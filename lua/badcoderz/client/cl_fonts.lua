surface.CreateFont("BadCoderzFontSmall", {
	font = "Roboto Lt",
	size = 22,
	weight = 200
})

surface.CreateFont("BadCoderzFont1", {
	font = "Roboto Lt",
	size = 25,
	weight = 200
})


surface.CreateFont("BadCoderzFont1.2", {
	font = "Roboto Lt",
	size = 27,
	weight = 200
})

surface.CreateFont("BadCoderzFont1.5", {
	font = "Roboto Lt",
	size = 31,
	weight = 200
})




surface.CreateFont("BadCoderzFont2", {
	font = "Roboto Lt",
	size = 35,
	weight = 100
})

surface.CreateFont("BadCoderzFont3", {
	font = "Roboto Lt",
	size = 40,
	weight = 100
})

if not DarkRP then
	-- if any fuckers tries to "emulate" darkrp by creating the DarkRP global var, he's an idiot
	surface.CreateFont("Trebuchet48", {
		size = 48,
		weight = 500,
		antialias = true,
		shadow = false,
		font = "Trebuchet MS"
	})
end