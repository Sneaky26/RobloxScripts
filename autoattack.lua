local VirtualInputManager = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer

local enabled = false
local selectedMove = 1

-- TIP: Adjust these coordinates based on your MuMu Player window size/aspect ratio!
local coords = {
    Fight = {700, 480},
    Move1 = {480, 450},
    Move2 = {480, 520},
    Move3 = {900, 450},
    Move4 = {900, 520}
}

-- Mobile Touch Input Simulation for Delta Emulator
local function ClickAt(x, y)
    -- State 0 = Touch down / Press
    VirtualInputManager:SendTouchEvent(0, 0, x, y)
    task.wait(0.05)
    -- State 2 = Touch up / Release
    VirtualInputManager:SendTouchEvent(0, 2, x, y)
end

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = (gethui or function() return game:GetService("CoreGui") end)()

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 320)
frame.Position = UDim2.new(0.02, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
frame.Parent = screenGui

-- CUSTOM DRAGGING LOGIC FOR MOBILE / EMULATORS
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- UI Elements
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,35)
title.BackgroundColor3 = Color3.fromRGB(0,120,200)
title.Text = "Loomian Auto Battle"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,0,0,25)
status.Position = UDim2.new(0,0,0,40)
status.BackgroundTransparency = 1
status.Text = "Status: Stopped"
status.TextColor3 = Color3.fromRGB(255, 200, 0)
status.TextScaled = true
status.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0.9,0,0,40)
toggle.Position = UDim2.new(0.05,0,0,70)
toggle.BackgroundColor3 = Color3.fromRGB(0,160,0)
toggle.Text = "ENABLE AUTO BATTLE"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.TextScaled = true
toggle.Parent = frame

-- Chronological Move Buttons (Fixed alignment math)
for i = 1,4 do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.45,0,0,35)
    btn.Position = UDim2.new(0.05 + (((i-1)%2)*0.5),0,0,120 + math.floor((i-1)/2)*40)
    btn.BackgroundColor3 = (i == selectedMove) and Color3.fromRGB(0,180,0) or Color3.fromRGB(60,60,70)
    btn.Text = "Move " .. i
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        selectedMove = i
        for _, b in ipairs(frame:GetChildren()) do
            if b:IsA("TextButton") and b.Text:find("Move") then
                b.BackgroundColor3 = (tonumber(b.Text:match("%d+")) == i) and Color3.fromRGB(0,180,0) or Color3.fromRGB(60,60,70)
            end
        end
    end)
end

local removeBtn = Instance.new("TextButton")
removeBtn.Size = UDim2.new(0.9,0,0,35)
removeBtn.Position = UDim2.new(0.05,0,0,260)
removeBtn.BackgroundColor3 = Color3.fromRGB(170,30,30)
removeBtn.Text = "Remove GUI"
removeBtn.TextColor3 = Color3.new(1,1,1)
removeBtn.TextScaled = true
removeBtn.Parent = frame

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "DISABLE AUTO BATTLE" or "ENABLE AUTO BATTLE"
    toggle.BackgroundColor3 = enabled and Color3.fromRGB(160,0,0) or Color3.fromRGB(0,160,0)
end)

removeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Main Automation Loop
task.spawn(function()
    while task.wait(0.8) do
        if not enabled then 
            status.Text = "Status: Stopped"
            continue 
        end
        
        status.Text = "Status: Looking for battle..."
        
        -- Click Fight
        ClickAt(coords.Fight[1], coords.Fight[2])
        status.Text = "Status: Clicked Fight"
        task.wait(0.6) -- Give the UI menu a split second to transition open
        
        -- Click Selected Move
        local moveCoord = coords["Move" .. selectedMove]
        ClickAt(moveCoord[1], moveCoord[2])
        status.Text = "Status: Clicked Move " .. selectedMove
    end
end)

print("Loomian Auto Battle loaded! Dragging fixed for MuMu/Delta.")
