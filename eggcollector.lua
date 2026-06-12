local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local collected = 0
local isRunning = false

-- ── Settings ────────────────────────────────────────────────────────────────
local GROUND_Y_THRESHOLD = 15    -- eggs ABOVE this Y are "falling" (raise if your map is elevated)
local MAX_VELOCITY       = 3     -- eggs faster than this stud/s are "falling"
local SCAN_RADIUS        = 120   -- collection radius in studs
local COLLECT_INTERVAL   = 0.4   -- seconds between sweeps
local MAX_PER_SWEEP      = 8     -- max eggs per sweep
-- ────────────────────────────────────────────────────────────────────────────

-- Remove old UI
local old = player.PlayerGui:FindFirstChild("EggCollectorUI")
if old then old:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggCollectorUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 260)
frame.Position = UDim2.new(0.5, -130, 0, 20)
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
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Kyeggo Egg Collector"
title.TextColor3 = Color3.fromRGB(255, 220, 80)
title.TextScaled = true
title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
title.Parent = titleBar

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

-- Tab Buttons
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

-- Debug Panel
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
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0, 6)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -8, 0, 145)
scrollFrame.Position = UDim2.new(0, 4, 0, 40)
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

-- ── Core: resolve a MeshPart egg into (isGround, position, targetPart) ───────
--[[
    HOW THIS WORKS:
    The visible egg is almost always a MeshPart named "Egg" (or similar).
    The actual COLLECTIBLE is whatever the server's touch/proximity script
    listens on — typically one of:

      A) The MeshPart itself    → touch teleport directly onto it
      B) A sibling Part named   → "Hitbox", "Touch", "Collect", "Body" etc.
         inside the same Model
      C) The parent Model       → touching any part of the model counts

    We find the MeshPart by name, then climb UP to its parent Model and look
    for a sibling BasePart that looks like a hitbox, falling back to the
    MeshPart itself.  We ALWAYS read Y/velocity from the MeshPart (visual egg)
    because that's the part that falls.
--]]
local HITBOX_NAMES = { "hitbox", "touch", "collect", "trigger", "body", "base", "root" }

local function resolveEgg(obj)
    -- Only interested in BaseParts named "egg" (covers MeshPart too)
    if not obj:IsA("BasePart") then return false, nil, nil end
    if not obj.Name:lower():find("egg") then return false, nil, nil end

    local pos   = obj.Position
    local speed = obj.AssemblyLinearVelocity.Magnitude

    -- Ground checks on the visual egg part
    if pos.Y > GROUND_Y_THRESHOLD then return false, nil, nil end
    if speed > MAX_VELOCITY        then return false, nil, nil end

    -- ── Find the best part to teleport onto ──────────────────────────────
    -- Priority 1: sibling hitbox inside the same Model
    local targetPart = nil
    local parentModel = obj.Parent
    if parentModel and parentModel:IsA("Model") then
        for _, sib in ipairs(parentModel:GetChildren()) do
            if sib:IsA("BasePart") and sib ~= obj then
                local sibLow = sib.Name:lower()
                for _, hname in ipairs(HITBOX_NAMES) do
                    if sibLow:find(hname) then
                        targetPart = sib
                        break
                    end
                end
            end
            if targetPart then break end
        end

        -- Priority 2: any other BasePart sibling (catch-all for unnamed hitboxes)
        if not targetPart then
            for _, sib in ipairs(parentModel:GetChildren()) do
                if sib:IsA("BasePart") and sib ~= obj then
                    targetPart = sib
                    break
                end
            end
        end
    end

    -- Priority 3: fall back to the MeshPart itself
    if not targetPart then
        targetPart = obj
    end

    return true, targetPart.Position, targetPart
end

-- ── Scan Button ──────────────────────────────────────────────────────────────
scanBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char then addLog("No character!", Color3.fromRGB(255,80,80)) return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then addLog("No HumanoidRootPart!", Color3.fromRGB(255,80,80)) return end

    addLog(string.format("── Scan r=%d maxY=%d maxV=%d ──",
        SCAN_RADIUS, GROUND_Y_THRESHOLD, MAX_VELOCITY), Color3.fromRGB(255,220,80))

    local gCount, fCount = 0, 0

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("egg") then
            local dist = (root.Position - obj.Position).Magnitude
            if dist <= SCAN_RADIUS then
                local speed  = obj.AssemblyLinearVelocity.Magnitude
                local isHigh = obj.Position.Y > GROUND_Y_THRESHOLD
                local isFast = speed > MAX_VELOCITY

                -- Parent info
                local parentName  = obj.Parent and obj.Parent.Name or "nil"
                local parentClass = obj.Parent and obj.Parent.ClassName or "nil"

                -- Sibling count (potential hitboxes)
                local sibCount = 0
                if obj.Parent and obj.Parent:IsA("Model") then
                    for _, s in ipairs(obj.Parent:GetChildren()) do
                        if s:IsA("BasePart") and s ~= obj then sibCount += 1 end
                    end
                end

                if not isHigh and not isFast then
                    gCount += 1
                    addLog(
                        string.format("[GROUND✅] %s | Y=%.1f V=%.1f d=%d | ^%s(%s) sibs=%d",
                            obj.Name, obj.Position.Y, speed, math.floor(dist),
                            parentName, parentClass, sibCount),
                        Color3.fromRGB(80, 255, 80)
                    )
                    -- Show siblings so we know what the hitbox is called
                    if obj.Parent and obj.Parent:IsA("Model") then
                        for _, sib in ipairs(obj.Parent:GetChildren()) do
                            if sib:IsA("BasePart") and sib ~= obj then
                                addLog(
                                    string.format("  sib: %s (%s) canCollide=%s",
                                        sib.Name, sib.ClassName, tostring(sib.CanCollide)),
                                    Color3.fromRGB(180, 255, 180)
                                )
                            end
                        end
                    end
                else
                    fCount += 1
                    local reason = isHigh
                        and string.format("highY=%.1f", obj.Position.Y)
                        or  string.format("fastV=%.1f", speed)
                    addLog(
                        string.format("[SKIP ❌] %s | %s | d=%d | ^%s",
                            obj.Name, reason, math.floor(dist), parentName),
                        Color3.fromRGB(255, 100, 100)
                    )
                end
            end
        end
    end

    addLog(string.format("Done. Ground=%d  Skipped=%d", gCount, fCount), Color3.fromRGB(255,220,80))
    if gCount == 0 then
        addLog("⚠ No ground eggs! Try raising GROUND_Y_THRESHOLD.", Color3.fromRGB(255,180,60))
    end
end)

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

-- ── Collection Loop ──────────────────────────────────────────────────────────
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

        local ok, targetPos, targetPart = resolveEgg(obj)

        if ok and targetPos then
            local dist = (root.Position - targetPos).Magnitude
            if dist < SCAN_RADIUS then
                eggsFound += 1

                -- Teleport onto the target part (hitbox or egg itself)
                root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                task.wait(0.12)

                -- If the parent is a Model with a PrimaryPart, also try touching that
                if targetPart and targetPart.Parent and targetPart.Parent:IsA("Model") then
                    local model = targetPart.Parent
                    if model.PrimaryPart then
                        root.CFrame = CFrame.new(
                            model.PrimaryPart.Position + Vector3.new(0, 3, 0))
                        task.wait(0.08)
                    end
                end

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
