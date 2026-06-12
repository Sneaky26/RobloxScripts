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
frame.Size = UDim2.new(0, 240, 0, 180)
frame.Position = UDim2.new(0.5, -120, 0, 20)
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

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Counter
local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(1, 0, 0, 25)
counterLabel.Position = UDim2.new(0, 0, 0, 40)
counterLabel.BackgroundTransparency = 1
counterLabel.Text = "Eggs Collected: 0"
counterLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
counterLabel.TextScaled = true
counterLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
counterLabel.Parent = frame

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 68)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: OFF"
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextScaled = true
statusLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
statusLabel.Parent = frame

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.1, 0, 0, 95)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
toggleBtn.Text = "START"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextScaled = true
toggleBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
toggleBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleBtn

-- Toggle Logic
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

-- Main Collection Function
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
        if eggsFound >= 8 then break end  -- Limit per cycle for performance

        if obj.Name == "Egg" and obj:IsA("MeshPart") or 
           (obj.Name:find("Egg") and obj:IsA("MeshPart")) then
            
            local dist = (root.Position - obj.Position).Magnitude
            if dist < 120 then  -- Adjustable range
                eggsFound += 1
                
                -- Teleport + small wait (safe method)
                root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 4, 0))
                task.wait(0.15)
                
                -- Return to original position
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
        task.wait(0.4)  -- Balanced speed
    end
end)

print("✅ Kyeggo Egg Collector Loaded!")
