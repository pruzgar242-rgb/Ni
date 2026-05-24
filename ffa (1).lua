-- RuzHub Mm2 FFA | Crimson Theme | Full GUI with All Features
-- Load Adonis Bypass
loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Adonis-actul-bypass-20697"))()

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()
WindUI:SetTheme("Crimson")

-- Welcome Popup
WindUI:Popup({
    Title = "RuzHub Mm2 FFA",
    Icon = "sparkles",
    Content = "🔴 Crimson Theme Activated!\n\nFeatures:\n• Silent Aim\n• FOV Circle\n• Line ESP\n• Highlight\n• Prediction\n• Auto Air\n• Hitbox Expander (Knife Only)\n• Hitbox Color & Transparency",
    Buttons = {
        {
            Title = "Let's Go!",
            Icon = "arrow-right",
            Variant = "Primary",
            Callback = function()
                print("✅ RuzHub Mm2 FFA Loaded!")
            end
        }
    }
})

-- //////////////////// Configuration ////////////////////
local Config = {
    SilentAim = true,
    FOVVisible = true,
    FOVSize = 90,
    FOVColor = Color3.fromRGB(255, 255, 255),
    ESPVisible = true,
    ESPColor = Color3.fromRGB(255, 0, 0),
    HighlightVisible = true,
    HighlightColor = Color3.fromRGB(255, 0, 0),
    PredictionEnabled = true,
    PredictionMultiplier = 0.135,
    HitChance = 100,
    AutoAir = false,
    AutoAirDelay = 0.10,
    AimPart = "Head",
    -- Hitbox Expander (Knife Only)
    HitboxExpander = false,
    HitboxSize = 3,
    HitboxColor = Color3.fromRGB(255, 0, 0),
    HitboxTransparency = 0.5,
    HitboxVisible = false,
}

-- //////////////////// Services ////////////////////
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerCamera = Workspace.CurrentCamera

-- //////////////////// Silent Aim Objects ////////////////////
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Config.FOVVisible
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Color = Config.FOVColor
FOVCircle.Radius = Config.FOVSize

local Highlight = Instance.new("Highlight")
Highlight.Parent = game:GetService("CoreGui")
Highlight.FillTransparency = 0.55
Highlight.OutlineTransparency = 0
Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
Highlight.FillColor = Config.HighlightColor
Highlight.OutlineColor = Config.HighlightColor
Highlight.Enabled = Config.HighlightVisible

local ESPLine = Drawing.new("Line")
ESPLine.Thickness = 2
ESPLine.Transparency = 1
ESPLine.Color = Config.ESPColor
ESPLine.Visible = Config.ESPVisible

-- Target variables
local TargetedPlayer = nil
local TargetedPlayerAimPart = nil

-- //////////////////// Silent Aim Functions ////////////////////
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local centerScreen = Vector2.new(playerCamera.ViewportSize.X / 2, playerCamera.ViewportSize.Y / 2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild(Config.AimPart) then
            local part = plr.Character[Config.AimPart]
            local screenPos, onScreen = playerCamera:WorldToViewportPoint(part.Position)
            if onScreen then
                local dx = screenPos.X - centerScreen.X
                local dy = screenPos.Y - centerScreen.Y
                local distance = math.sqrt(dx * dx + dy * dy)
                if distance <= Config.FOVSize then
                    if distance < shortestDistance then
                        closestPlayer = plr
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Render loop
RunService.RenderStepped:Connect(function()
    local centerScreen = Vector2.new(playerCamera.ViewportSize.X / 2, playerCamera.ViewportSize.Y / 2)
    FOVCircle.Position = centerScreen
    FOVCircle.Radius = Config.FOVSize
    FOVCircle.Visible = Config.FOVVisible
    FOVCircle.Color = Config.FOVColor

    TargetedPlayer = GetClosestPlayer()
    if TargetedPlayer and TargetedPlayer.Character and TargetedPlayer.Character:FindFirstChild(Config.AimPart) then
        TargetedPlayerAimPart = TargetedPlayer.Character[Config.AimPart]
        if Config.HighlightVisible then
            Highlight.Adornee = TargetedPlayer.Character
            Highlight.FillColor = Config.HighlightColor
            Highlight.OutlineColor = Config.HighlightColor
        else
            Highlight.Adornee = nil
        end
        local screenPos, onScreen = playerCamera:WorldToViewportPoint(TargetedPlayerAimPart.Position)
        if onScreen and Config.ESPVisible then
            ESPLine.From = centerScreen
            ESPLine.To = Vector2.new(screenPos.X, screenPos.Y)
            ESPLine.Color = Config.ESPColor
            ESPLine.Visible = true
        else
            ESPLine.Visible = false
        end
    else
        TargetedPlayerAimPart = nil
        Highlight.Adornee = nil
        ESPLine.Visible = false
    end
end)

-- FireServer hook
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(...)
    local args = {...}
    local method = getnamecallmethod()
    if Config.SilentAim and TargetedPlayerAimPart and method == "FireServer" then
        local predictedPosition = TargetedPlayerAimPart.Position
        if Config.PredictionEnabled then
            local vel = TargetedPlayerAimPart.Velocity
            predictedPosition = predictedPosition + vel * Config.PredictionMultiplier
        end
        local hitSuccess = math.random(100) <= Config.HitChance
        if hitSuccess then
            args[3] = predictedPosition
        end
        return old(unpack(args))
    end
    return old(...)
end)
setreadonly(mt, true)

-- Auto Air
spawn(function()
    while task.wait(0.01) do
        if Config.SilentAim and Config.AutoAir and TargetedPlayer and TargetedPlayer.Character then
            local humanoid = TargetedPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local state = humanoid:GetState()
                if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
                    task.wait(Config.AutoAirDelay)
                    pcall(function()
                        local tool = player.Character:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                            if tool:FindFirstChild("Remote") then
                                tool.Remote:FireServer()
                            end
                        end
                    end)
                end
            end
        end
    end
end)

-- Velocity stabilizer
local lastPositions = {}
RunService.Heartbeat:Connect(function(deltaTime)
    if TargetedPlayer and TargetedPlayer.Character and TargetedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = TargetedPlayer.Character.HumanoidRootPart
        local lastPos = lastPositions[TargetedPlayer] or hrp.Position
        local currentPos = hrp.Position
        local velocity = (currentPos - lastPos) / deltaTime
        hrp.AssemblyLinearVelocity = velocity
        hrp.Velocity = velocity
        lastPositions[TargetedPlayer] = currentPos
    end
end)

-- //////////////////// Hitbox Expander System ////////////////////
local HitboxParts = {}

local function isHoldingKnife()
    if player.Character then
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool and (tool.Name:lower():find("knife") or tool.Name:lower():find("blade") or tool.Name:lower():find("dagger")) then
            return true
        end
    end
    return false
end

local function removeHitboxFromPlayer(plr)
    if HitboxParts[plr] then
        HitboxParts[plr]:Destroy()
        HitboxParts[plr] = nil
    end
end

local function addHitboxToPlayer(plr)
    if plr == player then return end
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    if HitboxParts[plr] then return end

    local part = Instance.new("Part")
    part.Name = "HitboxExpander"
    part.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
    part.Transparency = Config.HitboxVisible and Config.HitboxTransparency or 1
    part.Color = Config.HitboxColor
    part.CanCollide = false
    part.Anchored = false
    part.Massless = true
    part.Parent = plr.Character

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = part
    weld.Part1 = plr.Character.HumanoidRootPart
    weld.Parent = part

    HitboxParts[plr] = part
end

local function removeAllHitboxes()
    for plr, _ in pairs(HitboxParts) do
        removeHitboxFromPlayer(plr)
    end
end

local function refreshAllHitboxes()
    removeAllHitboxes()
    if Config.HitboxExpander and isHoldingKnife() then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                addHitboxToPlayer(plr)
            end
        end
    end
end

local function updateHitboxVisuals()
    for _, part in pairs(HitboxParts) do
        part.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
        part.Color = Config.HitboxColor
        part.Transparency = Config.HitboxVisible and Config.HitboxTransparency or 1
    end
end

-- Tool equip/unequip detection
local function onCharacterToolChanged()
    if Config.HitboxExpander then
        refreshAllHitboxes()
    end
end

local function setupCharacterListeners(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            onCharacterToolChanged()
        end
    end)
    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then
            onCharacterToolChanged()
        end
    end)
end

if player.Character then
    setupCharacterListeners(player.Character)
end

player.CharacterAdded:Connect(function(char)
    setupCharacterListeners(char)
    if Config.HitboxExpander then
        task.wait(0.3)
        refreshAllHitboxes()
    end
end)

-- Player added/removing
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        if Config.HitboxExpander and isHoldingKnife() then
            task.wait(0.3)
            addHitboxToPlayer(plr)
        end
    end)
    if Config.HitboxExpander and isHoldingKnife() and plr.Character then
        addHitboxToPlayer(plr)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    removeHitboxFromPlayer(plr)
end)

-- Initial population
if Config.HitboxExpander and isHoldingKnife() then
    refreshAllHitboxes()
end

-- Death/respawn handler
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    refreshAllHitboxes()
end)

-- //////////////////// UI Window ////////////////////
local Window = WindUI:CreateWindow({
    Title = "RuzHub",
    Icon = "sparkles",
    Author = "Ruz Hub",
    Folder = "RuzHub",
    Size = UDim2.fromOffset(650, 550),
    Theme = "Crimson",
    Acrylic = false,
    HideSearchBar = false,
    OpenButton = {
        Title = "RuzHub",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled = true,
        OnlyMobile = false,
        Color = ColorSequence.new(
            Color3.fromHex("#dc2626"),
            Color3.fromHex("#991b1b")
        ),
    },
})

local MainSection = Window:Section({ Title = "⚙️ Settings", Opened = true })
local MainTab = MainSection:Tab({ Title = "Main", Icon = "crosshair" })

-- Silent Aim Toggle
MainTab:Toggle({
    Title = "Silent Aim",
    Description = "Enable/disable silent aim",
    Default = Config.SilentAim,
    Callback = function(state)
        Config.SilentAim = state
    end
})

-- Aim Part Selector
MainTab:Dropdown({
    Title = "Aim Part",
    Description = "Which body part to aim at",
    Options = { "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart" },
    Default = Config.AimPart,
    Callback = function(option)
        Config.AimPart = option
    end
})

-- FOV Circle
MainTab:Toggle({
    Title = "FOV Circle",
    Description = "Show FOV circle",
    Default = Config.FOVVisible,
    Callback = function(state)
        Config.FOVVisible = state
    end
})

-- FOV Size as Input Box
MainTab:Input({
    Title = "FOV Size",
    Description = "Radius of FOV circle (30-300)",
    Default = tostring(Config.FOVSize),
    Placeholder = "90",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 30 and num <= 300 then
            Config.FOVSize = num
        end
    end
})

-- FOV Color Picker
MainTab:ColorPicker({
    Title = "FOV Color",
    Default = Config.FOVColor,
    Callback = function(color)
        Config.FOVColor = color
    end
})

-- Line ESP
MainTab:Toggle({
    Title = "Line ESP",
    Description = "Draw line to target",
    Default = Config.ESPVisible,
    Callback = function(state)
        Config.ESPVisible = state
    end
})

-- Line ESP Color Picker
MainTab:ColorPicker({
    Title = "Line Color",
    Default = Config.ESPColor,
    Callback = function(color)
        Config.ESPColor = color
    end
})

-- Target Highlight
MainTab:Toggle({
    Title = "Target Highlight",
    Description = "Glow target character",
    Default = Config.HighlightVisible,
    Callback = function(state)
        Config.HighlightVisible = state
    end
})

-- Highlight Color Picker
MainTab:ColorPicker({
    Title = "Highlight Color",
    Default = Config.HighlightColor,
    Callback = function(color)
        Config.HighlightColor = color
        Highlight.FillColor = color
        Highlight.OutlineColor = color
    end
})

-- Prediction
MainTab:Toggle({
    Title = "Prediction",
    Description = "Predict target movement",
    Default = Config.PredictionEnabled,
    Callback = function(state)
        Config.PredictionEnabled = state
    end
})

-- Prediction Multiplier Input
MainTab:Input({
    Title = "Prediction Multiplier",
    Description = "Higher = more lead (0.05-0.3)",
    Default = tostring(Config.PredictionMultiplier),
    Placeholder = "0.135",
    Callback = function(text)
        local num = tonumber(text)
        if num then
            Config.PredictionMultiplier = num
        end
    end
})

-- Hit Chance Input
MainTab:Input({
    Title = "Hit Chance (%)",
    Description = "Chance to hit (1-100)",
    Default = tostring(Config.HitChance),
    Placeholder = "100",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 1 and num <= 100 then
            Config.HitChance = num
        end
    end
})

-- Auto Air
MainTab:Toggle({
    Title = "Auto Air",
    Description = "Auto-shoot when target is in air",
    Default = Config.AutoAir,
    Callback = function(state)
        Config.AutoAir = state
    end
})

-- Air Shoot Delay Input
MainTab:Input({
    Title = "Air Shoot Delay",
    Description = "Delay in seconds (0.05-0.5)",
    Default = tostring(Config.AutoAirDelay),
    Placeholder = "0.10",
    Callback = function(text)
        local num = tonumber(text)
        if num then
            Config.AutoAirDelay = num
        end
    end
})

-- Hitbox Expander Section
MainTab:Divider()

MainTab:Toggle({
    Title = "🔪 Hitbox Expander (Only Knife)",
    Description = "Expands enemy hitboxes when you hold a knife",
    Default = Config.HitboxExpander,
    Callback = function(state)
        Config.HitboxExpander = state
        if state then
            WindUI:Notify({
                Title = "Hitbox Expander",
                Content = "🔪 Only works when holding a knife!",
                Duration = 4,
                Icon = "alert-triangle"
            })
            if isHoldingKnife() then
                refreshAllHitboxes()
            end
        else
            removeAllHitboxes()
        end
    end
})

-- Hitbox Size Input
MainTab:Input({
    Title = "Hitbox Size (studs)",
    Description = "Cube side length (1-10)",
    Default = tostring(Config.HitboxSize),
    Placeholder = "3",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 1 and num <= 10 then
            Config.HitboxSize = num
            updateHitboxVisuals()
        end
    end
})

-- Hitbox Visible Toggle
MainTab:Toggle({
    Title = "Show Hitbox",
    Description = "Make hitbox visible (for testing)",
    Default = Config.HitboxVisible,
    Callback = function(state)
        Config.HitboxVisible = state
        updateHitboxVisuals()
    end
})

-- Hitbox Color Picker
MainTab:ColorPicker({
    Title = "Hitbox Color",
    Description = "Color of visible hitbox",
    Default = Config.HitboxColor,
    Callback = function(color)
        Config.HitboxColor = color
        updateHitboxVisuals()
    end
})

-- Hitbox Transparency Input
MainTab:Input({
    Title = "Hitbox Transparency",
    Description = "0 = solid, 1 = invisible",
    Default = tostring(Config.HitboxTransparency),
    Placeholder = "0.5",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 0 and num <= 1 then
            Config.HitboxTransparency = num
            updateHitboxVisuals()
        end
    end
})

-- Status Label
local function updateStatus()
    local holding = isHoldingKnife() and "🔪 KNIFE EQUIPPED" or "⚔️ NO KNIFE"
    local hitboxStatus = Config.HitboxExpander and (holding) or "❌ DISABLED"
    MainTab:Label({
        Title = "Status: " .. hitboxStatus,
        Description = "Hitbox Expander " .. (Config.HitboxExpander and "ACTIVE" or "INACTIVE") .. " | " .. holding
    })
end

-- Monitor knife status
spawn(function()
    while task.wait(1) do
        if Config.HitboxExpander then
            local hadKnife = isHoldingKnife()
            task.wait(0.1)
            if isHoldingKnife() ~= hadKnife then
                refreshAllHitboxes()
            end
        end
    end
end)

print("✅ RuzHub Mm2 FFA Crimson Fully Loaded!")
print("🔴 Features: Silent Aim, FOV, ESP, Highlight, Prediction, Auto Air, Hitbox Expander")
print("🔪 Hitbox Expander only works when holding a KNIFE!")