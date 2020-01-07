--[[---------------------------------------------------------------------------
	Three's Derma Lib
	Made by Threebow, moddified by Lapin to fix render order and to not "overwrite" other libs
---------------------------------------------------------------------------]]
--[[---------------------------------------------------------------------------
	Constants
---------------------------------------------------------------------------]]
local blur = Material("pp/blurscreen")
local gradLeft = Material("vgui/gradient-l")
local gradUp = Material("vgui/gradient-u")
local gradRight = Material("vgui/gradient-r")
local gradDown = Material("vgui/gradient-d")
--[[---------------------------------------------------------------------------
	Collection of various utilities
---------------------------------------------------------------------------]]
local TDLibUtil = {}

--Beast's circle drawing function v2
TDLibUtil.DrawCircle = function(x, y, r, col)
	local circle = {}

	for i = 1, 360 do
		circle[i] = {}
		circle[i].x = x + math.cos(math.rad(i * 360) / 360) * r
		circle[i].y = y + math.sin(math.rad(i * 360) / 360) * r
	end

	surface.SetDrawColor(col)
	draw.NoTexture()
	surface.DrawPoly(circle)
end

TDLibUtil.DrawArc = function(x, y, ang, p, rad, color, seg)
	seg = seg or 80
	ang = (-ang) + 180
	local circle = {}

	table.insert(circle, {
		x = x,
		y = y
	})

	for i = 0, seg do
		local a = math.rad((i / seg) * -p + ang)

		table.insert(circle, {
			x = x + math.sin(a) * rad,
			y = y + math.cos(a) * rad
		})
	end

	surface.SetDrawColor(color)
	draw.NoTexture()
	surface.DrawPoly(circle)
end

TDLibUtil.LerpColor = function(frac, from, to)
	return Color(Lerp(frac, from.r, to.r), Lerp(frac, from.g, to.g), Lerp(frac, from.b, to.b), Lerp(frac, from.a, to.a))
end

--Various handy premade transition functions
TDLibUtil.HoverFunc = function(s)
	return s:IsHovered()
end

TDLibUtil.HoverFuncChild = function(s)
	return s:IsHovered() or s:IsChildHovered()
end

--[[---------------------------------------------------------------------------
	Circle function - credit to Beast
---------------------------------------------------------------------------]]
local function drawCircle(x, y, r)
	local circle = {}

	for i = 1, 360 do
		circle[i] = {}
		circle[i].x = x + math.cos(math.rad(i * 360) / 360) * r
		circle[i].y = y + math.sin(math.rad(i * 360) / 360) * r
	end

	surface.DrawPoly(circle)
end

--[[---------------------------------------------------------------------------
	Basic helper classes
---------------------------------------------------------------------------]]
local classes = {}

classes.On = function(pnl, name, fn)
	name = pnl.AppendOverwrite or name
	local old = pnl[name]

	pnl[name] = function(s, ...)
		if (old) then
			old(s, ...)
		end

		fn(s, ...)
	end
end

classes.SetupTransition = function(pnl, name, speed, fn)
	fn = pnl.TransitionFunc or fn
	pnl[name] = 0

	pnl:On("Think", function(s)
		s[name] = Lerp(FrameTime() * speed, s[name], fn(s) and 1 or 0)
	end)
end

--[[---------------------------------------------------------------------------
	Classes
---------------------------------------------------------------------------]]
classes.FadeHover = function(pnl, col, speed, rad)
	col = col or Color(255, 255, 255, 30)
	speed = speed or 6
	pnl:SetupTransition("FadeHover", speed, TDLibUtil.HoverFunc)

	pnl:On("Paint", function(s, w, h)
		local col = ColorAlpha(col, col.a * s.FadeHover)

		if (rad and rad > 0) then
			draw.RoundedBox(rad, 0, 0, w, h, col)
		else
			surface.SetDrawColor(col)
			surface.DrawRect(0, 0, w, h)
		end
	end)
end

classes.BarHover = function(pnl, col, height, speed)
	col = col or Color(255, 255, 255, 255)
	height = height or 2
	speed = speed or 6
	pnl:SetupTransition("BarHover", speed, TDLibUtil.HoverFunc)

	pnl:On("Paint", function(s, w, h)
		local bar = math.Round(w * s.BarHover)
		surface.SetDrawColor(col)
		surface.DrawRect(w * 0.5 - bar * 0.5, h - height, bar, height)
	end)
end

classes.FillHover = function(pnl, col, dir, speed, mat)
	col = col or Color(255, 255, 255, 30)
	dir = dir or LEFT
	speed = speed or 8
	pnl:SetupTransition("FillHover", speed, TDLibUtil.HoverFunc)

	pnl:On("Paint", function(s, w, h)
		surface.SetDrawColor(col)
		local x, y, fw, fh

		if (dir == LEFT) then
			x, y, fw, fh = 0, 0, math.Round(w * s.FillHover), h
		elseif (dir == TOP) then
			x, y, fw, fh = 0, 0, w, math.Round(h * s.FillHover)
		elseif (dir == RIGHT) then
			local prog = math.Round(w * s.FillHover)
			x, y, fw, fh = w - prog, 0, prog, h
		elseif (dir == BOTTOM) then
			local prog = math.Round(h * s.FillHover)
			x, y, fw, fh = 0, h - prog, w, prog
		end

		if (mat) then
			surface.SetMaterial(mat)
			surface.DrawTexturedRect(x, y, fw, fh)
		else
			surface.DrawRect(x, y, fw, fh)
		end
	end)
end

classes.Background = function(pnl, col, rad, rtl, rtr, rbl, rbr)
	pnl:On("Paint", function(s, w, h)
		if (rad and rad > 0) then
			if (rtl ~= nil) then
				draw.RoundedBoxEx(rad, 0, 0, w, h, col, rtl, rtr, rbl, rbr)
			else
				draw.RoundedBox(rad, 0, 0, w, h, col)
			end
		else
			surface.SetDrawColor(col)
			surface.DrawRect(0, 0, w, h)
		end
	end)
end

classes.Material = function(pnl, mat, col)
	col = col or Color(255, 255, 255)

	pnl:On("Paint", function(s, w, h)
		surface.SetDrawColor(col)
		surface.SetMaterial(mat)
		surface.DrawTexturedRect(0, 0, w, h)
	end)
end

classes.TiledMaterial = function(pnl, mat, tw, th, col)
	col = col or Color(255, 255, 255, 255)

	pnl:On("Paint", function(s, w, h)
		surface.SetMaterial(mat)
		surface.SetDrawColor(col)
		surface.DrawTexturedRectUV(0, 0, w, h, 0, 0, w / tw, h / th)
	end)
end

classes.Outline = function(pnl, col, width)
	col = col or Color(255, 255, 255, 255)
	width = width or 1

	pnl:On("Paint", function(s, w, h)
		surface.SetDrawColor(col)

		for i = 0, width - 1 do
			surface.DrawOutlinedRect(0 + i, 0 + i, w - i * 2, h - i * 2)
		end
	end)
end

classes.LinedCorners = function(pnl, col, len)
	col = col or Color(255, 255, 255, 255)
	len = len or 15

	pnl:On("Paint", function(s, w, h)
		surface.SetDrawColor(col)
		surface.DrawRect(0, 0, len, 1)
		surface.DrawRect(0, 1, 1, len - 1)
		surface.DrawRect(w - len, h - 1, len, 1)
		surface.DrawRect(w - 1, h - len, 1, len - 1)
	end)
end

classes.SideBlock = function(pnl, col, size, side)
	col = col or Color(255, 255, 255, 255)
	size = size or 3
	side = side or LEFT

	pnl:On("Paint", function(s, w, h)
		surface.SetDrawColor(col)

		if (side == LEFT) then
			surface.DrawRect(0, 0, size, h)
		elseif (side == TOP) then
			surface.DrawRect(0, 0, w, size)
		elseif (side == RIGHT) then
			surface.DrawRect(w - size, 0, size, h)
		elseif (side == BOTTOM) then
			surface.DrawRect(0, h - size, w, size)
		end
	end)
end

classes.Text = function(pnl, text, font, col, alignment, ox, oy, paint)
	font = font or "Trebuchet24"
	col = col or Color(255, 255, 255, 255)
	alignment = alignment or TEXT_ALIGN_CENTER
	ox = ox or 0
	oy = oy or 0

	if (not paint and pnl.SetText and pnl.SetFont and pnl.SetTextColor) then
		pnl:SetText(text)
		pnl:SetFont(font)
		pnl:SetTextColor(col)
	else
		pnl:On("PaintOver", function(s, w, h)
			local x = 0

			if (alignment == TEXT_ALIGN_CENTER) then
				x = w * 0.5
			elseif (alignment == TEXT_ALIGN_RIGHT) then
				x = w
			end

			draw.SimpleText(text, font, x + ox, h * 0.5 + oy, col, alignment, TEXT_ALIGN_CENTER)
		end)
	end
end

classes.DualText = function(pnl, toptext, topfont, topcol, bottomtext, bottomfont, bottomcol, alignment, centerSpacing)
	topfont = topfont or "Trebuchet24"
	topcol = topcol or Color(0, 127, 255, 255)
	bottomfont = bottomfont or "Trebuchet18"
	bottomcol = bottomcol or Color(255, 255, 255, 255)
	alignment = alignment or TEXT_ALIGN_CENTER
	centerSpacing = centerSpacing or 0

	pnl:On("Paint", function(s, w, h)
		surface.SetFont(topfont)
		local tw, th = surface.GetTextSize(toptext)
		surface.SetFont(bottomfont)
		local bw, bh = surface.GetTextSize(bottomtext)
		local y1, y2 = h * 0.5 - bh * 0.5, h * 0.5 + th * 0.5
		local x

		if (alignment == TEXT_ALIGN_LEFT) then
			x = 0
		elseif (alignment == TEXT_ALIGN_CENTER) then
			x = w * 0.5
		elseif (alignment == TEXT_ALIGN_RIGHT) then
			x = w
		end

		draw.SimpleText(toptext, topfont, x, y1 + centerSpacing, topcol, alignment, TEXT_ALIGN_CENTER)
		draw.SimpleText(bottomtext, bottomfont, x, y2 - centerSpacing, bottomcol, alignment, TEXT_ALIGN_CENTER)
	end)
end

classes.Blur = function(pnl, amount)
	pnl:On("Paint", function(s, w, h)
		local x, y = s:LocalToScreen(0, 0)
		local scrW, scrH = ScrW(), ScrH()
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(blur)

		for i = 1, 3 do
			blur:SetFloat("$blur", (i / 3) * (amount or 8))
			blur:Recompute()
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
		end
	end)
end

classes.CircleClick = function(pnl, col, speed, trad)
	col = col or Color(255, 255, 255, 50)
	speed = speed or 5
	pnl.Rad, pnl.Alpha, pnl.ClickX, pnl.ClickY = 0, 0, 0, 0

	pnl:On("Paint", function(s, w, h)
		if (s.Alpha >= 1) then
			surface.SetDrawColor(ColorAlpha(col, s.Alpha))
			draw.NoTexture()
			drawCircle(s.ClickX, s.ClickY, s.Rad)
			s.Rad = Lerp(FrameTime() * speed, s.Rad, trad or w)
			s.Alpha = Lerp(FrameTime() * speed, s.Alpha, 0)
		end
	end)

	pnl:On("DoClick", function(s)
		s.ClickX, s.ClickY = s:CursorPos()
		s.Rad = 0
		s.Alpha = col.a
	end)
end

classes.CircleHover = function(pnl, col, speed, trad)
	col = col or Color(255, 255, 255, 30)
	speed = speed or 6
	pnl.LastX, pnl.LastY = 0, 0
	pnl:SetupTransition("CircleHover", speed, TDLibUtil.HoverFunc)

	pnl:On("Think", function(s)
		if (s:IsHovered()) then
			s.LastX, s.LastY = s:CursorPos()
		end
	end)

	pnl:On("Paint", function(s, w, h)
		draw.NoTexture()
		surface.SetDrawColor(ColorAlpha(col, col.a * s.CircleHover))
		drawCircle(s.LastX, s.LastY, s.CircleHover * (trad or w))
	end)
end

classes.SquareCheckbox = function(pnl, inner, outer, speed)
	inner = inner or Color(0, 255, 0, 255)
	outer = outer or Color(255, 255, 255, 255)
	speed = speed or 14

	pnl:SetupTransition("SquareCheckbox", speed, function(s)
		return s:GetChecked()
	end)

	pnl:On("Paint", function(s, w, h)
		surface.SetDrawColor(outer)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(inner)
		surface.DrawOutlinedRect(0, 0, w, h)
		local bw, bh = (w - 4) * s.SquareCheckbox, (h - 4) * s.SquareCheckbox
		bw, bh = math.Round(bw), math.Round(bh)
		surface.DrawRect(w * 0.5 - bw * 0.5, h * 0.5 - bh * 0.5, bw, bh)
	end)
end

classes.CircleCheckbox = function(pnl, inner, outer, speed)
	inner = inner or Color(0, 255, 0, 255)
	outer = outer or Color(255, 255, 255, 255)
	speed = speed or 14

	pnl:SetupTransition("CircleCheckbox", speed, function(s)
		return s:GetChecked()
	end)

	pnl:On("Paint", function(s, w, h)
		draw.NoTexture()
		surface.SetDrawColor(outer)
		drawCircle(w * 0.5, h * 0.5, w * 0.5 - 1)
		surface.SetDrawColor(inner)
		drawCircle(w * 0.5, h * 0.5, w * s.CircleCheckbox * 0.5)
	end)
end

classes.AvatarMask = function(pnl, mask)
	pnl.Avatar = vgui.Create("AvatarImage", pnl)
	pnl.Avatar:SetPaintedManually(true)

	pnl.Paint = function(s, w, h)
		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)
		render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilPassOperation(STENCILOPERATION_ZERO)
		render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
		render.SetStencilReferenceValue(1)
		draw.NoTexture()
		surface.SetDrawColor(255, 255, 255, 255)
		mask(s, w, h)
		render.SetStencilFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		render.SetStencilReferenceValue(1)
		s.Avatar:SetPaintedManually(false)
		s.Avatar:PaintManual()
		s.Avatar:SetPaintedManually(true)
		render.SetStencilEnable(false)
		render.ClearStencil()
	end

	pnl.PerformLayout = function(s)
		s.Avatar:SetSize(s:GetWide(), s:GetTall())
	end

	pnl.SetPlayer = function(s, ply, size)
		s.Avatar:SetPlayer(ply, size)
	end

	pnl.SetSteamID = function(s, id, size)
		s.Avatar:SetSteamID(id, size)
	end
end

classes.CircleAvatar = function(pnl)
	pnl:Class("AvatarMask", function(s, w, h)
		drawCircle(w * 0.5, h * 0.5, w * 0.5)
	end)
end

classes.Circle = function(pnl, col)
	col = col or Color(255, 255, 255, 255)

	pnl:On("Paint", function(s, w, h)
		draw.NoTexture()
		surface.SetDrawColor(col)
		drawCircle(w * 0.5, h * 0.5, math.min(w, h) * 0.5)
	end)
end

classes.CircleFadeHover = function(pnl, col, speed)
	col = col or Color(255, 255, 255, 30)
	speed = speed or 6
	pnl:SetupTransition("CircleFadeHover", speed, TDLibUtil.HoverFunc)

	pnl:On("Paint", function(s, w, h)
		draw.NoTexture()
		surface.SetDrawColor(ColorAlpha(col, col.a * s.CircleFadeHover))
		drawCircle(w * 0.5, h * 0.5, math.min(w, h) * 0.5)
	end)
end

classes.CircleExpandHover = function(pnl, col, speed)
	col = col or Color(255, 255, 255, 30)
	speed = speed or 6
	pnl:SetupTransition("CircleExpandHover", speed, TDLibUtil.HoverFunc)

	pnl:On("Paint", function(s, w, h)
		local rad = math.Round(w * 0.5 * s.CircleExpandHover)
		draw.NoTexture()
		surface.SetDrawColor(ColorAlpha(col, col.a * s.CircleExpandHover))
		drawCircle(w * 0.5, h * 0.5, rad)
	end)
end

classes.Gradient = function(pnl, col, dir, frac, op)
	dir = dir or BOTTOM
	frac = frac or 1

	pnl:On("Paint", function(s, w, h)
		surface.SetDrawColor(col)
		local x, y, gw, gh

		if (dir == LEFT) then
			local prog = math.Round(w * frac)
			x, y, gw, gh = 0, 0, prog, h
			surface.SetMaterial(op and gradRight or gradLeft)
		elseif (dir == TOP) then
			local prog = math.Round(h * frac)
			x, y, gw, gh = 0, 0, w, prog
			surface.SetMaterial(op and gradDown or gradUp)
		elseif (dir == RIGHT) then
			local prog = math.Round(w * frac)
			x, y, gw, gh = w - prog, 0, prog, h
			surface.SetMaterial(op and gradLeft or gradRight)
		elseif (dir == BOTTOM) then
			local prog = math.Round(h * frac)
			x, y, gw, gh = 0, h - prog, w, prog
			surface.SetMaterial(op and gradUp or gradDown)
		end

		surface.DrawTexturedRect(x, y, gw, gh)
	end)
end

classes.SetOpenURL = function(pnl, url)
	pnl:On("DoClick", function()
		gui.OpenURL(url)
	end)
end

classes.NetMessage = function(pnl, name, data)
	data = data or function() end

	pnl:On("DoClick", function()
		net.Start(name)
		data(pnl)
		net.SendToServer()
	end)
end

classes.Stick = function(pnl, dock, margin, dontInvalidate)
	dock = dock or FILL
	margin = margin or 0
	pnl:Dock(dock)

	if (margin > 0) then
		pnl:DockMargin(margin, margin, margin, margin)
	end

	if (not dontInvalidate) then
		pnl:InvalidateParent(true)
	end
end

classes.DivTall = function(pnl, frac, target)
	frac = frac or 2
	target = target or pnl:GetParent()
	pnl:SetTall(target:GetTall() / frac)
end

classes.DivWide = function(pnl, frac, target)
	target = target or pnl:GetParent()
	frac = frac or 2
	pnl:SetWide(target:GetWide() / frac)
end

classes.SquareFromHeight = function(pnl)
	pnl:SetWide(pnl:GetTall())
end

classes.SquareFromWidth = function(pnl)
	pnl:SetTall(pnl:GetWide())
end

classes.SetRemove = function(pnl, target)
	target = target or pnl

	pnl:On("DoClick", function()
		if (IsValid(target)) then
			target:Remove()
		end
	end)
end

classes.FadeIn = function(pnl, time, alpha)
	time = time or 0.2
	alpha = alpha or 255
	pnl:SetAlpha(0)
	pnl:AlphaTo(alpha, time)
end

classes.HideVBar = function(pnl)
	local vbar = pnl:GetVBar()
	vbar:SetWide(0)
	vbar:Hide()
end

classes.SetTransitionFunc = function(pnl, fn)
	pnl.TransitionFunc = fn
end

classes.ClearTransitionFunc = function(pnl)
	pnl.TransitionFunc = nil
end

classes.SetAppendOverwrite = function(pnl, fn)
	pnl.AppendOverwrite = fn
end

classes.ClearAppendOverwrite = function(pnl)
	pnl.AppendOverwrite = nil
end

classes.ClearPaint = function(pnl)
	pnl.Paint = nil
end

classes.ReadyTextbox = function(pnl)
	pnl:SetPaintBackground(false)

	pnl:SetAppendOverwrite("PaintOver"):SetTransitionFunc(function(s)
		return s:IsEditing()
	end)
end

--[[---------------------------------------------------------------------------
	TDLib function which adds all the classes to your panel
---------------------------------------------------------------------------]]
local meta = FindMetaTable("Panel")

function meta:TDLib()
	self.Class = function(pnl, name, ...)
		local class = classes[name]
		assert(class, "[TDLib]: Class " .. name .. " does not exist.")
		class(pnl, ...)

		return pnl
	end

	for k, v in pairs(classes) do
		self[k] = function(s, ...)
			return s:Class(k, ...)
		end
	end

	return self
end

function TDLib(c, p, n)
	local pnl = vgui.Create(c, p, n)

	return pnl:TDLib()
end

return (TDLib)