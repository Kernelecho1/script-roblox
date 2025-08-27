--[[
    EchnoLibrary - Advanced Roblox GUI Library
    Created by: EchnoLibrary Team
    Version: 1.0.0
    
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
    DefaultToggleKey = Enum.KeyCode.Insert,
    AnimationSpeed = 0.3,
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

local function CreateColorPicker(parent, callback)
    local colorPicker = Instance.new("Frame")
    colorPicker.Name = "ColorPicker"
    colorPicker.Size = UDim2.new(1, 0, 0, 200)
    colorPicker.BackgroundColor3 = CurrentTheme.Secondary
    colorPicker.BorderSizePixel = 0
    colorPicker.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = colorPicker
    
    local hueBar = Instance.new("Frame")
    hueBar.Name = "HueBar"
    hueBar.Size = UDim2.new(0.8, 0, 0, 20)
    hueBar.Position = UDim2.new(0.1, 0, 0.1, 0)
    hueBar.BackgroundColor3 = Color3.new(1, 0, 0)
    hueBar.BorderSizePixel = 0
    hueBar.Parent = colorPicker
    
    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 4)
    hueCorner.Parent = hueBar
    
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
        ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
        ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
    })
    hueGradient.Parent = hueBar
    
    local colorDisplay = Instance.new("Frame")
    colorDisplay.Name = "ColorDisplay"
    colorDisplay.Size = UDim2.new(0.8, 0, 0, 60)
    colorDisplay.Position = UDim2.new(0.1, 0, 0.4, 0)
    colorDisplay.BackgroundColor3 = Color3.new(1, 1, 1)
    colorDisplay.BorderSizePixel = 0
    colorDisplay.Parent = colorPicker
    
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 4)
    displayCorner.Parent = colorDisplay
    
    local currentHue = 0
    local currentColor = Color3.new(1, 0, 0)
    
    local function updateColor()
        currentColor = Color3.fromHSV(currentHue, 1, 1)
        colorDisplay.BackgroundColor3 = currentColor
        if callback then
            callback(currentColor)
        end
    end
    
    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = RunService.Heartbeat:Connect(function()
                local mouseX = Mouse.X - hueBar.AbsolutePosition.X
                local relativeX = math.clamp(mouseX / hueBar.AbsoluteSize.X, 0, 1)
                currentHue = relativeX
                updateColor()
            end)
            
            local releaseConnection
            releaseConnection = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                    releaseConnection:Disconnect()
                end
            end)
        end
    end)
    
    return colorPicker
end

-- Main Library Functions
function EchnoLibrary:CreateWindow(title, subtitle)
    local windowData = {
        Tabs = {},
        Elements = {},
        Visible = true
    }
    
    -- Create main GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EchnoLibrary_" .. title
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
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
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = CurrentTheme.Text
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.Parent = titleBar
    
    -- Subtitle Text
    if subtitle then
        local subtitleText = Instance.new("TextLabel")
        subtitleText.Name = "Subtitle"
        subtitleText.Size = UDim2.new(1, -100, 0, 20)
        subtitleText.Position = UDim2.new(0, 15, 0, 25)
        subtitleText.BackgroundTransparency = 1
        subtitleText.Text = subtitle
        subtitleText.TextColor3 = CurrentTheme.TextSecondary
        subtitleText.TextSize = 12
        subtitleText.TextXAlignment = Enum.TextXAlignment.Left
        subtitleText.Font = Enum.Font.Gotham
        subtitleText.Parent = titleBar
    end
    
    -- Close Button
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
    
    -- Settings Button
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
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        RippleEffect(closeButton, CurrentTheme.Text)
        windowData.Visible = false
        screenGui.Enabled = false
    end)
    
    -- Settings Panel
    local settingsPanel = Instance.new("Frame")
    settingsPanel.Name = "SettingsPanel"
    settingsPanel.Size = UDim2.new(0, 300, 0, 400)
    settingsPanel.Position = UDim2.new(0, -310, 0, 0)
    settingsPanel.BackgroundColor3 = CurrentTheme.Primary
    settingsPanel.BorderSizePixel = 0
    settingsPanel.Visible = false
    settingsPanel.Parent = mainFrame
    
    local settingsPanelCorner = Instance.new("UICorner")
    settingsPanelCorner.CornerRadius = UDim.new(0, 12)
    settingsPanelCorner.Parent = settingsPanel
    
    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Name = "SettingsTitle"
    settingsTitle.Size = UDim2.new(1, 0, 0, 40)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Text = "Paramètres"
    settingsTitle.TextColor3 = CurrentTheme.Text
    settingsTitle.TextSize = 16
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.Parent = settingsPanel
    
    -- Theme Color Picker
    local themeLabel = Instance.new("TextLabel")
    themeLabel.Name = "ThemeLabel"
    themeLabel.Size = UDim2.new(1, -20, 0, 20)
    themeLabel.Position = UDim2.new(0, 10, 0, 50)
    themeLabel.BackgroundTransparency = 1
    themeLabel.Text = "Couleur d'accent:"
    themeLabel.TextColor3 = CurrentTheme.Text
    themeLabel.TextSize = 12
    themeLabel.TextXAlignment = Enum.TextXAlignment.Left
    themeLabel.Font = Enum.Font.Gotham
    themeLabel.Parent = settingsPanel
    
    local colorPicker = CreateColorPicker(settingsPanel, function(color)
        CurrentTheme.Accent = color
        SaveSettings()
        -- Update all GUI elements with new theme
        for _, gui in pairs(CreatedGuis) do
            if gui and gui.Parent then
                local function updateElement(element)
                    if element:IsA("TextButton") or element:IsA("Frame") then
                        if element.Name:find("Accent") or element.BackgroundColor3 == CurrentTheme.Accent then
                            element.BackgroundColor3 = color
                        end
                    end
                    for _, child in pairs(element:GetChildren()) do
                        updateElement(child)
                    end
                end
                updateElement(gui)
            end
        end
    end)
    colorPicker.Position = UDim2.new(0, 10, 0, 80)
    colorPicker.Size = UDim2.new(1, -20, 0, 100)
    
    -- Keybind Settings
    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.Name = "KeybindLabel"
    keybindLabel.Size = UDim2.new(1, -20, 0, 20)
    keybindLabel.Position = UDim2.new(0, 10, 0, 200)
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Text = "Touche de basculement:"
    keybindLabel.TextColor3 = CurrentTheme.Text
    keybindLabel.TextSize = 12
    keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    keybindLabel.Font = Enum.Font.Gotham
    keybindLabel.Parent = settingsPanel
    
    local keybindButton = Instance.new("TextButton")
    keybindButton.Name = "KeybindButton"
    keybindButton.Size = UDim2.new(1, -20, 0, 30)
    keybindButton.Position = UDim2.new(0, 10, 0, 225)
    keybindButton.BackgroundColor3 = CurrentTheme.Secondary
    keybindButton.BorderSizePixel = 0
    keybindButton.Text = ToggleKey.Name
    keybindButton.TextColor3 = CurrentTheme.Text
    keybindButton.TextSize = 12
    keybindButton.Font = Enum.Font.Gotham
    keybindButton.Parent = settingsPanel
    
    local keybindCorner = Instance.new("UICorner")
    keybindCorner.CornerRadius = UDim.new(0, 6)
    keybindCorner.Parent = keybindButton
    
    local listeningForKey = false
    keybindButton.MouseButton1Click:Connect(function()
        if not listeningForKey then
            listeningForKey = true
            keybindButton.Text = "Appuyez sur une touche..."
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    ToggleKey = input.KeyCode
                    keybindButton.Text = ToggleKey.Name
                    listeningForKey = false
                    connection:Disconnect()
                    SaveSettings()
                end
            end)
        end
    end)
    
    -- Settings button functionality
    settingsButton.MouseButton1Click:Connect(function()
        RippleEffect(settingsButton, CurrentTheme.Text)
        settingsPanel.Visible = not settingsPanel.Visible
        
        local targetPos = settingsPanel.Visible and UDim2.new(0, -310, 0, 0) or UDim2.new(0, 0, 0, 0)
        CreateTween(settingsPanel, {Position = targetPos}):Play()
    end)
    
    -- Toggle functionality
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == ToggleKey then
            windowData.Visible = not windowData.Visible
            screenGui.Enabled = windowData.Visible
        end
    end)
    
    -- Window methods
    function windowData:CreateTab(name, icon)
        local tabData = {
            Elements = {},
            Container = nil
        }
        
        -- Tab Button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "Tab_" .. name
        tabButton.Size = UDim2.new(1, -10, 0, 40)
        tabButton.Position = UDim2.new(0, 5, 0, #self.Tabs * 45 + 10)
        tabButton.BackgroundColor3 = CurrentTheme.Secondary
        tabButton.BorderSizePixel = 0
        tabButton.Text = (icon and (icon .. " ") or "") .. name
        tabButton.TextColor3 = CurrentTheme.Text
        tabButton.TextSize = 12
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.Font = Enum.Font.Gotham
        tabButton.Parent = tabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabButton
        
        local tabPadding = Instance.new("UIPadding")
        tabPadding.PaddingLeft = UDim.new(0, 10)
        tabPadding.Parent = tabButton
        
        -- Tab Content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = "TabContent_" .. name
        tabContent.Size = UDim2.new(1, -20, 1, -20)
        tabContent.Position = UDim2.new(0, 10, 0, 10)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = CurrentTheme.Accent
        tabContent.Visible = #self.Tabs == 0
        tabContent.Parent = contentContainer
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 5)
        contentLayout.Parent = tabContent
        
        tabData.Container = tabContent
        
        -- Tab button click
        tabButton.MouseButton1Click:Connect(function()
            RippleEffect(tabButton, CurrentTheme.Accent)
            
            -- Hide all tabs
            for _, tab in pairs(self.Tabs) do
                tab.Container.Visible = false
                -- Reset tab button color
            end
            
            -- Show selected tab
            tabContent.Visible = true
            
            -- Update tab button appearance
            tabButton.BackgroundColor3 = CurrentTheme.Accent
        end)
        
        -- Tab element creation methods
        function tabData:CreateButton(text, callback)
            local button = Instance.new("TextButton")
            button.Name = "Button_" .. text
            button.Size = UDim2.new(1, 0, 0, 35)
            button.BackgroundColor3 = CurrentTheme.Secondary
            button.BorderSizePixel = 0
            button.Text = text
            button.TextColor3 = CurrentTheme.Text
            button.TextSize = 12
            button.Font = Enum.Font.Gotham
            button.Parent = tabContent
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 6)
            buttonCorner.Parent = button
            
            button.MouseButton1Click:Connect(function()
                RippleEffect(button, CurrentTheme.Accent)
                if callback then
                    callback()
                end
            end)
            
            button.MouseEnter:Connect(function()
                CreateTween(button, {BackgroundColor3 = CurrentTheme.Accent}):Play()
            end)
            
            button.MouseLeave:Connect(function()
                CreateTween(button, {BackgroundColor3 = CurrentTheme.Secondary}):Play()
            end)
            
            return button
        end
        
        function tabData:CreateToggle(text, default, callback)
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Name = "Toggle_" .. text
            toggleFrame.Size = UDim2.new(1, 0, 0, 35)
            toggleFrame.BackgroundColor3 = CurrentTheme.Secondary
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = tabContent
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 6)
            toggleCorner.Parent = toggleFrame
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Size = UDim2.new(1, -50, 1, 0)
            toggleLabel.Position = UDim2.new(0, 10, 0, 0)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Text = text
            toggleLabel.TextColor3 = CurrentTheme.Text
            toggleLabel.TextSize = 12
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Font = Enum.Font.Gotham
            toggleLabel.Parent = toggleFrame
            
            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, 40, 0, 20)
            toggleButton.Position = UDim2.new(1, -45, 0.5, -10)
            toggleButton.BackgroundColor3 = default and CurrentTheme.Success or CurrentTheme.TextSecondary
            toggleButton.BorderSizePixel = 0
            toggleButton.Text = ""
            toggleButton.Parent = toggleFrame
            
            local toggleButtonCorner = Instance.new("UICorner")
            toggleButtonCorner.CornerRadius = UDim.new(1, 0)
            toggleButtonCorner.Parent = toggleButton
            
            local toggleIndicator = Instance.new("Frame")
            toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
            toggleIndicator.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            toggleIndicator.BackgroundColor3 = CurrentTheme.Text
            toggleIndicator.BorderSizePixel = 0
            toggleIndicator.Parent = toggleButton
            
            local indicatorCorner = Instance.new("UICorner")
            indicatorCorner.CornerRadius = UDim.new(1, 0)
            indicatorCorner.Parent = toggleIndicator
            
            local toggled = default
            
            toggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                
                local indicatorPos = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local buttonColor = toggled and CurrentTheme.Success or CurrentTheme.TextSecondary
                
                CreateTween(toggleIndicator, {Position = indicatorPos}):Play()
                CreateTween(toggleButton, {BackgroundColor3 = buttonColor}):Play()
                
                if callback then
                    callback(toggled)
                end
            end)
            
            return {Frame = toggleFrame, SetValue = function(value)
                toggled = value
                local indicatorPos = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local buttonColor = toggled and CurrentTheme.Success or CurrentTheme.TextSecondary
                CreateTween(toggleIndicator, {Position = indicatorPos}):Play()
                CreateTween(toggleButton, {BackgroundColor3 = buttonColor}):Play()
            end}
        end
        
        function tabData:CreateSlider(text, min, max, default, callback)
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Name = "Slider_" .. text
            sliderFrame.Size = UDim2.new(1, 0, 0, 50)
            sliderFrame.BackgroundColor3 = CurrentTheme.Secondary
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = tabContent
            
            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(0, 6)
            sliderCorner.Parent = sliderFrame
            
            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Size = UDim2.new(0.7, 0, 0, 20)
            sliderLabel.Position = UDim2.new(0, 10, 0, 5)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Text = text
            sliderLabel.TextColor3 = CurrentTheme.Text
            sliderLabel.TextSize = 12
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Font = Enum.Font.Gotham
            sliderLabel.Parent = sliderFrame
            
            local sliderValue = Instance.new("TextLabel")
            sliderValue.Size = UDim2.new(0.3, -10, 0, 20)
            sliderValue.Position = UDim2.new(0.7, 0, 0, 5)
            sliderValue.BackgroundTransparency = 1
            sliderValue.Text = tostring(default)
            sliderValue.TextColor3 = CurrentTheme.Accent
            sliderValue.TextSize = 12
            sliderValue.TextXAlignment = Enum.TextXAlignment.Right
            sliderValue.Font = Enum.Font.GothamBold
            sliderValue.Parent = sliderFrame
            
            local sliderTrack = Instance.new("Frame")
            sliderTrack.Size = UDim2.new(1, -20, 0, 4)
            sliderTrack.Position = UDim2.new(0, 10, 1, -15)
            sliderTrack.BackgroundColor3 = CurrentTheme.Background
            sliderTrack.BorderSizePixel = 0
            sliderTrack.Parent = sliderFrame
            
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = sliderTrack
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = CurrentTheme.Accent
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderTrack
            
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = sliderFill
            
            local sliderHandle = Instance.new("Frame")
            sliderHandle.Size = UDim2.new(0, 12, 0, 12)
            sliderHandle.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
            sliderHandle.BackgroundColor3 = CurrentTheme.Text
            sliderHandle.BorderSizePixel = 0
            sliderHandle.Parent = sliderTrack
            
            local handleCorner = Instance.new("UICorner")
            handleCorner.CornerRadius = UDim.new(1, 0)
            handleCorner.Parent = sliderHandle
            
            local currentValue = default
            local dragging = false
            
            local function updateSlider(input)
                local relativeX = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                currentValue = min + (max - min) * relativeX
                currentValue = math.floor(currentValue * 100) / 100 -- Round to 2 decimal places
                
                sliderValue.Text = tostring(currentValue)
                sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                sliderHandle.Position = UDim2.new(relativeX, -6, 0.5, -6)
                
                if callback then
                    callback(currentValue)
                end
            end
            
            sliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
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
            
            return {Frame = sliderFrame, SetValue = function(value)
                currentValue = math.clamp(value, min, max)
                local relativeX = (currentValue - min) / (max - min)
                sliderValue.Text = tostring(currentValue)
                sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                sliderHandle.Position = UDim2.new(relativeX, -6, 0.5, -6)
            end}
        end
        
        function tabData:CreateTextbox(text, placeholder, callback)
            local textboxFrame = Instance.new("Frame")
            textboxFrame.Name = "Textbox_" .. text
            textboxFrame.Size = UDim2.new(1, 0, 0, 35)
            textboxFrame.BackgroundColor3 = CurrentTheme.Secondary
            textboxFrame.BorderSizePixel = 0
            textboxFrame.Parent = tabContent
            
            local textboxCorner = Instance.new("UICorner")
            textboxCorner.CornerRadius = UDim.new(0, 6)
            textboxCorner.Parent = textboxFrame
            
            local textboxInput = Instance.new("TextBox")
            textboxInput.Size = UDim2.new(1, -20, 1, 0)
            textboxInput.Position = UDim2.new(0, 10, 0, 0)
            textboxInput.BackgroundTransparency = 1
            textboxInput.Text = ""
            textboxInput.PlaceholderText = placeholder or text
            textboxInput.TextColor3 = CurrentTheme.Text
            textboxInput.PlaceholderColor3 = CurrentTheme.TextSecondary
            textboxInput.TextSize = 12
            textboxInput.TextXAlignment = Enum.TextXAlignment.Left
            textboxInput.Font = Enum.Font.Gotham
            textboxInput.ClearTextOnFocus = false
            textboxInput.Parent = textboxFrame
            
            textboxInput.FocusLost:Connect(function(enterPressed)
                if enterPressed and callback then
                    callback(textboxInput.Text)
                end
            end)
            
            textboxInput.Focused:Connect(function()
                CreateTween(textboxFrame, {BackgroundColor3 = CurrentTheme.Accent}):Play()
            end)
            
            textboxInput.FocusLost:Connect(function()
                CreateTween(textboxFrame, {BackgroundColor3 = CurrentTheme.Secondary}):Play()
            end)
            
            return {Frame = textboxFrame, SetText = function(newText)
                textboxInput.Text = newText
            end, GetText = function()
                return textboxInput.Text
            end}
        end
        
        function tabData:CreateDropdown(text, options, callback)
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Name = "Dropdown_" .. text
            dropdownFrame.Size = UDim2.new(1, 0, 0, 35)
            dropdownFrame.BackgroundColor3 = CurrentTheme.Secondary
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Parent = tabContent
            
            local dropdownCorner = Instance.new("UICorner")
            dropdownCorner.CornerRadius = UDim.new(0, 6)
            dropdownCorner.Parent = dropdownFrame
            
            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Size = UDim2.new(1, 0, 1, 0)
            dropdownButton.BackgroundTransparency = 1
            dropdownButton.Text = text .. ": " .. (options[1] or "None")
            dropdownButton.TextColor3 = CurrentTheme.Text
            dropdownButton.TextSize = 12
            dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
            dropdownButton.Font = Enum.Font.Gotham
            dropdownButton.Parent = dropdownFrame
            
            local dropdownPadding = Instance.new("UIPadding")
            dropdownPadding.PaddingLeft = UDim.new(0, 10)
            dropdownPadding.PaddingRight = UDim.new(0, 10)
            dropdownPadding.Parent = dropdownButton
            
            local dropdownArrow = Instance.new("TextLabel")
            dropdownArrow.Size = UDim2.new(0, 20, 1, 0)
            dropdownArrow.Position = UDim2.new(1, -25, 0, 0)
            dropdownArrow.BackgroundTransparency = 1
            dropdownArrow.Text = "▼"
            dropdownArrow.TextColor3 = CurrentTheme.TextSecondary
            dropdownArrow.TextSize = 10
            dropdownArrow.Font = Enum.Font.Gotham
            dropdownArrow.Parent = dropdownFrame
            
            local dropdownList = Instance.new("Frame")
            dropdownList.Name = "DropdownList"
            dropdownList.Size = UDim2.new(1, 0, 0, #options * 30)
            dropdownList.Position = UDim2.new(0, 0, 1, 5)
            dropdownList.BackgroundColor3 = CurrentTheme.Primary
            dropdownList.BorderSizePixel = 0
            dropdownList.Visible = false
            dropdownList.ZIndex = dropdownFrame.ZIndex + 10
            dropdownList.Parent = dropdownFrame
            
            local listCorner = Instance.new("UICorner")
            listCorner.CornerRadius = UDim.new(0, 6)
            listCorner.Parent = dropdownList
            
            local listLayout = Instance.new("UIListLayout")
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Parent = dropdownList
            
            local selectedValue = options[1]
            
            for i, option in ipairs(options) do
                local optionButton = Instance.new("TextButton")
                optionButton.Size = UDim2.new(1, 0, 0, 30)
                optionButton.BackgroundColor3 = Color3.new(0, 0, 0)
                optionButton.BackgroundTransparency = 1
                optionButton.BorderSizePixel = 0
                optionButton.Text = option
                optionButton.TextColor3 = CurrentTheme.Text
                optionButton.TextSize = 12
                optionButton.TextXAlignment = Enum.TextXAlignment.Left
                optionButton.Font = Enum.Font.Gotham
                optionButton.Parent = dropdownList
                
                local optionPadding = Instance.new("UIPadding")
                optionPadding.PaddingLeft = UDim.new(0, 10)
                optionPadding.Parent = optionButton
                
                optionButton.MouseButton1Click:Connect(function()
                    selectedValue = option
                    dropdownButton.Text = text .. ": " .. option
                    dropdownList.Visible = false
                    CreateTween(dropdownArrow, {Rotation = 0}):Play()
                    
                    if callback then
                        callback(option)
                    end
                end)
                
                optionButton.MouseEnter:Connect(function()
                    optionButton.BackgroundTransparency = 0.8
                    optionButton.BackgroundColor3 = CurrentTheme.Accent
                end)
                
                optionButton.MouseLeave:Connect(function()
                    optionButton.BackgroundTransparency = 1
                end)
            end
            
            dropdownButton.MouseButton1Click:Connect(function()
                dropdownList.Visible = not dropdownList.Visible
                local rotation = dropdownList.Visible and 180 or 0
                CreateTween(dropdownArrow, {Rotation = rotation}):Play()
            end)
            
            return {Frame = dropdownFrame, SetValue = function(value)
                if table.find(options, value) then
                    selectedValue = value
                    dropdownButton.Text = text .. ": " .. value
                end
            end, GetValue = function()
                return selectedValue
            end}
        end
        
        table.insert(self.Tabs, tabData)
        return tabData
    end
    
    -- Auto-resize content based on elements
    for _, tab in pairs(windowData.Tabs) do
        local contentLayout = tab.Container:FindFirstChild("UIListLayout")
        if contentLayout then
            contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                tab.Container.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
            end)
        end
    end
    
    return windowData
end

function EchnoLibrary:Notify(title, text, duration)
    duration = duration or 3
    
    local notification = Instance.new("Frame")
    notification.Name = "EchnoNotification"
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, 10, 0, 50)
    notification.BackgroundColor3 = CurrentTheme.Primary
    notification.BorderSizePixel = 0
    
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "EchnoNotification"
    notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notifGui.Parent = PlayerGui
    
    notification.Parent = notifGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notification
    
    local notifTitle = Instance.new("TextLabel")
    notifTitle.Size = UDim2.new(1, -20, 0, 25)
    notifTitle.Position = UDim2.new(0, 10, 0, 10)
    notifTitle.BackgroundTransparency = 1
    notifTitle.Text = title
    notifTitle.TextColor3 = CurrentTheme.Text
    notifTitle.TextSize = 14
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.Parent = notification
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -20, 0, 35)
    notifText.Position = UDim2.new(0, 10, 0, 35)
    notifText.BackgroundTransparency = 1
    notifText.Text = text
    notifText.TextColor3 = CurrentTheme.TextSecondary
    notifText.TextSize = 12
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.TextYAlignment = Enum.TextYAlignment.Top
    notifText.TextWrapped = true
    notifText.Font = Enum.Font.Gotham
    notifText.Parent = notification
    
    -- Animate in
    CreateTween(notification, {Position = UDim2.new(1, -310, 0, 50)}):Play()
    
    -- Animate out after duration
    wait(duration)
    local outTween = CreateTween(notification, {Position = UDim2.new(1, 10, 0, 50)})
    outTween:Play()
    outTween.Completed:Connect(function()
        notifGui:Destroy()
    end)
end

function EchnoLibrary:SetTheme(theme)
    CurrentTheme = theme
    SaveSettings()
    
    -- Update all existing GUI elements with the new theme
    for _, gui in pairs(CreatedGuis) do
        if gui and gui.Parent then
            local function updateElementColors(element)
                if element:IsA("Frame") then
                    if element.Name == "MainFrame" then
                        element.BackgroundColor3 = CurrentTheme.Primary
                    elseif element.Name == "TitleBar" or element.Name == "SettingsPanel" then
                        element.BackgroundColor3 = CurrentTheme.Secondary
                    elseif element.Name == "TabContainer" then
                        element.BackgroundColor3 = CurrentTheme.Background
                    elseif element.Name:find("Toggle_") then
                        element.BackgroundColor3 = CurrentTheme.Secondary
                    end
                elseif element:IsA("TextButton") then
                    if element.Name == "SettingsButton" then
                        element.BackgroundColor3 = CurrentTheme.Accent
                    elseif element.Name == "CloseButton" then
                        element.BackgroundColor3 = CurrentTheme.Error
                    elseif element.Name:find("Tab_") then
                        element.BackgroundColor3 = CurrentTheme.Secondary
                    elseif element.Name:find("Button_") then
                        element.BackgroundColor3 = CurrentTheme.Secondary
                    elseif element.Name == "KeybindButton" then
                        element.BackgroundColor3 = CurrentTheme.Secondary
                    end
                elseif element:IsA("TextLabel") then
                    if element.Name == "Title" or element.Name == "SettingsTitle" then
                        element.TextColor3 = CurrentTheme.Text
                    elseif element.Name == "Subtitle" then
                        element.TextColor3 = CurrentTheme.TextSecondary
                    end
                elseif element:IsA("ScrollingFrame") then
                    element.ScrollBarImageColor3 = CurrentTheme.Accent
                end
                
                -- Recursively update children
                for _, child in pairs(element:GetChildren()) do
                    updateElementColors(child)
                end
            end
            updateElementColors(gui)
        end
    end
end

function EchnoLibrary:GetTheme()
    return CurrentTheme
end

function EchnoLibrary:SetToggleKey(keyCode)
    ToggleKey = keyCode
    SaveSettings()
end

function EchnoLibrary:DestroyAllGuis()
    for _, gui in pairs(CreatedGuis) do
        if gui and gui.Parent then
            gui:Destroy()
        end
    end
    CreatedGuis = {}
end

-- Initialize
LoadSettings()

return EchnoLibrary
