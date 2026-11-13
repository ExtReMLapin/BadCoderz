-- Assertions sur les résultats du scénario e2e/run_scan.lua (globale TDD). Royaume : server.
-- Prérequis : avoir lancé run_scan.lua et attendu TDD.done == true.

local function find(func, locPattern)
	local found = {}
	for _, e in ipairs(TDD.entries) do
		if e.func == func and e.loc:find(locPattern, 1, true) then found[#found + 1] = e end
	end
	return found
end

local function lineOf(e) return tonumber(e.line) end

local probe = function() local c = Color(1, 2, 3) return c end
local funckWorks = select("#", jit.util.funck(probe, -1)) > 0

return {
	groupName = "BadCoderz : scan e2e (vrais ticks de Think)",
	beforeAll = function()
		assert(TDD and TDD.done, "lancer d'abord e2e/run_scan.lua puis attendre TDD.done")
	end,
	cases = {
		{
			name = "contrôle : un ents.GetAll direct dans Think est rapporté sous GM:Think",
			func = function()
				local hits = find("ents.GetAll", "tdd_fake_gma/hot.lua")
				local direct
				for _, e in ipairs(hits) do if lineOf(e) == 3 then direct = e end end
				expect(direct).to.exist()
				expect(direct.hook).to.equal("GM:Think")
				expect(direct.calls).to.beGreaterThan(10)
			end,
		},
		{
			name = "#2 un ents.GetAll lancé depuis une coroutine appelée par Think est rapporté",
			func = function()
				local inCo
				for _, e in ipairs(find("ents.GetAll", "tdd_fake_gma/hot.lua")) do
					if lineOf(e) == 5 then inCo = e end
				end
				-- RED attendu : debug.sethook est par thread, la coroutine n'est pas hookée
				expect(inCo).to.exist()
			end,
		},
		{
			name = "#7 fixGMAPath ne reparcourt pas toute la base GMA à chaque appel rapporté",
			func = function()
				-- avec un cache par chemin : au plus un parcours (N_ADDONS appels) par chemin distinct
				-- RED attendu : N_ADDONS appels de table.HasValue par frame de pile et par appel rapporté
				expect(TDD.hasValueCalls).to.beLessThan(TDD.nAddons * 4)
			end,
		},
		{
			name = "#12 _hook ne laisse pas de globale `traceTable` dans _G",
			func = function()
				expect(TDD.traceTableLeaked).to.beFalse()
			end,
		},
		{
			name = "#17 un `local c = Color(255,0,0)` statique dans Think est rapporté sous GM:Think",
			func = function()
				local static
				for _, e in ipairs(find("Color", "tdd_fake_gma/hot.lua")) do
					if lineOf(e) == 11 then static = e end
				end
				-- RED attendu : jit.util.funck est désactivé, la détection ne trouve rien
				expect(static).to.exist()
				expect(static.hook).to.equal("GM:Think")
				expect(static.calls).to.beGreaterThan(10)
			end,
		},
		{
			name = "faux positif : un Color(r,0,0) DYNAMIQUE n'est pas rapporté à cause d'un Color statique non exécuté sur la même ligne",
			-- garde-fou : vert aujourd'hui (rien n'est détecté). Limite connue : sans le pc de la frame, une détection
			-- par ligne ne peut pas distinguer les deux appels ; ce test devrait alors rougir et motiver une solution.
			func = function()
				local dyn
				for _, e in ipairs(find("Color", "tdd_fake_gma/hot.lua")) do
					if lineOf(e) == 7 then dyn = e end
				end
				expect(dyn).to.beNil()
			end,
		},
		{
			name = "exploratoire : un `return Color(255,0,0)` (tail call) dans Think est rapporté",
			-- en tail call la frame appelante disparaît : le hook voit le wrapper, pas la fonction qui contient l'appel
			func = function()
				local tail
				for _, e in ipairs(find("Color", "tdd_fake_gma/hot.lua")) do
					if lineOf(e) == 9 then tail = e end
				end
				expect(tail).to.exist()
			end,
		},
	},
}
