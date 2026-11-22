-- Bugs #8 / #12 : BadCoderz.find_call_static_args (sh_luajit_decompiler.lua)
-- (la détection elle-même est testée dans unit_static_args_nofunck.lua)
-- Royaume : server.

local function compile(src, id)
	local f = CompileString(src, id)
	assert(isfunction(f), tostring(f))
	return f()
end

local function def() return BadCoderz.heavy_funcs_objects[Color] end

-- l'appel est à la ligne 2
local staticFn = compile("return function()\n local c = Color(255, 0, 0)\n return c\nend", "tdd_static")
local dynamicFn = compile("return function(r)\n local c = Color(r, 0, 0)\n return c\nend", "tdd_dynamic")

return {
	groupName = "BadCoderz : find_call_static_args (hygiène)",
	cases = {
		{
			name = "contrôle négatif : Color(r,0,0) dynamique n'est pas détecté",
			func = function()
				expect((BadCoderz.find_call_static_args(dynamicFn, def(), 2))).to.beFalse()
			end,
		},
		{
			name = "#12 l'analyse ne laisse pas de globale `n` dans _G",
			func = function()
				_G.n = nil
				BadCoderz.find_call_static_args(staticFn, def(), 2)
				local leaked = rawget(_G, "n")
				_G.n = nil
				-- RED attendu : disassemble_function fait `n = 0` sans local
				expect(leaked).to.beNil()
			end,
		},
		{
			name = "#8 deux analyses de la même fonction ne la désassemblent pas deux fois",
			func = function()
				local real = jit.util.funcbc
				local count = 0
				jit.util.funcbc = function(...) count = count + 1 return real(...) end
				local ok, err = pcall(function()
					BadCoderz.find_call_static_args(staticFn, def(), 2)
					count = 0 -- on ne compte que la 2e analyse
					BadCoderz.find_call_static_args(staticFn, def(), 2)
				end)
				jit.util.funcbc = real
				assert(ok, err)
				-- RED attendu : aucun cache, la 2e analyse relit tout le bytecode
				expect(count).to.equal(0)
			end,
		},
	},
}
