--[[
    ============================================
    ANIMATION WHEEL PREMIUM v2 - ROBLOX
    Sistema profissional de rodinha de animações
    ============================================
    
    Cole isto no Command Bar do Roblox e aperte Enter
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character
if not character then
    character = player.CharacterAdded:Wait()
end

local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- CONFIGURAÇÃO
local CONFIG = {
    KEYBIND = Enum.KeyCode.G,
    RADIUS = 160,
    CENTER_SIZE = 100,
    ITEM_SIZE = 70,
    ITEM_SIZE_HOVER = 85,
    SOUND_VOLUME = 0.5,

    ITEMS = {
        { Name = "Radical", AssetId = 507770818, Speed = 1, Icon = "🔥" },
        { Name = "Dança", AssetId = 507771019, Speed = 1, Icon = "💃" },
        { Name = "Saltar", AssetId = 507777826, Speed = 1, Icon = "⬆️" },
        { Name = "Wave", AssetId = 507766666, Speed = 1, Icon = "👋" },
        { Name = "Rindo", AssetId = 507770818, Speed = 1, Icon = "😂" },
        { Name = "Vitória", AssetId = 507771837, Speed = 1, Icon = "🏆" },
        { Name = "Correr", AssetId = 507777623, Speed = 1, Icon = "🏃" },
        { Name = "Confusão", AssetId = 507770544, Speed = 1, Icon = "😕" },
    },

    SOUNDS = {
        OPEN = 3540595510,
        HOVER = 3540595500,
        SELECT = 3540595470,
    }
}

-- VARIÁVEIS GLOBAIS
local wheelGui = nil
local isOpen = false
local selectedIndex = 1
local currentTrack = nil
local trackCache = {}
local itemButtons = {}

-- FUNÇÃO: Criar Som
local function playSound(soundId, volume)
    if not soundId or soundId == 0 then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound.Volume = volume or CONFIG.SOUND_VOLUME
    sound.Parent = workspace
    
    game:GetService("Debris"):AddItem(sound, 2)
    sound:Play()
end

-- FUNÇÃO: Parar Animação Atual
local function stopCurrentAnimation()
    if currentTrack and currentTrack.IsPlaying then
        currentTrack:Stop(0.2)
    end
    currentTrack = nil
end

-- FUNÇÃO: Tocar Animação
local function playAnimation(index)
    local item = CONFIG.ITEMS[index]
    if not item or not item.AssetId or item.AssetId == 0 then
        warn("Animação inválida ou não configurada para " .. item.Name)
        return
    end

    stopCurrentAnimation()

    local track = trackCache[item.Name]
    if not track then
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://" .. tostring(item.AssetId)
        track = humanoid:LoadAnimation(animation)
        trackCache[item.Name] = track
    end

    if track then
        track:Play(item.Speed or 1)
        currentTrack = track
        playSound(CONFIG.SOUNDS.SELECT, CONFIG.SOUND_VOLUME + 0.2)
    end
end

-- FUNÇÃO: Calcular Posição do Item
local function getItemPosition(index)
    local count = #CONFIG.ITEMS
    local angle = -math.pi / 2 + (math.pi * 2 * (index - 1) / count)
    local x = math.cos(angle) * CONFIG.RADIUS
    local y = math.sin(angle) * CONFIG.RADIUS
    return x, y
end

-- FUNÇÃO: Criar UI da Roda
local function createWheelUI()
    if wheelGui then
        wheelGui:Destroy()
    end

    wheelGui = Instance.new("ScreenGui")
    wheelGui.Name = "AnimationWheelPremium"
    wheelGui.ResetOnSpawn = false
    wheelGui.IgnoreGuiInset = true
    wheelGui.Enabled = false
    wheelGui.Parent = player:WaitForChild("PlayerGui")

    -- OVERLAY
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    overlay.BackgroundTransparency = 1
    overlay.ZIndex = 1
    overlay.Parent = wheelGui

    local overlayClose = Instance.new("TextButton")
    overlayClose.Size = UDim2.new(1, 0, 1, 0)
    overlayClose.BackgroundTransparency = 1
    overlayClose.Text = ""
    overlayClose.ZIndex = 1
    overlayClose.Parent = overlay
    overlayClose.MouseButton1Click:Connect(function()
        if isOpen then
            closeWheel()
        end
    end)

    -- CONTAINER PRINCIPAL
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    container.Size = UDim2.new(0, CONFIG.RADIUS * 2 + 200, 0, CONFIG.RADIUS * 2 + 200)
    container.BackgroundTransparency = 1
    container.ZIndex = 2
    container.Parent = overlay

    -- CENTRO
    local center = Instance.new("Frame")
    center.Name = "Center"
    center.AnchorPoint = Vector2.new(0.5, 0.5)
    center.Position = UDim2.new(0.5, 0, 0.5, 0)
    center.Size = UDim2.new(0, CONFIG.CENTER_SIZE, 0, CONFIG.CENTER_SIZE)
    center.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    center.BorderSizePixel = 0
    center.ZIndex = 3
    center.Parent = container

    local centerCorner = Instance.new("UICorner")
    centerCorner.CornerRadius = UDim.new(1, 0)
    centerCorner.Parent = center

    local centerStroke = Instance.new("UIStroke")
    centerStroke.Color = Color3.fromRGB(255, 214, 102)
    centerStroke.Thickness = 2.5
    centerStroke.Parent = center

    local centerLabel = Instance.new("TextLabel")
    centerLabel.Size = UDim2.new(1, 0, 1, 0)
    centerLabel.BackgroundTransparency = 1
    centerLabel.Text = "G"
    centerLabel.TextColor3 = Color3.fromRGB(255, 214, 102)
    centerLabel.Font = Enum.Font.GothamBlack
    centerLabel.TextScaled = true
    centerLabel.ZIndex = 3
    centerLabel.Parent = center

    -- RING (Anel de Items)
    local ring = Instance.new("Frame")
    ring.Name = "Ring"
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Position = UDim2.new(0.5, 0, 0.5, 0)
    ring.Size = UDim2.new(1, 0, 1, 0)
    ring.BackgroundTransparency = 1
    ring.ZIndex = 2
    ring.Parent = container

    -- CRIAR ITEMS
    itemButtons = {}
    for i = 1, #CONFIG.ITEMS do
        local item = CONFIG.ITEMS[i]
        local x, y = getItemPosition(i)

        local itemButton = Instance.new("TextButton")
        itemButton.Name = "Item_" .. i
        itemButton.AnchorPoint = Vector2.new(0.5, 0.5)
        itemButton.Position = UDim2.new(0.5, 0, 0.5, 0)
        itemButton.Size = UDim2.new(0, CONFIG.ITEM_SIZE, 0, CONFIG.ITEM_SIZE)
        itemButton.BackgroundColor3 = Color3.fromRGB(40, 48, 62)
        itemButton.BorderSizePixel = 0
        itemButton.Text = ""
        itemButton.AutoButtonColor = false
        itemButton.ZIndex = 2
        itemButton.Parent = ring

        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 18)
        itemCorner.Parent = itemButton

        local itemStroke = Instance.new("UIStroke")
        itemStroke.Color = Color3.fromRGB(255, 214, 102)
        itemStroke.Thickness = 2
        itemStroke.Parent = itemButton

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = item.Icon .. "\n" .. item.Name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true
        label.TextWrapped = true
        label.TextTransparency = 0.15
        label.ZIndex = 2
        label.Parent = itemButton

        itemButton.MouseEnter:Connect(function()
            if not isOpen then return end
            if i == selectedIndex then return end

            selectedIndex = i
            playSound(CONFIG.SOUNDS.HOVER, CONFIG.SOUND_VOLUME)

            -- Animar todos os items
            for j, btn in pairs(itemButtons) do
                local btnLabel = btn:FindFirstChild("Label")
                local newSize = j == i and UDim2.new(0, CONFIG.ITEM_SIZE_HOVER, 0, CONFIG.ITEM_SIZE_HOVER) or UDim2.new(0, CONFIG.ITEM_SIZE, 0, CONFIG.ITEM_SIZE)
                local newColor = j == i and Color3.fromRGB(255, 180, 50) or Color3.fromRGB(40, 48, 62)
                local newTransparency = j == i and 0 or 0.15

                TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = newSize,
                    BackgroundColor3 = newColor
                }):Play()

                if btnLabel then
                    TweenService:Create(btnLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        TextTransparency = newTransparency
                    }):Play()
                end
            end
        end)

        itemButton.MouseButton1Click:Connect(function()
            if not isOpen then return end

            playAnimation(i)
            selectedIndex = i

            -- Animação de click
            TweenService:Create(itemButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, CONFIG.ITEM_SIZE_HOVER * 0.85, 0, CONFIG.ITEM_SIZE_HOVER * 0.85)
            }):Play()

            task.wait(0.15)
            closeWheel()
        end)

        itemButtons[i] = itemButton
    end

    return overlay, center, ring
end

-- FUNÇÃO: Abrir Roda
function openWheel()
    if isOpen then return end
    isOpen = true

    if not wheelGui then
        createWheelUI()
    end

    wheelGui.Enabled = true

    local overlay = wheelGui:FindFirstChild("Overlay")
    local container = overlay:FindFirstChild("Container")
    local center = container:FindFirstChild("Center")
    local ring = container:FindFirstChild("Ring")

    -- Animar Overlay
    TweenService:Create(overlay, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.4
    }):Play()

    -- Animar Centro
    TweenService:Create(center, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, CONFIG.CENTER_SIZE, 0, CONFIG.CENTER_SIZE)
    }):Play()

    -- Animar Items
    for i = 1, #CONFIG.ITEMS do
        local btn = ring:FindFirstChild("Item_" .. i)
        if btn then
            local x, y = getItemPosition(i)
            local targetSize = UDim2.new(0, CONFIG.ITEM_SIZE, 0, CONFIG.ITEM_SIZE)

            TweenService:Create(btn, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, x, 0.5, y),
                Size = targetSize
            }):Play()
        end
    end

    playSound(CONFIG.SOUNDS.OPEN, CONFIG.SOUND_VOLUME + 0.1)
end

-- FUNÇÃO: Fechar Roda
function closeWheel()
    if not isOpen then return end
    isOpen = false

    if not wheelGui or not wheelGui.Parent then return end

    local overlay = wheelGui:FindFirstChild("Overlay")
    local container = overlay:FindFirstChild("Container")
    if not container then return end

    local center = container:FindFirstChild("Center")
    local ring = container:FindFirstChild("Ring")

    -- Animar Overlay
    TweenService:Create(overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()

    -- Animar Centro
    TweenService:Create(center, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, CONFIG.CENTER_SIZE * 0.7, 0, CONFIG.CENTER_SIZE * 0.7)
    }):Play()

    -- Animar Items
    for i = 1, #CONFIG.ITEMS do
        local btn = ring:FindFirstChild("Item_" .. i)
        if btn then
            TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, CONFIG.ITEM_SIZE * 0.5, 0, CONFIG.ITEM_SIZE * 0.5)
            }):Play()
        end
    end

    task.wait(0.3)
    wheelGui.Enabled = false
end

-- EVENTOS
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == CONFIG.KEYBIND then
        if isOpen then
            closeWheel()
        else
            openWheel()
        end
    end

    if input.KeyCode == Enum.KeyCode.Escape and isOpen then
        closeWheel()
    end
end)

-- RESPAWN
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    trackCache = {}
    stopCurrentAnimation()
    if isOpen then
        closeWheel()
    end
end)

-- INICIALIZAR
createWheelUI()
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✓ Animation Wheel Premium v2")
print("✓ Pressione [G] para abrir/fechar")
print("✓ ESC para fechar")
print("✓ Clique para executar emote")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
