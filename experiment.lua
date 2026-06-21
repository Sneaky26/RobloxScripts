local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

local collected = 0
local isRunning = false
local isMinimized = false
local espEnabled = false

-- ── Settings ─────────────────────────────────────────────────────────────────
local COLLECT_INTERVAL = 0.4
local MAX_PER_SWEEP = 8
local MAX_ESP_DISTANCE = 20  -- studs

-- Remove old UI
local old = player.PlayerGui:FindFirstChild("EggCollectorUI")
if old then old:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggCollectorUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
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
title.Text = "Egg Collector"
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
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Tabs
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 28)
tabFrame.Position = UDim2.new(0, 0, 0, 36)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = frame

local function makeTab(text, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -3, 1, 0)
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
local tabEsp = makeTab("ESP", 0.5)

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

-- ── ESP Panel ────────────────────────────────────────────────────────────────
local espPanel = Instance.new("Frame")
espPanel.Size = UDim2.new(1, 0, 1, -68)
espPanel.Position = UDim2.new(0, 0, 0, 68)
espPanel.BackgroundTransparency = 1
espPanel.Visible = false
espPanel.Parent = frame

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

local espNormal = Color3.fromRGB(255, 120, 50)
local espRare = Color3.fromRGB(255, 80, 255)

local espInfoLabel = Instance.new("TextLabel")
espInfoLabel.Size = UDim2.new(1, -10, 0, 16)
espInfoLabel.Position = UDim2.new(0, 5, 0, 52)
espInfoLabel.BackgroundTransparency = 1
espInfoLabel.Text = "Box + Text ESP (20 studs range)"
espInfoLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
espInfoLabel.TextSize = 10
espInfoLabel.Font = Enum.Font.Code
espInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
espInfoLabel.Parent = espPanel

local espCountLabel = Instance.new("TextLabel")
espCountLabel.Size = UDim2.new(1, 0, 0, 18)
espCountLabel.Position = UDim2.new(0, 0, 0, 120)
espCountLabel.BackgroundTransparency = 1
espCountLabel.Text = "Models visible: 0"
espCountLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
espCountLabel.TextScaled = true
espCountLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
espCountLabel.Parent = espPanel

-- Tab Switching
local function setTab(t)
    mainPanel.Visible = (t == "main")
    espPanel.Visible = (t == "esp")
    local active = Color3.fromRGB(60, 100, 180)
    local inactive = Color3.fromRGB(40, 40, 55)
    tabMain.BackgroundColor3 = t=="main" and active or inactive
    tabEsp.BackgroundColor3 = t=="esp" and active or inactive
end
setTab("main")
tabMain.MouseButton1Click:Connect(function() setTab("main") end)
tabEsp.MouseButton1Click:Connect(function() setTab("esp") end)

-- Minimize
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        frame.Size = UDim2.new(0, 280, 0, 35)
        minimizeBtn.Text = "□"
        tabFrame.Visible = false
        mainPanel.Visible = false
        espPanel.Visible = false
    else
        frame.Size = UDim2.new(0, 280, 0, 310)
        minimizeBtn.Text = "–"
        tabFrame.Visible = true
        mainPanel.Visible = true
        espPanel.Visible = false
    end
end)

-- ESP System
local espData = {}  -- part -> {highlight, billboard}

local function createESP(model)
    local root = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if not root or espData[root] then return end

    local isRare = model.Name:lower():find("rainbow") or model.Name:lower():find("alpha") or model.Name:lower():find("gradient")
    local color = isRare and espRare or espNormal
    local prefix = isRare and "⭐ " or ""

    -- Box Overlay (Highlight)
    local highlight = Instance.new("Highlight")
    highlight.Name = "EggESP_Box"
    highlight.FillTransparency = 0.85
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = color
    highlight.FillColor = color
    highlight.Adornee = model
    highlight.Parent = model

    -- Text Label
    local bb = Instance.new("BillboardGui")
    bb.Name = "EggESP_Text"
    bb.Size = UDim2.new(0, 220, 0, 36)
    bb.StudsOffset = Vector3.new(0, 4, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = MAX_ESP_DISTANCE + 5
    bb.Adornee = root
    bb.Parent = model

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    bg.BackgroundTransparency = 0.4
    bg.BorderSizePixel = 0
    bg.Parent = bb
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 5)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -12, 1, 0)
    lbl.Position = UDim2.new(0, 9, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = prefix .. model.Name
    lbl.TextColor3 = color
    lbl.TextSize = 16
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Parent = bg

    espData[root] = {highlight = highlight, billboard = bb}
end

local function removeESP(root)
    local data = espData[root]
    if data then
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
        espData[root] = nil
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
        for root in pairs(espData) do
            removeESP(root)
        end
    end
end)

local function isPlayerCharacter(model)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return true end
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(0.4)
        if not espEnabled then continue end

        local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then continue end

        local seen = {}
        local count = 0

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not obj:IsA("Model") or not obj.Name:lower():find("kyeggo") or isPlayerCharacter(obj) then continue end

            local root = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
            if not root then continue end

            local distance = (root.Position - rootPart.Position).Magnitude
            if distance > MAX_ESP_DISTANCE then 
                removeESP(root)
                continue 
            end

            seen[root] = true
            count += 1

            if not espData[root] then
                createESP(obj)
            end
        end

        -- Cleanup old ESP
        for root in pairs(espData) do
            if not seen[root] or not root.Parent then
                removeESP(root)
            end
        end

        espCountLabel.Text = "Models visible: " .. count
    end
end)

-- Auto Egg Collection (unchanged)
local function isGroundEggPos(obj)
    if not obj:IsA("MeshPart") then return false, nil end
    if not obj.Name:lower():find("egg") then return false, nil end
    if not obj.Parent or not obj.Parent.Name:lower():find("chunk") then return false, nil end
    return true, obj.Position
end

local function collectEggs()
    if not isRunning then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local originalCFrame = root.CFrame
    local eggsFound = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not isRunning or eggsFound >= MAX_PER_SWEEP then break end
        local ok, targetPos = isGroundEggPos(obj)
        if ok then
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

print("✅ Egg Collector LOADED - Box ESP + 20 Studs Range")
