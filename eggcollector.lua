-- Egg Name Finder (On Screen Display)
-- Works with Delta Executor on Android

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player.PlayerGui

local frame = Instance.new("ScrollingFrame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.ScrollBarThickness = 6
frame.CanvasSize = UDim2.new(0, 0, 0, 0)
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Parent = frame

local count = 0

for _, obj in game:GetService("Workspace"):GetDescendants() do
    local name = obj.Name:lower()
    if name:find("egg") or name:find("kyeg") or name:find("item") or name:find("drop") or name:find("pickup") then
        count = count + 1

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 30)
        label.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        label.BorderSizePixel = 0
        label.Text = obj.Name .. " | " .. obj.ClassName
        label.TextColor3 = Color3.fromRGB(255, 220, 80)
        label.TextScaled = true
        label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
        label.Parent = frame

        frame.CanvasSize = UDim2.new(0, 0, 0, count * 30)
    end
end

if count == 0 then
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    label.BorderSizePixel = 0
    label.Text = "Nothing found! Wait for eggs to spawn"
    label.TextColor3 = Color3.fromRGB(255, 80, 80)
    label.TextScaled = true
    label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
    label.Parent = frame
end
