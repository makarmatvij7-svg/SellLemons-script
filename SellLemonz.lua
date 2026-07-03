--[[
    ═══════════════════════════════════════════════════════
      LEMON HUB v4.1  —  Sell Lemons 🍋
      Clean UI • Lucide icons • Full auto-farm engine
      UI builds instantly; game modules load async with
      timeouts so a hung require can never freeze the client.
    ═══════════════════════════════════════════════════════
]]

print("[LemonHub] v4.1 loading...")

-- ══════════════ Cleanup previous instance ══════════════
if getgenv().LemonHubV4 then
    pcall(function() getgenv().LemonHubV4.Destroy() end)
    getgenv().LemonHubV4 = nil
end

-- ══════════════ Services ══════════════
local Players            = game:GetService("Players")
local RS                 = game:GetService("ReplicatedStorage")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local CollectionService  = game:GetService("CollectionService")
local HttpService        = game:GetService("HttpService")

local LP = Players.LocalPlayer
local alive = true

-- ══════════════ Theme ══════════════
local T = {
    Bg        = Color3.fromRGB(12, 14, 18),
    Surface   = Color3.fromRGB(19, 22, 29),
    Elevated  = Color3.fromRGB(28, 32, 42),
    Elevated2 = Color3.fromRGB(36, 41, 53),
    Stroke    = Color3.fromRGB(255, 255, 255),
    Text      = Color3.fromRGB(233, 236, 244),
    TextDim   = Color3.fromRGB(136, 145, 164),
    TextFaint = Color3.fromRGB(90, 98, 115),
    Accent    = Color3.fromRGB(250, 204, 21),
    AccentTxt = Color3.fromRGB(28, 23, 5),
    Green     = Color3.fromRGB(74, 222, 128),
    Red       = Color3.fromRGB(248, 113, 113),
    Violet    = Color3.fromRGB(167, 139, 250),
    Blue      = Color3.fromRGB(96, 165, 250),
}
local FONT_B, FONT_M, FONT_R = Enum.Font.GothamBold, Enum.Font.GothamMedium, Enum.Font.Gotham

-- ══════════════ Async Lucide icons ══════════════
-- UI builds immediately; icons pop in once the sprite lib downloads.
local Lucide = nil
local pendingIcons = {}   -- ImageLabel -> icon name
local function applyIcon(img, name)
    if not Lucide then return end
    local ok, a = pcall(Lucide.GetAsset, name, 48)
    if ok and a then
        img.Image = a.Url
        img.ImageRectOffset = a.ImageRectOffset
        img.ImageRectSize = a.ImageRectSize
    end
end
task.spawn(function()
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet(
            "https://github.com/latte-soft/lucide-roblox/releases/latest/download/lucide-roblox.luau"))()
    end)
    if ok and lib then
        Lucide = lib
        for img, name in pairs(pendingIcons) do
            if img.Parent then applyIcon(img, name) end
        end
        pendingIcons = {}
        print("[LemonHub] Lucide icons loaded")
    else
        print("[LemonHub] Lucide failed to load (UI still works)")
    end
end)

-- ══════════════ UI helpers ══════════════
local connections = {}
local function track(con) table.insert(connections, con) return con end

local function mk(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function corner(r) return mk("UICorner", { CornerRadius = UDim.new(0, r) }) end
local function stroke(transp, color)
    return mk("UIStroke", {
        Color = color or T.Stroke, Transparency = transp or 0.92, Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end
local function pad(t, r, b, l)
    return mk("UIPadding", {
        PaddingTop = UDim.new(0, t), PaddingRight = UDim.new(0, r or t),
        PaddingBottom = UDim.new(0, b or t), PaddingLeft = UDim.new(0, l or r or t),
    })
end

local function icon(name, size, color, parent)
    local img = mk("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(size, size),
        ImageColor3 = color or T.Text,
        ScaleType = Enum.ScaleType.Fit,
        Parent = parent,
    })
    if Lucide then applyIcon(img, name) else pendingIcons[img] = name end
    return img
end

local function tween(inst, ti, props)
    local tw = TweenService:Create(inst, ti, props)
    tw:Play()
    return tw
end
local TI_FAST = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_MED  = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_POP  = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- ══════════════ State & config ══════════════
local State = {
    buyTiles = false, upgradeEarners = false, wakeEarners = false, powers = false,
    cashDrops = false, phoneDeals = false, minigame = false, harvest = false,
    rebirth = false, evolve = false, ascend = false,
    antiAfk = true, wsEnabled = false, wsValue = 16,
}
local CONFIG_FILE = "LemonHubV4.json"
local function saveConfig()
    pcall(function()
        if writefile then writefile(CONFIG_FILE, HttpService:JSONEncode(State)) end
    end)
end
pcall(function()
    if readfile and isfile and isfile(CONFIG_FILE) then
        local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        for k, v in pairs(data) do
            if State[k] ~= nil then State[k] = v end
        end
    end
end)
State.ascend = false -- never auto-load the dangerous one

local saveQueued = false
local function queueSave()
    if saveQueued then return end
    saveQueued = true
    task.delay(1, function() saveQueued = false saveConfig() end)
end

-- ══════════════ ScreenGui (PlayerGui — executor threads can't touch gethui) ══════════════
local pg = LP:WaitForChild("PlayerGui")
local gui = mk("ScreenGui", {
    Name = "LemonHubV4", ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999, Parent = pg,
})

-- ══════════════ Toasts ══════════════
local toastHolder = mk("Frame", {
    BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -16, 1, -16), Size = UDim2.fromOffset(272, 400),
    Parent = gui,
}, {
    mk("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical, VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }),
})
local toastOrder = 0
local function toast(title, msg, iconName, color)
    if not alive then return end
    toastOrder += 1
    local card = mk("Frame", {
        BackgroundColor3 = T.Surface, Size = UDim2.new(1, 40, 0, 58),
        LayoutOrder = toastOrder, ClipsDescendants = true, Parent = toastHolder,
    }, { corner(10), stroke(0.88), pad(10, 12, 10, 12) })
    local ic = icon(iconName or "citrus", 22, color or T.Accent, card)
    ic.Position = UDim2.fromOffset(0, 7)
    mk("TextLabel", {
        BackgroundTransparency = 1, Font = FONT_B, Text = title, TextSize = 13,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(34, 2), Size = UDim2.new(1, -34, 0, 16), Parent = card,
    })
    mk("TextLabel", {
        BackgroundTransparency = 1, Font = FONT_R, Text = msg or "", TextSize = 12,
        TextColor3 = T.TextDim, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.fromOffset(34, 20), Size = UDim2.new(1, -34, 0, 16), Parent = card,
    })
    card.BackgroundTransparency = 1
    tween(card, TI_MED, { Size = UDim2.new(1, 0, 0, 58), BackgroundTransparency = 0 })
    task.delay(4, function()
        if card.Parent then
            tween(card, TI_MED, { Size = UDim2.new(1, 40, 0, 58), BackgroundTransparency = 1 })
            task.wait(0.25)
            card:Destroy()
        end
    end)
end

-- ══════════════ Main window ══════════════
local WIN_W, WIN_H = 680, 440
local win = mk("Frame", {
    Name = "Window", BackgroundColor3 = T.Bg, AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(WIN_W, WIN_H),
    ClipsDescendants = true, Parent = gui,
}, { corner(14), stroke(0.9) })

-- ── Topbar ──
local topbar = mk("Frame", {
    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48), Parent = win,
})
local titleIcon = icon("citrus", 20, T.Accent, topbar)
titleIcon.Position = UDim2.fromOffset(18, 14)
mk("TextLabel", {
    BackgroundTransparency = 1, Font = FONT_B, Text = "Lemon Hub", TextSize = 15,
    TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.fromOffset(46, 8), Size = UDim2.fromOffset(120, 18), Parent = topbar,
})
mk("TextLabel", {
    BackgroundTransparency = 1, Font = FONT_R, Text = "Sell Lemons 🍋  •  v4.1", TextSize = 11,
    TextColor3 = T.TextFaint, TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.fromOffset(46, 26), Size = UDim2.fromOffset(160, 14), Parent = topbar,
})

local statusDot = mk("Frame", {
    BackgroundColor3 = T.TextFaint, AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -104, 0.5, 0), Size = UDim2.fromOffset(8, 8), Parent = topbar,
}, { corner(4) })
local statusLbl = mk("TextLabel", {
    BackgroundTransparency = 1, Font = FONT_M, Text = "booting", TextSize = 11,
    TextColor3 = T.TextDim, TextXAlignment = Enum.TextXAlignment.Left,
    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -44, 0.5, 0),
    Size = UDim2.fromOffset(52, 14), Parent = topbar,
})

local function winButton(iconName, xOff, hoverColor)
    local btn = mk("TextButton", {
        BackgroundColor3 = T.Surface, Text = "", AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, xOff, 0.5, 0),
        Size = UDim2.fromOffset(28, 28), Parent = topbar,
    }, { corner(8) })
    local ic = icon(iconName, 14, T.TextDim, btn)
    ic.AnchorPoint = Vector2.new(0.5, 0.5)
    ic.Position = UDim2.fromScale(0.5, 0.5)
    track(btn.MouseEnter:Connect(function()
        tween(btn, TI_FAST, { BackgroundColor3 = hoverColor or T.Elevated })
        tween(ic, TI_FAST, { ImageColor3 = T.Text })
    end))
    track(btn.MouseLeave:Connect(function()
        tween(btn, TI_FAST, { BackgroundColor3 = T.Surface })
        tween(ic, TI_FAST, { ImageColor3 = T.TextDim })
    end))
    return btn
end
-- keep window buttons clear of the status text
local minBtn = winButton("minus", -152)
local closeBtn = winButton("x", -118)

-- reposition: buttons on far right, status to their left
minBtn.Position = UDim2.new(1, -52, 0.5, 0)
closeBtn.Position = UDim2.new(1, -16, 0.5, 0)
statusDot.Position = UDim2.new(1, -160, 0.5, 0)
statusLbl.Position = UDim2.new(1, -96, 0.5, 0)

-- ── Drag ──
local function makeDraggable(handle, target)
    local dragging, dragStart, startPos = false, nil, nil
    track(handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
        end
    end))
    track(handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
    track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
end
makeDraggable(topbar, win)

-- ── Sidebar ──
local sidebar = mk("Frame", {
    BackgroundColor3 = T.Surface, Position = UDim2.fromOffset(10, 56),
    Size = UDim2.fromOffset(150, WIN_H - 56 - 10), Parent = win,
}, { corner(12), stroke(0.94) })

mk("TextLabel", {
    BackgroundTransparency = 1, Font = FONT_R, TextSize = 10,
    Text = LP.Name, TextColor3 = T.TextFaint, TextTruncate = Enum.TextTruncate.AtEnd,
    AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -10),
    Size = UDim2.new(1, -20, 0, 12), Parent = sidebar,
})

local content = mk("Frame", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(170, 56),
    Size = UDim2.new(1, -180, 1, -66), Parent = win,
})

-- ── Tabs ──
local tabs, tabOrder = {}, 0
local activeTab = nil
local tabIndicator = mk("Frame", {
    BackgroundColor3 = T.Accent, Size = UDim2.fromOffset(3, 20),
    Position = UDim2.fromOffset(0, 14), Parent = sidebar, Visible = false,
}, { corner(2) })

local function makePage()
    local page = mk("ScrollingFrame", {
        BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = T.Elevated2,
        BorderSizePixel = 0, Visible = false, Parent = content,
    }, {
        mk("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
        pad(2, 6, 12, 2),
    })
    return page
end

local function addTab(name, iconName)
    tabOrder += 1
    local order = tabOrder
    local page = makePage()
    local btn = mk("TextButton", {
        BackgroundColor3 = T.Surface, BackgroundTransparency = 1, Text = "",
        AutoButtonColor = false, Position = UDim2.fromOffset(8, 12 + (order - 1) * 42),
        Size = UDim2.new(1, -16, 0, 36), Parent = sidebar,
    }, { corner(9) })
    local ic = icon(iconName, 17, T.TextDim, btn)
    ic.Position = UDim2.fromOffset(11, 9)
    local lbl = mk("TextLabel", {
        BackgroundTransparency = 1, Font = FONT_M, Text = name, TextSize = 13,
        TextColor3 = T.TextDim, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(38, 0), Size = UDim2.new(1, -38, 1, 0), Parent = btn,
    })
    local tab = { name = name, page = page, btn = btn, ic = ic, lbl = lbl, order = order }
    table.insert(tabs, tab)

    local function select()
        for _, t2 in ipairs(tabs) do
            t2.page.Visible = false
            tween(t2.btn, TI_FAST, { BackgroundTransparency = 1 })
            tween(t2.ic, TI_FAST, { ImageColor3 = T.TextDim })
            tween(t2.lbl, TI_FAST, { TextColor3 = T.TextDim })
        end
        activeTab = tab
        page.Visible = true
        tween(btn, TI_FAST, { BackgroundTransparency = 0, BackgroundColor3 = T.Elevated })
        tween(ic, TI_FAST, { ImageColor3 = T.Accent })
        tween(lbl, TI_FAST, { TextColor3 = T.Text })
        tabIndicator.Visible = true
        tween(tabIndicator, TI_MED, { Position = UDim2.fromOffset(0, 12 + (order - 1) * 42 + 8) })
    end
    track(btn.MouseButton1Click:Connect(select))
    track(btn.MouseEnter:Connect(function()
        if activeTab ~= tab then tween(btn, TI_FAST, { BackgroundTransparency = 0.5, BackgroundColor3 = T.Elevated }) end
    end))
    track(btn.MouseLeave:Connect(function()
        if activeTab ~= tab then tween(btn, TI_FAST, { BackgroundTransparency = 1 }) end
    end))
    tab.select = select
    return page, tab
end

-- ══════════════ Row components ══════════════
local Toggles = {}   -- key -> { Set = fn }

local function sectionLabel(page, text)
    mk("TextLabel", {
        BackgroundTransparency = 1, Font = FONT_B, Text = string.upper(text), TextSize = 10,
        TextColor3 = T.TextFaint, TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 18), Parent = page,
    })
end

local function baseRow(page, height)
    return mk("Frame", {
        BackgroundColor3 = T.Surface, Size = UDim2.new(1, 0, 0, height or 54), Parent = page,
    }, { corner(10), stroke(0.94) })
end

local function rowHeader(row, opt)
    local iconBg = mk("Frame", {
        BackgroundColor3 = T.Elevated, Position = UDim2.fromOffset(12, 11),
        Size = UDim2.fromOffset(32, 32), Parent = row,
    }, { corner(8) })
    local ic = icon(opt.icon, 17, opt.iconColor or T.TextDim, iconBg)
    ic.AnchorPoint = Vector2.new(0.5, 0.5)
    ic.Position = UDim2.fromScale(0.5, 0.5)
    mk("TextLabel", {
        BackgroundTransparency = 1, Font = FONT_M, Text = opt.title, TextSize = 13,
        TextColor3 = opt.danger and T.Red or T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(54, 10), Size = UDim2.new(1, -120, 0, 16), Parent = row,
    })
    mk("TextLabel", {
        BackgroundTransparency = 1, Font = FONT_R, Text = opt.desc or "", TextSize = 11,
        TextColor3 = T.TextFaint, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.fromOffset(54, 28), Size = UDim2.new(1, -120, 0, 14), Parent = row,
    })
    return iconBg, ic
end

local function toggleRow(page, opt)
    local row = baseRow(page)
    local iconBg, ic = rowHeader(row, opt)
    local onColor = opt.danger and T.Red or T.Accent

    local pill = mk("Frame", {
        BackgroundColor3 = T.Elevated2, AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(40, 22), Parent = row,
    }, { corner(11) })
    local knob = mk("Frame", {
        BackgroundColor3 = Color3.fromRGB(200, 205, 215), Position = UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(16, 16), Parent = pill,
    }, { corner(8) })

    local function render(v, instant)
        local ti = instant and TweenInfo.new(0) or TI_MED
        tween(pill, ti, { BackgroundColor3 = v and onColor or T.Elevated2 })
        tween(knob, ti, {
            Position = v and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3),
            BackgroundColor3 = v and (opt.danger and Color3.fromRGB(255, 235, 235) or T.AccentTxt) or Color3.fromRGB(200, 205, 215),
        })
        tween(ic, ti, { ImageColor3 = v and onColor or (opt.iconColor or T.TextDim) })
    end
    render(State[opt.key], true)

    local function set(v)
        if opt.confirm and v and not opt._confirmed then
            opt._confirmed = true
            toast("Are you sure?", "Click again within 3s to enable " .. opt.title, "crown", T.Red)
            task.delay(3, function() opt._confirmed = false end)
            return
        end
        State[opt.key] = v
        render(v)
        queueSave()
        if opt.onChange then opt.onChange(v) end
    end

    local hit = mk("TextButton", {
        BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), Parent = row,
    })
    track(hit.MouseButton1Click:Connect(function() set(not State[opt.key]) end))
    track(hit.MouseEnter:Connect(function() tween(row, TI_FAST, { BackgroundColor3 = T.Elevated }) end))
    track(hit.MouseLeave:Connect(function() tween(row, TI_FAST, { BackgroundColor3 = T.Surface }) end))

    Toggles[opt.key] = { Set = function(v) set(v) end, Render = render }
    return row
end

local function sliderRow(page, opt)
    local row = baseRow(page, 68)
    rowHeader(row, opt)
    local valLbl = mk("TextLabel", {
        BackgroundTransparency = 1, Font = FONT_B, TextSize = 12, TextColor3 = T.Accent,
        Text = tostring(State[opt.key]), TextXAlignment = Enum.TextXAlignment.Right,
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 12),
        Size = UDim2.fromOffset(80, 16), Parent = row,
    })
    local trackBar = mk("Frame", {
        BackgroundColor3 = T.Elevated2, Position = UDim2.fromOffset(54, 50),
        Size = UDim2.new(1, -70, 0, 5), Parent = row,
    }, { corner(3) })
    local fill = mk("Frame", {
        BackgroundColor3 = T.Accent, Size = UDim2.fromScale(0, 1), Parent = trackBar,
    }, { corner(3) })
    local knob = mk("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(13, 13), Parent = trackBar,
    }, { corner(7), stroke(0.7) })

    local function render(v)
        local a = (v - opt.min) / (opt.max - opt.min)
        fill.Size = UDim2.fromScale(a, 1)
        knob.Position = UDim2.new(a, 0, 0.5, 0)
        valLbl.Text = tostring(v) .. (opt.suffix or "")
    end
    render(State[opt.key])

    local draggingSlider = false
    local function applyFromX(x)
        local a = math.clamp((x - trackBar.AbsolutePosition.X) / trackBar.AbsoluteSize.X, 0, 1)
        local v = math.floor(opt.min + a * (opt.max - opt.min) + 0.5)
        if v ~= State[opt.key] then
            State[opt.key] = v
            render(v)
            queueSave()
            if opt.onChange then opt.onChange(v) end
        end
    end
    local hit = mk("TextButton", {
        BackgroundTransparency = 1, Text = "", Position = UDim2.fromOffset(48, 38),
        Size = UDim2.new(1, -58, 0, 26), Parent = row,
    })
    track(hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            applyFromX(input.Position.X)
        end
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then draggingSlider = false end
    end))
    track(UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            applyFromX(input.Position.X)
        end
    end))
    return row
end

local function buttonRow(page, opt)
    local row = baseRow(page)
    local _, ic = rowHeader(row, opt)
    local hit = mk("TextButton", {
        BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), Parent = row,
    })
    track(hit.MouseButton1Click:Connect(opt.onClick))
    track(hit.MouseEnter:Connect(function()
        tween(row, TI_FAST, { BackgroundColor3 = opt.danger and Color3.fromRGB(60, 25, 25) or T.Elevated })
    end))
    track(hit.MouseLeave:Connect(function() tween(row, TI_FAST, { BackgroundColor3 = T.Surface }) end))
    return row
end

-- ══════════════ Build tabs ══════════════
local dashPage, dashTab = addTab("Dashboard", "layout-dashboard")
local farmPage  = addTab("Farm", "sprout")
local prestigePage = addTab("Prestige", "crown")
local settingsPage = addTab("Settings", "settings")

-- ── Dashboard: stat grid ──
sectionLabel(dashPage, "Live stats")
local statGrid = mk("Frame", {
    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 148), Parent = dashPage,
}, {
    mk("UIGridLayout", {
        CellSize = UDim2.new(0.5, -4, 0, 46), CellPadding = UDim2.fromOffset(8, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }),
})
local statValues = {}
local function statCard(iconName, label, color)
    local card = mk("Frame", { BackgroundColor3 = T.Surface, Parent = statGrid },
        { corner(10), stroke(0.94) })
    local ic = icon(iconName, 16, color or T.Accent, card)
    ic.Position = UDim2.fromOffset(12, 15)
    mk("TextLabel", {
        BackgroundTransparency = 1, Font = FONT_R, Text = label, TextSize = 10,
        TextColor3 = T.TextFaint, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(38, 8), Size = UDim2.new(1, -46, 0, 12), Parent = card,
    })
    local val = mk("TextLabel", {
        BackgroundTransparency = 1, Font = FONT_B, Text = "—", TextSize = 14,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.fromOffset(38, 21), Size = UDim2.new(1, -46, 0, 18), Parent = card,
    })
    statValues[label] = val
    return card
end
statCard("circle-dollar-sign", "Cash", T.Accent)
statCard("star", "Investors", T.Violet)
statCard("refresh-cw", "Rebirths", T.Green)
statCard("wallet", "Session earned", T.Blue)
statCard("gauge", "Rate", T.Green)
statCard("timer", "Race cooldown", T.TextDim)

-- ── Dashboard: quick actions ──
sectionLabel(dashPage, "Quick actions")
local qa = mk("Frame", {
    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), Parent = dashPage,
}, {
    mk("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }),
})
local FARM_KEYS = { "buyTiles", "upgradeEarners", "wakeEarners", "powers", "cashDrops", "phoneDeals", "minigame", "rebirth", "evolve" }
local function quickBtn(text, iconName, accent, cb)
    local btn = mk("TextButton", {
        BackgroundColor3 = accent and T.Accent or T.Surface, Text = "", AutoButtonColor = false,
        Size = UDim2.fromOffset(108, 34), Parent = qa,
    }, { corner(9), stroke(accent and 1 or 0.92) })
    local ic = icon(iconName, 14, accent and T.AccentTxt or T.TextDim, btn)
    ic.Position = UDim2.fromOffset(12, 10)
    mk("TextLabel", {
        BackgroundTransparency = 1, Font = FONT_B, Text = text, TextSize = 12,
        TextColor3 = accent and T.AccentTxt or T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(33, 0), Size = UDim2.new(1, -33, 1, 0), Parent = btn,
    })
    track(btn.MouseButton1Click:Connect(cb))
    track(btn.MouseEnter:Connect(function()
        tween(btn, TI_FAST, { BackgroundColor3 = accent and Color3.fromRGB(255, 220, 80) or T.Elevated })
    end))
    track(btn.MouseLeave:Connect(function()
        tween(btn, TI_FAST, { BackgroundColor3 = accent and T.Accent or T.Surface })
    end))
    return btn
end
quickBtn("Start all", "play", true, function()
    for _, k in ipairs(FARM_KEYS) do if Toggles[k] then Toggles[k].Set(true) end end
    toast("Farm started", #FARM_KEYS .. " features enabled", "play", T.Green)
end)
quickBtn("Stop all", "pause", false, function()
    for _, k in ipairs(FARM_KEYS) do if Toggles[k] then Toggles[k].Set(false) end end
    if Toggles.harvest then Toggles.harvest.Set(false) end
    if Toggles.ascend then Toggles.ascend.Set(false) end
    toast("Farm stopped", "All features disabled", "pause", T.Red)
end)

-- ── Dashboard: activity feed ──
sectionLabel(dashPage, "Activity")
local feedFrame = mk("Frame", {
    BackgroundColor3 = T.Surface, Size = UDim2.new(1, 0, 0, 132), Parent = dashPage,
}, { corner(10), stroke(0.94), pad(8, 12, 8, 12),
    mk("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }) })
local feedLines = {}
local feedCount = 0
local MAX_FEED = 6
local function log(text, color)
    if not alive then return end
    feedCount += 1
    local line = mk("TextLabel", {
        BackgroundTransparency = 1, Font = FONT_R, TextSize = 11,
        Text = os.date("%H:%M:%S") .. "  " .. text,
        TextColor3 = color or T.TextDim, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Size = UDim2.new(1, 0, 0, 17), LayoutOrder = feedCount, Parent = feedFrame,
    })
    table.insert(feedLines, line)
    if #feedLines > MAX_FEED then
        local old = table.remove(feedLines, 1)
        old:Destroy()
    end
end
log("Lemon Hub v4.1 loaded", T.Accent)

-- ── Farm tab ──
sectionLabel(farmPage, "Economy")
toggleRow(farmPage, { key = "buyTiles", icon = "shopping-cart", title = "Auto Buy Tiles",
    desc = "Purchases every unlocked tycoon tile" })
toggleRow(farmPage, { key = "upgradeEarners", icon = "trending-up", title = "Auto Upgrade Earners",
    desc = "Bulk-buys as many levels as affordable" })
toggleRow(farmPage, { key = "wakeEarners", icon = "alarm-clock", title = "Auto Wake Earners",
    desc = "Keeps manual machines running" })
toggleRow(farmPage, { key = "powers", icon = "zap", title = "Auto Upgrade Powers",
    desc = "Spends investors on power levels" })
sectionLabel(farmPage, "Income")
toggleRow(farmPage, { key = "cashDrops", icon = "hand-coins", title = "Auto Collect Cash Drops",
    desc = "Redeems drops instantly, no walking" })
toggleRow(farmPage, { key = "phoneDeals", icon = "phone", title = "Auto Phone Deals",
    desc = "Accepts lucrative phone offers" })
toggleRow(farmPage, { key = "minigame", icon = "gamepad-2", title = "Auto Race Minigame",
    desc = "Instant 1st place reward (~5 min CD)" })
toggleRow(farmPage, { key = "harvest", icon = "citrus", title = "Auto Harvest Lemons",
    desc = "⚠ Teleports your character to fruit" })

-- ── Prestige tab ──
sectionLabel(prestigePage, "Prestige loops")
toggleRow(prestigePage, { key = "rebirth", icon = "refresh-cw", title = "Auto Rebirth",
    desc = "Rebirths when investors are available" })
toggleRow(prestigePage, { key = "evolve", icon = "dna", title = "Auto Evolve",
    desc = "Evolves at 100% progress" })
sectionLabel(prestigePage, "Danger zone")
toggleRow(prestigePage, { key = "ascend", icon = "crown", title = "Auto Ascend", danger = true, confirm = true,
    desc = "RESETS ALL PROGRESS — double-click to arm" })

-- ── Settings tab ──
sectionLabel(settingsPage, "Player")
toggleRow(settingsPage, { key = "antiAfk", icon = "shield-check", title = "Anti-AFK",
    desc = "Blocks the 20-minute idle kick" })
toggleRow(settingsPage, { key = "wsEnabled", icon = "footprints", title = "WalkSpeed Override",
    desc = "Applies the speed below every frame" })
sliderRow(settingsPage, { key = "wsValue", icon = "gauge", title = "WalkSpeed", min = 16, max = 120,
    desc = "Drag to adjust", suffix = " studs/s" })
sectionLabel(settingsPage, "Interface")
buttonRow(settingsPage, { icon = "move", title = "Toggle UI  —  RightShift",
    desc = "Hide / show this window", onClick = function() end })
buttonRow(settingsPage, { icon = "power", title = "Unload Lemon Hub", danger = true,
    desc = "Removes the GUI and stops all loops",
    onClick = function() getgenv().LemonHubV4.Destroy() end })

-- ══════════════ Minimize bubble ══════════════
local bubble = mk("TextButton", {
    BackgroundColor3 = T.Accent, Text = "", AutoButtonColor = false, Visible = false,
    AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 16, 0.5, 0),
    Size = UDim2.fromOffset(48, 48), Parent = gui,
}, { corner(24), stroke(0.6) })
local bubbleIc = icon("citrus", 24, T.AccentTxt, bubble)
bubbleIc.AnchorPoint = Vector2.new(0.5, 0.5)
bubbleIc.Position = UDim2.fromScale(0.5, 0.5)
makeDraggable(bubble, bubble)

local minimized = false
local function setMinimized(v)
    minimized = v
    if v then
        tween(win, TI_MED, { Size = UDim2.fromOffset(WIN_W, 0) })
        task.delay(0.2, function() if minimized then win.Visible = false end end)
        bubble.Visible = true
        bubble.Size = UDim2.fromOffset(0, 0)
        tween(bubble, TI_POP, { Size = UDim2.fromOffset(48, 48) })
    else
        win.Visible = true
        tween(win, TI_POP, { Size = UDim2.fromOffset(WIN_W, WIN_H) })
        bubble.Visible = false
    end
end
track(minBtn.MouseButton1Click:Connect(function() setMinimized(true) end))
local bubbleDownPos
track(bubble.MouseButton1Down:Connect(function(x, y) bubbleDownPos = Vector2.new(x, y) end))
track(bubble.MouseButton1Up:Connect(function(x, y)
    if bubbleDownPos and (Vector2.new(x, y) - bubbleDownPos).Magnitude < 6 then
        setMinimized(false)
    end
end))
track(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if minimized then setMinimized(false) else gui.Enabled = not gui.Enabled end
    end
end))

-- close button = minimize to bubble (unload lives in Settings)
track(closeBtn.MouseButton1Click:Connect(function() setMinimized(true) end))

-- open animation
win.Size = UDim2.fromOffset(WIN_W, 0)
tween(win, TI_POP, { Size = UDim2.fromOffset(WIN_W, WIN_H) })
dashTab.select()
print("[LemonHub] UI built")

-- ══════════════════════════════════════════
--        ASYNC GAME-MODULE BOOTSTRAP
-- ══════════════════════════════════════════
-- Every require runs in its own thread with a timeout, so a module
-- that hangs on require can never freeze the executor pipeline.
local G = {}          -- loaded game modules
local bootDone = false

local function tryRequireAsync(label, timeout, getter)
    local done, val = false, nil
    task.spawn(function()
        local ok, m = pcall(getter)
        if ok then val = m end
        done = true
    end)
    local t0 = os.clock()
    while not done and os.clock() - t0 < (timeout or 3) do
        task.wait(0.1)
    end
    if not done then print("[LemonHub] require TIMEOUT: " .. label) end
    return val
end

local POWER_NAMES = { "UpgradeStack", "BuyNext", "Manage", "WalkSpeed", "ClickFruitValue" }

local function fmt(v)
    if v == nil then return "—" end
    if G.Huge then
        local ok, s = pcall(G.Huge.formatAbbreviated, v)
        if ok and s then return tostring(s) end
    end
    return tostring(v)
end

-- ══════════════ Engine state ══════════════
local lastErr, lastErrAt = nil, 0
local function reportErr(tag, err)
    local key = tag .. tostring(err)
    if key == lastErr and os.clock() - lastErrAt < 10 then return end
    lastErr, lastErrAt = key, os.clock()
    log("⚠ " .. tag .. ": " .. tostring(err):sub(1, 80), T.Red)
end

-- fresh handles every call — tycoon instance changes on respawn
local function ctx()
    if not G.Tycoon then return nil end
    local ok, c = pcall(function()
        local t = G.Tycoon.getLocal()
        if not t then return nil end
        return {
            t    = t,
            inst = t.Instance,
            bal  = G.CompBalances and t:GetComponent(G.CompBalances) or nil,
            reb  = G.CompRebirth and t:GetComponent(G.CompRebirth) or nil,
            evo  = G.CompEvolution and t:GetComponent(G.CompEvolution) or nil,
            asc  = G.CompAscension and t:GetComponent(G.CompAscension) or nil,
            pow  = G.CompPowers and t:GetComponent(G.CompPowers) or nil,
            pho  = G.CompPhone and t:GetComponent(G.CompPhone) or nil,
        }
    end)
    if ok then return c end
    return nil
end

local function tycoonRemotes(c)
    if c and c.inst then
        local r = c.inst:FindFirstChild("Remotes")
        if r then return r end
    end
    return nil
end

-- ── Feature: buy tiles ──
local function runBuyTiles(c)
    if not c then return end
    local bought = 0
    for _, inst in ipairs(CollectionService:GetTagged("Tycoon.Purchase")) do
        if bought >= 6 then break end
        if inst:IsDescendantOf(c.inst)
        and inst:GetAttribute("Shown") == true
        and inst:GetAttribute("Purchased") ~= true then
            -- Purchase RemoteFunction: server-validated, silent no-op if unaffordable
            local rf = inst:FindFirstChild("Purchase")
            if rf and rf:IsA("RemoteFunction") then
                task.spawn(function()
                    local ok, res = pcall(function() return rf:InvokeServer(false) end)
                    if ok and res == true then
                        log("Bought tile: " .. inst.Name, T.Green)
                    end
                end)
                bought += 1
            end
        end
    end
end

-- ── Feature: upgrade earners (exponential bulk-buy via raw remote) ──
local earnerBulk = {}   -- inst -> last successful count (start point)
local function runUpgradeEarners(c)
    if not c then return end
    for _, inst in ipairs(CollectionService:GetTagged("Tycoon.Earner")) do
        if inst:IsDescendantOf(c.inst) then
            local rf = inst:FindFirstChild("Upgrade")
            if rf and rf:IsA("RemoteFunction") then
                task.spawn(function()
                    -- exponential doubling: buy 1, 2, 4, 8... until "cannot afford"
                    local total = 0
                    local count = earnerBulk[inst] or 1
                    while alive and State.upgradeEarners do
                        local ok = pcall(function() return rf:InvokeServer(count) end)
                        if ok then
                            total += count
                            count *= 2
                        else
                            count = math.max(1, math.floor(count / 2))
                            break
                        end
                        if total > 4096 then break end
                        task.wait()
                    end
                    earnerBulk[inst] = math.max(1, math.floor(count / 2))
                    if total > 0 then
                        log(("Upgraded %s +%d levels"):format(inst.Name, total), T.Green)
                    end
                end)
            end
        end
    end
end

-- ── Feature: wake earners ──
local function runWakeEarners(c)
    if not c then return end
    local remotes = tycoonRemotes(c)
    if not remotes then return end
    local rf = remotes:FindFirstChild("WakeIncomeStream")
    if not rf then return end
    for _, inst in ipairs(CollectionService:GetTagged("Tycoon.Earner")) do
        if inst:IsDescendantOf(c.inst) then
            task.spawn(function() pcall(function() rf:InvokeServer(inst.Name) end) end)
        end
    end
end

-- ── Feature: powers (cost INVESTORS, not cash — server validates) ──
local function runPowers(c)
    if not c then return end
    if c.pow and c.bal then
        local ok, investors = pcall(function() return c.bal:GetInvestors() end)
        if ok then
            for _, name in ipairs(POWER_NAMES) do
                pcall(function()
                    local lvl, max = c.pow:GetLevel(name), c.pow:GetMaxLevel(name)
                    if lvl and max and lvl < max then
                        local price = c.pow:GetUpgradePrice(name)
                        if price and price <= investors then
                            c.pow:UpgradeAsync(name)
                            log("Power up: " .. name, T.Violet)
                        end
                    end
                end)
            end
            return
        end
    end
    -- raw fallback: server rejects if unaffordable
    local remotes = tycoonRemotes(c)
    local rf = remotes and remotes:FindFirstChild("UpgradePowerLevel")
    if rf then
        for _, name in ipairs(POWER_NAMES) do
            task.spawn(function() pcall(function() rf:InvokeServer(name) end) end)
        end
    end
end

-- ── Feature: phone deals ──
local function runPhone(c)
    if not c then return end
    if c.pho then
        local handled = pcall(function()
            if c.pho:GetCurrentOffer() ~= nil then
                c.pho:AcceptOffer()
                log("Accepted phone deal", T.Green)
            end
        end)
        if handled then return end
    end
    local remotes = tycoonRemotes(c)
    local re = remotes and remotes:FindFirstChild("PhoneOffer")
    if re and re:IsA("RemoteEvent") then
        pcall(function() re:FireServer("Accept") end)
    end
end

-- ── Feature: rebirth / evolve / ascend ──
local function runRebirth(c)
    if not c then return end
    if c.reb and G.Huge then
        local eligible = false
        pcall(function() eligible = G.Huge.one < c.reb:GetPotentialInvestors() end)
        if not eligible then return end
    end
    local remotes = tycoonRemotes(c)
    local rf = remotes and remotes:FindFirstChild("Rebirth")
    if rf then
        task.spawn(function() pcall(function() rf:InvokeServer() end) end)
    end
end

local function runEvolve(c)
    if not c then return end
    if c.evo then
        local eligible = true
        pcall(function() eligible = (c.evo:GetEvolutionProgress() or 0) >= 1 end)
        if not eligible then return end
    end
    local remotes = tycoonRemotes(c)
    local rf = remotes and remotes:FindFirstChild("Evolve")
    if rf then
        task.spawn(function() pcall(function() rf:InvokeServer() end) end)
    end
end

local function runAscend(c)
    if not c then return end
    if c.asc then
        local eligible = false
        pcall(function() eligible = (c.asc:GetAscension() or 0) >= 1 and c.asc:IsDiscovered() end)
        if not eligible then return end
    end
    local remotes = tycoonRemotes(c)
    local rf = remotes and remotes:FindFirstChild("Ascend")
    if rf then
        task.spawn(function() pcall(function() rf:InvokeServer() end) end)
    end
end

-- ── Feature: race minigame exploit ──
local raceNext = 0
local function runMinigame()
    if not G.raceStart or not G.raceEnd then return end
    if os.clock() < raceNext then return end
    raceNext = os.clock() + 20 -- assume cooldown until proven otherwise
    task.spawn(function()
        local ok, res = pcall(function() return G.raceStart:InvokeServer() end)
        if ok and res ~= nil then
            task.wait(0.4)
            pcall(function() G.raceEnd:InvokeServer(1) end)
            raceNext = os.clock() + 310
            log("Race minigame: 1st place claimed 🏆", T.Accent)
            toast("Minigame reward", "Fake 1st place payout collected", "trophy", T.Accent)
        end
    end)
end

-- ── Feature: harvest lemons ──
local harvestIdx = 0
local function collectFruit(c)
    local cds = {}
    for _, tree in ipairs(workspace:GetChildren()) do
        if tree.Name == "LemonTree" then
            for _, d in ipairs(tree:GetDescendants()) do
                if d:IsA("ClickDetector") then table.insert(cds, d) end
            end
        end
    end
    if c and c.inst then
        for _, d in ipairs(c.inst:GetDescendants()) do
            if d:IsA("ClickDetector") and d.Parent and d.Parent.Name == "ClickPart" then
                table.insert(cds, d)
            end
        end
    end
    return cds
end
local function runHarvest(c)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local cds = collectFruit(c)
    if #cds == 0 then return end
    harvestIdx = (harvestIdx % #cds) + 1
    local target = cds[harvestIdx]
    local part = target.Parent
    if not (part and part:IsA("BasePart")) then return end
    hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
    task.wait(0.15)
    local pos = hrp.Position
    for _, cd in ipairs(cds) do
        local p = cd.Parent
        if p and p:IsA("BasePart") and (p.Position - pos).Magnitude <= 15 then
            pcall(function() fireclickdetector(cd) end)
        end
    end
    harvestIdx = harvestIdx + 7 -- skip just-harvested neighbours
end

-- ── Anti-AFK ──
track(LP.Idled:Connect(function()
    if State.antiAfk then
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end
end))

-- ── WalkSpeed enforce ──
track(RunService.Heartbeat:Connect(function()
    if State.wsEnabled and alive then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= State.wsValue then hum.WalkSpeed = State.wsValue end
    end
end))

-- ── Scheduler ──
local features = {
    { key = "buyTiles",       fn = runBuyTiles,       every = 1.2 },
    { key = "upgradeEarners", fn = runUpgradeEarners, every = 2.0 },
    { key = "wakeEarners",    fn = runWakeEarners,    every = 5.0 },
    { key = "powers",         fn = runPowers,         every = 3.0 },
    { key = "phoneDeals",     fn = runPhone,          every = 4.0 },
    { key = "rebirth",        fn = runRebirth,        every = 5.0 },
    { key = "evolve",         fn = runEvolve,         every = 5.0 },
    { key = "ascend",         fn = runAscend,         every = 10.0 },
    { key = "minigame",       fn = runMinigame,       every = 5.0 },
    { key = "harvest",        fn = runHarvest,        every = 1.0 },
}
for _, f in ipairs(features) do f.nextRun = 0 end

-- ══════════════ Boot + loops (all async) ══════════════
task.spawn(function()
    -- load game modules with timeouts
    G.Tycoon = tryRequireAsync("Tycoon", 3, function() return require(RS.Modules.Tycoon.Tycoon) end)
    G.Huge   = tryRequireAsync("Huge", 3, function() return require(RS.Modules.Huge) end)
    G.CompBalances  = tryRequireAsync("Balances", 3, function() return require(RS.Modules.Tycoon.Component.TycoonBalances) end)
    G.CompRebirth   = tryRequireAsync("Rebirth", 3, function() return require(RS.Modules.Tycoon.Component.Client.ClientTycoonRebirth) end)
    G.CompEvolution = tryRequireAsync("Evolution", 3, function() return require(RS.Modules.Tycoon.Component.Client.ClientTycoonEvolution) end)
    G.CompAscension = tryRequireAsync("Ascension", 3, function() return require(RS.Modules.Tycoon.Component.Client.ClientTycoonAscension) end)
    G.CompPowers    = tryRequireAsync("Powers", 3, function() return require(RS.Modules.Tycoon.Component.Client.ClientTycoonPowers) end)
    G.CompPhone     = tryRequireAsync("Phone", 3, function() return require(RS.Modules.Tycoon.Component.Client.ClientTycoonPhoneOffers) end)
    local RemoteRequest = tryRequireAsync("RemoteRequest", 3, function() return require(RS.Core.RemoteRequest) end)
    local RemoteSignal  = tryRequireAsync("RemoteSignal", 3, function() return require(RS.Core.RemoteSignal) end)

    if RemoteRequest then
        pcall(function() G.raceStart = RemoteRequest.new("MinigameRaceService.Start") end)
        pcall(function() G.raceEnd = RemoteRequest.new("MinigameRaceService.End") end)
        pcall(function() G.redeem = RemoteRequest.new("CashDropService.Redeem") end)
    end
    -- cash drops: event-driven redeem
    if RemoteSignal and G.redeem then
        pcall(function()
            local sig = RemoteSignal.new("CashDropService.New")
            local connFn
            for _, m in ipairs({ "Connect", "connect" }) do
                local okI, f = pcall(function() return sig[m] end)
                if okI and type(f) == "function" then connFn = f break end
            end
            if connFn then
                track(connFn(sig, function(id)
                    if State.cashDrops and alive then
                        task.wait(0.2)
                        pcall(function() G.redeem:InvokeServer(id) end)
                        log("Cash drop redeemed", T.Green)
                    end
                end))
                print("[LemonHub] cash drop listener attached")
            end
        end)
    end

    local loaded = 0
    for _ in pairs(G) do loaded += 1 end
    bootDone = true
    print("[LemonHub] boot done, modules loaded: " .. loaded)
    log("Engine ready (" .. loaded .. " modules)", T.Green)

    -- main scheduler loop
    while alive do
        local now = os.clock()
        local c = nil
        for _, f in ipairs(features) do
            if State[f.key] and now >= f.nextRun then
                if c == nil then c = ctx() or false end
                f.nextRun = now + f.every
                if c then
                    local ok, err = pcall(f.fn, c)
                    if not ok then reportErr(f.key, err) end
                end
            end
        end
        task.wait(0.25)
    end
end)

-- ── Stats loop ──
task.spawn(function()
    local lastCash, earned = nil, nil
    local windowEarned, windowT, rateStr = nil, os.clock(), "…"
    local lastRebirths, lastEvolves, lastAscension = nil, nil, nil
    while alive do
        if bootDone then
            local c = ctx()
            if c and c.bal then
                pcall(function()
                    local cash = c.bal:GetCash()
                    statValues["Cash"].Text = "$" .. fmt(cash)
                    statValues["Investors"].Text = fmt(c.bal:GetInvestors())
                    pcall(function()
                        if lastCash ~= nil and lastCash < cash then
                            local delta = cash - lastCash
                            earned = earned ~= nil and (earned + delta) or delta
                        end
                        lastCash = cash
                        if earned ~= nil then
                            statValues["Session earned"].Text = "$" .. fmt(earned)
                            if os.clock() - windowT >= 60 then
                                if windowEarned ~= nil then
                                    rateStr = "$" .. fmt(earned - windowEarned) .. "/min"
                                end
                                windowEarned = earned
                                windowT = os.clock()
                            end
                            statValues["Rate"].Text = rateStr
                        end
                    end)
                end)
                pcall(function()
                    if c.reb then
                        local rs = fmt(c.reb:GetRebirths())
                        if lastRebirths and rs ~= lastRebirths then
                            toast("Rebirthed!", "Investor count increased", "refresh-cw", T.Green)
                            log("Rebirthed → " .. rs .. " total", T.Accent)
                        end
                        lastRebirths = rs
                        statValues["Rebirths"].Text = rs
                    end
                    if c.evo then
                        local e = c.evo:GetTotalEvolves()
                        if lastEvolves and e ~= lastEvolves then
                            toast("Evolved!", "Evolution " .. tostring(e), "dna", T.Violet)
                            log("Evolved → " .. tostring(e), T.Violet)
                        end
                        lastEvolves = e
                    end
                    if c.asc then
                        local a = c.asc:GetAscension()
                        if lastAscension and a ~= lastAscension then
                            toast("Ascended!", "Ascension " .. tostring(a), "crown", T.Accent)
                            log("ASCENDED → " .. tostring(a), T.Accent)
                        end
                        lastAscension = a
                    end
                end)
            end
            if statValues["Race cooldown"] then
                local left = raceNext - os.clock()
                statValues["Race cooldown"].Text =
                    (not State.minigame) and "off"
                    or (left <= 0 and "ready…"
                    or ("%d:%02d"):format(math.floor(left / 60), math.floor(left % 60)))
            end
        end
        local active = 0
        for _, f in ipairs(features) do if State[f.key] then active += 1 end end
        statusDot.BackgroundColor3 = active > 0 and T.Green or T.TextFaint
        statusLbl.Text = not bootDone and "booting" or (active > 0 and (active .. " active") or "idle")
        task.wait(1)
    end
end)

-- ══════════════ Public handle / destroy ══════════════
getgenv().LemonHubV4 = {
    Destroy = function()
        alive = false
        for _, con in ipairs(connections) do
            pcall(function() con:Disconnect() end)
        end
        pcall(function() gui:Destroy() end)
        getgenv().LemonHubV4 = nil
    end,
    State = State,
    Toggles = Toggles,
}

toast("Lemon Hub v4.1", "Loaded — RightShift to toggle UI", "citrus", T.Accent)
print("[LemonHub] v4.1 ready")
