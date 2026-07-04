--[[
    ShinyHub V5 - Brookhaven RP Mobile, Fly & Minimize Fix Edition (2026)
    - RESPONSIVE GUI: Dopasowane do telefonów (Scale-based).
    - FLY FIX: Latanie 3D (kierunek kamery góra/dół).
    - RP NAME FIX: Zaktualizowano powitanie o ~itzz_dekl1.
    - MINIMIZE SYSTEM: Przycisk [−] i [+] do zwijania interfejsu w mały pasek.
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- AUTOMATYCZNA ZMIANA RP NAME (ZAKTUALIZOWANA)
task.spawn(function()
    local welcomeText = "Welcome, thank you for using this hub ~majku ~itzz_dekl1"
    local rpNameEvent = ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("SetIdentity")
    if rpNameEvent then
        rpNameEvent:FireServer(welcomeText, "Gold", "Hub Users")
    else
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and v.Name == "SetIdentity" then
                v:FireServer(welcomeText, "Gold", "Hub Users")
                break
            end
        end
    end
end)

-- Czyszczenie starego GUI
if CoreGui:FindFirstChild("ShinyHubMenu") then 
    pcall(function() CoreGui.ShinyHubMenu:Destroy() end) 
end

-- Stan przełączników (Toggles)
local Toggles = {
    Noclip = false, Fly = false, InfJump = false, Gatling = false,
    RGB = false, Horn = false, ESP = false, SafeNoclip = false, Fullbright = false
}

-- Stan włączonych animacji
local ActiveAnimations = {}

local currentHue = 0
task.spawn(function()
    while true do
        currentHue = (tick() % 4) / 4
        task.wait()
    end
end)

-- SYSTEM ANIMACJI ON/OFF
local function toggleAnimation(animID, btn)
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if ActiveAnimations[animID] then
        pcall(function()
            ActiveAnimations[animID]:Stop()
            ActiveAnimations[animID]:Destroy()
        end)
        ActiveAnimations[animID] = nil
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        return
    end
    
    for id, track in pairs(ActiveAnimations) do
        pcall(function() track:Stop() track:Destroy() end)
        ActiveAnimations[id] = nil
    end
    
    pcall(function()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. tostring(animID)
        
        local track = hum:LoadAnimation(anim)
        track.Priority = Enum.AnimationPriority.Action
        track.Looped = true
        track:Play()
        
        ActiveAnimations[animID] = track
        btn.BackgroundColor3 = Color3.fromRGB(25, 45, 25)
        btn.TextColor3 = Color3.fromRGB(120, 255, 120)
    end)
end

local function stopAllAnimations()
    for id, track in pairs(ActiveAnimations) do
        pcall(function() track:Stop() track:Destroy() end)
        ActiveAnimations[id] = nil
    end
    pcall(function()
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
    end)
end

-- ==========================================
-- INTERFEJS GRAFICZNY (ZOPTYMALIZOWANY POD TELEFONY)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShinyHubMenu"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

-- GŁÓWNY PANEL HUB-a
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0.55, 0, 0.65, 0)
MainFrame.Position = UDim2.new(0.22, 0, 0.17, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
MainFrame.BorderSizePixel = 2

-- MAŁY PASEK MINIMALIZACJI (Ukryty na starcie)
local MiniFrame = Instance.new("Frame", ScreenGui)
MiniFrame.Size = UDim2.new(0.18, 0, 0.08, 0)
MiniFrame.Position = UDim2.new(0.02, 0, 0.05, 0)
MiniFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MiniFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
MiniFrame.BorderSizePixel = 2
MiniFrame.Visible = false

-- Dotykowe Przesuwanie dla obu paneli (Mobile Friendly)
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(MainFrame)
makeDraggable(MiniFrame)

-- Zawartość Małego Paska (Plus Button)
local MiniTitle = Instance.new("TextLabel", MiniFrame)
MiniTitle.Size = UDim2.new(0.75, 0, 1, 0)
MiniTitle.BackgroundTransparency = 1
MiniTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniTitle.Text = " ShinyHub"
MiniTitle.Font = Enum.Font.SourceSansBold
MiniTitle.TextScaled = true
MiniTitle.TextXAlignment = Enum.TextXAlignment.Left

local MaximizeBtn = Instance.new("TextButton", MiniFrame)
MaximizeBtn.Size = UDim2.new(0.25, 0, 1, 0)
MaximizeBtn.Position = UDim2.new(0.75, 0, 0, 0)
MaximizeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
MaximizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
MaximizeBtn.Text = "+"
MaximizeBtn.Font = Enum.Font.SourceSansBold
MaximizeBtn.TextScaled = true
MaximizeBtn.BorderSizePixel = 0

MaximizeBtn.MouseButton1Click:Connect(function()
    MiniFrame.Visible = false
    MainFrame.Visible = true
end)

-- Zawartość Głównego Menu
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(0.9, 0, 0.1, 0)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Text = "★ SHINYHUB V5 - MOBILE ★"
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true

-- Przycisk Minus do chowania menu
local MinimizeBtn = Instance.new("TextButton", MainFrame)
MinimizeBtn.Size = UDim2.new(0.1, 0, 0.1, 0)
MinimizeBtn.Position = UDim2.new(0.9, 0, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 160, 0)
MinimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
MinimizeBtn.Text = "−"
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextScaled = true
MinimizeBtn.BorderSizePixel = 0

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniFrame.Visible = true
end)

local TabPanel = Instance.new("Frame", MainFrame)
TabPanel.Size = UDim2.new(0.28, 0, 0.82, 0)
TabPanel.Position = UDim2.new(0, 0, 0.1, 0)
TabPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TabPanel.BorderSizePixel = 0

local ContentPanel = Instance.new("Frame", MainFrame)
ContentPanel.Size = UDim2.new(0.70, 0, 0.88, 0)
ContentPanel.Position = UDim2.new(0.29, 0, 0.11, 0)
ContentPanel.BackgroundTransparency = 1

local tabs = {}
local activeTab = nil
local tabCount = 0

local function createTab(name)
    local tabBtn = Instance.new("TextButton", TabPanel)
    tabBtn.Size = UDim2.new(1, 0, 0, 30)
    tabBtn.Position = UDim2.new(0, 0, 0, tabCount * 30)
    tabBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.TextSize = 11
    tabBtn.BorderSizePixel = 0
    tabCount = tabCount + 1
    
    local scroll = Instance.new("ScrollingFrame", ContentPanel)
    scroll.Size = UDim2.new(1, -5, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.Visible = false
    scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
    scroll.ScrollBarThickness = 3
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.scroll.Visible = false
            t.btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
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
    btn.Size = UDim2.new(1, -5, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 12
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(60, 60, 60)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

local function addAnimButton(tabName, text, animID)
    local scroll = tabs[tabName].scroll
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -5, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(60, 60, 60)
    btn.MouseButton1Click:Connect(function() toggleAnimation(animID, btn) end)
end

local function addToggleButton(tabName, text, toggleKey, callback)
    local scroll = tabs[tabName].scroll
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -5, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
    btn.TextColor3 = Color3.fromRGB(255, 120, 120)
    btn.Text = text .. " [OFF]"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    
    btn.MouseButton1Click:Connect(function()
        Toggles[toggleKey] = not Toggles[toggleKey]
        if Toggles[toggleKey] then
            btn.BackgroundColor3 = Color3.fromRGB(25, 45, 25)
            btn.TextColor3 = Color3.fromRGB(120, 255, 120)
            btn.Text = text .. " [ON]"
        else
            btn.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
            btn.TextColor3 = Color3.fromRGB(255, 120, 120)
            btn.Text = text .. " [OFF]"
        end
        pcall(callback, Toggles[toggleKey])
    end)
end

-- Zakładki
local tabMovement = createTab("Ruch")
local tabCombat = createTab("Ekwipunek")
local tabCars = createTab("Pojazdy")
local tabAnims = createTab("Animacje")
local tabTeleport = createTab("Teleport")
local tabVisuals = createTab("Wizualne")

-- 1. POSTAĆ & RUCH
addButton("Ruch", "Super Bieg (WalkSpeed 100)", function() if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 100 end end)
addButton("Ruch", "Mega Skok (JumpPower 150)", function() local h = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") if h then h.UseJumpPower = true h.JumpPower = 150 end end)
addToggleButton("Ruch", "Przenikanie (Noclip)", "Noclip", function(state)
    if state then
        _G.NoclipLoop = RunService.Stepped:Connect(function()
            if Player.Character then for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        end)
    else if _G.NoclipLoop then _G.NoclipLoop:Disconnect() end end
end)
addToggleButton("Ruch", "Latanie (3D Fly Mode)", "Fly", function(state)
    local char = Player.Character 
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    
    if state and hrp and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        _G.BVel = Instance.new("BodyVelocity", hrp) 
        _G.BVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        _G.BGyr = Instance.new("BodyGyro", hrp) 
        _G.BGyr.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        
        task.spawn(function()
            while Toggles.Fly and hrp and hum do
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    local camLook = cam.CFrame.LookVector
                    _G.BVel.Velocity = camLook * 70
                else
                    _G.BVel.Velocity = Vector3.new(0, 0, 0)
                end
                _G.BGyr.CFrame = cam.CFrame
                task.wait()
            end
        end)
    else 
        if _G.BVel then _G.BVel:Destroy() _G.BVel = nil end 
        if _G.BGyr then _G.BGyr:Destroy() _G.BGyr = nil end 
    end
end)
addToggleButton("Ruch", "Nieskończony Skok", "InfJump", function(state)
    if state then _G.JumpCon = UserInputService.JumpRequest:Connect(function() local h = Player.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end)
    else if _G.JumpCon then _G.JumpCon:Disconnect() end end
end)
addButton("Ruch", "Szybki Reset Postaci", function() if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").Health = 0 end end)
addButton("Ruch", "Połóż postać (Sit)", function() pcall(function() Player.Character.Humanoid.Sit = true end) end)

-- 2. EKWIPUNEK
addButton("Ekwipunek", "Weź Wszystkie Narzędzia z Gry", function()
    local res = ReplicatedStorage:FindFirstChild("Tools") or ReplicatedStorage:FindFirstChild("Items") or ReplicatedStorage
    for _, v in pairs(res:GetDescendants()) do if v:IsA("Tool") then v:Clone().Parent = Player.Backpack end end
end)
addToggleButton("Ekwipunek", "Gatling Mode (Spam Bronią)", "Gatling", function(state)
    if state then task.spawn(function()
        while Toggles.Gatling do
            local h = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if h and Player.Backpack then for _, t in pairs(Player.Backpack:GetChildren()) do if t:IsA("Tool") and Toggles.Gatling then h:EquipTool(t) task.wait(0.03) end end end
            task.wait()
        end
    end) end
end)
addButton("Ekwipunek", "Wyczyszczenie Ekwipunku", function() if Player.Backpack then Player.Backpack:ClearAllChildren() end end)
addButton("Ekwipunek", "Spawn Bomby i Worka", function()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do if v:IsA("Tool") and (v.Name == "Bomb" or v.Name == "Sack") then v:Clone().Parent = Player.Backpack end end
end)
addButton("Ekwipunek", "Daj Kartę ID Keycard", function() for _, v in pairs(ReplicatedStorage:GetDescendants()) do if v:IsA("Tool") and v.Name:find("Key") then v:Clone().Parent = Player.Backpack end end end)
addButton("Ekwipunek", "Daj Śpiwór (Glitche ścienne)", function() local s = ReplicatedStorage:FindFirstChild("SleepingBag", true) if s then s:Clone().Parent = Player.Backpack end end)

-- 3. POJAZDY
addToggleButton("Pojazdy", "Tęczowe Auto (RGB Mode)", "RGB", function(state)
    if state then task.spawn(function()
        while Toggles.RGB do
            pcall(function()
                local seat = nil for _, v in pairs(workspace:GetDescendants()) do if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then seat = v break end end
                if seat and seat.Parent and ReplicatedStorage:FindFirstChild("Network") then ReplicatedStorage.Network.ColorCar:FireServer(seat.Parent, Color3.fromHSV(currentHue, 1, 1)) end
            end)
            task.wait(0.05)
        end
    end) end
end)
addToggleButton("Pojazdy", "Spam Klaksonem (Horn Bug)", "Horn", function(state)
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
addButton("Pojazdy", "Odwołaj Swój Pojazd", function() if ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("EliminateCar") then ReplicatedStorage.Network.EliminateCar:FireServer() end end)
addButton("Pojazdy", "Wysoki Skok Autem", function()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then v.Parent.PrimaryPart.Velocity = v.Parent.PrimaryPart.Velocity + Vector3.new(0, 80, 0) end
        end
    end)
end)
addButton("Pojazdy", "Obróć Auto (Flip)", function()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then v.Parent.PrimaryPart.CFrame = v.Parent.PrimaryPart.CFrame * CFrame.Angles(0,0,0) end
        end
    end)
end)
addButton("Pojazdy", "Zniszcz koła w aucie", function() pcall(function() for _, v in pairs(workspace:GetDescendants()) do if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then for _, w in pairs(v.Parent:GetDescendants()) do if w.Name:lower():find("wheel") then w:Destroy() end end end end end) end)

-- 4. ANIMACJE PREMIUM
addAnimButton("Animacje", "Jerk Tool / Flex", 507371109)
addAnimButton("Animacje", "Take the L", 333833446)
addAnimButton("Animacje", "Scuba Wave", 333839256)
addAnimButton("Animacje", "Zombie Walk", 35654637)
addAnimButton("Animacje", "Taniec Hype", 424907230)
addAnimButton("Animacje", "Salto w tył", 303358334)
addAnimButton("Animacje", "Lewitacja", 313331574)
addButton("Animacje", "WYŁĄCZ ANIMACJE", function() stopAllAnimations() end)

-- 5. TELEPORTACJA
local function tpl(cf) if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then Player.Character.HumanoidRootPart.CFrame = cf end end
addButton("Teleport", "Bank & Sejf", function() tpl(CFrame.new(-22, 10, 52)) end)
addButton("Teleport", "Posterunek Policji", function() tpl(CFrame.new(-42, 11, 28)) end)
addButton("Teleport", "Sklep Spożywczy", function() tpl(CFrame.new(12, 10, 15)) end)
addButton("Teleport", "Dach Szpitala", function() tpl(CFrame.new(65, 25, -10)) end)
addButton("Teleport", "Bunkier Agencji", function() tpl(CFrame.new(-265, -15, -145)) end)
addButton("Teleport", "Szkoła", function() tpl(CFrame.new(-10, 10, -100)) end)
addButton("Teleport", "Losowa Działka (Plot 1)", function() tpl(CFrame.new(-484, 22, -153)) end)

-- 6. WIZUALNE & ŚWIAT
addToggleButton("Wizualne", "Wyświetl ESP Graczy", "ESP", function(state)
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
addToggleButton("Wizualne", "Przenikanie przez Sejf", "SafeNoclip", function(state)
    if state then
        _G.SafeTrack = RunService.Stepped:Connect(function()
            for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name == "SafeDoor" or v.Name == "BankWall") then v.CanCollide = false v.Transparency = 0.4 end end
        end)
    else
        if _G.SafeTrack then _G.SafeTrack:Disconnect() end
        for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name == "SafeDoor" or v.Name == "BankWall") then v.CanCollide = true v.Transparency = 0 end end
    end
end)
addToggleButton("Wizualne", "Tryb Jasności", "Fullbright", function(state)
    if state then Lighting.Brightness = 2 Lighting.ClockTime = 14 Lighting.FogEnd = 999999 else Lighting.Brightness = 1 Lighting.ClockTime = 12 end
end)
addButton("Wizualne", "Usuń Drzwi z Mapy", function() for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name:lower():find("door") or v.Name:lower():find("gate")) then v:Destroy() end end end)
addButton("Wizualne", "Zgaś Lampy Uliczne", function() for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and v.Name:lower():find("light") then v:Destroy() end end end)
addButton("Wizualne", "Crash Świateł w Domach", function() pcall(function() for _, v in pairs(workspace:GetDescendants()) do if v:IsA("RemoteEvent") and v.Name:find("Light") then v:FireServer(false) end end end) end)

-- ZAMKNIĘCIE INTERFEJSU
local CloseBtn = Instance.new("TextButton", TabPanel)
CloseBtn.Size = UDim2.new(1, 0, 0, 30)
CloseBtn.Position = UDim2.new(0, 0, 1, -30)
CloseBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "WYŁĄCZ HUB"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 11
CloseBtn.BorderSizePixel = 0
CloseBtn.MouseButton1Click:Connect(function()
    stopAllAnimations()
    for k, _ in pairs(Toggles) do Toggles[k] = false end
    if _G.NoclipLoop then _G.NoclipLoop:Disconnect() end
    if _G.BVel then _G.BVel:Destroy() _G.BVel = nil end
    if _G.BGyr then _G.BGyr:Destroy() _G.BGyr = nil end
    if _G.JumpCon then _G.JumpCon:Disconnect() end
    if _G.ESPTrack then _G.ESPTrack:Disconnect() end
    if _G.SafeTrack then _G.SafeTrack:Disconnect() end
    ScreenGui:Destroy()
end)
