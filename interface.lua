--[[
    EchnoLibrary - Advanced Roblox GUI Library (Version Modifiée)
    Created by: EchnoLibrary Team
    Version: 1.0.0
    
    Modifications:
    - Touche d'ouverture changée vers G
    - Animations d'ouverture et fermeture améliorées
    - Placement des textes corrigé

    A comprehensive GUI library for Roblox with modern design,
    data persistence, and customizable themes.
]]

local EchnoLibrary = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Mouse = Player:GetMouse()

-- Configuration
local CONFIG = {
    SaveFileName = "Acteterroriste",
    DefaultToggleKey = Enum.KeyCode.G, -- Changé de Insert vers G
    AnimationSpeed = 0.5, -- Augmenté pour des animations plus visibles
    OpenAnimationSpeed = 0.6,
    CloseAnimationSpeed = 0.4,
    DefaultTheme = {
        Primary = Color3.fromRGB(45, 45, 55),
        Secondary = Color3.fromRGB(35, 35, 45),
        Accent = Color3.fromRGB(85, 170, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Success = Color3.fromRGB(85, 255, 127),
        Warning = Color3.fromRGB(255, 213, 85),
        Error = Color3.fromRGB(255, 85, 85),
        Background = Color3.fromRGB(25, 25, 35)
    }
}

-- Global Variables
local CurrentTheme = CONFIG.DefaultTheme
local SavedSettings = {}
local ToggleKey = CONFIG.DefaultToggleKey
local CreatedGuis = {}

-- Utility Functions
local function CreateTween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or CONFIG.AnimationSpeed,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    return TweenService:Create(object, tweenInfo, properties)
end

-- Animation d'ouverture améliorée
local function PlayOpenAnimation(mainFrame)
    -- Animation d'entrée avec effet de scale et fade
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.BackgroundTransparency = 1
    
    local openTween = CreateTween(mainFrame, {
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundTransparency = 0
    }, CONFIG.OpenAnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    openTween:Play()
    
    -- Animation des éléments enfants
    for _, child in pairs(mainFrame:GetChildren()) do
        if child:IsA("GuiObject") then
            child.BackgroundTransparency = 1
            wait(0.05)
            local childTween = CreateTween(child, {
                BackgroundTransparency = 0
            }, 0.3)
            childTween:Play()
        end
    end
end

-- Animation de fermeture améliorée
local function PlayCloseAnimation(mainFrame, callback)
    local closeTween = CreateTween(mainFrame, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1
    }, CONFIG.CloseAnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    
    closeTween:Play()
    closeTween.Completed:Connect(function()
        if callback then
            callback()
        end
    end)
end

local function RippleEffect(button, color)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = color or CurrentTheme.Accent
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.ZIndex = button.ZIndex + 1
    ripple.Parent = button

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple

    local expandTween = CreateTween(ripple, {
        Size = UDim2.new(2, 0, 2, 0),
        BackgroundTransparency = 1
    }, 0.5)

    expandTween:Play()
    expandTween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

local function SaveSettings()
    local success, result = pcall(function()
        SavedSettings.Theme = CurrentTheme
        SavedSettings.ToggleKey = ToggleKey.Name
        local encoded = HttpService:JSONEncode(SavedSettings)
        writefile(CONFIG.SaveFileName .. ".json", encoded)
        return true
    end)

    if not success then
        warn("EchnoLibrary: Failed to save settings - " .. tostring(result))
    end
end

local function LoadSettings()
    local success, result = pcall(function()
        if isfile(CONFIG.SaveFileName .. ".json") then
            local content = readfile(CONFIG.SaveFileName .. ".json")
            local decoded = HttpService:JSONDecode(content)

            if decoded.Theme then
                CurrentTheme = decoded.Theme
            end

            if decoded.ToggleKey then
                ToggleKey = Enum.KeyCode[decoded.ToggleKey] or CONFIG.DefaultToggleKey
            end

            SavedSettings = decoded
            return true
        end
        return false
    end)

    if not success then
        warn("EchnoLibrary: Failed to load settings - " .. tostring(result))
    end
end

-- Main Library Functions
function EchnoLibrary:CreateWindow(title, subtitle)
    local windowData = {
        Tabs = {},
        Elements = {},
        Visible = false -- Commencer fermé pour l'animation
    }

    -- Create main GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EchnoLibrary_" .. title
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Enabled = false -- Commencer désactivé
    screenGui.Parent = PlayerGui

    table.insert(CreatedGuis, screenGui)

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.BackgroundColor3 = CurrentTheme.Primary
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    -- Shadow Effect
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, -3, 0, -3)
    shadow.BackgroundColor3 = Color3.new(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.BorderSizePixel = 0
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 12)
    shadowCorner.Parent = shadow

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = CurrentTheme.Secondary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0.5, 0)
    titleFix.Position = UDim2.new(0, 0, 0.5, 0)
    titleFix.BackgroundColor3 = CurrentTheme.Secondary
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar

    -- Title Text (placement amélioré)
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -120, 0, 30) -- Taille fixe pour éviter les chevauchements
    titleText.Position = UDim2.new(0, 20, 0, 5) -- Position ajustée
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = CurrentTheme.Text
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.TextYAlignment = Enum.TextYAlignment.Center
    titleText.Font = Enum.Font.GothamBold
    titleText.TextTruncate = Enum.TextTruncate.AtEnd -- Évite le débordement
    titleText.Parent = titleBar

    -- Subtitle Text (placement amélioré)
    if subtitle then
        local subtitleText = Instance.new("TextLabel")
        subtitleText.Name = "Subtitle"
        subtitleText.Size = UDim2.new(1, -120, 0, 15) -- Taille réduite
        subtitleText.Position = UDim2.new(0, 20, 0, 30) -- Position sous le titre
        subtitleText.BackgroundTransparency = 1
        subtitleText.Text = subtitle
        subtitleText.TextColor3 = CurrentTheme.TextSecondary
        subtitleText.TextSize = 12
        subtitleText.TextXAlignment = Enum.TextXAlignment.Left
        subtitleText.TextYAlignment = Enum.TextYAlignment.Center
        subtitleText.Font = Enum.Font.Gotham
        subtitleText.TextTruncate = Enum.TextTruncate.AtEnd
        subtitleText.Parent = titleBar
    end

    -- Close Button (position ajustée)
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = CurrentTheme.Error
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = CurrentTheme.Text
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton

    -- Settings Button (position ajustée)
    local settingsButton = Instance.new("TextButton")
    settingsButton.Name = "SettingsButton"
    settingsButton.Size = UDim2.new(0, 30, 0, 30)
    settingsButton.Position = UDim2.new(1, -75, 0, 10)
    settingsButton.BackgroundColor3 = CurrentTheme.Accent
    settingsButton.BorderSizePixel = 0
    settingsButton.Text = "⚙"
    settingsButton.TextColor3 = CurrentTheme.Text
    settingsButton.TextSize = 14
    settingsButton.Font = Enum.Font.Gotham
    settingsButton.Parent = titleBar

    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 6)
    settingsCorner.Parent = settingsButton

    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 150, 1, -50)
    tabContainer.Position = UDim2.new(0, 0, 0, 50)
    tabContainer.BackgroundColor3 = CurrentTheme.Background
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame

    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -150, 1, -50)
    contentContainer.Position = UDim2.new(0, 150, 0, 50)
    contentContainer.BackgroundTransparency = 1
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame

    -- Fonction de toggle avec animations
    local function toggleWindow()
        if windowData.Visible then
            -- Fermer avec animation
            windowData.Visible = false
            PlayCloseAnimation(mainFrame, function()
                screenGui.Enabled = false
            end)
        else
            -- Ouvrir avec animation
            windowData.Visible = true
            screenGui.Enabled = true
            PlayOpenAnimation(mainFrame)
        end
    end

    -- Input handler pour la touche G
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == ToggleKey then
            toggleWindow()
        end
    end)

    -- Dragging functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Close button functionality avec animation
    closeButton.MouseButton1Click:Connect(function()
        RippleEffect(closeButton, CurrentTheme.Text)
        windowData.Visible = false
        PlayCloseAnimation(mainFrame, function()
            screenGui.Enabled = false
        end)
    end)

    -- Window object methods
    function windowData:CreateTab(name, icon)
        local tabData = {
            Name = name,
            Icon = icon,
            Elements = {},
            Active = false
        }

        -- Tab Button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "Tab"
        tabButton.Size = UDim2.new(1, -10, 0, 40)
        tabButton.Position = UDim2.new(0, 5, 0, 10 + (#self.Tabs * 45))
        tabButton.BackgroundColor3 = CurrentTheme.Secondary
        tabButton.BorderSizePixel = 0
        tabButton.Text = (icon or "") .. " " .. name
        tabButton.TextColor3 = CurrentTheme.TextSecondary
        tabButton.TextSize = 14
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.TextTruncate = Enum.TextTruncate.AtEnd -- Évite le débordement des onglets
        tabButton.Font = Enum.Font.Gotham
        tabButton.Parent = tabContainer

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabButton

        -- Tab padding pour le texte
        local tabPadding = Instance.new("UIPadding")
        tabPadding.PaddingLeft = UDim.new(0, 10)
        tabPadding.PaddingRight = UDim.new(0, 10)
        tabPadding.Parent = tabButton

        -- Tab Content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = name .. "Content"
        tabContent.Size = UDim2.new(1, -20, 1, -20)
        tabContent.Position = UDim2.new(0, 10, 0, 10)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 6
        tabContent.ScrollBarImageColor3 = CurrentTheme.Accent
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Visible = false
        tabContent.Parent = contentContainer

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.Parent = tabContent

        -- Auto-update canvas size
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end)

        tabData.Button = tabButton
        tabData.Content = tabContent

        -- Tab click functionality
        tabButton.MouseButton1Click:Connect(function()
            RippleEffect(tabButton)
            
            -- Hide all tabs
            for _, tab in pairs(self.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = CurrentTheme.Secondary
                tab.Button.TextColor3 = CurrentTheme.TextSecondary
                tab.Active = false
            end
            
            -- Show current tab
            tabContent.Visible = true
            tabButton.BackgroundColor3 = CurrentTheme.Accent
            tabButton.TextColor3 = CurrentTheme.Text
            tabData.Active = true
        end)

        -- Auto-select first tab
        if #self.Tabs == 0 then
            tabContent.Visible = true
            tabButton.BackgroundColor3 = CurrentTheme.Accent
            tabButton.TextColor3 = CurrentTheme.Text
            tabData.Active = true
        end

        table.insert(self.Tabs, tabData)

        -- Tab methods
        function tabData:CreateButton(text, callback)
            local button = Instance.new("TextButton")
            button.Name = text .. "Button"
            button.Size = UDim2.new(1, 0, 0, 35)
            button.BackgroundColor3 = CurrentTheme.Secondary
            button.BorderSizePixel = 0
            button.Text = text
            button.TextColor3 = CurrentTheme.Text
            button.TextSize = 14
            button.Font = Enum.Font.Gotham
            button.Parent = tabContent

            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 6)
            buttonCorner.Parent = button

            button.MouseButton1Click:Connect(function()
                RippleEffect(button)
                if callback then
                    callback()
                end
            end)

            button.MouseEnter:Connect(function()
                CreateTween(button, {BackgroundColor3 = CurrentTheme.Accent}, 0.2):Play()
            end)

            button.MouseLeave:Connect(function()
                CreateTween(button, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2):Play()
            end)

            return button
        end

        function tabData:CreateToggle(text, default, callback)
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Name = text .. "Toggle"
            toggleFrame.Size = UDim2.new(1, 0, 0, 35)
            toggleFrame.BackgroundColor3 = CurrentTheme.Secondary
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = tabContent

            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 6)
            toggleCorner.Parent = toggleFrame

            -- Label avec padding amélioré
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, -60, 1, 0) -- Espace pour le toggle
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = CurrentTheme.Text
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Center
            label.Font = Enum.Font.Gotham
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.Parent = toggleFrame

            local toggleButton = Instance.new("TextButton")
            toggleButton.Name = "ToggleButton"
            toggleButton.Size = UDim2.new(0, 40, 0, 20)
            toggleButton.Position = UDim2.new(1, -50, 0.5, -10)
            toggleButton.BackgroundColor3 = default and CurrentTheme.Success or CurrentTheme.Background
            toggleButton.BorderSizePixel = 0
            toggleButton.Text = ""
            toggleButton.Parent = toggleFrame

            local toggleButtonCorner = Instance.new("UICorner")
            toggleButtonCorner.CornerRadius = UDim.new(1, 0)
            toggleButtonCorner.Parent = toggleButton

            local toggleCircle = Instance.new("Frame")
            toggleCircle.Name = "Circle"
            toggleCircle.Size = UDim2.new(0, 16, 0, 16)
            toggleCircle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            toggleCircle.BackgroundColor3 = CurrentTheme.Text
            toggleCircle.BorderSizePixel = 0
            toggleCircle.Parent = toggleButton

            local circleCorner = Instance.new("UICorner")
            circleCorner.CornerRadius = UDim.new(1, 0)
            circleCorner.Parent = toggleCircle

            local isToggled = default

            toggleButton.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                
                local newBackgroundColor = isToggled and CurrentTheme.Success or CurrentTheme.Background
                local newPosition = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                
                CreateTween(toggleButton, {BackgroundColor3 = newBackgroundColor}, 0.3):Play()
                CreateTween(toggleCircle, {Position = newPosition}, 0.3):Play()
                
                if callback then
                    callback(isToggled)
                end
            end)

            return toggleFrame
        end

        function tabData:CreateSlider(text, min, max, default, callback)
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Name = text .. "Slider"
            sliderFrame.Size = UDim2.new(1, 0, 0, 50) -- Hauteur augmentée
            sliderFrame.BackgroundColor3 = CurrentTheme.Secondary
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = tabContent

            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(0, 6)
            sliderCorner.Parent = sliderFrame

            -- Label avec placement amélioré
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, -20, 0, 20)
            label.Position = UDim2.new(0, 10, 0, 5)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = CurrentTheme.Text
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.Parent = sliderFrame

            -- Value label
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Name = "ValueLabel"
            valueLabel.Size = UDim2.new(0, 60, 0, 20)
            valueLabel.Position = UDim2.new(1, -70, 0, 5)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(default)
            valueLabel.TextColor3 = CurrentTheme.Accent
            valueLabel.TextSize = 12
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.Parent = sliderFrame

            local sliderBar = Instance.new("Frame")
            sliderBar.Name = "SliderBar"
            sliderBar.Size = UDim2.new(1, -20, 0, 6)
            sliderBar.Position = UDim2.new(0, 10, 0, 30)
            sliderBar.BackgroundColor3 = CurrentTheme.Background
            sliderBar.BorderSizePixel = 0
            sliderBar.Parent = sliderFrame

            local sliderBarCorner = Instance.new("UICorner")
            sliderBarCorner.CornerRadius = UDim.new(1, 0)
            sliderBarCorner.Parent = sliderBar

            local sliderFill = Instance.new("Frame")
            sliderFill.Name = "Fill"
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = CurrentTheme.Accent
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBar

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = sliderFill

            local sliderButton = Instance.new("TextButton")
            sliderButton.Name = "SliderButton"
            sliderButton.Size = UDim2.new(0, 16, 0, 16)
            sliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
            sliderButton.BackgroundColor3 = CurrentTheme.Text
            sliderButton.BorderSizePixel = 0
            sliderButton.Text = ""
            sliderButton.Parent = sliderBar

            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(1, 0)
            buttonCorner.Parent = sliderButton

            local currentValue = default
            local dragging = false

            local function updateSlider(input)
                local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                currentValue = math.floor(min + (max - min) * relativeX)
                
                valueLabel.Text = tostring(currentValue)
                sliderButton.Position = UDim2.new(relativeX, -8, 0.5, -8)
                sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                
                if callback then
                    callback(currentValue)
                end
            end

            sliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    updateSlider(input)
                end
            end)

            return sliderFrame
        end

        function tabData:CreateTextbox(text, placeholder, callback)
            local textboxFrame = Instance.new("Frame")
            textboxFrame.Name = text .. "Textbox"
            textboxFrame.Size = UDim2.new(1, 0, 0, 50) -- Hauteur augmentée
            textboxFrame.BackgroundColor3 = CurrentTheme.Secondary
            textboxFrame.BorderSizePixel = 0
            textboxFrame.Parent = tabContent

            local textboxCorner = Instance.new("UICorner")
            textboxCorner.CornerRadius = UDim.new(0, 6)
            textboxCorner.Parent = textboxFrame

            -- Label avec espacement amélioré
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, -20, 0, 20)
            label.Position = UDim2.new(0, 10, 0, 5)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = CurrentTheme.Text
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.Parent = textboxFrame

            local textbox = Instance.new("TextBox")
            textbox.Name = "Textbox"
            textbox.Size = UDim2.new(1, -20, 0, 20)
            textbox.Position = UDim2.new(0, 10, 0, 25)
            textbox.BackgroundColor3 = CurrentTheme.Background
            textbox.BorderSizePixel = 0
            textbox.Text = ""
            textbox.PlaceholderText = placeholder
            textbox.TextColor3 = CurrentTheme.Text
            textbox.PlaceholderColor3 = CurrentTheme.TextSecondary
            textbox.TextSize = 12
            textbox.Font = Enum.Font.Gotham
            textbox.ClearButtonOnFocus = false
            textbox.Parent = textboxFrame

            local textboxInputCorner = Instance.new("UICorner")
            textboxInputCorner.CornerRadius = UDim.new(0, 4)
            textboxInputCorner.Parent = textbox

            -- Padding interne
            local textboxPadding = Instance.new("UIPadding")
            textboxPadding.PaddingLeft = UDim.new(0, 8)
            textboxPadding.PaddingRight = UDim.new(0, 8)
            textboxPadding.Parent = textbox

            textbox.FocusLost:Connect(function(enterPressed)
                if callback and enterPressed then
                    callback(textbox.Text)
                end
            end)

            return textboxFrame
        end

        function tabData:CreateDropdown(text, options, callback)
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Name = text .. "Dropdown"
            dropdownFrame.Size = UDim2.new(1, 0, 0, 35)
            dropdownFrame.BackgroundColor3 = CurrentTheme.Secondary
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Parent = tabContent

            local dropdownCorner = Instance.new("UICorner")
            dropdownCorner.CornerRadius = UDim.new(0, 6)
            dropdownCorner.Parent = dropdownFrame

            -- Main button avec espacement amélioré
            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Name = "DropdownButton"
            dropdownButton.Size = UDim2.new(1, -20, 1, 0)
            dropdownButton.Position = UDim2.new(0, 10, 0, 0)
            dropdownButton.BackgroundTransparency = 1
            dropdownButton.Text = text .. ": " .. (options[1] or "None")
            dropdownButton.TextColor3 = CurrentTheme.Text
            dropdownButton.TextSize = 14
            dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
            dropdownButton.Font = Enum.Font.Gotham
            dropdownButton.TextTruncate = Enum.TextTruncate.AtEnd
            dropdownButton.Parent = dropdownFrame

            local arrow = Instance.new("TextLabel")
            arrow.Name = "Arrow"
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(1, -25, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▼"
            arrow.TextColor3 = CurrentTheme.TextSecondary
            arrow.TextSize = 12
            arrow.TextXAlignment = Enum.TextXAlignment.Center
            arrow.Font = Enum.Font.Gotham
            arrow.Parent = dropdownFrame

            local optionsFrame = Instance.new("Frame")
            optionsFrame.Name = "OptionsFrame"
            optionsFrame.Size = UDim2.new(1, 0, 0, #options * 30)
            optionsFrame.Position = UDim2.new(0, 0, 1, 5)
            optionsFrame.BackgroundColor3 = CurrentTheme.Primary
            optionsFrame.BorderSizePixel = 0
            optionsFrame.Visible = false
            optionsFrame.ZIndex = dropdownFrame.ZIndex + 10
            optionsFrame.Parent = dropdownFrame

            local optionsCorner = Instance.new("UICorner")
            optionsCorner.CornerRadius = UDim.new(0, 6)
            optionsCorner.Parent = optionsFrame

            local optionsLayout = Instance.new("UIListLayout")
            optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optionsLayout.Parent = optionsFrame

            local selectedOption = options[1]
            local isOpen = false

            for i, option in ipairs(options) do
                local optionButton = Instance.new("TextButton")
                optionButton.Name = "Option" .. i
                optionButton.Size = UDim2.new(1, 0, 0, 30)
                optionButton.BackgroundColor3 = CurrentTheme.Primary
                optionButton.BorderSizePixel = 0
                optionButton.Text = option
                optionButton.TextColor3 = CurrentTheme.Text
                optionButton.TextSize = 12
                optionButton.TextXAlignment = Enum.TextXAlignment.Left
                optionButton.Font = Enum.Font.Gotham
                optionButton.Parent = optionsFrame

                -- Padding pour les options
                local optionPadding = Instance.new("UIPadding")
                optionPadding.PaddingLeft = UDim.new(0, 10)
                optionPadding.Parent = optionButton

                optionButton.MouseButton1Click:Connect(function()
                    selectedOption = option
                    dropdownButton.Text = text .. ": " .. option
                    optionsFrame.Visible = false
                    isOpen = false
                    arrow.Text = "▼"
                    
                    if callback then
                        callback(option)
                    end
                end)

                optionButton.MouseEnter:Connect(function()
                    optionButton.BackgroundColor3 = CurrentTheme.Accent
                end)

                optionButton.MouseLeave:Connect(function()
                    optionButton.BackgroundColor3 = CurrentTheme.Primary
                end)
            end

            dropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                optionsFrame.Visible = isOpen
                arrow.Text = isOpen and "▲" or "▼"
                
                if isOpen then
                    dropdownFrame.Size = UDim2.new(1, 0, 0, 35 + (#options * 30) + 5)
                else
                    dropdownFrame.Size = UDim2.new(1, 0, 0, 35)
                end
            end)

            return dropdownFrame
        end

        return tabData
    end

    function windowData:Toggle()
        toggleWindow()
    end

    function windowData:Destroy()
        screenGui:Destroy()
        for i, gui in ipairs(CreatedGuis) do
            if gui == screenGui then
                table.remove(CreatedGuis, i)
                break
            end
        end
    end

    -- Load settings and initialize
    LoadSettings()

    return windowData
end

-- Notification system amélioré
function EchnoLibrary:CreateNotification(title, description, duration, notificationType)
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "Notification"
    notificationFrame.Size = UDim2.new(0, 300, 0, 80)
    notificationFrame.Position = UDim2.new(1, 320, 0, 50) -- Commence hors écran
    notificationFrame.BackgroundColor3 = CurrentTheme.Primary
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Parent = PlayerGui

    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notificationFrame

    -- Type indicator
    local typeColor = CurrentTheme.Accent
    if notificationType == "success" then
        typeColor = CurrentTheme.Success
    elseif notificationType == "warning" then
        typeColor = CurrentTheme.Warning
    elseif notificationType == "error" then
        typeColor = CurrentTheme.Error
    end

    local typeIndicator = Instance.new("Frame")
    typeIndicator.Name = "TypeIndicator"
    typeIndicator.Size = UDim2.new(0, 4, 1, 0)
    typeIndicator.BackgroundColor3 = typeColor
    typeIndicator.BorderSizePixel = 0
    typeIndicator.Parent = notificationFrame

    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 2)
    indicatorCorner.Parent = typeIndicator

    -- Title avec placement amélioré
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 15, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = CurrentTheme.Text
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = notificationFrame

    -- Description
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, -20, 0, 35)
    descLabel.Position = UDim2.new(0, 15, 0, 35)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = CurrentTheme.TextSecondary
    descLabel.TextSize = 12
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextWrapped = true
    descLabel.Parent = notificationFrame

    -- Animation d'entrée
    local enterTween = CreateTween(notificationFrame, {
        Position = UDim2.new(1, -320, 0, 50)
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    enterTween:Play()

    -- Animation de sortie après la durée
    game:GetService("Debris"):AddItem(notificationFrame, duration or 5)
    
    wait(duration or 4.5)
    local exitTween = CreateTween(notificationFrame, {
        Position = UDim2.new(1, 320, 0, 50),
        BackgroundTransparency = 1
    }, 0.3)
    
    exitTween:Play()
end

-- Initialize library
LoadSettings()

-- Cleanup function
game.Players.PlayerRemoving:Connect(function(player)
    if player == Player then
        SaveSettings()
        for _, gui in ipairs(CreatedGuis) do
            gui:Destroy()
        end
    end
end)

return EchnoLibrary
