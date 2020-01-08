util.AddNetworkString("BadCoderz_status_request")
util.AddNetworkString("BadCoderz_report_request")
util.AddNetworkString("BadCoderz_scan_request")
util.AddNetworkString("BadCoderz_serverside_file_open")



net.Receive("BadCoderz_status_request",function (len, context)
	if not context:CanUseBadCoderz() then return end
	net.Start("BadCoderz_status_request")
	net.WriteBool(BadCoderz.test_running)
	net.Send(context)
end)


function BadCoderz.WriteReport(ply)
	if not ply:CanUseBadCoderz() then return end
	local json = util.TableToJSON(BadCoderz.getReport()) -- big boi
	local data = util.Compress(json)

	if string.len(data) > 64000 then
		error("Report is too big :(")
	end

	net.Start("BadCoderz_report_request")
	net.WriteBool(BadCoderz.test_running)
	net.WriteUInt(string.len(data), 16)
	net.WriteData(data, string.len(data))
	net.Send(ply)
end


net.Receive("BadCoderz_report_request",function (len, ply)
	if not ply:CanUseBadCoderz() then return end
	BadCoderz.WriteReport(ply)
end)

net.Receive("BadCoderz_scan_request",function (len, ply)
	if not ply:CanUseBadCoderz() then return end
	BadCoderz.toggle()
end)


net.Receive("BadCoderz_serverside_file_open",function (len, ply)
	if not ply:CanUseBadCoderz() then return end

	local gamePath = net.ReadString()
	local fakePath = net.ReadString()
	local line;
	local text
	if (net.ReadBool() == true) then
		line = net.ReadUInt(13)
		local client = net.ReadBool()
		local _func
		if client == false then
			local func = net.ReadString()
			local hookname = net.ReadString()
			local location = net.ReadString()
			local callLineID = net.ReadUInt(13)
			local k = net.ReadUInt(8)
			_func = BadCoderz.getReport()[func][hookname][location][callLineID].funcs[k]
		end
		if file.Exists(gamePath, "LUA") then
			text = file.Read(gamePath,"LUA")
		elseif GLib then
			text = GLib.Lua.BytecodeReader(_func):ToString()
		else
			ply:ChatPrint("You need GLib to decompile this function, get it here : https://github.com/notcake/glib")
			return
		end
	else
		if not file.Exists(gamePath, "LUA") then
			ply:ChatPrint("Can't open the file, it was created with compilestring, please try to open a function of it, not the file itself.")
			return
		end

		text = file.Read(gamePath,"LUA")
	end


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

end)
