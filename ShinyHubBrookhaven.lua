--[[
    ShinyHub V7 - Brookhaven RP Mega Premium Edition
    - FIX: Animacje zablokowane na stałe (Bypass serwerowego resetu Idle)
    - SYSTEM: Wygodne przełączniki [ON / OFF] dla każdej opcji wymagającej kontroli
    - ILOŚĆ: Dokładnie 60 unikalnych, spersonalizowanych funkcji pod Brookhaven
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

if CoreGui:FindFirstChild("ShinyHubMenu") then CoreGui.ShinyHubMenu:Destroy() end

-- Zmienne globalne stanów (Toggles)
local Toggles = {
    Noclip = false, Fly = false, InfJump = false, Gatling = false, RGB= false, 
    Horn = false, ESP = false, SafeNoclip = false, Fullbright = false, AutoRob = false,
    ClickTP = false, Freecam = false, SpeedCar = false, AutoChat = false, Invisible = false
}

local currentHue = 0
task.spawn(function()
    while true do
        currentHue = (tick() % 4) / 4
        task.wait()
    end
end)

-- ==========================================
-- NIEZAWODNY SYSTEM BLOKADY ANIMACJI
-- ==========================================
local ActiveTrack = nil
local CurrentAnimID = nil

local function forcePlayAnimation(animID)
    pcall(function()
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local animScript = char:FindFirstChild("Animate")
        
        -- Wyłączenie kontroli domyślnego skryptu animacji na czas trwania emotki
        if animScript then animScript.Disabled = true end
        
        if hum then
            -- Czyszczenie starych śladów
            if ActiveTrack then ActiveTrack:Stop() ActiveTrack:Destroy() end
            for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end
            
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://" .. tostring(animID)
            
            ActiveTrack = hum:LoadAnimation(anim)
            ActiveTrack.Priority = Enum.AnimationPriority.Action
            ActiveTrack.Looped = true
            ActiveTrack:Play()
            CurrentAnimID = animID
        end
    end)
end

local function stopAllCustomAnimations()
    CurrentAnimID = nil
    if ActiveTrack then ActiveTrack:Stop() ActiveTrack:Destroy() ActiveTrack = nil end
    pcall(function()
        local char = Player.Character
        local animScript = char:FindFirstChild("Animate")
        if animScript then animScript.Disabled = false end -- Przywrócenie normalnego ruchu
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
    end)
end

-- Utrzymywanie klatek animacji bez względu na ruch czy stan bezczynności postaci
RunService.RenderStepped:Connect(function()
    if CurrentAnimID and ActiveTrack and not ActiveTrack.IsPlaying then
        pcall(function() ActiveTrack:Play() end)
    end
end)

-- ==========================================
-- INTERFEJS GRAFICZNY (60 OPCJI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ShinyHubMenu"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 680, 0, 540)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -270)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true

local TabPanel = Instance.new("Frame", MainFrame)
TabPanel.Size = UDim2.new(0, 160, 1, -45)
TabPanel.Position = UDim2.new(0, 0, 0, 45)
TabPanel.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
TabPanel.BorderSizePixel = 0

local ContentPanel = Instance.new("Frame", MainFrame)
ContentPanel.Size = UDim2.new(1, -175, 1, -55)
ContentPanel.Position = UDim2.new(0, 170, 0, 50)
ContentPanel.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Text = "★ SHINYHUB V7 - ULTIMATE 60 PREMIUM SELECTION ★"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

local tabs = {}
local activeTab = nil

local function createTab(name)
    local tabBtn = Instance.new("TextButton", TabPanel)
    tabBtn.Size = UDim2.new(1, 0, 0, 36)
    tabBtn.Position = UDim2.new(0, 0, 0, #TabPanel:GetChildren() * 36)
    tabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    tabBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.TextSize = 12
    tabBtn.BorderSizePixel = 0
    
    local scroll = Instance.new("ScrollingFrame", ContentPanel)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.Visible = false
    scroll.CanvasSize = UDim2.new(0, 0, 0, 750) -- Bardzo duża przestrzeń na przyciski
    scroll.ScrollBarThickness = 5
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.scroll.Visible = false
            t.btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            t.btn.TextColor3 = Color3.fromRGB(220, 220, 220)
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
    btn.Size = UDim2.new(1, -12, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(50, 50, 50)
    btn.MouseButton1Click:Connect(callback)
end

local function addToggleButton(tabName, text, toggleKey, callback)
    local scroll = tabs[tabName].scroll
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -12, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.Text = text .. " [OFF]"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(80, 40, 40)
    
    btn.MouseButton1Click:Connect(function()
        Toggles[toggleKey] = not Toggles[toggleKey]
        if Toggles[toggleKey] then
            btn.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
            btn.TextColor3 = Color3.fromRGB(100, 255, 100)
            btn.Text = text .. " [ON]"
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
            btn.Text = text .. " [OFF]"
        end
        callback(Toggles[toggleKey])
    end)
end

local function addSlider(tabName, text, min, max, default, callback)
    local scroll = tabs[tabName].scroll
    local f = Instance.new("Frame", scroll) f.Size = UDim2.new(1, -12, 0, 40) f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f) l.Size = UDim2.new(1, 0, 0, 14) l.BackgroundTransparency = 1 l.TextColor3 = Color3.fromRGB(255,255,0) l.Text = text..": "..default l.TextXAlignment = Enum.TextXAlignment.Left
    local tr = Instance.new("Frame", f) tr.Size = UDim2.new(1, 0, 0, 6) tr.Position = UDim2.new(0,0,0,18) tr.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local fi = Instance.new("Frame", tr) fi.Size = UDim2.new((default-min)/(max-min),0,1,0) fi.BackgroundColor3 = Color3.fromRGB(255,255,0)
    local b = Instance.new("TextButton", tr) b.Size = UDim2.new(0,12,0,12) b.Position = UDim2.new((default-min)/(max-min),-6,0,-3) b.Text=""
    local drag = false
    b.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local p = math.clamp((i.Position.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
        b.Position = UDim2.new(p, -6, 0, -3) fi.Size = UDim2.new(p, 0, 1, 0)
        local val = math.floor(min + (p * (max - min))) l.Text = text..": "..val callback(val)
    end end)
end

-- Tworzenie Kategorii
local tabMovement = createTab("Ruch & Postać")
local tabCombat = createTab("Ekwipunek")
local tabCars = createTab("Pojazdy")
local tabAnims = createTab("Animacje Premium")
local tabPlots = createTab("Teleport Działek")
local tabLocs = createTab("Teleport Lokacji")
local tabServer = createTab("Trolle & Otoczenie")

-- ==========================================
-- 1. RUCH & POSTAĆ (9 OPCJI)
-- ==========================================
addSlider("Ruch & Postać", "Bieg (WalkSpeed)", 16, 350, 16, function(v) if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v end end)
addSlider("Ruch & Postać", "Wysokość Skoku", 50, 500, 50, function(v) local h = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") if h then h.UseJumpPower = true h.JumpPower = v end end)
addToggleButton("Ruch & Postać", "[1] Noclip", "Noclip", function(state)
    if state then
        _G.NoclipLoop = RunService.Stepped:Connect(function()
            if Player.Character then for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        end)
    else if _G.NoclipLoop then _G.NoclipLoop:Disconnect() end end
end)
addToggleButton("Ruch & Postać", "[2] Latanie (Fly Mode)", "Fly", function(state)
    local char = Player.Character local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if state and hrp then
        _G.BVel = Instance.new("BodyVelocity", hrp) _G.BVel.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        _G.BGyr = Instance.new("BodyGyro", hrp) _G.BGyr.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
        task.spawn(function()
            while Toggles.Fly and hrp do _G.BVel.Velocity = char.Humanoid.MoveDirection * 80 _G.BGyr.CFrame = workspace.CurrentCamera.CFrame task.wait() end
        end)
    else if _G.BVel then _G.BVel:Destroy() _G.BGyr:Destroy() end end
end)
addToggleButton("Ruch & Postać", "[3] Nieskończony Skok", "InfJump", function(state)
    if state then _G.JumpCon = UserInputService.JumpRequest:Connect(function() local h = Player.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end)
    else if _G.JumpCon then _G.JumpCon:Disconnect() end end
end)
addToggleButton("Ruch & Postać", "[4] Teleport pod myszkę (Ctrl+Click)", "ClickTP", function(state)
    if state then _G.ClickCon = UserInputService.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            local pos = Player:GetMouse().Hit.p if Player.Character then Player.Character:MoveTo(pos + Vector3.new(0,3,0)) end
        end
    end) else if _G.ClickCon then _G.ClickCon:Disconnect() end end
end)
addButton("Ruch & Postać", "[5] Szybki Reset Postaci", function() if Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").Health = 0 end end)
addButton("Ruch & Postać", "[6] Usuń Swój NameTag", function() pcall(function() Player.Character.Head.nametag:Destroy() end) end)
addButton("Ruch & Postać", "[7] Połóż postać na ziemi (Sit)", function() pcall(function() Player.Character.Humanoid.Sit = true end end)

-- ==========================================
-- 2. EKWIPUNEK (8 OPCJI)
-- ==========================================
addButton("Ekwipunek", "[8] Pobierz Wszystkie Narzędzia", function()
    local res = ReplicatedStorage:FindFirstChild("Tools") or ReplicatedStorage:FindFirstChild("Items") or ReplicatedStorage
    for _, v in pairs(res:GetDescendants()) do if v:IsA("Tool") then v:Clone().Parent = Player.Backpack end end
end)
addToggleButton("Ekwipunek", "[9] Gatling Mode (Szybka Zmiana)", "Gatling", function(state)
    if state then task.spawn(function()
        while Toggles.Gatling do
            local h = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if h and Player.Backpack then for _, t in pairs(Player.Backpack:GetChildren()) do if t:IsA("Tool") and Toggles.Gatling then h:EquipTool(t) task.wait(0.02) end end end
            task.wait()
        end
    end) end
end)
addButton("Ekwipunek", "[10] Wyczyszczenie Plecaka", function() if Player.Backpack then Player.Backpack:ClearAllChildren() end end)
addButton("Ekwipunek", "[11] Spawn Zestawu Napadowego", function()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do if v:IsA("Tool") and (v.Name == "Bomb" or v.Name == "Sack") then v:Clone().Parent = Player.Backpack end end
end)
addButton("Ekwipunek", "[12] Daj Kartę ID Agencji", function() for _, v in pairs(ReplicatedStorage:GetDescendants()) do if v:IsA("Tool") and v.Name:find("Key") then v:Clone().Parent = Player.Backpack end end end)
addButton("Ekwipunek", "[13] Spawn Smartfona", function() local p = ReplicatedStorage:FindFirstChild("Phone", true) if p then p:Clone().Parent = Player.Backpack end end)
addButton("Ekwipunek", "[14] Daj Śpiwór (Glitche)", function() local s = ReplicatedStorage:FindFirstChild("SleepingBag", true) if s then s:Clone().Parent = Player.Backpack end end)
addButton("Ekwipunek", "[15] Pobierz Jedzenie", function() for _, v in pairs(ReplicatedStorage:GetDescendants()) do if v:IsA("Tool") and (v.Name == "Pizza" or v.Name == "Donut" or v.Name == "IceCream") then v:Clone().Parent = Player.Backpack end end end)

-- ==========================================
-- 3. POJAZDY (8 OPCJI)
-- ==========================================
addToggleButton("Pojazdy", "[16] Tryb Tęczy (RGB Car)", "RGB", function(state)
    if state then task.spawn(function()
        while Toggles.RGB do
            pcall(function()
                local seat = nil for _, v in pairs(workspace:GetDescendants()) do if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then seat = v break end end
                if seat and seat.Parent then ReplicatedStorage.Network.ColorCar:FireServer(seat.Parent, Color3.fromHSV(currentHue, 1, 1)) end
            end)
            task.wait(0.05)
        end
    end) end
end)
addToggleButton("Pojazdy", "[17] Mega Przyśpieszenie Silnika", "SpeedCar", function(state)
    task.spawn(function()
        while Toggles.SpeedCar do
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then v.MaxSpeed = 400 v.Torque = 5000 end
                end
            end)
            task.wait(0.5)
        end
    end)
end)
addToggleButton("Pojazdy", "[18] Spamowanie Klaksonem (Horn Bug)", "Horn", function(state)
    if state then task.spawn(function()
        while Toggles.Horn do
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then
                        local h = v.Parent:FindFirstChild("Horn") or v.Parent:FindFirstChildOfClass("Sound") if h then h:Play() end
                    end
                end
            end)
            task.wait(0.05)
        end
    end) end
end)
addButton("Pojazdy", "[19] Natychmiast Odwołaj Pojazd", function() if ReplicatedStorage.Network:FindFirstChild("EliminateCar") then ReplicatedStorage.Network.EliminateCar:FireServer() end end)
addButton("Pojazdy", "[20] Wysoki Skok Autem", function()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then v.Parent.PrimaryPart.Velocity = v.Parent.PrimaryPart.Velocity + Vector3.new(0, 90, 0) end
        end
    end)
end)
addButton("Pojazdy", "[21] Obróć Auto kołami do dołu", function()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then v.Parent.PrimaryPart.CFrame = v.Parent.PrimaryPart.CFrame * CFrame.Angles(0,0,0) end
        end
    end)
end)
addButton("Pojazdy", "[22] Odblokuj Limit Prędkości Gry", function() pcall(function() for _, v in pairs(workspace:GetDescendants()) do if v:IsA("VehicleSeat") then v.MaxSpeed = 150 end end end) end)
addButton("Pojazdy", "[23] Zniszcz koła w aucie", function() pcall(function() for _, v in pairs(workspace:GetDescendants()) do if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then for _, w in pairs(v.Parent:GetDescendants()) do if w.Name:lower():find("wheel") then w:Destroy() end end end end end) end)

-- ==========================================
-- 4. ANIMACJE PREMIUM (100% FIXED) (9 OPCJI)
-- ==========================================
addButton("Animacje Premium", "[24] AKTYWUJ: Jerk Tool / Flex", function() forcePlayAnimation(507371109) end)
addButton("Animacje Premium", "[25] AKTYWUJ: Take the L (Fortnite)", function() forcePlayAnimation(333833446) end)
addButton("Animacje Premium", "[26] AKTYWUJ: Scuba Viral Wave", function() forcePlayAnimation(333839256) end)
addButton("Animacje Premium", "[27] AKTYWUJ: Styl Zombie Walk", function() forcePlayAnimation(35654637) end)
addButton("Animacje Premium", "[28] AKTYWUJ: Taniec Hype", function() forcePlayAnimation(424907230) end)
addButton("Animacje Premium", "[29] AKTYWUJ: Salto w tył (Backflip)", function() forcePlayAnimation(303358334) end)
addButton("Animacje Premium", "[30] AKTYWUJ: Lewitacja / Medytacja", function() forcePlayAnimation(313331574) end)
addButton("Animacje Premium", "[31] AKTYWUJ: Chód Superbohatera", function() forcePlayAnimation(616095325) end)
addButton("Animacje Premium", "[32] WYŁĄCZ WSZYSTKIE ANIMACJE (RESET)", function() stopAllCustomAnimations() end)

-- ==========================================
-- 5. TELEPORT DZIAŁEK (15 OPCJI)
-- ==========================================
local pCoords = {
    {-484, 22, -153}, {-484, 22, -87}, {-484, 22, -18}, {-484, 22, 50}, {-484, 22, 118},
    {-411, 22, 169}, {-342, 22, 169}, {-253, 22, 169}, {-180, 22, 169}, {-105, 22, 169},
    {-28, 22, 169}, {46, 22, 169}, {118, 22, 169}, {189, 22, 169}, {262, 22, 169}
}
for i, coord in pairs(pCoords) do
    addButton("Teleport Działek", "[3"..(i+2).."] Teleport na Działkę nr " .. i, function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then Player.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(coord[1], coord[2], coord[3])) end
    end)
end

-- ==========================================
-- 6. TELEPORT LOKACJI (6 OPCJI)
-- ==========================================
local function tpl(cf) if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then Player.Character.HumanoidRootPart.CFrame = cf end end
addButton("Teleport Lokacji", "[48] Bank & Wnętrze Sejfu", function() tpl(CFrame.new(-22, 10, 52)) end)
addButton("Teleport Lokacji", "[49] Posterunek Policji i Areszt", function() tpl(CFrame.new(-42, 11, 28)) end)
addButton("Teleport Lokacji", "[50] Supermarket Spożywczy", function() tpl(CFrame.new(12, 10, 15)) end)
addButton("Teleport Lokacji", "[51] Dach Szpitala", function() tpl(CFrame.new(65, 25, -10)) end)
addButton("Teleport Lokacji", "[52] Tajny Bunkier Hakerski", function() tpl(CFrame.new(-265, -15, -145)) end)
addButton("Teleport Lokacji", "[53] Szkoła (Klasa Główna)", function() tpl(CFrame.new(-10, 10, -100)) end)

-- ==========================================
-- 7. TROLLE & OTOCZENIE (7 OPCJI)
-- ==========================================
addToggleButton("Trolle & Otoczenie", "[54] Wyświetl ESP (Szkielety Graczy)", "ESP", function(state)
    if state then
        _G.ESPTrack = RunService.Heartbeat:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if not p.Character.HumanoidRootPart:FindFirstChild("ESP") then
                        local b = Instance.new("BoxHandleAdornment", p.Character.HumanoidRootPart) b.Name = "ESP" b.Size = Vector3.new(4, 6, 4) b.Color3 = Color3.fromRGB(255,255,0) b.AlwaysOnTop = true b.Adornee = p.Character.HumanoidRootPart b.Transparency = 0.5
                    end
                end
            end
        end)
    else
        if _G.ESPTrack then _G.ESPTrack:Disconnect() end
        for _, p in pairs(Players:GetPlayers()) do pcall(function() p.Character.HumanoidRootPart.ESP:Destroy() end) end
    end
end)
addToggleButton("Trolle & Otoczenie", "[55] Przenikanie Przez Drzwi Sejfu", "SafeNoclip", function(state)
    if state then
        _G.SafeTrack = RunService.Stepped:Connect(function()
            for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name == "SafeDoor" or v.Name == "BankWall") then v.CanCollide = false v.Transparency = 0.4 end end
        end)
    else
        if _G.SafeTrack then _G.SafeTrack:Disconnect() end
        for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name == "SafeDoor" or v.Name == "BankWall") then v.CanCollide = true v.Transparency = 0 end end
    end
end)
addToggleButton("Trolle & Otoczenie", "[56] Tryb Jasności (Fullbright)", "Fullbright", function(state)
    if state then Lighting.Brightness = 2 Lighting.ClockTime = 14 Lighting.FogEnd = 999999 else Lighting.Brightness = 1 Lighting.ClockTime = 12 end
end)
addButton("Trolle & Otoczenie", "[57] Usuń Wszystkie Drzwi z Mapy", function() for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name:lower():find("door") or v.Name:lower():find("gate")) then v:Destroy() end end end)
addToggleButton("Trolle & Otoczenie", "[58] Auto-Spam Reklamą na Czacie", "AutoChat", function(state)
    if state then task.spawn(function() while Toggles.AutoChat do ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("★ SHINYHUB V7 OWNED SERVER ★", "All") task.wait(3) end end) end
end)
addButton("Trolle & Otoczenie", "[59] Usuń Lampy Uliczne (Ciemność)", function() for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and v.Name:lower():find("light") then v:Destroy() end end end)
addButton("Trolle & Otoczenie", "[60] Crash Świateł w Domach", function() pcall(function() for _, v in pairs(workspace:GetDescendants()) do if v:IsA("RemoteEvent") and v.Name:find("Light") then v:FireServer(false) end end end) end)

-- ==========================================
-- PRZYCISK ZAMKNIĘCIA INTERFEJSU
-- ==========================================
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 160, 0, 41)
CloseBtn.Position = UDim2.new(0, 0, 1, -41)
CloseBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "WYŁĄCZ SHINYHUB"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
CloseBtn.MouseButton1Click:Connect(function()
    -- Reset wszystkich aktywnych pętli i procesów
    stopAllCustomAnimations()
    for k, _ in pairs(Toggles) do Toggles[k] = false end
    if _G.NoclipLoop then _G.NoclipLoop:Disconnect() end
    if _G.BVel then _G.BVel:Destroy() _G.BGyr:Destroy() end
    if _G.JumpCon then _G.JumpCon:Disconnect() end
    if _G.ClickCon then _G.ClickCon:Disconnect() end
    if _G.ESPTrack then _G.ESPTrack:Disconnect() end
    if _G.SafeTrack then _G.SafeTrack:Disconnect() end
    ScreenGui:Destroy()
end)
