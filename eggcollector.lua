-- Egg Name Finder (On Screen Display)
-- Works with Delta Executor on Android

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Remove old gui if exists
local old = player.PlayerGui:FindFirstChild("EggFinderUI")
if old then old:Destroy() end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggFinderUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player.PlayerGui

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 300, 0, 35)
titleLabel.Position = UDim2.new(0, 10, 0, 10)
titleLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "Egg Name Finder"
titleLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
titleLabel.TextScaled = true
titleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
titleLabel.Parent = screenGui

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleLabel

-- Scrolling Frame
local frame = Instance.new("ScrollingFrame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.ScrollBarThickness = 6
frame.CanvasSize = UDim2.new(0, 0, 0, 0)
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 2)
layout.Parent = frame

-- Scan workspace
local count = 0

for _, obj in Workspace:GetDescendants() do
    local name = obj.Name:lower()
    if name:find("egg") or name:find("kyeg") or name:find("item") 
    or name:find("drop") or name:find("pickup") or name:find("collect") then
        count = count + 1

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 32)
        label.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        label.BorderSizePixel = 0
        label.Text = obj.Name .. " | " .. obj.ClassName
        label.TextColor3 = Color3.fromRGB(255, 220, 80)
        label.TextScaled = true
        label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
        label.Parent = frame

        local labelCorner = Instance.new("UICorner")
        labelCorner.CornerRadius = UDim.new(0, 4)
        labelCorner.Parent = label

        frame.CanvasSize = UDim2.new(0, 0, 0, count * 34)
    end
end

-- Nothing found message
if count == 0 then
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 32)
    label.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    label.BorderSizePixel = 0
    label.Text = "Nothing found! Wait for eggs to spawn"
    label.TextColor3 = Color3.fromRGB(255, 80, 80)
    label.TextScaled = true
    label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
    label.Parent = frame

    frame.CanvasSize = UDim2.new(0, 0, 0, 32)
end

-- Counter label at bottom
local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(0, 300, 0, 25)
countLabel.Position = UDim2.new(0, 10, 0, 455)
countLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
countLabel.BorderSizePixel = 0
countLabel.Text = "Found: " .. count .. " objects"
countLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
countLabel.TextScaled = true
countLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
countLabel.Parent = screenGui

local countCorner = Instance.new("UICorner")
countCorner.CornerRadius = UDim.new(0, 8)
countCorner.Parent = countLabel
