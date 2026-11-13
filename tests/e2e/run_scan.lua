-- Scénario e2e (royaume server) : lance un VRAI scan sur de vrais ticks de Think,
-- collecte les résultats dans la globale TDD, puis remet tout en l'état.
-- Les assertions sont dans tests/scan_e2e.lua (à lancer quand TDD.done == true).
--
--   lua_exec_file  D:\dev\BadCoderz\tests\e2e\run_scan.lua   realm=server
--   wait_for       TDD and TDD.done                           realm=server
--   tests_run      D:\dev\BadCoderz\tests\scan_e2e.lua        realm=server

if BadCoderz.scanningCodeSmells then BadCoderz.toggleCodeSmellsScan() end

TDD = { done = false, entries = {}, hasValueCalls = 0 }

local N_ADDONS, N_FILES = 150, 400
local SCAN_SECONDS = 2

-- fausse base de GMA : aucun ne contient notre fichier factice -> fixGMAPath parcourt tout
local oldDB = BadCoderz.GMA_DB
local db = {}
for a = 1, N_ADDONS do
	local files = {}
	for f = 1, N_FILES do files[f] = ("lua/other_addon_%d/file_%d.lua"):format(a, f) end
	db[("addons/fake_%d.gma"):format(a)] = files
end
BadCoderz.GMA_DB = db
TDD.nAddons = N_ADDONS

-- compteur de table.HasValue (appelé par fixGMAPath pour chaque frame de pile rapportée)
local realHasValue = table.HasValue
table.HasValue = function(t, v)
	TDD.hasValueCalls = TDD.hasValueCalls + 1
	return realHasValue(t, v)
end

-- code « chaud » dans un fichier qui n'existe pas sur disque (=> chemin résolu via la base GMA)
local hot = CompileString([[
return {
	-- 1) contrôle positif : appel lourd direct dans un hook Think
	direct = function() ents.GetAll() end,
	-- 2) même appel lourd, mais dans une coroutine lancée par le hook Think
	inCoroutine = function() coroutine.wrap(function() ents.GetAll() end)() end,
	-- 3) Color dynamique, avec un Color statique jamais exécuté sur la MÊME ligne
	dynamicColor = function(never, r) return never and Color(255, 0, 0) or Color(r, 0, 0) end,
	-- 4) Color statique en position de tail call
	tailColor = function() return Color(255, 0, 0) end,
	-- 5) Color statique classique, à recréer à chaque tick (le cas que l'addon doit attraper)
	staticColor = function() local c = Color(255, 0, 0) return c end,
}
]], "lua/tdd_fake_gma/hot.lua")()

hook.Add("Think", "tdd_direct", function() hot.direct() end)
hook.Add("Think", "tdd_coroutine", function() hot.inCoroutine() end)
hook.Add("Think", "tdd_dyncolor", function() hot.dynamicColor(false, math.random(0, 255)) end)
hook.Add("Think", "tdd_tailcolor", function() hot.tailColor() end)
hook.Add("Think", "tdd_staticcolor", function() hot.staticColor() end)

local jitWas = jit.status()
local hookFn, hookMask, hookCount

-- le scan doit démarrer HORS de lua_exec : le harnais repose son propre hook à la fin de l'appel
timer.Simple(0.1, function()
	hookFn, hookMask, hookCount = debug.gethook()
	BadCoderz.toggleCodeSmellsScan() -- start
	TDD.hookAfterStart = debug.gethook() ~= hookFn
end)

timer.Simple(0.1 + SCAN_SECONDS, function()
	BadCoderz.toggleCodeSmellsScan() -- stop
	-- hygiène du test : on remet le hook du harnais (c'est ce que stop_scan devrait faire lui-même)
	debug.sethook(hookFn, hookMask or "", hookCount or 0)

	for _, id in ipairs({ "tdd_direct", "tdd_coroutine", "tdd_dyncolor", "tdd_tailcolor", "tdd_staticcolor" }) do
		hook.Remove("Think", id)
	end
	table.HasValue = realHasValue
	BadCoderz.GMA_DB = oldDB
	if not jitWas then jit.off() end

	for func, hooks in pairs(BadCoderz.getReport()) do
		for hookName, locs in pairs(hooks) do
			for loc, lines in pairs(locs) do
				for line, info in pairs(lines) do
					TDD.entries[#TDD.entries + 1] = { func = func, hook = hookName, loc = loc, line = line, calls = info.calls }
				end
			end
		end
	end
	TDD.traceTableLeaked = rawget(_G, "traceTable") ~= nil
	TDD.done = true
end)

return "scan lancé pour " .. SCAN_SECONDS .. " s"
