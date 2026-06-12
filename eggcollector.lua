local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera

local player = Players.LocalPlayer
local collected = 0
local isRunning = false
local isMinimized = false
local espEnabled = false
local autoRunEnabled = false

-- ── Settings ─────────────────────────────────────────────────────────────────
local COLLECT_INTERVAL = 0.4
local MAX_PER_SWEEP    = 8
-- ─────────────────────────────────────────────────────────────────────────────

-- Remove old UI
local old = player.PlayerGui:FindFirstChild("EggCollectorUI")
if old then old:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggCollectorUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

-- ── Main Frame ───────────────────────────────────────────────────────────────
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 310)
frame.Position = UDim2.new(0.5, -140, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Kyeggo Egg Collector"
title.TextColor3 = Color3.fromRGB(255, 220, 80)
title.TextScaled = true
title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
title.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
minimizeBtn.Position = UDim2.new(1, -64, 0, 4)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
minimizeBtn.Text = "–"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextScaled = true
minimizeBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
minimizeBtn.Parent = titleBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -32, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Tabs
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 28)
tabFrame.Position = UDim2.new(0, 0, 0, 36)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = frame

local function makeTab(text, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -4, 1, 0)
    btn.Position = UDim2.new(xPos, 2, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextScaled = true
    btn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    btn.Parent = tabFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end
local tabMain = makeTab("Collector", 0)
local tabEsp  = makeTab("ESP", 0.5)

-- ── Main Panel ───────────────────────────────────────────────────────────────
local mainPanel = Instance.new("Frame")
mainPanel.Size = UDim2.new(1, 0, 1, -68)
mainPanel.Position = UDim2.new(0, 0, 0, 68)
mainPanel.BackgroundTransparency = 1
mainPanel.Parent = frame

local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(1, 0, 0, 25)
counterLabel.Position = UDim2.new(0, 0, 0, 8)
counterLabel.BackgroundTransparency = 1
counterLabel.Text = "Eggs Collected: 0"
counterLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
counterLabel.TextScaled = true
counterLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
counterLabel.Parent = mainPanel

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 36)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: OFF"
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextScaled = true
statusLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
statusLabel.Parent = mainPanel

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.1, 0, 0, 62)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
toggleBtn.Text = "START"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextScaled = true
toggleBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
toggleBtn.Parent = mainPanel
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

toggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        toggleBtn.Text = "STOP"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        statusLabel.Text = "Status: ON"
        statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
    else
        toggleBtn.Text = "START"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        statusLabel.Text = "Status: OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

local autoRunToggle = Instance.new("TextButton")
autoRunToggle.Size = UDim2.new(0.8, 0, 0, 30)
autoRunToggle.Position = UDim2.new(0.1, 0, 0, 104)
autoRunToggle.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
autoRunToggle.Text = "Auto-Run: OFF"
autoRunToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoRunToggle.TextScaled = true
autoRunToggle.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
autoRunToggle.Parent = mainPanel
Instance.new("UICorner", autoRunToggle).CornerRadius = UDim.new(0, 8)

autoRunToggle.MouseButton1Click:Connect(function()
    autoRunEnabled = not autoRunEnabled
    if autoRunEnabled then
        autoRunToggle.Text = "Auto-Run: ON"
        autoRunToggle.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
    else
        autoRunToggle.Text = "Auto-Run: OFF"
        autoRunToggle.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

local encounterLabel = Instance.new("TextLabel")
encounterLabel.Size = UDim2.new(1, 0, 0, 18)
encounterLabel.Position = UDim2.new(0, 0, 0, 140)
encounterLabel.BackgroundTransparency = 1
encounterLabel.Text = "Last Encounter: —"
encounterLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
encounterLabel.TextScaled = true
encounterLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
encounterLabel.Parent = mainPanel

-- ── ESP Panel ────────────────────────────────────────────────────────────────
local espPanel = Instance.new("Frame")
espPanel.Size = UDim2.new(1, 0, 1, -68)
espPanel.Position = UDim2.new(0, 0, 0, 68)
espPanel.BackgroundTransparency = 1
espPanel.Visible = false
espPanel.Parent = frame

-- ESP toggle button
local espToggleBtn = Instance.new("TextButton")
espToggleBtn.Size = UDim2.new(0.8, 0, 0, 35)
espToggleBtn.Position = UDim2.new(0.1, 0, 0, 10)
espToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
espToggleBtn.Text = "ESP: OFF"
espToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggleBtn.TextScaled = true
espToggleBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
espToggleBtn.Parent = espPanel
Instance.new("UICorner", espToggleBtn).CornerRadius = UDim.new(0, 8)

-- Legend
local function makeLegend(text, color, yPos)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, 12, 0, yPos + 4)
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    dot.Parent = espPanel
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -30, 0, 18)
    lbl.Position = UDim2.new(0, 28, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = espPanel
end

local espNormalPokemon = Color3.fromRGB(255, 120, 50)  -- orange     = normal pokemon
local espRarePokemon   = Color3.fromRGB(255, 80, 255)  -- magenta    = rare variant (rainbow/gradient/alpha/gamma/wisp)

local espInfoLabel = Instance.new("TextLabel")
espInfoLabel.Size = UDim2.new(1, -10, 0, 16)
espInfoLabel.Position = UDim2.new(0, 5, 0, 52)
espInfoLabel.BackgroundTransparency = 1
espInfoLabel.Text = "Labels all NPCs/Pokemon + currency eggs"
espInfoLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
espInfoLabel.TextSize = 10
espInfoLabel.Font = Enum.Font.Code
espInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
espInfoLabel.Parent = espPanel

makeLegend("Normal Pokemon",                    espNormalPokemon, 72)
makeLegend("Rare (Rainbow/Gradient/Alpha/etc.)", espRarePokemon,   94)

local espCountLabel = Instance.new("TextLabel")
espCountLabel.Size = UDim2.new(1, 0, 0, 18)
espCountLabel.Position = UDim2.new(0, 0, 0, 120)
espCountLabel.BackgroundTransparency = 1
espCountLabel.Text = "Eggs: 0  |  NPCs: 0"
espCountLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
espCountLabel.TextScaled = true
espCountLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
espCountLabel.Parent = espPanel

-- ── Tab Switching ─────────────────────────────────────────────────────────────
local function setTab(isEsp)
    mainPanel.Visible = not isEsp
    espPanel.Visible  = isEsp
    if isEsp then
        tabEsp.BackgroundColor3  = Color3.fromRGB(60, 100, 180)
        tabEsp.TextColor3        = Color3.fromRGB(255, 255, 255)
        tabMain.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        tabMain.TextColor3       = Color3.fromRGB(180, 180, 180)
    else
        tabMain.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
        tabMain.TextColor3       = Color3.fromRGB(255, 255, 255)
        tabEsp.BackgroundColor3  = Color3.fromRGB(40, 40, 55)
        tabEsp.TextColor3        = Color3.fromRGB(180, 180, 180)
    end
end
setTab(false)
tabMain.MouseButton1Click:Connect(function() setTab(false) end)
tabEsp.MouseButton1Click:Connect(function()  setTab(true)  end)

-- ── Minimize ──────────────────────────────────────────────────────────────────
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        frame.Size = UDim2.new(0, 280, 0, 35)
        minimizeBtn.Text = "□"
        tabFrame.Visible  = false
        mainPanel.Visible = false
        espPanel.Visible  = false
    else
        frame.Size = UDim2.new(0, 280, 0, 310)
        minimizeBtn.Text = "–"
        tabFrame.Visible  = true
        mainPanel.Visible = true
        espPanel.Visible  = false
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- ── ESP System ───────────────────────────────────────────────────────────────
-- Uses BillboardGuis attached directly to parts so labels float above objects
-- in world-space. Much cleaner than screen-space projection.
-- ══════════════════════════════════════════════════════════════════════════════

local espLabels = {}  -- [part] = BillboardGui

local function isGroundEgg(obj)
    if not obj:IsA("MeshPart") then return false end
    if not obj.Name:lower():find("egg") then return false end
    if not obj.Parent then return false end
    if not obj.Parent.Name:lower():find("chunk") then return false end
    return true
end

local function makeESPLabel(part, text, color)
    if espLabels[part] then return end  -- already has one

    local bb = Instance.new("BillboardGui")
    bb.Name = "KyeggoESP"
    bb.Size = UDim2.new(0, 200, 0, 28)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 300
    bb.Adornee = part
    bb.Parent = part  -- parent to part so it auto-removes when part does

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    bg.BackgroundTransparency = 0.35
    bg.BorderSizePixel = 0
    bg.Parent = bb
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 5)

    -- Coloured left stripe
    local stripe = Instance.new("Frame")
    stripe.Size = UDim2.new(0, 4, 1, 0)
    stripe.BackgroundColor3 = color
    stripe.BorderSizePixel = 0
    stripe.Parent = bg
    Instance.new("UICorner", stripe).CornerRadius = UDim.new(0, 4)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 1, 0)
    lbl.Position = UDim2.new(0, 7, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Parent = bg

    espLabels[part] = bb
end

local function removeESPLabel(part)
    local bb = espLabels[part]
    if bb then
        bb:Destroy()
        espLabels[part] = nil
    end
end

local function clearAllESP()
    for part, bb in pairs(espLabels) do
        if bb and bb.Parent then bb:Destroy() end
        espLabels[part] = nil
    end
end

espToggleBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        espToggleBtn.Text = "ESP: ON"
        espToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
    else
        espToggleBtn.Text = "ESP: OFF"
        espToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        clearAllESP()
        espCountLabel.Text = "Eggs visible: 0"
    end
end)

-- ── NPC / Pokemon color ─────────────────────────────────────────────────────
-- Exact model names that are NOT rare — auto-run on these
local COMMON_KYEGGOS = {
    ["Kyeggo-rviolet"]  = true,
    ["Kyeggo-rorange"]  = true,
    ["Kyeggo-rred"]     = true,
    ["Kyeggo-rblue"]     = true,
    ["Kyeggo-rgreen"]    = true,
    ["Kyeggo-pattern4"] = true,
    ["Kyeggo-pattern3"] = true,
    ["Kyeggo-pattern2"] = true,
    ["Kyeggo-pattern1"] = true,
    ["Kyeggo-faberge1"] = true,
    ["Kyeggo-faberge2"] = true,
    ["Kyeggo-faberge3"] = true,
    ["Kyeggo"]          = true,
}

-- Any Kyeggo NOT in the common list = rare, notify user
local function isRareKyeggo(name)
    return not COMMON_KYEGGOS[name]
end

-- Skip list — ignore these model names so ESP isn't cluttered with map junk
local SKIP_NAMES = {
    ["Baseplate"] = true, ["Terrain"] = true, ["Camera"] = true,
    ["SpawnLocation"] = true, ["Sky"] = true, ["Lighting"] = true,
    ["SunRaysEffect"] = true, ["Atmosphere"] = true,
}

local function isPlayerCharacter(model)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return true end
    end
    return false
end

-- Get the root part of a model to attach ESP to
local function getModelRoot(model)
    if model.PrimaryPart then return model.PrimaryPart end
    local h = model:FindFirstChildWhichIsA("BasePart", true)
    return h
end

-- Get distance from local player to a position
local function distTo(pos)
    local char = player.Character
    if not char then return 9999 end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return 9999 end
    return (root.Position - pos).Magnitude
end

-- Refresh ESP every 0.5s
task.spawn(function()
    while true do
        task.wait(0.5)
        if not espEnabled then continue end

        local seenParts = {}
        local npcCount  = 0

        -- ── Kyeggo models only ────────────────────────────────────────────────
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not obj:IsA("Model") then continue end
            -- Only care about models starting with "Kyeggo" (case-insensitive)
            if not obj.Name:lower():sub(1, 6) == "kyeggo" then continue end
            if not obj.Name:lower():find("^kyeggo") then continue end
            if isPlayerCharacter(obj) then continue end

            local root = getModelRoot(obj)
            if not root then continue end

            seenParts[root] = true
            npcCount += 1

            if not espLabels[root] then
                local rare = isRareKyeggo(obj.Name)
                local prefix = rare and "⭐ " or "🔵 "
                local color  = rare and espRarePokemon or espNormalPokemon
                makeESPLabel(root, prefix .. obj.Name, color)
            end
        end

        -- Remove stale labels
        for part, _ in pairs(espLabels) do
            if not seenParts[part] or not part.Parent then
                removeESPLabel(part)
            end
        end

        espCountLabel.Text = "Pokemon visible: " .. npcCount
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- ── Ground Egg Check (collection) ────────────────────────────────────────────
-- ══════════════════════════════════════════════════════════════════════════════
local function isGroundEggPos(obj)
    if not obj:IsA("MeshPart") then return false, nil end
    if not obj.Name:lower():find("egg") then return false, nil end
    if not obj.Parent then return false, nil end
    if not obj.Parent.Name:lower():find("chunk") then return false, nil end
    return true, obj.Position
end

-- ── Collection Loop ───────────────────────────────────────────────────────────
local function collectEggs()
    if not isRunning then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local originalCFrame = root.CFrame
    local eggsFound = 0

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not isRunning then break end
        if eggsFound >= MAX_PER_SWEEP then break end

        local ok, targetPos = isGroundEggPos(obj)
        if ok and targetPos then
            eggsFound += 1
            root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
            task.wait(0.12)
            root.CFrame = originalCFrame
            task.wait(0.08)
            collected += 1
            counterLabel.Text = "Eggs Collected: " .. collected
        end
    end
end

task.spawn(function()
    while true do
        pcall(collectEggs)
        task.wait(COLLECT_INTERVAL)
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- ── Auto-Run Filter ───────────────────────────────────────────────────────────
-- ══════════════════════════════════════════════════════════════════════════════
-- isKeeper: scans GUI text for any Kyeggo name that is NOT in the common list
-- Returns true + the name if it's a rare Kyeggo worth keeping
local function isKeeper(text)
    -- Check for exact common names first — if found, it's NOT a keeper
    for name, _ in pairs(COMMON_KYEGGOS) do
        if text:find(name, 1, true) then
            return false, name
        end
    end
    -- If the battle screen mentions any Kyeggo at all but it's not in common list = rare
    if text:lower():find("kyeggo") then
        -- Extract the Kyeggo name from text for the notification
        local found = text:match("Kyeggo%S*") or text:match("kyeggo%S*") or "Kyeggo variant"
        return true, found
    end
    return false, nil
end

local function getAllText(gui)
    local texts = {}
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            if obj.Text and obj.Text ~= "" then
                table.insert(texts, obj.Text)
            end
        end
    end
    return table.concat(texts, " ")
end

local function clickRunButton(gui)
    local target = nil

    -- Pass 1: exact text "Run"
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") and obj.Text == "Run" then
            target = obj break
        end
    end
    -- Pass 2: name contains "run"
    if not target then
        for _, obj in ipairs(gui:GetDescendants()) do
            if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Name:lower():find("run") then
                target = obj break
            end
        end
    end

    if not target then return false, nil end

    -- Try all firing methods — Loomian Legacy uses a custom button handler
    pcall(function() target.MouseButton1Click:Fire() end)
    pcall(function() target.Activated:Fire() end)
    -- Simulate real mouse click via VirtualUser if available
    pcall(function()
        local vu = game:GetService("VirtualUser")
        local pos = target.AbsolutePosition
        local size = target.AbsoluteSize
        vu:Button1Down(Vector2.new(pos.X + size.X/2, pos.Y + size.Y/2), CFrame.new())
        task.wait(0.05)
        vu:Button1Up(Vector2.new(pos.X + size.X/2, pos.Y + size.Y/2), CFrame.new())
    end)

    return true, target.Text or target.Name
end

local function isBattleGui(gui)
    if not gui:IsA("ScreenGui") then return false end
    local hasRun, hasFight, hasLoomians = false, false, false
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") then
            if obj.Text == "Run"      then hasRun      = true end
            if obj.Text == "Fight"    then hasFight    = true end
            if obj.Text == "Loomians" then hasLoomians = true end
        end
    end
    return hasRun and hasFight and hasLoomians
end

local function showNotif(text, color)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 260, 0, 44)
    notif.Position = UDim2.new(0.5, -130, 1, -60)
    notif.BackgroundColor3 = color or Color3.fromRGB(30, 30, 45)
    notif.BorderSizePixel = 0
    notif.Parent = screenGui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.Position = UDim2.new(0, 5, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextScaled = true
    lbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    lbl.Parent = notif
    task.delay(3.5, function()
        if notif and notif.Parent then notif:Destroy() end
    end)
end

local watchedGuis = {}

task.spawn(function()
    while true do
        task.wait(0.3)
        if not autoRunEnabled then continue end

        for _, gui in ipairs(player.PlayerGui:GetChildren()) do
            if gui.Name == "EggCollectorUI" then continue end
            if watchedGuis[gui] then continue end
            if not gui:IsA("ScreenGui") then continue end
            if not gui.Enabled then continue end

            if isBattleGui(gui) then
                watchedGuis[gui] = true
                local fullText = getAllText(gui)
                local keep, reason = isKeeper(fullText)

                if keep then
                    showNotif("⭐ KEEPER: " .. reason:upper() .. "! Stay!", Color3.fromRGB(255, 180, 0))
                    encounterLabel.Text = "Last: KEEPER (" .. reason .. ")"
                    encounterLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
                else
                    showNotif("🏃 Auto-running in 3s...", Color3.fromRGB(80, 80, 120))
                    encounterLabel.Text = "Last: Skipped (running...)"
                    encounterLabel.TextColor3 = Color3.fromRGB(180, 180, 180)

                    task.wait(3)

                    if not isKeeper(getAllText(gui)) then
                        local clicked, btnName = clickRunButton(gui)
                        if clicked then
                            encounterLabel.Text = "Last: Skipped ✓"
                        else
                            encounterLabel.Text = "Last: Run btn not found ⚠"
                            showNotif("⚠ Run button not found!", Color3.fromRGB(200, 100, 0))
                        end
                    end
                end

                task.delay(10, function() watchedGuis[gui] = nil end)
            end
        end
    end
end)

print("✅ Kyeggo Egg Collector loaded — ESP + Auto-Run ready")
