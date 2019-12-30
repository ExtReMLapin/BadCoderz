
local color_green = Color(65, 200, 0, 255)
surface.CreateFont("BadCoderzHACK", {
	font = "Courier New",
	extended = false,
	size = ScrH()*23/1440,
	weight = 0,
	blursize = 0,
	scanlines = 0,
	antialias = false,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

local ASCII = [[

▀█████████▄     ▄████████ ████████▄   ▄████████  ▄██████▄  ████████▄     ▄████████    ▄████████  ▄███████▄  
  ███    ███   ███    ███ ███   ▀███ ███    ███ ███    ███ ███   ▀███   ███    ███   ███    ███ ██▀     ▄██ 
  ███    ███   ███    ███ ███    ███ ███    █▀  ███    ███ ███    ███   ███    █▀    ███    ███       ▄███▀ 
 ▄███▄▄▄██▀    ███    ███ ███    ███ ███        ███    ███ ███    ███  ▄███▄▄▄      ▄███▄▄▄▄██▀  ▀█▀▄███▀▄▄ 
▀▀███▀▀▀██▄  ▀███████████ ███    ███ ███        ███    ███ ███    ███ ▀▀███▀▀▀     ▀▀███▀▀▀▀▀     ▄███▀   ▀ 
  ███    ██▄   ███    ███ ███    ███ ███    █▄  ███    ███ ███    ███   ███    █▄  ▀███████████ ▄███▀       
  ███    ███   ███    ███ ███   ▄███ ███    ███ ███    ███ ███   ▄███   ███    ███   ███    ███ ███▄     ▄█ 
▄█████████▀    ███    █▀  ████████▀  ████████▀   ▀██████▀  ████████▀    ██████████   ███    ███  ▀████████▀ 
                                                                                     ███    ███             

]]

local bdctbl = {utf8.codepoint(ASCII, 1, -1)}
local bdcchartbl = {}

for k, v in ipairs(bdctbl) do
	bdcchartbl[k] = utf8.char(v)
end

local timedown = 5
local offsetbase = -ScrH()/2-300
local function flagdraw(startTime)
	surface.SetFont("BadCoderzHACK")
	surface.SetTextColor(color_green)
	local charsizew, charsizeh = surface.GetTextSize('▀')
	local i = 1
	local x = ScrW() / 2 - (108 * charsizew) / 2 + math.cos(CurTime() * 1.5 + 2) * 15
	local yoffset = 0

	if (CurTime() < startTime + timedown) then
		yoffset = math.Remap(CurTime(),startTime ,startTime + timedown, offsetbase, 0 )
	end


	local y = ScrH()/2.4 + math.sin(CurTime() * 0.75 - 1) * 25 + yoffset
	local cursize = 0
	local count = #bdcchartbl
	local y2 = 0

	while (i <= count) do
		if (bdcchartbl[i] == '\n') then
			cursize = 0
			y2 = y2 + charsizeh
			i = i + 1
			if (i > count) then break end
		end

		cursize = cursize + charsizew
		surface.SetTextPos(x + cursize, y + y2 + math.cos(cursize + SysTime() * 10) * 4)
		surface.DrawText(bdcchartbl[i])
		i = i + 1
	end
end

function BadCoderz.Credits()
	if BadCoderz.DermaCredits and IsValid(BadCoderz.DermaCredits) then
		BadCoderz.DermaCredits:Close()
	end

	DermaBadCoderz = TDLib("DFrame")
	BadCoderz.DermaCredits = DermaBadCoderz
	DermaBadCoderz:SetPos(0, 0)
	DermaBadCoderz:SetSize(ScrW(), ScrH())
	DermaBadCoderz:SetTitle("")
	DermaBadCoderz:SetDraggable(false)
	DermaBadCoderz:MakePopup()
	DermaBadCoderz:Center()
	DermaBadCoderz:ShowCloseButton(false)
	DermaBadCoderz.btnMaxim.Paint = function(panel, w, h) end
	DermaBadCoderz.btnMinim.Paint = function(panel, w, h) end
	local buttonClose = TDLib("DButton", DermaBadCoderz)
	buttonClose:SetText("")
	buttonClose:SetSize(100, 40)
	buttonClose:SetPos(DermaBadCoderz:GetWide() - buttonClose:GetWide() - 1, 1)
	buttonClose:ClearPaint():Background(color_black):Text("×", "Trebuchet48", color_green)

	buttonClose.DoClick = function(pnl)
		pnl:GetParent():Close()
	end

	local startTime = CurTime()

	DermaBadCoderz.Paint = function(pnl, w, h)
		surface.SetDrawColor(color_black)
		surface.DrawRect(0, 0, w, h)
		flagdraw(startTime)
	end

	local music
	local url = "https://extrem-team.com/keygen3.mp3"

	sound.PlayURL(url, "", function(station, errorid, errorstr)
		music = station
	end)

	DermaBadCoderz.OnClose = function(pnl)
		if (music == nil or music:IsValid() == false) then
			return
		end

		timer.Remove("hackingGmodStore")
		music:Stop()
	end
end

--BadCoderz.Credits()