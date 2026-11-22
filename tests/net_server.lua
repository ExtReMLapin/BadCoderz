-- Assertions côté serveur sur e2e/net_server_setup.lua + net_client_run.lua (globale NETTDD).
-- Royaume : server.

return {
	groupName = "BadCoderz : réseau, côté serveur",
	beforeAll = function()
		assert(NETTDD and (NETTDD.calls.badcoderz_serverside_bytecode_reader or 0) > 0,
			"lancer d'abord les scripts e2e/net_*.lua (et attendre NETC.done côté client)")
	end,
	afterAll = function()
		-- on remet tout en l'état
		for name, f in pairs(NETTDD.orig) do net.Receivers[name] = f end
		if NETTDD.oldCompiled then BadCoderz.compiledFuncs = NETTDD.oldCompiled end
	end,
	cases = {
		{
			name = "#5 une requête file_open qui vise une entrée de rapport inexistante est rejetée sans erreur Lua",
			func = function()
				-- RED attendu : « attempt to index a nil value » (getReport()[func][hook]... sans validation)
				expect(NETTDD.errors.badcoderz_serverside_file_open or "").to.equal("")
			end,
		},
		{
			name = "#5 une requête bytecode_reader sans GLib est rejetée sans erreur Lua",
			when = not GLib, -- si GLib est installé, le scénario n'a pas de sens
			func = function()
				-- RED attendu : « attempt to index global 'GLib' »
				expect(NETTDD.errors.badcoderz_serverside_bytecode_reader or "").to.equal("")
			end,
		},
	},
}
