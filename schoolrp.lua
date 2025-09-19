local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService('VirtualUser')
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({
    Name = "Prostone Hub - schibuya rp",
    LoadingTitle = "Chargement du Script",
    LoadingSubtitle = "par Prostone Hub",
    Theme = "DarkBlue",
    SyncConfigSettings = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ProstoneHub",
        FileName = "Configuration"
    },
    Discord = {
        Enabled = true,
        Invite = "RyQFfVrbWR",
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title = "Prostone Hub - Key System",
        Subtitle = "Entrez votre clé d'accès",
        Note = "La clé se récupère sur le serveur Discord ! Rejoignez-nous pour l'obtenir.",
        FileName = "ProstoneKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"CioKombuchaa"}
    }
})

local MainTab = Window:CreateTab("Local Player", 4483362458)

local WalkSpeedSection = MainTab:CreateSection("WalkSpeed")

local WalkSpeedSlider = MainTab:CreateSlider({
    Name = "WalkSpeed (1-35)",
    Range = {1, 35},
    Increment = 1,
    Suffix = "",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

local AntiAFKSection = MainTab:CreateSection("Anti AFK Prostone Hub")

local AntiAFKEnabled = false
local AntiAFKConnection = nil
local AntiAFKGui = nil
local TimerActive = false
local AntiAFKSeconds = 0
local AntiAFKMinutes = 0
local AntiAFKHours = 0

local function CreateAntiAFKInterface()
    if AntiAFKGui then
        AntiAFKGui:Destroy()
    end

    if getgenv().ProstoneAntiAfkExecuted then
        getgenv().ProstoneAntiAfkExecuted = false
        getgenv().ProstoneTimerActive = false
        local existingGui = game.CoreGui:FindFirstChild("ProstoneAntiAfkGui")
        if existingGui then
            existingGui:Destroy()
        end
    end

    getgenv().ProstoneAntiAfkExecuted = true

    AntiAFKGui = Instance.new("ScreenGui")
    local MainContainer = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")
    local StatusIcon = Instance.new("Frame")
    local IconCorner = Instance.new("UICorner")
    local IconLabel = Instance.new("TextLabel")
    local ContentFrame = Instance.new("Frame")
    local TitleLabel = Instance.new("TextLabel")
    local TimerLabel = Instance.new("TextLabel")
    local StatusLabel = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    local CloseCorner = Instance.new("UICorner")
    local CreditsLabel = Instance.new("TextLabel")

    AntiAFKGui.Name = "ProstoneAntiAfkGui"
    AntiAFKGui.Parent = game.CoreGui
    AntiAFKGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    AntiAFKGui.ResetOnSpawn = false

    -- Container principal avec style moderne
    MainContainer.Name = "MainContainer"
    MainContainer.Parent = AntiAFKGui
    MainContainer.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    MainContainer.BorderSizePixel = 0
    MainContainer.Position = UDim2.new(0.02, 0, 0.02, 0)
    MainContainer.Size = UDim2.new(0, 340, 0, 90)

    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainContainer

    UIStroke.Color = Color3.fromRGB(46, 204, 113)
    UIStroke.Thickness = 2
    UIStroke.Parent = MainContainer

    -- Icône de statut
    StatusIcon.Name = "StatusIcon"
    StatusIcon.Parent = MainContainer
    StatusIcon.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    StatusIcon.BorderSizePixel = 0
    StatusIcon.Position = UDim2.new(0, 15, 0.5, -18)
    StatusIcon.Size = UDim2.new(0, 36, 0, 36)

    IconCorner.CornerRadius = UDim.new(0, 18)
    IconCorner.Parent = StatusIcon

    IconLabel.Name = "IconLabel"
    IconLabel.Parent = StatusIcon
    IconLabel.BackgroundTransparency = 1
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.Text = "⚡"
    IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconLabel.TextScaled = true
    IconLabel.TextStrokeTransparency = 0.5
    IconLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    -- Contenu texte
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainContainer
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 65, 0, 8)
    ContentFrame.Size = UDim2.new(0, 240, 0, 74)

    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = ContentFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.Size = UDim2.new(1, -35, 0, 24)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "PROSTONE ANTI-AFK"
    TitleLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextYAlignment = Enum.TextYAlignment.Center

    TimerLabel.Name = "TimerLabel"
    TimerLabel.Parent = ContentFrame
    TimerLabel.BackgroundTransparency = 1
    TimerLabel.Position = UDim2.new(0, 0, 0, 25)
    TimerLabel.Size = UDim2.new(0.6, 0, 0, 20)
    TimerLabel.Font = Enum.Font.GothamBold
    TimerLabel.Text = "Temps: 0:00:00"
    TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimerLabel.TextSize = 13
    TimerLabel.TextXAlignment = Enum.TextXAlignment.Left
    TimerLabel.TextYAlignment = Enum.TextYAlignment.Center

    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = ContentFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0.6, 0, 0, 25)
    StatusLabel.Size = UDim2.new(0.4, -35, 0, 20)
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.Text = "ACTIF"
    StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Center

    CreditsLabel.Name = "CreditsLabel"
    CreditsLabel.Parent = ContentFrame
    CreditsLabel.BackgroundTransparency = 1
    CreditsLabel.Position = UDim2.new(0, 0, 0, 50)
    CreditsLabel.Size = UDim2.new(1, -35, 0, 18)
    CreditsLabel.Font = Enum.Font.Gotham
    CreditsLabel.Text = "Protection automatique contre l'inactivité"
    CreditsLabel.TextColor3 = Color3.fromRGB(149, 165, 166)
    CreditsLabel.TextSize = 11
    CreditsLabel.TextXAlignment = Enum.TextXAlignment.Left
    CreditsLabel.TextYAlignment = Enum.TextYAlignment.Center


    -- Bouton fermer moderne
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = MainContainer
    CloseButton.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -30, 0, 8)
    CloseButton.Size = UDim2.new(0, 22, 0, 22)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 12

    CloseCorner.CornerRadius = UDim.new(0, 11)
    CloseCorner.Parent = CloseButton



    CloseButton.MouseButton1Click:Connect(function()
        local slideOut = TweenService:Create(MainContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
            Position = UDim2.new(1, 10, 0.02, 0)
        })
        slideOut:Play()
        slideOut.Completed:Wait()

        if StaffNotificationGui then
            StaffNotificationGui:Destroy()
            StaffNotificationGui = nil
        end
    end)

    -- Système de glissement moderne
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function updateDrag(input)
        local delta = input.Position - dragStart
        local dragTime = 0.04
        local targetPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)

        local dragTween = TweenService:Create(MainContainer, TweenInfo.new(dragTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = targetPosition})
        dragTween:Play()
    end

    MainContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainContainer.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainContainer.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and MainContainer.Size then
            updateDrag(input)
        end
    end)

    -- Animation d'entrée fluide
    MainContainer.Position = UDim2.new(-0.5, 0, 0.02, 0)
    MainContainer.BackgroundTransparency = 1
    StatusIcon.BackgroundTransparency = 1

    for _, child in pairs(ContentFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child.TextTransparency = 1
        end
    end
    CloseButton.BackgroundTransparency = 1
    CloseButton.TextTransparency = 1

    -- Animation de glissement vers la droite
    local slideIn = TweenService:Create(MainContainer, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.02, 0, 0.02, 0)
    })
    slideIn:Play()

    -- Animation de fade in
    local fadeInTween = TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0})
    fadeInTween:Play()

    local iconFade = TweenService:Create(StatusIcon, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 0})
    iconFade:Play()

    local buttonFade = TweenService:Create(CloseButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 0})
    buttonFade:Play()

    local buttonTextFade = TweenService:Create(CloseButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {TextTransparency = 0})
    buttonTextFade:Play()

    -- Animation des textes
    for i, child in pairs(ContentFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            task.spawn(function()
                task.wait(0.1 * i)
                local textTween = TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0})
                textTween:Play()
            end)
        end
    end

    TimerActive = true
    getgenv().ProstoneTimerActive = true

    -- Timer amélioré avec effets visuels
    spawn(function()
        while TimerActive and getgenv().ProstoneTimerActive and AntiAFKGui do
            AntiAFKSeconds = AntiAFKSeconds + 1

            if AntiAFKSeconds >= 60 then
                AntiAFKSeconds = 0
                AntiAFKMinutes = AntiAFKMinutes + 1
            end

            if AntiAFKMinutes >= 60 then
                AntiAFKMinutes = 0
                AntiAFKHours = AntiAFKHours + 1
            end

            local timeString = string.format("Temps: %d:%02d:%02d", AntiAFKHours, AntiAFKMinutes, AntiAFKSeconds)
            if AntiAFKGui and AntiAFKGui.Parent then
                TimerLabel.Text = timeString

                -- Couleurs dynamiques selon le temps
                if AntiAFKHours > 0 then
                    TimerLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Or pour les heures
                    StatusIcon.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
                    UIStroke.Color = Color3.fromRGB(255, 215, 0)
                elseif AntiAFKMinutes > 30 then
                    TimerLabel.TextColor3 = Color3.fromRGB(46, 204, 113) -- Vert pour 30+ minutes
                    StatusIcon.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                    UIStroke.Color = Color3.fromRGB(46, 204, 113)
                else
                    TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Blanc par défaut
                    StatusIcon.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                    UIStroke.Color = Color3.fromRGB(46, 204, 113)
                end
            end

            task.wait(1)
        end
    end)

    -- Interface statique sans animations continues pour éviter les conflits
end

local function ToggleAntiAFK(enabled)
    if enabled then
        CreateAntiAFKInterface()

        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())

            pcall(function()
                VirtualUser:Button1Down(Vector2.new(0,0))
                task.wait(0.1)
                VirtualUser:Button1Up(Vector2.new(0,0))
            end)
        end)

        AntiAFKConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)

        spawn(function()
            while AntiAFKEnabled do
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(0,0))
                    task.wait(0.1)
                    VirtualUser:Button1Up(Vector2.new(0,0))

                    VirtualUser:TypeOnKeyboard("")
                end)
                task.wait(45)
            end
        end)

        AntiAFKEnabled = true
        print("Prostone Hub - Anti AFK activé avec succès!")
    else
        if AntiAFKConnection then
            AntiAFKConnection:Disconnect()
            AntiAFKConnection = nil
        end

        if AntiAFKGui then
            getgenv().ProstoneAntiAfkExecuted = false
            getgenv().ProstoneTimerActive = false
            TimerActive = false
            AntiAFKGui:Destroy()
            AntiAFKGui = nil
        end

        AntiAFKSeconds = 0
        AntiAFKMinutes = 0
        AntiAFKHours = 0

        AntiAFKEnabled = false
        print("Prostone Hub - Anti AFK désactivé")
    end
end

local AntiAFKToggle = MainTab:CreateToggle({
    Name = "Anti AFK Prostone Hub",
    CurrentValue = false,
    Flag = "AntiAFKToggle",
    Callback = function(Value)
        ToggleAntiAFK(Value)
    end,
})

local AppearanceSection = MainTab:CreateSection("Apparence")

local RainbowConnection = nil
local IsRainbowEnabled = false
local OriginalClothing = {}
local RemovedAccessories = {}

local function RemoveClothing()
    if not LocalPlayer.Character then return end

    OriginalClothing = {}

    for _, item in pairs(LocalPlayer.Character:GetChildren()) do
        if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
            table.insert(OriginalClothing, {
                item = item:Clone(),
                parent = item.Parent
            })
            item:Destroy()
        end
    end
end

local function RestoreClothing()
    for _, clothingData in pairs(OriginalClothing) do
        if clothingData.parent and clothingData.item then
            clothingData.item.Parent = clothingData.parent
        end
    end
    OriginalClothing = {}
end

local function RemoveSmallParts()
    if not LocalPlayer.Character then return end

    RemovedAccessories = {}

    for _, item in pairs(LocalPlayer.Character:GetChildren()) do
        if item:IsA("Accessory") then
            local isHair = false
            if item:FindFirstChild("Handle") and item.Handle:FindFirstChild("Mesh") then
                local mesh = item.Handle.Mesh
                if mesh:IsA("SpecialMesh") and mesh.MeshId then
                    local attachment = item:FindFirstChild("HairAttachment") or item:FindFirstChild("HatAttachment")
                    if attachment or item.Name:lower():find("hair") or item.AttachmentName == "HairAttachment" then
                        isHair = true
                    end
                end
            end

            if not isHair then
                table.insert(RemovedAccessories, {
                    item = item:Clone(),
                    parent = item.Parent
                })
                item:Destroy()
            end
        end
    end
end

local function RestoreSmallParts()
    for _, accessoryData in pairs(RemovedAccessories) do
        if accessoryData.parent and accessoryData.item then
            accessoryData.item.Parent = accessoryData.parent
        end
    end
    RemovedAccessories = {}
end

local function ModifyFaceTraits(isEnabled)
    if not LocalPlayer.Character then return end

    local head = LocalPlayer.Character:FindFirstChild("Head")
    if not head then return end

    if isEnabled then
        for _, item in pairs(head:GetChildren()) do
            if item:IsA("Decal") and item.Name == "face" then
                item.Color3 = Color3.new(1, 1, 1)
                item.Transparency = 0.3
            end
        end
    else
        for _, item in pairs(head:GetChildren()) do
            if item:IsA("Decal") and item.Name == "face" then
                item.Color3 = Color3.new(1, 1, 1)
                item.Transparency = 0
            end
        end
    end
end

local function ToggleRainbowEffect(enabled)
    if RainbowConnection then
        RainbowConnection:Disconnect()
        RainbowConnection = nil
    end

    if not LocalPlayer.Character then return end

    local mainBodyParts = {}
    local bodyPartNames = {
        "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg",
        "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand",
        "UpperTorso", "LowerTorso", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", 
        "RightUpperLeg", "RightLowerLeg", "RightFoot"
    }

    for _, partName in pairs(bodyPartNames) do
        local part = LocalPlayer.Character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            table.insert(mainBodyParts, part)
        end
    end

    if enabled then
        RemoveClothing()
        RemoveSmallParts()
        ModifyFaceTraits(true)

        RainbowConnection = RunService.Heartbeat:Connect(function()
            local time = tick()
            local hue = (time * 0.3) % 1
            local saturation = 1
            local value = 0.9 + 0.1 * math.sin(time * 3)

            local uniformColor = Color3.fromHSV(hue, saturation, value)
            local uniformTransparency = 0.3 + 0.1 * math.sin(time * 2)

            for _, part in pairs(mainBodyParts) do
                if part and part.Parent then
                    part.Color = uniformColor
                    part.Transparency = uniformTransparency
                end
            end
        end)
        IsRainbowEnabled = true
    else
        for _, part in pairs(mainBodyParts) do
            if part and part.Parent then
                part.Transparency = 0
                part.Color = Color3.new(1, 1, 1)
            end
        end

        RestoreClothing()
        RestoreSmallParts()
        ModifyFaceTraits(false)

        IsRainbowEnabled = false
    end
end

local RainbowToggle = MainTab:CreateToggle({
    Name = "Effet Multicolore Uniforme + Nu",
    CurrentValue = false,
    Flag = "RainbrowToggle",
    Callback = function(Value)
        ToggleRainbowEffect(Value)
    end,
})

local FullbrightSection = MainTab:CreateSection("Éclairage")

local FullbrightButton = MainTab:CreateButton({
    Name = "Fullbright",
    Callback = function()
        pcall(function()
            local Light = game:GetService("Lighting")

            function dofullbright()
                Light.Ambient = Color3.new(1, 1, 1)
                Light.ColorShift_Bottom = Color3.new(1, 1, 1)
                Light.ColorShift_Top = Color3.new(1, 1, 1)
            end

            dofullbright()

            Light.LightingChanged:Connect(dofullbright)

            print("Prostone Hub - Fullbright activé!")
        end)
    end,
})

local TrollTab = Window:CreateTab("Troll", 4483362458)

local TrollScriptsSection = TrollTab:CreateSection("Troll Scripts")

local SpinConnection = nil
local SpinActive = false
local SpinSpeed = 75

local function GetRigType()
    if not LocalPlayer.Character then 
        return "R6"
    end

    local upperTorso = LocalPlayer.Character:FindFirstChild("UpperTorso")
    local lowerTorso = LocalPlayer.Character:FindFirstChild("LowerTorso")

    if upperTorso and lowerTorso then
        return "R15"
    else
        return "R6"
    end
end

local function StartSpinTroll()
    if SpinConnection then
        SpinConnection:Disconnect()
    end

    if not LocalPlayer.Character then return end

    local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.Name = "ProstoneSpinTroll"
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, SpinSpeed, 0)
    bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
    bodyAngularVelocity.Parent = humanoidRootPart

    SpinActive = true

    SpinConnection = RunService.Heartbeat:Connect(function()
        if humanoidRootPart and humanoidRootPart:FindFirstChild("ProstoneSpinTroll") then
            humanoidRootPart.ProstoneSpinTroll.AngularVelocity = Vector3.new(0, SpinSpeed, 0)
        else
            StopSpinTroll()
        end
    end)
end

function StopSpinTroll()
    SpinActive = false

    if SpinConnection then
        SpinConnection:Disconnect()
        SpinConnection = nil
    end

    if LocalPlayer.Character then
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local spinObject = humanoidRootPart:FindFirstChild("ProstoneSpinTroll")
            if spinObject then
                spinObject:Destroy()
            end
        end
    end
end

local BrSaleButton = TrollTab:CreateButton({
    Name = "BR Sale",
    Callback = function()
        pcall(function()
            local rigType = GetRigType()
            print("Prostone Hub - Rig Type détecté: " .. rigType)

            if rigType == "R15" then
                loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
            else
                loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))()
            end

            print("Prostone Hub - BR Sale activé pour " .. rigType)
        end)
    end,
})

local SpinSpeedSlider = TrollTab:CreateSlider({
    Name = "Vitesse de Spin (10-75)",
    Range = {10, 75},
    Increment = 10,
    Suffix = " tours/s",
    CurrentValue = 75,
    Flag = "SpinSpeedSlider",
    Callback = function(Value)
        SpinSpeed = Value
        if SpinActive and LocalPlayer.Character then
            local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local spinObject = humanoidRootPart:FindFirstChild("ProstoneSpinTroll")
                if spinObject then
                    spinObject.AngularVelocity = Vector3.new(0, SpinSpeed, 0)
                end
            end
        end
    end,
})

local SpinTrollToggle = TrollTab:CreateToggle({
    Name = "Spin Troll",
    CurrentValue = false,
    Flag = "SpinTrollToggle",
    Callback = function(Value)
        if Value then
            StartSpinTroll()
        else
            StopSpinTroll()
        end
    end,
})

local TrollInfo = TrollTab:CreateParagraph({
    Title = "Informations Troll", 
    Content = "BR Sale détecte automatiquement votre type de rig (R6/R15). Le Spin Troll fait tourner votre personnage à la vitesse sélectionnée."
})


local SpectateTab = Window:CreateTab("Spectate", 4483362458)

local SpectatingPlayer = nil
local OriginalCameraSubject = nil
local OriginalCameraType = nil
local SpectateConnection = nil
local SpectateCharacterConnection = nil
local AutoRefreshEnabled = true

local SpectateSection = SpectateTab:CreateSection("Spectate Options")

local function GetPlayersList()
    local playersList = {"Aucun"} -- Ajouter option "Aucun" en premier
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Name then
            -- S'assurer que c'est bien un string valide
            local playerName = tostring(player.Name)
            if playerName and playerName ~= "" and playerName ~= "nil" then
                table.insert(playersList, playerName)
            end
        end
    end
    return playersList
end

local function StartSpectating(playerName)
    if not playerName or playerName == "" or type(playerName) ~= "string" or playerName == "Aucun" then 
        print("[DEBUG] Nom de joueur invalide ou 'Aucun' sélectionné: " .. tostring(playerName))
        StopSpectating()
        return 
    end

    local targetPlayer = game.Players:FindFirstChild(playerName)
    if not targetPlayer then
        print("[DEBUG] Joueur introuvable: " .. playerName)
        return
    end

    if targetPlayer == LocalPlayer then
        print("[DEBUG] Cannot spectate yourself")
        return
    end

    -- Si on spectate déjà ce joueur, ne rien faire
    if SpectatingPlayer == targetPlayer then
        print("[DEBUG] Déjà en train de spectate " .. playerName)
        return
    end

    print("[DEBUG] Démarrage du spectate pour: " .. playerName)

    -- Arrêter complètement le spectate précédent
    StopSpectating()

    -- Attendre un peu pour éviter les conflits
    task.wait(0.1)

    -- Sauvegarder les paramètres originaux de la caméra (seulement si pas déjà fait)
    if not OriginalCameraSubject then
        OriginalCameraSubject = workspace.CurrentCamera.CameraSubject
        OriginalCameraType = workspace.CurrentCamera.CameraType
        print("[DEBUG] Caméra originale sauvegardée")
    end

    SpectatingPlayer = targetPlayer

    -- Fonction de mise à jour de la caméra
    local function UpdateSpectateCamera()
        if not SpectatingPlayer or not SpectatingPlayer.Parent then
            print("[DEBUG] Joueur spectateé déconnecté")
            StopSpectating()
            return
        end

        if SpectatingPlayer.Character and SpectatingPlayer.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = SpectatingPlayer.Character.Humanoid
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end
    end

    -- Première mise à jour
    UpdateSpectateCamera()

    -- Connexion pour maintenir le spectate (moins fréquente pour éviter les conflits)
    SpectateConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if SpectatingPlayer and SpectatingPlayer.Parent and SpectatingPlayer.Character then
            if workspace.CurrentCamera.CameraSubject ~= SpectatingPlayer.Character.Humanoid then
                UpdateSpectateCamera()
            end
        else
            StopSpectating()
        end
    end)

    -- Gérer les respawns
    if SpectatingPlayer then
        SpectateCharacterConnection = SpectatingPlayer.CharacterAdded:Connect(function(character)
            task.wait(0.3)
            if SpectatingPlayer then -- Vérifier qu'on spectate toujours ce joueur
                UpdateSpectateCamera()
            end
        end)
    end

    print("Prostone Hub - Spectate activé pour: " .. playerName)
end

function StopSpectating()
    print("[DEBUG] Arrêt du spectate")

    -- Déconnexion de toutes les connexions
    if SpectateConnection then
        SpectateConnection:Disconnect()
        SpectateConnection = nil
        print("[DEBUG] SpectateConnection déconnectée")
    end

    if SpectateCharacterConnection then
        SpectateCharacterConnection:Disconnect()
        SpectateCharacterConnection = nil
        print("[DEBUG] SpectateCharacterConnection déconnectée")
    end

    -- Restauration de la caméra
    if OriginalCameraSubject and OriginalCameraSubject.Parent then
        workspace.CurrentCamera.CameraSubject = OriginalCameraSubject
        print("[DEBUG] Caméra originale restaurée")
    else
        -- Fallback: utiliser le joueur local
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
            print("[DEBUG] Caméra restaurée au joueur local")
        end
    end

    -- Restaurer le type de caméra
    if OriginalCameraType then
        workspace.CurrentCamera.CameraType = OriginalCameraType
        print("[DEBUG] Type de caméra original restauré")
    else
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end

    if SpectatingPlayer then
        print("Prostone Hub - Spectate arrêté pour: " .. SpectatingPlayer.Name)
    end

    -- Reset des variables
    SpectatingPlayer = nil
    OriginalCameraSubject = nil
    OriginalCameraType = nil
end

local SpectatePlayerName = ""

local PlayerInput = SpectateTab:CreateInput({
    Name = "Pseudo du joueur à spectate",
    PlaceholderText = "Tapez le nom du joueur...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        SpectatePlayerName = Text
    end,
})

local StartSpectateButton = SpectateTab:CreateButton({
    Name = "Commencer le Spectate",
    Callback = function()
        if SpectatePlayerName and SpectatePlayerName ~= "" then
            local targetPlayer = game.Players:FindFirstChild(SpectatePlayerName)
            if targetPlayer and targetPlayer ~= LocalPlayer then
                StartSpectating(SpectatePlayerName)
            else
                print("Prostone Hub - Joueur '" .. SpectatePlayerName .. "' introuvable")
            end
        else
            print("Prostone Hub - Veuillez entrer un nom de joueur")
        end
    end,
})

-- Plus besoin de rafraîchissement automatique avec le système de saisie manuelle

local StopSpectateButton = SpectateTab:CreateButton({
    Name = "Arrêter le Spectate",
    Callback = function()
        StopSpectating()
    end,
})

local SpectateInfo = SpectateTab:CreateParagraph({
    Title = "Informations", 
    Content = "Tapez le nom exact du joueur que vous voulez spectate et cliquez sur 'Commencer le Spectate'. La caméra suivra automatiquement le joueur, même s'il respawn."
})

local ESPTab = Window:CreateTab("ESP", 4483362458)

local ESPObjects = {}
local ESPEnabled = false
local NamesEnabled = false
local TeamCheckEnabled = false
local StaffDetectionEnabled = false
local StaffNotificationGui = nil

local ESPSection = ESPTab:CreateSection("ESP Options")

local function CreateStaffNotification(staffPlayerName)
    local StaffNotificationGui = Instance.new("ScreenGui")
    local MainContainer = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")
    local AlertIcon = Instance.new("Frame")
    local IconCorner = Instance.new("UICorner")
    local IconLabel = Instance.new("TextLabel")
    local ContentFrame = Instance.new("Frame")
    local TitleLabel = Instance.new("TextLabel")
    local StaffLabel = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    local CloseCorner = Instance.new("UICorner")
    local LocalizeButton = Instance.new("TextButton")
    local LocalizeCorner = Instance.new("UICorner")

    StaffNotificationGui.Name = "ProStoneStaffAlert"
    StaffNotificationGui.Parent = game.CoreGui
    StaffNotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    StaffNotificationGui.ResetOnSpawn = false

    -- Container principal
    MainContainer.Name = "MainContainer"
    MainContainer.Parent = StaffNotificationGui
    MainContainer.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    MainContainer.BorderSizePixel = 0

    -- Calculer la position en fonction du nombre de notifications existantes
    local notificationCount = 0
    for _, _ in pairs(StaffNotifications) do
        notificationCount = notificationCount + 1
    end

    MainContainer.Position = UDim2.new(1, 10, 0.02 + (notificationCount * 0.12), 0)
    MainContainer.Size = UDim2.new(0, 360, 0, 80)

    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainContainer

    UIStroke.Color = Color3.fromRGB(220, 53, 69)
    UIStroke.Thickness = 2
    UIStroke.Parent = MainContainer

    -- Icône d'alerte
    AlertIcon.Name = "AlertIcon"
    AlertIcon.Parent = MainContainer
    AlertIcon.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    AlertIcon.BorderSizePixel = 0
    AlertIcon.Position = UDim2.new(0, 15, 0.5, -18)
    AlertIcon.Size = UDim2.new(0, 36, 0, 36)

    IconCorner.CornerRadius = UDim.new(0, 18)
    IconCorner.Parent = AlertIcon

    IconLabel.Name = "IconLabel"
    IconLabel.Parent = AlertIcon
    IconLabel.BackgroundTransparency = 1
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.Text = "!"
    IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconLabel.TextScaled = true
    IconLabel.TextStrokeTransparency = 0.5
    IconLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    -- Contenu texte
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainContainer
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 65, 0, 8)
    ContentFrame.Size = UDim2.new(0, 200, 0, 64)

    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = ContentFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.Size = UDim2.new(1, -30, 0, 22)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "STAFF DETECTE"
    TitleLabel.TextColor3 = Color3.fromRGB(220, 53, 69)
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextYAlignment = Enum.TextYAlignment.Center

    StaffLabel.Name = "StaffLabel"
    StaffLabel.Parent = ContentFrame
    StaffLabel.BackgroundTransparency = 1
    StaffLabel.Position = UDim2.new(0, 0, 0, 25)
    StaffLabel.Size = UDim2.new(1, -30, 0, 18)
    StaffLabel.Font = Enum.Font.Gotham
    StaffLabel.Text = "Joueur: " .. staffPlayerName
    StaffLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StaffLabel.TextSize = 12
    StaffLabel.TextXAlignment = Enum.TextXAlignment.Left
    StaffLabel.TextYAlignment = Enum.TextYAlignment.Center

    -- Bouton fermer
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = MainContainer
    CloseButton.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -30, 0, 8)
    CloseButton.Size = UDim2.new(0, 22, 0, 22)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 12

    CloseCorner.CornerRadius = UDim.new(0, 11)
    CloseCorner.Parent = CloseButton

    -- Animation d'entrée
    local slideIn = TweenService:Create(MainContainer, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -330, 0.02, 0)
    })
    slideIn:Play()

    -- Fonction de fermeture
    local function CloseNotification()
        local slideOut = TweenService:Create(MainContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
            Position = UDim2.new(1, 10, MainContainer.Position.Y.Scale, 0)
        })
        slideOut:Play()
        slideOut.Completed:Wait()

        if StaffNotifications[staffPlayerName] then
            StaffNotifications[staffPlayerName] = nil
        end

        if StaffNotificationGui then
            StaffNotificationGui:Destroy()
        end
    end

    CloseButton.MouseButton1Click:Connect(CloseNotification)

    -- Fermeture automatique après 8 secondes
    task.spawn(function()
        task.wait(8)
        if StaffNotifications[staffPlayerName] then
            CloseNotification()
        end
    end)

    return StaffNotificationGui
end

local AutoQuitEnabled = false
local StaffCheckConnection = nil

-- Fonction de vérification périodique des staffs
local function StartStaffMonitoring()
    if StaffCheckConnection then
        StaffCheckConnection:Disconnect()
    end

    StaffCheckConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if StaffDetectionEnabled then
            -- Vérifier les staffs toutes les 2 secondes environ
            local currentTime = tick()
            if not lastStaffCheck or currentTime - lastStaffCheck >= 2 then
                CheckForStaff()
                lastStaffCheck = currentTime
            end
        end
    end)
end

local lastStaffCheck = 0

local StaffNotifications = {}

local function CheckForStaff(silent)
    if not StaffDetectionEnabled and not silent then return end

    local staffDetected = {}
    local currentStaffs = {}

    -- Identifier tous les staffs actuels
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team then
            local teamName = player.Team.Name:lower()
            if teamName:find("staff") or teamName:find("admin") or teamName:find("moderator") or teamName:find("mod") then
                table.insert(staffDetected, {name = player.Name, team = player.Team.Name})
                currentStaffs[player.Name] = true
            end
        end
    end

    -- Fermer les notifications des staffs qui ont quitté
    for staffName, notification in pairs(StaffNotifications) do
        if not currentStaffs[staffName] then
            if notification and notification.Parent then
                notification:Destroy()
            end
            StaffNotifications[staffName] = nil
            print("Prostone Hub - Staff déconnecté: " .. staffName)
        end
    end

    -- Créer des notifications pour les nouveaux staffs
    for _, staff in ipairs(staffDetected) do
        if not silent then
            print("Prostone Hub - Staff détecté: " .. staff.name .. " (Team: " .. staff.team .. ")")

            -- Créer une notification uniquement si elle n'existe pas déjà
            if not StaffNotifications[staff.name] then
                task.spawn(function()
                    local notification = CreateStaffNotification(staff.name)
                    StaffNotifications[staff.name] = notification
                end)
            end
        end
    end

    -- Auto-quit si activé et qu'il y a des staffs
    if not silent and #staffDetected > 0 and AutoQuitEnabled then
        print("Prostone Hub - Auto-quit activé! " .. #staffDetected .. " staff(s) détecté(s). Déconnexion du serveur...")

        -- Créer une notification d'avertissement
        Rayfield:Notify({
            Title = "AUTO-QUIT ACTIVÉ",
            Content = "Staff détecté! Déconnexion en cours...",
            Duration = 3,
            Image = 4483362458,
        })

        task.wait(2) -- Laisser le temps de voir les notifications

        -- Kick du serveur avec message personnalisé
        LocalPlayer:Kick("🚫 PROSTONE HUB - AUTO PROTECTION 🚫\n\n⚠️ Un staff a été détecté dans la partie ⚠️\n\nVous avez été automatiquement déconnecté pour votre sécurité.\n\n🔒 Protection anti-staff activée\n💙 Prostone Hub - discord.gg/RyQFfVrbWR")
    end

    return staffDetected
end

local function CreateESP(player)
    if player == LocalPlayer then return end

    local character = player.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    -- Billboard épuré sans fond
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. player.Name
    billboard.Adornee = humanoidRootPart
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.ZIndexBehavior = Enum.ZIndexBehavior.Global
    billboard.Parent = humanoidRootPart

    -- Label de nom stylé
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.2
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextScaled = false
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextWrapped = true
    nameLabel.ZIndex = 10
    nameLabel.Parent = billboard

    -- Label d'équipe stylé
    local teamLabel = Instance.new("TextLabel")
    teamLabel.Name = "TeamLabel"
    teamLabel.Size = UDim2.new(1, 0, 0.3, 0)
    teamLabel.Position = UDim2.new(0, 0, 0.35, 0)
    teamLabel.BackgroundTransparency = 1
    teamLabel.Text = (player.Team and player.Team.Name or "No Team")
    teamLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    teamLabel.TextStrokeTransparency = 0.3
    teamLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    teamLabel.TextScaled = false
    teamLabel.TextSize = 12
    teamLabel.Font = Enum.Font.Gotham
    teamLabel.TextWrapped = true
    teamLabel.ZIndex = 10
    teamLabel.Parent = billboard

    -- Label de distance stylé
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, 0, 0.25, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.7, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "--- m"
    distanceLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    distanceLabel.TextStrokeTransparency = 0.3
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.TextScaled = false
    distanceLabel.TextSize = 10
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextWrapped = true
    distanceLabel.ZIndex = 10
    distanceLabel.Parent = billboard

    -- Highlight stylé avec contour d'équipe
    local highlight = nil
    pcall(function()
        highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = character
        highlight.FillTransparency = 0.9
        highlight.OutlineTransparency = 0.1
        highlight.FillColor3 = Color3.fromRGB(100, 149, 237)
        highlight.OutlineColor3 = Color3.fromRGB(255, 255, 255)
        highlight.Parent = character
    end)

    -- Mise à jour de la distance en temps réel
    task.spawn(function()
        while ESPObjects[player] and billboard and billboard.Parent do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
               player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                local distanceText = string.format("%.1f m", distance)
                distanceLabel.Text = distanceText

                -- Changer la couleur selon la distance
                if distance < 50 then
                    distanceLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Rouge pour proche
                elseif distance < 100 then
                    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 100) -- Jaune pour moyen
                else
                    distanceLabel.TextColor3 = Color3.fromRGB(150, 255, 150) -- Vert pour loin
                end
            end
            task.wait(0.5) -- Mise à jour toutes les 0.5 secondes
        end
    end)

    ESPObjects[player] = {
        billboard = billboard,
        nameLabel = nameLabel,
        teamLabel = teamLabel,
        distanceLabel = distanceLabel,
        highlight = highlight
    }

    UpdateESP(player)
end

function UpdateESP(player)
    local espObject = ESPObjects[player]
    if not espObject then return end

    local teamColor = Color3.fromRGB(100, 149, 237) -- Couleur par défaut plus esthétique
    local brightTeamColor = Color3.fromRGB(255, 255, 255)
    local contourColor = Color3.fromRGB(255, 255, 255) -- Couleur de contour par défaut

    if player.Team and player.Team.TeamColor then
        teamColor = player.Team.TeamColor.Color
        -- Rendre la couleur plus vive pour l'affichage
        local h, s, v = Color3.toHSV(teamColor)
        brightTeamColor = Color3.fromHSV(h, s, math.min(v + 0.3, 1))
        -- Utiliser la couleur d'équipe pour le contour avec plus de saturation
        contourColor = Color3.fromHSV(h, math.min(s + 0.2, 1), math.min(v + 0.4, 1))
    end

    if TeamCheckEnabled then
        -- Mise à jour des couleurs avec les couleurs d'équipe
        espObject.nameLabel.TextColor3 = brightTeamColor
        espObject.teamLabel.TextColor3 = teamColor

        if espObject.highlight then
            pcall(function()
                espObject.highlight.FillColor3 = teamColor
                espObject.highlight.OutlineColor3 = contourColor -- Contour avec couleur d'équipe
                espObject.highlight.FillTransparency = 0.9
                espObject.highlight.OutlineTransparency = 0.1 -- Contour bien visible
                espObject.highlight.Enabled = true
            end)
        end
        espObject.teamLabel.Text = (player.Team and player.Team.Name or "No Team")
        espObject.teamLabel.Visible = true
    else
        -- Couleurs par défaut élégantes
        espObject.nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        espObject.teamLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

        if espObject.highlight then
            pcall(function()
                espObject.highlight.FillColor3 = Color3.fromRGB(100, 149, 237)
                espObject.highlight.OutlineColor3 = Color3.fromRGB(255, 255, 255)
                espObject.highlight.FillTransparency = 0.9
                espObject.highlight.OutlineTransparency = 0.3
                espObject.highlight.Enabled = NamesEnabled
            end)
        end
        espObject.teamLabel.Visible = false
    end

    -- Visibilité des éléments
    espObject.nameLabel.Visible = NamesEnabled
    espObject.billboard.Enabled = NamesEnabled or TeamCheckEnabled

    if espObject.highlight then
        espObject.highlight.Enabled = NamesEnabled or TeamCheckEnabled
    end
end

local function RemoveESP(player)
    local espObject = ESPObjects[player]
    if espObject then
        if espObject.billboard and espObject.billboard.Parent then
            espObject.billboard:Destroy()
        end
        if espObject.highlight and espObject.highlight.Parent then
            espObject.highlight:Destroy()
        end
        ESPObjects[player] = nil
    end
end

local function RefreshESP()
    for player, _ in pairs(ESPObjects) do
        RemoveESP(player)
    end

    if NamesEnabled or TeamCheckEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESP(player)
            end
        end
    end
end

local NamesToggle = ESPTab:CreateToggle({
    Name = "Voir les noms",
    CurrentValue = false,
    Flag = "NamesToggle",
    Callback = function(Value)
        NamesEnabled = Value
        RefreshESP()
    end,
})

local TeamCheckToggle = ESPTab:CreateToggle({
    Name = "Team Check + Color",
    CurrentValue = false,
    Flag = "TeamCheckToggle",
    Callback = function(Value)
        TeamCheckEnabled = Value
        RefreshESP()
    end,
})

local StaffDetectSection = ESPTab:CreateSection("Staff Detect")

local StaffDetectionToggle = ESPTab:CreateToggle({
    Name = "Détection Staff",
    CurrentValue = false,
    Flag = "StaffDetectionToggle",
    Callback = function(Value)
        StaffDetectionEnabled = Value
        if Value then
            CheckForStaff()
        else
            -- Fermer toutes les notifications de staff
            for staffName, notification in pairs(StaffNotifications) do
                if notification and notification.Parent then
                    notification:Destroy()
                end
            end
            StaffNotifications = {}
        end
    end,
})

local AutoQuitToggle = ESPTab:CreateToggle({
    Name = "Auto-Quit si Staff détecté",
    CurrentValue = false,
    Flag = "AutoQuitToggle",
    Callback = function(Value)
        AutoQuitEnabled = Value
        if Value then
            print("Prostone Hub - Auto-quit activé! Le jeu se fermera si un staff est détecté.")
        else
            print("Prostone Hub - Auto-quit désactivé.")
        end
    end,
})

local CheckStaffButton = ESPTab:CreateButton({
    Name = "Vérifier les Staffs maintenant",
    Callback = function()
        local staffList = CheckForStaff(true) -- Mode silencieux

        if #staffList > 0 then
            local message = "STAFFS DÉTECTÉS:\n"
            for _, staff in ipairs(staffList) do
                message = message .. "- " .. staff.name .. " (" .. staff.team .. ")\n"
            end
            print(message)

            -- Créer une notification spéciale pour le check manuel
            Rayfield:Notify({
                Title = "Staff Détectés",
                Content = #staffList .. " staff(s) trouvé(s) dans la partie!",
                Duration = 5,
                Image = 4483362458,
            })
        else
            print("Prostone Hub - Aucun staff détecté dans la partie.")
            Rayfield:Notify({
                Title = "Vérification Staff",
                Content = "Aucun staff détecté dans la partie.",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

local VisualizeStaffButton = ESPTab:CreateButton({
    Name = "Localiser Staff visuellement",
    Callback = function()
        -- Fonction pour créer un marqueur visuel sur le staff
        local function CreateStaffMarker(staffPlayer)
            if not staffPlayer or not staffPlayer.Character or not staffPlayer.Character:FindFirstChild("HumanoidRootPart") then
                return
            end

            local character = staffPlayer.Character
            local humanoidRootPart = character.HumanoidRootPart

            -- Créer un gros highlight rouge clignotant
            local highlight = Instance.new("Highlight")
            highlight.Name = "StaffMarker"
            highlight.Adornee = character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
            highlight.FillTransparency = 0.3
            highlight.OutlineTransparency = 0
            highlight.Parent = character

            -- Créer une grosse sphère rouge au-dessus du staff
            local sphere = Instance.new("Part")
            sphere.Name = "StaffMarkerSphere"
            sphere.Shape = Enum.PartType.Ball
            sphere.Material = Enum.Material.Neon
            sphere.Size = Vector3.new(8, 8, 8)
            sphere.Color = Color3.fromRGB(255, 0, 0)
            sphere.Anchored = true
            sphere.CanCollide = false
            sphere.Position = humanoidRootPart.Position + Vector3.new(0, 15, 0)
            sphere.Parent = workspace

            -- Créer un GUI au-dessus du staff
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "StaffMarkerGUI"
            billboard.Adornee = humanoidRootPart
            billboard.Size = UDim2.new(0, 400, 0, 100)
            billboard.StudsOffset = Vector3.new(0, 8, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = humanoidRootPart

            local warningLabel = Instance.new("TextLabel")
            warningLabel.Size = UDim2.new(1, 0, 1, 0)
            warningLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            warningLabel.BackgroundTransparency = 0.2
            warningLabel.BorderSizePixel = 3
            warningLabel.BorderColor3 = Color3.fromRGB(255, 255, 0)
            warningLabel.Text = "⚠️ STAFF DÉTECTÉ ⚠️\n" .. staffPlayer.Name
            warningLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            warningLabel.TextStrokeTransparency = 0
            warningLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            warningLabel.TextScaled = true
            warningLabel.Font = Enum.Font.GothamBold
            warningLabel.Parent = billboard

            -- Animation de clignotement
            local blinkConnection
            blinkConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local time = tick()
                local alpha = (math.sin(time * 10) + 1) / 2 -- Valeur entre 0 et 1

                if highlight and highlight.Parent then
                    highlight.FillTransparency = 0.1 + (alpha * 0.4)
                    highlight.OutlineTransparency = alpha * 0.3
                end

                if sphere and sphere.Parent then
                    sphere.Transparency = alpha * 0.5
                    sphere.Position = humanoidRootPart.Position + Vector3.new(0, 15 + math.sin(time * 5) * 3, 0)
                end

                if warningLabel and warningLabel.Parent then
                    warningLabel.BackgroundTransparency = 0.1 + (alpha * 0.4)
                end
            end)

            -- Supprimer les marqueurs après 3 secondes
            task.spawn(function()
                task.wait(3)

                if blinkConnection then
                    blinkConnection:Disconnect()
                end

                if highlight and highlight.Parent then
                    highlight:Destroy()
                end

                if sphere and sphere.Parent then
                    sphere:Destroy()
                end

                if billboard and billboard.Parent then
                    billboard:Destroy()
                end
            end)

            print("Prostone Hub - Marqueur visuel créé sur le staff: " .. staffPlayer.Name)
        end

        -- Chercher tous les staffs actuellement connectés
        local staffFound = false

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team then
                local teamName = player.Team.Name:lower()
                if teamName:find("staff") or teamName:find("admin") or teamName:find("moderator") or teamName:find("mod") then
                    if player.Character then
                        CreateStaffMarker(player)
                        staffFound = true
                        print("Prostone Hub - Marqueur créé sur le staff: " .. player.Name)
                    end
                end
            end
        end

        if staffFound then
            Rayfield:Notify({
                Title = "Marqueurs Staff",
                Content = "Marqueurs visuels créés sur les staffs présents!",
                Duration = 3,
                Image = 4483362458,
            })
        else
            print("Prostone Hub - Aucun staff détecté ou staff déconnecté")
            Rayfield:Notify({
                Title = "Localisation Staff",
                Content = "Aucun staff détecté dans la partie.",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

local AntiCheatTab = Window:CreateTab("Anti Cheat", 4483362458)

local AntiCheatSection = AntiCheatTab:CreateSection("Anti Cheat Options")

local AdonisButton = AntiCheatTab:CreateButton({
    Name = "Adonis",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/e1998ee/adonisb1p3ss/refs/heads/main/NeptuneScripts"))()
        end)
    end,
})

-- Variable pour tracker si le bypass a déjà été effectué avec succès
local BypassACPAlreadyDone = false

local BypassACPButton = AntiCheatTab:CreateButton({
    Name = "Bypass ACP",
    Callback = function()
        pcall(function()
            -- Vérifier si le bypass a déjà été fait avec succès
            if BypassACPAlreadyDone then
                Rayfield:Notify({
                    Title = "Bypass ACP",
                    Content = "mais mon reuf ta deja bypass",
                    Duration = 5,
                    Image = 4483362458,
                })
                print("Prostone Hub - Bypass ACP déjà effectué!")
                return
            end

            local success = false
            local webhookRemotes = {}

            -- Fonction récursive pour chercher les RemoteEvents nommés "Webhook"
            local function searchWebhookRemotes(parent)
                for _, child in pairs(parent:GetChildren()) do
                    if child:IsA("RemoteEvent") and child.Name == "Webhook" then
                        table.insert(webhookRemotes, child)
                    elseif child:IsA("Folder") or child:IsA("Model") then
                        searchWebhookRemotes(child)
                    end
                end
            end

            -- Chercher dans ReplicatedStorage
            if game:GetService("ReplicatedStorage") then
                searchWebhookRemotes(game:GetService("ReplicatedStorage"))
            end

            -- Chercher dans Workspace
            if workspace then
                searchWebhookRemotes(workspace)
            end

            -- Chercher dans StarterPlayer
            if game:GetService("StarterPlayer") then
                searchWebhookRemotes(game:GetService("StarterPlayer"))
            end

            -- Bloquer les RemoteEvents trouvés
            if #webhookRemotes > 0 then
                for _, remote in pairs(webhookRemotes) do
                    -- Méthode 1: Détruire le RemoteEvent
                    pcall(function()
                        remote:Destroy()
                    end)

                    -- Méthode 2: Remplacer la fonction FireServer
                    pcall(function()
                        remote.FireServer = function() end
                    end)

                    -- Méthode 3: Créer un hook qui bloque les appels
                    pcall(function()
                        local oldFireServer = remote.FireServer
                        remote.FireServer = function(...)
                            -- Bloquer l'appel en ne faisant rien
                            return
                        end
                    end)
                end
                success = true
                print("Prostone Hub - " .. #webhookRemotes .. " RemoteEvent(s) 'Webhook' bloqué(s)")
            end

            -- Afficher le résultat
            if success then
                -- Marquer que le bypass a été effectué avec succès
                BypassACPAlreadyDone = true

                Rayfield:Notify({
                    Title = "Bypass ACP",
                    Content = "gg c good fais ce que tu veux",
                    Duration = 5,
                    Image = 4483362458,
                })
                print("Prostone Hub - Bypass ACP réussi!")
            else
                Rayfield:Notify({
                    Title = "Bypass ACP",
                    Content = "t sur un executeur nul la honte",
                    Duration = 5,
                    Image = 4483362458,
                })
                print("Prostone Hub - Bypass ACP échoué - Aucun RemoteEvent 'Webhook' trouvé")
            end
        end)
    end,
})

local WarningParagraph = AntiCheatTab:CreateParagraph({
    Title = "Avertissement", 
    Content = "Ce script ne fonctionne pas avec Xeno, JJSploit et Solara."
})

-- ONGLET SCRIPTS EXTERNES - DEPLACE A LA FIN
local TargetTab = Window:CreateTab("Target", 4483362458)

local TargetSection = TargetTab:CreateSection("Target Options")

local TargetedPlayer = nil
local TargetColleActive = false
local TargetColleConnection = nil

local function GetTargetPlayersList()
    local playersList = {"Aucun"}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Name then
            local playerName = tostring(player.Name)
            if playerName and playerName ~= "" and playerName ~= "nil" then
                table.insert(playersList, playerName)
            end
        end
    end
    return playersList
end

local function TeleportBehindTarget()
    if not TargetedPlayer or not TargetedPlayer.Parent then
        return false
    end

    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end

    if not TargetedPlayer.Character or not TargetedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end

    local targetHRP = TargetedPlayer.Character.HumanoidRootPart
    local myHRP = LocalPlayer.Character.HumanoidRootPart

    -- Calculer la position derrière le joueur ciblé
    local targetCFrame = targetHRP.CFrame
    local behindPosition = targetCFrame * CFrame.new(0, 0, 2) -- 2 studs derrière

    -- Téléporter le joueur
    myHRP.CFrame = behindPosition

    return true
end

local function StartTargetColle()
    if not TargetedPlayer then
        print("Prostone Hub - Aucun joueur ciblé")
        return
    end

    if TargetColleConnection then
        TargetColleConnection:Disconnect()
    end

    TargetColleActive = true
    print("Prostone Hub - Target Collé activé pour: " .. TargetedPlayer.Name)

    TargetColleConnection = RunService.Heartbeat:Connect(function()
        if TargetColleActive and TargetedPlayer then
            local success = TeleportBehindTarget()
            if not success then
                -- Si la téléportation échoue, arrêter le target collé
                StopTargetColle()
            end
        else
            StopTargetColle()
        end
    end)
end

local function StopTargetColle()
    TargetColleActive = false

    if TargetColleConnection then
        TargetColleConnection:Disconnect()
        TargetColleConnection = nil
    end

    if TargetedPlayer then
        print("Prostone Hub - Target Collé désactivé pour: " .. TargetedPlayer.Name)
    else
        print("Prostone Hub - Target Collé désactivé")
    end
end

local TargetPlayerName = ""

local TargetInput = TargetTab:CreateInput({
    Name = "Pseudo du joueur à cibler",
    PlaceholderText = "Tapez le nom du joueur...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        TargetPlayerName = Text
        if Text and Text ~= "" then
            local targetPlayer = game.Players:FindFirstChild(Text)
            if targetPlayer and targetPlayer ~= LocalPlayer then
                TargetedPlayer = targetPlayer
                print("Prostone Hub - Joueur ciblé: " .. Text)
            else
                TargetedPlayer = nil
                print("Prostone Hub - Joueur '" .. Text .. "' introuvable")
            end
        else
            TargetedPlayer = nil
        end
    end,
})

local TargetColleToggle = TargetTab:CreateToggle({
    Name = "Target Collé (Auto TP)",
    CurrentValue = false,
    Flag = "TargetColleToggle",
    Callback = function(Value)
        if Value then
            if TargetPlayerName and TargetPlayerName ~= "" then
                -- Vérifier à nouveau si le joueur existe au moment du clic
                local targetPlayer = game.Players:FindFirstChild(TargetPlayerName)
                if targetPlayer and targetPlayer ~= LocalPlayer then
                    TargetedPlayer = targetPlayer
                    StartTargetColle()
                else
                    print("Prostone Hub - Joueur '" .. TargetPlayerName .. "' introuvable ou déconnecté")
                    -- Désactiver le toggle si le joueur n'existe pas
                    TargetColleToggle:Set(false)
                end
            else
                print("Prostone Hub - Veuillez entrer un nom de joueur")
                -- Désactiver le toggle si aucun nom n'est entré
                TargetColleToggle:Set(false)
            end
        else
            StopTargetColle()
        end
    end,
})

local TargetInfo = TargetTab:CreateParagraph({
    Title = "Informations Target", 
    Content = "Tapez le nom exact du joueur et activez 'Target Collé' pour vous téléporter automatiquement derrière lui en continu. Désactivez le toggle pour arrêter la téléportation."
})

-- Plus besoin de rafraîchissement automatique avec le système de saisie manuelle

local ExternalScriptsTab = Window:CreateTab("Scripts Externes", 4483362458)

local PopularScriptsSection = ExternalScriptsTab:CreateSection("Scripts Populaires")

local OrcaButton = ExternalScriptsTab:CreateButton({
    Name = "Orca Script",
    Callback = function()
        pcall(function()
            loadstring(
                game:HttpGetAsync("https://raw.githubusercontent.com/richie0866/orca/master/public/latest.lua")
            )()
        end)
    end,
})

local InfiniteYieldButton = ExternalScriptsTab:CreateButton({
    Name = "Infinite Yield",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end)
    end,
})

local DexButton = ExternalScriptsTab:CreateButton({
    Name = "DEX Explorer",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/dex.lua'))()
        end)
    end,
})



local ScriptsInfoSection = ExternalScriptsTab:CreateSection("Informations")

local ScriptsInfo = ExternalScriptsTab:CreateParagraph({
    Title = "À propos des Scripts Externes", 
    Content = "Ces scripts sont des outils populaires de la communauté Roblox. Utilisez-les à vos propres risques. Certains peuvent ne pas fonctionner sur tous les jeux ou exécuteurs."
})

local isUIVisible = true
local RayfieldKeybind = Enum.KeyCode.G

pcall(function()
    if Rayfield and Rayfield.SetKeybind then
        Rayfield:SetKeybind(RayfieldKeybind)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.KeyCode == RayfieldKeybind then
        pcall(function()
            if Rayfield then
                isUIVisible = not isUIVisible
                local rayfieldGui = game.CoreGui:FindFirstChild("Rayfield")
                if rayfieldGui then
                    local mainFrame = rayfieldGui:FindFirstChild("Main")
                    if mainFrame then
                        mainFrame.Visible = isUIVisible
                    end
                end
            end
        end)
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if NamesEnabled or TeamCheckEnabled then
            CreateESP(player)
        end
    end)

    player:GetPropertyChangedSignal("Team"):Connect(function()
        if ESPObjects[player] then
            UpdateESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)

    if SpectatingPlayer == player then
        StopSpectating()
    end

    if TargetedPlayer == player then
        StopTargetColle()
        TargetedPlayer = nil
        print("Prostone Hub - Joueur ciblé déconnecté")
        -- Désactiver le toggle
        if TargetColleToggle then
            TargetColleToggle:Set(false)
        end
    end

    -- Plus besoin de mettre à jour les dropdowns
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedSlider.CurrentValue
    end

    if IsRainbowEnabled then
        task.wait(0.5)
        ToggleRainbowEffect(true)
    end

    if SpinActive then
        StopSpinTroll()
    end

    if not SpectatingPlayer and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            Camera.CameraSubject = humanoid
        end
    end
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        if NamesEnabled or TeamCheckEnabled then
            CreateESP(player)
        end
    end

    player.CharacterAdded:Connect(function()
        task.wait(1)
        if NamesEnabled or TeamCheckEnabled then
            CreateESP(player)
        end
    end)

    player:GetPropertyChangedSignal("Team"):Connect(function()
        if ESPObjects[player] then
            UpdateESP(player)
        end
    end)
end

game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        for otherPlayer, _ in pairs(ESPObjects) do
            RemoveESP(otherPlayer)
        end

        StopSpectating()

        StopSpinTroll()

        StopTargetColle()

        if AntiAFKGui then
            getgenv().ProstoneAntiAfkExecuted = false
            getgenv().ProstoneTimerActive = false
            AntiAFKGui:Destroy()
        end
    end
end)

-- Démarrer le monitoring des staffs
StartStaffMonitoring()

print("Prostone Hub - Schibuya RP chargé avec succès!")
print("Discord: discord.gg/RyQFfVrbWR")
