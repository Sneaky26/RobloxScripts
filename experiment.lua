local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

local collected = 0
local isRunning = false
local isMinimized = false
local espEnabled = false
local fpsBoostEnabled = false

local COLLECT_INTERVAL = 0.4
local MAX_PER_SWEEP = 8

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

-- ── Main Frame (compact) ─────────────────────────────────────────────────────
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 270)
frame.Position = UDim2.new(0.5, -120, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Subtle border
local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(60, 60, 90)
border.Thickness = 1
border.Parent = frame

-- ── Title Bar ────────────────────────────────────────────────────────────────
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🥚 Kyeggo Collector"
title.TextColor3 = Color3.fromRGB(255, 220, 80)
title.TextScaled = true
title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
title.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
minimizeBtn.Position = UDim2.new(1, -56, 0, 4)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 130, 220)
minimizeBtn.Text = "–"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextScaled = true
minimizeBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
minimizeBtn.Parent = titleBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- ── Tabs ─────────────────────────────────────────────────────────────────────
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -12, 0, 26)
tabFrame.Position = UDim2.new(0, 6, 0, 35)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = frame

local function makeTab(text, xFrac)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.333, -3, 1, 0)
    btn.Position = UDim2.new(xFrac, 2, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(170, 170, 170)
    btn.TextScaled = true
    btn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    btn.Parent = tabFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local tabMain = makeTab("Collect", 0)
local tabEsp  = makeTab("ESP", 0.333)
local tabFps  = makeTab("FPS", 0.666)

-- ── MAIN PANEL ───────────────────────────────────────────────────────────────
local mainPanel = Instance.new("Frame")
mainPanel.Size = UDim2.new(1, -12, 1, -68)
mainPanel.Position = UDim2.new(0, 6, 0, 65)
mainPanel.BackgroundTransparency = 1
mainPanel.Parent = frame

-- Stats row
local statsRow = Instance.new("Frame")
statsRow.Size = UDim2.new(1, 0, 0, 38)
statsRow.Position = UDim2.new(0, 0, 0, 0)
statsRow.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
statsRow.BorderSizePixel = 0
statsRow.Parent = mainPanel
Instance.new("UICorner", statsRow).CornerRadius = UDim.new(0, 8)

local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(0.5, 0, 1, 0)
counterLabel.BackgroundTransparency = 1
counterLabel.Text = "🥚 0"
counterLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
counterLabel.TextScaled = true
counterLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
counterLabel.Parent = statsRow

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.5, 0, 1, 0)
statusLabel.Position = UDim2.new(0.5, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "OFF"
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextScaled = true
statusLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
statusLabel.Parent = statsRow

-- BIG START BUTTON
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, 0, 0, 110)
toggleBtn.Position = UDim2.new(0, 0, 0, 44)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
toggleBtn.Text = "▶  START"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextScaled = true
toggleBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
toggleBtn.Parent = mainPanel
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 12)

-- Subtle inner shadow effect via UIStroke
local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(255, 255, 255)
btnStroke.Transparency = 0.85
btnStroke.Thickness = 1.5
btnStroke.Parent = toggleBtn

toggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        toggleBtn.Text = "⏹  STOP"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(210, 55, 55)
        statusLabel.Text = "ON"
        statusLabel.TextColor3 = Color3.fromRGB(80, 255, 100)
    else
        toggleBtn.Text = "▶  START"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
        statusLabel.Text = "OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

local encounterLabel = Instance.new("TextLabel")
encounterLabel.Size = UDim2.new(1, 0, 0, 16)
encounterLabel.Position = UDim2.new(0, 0, 0, 160)
encounterLabel.BackgroundTransparency = 1
encounterLabel.Text = "Last: —"
encounterLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
encounterLabel.TextScaled = true
encounterLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
encounterLabel.Parent = mainPanel

-- ── ESP PANEL ────────────────────────────────────────────────────────────────
local espPanel = Instance.new("Frame")
espPanel.Size = UDim2.new(1, -12, 1, -68)
espPanel.Position = UDim2.new(0, 6, 0, 65)
espPanel.BackgroundTransparency = 1
espPanel.Visible = false
espPanel.Parent = frame

local espToggleBtn = Instance.new("TextButton")
espToggleBtn.Size = UDim2.new(1, 0, 0, 46)
espToggleBtn.Position = UDim2.new(0, 0, 0, 0)
espToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
espToggleBtn.Text = "ESP: OFF"
espToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggleBtn.TextScaled = true
espToggleBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
espToggleBtn.Parent = espPanel
Instance.new("UICorner", espToggleBtn).CornerRadius = UDim.new(0, 10)

local espNormalColor = Color3.fromRGB(255, 120, 50)
local espRareColor   = Color3.fromRGB(255, 80, 255)

local function makeLegendEntry(labelText, color, yPos)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, 4, 0, yPos + 4)
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    dot.Parent = espPanel
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -22, 0, 18)
    lbl.Position = UDim2.new(0, 20, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = espPanel
end

makeLegendEntry("Normal Kyeggo", espNormalColor, 54)
makeLegendEntry("Rare / Rainbow / Alpha", espRareColor, 76)

local espCountLabel = Instance.new("TextLabel")
espCountLabel.Size = UDim2.new(1, 0, 0, 20)
espCountLabel.Position = UDim2.new(0, 0, 0, 106)
espCountLabel.BackgroundTransparency = 1
espCountLabel.Text = "Visible: 0"
espCountLabel.TextColor3 = Color3.fromRGB(0, 220, 160)
espCountLabel.TextScaled = true
espCountLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
espCountLabel.Parent = espPanel

-- ── FPS PANEL ────────────────────────────────────────────────────────────────
local fpsPanel = Instance.new("Frame")
fpsPanel.Size = UDim2.new(1, -12, 1, -68)
fpsPanel.Position = UDim2.new(0, 6, 0, 65)
fpsPanel.BackgroundTransparency = 1
fpsPanel.Visible = false
fpsPanel.Parent = frame

local fpsInfo = Instance.new("TextLabel")
fpsInfo.Size = UDim2.new(1, 0, 0, 44)
fpsInfo.Position = UDim2.new(0, 0, 0, 0)
fpsInfo.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
fpsInfo.BorderSizePixel = 0
fpsInfo.Text = "Hides buildings & props.\nKeeps ground & eggs visible."
fpsInfo.TextColor3 = Color3.fromRGB(160, 160, 180)
fpsInfo.TextScaled = true
fpsInfo.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
fpsInfo.TextWrapped = true
fpsInfo.Parent = fpsPanel
Instance.new("UICorner", fpsInfo).CornerRadius = UDim.new(0, 8)

local fpsToggleBtn = Instance.new("TextButton")
fpsToggleBtn.Size = UDim2.new(1, 0, 0, 56)
fpsToggleBtn.Position = UDim2.new(0, 0, 0, 52)
fpsToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 30)
fpsToggleBtn.Text = "FPS Boost: OFF"
fpsToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsToggleBtn.TextScaled = true
fpsToggleBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
fpsToggleBtn.Parent = fpsPanel
Instance.new("UICorner", fpsToggleBtn).CornerRadius = UDim.new(0, 10)

local fpsStatusLabel = Instance.new("TextLabel")
fpsStatusLabel.Size = UDim2.new(1, 0, 0, 16)
fpsStatusLabel.Position = UDim2.new(0, 0, 0, 116)
fpsStatusLabel.BackgroundTransparency = 1
fpsStatusLabel.Text = "Objects hidden: 0"
fpsStatusLabel.TextColor3 = Color3.fromRGB(140, 200, 140)
fpsStatusLabel.TextScaled = true
fpsStatusLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
fpsStatusLabel.Parent = fpsPanel

-- ── Tab Switching ─────────────────────────────────────────────────────────────
local function setTab(t)
    mainPanel.Visible = (t == "main")
    espPanel.Visible  = (t == "esp")
    fpsPanel.Visible  = (t == "fps")
    local active   = Color3.fromRGB(55, 90, 170)
    local inactive = Color3.fromRGB(35, 35, 50)
    tabMain.BackgroundColor3 = t == "main" and active or inactive
    tabEsp.BackgroundColor3  = t == "esp"  and active or inactive
    tabFps.BackgroundColor3  = t == "fps"  and active or inactive
end
setTab("main")
tabMain.MouseButton1Click:Connect(function() setTab("main") end)
tabEsp.MouseButton1Click:Connect(function()  setTab("esp")  end)
tabFps.MouseButton1Click:Connect(function()  setTab("fps")  end)

-- ── Minimize ──────────────────────────────────────────────────────────────────
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        frame.Size = UDim2.new(0, 240, 0, 32)
        minimizeBtn.Text = "□"
        tabFrame.Visible = false
        mainPanel.Visible = false
        espPanel.Visible = false
        fpsPanel.Visible = false
    else
        frame.Size = UDim2.new(0, 240, 0, 270)
        minimizeBtn.Text = "–"
        tabFrame.Visible = true
        setTab("main")
    end
end)

-- ── ESP System ────────────────────────────────────────────────────────────────
local espLabels = {}

local COMMON_KYEGGOS = {
    ["Kyeggo-rviolet"] = true, ["Kyeggo-rorange"] = true, ["Kyeggo-rred"] = true,
    ["Kyeggo-blue"] = true, ["Kyeggo-green"] = true,
    ["Kyeggo-pattern4"] = true, ["Kyeggo-pattern3"] = true,
    ["Kyeggo-pattern2"] = true, ["Kyeggo-pattern1"] = true,
    ["Kyeggo-faberge1"] = true, ["Kyeggo-faberge2"] = true, ["Kyeggo-faberge3"] = true,
    ["Kyeggo"] = true,
}

local function isRareKyeggo(name) return not COMMON_KYEGGOS[name] end

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

local function makeESPLabel(part, text, color)
    if espLabels[part] then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "KyeggoESP"
    bb.Size = UDim2.new(0, 180, 0, 26)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 300
    bb.Adornee = part
    bb.Parent = part
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    bg.BackgroundTransparency = 0.3
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
    lbl.TextSize = 10
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
        espToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
    else
        espToggleBtn.Text = "ESP: OFF"
        espToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        clearAllESP()
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if not espEnabled then continue end
        local seenParts = {}
        local npcCount = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not obj:IsA("Model") or not obj.Name:lower():find("^kyeggo") or isPlayerCharacter(obj) then continue end
            local root = getModelRoot(obj)
            if not root then continue end
            seenParts[root] = true
            npcCount += 1
            if not espLabels[root] then
                local rare = isRareKyeggo(obj.Name)
                local prefix = rare and "⭐ " or "🔵 "
                local color  = rare and espRareColor or espNormalColor
                makeESPLabel(root, prefix .. obj.Name, color)
            end
        end
        for part in pairs(espLabels) do
            if not seenParts[part] or not part.Parent then removeESPLabel(part) end
        end
        espCountLabel.Text = "Visible: " .. npcCount
    end
end)

-- ── FPS Boost System ─────────────────────────────────────────────────────────
-- key = object, value = original Transparency before we hid it
local hiddenObjects = {}

-- Returns true if this part should be KEPT visible no matter what
local function shouldKeep(obj)
    local nameLower = obj.Name:lower()

    -- Always keep eggs
    if nameLower:find("egg") then return true end

    -- Always keep Kyeggo NPCs
    if nameLower:find("kyeggo") then return true end

    -- Keep ground / floor / baseplate type names
    if nameLower:find("ground") or nameLower:find("baseplate") or nameLower:find("base")
    or nameLower:find("floor") or nameLower:find("grass") or nameLower:find("dirt")
    or nameLower:find("terrain") or nameLower:find("road") or nameLower:find("path")
    or nameLower:find("sand") or nameLower:find("water") then
        return true
    end

    -- Keep player characters (self + others)
    for _, p in ipairs(Players:GetPlayers()) do
        local char = p.Character
        if char and obj:IsDescendantOf(char) then return true end
    end

    -- Keep anything parented under Kyeggo models (their body parts)
    local ancestor = obj.Parent
    while ancestor and ancestor ~= Workspace do
        if ancestor.Name:lower():find("kyeggo") then return true end
        ancestor = ancestor.Parent
    end

    return false
end

local function applyFpsBoost()
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        -- Target all visible geometry parts
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("SpecialMesh")
        or obj:IsA("UnionOperation") or obj:IsA("PartOperation") then
            if not hiddenObjects[obj] and not shouldKeep(obj) then
                local ok, original = pcall(function() return obj.Transparency end)
                if ok and original < 1 then
                    hiddenObjects[obj] = original
                    pcall(function() obj.Transparency = 1 end)
                    count += 1
                end
            end
        end
        -- Hide Decals, Textures, and SurfaceAppearances (extra visual noise)
        if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceAppearance") then
            if not hiddenObjects[obj] then
                local ok, original = pcall(function() return obj.Transparency end)
                if ok then
                    hiddenObjects[obj] = original
                    pcall(function() obj.Transparency = 1 end)
                    count += 1
                end
            end
        end
    end

    -- Disable terrain decoration
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then pcall(function() terrain.Decoration = false end) end

    fpsStatusLabel.Text = "Hidden: " .. count .. " objects ✓"
end

local function removeFpsBoost()
    for obj, original in pairs(hiddenObjects) do
        pcall(function()
            if obj and obj.Parent then
                obj.Transparency = original
            end
        end)
    end
    hiddenObjects = {}

    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then pcall(function() terrain.Decoration = true end) end

    fpsStatusLabel.Text = "Objects hidden: 0"
end

fpsToggleBtn.MouseButton1Click:Connect(function()
    fpsBoostEnabled = not fpsBoostEnabled
    if fpsBoostEnabled then
        fpsToggleBtn.Text = "FPS Boost: ON"
        fpsToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
        applyFpsBoost()
    else
        fpsToggleBtn.Text = "FPS Boost: OFF"
        fpsToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 30)
        removeFpsBoost()
    end
end)

-- ── Ground Egg Collection ─────────────────────────────────────────────────────
local function isGroundEgg(obj)
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
        local ok, targetPos = isGroundEgg(obj)
        if ok then
            eggsFound += 1
            root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
            task.wait(0.12)
            root.CFrame = originalCFrame
            task.wait(0.08)
            collected += 1
            counterLabel.Text = "🥚 " .. collected
        end
    end
end

task.spawn(function()
    while true do
        pcall(collectEggs)
        task.wait(COLLECT_INTERVAL)
    end
end)

print("✅ Kyeggo Collector loaded — compact UI + FPS Boost ready")
