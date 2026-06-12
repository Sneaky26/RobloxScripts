-- Kyeggo Event Auto Egg Collector (Improved 2026 v2)
-- Works with Delta Executor on Android

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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
frame.Size = UDim2.new(0, 260, 0, 220)
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
title.Text = "Kyeggo Egg Collector v2"
title.TextColor3 = Color3.fromRGB(255, 220, 80)
title.TextScaled = true
title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
closeBtn.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

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

-- Debug Tab Button
local debugBtn = Instance.new("TextButton")
debugBtn.Size = UDim2.new(0.8, 0, 0, 30)
debugBtn.Position = UDim2.new(0.1, 0, 0, 140)
debugBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
debugBtn.Text = "Debug - Find Egg Names"
debugBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
debugBtn.TextScaled = true
debugBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
debugBtn.Parent = frame

local debugCorner = Instance.new("UICorner")
debugCorner.CornerRadius = UDim.new(0, 8)
debugCorner.Parent = debugBtn

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

-- ==================== DEBUG FUNCTION ====================
local function debugEggs()
    print("🔍 === KYEGGO EGG DEBUG START ===")
    local char = player.Character
    if not char then print("No character") return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then print("No HRP") return end

    local found = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("MeshPart") or obj:IsA("Part") then
            local dist = (root.Position - obj.Position).Magnitude
            if dist < 150 then
                if obj.Name:lower():find("egg") or (obj.Parent and obj.Parent.Name:lower():find("egg")) then
                    found += 1
                    print(string.format("[%d] Name: %s | Class: %s | Parent: %s | Distance: %.1f", 
                        found, obj.Name, obj.ClassName, obj.Parent.Name, dist))
                    
                    -- Print hierarchy
                    local hierarchy = obj:GetFullName()
                    print("   Full Path: " .. hierarchy)
                end
            end
        end
    end
    print("🔍 === Found " .. found .. " potential egg objects ===\n")
end

debugBtn.MouseButton1Click:Connect(debugEggs)

-- ==================== IMPROVED COLLECTION ====================
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
        if eggsFound >= 6 then break end  -- Lowered for better performance

        -- Better egg detection
        local isEgg = false
        if obj.Name == "Egg" or obj.Name:find("Egg") then
            isEgg = true
        elseif obj.Parent and (obj.Parent.Name == "Egg" or obj.Parent.Name:find("Egg")) then
            isEgg = true
        elseif obj:FindFirstAncestorWhichIsA("Model") then
            local model = obj:FindFirstAncestorWhichIsA("Model")
            if model.Name:lower():find("egg") then
                isEgg = true
            end
        end

        if isEgg and (obj:IsA("MeshPart") or obj:IsA("Part")) then
            local dist = (root.Position - obj.Position).Magnitude
            if dist < 130 then
                eggsFound += 1
                
                -- Teleport to the actual collectible part
                local targetPos = obj.Position + Vector3.new(0, 3.5, 0)
                
                root.CFrame = CFrame.new(targetPos)
                task.wait(0.12)
                
                -- Optional: small random offset to avoid detection
                root.CFrame = CFrame.new(targetPos + Vector3.new(math.random(-2,2), 0, math.random(-2,2)))
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
        task.wait(0.35)
    end
end)

print("✅ Kyeggo Egg Collector v2 Loaded! Use Debug button to find correct egg parts.")
