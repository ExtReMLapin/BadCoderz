BadCoderz.scanningCodeSmells = BadCoderz.scanningCodeSmells or false

BadCoderz.heavy_funcs = {
	[player.GetAll] = "player.GetAll",
	[ents.GetAll] = "ents.GetAll",
	[file.Append] = "file.Append",
	[file.CreateDir] = "file.CreateDir",
	[file.Delete] = "file.Delete",
	[file.Exists] = "file.Exists",
	[file.Find] = "file.Find",
	[file.IsDir] = "file.IsDir",
	[file.Open] = "file.Open",
	[file.Read] = "file.Read",
	[file.Rename] = "file.Rename",
	[file.Size] = "file.Size",
	[file.Time] = "file.Time",
	[file.Write] = "file.Write",
	[Color] = "Color"
	--[[
	candidates for "dumb fuckers" update :
	CompileString
	RunString
	RunStringEx
	ents.Create
	surface.CreateFont
	]]
}



BadCoderz.toolTips = {
	["player.GetAll"] = "This function is used to find all players, it depends of the implementation and what the dev is doing with it but there is good chances he's doing CPU Intensive things in this loop",
	["ents.GetAll"] = "This function is used to find all entities (A LOT), it depends of the implementation and what the dev is doing with it but there is good chances he's doing CPU Intensive things in this loop",
	["file.Append"] = "Working with files is always slow, doing it a lot is a TERRIBLE IDEA",
	["Color"] = "This functions creates a new Color object on each call, it takes ram, cpu time to be allocated in the memory and cpu time by the garbage collector, so the dev is supposed to cache it. Only the Color() calls with static values (not vars) are detected."
}

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


--pretty much the heavy hooks where you should not use IO/heavy funcs
BadCoderz.dangerous_hooks = {
	["Tick"] = true,
	["Think"] = true,
	["PlayerDeathThink"] = true,
	["PlayerPostThink"] = true,
	["PlayerTick"] = true,
	["HUDAmmoPickedUp"] = true,
	["HUDItemPickedUp"] = true,
	["HUDPaint"] = true,
	["HUDPaintBackground"] = true,
	["Paint"] = true,
	["HUDWeaponPickedUp"] = true,
	["DrawDeathNotice"] = true,
	["DrawMonitors"] = true,
	["DrawOverlay"] = true,
	["DrawPhysgunBeam"] = true,
	["HUDDrawPickupHistory"] = true,
	["HUDDrawScoreBoard"] = true,
	["HUDDrawTargetID"] = true,
	["PostDraw2DSkyBox"] = true,
	["PostDrawEffects"] = true,
	["PostDrawHUD"] = true,
	["PostDrawOpaqueRenderables"] = true,
	["PostDrawPlayerHands"] = true,
	["PostDrawSkyBox"] = true,
	["PostDrawTranslucentRenderables"] = true,
	["PostPlayerDraw"] = true,
	["PreDrawEffects"] = true,
	["PreDrawHalos"] = true,
	["PreDrawHUD"] = true,
	["PreDrawOpaqueRenderables"] = true,
	["PreDrawPlayerHands"] = true,
	["PreDrawSkyBox"] = true,
	["PreDrawTranslucentRenderables"] = true,
	["PreDrawViewModel"] = true,
	["PrePlayerDraw"] = true,
	["PostDraw2DSkyBox"] = true,
	["PostDrawEffects"] = true,
	["PostDrawHUD"] = true,
	["PostDrawOpaqueRenderables"] = true,
	["PostDrawPlayerHands"] = true,
	["PostDrawSkyBox"] = true,
	["PostDrawTranslucentRenderables"] = true,
	["PreRender"] = true,
	["PreDrawEffects"] = true,
	["PreDrawHUD"] = true,
	["PreDrawHalos"] = true,
	["PreDrawOpaqueRenderables"] = true,
	["PreDrawPlayerHands"] = true,
	["PreDrawSkyBox"] = true,
	["PreDrawTranslucentRenderables"] = true,
	["PostPlayerDraw"] = true,
	["Move"] = true,
	["VehicleMove"] = true,
	["Draw"] = true,
	["DrawTranslucent"] = true,
	["CalcAbsolutePosition"] = true,
	["CalcMainActivity"] = true,
	["CalcVehicleView"] = true,
	["CalcView"] = true,
	["CalcViewModelView"] = true,
	["DrawWeaponSelection"] = true,
	["DrawWorldModel"] = true,
	["DrawWorldModelTranslucent"] = true,
	["ViewModelDrawn"] = true
}
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

	BadCoderz.settings = {
		auto_close_menu = CreateClientConVar("badcoderz_autoclosemenu", "0", true, false, "Auto close BadCoderz menu after starting a scan"),
		auto_reopen_menu = CreateClientConVar("badcoderz_autoreopenmenu", "1", true, false, "Auto re-open BadCoderz menu after it was auto-closed"),
		auto_reopen_menu_time = CreateClientConVar("badcoderz_autoreopenmenu_time", "15", true, false, "After how many seconds the menu should reopen")
	}
end

-- clientside functions
BadCoderz.potentialsHooksFiles = {}
BadCoderz.potentialsHooksFiles["lua/includes/modules/hook.lua"] = true