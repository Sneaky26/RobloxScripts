local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local collected = 0
local isRunning = false
local isMinimized = false

-- ── Settings ─────────────────────────────────────────────────────────────────
local SCAN_RADIUS      = 120   -- studs (debug scan only, NOT used for collection)
local COLLECT_INTERVAL = 0.4   -- seconds between sweeps
local MAX_PER_SWEEP    = 8     -- max eggs per sweep
-- ─────────────────────────────────────────────────────────────────────────────

-- Remove old UI
local old = player.PlayerGui:FindFirstChild("EggCollectorUI")
if old then old:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggCollectorUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 300)
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

-- Minimize Button
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
local tabMain  = makeTab("Collector", 0)
local tabDebug = makeTab("Debug", 0.5)

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

-- ── Debug Panel ──────────────────────────────────────────────────────────────
local debugPanel = Instance.new("Frame")
debugPanel.Size = UDim2.new(1, 0, 1, -68)
debugPanel.Position = UDim2.new(0, 0, 0, 68)
debugPanel.BackgroundTransparency = 1
debugPanel.Visible = false
debugPanel.Parent = frame

local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(1, -10, 0, 18)
radiusLabel.Position = UDim2.new(0, 5, 0, 4)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Text = "Stand next to a ground egg, then scan 20st"
radiusLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
radiusLabel.TextSize = 10
radiusLabel.Font = Enum.Font.Code
radiusLabel.TextXAlignment = Enum.TextXAlignment.Left
radiusLabel.Parent = debugPanel

local btnNear = Instance.new("TextButton")
btnNear.Size = UDim2.new(0.44, 0, 0, 26)
btnNear.Position = UDim2.new(0.03, 0, 0, 26)
btnNear.BackgroundColor3 = Color3.fromRGB(60, 150, 80)
btnNear.Text = "Scan 20st (close)"
btnNear.TextColor3 = Color3.fromRGB(255, 255, 255)
btnNear.TextScaled = true
btnNear.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
btnNear.Parent = debugPanel
Instance.new("UICorner", btnNear).CornerRadius = UDim.new(0, 6)

local btnFar = Instance.new("TextButton")
btnFar.Size = UDim2.new(0.44, 0, 0, 26)
btnFar.Position = UDim2.new(0.53, 0, 0, 26)
btnFar.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
btnFar.Text = "Scan 150st (wide)"
btnFar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFar.TextScaled = true
btnFar.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
btnFar.Parent = debugPanel
Instance.new("UICorner", btnFar).CornerRadius = UDim.new(0, 6)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -8, 0, 195)
scrollFrame.Position = UDim2.new(0, 4, 0, 58)
scrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = debugPanel
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 6)

local logLayout = Instance.new("UIListLayout")
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Padding = UDim.new(0, 2)
logLayout.Parent = scrollFrame

local logPad = Instance.new("UIPadding")
logPad.PaddingLeft = UDim.new(0, 4)
logPad.PaddingTop  = UDim.new(0, 4)
logPad.Parent = scrollFrame

local logEntries = {}
local function addLog(text, color)
    color = color or Color3.fromRGB(180, 255, 180)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 0, 14)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextSize = 10
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.Parent = scrollFrame
    table.insert(logEntries, lbl)
    if #logEntries > 80 then
        logEntries[1]:Destroy()
        table.remove(logEntries, 1)
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y + 8)
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
end

local function doScan(radius)
    local char = player.Character
    if not char then addLog("No character!", Color3.fromRGB(255,80,80)) return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then addLog("No HumanoidRootPart!", Color3.fromRGB(255,80,80)) return end

    local nearby = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local pos
            if obj:IsA("BasePart") then
                pos = obj.Position
            elseif obj:IsA("Model") then
                if obj.PrimaryPart then
                    pos = obj.PrimaryPart.Position
                else
                    local p = obj:FindFirstChildWhichIsA("BasePart", true)
                    if p then pos = p.Position end
                end
            end
            if pos then
                local dist = (root.Position - pos).Magnitude
                if dist <= radius then
                    table.insert(nearby, { obj = obj, dist = dist, pos = pos })
                end
            end
        end
    end

    table.sort(nearby, function(a, b) return a.dist < b.dist end)
    addLog(string.format("── Scan r=%dst: %d objects ──", radius, #nearby), Color3.fromRGB(255,220,80))

    for _, entry in ipairs(nearby) do
        local obj  = entry.obj
        local dist = entry.dist
        local pos  = entry.pos
        local parentName = obj.Parent and obj.Parent.Name or "nil"
        local extra = ""
        if obj:IsA("BasePart") then
            local speed = obj.AssemblyLinearVelocity.Magnitude
            local anch  = obj.Anchored and "A" or "U"
            extra = string.format(" Y=%.1f V=%.1f %s", pos.Y, speed, anch)
            local hints = {}
            if obj:FindFirstChildOfClass("ClickDetector")   then table.insert(hints, "CLICK") end
            if obj:FindFirstChildOfClass("ProximityPrompt") then table.insert(hints, "PROX")  end
            if obj:FindFirstChildOfClass("TouchInterest")   then table.insert(hints, "TOUCH") end
            if obj:FindFirstChildWhichIsA("Script") or obj:FindFirstChildWhichIsA("LocalScript") then
                table.insert(hints, "SCR")
            end
            if #hints > 0 then extra = extra .. " [" .. table.concat(hints,",") .. "]" end
        end

        local clr = Color3.fromRGB(180, 180, 180)
        if obj:IsA("MeshPart")  then clr = Color3.fromRGB(120, 160, 255) end
        if obj:IsA("Model")     then clr = Color3.fromRGB(255, 220, 80)  end
        if obj:IsA("Part")      then clr = Color3.fromRGB(180, 255, 180) end

        if obj:IsA("MeshPart") and obj.Name:lower():find("egg")
           and obj.Parent and obj.Parent.Name:lower():find("chunk") then
            clr = Color3.fromRGB(0, 255, 220)
            extra = extra .. " ← GROUND EGG ✅"
        end

        addLog(string.format("%.1fst | %s (%s) | ^%s%s",
            dist, obj.Name, obj.ClassName, parentName, extra), clr)
    end

    if #nearby == 0 then
        addLog("Nothing found. Move closer!", Color3.fromRGB(255,150,80))
    end
end

btnNear.MouseButton1Click:Connect(function() doScan(20)  end)
btnFar.MouseButton1Click:Connect(function()  doScan(150) end)

-- ── Tab Switching ────────────────────────────────────────────────────────────
local function setTab(isDebug)
    mainPanel.Visible  = not isDebug
    debugPanel.Visible = isDebug
    if isDebug then
        tabDebug.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
        tabDebug.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabMain.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        tabMain.TextColor3 = Color3.fromRGB(180, 180, 180)
    else
        tabMain.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
        tabMain.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabDebug.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        tabDebug.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end
setTab(false)
tabMain.MouseButton1Click:Connect(function() setTab(false) end)
tabDebug.MouseButton1Click:Connect(function() setTab(true) end)

-- ── Minimize Logic ───────────────────────────────────────────────────────────
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        frame.Size = UDim2.new(0, 280, 0, 35)
        minimizeBtn.Text = "□"
        tabFrame.Visible = false
        mainPanel.Visible = false
        debugPanel.Visible = false
    else
        frame.Size = UDim2.new(0, 280, 0, 300)
        minimizeBtn.Text = "–"
        tabFrame.Visible = true
        mainPanel.Visible = true
        debugPanel.Visible = false
    end
end)

-- ── Ground Egg Check ─────────────────────────────────────────────────────────
--[[
    Ground eggs confirmed:
      - MeshPart named "Egg" (case-insensitive)
      - Parent name contains "chunk" (chunk1, chunk2, chunk3, etc.)
    Falling/visual eggs:
      - Same MeshPart name but parent is "camera" or similar — SKIP those
--]]
local function isGroundEgg(obj)
    if not obj:IsA("MeshPart") then return false, nil end
    if not obj.Name:lower():find("egg") then return false, nil end
    if not obj.Parent then return false, nil end
    if not obj.Parent.Name:lower():find("chunk") then return false, nil end
    return true, obj.Position
end

-- ── Collection Loop ──────────────────────────────────────────────────────────
-- Only change from original: removed the dist < SCAN_RADIUS check
-- so it collects eggs anywhere on the map, not just within 120 studs
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

        local ok, targetPos = isGroundEgg(obj)
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

print("✅ Kyeggo Egg Collector loaded! Ground egg rule: MeshPart named 'Egg' parented to 'chunk*'")
