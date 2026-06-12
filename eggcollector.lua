-- Kyeggo Event Auto Egg Collector
-- Latest Roblox Compatible | Works with Delta Executor

-- Services cached at top
local Players   = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Player refs
local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart  = character:WaitForChild("HumanoidRootPart")

-- State
local collected = 0
local isRunning = false

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

-- Safe position getter
local function getPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        local ok, pos = pcall(function()
            return obj:GetPivot().Position
        end)
        if ok and pos then return pos end
        if obj.PrimaryPart then
            return obj.PrimaryPart.Position
        end
    end
    return nil
end

-- Smart search pool (checks known folders first, falls back to full scan)
local function getSearchPool()
    local knownFolders = {"Eggs", "KyeggoEggs", "EventEggs", "Map", "GameFolder", "World"}
    for _, name in ipairs(knownFolders) do
        local folder = Workspace:FindFirstChild(name)
        if folder then
            local items = folder:GetDescendants()
            if #items > 0 then return items end
        end
    end
    return Workspace:GetDescendants()
end

-- Main collect function (uses firetouchinterest — no teleporting, stay in place)
local function collectEggs()
    if not isRunning then return end

    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, obj in getSearchPool() do
        if not isRunning then break end

        local name = obj.Name:lower()

        if (name:find("egg") or name:find("kyeggo")) and
           (obj:IsA("BasePart") or obj:IsA("Model")) then

            local pos = getPosition(obj)

            if pos then
                local dist = (root.Position - pos).Magnitude

                if dist < 60 then
                    -- Get the actual BasePart
                    local part = nil
                    if obj:IsA("BasePart") then
                        part = obj
                    elseif obj:IsA("Model") then
                        part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    end

                    if part then
                        -- Simulate touch without moving character
                        pcall(function()
                            firetouchinterest(root, part, 0) -- touch
                            task.wait(0.1)
                            firetouchinterest(root, part, 1) -- release
                        end)

                        task.wait(0.15)
                        collected = collected + 1
                        counterLabel.Text = "Eggs Collected: " .. collected
                    end
                end
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