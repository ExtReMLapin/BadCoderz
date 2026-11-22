-- Prépare le serveur pour les tests réseau : enveloppe les receivers de BadCoderz dans un pcall
-- (on observe les erreurs au lieu de les laisser se perdre dans la console).
-- Royaume : server.  À lancer AVANT e2e/net_client_run.lua.

NETTDD = NETTDD or {}
NETTDD.orig = NETTDD.orig or {}
NETTDD.wrappers = NETTDD.wrappers or {}
NETTDD.errors = {}
NETTDD.calls = {}
NETTDD.glib = GLib ~= nil

for _, name in ipairs({ "badcoderz_serverside_file_open", "badcoderz_serverside_bytecode_reader" }) do
	-- on enveloppe le receiver ACTUEL (il peut avoir été rechargé depuis), sauf si c'est déjà notre enveloppe
	if net.Receivers[name] ~= NETTDD.wrappers[name] then
		NETTDD.orig[name] = net.Receivers[name]
	end
	assert(NETTDD.orig[name], "receiver absent : " .. name)
	local wrapper = function(len, ply)
		NETTDD.calls[name] = (NETTDD.calls[name] or 0) + 1
		local ok, err = pcall(NETTDD.orig[name], len, ply)
		if not ok then NETTDD.errors[name] = tostring(err) end
	end
	NETTDD.wrappers[name] = wrapper
	net.Receivers[name] = wrapper
end

-- une fonction compilée factice pour le receiver bytecode_reader
NETTDD.oldCompiled = BadCoderz.compiledFuncs
BadCoderz.compiledFuncs = { { func = function() end, pointer = "0xtdd", stack = "stack", location = "lua/tdd.lua", level = 0, time = 0 } }

NETTDD.files = {
	small = file.Exists("badcoderz/sh_data.lua", "LUA"),
	big = file.Exists("tdd_fixtures/big_random.lua", "LUA"),
}
return NETTDD.files
