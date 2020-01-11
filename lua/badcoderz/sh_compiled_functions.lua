BadCoderz.compiledFuncs = BadCoderz.compiledFuncs or {}
BadCoderz.scanningCompiledFuncs = false
BadCoderz.scanCompiledFuncsOnNextBoot = false


local filename;

if CLIENT then
	filename = "badcoderz_scan_on_boot_cl.txt"
else
	filename = "badcoderz_scan_on_boot_sv.txt"
end

function BadCoderz.prepareCompiledFuncsScanNextReboot(bEnable)
	if bEnable then
		file.Write(filename, "") 
		BadCoderz.scanCompiledFuncsOnNextBoot = true
	else
		file.Delete(filename)
		BadCoderz.scanCompiledFuncsOnNextBoot = false
	end
end


local ignored_funcs = {} -- rip garbage collection

local settings = {
	detectFakePath = true -- detecting fuckers doing RunString("bluh blug", "lua/legit_lua_file.lua")
}


local function call_wrapper(_)
	local debugInfos = debug.getinfo(2, "flnSu")
	local curFunction = debugInfos.func
	if ignored_funcs[curFunction] then return end
	local source = debugInfos.source:sub(2) -- source might need to be reformated to work with file.Read(source, "LUA")

	if source == "[C]" then
		ignored_funcs[curFunction] = true

		return
	end

	local lineDefined = debugInfos.linedefined

	if lineDefined ~= 0 then
		ignored_funcs[curFunction] = true

		return
	end

	local level = 0

	-- at this point if you're not even trying to hide it ...
	if source == "RunString" then
		level = 1
	elseif settings.detectFakePath and file.Exists(source, "GAME") then
		local code = file.Read(source, "GAME")
		local bytecode = CompileString(code, source)

		-- ghetto
		if string.dump(curFunction) == string.dump(bytecode) then
			ignored_funcs[curFunction] = true

			return
		end

		level = 2
	end


	table.insert(BadCoderz.compiledFuncs, {
		pointer = tostring(curFunction):sub(11),
		func = curFunction,
		location = source,
		level = level,
		time = SysTime(),
		stack = debug.traceback("", 2)
	})
end

if file.Exists(filename, "DATA") then

	debug.sethook(call_wrapper, "c")
	BadCoderz.scanningCompiledFuncs = true
	file.Delete(filename)
end


