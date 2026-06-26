local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Remove old GUI
if player.PlayerGui:FindFirstChild("RainbowSpyUI") then
    player.PlayerGui.RainbowSpyUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RainbowSpyUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player.PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 400, 0, 320)
Main.Position = UDim2.new(0.5, -200, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Title.Text = "Rainbow Shop Spy"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0.95, 0, 0, 40)
Status.Position = UDim2.new(0.025, 0, 0.2, 0)
Status.BackgroundTransparency = 1
Status.Text = "Spy Active - Buy 1 item from Rainbow Shop"
Status.TextColor3 = Color3.fromRGB(0, 255, 100)
Status.TextScaled = true
Status.TextWrapped = true
Status.Parent = Main

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(0.95, 0, 0, 180)
LogFrame.Position = UDim2.new(0.025, 0, 0.38, 0)
LogFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LogFrame.ScrollBarThickness = 8
LogFrame.Parent = Main

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = LogFrame

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0.95, 0, 0, 35)
ClearBtn.Position = UDim2.new(0.025, 0, 0.88, 0)
ClearBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
ClearBtn.Text = "Clear Log"
ClearBtn.TextColor3 = Color3.new(1,1,1)
ClearBtn.TextScaled = true
ClearBtn.Parent = Main

-- Spy Hook
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" then
        local name = self.Name:lower()
        local path = self:GetFullName():lower()
        
        if name:find("buy") or name:find("purchase") or name:find("shop") or 
           name:find("item") or name:find("rainbow") or path:find("rainbow") then
            
            local logText = "Remote: " .. self.Name .. "\n"
            logText = logText .. "Path: " .. self:GetFullName() .. "\n"
            logText = logText .. "Args: " .. #args .. "\n"
            
            for i, arg in ipairs(args) do
                if typeof(arg) == "table" then
                    logText = logText .. "  Arg" .. i .. " (Table)\n"
                    for k,v in pairs(arg) do
                        logText = logText .. "    " .. tostring(k) .. " = " .. tostring(v) .. "\n"
                    end
                else
                    logText = logText .. "  Arg" .. i .. ": " .. typeof(arg) .. " = " .. tostring(arg) .. "\n"
                end
            end
            
            -- Add to GUI Log
            local logLabel = Instance.new("TextLabel")
            logLabel.Size = UDim2.new(1, 0, 0, 80 + (#args * 15))
            logLabel.BackgroundTransparency = 0.7
            logLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            logLabel.Text = logText
            logLabel.TextColor3 = Color3.new(1,1,1)
            logLabel.TextScaled = false
            logLabel.TextSize = 14
            logLabel.TextWrapped = true
            logLabel.TextXAlignment = Enum.TextXAlignment.Left
            logLabel.TextYAlignment = Enum.TextYAlignment.Top
            logLabel.Parent = LogFrame
            
            LogFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
            
            Status.Text = "Caught Shop Remote! Check log below"
            task.delay(3, function()
                if Status.Text:find("Caught") then
                    Status.Text = "Spy Active - Buy another item"
                end
            end)
        end
    end
    
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

ClearBtn.MouseButton1Click:Connect(function()
    for _, child in pairs(LogFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    LogFrame.CanvasSize = UDim2.new(0,0,0,0)
end)

print("✅ Rainbow Shop Spy GUI Loaded!")
print("Go to Rainbow Shop NPC and buy 1 item")
