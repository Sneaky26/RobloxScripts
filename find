-- === LOOMIAN LEGACY AUTO FIGHT SCRIPT ===
-- Made for Delta Executor

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- Executor friendly GUI
local gethui = gethui or function() return game:GetService("CoreGui") end
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LoomianAutoFight"
screenGui.ResetOnSpawn = false
screenGui.Parent = gethui()

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 180)
frame.Position = UDim2.new(0.02, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
title.Text = "Loomian Legacy Auto Fight"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -10, 0, 30)
status.Position = UDim2.new(0, 5, 0, 40)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(0, 255, 100)
status.Text = "Status: Waiting..."
status.TextScaled = true
status.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 80)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggleBtn.Text = "ENABLE AUTO FIGHT"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = frame

local enabled = false

local function ClickImage(imageId)
    for _, obj in ipairs(player:WaitForChild("PlayerGui"):GetDescendants()) do
        if (obj:IsA("ImageButton") or obj:IsA("ImageLabel")) and 
           obj.Image and obj.Image:find(imageId) and obj.Visible then
            local pos = obj.AbsolutePosition
            local size = obj.AbsoluteSize
            local x = pos.X + size.X / 2
            local y = pos.Y + size.Y / 2 + 5
            
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(0.07)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
            return true
        end
    end
    return false
end

toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        toggleBtn.Text = "DISABLE AUTO FIGHT"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        status.Text = "Status: AUTO FIGHT ENABLED"
    else
        toggleBtn.Text = "ENABLE AUTO FIGHT"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        status.Text = "Status: Stopped"
    end
end)

-- Main Auto Fight Loop
task.spawn(function()
    while task.wait(0.6) do
        if not enabled then continue end
        
        status.Text = "Status: Looking for move..."
        
        -- Try common move button Image IDs from your scan
        local clicked = false
        
        local moveIds = {
            "2180281104",   -- Best candidate
            "2622558781",
            "2573209642",
            "1961307763",
            "129641854675237",
            "131528153567248"
        }
        
        for _, id in ipairs(moveIds) do
            if ClickImage(id) then
                clicked = true
                status.Text = "Status: Clicked Move! ("..id..")"
                break
            end
        end
        
        if not clicked then
            status.Text = "Status: No move button found"
        end
    end
end)

print("Loomian Legacy Auto Fight loaded! Drag the GUI.")
