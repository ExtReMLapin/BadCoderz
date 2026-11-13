-- Bug #6 : le scan « RunString au boot » (sh_compiled_functions.lua) retient toutes les fonctions
-- appelées dans une table forte (`ignored_funcs`), elles ne sont donc jamais collectées.
-- Royaume : server.
--
-- Le scan boot s'active au chargement du fichier si `badcoderz_scan_on_boot_sv.txt` existe dans DATA :
-- on simule un redémarrage en créant ce fichier puis en relançant l'include.

local FLAG = "badcoderz_scan_on_boot_sv.txt"

-- retrouve la table `ignored_funcs` (upvalue de call_wrapper, le hook posé par le fichier)
local function findIgnored()
	local hookFn = debug.gethook()
	if not hookFn then return nil end
	for i = 1, 20 do
		local name, value = debug.getupvalue(hookFn, i)
		if not name then break end
		if name == "ignored_funcs" then return value end
	end
end

return {
	groupName = "BadCoderz : scan boot (fonctions compilées)",
	beforeEach = function(state)
		state.hookFn, state.hookMask, state.hookCount = debug.gethook()
		state.compiled = BadCoderz.compiledFuncs
	end,
	afterEach = function(state)
		debug.sethook(state.hookFn, state.hookMask or "", state.hookCount or 0)
		BadCoderz.scanningCompiledFuncs = false
		file.Delete(FLAG)
		BadCoderz.compiledFuncs = state.compiled
	end,
	cases = {
		{
			name = "#6 une fonction appelée pendant le scan boot peut être collectée par le GC",
			func = function(state)
				file.Write(FLAG, "")
				include("badcoderz/sh_compiled_functions.lua") -- pose le hook et un ignored_funcs neuf
				local ignored = findIgnored()
				expect(ignored).to.exist() -- précondition : le hook du scan boot est bien actif

				local weak = setmetatable({}, { __mode = "v" })
				local f = function() return 1 end
				f() -- appelé sous le hook
				expect(ignored[f]).to.beTrue() -- précondition : le scan l'a bien enregistré
				weak[1] = f
				f = nil

				debug.sethook(state.hookFn, state.hookMask or "", state.hookCount or 0) -- on arrête de hooker avant le GC
				collectgarbage()
				collectgarbage()
				-- RED attendu : ignored_funcs[f] = true garde f en vie pour toujours
				expect(weak[1]).to.beNil()
			end,
		},
	},
}
