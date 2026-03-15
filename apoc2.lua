local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local DIST_DOT = 1000
local DIST_MAX = 5000

local espData = {}
local charactersFolder = workspace:FindFirstChild("Characters")

local function getSquadMembers()
    local members = {}
    local playerList = localPlayer.PlayerGui:FindFirstChild("PlayerList", true)
    if not playerList then return members end
    local squadList = playerList:FindFirstChild("SquadList", true)
    if not squadList then return members end
    for _, obj in ipairs(squadList:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Name == "NameLabel" and obj.Text ~= "" then
            members[obj.Text] = true
        end
    end
    return members
end

local function isVisible(character)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    local origin = camera.CFrame.Position
    local direction = rootPart.Position - origin
    local rayParams = RaycastParams.new()
    local filter = {character}
    if localPlayer.Character then table.insert(filter, localPlayer.Character) end
    if charactersFolder then
        for _, char in ipairs(charactersFolder:GetChildren()) do
            table.insert(filter, char)
        end
    end
    rayParams.FilterDescendantsInstances = filter
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, direction, rayParams)
    return result == nil
end

local function getEquipped(character)
    local equipped = character:FindFirstChild("Equipped")
    if equipped then
        for _, obj in ipairs(equipped:GetChildren()) do
            if obj:IsA("Model") then return obj.Name end
        end
    end
    local tool = character:FindFirstChildWhichIsA("Tool")
    if tool then return tool.Name end
    return "No Weapon"
end

local function removeESP(player)
    if espData[player] then
        if espData[player].highlight then espData[player].highlight:Destroy() end
        if espData[player].billboardBottom then espData[player].billboardBottom:Destroy() end
        if espData[player].billboardDot then espData[player].billboardDot:Destroy() end
        espData[player] = nil
    end
end

local watermark = Drawing.new("Text")
watermark.Text = "script made by bailando / dc: iszymii"
watermark.Size = 25
watermark.Color = Color3.fromRGB(200, 200, 200)
watermark.Outline = true
watermark.OutlineColor = Color3.fromRGB(0, 0, 0)
watermark.Font = 4
watermark.Visible = true
watermark.Position = Vector2.new(10, camera.ViewportSize.Y - 50)

local function addESP(player)
    if player == localPlayer then return end

    local function setupESP(character)
        removeESP(player)

        local humanoid = character:WaitForChild("Humanoid", 5)
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        if not humanoid or not rootPart then return end

        local highlight = Instance.new("Highlight")
        highlight.FillTransparency = 0.4
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = Color3.fromRGB(220, 40, 40)
        highlight.OutlineColor = Color3.fromRGB(255, 60, 60)
        highlight.Adornee = character
        highlight.Parent = character

        local billboardBottom = Instance.new("BillboardGui")
        billboardBottom.AlwaysOnTop = true
        billboardBottom.StudsOffsetWorldSpace = Vector3.new(0, -7.5, 0)
        billboardBottom.Size = UDim2.new(0, 100, 0, 30)
        billboardBottom.Adornee = rootPart
        billboardBottom.Parent = rootPart
        billboardBottom.Enabled = false

        local labelDist = Instance.new("TextLabel")
        labelDist.Size = UDim2.new(1, 0, 0.5, 0)
        labelDist.Position = UDim2.new(0, 0, 0, 0)
        labelDist.BackgroundTransparency = 1
        labelDist.TextColor3 = Color3.fromRGB(220, 220, 220)
        labelDist.TextStrokeTransparency = 0.3
        labelDist.Font = Enum.Font.GothamMedium
        labelDist.TextSize = 9
        labelDist.Text = "0m"
        labelDist.Parent = billboardBottom

        local labelItem = Instance.new("TextLabel")
        labelItem.Size = UDim2.new(1, 0, 0.5, 0)
        labelItem.Position = UDim2.new(0, 0, 0.5, 0)
        labelItem.BackgroundTransparency = 1
        labelItem.TextColor3 = Color3.fromRGB(255, 200, 60)
        labelItem.TextStrokeTransparency = 0.3
        labelItem.Font = Enum.Font.GothamMedium
        labelItem.TextSize = 9
        labelItem.Text = "No Weapon"
        labelItem.Parent = billboardBottom

        local billboardDot = Instance.new("BillboardGui")
        billboardDot.AlwaysOnTop = true
        billboardDot.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
        billboardDot.Size = UDim2.new(0, 50, 0, 36)
        billboardDot.Adornee = rootPart
        billboardDot.Parent = rootPart
        billboardDot.Enabled = false

        local labelDistDot = Instance.new("TextLabel")
        labelDistDot.Size = UDim2.new(1, 0, 0, 10)
        labelDistDot.Position = UDim2.new(0, 0, 0, 0)
        labelDistDot.BackgroundTransparency = 1
        labelDistDot.TextColor3 = Color3.fromRGB(180, 180, 180)
        labelDistDot.TextStrokeTransparency = 0.4
        labelDistDot.Font = Enum.Font.Gotham
        labelDistDot.TextSize = 8
        labelDistDot.Text = "0m"
        labelDistDot.Parent = billboardDot

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 6, 0, 6)
        dot.Position = UDim2.new(0.5, -3, 0, 13)
        dot.BackgroundColor3 = Color3.fromRGB(0, 210, 80)
        dot.BorderSizePixel = 0
        dot.Parent = billboardDot

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot

        local labelName = Instance.new("TextLabel")
        labelName.Size = UDim2.new(1, 0, 0, 10)
        labelName.Position = UDim2.new(0, 0, 0, 23)
        labelName.BackgroundTransparency = 1
        labelName.TextColor3 = Color3.fromRGB(220, 220, 220)
        labelName.TextStrokeTransparency = 0.4
        labelName.Font = Enum.Font.Gotham
        labelName.TextSize = 8
        labelName.Text = player.Name
        labelName.Parent = billboardDot

        espData[player] = {
            highlight = highlight,
            billboardBottom = billboardBottom,
            billboardDot = billboardDot,
            dot = dot,
            labelDist = labelDist,
            labelItem = labelItem,
            labelDistDot = labelDistDot,
            rootPart = rootPart,
            humanoid = humanoid,
            character = character,
        }

        humanoid.Died:Connect(function()
            removeESP(player)
        end)
    end

    local character = player.Character
    if not character then
        if charactersFolder then
            character = charactersFolder:FindFirstChild(player.Name)
        end
    end
    if character then setupESP(character) end

    player.CharacterAdded:Connect(function(c) setupESP(c) end)

    if charactersFolder then
        charactersFolder.ChildAdded:Connect(function(child)
            if child.Name == player.Name then setupESP(child) end
        end)
    end
end

-- Odświeżaj squad co 2 sekundy
local squadMembers = {}
task.spawn(function()
    while true do
        squadMembers = getSquadMembers()
        task.wait(2)
    end
end)

RunService.RenderStepped:Connect(function()
    watermark.Position = Vector2.new(10, camera.ViewportSize.Y - 50)

    for player, data in pairs(espData) do
        if not data.character or not data.character.Parent then
            removeESP(player)
            continue
        end

        local localChar = localPlayer.Character
        if not localChar and charactersFolder then
            for _, char in ipairs(charactersFolder:GetChildren()) do
                if char.Name == localPlayer.Name then
                    localChar = char
                    break
                end
            end
        end

        local dist = 9999
        if localChar and localChar:FindFirstChild("HumanoidRootPart") then
            dist = math.floor((data.rootPart.Position - localChar.HumanoidRootPart.Position).Magnitude)
        end

        if dist > DIST_MAX then
            data.highlight.Enabled = false
            data.billboardBottom.Enabled = false
            data.billboardDot.Enabled = false
            continue
        end

        local isSquadMate = squadMembers[player.Name] == true

        local dotMode = dist >= DIST_DOT
        data.highlight.Enabled = not dotMode
        data.billboardBottom.Enabled = not dotMode
        data.billboardDot.Enabled = dotMode

        if dotMode then
            local t = math.clamp((dist - 1000) / 4000, 0, 1)
            local r = math.floor((1 - t) * 220)
            local g = math.floor(t * 210)
            -- Kropka niebieska dla squadmate
            if isSquadMate then
                data.dot.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
            else
                data.dot.BackgroundColor3 = Color3.fromRGB(r, g, 0)
            end
            data.labelDistDot.Text = dist .. "m"
        else
            local scale = math.clamp(40 / math.max(dist, 1), 0.4, 1.8)
            data.billboardBottom.Size = UDim2.new(0, math.floor(100 * scale), 0, math.floor(30 * scale))
            data.labelDist.TextSize = math.clamp(math.floor(9 * scale), 7, 13)
            data.labelItem.TextSize = math.clamp(math.floor(9 * scale), 7, 13)
            data.labelDist.Text = dist .. "m"
            data.labelItem.Text = getEquipped(data.character)

            if isSquadMate then
                -- Squadmate zawsze niebieski
                data.highlight.FillColor = Color3.fromRGB(0, 100, 255)
                data.highlight.OutlineColor = Color3.fromRGB(50, 150, 255)
            elseif isVisible(data.character) then
                data.highlight.FillColor = Color3.fromRGB(0, 210, 80)
                data.highlight.OutlineColor = Color3.fromRGB(0, 255, 100)
            else
                data.highlight.FillColor = Color3.fromRGB(220, 40, 40)
                data.highlight.OutlineColor = Color3.fromRGB(255, 60, 60)
            end
        end
    end
end)

Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(removeESP)

for _, player in ipairs(Players:GetPlayers()) do
    addESP(player)
end

print("ESP active!")
