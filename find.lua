-- === LOOMIAN LEGACY AUTO MOVE CLICKER v2 ===
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer

local enabled = false

local function ClickMoveButton()
    for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
        if (obj:IsA("ImageButton") or obj:IsA("ImageLabel")) and obj.Visible and obj.Image then
            
            -- Target move buttons more accurately
            if obj.Name:find("Move") or 
               obj.Image:find("2562648980") or 
               obj.Image:find("2548893") then   -- move text IDs
                
                local pos = obj.AbsolutePosition
                local size = obj.AbsoluteSize
                local x = pos.X + size.X / 2
                local y = pos.Y + size.Y / 2
                
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
                task.wait(0.08)
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
                
                print("Clicked Move Button:", obj.Name or "Unknown")
                return true
            end
        end
    end
    return false
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = (gethui or function() return game.CoreGui end)()

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 140)
frame.Position = UDim2.new(0.02, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,35)
title.BackgroundColor3 = Color3.fromRGB(0,120,200)
title.Text = "Loomian Auto Move"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0.9,0,0,50)
toggle.Position = UDim2.new(0.05,0,0,45)
toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
toggle.Text = "ENABLE AUTO CLICK"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.TextScaled = true
toggle.Parent = frame

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "DISABLE AUTO CLICK" or "ENABLE AUTO CLICK"
    toggle.BackgroundColor3 = enabled and Color3.fromRGB(170,0,0) or Color3.fromRGB(0,170,0)
end)

task.spawn(function()
    while task.wait(0.7) do   -- adjust speed
        if enabled then
            ClickMoveButton()
        end
    end
end)

print("Loomian Auto Move Clicker loaded!")
