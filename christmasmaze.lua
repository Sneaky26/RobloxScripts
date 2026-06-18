-- ❄️ Christmas / Winter Maze Mobile Script for Delta Executor
-- Noclip + Fly + ESP + Auto Collect

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local isRunning = false
local noclipEnabled = true
local flyEnabled = false
local autoCollect = true
local espEnabled = false
local autoRejoin = true

local flySpeed = 50
local bodyVelocity, bodyGyro = nil, nil

-- Remove old UI
if player.PlayerGui:FindFirstChild("WinterMazeMobileUI") then
    player.PlayerGui.WinterMazeMobileUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WinterMazeMobileUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 400)
frame.Position = UDim2.new(0, 10, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(0, 110, 200)
title.Text = "❄️ Christmas Maze Mobile"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

local y = 60
local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Parent = frame
    btn.MouseButton1Click:Connect(callback)
    y += 52
    return btn
end

createButton("Main Script: OFF", function(self)
    isRunning = not isRunning
    self.Text = "Main Script: " .. (isRunning and "ON" or "OFF")
end)

createButton("Noclip: ON", function(self)
    noclipEnabled = not noclipEnabled
    self.Text = "Noclip: " .. (noclipEnabled and "ON" or "OFF")
end)

local flyBtn = createButton("Fly: OFF", function(self)
    flyEnabled = not flyEnabled
    self.Text = "Fly: " .. (flyEnabled and "ON" or "OFF")
    if flyEnabled then startFly() else stopFly() end
end)

createButton("Auto Collect: ON", function(self)
    autoCollect = not autoCollect
    self.Text = "Auto Collect: " .. (autoCollect and "ON" or "OFF")
end)

createButton("ESP: OFF", function(self)
    espEnabled = not espEnabled
    self.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
end)

createButton("Auto Rejoin: ON", function(self)
    autoRejoin = not autoRejoin
    self.Text = "Auto Rejoin: " .. (autoRejoin and "ON" or "OFF")
end)

createButton("Fly Speed +10", function() flySpeed = math.min(120, flySpeed + 10); print("Fly Speed: " .. flySpeed) end)
createButton("Fly Speed -10", function() flySpeed = math.max(30, flySpeed - 10); print("Fly Speed: " .. flySpeed) end)

-- Noclip
RunService.Stepped:Connect(function()
    if not noclipEnabled then return end
    local char = player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

function startFly()
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then humanoid.PlatformStand = true end
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
    bodyVelocity.Parent = root
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
    bodyGyro.P = 12500
    bodyGyro.Parent = root
end

function stopFly()
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then humanoid.PlatformStand = false end
end

-- Fly Movement
RunService.Heartbeat:Connect(function()
    if not flyEnabled or not bodyVelocity then return end
    local cam = Workspace.CurrentCamera
    local moveDir = cam.CFrame.LookVector * 0.8
    bodyVelocity.Velocity = moveDir * flySpeed
end)

-- Auto Collect
task.spawn(function()
    while true do
        if autoCollect then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                local n = obj.Name:lower()
                if n:find("peppermint") or n:find("key") or n:find("yule") or n:find("log") or n:find("mask") or n:find("crate") or n:find("gift") then
                    local pos = obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
                    if pos and (pos - root.Position).Magnitude < 90 then
                        root.CFrame = CFrame.new(root.Position, pos) * CFrame.new(0,0,-5)
                        task.wait(0.2)
                    end
                end
            end
        end
        task.wait(0.8)
    end
end)

print("❄️ Christmas Maze Mobile Script Loaded for Delta Executor!")
print("Noclip is ON by default. Use the buttons.")

player.CharacterAdded:Connect(function(new)
    character = new
    root = new:WaitForChild("HumanoidRootPart")
end)