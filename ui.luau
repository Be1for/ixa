local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

UserInputService.MouseIconEnabled = true
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local GuiService       = game:GetService("GuiService")
local Stats            = game:GetService("Stats")
local HttpService      = game:GetService("HttpService")

local player = Players.LocalPlayer
local mouse  = player:GetMouse()
local cam    = workspace.CurrentCamera or workspace:WaitForChild("Camera")

local COMET_ID = "rbxassetid://122212432133342"
local GUI_NAME = "IxaHub"
local HUB_TITLE = "IXA HUB"
local HUB_SUBTITLE = "clean GUI shell"

local guiRoot = player:WaitForChild("PlayerGui")
local stale   = guiRoot:FindFirstChild(GUI_NAME)
if stale then stale:Destroy() end

local C = {
	Window = Color3.fromRGB(23, 24, 26),
	Glass  = Color3.fromRGB(34, 35, 38),
	On     = Color3.fromRGB(255, 186, 44),
	Blue   = Color3.fromRGB(91, 96, 106),
	Text   = Color3.fromRGB(237, 237, 242),
	Dim    = Color3.fromRGB(164, 166, 175),
	White  = Color3.fromRGB(255, 255, 255),
	Accent = Color3.fromRGB(214, 116, 18),
	Lamp   = Color3.fromRGB(255, 236, 170),
}

local T = { fast = 0.14, mid = 0.28, open = 0.40, close = 0.34 }
local FULL_SCALE = 1.3

local FALLBACK_FONT = Font.fromEnum(Enum.Font.GothamMedium)
local function makeFont(families, weightName)
	for _, fam in ipairs(families) do
		local ok, font = pcall(function()
			local famEnum = (Enum.FontFamily :: any)[fam]
			if famEnum == nil then return nil end
			local weightEnum = (Enum.FontWeight :: any)[weightName] or Enum.FontWeight.Regular
			return Font.new(famEnum, weightEnum)
		end)
		if ok and font then return font end
	end
	return FALLBACK_FONT
end
local uiReg  = makeFont({ "GothamSSm", "Nunito", "Fredoka" }, "Medium")
local uiMed  = makeFont({ "GothamSSm", "Nunito", "Fredoka" }, "Bold")
local uiBold = makeFont({ "GothamSSm", "Nunito", "Fredoka" }, "Black")

local NL_ICON_REGULAR = Font.new(
	"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json",
	Enum.FontWeight.Regular, Enum.FontStyle.Normal
)
local ICON_MAP = {
	["swords"]="sword", ["footprints"]="person-running", ["eye"]="eye",
	["crosshair"]="crosshairs", ["party-popper"]="star", ["drama"]="person",
	["wrench"]="gear", ["wheat"]="flag", ["settings"]="gear", ["save"]="floppy-disk",
	["minus"]="minus", ["maximize-2"]="dual-arrows-to-corners", ["x"]="x",
	["zap"]="lightning-bolt", ["wifi"]="signal-exclamation", ["search"]="magnifying-glass",
	["plus"]="plus-large", ["trash-2"]="trash-can", ["check"]="check",
}
local function setIcon(holder, name, color)
	if not holder then return end
	if not holder:IsA("TextLabel") then
		local lbl = holder:FindFirstChild("NLIcon")
		if not lbl then
		lbl = Instance.new("TextLabel")
		lbl.Name = "NLIcon"
		pcall(function() lbl.AutoLocalize = false end)
			lbl.BackgroundTransparency = 1
			lbl.Size = UDim2.fromScale(1, 1)
			lbl.TextXAlignment = Enum.TextXAlignment.Center
			lbl.TextYAlignment = Enum.TextYAlignment.Center
			lbl.Parent = holder
		end
		holder = lbl
	end
	color = color or Color3.fromRGB(255, 255, 255)
	holder.Text = ICON_MAP[name] or name
	holder.FontFace = NL_ICON_REGULAR
	holder.TextColor3 = color
	holder.TextTransparency = 0
end

local function new(className, props)
	local inst = Instance.new(className)
	pcall(function() inst.AutoLocalize = false end)
	for k, v in pairs(props or {}) do
		pcall(function() inst[k] = v end)
	end
	pcall(function() inst:SetAttribute("bBT", inst.BackgroundTransparency) end)
	pcall(function() inst:SetAttribute("bTT", inst.TextTransparency) end)
	pcall(function() inst:SetAttribute("bIT", inst.ImageTransparency) end)
	pcall(function() inst:SetAttribute("bST", inst.Transparency) end)
	return inst
end

local tweenRegistry = setmetatable({}, { __mode = "k" })
local function cancelTweens(inst)
	local list = tweenRegistry[inst]
	if list then
		for _, t in ipairs(list) do
			if t.PlaybackState ~= Enum.PlaybackState.Completed then t:Cancel() end
		end
		tweenRegistry[inst] = nil
	end
end
local function tw(inst, props, time, style, dir, delayTime)
	cancelTweens(inst)
	local t = TweenService:Create(inst,
		TweenInfo.new(time or T.mid, style or Enum.EasingStyle.Quad,
			dir or Enum.EasingDirection.Out, 0, false, delayTime or 0),
		props)
	local list = tweenRegistry[inst]
	if not list then list = {}; tweenRegistry[inst] = list end
	table.insert(list, t)
	t:Play()
	return t
end

local function round(v) return math.floor(v + 0.5) end
local function vp() return cam.ViewportSize end

local function groupFadeProps(d, fade)
	local props = {}
	local bBT = d:GetAttribute("bBT")
	if bBT ~= nil and bBT < 1 then props.BackgroundTransparency = bBT + (1 - bBT) * fade end
	if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
		local bTT = d:GetAttribute("bTT")
		if bTT ~= nil and bTT < 1 then props.TextTransparency = bTT + (1 - bTT) * fade end
	end
	if d:IsA("ImageLabel") or d:IsA("ImageButton") then
		local bIT = d:GetAttribute("bIT")
		if bIT ~= nil and bIT < 1 then props.ImageTransparency = bIT + (1 - bIT) * fade end
	end
	if d:IsA("UIStroke") then
		local bST = d:GetAttribute("bST")
		if bST ~= nil and bST < 1 then props.Transparency = bST + (1 - bST) * fade end
	end
	return props
end
local function withRoot(root)
	local all = { root }
	for _, d in ipairs(root:GetDescendants()) do table.insert(all, d) end
	return all
end
local function groupFadeSet(root, fade)
	for _, d in ipairs(withRoot(root)) do
		for k, v in pairs(groupFadeProps(d, fade)) do d[k] = v end
	end
end
local function groupFade(root, fade, time, style, dir, delay)
	for _, d in ipairs(withRoot(root)) do
		local props = groupFadeProps(d, fade)
		if next(props) then tw(d, props, time, style, dir, delay) end
	end
end

local function tap(inst, cb)
	local down = nil
	inst.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			down = Vector2.new(mouse.X, mouse.Y)
		end
	end)
	inst.InputEnded:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch) and down ~= nil then
			local d = Vector2.new(mouse.X, mouse.Y) - down
			down = nil
			if d.Magnitude < 6 then cb() end
		end
	end)
end

local DRAG_TYPES = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.Touch] = true,
}
local DRAG_CLICK_THRESHOLD = 8
local function connectDrag(inst, onStart, onMove, onDone)
	inst.InputBegan:Connect(function(input)
		if not DRAG_TYPES[input.UserInputType] then return end
		local origin = Vector2.new(mouse.X, mouse.Y)
		local moved  = false
		local moveConn = UserInputService.InputChanged:Connect(function(ch)
			if ch.UserInputType == Enum.UserInputType.MouseMovement
			or ch.UserInputType == Enum.UserInputType.Touch then
				local d = Vector2.new(mouse.X, mouse.Y) - origin
				if not moved and d.Magnitude > DRAG_CLICK_THRESHOLD then
					moved = true
					if onStart then onStart() end
				end
				if moved and onMove then onMove(d) end
			end
		end)
		local endConn
		endConn = UserInputService.InputEnded:Connect(function(ch)
			if ch.UserInputType == input.UserInputType then
				moveConn:Disconnect()
				endConn:Disconnect()
				if onDone then onDone(moved) end
			end
		end)
	end)
end

local function pointIn(inst, p)
	if not inst or not inst.Visible then return false end
	local pos, size = inst.AbsolutePosition, inst.AbsoluteSize
	return p.X >= pos.X and p.X <= pos.X + size.X
	   and p.Y >= pos.Y and p.Y <= pos.Y + size.Y
end

local openHub, closeHub, toggleFull, switchTab, buildTab
local activeTab = 1
local isOpen = false
local unloaded = false

IXA_UI_STATE = IXA_UI_STATE or {}

uiRefs = uiRefs or {}

IXAL_Keys = IXAL_Keys or {}

local gui = new("ScreenGui", {
	Name = GUI_NAME,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 9999,
	IgnoreGuiInset = true,
})
gui.Parent = guiRoot

local toasts = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -18),
	Size = UDim2.fromOffset(320, 260),
	BackgroundTransparency = 1, BorderSizePixel = 0, Parent = gui,
})
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = toasts,
})
local toastOrder = 0
local function toast(msg)
	toastOrder = toastOrder + 1
	local box = new("Frame", {
		ZIndex = 20,
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = C.Glass, BackgroundTransparency = 1,
		LayoutOrder = toastOrder, BorderSizePixel = 0,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = box })
	local stroke = new("UIStroke", { Color = C.Accent, Transparency = 1, Thickness = 1, Parent = box })
	local dot = new("Frame", {
		ZIndex = 21, Active = false,
		Size = UDim2.fromOffset(8, 8),
		Position = UDim2.new(0, 12, 0.5, -4),
		BackgroundColor3 = C.On, BackgroundTransparency = 1,
		BorderSizePixel = 0, Parent = box,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
	local label = new("TextLabel", {
		ZIndex = 21, Active = false,
		Size = UDim2.new(1, -38, 1, 0),
		Position = UDim2.new(0, 28, 0, 0),
		BackgroundTransparency = 1,
		Text = msg, TextColor3 = C.Text, TextTransparency = 1,
		FontFace = uiMed, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	label.Parent = box
	box.Parent = toasts
	tw(box,    { BackgroundTransparency = 0.06 }, 0.18)
	tw(label,  { TextTransparency = 0 }, 0.18)
	tw(dot,    { BackgroundTransparency = 0 }, 0.18)
	tw(stroke, { Transparency = 0.55 }, 0.18)
	task.delay(1.7, function()
		if not box.Parent then return end
		tw(box,    { BackgroundTransparency = 1 }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		tw(label,  { TextTransparency = 1 }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		tw(dot,    { BackgroundTransparency = 1 }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		tw(stroke, { Transparency = 1 }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.delay(0.35, function() box:Destroy() end)
	end)
end

local W, H = 820, 470
IXA_FitViewport = function()
	local v = vp()
	if v.X < 50 or v.Y < 50 then return end
	W = math.clamp(v.X - 28, 440, 820)
	H = math.clamp(v.Y - 52, 240, 470)
end
IXA_FitViewport()
local ISLAND_W   = 468
local ISLAND_H   = 34
local ISLAND_TOP = 14
local islandOffset = Vector2.new(0, 0)
local function islandPos()
	return UDim2.new(0.5, -ISLAND_W / 2 + islandOffset.X, 0, ISLAND_TOP + islandOffset.Y)
end
local function normPos() return UDim2.new(0.5, 0, 0, 40) end
local function normSize() return UDim2.fromOffset(W, H) end
local function fullSizeFit()
	local v = vp()
	local scale = math.min(FULL_SCALE, (v.X - 24) / W, (v.Y - 24) / H)
	scale = math.max(1.05, scale)
	local nw = math.min(W * scale, v.X - 16)
	local nh = math.min(H * scale, v.Y - 16)
	return nw, nh
end

local ISLAND_BG = Color3.fromRGB(17, 18, 20)

local LIVE = { fps = 0, ping = nil }

local islandEntrance = function() end

local island = new("Frame", {
	Name = "Island",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = islandPos(),
	Size = UDim2.fromOffset(ISLAND_W, ISLAND_H),
	BackgroundTransparency = 1, BorderSizePixel = 0,
	Visible = false, Parent = gui,
})

local islandVisual = new("Frame", {
	Name = "IslandVisual",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = ISLAND_BG,
	BackgroundTransparency = 0.28,
	BorderSizePixel = 0, Parent = island,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = islandVisual })

local glassTop = new("Frame", {
	Name = "GlassTop",
	Size = UDim2.new(1, 0, 0.55, 0),
	Position = UDim2.new(0, 0, 0, 0),
	BackgroundColor3 = Color3.fromRGB(190, 190, 200),
	BackgroundTransparency = 0.94,
	BorderSizePixel = 0, ZIndex = 2, Parent = islandVisual,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = glassTop })
new("UIGradient", {
	Rotation = 90,
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	}),
	Parent = glassTop,
})

local glassBottom = new("Frame", {
	Name = "GlassBottom",
	Size = UDim2.new(1, 0, 0.35, 0),
	Position = UDim2.new(0, 0, 0.65, 0),
	BackgroundColor3 = Color3.fromRGB(125, 122, 132),
	BackgroundTransparency = 0.95,
	BorderSizePixel = 0, ZIndex = 2, Parent = islandVisual,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = glassBottom })

local stretch = { x = 0, y = 0, tx = 0, ty = 0 }
local function pushStretch(dx, dy)
	stretch.tx = math.clamp(stretch.tx + dx * 0.9, -40, 40)
	stretch.ty = math.clamp(stretch.ty + dy * 0.9, -40, 40)
end

local islandGlow = new("UIStroke", {
	Color = C.On,
	Transparency = 0.5, Thickness = 1.25,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = islandVisual,
})
local islandScale = new("UIScale", { Scale = 1, Parent = islandVisual })

local logoHolder = new("Frame", {
	Active = false,
	Size = UDim2.fromOffset(40, 26),
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 6, 0.5, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	ZIndex = 3, Parent = islandVisual,
})

local logoIcon = new("ImageLabel", {
	Name = "CometIcon",
	BackgroundTransparency = 1, BorderSizePixel = 0,
	Image = COMET_ID,
	Size = UDim2.fromOffset(46, 30),
	Position = UDim2.fromOffset(-46, -30),
	ScaleType = Enum.ScaleType.Fit,
	ImageColor3 = Color3.fromRGB(255, 255, 255),
	ImageTransparency = 1,
	ZIndex = 4, Parent = logoHolder,
})

local cometGlow = new("ImageLabel", {
	Name = "CometGlow",
	BackgroundTransparency = 1, BorderSizePixel = 0,
	Image = COMET_ID,
	Size = UDim2.fromOffset(52, 34),
	Position = UDim2.fromOffset(-49, -32),
	ScaleType = Enum.ScaleType.Fit,
	ImageColor3 = Color3.fromRGB(155, 121, 214),
	ImageTransparency = 1,
	ZIndex = 3, Parent = logoHolder,
})

local cometTrail = {}
local cometTrailSamples = {}
for i = 1, 3 do
	cometTrail[i] = new("ImageLabel", {
		Name = "CometTrail" .. i,
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Image = COMET_ID,
		Size = UDim2.fromOffset(46, 30),
		Position = UDim2.fromOffset(-46, -30),
		ScaleType = Enum.ScaleType.Fit,
		ImageColor3 = Color3.fromRGB(186, 165, 225),
		ImageTransparency = 1,
		ZIndex = 3, Parent = logoHolder,
	})
end

local cometAnimToken = 0
local cometAnimating = false
local function strikeComet()
	if cometAnimating or unloaded or not logoIcon.Parent or isOpen or not island.Visible then return end
	cometAnimating = true
	cometAnimToken += 1
	local token = cometAnimToken

	task.spawn(function()
		local function hideComet()
			logoIcon.ImageTransparency = 1
			cometGlow.ImageTransparency = 1
			for _, trail in ipairs(cometTrail) do trail.ImageTransparency = 1 end
		end

		local function cancelled()
			if token ~= cometAnimToken or unloaded or not logoIcon.Parent or isOpen or not island.Visible then
				hideComet()
				cometAnimating = false
				return true
			end
			return false
		end

		table.clear(cometTrailSamples)
		local startX, startY = -46, -30
		local endX, endY = -3, -2
		logoIcon.Position = UDim2.fromOffset(startX, startY)
		cometGlow.Position = UDim2.fromOffset(startX - 3, startY - 2)
		hideComet()

		local duration = 4.2
		local startT = os.clock()
		local sampleClock = 0
		local function ease(k)
			return 0.5 - 0.5 * math.cos(math.pi * k)
		end

		while true do
			if cancelled() then return end
			local k = math.clamp((os.clock() - startT) / duration, 0, 1)
			local eased = ease(k)
			local x = startX + (endX - startX) * eased
			local y = startY + (endY - startY) * eased

			local fadeIn = ease(math.clamp(k / 0.5, 0, 1))
			local fadeOut = ease(math.clamp((1 - k) / 0.12, 0, 1))
			local opacity = math.min(fadeIn, fadeOut)

			logoIcon.Position = UDim2.fromOffset(x, y)
			logoIcon.ImageTransparency = 1 - opacity
			cometGlow.Position = UDim2.fromOffset(x - 3, y - 2)
			cometGlow.ImageTransparency = 1 - opacity * 0.46

			local dt = RunService.Heartbeat:Wait()
			sampleClock += dt
			if sampleClock >= 0.075 then
				sampleClock -= 0.075
				table.insert(cometTrailSamples, { x = x, y = y })
				if #cometTrailSamples > 30 then table.remove(cometTrailSamples, 1) end
			end

			for i, trail in ipairs(cometTrail) do
				local sample = cometTrailSamples[#cometTrailSamples - i * 4]
				if sample then
					trail.Position = UDim2.fromOffset(sample.x, sample.y)
					local strength = 0.38 - (i - 1) * 0.09
					trail.ImageTransparency = 1 - opacity * strength
				else
					trail.ImageTransparency = 1
				end
			end

			if k >= 1 then break end
		end

		if token == cometAnimToken then
			hideComet()
			logoIcon.Position = UDim2.fromOffset(startX, startY)
			cometGlow.Position = UDim2.fromOffset(startX - 3, startY - 2)
			table.clear(cometTrailSamples)
		end
		cometAnimating = false
	end)
end

task.delay(0.35, function() strikeComet() end)
task.spawn(function()
	while gui.Parent and not unloaded do
		task.wait(math.random(85, 115) / 10)
		if not unloaded and logoHolder.Parent and not isOpen and island.Visible then strikeComet() end
	end
end)

local lastHoverComet = 0
island.MouseEnter:Connect(function()
	local now = os.clock()
	if now - lastHoverComet < 2 then return end
	lastHoverComet = now
	strikeComet()
end)

local islandLabel = new("TextLabel", {
	Active = false,
	Size = UDim2.new(0, 64, 1, 0),
	Position = UDim2.new(0, 48, 0, 0),
	BackgroundTransparency = 1,
	Text = HUB_TITLE,
	TextColor3 = C.Text,
	FontFace = uiBold, TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 3, Parent = islandVisual,
})

local islandFadeables = {
	{ islandVisual, "BackgroundTransparency", 0.28 },
	{ glassTop,     "BackgroundTransparency", 0.94 },
	{ glassBottom,  "BackgroundTransparency", 0.95 },
	{ islandGlow,   "Transparency",           0.5  },
	{ islandLabel,  "TextTransparency",       0    },
}
local function regFade(inst, prop, rest)
	table.insert(islandFadeables, { inst, prop, rest })
end

local function segDivider(x)
	local d = new("Frame", {
		Active = false,
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(1, 13),
		Position = UDim2.new(0, x, 0.5, 0),
		BackgroundColor3 = C.White, BackgroundTransparency = 0.82,
		BorderSizePixel = 0, ZIndex = 3, Parent = islandVisual,
	})
	regFade(d, "BackgroundTransparency", 0.82)
	return d
end

local function makeSeg(x, icon, valW, cap, capW)
	local ic = new("TextLabel", {
		Active = false,
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(13, 13),
		Position = UDim2.new(0, x, 0.5, 0),
		BackgroundTransparency = 1,
		Text = "", TextSize = 13,
		FontFace = NL_ICON_REGULAR, TextColor3 = C.Accent,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 4, Parent = islandVisual,
	})
	setIcon(ic, icon, C.Accent)
	regFade(ic, "TextTransparency", 0)
	local val = new("TextLabel", {
		Active = false,
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(valW, 15),
		Position = UDim2.new(0, x + 16, 0.5, -1),
		BackgroundTransparency = 1,
		Text = "--", TextColor3 = C.Text,
		FontFace = uiBold, TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4, Parent = islandVisual,
	})
	regFade(val, "TextTransparency", 0)
	local capL = new("TextLabel", {
		Active = false,
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(capW, 12),
		Position = UDim2.new(0, x + 16 + valW + 3, 0.5, 0),
		BackgroundTransparency = 1,
		Text = cap, TextColor3 = C.Dim,
		FontFace = uiMed, TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4, Parent = islandVisual,
	})
	regFade(capL, "TextTransparency", 0)
	return val
end

segDivider(118)
local segFpsVal  = makeSeg(124, "chart-line", 30, "FPS", 24)
segDivider(203)
local segPlVal   = makeSeg(209, "person", 36, "PLAYERS", 48)
segDivider(318)
local segPingVal = makeSeg(324, "wifi", 30, "MS", 20)

local keyChip = new("Frame", {
	Active = false,
	AnchorPoint = Vector2.new(0, 0.5),
	Size = UDim2.fromOffset(58, 18),
	Position = UDim2.new(0, 404, 0.5, 0),
	BackgroundColor3 = C.On, BackgroundTransparency = 0.82,
	BorderSizePixel = 0, ZIndex = 3, Parent = islandVisual,
})
new("UICorner", { CornerRadius = UDim.new(0, 5), Parent = keyChip })
regFade(keyChip, "BackgroundTransparency", 0.82)
local keyChipText = new("TextLabel", {
	Active = false,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = "RShift", TextColor3 = C.Lamp,
	FontFace = uiBold, TextSize = 9.5,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
	ZIndex = 4, Parent = keyChip,
})
regFade(keyChipText, "TextTransparency", 0.1)

local BlurPart = Instance.new("Part")
BlurPart.Name = "IXA_IslandBlur"
BlurPart.Material = Enum.Material.Glass
BlurPart.Transparency = 1
BlurPart.Reflectance = 0
BlurPart.CastShadow = false
BlurPart.Anchored = true
BlurPart.CanCollide = false
BlurPart.CanQuery = false
BlurPart.CanTouch = false
BlurPart.Size = Vector3.new(1, 1, 1) * 0.01
BlurPart.Color = Color3.fromRGB(0, 0, 0)
BlurPart.LocalTransparencyModifier = 1
local BlurMesh = Instance.new("BlockMesh")
BlurMesh.Parent = BlurPart

local BlurFX = Instance.new("DepthOfFieldEffect", Lighting)
BlurFX.Enabled = true
BlurFX.FarIntensity = 0
BlurFX.FocusDistance = 0
BlurFX.InFocusRadius = 1000
BlurFX.NearIntensity = 0
BlurFX.Name = "IXA_IslandBlurFX"

local BlurTarget = 0
local BlurCurrent = 0

local function UpdateIslandBlur()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local viewport = camera.ViewportSize
	if viewport.X <= 0 or viewport.Y <= 0 then return end
	local pos = island.AbsolutePosition
	local size = island.AbsoluteSize
	local inset = GuiService:GetGuiInset()
	local distance = 0.05 - camera.NearPlaneZ
	local aspect = viewport.X / viewport.Y
	local tanY = math.tan(math.rad(camera.FieldOfView) / 2)
	local tanX = tanY * aspect
	local function toWorld(x, y)
		local nx = ((x + inset.X) / viewport.X) * 2 - 1
		local ny = 1 - ((y + inset.Y) / viewport.Y) * 2
		return Vector3.new(nx * tanX * distance, ny * tanY * distance, -distance)
	end
	local p0 = toWorld(pos.X, pos.Y)
	local p1 = toWorld(pos.X + size.X, pos.Y + size.Y)
	local center = (p0 + p1) / 2
	local dims = p1 - p0
	BlurMesh.Offset = center
	BlurMesh.Scale = Vector3.new(math.abs(dims.X), math.abs(dims.Y), 0) / 0.0101
	BlurPart.CFrame = CFrame.fromMatrix(camera.CFrame.Position, camera.CFrame.RightVector, camera.CFrame.UpVector)
end

RunService.RenderStepped:Connect(function(dt)
	if unloaded then return end
	local alpha = math.min(1, dt * 6)
	BlurCurrent += (BlurTarget - BlurCurrent) * alpha
	BlurFX.NearIntensity = BlurCurrent
	if BlurCurrent > 0.001 then
		if BlurPart.Parent ~= workspace.CurrentCamera then
			BlurPart.Parent = workspace.CurrentCamera
		end
		pcall(UpdateIslandBlur)
	else
		BlurPart.Parent = nil
	end
end)

island:GetPropertyChangedSignal("AbsolutePosition"):Connect(function() pcall(UpdateIslandBlur) end)
island:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() pcall(UpdateIslandBlur) end)
cam:GetPropertyChangedSignal("ViewportSize"):Connect(function() pcall(UpdateIslandBlur) end)
player.CharacterAdded:Connect(function()
	task.wait(0.5)
	if BlurCurrent > 0.001 then BlurPart.Parent = workspace.CurrentCamera end
end)

local function clampIslandOffset(off)
	local v = vp()
	local maxX = math.max(0, v.X / 2 - ISLAND_W / 2 - 8)
	local minY = 8 - ISLAND_TOP
	local maxY = math.max(minY, v.Y - ISLAND_H - 8 - ISLAND_TOP)
	return Vector2.new(math.clamp(off.X, -maxX, maxX), math.clamp(off.Y, minY, maxY))
end

local islandDrag = {
	active = false,
	origin = Vector2.new(0, 0),
	target = islandOffset,
	current = islandOffset,
}

local window = new("Frame", {
	Name = "Window",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = islandPos(),
	Size = UDim2.fromOffset(ISLAND_W, ISLAND_H),
	BackgroundColor3 = C.Window, BackgroundTransparency = 0.15,
	BorderSizePixel = 0, Visible = false, Parent = gui,
})
local winCorner = new("UICorner", { CornerRadius = UDim.new(0, 22), Parent = window })
local winStroke = new("UIStroke", {
	Color = C.White, Transparency = 0.6, Thickness = 1.2,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = window,
})
new("UIGradient", {
	Rotation = 65,
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C.Accent),
		ColorSequenceKeypoint.new(0.45, Color3.fromRGB(177, 164, 200)),
		ColorSequenceKeypoint.new(1, C.White),
	}),
	Parent = winStroke,
})

local bg = new("ImageLabel", {
	Active = false,
	Size = UDim2.new(1, 0, 1, 0),
	Image = "", ScaleType = Enum.ScaleType.Crop,
	ImageTransparency = 1, BackgroundColor3 = C.Window,
	BackgroundTransparency = 0, BorderSizePixel = 0, Parent = window,
})
new("UICorner", { CornerRadius = UDim.new(0, 22), Parent = bg })

local overlay = new("Frame", {
	Active = false,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = C.Window, BackgroundTransparency = 1,
	BorderSizePixel = 0, Parent = window,
})
new("UICorner", { CornerRadius = UDim.new(0, 22), Parent = overlay })

local chrome = new("CanvasGroup", {
	Name = "Chrome",
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Visible = false, BorderSizePixel = 0, Parent = window,
})

local header = new("Frame", {
	Name = "Header",
	Size = UDim2.new(1, -16, 0, 56),
	Position = UDim2.new(0, 8, 0, 6),
	BackgroundTransparency = 1, Active = true,
	BorderSizePixel = 0, Parent = chrome,
})

local headAvaRing = new("Frame", {
	Active = false,
	Size = UDim2.fromOffset(38, 38),
	Position = UDim2.new(0, 14, 0.5, -19),
	BackgroundTransparency = 1, BorderSizePixel = 0, Parent = header,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = headAvaRing })
local headRingStroke = new("UIStroke", {
	Color = C.Accent, Transparency = 0.2, Thickness = 1.5,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = headAvaRing,
})
local headRingGrad = new("UIGradient", {
	Color = ColorSequence.new(C.Accent, C.On), Parent = headRingStroke,
})
task.spawn(function()
	while headRingGrad and headRingGrad.Parent do
		headRingGrad.Rotation = (tick() * 60) % 360
		task.wait()
	end
end)
local headAva = new("ImageLabel", {
	Active = false,
	Size = UDim2.new(1, -4, 1, -4),
	Position = UDim2.new(0, 2, 0, 2),
	Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(player.UserId) .. "&w=150&h=150",
	BackgroundColor3 = C.Glass, BackgroundTransparency = 0,
	BorderSizePixel = 0, Parent = headAvaRing,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = headAva })

new("TextLabel", {
	Active = false,
	Size = UDim2.new(0, 220, 0, 20),
	Position = UDim2.new(0, 62, 0, 10),
	BackgroundTransparency = 1,
	Text = HUB_TITLE, TextColor3 = C.Text,
	FontFace = uiBold, TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
})
new("TextLabel", {
	Active = false,
	Size = UDim2.new(0, 220, 0, 16),
	Position = UDim2.new(0, 62, 0, 28),
	BackgroundTransparency = 1,
	Text = HUB_SUBTITLE, TextColor3 = C.Dim,
	FontFace = uiReg, TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
})

local function makeChip(text, xFromRight)
	local chip = new("Frame", {
		Active = false,
		Size = UDim2.fromOffset(78, 24),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, xFromRight, 0, 10),
		BackgroundColor3 = C.Glass, BackgroundTransparency = 0.35,
		BorderSizePixel = 0, Parent = header,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = chip })
	local dot = new("Frame", {
		Active = false,
		Size = UDim2.fromOffset(6, 6),
		Position = UDim2.new(0, 8, 0.5, -3),
		BackgroundColor3 = C.Lamp, BorderSizePixel = 0, Parent = chip,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
	local lbl = new("TextLabel", {
		Active = false,
		Size = UDim2.new(1, -22, 1, 0),
		Position = UDim2.new(0, 18, 0, 0),
		BackgroundTransparency = 1,
		Text = text, TextColor3 = C.Dim,
		FontFace = uiMed, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = chip,
	})
	lbl:SetAttribute("IXA_Role", "Dim")
	return chip, lbl
end
local _pingChip, pingLbl = makeChip("PING --", -290)
local _fpsChip,  fpsLbl  = makeChip("FPS --",  -204)
local _plChip,   plLbl   = makeChip("PL --",   -118)

task.spawn(function()
	while gui.Parent and not unloaded do
		local ok, ping = pcall(function()
			return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		if ok and type(ping) == "number" then
			LIVE.ping = math.floor(ping + 0.5)
			pingLbl.Text = "PING " .. LIVE.ping
		else
			LIVE.ping = nil
			pingLbl.Text = "PING --"
		end
		plLbl.Text = "PL " .. #Players:GetPlayers()
		task.wait(1)
	end
end)

do
	local fpsAccum, fpsFrames = 0, 0
	RunService.Heartbeat:Connect(function(dt)
		if unloaded then return end
		fpsAccum += dt
		fpsFrames += 1
		if fpsAccum >= 0.5 then
			LIVE.fps = math.floor(fpsFrames / fpsAccum + 0.5)
			fpsLbl.Text = "FPS " .. LIVE.fps
			fpsAccum, fpsFrames = 0, 0
		end
	end)
end

task.spawn(function()
	while gui.Parent and not unloaded do
		segFpsVal.Text  = LIVE.fps > 0 and tostring(LIVE.fps) or "--"
		segPlVal.Text   = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
		segPingVal.Text = LIVE.ping and tostring(LIVE.ping) or "--"
		task.wait(0.5)
	end
end)

local iconBar = new("Frame", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -6, 0, 10),
	Size = UDim2.fromOffset(96, 26),
	BorderSizePixel = 0, Parent = header,
})
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 8),
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Parent = iconBar,
})

local function iconButton(kind, cb)
	local btn = new("TextButton", {
		ZIndex = 3,
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = C.Glass, BackgroundTransparency = 0.35,
		AutoButtonColor = false, Text = "", BorderSizePixel = 0,
		Parent = iconBar,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btn })
	local img = new("TextLabel", {
		Active = false,
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1,
		Text = "", TextScaled = false, TextSize = 14,
		FontFace = NL_ICON_REGULAR, TextColor3 = C.Text,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = btn,
	})
	local names = { min = "minus", max = "dual-arrows-to-corners", close = "x" }
	setIcon(img, names[kind], C.Text)

	btn.MouseEnter:Connect(function()
		tw(btn, { BackgroundTransparency = 0.05, BackgroundColor3 = (kind == "close") and C.On or C.Glass }, 0.15)
	end)
	btn.MouseLeave:Connect(function()
		tw(btn, { BackgroundTransparency = 0.35, BackgroundColor3 = C.Glass }, 0.15)
	end)
	btn.MouseButton1Down:Connect(function() tw(btn, { Size = UDim2.fromOffset(22, 22) }, 0.08) end)
	btn.MouseButton1Up:Connect(function()   tw(btn, { Size = UDim2.fromOffset(26, 26) }, 0.12) end)
	tap(btn, cb)
	return btn
end

iconButton("min", function() closeHub() end)
iconButton("max", function() toggleFull() end)
iconButton("close", function()
	if unloaded then return end
	unloaded = true
	UserInputService.MouseIconEnabled = true
	toast("Ixa Hub unloaded")
	task.delay(0.45, function()
		if gui and gui.Parent then gui:Destroy() end
	end)
end)

local TAB_ICON = {
	Main="house",
	Controls="settings", Settings="settings", Config="save", Demo="star",
	Example="eye", Menu="gear", Info="magnifying-glass", Tools="wrench",
}

local sidebar = new("ScrollingFrame", {
	Name = "Sidebar",
	Size = UDim2.new(0, 150, 1, -80),
	Position = UDim2.new(0, 14, 0, 66),
	BackgroundTransparency = 1, BorderSizePixel = 0,
	ScrollBarThickness = 2, ScrollBarImageColor3 = C.On,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ElasticBehavior = Enum.ElasticBehavior.Never,
	Parent = chrome,
})
new("UIListLayout", {
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = sidebar,
})

local tabButtons = {}
local function makeTabButton(name, order, index)
	local b = new("TextButton", {
		Size = UDim2.new(1, -4, 0, 36),
		LayoutOrder = order,
		BackgroundColor3 = C.Glass, BackgroundTransparency = 0.55,
		Text = "", AutoButtonColor = false, BorderSizePixel = 0,
		Parent = sidebar,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = b })
	local ind = new("Frame", {
		Name = "Ind", Active = false,
		Size = UDim2.new(0, 3, 0.55, 0),
		Position = UDim2.new(0, 0, 0.225, 0),
		BackgroundColor3 = C.On, BackgroundTransparency = 1,
		BorderSizePixel = 0, Parent = b,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ind })
	local iconImg = new("TextLabel", {
		Active = false,
		Size = UDim2.fromOffset(18, 18),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		BackgroundTransparency = 1,
		Text = "", TextScaled = false, TextSize = 16,
		FontFace = NL_ICON_REGULAR, TextColor3 = C.Dim,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = b,
	})
	setIcon(iconImg, TAB_ICON[name], C.Dim)
	local lbl = new("TextLabel", {
		Name = "Lbl", Active = false,
		Size = UDim2.new(1, -46, 1, 0),
		Position = UDim2.new(0, 40, 0, 0),
		BackgroundTransparency = 1,
		Text = name, TextColor3 = C.Dim,
		FontFace = uiBold, TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = b,
	})
	lbl:SetAttribute("IXA_L10N", "TabName")
	lbl:SetAttribute("IXA_En", name)
	b.MouseEnter:Connect(function()
		if index ~= activeTab then tw(b, { BackgroundTransparency = 0.4 }, T.fast) end
	end)
	b.MouseLeave:Connect(function()
		if index ~= activeTab then tw(b, { BackgroundTransparency = 0.55 }, T.fast) end
	end)
	tap(b, function() switchTab(index) end)
	tabButtons[index] = { btn = b, img = iconImg, ind = ind, lbl = lbl }
	return b
end

local contentHolder = new("Frame", {
	Name = "ContentHolder",
	Size = UDim2.new(1, -188, 1, -80),
	Position = UDim2.new(0, 174, 0, 66),
	BackgroundColor3 = C.Glass, BackgroundTransparency = 0.55,
	BorderSizePixel = 0, Parent = chrome,
})
new("UICorner", { CornerRadius = UDim.new(0, 14), Parent = contentHolder })

local content = new("ScrollingFrame", {
	Name = "Content",
	Size = UDim2.new(1, -20, 1, -20),
	Position = UDim2.new(0, 10, 0, 10),
	BackgroundTransparency = 1, BorderSizePixel = 0,
	ScrollBarThickness = 3, ScrollBarImageColor3 = C.On,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	Parent = contentHolder,
})
new("UIPadding", {
	PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 10),
	Parent = content,
})
local contentLayout = new("UIListLayout", {
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = content,
})
local extraCanvas = 0
local function updateCanvas()
	content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 16 + extraCanvas)
end
contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

local function makeToggle(parent, state, onChange)
	local track = new("Frame", {
		Size = UDim2.fromOffset(46, 26),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -4, 0.5, 0),
		BackgroundColor3 = state and C.On or C.White,
		BackgroundTransparency = state and 0.04 or 0.74,
		BorderSizePixel = 0, Parent = parent,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
	local knob = new("Frame", {
		Active = false,
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(state and 1 or 0, state and -24 or 3, 0.5, -10),
		BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = track,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
	local function set(v, silent)
		state = v
		cancelTweens(track)
		track.BackgroundColor3 = v and C.On or C.White
		track.BackgroundTransparency = v and 0.04 or 0.74
		track:SetAttribute("bBT", track.BackgroundTransparency)
		if not silent then
			tw(knob, { Position = UDim2.new(v and 1 or 0, v and -24 or 3, 0.5, -10) },
				T.fast, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		else
			knob.Position = UDim2.new(v and 1 or 0, v and -24 or 3, 0.5, -10)
		end
		if onChange and not silent then onChange(v) end
	end
	tap(track, function() set(not state) end)
	local api = {}
	function api:SetVisual(v)
		cancelTweens(track)
		track.BackgroundColor3 = v and C.On or C.White
		track.BackgroundTransparency = v and 0.04 or 0.74
		track:SetAttribute("bBT", track.BackgroundTransparency)
		knob.Position = UDim2.new(v and 1 or 0, v and -24 or 3, 0.5, -10)
	end
	function api:SetValue(v, silent) set(v == true, silent) end
	function api:GetValue() return state end
	return api
end

local function makeSlider(parent, minValue, maxValue, value, onChange, accent)
	local acc = accent or C.White
	local box = new("Frame", {
		Size = UDim2.fromOffset(190, 28),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -4, 0.5, 0),
		BackgroundTransparency = 1, BorderSizePixel = 0, Parent = parent,
	})
	local label = new("TextLabel", {
		Active = false,
		Size = UDim2.fromOffset(52, 16),
		Position = UDim2.new(0, 0, 0.5, -8),
		BackgroundTransparency = 1,
		Text = tostring(round(value)),
		TextColor3 = C.Text, FontFace = uiMed, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = box,
	})
	local track = new("Frame", {
		Size = UDim2.new(1, -60, 0, 4),
		Position = UDim2.new(0, 58, 0.5, -2),
		BackgroundColor3 = C.White, BackgroundTransparency = 0.62,
		BorderSizePixel = 0, Parent = box,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
	local fill = new("Frame", {
		Active = false,
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = acc, BackgroundTransparency = 0.05,
		BorderSizePixel = 0, Parent = track,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
	local knob = new("Frame", {
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = track,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
	local function repaint(v)
		local range = math.max(1, maxValue - minValue)
		local rel = math.clamp((v - minValue) / range, 0, 1)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, 0, 0.5, 0)
		label.Text = tostring(round(v))
	end
	repaint(value)
	local function fromX(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
		local v = minValue + rel * (maxValue - minValue)
		if math.abs(v - value) > 0.001 then
			value = v
			repaint(value)
			if onChange then onChange(round(value)) end
		end
	end
	local function beginSlide(input)
		fromX(mouse.X)
		tw(knob, { Size = UDim2.fromOffset(20, 20) }, T.fast)
		local moveConn = UserInputService.InputChanged:Connect(function(ch)
			if ch.UserInputType == Enum.UserInputType.MouseMovement
			or ch.UserInputType == Enum.UserInputType.Touch then
				fromX(mouse.X)
			end
		end)
		local endConn
		endConn = UserInputService.InputEnded:Connect(function(ch)
			if ch.UserInputType == input.UserInputType then
				moveConn:Disconnect()
				endConn:Disconnect()
				if knob.Parent then
					tw(knob, { Size = UDim2.fromOffset(16, 16) }, T.fast,
						Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				end
			end
		end)
	end
	knob.InputBegan:Connect(function(input)
		if DRAG_TYPES[input.UserInputType] then beginSlide(input) end
	end)
	track.InputBegan:Connect(function(input)
		if DRAG_TYPES[input.UserInputType] then beginSlide(input) end
	end)
	return box
end

local openMenus = {}
UserInputService.InputBegan:Connect(function(input)
	if not DRAG_TYPES[input.UserInputType] then return end
	if #openMenus == 0 then return end
	local p = Vector2.new(mouse.X, mouse.Y)
	for i = #openMenus, 1, -1 do
		local m = openMenus[i]
		if not pointIn(m.menu, p) and not pointIn(m.pill, p) then m.close() end
	end
end)

local function makeDropdown(parent, options, current, onChange)
	local row = parent.Parent
	local pill = new("TextButton", {
		Size = UDim2.fromOffset(160, 28),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -4, 0.5, 0),
		BackgroundColor3 = C.White, BackgroundTransparency = 0.8,
		Text = "  " .. current, TextColor3 = C.Text,
		FontFace = uiMed, TextSize = 13, AutoButtonColor = false,
		BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = parent,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 9), Parent = pill })
	new("UIStroke", { Color = C.White, Transparency = 0.65, Thickness = 1, Parent = pill })
	new("TextLabel", {
		Active = false,
		Size = UDim2.fromOffset(16, 28),
		Position = UDim2.new(1, -16, 0, 0),
		BackgroundTransparency = 1,
		Text = "v", TextColor3 = C.Dim,
		FontFace = uiMed, TextSize = 11, Parent = pill,
	})
	local menuFullH = #options * 27 + 8
	local menuH = math.min(menuFullH, 170)
	local menu = new("ScrollingFrame", {
		ZIndex = 10,
		Size = UDim2.fromOffset(172, menuH),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 1, 6),
		BackgroundColor3 = C.Window, BackgroundTransparency = 0.02,
		BorderSizePixel = 0, ScrollBarThickness = 4,
		ScrollBarImageColor3 = C.Accent,
		CanvasSize = UDim2.new(0, 0, 0, menuFullH),
		Visible = false, Parent = pill,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = menu })
	new("UIStroke", { Color = C.White, Transparency = 0.55, Thickness = 1, Parent = menu })
	new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = menu })
	new("UIPadding", {
		PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = menu,
	})
	local isOpenMenu = false
	local consumeClick = false
	local myEntry = { pill = pill, menu = menu }
	local function setMenu(v)
		if isOpenMenu == v then return end
		isOpenMenu = v
		if v then
			for i = #openMenus, 1, -1 do
				if openMenus[i] ~= myEntry then openMenus[i].close() end
			end
			table.insert(openMenus, myEntry)
			extraCanvas = extraCanvas + 170
			if row then row.ZIndex = 6 end
			menu.Visible = true
			groupFadeSet(menu, 1)
			groupFade(menu, 0, 0.16)
		else
			for i = #openMenus, 1, -1 do
				if openMenus[i] == myEntry then table.remove(openMenus, i) end
			end
			extraCanvas = math.max(0, extraCanvas - 170)
			if row then row.ZIndex = 1 end
			groupFade(menu, 1, 0.12)
			task.delay(0.14, function()
				if not isOpenMenu then menu.Visible = false end
			end)
		end
		updateCanvas()
	end
	myEntry.close = function() setMenu(false) end
	for i, opt in ipairs(options) do
		local b = new("TextButton", {
			ZIndex = 11,
			Size = UDim2.new(1, 0, 0, 23),
			LayoutOrder = i,
			BackgroundColor3 = C.White,
			BackgroundTransparency = opt == current and 0.68 or 0.9,
			Text = "  " .. opt, TextColor3 = C.Text,
			FontFace = uiMed, TextSize = 12, AutoButtonColor = false,
			BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left,
			Parent = menu,
		})
		new("UICorner", { CornerRadius = UDim.new(0, 7), Parent = b })
		b.MouseEnter:Connect(function() tw(b, { BackgroundTransparency = 0.68 }, 0.1) end)
		b.MouseLeave:Connect(function() tw(b, { BackgroundTransparency = 0.9 }, 0.1) end)
		tap(b, function()
			consumeClick = true
			current = opt
			pill.Text = "  " .. opt
			setMenu(false)
			if onChange then onChange(opt) end
		end)
	end
	tap(pill, function()
		if consumeClick then consumeClick = false return end
		setMenu(not isOpenMenu)
	end)
	return pill
end

IXA_SearchRows = {}

local function addRow(parent, title, subtitle, buildControl, order)
	local h = 44
	if subtitle ~= nil then h = 54 end
	local row = new("Frame", {
		Name = "Row",
		Size = UDim2.new(1, 0, 0, h),
		LayoutOrder = order or 0,
		BackgroundColor3 = C.Glass, BackgroundTransparency = 0.85,
		BorderSizePixel = 0, Parent = parent,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = row })
	new("UIStroke", {
		Color = C.Accent, Transparency = 1, Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = row,
	})
	local titleY = 11
	if subtitle ~= nil then titleY = 7 end
	local titleLabel = new("TextLabel", {
		Active = false,
		Size = UDim2.new(1, -300, 0, 18),
		Position = UDim2.new(0, 16, 0, titleY),
		BackgroundTransparency = 1,
		Text = title, TextColor3 = C.Text,
		FontFace = uiBold, TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
	})
	titleLabel:SetAttribute("IXA_L10N", "RowTitle")
	titleLabel:SetAttribute("IXA_En", title)
	if subtitle ~= nil then
		local sub = new("TextLabel", {
			Active = false,
			Size = UDim2.new(1, -300, 0, 14),
			Position = UDim2.new(0, 16, 0, 28),
			BackgroundTransparency = 1,
			Text = subtitle, TextColor3 = C.Dim, TextTransparency = 0.25,
			FontFace = uiReg, TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
		})
		sub:SetAttribute("IXA_Role", "Dim")
		sub:SetAttribute("IXA_L10N", "RowSub")
		sub:SetAttribute("IXA_En", subtitle)
	end
	local box = new("Frame", {
		Size = UDim2.new(0, 250, 1, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 0),
		BackgroundTransparency = 1, BorderSizePixel = 0, Parent = row,
	})
	if buildControl ~= nil then buildControl(box) end
	IXA_SearchRows[#IXA_SearchRows + 1] = {
		row = row, tab = activeTab, title = title,
		subtitle = subtitle, order = order or 0,
	}
	row.MouseEnter:Connect(function() tw(row, { BackgroundTransparency = 0.75 }, T.fast) end)
	row.MouseLeave:Connect(function() tw(row, { BackgroundTransparency = 0.85 }, T.fast) end)
	return row
end

local TABS = {}

_G.__IXA_TOAST = toast

local function ixaCall(fn, ...)
	if type(fn) ~= "function" then return nil end
	local result = table.pack(pcall(fn, ...))
	if not result[1] then warn("[IXA] " .. tostring(result[2])) return nil end
	return table.unpack(result, 2, result.n)
end

local function ixaToggle(parent, key, callback)
	local value = IXA_UI_STATE[key] == true
	local api = makeToggle(parent, value, function(nextValue)
		IXA_UI_STATE[key] = nextValue
		ixaCall(callback, nextValue)
	end)
	if key then
		uiRefs[key] = api
		if IXA_UI_STATE[key] == true and api.SetVisual then
			api:SetVisual(true)
		end
	end
	return api
end

local function ixaText(parent, key, defaultValue, callback)
	local input = new("TextBox", {
		Size = UDim2.fromOffset(150, 28),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -4, 0.5, 0),
		BackgroundColor3 = C.White,
		BackgroundTransparency = 0.82,
		TextColor3 = C.Text,
		PlaceholderColor3 = C.Dim,
		Text = tostring(defaultValue or ""),
		PlaceholderText = tostring(defaultValue or ""),
		ClearTextOnFocus = false,
		FontFace = uiMed,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0,
		Parent = parent,
	})
	new("UICorner", {CornerRadius = UDim.new(0, 9), Parent = input})
	new("UIPadding", {PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 6), Parent = input})
	input.FocusLost:Connect(function()
		IXA_UI_STATE[key] = input.Text
		ixaCall(callback, input.Text)
	end)
end

local function ixaDropdown(parent, options, current, callback, stateKey)
	options = options or {}
	if #options == 0 then options = {"None"} end
	local selected = current
	local found = false
	for _, item in ipairs(options) do if item == selected then found = true break end end
	if not found then selected = options[1] end
	makeDropdown(parent, options, selected, function(value)
		if stateKey then IXA_UI_STATE[stateKey] = value end
		ixaCall(callback, value)
	end)
end

local function ixaSlider(parent, minimum, maximum, current, callback, stateKey)
	makeSlider(parent, minimum, maximum, math.clamp(tonumber(current) or minimum, minimum, maximum), function(value)
		if stateKey then IXA_UI_STATE[stateKey] = value end
		ixaCall(callback, value)
	end)
end

local function makeBtn(parent, text, cb, width)
	local btn = new("TextButton", {
		Size = UDim2.fromOffset(width or 74, 28),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -4, 0.5, 0),
		BackgroundColor3 = C.White,
		BackgroundTransparency = 0.8,
		Text = text,
		TextColor3 = C.Text,
		FontFace = uiMed,
		TextSize = 13,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = parent,
	})
	new("UICorner", {CornerRadius = UDim.new(0, 9), Parent = btn})
	btn:SetAttribute("IXA_L10N", "Btn")
	btn:SetAttribute("IXA_En", text)
	tap(btn, cb)
	return btn
end

local function ixaButton(parent, title, callback)
	makeBtn(parent, title, function() ixaCall(callback) end, 150)
end

local function ixaColor(parent, defaultColor, callback)
	local colors = {"Orange", "Pink", "Purple", "Blue", "Green", "White", "Red"}
	local values = {
		Orange = Color3.fromRGB(224, 116, 24), Pink = Color3.fromRGB(255, 90, 160),
		Purple = Color3.fromRGB(170, 90, 255), Blue = Color3.fromRGB(70, 150, 255),
		Green = Color3.fromRGB(70, 220, 140), White = Color3.fromRGB(255, 255, 255),
		Red = Color3.fromRGB(255, 70, 70),
	}
	local chosen = "Orange"
	local best = math.huge
	if typeof(defaultColor) == "Color3" then
		local function cdist(c)
			return math.abs(c.R - defaultColor.R) + math.abs(c.G - defaultColor.G) + math.abs(c.B - defaultColor.B)
		end
		for name, color in pairs(values) do
			local d = cdist(color)
			if d < best then best, chosen = d, name end
		end
	end
	ixaDropdown(parent, colors, chosen, function(name) ixaCall(callback, values[name]) end)
end

IXAL_Locale = "English"
function IXAL_L(key)
	if IXAL_Locale ~= "Russian" then return key end
	return IXAL_Keys[key] or key
end
function IXAL_ApplyTranslations()
	if not gui then return end
	for _, item in ipairs(gui:GetDescendants()) do
		local tag = item:GetAttribute("IXA_L10N")
		if tag then
			if item:IsA("TextLabel") or item:IsA("TextButton") then
				if tag == "Tab" then
					item.Text = "  " .. IXAL_L(item:GetAttribute("IXA_En") or "")
				else
					item.Text = IXAL_L(item:GetAttribute("IXA_En") or "")
				end
			end
		end
	end
end
function IXAL_SetLanguage(lang)
	IXA_UI_STATE.Language = lang
	IXAL_Locale = (lang == "Russian") and "Russian" or "English"
	IXAL_ApplyTranslations()
	if IXA_searchInput and IXA_searchInput.Parent then
		IXA_searchInput.PlaceholderText = IXAL_L("Search features...")
	end
	if IXA_rebuildSuggestions then IXA_rebuildSuggestions() end
end

local function addSubGroup(parent, order, subs)
	local subRows = {}
	local expanded = false

	local expRow = new("Frame", {
		Name = "Row",
		Size = UDim2.new(1, 0, 0, 20),
		LayoutOrder = order,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = parent,
	})
	local exp = new("TextButton", {
		Name = "Expander",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = C.Glass,
		BackgroundTransparency = 0.95,
		Text = "+",
		TextColor3 = C.Accent,
		FontFace = uiBold,
		TextSize = 15,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = expRow,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = exp })
	for i, s in ipairs(subs) do
		local r = addRow(parent, s[1], s[2], s[3], order + i)
		r:SetAttribute("IXA_FullH", r.Size.Y.Offset)
		r.ClipsDescendants = true
		r.Visible = false
		r.Size = UDim2.new(1, 0, 0, 0)
		subRows[i] = r
	end
	tap(exp, function()
		expanded = not expanded
		exp.Text = expanded and "\u{2013}" or "+"
		for _, r in ipairs(subRows) do
			if expanded then
				r.Visible = true
				r.ClipsDescendants = true
				TweenService:Create(r, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Size = UDim2.new(1, 0, 0, r:GetAttribute("IXA_FullH")) }):Play()
				task.delay(0.3, function()

					if expanded and r.Parent then r.ClipsDescendants = false end
				end)
			else
				r.ClipsDescendants = true
				TweenService:Create(r, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{ Size = UDim2.new(1, 0, 0, 0) }):Play()
				task.delay(0.24, function()
					if not expanded and r.Parent then r.Visible = false end
				end)
			end
		end
	end)
	exp.MouseEnter:Connect(function() exp.TextColor3 = C.On end)
	exp.MouseLeave:Connect(function() exp.TextColor3 = C.Accent end)
end

TABS[1] = {name = "Controls", build = function(c)

	addRow(c, "Toggle", "Boolean switch with a saved state", function(b)
		ixaToggle(b, "DemoToggle", function(v)
			toast("Toggle -> " .. tostring(v))
		end)
	end, 1)

	addRow(c, "Slider", "Drag to change a number (0 - 100)", function(b)

		ixaSlider(b, 0, 100, IXA_UI_STATE.DemoSlider or 50, function(v) end, "DemoSlider")
	end, 2)

	addRow(c, "Dropdown", "Pick one option from a list", function(b)
		ixaDropdown(b, { "Option A", "Option B", "Option C" }, IXA_UI_STATE.DemoDropdown or "Option A", function(v)
			toast("Dropdown -> " .. tostring(v))
		end, "DemoDropdown")
	end, 3)

	addRow(c, "Text Input", "Free text, read on focus lost", function(b)
		ixaText(b, "DemoText", IXA_UI_STATE.DemoText or "hello", function(v)
			toast("Text -> " .. tostring(v))
		end)
	end, 4)

	addRow(c, "Button", "Runs a callback on click", function(b)
		ixaButton(b, "Press me", function()
			toast("Button pressed")
		end)
	end, 5)

	addRow(c, "Color", "Preset color picker", function(b)
		ixaColor(b, Color3.fromRGB(255, 186, 44), function(color)
			toast(string.format("Color -> %d, %d, %d", color.R * 255, color.G * 255, color.B * 255))
		end)
	end, 6)

	addSubGroup(c, 7, {
		{ "Grouped Toggle", "Row inside a collapsible group", function(b)
			ixaToggle(b, "DemoGroupToggle", function(v)
				toast("Grouped toggle -> " .. tostring(v))
			end)
		end },
		{ "Grouped Slider", "0 - 10", function(b)
			ixaSlider(b, 0, 10, IXA_UI_STATE.DemoGroupSlider or 5, function(v) end, "DemoGroupSlider")
		end },
		{ "Grouped Dropdown", "One more option list", function(b)
			ixaDropdown(b, { "One", "Two", "Three" }, "One", function(v) end, "DemoGroupDropdown")
		end },
	})

	addRow(c, "Raw Toggle", "makeToggle() without any state handling", function(b)
		makeToggle(b, false, function(v)
			print("[demo] raw toggle:", v)
		end)
	end, 20)

	addRow(c, "Row Without Control", nil, nil, 21)
end}

TABS[2] = {name = "Settings", build = function(c)
	addRow(c, "Language", "Interface label preference", function(b)
		ixaDropdown(b, { "English", "Russian" }, IXA_UI_STATE.Language or "English", function(v)
			IXAL_SetLanguage(v)
		end, "Language")
	end, 1)
	addRow(c, "Menu Key", "Fixed open / close key for the GUI", function(b)
		local fixed = label(b, "RIGHT SHIFT", uiBold, 12, C.Lamp,
			UDim2.new(1, -4, 0.5, 0), UDim2.new(0, 96, 0, 16))
		fixed.AnchorPoint = Vector2.new(1, 0.5)
		fixed.TextXAlignment = Enum.TextXAlignment.Right
	end, 2)
	addRow(c, "Menu Scale", "Base window scale", function(b)
		ixaDropdown(b, { "Small", "Default", "Large" }, IXA_UI_STATE.MenuScale or "Default", function(v)
			IXA_UI_STATE.MenuScale = v
			local scales = { Small = 0.86, Default = 1, Large = 1.14 }
			local scale = scales[v] or 1
			W, H = math.floor(820 * scale), math.floor(470 * scale)
			window.Size = normSize()
		end, "MenuScale")
	end, 3)
	addRow(c, "Menu Transparency", "Visual transparency from 0 to 80 percent", function(b)
		ixaSlider(b, 0, 80, IXA_UI_STATE.MenuTransparency or 0, function(v)

			IXA_UI_STATE.MenuTransparency = v
			if bg then
				bg.ImageTransparency = math.clamp(0.35 + (v / 100) * 0.65, 0.35, 1)
				bg.BackgroundTransparency = math.clamp(0.5 + (v / 100) * 0.5, 0.5, 1)
			end
			if overlay then
				overlay.BackgroundTransparency = math.clamp(0.65 + (v / 100) * 0.35, 0.65, 1)
			end
		end)
	end, 4)
	addRow(c, "Refresh UI", "Rebuild the current tab", function(b)
		ixaButton(b, "Refresh", function() buildTab(activeTab, true) end)
	end, 5)
end}

TABS[3] = {name = "Config", build = function(c)
	addRow(c, "Profile Name", "Saved beside the script", function(b)
		ixaText(b, "ConfigName", IXA_UI_STATE.ConfigName or "default", function(v)
			IXA_UI_STATE.ConfigName = (tostring(v):gsub("[^%w_%-% ]", ""))
			if IXA_UI_STATE.ConfigName == "" then IXA_UI_STATE.ConfigName = "default" end
		end)
	end, 1)
	addRow(c, "Save Profile", "Save the readable settings", function(b)
		ixaButton(b, "Save", function()
			if writefile and HttpService then
				pcall(function()
					writefile("IXA_" .. (IXA_UI_STATE.ConfigName or "default") .. ".json", HttpService:JSONEncode(IXA_UI_STATE))
				end)
				toast("Profile saved")
			else
				toast("File API is unavailable")
			end
		end)
	end, 2)
	addRow(c, "Load Profile", "Load the selected profile", function(b)
		ixaButton(b, "Load", function()
			local path = "IXA_" .. (IXA_UI_STATE.ConfigName or "default") .. ".json"
			if readfile and isfile and isfile(path) then
				local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
				if ok and type(data) == "table" then
					for k, v in pairs(data) do IXA_UI_STATE[k] = v end
					toast("Profile loaded")
				end
			else
				toast("Profile not found")
			end
		end)
	end, 3)
	addRow(c, "Delete Profile", "Delete the selected file", function(b)
		ixaButton(b, "Delete", function()
			local path = "IXA_" .. (IXA_UI_STATE.ConfigName or "default") .. ".json"
			if delfile and isfile and isfile(path) then
				delfile(path)
				toast("Profile deleted")
			else
				toast("Profile not found")
			end
		end)
	end, 4)
end}

local DISCORD_INVITE = "https://discord.gg/ggfPWB6N3t"

local DRAG_INVERTED = false
local DISCORD_MEMBERS_TEXT = "400+ members"
local HUB_VERSION_TAG = "2.4"
local ALL_FEATURES_TAB = 2

local QUICK_LAUNCH = {
	{ name = "Flight",   icon = "arrow-up-from-line", key = "QL_Flight",   onChange = nil },
	{ name = "ESP",      icon = "eye",                key = "QL_ESP",      onChange = nil },
	{ name = "Aimbot",   icon = "crosshairs",         key = "QL_Aimbot",   onChange = nil },
	{ name = "AutoFarm", icon = "flag",               key = "QL_AutoFarm", onChange = nil },
}

local CHANGELOG = {
	{ tag = "NEW",      text = "Main tab with a live preview of your character" },
	{ tag = "NEW",      text = "Discord invite banner with members counter" },
	{ tag = "IMPROVED", text = "Main is now the home tab of the hub" },
}

IXAL_Keys["Main"] = "Главная"
IXAL_Keys["Online now"] = "Сейчас онлайн"
IXAL_Keys["Executions"] = "Запусков"
IXAL_Keys["Uptime"] = "Аптайм"
IXAL_Keys["Welcome back"] = "С возвращением"
IXAL_Keys["Join the IXA HUB Discord"] = "Заходи в Discord IXA HUB"
IXAL_Keys["Updates, giveaways, support & new scripts first."] = "Апдейты, розыгрыши, поддержка и новые скрипты — раньше всех."
IXAL_Keys["Join"] = "Войти"
IXAL_Keys["Quick Launch"] = "Быстрый запуск"
IXAL_Keys["What's New"] = "Что нового"
IXAL_Keys["All features →"] = "Все функции →"
IXAL_Keys["OFF"] = "Выкл"
IXAL_Keys["ON"] = "Вкл"
IXAL_Keys[DISCORD_MEMBERS_TEXT] = "400+ участников"

local MAIN_T0 = os.time()
local EXEC_COUNT = 1
pcall(function()
	if readfile and writefile and isfile then
		if isfile("IXA_executions.txt") then
			EXEC_COUNT = math.max(0, tonumber(readfile("IXA_executions.txt")) or 0) + 1
		end
		writefile("IXA_executions.txt", tostring(EXEC_COUNT))
	end
end)

local GAME_NAME = nil
task.spawn(function()
	local ok, info = pcall(function()
		return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
	end)
	if ok and type(info) == "table" and type(info.Name) == "string" then GAME_NAME = info.Name end
end)

local function mainFmtInt(n)
	local rev = tostring(math.max(0, math.floor(n))):reverse():gsub("(%d%d%d)", "%1 ")
	return rev:reverse():gsub("^ ", "")
end
local function mainFmtK(n)
	if n >= 1e6 then return (string.format("%.1f", n / 1e6):gsub("%.0$", "")) .. "M" end
	if n >= 1000 then return (string.format("%.1f", n / 1000):gsub("%.0$", "")) .. "K" end
	return tostring(math.floor(n))
end
local function mainFmtUptime(sec)
	sec = math.max(0, math.floor(sec))
	local h, m, s = math.floor(sec / 3600), math.floor(sec / 60) % 60, sec % 60
	if h > 0 then return h .. "h " .. m .. "m" end
	if m > 0 then return m .. "m " .. s .. "s" end
	return s .. "s"
end

local function mainShimmer(grad, period)
	local t0 = os.clock()
	task.spawn(function()
		while grad.Parent do
			local t = (os.clock() - t0) / period
			local tri = math.abs((t % 2) - 1)
			grad.Offset = Vector2.new((tri - 0.5) * 0.7, 0)
			task.wait(0.03)
		end
	end)
end

local MAIN_TAB = { name = "Main", build = function(c)
	local function ru() return IXAL_Locale == "Russian" end
	local cleanups = {}
	local function onClose(fn) cleanups[#cleanups + 1] = fn end

	local function cardFrame(order, height, parent)
		local f = new("Frame", {
			Name = "Row", LayoutOrder = order,
			Size = UDim2.new(1, 0, 0, height),
			BackgroundColor3 = C.Glass, BackgroundTransparency = 0.45,
			BorderSizePixel = 0, Parent = parent,
		})
		new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = f })
		return f
	end
	local function label(parent, text, font, size, color, pos, sizeUd)
		return new("TextLabel", {
			Active = false, BackgroundTransparency = 1,
			Position = pos, Size = sizeUd,
			Text = text, FontFace = font, TextSize = size, TextColor3 = color,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = parent,
		})
	end
	local function iconBox(parent, name, color, pos, px)
		local h = new("Frame", {
			Active = false, BackgroundTransparency = 1,
			Position = pos, Size = UDim2.fromOffset(px or 16, px or 16),
			Parent = parent,
		})
		setIcon(h, name, color)

		local ic = h:FindFirstChild("NLIcon")
		if ic then ic.TextSize = px or 16 end
		return h
	end
	local function hoverGlow(f, solidBg)

		local gl = new("Frame", {
			Active = false, BackgroundTransparency = 1,
			Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2),
			BorderSizePixel = 0, Parent = f,
		})
		new("UICorner", { CornerRadius = UDim.new(0, 11), Parent = gl })
		local st = new("UIStroke", { Color = C.On, Transparency = 1, Thickness = 1, Parent = gl })
		f.MouseEnter:Connect(function()
			tw(st, { Transparency = 0.25 }, T.fast)
			if not solidBg then tw(f, { BackgroundTransparency = 0.38 }, T.fast) end
		end)
		f.MouseLeave:Connect(function()
			tw(st, { Transparency = 1 }, T.fast)
			if not solidBg then tw(f, { BackgroundTransparency = 0.45 }, T.fast) end
		end)
	end
	local function clickFlash(b)
		local gl = new("Frame", {
			Active = false, BackgroundTransparency = 1,
			Position = UDim2.new(0, 2, 0, 2), Size = UDim2.new(1, -4, 1, -4),
			BorderSizePixel = 0, Parent = b,
		})
		new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = gl })
		local st = new("UIStroke", { Color = C.On, Transparency = 1, Thickness = 2, Parent = gl })
		local function isPress(i)
			return i.UserInputType == Enum.UserInputType.MouseButton1
				or i.UserInputType == Enum.UserInputType.Touch
		end
		b.InputBegan:Connect(function(i)
			if isPress(i) then tw(st, { Transparency = 0.1 }, 0.06) end
		end)
		b.InputEnded:Connect(function(i)
			if isPress(i) then tw(st, { Transparency = 1 }, 0.28) end
		end)
	end

	local hero = cardFrame(1, 164, c)
	hoverGlow(hero)

	local stage = new("Frame", {
		Active = false, BackgroundTransparency = 1, ClipsDescendants = true,
		Size = UDim2.new(0, 252, 1, 0), Parent = hero,
	})
	local viewport = new("ViewportFrame", {
		Active = false, BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -18), Position = UDim2.new(0, 0, 0, 8),
		AmbientColor = Color3.fromRGB(190, 168, 128),
		LightColor = Color3.fromRGB(255, 255, 255),
		LightDirection = Vector3.new(-0.35, -1, 0.45),
		Parent = stage,
	})
	local world = Instance.new("WorldModel")
	world.Parent = viewport
	local vcam = Instance.new("Camera")
	vcam.FieldOfView = 40
	vcam.Parent = viewport
	viewport.CurrentCamera = vcam

	local PREVIEW_PIVOT = Vector3.new(0, -0.3, 0)
	local PREVIEW_OFFSET = Vector3.new(0, 0.55, 8.8)
	vcam.CFrame = CFrame.lookAt(PREVIEW_PIVOT + PREVIEW_OFFSET, PREVIEW_PIVOT)

	local spin, spinTarget = 0, 0
	local pitch, pitchTarget = 0, 0
	local dragging, lastX, lastY = false, 0, 0
	viewport.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging, lastX, lastY = true, input.Position.X, input.Position.Y
		end
	end)

	local uisMove = UserInputService.InputChanged:Connect(function(input)
		if dragging
		and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local dx = input.Position.X - lastX
			local dy = input.Position.Y - lastY
			lastX, lastY = input.Position.X, input.Position.Y
			local dir = DRAG_INVERTED and -1 or 1

			spinTarget = spinTarget - dx * 0.008 * dir
			pitchTarget = math.clamp(pitchTarget - dy * 0.005 * dir, -1.55, 1.55)
		end
	end)
	onClose(function() uisMove:Disconnect() end)
	local uisEnd = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	onClose(function() uisEnd:Disconnect() end)
	local spinConn
	spinConn = RunService.RenderStepped:Connect(function(dt)
		if not viewport.Parent then spinConn:Disconnect() return end
		local k = math.min(1, dt * 10)
		spin = spin + (spinTarget - spin) * k
		pitch = pitch + (pitchTarget - pitch) * k
		local rot = CFrame.Angles(0, spin, 0) * CFrame.Angles(pitch, 0, 0)
		local pos = PREVIEW_PIVOT + rot:VectorToWorldSpace(PREVIEW_OFFSET)
		vcam.CFrame = CFrame.lookAt(pos, PREVIEW_PIVOT)
	end)
	onClose(function() spinConn:Disconnect() end)

	local cloneHolder = { model = nil }
	local function buildClone(char)
		if not viewport.Parent then return end
		if cloneHolder.model then
			cloneHolder.model:Destroy()
			cloneHolder.model = nil
		end
		if not char or not char.Parent then return end

		pcall(function() char.Archivable = true end)
		local ok, clone = pcall(function() return char:Clone() end)
		if not ok then
			warn("[IXA] character clone failed: " .. tostring(clone))
			return
		end
		if not clone then
			warn("[IXA] character clone returned nil (Archivable blocked?)")
			return
		end
		for _, d in ipairs(clone:GetDescendants()) do
			if d:IsA("LocalScript") or d:IsA("Script") then
				d:Destroy()
			elseif d:IsA("BasePart") then
				d.Anchored = true

				d.LocalTransparencyModifier = 0
			end
		end
		clone.Parent = world

		local root = clone:FindFirstChild("HumanoidRootPart")
			or clone:FindFirstChildOfClass("BasePart")
		if root then

			local face = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.pi, 0)
			local base = face * root.CFrame:Inverse()
			for _, p in ipairs(clone:GetDescendants()) do
				if p:IsA("BasePart") then
					p.CFrame = base * p.CFrame
				end
			end
			pcall(function() clone.PrimaryPart = root end)
		end

		local accessoryFix = {}
		for _, acc in ipairs(clone:GetChildren()) do
			if acc:IsA("Accessory") then
				local handle = acc:FindFirstChild("Handle")
					or acc:FindFirstChildOfClass("BasePart")
				if handle then
					local parentPart = nil
					for _, j in ipairs(clone:GetDescendants()) do
						if j:IsA("Weld") and (j.Part0 == handle or j.Part1 == handle) then
							local other = (j.Part0 == handle) and j.Part1 or j.Part0
							if other and other:IsA("BasePart") and other ~= handle then
								parentPart = other
								break
							end
						end
					end
					if not parentPart then
						parentPart = clone:FindFirstChild("Head")
					end
					if parentPart and parentPart ~= handle then
						accessoryFix[handle] = { parentPart, parentPart.CFrame:Inverse() * handle.CFrame }
					end
				end
			end
		end

		local posed = false
		local hum = clone:FindFirstChildOfClass("Humanoid")
		local desc = nil
		if hum then
			local okDesc
			okDesc, desc = pcall(function() return hum:GetAppliedDescription() end)
			if not (okDesc and desc) then
				desc = Instance.new("HumanoidDescription")
				pcall(function() desc.RigType = hum.RigType end)
			end
			local okRig, rig = pcall(function()
				return Players:CreateHumanoidModelAsync(desc)
			end)
			if okRig and rig then
				local defaults = {}
				for _, j in ipairs(rig:GetDescendants()) do
					if j:IsA("Motor6D") then defaults[j.Name] = { j.C0, j.C1 } end
				end
				for _, j in ipairs(clone:GetDescendants()) do
					local d = j:IsA("Motor6D") and defaults[j.Name]
					if d then
						j.C0, j.C1 = d[1], d[2]
					end
				end
				rig:Destroy()
				posed = true
			else
				warn("[IXA] fresh rig unavailable, joints kept as cloned")
			end
		end

		local poseRoot = clone:FindFirstChild("HumanoidRootPart")
		if poseRoot then
			local jointsByPart0 = {}
			for _, j in ipairs(clone:GetDescendants()) do
				if (j:IsA("Motor6D") or j:IsA("Weld")) and j.Part0 and j.Part1 then
					local list = jointsByPart0[j.Part0]
					if not list then
						list = {}
						jointsByPart0[j.Part0] = list
					end
					table.insert(list, j)
				end
			end
			local function walk(part, seen)
				seen[part] = true
				local list = jointsByPart0[part]
				if not list then return end
				for _, j in ipairs(list) do
					local child = j.Part1
					if child and child:IsA("BasePart") and not seen[child] then
						child.CFrame = part.CFrame * j.C0 * j.C1:Inverse()
						walk(child, seen)
					end
				end
			end
			walk(poseRoot, {})
		end

		for handle, fix in pairs(accessoryFix) do
			local parentPart, rel = fix[1], fix[2]
			if handle.Parent and parentPart.Parent then
				handle.CFrame = parentPart.CFrame * rel
			end
		end
		local animator = clone:FindFirstChildOfClass("Animator")
		if animator then animator:Destroy() end
		cloneHolder.model = clone
	end
	local charConn = player.CharacterAdded:Connect(function(char)
		task.delay(0.8, function() buildClone(char) end)
	end)
	onClose(function() charConn:Disconnect() end)
	task.spawn(function()
		local char = player.Character
		if not char then
			char = player.CharacterAdded:Wait()
		end
		task.wait(0.8)
		buildClone(char)
	end)

	local right = new("Frame", {
		Active = false, BackgroundTransparency = 1,
		Position = UDim2.new(0, 260, 0, 14), Size = UDim2.new(1, -274, 1, -26),
		Parent = hero,
	})
	local pill = new("Frame", {
		Active = false, Size = UDim2.fromOffset(152, 26),
		BackgroundColor3 = C.White, BackgroundTransparency = 0.9,
		Parent = right,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = pill })
	iconBox(pill, "star", C.Lamp, UDim2.new(0, 10, 0.5, -7), 14)
	local pillText = label(pill, "WELCOME BACK", uiBold, 11, C.Lamp,
		UDim2.new(0, 30, 0, 0), UDim2.new(1, -34, 1, 0))
	local heroTitle = label(right, player.DisplayName, uiBold, 34, C.Text,
		UDim2.new(0, 0, 0, 32), UDim2.new(1, 0, 0, 42))
	local titleGrad = new("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(224, 122, 12)),
			ColorSequenceKeypoint.new(0.42, Color3.fromRGB(255, 176, 32)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 248, 214)),
			ColorSequenceKeypoint.new(0.58, Color3.fromRGB(255, 176, 32)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(224, 122, 12)),
		}),
		Parent = heroTitle,
	})
	mainShimmer(titleGrad, 2.8)
	local heroTag = label(right, "", uiReg, 13, C.Dim,
		UDim2.new(0, 0, 0, 76), UDim2.new(1, -6, 0, 30))
	heroTag.TextWrapped = true
	heroTag.TextYAlignment = Enum.TextYAlignment.Top
	local connText = label(right, "", uiReg, 12, C.Dim,
		UDim2.new(0, 2, 0, 106), UDim2.new(1, -16, 0, 22))

	local statsRow = new("Frame", {
		Name = "Row", LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 86), BackgroundTransparency = 1,
		BorderSizePixel = 0, Parent = c,
	})
	new("UIListLayout", {
		Padding = UDim.new(0, 8), FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder, Parent = statsRow,
	})
	local statDefs = {
		{ icon = "person" }, { icon = "lightning-bolt" }, { icon = "clock" },
	}
	local statVals, statCaps = {}, {}
	for i, def in ipairs(statDefs) do
		local sc = new("Frame", {
			Active = false, LayoutOrder = i,
			Size = UDim2.new(1 / 3, -6, 1, 0),
			BackgroundColor3 = C.Glass, BackgroundTransparency = 0.45,
			BorderSizePixel = 0, Parent = statsRow,
		})
		new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = sc })
		hoverGlow(sc)
		iconBox(sc, def.icon, C.Lamp, UDim2.new(0, 15, 0, 12), 16)
		statVals[i] = label(sc, "--", uiBold, 24, C.Text,
			UDim2.new(0, 15, 0, 34), UDim2.new(1, -15, 0, 30))
		statCaps[i] = label(sc, "", uiBold, 10.5, C.Dim,
			UDim2.new(0, 15, 0, 66), UDim2.new(1, -15, 0, 14))
	end

	local banner = new("Frame", {
		Name = "Row", LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0, 92),
		BackgroundColor3 = Color3.fromRGB(198, 110, 14), BackgroundTransparency = 0,
		BorderSizePixel = 0, Parent = c,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = banner })
	hoverGlow(banner, true)
	local banGrad = new("UIGradient", {

		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(172, 88, 8)),
			ColorSequenceKeypoint.new(0.38, Color3.fromRGB(214, 122, 16)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 240, 190)),
			ColorSequenceKeypoint.new(0.62, Color3.fromRGB(214, 122, 16)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(172, 88, 8)),
		}),
		Parent = banner,
	})
	mainShimmer(banGrad, 3.6)
	local INK = Color3.fromRGB(44, 26, 4)
	local logo = new("Frame", {
		Active = false, Size = UDim2.fromOffset(54, 54),
		Position = UDim2.new(0, 16, 0.5, -27),
		BackgroundColor3 = Color3.fromRGB(52, 30, 4), BackgroundTransparency = 0.12,
		Parent = banner,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 14), Parent = logo })
	iconBox(logo, "discord", C.Lamp, UDim2.new(0.5, -17, 0.5, -17), 34)
	local banTitle = label(banner, "Join the IXA HUB Discord", uiBold, 16, INK,
		UDim2.new(0, 78, 0, 15), UDim2.new(1, -210, 0, 22))
	banTitle:SetAttribute("IXA_L10N", "Plain")
	banTitle:SetAttribute("IXA_En", "Join the IXA HUB Discord")
	local banSub = label(banner, "Updates, giveaways, support & new scripts first.",
		uiReg, 12.5, INK, UDim2.new(0, 78, 0, 40), UDim2.new(1, -210, 0, 20))
	banSub.TextTransparency = 0.2
	banSub:SetAttribute("IXA_L10N", "Plain")
	banSub:SetAttribute("IXA_En", "Updates, giveaways, support & new scripts first.")
	local membersText = label(banner, DISCORD_MEMBERS_TEXT, uiBold, 12, INK,
		UDim2.new(0, 78, 0, 63), UDim2.new(0, 200, 0, 20))
	membersText:SetAttribute("IXA_L10N", "Plain")
	membersText:SetAttribute("IXA_En", DISCORD_MEMBERS_TEXT)
	local joinBtn = new("TextButton", {
		Size = UDim2.fromOffset(112, 38),
		Position = UDim2.new(1, -126, 0.5, -19),
		BackgroundColor3 = C.White, BackgroundTransparency = 0,
		Text = "", AutoButtonColor = false, BorderSizePixel = 0,
		Parent = banner,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = joinBtn })
	clickFlash(joinBtn)
	local joinText = label(joinBtn, "Join", uiBold, 13, Color3.fromRGB(178, 92, 6),
		UDim2.new(0, 6, 0, 0), UDim2.new(1, -12, 1, 0))
	joinText.TextXAlignment = Enum.TextXAlignment.Center
	joinText:SetAttribute("IXA_L10N", "Plain")
	joinText:SetAttribute("IXA_En", "Join")
	joinBtn.MouseEnter:Connect(function() tw(joinBtn, { BackgroundTransparency = 0.12 }, T.fast) end)
	joinBtn.MouseLeave:Connect(function() tw(joinBtn, { BackgroundTransparency = 0 }, T.fast) end)
	tap(joinBtn, function()
		if setclipboard then
			pcall(function() setclipboard(DISCORD_INVITE) end)
			toast(ru() and "Ссылка-приглашение скопирована" or "Invite link copied")
		else
			toast(DISCORD_INVITE)
		end
	end)

	local brow = new("Frame", {
		Name = "Row", LayoutOrder = 4,
		Size = UDim2.new(1, 0, 0, 186), BackgroundTransparency = 1,
		BorderSizePixel = 0, Parent = c,
	})
	new("UIListLayout", {
		Padding = UDim.new(0, 8), FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder, Parent = brow,
	})
	local ql = new("Frame", {
		Active = false, LayoutOrder = 1,
		Size = UDim2.new(0.5, -4, 1, 0),
		BackgroundColor3 = C.Glass, BackgroundTransparency = 0.45,
		BorderSizePixel = 0, Parent = brow,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = ql })
	hoverGlow(ql)
	iconBox(ql, "lightning-bolt", C.Lamp, UDim2.new(0, 15, 0, 15), 14)
	local qlHead = label(ql, "", uiBold, 11.5, C.Lamp,
		UDim2.new(0, 34, 0, 14), UDim2.new(1, -42, 0, 16))
	for i, def in ipairs(QUICK_LAUNCH) do
		local col, row = (i - 1) % 2, math.floor((i - 1) / 2)
		local chip = new("TextButton", {
			Size = UDim2.new(0.5, -19, 0, 36),
			Position = UDim2.new(col * 0.5, col == 0 and 14 or 5, 0, 40 + row * 44),
			BackgroundColor3 = C.White, BackgroundTransparency = 0.88,
			Text = "", AutoButtonColor = false, BorderSizePixel = 0,
			Parent = ql,
		})
		new("UICorner", { CornerRadius = UDim.new(0, 9), Parent = chip })
		clickFlash(chip)
		iconBox(chip, def.icon, C.Dim, UDim2.new(0, 10, 0.5, -7), 15)
		label(chip, def.name, uiBold, 12.5, C.Text,
			UDim2.new(0, 31, 0, 0), UDim2.new(1, -88, 1, 0))
		local stateL = label(chip, "OFF", uiBold, 10, C.Dim,
			UDim2.new(1, -52, 0, 0), UDim2.new(0, 44, 1, 0))
		stateL.TextXAlignment = Enum.TextXAlignment.Right
		local on = IXA_UI_STATE[def.key] == true
		local function paint(isOn)
			chip.BackgroundColor3 = isOn and C.On or C.White
			chip.BackgroundTransparency = isOn and 0.72 or 0.88
			stateL.Text = IXAL_L(isOn and "ON" or "OFF")
			stateL.TextColor3 = isOn and C.Text or C.Dim
		end
		paint(on)
		tap(chip, function()
			on = not on
			IXA_UI_STATE[def.key] = on
			paint(on)
			ixaCall(def.onChange, on)
		end)
	end
	local allBtn = new("TextButton", {
		Size = UDim2.new(1, -28, 0, 32), Position = UDim2.new(0, 14, 1, -46),
		BackgroundColor3 = C.White, BackgroundTransparency = 0.93,
		Text = "", AutoButtonColor = false, BorderSizePixel = 0, Parent = ql,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 9), Parent = allBtn })
	clickFlash(allBtn)
	new("UIStroke", { Color = C.White, Transparency = 0.7, Thickness = 1, Parent = allBtn })
	local allText = label(allBtn, "All features →", uiMed, 12.5, C.Dim,
		UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 1, 0))
	allText.TextXAlignment = Enum.TextXAlignment.Center
	allText:SetAttribute("IXA_L10N", "Plain")
	allText:SetAttribute("IXA_En", "All features →")
	tap(allBtn, function() switchTab(ALL_FEATURES_TAB) end)

	local wn = new("Frame", {
		Active = false, LayoutOrder = 2,
		Size = UDim2.new(0.5, -4, 1, 0),
		BackgroundColor3 = C.Glass, BackgroundTransparency = 0.45,
		BorderSizePixel = 0, Parent = brow,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = wn })
	hoverGlow(wn)
	iconBox(wn, "clock-spin-reverse", C.Lamp, UDim2.new(0, 15, 0, 15), 14)
	local wnHead = label(wn, "", uiBold, 11.5, C.Lamp,
		UDim2.new(0, 34, 0, 14), UDim2.new(1, -42, 0, 16))

	local tagCols = {
		NEW = C.On,
		IMPROVED = C.Accent,
		FIX = C.Blue,
	}
	local tagW = { NEW = 44, IMPROVED = 76, FIX = 34 }

	local tagText = { NEW = INK, IMPROVED = INK, FIX = C.White }
	local list = new("Frame", {
		Active = false, BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 40), Size = UDim2.new(1, -30, 1, -52),
		Parent = wn,
	})
	new("UIListLayout", {
		Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list,
	})
	for i, entry in ipairs(CHANGELOG) do
		local line = new("Frame", {
			Active = false, LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
			Parent = list,
		})
		local w = tagW[entry.tag] or 46
		local chipL = new("TextLabel", {
			Active = false, Size = UDim2.fromOffset(w, 16),
			BackgroundColor3 = tagCols[entry.tag] or C.Accent,
			BackgroundTransparency = 0.08,
			Text = entry.tag, TextColor3 = tagText[entry.tag] or C.White,
			FontFace = uiBold, TextSize = 9.5,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			BorderSizePixel = 0, Parent = line,
		})
		new("UICorner", { CornerRadius = UDim.new(0, 4), Parent = chipL })
		label(line, entry.text, uiReg, 12.5, C.Text,
			UDim2.new(0, w + 9, 0, 0), UDim2.new(1, -w - 9, 1, 0))
	end

	local function refreshLive()
		if not hero.Parent then return false end
		statVals[1].Text = mainFmtInt(#Players:GetPlayers())
		statVals[2].Text = mainFmtK(EXEC_COUNT)
		statVals[3].Text = mainFmtUptime(os.time() - MAIN_T0)
		statCaps[1].Text = string.upper(IXAL_L("Online now"))
		statCaps[2].Text = string.upper(IXAL_L("Executions"))
		statCaps[3].Text = string.upper(IXAL_L("Uptime"))
		pillText.Text = string.upper(IXAL_L("Welcome back"))
		qlHead.Text = string.upper(IXAL_L("Quick Launch"))
		wnHead.Text = string.upper(IXAL_L("What's New")) .. " · V" .. HUB_VERSION_TAG
		local ping = nil
		pcall(function()
			ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
		end)
		local gameName = GAME_NAME or (ru() and "игра" or "the game")
		local pingPart = ping and (" · " .. ping .. (ru() and " мс" or " ms")) or ""
		if ru() then
			heroTag.Text = "Твой универсальный хаб для " .. gameName .. ". Выбери фичу и доминируй."
			connText.Text = "Подключено к " .. gameName .. pingPart
		else
			heroTag.Text = "Your all-in-one hub for " .. gameName .. ". Pick a feature and dominate."
			connText.Text = "Connected to " .. gameName .. pingPart
		end
		return true
	end
	refreshLive()
	task.spawn(function()
		while task.wait(2) do
			if not refreshLive() then
				for _, fn in ipairs(cleanups) do pcall(fn) end
				return
			end
		end
	end)
end }

table.insert(TABS, 1, MAIN_TAB)

task.spawn(function()
	task.wait(0.15)
	if not gui or not gui.Parent then return end
	local ruNow = IXAL_Locale == "Russian"

	local blur = Instance.new("BlurEffect")
	blur.Name = "IxaSplashBlur"
	blur.Size = 0
	blur.Parent = Lighting
	local dim = new("Frame", {
		Name = "IxaSplashDim", Active = false,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
		BorderSizePixel = 0, ZIndex = 55, Parent = gui,
	})

	local holder = new("Frame", {
		Name = "IxaSplash", Active = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromOffset(560, 124),
		BackgroundTransparency = 1,
		BorderSizePixel = 0, ZIndex = 60, Parent = gui,
	})
	local sTitle = new("TextLabel", {
		Active = false, ZIndex = 61, BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 4), Size = UDim2.new(1, 0, 0, 44),
		Text = HUB_TITLE, FontFace = uiBold, TextSize = 36, TextColor3 = C.On,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = holder,
	})
	local tGrad = new("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, C.Accent),
			ColorSequenceKeypoint.new(0.45, C.On),
			ColorSequenceKeypoint.new(0.5, C.Lamp),
			ColorSequenceKeypoint.new(0.55, C.On),
			ColorSequenceKeypoint.new(1, C.Accent),
		}),
		Parent = sTitle,
	})
	mainShimmer(tGrad, 2.4)
	local sSub = new("TextLabel", {
		Active = false, ZIndex = 61, BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 52), Size = UDim2.new(1, 0, 0, 24),
		Text = ruNow and ("С возвращением, " .. player.DisplayName)
			or ("Welcome back, " .. player.DisplayName),
		FontFace = uiReg, TextSize = 15, TextColor3 = C.Text, TextTransparency = 0.15,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = holder,
	})
	local sLine = new("Frame", {
		Active = false, ZIndex = 61,
		AnchorPoint = Vector2.new(0.5, 0),
		Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.5, 0, 0, 88),
		BackgroundColor3 = C.On, BackgroundTransparency = 0.1,
		BorderSizePixel = 0, Parent = holder,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sLine })
	local sTag = new("TextLabel", {
		Active = false, ZIndex = 61, BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 100), Size = UDim2.new(1, 0, 0, 18),
		Text = ruNow and "инжект выполнен · хорошего сеанса"
			or "inject complete · have a good session",
		FontFace = uiReg, TextSize = 11, TextColor3 = C.Dim,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = holder,
	})

	TweenService:Create(blur,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = 24 }):Play()
	tw(dim, { BackgroundTransparency = 0.45 }, 0.5)
	groupFadeSet(holder, 1)
	groupFade(sTitle, 0, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.25)
	groupFade(sSub, 0, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.5)
	groupFade(sLine, 0, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.6)
	tw(sLine, { Size = UDim2.new(0, 220, 0, 2) }, 0.7,
		Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.6)
	groupFade(sTag, 0, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.75)

	task.wait(2.6)
	groupFade(holder, 1, 0.35)
	tw(dim, { BackgroundTransparency = 1 }, 0.45)
	TweenService:Create(blur,
		TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Size = 0 }):Play()
	task.wait(0.5)
	if holder.Parent then holder:Destroy() end
	if dim.Parent then dim:Destroy() end
	if blur.Parent then blur:Destroy() end
	islandEntrance()
end)

do
	local holder = Instance.new("Folder")
	local savedTab = activeTab
	local savedUiRefs = uiRefs
	uiRefs = {}
	for i, def in ipairs(TABS) do
		activeTab = i
		local sink = Instance.new("Frame")
		sink.Parent = holder
		local ok, err = pcall(def.build, sink)
		if not ok then warn("[IXA] search prebuild tab " .. i .. ": " .. tostring(err)) end
		sink:Destroy()
	end
	holder:Destroy()
	activeTab = savedTab
	uiRefs = savedUiRefs
end

local function setTabVisual(index)
	for i, t in ipairs(tabButtons) do
		local on = i == index
		tw(t.btn, { BackgroundTransparency = on and 0.2 or 0.55 }, T.mid)
		tw(t.ind, { BackgroundTransparency = on and 0 or 1 }, T.mid)
		tw(t.lbl, { TextColor3 = on and C.Text or C.Dim }, T.mid)
		if t.img then tw(t.img, { TextColor3 = on and C.Accent or C.Dim }, T.mid) end
	end
end
local function getRows()
	local rows = {}
	for _, d in ipairs(content:GetChildren()) do
		if d:IsA("Frame") and d.Name == "Row" then table.insert(rows, d) end
	end
	return rows
end
local function staggerIn()
	local rows = getRows()
	table.sort(rows, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
	for i, d in ipairs(rows) do
		groupFadeSet(d, 1)
		groupFade(d, 0, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, (i - 1) * 0.035)
	end
end
buildTab = function(index, animate)
	for i = #openMenus, 1, -1 do openMenus[i].close() end
	extraCanvas = 0
	for _, d in ipairs(getRows()) do d:Destroy() end
	content.CanvasPosition = Vector2.new(0, 0)
	if TABS[index] then TABS[index].build(content) end
	updateCanvas()
	if animate then staggerIn() end
end

local rawBuildTab = buildTab
buildTab = function(index, animate)
	for i = #IXA_SearchRows, 1, -1 do
		if IXA_SearchRows[i].tab == index then table.remove(IXA_SearchRows, i) end
	end
	rawBuildTab(index, animate)
	if IXAL_ApplyTranslations then IXAL_ApplyTranslations() end
	if IXA_rebuildSuggestions and not IXA_SuppressFocusRebuild then
		IXA_rebuildSuggestions()
	end
end

local tabToken = 0
switchTab = function(index)
	if index == activeTab or not TABS[index] then return end
	activeTab = index
	setTabVisual(index)
	tabToken += 1
	local token = tabToken
	for _, d in ipairs(getRows()) do
		groupFade(d, 1, 0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	end
	task.delay(0.14, function()
		if token ~= tabToken then return end
		buildTab(index, true)
	end)
end
for i, def in ipairs(TABS) do
	makeTabButton(def.name, i, i)
end
setTabVisual(1)
buildTab(1, true)

;(function()
local SEARCH_COLLAPSED = UDim2.fromOffset(26, 26)
local SEARCH_EXPANDED  = UDim2.fromOffset(250, 26)
local searchRow = new("TextButton", {
	Name = "SearchBar", ZIndex = 3,
	AnchorPoint = Vector2.new(1, 0),
	Size = SEARCH_COLLAPSED,
	Position = UDim2.new(1, -376, 0, 9),
	BackgroundColor3 = C.Glass, BackgroundTransparency = 0.35,
	Text = "", AutoButtonColor = false,
	ClipsDescendants = true, BorderSizePixel = 0, Parent = header,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = searchRow })
local searchStroke = new("UIStroke", { Color = C.Accent, Transparency = 1, Thickness = 1, Parent = searchRow })
local searchIcon = new("TextLabel", {
	ZIndex = 4, Active = false,
	Size = UDim2.fromOffset(14, 14),
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 6, 0.5, 0),
	BackgroundTransparency = 1,
	Text = "", TextScaled = false, TextSize = 13,
	FontFace = NL_ICON_REGULAR, TextColor3 = C.Dim,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
	Parent = searchRow,
})
setIcon(searchIcon, "search", C.Dim)

IXA_searchInput = new("TextBox", {
	Name = "SearchInput", ZIndex = 4,
	Size = UDim2.new(1, -36, 1, 0),
	Position = UDim2.new(0, 26, 0, 0),
	BackgroundTransparency = 1,
	Text = "", PlaceholderText = "Search features...",
	PlaceholderColor3 = C.Dim, TextColor3 = C.Text,
	FontFace = uiMed, TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	ClearTextOnFocus = false, TextTransparency = 1,
	Visible = false, Parent = searchRow,
})

local suggBox = new("Frame", {
	Name = "SearchResultsBox", ZIndex = 5,
	AnchorPoint = Vector2.new(1, 0),
	Size = UDim2.fromOffset(280, 0),
	Position = UDim2.new(1, -10, 0, 66),
	BackgroundColor3 = C.Window, BackgroundTransparency = 0.3,
	BorderSizePixel = 0, ClipsDescendants = true,
	Visible = false, Parent = window,
})
new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = suggBox })
local suggStroke = new("UIStroke", { Color = C.Accent, Transparency = 0.45, Thickness = 1, Parent = suggBox })
new("UIGradient", {
	Rotation = 65,
	Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.Accent), ColorSequenceKeypoint.new(1, C.White) }),
	Parent = suggStroke,
})
local suggestions = new("ScrollingFrame", {
	Name = "SearchResults", ZIndex = 5,
	Size = UDim2.new(1, -8, 1, -12),
	Position = UDim2.new(0, 4, 0, 6),
	BackgroundTransparency = 1, BorderSizePixel = 0,
	ScrollBarThickness = 3, ScrollBarImageColor3 = C.Accent,
	CanvasSize = UDim2.new(0, 0, 0, 0), Parent = suggBox,
})
local suggLayout = new("UIListLayout", {
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = suggestions,
})
local function updateSearchCanvas()
	suggestions.CanvasSize = UDim2.new(0, 0, 0, suggLayout.AbsoluteContentSize.Y + 6)
	local h = math.min(suggLayout.AbsoluteContentSize.Y + 18, 8 * 34 + 14)
	if h < 42 then h = 42 end
	suggBox.Size = UDim2.new(0, 280, 0, h)
end
suggLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSearchCanvas)

IXA_SearchOpen = false

IXA_OpenSearch = function()
	if IXA_SearchOpen or unloaded then return end
	IXA_SearchOpen = true
	IXA_searchInput.Visible = true
	tw(searchRow, { Size = SEARCH_EXPANDED, BackgroundTransparency = 0.2 }, 0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	tw(IXA_searchInput, { TextTransparency = 0 }, 0.2)
	tw(searchIcon, { TextColor3 = C.Text }, 0.2)
	task.delay(0.18, function()
		if IXA_SearchOpen and IXA_searchInput and IXA_searchInput.Parent then
			pcall(function() IXA_searchInput:CaptureFocus() end)
		end
	end)
end

IXA_CloseSearch = function()
	if not IXA_SearchOpen then return end
	IXA_SearchOpen = false
	suggBox.Visible = false
	IXA_searchInput.Text = ""
	pcall(function() IXA_searchInput:ReleaseFocus() end)
	tw(IXA_searchInput, { TextTransparency = 1 }, 0.1)
	tw(searchIcon, { TextColor3 = C.Dim }, 0.2)
	tw(searchRow, { Size = SEARCH_COLLAPSED, BackgroundTransparency = 0.35 }, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	task.delay(0.26, function()
		if not IXA_SearchOpen then IXA_searchInput.Visible = false end
	end)
end

searchRow.MouseEnter:Connect(function()
	if not IXA_SearchOpen then tw(searchRow, { BackgroundTransparency = 0.05 }, T.fast) end
end)
searchRow.MouseLeave:Connect(function()
	if not IXA_SearchOpen then tw(searchRow, { BackgroundTransparency = 0.35 }, T.fast) end
end)

searchRow.MouseButton1Click:Connect(function()
	if IXA_SearchOpen then IXA_CloseSearch() else IXA_OpenSearch() end
end)

IXA_resultPending = false
IXA_FirstSuggestion = nil
IXA_flashToken = 0
IXA_SuppressFocusRebuild = false

IXA_LOWER = {}
for _, rng in ipairs({ {0x41, 0x5A, 32}, {0x0410, 0x042F, 32}, {0x0460, 0x0481, 1}, {0x048A, 0x052F, 1} }) do
	for code = rng[1], rng[2] do
		IXA_LOWER[code] = code + rng[3]
	end
end
IXA_LOWER[0x0401] = 0x0451

local function lowerText(s)
	if not s or s == "" then return "" end
	local out = {}

	for _, code in utf8.codes(s) do
		table.insert(out, utf8.char(IXA_LOWER[code] or code))
	end
	return table.concat(out)
end

local function searchScore(query, text)
	if not text or text == "" then return nil end
	local t = lowerText(text)
	local idx = t:find(query, 1, true)
	if not idx then return nil end
	if idx == 1 then return 0 end
	local prev = t:sub(idx - 1, idx - 1)
	if prev == " " or prev == "-" or prev == "." or prev == "+" or prev == ":" then return 1 end
	return 2
end

local function looseScore(query, text)
	if not query or query == "" then return false end
	local t = lowerText(text or "")
	local pos = 0
	for _, ch in utf8.codes(query) do
		local at = t:find(utf8.char(ch), pos + 1, true)
		if not at then return false end
		pos = at
	end
	return true
end

IXA_flashRow = function(row)
	if not row then return end
	IXA_flashToken += 1
	local token = IXA_flashToken
	cancelTweens(row)
	local stroke = row:FindFirstChildOfClass("UIStroke")
	if stroke then stroke.Transparency = 0 end

	task.spawn(function()
		local startT = os.clock()
		local dur = 2.2

		local deepGray = Color3.fromRGB(43, 43, 47)
		while os.clock() - startT < dur do
			if token ~= IXA_flashToken or not row.Parent then return end
			local k = (os.clock() - startT) / dur
			if stroke then
				local pulse = 0.5 + 0.5 * math.sin(k * math.pi * 4)
				stroke.Color = deepGray:Lerp(C.On, pulse)
				stroke.Transparency = 0.05 + 0.35 * math.abs(math.sin(k * math.pi * 2))
			end
			task.wait(0.03)
		end
		if token == IXA_flashToken and row.Parent then
			tw(row, { BackgroundTransparency = 0.86 }, 0.4)
			if stroke then tw(stroke, { Transparency = 1 }, 0.4) end
		end
	end)
	task.spawn(function()
		for _ = 1, 2 do
			if token ~= IXA_flashToken or not row.Parent then return end
			tw(row, { BackgroundTransparency = 0.08 }, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(0.55)
			if token ~= IXA_flashToken or not row.Parent then return end
			tw(row, { BackgroundTransparency = 0.6 }, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(0.55)
		end
	end)
end

IXA_ScrollToRow = function(entry)
	if not entry or not entry.tab then return end

	task.delay(0.34, function()
		if entry.tab ~= activeTab then return end

		local function freshRow()
			if entry.row and entry.row.Parent then return entry.row end
			for _, e in ipairs(IXA_SearchRows) do
				if e.tab == entry.tab and e.order == entry.order and e.row and e.row.Parent then
					return e.row
				end
			end
			return nil
		end
		local row = freshRow()
		if not row then
			IXA_SuppressFocusRebuild = true
			buildTab(entry.tab, false)
			IXA_SuppressFocusRebuild = false
			row = freshRow()
		end
		if not (row and row.Parent) then return end

		task.defer(function()
			IXA_resultPending = false
			IXA_CloseSearch()
		end)

		local rowLO = row.LayoutOrder
		local cumY = 0
		for _, d in ipairs(content:GetChildren()) do
			if d:IsA("Frame") and d.Name == "Row" and d ~= row and d.LayoutOrder < rowLO then
				cumY = cumY + d.Size.Y.Offset + 6
			end
		end
		local rowH = row.Size.Y.Offset
		local visibleH = content.AbsoluteSize.Y
		local maxScroll = math.max(0, content.CanvasSize.Y.Offset - visibleH)
		local y = math.clamp(cumY + rowH / 2 - visibleH / 2, 0, maxScroll)
		if visibleH >= 40 then
			tw(content, { CanvasPosition = Vector2.new(0, y) }, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end

		task.spawn(function()
			local deadline = os.clock() + 1.5
			while os.clock() < deadline do
				task.wait(0.15)
				if not row.Parent or entry.tab ~= activeTab then return end
				local vis = content.AbsoluteSize.Y
				if vis >= 40 then
					local max = math.max(0, content.CanvasSize.Y.Offset - vis)
					local want = math.clamp(cumY + rowH / 2 - vis / 2, 0, max)
					if math.abs(content.CanvasPosition.Y - want) <= 3 then return end
					tw(content, { CanvasPosition = Vector2.new(0, want) }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				end
			end
		end)

		task.delay(0.12, function()
			if entry.tab == activeTab and row.Parent then
				IXA_flashRow(row)
			end
		end)
	end)
end

IXA_rebuildSuggestions = function()

	IXA_resultPending = false
	for _, d in ipairs(suggestions:GetChildren()) do
		if d:IsA("TextButton") then d:Destroy() end
	end
	IXA_FirstSuggestion = nil

	local query = lowerText(IXA_searchInput.Text)
	query = query:gsub("^%s+", ""):gsub("%s+$", "")
	if utf8.len(query) == nil or utf8.len(query) < 1 then
		suggBox.Visible = false
		updateSearchCanvas()
		return
	end
	local found = {}
	for _, entry in ipairs(IXA_SearchRows) do

		if (entry.row and entry.row.Parent ~= nil) or entry.tab ~= activeTab then
			local titleRu = IXAL_L(entry.title or "")
			local titleEn = entry.title or ""
			local best, rank = nil, nil
			for _, text in ipairs({ titleRu, titleEn }) do
				local r = searchScore(query, text)
				if r and (rank == nil or r < rank) then
					rank = r
					best = text
				end
			end

			if not rank then
				for _, text in ipairs({ titleRu, titleEn }) do
					if looseScore(query, text) then
						rank, best = 9, text
						break
					end
				end
			end
			if rank then

				local dupe = false
				for _, f in ipairs(found) do
					if f.entry.tab == entry.tab and f.entry.order == entry.order then dupe = true break end
				end
				if not dupe then

					found[#found + 1] = { rank = rank, entry = entry, label = (titleRu ~= "" and titleRu) or titleEn }
				end
			end
		end
	end
	table.sort(found, function(a, b)
		if a.rank ~= b.rank then return a.rank < b.rank end
		return a.label:lower() < b.label:lower()
	end)

	while #found > 16 do table.remove(found) end
	local maxShow = math.min(#found, 8)
	for i = 1, maxShow do
		local hit = found[i]
		local btn = new("TextButton", {
			Size = UDim2.new(1, -6, 0, 30),
			LayoutOrder = i,
			BackgroundColor3 = C.Glass,
			BackgroundTransparency = 0.88,
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Parent = suggestions,
		})
		new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = btn })

		local mark = new("Frame", {
			Name = "HoverMark",
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.new(0, 3, 1, -12),
			Position = UDim2.new(0, 3, 0.5, 0),
			BackgroundColor3 = C.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = btn,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = mark })
		new("TextLabel", {
			Active = false,
			Size = UDim2.new(1, -92, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Text = hit.label,
			TextColor3 = C.Text,
			FontFace = uiMed,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = btn,
		})
		local tabLabel = new("TextLabel", {
			Active = false,
			Size = UDim2.new(0, 80, 1, 0),
			Position = UDim2.new(1, -84, 0, 0),
			BackgroundTransparency = 1,
			Text = IXAL_L(TABS[hit.entry.tab] and TABS[hit.entry.tab].name or ""),
			TextColor3 = C.Dim,
			TextTransparency = 0.25,
			FontFace = uiReg,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = btn,
		})
		tabLabel:SetAttribute("IXA_Role", "Dim")
		btn.MouseEnter:Connect(function()
			tw(btn, { BackgroundTransparency = 0.76 }, T.fast)
			tw(mark, { BackgroundTransparency = 0 }, T.fast)
		end)
		btn.MouseLeave:Connect(function()
			tw(btn, { BackgroundTransparency = 0.88 }, T.fast)
			tw(mark, { BackgroundTransparency = 1 }, T.fast)
		end)
		tap(btn, function()

			IXA_resultPending = true
			IXA_resultCB(hit.entry)
		end)
		if i == 1 then IXA_FirstSuggestion = hit.entry end
	end
	updateSearchCanvas()
	suggBox.Visible = (maxShow > 0) and IXA_SearchOpen
end

IXA_resultCB = function(entry)
	if not entry or not entry.tab then return end
	suggBox.Visible = false
	switchTab(entry.tab)
	IXA_ScrollToRow(entry)
end

IXA_SearchRestoreFocus = function()
	if IXA_resultPending then
		IXA_resultPending = false
		return
	end
	if not isOpen or unloaded then return end

	if not IXA_SearchOpen then return end
	task.defer(function()
		if IXA_searchInput and IXA_searchInput.Parent then
			IXA_searchInput:CaptureFocus()
		end
	end)
end

IXA_ApplySearchTheme = function()
	if not searchRow or not searchRow.Parent then return end
	searchRow.BackgroundColor3 = C.Glass
	searchIcon.TextColor3 = IXA_SearchOpen and C.Text or C.Dim
	IXA_searchInput.TextColor3 = C.Text
	IXA_searchInput.PlaceholderColor3 = C.Dim
	searchStroke.Color = C.Accent
	suggBox.BackgroundColor3 = C.Window
	suggStroke.Color = C.Accent
	for _, d in ipairs(suggestions:GetChildren()) do
		if d:IsA("TextButton") then
			d.BackgroundColor3 = C.Text
			local st = d:FindFirstChildOfClass("UIStroke")
			if st then st.Color = C.Accent end
			for _, e in ipairs(d:GetChildren()) do
				if e:IsA("TextLabel") then
					e.TextColor3 = (e:GetAttribute("IXA_Role") == "Dim") and C.Dim or C.Text
				end
			end
		end
	end
end

IXA_searchInput:GetPropertyChangedSignal("Text"):Connect(function()
	IXA_rebuildSuggestions()
end)

IXA_searchInput.Focused:Connect(function()
	tw(searchStroke, { Transparency = 0.35 }, T.fast)
	IXA_rebuildSuggestions()
end)

IXA_searchInput.FocusLost:Connect(function(enter)
	tw(searchStroke, { Transparency = 1 }, T.fast)
	if enter then
		if IXA_FirstSuggestion then
			local entry = IXA_FirstSuggestion

			if not (entry.row and entry.row.Parent) then
				IXA_SuppressFocusRebuild = true
				IXA_rebuildSuggestions()
				IXA_SuppressFocusRebuild = false
				entry = IXA_FirstSuggestion or entry
			end
			IXA_resultPending = true
			IXA_resultCB(entry)
		end
		return
	end

	task.delay(0.05, function()
		if not IXA_resultPending and IXA_searchInput.Text == "" then

			IXA_CloseSearch()
		end
	end)
end)

IXA_searchInput.PlaceholderText = IXAL_L("Search features...")

end)()

;(function()

local windowDrag = {
	active = false,
	origin = Vector2.new(0, 0),
	target = Vector2.new(0, 0),
	current = Vector2.new(0, 0),
}
local function clampWindowPos(p, w, h)
	local v = vp()
	local halfW = w / 2
	local minX = 8 + halfW - v.X / 2
	local maxX = v.X / 2 - halfW - 8
	if minX > maxX then minX, maxX = 0, 0 end
	local minY = 8
	local maxY = math.max(minY, v.Y - h - 8)
	return Vector2.new(math.clamp(p.X, minX, maxX), math.clamp(p.Y, minY, maxY))
end

isOpen = false
local isFull = false
local fullRect = nil
local anim = { token = 0, animating = false }

local function fadeIsland(out, duration, delayTime)
	for _, f in ipairs(islandFadeables) do
		tw(f[1], { [f[2]] = out and 1 or f[3] }, duration,
			Enum.EasingStyle.Quad, Enum.EasingDirection.Out, delayTime)
	end
	tw(logoIcon,  { ImageTransparency = 1 }, duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, delayTime)
	tw(cometGlow, { ImageTransparency = 1 }, duration)
	for _, trail in ipairs(cometTrail) do tw(trail, { ImageTransparency = 1 }, duration) end
end

islandEntrance = function()
	if unloaded or island.Visible then return end
	for _, f in ipairs(islandFadeables) do f[1][f[2]] = 1 end
	logoIcon.ImageTransparency = 1
	cometGlow.ImageTransparency = 1
	for _, trail in ipairs(cometTrail) do trail.ImageTransparency = 1 end
	islandScale.Scale = 0.82
	island.Visible = true
	BlurTarget = 0.85
	fadeIsland(false, 0.5, 0.05)
	tw(islandScale, { Scale = 1 }, 0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0.05)
	task.delay(0.9, function()
		if not isOpen and island.Visible then strikeComet() end
	end)
end

openHub = function()
	if isOpen or unloaded then return end
	isOpen = true
	anim.token += 1
	anim.animating = true
	local token = anim.token

	window.AnchorPoint = Vector2.new(0.5, 0)
	window.Position = islandPos()
	window.Size = UDim2.fromOffset(ISLAND_W, ISLAND_H)
	window.BackgroundTransparency = 0.15
	winCorner.CornerRadius = UDim.new(0, 18)
	window.Visible = true

	fadeIsland(true, T.mid)
	BlurTarget = 0

	local targetPos  = normPos()
	local targetSize = normSize()
	if isFull then
		local v = vp()
		local nw, nh = fullSizeFit()
		targetSize = UDim2.fromOffset(nw, nh)
		targetPos  = UDim2.new(0.5, 0, 0, math.max(8, (v.Y - nh) / 2))
	end

	local winTween = tw(window, {
		Position = targetPos,
		Size = targetSize,
		BackgroundTransparency = 1,
	}, T.open, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	tw(winCorner, { CornerRadius = UDim.new(0, 22) }, T.open, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	tw(bg,        { ImageTransparency = 1, BackgroundTransparency = 0.08 }, T.open, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	tw(overlay,   { BackgroundTransparency = 0.65 }, T.open, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	tw(winStroke, { Transparency = 0.6 }, T.open, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	chrome.Visible = true
	groupFadeSet(chrome, 1)
	groupFade(chrome, 0, T.open * 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, T.open * 0.35)

	task.delay(T.mid, function()
		if token ~= anim.token then return end
		island.Visible = false
	end)
	winTween.Completed:Connect(function(playState)
		if token ~= anim.token then return end
		anim.animating = (playState ~= Enum.PlaybackState.Completed)
	end)
end

closeHub = function()
	if not isOpen or unloaded then return end
	isOpen = false
	anim.token += 1
	anim.animating = true
	local token = anim.token

	groupFade(chrome, 1, T.close * 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	IXA_CloseSearch()

	island.Visible = true
	for _, f in ipairs(islandFadeables) do f[1][f[2]] = 1 end
	logoIcon.ImageTransparency = 1
	cometGlow.ImageTransparency = 1
	for _, trail in ipairs(cometTrail) do trail.ImageTransparency = 1 end

	BlurTarget = 0.85

	local winTween = tw(window, {
		Position = islandPos(),
		Size = UDim2.fromOffset(ISLAND_W, ISLAND_H),
		BackgroundTransparency = 0.15,
	}, T.close, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

	tw(winCorner, { CornerRadius = UDim.new(0, 18) }, T.close, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	tw(bg,        { ImageTransparency = 1, BackgroundTransparency = 1 }, T.close, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	tw(overlay,   { BackgroundTransparency = 1 }, T.close, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	tw(winStroke, { Transparency = 1 }, T.close, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

	fadeIsland(false, T.close * 0.6, T.close * 0.35)

	task.delay(T.close * 0.35, function()
		if token ~= anim.token then return end
		islandScale.Scale = 0.75
		tw(islandScale, { Scale = 1 }, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end)

	winTween.Completed:Connect(function(playState)
		if token ~= anim.token then return end
		window.Visible = false
		chrome.Visible = false
		anim.animating = (playState ~= Enum.PlaybackState.Completed)
	end)
end

toggleFull = function()
	if unloaded then return end
	if not isOpen or anim.animating then return end
	local v = vp()
	if not isFull then
		local w = window.AbsoluteSize.X
		local h = window.AbsoluteSize.Y
		local cx = window.Position.X.Offset
		local top = window.Position.Y.Offset
		fullRect = { x = cx, y = top, w = w, h = h }
		local nw, nh = fullSizeFit()
		local centerY = top + h / 2
		local newTop = math.clamp(centerY - nh / 2, 8, math.max(8, v.Y - nh - 8))
		local pos = clampWindowPos(Vector2.new(cx, newTop), nw, nh)
		tw(window, {
			Position = UDim2.new(0.5, pos.X, 0, pos.Y),
			Size = UDim2.fromOffset(nw, nh),
		}, T.mid, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		isFull = true
	else
		isFull = false
		local r = fullRect or { x = 0, y = 40, w = W, h = H }
		local pos = clampWindowPos(Vector2.new(r.x, r.y), r.w, r.h)
		tw(window, {
			Position = UDim2.new(0.5, pos.X, 0, pos.Y),
			Size = UDim2.fromOffset(r.w, r.h),
		}, T.mid, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end
end

cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	if unloaded then return end
	IXA_FitViewport()
	if window.Visible and not isFull and not anim.animating then
		local pos = clampWindowPos(Vector2.new(window.Position.X.Offset, window.Position.Y.Offset), W, H)
		tw(window, {
			Position = UDim2.new(0.5, pos.X, 0, pos.Y),
			Size = UDim2.fromOffset(W, H),
		}, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end
end)

local islandStretchLast = nil
connectDrag(island,
	function()
		islandDrag.active = true
		islandDrag.origin = islandDrag.current
		islandStretchLast = nil
	end,
	function(delta)
		islandDrag.target = clampIslandOffset(islandDrag.origin + delta)
	end,
	function(moved)
		islandDrag.active = false
		islandStretchLast = nil
		if not moved then openHub() end
	end
)
connectDrag(header,
	function()
		local p = Vector2.new(window.Position.X.Offset, window.Position.Y.Offset)
		windowDrag.origin = p
		windowDrag.current = p
		windowDrag.target = p
		windowDrag.active = true
		cancelTweens(window)
	end,
	function(delta)
		windowDrag.target = clampWindowPos(
			windowDrag.origin + delta,
			window.AbsoluteSize.X,
			window.AbsoluteSize.Y
		)
	end,
	function() windowDrag.active = false end
)

RunService.Heartbeat:Connect(function(dt)
	if islandDrag.active or islandDrag.current ~= islandDrag.target then
		local alpha = math.min(1, dt * 14)
		local n = islandDrag.current:Lerp(islandDrag.target, alpha)
		if not islandDrag.active and (islandDrag.target - n).Magnitude < 0.5 then
			n = islandDrag.target
		end
		islandDrag.current = n
		islandOffset = n
		island.Position = islandPos()
	end
	if islandDrag.active then
		local mp = Vector2.new(mouse.X, mouse.Y)
		local fd = mp - (islandStretchLast or mp)
		islandStretchLast = mp
		pushStretch(fd.X, fd.Y)
	end
	if island.Visible then
		stretch.tx *= 0.8
		stretch.ty *= 0.8
		local a2 = 1 - math.exp(-dt * 22)
		stretch.x += (stretch.tx - stretch.x) * a2
		stretch.y += (stretch.ty - stretch.y) * a2
		local fx = stretch.x - stretch.y * 0.3
		local fy = stretch.y - stretch.x * 0.3
		if math.abs(fx) > 0.25 or math.abs(fy) > 0.25 then
			islandVisual.Size = UDim2.new(1, fx, 1, fy)
		else
			islandVisual.Size = UDim2.new(1, 0, 1, 0)
		end
	end
	if windowDrag.active or windowDrag.current ~= windowDrag.target then
		local alpha = math.min(1, dt * 14)
		local n = windowDrag.current:Lerp(windowDrag.target, alpha)
		if not windowDrag.active and (windowDrag.target - n).Magnitude < 0.5 then
			n = windowDrag.target
		end
		windowDrag.current = n
		window.Position = UDim2.new(0.5, n.X, 0, n.Y)
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		if unloaded then return end
		if isOpen then closeHub() else openHub() end
	end
end)

do
	local IDLE_AFTER = 10
	local idleTarget   = 0
	local idleAlpha    = 0
	local lastActivity = os.clock()
	local function bumpActivity()
		lastActivity = os.clock()
		idleTarget = 0
	end
	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.MouseButton2
		or input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.Keyboard then
			bumpActivity()
		end
	end)
	RunService.RenderStepped:Connect(function(dt)
		if unloaded or not gui.Parent then return end
		if idleTarget == 0 and (os.clock() - lastActivity) >= IDLE_AFTER then
			idleTarget = 0.5
		end
		local speed = (idleTarget > idleAlpha) and 3.5 or 11
		idleAlpha += (idleTarget - idleAlpha) * math.min(dt * speed, 1)
		if math.abs(idleAlpha - idleTarget) < 0.002 then idleAlpha = idleTarget end
		islandVisual.BackgroundTransparency = 0.28 + idleAlpha * 0.5
		chrome.GroupTransparency = idleAlpha
	end)
end

do
	local t0 = os.clock()
	RunService.RenderStepped:Connect(function()
		if unloaded then return end
		if not island.Visible or window.Visible or anim.animating then return end
		local t = os.clock() - t0
		local pulse = (math.sin(t * math.pi * 2 / 1.2) + 1) / 2
		islandGlow.Thickness = 1.25 + pulse * 0.35
		islandGlow.Transparency = math.max(0.3, 0.5 - pulse * 0.18)
	end)
end

toast("Ixa Hub GUI loaded - press Right Shift")
end)()
