local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- ================== SETTINGS ==================
local ENABLED = false
local MODE = "Multiplier"  -- "Multiplier" or "AutoBuy"
local MULTIPLIER = 100
local AUTO_DELAY = 0.6     -- seconds between buys in Auto mode
local MAX_BUYS = 0         -- 0 = unlimited

-- Remove old GUI
if player.PlayerGui:FindFirstChild("AdvancedShopBuyer") then
    player.PlayerGui.AdvancedShopBuyer:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedShopBuyer"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player.PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 380, 0, 280)
Main.Position = UDim2.new(0.5, -190, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Title.Text = "Loomian Legacy Advanced Shop Buyer"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 50)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.22, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
ToggleBtn.Text = "ENABLED: OFF"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = Main

local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(0.9, 0, 0, 40)
ModeBtn.Position = UDim2.new(0.05, 0, 0.42, 0)
ModeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ModeBtn.Text = "Mode: Multiplier"
ModeBtn.TextColor3 = Color3.new(1,1,1)
ModeBtn.TextScaled = true
ModeBtn.Parent = Main

local MultiLabel = Instance.new("TextLabel")
MultiLabel.Size = UDim2.new(0.9, 0, 0, 30)
MultiLabel.Position = UDim2.new(0.05, 0, 0.58, 0)
MultiLabel.BackgroundTransparency = 1
MultiLabel.Text = "Multiplier: 100x"
MultiLabel.TextColor3 = Color3.new(1,1,1)
MultiLabel.TextScaled = true
MultiLabel.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0.9, 0, 0, 60)
Status.Position = UDim2.new(0.05, 0, 0.72, 0)
Status.BackgroundTransparency = 1
Status.Text = "Ready - Toggle ON"
Status.TextColor3 = Color3.fromRGB(255, 200, 100)
Status.TextScaled = true
Status.TextWrapped = true
Status.Parent = Main

-- Hook
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

local buyCount = 0

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not ENABLED then return oldNamecall(self, ...) end
    
    local name = self.Name:lower()
    if method == "FireServer" and (name:find("buy") or name:find("purchase") or name:find("shop") or name:find("item")) then
        
        -- Multiplier Mode
        if MODE == "Multiplier" then
            for i = 1, #args do
                if typeof(args[i]) == "number" and args[i] >= 1 and args[i] <= 20 then
                    local old = args[i]
                    args[i] = MULTIPLIER
                    buyCount += 1
                    Status.Text = string.format("Multiplied %d → %d | Total: %d", old, MULTIPLIER, buyCount)
                    break
                end
            end
        end
    end
    
    return oldNamecall(self, unpack(args))
end)

setreadonly(mt, true)

-- Auto Buy Loop
local autoLoop
local function startAutoBuy()
    if autoLoop then return end
    autoLoop = task.spawn(function()
        while ENABLED and MODE == "AutoBuy" do
            -- Try to find and fire common shop remotes
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") and (remote.Name:lower():find("buy") or remote.Name:lower():find("purchase")) then
                    pcall(function()
                        remote:FireServer("ItemNameHere", 1) -- This may need adjustment
                    end)
                    buyCount += 1
                    Status.Text = "Auto Buying... Total: " .. buyCount
                end
            end
            task.wait(AUTO_DELAY)
            if MAX_BUYS > 0 and buyCount >= MAX_BUYS then break end
        end
    end)
end

-- Buttons
ToggleBtn.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    ToggleBtn.Text = "ENABLED: " .. (ENABLED and "ON" or "OFF")
    ToggleBtn.BackgroundColor3 = ENABLED and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    
    if ENABLED and MODE == "AutoBuy" then
        startAutoBuy()
    end
end)

ModeBtn.MouseButton1Click:Connect(function()
    if MODE == "Multiplier" then
        MODE = "AutoBuy"
        ModeBtn.Text = "Mode: Auto Buy"
    else
        MODE = "Multiplier"
        ModeBtn.Text = "Mode: Multiplier"
    end
end)

print("✅ Advanced Loomian Shop Buyer loaded (Delta Executor)")
print("Use Multiplier mode first - it's more reliable")
