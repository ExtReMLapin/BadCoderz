
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

surface.CreateFont("BadCoderzHACK2", {
	font = "Courier New",
	extended = false,
	size = ScrH()*50/1440,
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


local credits = {
"Nux [76561197962571798]",
"Riddick [76561197963098122]",
"Alexander Ivanov [76561197971459535]",
"[CC] Danny [76561197974070406]",
"Vernoctus [76561197976207928]",
"pigeon [76561197978789107]",
"⬜HP⬜F.M. SMITH [76561197979056981]",
"alexgrist [76561197979205163]",
"Mika32 [76561197984232597]",
"DegenerateManiac [76561197985131383]",
"Marc [76561197987428962]",
"INJ3 [76561197988568430]",
"St11l [76561197989007643]",
"freemmaann [76561197989323181]",
"#Attache [76561197989693629]",
"Sgt.Val [76561197989881498]",
"Jckuk [76561197990859059]",
"gameout [76561197991275937]",
"[MG] Mark [76561197991892879]",
"Nurdism [76561197991928585]",
"-ICE- [76561197993955387]",
"Mrkrabz [76561197994206223]",
"MrGrim [76561197994240526]",
"Twitch.tv/m0rtos [76561197994560611]",
"ZerTeK [76561197995326047]",
"|DC| Drewbie [76561197995916061]",
"Mka0207 [76561197996267438]",
"Nosjo [76561197996463808]",
"[LRS] Aranir [76561197997606141]",
"[WPC] Forrest Mark X [76561197997881512]",
"$zero++; [76561197999997389]",
"Tontsa [76561198000189501]",
"chelog [76561198001309034]",
"Watchdog [76561198006360138]",
"GodOfNothing. [76561198007111303]",
"Jouaram [76561198010069529]",
"Kommandant Jut [76561198010077714]",
"Tyzu [76561198010806404]",
"mo3g666 [76561198011777394]",
"Nykez [76561198011844757]",
"Zerochain [76561198013322242]",
"☣»√ιяυƨ«☣ [76561198013802225]",
"flamboo [76561198014940064]",
"Nguyen [76561198015157261]",
"FrOnTeZ [76561198015224919]",
"Dallas [76561198016349436]",
"Erazor White [76561198017884700]",
"Mipastu [76561198018477778]",
"Jam Session [76561198019048041]",
"Pure [76561198019210482]",
"Loaskyial [Varus] SUS [76561198019442318]",
"{CCz} Jibinwar [76561198021824216]",
"Mr.ROFLMAN™ [76561198022493588]",
"GhostComander72 [76561198023723483]",
"Killer™ [76561198024821053]",
"Captain Black [76561198025881657]",
"Jorim [76561198026900589]",
"Tomas [76561198027094023]",
"TheFaiint [76561198028087472]",
"Ventz - Wang Dong Wingo [76561198029085201]",
"Instinkt [76561198030713180]",
"GrandpaTroll [76561198031700108]",
"=[HN]= Havoc [76561198033383770]",
"4udo [76561198033468770]",
"Horatio™ [76561198033756338]",
"[TG-of-TN]walkka [76561198034333249]",
"Ptilly [76561198035559333]",
"Rizqo [76561198035668047]",
"Vodka [76561198036772852]",
"Havanna ElLama [76561198037211601]",
"Major Death [76561198038710503]",
"azuspl [76561198038749037]",
"Clorox [76561198039226224]",
"Jesse [76561198040571472]",
"#Black4President [76561198040919114]",
"Hasan [76561198041569183]",
"Jomsy [76561198041934099]",
"Brassx [76561198041959113]",
"[Gaminglight.com] Zeeptin [76561198042112161]",
"Kezhar [76561198043293182]",
"Questionable [76561198044346824]",
"Alpha [76561198046362677]",
"我是淡定当然 [76561198046405253]",
"Gaboo [76561198046907785]",
"DrEnder [76561198047920491]",
"『 𝓕𝓵𝓾𝓰𝓪𝓵 』 [76561198047926641]",
"Alaxandar [76561198049186088]",
"Komi-sar [76561198049442792]",
"-JakerZ [76561198050338246]",
"[BLN] Resh [76561198050652544]",
"SunlessPine [76561198051517023]",
"Skyrox [76561198051535832]",
"sɦɨиγɑ ќღиɢɑʍɨ [76561198054648669]",
"Nidolai [76561198055180234]",
"Markus [76561198055581096]",
"Adam James [76561198056469034]",
"Dinkleberg >:( [76561198057690973]",
"whisperrybowl228 [76561198057974840]",
"Owain [76561198058562944]",
"Flol [76561198059279463]",
"101 Palpatyńczyków [76561198059635872]",
"Gmanc2 [76561198060166859]",
"Right_Twix [76561198063610282]",
"Sensei Hiraku [76561198063946583]",
"DogerTheDoge [76561198065274788]",
"Wasuma [76561198066766008]",
"Heaven [76561198068199263]",
"mcNuggets [76561198068523613]",
"Fruity [76561198068753895]",
"GrandDaddySmoke [76561198068857227]",
"Jellyton69 [76561198069393930]",
"MasterX [76561198069840599]",
"sacul.h [76561198071443989]",
"Shadow [76561198071598838]",
"TheLuMaster [76561198071604863]",
"YouTube - Wunder [76561198072208440]",
"Warden Potato [76561198072825924]",
"useless [76561198073125273]",
"Mayze6 [76561198074906310]",
"VALERY [76561198074911795]",
"[₯₰۞]μṬṓṙṙḙṉṯ® [76561198075148568]",
"Romarin [76561198075390609]",
"{SBF}Sauronox [76561198077277128]",
"Bhoon [76561198078444928]",
"Soul [76561198078481716]",
"JockeRex [76561198078608537]",
"[*P:R*]Diemon_EX [76561198080439685]",
"twtich.tv/highfivebadger [76561198083570332]",
"Walker [76561198083670208]",
"Golgi Apparatus [76561198084042269]",
"Alex T. Foxe [76561198084204021]",
"MultiGK [76561198085267384]",
"nerzlakai96 [76561198085282329]",
"Amanite2012 [76561198085690199]",
"Stan [76561198086036321]",
"Hades [76561198086193663]",
"Adsman100 [76561198087621128]",
"mark_xero_04 [76561198088133019]",
"Sam Maxis [76561198088824319]",
"Verdict [76561198089465570]",
"Yogpod [76561198092381685]",
"Flash [76561198092742034]",
"Kantil [76561198092983444]",
"LucaReno [76561198093244860]",
"Moonlight | AJ [76561198093521540]",
"slaVAC [76561198095033845]",
"Keitho [76561198096900690]",
"TorrentofShame [76561198097015658]",
"Chris [76561198097562734]",
"Camper™ [76561198098449576]",
"Shocks [76561198098764577]",
"ЯМАТО ???????? [76561198100296417]",
"Lanos [76561198100383665]",
"Dawnables [76561198100789604]",
"Triangle [76561198100793182]",
"Juaket [76561198100925473]",
"3pixel [76561198102241597]",
"RockerOfWorlds [76561198102292519]",
"Noobly [76561198102403039]",
"Nikku Miru [76561198104065271]",
"Lufou [76561198104759836]",
"taka_qiao [76561198104948727]",
"wtfisarabesk [76561198105957680]",
"Niff [76561198106316621]",
"Soks [76561198107255211]",
"Pierre Johnson [76561198109871279]",
"clear [76561198109963148]",
"NacBoi [76561198110022447]",
"Stezzers - Naxal-Networks.co.uk [76561198111790342]",
"Shadowsun™ [76561198112042939]",
"Tanker [76561198113025297]",
"[Toxidation] [76561198114369348]",
"Gasp ★ [76561198115550675]",
"Habel [76561198116515492]",
"Aws0me [76561198116888982]",
"Trillium [76561198117369504]",
"Bucket [76561198117917496]",
"odesza [76561198118169513]",
"BlueSn00w [76561198120125520]",
"BOT Benny [76561198120695978]",
"Aevoa [76561198120882898]",
"Livaco [76561198121018313]",
"Omni [76561198121441395]",
"Miskie [76561198122638261]",
"Conwell [76561198123068127]",
"Marki [76561198124382817]",
"☜☆☞ -GPX- Demo ☜☆☞ [76561198124708739]",
"Isaac131 [76561198125561657]",
"AvoxPaine [76561198126083590]",
"Marcin46405 [76561198127143504]",
"Nystoo/Neal [76561198127456980]",
"Kydesn1k [76561198128047514]",
"MrDiaboloz [76561198128166689]",
"Skeptic [76561198128507071]",
"Syzco [76561198128725929]",
"|$m0k!n|~IKILLYOU~ [76561198129536045]",
"waythink [76561198129697732]",
"Jacob [76561198130115660]",
"Sven [76561198130141257]",
"RyanTheTechMan [76561198131304286]",
"Jean Marie LePen [76561198132219148]",
"Sleety [76561198133686949]",
".#NIKOLAY!3370 ☾⋆ [76561198134029133]",
"xXReAL OtVeRTKAXx [76561198134148886]",
"Offshorp [76561198134595040]",
"Pandaa [76561198135638255]",
"Dopler [76561198135698052]",
"Greenwood [76561198135727623]",
"Nitch [76561198136394134]",
"MasterBeef [76561198136775271]",
"Gamma [76561198137025938]",
"Sombra Carmesí [76561198137854113]",
"[FL] AweSUCCBullet [76561198138802562]",
"KyrBaXa (≧∇≦) [76561198139315626]",
"KyleJames0408 [76561198139359719]",
"a [76561198139637545]",
"yam [76561198139733880]",
"Военком [76561198140183136]",
"JYST3R [76561198140995609]",
"Batmanhey [76561198141043787]",
"Blaster Alpha [76561198141142594]",
"TEH 1337 |-|VHS7 [76561198141666619]",
"[RU]LOyoujoLI [76561198142346653]",
"STRELOKMAX [76561198142760541]",
"[HG] x Hyper Gaming x [76561198142971462]",
"Erik [76561198143535846]",
"DrumFire [76561198143682256]",
"Mr. Tapout [76561198143907681]",
"Enzio [76561198144440215]",
"Zebra [76561198144651117]",
"The_Cosmic [76561198144807674]",
"Kotyarishka [76561198144964099]",
"JackGamesFTW [76561198145669259]",
"SeeTwo [76561198145700098]",
"RoZeL [76561198146913082]",
"Marshall [76561198147082669]",
"XxsnipercatxX81 [76561198148179653]",
"Ben [76561198150268365]",
"TheGeek47  [76561198151644706]",
"Brozzor [76561198156635728]",
"_RedWolf [76561198157339064]",
"HeyJack [76561198158042782]",
"Log [76561198159652224]",
"Aiko Suzuki [76561198160570208]",
"Micah [76561198162087822]",
"Ethan [76561198163953541]",
"Walrusking [76561198167304516]",
"CandyApple [76561198168652477]",
"Shadow [76561198170651942]",
"Nicolas [76561198173245925]",
"SugarTheCat 2nd[CaT] [76561198174394338]",
"AvarianKnight [76561198174460202]",
"Ghost36000 [76561198175653470]",
"{Belda} [76561198177069851]",
"Rayek [76561198178393710]",
"Seth [76561198180318085]",
"Kotus [76561198181970707]",
"Ceaser [76561198183691630]",
"Focus [76561198183857985]",
"LAST OF US [76561198184300797]",
"KinGoHD [76561198184662818]",
"Ballerd™ [76561198187121533]",
"No-Name Legend2 [76561198192711263]",
"1328 | SOG | Cohen™ #Abrakadab [76561198193206907]",
"Peteplays42 [76561198194722521]",
"versa [76561198194961926]",
"Flame [76561198195497869]",
"minethan60 [76561198198093633]",
"Wesley ❉ [76561198198105490]",
"[GG] Jeremy [76561198202011800]",
"Sinyx [76561198204327588]",
"Doublés [76561198208154057]",
"tasid [76561198210577821]",
"Vulgo [76561198212875496]",
"Tom.bat [76561198215456356]",
"[♥D.SS♥]Phoenixmeister [76561198216476691]",
"Mekphen [76561198224385656]",
"[Wrups2.0] Benoit Freeman [76561198226277844]",
"Elisium Mesrine [76561198237595634]",
"dontworry [76561198242113260]",
"[RN] Zeo [76561198249648050]",
"SlownLS [76561198251737334]",
"Zeo [76561198251742058]",
"Twacker [76561198253168662]",
"[Corvezeo] [76561198253220777]",
"MultiXeon [76561198256490200]",
"Zepioz [76561198262193882]",
"Swank Weezy [76561198262538001]",
"[罪] Hunzerg [76561198271953473]",
"ichickenwafflei - twitch [76561198284023854]",
"joeleroi1990 [76561198296934706]",
"JAKE1234 [76561198297340417]",
"Feeps [76561198297871252]",
"[IG] Eclipse [76561198299938652]",
"Foks [76561198300670656]",
"Wrath [76561198305817302]",
"Johnson [76561198307660201]",
"Wryer [76561198316998248]",
"[76561198321157245]",
"_Dubrovski_ [76561198327871184]",
"-MG- Pie [76561198328716062]",
"[PS] Kairos [76561198328995481]",
"Kaname [76561198329543401]",
"Sebiann [76561198337460582]",
"Flase | LegacyGaming.co [76561198339936290]",
"Emaister : P [76561198340258665]",
"Килиан | UnityServers.FR [76561198343872798]",
"Nafik Ma Wyjebane [76561198347648056]",
"LindaBigTits [76561198352098873]",
"Jame [76561198353159846]",
"Dog are cute. hellcase.com [76561198360062712]",
"Adapting [76561198368262297]",
"Urgo [76561198370489073]",
"poorMrbumblepuss [76561198378141280]",
"_KaMYu_ [76561198378359741]",
"Garry [76561198378570387]",
"Binbin [76561198387524220]",
"D34THC47 [76561198391272884]",
"Wicca Phase [76561198398798258]",
"Zaphkiel [76561198412850298]",
"Alex Loven [76561198420959775]",
"Sir. Skeleton [76561198423673722]",
"Deadpool [76561198427344474]",
"Haley | GMOD Central [76561198444401856]",
"SacredAI [76561198806609844]",
"[WOLF] The Omega(Second) [76561198815111433]",
"Miau-Hase [76561198815186070]",
"bilalunal252 [76561198835587375]",
"komatoz.# [76561198843430939]",
"Donovan[El Rodriguez][Capitaine] [76561198864405374]",
"notsaying [76561198872122075]",
"NoSharp [76561198879542401]",
"intellectpvp [76561198977521251]",
"High Octane Gaming [76561198979042539]",
"DummKopf [76561198979866465]",
"BigBoiBorris [76561198982162713]",
"nshatov21 [76561198987046616]",
"RedFox-Community [76561199001230296]",
"Tom Hagen [76561199008488819]",
"BillyW [76561198346972028]",
"Lapin/LPN64 [76561198001451981]"
}

local posTbl
local proGamer

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
		yoffset = math.Remap(CurTime(), startTime, startTime + timedown, offsetbase, 0)
	end

	local y = ScrH() / 2.4 + math.sin(CurTime() * 0.75 - 1) * 25 + yoffset
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

	surface.SetTextColor(Color(65, 200, 0, math.Remap(CurTime(), startTime, startTime + timedown, 0, 255)))

	for k, v in ipairs(credits) do
		if k == proGamer then continue end
		local timeChange1 = math.cos(CurTime() + k * k / 2) * 20
		local timeChange2 = math.sin(CurTime() + k * k / 5) * 80
		surface.SetTextPos(posTbl[k][1] + timeChange1, posTbl[k][2] - timeChange2)
		surface.DrawText(v)
	end

	if proGamer then
		surface.SetFont("BadCoderzHACK2")
		surface.SetTextColor(
			Color(math.abs(math.sin(CurTime() * 5)) * 255,
				math.cos(math.sin(CurTime() * 9)) * 255,
				math.abs(math.sin(CurTime() * 7)) * 255,
				math.Remap(CurTime(), startTime, startTime + timedown, 0, 255)
				)
			)
		local timeChange1 = math.cos(CurTime() + proGamer * proGamer / 2) * 20
		local timeChange2 = math.sin(CurTime() + proGamer * proGamer / 5) * 80
		surface.SetTextPos(posTbl[proGamer][1] + timeChange1, posTbl[proGamer][2] - timeChange2)
		surface.DrawText(credits[proGamer])
	end
end

function BadCoderz.Credits()
	if BadCoderz.DermaCredits and IsValid(BadCoderz.DermaCredits) then
		BadCoderz.DermaCredits:Close()
	end
	posTbl = {}

	proGamer = nil
	for k, v in ipairs(credits) do
		if not proGamer and string.find(v, LocalPlayer():SteamID64()) then proGamer = k end
		surface.SetFont("BadCoderzHACK")
		local w, h = surface.GetTextSize(v)
		posTbl[k] = {math.random(0, ScrW()-w), math.random(h, ScrH()-h)}
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

		music:Stop()
	end
end

--BadCoderz.Credits()