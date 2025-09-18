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
    LoadingTitle = "t une slp fdp ...",
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
    local MainFrame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local CloseButton = Instance.new("TextButton")
    local TitleLabel = Instance.new("TextLabel")
    local TimerLabel = Instance.new("TextLabel")
    local PingTitleLabel = Instance.new("TextLabel")
    local FPSLabel = Instance.new("TextLabel")
    local FPSTitleLabel = Instance.new("TextLabel")
    local PingLabel = Instance.new("TextLabel")
    local Separator = Instance.new("Frame")
    local SeparatorUICorner = Instance.new("UICorner")
    local StatusLabel = Instance.new("TextLabel")
    local CreditsLabel = Instance.new("TextLabel")

    AntiAFKGui.Name = "ProstoneAntiAfkGui"
    AntiAFKGui.Parent = game.CoreGui
    AntiAFKGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = AntiAFKGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.02, 0, 0.02, 0)
    MainFrame.Size = UDim2.new(0, 200, 0, 80)

    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    CloseButton.Name = "CloseButton"
    CloseButton.Parent = MainFrame
    CloseButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    CloseButton.BackgroundTransparency = 0
    CloseButton.Position = UDim2.new(0.85, 0, 0.05, 0)
    CloseButton.Size = UDim2.new(0, 20, 0, 16)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 12
    CloseButton.TextStrokeTransparency = 0
    CloseButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    local CloseUICorner = Instance.new("UICorner")
    CloseUICorner.CornerRadius = UDim.new(0, 6)
    CloseUICorner.Parent = CloseButton

    CloseButton.MouseButton1Click:Connect(function()
        getgenv().ProstoneAntiAfkExecuted = false
        getgenv().ProstoneTimerActive = false
        TimerActive = false
        AntiAFKGui:Destroy()
        AntiAFKGui = nil
    end)

    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = MainFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
    TitleLabel.Size = UDim2.new(0.7, 0, 0.3, 0)
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.Text = "Prostone - Anti AFK"
    TitleLabel.TextColor3 = Color3.fromRGB(100, 149, 237)
    TitleLabel.TextSize = 12
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    TimerLabel.Name = "TimerLabel"
    TimerLabel.Parent = MainFrame
    TimerLabel.BackgroundTransparency = 1
    TimerLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
    TimerLabel.Size = UDim2.new(0.45, 0, 0.3, 0)
    TimerLabel.Font = Enum.Font.SourceSansBold
    TimerLabel.Text = "0:00:00"
    TimerLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
    TimerLabel.TextSize = 11
    TimerLabel.TextXAlignment = Enum.TextXAlignment.Left

    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0.55, 0, 0.35, 0)
    StatusLabel.Size = UDim2.new(0.4, 0, 0.3, 0)
    StatusLabel.Font = Enum.Font.SourceSans
    StatusLabel.Text = "Actif"
    StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
    StatusLabel.TextSize = 10
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

    CreditsLabel.Name = "CreditsLabel"
    CreditsLabel.Parent = MainFrame
    CreditsLabel.BackgroundTransparency = 1
    CreditsLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
    CreditsLabel.Size = UDim2.new(0.9, 0, 0.25, 0)
    CreditsLabel.Font = Enum.Font.SourceSans
    CreditsLabel.Text = "Prostone Hub"
    CreditsLabel.TextColor3 = Color3.fromRGB(149, 165, 166)
    CreditsLabel.TextSize = 9
    CreditsLabel.TextXAlignment = Enum.TextXAlignment.Center

    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function updateDrag(input)
        local delta = input.Position - dragStart
        local dragTime = 0.04
        local targetPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        
        local dragTween = TweenService:Create(MainFrame, TweenInfo.new(dragTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = targetPosition})
        dragTween:Play()
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and MainFrame.Size then
            updateDrag(input)
        end
    end)

    MainFrame.BackgroundTransparency = 1
    for _, child in pairs(MainFrame:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            child.TextTransparency = 1
        end
    end

    local fadeInTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0})
    fadeInTween:Play()

    for _, child in pairs(MainFrame:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            local textTween = TweenService:Create(child, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {TextTransparency = 0})
            textTween:Play()
        end
    end

    TimerActive = true
    getgenv().ProstoneTimerActive = true
    
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
            
            local timeString = string.format("%d:%02d:%02d", AntiAFKHours, AntiAFKMinutes, AntiAFKSeconds)
            if AntiAFKGui and AntiAFKGui.Parent then
                TimerLabel.Text = "⏱️ " .. timeString
                
                if AntiAFKHours > 0 then
                    TimerLabel.TextColor3 = Color3.fromRGB(241, 196, 15)
                elseif AntiAFKMinutes > 30 then
                    TimerLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
                else
                    TimerLabel.TextColor3 = Color3.fromRGB(52, 152, 219)
                end
            end
            
            wait(1)
        end
    end)

    spawn(function()
        while getgenv().ProstoneAntiAfkExecuted and AntiAFKGui do
            local pulseTween1 = TweenService:Create(StatusLabel, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0.4})
            local pulseTween2 = TweenService:Create(StatusLabel, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0})
            
            pulseTween1:Play()
            pulseTween1.Completed:Wait()
            pulseTween2:Play()
            pulseTween2.Completed:Wait()
        end
    end)
end

local function ToggleAntiAFK(enabled)
    if enabled then
        CreateAntiAFKInterface()
        
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            
            pcall(function()
                VirtualUser:Button1Down(Vector2.new(0,0))
                wait(0.1)
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
                    wait(0.1)
                    VirtualUser:Button1Up(Vector2.new(0,0))
                    
                    VirtualUser:TypeOnKeyboard("")
                end)
                wait(45)
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
    Flag = "RainbowToggle",
    Callback = function(Value)
        ToggleRainbowEffect(Value)
    end,
})

local TrollTab = Window:CreateTab("Troll", 4483362458)

local TrollScriptsSection = TrollTab:CreateSection("Troll Scripts")

local SpinConnection = nil
local SpinActive = false
local SpinSpeed = 100

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
    Name = "Vitesse de Spin (10-500)",
    Range = {10, 500},
    Increment = 10,
    Suffix = " tours/s",
    CurrentValue = 100,
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

local UtilityScriptsSection = ExternalScriptsTab:CreateSection("Scripts Utiles")

local RemoteSpyButton = ExternalScriptsTab:CreateButton({
    Name = "Remote Spy",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua'))()
        end)
    end,
})

local ServerHopperButton = ExternalScriptsTab:CreateButton({
    Name = "Server Hopper",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/LeoKholYt/roblox/main/lk_serverhop.lua'))()
        end)
    end,
})

local FPSBoosterButton = ExternalScriptsTab:CreateButton({
    Name = "FPS Booster",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/FPSBooster.lua'))()
        end)
    end,
})

local ScriptsInfoSection = ExternalScriptsTab:CreateSection("Informations")

local ScriptsInfo = ExternalScriptsTab:CreateParagraph({
    Title = "À propos des Scripts Externes", 
    Content = "Ces scripts sont des outils populaires de la communauté Roblox. Utilisez-les à vos propres risques. Certains peuvent ne pas fonctionner sur tous les jeux ou exécuteurs."
})

local SpectateTab = Window:CreateTab("Spectate", 4483362458)

local SpectatingPlayer = nil
local OriginalCameraSubject = nil
local SpectateConnection = nil

local SpectateSection = SpectateTab:CreateSection("Spectate Options")

local function GetPlayersList()
    local playersList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playersList, player.Name)
        end
    end
    return playersList
end

local function StartSpectating(playerName)
    if not playerName or playerName == "" then return end
    
    local targetPlayer = Players:FindFirstChild(playerName)
    if not targetPlayer or targetPlayer == LocalPlayer then return end
    
    StopSpectating()
    
    if not OriginalCameraSubject then
        OriginalCameraSubject = Camera.CameraSubject
    end
    
    SpectatingPlayer = targetPlayer
    
    local function UpdateCamera()
        pcall(function()
            if SpectatingPlayer and SpectatingPlayer.Character then
                local humanoid = SpectatingPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    Camera.CameraSubject = humanoid
                    Camera.CameraType = Enum.CameraType.Custom
                end
            end
        end)
    end
    
    UpdateCamera()
    
    SpectateConnection = RunService.Heartbeat:Connect(function()
        if SpectatingPlayer and SpectatingPlayer.Parent then
            UpdateCamera()
        else
            StopSpectating()
        end
    end)
    
    if SpectatingPlayer then
        SpectatingPlayer.CharacterAdded:Connect(function()
            wait(1)
            if SpectatingPlayer then
                UpdateCamera()
            end
        end)
    end
end

function StopSpectating()
    pcall(function()
        if OriginalCameraSubject then
            Camera.CameraSubject = OriginalCameraSubject
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = LocalPlayer.Character.Humanoid
            end
        end
        
        Camera.CameraType = Enum.CameraType.Custom
        
        if SpectateConnection then
            SpectateConnection:Disconnect()
            SpectateConnection = nil
        end
        
        SpectatingPlayer = nil
        OriginalCameraSubject = nil
    end)
end

local PlayerDropdown = SpectateTab:CreateDropdown({
    Name = "Sélectionner un joueur",
    Options = GetPlayersList(),
    CurrentOption = "",
    Flag = "SpectatePlayerDropdown",
    Callback = function(Option)
        if Option and Option ~= "" then
            StartSpectating(Option)
        end
    end,
})

local RefreshButton = SpectateTab:CreateButton({
    Name = "Rafraîchir la liste",
    Callback = function()
        PlayerDropdown:Set(GetPlayersList())
    end,
})

local StopSpectateButton = SpectateTab:CreateButton({
    Name = "Arrêter le Spectate",
    Callback = function()
        StopSpectating()
    end,
})

local SpectateInfo = SpectateTab:CreateParagraph({
    Title = "Informations", 
    Content = "Sélectionnez un joueur pour commencer à le spectate. La caméra suivra automatiquement le joueur sélectionné, même s'il respawn."
})

local ESPTab = Window:CreateTab("ESP", 4483362458)

local ESPObjects = {}
local ESPEnabled = false
local NamesEnabled = false
local TeamCheckEnabled = false

local ESPSection = ESPTab:CreateSection("ESP Options")

local function CreateESP(player)
    if player == LocalPlayer then return end

    local character = player.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. player.Name
    billboard.Adornee = humanoidRootPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = humanoidRootPart

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Parent = billboard

    local teamLabel = Instance.new("TextLabel")
    teamLabel.Name = "TeamLabel"
    teamLabel.Size = UDim2.new(1, 0, 0.5, 0)
    teamLabel.Position = UDim2.new(0, 0, 0.5, 0)
    teamLabel.BackgroundTransparency = 1
    teamLabel.Text = player.Team and player.Team.Name or "No Team"
    teamLabel.TextColor3 = Color3.new(1, 1, 1)
    teamLabel.TextStrokeTransparency = 0
    teamLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    teamLabel.TextScaled = true
    teamLabel.Font = Enum.Font.SourceSans
    teamLabel.Parent = billboard

    local highlight = nil
    pcall(function()
        highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = character
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = character
    end)

    ESPObjects[player] = {
        billboard = billboard,
        nameLabel = nameLabel,
        teamLabel = teamLabel,
        highlight = highlight
    }

    UpdateESP(player)
end

function UpdateESP(player)
    local espObject = ESPObjects[player]
    if not espObject then return end

    local teamColor = Color3.new(1, 1, 1)
    if player.Team and player.Team.TeamColor then
        teamColor = player.Team.TeamColor.Color
    end

    if TeamCheckEnabled then
        espObject.nameLabel.TextColor3 = teamColor
        espObject.teamLabel.TextColor3 = teamColor
        if espObject.highlight then
            pcall(function()
                espObject.highlight.FillColor3 = teamColor
                espObject.highlight.OutlineColor3 = teamColor
                espObject.highlight.Enabled = true
            end)
        end
        espObject.teamLabel.Text = player.Team and player.Team.Name or "No Team"
        espObject.teamLabel.Visible = true
    else
        espObject.nameLabel.TextColor3 = Color3.new(1, 1, 1)
        espObject.teamLabel.TextColor3 = Color3.new(1, 1, 1)
        if espObject.highlight then
            pcall(function()
                espObject.highlight.FillColor3 = Color3.new(1, 1, 1)
                espObject.highlight.OutlineColor3 = Color3.new(1, 1, 1)
                espObject.highlight.Enabled = NamesEnabled
            end)
        end
        espObject.teamLabel.Visible = false
    end

    espObject.nameLabel.Visible = NamesEnabled
    
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

local WarningParagraph = AntiCheatTab:CreateParagraph({
    Title = "Avertissement", 
    Content = "Ce script ne fonctionne pas avec Xeno, JJSploit et Solara."
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
        wait(1)
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
    
    pcall(function()
        PlayerDropdown:Set(GetPlayersList())
    end)
end)

LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedSlider.CurrentValue
    end
    
    if IsRainbowEnabled then
        wait(0.5)
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
        wait(1)
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
        
        if AntiAFKGui then
            getgenv().ProstoneAntiAfkExecuted = false
            getgenv().ProstoneTimerActive = false
            AntiAFKGui:Destroy()
        end
    end
end)

print("Prostone Hub - Schibuya RP chargé avec succès!")
print("Discord: discord.gg/RyQFfVrbWR")
