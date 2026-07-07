-- === CLEAN FIXED MOBILE AUTO CLICKER ===
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer

local enabled = false
local clickX = 480
local clickY = 620

local function ClickAt(x, y)
    print("Attempting click at:", x, y)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.12)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = (gethui or function() return game:GetService("CoreGui") end)()

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 200)
frame.Position = UDim2.new(0.02, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(0,100,180)
title.Text = "Loomian Mobile Clicker"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

local xLabel = Instance.new("TextLabel")
xLabel.Size = UDim2.new(0.4,0,0,25)
xLabel.Position = UDim2.new(0.05,0,0,40)
xLabel.BackgroundTransparency = 1
xLabel.Text = "X:"
xLabel.TextColor3 = Color3.new(1,1,1)
xLabel.TextScaled = true
xLabel.Parent = frame

local xBox = Instance.new("TextBox")
xBox.Size = UDim2.new(0.5,0,0,25)
xBox.Position = UDim2.new(0.45,0,0,40)
xBox.Text = tostring(clickX)
xBox.Parent = frame

local yLabel = Instance.new("TextLabel")
yLabel.Size = UDim2.new(0.4,0,0,25)
yLabel.Position = UDim2.new(0.05,0,0,70)
yLabel.BackgroundTransparency = 1
yLabel.Text = "Y:"
yLabel.TextColor3 = Color3.new(1,1,1)
yLabel.TextScaled = true
yLabel.Parent = frame

local yBox = Instance.new("TextBox")
yBox.Size = UDim2.new(0.5,0,0,25)
yBox.Position = UDim2.new(0.45,0,0,70)
yBox.Text = tostring(clickY)
yBox.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0.9,0,0,40)
toggle.Position = UDim2.new(0.05,0,0,105)
toggle.BackgroundColor3 = Color3.fromRGB(0,160,0)
toggle.Text = "ENABLE"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.TextScaled = true
toggle.Parent = frame

local removeBtn = Instance.new("TextButton")
removeBtn.Size = UDim2.new(0.9,0,0,30)
removeBtn.Position = UDim2.new(0.05,0,0,155)
removeBtn.BackgroundColor3 = Color3.fromRGB(170,30,30)
removeBtn.Text = "Remove GUI"
removeBtn.TextColor3 = Color3.new(1,1,1)
removeBtn.TextScaled = true
removeBtn.Parent = frame

-- Update values
xBox.FocusLost:Connect(function() clickX = tonumber(xBox.Text) or clickX end)
yBox.FocusLost:Connect(function() clickY = tonumber(yBox.Text) or clickY end)

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "DISABLE" or "ENABLE"
    toggle.BackgroundColor3 = enabled and Color3.fromRGB(160,0,0) or Color3.fromRGB(0,160,0)
end)

removeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

task.spawn(function()
    while task.wait(0.8) do
        if enabled then
            ClickAt(clickX, clickY)
        end
    end
end)

print("Mobile Clicker loaded! Adjust X and Y")
print("Current:", clickX, clickY)
