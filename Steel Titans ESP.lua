--[[
    ██████╗ ██╗      ██████╗ ██╗  ██╗███████╗
    ██╔══██╗██║     ██╔═══██╗╚██╗██╔╝██╔════╝
    ██████╔╝██║     ██║   ██║ ╚███╔╝ ███████╗
    ██╔══██╗██║     ██║   ██║ ██╔██╗ ╚════██║
    ██████╔╝███████╗╚██████╔╝██╔╝ ██╗███████║
    ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
    
    Steel Titans - Tank ESP System v1.0
    Author: MortyMo22
    Game: Steel Titans
    
    Features:
    - Real-time Tank ESP with Highlight
    - LineOfSight detection (Visible/Not Visible)
    - Team Check system
    - Dual color rendering
    - Memory leak protection
    - Dynamic model scanning
]]

--[[ ==================== SERVICE INITIALIZATION ==================== ]]
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Teams = game:GetService("Teams")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--[[ ==================== CONFIGURATION ==================== ]]
local EXCLUDED_MODELS = {
    "GCamera", "MinimapCamera", "Terrain", "TurCam", "VP", "RootSounds",
    "Steel Fart Tank Sounds", "Terrain Graph", "ArmorHolder", "Bushes",
    "Ignore", "Lobby", "Map", "AmmoContainer", "FuelContainer",
    "Barrel Container", "PlacementGhosts", "Spawns", "TreesContainer",
    "RainPart"
}

local RAYCAST_DISTANCE = 5000
local RAYCASTING_ENABLED = true
local UPDATE_INTERVAL = 0.1 -- Update frequency in seconds

--[[ ==================== DATA STRUCTURES ==================== ]]
local ESPData = {
    Tanks = {},           -- {TankModel = {Owner = string, Team = Team, ESPObjects = {}}}
    LocalPlayerTank = nil,
    LocalPlayerTeam = nil
}

local Flags = {
    ESPEnabled = false,
    TeamCheck = false,
    VisibleColor = Color3.fromRGB(50, 200, 50),   -- Green
    NotVisibleColor = Color3.fromRGB(255, 50, 50) -- Red
}

--[[ ==================== UTILITY FUNCTIONS ==================== ]]

--- Check if model should be ignored
local function IsExcludedModel(name)
    for _, excluded in ipairs(EXCLUDED_MODELS) do
        if name == excluded then return true end
    end
    return false
end

--- Safe pcall wrapper with error handling
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[Steel Titans ESP] Error:", result)
        return nil
    end
    return result
end

--- Find player's tank in workspace
local function FindLocalPlayerTank()
    for _, model in ipairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("Owner") then
            local ownerValue = model:FindFirstChild("Owner")
            if ownerValue and ownerValue:IsA("StringValue") then
                if ownerValue.Value == LocalPlayer.Name then
                    return model
                end
            end
        end
    end
    return nil
end

--- Get player's team
local function GetPlayerTeam(playerName)
    for _, team in ipairs(Teams:GetChildren()) do
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

--- Check if player is in local player's team
local function IsTeammate(playerName)
    if not ESPData.LocalPlayerTeam then return false end
    local targetTeam = GetPlayerTeam(playerName)
    return targetTeam == ESPData.LocalPlayerTeam
end

--- Raycast to check visibility
local function IsPartVisible(tankPart)
    if not ESPData.LocalPlayerTank then return false end
    if not RAYCASTING_ENABLED then return true end
    
    local localTankParts = ESPData.LocalPlayerTank:FindFirstChild("Main")
    if not localTankParts then return false end
    
    -- Get origin point (center of local tank)
    local originPart = localTankParts:FindFirstChildOfClass("MeshPart") or localTankParts:FindFirstChildOfClass("Part")
    if not originPart then return false end
    
    local rayOrigin = originPart.Position
    local rayDirection = (tankPart.Position - rayOrigin).Unit * RAYCAST_DISTANCE
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    -- Exclude local player's tank from raycast
    local excludeList = {ESPData.LocalPlayerTank}
    raycastParams.FilterDescendantsInstances = excludeList
    
    local rayResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    -- If raycast hit nothing or hit the target part = visible
    if not rayResult then return true end
    if rayResult.Instance:IsDescendantOf(tankPart.Parent) then return true end
    
    return false
end

--- Create or update highlight for a part
local function CreateHighlight(part, visible)
    if not part or not part.Parent then return end
    
    local highlight = part:FindFirstChildOfClass("Highlight")
    
    if not highlight then
        SafeCall(function()
            highlight = Instance.new("Highlight")
            highlight.Parent = part
            highlight.FillTransparency = 0.3
            highlight.OutlineTransparency = 0
        end)
    end
    
    if highlight then
        SafeCall(function()
            if visible then
                highlight.FillColor = Flags.VisibleColor
                highlight.OutlineColor = Flags.VisibleColor
            else
                highlight.FillColor = Flags.NotVisibleColor
                highlight.OutlineColor = Flags.NotVisibleColor
            end
        end)
    end
    
    return highlight
end

--- Clean up all highlights from a model
local function RemoveHighlights(model)
    if not model then return end
    
    SafeCall(function()
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("MeshPart") or part:IsA("Part") then
                local highlight = part:FindFirstChildOfClass("Highlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end)
end

--- Process all MeshParts in tank
local function UpdateTankESP(tankModel)
    if not tankModel or not tankModel.Parent then
        RemoveHighlights(tankModel)
        return
    end
    
    SafeCall(function()
        for _, descendant in ipairs(tankModel:GetDescendants()) do
            if descendant:IsA("MeshPart") or descendant:IsA("Part") then
                if Flags.ESPEnabled then
                    local isVisible = IsPartVisible(descendant)
                    CreateHighlight(descendant, isVisible)
                else
                    local highlight = descendant:FindFirstChildOfClass("Highlight")
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
    end)
end

--- Register new tank for ESP
local function RegisterTank(tankModel)
    if not tankModel or ESPData.Tanks[tankModel] then return end
    
    SafeCall(function()
        local ownerValue = tankModel:FindFirstChild("Owner")
        if not ownerValue or not ownerValue:IsA("StringValue") then return end
        
        local ownerName = ownerValue.Value
        local ownerTeam = GetPlayerTeam(ownerName)
        
        ESPData.Tanks[tankModel] = {
            Owner = ownerName,
            Team = ownerTeam,
            ESPObjects = {}
        }
    end)
end

--- Unregister tank and clean up
local function UnregisterTank(tankModel)
    if not tankModel then return end
    
    SafeCall(function()
        RemoveHighlights(tankModel)
        ESPData.Tanks[tankModel] = nil
    end)
end

--- Filter tank based on team check
local function ShouldShowESP(tankModel)
    if not Flags.ESPEnabled then return false end
    
    local tankData = ESPData.Tanks[tankModel]
    if not tankData then return false end
    
    -- Don't show ESP for own tank
    if tankData.Owner == LocalPlayer.Name then return false end
    
    -- Apply team check
    if Flags.TeamCheck then
        if IsTeammate(tankData.Owner) then
            return false -- Don't show teammates
        end
    end
    
    return true
end

--[[ ==================== MAIN SCANNING SYSTEM ==================== ]]

--- Scan workspace for tanks
local function ScanWorkspace()
    SafeCall(function()
        for _, model in ipairs(Workspace:GetChildren()) do
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

--- Update all registered tanks
local function UpdateAllTanks()
    for tankModel, _ in pairs(ESPData.Tanks) do
        if not tankModel or not tankModel.Parent then
            UnregisterTank(tankModel)
        elseif ShouldShowESP(tankModel) then
            UpdateTankESP(tankModel)
        else
            RemoveHighlights(tankModel)
        end
    end
end

--[[ ==================== UI SYSTEM ==================== ]]

local function LoadUI()
    SafeCall(function()
        local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/MortyMo22/ui-libs/refs/heads/main/New%20UI"))()
        
        local app = UI.CreateWindow("Steel Titans ESP", "User: " .. LocalPlayer.UserId)
        local main = app:AddSection("Tank ESP")
        local left, right = main:AddUnderSections("ESP Settings", "Colors")
        
        -- Left column - ESP Settings
        left:Label("Tank ESP System", {bold = true, topMargin = 10})
        
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
        left:Label("Update every " .. UPDATE_INTERVAL .. "s", {italic = true})
        
        -- Right column - Colors
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

RunService.RenderStepped:Connect(function()
    local currentTime = tick()
    
    -- Scan workspace every second
    if currentTime - lastScan >= 1 then
        ScanWorkspace()
        lastScan = currentTime
    end
    
    -- Update ESP every UPDATE_INTERVAL seconds
    if currentTime - lastUpdate >= UPDATE_INTERVAL then
        if not ESPData.LocalPlayerTank then
            ESPData.LocalPlayerTank = FindLocalPlayerTank()
            if ESPData.LocalPlayerTank then
                ESPData.LocalPlayerTeam = GetPlayerTeam(LocalPlayer.Name)
                print("[Steel Titans] Local tank found: " .. ESPData.LocalPlayerTank.Name)
            end
        end
        
        UpdateAllTanks()
        lastUpdate = currentTime
    end
end)

--[[ ==================== WORKSPACE LISTENERS ==================== ]]

Workspace.ChildAdded:Connect(function(child)
    task.wait(0.5)
    SafeCall(function()
        if child:IsA("Model") and not IsExcludedModel(child.Name) then
            if child:FindFirstChild("Owner") and child:FindFirstChild("Main") then
                RegisterTank(child)
                print("[Steel Titans] New tank detected: " .. child.Name)
            end
        end
    end)
end)

Workspace.ChildRemoved:Connect(function(child)
    SafeCall(function()
        if ESPData.Tanks[child] then
            UnregisterTank(child)
            print("[Steel Titans] Tank removed: " .. child.Name)
        end
    end)
end)

--[[ ==================== CAMERA TRACKING ==================== ]]

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    SafeCall(function()
        Camera = Workspace.CurrentCamera
    end)
end)

--[[ ==================== INITIALIZATION ==================== ]]

print("[Steel Titans ESP] Initializing system...")
LoadUI()
ScanWorkspace()

print("[Steel Titans ESP] ✓ Loaded successfully!")
print("[Steel Titans ESP] Settings: ESPEnabled=" .. tostring(Flags.ESPEnabled) .. " | TeamCheck=" .. tostring(Flags.TeamCheck))
