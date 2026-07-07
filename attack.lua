local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local function ScanImageIDs()
    print("\n=== NEW IMAGE ID SCAN ===")
    local count = 0
    
    for _, obj in ipairs(playerGui:GetDescendants()) do
        if (obj:IsA("ImageButton") or obj:IsA("ImageLabel")) and obj.Image and obj.Image ~= "" then
            count += 1
            print(string.format("%d. Name: %-20s | Visible: %s | Image: %s", 
                count, 
                obj.Name, 
                obj.Visible and "YES" or "NO", 
                obj.Image
            ))
        end
    end
    
    if count == 0 then
        print("No ImageButtons/ImageLabels found.")
    else
        print("Found " .. count .. " images total.")
    end
end

-- Run scan every 5 seconds
while true do
    ScanImageIDs()
    task.wait(5)
end
