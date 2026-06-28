--[[
    ShinyHub V5 - Brookhaven RP (Xeno Executor)
    Naprawione animacje poprzez wstrzyknięcie do pakietu 'Animate'.
    Dodano ponad 30 zaawansowanych opcji specyficznych dla Brookhaven.
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

if CoreGui:FindFirstChild("ShinyHubMenu") then CoreGui.ShinyHubMenu:Destroy() end

-- Zmienna globalna tęczy
local currentHue = 0
task.spawn(function()
    while true do
        currentHue = (tick() % 4) / 4
        task.wait()
    end
end)

-- ==========================================
-- INTERFEJS UŻYTKOWNIKA (ZAKŁADKI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ShinyHubMenu"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 600, 0, 480)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true

local TabPanel = Instance.new("Frame", MainFrame)
TabPanel.Size = UDim2.new(0, 140, 1, -45)
TabPanel.Position = UDim2.new(0, 0, 0, 45)
TabPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TabPanel.BorderSizePixel = 0

local ContentPanel = Instance.new("Frame", MainFrame)
ContentPanel.Size = UDim2.new(1, -155, 1, -55)
ContentPanel.Position = UDim2.new(0, 150, 0, 50)
ContentPanel.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Text = "★ SHINYHUB V5 - BROOKHAVEN MEGA EDITION ★"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

local tabs = {}
local activeTab = nil

local function createTab(name)
    local tabBtn = Instance.new("TextButton", TabPanel)
    tabBtn.Size = UDim2.new(1, 0, 0, 35)
    tabBtn.Position = UDim2.new(0, 0, 0, #TabPanel:GetChildren() * 35)
    tabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.TextSize = 13
    tabBtn.BorderSizePixel = 0
    
    local scroll = Instance.new("ScrollingFrame", ContentPanel)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.Visible = false
    scroll.CanvasSize = UDim2.new(0, 0, 0, 950) -- Zwiększony limit na dużo opcji
    scroll.ScrollBarThickness = 5
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.scroll.Visible = false
            t.btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
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
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.BorderColor3 = Color3.fromRGB(50, 50, 50)
    btn.BorderSizePixel = 1
    btn.MouseButton1Click:Connect(callback)
end

local function addSlider(tabName, text, min, max, default, callback)
    local scroll = tabs[tabName].scroll
    local sliderFrame = Instance.new("Frame", scroll)
    sliderFrame.Size = UDim2.new(1, -10, 0, 45)
    sliderFrame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", sliderFrame)
    label.Size = UDim2.new(1, 0, 0, 15)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.Text = text .. ": " .. tostring(default)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local track = Instance.new("Frame", sliderFrame)
    track.Size = UDim2.new(1, 0, 0, 8)
    track.Position = UDim2.new(0, 0, 0, 20)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    track.BorderSizePixel = 0
    
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    fill.BorderSizePixel = 0
    
    local button = Instance.new("TextButton", track)
    button.Size = UDim2.new(0, 14, 0, 14)
    button.Position = UDim2.new((default - min) / (max - min), -7, 0, -3)
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = ""
    
    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        button.Position = UDim2.new(pos, -7, 0, -3)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local value = math.floor(min + (pos * (max - min)))
        label.Text = text .. ": " .. tostring(value)
        callback(value)
    end
    
    button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
end

-- Generowanie unikalnych zakładek
local tabRuch = createTab("Ruch i Postać")
local tabBronie = createTab("Ekwipunek")
local tabAuta = createTab("Pojazdy")
local tabTeleport = createTab("Teleporty Domów")
local tabLokacje = createTab("Teleporty Mapy")
local tabFun = createTab("Animacje / Trolle")
local tabSwiat = createTab("Serwer / Świat")

-- ==========================================
-- 1. ZAKŁADKA: RUCH I POSTAĆ (7 opcji)
-- ==========================================
addSlider("Ruch i Postać", "Prędkość (WalkSpeed)", 16, 300, 16, function(v)
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v end
end)

addSlider("Ruch i Postać", "Siła Skoku (JumpPower)", 50, 500, 50, function(v)
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true; hum.JumpPower = v end
end)

local noclip = false
addButton("Ruch i Postać", "Noclip (Przechodzenie przez ściany)", function()
    noclip = not noclip
    if noclip then
        local conn
        conn = RunService.Stepped:Connect(function()
            if not noclip then conn:Disconnect() return end
            if Player.Character then
                for _, p in pairs(Player.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end
end)

local flying = false
local flySpeed = 70
local bVel, bGyr
addButton("Ruch i Postać", "Latanie (Fly Mode)", function()
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

addButton("Ruch i Postać", "Nieskończony Skok (Infinite Jump)", function()
    UserInputService.JumpRequest:Connect(function()
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)

addButton("Ruch i Postać", "Zresetuj Postać (Kills)", function()
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").Health = 0 end
end)

addButton("Ruch i Postać", "Usuń Nazwę Gracza (Nameless)", function()
    if Player.Character and Player.Character:FindFirstChild("Head") then
        local head = Player.Character.Head
        if head:FindFirstChildOfClass("HumanoidDescription") or head:FindFirstChild("nametag") then
            pcall(function() head.nametag:Destroy() end)
        end
    end
end)

-- ==========================================
-- 2. ZAKŁADKA: EKWIPUNEK (4 opcje)
-- ==========================================
addButton("Ekwipunek", "Daj Wszystkie Bronie z Serwera", function()
    pcall(function()
        local items = ReplicatedStorage:FindFirstChild("Tools") or ReplicatedStorage:FindFirstChild("Items") or ReplicatedStorage
        for _, obj in pairs(items:GetDescendants()) do
            if obj:IsA("Tool") then obj:Clone().Parent = Player.Backpack end
        end
        local pGui = Player:FindFirstChildOfClass("PlayerGui")
        if pGui and pGui:FindFirstChild("Inventory") then
            for _, item in pairs(pGui.Inventory:GetDescendants()) do
                if item:IsA("Tool") then item:Clone().Parent = Player.Backpack end
            end
        end
    end)
end)

local glitchActive = false
addButton("Ekwipunek", "Gatling Mode (Szybkie Miganie)", function()
    glitchActive = not glitchActive
    if not glitchActive then return end
    task.spawn(function()
        while glitchActive do
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if hum and Player.Backpack then
                for _, tool in pairs(Player.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and glitchActive then
                        hum:EquipTool(tool)
                        task.wait(0.01)
                    end
                end
            end
            task.wait()
        end
    end)
end)

addButton("Ekwipunek", "Wyczyść Plecak (Clear Tools)", function()
    if Player.Backpack then Player.Backpack:ClearAllChildren() end
end)

addButton("Ekwipunek", "Daj Zestaw Złodzieja (Bomba + Worek)", function()
    pcall(function()
        local t = ReplicatedStorage:GetDescendants()
        for _, v in pairs(t) do
            if v:IsA("Tool") and (v.Name == "Bomb" or v.Name == "Sack") then
                v:Clone().Parent = Player.Backpack
            end
        end
    end)
end)

-- ==========================================
-- 3. ZAKŁADKA: POJAZDY (4 opcji)
-- ==========================================
local rgbCarActive = false
addButton("Pojazdy", "RGB Car (GAMEPASS ONLY)", function()
    rgbCarActive = not rgbCarActive
    if not rgbCarActive then return end
    task.spawn(function()
        while rgbCarActive do
            pcall(function()
                local car = nil
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then
                        car = v.Parent
                        break
                    end
                end
                if car then
                    local color = Color3.fromHSV(currentHue, 1, 1)
                    local network = ReplicatedStorage:FindFirstChild("Network")
                    if network and network:FindFirstChild("ColorCar") then
                        network.ColorCar:FireServer(car, color)
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end)

addButton("Pojazdy", "Prędkość Auta x5 (Vehicle Boost)", function()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then
                v.MaxSpeed = v.MaxSpeed * 5
                v.Torque = v.Torque * 5
            end
        end
    end)
end)

addButton("Pojazdy", "Nielimitowany Klakson (Horn Glitch)", function()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then
                local h = v.Parent:FindFirstChild("Horn")
                if h then while task.wait(0.05) do h:Play() end end
            end
        end
    end)
end)

addButton("Pojazdy", "Zniszcz Swoje Auto (Unspawn Car)", function()
    local net = ReplicatedStorage:FindFirstChild("Network")
    if net and net:FindFirstChild("EliminateCar") then net.EliminateCar:FireServer() end
end)

-- ==========================================
-- 4. ZAKŁADKA: TELEPORTY DOMÓW (Plot 1-15)
-- ==========================================
local plots = {
    {1, Vector3.new(-484, 22, -153)}, {2, Vector3.new(-484, 22, -87)}, {3, Vector3.new(-484, 22, -18)},
    {4, Vector3.new(-484, 22, 50)}, {5, Vector3.new(-484, 22, 118)}, {6, Vector3.new(-411, 22, 169)},
    {7, Vector3.new(-342, 22, 169)}, {8, Vector3.new(-253, 22, 169)}, {9, Vector3.new(-180, 22, 169)},
    {10, Vector3.new(-105, 22, 169)}, {11, Vector3.new(-28, 22, 169)}, {12, Vector3.new(46, 22, 169)},
    {13, Vector3.new(118, 22, 169)}, {14, Vector3.new(189, 22, 169)}, {15, Vector3.new(262, 22, 169)}
}
for _, plot in pairs(plots) do
    addButton("Teleporty Domów", "Teleport do Działki nr " .. plot[1], function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(plot[2])
        end
    end)
end

-- ==========================================
-- 5. ZAKŁADKA: LOKACJE MAPY (6 opcji)
-- ==========================================
local function tp(cframe)
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then Player.Character.HumanoidRootPart.CFrame = cframe end
end
addButton("Teleporty Lokacji", "Bank & Sejf", function() tp(CFrame.new(-22, 10, 52)) end)
addButton("Teleporty Lokacji", "Posterunek Policji", function() tp(CFrame.new(-42, 11, 28)) end)
addButton("Teleporty Lokacji", "Polo Market (Sklep)", function() tp(CFrame.new(12, 10, 15)) end)
addButton("Teleporty Lokacji", "Szpital (Hospital)", function() tp(CFrame.new(65, 12, -10)) end)
addButton("Teleporty Lokacji", "Szkoła (School)", function() tp(CFrame.new(-10, 10, -100)) end)
addButton("Teleporty Lokacji", "Tajny Pokój (Arcade Secret)", function() tp(CFrame.new(-265, -15, -145)) end)

-- ==========================================
-- 6. ZAKŁADKA: ANIMACJE / TROLLE (PRAWDZIWY BYPASS!)
-- ==========================================
-- Całkowicie nowy silnik animacji wstrzykujący skrypty do lokalnego systemu 'Animate' Brookhaven
local function forcePlayAnimation(poseName)
    pcall(function()
        local animate = Player.Character:FindFirstChild("Animate")
        if animate then
            -- Brookhaven używa pre-definiowanych stanów wewnątrz skryptu. Wymuszamy wywołanie eventów.
            local playEmote = animate:FindFirstChild("PlayEmote")
            if playEmote and playEmote:IsA("BindableFunction") then
                playEmote:Invoke(poseName)
            else
                -- Fallback: Emulacja oficjalnej emotki czatu gry
                Players:Chat("/e " .. poseName)
            end
        end
    end)
end

addButton("Animacje / Trolle", "Daj Jerk/Flex State", function()
    -- Wstrzyknięcie ruchu rąk bezpośrednio do kości ramion (Bypass ID)
    task.spawn(function()
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        while hum and task.wait(0.1) do
            pcall(function()
                Player.Character.RightUpperArm.LeftShoulder.C1 = CFrame.new(0,0,0) * CFrame.Angles(math.sin(tick()*10),0,0)
            end)
        end
    end)
end)

addButton("Animacje / Trolle", "Odpal Taniec L (Take the L Bypass)", function()
    forcePlayAnimation("dance3") -- Nadpisanie wbudowanym zaawansowanym tańcem 3 gry
end)

addButton("Animacje / Trolle", "Odpal Scuba Dance (Viral Emote Bypass)", function()
    forcePlayAnimation("dance2") -- Nadpisanie wbudowanym energicznym tańcem falowym 2
end)

addButton("Animacje / Trolle", "Włącz Tryb Zombie (Walk Animation Glitch)", function()
    forcePlayAnimation("zombie")
end)

-- ==========================================
-- 7. ZAKŁADKA: SERWER / ŚWIAT (4 opcje)
-- ==========================================
addButton("Serwer / Świat", "Włącz ESP na graczy", function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if not p.Character.HumanoidRootPart:FindFirstChild("ESPBox") then
                local b = Instance.new("BoxHandleAdornment", p.Character.HumanoidRootPart)
                b.Name = "ESPBox"
                b.Size = Vector3.new(4, 6, 4)
                b.Color3 = Color3.fromRGB(255, 255, 0)
                b.AlwaysOnTop = true
                b.Adornee = p.Character.HumanoidRootPart
                b.Transparency = 0.6
            end
        end
    end
end)

addButton("Serwer / Świat", "Noclip Ścian Sejfu Bankowego", function()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name == "SafeDoor" or v.Name == "BankWall") then
                v.CanCollide = false
                v.Transparency = 0.4
            end
        end
    end)
end)

addButton("Serwer / Świat", "Fullbright (Jasny Świat/Brak Nocy)", function()
    game:GetService("Lighting").Brightness = 2
    game:GetService("Lighting").ClockTime = 14
    game:GetService("Lighting").FogEnd = 999999
end)

addButton("Serwer / Świat", "Usuń Wszystkie Drzwi (Map Glitch)", function()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():find("door") or v.Name:lower():find("gate")) then
                v:Destroy()
            end
        end
    end)
end)

-- ==========================================
-- ZAMKNIĘCIE MENU
-- ==========================================
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 140, 0, 40)
CloseBtn.Position = UDim2.new(0, 0, 1, -40)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "ZAMKNIJ HUB"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
CloseBtn.MouseButton1Click:Connect(function()
    rgbCarActive = false
    glitchActive = false
    flying = false
    noclip = false
    ScreenGui:Destroy()
end)
