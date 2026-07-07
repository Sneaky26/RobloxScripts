--======================================================================
-- 1. CONFIGURATION & MODULE STATE
--======================================================================
local Config = {
    Delays = {
        LoopInterval  = 0.5,  -- How often the loop checks status
        ClickHold     = 0.05, -- Mouse button down duration
        MenuTransition = 0.5, -- Wait time after clicking "Fight"
        TurnAnimation  = 1.5  -- Wait time for battle animations
    },
    Coordinates = {
        Fight = {700, 480},
        Move1 = {480, 450},
        Move2 = {480, 520},
        Move3 = {900, 450},
        Move4 = {900, 520}
    },
    UI = {
        Size = UDim2.new(0, 280, 0, 320),
        Position = UDim2.new(0.02, 0, 0.2, 0),
        BgColor = Color3.fromRGB(20, 20, 25),
        ThemeColor = Color3.fromRGB(0, 120, 200),
        SuccessColor = Color3.fromRGB(0, 160, 0),
        AlertColor = Color3.fromRGB(170, 30, 30),
        NeutralColor = Color3.fromRGB(60, 60, 70)
    }
}

local State = {
    Enabled = false,
    SelectedMove = 1,
    IsRunning = true
}

--======================================================================
-- 2. CORE ACTIONS MODULE
--======================================================================
local VirtualInputManager = game:GetService("VirtualInputManager")

local function ClickAt(x, y)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(Config.Delays.ClickHold)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

--======================================================================
-- 3. UI GENERATOR & CONTROLLER MODULE
--======================================================================
local UI = {}
local elements = {} -- Stores references to elements that change dynamically

function UI.Create()
    elements.ScreenGui = Instance.new("ScreenGui")
    elements.ScreenGui.ResetOnSpawn = false
    elements.ScreenGui.Parent = (gethui or function() return game:GetService("CoreGui") end)()

    local frame = Instance.new("Frame")
    frame.Size = Config.UI.Size
    frame.Position = Config.UI.Position
    frame.BackgroundColor3 = Config.UI.BgColor
    frame.Active = true
    frame.Draggable = true
    frame.Parent = elements.ScreenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Config.UI.ThemeColor
    title.Text = "Loomian Auto Battle"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Parent = frame

    elements.Status = Instance.new("TextLabel")
    elements.Status.Size = UDim2.new(1, 0, 0, 25)
    elements.Status.Position = UDim2.new(0, 0, 0, 40)
    elements.Status.BackgroundTransparency = 1
    elements.Status.Text = "Status: Stopped"
    elements.Status.TextColor3 = Color3.fromRGB(255, 200, 0)
    elements.Status.TextScaled = true
    elements.Parent = frame

    elements.ToggleBtn = Instance.new("TextButton")
    elements.ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
    elements.ToggleBtn.Position = UDim2.new(0.05, 0, 0, 70)
    elements.ToggleBtn.BackgroundColor3 = Config.UI.SuccessColor
    elements.ToggleBtn.Text = "ENABLE AUTO BATTLE"
    elements.ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
    elements.ToggleBtn.TextScaled = true
    elements.ToggleBtn.Parent = frame

    -- Generate Move Buttons Matrix
    for i = 1, 4 do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.42, 0, 0, 35)
        
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        btn.Position = UDim2.new(0.06 + (col * 0.46), 0, 0, 130 + (row * 45))
        btn.BackgroundColor3 = (i == State.SelectedMove) and Config.UI.SuccessColor or Config.UI.NeutralColor
        btn.Text = "Move " .. i
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextScaled = true
        btn.Parent = frame
        
        btn.MouseButton1Click:Connect(function()
            UI.SelectMove(i, frame)
        end)
    end

    local removeBtn = Instance.new("TextButton")
    removeBtn.Size = UDim2.new(0.9, 0, 0, 35)
    removeBtn.Position = UDim2.new(0.05, 0, 0, 260)
    removeBtn.BackgroundColor3 = Config.UI.AlertColor
    removeBtn.Text = "Remove GUI"
    removeBtn.TextColor3 = Color3.new(1, 1, 1)
    removeBtn.TextScaled = true
    removeBtn.Parent = frame

    -- Event Listeners
    elements.ToggleBtn.MouseButton1Click:Connect(UI.ToggleAutoBattle)
    removeBtn.MouseButton1Click:Connect(UI.Destroy)
end

function UI.SetStatus(text)
    if elements.Status then
        elements.Status.Text = "Status: " .. text
    end
end

function UI.ToggleAutoBattle()
    State.Enabled = not State.Enabled
    if State.Enabled then
        elements.ToggleBtn.Text = "DISABLE AUTO BATTLE"
        elements.ToggleBtn.BackgroundColor3 = Config.UI.AlertColor
    else
        elements.ToggleBtn.Text = "ENABLE AUTO BATTLE"
        elements.ToggleBtn.BackgroundColor3 = Config.UI.SuccessColor
    end
end

function UI.SelectMove(moveIndex, frame)
    State.SelectedMove = moveIndex
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("TextButton") and child.Text:find("Move ") then
            local num = tonumber(child.Text:match("%d+"))
            child.BackgroundColor3 = (num == moveIndex) and Config.UI.SuccessColor or Config.UI.NeutralColor
        end
    end
end

function UI.Destroy()
    State.IsRunning = false
    if elements.ScreenGui then
        elements.ScreenGui:Destroy()
    end
end

--======================================================================
-- 4. MAIN EXECUTION LOOP
--======================================================================
UI.Create()

task.spawn(function()
    while State.IsRunning do
        task.wait(Config.Delays.LoopInterval)
        
        if not State.Enabled then 
            UI.SetStatus("Stopped")
            continue 
        end
        
        UI.SetStatus("Attacking...")
        
        -- Step 1: Click Fight
        local fightCoords = Config.Coordinates.Fight
        ClickAt(fightCoords[1], fightCoords[2])
        task.wait(Config.Delays.MenuTransition)
        
        -- Intermittent safety break checks
        if not State.Enabled or not State.IsRunning then continue end 
        
        -- Step 2: Click Chosen Move
        local moveKey = "Move" .. State.SelectedMove
        local moveCoords = Config.Coordinates[moveKey]
        if moveCoords then
            ClickAt(moveCoords[1], moveCoords[2])
            UI.SetStatus("Clicked Move " .. State.SelectedMove)
        end
        
        task.wait(Config.Delays.TurnAnimation)
    end
end)

print("Loomian Auto Battle Module loaded successfully.")
