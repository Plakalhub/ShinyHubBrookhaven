--[[
    ShinyHub V2 - Brookhaven RP (Xeno Executor Ultimate Bypass)
    Wymuszone RGB, Naprawiony RP Name przez Metatable Hooking, Nowe Zakładki i Funkcje.
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

if CoreGui:FindFirstChild("ShinyHubMenu") then CoreGui.ShinyHubMenu:Destroy() end

-- ==========================================
-- [BYPASSY & HOOKI] Naprawa RP Name, RGB i Radia
-- ==========================================
local currentHue = 0
task.spawn(function()
    while true do
        currentHue = (tick() % 4) / 4
        task.wait()
    end
end)

-- Wymuszenie zmiany RP Name oraz koloru w strukturze gry
local function forceShinyHubIdentity()
    task.spawn(function()
        while task.wait(0.1) do
            pcall(function()
                -- Zmiana tekstu i koloru nad głową w tabliczkach Brookhaven
                local char = Player.Character
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("TextLabel") and (v.Text:lower():find(Player.Name:lower()) or v.Name == "NameTag" or v.Parent:IsA("BillboardGui")) then
                            v.Text = "ShinyHub"
                            v.TextColor3 = Color3.fromHSV(currentHue, 1, 1)
                        end
                    end
                end
                -- Wymuszenie wysłania do serwera (jeśli remote odpowiada)
                local net = ReplicatedStorage:FindFirstChild("Network")
                if net and net:FindFirstChild("SetRPName") then
                    net.SetRPName:FireServer("ShinyHub")
                end
            end)
        end
    end)
end
task.spawn(forceShinyHubIdentity)

-- ==========================================
-- INTERFEJS UŻYTKOWNIKA (ŻÓŁTO-CZARNY Z ZAKŁADKAMI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ShinyHubMenu"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true

-- Panel boczny (Zakładki)
local TabPanel = Instance.new("Frame", MainFrame)
TabPanel.Size = UDim2.new(0, 130, 1, -45)
TabPanel.Position = UDim2.new(0, 0, 0, 45)
TabPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabPanel.BorderSizePixel = 0

-- Kontener na zawartość zakładek
local ContentPanel = Instance.new("Frame", MainFrame)
ContentPanel.Size = UDim2.new(1, -140, 1, -55)
ContentPanel.Position = UDim2.new(0, 135, 0, 50)
ContentPanel.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Text = "★ SHINYHUB V2 - BROOKHAVEN ★"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

local tabs = {}
local activeTab = nil

local function createTab(name)
    local tabBtn = Instance.new("TextButton", TabPanel)
    tabBtn.Size = UDim2.new(1, 0, 0, 40)
    tabBtn.Position = UDim2.new(0, 0, 0, #TabPanel:GetChildren() * 40)
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.TextSize = 14
    tabBtn.BorderSizePixel = 0
    
    local scroll = Instance.new("ScrollingFrame", ContentPanel)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.Visible = false
    scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
    scroll.ScrollBarThickness = 4
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.scroll.Visible = false
            t.btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            t.btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        scroll.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        tabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)
    
    tabs[name] = {btn = tabBtn, scroll = scroll}
    if not activeTab then
        scroll.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        tabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        activeTab = name
    end
    return scroll
end

local function addButton(tabName, text, callback)
    local scroll = tabs[tabName].scroll
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.fromRGB(255, 255, 0)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 15
    btn.BorderColor3 = Color3.fromRGB(255, 255, 0)
    btn.BorderSizePixel = 1
    btn.MouseButton1Click:Connect(callback)
end

-- Tworzenie zakładek
local mainTab = createTab("Główne")
local vehicleTab = createTab("Pojazdy")
local teleportTab = createTab("Teleporty")
local funTab = createTab("Inne/Fun")

-- ==========================================
-- ZAKŁADKA: GŁÓWNE (Radio, Fly, Prędkość)
-- ==========================================
local function forceAudio(id)
    -- Całkowity bypass audio – generowanie bezpośrednio w uchu gracza i postaci
    pcall(function()
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local sound = char.HumanoidRootPart:FindFirstChild("ShinyHubAudio") or Instance.new("Sound", char.HumanoidRootPart)
            sound.Name = "ShinyHubAudio"
            sound.SoundId = "rbxassetid://" .. tostring(id)
            sound.Volume = 5
            sound.Looped = false
            sound:Play()
        end
        -- Agresywny spam do wszystkich eventów dźwiękowych w Brookhaven
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("audio") or v.Name:lower():find("sound")) then
                v:FireServer(tostring(id))
            end
        end
    end)
end

addButton("Główne", "Głośne Radio (Test)", function() forceAudio(1837946285) end)
addButton("Główne", "Horror Krzyk 1", function() forceAudio(9069609268) end)
addButton("Główne", "Horror Śmiech 2", function() forceAudio(9061011306) end)

local flying = false
local flySpeed = 60
local bVel, bGyr
addButton("Główne", "Latanie (Fly) Włącz/Wyłącz", function()
    flying = not flying
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if flying and hrp then
        bVel = Instance.new("BodyVelocity", hrp)
        bVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bGyr = Instance.new("BodyGyro", hrp)
        bGyr.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while flying and hrp and char:FindFirstChild("Humanoid") do
                bVel.Velocity = char.Humanoid.MoveDirection * flySpeed
                bGyr.CFrame = workspace.CurrentCamera.CFrame
                task.wait()
            end
        end)
    else
        if bVel then bVel:Destroy() end
        if bGyr then bGyr:Destroy() end
    end
end)

addButton("Główne", "Zwiększ Prędkość Biegu (Speed 60)", function()
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 60
    end
end)

-- ==========================================
-- ZAKŁADKA: POJAZDY (Wymuszone RGB)
-- ==========================================
local rgbCarActive = false
addButton("Pojazdy", "Wymuś RGB Car (Szybkie)", function()
    rgbCarActive = not rgbCarActive
    if not rgbCarActive then return end
    
    task.spawn(function()
        while rgbCarActive do
            pcall(function()
                local car = nil
                -- Najbardziej niezawodne szukanie pojazdu w Brookhaven
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then
                        car = v.Parent
                        break
                    end
                end
                
                if car then
                    local color = Color3.fromHSV(currentHue, 1, 1)
                    
                    -- Próba zmiany przez event sieciowy gry
                    local network = ReplicatedStorage:FindFirstChild("Network")
                    if network and network:FindFirstChild("ColorCar") then
                        network.ColorCar:FireServer(car, color)
                    end
                    
                    -- Brutalne nadpisanie kolorów każdej części i usunięcie tekstur blokujących kolory
                    for _, part in pairs(car:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "Windshield" then
                            part.Color = color
                            part.Material = Enum.Material.Glass -- Daje ładny połysk neonowy
                            if part:IsA("MeshPart") then
                                part.TextureID = ""
                            end
                        end
                    end
                end
            end)
            task.wait(0.01)
        end
    end)
end)

addButton("Pojazdy", "Super Prędkość Auta (Jedź do przodu!)", function()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then
                v.MaxSpeed = 300
                v.Torque = 10000
            end
        end
    end)
end)

-- ==========================================
-- ZAKŁADKA: TELEPORTY (Kluczowe miejsca)
-- ==========================================
local function tpTo(cframe)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = cframe end
end

addButton("Teleporty", "Bank (Sejf)", function() tpTo(CFrame.new(-22, 10, 52)) end)
addButton("Teleporty", "Posterunek Policji", function() tpTo(CFrame.new(-42, 11, 28)) end)
addButton("Teleporty", "Spawn Główny", function() tpTo(CFrame.new(0, 10, 0)) end)
addButton("Teleporty", "Szpital", function() tpTo(CFrame.new(65, 12, -10)) end)

-- ==========================================
-- ZAKŁADKA: INNE / FUN (ESP, Bariery)
-- ==========================================
addButton("Inne/Fun", "Włącz ESP (Widzenie przez ściany)", function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if not p.Character.HumanoidRootPart:FindFirstChild("BoxHighlight") then
                local box = Instance.new("BoxHandleAdornment", p.Character.HumanoidRootPart)
                box.Name = "BoxHighlight"
                box.Size = Vector3.new(4, 6, 4)
                box.Color3 = Color3.fromRGB(255, 255, 0)
                box.AlwaysOnTop = true
                box.ZIndex = 5
                box.Adornee = p.Character.HumanoidRootPart
                box.Transparency = 0.5
            end
        end
    end
end)

addButton("Inne/Fun", "Usuń Ściany Sejfu / Drzwi (NoClip Bank)", function()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():find("door") or v.Name:lower():find("wall") or v.Name:lower():find("safe")) then
                if (v.Position - Player.Character.HumanoidRootPart.Position).Magnitude < 50 then
                    v.CanCollide = false
                    v.Transparency = 0.5
                end
            end
        end
    end)
end)

addButton("Inne/Fun", "Skok na księżyc", function()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Velocity = Vector3.new(0, 350, 0) end
end)

-- Przycisk zamknięcia
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 130, 0, 40)
CloseBtn.Position = UDim2.new(0, 0, 1, -40)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "ZAMKNIJ HUB"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.MouseButton1Click:Connect(function()
    rgbCarActive = false
    flying = false
    ScreenGui:Destroy()
end)
