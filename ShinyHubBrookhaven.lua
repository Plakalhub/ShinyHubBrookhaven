--[[
    ShinyHub V5 - Brookhaven Mobile Compact & SERVER-SIDE CAR FLING (2026)
    - MASS CAR FLING: Używa fizyki auta (Network Ownership) do prawdziwego wywalania graczy na serwerze!
    - Jak używać: Wsiądź do auta jako kierowca, wpisz 'all' lub nick i kliknij "CAR MASS FLING".
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local SelectedTarget = ""
local currentHue = 0

task.spawn(function()
    while true do
        currentHue = (tick() % 4) / 4
        task.wait()
    end
end)

if CoreGui:FindFirstChild("ShinyHubMenu") then 
    pcall(function() CoreGui.ShinyHubMenu:Destroy() end) 
end

local Toggles = { Noclip = false, Fly = false, InfJump = false, Gatling = false, RGB = false, FlyCar = false, NoclipCar = false }
local ActiveAnimations = {}

-- Pobieranie auta, w którym siedzisz
local function getCurrentVehicle()
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        local seat = Player.Character:FindFirstChildOfClass("Humanoid").SeatPart
        if seat and seat:IsA("VehicleSeat") and seat.Parent then
            return seat.Parent, seat
        end
    end
    return nil, nil
end

-- Pobieranie celów (wspiera 'all')
local function getTargets(str)
    local targets = {}
    if str:lower() == "all" then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player then table.insert(targets, p) end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and (p.Name:lower():sub(1, #str) == str:lower() or p.DisplayName:lower():sub(1, #str) == str:lower()) then
                table.insert(targets, p)
                break
            end
        end
    end
    return targets
end

-- ==========================================
-- INTERFEJS GRAFICZNY
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShinyHubMenu"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0.45, 0, 0.55, 0)
MainFrame.Position = UDim2.new(0.30, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
MainFrame.BorderSizePixel = 2

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

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0.10, 0)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Text = "★ SHINYHUB V5 (SERVER-SIDE FLING) ★"
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true

local TabPanel = Instance.new("Frame", MainFrame)
TabPanel.Size = UDim2.new(0.28, 0, 0.90, 0)
TabPanel.Position = UDim2.new(0, 0, 0.10, 0)
TabPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 18)

local ContentPanel = Instance.new("Frame", MainFrame)
ContentPanel.Size = UDim2.new(0.70, 0, 0.90, 0)
ContentPanel.Position = UDim2.new(0.29, 0, 0.10, 0)
ContentPanel.BackgroundTransparency = 1

local tabs = {}
local tabCount = 0

local function createTab(name)
    local tabBtn = Instance.new("TextButton", TabPanel)
    tabBtn.Size = UDim2.new(1, 0, 0, 22)
    tabBtn.Position = UDim2.new(0, 0, 0, tabCount * 22)
    tabBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.TextSize = 10
    tabCount = tabCount + 1
    
    local scroll = Instance.new("ScrollingFrame", ContentPanel)
    scroll.Size = UDim2.new(1, -2, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.Visible = false
    scroll.CanvasSize = UDim2.new(0, 0, 0, 400)
    scroll.ScrollBarThickness = 2
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 3)
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do t.scroll.Visible = false t.btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24) end
        scroll.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    end)
    tabs[name] = {btn = tabBtn, scroll = scroll}
    if tabCount == 1 then scroll.Visible = true tabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0) end
    return scroll
end

local function addButton(tabName, text, callback)
    local btn = Instance.new("TextButton", tabs[tabName].scroll)
    btn.Size = UDim2.new(1, -4, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

local function addToggleButton(tabName, text, toggleKey, callback)
    local btn = Instance.new("TextButton", tabs[tabName].scroll)
    btn.Size = UDim2.new(1, -4, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
    btn.TextColor3 = Color3.fromRGB(255, 120, 120)
    btn.Text = text .. " [OFF]"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 10
    
    btn.MouseButton1Click:Connect(function()
        Toggles[toggleKey] = not Toggles[toggleKey]
        btn.Text = text .. (Toggles[toggleKey] and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = Toggles[toggleKey] and Color3.fromRGB(25, 45, 25) or Color3.fromRGB(45, 25, 25)
        btn.TextColor3 = Toggles[toggleKey] and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 120, 120)
        pcall(callback, Toggles[toggleKey])
    end)
end

createTab("Trolling")
createTab("Ruch/Pojazdy")

-- ==========================================
-- SEKCJA TROLLINGU
-- ==========================================
local scrollTroll = tabs["Trolling"].scroll

local UserSelector = Instance.new("TextBox", scrollTroll)
UserSelector.Size = UDim2.new(1, -4, 0, 30)
UserSelector.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
UserSelector.TextColor3 = Color3.fromRGB(255, 255, 0)
UserSelector.PlaceholderText = "Wpisz nick lub 'all'..."
UserSelector.Text = ""
UserSelector.Font = Enum.Font.SourceSansBold
UserSelector.TextSize = 12

UserSelector:GetPropertyChangedSignal("Text"):Connect(function() SelectedTarget = UserSelector.Text end)

-- PRAWDZIWY SERWEROWY MASS FLING AUTEM
addButton("Trolling", "🚀 CAR MASS FLING (Wywala serwer!)", function()
    local car, seat = getCurrentVehicle()
    if not car or not seat then return end
    
    local targets = getTargets(SelectedTarget)
    if #targets == 0 then return end
    
    local bodyPart = car:FindFirstChild("Body") or seat
    local char = Player.Character
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    local bAV = Instance.new("BodyAngularVelocity")
    bAV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bAV.AngularVelocity = Vector3.new(0, 999999, 0)
    bAV.Parent = bodyPart
    
    local bV = Instance.new("BodyVelocity")
    bV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bV.Velocity = Vector3.new(0, 0, 0)
    bV.Parent = bodyPart

    for _, tPlayer in pairs(targets) do
        if tPlayer.Character and tPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = tPlayer.Character.HumanoidRootPart
            for i = 1, 20 do
                if targetHrp and bodyPart then
                    bodyPart.CFrame = targetHrp.CFrame * CFrame.new(0, -1, 0)
                end
                task.wait(0.02)
            end
        end
    end
    
    bAV:Destroy()
    bV:Destroy()
end)

addButton("Trolling", "🧱 JAIL TARGET (Klatka z barier)", function()
    local targets = getTargets(SelectedTarget)
    if #targets == 0 then return end
    if ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("BuildProp") then
        for _, tPlayer in pairs(targets) do
            if tPlayer.Character and tPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local tHrp = tPlayer.Character.HumanoidRootPart
                for i = 1, 4 do
                    local angle = (i * math.pi) / 2
                    local cf = tHrp.CFrame * CFrame.new(math.sin(angle)*4, 0, math.cos(angle)*4)
                    ReplicatedStorage.Network.BuildProp:FireServer("Barricade", cf.Position, cf.Rotation)
                end
            end
        end
    end
end)

addButton("Trolling", "🔊 SPAM SOUND (Hałas u wszystkich)", function()
    local targets = getTargets(SelectedTarget)
    if #targets == 0 then return end
    task.spawn(function()
        for i = 1, 30 do
            for _, tPlayer in pairs(targets) do
                if tPlayer.Character and tPlayer.Character:FindFirstChild("HumanoidRootPart") and ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("PlaySound") then
                    ReplicatedStorage.Network.PlaySound:FireServer("Bell", tPlayer.Character.HumanoidRootPart.Position)
                end
            end
            task.wait(0.04)
        end
    end)
end)

-- ==========================================
-- SEKCJA RUCH / POJAZDY
-- ==========================================
addButton("Ruch/Pojazdy", "Super Bieg (Speed 100)", function() if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 100 end end)
addToggleButton("Ruch/Pojazdy", "Latanie Autem (Fly Car)", "FlyCar", function(state)
    local cam = workspace.CurrentCamera
    if state then
        task.spawn(function()
            while Toggles.FlyCar do
                local car, seat = getCurrentVehicle()
                if car and seat then
                    local bodyPart = car:FindFirstChild("Body") or seat
                    if not bodyPart:FindFirstChild("CarFlyVel") then
                        local bv = Instance.new("BodyVelocity") bv.Name = "CarFlyVel" bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) bv.Parent = bodyPart
                        local bg = Instance.new("BodyGyro") bg.Name = "CarFlyGyr" bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) bg.Parent = bodyPart
                    end
                    bodyPart.CarFlyGyr.CFrame = cam.CFrame
                    if seat.Throttle ~= 0 then bodyPart.CarFlyVel.Velocity = cam.CFrame.LookVector * (seat.Throttle * 100) else bodyPart.CarFlyVel.Velocity = Vector3.new(0,0,0) end
                else break end
                task.wait()
            end
        end)
    end
end)

addToggleButton("Ruch/Pojazdy", "Tęczowe Auto (RGB)", "RGB", function(state)
    if state then task.spawn(function()
        while Toggles.RGB do
            local car = getCurrentVehicle()
            if car and ReplicatedStorage:FindFirstChild("Network") then ReplicatedStorage.Network.ColorCar:FireServer(car, Color3.fromHSV(currentHue, 1, 1)) end
            task.wait(0.05)
        end
    end) end
end)

-- ==========================================
-- PRZYCISK ZAMKNIĘCIA MENU
-- ==========================================
local CloseBtn = Instance.new("TextButton", TabPanel)
CloseBtn.Size = UDim2.new(1, 0, 0, 24)
CloseBtn.Position = UDim2.new(0, 0, 1, -24)
CloseBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "WYŁĄCZ HUB"
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
