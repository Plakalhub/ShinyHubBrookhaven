--[[
    ShinyHub V5 - Brookhaven RP Premium Edition
    - PRZYWRÓCONO: Klasyczny zestaw 40 sprawdzonych opcji
    - FIX: Naprawiony i zabezpieczony system ładowania animacji
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Czyszczenie starego GUI
if CoreGui:FindFirstChild("ShinyHubMenu") then 
    pcall(function() CoreGui.ShinyHubMenu:Destroy() end) 
end

-- Stan przełączników
local Toggles = {
    Noclip = false, Fly = false, InfJump = false, Gatling = false,
    RGB = false, Horn = false, ESP = false, SafeNoclip = false, Fullbright = false
}

local currentHue = 0
task.spawn(function()
    while true do
        currentHue = (tick() % 4) / 4
        task.wait()
    end
end)

-- ==========================================
-- POPRAWIONY SYSTEM ANIMACJI
-- ==========================================
local ActiveTrack = nil
local CurrentAnimID = nil

local function forcePlayAnimation(animID)
    pcall(function()
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local animScript = char and char:FindFirstChild("Animate")
        
        if animScript then animScript.Disabled = true end
        
        if hum then
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
    if ActiveTrack then pcall(function() ActiveTrack:Stop() ActiveTrack:Destroy() end) ActiveTrack = nil end
    pcall(function()
        local char = Player.Character
        local animScript = char and char:FindFirstChild("Animate")
        if animScript then animScript.Disabled = false end
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
    end)
end

RunService.RenderStepped:Connect(function()
    if CurrentAnimID and ActiveTrack and not ActiveTrack.IsPlaying then
        pcall(function() ActiveTrack:Play() end)
    end
end)

-- ==========================================
-- INTERFEJS GRAFICZNY (STABILNY)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShinyHubMenu"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 650, 0, 480)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
MainFrame.BorderSizePixel = 2

-- Modern Dragging
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

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
Title.Text = "★ SHINYHUB V5 - 40 PREMIUM SELECTION ★"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local tabs = {}
local activeTab = nil
local tabCount = 0

local function createTab(name)
    local tabBtn = Instance.new("TextButton", TabPanel)
    tabBtn.Size = UDim2.new(1, 0, 0, 40)
    tabBtn.Position = UDim2.new(0, 0, 0, tabCount * 40)
    tabBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.TextSize = 13
    tabBtn.BorderSizePixel = 0
    tabCount = tabCount + 1
    
    local scroll = Instance.new("ScrollingFrame", ContentPanel)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.Visible = false
    scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
    scroll.ScrollBarThickness = 4
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    
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
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(60, 60, 60)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

local function addToggleButton(tabName, text, toggleKey, callback)
    local scroll = tabs[tabName].scroll
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
    btn.TextColor3 = Color3.fromRGB(255, 120, 120)
    btn.Text = text .. " [OFF]"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    
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
local tabMovement = createTab("Postać & Ruch")
local tabCombat = createTab("Ekwipunek")
local tabCars = createTab("Pojazdy")
local tabAnims = createTab("Animacje Premium")
local tabTeleport = createTab("Teleportacja")
local tabVisuals = createTab("Wizualne & Świat")

-- ==========================================
-- 1. POSTAĆ & RUCH (7 OPCJI)
-- ==========================================
addButton("Postać & Ruch", "Super Bieg (WalkSpeed 100)", function() if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 100 end end)
addButton("Postać & Ruch", "Mega Skok (JumpPower 150)", function() local h = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") if h then h.UseJumpPower = true h.JumpPower = 150 end end)
addToggleButton("Postać & Ruch", "Przenikanie (Noclip)", "Noclip", function(state)
    if state then
        _G.NoclipLoop = RunService.Stepped:Connect(function()
            if Player.Character then for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        end)
    else if _G.NoclipLoop then _G.NoclipLoop:Disconnect() end end
end)
addToggleButton("Postać & Ruch", "Latanie (Fly Mode)", "Fly", function(state)
    local char = Player.Character local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if state and hrp then
        _G.BVel = Instance.new("BodyVelocity", hrp) _G.BVel.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        _G.BGyr = Instance.new("BodyGyro", hrp) _G.BGyr.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
        task.spawn(function()
            while Toggles.Fly and hrp do _G.BVel.Velocity = char.Humanoid.MoveDirection * 70 _G.BGyr.CFrame = workspace.CurrentCamera.CFrame task.wait() end
        end)
    else if _G.BVel then _G.BVel:Destroy() _G.BGyr:Destroy() end end
end)
addToggleButton("Postać & Ruch", "Nieskończony Skok", "InfJump", function(state)
    if state then _G.JumpCon = UserInputService.JumpRequest:Connect(function() local h = Player.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end)
    else if _G.JumpCon then _G.JumpCon:Disconnect() end end
end)
addButton("Postać & Ruch", "Szybki Reset Postaci", function() if Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").Health = 0 end end)
addButton("Postać & Ruch", "Połóż postać (Sit)", function() pcall(function() Player.Character.Humanoid.Sit = true end) end)

-- ==========================================
-- 2. EKWIPUNEK (6 OPCJI)
-- ==========================================
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

-- ==========================================
-- 3. POJAZDY (6 OPCJI)
-- ==========================================
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
addButton("Pojazdy", "Zniszcz koła w aktualnym aucie", function() pcall(function() for _, v in pairs(workspace:GetDescendants()) do if v:IsA("VehicleSeat") and v.Occupant and v.Occupant.Parent == Player.Character then for _, w in pairs(v.Parent:GetDescendants()) do if w.Name:lower():find("wheel") then w:Destroy() end end end end end) end)

-- ==========================================
-- 4. ANIMACJE PREMIUM (8 OPCJI)
-- ==========================================
addButton("Animacje Premium", "AKTYWUJ: Jerk Tool / Flex", function() forcePlayAnimation(507371109) end)
addButton("Animacje Premium", "AKTYWUJ: Take the L", function() forcePlayAnimation(333833446) end)
addButton("Animacje Premium", "AKTYWUJ: Scuba Wave", function() forcePlayAnimation(333839256) end)
addButton("Animacje Premium", "AKTYWUJ: Zombie Walk", function() forcePlayAnimation(35654637) end)
addButton("Animacje Premium", "AKTYWUJ: Taniec Hype", function() forcePlayAnimation(424907230) end)
addButton("Animacje Premium", "AKTYWUJ: Salto (Backflip)", function() forcePlayAnimation(303358334) end)
addButton("Animacje Premium", "AKTYWUJ: Lewitacja", function() forcePlayAnimation(313331574) end)
addButton("Animacje Premium", "WYŁĄCZ WSZYSTKIE ANIMACJE (RESET)", function() stopAllCustomAnimations() end)

-- ==========================================
-- 5. TELEPORTACJA (7 OPCJI)
-- ==========================================
local function tpl(cf) if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then Player.Character.HumanoidRootPart.CFrame = cf end end
addButton("Teleportacja", "Bank & Sejf", function() tpl(CFrame.new(-22, 10, 52)) end)
addButton("Teleportacja", "Posterunek Policji", function() tpl(CFrame.new(-42, 11, 28)) end)
addButton("Teleportacja", "Sklep Spożywczy", function() tpl(CFrame.new(12, 10, 15)) end)
addButton("Teleportacja", "Dach Szpitala", function() tpl(CFrame.new(65, 25, -10)) end)
addButton("Teleportacja", "Bunkier Agencji", function() tpl(CFrame.new(-265, -15, -145)) end)
addButton("Teleportacja", "Szkoła", function() tpl(CFrame.new(-10, 10, -100)) end)
addButton("Teleportacja", "Losowa Działka (Plot 1)", function() tpl(CFrame.new(-484, 22, -153)) end)

-- ==========================================
-- 6. WIZUALNE & ŚWIAT (6 OPCJI)
-- ==========================================
addToggleButton("Wizualne & ŚWIAT", "Wyświetl ESP Graczy", "ESP", function(state)
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
addToggleButton("Wizualne & ŚWIAT", "Przenikanie przez Sejf", "SafeNoclip", function(state)
    if state then
        _G.SafeTrack = RunService.Stepped:Connect(function()
            for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name == "SafeDoor" or v.Name == "BankWall") then v.CanCollide = false v.Transparency = 0.4 end end
        end)
    else
        if _G.SafeTrack then _G.SafeTrack:Disconnect() end
        for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name == "SafeDoor" or v.Name == "BankWall") then v.CanCollide = true v.Transparency = 0 end end
    end
end)
addToggleButton("Wizualne & ŚWIAT", "Tryb Jasności (Fullbright)", "Fullbright", function(state)
    if state then Lighting.Brightness = 2 Lighting.ClockTime = 14 Lighting.FogEnd = 999999 else Lighting.Brightness = 1 Lighting.ClockTime = 12 end
end)
addButton("Wizualne & ŚWIAT", "Usuń Wszystkie Drzwi z Mapy", function() for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name:lower():find("door") or v.Name:lower():find("gate")) then v:Destroy() end end end)
addButton("Wizualne & ŚWIAT", "Zgaś Lampy Uliczne", function() for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and v.Name:lower():find("light") then v:Destroy() end end end)
addButton("Wizualne & ŚWIAT", "Crash Świateł w Domach", function() pcall(function() for _, v in pairs(workspace:GetDescendants()) do if v:IsA("RemoteEvent") and v.Name:find("Light") then v:FireServer(false) end end end) end)

-- ==========================================
-- PRZYCISK ZAMKNIĘCIA INTERFEJSU
-- ==========================================
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 150, 0, 40)
CloseBtn.Position = UDim2.new(0, 0, 1, -40)
CloseBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "WYŁĄCZ SHINYHUB"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
CloseBtn.MouseButton1Click:Connect(function()
    stopAllCustomAnimations()
    for k, _ in pairs(Toggles) do Toggles[k] = false end
    if _G.NoclipLoop then _G.NoclipLoop:Disconnect() end
    if _G.BVel then _G.BVel:Destroy() _G.BGyr:Destroy() end
    if _G.JumpCon then _G.JumpCon:Disconnect() end
    if _G.ESPTrack then _G.ESPTrack:Disconnect() end
    if _G.SafeTrack then _G.SafeTrack:Disconnect() end
    ScreenGui:Destroy()
end)
