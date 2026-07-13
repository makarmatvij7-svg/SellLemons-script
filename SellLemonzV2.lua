--==================================================================
-- 🍋 LEMON HUB MAXIMUM — The Final Form
-- Every auto-farm loop, remote call, and state toggle preserved.
-- Visual layer rebuilt with particle engine, mesh gradients, spring
-- physics, ripple effects, cursor trails, and ambient lighting.
-- RightShift hides, — minimizes, ✕ closes.
-- _G.LemonFarm.Destroy() removes everything.
--
-- INTEGRATED: Cobalt-generated OrchardPlot.Harvest auto-harvest
-- for ALL tycoon orchard plots.
--==================================================================
if _G.LemonFarm and _G.LemonFarm.Destroy then pcall(_G.LemonFarm.Destroy) end

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local POWERS = {"UpgradeStack","BuyNext","Manage","WalkSpeed","ClickFruitValue","AutoFruit"}

-- ================================================================
-- STATE (PRESERVED EXACTLY + harvest)
-- ================================================================
local S = {
    upgrade=false, buy=false, drops=false, click=false,
    rebirth=false, ascend=false, evolve=false,
    powers=false, wake=false, offers=false, offline=false,
    mini=false, antiafk=false, harvest=false, remotebuy=false, autoeat=false, autopowers=false, perfmode=false,
    cUp=0, cBuy=0, cDrop=0, cMini=0, cHarvest=0, cRemoteBuy=0, cAutoEat=0, cAutoPowers=0
}

-- ================================================================
-- DESIGN SYSTEM — Maximum Overdrive Palette
-- ================================================================
local PAL = {
    void        = Color3.fromRGB(6, 7, 10),
    bg          = Color3.fromRGB(12, 14, 20),
    bgGlass     = Color3.fromRGB(18, 21, 30),
    bgGlass2    = Color3.fromRGB(24, 28, 40),
    surface     = Color3.fromRGB(32, 36, 52),
    surfaceLit  = Color3.fromRGB(42, 48, 68),
    surfaceHot  = Color3.fromRGB(52, 60, 85),
    txt         = Color3.fromRGB(248, 250, 252),
    txtDim      = Color3.fromRGB(130, 138, 155),
    accent      = Color3.fromRGB(170, 240, 100),
    accent2     = Color3.fromRGB(255, 210, 70),
    accent3     = Color3.fromRGB(100, 220, 255),
    accentHot   = Color3.fromRGB(255, 90, 80),
    border      = Color3.fromRGB(55, 60, 80),
    borderGlow  = Color3.fromRGB(140, 230, 100),
    shadow      = Color3.fromRGB(0, 0, 0),
    ledOff      = Color3.fromRGB(60, 65, 80),
    ledOn       = Color3.fromRGB(170, 240, 100),
}

-- ================================================================
-- UTILITY FACTORY
-- ================================================================
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = p
    return c
end

local function pad(p, t, b, l, r)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t)
    u.PaddingBottom = UDim.new(0, b)
    u.PaddingLeft   = UDim.new(0, l)
    u.PaddingRight  = UDim.new(0, r)
    u.Parent = p
    return u
end

local function stroke(p, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = col or PAL.border
    s.Thickness = thick or 1
    s.Transparency = trans or 0.3
    s.Parent = p
    return s
end

local function gradient(p, seq, rot)
    local g = Instance.new("UIGradient")
    g.Color = seq
    g.Rotation = rot or 0
    g.Parent = p
    return g
end

local function shadow(p, off, blur, trans, col)
    local sh = Instance.new("ImageLabel")
    sh.BackgroundTransparency = 1
    sh.Image = "rbxassetid://5554236805"
    sh.ImageColor3 = col or PAL.shadow
    sh.ImageTransparency = trans or 0.5
    sh.ScaleType = Enum.ScaleType.Slice
    sh.SliceCenter = Rect.new(23, 23, 277, 277)
    sh.Size = UDim2.new(1, blur*2, 1, blur*2)
    sh.Position = UDim2.fromOffset(-blur, -blur+off)
    sh.ZIndex = p.ZIndex - 1
    sh.Parent = p
    return sh
end

local function innerGlow(p, col, trans)
    local g = Instance.new("Frame")
    g.Size = UDim2.new(1, 0, 1, 0)
    g.BackgroundTransparency = 1
    g.ZIndex = p.ZIndex + 1
    g.Parent = p
    local gr = Instance.new("UIGradient")
    gr.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, col or PAL.accent),
        ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, col or PAL.accent)
    }
    gr.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, trans or 0.9),
        NumberSequenceKeypoint.new(0.5, 1),
        NumberSequenceKeypoint.new(1, trans or 0.9)
    }
    gr.Rotation = 90
    gr.Parent = g
    return g
end

-- ================================================================
-- ROOT GUI WITH ENTRANCE ANIMATION
-- ================================================================
local parent = (gethui and gethui()) or game:GetService("CoreGui")
local gui = Instance.new("ScreenGui")
gui.Name = "LemonHubMax"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = parent

-- Ambient background orbs (behind everything)
local ambient = Instance.new("Frame")
ambient.Size = UDim2.new(1, 0, 1, 0)
ambient.BackgroundTransparency = 1
ambient.ZIndex = 1
ambient.Parent = gui

local orb1 = Instance.new("Frame")
orb1.Size = UDim2.fromOffset(400, 400)
orb1.Position = UDim2.fromScale(0.2, 0.3)
orb1.BackgroundColor3 = PAL.accent
orb1.BackgroundTransparency = 0.92
orb1.BorderSizePixel = 0
orb1.ZIndex = 1
orb1.Parent = ambient
corner(orb1, 200)

local orb2 = Instance.new("Frame")
orb2.Size = UDim2.fromOffset(300, 300)
orb2.Position = UDim2.fromScale(0.7, 0.6)
orb2.BackgroundColor3 = PAL.accent2
orb2.BackgroundTransparency = 0.9
orb2.BorderSizePixel = 0
orb2.ZIndex = 1
orb2.Parent = ambient
corner(orb2, 150)

local orb3 = Instance.new("Frame")
orb3.Size = UDim2.fromOffset(250, 250)
orb3.Position = UDim2.fromScale(0.5, 0.2)
orb3.BackgroundColor3 = PAL.accent3
orb3.BackgroundTransparency = 0.93
orb3.BorderSizePixel = 0
orb3.ZIndex = 1
orb3.Parent = ambient
corner(orb3, 125)

-- Parallax state (mouse-driven depth offset, smoothed)
local parX, parY = 0, 0
local parTX, parTY = 0, 0

-- Animate orbs (base drift + parallax layers at different depths)
local orbTime = 0
-- Orb parallax: 30fps throttle to reduce CPU load
local orbLastUpdate = 0
local orbConn = RunService.Heartbeat:Connect(function(dt)
    local now = tick()
    if now - orbLastUpdate < 0.033 then return end
    orbLastUpdate = now
    orbTime += dt

    -- Smooth the parallax target toward the raw mouse offset (spring-like lag)
    parX += (parTX - parX) * math.min(dt * 6, 1)
    parY += (parTY - parY) * math.min(dt * 6, 1)

    -- Each orb sits at a different "depth" so they drift at different rates
    orb1.Position = UDim2.fromScale(
        0.2 + math.sin(orbTime*0.3)*0.08 + parX * 0.020,
        0.3 + math.cos(orbTime*0.2)*0.06 + parY * 0.020
    )
    orb2.Position = UDim2.fromScale(
        0.7 + math.cos(orbTime*0.25)*0.06 - parX * 0.035,
        0.6 + math.sin(orbTime*0.35)*0.08 - parY * 0.035
    )
    orb3.Position = UDim2.fromScale(
        0.5 + math.sin(orbTime*0.4)*0.05 + parX * 0.012,
        0.2 + math.cos(orbTime*0.3)*0.07 - parY * 0.012
    )
end)

-- Main panel
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(560, 400)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = PAL.bgGlass
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.ZIndex = 10
main.Parent = gui
corner(main, 24)

-- Entrance animation
main.Size = UDim2.fromOffset(0, 0)
main.BackgroundTransparency = 1
TweenService:Create(main, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0.05), {
    Size = UDim2.fromOffset(560, 400),
    BackgroundTransparency = 0.1
}):Play()

-- Multi-layer border glow
local glow1 = stroke(main, PAL.accent, 2.5, 0.85)
local glow1g = gradient(glow1, ColorSequence.new(PAL.accent, PAL.accent2), 0)
local glow2 = stroke(main, PAL.accent3, 1.5, 0.9)
local glow2g = gradient(glow2, ColorSequence.new(PAL.accent3, PAL.accent), 90)

-- Deep shadow
shadow(main, 8, 40, 0.6)

-- Frosted glass layers (fake backdrop blur via stacked soft-edge tints)
local frost1 = Instance.new("Frame")
frost1.Size = UDim2.new(1, 0, 1, 0)
frost1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frost1.BackgroundTransparency = 0.97
frost1.BorderSizePixel = 0
frost1.ZIndex = 1
frost1.Parent = main
corner(frost1, 24)
local frost1g = gradient(frost1, ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
    ColorSequenceKeypoint.new(0.4, Color3.new(1,1,1)),
    ColorSequenceKeypoint.new(1, Color3.new(0,0,0))
}, 90)
frost1g.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.4),
    NumberSequenceKeypoint.new(0.5, 0.85),
    NumberSequenceKeypoint.new(1, 1)
}

-- Edge highlight sliver (top glass rim catching light)
local rim = Instance.new("Frame")
rim.Size = UDim2.new(1, -4, 0, 1)
rim.Position = UDim2.fromOffset(2, 1)
rim.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
rim.BackgroundTransparency = 0.6
rim.BorderSizePixel = 0
rim.ZIndex = 25
rim.Parent = main
gradient(rim, ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
    ColorSequenceKeypoint.new(0.5, PAL.accent),
    ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
}, 0)

-- Particle canvas
local particleCanvas = Instance.new("Frame")
particleCanvas.Size = UDim2.new(1, 0, 1, 0)
particleCanvas.BackgroundTransparency = 1
particleCanvas.ZIndex = 2
particleCanvas.Parent = main

-- ================================================================
-- HEADER — Living Mesh Gradient
-- ================================================================
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 72)
header.BackgroundColor3 = PAL.bgGlass2
header.BackgroundTransparency = 0.15
header.BorderSizePixel = 0
header.ZIndex = 20
header.Parent = main
corner(header, 24)

local hfix = Instance.new("Frame")
hfix.Size = UDim2.new(1, 0, 0, 24)
hfix.Position = UDim2.new(0, 0, 1, -24)
hfix.BackgroundColor3 = PAL.bgGlass2
hfix.BackgroundTransparency = 0.15
hfix.BorderSizePixel = 0
hfix.ZIndex = 20
hfix.Parent = header

-- Layer 1: Slow rotating warm gradient
local hgrad1 = Instance.new("Frame")
hgrad1.Size = UDim2.new(1, 0, 1, 0)
hgrad1.BackgroundTransparency = 1
hgrad1.ZIndex = 21
hgrad1.Parent = header
local hg1 = gradient(hgrad1, ColorSequence.new{
    ColorSequenceKeypoint.new(0, PAL.accent),
    ColorSequenceKeypoint.new(0.5, PAL.accent2),
    ColorSequenceKeypoint.new(1, PAL.accent)
}, 0)
hg1.Transparency = NumberSequence.new(0.88, 0.95)

-- Layer 2: Fast rotating cool gradient
local hgrad2 = Instance.new("Frame")
hgrad2.Size = UDim2.new(1, 0, 1, 0)
hgrad2.BackgroundTransparency = 1
hgrad2.ZIndex = 21
hgrad2.Parent = header
local hg2 = gradient(hgrad2, ColorSequence.new{
    ColorSequenceKeypoint.new(0, PAL.accent3),
    ColorSequenceKeypoint.new(0.5, PAL.accent),
    ColorSequenceKeypoint.new(1, PAL.accent3)
}, 45)
hg2.Transparency = NumberSequence.new(0.9, 0.96)

-- Layer 3: Radial accent burst
local hgrad3 = Instance.new("Frame")
hgrad3.Size = UDim2.new(1, 0, 1, 0)
hgrad3.BackgroundTransparency = 1
hgrad3.ZIndex = 21
hgrad3.Parent = header
local hg3 = gradient(hgrad3, ColorSequence.new{
    ColorSequenceKeypoint.new(0, PAL.accent2),
    ColorSequenceKeypoint.new(1, PAL.bgGlass2)
}, 135)
hg3.Transparency = NumberSequence.new(0.85, 0.98)

-- Animate header gradients
local hTime = 0
-- Header gradients: 30fps throttle
local hLastUpdate = 0
local hConn = RunService.Heartbeat:Connect(function(dt)
    local now = tick()
    if now - hLastUpdate < 0.033 then return end
    hLastUpdate = now
    hTime += dt
    hg1.Rotation = (hTime * 8) % 360 + parX * 6
    hg2.Rotation = (hTime * 15 + 45) % 360 - parY * 8
    hg3.Rotation = (hTime * 5 + 135) % 360 + parX * 4
    hg1.Offset = Vector2.new(parX * 0.03, parY * 0.02)
    hg2.Offset = Vector2.new(-parX * 0.02, -parY * 0.03)
end)

-- Logo orb with pulse
local logoOrb = Instance.new("Frame")
logoOrb.Size = UDim2.fromOffset(48, 48)
logoOrb.Position = UDim2.fromOffset(18, 12)
logoOrb.BackgroundColor3 = PAL.accent
logoOrb.BorderSizePixel = 0
logoOrb.ZIndex = 22
logoOrb.Parent = header
corner(logoOrb, 14)
shadow(logoOrb, 0, 20, 0.5, PAL.accent)

local logoPulse = Instance.new("Frame")
logoPulse.Size = UDim2.new(1, 0, 1, 0)
logoPulse.BackgroundColor3 = PAL.accent
logoPulse.BackgroundTransparency = 0.7
logoPulse.BorderSizePixel = 0
logoPulse.ZIndex = 21
logoPulse.Parent = logoOrb
corner(logoPulse, 14)

-- Pulse animation
-- Logo pulse: 30fps throttle
local pulseTime = 0
local pulseLastUpdate = 0
local pulseConn = RunService.Heartbeat:Connect(function(dt)
    local now = tick()
    if now - pulseLastUpdate < 0.033 then return end
    pulseLastUpdate = now
    pulseTime += dt
    local s = 1 + math.sin(pulseTime * 3) * 0.15
    logoPulse.Size = UDim2.fromScale(s, s)
    logoPulse.Position = UDim2.fromScale(0.5 - s*0.5, 0.5 - s*0.5)
    logoPulse.BackgroundTransparency = 0.6 + math.sin(pulseTime * 3) * 0.2
end)

local logoIcon = Instance.new("TextLabel")
logoIcon.Size = UDim2.fromScale(1, 1)
logoIcon.BackgroundTransparency = 1
logoIcon.Font = Enum.Font.GothamBold
logoIcon.Text = "🍋"
logoIcon.TextSize = 26
logoIcon.ZIndex = 23
logoIcon.Parent = logoOrb

-- Title with gradient
local titleC = Instance.new("TextLabel")
titleC.Size = UDim2.fromOffset(220, 26)
titleC.Position = UDim2.fromOffset(76, 14)
titleC.BackgroundTransparency = 1
titleC.Font = Enum.Font.GothamBold
titleC.TextSize = 22
titleC.TextColor3 = PAL.txt
titleC.Text = "Lemon Hub"
titleC.TextXAlignment = Enum.TextXAlignment.Left
titleC.ZIndex = 22
titleC.Parent = header
gradient(titleC, ColorSequence.new(PAL.accent2, PAL.accent), 0)

-- Cash label
local cashL = Instance.new("TextLabel")
cashL.Size = UDim2.fromOffset(340, 18)
cashL.Position = UDim2.fromOffset(76, 40)
cashL.BackgroundTransparency = 1
cashL.Font = Enum.Font.GothamMedium
cashL.TextSize = 13
cashL.TextColor3 = PAL.txtDim
cashL.Text = "—"
cashL.TextXAlignment = Enum.TextXAlignment.Left
cashL.ZIndex = 22
cashL.Parent = header

-- Window controls with micro-interactions
local function winBtn(txt, x, col, rotAnim)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(34, 34)
    b.Position = UDim2.new(1, x, 0, 19)
    b.BackgroundColor3 = PAL.surface
    b.Text = txt
    b.TextColor3 = PAL.txt
    b.Font = Enum.Font.GothamBold
    b.TextSize = 15
    b.AutoButtonColor = false
    b.ZIndex = 22
    b.Parent = header
    corner(b, 10)
    stroke(b, PAL.border, 1, 0.4)

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundColor3 = PAL.surfaceLit, Size = UDim2.fromOffset(36, 36)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundColor3 = PAL.surface, Size = UDim2.fromOffset(34, 34)}):Play()
    end)
    b.MouseButton1Down:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = PAL.bgGlass, Size = UDim2.fromOffset(31, 31)}):Play()
        if rotAnim then
            TweenService:Create(b, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = 90}):Play()
        end
    end)
    b.MouseButton1Up:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundColor3 = PAL.surfaceLit, Size = UDim2.fromOffset(34, 34)}):Play()
        if rotAnim then
            TweenService:Create(b, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = 0}):Play()
        end
    end)
    return b
end

local closeB = winBtn("✕", -48, PAL.accentHot, true)
local minB   = winBtn("—", -90)

-- ================================================================
-- BODY
-- ================================================================
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -72)
body.Position = UDim2.fromOffset(0, 72)
body.BackgroundTransparency = 1
body.ZIndex = 10
body.Parent = main

-- Sidebar with glass depth
local side = Instance.new("Frame")
side.Size = UDim2.new(0, 160, 1, 0)
side.BackgroundColor3 = PAL.bgGlass
side.BackgroundTransparency = 0.25
side.BorderSizePixel = 0
side.ZIndex = 11
side.Parent = body
pad(side, 16, 16, 14, 14)
local sl = Instance.new("UIListLayout", side)
sl.Padding = UDim.new(0, 8)
sl.SortOrder = Enum.SortOrder.LayoutOrder

-- Content area
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -160, 1, 0)
content.Position = UDim2.fromOffset(160, 0)
content.BackgroundTransparency = 1
content.ZIndex = 11
content.Parent = body

-- Custom scrollbar track
local scrollTrack = Instance.new("Frame")
scrollTrack.Size = UDim2.new(0, 6, 1, -20)
scrollTrack.Position = UDim2.new(1, -10, 0, 10)
scrollTrack.BackgroundColor3 = PAL.bgGlass2
scrollTrack.BackgroundTransparency = 0.5
scrollTrack.BorderSizePixel = 0
scrollTrack.ZIndex = 15
scrollTrack.Parent = content
corner(scrollTrack, 3)

-- ================================================================
-- CURSOR GLOW TRAIL
-- ================================================================
local cursorGlow = Instance.new("Frame")
cursorGlow.Size = UDim2.fromOffset(20, 20)
cursorGlow.BackgroundColor3 = PAL.accent
cursorGlow.BackgroundTransparency = 0.85
cursorGlow.BorderSizePixel = 0
cursorGlow.ZIndex = 50
cursorGlow.Parent = main
corner(cursorGlow, 10)
shadow(cursorGlow, 0, 12, 0.7, PAL.accent)

-- Cursor tracking: direct position assignment (no tween) + 30fps throttle
local cursorLastUpdate = 0
local cursorConn = RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - cursorLastUpdate < 0.033 then return end -- 30fps cap
    cursorLastUpdate = now

    local mouse = lp:GetMouse()
    if not mouse then return end
    local absPos = main.AbsolutePosition
    local absSize = main.AbsoluteSize
    local relX = mouse.X - absPos.X
    local relY = mouse.Y - absPos.Y
    if relX >= 0 and relX <= absSize.X and relY >= 0 and relY <= absSize.Y then
        cursorGlow.Visible = true
        cursorGlow.Position = UDim2.fromOffset(relX - 10, relY - 10)
        if absSize.X > 0 and absSize.Y > 0 then
            parTX = ((relX / absSize.X) - 0.5) * 2
            parTY = ((relY / absSize.Y) - 0.5) * 2
        end
    else
        cursorGlow.Visible = false
        parTX, parTY = 0, 0
    end
end)

-- ================================================================
-- TABS SYSTEM — With sliding indicator & staggered reveals
-- ================================================================
local tabs = {}
local pages = {}
local activeTab = nil

local function selectTab(name)
    activeTab = name
    for n, m in pairs(tabs) do
        local on = (n == name)
        TweenService:Create(m.btn, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundColor3 = on and PAL.surface or PAL.bgGlass,
            BackgroundTransparency = on and 0.05 or 0.25
        }):Play()
        TweenService:Create(m.lbl, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = on and PAL.txt or PAL.txtDim}):Play()
        TweenService:Create(m.icon, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = on and PAL.accent or PAL.txtDim}):Play()

        -- Slide indicator
        if on then
            TweenService:Create(m.accent, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
                Position = UDim2.fromOffset(8, 12),
                Size = UDim2.fromOffset(4, 20)
            }):Play()
            m.accent.Visible = true
        else
            TweenService:Create(m.accent, TweenInfo.new(0.2), {
                Position = UDim2.fromOffset(8, 22),
                Size = UDim2.fromOffset(4, 0)
            }):Play()
            task.delay(0.2, function() if activeTab ~= n then m.accent.Visible = false end end)
        end
    end

    for n, p in pairs(pages) do
        if n == name then
            p.Visible = true
            p.Position = UDim2.fromOffset(24, 0)
            p.ScrollBarImageTransparency = 0.3
            TweenService:Create(p, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.fromOffset(0, 0)
            }):Play()
            -- Stagger children in with a gentle settle
            for i, child in ipairs(p:GetChildren()) do
                if child:IsA("GuiObject") and child ~= p:FindFirstChildOfClass("UIListLayout") and child ~= p:FindFirstChildOfClass("UIPadding") then
                    local origTrans = child.BackgroundTransparency
                    child.Position = child.Position + UDim2.fromOffset(0, 12)
                    child.BackgroundTransparency = math.min(origTrans + 0.35, 1)
                    local targetPos = child.Position - UDim2.fromOffset(0, 12)
                    TweenService:Create(child, TweenInfo.new(0.4 + i*0.045, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Position = targetPos,
                        BackgroundTransparency = origTrans
                    }):Play()
                end
            end
        else
            p.Visible = false
        end
    end
end

local tabOrder = 0
local function makeTab(name, icon)
    tabOrder += 1
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 48)
    b.BackgroundColor3 = PAL.bgGlass
    b.BackgroundTransparency = 0.25
    b.AutoButtonColor = false
    b.Text = ""
    b.LayoutOrder = tabOrder
    b.ZIndex = 12
    b.Parent = side
    corner(b, 12)

    local acc = Instance.new("Frame")
    acc.Size = UDim2.fromOffset(4, 0)
    acc.Position = UDim2.fromOffset(8, 22)
    acc.BackgroundColor3 = PAL.accent
    acc.BorderSizePixel = 0
    acc.Visible = false
    acc.ZIndex = 13
    acc.Parent = b
    corner(acc, 2)

    local ic = Instance.new("TextLabel")
    ic.Size = UDim2.fromOffset(26, 26)
    ic.Position = UDim2.fromOffset(20, 11)
    ic.BackgroundTransparency = 1
    ic.Font = Enum.Font.GothamBold
    ic.TextSize = 18
    ic.TextColor3 = PAL.txtDim
    ic.Text = icon
    ic.ZIndex = 13
    ic.Parent = b

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -56, 1, 0)
    lbl.Position = UDim2.fromOffset(50, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 14
    lbl.TextColor3 = PAL.txtDim
    lbl.Text = name
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = b

    tabs[name] = {btn = b, accent = acc, lbl = lbl, icon = ic}

    local tabBasePos = b.Position
    b.MouseEnter:Connect(function()
        if activeTab ~= name then
            TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = PAL.surface,
                BackgroundTransparency = 0.15,
                Position = tabBasePos + UDim2.fromOffset(3, 0)
            }):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if activeTab ~= name then
            TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = PAL.bgGlass,
                BackgroundTransparency = 0.25,
                Position = tabBasePos
            }):Play()
        end
    end)
    b.MouseButton1Click:Connect(function() selectTab(name) end)

    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, -16, 1, 0)
    page.Position = UDim2.fromOffset(0, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 5
    page.ScrollBarImageColor3 = PAL.accent
    page.ScrollBarImageTransparency = 0.3
    page.CanvasSize = UDim2.new()
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 12
    page.Parent = content
    pad(page, 18, 18, 20, 20)
    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0, 12)
    pl.SortOrder = Enum.SortOrder.LayoutOrder

    pages[name] = page
    return page
end

-- ================================================================
-- TOGGLE COMPONENT — Magnetic Spring + LED + Ripple + Neumorphism
-- ================================================================
local rowOrder = 0
local function makeToggle(page, label, desc, key)
    rowOrder += 1
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 64)
    row.BackgroundColor3 = PAL.surface
    row.BackgroundTransparency = 0.15
    row.BorderSizePixel = 0
    row.LayoutOrder = rowOrder
    row.ZIndex = 13
    row.Parent = page
    corner(row, 16)
    stroke(row, PAL.border, 1, 0.3)

    -- Neumorphic shadow layers
    local neuUp = shadow(row, -2, 8, 0.7)
    neuUp.ImageColor3 = Color3.fromRGB(255, 255, 255)
    neuUp.ImageTransparency = 0.85
    local neuDown = shadow(row, 2, 8, 0.7)

    -- Hover with depth shift + lift
    local rowBasePos = row.Position
    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.05,
            Position = rowBasePos - UDim2.fromOffset(0, 2)
        }):Play()
        TweenService:Create(neuUp, TweenInfo.new(0.2), {ImageTransparency = 0.7}):Play()
        TweenService:Create(neuDown, TweenInfo.new(0.2), {ImageTransparency = 0.55}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.15,
            Position = rowBasePos
        }):Play()
        TweenService:Create(neuUp, TweenInfo.new(0.2), {ImageTransparency = 0.85}):Play()
        TweenService:Create(neuDown, TweenInfo.new(0.2), {ImageTransparency = 0.7}):Play()
    end)

    -- LED status dot
    local led = Instance.new("Frame")
    led.Size = UDim2.fromOffset(8, 8)
    led.Position = UDim2.fromOffset(14, 28)
    led.BackgroundColor3 = PAL.ledOff
    led.BorderSizePixel = 0
    led.ZIndex = 15
    led.Parent = row
    corner(led, 4)
    local ledGlow = shadow(led, 0, 6, 0.8, PAL.ledOff)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -110, 0, 22)
    t.Position = UDim2.fromOffset(30, 10)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold
    t.TextSize = 15
    t.TextColor3 = PAL.txt
    t.Text = label
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 14
    t.Parent = row

    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1, -110, 0, 16)
    d.Position = UDim2.fromOffset(30, 33)
    d.BackgroundTransparency = 1
    d.Font = Enum.Font.Gotham
    d.TextSize = 12
    d.TextColor3 = PAL.txtDim
    d.Text = desc
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.ZIndex = 14
    d.Parent = row

    -- Switch track with inner glow
    local sw = Instance.new("Frame")
    sw.Size = UDim2.fromOffset(52, 28)
    sw.Position = UDim2.new(1, -68, 0.5, -14)
    sw.BackgroundColor3 = PAL.bgGlass2
    sw.BorderSizePixel = 0
    sw.ZIndex = 14
    sw.Parent = row
    corner(sw, 14)
    stroke(sw, PAL.border, 1, 0.4)
    innerGlow(sw, PAL.accent, 0.85)

    -- Magnetic knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(22, 22)
    knob.Position = UDim2.fromOffset(3, 3)
    knob.BackgroundColor3 = Color3.fromRGB(250, 251, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 16
    knob.Parent = sw
    corner(knob, 11)
    shadow(knob, 0, 8, 0.6)

    -- Knob bloom
    local bloom = Instance.new("ImageLabel")
    bloom.Size = UDim2.new(1, 20, 1, 20)
    bloom.Position = UDim2.fromOffset(-10, -10)
    bloom.BackgroundTransparency = 1
    bloom.Image = "rbxassetid://5554236805"
    bloom.ImageColor3 = PAL.accent
    bloom.ImageTransparency = 1
    bloom.ScaleType = Enum.ScaleType.Slice
    bloom.SliceCenter = Rect.new(23, 23, 277, 277)
    bloom.ZIndex = 15
    bloom.Parent = knob

    -- Hit area with ripple
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1, 1)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 17
    btn.Parent = row

    local function render()
        local on = S[key]
        TweenService:Create(sw, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            BackgroundColor3 = on and PAL.accent or PAL.bgGlass2
        }):Play()

        -- Spring: overshoot past target, squash on arrival, settle back to normal
        local targetPos = on and UDim2.fromOffset(27, 3) or UDim2.fromOffset(3, 3)
        TweenService:Create(knob, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0), {
            Position = targetPos,
            Size = UDim2.fromOffset(25, 19)
        }):Play()
        task.delay(0.28, function()
            if knob and knob.Parent then
                TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.fromOffset(22, 22)
                }):Play()
            end
        end)
        TweenService:Create(bloom, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageTransparency = on and 0.4 or 1
        }):Play()
        TweenService:Create(row, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = on and PAL.surfaceLit or PAL.surface
        }):Play()
        TweenService:Create(led, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = on and PAL.ledOn or PAL.ledOff
        }):Play()
        TweenService:Create(ledGlow, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageColor3 = on and PAL.ledOn or PAL.ledOff,
            ImageTransparency = on and 0.5 or 0.8
        }):Play()
    end

    btn.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        render()
        -- Ripple
        local mx = btn.AbsoluteSize.X / 2
        local my = btn.AbsoluteSize.Y / 2
        local rip = Instance.new("Frame")
        rip.Size = UDim2.fromOffset(4, 4)
        rip.Position = UDim2.fromOffset(mx - 2, my - 2)
        rip.BackgroundColor3 = PAL.accent
        rip.BackgroundTransparency = 0.5
        rip.BorderSizePixel = 0
        rip.ZIndex = 12
        rip.Parent = row
        corner(rip, 50)
        TweenService:Create(rip, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(200, 200),
            Position = UDim2.fromOffset(mx - 100, my - 100),
            BackgroundTransparency = 1
        }):Play()
        task.delay(0.75, function() rip:Destroy() end)

        -- Flash
        local flash = Instance.new("Frame")
        flash.Size = UDim2.new(1, 0, 1, 0)
        flash.BackgroundColor3 = PAL.accent
        flash.BackgroundTransparency = 0.7
        flash.BorderSizePixel = 0
        flash.ZIndex = 12
        flash.Parent = row
        corner(flash, 16)
        TweenService:Create(flash, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        task.delay(0.55, function() flash:Destroy() end)
    end)
    render()
end

-- ================================================================
-- ANIMATED DIVIDER
-- ================================================================
local function makeDivider(page)
    rowOrder += 1
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 2)
    f.BackgroundTransparency = 1
    f.LayoutOrder = rowOrder
    f.ZIndex = 13
    f.Parent = page

    local grad = Instance.new("Frame")
    grad.Size = UDim2.new(1, 0, 1, 0)
    grad.BackgroundColor3 = PAL.accent
    grad.BorderSizePixel = 0
    grad.ZIndex = 13
    grad.Parent = f
    local g = gradient(grad, ColorSequence.new(PAL.accent, PAL.accent2), 0)
    g.Transparency = NumberSequence.new(0.6, 0.9)

    local divTime = 0
    local divConn
    divConn = RunService.Heartbeat:Connect(function(dt)
        divTime += dt
        g.Offset = Vector2.new(math.sin(divTime * 2) * 0.3, 0)
    end)

    -- Cleanup connection when destroyed
    f.Destroying:Connect(function()
        if divConn then divConn:Disconnect() end
    end)
end

local function sectionInfo(page, text)
    rowOrder += 1
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 0)
    l.AutomaticSize = Enum.AutomaticSize.Y
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextColor3 = PAL.txtDim
    l.TextWrapped = true
    l.RichText = true
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = text
    l.LayoutOrder = rowOrder
    l.ZIndex = 13
    l.Parent = page
end

-- ================================================================
-- BUILD TABS
-- ================================================================
local pFarm  = makeTab("Farm", "🌱")
makeToggle(pFarm, "Auto Upgrade", "Bulk-upgrades all income sources", "upgrade")
makeToggle(pFarm, "Auto Buy", "Buys unlocked tycoon buttons", "buy")
makeToggle(pFarm, "Auto Collect Drops", "Instantly grabs cash drops", "drops")
makeToggle(pFarm, "Auto Click Fruit", "Auto-clicks the lemon trees", "click")
makeToggle(pFarm, "Auto Harvest", "Harvests ALL orchard plots via remote", "harvest")
makeToggle(pFarm, "Auto Upgrade Powers", "Cycles all power upgrades via verified remote", "autopowers")
makeDivider(pFarm)

local pPrest = makeTab("Prestige", "🔼")
makeToggle(pPrest, "Auto Rebirth", "Rebirths for investors when able", "rebirth")
makeToggle(pPrest, "Auto Ascend", "Ascends when progress is full", "ascend")
makeToggle(pPrest, "Auto Evolve", "Evolves when able", "evolve")
makeToggle(pPrest, "Auto Power Upgrade", "Levels UpgradeStack / BuyNext / etc", "powers")
makeDivider(pPrest)
sectionInfo(pPrest, "<font color=\'#FFAA55\'>⚠ Ascend &amp; Evolve reset your tycoon for permanent multipliers.</font>")

local pBonus = makeTab("Bonus", "💎")
makeToggle(pBonus, "Auto Wake Income", "Keeps every earner producing", "wake")
makeToggle(pBonus, "Auto Phone Offers", "Auto-accepts deal calls", "offers")
makeToggle(pBonus, "Auto Offline Cash", "Claims free 2x offline (no Robux)", "offline")
makeToggle(pBonus, "Auto Minigame", "Auto-wins LemonDash (5m cooldown)", "mini")
makeToggle(pBonus, "Remote Buy", "Buys next item remotely (gamepass)", "remotebuy")
makeToggle(pBonus, "Auto Eater", "Auto-eats orchard fruit (gamepass)", "autoeat")
makeDivider(pBonus)

local pMisc  = makeTab("Misc", "⚙️")
makeToggle(pMisc, "Anti-AFK", "Never get idle-kicked", "antiafk")
makeToggle(pMisc, "Performance Mode", "Reduces visual effects to boost FPS", "perfmode")
makeDivider(pMisc)

-- Stats card with rolling counters
local statsCard = Instance.new("Frame")
statsCard.Size = UDim2.new(1, 0, 0, 120)
statsCard.BackgroundColor3 = PAL.bgGlass2
statsCard.BackgroundTransparency = 0.1
statsCard.BorderSizePixel = 0
statsCard.LayoutOrder = 50
statsCard.ZIndex = 13
statsCard.Parent = pMisc
corner(statsCard, 16)
stroke(statsCard, PAL.border, 1, 0.25)
innerGlow(statsCard, PAL.accent, 0.9)
shadow(statsCard, 4, 16, 0.5)

local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, -20, 0, 22)
statsTitle.Position = UDim2.fromOffset(14, 12)
statsTitle.BackgroundTransparency = 1
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextSize = 14
statsTitle.TextColor3 = PAL.accent
statsTitle.Text = "📊 Session Stats"
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.ZIndex = 14
statsTitle.Parent = statsCard

local stats = Instance.new("TextLabel")
stats.Size = UDim2.new(1, -20, 0, 70)
stats.Position = UDim2.fromOffset(14, 36)
stats.BackgroundTransparency = 1
stats.Font = Enum.Font.Code
stats.TextSize = 13
stats.TextColor3 = PAL.txt
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.RichText = true
stats.ZIndex = 14
stats.Text = ""
stats.Parent = statsCard

sectionInfo(pMisc, "<font color=\'#8A8F9C\'>RightShift hides the menu  •  drag the header to move</font>")
selectTab("Farm")

-- ================================================================
-- PARTICLE ENGINE — Full system with pools & trajectories
-- ================================================================
local particlePool = {}
local activeParticles = {}
local particleTypes = {"🍋", "✦", "•", "◆", "◇", "✧"}

local function spawnParticle()
    if #activeParticles > 12 then return end
    local p
    if #particlePool > 0 then
        p = table.remove(particlePool)
        p.Visible = true
    else
        p = Instance.new("TextLabel")
        p.Size = UDim2.fromOffset(14, 14)
        p.BackgroundTransparency = 1
        p.Font = Enum.Font.GothamBold
        p.TextSize = 12
        p.ZIndex = 3
        p.Parent = particleCanvas
    end

    p.TextColor3 = math.random() > 0.5 and PAL.accent or (math.random() > 0.5 and PAL.accent2 or PAL.accent3)
    p.Text = particleTypes[math.random(1, #particleTypes)]

    local startX = math.random(10, 540)
    local startY = 400 + math.random(0, 50)
    p.Position = UDim2.fromOffset(startX, startY)
    p.Rotation = math.random(0, 360)

    local speed = 15 + math.random() * 25
    local amp = 15 + math.random() * 40
    local freq = 1 + math.random() * 2
    local rotSpeed = (math.random() - 0.5) * 120
    local scalePulse = 0.5 + math.random() * 0.5
    local life = 0
    local maxLife = 4 + math.random() * 6

    table.insert(activeParticles, {obj = p, startX = startX, startY = startY, speed = speed, amp = amp, freq = freq, rotSpeed = rotSpeed, scalePulse = scalePulse, life = 0, maxLife = maxLife})
end

-- Particle physics: 30fps throttle
local particleLastUpdate = 0
local particleConn = RunService.Heartbeat:Connect(function(dt)
    local now = tick()
    if now - particleLastUpdate < 0.033 then return end
    particleLastUpdate = now
    for i = #activeParticles, 1, -1 do
        local part = activeParticles[i]
        part.life += dt
        if part.life >= part.maxLife then
            part.obj.Visible = false
            table.insert(particlePool, part.obj)
            table.remove(activeParticles, i)
        else
            local y = part.startY - part.life * part.speed
            local x = part.startX + math.sin(part.life * part.freq) * part.amp
            local s = 1 + math.sin(part.life * part.scalePulse * 5) * 0.3
            part.obj.Position = UDim2.fromOffset(x, y)
            part.obj.Rotation = part.obj.Rotation + part.rotSpeed * dt
            part.obj.TextTransparency = 0.5 + (part.life / part.maxLife) * 0.5
            part.obj.Size = UDim2.fromOffset(14 * s, 14 * s)
        end
    end
end)

local particleSpawner = task.spawn(function()
    while true do
        task.wait(1.5 + math.random() * 2)
        if gui and gui.Parent then
            if not S.perfmode then
                pcall(spawnParticle)
            end
        else
            break
        end
    end
end)

-- Performance mode: disable heavy visual effects
local perfConn = nil
local function updatePerfMode()
    if S.perfmode then
        ambient.Visible = false
        particleCanvas.Visible = false
        cursorGlow.Visible = false
        if not perfConn then
            perfConn = RunService.Heartbeat:Connect(function()
                if not S.perfmode then return end
                -- Minimal orb movement in perf mode
                orb1.Position = UDim2.fromScale(0.2, 0.3)
                orb2.Position = UDim2.fromScale(0.7, 0.6)
                orb3.Position = UDim2.fromScale(0.5, 0.2)
            end)
        end
    else
        ambient.Visible = true
        particleCanvas.Visible = true
        if perfConn then
            perfConn:Disconnect()
            perfConn = nil
        end
    end
end

-- Watch for perf mode toggle
local perfCheckConn = RunService.Heartbeat:Connect(function()
    updatePerfMode()
end)

-- ================================================================
-- BORDER GLOW ANIMATION
-- ================================================================
-- Border glow: 30fps throttle
local glowTime = 0
local glowLastUpdate = 0
local glowConn = RunService.Heartbeat:Connect(function(dt)
    local now = tick()
    if now - glowLastUpdate < 0.033 then return end
    glowLastUpdate = now
    glowTime += dt
    glow1g.Rotation = (glowTime * 12) % 360
    glow2g.Rotation = (glowTime * 18 + 90) % 360
    glow1.Transparency = 0.8 + math.sin(glowTime * 3) * 0.1
    glow2.Transparency = 0.85 + math.cos(glowTime * 2.5) * 0.1
end)

-- ================================================================
-- DRAG SYSTEM
-- ================================================================
do
    local drag, sp, si
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            sp = main.Position
            si = i.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local dd = i.Position - si
            main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dd.X, sp.Y.Scale, sp.Y.Offset + dd.Y)
        end
    end)
end

-- ================================================================
-- MINIMIZE / CLOSE / HOTKEY
-- ================================================================
local minimized = false
local originalSize = UDim2.fromOffset(560, 400)

minB.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(main, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
            Size = UDim2.fromOffset(560, 72)
        }):Play()
        body.Visible = false
        particleCanvas.Visible = false
    else
        body.Visible = true
        particleCanvas.Visible = true
        TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = originalSize
        }):Play()
    end
end)

local panelHidden = false
local function setPanelHidden(hidden)
    if hidden == panelHidden then return end
    panelHidden = hidden
    if hidden then
        TweenService:Create(main, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(main.AbsoluteSize.X, 0),
            BackgroundTransparency = 1
        }):Play()
        task.delay(0.28, function()
            if panelHidden then main.Visible = false end
        end)
    else
        main.Visible = true
        main.Size = UDim2.fromOffset(main.AbsoluteSize.X > 0 and main.AbsoluteSize.X or 560, 0)
        main.BackgroundTransparency = 1
        local targetSize = minimized and UDim2.fromOffset(560, 72) or originalSize
        TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = targetSize,
            BackgroundTransparency = 0.1
        }):Play()
    end
end

UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        setPanelHidden(not panelHidden)
    end
end)

closeB.MouseButton1Click:Connect(function()
    closeB.Active = false
    minB.Active = false
    TweenService:Create(main, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        Rotation = 6
    }):Play()
    TweenService:Create(glow1, TweenInfo.new(0.25), {Transparency = 1}):Play()
    TweenService:Create(glow2, TweenInfo.new(0.25), {Transparency = 1}):Play()
    task.delay(0.34, function()
        if _G.LemonFarm then _G.LemonFarm.Destroy() end
    end)
end)

-- ================================================================
-- FUNCTIONAL LOOPS (PRESERVED EXACTLY + HARVEST)
-- ================================================================
local alive = true
local function getMyTycoon()
    for _, f in ipairs(workspace:GetChildren()) do
        if f:IsA("Folder") and f.Name:match("^Tycoon%d+$") then
            local o = f:FindFirstChild("Owner")
            if o and o:IsA("ObjectValue") and o.Value == lp then return f end
        end
    end
end

local lastTycoonName = nil

local function clearAllCaches()
    table.clear(purchasedCache)
    table.clear(upgradeCache)
    table.clear(harvestCache)
    table.clear(powerCooldowns)
    table.clear(remoteBuyCache)
    table.clear(autoEatCache)
    table.clear(powerFailStreak)
    powerIdx = 1
    legacyPowerIdx = 1
end

local function rem(myT, name)
    if myT and myT:FindFirstChild("Remotes") then
        return myT.Remotes:FindFirstChild(name)
    end
end

local function loop(iv, fn)
    task.spawn(function()
        while alive do
            pcall(fn)
            task.wait(iv)
        end
    end)
end

-- Upgrade cache to prevent spam on maxed earners
local upgradeCache = {}
loop(0.20, function()
    if not S.upgrade then return end
    local myT = getMyTycoon()
    if not myT then return end
    for _, e in ipairs(CollectionService:GetTagged("Tycoon.Earner")) do
        if not S.upgrade then break end
        if not e:IsDescendantOf(myT) then continue end

        local uid = tostring(e)
        local r = e:FindFirstChild("Upgrade")
        if not (r and r:IsA("RemoteFunction")) then continue end

        -- Skip if this earner was marked as maxed recently
        if upgradeCache[uid] and (tick() - upgradeCache[uid]) < 3 then continue end

        local n = 1
        local anySuccess = false
        while alive and S.upgrade and n <= 1e6 do
            local ok = pcall(function() return r:InvokeServer(n) end)
            if ok then
                S.cUp += n
                n *= 2
                anySuccess = true
            else
                break
            end
        end
        -- If even n=1 failed, mark as maxed for a few seconds
        if not anySuccess then
            upgradeCache[uid] = tick()
        end
    end
end)

-- Track recently-processed purchases to avoid spamming "already purchased" errors
local purchasedCache = {}
local function isPurchaseReady(p)
    if not p or not p.Parent then return false end
    if p:GetAttribute("Purchased") then return false end
    if not p:GetAttribute("Enabled") then return false end
    if not p:GetAttribute("Shown") then return false end
    return true
end

loop(0.25, function()
    if not S.buy then return end
    local myT = getMyTycoon()
    if not myT then return end
    for _, p in ipairs(CollectionService:GetTagged("Tycoon.Purchase")) do
        if not S.buy then break end
        if not p:IsDescendantOf(myT) then continue end
        if not isPurchaseReady(p) then continue end

        local uid = tostring(p)
        local lastTry = purchasedCache[uid]
        if lastTry and (tick() - lastTry) < 2 then continue end

        local r = p:FindFirstChild("Purchase")
        if not (r and r:IsA("RemoteFunction")) then continue end

        purchasedCache[uid] = tick()
        local ok = pcall(function() r:InvokeServer(false) end)
        if ok and p:GetAttribute("Purchased") then
            S.cBuy += 1
            purchasedCache[uid] = nil
        end
    end
end)

task.spawn(function()
    local nv = RS.Core.RemoteSignal:FindFirstChild("CashDropService.New")
    local rd = RS.Core.RemoteRequest:FindFirstChild("CashDropService.Redeem")
    if nv and rd then
        nv.OnClientEvent:Connect(function(id)
            if S.drops and id ~= nil then
                task.spawn(function()
                    if pcall(function() return rd:InvokeServer(id) end) then
                        S.cDrop += 1
                    end
                end)
            end
        end)
    end
end)

loop(0.2, function()
    if not (S.click and fireclickdetector) then return end
    local myT = getMyTycoon()
    if not myT then return end
    for _, d in ipairs(myT:GetDescendants()) do
        if not S.click then break end
        if d:IsA("ClickDetector") then pcall(fireclickdetector, d) end
    end
end)

-- ================================================================
-- AUTO HARVEST — Cobalt-Generated Remote Integration
-- Iterates ALL orchard plots in the user's tycoon and harvests them
-- via the ReplicatedStorage.Core.RemoteRequest.OrchardPlot.Harvest
-- remote function.
-- ================================================================
local harvestEvent = nil
local function getHarvestRemote()
    if harvestEvent then return harvestEvent end
    local core = RS:FindFirstChild("Core")
    if not core then return nil end
    local rr = core:FindFirstChild("RemoteRequest")
    if not rr then return nil end
    harvestEvent = rr:FindFirstChild("OrchardPlot.Harvest")
    return harvestEvent
end

-- Harvest cache to avoid spamming empty/unready plots
local harvestCache = {}
loop(0.5, function()
    if not S.harvest then return end
    local myT = getMyTycoon()
    if not myT then return end

    local hev = getHarvestRemote()
    if not hev then return end

    local orchard = myT:FindFirstChild("Orchard")
    if not orchard then return end

    local plots = orchard:FindFirstChild("Plots")
    if not plots then return end

    for _, plot in ipairs(plots:GetChildren()) do
        if not S.harvest then break end
        if not (plot:IsA("BasePart") or plot:IsA("Model") or plot:IsA("Folder")) then continue end

        local uid = tostring(plot)
        if harvestCache[uid] and (tick() - harvestCache[uid]) < 1 then continue end

        local ok = pcall(function()
            return hev:InvokeServer(plot)
        end)
        if ok then
            S.cHarvest += 1
            harvestCache[uid] = nil
        else
            harvestCache[uid] = tick()
        end
    end
end)

-- ================================================================
-- AUTO UPGRADE POWERS — BUY FULL (AGGRESSIVE)
-- Each call buys exactly 1 level. We cycle powers rapidly and buy
-- as many levels as money allows. No tier detection, no complex logic.
-- Just pure speed: try → success? buy again. fail? next power.
-- ================================================================
local POWER_NAMES = {"UpgradeStack", "BuyNext", "Manage", "WalkSpeed", "ClickFruitValue", "AutoFruit"}
local powerFailStreak = {}  -- consecutive fails per power
local powerIdx = 1        -- current power index for round-robin

loop(0.05, function()
    if not S.autopowers then return end
    local myT = getMyTycoon()
    if not myT then return end
    local remotes = myT:FindFirstChild("Remotes")
    if not remotes then return end
    local r = remotes:FindFirstChild("UpgradePowerLevel")
    if not r then return end

    -- Batch multiple purchases per loop iteration (more efficient)
    -- but yield every few to prevent starving other threads
    local batchCount = 0
    while S.autopowers and batchCount < 5 do
        local name = POWER_NAMES[powerIdx]
        if not name then powerIdx = 1 break end

        -- Skip powers with 10+ consecutive fails (likely maxed)
        if (powerFailStreak[name] or 0) >= 10 then
            powerIdx = (powerIdx % #POWER_NAMES) + 1
            batchCount += 1
            continue
        end

        local ok, res = pcall(function()
            return r:InvokeServer(name)
        end)

        if ok and res == 1 then
            powerFailStreak[name] = 0
            S.cAutoPowers += 1
            batchCount += 1
            -- Stay on same power
        else
            powerFailStreak[name] = (powerFailStreak[name] or 0) + 1
            powerIdx = (powerIdx % #POWER_NAMES) + 1
            batchCount += 1
        end
    end
end)

loop(60, function()
    if not S.rebirth then return end
    local myT = getMyTycoon()
    local r = rem(myT, "Rebirth")
    if r then
        local ok = pcall(function() r:InvokeServer() end)
        if ok then
            clearAllCaches()
            lastTycoonName = nil
            harvestEvent = nil
        end
    end
end)

loop(8, function()
    if not S.ascend then return end
    local myT = getMyTycoon()
    local r = rem(myT, "Ascend")
    if r then
        local ok = pcall(function() r:InvokeServer() end)
        if ok then
            clearAllCaches()
            lastTycoonName = nil
            harvestEvent = nil
        end
    end
end)

loop(8, function()
    if not S.evolve then return end
    local myT = getMyTycoon()
    local r = rem(myT, "Evolve")
    if r then
        local ok = pcall(function() r:InvokeServer() end)
        if ok then
            clearAllCaches()
            lastTycoonName = nil
        end
    end
end)

-- Power upgrades — Cobalt-verified path: workspace.Tycoon{N}.Remotes.UpgradePowerLevel
-- Returns 1 on success. Fast round-robin with fail tracking.
local powerCooldowns = {}
local lastPowerTycoon = nil
local legacyPowerIdx = 1
loop(0.15, function()
    if not S.powers then return end
    local myT = getMyTycoon()
    if not myT then return end

    -- Clear cooldowns when tycoon changes (prestige reset)
    if lastPowerTycoon and myT.Name ~= lastPowerTycoon then
        table.clear(powerCooldowns)
        legacyPowerIdx = 1
    end
    lastPowerTycoon = myT.Name

    local r = myT:FindFirstChild("Remotes") and myT.Remotes:FindFirstChild("UpgradePowerLevel")
    if not r then return end

    local n = POWERS[legacyPowerIdx]
    if not n then legacyPowerIdx = 1 return end

    if powerCooldowns[n] and (tick() - powerCooldowns[n]) < 2 then
        legacyPowerIdx = (legacyPowerIdx % #POWERS) + 1
        return
    end

    local ok, res = pcall(function() return r:InvokeServer(n) end)
    if ok and res == 1 then
        S.cUp += 1
        powerCooldowns[n] = nil
        -- Stay on this power, buy again
    else
        powerCooldowns[n] = tick()
        legacyPowerIdx = (legacyPowerIdx % #POWERS) + 1
    end
end)

loop(8, function()
    if not S.wake then return end
    local myT = getMyTycoon()
    local r = rem(myT, "WakeIncomeStream")
    if not r then return end
    for _, e in ipairs(CollectionService:GetTagged("Tycoon.Earner")) do
        if not S.wake then break end
        if e:IsDescendantOf(myT) then
            pcall(function() r:InvokeServer(e.Name) end)
        end
    end
end)

task.spawn(function()
    while alive do
        local myT = getMyTycoon()
        local ev = myT and rem(myT, "PhoneOffer")
        if ev and ev:IsA("RemoteEvent") and not ev:GetAttribute("_LH") then
            ev:SetAttribute("_LH", true)
            ev.OnClientEvent:Connect(function(v)
                if S.offers and type(v) == "number" then
                    pcall(function() ev:FireServer("Accept") end)
                end
            end)
        end
        task.wait(2)
    end
end)

loop(20, function()
    if not S.offline then return end
    local r = rem(getMyTycoon(), "DoubleOfflineCash")
    if r then pcall(function() r:InvokeServer() end) end
end)

loop(5, function()
    if not S.mini then return end
    local sr = RS.Core.RemoteRequest:FindFirstChild("MinigameRaceService.Start")
    local er = RS.Core.RemoteRequest:FindFirstChild("MinigameRaceService.End")
    if not (sr and er) then return end
    local ok, res = pcall(function() return sr:InvokeServer() end)
    if ok and res then
        task.wait(0.25)
        pcall(function() er:InvokeServer(1) end)
        S.cMini += 1
    end
end)

-- ================================================================
-- REMOTE BUY — Discovers and fires the remote-buy remote
-- Common names: BuyNext, RemoteBuy, PurchaseNext, RemotePurchase
-- ================================================================
local remoteBuyNames = {"BuyNext", "RemoteBuy", "PurchaseNext", "RemotePurchase", "BuyRemote"}
local remoteBuyCache = {}
loop(1, function()
    if not S.remotebuy then return end
    local myT = getMyTycoon()
    if not myT then return end
    local remotes = myT:FindFirstChild("Remotes")
    if not remotes then return end

    for _, name in ipairs(remoteBuyNames) do
        if not S.remotebuy then break end
        local r = remotes:FindFirstChild(name)
        if r and r:IsA("RemoteFunction") then
            local uid = name
            if remoteBuyCache[uid] and (tick() - remoteBuyCache[uid]) < 2 then continue end
            local ok = pcall(function() r:InvokeServer() end)
            if ok then
                S.cRemoteBuy += 1
                remoteBuyCache[uid] = nil
            else
                remoteBuyCache[uid] = tick()
            end
            break
        end
    end
end)

-- ================================================================
-- AUTO EATER — Discovers and fires auto-eat / eat-fruit remotes
-- Tries tycoon remotes first, then orchard remotes, then RS.Core
-- ================================================================
local autoEatNames = {"EatFruit", "AutoEat", "ConsumeFruit", "EatOrchardFruit"}
local autoEatCache = {}
loop(2, function()
    if not S.autoeat then return end
    local myT = getMyTycoon()
    if not myT then return end

    -- Try tycoon remotes first
    local remotes = myT:FindFirstChild("Remotes")
    if remotes then
        for _, name in ipairs(autoEatNames) do
            if not S.autoeat then break end
            local r = remotes:FindFirstChild(name)
            if r then
                local uid = "tycoon_" .. name
                if autoEatCache[uid] and (tick() - autoEatCache[uid]) < 3 then continue end
                local ok = pcall(function()
                    if r:IsA("RemoteFunction") then
                        r:InvokeServer()
                    elseif r:IsA("RemoteEvent") then
                        r:FireServer()
                    end
                end)
                if ok then
                    S.cAutoEat += 1
                    autoEatCache[uid] = nil
                else
                    autoEatCache[uid] = tick()
                end
                return
            end
        end
    end

    -- Try orchard plot remotes
    local orchard = myT:FindFirstChild("Orchard")
    if orchard then
        local plots = orchard:FindFirstChild("Plots")
        if plots then
            for _, plot in ipairs(plots:GetChildren()) do
                if not S.autoeat then break end
                for _, name in ipairs(autoEatNames) do
                    if not S.autoeat then break end
                    local r = plot:FindFirstChild(name)
                    if r then
                        local uid = tostring(plot) .. "_" .. name
                        if autoEatCache[uid] and (tick() - autoEatCache[uid]) < 3 then continue end
                        local ok = pcall(function()
                            if r:IsA("RemoteFunction") then
                                r:InvokeServer()
                            elseif r:IsA("RemoteEvent") then
                                r:FireServer()
                            end
                        end)
                        if ok then
                            S.cAutoEat += 1
                            autoEatCache[uid] = nil
                        else
                            autoEatCache[uid] = tick()
                        end
                        return
                    end
                end
            end
        end
    end

    -- Try ReplicatedStorage.Core.RemoteRequest
    local core = RS:FindFirstChild("Core")
    local rr = core and core:FindFirstChild("RemoteRequest")
    if rr then
        for _, name in ipairs(autoEatNames) do
            if not S.autoeat then break end
            local r = rr:FindFirstChild(name)
            if r then
                local uid = "rs_" .. name
                if autoEatCache[uid] and (tick() - autoEatCache[uid]) < 3 then continue end
                local ok = pcall(function()
                    if r:IsA("RemoteFunction") then
                        r:InvokeServer()
                    elseif r:IsA("RemoteEvent") then
                        r:FireServer()
                    end
                end)
                if ok then
                    S.cAutoEat += 1
                    autoEatCache[uid] = nil
                else
                    autoEatCache[uid] = tick()
                end
                return
            end
        end
    end
end)

lp.Idled:Connect(function()
    if S.antiafk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- ================================================================
-- UI UPDATE LOOP
-- ================================================================
loop(0.4, function()
    local myT = getMyTycoon()

    -- Detect tycoon change (rebirth/ascend/evolve destroys old tycoon)
    local currentName = myT and myT.Name or nil
    if currentName ~= lastTycoonName then
        lastTycoonName = currentName
        clearAllCaches()
        -- Also clear the harvest remote cache since tycoon changed
        harvestEvent = nil
    end

    local cash = lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Cash") and lp.leaderstats.Cash.Value or "?"
    cashL.Text = "💰 " .. tostring(cash) .. "   •   " .. (currentName or "?")
    stats.Text = string.format("Upgrades    %d\nBuys        %d\nDrops       %d\nHarvests    %d\nPowers      %d\nRemoteBuy   %d\nAutoEat     %d\nRaces       %d", S.cUp, S.cBuy, S.cDrop, S.cHarvest, S.cAutoPowers, S.cRemoteBuy, S.cAutoEat, S.cMini)
end)

-- ================================================================
-- CLEANUP — Disconnect all connections
-- ================================================================
_G.LemonFarm = {
    Destroy = function()
        alive = false
        for k in pairs(S) do
            if type(S[k]) == "boolean" then S[k] = false end
        end
        table.clear(purchasedCache)
        table.clear(upgradeCache)
        table.clear(harvestCache)
        table.clear(powerCooldowns)
        table.clear(remoteBuyCache)
        table.clear(autoEatCache)
        table.clear(powerFailStreak)
        lastTycoonName = nil
        lastPowerTycoon = nil
        harvestEvent = nil
        powerIdx = 1
        legacyPowerIdx = 1
        if orbConn then orbConn:Disconnect() end
        if hConn then hConn:Disconnect() end
        if pulseConn then pulseConn:Disconnect() end
        if glowConn then glowConn:Disconnect() end
        if particleConn then particleConn:Disconnect() end
        if cursorConn then cursorConn:Disconnect() end
        if perfConn then perfConn:Disconnect() end
        if perfCheckConn then perfCheckConn:Disconnect() end
        if gui then gui:Destroy() end
    end
}

print("[🍋 Lemon Hub Maximum] Loaded — The Final Form. RightShift hides, ✕ closes.")
