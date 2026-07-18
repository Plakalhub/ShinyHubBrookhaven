--[[
    ShinyHub V5 - BROOKHAVEN VEHICLE PALETTE & ITEM FLING FIX (2026)
    - NAPRAWIONO: Metoda Fling działa teraz poprzez glitchowanie piłki z ekwipunku.
    - NAPRAWIONO: Fly Car (Latanie autem) już nie crashuje i działa płynnie.
    - NAPRAWIONO: Bezpieczne nadawanie prędkości pojazdu.
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local SelectedTarget = ""
local CustomCarSpeed = 400

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

local function updateVehicleSpeed()
    local car, seat = getPlayerVehicle()
    if car and seat and seat:IsA("VehicleSeat") then
        seat.MaxSpeed = CustomCarSpeed
    end
end

-- Monitorowanie prędkości w tle, by gra jej nie resetowała
task.spawn(function()
    while task.wait(0.5) do
        local car, seat = getPlayerVehicle()
        if car and seat and seat:IsA("VehicleSeat") then
            if seat.MaxSpeed ~= CustomCarSpeed then
                seat.MaxSpeed = CustomCarSpeed
            end
        end
    end
end)

Player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Seated:Connect(function(active, currentSeat)
        if active and currentSeat:IsA("VehicleSeat") then
            task.wait(0.1)
            updateVehicleSpeed()
        end
    end)
end)

if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
    Player.Character:FindFirstChildOfClass("Humanoid").Seated:Connect(function(active, currentSeat)
        if active and currentSeat:IsA("VehicleSeat") then
            task.wait(0.1)
            updateVehicleSpeed()
        end
    end)
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
Title.Text = "  ★ SHINYHUB V5 [BALL & FLY FIX] ★"
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
-- ZAKŁADKA TROLLING (BALL ITEM FLING)
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

addButton("Trolling", "⚽ BALL ITEM FLING TARGET", function()
    local targets = getTargets(SelectedTarget)
    if #targets == 0 then return end

    -- Przywołaj przedmiot Piłki przez Remote z Brookhaven
    if ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("GiveItem") then
        ReplicatedStorage.Network.GiveItem:FireServer("Basketball") -- lub "Ball" w zależności od dokładnej nazwy w grze
    end
    task.wait(0.1)

    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local tool = Player.Backpack:FindFirstChild("Basketball") or char:FindFirstChild("Basketball")

    if not tool or not hrp then return end
    if tool.Parent ~= char then tool.Parent = char end -- Wyciągnij piłkę do ręki

    -- Glitchowanie kolizji i nadawanie rotacji obiektowi podręcznemu (Fling)
    local handle = tool:FindFirstChild("Handle")
    if handle then
        local bAV = Instance.new("BodyAngularVelocity")
        bAV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bAV.AngularVelocity = Vector3.new(0, 50000, 0)
        bAV.Parent = handle

        for _, tPlayer in pairs(targets) do
            if tPlayer.Character and tPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = tPlayer.Character.HumanoidRootPart
                for frame = 1, 15 do
                    if targetHrp and hrp then
                        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 0.5) -- Teleportuje nas tuż obok celu generując uderzenie fizyki
                        handle.Velocity = Vector3.new(0, 5000, 0)
                    end
                    RunService.Heartbeat:Wait()
                end
            end
        end
        bAV:Destroy()
    end
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
-- ZAKŁADKA RUCH GRACZA
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

-- ==========================================
-- ZAKŁADKA POJAZDY
-- ==========================================
local scrollVehicles = tabs["Pojazdy"].scroll

local SpeedLabel = Instance.new("TextLabel", scrollVehicles)
SpeedLabel.Size = UDim2.new(1, -6, 0, 20)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SpeedLabel.Text = "Ustaw własną prędkość auta (np. 400):"
SpeedLabel.Font = Enum.Font.GothamSemibold
SpeedLabel.TextSize = 11
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

local SpeedInput = Instance.new("TextBox", scrollVehicles)
SpeedInput.Size = UDim2.new(1, -6, 0, 34)
SpeedInput.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 0)
SpeedInput.PlaceholderText = "Wpisz prędkość..."
SpeedInput.Text = "400"
SpeedInput.Font = Enum.Font.GothamBold
SpeedInput.TextSize = 13
Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0, 4)
local speedStroke = Instance.new("UIStroke", SpeedInput) speedStroke.Color = Color3.fromRGB(255, 255, 0)

SpeedInput:GetPropertyChangedSignal("Text"):Connect(function()
    local num = tonumber(SpeedInput.Text)
    if num then 
        CustomCarSpeed = num 
        updateVehicleSpeed()
    end
end)

-- NAPRAWIONY FLY CAR SYSTEM
addToggleButton("Pojazdy", "Latanie Autem (Fly Car)", "FlyCar", function(state)
    local cam = workspace.CurrentCamera
    if state then
        task.spawn(function()
            while Toggles.FlyCar do
                local car, seat = getPlayerVehicle()
                if car and seat then
                    local bodyPart = car:FindFirstChild("Body") or seat
                    
                    local bv = bodyPart:FindFirstChild("CarFlyVel") or Instance.new("BodyVelocity")
                    if not bv.Parent then
                        bv.Name = "CarFlyVel"
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Parent = bodyPart
                    end
                    
                    local bg = bodyPart:FindFirstChild("CarFlyGyr") or Instance.new("BodyGyro")
                    if not bg.Parent then
                        bg.Name = "CarFlyGyr"
                        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                        bg.Parent = bodyPart
                    end
                    
                    bg.CFrame = cam.CFrame
                    
                    -- Sterowanie wektorem ruchu na podstawie wciśniętego gazu/wstecznego w pojeździe
                    if seat.Throttle ~= 0 then 
                        bv.Velocity = cam.CFrame.LookVector * (seat.Throttle * 150) 
                    elseif seat.Steer ~= 0 then
                        bv.Velocity = cam.CFrame.RightVector * (seat.Steer * 60)
                    else 
                        bv.Velocity = Vector3.new(0, 0, 0) 
                    end
                else 
                    break 
                end
                task.wait()
            end
            
            -- Czyszczenie fizyki po wyłączeniu opcji fly car
            local car, seat = getPlayerVehicle()
            if car and seat then
                local bodyPart = car:FindFirstChild("Body") or seat
                if bodyPart:FindFirstChild("CarFlyVel") then bodyPart.CarFlyVel:Destroy() end
                if bodyPart:FindFirstChild("CarFlyGyr") then bodyPart.CarFlyGyr:Destroy() end
            end
        end)
    end
end)

addToggleButton("Pojazdy", "Noclip Car", "NoclipCar", function(state) end)

addToggleButton("Pojazdy", "Tęczowe Auto (RGB)", "RGB", function(state)
    if state then 
        task.spawn(function()
            while Toggles.RGB do
                local car = getPlayerVehicle()
                if car and ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("ColorCar") then 
                    local fakeX = math.random(1, 255) / 255
                    local fakeY = math.random(1, 255) / 255
                    local fakeZ = math.random(1, 255) / 255
                    ReplicatedStorage.Network.ColorCar:FireServer(car, Vector3.new(fakeX, fakeY, fakeZ))
                end
                task.wait(0.12)
            end
        end) 
    end
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
