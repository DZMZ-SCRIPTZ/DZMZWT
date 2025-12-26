-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "DZMZ Warfare Tycoon by DeadzModz",
    LoadingTitle = "DZMZ Warfare Tycoon",
    LoadingSubtitle = "by DeadzModz",
    ShowText = "DZMZ Warfare",
    Theme = "Default",
    ToggleUIKeybind = "K"
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

--------------------------------
-- PLAYER TAB
--------------------------------
local PlayerTab = Window:CreateTab("Player", 4483362458)
local FlyEnabled = false
local FlySpeed = 2
local FlyKeys = {}
local FlyPart
local NoClipEnabled = false
local SpinBotEnabled = false
local SpinSpeed = 10
local JumpPowerValue = 50 -- Default jump power

-- Fly Toggle
PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(value)
        FlyEnabled = value
        local character = LocalPlayer.Character
        if character then
            FlyPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
            FlyPart.Anchored = FlyEnabled
        end
    end
})

-- Jump Power Slider (no toggle)
PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {10,500}, -- can go very low or high
    Increment = 1,
    CurrentValue = JumpPowerValue,
    Callback = function(value)
        JumpPowerValue = value
    end
})

-- NoClip Toggle
PlayerTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(value)
        NoClipEnabled = value
    end
})

-- Spin Bot Toggle
PlayerTab:CreateToggle({
    Name = "Spin Bot",
    CurrentValue = false,
    Callback = function(value)
        SpinBotEnabled = value
    end
})

-- Spin Bot Speed Slider
PlayerTab:CreateSlider({
    Name = "Spin Speed",
    Range = {1,50},
    Increment = 1,
    CurrentValue = SpinSpeed,
    Callback = function(value)
        SpinSpeed = value
    end
})

-- Key tracking for Fly
UIS.InputBegan:Connect(function(input)
    if FlyEnabled then FlyKeys[input.KeyCode] = true end
end)

UIS.InputEnded:Connect(function(input)
    if FlyEnabled then FlyKeys[input.KeyCode] = nil end
end)

-- RunService for Fly, Jump, NoClip, Spin Bot
RunService.Stepped:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end

    -- Fly movement
    if FlyEnabled then
        local moveDir = Vector3.new(0,0,0)
        local cam = Camera.CFrame
        if FlyKeys[Enum.KeyCode.W] then moveDir = moveDir + cam.LookVector end
        if FlyKeys[Enum.KeyCode.S] then moveDir = moveDir - cam.LookVector end
        if FlyKeys[Enum.KeyCode.A] then moveDir = moveDir - cam.RightVector end
        if FlyKeys[Enum.KeyCode.D] then moveDir = moveDir + cam.RightVector end
        if FlyKeys[Enum.KeyCode.Space] then moveDir = moveDir + Vector3.new(0,1,0) end
        if FlyKeys[Enum.KeyCode.LeftShift] then moveDir = moveDir - Vector3.new(0,1,0) end
        if moveDir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + moveDir.Unit * FlySpeed
        end
    end

    -- Jump Power
    if humanoid then
        humanoid.JumpPower = JumpPowerValue
    end

    -- NoClip
    if NoClipEnabled then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Spin Bot
    if SpinBotEnabled then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
    end
end)

--------------------------------
-- VISUAL TAB
--------------------------------
local VisualTab = Window:CreateTab("Visual", 4483362458)
local ESPOptions = {Skeleton=false, Name=false, Box=false, Tracer=false}
local ESPDrawings = {}

VisualTab:CreateToggle({Name="Skeleton ESP", CurrentValue=false, Callback=function(v) ESPOptions.Skeleton=v end})
VisualTab:CreateToggle({Name="Name ESP", CurrentValue=false, Callback=function(v) ESPOptions.Name=v end})
VisualTab:CreateToggle({Name="Box ESP", CurrentValue=false, Callback=function(v) ESPOptions.Box=v end})
VisualTab:CreateToggle({Name="Tracer ESP", CurrentValue=false, Callback=function(v) ESPOptions.Tracer=v end})

local function NewLine(thickness)
    local line = Drawing.new("Line")
    line.Thickness = thickness
    line.Visible = true
    return line
end

local function NewText(text, size)
    local t = Drawing.new("Text")
    t.Text = text
    t.Size = size
    t.Center = true
    t.Outline = true
    t.Visible = true
    return t
end

local function GetSkeletonJoints(character)
    local joints = {}
    local h = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    local lArm = character:FindFirstChild("LeftUpperArm")
    local rArm = character:FindFirstChild("RightUpperArm")
    local lLeg = character:FindFirstChild("LeftUpperLeg")
    local rLeg = character:FindFirstChild("RightUpperLeg")
    
    joints["Head"] = h and h.Position
    joints["Torso"] = torso and torso.Position or hrp.Position
    joints["LArm"] = lArm and lArm.Position
    joints["RArm"] = rArm and rArm.Position
    joints["LLeg"] = lLeg and lLeg.Position
    joints["RLeg"] = rLeg and rLeg.Position
    joints["Root"] = hrp and hrp.Position
    return joints
end

local rainbowHue = 0
local function GetRainbowColor()
    rainbowHue = (rainbowHue + 1) % 360
    return Color3.fromHSV(rainbowHue/360,1,1)
end

RunService.RenderStepped:Connect(function()
    for _, v in pairs(ESPDrawings) do
        if v then v:Remove() end
    end
    ESPDrawings = {}

    local color = GetRainbowColor()

    for _, player in pairs(Players:GetPlayers()) do
        if player~=LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
            local char = player.Character
            local joints = GetSkeletonJoints(char)
            local screenJoints = {}
            for k,v in pairs(joints) do
                if v then
                    local screen, onScreen = Camera:WorldToViewportPoint(v)
                    if onScreen then
                        screenJoints[k] = Vector2.new(screen.X, screen.Y)
                    end
                end
            end

            -- Skeleton ESP
            if ESPOptions.Skeleton then
                local connections = {{"Head","Torso"},{"Torso","LArm"},{"Torso","RArm"},{"Torso","LLeg"},{"Torso","RLeg"},{"Torso","Root"}}
                for _, conn in pairs(connections) do
                    local from, to = screenJoints[conn[1]], screenJoints[conn[2]]
                    if from and to then
                        local line = NewLine(2)
                        line.Color = color
                        line.From = from
                        line.To = to
                        table.insert(ESPDrawings,line)
                    end
                end
            end

            -- Box ESP
            if ESPOptions.Box and screenJoints["Head"] and screenJoints["Root"] then
                local top = screenJoints["Head"]
                local bottom = screenJoints["Root"]
                local width = (bottom.Y - top.Y)/1.5
                local boxCorners = {
                    Vector2.new(top.X-width, top.Y),
                    Vector2.new(top.X+width, top.Y),
                    Vector2.new(bottom.X+width, bottom.Y),
                    Vector2.new(bottom.X-width, bottom.Y)
                }
                local lines = {{1,2},{2,3},{3,4},{4,1}}
                for _, l in pairs(lines) do
                    local ln = NewLine(2)
                    ln.Color = color
                    ln.From = boxCorners[l[1]]
                    ln.To = boxCorners[l[2]]
                    table.insert(ESPDrawings,ln)
                end
            end

            -- Name ESP
            if ESPOptions.Name and screenJoints["Head"] then
                local nameText = NewText(player.Name,16)
                nameText.Color = color
                nameText.Position = Vector2.new(screenJoints["Head"].X, screenJoints["Head"].Y-15)
                table.insert(ESPDrawings,nameText)
            end

            -- Tracer ESP
            if ESPOptions.Tracer and screenJoints["Root"] then
                local tracer = NewLine(2)
                tracer.Color = color
                tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                tracer.To = screenJoints["Root"]
                table.insert(ESPDrawings,tracer)
            end
        end
    end
end)

--------------------------------
-- AIM TAB
--------------------------------
local AimTab = Window:CreateTab("Aim", 4483362458)
local aimEnabled = false
local aimLocked = nil
local aimFOV = 150
local bodyPart = "Head"
local aimKey = Enum.KeyCode.LeftAlt

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Radius = aimFOV
fovCircle.Color = Color3.fromRGB(255,0,0)

-- Aimlock Toggle
AimTab:CreateToggle({
    Name = "Aimlock",
    CurrentValue = false,
    Callback = function(value)
        aimEnabled = value
        aimLocked = nil
        fovCircle.Visible = value
    end
})

-- FOV Slider
AimTab:CreateSlider({
    Name = "FOV Size",
    Range = {50,500},
    Increment = 10,
    CurrentValue = aimFOV,
    Callback=function(val)
        aimFOV = val
        fovCircle.Radius = val
    end
})

-- Body Part Selector
AimTab:CreateDropdown({
    Name = "Body Part",
    Options = {"Head","Torso","HumanoidRootPart"},
    CurrentOption="Head",
    Callback=function(opt) bodyPart=opt end
})

-- Lock/unlock aim
UIS.InputBegan:Connect(function(input)
    if aimEnabled and input.KeyCode == Enum.KeyCode.LeftAlt then
        if aimLocked then
            aimLocked = nil
        else
            local nearest, dist = nil, aimFOV
            for _, player in pairs(Players:GetPlayers()) do
                if player~=LocalPlayer and player.Character and player.Character:FindFirstChild(bodyPart) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character[bodyPart].Position)
                    if not onScreen then continue end
                    local distance = (Vector2.new(screenPos.X,screenPos.Y)-Vector2.new(UIS:GetMouseLocation().X,UIS:GetMouseLocation().Y)).Magnitude
                    if distance < dist then nearest = player dist = distance end
                end
            end
            aimLocked = nearest
        end
    end
end)

-- Aimlock Render
RunService.RenderStepped:Connect(function()
    if aimEnabled then
        fovCircle.Position = Vector2.new(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)
        fovCircle.Color = Color3.fromHSV(tick()%5/5,1,1)
    end
    if aimEnabled and aimLocked and aimLocked.Character and aimLocked.Character:FindFirstChild(bodyPart) then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimLocked.Character[bodyPart].Position)
    end
end)

-- Instructions
local function ShowAimInstructions()
    local screenGui = Instance.new("ScreenGui")
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.CoreGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 300, 0, 50)
    textLabel.Position = UDim2.new(0.5, -150, 0, 30)
    textLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Text = "Aimlock Instructions:\nToggle Aimlock ON, then press Left Alt to lock/unlock target"
    textLabel.TextWrapped = true
    textLabel.Parent = screenGui

    game:GetService("Debris"):AddItem(screenGui, 6)
end

ShowAimInstructions()

--------------------------------
-- SERVER TAB (Working Spectate)
--------------------------------
local ServerTab = Window:CreateTab("Server", 4483362458)
local PlayerButtons = {}
local ViewingPlayer = nil
local OriginalCameraCFrame = nil

local function ToggleSpectate(player)
    if ViewingPlayer == player then
        ViewingPlayer = nil
        if OriginalCameraCFrame then
            Camera.CFrame = OriginalCameraCFrame
            OriginalCameraCFrame = nil
        end
    else
        if not OriginalCameraCFrame then
            OriginalCameraCFrame = Camera.CFrame
        end
        ViewingPlayer = player
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,10)
        end
    end
end

local function AddPlayerButtons(player)
    local viewBtn = ServerTab:CreateButton({
        Name = "View "..player.Name,
        Callback = function()
            ToggleSpectate(player)
        end
    })
    local tpBtn = ServerTab:CreateButton({
        Name = "Teleport to "..player.Name,
        Callback = function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                end
            end
        end
    })
    PlayerButtons[player] = {viewBtn, tpBtn}
end

local function RemovePlayerButtons(player)
    if PlayerButtons[player] then
        for _, btn in pairs(PlayerButtons[player]) do btn:Remove() end
        PlayerButtons[player] = nil
    end
    if ViewingPlayer == player then
        ViewingPlayer = nil
        if OriginalCameraCFrame then
            Camera.CFrame = OriginalCameraCFrame
            OriginalCameraCFrame = nil
        end
    end
end

-- Populate initial players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then AddPlayerButtons(player) end
end

-- Update when players join/leave
Players.PlayerAdded:Connect(AddPlayerButtons)
Players.PlayerRemoving:Connect(RemovePlayerButtons)

-- Keep camera on the player while spectating
RunService.RenderStepped:Connect(function()
    if ViewingPlayer and ViewingPlayer.Character and ViewingPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = ViewingPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,10)
    end
end)
