-- PłakałHub dla Brookhaven (Xeno)
-- Wersja: 2.0 (Mega Rozbudowana)
-- Autor: palofsc

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Plakalhub/P-aka-HubBrookHaven/refs/heads/main/PłakałHub.lua"))() -- Zmień na swój adres URL biblioteki UI

local Window = Library:CreateWindow("PłakałHub v2.0")
local MainTab = Window:CreateTab("Główne")
local PlayerTab = Window:CreateTab("Gracz")
local TrollTab = Window:CreateTab("Trolling")
local TeleportTab = Window:CreateTab("Teleportacja")
local FunTab = Window:CreateTab("Zabawa & Wizualne")
local MiscTab = Window:CreateTab("Różne")

-- ==========================================
-- GŁÓWNE (MainTab)
-- ==========================================

MainTab:CreateButton("Zabij wszystkich", function()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = 0
        end
    end
end)

MainTab:CreateButton("Wysadź wszystkich", function()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local explosion = Instance.new("Explosion")
            explosion.Position = player.Character.HumanoidRootPart.Position
            explosion.Parent = workspace
        end
    end
end)

MainTab:CreateToggle("Auto-farma pieniędzy", false, function(state)
    getgenv().AutoFarm = state
    task.spawn(function()
        while getgenv().AutoFarm do
            local reStorage = game:GetService("ReplicatedStorage")
            local events = reStorage:FindFirstChild("Events")
            if events and events:FindFirstChild("GiveMoney") then
                events.GiveMoney:FireServer(1000)
            end
            task.wait(0.3)
        end
    end)
end)

MainTab:CreateButton("Aresztuj wszystkich (Lokalnie)", function()
    -- Symulacja aresztowania poprzez przypięcie kajdanek (efekt wizualny/lokalny)
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer and player.Character then
            local b = Instance.new("RopeConstraint")
            b.Parent = player.Character
            -- uwaga: w pełni działające aresztowanie wymaga odpowiedniego eventu gry
        end
    end
end)

-- ==========================================
-- GRACZ (PlayerTab)
-- ==========================================

PlayerTab:CreateSlider("Prędkość chodzenia", 16, 500, 16, function(value)
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end)

PlayerTab:CreateSlider("Siła skoku", 50, 500, 50, function(value)
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = value
    end
end)

PlayerTab:CreateToggle("Nieskończony skok", false, function(state)
    getgenv().InfJump = state
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if getgenv().InfJump then
            local char = game:GetService("Players").LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end
    end)
end)

PlayerTab:CreateToggle("Noclip (Chodzenie przez ściany)", false, function(state)
    getgenv().Noclip = state
    game:GetService("RunService").Stepped:Connect(function()
        if getgenv().Noclip then
            local char = game:GetService("Players").LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end)

PlayerTab:CreateButton("Włącz pełne latanie (E to toggle)", function()
    -- Klasyczny skrypt na latanie pod klawisz E
    local player = game:GetService("Players").LocalPlayer
    local mouse = player:GetMouse()
    local char = player.Character
    local flying = false
    local speed = 50

    mouse.KeyDown:Connect(function(key)
        if key:lower() == "e" then
            flying = not flying
            local root = char:FindFirstChild("HumanoidRootPart")
            if flying and root then
                local bv = Instance.new("BodyVelocity", root)
                bv.Name = "FlyBV"
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bv.Velocity = Vector3.new(0,0,0)
                
                task.spawn(function()
                    while flying and root and bv.Parent do
                        bv.Velocity = mouse.Hit.LookVector * speed
                        task.wait()
                    end
                end)
            else
                if root and root:FindFirstChild("FlyBV") then
                    root.FlyBV:Destroy()
                end
            end
        end
    end)
end)

PlayerTab:CreateButton("Zresetuj postać", function()
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = 0
    end
end)

-- ==========================================
-- TOLLING / PRZESZKADZANIE (TrollTab)
-- ==========================================

TrollTab:CreateButton("Teleportuj wszystkich do siebie", function()
    local lp = game:GetService("Players").LocalPlayer
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = lp.Character.HumanoidRootPart.CFrame
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = myPos
            end
        end
    end
end)

TrollTab:CreateButton("Zglitchuj/Odepchnij wszystkich", function()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local bp = Instance.new("BodyThrust")
            bp.Force = Vector3.new(99999, 99999, 99999)
            bp.Parent = player.Character.HumanoidRootPart
        end
    end
end)

TrollTab:CreateTextBox("Spamuj czat wiadomością", function(text)
    for i = 1, 5 do
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
        task.wait(0.4)
    end
end)

TrollTab:CreateButton("Ukradnij wózki dziecięce", function()
    -- Specyficzne dla Brookhaven usuwanie/przywłaszczanie wózków na mapie
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("stroller") or obj.Name:lower():find("carriage") then
            obj.CFrame = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end
end)

-- ==========================================
-- TELEPORTACJA (TeleportTab)
-- ==========================================

TeleportTab:CreateButton("Bank (Sejf)", function()
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(100, 20, 200) -- Przykładowe współrzędne banku
    end
end)

TeleportTab:CreateButton("Komisariat Policji", function()
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-50, 20, 300)
    end
end)

TeleportTab:CreateButton("Szpital", function()
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(250, 20, -100)
    end
end)

TeleportTab:CreateButton("Salon samochodowy", function()
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-150, 20, 50)
    end
end)

TeleportTab:CreateButton("Sekretny pokój (Agencja)", function()
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(500, -50, 500) -- Przykładowy tajny pokój Brookhaven
    end
end)

TeleportTab:CreateTextBox("Wpisz współrzędne (x,y,z)", function(text)
    local coords = text:split(",")
    if #coords == 3 then
        local x, y, z = tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3])
        local char = game:GetService("Players").LocalPlayer.Character
        if x and y and z and char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
        end
    end
end)

-- ==========================================
-- ZABAWA & WIZUALNE (FunTab)
-- ==========================================

FunTab:CreateButton("Tryb Giganta (Lokalnie)", function()
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if hum:FindFirstChild("BodyHeightScale") then
            hum.BodyHeightScale.Value = 3
            hum.BodyWidthScale.Value = 3
            hum.BodyDepthScale.Value = 3
            hum.HeadScale.Value = 3
        end
    end
end)

FunTab:CreateButton("Tryb Mini-Gracza (Lokalnie)", function()
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if hum:FindFirstChild("BodyHeightScale") then
            hum.BodyHeightScale.Value = 0.3
            hum.BodyWidthScale.Value = 0.3
            hum.BodyDepthScale.Value = 0.3
            hum.HeadScale.Value = 0.3
        end
    end
end)

FunTab:CreateButton("Nocna Wizja (Fullbright)", function()
    game:GetService("Lighting").Ambient = Color3.new(1, 1, 1)
    game:GetService("Lighting").OutdoorAmbient = Color3.new(1, 1, 1)
    game:GetService("Lighting").Brightness = 2
end)

FunTab:CreateButton("Zepsuj niebo (Tęcza)", function()
    task.spawn(function()
        while true do
            game:GetService("Lighting").Sky.SkyboxBk = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            game:GetService("Lighting").Sky.SkyboxDn = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            task.wait()
        end
    end)
end)

-- ==========================================
-- RÓŻNE (MiscTab)
-- ==========================================

MiscTab:CreateButton("ESP (Przez ściany)", function()
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

MiscTab:CreateButton("Usuń mgłę", function()
    game:GetService("Lighting").FogEnd = 1e5
end)

MiscTab:CreateButton("Nieśmiertelność (Lokalna)", function()
    local plr = game:GetService("Players").LocalPlayer
    local char = plr.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end
end)

MiscTab:CreateButton("Usuń wszystkie drzwi od domów", function()
    -- Funkcja próbuje usunąć bariery i drzwi z domów w Brookhaven (działa lokalnie)
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name:lower():find("door") or v.Name:lower():find("gate") then
            v:Destroy()
        end
    end
end)

-- Uruchomienie
Library:Notify("PłakałHub v2.0 załadowany! Ponad 25 potężnych opcji gotowych do użycia. Insert otwiera menu.")