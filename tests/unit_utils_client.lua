-- Bug #13 : `file.Read("garrysmod/lua/send.txt", "BASE_PATH")` peut valoir nil, et string.find(nil, …)
-- plante BadCoderz.reportToText.  Royaume : client.

return {
	groupName = "BadCoderz : cl_utils",
	cases = {
		{
			name = "#13 reportToText ne plante pas quand send.txt est absent",
			func = function()
				-- on force le contexte « fichier absent » en rechargeant cl_utils avec file.Read qui renvoie nil
				local realRead = file.Read
				file.Read = function(path, ...)
					if path == "garrysmod/lua/send.txt" then return nil end
					return realRead(path, ...)
				end
				local okLoad, errLoad = pcall(include, "badcoderz/client/cl_utils.lua")
				file.Read = realRead
				assert(okLoad, errLoad)

				local report = { ["ents.GetAll"] = { ["GM:Think"] = { ["lua/x.lua"] = {
					[1] = { calls = 2, lines = { { location = "lua/x.lua", line = 1 } }, funcs = {} },
				} } } }
				local ok, err = pcall(BadCoderz.reportToText, report)
				-- RED attendu : bad argument #1 to 'find' (string expected, got nil)
				expect(ok and "" or tostring(err)).to.equal("")
			end,
			afterEach = nil,
		},
	},
	afterAll = function()
		include("badcoderz/client/cl_utils.lua") -- remet l'état normal
	end,
}
