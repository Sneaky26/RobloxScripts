local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

local collected = 0
local isRunning = false
local isMinimized = false
local espEnabled = false
local autoRunEnabled = false

-- ── AGGRESSIVE SETTINGS ─────────────────────────────────────────────────────
local COLLECT_INTERVAL = 0.25
local MAX_PER_SWEEP = 10
local RUN_DELAY = 1.2          -- Much faster reaction
local LOOP_SPEED = 0.15        -- Very aggressive scanning
-- ─────────────────────────────────────────────────────────────────────────────

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

-- Main Frame + UI (same as before, shortened for space)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 310)
frame.Position = UDim2.new(0.5, -140, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
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
title.Text = "Kyeggo Egg Collector [AGGRESSIVE]"
title.TextColor3 = Color3.fromRGB(255, 100, 100)
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
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Tabs and Panels (Main, ESP, Scan) - Same as previous version
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 28)
tabFrame.Position = UDim2.new(0, 0, 0, 36)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = frame

local function makeTab(text, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.333, -3, 1, 0)
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
local tabEsp = makeTab("ESP", 0.333)
local tabScan = makeTab("Scan", 0.666)

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
encounterLabel.Position = UDim2.new(0, 0, 0, 140)
encounterLabel.BackgroundTransparency = 1
encounterLabel.Text = "Last Encounter: —"
encounterLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
encounterLabel.TextScaled = true
encounterLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
encounterLabel.Parent = mainPanel

-- Tab + Minimize logic (same as before)
local espPanel = Instance.new("Frame") espPanel.Size = UDim2.new(1,0,1,-68) espPanel.Position = UDim2.new(0,0,0,68) espPanel.BackgroundTransparency = 1 espPanel.Visible = false espPanel.Parent = frame
local scanPanel = Instance.new("Frame") scanPanel.Size = UDim2.new(1,0,1,-68) scanPanel.Position = UDim2.new(0,0,0,68) scanPanel.BackgroundTransparency = 1 scanPanel.Visible = false scanPanel.Parent = frame

local function setTab(t)
    mainPanel.Visible = (t == "main")
    espPanel.Visible = (t == "esp")
    scanPanel.Visible = (t == "scan")
end
setTab("main")
-- (Add tab clicks and minimize logic if needed - they work the same)

-- ==================== AGGRESSIVE AUTO-RUN ====================

local COMMON_KYEGGOS = { -- same list
    ["Kyeggo-rviolet"] = true, ["Kyeggo-rorange"] = true, ["Kyeggo-rred"] = true,
    ["Kyeggo-blue"] = true, ["Kyeggo-green"] = true, ["Kyeggo"] = true,
    ["Kyeggo-pattern1"] = true, ["Kyeggo-pattern2"] = true, ["Kyeggo-pattern3"] = true,
    ["Kyeggo-pattern4"] = true, ["Kyeggo-faberge1"] = true, ["Kyeggo-faberge2"] = true,
    ["Kyeggo-faberge3"] = true,
}

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

local function clickRunButton()
    local vu = game:GetService("VirtualUser")
    local clicked = false

    -- Ultra aggressive multi-method clicking
    for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
        if obj:IsA("TextButton") and (obj.Text == "Run" or obj.Parent.Name == "Run") and obj.Visible then
            local pos = obj.AbsolutePosition + (obj.AbsoluteSize / 2)
            pcall(function()
                vu:Button1Down(pos, Camera.CFrame)
                task.wait(0.05)
                vu:Button1Up(pos, Camera.CFrame)
            end)
            clicked = true
            break
        end
    end

    if not clicked then
        -- Fallback spam click bottom center
        local vp = Camera.ViewportSize
        for i = 1, 3 do
            pcall(function()
                vu:Button1Down(Vector2.new(vp.X/2, vp.Y * 0.87), Camera.CFrame)
                task.wait(0.04)
                vu:Button1Up(Vector2.new(vp.X/2, vp.Y * 0.87), Camera.CFrame)
            end)
        end
    end
    return clicked
end

local function getAllText(gui)
    local text = ""
    for _, obj in ipairs(gui:GetDescendants()) do
        if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Text and #obj.Text > 1 then
            text = text .. " " .. obj.Text
        end
    end
    return text
end

local function showNotif(text, color)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 280, 0, 40)
    notif.Position = UDim2.new(0.5, -140, 0, 10)
    notif.BackgroundColor3 = color or Color3.fromRGB(30,30,45)
    notif.Parent = screenGui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-10,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextScaled = true
    lbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    lbl.Parent = notif
    task.delay(2.8, function() notif:Destroy() end)
end

local watchedGuis = {}

task.spawn(function()
    while true do
        task.wait(LOOP_SPEED)
        if not autoRunEnabled then continue end

        for _, gui in ipairs(player.PlayerGui:GetChildren()) do
            if gui.Name == "EggCollectorUI" or watchedGuis[gui] then continue end
            if not gui:IsA("ScreenGui") or not gui.Enabled then continue end

            if gui:FindFirstChild("Run", true) or (gui:FindFirstChildWhichIsA("TextButton") and gui:FindFirstChildWhichIsA("TextButton").Text == "Run") then
                watchedGuis[gui] = true

                local fullText = getAllText(gui)
                local keep, reason = isKeeper(fullText)

                if keep then
                    showNotif("⭐ KEEPER FOUND: " .. reason:upper(), Color3.fromRGB(0, 255, 120))
                    encounterLabel.Text = "KEEPER: " .. reason
                    encounterLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
                else
                    showNotif("🏃 AUTO RUNNING...", Color3.fromRGB(100, 100, 255))
                    encounterLabel.Text = "Skipped"
                    encounterLabel.TextColor3 = Color3.fromRGB(200, 100, 100)

                    task.wait(RUN_DELAY)
                    clickRunButton()
                end

                task.delay(7, function() watchedGuis[gui] = nil end)
            end
        end
    end
end)

-- Ground Egg Collection (also made more aggressive)
local function collectEggs()
    if not isRunning then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local original = root.CFrame
    local count = 0

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if count >= MAX_PER_SWEEP then break end
        if obj:IsA("MeshPart") and obj.Name:lower():find("egg") and obj.Parent and obj.Parent.Name:lower():find("chunk") then
            count += 1
            root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3.5, 0))
            task.wait(0.08)
            root.CFrame = original
            task.wait(0.05)
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

print("🚀 Kyeggo Egg Collector [AGGRESSIVE MODE] Loaded!")
