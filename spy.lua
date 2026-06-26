-- ================== RAINBOW SHOP SPY ==================
print("🔍 Rainbow Shop Spy Started - Buy 1 item now!")

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" then
        local name = self.Name:lower()
        local path = self:GetFullName():lower()
        
        if name:find("buy") or name:find("purchase") or name:find("shop") or 
           name:find("item") or name:find("rainbow") or path:find("rainbow") then
            
            print("\n=== RAINBOW SHOP REMOTE CAUGHT ===")
            print("Remote:", self:GetFullName())
            print("Name:", self.Name)
            
            local args = {...}
            for i, arg in ipairs(args) do
                if typeof(arg) == "table" then
                    print("Arg " .. i .. " (Table):")
                    for k,v in pairs(arg) do
                        print("   " .. tostring(k) .. " = " .. tostring(v))
                    end
                else
                    print("Arg " .. i .. ":", typeof(arg), "→", arg)
                end
            end
            print("===================================\n")
        end
    end
    return old(self, ...)
end)

setreadonly(mt, true)
print("Spy is ready! Go buy 1 item from Rainbow Shop NPC now.")
