-- Bug #3 : un gros rapport fait échouer WriteReport au lieu d'être découpé/tronqué.
-- Royaume : server (singleplayer : le joueur est autorisé par CanUseBadCoderz).

local function randomHex(n)
	local t = {}
	for i = 1, n do t[i] = string.format("%x", math.random(0, 15)) end
	return table.concat(t)
end

local snapshot

return {
	groupName = "BadCoderz : taille du rapport réseau",
	beforeAll = function()
		assert(game.SinglePlayer(), "test prévu pour le solo")
		math.randomseed(1234)
		snapshot = {}
		local reports = BadCoderz.getReport()
		for k, v in pairs(reports) do snapshot[k] = v end
		-- on fabrique un rapport « d'un gros serveur » : beaucoup de lignes distinctes
		for k in pairs(reports) do reports[k] = nil end
		local byLoc = {}
		for i = 1, 1500 do
			local loc = "addons/" .. randomHex(24) .. ".gma/lua/" .. randomHex(16) .. "/" .. randomHex(12) .. ".lua"
			byLoc[loc] = byLoc[loc] or {}
			local frames = {}
			for f = 1, 6 do frames[f] = { location = "lua/" .. randomHex(30) .. ".lua", line = math.random(1, 5000) } end
			byLoc[loc][math.random(1, 5000)] = { calls = math.random(1, 100000), lines = frames, funcs = {} }
		end
		-- l'entrée la plus appelée de loin : elle doit survivre à toute troncature
		byLoc["lua/tdd_top.lua"] = { [42] = { calls = 999999999, lines = { { location = "lua/tdd_top.lua", line = 42 } }, funcs = {} } }
		reports["ents.GetAll"] = { ["GM:Think"] = byLoc }
	end,
	afterAll = function()
		local reports = BadCoderz.getReport()
		for k in pairs(reports) do reports[k] = nil end
		for k, v in pairs(snapshot) do reports[k] = v end
	end,
	cases = {
		{
			name = "précondition : le rapport fabriqué dépasse bien 64000 octets compressés",
			func = function()
				local size = #util.Compress(util.TableToJSON(BadCoderz.getReport()))
				expect(size).to.beGreaterThan(64000)
			end,
		},
		{
			name = "#3 WriteReport sur un gros rapport ne lève pas d'erreur",
			func = function()
				local ply = player.GetAll()[1]
				expect(IsValid(ply)).to.beTrue()
				local ok, err = pcall(BadCoderz.WriteReport, ply)
				-- RED attendu : error("Report is too big :(")
				expect(ok and "" or tostring(err)).to.equal("")
			end,
		},
		{
			name = "#3 GetNetReport existe",
			func = function()
				expect(BadCoderz.GetNetReport).to.exist()
			end,
		},
		{
			name = "#3 GetNetReport : un gros rapport est tronqué sous la limite réseau et signalé comme tel",
			func = function()
				local data, truncated = BadCoderz.GetNetReport()
				expect(#data).to.beLessThan(64001)
				expect(truncated).to.beTrue()
			end,
		},
		{
			name = "#3 GetNetReport : la troncature garde les entrées les plus appelées",
			func = function()
				local data = BadCoderz.GetNetReport()
				local sent = util.JSONToTable(util.Decompress(data))
				local top = sent["ents.GetAll"]["GM:Think"]["lua/tdd_top.lua"]
				expect(top).to.exist()
				expect(top[42] or top["42"]).to.exist()
			end,
		},
		{
			name = "#3 GetNetReport : un petit rapport n'est ni modifié ni signalé comme tronqué",
			func = function()
				local reports = BadCoderz.getReport()
				for k in pairs(reports) do reports[k] = nil end
				reports["ents.GetAll"] = { ["GM:Think"] = { ["lua/a.lua"] = { [1] = { calls = 3, lines = { { location = "lua/a.lua", line = 1 } }, funcs = {} } } } }

				local data, truncated = BadCoderz.GetNetReport()
				expect(truncated).to.beFalse()
				local sent = util.JSONToTable(util.Decompress(data))
				local entry = sent["ents.GetAll"]["GM:Think"]["lua/a.lua"]
				expect((entry[1] or entry["1"]).calls).to.equal(3)
			end,
		},
	},
}
