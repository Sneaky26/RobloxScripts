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
frame.Size = UDim2.new(0, 280, 0, 430)
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
    btn.Size = UDim2.new(0.25, -3, 1, 0)
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
local tabCoords = makeTab("Coords", 0.75)  -- New Tab

-- Main Panel (Collector)
local mainPanel = Instance.new("Frame")
mainPanel.Size = UDim2.new(1, 0, 1, -68)
mainPanel.Position = UDim2.new(0, 0, 0, 68)
mainPanel.BackgroundTransparency = 1
mainPanel.Parent = frame

-- ... (All your original main panel elements: counter, status, toggles, auto zone button, etc.)

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
    {name = "Route 3", pos = Vector3.new(0, 50, 0)},      -- ← Replace with real coords
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

-- Coords Panel (New Tab)
local coordsPanel = Instance.new("Frame")
coordsPanel.Size = UDim2.new(1, 0, 1, -68)
coordsPanel.Position = UDim2.new(0, 0, 0, 68)
coordsPanel.BackgroundTransparency = 1
coordsPanel.Visible = false
coordsPanel.Parent = frame

local coordLabel = Instance.new("TextLabel")
coordLabel.Size = UDim2.new(1, -20, 0, 60)
coordLabel.Position = UDim2.new(0, 10, 0, 20)
coordLabel.BackgroundTransparency = 1
coordLabel.Text = "Click Get Position"
coordLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
coordLabel.TextScaled = true
coordLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
coordLabel.Parent = coordsPanel

local getCoordBtn = Instance.new("TextButton")
getCoordBtn.Size = UDim2.new(0.9, 0, 0, 50)
getCoordBtn.Position = UDim2.new(0.05, 0, 0, 100)
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
        print("📍 Current Position: " .. tostring(pos))
    else
        coordLabel.Text = "Character not loaded!"
    end
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

tabMain.MouseButton1Click:Connect(function() setTab("main") end)
tabEsp.MouseButton1Click:Connect(function() setTab("esp") end)
tabScan.MouseButton1Click:Connect(function() setTab("scan") end)
tabCoords.MouseButton1Click:Connect(function() setTab("coords") end)

setTab("main")

-- Rest of your script (ESP, Scan, Egg Collection, Auto Zone logic, etc.) remains the same as previous versions.

print("✅ Full Script Loaded with Coords Tab")
