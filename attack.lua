-- === FIXED DELTA IMAGE ID LOGGER ===
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Better GUI parenting for executors
local gethui = gethui or function() return game:GetService("CoreGui") end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ImageIDLogger"
screenGui.ResetOnSpawn = false
screenGui.Parent = gethui()  -- This is the fix

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.55, 0, 0.65, 0)
frame.Position = UDim2.new(0.225, 0, 0.175, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
title.Text = "🖼 Image ID Logger - Delta Friendly"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -10, 1, -110)
textBox.Position = UDim2.new(0, 5, 0, 55)
textBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
textBox.TextColor3 = Color3.fromRGB(0, 255, 120)
textBox.TextWrapped = true
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.ClearTextOnFocus = false
textBox.MultiLine = true
textBox.Font = Enum.Font.Code
textBox.TextSize = 15
textBox.Text = "Scanning...\n"
textBox.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 120, 0, 35)
closeBtn.Position = UDim2.new(1, -130, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeBtn.Text = "Close Logger"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextScaled = true
closeBtn.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local function Log(msg)
    textBox.Text = textBox.Text .. msg .. "\n"
    textBox.CursorPosition = #textBox.Text
end

Log("=== Image ID Logger Started ===")
Log("Waiting 3 seconds for GUIs to load...")
task.wait(3)

local count = 0
for _, obj in ipairs(player:WaitForChild("PlayerGui"):GetDescendants()) do
    if (obj:IsA("ImageButton") or obj:IsA("ImageLabel")) and obj.Image and obj.Image ~= "" then
        count += 1
        local status = obj.Visible and "✅ Visible" or "❌ Hidden"
        local logLine = string.format("[%d] %s | %s | %s", count, obj.Name, status, obj.Image)
        Log(logLine)
    end
end

Log("=== SCAN COMPLETE ===")
Log("Total Images Found: " .. count)
Log("")
Log("👉 Click inside box → Ctrl + A → Ctrl + C to copy")

print("Logger GUI should now be visible!")
