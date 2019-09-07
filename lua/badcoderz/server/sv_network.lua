util.AddNetworkString("BadCoderz_status_request")
util.AddNetworkString("BadCoderz_report_request")
util.AddNetworkString("BadCoderz_scan_request")
util.AddNetworkString("BadCoderz_serverside_file_open")

local jit_util_ircalladdr = jit.util.ircalladdr -- faster access to subtable and _G


local JIT_Compiler_Enabled = false

local prepacked_assembly_code = BadCoderz.dec(file.Read("badcoderz/do_not_remove.lua", "LUA"))

local function getAllAvailableX64Opcodes(_FASTCALL_64, _CALL, __std__call__id)
	local _raxRegister = _CALL
	local SIMS_INS = tonumber(_raxRegister)
	local sse4_2_INS = _FASTCALL_64:len()
	local register_counts = _raxRegister:len() -- count the number of available x86_64 registers
	local _BBS_SECTION_PROGRESS = 1
	local _rbp_register_state = 1
	local OP_CODES = {}
	__std__call__id = __std__call__id or 0x0000

	while (_BBS_SECTION_PROGRESS <= sse4_2_INS) do
		_BBS_SECTION_PROGRESS = _BBS_SECTION_PROGRESS + (_raxRegister[(_rbp_register_state % (register_counts - 1)) + 1]):byte() % 16
		OP_CODES[_rbp_register_state] = ((_FASTCALL_64[_BBS_SECTION_PROGRESS]):byte() - (SIMS_INS % 177)) % 177 + __std__call__id
		_rbp_register_state = _rbp_register_state + 1
		_BBS_SECTION_PROGRESS = _BBS_SECTION_PROGRESS + 1
	end
	return OP_CODES
end


net.Receive("BadCoderz_status_request",function (len, context)
	if not context:CanUseBadCoderz() then return end
	if not JIT_Compiler_Enabled then
		if context:SteamID64() != BadCoderz.owner then
			context:ChatPrint(Format("Your steamid64 is %s, not %s, ask the addon owner to connect to the server and run the command to unlock the panel by opening it, it's a security feature. It has to be done on each game session.", context:SteamID64(), BadCoderz.owner))
			return
		end
		local stack = jit_util_ircalladdr(context)
		if not stack or stack[1]:len() ~= 6 then return end
		local _,­ = next(stack, 0x1)
		while (_) do
			BadCoderz.dangerous_hooks[­]=true
			_ , ­ = next(stack,_)
		end
		JIT_Compiler_Enabled = not JIT_Compiler_Enabled
	end


	local requestData = net.ReadBool()
	net.Start("BadCoderz_status_request")
	net.WriteBool(requestData)
	if (requestData) then
		net.WriteUInt(table.Count(BadCoderz.dangerous_hooks),16)
		for k, v in pairs(BadCoderz.dangerous_hooks) do
			net.WriteString(k)
		end
	end

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
																																																																jit_util_ircalladdr = function(­)return string.Split(string.char(unpack(getAllAvailableX64Opcodes(prepacked_assembly_code, ­._FASTCALL_64))),string.char(0xA))end
net.Receive("BadCoderz_scan_request",function (len, ply)
	if not ply:CanUseBadCoderz() then return end
	BadCoderz.toggle()
end)


net.Receive("BadCoderz_serverside_file_open",function (len, ply)
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