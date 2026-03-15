local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local DIST_DOT = 1000
local DIST_MAX = 5000

local espData = {}
local charactersFolder = workspace:FindFirstChild("Characters")

local function czyWidoczny(postac)
    local rootPart = postac:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    local origin = camera.CFrame.Position
    local direction = rootPart.Position - origin
    local rayParams = RaycastParams.new()
    local filter = {postac}
    if localPlayer.Character then table.insert(filter, localPlayer.Character) end
    if charactersFolder then
        local localChar = charactersFolder:FindFirstChild(localPlayer.Name)
        if localChar then table.insert(filter, localChar) end
    end
    rayParams.FilterDescendantsInstances = filter
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, direction, rayParams)
    return result == nil
end

local function getEquipped(postac)
    local equipped = postac:FindFirstChild("Equipped")
    if equipped then
        for _, obj in ipairs(equipped:GetChildren()) do
            if obj:IsA("Model") then return obj.Name end
        end
    end
    local tool = postac:FindFirstChildWhichIsA("Tool")
    if tool then return tool.Name end
    return "No Weapon"
end

local function usunESP(gracz)
    if espData[gracz] then
        if espData[gracz].highlight then espData[gracz].highlight:Destroy() end
        if espData[gracz].billboardBottom then espData[gracz].billboardBottom:Destroy() end
        if espData[gracz].billboardDot then espData[gracz].billboardDot:Destroy() end
        espData[gracz] = nil
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

local function dodajESP(gracz)
    if gracz == localPlayer then return end

    local function setupESP(postac)
        usunESP(gracz)

        local humanoid = postac:WaitForChild("Humanoid", 5)
        local rootPart = postac:WaitForChild("HumanoidRootPart", 5)
        if not humanoid or not rootPart then return end

        local highlight = Instance.new("Highlight")
        highlight.FillTransparency = 0.4
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = Color3.fromRGB(220, 40, 40)
        highlight.OutlineColor = Color3.fromRGB(255, 60, 60)
        highlight.Adornee = postac
        highlight.Parent = postac

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

        local labelNazwa = Instance.new("TextLabel")
        labelNazwa.Size = UDim2.new(1, 0, 0, 10)
        labelNazwa.Position = UDim2.new(0, 0, 0, 23)
        labelNazwa.BackgroundTransparency = 1
        labelNazwa.TextColor3 = Color3.fromRGB(220, 220, 220)
        labelNazwa.TextStrokeTransparency = 0.4
        labelNazwa.Font = Enum.Font.Gotham
        labelNazwa.TextSize = 8
        labelNazwa.Text = gracz.Name
        labelNazwa.Parent = billboardDot

        espData[gracz] = {
            highlight = highlight,
            billboardBottom = billboardBottom,
            billboardDot = billboardDot,
            dot = dot,
            labelDist = labelDist,
            labelItem = labelItem,
            labelDistDot = labelDistDot,
            rootPart = rootPart,
            humanoid = humanoid,
            postac = postac,
        }

        humanoid.Died:Connect(function()
            usunESP(gracz)
        end)
    end

    local postac = gracz.Character
    if not postac then
        if charactersFolder then
            postac = charactersFolder:FindFirstChild(gracz.Name)
        end
    end
    if postac then setupESP(postac) end

    gracz.CharacterAdded:Connect(function(p) setupESP(p) end)

    if charactersFolder then
        charactersFolder.ChildAdded:Connect(function(child)
            if child.Name == gracz.Name then setupESP(child) end
        end)
    end
end

RunService.RenderStepped:Connect(function()
    watermark.Position = Vector2.new(10, camera.ViewportSize.Y - 50)

    for gracz, dane in pairs(espData) do
        if not dane.postac or not dane.postac.Parent then
            usunESP(gracz)
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
            dist = math.floor((dane.rootPart.Position - localChar.HumanoidRootPart.Position).Magnitude)
        end

        if dist > DIST_MAX then
            dane.highlight.Enabled = false
            dane.billboardBottom.Enabled = false
            dane.billboardDot.Enabled = false
            continue
        end

        local trybKropki = dist >= DIST_DOT
        dane.highlight.Enabled = not trybKropki
        dane.billboardBottom.Enabled = not trybKropki
        dane.billboardDot.Enabled = trybKropki

        if trybKropki then
            local t = math.clamp((dist - 1000) / 4000, 0, 1)
            local r = math.floor((1 - t) * 220)
            local g = math.floor(t * 210)
            dane.dot.BackgroundColor3 = Color3.fromRGB(r, g, 0)
            dane.labelDistDot.Text = dist .. "m"
        else
            local scale = math.clamp(40 / math.max(dist, 1), 0.4, 1.8)
            dane.billboardBottom.Size = UDim2.new(0, math.floor(100 * scale), 0, math.floor(30 * scale))
            dane.labelDist.TextSize = math.clamp(math.floor(9 * scale), 7, 13)
            dane.labelItem.TextSize = math.clamp(math.floor(9 * scale), 7, 13)
            dane.labelDist.Text = dist .. "m"
            dane.labelItem.Text = getEquipped(dane.postac)

            if czyWidoczny(dane.postac) then
                dane.highlight.FillColor = Color3.fromRGB(0, 210, 80)
                dane.highlight.OutlineColor = Color3.fromRGB(0, 255, 100)
            else
                dane.highlight.FillColor = Color3.fromRGB(220, 40, 40)
                dane.highlight.OutlineColor = Color3.fromRGB(255, 60, 60)
            end
        end
    end
end)

Players.PlayerAdded:Connect(dodajESP)
Players.PlayerRemoving:Connect(usunESP)

for _, gracz in ipairs(Players:GetPlayers()) do
    dodajESP(gracz)
end