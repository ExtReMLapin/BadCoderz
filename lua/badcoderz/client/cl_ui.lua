local DermaBadCoderz;

local TDLib = include("badcoderz/client/lapin_tdlib.lua")

local LastCSReport = {}
local LastSSReport = {}


local color_light_grey =  Color(0, 0, 0, 20)
local color_button_fade =  Color(0, 0, 0, 100)
local color_black = Color(0, 0, 0)
local color_light_red = Color(255, 100, 100)
local color_dark_green = Color(0,200,0)
local color_dark_red = Color(200,0,0)
local color_CS = Color(255,136,0)
local color_SS = Color(0,136,255)
local color_green = Color(65, 200, 0, 255)
local color_red = Color(225, 0, 0)


function BadCoderz.openLuaPad(luaCode, path, line)
	local EditorFrame = TDLib( "DFrame" )
	EditorFrame:SetSize( ScrW() * 0.75, ScrH() * 0.75 )
	EditorFrame:SetTitle( "" )
	EditorFrame:Center()
	EditorFrame:MakePopup()


	EditorFrame:ClearPaint():Background(color_white):Outline(color_black):Text("MetaStruct's WEB Lua editor @" .. path, "BadCoderzFont1", color_black, TEXT_ALIGN_LEFT, 10, -EditorFrame:GetTall() / 2 + 15, true)


	EditorFrame:ShowCloseButton(false)
	EditorFrame.btnMaxim.Paint = function() end
	EditorFrame.btnMinim.Paint = function() end

	local buttonClose = TDLib("DButton", EditorFrame)
	buttonClose:SetText("")
	buttonClose:SetSize(60, 20)
	buttonClose:SetPos(EditorFrame:GetWide() - buttonClose:GetWide() - 1, 1)
	buttonClose:ClearPaint():Background(color_white):FadeHover(color_light_red, 15):Text("×", "BadCoderzFont1", color_black)

	buttonClose.DoClick = function(pnl)
		pnl:GetParent():Close()
	end

	local html = vgui.Create( "DHTML", EditorFrame )
	html:Dock( FILL )
	html:OpenURL( "http://metastruct.github.io/lua_editor/" )
	html:Call("SetContent(\"" .. string.JavascriptSafe(luaCode) .. "\");")
	if (line) then
		html:Call(" GotoLine(\"" .. tostring(line) .. "\");")
	end

end



--ghetto ui m8

function BadCoderz.ShowUI(ongoingServerScan)
	if BadCoderz.Derma and IsValid(BadCoderz.Derma) then
		BadCoderz.Derma:Close()
	end

	DermaBadCoderz = TDLib("DFrame")
	BadCoderz.Derma = DermaBadCoderz
	DermaBadCoderz.currentmode = 0
	DermaBadCoderz:SetPos(100, 100)
	DermaBadCoderz:SetSize(1366, 768)
	DermaBadCoderz:SetTitle("")
	DermaBadCoderz:SetDraggable(true)
	DermaBadCoderz:MakePopup()
	DermaBadCoderz:Center()
	local x = DermaBadCoderz:GetPos()
	--DermaBadCoderz:SetPos(x, 10)
	DermaBadCoderz:ShowCloseButton(false)
	DermaBadCoderz.btnMaxim.Paint = function() end
	DermaBadCoderz.btnMinim.Paint = function() end
	DermaBadCoderz:ClearPaint():Background(color_white):Outline(color_black):Text("BadCoderz control Panel", "BadCoderzFont1", color_black, TEXT_ALIGN_LEFT, 10, -DermaBadCoderz:GetTall() / 2 + 20, true)

	DermaBadCoderz.Wizz = function(pnl)
		notification.AddLegacy("No report to export!", NOTIFY_ERROR, 3)
		surface.PlaySound("badcoderz/oof.mp3")
		local start = CurTime()
		local x, y = BadCoderz.Derma:GetPos()

		hook.Add("Think", "badcoderzWizz", function()
			if start + 0.1 < CurTime() or not IsValid(BadCoderz.Derma) then
				hook.Remove("Think", "badcoderzWizz")

				return
			end

			BadCoderz.Derma:SetPos(x + math.random(-5, 5), y + math.random(-5, 5))
		end)
	end



	local buttonClose = TDLib("DButton", DermaBadCoderz)
	buttonClose:SetText("")
	buttonClose:SetSize(100, 40)
	buttonClose:SetPos(DermaBadCoderz:GetWide() - buttonClose:GetWide() - 1, 1)
	buttonClose:ClearPaint():Background(color_white):FadeHover(color_light_red, 15):Text("×", "Trebuchet48", color_black)


	local mainHolder = TDLib("DPanel", DermaBadCoderz)
	DermaBadCoderz.mainHolder = mainHolder
	local holderx, holdery = 200, 100
	local holderbordel = 20
	mainHolder:SetPos( holderx, holdery )
	mainHolder:SetSize( DermaBadCoderz:GetWide() - holderx-holderbordel, DermaBadCoderz:GetTall() - holdery-1 )


	--:CircleHover()
	buttonClose.DoClick = function(pnl)
		pnl:GetParent():Close()
	end

	local nbutton = 0
	local buttonh = 50
	local curcolor;

	local curcolor = color_CS
	local buttonClientside = TDLib("DButton", DermaBadCoderz)
	DermaBadCoderz.buttonClientside = buttonClientside
	buttonClientside:SetPos(1, holdery + nbutton * buttonh)
	buttonClientside:SetSize(DermaBadCoderz:GetWide() - mainHolder:GetWide() - holderbordel-1, buttonh)
	buttonClientside:SetText("")
	buttonClientside:ClearPaint()
	:Background(color_light_grey)
	:SideBlock(curcolor, 4, LEFT)
	:FillHover(curcolor)
	:Text("Client Realm", "BadCoderzFont2", color_black, TEXT_ALIGN_CENTER, 5):CircleClick(color_black)

	buttonClientside.DoClick = function(pnl)
		pnl.ClickX, pnl.ClickY = pnl:CursorPos()
		pnl.Rad = 0
		pnl.Alpha = color_black.a
		mainHolder:Clear()
		mainHolder:ClearPaint():Background(color_light_grey):SideBlock(curcolor, 6, LEFT)
		DermaBadCoderz.currentmode = nbutton
		local labelStatus = vgui.Create( "DLabel", mainHolder )
		labelStatus:SetPos( 40, 20 )
		labelStatus:SetSize( 300, 30 )
		labelStatus:SetText( "Scan status : " ..  (BadCoderz.test_running and "Active" or "Innactive"))
		labelStatus:SetColor(BadCoderz.test_running and color_dark_green  or color_dark_red)
		labelStatus:SetFont("BadCoderzFont2")

		local labelProtip = vgui.Create( "DLabel", mainHolder )
		labelProtip:SetPos( 720, 10 )
		labelProtip:SetSize( 400, 300 )
		labelProtip:SetText( "After starting the scan, if you want\nto catch as much 'code smells' as possible\nyou should close this menu and play the game.\nThe more you interract with other addons\nthe more 'code smells' the scanner will catch.")
		labelProtip:SetColor(color_black)
		labelProtip:SetFont("BadCoderzFontSmall")
		labelProtip:SetContentAlignment(8)

		local buttonStartPause = TDLib("DButton", mainHolder)
		buttonStartPause:SetPos(40, 70)
		buttonStartPause:SetSize(150,50)
		buttonStartPause:SetText("")


		if BadCoderz.test_running then
			buttonStartPause:ClearPaint():Background(color_red):FadeHover(color_button_fade, 15):Text("Pause", "BadCoderzFont2", color_white)
		else
			buttonStartPause:ClearPaint():Background(color_green):FadeHover(color_button_fade, 15):Text("Start", "BadCoderzFont2", color_white)
		end

		buttonStartPause.DoClick = function()
			if (BadCoderz.test_running) then
				LastCSReport = BadCoderz.getReport()
			else
				LastCSReport = {}
			end
			BadCoderz.toggle()
			local shouldclose = BadCoderz.settings.auto_close_menu:GetBool()
			local shouldreopen = BadCoderz.settings.auto_reopen_menu:GetBool()
			if (shouldclose and BadCoderz.test_running and shouldreopen) then -- test running == true because it was called right before
				local timer_reopen = BadCoderz.settings.auto_reopen_menu_time:GetInt()
				DermaBadCoderz:Close()
				timer.Simple(timer_reopen, function()
					if BadCoderz.Derma and IsValid(BadCoderz.Derma) then
						return
					end
					net.Start("BadCoderz_status_request")
					net.SendToServer()
				end)
				return
			end


			pnl:DoClick(pnl)
		end

		local treeReport = vgui.Create( "DTree", mainHolder )
		treeReport:SetPos(20,150)
		treeReport:SetSize(mainHolder:GetWide() - 40,475)

		BadCoderz.populateTreeWithData(treeReport, LastCSReport, true)

	end



	local curcolor = color_SS
	local nbutton = nbutton + 1
	local buttonServerside = TDLib("DButton", DermaBadCoderz)
	DermaBadCoderz.buttonServerside = buttonServerside
	buttonServerside:SetPos(1, holdery + nbutton * buttonh)
	buttonServerside:SetSize(DermaBadCoderz:GetWide() - mainHolder:GetWide() - holderbordel-1, buttonh)
	buttonServerside:SetText("")
	buttonServerside:ClearPaint()
	:Background(color_light_grey)
	:SideBlock(curcolor, 4, LEFT)
	:FillHover(curcolor)
	:Text("Server Realm", "BadCoderzFont2", color_black, TEXT_ALIGN_CENTER, 5):CircleClick(color_black)

	buttonServerside.DoClick = function(pnl)
		pnl.ClickX, pnl.ClickY = pnl:CursorPos()
		pnl.Rad = 0
		pnl.Alpha = color_black.a

		net.Start("BadCoderz_report_request")
		net.SendToServer()

		DermaBadCoderz.currentmode = nbutton
		mainHolder:Clear()




	end

	buttonServerside.UpdateAsync = function(pnl, active, data)

		mainHolder:ClearPaint():Background(color_light_grey):SideBlock(curcolor, 6, LEFT)
		--:FillHover(curcolor)
		LastSSReport = data
		local labelStatus = vgui.Create( "DLabel", mainHolder )
		labelStatus:SetPos( 40, 20 )
		labelStatus:SetSize( 300, 30 )
		labelStatus:SetText( "Scan status : " ..  (active and "Active" or "Innactive"))
		labelStatus:SetColor(active and color_dark_green  or color_dark_red)
		labelStatus:SetFont("BadCoderzFont2")


		local labelProtip = vgui.Create( "DLabel", mainHolder )
		labelProtip:SetPos( 760, 20 )
		labelProtip:SetSize( 400, 300 )
		labelProtip:SetText( "The more player you have on the server,\nthe more 'code smells' will be detected.\nThe idea is to do as much different\nthings as possible to cover an area\nas wide as possible.")
		labelProtip:SetColor(color_black)
		labelProtip:SetFont("BadCoderzFontSmall")
		labelProtip:SetContentAlignment(8)



		local buttonStartPause = TDLib("DButton", mainHolder)
		buttonStartPause:SetPos(40, 70)
		buttonStartPause:SetSize(150,50)
		buttonStartPause:SetText("")


		if active then
			buttonStartPause:ClearPaint():Background(color_red):FadeHover(color_button_fade, 15):Text("Pause", "BadCoderzFont2", color_white)
		else
			buttonStartPause:ClearPaint():Background(color_green):FadeHover(color_button_fade, 15):Text("Start", "BadCoderzFont2", color_white)
		end

		buttonStartPause.DoClick = function()
			net.Start("BadCoderz_scan_request")
			net.SendToServer()

			local shouldclose = BadCoderz.settings.auto_close_menu:GetBool()
			local shouldreopen = BadCoderz.settings.auto_reopen_menu:GetBool()
			if (shouldclose and not active and shouldreopen) then -- test running == true because it was called right before
				local timer_reopen = BadCoderz.settings.auto_reopen_menu_time:GetInt()
				DermaBadCoderz:Close()
				timer.Simple(timer_reopen, function()
					if BadCoderz.Derma and IsValid(BadCoderz.Derma) then
						return
					end
					net.Start("BadCoderz_status_request")
					net.SendToServer()
				end)
				return
			end

			pnl:DoClick(pnl)
		end

		local treeReport = vgui.Create( "DTree", mainHolder )
		treeReport:SetPos(20,150)
		treeReport:SetSize(mainHolder:GetWide() - 40,475)

		BadCoderz.populateTreeWithData(treeReport, data, false)


	end





	local curcolor = color_light_red
	local nbutton = nbutton + 1
	local buttonOptions = TDLib("DButton", DermaBadCoderz)
	DermaBadCoderz.buttonOptions = buttonOptions
	buttonOptions:SetPos(1, holdery + nbutton * buttonh)
	buttonOptions:SetSize(DermaBadCoderz:GetWide() - mainHolder:GetWide() - holderbordel-1, buttonh)
	buttonOptions:SetText("")
	buttonOptions:ClearPaint()

	:Background(color_light_grey)
	:SideBlock(curcolor, 4, LEFT)
	:FillHover(curcolor)
	:Text("Options & Misc", "BadCoderzFont1.5", color_black, TEXT_ALIGN_CENTER, 5):CircleClick(color_black)


	buttonOptions.DoClick = function(pnl)
		pnl.ClickX, pnl.ClickY = pnl:CursorPos()
		pnl.Rad = 0
		pnl.Alpha = color_black.a
		DermaBadCoderz.currentmode = nbutton
		mainHolder:Clear()
		mainHolder:ClearPaint():Background(color_light_grey):SideBlock(curcolor, 6, LEFT)

			/*
			BadCoderz.settings.auto_close_menu
			BadCoderz.settings.auto_reopen_menu
			BadCoderz.settings.auto_reopen_menu_time*
			*/


			local CheckBoxAutoClose = TDLib( "DCheckBoxLabel", mainHolder )
			CheckBoxAutoClose:SetPos( 35, 50 )
			CheckBoxAutoClose:SetText( "")
			CheckBoxAutoClose:SetConVar( BadCoderz.settings.auto_close_menu:GetName())
			CheckBoxAutoClose:SetChecked( BadCoderz.settings.auto_close_menu:GetBool() )
			CheckBoxAutoClose:SizeToContents()
			CheckBoxAutoClose:SetDark(true)
			CheckBoxAutoClose:ClearPaint():Text(BadCoderz.settings.auto_close_menu:GetHelpText(), "BadCoderzFont1", color_black)


			local CheckBoxAutoReOpen = TDLib( "DCheckBoxLabel", mainHolder )
			CheckBoxAutoReOpen:SetPos( 35, 90 )
			CheckBoxAutoReOpen:SetText( "")
			CheckBoxAutoReOpen:SetConVar( BadCoderz.settings.auto_reopen_menu:GetName())
			CheckBoxAutoReOpen:SetChecked( BadCoderz.settings.auto_reopen_menu:GetBool() )
			CheckBoxAutoReOpen:SizeToContents()
			CheckBoxAutoReOpen:SetDark(true)
			CheckBoxAutoReOpen:ClearPaint():Text(BadCoderz.settings.auto_reopen_menu:GetHelpText(), "BadCoderzFont1", color_black)


			local SliderReopentimer = TDLib( "DNumSlider", mainHolder )
			--SliderReopentimer.TextArea:Hide()
			SliderReopentimer.Label:Hide()
			SliderReopentimer.Scratch:Hide()
			SliderReopentimer:SetPos( 30, 110 )
			SliderReopentimer:SetSize( 175, 50 )
			--SliderReopentimer:SetText(false)
			SliderReopentimer:SetMin( 1 )
			SliderReopentimer:SetMax( 60 )
			SliderReopentimer:SetDecimals( 0 )
			SliderReopentimer:SetConVar( BadCoderz.settings.auto_reopen_menu_time:GetName() )
			SliderReopentimer:SetDark(true)
			SliderReopentimer:SizeToContents()
			SliderReopentimer:SetValue(BadCoderz.settings.auto_reopen_menu_time:GetInt())

			local labelSliderReopen = vgui.Create( "DLabel", mainHolder )
			labelSliderReopen:SetPos( 190, 123 )
			labelSliderReopen:SetSize( 500, 300 )
			labelSliderReopen:SetText( BadCoderz.settings.auto_reopen_menu_time:GetHelpText())
			labelSliderReopen:SetColor(color_black)
			labelSliderReopen:SetFont("BadCoderzFont1")
			labelSliderReopen:SetContentAlignment(8)


			SliderReopentimer.Slider.Paint = function(self, w, h)
				surface.SetDrawColor(75, 75, 75, 100)
				surface.DrawRect(8, h / 2 - 2, w - 12, 3)
			end

			SliderReopentimer.Slider.Knob.Paint = function(self, w, h)
				surface.SetDrawColor(150, 150, 255, 255)
				surface.DrawRect(8, 0, 3, h)
			end
			/*
				lastCSReport
				LastSSReport
			*/
			local buttonExportCS = TDLib("DButton", mainHolder)
			buttonExportCS:SetText("")
			buttonExportCS:SetSize(500, 60)
			buttonExportCS:SetPos(40,165)
			buttonExportCS:ClearPaint():Background(color_CS):Text("Export last Clientside report to Clipboard", "BadCoderzFont1.5", color_black):CircleClick(color_black)

			buttonExportCS.DoClick = function(pnl)
				pnl.ClickX, pnl.ClickY = pnl:CursorPos()
				pnl.Rad = 0
				pnl.Alpha = color_black.a
				if (table.IsEmpty(LastCSReport)) then
					DermaBadCoderz.Wizz()
				end
				SetClipboardText(BadCoderz.reportToText(LastCSReport))

			end


			local buttonExportSS = TDLib("DButton", mainHolder)
			buttonExportSS:SetText("")
			buttonExportSS:SetSize(500, 60)
			buttonExportSS:SetPos(40,245)
			buttonExportSS:ClearPaint():Background(color_SS):Text("Export last Serverside report to Clipboard", "BadCoderzFont1.5", color_black):CircleClick(color_black)
			buttonExportSS.DoClick = function(pnl)
				pnl.ClickX, pnl.ClickY = pnl:CursorPos()
				pnl.Rad = 0
				pnl.Alpha = color_black.a
				if (table.IsEmpty(LastSSReport)) then
					DermaBadCoderz.Wizz()
				end
				SetClipboardText(BadCoderz.reportToText(LastSSReport))
			end

		end

	local secretbutton = TDLib("DButton", DermaBadCoderz)
	secretbutton:SetSize(DermaBadCoderz:GetWide() - mainHolder:GetWide() - holderbordel-1, buttonh)
	secretbutton:SetPos(1,DermaBadCoderz:GetTall()-buttonh*2-1)

	secretbutton:SetText("")
	secretbutton:ClearPaint()

	:Background(color_white)
	:CircleHover(color_black)
	:Text("The Twilight Zone", "BadCoderzFont1", color_white, TEXT_ALIGN_CENTER, 5)


	secretbutton.DoClick = function(pnl)
		pnl:GetParent():Close()
		BadCoderz.Credits()
	end
																																																		-- don't bother removing this from gmodstore, it's going to be released for free on github anyway
																																																		local noUpdate = TDLib("DButton", DermaBadCoderz)
																																																		noUpdate:SetSize(DermaBadCoderz:GetWide() - mainHolder:GetWide() - holderbordel-1, buttonh)
																																																		noUpdate:SetPos(1,DermaBadCoderz:GetTall() - buttonh-1)

																																																		noUpdate:SetText("")
																																																		noUpdate:ClearPaint()

																																																		:Background(color_white)
																																																		:CircleHover(color_button_fade)
																																																		:Text("No more updates", "BadCoderzFont1", color_black, TEXT_ALIGN_CENTER, 5)
																																																		:SetOpenURL("https://gist.github.com/ExtReMLapin/5a7779e7ced431d1ba9a6a12b3b577b0")

	if not ongoingServerScan then
		buttonClientside:DoClick()
	else
		buttonServerside:DoClick()
	end

end

