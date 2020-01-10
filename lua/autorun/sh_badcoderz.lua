BadCoderz = BadCoderz or {}

local metaplayer = FindMetaTable("Player")

function metaplayer:CanUseBadCoderz()
	return game.SinglePlayer() or self:IsSuperAdmin()
end


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
end

if SERVER then
	include("badcoderz/server/sv_network.lua")
end

include("badcoderz/sh_gmaparser.lua")
