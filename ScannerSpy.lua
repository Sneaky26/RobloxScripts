local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Remove old GUI
if player.PlayerGui:FindFirstChild("FullSpyUI") then
    player.PlayerGui.FullSpyUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FullSpyUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player.PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 420, 0, 380)
Main.Position = UDim2.new(0.5, -210, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Title.Text = "FULL Remote Spy (Rainbow Shop)"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0.95, 0, 0, 40)
Status.Position = UDim2.new(0.025, 0, 0.16, 0)
Status.BackgroundTransparency = 1
Status.Text = "Spy ACTIVE - Buy 1 Disc from Rainbow NPC"
Status.TextColor3 = Color3.fromRGB(0, 255, 100)
Status.TextScaled = true
Status.Parent = Main

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(0.95, 0, 0, 220)
LogFrame.Position = UDim2.new(0.025, 0, 0.3, 0)
LogFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LogFrame.ScrollBarThickness = 10
LogFrame.Parent = Main

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 3)
UIList.Parent = LogFrame

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0.95, 0, 0, 40)
ClearBtn.Position = UDim2.new(0.025, 0, 0.88, 0)
ClearBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
ClearBtn.Text = "CLEAR LOG"
ClearBtn.TextColor3 = Color3.new(1,1,1)
ClearBtn.TextScaled = true
ClearBtn.Parent = Main

-- ================== FULL SPY HOOK ==================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" or method == "InvokeServer" then
        local logText = string.format("[%s] %s\n", method, self.Name)
        logText = logText .. "Path: " .. self:GetFullName() .. "\n"
        
        for i, arg in ipairs(args) do
            if typeof(arg) == "table" then
                logText = logText .. "Arg" .. i .. " (Table):\n"
                for k, v in pairs(arg) do
                    logText = logText .. "   " .. tostring(k) .. " = " .. tostring(v) .. "\n"
                end
            else
                logText = logText .. "Arg" .. i .. ": " .. typeof(arg) .. " = " .. tostring(arg) .. "\n"
            end
        end
        
        -- Add to GUI
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 90 + (#args * 18))
        label.BackgroundTransparency = 0.8
        label.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        label.Text = logText
        label.TextColor3 = Color3.new(1,1,1)
        label.TextSize = 13
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Code
        label.Parent = LogFrame
        
        LogFrame.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
        
        Status.Text = "Logged Remote! Check below"
        task.delay(2, function()
            if Status.Text:find("Logged") then
                Status.Text = "Spy Active - Buy another item"
            end
        end)
    end
    
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

ClearBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(LogFrame:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
    LogFrame.CanvasSize = UDim2.new(0,0,0,0)
end)

print("✅ FULL Spy GUI Loaded - Buy a disc from Rainbow Shop now!")
