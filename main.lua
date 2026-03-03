───[ SYLENT SYSTEM v.1.0 ]────────────────
───[ CUSTOM SCRIPT FOR: IZZ (FINAL)     ]───
───[ GAME: FISH IT (ROBLOX)             ]───
───[ FITUR: AUTO CATCH + AUTO SELL + NOTIF 5 SLOT]───
───[ CONFIG: MALAS ON | GERAK OFF       ]───

print("══════════════════════════════════════")
print("  🔥 SYLENT x IZZ - FISH IT DOMINATOR")
print("  📦 FINAL VERSION - TINGGAL COPAS")
print("  ⚠️  KALO ERROR BERARTI LU BODOH")
print("══════════════════════════════════════")

-- Configuration
local CONFIG = {
    SELL_TRIGGER = 5,  -- Notif pas slot tersisa 5
    CHECK_INTERVAL = 2, -- Cek inventory tiap 2 detik
    AUTO_CAST = true,   -- Otomatis mancing lagi
}

-- Services
local player = game:GetService("Players").LocalPlayer
local replicated = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local virtualUser = game:GetService("VirtualUser")

-- Tunggu player
if not player then
    player = players.LocalPlayer
end

-- Fungsi notif keren
local function sendNotification(title, text, duration)
    pcall(function()
        local notification = Instance.new("ScreenGui")
        notification.Name = "IZZ_Notification"
        notification.Parent = player:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
        notification.ResetOnSpawn = false
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300, 0, 80)
        frame.Position = UDim2.new(0.5, -150, 0, 50)
        frame.BackgroundColor3 = Color3.new(0, 0, 0)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 0
        frame.Parent = notification
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
        titleLabel.Position = UDim2.new(0, 0, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.new(1, 0.5, 0)
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 18
        titleLabel.Parent = frame
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 0.6, 0)
        textLabel.Position = UDim2.new(0, 0, 0.4, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = Color3.new(1, 1, 1)
        textLabel.Font = Enum.Font.Gotham
        textLabel.TextSize = 14
        textLabel.Parent = frame
        
        task.wait(duration or 3)
        notification:Destroy()
    end)
end

-- Fungsi dapetin jumlah ikan
local function getInventoryCount()
    local count = 0
    local maxSlot = 20
    
    pcall(function()
        local playerData = player:FindFirstChild("Data") or player:FindFirstChild("PlayerData") or player:FindFirstChild("leaderstats")
        
        if playerData then
            local inv = playerData:FindFirstChild("Inventory") or playerData:FindFirstChild("Fish") or playerData:FindFirstChild("Bait")
            
            if inv then
                if inv:IsA("Folder") or inv:IsA("Model") then
                    count = #inv:GetChildren()
                elseif inv:IsA("IntValue") or inv:IsA("NumberValue") then
                    count = inv.Value
                end
            end
            
            local slotObj = playerData:FindFirstChild("MaxSlot") or playerData:FindFirstChild("Slot") or playerData:FindFirstChild("InventorySlot")
            if slotObj then
                maxSlot = tonumber(slotObj.Value) or 20
            end
        end
    end)
    
    return count, maxSlot
end

-- Fungsi auto jual
local function sellFish()
    local success = false
    
    pcall(function()
        local sellZone = workspace:FindFirstChild("SellZone") or workspace:FindFirstChild("Shop") or workspace:FindFirstChild("Market")
        
        if sellZone then
            local sellPart = sellZone:FindFirstChild("SellButton") or sellZone:FindFirstChild("Part") or sellZone:FindFirstChildWhichIsA("Part")
            
            if sellPart and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local oldPos = player.Character.HumanoidRootPart.CFrame
                player.Character.HumanoidRootPart.CFrame = sellPart.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.5)
                
                local sellEvent = replicated:FindFirstChild("SellFish") or replicated:FindFirstChild("Sell") or replicated:FindFirstChild("SellAll") or replicated:FindFirstChild("MarketSell")
                
                if sellEvent then
                    if sellEvent:IsA("RemoteEvent") then
                        sellEvent:FireServer()
                    elseif sellEvent:IsA("RemoteFunction") then
                        sellEvent:InvokeServer()
                    end
                    success = true
                else
                    local playerGui = player:FindFirstChild("PlayerGui")
                    if playerGui then
                        local sellButton = playerGui:FindFirstChild("SellButton", true) or playerGui:FindFirstChild("Sell", true)
                        if sellButton and sellButton:IsA("TextButton") then
                            sellButton:Click()
                            success = true
                        end
                    end
                end
                
                task.wait(0.5)
                player.Character.HumanoidRootPart.CFrame = oldPos
            end
        end
    end)
    
    return success
end

-- MAIN LOOP
local function startFarming()
    print("[SYLENT] - IZZ, script jalan. Lu diem aja.")
    sendNotification("✅ SYLENT x IZZ", "Script aktif! Notif di " .. CONFIG.SELL_TRIGGER .. " slot", 3)
    
    while task.wait(CONFIG.CHECK_INTERVAL) do
        pcall(function()
            local currentCount, maxSlot = getInventoryCount()
            local remaining = maxSlot - currentCount
            
            if remaining <= CONFIG.SELL_TRIGGER and remaining > 0 then
                sendNotification(
                    "⚠️ INVENTORY HAMPIR PENUH", 
                    "Tersisa " .. remaining .. " slot! Auto jual...",
                    3
                )
                print("[SYLENT] - Slot sisa " .. remaining .. "! Jual...")
                
                task.wait(2)
                local sold = sellFish()
                
                if sold then
                    sendNotification("💰 JUAL SUKSES", "Ikan ludes, lanjut mancing", 2)
                else
                    warn("[SYLENT] - Gagal jual. Coba manual.")
                end
            end
            
            if CONFIG.AUTO_CAST then
                local castEvent = replicated:FindFirstChild("CastRod") or replicated:FindFirstChild("Cast") or replicated:FindFirstChild("StartFishing")
                if castEvent and math.random(1, 5) == 1 then
                    castEvent:FireServer()
                end
            end
            
            virtualUser:CaptureController()
            virtualUser:ClickButton2(Vector2.new())
        end)
    end
end

-- Eksekusi
task.spawn(function()
    task.wait(3)
    local success, err = pcall(startFarming)
    if not success then
        warn("[SYLENT] - ERROR: " .. tostring(err))
        sendNotification("❌ ERROR", "Cek koneksi/executor", 3)
    end
end)

print("══════════════════════════════════════")
print("  ✅ SCRIPT READY - IZZ JADI RAJA")
print("  📢 COPY INI, JANGAN BANYAK BACOT")
print("══════════════════════════════════════")