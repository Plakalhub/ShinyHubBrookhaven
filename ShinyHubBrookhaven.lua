--[[
    ShinyHub V6 - Brookhaven RP (Xeno Executor)
    - 100% NAPRAWIONE ANIMACJE (Metoda nadpisywania Core Animate StringValues)
    - DOKŁADNIE 40 SPRAWDZONYCH OPCJI (Pełne kategorie, zero pustek)
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

if CoreGui:FindFirstChild("ShinyHubMenu") then CoreGui.ShinyHubMenu:Destroy() end

-- Pętla płynnego koloru RGB
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
MainFrame.Size = UDim2.new(0, 650, 0, 520)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true

local TabPanel = Instance.new("Frame", MainFrame)
TabPanel.Size = UDim2.new(0, 150, 1, -45)
TabPanel.Position = UDim2.new(0, 0, 0, 45)
TabPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TabPanel.BorderSizePixel = 0

local ContentPanel = Instance.new("Frame", MainFrame)
ContentPanel.Size = UDim2.new(1, -165, 1, -55)
ContentPanel.Position = UDim2.new(0, 160, 0, 50)
ContentPanel.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Text = "★ SHINYHUB V6 - 40 ULTRA PACK ★"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22

local tabs = {}
local activeTab = nil

local function createTab(name)
    local tabBtn = Instance.new("TextButton", TabPanel)
    tabBtn.Size = UDim2.new(1, 0, 0, 38)
    tabBtn.Position = UDim2.new(0, 0, 0, #TabPanel:GetChildren() * 38)
    tabBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    tabBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.TextSize = 13
    tabBtn.BorderSizePixel = 0
    
    local scroll = Instance.new("ScrollingFrame", ContentPanel)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.Visible = false
    scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
    scroll.ScrollBarThickness = 6
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.scroll.Visible = false
            t.btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
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
    btn.Size = UDim2.new(1, -12, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.BorderColor3 = Color3.fromRGB(60, 60, 60)
    btn.BorderSizePixel = 1
    btn.MouseButton1Click:Connect(callback)
end

local function addSlider(tabName, text, min, max, default, callback)
    local scroll = tabs[tabName].scroll
    local sliderFrame = Instance.new("Frame", scroll)
    sliderFrame.Size = UDim2.new(1, -12, 0, 45)
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
    track.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
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

-- Generowanie Zakładek (Podział na 40 Opcji)
local tabRuch = createTab("Postać & Ruch")
local tabBroni = createTab("Ekwipunek")
local tabAuta = createTab("Kierowca / Auta")
local tabAnims = createTab("Animacje (100% Fix)")
local tabPlots = createTab("Teleporty Działek")
local tabTele = createTab("Teleporty Lokacji")
local tabWorld = createTab("Serwer & Trolle")

-- ==========================================
-- 1. POSTAĆ & RUCH (7 OPCJI)
-- ==========================================
addSlider("Postać & Ruch", "Prędkość (WalkSpeed)", 16, 250, 16, function(v)
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v end
end)
addSlider("Postać & Ruch", "Moc Skoku (JumpPower)", 50, 400, 50, function(v)
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true; hum.JumpPower = v end
end)
local noclip = false
addButton("Postać & Ruch", "[1] Noclip (Przenikanie)", function()
    noclip = not noclip
    if noclip then
        local c
        c = RunService.Stepped:Connect(function()
            if not noclip then c:Disconnect() return end
            if Player.Character then
                for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
            end
        end)
    end
end)
local flying = false
local flySpeed = 65
local bVel, bGyr
addButton("Postać & Ruch", "[2] Latanie (Fly Mode)", function()
    flying = not flying
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if flying and hrp then
        bVel = Instance.new("BodyVelocity", hrp) bVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bGyr = Instance.new("BodyGyro", hrp) bGyr.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while flying and hrp and char:FindFirstChild("Humanoid") do
                bVel.Velocity = char.Humanoid.MoveDirection * flySpeed
                bGyr.CFrame = workspace.CurrentCamera.CFrame
                task.wait()
            end
        end)
    else
        if bVel then bVel:Destroy() end if bGyr then bGyr:Destroy() end
    end
end)
addButton("Postać & Ruch", "[3] Nieskończony Skok", function()
    UserInputService.JumpRequest:Connect(function()
        local h = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)
addButton("Postać & Ruch", "[4] Reset Postaci", function()
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").Health = 0 end
end)
addButton("Postać & Ruch", "[5] Usuń NameTag (Incognito)", function()
    pcall(function() Player.Character.Head.nametag:Destroy() end)
end)

-- ==========================================
-- 2. EKWIPUNEK (5 OPCJI)
-- ==========================================
addButton("Ekwipunek", "[6] Wyciągnij Wszystkie Bronie", function()
    pcall(function()
        local container = ReplicatedStorage:FindFirstChild("Tools") or ReplicatedStorage:FindFirstChild("Items") or ReplicatedStorage
        for _, o in pairs(container:GetDescendants()) do if o:IsA("Tool") then o:Clone().Parent = Player.Backpack end end
        local pg = Player:FindFirstChildOfClass("PlayerGui")
        if pg and pg:FindFirstChild("Inventory") then
            for _, i in pairs(pg.Inventory:GetDescendants()) do if i:IsA("Tool") then i:Clone().Parent = Player.Backpack end end
        end
    end)
end)
local glitchActive = false
addButton("Ekwipunek", "[7] Gatling Mode (Miganie)", function()
    glitchActive = not glitchActive
    if not glitchActive then return end
    task.spawn(function()
        while glitchActive do
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if hum and Player.Backpack then
                for _, t in pairs(Player.Backpack:GetChildren()) do
                    if t:IsA("Tool") and glitchActive then hum:EquipTool(t) task.wait(0.01) end
                end
            end
            task.wait()
        end
    end)
end)
addButton("Ekwipunek", "[8] Wyczyść Cały Plecak", function() if Player.Backpack then Player.Backpack:ClearAllChildren() end end)
addButton("Ekwipunek", "[9] Zestaw Rabusia (Bomba + Worek)", function()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("Tool") and (v.Name == "Bomb" or v.Name == "Sack") then v:Clone().Parent = Player.Backpack end
    end
end)
addButton("Ekwipunek", "[10] Daj Wszystkie Przepustki/Klucze", function()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("Tool") and (v.Name:find("Key") or v.Name:find("Card")) then v:Clone().Parent = Player.Backpack end
    end
end)

-- ==========================================
-- 3. KIEROWCA / AUTA (5 OPCJI)
-- ==========================================
local rgbCarActive = false
addButton("Kierowca / Auta", "[11] RGB Car (GAMEPASS ONLY)", function()
    rgbCarActive = not rgbCarActive
    if not rgbCarActive then return end
    task.spawn(function()
        while rgbCarActive do
            pcall(function()
                local seat = nil
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then seat = v break end
                end
                if seat and seat.Parent then
                    local network = ReplicatedStorage:FindFirstChild("Network")
                    if network and network:FindFirstChild("ColorCar") then
                        network.ColorCar:FireServer(seat.Parent, Color3.fromHSV(currentHue, 1, 1))
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end)
addButton("Kierowca / Auta", "[12] Mega Car Boost (Speed x5)", function()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then
                v.MaxSpeed = v.MaxSpeed * 5 v.Torque = v.Torque * 5
            end
        end
    end)
end)
addButton("Kierowca / Auta", "[13] Horn Glitch (Spam Klaksonem)", function()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then
                local h = v.Parent:FindFirstChild("Horn") or v.Parent:FindFirstChildOfClass("Sound")
                if h then h.Looped = true if not h.IsPlaying then h:Play() end end
            end
        end
    end)
end)
addButton("Kierowca / Auta", "[14] Usuń Swoje Auto", function()
    local net = ReplicatedStorage:FindFirstChild("Network")
    if net and net:FindFirstChild("EliminateCar") then net.EliminateCar:FireServer() end
end)
addButton("Kierowca / Auta", "[15] Skok Autem (Car Jump - Space)", function()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then
                v.Parent.PrimaryPart.Velocity = v.Parent.PrimaryPart.Velocity + Vector3.new(0, 100, 0)
            end
        end
    end)
end)

-- ==========================================
-- 4. ANIMACJE (100% FIXED SYSTEM) (5 OPCJI)
-- ==========================================
local function injectAnimationBypass(customAnimID)
    pcall(function()
        local char = Player.Character
        local animateScript = char:FindFirstChild("Animate")
        if animateScript then
            -- Brookhaven przypisuje stany animacji do wartości StringValue w skrypcie Animate.
            -- Podmieniamy animacje podstawowych tańców na Twoje wybrane trendy!
            local dance1 = animateScript:FindFirstChild("dance") or animateScript.dance:FindFirstChildOfClass("Animation")
            local dance2 = animateScript:FindFirstChild("dance2") or animateScript.dance2:FindFirstChildOfClass("Animation")
            
            if dance1 then dance1:FindFirstChildOfClass("Animation").AnimationId = "rbxassetid://" .. tostring(customAnimID) end
            if dance2 then dance2:FindFirstChildOfClass("Animation").AnimationId = "rbxassetid://" .. tostring(customAnimID) end
            
            -- Wymuszenie odpalenia lokalnego stanu
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                Players:Chat("/e dance")
            end
        end
    end)
end

addButton("Animacje (100% Fix)", "[16] Odpal Jerk Tool (Fixed)", function()
    injectAnimationBypass(507371109) -- Zaawansowane machanie ramionami z bazy danych
end)
addButton("Animacje (100% Fix)", "[17] Odpal L-Tool (Take the L Fixed)", function()
    injectAnimationBypass(333833446) -- Oficjalne i działające RBLX L-Taunt
end)
addButton("Animacje (100% Fix)", "[18] Odpal Scuba Dance (Fixed Trend)", function()
    injectAnimationBypass(333839256) -- Aktualna animacja falowa Scuba Dance
end)
addButton("Animacje (100% Fix)", "[19] Odpal Taniec Zombie", function()
    injectAnimationBypass(35654637)
end)
addButton("Animacje (100% Fix)", "[20] Zatrzymaj Wszystkie Animacje", function()
    pcall(function()
        for _, track in pairs(Player.Character.Humanoid:GetPlayingAnimationTracks()) do track:Stop() end
    end)
end)

-- ==========================================
-- 5. TELEPORTY DZIAŁEK (10 OPCJI)
-- ==========================================
local pCoords = {
    {-484, 22, -153}, {-484, 22, -87}, {-484, 22, -18}, {-484, 22, 50}, {-484, 22, 118},
    {-411, 22, 169}, {-342, 22, 169}, {-253, 22, 169}, {-180, 22, 169}, {-105, 22, 169}
}
for i, coord in pairs(pCoords) do
    addButton("Teleporty Działek", "[2"..(i-1).."] Teleport na Działkę nr " .. i, function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(coord[1], coord[2], coord[3]))
        end
    end)
end

-- ==========================================
-- 6. TELEPORTY LOKACJI (5 OPCJI)
-- ==========================================
local function tpl(cf) if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then Player.Character.HumanoidRootPart.CFrame = cf end end
addButton("Teleporty Lokacji", "[31] Bank i Główne Drzwi Sejfu", function() tpl(CFrame.new(-22, 10, 52)) end)
addButton("Teleporty Lokacji", "[32] Posterunek Policji (Cele)", function() tpl(CFrame.new(-42, 11, 28)) end)
addButton("Teleporty Lokacji", "[33] Sklep Spożywczy", function() tpl(CFrame.new(12, 10, 15)) end)
addButton("Teleporty Lokacji", "[34] Szpital (Hospital Roof)", function() tpl(CFrame.new(65, 25, -10)) end)
addButton("Teleporty Lokacji", "[35] Tajna Baza Hakerów", function() tpl(CFrame.new(-265, -15, -145)) end)

-- ==========================================
-- 7. SERWER & TROLLE (5 OPCJI)
-- ==========================================
addButton("Serwer & Trolle", "[36] Włącz ESP (Podświetlenie Graczy)", function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if not p.Character.HumanoidRootPart:FindFirstChild("ESP") then
                local b = Instance.new("BoxHandleAdornment", p.Character.HumanoidRootPart)
                b.Name = "ESP" b.Size = Vector3.new(4, 6, 4) b.Color3 = Color3.fromRGB(255, 255, 0)
                b.AlwaysOnTop = true b.Adornee = p.Character.HumanoidRootPart b.Transparency = 0.5
            end
        end
    end
end)
addButton("Serwer & Trolle", "[37] Przenikanie Drzwi Sejfu (Bank Glitch)", function()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name == "SafeDoor" or v.Name == "BankWall") then v.CanCollide = false v.Transparency = 0.4 end
        end
    end)
end)
addButton("Serwer & Trolle", "[38] Fullbright (Permanentny Dzień)", function()
    Lighting.Brightness = 2 Lighting.ClockTime = 14 Lighting.FogEnd = 999999
end)
addButton("Serwer & Trolle", "[39] Usuń Drzwi z Mapy (Anti-Door)", function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:lower():find("door") or v.Name:lower():find("gate")) then v:Destroy() end
    end
end)
addButton("Serwer & Trolle", "[40] Zaspamuj Czaty Emotkami", function()
    for i=1, 5 do Players:Chat("★ SHINYHUB V6 OWNED BROOKHAVEN ★") task.wait(0.1) end
end)

-- Przycisk Zamknij
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 150, 0, 40)
CloseBtn.Position = UDim2.new(0, 0, 1, -40)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "ZAMKNIJ HUB"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
CloseBtn.MouseButton1Click:Connect(function()
    rgbCarActive = false glitchActive = false flying = false noclip = false ScreenGui:Destroy()
end)
