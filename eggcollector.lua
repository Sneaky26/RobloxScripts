-- Kyeggo Event Auto Egg Collector (UPDATED WITH REAL EGG NAME)
-- Works with Delta Executor on Android

local Players   = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player    = Players.LocalPlayer

local collected = 0
local isRunning = false

-- Remove old UI if exists
local old = player.PlayerGui:FindFirstChild("EggCollectorUI")
if old then old:Destroy() end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "EggCollectorUI"
screenGui.ResetOnSpawn   = false
screenGui.IgnoreGuiInset = true
screenGui.Parent         = player.PlayerGui

-- Main Frame
local frame = Instance.new("Frame")
frame.Size             = UDim2.new(0, 220, 0, 130)
frame.Position         = UDim2.new(0.5, -110, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel  = 0
frame.Active           = true
frame.Draggable        = true
frame.Parent           = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size             = UDim2.new(1, 0, 0, 35)
title.Position         = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
title.BorderSizePixel  = 0
title.Text             = "Kyeggo Egg Collector"
title.TextColor3       = Color3.fromRGB(255, 220, 80)
title.TextScaled       = true
title.FontFace         = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
title.Parent           = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Counter Label
local counterLabel = Instance.new("TextLabel")
counterLabel.Size                   = UDim2.new(1, 0, 0, 25)
counterLabel.Position               = UDim2.new(0, 0, 0, 43)
counterLabel.BackgroundTransparency = 1
counterLabel.Text                   = "Eggs Collected: 0"
counterLabel.TextColor3             = Color3.fromRGB(200, 200, 200)
counterLabel.TextScaled             = true
counterLabel.FontFace               = Font.new("rbxasset://fonts/families/GothamSSm.json")
counterLabel.Parent                 = frame

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size                   = UDim2.new(1, 0, 0, 20)
statusLabel.Position               = UDim2.new(0, 0, 0, 68)
statusLabel.BackgroundTransparency = 1
statusLabel.Text                   = "Status: OFF"
statusLabel.TextColor3             = Color3.fromRGB(255, 80, 80)
statusLabel.TextScaled             = true
statusLabel.FontFace               = Font.new("rbxasset://fonts/families/GothamSSm.json")
statusLabel.Parent                 = frame

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size             = UDim2.new(0.7, 0, 0, 30)
toggleBtn.Position         = UDim2.new(0.15, 0, 0, 92)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
toggleBtn.BorderSizePixel  = 0
toggleBtn.Text             = "START"
toggleBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
toggleBtn.TextScaled       = true
toggleBtn.FontFace         = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
toggleBtn.Parent           = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleBtn

-- Toggle Logic
toggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        toggleBtn.Text             = "STOP"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        statusLabel.Text           = "Status: ON"
        statusLabel.TextColor3     = Color3.fromRGB(80, 255, 80)
    else
        toggleBtn.Text             = "START"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        statusLabel.Text           = "Status: OFF"
        statusLabel.TextColor3     = Color3.fromRGB(255, 80, 80)
    end
end)

-- Main collect function
-- UPDATED: targets "Egg" MeshParts only, skips ParticleEmitters
local function collectEggs()
    if not isRunning then return end

    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Save original position
    local originalCFrame = root.CFrame

    for _, obj in Workspace:GetDescendants() do
        if not isRunning then break end

        if obj.Name == "Egg" and obj:IsA("MeshPart") then
            local dist = (root.Position - obj.Position).Magnitude

            if dist < 100 then
                -- Teleport to egg
                root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                task.wait(0.2)

                -- Return to original position
                root.CFrame = originalCFrame
                task.wait(0.1)

                collected = collected + 1
                counterLabel.Text = "Eggs Collected: " .. collected
            end
        end
    end
end

-- Run on separate thread so UI stays responsive
task.spawn(function()
    while true do
        pcall(collectEggs)
        task.wait(0.5)
    end
end)
