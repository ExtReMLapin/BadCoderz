-- Recharge à chaud le code de l'addon dans le royaume courant (server OU client), après une modification.
-- Évite de relancer le jeu entre deux cycles rouge/vert.  Lancer dans chaque royaume concerné.

for _, f in ipairs({ "sh_data", "sh_code_smells", "sh_compiled_functions", "sh_luajit_decompiler" }) do
	include("badcoderz/" .. f .. ".lua")
end

if SERVER then
	include("badcoderz/server/sv_network.lua")
else
	include("badcoderz/client/cl_utils.lua")
	include("badcoderz/client/cl_network.lua")
end

include("badcoderz/sh_gmaparser.lua")
-- la base GMA est reconstruite dans Initialize : on la relance à la main
local init = hook.GetTable().Initialize and hook.GetTable().Initialize.BadCoderzBuildDB
if init then init() end

return "rechargé (" .. (SERVER and "server" or "client") .. ")"
