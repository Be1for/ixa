local Ixa = {}
Ixa.Version = "3.0.0"

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

local function viewport()
    local cam = workspace.CurrentCamera
    if cam then
        return cam.ViewportSize
    end
    return Vector2.new(1280, 720)
end

local function resolveParent()
    if type(gethui) == "function" then
        local ok, parent = pcall(gethui)
        if ok and typeof(parent) == "Instance" then
            return parent
        end
    end
    local ok, core = pcall(function()
        local coreGui = game:GetService("CoreGui")
        local probe = Instance.new("Folder")
        probe.Parent = coreGui
        probe:Destroy()
        return coreGui
    end)
    if ok and typeof(core) == "Instance" then
        return core
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local DEFAULT_ACCENT = Color3.fromRGB(224, 110, 78)

local Theme = {
    window = Color3.fromRGB(21, 20, 19),
    sidebar = Color3.fromRGB(16, 15, 14),
    panel = Color3.fromRGB(28, 27, 25),
    panelHover = Color3.fromRGB(34, 32, 30),
    field = Color3.fromRGB(17, 16, 15),
    raised = Color3.fromRGB(37, 35, 32),
    raisedHover = Color3.fromRGB(43, 41, 37),
    line = Color3.fromRGB(50, 47, 43),
    lineSoft = Color3.fromRGB(40, 38, 35),
    text = Color3.fromRGB(235, 232, 226),
    dim = Color3.fromRGB(157, 152, 144),
    faint = Color3.fromRGB(112, 108, 102),
    good = Color3.fromRGB(136, 198, 153),
    warn = Color3.fromRGB(226, 182, 108),
    bad = Color3.fromRGB(226, 121, 112),
    white = Color3.fromRGB(255, 255, 255),
    black = Color3.fromRGB(0, 0, 0),
}

local function resolveFont(names, lastResort)
    for _, name in ipairs(names) do
        local ok, enum = pcall(function()
            return Enum.Font[name]
        end)
        if ok and enum then
            local ok2, face = pcall(Font.fromEnum, enum)
            if ok2 and face then
                return face
            end
        end
    end
    local ok, fallback = pcall(function()
        return Font.fromEnum(Enum.Font[lastResort])
    end)
    if ok then
        return fallback
    end
    return Font.fromEnum(Enum.Font.SourceSans)
end

local Fonts = {
    regular = resolveFont({ "BuilderSans", "GothamMedium", "Gotham" }, "Gotham"),
    medium = resolveFont({ "BuilderSansMedium", "GothamMedium", "Gotham" }, "GothamMedium"),
    bold = resolveFont({ "BuilderSansBold", "GothamBold", "GothamBold" }, "GothamBold"),
    black = resolveFont({ "BuilderSansExtraBold", "GothamBlack", "GothamBold" }, "GothamBlack"),
}

local IconFont = nil
pcall(function()
    IconFont = Font.new(
        "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json",
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
end)

local IconAliases = {
    ["settings"] = "gear",
    ["save"] = "floppy-disk",
    ["search"] = "magnifying-glass",
    ["user"] = "person",
    ["users"] = "people",
    ["swords"] = "sword",
    ["crosshair"] = "crosshairs",
    ["maximize"] = "dual-arrows-to-corners",
    ["maximize-2"] = "dual-arrows-to-corners",
    ["trash"] = "trash-can",
    ["trash-2"] = "trash-can",
    ["close"] = "x",
    ["zap"] = "lightning-bolt",
    ["wifi"] = "signal-exclamation",
    ["plus"] = "plus-large",
}

local IconFallback = {
    ["magnifying-glass"] = "\u{2315}",
    ["x"] = "\u{00D7}",
    ["minus"] = "\u{2013}",
    ["dual-arrows-to-corners"] = "\u{2921}",
    ["chevron-down"] = "\u{2304}",
    ["chevron-right"] = "\u{203A}",
    ["check"] = "\u{2713}",
    ["gear"] = "\u{2699}",
    ["house"] = "\u{2302}",
    ["person"] = "\u{25CF}",
    ["people"] = "\u{25CF}",
    ["floppy-disk"] = "\u{25A3}",
    ["star"] = "\u{2605}",
    ["eye"] = "\u{25C9}",
    ["eye-off"] = "\u{25CE}",
    ["dot"] = "\u{2022}",
    ["plus-large"] = "+",
    ["trash-can"] = "\u{232B}",
    ["lightning-bolt"] = "\u{03DF}",
    ["signal-exclamation"] = "!",
    ["activity"] = "\u{223F}",
    ["sword"] = "\u{2020}",
    ["crosshairs"] = "\u{25CE}",
    ["arrow-up-right"] = "\u{2197}",
    ["clock"] = "\u{25F7}",
    ["timer"] = "\u{25D4}",
    ["message-circle"] = "\u{25CC}",
    ["sparkles"] = "\u{2727}",
    ["shield-check"] = "\u{25C7}",
    ["copy"] = "\u{29C9}",
    ["layout-grid"] = "\u{25A6}",
    ["flag"] = "\u{2691}",
    ["gauge"] = "\u{25E0}",
}

local function glyph(name)
    name = IconAliases[name] or name
    if IconFont then
        return name
    end
    return IconFallback[name] or "\u{2022}"
end

local function new(className, props)
    local inst = Instance.new(className)
    pcall(function()
        inst.AutoLocalize = false
    end)
    for key, value in pairs(props or {}) do
        pcall(function()
            inst[key] = value
        end)
    end
    return inst
end

local function corner(parent, radius)
    return new("UICorner", {
        CornerRadius = typeof(radius) == "UDim" and radius or UDim.new(0, radius or 8),
        Parent = parent,
    })
end

local function stroke(parent, color, transparency, thickness)
    return new("UIStroke", {
        Color = color or Theme.line,
        Transparency = transparency == nil and 1 or transparency,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function pad(parent, top, right, bottom, left)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        PaddingLeft = UDim.new(0, left or 0),
        Parent = parent,
    })
end

local function list(parent, padding, direction)
    return new("UIListLayout", {
        FillDirection = direction or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, padding or 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

local tweens = setmetatable({}, { __mode = "k" })

local function cancelTweens(inst)
    local pending = tweens[inst]
    if not pending then
        return
    end
    for _, tween in ipairs(pending) do
        pcall(function()
            tween:Cancel()
        end)
    end
    tweens[inst] = nil
end

local function tween(inst, props, time, style, direction, delay)
    if not inst or not inst.Parent then
        return
    end
    cancelTweens(inst)
    local t = TweenService:Create(
        inst,
        TweenInfo.new(
            time or 0.14,
            style or Enum.EasingStyle.Quad,
            direction or Enum.EasingDirection.Out,
            0,
            false,
            delay or 0
        ),
        props
    )
    tweens[inst] = { t }
    t:Play()
    return t
end

local function clampWindowSize(width, height)
    local v = viewport()
    local w = math.clamp(width, 680, math.max(680, v.X - 24))
    local h = math.clamp(height, 420, math.max(420, v.Y - 24))
    return w, h
end

local function centerOffsetLimits(w, h)
    local v = viewport()
    local minX = (w - v.X) / 2 + 10
    local maxX = (v.X - w) / 2 - 10
    local minY = (h - v.Y) / 2 + 10
    local maxY = (v.Y - h) / 2 - 10
    if minX > maxX then
        minX, maxX = 0, 0
    end
    if minY > maxY then
        minY, maxY = 0, 0
    end
    return minX, maxX, minY, maxY
end

local function clampCenter(x, y, w, h)
    local minX, maxX, minY, maxY = centerOffsetLimits(w, h)
    return Vector2.new(math.clamp(x, minX, maxX), math.clamp(y, minY, maxY))
end

local function hexOf(color)
    local function part(value)
        return math.clamp(math.floor(value * 255 + 0.5), 0, 255)
    end
    return string.format("%02X%02X%02X", part(color.R), part(color.G), part(color.B))
end

local function colorOf(hex)
    hex = tostring(hex or ""):gsub("#", "")
    if #hex == 3 then
        hex = hex:sub(1, 1):rep(2) .. hex:sub(2, 2):rep(2) .. hex:sub(3, 3):rep(2)
    end
    local r = tonumber(hex:sub(1, 2), 16) or 255
    local g = tonumber(hex:sub(3, 4), 16) or 255
    local b = tonumber(hex:sub(5, 6), 16) or 255
    return Color3.fromRGB(r, g, b)
end

local function HSVtoRGB(h, s, v)
    local r, g, b = 0, 0, 0
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then
        r, g, b = v, t, p
    elseif i == 1 then
        r, g, b = q, v, p
    elseif i == 2 then
        r, g, b = p, v, t
    elseif i == 3 then
        r, g, b = p, q, v
    elseif i == 4 then
        r, g, b = t, p, v
    else
        r, g, b = v, p, q
    end
    return Color3.new(r, g, b)
end

local function RGBtoHSV(color)
    local r, g, b = color.R, color.G, color.B
    local maxV = math.max(r, g, b)
    local minV = math.min(r, g, b)
    local delta = maxV - minV
    local h = 0
    if delta > 0 then
        if maxV == r then
            h = ((g - b) / delta) % 6
        elseif maxV == g then
            h = (b - r) / delta + 2
        else
            h = (r - g) / delta + 4
        end
        h = h / 6
    end
    local s = maxV == 0 and 0 or delta / maxV
    return h, s, maxV
end

local function roundTo(value, step, decimals)
    if step and step > 0 then
        value = math.floor(value / step + 0.5) * step
    end
    if decimals and decimals > 0 then
        local factor = 10 ^ decimals
        value = math.floor(value * factor + 0.5) / factor
    end
    return value
end

local function formatNumber(value, decimals)
    decimals = decimals or 0
    if decimals <= 0 then
        return tostring(math.floor(value + 0.5))
    end
    local text = string.format("%." .. tostring(decimals) .. "f", value)
    text = text:gsub("0+$", ""):gsub("%.$", "")
    return text
end

local keyNames = {
    RightShift = "RShift",
    LeftShift = "LShift",
    RightControl = "RCtrl",
    LeftControl = "LCtrl",
    RightAlt = "RAlt",
    LeftAlt = "LAlt",
    Backspace = "Bksp",
    Return = "Enter",
    Escape = "Esc",
    Delete = "Del",
    Insert = "Ins",
    PageUp = "PgUp",
    PageDown = "PgDn",
    CapsLock = "Caps",
    Tab = "Tab",
    Space = "Space",
}

local function keyLabel(keyCode)
    if not keyCode then
        return "\u{2014}"
    end
    local name = typeof(keyCode) == "EnumItem" and keyCode.Name or tostring(keyCode)
    return keyNames[name] or name
end

local function safeCallback(fn, ...)
    if type(fn) ~= "function" then
        return
    end
    local args = table.pack(...)
    task.spawn(function()
        local ok, err = pcall(fn, table.unpack(args, 1, args.n))
        if not ok then
            warn("[ixa] callback failed: " .. tostring(err))
        end
    end)
end

local function emitter()
    local handlers = {}
    return {
        Connect = function(fn)
            if type(fn) ~= "function" then
                return { Disconnect = function() end }
            end
            table.insert(handlers, fn)
            local connected = true
            return {
                Disconnect = function()
                    if not connected then
                        return
                    end
                    connected = false
                    for index, handler in ipairs(handlers) do
                        if handler == fn then
                            table.remove(handlers, index)
                            break
                        end
                    end
                end,
            }
        end,
        Fire = function(...)
            local args = table.pack(...)
            for _, handler in ipairs(handlers) do
                local ok, err = pcall(handler, table.unpack(args, 1, args.n))
                if not ok then
                    warn("[ixa] listener failed: " .. tostring(err))
                end
            end
        end,
    }
end

local function tap(gui, callback)
    local start = nil
    local inputType = nil
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            start = input.Position
            inputType = input.UserInputType
        end
    end)
    gui.InputEnded:Connect(function(input)
        if start == nil or input.UserInputType ~= inputType then
            return
        end
        local distance = (input.Position - start).Magnitude
        start = nil
        inputType = nil
        if distance <= 7 then
            callback()
        end
    end)
end

local function drag(gui, onStart, onMove, onFinish)
    local connections = {}

    local function add(connection)
        table.insert(connections, connection)
        return connection
    end

    local function forget(connection)
        local index = table.find(connections, connection)
        if index then
            table.remove(connections, index)
        end
    end

    add(gui.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local origin = input.Position
        local moving = false
        local moveConnection
        local endConnection
        moveConnection = add(UserInputService.InputChanged:Connect(function(changed)
            if changed.UserInputType ~= Enum.UserInputType.MouseMovement and changed.UserInputType ~= Enum.UserInputType.Touch then
                return
            end
            local delta = changed.Position - origin
            if not moving and delta.Magnitude > 6 then
                moving = true
                if onStart then
                    onStart()
                end
            end
            if moving and onMove then
                onMove(delta)
            end
        end))
        endConnection = add(UserInputService.InputEnded:Connect(function(ended)
            if ended.UserInputType ~= input.UserInputType then
                return
            end
            moveConnection:Disconnect()
            endConnection:Disconnect()
            forget(moveConnection)
            forget(endConnection)
            if onFinish then
                onFinish(moving)
            end
        end))
    end))

    return {
        Disconnect = function()
            for _, connection in ipairs(connections) do
                pcall(function()
                    connection:Disconnect()
                end)
            end
            table.clear(connections)
        end,
    }
end

local function isKeyDown(keyCode)
    local ok, pressed = pcall(function()
        return UserInputService:IsKeyDown(keyCode)
    end)
    return ok and pressed
end

local function mix(a, b, alpha)
    return a:Lerp(b, alpha)
end

local function iconLabel(parent, name, textSize, color)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = glyph(name),
        FontFace = IconFont or Fonts.regular,
        TextSize = textSize or 12,
        TextColor3 = color or Theme.faint,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = parent,
    })
end

local function keycap(parent, text, width, height)
    local box = new("Frame", {
        Size = UDim2.fromOffset(width or 42, height or 16),
        BackgroundColor3 = Theme.raised,
        BorderSizePixel = 0,
        Parent = parent,
    })
    corner(box, 5)
    local border = stroke(box, Theme.line, 0.35, 1)
    local label = new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = text or "",
        FontFace = Fonts.bold,
        TextSize = 8.5,
        TextColor3 = Theme.dim,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = box,
    })
    return box, label, border
end

local function executorName()
    local ok, name = pcall(function()
        if type(identifyexecutor) == "function" then
            return identifyexecutor()
        end
        if type(getexecutername) == "function" then
            return getexecutername()
        end
    end)
    if ok and type(name) == "string" and name ~= "" then
        return name
    end
    return "studio"
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

Ixa._windows = Ixa._windows or {}

function Ixa:Window(options)
    options = options or {}

    local self = setmetatable({}, Window)
    self.options = options
    self.flags = {}
    self.tabs = {}
    self.index = {}
    self.connections = {}
    self.notifications = {}
    self.destroyed = false
    self.isOpen = false
    self.activeIndex = nil
    self.searchOpen = false
    self.popover = nil
    self.workspace = tostring(options.workspace or "app")

    self.theme = {}
    for key, value in pairs(Theme) do
        self.theme[key] = value
    end
    local accent = options.accent
    if typeof(accent) ~= "Color3" then
        accent = DEFAULT_ACCENT
    end
    self.theme.accent = accent
    self.theme.accentDim = mix(self.theme.accent, Theme.window, 0.72)
    self.theme.accentDeep = mix(self.theme.accent, Theme.black, 0.18)

    self.title = tostring(options.title or "ixa")
    self.subtitle = tostring(options.subtitle or "interface")
    self.version = tostring(options.version or Ixa.Version)
    local toggleKey = options.toggleKey
    if typeof(toggleKey) ~= "EnumItem" or toggleKey.EnumType ~= Enum.KeyCode then
        toggleKey = Enum.KeyCode.RightShift
    end
    self.toggleKey = toggleKey
    self.resizable = options.resizable ~= false
    self.launcherEnabled = options.launcher ~= false
    self.user = LocalPlayer

    local size = options.size
    if typeof(size) ~= "Vector2" then
        size = Vector2.new(tonumber(options.width) or 820, tonumber(options.height) or 520)
    end
    self.size = Vector2.new(clampWindowSize(size.X, size.Y))
    local position = options.position
    local positionX = typeof(position) == "Vector2" and position.X or 0
    local positionY = typeof(position) == "Vector2" and position.Y or 0
    self.center = clampCenter(
        positionX,
        positionY,
        self.size.X,
        self.size.Y
    )

    self.gui = new("ScreenGui", {
        Name = "_ixa_" .. tostring(math.random(100000, 999999)),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 9999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    do
        local ok, parent = pcall(resolveParent)
        if not ok or typeof(parent) ~= "Instance" then
            parent = LocalPlayer:WaitForChild("PlayerGui")
        end
        self.gui.Parent = parent
    end

    local root = new("CanvasGroup", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, self.center.X, 0.5, self.center.Y),
        Size = UDim2.fromOffset(self.size.X, self.size.Y),
        BackgroundColor3 = self.theme.window,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        GroupTransparency = 0,
        ZIndex = 10,
        Parent = self.gui,
    })
    corner(root, 14)
    local rootBorder = stroke(root, self.theme.line, 0.15, 1)
    self.root = root
    self.rootBorder = rootBorder
    self.scale = new("UIScale", { Scale = 1, Parent = root })

    local sidebarWidth = 188
    local topHeight = 44
    local statusHeight = 28
    self.sidebarWidth = sidebarWidth
    self.topHeight = topHeight
    self.statusHeight = statusHeight

    local sidebar = new("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, sidebarWidth, 1, -statusHeight),
        BackgroundColor3 = self.theme.sidebar,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = root,
    })
    self.sidebar = sidebar
    new("Frame", {
        Name = "Divide",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = self.theme.lineSoft,
        BorderSizePixel = 0,
        Parent = sidebar,
    })

    local brand = new("Frame", {
        Name = "Brand",
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = sidebar,
    })
    local mark = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 21, 0, 26),
        Size = UDim2.fromOffset(9, 9),
        Rotation = 45,
        BackgroundColor3 = self.theme.accent,
        BorderSizePixel = 0,
        Parent = brand,
    })
    corner(mark, 2)
    local markHole = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(3, 3),
        BackgroundColor3 = self.theme.sidebar,
        BorderSizePixel = 0,
        Parent = mark,
    })
    corner(markHole, UDim.new(1, 0))
    new("TextLabel", {
        Position = UDim2.new(0, 32, 0, 13),
        Size = UDim2.new(0, 84, 0, 21),
        BackgroundTransparency = 1,
        Text = self.title,
        FontFace = Fonts.black,
        TextSize = 15.5,
        TextColor3 = self.theme.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = brand,
    })
    new("TextLabel", {
        Position = UDim2.new(0, 33, 0, 34),
        Size = UDim2.new(0, 110, 0, 13),
        BackgroundTransparency = 1,
        Text = self.subtitle,
        FontFace = Fonts.regular,
        TextSize = 9.5,
        TextColor3 = self.theme.faint,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = brand,
    })
    local versionPill = new("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 18),
        Size = UDim2.fromOffset(40, 15),
        BackgroundColor3 = self.theme.window,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = brand,
    })
    corner(versionPill, 4)
    local versionBorder = stroke(versionPill, self.theme.line, 0.3, 1)
    new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "v" .. self.version,
        FontFace = Fonts.medium,
        TextSize = 8,
        TextColor3 = self.theme.faint,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = versionPill,
    })

    local brandDrag = new("Frame", {
        Name = "DragZone",
        Active = true,
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundTransparency = 1,
        ZIndex = 1,
        Parent = brand,
    })
    self:_track(drag(brandDrag, function()
        self:_beginWindowDrag()
    end, function(delta)
        self:_moveWindowDrag(delta)
    end))

    local footerHeight = 104
    local footer = new("Frame", {
        Name = "Footer",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, footerHeight),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = sidebar,
    })
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = self.theme.lineSoft,
        BorderSizePixel = 0,
        Parent = footer,
    })
    new("TextLabel", {
        Position = UDim2.new(0, 15, 0, 14),
        Size = UDim2.new(0, 80, 0, 14),
        BackgroundTransparency = 1,
        Text = "Toggle menu",
        FontFace = Fonts.regular,
        TextSize = 10,
        TextColor3 = self.theme.faint,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = footer,
    })
    local footerKey, footerKeyLabel = keycap(footer, keyLabel(self.toggleKey), 46, 17)
    footerKey.AnchorPoint = Vector2.new(1, 0)
    footerKey.Position = UDim2.new(1, -12, 0, 12)
    self.footerKeyLabel = footerKeyLabel

    local avatarRing = new("Frame", {
        Position = UDim2.new(0, 15, 0, 42),
        Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = self.theme.raised,
        BorderSizePixel = 0,
        Parent = footer,
    })
    corner(avatarRing, UDim.new(1, 0))
    stroke(avatarRing, self.theme.line, 0.2, 1)
    new("ImageLabel", {
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundTransparency = 1,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150",
        Parent = avatarRing,
    })
    do
        local image = avatarRing:FindFirstChildOfClass("ImageLabel")
        if image then
            corner(image, UDim.new(1, 0))
        end
    end
    local statusDot = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -1, 1, -1),
        Size = UDim2.fromOffset(7, 7),
        BackgroundColor3 = self.theme.good,
        BorderSizePixel = 0,
        Parent = avatarRing,
    })
    corner(statusDot, UDim.new(1, 0))
    stroke(statusDot, self.theme.sidebar, 0, 1.5)
    new("TextLabel", {
        Position = UDim2.new(0, 49, 0, 42),
        Size = UDim2.new(1, -62, 0, 14),
        BackgroundTransparency = 1,
        Text = LocalPlayer.DisplayName,
        FontFace = Fonts.medium,
        TextSize = 11.5,
        TextColor3 = self.theme.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = footer,
    })
    new("TextLabel", {
        Position = UDim2.new(0, 49, 0, 56),
        Size = UDim2.new(1, -62, 0, 14),
        BackgroundTransparency = 1,
        Text = "@" .. LocalPlayer.Name,
        FontFace = Fonts.regular,
        TextSize = 9.5,
        TextColor3 = self.theme.faint,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = footer,
    })

    local nav = new("ScrollingFrame", {
        Name = "Navigation",
        Position = UDim2.new(0, 0, 0, 64),
        Size = UDim2.new(1, 0, 1, -(64 + footerHeight)),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.theme.line,
        ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        ZIndex = 2,
        Parent = sidebar,
    })
    pad(nav, 10, 10, 12, 10)
    list(nav, 2)
    self.nav = nav

    local navCaption = new("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        LayoutOrder = 0,
        Parent = nav,
    })
    new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "MENU",
        FontFace = Fonts.bold,
        TextSize = 8.5,
        TextColor3 = self.theme.faint,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = navCaption,
    })
    self.navOrder = 0

    local topbar = new("Frame", {
        Name = "TopBar",
        Position = UDim2.new(0, sidebarWidth, 0, 0),
        Size = UDim2.new(1, -sidebarWidth, 0, topHeight),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = root,
    })
    self.topbar = topbar
    new("Frame", {
        Position = UDim2.new(0, 0, 0, topHeight - 1),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = self.theme.lineSoft,
        BorderSizePixel = 0,
        Parent = topbar,
    })
    local crumbRoot = new("TextLabel", {
        Position = UDim2.new(0, 20, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 60, 0, 14),
        BackgroundTransparency = 1,
        Text = self.workspace,
        FontFace = Fonts.regular,
        TextSize = 10.5,
        TextColor3 = self.theme.faint,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar,
    })
    local crumbChevron = iconLabel(topbar, "chevron-right", 10, self.theme.faint)
    crumbChevron.Position = UDim2.new(0, 20 + 56, 0.5, -5)
    crumbChevron.Size = UDim2.fromOffset(10, 10)
    local crumbCurrent = new("TextLabel", {
        Position = UDim2.new(0, 92, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 160, 0, 14),
        BackgroundTransparency = 1,
        Text = "",
        FontFace = Fonts.medium,
        TextSize = 10.5,
        TextColor3 = self.theme.dim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = topbar,
    })
    self.crumbCurrent = crumbCurrent

    local searchButton = new("TextButton", {
        Name = "Search",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -102, 0.5, 0),
        Size = UDim2.fromOffset(118, 28),
        BackgroundColor3 = self.theme.field,
        BackgroundTransparency = 0,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = topbar,
    })
    corner(searchButton, 7)
    local searchBorder = stroke(searchButton, self.theme.lineSoft, 0.15, 1)
    local searchIcon = iconLabel(searchButton, "magnifying-glass", 11, self.theme.faint)
    searchIcon.Position = UDim2.new(0, 9, 0.5, -6)
    searchIcon.Size = UDim2.fromOffset(12, 12)
    local searchText = new("TextLabel", {
        Position = UDim2.new(0, 27, 0, 0),
        Size = UDim2.new(0, 44, 1, 0),
        BackgroundTransparency = 1,
        Text = "Search",
        FontFace = Fonts.regular,
        TextSize = 10.5,
        TextColor3 = self.theme.dim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = searchButton,
    })
    local searchKeycap = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -7, 0.5, 0),
        Size = UDim2.fromOffset(36, 15),
        BackgroundColor3 = self.theme.raised,
        BorderSizePixel = 0,
        Parent = searchButton,
    })
    corner(searchKeycap, 4)
    stroke(searchKeycap, self.theme.line, 0.3, 1)
    new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "Ctrl K",
        FontFace = Fonts.medium,
        TextSize = 8,
        TextColor3 = self.theme.faint,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = searchKeycap,
    })
    self.searchButton = searchButton
    self.searchBorder = searchBorder
    self.searchIcon = searchIcon
    self.searchText = searchText
    searchButton.MouseEnter:Connect(function()
        if self.searchOpen then
            return
        end
        tween(searchButton, { BackgroundColor3 = self.theme.raised }, 0.12)
        tween(searchBorder, { Color = self.theme.line }, 0.12)
        tween(searchText, { TextColor3 = self.theme.text }, 0.12)
        tween(searchIcon, { TextColor3 = self.theme.dim }, 0.12)
    end)
    searchButton.MouseLeave:Connect(function()
        if self.searchOpen then
            return
        end
        tween(searchButton, { BackgroundColor3 = self.theme.field }, 0.12)
        tween(searchBorder, { Color = self.theme.lineSoft }, 0.12)
        tween(searchText, { TextColor3 = self.theme.dim }, 0.12)
        tween(searchIcon, { TextColor3 = self.theme.faint }, 0.12)
    end)
    tap(searchButton, function()
        self:_openSearch()
    end)

    local controls = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(78, 26),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = topbar,
    })
    list(controls, 2, Enum.FillDirection.Horizontal)
    local function controlButton(iconName, danger, callback)
        local button = new("TextButton", {
            Size = UDim2.fromOffset(24, 24),
            BackgroundColor3 = self.theme.raised,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            Parent = controls,
        })
        corner(button, 6)
        local icon = iconLabel(button, iconName, 11.5, self.theme.dim)
        icon.Size = UDim2.new(1, 0, 1, 0)
        button.MouseEnter:Connect(function()
            tween(button, {
                BackgroundTransparency = 0,
                BackgroundColor3 = danger and mix(self.theme.bad, self.theme.window, 0.84) or self.theme.raised,
            }, 0.1)
            tween(icon, { TextColor3 = danger and self.theme.bad or self.theme.text }, 0.1)
        end)
        button.MouseLeave:Connect(function()
            tween(button, { BackgroundTransparency = 1 }, 0.12)
            tween(icon, { TextColor3 = self.theme.dim }, 0.12)
        end)
        tap(button, callback)
        return button
    end
    controlButton("minus", false, function()
        self:Hide()
    end)
    controlButton("dual-arrows-to-corners", false, function()
        self:_toggleFullscreen()
    end)
    controlButton("x", true, function()
        self:Hide()
    end)

    local topDrag = new("Frame", {
        Name = "DragZone",
        Active = true,
        Size = UDim2.new(1, -220, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 1,
        Parent = topbar,
    })
    self:_track(drag(topDrag, function()
        self:_beginWindowDrag()
    end, function(delta)
        self:_moveWindowDrag(delta)
    end))

    local pages = new("Frame", {
        Name = "Pages",
        Position = UDim2.new(0, sidebarWidth, 0, topHeight),
        Size = UDim2.new(1, -sidebarWidth, 1, -(topHeight + statusHeight)),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 1,
        Parent = root,
    })
    self.pages = pages

    local status = new("Frame", {
        Name = "Status",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, statusHeight),
        BackgroundColor3 = self.theme.window,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = root,
    })
    self.status = status
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = self.theme.lineSoft,
        BorderSizePixel = 0,
        Parent = status,
    })
    local liveDot = new("Frame", {
        Position = UDim2.new(0, 16, 0.5, -2.5),
        Size = UDim2.fromOffset(5, 5),
        BackgroundColor3 = self.theme.good,
        BorderSizePixel = 0,
        Parent = status,
    })
    corner(liveDot, UDim.new(1, 0))
    new("TextLabel", {
        Position = UDim2.new(0, 26, 0, 0),
        Size = UDim2.new(0, 40, 1, 0),
        BackgroundTransparency = 1,
        Text = "ready",
        FontFace = Fonts.regular,
        TextSize = 9.5,
        TextColor3 = self.theme.dim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = status,
    })
    new("Frame", {
        Position = UDim2.new(0, 65, 0.5, -5),
        Size = UDim2.fromOffset(1, 10),
        BackgroundColor3 = self.theme.line,
        BorderSizePixel = 0,
        Parent = status,
    })
    new("TextLabel", {
        Position = UDim2.new(0, 76, 0, 0),
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        Text = executorName(),
        FontFace = Fonts.regular,
        TextSize = 9.5,
        TextColor3 = self.theme.faint,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = status,
    })
    self.fpsLabel = new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -160, 0.5, 0),
        Size = UDim2.fromOffset(46, 12),
        BackgroundTransparency = 1,
        Text = "-- fps",
        FontFace = Fonts.regular,
        TextSize = 9.5,
        TextColor3 = self.theme.faint,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = status,
    })
    self.pingLabel = new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -108, 0.5, 0),
        Size = UDim2.fromOffset(46, 12),
        BackgroundTransparency = 1,
        Text = "-- ms",
        FontFace = Fonts.regular,
        TextSize = 9.5,
        TextColor3 = self.theme.faint,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = status,
    })
    new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -94, 0.5, 0),
        Size = UDim2.fromOffset(1, 10),
        BackgroundColor3 = self.theme.line,
        BorderSizePixel = 0,
        Parent = status,
    })
    local statusKey, statusKeyLabel = keycap(status, keyLabel(self.toggleKey), 44, 17)
    statusKey.AnchorPoint = Vector2.new(1, 0.5)
    statusKey.Position = UDim2.new(1, -12, 0.5, 0)
    self.statusKeyLabel = statusKeyLabel

    local overlay = new("Frame", {
        Name = "Overlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Active = false,
        ZIndex = 90,
        Parent = root,
    })
    self.overlay = overlay

    if self.resizable then
        local grip = new("Frame", {
            Name = "Resize",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -4, 1, -4),
            Size = UDim2.fromOffset(16, 16),
            BackgroundTransparency = 1,
            Active = true,
            ZIndex = 8,
            Parent = root,
        })
        local dots = {}
        for i = 1, 3 do
            local dot = new("Frame", {
                AnchorPoint = Vector2.new(1, 1),
                Position = UDim2.new(1, -(i - 1) * 4, 1, -(i - 1) * 4),
                Size = UDim2.fromOffset(2, 2),
                BackgroundColor3 = self.theme.faint,
                BackgroundTransparency = 0.35,
                BorderSizePixel = 0,
                Parent = grip,
            })
            corner(dot, UDim.new(1, 0))
            dots[i] = dot
        end
        local startSize, startCenter
        self:_track(drag(grip, function()
            startSize = self.size
            startCenter = self.center
            self:_closePopover()
        end, function(delta)
            local newW, newH = clampWindowSize(startSize.X + delta.X, startSize.Y + delta.Y)
            self.size = Vector2.new(newW, newH)
            self.center = clampCenter(
                startCenter.X + (newW - startSize.X) / 2,
                startCenter.Y + (newH - startSize.Y) / 2,
                newW,
                newH
            )
            self.root.Size = UDim2.fromOffset(newW, newH)
            self.root.Position = UDim2.new(0.5, self.center.X, 0.5, self.center.Y)
        end, function()
            self:_resizeFullscreenGuard()
        end))
        grip.MouseEnter:Connect(function()
            for _, dot in ipairs(dots) do
                tween(dot, { BackgroundColor3 = self.theme.accent, BackgroundTransparency = 0.1 }, 0.1)
            end
        end)
        grip.MouseLeave:Connect(function()
            for _, dot in ipairs(dots) do
                tween(dot, { BackgroundColor3 = self.theme.faint, BackgroundTransparency = 0.35 }, 0.12)
            end
        end)
        self.grip = grip
    end

    if self.launcherEnabled then
        local launcher = new("CanvasGroup", {
            Name = "Launcher",
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 12),
            Size = UDim2.fromOffset(134, 30),
            BackgroundColor3 = self.theme.window,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            GroupTransparency = 1,
            Visible = false,
            ZIndex = 30,
            Parent = self.gui,
        })
        corner(launcher, 8)
        local launcherBorder = stroke(launcher, self.theme.lineSoft, 0.1, 1)
        local launcherMark = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 13, 0.5, 0),
            Size = UDim2.fromOffset(8, 8),
            Rotation = 45,
            BackgroundColor3 = self.theme.accent,
            BorderSizePixel = 0,
            Parent = launcher,
        })
        corner(launcherMark, 2)
        local launcherHole = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(2.5, 2.5),
            BackgroundColor3 = self.theme.window,
            BorderSizePixel = 0,
            Parent = launcherMark,
        })
        corner(launcherHole, UDim.new(1, 0))
        new("TextLabel", {
            Position = UDim2.new(0, 26, 0, 0),
            Size = UDim2.new(0, 44, 1, 0),
            BackgroundTransparency = 1,
            Text = self.title,
            FontFace = Fonts.black,
            TextSize = 11,
            TextColor3 = self.theme.text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = launcher,
        })
        local launcherKey, launcherKeyLabel = keycap(launcher, keyLabel(self.toggleKey), 40, 16)
        launcherKey.AnchorPoint = Vector2.new(1, 0.5)
        launcherKey.Position = UDim2.new(1, -8, 0.5, 0)
        self.launcherKeyLabel = launcherKeyLabel
        local launcherScale = new("UIScale", { Scale = 1, Parent = launcher })
        self.launcher = launcher
        self.launcherScale = launcherScale
        self.launcherBorder = launcherBorder
        self.launcherOffset = Vector2.new(0, 12)
        self.launcherToken = 0
        launcher.MouseEnter:Connect(function()
            tween(launcher, { BackgroundColor3 = self.theme.panel }, 0.12)
            tween(launcherBorder, { Color = self.theme.line }, 0.12)
        end)
        launcher.MouseLeave:Connect(function()
            tween(launcher, { BackgroundColor3 = self.theme.window }, 0.14)
            tween(launcherBorder, { Color = self.theme.lineSoft }, 0.14)
        end)
        local start
        self:_track(drag(launcher, function()
            start = self.launcherOffset
        end, function(delta)
            local v = viewport()
            local maxX = math.max(8, v.X / 2 - 134 / 2 - 8)
            local x = math.clamp(start.X + delta.X, -maxX, maxX)
            local y = math.clamp(start.Y + delta.Y, 8, math.max(8, v.Y - 30 - 8))
            self.launcherOffset = Vector2.new(x, y)
            launcher.Position = UDim2.new(0.5, x, 0, y)
        end, function(moved)
            if not moved then
                self:Show()
            end
        end))
    end

    self:_track(UserInputService.InputBegan:Connect(function(input, processed)
        if processed or self.destroyed then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        if self._keyListening then
            return
        end
        if input.KeyCode == self.toggleKey then
            self:Toggle()
        elseif input.KeyCode == Enum.KeyCode.K and (isKeyDown(Enum.KeyCode.LeftControl) or isKeyDown(Enum.KeyCode.RightControl)) then
            if self.isOpen then
                self:_openSearch()
            end
        end
    end))

    task.spawn(function()
        local frames, elapsed = 0, 0
        while not self.destroyed and self.gui.Parent do
            local dt = RunService.Heartbeat:Wait()
            frames += 1
            elapsed += dt
            if elapsed >= 0.5 then
                local fps = math.floor(frames / elapsed + 0.5)
                self.fpsLabel.Text = tostring(fps) .. " fps"
                frames, elapsed = 0, 0
            end
        end
    end)
    task.spawn(function()
        while not self.destroyed and self.gui.Parent do
            local ok, ping = pcall(function()
                return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            self.pingLabel.Text = ok and (tostring(math.floor(ping + 0.5)) .. " ms") or "-- ms"
            task.wait(1)
        end
    end)

    table.insert(Ixa._windows, self)
    if options.open ~= false then
        self:_setOpen(true, true)
    else
        self.root.Visible = false
        self:_showLauncher()
    end

    return self
end

function Window:_track(connection)
    if connection then
        table.insert(self.connections, connection)
    end
    return connection
end

function Window:_beginWindowDrag()
    self:_closePopover()
    self._dragStart = self.center
end

function Window:_moveWindowDrag(delta)
    if not self._dragStart then
        return
    end
    self.center = clampCenter(
        self._dragStart.X + delta.X,
        self._dragStart.Y + delta.Y,
        self.size.X,
        self.size.Y
    )
    self.root.Position = UDim2.new(0.5, self.center.X, 0.5, self.center.Y)
end

function Window:_toggleFullscreen()
    if self.destroyed or not self.isOpen then
        return
    end
    local v = viewport()
    self:_closePopover()
    if not self._full then
        self._full = {
            size = self.size,
            center = self.center,
        }
        local w, h = clampWindowSize(v.X - 32, v.Y - 32)
        self.size = Vector2.new(w, h)
        self.center = clampCenter(0, 0, w, h)
    else
        local saved = self._full
        self._full = nil
        self.size = saved.size
        self.center = clampCenter(saved.center.X, saved.center.Y, saved.size.X, saved.size.Y)
    end
    tween(self.root, {
        Size = UDim2.fromOffset(self.size.X, self.size.Y),
        Position = UDim2.new(0.5, self.center.X, 0.5, self.center.Y),
    }, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
end

function Window:_resizeFullscreenGuard()
    if self._full then
        self._full.size = self.size
        self._full.center = self.center
    end
end

function Window:_setOpen(open, instant)
    if self.destroyed then
        return
    end
    if self.isOpen == open then
        if open then
            self.root.Visible = true
        end
        return
    end
    self.isOpen = open
    if open then
        self:_closePopover()
        self:_hideLauncher()
        self.root.Visible = true
        self.root.Position = UDim2.new(0.5, self.center.X, 0.5, self.center.Y)
        if instant then
            self.root.GroupTransparency = 0
            self.scale.Scale = 1
        else
            self.root.GroupTransparency = 1
            self.scale.Scale = 0.975
            tween(self.root, { GroupTransparency = 0 }, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            tween(self.scale, { Scale = 1 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        end
    else
        self:_closePopover()
        self:_closeSearch()
        if instant then
            self.root.Visible = false
            self:_showLauncher()
        else
            tween(self.root, { GroupTransparency = 1 }, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            tween(self.scale, { Scale = 0.985 }, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.16, function()
                if not self.destroyed and not self.isOpen then
                    self.root.Visible = false
                    self.scale.Scale = 1
                    self:_showLauncher()
                end
            end)
        end
    end
end

function Window:Show()
    self:_setOpen(true, false)
end

function Window:Hide()
    self:_setOpen(false, false)
end

function Window:Toggle()
    if self.isOpen then
        self:Hide()
    else
        self:Show()
    end
end

function Window:IsOpen()
    return self.isOpen
end

function Window:SetToggleKey(keyCode)
    if typeof(keyCode) == "EnumItem" and keyCode.EnumType == Enum.KeyCode then
        self.toggleKey = keyCode
        local label = keyLabel(keyCode)
        if self.footerKeyLabel then
            self.footerKeyLabel.Text = label
        end
        if self.statusKeyLabel then
            self.statusKeyLabel.Text = label
        end
        if self.launcherKeyLabel then
            self.launcherKeyLabel.Text = label
        end
    end
    return self
end

function Window:_showLauncher()
    if not self.launcherEnabled or not self.launcher or self.destroyed then
        return
    end
    self.launcherToken += 1
    local token = self.launcherToken
    local launcher = self.launcher
    launcher.Visible = true
    launcher.GroupTransparency = 1
    self.launcherScale.Scale = 0.96
    tween(launcher, { GroupTransparency = 0 }, 0.16)
    tween(self.launcherScale, { Scale = 1 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    launcher.Position = UDim2.new(0.5, self.launcherOffset.X, 0, self.launcherOffset.Y)
end

function Window:_hideLauncher()
    if not self.launcherEnabled or not self.launcher or self.destroyed then
        return
    end
    self.launcherToken += 1
    local token = self.launcherToken
    local launcher = self.launcher
    tween(launcher, { GroupTransparency = 1 }, 0.1)
    tween(self.launcherScale, { Scale = 0.97 }, 0.12)
    task.delay(0.12, function()
        if token == self.launcherToken and not self.destroyed then
            launcher.Visible = false
        end
    end)
end

function Window:Destroy()
    if self.destroyed then
        return
    end
    self:_closePopover()
    self:_closeSearch()
    self.destroyed = true
    self.isOpen = false
    self._keyListening = false
    for _, connection in ipairs(self.connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    self.connections = {}
    for i = #Ixa._windows, 1, -1 do
        if Ixa._windows[i] == self then
            table.remove(Ixa._windows, i)
        end
    end
    if self.gui then
        pcall(function()
            self.gui:Destroy()
        end)
    end
    self.gui = nil
end

local notifyColors = {
    info = "accent",
    success = "good",
    warning = "warn",
    error = "bad",
}

function Window:_notificationDock()
    if self._dock and self._dock.Parent then
        return self._dock
    end
    local dock = new("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.new(0, 312, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 200,
        Parent = self.gui,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = dock,
    })
    self._dock = dock
    self._notificationOrder = 0
    return dock
end

function Window:Notify(options)
    if self.destroyed then
        return
    end
    if type(options) == "string" then
        options = { text = options }
    end
    if type(options) ~= "table" then
        return
    end

    local dock = self:_notificationDock()
    local kind = options.type or "info"
    local colorKey = notifyColors[kind]
    local color = colorKey and self.theme[colorKey] or self.theme.accent
    local duration = tonumber(options.duration)
    if duration == nil then
        duration = 3.4
    end
    local title = tostring(options.title or "Notice")
    local body = tostring(options.text or options.body or "")

    self._notificationOrder += 1

    local box = new("CanvasGroup", {
        Name = "Notification",
        Size = UDim2.new(0, 312, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.theme.panel,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        LayoutOrder = self._notificationOrder,
        ClipsDescendants = true,
        ZIndex = 201,
        Parent = dock,
    })
    corner(box, 10)
    stroke(box, self.theme.lineSoft, 0.25, 1)

    local content = new("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = box,
    })
    pad(content, 12, 34, 15, 13)
    list(content, 4)

    local header = new("Frame", {
        Size = UDim2.new(1, 0, 0, 15),
        BackgroundTransparency = 1,
        Parent = content,
    })
    local dot = new("Frame", {
        Position = UDim2.new(0, 0, 0.5, -2.5),
        Size = UDim2.fromOffset(5, 5),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = header,
    })
    corner(dot, UDim.new(1, 0))
    new("TextLabel", {
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -12, 1, 0),
        BackgroundTransparency = 1,
        Text = title,
        FontFace = Fonts.medium,
        TextSize = 11.5,
        TextColor3 = self.theme.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = header,
    })

    if body ~= "" then
        new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = body,
            FontFace = Fonts.regular,
            TextSize = 10.5,
            TextColor3 = self.theme.dim,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            LineHeight = 1.15,
            Parent = content,
        })
    end

    local close = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -7, 0, 6),
        Size = UDim2.fromOffset(18, 18),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 202,
        Parent = box,
    })
    local closeIcon = iconLabel(close, "x", 10, self.theme.faint)
    closeIcon.Size = UDim2.new(1, 0, 1, 0)
    close.MouseEnter:Connect(function()
        tween(closeIcon, { TextColor3 = self.theme.text }, 0.1)
    end)
    close.MouseLeave:Connect(function()
        tween(closeIcon, { TextColor3 = self.theme.faint }, 0.12)
    end)

    local progress
    local progressTween
    if duration and duration > 0 then
        progress = new("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = color,
            BackgroundTransparency = 0.45,
            BorderSizePixel = 0,
            ZIndex = 202,
            Parent = box,
        })
        progressTween = TweenService:Create(
            progress,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            { Size = UDim2.new(0, 0, 0, 2) }
        )
    end

    local scale = new("UIScale", { Scale = 0.98, Parent = box })
    local dismissed = false
    local entry = { box = box }

    local function dismiss()
        if dismissed or not box.Parent then
            return
        end
        dismissed = true
        if progressTween then
            pcall(function()
                progressTween:Cancel()
            end)
        end
        for index = #self.notifications, 1, -1 do
            if self.notifications[index] == entry then
                table.remove(self.notifications, index)
            end
        end
        tween(box, { GroupTransparency = 1 }, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(scale, { Scale = 0.98 }, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.18, function()
            if box.Parent then
                box:Destroy()
            end
        end)
    end

    entry.dismiss = dismiss
    entry.box = box

    if #self.notifications >= 4 and self.notifications[1] then
        self.notifications[1].dismiss()
    end
    table.insert(self.notifications, entry)

    if progressTween then
        progressTween.Completed:Connect(function(state)
            if state == Enum.PlaybackState.Completed then
                dismiss()
            end
        end)
        box.MouseEnter:Connect(function()
            pcall(function()
                progressTween:Pause()
            end)
        end)
        box.MouseLeave:Connect(function()
            pcall(function()
                progressTween:Play()
            end)
        end)
        progressTween:Play()
    end

    tap(close, dismiss)

    tween(box, { GroupTransparency = 0 }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    tween(scale, { Scale = 1 }, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    return {
        Dismiss = dismiss,
        Box = box,
    }
end


local function lowerText(text)
    return string.lower(tostring(text or ""))
end

function Window:Tab(options)
    options = options or {}
    if self.destroyed or self.gui == nil then
        return nil
    end

    local index = #self.tabs + 1
    local tab = setmetatable({}, Tab)
    tab.window = self
    tab.index = index
    tab.name = tostring(options.name or ("Page " .. tostring(index)))
    tab.icon = tostring(options.icon or "dot")
    tab.description = options.description ~= nil and tostring(options.description) or nil
    tab.onSelect = options.onSelect
    tab.sections = {}
    tab.count = 0
    tab.sectionOrder = 0

    local viewport = new("ScrollingFrame", {
        Name = "Page_" .. tostring(index),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.theme.line,
        ScrollBarImageTransparency = 0.2,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        Visible = false,
        ZIndex = 1,
        Parent = self.pages,
    })
    pad(viewport, 18, 12, 24, 20)
    local viewportLayout = list(viewport, 18)
    tab.viewport = viewport
    tab.viewportLayout = viewportLayout

    local headHeight = tab.description and tab.description ~= "" and 58 or 38
    local head = new("Frame", {
        Name = "PageHead",
        Size = UDim2.new(1, 0, 0, headHeight),
        BackgroundTransparency = 1,
        LayoutOrder = 0,
        Parent = viewport,
    })
    new("TextLabel", {
        Size = UDim2.new(1, -120, 0, 24),
        BackgroundTransparency = 1,
        Text = tab.name,
        FontFace = Fonts.bold,
        TextSize = 18,
        TextColor3 = self.theme.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = head,
    })
    local countLabel = new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 3),
        Size = UDim2.new(0, 110, 0, 16),
        BackgroundTransparency = 1,
        Text = "0 controls",
        FontFace = Fonts.regular,
        TextSize = 9.5,
        TextColor3 = self.theme.faint,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = head,
    })
    tab.countLabel = countLabel
    if tab.description and tab.description ~= "" then
        new("TextLabel", {
            Position = UDim2.new(0, 0, 0, 29),
            Size = UDim2.new(1, -80, 0, 17),
            BackgroundTransparency = 1,
            Text = tab.description,
            FontFace = Fonts.regular,
            TextSize = 10.5,
            TextColor3 = self.theme.dim,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = head,
        })
    end

    self.navOrder += 1
    local navButton = new("TextButton", {
        Name = "Tab_" .. tostring(index),
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = self.theme.raised,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        LayoutOrder = self.navOrder,
        ZIndex = 2,
        Parent = self.nav,
    })
    corner(navButton, 7)
    local marker = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(2, 14),
        BackgroundColor3 = self.theme.accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = navButton,
    })
    corner(marker, UDim.new(1, 0))
    local navIcon = iconLabel(navButton, tab.icon, 13, self.theme.faint)
    navIcon.AnchorPoint = Vector2.new(0, 0.5)
    navIcon.Position = UDim2.new(0, 11, 0.5, 0)
    navIcon.Size = UDim2.fromOffset(14, 14)
    local navLabel = new("TextLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 33, 0.5, 0),
        Size = UDim2.new(1, -44, 1, 0),
        BackgroundTransparency = 1,
        Text = tab.name,
        FontFace = Fonts.medium,
        TextSize = 11.5,
        TextColor3 = self.theme.dim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = navButton,
    })
    tab.navButton = navButton
    tab.navIcon = navIcon
    tab.navLabel = navLabel
    tab.marker = marker

    navButton.MouseEnter:Connect(function()
        if self.activeIndex == index then
            return
        end
        tween(navButton, { BackgroundTransparency = 0.55 }, 0.1)
        tween(navLabel, { TextColor3 = self.theme.text }, 0.1)
        tween(navIcon, { TextColor3 = self.theme.dim }, 0.1)
    end)
    navButton.MouseLeave:Connect(function()
        if self.activeIndex == index then
            return
        end
        tween(navButton, { BackgroundTransparency = 1 }, 0.12)
        tween(navLabel, { TextColor3 = self.theme.dim }, 0.12)
        tween(navIcon, { TextColor3 = self.theme.faint }, 0.12)
    end)
    tap(navButton, function()
        self:SelectTab(index)
    end)

    table.insert(self.tabs, tab)
    if self.activeIndex == nil then
        self:SelectTab(index)
    end
    return tab
end

function Tab:_paintCount()
    if self.countLabel then
        self.countLabel.Text = tostring(self.count) .. (self.count == 1 and " control" or " controls")
    end
end

function Tab:_bump()
    self.count += 1
    self:_paintCount()
end

function Tab:_dropRow(row, indexed)
    if self.window.destroyed then
        return
    end
    if indexed then
        for i = #self.window.index, 1, -1 do
            if self.window.index[i].row == row then
                table.remove(self.window.index, i)
            end
        end
    end
    self.count = math.max(0, self.count - 1)
    self:_paintCount()
end

function Tab:_indexRow(row, text, kind)
    table.insert(self.window.index, {
        tab = self,
        row = row,
        text = tostring(text),
        lower = lowerText(text),
        kind = kind or "Control",
    })
end

function Tab:_setActive(active)
    local theme = self.window.theme
    tween(self.navButton, {
        BackgroundTransparency = active and 0 or 1,
        BackgroundColor3 = theme.raised,
    }, 0.14)
    tween(self.navLabel, { TextColor3 = active and theme.text or theme.dim }, 0.14)
    tween(self.navIcon, { TextColor3 = active and theme.accent or theme.faint }, 0.14)
    tween(self.marker, { BackgroundTransparency = active and 0 or 1 }, 0.14)
end

function Tab:Select()
    self.window:SelectTab(self.index)
end

function Tab:Section(options)
    options = options or {}
    local section = setmetatable({}, Section)
    section.tab = self
    section.window = self.window
    section.name = tostring(options.name or "Section")
    section.note = options.note ~= nil and tostring(options.note) or nil
    section.order = self.sectionOrder + 1
    section.rowOrder = 0
    section.rows = {}
    self.sectionOrder = section.order
    table.insert(self.sections, section)

    local root = new("Frame", {
        Name = "Section",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = section.order,
        Parent = self.viewport,
    })
    list(root, 7)

    local head = new("Frame", {
        Name = "Head",
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Parent = root,
    })
    local dash = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(8, 2),
        BackgroundColor3 = self.window.theme.accent,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Parent = head,
    })
    corner(dash, UDim.new(1, 0))
    new("TextLabel", {
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -140, 1, 0),
        BackgroundTransparency = 1,
        Text = string.upper(section.name),
        FontFace = Fonts.bold,
        TextSize = 8.5,
        TextColor3 = self.window.theme.faint,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = head,
    })
    if section.note and section.note ~= "" then
        new("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 150, 1, 0),
            BackgroundTransparency = 1,
            Text = section.note,
            FontFace = Fonts.regular,
            TextSize = 9,
            TextColor3 = self.window.theme.faint,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = head,
        })
    end

    local card = new("Frame", {
        Name = "Card",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.window.theme.panel,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = root,
    })
    corner(card, 10)
    stroke(card, self.window.theme.lineSoft, 0.35, 1)
    list(card, 0)

    section.root = root
    section.card = card
    section.head = head
    section.dash = dash
    return section
end


function Section:_row(kind, options, controlWidth, counted)
    options = options or {}
    local window = self.window
    local theme = window.theme
    local titleText = tostring(options.text or options.title or "")
    local description = options.description ~= nil and tostring(options.description) or nil
    local hasDescription = description ~= nil and description ~= ""

    local height = hasDescription and 56 or 44
    self.rowOrder += 1
    local order = self.rowOrder

    local row = new("Frame", {
        Name = "Row",
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = theme.panelHover,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Parent = self.card,
    })

    if order > 1 then
        new("Frame", {
            Position = UDim2.new(0, 14, 0, 0),
            Size = UDim2.new(1, -28, 0, 1),
            BackgroundColor3 = theme.lineSoft,
            BackgroundTransparency = 0.25,
            BorderSizePixel = 0,
            Parent = row,
        })
    end

    local titleWidth = controlWidth and controlWidth > 0 and UDim2.new(1, -(controlWidth + 40), 0, hasDescription and 15 or height)
        or UDim2.new(1, -32, 0, hasDescription and 15 or height)
    local title = new("TextLabel", {
        Position = UDim2.new(0, 14, 0, hasDescription and 10 or 0),
        Size = titleWidth,
        BackgroundTransparency = 1,
        Text = titleText,
        FontFace = Fonts.medium,
        TextSize = 12,
        TextColor3 = theme.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = hasDescription and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })

    local descriptionLabel
    if hasDescription then
        descriptionLabel = new("TextLabel", {
            Position = UDim2.new(0, 14, 0, 26),
            Size = UDim2.new(1, controlWidth and controlWidth > 0 and -(controlWidth + 40) or -32, 0, 15),
            BackgroundTransparency = 1,
            Text = description,
            FontFace = Fonts.regular,
            TextSize = 10,
            TextColor3 = theme.faint,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })
    end

    local control
    if controlWidth and controlWidth > 0 then
        control = new("Frame", {
            Name = "Control",
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(controlWidth, 28),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = row,
        })
    end

    row.MouseEnter:Connect(function()
        tween(row, { BackgroundTransparency = 0 }, 0.12)
    end)
    row.MouseLeave:Connect(function()
        tween(row, { BackgroundTransparency = 1 }, 0.14)
    end)

    self.rows[order] = {
        row = row,
        kind = kind,
        title = titleText,
        counted = counted ~= false,
    }

    if counted ~= false then
        local indexed = titleText ~= ""
        if indexed then
            self.tab:_indexRow(row, titleText, kind)
        end
        self.tab:_bump()
        row.Destroying:Connect(function()
            self.tab:_dropRow(row, indexed)
        end)
    end

    return row, control, title, descriptionLabel
end

function Window:SelectTab(target)
    if self.destroyed then
        return
    end
    local index = target
    if type(target) == "string" then
        for _, tab in ipairs(self.tabs) do
            if tab.name == target then
                index = tab.index
                break
            end
        end
    end
    local tab = self.tabs[index]
    if not tab or index == self.activeIndex then
        return
    end

    self:_closePopover()
    self:_closeSearch()
    self._hoveredIndex = nil

    local previous = self.activeIndex and self.tabs[self.activeIndex]
    if previous then
        previous.viewport.Visible = false
        previous:_setActive(false)
    end
    self.activeIndex = index
    tab.viewport.Visible = true
    tab:_setActive(true)

    if self.crumbCurrent then
        tween(self.crumbCurrent, { TextTransparency = 0.35 }, 0.07)
        task.delay(0.07, function()
            if self.destroyed or self.activeIndex ~= index then
                return
            end
            self.crumbCurrent.Text = tab.name
            tween(self.crumbCurrent, { TextTransparency = 0 }, 0.12)
        end)
    end

    if tab.onSelect then
        safeCallback(tab.onSelect, tab)
    end
end


function Window:_registerFlag(flag, api)
    if type(flag) ~= "string" or flag == "" then
        return
    end
    if self.flags[flag] then
        warn("[ixa] duplicate flag: " .. flag)
        return
    end
    self.flags[flag] = api
end

function Window:_newFlag(kind, tab, text)
    local base = string.format(
        "%s/%s/%s",
        tostring(kind),
        tab and tostring(tab.name) or "tab",
        text ~= "" and tostring(text) or "control"
    )
    local flag = base
    local suffix = 2
    while self.flags[flag] do
        flag = base .. "#" .. tostring(suffix)
        suffix += 1
    end
    return flag
end


function Window:_closePopover()
    if not self.popover then
        return
    end
    local pop = self.popover
    self.popover = nil
    pop:Close(false)
end

function Window:_makePopover(width, height)
    self:_closeSearch()
    self:_closePopover()
    self.overlay.Visible = true
    self.overlay.Active = true

    local catcher = new("TextButton", {
        Name = "Dismiss",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 90,
        Parent = self.overlay,
    })

    local canvas = new("CanvasGroup", {
        Name = "Popover",
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = self.theme.panel,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 91,
        Parent = self.overlay,
    })
    corner(canvas, 9)
    stroke(canvas, self.theme.line, 0.15, 1)
    local scale = new("UIScale", { Scale = 0.985, Parent = canvas })

    local pop = {
        window = self,
        canvas = canvas,
        catcher = catcher,
        scale = scale,
        closed = false,
        onClose = nil,
        connection = nil,
        escapeConnection = nil,
    }

    function pop:PositionAt(anchor, heightOverride)
        local winPos = self.window.root.AbsolutePosition
        local width = width
        local h = heightOverride or height
        local anchorPos = anchor.AbsolutePosition
        local anchorSize = anchor.AbsoluteSize
        local x = anchorPos.X - winPos.X + anchorSize.X - width
        local y = anchorPos.Y - winPos.Y + anchorSize.Y + 6
        if y + h > self.window.size.Y - 8 then
            y = anchorPos.Y - winPos.Y - h - 6
        end
        x = math.clamp(x, 8, math.max(8, self.window.size.X - width - 8))
        y = math.clamp(y, 8, math.max(8, self.window.size.Y - h - 8))
        self.canvas.Position = UDim2.fromOffset(x, y)
    end

    function pop:Close(instant)
        if self.closed then
            return
        end
        self.closed = true
        if self.connection then
            pcall(function()
                self.connection:Disconnect()
            end)
            self.connection = nil
        end
        if self.escapeConnection then
            pcall(function()
                self.escapeConnection:Disconnect()
            end)
            self.escapeConnection = nil
        end
        if self.catcher and self.catcher.Parent then
            self.catcher:Destroy()
        end
        if self.window.popover == self then
            self.window.popover = nil
        end
        if self.onClose then
            local ok, err = pcall(self.onClose)
            if not ok then
                warn("[ixa] popover close failed: " .. tostring(err))
            end
        end
        if instant or not self.canvas.Parent then
            if self.canvas.Parent then
                self.canvas:Destroy()
            end
            self.window.overlay.Visible = false
            self.window.overlay.Active = false
            return
        end
        tween(self.canvas, { GroupTransparency = 1 }, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(self.scale, { Scale = 0.985 }, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.13, function()
            if self.canvas.Parent then
                self.canvas:Destroy()
            end
            if not self.window.popover then
                self.window.overlay.Visible = false
                self.window.overlay.Active = false
            end
        end)
    end

    catcher.MouseButton1Click:Connect(function()
        pop:Close(false)
    end)

    self.popover = pop
    pop.escapeConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
            pop:Close(false)
        end
    end)
    tween(canvas, { GroupTransparency = 0 }, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    tween(scale, { Scale = 1 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    return pop
end

function Section:Toggle(options)
    options = options or {}
    local window = self.window
    local theme = window.theme
    local state = options.default == true
    local row, control = self:_row("Toggle", options, 58)

    local hit = new("TextButton", {
        Name = "ToggleHit",
        Size = UDim2.fromOffset(58, 34),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = control,
    })
    local track = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(36, 20),
        BackgroundColor3 = theme.raised,
        BorderSizePixel = 0,
        Parent = hit,
    })
    corner(track, UDim.new(1, 0))
    local trackBorder = stroke(track, theme.line, 0.15, 1)
    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = theme.dim,
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(knob, UDim.new(1, 0))

    local listeners = emitter()
    local api = { Flag = options.flag, Instance = hit }

    local function paint(value, instant)
        if instant then
            cancelTweens(track)
            cancelTweens(knob)
            cancelTweens(trackBorder)
            track.BackgroundColor3 = value and theme.accent or theme.raised
            trackBorder.Color = value and theme.accent or theme.line
            trackBorder.Transparency = value and 0.55 or 0.15
            knob.BackgroundColor3 = value and theme.window or theme.dim
            knob.Position = value and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        else
            tween(track, { BackgroundColor3 = value and theme.accent or theme.raised }, 0.14)
            tween(trackBorder, {
                Color = value and theme.accent or theme.line,
                Transparency = value and 0.55 or 0.15,
            }, 0.14)
            tween(knob, { BackgroundColor3 = value and theme.window or theme.dim }, 0.14)
            tween(knob, { Position = value and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        end
    end

    local function fire(value)
        listeners.Fire(value)
        safeCallback(options.callback, value)
    end

    function api:Get()
        return state
    end

    function api:Set(value, silent)
        value = value == true
        local changed = value ~= state
        state = value
        paint(state, silent)
        if changed and not silent then
            fire(state)
        end
        return self
    end

    function api:On(fn)
        return listeners.Connect(fn)
    end

    function api:Destroy()
        row:Destroy()
    end

    paint(state, true)
    tap(hit, function()
        api:Set(not state)
    end)

    local flag = options.flag or window:_newFlag("toggle", self.tab, options.text or options.title or "toggle")
    api.Flag = flag
    window:_registerFlag(flag, {
        Get = function()
            return state
        end,
        Set = function(value)
            api:Set(value)
        end,
        Kind = "Toggle",
    })

    return api
end


function Section:Slider(options)
    options = options or {}
    local window = self.window
    local theme = window.theme
    local minimum = tonumber(options.min or options.minimum) or 0
    local maximum = tonumber(options.max or options.maximum) or 100
    if maximum <= minimum then
        maximum = minimum + 1
    end
    local decimals = math.max(0, tonumber(options.decimals) or 0)
    local step = tonumber(options.step) or (10 ^ -decimals)
    local value = math.clamp(roundTo(tonumber(options.default) or minimum, step, decimals), minimum, maximum)
    local suffix = options.suffix or ""
    local listeners = emitter()

    local row, control = self:_row("Slider", options, 196)
    local hit = new("TextButton", {
        Name = "SliderHit",
        Position = UDim2.new(0, 0, 0.5, -9),
        Size = UDim2.new(1, -50, 0, 18),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = control,
    })
    local track = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = theme.line,
        BorderSizePixel = 0,
        Parent = hit,
    })
    corner(track, UDim.new(1, 0))
    local fill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = theme.accent,
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(fill, UDim.new(1, 0))
    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(7, 14),
        BackgroundColor3 = theme.text,
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(knob, 3)
    stroke(knob, theme.window, 0.35, 1)

    local valueLabel = new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(42, 18),
        BackgroundTransparency = 1,
        Text = "",
        FontFace = Fonts.medium,
        TextSize = 11.5,
        TextColor3 = theme.text,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = control,
    })

    local function paint()
        local alpha = (value - minimum) / (maximum - minimum)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = formatNumber(value, decimals) .. suffix
    end

    local function fire()
        listeners.Fire(value)
        safeCallback(options.callback, value)
    end

    local api = { Flag = options.flag, Instance = hit }

    function api:Get()
        return value
    end

    function api:Set(nextValue, silent)
        nextValue = tonumber(nextValue)
        if nextValue == nil then
            return self
        end
        nextValue = math.clamp(roundTo(nextValue, step, decimals), minimum, maximum)
        local changed = nextValue ~= value
        value = nextValue
        paint()
        if changed and not silent then
            fire()
        end
        return self
    end

    function api:On(fn)
        return listeners.Connect(fn)
    end

    function api:Destroy()
        row:Destroy()
    end

    local function fromX(x)
        local alpha = math.clamp((x - hit.AbsolutePosition.X) / math.max(1, hit.AbsoluteSize.X), 0, 1)
        api:Set(minimum + alpha * (maximum - minimum))
    end

    hit.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        fromX(input.Position.X)
        tween(knob, { Size = UDim2.fromOffset(8, 16) }, 0.1)
        local moveConnection
        local endConnection
        moveConnection = UserInputService.InputChanged:Connect(function(changed)
            if changed.UserInputType == Enum.UserInputType.MouseMovement or changed.UserInputType == Enum.UserInputType.Touch then
                fromX(changed.Position.X)
            end
        end)
        endConnection = UserInputService.InputEnded:Connect(function(ended)
            if ended.UserInputType ~= input.UserInputType then
                return
            end
            moveConnection:Disconnect()
            endConnection:Disconnect()
            tween(knob, { Size = UDim2.fromOffset(7, 14) }, 0.12)
        end)
    end)

    paint()

    local flag = options.flag or window:_newFlag("slider", self.tab, options.text or options.title or "slider")
    api.Flag = flag
    window:_registerFlag(flag, {
        Get = function()
            return value
        end,
        Set = function(nextValue)
            api:Set(nextValue)
        end,
        Kind = "Slider",
    })

    return api
end

function Section:Dropdown(options)
    options = options or {}
    local window = self.window
    local theme = window.theme
    local values = {}
    for _, item in ipairs(options.values or {}) do
        table.insert(values, tostring(item))
    end
    if #values == 0 then
        values = { "None" }
    end
    local value = options.default
    local found = false
    for _, item in ipairs(values) do
        if item == value then
            found = true
            break
        end
    end
    if not found then
        value = values[1]
    end

    local row, control = self:_row("Dropdown", options, 184)
    local pill = new("TextButton", {
        Name = "Dropdown",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = theme.field,
        BackgroundTransparency = 0,
        Text = value,
        TextColor3 = theme.text,
        FontFace = Fonts.medium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = control,
    })
    pad(pill, 0, 27, 0, 10)
    corner(pill, 7)
    local pillBorder = stroke(pill, theme.lineSoft, 0.1, 1)
    local chevron = iconLabel(pill, "chevron-down", 11, theme.dim)
    chevron.AnchorPoint = Vector2.new(1, 0.5)
    chevron.Position = UDim2.new(1, -8, 0.5, 0)
    chevron.Size = UDim2.fromOffset(10, 10)

    local listeners = emitter()
    local api = { Flag = options.flag, Instance = pill }
    local currentPopover = nil

    local function paint()
        pill.Text = value
        if currentPopover and not currentPopover.closed then
            currentPopover:Close(true)
            currentPopover = nil
        end
    end

    local function fire()
        listeners.Fire(value)
        safeCallback(options.callback, value)
    end

    function api:Get()
        return value
    end

    function api:Set(nextValue, silent)
        nextValue = tostring(nextValue)
        local valid = false
        for _, item in ipairs(values) do
            if item == nextValue then
                valid = true
                break
            end
        end
        if not valid then
            return self
        end
        local changed = nextValue ~= value
        value = nextValue
        pill.Text = value
        if currentPopover and not currentPopover.closed then
            currentPopover:Close(true)
            currentPopover = nil
        end
        if changed and not silent then
            fire()
        end
        return self
    end

    function api:SetValues(nextValues, keepValue)
        local nextList = {}
        for _, item in ipairs(nextValues or {}) do
            table.insert(nextList, tostring(item))
        end
        if #nextList == 0 then
            return self
        end
        if currentPopover and not currentPopover.closed then
            currentPopover:Close(true)
            currentPopover = nil
        end
        values = nextList
        if not keepValue or not table.find(values, value) then
            value = values[1]
            pill.Text = value
        end
        return self
    end

    function api:On(fn)
        return listeners.Connect(fn)
    end

    function api:Destroy()
        if currentPopover then
            currentPopover:Close(true)
        end
        row:Destroy()
    end

    local function open()
        if currentPopover and not currentPopover.closed then
            currentPopover:Close(true)
            currentPopover = nil
            chevron.Rotation = 0
            pillBorder.Color = theme.lineSoft
            return
        end

        local itemHeight = 28
        local menuHeight = math.min(#values * itemHeight + 8, 216)
        local pop = window:_makePopover(math.max(184, pill.AbsoluteSize.X), menuHeight)
        currentPopover = pop
        pop:PositionAt(pill, menuHeight)
        pop.onClose = function()
            if currentPopover == pop then
                currentPopover = nil
            end
            tween(chevron, { Rotation = 0 }, 0.14)
            tween(pillBorder, { Color = theme.lineSoft }, 0.14)
        end
        tween(chevron, { Rotation = 180 }, 0.16)
        tween(pillBorder, { Color = theme.line }, 0.14)

        if pop.connection == nil and window.tabs[window.activeIndex] then
            pop.connection = window.tabs[window.activeIndex].viewport:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                pop:Close(false)
            end)
        end

        local scroll = new("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = theme.line,
            ScrollBarImageTransparency = 0.3,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ElasticBehavior = Enum.ElasticBehavior.Never,
            Parent = pop.canvas,
        })
        pad(scroll, 4, 4, 4, 4)
        list(scroll, 1)

        local items = {}
        for index, item in ipairs(values) do
            local selected = item == value
            local button = new("TextButton", {
                Size = UDim2.new(1, 0, 0, itemHeight),
                BackgroundColor3 = theme.raised,
                BackgroundTransparency = 1,
                Text = item,
                TextColor3 = selected and theme.accent or theme.dim,
                FontFace = Fonts.medium,
                TextSize = 10.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                AutoButtonColor = false,
                BorderSizePixel = 0,
                LayoutOrder = index,
                Parent = scroll,
            })
            pad(button, 0, 26, 0, 9)
            corner(button, 6)
            if selected then
                local check = iconLabel(button, "check", 10, theme.accent)
                check.AnchorPoint = Vector2.new(1, 0.5)
                check.Position = UDim2.new(1, -8, 0.5, 0)
                check.Size = UDim2.fromOffset(10, 10)
            end
            items[item] = button
            button.MouseEnter:Connect(function()
                tween(button, { BackgroundTransparency = 0 }, 0.1)
                if item ~= value then
                    tween(button, { TextColor3 = theme.text }, 0.1)
                end
            end)
            button.MouseLeave:Connect(function()
                tween(button, { BackgroundTransparency = 1 }, 0.12)
                if item ~= value then
                    tween(button, { TextColor3 = theme.dim }, 0.12)
                end
            end)
            tap(button, function()
                api:Set(item)
                pop:Close(false)
            end)
        end
    end

    pill.MouseEnter:Connect(function()
        if not (currentPopover and not currentPopover.closed) then
            tween(pill, { BackgroundColor3 = theme.raised }, 0.12)
            tween(pillBorder, { Color = theme.line }, 0.12)
        end
    end)
    pill.MouseLeave:Connect(function()
        if not (currentPopover and not currentPopover.closed) then
            tween(pill, { BackgroundColor3 = theme.field }, 0.14)
            tween(pillBorder, { Color = theme.lineSoft }, 0.14)
        end
    end)
    tap(pill, open)

    paint()

    local flag = options.flag or window:_newFlag("dropdown", self.tab, options.text or options.title or "dropdown")
    api.Flag = flag
    window:_registerFlag(flag, {
        Get = function()
            return value
        end,
        Set = function(nextValue)
            api:Set(nextValue)
        end,
        Kind = "Dropdown",
    })

    return api
end


function Section:Input(options)
    options = options or {}
    local window = self.window
    local theme = window.theme
    local state = tostring(options.default or options.value or "")
    local listeners = emitter()

    local row, control = self:_row("Input", options, 184)
    local input = new("TextBox", {
        Name = "Input",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = theme.field,
        BackgroundTransparency = 0,
        Text = state,
        PlaceholderText = tostring(options.placeholder or ""),
        PlaceholderColor3 = theme.faint,
        TextColor3 = theme.text,
        FontFace = Fonts.medium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
        Parent = control,
    })
    pad(input, 0, 10, 0, 10)
    corner(input, 7)
    local inputBorder = stroke(input, theme.lineSoft, 0.1, 1)

    local function fire()
        listeners.Fire(state)
        safeCallback(options.callback, state)
    end

    local api = { Flag = options.flag, Instance = input }

    function api:Get()
        return state
    end

    function api:Set(value, silent)
        value = tostring(value == nil and "" or value)
        local changed = value ~= state
        state = value
        input.Text = value
        if changed and not silent then
            fire()
        end
        return self
    end

    function api:On(fn)
        return listeners.Connect(fn)
    end

    function api:Destroy()
        row:Destroy()
    end

    input.Focused:Connect(function()
        tween(input, { BackgroundColor3 = theme.raised }, 0.12)
        tween(inputBorder, { Color = theme.accent, Transparency = 0.5 }, 0.12)
    end)
    input.FocusLost:Connect(function()
        tween(input, { BackgroundColor3 = theme.field }, 0.14)
        tween(inputBorder, { Color = theme.lineSoft, Transparency = 0.1 }, 0.14)
        if input.Text ~= state then
            state = input.Text
            fire()
        end
    end)

    local flag = options.flag or window:_newFlag("input", self.tab, options.text or options.title or "input")
    api.Flag = flag
    window:_registerFlag(flag, {
        Get = function()
            return state
        end,
        Set = function(value)
            api:Set(value)
        end,
        Kind = "Input",
    })

    return api
end


function Section:Button(options)
    if type(options) == "string" then
        options = { text = options }
    end
    options = options or {}
    local window = self.window
    local theme = window.theme
    local variant = options.variant or "secondary"
    local width = math.clamp(tonumber(options.width) or 94, 60, 196)

    local rowOptions = {}
    for key, value in pairs(options) do
        rowOptions[key] = value
    end
    rowOptions.text = options.label ~= nil and tostring(options.label)
        or (options.title ~= nil and tostring(options.title) or nil)
    rowOptions.title = nil

    local row, control = self:_row("Button", rowOptions, width, true)
    control.Size = UDim2.fromOffset(width, 28)

    local base = {
        secondary = {
            background = theme.field,
            border = theme.lineSoft,
            borderTransparency = 0.1,
            text = theme.text,
            hoverBackground = theme.raised,
            hoverBorder = theme.line,
        },
        primary = {
            background = theme.accent,
            border = theme.accent,
            borderTransparency = 1,
            text = theme.window,
            hoverBackground = theme.accentDeep,
            hoverBorder = theme.accent,
        },
        danger = {
            background = theme.field,
            border = theme.bad,
            borderTransparency = 0.65,
            text = theme.bad,
            hoverBackground = mix(theme.bad, theme.panel, 0.84),
            hoverBorder = theme.bad,
        },
        ghost = {
            background = theme.panel,
            border = theme.lineSoft,
            borderTransparency = 0.5,
            text = theme.dim,
            hoverBackground = theme.raised,
            hoverBorder = theme.line,
        },
    }
    local colors = base[variant] or base.secondary

    local buttonText = tostring(options.text or options.title or "Button")
    local button = new("TextButton", {
        Name = "Button",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = colors.background,
        BackgroundTransparency = 0,
        Text = buttonText,
        TextColor3 = colors.text,
        FontFace = Fonts.medium,
        TextSize = 10.5,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Parent = control,
    })
    pad(button, 0, 10, 0, 10)
    corner(button, 7)
    local buttonBorder = stroke(button, colors.border, colors.borderTransparency, 1)
    local buttonScale = new("UIScale", { Scale = 1, Parent = button })
    local armed = false
    local armToken = 0

    local function defaultText()
        return buttonText
    end

    local function disarm()
        if not armed then
            return
        end
        armed = false
        armToken += 1
        button.Text = defaultText()
        button.TextColor3 = colors.text
        buttonBorder.Color = colors.border
        buttonBorder.Transparency = colors.borderTransparency
    end

    local function run()
        if options.confirm and not armed then
            armed = true
            armToken += 1
            local token = armToken
            button.Text = tostring(options.confirmText or "Confirm?")
            button.TextColor3 = theme.warn
            buttonBorder.Color = theme.warn
            buttonBorder.Transparency = 0.35
            task.delay(2.2, function()
                if token == armToken then
                    disarm()
                end
            end)
            return
        end
        disarm()
        safeCallback(options.callback)
    end

    button.MouseEnter:Connect(function()
        if armed then
            return
        end
        tween(button, { BackgroundColor3 = colors.hoverBackground }, 0.12)
        tween(buttonBorder, { Color = colors.hoverBorder, Transparency = 0.15 }, 0.12)
    end)
    button.MouseLeave:Connect(function()
        if armed then
            return
        end
        tween(button, { BackgroundColor3 = colors.background }, 0.14)
        tween(buttonBorder, { Color = colors.border, Transparency = colors.borderTransparency }, 0.14)
    end)
    button.MouseButton1Down:Connect(function()
        tween(buttonScale, { Scale = 0.975 }, 0.08)
    end)
    button.MouseButton1Up:Connect(function()
        tween(buttonScale, { Scale = 1 }, 0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
    tap(button, run)

    local api = { Flag = options.flag, Instance = button }
    function api:Destroy()
        row:Destroy()
    end

    return api
end


function Section:Keybind(options)
    options = options or {}
    local window = self.window
    local theme = window.theme
    local state = options.default
    if typeof(state) ~= "EnumItem" or state.EnumType ~= Enum.KeyCode then
        state = nil
    end
    local allowNone = options.allowNone ~= false
    local listeners = emitter()
    local listening = false
    local keyConnection = nil
    local stopConnection = nil
    local lastStop = 0
    local paintedText = ""

    local row, control = self:_row("Keybind", options, 104)
    local button = new("TextButton", {
        Name = "Keybind",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = theme.field,
        BackgroundTransparency = 0,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Parent = control,
    })
    corner(button, 7)
    local buttonBorder = stroke(button, theme.lineSoft, 0.1, 1)
    local label = new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        FontFace = Fonts.medium,
        TextSize = 10,
        TextColor3 = theme.faint,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = button,
    })

    local api = { Flag = options.flag, Instance = button }

    local function fire()
        listeners.Fire(state)
        safeCallback(options.callback, state)
    end

    local function paint()
        if listening then
            label.Text = "press a key"
            label.TextColor3 = theme.accent
            button.BorderColor3 = theme.accent
            buttonBorder.Color = theme.accent
            buttonBorder.Transparency = 0.35
            button.BackgroundColor3 = theme.raised
            return
        end
        label.Text = keyLabel(state)
        label.TextColor3 = state and theme.text or theme.faint
        button.BackgroundColor3 = theme.field
        buttonBorder.Color = theme.lineSoft
        buttonBorder.Transparency = 0.1
    end

    local function stopListening()
        if not listening then
            return
        end
        listening = false
        lastStop = os.clock()
        window._keyListening = false
        if keyConnection then
            keyConnection:Disconnect()
            keyConnection = nil
        end
        if stopConnection then
            stopConnection:Disconnect()
            stopConnection = nil
        end
        paint()
    end

    local function startListening()
        if listening then
            stopListening()
            return
        end
        listening = true
        window._keyListening = true
        paint()
        keyConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then
                return
            end
            if input.KeyCode == Enum.KeyCode.Escape then
                stopListening()
                return
            end
            if input.KeyCode == Enum.KeyCode.Backspace and allowNone then
                api:Set(nil)
                stopListening()
                return
            end
            if input.KeyCode == Enum.KeyCode.Unknown then
                return
            end
            api:Set(input.KeyCode)
            stopListening()
        end)
        stopConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                stopListening()
            end
        end)
    end

    function api:Get()
        return state
    end

    function api:Set(value, silent)
        if value ~= nil then
            if typeof(value) ~= "EnumItem" or value.EnumType ~= Enum.KeyCode then
                return self
            end
        end
        local changed = value ~= state
        state = value
        paint()
        if changed and not silent then
            fire()
        end
        return self
    end

    function api:On(fn)
        return listeners.Connect(fn)
    end

    function api:Destroy()
        stopListening()
        row:Destroy()
    end

    paint()
    button.MouseEnter:Connect(function()
        if listening then
            return
        end
        tween(button, { BackgroundColor3 = theme.raised }, 0.12)
        tween(buttonBorder, { Color = theme.line, Transparency = 0.1 }, 0.12)
    end)
    button.MouseLeave:Connect(function()
        if listening then
            return
        end
        tween(button, { BackgroundColor3 = theme.field }, 0.14)
        tween(buttonBorder, { Color = theme.lineSoft }, 0.14)
    end)
    tap(button, function()
        if os.clock() - lastStop < 0.2 then
            return
        end
        if listening then
            stopListening()
        else
            startListening()
        end
    end)

    local flag = options.flag or window:_newFlag("keybind", self.tab, options.text or options.title or "keybind")
    api.Flag = flag
    window:_registerFlag(flag, {
        Get = function()
            return state
        end,
        Set = function(value)
            if type(value) == "string" then
                local ok, key = pcall(function()
                    return Enum.KeyCode[value]
                end)
                if ok then
                    api:Set(key)
                    return true
                end
                return false
            end
            api:Set(value)
        end,
        Kind = "Keybind",
    })

    return api
end


local pickerPresets = {
    Color3.fromRGB(224, 110, 78),
    Color3.fromRGB(227, 121, 114),
    Color3.fromRGB(224, 181, 106),
    Color3.fromRGB(132, 201, 154),
    Color3.fromRGB(111, 168, 221),
    Color3.fromRGB(171, 138, 224),
    Color3.fromRGB(232, 230, 225),
    Color3.fromRGB(120, 122, 132),
}

function Section:ColorPicker(options)
    options = options or {}
    local window = self.window
    local theme = window.theme
    local state = typeof(options.default) == "Color3" and options.default or theme.accent
    local listeners = emitter()
    local popover = nil

    local row, control = self:_row("Color", options, 168)
    local button = new("TextButton", {
        Name = "Color",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = theme.field,
        BackgroundTransparency = 0,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Parent = control,
    })
    corner(button, 7)
    local buttonBorder = stroke(button, theme.lineSoft, 0.1, 1)
    local swatch = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 6, 0.5, 0),
        Size = UDim2.fromOffset(18, 16),
        BackgroundColor3 = state,
        BorderSizePixel = 0,
        Parent = button,
    })
    corner(swatch, 4)
    stroke(swatch, theme.black, 0.82, 1)
    local swatchText = new("TextLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 31, 0.5, 0),
        Size = UDim2.new(1, -38, 1, 0),
        BackgroundTransparency = 1,
        Text = "#" .. hexOf(state),
        FontFace = Fonts.medium,
        TextSize = 10,
        TextColor3 = theme.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = button,
    })

    local api = { Flag = options.flag, Instance = button }

    local function paint()
        swatch.BackgroundColor3 = state
        swatchText.Text = "#" .. hexOf(state)
    end

    local function fire()
        listeners.Fire(state)
        safeCallback(options.callback, state)
    end

    function api:Get()
        return state
    end

    function api:Set(value, silent)
        if typeof(value) ~= "Color3" then
            return self
        end
        local changed = value ~= state
        state = value
        paint()
        if popover and not popover.closed then
            popover:Close(true)
            popover = nil
        end
        if changed and not silent then
            fire()
        end
        return self
    end

    function api:On(fn)
        return listeners.Connect(fn)
    end

    function api:Destroy()
        if popover then
            popover:Close(true)
        end
        row:Destroy()
    end

    local function open()
        if popover and not popover.closed then
            popover:Close(false)
            popover = nil
            return
        end

        local width, height = 236, 218
        local pop = window:_makePopover(width, height)
        popover = pop
        pop:PositionAt(button, height)
        pop.onClose = function()
            if popover == pop then
                popover = nil
            end
        end

        local h, s, v = RGBtoHSV(state)
        local svField = new("Frame", {
            Position = UDim2.fromOffset(10, 10),
            Size = UDim2.fromOffset(216, 116),
            BackgroundColor3 = HSVtoRGB(h, 1, 1),
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Active = true,
            Parent = pop.canvas,
        })
        corner(svField, 6)
        local white = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = theme.white,
            BorderSizePixel = 0,
            Parent = svField,
        })
        new("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Parent = white,
        })
        local black = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = theme.black,
            BorderSizePixel = 0,
            Parent = svField,
        })
        new("UIGradient", {
            Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Parent = black,
        })
        local cursor = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(10, 10),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = svField,
        })
        corner(cursor, UDim.new(1, 0))
        stroke(cursor, theme.white, 0, 1.5)
        local cursorInner = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(2, 2),
            BackgroundColor3 = theme.white,
            BorderSizePixel = 0,
            Parent = cursor,
        })
        corner(cursorInner, UDim.new(1, 0))

        local hueBar = new("Frame", {
            Position = UDim2.fromOffset(10, 136),
            Size = UDim2.fromOffset(216, 10),
            BackgroundColor3 = theme.white,
            BorderSizePixel = 0,
            ClipsDescendants = false,
            Active = true,
            Parent = pop.canvas,
        })
        corner(hueBar, UDim.new(1, 0))
        new("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 74, 74)),
                ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 210, 74)),
                ColorSequenceKeypoint.new(0.32, Color3.fromRGB(123, 230, 123)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(92, 220, 220)),
                ColorSequenceKeypoint.new(0.66, Color3.fromRGB(92, 145, 255)),
                ColorSequenceKeypoint.new(0.82, Color3.fromRGB(190, 110, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 74, 120)),
            }),
            Parent = hueBar,
        })
        local hueCursor = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(h, 0, 0.5, 0),
            Size = UDim2.fromOffset(4, 14),
            BackgroundColor3 = theme.white,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = hueBar,
        })
        corner(hueCursor, 2)
        stroke(hueCursor, theme.black, 0.55, 1)

        local preview = new("Frame", {
            Position = UDim2.fromOffset(10, 156),
            Size = UDim2.fromOffset(24, 24),
            BackgroundColor3 = state,
            BorderSizePixel = 0,
            Parent = pop.canvas,
        })
        corner(preview, 5)
        stroke(preview, theme.line, 0.2, 1)

        local hexBox = new("TextBox", {
            Position = UDim2.fromOffset(40, 156),
            Size = UDim2.fromOffset(94, 24),
            BackgroundColor3 = theme.field,
            BackgroundTransparency = 0,
            Text = hexOf(state),
            PlaceholderText = "RRGGBB",
            PlaceholderColor3 = theme.faint,
            TextColor3 = theme.text,
            FontFace = Fonts.medium,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ClearTextOnFocus = false,
            BorderSizePixel = 0,
            Parent = pop.canvas,
        })
        pad(hexBox, 0, 8, 0, 8)
        corner(hexBox, 6)
        local hexBorder = stroke(hexBox, theme.lineSoft, 0.05, 1)

        local presetFrame = new("Frame", {
            Position = UDim2.fromOffset(10, 192),
            Size = UDim2.new(1, -20, 0, 16),
            BackgroundTransparency = 1,
            Parent = pop.canvas,
        })
        list(presetFrame, 5, Enum.FillDirection.Horizontal)
        local presetButtons = {}
        for index, preset in ipairs(pickerPresets) do
            local presetButton = new("TextButton", {
                Size = UDim2.fromOffset(18, 16),
                BackgroundColor3 = preset,
                Text = "",
                AutoButtonColor = false,
                BorderSizePixel = 0,
                LayoutOrder = index,
                Parent = presetFrame,
            })
            corner(presetButton, 3)
            local border = stroke(presetButton, theme.line, 0.45, 1)
            presetButton.MouseEnter:Connect(function()
                tween(border, { Color = theme.text, Transparency = 0.2 }, 0.1)
            end)
            presetButton.MouseLeave:Connect(function()
                tween(border, { Color = theme.line, Transparency = 0.45 }, 0.12)
            end)
            tap(presetButton, function()
                h, s, v = RGBtoHSV(preset)
                local color = HSVtoRGB(h, s, v)
                api:Set(color)
                pop:Close(true)
                popover = nil
            end)
            presetButtons[index] = presetButton
        end

        local function updateFromHsv(notify)
            local color = HSVtoRGB(h, s, v)
            state = color
            preview.BackgroundColor3 = color
            svField.BackgroundColor3 = HSVtoRGB(h, 1, 1)
            cursor.Position = UDim2.new(s, 0, 1 - v, 0)
            hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
            hexBox.Text = hexOf(color)
            swatch.BackgroundColor3 = color
            swatchText.Text = "#" .. hexOf(color)
            if notify ~= false then
                fire()
            end
        end

        local function beginDrag(target, handler)
            target.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
                    return
                end
                handler(input.Position)
                local moveConnection
                local endConnection
                moveConnection = UserInputService.InputChanged:Connect(function(changed)
                    if changed.UserInputType == Enum.UserInputType.MouseMovement or changed.UserInputType == Enum.UserInputType.Touch then
                        handler(changed.Position)
                    end
                end)
                endConnection = UserInputService.InputEnded:Connect(function(ended)
                    if ended.UserInputType ~= input.UserInputType then
                        return
                    end
                    moveConnection:Disconnect()
                    endConnection:Disconnect()
                end)
            end)
        end

        beginDrag(svField, function(position)
            s = math.clamp((position.X - svField.AbsolutePosition.X) / math.max(1, svField.AbsoluteSize.X), 0, 1)
            v = 1 - math.clamp((position.Y - svField.AbsolutePosition.Y) / math.max(1, svField.AbsoluteSize.Y), 0, 1)
            updateFromHsv()
        end)
        beginDrag(hueBar, function(position)
            h = math.clamp((position.X - hueBar.AbsolutePosition.X) / math.max(1, hueBar.AbsoluteSize.X), 0, 1)
            updateFromHsv()
        end)

        hexBox.Focused:Connect(function()
            tween(hexBorder, { Color = theme.accent, Transparency = 0.5 }, 0.1)
        end)
        hexBox.FocusLost:Connect(function()
            tween(hexBorder, { Color = theme.lineSoft, Transparency = 0.05 }, 0.12)
            local text = hexBox.Text:gsub("#", "")
            if #text == 6 and tonumber(text, 16) then
                local color = colorOf(text)
                h, s, v = RGBtoHSV(color)
                updateFromHsv()
            else
                hexBox.Text = hexOf(state)
            end
        end)

        updateFromHsv(false)
    end

    button.MouseEnter:Connect(function()
        tween(button, { BackgroundColor3 = theme.raised }, 0.12)
        tween(buttonBorder, { Color = theme.line }, 0.12)
    end)
    button.MouseLeave:Connect(function()
        tween(button, { BackgroundColor3 = theme.field }, 0.14)
        tween(buttonBorder, { Color = theme.lineSoft }, 0.14)
    end)
    tap(button, open)

    paint()

    local flag = options.flag or window:_newFlag("color", self.tab, options.text or options.title or "color")
    api.Flag = flag
    window:_registerFlag(flag, {
        Get = function()
            return state
        end,
        Set = function(value)
            api:Set(value)
        end,
        Kind = "Color",
    })

    return api
end


function Section:Label(options)
    if type(options) == "string" then
        options = { text = options }
    end
    options = options or {}
    local theme = self.window.theme
    local text = tostring(options.text or options.title or "")
    local description = options.description ~= nil and tostring(options.description) or nil
    self.rowOrder += 1
    local hasDescription = description ~= nil and description ~= ""
    local height = hasDescription and 40 or 26

    local row = new("Frame", {
        Name = "Row",
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        LayoutOrder = self.rowOrder,
        Parent = self.card,
    })
    new("TextLabel", {
        Position = UDim2.new(0, 14, 0, hasDescription and 5 or 0),
        Size = UDim2.new(1, -28, 0, hasDescription and 15 or height),
        BackgroundTransparency = 1,
        Text = text,
        FontFace = Fonts.medium,
        TextSize = 11.5,
        TextColor3 = options.color or theme.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = hasDescription and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })
    if hasDescription then
        new("TextLabel", {
            Position = UDim2.new(0, 14, 0, 21),
            Size = UDim2.new(1, -28, 0, 14),
            BackgroundTransparency = 1,
            Text = description,
            FontFace = Fonts.regular,
            TextSize = 10,
            TextColor3 = options.descriptionColor or theme.faint,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })
    end
    return row
end

function Section:Paragraph(options)
    if type(options) == "string" then
        options = { text = options }
    end
    options = options or {}
    local theme = self.window.theme
    self.rowOrder += 1

    local row = new("Frame", {
        Name = "Row",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = self.rowOrder,
        Parent = self.card,
    })
    pad(row, 12, 16, 12, 14)
    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = tostring(options.text or options.title or ""),
        FontFace = Fonts.regular,
        TextSize = 10.5,
        TextColor3 = options.color or theme.dim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        LineHeight = 1.2,
        Parent = row,
    })
    return row
end

function Section:Divider()
    self.rowOrder += 1
    local row = new("Frame", {
        Name = "Row",
        Size = UDim2.new(1, 0, 0, 15),
        BackgroundTransparency = 1,
        LayoutOrder = self.rowOrder,
        Parent = self.card,
    })
    local theme = self.window.theme
    new("Frame", {
        Position = UDim2.new(0, 14, 0.5, 0),
        Size = UDim2.new(1, -28, 0, 1),
        BackgroundColor3 = theme.lineSoft,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Parent = row,
    })
    return row
end

function Section:Space(pixels)
    self.rowOrder += 1
    local height = math.clamp(tonumber(pixels) or 8, 1, 120)
    return new("Frame", {
        Name = "Row",
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        LayoutOrder = self.rowOrder,
        Parent = self.card,
    })
end


local function searchScore(query, text)
    local index = text:find(query, 1, true)
    if not index then
        local position = 1
        for i = 1, #query do
            local found = text:find(query:sub(i, i), position, true)
            if not found then
                return nil
            end
            position = found + 1
        end
        return 3
    end
    if index == 1 then
        return 0
    end
    local previous = text:sub(index - 1, index - 1)
    if previous == " " or previous == "-" or previous == "/" or previous == "." then
        return 1
    end
    return 2
end

function Window:_ensureSearch()
    if self._search then
        return self._search
    end
    local theme = self.theme

    local layer = new("CanvasGroup", {
        Name = "SearchLayer",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 95,
        Parent = self.root,
    })
    local dim = new("TextButton", {
        Name = "Dim",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = theme.black,
        BackgroundTransparency = 0.42,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 95,
        Parent = layer,
    })
    tap(dim, function()
        self:_closeSearch()
    end)

    local panel = new("CanvasGroup", {
        Name = "SearchPanel",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 60),
        Size = UDim2.fromOffset(448, 148),
        BackgroundColor3 = theme.panel,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        GroupTransparency = 0,
        ClipsDescendants = true,
        ZIndex = 96,
        Parent = layer,
    })
    corner(panel, 12)
    stroke(panel, theme.line, 0.1, 1)
    local panelScale = new("UIScale", { Scale = 1, Parent = panel })

    local searchIcon = iconLabel(panel, "magnifying-glass", 13, theme.dim)
    searchIcon.Position = UDim2.fromOffset(15, 19)
    searchIcon.Size = UDim2.fromOffset(14, 14)

    local input = new("TextBox", {
        Name = "Query",
        Position = UDim2.fromOffset(39, 0),
        Size = UDim2.new(1, -108, 0, 51),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search controls",
        PlaceholderColor3 = theme.faint,
        TextColor3 = theme.text,
        FontFace = Fonts.medium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
        ZIndex = 97,
        Parent = panel,
    })
    local escKey, _ = keycap(panel, "Esc", 34, 17)
    escKey.AnchorPoint = Vector2.new(1, 0.5)
    escKey.Position = UDim2.new(1, -12, 0, 25.5)
    escKey.ZIndex = 97

    new("Frame", {
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = theme.lineSoft,
        BorderSizePixel = 0,
        ZIndex = 97,
        Parent = panel,
    })

    local results = new("Frame", {
        Name = "Results",
        Position = UDim2.fromOffset(0, 51),
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        ZIndex = 96,
        Parent = panel,
    })
    local resultsLayout = list(results, 2)
    new("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        Parent = results,
    })

    local footer = new("Frame", {
        Position = UDim2.fromOffset(0, 103),
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = 96,
        Parent = panel,
    })
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = theme.lineSoft,
        BorderSizePixel = 0,
        Parent = footer,
    })
    new("TextLabel", {
        Position = UDim2.fromOffset(13, 0),
        Size = UDim2.new(0, 240, 1, 0),
        BackgroundTransparency = 1,
        Text = "Up/Down to move  \u{00B7}  Enter to open",
        FontFace = Fonts.regular,
        TextSize = 9,
        TextColor3 = theme.faint,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = footer,
    })
    local resultCount = new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.new(0, 80, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        FontFace = Fonts.regular,
        TextSize = 9,
        TextColor3 = theme.faint,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = footer,
    })

    local search = {
        layer = layer,
        dim = dim,
        panel = panel,
        scale = panelScale,
        input = input,
        results = results,
        resultsLayout = resultsLayout,
        footer = footer,
        resultCount = resultCount,
        rows = {},
        entries = {},
        selected = 0,
        empty = nil,
    }
    self._search = search
    input:GetPropertyChangedSignal("Text"):Connect(function()
        if self.searchOpen then
            self:_rebuildSearch()
        end
    end)
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed and self.searchOpen and search.rows[search.selected] then
            self:_openSearchEntry(search.rows[search.selected].entry)
        end
    end)
    return search
end

function Window:_paintSearchButton(active)
    self.searchButton.BackgroundColor3 = active and self.theme.raised or self.theme.field
    self.searchBorder.Color = active and self.theme.accent or self.theme.lineSoft
    self.searchBorder.Transparency = active and 0.55 or 0.15
    self.searchIcon.TextColor3 = active and self.theme.accent or self.theme.faint
    self.searchText.TextColor3 = active and self.theme.text or self.theme.dim
end

function Window:_rebuildSearch()
    if not self._search then
        return
    end
    local search = self._search
    for _, row in ipairs(search.rows) do
        if row.Parent then
            row:Destroy()
        end
    end
    search.rows = {}
    search.entries = {}
    search.selected = 0
    if search.empty and search.empty.Parent then
        search.empty:Destroy()
    end
    search.empty = nil

    local query = lowerText(search.input.Text):gsub("^%s+", ""):gsub("%s+$", "")
    local found = {}
    for _, entry in ipairs(self.index) do
        local score = query == "" and 0 or searchScore(query, entry.lower)
        if score then
            table.insert(found, { entry = entry, score = score })
        end
    end
    table.sort(found, function(a, b)
        if a.score ~= b.score then
            return a.score < b.score
        end
        if a.entry.tab.index ~= b.entry.tab.index then
            return a.entry.tab.index < b.entry.tab.index
        end
        return a.entry.lower < b.entry.lower
    end)
    while #found > 7 do
        table.remove(found)
    end

    local rowHeight = 32
    local resultsHeight = math.max(52, #found * rowHeight + 8)
    search.results.Size = UDim2.new(1, 0, 0, resultsHeight)
    search.results.Position = UDim2.fromOffset(0, 51)
    search.footer.Position = UDim2.fromOffset(0, 51 + resultsHeight)
    search.panel.Size = UDim2.fromOffset(448, 51 + resultsHeight + 30)
    search.resultCount.Text = tostring(#found) .. (#found == 1 and " result" or " results")

    if #found == 0 then
        local empty = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 44),
            BackgroundTransparency = 1,
            Text = query == "" and "No controls registered yet" or "No controls match \"" .. search.input.Text .. "\"",
            FontFace = Fonts.regular,
            TextSize = 10,
            TextColor3 = self.theme.faint,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = search.results,
        })
        search.empty = empty
        return
    end

    for index, hit in ipairs(found) do
        local entry = hit.entry
        local button = new("TextButton", {
            Size = UDim2.new(1, 0, 0, rowHeight),
            BackgroundColor3 = self.theme.raised,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            LayoutOrder = index,
            Parent = search.results,
        })
        corner(button, 6)
        local marker = new("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(2, 13),
            BackgroundColor3 = self.theme.accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = button,
        })
        corner(marker, UDim.new(1, 0))
        new("TextLabel", {
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -180, 1, 0),
            BackgroundTransparency = 1,
            Text = entry.text,
            FontFace = Fonts.medium,
            TextSize = 11,
            TextColor3 = self.theme.text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = button,
        })
        new("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.new(0, 160, 1, 0),
            BackgroundTransparency = 1,
            Text = entry.tab.name .. "  \u{00B7}  " .. entry.kind,
            FontFace = Fonts.regular,
            TextSize = 9,
            TextColor3 = self.theme.faint,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = button,
        })
        search.rows[index] = {
            button = button,
            marker = marker,
            entry = entry,
        }
        table.insert(search.entries, entry)

        button.MouseEnter:Connect(function()
            search.selected = index
            self:_paintSearchSelection()
        end)
        tap(button, function()
            self:_openSearchEntry(entry)
        end)
    end

    search.selected = 1
    self:_paintSearchSelection()
end

function Window:_paintSearchSelection()
    local search = self._search
    if not search then
        return
    end
    for index, row in ipairs(search.rows) do
        local selected = index == search.selected
        row.button.BackgroundTransparency = selected and 0 or 1
        row.marker.BackgroundTransparency = selected and 0 or 1
    end
end

function Window:_openSearchEntry(entry)
    if not self.searchOpen or not entry then
        return
    end
    self:_closeSearch()
    self:SelectTab(entry.tab.index)
    task.delay(0.16, function()
        if self.destroyed or not entry.row or not entry.row.Parent then
            return
        end
        local viewport = entry.tab.viewport
        if not viewport or not viewport.Visible then
            return
        end
        local offset = entry.row.AbsolutePosition.Y - viewport.AbsolutePosition.Y + viewport.CanvasPosition.Y
        local maxScroll = math.max(0, viewport.AbsoluteCanvasSize.Y - viewport.AbsoluteSize.Y)
        local target = math.clamp(offset - 74, 0, maxScroll)
        TweenService:Create(
            viewport,
            TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { CanvasPosition = Vector2.new(0, target) }
        ):Play()

        local flash = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = self.theme.accent,
            BackgroundTransparency = 0.86,
            BorderSizePixel = 0,
            ZIndex = 0,
            Parent = entry.row,
        })
        tween(flash, { BackgroundTransparency = 1 }, 0.9, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        task.delay(1, function()
            if flash.Parent then
                flash:Destroy()
            end
        end)
    end)
end

function Window:_openSearch()
    if self.destroyed or not self.isOpen or self.searchOpen then
        if self.searchOpen and self._search then
            pcall(function()
                self._search.input:CaptureFocus()
            end)
        end
        return
    end
    self:_closePopover()
    local search = self:_ensureSearch()
    self.searchOpen = true
    self:_paintSearchButton(true)
    search.layer.Visible = true
    search.layer.GroupTransparency = 1
    search.scale.Scale = 0.985
    search.input.Text = ""
    self:_rebuildSearch()
    tween(search.layer, { GroupTransparency = 0 }, 0.14)
    tween(search.scale, { Scale = 1 }, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    task.defer(function()
        if self.searchOpen and search.input.Parent then
            pcall(function()
                search.input:CaptureFocus()
            end)
        end
    end)

    if self._searchKeyConnection then
        pcall(function()
            self._searchKeyConnection:Disconnect()
        end)
    end
    self._searchKeyConnection = UserInputService.InputBegan:Connect(function(input)
        if not self.searchOpen then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        if input.KeyCode == Enum.KeyCode.Escape then
            self:_closeSearch()
        elseif input.KeyCode == Enum.KeyCode.Up then
            if search.selected > 1 then
                search.selected -= 1
                self:_paintSearchSelection()
            end
        elseif input.KeyCode == Enum.KeyCode.Down then
            if search.selected < #search.rows then
                search.selected += 1
                self:_paintSearchSelection()
            end
        elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
            local entry = search.entries[search.selected]
            if entry then
                self:_openSearchEntry(entry)
            end
        end
    end)
end

function Window:_closeSearch()
    if not self.searchOpen then
        return
    end
    self.searchOpen = false
    if self._searchKeyConnection then
        pcall(function()
            self._searchKeyConnection:Disconnect()
        end)
        self._searchKeyConnection = nil
    end
    local search = self._search
    if not search then
        self:_paintSearchButton(false)
        return
    end
    pcall(function()
        search.input:ReleaseFocus()
    end)
    self:_paintSearchButton(false)
    local token = (self._searchToken or 0) + 1
    self._searchToken = token
    tween(search.layer, { GroupTransparency = 1 }, 0.1)
    tween(search.scale, { Scale = 0.985 }, 0.12)
    task.delay(0.14, function()
        if token == self._searchToken and not self.searchOpen then
            search.layer.Visible = false
            search.input.Text = ""
        end
    end)
end

function Window:OpenSearch()
    if self.destroyed then
        return self
    end
    if not self.isOpen then
        self:Show()
    end
    self:_openSearch()
    return self
end

function Window:CloseSearch()
    self:_closeSearch()
    return self
end

function Window:IsSearchOpen()
    return self.searchOpen == true
end


local function sanitizeName(name)
    name = tostring(name or "default"):gsub("[^%w_%-]", "_")
    if name == "" then
        name = "default"
    end
    return name
end

local function encodeValue(value)
    if typeof(value) == "Color3" then
        return { __type = "color", value = hexOf(value) }
    end
    if typeof(value) == "EnumItem" then
        local enumName = tostring(value.EnumType):gsub("^Enum%.", "")
        return { __type = "enum", enum = enumName, value = value.Name }
    end
    if type(value) == "boolean" or type(value) == "number" or type(value) == "string" then
        return value
    end
    return nil
end

local function decodeValue(value)
    if type(value) ~= "table" then
        return value
    end
    if value.__type == "color" then
        return colorOf(value.value)
    end
    if value.__type == "enum" then
        local enumName = tostring(value.enum or ""):gsub("^Enum%.", "")
        local ok, enum = pcall(function()
            return Enum[enumName]
        end)
        if ok and enum then
            local ok2, item = pcall(function()
                return enum[value.value]
            end)
            if ok2 then
                return item
            end
        end
        return nil
    end
    return nil
end

function Window:SaveConfig(name)
    if self.destroyed then
        return false, "window destroyed"
    end
    if type(writefile) ~= "function" then
        return false, "writefile is unavailable"
    end
    local clean = sanitizeName(name or self.options.configName)
    local payload = {
        name = clean,
        version = Ixa.Version,
        savedAt = os.time(),
        toggleKey = self.toggleKey and self.toggleKey.Name or nil,
        flags = {},
    }
    for flag, api in pairs(self.flags) do
        if api and api.Get then
            local ok, value = pcall(api.Get)
            if ok then
                payload.flags[flag] = encodeValue(value)
            end
        end
    end
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(payload)
    end)
    if not ok then
        return false, "could not encode config"
    end
    local path = "ixa_" .. clean .. ".json"
    local saved = pcall(function()
        writefile(path, encoded)
    end)
    if not saved then
        return false, "could not write " .. path
    end
    return true, path
end

function Window:LoadConfig(name)
    if self.destroyed then
        return false, "window destroyed"
    end
    if type(readfile) ~= "function" or type(isfile) ~= "function" then
        return false, "readfile is unavailable"
    end
    local clean = sanitizeName(name or self.options.configName)
    local path = "ixa_" .. clean .. ".json"
    local exists = false
    pcall(function()
        exists = isfile(path)
    end)
    if not exists then
        return false, "config not found"
    end
    local raw
    local readOk = pcall(function()
        raw = readfile(path)
    end)
    if not readOk or type(raw) ~= "string" then
        return false, "could not read config"
    end
    local decodeOk, payload = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if not decodeOk or type(payload) ~= "table" or type(payload.flags) ~= "table" then
        return false, "config is not valid"
    end

    local applied = 0
    for flag, rawValue in pairs(payload.flags) do
        local api = self.flags[flag]
        if api and api.Set then
            local ok = pcall(api.Set, decodeValue(rawValue))
            if ok then
                applied += 1
            end
        end
    end
    if payload.toggleKey then
        local ok, key = pcall(function()
            return Enum.KeyCode[payload.toggleKey]
        end)
        if ok and key then
            self:SetToggleKey(key)
        end
    end
    return true, applied
end

function Window:DeleteConfig(name)
    if self.destroyed then
        return false, "window destroyed"
    end
    local remove = delfile
    if type(remove) ~= "function" then
        remove = deletefile
    end
    if type(remove) ~= "function" then
        return false, "delfile is unavailable"
    end
    local clean = sanitizeName(name or self.options.configName)
    local path = "ixa_" .. clean .. ".json"
    local ok = pcall(function()
        remove(path)
    end)
    return ok, path
end

return Ixa
