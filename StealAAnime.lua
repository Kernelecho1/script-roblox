-- Steal a Noob TP Script - Version Corrigée
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Chargement de Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Variables globales
local walkSpeed = 23 -- Vitesse initiale modifiée
local savedWalkSpeed = 22 -- Vitesse initiale modifiée
local maxWalkSpeed = 1000 -- Limite de vitesse modifiée
local instantProxActive = false
local currentPlayerType = "Ayere"
local playerTypes = {"GRIFFENFERW", "GiusGiuz24", "lu_nettes", "SHINOBIDUWEB", "Jessim3838", "le_gamerdu67lenoob", "Toy_bonnieimran", "UltraInstinctGaku", "SangWoo", "SunJinWoo", "LoffyGear5", "NarotoKyoby", "ModoraRikudo", "DakuVigilant", "GakuDaima", "Speekillue", "Rangaku", "Itochianbu", "Mehogere", "Mazun", "BlackGaku", "Sakuna", "Gogete", "NarotoHokega", "Gohen", "Marin", "Modora", "Tajo", "Friaran", "Gorp", "Obita", "Shinobe", "Igros", "Kirita", "Zanitsa", "Reger", "Bachera", "Kakashibo", "Gaja", "Roblucci", "Tangan", "Braly", "Mikuma", "Matsura", "Konen", "Dome", "Obene", "Akeza", "Satana", "IgrosOmbre", "Yute", "Itochi", "Keneo", "Shodow", "Muichara", "Gomomaru", "ZaraEggHead", "Saske", "Vagete", "Nazeko", "Kasame", "Ichiga", "Kekeshi", "NomiEgg", "Koiser", "Ruda", "Sarede", "Shadou", "Meguma", "MamaAyasa", "Makasa", "Nomi", "Gan", "Chagari", "Gaku", "Aren", "Killue", "Loffy", "Ayere", "Tanjoro"}
local instantProxConnection = nil



-- Vérification vitesse continue
local speedCheckConnection = nil

-- Variables Auto Buy
local autoBuyActive = false
local selectedAutoBuyItems = {}
local autoBuyItems = {"Tanjoro", "Killue", "Loffy", "Ayere", "Aren", "Gaku", "Chagari", "Gan", "Nomi", "Makasa", "MamaAyasa", "Meguma", "Shadou", "Sarede", "Ruda", "Koiser", "NomiEgg", "Kekeshi", "Ichiga", "Kasame", "Nazeko", "Vagete", "Saske", "Muichara", "Gomomaru", "ZaraEggHead", "Itochi", "Keneo", "Shodow", "Satana", "IgrosOmbre", "Yute", "Sakuna", "Gogete", "NarotoHokega", "Gohen", "Marin", "Modora", "BlackGaku", "Akeza", "Tajo", "Friaran", "Gorp", "Obita", "Shinobe", "Igros", "Kirita", "Zanitsa", "Reger", "Bachera", "Kakashibo", "ModoraRikudo", "DakuVigilant", "LoffyGear5", "NarotoKyoby", "Mehogere", "Mazun", "UltraInstinctGaku", "SangWoo", "SunJinWoo", "Gaja", "Roblucci", "Tangan", "Braly", "Mikuma", "Matsura", "Konen", "Dome", "Obene", "GakuDaima", "Speekillue", "Rangaku", "Itochianbu", "GiusGiuz24", "lu_nettes", "SHINOBIDUWEB", "Jessim3838", "le_gamerdu67lenoob", "Toy_bonnieimran", "GRIFFENFERW"}
local processedObjects = {} -- Pour tracker les objets déjà traités
local autoBuyConnection = nil
local trackedObjects = {} -- Pour tracker les positions des objets
local positionTrackingConnection = nil

-- ZONE INTERDITE - Points de delimitation
local PointA = Vector3.new(-355.81, 0.79, -419.35)
local PointB = Vector3.new(67.48, 0.79, -314.64)

-- Attendre le personnage
if not player.Character then
    player.CharacterAdded:Wait()
end

local function safeNotify(title, content, duration)
    pcall(function()
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = duration or 2,
            Image = 4483362458
        })
    end)
end

-- FONCTION POUR VERIFIER SI UNE POSITION EST DANS LA ZONE INTERDITE
local function isInRestrictedZone(position)
    local minX = math.min(PointA.X, PointB.X)
    local maxX = math.max(PointA.X, PointB.X)
    local minZ = math.min(PointA.Z, PointB.Z)
    local maxZ = math.max(PointA.Z, PointB.Z)

    return position.X >= minX and position.X <= maxX and position.Z >= minZ and position.Z <= maxZ
end



-- FONCTION DE TELEPORTATION SIMPLE
local function teleportPlayer(targetPosition, locationName)
    local character = player.Character
    if not character then
        safeNotify("Erreur", "Personnage introuvable", 3)
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")

    if not hrp then
        safeNotify("Erreur", "HumanoidRootPart introuvable", 3)
        return
    end

    -- VERIFICATION: Ne pas se teleporter dans la zone restreinte
    if isInRestrictedZone(targetPosition) then
        return false
    end

    -- Teleportation simple
    hrp.CFrame = CFrame.new(targetPosition)
    hrp.Velocity = Vector3.new(0, 0, 0)

    if locationName then
        safeNotify("Teleporte!", locationName, 2)
    end
    return true
end

-- Fonction pour cliquer sur ProximityPrompt a distance avec verification et restauration garantie
local function clickProximityPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        local originalDistance = prompt.MaxActivationDistance
        local originalDuration = prompt.HoldDuration
        local originalEnabled = prompt.Enabled

        local interactionSuccess = false

        -- Modifier temporairement
        prompt.MaxActivationDistance = 50 -- Distance réduite pour éviter les interactions à distance
        prompt.HoldDuration = 0
        prompt.Enabled = true

        -- Essayer l'interaction
        pcall(function()
            prompt:InputHoldBegin()
            wait(0.1)
            prompt:InputHoldEnd()
            interactionSuccess = true
        end)

        wait(0.2)

        -- Essayer fireproximityprompt si disponible
        if not interactionSuccess and fireproximityprompt then
            pcall(function()
                fireproximityprompt(prompt)
                interactionSuccess = true
            end)
        end

        -- TOUJOURS restaurer les valeurs originales
        pcall(function()
            if prompt and prompt.Parent then
                prompt.MaxActivationDistance = originalDistance
                prompt.HoldDuration = originalDuration
                prompt.Enabled = originalEnabled
            end
        end)

        return interactionSuccess
    end
    return false
end

-- Fonction de téléportation vers l'avant
local function teleportForward()
    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Calculer la position 10 studs devant le joueur
    local currentPosition = hrp.Position
    local lookDirection = hrp.CFrame.LookVector
    local newPosition = currentPosition + (lookDirection * 10)

    -- Téléporter (plus de vérification de zone interdite)
    hrp.CFrame = CFrame.new(newPosition, newPosition + lookDirection)
    hrp.Velocity = Vector3.new(0, 0, 0)

    safeNotify("TP Forward", "Téléporté 10 studs devant", 1)
end

-- Fonction Proximity
local function setInstantProximity(active)
    instantProxActive = active

    if instantProxConnection then
        instantProxConnection:Disconnect()
        instantProxConnection = nil
    end

    local function modifyPrompt(prompt)
        if active then
            prompt.HoldDuration = 0
            -- Ne pas modifier MaxActivationDistance
        else
            prompt.HoldDuration = 1
            -- Restaurer la distance originale si elle était stockée
        end
    end

    -- Appliquer la modification aux prompts existants
    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            modifyPrompt(descendant)
        end
    end

    -- Connecter pour les nouveaux prompts ajoutés après coup
    if active then
        instantProxConnection = workspace.DescendantAdded:Connect(function(desc)
            if desc:IsA("ProximityPrompt") and instantProxActive then
                modifyPrompt(desc)
            end
        end)
    end
end

-- Fonction pour trouver notre base
local function findMyBase()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            local ownerLabel = obj:FindFirstChild("Owner") or obj:FindFirstChildWhichIsA("TextLabel")
            if ownerLabel and ownerLabel:IsA("TextLabel") then
                if string.lower(ownerLabel.Text) == string.lower(player.Name) then
                    if obj.Adornee and obj.Adornee:IsA("BasePart") then
                        return obj.Adornee
                    elseif obj.Parent:IsA("BasePart") then
                        return obj.Parent
                    end
                end
            end
        end
    end
    return nil
end



-- Fonction pour verifier si un objet est sur notre base (à ignorer)
local function isOnMyBase(obj)
    local myBase = findMyBase()
    if not myBase then return false end

    local objPosition = nil

    if obj:IsA("Model") then
        local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
        if hrp then
            objPosition = hrp.Position
        elseif obj.PrimaryPart then
            objPosition = obj.PrimaryPart.Position
        end
    elseif obj:IsA("BasePart") then
        objPosition = obj.Position
    end

    if objPosition then
        local distance = (objPosition - myBase.Position).Magnitude
        return distance <= 50
    end

    return false
end

-- Fonction pour vérifier si on est dans une CollectZone
local function isInCollectZone(position)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("collect") and obj:IsA("BasePart") then
            local distance = (position - obj.Position).Magnitude
            if distance <= 20 then
                return true
            end
        end
    end
    return false
end

-- Fonction pour verifier si un objet est sur un slot d'une base
local function isOnBaseSlot(obj)
    local objPosition = nil

    if obj:IsA("Model") then
        local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
        if hrp then
            objPosition = hrp.Position
        elseif obj.PrimaryPart then
            objPosition = obj.PrimaryPart.Position
        end
    elseif obj:IsA("BasePart") then
        objPosition = obj.Position
    end

    if not objPosition then return false end

    for _, baseObj in pairs(workspace:GetDescendants()) do
        if baseObj:IsA("BillboardGui") or baseObj:IsA("SurfaceGui") then
            local ownerLabel = baseObj:FindFirstChild("Owner") or baseObj:FindFirstChildWhichIsA("TextLabel")
            if ownerLabel and ownerLabel:IsA("TextLabel") then
                local basePart = nil
                if baseObj.Adornee and baseObj.Adornee:IsA("BasePart") then
                    basePart = baseObj.Adornee
                elseif baseObj.Parent:IsA("BasePart") then
                    basePart = baseObj.Parent
                end

                if basePart then
                    local distance = (objPosition - basePart.Position).Magnitude
                    if distance <= 50 then
                        return true, ownerLabel.Text
                    end
                end
            end
        end
    end

    return false
end

-- Variables pour l'ESP
local espActive = false
local selectedEspItems = {}
local espGuis = {}
local espConnection = nil
local espExcludeMyBase = true -- Nouvelle option pour exclure sa propre base

-- Variables pour le saut infini
local infiniteJumpActive = false
local infiniteJumpConnection = nil

-- Fonction pour le saut infini
local function toggleInfiniteJump(active)
    infiniteJumpActive = active

    if infiniteJumpConnection then
        infiniteJumpConnection:Disconnect()
        infiniteJumpConnection = nil
    end

    if active then
        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        safeNotify("Saut Infini", "Activé", 2)
    else
        safeNotify("Saut Infini", "Désactivé", 2)
    end
end

-- Fonction pour créer un GUI ESP amélioré
local function createEspGui(obj, name, isMyBase)
    local character = player.Character
    if not character or not obj.PrimaryPart then return nil end

    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ESP_" .. name
    billboardGui.Adornee = obj.PrimaryPart
    billboardGui.Size = UDim2.new(0, 250, 0, 80)
    billboardGui.StudsOffset = Vector3.new(0, 4, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = workspace

    -- Frame principal avec bordure
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BackgroundColor3 = isMyBase and Color3.new(0.2, 0.2, 1) or Color3.new(0, 0.8, 0)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.new(1, 1, 1)
    mainFrame.Parent = billboardGui

    -- Coins arrondis
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    -- Frame pour le texte principal
    local textFrame = Instance.new("Frame")
    textFrame.Size = UDim2.new(1, 0, 0.6, 0)
    textFrame.Position = UDim2.new(0, 0, 0, 0)
    textFrame.BackgroundTransparency = 1
    textFrame.Parent = mainFrame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name:match("^(.+)%s%(") or name -- Extraire seulement le nom du personnage
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Parent = textFrame

    -- Frame pour le propriétaire
    local ownerFrame = Instance.new("Frame")
    ownerFrame.Size = UDim2.new(1, 0, 0.4, 0)
    ownerFrame.Position = UDim2.new(0, 0, 0.6, 0)
    ownerFrame.BackgroundTransparency = 1
    ownerFrame.Parent = mainFrame

    local ownerLabel = Instance.new("TextLabel")
    ownerLabel.Size = UDim2.new(1, 0, 1, 0)
    ownerLabel.BackgroundTransparency = 1
    ownerLabel.Text = name:match("%((.+)%)") or "Inconnu" -- Extraire le propriétaire
    ownerLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    ownerLabel.TextScaled = true
    ownerLabel.Font = Enum.Font.Gotham
    ownerLabel.TextStrokeTransparency = 0
    ownerLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    ownerLabel.Parent = ownerFrame

    -- Indicateur visuel si c'est sa propre base
    if isMyBase then
        local myBaseIndicator = Instance.new("TextLabel")
        myBaseIndicator.Size = UDim2.new(0.3, 0, 0.3, 0)
        myBaseIndicator.Position = UDim2.new(0.7, 0, -0.1, 0)
        myBaseIndicator.BackgroundColor3 = Color3.new(1, 0.8, 0)
        myBaseIndicator.Text = "MINE"
        myBaseIndicator.TextColor3 = Color3.new(0, 0, 0)
        myBaseIndicator.TextScaled = true
        myBaseIndicator.Font = Enum.Font.GothamBold
        myBaseIndicator.Parent = mainFrame

        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(0, 4)
        indicatorCorner.Parent = myBaseIndicator
    end

    return billboardGui
end

-- Fonction pour mettre à jour l'ESP
local function updateEsp()
    if not espActive or #selectedEspItems == 0 then
        return
    end

    -- Nettoyer les anciens GUIs
    for _, gui in pairs(espGuis) do
        if gui and gui.Parent then
            gui:Destroy()
        end
    end
    espGuis = {}

    -- Rechercher les objets sélectionnés
    for _, item in pairs(selectedEspItems) do
        local itemName = item:lower()

        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find(itemName) and
               not obj.Name:lower():find("hitbox") and 
               not obj.Name:lower():find("collision") then

                local objPosition = nil
                local hrpObj = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                if hrpObj then
                    objPosition = hrpObj.Position
                elseif obj.PrimaryPart then
                    objPosition = obj.PrimaryPart.Position
                end

                if objPosition then
                    -- Vérifier que l'objet est EN DEHORS de la zone interdite
                    if not isInRestrictedZone(objPosition) then
                        -- Vérifier si l'objet est sur un stand
                        local onSlot, baseOwner = isOnBaseSlot(obj)
                        if onSlot and baseOwner then
                            -- NOUVELLE CONDITION: Vérifier l'option d'exclusion de sa propre base
                            local isMyBaseObj = (baseOwner == player.Name)
                            if not espExcludeMyBase or not isMyBaseObj then
                                local espGui = createEspGui(obj, obj.Name .. " (" .. baseOwner .. ")", isMyBaseObj)
                                if espGui then
                                    table.insert(espGuis, espGui)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Fonction pour activer/désactiver l'ESP
local function toggleEsp(active)
    espActive = active

    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end

    if active then
        updateEsp()
        -- Mettre à jour toutes les 1 secondes
        espConnection = runService.Heartbeat:Connect(function()
            if not espConnection.lastUpdate then
                espConnection.lastUpdate = tick()
            end

            local currentTime = tick()
            if currentTime - espConnection.lastUpdate >= 1 then
                espConnection.lastUpdate = currentTime
                spawn(function()
                    pcall(updateEsp)
                end)
            end
        end)
        safeNotify("ESP", "Activé", 2)
    else
        -- Nettoyer tous les GUIs ESP
        for _, gui in pairs(espGuis) do
            if gui and gui.Parent then
                gui:Destroy()
            end
        end
        espGuis = {}
        safeNotify("ESP", "Désactivé", 2)
    end
end

-- Fonction pour tracker les positions des objets
local function trackObjectPositions()
    if not autoBuyActive or #selectedAutoBuyItems == 0 then
        return
    end

    for _, item in pairs(selectedAutoBuyItems) do
        for _, obj in pairs(workspace:GetDescendants()) do
            local objName = obj.Name:lower()
            local itemName = item:lower()

            local keywords = {}
            if itemName:find("poor") then keywords = {"poor"} end
            if itemName:find("surf") then keywords = {"surf"} end
            if itemName:find("teacher") then keywords = {"teacher"} end
            if itemName:find("magic") then keywords = {"magic", "mage"} end
            if itemName:find("swat") then keywords = {"swat"} end
            if itemName:find("buildeur") then keywords = {"buildeur", "builder", "build"} end
            if itemName:find("ninja") then keywords = {"ninja"} end
            if itemName:find("sleeping") then keywords = {"sleeping", "sleep"} end
            if itemName:find("rich") then keywords = {"rich"} end
            if itemName:find("boxer") then keywords = {"boxer", "box"} end
            if itemName:find("hacker") then keywords = {"hacker", "hack"} end
            if itemName:find("king") then keywords = {"king"} end
            if itemName:find("demon") then keywords = {"demon"} end
            if itemName:find("god") then keywords = {"god"} end
            if itemName:find("sayan") then keywords = {"sayan", "saiyan"} end
            if itemName:find("solider") then keywords = {"soldier", "solider"} end
            if itemName:find("creator") then keywords = {"creator"} end

            local matches = false
            for _, keyword in pairs(keywords) do
                if objName:find(keyword) then
                    matches = true
                    break
                end
            end

            if matches then
                local objPosition = nil
                if obj:IsA("Model") and obj.PrimaryPart then
                    objPosition = obj.PrimaryPart.Position
                elseif obj:IsA("BasePart") then
                    objPosition = obj.Position
                end

                if objPosition then
                    local objId = tostring(obj)

                    -- Si l'objet était déjà tracké et a bougé
                    if trackedObjects[objId] and trackedObjects[objId].position then
                        local oldPosition = trackedObjects[objId].position
                        local distance = (objPosition - oldPosition).Magnitude

                        -- Si l'objet a bougé de plus de 5 studs
                        if distance > 5 then

                            -- Se téléporter vers la nouvelle position
                            local character = player.Character
                            if character then
                                local hrp = character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    hrp.CFrame = CFrame.new(objPosition)
                                    hrp.Velocity = Vector3.new(0, 0, 0)

                                    -- Essayer d'interagir avec l'objet
                                    wait(0.3)
                                    for _, desc in pairs(obj:GetDescendants()) do
                                        if desc:IsA("ProximityPrompt") then
                                            pcall(function()
                                                desc.MaxActivationDistance = 1000
                                                desc.HoldDuration = 0
                                                desc.Enabled = true
                                                desc:InputHoldBegin()
                                                wait(0.1)
                                                desc:InputHoldEnd()
                                                if fireproximityprompt then
                                                    fireproximityprompt(desc)
                                                end
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end

                    -- Mettre à jour la position trackée
                    trackedObjects[objId] = {
                        position = objPosition,
                        object = obj,
                        item = item
                    }
                end
            end
        end
    end
end

-- Fonction pour désactiver/réactiver les proximity prompts de notre base
local function toggleMyBaseProximityPrompts(disable)
    local myBase = findMyBase()
    if not myBase then return end

    -- Chercher tous les proximity prompts dans un rayon de 50 studs de notre base
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local promptPosition = nil

            if obj.Parent:IsA("BasePart") then
                promptPosition = obj.Parent.Position
            elseif obj.Parent:IsA("Model") and obj.Parent.PrimaryPart then
                promptPosition = obj.Parent.PrimaryPart.Position
            end

            if promptPosition then
                local distance = (promptPosition - myBase.Position).Magnitude
                if distance <= 50 then -- Dans notre base
                    if disable then
                        obj.Enabled = false
                    else
                        obj.Enabled = true
                    end
                end
            end
        end
    end
end

-- FONCTION AUTO BUY AMÉLIORÉE - Version continue et stable
local function performAutoBuy()
    if not autoBuyActive or #selectedAutoBuyItems == 0 then
        return
    end

    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Rechercher continuellement les objets dans toute la zone shop
    local allBuyObjects = {}

    for _, item in pairs(selectedAutoBuyItems) do
        for _, obj in pairs(workspace:GetDescendants()) do
            if not obj or not obj.Parent then
                continue
            end

            local objName = obj.Name:lower()
            local itemName = item:lower()

            -- Correspondance directe avec le nom
            if objName:find(itemName) then
                local objId = tostring(obj)

                -- Vérifier si cet objet a déjà été traité récemment (avec timeout)
                local currentTime = tick()
                if not processedObjects[objId] or (currentTime - processedObjects[objId]) > 30 then
                    for _, desc in pairs(obj:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") and desc.Enabled then
                            local objPosition = nil

                            if obj:IsA("Model") and obj.PrimaryPart then
                                objPosition = obj.PrimaryPart.Position
                            elseif obj:IsA("BasePart") then
                                objPosition = obj.Position
                            elseif obj:IsA("Model") then
                                local part = obj:FindFirstChildOfClass("BasePart")
                                if part then
                                    objPosition = part.Position
                                end
                            end

                            if objPosition and isInRestrictedZone(objPosition) then
                                local distance = (objPosition - hrp.Position).Magnitude
                                table.insert(allBuyObjects, {
                                    name = obj.Name,
                                    position = objPosition,
                                    prompt = desc,
                                    item = item,
                                    object = obj,
                                    objId = objId,
                                    distance = distance
                                })
                            end
                            break
                        end
                    end
                end
            end
        end
    end

    -- Si on a trouvé des objets, aller les acheter
    if #allBuyObjects > 0 then
        -- Trier par distance (plus proche en premier)
        table.sort(allBuyObjects, function(a, b)
            return a.distance < b.distance
        end)

        local targetObj = allBuyObjects[1]

        -- Se téléporter dans la zone shop si pas déjà dedans
        if not isInRestrictedZone(hrp.Position) then
            local shopPosition = Vector3.new(-150, 10, -370) -- Position dans la zone shop
            pcall(function()
                hrp.CFrame = CFrame.new(shopPosition)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end)
            wait(0.5)
        end

        -- Marquer l'objet comme traité
        processedObjects[targetObj.objId] = tick()

        -- Téléportation vers l'objet
        pcall(function()
            hrp.CFrame = CFrame.new(targetObj.position + Vector3.new(0, 2, 0))
            hrp.Velocity = Vector3.new(0, 0, 0)
            if hrp.AssemblyLinearVelocity then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end)

        wait(0.3)

        -- Interaction avec le prompt
        local interactionSuccess = false
        pcall(function()
            if targetObj.prompt and targetObj.prompt.Parent and targetObj.prompt.Enabled then
                local origDistance = targetObj.prompt.MaxActivationDistance
                local origDuration = targetObj.prompt.HoldDuration

                targetObj.prompt.MaxActivationDistance = 100
                targetObj.prompt.HoldDuration = 0
                targetObj.prompt.Enabled = true

                targetObj.prompt:InputHoldBegin()
                wait(0.1)
                targetObj.prompt:InputHoldEnd()

                if fireproximityprompt then
                    fireproximityprompt(targetObj.prompt)
                end

                targetObj.prompt.MaxActivationDistance = origDistance
                targetObj.prompt.HoldDuration = origDuration

                interactionSuccess = true
            end
        end)

        if interactionSuccess then
            safeNotify("Auto Buy", "Acheté: " .. targetObj.name, 1)
        end

        wait(0.5)
    end
end

-- FONCTION TOGGLE AUTO BUY - Version continue
local function toggleAutoBuy(active)
    autoBuyActive = active

    -- Nettoyer les connexions existantes
    if autoBuyConnection then
        autoBuyConnection:Disconnect()
        autoBuyConnection = nil
    end

    if active then
        safeNotify("Auto Buy", "Auto Buy continu activé", 2)

        -- Connexion continue qui fonctionne en permanence
        autoBuyConnection = runService.Heartbeat:Connect(function()
            local currentTime = tick()
            if not autoBuyConnection.lastRun then
                autoBuyConnection.lastRun = currentTime
            end

            -- Exécuter l'auto buy toutes les 3 secondes
            if currentTime - autoBuyConnection.lastRun >= 3 then
                autoBuyConnection.lastRun = currentTime
                spawn(function()
                    pcall(performAutoBuy) -- Protection contre les erreurs
                end)
            end
        end)

        -- Démarrer immédiatement
        spawn(function()
            wait(1)
            pcall(performAutoBuy)
        end)
    else
        safeNotify("Auto Buy", "Auto Buy désactivé", 2)
        processedObjects = {} -- Réinitialiser les objets traités
    end
end

-- Fonction performStealBest - version ultra-optimisée et rapide
local function performStealBest()
    local character = player.Character
    if not character then
        safeNotify("Steal Best", "Personnage introuvable", 2)
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        safeNotify("Steal Best", "HumanoidRootPart introuvable", 2)
        return
    end

    local originalPosition = hrp.Position
    local bestTarget = nil
    local allTargets = {}

    safeNotify("Steal Best", "Scan ultra-rapide...", 1)

    -- OPTIMISATION MAJEURE: Collecte tous les targets en une seule passe
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and not obj.Name:lower():find("hitbox") and 
           not obj.Name:lower():find("collision") then

            local objName = obj.Name:lower()
            local matchedPriority = nil
            local matchedType = nil

            -- Recherche de correspondance optimisée
            for priority, playerType in ipairs(playerTypes) do
                if objName:find(playerType:lower()) then
                    matchedPriority = priority
                    matchedType = playerType
                    break
                end
            end

            if matchedPriority then
                local objPosition = nil
                local hrpObj = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                if hrpObj then
                    objPosition = hrpObj.Position
                elseif obj.PrimaryPart then
                    objPosition = obj.PrimaryPart.Position
                end

                if objPosition and not isInRestrictedZone(objPosition) and not isOnMyBase(obj) then
                    local onSlot, baseOwner = isOnBaseSlot(obj)
                    if onSlot and baseOwner and baseOwner ~= player.Name then
                        -- Vérification rapide des prompts
                        local hasPrompt = false
                        for _, desc in pairs(obj:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") and desc.Enabled then
                                hasPrompt = true
                                break
                            end
                        end

                        if hasPrompt then
                            local distance = (objPosition - originalPosition).Magnitude
                            table.insert(allTargets, {
                                object = obj,
                                position = objPosition,
                                name = obj.Name,
                                baseOwner = baseOwner,
                                distance = distance,
                                type = matchedType,
                                priority = matchedPriority
                            })
                        end
                    end
                end
            end
        end
    end

    if #allTargets == 0 then
        safeNotify("Steal Best", "Aucun personnage disponible", 3)
        return
    end

    -- Tri intelligent: priorité d'abord, puis distance
    table.sort(allTargets, function(a, b)
        if a.priority == b.priority then
            return a.distance < b.distance
        end
        return a.priority < b.priority
    end)

    bestTarget = allTargets[1]

    safeNotify("Steal Best", bestTarget.type .. " chez " .. bestTarget.baseOwner, 1)

    -- Téléportation instantanée optimisée
    local targetPos = bestTarget.position + Vector3.new(0, 2, 0)

    -- Désactiver temporairement la physique pour une téléportation plus stable
    hrp.Anchored = true
    hrp.CFrame = CFrame.new(targetPos)
    hrp.Velocity = Vector3.new(0, 0, 0)
    wait(0.1)
    hrp.Anchored = false

    -- Interaction ultra-rapide avec retry automatique
    local success = false
    local maxAttempts = 3

    for attempt = 1, maxAttempts do
        if bestTarget.object and bestTarget.object.Parent then
            for _, prompt in pairs(bestTarget.object:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                    local interacted = pcall(function()
                        -- Configuration optimale pour interaction rapide
                        prompt.MaxActivationDistance = 1000
                        prompt.HoldDuration = 0
                        prompt.Enabled = true

                        -- Multiples méthodes d'interaction simultanées
                        prompt:InputHoldBegin()
                        prompt:InputHoldEnd()

                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        end

                        success = true
                    end)

                    if success then break end
                end
            end
        end

        if success then break end
        wait(0.1)
    end

    wait(0.2)

    -- Retour optimisé avec téléportation directe
    local myBase = findMyBase()
    if myBase then
        hrp.Anchored = true
        hrp.CFrame = CFrame.new(myBase.Position + Vector3.new(0, -15, 0))
        wait(0.3)
        hrp.Anchored = false
    end

    -- Retour instantané à l'origine
    hrp.Anchored = true
    hrp.CFrame = CFrame.new(originalPosition)
    wait(0.1)
    hrp.Anchored = false

    if success then
        safeNotify("Steal Best", "Succès: " .. bestTarget.name, 2)
    else
        safeNotify("Steal Best", "Échec après " .. maxAttempts .. " tentatives", 2)
    end
end



-- Fonction performSteal ultra-optimisée
local function performSteal()
    local selectedType = currentPlayerType
    local character = player.Character
    if not character then
        safeNotify("Steal", "Personnage introuvable", 2)
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        safeNotify("Steal", "HumanoidRootPart introuvable", 2)
        return
    end

    local originalPosition = hrp.Position
    local matchingObjects = {}

    safeNotify("Steal", "Recherche de " .. selectedType .. "...", 1)

    -- Recherche optimisée en une seule passe
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find(selectedType:lower()) and
           not obj.Name:lower():find("hitbox") and not obj.Name:lower():find("collision") then

            local objPosition = nil
            local hrpObj = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
            if hrpObj then
                objPosition = hrpObj.Position
            elseif obj.PrimaryPart then
                objPosition = obj.PrimaryPart.Position
            end

            if objPosition and not isInRestrictedZone(objPosition) and not isOnMyBase(obj) then
                local onSlot, baseOwner = isOnBaseSlot(obj)
                if onSlot and baseOwner and baseOwner ~= player.Name then
                    -- Vérification rapide des prompts
                    local hasPrompt = false
                    for _, desc in pairs(obj:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") and desc.Enabled then
                            hasPrompt = true
                            break
                        end
                    end

                    if hasPrompt then
                        local distance = (objPosition - originalPosition).Magnitude
                        table.insert(matchingObjects, {
                            object = obj,
                            position = objPosition,
                            name = obj.Name,
                            baseOwner = baseOwner,
                            distance = distance
                        })
                    end
                end
            end
        end
    end

    if #matchingObjects == 0 then
        safeNotify("Steal", "Aucun " .. selectedType .. " disponible", 3)
        return
    end

    -- Tri par distance
    table.sort(matchingObjects, function(a, b)
        return a.distance < b.distance
    end)

    local targetData = matchingObjects[1]
    safeNotify("Steal", targetData.name .. " chez " .. targetData.baseOwner, 1)

    -- Téléportation optimisée avec anchoring
    local targetPosition = targetData.position + Vector3.new(0, 2, 0)
    hrp.Anchored = true
    hrp.CFrame = CFrame.new(targetPosition)
    wait(0.15)
    hrp.Anchored = false

    -- Interaction rapide avec retry
    local success = false
    local attempts = 0
    local maxAttempts = 2

    while not success and attempts < maxAttempts do
        attempts = attempts + 1

        if targetData.object and targetData.object.Parent then
            for _, prompt in pairs(targetData.object:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                    local interacted = pcall(function()
                        prompt.MaxActivationDistance = 1000
                        prompt.HoldDuration = 0
                        prompt:InputHoldBegin()
                        prompt:InputHoldEnd()

                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        end
                        success = true
                    end)

                    if success then break end
                end
            end
        end

        if not success then wait(0.1) end
    end

    wait(0.2)

    -- Retour ultra-rapide
    local myBase = findMyBase()
    if myBase then
        hrp.Anchored = true
        hrp.CFrame = CFrame.new(myBase.Position + Vector3.new(0, -15, 0))
        wait(0.3)
        hrp.CFrame = CFrame.new(originalPosition)
        wait(0.1)
        hrp.Anchored = false
    else
        hrp.Anchored = true
        hrp.CFrame = CFrame.new(originalPosition)
        wait(0.1)
        hrp.Anchored = false
    end

    if success then
        safeNotify("Steal", "Succès: " .. targetData.name, 2)
    else
        safeNotify("Steal", "Interaction échouée", 2)
    end
end

-- CREATION DE L'INTERFACE
local Window = Rayfield:CreateWindow({
    Name = "Steal a Anime - script",
    LoadingTitle = "Chargement...",
    LoadingSubtitle = "Preparation du script",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

-- Onglet Principal
local MainTab = Window:CreateTab("Principal", 4483362458)

local SpeedSlider = MainTab:CreateSlider({
    Name = "Vitesse de marche",
    Range = {16, maxWalkSpeed}, -- Utilise la nouvelle limite
    Increment = 1,
    Suffix = "",
    CurrentValue = savedWalkSpeed, -- Utilise la nouvelle valeur initiale
    Callback = function(Value)
        walkSpeed = Value
        savedWalkSpeed = Value
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = walkSpeed
        end
    end
})

local TpForwardButton = MainTab:CreateButton({
    Name = "TP AVANT (10 studs)",
    Callback = function()
        teleportForward()
    end
})

local ProximityToggle = MainTab:CreateToggle({
    Name = "Proximite Instantanee", -- Nom du bouton modifié
    CurrentValue = false,
    Callback = function(Value)
        setInstantProximity(Value)
    end
})

local TpBaseButton = MainTab:CreateButton({
    Name = "TP BASE",
    Callback = function()
        local character = player.Character
        if not character then
            safeNotify("TP Base", "Personnage introuvable", 2)
            return
        end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            safeNotify("TP Base", "HumanoidRootPart introuvable", 2)
            return
        end

        local myBase = findMyBase()
        if myBase then
            local basePosition = myBase.Position + Vector3.new(0, -20, 0)
            hrp.CFrame = CFrame.new(basePosition)
            hrp.Velocity = Vector3.new(0, 0, 0)
            safeNotify("TP Base", "Téléporté à votre base", 2)
        else
            safeNotify("TP Base", "Base introuvable", 3)
        end
    end
})

-- Nouveau toggle pour le saut infini
local InfiniteJumpToggle = MainTab:CreateToggle({
    Name = "Saut Infini",
    CurrentValue = false,
    Callback = function(Value)
        toggleInfiniteJump(Value)
    end
})

-- Onglet Auto Buy
local AutoBuyTab = Window:CreateTab("Auto Buy", 4483362458)

local AutoBuyInfo = AutoBuyTab:CreateLabel("Selectionne les Noobs a acheter automatiquement:")

-- CORRECTION: Dropdown avec Flag pour pouvoir modifier la sélection
local AutoBuyDropdown = AutoBuyTab:CreateDropdown({
    Name = "Noobs disponibles",
    Options = autoBuyItems,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "AutoBuySelection", -- Ajout du Flag
    Callback = function(Options)
        selectedAutoBuyItems = Options
    end
})

-- NOUVEAU: Bouton pour vider la sélection
local ClearSelectionButton = AutoBuyTab:CreateButton({
    Name = "Vider la sélection",
    Callback = function()
        selectedAutoBuyItems = {}
        -- Réinitialiser le dropdown
        AutoBuyDropdown:Set({})
        -- Sélection vidée
    end
})

local AutoBuyToggle = AutoBuyTab:CreateToggle({
    Name = "AUTO BUY",
    CurrentValue = false,
    Callback = function(Value)
        toggleAutoBuy(Value)
    end
})

local AutoBuyInfo2 = AutoBuyTab:CreateLabel("En bêta, peut y avoir quelque bugs")

-- Onglet Steal
local StealTab = Window:CreateTab("Steal", 4483362458)

local PlayerTypeDropdown = StealTab:CreateDropdown({
    Name = "Type de cible a voler",
    Options = playerTypes,
    CurrentOption = {"Ayere"},
    Callback = function(Option)
        currentPlayerType = Option[1]
    end
})

local StealButton = StealTab:CreateButton({
    Name = "STEAL",
    Callback = function()
        performSteal()
    end
})

local StealBestButton = StealTab:CreateButton({
    Name = "STEAL BEST",
    Callback = function()
        performStealBest()
    end
})

-- Labels d'information mis à jour
local InfoLabel = StealTab:CreateLabel("Steal  - Plus rapide et efficace")
local InfoLabel2 = StealTab:CreateLabel("Steal Best:optimisé pour trouver le meilleur")

-- Onglet ESP amélioré
local EspTab = Window:CreateTab("ESP", 4483362458)

local EspInfo = EspTab:CreateLabel("🔍 ESP")

local EspToggle = EspTab:CreateToggle({
    Name = "🎯 ESP",
    CurrentValue = false,
    Callback = function(Value)
        toggleEsp(Value)
    end
})

local EspExcludeMyBaseToggle = EspTab:CreateToggle({
    Name = "🏠 NO MY base",
    CurrentValue = true,
    Callback = function(Value)
        espExcludeMyBase = Value
        -- Rafraîchir l'ESP si actif
        if espActive then
            updateEsp()
        end
    end
})

local EspDropdown = EspTab:CreateDropdown({
    Name = "👤 Character detect",
    Options = playerTypes,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "EspSelection",
    Callback = function(Options)
        selectedEspItems = Options
        -- Rafraîchir l'ESP si actif
        if espActive then
            updateEsp()
        end
    end
})

local ClearEspButton = EspTab:CreateButton({
    Name = "🗑️ Clear detection",
    Callback = function()
        selectedEspItems = {}
        EspDropdown:Set({})
        -- Nettoyer l'ESP
        for _, gui in pairs(espGuis) do
            if gui and gui.Parent then
                gui:Destroy()
            end
        end
        espGuis = {}
    end
})

local SelectAllButton = EspTab:CreateButton({
    Name = "✅ All",
    Callback = function()
        selectedEspItems = playerTypes
        EspDropdown:Set(playerTypes)
        if espActive then
            updateEsp()
        end
    end
})


-- Nettoyage périodique des objets traités - amélioré pour l'auto buy continu
spawn(function()
    while true do
        wait(45) -- Nettoyer toutes les 45 secondes pour plus de réactivité
        if autoBuyActive then
            local currentTime = tick()
            local cleanedCount = 0

            -- Nettoyer seulement les objets traités il y a plus de 30 secondes
            for objId, processTime in pairs(processedObjects) do
                if (currentTime - processTime) > 30 then
                    processedObjects[objId] = nil
                    cleanedCount = cleanedCount + 1
                end
            end

            if cleanedCount > 0 then
                safeNotify("Auto Buy", "Cache nettoyé (" .. cleanedCount .. " objets)", 1)
            end
        end
    end
end)

-- Fonction pour vérifier et corriger la vitesse
local function checkAndCorrectSpeed()
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    if humanoid.WalkSpeed > maxWalkSpeed then
        humanoid.WalkSpeed = maxWalkSpeed
    end
end

-- Connexion pour la vérification de vitesse continue
if not speedCheckConnection then
    speedCheckConnection = runService.Heartbeat:Connect(checkAndCorrectSpeed)
end

-- Evenements
player.CharacterAdded:Connect(function()
    wait(1)
    walkSpeed = savedWalkSpeed -- Réinitialiser à la valeur sauvegardée
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = walkSpeed
    end
    setInstantProximity(instantProxActive)

    -- Réactiver le saut infini si nécessaire
    if infiniteJumpActive then
        toggleInfiniteJump(true)
    end

    -- Auto buy check avec delai
    if autoBuyActive then
        wait(1)
        performAutoBuy()
    end

    -- Réactiver l'ESP si nécessaire
    if espActive then
        wait(0.5)
        toggleEsp(true)
    end
end)

-- Appliquer les paramètres initiaux
if player.Character then
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = walkSpeed
    end
end

-- Script chargé
