-- === DELTA FRIENDLY IMAGE ID LOGGER ===
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create GUI for logging
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ImageIDLogger"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.5, 0, 0.6, 0)
frame.Position = UDim2.new(0.25, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
title.Text = "Image ID Logger (Copyable)"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -10, 1, -60)
textBox.Position = UDim2.new(0, 5, 0, 55)
textBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
textBox.TextColor3 = Color3.fromRGB(0, 255, 100)
textBox.TextWrapped = true
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.ClearTextOnFocus = false
textBox.MultiLine = true
textBox.Font = Enum.Font.Code
textBox.TextSize = 14
textBox.Text = "Waiting for scan...\n"
textBox.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 100, 0, 30)
closeBtn.Position = UDim2.new(1, -105, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "Close"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local function Log(text)
    textBox.Text = textBox.Text .. text .. "\n"
    textBox.CursorPosition = #textBox.Text + 1
end

Log("=== Image ID Logger Started ===")
Log("Open your GUI now...")

task.wait(2)

local count = 0
for _, obj in ipairs(playerGui:GetDescendants()) do
    if (obj:IsA("ImageButton") or obj:IsA("ImageLabel")) and obj.Image and obj.Image ~= "" then
        count += 1
        local logLine = string.format("[%d] Name: %s | Visible: %s | Image: %s", 
            count, obj.Name, obj.Visible and "YES" or "NO", obj.Image)
        
        Log(logLine)
    end
end

Log("=== Scan Finished! Total Images: " .. count .. " ===")
Log("Click inside the box and Ctrl+A → Ctrl+C to copy all")
