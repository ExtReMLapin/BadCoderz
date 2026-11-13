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
	},
}
