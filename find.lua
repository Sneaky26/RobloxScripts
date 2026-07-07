-- === LOOMIAN LEGACY AUTO CLICKER WITH REMOVE GUI ===
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer

local enabled = false
local screenGui

local function ClickMoveButton()
    for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
        if (obj:IsA("ImageButton") or obj:IsA("ImageLabel")) and obj.Visible and obj.Image then
            -- Target move buttons
            if obj.Name:find("Move") or 
               obj.Image:find("2562648980") or 
               obj.Image:find("2548893") then
                
                local pos = obj.AbsolutePosition
                local size = obj.AbsoluteSize
                local x = pos.X + size.X / 2
                local y = pos.Y + size.Y / 2
                
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
                task.wait(0.07)
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
                return true
            end
        end
    end
    return false
end

-- Create GUI
screenGui = Instance.new("ScreenGui")
screenGui.Name = "LoomianAutoClicker"
screenGui.ResetOnSpawn = false
screenGui.Parent = (gethui or function() return game:GetService("CoreGui") end)()

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 160)
frame.Position = UDim2.new(0.02, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,35)
title.BackgroundColor3 = Color3.fromRGB(0,120,200)
title.Text = "Loomian Auto Clicker"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0.9,0,0,45)
toggle.Position = UDim2.new(0.05,0,0,45)
toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
toggle.Text = "ENABLE AUTO CLICK"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.TextScaled = true
toggle.Parent = frame

local removeBtn = Instance.new("TextButton")
removeBtn.Size = UDim2.new(0.9,0,0,35)
removeBtn.Position = UDim2.new(0.05,0,0,100)
removeBtn.BackgroundColor3 = Color3.fromRGB(170,40,40)
removeBtn.Text = "REMOVE GUI"
removeBtn.TextColor3 = Color3.new(1,1,1)
removeBtn.TextScaled = true
removeBtn.Parent = frame

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "DISABLE AUTO CLICK" or "ENABLE AUTO CLICK"
    toggle.BackgroundColor3 = enabled and Color3.fromRGB(170,0,0) or Color3.fromRGB(0,170,0)
end)

removeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    print("Auto Clicker GUI Removed!")
end)

-- Auto Click Loop
task.spawn(function()
    while task.wait(0.65) do
        if enabled then
            ClickMoveButton()
        end
    end
end)

print("Loomian Auto Clicker loaded! Use Remove GUI anytime.")
