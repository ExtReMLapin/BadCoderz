function BadCoderz.ReadReport()
	local len = net.ReadUInt(16)
	local data = net.ReadData(len)
	local json = util.Decompress(data)
	local table = util.JSONToTable(json)

	return table
end

net.Receive("BadCoderz_status_request", function()
	local codeSmellsScan = net.ReadBool()
	local compiledFuncsScan = net.ReadBool()
	local scanOnReboot = net.ReadBool()
	BadCoderz.ShowUI(codeSmellsScan, compiledFuncsScan, scanOnReboot)
end)

concommand.Add("BadCoderz", function()
	if not LocalPlayer():CanUseBadCoderz() then
		LocalPlayer():ChatPrint("You cannot use badcoderz")

		return
	end

	net.Start("BadCoderz_status_request")
	net.SendToServer()
end)

net.Receive("BadCoderz_report_request", function()
	local active = net.ReadBool()
	local report = BadCoderz.ReadReport()
	-- BUG #3 : the server now cuts a report that would not fit in a net message and says so after the data
	-- (false when talking to an old server, ReadBool past the end of the message returns false)
	local truncated = net.ReadBool()

	if truncated then
		LocalPlayer():ChatPrint("BadCoderz : the server report was too big for one network message, only the most called entries are shown.")
	end

	if (BadCoderz.Derma and IsValid(BadCoderz.Derma)) then
		BadCoderz.Derma.buttonServerside:UpdateAsync(active, report)
	end
end)

-- BUG #3 : files are now received in several parts (see sv_network.lua), kept here until they are all there.
local incomingFiles = {} -- path -> { parts = {}, count = n, got = n }

--[[
-- OLD : one message per file, line on 13 bits
net.Receive("BadCoderz_serverside_file_open", function(len)
	local realPath = net.ReadString()
	local datalen = net.ReadUInt(16)
	local data = net.ReadData(datalen)
	local line

	if (net.ReadBool()) then
		line = net.ReadUInt(13)
	end

	data = util.Decompress(data)

	if not data then
		error("Could not read file data from server : " .. realPath)

		return
	end

	BadCoderz.openLuaPad(data, realPath, line)
end)
]]
net.Receive("BadCoderz_serverside_file_open", function(len)
	local realPath = net.ReadString()
	local datalen = net.ReadUInt(16)
	local data = net.ReadData(datalen)
	local line

	if (net.ReadBool()) then
		line = net.ReadUInt(BadCoderz.NET_LINE_BITS) -- BUG #4 : was 13 bits
	end

	local partIndex = net.ReadUInt(12)
	local partCount = math.max(net.ReadUInt(12), 1) -- 0 = message from a server without multipart support

	data = util.Decompress(data)

	if not data then
		error("Could not read file data from server : " .. realPath)

		return
	end

	local pending = incomingFiles[realPath]

	-- a new transfer starts with part 0 (or if the number of parts changed)
	if not pending or partIndex == 0 or pending.count ~= partCount then
		pending = { parts = {}, count = partCount, got = 0 }
		incomingFiles[realPath] = pending
	end

	if not pending.parts[partIndex + 1] then
		pending.got = pending.got + 1
	end

	pending.parts[partIndex + 1] = data

	if pending.got < pending.count then return end

	incomingFiles[realPath] = nil
	BadCoderz.openLuaPad(table.concat(pending.parts), realPath, line)
end)

net.Receive("BadCoderz_serverside_bytecode_reader", function(len)
	assert(GLib, "GLib is missing")
	local bytecode = util.Decompress(net.ReadData(net.ReadUInt(16)))
	local pointer = net.ReadString()
	local stack = net.ReadString()
	local location = net.ReadString()
	local code = string.format("--[[\n\n%s\n\n]]\n\n", stack) .. bytecode
	BadCoderz.openLuaPad(code, "DECOMPILED VIRTUAL FUNCTION : " .. pointer .. " " .. location)
end)