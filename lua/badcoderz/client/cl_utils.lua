local function openWikipage(func_name)
	func_name = string.Replace(func_name,".","/")
	func_name = string.Replace(func_name,":","/")
	gui.OpenURL("https://wiki.garrysmod.com/page/" .. func_name)
	--input.SetCursorPos(ScrW()/2+239, ScrH()/2+34) -- hackerman
end


local disclamer = [[
	This report is meant to be understood by devs.
	Check the call stack, because the real location of the function is in it.
	Of course, if you know a bit about lua, you should be able to spot the addons with A LOT of code smell/bad things.
]]
local preloaded_data = file.Read("garrysmod/lua/send.txt", "BASE_PATH")


local wiki_base = "https://wiki.garrysmod.com/page/"
function BadCoderz.reportToText(dataTbl)

	if table.IsEmpty(dataTbl) then
		return "report was empty :("
	end

	local str = disclamer
	for functionsNames, hookTable in pairs(dataTbl) do
		local function_internet_name = string.Replace(functionsNames,".","/")
		if not string.find(function_internet_name, '/',1,  true) then
			function_internet_name = "Global/" .. function_internet_name
		end
		str = str .. "\nFunction : " .. functionsNames .. " (Wiki page : " .. wiki_base .. function_internet_name .. " )\n"
		for hookName, callsLocations in pairs(hookTable) do
			local hook_internet_name = string.Replace(hookName,":","/")
			str = str .. "	Hook : " .. hookName .. " (Wiki page : " .. wiki_base .. hook_internet_name .. " )\n"
			for filename, LinesTable in pairs(callsLocations) do
				local warning;
				if string.find(preloaded_data, string.Replace(filename, "/", "\\"), 1, false) then
					warning = "   /!\\(Probably wrong, check the stack call history bellow)/!\\"
				else
					warning = ""
				end

				str = str .. "		File  : " .. filename .. warning .. "\n"
				for callLines, calls in pairs(LinesTable) do
					local info;
					if calls.calls == 1 then
						info = " /!\\(Only one call, probably used for caching)/!\\"
					else
						info = ""
					end
					str = str .. "			└►Line #" .. callLines .. "-> " .. calls.calls  .. " calls" .. info .. "\n"
					str = str .. "				Call History\n"
					for k, location in pairs(calls.lines) do
						str = str .. "				#" .. k .. " File:" .. location.location .. ", Line #" .. location.line .. "\n"
					end
				end
			end
		end
	end
	return str
end


local function getDescFromWikiBody(body)

	local tofind = ">Description</span></h1>"

	if not string.find(body, tofind) then
		return ""
	end
	local found = string.find(body, tofind) + string.len(tofind) + 4
	local enddesc = string.find(body, ".", found, true)
	local tip = string.sub(body, found, enddesc)
	tip = string.gsub(tip, "<.->", "")


	return tip
end



local function absolutePathToLuaPath(path)
	if string.StartWith(path, "lua/") then
		return path:sub(5, path:len())
	end
	if string.StartWith(path, "gamemodes/") then
		return path:sub(11, path:len())
	end

	local luaPos = string.find(path, "/lua/", 1, false)
	if not luaPos then return path end
	return string.sub(path, luaPos + 5, path:len())
end


function BadCoderz.populateTreeWithData(treePanel, dataTbl, client)

	for functionsNames, hookTable in pairs(dataTbl) do
			local nodeFunctionName = treePanel:AddNode( functionsNames , "icon16/sitemap.png")
			local function_internet_name = string.Replace(functionsNames,".","/")
			if not string.find(function_internet_name, '/',1,  true) then
				function_internet_name = "Global/" .. function_internet_name
			end

			nodeFunctionName:SetExpanded(true, true)
			local fName = nodeFunctionName:GetText()
			nodeFunctionName.DoRightClick = function(pnl)
				openWikipage(fName)
			end
			if BadCoderz.toolTips[fName] then
				nodeFunctionName:SetTooltip(BadCoderz.toolTips[fName])
			end
			http.Fetch("https://wiki.garrysmod.com/page/" .. function_internet_name,function(body)
				if nodeFunctionName and IsValid(nodeFunctionName) then
					local tip = getDescFromWikiBody(body)
					if BadCoderz.toolTips[fName] then
						tip = tip .. "\n" .. BadCoderz.toolTips[fName]
					end

					nodeFunctionName:SetTooltip(tip)
				end
			end)

			for hookName, callsLocations in pairs(hookTable) do
				local nodeHookName = nodeFunctionName:AddNode( hookName , "icon16/wrench.png")
				local hook_internet_name = string.Replace(hookName,":","/")
				nodeHookName:SetTooltip("Loading ...")
				http.Fetch("https://wiki.garrysmod.com/page/" .. hook_internet_name,function(body)
					if nodeHookName and IsValid(nodeHookName) then
						nodeHookName:SetTooltip(getDescFromWikiBody(body))
					end
				end)

				nodeHookName:SetExpanded(true, true)
				nodeHookName:SetDoubleClickToOpen(false)
				nodeHookName.DoRightClick = function(pnl)
					local fName = pnl:GetText()
					openWikipage(fName)
				end

				for filename, LinesTable in pairs(callsLocations) do
					local fileIcon;
					if string.find(preloaded_data, string.Replace(filename, "/", "\\"), 1, false) then
						fileIcon = "icon16/application_error.png"
					else
						fileIcon = "icon16/script_code.png"
					end

					local fixedName = filename
					local findGMA = string.find(filename, ".gma", 1 , true)
					if findGMA then
						fixedName = filename:sub(findGMA + 5, filename:len())
					end

					fixedName = absolutePathToLuaPath(fixedName)

					local nodeFileName = nodeHookName:AddNode( filename, fileIcon )

					nodeFileName:SetTooltip("Right click to open in Lua editor")
					nodeFileName.DoRightClick = function(pnl)
						net.Start("BadCoderz_serverside_file_open")
						net.WriteString(fixedName)
						net.WriteString(filename)
						net.WriteBool(false)
						net.SendToServer()
					end

					for callLines, calls in pairs(LinesTable) do
						local icon;
						if calls.calls > 1 then
							icon = "icon16/stop.png"
						else
							icon = "icon16/lightning_go.png"
						end

						local callLineNode = nodeFileName:AddNode( "└►Line #" .. callLines .. "-> " .. calls.calls .. " calls  | Expand to see call history", icon)
						callLineNode:SetTooltip("Click to expand the call history")
						for k, location in pairs(calls.lines) do


							local fixedName = location.location
							local findGMA = string.find(location.location, ".gma", 1 , true)
							if findGMA then
								fixedName = location.location:sub(findGMA+5, location.location:len())
							end
							fixedName = absolutePathToLuaPath(fixedName)

							local iconCallHistory;
							if k == #calls.lines then
								iconCallHistory = "icon16/stop.png"
							else
								iconCallHistory = "icon16/clock.png"
							end

							local _endNode = callLineNode:AddNode( "#" .. k .. " File:" .. location.location .. ", Line #" .. location.line, iconCallHistory)

							_endNode.DoRightClick = function(pnl)
								if client and not file.Exists(fixedName, "LUA") then
									if not GLib then
										LocalPlayer():ChatPrint("You need GLib to decompile this function, get it here : https://github.com/notcake/glib")
										return
									end
									local byteCode = GLib.Lua.BytecodeReader(calls.funcs[k]):ToString()
									BadCoderz.openLuaPad(byteCode, "DECOMPILED VIRTUAL FUNCTION : " .. location.location)
									return
								end
								net.Start("BadCoderz_serverside_file_open")
								net.WriteString(fixedName)
								net.WriteString(location.location)
								net.WriteBool(true)
								net.WriteUInt(location.line,13)
								net.WriteBool(client)
								if not client then
									net.WriteString(functionsNames)
									net.WriteString(hookName)
									net.WriteString(filename)
									net.WriteUInt(callLines, 13)
									net.WriteUInt(k, 8)
								end
								net.SendToServer()
							end
							_endNode:SetTooltip("Right click to open in Lua editor")
						end
					end
				end
			end
		end
end
