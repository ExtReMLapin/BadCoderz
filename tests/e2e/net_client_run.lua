-- Envoie au serveur, avec le MÊME format de message que cl_utils.lua, les requêtes de BadCoderz
-- et capture ce que le client reçoit en retour.  Royaume : client.
-- Prérequis : e2e/net_server_setup.lua exécuté côté serveur.  Attendre NETC.done.

NETC = { done = false, opened = {} }

local realOpen = BadCoderz.openLuaPad
BadCoderz.openLuaPad = function(data, path, line)
	NETC.opened[#NETC.opened + 1] = { data = data, path = path, line = line, len = #data }
end

local steps = {
	-- A : cl_utils.lua:212-217, ligne 9000 (fichier de plus de 8191 lignes)
	function()
		net.Start("BadCoderz_serverside_file_open")
		net.WriteString("badcoderz/sh_data.lua")
		net.WriteString("lua/badcoderz/sh_data.lua")
		net.WriteBool(true)
		net.WriteUInt(9000, 13)
		net.WriteBool(true) -- client
		net.SendToServer()
	end,
	-- B : cl_utils.lua:162-165, ouverture d'un gros fichier (120 Ko, ~87 Ko compressé)
	function()
		net.Start("BadCoderz_serverside_file_open")
		net.WriteString("tdd_fixtures/big_random.lua")
		net.WriteString("lua/tdd_fixtures/big_random.lua")
		net.WriteBool(false)
		net.SendToServer()
	end,
	-- C : cl_utils.lua:212-223 côté serveur, avec une entrée de rapport qui n'existe plus
	function()
		net.Start("BadCoderz_serverside_file_open")
		net.WriteString("badcoderz/sh_data.lua")
		net.WriteString("lua/badcoderz/sh_data.lua")
		net.WriteBool(true)
		net.WriteUInt(10, 13)
		net.WriteBool(false) -- client = false -> lecture du rapport serveur
		net.WriteString("ents.GetAll")
		net.WriteString("GM:Think")
		net.WriteString("lua/inexistant.lua")
		net.WriteUInt(1, 13)
		net.WriteUInt(1, 8)
		net.SendToServer()
	end,
	-- D : cl_utils.lua:285-286, décompilation d'une fonction compilée
	function()
		net.Start("BadCoderz_serverside_bytecode_reader")
		net.WriteUInt(1, 16)
		net.SendToServer()
	end,
}

local i = 0
local function nextStep()
	i = i + 1
	if i > #steps then
		BadCoderz.openLuaPad = realOpen
		NETC.done = true
		return
	end
	steps[i]()
	timer.Simple(0.7, nextStep)
end
nextStep()
return "envoi en cours"
