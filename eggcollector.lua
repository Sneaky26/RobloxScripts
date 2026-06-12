-- Kyeggo Ground Collector + Rare Detector (Teleport Version)
-- Uses your original working teleport method

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

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
frame.Size = UDim2.new(0, 270, 0, 220)
frame.Position = UDim2.new(0.5, -135, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
title.Text = "Kyeggo Ground Collector"
title.TextColor3 = Color3.fromRGB(255, 220, 80)
title.TextScaled = true
title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
title.Parent = frame

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

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.1, 0, 0, 130)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
toggleBtn.Text = "START"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextScaled = true
toggleBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
toggleBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleBtn

-- Rare Detection
local function isRareEgg(obj)
    local name = obj.Name:lower()
    return name:find("rainbow") or name:find("faberge") or name:find("star") or 
           name:find("pyramind") or name:find("gold") or name:find("diamond")
end

local function isSuperRareEgg(obj)
    local name = obj.Name:lower()
    return name:find("rainbow") or name:find("faberge") or name:find("star")
end

local function showRareNotification(egg, isSuper)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 340, 0, 100)
    notif.Position = UDim2.new(0.5, -170, 0.2, 0)
    notif.BackgroundColor3 = isSuper and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(180, 0, 0)
    notif.Text = (isSuper and "🔥 SUPER RARE EGG! (Gamma/Alpha Chance) 🔥" or "🎉 RARE KYEGGO EGG! 🎉") .. "\n" .. (egg.Name or "Special")
    notif.TextColor3 = Color3.fromRGB(255, 255, 100)
    notif.TextScaled = true
    notif.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    notif.Parent = screenGui
    
    local sound = Instance.new("Sound")
    sound.SoundId = isSuper and "rbxassetid://1848354536" or "rbxassetid://131057809"
    sound.Volume = 0.85
    sound.Parent = workspace
    sound:Play()
    
    task.wait(5)
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
        if itemsFound >= 8 then break end

        if (obj.Name == "Egg" or obj.Name == "Easter Egg") and obj:IsA("MeshPart") then
            local pos = obj.Position
            local dist = (root.Position - pos).Magnitude
            
            -- Only ground eggs
            if dist < 130 and pos.Y < 60 then
                itemsFound += 1
                
                -- Original teleport method you liked
                root.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
                task.wait(0.2)
                root.CFrame = originalCFrame
                task.wait(0.1)

                if obj.Name == "Egg" then
                    collectedEggs += 1
                    eggLabel.Text = "Eggs Collected: " .. collectedEggs
                    
                    if isRareEgg(obj) then
                        local isSuper = isSuperRareEgg(obj)
                        showRareNotification(obj, isSuper)
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
        task.wait(0.45)
    end
end)

print("✅ Kyeggo Collector (Teleport Version) Loaded!")
