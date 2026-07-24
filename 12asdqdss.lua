--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- I Love Aint♥️
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local CoreGui=game:GetService("CoreGui")
local RunService=game:GetService("RunService")

local lp=Players.LocalPlayer
local lpC=lp.Character or lp.CharacterAdded:Wait()
local lpH=lpC:WaitForChild("HumanoidRootPart")
local rm={}
local rn=Raknet or raknet
local nT,iOn,voidActive,blockActive,dCon=false,false,false,false,nil
local lastClean=0
local originalFallHeight=Workspace.FallenPartsDestroyHeight

local function getFTI()
    local t={}
    if not blockActive then return t end
    for _,v in ipairs(Workspace:GetDescendants())do if v:IsA("FireTouchInterest")then t[#t+1]=v end end
    return t
end

local function removeFTI()
    rm={}
    for _,v in ipairs(getFTI())do rm[#rm+1]={v,v.Parent} v.Parent=nil end
end

local function restoreFTI()
    for _,v in ipairs(rm)do if v[1]and not v[1].Parent then v[1].Parent=v[2]end end
    rm={}
end

local blockerConnection=Workspace.DescendantAdded:Connect(function(d)
    if not blockActive then return end
    if d:IsA("FireTouchInterest")or d:IsA("TouchInterest")then
        if d.Parent then
            local model=d.Parent:FindFirstAncestorOfClass("Model")
            if model then
                local player=Players:GetPlayerFromCharacter(model)
                if player and player~=lp then d:Destroy() end
            end
        end
    end
end)

lp.CharacterAdded:Connect(function(c)
    lpC=c
    lpH=c:WaitForChild("HumanoidRootPart")
    if blockerConnection then blockerConnection:Disconnect()end
    blockerConnection=Workspace.DescendantAdded:Connect(function(d)
        if not blockActive then return end
        if d:IsA("FireTouchInterest")or d:IsA("TouchInterest")then
            if d.Parent then
                local model=d.Parent:FindFirstAncestorOfClass("Model")
                if model then
                    local player=Players:GetPlayerFromCharacter(model)
                    if player and player~=lp then d:Destroy()end
                end
            end
        end
    end)
end)

local function cleanPlayer(p)
    if p==lp then return end
    local function clean(inst)
        if not inst then return end
        for _,ch in pairs(inst:GetChildren())do task.spawn(function()
            local part=ch:FindFirstChildWhichIsA("Part",true)
            if part then
                local ti=part:FindFirstChild("TouchInterest")or part:FindFirstChild("FireTouchInterest")
                if ti then ti:Destroy()end
            end
        end)end
    end
    local bp=p:FindFirstChild("Backpack")
    if bp then clean(bp) bp.ChildAdded:Connect(clean)end
    if p.Character then clean(p.Character) p.CharacterAdded:Connect(clean)end
end

for _,p in pairs(Players:GetPlayers())do cleanPlayer(p)end
Players.PlayerAdded:Connect(cleanPlayer)

RunService.Heartbeat:Connect(function(dt)
    lastClean=lastClean+dt
    if not blockActive or not lpH or lastClean<0.5 then return end
    lastClean=0
    for _,p in pairs(Players:GetPlayers())do
        if p~=lp then
            local c=p.Character
            if c and c.PrimaryPart and (c.PrimaryPart.Position-lpH.Position).Magnitude<100 then
                for _,t in pairs(c:GetChildren())do if t:IsA("Tool")then
                    for _,h in pairs(t:GetDescendants())do if h:IsA("Part")then
                        local ti=h:FindFirstChild("TouchInterest")or h:FindFirstChild("FireTouchInterest")
                        if ti then ti:Destroy()end
                    end end
                end end
                local bp=p:FindFirstChild("Backpack")
                if bp then for _,t in pairs(bp:GetChildren())do for _,h in pairs(t:GetDescendants())do if h:IsA("Part")then
                    local ti=h:FindFirstChild("TouchInterest")or h:FindFirstChild("FireTouchInterest")
                    if ti then ti:Destroy()end
                end end end end
            end
        end
    end
end)

local function startDesync()
    if dCon then return end
    dCon=RunService.RenderStepped:Connect(function()
        if (nT or voidActive)and rn and rn.desync then rn.desync(true)end
    end)
end

local function stopDesync()
    if dCon then dCon:Disconnect()dCon=nil end
    if rn and rn.desync then rn.desync(false)end
end

if CoreGui:FindFirstChild("ILuvAintMyCrib")then CoreGui.ILuvAintMyCrib:Destroy()end

local sg=Instance.new("ScreenGui")
sg.Name="ILuvAintMyCrib"
sg.Parent=CoreGui

local fr=Instance.new("Frame")
fr.Size=UDim2.new(0,280,0,170)
fr.Position=UDim2.new(0.5,-140,0.2,0)
fr.BackgroundColor3=Color3.fromRGB(18,18,18)
fr.BorderSizePixel=0
fr.Active=true
fr.Draggable=true
fr.Parent=sg
Instance.new("UICorner",fr).CornerRadius=UDim.new(0,10)

local tl=Instance.new("TextLabel")
tl.Size=UDim2.new(1,-30,0,22)
tl.BackgroundTransparency=1
tl.Text="ILuvAintMyCrib"
tl.TextColor3=Color3.fromRGB(255,255,255)
tl.Font=Enum.Font.SourceSansBold
tl.TextSize=16
tl.TextXAlignment=Enum.TextXAlignment.Left
tl.Parent=fr

local x=Instance.new("TextButton")
x.Size=UDim2.new(0,22,0,22)
x.Position=UDim2.new(1,-25,0,0)
x.BackgroundColor3=Color3.fromRGB(200,50,50)
x.Text="X"
x.TextColor3=Color3.fromRGB(255,255,255)
x.Font=Enum.Font.SourceSansBold
x.TextSize=16
x.Parent=fr
Instance.new("UICorner",x).CornerRadius=UDim.new(0,4)

local st=Instance.new("TextLabel")
st.Size=UDim2.new(1,0,0,18)
st.Position=UDim2.new(0,0,0,24)
st.BackgroundTransparency=1
st.Text=rn and"Shutdown"or"No Raknet"
st.TextColor3=Color3.fromRGB(200,200,200)
st.Font=Enum.Font.SourceSans
st.TextSize=14
st.Parent=fr

task.spawn(function()while true do task.wait(0.3)if st then
    local c=#getFTI()
    if voidActive then st.Text="🌊 VOID | REMOVED Firetouchinterest: "..c
    elseif nT then st.Text="⚡ DESYNC | "..c
    elseif iOn then st.Text="💀 INSTANT | "..c
    else st.Text="🔴 OFF | FTI: "..c end
end end end)

local b1=Instance.new("TextButton")
b1.Size=UDim2.new(0,100,0,30)
b1.Position=UDim2.new(0,10,0,60)
b1.BackgroundColor3=Color3.fromRGB(40,40,40)
b1.TextColor3=Color3.fromRGB(220,220,220)
b1.Text="⚡ Desync"
b1.Font=Enum.Font.SourceSansBold
b1.TextSize=14
b1.Parent=fr
Instance.new("UICorner",b1).CornerRadius=UDim.new(0,6)

local b2=Instance.new("TextButton")
b2.Size=UDim2.new(0,120,0,30)
b2.Position=UDim2.new(0,130,0,60)
b2.BackgroundColor3=Color3.fromRGB(70,40,170)
b2.TextColor3=Color3.fromRGB(220,220,220)
b2.Text="💀 Instant"
b2.Font=Enum.Font.SourceSansBold
b2.TextSize=14
b2.Parent=fr
Instance.new("UICorner",b2).CornerRadius=UDim.new(0,6)

local b3=Instance.new("TextButton")
b3.Size=UDim2.new(0,260,0,35)
b3.Position=UDim2.new(0,10,0,120)
b3.BackgroundColor3=Color3.fromRGB(100,30,100)
b3.TextColor3=Color3.fromRGB(255,255,255)
b3.Text="🌊 VOID DESYNC (Wait 10-12 sec for full desync - Sword games no wait)"
b3.Font=Enum.Font.SourceSansBold
b3.TextSize=11
b3.Parent=fr
Instance.new("UICorner",b3).CornerRadius=UDim.new(0,6)

local function normalCountdown()
    for i=12,1,-1 do if not nT then return end
        st.Text="⏰ "..i.."s | FTI: "..#getFTI()
        b1.Text="⏰ "..i.."s"
        task.wait(1)
    end
    if nT then st.Text="✅ Active | FTI: "..#getFTI() b1.Text="⚡ Desync" end
end

b1.MouseButton1Click:Connect(function()
    iOn=false
    if voidActive then voidActive=false Workspace.FallenPartsDestroyHeight=originalFallHeight end
    nT=not nT
    blockActive=nT
    if nT then
        startDesync()
        task.spawn(normalCountdown)
        removeFTI()
        b1.BackgroundColor3=Color3.fromRGB(80,80,80)
    else
        stopDesync()
        restoreFTI()
        st.Text="🔴 OFF | FTI: "..#getFTI()
        b1.BackgroundColor3=Color3.fromRGB(40,40,40)
        b1.Text="⚡ Desync"
    end
end)

b2.MouseButton1Click:Connect(function()
    nT=false
    if voidActive then voidActive=false Workspace.FallenPartsDestroyHeight=originalFallHeight end
    if dCon then stopDesync()end
    if iOn then
        iOn,blockActive=false,false
        if rn and rn.desync then rn.desync(false)end
        restoreFTI()
        st.Text="🔴 OFF | FTI: "..#getFTI()
        b2.BackgroundColor3=Color3.fromRGB(70,40,170)
        b2.Text="💀 Instant"
        return
    end
    iOn,blockActive=true,true
    removeFTI()
    st.Text="🔄 Resetting..."
    b2.BackgroundColor3=Color3.fromRGB(150,100,255)
    b2.Text="💀 ACTIVE"
    local c=lp.Character if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid")
    local r=c:FindFirstChild("HumanoidRootPart")
    if not(h and r)then return end
    local cf=r.CFrame
    h.Health=0
    local nc=lp.CharacterAdded:Wait()
    local nr=nc:WaitForChild("HumanoidRootPart")
    if rn and rn.desync then rn.desync(true)end
    task.wait(0.2)
    if cf then nr.CFrame=cf end
    st.Text="✅ Active | FTI: "..#getFTI()
end)

b3.MouseButton1Click:Connect(function()
    if voidActive then
        voidActive,blockActive=false,false
        if dCon then stopDesync()end
        restoreFTI()
        Workspace.FallenPartsDestroyHeight=originalFallHeight
        st.Text="🔴 OFF | FTI: "..#getFTI()
        b3.BackgroundColor3=Color3.fromRGB(100,30,100)
        b3.Text="🌊 VOID DESYNC (Wait 10-12 sec for full desync - Sword games no wait)"
        return
    end
    nT,iOn=false,false
    b1.BackgroundColor3=Color3.fromRGB(40,40,40)
    b1.Text="⚡ Desync"
    b2.BackgroundColor3=Color3.fromRGB(70,40,170)
    b2.Text="💀 Instant"
    voidActive,blockActive=true,true
    b3.BackgroundColor3=Color3.fromRGB(150,50,150)
    b3.Text="🌊 VOIDING..."
    st.Text="🌊 Void sequence..."
    local c=lp.Character if not c then voidActive=false blockActive=false b3.BackgroundColor3=Color3.fromRGB(100,30,100) b3.Text="🌊 VOID DESYNC (Wait 10-12 sec for full desync - Sword games no wait)" return end
    local r=c:FindFirstChild("HumanoidRootPart") if not r then voidActive=false blockActive=false b3.BackgroundColor3=Color3.fromRGB(100,30,100) b3.Text="🌊 VOID DESYNC (Wait 10-12 sec for full desync - Sword games no wait)" return end
    local og=r.CFrame
    Workspace.FallenPartsDestroyHeight=0/0
    st.Text="🌊 Height=0"
    task.wait(0.2)
    r.CFrame=CFrame.new(0,-1e99,0)
    st.Text="🌊 In void"
    task.wait(1)
    startDesync()
    removeFTI()
    st.Text="🌊 Desync ON"
    task.wait(1)
    r.CFrame=og
    b3.Text="🌊 VOID ON (click stop)"
    st.Text="🌊 VOID ACTIVE | FTI: "..#getFTI()
end)

x.MouseButton1Click:Connect(function()
    nT,iOn,voidActive,blockActive=false,false,false,false
    if dCon then dCon:Disconnect() dCon=nil end
    if rn and rn.desync then rn.desync(false)end
    restoreFTI()
    Workspace.FallenPartsDestroyHeight=originalFallHeight
    sg:Destroy()
end)
wait(1)
local c=game:GetService("TextChatService").TextChannels.RBXGeneral

for _,m in ipairs({
    "AintMYcrib BLAH BLAH"
}) do
    c:SendAsync(m)
    task.wait()
end
