util.AddNetworkString("BadCoderz_status_request")
util.AddNetworkString("BadCoderz_report_request")
util.AddNetworkString("BadCoderz_scan_request")
util.AddNetworkString("BadCoderz_compiled_report_request")
util.AddNetworkString("BadCoderz_serverside_file_open")
util.AddNetworkString("BadCoderz_serverside_bytecode_reader")
util.AddNetworkString("BadCoderz_next_reboot_scan_change_status")
util.AddNetworkString("BadCoderz_stop_boot_scan")

net.Receive("BadCoderz_status_request",function (len, context)
	if not context:CanUseBadCoderz() then return end
	net.Start("BadCoderz_status_request")
	net.WriteBool(BadCoderz.scanningCodeSmells)
	net.WriteBool(BadCoderz.scanningCompiledFuncs)
	net.WriteBool(BadCoderz.scanCompiledFuncsOnNextBoot)
	net.Send(context)
end)


--[[
	BUG #3 : a net message is limited to 64 KB, and the report used to be sent whole : as soon as the compressed
	report passed 64000 bytes WriteReport raised "Report is too big :(" and nothing was sent at all (the UI then
	waited forever) : the longer the scan, the more likely the failure.
	New behaviour : the entries are sorted by number of calls and the report is cut to what fits, the client is told
	that it was truncated.
]]
local MAX_NET_PAYLOAD = 60000 -- compressed bytes, keeps a margin under the 64 KB limit of a net message

-- every reported line as a flat list, most called first
local function flattenReport(report)
	local list = {}

	for func, hooks in pairs(report) do
		for hookName, locations in pairs(hooks) do
			for location, lines in pairs(locations) do
				for line, info in pairs(lines) do
					list[#list + 1] = { func = func, hook = hookName, location = location, line = line, info = info }
				end
			end
		end
	end

	table.sort(list, function(a, b) return a.info.calls > b.info.calls end)

	return list
end

-- the report made of the `count` first (most called) entries of the flat list
local function buildReport(list, count)
	local out = {}

	for i = 1, count do
		local e = list[i]
		out[e.func] = out[e.func] or {}
		out[e.func][e.hook] = out[e.func][e.hook] or {}
		out[e.func][e.hook][e.location] = out[e.func][e.hook][e.location] or {}
		-- `funcs` (references to the functions of the stack) is only used server side and can't be sent anyway
		out[e.func][e.hook][e.location][e.line] = { calls = e.info.calls, lines = e.info.lines }
	end

	return out
end

local function compressReport(list, count)
	return util.Compress(util.TableToJSON(buildReport(list, count)))
end

-- returns the compressed report that fits in a net message, and whether it had to be truncated
function BadCoderz.GetNetReport()
	local list = flattenReport(BadCoderz.getReport())
	local data = compressReport(list, #list)

	if #data <= MAX_NET_PAYLOAD then return data, false end

	-- binary search of the biggest number of entries that fits, first probe by proportionality to save time
	local lo, hi = 0, #list - 1 -- `lo` always fits (empty report), `hi` is the highest candidate
	local mid = math.Clamp(math.floor(#list * MAX_NET_PAYLOAD / #data * 0.97), 1, hi)

	while lo < hi do
		if #compressReport(list, mid) <= MAX_NET_PAYLOAD then
			lo = mid
		else
			hi = mid - 1
		end

		mid = math.ceil((lo + hi + 1) / 2)
	end

	return compressReport(list, lo), true
end

function BadCoderz.WriteReport(ply)
	if not ply:CanUseBadCoderz() then return end
	-- local json = util.TableToJSON(BadCoderz.getReport()) -- big boi
	-- local data = util.Compress(json)
	--
	-- if string.len(data) > 64000 then
	-- 	error("Report is too big :(")
	-- end
	local data, truncated = BadCoderz.GetNetReport()

	net.Start("BadCoderz_report_request")
	net.WriteBool(BadCoderz.scanningCodeSmells)
	net.WriteUInt(string.len(data), 16)
	net.WriteData(data, string.len(data))
	net.WriteBool(truncated) -- read by the client after the data (an old client just ignores it)
	net.Send(ply)
end


net.Receive("BadCoderz_report_request",function (_, ply)
	if not ply:CanUseBadCoderz() then return end
	BadCoderz.WriteReport(ply)
end)

net.Receive("BadCoderz_scan_request",function (_, ply)
	if not ply:CanUseBadCoderz() then return end
	BadCoderz.toggleCodeSmellsScan()
end)


--[[
	BUG #3 : the whole file used to be compressed into ONE net message, with its length written on 16 bits : a file
	whose compressed size is over 64 KB overflowed the field and the message limit, and never reached the client.
	New behaviour : the text is cut in parts of FILE_PART_RAW bytes, each part is compressed and sent in its own
	message, one part every FILE_PART_DELAY seconds (a burst of big reliable messages can overflow the reliable
	channel and disconnect the player). Each message ends with `part index, part count`, the client reassembles.
]]
local FILE_PART_RAW = 40000 -- raw bytes per message : even incompressible, it stays far below the 64 KB limit
local FILE_PART_DELAY = 0.05
local FILE_MAX_SIZE = 4 * 1024 * 1024

local function sendFile(ply, fakePath, text, line)
	local parts = math.max(1, math.ceil(#text / FILE_PART_RAW))

	for part = 1, parts do
		timer.Simple((part - 1) * FILE_PART_DELAY, function()
			if not IsValid(ply) then return end

			local data = util.Compress(text:sub((part - 1) * FILE_PART_RAW + 1, part * FILE_PART_RAW))
			local len = data:len()
			net.Start("BadCoderz_serverside_file_open")
			net.WriteString(fakePath)
			net.WriteUInt(len, 16)
			net.WriteData(data, len)
			local sendLine = line ~= nil
			net.WriteBool(sendLine)
			if sendLine == true then
				net.WriteUInt(line, BadCoderz.NET_LINE_BITS)
			end
			net.WriteUInt(part - 1, 12)
			net.WriteUInt(parts, 12)
			net.Send(ply)
		end)
	end
end

-- Safe lookup in the report : the client sends 4 strings/numbers and the report may have been reset since (BUG #5 :
-- the old code indexed report[func][hookname][location][callLineID] without any check and raised an error).
local function findReportedFunction(func, hookname, location, callLineID, k)
	local report = BadCoderz.getReport()
	local byHook = report[func]
	local byLocation = byHook and byHook[hookname]
	local byLine = byLocation and byLocation[location]
	local entry = byLine and byLine[callLineID]

	return entry and entry.funcs and entry.funcs[k]
end

net.Receive("BadCoderz_serverside_file_open",function (_, ply)
	if not ply:CanUseBadCoderz() then return end

	local gamePath = net.ReadString()
	local fakePath = net.ReadString()
	local line;
	local text
	if (net.ReadBool() == true) then
		line = net.ReadUInt(BadCoderz.NET_LINE_BITS) -- was 13 bits : lines above 8191 came back wrong (BUG #4)
		local client = net.ReadBool()
		local _func
		if client == false then
			local func = net.ReadString()
			local hookname = net.ReadString()
			local location = net.ReadString()
			local callLineID = net.ReadUInt(BadCoderz.NET_LINE_BITS)
			local k = net.ReadUInt(BadCoderz.NET_STACK_BITS) -- was 8 bits : stacks deeper than 255 frames wrapped
			-- _func = BadCoderz.getReport()[func][hookname][location][callLineID].funcs[k]
			_func = findReportedFunction(func, hookname, location, callLineID, k)
		end
		if file.Exists(gamePath, "LUA") then
			text = file.Read(gamePath,"LUA")
		elseif not GLib then
			ply:ChatPrint("You need GLib to decompile this function, get it here : https://github.com/notcake/glib")
			return
		elseif not _func then
			ply:ChatPrint("This function is not in the report anymore (the scan was restarted ?), refresh the report.")
			return
		else
			-- text = GLib.Lua.BytecodeReader(_func):ToString()
			text = GLib.Lua.BytecodeReader(_func):ToString()
		end
	else
		if not file.Exists(gamePath, "LUA") then
			ply:ChatPrint("Can't open the file, it was created with compilestring, please try to open a function of it, not the file itself.")
			return
		end

		text = file.Read(gamePath,"LUA")
	end

	if not text or text == "" then
		ply:ChatPrint("Can't open the file : it is empty or unreadable.")
		return
	end

	if #text > FILE_MAX_SIZE then
		ply:ChatPrint("Can't open the file : it is too big (" .. #text .. " bytes, limit " .. FILE_MAX_SIZE .. ").")
		return
	end

	--[[
	-- OLD : one message for the whole file
	local data = util.Compress(text)
	local len = data:len()
	net.Start("BadCoderz_serverside_file_open")
	net.WriteString(fakePath)
	net.WriteUInt(len,16)
	net.WriteData(data, len)
	local sendLine = line != nil
	net.WriteBool(sendLine)
	if sendLine == true then
		net.WriteUInt(line, 13)
	end
	net.Send(ply)
	]]
	sendFile(ply, fakePath, text, line)
end)



net.Receive("BadCoderz_serverside_bytecode_reader",function (_, ply)
	if not ply:CanUseBadCoderz() then return end
	local index = net.ReadUInt(16)
	local funcTable = BadCoderz.compiledFuncs[index]
	-- BUG #5 : an unknown index used to raise an error (assert) and a missing GLib an "attempt to index global 'GLib'"
	-- assert(funcTable, "Index for decompiled function " .. index .. " doesn't exist")
	if not funcTable then
		ply:ChatPrint("Index for decompiled function " .. index .. " doesn't exist")
		return
	end

	if not GLib then
		ply:ChatPrint("You need GLib to decompile this function, get it here : https://github.com/notcake/glib")
		return
	end

	net.Start("BadCoderz_serverside_bytecode_reader")
	local byteCode = util.Compress(GLib.Lua.BytecodeReader(funcTable.func):ToString())
	local byteCodeLen = byteCode:len()
	net.WriteUInt(byteCodeLen, 16)
	net.WriteData(byteCode, byteCodeLen)
	net.WriteString(funcTable.pointer)
	net.WriteString(funcTable.stack)
	net.WriteString(funcTable.location)
	net.Send(ply)
end)

net.Receive("BadCoderz_compiled_report_request", function(_, ply)
	if not ply:CanUseBadCoderz() then return end
	local len = #BadCoderz.compiledFuncs
	net.Start("BadCoderz_compiled_report_request")
	net.WriteUInt(len, 16)
	local i = 1
	while (i <= len) do
		local funcTable = BadCoderz.compiledFuncs[i]
		local byteCode = string.dump(funcTable.func)
		local byteCodeLen = byteCode:len()
		net.WriteUInt(byteCodeLen, 16)
		net.WriteString(funcTable.location)
		net.WriteString(funcTable.pointer)
		net.WriteUInt(funcTable.level, 4)
		net.WriteFloat(funcTable.time)
		i = i + 1
	end
	net.Send(ply)
end)


net.Receive("BadCoderz_next_reboot_scan_change_status", function(len, ply)
	if not ply:CanUseBadCoderz() then return end
	BadCoderz.prepareCompiledFuncsScanNextReboot(net.ReadBool())
end)

net.Receive("BadCoderz_stop_boot_scan", function(len, ply)
	if not ply:CanUseBadCoderz() or not BadCoderz.scanningCompiledFuncs then return end
	BadCoderz.scanningCompiledFuncs = false
	debug.sethook()
end)