--[[
    ============================================
    ANIMATION WHEEL PREMIUM - ROBLOX
    Sistema profissional de rodinha de animações
    ============================================
    
    Cole este comando no Command Bar do Roblox:
    require(game:GetService("InsertService"):LoadLocalAsset("rbxassetid://00000000")).Run()
    
    OU copie tudo abaixo e cole no Command Bar diretamente
]]

local function createAnimationWheelSystem()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    -- ============ CONFIGURAÇÕES ============
    local CONFIG = {
        KEYBIND = Enum.KeyCode.G,
        RADIUS = 160,
        CENTER_SIZE = 100,
        ITEM_SIZE = 70,
        ITEM_SIZE_HOVER = 85,
        OPEN_SPEED = 0.4,
        CLOSE_SPEED = 0.3,
        HOVER_SPEED = 0.15,
        SOUND_VOLUME = 0.5,

        -- IDs DE ANIMAÇÃO (R6)
        -- Encontre IDs em: https://www.roblox.com/library/search?ConcurrentUsers=true
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

        -- IDS DE SONS
        SOUNDS = {
            OPEN = 3540595510,
            HOVER = 3540595500,
            SELECT = 3540595470,
        }
    }

    -- ============ CACHE E ESTADO ============
    local wheelState = {
        isOpen = false,
        selectedIndex = 1,
        currentTrack = nil,
        trackCache = {},
        lastHoverTime = 0,
        wheelGui = nil,
    }

    -- ============ FUNÇÕES DE SOM ============
    local function playSound(soundId, volume)
        if not soundId or soundId == 0 then return end
        
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. tostring(soundId)
        sound.Volume = volume or CONFIG.SOUND_VOLUME
        sound.Parent = workspace
        
        game:GetService("Debris"):AddItem(sound, 2)
        sound:Play()
    end

    -- ============ FUNÇÕES DE ANIMAÇÃO ============
    local function getAnimationTrack(item)
        if wheelState.trackCache[item.Name] then
            return wheelState.trackCache[item.Name]
        end

        if not item.AssetId or item.AssetId == 0 then
            return nil
        end

        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://" .. tostring(item.AssetId)

        local track = humanoid:LoadAnimation(animation)
        wheelState.trackCache[item.Name] = track
        return track
    end

    local function stopCurrentAnimation()
        if wheelState.currentTrack and wheelState.currentTrack.IsPlaying then
            wheelState.currentTrack:Stop(0.2)
        end
        wheelState.currentTrack = nil
    end

    local function playAnimation(index)
        local item = CONFIG.ITEMS[index]
        if not item or not item.AssetId or item.AssetId == 0 then
            return
        end

        stopCurrentAnimation()

        local track = getAnimationTrack(item)
        if not track then
            return
        end

        track:Play(item.Speed or 1, 1, item.Speed or 1)
        wheelState.currentTrack = track

        playSound(CONFIG.SOUNDS.SELECT, CONFIG.SOUND_VOLUME + 0.2)
    end

    -- ============ FUNÇÕES DE UI ============
    local function getItemAngle(index)
        local count = #CONFIG.ITEMS
        return -math.pi / 2 + (math.pi * 2 * (index - 1) / count)
    end

    local function getItemPosition(index)
        local angle = getItemAngle(index)
        local x = math.cos(angle) * CONFIG.RADIUS
        local y = math.sin(angle) * CONFIG.RADIUS
        return x, y
    end

    local function createWheelUI()
        if wheelState.wheelGui then
            wheelState.wheelGui:Destroy()
        end

        wheelState.wheelGui = Instance.new("ScreenGui")
        wheelState.wheelGui.Name = "AnimationWheelPremium"
        wheelState.wheelGui.ResetOnSpawn = false
        wheelState.wheelGui.IgnoreGuiInset = true
        wheelState.wheelGui.Enabled = false
        wheelState.wheelGui.Parent = player:WaitForChild("PlayerGui")

        -- Overlay
        local overlay = Instance.new("Frame")
        overlay.Name = "Overlay"
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        overlay.BackgroundTransparency = 1
        overlay.ZIndex = 1
        overlay.Parent = wheelState.wheelGui

        local overlayClick = Instance.new("TextButton")
        overlayClick.Size = UDim2.new(1, 0, 1, 0)
        overlayClick.BackgroundTransparency = 1
        overlayClick.Text = ""
        overlayClick.ZIndex = 1
        overlayClick.Parent = overlay

        overlayClick.MouseButton1Click:Connect(function()
            if wheelState.isOpen then
                closeWheel()
            end
        end)

        -- Container Principal
        local container = Instance.new("Frame")
        container.Name = "Container"
        container.AnchorPoint = Vector2.new(0.5, 0.5)
        container.Position = UDim2.new(0.5, 0, 0.5, 0)
        container.Size = UDim2.new(0, 1, 0, 1)
        container.BackgroundTransparency = 1
        container.ZIndex = 2
        container.Parent = overlay

        -- Centro
        local center = Instance.new("Frame")
        center.Name = "Center"
        center.AnchorPoint = Vector2.new(0.5, 0.5)
        center.Position = UDim2.new(0, 0, 0, 0)
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

        -- Anel de Items
        local ring = Instance.new("Frame")
        ring.Name = "Ring"
        ring.AnchorPoint = Vector2.new(0.5, 0.5)
        ring.Position = UDim2.new(0, 0, 0, 0)
        ring.Size = UDim2.new(0, 1, 0, 1)
        ring.BackgroundTransparency = 1
        ring.ZIndex = 2
        ring.Parent = container

        local itemButtons = {}

        for i = 1, #CONFIG.ITEMS do
            local item = CONFIG.ITEMS[i]
            local x, y = getItemPosition(i)

            local itemButton = Instance.new("TextButton")
            itemButton.Name = "Item_" .. i
            itemButton.AnchorPoint = Vector2.new(0.5, 0.5)
            itemButton.Position = UDim2.new(0.5, 0, 0.5, 0)
            itemButton.Size = UDim2.new(0, CONFIG.ITEM_SIZE, 0, CONFIG.ITEM_SIZE)
            itemButton.BackgroundColor3 = Color3.fromRGB(35, 42, 55)
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

            -- Background
            local bg = Instance.new("Frame")
            bg.Name = "BG"
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3 = i == wheelState.selectedIndex and Color3.fromRGB(255, 180, 50) or Color3.fromRGB(40, 48, 62)
            bg.BorderSizePixel = 0
            bg.ZIndex = 1
            bg.Parent = itemButton

            local bgCorner = Instance.new("UICorner")
            bgCorner.CornerRadius = UDim.new(0, 18)
            bgCorner.Parent = bg

            -- Icon/Label
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = item.Icon .. "\n" .. item.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.Font = Enum.Font.GothamBold
            label.TextScaled = true
            label.TextWrapped = true
            label.TextTransparency = i == wheelState.selectedIndex and 0 or 0.15
            label.ZIndex = 2
            label.Parent = itemButton

            -- Eventos de Mouse
            local function onHover()
                if not wheelState.isOpen or i == wheelState.selectedIndex then
                    return
                end

                wheelState.selectedIndex = i
                playSound(CONFIG.SOUNDS.HOVER, CONFIG.SOUND_VOLUME)

                -- Animação de todos os itens
                for j, btn in pairs(itemButtons) do
                    local btnBg = btn:FindFirstChild("BG")
                    local btnLabel = btn:FindFirstChild("Label")
                    local newSize = j == i and UDim2.new(0, CONFIG.ITEM_SIZE_HOVER, 0, CONFIG.ITEM_SIZE_HOVER) or UDim2.new(0, CONFIG.ITEM_SIZE, 0, CONFIG.ITEM_SIZE)

                    TweenService:Create(btn, TweenInfo.new(CONFIG.HOVER_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = newSize
                    }):Play()

                    if btnBg then
                        local targetColor = j == i and Color3.fromRGB(255, 180, 50) or Color3.fromRGB(40, 48, 62)
                        TweenService:Create(btnBg, TweenInfo.new(CONFIG.HOVER_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundColor3 = targetColor
                        }):Play()
                    end

                    if btnLabel then
                        TweenService:Create(btnLabel, TweenInfo.new(CONFIG.HOVER_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            TextTransparency = j == i and 0 or 0.15
                        }):Play()
                    end
                end
            end

            itemButton.MouseEnter:Connect(onHover)

            itemButton.MouseButton1Click:Connect(function()
                if not wheelState.isOpen then
                    return
                end

                playAnimation(i)
                wheelState.selectedIndex = i
                
                -- Animação de click
                TweenService:Create(itemButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, CONFIG.ITEM_SIZE_HOVER * 0.9, 0, CONFIG.ITEM_SIZE_HOVER * 0.9)
                }):Play()

                task.wait(0.1)
                closeWheel()
            end)

            itemButtons[i] = itemButton
        end

        return container, center, ring, itemButtons
    end

    -- ============ FUNÇÕES DE ANIMAÇÃO DA RODA ============
    function openWheel()
        if wheelState.isOpen then
            return
        end

        wheelState.isOpen = true

        if not wheelState.wheelGui then
            createWheelUI()
        end

        local container, center, ring, itemButtons = createWheelUI()
        if not container then
            container = wheelState.wheelGui:FindFirstChild("Overlay"):FindFirstChild("Container")
            center = container:FindFirstChild("Center")
            ring = container:FindFirstChild("Ring")
            itemButtons = {}
            for i = 1, #CONFIG.ITEMS do
                itemButtons[i] = ring:FindFirstChild("Item_" .. i)
            end
        end

        wheelState.wheelGui.Enabled = true

        -- Overlay fade
        local overlay = wheelState.wheelGui:FindFirstChild("Overlay")
        TweenService:Create(overlay, TweenInfo.new(CONFIG.OPEN_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.4
        }):Play()

        -- Center pop
        TweenService:Create(center, TweenInfo.new(CONFIG.OPEN_SPEED, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, CONFIG.CENTER_SIZE, 0, CONFIG.CENTER_SIZE)
        }):Play()

        -- Items spread
        for i, btn in pairs(itemButtons) do
            local x, y = getItemPosition(i)
            local targetSize = i == wheelState.selectedIndex and UDim2.new(0, CONFIG.ITEM_SIZE_HOVER, 0, CONFIG.ITEM_SIZE_HOVER) or UDim2.new(0, CONFIG.ITEM_SIZE, 0, CONFIG.ITEM_SIZE)

            TweenService:Create(btn, TweenInfo.new(CONFIG.OPEN_SPEED, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, x, 0.5, y),
                Size = targetSize
            }):Play()
        end

        playSound(CONFIG.SOUNDS.OPEN, CONFIG.SOUND_VOLUME + 0.1)
    end

    function closeWheel()
        if not wheelState.isOpen then
            return
        end

        wheelState.isOpen = false

        if not wheelState.wheelGui or not wheelState.wheelGui.Parent then
            return
        end

        local container = wheelState.wheelGui:FindFirstChild("Overlay"):FindFirstChild("Container")
        if not container then
            return
        end

        local center = container:FindFirstChild("Center")
        local ring = container:FindFirstChild("Ring")

        -- Overlay fade out
        local overlay = wheelState.wheelGui:FindFirstChild("Overlay")
        TweenService:Create(overlay, TweenInfo.new(CONFIG.CLOSE_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        }):Play()

        -- Center collapse
        TweenService:Create(center, TweenInfo.new(CONFIG.CLOSE_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, CONFIG.CENTER_SIZE * 0.8, 0, CONFIG.CENTER_SIZE * 0.8)
        }):Play()

        -- Items collapse
        for i = 1, #CONFIG.ITEMS do
            local btn = ring:FindFirstChild("Item_" .. i)
            if btn then
                TweenService:Create(btn, TweenInfo.new(CONFIG.CLOSE_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, CONFIG.ITEM_SIZE * 0.5, 0, CONFIG.ITEM_SIZE * 0.5)
                }):Play()
            end
        end

        task.wait(CONFIG.CLOSE_SPEED)
        wheelState.wheelGui.Enabled = false
    end

    -- ============ INPUT HANDLING ============
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end

        if input.KeyCode == CONFIG.KEYBIND then
            if wheelState.isOpen then
                closeWheel()
            else
                openWheel()
            end
        end

        -- ESC para fechar
        if input.KeyCode == Enum.KeyCode.Escape and wheelState.isOpen then
            closeWheel()
        end
    end)

    -- ============ CHARACTER RESPAWN HANDLING ============
    player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
        wheelState.trackCache = {}
        stopCurrentAnimation()
        
        if wheelState.isOpen then
            closeWheel()
        end
    end)

    -- ============ INICIALIZAÇÃO ============
    print("✓ Animation Wheel Premium carregado!")
    print("✓ Pressione [G] para abrir/fechar")
    print("✓ ESC para fechar rapidamente")
    print("✓ Clique no emote para executar")

    return {
        openWheel = openWheel,
        closeWheel = closeWheel,
        playAnimation = playAnimation,
    }
end

-- Executa o sistema
createAnimationWheelSystem()
