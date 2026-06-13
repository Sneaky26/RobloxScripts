local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

local collected = 0
local isRunning = false
local isMinimized = false
local espEnabled = false
local autoRunEnabled = false
local autoEggRainEnabled = false

-- Settings
local COLLECT_INTERVAL = 0.3
local MAX_PER_SWEEP = 8
local CYCLE_INTERVAL = 15
local STAY_DURATION = 75 * 60  -- 1.25 hours

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

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 450)
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
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Tabs
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 28)
tabFrame.Position = UDim2.new(0, 0, 0, 36)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = frame

local function makeTab(text, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, -4, 1, 0)
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
local tabEsp = makeTab("ESP", 0.25)
local tabScan = makeTab("Scan", 0.5)
local tabCoords = makeTab("Coords", 0.75)

-- Main Panel
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

-- Auto Egg Rain Zone
local autoZoneBtn = Instance.new("TextButton")
autoZoneBtn.Size = UDim2.new(0.8, 0, 0, 35)
autoZoneBtn.Position = UDim2.new(0.1, 0, 0, 142)
autoZoneBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 200)
autoZoneBtn.Text = "Auto Egg Rain Zone: OFF"
autoZoneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoZoneBtn.TextScaled = true
autoZoneBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
autoZoneBtn.Parent = mainPanel
Instance.new("UICorner", autoZoneBtn).CornerRadius = UDim.new(0, 8)

local eggRainZones = {
    {name = "Route 3", pos = Vector3.new(0, 50, 0)},
    {name = "Route 4", pos = Vector3.new(0, 50, 0)},
    {name = "Route 6", pos = Vector3.new(0, 50, 0)},
    {name = "Route 8", pos = Vector3.new(0, 50, 0)},
    {name = "Cheshma Town", pos = Vector3.new(0, 50, 0)},
    {name = "Silvent City", pos = Vector3.new(0, 50, 0)},
    {name = "Heiwa Village", pos = Vector3.new(0, 50, 0)},
}

local currentZoneIndex = 1
local isLockedIn = false
local lockEndTime = 0

autoZoneBtn.MouseButton1Click:Connect(function()
    autoEggRainEnabled = not autoEggRainEnabled
    if autoEggRainEnabled then
        autoZoneBtn.Text = "Auto Egg Rain Zone: ON"
        autoZoneBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
    else
        autoZoneBtn.Text = "Auto Egg Rain Zone: OFF"
        autoZoneBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 200)
        isLockedIn = false
    end
end)

-- Coords Panel
local coordsPanel = Instance.new("Frame")
coordsPanel.Size = UDim2.new(1, 0, 1, -68)
coordsPanel.Position = UDim2.new(0, 0, 0, 68)
coordsPanel.BackgroundTransparency = 1
coordsPanel.Visible = false
coordsPanel.Parent = frame

local coordLabel = Instance.new("TextLabel")
coordLabel.Size = UDim2.new(1, -20, 0, 100)
coordLabel.Position = UDim2.new(0, 10, 0, 30)
coordLabel.BackgroundTransparency = 1
coordLabel.Text = "Stand in zone → Click button"
coordLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
coordLabel.TextScaled = true
coordLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
coordLabel.Parent = coordsPanel

local getCoordBtn = Instance.new("TextButton")
getCoordBtn.Size = UDim2.new(0.9, 0, 0, 50)
getCoordBtn.Position = UDim2.new(0.05, 0, 0, 150)
getCoordBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
getCoordBtn.Text = "Get Current Coordinates"
getCoordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
getCoordBtn.TextScaled = true
getCoordBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
getCoordBtn.Parent = coordsPanel
Instance.new("UICorner", getCoordBtn).CornerRadius = UDim.new(0, 8)

getCoordBtn.MouseButton1Click:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local pos = root.Position
        coordLabel.Text = string.format("X: %.2f\nY: %.2f\nZ: %.2f", pos.X, pos.Y, pos.Z)
        print("📍 Position: " .. tostring(pos))
    end
end)

-- ESP Panel
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

makeLegend("Normal Pokemon", Color3.fromRGB(255, 120, 50), 72)
makeLegend("Rare", Color3.fromRGB(255, 80, 255), 94)

local espCountLabel = Instance.new("TextLabel")
espCountLabel.Size = UDim2.new(1, 0, 0, 18)
espCountLabel.Position = UDim2.new(0, 0, 0, 120)
espCountLabel.BackgroundTransparency = 1
espCountLabel.Text = "Pokemon visible: 0"
espCountLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
espCountLabel.TextScaled = true
espCountLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
espCountLabel.Parent = espPanel

-- Scan Panel
local scanPanel = Instance.new("Frame")
scanPanel.Size = UDim2.new(1, 0, 1, -68)
scanPanel.Position = UDim2.new(0, 0, 0, 68)
scanPanel.BackgroundTransparency = 1
scanPanel.Visible = false
scanPanel.Parent = frame

local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(1, -10, 0, 28)
scanBtn.Position = UDim2.new(0, 5, 0, 4)
scanBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
scanBtn.Text = "Scan Active Battle GUIs"
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.TextScaled = true
scanBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
scanBtn.Parent = scanPanel
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0, 6)

local scanScroll = Instance.new("ScrollingFrame")
scanScroll.Size = UDim2.new(1, -8, 1, -40)
scanScroll.Position = UDim2.new(0, 4, 0, 36)
scanScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
scanScroll.BorderSizePixel = 0
scanScroll.ScrollBarThickness = 4
scanScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scanScroll.Parent = scanPanel
Instance.new("UICorner", scanScroll).CornerRadius = UDim.new(0, 6)

local scanLayout = Instance.new("UIListLayout")
scanLayout.SortOrder = Enum.SortOrder.LayoutOrder
scanLayout.Padding = UDim.new(0, 1)
scanLayout.Parent = scanScroll

local scanEntries = {}

local function scanLog(text, color)
    color = color or Color3.fromRGB(180, 200, 180)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 0, 12)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextSize = 9
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.Parent = scanScroll
    table.insert(scanEntries, lbl)
    if #scanEntries > 200 then
        scanEntries[1]:Destroy()
        table.remove(scanEntries, 1)
    end
    scanScroll.CanvasSize = UDim2.new(0, 0, 0, scanLayout.AbsoluteContentSize.Y + 6)
    scanScroll.CanvasPosition = Vector2.new(0, scanScroll.CanvasSize.Y.Offset)
end

local function clearScanLog()
    for _, e in ipairs(scanEntries) do e:Destroy() end
    scanEntries = {}
    scanScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
end

scanBtn.MouseButton1Click:Connect(function()
    clearScanLog()
    scanLog("=== BATTLE GUI SCAN ===", Color3.fromRGB(255, 220, 80))
    for _, gui in ipairs(player.PlayerGui:GetChildren()) do
        if gui.Name == "EggCollectorUI" or not gui:IsA("ScreenGui") then continue end
        scanLog("GUI: " .. gui.Name, Color3.fromRGB(100, 200, 255))
        for _, obj in ipairs(gui:GetDescendants()) do
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                local txt = obj.Text or "(ImageButton)"
                scanLog("BTN: " .. obj.Name .. " | Text: " .. txt, Color3.fromRGB(80, 255, 120))
            end
        end
    end
    scanLog("=== SCAN DONE ===", Color3.fromRGB(255, 220, 80))
end)

-- Tab Switching
local function setTab(t)
    mainPanel.Visible = (t == "main")
    espPanel.Visible = (t == "esp")
    scanPanel.Visible = (t == "scan")
    coordsPanel.Visible = (t == "coords")
    local active = Color3.fromRGB(60, 100, 180)
    local inactive = Color3.fromRGB(40, 40, 55)
    tabMain.BackgroundColor3 = t=="main" and active or inactive
    tabEsp.BackgroundColor3 = t=="esp" and active or inactive
    tabScan.BackgroundColor3 = t=="scan" and active or inactive
    tabCoords.BackgroundColor3 = t=="coords" and active or inactive
end
setTab("main")

tabMain.MouseButton1Click:Connect(function() setTab("main") end)
tabEsp.MouseButton1Click:Connect(function() setTab("esp") end)
tabScan.MouseButton1Click:Connect(function() setTab("scan") end)
tabCoords.MouseButton1Click:Connect(function() setTab("coords") end)

-- Minimize
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        frame.Size = UDim2.new(0, 280, 0, 35)
        minimizeBtn.Text = "□"
        tabFrame.Visible = false
        mainPanel.Visible = false
        espPanel.Visible = false
        scanPanel.Visible = false
        coordsPanel.Visible = false
    else
        frame.Size = UDim2.new(0, 280, 0, 450)
        minimizeBtn.Text = "–"
        tabFrame.Visible = true
        mainPanel.Visible = true
    end
end)

-- ESP System
local espLabels = {}

local function makeESPLabel(part, text, color)
    if espLabels[part] then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "KyeggoESP"
    bb.Size = UDim2.new(0, 200, 0, 28)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 300
    bb.Adornee = part
    bb.Parent = part
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    bg.BackgroundTransparency = 0.35
    bg.BorderSizePixel = 0
    bg.Parent = bb
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 5)
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
    if bb then bb:Destroy() espLabels[part] = nil end
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
    end
end)

local COMMON_KYEGGOS = {
    ["Kyeggo-rviolet"] = true,["Kyeggo-rorange"] = true,["Kyeggo-rred"] = true,
    ["Kyeggo-blue"] = true,["Kyeggo-green"] = true,
    ["Kyeggo-pattern4"] = true,["Kyeggo-pattern3"] = true,
    ["Kyeggo-pattern2"] = true,["Kyeggo-pattern1"] = true,
    ["Kyeggo-faberge1"] = true,["Kyeggo-faberge2"] = true,["Kyeggo-faberge3"] = true,
    ["Kyeggo"] = true,
}

task.spawn(function()
    while true do
        task.wait(0.5)
        if not espEnabled then continue end
        local seenParts = {}
        local npcCount = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not obj:IsA("Model") or not obj.Name:lower():find("^kyeggo") then continue end
            local root = obj:FindFirstChildWhichIsA("BasePart")
            if not root then continue end
            seenParts[root] = true
            npcCount += 1
            if not espLabels[root] then
                local rare = not COMMON_KYEGGOS[obj.Name]
                local color = rare and Color3.fromRGB(255, 80, 255) or Color3.fromRGB(255, 120, 50)
                local prefix = rare and "⭐ " or "🔵 "
                makeESPLabel(root, prefix .. obj.Name, color)
            end
        end
        for part in pairs(espLabels) do
            if not seenParts[part] or not part.Parent then removeESPLabel(part) end
        end
        espCountLabel.Text = "Pokemon visible: " .. npcCount
    end
end)

-- ==================== EGG COLLECTION ====================
local function collectEggs()
    if not isRunning then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local eggsFound = 0
    local playerPos = root.Position
    local foundWeatherEgg = false

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not isRunning or eggsFound >= MAX_PER_SWEEP then break end
        if not obj:IsA("MeshPart") or not obj.Name:lower():find("egg") then continue end

        local targetPos = obj.Position
        local parentName = (obj.Parent and obj.Parent.Name) or ""

        if parentName:lower():find("chunk") then
            eggsFound += 1
            root.CFrame = CFrame.new(targetPos + Vector3.new(0, 4, 0))
            task.wait(0.25)
            collected += 1
            counterLabel.Text = "Eggs Collected: " .. collected

        elseif parentName:lower() == "camera" or obj.Parent == Camera or parentName:lower():find("weather") or parentName:lower():find("effect") then
            local distance = (targetPos - playerPos).Magnitude
            if distance > 60 and distance < 900 then
                eggsFound += 1
                root.CFrame = CFrame.new(targetPos + Vector3.new(0, 4, 0))
                task.wait(0.3)
                collected += 1
                counterLabel.Text = "Eggs Collected: " .. collected
                foundWeatherEgg = true
            end
        end
    end

    if foundWeatherEgg and autoEggRainEnabled and not isLockedIn then
        isLockedIn = true
        lockEndTime = tick() + STAY_DURATION
        print("✅ Egg Rain Detected! Locked for 1.25 hours")
    end
end

task.spawn(function()
    while true do
        pcall(collectEggs)
        task.wait(COLLECT_INTERVAL)
    end
end)

-- Auto Egg Rain Logic
task.spawn(function()
    while true do
        task.wait(CYCLE_INTERVAL)
        if not autoEggRainEnabled then continue end
        if isLockedIn and tick() < lockEndTime then continue end

        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local zone = eggRainZones[currentZoneIndex]
        root.CFrame = CFrame.new(zone.pos + Vector3.new(0, 12, 0))
        currentZoneIndex = (currentZoneIndex % #eggRainZones) + 1
    end
end)

print("✅ FULL COMPLETE SCRIPT LOADED - Use Coords tab to get positions!")
