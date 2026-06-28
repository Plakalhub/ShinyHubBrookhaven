--[[
    Skrypt do Brookhaven RP (Zoptymalizowany dla Xeno)
    Funkcje: Naprawione RGB dla auta, poprawne UI (brak nakładania), działający text RGB oraz poprawne i naprawione Radio.
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Usuwanie starego menu, jeśli istnieje
if CoreGui:FindFirstChild("ShinyHubMenu") then
    CoreGui.ShinyHubMenu:Destroy()
end

-- Zmiana Nicku (Kompatybilne z Brookhaven RP system)
local function changeName()
    -- Próba zmiany przez RemoteEvent gry (Brookhaven używa eventów do aktualizacji RP Name)
    local Network = game:GetService("ReplicatedStorage"):FindFirstChild("Network")
    if Network and Network:FindFirstChild("SetRPName") then
        Network.SetRPName:FireServer("ShinyHub")
    end
    
    -- Własny lokalny efekt RGB na nadgłówku (jeśli gra go zrenderuje)
    task.spawn(function()
        while task.wait(0.05) do
            local char = Player.Character
            if char then
                local head = char:FindFirstChild("Head")
                local overhead = head and (head:FindFirstChild("NameTag") or head:FindFirstChild("Overhead"))
                if overhead then
                    local textLabel = overhead:FindFirstChildOfClass("TextLabel")
                    if textLabel then
                        textLabel.Text = "ShinyHub"
                        local hue = (tick() % 4) / 4
                        textLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
                    end
                end
            end
        end
    end)
end

Player.CharacterAdded:Connect(function()
    task.wait(1)
    changeName()
end)
if Player.Character then task.spawn(changeName) end

-- Tworzenie UI (Żółto-czarne, bez nakładania się przycisków)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ShinyHubMenu"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 420, 0, 520)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Ciemne tło dla lepszego kontrastu
MainFrame.BorderColor3 = Color3.fromRGB(255, 215, 0) -- Złoto/Żółta ramka
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true

-- Tytuł Menu
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Text = "★ ShinyHub - Brookhaven ★"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22

-- Kontener na przyciski z automatycznym układem (zapobiega nakładaniu się!)
local ScrollingFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollingFrame.Size = UDim2.new(1, -20, 1, -110)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 55)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 450)
ScrollingFrame.ScrollBarThickness = 6

local UIListLayout = Instance.new("UIListLayout", ScrollingFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- Generator Przycisków
local function createButton(text, callback)
    local btn = Instance.new("TextButton", ScrollingFrame)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 215, 0)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.BorderColor3 = Color3.fromRGB(255, 215, 0)
    btn.BorderSizePixel = 1
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- --- NOWE NAPRAWIONE RADIO I DŹWIĘKI ---
local function playRadio(id)
    local Network = game:GetService("ReplicatedStorage"):FindFirstChild("Network")
    local playAudioEvent = Network and (Network:FindFirstChild("PlayAudio") or Network:FindFirstChild("BringAudio") or Network:FindFirstChild("CarSound"))
    
    if playAudioEvent and playAudioEvent:IsA("RemoteEvent") then
        playAudioEvent:FireServer(tostring(id))
    else
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local localSound = hrp:FindFirstChild("ShinySound") or Instance.new("Sound", hrp)
            localSound.Name = "ShinySound"
            localSound.SoundId = "rbxassetid://" .. tostring(id)
            localSound.Volume = 2
            localSound.Looped = false
            localSound:Play()
        end
    end
end

createButton("Radio: Muzyka (Działające ID)", function() playRadio(1837946285) end)
createButton("Straszny dźwięk 1 (Krzyk)", function() playRadio(9069609268) end)
createButton("Straszny dźwięk 2 (Śmiech)", function() playRadio(9061011306) end)

-- Fly
local flying = false
local flySpeed = 50
local bodyVelocity, bodyGyro

createButton("Toggle Fly", function()
    flying = not flying
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if flying and hrp then
        bodyVelocity = Instance.new("BodyVelocity", hrp)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        
        bodyGyro = Instance.new("BodyGyro", hrp)
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.CFrame = hrp.CFrame
        
        task.spawn(function()
            local camera = workspace.CurrentCamera
            while flying and hrp and char:FindFirstChild("Humanoid") do
                local moveDirection = char.Humanoid.MoveDirection
                bodyVelocity.Velocity = moveDirection * flySpeed
                bodyGyro.CFrame = camera.CFrame
                task.wait()
            end
        end)
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
    end
end)

-- RGB Car
local rgbCarActive = false
createButton("RGB Car (Wsiądź do auta)", function()
    if rgbCarActive then rgbCarActive = false return end
    rgbCarActive = true
    
    task.spawn(function()
        while rgbCarActive do
            local char = Player.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat") then
                local car = humanoid.SeatPart.Parent
                local hue = (tick() % 5) / 5
                local color = Color3.fromHSV(hue, 1, 1)
                
                for _, part in pairs(car:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "Windshield" then
                        part.Color = color
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end)

-- Dodatkowe
createButton("Nieskończone HP (Lokalne)", function()
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character:FindFirstChildOfClass("Humanoid").MaxHealth = math.huge
        Player.Character:FindFirstChildOfClass("Humanoid").Health = math.huge
    end
end)

createButton("Skok na księżyc", function()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Velocity = Vector3.new(0, 350, 0) end
end)

-- Przycisk Zamknij na dole ekranu menu
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(1, -20, 0, 40)
CloseBtn.Position = UDim2.new(0, 10, 1, -50)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "ZAMKNIJ MENU"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.MouseButton1Click:Connect(function() 
    rgbCarActive = false
    flying = false
    ScreenGui:Destroy() 
end)
