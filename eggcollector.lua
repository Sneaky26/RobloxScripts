-- Kyeggo Event Auto Egg Collector (Improved 2026)
-- Works with Delta Executor on Android

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local collected = 0
local isRunning = false

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

-- Scan button
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0.9, 0, 0, 28)
scanBtn.Position = UDim2.new(0.05, 0, 0, 6)
scanBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
scanBtn.Text = "Scan Nearby Objects"
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.TextScaled = true
scanBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
scanBtn.Parent = debugPanel

local scanBtnCorner = Instance.new("UICorner")
scanBtnCorner.CornerRadius = UDim.new(0, 6)
scanBtnCorner.Parent = scanBtn

-- Scrolling log
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
    -- Keep at most 40 entries
    if #logEntries > 40 then
        logEntries[1]:Destroy()
        table.remove(logEntries, 1)
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y + 8)
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
end

-- ── Scan Logic ──────────────────────────────────────────
--[[
    HOW TO FIND THE REAL EGG OBJECT:
    The visual falling egg is usually a MeshPart/Part named "Egg" that is
    purely decorative. The REAL collectable is typically one of:
      • A Part/Model with a "Touched" connection (has a Script/LocalScript child)
      • A Part inside a Model folder (e.g. Workspace.Eggs.EggModel)
      • A part whose parent Model has a BoolValue / StringValue "EggType" inside
      • A Part with a ClickDetector or ProximityPrompt child
    The scan below prints Name, ClassName, Parent, and any notable children
    so you can identify the correct object to teleport to.
--]]

scanBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char then addLog("No character found!", Color3.fromRGB(255,80,80)) return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then addLog("No HumanoidRootPart!", Color3.fromRGB(255,80,80)) return end

    addLog("── Scanning (150 stud range) ──", Color3.fromRGB(255, 220, 80))

    local found = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        -- Cast a wide net: any instance whose name contains "egg" (case-insensitive)
        if obj.Name:lower():find("egg") then
            local dist = 999
            local pos = nil

            -- Try to get a position for distance check
            if obj:IsA("BasePart") then
                pos = obj.Position
            elseif obj:IsA("Model") and obj.PrimaryPart then
                pos = obj.PrimaryPart.Position
            elseif obj:IsA("Model") then
                local p = obj:FindFirstChildWhichIsA("BasePart", true)
                if p then pos = p.Position end
            end

            if pos then
                dist = (root.Position - pos).Magnitude
            end

            if dist <= 150 then
                found += 1
                -- Color code by class type to help identify the real one
                local clr = Color3.fromRGB(180, 255, 180)
                if obj:IsA("Model") then
                    clr = Color3.fromRGB(255, 220, 80)   -- yellow = Model (likely real)
                elseif obj:IsA("MeshPart") then
                    clr = Color3.fromRGB(180, 180, 255)  -- blue = MeshPart (likely visual)
                end

                -- Check for collectability hints
                local hints = {}
                if obj:FindFirstChildWhichIsA("Script") or obj:FindFirstChildWhichIsA("LocalScript") then
                    table.insert(hints, "HAS_SCRIPT")
                end
                if obj:FindFirstChildOfClass("ClickDetector") then
                    table.insert(hints, "CLICK")
                end
                if obj:FindFirstChildOfClass("ProximityPrompt") then
                    table.insert(hints, "PROMPT")
                end
                if obj:FindFirstChildOfClass("BoolValue") or obj:FindFirstChildOfClass("StringValue") or obj:FindFirstChildOfClass("IntValue") then
                    table.insert(hints, "HAS_VALUE")
                end
                if obj:FindFirstChildOfClass("BillboardGui") then
                    table.insert(hints, "BILLBOARD")
                end

                local hintStr = #hints > 0 and (" [" .. table.concat(hints, ",") .. "]") or ""
                local parentName = obj.Parent and obj.Parent.Name or "nil"
                local distStr = math.floor(dist) .. "st"

                addLog(
                    string.format("[%d] %s (%s) | ^%s | %s%s",
                        found, obj.Name, obj.ClassName, parentName, distStr, hintStr),
                    clr
                )
            end
        end
    end

    if found == 0 then
        addLog("No egg objects found nearby.", Color3.fromRGB(255, 150, 80))
    else
        addLog(string.format("Done. %d object(s) found.", found), Color3.fromRGB(255, 220, 80))
        addLog("Yellow=Model  Blue=MeshPart  Green=Other", Color3.fromRGB(120, 120, 120))
        addLog("Look for HAS_SCRIPT or PROMPT tags -- those are likely the real collectable.", Color3.fromRGB(120, 255, 120))
    end
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

-- ── Main Collection Function ─────────────────────────────
--[[
    UPDATE THIS after using the Debug tab:
    Replace the name/class checks below with whatever the scan reveals.
    E.g. if the real egg is a Model named "EggPickup", change the condition to:
        obj:IsA("Model") and obj.Name == "EggPickup"
    and teleport to obj.PrimaryPart.Position instead of obj.Position
--]]
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
        if eggsFound >= 8 then break end

        local isEgg = false
        local targetPos = nil

        -- ── EDIT THESE CONDITIONS based on Debug tab findings ──
        if obj:IsA("Model") and obj.Name:lower():find("egg") then
            -- Model type eggs (most likely the real collectable)
            isEgg = true
            if obj.PrimaryPart then
                targetPos = obj.PrimaryPart.Position
            else
                local p = obj:FindFirstChildWhichIsA("BasePart", true)
                if p then targetPos = p.Position end
            end
        elseif obj:IsA("BasePart") and obj.Name:lower():find("egg")
               and not obj:IsA("MeshPart") then
            -- Non-mesh BaseParts named egg (e.g. plain Parts used as hitboxes)
            isEgg = true
            targetPos = obj.Position
        end
        -- MeshParts are intentionally excluded (those are the visual-only falling ones)

        if isEgg and targetPos then
            local dist = (root.Position - targetPos).Magnitude
            if dist < 120 then
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

-- Main Loop
task.spawn(function()
    while true do
        pcall(collectEggs)
        task.wait(0.4)
    end
end)

print("✅ Kyeggo Egg Collector Loaded!")
