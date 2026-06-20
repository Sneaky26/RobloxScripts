
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

-- ── Button Cache ──────────────────────────────────────────────────────────────
-- Instead of scanning every battle, we find the button once and save it.
-- cachedRunButton = the actual button object, found on first encounter
-- cachedRunGui    = which ScreenGui it belongs to (so we can revalidate)
local cachedRunButton = nil
local cachedRunGui    = nil

local function isCacheValid()
    -- Check the saved button still exists in the game tree
    return cachedRunButton ~= nil
        and cachedRunButton.Parent ~= nil
        and cachedRunGui ~= nil
        and cachedRunGui.Parent ~= nil
end

local function invalidateCache()
    cachedRunButton = nil
    cachedRunGui    = nil
    print("🗑️ Run button cache cleared")
end

-- Clear cache on respawn (the battle GUI gets rebuilt after death)
player.CharacterAdded:Connect(invalidateCache)

-- ── UI Setup ──────────────────────────────────────────────────────────────────
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

local tabMain   = makeTab("Main",   0)
local tabEsp    = makeTab("ESP",    0.25)
local tabScan   = makeTab("Scan",   0.50)
local tabCoords = makeTab("Coords", 0.75)

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

-- Cache status label (new!) — shows user whether button is cached or not
local cacheLabel = Instance.new("TextLabel")
cacheLabel.Size = UDim2.new(1, 0, 0, 18)
cacheLabel.Position = UDim2.new(0, 0, 0, 140)
cacheLabel.BackgroundTransparency = 1
cacheLabel.Text = "Run Btn: Not cached yet"
cacheLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
cacheLabel.TextScaled = true
cacheLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
cacheLabel.Parent = mainPanel

-- Manual cache clear button (useful if game updates its UI)
local clearCacheBtn = Instance.new("TextButton")
clearCacheBtn.Size = UDim2.new(0.8, 0, 0, 24)
clearCacheBtn.Position = UDim2.new(0.1, 0, 0, 162)
clearCacheBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 100)
clearCacheBtn.Text = "Clear Cache"
clearCacheBtn.TextColor3 = Color3.fromRGB(200, 180, 255)
clearCacheBtn.TextScaled = true
clearCacheBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
clearCacheBtn.Parent = mainPanel
Instance.new("UICorner", clearCacheBtn).CornerRadius = UDim.new(0, 6)

clearCacheBtn.MouseButton1Click:Connect(function()
    invalidateCache()
    cacheLabel.Text = "Run Btn: Cache cleared"
    cacheLabel.TextColor3 = Color3.fromRGB(255, 160, 80)
end)

local encounterLabel = Instance.new("TextLabel")
encounterLabel.Size = UDim2.new(1, 0, 0, 18)
encounterLabel.Position = UDim2.new(0, 0, 0, 192)
encounterLabel.BackgroundTransparency = 1
encounterLabel.Text = "Last Encounter: —"
encounterLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
encounterLabel.TextScaled = true
encounterLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
encounterLabel.Parent = mainPanel

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

local espNormalPokemon = Color3.fromRGB(255, 120, 50)
local espRarePokemon   = Color3.fromRGB(255, 80, 255)

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

makeLegend("Normal Pokemon", espNormalPokemon, 72)
makeLegend("Rare (Rainbow/Gradient/Alpha/etc.)", espRarePokemon, 94)

local espCountLabel = Instance.new("TextLabel")
espCountLabel.Size = UDim2.new(1, 0, 0, 18)
espCountLabel.Position = UDim2.new(0, 0, 0, 120)
espCountLabel.BackgroundTransparency = 1
espCountLabel.Text = "Pokemon visible: 0"
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

-- Button 1: Battle GUI scan (existing)
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(1, -10, 0, 26)
scanBtn.Position = UDim2.new(0, 5, 0, 2)
scanBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
scanBtn.Text = "Scan Battle GUIs"
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.TextScaled = true
scanBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
scanBtn.Parent = scanPanel
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0, 6)

-- Button 2: Top bar / hourly menu scan (new)
-- Scans ALL GUIs and shows each button's screen position
-- so you can identify the hourly menu button at the top
local topBarScanBtn = Instance.new("TextButton")
topBarScanBtn.Size = UDim2.new(1, -10, 0, 26)
topBarScanBtn.Position = UDim2.new(0, 5, 0, 31)
topBarScanBtn.BackgroundColor3 = Color3.fromRGB(160, 80, 200)
topBarScanBtn.Text = "Scan Top Bar / Menu"
topBarScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
topBarScanBtn.TextScaled = true
topBarScanBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
topBarScanBtn.Parent = scanPanel
Instance.new("UICorner", topBarScanBtn).CornerRadius = UDim.new(0, 6)

local scanScroll = Instance.new("ScrollingFrame")
scanScroll.Size = UDim2.new(1, -8, 1, -64)
scanScroll.Position = UDim2.new(0, 4, 0, 62)
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

-- ── SCAN: now also caches the Run button when found ───────────────────────────
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

                -- Auto-cache if this looks like the Run button
                if not isCacheValid() and (txt:lower():find("run") or obj.Name:lower():find("run")) then
                    cachedRunButton = obj
                    cachedRunGui    = gui
                    scanLog("  ✅ CACHED as Run button!", Color3.fromRGB(255, 220, 0))
                    cacheLabel.Text = "Run Btn: ✅ Cached (" .. obj.Name .. ")"
                    cacheLabel.TextColor3 = Color3.fromRGB(80, 255, 150)
                end
            end
        end
    end
    scanLog("=== Done. " .. guiCount .. " GUI(s) ===", Color3.fromRGB(255, 220, 80))
end)

-- ── TOP BAR SCANNER ───────────────────────────────────────────────────────────
-- Scans every GUI and logs ALL buttons with their screen Y position.
-- Buttons near the top of screen (small Y value) = likely the hourly menu.
-- Run this WHILE the top bar menu is visible so we catch it.
topBarScanBtn.MouseButton1Click:Connect(function()
    clearScanLog()
    local vp = Camera.ViewportSize
    scanLog("=== TOP BAR SCAN (screen: "..math.floor(vp.X).."x"..math.floor(vp.Y)..") ===", Color3.fromRGB(220, 160, 255))
    scanLog("Buttons near top = small Y pos. Look for the menu!", Color3.fromRGB(160, 130, 200))

    -- Collect all buttons across all GUIs, sort by Y position
    local found = {}
    for _, gui in ipairs(player.PlayerGui:GetChildren()) do
        if gui.Name == "EggCollectorUI" or not gui:IsA("ScreenGui") or not gui.Enabled then continue end
        for _, obj in ipairs(gui:GetDescendants()) do
            if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible then
                local absY = obj.AbsolutePosition.Y
                local absX = obj.AbsolutePosition.X
                table.insert(found, {
                    obj    = obj,
                    gui    = gui.Name,
                    y      = absY,
                    x      = absX,
                    name   = obj.Name,
                    text   = obj.Text or "(ImageButton)",
                    parent = obj.Parent and obj.Parent.Name or "?",
                    class  = obj.ClassName,
                })
            end
        end
    end

    -- Sort by Y so top-of-screen buttons appear first in the log
    table.sort(found, function(a, b) return a.y < b.y end)

    if #found == 0 then
        scanLog("No buttons found! Make sure the menu is open.", Color3.fromRGB(255, 100, 100))
    end

    local topThreshold = vp.Y * 0.15  -- top 15% of screen = "top bar area"
    for _, b in ipairs(found) do
        local isTop = b.y <= topThreshold
        local color = isTop
            and Color3.fromRGB(255, 220, 80)   -- yellow = top bar area (what we want)
            or  Color3.fromRGB(140, 160, 140)  -- grey = rest of screen

        local posStr = "Y="..math.floor(b.y).." X="..math.floor(b.x)
        local marker = isTop and "⭐TOP " or "    "
        scanLog(marker .. b.gui .. " > " .. b.parent .. " > " .. b.name, color)
        scanLog('     Class=' .. b.class .. ' Text="' .. b.text .. '" ' .. posStr, color)
    end

    scanLog("=== Done. " .. #found .. " button(s) total ===", Color3.fromRGB(220, 160, 255))
    scanLog("⭐ = top 15% of screen. Tell me the GUI/Name of the menu button!", Color3.fromRGB(200, 180, 255))
end)

-- ── Coords Panel ─────────────────────────────────────────────────────────────
local coordsPanel = Instance.new("Frame")
coordsPanel.Size = UDim2.new(1, 0, 1, -68)
coordsPanel.Position = UDim2.new(0, 0, 0, 68)
coordsPanel.BackgroundTransparency = 1
coordsPanel.Visible = false
coordsPanel.Parent = frame

-- Live position display
local livePosLabel = Instance.new("TextLabel")
livePosLabel.Size = UDim2.new(1, -8, 0, 18)
livePosLabel.Position = UDim2.new(0, 4, 0, 4)
livePosLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
livePosLabel.BackgroundTransparency = 0
livePosLabel.Text = "Pos: —"
livePosLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
livePosLabel.TextScaled = true
livePosLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
livePosLabel.Parent = coordsPanel
Instance.new("UICorner", livePosLabel).CornerRadius = UDim.new(0, 5)

-- Copy current coords button
local copyPosBtn = Instance.new("TextButton")
copyPosBtn.Size = UDim2.new(1, -8, 0, 22)
copyPosBtn.Position = UDim2.new(0, 4, 0, 26)
copyPosBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 60)
copyPosBtn.Text = "📋 Copy My Coords"
copyPosBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
copyPosBtn.TextScaled = true
copyPosBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
copyPosBtn.Parent = coordsPanel
Instance.new("UICorner", copyPosBtn).CornerRadius = UDim.new(0, 5)

copyPosBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local p = root.Position
        local str = "X:"..math.floor(p.X).." Y:"..math.floor(p.Y).." Z:"..math.floor(p.Z)
        setclipboard(str)
        copyPosBtn.Text = "✅ Copied!"
        task.delay(1.5, function() copyPosBtn.Text = "📋 Copy My Coords" end)
    end
end)

-- Divider label
local locTitle = Instance.new("TextLabel")
locTitle.Size = UDim2.new(1, -8, 0, 14)
locTitle.Position = UDim2.new(0, 4, 0, 52)
locTitle.BackgroundTransparency = 1
locTitle.Text = "── Known Locations ──"
locTitle.TextColor3 = Color3.fromRGB(120, 120, 160)
locTitle.TextScaled = true
locTitle.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
locTitle.Parent = coordsPanel

-- Scrollable location list
local locScroll = Instance.new("ScrollingFrame")
locScroll.Size = UDim2.new(1, -8, 1, -72)
locScroll.Position = UDim2.new(0, 4, 0, 70)
locScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
locScroll.BorderSizePixel = 0
locScroll.ScrollBarThickness = 4
locScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
locScroll.Parent = coordsPanel
Instance.new("UICorner", locScroll).CornerRadius = UDim.new(0, 6)

local locLayout = Instance.new("UIListLayout")
locLayout.SortOrder = Enum.SortOrder.LayoutOrder
locLayout.Padding = UDim.new(0, 2)
locLayout.Parent = locScroll

-- Known locations table — add missing ones here later
-- Format: { name, x, y, z }  (nil = not yet known)
local LOCATIONS = {
    { "Cheshma Town",   -220,  83,  -564 },
    { "Route 3",       -1598, 103,  -398 },
    { "Silvent City",  -1586, 160, -1110 },
    { "Kanoko Village",-1027,  74, -1418 },
    { "Rally Ranch",     524,  56,  -168 },
    { "Route 8",         211, 333,  3448 },
    { "Living District",-3027, 493, -704 },
    -- missing — fill in after coord scan:
    { "Heiwa Village",  nil,  nil,   nil },
    { "Route 1",        nil,  nil,   nil },
    { "Route 4",        nil,  nil,   nil },
    { "Route 6",        nil,  nil,   nil },
    { "Atlanthian City",nil,  nil,   nil },
    { "Gale Forest",    nil,  nil,   nil },
}

for _, loc in ipairs(LOCATIONS) do
    local name, x, y, z = loc[1], loc[2], loc[3], loc[4]
    local known = x ~= nil

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 36)
    row.BackgroundColor3 = known
        and Color3.fromRGB(20, 30, 45)
        or  Color3.fromRGB(35, 20, 20)
    row.BorderSizePixel = 0
    row.Parent = locScroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -8, 0, 16)
    nameLbl.Position = UDim2.new(0, 6, 0, 2)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextColor3 = known
        and Color3.fromRGB(200, 220, 255)
        or  Color3.fromRGB(160, 100, 100)
    nameLbl.TextScaled = true
    nameLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = row

    local coordLbl = Instance.new("TextLabel")
    coordLbl.Size = UDim2.new(0.7, 0, 0, 14)
    coordLbl.Position = UDim2.new(0, 6, 0, 19)
    coordLbl.BackgroundTransparency = 1
    coordLbl.Text = known
        and ("X:"..x.." Y:"..y.." Z:"..z)
        or  "coords unknown"
    coordLbl.TextColor3 = known
        and Color3.fromRGB(100, 200, 150)
        or  Color3.fromRGB(120, 80, 80)
    coordLbl.TextScaled = true
    coordLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
    coordLbl.TextXAlignment = Enum.TextXAlignment.Left
    coordLbl.Parent = row

    -- Teleport button (only if coords known)
    if known then
        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0, 50, 0, 26)
        tpBtn.Position = UDim2.new(1, -56, 0.5, -13)
        tpBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 180)
        tpBtn.Text = "TP"
        tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tpBtn.TextScaled = true
        tpBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
        tpBtn.Parent = row
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 5)

        tpBtn.MouseButton1Click:Connect(function()
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(Vector3.new(x, y + 3, z))
                tpBtn.Text = "✅"
                task.delay(1.5, function() tpBtn.Text = "TP" end)
            end
        end)
    end
end

-- Auto-update canvas height
locLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    locScroll.CanvasSize = UDim2.new(0, 0, 0, locLayout.AbsoluteContentSize.Y + 6)
end)

-- Live position updater
task.spawn(function()
    while true do
        task.wait(0.3)
        if not coordsPanel.Visible then continue end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local p = root.Position
            livePosLabel.Text = "X:"..math.floor(p.X).." Y:"..math.floor(p.Y).." Z:"..math.floor(p.Z)
        end
    end
end)

-- ── Tab Switching ─────────────────────────────────────────────────────────────
local function setTab(t)
    mainPanel.Visible   = (t == "main")
    espPanel.Visible    = (t == "esp")
    scanPanel.Visible   = (t == "scan")
    coordsPanel.Visible = (t == "coords")
    local active   = Color3.fromRGB(60, 100, 180)
    local inactive = Color3.fromRGB(40, 40, 55)
    tabMain.BackgroundColor3   = t == "main"   and active or inactive
    tabEsp.BackgroundColor3    = t == "esp"    and active or inactive
    tabScan.BackgroundColor3   = t == "scan"   and active or inactive
    tabCoords.BackgroundColor3 = t == "coords" and active or inactive
end
setTab("main")
tabMain.MouseButton1Click:Connect(function()   setTab("main")   end)
tabEsp.MouseButton1Click:Connect(function()    setTab("esp")    end)
tabScan.MouseButton1Click:Connect(function()   setTab("scan")   end)
tabCoords.MouseButton1Click:Connect(function() setTab("coords") end)

-- ── Minimize ──────────────────────────────────────────────────────────────────
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        frame.Size = UDim2.new(0, 280, 0, 35)
        minimizeBtn.Text = "□"
        tabFrame.Visible    = false
        mainPanel.Visible   = false
        espPanel.Visible    = false
        scanPanel.Visible   = false
        coordsPanel.Visible = false
    else
        frame.Size = UDim2.new(0, 280, 0, 310)
        minimizeBtn.Text = "–"
        tabFrame.Visible    = true
        mainPanel.Visible   = true
        espPanel.Visible    = false
        scanPanel.Visible   = false
        coordsPanel.Visible = false
    end
end)

-- ── ESP System ────────────────────────────────────────────────────────────────
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
    ["Kyeggo-rviolet"] = true, ["Kyeggo-rorange"] = true, ["Kyeggo-rred"] = true,
    ["Kyeggo-blue"] = true,    ["Kyeggo-green"] = true,
    ["Kyeggo-pattern4"] = true, ["Kyeggo-pattern3"] = true,
    ["Kyeggo-pattern2"] = true, ["Kyeggo-pattern1"] = true,
    ["Kyeggo-faberge1"] = true, ["Kyeggo-faberge2"] = true, ["Kyeggo-faberge3"] = true,
    ["Kyeggo"] = true,
}

local function isRareKyeggo(name)
    return not COMMON_KYEGGOS[name]
end

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

task.spawn(function()
    while true do
        task.wait(0.5)
        if not espEnabled then continue end
        local seenParts = {}
        local npcCount  = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not obj:IsA("Model") or not obj.Name:lower():find("^kyeggo") or isPlayerCharacter(obj) then continue end
            local root = getModelRoot(obj)
            if not root then continue end
            seenParts[root] = true
            npcCount += 1
            if not espLabels[root] then
                local rare   = isRareKyeggo(obj.Name)
                local prefix = rare and "⭐ " or "🔵 "
                local color  = rare and espRarePokemon or espNormalPokemon
                makeESPLabel(root, prefix .. obj.Name, color)
            end
        end
        for part in pairs(espLabels) do
            if not seenParts[part] or not part.Parent then removeESPLabel(part) end
        end
        espCountLabel.Text = "Pokemon visible: " .. npcCount
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

-- ── Click Run Button (cache-first, fallback second) ───────────────────────────
local function clickRunButton(battleGui)
    -- ① Try cached button first (fastest path, no scanning)
    if isCacheValid() then
        local btn = cachedRunButton
        local pos = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
        pcall(function()
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true,  game, 0)
            task.wait(0.07)
            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
        end)
        print("✅ Clicked cached Run button")
        return true
    end

    -- ② Cache miss: scan the battle GUI now and cache what we find
    print("🔍 Cache miss — scanning for Run button...")
    if battleGui then
        for _, obj in ipairs(battleGui:GetDescendants()) do
            if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible then
                local text = (obj.Text or ""):lower()
                if text:find("run") or obj.Name:lower():find("run") then
                    -- Save for next time
                    cachedRunButton = obj
                    cachedRunGui    = battleGui
                    cacheLabel.Text = "Run Btn: ✅ Cached (" .. obj.Name .. ")"
                    cacheLabel.TextColor3 = Color3.fromRGB(80, 255, 150)
                    print("✅ Found & cached Run button: " .. obj.Name)

                    local pos = obj.AbsolutePosition + (obj.AbsoluteSize / 2)
                    pcall(function()
                        local vim = game:GetService("VirtualInputManager")
                        vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true,  game, 0)
                        task.wait(0.07)
                        vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                    end)
                    return true
                end
            end
        end
    end

    -- ③ Full fallback: coordinate guess (last resort)
    print("⚠️ Run button not found — using fallback coordinate click")
    local vp = Camera.ViewportSize
    local x  = vp.X * 0.5
    local y  = vp.Y * 0.89
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(x, y, 0, true,  game, 0)
        task.wait(0.08)
        vim:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end)
    return false
end

-- ── Auto-Run System ───────────────────────────────────────────────────────────
local function isKeeper(text)
    for name in pairs(COMMON_KYEGGOS) do
        if text:find(name, 1, true) then return false, name end
    end
    if text:lower():find("kyeggo") then
        return true, text:match("Kyeggo%S*") or "Variant"
    end
    return false, nil
end

local function getAllText(gui)
    local texts = {}
    for _, obj in ipairs(gui:GetDescendants()) do
        if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox"))
            and obj.Text and obj.Text ~= "" then
            table.insert(texts, obj.Text)
        end
    end
    return table.concat(texts, " ")
end

local function isBattleGui(gui)
    if not gui:IsA("ScreenGui") then return false end
    local hasRun, hasFight, hasLoomians = false, false, false
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") then
            local txt = obj.Text or ""
            if txt == "Run"      then hasRun      = true
            elseif txt == "Fight"    then hasFight    = true
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
            if gui.Name == "EggCollectorUI" or watchedGuis[gui]
                or not gui:IsA("ScreenGui") or not gui.Enabled then continue end
            if isBattleGui(gui) then
                watchedGuis[gui] = true
                local fullText = getAllText(gui)
                local keep, reason = isKeeper(fullText)
                if keep then
                    showNotif("⭐ KEEPER: " .. reason:upper() .. "!", Color3.fromRGB(255, 180, 0))
                    encounterLabel.Text = "Last: KEEPER (" .. reason .. ")"
                    encounterLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
                else
                    showNotif("🏃 Auto-running in 3s...", Color3.fromRGB(80, 80, 120))
                    encounterLabel.Text = "Last: Skipped (running...)"
                    encounterLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
                    task.wait(3)
                    if not isKeeper(getAllText(gui)) then
                        -- Pass the battle GUI so cache-miss scan targets the right place
                        clickRunButton(gui)
                        encounterLabel.Text = "Last: Skipped ✓"
                        encounterLabel.TextColor3 = Color3.fromRGB(120, 200, 120)
                    end
                end
                task.delay(10, function() watchedGuis[gui] = nil end)
            end
        end
    end
end)

print("✅ Kyeggo Egg Collector LOADED — Cache system active")
