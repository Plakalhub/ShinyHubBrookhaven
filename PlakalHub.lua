--[[
  Skrypt do Brookhaven RP (Xeno executor)
  Funkcje: radio (ID), straszne dźwięki, fly, RGB car (płynne przejścia), zmiana nicku na ShinyHub z RGB, menu żółto-czarne.
  Uwaga: wymagany gamepass do radia z własnymi ID.
]]
local Player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Zmiana nicku na ShinyHub z RGB
local function changeName()
    local nametag = Player.Character and Player.Character:FindFirstChild("Nametag")
    if nametag then
        nametag.Text = "ShinyHub"
        spawn(function()
            while wait(0.1) do
                local hue = tick() % 6 / 6
                local color = Color3.fromHSV(hue, 1, 1)
                nametag.TextColor3 = color
            end
        end)
    end
end
Player.CharacterAdded:Connect(function(char)
    repeat wait() until char:FindFirstChild("Nametag")
    changeName()
end)
if Player.Character then changeName() end

-- Menu (żółto-czarne)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ShinyHubMenu"
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
Title.Text = "ShinyHub - Brookhaven"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 24
Title.Position = UDim2.new(0, 0, 0, 0)
-- Przyciski
local function createButton(text, position, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, position, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 0)
    btn.Text = text
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 20
    btn.BorderColor3 = Color3.fromRGB(255, 255, 0)
    btn.BorderSizePixel = 2
    btn.MouseButton1Click:Connect(callback)
end

-- Radio (wymagany gamepass)
local function playRadio(id)
    local radio = Player.Character and Player.Character:FindFirstChild("Radio")
    if radio then
        radio:Play(id) -- id jako string lub number
    end
end
createButton("Radio ID", 0.1, function()
    local id = "1234567890" -- domyślne ID, można zmienić
    playRadio(id)
end)
createButton("Straszny dźwięk 1", 0.2, function()
    playRadio("1234567891") -- przykładowe ID straszne
end)
createButton("Straszny dźwięk 2", 0.25, function()
    playRadio("1234567892")
end)

-- Fly
local flying = false
local bodyVelocity
local function toggleFly()
    flying = not flying
    if flying then
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            bodyVelocity = Instance.new("BodyVelocity", char.HumanoidRootPart)
            bodyVelocity.Velocity = Vector3.new(0, 50, 0)
            bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 10000
        end
    else
        if bodyVelocity then bodyVelocity:Destroy() end
    end
end
createButton("Fly", 0.3, toggleFly)

-- RGB Car (płynne przejścia kolorów)
local function rgbCar()
    local vehicle = Player.Character and Player.Character:FindFirstChildOfClass("VehicleSeat")
    if vehicle and vehicle.Parent then
        local car = vehicle.Parent
        spawn(function()
            while wait(0.1) do
                local hue = tick() % 6 / 6
                local color = Color3.fromHSV(hue, 1, 1)
                for _, part in pairs(car:GetDescendants()) do
                    if part:IsA("BasePart") then
                        TweenService:Create(part, TweenInfo.new(0.1), {Color = color}):Play()
                    end
                end
            end
        end)
    end
end
createButton("RGB Car", 0.35, rgbCar)

-- Dodatkowe opcje
createButton("Nieskończona energia", 0.4, function()
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.MaxHealth = math.huge
    end
end)
createButton("Skok na księżyc", 0.45, function()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.Velocity = Vector3.new(0, 500, 0)
    end
end)
createButton("Zamknij", 0.9, function() ScreenGui:Destroy() end)
