
--[[
If you're interrested in this kind of stuff you can go here
https://github.com/ExtReMLapin/luajit_func_bytecode_toolbox

https://gist.github.com/meepen/807dd81a572ffb0f28a8c44c04922fdd

]]

-- Fallback opcode numbers, only used if the runtime probe below fails (see detect_opcodes).
local instructions_db;

if jit.version_num < 20100 then
	instructions_db = {
		CALL = 62,
		KSHORT = 39,
		GGET = 52,
		UGET = 43,
		FUNCF = 85,
		KNUM = 40
	}
else -- bytecode changes
	instructions_db = {
		CALL = 66,
		KSHORT = 41,
		GGET = 54,
		UGET = 45,
		FUNCF = 89,
		KNUM = 42
	}
end

--[[
	BUG #17 / #11 : jit.util.funck and jit.util.funcuvname are disabled by Facepunch ("disabled due to security
	concerns", https://wiki.facepunch.com/gmod/jit.util.funck) and return nothing, so the old analysis (kept,
	commented, at the bottom of this file) could never read the name of the called function and therefore never
	detected any static Color/Vector/Angle call.

	New approach, which needs neither constants nor names: the profiler hook already knows WHICH function was
	called (Color, Vector, Angle), so the only thing left to check is whether the arguments of the CALL
	instruction at the given line are all loaded by KSHORT/KNUM instructions, i.e. are compile-time constants.
	jit.util.funcbc (still enabled) is enough for that.

	Known limit : we cannot tell WHICH call of a line was executed (the frame's pc is not exposed), so a line that
	holds both a static and a dynamic call to the same constructor is reported as static.
]]

-- Opcode numbers are derived at load time from a probe function instead of being hardcoded per LuaJIT version.
-- Returns nil if the probe does not look like what we expect (then we keep the fallback table above).
local function detect_opcodes()
	local probe = CompileString("local F = ... local a = F(255, 0, 0) local b = F(1.5, 2.5, 3.5) return F(1, 2, 3)", "badcoderz_opcode_probe")
	if not isfunction(probe) then return nil end

	local ops = {}
	local pc = 0
	while true do
		local ins = jit.util.funcbc(probe, pc)
		if not ins then break end
		ops[pc] = bit.band(ins, 0xFF)
		pc = pc + 1
	end

	-- expected layout (pc 0 is the function header, pc 1 is VARG/MOV for `...`, hence we search by pattern)
	-- ... KSHORT KSHORT KSHORT CALL ... KNUM KNUM KNUM CALL ... KSHORT KSHORT KSHORT CALLT
	local last = pc - 1
	local callt = ops[last]
	local found
	for i = 1, last - 1 do
		local k1, k2, k3, call = ops[i], ops[i + 1], ops[i + 2], ops[i + 3]
		if k1 and k1 == k2 and k2 == k3 and call and call ~= k1 then
			found = found or {}
			found[#found + 1] = { k = k1, call = call }
		end
	end
	if not found or #found < 3 then return nil end

	local kshort, call = found[1].k, found[1].call
	local knum = found[2].k
	if found[2].call ~= call or found[3].k ~= kshort or found[3].call ~= callt then return nil end
	if kshort == knum or call == callt then return nil end

	return { KSHORT = kshort, KNUM = knum, CALL = call, CALLT = callt }
end

local opcodes = detect_opcodes()

if not opcodes then
	-- CALLT follows CALL by two in every LuaJIT version (CALLM, CALL, CALLMT, CALLT)
	opcodes = {
		KSHORT = instructions_db.KSHORT,
		KNUM = instructions_db.KNUM,
		CALL = instructions_db.CALL,
		CALLT = instructions_db.CALL + 2
	}
	print("BadCoderz : opcode probe failed, falling back to the hardcoded LuaJIT " .. tostring(jit.version) .. " opcode table")
end

-- Disassembly cache (BUG #8 : the old code disassembled the whole calling function again on every single hit).
-- Weak keys : we never keep a function alive just because we analysed it.
local disassembly_cache = setmetatable({}, { __mode = "k" })

-- Only keeps what the analysis needs : for each CALL/CALLT, its pc and argument count, plus the opcode of every pc.
local function disassemble_function(fn)
	local cached = disassembly_cache[fn]
	if cached then return cached end

	local ops = {}
	local registers = {}
	local calls = {}
	local pc = 1 -- pc 0 is the function header
	while true do
		local ins = jit.util.funcbc(fn, pc)
		if not ins then break end
		local op = bit.band(ins, 0xFF)
		ops[pc] = op
		registers[pc] = bit.rshift(bit.band(ins, 0x0000ff00), 8) -- operand A

		if op == opcodes.CALL then
			-- CALL A B C : C - 1 arguments
			calls[#calls + 1] = { pc = pc, nargs = bit.rshift(bit.band(ins, 0x00ff0000), 16) - 1 }
		elseif op == opcodes.CALLT then
			-- CALLT A D : D - 1 arguments
			calls[#calls + 1] = { pc = pc, nargs = bit.rshift(ins, 16) - 1 }
		end

		pc = pc + 1
	end

	cached = { ops = ops, registers = registers, calls = calls }
	disassembly_cache[fn] = cached
	return cached
end

-- `definition` is an entry of BadCoderz.heavy_funcs_objects : { names, { true, true, true, false } }
-- (true = required numeric argument, false = optional one). `names` is not needed anymore (see above).
-- Returns true if a call on `expectedLine` has between min and max arguments that are all numeric constants.
function BadCoderz.find_call_static_args(fn, definition, expectedLine)
	local minNums = 0
	local maxNums = 0
	for _, v in ipairs(definition[2]) do
		if v == true then
			minNums = minNums + 1
		end
		maxNums = maxNums + 1
	end

	local disassembled = disassemble_function(fn)
	local ops, registers = disassembled.ops, disassembled.registers

	for _, call in ipairs(disassembled.calls) do
		local nargs, pc = call.nargs, call.pc

		if nargs >= minNums and nargs <= maxNums and pc - nargs >= 1 then
			-- every argument must come from a KSHORT/KNUM, loaded in consecutive registers right before the call
			local allStatic = true
			for j = pc - nargs, pc - 1 do
				local op = ops[j]
				if (op ~= opcodes.KSHORT and op ~= opcodes.KNUM) or (j > pc - nargs and registers[j] ~= registers[j - 1] + 1) then
					allStatic = false
					break
				end
			end

			if allStatic and jit.util.funcinfo(fn, pc).currentline == expectedLine then return true end
		end
	end

	return false, "no call with only constant arguments on this line"
end

-- ---------------------------------------------------------------------------------------------------------------
-- OLD IMPLEMENTATION (kept for reference, disabled). It relied on jit.util.funck / jit.util.funcuvname, which
-- Facepunch disabled, and it leaked the globals `n` (BUG #12) and re-disassembled the function on every call (#8).
-- ---------------------------------------------------------------------------------------------------------------
--[==[
local function disassemble_function(fn)
	local upvalues = {}
	n = 0
	local upvalue = jit.util.funcuvname(fn, n)
	while (upvalue ~= nil) do
		upvalues[n] = upvalue
		n = n + 1
		upvalue = jit.util.funcuvname(fn, n)
	end


	-- consts are BELLOW zero, 64bits nums (KNUMS) are ABOVE zero but we don't need them here, we're just looking for the functions call names
	local consts = {}
	n = -1
	local value = jit.util.funck(fn, n)
	while (value ~= nil) do
		consts[-1 * n - 1] = value
		n = n - 1
		value = jit.util.funck(fn, n)
	end
	n = 1

	local countBC = jit.util.funcinfo(fn).bytecodes
	local instructions = {}

	if bit.band(select(1, jit.util.funcbc(fn, 0)), 0xFF) < instructions_db.FUNCF then
		print("BadCoderz decompiler : this should not happen")
	end

	while (n < countBC) do
		local ins = jit.util.funcbc(fn, n)
		local instruction = {
			C = bit.rshift(bit.band(ins, 0x00ff0000), 16),
			B = bit.rshift(ins, 24),
			A = bit.rshift(bit.band(ins, 0x0000ff00), 8),
			D = bit.rshift(ins, 16),
			OP_CODE = bit.band(ins, 0xFF)
		}
		instructions[n] = instruction
		n = n + 1
	end

	local ret = {
		consts = consts,
		instructions = instructions,
		upvalues = upvalues
	}

	return ret
end

function BadCoderz.find_call_static_args(fn, definition, expectedLine)
	-- to fix : it just find any Color() with static short int call, doesn't return the line
	local minNums = 0
	local maxNums = 0
	for k, v in ipairs(definition[2]) do
		if v == true then
			minNums = minNums + 1
		end
		maxNums = maxNums + 1
	end



	local disassembled_code = disassemble_function(fn)
	local targeted_consts = {}
	local targeted_upvalues = {}

	for k, v in pairs(disassembled_code.consts) do
		if definition[1][v] then
			targeted_consts[k] = true
		end
	end

	for k, v in pairs(disassembled_code.upvalues) do
		if definition[1][v] then
			targeted_upvalues[k] = true
		end
	end

	if (table.Count(targeted_consts) == 0) and (table.Count(targeted_upvalues) == 0) then
		return false, "Not found in const"
	end

	local count = #disassembled_code.instructions
	local i = 1

	while (i <= count) do
		local instruction = disassembled_code.instructions[i]

		if (((instruction.OP_CODE == instructions_db.GGET) and (targeted_consts[instruction.D] == true) or
			(instruction.OP_CODE == instructions_db.UGET) and (targeted_upvalues[instruction.D] == true))
				and ((i + minNums) < count) and jit.util.funcinfo(fn, i).currentline == expectedLine) then
			local NUMBER_count = 0
			local i2 = i + 1
			local cur_instruction = disassembled_code.instructions[i2]

			while ((i2 <= count) and ((cur_instruction.OP_CODE == instructions_db.KSHORT) or (cur_instruction.OP_CODE == instructions_db.KNUM))) do
				NUMBER_count = NUMBER_count + 1
				i2 = i2 + 1
				cur_instruction = disassembled_code.instructions[i2]
			end

			if (NUMBER_count < minNums or NUMBER_count > maxNums) then
				i = i + 1
				continue
			end

			if (cur_instruction.OP_CODE ~= instructions_db.CALL) then
				i = i + 1
				continue
			end

			return true
		end

		i = i + 1
	end

	return false, "didnt find shit"
end
]==]
