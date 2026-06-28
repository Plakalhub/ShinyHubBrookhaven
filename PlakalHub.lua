--[[
    ShinyHub V3 - Brookhaven RP (Xeno Executor)
    Dodano: Suwak Prędkości, Suwak Skoku, Wszystkie Bronie (Gatling Backpack Glitch).
    Usunięto: Niedziałające funkcje RGB/Radio zablokowane przez serwer gry.
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

if CoreGui:FindFirstChild("ShinyHubMenu") then CoreGui.ShinyHubMenu:Destroy() end

-- ==========================================
-- INTERFEJS UŻYTKOWNIKA (ŻÓŁTO-CZARNY Z ZAKŁADKAMI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ShinyHubMenu"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
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
Title.Text = "★ SHINYHUB V3 - BROOKHAVEN ★"
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
    scroll.CanvasSize = UDim2.new(0, 0, 0, 550)
    scroll.ScrollBarThickness = 4
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    
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

-- FUNKCJA TWORZENIA SUWAKA (SLIDER)
local function addSlider(tabName, text, min, max, default, callback)
    local scroll = tabs[tabName].scroll
    local sliderFrame = Instance.new("Frame", scroll)
    sliderFrame.Size = UDim2.new(1, -10, 0, 50)
    sliderFrame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", sliderFrame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.Text = text .. ": " .. tostring(default)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local track = Instance.new("Frame", sliderFrame)
    track.Size = UDim2.new(1, 0, 0, 10)
    track.Position = UDim2.new(0, 0, 0, 25)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    track.BorderSizePixel = 0
    
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    fill.BorderSizePixel = 0
    
    local button = Instance.new("TextButton", track)
    button.Size = UDim2.new(0, 16, 0, 16)
    button.Position = UDim2.new((default - min) / (max - min), -8, 0, -3)
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = ""
    
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        button.Position = UDim2.new(pos, -8, 0, -3)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local value = math.floor(min + (pos * (max - min)))
        label.Text = text .. ": " .. tostring(value)
        callback(value)
    end
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)
end

-- Tworzenie zakładek
local mainTab = createTab("Statystyki")
local combatTab = createTab("Bronie")
local teleportTab = createTab("Teleporty")
local funTab = createTab("Inne")

-- ==========================================
-- ZAKŁADKA: STATYSTYKI (Suwaki i Fly)
-- ==========================================
addSlider("Statystyki", "Prędkość Chodzenia (Speed)", 16, 250, 16, function(value)
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = value end
end)

addSlider("Statystyki", "Siła Skoku (JumpPower)", 50, 400, 50, function(value)
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then 
        hum.UseJumpPower = true
        hum.JumpPower = value 
    end
end)

local flying = false
local flySpeed = 60
local bVel, bGyr
addButton("Statystyki", "Latanie (Fly) Włącz/Wyłącz", function()
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

-- ==========================================
-- ZAKŁADKA: BRONIE (Gatling Glitch i Ekwipunek)
-- ==========================================
addButton("Bronie", "Daj Wszystkie Bronie/Narzędzia", function()
    -- Pobieranie wszystkich przedmiotów przechowywanych w pamięci Brookhaven
    pcall(function()
        local storage = game:GetService("ReplicatedStorage"):FindFirstChild("Tools") or game:GetService("ReplicatedStorage")
        for _, tool in pairs(storage:GetDescendants()) do
            if tool:IsA("Tool") then
                local clone = tool:Clone()
                clone.Parent = Player.Backpack
            end
        end
    end)
end)

local glitchActive = false
addButton("Bronie", "Gatling Mode (Miganie Wszystkich Broni)", function()
    glitchActive = not glitchActive
    if not glitchActive then return end
    
    task.spawn(function()
        while glitchActive do
            local char = Player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and Player.Backpack then
                local tools = Player.Backpack:GetChildren()
                for _, tool in pairs(tools) do
                    if tool:IsA("Tool") and glitchActive then
                        hum:EquipTool(tool)
                        task.wait(0.01) -- Szalenie szybka zmiana dłoni
                    end
                end
            end
            task.wait()
        end
    end)
end)

-- ==========================================
-- ZAKŁADKA: TELEPORTY
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
-- ZAKŁADKA: INNE
-- ==========================================
addButton("Inne", "Włącz ESP (Prześwietlenie graczy)", function()
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

addButton("Inne", "Noclip Przez Ściany Sejfu", function()
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
    glitchActive = false
    flying = false
    ScreenGui:Destroy()
end)
