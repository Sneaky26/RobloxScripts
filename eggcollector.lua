local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local collected = 0
local isRunning = false

-- ── Ground Detection Settings ──────────────────────────────────────────────
-- Tweak these if eggs aren't being detected correctly.
-- Use the Debug tab to find what Y level your map's ground is.
local GROUND_Y_THRESHOLD  = 15    -- eggs ABOVE this Y are considered "falling"
local MAX_VELOCITY        = 3     -- eggs moving faster than this stud/s are "falling"
local SCAN_RADIUS         = 120   -- how far (studs) to look for eggs
local COLLECT_INTERVAL    = 0.4   -- seconds between each sweep
local MAX_PER_SWEEP       = 8     -- max eggs to collect per sweep
-- ───────────────────────────────────────────────────────────────────────────

-- Remove old UI
local old = player.PlayerGui:FindFirstChild("EggCollectorUI")
if old then old:Destroy() end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggCollectorUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player.PlayerGui

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 260)
frame.Position = UDim2.new(0.5, -130, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- ── Title Bar ──────────────────────────────────────────
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 10)
titleBarCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Kyeggo Egg Collector"
title.TextColor3 = Color3.fromRGB(255, 220, 80)
title.TextScaled = true
title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
title.Parent = titleBar

-- X Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -32, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
closeBtn.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 6)
closeBtnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ── Tab Buttons ─────────────────────────────────────────
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
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    return btn
end

local tabMain  = makeTab("Collector", 0)
local tabDebug = makeTab("Debug", 0.5)

-- ── Main Panel ──────────────────────────────────────────
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

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleBtn

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

-- ── Debug Panel ─────────────────────────────────────────
local debugPanel = Instance.new("Frame")
debugPanel.Size = UDim2.new(1, 0, 1, -68)
debugPanel.Position = UDim2.new(0, 0, 0, 68)
debugPanel.BackgroundTransparency = 1
debugPanel.Visible = false
debugPanel.Parent = frame

local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0.9, 0, 0, 28)
scanBtn.Position = UDim2.new(0.05, 0, 0, 6)
scanBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
scanBtn.Text = "Scan Nearby Eggs"
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.TextScaled = true
scanBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
scanBtn.Parent = debugPanel

local scanBtnCorner = Instance.new("UICorner")
scanBtnCorner.CornerRadius = UDim.new(0, 6)
scanBtnCorner.Parent = scanBtn

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -8, 0, 145)
scrollFrame.Position = UDim2.new(0, 4, 0, 40)
scrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = debugPanel

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 6)
scrollCorner.Parent = scrollFrame

local logLayout = Instance.new("UIListLayout")
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Padding = UDim.new(0, 2)
logLayout.Parent = scrollFrame

local logPadding = Instance.new("UIPadding")
logPadding.PaddingLeft = UDim.new(0, 4)
logPadding.PaddingTop = UDim.new(0, 4)
logPadding.Parent = scrollFrame

local logEntries = {}

local function addLog(text, color)
    color = color or Color3.fromRGB(180, 255, 180)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.Parent = scrollFrame
    table.insert(logEntries, lbl)
    if #logEntries > 40 then
        logEntries[1]:Destroy()
        table.remove(logEntries, 1)
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y + 8)
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
end

-- ── Ground Egg Detection ─────────────────────────────────────────────────────
--[[
    isGroundEgg(obj) → bool, position
    Returns true (and the world position) only when ALL of these pass:
      1. Name contains "egg" (case-insensitive)
      2. It is a BasePart (MeshPart is a subclass – this catches MeshParts too)
      3. Y position is below GROUND_Y_THRESHOLD  → not flying through the air
      4. AssemblyLinearVelocity magnitude ≤ MAX_VELOCITY → not actively falling
    Falling eggs spawn high up and move fast; ground eggs sit still at ground level.
    Adjust GROUND_Y_THRESHOLD at the top of the script if your map's terrain is hilly.
--]]
local function isGroundEgg(obj)
    -- Must be a BasePart (covers Part, MeshPart, UnionOperation, etc.)
    if not obj:IsA("BasePart") then return false, nil end

    -- Name must contain "egg"
    if not obj.Name:lower():find("egg") then return false, nil end

    local pos = obj.Position

    -- Y-height check: ground eggs rest near terrain level
    if pos.Y > GROUND_Y_THRESHOLD then return false, nil end

    -- Velocity check: falling eggs move fast downward
    local speed = obj.AssemblyLinearVelocity.Magnitude
    if speed > MAX_VELOCITY then return false, nil end

    return true, pos
end

-- ── Scan Button Logic ────────────────────────────────────────────────────────
scanBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char then addLog("No character found!", Color3.fromRGB(255,80,80)) return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then addLog("No HumanoidRootPart!", Color3.fromRGB(255,80,80)) return end

    addLog(string.format("── Scan (r=%d, maxY=%d, maxV=%d) ──",
        SCAN_RADIUS, GROUND_Y_THRESHOLD, MAX_VELOCITY),
        Color3.fromRGB(255, 220, 80))

    local groundCount, fallingCount = 0, 0

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("egg") then
            local pos = obj.Position
            local dist = (root.Position - pos).Magnitude
            if dist <= SCAN_RADIUS then
                local speed   = obj.AssemblyLinearVelocity.Magnitude
                local isHigh  = pos.Y > GROUND_Y_THRESHOLD
                local isFast  = speed > MAX_VELOCITY
                local ground  = not isHigh and not isFast

                if ground then
                    groundCount += 1
                    addLog(
                        string.format("[GROUND✅] %s (%s) Y=%.1f V=%.1f dist=%d",
                            obj.Name, obj.ClassName, pos.Y, speed, math.floor(dist)),
                        Color3.fromRGB(80, 255, 80)
                    )
                else
                    fallingCount += 1
                    local reason = isHigh and ("highY=%.1f"):format(pos.Y)
                                           or ("fastV=%.1f"):format(speed)
                    addLog(
                        string.format("[SKIP ❌] %s (%s) %s dist=%d",
                            obj.Name, obj.ClassName, reason, math.floor(dist)),
                        Color3.fromRGB(255, 100, 100)
                    )
                end
            end
        end
    end

    addLog(string.format("Done. Ground=%d  Falling/skip=%d", groundCount, fallingCount),
        Color3.fromRGB(255, 220, 80))
    addLog(string.format("Thresholds: Y<%d  Speed<%d  (edit top of script)",
        GROUND_Y_THRESHOLD, MAX_VELOCITY),
        Color3.fromRGB(120, 120, 120))
end)

-- ── Tab Switching ────────────────────────────────────────
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

-- ── Main Collection Loop ─────────────────────────────────────────────────────
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
            local dist = (root.Position - targetPos).Magnitude
            if dist < SCAN_RADIUS then
                eggsFound += 1
                root.CFrame = CFrame.new(targetPos + Vector3.new(0, 4, 0))
                task.wait(0.15)
                root.CFrame = originalCFrame
                task.wait(0.08)
                collected += 1
                counterLabel.Text = "Eggs Collected: " .. collected
            end
        end
    end
end

task.spawn(function()
    while true do
        pcall(collectEggs)
        task.wait(COLLECT_INTERVAL)
    end
end)

print("✅ Kyeggo Egg Collector Loaded!")
