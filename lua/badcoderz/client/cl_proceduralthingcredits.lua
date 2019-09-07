surface.CreateFont("BadCoderzRETARD", {
size = ScrH() * 80 / 1440,
	weight = 2000,
	shadow = false,
	font = "Trebuchet MS",
	outline = true
})


local soundtbl = {
	"vo/k_lab/kl_ahhhh.wav",
	"vo/npc/male01/runforyourlife03.wav",
	"vo/outland_02/sheckley_idiot02.wav",
	"vo/k_lab/ba_sarcastic01.wav",
	"vo/k_lab/ba_sarcastic03.wav",
	"vo/npc/barney/ba_pain01.wav",
	"vo/citadel/br_mock04.wav",
	"vo/npc/female01/answer21.wav",
	"vo/streetwar/alyx_gate/al_gordonrun.wav",
	"ambient/voices/f_scream1.wav",
	"vo/ravenholm/monk_death07.wav",
	"vo/npc/male01/no01.wav",
	"vo/k_lab/kl_heremypet02.wav",
	"vo/novaprospekt/al_nostop.wav",
	"vo/citadel/br_youfool.wav",
	"vo/novaprospekt/al_combinespy03.wav",
	"vo/npc/barney/ba_damnit.wav",
	"vo/citadel/al_notagain02.wav",
	"vo/citadel/br_goback.wav",
	"vo/streetwar/sniper/ba_heycomeon.wav"}


local texttbl = {

"S T O P   E D I T I N G   T H E   C O D E",
"STOP TOUCHING THE CODE YOU SILLY GOOSE",
"WELL PLAYED, YOU MANAGED TO BREAK THE ADDON BECAUSE YOU DIDN'T READ SHIT",
"*CLAP* *CLAP*",
"YER A PRO LUA CODER, WELL PLAYED",
"STOP EDITING THE CODE YOU FOOL",
"THERE IS NO CONFIG IN THE ADDON SO STOP EDITING THE CODE",
"REVERT THE CHANGES YOU DID ON THE CODE YOU FOOL",
"PUT BACK THE STEAMID64 YOU EDITED TO WHAT IT WAS",
"YOU SILLY GOOSE"
}


if BadCoderz.owner ~= "{{ user_id }}" then
	local ncount = 1

	concommand.Add("BadCoderz", function()
		if game.SinglePlayer() then
			LocalPlayer():ChatPrint("SinglePlayer isn't supported at least be connected to steam and start a local server in lan.")

			return
		end

		if LocalPlayer():SteamID64() ~= BadCoderz.owner and LocalPlayer():SteamID64() ~= "{{ user_id }}" then return end

		timer.Create("BadCoderzRetard", 0.6, 40, function()
			local _ncount = ncount
			local text = table.Random(texttbl)
			surface.SetFont("BadCoderzRETARD")
			local width, height = surface.GetTextSize(text)
			local x = math.random(0, ScrW() - width)
			local y = math.random(0, ScrH() - height)
			local hookname = "badcoderz_idiot" .. tostring(_ncount)

			if _ncount % 2 == 0 then
				surface.PlaySound(table.Random(soundtbl))
			end

			hook.Add("HUDPaint", hookname, function()
				surface.SetTextColor((math.cos(CurTime() * 5) + 0.5) * 255, (math.sin(CurTime()) + 0.5) * 255, (math.sin(CurTime() / 2) + 0.5) * 255)
				surface.SetTextPos(x, y)
				surface.SetFont("BadCoderzRETARD")
				surface.DrawText(text)

				timer.Simple(3, function()
					hook.Remove("HUDPaint", hookname)
				end)
			end)

			ncount = ncount + 1
		end)
	end)
end

local color_green = Color(65, 200, 0, 255)

surface.CreateFont("BadCoderzHACK", {
	font = "Courier New",
	extended = false,
	size = ScrH() * 23 / 1440,
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