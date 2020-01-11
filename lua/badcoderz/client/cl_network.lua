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

	if (BadCoderz.Derma and IsValid(BadCoderz.Derma)) then
		BadCoderz.Derma.buttonServerside:UpdateAsync(active, report)
	end
end)

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

net.Receive("BadCoderz_serverside_bytecode_reader", function(len)
	assert(GLib, "GLib is missing")
	local bytecode = util.Decompress(net.ReadData(net.ReadUInt(16)))
	local pointer = net.ReadString()
	local stack = net.ReadString()
	local location = net.ReadString()
	local code = string.format("--[[\n\n%s\n\n]]\n\n", stack) .. bytecode
	BadCoderz.openLuaPad(code, "DECOMPILED VIRTUAL FUNCTION : " .. pointer .. " " .. location)
end)