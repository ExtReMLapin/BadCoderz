local reports = {}
local function do_report(func, hookname, lines, parentFuncs)
	reports[func] = reports[func] or {}
	reports[func][hookname] = reports[func][hookname] or {}
	reports[func][hookname][lines[#lines].location] = reports[func][hookname][lines[#lines].location] or {}

	if not reports[func][hookname][lines[#lines].location][lines[#lines].line] then
		reports[func][hookname][lines[#lines].location][lines[#lines].line] = {
			calls = 1,
			lines = lines,
			funcs = parentFuncs
		}
	else
		reports[func][hookname][lines[#lines].location][lines[#lines].line].calls = reports[func][hookname][lines[#lines].location][lines[#lines].line].calls + 1
	end
end

function BadCoderz.getReport()
	return reports
end

local color_red = Color(255, 50, 50)


local function fixGMAPath(path)
	if file.Exists("garrysmod/" .. path, "BASE_PATH") then return path end

	for k, v in pairs(BadCoderz.GMA_DB) do
		if table.HasValue(v, path) then
			path = k .. "/" .. path
			return path
		end
	end
	return path
end


--[[
	Some libs like ULib overwrite the hooks functions, so to detect it by locations we need to manually run a hook
	then detect the top function in the call stack and decide it's the file where the call comes from
]]
local function initScan()
	local debugTable
	local level = 1
	while true do
		local _debugTable = debug.getinfo(level, "S")
		if not _debugTable then break end
		debugTable = _debugTable
		level = level + 1
	end
	assert(debugTable, "What the fuck did you do to the hook system ?")
	BadCoderz.potentialsHooksFiles[debugTable.source:sub(2)] = true
	hook.Remove("Think", "badCoderzTrapHook")
end

local function _hook()
	local curStackLevel = 2
	local calledFunc = debug.getinfo(curStackLevel, "f").func

	if not BadCoderz.heavy_funcs[calledFunc] then
		return
	end

	if calledFunc == Color then
		local callingContext = debug.getinfo(curStackLevel + 1, "f")
		local callingContextFunc = callingContext.func

		local found = BadCoderz.find_color_call_static_args(callingContextFunc)
		if not found then
			return
		end

	end


	local level = 0
	traceTable = {}
	while true do
		local debugTable = debug.getinfo(level, "Sl")
		if not debugTable then break end
		level = level + 1
		-- already got level++'ed, don't do it again here
		traceTable[level] = {
			location = debugTable.source:sub(2),
			line = debugTable.currentline
		}
	end

	--------- getting the hook call
	local foundhookLevel = -1
	local foundHookContext
	local topStack = #traceTable
	local stackData = traceTable[topStack]
	local name, value = debug.getlocal(topStack - 1, 1)
	local foundName

	if name == "self" then

		local func = debug.getinfo(topStack - 1, "f").func
		if value == gmod.GetGamemode() then
			for k, v in pairs(value) do
				if not isfunction(v) then continue end

				if v == func then
					foundName = k
					break
				end
			end
			if foundName and BadCoderz.dangerous_hooks[foundName] then
				foundHookContext = "GM:" .. foundName
				foundhookLevel = topStack - 1
			else
				return
			end
		elseif IsEntity(value) then
			for k, v in pairs(value:GetTable()) do
				if not isfunction(v) then continue end

				if func == v then
					foundName = k
					break
				end
			end

			if foundName and BadCoderz.dangerous_hooks[foundName] then
				foundHookContext = "ENT:" .. foundName
				foundhookLevel = topStack - 1
			else
				return
			end
		elseif ispanel(value) then
			for k, v in pairs(value:GetTable()) do
				if not isfunction(v) then continue end

				if func == v then
					foundName = k
					break
				end
			end

			if foundName and BadCoderz.dangerous_hooks[foundName] then
				foundHookContext = "PANEL:" .. foundName
				foundhookLevel = topStack - 1
			else
				return
			end
		else
			print("Var type " .. type(value) .. " is not implemented in BadCoderz, pls tell the dev")
			return
		end
	elseif BadCoderz.potentialsHooksFiles[stackData.location] then
		local hookStackLevel = topStack - 1
		local i = 1


		while (true) do
			local _name, _value = debug.getlocal(hookStackLevel, i)
			if (_name == nil) then break end

			if _name == "name" then
				foundName = _value
				break
			end

			i = i + 1
		end

		if foundName and BadCoderz.dangerous_hooks[foundName] then
			foundHookContext = "GM:" .. foundName
			foundhookLevel = topStack - 2 -- ignore the very stop stack cuz it's the hook call from Lua
		else
			return
		end
	else
		return
	end

	local lines = {}
	local functions = {}
	local targetStackLevel = curStackLevel

	if debug.getinfo(calledFunc).what == "Lua" then
		targetStackLevel = targetStackLevel + 1
	end

	while (foundhookLevel >= targetStackLevel) do
		local data = debug.getinfo(foundhookLevel, "lSf")
		if data.currentline == -1 then
			foundhookLevel = foundhookLevel - 1
			continue
		end
		local infoline = {location = fixGMAPath(data.source:gsub("^@", "")), line = data.currentline}
		table.insert(lines, infoline)
		table.insert(functions, data.func)
		foundhookLevel = foundhookLevel - 1
	end

	do_report(BadCoderz.heavy_funcs[calledFunc], foundHookContext, lines, functions)
end


local function start_scan()
	jit.off()
	-- you also need to flush the jit cache because it may miss something if one day LuaJIT stitching gets jitted with black magic
	jit.flush()

	hook.Add("Think", "badCoderzTrapHook", initScan)
	BadCoderz.test_running = true
	reports = {}

	if CLIENT and gui.IsConsoleVisible() then
		MsgC(color_red, "PLEASE CLOSE THE CONSOLE TO RUN ALL CLIENTS CHECKS\n")
	end
	debug.sethook(_hook, "c") -- hook functions calls
end

local function stop_scan()
	jit.on()
	BadCoderz.test_running = false
	debug.sethook(_hook, "")
end

function BadCoderz.toggle()
	if not BadCoderz.test_running then
		start_scan()
	else
		stop_scan()
	end
end


