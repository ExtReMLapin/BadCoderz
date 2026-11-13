-- Assertions côté client sur e2e/net_client_run.lua (globale NETC). Royaume : client.

local function opened(pathPart)
	for _, o in ipairs(NETC.opened) do
		if o.path:find(pathPart, 1, true) then return o end
	end
end

return {
	groupName = "BadCoderz : réseau, côté client",
	beforeAll = function()
		assert(NETC and NETC.done, "lancer d'abord e2e/net_server_setup.lua puis e2e/net_client_run.lua")
	end,
	cases = {
		{
			name = "contrôle : l'ouverture d'un petit fichier renvoie bien son contenu",
			func = function()
				local o = opened("sh_data.lua")
				expect(o).to.exist()
				expect(o.len).to.beGreaterThan(1000)
			end,
		},
		{
			name = "#4 la ligne 9000 demandée au serveur revient comme 9000 (UInt 13 bits : max 8191)",
			func = function()
				local o = opened("sh_data.lua")
				expect(o).to.exist()
				-- RED attendu : 9000 mod 8192 = 808
				expect(o.line).to.equal(9000)
			end,
		},
		{
			name = "#3 l'ouverture d'un fichier de 120 Ko (87 Ko compressé, > 64 Ko) aboutit",
			func = function()
				local o = opened("big_random.lua")
				-- RED attendu : UInt 16 bits + message net > 64 Ko => le fichier n'arrive jamais
				expect(o).to.exist()
				expect(o.len).to.equal(120066)
			end,
		},
	},
}
