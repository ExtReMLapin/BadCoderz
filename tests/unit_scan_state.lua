-- Bug #1 / #14 : le scan des code smells doit être un bon citoyen
-- (ne pas écraser le debug hook d'autrui, ne pas forcer l'état du JIT).
-- Royaume : server.  Lancer : tests_run path=<ce fichier> realm=server

local function snapshot(state)
	state.hookFn, state.hookMask, state.hookCount = debug.gethook()
	state.jitWas = jit.status()
end

local function restore(state)
	-- le scan peut avoir laissé un hook : on remet celui du lanceur de tests
	debug.sethook(state.hookFn, state.hookMask or "", state.hookCount or 0)
	if state.jitWas then jit.on() else jit.off() end
	BadCoderz.scanningCodeSmells = false
	hook.Remove("Think", "badCoderzTrapHook")
end

return {
	groupName = "BadCoderz : état global autour d'un scan",
	beforeEach = snapshot,
	afterEach = restore,
	cases = {
		{
			name = "#1 arrêter le scan restitue le debug hook qui était actif avant",
			func = function(state)
				local sentinel = function() end
				debug.sethook(sentinel, "c")
				expect(debug.gethook()).to.equal(sentinel) -- précondition

				BadCoderz.toggleCodeSmellsScan() -- start
				BadCoderz.toggleCodeSmellsScan() -- stop

				-- RED attendu : stop_scan fait debug.sethook(_hook, "") et le hook d'origine est perdu
				expect(debug.gethook()).to.equal(sentinel)
			end,
		},
		{
			name = "#1 démarrer le scan ne casse pas un scan « boot » déjà actif (drapeau et hook cohérents)",
			func = function(state)
				-- on simule l'état laissé par sh_compiled_functions.lua : hook posé + drapeau levé
				local sentinel = function() end
				debug.sethook(sentinel, "c")
				BadCoderz.scanningCompiledFuncs = true

				BadCoderz.toggleCodeSmellsScan()
				BadCoderz.toggleCodeSmellsScan()

				local stillHooked = debug.gethook() == sentinel
				local flagStillClaimsScan = BadCoderz.scanningCompiledFuncs
				BadCoderz.scanningCompiledFuncs = false
				-- RED attendu : le drapeau dit « scan en cours » alors que le hook a disparu
				expect(flagStillClaimsScan and not stillHooked).to.beFalse()
			end,
		},
		{
			name = "#14 arrêter le scan laisse le JIT dans l'état où il l'a trouvé (désactivé)",
			func = function(state)
				jit.off()
				expect(jit.status()).to.beFalse() -- précondition

				BadCoderz.toggleCodeSmellsScan()
				BadCoderz.toggleCodeSmellsScan()

				-- RED attendu : stop_scan appelle jit.on() sans condition
				expect(jit.status()).to.beFalse()
			end,
		},
	},
}
