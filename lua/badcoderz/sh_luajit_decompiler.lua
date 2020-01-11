
--[[
If you're interrested in this kind of stuff you can go here
https://github.com/ExtReMLapin/luajit_func_bytecode_toolbox

https://gist.github.com/meepen/807dd81a572ffb0f28a8c44c04922fdd

]]

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