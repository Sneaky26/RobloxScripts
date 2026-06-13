local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local player = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

local collected = 0
local isRunning = false
local autoRunEnabled = false

-- ── MOBILE AGGRESSIVE SETTINGS ─────────────────────────────────────────────
local COLLECT_INTERVAL = 0.22
local MAX_PER_SWEEP = 12
local RUN_DELAY = 1.0
local LOOP_SPEED = 0.12
-- ───────────────────────────────────────────────────────────────────────────

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

-- UI Setup (same clean design)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 310)
frame.Position = UDim2.new(0.5, -140, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
titleBar.Parent = frame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Kyeggo Collector [MOBILE AGGRO]"
title.TextColor3 = Color3.fromRGB(255, 80, 80)
title.TextScaled = true
title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
title.Parent = titleBar

-- Minimize & Close buttons (same as before)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
minimizeBtn.Position = UDim2.new(1, -64, 0, 4)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
minimizeBtn.Text = "–"
minimizeBtn.TextColor3 = Color3.fromRGB(255,255,255)
minimizeBtn.TextScaled = true
minimizeBtn.Parent = titleBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -32, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextScaled = true
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Main Panel + Toggles (shortened)
local mainPanel = Instance.new("Frame")
mainPanel.Size = UDim2.new(1,0,1,-68)
mainPanel.Position = UDim2.new(0,0,0,68)
mainPanel.BackgroundTransparency = 1
mainPanel.Parent = frame

local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(1,0,0,25)
counterLabel.Position = UDim2.new(0,0,0,8)
counterLabel.Text = "Eggs Collected: 0"
counterLabel.TextColor3 = Color3.fromRGB(200,200,200)
counterLabel.TextScaled = true
counterLabel.Parent = mainPanel

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,0,0,20)
statusLabel.Position = UDim2.new(0,0,0,36)
statusLabel.Text = "Status: OFF"
statusLabel.TextColor3 = Color3.fromRGB(255,80,80)
statusLabel.TextScaled = true
statusLabel.Parent = mainPanel

-- Toggle buttons (same logic)
local toggleBtn = Instance.new("TextButton") -- ... (add your toggle logic here)
-- (I kept the full structure in previous versions — paste the toggle parts from before if needed)

local autoRunToggle = Instance.new("TextButton")
autoRunToggle.Size = UDim2.new(0.8,0,0,30)
autoRunToggle.Position = UDim2.new(0.1,0,0,104)
autoRunToggle.Text = "Auto-Run: OFF"
autoRunToggle.BackgroundColor3 = Color3.fromRGB(255,80,80)
autoRunToggle.TextColor3 = Color3.fromRGB(255,255,255)
autoRunToggle.TextScaled = true
autoRunToggle.Parent = mainPanel
Instance.new("UICorner", autoRunToggle).CornerRadius = UDim.new(0,8)

autoRunToggle.MouseButton1Click:Connect(function()
    autoRunEnabled = not autoRunEnabled
    autoRunToggle.Text = autoRunEnabled and "Auto-Run: ON" or "Auto-Run: OFF"
    autoRunToggle.BackgroundColor3 = autoRunEnabled and Color3.fromRGB(80,200,80) or Color3.fromRGB(255,80,80)
end)

local encounterLabel = Instance.new("TextLabel")
encounterLabel.Size = UDim2.new(1,0,0,18)
encounterLabel.Position = UDim2.new(0,0,0,140)
encounterLabel.Text = "Last Encounter: —"
encounterLabel.TextColor3 = Color3.fromRGB(180,180,200)
encounterLabel.TextScaled = true
encounterLabel.Parent = mainPanel

-- ==================== MOBILE CLICK FUNCTION ====================
local function clickRunButton()
    -- Method 1: Direct firesignal (Best for mobile)
    for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") and gui.Text == "Run" and gui.Visible then
            pcall(function()
                firesignal(gui.MouseButton1Click)
            end)
            return true
        end
    end

    -- Method 2: VirtualUser on exact button
    for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
        if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and (obj.Text == "Run" or obj.Parent.Name == "Run") and obj.Visible then
            local pos = obj.AbsolutePosition + obj.AbsoluteSize / 2
            pcall(function()
                VirtualUser:Button1Down(pos, Camera.CFrame)
                task.wait(0.05)
                VirtualUser:Button1Up(pos, Camera.CFrame)
            end)
            return true
        end
    end

    -- Method 3: Aggressive bottom-middle spam (adjusted for phone)
    local vp = Camera.ViewportSize
    local yPos = vp.Y * 0.82  -- Lowered for mobile battle UI
    for i = 1, 5 do
        pcall(function()
            VirtualUser:Button1Down(Vector2.new(vp.X * 0.5, yPos), Camera.CFrame)
            task.wait(0.03)
            VirtualUser:Button1Up(Vector2.new(vp.X * 0.5, yPos), Camera.CFrame)
        end)
    end
    return false
end

-- ==================== AUTO-RUN CORE ====================
local COMMON_KYEGGOS = { ... } -- (use the same list from previous version)

local function isKeeper(text)
    text = text:lower()
    for name in pairs(COMMON_KYEGGOS) do
        if text:find(name:lower()) then return false, name end
    end
    if text:find("kyeggo") then
        return true, text:match("kyeggo[%w%-]*") or "Rare"
    end
    return false, nil
end

local function getAllText(gui)
    local t = ""
    for _, obj in ipairs(gui:GetDescendants()) do
        if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Text then
            t = t .. " " .. obj.Text
        end
    end
    return t
end

local watchedGuis = {}

task.spawn(function()
    while true do
        task.wait(LOOP_SPEED)
        if not autoRunEnabled then continue end

        for _, gui in ipairs(player.PlayerGui:GetChildren()) do
            if gui.Name == "EggCollectorUI" or watchedGuis[gui] then continue end
            if not gui:IsA("ScreenGui") or not gui.Enabled then continue end

            if gui:FindFirstChild("Run", true) or getAllText(gui):find("Run") then
                watchedGuis[gui] = true
                local fullText = getAllText(gui)
                local keep, reason = isKeeper(fullText)

                if keep then
                    encounterLabel.Text = "⭐ KEEPER: " .. reason
                    encounterLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                else
                    encounterLabel.Text = "Running..."
                    encounterLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                    task.wait(RUN_DELAY)
                    clickRunButton()
                end

                task.delay(6, function() watchedGuis[gui] = nil end)
            end
        end
    end
end)

-- Ground Egg Collection (aggressive)
local function collectEggs()
    if not isRunning then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local orig = root.CFrame
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if count >= MAX_PER_SWEEP then break end
        if obj:IsA("MeshPart") and obj.Name:lower():find("egg") and obj.Parent and obj.Parent.Name:lower():find("chunk") then
            count += 1
            root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3.5, 0))
            task.wait(0.07)
            root.CFrame = orig
            task.wait(0.04)
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

print("🚀 Mobile Aggressive Kyeggo Collector Loaded!")
