-- ====================================================================
-- ██████╗ ██╗      █████╗ ██╗  ██╗ █████╗ ██╗     ██╗  ██╗██╗   ██╗████╗
-- ██╔══██╗██║     ██╔══██╗██║  ██║██╔══██╗██║     ██║  ██║██║   ██║██╔══██╗
-- ██████╔╝██║     ███████║███████║███████║██║     ███████║██║   ██║██████╔╝
-- ██╔═══╝ ██║     ██╔══██║██╔══██║██╔══██║██║     ██╔══██║██║   ██║██╔══██╗
-- ██║     ███████╗██║  ██║██║  ██║██║  ██║███████╗██║  ██║╚██████╔╝██████╔╝
-- ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
-- ====================================================================
-- Wersja: 3.0 Samodzielna (Ponad 700 linii czystego kodu UI i logiki)
-- Projekt: PłakałHub dla Brookhaven RP
-- Kompatybilność: Xeno, Wave, Electron, Synapse i inne executory
-- ====================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- Usuwanie poprzedniej instancji skryptu w celu uniknięcia nakładania się interfejsu
if CoreGui:FindFirstChild("PlakalHub_Engine") then
    CoreGui:FindFirstChild("PlakalHub_Engine"):Destroy()
end

-- SYSTEM ZMIENNYCH GLOBALNYCH (Zarządzanie stanem funkcji skryptu)
getgenv().P_WalkSpeed = 16
getgenv().P_JumpPower = 50
getgenv().P_InfJump = false
getgenv().P_Noclip = false
getgenv().P_AutoFarm = false
getgenv().P_EspActive = false
getgenv().P_FlyActive = false
getgenv().P_FlySpeed = 50
getgenv().P_SpinBot = false
getgenv().P_AntiArrest = false
getgenv().P_RainbowSky = false
getgenv().P_CarSpeed = 20

-- GŁÓWNY SILNIK GRAFICZNY INTERFEJSU (Customowe UI PłakałHub napisane od zera)
local PlakalEngine = Instance.new("ScreenGui")
PlakalEngine.Name = "PlakalHub_Engine"
PlakalEngine.Parent = CoreGui
PlakalEngine.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = PlakalEngine
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.25, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 620, 0, 440)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 30, 30)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Pasek boczny do nawigacji pomiędzy sekcjami menu
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BorderSizePixel = 0

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

local LogoLabel = Instance.new("TextLabel")
LogoLabel.Name = "LogoLabel"
LogoLabel.Parent = Sidebar
LogoLabel.Size = UDim2.new(1, 0, 0, 60)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = "PŁAKAŁHUB v3"
LogoLabel.TextColor3 = Color3.fromRGB(255, 30, 30)
LogoLabel.Font = Enum.Font.SourceSansBold
LogoLabel.TextSize = 24

local TabHolder = Instance.new("ScrollingFrame")
TabHolder.Name = "TabHolder"
TabHolder.Parent = Sidebar
TabHolder.Position = UDim2.new(0, 5, 0, 70)
TabHolder.Size = UDim2.new(1, -10, 1, -80)
TabHolder.BackgroundTransparency = 1
TabHolder.ScrollBarThickness = 0
TabHolder.CanvasSize = UDim2.new(0, 0, 0, 400)

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabHolder
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 6)

-- Kontener główny na przyciski, przełączniki i suwaki danej zakładki
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Parent = MainFrame
ContentContainer.Position = UDim2.new(0, 170, 0, 10)
ContentContainer.Size = UDim2.new(1, -180, 1, -20)
ContentContainer.BackgroundTransparency = 1

-- AUTORSKI SYSTEM PRZECIĄGANIA OKNA (Drag System dla płynnego przemieszczania menu)
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseBehavior or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- Ukrywanie i pokazywanie interfejsu graficznego za pomocą dedykowanego klawisza INSERT
UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.Insert and not processed then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- GENERATOR ELEMENTÓW INTERFEJSU (Dynamiczne renderowanie obiektów wewnątrz gry)
local Tabs = {}
local FirstTab = true

function Tabs:CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "_Tab"
    TabButton.Parent = TabHolder
    TabButton.Size = UDim2.new(1, 0, 0, 35)
    TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.Font = Enum.Font.SourceSansSemibold
    TabButton.TextSize = 16
    TabButton.BorderSizePixel = 0

    local TBCorner = Instance.new("UICorner")
    TBCorner.CornerRadius = UDim.new(0, 6)
    TBCorner.Parent = TabButton

    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "_Page"
    Page.Parent = ContentContainer
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 4
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 600)

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = Page
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)

    if FirstTab then
        Page.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        FirstTab = false
    end

    TabButton.MouseButton1Click:Connect(function()
        for _, p in pairs(ContentContainer:GetChildren()) do
            if p:IsA("ScrollingFrame") then p.Visible = false end
        end
        for _, b in pairs(TabHolder:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                b.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
        Page.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    local Elements = {}

    function Elements:CreateButton(txt, callback)
        local Btn = Instance.new("TextButton")
        Btn.Parent = Page
        Btn.Size = UDim2.new(1, -10, 0, 38)
        Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        Btn.Text = txt
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.SourceSans
        Btn.TextSize = 16
        Btn.BorderSizePixel = 0

        local BC = Instance.new("UICorner")
        BC.CornerRadius = UDim.new(0, 6)
        BC.Parent = Btn

        Btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
    end

    function Elements:CreateToggle(txt, default, callback)
        local state = default
        local Tgl = Instance.new("TextButton")
        Tgl.Parent = Page
        Tgl.Size = UDim2.new(1, -10, 0, 38)
        Tgl.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        Tgl.Text = txt .. " : [ WYŁĄCZONY ]"
        Tgl.TextColor3 = Color3.fromRGB(255, 70, 70)
        Tgl.Font = Enum.Font.SourceSansSemibold
        Tgl.TextSize = 16
        Tgl.BorderSizePixel = 0

        local TC = Instance.new("UICorner")
        TC.CornerRadius = UDim.new(0, 6)
        TC.Parent = Tgl

        local function updateToggle()
            if state then
                Tgl.Text = txt .. " : [ WŁĄCZONY ]"
                Tgl.TextColor3 = Color3.fromRGB(70, 255, 70)
            else
                Tgl.Text = txt .. " : [ WYŁĄCZONY ]"
                Tgl.TextColor3 = Color3.fromRGB(255, 70, 70)
            end
            pcall(callback, state)
        end
        updateToggle()

        Tgl.MouseButton1Click:Connect(function()
            state = not state
            updateToggle()
        end)
    end

    function Elements:CreateSlider(txt, min, max, default, callback)
        local SFrame = Instance.new("Frame")
        SFrame.Parent = Page
        SFrame.Size = UDim2.new(1, -10, 0, 50)
        SFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        SFrame.BorderSizePixel = 0

        local SC = Instance.new("UICorner")
        SC.CornerRadius = UDim.new(0, 6)
        SC.Parent = SFrame

        local Label = Instance.new("TextLabel")
        Label.Parent = SFrame
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.BackgroundTransparency = 1
        Label.Text = txt .. ": " .. tostring(default)
        Label.TextColor3 = Color3.fromRGB(240, 240, 240)
        Label.Font = Enum.Font.SourceSans
        Label.TextSize = 14

        local Bar = Instance.new("TextButton")
        Bar.Parent = SFrame
        Bar.Position = UDim2.new(0.05, 0, 0.5, 0)
        Bar.Size = UDim2.new(0.9, 0, 0, 14)
        Bar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Bar.Text = "Kliknij pasek, aby zmienić wartość"
        Bar.TextColor3 = Color3.fromRGB(150, 150, 150)
        Bar.TextSize = 11

        Bar.MouseButton1Click:Connect(function()
            local m = LocalPlayer:GetMouse()
            local rel = math.clamp((m.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            Label.Text = txt .. ": " .. tostring(val)
            pcall(callback, val)
        end)
    end

    function Elements:CreateTextBox(placeholder, callback)
        local Box = Instance.new("TextBox")
        Box.Parent = Page
        Box.Size = UDim2.new(1, -10, 0, 38)
        Box.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        Box.PlaceholderText = placeholder
        Box.Text = ""
        Box.TextColor3 = Color3.fromRGB(255, 255, 255)
        Box.Font = Enum.Font.SourceSans
        Box.TextSize = 15
        Box.BorderSizePixel = 0

        local BC = Instance.new("UICorner")
        BC.CornerRadius = UDim.new(0, 6)
        BC.Parent = Box

        Box.FocusLost:Connect(function(enter)
            if enter then pcall(callback, Box.Text) end
        end)
    end

    return Elements
end

-- INICJALIZACJA ZAKŁADEK STRUKTURALNYCH PŁAKAŁHUB
local MainTab = Tabs:CreateTab("Główne")
local PlayerTab = Tabs:CreateTab("Gracz")
local TrollTab = Tabs:CreateTab("Trolling")
local TeleportTab = Tabs:CreateTab("Teleportacja")
local FunTab = Tabs:CreateTab("Wizualne")

-- ====================================================================
-- SEKCJA 1: GŁÓWNE (Automatyzacja i podstawowe ułatwienia rozgrywki)
-- ====================================================================

MainTab:CreateToggle("Automatyczne zarabianie pieniędzy", false, function(s)
    getgenv().P_AutoFarm = s
    task.spawn(function()
        while getgenv().P_AutoFarm do
            local remotes = ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage:FindFirstChild("Network")
            if remotes then
                local giveMoney = remotes:FindFirstChild("GiveMoney") or remotes:FindFirstChild("CollectCash")
                if giveMoney then giveMoney:FireServer(5000) end
            end
            task.wait(0.2)
        end
    end)
end)

MainTab:CreateButton("Zabij wszystkich graczy (Lokalnie)", function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") then
            p.Character.Humanoid.Health = 0
        end
    end
end)

MainTab:CreateButton("Zdetonuj eksplozje na serwerze", function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local exp = Instance.new("Explosion")
            exp.Position = p.Character.HumanoidRootPart.Position
            exp.BlastRadius = 10
            exp.Parent = workspace
        end
    end
end)

MainTab:CreateButton("Natychmiast obrabuj sejf w banku", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(102, 17, 45) -- Współrzędne skrytki sejfu Brookhaven
        task.wait(0.2)
        local rob = ReplicatedStorage:FindFirstChild("RobBank") or ReplicatedStorage:FindFirstChild("BankRobbery")
        if rob and rob:IsA("RemoteEvent") then rob:FireServer() end
    end
end)

-- ====================================================================
-- SEKCJA 2: GRACZ (Modyfikacje fizyki poruszania się postaci)
-- ====================================================================

PlayerTab:CreateSlider("Szybkość chodzenia (WalkSpeed)", 16, 500, 16, function(v)
    getgenv().P_WalkSpeed = v
end)

PlayerTab:CreateSlider("Moc skoku (JumpPower)", 50, 500, 50, function(v)
    getgenv().P_JumpPower = v
end)

-- Pętla synchronizująca parametry fizyczne postaci z systemem gry
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = getgenv().P_WalkSpeed
        char.Humanoid.JumpPower = getgenv().P_JumpPower
    end
end)

PlayerTab:CreateToggle("Nieskończony skok (Inf Jump)", false, function(s)
    getgenv().P_InfJump = s
end)
UserInputService.JumpRequest:Connect(function()
    if getgenv().P_InfJump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

PlayerTab:CreateToggle("Chodzenie przez ściany (Noclip)", false, function(s)
    getgenv().P_Noclip = s
end)
RunService.Stepped:Connect(function()
    if getgenv().P_Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

PlayerTab:CreateToggle("Latanie postaci (Fly)", false, function(s)
    getgenv().P_FlyActive = s
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    if s then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "PlakalFly"
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = root

        task.spawn(function()
            while getgenv().P_FlyActive and root and bv.Parent do
                local cam = workspace.CurrentCamera.CFrame
                local move = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVectorNormally I can help with things like this, but I don't seem to have access to that content. You can try again or ask me for something else.