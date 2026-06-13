local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local player = Players.LocalPlayer
local collected = 0
local isRunning = false
local isMinimized = false
local espEnabled = false
local autoRunEnabled = false

-- ── Settings ─────────────────────────────────────────────────────────────────
local COLLECT_INTERVAL = 0.4
local MAX_PER_SWEEP = 8
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

-- ── Main Frame ───────────────────────────────────────────────────────────────
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

-- (ESP Panel, Scan Panel, Tab Switching, Minimize - unchanged for brevity, they stay exactly the same)

-- ══════════════════════════════════════════════════════════════════════════════
-- ── IMPROVED FUNCTIONS ───────────────────────────────────────────────────────
-- ══════════════════════════════════════════════════════════════════════════════

local COMMON_KYEGGOS = {
    ["Kyeggo-rviolet"] = true, ["Kyeggo-rorange"] = true, ["Kyeggo-rred"] = true,
    ["Kyeggo-blue"] = true, ["Kyeggo-green"] = true,
    ["Kyeggo-pattern4"] = true, ["Kyeggo-pattern3"] = true,
    ["Kyeggo-pattern2"] = true, ["Kyeggo-pattern1"] = true,
    ["Kyeggo-faberge1"] = true, ["Kyeggo-faberge2"] = true, ["Kyeggo-faberge3"] = true,
    ["Kyeggo"] = true,
}

local function isKeeper(text)
    text = text:lower()
    for name in pairs(COMMON_KYEGGOS) do
        if text:find(name:lower(), 1, true) then
            return false, name
        end
    end
    if text:find("kyeggo") then
        local match = text:match("kyeggo[%w%-]*") or "Rare Variant"
        return true, match
    end
    return false, nil
end

local function isBattleGui(gui)
    if not gui or not gui:IsA("ScreenGui") or not gui.Enabled then return false end
    local hasRun, hasFight = false, false
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") then
            if obj.Text == "Run" then hasRun = true
            elseif obj.Text == "Fight" then hasFight = true
            end
        end
    end
    return hasRun and hasFight
end

local function clickRunButton(battleGui)
    local vu = game:GetService("VirtualUser")
    
    -- Priority 1: Button inside "Run" frame
    if battleGui then
        for _, obj in ipairs(battleGui:GetDescendants()) do
            if (obj:IsA("TextButton") or obj:IsA("ImageButton")) 
                and obj.Parent and obj.Parent.Name == "Run" 
                and obj.Visible then
                local center = obj.AbsolutePosition + obj.AbsoluteSize / 2
                pcall(function()
                    vu:Button1Down(center, Camera.CFrame)
                    task.wait(0.08)
                    vu:Button1Up(center, Camera.CFrame)
                end)
                return true
            end
        end
    end

    -- Priority 2: Any "Run" button
    for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
        if obj:IsA("TextButton") and obj.Text == "Run" and obj.Visible then
            local center = obj.AbsolutePosition + obj.AbsoluteSize / 2
            pcall(function()
                vu:Button1Down(center, Camera.CFrame)
                task.wait(0.08)
                vu:Button1Up(center, Camera.CFrame)
            end)
            return true
        end
    end

    -- Priority 3: Fallback click
    local vp = Camera.ViewportSize
    pcall(function()
        vu:Button1Down(Vector2.new(vp.X * 0.5, vp.Y * 0.88), Camera.CFrame)
        task.wait(0.1)
        vu:Button1Up(Vector2.new(vp.X * 0.5, vp.Y * 0.88), Camera.CFrame)
    end)
    return false
end

-- ── ESP System (unchanged) ───────────────────────────────────────────────────
-- ... [Your existing ESP code remains the same] ...

-- ── Ground Egg Collection (unchanged) ───────────────────────────────────────
-- ... [Your existing collection code remains the same] ...

-- ── Improved Auto-Run System ─────────────────────────────────────────────────
local watchedGuis = {}

task.spawn(function()
    while true do
        task.wait(0.3)
        if not autoRunEnabled then continue end

        for _, gui in ipairs(player.PlayerGui:GetChildren()) do
            if gui.Name == "EggCollectorUI" then continue end
            if watchedGuis[gui] then continue end
            if not gui:IsA("ScreenGui") or not gui.Enabled then continue end

            if isBattleGui(gui) then
                watchedGuis[gui] = true
                local fullText = ""
                for _, obj in ipairs(gui:GetDescendants()) do
                    if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Text then
                        fullText = fullText .. " " .. obj.Text
                    end
                end

                local keep, reason = isKeeper(fullText)

                if keep then
                    showNotif("⭐ KEEPER: " .. reason:upper() .. "! Stay!", Color3.fromRGB(255, 180, 0))
                    encounterLabel.Text = "Last: KEEPER (" .. reason .. ")"
                    encounterLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
                else
                    showNotif("🏃 Auto-running in 3s...", Color3.fromRGB(80, 80, 120))
                    encounterLabel.Text = "Last: Skipped (running...)"
                    encounterLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
                    
                    task.wait(3)
                    if not isKeeper(getAllText(gui)) then
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

print("✅ Kyeggo Egg Collector v2 - Improved Auto-Run Loaded!")
