--[[
    ShinyHub V5 - School Bus INSTANT FLING Edition (2026)
    - RAPID TELEPORT: Ekstremalnie szybkie przeskakiwanie między graczami, zanim zdążą zareagować.
    - AUTOMATIC SCHOOL BUS SPAWN: Skrypt sam spawnuje autobus i wsadza Cię do niego.
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

if CoreGui:FindFirstChild("ShinyHubPremium") then 
    pcall(function() CoreGui.ShinyHubPremium:Destroy() end) 
end

local Toggles = { Noclip = false, Fly = false, RGB = false, FlyCar = false, NoclipCar = false }

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

local function getPlayerVehicle()
    for _, v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Owner") and v.Owner.Value == Player then
            local seat = v:FindFirstChildOfClass("VehicleSeat") or v:FindFirstChild("DriveSeat", true)
            return v, seat
        end
    end
    return nil, nil
end

RunService.Stepped:Connect(function()
    if Toggles.Noclip and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    if Toggles.NoclipCar then
        local car = getPlayerVehicle()
        if car then
            for _, part in pairs(car:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- ==========================================
-- INTERFEJS GRAFICZNY
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShinyHubPremium"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
MainFrame.BorderSizePixel = 0

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 8)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(255, 255, 0)
MainStroke.Thickness = 1.5

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
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
Title.TextColor3 = Color3.fromRGB(10, 10, 10)
Title.Text = "  ★ SHINYHUB V5 [INSTANT BUS FLING] ★"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
local TitleCorner = Instance.new("UICorner", Title)
TitleCorner.CornerRadius = UDim.new(0, 8)

local TabPanel = Instance.new("Frame", MainFrame)
TabPanel.Size = UDim2.new(0, 140, 1, -40)
TabPanel.Position = UDim2.new(0, 0, 0, 40)
TabPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TabPanel.BorderSizePixel = 0

local TabList = Instance.new("UIListLayout", TabPanel)
TabList.Padding = UDim.new(0, 2)

local ContentPanel = Instance.new("Frame", MainFrame)
ContentPanel.Size = UDim2.new(1, -150, 1, -50)
ContentPanel.Position = UDim2.new(0, 145, 0, 45)
ContentPanel.BackgroundTransparency = 1

local tabs = {}
local tabCount = 0

local function createTab(name)
    local tabBtn = Instance.new("TextButton", TabPanel)
    tabBtn.Size = UDim2.new(1, 0, 0, 32)
    tabBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    tabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    tabBtn.Text = "  " .. name
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 12
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.BorderSizePixel = 0
    tabCount = tabCount + 1
    
    local scroll = Instance.new("ScrollingFrame", ContentPanel)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.Visible = false
    scroll.CanvasSize = UDim2.new(0, 0, 0, 450)
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 0)
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do t.scroll.Visible = false t.btn.BackgroundColor3 = Color3.fromRGB(26, 26, 26) t.btn.TextColor3 = Color3.fromRGB(180, 180, 180) end
        scroll.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
    end)
    
    tabs[name] = {btn = tabBtn, scroll = scroll}
    if tabCount == 1 then scroll.Visible = true tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35) tabBtn.TextColor3 = Color3.fromRGB(255, 255, 0) end
    return scroll
end

local function addButton(tabName, text, callback)
    local btn = Instance.new("TextButton", tabs[tabName].scroll)
    btn.Size = UDim2.new(1, -6, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local stroke = Instance.new("UIStroke", btn) stroke.Color = Color3.fromRGB(40, 40, 40)
    btn.MouseEnter:Connect(function() stroke.Color = Color3.fromRGB(255, 255, 0) end)
    btn.MouseLeave:Connect(function() stroke.Color = Color3.fromRGB(40, 40, 40) end)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

local function addToggleButton(tabName, text, toggleKey, callback)
    local btn = Instance.new("TextButton", tabs[tabName].scroll)
    btn.Size = UDim2.new(1, -6, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(35, 20, 20)
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.Text = text .. " : OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        Toggles[toggleKey] = not Toggles[toggleKey]
        btn.Text = text .. (Toggles[toggleKey] and " : ON" or " : OFF")
        btn.BackgroundColor3 = Toggles[toggleKey] and Color3.fromRGB(20, 35, 20) or Color3.fromRGB(35, 20, 20)
        btn.TextColor3 = Toggles[toggleKey] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        pcall(callback, Toggles[toggleKey])
    end)
end

createTab("Trolling")
createTab("Ruch Gracza")
createTab("Pojazdy")

-- ==========================================
-- ZAKŁADKA TROLLING (BŁYSKAWICZNY ATTACK)
-- ==========================================
local scrollTroll = tabs["Trolling"].scroll

local UserSelector = Instance.new("TextBox", scrollTroll)
UserSelector.Size = UDim2.new(1, -6, 0, 34)
UserSelector.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
UserSelector.TextColor3 = Color3.fromRGB(255, 255, 0)
UserSelector.PlaceholderText = "Wpisz nick lub 'all'..."
UserSelector.Text = ""
UserSelector.Font = Enum.Font.GothamSemibold
UserSelector.TextSize = 12
Instance.new("UICorner", UserSelector).CornerRadius = UDim.new(0, 4)
local boxStroke = Instance.new("UIStroke", UserSelector) boxStroke.Color = Color3.fromRGB(255, 255, 0)

UserSelector:GetPropertyChangedSignal("Text"):Connect(function() SelectedTarget = UserSelector.Text end)

addButton("Trolling", "🚌 INSTANT BUS MASS FLING", function()
    local targets = getTargets(SelectedTarget)
    if #targets == 0 then return end
    
    if ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("RemoveVehicle") then
        ReplicatedStorage.Network.RemoveVehicle:FireServer()
    end
    task.wait(0.15)
    
    if ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("SpawnVehicle") then
        ReplicatedStorage.Network.SpawnVehicle:FireServer("Bus", Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, -10), Color3.fromRGB(255,255,0))
    end
    
    local car, seat
    for i = 1, 20 do
        car, seat = getPlayerVehicle()
        if car and seat then 
            seat:Sit(Player.Character:FindFirstChildOfClass("Humanoid"))
            break 
        end
        task.wait(0.05)
    end
    
    if not car or not seat then return end
    task.wait(0.2)
    
    local bodyPart = car:FindFirstChild("Body") or seat
    local char = Player.Character
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    -- Agresywne wartości fizyki rotacyjnej (natychmiastowy fling)
    local bAV = Instance.new("BodyAngularVelocity")
    bAV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bAV.AngularVelocity = Vector3.new(0, 9999999, 0)
    bAV.Parent = bodyPart
    
    local bV = Instance.new("BodyVelocity")
    bV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bV.Velocity = Vector3.new(0, 0, 0)
    bV.Parent = bodyPart

    -- Błyskawiczna pętla rażenia: uderzenie trwa tylko ułamek sekundy na gracza
    for _, tPlayer in pairs(targets) do
        if tPlayer.Character and tPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = tPlayer.Character.HumanoidRootPart
            -- Zredukowane do 6 szybkich powtórzeń (bardzo szybki przeskok)
            for i = 1, 6 do
                if targetHrp and bodyPart then
                    bodyPart.CFrame = targetHrp.CFrame * CFrame.new(0, -1, 0)
                end
                RunService.Heartbeat:Wait() -- Synchronizacja z fizyką gry zamiast stałego task.wait
            end
        end
    end
    
    bAV:Destroy()
    bV:Destroy()
end)

addButton("Trolling", "🧱 JAIL TARGET (Klatka)", function()
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

-- ==========================================
-- ZAKŁADKI RUCH I POJAZDY
-- ==========================================
addButton("Ruch Gracza", "Szybki Bieg (Speed 100)", function() if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 100 end end)
addButton("Ruch Gracza", "Resetuj Bieg", function() if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 end end)

addToggleButton("Ruch Gracza", "Latanie Postacią (Fly)", "Fly", function(state)
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local cam = workspace.CurrentCamera
    if state then
        task.spawn(function()
            local bv = Instance.new("BodyVelocity") bv.Name = "TotalFlyVel" bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) bv.Parent = hrp
            local bg = Instance.new("BodyGyro") bg.Name = "TotalFlyGyr" bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) bg.Parent = hrp
            while Toggles.Fly and char and hrp do
                bg.CFrame = cam.CFrame
                local hum = char:FindFirstChildOfClass("Humanoid")
                local moveDir = hum and hum.MoveDirection or Vector3.new(0,0,0)
                if moveDir.Magnitude > 0 then bv.Velocity = cam.CFrame:VectorToWorldSpace(Vector3.new(moveDir.X, 0, -moveDir.Z).Unit * 70) else bv.Velocity = Vector3.new(0,0.1,0) end
                task.wait()
            end
            if hrp:FindFirstChild("TotalFlyVel") then hrp.TotalFlyVel:Destroy() end
            if hrp:FindFirstChild("TotalFlyGyr") then hrp.TotalFlyGyr:Destroy() end
        end)
    end
end)

addToggleButton("Ruch Gracza", "Noclip", "Noclip", function(state) end)

addToggleButton("Pojazdy", "Latanie Autem (Fly Car)", "FlyCar", function(state)
    local cam = workspace.CurrentCamera
    if state then
        task.spawn(function()
            while Toggles.FlyCar do
                local car, seat = getPlayerVehicle()
                if car and seat then
                    local bodyPart = car:FindFirstChild("Body") or seat
                    if not bodyPart:FindFirstChild("CarFlyVel") then
                        local bv = Instance.new("BodyVelocity") bv.Name = "CarFlyVel" bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) bv.Parent = bodyPart
                        local bg = Instance.new("BodyGyro") bg.Name = "CarFlyGyr" bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) bg.Parent = bodyPart
                    end
                    bodyPart.CarFlyGyr.CFrame = cam.CFrame
                    if seat.Throttle ~= 0 then bodyPart.CarFlyVel.Velocity = cam.CFrame.LookVector * (seat.Throttle * 120) else bodyPart.CarFlyVel.Velocity = Vector3.new(0,0,0) end
                else break end
                task.wait()
            end
        end)
    end
end)

addToggleButton("Pojazdy", "Noclip Car", "NoclipCar", function(state) end)

addToggleButton("Pojazdy", "Tęczowe Auto (RGB)", "RGB", function(state)
    if state then task.spawn(function()
        while Toggles.RGB do
            local car = getPlayerVehicle()
            if car and ReplicatedStorage:FindFirstChild("Network") then ReplicatedStorage.Network.ColorCar:FireServer(car, Color3.fromHSV(currentHue, 1, 1)) end
            task.wait(0.05)
        end
    end) end
end)

local CloseBtn = Instance.new("TextButton", TabPanel)
CloseBtn.Size = UDim2.new(1, 0, 0, 32)
CloseBtn.Position = UDim2.new(0, 0, 1, -32)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "WYŁĄCZ HUB"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11
CloseBtn.BorderSizePixel = 0
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
