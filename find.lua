-- === LOOMIAN LEGACY MOBILE AUTO CLICKER - FIXED TARGETING ===
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer

local enabled = false

local function ClickAt(x, y)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.08)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function ClickMoveButton()
    for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
        if (obj:IsA("ImageButton") or obj:IsA("ImageLabel")) and obj.Visible then
            
            -- Stronger filter for actual move buttons
            if (obj.Name:find("Move") or obj.Name == "1" or obj.Name == "2" or obj.Name == "3" or obj.Name == "4") 
               and obj.Image:find("2562648980") then
                
                local pos = obj.AbsolutePosition
                local size = obj.AbsoluteSize
                
                local x = pos.X + size.X / 2
                local y = pos.Y + size.Y / 2 + 8   -- mobile offset
                
                ClickAt(x, y)
                print("Clicked Move:", obj.Name)
                return true
            end
        end
    end
    return false
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = (gethui or function() return game:GetService("CoreGui") end)()

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.5, 0, 0, 140)
frame.Position = UDim2.new(0.25, 0, 0.55, 0)
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
toggle.Size = UDim2.new(0.9,0,0,45)
toggle.Position = UDim2.new(0.05,0,0,40)
toggle.BackgroundColor3 = Color3.fromRGB(0,160,0)
toggle.Text = "ENABLE AUTO"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.TextScaled = true
toggle.Parent = frame

local removeBtn = Instance.new("TextButton")
removeBtn.Size = UDim2.new(0.9,0,0,30)
removeBtn.Position = UDim2.new(0.05,0,0,95)
removeBtn.BackgroundColor3 = Color3.fromRGB(170,30,30)
removeBtn.Text = "REMOVE GUI"
removeBtn.TextColor3 = Color3.new(1,1,1)
removeBtn.TextScaled = true
removeBtn.Parent = frame

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "DISABLE AUTO" or "ENABLE AUTO"
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

print("Fixed Mobile Auto Clicker loaded!")
