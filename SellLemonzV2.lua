--==================================================================
-- 🍋 LEMON HUB MAXIMUM — Key System Edition
--==================================================================
-- Key System: Loot-Link integration with per-key expiration
-- Backend: https://loot-link.com/s?90oVk0Lh
-- Master Key (for testing): gjyAZmyNUdiDCFjnzxPvdonFRLIiDrSa
--==================================================================

if _G.LemonFarm and _G.LemonFarm.Destroy then pcall(_G.LemonFarm.Destroy) end

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer
local POWERS = {"UpgradeStack","BuyNext","Manage","WalkSpeed","ClickFruitValue","AutoFruit"}

-- ================================================================
-- KEY SYSTEM CONFIGURATION
-- ================================================================
local KEY_CONFIG = {
    lootLink = "https://loot-link.com/s?90oVk0Lh",
    keys = {
        ["gjyAZmyNUdiDCFjnzxPvdonFRLIiDrSa"] = { hours = 24 },
        ["croxLifeTimeKey"] = { hours = 9999999999999999999 },
        ["finwoLifeTimeKey"] = { hours = 9999999999999999999 }, -- lifetime
    },
    graceMinutes = 5,
    cacheFile = "LemonHub_KeyCache.json",
    checkInterval = 60,
}

-- ================================================================
-- KEY SYSTEM STATE
-- ================================================================
local keyState = {
    authenticated = false,
    currentKey = nil,
    expiresAt = nil,
    firstUsed = nil,
    warned = false,
}

-- ================================================================
-- KEY SYSTEM UTILITIES
-- ================================================================
local function saveKeyCache()
    local cache = {
        currentKey = keyState.currentKey,
        expiresAt = keyState.expiresAt,
        firstUsed = keyState.firstUsed,
    }
    local ok, json = pcall(function() return HttpService:JSONEncode(cache) end)
    if ok then
        pcall(function() writefile(KEY_CONFIG.cacheFile, json) end)
    end
end

local function loadKeyCache()
    local ok, content = pcall(function() return readfile(KEY_CONFIG.cacheFile) end)
    if not ok then return false end
    local ok2, cache = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok2 or not cache then return false end

    if cache.currentKey and KEY_CONFIG.keys[cache.currentKey] then
        keyState.currentKey = cache.currentKey
        keyState.expiresAt = cache.expiresAt
        keyState.firstUsed = cache.firstUsed

        if keyState.expiresAt and tick() > keyState.expiresAt then
            keyState.currentKey = nil
            keyState.expiresAt = nil
            keyState.firstUsed = nil
            pcall(function() delfile(KEY_CONFIG.cacheFile) end)
            return false
        end

        keyState.authenticated = true
        return true
    end
    return false
end

local function clearKeyCache()
    pcall(function() delfile(KEY_CONFIG.cacheFile) end)
    keyState.authenticated = false
    keyState.currentKey = nil
    keyState.expiresAt = nil
    keyState.firstUsed = nil
    keyState.warned = false
end

local function validateKey(key)
    if not key or type(key) ~= "string" then return false end
    key = key:gsub("%s+", "")

    local config = KEY_CONFIG.keys[key]
    if not config then return false end

    if keyState.expiresAt and tick() > keyState.expiresAt then
        return false
    end

    if not keyState.firstUsed then
        keyState.firstUsed = tick()
        keyState.expiresAt = tick() + (config.hours * 3600)
        keyState.currentKey = key
        keyState.authenticated = true
        keyState.warned = false
        saveKeyCache()
    end

    return true
end

local function getTimeRemaining()
    if not keyState.expiresAt then return "EXPIRED" end
    local seconds = keyState.expiresAt - tick()
    if seconds <= 0 then return "EXPIRED" end
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    if hours > 0 then
        return string.format("%dh %dm %ds", hours, mins, secs)
    elseif mins > 0 then
        return string.format("%dm %ds", mins, secs)
    else
        return string.format("%ds", secs)
    end
end


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
-- ROOT GUI
-- ================================================================
local parent = (gethui and gethui()) or game:GetService("CoreGui")
local gui = Instance.new("ScreenGui")
gui.Name = "LemonHubMax"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = parent

-- ================================================================
-- KEY SYSTEM UI
-- ================================================================
local function createKeySystemUI(onAuthenticated)
    local keyGui = Instance.new("Frame")
    keyGui.Name = "KeySystem"
    keyGui.Size = UDim2.fromOffset(420, 340)
    keyGui.Position = UDim2.fromScale(0.5, 0.5)
    keyGui.AnchorPoint = Vector2.new(0.5, 0.5)
    keyGui.BackgroundColor3 = PAL.bgGlass
    keyGui.BackgroundTransparency = 0.1
    keyGui.BorderSizePixel = 0
    keyGui.ClipsDescendants = true
    keyGui.ZIndex = 100
    keyGui.Parent = gui
    corner(keyGui, 24)

    keyGui.Size = UDim2.fromOffset(0, 0)
    keyGui.BackgroundTransparency = 1
    TweenService:Create(keyGui, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0.05), {
        Size = UDim2.fromOffset(420, 340),
        BackgroundTransparency = 0.1
    }):Play()

    local glow1 = stroke(keyGui, PAL.accent, 2.5, 0.85)
    local glow1g = gradient(glow1, ColorSequence.new(PAL.accent, PAL.accent2), 0)
    local glow2 = stroke(keyGui, PAL.accent3, 1.5, 0.9)
    local glow2g = gradient(glow2, ColorSequence.new(PAL.accent3, PAL.accent), 90)
    shadow(keyGui, 8, 40, 0.6)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 64)
    header.BackgroundColor3 = PAL.bgGlass2
    header.BackgroundTransparency = 0.15
    header.BorderSizePixel = 0
    header.ZIndex = 101
    header.Parent = keyGui
    corner(header, 24)

    local hfix = Instance.new("Frame")
    hfix.Size = UDim2.new(1, 0, 0, 24)
    hfix.Position = UDim2.new(0, 0, 1, -24)
    hfix.BackgroundColor3 = PAL.bgGlass2
    hfix.BackgroundTransparency = 0.15
    hfix.BorderSizePixel = 0
    hfix.ZIndex = 101
    hfix.Parent = header

    local hgrad = Instance.new("Frame")
    hgrad.Size = UDim2.new(1, 0, 1, 0)
    hgrad.BackgroundTransparency = 1
    hgrad.ZIndex = 102
    hgrad.Parent = header
    local hg = gradient(hgrad, ColorSequence.new{
        ColorSequenceKeypoint.new(0, PAL.accent),
        ColorSequenceKeypoint.new(0.5, PAL.accent2),
        ColorSequenceKeypoint.new(1, PAL.accent)
    }, 0)
    hg.Transparency = NumberSequence.new(0.88, 0.95)

    local logoOrb = Instance.new("Frame")
    logoOrb.Size = UDim2.fromOffset(40, 40)
    logoOrb.Position = UDim2.fromOffset(16, 12)
    logoOrb.BackgroundColor3 = PAL.accent
    logoOrb.BorderSizePixel = 0
    logoOrb.ZIndex = 103
    logoOrb.Parent = header
    corner(logoOrb, 12)
    shadow(logoOrb, 0, 16, 0.5, PAL.accent)

    local logoIcon = Instance.new("TextLabel")
    logoIcon.Size = UDim2.fromScale(1, 1)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Font = Enum.Font.GothamBold
    logoIcon.Text = "🔐"
    logoIcon.TextSize = 22
    logoIcon.ZIndex = 104
    logoIcon.Parent = logoOrb

    local titleC = Instance.new("TextLabel")
    titleC.Size = UDim2.fromOffset(280, 24)
    titleC.Position = UDim2.fromOffset(68, 12)
    titleC.BackgroundTransparency = 1
    titleC.Font = Enum.Font.GothamBold
    titleC.TextSize = 20
    titleC.TextColor3 = PAL.txt
    titleC.Text = "Lemon Hub — Key System"
    titleC.TextXAlignment = Enum.TextXAlignment.Left
    titleC.ZIndex = 103
    titleC.Parent = header
    gradient(titleC, ColorSequence.new(PAL.accent2, PAL.accent), 0)

    local subtitleC = Instance.new("TextLabel")
    subtitleC.Size = UDim2.fromOffset(280, 16)
    subtitleC.Position = UDim2.fromOffset(68, 36)
    subtitleC.BackgroundTransparency = 1
    subtitleC.Font = Enum.Font.GothamMedium
    subtitleC.TextSize = 12
    subtitleC.TextColor3 = PAL.txtDim
    subtitleC.Text = "Enter your key to access Lemon Hub"
    subtitleC.TextXAlignment = Enum.TextXAlignment.Left
    subtitleC.ZIndex = 103
    subtitleC.Parent = header

    local body = Instance.new("Frame")
    body.Size = UDim2.new(1, 0, 1, -64)
    body.Position = UDim2.fromOffset(0, 64)
    body.BackgroundTransparency = 1
    body.ZIndex = 101
    body.Parent = keyGui
    pad(body, 20, 20, 24, 24)

    local bodyList = Instance.new("UIListLayout", body)
    bodyList.Padding = UDim.new(0, 12)
    bodyList.SortOrder = Enum.SortOrder.LayoutOrder

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 13
    statusLabel.TextColor3 = PAL.txtDim
    statusLabel.Text = "Waiting for authentication..."
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.LayoutOrder = 1
    statusLabel.ZIndex = 102
    statusLabel.Parent = body

    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, 0, 0, 48)
    inputFrame.BackgroundColor3 = PAL.surface
    inputFrame.BackgroundTransparency = 0.15
    inputFrame.BorderSizePixel = 0
    inputFrame.LayoutOrder = 2
    inputFrame.ZIndex = 102
    inputFrame.Parent = body
    corner(inputFrame, 12)
    stroke(inputFrame, PAL.border, 1, 0.4)

    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(1, -20, 1, 0)
    keyInput.Position = UDim2.fromOffset(10, 0)
    keyInput.BackgroundTransparency = 1
    keyInput.Font = Enum.Font.Code
    keyInput.TextSize = 14
    keyInput.TextColor3 = PAL.txt
    keyInput.PlaceholderText = "Paste your key here..."
    keyInput.PlaceholderColor3 = PAL.txtDim
    keyInput.Text = ""
    keyInput.ClearTextOnFocus = false
    keyInput.ZIndex = 103
    keyInput.Parent = inputFrame

    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(1, 0, 0, 44)
    submitBtn.BackgroundColor3 = PAL.accent
    submitBtn.Text = "🔓 Authenticate"
    submitBtn.TextColor3 = Color3.fromRGB(20, 25, 15)
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.TextSize = 15
    submitBtn.AutoButtonColor = false
    submitBtn.LayoutOrder = 3
    submitBtn.ZIndex = 102
    submitBtn.Parent = body
    corner(submitBtn, 12)
    shadow(submitBtn, 0, 12, 0.5, PAL.accent)

    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(1, 0, 0, 40)
    getKeyBtn.BackgroundColor3 = PAL.surface
    getKeyBtn.Text = "🔗 Get Key from Loot-Link"
    getKeyBtn.TextColor3 = PAL.txt
    getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.TextSize = 14
    getKeyBtn.AutoButtonColor = false
    getKeyBtn.LayoutOrder = 4
    getKeyBtn.ZIndex = 102
    getKeyBtn.Parent = body
    corner(getKeyBtn, 12)
    stroke(getKeyBtn, PAL.border, 1, 0.4)

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(1, 0, 0, 36)
    copyBtn.BackgroundColor3 = PAL.bgGlass2
    copyBtn.Text = "📋 Copy Link to Clipboard"
    copyBtn.TextColor3 = PAL.txtDim
    copyBtn.Font = Enum.Font.GothamMedium
    copyBtn.TextSize = 12
    copyBtn.AutoButtonColor = false
    copyBtn.LayoutOrder = 5
    copyBtn.ZIndex = 102
    copyBtn.Parent = body
    corner(copyBtn, 10)
    stroke(copyBtn, PAL.border, 1, 0.5)

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 0)
    infoLabel.AutomaticSize = Enum.AutomaticSize.Y
    infoLabel.BackgroundTransparency = 1
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 11
    infoLabel.TextColor3 = PAL.txtDim
    infoLabel.TextWrapped = true
    infoLabel.Text = "Keys are single-use per session. Each key has an expiration time. Visit the link above to get your unique key."
    infoLabel.LayoutOrder = 6
    infoLabel.ZIndex = 102
    infoLabel.Parent = body

    -- Button interactions
    submitBtn.MouseEnter:Connect(function()
        TweenService:Create(submitBtn, TweenInfo.new(0.2), {BackgroundColor3 = PAL.accent2}):Play()
    end)
    submitBtn.MouseLeave:Connect(function()
        TweenService:Create(submitBtn, TweenInfo.new(0.2), {BackgroundColor3 = PAL.accent}):Play()
    end)
    submitBtn.MouseButton1Down:Connect(function()
        TweenService:Create(submitBtn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 42)}):Play()
    end)
    submitBtn.MouseButton1Up:Connect(function()
        TweenService:Create(submitBtn, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 44)}):Play()
    end)

    getKeyBtn.MouseEnter:Connect(function()
        TweenService:Create(getKeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = PAL.surfaceLit}):Play()
    end)
    getKeyBtn.MouseLeave:Connect(function()
        TweenService:Create(getKeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = PAL.surface}):Play()
    end)

    copyBtn.MouseEnter:Connect(function()
        TweenService:Create(copyBtn, TweenInfo.new(0.2), {BackgroundColor3 = PAL.surface}):Play()
    end)
    copyBtn.MouseLeave:Connect(function()
        TweenService:Create(copyBtn, TweenInfo.new(0.2), {BackgroundColor3 = PAL.bgGlass2}):Play()
    end)

    local function doAuthenticate()
        local key = keyInput.Text:gsub("%s+", "")
        if key == "" then
            statusLabel.Text = "❌ Please enter a key"
            statusLabel.TextColor3 = PAL.accentHot
            return
        end

        statusLabel.Text = "⏳ Verifying key..."
        statusLabel.TextColor3 = PAL.accent2

        task.wait(0.5)

        if validateKey(key) then
            statusLabel.Text = "✅ Authentication successful!"
            statusLabel.TextColor3 = PAL.accent

            TweenService:Create(keyGui, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Size = UDim2.fromOffset(0, 0),
                BackgroundTransparency = 1,
                Rotation = -3
            }):Play()
            task.delay(0.55, function()
                if keyGui and keyGui.Parent then keyGui:Destroy() end
                if onAuthenticated then onAuthenticated() end
            end)
        else
            statusLabel.Text = "❌ Invalid or expired key"
            statusLabel.TextColor3 = PAL.accentHot
            TweenService:Create(inputFrame, TweenInfo.new(0.15), {Position = UDim2.fromOffset(10, 0)}):Play()
            task.delay(0.05, function()
                TweenService:Create(inputFrame, TweenInfo.new(0.15), {Position = UDim2.fromOffset(10, 0)}):Play()
            end)
            task.delay(0.1, function()
                TweenService:Create(inputFrame, TweenInfo.new(0.15), {Position = UDim2.fromOffset(10, 0)}):Play()
            end)
        end
    end

    submitBtn.MouseButton1Click:Connect(doAuthenticate)
    keyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then doAuthenticate() end
    end)

    getKeyBtn.MouseButton1Click:Connect(function()
        local ok = pcall(function()
            if request then
                request({
                    Url = KEY_CONFIG.lootLink,
                    Method = "GET"
                })
            elseif syn and syn.request then
                syn.request({
                    Url = KEY_CONFIG.lootLink,
                    Method = "GET"
                })
            end
        end)
        statusLabel.Text = "🌐 Opening Loot-Link..."
        statusLabel.TextColor3 = PAL.accent3
    end)

    copyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then
                setclipboard(KEY_CONFIG.lootLink)
            end
        end)
        statusLabel.Text = "📋 Link copied!"
        statusLabel.TextColor3 = PAL.accent
        task.delay(2, function()
            if statusLabel and statusLabel.Parent then
                statusLabel.Text = "Waiting for authentication..."
                statusLabel.TextColor3 = PAL.txtDim
            end
        end)
    end)

    -- Border glow animation
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

    keyGui.Destroying:Connect(function()
        if glowConn then glowConn:Disconnect() end
    end)

    -- Expiry checker
    if keyState.authenticated then
        task.spawn(function()
            while keyGui and keyGui.Parent do
                task.wait(KEY_CONFIG.checkInterval)
                if not keyGui or not keyGui.Parent then break end

                if keyState.expiresAt then
                    local remaining = keyState.expiresAt - tick()
                    if remaining <= 0 then
                        statusLabel.Text = "⏰ Key expired! Please re-authenticate."
                        statusLabel.TextColor3 = PAL.accentHot
                        clearKeyCache()
                    elseif remaining <= (KEY_CONFIG.graceMinutes * 60) and not keyState.warned then
                        keyState.warned = true
                        statusLabel.Text = "⚠️ Key expires in " .. getTimeRemaining() .. "!"
                        statusLabel.TextColor3 = PAL.accent2
                    end
                end
            end
        end)
    end
end


-- ================================================================
-- STATE TABLE (module level so makeToggle closure can access it)
-- ================================================================
local S = {
    upgrade=false, buy=false, drops=false, click=false,
    rebirth=false, ascend=false, evolve=false,
    powers=false, wake=false, offers=false, offline=false,
    mini=false, antiafk=false, harvest=false, remotebuy=false, autoeat=false, autopowers=false, perfmode=false,
    cUp=0, cBuy=0, cDrop=0, cMini=0, cHarvest=0, cRemoteBuy=0, cAutoEat=0, cAutoPowers=0
}

-- ================================================================
-- MAIN UI BUILDER (called after auth)
-- ================================================================
local function buildMainUI()
    -- Ambient background orbs
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

    local parX, parY = 0, 0
    local parTX, parTY = 0, 0

    local orbTime = 0
    local orbLastUpdate = 0
    local orbConn = RunService.Heartbeat:Connect(function(dt)
        local now = tick()
        if now - orbLastUpdate < 0.033 then return end
        orbLastUpdate = now
        orbTime += dt

        parX += (parTX - parX) * math.min(dt * 6, 1)
        parY += (parTY - parY) * math.min(dt * 6, 1)

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

    main.Size = UDim2.fromOffset(0, 0)
    main.BackgroundTransparency = 1
    TweenService:Create(main, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0.05), {
        Size = UDim2.fromOffset(560, 400),
        BackgroundTransparency = 0.1
    }):Play()

    local glow1 = stroke(main, PAL.accent, 2.5, 0.85)
    local glow1g = gradient(glow1, ColorSequence.new(PAL.accent, PAL.accent2), 0)
    local glow2 = stroke(main, PAL.accent3, 1.5, 0.9)
    local glow2g = gradient(glow2, ColorSequence.new(PAL.accent3, PAL.accent), 90)
    shadow(main, 8, 40, 0.6)

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

    local hTime = 0
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

    -- Key expiry label (NEW!)
    local keyExpiryLabel = Instance.new("TextLabel")
    keyExpiryLabel.Size = UDim2.fromOffset(200, 14)
    keyExpiryLabel.Position = UDim2.new(1, -210, 0, 40)
    keyExpiryLabel.BackgroundTransparency = 1
    keyExpiryLabel.Font = Enum.Font.GothamMedium
    keyExpiryLabel.TextSize = 11
    keyExpiryLabel.TextColor3 = PAL.accent
    keyExpiryLabel.Text = ""
    keyExpiryLabel.TextXAlignment = Enum.TextXAlignment.Right
    keyExpiryLabel.ZIndex = 22
    keyExpiryLabel.Parent = header

    -- Window controls
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

    -- Sidebar
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

    -- Scrollbar track
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

    local cursorLastUpdate = 0
    local cursorConn = RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - cursorLastUpdate < 0.033 then return end
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
    -- TABS SYSTEM
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
    -- TOGGLE COMPONENT
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

        local neuUp = shadow(row, -2, 8, 0.7)
        neuUp.ImageColor3 = Color3.fromRGB(255, 255, 255)
        neuUp.ImageTransparency = 0.85
        local neuDown = shadow(row, 2, 8, 0.7)

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

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(22, 22)
        knob.Position = UDim2.fromOffset(3, 3)
        knob.BackgroundColor3 = Color3.fromRGB(250, 251, 255)
        knob.BorderSizePixel = 0
        knob.ZIndex = 16
        knob.Parent = sw
        corner(knob, 11)
        shadow(knob, 0, 8, 0.6)

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
    sectionInfo(pPrest, "<font color='#FFAA55'>⚠ Ascend &amp; Evolve reset your tycoon for permanent multipliers.</font>")

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

    -- Stats card
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

    sectionInfo(pMisc, "<font color='#8A8F9C'>RightShift hides the menu  •  drag the header to move</font>")
    selectTab("Farm")

    -- ================================================================
    -- PARTICLE ENGINE
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

    -- Performance mode
    local perfConn = nil
    local function updatePerfMode()
        if S.perfmode then
            ambient.Visible = false
            particleCanvas.Visible = false
            cursorGlow.Visible = false
            if not perfConn then
                perfConn = RunService.Heartbeat:Connect(function()
                    if not S.perfmode then return end
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

    local perfCheckConn = RunService.Heartbeat:Connect(function()
        updatePerfMode()
    end)

    -- ================================================================
    -- BORDER GLOW ANIMATION
    -- ================================================================
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

    local upgradeCache = {}
    loop(0.15, function()
        if not S.upgrade then return end
        local myT = getMyTycoon()
        if not myT then return end
        for _, e in ipairs(CollectionService:GetTagged("Tycoon.Earner")) do
            if not S.upgrade then break end
            if not e:IsDescendantOf(myT) then continue end

            local uid = tostring(e)
            local r = e:FindFirstChild("Upgrade")
            if not (r and r:IsA("RemoteFunction")) then continue end

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
            if not anySuccess then
                upgradeCache[uid] = tick()
            end
        end
    end)

    local purchasedCache = {}
    local function isPurchaseReady(p)
        if not p or not p.Parent then return false end
        if p:GetAttribute("Purchased") then return false end
        if not p:GetAttribute("Enabled") then return false end
        if not p:GetAttribute("Shown") then return false end
        return true
    end

    loop(0.1, function()
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

    -- Auto Harvest
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

    -- Auto Upgrade Powers
    local POWER_NAMES = {"UpgradeStack", "BuyNext", "Manage", "WalkSpeed", "ClickFruitValue", "AutoFruit"}
    local powerFailStreak = {}
    local powerIdx = 1

    loop(0.05, function()
        if not S.autopowers then return end
        local myT = getMyTycoon()
        if not myT then return end
        local remotes = myT:FindFirstChild("Remotes")
        if not remotes then return end
        local r = remotes:FindFirstChild("UpgradePowerLevel")
        if not r then return end

        local batchCount = 0
        while S.autopowers and batchCount < 5 do
            local name = POWER_NAMES[powerIdx]
            if not name then powerIdx = 1 break end

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
            else
                powerFailStreak[name] = (powerFailStreak[name] or 0) + 1
                powerIdx = (powerIdx % #POWER_NAMES) + 1
                batchCount += 1
            end
        end
    end)

    loop(41, function()
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

    loop(7, function()
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

    loop(7, function()
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

    local powerCooldowns = {}
    local lastPowerTycoon = nil
    local legacyPowerIdx = 1
    loop(0.15, function()
        if not S.powers then return end
        local myT = getMyTycoon()
        if not myT then return end

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

    -- Remote Buy
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

    -- Auto Eater
    local autoEatNames = {"EatFruit", "AutoEat", "ConsumeFruit", "EatOrchardFruit"}
    local autoEatCache = {}
    loop(2, function()
        if not S.autoeat then return end
        local myT = getMyTycoon()
        if not myT then return end

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

        local currentName = myT and myT.Name or nil
        if currentName ~= lastTycoonName then
            lastTycoonName = currentName
            clearAllCaches()
            harvestEvent = nil
        end

        local cash = lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Cash") and lp.leaderstats.Cash.Value or "?"
        cashL.Text = "💰 " .. tostring(cash) .. "   •   " .. (currentName or "?")
        stats.Text = string.format("Upgrades    %d\nBuys        %d\nDrops       %d\nHarvests    %d\nPowers      %d\nRemoteBuy   %d\nAutoEat     %d\nRaces       %d", S.cUp, S.cBuy, S.cDrop, S.cHarvest, S.cAutoPowers, S.cRemoteBuy, S.cAutoEat, S.cMini)

        -- Update key expiry label
        if keyState.authenticated and keyState.expiresAt then
            keyExpiryLabel.Text = "⏳ " .. getTimeRemaining()
        else
            keyExpiryLabel.Text = ""
        end
    end)

    -- ================================================================
    -- CLEANUP
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

    print("lemon hub loaded")
end


-- ================================================================
-- ENTRY POINT
-- ================================================================
-- Try to load cached key first
if loadKeyCache() then
    -- Already authenticated, build main UI directly
    buildMainUI()
else
    -- Show key system UI
    createKeySystemUI(function()
        buildMainUI()
    end)
end
