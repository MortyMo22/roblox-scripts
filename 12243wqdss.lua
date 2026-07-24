--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local UPDATE_INTERVAL = 0.05

local fakeCharacter = Instance.new("Model")
fakeCharacter.Name = "FakeCharacter_ServerView"
fakeCharacter.Parent = workspace

local fakeRootPart = Instance.new("Part")
fakeRootPart.Name = "HumanoidRootPart"
fakeRootPart.Size = rootPart.Size
fakeRootPart.CFrame = rootPart.CFrame
fakeRootPart.Anchored = true
fakeRootPart.CanCollide = false
fakeRootPart.Transparency = 1
fakeRootPart.Material = Enum.Material.Plastic
fakeRootPart.Parent = fakeCharacter

local boxAdornment = Instance.new("BoxHandleAdornment")
boxAdornment.Name = "ServerViewBox"
boxAdornment.Adornee = fakeRootPart
boxAdornment.Size = rootPart.Size + Vector3.new(0.5, 0.5, 0.5)
boxAdornment.Color3 = Color3.new(1, 1, 1)
boxAdornment.Transparency = 0.3
boxAdornment.ZIndex = 0
boxAdornment.AlwaysOnTop = true
boxAdornment.Parent = fakeRootPart

local fakeHumanoid = Instance.new("Humanoid")
fakeHumanoid.Name = "Humanoid"
fakeHumanoid.Parent = fakeCharacter

local positionHistory = {}

local function getRealPing()
    local ping = 0
    local pingSuccess, pingResult = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    
    if pingSuccess and pingResult then
        ping = pingResult
    end
    
    return ping
end

local function addPositionToHistory(position)
    local currentTime = tick()
    table.insert(positionHistory, {
        position = position,
        time = currentTime
    })
    
    local maxHistory = math.ceil(2000 / (UPDATE_INTERVAL * 1000)) + 10
    if #positionHistory > maxHistory then
        table.remove(positionHistory, 1)
    end
end

local function getPositionAtTime(targetTime)
    if #positionHistory == 0 then
        return rootPart.Position
    end
    
    local closestIndex = 1
    local closestDiff = math.abs(positionHistory[1].time - targetTime)
    
    for i = 2, #positionHistory do
        local diff = math.abs(positionHistory[i].time - targetTime)
        if diff < closestDiff then
            closestDiff = diff
            closestIndex = i
        end
    end
    
    return positionHistory[closestIndex].position
end

local function updateFakeCharacter()
    if not character or not character.Parent then return end
    if not rootPart or not rootPart.Parent then return end
    
    local ping = getRealPing()
    ping = math.max(10, math.min(1000, ping))
    
    local pingDelay = ping / 1000
    
    addPositionToHistory(rootPart.Position)
    
    local serverTime = tick() - pingDelay
    
    local serverPosition
    if #positionHistory > 1 then
        serverPosition = getPositionAtTime(serverTime)
    else
        serverPosition = rootPart.Position
    end
    
    local currentCFrame = rootPart.CFrame
    local newCFrame = CFrame.new(serverPosition) * (currentCFrame - currentCFrame.Position)
    fakeRootPart.CFrame = newCFrame
end

local connection = RunService.Heartbeat:Connect(function()
    updateFakeCharacter()
end)

local function cleanup()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    if fakeCharacter then
        fakeCharacter:Destroy()
    end
end

player.CharacterAdded:Connect(function(newCharacter)
    cleanup()
    
    character = newCharacter
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    positionHistory = {}
    
    fakeCharacter = Instance.new("Model")
    fakeCharacter.Name = "FakeCharacter_ServerView"
    fakeCharacter.Parent = workspace
    
    fakeRootPart = Instance.new("Part")
    fakeRootPart.Name = "HumanoidRootPart"
    fakeRootPart.Size = rootPart.Size
    fakeRootPart.CFrame = rootPart.CFrame
    fakeRootPart.Anchored = true
    fakeRootPart.CanCollide = false
    fakeRootPart.Transparency = 1
    fakeRootPart.Material = Enum.Material.Plastic
    fakeRootPart.Parent = fakeCharacter
    
    boxAdornment = Instance.new("BoxHandleAdornment")
    boxAdornment.Name = "ServerViewBox"
    boxAdornment.Adornee = fakeRootPart
    boxAdornment.Size = rootPart.Size + Vector3.new(0.5, 0.5, 0.5)
    boxAdornment.Color3 = Color3.new(1, 1, 1)
    boxAdornment.Transparency = 0.3
    boxAdornment.AlwaysOnTop = true
    boxAdornment.Parent = fakeRootPart
    
    fakeHumanoid = Instance.new("Humanoid")
    fakeHumanoid.Name = "Humanoid"
    fakeHumanoid.Parent = fakeCharacter
    
    connection = RunService.Heartbeat:Connect(function()
        updateFakeCharacter()
    end)
end)
