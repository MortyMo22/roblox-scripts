--[[
    ██████╗ ██╗      ██████╗ ██╗  ██╗███████╗
    ██╔══██╗██║     ██╔═══██╗╚██╗██╔╝██╔════╝
    ██████╔╝██║     ██║   ██║ ╚███╔╝ ███████╗
    ██╔══██╗██║     ██║   ██║ ██╔██╗ ╚════██║
    ██████╔╝███████╗╚██████╔╝██╔╝ ██╗███████║
    ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
    
    Steel Titans - Tank ESP System v3.0 HYBRID
    Author: MortyMo22
    Game: Steel Titans
    
    Hybrid version combining:
    - Reliable Char.Value detection
    - Advanced LineOfSight visibility
    - Team Check system
    - Dual color rendering
]]

--[[ ==================== SERVICE INITIALIZATION ==================== ]]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--[[ ==================== CONFIGURATION ==================== ]]
local EXCLUDED_MODELS = {
    "GCamera", "MinimapCamera", "Terrain", "TurCam", "VP", "RootSounds",
    "Steel Fart Tank Sounds", "Terrain Graph", "ArmorHolder", "Bushes",
    "Ignore", "Lobby", "Map", "AmmoContainer", "FuelContainer",
    "Barrel Container", "PlacementGhosts", "Spawns", "TreesContainer",
    "RainPart", "Workspace"
}

local RAYCAST_DISTANCE = 10000
local UPDATE_INTERVAL = 0.08
local REGISTRATION_DELAY = 0.2

--[[ ==================== DATA STRUCTURES ==================== ]]
local ESPData = {
    Tanks = {},
    LocalPlayerTank = nil,
    LocalPlayerTeam = nil
}

local Flags = {
    ESPEnabled = false,
    TeamCheck = false,
    VisibleColor = Color3.fromRGB(50, 200, 50),
    NotVisibleColor = Color3.fromRGB(255, 50, 50)
}

--[[ ==================== UTILITY FUNCTIONS ==================== ]]

local function IsExcludedModel(name)
    for _, excluded in ipairs(EXCLUDED_MODELS) do
        if name == excluded then return true end
    end
    return false
end

local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[Steel Titans ESP] Error:", result)
        return nil
    end
    return result
end

local function IsInstanceValid(instance)
    if not instance then return false end
    if not pcall(function() local _ = instance.Parent end) then return false end
    return instance.Parent ~= nil
end

--[[ ==================== TANK DETECTION - IMPROVED ==================== ]]

local function GetPlayerTank(Player)
    SafeCall(function()
        local CharValue = Player:FindFirstChild("Char")
        if not CharValue or not CharValue:IsA("StringValue") then return nil end
        
        local charVal = CharValue.Value
        if not charVal or charVal == "" then return nil end
        
        -- Если игрок в бою (Engine существует)
        if charVal == "Engine" then
            -- Ищем модель по Owner
            for _, model in ipairs(Workspace:GetChildren()) do
                if not IsInstanceValid(model) then continue end
                if model:IsA("Model") and model:FindFirstChild("Owner") then
                    local ownerVal = model:FindFirstChild("Owner")
                    if ownerVal and ownerVal:IsA("StringValue") and ownerVal.Value == Player.Name then
                        return model
                    end
                end
            end
        end
    end)
    return nil
end

local function FindLocalPlayerTank()
    return GetPlayerTank(LocalPlayer)
end

local function GetPlayerTeam(playerName)
    for _, team in ipairs(Teams:GetChildren()) do
        if not IsInstanceValid(team) then continue end
        if team:IsA("Team") then
            for _, player in ipairs(team:GetPlayers()) do
                if player.Name == playerName then
                    return team
                end
            end
        end
    end
    return nil
end

local function IsTeammate(playerName)
    if not ESPData.LocalPlayerTeam then return false end
    local targetTeam = GetPlayerTeam(playerName)
    return targetTeam == ESPData.LocalPlayerTeam
end

--[[ ==================== LINEOFISGHT - ADVANCED ==================== ]]

local function IsPartVisible(targetPart)
    if not IsInstanceValid(targetPart) then return false end
    if not IsInstanceValid(Camera) then return true end
    
    SafeCall(function()
        local rayOrigin = Camera.CFrame.Position
        local rayDirection = (targetPart.Position - rayOrigin).Unit * RAYCAST_DISTANCE
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        
        -- Исключаем свой танк из raycast'а
        if ESPData.LocalPlayerTank then
            raycastParams.FilterDescendantsInstances = {ESPData.LocalPlayerTank}
        else
            raycastParams.FilterDescendantsInstances = {}
        end
        
        local rayResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        
        -- Если raycast ничего не попал = видимо
        if not rayResult then return true end
        
        -- Если попал в целевую часть = видимо
        if rayResult.Instance == targetPart then return true end
        
        -- Если попал в другую часть того же танка = видимо
        if targetPart.Parent and rayResult.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
        
        -- Иначе = скрыто за стеной
        return false
    end)
    
    return false
end

--[[ ==================== HIGHLIGHT MANAGEMENT ==================== ]]

local function CreateHighlight(part, visible)
    if not IsInstanceValid(part) then return end
    
    SafeCall(function()
        local highlight = part:FindFirstChildOfClass("Highlight")
        
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Parent = part
            highlight.FillTransparency = 0.35
            highlight.OutlineTransparency = 0.1
        end
        
        if IsInstanceValid(highlight) then
            if visible then
                highlight.FillColor = Flags.VisibleColor
                highlight.OutlineColor = Flags.VisibleColor
            else
                highlight.FillColor = Flags.NotVisibleColor
                highlight.OutlineColor = Flags.NotVisibleColor
            end
        end
    end)
end

local function RemoveHighlights(model)
    if not model then return end
    
    SafeCall(function()
        for _, part in ipairs(model:GetDescendants()) do
            if IsInstanceValid(part) and (part:IsA("MeshPart") or part:IsA("Part")) then
                local highlight = part:FindFirstChildOfClass("Highlight")
                if highlight and IsInstanceValid(highlight) then
                    highlight:Destroy()
                end
            end
        end
    end)
end

--[[ ==================== TANK PROCESSING ==================== ]]

local function UpdateTankESP(tankModel)
    if not IsInstanceValid(tankModel) then
        RemoveHighlights(tankModel)
        return
    end
    
    SafeCall(function()
        local mainPart = tankModel:FindFirstChild("Main")
        if not IsInstanceValid(mainPart) then return end
        
        for _, descendant in ipairs(mainPart:GetDescendants()) do
            if not IsInstanceValid(descendant) then continue end
            if descendant:IsA("MeshPart") or descendant:IsA("Part") then
                if Flags.ESPEnabled then
                    local isVisible = IsPartVisible(descendant)
                    CreateHighlight(descendant, isVisible)
                else
                    local highlight = descendant:FindFirstChildOfClass("Highlight")
                    if IsInstanceValid(highlight) then
                        highlight:Destroy()
                    end
                end
            end
        end
    end)
end

local function RegisterTank(tankModel)
    if not IsInstanceValid(tankModel) or ESPData.Tanks[tankModel] then return end
    if IsExcludedModel(tankModel.Name) then return end
    
    SafeCall(function()
        local ownerValue = tankModel:FindFirstChild("Owner")
        if not ownerValue or not ownerValue:IsA("StringValue") then return end
        
        local mainPart = tankModel:FindFirstChild("Main")
        if not mainPart then return end
        
        local ownerName = ownerValue.Value
        
        -- Не регистрируем свой танк
        if ownerName == LocalPlayer.Name then return end
        
        local ownerTeam = GetPlayerTeam(ownerName)
        
        ESPData.Tanks[tankModel] = {
            Owner = ownerName,
            Team = ownerTeam,
            Registered = true
        }
        
        print("[Steel Titans] Tank registered: " .. tankModel.Name .. " (Owner: " .. ownerName .. ")")
    end)
end

local function UnregisterTank(tankModel)
    if not tankModel then return end
    
    SafeCall(function()
        RemoveHighlights(tankModel)
        ESPData.Tanks[tankModel] = nil
        print("[Steel Titans] Tank unregistered: " .. tankModel.Name)
    end)
end

local function ShouldShowESP(tankModel)
    if not Flags.ESPEnabled then return false end
    if not IsInstanceValid(tankModel) then return false end
    
    local tankData = ESPData.Tanks[tankModel]
    if not tankData then return false end
    
    if Flags.TeamCheck then
        if IsTeammate(tankData.Owner) then
            return false
        end
    end
    
    return true
end

--[[ ==================== MAIN SCANNING SYSTEM ==================== ]]

local function FullWorkspaceScan()
    SafeCall(function()
        for _, model in ipairs(Workspace:GetChildren()) do
            if not IsInstanceValid(model) then continue end
            if model:IsA("Model") and not IsExcludedModel(model.Name) then
                if model:FindFirstChild("Owner") and model:FindFirstChild("Main") then
                    if not ESPData.Tanks[model] then
                        RegisterTank(model)
                    end
                end
            end
        end
    end)
end

local function UpdateAllTanks()
    local toRemove = {}
    
    for tankModel, _ in pairs(ESPData.Tanks) do
        if not IsInstanceValid(tankModel) then
            table.insert(toRemove, tankModel)
        elseif ShouldShowESP(tankModel) then
            UpdateTankESP(tankModel)
        else
            RemoveHighlights(tankModel)
        end
    end
    
    for _, tankModel in ipairs(toRemove) do
        UnregisterTank(tankModel)
    end
end

--[[ ==================== UI SYSTEM ==================== ]]

local function LoadUI()
    SafeCall(function()
        local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/MortyMo22/ui-libs/refs/heads/main/New%20UI"))()
        
        local app = UI.CreateWindow("Steel Titans ESP", "User: " .. LocalPlayer.UserId)
        local main = app:AddSection("Tank ESP")
        local left, right = main:AddUnderSections("ESP Settings", "Colors")
        
        left:Label("Tank ESP System v3.0", {bold = true, topMargin = 10})
        
        left:Toggle("ESP Enabled", {
            Default = false,
            Callback = function(state)
                Flags.ESPEnabled = state
                if not state then
                    for tankModel, _ in pairs(ESPData.Tanks) do
                        RemoveHighlights(tankModel)
                    end
                end
                print("[Steel Titans] ESP " .. (state and "✓ Enabled" or "✗ Disabled"))
            end
        })
        
        left:Toggle("Team Check", {
            Default = false,
            Callback = function(state)
                Flags.TeamCheck = state
                print("[Steel Titans] Team Check " .. (state and "✓ Enabled" or "✗ Disabled"))
            end
        })
        
        left:Separator()
        left:Label("Char.Value detection", {italic = true})
        left:Label("Update: " .. UPDATE_INTERVAL .. "s", {italic = true})
        
        right:Label("Color Settings", {bold = true, topMargin = 10})
        
        right:ToggleColor("Visible Parts", true, Flags.VisibleColor, function(state, color)
            Flags.VisibleColor = color
            print("[Steel Titans] Visible Color Updated")
        end)
        
        right:ToggleColor("Hidden Parts", true, Flags.NotVisibleColor, function(state, color)
            Flags.NotVisibleColor = color
            print("[Steel Titans] Hidden Color Updated")
        end)
        
        right:Label("Based on LineOfSight", {italic = true, topMargin = 15})
        
    end)
end

--[[ ==================== MAIN LOOP ==================== ]]

local lastScan = 0
local lastUpdate = 0
local lastCharCheck = 0

RunService.RenderStepped:Connect(function()
    local currentTime = tick()
    
    -- Scan workspace every 1 second
    if currentTime - lastScan >= 1 then
        FullWorkspaceScan()
        lastScan = currentTime
    end
    
    -- Check local player tank every 2 seconds
    if currentTime - lastCharCheck >= 2 then
        if not IsInstanceValid(ESPData.LocalPlayerTank) then
            ESPData.LocalPlayerTank = FindLocalPlayerTank()
            if IsInstanceValid(ESPData.LocalPlayerTank) then
                ESPData.LocalPlayerTeam = GetPlayerTeam(LocalPlayer.Name)
                print("[Steel Titans] Local tank found via Char.Value!")
            end
        end
        lastCharCheck = currentTime
    end
    
    -- Update ESP every UPDATE_INTERVAL seconds
    if currentTime - lastUpdate >= UPDATE_INTERVAL then
        UpdateAllTanks()
        lastUpdate = currentTime
    end
end)

--[[ ==================== WORKSPACE LISTENERS ==================== ]]

Workspace.ChildAdded:Connect(function(child)
    if IsExcludedModel(child.Name) then return end
    
    task.delay(REGISTRATION_DELAY, function()
        SafeCall(function()
            if not IsInstanceValid(child) then return end
            if child:IsA("Model") and child:FindFirstChild("Owner") and child:FindFirstChild("Main") then
                if not ESPData.Tanks[child] then
                    RegisterTank(child)
                end
            end
        end)
    end)
end)

Workspace.ChildRemoved:Connect(function(child)
    SafeCall(function()
        if ESPData.Tanks[child] then
            UnregisterTank(child)
        end
    end)
end)

--[[ ==================== CAMERA TRACKING ==================== ]]

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    SafeCall(function()
        Camera = Workspace.CurrentCamera
    end)
end)

--[[ ==================== CHAR VALUE MONITORING ==================== ]]

LocalPlayer:FindFirstChild("Char"):GetPropertyChangedSignal("Value"):Connect(function()
    SafeCall(function()
        local charVal = LocalPlayer.Char.Value
        if charVal == "Engine" then
            -- Игрок вошёл в бой
            task.wait(0.5)
            ESPData.LocalPlayerTank = FindLocalPlayerTank()
            if IsInstanceValid(ESPData.LocalPlayerTank) then
                ESPData.LocalPlayerTeam = GetPlayerTeam(LocalPlayer.Name)
                print("[Steel Titans] Player entered battle - tank found!")
            end
        else
            -- Игрок вышел из боя
            print("[Steel Titans] Player left battle")
            ESPData.LocalPlayerTank = nil
            ESPData.LocalPlayerTeam = nil
            for tankModel, _ in pairs(ESPData.Tanks) do
                RemoveHighlights(tankModel)
            end
        end
    end)
end)

--[[ ==================== INITIALIZATION ==================== ]]

print("[Steel Titans ESP] Initializing system v3.0 HYBRID...")
LoadUI()
task.wait(0.5)
FullWorkspaceScan()

print("[Steel Titans ESP] ✓ Loaded successfully!")
print("[Steel Titans ESP] Using Char.Value detection for tank identification")
print("[Steel Titans ESP] Settings: ESPEnabled=" .. tostring(Flags.ESPEnabled) .. " | TeamCheck=" .. tostring(Flags.TeamCheck))
