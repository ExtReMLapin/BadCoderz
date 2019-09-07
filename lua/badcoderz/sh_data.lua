
BadCoderz.test_running = BadCoderz.test_running or false


BadCoderz.heavy_funcs = {}
BadCoderz.heavy_funcs[player.GetAll] = "player.GetAll"
BadCoderz.heavy_funcs[ents.GetAll] = "ents.GetAll"
BadCoderz.heavy_funcs[file.Append] = "file.Append"
BadCoderz.heavy_funcs[file.CreateDir] = "file.CreateDir"
BadCoderz.heavy_funcs[file.Delete] = "file.Delete"
BadCoderz.heavy_funcs[file.Exists] = "file.Exists"
BadCoderz.heavy_funcs[file.Find] = "file.Find"
BadCoderz.heavy_funcs[file.IsDir] = "file.IsDir"
BadCoderz.heavy_funcs[file.Open] = "file.Open"
BadCoderz.heavy_funcs[file.Read] = "file.Read"
BadCoderz.heavy_funcs[file.Rename] = "file.Rename"
BadCoderz.heavy_funcs[file.Size] = "file.Size"
BadCoderz.heavy_funcs[file.Time] = "file.Time"
BadCoderz.heavy_funcs[file.Write] = "file.Write"
BadCoderz.heavy_funcs[Color] = "Color"


BadCoderz.toolTips = {}
BadCoderz.toolTips["player.GetAll"] = "This function is used to find all players, it depends of the implementation and what the dev is doing with it but there is good chances he's doing CPU Intensive things in this loop"
BadCoderz.toolTips["ents.GetAll"] = "This function is used to find all entities (A LOT), it depends of the implementation and what the dev is doing with it but there is good chances he's doing CPU Intensive things in this loop"
BadCoderz.toolTips["file.Append"] = "Working with files is always slow, doing it a lot is a TERRIBLE IDEA"
BadCoderz.toolTips["file.CreateDir"] = BadCoderz.toolTips["file.Append"]
BadCoderz.toolTips["file.Delete"] = BadCoderz.toolTips["file.Append"]
BadCoderz.toolTips["file.Exists"] = BadCoderz.toolTips["file.Append"]
BadCoderz.toolTips["file.Find"] = BadCoderz.toolTips["file.Append"]
BadCoderz.toolTips["file.IsDir"] = BadCoderz.toolTips["file.Append"]
BadCoderz.toolTips["file.Open"] = BadCoderz.toolTips["file.Append"]
BadCoderz.toolTips["file.Read"] = BadCoderz.toolTips["file.Append"]
BadCoderz.toolTips["file.Rename"] = BadCoderz.toolTips["file.Append"]
BadCoderz.toolTips["file.Size"] = BadCoderz.toolTips["file.Append"]
BadCoderz.toolTips["file.Time"] = BadCoderz.toolTips["file.Append"]
BadCoderz.toolTips["file.Write"] = BadCoderz.toolTips["file.Append"]
BadCoderz.toolTips["Color"] = "This functions creates a new Color object on each call, it takes ram, cpu time to be allocated in the memory and cpu time by the garbage collector, so the dev is supposed to cache it. Only the Color() calls with static values (not vars) are detected."

BadCoderz.dangerous_hooks = BadCoderz.dangerous_hooks or {}

if CLIENT then

	BadCoderz.toolTips["player.GetAll"] = "This function is used to find all players, it depends of the implementation and what the dev is doing with it but there is good chances he's doing CPU Intensive things in this loop"

	BadCoderz.heavy_funcs[surface.CreateFont] = "surface.CreateFont"
	BadCoderz.heavy_funcs[surface.GetTextureID] = "surface.GetTextureID"
	BadCoderz.heavy_funcs[surface.CreateFont] = "surface.CreateFont"
	BadCoderz.heavy_funcs[Material] = "Material"
	BadCoderz.heavy_funcs[vgui.Create] = "vgui.Create"


	BadCoderz.toolTips["surface.CreateFont"] = "Creating a font on each frame is destroying performance, there is only one specific case where it's needed, when you want to smooth for size change in real time, but it's still eating too much CPU Time"
	BadCoderz.toolTips["surface.GetTextureID"] = "Common mistake, reading textures from the disk on each frame instead of caching it outside of the rendering function."
	BadCoderz.toolTips["Material"] = BadCoderz.toolTips["surface.GetTextureID"]
	BadCoderz.toolTips["vgui.Create"] = "Common mistake (especially for avatars), created Derma on user interaction, and only on user interaction."

	BadCoderz.settings = {}
	BadCoderz.settings.auto_close_menu = CreateClientConVar("badcoderz_autoclosemenu", "0", true, false, "Auto close BadCoderz menu after starting a scan")
	BadCoderz.settings.auto_reopen_menu = CreateClientConVar("badcoderz_autoreopenmenu", "1", true, false, "Auto re-open BadCoderz menu after it was auto-closed")
	BadCoderz.settings.auto_reopen_menu_time = CreateClientConVar("badcoderz_autoreopenmenu_time", "15", true, false, "After how many seconds the menu should reopen")

end -- clientside functions


BadCoderz.potentialsHooksFiles = {}
BadCoderz.potentialsHooksFiles["lua/includes/modules/hook.lua"] = true

