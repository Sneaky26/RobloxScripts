local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

local collected = 0
local isRunning = false
local isMinimized = false
local espEnabled = false
local autoRunEnabled = false

-- ── Settings ──────────────────────────────────────────────────────────────────
local COLLECT_INTERVAL = 0.4
local MAX_PER_SWEEP = 8

-- ── Run Button Circle Position (center of screen by default) ──────────────────
local runBtnPos = nil -- will be set after Camera is ready
local runBtnRadius = 40

-- ── Ignore List (true = auto-run/skip, false = keep/don't run) ───────────────
local ignoreList = {
    ["Kyeggo-rviolet"]  = true,
    ["Kyeggo-rorange"]  = true,
    ["Kyeggo-rred"]     = true,
    ["Kyeggo-blue"]     = true,
    ["Kyeggo-green"]    = true,
    ["Kyeggo-pattern4"] = true,
    ["Kyeggo-pattern3"] = true,
    ["Kyeggo-pattern2"] = true,
    ["Kyeggo-pattern1"] = true,
    ["Kyeggo-faberge1"] = true,
    ["Kyeggo-faberge2"] = true,
    ["Kyeggo-faberge3"] = true,
    ["Kyeggo"]          = true,
}

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

-- ── Main Frame ────────────────────────────────────────────────────────────────
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 340)
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
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- ── Tabs (now 4: Main, ESP, Scan, List) ──────────────────────────────────────
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 28)
tabFrame.Position = UDim2.new(0, 0, 0, 36)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = frame

local function makeTab(text, xPos, width)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(width, -3, 1, 0)
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

local tabMain = makeTab("Collect", 0,      0.25)
local tabEsp  = makeTab("ESP",     0.25,   0.25)
local tabScan = makeTab("Scan",    0.5,    0.25)
local tabList = makeTab("List",    0.75,   0.25)

-- ── Main Panel ────────────────────────────────────────────────────────────────
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
encounterLabel.Position = UDim2.new(0, 0, 0, 142)
encounterLabel.BackgroundTransparency = 1
encounterLabel.Text = "Last Encounter: —"
encounterLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
encounterLabel.TextScaled = true
encounterLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
encounterLabel.Parent = mainPanel

-- Run Button Circle Setup button
local setupRunBtn = Instance.new("TextButton")
setupRunBtn.Size = UDim2.new(0.8, 0, 0, 28)
setupRunBtn.Position = UDim2.new(0.1, 0, 0, 168)
setupRunBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 160)
setupRunBtn.Text = "🎯 Set Run Button Position"
setupRunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setupRunBtn.TextScaled = true
setupRunBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
setupRunBtn.Parent = mainPanel
Instance.new("UICorner", setupRunBtn).CornerRadius = UDim.new(0, 8)

local runBtnLabel = Instance.new("TextLabel")
runBtnLabel.Size = UDim2.new(1, 0, 0, 16)
runBtnLabel.Position = UDim2.new(0, 0, 0, 202)
runBtnLabel.BackgroundTransparency = 1
runBtnLabel.Text = "Drag circle to Run button, then confirm"
runBtnLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
runBtnLabel.TextSize = 10
runBtnLabel.Font = Enum.Font.Code
runBtnLabel.Parent = mainPanel

-- ── Run Button Circle Overlay ─────────────────────────────────────────────────
local circleGui = Instance.new("Frame")
circleGui.Size = UDim2.new(0, runBtnRadius*2, 0, runBtnRadius*2)
circleGui.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
circleGui.BackgroundTransparency = 0.5
circleGui.BorderSizePixel = 0
circleGui.Visible = false
circleGui.Active = true
circleGui.Draggable = true
circleGui.ZIndex = 100
circleGui.Parent = screenGui
local circleCorner = Instance.new("UICorner", circleGui)
circleCorner.CornerRadius = UDim.new(1, 0)

local circleLabel = Instance.new("TextLabel")
circleLabel.Size = UDim2.new(1, 0, 0.5, 0)
circleLabel.Position = UDim2.new(0, 0, 0.1, 0)
circleLabel.BackgroundTransparency = 1
circleLabel.Text = "RUN"
circleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
circleLabel.TextScaled = true
circleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
circleLabel.Parent = circleGui

-- Size slider row inside the circle overlay area
local sizeLabel = Instance.new("TextLabel")
sizeLabel.Size = UDim2.new(1, 0, 0, 14)
sizeLabel.Position = UDim2.new(0, 0, 0.6, 0)
sizeLabel.BackgroundTransparency = 1
sizeLabel.Text = "Size: 40"
sizeLabel.TextColor3 = Color3.fromRGB(255, 255, 200)
sizeLabel.TextSize = 11
sizeLabel.Font = Enum.Font.GothamBold
sizeLabel.Parent = circleGui

-- Confirm button shown near circle
local confirmCircleBtn = Instance.new("TextButton")
confirmCircleBtn.Size = UDim2.new(0, 90, 0, 26)
confirmCircleBtn.Position = UDim2.new(0, runBtnRadius*2 + 6, 0, 0)
confirmCircleBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
confirmCircleBtn.Text = "✔ Confirm"
confirmCircleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmCircleBtn.TextScaled = true
confirmCircleBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
confirmCircleBtn.Visible = false
confirmCircleBtn.ZIndex = 101
confirmCircleBtn.Parent = screenGui
Instance.new("UICorner", confirmCircleBtn).CornerRadius = UDim.new(0, 6)

local cancelCircleBtn = Instance.new("TextButton")
cancelCircleBtn.Size = UDim2.new(0, 90, 0, 26)
cancelCircleBtn.Position = UDim2.new(0, 0, 0, 0) -- positioned near circle
cancelCircleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
cancelCircleBtn.Text = "✖ Cancel"
cancelCircleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cancelCircleBtn.TextScaled = true
cancelCircleBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
cancelCircleBtn.Visible = false
cancelCircleBtn.ZIndex = 101
cancelCircleBtn.Parent = screenGui
Instance.new("UICorner", cancelCircleBtn).CornerRadius = UDim.new(0, 6)

-- Size +/- buttons on the circle
local sizePlusBtn = Instance.new("TextButton")
sizePlusBtn.Size = UDim2.new(0, 22, 0, 22)
sizePlusBtn.Position = UDim2.new(1, -24, 0, 2)
sizePlusBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
sizePlusBtn.Text = "+"
sizePlusBtn.TextColor3 = Color3.fromRGB(255,255,255)
sizePlusBtn.TextScaled = true
sizePlusBtn.ZIndex = 102
sizePlusBtn.Parent = circleGui
Instance.new("UICorner", sizePlusBtn).CornerRadius = UDim.new(0,4)

local sizeMinusBtn = Instance.new("TextButton")
sizeMinusBtn.Size = UDim2.new(0, 22, 0, 22)
sizeMinusBtn.Position = UDim2.new(0, 2, 0, 2)
sizeMinusBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
sizeMinusBtn.Text = "–"
sizeMinusBtn.TextColor3 = Color3.fromRGB(255,255,255)
sizeMinusBtn.TextScaled = true
sizeMinusBtn.ZIndex = 102
sizeMinusBtn.Parent = circleGui
Instance.new("UICorner", sizeMinusBtn).CornerRadius = UDim.new(0,4)

local function updateCircleSize()
    circleGui.Size = UDim2.new(0, runBtnRadius*2, 0, runBtnRadius*2)
    sizeLabel.Text = "Size: " .. runBtnRadius
end

sizePlusBtn.MouseButton1Click:Connect(function()
    runBtnRadius = math.min(runBtnRadius + 5, 120)
    updateCircleSize()
end)

sizeMinusBtn.MouseButton1Click:Connect(function()
    runBtnRadius = math.max(runBtnRadius - 5, 15)
    updateCircleSize()
end)

local isSettingRunBtn = false

local function updateConfirmPos()
    local cp = circleGui.AbsolutePosition
    local cs = circleGui.AbsoluteSize
    confirmCircleBtn.Position = UDim2.new(0, cp.X + cs.X + 6, 0, cp.Y)
    cancelCircleBtn.Position  = UDim2.new(0, cp.X + cs.X + 6, 0, cp.Y + 32)
end

setupRunBtn.MouseButton1Click:Connect(function()
    if isSettingRunBtn then return end
    isSettingRunBtn = true
    -- Place circle in center of screen
    local vp = Camera.ViewportSize
    local r = runBtnRadius
    circleGui.Position = UDim2.new(0, vp.X/2 - r, 0, vp.Y/2 - r)
    circleGui.Visible = true
    confirmCircleBtn.Visible = true
    cancelCircleBtn.Visible = true
    updateConfirmPos()
    setupRunBtn.Text = "🎯 Positioning..."
    setupRunBtn.BackgroundColor3 = Color3.fromRGB(200, 130, 0)
    runBtnLabel.Text = "Drag the circle to the Run button"
end)

-- Update confirm/cancel pos as circle is dragged
task.spawn(function()
    while true do
        task.wait(0.05)
        if isSettingRunBtn and circleGui.Visible then
            updateConfirmPos()
        end
    end
end)

confirmCircleBtn.MouseButton1Click:Connect(function()
    local ap = circleGui.AbsolutePosition
    local as = circleGui.AbsoluteSize
    runBtnPos = Vector2.new(ap.X + as.X/2, ap.Y + as.Y/2)
    circleGui.Visible = false
    confirmCircleBtn.Visible = false
    cancelCircleBtn.Visible = false
    isSettingRunBtn = false
    setupRunBtn.Text = "🎯 Run Btn Set ✔"
    setupRunBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
    runBtnLabel.Text = string.format("Position: %.0f, %.0f | Size: %d", runBtnPos.X, runBtnPos.Y, runBtnRadius)
end)

cancelCircleBtn.MouseButton1Click:Connect(function()
    circleGui.Visible = false
    confirmCircleBtn.Visible = false
    cancelCircleBtn.Visible = false
    isSettingRunBtn = false
    setupRunBtn.Text = "🎯 Set Run Button Position"
    setupRunBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 160)
    runBtnLabel.Text = "Drag circle to Run button, then confirm"
end)

-- ── ESP Panel ─────────────────────────────────────────────────────────────────
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

local espNormalColor = Color3.fromRGB(255, 120, 50)
local espRareColor   = Color3.fromRGB(255, 80, 255)
local espAlphaColor  = Color3.fromRGB(255, 210, 0)    -- Gold
local espGammaColor  = Color3.fromRGB(0, 220, 200)    -- Teal

local espInfoLabel = Instance.new("TextLabel")
espInfoLabel.Size = UDim2.new(1, -10, 0, 16)
espInfoLabel.Position = UDim2.new(0, 5, 0, 52)
espInfoLabel.BackgroundTransparency = 1
espInfoLabel.Text = "Labels all Kyeggos + special variants"
espInfoLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
espInfoLabel.TextSize = 10
espInfoLabel.Font = Enum.Font.Code
espInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
espInfoLabel.Parent = espPanel

makeLegend("Normal Kyeggo",                    espNormalColor, 72)
makeLegend("Rare variant",                     espRareColor,   94)
makeLegend("✨ Alpha Kyeggo (sparkle)",         espAlphaColor,  116)
makeLegend("🔮 Gamma Kyeggo (orbiting balls)", espGammaColor,  138)

local espCountLabel = Instance.new("TextLabel")
espCountLabel.Size = UDim2.new(1, 0, 0, 18)
espCountLabel.Position = UDim2.new(0, 0, 0, 162)
espCountLabel.BackgroundTransparency = 1
espCountLabel.Text = "Kyeggos visible: 0  |  Alpha/Gamma: 0"
espCountLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
espCountLabel.TextScaled = true
espCountLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
espCountLabel.Parent = espPanel

-- ── Scan Panel ────────────────────────────────────────────────────────────────
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

local dumpBtn = Instance.new("TextButton")
dumpBtn.Size = UDim2.new(1, -10, 0, 28)
dumpBtn.Position = UDim2.new(0, 5, 0, 36)
dumpBtn.BackgroundColor3 = Color3.fromRGB(140, 60, 200)
dumpBtn.Text = "🔍 Dump Nearby Models (60 studs)"
dumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dumpBtn.TextScaled = true
dumpBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
dumpBtn.Parent = scanPanel
Instance.new("UICorner", dumpBtn).CornerRadius = UDim.new(0, 6)

local scanScroll = Instance.new("ScrollingFrame")
scanScroll.Size = UDim2.new(1, -8, 1, -72)
scanScroll.Position = UDim2.new(0, 4, 0, 68)
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
local scanLogOrder = 0

local function scanLog(text, color)
    color = color or Color3.fromRGB(180, 200, 180)
    scanLogOrder += 1
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
    lbl.LayoutOrder = scanLogOrder
    lbl.Parent = scanScroll
    table.insert(scanEntries, lbl)
    if #scanEntries > 200 then
        scanEntries[1]:Destroy()
        table.remove(scanEntries, 1)
    end
    -- defer so AutomaticSize resolves before measuring canvas
    task.defer(function()
        scanScroll.CanvasSize = UDim2.new(0, 0, 0, scanLayout.AbsoluteContentSize.Y + 6)
        scanScroll.CanvasPosition = Vector2.new(0, scanScroll.CanvasSize.Y.Offset)
    end)
end

local function clearScanLog()
    for _, e in ipairs(scanEntries) do e:Destroy() end
    scanEntries = {}
    scanLogOrder = 0
    scanScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
end

dumpBtn.MouseButton1Click:Connect(function()
    clearScanLog()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        scanLog("❌ No character found!", Color3.fromRGB(255, 80, 80))
        return
    end
    local playerPos = root.Position
    scanLog("=== NEARBY MODELS (60 studs) ===", Color3.fromRGB(180, 100, 255))
    scanLog("Player pos: " .. math.floor(playerPos.X) .. ", " .. math.floor(playerPos.Y) .. ", " .. math.floor(playerPos.Z), Color3.fromRGB(150, 150, 200))

    local found = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local modelRoot = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
            if modelRoot then
                local dist = (modelRoot.Position - playerPos).Magnitude
                if dist <= 60 then
                    table.insert(found, { model = obj, dist = dist })
                end
            end
        end
    end

    -- Sort by distance
    table.sort(found, function(a, b) return a.dist < b.dist end)

    if #found == 0 then
        scanLog("No models found nearby.", Color3.fromRGB(200, 100, 100))
    else
        for _, entry in ipairs(found) do
            local obj = entry.model
            local dist = entry.dist
            local modelRoot = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)

            -- Check for particles and small parts
            local hasParticle = false
            local smallPartCount = 0
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("ParticleEmitter") then hasParticle = true end
                if child:IsA("BasePart") and child ~= obj.PrimaryPart then
                    local s = child.Size
                    if s.X < 3 and s.Y < 3 and s.Z < 3 then smallPartCount += 1 end
                end
            end

            local tags = ""
            if hasParticle then tags = tags .. " [PARTICLE✨]" end
            if smallPartCount >= 2 then tags = tags .. " [BALLS🔮x" .. smallPartCount .. "]" end

            -- Color: kyeggo models highlighted
            local isKyeggo = obj.Name:lower():find("kyeggo") ~= nil
            local color = isKyeggo and Color3.fromRGB(255, 220, 80) or Color3.fromRGB(160, 160, 180)

            scanLog(string.format(
                "[%.1f st] %s%s",
                dist, obj.Name, tags
            ), color)

            -- Also list direct children names for kyeggo models (helps see ball/orb names)
            if isKyeggo then
                for _, child in ipairs(obj:GetChildren()) do
                    local childInfo = "  └ " .. child.Name .. " (" .. child.ClassName .. ")"
                    if child:IsA("BasePart") then
                        childInfo = childInfo .. string.format(" size=%.1f,%.1f,%.1f", child.Size.X, child.Size.Y, child.Size.Z)
                    end
                    scanLog(childInfo, Color3.fromRGB(120, 200, 255))
                end
            end
        end
    end
    scanLog("=== Done. " .. #found .. " model(s) ===", Color3.fromRGB(180, 100, 255))
end)

scanBtn.MouseButton1Click:Connect(function()
    clearScanLog()
    scanLog("=== BATTLE GUI SCAN ===", Color3.fromRGB(255, 220, 80))
    local guiCount = 0
    for _, gui in ipairs(player.PlayerGui:GetChildren()) do
        if gui.Name == "EggCollectorUI" or not gui:IsA("ScreenGui") or not gui.Enabled then continue end
        guiCount += 1
        scanLog("GUI: " .. gui.Name, Color3.fromRGB(100, 200, 255))
        for _, obj in ipairs(gui:GetDescendants()) do
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                local txt = obj.Text or "(ImageButton)"
                scanLog("  BTN: " .. obj.Name .. ' | Text="' .. txt .. '"', Color3.fromRGB(80, 255, 120))
                scanLog("  Parent=" .. (obj.Parent and obj.Parent.Name or "?"), Color3.fromRGB(60, 200, 100))
            end
        end
    end
    scanLog("=== Done. " .. guiCount .. " GUI(s) ===", Color3.fromRGB(255, 220, 80))
end)

-- ── Ignore List Panel ─────────────────────────────────────────────────────────
local listPanel = Instance.new("Frame")
listPanel.Size = UDim2.new(1, 0, 1, -68)
listPanel.Position = UDim2.new(0, 0, 0, 68)
listPanel.BackgroundTransparency = 1
listPanel.Visible = false
listPanel.Parent = frame

local listTitle = Instance.new("TextLabel")
listTitle.Size = UDim2.new(1, 0, 0, 18)
listTitle.Position = UDim2.new(0, 0, 0, 4)
listTitle.BackgroundTransparency = 1
listTitle.Text = "✔ = Auto-Run (skip)  |  ✖ = Keep (don't run)"
listTitle.TextColor3 = Color3.fromRGB(160, 160, 180)
listTitle.TextSize = 10
listTitle.Font = Enum.Font.Code
listTitle.Parent = listPanel

local listScroll = Instance.new("ScrollingFrame")
listScroll.Size = UDim2.new(1, -8, 1, -26)
listScroll.Position = UDim2.new(0, 4, 0, 24)
listScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
listScroll.BorderSizePixel = 0
listScroll.ScrollBarThickness = 4
listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
listScroll.Parent = listPanel
Instance.new("UICorner", listScroll).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = listScroll

-- Ordered list of all Kyeggo variants
local KYEGGO_VARIANTS = {
    "Kyeggo",
    "Kyeggo-blue",
    "Kyeggo-green",
    "Kyeggo-rred",
    "Kyeggo-rorange",
    "Kyeggo-rviolet",
    "Kyeggo-pattern1",
    "Kyeggo-pattern2",
    "Kyeggo-pattern3",
    "Kyeggo-pattern4",
    "Kyeggo-faberge1",
    "Kyeggo-faberge2",
    "Kyeggo-faberge3",
}

local function makeListRow(variantName)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 26)
    row.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    row.BorderSizePixel = 0
    row.Parent = listScroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -70, 1, 0)
    nameLbl.Position = UDim2.new(0, 8, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = variantName
    nameLbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    nameLbl.TextSize = 11
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.Parent = row

    local togBtn = Instance.new("TextButton")
    togBtn.Size = UDim2.new(0, 60, 0, 20)
    togBtn.Position = UDim2.new(1, -64, 0.5, -10)
    togBtn.BorderSizePixel = 0
    togBtn.TextScaled = true
    togBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    togBtn.Parent = row
    Instance.new("UICorner", togBtn).CornerRadius = UDim.new(0, 5)

    local function refreshToggle()
        local skip = ignoreList[variantName]
        if skip then
            togBtn.Text = "✔ SKIP"
            togBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
            togBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
        else
            togBtn.Text = "✖ KEEP"
            togBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            togBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLbl.TextColor3 = Color3.fromRGB(255, 220, 80)
        end
    end

    refreshToggle()

    togBtn.MouseButton1Click:Connect(function()
        ignoreList[variantName] = not ignoreList[variantName]
        refreshToggle()
    end)
end

for _, v in ipairs(KYEGGO_VARIANTS) do
    makeListRow(v)
end

task.wait(0.1)
listScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 6)

-- ── Tab Switching ─────────────────────────────────────────────────────────────
local function setTab(t)
    mainPanel.Visible = (t == "main")
    espPanel.Visible  = (t == "esp")
    scanPanel.Visible = (t == "scan")
    listPanel.Visible = (t == "list")
    local active   = Color3.fromRGB(60, 100, 180)
    local inactive = Color3.fromRGB(40, 40, 55)
    tabMain.BackgroundColor3 = t=="main" and active or inactive
    tabEsp.BackgroundColor3  = t=="esp"  and active or inactive
    tabScan.BackgroundColor3 = t=="scan" and active or inactive
    tabList.BackgroundColor3 = t=="list" and active or inactive
end
setTab("main")
tabMain.MouseButton1Click:Connect(function() setTab("main") end)
tabEsp.MouseButton1Click:Connect(function()  setTab("esp")  end)
tabScan.MouseButton1Click:Connect(function() setTab("scan") end)
tabList.MouseButton1Click:Connect(function() setTab("list") end)

-- ── Minimize ──────────────────────────────────────────────────────────────────
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        frame.Size = UDim2.new(0, 280, 0, 35)
        minimizeBtn.Text = "□"
        tabFrame.Visible = false
        mainPanel.Visible = false
        espPanel.Visible = false
        scanPanel.Visible = false
        listPanel.Visible = false
    else
        frame.Size = UDim2.new(0, 280, 0, 340)
        minimizeBtn.Text = "–"
        tabFrame.Visible = true
        setTab("main")
    end
end)

-- ── Alpha / Gamma Detection ───────────────────────────────────────────────────
-- Alpha: has ParticleEmitter descendants
-- Gamma: has small orbiting Part(s) that are children of the model but NOT the main body
--        (they tend to be named things like "Ball", "Orb", or are small spherical BaseParts
--         separate from the main mesh, positioned around the model)

local function hasAlphaParticles(model)
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then
            return true
        end
    end
    return false
end

local function hasGammaBalls(model)
    -- Look for small orbiting BaseParts that are direct children of the model
    -- and are NOT the PrimaryPart / HumanoidRootPart
    local primaryPart = model.PrimaryPart
    local partCount = 0
    for _, obj in ipairs(model:GetChildren()) do
        if obj:IsA("BasePart") and obj ~= primaryPart then
            -- Gamma balls are typically small (size < 3 in all axes)
            local s = obj.Size
            if s.X < 3 and s.Y < 3 and s.Z < 3 then
                partCount += 1
                if partCount >= 2 then return true end
            end
        end
    end
    -- Also check one level deeper (nested models)
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("Model") then
            for _, obj in ipairs(child:GetChildren()) do
                if obj:IsA("BasePart") then
                    local s = obj.Size
                    if s.X < 3 and s.Y < 3 and s.Z < 3 then
                        partCount += 1
                        if partCount >= 2 then return true end
                    end
                end
            end
        end
    end
    return false
end

local function getKyeggoVariant(model)
    -- Returns "alpha", "gamma", "rare", or "normal"
    if hasAlphaParticles(model) then return "alpha" end
    if hasGammaBalls(model)     then return "gamma" end
    if not ignoreList[model.Name] then return "rare" end
    return "normal"
end

-- ── ESP System ────────────────────────────────────────────────────────────────
local espLabels = {}

local function makeESPLabel(part, text, color)
    if espLabels[part] then
        -- Update existing label text/color in case variant changed
        local bb = espLabels[part]
        local bg = bb:FindFirstChildWhichIsA("Frame")
        if bg then
            local stripe = bg:FindFirstChildWhichIsA("Frame")
            if stripe then stripe.BackgroundColor3 = color end
            local lbl = bg:FindFirstChildWhichIsA("TextLabel")
            if lbl then lbl.Text = text; lbl.TextColor3 = color end
        end
        return
    end
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
    if bb then bb:Destroy(); espLabels[part] = nil end
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

local function isPlayerCharacter(model)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return true end
    end
    return false
end

local function getModelRoot(model)
    if model.PrimaryPart then return model.PrimaryPart end
    return model:FindFirstChildWhichIsA("BasePart", true)
end

-- Always-on ESP scan loop (like you asked — same as original but now includes Alpha/Gamma)
task.spawn(function()
    while true do
        task.wait(0.5)
        if not espEnabled then continue end
        local seenParts = {}
        local totalCount = 0
        local specialCount = 0

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not obj:IsA("Model") then continue end
            if not obj.Name:lower():find("^kyeggo") then continue end
            if isPlayerCharacter(obj) then continue end

            local root = getModelRoot(obj)
            if not root then continue end

            seenParts[root] = true
            totalCount += 1

            local variant = getKyeggoVariant(obj)
            local label, color

            if variant == "alpha" then
                label = "✨ ALPHA - " .. obj.Name
                color = espAlphaColor
                specialCount += 1
            elseif variant == "gamma" then
                label = "🔮 GAMMA - " .. obj.Name
                color = espGammaColor
                specialCount += 1
            elseif variant == "rare" then
                label = "⭐ " .. obj.Name
                color = espRareColor
            else
                label = "🔵 " .. obj.Name
                color = espNormalColor
            end

            makeESPLabel(root, label, color)
        end

        -- Remove stale labels
        for part in pairs(espLabels) do
            if not seenParts[part] or not part.Parent then
                removeESPLabel(part)
            end
        end

        espCountLabel.Text = string.format(
            "Kyeggos: %d  |  Alpha/Gamma: %d", totalCount, specialCount
        )
    end
end)

-- ── Ground Egg Collection ─────────────────────────────────────────────────────
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

-- ── Run Button Click (uses confirmed circle position) ─────────────────────────
local function clickRunButton()
    local vim = game:GetService("VirtualInputManager")

    -- Use confirmed circle position if set
    if runBtnPos then
        pcall(function()
            vim:SendMouseButtonEvent(runBtnPos.X, runBtnPos.Y, 0, true, game, 0)
            task.wait(0.08)
            vim:SendMouseButtonEvent(runBtnPos.X, runBtnPos.Y, 0, false, game, 0)
        end)
        print("✅ Clicked Run at confirmed position " .. math.floor(runBtnPos.X) .. "," .. math.floor(runBtnPos.Y))
        return true
    end

    -- Fallback: scan for Run text button
    for _, gui in ipairs(player.PlayerGui:GetChildren()) do
        if gui.Name == "EggCollectorUI" or not gui:IsA("ScreenGui") or not gui.Enabled then continue end
        for _, obj in ipairs(gui:GetDescendants()) do
            if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible then
                local text = (obj.Text or ""):lower()
                if text:find("run") then
                    local pos = obj.AbsolutePosition + (obj.AbsoluteSize / 2)
                    pcall(function()
                        vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                        task.wait(0.07)
                        vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                    end)
                    print("✅ Clicked Run button (text scan) at " .. math.floor(pos.X) .. "," .. math.floor(pos.Y))
                    return true
                end
            end
        end
    end

    -- Last fallback: bottom-middle
    local vp = Camera.ViewportSize
    local x = vp.X * 0.5
    local y = vp.Y * 0.89
    pcall(function()
        vim:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.08)
        vim:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end)
    print("⚠️ Used fallback bottom-middle click")
    return false
end

-- ── Encounter / Battle Check ──────────────────────────────────────────────────
-- Checks Workspace for the currently encountered Kyeggo model (the one in battle)
-- by looking for a Kyeggo model that is anchored / near the player
local function getBattleKyeggoModel()
    local char = player.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local playerPos = root.Position
    local closest, closestDist = nil, 60 -- only check within 60 studs

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("^kyeggo") and not isPlayerCharacter(obj) then
            local modelRoot = getModelRoot(obj)
            if modelRoot then
                local dist = (modelRoot.Position - playerPos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = obj
                end
            end
        end
    end
    return closest
end

local function shouldKeepEncounter(kyeggoModel)
    if not kyeggoModel then return false end
    local variant = getKyeggoVariant(kyeggoModel)
    -- Always keep Alpha and Gamma
    if variant == "alpha" or variant == "gamma" then return true end
    -- Keep if NOT in ignore list
    if not ignoreList[kyeggoModel.Name] then return true end
    return false
end

local function isBattleGui(gui)
    if not gui:IsA("ScreenGui") then return false end
    local hasRun, hasFight, hasLoomians = false, false, false
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") then
            local txt = obj.Text or ""
            if txt == "Run" then hasRun = true
            elseif txt == "Fight" then hasFight = true
            elseif txt == "Loomians" then hasLoomians = true end
        end
    end
    return hasRun and hasFight and hasLoomians
end

local function showNotif(text, color)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 260, 0, 44)
    notif.Position = UDim2.new(0.5, -130, 0, 10)
    notif.BackgroundColor3 = color or Color3.fromRGB(30, 30, 45)
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
    task.delay(3.5, function() if notif.Parent then notif:Destroy() end end)
end

local watchedGuis = {}

task.spawn(function()
    while true do
        task.wait(0.3)
        if not autoRunEnabled then continue end
        for _, gui in ipairs(player.PlayerGui:GetChildren()) do
            if gui.Name == "EggCollectorUI" or watchedGuis[gui] or not gui:IsA("ScreenGui") or not gui.Enabled then continue end
            if isBattleGui(gui) then
                watchedGuis[gui] = true

                -- Find the Kyeggo model in the battle
                local kyeggoModel = getBattleKyeggoModel()
                local keep = shouldKeepEncounter(kyeggoModel)
                local modelName = kyeggoModel and kyeggoModel.Name or "Unknown"

                if kyeggoModel then
                    local variant = getKyeggoVariant(kyeggoModel)
                    if variant == "alpha" then
                        showNotif("✨ ALPHA KYEGGO! - " .. modelName, Color3.fromRGB(255, 200, 0))
                        encounterLabel.Text = "Last: ✨ ALPHA - " .. modelName
                        encounterLabel.TextColor3 = espAlphaColor
                    elseif variant == "gamma" then
                        showNotif("🔮 GAMMA KYEGGO! - " .. modelName, Color3.fromRGB(0, 200, 180))
                        encounterLabel.Text = "Last: 🔮 GAMMA - " .. modelName
                        encounterLabel.TextColor3 = espGammaColor
                    elseif keep then
                        showNotif("⭐ KEEPER: " .. modelName:upper(), Color3.fromRGB(255, 180, 0))
                        encounterLabel.Text = "Last: KEEPER (" .. modelName .. ")"
                        encounterLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
                    else
                        showNotif("🏃 Auto-running in 3s... (" .. modelName .. ")", Color3.fromRGB(80, 80, 120))
                        encounterLabel.Text = "Last: Skipped (" .. modelName .. ")"
                        encounterLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
                        task.wait(3)
                        -- Re-check after wait in case something changed
                        if not shouldKeepEncounter(getBattleKyeggoModel()) then
                            clickRunButton()
                            encounterLabel.Text = "Last: Skipped ✓ (" .. modelName .. ")"
                            encounterLabel.TextColor3 = Color3.fromRGB(120, 200, 120)
                        end
                    end
                else
                    -- Can't identify model, skip for safety
                    showNotif("❓ Unknown encounter — keeping", Color3.fromRGB(100, 100, 140))
                    encounterLabel.Text = "Last: Unknown (kept)"
                    encounterLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
                end

                task.delay(10, function() watchedGuis[gui] = nil end)
            end
        end
    end
end)

print("✅ Kyeggo Egg Collector LOADED - Alpha/Gamma ESP + Adjustable Run Button")
