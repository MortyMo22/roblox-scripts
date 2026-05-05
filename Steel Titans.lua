local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")


local LocalPlayer = Players.LocalPlayer



local EXCLUDED_MODELS = {
    GCamera = true,
    MinimapCamera = true,
    Terrain = true,
    TurCam = true,
    VP = true,
    RootSounds = true,
    ["Steel Fart Tank Sounds"] = true,
    ["Terrain Graph"] = true,
    ArmorHolder = true,
    Bushes = true,
    Ignore = true,
    Lobby = true,
    Map = true,
    AmmoContainer = true,
    FuelContainer = true,
    ["Barrel Container"] = true,
    PlacementGhosts = true,
    Spawns = true,
    TreesContainer = true,
    RainPart = true,
    Workspace = true
}

local UPDATE_INTERVAL = 0.08



local ESPData = {
    Tanks = {}
}

local Flags = {
    ESPEnabled = false,
    EnemyColor = Color3.fromRGB(255, 50, 50)
}



local function IsExcludedModel(name)
    return EXCLUDED_MODELS[name] == true
end

local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[Steel Titans ESP] Error:", result)
    end
    return result
end

local function IsInstanceValid(instance)
    if not instance then return false end
    if not pcall(function() local _ = instance.Parent end) then return false end
    return instance.Parent ~= nil
end



local function CreateHighlight(part)
    if not IsInstanceValid(part) then return end
    
    local highlight = part:FindFirstChild("ESP_Highlight")
    
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = part
        highlight.Parent = part
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 0.1
    end

    local color = Flags.EnemyColor
    

    
    if highlight.FillColor ~= color then
        highlight.FillColor = color
        highlight.OutlineColor = color
    end
end



local function RemoveHighlights(model)
    if not model then return end

    for _, part in ipairs(model:GetDescendants()) do
        if IsInstanceValid(part) and (part:IsA("MeshPart") or part:IsA("Part")) then
            local highlight = part:FindFirstChild("ESP_Highlight")
            if highlight and highlight:IsA("Highlight") then
                highlight:Destroy()
            end
        end
    end
end



local function UpdateTankESP(tankModel)
    if not IsInstanceValid(tankModel) then
        RemoveHighlights(tankModel)
        return
    end

    local mainPart = tankModel:FindFirstChild("Main")
    if not IsInstanceValid(mainPart) then return end

    

    local highlightPart = mainPart

    if Flags.ESPEnabled then
        CreateHighlight(highlightPart)
    else
        local highlight = highlightPart:FindFirstChild("ESP_Highlight")
        if highlight then
            highlight:Destroy()
        end
    end
end

local function RegisterTank(tankModel)
    if not IsInstanceValid(tankModel) or ESPData.Tanks[tankModel] then return end
    if IsExcludedModel(tankModel.Name) then return end

    local ownerValue = tankModel:FindFirstChild("Owner")
    if not ownerValue or not ownerValue:IsA("StringValue") then return end

    local ownerName = ownerValue.Value -- 🔥 ВОТ ЭТО ГЛАВНОЕ

    local mainPart = tankModel:FindFirstChild("Main")
    if not mainPart then return end

    -- не регистрируем свой танк
    if ownerName == LocalPlayer.Name then return end



    ESPData.Tanks[tankModel] = {
        Owner = ownerName,
        Registered = true
    }

    print("[Steel Titans] Tank registered: " .. tankModel.Name)
end


local function FullWorkspaceScan()
    for _, model in Workspace:GetChildren() do
        if not IsInstanceValid(model) then
            continue
        end

        if model:IsA("Model") and not IsExcludedModel(model.Name) then
            local owner = model:FindFirstChild("Owner")
            local main = model:FindFirstChild("Main")

            if owner and main then
                if not ESPData.Tanks[model] then
                    RegisterTank(model)
                end
            end
        end
    end
end


local function UpdateAllTanks()
    local toRemove = {}

    for tankModel, _ in pairs(ESPData.Tanks) do
        if not IsInstanceValid(tankModel) then
            table.insert(toRemove, tankModel)
        else
            UpdateTankESP(tankModel) -- 🔥 ВАЖНО
        end
    end

    for _, tankModel in ipairs(toRemove) do
        ESPData.Tanks[tankModel] = nil
        RemoveHighlights(tankModel)
    end
end



local function LoadUI()
    local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/MortyMo22/ui-libs/refs/heads/main/New%20UI"))()
    
    local app = UI.CreateWindow("Steel Titans ESP", "User: " .. LocalPlayer.UserId)
    local main = app:AddSection("Tank ESP")
    local left, right = main:AddUnderSections("ESP Settings", "Colors")
    
    left:Label("Tank ESP System v3.2", {bold = true, topMargin = 10})
    
    left:Toggle("ESP Enabled", {
        Default = false,
        Callback = function(state)
            Flags.ESPEnabled = state
            if not state then
                for tankModel, _ in pairs(ESPData.Tanks) do
                    RemoveHighlights(tankModel)
                end
            end
            print("[Steel Titans] ESP " .. (state and "✓ ON" or "✗ OFF"))
        end
    })
    

    left:Separator()
    
    left:Label("Color Settings", {bold = true, topMargin = 10})
    
    left:ToggleColor("Enemy Color", true, Flags.EnemyColor, function(state, color)
        Flags.EnemyColor = color
        print("[Steel Titans] Enemy Color Updated")
    end)
    
end


local lastScan = 0
local lastUpdate = 0
local lastCharCheck = 0

RunService.Heartbeat:Connect(function()
    local currentTime = tick()
    
    if currentTime - lastScan >= 3 then
        FullWorkspaceScan()
        lastScan = currentTime
    end
    

    
    if currentTime - lastUpdate >= UPDATE_INTERVAL then
        UpdateAllTanks()
        lastUpdate = currentTime
    end
end)


Workspace.ChildAdded:Connect(function(child)
    if not IsInstanceValid(child) then return end
    if not child:IsA("Model") then return end
    if IsExcludedModel(child.Name) then return end

    if child:FindFirstChild("Owner") and child:FindFirstChild("Main") then
        RegisterTank(child)
    end
end)






print("[Steel Titans ESP] Loading v3.2...")
LoadUI()
task.wait(0.5)
FullWorkspaceScan()

print("[Steel Titans ESP] ✓ Successfully loaded!")
