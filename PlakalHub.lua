-- PłakałHub dla Brookhaven
-- Wersja: 1.0
-- Autor: palofsc

-- Twój oryginalny link ładowany jako czysta biblioteka
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Plakalhub/PlakalHubBrookHaven/refs/heads/main/PlakalHub.lua"))()
-- Zmiana motywu na "Sentinel" (bardzo żywy, czarno-czerwony neon, brak szarości)
local Window = Library.CreateLib("PłakałHub", "Sentinel")

-- Rejestracja Zakładek
local MainTab = Window:NewTab("Główne")
local MainSection = MainTab:NewSection("Opcje Główne")

local PlayerTab = Window:NewTab("Gracz")
local PlayerSection = PlayerTab:NewSection("Opcje Gracza")

local TeleportTab = Window:NewTab("Teleport")
local TeleportSection = TeleportTab:NewSection("Miejsca")

local MiscTab = Window:NewTab("Różne")
local MiscSection = MiscTab:NewSection("Inne")
local CarSection = MiscTab:NewSection("Opcje Auta")

-- Główne
MainSection:NewButton("Zabij wszystkich", "Zdejmuje HP innym graczom", function()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = 0
        end
    end
end)

MainSection:NewButton("Wysadź wszystkich", "Tworzy eksplozję", function()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local explosion = Instance.new("Explosion")
            explosion.Position = player.Character.HumanoidRootPart.Position
            explosion.Parent = workspace
        end
    end
end)

MainSection:NewToggle("Auto-farma pieniędzy", "Zbiera kasę", function(state)
    getgenv().AutoFarm = state
    task.spawn(function()
        while getgenv().AutoFarm do
            local reStorage = game:GetService("ReplicatedStorage")
            local events = reStorage:FindFirstChild("Events")
            if events and events:FindFirstChild("GiveMoney") then
                events.GiveMoney:FireServer(1000)
            end
            task.wait(0.5)
        end
    end)
end)

-- Wybór i odtwarzanie Radio ID (Wymaga Gamepassa)
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

-- Gracz
PlayerSection:NewSlider("Prędkość", "Zmienia szybkość", 500, 16, function(value)
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end)

PlayerSection:NewSlider("Skok", "Zmienia siłę skoku", 500, 50, function(value)
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = value
    end
end)

-- Latanie (Fly)
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

-- Teleport
TeleportSection:NewButton("Teleport do banku", "Bank", function()
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(100, 20, 200)
    end
end)

TeleportSection:NewButton("Teleport do policji", "Policja", function()
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-50, 20, 300)
    end
end)

-- Różne
MiscSection:NewButton("ESP (Przez ściany)", "Pokazuje graczy", function()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer and player.Character then
            local oldHighlight = player.Character:FindFirstChild("EspHighlight")
            if oldHighlight then oldHighlight:Destroy() end

            local highlight = Instance.new("Highlight")
            highlight.Name = "EspHighlight"
            highlight.Parent = player.Character
            highlight.FillColor = Color3.new(1, 0, 0)
            highlight.OutlineColor = Color3.new(1, 1, 1)
        end
    end
end)

MiscSection:NewButton("Usuń mgłę", "Czyste niebo", function()
    game:GetService("Lighting").FogEnd = 1e5
end)

MiscSection:NewButton("Nieśmiertelność (Lokalna)", "Nieskończone HP", function()
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.MaxHealth = math.huge
        char.Humanoid.Health = math.huge
    end
end)

-- Płynne RGB dla auta (Czerwony <-> Czarny)
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
