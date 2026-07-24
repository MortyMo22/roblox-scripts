--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
--[[
its a hook based clientside desync
No NetworkOwner errors anymore • No lag btwww • Spin auto-pause so no detects
]]
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 180)
Frame.Position = UDim2.new(0.5, -100, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = Frame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(100, 100, 100)
FrameStroke.Thickness = 1
FrameStroke.Parent = Frame

local FrameShadow = Instance.new("ImageLabel")
FrameShadow.Image = "rbxassetid://1316045217"
FrameShadow.ImageTransparency = 0.5
FrameShadow.BackgroundTransparency = 1
FrameShadow.Size = UDim2.new(1, 10, 1, 10)
FrameShadow.Position = UDim2.new(0, -5, 0, -5)
FrameShadow.ZIndex = Frame.ZIndex - 1
FrameShadow.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 100, 0, 40)
ToggleButton.Position = UDim2.new(0.5, -50, 0, 45)
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ToggleButton.Text = "Desync: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18
ToggleButton.Parent = Frame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleButton

local CustomToggleButton = Instance.new("TextButton")
CustomToggleButton.Size = UDim2.new(0, 100, 0, 40)
CustomToggleButton.Position = UDim2.new(0.5, -50, 0, 95)
CustomToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
CustomToggleButton.Text = "Custom: OFF"
CustomToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CustomToggleButton.Font = Enum.Font.SourceSansBold
CustomToggleButton.TextSize = 18
CustomToggleButton.Parent = Frame

local CustomToggleCorner = Instance.new("UICorner")
CustomToggleCorner.CornerRadius = UDim.new(0, 6)
CustomToggleCorner.Parent = CustomToggleButton

local TextBoxX = Instance.new("TextBox")
TextBoxX.Size = UDim2.new(0, 50, 0, 30)
TextBoxX.Position = UDim2.new(0, 20, 0, 140)
TextBoxX.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TextBoxX.Text = "0"
TextBoxX.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBoxX.Font = Enum.Font.SourceSans
TextBoxX.TextSize = 16
TextBoxX.Visible = false
TextBoxX.Parent = Frame

local TextBoxXCorner = Instance.new("UICorner")
TextBoxXCorner.CornerRadius = UDim.new(0, 4)
TextBoxXCorner.Parent = TextBoxX

local TextBoxY = Instance.new("TextBox")
TextBoxY.Size = UDim2.new(0, 50, 0, 30)
TextBoxY.Position = UDim2.new(0, 75, 0, 140)
TextBoxY.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TextBoxY.Text = "0"
TextBoxY.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBoxY.Font = Enum.Font.SourceSans
TextBoxY.TextSize = 16
TextBoxY.Visible = false
TextBoxY.Parent = Frame

local TextBoxYCorner = Instance.new("UICorner")
TextBoxYCorner.CornerRadius = UDim.new(0, 4)
TextBoxYCorner.Parent = TextBoxY

local TextBoxZ = Instance.new("TextBox")
TextBoxZ.Size = UDim2.new(0, 50, 0, 30)
TextBoxZ.Position = UDim2.new(0, 130, 0, 140)
TextBoxZ.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TextBoxZ.Text = "0"
TextBoxZ.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBoxZ.Font = Enum.Font.SourceSans
TextBoxZ.TextSize = 16
TextBoxZ.Visible = false
TextBoxZ.Parent = Frame

local TextBoxZCorner = Instance.new("UICorner")
TextBoxZCorner.CornerRadius = UDim.new(0, 4)
TextBoxZCorner.Parent = TextBoxZ

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -40, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 20
MinimizeButton.Parent = Frame

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 4)
MinimizeCorner.Parent = MinimizeButton

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -70, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 20
CloseButton.Parent = Frame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

local desyncT = {enabled = false, loc = CFrame.new()}
local customDesyncEnabled = false
local isMinimized = false

local frameTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function validateTextboxInput(textbox)
    textbox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = textbox.Text
        if text == "" or text == "-" or text == "+" then return end
        if not text:match("^[+-]?%d*%.?%d*$") then
            textbox.Text = "0"
        end
    end)
end
validateTextboxInput(TextBoxX)
validateTextboxInput(TextBoxY)
validateTextboxInput(TextBoxZ)

ToggleButton.MouseButton1Click:Connect(function()
    desyncT.enabled = not desyncT.enabled
    ToggleButton.Text = desyncT.enabled and "Desync: ON" or "Desync: OFF"
end)

CustomToggleButton.MouseButton1Click:Connect(function()
    customDesyncEnabled = not customDesyncEnabled
    CustomToggleButton.Text = customDesyncEnabled and "Custom: ON" or "Custom: OFF"
    TextBoxX.Visible = customDesyncEnabled and not isMinimized
    TextBoxY.Visible = customDesyncEnabled and not isMinimized
    TextBoxZ.Visible = customDesyncEnabled and not isMinimized
end)

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local newSize = isMinimized and UDim2.new(0, 200, 0, 40) or UDim2.new(0, 200, 0, 180)
    MinimizeButton.Text = isMinimized and "+" or "-"
    TweenService:Create(Frame, frameTweenInfo, {Size = newSize}):Play()
    ToggleButton.Visible = not isMinimized
    CustomToggleButton.Visible = not isMinimized
    TextBoxX.Visible = customDesyncEnabled and not isMinimized
    TextBoxY.Visible = customDesyncEnabled and not isMinimized
    TextBoxZ.Visible = customDesyncEnabled and not isMinimized
end)


CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    desyncT.enabled = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.C then
        desyncT.enabled = not desyncT.enabled
        ToggleButton.Text = desyncT.enabled and "Desync: ON" or "Desync: OFF"
    end
end)

local desynchook = nil
local prevLookVector = nil
local isSpinning = false
local spinThreshold = 15

local function getOffsetCFrame()
    if customDesyncEnabled then
        local x = tonumber(TextBoxX.Text) or 0
        local y = tonumber(TextBoxY.Text) or 0
        local z = tonumber(TextBoxZ.Text) or 0
        return CFrame.new(x, y, z)
    else
        local ping = LocalPlayer:GetNetworkPing() * 1000
        if ping < 100 then return CFrame.new(0, 0, -2)
        elseif ping <= 170 then return CFrame.new(0, 0, -2.7)
        else return CFrame.new(0, 0, -3.7) end
    end
end

RunService.Heartbeat:Connect(function()
    if not desyncT.enabled or not LocalPlayer.Character then return end
    
    local character = LocalPlayer.Character
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local currentLook = root.CFrame.LookVector
    if prevLookVector then
        local dot = math.clamp(prevLookVector:Dot(currentLook), -1, 1)
        local angleDiff = math.deg(math.acos(dot))
        isSpinning = angleDiff > spinThreshold
    end
    prevLookVector = currentLook
    
    if isSpinning then return end 
    
    desyncT.loc = root.CFrame
    
    local offset = getOffsetCFrame()
    local newCFrame = desyncT.loc * offset
    root.CFrame = newCFrame
    
    RunService.RenderStepped:Wait()
    root.CFrame = desyncT.loc
end)

desynchook = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if desyncT.enabled and not checkcaller() and 
       key == "CFrame" and 
       LocalPlayer.Character and 
       self == LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
       not isSpinning then
        return desyncT.loc
    end
    return desynchook(self, key)
end))

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    prevLookVector = nil
    isSpinning = false
end)

print("HOOK DESYNC LOADED - Client-side only, others see server pos!")
