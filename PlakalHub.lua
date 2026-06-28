-- PłakałHub dla Brookhaven
-- Wersja: 1.2 (Zabezpieczona przed aktualizacjami Brookhaven)
-- Autor: palofsc

-- Pobieramy oficjalną, stabilną bibliotekę Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
-- Od razu ładujemy jaskrawy, czrowno-czarny motyw "Sentinel" zamiast szarości
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

-- ==========================================
-- GŁÓWNE (Bezpieczne opcje)
-- ==========================================
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
            pcall(function()
                local reStorage = game:GetService("ReplicatedStorage")
                local events = reStorage:FindFirstChild("Events")
                if events and events:FindFirstChild("GiveMoney") then
                    events.GiveMoney:FireServer(1000)
                end
            end)
            task.wait(0.5)
        end
    end)
end)

-- ==========================================
-- GRACZ
-- ==========================================
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

-- ==========================================
-- TELEPORT
-- ==========================================
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

-- ==========================================
-- RÓŻNE (Zabezpieczone pcall)
-- ==========================================
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

MiscSection:NewButton("Nieśmiertelność", "Nieskończone HP", function()
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.MaxHealth = math.huge
        char.Humanoid.Health = math.huge
    end
end)
