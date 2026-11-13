-- #17 : jit.util.funck / funcuvname sont désactivés par Facepunch ("disabled due to security concerns",
-- https://wiki.facepunch.com/gmod/jit.util.funck) et ne renvoient plus rien. find_call_static_args, qui
-- en dépend pour retrouver le NOM de la fonction appelée, ne détecte donc plus aucun Color/Vector/Angle.
--
-- Contrat attendu : retrouver les appels à arguments statiques SANS lire de constantes ni de noms
-- (l'appelé est déjà connu du hook ; seul compte ce qui précède l'instruction CALL).
--
-- API testée : BadCoderz.find_call_static_args(fn, definition, ligne) -> true/false
-- Royaume : server.

local function compile(src, id)
	local f = CompileString(src, id)
	assert(isfunction(f), tostring(f))
	return f()
end

-- tous les appels testés sont sur la ligne 2, sauf mention contraire
local function fn(body, params)
	return compile("return function(" .. (params or "") .. ")\n" .. body .. "\nend", "tdd_nofunck")
end

local function detected(f, ctor, line)
	local definition = BadCoderz.heavy_funcs_objects[ctor]
	assert(definition, "pas de définition pour ce constructeur")
	return (BadCoderz.find_call_static_args(f, definition, line or 2)) == true
end

return {
	groupName = "BadCoderz : détection d'arguments statiques sans jit.util.funck",
	cases = {
		-- ----- doivent être détectés (RED attendu aujourd'hui) -----
		{
			name = "Color(255,0,0) statique est détecté",
			func = function() expect(detected(fn(" local c = Color(255, 0, 0) return c"), Color)).to.beTrue() end,
		},
		{
			name = "Color(255,255,255,255) à 4 arguments statiques est détecté",
			func = function() expect(detected(fn(" local c = Color(255, 255, 255, 255) return c"), Color)).to.beTrue() end,
		},
		{
			name = "Vector(0,0,0) statique est détecté",
			func = function() expect(detected(fn(" local v = Vector(0, 0, 0) return v"), Vector)).to.beTrue() end,
		},
		{
			name = "Vector(1.5, 2.5, 3.5) (constantes KNUM) est détecté",
			func = function() expect(detected(fn(" local v = Vector(1.5, 2.5, 3.5) return v"), Vector)).to.beTrue() end,
		},
		{
			name = "Angle(0,90,0) statique est détecté",
			func = function() expect(detected(fn(" local a = Angle(0, 90, 0) return a"), Angle)).to.beTrue() end,
		},
		{
			name = "Color(255,0,0) passé en argument (print(Color(...))) est détecté",
			func = function() expect(detected(fn(" print(Color(255, 0, 0))"), Color)).to.beTrue() end,
		},
		{
			name = "`return Color(255,0,0)` (tail call) est détecté",
			func = function() expect(detected(fn(" return Color(255, 0, 0)"), Color)).to.beTrue() end,
		},
		{
			name = "seule la ligne demandée compte : Color statique ligne 3, ligne 2 dynamique -> demande ligne 3 détectée",
			func = function()
				local f = fn(" local a = Color(r, 0, 0)\n local b = Color(255, 0, 0)\n return a, b", "r")
				expect(detected(f, Color, 3)).to.beTrue()
			end,
		},

		-- ----- ne doivent PAS être détectés (garde-fous : passent aujourd'hui, doivent rester verts) -----
		{
			name = "Color(r,0,0) dynamique n'est pas détecté",
			func = function() expect(detected(fn(" local c = Color(r, 0, 0) return c", "r"), Color)).to.beFalse() end,
		},
		{
			name = "Color(255, g, 0) partiellement dynamique n'est pas détecté",
			func = function() expect(detected(fn(" local c = Color(255, g, 0) return c", "g"), Color)).to.beFalse() end,
		},
		{
			name = "Vector(x, y, z) dynamique n'est pas détecté",
			func = function() expect(detected(fn(" local v = Vector(x, y, z) return v", "x, y, z"), Vector)).to.beFalse() end,
		},
		{
			name = "seule la ligne demandée compte : Color statique ligne 3 mais appel dynamique ligne 2 -> non détecté",
			func = function()
				local f = fn(" local a = Color(r, 0, 0)\n local b = Color(255, 0, 0)\n return a, b", "r")
				expect(detected(f, Color, 2)).to.beFalse()
			end,
		},
		{
			name = "aucun appel Color dans la fonction -> non détecté, sans erreur",
			func = function() expect(detected(fn(" local x = 1 + 1 return x"), Color)).to.beFalse() end,
		},
	},
}
