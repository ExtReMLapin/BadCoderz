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

--[[
	OLD VERSION (disabled) : for every frame of every reported call it did a file.Exists and then a
	table.HasValue over the file list of EVERY mounted GMA (BUG #7 : 150 addons x 2 frames x each hit = tens of
	thousands of linear scans per second, while profiling code that is itself being called every frame).
	When a file was present in several GMAs the winner also depended on the iteration order of pairs().

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
]]

-- NEW VERSION : a reverse index file -> GMA built once, and a per-path cache of the final answer.
-- The index is rebuilt when BadCoderz.GMA_DB is replaced, and at the start of every scan.
local gmaIndexSource -- the GMA_DB table the index was built from
local gmaIndex = {} -- "lua/foo/bar.lua" -> "addons/xxx.gma"
local gmaPathCache = {} -- path given by the debug library -> path shown in the report

local function rebuildGMAIndex()
	gmaIndexSource = BadCoderz.GMA_DB
	gmaIndex = {}
	gmaPathCache = {}

	for gma, files in pairs(gmaIndexSource) do
		for _, filePath in ipairs(files) do
			local known = gmaIndex[filePath]

			-- the same file can exist in several GMAs : keep the smallest name so the result is deterministic
			if known == nil or gma < known then
				gmaIndex[filePath] = gma
			end
		end
	end
end

local function fixGMAPath(path)
	if gmaIndexSource ~= BadCoderz.GMA_DB then rebuildGMAIndex() end

	local cached = gmaPathCache[path]
	if cached then return cached end

	local fixed = path

	if not file.Exists("garrysmod/" .. path, "BASE_PATH") then
		local gma = gmaIndex[path]

		if gma then
			fixed = gma .. "/" .. path
		end
	end

	gmaPathCache[path] = fixed

	return fixed
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

local hookNames = {
	name = true,
	event_name = true
}

local function _hook()
	local curStackLevel = 2
	local calledFunc = debug.getinfo(curStackLevel, "f").func
	if not BadCoderz.heavy_funcs[calledFunc] then return end
	--threats functions like Color/Angle/Vector in a different way since the way it's called matters
	local heavyObject = BadCoderz.heavy_funcs_objects[calledFunc]

	if heavyObject then
		local callingContext = debug.getinfo(curStackLevel + 1, "fSl")
		if callingContext.what == "C" then return end -- C could be calling it for some reason
		local callingContextFunc = callingContext.func
		local found = BadCoderz.find_call_static_args(callingContextFunc, heavyObject, callingContext.currentline)
		if not found then return end
	end

	local level = 0
	-- BUG #12 : this used to be a global (`traceTable = {}`) that leaked into _G and made the hook non reentrant
	-- traceTable = {}
	local traceTable = {}

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

			if hookNames[_name] == true then
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

		local infoline = {
			location = fixGMAPath(data.source:gsub("^@", "")),
			line = data.currentline
		}

		table.insert(lines, infoline)
		table.insert(functions, data.func)
		foundhookLevel = foundhookLevel - 1
	end

	do_report(BadCoderz.heavy_funcs[calledFunc], foundHookContext, lines, functions)
end

-- What was in place before the scan started, so that stopping it puts everything back (BUG #1 and #14).
-- There is only ONE debug hook slot per thread : the "scan RunString at boot" hook (sh_compiled_functions.lua),
-- profilers or debuggers may already be using it.
local previousHook = {}
local jitWasOn = true

local function start_scan()
	print("started scan")
	-- remember the state we are about to overwrite
	jitWasOn = jit.status()
	previousHook.func, previousHook.mask, previousHook.count = debug.gethook()

	jit.off()
	-- you also need to flush the jit cache because it may miss something if one day LuaJIT stitching gets jitted with black magic
	jit.flush()
	hook.Add("Think", "badCoderzTrapHook", initScan)
	BadCoderz.scanningCodeSmells = true
	reports = {}
	rebuildGMAIndex() -- GMA_DB may have changed since the last scan (BUG #7 : the index is cached)

	if CLIENT and gui.IsConsoleVisible() then
		MsgC(color_red, "PLEASE CLOSE THE CONSOLE TO RUN ALL CLIENTS CHECKS\n")
	end

	debug.sethook(_hook, "c") -- hook functions calls
end

local function stop_scan()
	-- BUG #14 : jit.on() used to be called unconditionally, even if the JIT was off before the scan
	-- jit.on()
	if jitWasOn then
		jit.on()
	end

	BadCoderz.scanningCodeSmells = false
	hook.Remove("Think", "badCoderzTrapHook") -- the trap is useless (and stays registered) if the scan is stopped before the first Think

	-- BUG #1 : this used to disable every hook, destroying the one that was active before the scan
	-- debug.sethook(_hook, "")
	debug.sethook(previousHook.func, previousHook.mask or "", previousHook.count or 0)
end

function BadCoderz.toggleCodeSmellsScan()
	if not BadCoderz.scanningCodeSmells then
		start_scan()
	else
		stop_scan()
	end
end
