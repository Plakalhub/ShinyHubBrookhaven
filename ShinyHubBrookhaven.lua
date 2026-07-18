--[[
    ShinyHub V5 - Brookhaven Mobile Compact & Troll Edition (2026) - 10 NEW TROLL OPTIONS
    - COMPACT GUI: Zoptymalizowane skalowanie pod telefony.
    - RP NAME FIX: Bezpieczna pętla sprawdzająca i nadająca nick RP.
    - FLY FIX: Stabilne latanie 3D kierowane kamerą.
    - NOCLIP FIX: Nowa, niezawodna metoda przenikania (Humanoid State & Collision Bypass).
    - TROLLING UPDATE: Dodano 10 nowych opcji trollerskich dla Brookhaven.
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Zmienne trollingu
local SelectedTarget = ""
local AnnoyLoop = nil
local FreezeLoop = nil
local VoidLoopCon = nil

-- STABILNY SYSTEM ZMIANY RP NAME
task.spawn(function()
    local welcomeText = "Welcome, thank you for using this hub ~majku ~itzz_dekl1"
    if not Player.Character then Player.CharacterAdded:Wait() end
    local char = Player.Character or Player.CharacterAdded:Wait()
    char:WaitForChild("HumanoidRootPart", 10)
    task.wait(2)
    
    for i = 1, 5 do
        local rpNameEvent = ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("SetIdentity")
        if rpNameEvent then
            rpNameEvent:FireServer(welcomeText, "Gold", "Hub Users")
            break
        else
            for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                if v:IsA("RemoteEvent") and v.Name == "SetIdentity" then
                    v:FireServer(welcomeText, "Gold", "Hub Users")
                    break
                end
            end
        end
        task.wait(1)
    end
end)

-- Czyszczenie starego GUI
if CoreGui:FindFirstChild("ShinyHubMenu") then 
    pcall(function() CoreGui.ShinyHubMenu:Destroy() end) 
end

local Toggles = {
    Noclip = false, Fly = false, InfJump = false, Gatling = false,
    RGB = false, Horn = false, ESP = false, SafeNoclip = false, Fullbright = false,
    FlyCar = false, NoclipCar = false
}

local ActiveAnimations = {}
local currentHue = 0
task.spawn(function()
    while true do
        currentHue = (tick() % 4) / 4
        task.wait()
    end
end)

-- Funkcje pomocnicze
local function getCurrentVehicle()
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        local seat = Player.Character:FindFirstChildOfClass("Humanoid").SeatPart
        if seat and seat:IsA("VehicleSeat") and seat.Parent then
            return seat.Parent, seat
        end
    end
    return nil, nil
end

local function getPlayerFromSubstring(str)
    if str == "" then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #str) == str:lower() or p.DisplayName:lower():sub(1, #str) == str:lower() then
            return p
        end
    end
    return nil
end

local function toggleAnimation(animID, btn)
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if ActiveAnimations[animID] then
        pcall(function() ActiveAnimations[animID]:Stop() ActiveAnimations[animID]:Destroy() end)
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
-- INTERFEJS GRAFICZNY
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShinyHubMenu"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0.45, 0, 0.55, 0)
MainFrame.Position = UDim2.new(0.30, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
MainFrame.BorderSizePixel = 2

local MiniFrame = Instance.new("Frame", ScreenGui)
MiniFrame.Size = UDim2.new(0.12, 0, 0.05, 0)
MiniFrame.Position = UDim2.new(0.02, 0, 0.05, 0)
MiniFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MiniFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
MiniFrame.BorderSizePixel = 2
MiniFrame.Visible = false

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

local MiniTitle = Instance.new("TextLabel", MiniFrame)
MiniTitle.Size = UDim2.new(0.7, 0, 1, 0)
MiniTitle.BackgroundTransparency = 1
MiniTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniTitle.Text = " ShinyHub"
MiniTitle.Font = Enum.Font.SourceSansBold
MiniTitle.TextScaled = true
MiniTitle.TextXAlignment = Enum.TextXAlignment.Left

local MaximizeBtn = Instance.new("TextButton", MiniFrame)
MaximizeBtn.Size = UDim2.new(0.3, 0, 1, 0)
MaximizeBtn.Position = UDim2.new(0.7, 0, 0, 0)
MaximizeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
MaximizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
MaximizeBtn.Text = "+"
MaximizeBtn.Font = Enum.Font.SourceSansBold
MaximizeBtn.TextScaled = true
MaximizeBtn.BorderSizePixel = 0
MaximizeBtn.MouseButton1Click:Connect(function() MiniFrame.Visible = false MainFrame.Visible = true end)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(0.88, 0, 0.10, 0)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Text = "★ SHINYHUB V5 ★"
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true

local MinimizeBtn = Instance.new("TextButton", MainFrame)
MinimizeBtn.Size = UDim2.new(0.12, 0, 0.10, 0)
MinimizeBtn.Position = UDim2.new(0.88, 0, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 160, 0)
MinimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
MinimizeBtn.Text = "−"
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextScaled = true
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false MiniFrame.Visible = true end)

local TabPanel = Instance.new("Frame", MainFrame)
TabPanel.Size = UDim2.new(0.28, 0, 0.90, 0)
TabPanel.Position = UDim2.new(0, 0, 0.10, 0)
TabPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TabPanel.BorderSizePixel = 0

local ContentPanel = Instance.new("Frame", MainFrame)
ContentPanel.Size = UDim2.new(0.70, 0, 0.90, 0)
ContentPanel.Position = UDim2.new(0.29, 0, 0.10, 0)
ContentPanel.BackgroundTransparency = 1

local tabs = {}
local activeTab = nil
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
    tabBtn.BorderSizePixel = 0
    tabCount = tabCount + 1
    
    local scroll = Instance.new("ScrollingFrame", ContentPanel)
    scroll.Size = UDim2.new(1, -2, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.Visible = false
    scroll.CanvasSize = UDim2.new(0, 0, 0, 550)
    scroll.ScrollBarThickness = 2
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 3)
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do t.scroll.Visible = false t.btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24) t.btn.TextColor3 = Color3.fromRGB(200, 200, 200) end
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
    btn.Size = UDim2.new(1, -4, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 11
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(50, 50, 50)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

local function addAnimButton(tabName, text, animID)
    local scroll = tabs[tabName].scroll
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -4, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(50, 50, 50)
    btn.MouseButton1Click:Connect(function() toggleAnimation(animID, btn) end)
end

local function addToggleButton(tabName, text, toggleKey, callback)
    local scroll = tabs[tabName].scroll
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -4, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
    btn.TextColor3 = Color3.fromRGB(255, 120, 120)
    btn.Text = text .. " [OFF]"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 10
    
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

-- Rejestracja zakładek
createTab("Ruch")
createTab("Ekwipunek")
createTab("Pojazdy")
createTab("Animacje")
createTab("Trolling")
createTab("Teleport")
createTab("Wizualne")

-- ==========================================
-- ZAKŁADKA TROLLINGU (10 NOWYCH OPCJI)
-- ==========================================
local scrollTroll = tabs["Trolling"].scroll

local UserSelector = Instance.new("TextBox", scrollTroll)
UserSelector.Size = UDim2.new(1, -4, 0, 26)
UserSelector.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
UserSelector.TextColor3 = Color3.fromRGB(255, 255, 0)
UserSelector.PlaceholderText = "Wpisz nick celu..."
UserSelector.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
UserSelector.Text = ""
UserSelector.Font = Enum.Font.SourceSansBold
UserSelector.TextSize = 12
UserSelector.BorderSizePixel = 1
UserSelector.BorderColor3 = Color3.fromRGB(255, 255, 0)

UserSelector:GetPropertyChangedSignal("Text"):Connect(function()
    SelectedTarget = UserSelector.Text
end)

-- 1. BALL KILL
addButton("Trolling", "⚽ BALL KILL (Zabij Piłką)", function()
    local targetPlayer = getPlayerFromSubstring(SelectedTarget)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local char = Player.Character local hrp = char and char:FindFirstChild("HumanoidRootPart") local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    local ball = Player.Backpack:FindFirstChild("SoccerBall") or Player.Character:FindFirstChild("SoccerBall")
    if not ball then for _, v in pairs(ReplicatedStorage:GetDescendants()) do if v:IsA("Tool") and v.Name:lower():find("ball") then ball = v:Clone() ball.Parent = Player.Backpack break end end end
    if ball then
        hum:EquipTool(ball) task.wait(0.1)
        local targetHrp = targetPlayer.Character.HumanoidRootPart local origCFrame = hrp.CFrame
        local bV = Instance.new("BodyVelocity", hrp) bV.MaxForce = Vector3.new(math.huge, math.huge, math.huge) bV.Velocity = Vector3.new(9999, 9999, 9999)
        local bAV = Instance.new("BodyAngularVelocity", hrp) bAV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) bAV.AngularVelocity = Vector3.new(9999, 9999, 9999)
        for i = 1, 30 do if targetHrp and hrp then hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 0.2) for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end task.wait(0.02) end
        bV:Destroy() bAV:Destroy() hrp.Velocity = Vector3.new(0,0,0) hrp.RotVelocity = Vector3.new(0,0,0) task.wait(0.1) hrp.CFrame = origCFrame
    end
end)

-- 2. STROLLER VOID
addButton("Trolling", "🛒 STROLLER VOID (Wózek w próżnię)", function()
    local targetPlayer = getPlayerFromSubstring(SelectedTarget)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local char = Player.Character local hrp = char and char:FindFirstChild("HumanoidRootPart") local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    local stroller = Player.Backpack:FindFirstChild("Stroller") or Player.Character:FindFirstChild("Stroller")
    if not stroller then for _, v in pairs(ReplicatedStorage:GetDescendants()) do if v:IsA("Tool") and v.Name:lower():find("stroller") then stroller = v:Clone() stroller.Parent = Player.Backpack break end end end
    if stroller then
        local savedPos = hrp.CFrame hum:EquipTool(stroller) task.wait(0.2)
        local targetHrp = targetPlayer.Character.HumanoidRootPart
        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, -1) task.wait(0.3)
        if targetHrp then hrp.CFrame = CFrame.new(0, -350, 0) task.wait(0.4) hrp.CFrame = savedPos end
    end
end)

-- 3. FLING TARGET (Wywalenie gracza)
addButton("Trolling", "🌪️ FLING TARGET (Wywal Gracza)", function()
    local targetPlayer = getPlayerFromSubstring(SelectedTarget)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local char = Player.Character local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local origCF = hrp.CFrame
    local bAV = Instance.new("BodyAngularVelocity", hrp)
    bAV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bAV.AngularVelocity = Vector3.new(0, 99999, 0)
    for i = 1, 50 do
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
        end
        task.wait(0.01)
    end
    bAV:Destroy() hrp.Velocity = Vector3.new(0,0,0) hrp.RotVelocity = Vector3.new(0,0,0) hrp.CFrame = origCF
end)

-- 4. BRING TARGET (Przyciągnij - Wymaga wózka/narzędzia w Brookhaven)
addButton("Trolling", "🧲 BRING TARGET (Przyciągnij)", function()
    local targetPlayer = getPlayerFromSubstring(SelectedTarget)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local char = Player.Character local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local saved = hrp.CFrame
    hrp.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-1)
    task.wait(0.2)
    hrp.CFrame = saved
end)

-- 5. ATTACH (Przyczep się do pleców)
addButton("Trolling", "📌 ATTACH (Przyczep do pleców)", function()
    local targetPlayer = getPlayerFromSubstring(SelectedTarget)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    if AnnoyLoop then AnnoyLoop:Disconnect() AnnoyLoop = nil end
    AnnoyLoop = RunService.Heartbeat:Connect(function()
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
        end
    end)
end)

-- 6. ANNOY LOOP (Lataj wokół głowy)
addButton("Trolling", "🐝 ANNOY LOOP (Irytuj)", function()
    local targetPlayer = getPlayerFromSubstring(SelectedTarget)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    if AnnoyLoop then AnnoyLoop:Disconnect() AnnoyLoop = nil end
    AnnoyLoop = RunService.Heartbeat:Connect(function()
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local angle = tick() * 10
            Player.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(math.sin(angle)*3, 3, math.cos(angle)*3)
        end
    end)
end)

-- 7. STOP ANNOY/ATTACH
addButton("Trolling", "❌ STOP ANNOY / ATTACH", function()
    if AnnoyLoop then AnnoyLoop:Disconnect() AnnoyLoop = nil end
end)

-- 8. JAIL TARGET (Bariera z rekwizytów Brookhaven)
addButton("Trolling", "🧱 JAIL TARGET (Zamknij w klatce)", function()
    local targetPlayer = getPlayerFromSubstring(SelectedTarget)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local tHrp = targetPlayer.Character.HumanoidRootPart
    if ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("BuildProp") then
        for i = 1, 4 do
            local angle = (i * math.pi) / 2
            local cf = tHrp.CFrame * CFrame.new(math.sin(angle)*4, 0, math.cos(angle)*4)
            ReplicatedStorage.Network.BuildProp:FireServer("Barricade", cf.Position, cf.Rotation)
        end
    end
end)

-- 9. FREEZE TARGET (Zamroź gracza)
addButton("Trolling", "❄️ FREEZE TARGET (Zamroź)", function()
    local targetPlayer = getPlayerFromSubstring(SelectedTarget)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local lockedCF = targetPlayer.Character.HumanoidRootPart.CFrame
    if FreezeLoop then FreezeLoop:Disconnect() FreezeLoop = nil end
    FreezeLoop = RunService.Heartbeat:Connect(function()
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            targetPlayer.Character.HumanoidRootPart.CFrame = lockedCF
            targetPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end
    end)
end)
addButton("Trolling", "🔥 UNFREEZE (Odmroź)", function() if FreezeLoop then FreezeLoop:Disconnect() FreezeLoop = nil end end)

-- 10. TRIP TARGET (Przewróć)
addButton("Trolling", "🦵 TRIP TARGET (Podetnij Nogi)", function()
    local targetPlayer = getPlayerFromSubstring(SelectedTarget)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local old = hrp.CFrame
        hrp.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
        task.wait(0.1)
        hrp.CFrame = old
    end
end)

-- 11. LAG TARGET (Spamuj eventami wokół gracza)
addButton("Trolling", "💥 LAG TARGET (Zlaguj)", function()
    local targetPlayer = getPlayerFromSubstring(SelectedTarget)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    task.spawn(function()
        for i = 1, 50 do
            if ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("PlaySound") then
                ReplicatedStorage.Network.PlaySound:FireServer("Klakson", targetPlayer.Character.HumanoidRootPart.Position)
            end
            task.wait(0.01)
        end
    end)
end)

-- 12. SPAM SOUND (Hałasuj u celu)
addButton("Trolling", "🔊 SPAM SOUND (Spamuj dźwiękiem)", function()
    local targetPlayer = getPlayerFromSubstring(SelectedTarget)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    task.spawn(function()
        for i = 1, 30 do
            if ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("PlaySound") then
                ReplicatedStorage.Network.PlaySound:FireServer("Bell", targetPlayer.Character.HumanoidRootPart.Position)
            end
            task.wait(0.05)
        end
    end)
end)

-- 13. VOID LOOP TARGET (Pętla zrzucania pod mapę)
addButton("Trolling", "🕳️ VOID LOOP TARGET (Do Próżni)", function()
    local targetPlayer = getPlayerFromSubstring(SelectedTarget)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    if VoidLoopCon then VoidLoopCon:Disconnect() VoidLoopCon = nil end
    VoidLoopCon = RunService.Heartbeat:Connect(function()
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            targetPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPlayer.Character.HumanoidRootPart.Position.X, -300, targetPlayer.Character.HumanoidRootPart.Position.Z)
        end
    end)
end)
addButton("Trolling", "❌ STOP VOID LOOP", function() if VoidLoopCon then VoidLoopCon:Disconnect() VoidLoopCon = nil end end)


-- ==========================================
-- INNE SEKCJE (RUCH, POJAZDY ITD.)
-- ==========================================

-- 1. RUCH
addButton("Ruch", "Super Bieg (WalkSpeed 100)", function() if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 100 end end)
addButton("Ruch", "Mega Skok (JumpPower 150)", function() local h = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") if h then h.UseJumpPower = true h.JumpPower = 150 end end)

addToggleButton("Ruch", "Przenikanie (Noclip)", "Noclip", function(state)
    if state then
        _G.NoclipLoop = RunService.Stepped:Connect(function()
            if Toggles.Noclip and Player.Character then
                for _, part in pairs(Player.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
                local hum = Player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end
            end
        end)
    else
        if _G.NoclipLoop then _G.NoclipLoop:Disconnect() _G.NoclipLoop = nil end
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
end)

addToggleButton("Ruch", "Latanie (3D Fly Mode)", "Fly", function(state)
    local char = Player.Character local hrp = char and char:FindFirstChild("HumanoidRootPart") local cam = workspace.CurrentCamera
    if state and hrp and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        _G.BVel = Instance.new("BodyVelocity", hrp) _G.BVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        _G.BGyr = Instance.new("BodyGyro", hrp) _G.BGyr.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while Toggles.Fly and hrp and hum do
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then _G.BVel.Velocity = cam.CFrame.LookVector * 70 else _G.BVel.Velocity = Vector3.new(0, 0, 0) end
                _G.BGyr.CFrame = cam.CFrame task.wait()
            end
        end)
    else 
        if _G.BVel then _G.BVel:Destroy() _G.BVel = nil end if _G.BGyr then _G.BGyr:Destroy() _G.BGyr = nil end 
    end
end)
addToggleButton("Ruch", "Nieskończony Skok", "InfJump", function(state)
    if state then _G.JumpCon = UserInputService.JumpRequest:Connect(function() local h = Player.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end)
    else if _G.JumpCon then _G.JumpCon:Disconnect() end end
end)
addButton("Ruch", "Szybki Reset Postaci", function() if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").Health = 0 end end)

-- 2. EKWIPUNEK
addButton("Ekwipunek", "Weź Wszystkie Narzędzia", function()
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

-- 3. POJAZDY
addToggleButton("Pojazdy", "Tęczowe Auto (RGB Mode)", "RGB", function(state)
    if state then task.spawn(function()
        while Toggles.RGB do
            pcall(function() local car = getCurrentVehicle() if car and ReplicatedStorage:FindFirstChild("Network") then ReplicatedStorage.Network.ColorCar:FireServer(car, Color3.fromHSV(currentHue, 1, 1)) end end)
            task.wait(0.05)
        end
    end) end
end)

addToggleButton("Pojazdy", "Latanie Autem (Fly Car)", "FlyCar", function(state)
    local cam = workspace.CurrentCamera
    if state then
        task.spawn(function()
            while Toggles.FlyCar do
                local car, seat = getCurrentVehicle()
                if car and seat then
                    local bodyPart = car:FindFirstChild("Body") or seat
                    if bodyPart then
                        if not bodyPart:FindFirstChild("CarFlyVel") then
                            local bv = Instance.new("BodyVelocity") bv.Name = "CarFlyVel" bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) bv.Parent = bodyPart
                            local bg = Instance.new("BodyGyro") bg.Name = "CarFlyGyr" bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) bg.Parent = bodyPart
                        end
                        local bv = bodyPart.CarFlyVel local bg = bodyPart.CarFlyGyr bg.CFrame = cam.CFrame
                        if seat.Throttle ~= 0 or seat.Steer ~= 0 then bv.Velocity = cam.CFrame.LookVector * (seat.Throttle * 80) + cam.CFrame.RightVector * (seat.Steer * 40) else bv.Velocity = Vector3.new(0, 0, 0) end
                    end
                else Toggles.FlyCar = false break end
                task.wait()
            end
            local car, seat = getCurrentVehicle() if car and seat then local bodyPart = car:FindFirstChild("Body") or seat if bodyPart:FindFirstChild("CarFlyVel") then bodyPart.CarFlyVel:Destroy() end if bodyPart:FindFirstChild("CarFlyGyr") then bodyPart.CarFlyGyr:Destroy() end end
        end)
    end
end)

addToggleButton("Pojazdy", "Przenikanie Auta (Noclip)", "NoclipCar", function(state)
    if state then
        _G.CarNoclipLoop = RunService.Stepped:Connect(function()
            if Toggles.NoclipCar then
                local car = getCurrentVehicle()
                if car then
                    for _, part in pairs(car:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
                    if Player.Character then for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
                else if _G.CarNoclipLoop then _G.CarNoclipLoop:Disconnect() _G.CarNoclipLoop = nil end Toggles.NoclipCar = false end
            end
        end)
    else if _G.CarNoclipLoop then _G.CarNoclipLoop:Disconnect() _G.CarNoclipLoop = nil end end
end)

-- 4. ANIMACJE
addAnimButton("Animacje", "Jerk Tool / Flex", 507371109)
addAnimButton("Animacje", "Take the L", 333833446)
addAnimButton("Animacje", "Zombie Walk", 35654637)
addButton("Animacje", "WYŁĄCZ ANIMACJE", function() stopAllAnimations() end)

-- 5. TELEPORTACJA
local function tpl(cf) if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then Player.Character.HumanoidRootPart.CFrame = cf end end
addButton("Teleport", "Bank & Sejf", function() tpl(CFrame.new(-22, 10, 52)) end)
addButton("Teleport", "Posterunek Policji", function() tpl(CFrame.new(-42, 11, 28)) end)

-- 6. WIZUALNE
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

-- ZAMKNIĘCIE INTERFEJSU
local CloseBtn = Instance.new("TextButton", TabPanel)
CloseBtn.Size = UDim2.new(1, 0, 0, 24)
CloseBtn.Position = UDim2.new(0, 0, 1, -24)
CloseBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "WYŁĄCZ HUB"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 10
CloseBtn.BorderSizePixel = 0
CloseBtn.MouseButton1Click:Connect(function()
    stopAllAnimations()
    if AnnoyLoop then AnnoyLoop:Disconnect() end
    if FreezeLoop then FreezeLoop:Disconnect() end
    if VoidLoopCon then VoidLoopCon:Disconnect() end
    for k, _ in pairs(Toggles) do Toggles[k] = false end
    if _G.NoclipLoop then _G.NoclipLoop:Disconnect() _G.NoclipLoop = nil end
    if _G.CarNoclipLoop then _G.CarNoclipLoop:Disconnect() _G.CarNoclipLoop = nil end
    if _G.BVel then _G.BVel:Destroy() _G.BVel = nil end
    if _G.BGyr then _G.BGyr:Destroy() _G.BGyr = nil end
    if _G.JumpCon then _G.JumpCon:Disconnect() end
    if _G.ESPTrack then _G.ESPTrack:Disconnect() end
    ScreenGui:Destroy()
end)
