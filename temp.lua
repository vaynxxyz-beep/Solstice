local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Detect if the user is on a mobile device
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local Window = Fluent:CreateWindow({
    Title = "Solstice Hub",
    SubTitle = "by Vaynx (Mobile Fixed)",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Utilities = Window:AddTab({ Title = "Utilities", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "" })
}

Fluent:Notify({
    Title = "Notification",
    Content = IsMobile and "Mobile Mode Enabled" or "PC Mode Enabled",
    SubContent = "Welcome to Solstice Hub",
    Duration = 5
})

local Options = Fluent.Options

--------------------------------------------------------------------------------
-- SETTINGS & STATE VARIABLES
--------------------------------------------------------------------------------
local Config = {
    AimbotMode = "None", 
    AimPart = "Head",   
    Smoothing = 2,      
    TriggerBot = false,
    TeamCheck = true,
    
    AutoAim = false,
    HoldRightClick = true,
    
    EnableFOVCircle = false,
    FOVSize = 100,
    FOVColor = Color3.fromRGB(255, 255, 255),
    
    AimbotOffset = Vector3.new(0, 0, 0),
    
    GodMode = false,
    HitboxExpander = false,
    HitboxSize = 10,
    InfiniteJump = false,
    Noclip = false,
    PlayerESP = false,
    
    CornerBox = false,
    TracerLines = false,
    NameAndHealthPct = false,
    HealthBar = false,
    Distance = false,
    Highlights = false
}

--------------------------------------------------------------------------------
-- DRAWING FOV CIRCLE
--------------------------------------------------------------------------------
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

--------------------------------------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------------------------------------
local function IsEnemy(p)
    if not Config.TeamCheck then return true end
    
    if p.Team ~= nil and LocalPlayer.Team ~= nil then
        return p.Team ~= LocalPlayer.Team
    end
    
    if p.TeamColor and LocalPlayer.TeamColor then
        return p.TeamColor ~= LocalPlayer.TeamColor
    end

    return true
end

--------------------------------------------------------------------------------
-- MAIN TAB
--------------------------------------------------------------------------------
Tabs.Main:AddSection("Aimbot Settings")

Tabs.Main:AddToggle("TeamCheckToggle", {
    Title = "Team Check",
    Default = true,
    Callback = function(Value)
        Config.TeamCheck = Value
    end
})

Tabs.Main:AddDropdown("AimbotModeDropdown", {
    Title = "Aimbot Mode",
    Values = {"None", "Camera", "Mouse"},
    Default = "None",
    Callback = function(Value)
        Config.AimbotMode = Value
    end
})

Tabs.Main:AddDropdown("AimPartDropdown", {
    Title = "Aim Part",
    Values = {"Head", "HumanoidRootPart", "Torso"},
    Default = "Head",
    Callback = function(Value)
        Config.AimPart = Value
    end
})

Tabs.Main:AddSlider("SmoothingSlider", {
    Title = "Smoothing",
    Default = 2,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        Config.Smoothing = Value
    end
})

Tabs.Main:AddToggle("AutoAimToggle", {
    Title = "Auto-Aim (Recommended for Mobile)",
    Default = false,
    Callback = function(Value)
        Config.AutoAim = Value
    end
})

if not IsMobile then
    Tabs.Main:AddToggle("HoldRightClickToggle", {
        Title = "Hold Right Click to Aim",
        Default = true,
        Callback = function(Value)
            Config.HoldRightClick = Value
        end
    })

    Tabs.Main:AddToggle("TriggerBotToggle", {
        Title = "Trigger Bot (PC Only)",
        Default = false,
        Callback = function(Value)
            Config.TriggerBot = Value
        end
    })
end

Tabs.Main:AddSection("FOV Settings")

Tabs.Main:AddToggle("EnableFOVCircleToggle", {
    Title = "Enable Circle",
    Default = false,
    Callback = function(Value)
        Config.EnableFOVCircle = Value
    end
})

Tabs.Main:AddSlider("FOVSizeSlider", {
    Title = "Size",
    Default = 100,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        Config.FOVSize = Value
    end
})

Tabs.Main:AddDropdown("FOVColorDropdown", {
    Title = "Color",
    Values = {"White", "Red", "Green", "Blue", "Yellow", "Cyan"},
    Default = "White",
    Callback = function(Value)
        if Value == "White" then Config.FOVColor = Color3.fromRGB(255, 255, 255)
        elseif Value == "Red" then Config.FOVColor = Color3.fromRGB(255, 0, 0)
        elseif Value == "Green" then Config.FOVColor = Color3.fromRGB(0, 255, 0)
        elseif Value == "Blue" then Config.FOVColor = Color3.fromRGB(0, 100, 255)
        elseif Value == "Yellow" then Config.FOVColor = Color3.fromRGB(255, 255, 0)
        elseif Value == "Cyan" then Config.FOVColor = Color3.fromRGB(0, 255, 255)
        end
    end
})

Tabs.Main:AddSection("Offsets")

Tabs.Main:AddSlider("OffsetX", {
    Title = "Offset X",
    Default = 0,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        Config.AimbotOffset = Vector3.new(Value, Config.AimbotOffset.Y, Config.AimbotOffset.Z)
    end
})

Tabs.Main:AddSlider("OffsetY", {
    Title = "Offset Y",
    Default = 0,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        Config.AimbotOffset = Vector3.new(Config.AimbotOffset.X, Value, Config.AimbotOffset.Z)
    end
})

Tabs.Main:AddSlider("OffsetZ", {
    Title = "Offset Z",
    Default = 0,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        Config.AimbotOffset = Vector3.new(Config.AimbotOffset.X, Config.AimbotOffset.Y, Value)
    end
})

Tabs.Main:AddSection("Visual ESP Settings")

Tabs.Main:AddToggle("CornerBoxToggle", {
    Title = "Corner Box",
    Default = false,
    Callback = function(Value)
        Config.CornerBox = Value
    end
})

Tabs.Main:AddToggle("TracerLinesToggle", {
    Title = "Tracer Lines",
    Default = false,
    Callback = function(Value)
        Config.TracerLines = Value
    end
})

Tabs.Main:AddToggle("NameHealthPctToggle", {
    Title = "Name & Health %",
    Default = false,
    Callback = function(Value)
        Config.NameAndHealthPct = Value
    end
})

Tabs.Main:AddToggle("HealthBarToggle", {
    Title = "Health Bar",
    Default = false,
    Callback = function(Value)
        Config.HealthBar = Value
    end
})

Tabs.Main:AddToggle("DistanceToggle", {
    Title = "Distance",
    Default = false,
    Callback = function(Value)
        Config.Distance = Value
    end
})

Tabs.Main:AddToggle("HighlightsToggle", {
    Title = "Highlights",
    Default = false,
    Callback = function(Value)
        Config.Highlights = Value
        Config.PlayerESP = Value
    end
})

--------------------------------------------------------------------------------
-- DRAWING ESP CONTAINER
--------------------------------------------------------------------------------
local ESPObjects = {}

local function CreatePlayerESP(player)
    local drawings = {
        Tracer = Drawing.new("Line"),
        NameText = Drawing.new("Text"),
        HealthText = Drawing.new("Text"),
        DistanceText = Drawing.new("Text"),
        HealthBarBG = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Corners = {
            Drawing.new("Line"), Drawing.new("Line"),
            Drawing.new("Line"), Drawing.new("Line"),
            Drawing.new("Line"), Drawing.new("Line"),
            Drawing.new("Line"), Drawing.new("Line")
        }
    }

    drawings.Tracer.Thickness = 1.5
    drawings.Tracer.Color = Color3.fromRGB(255, 255, 255)

    drawings.NameText.Size = 14
    drawings.NameText.Center = true
    drawings.NameText.Outline = true
    drawings.NameText.Color = Color3.fromRGB(255, 255, 255)

    drawings.HealthText.Size = 12
    drawings.HealthText.Center = true
    drawings.HealthText.Outline = true
    drawings.HealthText.Color = Color3.fromRGB(0, 255, 0)

    drawings.DistanceText.Size = 12
    drawings.DistanceText.Center = true
    drawings.DistanceText.Outline = true
    drawings.DistanceText.Color = Color3.fromRGB(200, 200, 200)

    drawings.HealthBarBG.Filled = true
    drawings.HealthBarBG.Color = Color3.fromRGB(0, 0, 0)
    
    drawings.HealthBar.Filled = true
    drawings.HealthBar.Color = Color3.fromRGB(0, 255, 0)

    for _, line in ipairs(drawings.Corners) do
        line.Thickness = 1.5
        line.Color = Color3.fromRGB(255, 0, 0)
    end

    ESPObjects[player] = drawings
end

local function RemovePlayerESP(player)
    if ESPObjects[player] then
        local d = ESPObjects[player]
        pcall(function()
            d.Tracer:Remove()
            d.NameText:Remove()
            d.HealthText:Remove()
            d.DistanceText:Remove()
            d.HealthBarBG:Remove()
            d.HealthBar:Remove()
            for _, line in ipairs(d.Corners) do
                line:Remove()
            end
        end)
        ESPObjects[player] = nil
    end
end

Players.PlayerRemoving:Connect(RemovePlayerESP)

--------------------------------------------------------------------------------
-- LOGIC HANDLERS
--------------------------------------------------------------------------------

local function GetClosestPlayer()
    local closest, shortestDist = nil, math.huge
    local screenCenter = IsMobile and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) or UserInputService:GetMouseLocation()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsEnemy(p) and p.Character and p.Character:FindFirstChild(Config.AimPart) then
            local targetPart = p.Character[Config.AimPart]
            local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                
                if not Config.EnableFOVCircle or dist <= Config.FOVSize then
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = p
                    end
                end
            end
        end
    end
    return closest
end

local function UpdateFOV()
    if Config.EnableFOVCircle then
        FOVCircle.Position = IsMobile and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) or UserInputService:GetMouseLocation()
        FOVCircle.Radius = Config.FOVSize
        FOVCircle.Color = Config.FOVColor
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end

local function UpdateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if not ESPObjects[p] then CreatePlayerESP(p) end
            local d = ESPObjects[p]
            
            local char = p.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            if char then
                local highlight = char:FindFirstChild("SolsticeESP")
                if Config.Highlights and IsEnemy(p) then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "SolsticeESP"
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.Parent = char
                    end
                elseif highlight then
                    highlight:Destroy()
                end
            end

            if char and hrp and head and humanoid and humanoid.Health > 0 and IsEnemy(p) then
                local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 2
                    local topX, topY = hrpPos.X - width / 2, headPos.Y

                    if Config.CornerBox then
                        local lineLen = width / 4
                        d.Corners[1].From = Vector2.new(topX, topY)
                        d.Corners[1].To = Vector2.new(topX + lineLen, topY)
                        d.Corners[2].From = Vector2.new(topX, topY)
                        d.Corners[2].To = Vector2.new(topX, topY + lineLen)

                        d.Corners[3].From = Vector2.new(topX + width, topY)
                        d.Corners[3].To = Vector2.new(topX + width - lineLen, topY)
                        d.Corners[4].From = Vector2.new(topX + width, topY)
                        d.Corners[4].To = Vector2.new(topX + width, topY + lineLen)

                        d.Corners[5].From = Vector2.new(topX, topY + height)
                        d.Corners[5].To = Vector2.new(topX + lineLen, topY + height)
                        d.Corners[6].From = Vector2.new(topX, topY + height)
                        d.Corners[6].To = Vector2.new(topX, topY + height - lineLen)

                        d.Corners[7].From = Vector2.new(topX + width, topY + height)
                        d.Corners[7].To = Vector2.new(topX + width - lineLen, topY + height)
                        d.Corners[8].From = Vector2.new(topX + width, topY + height)
                        d.Corners[8].To = Vector2.new(topX + width, topY + height - lineLen)

                        for _, line in ipairs(d.Corners) do line.Visible = true end
                    else
                        for _, line in ipairs(d.Corners) do line.Visible = false end
                    end

                    if Config.TracerLines then
                        d.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        d.Tracer.To = Vector2.new(hrpPos.X, hrpPos.Y)
                        d.Tracer.Visible = true
                    else
                        d.Tracer.Visible = false
                    end

                    if Config.NameAndHealthPct then
                        local healthPct = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                        d.NameText.Text = p.Name .. " [" .. healthPct .. "%]"
                        d.NameText.Position = Vector2.new(hrpPos.X, topY - 18)
                        d.NameText.Visible = true
                    else
                        d.NameText.Visible = false
                    end

                    if Config.HealthBar then
                        local barWidth = 3
                        local barHeight = height * (humanoid.Health / humanoid.MaxHealth)
                        
                        d.HealthBarBG.Size = Vector2.new(barWidth, height)
                        d.HealthBarBG.Position = Vector2.new(topX - 6, topY)
                        d.HealthBarBG.Visible = true

                        d.HealthBar.Size = Vector2.new(barWidth, barHeight)
                        d.HealthBar.Position = Vector2.new(topX - 6, topY + (height - barHeight))
                        d.HealthBar.Visible = true
                    else
                        d.HealthBarBG.Visible = false
                        d.HealthBar.Visible = false
                    end

                    if Config.Distance then
                        local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                        d.DistanceText.Text = dist .. " studs"
                        d.DistanceText.Position = Vector2.new(hrpPos.X, topY + height + 2)
                        d.DistanceText.Visible = true
                    else
                        d.DistanceText.Visible = false
                    end

                else
                    d.Tracer.Visible = false
                    d.NameText.Visible = false
                    d.HealthText.Visible = false
                    d.DistanceText.Visible = false
                    d.HealthBarBG.Visible = false
                    d.HealthBar.Visible = false
                    for _, line in ipairs(d.Corners) do line.Visible = false end
                end
            else
                d.Tracer.Visible = false
                d.NameText.Visible = false
                d.HealthText.Visible = false
                d.DistanceText.Visible = false
                d.HealthBarBG.Visible = false
                d.HealthBar.Visible = false
                for _, line in ipairs(d.Corners) do line.Visible = false end
            end
        end
    end
end

-- Render Loop
RunService.RenderStepped:Connect(function()
    UpdateFOV()

    if Config.AimbotMode ~= "None" then
        local shouldAim = false

        if IsMobile then
            shouldAim = Config.AutoAim
        else
            local isRightClickPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            shouldAim = Config.AutoAim or (Config.HoldRightClick and isRightClickPressed)
        end

        if shouldAim then
            local target = GetClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild(Config.AimPart) then
                local targetPos = target.Character[Config.AimPart].Position + Config.AimbotOffset
                local lerpAlpha = Config.Smoothing > 0 and math.clamp(1 / Config.Smoothing, 0.05, 1) or 1
                
                -- Force camera rotation on mobile (safe and universal)
                if Config.AimbotMode == "Camera" or IsMobile then
                    local currentCamCF = Camera.CFrame
                    local targetCamCF = CFrame.new(currentCamCF.Position, targetPos)
                    Camera.CFrame = currentCamCF:Lerp(targetCamCF, lerpAlpha)
                elseif Config.AimbotMode == "Mouse" and not IsMobile then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local moveX = (screenPos.X - mousePos.X) * lerpAlpha
                        local moveY = (screenPos.Y - mousePos.Y) * lerpAlpha
                        if mousemoverel then mousemoverel(moveX, moveY) end
                    end
                end
            end
        end
    end

    if not IsMobile and Config.TriggerBot then
        local mouse = LocalPlayer:GetMouse()
        local target = mouse.Target
        if target and target.Parent then
            local character = target.Parent
            local player = Players:GetPlayerFromCharacter(character)
            if player and player ~= LocalPlayer and IsEnemy(player) then
                if mouse1click then mouse1click() end
            end
        end
    end

    UpdateESP()
end)

--------------------------------------------------------------------------------
-- INTERFACE & SAVE MANAGERS
--------------------------------------------------------------------------------
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("SolsticeConfig")
SaveManager:SetFolder("SolsticeConfig/main")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
