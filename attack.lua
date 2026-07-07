-- === DELTA EXECUTOR - IMAGE ID LOGGER (PlayerSide) ===
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Executor friendly GUI parent
local CoreGui = game:GetService("CoreGui")
local gethui = gethui or function() return CoreGui end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ImageLogger"
screenGui.ResetOnSpawn = false
screenGui.Parent = gethui()

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.6, 0, 0.7, 0)
frame.Position = UDim2.new(0.2, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(0, 80, 180)
title.Text = "📸 Image ID Logger (PlayerSide)"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -10, 1, -90)
textBox.Position = UDim2.new(0, 5, 0, 45)
textBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
textBox.TextColor3 = Color3.fromRGB(0, 240, 100)
textBox.TextWrapped = true
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.ClearTextOnFocus = false
textBox.MultiLine = true
textBox.Font = Enum.Font.Code
textBox.TextSize = 14
textBox.Text = "Starting scan...\n"
textBox.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 100, 0, 30)
closeBtn.Position = UDim2.new(1, -110, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(170, 30, 30)
closeBtn.Text = "Close"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local function Log(msg)
    textBox.Text = textBox.Text .. msg .. "\n"
    textBox.CursorPosition = #textBox.Text + 1
end

Log("=== Image ID Logger Started (PlayerSide) ===")
Log("Waiting for GUIs to load...")
task.wait(2.5)

local count = 0
local playerGui = player:WaitForChild("PlayerGui")

for _, obj in ipairs(playerGui:GetDescendants()) do
    if (obj:IsA("ImageButton") or obj:IsA("ImageLabel")) and obj.Image and obj.Image ~= "" then
        count += 1
        local visible = obj.Visible and "✅ Visible" or "❌ Hidden"
        Log(string.format("[%d] %s | %s | %s", count, obj.Name, visible, obj.Image))
    end
end

Log("=== SCAN COMPLETE ===")
Log("Total Images Found: " .. count)
Log("")
Log("✅ Drag the window if needed")
Log("👉 Click in box → Ctrl+A → Ctrl+C to copy all text")

print("Logger GUI created! Check your screen.")
