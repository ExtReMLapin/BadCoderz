local instructions_db = {
	CALL = 62,
	KSHORT = 39,
	GGET = 52,
	UGET = 43,
	FUNCF = 85
}

local function disassemble_function(fn)
	local upvalues = {}
	local n = 0
	local upvalue = jit.util.funcuvname(fn, n)
	while (upvalue ~= nil) do
		upvalues[n] = upvalue
		n = n + 1
		upvalue = jit.util.funcuvname(fn, n)
	end


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
		local instruction = {}
		instruction.C = bit.rshift(bit.band(ins, 0x00ff0000), 16)
		instruction.B = bit.rshift(ins, 24)
		instruction.A = bit.rshift(bit.band(ins, 0x0000ff00), 8)
		instruction.D = bit.rshift(ins, 16)
		instruction.OP_CODE = bit.band(ins, 0xFF)
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

local Color_calls = {}
Color_calls["Color"] = true
Color_calls["SetDrawColor"] = true

-- to fix : it just find any Color() with static short int call, doesn't return the line
function BadCoderz.find_color_call_static_args(fn)
	local disassembled_code = disassemble_function(fn)
	local targeted_consts = {}
	local targeted_upvalues = {}

	for k, v in pairs(disassembled_code.consts) do
		if Color_calls[v] then
			targeted_consts[k] = true
		end
	end

	for k, v in pairs(disassembled_code.upvalues) do
		if Color_calls[v] then
			targeted_upvalues[k] = true
		end
	end

	if (table.Count(targeted_consts) == 0) and (table.Count(targeted_upvalues) == 0) then
		--[[print("infos :")
		PrintTable(debug.getinfo(fn))

		print("consts : ")
		PrintTable(disassembled_code.consts)]]

		return false, "Not found in const"
	end

	local count = #disassembled_code.instructions
	local i = 1

	while (i <= count) do
		local instruction = disassembled_code.instructions[i]

		if ((instruction.OP_CODE == instructions_db.GGET) and (targeted_consts[instruction.D] == true) or
			(instruction.OP_CODE == instructions_db.UGET) and (targeted_upvalues[instruction.D] == true))
				and (i + 4) < count then
			local KSHORT_count = 0
			local i2 = i + 1
			local cur_instruction = disassembled_code.instructions[i2]

			while ((i2 <= count) and (cur_instruction.OP_CODE == instructions_db.KSHORT)) do
				KSHORT_count = KSHORT_count + 1
				i2 = i2 + 1
				cur_instruction = disassembled_code.instructions[i2]
			end

			if (KSHORT_count ~= 3 and KSHORT_count ~= 4) then
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