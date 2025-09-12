local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ====== File Replay ======
local SAVE_FILE = "Replays.json"
local hasFileAPI = (writefile and readfile and isfile) and true or false

local function safeWrite(data)
    if hasFileAPI then writefile(SAVE_FILE, HttpService:JSONEncode(data)) end
end

local function safeRead()
    if hasFileAPI and isfile(SAVE_FILE) then
        local ok, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(SAVE_FILE))
        end)
        if ok and decoded then return decoded end
    end
    return {}
end

local savedReplays = safeRead()

-- ====== UI Helper ======
local function styleFrame(frame, radius, color)
    frame.BackgroundColor3 = color
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, radius)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(80,80,80)
end

local function styleButton(btn, color)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0,8)
end

local function addShadow(frame)
    local shadow = Instance.new("ImageLabel", frame)
    shadow.ZIndex = 0
    shadow.Size = UDim2.new(1,30,1,30)
    shadow.Position = UDim2.new(0,-15,0,-15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5028857472"
    shadow.ImageColor3 = Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = 0.5
end

-- ====== Main Frame ======
local guiName = "MountaineerRecorderModern"
local oldGui = playerGui:FindFirstChild(guiName)
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,380,0,380)
mainFrame.Position = UDim2.new(0.5,-190,0.25,0)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
styleFrame(mainFrame, 12, Color3.fromRGB(35,35,40))
addShadow(mainFrame)

-- ====== Header ======
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1,0,0,40)
styleFrame(header, 12, Color3.fromRGB(45,45,55))

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-90,1,0)
title.Position = UDim2.new(0,15,0,0)
title.BackgroundTransparency = 1
title.Text = "🏔 PS SCRIPT AUTO WALK"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0,35,0,35)
closeBtn.Position = UDim2.new(1,-50,0,3)
closeBtn.Text = "✖"
styleButton(closeBtn, Color3.fromRGB(200,70,70))

local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.new(0,35,0,35)
minimizeBtn.Position = UDim2.new(1,-95,0,3)
minimizeBtn.Text = "—"
styleButton(minimizeBtn, Color3.fromRGB(80,80,80))

-- ====== Bubble Dock ======
local bubbleBtn = Instance.new("TextButton")
bubbleBtn.Size = UDim2.new(0,50,0,50)
bubbleBtn.BackgroundColor3 = Color3.fromRGB(70,130,180)
bubbleBtn.Text = "🏔"
bubbleBtn.Font = Enum.Font.GothamBold
bubbleBtn.TextSize = 20
bubbleBtn.TextColor3 = Color3.new(1,1,1)
bubbleBtn.Visible = false
bubbleBtn.Parent = screenGui
styleFrame(bubbleBtn, 25, Color3.fromRGB(70,130,180))

local isBubble = false
local dragging, dragStart, startPos
local lastBubblePos = UDim2.new(0, 15, 0.4, 0)

local function toBubble()
    isBubble = true
    mainFrame.Visible = false
    bubbleBtn.Visible = true
    bubbleBtn.Position = lastBubblePos
end

local function fromBubble()
    isBubble = false
    bubbleBtn.Visible = false
    mainFrame.Visible = true
end

bubbleBtn.MouseButton1Click:Connect(fromBubble)

bubbleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = bubbleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                lastBubblePos = bubbleBtn.Position
            end
        end)
    end
end)

bubbleBtn.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                     input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        bubbleBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

minimizeBtn.MouseButton1Click:Connect(function()
    if isBubble then
        fromBubble()
    else
        lastBubblePos = bubbleBtn.Position
        toBubble()
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ====== Content ======
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1,0,1,-40)
contentFrame.Position = UDim2.new(0,0,0,40)
styleFrame(contentFrame, 12, Color3.fromRGB(45,45,55))

-- Tombol utama
local recordBtn = Instance.new("TextButton", contentFrame)
recordBtn.Size = UDim2.new(0,120,0,35)
recordBtn.Position = UDim2.new(0,15,0,15)
recordBtn.Text = "⏺ Record"
styleButton(recordBtn, Color3.fromRGB(70,130,180))

local pauseRecordBtn = Instance.new("TextButton", contentFrame)
pauseRecordBtn.Size = UDim2.new(0,120,0,35)
pauseRecordBtn.Position = UDim2.new(0,150,0,15)
pauseRecordBtn.Text = "⏸ Pause Rec"
styleButton(pauseRecordBtn, Color3.fromRGB(255,215,0))
pauseRecordBtn.Visible = false

local saveBtn = Instance.new("TextButton", contentFrame)
saveBtn.Size = UDim2.new(0,120,0,35)
saveBtn.Position = UDim2.new(0,250,0,15)
saveBtn.Text = "💾 Save Replay"
styleButton(saveBtn, Color3.fromRGB(34,139,34))

local loadBtn = Instance.new("TextButton", contentFrame)
loadBtn.Size = UDim2.new(0,120,0,35)
loadBtn.Position = UDim2.new(0,15,0,60)
loadBtn.Text = "📂 Load Path"
styleButton(loadBtn, Color3.fromRGB(100,149,237))

local mergeBtn = Instance.new("TextButton", contentFrame)
mergeBtn.Size = UDim2.new(0,150,0,35)
mergeBtn.Position = UDim2.new(0,150,0,60)
mergeBtn.Text = "🔗 Merge & Play"
styleButton(mergeBtn, Color3.fromRGB(255,140,0))

local autoQueueBtn = Instance.new("TextButton", contentFrame)
autoQueueBtn.Size = UDim2.new(0,150,0,35)
autoQueueBtn.Position = UDim2.new(0,150,0,105)
autoQueueBtn.Text = "▶ Auto Respawn"
styleButton(autoQueueBtn, Color3.fromRGB(123,104,238))

-- ====== Speed Control ======
local speedLabel = Instance.new("TextLabel", contentFrame)
speedLabel.Size = UDim2.new(0,50,0,30)
speedLabel.Position = UDim2.new(0,15,0,105)
speedLabel.Text = "Speed:"
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedBox = Instance.new("TextBox", contentFrame)
speedBox.Size = UDim2.new(0,50,0,30)
speedBox.Position = UDim2.new(0,70,0,105)
speedBox.Text = "1"
speedBox.ClearTextOnFocus = false
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.BackgroundColor3 = Color3.fromRGB(80,80,90)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 14
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0,6)

-- ====== Replay List ======
local replayList = Instance.new("ScrollingFrame", contentFrame)
replayList.Size = UDim2.new(1,-30,1,-190)
replayList.Position = UDim2.new(0,15,0,145)
replayList.CanvasSize = UDim2.new(0,0,0,0)
replayList.ScrollBarThickness = 6
styleFrame(replayList, 10, Color3.fromRGB(55,55,65))

local listLayout = Instance.new("UIListLayout", replayList)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0,5)

-- ====== Replay Logic ======
local character, humanoidRootPart
local isRecording, isPaused, isPausedRecord = false, false, false
local recordData = {}
local currentReplayToken = nil
local autoQueueRunning = false

local function onCharacterAdded(char)
    character = char
    humanoidRootPart = char:WaitForChild("HumanoidRootPart",10)
end
player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character) end

local function startRecording()
    recordData = {}
    isRecording = true
    isPausedRecord = false
    pauseRecordBtn.Visible = true
end

local function stopRecording()
    isRecording = false
    isPausedRecord = false
    pauseRecordBtn.Visible = false
end

RunService.Heartbeat:Connect(function()
    if isRecording and not isPausedRecord and humanoidRootPart and humanoidRootPart.Parent then
        local cf = humanoidRootPart.CFrame
        table.insert(recordData, {
            Position = {cf.Position.X, cf.Position.Y, cf.Position.Z},
            LookVector = {cf.LookVector.X, cf.LookVector.Y, cf.LookVector.Z},
            UpVector = {cf.UpVector.X, cf.UpVector.Y, cf.UpVector.Z}
        })
    end
end)

local function playReplay(data)
    local token = {}
    currentReplayToken = token
    isPaused = false
    local speed = tonumber(speedBox.Text) or 1
    if speed <= 0 then speed = 1 end
    local index,totalFrames = 1,#data

    while index <= totalFrames do
        if currentReplayToken ~= token then break end
        while isPaused and currentReplayToken == token do RunService.Heartbeat:Wait() end
        if humanoidRootPart and humanoidRootPart.Parent and currentReplayToken == token then
            local frame = data[math.floor(index)]
            humanoidRootPart.CFrame = CFrame.lookAt(
                Vector3.new(frame.Position[1],frame.Position[2],frame.Position[3]),
                Vector3.new(frame.Position[1]+frame.LookVector[1], frame.Position[2]+frame.LookVector[2], frame.Position[3]+frame.LookVector[3]),
                Vector3.new(frame.UpVector[1], frame.UpVector[2], frame.UpVector[3])
            )
        end
        index = index + speed
        RunService.Heartbeat:Wait()
    end
    if currentReplayToken == token then currentReplayToken = nil end
end

local function playQueue()
    if autoQueueRunning then autoQueueRunning=false autoQueueBtn.Text="▶ Auto Queue" return end
    autoQueueRunning=true autoQueueBtn.Text="⏹ Stop Queue"
    task.spawn(function()
        while autoQueueRunning do
            local queue={}
            for _,r in ipairs(savedReplays) do if r.Selected then table.insert(queue,r.Frames) end end
            if #queue==0 then autoQueueRunning=false autoQueueBtn.Text="▶ Auto Queue" return end
            for _,frames in ipairs(queue) do
                local finished=false
                task.spawn(function() playReplay(frames) finished=true end)
                while not finished and currentReplayToken do RunService.Heartbeat:Wait() end
                task.wait(0.5)
            end
            if character and character:FindFirstChild("Humanoid") then character.Humanoid.Health=0 end
            player.CharacterAdded:Wait() onCharacterAdded(player.Character) task.wait(1)
        end
    end)
end

function addReplayItem(saved,index)
    local item=Instance.new("Frame",replayList)
    item.Size=UDim2.new(1,-10,0,45) styleFrame(item,8,Color3.fromRGB(65,65,75))
    item.LayoutOrder=index saved.Selected=false
    local nameBox=Instance.new("TextBox",item)
    nameBox.Size=UDim2.new(0.35,0,1,0) nameBox.Text=saved.Name
    nameBox.TextColor3=Color3.new(1,1,1) nameBox.BackgroundColor3=Color3.fromRGB(90,90,100)
    nameBox.Font=Enum.Font.Gotham nameBox.TextSize=14 nameBox.ClearTextOnFocus=false
    Instance.new("UICorner",nameBox).CornerRadius=UDim.new(0,6)
    nameBox.FocusLost:Connect(function() saved.Name=nameBox.Text end)

    local function makeBtn(txt,pos,color,cb)
        local b=Instance.new("TextButton",item)
        b.Size=UDim2.new(0,35,0,30) b.Position=pos b.Text=txt styleButton(b,color)
        b.MouseButton1Click:Connect(cb) return b end

    makeBtn("▶",UDim2.new(0.4,0,0.5,-15),Color3.fromRGB(70,130,180),function() task.spawn(function() playReplay(saved.Frames) end) end)
    makeBtn("⏸",UDim2.new(0.48,0,0.5,-15),Color3.fromRGB(255,215,0),function() isPaused=not isPaused end)
    makeBtn("🗑",UDim2.new(0.56,0,0.5,-15),Color3.fromRGB(220,20,60),function() table.remove(savedReplays,index) refreshReplayList() end)
    makeBtn("💾",UDim2.new(0.64,0,0.5,-15),Color3.fromRGB(34,139,34),function() safeWrite(savedReplays) end)

    local selectCheck=Instance.new("TextButton",item)
    selectCheck.Size=UDim2.new(0,25,0,25) selectCheck.Position=UDim2.new(0.72,0,0.5,-12)
    selectCheck.Text="☐" styleButton(selectCheck,Color3.fromRGB(100,100,100))
    selectCheck.MouseButton1Click:Connect(function() saved.Selected=not saved.Selected selectCheck.Text=saved.Selected and "☑" or "☐" end)

    makeBtn("⬆",UDim2.new(0.82,0,0.5,-12),Color3.fromRGB(100,149,237),function()
        if index>1 then savedReplays[index],savedReplays[index-1]=savedReplays[index-1],savedReplays[index] refreshReplayList() end end)
    makeBtn("⬇",UDim2.new(0.9,0,0.5,-12),Color3.fromRGB(100,149,237),function()
        if index<#savedReplays then savedReplays[index],savedReplays[index+1]=savedReplays[index+1],savedReplays[index] refreshReplayList() end end)
end

function refreshReplayList()
    for _,c in ipairs(replayList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for i,r in ipairs(savedReplays) do addReplayItem(r,i) end
    replayList.CanvasSize=UDim2.new(0,0,0,#savedReplays*50)
end
refreshReplayList()

-- Tombol fungsi utama
recordBtn.MouseButton1Click:Connect(function() if isRecording then stopRecording() recordBtn.Text="⏺ Record" else startRecording() recordBtn.Text="⏹ Stop Rec" end end)
pauseRecordBtn.MouseButton1Click:Connect(function() isPausedRecord=not isPausedRecord pauseRecordBtn.Text=isPausedRecord and "▶ Resume Rec" or "⏸ Pause Rec" end)
saveBtn.MouseButton1Click:Connect(function()
    if #recordData>0 then
        table.insert(savedReplays,{Name="Replay"..(#savedReplays+1),Frames=recordData,Selected=false})
        refreshReplayList()
        safeWrite(savedReplays)
    end
end)
mergeBtn.MouseButton1Click:Connect(function() task.spawn(function() playQueue() end) end)
autoQueueBtn.MouseButton1Click:Connect(playQueue)

-- ====== ====== AUTO WALK SCRIPT ======
local autoWalking = false
local bodyVelocity = nil
local awCharacter, awHumanoid, awHRP
local speedAW = 16
local walkStepName = "AutoWalkStep"

local function onCharacterAddedAW(char)
    awCharacter = char
    awHumanoid = char:WaitForChild("Humanoid",10)
    awHumanoid.WalkSpeed = 16
    awHRP = char:WaitForChild("HumanoidRootPart",10)
end
player.CharacterAdded:Connect(onCharacterAddedAW)
if player.Character then onCharacterAddedAW(player.Character) end

-- Tombol Auto Walk bulat di kanan
local autoWalkBtn = Instance.new("TextButton", contentFrame)
autoWalkBtn.Size = UDim2.new(0,60,0,60)
autoWalkBtn.Position = UDim2.new(0,310,0,70)
autoWalkBtn.Text = "🏃"
autoWalkBtn.Font = Enum.Font.GothamBold
autoWalkBtn.TextSize = 28
autoWalkBtn.BackgroundColor3 = Color3.fromRGB(70,130,180)
autoWalkBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", autoWalkBtn).CornerRadius = UDim.new(0,30)

local glow = Instance.new("UIStroke", autoWalkBtn)
glow.Thickness = 3
glow.Color = Color3.fromRGB(255,255,0)
glow.Transparency = 1

local function clampPosition(pos)
    local screenSize = workspace.CurrentCamera.ViewportSize
    local x = math.clamp(pos.X.Offset, 0, screenSize.X - autoWalkBtn.AbsoluteSize.X)
    local y = math.clamp(pos.Y.Offset, 0, screenSize.Y - autoWalkBtn.AbsoluteSize.Y)
    return UDim2.new(pos.X.Scale, x, pos.Y.Scale, y)
end

local function toggleAutoWalk()
    autoWalking = not autoWalking
    glow.Transparency = autoWalking and 0 or 1

    if autoWalking then
        if awHRP and not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(1e5,0,1e5)
            bodyVelocity.Velocity = Vector3.new(0,0,0)
            bodyVelocity.Parent = awHRP
        end

        RunService:BindToRenderStep(walkStepName, Enum.RenderPriority.Character.Value, function(dt)
            if awHRP and awHumanoid then
                local dir = Vector3.new(awHRP.CFrame.LookVector.X,0,awHRP.CFrame.LookVector.Z)
                if dir.Magnitude > 0 then
                    bodyVelocity.Velocity = dir.Unit * speedAW
                    awHumanoid:Move(dir.Unit)
                end
            end
        end)
    else
        RunService:UnbindFromRenderStep(walkStepName)
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
        if awHumanoid then
            awHumanoid:Move(Vector3.new(0,0,0))
        end
    end
end
autoWalkBtn.MouseButton1Click:Connect(toggleAutoWalk)

-- Drag tombol Auto Walk
local draggingAW, dragStartAW, startPosAW = false, nil, nil
autoWalkBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        draggingAW = true
        dragStartAW = input.Position
        startPosAW = autoWalkBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingAW=false end
        end)
    end
end)
autoWalkBtn.InputChanged:Connect(function(input)
    if draggingAW and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-dragStartAW
        autoWalkBtn.Position = clampPosition(
            UDim2.new(
                startPosAW.X.Scale,startPosAW.X.Offset+delta.X,
                startPosAW.Y.Scale,startPosAW.Y.Offset+delta.Y
            )
        )
    end
end)
