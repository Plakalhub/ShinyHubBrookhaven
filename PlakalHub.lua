-- PłakałHub dla Brookhaven
-- Wersja: 1.0
-- Autor: palofsc

-- Ładujemy Twój skrypt (On już sam tworzy okno i sekcje, więc NIE dodajemy tu Library.CreateLib!)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Plakalhub/PlakalHubBrookHaven/refs/heads/main/PlakalHub.lua"))()

-- Rejestracja dodatkowej sekcji dla auta w zakładce Różne (MiscTab/MiscSection są już stworzone w Twoim pliku)
-- Uwaga: Jeśli Kavo sypie błędem przy tworzeniu nowej sekcji, wrzucamy opcję RGB prosto do istniejącej MiscSection
local CarSection = MiscSection

-- ==========================================
-- DOPISYWANIE NOWYCH FUNKCJI DO TWOICH ZAKŁADEK
-- ==========================================

-- 1. NOWA OPCJA: Wybór i odtwarzanie Radio ID (Dodawane do Twojej sekcji Główne)
local currentRadioID = ""
MainSection:NewTextBox("Wpisz Radio ID", "Tutaj wpisz ID muzyki z Roblox", function(text)
    currentRadioID = text
end)

MainSection:NewButton("Odtwórz Radio ID", "Puszcza muzykę dla całego serwera", function()
    local reStorage = game:GetService("ReplicatedStorage")
    local passEvent = reStorage:FindFirstChild("Content") and reStorage.Content:FindFirstChild("EquipGamepass")
    
    if passEvent and currentRadioID ~= "" then
        passEvent:FireServer("Radio", currentRadioID)
    end
end)

-- 2. NOWA OPCJA: Latanie (Fly) (Dodawane do Twojej sekcji Gracz)
PlayerSection:NewToggle("Latanie (Fly)", "Pozwala latać postacią", function(state)
    getgenv().Fly = state
    local player = game:GetService("Players").LocalPlayer
    
    if state then
        task.spawn(function()
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local humanoid = char:WaitForChild("Humanoid")
            
            if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
            if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end
            
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlyBV"
            bv.MaxForce = Vector3.new(0, 0, 0)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp
            
            local bg = Instance.new("BodyGyro")
            bg.Name = "FlyBG"
            bg.MaxTorque = Vector3.new(0, 0, 0)
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp
            
            humanoid.PlatformStand = true
            local camera = workspace.CurrentCamera
            
            while getgenv().Fly and char and char.Parent ~= nil do
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                bg.CFrame = camera.CFrame
                
                local moveDirection = humanoid.MoveDirection
                local uis = game:GetService("UserInputService")
                local up = uis:IsKeyDown(Enum.KeyCode.Space) and 1 or 0
                local down = uis:IsKeyDown(Enum.KeyCode.LeftShift) and -1 or 0
                
                local speed = char.Humanoid.WalkSpeed
                bv.Velocity = (moveDirection * speed) + Vector3.new(0, (up + down) * speed, 0)
                task.wait()
            end
            
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.PlatformStand = false
            end
        end)
    else
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChild("Humanoid")
            if hrp then
                if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
                if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end
            end
            if humanoid then
                humanoid.PlatformStand = false
            end
        end
    end
end)

-- 3. NOWA OPCJA: Płynne RGB dla auta (Dodawane do Twojej sekcji Różne)
CarSection:NewToggle("Płynne RGB Auta", "Zmienia kolor auta (Czerwony-Czarny)", function(state)
    getgenv().RGBVehicle = state
    
    if state then
        task.spawn(function()
            local reStorage = game:GetService("ReplicatedStorage")
            local carEvent = reStorage:FindFirstChild("RE") and reStorage.RE:FindFirstChild("1_v_c_c") 
            
            local colorStart = Color3.fromRGB(255, 0, 0)
            local colorEnd = Color3.fromRGB(0, 0, 0)
            local t = 0
            local direction = 1
            
            while getgenv().RGBVehicle do
                t = t + (0.05 * direction)
                if t >= 1 then
                    t = 1
                    direction = -1
                elseif t <= 0 then
                    t = 0
                    direction = 1
                end
                
                local currentColor = colorStart:lerp(colorEnd, t)
                
                if carEvent then
                    carEvent:FireServer("Color", currentColor)
                end
                
                task.wait(0.1)
            end
        end)
    end
end)
