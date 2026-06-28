--[[
    ShinyHub V4 - Brookhaven RP (Xeno Executor)
    Dodano: L-Tool, Scuba-Tool, RGB Car (Gamepass), Noclip, Slidery, Gatling Tools.
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if CoreGui:FindFirstChild("ShinyHubMenu") then CoreGui.ShinyHubMenu:Destroy() end

-- Zmienna globalna tęczy dla auta i tekstu
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
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true

local TabPanel = Instance.new("Frame", MainFrame)
TabPanel.Size = UDim2.new(0, 130, 1, -45)
TabPanel.Position = UDim2.new(0, 0, 0, 45)
TabPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabPanel.BorderSizePixel = 0

local ContentPanel = Instance.new("Frame", MainFrame)
ContentPanel.Size = UDim2.new(1, -140, 1, -55)
ContentPanel.Position = UDim2.new(0, 135, 0, 50)
ContentPanel.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Text = "★ SHINYHUB V4 - BROOKHAVEN ★"
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
    
    local track = Instance.new("Frame", track)
    track = Instance.new("Frame", sliderFrame)
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
    
    button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
end

-- Zakładki
local mainTab = createTab("Ruch")
local combatTab = createTab("Bronie")
local vehicleTab = createTab("Pojazdy")
local funTab = createTab("Animacje / Trolle")

-- ==========================================
-- ZAKŁADKA: RUCH (Suwaki, Fly, Noclip)
-- ==========================================
addSlider("Ruch", "Prędkość (Speed)", 16, 250, 16, function(value)
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = value end
end)

addSlider("Ruch", "Siła Skoku (JumpPower)", 50, 400, 50, function(value)
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true; hum.JumpPower = value end
end)

local noclip = false
addButton("Ruch", "Noclip (Przechodzenie przez ściany)", function()
    noclip = not noclip
    if noclip then
        local connection
        connection = RunService.Stepped:Connect(function()
            if not noclip then connection:Disconnect() return end
            if Player.Character then
                for _, part in pairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end
end)

local flying = false
local flySpeed = 60
local bVel, bGyr
addButton("Ruch", "Latanie (Fly)", function()
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
-- ZAKŁADKA: BRONIE (Ekwipunek)
-- ==========================================
addButton("Bronie", "Daj Wszystkie Bronie i Przedmioty", function()
    pcall(function()
        local items = ReplicatedStorage:FindFirstChild("Tools") or ReplicatedStorage:FindFirstChild("Items") or ReplicatedStorage
        for _, obj in pairs(items:GetDescendants()) do
            if obj:IsA("Tool") then
                local clone = obj:Clone()
                clone.Parent = Player.Backpack
            end
        end
        local playerGui = Player:FindFirstChildOfClass("PlayerGui")
        if playerGui and playerGui:FindFirstChild("Inventory") then
            for _, item in pairs(playerGui.Inventory:GetDescendants()) do
                if item:IsA("Tool") then item:Clone().Parent = Player.Backpack end
            end
        end
    end)
end)

local glitchActive = false
addButton("Bronie", "Gatling Mode (Szybkie Miganie Broni)", function()
    glitchActive = not glitchActive
    if not glitchActive then return end
    task.spawn(function()
        while glitchActive do
            local char = Player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
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

-- ==========================================
-- ZAKŁADKA: POJAZDY (Działające RGB z GP)
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

-- ==========================================
-- ZAKŁADKA: ANIMACJE / TROLLE (Jerk, L-Tool, Scuba)
-- ==========================================
addButton("Animacje / Trolle", "Daj Jerk Tool", function()
    local tool = Instance.new("Tool", Player.Backpack)
    tool.Name = "Jerk Tool"
    tool.RequiresHandle = false
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://148840371"
    local track
    tool.Equipped:Connect(function()
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then track = hum:LoadAnimation(anim); track.Looped = true; track:Play() end
    end)
    tool.Unequipped:Connect(function() if track then track:Stop() end end)
end)

addButton("Animacje / Trolle", "Daj L-Tool (Take the L)", function()
    local tool = Instance.new("Tool", Player.Backpack)
    tool.Name = "L-Tool"
    tool.RequiresHandle = false
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://4295417122" -- Oficjalny taniec L (Emote)
    local track
    tool.Equipped:Connect(function()
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then track = hum:LoadAnimation(anim); track.Looped = true; track:Play() end
    end)
    tool.Unequipped:Connect(function() if track then track:Stop() end end)
end)

addButton("Animacje / Trolle", "Daj ScubaTool (Scuba Dance)", function()
    local tool = Instance.new("Tool", Player.Backpack)
    tool.Name = "ScubaTool"
    tool.RequiresHandle = false
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://16124192661" -- Viralowy i aktualny trend Scuba Dance
    local track
    tool.Equipped:Connect(function()
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then track = hum:LoadAnimation(anim); track.Looped = true; track:Play() end
    end)
    tool.Unequipped:Connect(function() if track then track:Stop() end end)
end)

-- Przycisk Zamknij
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
    rgbCarActive = false
    glitchActive = false
    flying = false
    noclip = false
    ScreenGui:Destroy()
end)
