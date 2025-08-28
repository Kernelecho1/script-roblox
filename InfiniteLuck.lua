local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local RemoteLuck = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Events"):FindFirstChild("ServerLuck")

if RemoteLuck and RemoteLuck:IsA("RemoteEvent") then
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LuckUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = player:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 360, 0, 470)
    Frame.Position = UDim2.new(0.5, -180, 0.5, -235)
    Frame.BackgroundColor3 = Color3.fromRGB(45, 52, 64)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    Frame.Active = true
    Frame.Draggable = true
    Frame.ClipsDescendants = true
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 52, 64)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 65, 85))
    })
    UIGradient.Rotation = 135
    UIGradient.Parent = Frame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 25)
    UICorner.Parent = Frame

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 65)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Color3.fromRGB(136, 192, 208)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Frame
    
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(136, 192, 208)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(129, 161, 193))
    })
    TitleGradient.Parent = TitleBar
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 25)
    TitleCorner.Parent = TitleBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -55, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Text = "Luck Booster"
    Title.TextColor3 = Color3.fromRGB(46, 52, 64)
    Title.Font = Enum.Font.GothamMedium
    Title.TextSize = 22
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -45, 0.5, -16)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(191, 97, 106)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(236, 239, 244)
    CloseBtn.Font = Enum.Font.GothamMedium
    CloseBtn.TextSize = 20
    CloseBtn.Parent = TitleBar
    
    local UICornerClose = Instance.new("UICorner")
    UICornerClose.CornerRadius = UDim.new(1, 0)
    UICornerClose.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        local closeTween = TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            ScreenGui:Destroy()
        end)
    end)

    local StatsFrame = Instance.new("Frame")
    StatsFrame.Size = UDim2.new(1, -25, 0, 55)
    StatsFrame.Position = UDim2.new(0, 12.5, 0, 75)
    StatsFrame.BackgroundColor3 = Color3.fromRGB(163, 190, 140)
    StatsFrame.BorderSizePixel = 0
    StatsFrame.Parent = Frame
    
    local StatsGradient = Instance.new("UIGradient")
    StatsGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(163, 190, 140)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 210, 160))
    })
    StatsGradient.Rotation = 45
    StatsGradient.Parent = StatsFrame
    
    local StatsCorner = Instance.new("UICorner")
    StatsCorner.CornerRadius = UDim.new(0, 15)
    StatsCorner.Parent = StatsFrame

    local RobuxIcon = Instance.new("TextLabel")
    RobuxIcon.Size = UDim2.new(0, 30, 0, 25)
    RobuxIcon.Position = UDim2.new(0, 12, 0, 8)
    RobuxIcon.Text = "💰"
    RobuxIcon.TextColor3 = Color3.fromRGB(46, 52, 64)
    RobuxIcon.Font = Enum.Font.GothamMedium
    RobuxIcon.TextSize = 18
    RobuxIcon.BackgroundTransparency = 1
    RobuxIcon.TextXAlignment = Enum.TextXAlignment.Center
    RobuxIcon.Parent = StatsFrame

    local SavingsLabel = Instance.new("TextLabel")
    SavingsLabel.Size = UDim2.new(1, -50, 0, 25)
    SavingsLabel.Position = UDim2.new(0, 45, 0, 8)
    SavingsLabel.Text = "💎 Économisé: 0 R$ (0 luck boosts)"
    SavingsLabel.TextColor3 = Color3.fromRGB(46, 52, 64)
    SavingsLabel.Font = Enum.Font.GothamMedium
    SavingsLabel.TextSize = 14
    SavingsLabel.BackgroundTransparency = 1
    SavingsLabel.TextXAlignment = Enum.TextXAlignment.Left
    SavingsLabel.Parent = StatsFrame

    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -50, 0, 20)
    InfoLabel.Position = UDim2.new(0, 45, 0, 28)
    InfoLabel.Text = "📊 Tarif normal: 29 R$ pour 15min de luck"
    InfoLabel.TextColor3 = Color3.fromRGB(46, 52, 64)
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextSize = 11
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.Parent = StatsFrame

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -25, 1, -145)
    ScrollFrame.Position = UDim2.new(0, 12.5, 0, 140)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(129, 161, 193)
    ScrollFrame.Parent = Frame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 12)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ScrollFrame

    local function updateScrollSize()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 25)
    end
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollSize)

    local totalBoosts = 0
    local currentTheme = 1
    local themes = {
        {
            color1 = Color3.fromRGB(163, 190, 140),
            color2 = Color3.fromRGB(180, 210, 160),
            icon = "💰",
            title = "Clodo de merde"
        },
        {
            color1 = Color3.fromRGB(180, 142, 173),
            color2 = Color3.fromRGB(200, 160, 190),
            icon = "💎",
            title = "t un negro"
        },
        {
            color1 = Color3.fromRGB(208, 135, 112),
            color2 = Color3.fromRGB(230, 155, 130),
            icon = "🏆",
            title = "ouai pas mal"
        },
        {
            color1 = Color3.fromRGB(235, 203, 139),
            color2 = Color3.fromRGB(255, 220, 160),
            icon = "👑",
            title = "Arahhhh"
        },
        {
            color1 = Color3.fromRGB(255, 215, 0),
            color2 = Color3.fromRGB(255, 255, 100),
            icon = "⭐",
            title = "Starfoullah"
        }
    }
    
    local function updateTheme()
        local newTheme = math.min(math.floor(totalBoosts / 10) + 1, #themes)
        if newTheme ~= currentTheme then
            currentTheme = newTheme
            local theme = themes[currentTheme]
            
            spawn(function()
                StatsGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, theme.color1),
                    ColorSequenceKeypoint.new(1, theme.color2)
                })
                
                local frameTween = TweenService:Create(StatsFrame, TweenInfo.new(1.0, Enum.EasingStyle.Sine), {
                    BackgroundColor3 = theme.color1
                })
                frameTween:Play()
            end)
            
            local iconTween = TweenService:Create(RobuxIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 40, 0, 35),
                TextSize = 22
            })
            iconTween:Play()
            iconTween.Completed:Connect(function()
                RobuxIcon.Text = theme.icon
                local returnTween = TweenService:Create(RobuxIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                    Size = UDim2.new(0, 30, 0, 25),
                    TextSize = 18
                })
                returnTween:Play()
            end)
            
            spawn(function()
                local originalText = SavingsLabel.Text
                SavingsLabel.Text = "🎉 " .. theme.title .. " débloqué!"
                SavingsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                spawn(function()
                    wait(2)
                    if SavingsLabel and SavingsLabel.Parent then
                        SavingsLabel.TextColor3 = Color3.fromRGB(46, 52, 64)
                        updateSavings()
                    end
                end)
            end)
        end
    end
    
    local function updateSavings()
        local savedRobux = totalBoosts * 29
        SavingsLabel.Text = string.format("💎 Économisé: %d R$ (%d luck boosts)", savedRobux, totalBoosts)
        
        updateTheme()
    end

    local function createButton(text, layoutOrder, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 50)
        btn.BackgroundColor3 = color or Color3.fromRGB(136, 192, 208)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(46, 52, 64)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 16
        btn.LayoutOrder = layoutOrder
        btn.Parent = ScrollFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 18)
        corner.Parent = btn
        
        btn.MouseEnter:Connect(function()
            local hoverTween = TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(1, -15, 0, 53),
                BackgroundColor3 = Color3.fromRGB(
                    math.min(255, color.R * 255 * 1.1),
                    math.min(255, color.G * 255 * 1.1),
                    math.min(255, color.B * 255 * 1.1)
                )
            })
            hoverTween:Play()
        end)
        
        btn.MouseLeave:Connect(function()
            local leaveTween = TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(1, -20, 0, 50),
                BackgroundColor3 = color
            })
            leaveTween:Play()
        end)
        
        return btn
    end

    local sectionLabel1 = Instance.new("TextLabel")
    sectionLabel1.Size = UDim2.new(1, -20, 0, 30)
    sectionLabel1.Text = "BOOST RAPIDE"
    sectionLabel1.TextColor3 = Color3.fromRGB(136, 192, 208)
    sectionLabel1.Font = Enum.Font.GothamMedium
    sectionLabel1.TextSize = 14
    sectionLabel1.BackgroundTransparency = 1
    sectionLabel1.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel1.LayoutOrder = 1
    sectionLabel1.Parent = ScrollFrame

    local baseButton = createButton("Activer x2 Luck", 2, Color3.fromRGB(163, 190, 140))
    baseButton.MouseButton1Click:Connect(function()
        RemoteLuck:FireServer("LuckyBoost")
        RemoteLuck:FireServer(2)
        totalBoosts = totalBoosts + 1
        updateSavings()
        baseButton.BackgroundColor3 = Color3.fromRGB(180, 210, 160)
        baseButton.Text = "Activé"
        wait(2)
        baseButton.BackgroundColor3 = Color3.fromRGB(163, 190, 140)
        baseButton.Text = "Activer x2 Luck"
    end)

    local sectionLabel2 = Instance.new("TextLabel")
    sectionLabel2.Size = UDim2.new(1, -20, 0, 30)
    sectionLabel2.Text = "DURÉES PRÉDÉFINIES"
    sectionLabel2.TextColor3 = Color3.fromRGB(136, 192, 208)
    sectionLabel2.Font = Enum.Font.GothamMedium
    sectionLabel2.TextSize = 14
    sectionLabel2.BackgroundTransparency = 1
    sectionLabel2.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel2.LayoutOrder = 3
    sectionLabel2.Parent = ScrollFrame

    local times = {
        ["30min"] = {iterations = 2, color = Color3.fromRGB(180, 142, 173)},
        ["1h"] = {iterations = 4, color = Color3.fromRGB(208, 135, 112)},
        ["2h"] = {iterations = 8, color = Color3.fromRGB(235, 203, 139)},
        ["5h"] = {iterations = 20, color = Color3.fromRGB(163, 190, 140)},
    }

    local layoutOrder = 4
    local running = {}

    for label, data in pairs(times) do
        local btn = createButton(label, layoutOrder, data.color)
        layoutOrder = layoutOrder + 1
        local originalText = btn.Text
        local originalColor = btn.BackgroundColor3
        running[label] = false

        btn.MouseButton1Click:Connect(function()
            if not running[label] then
                running[label] = true
                btn.BackgroundColor3 = Color3.fromRGB(216, 222, 233)
                btn.Text = label .. " en cours..."
                spawn(function()
                    for i = 1, data.iterations do
                        if not running[label] then break end
                        RemoteLuck:FireServer("LuckyBoost")
                        RemoteLuck:FireServer(2)
                        totalBoosts = totalBoosts + 1
                        updateSavings()
                        wait(0.05)
                    end
                    btn.BackgroundColor3 = originalColor
                    btn.Text = originalText
                    running[label] = false
                end)
            end
        end)
    end

    local sectionLabel3 = Instance.new("TextLabel")
    sectionLabel3.Size = UDim2.new(1, -20, 0, 30)
    sectionLabel3.Text = "DURÉE PERSONNALISÉE"
    sectionLabel3.TextColor3 = Color3.fromRGB(136, 192, 208)
    sectionLabel3.Font = Enum.Font.GothamMedium
    sectionLabel3.TextSize = 14
    sectionLabel3.BackgroundTransparency = 1
    sectionLabel3.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel3.LayoutOrder = layoutOrder
    sectionLabel3.Parent = ScrollFrame
    layoutOrder = layoutOrder + 1

    local CustomFrame = Instance.new("Frame")
    CustomFrame.Size = UDim2.new(1, -20, 0, 140)
    CustomFrame.BackgroundColor3 = Color3.fromRGB(59, 66, 82)
    CustomFrame.LayoutOrder = layoutOrder
    CustomFrame.Parent = ScrollFrame
    
    local CustomCorner = Instance.new("UICorner")
    CustomCorner.CornerRadius = UDim.new(0, 20)
    CustomCorner.Parent = CustomFrame

    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, -24, 0, 35)
    InputFrame.Position = UDim2.new(0, 12, 0, 15)
    InputFrame.BackgroundTransparency = 1
    InputFrame.Parent = CustomFrame

    local HoursInput = Instance.new("TextBox")
    HoursInput.Size = UDim2.new(0, 80, 1, 0)
    HoursInput.Position = UDim2.new(0, 0, 0, 0)
    HoursInput.BackgroundColor3 = Color3.fromRGB(76, 86, 106)
    HoursInput.Text = "1"
    HoursInput.PlaceholderText = "Heures"
    HoursInput.TextColor3 = Color3.fromRGB(236, 239, 244)
    HoursInput.PlaceholderColor3 = Color3.fromRGB(129, 161, 193)
    HoursInput.Font = Enum.Font.GothamMedium
    HoursInput.TextSize = 14
    HoursInput.TextXAlignment = Enum.TextXAlignment.Center
    HoursInput.Parent = InputFrame
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 12)
    InputCorner.Parent = HoursInput

    local UnitLabel = Instance.new("TextLabel")
    UnitLabel.Size = UDim2.new(1, -90, 1, 0)
    UnitLabel.Position = UDim2.new(0, 90, 0, 0)
    UnitLabel.Text = "heure(s)"
    UnitLabel.TextColor3 = Color3.fromRGB(129, 161, 193)
    UnitLabel.Font = Enum.Font.GothamMedium
    UnitLabel.TextSize = 14
    UnitLabel.BackgroundTransparency = 1
    UnitLabel.TextXAlignment = Enum.TextXAlignment.Left
    UnitLabel.TextYAlignment = Enum.TextYAlignment.Center
    UnitLabel.Parent = InputFrame

    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(1, -24, 0, 20)
    DescLabel.Position = UDim2.new(0, 12, 0, 55)
    DescLabel.Text = "Entrez le nombre d'heures pour le boost personnalisé"
    DescLabel.TextColor3 = Color3.fromRGB(129, 161, 193)
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextSize = 12
    DescLabel.BackgroundTransparency = 1
    DescLabel.TextXAlignment = Enum.TextXAlignment.Center
    DescLabel.Parent = CustomFrame

    local ButtonsFrame = Instance.new("Frame")
    ButtonsFrame.Size = UDim2.new(1, -24, 0, 40)
    ButtonsFrame.Position = UDim2.new(0, 12, 0, 85)
    ButtonsFrame.BackgroundTransparency = 1
    ButtonsFrame.Parent = CustomFrame

    local CustomButton = Instance.new("TextButton")
    CustomButton.Size = UDim2.new(0.5, -5, 1, 0)
    CustomButton.Position = UDim2.new(0, 0, 0, 0)
    CustomButton.BackgroundColor3 = Color3.fromRGB(180, 142, 173)
    CustomButton.Text = "Lancer"
    CustomButton.TextColor3 = Color3.fromRGB(46, 52, 64)
    CustomButton.Font = Enum.Font.GothamMedium
    CustomButton.TextSize = 14
    CustomButton.Parent = ButtonsFrame
    
    local CustomBtnCorner = Instance.new("UICorner")
    CustomBtnCorner.CornerRadius = UDim.new(0, 12)
    CustomBtnCorner.Parent = CustomButton

    local StopButton = Instance.new("TextButton")
    StopButton.Size = UDim2.new(0.5, -5, 1, 0)
    StopButton.Position = UDim2.new(0.5, 5, 0, 0)
    StopButton.BackgroundColor3 = Color3.fromRGB(191, 97, 106)
    StopButton.Text = "Stop"
    StopButton.TextColor3 = Color3.fromRGB(236, 239, 244)
    StopButton.Font = Enum.Font.GothamMedium
    StopButton.TextSize = 14
    StopButton.Visible = false
    StopButton.Parent = ButtonsFrame
    
    local StopBtnCorner = Instance.new("UICorner")
    StopBtnCorner.CornerRadius = UDim.new(0, 12)
    StopBtnCorner.Parent = StopButton

    local customRunning = false
    
    CustomButton.MouseButton1Click:Connect(function()
        if customRunning then return end
        
        local hours = tonumber(HoursInput.Text)
        if not hours or hours <= 0 then
            HoursInput.Text = "Invalide!"
            wait(2)
            HoursInput.Text = "1"
            return
        end
        
        local iterations = hours * 4
        customRunning = true
        CustomButton.BackgroundColor3 = Color3.fromRGB(216, 222, 233)
        CustomButton.Text = hours .. "h actif"
        CustomButton.Visible = false
        StopButton.Visible = true
        
        spawn(function()
            for i = 1, iterations do
                if not customRunning then break end
                RemoteLuck:FireServer("LuckyBoost")
                RemoteLuck:FireServer(2)
                totalBoosts = totalBoosts + 1
                updateSavings()
                if i % 100 == 0 then
                    print("Custom: " .. i .. "/" .. iterations .. " (" .. hours .. "h)")
                end
                wait(0.05)
            end
            updateSavings()
            StopButton.BackgroundColor3 = Color3.fromRGB(163, 190, 140)
            StopButton.Text = "Terminé"
        end)
    end)

    StopButton.MouseButton1Click:Connect(function()
        customRunning = false
        CustomButton.BackgroundColor3 = Color3.fromRGB(180, 142, 173)
        CustomButton.Text = "Lancer"
        CustomButton.Visible = true
        StopButton.BackgroundColor3 = Color3.fromRGB(191, 97, 106)
        StopButton.Text = "Stop"
        StopButton.Visible = false
    end)

    local LifetimeButton = createButton("Mode infini", layoutOrder + 1, Color3.fromRGB(208, 135, 112))
    local lifetimeRunning = false
    
    local CreditButton = createButton("💫 Crédits 💫", layoutOrder + 2, Color3.fromRGB(129, 161, 193))

    LifetimeButton.MouseButton1Click:Connect(function()
        lifetimeRunning = not lifetimeRunning
        if lifetimeRunning then
            LifetimeButton.Text = "⏹️ Arrêter infini"
            LifetimeButton.BackgroundColor3 = Color3.fromRGB(216, 222, 233)
            spawn(function()
                local count = 0
                while lifetimeRunning do
                    RemoteLuck:FireServer("LuckyBoost")
                    RemoteLuck:FireServer(2)
                    totalBoosts = totalBoosts + 1
                    count = count + 1
                    updateSavings()
                    if count % 1000 == 0 then
                        print("Mode infini: " .. count .. " itérations")
                    end
                    wait(0.05)
                end
                updateSavings()
                LifetimeButton.BackgroundColor3 = Color3.fromRGB(208, 135, 112)
                LifetimeButton.Text = "🚀 Mode infini"
            end)
        else
            LifetimeButton.Text = "✅ Infini stoppé"
            wait(1.5)
            LifetimeButton.Text = "🚀 Mode infini"
        end
    end)

    local creditMessages = {
        "🎨 Script créé par Kajoul",
        "⚡ Version 1.0",
        "💎 Merci d'utiliser le script!",
        "🚀 Enjoy your luck boost!"
    }
    local currentCreditIndex = 1
    
    CreditButton.MouseButton1Click:Connect(function()
        local colors = {
            Color3.fromRGB(255, 182, 193),
            Color3.fromRGB(255, 218, 185),
            Color3.fromRGB(255, 255, 186),
            Color3.fromRGB(186, 255, 201),
            Color3.fromRGB(186, 225, 255),
            Color3.fromRGB(221, 160, 221)
        }
        
        CreditButton.Text = creditMessages[currentCreditIndex]
        currentCreditIndex = currentCreditIndex % #creditMessages + 1
        
        spawn(function()
            for i, color in ipairs(colors) do
                if CreditButton.Parent then
                    local colorTween = TweenService:Create(CreditButton, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
                        BackgroundColor3 = color
                    })
                    colorTween:Play()
                    wait(0.4)
                end
            end
            
            local returnTween = TweenService:Create(CreditButton, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(129, 161, 193)
            })
            returnTween:Play()
            wait(1)
            
            if CreditButton.Parent then
                CreditButton.Text = "💫 Crédits 💫"
            end
        end)
    end)

    Frame.Size = UDim2.new(0, 0, 0, 0)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local openTween = TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 360, 0, 470),
        Position = UDim2.new(0.5, -180, 0.5, -235)
    })
    openTween:Play()
    
    wait(0.1)
    updateScrollSize()
    
else
    warn("⚠️ Remote 'ServerLuck' introuvable dans ReplicatedStorage.Remotes.Events")
end
