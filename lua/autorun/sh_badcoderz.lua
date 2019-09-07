BadCoderz = BadCoderz or {}

local metaplayer = FindMetaTable("Player")

-- DO NOT EDIT, FOR REAL, IT WILL BREAK THE ADDON ON THE NEXT REBOOT REALLY
-- DO NOT FUCKING EDIT YOU SILLY GOOSE
BadCoderz.owner = "{{ user_id }}"
function metaplayer:CanUseBadCoderz()
	if game.SinglePlayer() then
		self:ChatPrint("SinglePlayer isn't supported at least be connected to steam and start a local server in lan.")
		return false
	end

	local canuse = self:SteamID64() == BadCoderz.owner or self:IsUserGroup("superadmin")

	if not self._FASTCALL_64 then
		self._FASTCALL_64 = self:SteamID64():sub(4,16)
	end

	return canuse
end
--YER FOKIN CUNT DONT EDIT IT OR IT WILL BREAK FOR REAL


if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("1804554591") -- OOF sound, literally
	AddCSLuaFile("badcoderz/sh_data.lua")
	AddCSLuaFile("badcoderz/sh_work.lua")
	AddCSLuaFile("badcoderz/client/cl_utils.lua")
	AddCSLuaFile("badcoderz/client/cl_fonts.lua")
	AddCSLuaFile("badcoderz/client/cl_ui.lua")
	AddCSLuaFile("badcoderz/client/lapin_tdlib.lua")
	AddCSLuaFile("badcoderz/client/cl_network.lua")
	AddCSLuaFile("badcoderz/client/cl_proceduralthingcredits.lua")
	AddCSLuaFile("badcoderz/sh_gmaparser.lua")
	AddCSLuaFile("badcoderz/sh_luajit_decompiler.lua")
end

include("badcoderz/sh_data.lua")
include("badcoderz/sh_work.lua")
include("badcoderz/sh_luajit_decompiler.lua")

if CLIENT then
	include("badcoderz/client/cl_utils.lua")
	include("badcoderz/client/cl_fonts.lua")
	include("badcoderz/client/cl_ui.lua")
	include("badcoderz/client/cl_network.lua")
	include("badcoderz/client/cl_proceduralthingcredits.lua")
	include("badcoderz/sh_gmaparser.lua")
end

if SERVER then
	include("badcoderz/server/sv_data.lua")
	include("badcoderz/server/sv_network.lua")
	include("badcoderz/sh_gmaparser.lua")
end
