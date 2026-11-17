local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local _sid = setthreadidentity or setidentity or set_thread_identity or (syn and syn.set_thread_identity)
if _sid then
    pcall(function()
        _sid(8)
    end)
end

local okEnv, ENV = pcall(function()
    return (getgenv and getgenv()) or _G
end)
if not okEnv or type(ENV) ~= "table" then
    ENV = _G
end
local REG_KEY = "__cfg"
local REG = ENV[REG_KEY]
if type(REG) ~= "table" then
    REG = {}
    ENV[REG_KEY] = REG
end
if REG.gui then
    pcall(function()
        REG.gui:Destroy()
    end)
    REG.gui = nil
end

local function pick_parent()
    local ok, hidden = pcall(function()
        return gethui and gethui()
    end)
    if ok and typeof(hidden) == "Instance" then
        return hidden
    end
    local ok2, core = pcall(function()
        local cg = game:GetService("CoreGui")
        local probe = Instance.new("Folder")
        probe.Parent = cg
        probe:Destroy()
        return cg
    end)
    if ok2 and typeof(core) == "Instance" then
        return core
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end
local UI_PARENT = pick_parent()

local function try_protect(g)
    local getters = {
        function()
            return syn and syn.protect_gui
        end,
        function()
            return protect_gui
        end,
        function()
            return fluxus and fluxus.protect_gui
        end,
    }
    for _, get in ipairs(getters) do
        local ok, fn = pcall(get)
        if ok and type(fn) == "function" then
            if pcall(fn, g) then
                return true
            end
        end
    end
    return false
end

local function rnd(n)
    local s = ""
    for _ = 1, n do
        s ..= string.format("%x", math.random(0, 15))
    end
    return s
end
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera or workspace:WaitForChild("Camera")

local COMET_ID = "rbxassetid://122212432133342"
local GUI_NAME = "IxaHub"
local HUB_TITLE = "IXA HUB"
local HUB_SUBTITLE = "clean GUI shell"

local guiRoot = player:WaitForChild("PlayerGui")
local stale = guiRoot:FindFirstChild(GUI_NAME)
if stale then
    stale:Destroy()
end
if REG.gui then
    pcall(function()
        REG.gui:Destroy()
    end)
    REG.gui = nil
end

local C = {
    Window = Color3.fromRGB(13,
    14,
    17),
    Surface = Color3.fromRGB(19,
    20,
    24),
    Surface2 = Color3.fromRGB(26,
    27,
    32),
    Glass = Color3.fromRGB(27,
    28,
    33),
    Hair = Color3.fromRGB(50,
    52,
    60),
    HairHi = Color3.fromRGB(86,
    88,
    100),
    On = Color3.fromRGB(246,
    176,
    76),
    Blue = Color3.fromRGB(126,
    160,
    216),
    Text = Color3.fromRGB(243,
    241,
    236),
    Dim = Color3.fromRGB(154,
    154,
    162),
    Faint = Color3.fromRGB(100,
    102,
    112),
    White = Color3.fromRGB(255,
    255,
    255),
    Accent = Color3.fromRGB(205,
    121,
    39),
    Ember = Color3.fromRGB(255,
    214,
    140),
    Lamp = Color3.fromRGB(255,
    237,
    198),
    Good = Color3.fromRGB(122,
    222,
    166),
    Bad = Color3.fromRGB(224,
    104,
    96),
}

local BUILD_TAG = "2.4"
local EXEC_NAME = "Unknown"
do
    local ok, name = pcall(function()
        if type(identifyexecutor) == "function" then
            return identifyexecutor()
        end
        if type(getexecutorname) == "function" then
            return getexecutorname()
        end
    end)
    if ok and type(name) == "string" and name ~= "" then
        EXEC_NAME = name
    end
end

local T = { fast = 0.14, mid = 0.28, open = 0.40, close = 0.34 }
local FULL_SCALE = 1.3

local FALLBACK_FONT = Font.fromEnum(Enum.Font.GothamMedium)
local function makeFont(families, weightName)
    for _, fam in ipairs(families) do
        local ok, font = pcall(function()
            local famEnum = (Enum.FontFamily :: any)[fam]
            if famEnum == nil then
                return nil
            end
            local weightEnum = (Enum.FontWeight :: any)[weightName] or Enum.FontWeight.Regular
            return Font.new(famEnum, weightEnum)
        end)
        if ok and font then
            return font
        end
    end
    return FALLBACK_FONT
end
local uiReg = makeFont({ "GothamSSm", "Nunito", "Fredoka" }, "Medium")
local uiMed = makeFont({ "GothamSSm", "Nunito", "Fredoka" }, "Bold")
local uiBold = makeFont({ "GothamSSm", "Nunito", "Fredoka" }, "Black")

local NL_ICON_REGULAR = Font.new("rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
local ICON_MAP = {
    ["swords"] = "sword",
    ["footprints"] = "person-running",
    ["eye"] = "eye",
    ["crosshair"] = "crosshairs",
    ["party-popper"] = "star",
    ["drama"] = "person",
    ["wrench"] = "gear",
    ["wheat"] = "flag",
    ["settings"] = "gear",
    ["save"] = "floppy-disk",
    ["minus"] = "minus",
    ["maximize-2"] = "dual-arrows-to-corners",
    ["x"] = "x",
    ["zap"] = "lightning-bolt",
    ["wifi"] = "signal-exclamation",
    ["search"] = "magnifying-glass",
    ["plus"] = "plus-large",
    ["trash-2"] = "trash-can",
    ["check"] = "check",
    ["chevron-down"] = "chevron-down",
    ["chevron-right"] = "chevron-right",
    ["arrow-up-right"] = "arrow-up-right",
    ["clock"] = "clock",
    ["timer"] = "timer",
    ["gauge"] = "gauge",
    ["activity"] = "activity",
    ["message-circle"] = "message-circle",
    ["discord"] = "message-circle",
    ["user"] = "person",
    ["user-x"] = "user-x",
    ["eye-off"] = "eye-off",
    ["copy"] = "copy",
    ["layout-grid"] = "layout-grid",
    ["shield-check"] = "shield-check",
    ["house"] = "house",
    ["star"] = "star",
    ["sparkles"] = "sparkles",
    ["dot"] = "dot",
}
local function setIcon(holder, name, color)
    if not holder then
        return
    end
    if not holder:IsA("TextLabel") then
        local lbl = holder:FindFirstChild("NLIcon")
        if not lbl then
            lbl = Instance.new("TextLabel")
            lbl.Name = "NLIcon"
            pcall(function()
                lbl.AutoLocalize = false
            end)
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
    pcall(function()
        inst.AutoLocalize = false
    end)
    for k, v in pairs(props or {}) do
        pcall(function()
            inst[k] = v
        end)
    end
    pcall(function()
        inst:SetAttribute("bBT", inst.BackgroundTransparency)
    end)
    pcall(function()
        inst:SetAttribute("bTT", inst.TextTransparency)
    end)
    pcall(function()
        inst:SetAttribute("bIT", inst.ImageTransparency)
    end)
    pcall(function()
        inst:SetAttribute("bST", inst.Transparency)
    end)
    return inst
end

local tweenRegistry = setmetatable({}, { __mode = "k" })
local function cancelTweens(inst)
    local list = tweenRegistry[inst]
    if list then
        for _, t in ipairs(list) do
            if t.PlaybackState ~= Enum.PlaybackState.Completed then
                t:Cancel()
            end
        end
        tweenRegistry[inst] = nil
    end
end
local function tw(inst, props, time, style, dir, delayTime)
    cancelTweens(inst)
    local t = TweenService:Create(inst, TweenInfo.new(time or T.mid, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out, 0, false, delayTime or 0), props)
    local list = tweenRegistry[inst]
    if not list then
        list = {}
        tweenRegistry[inst] = list
    end
    table.insert(list, t)
    t:Play()
    return t
end

local function round(v)
    return math.floor(v + 0.5)
end
local function vp()
    return cam.ViewportSize
end

local function groupFadeProps(d, fade)
    local props = {}
    local bBT = d:GetAttribute("bBT")
    if bBT ~= nil and bBT < 1 then
        props.BackgroundTransparency = bBT + (1 - bBT) * fade
    end
    if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
        local bTT = d:GetAttribute("bTT")
        if bTT ~= nil and bTT < 1 then
            props.TextTransparency = bTT + (1 - bTT) * fade
        end
    end
    if d:IsA("ImageLabel") or d:IsA("ImageButton") then
        local bIT = d:GetAttribute("bIT")
        if bIT ~= nil and bIT < 1 then
            props.ImageTransparency = bIT + (1 - bIT) * fade
        end
    end
    if d:IsA("UIStroke") then
        local bST = d:GetAttribute("bST")
        if bST ~= nil and bST < 1 then
            props.Transparency = bST + (1 - bST) * fade
        end
    end
    return props
end
local function withRoot(root)
    local all = { root }
    for _, d in ipairs(root:GetDescendants()) do
        table.insert(all, d)
    end
    return all
end
local function groupFadeSet(root, fade)
    for _, d in ipairs(withRoot(root)) do
        for k, v in pairs(groupFadeProps(d, fade)) do
            d[k] = v
        end
    end
end
local function groupFade(root, fade, time, style, dir, delay)
    for _, d in ipairs(withRoot(root)) do
        local props = groupFadeProps(d, fade)
        if next(props) then
            tw(d, props, time, style, dir, delay)
        end
    end
end

local function tap(inst, cb)
    local down = nil
    inst.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            down = Vector2.new(mouse.X, mouse.Y)
        end
    end)
    inst.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and down ~= nil then
            local d = Vector2.new(mouse.X, mouse.Y) - down
            down = nil
            if d.Magnitude < 6 then
                cb()
            end
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
        if not DRAG_TYPES[input.UserInputType] then
            return
        end
        local origin = Vector2.new(mouse.X, mouse.Y)
        local moved = false
        local moveConn = UserInputService.InputChanged:Connect(function(ch)
            if ch.UserInputType == Enum.UserInputType.MouseMovement or ch.UserInputType == Enum.UserInputType.Touch then
                local d = Vector2.new(mouse.X, mouse.Y) - origin
                if not moved and d.Magnitude > DRAG_CLICK_THRESHOLD then
                    moved = true
                    if onStart then
                        onStart()
                    end
                end
                if moved and onMove then
                    onMove(d)
                end
            end
        end)
        local endConn
        endConn = UserInputService.InputEnded:Connect(function(ch)
            if ch.UserInputType == input.UserInputType then
                moveConn:Disconnect()
                endConn:Disconnect()
                if onDone then
                    onDone(moved)
                end
            end
        end)
    end)
end

local function pointIn(inst, p)
    if not inst or not inst.Visible then
        return false
    end
    local pos, size = inst.AbsolutePosition, inst.AbsoluteSize
    return p.X >= pos.X and p.X <= pos.X + size.X and p.Y >= pos.Y and p.Y <= pos.Y + size.Y
end

local openHub, closeHub, toggleFull, switchTab, buildTab
local activeTab = 1
local isOpen = false
local unloaded = false

IXA_UI_STATE = IXA_UI_STATE or {}

uiRefs = uiRefs or {}

IXAL_Keys = IXAL_Keys or {}

local gui = new("ScreenGui", {
    Name = "_g" .. rnd(6),
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 9999,
    IgnoreGuiInset = true,
})
try_protect(gui)
local parented = pcall(function()
    gui.Parent = UI_PARENT
end)
if not parented then
    UI_PARENT = guiRoot
    gui.Parent = UI_PARENT
end
REG.gui = gui
try_protect(gui)

local toasts = new("Frame", {
    AnchorPoint = Vector2.new(0.5,
    1),
    Position = UDim2.new(0.5,
    0,
    1,
    -20),
    Size = UDim2.fromOffset(340,
    280),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = gui,
})
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    Padding = UDim.new(0,
    8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = toasts,
})
local toastOrder = 0
local function toast(msg)
    toastOrder = toastOrder + 1
    local box = new("Frame", {
        ZIndex = 20,
        Size = UDim2.new(1,
        0,
        0,
        40),
        BackgroundColor3 = C.Surface2,
        BackgroundTransparency = 1,
        LayoutOrder = toastOrder,
        BorderSizePixel = 0,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = box })
    local stroke = new("UIStroke", { Color = C.Hair, Transparency = 1, Thickness = 1, Parent = box })
    local accentBar = new("Frame", {
        ZIndex = 21,
        Active = false,
        AnchorPoint = Vector2.new(0,
        0.5),
        Size = UDim2.new(0,
        3,
        1,
        -16),
        Position = UDim2.new(0,
        10,
        0.5,
        0),
        BackgroundColor3 = C.On,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = box,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = accentBar })
    local icon = new("TextLabel", {
        ZIndex = 21,
        Active = false,
        Size = UDim2.fromOffset(14,
        14),
        Position = UDim2.new(0,
        20,
        0.5,
        -7),
        BackgroundTransparency = 1,
        Text = "",
        TextSize = 13,
        FontFace = NL_ICON_REGULAR,
        TextColor3 = C.On,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = box,
    })
    setIcon(icon, "sparkles", C.On)
    local label = new("TextLabel", {
        ZIndex = 21,
        Active = false,
        Size = UDim2.new(1,
        -54,
        1,
        0),
        Position = UDim2.new(0,
        42,
        0,
        0),
        BackgroundTransparency = 1,
        Text = msg,
        TextColor3 = C.Text,
        TextTransparency = 1,
        FontFace = uiMed,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    label.Parent = box
    box.Parent = toasts
    local scale = new("UIScale", { Scale = 0.96, Parent = box })
    tw(scale, { Scale = 1 }, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tw(box, { BackgroundTransparency = 0.04 }, 0.18)
    tw(label, { TextTransparency = 0 }, 0.18)
    tw(icon, { TextTransparency = 0 }, 0.18)
    tw(accentBar, { BackgroundTransparency = 0 }, 0.18)
    tw(stroke, { Transparency = 0.7 }, 0.18)
    task.delay(1.7, function()
        if not box.Parent then
            return
        end
        tw(box, { BackgroundTransparency = 1 }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tw(label, { TextTransparency = 1 }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tw(icon, { TextTransparency = 1 }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tw(accentBar, { BackgroundTransparency = 1 }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tw(stroke, { Transparency = 1 }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.35, function()
            box:Destroy()
        end)
    end)
end

local W, H = 820, 470
IXA_FitViewport = function()
    local v = vp()
    if v.X < 50 or v.Y < 50 then
        return
    end
    W = math.clamp(v.X - 28, 440, 820)
    H = math.clamp(v.Y - 52, 240, 470)
end
IXA_FitViewport()
local ISLAND_W = 468
local ISLAND_H = 34
local ISLAND_TOP = 14
local islandOffset = Vector2.new(0, 0)
local function islandPos()
    return UDim2.new(0.5, -ISLAND_W / 2 + islandOffset.X, 0, ISLAND_TOP + islandOffset.Y)
end
local function normPos()
    return UDim2.new(0.5, 0, 0, 40)
end
local function normSize()
    return UDim2.fromOffset(W, H)
end
local function fullSizeFit()
    local v = vp()
    local scale = math.min(FULL_SCALE, (v.X - 24) / W, (v.Y - 24) / H)
    scale = math.max(1.05, scale)
    local nw = math.min(W * scale, v.X - 16)
    local nh = math.min(H * scale, v.Y - 16)
    return nw, nh
end

local ISLAND_BG = Color3.fromRGB(12, 13, 16)

local LIVE = { fps = 0, ping = nil }

local islandEntrance = function() end

local island = new("Frame", {
    Name = "Island",
    AnchorPoint = Vector2.new(0.5,
    0),
    Position = islandPos(),
    Size = UDim2.fromOffset(ISLAND_W,
    ISLAND_H),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Visible = false,
    Parent = gui,
})

local islandVisual = new("Frame", {
    Name = "IslandVisual",
    AnchorPoint = Vector2.new(0.5,
    0.5),
    Position = UDim2.new(0.5,
    0,
    0.5,
    0),
    Size = UDim2.new(1,
    0,
    1,
    0),
    BackgroundColor3 = ISLAND_BG,
    BackgroundTransparency = 0.22,
    BorderSizePixel = 0,
    Parent = island,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = islandVisual })

local glassTop = new("Frame", {
    Name = "GlassTop",
    Size = UDim2.new(1,
    0,
    0.55,
    0),
    Position = UDim2.new(0,
    0,
    0,
    0),
    BackgroundColor3 = Color3.fromRGB(190,
    190,
    200),
    BackgroundTransparency = 0.94,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = islandVisual,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = glassTop })
new("UIGradient", {
    Rotation = 90,
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,
        0),
        NumberSequenceKeypoint.new(1,
        1),
    }),
    Parent = glassTop,
})

local glassBottom = new("Frame", {
    Name = "GlassBottom",
    Size = UDim2.new(1,
    0,
    0.35,
    0),
    Position = UDim2.new(0,
    0,
    0.65,
    0),
    BackgroundColor3 = Color3.fromRGB(125,
    122,
    132),
    BackgroundTransparency = 0.95,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = islandVisual,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = glassBottom })

local stretch = { x = 0, y = 0, tx = 0, ty = 0 }
local function pushStretch(dx, dy)
    stretch.tx = math.clamp(stretch.tx + dx * 0.9, -40, 40)
    stretch.ty = math.clamp(stretch.ty + dy * 0.9, -40, 40)
end

local islandGlow = new("UIStroke", {
    Color = C.On,
    Transparency = 0.38,
    Thickness = 1.1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Parent = islandVisual,
})
local islandScale = new("UIScale", { Scale = 1, Parent = islandVisual })

local logoHolder = new("Frame", {
    Active = false,
    Size = UDim2.fromOffset(40,
    26),
    AnchorPoint = Vector2.new(0,
    0.5),
    Position = UDim2.new(0,
    6,
    0.5,
    0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 3,
    Parent = islandVisual,
})

local logoIcon = new("ImageLabel", {
    Name = "CometIcon",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Image = COMET_ID,
    Size = UDim2.fromOffset(46,
    30),
    Position = UDim2.fromOffset(-46,
    -30),
    ScaleType = Enum.ScaleType.Fit,
    ImageColor3 = Color3.fromRGB(255,
    255,
    255),
    ImageTransparency = 1,
    ZIndex = 4,
    Parent = logoHolder,
})

local cometGlow = new("ImageLabel", {
    Name = "CometGlow",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Image = COMET_ID,
    Size = UDim2.fromOffset(52,
    34),
    Position = UDim2.fromOffset(-49,
    -32),
    ScaleType = Enum.ScaleType.Fit,
    ImageColor3 = Color3.fromRGB(255,
    206,
    120),
    ImageTransparency = 1,
    ZIndex = 3,
    Parent = logoHolder,
})

local cometTrail = {}
local cometTrailSamples = {}
for i = 1, 3 do
    cometTrail[i] = new("ImageLabel", {
        Name = "CometTrail" .. i,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = COMET_ID,
        Size = UDim2.fromOffset(46,
        30),
        Position = UDim2.fromOffset(-46,
        -30),
        ScaleType = Enum.ScaleType.Fit,
        ImageColor3 = Color3.fromRGB(255,
        224,
        170),
        ImageTransparency = 1,
        ZIndex = 3,
        Parent = logoHolder,
    })
end

local cometAnimToken = 0
local cometAnimating = false
local function strikeComet()
    if cometAnimating or unloaded or not logoIcon.Parent or isOpen or not island.Visible then
        return
    end
    cometAnimating = true
    cometAnimToken += 1
    local token = cometAnimToken

    task.spawn(function()
        local function hideComet()
            logoIcon.ImageTransparency = 1
            cometGlow.ImageTransparency = 1
            for _, trail in ipairs(cometTrail) do
                trail.ImageTransparency = 1
            end
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
            if cancelled() then
                return
            end
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
                if #cometTrailSamples > 30 then
                    table.remove(cometTrailSamples, 1)
                end
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
            if k >= 1 then
                break
            end
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

task.delay(0.35, function()
    strikeComet()
end)
task.spawn(function()
    while gui.Parent and not unloaded do
        task.wait(math.random(85, 115) / 10)
        if not unloaded and logoHolder.Parent and not isOpen and island.Visible then
            strikeComet()
        end
    end
end)

local lastHoverComet = 0
island.MouseEnter:Connect(function()
    local now = os.clock()
    if now - lastHoverComet < 2 then
        return
    end
    lastHoverComet = now
    strikeComet()
end)

local islandLabel = new("TextLabel", {
    Active = false,
    Size = UDim2.new(0,
    70,
    1,
    0),
    Position = UDim2.new(0,
    48,
    0,
    0),
    BackgroundTransparency = 1,
    Text = 'IXA <font color="#F6B04C">HUB</font>',
    RichText = true,
    TextColor3 = C.Text,
    FontFace = uiBold,
    TextSize = 12.5,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
    Parent = islandVisual,
})

local islandFadeables = {
    { islandVisual, "BackgroundTransparency", 0.22 },
    { glassTop, "BackgroundTransparency", 0.94 },
    { glassBottom, "BackgroundTransparency", 0.95 },
    { islandGlow, "Transparency", 0.38 },
    { islandLabel, "TextTransparency", 0 },
}
local function regFade(inst, prop, rest)
    table.insert(islandFadeables, { inst, prop, rest })
end

local function segDivider(x)
    local d = new("Frame", {
        Active = false,
        AnchorPoint = Vector2.new(0,
        0.5),
        Size = UDim2.fromOffset(1,
        13),
        Position = UDim2.new(0,
        x,
        0.5,
        0),
        BackgroundColor3 = C.Hair,
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = islandVisual,
    })
    regFade(d, "BackgroundTransparency", 0.45)
    return d
end

local function makeSeg(x, icon, valW, cap, capW)
    local ic = new("TextLabel", {
        Active = false,
        AnchorPoint = Vector2.new(0,
        0.5),
        Size = UDim2.fromOffset(13,
        13),
        Position = UDim2.new(0,
        x,
        0.5,
        0),
        BackgroundTransparency = 1,
        Text = "",
        TextSize = 13,
        FontFace = NL_ICON_REGULAR,
        TextColor3 = C.Faint,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 4,
        Parent = islandVisual,
    })
    setIcon(ic, icon, C.Faint)
    regFade(ic, "TextTransparency", 0)
    local val = new("TextLabel", {
        Active = false,
        AnchorPoint = Vector2.new(0,
        0.5),
        Size = UDim2.fromOffset(valW,
        15),
        Position = UDim2.new(0,
        x + 16,
        0.5,
        -1),
        BackgroundTransparency = 1,
        Text = "--",
        TextColor3 = C.Text,
        FontFace = uiBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = islandVisual,
    })
    regFade(val, "TextTransparency", 0)
    local capL = new("TextLabel", {
        Active = false,
        AnchorPoint = Vector2.new(0,
        0.5),
        Size = UDim2.fromOffset(capW,
        12),
        Position = UDim2.new(0,
        x + 16 + valW + 3,
        0.5,
        0),
        BackgroundTransparency = 1,
        Text = cap,
        TextColor3 = C.Dim,
        FontFace = uiMed,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = islandVisual,
    })
    regFade(capL, "TextTransparency", 0)
    return val
end

segDivider(118)
local segFpsVal = makeSeg(124, "chart-line", 30, "FPS", 24)
segDivider(203)
local segPlVal = makeSeg(209, "person", 36, "PLAYERS", 48)
segDivider(318)
local segPingVal = makeSeg(324, "wifi", 30, "MS", 20)

local keyChip = new("Frame", {
    Active = false,
    AnchorPoint = Vector2.new(0,
    0.5),
    Size = UDim2.fromOffset(58,
    18),
    Position = UDim2.new(0,
    404,
    0.5,
    0),
    BackgroundColor3 = C.Surface2,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    ZIndex = 3,
    Parent = islandVisual,
})
new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = keyChip })
local keyStroke = new("UIStroke", { Color = C.On, Transparency = 0.72, Thickness = 1, Parent = keyChip })
regFade(keyChip, "BackgroundTransparency", 0.25)
regFade(keyStroke, "Transparency", 0.72)
local keyChipText = new("TextLabel", {
    Active = false,
    Size = UDim2.new(1,
    0,
    1,
    0),
    BackgroundTransparency = 1,
    Text = "RShift",
    TextColor3 = C.Lamp,
    FontFace = uiMed,
    TextSize = 9.5,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
    ZIndex = 4,
    Parent = keyChip,
})
regFade(keyChipText, "TextTransparency", 0.1)

local function clampIslandOffset(off)
    local v = vp()
    local maxX = math.max(0, v.X / 2 - ISLAND_W / 2 - 8)
    local minY = 8 - ISLAND_TOP
    local maxY = math.max(minY, v.Y - ISLAND_H - 8 - ISLAND_TOP)
    return Vector2.new(math.clamp(off.X, -maxX, maxX), math.clamp(off.Y, minY, maxY))
end

local islandDrag = {
    active = false,
    origin = Vector2.new(0,
    0),
    target = islandOffset,
    current = islandOffset,
}

local window = new("Frame", {
    Name = "Window",
    AnchorPoint = Vector2.new(0.5,
    0),
    Position = islandPos(),
    Size = UDim2.fromOffset(ISLAND_W,
    ISLAND_H),
    BackgroundColor3 = C.Window,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    Visible = false,
    Parent = gui,
})
local winCorner = new("UICorner", { CornerRadius = UDim.new(0, 20), Parent = window })
local winStroke = new("UIStroke", {
    Color = C.White,
    Transparency = 0.72,
    Thickness = 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Parent = window,
})
new("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,
        Color3.fromRGB(128,
        118,
        98)),
        ColorSequenceKeypoint.new(0.32,
        Color3.fromRGB(56,
        57,
        64)),
        ColorSequenceKeypoint.new(1,
        Color3.fromRGB(28,
        29,
        34)),
    }),
    Parent = winStroke,
})

local bg = new("ImageLabel", {
    Active = false,
    Size = UDim2.new(1,
    0,
    1,
    0),
    Image = "",
    ScaleType = Enum.ScaleType.Crop,
    ImageTransparency = 1,
    BackgroundColor3 = C.Window,
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    Parent = window,
})
new("UICorner", { CornerRadius = UDim.new(0, 20), Parent = bg })
new("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,
        Color3.fromRGB(22,
        23,
        28)),
        ColorSequenceKeypoint.new(0.58,
        Color3.fromRGB(15,
        16,
        19)),
        ColorSequenceKeypoint.new(1,
        Color3.fromRGB(10,
        10,
        13)),
    }),
    Parent = bg,
})

local overlay = new("Frame", {
    Active = false,
    Size = UDim2.new(1,
    0,
    1,
    0),
    BackgroundColor3 = C.Window,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = window,
})
new("UICorner", { CornerRadius = UDim.new(0, 20), Parent = overlay })

local chrome = new("CanvasGroup", {
    Name = "Chrome",
    Size = UDim2.new(1,
    0,
    1,
    0),
    BackgroundTransparency = 1,
    Visible = false,
    BorderSizePixel = 0,
    Parent = window,
})

local header = new("Frame", {
    Name = "Header",
    Size = UDim2.new(1,
    -24,
    0,
    52),
    Position = UDim2.new(0,
    12,
    0,
    4),
    BackgroundTransparency = 1,
    Active = true,
    BorderSizePixel = 0,
    Parent = chrome,
})

local headRule = new("Frame", {
    Active = false,
    Size = UDim2.new(1,
    -24,
    0,
    1),
    Position = UDim2.new(0,
    12,
    0,
    60),
    BackgroundColor3 = C.Hair,
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    Parent = chrome,
})
new("UIGradient", {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,
        1),
        NumberSequenceKeypoint.new(0.1,
        0.35),
        NumberSequenceKeypoint.new(0.9,
        0.35),
        NumberSequenceKeypoint.new(1,
        1),
    }),
    Parent = headRule,
})

local headAvaRing = new("Frame", {
    Active = false,
    Size = UDim2.fromOffset(32,
    32),
    Position = UDim2.new(0,
    16,
    0.5,
    -16),
    BackgroundColor3 = C.Surface2,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    Parent = header,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = headAvaRing })
local headRingStroke = new("UIStroke", {
    Color = C.HairHi,
    Transparency = 0.45,
    Thickness = 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Parent = headAvaRing,
})
local headAva = new("ImageLabel", {
    Active = false,
    Size = UDim2.new(1,
    -4,
    1,
    -4),
    Position = UDim2.new(0,
    2,
    0,
    2),
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(player.UserId) .. "&w=150&h=150",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = headAvaRing,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = headAva })
local headStatus = new("Frame", {
    Active = false,
    AnchorPoint = Vector2.new(1,
    1),
    Size = UDim2.fromOffset(9,
    9),
    Position = UDim2.new(1,
    1,
    1,
    1),
    BackgroundColor3 = C.Window,
    BorderSizePixel = 0,
    Parent = headAvaRing,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = headStatus })
local headStatusDot = new("Frame", {
    Active = false,
    Size = UDim2.new(1,
    -4,
    1,
    -4),
    Position = UDim2.new(0,
    2,
    0,
    2),
    BackgroundColor3 = C.Good,
    BorderSizePixel = 0,
    Parent = headStatus,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = headStatusDot })

local brand = new("CanvasGroup", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0,
    58,
    0,
    0),
    Size = UDim2.new(0,
    210,
    1,
    0),
    BorderSizePixel = 0,
    Parent = header,
})
new("TextLabel", {
    Active = false,
    Size = UDim2.new(1,
    0,
    0,
    18),
    Position = UDim2.new(0,
    0,
    0,
    7),
    BackgroundTransparency = 1,
    Text = 'IXA <font color="#F6B04C">HUB</font>',
    RichText = true,
    TextColor3 = C.Text,
    FontFace = uiBold,
    TextSize = 14.5,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = brand,
})
new("TextLabel", {
    Active = false,
    Size = UDim2.new(1,
    0,
    0,
    14),
    Position = UDim2.new(0,
    0,
    0,
    25),
    BackgroundTransparency = 1,
    Text = "@" .. player.Name .. " · v" .. BUILD_TAG,
    TextColor3 = C.Faint,
    FontFace = uiMed,
    TextSize = 10.5,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    Parent = brand,
})

local telemetry = new("CanvasGroup", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1,
    0.5),
    Position = UDim2.new(1,
    -140,
    0.5,
    0),
    Size = UDim2.fromOffset(190,
    28),
    BorderSizePixel = 0,
    Parent = header,
})
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0,
    10),
    Parent = telemetry,
})
local function telemetryCell(caption, width, order)
    local cell = new("Frame", {
        Active = false,
        Size = UDim2.fromOffset(width,
        28),
        LayoutOrder = order,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = telemetry,
    })
    new("TextLabel", {
        Active = false,
        Size = UDim2.new(1,
        0,
        0,
        10),
        Position = UDim2.new(0,
        0,
        0,
        1),
        BackgroundTransparency = 1,
        Text = caption,
        TextColor3 = C.Faint,
        FontFace = uiBold,
        TextSize = 8.5,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = cell,
    })
    local value = new("TextLabel", {
        Active = false,
        Size = UDim2.new(1,
        0,
        0,
        15),
        Position = UDim2.new(0,
        0,
        0,
        12),
        BackgroundTransparency = 1,
        Text = "--",
        TextColor3 = C.Text,
        FontFace = uiBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = cell,
    })
    return value
end
local function telemetryDivider(order)
    new("Frame", {
        Active = false,
        Size = UDim2.fromOffset(1,
        14),
        LayoutOrder = order,
        BackgroundColor3 = C.Hair,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = telemetry,
    })
end
local pingLbl = telemetryCell("PING", 42, 1)
telemetryDivider(2)
local fpsLbl = telemetryCell("FPS", 36, 3)
telemetryDivider(4)
local plLbl = telemetryCell("PLAYERS", 58, 5)

task.spawn(function()
    while gui.Parent and not unloaded do
        local ok, ping = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]: GetValue()
        end)
        if ok and type(ping) == "number" then
            LIVE.ping = math.floor(ping + 0.5)
            pingLbl.Text = tostring(LIVE.ping)
        else
            LIVE.ping = nil
            pingLbl.Text = "--"
        end
        plLbl.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
        task.wait(1)
    end
end)

do
    local fpsAccum, fpsFrames = 0, 0
    RunService.Heartbeat:Connect(function(dt)
        if unloaded then
            return
        end
        fpsAccum += dt
        fpsFrames += 1
        if fpsAccum >= 0.5 then
            LIVE.fps = math.floor(fpsFrames / fpsAccum + 0.5)
            fpsLbl.Text = tostring(LIVE.fps)
            fpsAccum, fpsFrames = 0, 0
        end
    end)
end

local function fitTelemetry()
    telemetry.Visible = window.AbsoluteSize.X >= 560
end
fitTelemetry()
window:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitTelemetry)

task.spawn(function()
    while gui.Parent and not unloaded do
        segFpsVal.Text = LIVE.fps > 0 and tostring(LIVE.fps) or "--"
        segPlVal.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
        segPingVal.Text = LIVE.ping and tostring(LIVE.ping) or "--"
        task.wait(0.5)
    end
end)

local iconBar = new("Frame", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1,
    0.5),
    Position = UDim2.new(1,
    -8,
    0.5,
    0),
    Size = UDim2.fromOffset(88,
    26),
    BorderSizePixel = 0,
    Parent = header,
})
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0,
    6),
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Parent = iconBar,
})

local function iconButton(kind, cb)
    local isClose = kind == "close"
    local btn = new("TextButton", {
        ZIndex = 3,
        Size = UDim2.fromOffset(26,
        26),
        BackgroundColor3 = C.Surface2,
        BackgroundTransparency = 0.9,
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0,
        Parent = iconBar,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 7), Parent = btn })
    local stroke = new("UIStroke", { Color = C.Hair, Transparency = 0.85, Thickness = 1, Parent = btn })
    local img = new("TextLabel", {
        Active = false,
        Size = UDim2.fromOffset(14,
        14),
        AnchorPoint = Vector2.new(0.5,
        0.5),
        Position = UDim2.new(0.5,
        0,
        0.5,
        0),
        BackgroundTransparency = 1,
        Text = "",
        TextScaled = false,
        TextSize = 13,
        FontFace = NL_ICON_REGULAR,
        TextColor3 = C.Dim,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = btn,
    })
    local names = { min = "minus", max = "dual-arrows-to-corners", close = "x" }
    setIcon(img, names[kind], C.Dim)
    local scale = new("UIScale", { Scale = 1, Parent = btn })

    btn.MouseEnter:Connect(function()
        tw(btn, { BackgroundTransparency = 0.55 }, 0.16)
        tw(stroke, { Transparency = 0.4, Color = isClose and C.Bad or C.HairHi }, 0.16)
        tw(img, { TextColor3 = isClose and C.Bad or C.Text }, 0.16)
    end)
    btn.MouseLeave:Connect(function()
        tw(btn, { BackgroundTransparency = 0.9 }, 0.18)
        tw(stroke, { Transparency = 0.85, Color = C.Hair }, 0.18)
        tw(img, { TextColor3 = C.Dim }, 0.18)
    end)
    btn.MouseButton1Down:Connect(function()
        tw(scale, { Scale = 0.88 }, 0.08)
    end)
    btn.MouseButton1Up:Connect(function()
        tw(scale, { Scale = 1 }, 0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
    tap(btn, cb)
    return btn
end

iconButton("min", function()
    closeHub()
end)
iconButton("max", function()
    toggleFull()
end)
iconButton("close", function()
    if unloaded then
        return
    end
    unloaded = true
    toast("Ixa Hub unloaded")
    task.delay(0.45, function()
        if gui and gui.Parent then
            gui:Destroy()
        end
        REG.gui = nil
    end)
end)

local TAB_ICON = {
    Main = "house",
    Controls = "settings",
    Settings = "settings",
    Config = "save",
    Demo = "star",
    Example = "eye",
    Menu = "gear",
    Info = "magnifying-glass",
    Tools = "wrench",
}

local sidebar = new("ScrollingFrame", {
    Name = "Sidebar",
    Size = UDim2.new(0,
    150,
    1,
    -110),
    Position = UDim2.new(0,
    14,
    0,
    72),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = C.HairHi,
    CanvasSize = UDim2.new(0,
    0,
    0,
    0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ElasticBehavior = Enum.ElasticBehavior.Never,
    Parent = chrome,
})
new("UIListLayout", {
    Padding = UDim.new(0,
    4),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = sidebar,
})

local navCap = new("Frame", {
    Active = false,
    Size = UDim2.new(1,
    -4,
    0,
    24),
    LayoutOrder = 0,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = sidebar,
})
local navTick = new("Frame", {
    Active = false,
    Size = UDim2.fromOffset(2,
    8),
    Position = UDim2.new(0,
    2,
    0.5,
    -4),
    BackgroundColor3 = C.Accent,
    BorderSizePixel = 0,
    Parent = navCap,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = navTick })
new("TextLabel", {
    Active = false,
    Size = UDim2.new(1,
    -14,
    1,
    0),
    Position = UDim2.new(0,
    14,
    0,
    0),
    BackgroundTransparency = 1,
    Text = "NAVIGATION",
    TextColor3 = C.Faint,
    FontFace = uiBold,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = navCap,
})

local tabButtons = {}
local function makeTabButton(name, order, index)
    local b = new("TextButton", {
        Size = UDim2.new(1,
        -4,
        0,
        36),
        LayoutOrder = order,
        BackgroundColor3 = C.Surface2,
        BackgroundTransparency = 0.92,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Parent = sidebar,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 9), Parent = b })
    local stroke = new("UIStroke", { Color = C.Hair, Transparency = 0.9, Thickness = 1, Parent = b })
    local ind = new("Frame", {
        Name = "Ind",
        Active = false,
        AnchorPoint = Vector2.new(0,
        0.5),
        Size = UDim2.fromOffset(2,
        16),
        Position = UDim2.new(0,
        0,
        0.5,
        0),
        BackgroundColor3 = C.On,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = b,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ind })
    local iconImg = new("TextLabel", {
        Active = false,
        Size = UDim2.fromOffset(16,
        16),
        AnchorPoint = Vector2.new(0,
        0.5),
        Position = UDim2.new(0,
        12,
        0.5,
        0),
        BackgroundTransparency = 1,
        Text = "",
        TextScaled = false,
        TextSize = 15,
        FontFace = NL_ICON_REGULAR,
        TextColor3 = C.Dim,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = b,
    })
    setIcon(iconImg, TAB_ICON[name], C.Dim)
    local lbl = new("TextLabel", {
        Name = "Lbl",
        Active = false,
        Size = UDim2.new(1,
        -74,
        1,
        0),
        Position = UDim2.new(0,
        38,
        0,
        0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = C.Dim,
        FontFace = uiMed,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = b,
    })
    lbl:SetAttribute("TrKey", "TabName")
    lbl:SetAttribute("TrEn", name)
    local num = new("TextLabel", {
        Active = false,
        Size = UDim2.new(0,
        24,
        1,
        0),
        Position = UDim2.new(1,
        -30,
        0,
        0),
        BackgroundTransparency = 1,
        Text = string.format("%02d",
        index),
        TextColor3 = C.Faint,
        TextTransparency = 0.65,
        FontFace = uiMed,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = b,
    })
    b.MouseEnter:Connect(function()
        if index ~= activeTab then
            tw(b, { BackgroundTransparency = 0.78 }, T.fast)
            tw(lbl, { TextColor3 = C.Text }, T.fast)
            tw(iconImg, { TextColor3 = C.Text }, T.fast)
        end
    end)
    b.MouseLeave:Connect(function()
        if index ~= activeTab then
            tw(b, { BackgroundTransparency = 0.92 }, T.fast)
            tw(lbl, { TextColor3 = C.Dim }, T.fast)
            tw(iconImg, { TextColor3 = C.Dim }, T.fast)
        end
    end)
    tap(b, function()
        switchTab(index)
    end)
    tabButtons[index] = { btn = b, img = iconImg, ind = ind, lbl = lbl, stroke = stroke, num = num }
    return b
end

local contentHolder = new("Frame", {
    Name = "ContentHolder",
    Size = UDim2.new(1,
    -186,
    1,
    -110),
    Position = UDim2.new(0,
    172,
    0,
    72),
    BackgroundColor3 = C.Surface,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    Parent = chrome,
})
new("UICorner", { CornerRadius = UDim.new(0, 14), Parent = contentHolder })
new("UIStroke", {
    Color = C.Hair,
    Transparency = 0.55,
    Thickness = 1,
    Parent = contentHolder
})
local paneHi = new("Frame", {
    Active = false,
    Size = UDim2.new(1,
    -28,
    0,
    1),
    Position = UDim2.new(0,
    14,
    0,
    0),
    BackgroundColor3 = C.HairHi,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    Parent = contentHolder,
})
new("UIGradient", {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,
        1),
        NumberSequenceKeypoint.new(0.2,
        0.35),
        NumberSequenceKeypoint.new(0.8,
        0.35),
        NumberSequenceKeypoint.new(1,
        1),
    }),
    Parent = paneHi,
})

local content = new("ScrollingFrame", {
    Name = "Content",
    Size = UDim2.new(1,
    -24,
    1,
    -24),
    Position = UDim2.new(0,
    12,
    0,
    12),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = C.HairHi,
    CanvasSize = UDim2.new(0,
    0,
    0,
    0),
    Parent = contentHolder,
})
new("UIPadding", {
    PaddingTop = UDim.new(0,
    2),
    PaddingBottom = UDim.new(0,
    8),
    PaddingLeft = UDim.new(0,
    2),
    PaddingRight = UDim.new(0,
    6),
    Parent = content,
})
local contentLayout = new("UIListLayout", {
    Padding = UDim.new(0,
    6),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = content,
})
local extraCanvas = 0
local function updateCanvas()
    content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 16 + extraCanvas)
end
contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

local footer = new("Frame", {
    Active = false,
    Position = UDim2.new(0,
    172,
    1,
    -30),
    Size = UDim2.new(1,
    -186,
    0,
    20),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = chrome,
})
local footDot = new("Frame", {
    Active = false,
    Size = UDim2.fromOffset(6,
    6),
    Position = UDim2.new(0,
    1,
    0.5,
    -3),
    BackgroundColor3 = C.Good,
    BorderSizePixel = 0,
    Parent = footer,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = footDot })
new("TextLabel", {
    Active = false,
    Size = UDim2.new(0,
    46,
    1,
    0),
    Position = UDim2.new(0,
    13,
    0,
    0),
    BackgroundTransparency = 1,
    Text = "READY",
    TextColor3 = C.Faint,
    FontFace = uiBold,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = footer,
})
new("TextLabel", {
    Active = false,
    Size = UDim2.new(1,
    -160,
    1,
    0),
    Position = UDim2.new(0,
    58,
    0,
    0),
    BackgroundTransparency = 1,
    Text = EXEC_NAME .. " · v" .. BUILD_TAG,
    TextColor3 = C.Dim,
    TextTransparency = 0.25,
    FontFace = uiMed,
    TextSize = 10.5,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    Parent = footer,
})
local footKey = new("Frame", {
    Active = false,
    AnchorPoint = Vector2.new(1,
    0.5),
    Size = UDim2.fromOffset(86,
    17),
    Position = UDim2.new(1,
    0,
    0.5,
    0),
    BackgroundColor3 = C.Surface2,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    Parent = footer,
})
new("UICorner", { CornerRadius = UDim.new(0, 5), Parent = footKey })
new("UIStroke", { Color = C.Hair, Transparency = 0.55, Thickness = 1, Parent = footKey })
new("TextLabel", {
    Active = false,
    Size = UDim2.new(1,
    0,
    1,
    0),
    BackgroundTransparency = 1,
    Text = "RIGHT SHIFT",
    TextColor3 = C.Faint,
    FontFace = uiBold,
    TextSize = 8.5,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
    Parent = footKey,
})

local function makeToggle(parent, state, onChange)
    local track = new("Frame", {
        Size = UDim2.fromOffset(40,
        22),
        AnchorPoint = Vector2.new(1,
        0.5),
        Position = UDim2.new(1,
        -4,
        0.5,
        0),
        BackgroundColor3 = state and C.On or C.Surface2,
        BackgroundTransparency = state and 0 or 0.45,
        BorderSizePixel = 0,
        Parent = parent,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
    local trackStroke = new("UIStroke", {
        Color = state and C.On or C.Hair,
        Transparency = state and 0.55 or 0.15,
        Thickness = 1,
        Parent = track,
    })
    local fillGrad = new("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new(C.Ember,
        C.On),
        Enabled = state,
        Parent = track,
    })
    local knob = new("Frame", {
        Active = false,
        Size = UDim2.fromOffset(16,
        16),
        Position = UDim2.new(state and 1 or 0,
        state and 21 or 3,
        0.5,
        -8),
        BackgroundColor3 = state and C.White or C.Dim,
        BorderSizePixel = 0,
        Parent = track,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
    local function paint(v)
        track.BackgroundColor3 = v and C.On or C.Surface2
        track.BackgroundTransparency = v and 0 or 0.45
        trackStroke.Color = v and C.On or C.Hair
        trackStroke.Transparency = v and 0.55 or 0.15
        fillGrad.Enabled = v
        knob.BackgroundColor3 = v and C.White or C.Dim
        track:SetAttribute("bBT", track.BackgroundTransparency)
    end
    local function set(v, silent)
        state = v
        cancelTweens(track)
        paint(v)
        if not silent then
            tw(knob, { Position = UDim2.new(v and 1 or 0, v and 21 or 3, 0.5, -8) }, T.fast, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            knob.Position = UDim2.new(v and 1 or 0, v and 21 or 3, 0.5, -8)
        end
        if onChange and not silent then
            onChange(v)
        end
    end
    tap(track, function()
        set(not state)
    end)
    local api = {}
    function api:SetVisual(v)
        cancelTweens(track)
        paint(v)
        knob.Position = UDim2.new(v and 1 or 0, v and 21 or 3, 0.5, -8)
    end
    function api:SetValue(v, silent)
        set(v == true, silent)
    end
    function api:GetValue()
        return state
    end
    return api
end

local function makeSlider(parent, minValue, maxValue, value, onChange, accent)
    local acc = accent or C.On
    local box = new("Frame", {
        Size = UDim2.fromOffset(190,
        28),
        AnchorPoint = Vector2.new(1,
        0.5),
        Position = UDim2.new(1,
        -4,
        0.5,
        0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent,
    })
    local label = new("TextLabel", {
        Active = false,
        Size = UDim2.fromOffset(42,
        16),
        Position = UDim2.new(0,
        0,
        0.5,
        -8),
        BackgroundTransparency = 1,
        Text = tostring(round(value)),
        TextColor3 = C.Text,
        FontFace = uiBold,
        TextSize = 12.5,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = box,
    })
    local track = new("Frame", {
        Size = UDim2.new(1,
        -50,
        0,
        3),
        Position = UDim2.new(0,
        50,
        0.5,
        -1),
        BackgroundColor3 = C.Surface2,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Parent = box,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
    local fill = new("Frame", {
        Active = false,
        Size = UDim2.new(0,
        0,
        1,
        0),
        BackgroundColor3 = acc,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Parent = track,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
    new("UIGradient", { Color = ColorSequence.new(C.Ember, acc), Parent = fill })
    for i = 1, 3 do
        new("Frame", {
            Active = false,
            AnchorPoint = Vector2.new(0.5,
            0),
            Size = UDim2.fromOffset(1,
            4),
            Position = UDim2.new(i / 4,
            0,
            1,
            3),
            BackgroundColor3 = C.Hair,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            Parent = track,
        })
    end
    local knob = new("Frame", {
        Size = UDim2.fromOffset(12,
        12),
        AnchorPoint = Vector2.new(0.5,
        0.5),
        Position = UDim2.new(0,
        0,
        0.5,
        0),
        BackgroundColor3 = C.White,
        BorderSizePixel = 0,
        Parent = track,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
    new("UIStroke", { Color = C.On, Transparency = 0.55, Thickness = 1, Parent = knob })
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
            if onChange then
                onChange(round(value))
            end
        end
    end
    local function beginSlide(input)
        fromX(mouse.X)
        tw(knob, { Size = UDim2.fromOffset(15, 15) }, T.fast)
        local moveConn = UserInputService.InputChanged:Connect(function(ch)
            if ch.UserInputType == Enum.UserInputType.MouseMovement or ch.UserInputType == Enum.UserInputType.Touch then
                fromX(mouse.X)
            end
        end)
        local endConn
        endConn = UserInputService.InputEnded:Connect(function(ch)
            if ch.UserInputType == input.UserInputType then
                moveConn:Disconnect()
                endConn:Disconnect()
                if knob.Parent then
                    tw(knob, { Size = UDim2.fromOffset(12, 12) }, T.fast, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                end
            end
        end)
    end
    knob.InputBegan:Connect(function(input)
        if DRAG_TYPES[input.UserInputType] then
            beginSlide(input)
        end
    end)
    track.InputBegan:Connect(function(input)
        if DRAG_TYPES[input.UserInputType] then
            beginSlide(input)
        end
    end)
    return box
end

local openMenus = {}
UserInputService.InputBegan:Connect(function(input)
    if not DRAG_TYPES[input.UserInputType] then
        return
    end
    if #openMenus == 0 then
        return
    end
    local p = Vector2.new(mouse.X, mouse.Y)
    for i = #openMenus, 1, -1 do
        local m = openMenus[i]
        if not pointIn(m.menu, p) and not pointIn(m.pill, p) then
            m.close()
        end
    end
end)

local function makeDropdown(parent, options, current, onChange)
    local row = parent.Parent
    local pill = new("TextButton", {
        Size = UDim2.fromOffset(160,
        30),
        AnchorPoint = Vector2.new(1,
        0.5),
        Position = UDim2.new(1,
        -4,
        0.5,
        0),
        BackgroundColor3 = C.Surface2,
        BackgroundTransparency = 0.4,
        Text = "  " .. current,
        TextColor3 = C.Text,
        FontFace = uiMed,
        TextSize = 12.5,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = parent,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = pill })
    local pillStroke = new("UIStroke", { Color = C.Hair, Transparency = 0.55, Thickness = 1, Parent = pill })
    local chev = new("TextLabel", {
        Active = false,
        Size = UDim2.fromOffset(14,
        14),
        AnchorPoint = Vector2.new(0,
        0.5),
        Position = UDim2.new(1,
        -22,
        0.5,
        0),
        BackgroundTransparency = 1,
        Text = "",
        TextSize = 13,
        FontFace = NL_ICON_REGULAR,
        TextColor3 = C.Faint,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = pill,
    })
    setIcon(chev, "chevron-down", C.Faint)
    local menuFullH = #options * 28 + 8
    local menuH = math.min(menuFullH, 176)
    local menu = new("ScrollingFrame", {
        ZIndex = 10,
        Size = UDim2.fromOffset(180,
        menuH),
        AnchorPoint = Vector2.new(1,
        0),
        Position = UDim2.new(1,
        0,
        1,
        5),
        BackgroundColor3 = C.Surface,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = C.HairHi,
        CanvasSize = UDim2.new(0,
        0,
        0,
        menuFullH),
        Visible = false,
        Parent = pill,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = menu })
    new("UIStroke", { Color = C.Hair, Transparency = 0.35, Thickness = 1, Parent = menu })
    new("UIListLayout", {
        Padding = UDim.new(0,
        2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = menu
    })
    new("UIPadding", {
        PaddingTop = UDim.new(0,
        4),
        PaddingBottom = UDim.new(0,
        4),
        PaddingLeft = UDim.new(0,
        4),
        PaddingRight = UDim.new(0,
        4),
        Parent = menu,
    })
    local isOpenMenu = false
    local consumeClick = false
    local myEntry = { pill = pill, menu = menu }
    local optionButtons = {}
    local function paintSelection()
        for opt, entry in pairs(optionButtons) do
            local selected = opt == current
            entry.btn.BackgroundTransparency = selected and 0.86 or 1
            entry.btn.TextColor3 = selected and C.On or C.Dim
            entry.mark.BackgroundTransparency = selected and 0 or 1
        end
    end
    local function setMenu(v)
        if isOpenMenu == v then
            return
        end
        isOpenMenu = v
        if v then
            for i = #openMenus, 1, -1 do
                if openMenus[i] ~= myEntry then
                    openMenus[i].close()
                end
            end
            table.insert(openMenus, myEntry)
            extraCanvas = extraCanvas + 170
            if row then
                row.ZIndex = 6
            end
            menu.Visible = true
            groupFadeSet(menu, 1)
            groupFade(menu, 0, 0.16)
            tw(chev, { Rotation = 180 }, T.fast)
            tw(pillStroke, { Color = C.On, Transparency = 0.55 }, T.fast)
        else
            for i = #openMenus, 1, -1 do
                if openMenus[i] == myEntry then
                    table.remove(openMenus, i)
                end
            end
            extraCanvas = math.max(0, extraCanvas - 170)
            if row then
                row.ZIndex = 1
            end
            groupFade(menu, 1, 0.12)
            tw(chev, { Rotation = 0 }, T.fast)
            tw(pillStroke, { Color = C.Hair, Transparency = 0.55 }, T.fast)
            task.delay(0.14, function()
                if not isOpenMenu then
                    menu.Visible = false
                end
            end)
        end
        updateCanvas()
    end
    myEntry.close = function()
        setMenu(false)
    end
    for i, opt in ipairs(options) do
        local b = new("TextButton", {
            ZIndex = 11,
            Size = UDim2.new(1,
            0,
            0,
            26),
            LayoutOrder = i,
            BackgroundColor3 = C.On,
            BackgroundTransparency = 1,
            Text = "  " .. opt,
            TextColor3 = C.Dim,
            FontFace = uiMed,
            TextSize = 12,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = menu,
        })
        new("UICorner", { CornerRadius = UDim.new(0, 7), Parent = b })
        local mark = new("Frame", {
            Active = false,
            AnchorPoint = Vector2.new(0,
            0.5),
            Size = UDim2.fromOffset(2,
            12),
            Position = UDim2.new(0,
            3,
            0.5,
            0),
            BackgroundColor3 = C.On,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = b,
        })
        new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = mark })
        optionButtons[opt] = { btn = b, mark = mark }
        b.MouseEnter:Connect(function()
            if opt ~= current then
                tw(b, { BackgroundColor3 = C.Surface2, BackgroundTransparency = 0.35 }, 0.1)
            end
        end)
        b.MouseLeave:Connect(function()
            if opt ~= current then
                tw(b, { BackgroundColor3 = C.On, BackgroundTransparency = 1 }, 0.1)
            end
        end)
        tap(b, function()
            consumeClick = true
            current = opt
            pill.Text = "  " .. opt
            paintSelection()
            setMenu(false)
            if onChange then
                onChange(opt)
            end
        end)
    end
    paintSelection()
    tap(pill, function()
        if consumeClick then
            consumeClick = false
            return
        end
        setMenu(not isOpenMenu)
    end)
    return pill
end

IXA_SearchRows = {}

local function addRow(parent, title, subtitle, buildControl, order)
    local h = 46
    if subtitle ~= nil then
        h = 56
    end
    local row = new("Frame", {
        Name = "Row",
        Size = UDim2.new(1,
        0,
        0,
        h),
        LayoutOrder = order or 0,
        BackgroundColor3 = C.Surface2,
        BackgroundTransparency = 0.72,
        BorderSizePixel = 0,
        Parent = parent,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 9), Parent = row })
    local rowStroke = new("UIStroke", {
        Color = C.Hair,
        Transparency = 0.85,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = row,
    })
    local rowMark = new("Frame", {
        Active = false,
        AnchorPoint = Vector2.new(0,
        0.5),
        Size = UDim2.fromOffset(2,
        16),
        Position = UDim2.new(0,
        0,
        0.5,
        0),
        BackgroundColor3 = C.On,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = row,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = rowMark })
    local titleY = 12
    if subtitle ~= nil then
        titleY = 8
    end
    local titleLabel = new("TextLabel", {
        Active = false,
        Size = UDim2.new(1,
        -300,
        0,
        18),
        Position = UDim2.new(0,
        15,
        0,
        titleY),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = C.Text,
        FontFace = uiMed,
        TextSize = 13.5,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })
    titleLabel:SetAttribute("TrKey", "RowTitle")
    titleLabel:SetAttribute("TrEn", title)
    if subtitle ~= nil then
        local sub = new("TextLabel", {
            Active = false,
            Size = UDim2.new(1,
            -300,
            0,
            15),
            Position = UDim2.new(0,
            15,
            0,
            29),
            BackgroundTransparency = 1,
            Text = subtitle,
            TextColor3 = C.Faint,
            FontFace = uiReg,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })
        sub:SetAttribute("RoleTag", "Dim")
        sub:SetAttribute("TrKey", "RowSub")
        sub:SetAttribute("TrEn", subtitle)
    end
    local box = new("Frame", {
        Size = UDim2.new(0,
        250,
        1,
        0),
        AnchorPoint = Vector2.new(1,
        0),
        Position = UDim2.new(1,
        -12,
        0,
        0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = row,
    })
    if buildControl ~= nil then
        buildControl(box)
    end
    IXA_SearchRows[#IXA_SearchRows + 1] = {
        row = row,
        tab = activeTab,
        title = title,
        subtitle = subtitle,
        order = order or 0,
    }
    row.MouseEnter:Connect(function()
        tw(row, { BackgroundTransparency = 0.5 }, T.fast)
        tw(rowStroke, { Transparency = 0.5 }, T.fast)
        tw(rowMark, { BackgroundTransparency = 0.15 }, T.fast)
    end)
    row.MouseLeave:Connect(function()
        tw(row, { BackgroundTransparency = 0.72 }, T.fast)
        tw(rowStroke, { Transparency = 0.85 }, T.fast)
        tw(rowMark, { BackgroundTransparency = 1 }, T.fast)
    end)
    return row
end

local TABS = {}

_G.__IXA_TOAST = toast

local function ixaCall(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end
    local result = table.pack(pcall(fn, ...))
    if not result[1] then
        return nil
    end
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
        Size = UDim2.fromOffset(150,
        30),
        AnchorPoint = Vector2.new(1,
        0.5),
        Position = UDim2.new(1,
        -4,
        0.5,
        0),
        BackgroundColor3 = C.Surface2,
        BackgroundTransparency = 0.45,
        TextColor3 = C.Text,
        PlaceholderColor3 = C.Faint,
        Text = tostring(defaultValue or ""),
        PlaceholderText = tostring(defaultValue or ""),
        ClearTextOnFocus = false,
        FontFace = uiMed,
        TextSize = 12.5,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        Parent = parent,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = input })
    local stroke = new("UIStroke", { Color = C.Hair, Transparency = 0.55, Thickness = 1, Parent = input })
    new("UIPadding", {
        PaddingLeft = UDim.new(0,
        10),
        PaddingRight = UDim.new(0,
        8),
        Parent = input
    })
    input.Focused:Connect(function()
        tw(stroke, { Color = C.On, Transparency = 0.55 }, T.fast)
        tw(input, { BackgroundTransparency = 0.3 }, T.fast)
    end)
    input.FocusLost:Connect(function()
        tw(stroke, { Color = C.Hair, Transparency = 0.55 }, T.fast)
        tw(input, { BackgroundTransparency = 0.45 }, T.fast)
        IXA_UI_STATE[key] = input.Text
        ixaCall(callback, input.Text)
    end)
end

local function ixaDropdown(parent, options, current, callback, stateKey)
    options = options or {}
    if #options == 0 then
        options = { "None" }
    end
    local selected = current
    local found = false
    for _, item in ipairs(options) do
        if item == selected then
            found = true
            break
        end
    end
    if not found then
        selected = options[1]
    end
    makeDropdown(parent, options, selected, function(value)
        if stateKey then
            IXA_UI_STATE[stateKey] = value
        end
        ixaCall(callback, value)
    end)
end

local function ixaSlider(parent, minimum, maximum, current, callback, stateKey)
    makeSlider(parent, minimum, maximum, math.clamp(tonumber(current) or minimum, minimum, maximum), function(value)
        if stateKey then
            IXA_UI_STATE[stateKey] = value
        end
        ixaCall(callback, value)
    end)
end

local function makeBtn(parent, text, cb, width)
    local btn = new("TextButton", {
        Size = UDim2.fromOffset(width or 74,
        30),
        AnchorPoint = Vector2.new(1,
        0.5),
        Position = UDim2.new(1,
        -4,
        0.5,
        0),
        BackgroundColor3 = C.Surface2,
        BackgroundTransparency = 0.4,
        Text = text,
        TextColor3 = C.Text,
        FontFace = uiMed,
        TextSize = 12.5,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Parent = parent,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
    local bStroke = new("UIStroke", { Color = C.Hair, Transparency = 0.55, Thickness = 1, Parent = btn })
    btn:SetAttribute("TrKey", "Btn")
    btn:SetAttribute("TrEn", text)
    btn.MouseEnter:Connect(function()
        tw(btn, { BackgroundTransparency = 0.2 }, T.fast)
        tw(bStroke, { Color = C.On, Transparency = 0.6 }, T.fast)
        tw(btn, { TextColor3 = C.Lamp }, T.fast)
    end)
    btn.MouseLeave:Connect(function()
        tw(btn, { BackgroundTransparency = 0.4 }, T.fast)
        tw(bStroke, { Color = C.Hair, Transparency = 0.55 }, T.fast)
        tw(btn, { TextColor3 = C.Text }, T.fast)
    end)
    tap(btn, cb)
    return btn
end

local function ixaButton(parent, title, callback)
    makeBtn(parent, title, function()
        ixaCall(callback)
    end, 150)
end

local function ixaColor(parent, defaultColor, callback)
    local colors = { "Orange", "Pink", "Purple", "Blue", "Green", "White", "Red" }
    local values = {
        Orange = Color3.fromRGB(224,
        116,
        24),
        Pink = Color3.fromRGB(255,
        90,
        160),
        Purple = Color3.fromRGB(170,
        90,
        255),
        Blue = Color3.fromRGB(70,
        150,
        255),
        Green = Color3.fromRGB(70,
        220,
        140),
        White = Color3.fromRGB(255,
        255,
        255),
        Red = Color3.fromRGB(255,
        70,
        70),
    }
    local chosen = "Orange"
    local best = math.huge
    if typeof(defaultColor) == "Color3" then
        local function cdist(c)
            return math.abs(c.R - defaultColor.R) + math.abs(c.G - defaultColor.G) + math.abs(c.B - defaultColor.B)
        end
        for name, color in pairs(values) do
            local d = cdist(color)
            if d < best then
                best, chosen = d, name
            end
        end
    end
    ixaDropdown(parent, colors, chosen, function(name)
        ixaCall(callback, values[name])
    end)
end

IXAL_Locale = "English"
function IXAL_L(key)
    if IXAL_Locale ~= "Russian" then
        return key
    end
    return IXAL_Keys[key] or key
end
function IXAL_ApplyTranslations()
    if not gui then
        return
    end
    for _, item in ipairs(gui:GetDescendants()) do
        local tag = item:GetAttribute("TrKey")
        if tag then
            if item:IsA("TextLabel") or item:IsA("TextButton") then
                if tag == "Tab" then
                    item.Text = "  " .. IXAL_L(item:GetAttribute("TrEn") or "")
                else
                    item.Text = IXAL_L(item:GetAttribute("TrEn") or "")
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
    if IXA_rebuildSuggestions then
        IXA_rebuildSuggestions()
    end
end

local function addSubGroup(parent, order, subs)
    local subRows = {}
    local expanded = false

    local expRow = new("Frame", {
        Name = "Row",
        Size = UDim2.new(1,
        0,
        0,
        20),
        LayoutOrder = order,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent,
    })
    local exp = new("TextButton", {
        Name = "Expander",
        Size = UDim2.new(1,
        0,
        1,
        0),
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
        r:SetAttribute("FullH", r.Size.Y.Offset)
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
                TweenService:Create(r, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, r:GetAttribute("FullH")) }):Play()
                task.delay(0.3, function()
                    if expanded and r.Parent then
                        r.ClipsDescendants = false
                    end
                end)
            else
                r.ClipsDescendants = true
                TweenService:Create(r, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(1, 0, 0, 0) }):Play()
                task.delay(0.24, function()
                    if not expanded and r.Parent then
                        r.Visible = false
                    end
                end)
            end
        end
    end)
    exp.MouseEnter:Connect(function()
        exp.TextColor3 = C.On
    end)
    exp.MouseLeave:Connect(function()
        exp.TextColor3 = C.Accent
    end)
end

local function sectionLabel(parent, text, order)
    local row = new("Frame", {
        Name = "Row",
        Size = UDim2.new(1,
        0,
        0,
        22),
        LayoutOrder = order,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent,
    })
    new("TextLabel", {
        Active = false,
        BackgroundTransparency = 1,
        Position = UDim2.new(0,
        2,
        0,
        0),
        Size = UDim2.new(0,
        140,
        1,
        0),
        Text = string.upper(text),
        TextColor3 = C.Faint,
        FontFace = uiBold,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local line = new("Frame", {
        Active = false,
        AnchorPoint = Vector2.new(1,
        0.5),
        Position = UDim2.new(1,
        -4,
        0.5,
        0),
        Size = UDim2.new(1,
        -164,
        0,
        1),
        BackgroundColor3 = C.Hair,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Parent = row,
    })
    new("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,
            1),
            NumberSequenceKeypoint.new(0.35,
            0.4),
            NumberSequenceKeypoint.new(1,
            0.4),
        }),
        Parent = line,
    })
    return row
end

TABS[1] = {
    name = "Controls",
    build = function(c)
        sectionLabel(c,
        "Components",
        0)
        addRow(c,
        "Toggle",
        "Boolean switch with a saved state",
        function(b)
            ixaToggle(b,
            "DemoToggle",
            function(v)
                toast("Toggle -> " .. tostring(v))
            end)
        end,
        1)
        addRow(c,
        "Slider",
        "Drag to change a number (0 - 100)",
        function(b)
            ixaSlider(b,
            0,
            100,
            IXA_UI_STATE.DemoSlider or 50,
            function(v)
        end,
        "DemoSlider")
    end,
    2) addRow(c,
    "Dropdown",
    "Pick one option from a list",
    function(b)
        ixaDropdown(b,
        { "Option A", "Option B", "Option C" },
        IXA_UI_STATE.DemoDropdown or "Option A",
        function(v)
            toast("Dropdown -> " .. tostring(v))
        end,
        "DemoDropdown")
    end,
    3) addRow(c,
    "Text Input",
    "Free text, read on focus lost",
    function(b)
        ixaText(b,
        "DemoText",
        IXA_UI_STATE.DemoText or "hello",
        function(v)
            toast("Text -> " .. tostring(v))
        end)
    end,
    4) addRow(c,
    "Button",
    "Runs a callback on click",
    function(b)
        ixaButton(b,
        "Press me",
        function()
            toast("Button pressed")
        end)
    end,
    5) addRow(c,
    "Color",
    "Preset color picker",
    function(b)
        ixaColor(b,
        Color3.fromRGB(255,
        186,
        44),
        function(color)
            toast(string.format("Color -> %d, %d, %d",
            color.R * 255,
            color.G * 255,
            color.B * 255))
        end)
    end,
    6) addSubGroup(c,
    7,
    {
        {
            "Grouped Toggle",
            "Row inside a collapsible group",
            function(b)
                ixaToggle(b,
                "DemoGroupToggle",
                function(v)
                    toast("Grouped toggle -> " .. tostring(v))
                end)
            end
        },
        {
            "Grouped Slider",
            "0 - 10",
            function(b)
                ixaSlider(b,
                0,
                10,
                IXA_UI_STATE.DemoGroupSlider or 5,
                function(v)
            end,
            "DemoGroupSlider") end
        },
        {
            "Grouped Dropdown",
            "One more option list",
            function(b)
                ixaDropdown(b,
                { "One", "Two", "Three" },
                "One",
                function(v)
            end,
            "DemoGroupDropdown") end
        },
    }) addRow(c,
    "Raw Toggle",
    "makeToggle() without any state handling",
    function(b)
        makeToggle(b,
        false,
        function(v)
    end) end,
    20) addRow(c,
    "Row Without Control",
    nil,
    nil,
    21) end
}

TABS[2] = {
    name = "Settings",
    build = function(c)
        sectionLabel(c,
        "Interface",
        0)
        addRow(c,
        "Language",
        "Interface label preference",
        function(b)
            ixaDropdown(b,
            { "English", "Russian" },
            IXA_UI_STATE.Language or "English",
            function(v)
                IXAL_SetLanguage(v)
            end,
            "Language")
        end,
        1)
        addRow(c,
        "Menu Key",
        "Fixed open / close key for the GUI",
        function(b)
            local fixed = new("TextLabel",
            {
                Active = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(0,
                96,
                0,
                16),
                AnchorPoint = Vector2.new(1,
                0.5),
                Position = UDim2.new(1,
                -4,
                0.5,
                0),
                Text = "RIGHT SHIFT",
                FontFace = uiBold,
                TextSize = 12,
                TextColor3 = C.Lamp,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = b,
            })
        end,
        2)
        addRow(c,
        "Menu Scale",
        "Base window scale",
        function(b)
            ixaDropdown(b,
            { "Small", "Default", "Large" },
            IXA_UI_STATE.MenuScale or "Default",
            function(v)
                IXA_UI_STATE.MenuScale = v
                local scales = { Small = 0.86, Default = 1, Large = 1.14 }
                local scale = scales[v] or 1
                W,
                H = math.floor(820 * scale),
                math.floor(470 * scale)
                window.Size = normSize()
            end,
            "MenuScale")
        end,
        3)
        addRow(c,
        "Menu Transparency",
        "Visual transparency from 0 to 80 percent",
        function(b)
            ixaSlider(b,
            0,
            80,
            IXA_UI_STATE.MenuTransparency or 0,
            function(v)
                IXA_UI_STATE.MenuTransparency = v
                if bg then
                    bg.ImageTransparency = math.clamp(0.35 + (v / 100) * 0.65,
                    0.35,
                    1)
                    bg.BackgroundTransparency = math.clamp(0.5 + (v / 100) * 0.5,
                    0.5,
                    1)
                end
                if overlay then
                    overlay.BackgroundTransparency = math.clamp(0.65 + (v / 100) * 0.35,
                    0.65,
                    1)
                end
            end)
        end,
        4)
        addRow(c,
        "Refresh UI",
        "Rebuild the current tab",
        function(b)
            ixaButton(b,
            "Refresh",
            function()
                buildTab(activeTab,
                true)
            end)
        end,
        5)
    end
}

TABS[3] = {
    name = "Config",
    build = function(c)
        sectionLabel(c,
        "Profiles",
        0)
        addRow(c,
        "Profile Name",
        "Saved beside the script",
        function(b)
            ixaText(b,
            "ConfigName",
            IXA_UI_STATE.ConfigName or "default",
            function(v)
                IXA_UI_STATE.ConfigName = (tostring(v):gsub("[^%w_%-% ]",
                ""))
                if IXA_UI_STATE.ConfigName == "" then
                    IXA_UI_STATE.ConfigName = "default"
                end
            end)
        end,
        1)
        addRow(c,
        "Save Profile",
        "Save the readable settings",
        function(b)
            ixaButton(b,
            "Save",
            function()
                if writefile and HttpService then
                    pcall(function()
                        writefile("IXA_" .. (IXA_UI_STATE.ConfigName or "default") .. ".json",
                        HttpService:JSONEncode(IXA_UI_STATE))
                    end)
                    toast("Profile saved")
                else
                    toast("File API is unavailable")
                end
            end)
        end,
        2)
        addRow(c,
        "Load Profile",
        "Load the selected profile",
        function(b)
            ixaButton(b,
            "Load",
            function()
                local path = "IXA_" .. (IXA_UI_STATE.ConfigName or "default") .. ".json"
                if readfile and isfile and isfile(path) then
                    local ok,
                    data = pcall(function()
                        return HttpService:JSONDecode(readfile(path))
                    end)
                    if ok and type(data) == "table" then
                        for k,
                        v in pairs(data) do
                            IXA_UI_STATE[k] = v
                        end
                        toast("Profile loaded")
                    end
                else
                    toast("Profile not found")
                end
            end)
        end,
        3)
        addRow(c,
        "Delete Profile",
        "Delete the selected file",
        function(b)
            ixaButton(b,
            "Delete",
            function()
                local path = "IXA_" .. (IXA_UI_STATE.ConfigName or "default") .. ".json"
                if delfile and isfile and isfile(path) then
                    delfile(path)
                    toast("Profile deleted")
                else
                    toast("Profile not found")
                end
            end)
        end,
        4)
    end
}

local DISCORD_INVITE = "https://discord.gg/dZ9rnh7tjS"
local DISCORD_MEMBERS_TEXT = "400+ members"

IXAL_Keys["Main"] = "Главная"
IXAL_Keys["Welcome back"] = "С возвращением"
IXAL_Keys["Join"] = "Войти"
IXAL_Keys["Uptime"] = "Аптайм"
IXAL_Keys["Ping"] = "Пинг"
IXAL_Keys["Players"] = "Игроки"
IXAL_Keys["Place"] = "Место"
IXAL_Keys["Current game"] = "Текущая игра"
IXAL_Keys["All features"] = "Все функции"
IXAL_Keys["Hidden"] = "Скрыто"
IXAL_Keys["Name hidden"] = "Имя скрыто"
IXAL_Keys["Name shown"] = "Имя открыто"
IXAL_Keys["Avatar hidden"] = "Аватар скрыт"
IXAL_Keys["Avatar shown"] = "Аватар открыт"
IXAL_Keys["Invite copied"] = "Инвайт скопирован"
IXAL_Keys["Right Shift hides the hub"] = "Right Shift скрывает хаб"
IXAL_Keys["Session"] = "Сессия"
IXAL_Keys["Community"] = "Сообщество"
IXAL_Keys[DISCORD_MEMBERS_TEXT] = "400+ участников"

local MAIN_T0 = os.time()

local GAME_NAME = nil
task.spawn(function()
    local ok, info = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    if ok and type(info) == "table" and type(info.Name) == "string" then
        GAME_NAME = info.Name
    end
end)

local function mainFmtUptime(sec)
    sec = math.max(0, math.floor(sec))
    local h, m, s = math.floor(sec / 3600), math.floor(sec / 60) % 60, sec % 60
    if h > 0 then
        return h .. "h " .. m .. "m"
    end
    if m > 0 then
        return m .. "m " .. s .. "s"
    end
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

local MAIN_TAB = {
    name = "Main",
    build = function(c)
        local function ru()
            return IXAL_Locale == "Russian"
        end
        local conns = {}
        local function track(conn)
            conns[#conns + 1] = conn
        end
        local function panel(order,
        height,
        parent,
        name)
            local f = new("Frame",
            {
                Name = name or "Row",
                LayoutOrder = order,
                Size = UDim2.new(1,
                0,
                0,
                height),
                BackgroundColor3 = C.Surface2,
                BackgroundTransparency = 0.45,
                BorderSizePixel = 0,
                Parent = parent,
            })
            new("UICorner",
            { CornerRadius = UDim.new(0, 12), Parent = f })
            new("UIStroke",
            { Color = C.Hair, Transparency = 0.78, Thickness = 1, Parent = f })
            return f
        end
        local function txt(parent,
        text,
        font,
        size,
        color,
        pos,
        sizeUd,
        align)
            return new("TextLabel",
            {
                Active = false,
                BackgroundTransparency = 1,
                Position = pos,
                Size = sizeUd,
                Text = text,
                FontFace = font,
                TextSize = size,
                TextColor3 = color,
                TextXAlignment = align or Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = parent,
            })
        end
        local function glyph(parent,
        name,
        color,
        pos,
        px)
            local h = new("Frame",
            {
                Active = false,
                BackgroundTransparency = 1,
                Position = pos,
                Size = UDim2.fromOffset(px,
                px),
                Parent = parent,
            })
            setIcon(h,
            name,
            color)
            local ic = h:FindFirstChild("NLIcon")
            if ic then
                ic.TextSize = px
            end
            return h
        end
        local function softHover(f,
        rest)
            local st = f:FindFirstChildOfClass("UIStroke")
            f.MouseEnter:Connect(function()
                tw(f,
                { BackgroundTransparency = math.max(0.08, rest - 0.2) },
                T.fast)
                if st then
                    tw(st,
                    { Transparency = 0.48 },
                    T.fast)
                end
            end)
            f.MouseLeave:Connect(function()
                tw(f,
                { BackgroundTransparency = rest },
                T.fast)
                if st then
                    tw(st,
                    { Transparency = 0.78 },
                    T.fast)
                end
            end)
        end
        local hero = panel(1,
        152,
        c)
        hero.ClipsDescendants = true
        new("UIGradient",
        {
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,
                Color3.fromRGB(31,
                32,
                38)),
                ColorSequenceKeypoint.new(1,
                Color3.fromRGB(23,
                24,
                29)),
            }),
            Parent = hero,
        })
        local bustHolder = new("Frame",
        {
            Active = false,
            AnchorPoint = Vector2.new(1,
            1),
            Position = UDim2.new(1,
            -2,
            1,
            0),
            Size = UDim2.fromOffset(158,
            158),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Parent = hero,
        })
        local bust = new("ImageLabel",
        {
            Active = false,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,
            0,
            1,
            0),
            Image = "rbxthumb://type=AvatarBust&id=" .. tostring(player.UserId) .. "&w=420&h=420",
            ScaleType = Enum.ScaleType.Fit,
            Parent = bustHolder,
        })
        new("UIGradient",
        {
            Rotation = 0,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0,
                1),
                NumberSequenceKeypoint.new(0.4,
                0.82),
                NumberSequenceKeypoint.new(0.66,
                0),
                NumberSequenceKeypoint.new(1,
                0),
            }),
            Parent = bust,
        })
        local info = new("Frame",
        {
            Active = false,
            BackgroundTransparency = 1,
            Position = UDim2.new(0,
            20,
            0,
            18),
            Size = UDim2.new(1,
            -212,
            1,
            -36),
            Parent = hero,
        })
        new("Frame",
        {
            Active = false,
            Size = UDim2.fromOffset(14,
            1),
            Position = UDim2.new(0,
            0,
            0,
            7),
            BackgroundColor3 = C.On,
            BorderSizePixel = 0,
            Parent = info,
        })
        local overline = txt(info,
        string.upper(IXAL_L("Welcome back")),
        uiBold,
        9,
        C.Faint,
        UDim2.new(0,
        22,
        0,
        0),
        UDim2.new(1,
        -22,
        0,
        15))
        overline.TextTransparency = 0.05
        local nameLbl = txt(info,
        player.DisplayName,
        uiBold,
        30,
        C.Text,
        UDim2.new(0,
        0,
        0,
        20),
        UDim2.new(1,
        -4,
        0,
        38))
        new("UIGradient",
        {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,
                C.White),
                ColorSequenceKeypoint.new(1,
                C.Ember),
            }),
            Parent = nameLbl,
        })
        local userDot = new("Frame",
        {
            Active = false,
            Size = UDim2.fromOffset(5,
            5),
            Position = UDim2.new(0,
            1,
            0,
            65),
            BackgroundColor3 = C.Good,
            BorderSizePixel = 0,
            Parent = info,
        })
        new("UICorner",
        { CornerRadius = UDim.new(1, 0), Parent = userDot })
        local userLbl = txt(info,
        "",
        uiReg,
        11.5,
        C.Faint,
        UDim2.new(0,
        11,
        0,
        60),
        UDim2.new(1,
        -11,
        0,
        15))
        local metaLbl = txt(info,
        "",
        uiMed,
        10.5,
        C.Dim,
        UDim2.new(0,
        1,
        0,
        94),
        UDim2.new(1,
        -60,
        0,
        15))
        local function miniBtn(xOff,
        iconName,
        cb)
            local b = new("TextButton",
            {
                ZIndex = 4,
                AnchorPoint = Vector2.new(1,
                0),
                Position = UDim2.new(1,
                xOff,
                0,
                92),
                Size = UDim2.fromOffset(22,
                22),
                BackgroundColor3 = C.Surface2,
                BackgroundTransparency = 0.5,
                Text = "",
                AutoButtonColor = false,
                BorderSizePixel = 0,
                Parent = info,
            })
            new("UICorner",
            { CornerRadius = UDim.new(0, 6), Parent = b })
            local st = new("UIStroke",
            { Color = C.Hair, Transparency = 0.6, Thickness = 1, Parent = b })
            local ic = new("TextLabel",
            {
                Active = false,
                Size = UDim2.fromOffset(12,
                12),
                AnchorPoint = Vector2.new(0.5,
                0.5),
                Position = UDim2.fromOffset(11,
                11),
                BackgroundTransparency = 1,
                Text = "",
                TextSize = 11,
                FontFace = NL_ICON_REGULAR,
                TextColor3 = C.Faint,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                Parent = b,
            })
            setIcon(ic,
            iconName,
            C.Faint)
            b.MouseEnter:Connect(function()
                tw(b,
                { BackgroundTransparency = 0.25 },
                T.fast)
                tw(st,
                { Color = C.HairHi, Transparency = 0.4 },
                T.fast)
            end)
            b.MouseLeave:Connect(function()
                tw(b,
                { BackgroundTransparency = 0.5 },
                T.fast)
                tw(st,
                { Color = C.Hair, Transparency = 0.6 },
                T.fast)
            end)
            tap(b,
            cb)
            return { btn = b, icon = ic, stroke = st }
        end
        local hideName = IXA_UI_STATE.HomeHideName == true
        local hideAvatar = IXA_UI_STATE.HomeHideAvatar == true
        local eyeRef,
        avaRef
        local function applyIdentity()
            nameLbl.Text = hideName and IXAL_L("Hidden") or player.DisplayName
            userLbl.Text = hideName and "@hidden" or ("@" .. player.Name)
            bustHolder.Visible = not hideAvatar
            if eyeRef then
                setIcon(eyeRef.icon,
                hideName and "eye-off" or "eye",
                hideName and C.On or C.Faint)
            end
            if avaRef then
                setIcon(avaRef.icon,
                hideAvatar and "user-x" or "user",
                hideAvatar and C.On or C.Faint)
            end
            IXA_UI_STATE.HomeHideName = hideName
            IXA_UI_STATE.HomeHideAvatar = hideAvatar
        end
        eyeRef = miniBtn(-30,
        "eye",
        function()
            hideName = not hideName
            applyIdentity()
            toast(IXAL_L(hideName and "Name hidden" or "Name shown"))
        end)
        avaRef = miniBtn(-5,
        "user",
        function()
            hideAvatar = not hideAvatar
            applyIdentity()
            toast(IXAL_L(hideAvatar and "Avatar hidden" or "Avatar shown"))
        end)
        applyIdentity()
        local statsPanel = panel(2,
        78,
        c)
        local statDefs = {
            { cap = "Players", icon = "person" },
            { cap = "Uptime", icon = "clock" },
            { cap = "FPS", icon = "activity" },
            { cap = "Ping", icon = "wifi" },
        }
        local statCells = {}
        for i,
        def in ipairs(statDefs) do
            local cell = new("Frame",
            { Active = false, BackgroundTransparency = 1, Parent = statsPanel })
            glyph(cell,
            def.icon,
            C.Faint,
            UDim2.new(1,
            -22,
            0,
            12),
            12)
            local cap = txt(cell,
            string.upper(def.cap),
            uiBold,
            8.5,
            C.Faint,
            UDim2.new(0,
            14,
            0,
            11),
            UDim2.new(1,
            -34,
            0,
            13))
            local val = txt(cell,
            "--",
            uiBold,
            20,
            C.Text,
            UDim2.new(0,
            14,
            0,
            27),
            UDim2.new(1,
            -24,
            0,
            26))
            statCells[i] = { cell = cell, val = val, cap = cap, def = def }
        end
        local statDivs = {}
        for i = 1,
        3 do
            statDivs[i] = new("Frame",
            {
                Active = false,
                BackgroundColor3 = C.Hair,
                BackgroundTransparency = 0.4,
                Size = UDim2.new(0,
                1,
                1,
                -28),
                BorderSizePixel = 0,
                Parent = statsPanel,
            })
        end
        local statHDiv = new("Frame",
        {
            Active = false,
            BackgroundColor3 = C.Hair,
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1,
            -28,
            0,
            1),
            BorderSizePixel = 0,
            Visible = false,
            Parent = statsPanel,
        })
        local function layoutStats(w)
            local cols = (w >= 350) and 4 or 2
            local rows = 4 / cols
            statsPanel.Size = UDim2.new(1,
            0,
            0,
            rows == 1 and 78 or 132)
            for i,
            s in ipairs(statCells) do
                local col = (i - 1) % cols
                local row = math.floor((i - 1) / cols)
                s.cell.Position = UDim2.new(col / cols,
                0,
                row / rows,
                0)
                s.cell.Size = UDim2.new(1 / cols,
                0,
                1 / rows,
                0)
            end
            for i,
            d in ipairs(statDivs) do
                local visible = i < cols
                d.Visible = visible
                if visible then
                    d.Position = UDim2.new(i / cols,
                    0,
                    0,
                    14)
                    d.Size = UDim2.new(0,
                    1,
                    1 / rows,
                    -28)
                end
            end
            statHDiv.Visible = rows > 1
            if rows > 1 then
                statHDiv.Position = UDim2.new(0,
                14,
                0.5,
                0)
                statHDiv.Size = UDim2.new(1,
                -28,
                0,
                1)
            end
        end
        local pair = new("Frame",
        {
            Name = "Row",
            LayoutOrder = 3,
            Size = UDim2.new(1,
            0,
            0,
            124),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = c,
        })
        local sessionCard = panel(1,
        124,
        pair,
        "Card")
        local commCard = panel(2,
        124,
        pair,
        "Card")
        glyph(sessionCard,
        "timer",
        C.On,
        UDim2.new(0,
        14,
        0,
        14),
        13)
        txt(sessionCard,
        string.upper(IXAL_L("Session")),
        uiBold,
        9,
        C.Faint,
        UDim2.new(0,
        34,
        0,
        13),
        UDim2.new(1,
        -86,
        0,
        15))
        local liveTag = new("Frame",
        {
            Active = false,
            AnchorPoint = Vector2.new(1,
            0),
            Position = UDim2.new(1,
            -14,
            0,
            13),
            Size = UDim2.fromOffset(46,
            15),
            BackgroundColor3 = C.Good,
            BackgroundTransparency = 0.9,
            BorderSizePixel = 0,
            Parent = sessionCard,
        })
        new("UICorner",
        { CornerRadius = UDim.new(0, 4), Parent = liveTag })
        txt(liveTag,
        "LIVE",
        uiBold,
        8,
        C.Good,
        UDim2.new(0,
        0,
        0,
        0),
        UDim2.new(1,
        0,
        1,
        0),
        Enum.TextXAlignment.Center)
        local gameLbl = txt(sessionCard,
        "",
        uiBold,
        14,
        C.Text,
        UDim2.new(0,
        14,
        0,
        36),
        UDim2.new(1,
        -28,
        0,
        20))
        local sesMeta = txt(sessionCard,
        "",
        uiReg,
        10.5,
        C.Dim,
        UDim2.new(0,
        14,
        0,
        60),
        UDim2.new(1,
        -28,
        0,
        36))
        sesMeta.TextWrapped = true
        sesMeta.TextYAlignment = Enum.TextYAlignment.Top
        new("Frame",
        {
            Active = false,
            Size = UDim2.new(1,
            -28,
            0,
            1),
            Position = UDim2.new(0,
            14,
            0,
            100),
            BackgroundColor3 = C.Hair,
            BackgroundTransparency = 0.45,
            BorderSizePixel = 0,
            Parent = sessionCard,
        })
        txt(sessionCard,
        IXAL_L("Right Shift hides the hub"),
        uiReg,
        9.5,
        C.Faint,
        UDim2.new(0,
        14,
        0,
        104),
        UDim2.new(1,
        -28,
        0,
        14))
        glyph(commCard,
        "message-circle",
        C.On,
        UDim2.new(0,
        14,
        0,
        14),
        13)
        txt(commCard,
        string.upper(IXAL_L("Community")),
        uiBold,
        9,
        C.Faint,
        UDim2.new(0,
        34,
        0,
        13),
        UDim2.new(1,
        -48,
        0,
        15))
        txt(commCard,
        "Discord",
        uiBold,
        14,
        C.Text,
        UDim2.new(0,
        14,
        0,
        36),
        UDim2.new(1,
        -28,
        0,
        20))
        txt(commCard,
        IXAL_L(DISCORD_MEMBERS_TEXT),
        uiReg,
        10.5,
        C.Dim,
        UDim2.new(0,
        14,
        0,
        60),
        UDim2.new(1,
        -28,
        0,
        16))
        local joinBtn = new("TextButton",
        {
            AnchorPoint = Vector2.new(1,
            1),
            Position = UDim2.new(1,
            -14,
            1,
            -14),
            Size = UDim2.fromOffset(96,
            28),
            BackgroundColor3 = C.On,
            BackgroundTransparency = 0.88,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            Parent = commCard,
        })
        new("UICorner",
        { CornerRadius = UDim.new(0, 7), Parent = joinBtn })
        local joinStroke = new("UIStroke",
        { Color = C.On, Transparency = 0.55, Thickness = 1, Parent = joinBtn })
        local joinLbl = txt(joinBtn,
        IXAL_L("Join"),
        uiBold,
        11,
        C.Lamp,
        UDim2.new(0,
        12,
        0,
        0),
        UDim2.new(1,
        -34,
        1,
        0))
        glyph(joinBtn,
        "arrow-up-right",
        C.Lamp,
        UDim2.new(1,
        -22,
        0.5,
        -6),
        12)
        joinBtn.MouseEnter:Connect(function()
            tw(joinBtn,
            { BackgroundTransparency = 0.74 },
            T.fast)
            tw(joinStroke,
            { Transparency = 0.3 },
            T.fast)
        end)
        joinBtn.MouseLeave:Connect(function()
            tw(joinBtn,
            { BackgroundTransparency = 0.88 },
            T.fast)
            tw(joinStroke,
            { Transparency = 0.55 },
            T.fast)
        end)
        tap(joinBtn,
        function()
            if setclipboard then
                pcall(function()
                    setclipboard(DISCORD_INVITE)
                end)
                toast(IXAL_L("Invite copied"))
            else
                toast(DISCORD_INVITE)
            end
        end)
        local function layoutPair(w)
            local stacked = w < 400
            pair.Size = UDim2.new(1,
            0,
            0,
            stacked and 258 or 124)
            if stacked then
                sessionCard.Position = UDim2.new(0,
                0,
                0,
                0)
                sessionCard.Size = UDim2.new(1,
                0,
                0,
                124)
                commCard.Position = UDim2.new(0,
                0,
                0,
                134)
                commCard.Size = UDim2.new(1,
                0,
                0,
                124)
            else
                sessionCard.Position = UDim2.new(0,
                0,
                0,
                0)
                sessionCard.Size = UDim2.new(0.5,
                -5,
                1,
                0)
                commCard.Position = UDim2.new(0.5,
                5,
                0,
                0)
                commCard.Size = UDim2.new(0.5,
                -5,
                1,
                0)
            end
        end
        local allBtn = new("TextButton",
        {
            Name = "Row",
            LayoutOrder = 4,
            Size = UDim2.new(1,
            0,
            0,
            44),
            BackgroundColor3 = C.Surface2,
            BackgroundTransparency = 0.65,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            Parent = c,
        })
        new("UICorner",
        { CornerRadius = UDim.new(0, 10), Parent = allBtn })
        local allStroke = new("UIStroke",
        { Color = C.Hair, Transparency = 0.6, Thickness = 1, Parent = allBtn })
        glyph(allBtn,
        "layout-grid",
        C.Faint,
        UDim2.new(0,
        14,
        0.5,
        -7),
        14)
        txt(allBtn,
        IXAL_L("All features"),
        uiMed,
        12.5,
        C.Text,
        UDim2.new(0,
        38,
        0,
        0),
        UDim2.new(1,
        -90,
        1,
        0))
        txt(allBtn,
        "OPEN",
        uiBold,
        9,
        C.Faint,
        UDim2.new(1,
        -62,
        0,
        0),
        UDim2.new(0,
        36,
        1,
        0),
        Enum.TextXAlignment.Right)
        glyph(allBtn,
        "arrow-up-right",
        C.Faint,
        UDim2.new(1,
        -20,
        0.5,
        -6),
        12)
        allBtn.MouseEnter:Connect(function()
            tw(allBtn,
            { BackgroundTransparency = 0.42 },
            T.fast)
            tw(allStroke,
            { Transparency = 0.38 },
            T.fast)
        end)
        allBtn.MouseLeave:Connect(function()
            tw(allBtn,
            { BackgroundTransparency = 0.65 },
            T.fast)
            tw(allStroke,
            { Transparency = 0.6 },
            T.fast)
        end)
        tap(allBtn,
        function()
            switchTab(2)
        end)
        local hint = new("Frame",
        {
            Name = "Row",
            LayoutOrder = 5,
            Size = UDim2.new(1,
            0,
            0,
            18),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = c,
        })
        txt(hint,
        "Drag the header to move · Right Shift toggles the hub",
        uiReg,
        10,
        C.Faint,
        UDim2.new(0,
        2,
        0,
        0),
        UDim2.new(1,
        -4,
        1,
        0))
        local function layout(width)
            local w = width > 40 and width or 600
            bustHolder.Visible = (not hideAvatar) and w >= 360
            info.Size = UDim2.new(1,
            w >= 360 and -212 or -40,
            1,
            -36)
            nameLbl.TextSize = w >= 360 and 30 or 26
            layoutStats(w)
            layoutPair(w)
        end
        layout(c.AbsoluteSize.X)
        track(c:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            layout(c.AbsoluteSize.X)
        end))
        local function refreshLive()
            if not hero.Parent then
                return false
            end
            local uptime = mainFmtUptime(os.time() - MAIN_T0)
            statCells[1].val.Text = tostring(#Players:GetPlayers())
            statCells[2].val.Text = uptime
            statCells[3].val.Text = LIVE.fps and tostring(LIVE.fps) or "--"
            statCells[4].val.Text = LIVE.ping and tostring(LIVE.ping) or "--"
            for _,
            s in ipairs(statCells) do
                s.cap.Text = string.upper(IXAL_L(s.def.cap))
            end
            local pingTxt = LIVE.ping and (tostring(LIVE.ping) .. " ms") or "--"
            gameLbl.Text = GAME_NAME or IXAL_L("Current game")
            sesMeta.Text = IXAL_L("Uptime") .. " " .. uptime .. "  ·  " .. IXAL_L("Ping") .. " " .. pingTxt .. "  ·  " .. IXAL_L("Place") .. " " .. tostring(game.PlaceId)
            metaLbl.Text = EXEC_NAME .. "  ·  v" .. BUILD_TAG .. "  ·  " .. pingTxt
            return true
        end
        refreshLive()
        task.spawn(function()
            while task.wait(1.5) do
                if not refreshLive() then
                    for _,
                    conn in ipairs(conns) do
                        pcall(function()
                            conn:Disconnect()
                        end)
                    end
                    return
                end
            end
        end)
    end
}

table.insert(TABS, 1, MAIN_TAB)

task.spawn(function()
    task.wait(0.15)
    if not gui or not gui.Parent then
        return
    end
    local ruNow = IXAL_Locale == "Russian"
    local dim = new("Frame", {
        Name = "IxaSplashDim",
        Active = false,
        Size = UDim2.new(1,
        0,
        1,
        0),
        BackgroundColor3 = Color3.new(0,
        0,
        0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 55,
        Parent = gui,
    })
    local holder = new("Frame", {
        Name = "IxaSplash",
        Active = false,
        AnchorPoint = Vector2.new(0.5,
        0.5),
        Position = UDim2.new(0.5,
        0,
        0.5,
        0),
        Size = UDim2.fromOffset(560,
        124),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 60,
        Parent = gui,
    })
    local sTitle = new("TextLabel", {
        Active = false,
        ZIndex = 61,
        BackgroundTransparency = 1,
        Position = UDim2.new(0,
        0,
        0,
        4),
        Size = UDim2.new(1,
        0,
        0,
        44),
        Text = HUB_TITLE,
        FontFace = uiBold,
        TextSize = 36,
        TextColor3 = C.On,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = holder,
    })
    local tGrad = new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,
            C.Accent),
            ColorSequenceKeypoint.new(0.45,
            C.On),
            ColorSequenceKeypoint.new(0.5,
            C.Lamp),
            ColorSequenceKeypoint.new(0.55,
            C.On),
            ColorSequenceKeypoint.new(1,
            C.Accent),
        }),
        Parent = sTitle,
    })
    mainShimmer(tGrad, 2.4)
    local sSub = new("TextLabel", {
        Active = false,
        ZIndex = 61,
        BackgroundTransparency = 1,
        Position = UDim2.new(0,
        0,
        0,
        52),
        Size = UDim2.new(1,
        0,
        0,
        24),
        Text = ruNow and ("С возвращением, " .. player.DisplayName) or ("Welcome back, " .. player.DisplayName),
        FontFace = uiReg,
        TextSize = 15,
        TextColor3 = C.Text,
        TextTransparency = 0.15,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = holder,
    })
    local sLine = new("Frame", {
        Active = false,
        ZIndex = 61,
        AnchorPoint = Vector2.new(0.5,
        0),
        Size = UDim2.new(0,
        0,
        0,
        2),
        Position = UDim2.new(0.5,
        0,
        0,
        88),
        BackgroundColor3 = C.On,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = holder,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sLine })
    local sTag = new("TextLabel", {
        Active = false,
        ZIndex = 61,
        BackgroundTransparency = 1,
        Position = UDim2.new(0,
        0,
        0,
        100),
        Size = UDim2.new(1,
        0,
        0,
        18),
        Text = ruNow and "инжект выполнен · хорошего сеанса" or "inject complete · have a good session",
        FontFace = uiReg,
        TextSize = 11,
        TextColor3 = C.Dim,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = holder,
    })
    tw(dim, { BackgroundTransparency = 0.45 }, 0.5)
    groupFadeSet(holder, 1)
    groupFade(sTitle, 0, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.25)
    groupFade(sSub, 0, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.5)
    groupFade(sLine, 0, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.6)
    tw(sLine, { Size = UDim2.new(0, 220, 0, 2) }, 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.6)
    groupFade(sTag, 0, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.75)
    task.wait(2.6)
    groupFade(holder, 1, 0.35)
    tw(dim, { BackgroundTransparency = 1 }, 0.45)
    task.wait(0.5)
    if holder.Parent then
        holder:Destroy()
    end
    if dim.Parent then
        dim:Destroy()
    end
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
        pcall(def.build, sink)
        sink:Destroy()
    end
    holder:Destroy()
    activeTab = savedTab
    uiRefs = savedUiRefs
end

local function setTabVisual(index)
    for i, t in ipairs(tabButtons) do
        local on = i == index
        tw(t.btn, { BackgroundTransparency = on and 0.35 or 0.92 }, T.mid)
        tw(t.ind, { BackgroundTransparency = on and 0 or 1 }, T.mid)
        tw(t.lbl, { TextColor3 = on and C.Text or C.Dim }, T.mid)
        if t.img then
            tw(t.img, { TextColor3 = on and C.On or C.Dim }, T.mid)
        end
        if t.stroke then
            tw(t.stroke, { Transparency = on and 0.62 or 0.9 }, T.mid)
        end
        if t.num then
            tw(t.num, { TextTransparency = on and 0.1 or 0.65 }, T.mid)
        end
    end
end
local function getRows()
    local rows = {}
    for _, d in ipairs(content:GetChildren()) do
        if d:IsA("Frame") and d.Name == "Row" then
            table.insert(rows, d)
        end
    end
    return rows
end
local function staggerIn()
    local rows = getRows()
    table.sort(rows, function(a, b)
        return a.LayoutOrder < b.LayoutOrder
    end)
    for i, d in ipairs(rows) do
        groupFadeSet(d, 1)
        groupFade(d, 0, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, (i - 1) * 0.035)
    end
end
buildTab = function(index, animate)
    for i = #openMenus, 1, -1 do
        openMenus[i].close()
    end
    extraCanvas = 0
    for _, d in ipairs(getRows()) do
        d:Destroy()
    end
    content.CanvasPosition = Vector2.new(0, 0)
    if TABS[index] then
        TABS[index].build(content)
    end
    updateCanvas()
    if animate then
        staggerIn()
    end
end

local rawBuildTab = buildTab
buildTab = function(index, animate)
    for i = #IXA_SearchRows, 1, -1 do
        if IXA_SearchRows[i].tab == index then
            table.remove(IXA_SearchRows, i)
        end
    end
    rawBuildTab(index, animate)
    if IXAL_ApplyTranslations then
        IXAL_ApplyTranslations()
    end
    if IXA_rebuildSuggestions and not IXA_SuppressFocusRebuild then
        IXA_rebuildSuggestions()
    end
end

local tabToken = 0
switchTab = function(index)
    if index == activeTab or not TABS[index] then
        return
    end
    activeTab = index
    setTabVisual(index)
    tabToken += 1
    local token = tabToken
    for _, d in ipairs(getRows()) do
        groupFade(d, 1, 0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    end
    task.delay(0.14, function()
        if token ~= tabToken then
            return
        end
        buildTab(index, true)
    end)
end
for i, def in ipairs(TABS) do
    makeTabButton(def.name, i, i)
end
setTabVisual(1)
buildTab(1, true);(function()
    local SEARCH_COLLAPSED = UDim2.fromOffset(26, 26)
    local SEARCH_EXPANDED = UDim2.fromOffset(228, 26)
    local searchRow = new("TextButton", {
        Name = "SearchBar",
        ZIndex = 3,
        AnchorPoint = Vector2.new(1,
        0.5),
        Size = SEARCH_COLLAPSED,
        Position = UDim2.new(1,
        -104,
        0.5,
        0),
        BackgroundColor3 = C.Surface2,
        BackgroundTransparency = 0.45,
        Text = "",
        AutoButtonColor = false,
        ClipsDescendants = true,
        BorderSizePixel = 0,
        Parent = header,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = searchRow })
    local searchStroke = new("UIStroke", { Color = C.Hair, Transparency = 0.5, Thickness = 1, Parent = searchRow })
    local searchIcon = new("TextLabel", {
        ZIndex = 4,
        Active = false,
        Size = UDim2.fromOffset(13,
        13),
        AnchorPoint = Vector2.new(0,
        0.5),
        Position = UDim2.new(0,
        7,
        0.5,
        0),
        BackgroundTransparency = 1,
        Text = "",
        TextScaled = false,
        TextSize = 12,
        FontFace = NL_ICON_REGULAR,
        TextColor3 = C.Faint,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = searchRow,
    })
    setIcon(searchIcon, "search", C.Faint)
    IXA_searchInput = new("TextBox", {
        Name = "SearchInput",
        ZIndex = 4,
        Size = UDim2.new(1,
        -34,
        1,
        0),
        Position = UDim2.new(0,
        25,
        0,
        0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search features...",
        PlaceholderColor3 = C.Faint,
        TextColor3 = C.Text,
        FontFace = uiMed,
        TextSize = 12.5,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        TextTransparency = 1,
        Visible = false,
        Parent = searchRow,
    })
    local suggBox = new("Frame", {
        Name = "SearchResultsBox",
        ZIndex = 5,
        AnchorPoint = Vector2.new(1,
        0),
        Size = UDim2.fromOffset(280,
        0),
        Position = UDim2.new(1,
        -10,
        0,
        66),
        BackgroundColor3 = C.Surface,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        Parent = window,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = suggBox })
    local suggStroke = new("UIStroke", { Color = C.Hair, Transparency = 0.35, Thickness = 1, Parent = suggBox })
    local suggestions = new("ScrollingFrame", {
        Name = "SearchResults",
        ZIndex = 5,
        Size = UDim2.new(1,
        -8,
        1,
        -12),
        Position = UDim2.new(0,
        4,
        0,
        6),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.Accent,
        CanvasSize = UDim2.new(0,
        0,
        0,
        0),
        Parent = suggBox,
    })
    local suggLayout = new("UIListLayout", {
        Padding = UDim.new(0,
        4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = suggestions,
    })
    local function updateSearchCanvas()
        suggestions.CanvasSize = UDim2.new(0, 0, 0, suggLayout.AbsoluteContentSize.Y + 6)
        local h = math.min(suggLayout.AbsoluteContentSize.Y + 18, 8 * 34 + 14)
        if h < 42 then
            h = 42
        end
        suggBox.Size = UDim2.new(0, 280, 0, h)
    end
    suggLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSearchCanvas)
    IXA_SearchOpen = false
    IXA_OpenSearch = function()
        if IXA_SearchOpen or unloaded then
            return
        end
        IXA_SearchOpen = true
        IXA_searchInput.Visible = true
        tw(searchRow, { Size = SEARCH_EXPANDED, BackgroundTransparency = 0.1 }, 0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tw(IXA_searchInput, { TextTransparency = 0 }, 0.2)
        tw(searchIcon, { TextColor3 = C.Text }, 0.2)
        tw(searchStroke, { Color = C.On, Transparency = 0.6 }, 0.2)
        tw(telemetry, { GroupTransparency = 1 }, 0.2)
        tw(brand, { GroupTransparency = 1 }, 0.2)
        task.delay(0.18, function()
            if IXA_SearchOpen and IXA_searchInput and IXA_searchInput.Parent then
                pcall(function()
                    IXA_searchInput:CaptureFocus()
                end)
            end
        end)
    end
    IXA_CloseSearch = function()
        if not IXA_SearchOpen then
            return
        end
        IXA_SearchOpen = false
        suggBox.Visible = false
        IXA_searchInput.Text = ""
        pcall(function()
            IXA_searchInput:ReleaseFocus()
        end)
        tw(IXA_searchInput, { TextTransparency = 1 }, 0.1)
        tw(searchIcon, { TextColor3 = C.Faint }, 0.2)
        tw(searchStroke, { Color = C.Hair, Transparency = 0.5 }, 0.2)
        tw(telemetry, { GroupTransparency = 0 }, 0.25)
        tw(brand, { GroupTransparency = 0 }, 0.25)
        tw(searchRow, { Size = SEARCH_COLLAPSED, BackgroundTransparency = 0.45 }, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        task.delay(0.26, function()
            if not IXA_SearchOpen then
                IXA_searchInput.Visible = false
            end
        end)
    end
    searchRow.MouseEnter:Connect(function()
        if not IXA_SearchOpen then
            tw(searchRow, { BackgroundTransparency = 0.2 }, T.fast)
        end
    end)
    searchRow.MouseLeave:Connect(function()
        if not IXA_SearchOpen then
            tw(searchRow, { BackgroundTransparency = 0.45 }, T.fast)
        end
    end)
    searchRow.MouseButton1Click:Connect(function()
        if IXA_SearchOpen then
            IXA_CloseSearch()
        else
            IXA_OpenSearch()
        end
    end)
    IXA_resultPending = false
    IXA_FirstSuggestion = nil
    IXA_flashToken = 0
    IXA_SuppressFocusRebuild = false
    IXA_LOWER = {}
    for _, rng in ipairs({
        { 0x41, 0x5A, 32 },
        { 0x0410, 0x042F, 32 },
        { 0x0460, 0x0481, 1 },
        { 0x048A, 0x052F, 1 }
    }) do
        for code = rng[1], rng[2] do
            IXA_LOWER[code] = code + rng[3]
        end
    end
    IXA_LOWER[0x0401] = 0x0451
    local function lowerText(s)
        if not s or s == "" then
            return ""
        end
        local out = {}
        for _, code in utf8.codes(s) do
            table.insert(out, utf8.char(IXA_LOWER[code] or code))
        end
        return table.concat(out)
    end
    local function searchScore(query, text)
        if not text or text == "" then
            return nil
        end
        local t = lowerText(text)
        local idx = t:find(query, 1, true)
        if not idx then
            return nil
        end
        if idx == 1 then
            return 0
        end
        local prev = t:sub(idx - 1, idx - 1)
        if prev == " " or prev == "-" or prev == "." or prev == "+" or prev == ":" then
            return 1
        end
        return 2
    end
    local function looseScore(query, text)
        if not query or query == "" then
            return false
        end
        local t = lowerText(text or "")
        local pos = 0
        for _, ch in utf8.codes(query) do
            local at = t:find(utf8.char(ch), pos + 1, true)
            if not at then
                return false
            end
            pos = at
        end
        return true
    end
    IXA_flashRow = function(row)
        if not row then
            return
        end
        IXA_flashToken += 1
        local token = IXA_flashToken
        cancelTweens(row)
        local stroke = row:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Transparency = 0
        end
        task.spawn(function()
            local startT = os.clock()
            local dur = 2.2
            local deepGray = Color3.fromRGB(43, 43, 47)
            while os.clock() - startT < dur do
                if token ~= IXA_flashToken or not row.Parent then
                    return
                end
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
                if stroke then
                    tw(stroke, { Transparency = 1 }, 0.4)
                end
            end
        end)
        task.spawn(function()
            for _ = 1, 2 do
                if token ~= IXA_flashToken or not row.Parent then
                    return
                end
                tw(row, { BackgroundTransparency = 0.08 }, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(0.55)
                if token ~= IXA_flashToken or not row.Parent then
                    return
                end
                tw(row, { BackgroundTransparency = 0.6 }, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(0.55)
            end
        end)
    end
    IXA_ScrollToRow = function(entry)
        if not entry or not entry.tab then
            return
        end
        task.delay(0.34, function()
            if entry.tab ~= activeTab then
                return
            end
            local function freshRow()
                if entry.row and entry.row.Parent then
                    return entry.row
                end
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
            if not (row and row.Parent) then
                return
            end
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
                    if not row.Parent or entry.tab ~= activeTab then
                        return
                    end
                    local vis = content.AbsoluteSize.Y
                    if vis >= 40 then
                        local max = math.max(0, content.CanvasSize.Y.Offset - vis)
                        local want = math.clamp(cumY + rowH / 2 - vis / 2, 0, max)
                        if math.abs(content.CanvasPosition.Y - want) <= 3 then
                            return
                        end
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
            if d:IsA("TextButton") then
                d:Destroy()
            end
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
                        if f.entry.tab == entry.tab and f.entry.order == entry.order then
                            dupe = true
                            break
                        end
                    end
                    if not dupe then
                        found[#found + 1] = {
                            rank = rank,
                            entry = entry,
                            label = (titleRu ~= "" and titleRu) or titleEn
                        }
                    end
                end
            end
        end
        table.sort(found, function(a, b)
            if a.rank ~= b.rank then
                return a.rank < b.rank
            end
            return a.label:lower() < b.label:lower()
        end)
        while #found > 16 do
            table.remove(found)
        end
        local maxShow = math.min(#found, 8)
        for i = 1, maxShow do
            local hit = found[i]
            local btn = new("TextButton", {
                Size = UDim2.new(1,
                -6,
                0,
                30),
                LayoutOrder = i,
                BackgroundColor3 = C.Surface2,
                BackgroundTransparency = 0.9,
                Text = "",
                AutoButtonColor = false,
                BorderSizePixel = 0,
                Parent = suggestions,
            })
            new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
            local mark = new("Frame", {
                Name = "HoverMark",
                AnchorPoint = Vector2.new(0,
                0.5),
                Size = UDim2.new(0,
                2,
                1,
                -14),
                Position = UDim2.new(0,
                4,
                0.5,
                0),
                BackgroundColor3 = C.On,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = btn,
            })
            new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = mark })
            new("TextLabel", {
                Active = false,
                Size = UDim2.new(1,
                -92,
                1,
                0),
                Position = UDim2.new(0,
                12,
                0,
                0),
                BackgroundTransparency = 1,
                Text = hit.label,
                TextColor3 = C.Text,
                FontFace = uiMed,
                TextSize = 12.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = btn,
            })
            local tabLabel = new("TextLabel", {
                Active = false,
                Size = UDim2.new(0,
                80,
                1,
                0),
                Position = UDim2.new(1,
                -86,
                0,
                0),
                BackgroundTransparency = 1,
                Text = IXAL_L(TABS[hit.entry.tab] and TABS[hit.entry.tab].name or ""),
                TextColor3 = C.Faint,
                TextTransparency = 0.1,
                FontFace = uiReg,
                TextSize = 10.5,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = btn,
            })
            tabLabel:SetAttribute("RoleTag", "Dim")
            btn.MouseEnter:Connect(function()
                tw(btn, { BackgroundTransparency = 0.78 }, T.fast)
                tw(mark, { BackgroundTransparency = 0 }, T.fast)
            end)
            btn.MouseLeave:Connect(function()
                tw(btn, { BackgroundTransparency = 0.9 }, T.fast)
                tw(mark, { BackgroundTransparency = 1 }, T.fast)
            end)
            tap(btn, function()
                IXA_resultPending = true
                IXA_resultCB(hit.entry)
            end)
            if i == 1 then
                IXA_FirstSuggestion = hit.entry
            end
        end
        updateSearchCanvas()
        suggBox.Visible = (maxShow > 0) and IXA_SearchOpen
    end
    IXA_resultCB = function(entry)
        if not entry or not entry.tab then
            return
        end
        suggBox.Visible = false
        switchTab(entry.tab)
        IXA_ScrollToRow(entry)
    end
    IXA_SearchRestoreFocus = function()
        if IXA_resultPending then
            IXA_resultPending = false
            return
        end
        if not isOpen or unloaded then
            return
        end
        if not IXA_SearchOpen then
            return
        end
        task.defer(function()
            if IXA_searchInput and IXA_searchInput.Parent then
                IXA_searchInput:CaptureFocus()
            end
        end)
    end
    IXA_ApplySearchTheme = function()
        if not searchRow or not searchRow.Parent then
            return
        end
        searchRow.BackgroundColor3 = C.Surface2
        searchIcon.TextColor3 = IXA_SearchOpen and C.Text or C.Faint
        IXA_searchInput.TextColor3 = C.Text
        IXA_searchInput.PlaceholderColor3 = C.Faint
        searchStroke.Color = C.Hair
        suggBox.BackgroundColor3 = C.Surface
        suggStroke.Color = C.Hair
        for _, d in ipairs(suggestions:GetChildren()) do
            if d:IsA("TextButton") then
                d.BackgroundColor3 = C.Surface2
                local st = d:FindFirstChildOfClass("UIStroke")
                if st then
                    st.Color = C.Hair
                end
                for _, e in ipairs(d:GetChildren()) do
                    if e:IsA("TextLabel") then
                        e.TextColor3 = (e:GetAttribute("RoleTag") == "Dim") and C.Faint or C.Text
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
end)();(function()
    local windowDrag = {
        active = false,
        origin = Vector2.new(0,
        0),
        target = Vector2.new(0,
        0),
        current = Vector2.new(0,
        0),
    }
    local function clampWindowPos(p, w, h)
        local v = vp()
        local halfW = w / 2
        local minX = 8 + halfW - v.X / 2
        local maxX = v.X / 2 - halfW - 8
        if minX > maxX then
            minX, maxX = 0, 0
        end
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
            tw(f[1], { [f[2]] = out and 1 or f[3] }, duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, delayTime)
        end
        tw(logoIcon, { ImageTransparency = 1 }, duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, delayTime)
        tw(cometGlow, { ImageTransparency = 1 }, duration)
        for _, trail in ipairs(cometTrail) do
            tw(trail, { ImageTransparency = 1 }, duration)
        end
    end
    islandEntrance = function()
        if unloaded or island.Visible then
            return
        end
        for _, f in ipairs(islandFadeables) do
            f[1][f[2]] = 1
        end
        logoIcon.ImageTransparency = 1
        cometGlow.ImageTransparency = 1
        for _, trail in ipairs(cometTrail) do
            trail.ImageTransparency = 1
        end
        islandScale.Scale = 0.82
        island.Visible = true
        fadeIsland(false, 0.5, 0.05)
        tw(islandScale, { Scale = 1 }, 0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0.05)
        task.delay(0.9, function()
            if not isOpen and island.Visible then
                strikeComet()
            end
        end)
    end
    openHub = function()
        if isOpen or unloaded then
            return
        end
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
        local targetPos = normPos()
        local targetSize = normSize()
        if isFull then
            local v = vp()
            local nw, nh = fullSizeFit()
            targetSize = UDim2.fromOffset(nw, nh)
            targetPos = UDim2.new(0.5, 0, 0, math.max(8, (v.Y - nh) / 2))
        end
        local winTween = tw(window, { Position = targetPos, Size = targetSize, BackgroundTransparency = 1, }, T.open, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tw(winCorner, { CornerRadius = UDim.new(0, 22) }, T.open, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tw(bg, { ImageTransparency = 1, BackgroundTransparency = 0.08 }, T.open, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tw(overlay, { BackgroundTransparency = 0.65 }, T.open, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tw(winStroke, { Transparency = 0.6 }, T.open, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        chrome.Visible = true
        groupFadeSet(chrome, 1)
        groupFade(chrome, 0, T.open * 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, T.open * 0.35)
        task.delay(T.mid, function()
            if token ~= anim.token then
                return
            end
            island.Visible = false
        end)
        winTween.Completed:Connect(function(playState)
            if token ~= anim.token then
                return
            end
            anim.animating = (playState ~= Enum.PlaybackState.Completed)
        end)
    end
    closeHub = function()
        if not isOpen or unloaded then
            return
        end
        isOpen = false
        anim.token += 1
        anim.animating = true
        local token = anim.token
        groupFade(chrome, 1, T.close * 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        IXA_CloseSearch()
        island.Visible = true
        for _, f in ipairs(islandFadeables) do
            f[1][f[2]] = 1
        end
        logoIcon.ImageTransparency = 1
        cometGlow.ImageTransparency = 1
        for _, trail in ipairs(cometTrail) do
            trail.ImageTransparency = 1
        end
        local winTween = tw(window, {
            Position = islandPos(),
            Size = UDim2.fromOffset(ISLAND_W,
            ISLAND_H),
            BackgroundTransparency = 0.15,
        }, T.close, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tw(winCorner, { CornerRadius = UDim.new(0, 18) }, T.close, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tw(bg, { ImageTransparency = 1, BackgroundTransparency = 1 }, T.close, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tw(overlay, { BackgroundTransparency = 1 }, T.close, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tw(winStroke, { Transparency = 1 }, T.close, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        fadeIsland(false, T.close * 0.6, T.close * 0.35)
        task.delay(T.close * 0.35, function()
            if token ~= anim.token then
                return
            end
            islandScale.Scale = 0.75
            tw(islandScale, { Scale = 1 }, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end)
        winTween.Completed:Connect(function(playState)
            if token ~= anim.token then
                return
            end
            window.Visible = false
            chrome.Visible = false
            anim.animating = (playState ~= Enum.PlaybackState.Completed)
        end)
    end
    toggleFull = function()
        if unloaded then
            return
        end
        if not isOpen or anim.animating then
            return
        end
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
                Position = UDim2.new(0.5,
                pos.X,
                0,
                pos.Y),
                Size = UDim2.fromOffset(nw,
                nh),
            }, T.mid, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            isFull = true
        else
            isFull = false
            local r = fullRect or { x = 0, y = 40, w = W, h = H }
            local pos = clampWindowPos(Vector2.new(r.x, r.y), r.w, r.h)
            tw(window, {
                Position = UDim2.new(0.5,
                pos.X,
                0,
                pos.Y),
                Size = UDim2.fromOffset(r.w,
                r.h),
            }, T.mid, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        end
    end
    cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if unloaded then
            return
        end
        IXA_FitViewport()
        if window.Visible and not isFull and not anim.animating then
            local pos = clampWindowPos(Vector2.new(window.Position.X.Offset, window.Position.Y.Offset), W, H)
            tw(window, {
                Position = UDim2.new(0.5,
                pos.X,
                0,
                pos.Y),
                Size = UDim2.fromOffset(W,
                H),
            }, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    end)
    local islandStretchLast = nil
    connectDrag(island, function()
        islandDrag.active = true
        islandDrag.origin = islandDrag.current
        islandStretchLast = nil
    end, function(delta)
        islandDrag.target = clampIslandOffset(islandDrag.origin + delta)
    end, function(moved)
        islandDrag.active = false
        islandStretchLast = nil
        if not moved then
            openHub()
        end
    end)
    connectDrag(header, function()
        local p = Vector2.new(window.Position.X.Offset, window.Position.Y.Offset)
        windowDrag.origin = p
        windowDrag.current = p
        windowDrag.target = p
        windowDrag.active = true
        cancelTweens(window)
    end, function(delta)
        windowDrag.target = clampWindowPos(windowDrag.origin + delta, window.AbsoluteSize.X, window.AbsoluteSize.Y)
    end, function()
        windowDrag.active = false
    end)
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
        if gameProcessed then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        if input.KeyCode == Enum.KeyCode.RightShift then
            if unloaded then
                return
            end
            if isOpen then
                closeHub()
            else
                openHub()
            end
        end
    end)
    do
        local IDLE_AFTER = 10
        local idleTarget = 0
        local idleAlpha = 0
        local lastActivity = os.clock()
        local function bumpActivity()
            lastActivity = os.clock()
            idleTarget = 0
        end
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.Keyboard then
                bumpActivity()
            end
        end)
        RunService.RenderStepped:Connect(function(dt)
            if unloaded or not gui.Parent then
                return
            end
            if idleTarget == 0 and (os.clock() - lastActivity) >= IDLE_AFTER then
                idleTarget = 0.5
            end
            local speed = (idleTarget > idleAlpha) and 3.5 or 11
            idleAlpha += (idleTarget - idleAlpha) * math.min(dt * speed, 1)
            if math.abs(idleAlpha - idleTarget) < 0.002 then
                idleAlpha = idleTarget
            end
            islandVisual.BackgroundTransparency = 0.28 + idleAlpha * 0.5
            chrome.GroupTransparency = idleAlpha
        end)
    end
    do
        local t0 = os.clock()
        RunService.RenderStepped:Connect(function()
            if unloaded then
                return
            end
            if not island.Visible or window.Visible or anim.animating then
                return
            end
            local t = os.clock() - t0
            local pulse = (math.sin(t * math.pi * 2 / 1.2) + 1) / 2
            islandGlow.Thickness = 1.25 + pulse * 0.35
            islandGlow.Transparency = math.max(0.3, 0.5 - pulse * 0.18)
        end)
    end
    toast("Ixa Hub loaded · " .. (UI_PARENT == guiRoot and "fallback: PlayerGui" or "hidden") .. " · RShift")
end)()
