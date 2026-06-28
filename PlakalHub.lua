--[[
    ShinyHub - Brookhaven Premium Edition (Xeno Bypass)
    Zaktualizowane metody dla RGB, Radia oraz RP Name.
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("ShinyHubMenu") then
    CoreGui.ShinyHubMenu:Destroy()
end

-- ==========================================
-- [1] SKUTECZNA ZMIANA RP NAME + RGB TEXT
-- ==========================================
local function applyShinyName()
    -- Metoda 1: Szukanie oficjalnego panelu rejestracji Brookhaven (Bypass zdalny)
    local Network = ReplicatedStorage:FindFirstChild("Network")
    if Network then
        local remote = Network:FindFirstChild("SetRPName") or Network:FindFirstChild("UpdateName") or Network:FindFirstChild("EditIdentity")
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer("ShinyHub")
        end
    end

    -- Metoda 2: Agresywny lokalny Override nad głową (Działa, nawet jak serwer blokuje)
    task.spawn(function()
        while task.wait(0.1) do
            local char = Player.Character
            if char and char:FindFirstChild("Head") then
                -- Szukanie dowolnego obiektu typu BillboardGui nad głową postaci
                for _, bGui in pairs(char.Head:GetChildren()) do
                    if bGui:IsA("BillboardGui") then
                        local text = bGui:FindFirstChildOfClass("TextLabel")
                        if text then
                            text.Text = "ShinyHub"
                            local hue = (tick() % 3) / 3
                            text.TextColor3 = Color3.fromHSV(hue, 1, 1)
                        end
                    end
                end
                
                -- Szukanie w obiekcie Nametag/Overhead, jeśli jest w samej postaci
                local nameTag = char:FindFirstChild("Nametag") or char:FindFirstChild("Overhead")
                if nameTag then
                    local text = nameTag:FindFirstChildOfClass("TextLabel")
                    if text then
                        text.Text = "ShinyHub"
                        local hue = (tick() % 3) / 3
                        text.TextColor3 = Color3.fromHSV(hue, 1, 1)
                    end
                end
            end
        end
    end)
end

task.spawn(applyShinyName)
Player.CharacterAdded:Connect(function()
    task.wait(1.5)
    applyShinyName()
end)

-- ==========================================
-- [2] INTERFEJS UŻYTKOWNIKA (MENU)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ShinyHubMenu"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 420, 0, 520)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Text = "★ SHINYHUB - BROOKHAVEN FIXED ★"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

local ScrollingFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollingFrame.Size = UDim2.new(1, -20, 1, -110)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 55)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 480)
ScrollingFrame.ScrollBarThickness = 6

local UIListLayout = Instance.new("UIListLayout", ScrollingFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

local function createButton(text, callback)
    local btn = Instance.new("TextButton", ScrollingFrame)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 0)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.BorderColor3 = Color3.fromRGB(255, 255, 0)
    btn.BorderSizePixel = 1
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ==========================================
-- [3] SYSTEM RADIA (WYMUSZONY BYPASS)
-- ==========================================
-- Brookhaven łapie eventy bezpośrednio z narzędzia (Tool) lub auta. 
-- Jeśli serwer odrzuca pakiety, ten kod odpala muzykę lokalnie na najwyższym priorytecie.
local function playRadio(id)
    local fired = false
    
    -- Szukanie autentycznego eventu audio w strukturze Brookhaven
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("audio") or v.Name:lower():find("sound") or v.Name:lower():find("radio")) then
            v:FireServer(tostring(id))
            fired = true
        end
    end
    
    -- Jeżeli serwer zablokował (Brak gamepassa), odpala dźwięk u Ciebie 3D (słyszysz go idealnie w grze)
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local sound = hrp:FindFirstChild("ShinyHubAudio") or Instance.new("Sound", hrp)
        sound.Name = "ShinyHubAudio"
        sound.SoundId = "rbxassetid://" .. tostring(id)
        sound.Volume = 3
        sound.RollOffMaxDistance = 150
        sound.RollOffMinDistance = 10
        sound:Play()
    end
end

createButton("Radio: Muzyka (Test)", function() playRadio(1837946285) end)
createButton("Straszny dźwięk 1 (Krzyk)", function() playRadio(9069609268) end)
createButton("Straszny dźwięk 2 (Mroczny Śmiech)", function() playRadio(9061011306) end)

-- ==========================================
-- [4] AUTOMATYCZNE I PŁYNNE RGB CAR (FORSOWANE)
-- ==========================================
local rgbCarActive = false
createButton("RGB Car (Włącz / Wyłącz)", function()
    rgbCarActive = not rgbCarActive
    if not rgbCarActive then return end
    
    task.spawn(function()
        while rgbCarActive do
            local workspaceVehicles = workspace:FindFirstChild("Vehicles") or workspace
            local char = Player.Character
            local myCar = nil
            
            -- Szukanie pojazdu przypisanego do gracza
            for _, veh in pairs(workspaceVehicles:GetChildren()) do
                if veh:FindFirstChild("Owner") and veh.Owner.Value == Player then
                    myCar = veh
                    break
                end
            end
            
            -- Jeśli nie znaleziono po Ownerze, szukaj po fotelu kierowcy
            if not myCar and char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
                    myCar = hum.SeatPart.Parent
                end
            end
            
            -- Malowanie całego pojazdu (Bypass zabezpieczeń Brookhaven)
            if myCar then
                local hue = (tick() % 4) / 4
                local color = Color3.fromHSV(hue, 1, 1)
                
                -- Aktualizacja koloru przez event gry (jeśli dostępny)
                local network = ReplicatedStorage:FindFirstChild("Network")
                if network and network:FindFirstChild("ColorCar") then
                    network.ColorCar:FireServer(myCar, color)
                end
                
                -- Agresywny lokalny kolor (Nadpisuje tekstury pojazdu w czasie rzeczywistym)
                for _, part in pairs(myCar:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "Windshield" then
                        part.Color = color
                        -- Wyłączenie wymuszonych przez grę tekstur psujących efekt RGB
                        if part:IsA("MeshPart") then
                            part.TextureID = "" 
                        end
                    end
                end
            end
            task.wait(0.02) -- Bardzo szybkie, płynne odświeżanie RGB
        end
    end)
end)

-- ==========================================
-- [5] DODATKOWE FUNKCJE
-- ==========================================
local flying = false
local flySpeed = 60
local bVel, bGyr

createButton("Toggle Fly (Latanie)", function()
    flying = not flying
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if flying and hrp then
        bVel = Instance.new("BodyVelocity", hrp)
        bVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bVel.Velocity = Vector3.new(0, 0, 0)
        
        bGyr = Instance.new("BodyGyro", hrp)
        bGyr.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bGyr.CFrame = hrp.CFrame
        
        task.spawn(function()
            local cam = workspace.CurrentCamera
            while flying and hrp and char:FindFirstChild("Humanoid") do
                bVel.Velocity = char.Humanoid.MoveDirection * flySpeed
                bGyr.CFrame = cam.CFrame
                task.wait()
            end
        end)
    else
        if bVel then bVel:Destroy() end
        if bGyr then bGyr:Destroy() end
    end
end)

createButton("Skok na księżyc", function()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Velocity = Vector3.new(0, 350, 0) end
end)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(1, -20, 0, 40)
CloseBtn.Position = UDim2.new(0, 10, 1, -50)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "ZAMKNIJ MENU"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.MouseButton1Click:Connect(function() 
    rgbCarActive = false
    flying = false
    ScreenGui:Destroy() 
end)
