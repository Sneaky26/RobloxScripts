-- === CLICK ACTUAL IMAGE BUTTON (Move1-4) ===
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer

local enabled = false

local function ClickMoveButton()
    for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
        if (obj.Name == "Move1" or obj.Name == "Move2" or obj.Name == "Move3" or obj.Name == "Move4") and obj.Visible then
            local pos = obj.AbsolutePosition
            local size = obj.AbsoluteSize
            
            local x = pos.X + size.X / 2
            local y = pos.Y + size.Y / 2 + 12   -- tweak this number if needed
            
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(0.1)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
            
            print("Clicked button:", obj.Name)
            return true
        end
    end
    return false
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = (gethui or function() return game:GetService("CoreGui") end)()

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 140)
frame.Position = UDim2.new(0.02, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(0,110,190)
title.Text = "Image Button Clicker"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0.9,0,0,40)
toggle.Position = UDim2.new(0.05,0,0,35)
toggle.BackgroundColor3 = Color3.fromRGB(0,160,0)
toggle.Text = "ENABLE"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.TextScaled = true
toggle.Parent = frame

local removeBtn = Instance.new("TextButton")
removeBtn.Size = UDim2.new(0.9,0,0,30)
removeBtn.Position = UDim2.new(0.05,0,0,80)
removeBtn.BackgroundColor3 = Color3.fromRGB(170,30,30)
removeBtn.Text = "Remove GUI"
removeBtn.TextColor3 = Color3.new(1,1,1)
removeBtn.TextScaled = true
removeBtn.Parent = frame

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "DISABLE" or "ENABLE"
    toggle.BackgroundColor3 = enabled and Color3.fromRGB(160,0,0) or Color3.fromRGB(0,160,0)
end)

removeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

task.spawn(function()
    while task.wait(0.75) do
        if enabled then
            ClickMoveButton()
        end
    end
end)

print("Image Button Clicker loaded!")
