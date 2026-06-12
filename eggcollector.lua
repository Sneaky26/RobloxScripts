-- Kyeggo Event Auto Egg + Currency Collector + Rare Notifier
-- Improved for 2026 Rainbow Dreggodyne Event

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local collectedEggs = 0
local collectedCurrency = 0
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

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 210)
frame.Position = UDim2.new(0.5, -130, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
title.Text = "Kyeggo Egg Collector"
title.TextColor3 = Color3.fromRGB(255, 220, 80)
title.TextScaled = true
title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
title.Parent = frame

-- Counters
local eggLabel = Instance.new("TextLabel")
eggLabel.Size = UDim2.new(1, 0, 0, 25)
eggLabel.Position = UDim2.new(0, 0, 0, 40)
eggLabel.BackgroundTransparency = 1
eggLabel.Text = "Eggs Collected: 0"
eggLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
eggLabel.TextScaled = true
eggLabel.Parent = frame

local currencyLabel = Instance.new("TextLabel")
currencyLabel.Size = UDim2.new(1, 0, 0, 25)
currencyLabel.Position = UDim2.new(0, 0, 0, 68)
currencyLabel.BackgroundTransparency = 1
currencyLabel.Text = "Easter Eggs: 0"
currencyLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
currencyLabel.TextScaled = true
currencyLabel.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 96)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: OFF"
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextScaled = true
statusLabel.Parent = frame

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.1, 0, 0, 125)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
toggleBtn.Text = "START"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextScaled = true
toggleBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
toggleBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleBtn

-- Rare Notification Function
local function showRareNotification(egg)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 300, 0, 80)
    notif.Position = UDim2.new(0.5, -150, 0.3, 0)
    notif.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    notif.Text = "🎉 RARE KYEGGO FOUND! 🎉\n" .. egg.Name
    notif.TextColor3 = Color3.fromRGB(255, 255, 100)
    notif.TextScaled = true
    notif.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    notif.Parent = screenGui
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://131057809" -- Nice alert sound
    sound.Volume = 0.7
    sound.Parent = workspace
    sound:Play()
    
    task.wait(4)
    notif:Destroy()
    sound:Destroy()
end

-- Toggle
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

local function isRareKyeggo(egg)
    local name = egg.Name:lower()
    -- Add more patterns if needed
    if name:find("rainbow") or name:find("faberge") or name:find("colored") or 
       name:find("gold") or name:find("red") or name:find("blue") or 
       name:find("green") or name:find("purple") then
        return true
    end
    return false
end

local function collectItems()
    if not isRunning then return end
    
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local originalCFrame = root.CFrame
    local itemsFound = 0

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not isRunning then break end
        if itemsFound >= 10 then break end

        local isEgg = obj.Name == "Egg" and obj:IsA("MeshPart")
        local isCurrency = obj.Name == "Easter Egg" or (obj:IsA("Part") and obj.Name:find("Egg"))

        if isEgg or isCurrency then
            local dist = (root.Position - obj.Position).Magnitude
            if dist < 130 then
                itemsFound += 1
                
                root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 4, 0))
                task.wait(0.15)
                root.CFrame = originalCFrame
                task.wait(0.08)

                if isEgg then
                    collectedEggs += 1
                    eggLabel.Text = "Eggs Collected: " .. collectedEggs
                    
                    -- Check if rare
                    if isRareKyeggo(obj) then
                        showRareNotification(obj)
                    end
                else
                    collectedCurrency += 1
                    currencyLabel.Text = "Easter Eggs: " .. collectedCurrency
                end
            end
        end
    end
end

-- Main Loop
task.spawn(function()
    while true do
        pcall(collectItems)
        task.wait(0.35)
    end
end)

print("✅ Kyeggo Collector + Currency + Rare Notifier Loaded!")
