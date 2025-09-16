-- Services Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Détecter si c'est mobile ou PC
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Variables principales
local mainFrame = nil
local boostFrame = nil
local logsFrame = nil
local bypassEnabled = false
local bypassConnections = {}
local spoofedStats = {}
local gradualSpeedActive = false

-- Système de logs
local LogSystem = {
    logs = {},
    maxLogs = 100,
    logTypes = {
        INFO = {color = Color3.fromRGB(100, 200, 255), prefix = "ℹ️"},
        SUCCESS = {color = Color3.fromRGB(100, 255, 100), prefix = "✅"},
        WARNING = {color = Color3.fromRGB(255, 200, 100), prefix = "⚠️"},
        ERROR = {color = Color3.fromRGB(255, 100, 100), prefix = "❌"},
        EXPLOIT = {color = Color3.fromRGB(255, 100, 255), prefix = "💀"},
        DETECTION = {color = Color3.fromRGB(255, 255, 100), prefix = "🎯"}
    }
}

-- Variables de boost
local currentSpeed = 50
local currentJumpPower = 50
local boostActive = false
local originalSpeed = 16
local originalJumpPower = 50

-- Fonctions du système de logs
function LogSystem:addLog(message, logType)
    logType = logType or "INFO"
    local timestamp = os.date("%H:%M:%S")
    local logEntry = {
        time = timestamp,
        message = message,
        type = logType,
        color = self.logTypes[logType] and self.logTypes[logType].color or Color3.fromRGB(255, 255, 255),
        prefix = self.logTypes[logType] and self.logTypes[logType].prefix or "📝"
    }

    table.insert(self.logs, logEntry)

    -- Limiter le nombre de logs
    if #self.logs > self.maxLogs then
        table.remove(self.logs, 1)
    end

    -- Mettre à jour l'affichage si le panel est ouvert
    if logsFrame and logsFrame.Visible then
        self:updateLogsDisplay()
    end

    -- Afficher aussi dans la console
    print("[" .. timestamp .. "] " .. logEntry.prefix .. " " .. message)
end

function LogSystem:updateLogsDisplay()
    if not logsFrame then return end

    local scrollingFrame = logsFrame:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then return end

    -- Nettoyer les anciens logs
    for _, child in pairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    -- Ajouter les nouveaux logs
    for i, log in pairs(self.logs) do
        local logLabel = Instance.new("TextLabel")
        logLabel.Name = "LogEntry" .. i
        logLabel.Size = UDim2.new(1, -10, 0, 20)
        logLabel.Position = UDim2.new(0, 5, 0, (i-1) * 22)
        logLabel.BackgroundTransparency = 1
        logLabel.Text = "[" .. log.time .. "] " .. log.prefix .. " " .. log.message
        logLabel.TextColor3 = log.color
        logLabel.TextScaled = false
        logLabel.TextSize = 12
        logLabel.Font = Enum.Font.Code
        logLabel.TextXAlignment = Enum.TextXAlignment.Left
        logLabel.Parent = scrollingFrame
    end

    -- Ajuster la taille du contenu
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #self.logs * 22)

    -- Scroll vers le bas (derniers logs)
    scrollingFrame.CanvasPosition = Vector2.new(0, scrollingFrame.CanvasSize.Y.Offset)
end

function LogSystem:createLogsPanel()
    if logsFrame then
        logsFrame:Destroy()
    end

    -- Créer le panel principal
    logsFrame = Instance.new("Frame")
    logsFrame.Name = "LogsPanel"
    logsFrame.Size = UDim2.new(0, 600, 0, 400)
    logsFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    logsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    logsFrame.BorderSizePixel = 2
    logsFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    logsFrame.Visible = false
    logsFrame.Parent = playerGui

    -- Titre
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleLabel.Text = "📜 PANEL DES LOGS"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = logsFrame

    -- Bouton fermer
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = logsFrame

    closeButton.MouseButton1Click:Connect(function()
        logsFrame.Visible = false
    end)

    -- Zone de scroll pour les logs
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Name = "ScrollingFrame"
    scrollingFrame.Size = UDim2.new(1, -10, 1, -80)
    scrollingFrame.Position = UDim2.new(0, 5, 0, 35)
    scrollingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    scrollingFrame.BorderSizePixel = 1
    scrollingFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
    scrollingFrame.ScrollBarThickness = 10
    scrollingFrame.Parent = logsFrame

    -- Boutons d'action
    local clearButton = Instance.new("TextButton")
    clearButton.Name = "ClearButton"
    clearButton.Size = UDim2.new(0, 100, 0, 30)
    clearButton.Position = UDim2.new(0, 10, 1, -35)
    clearButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    clearButton.Text = "🗑️ Effacer"
    clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearButton.TextScaled = true
    clearButton.Font = Enum.Font.SourceSans
    clearButton.Parent = logsFrame

    clearButton.MouseButton1Click:Connect(function()
        self.logs = {}
        self:updateLogsDisplay()
        self:addLog("Logs effacés", "INFO")
    end)

    local exportButton = Instance.new("TextButton")
    exportButton.Name = "ExportButton"
    exportButton.Size = UDim2.new(0, 100, 0, 30)
    exportButton.Position = UDim2.new(0, 120, 1, -35)
    exportButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    exportButton.Text = "📤 Exporter"
    exportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    exportButton.TextScaled = true
    exportButton.Font = Enum.Font.SourceSans
    exportButton.Parent = logsFrame

    exportButton.MouseButton1Click:Connect(function()
        self:exportLogs()
    end)

    -- Rendre draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil

    titleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = logsFrame.Position
        end
    end)

    titleLabel.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            logsFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    titleLabel.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    self:addLog("Panel des logs créé", "SUCCESS")
end

function LogSystem:exportLogs()
    local exportText = "=== EXPORT DES LOGS ===\n"
    exportText = exportText .. "Généré le: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    exportText = exportText .. "Nombre total de logs: " .. #self.logs .. "\n\n"

    for _, log in pairs(self.logs) do
        exportText = exportText .. "[" .. log.time .. "] " .. log.prefix .. " " .. log.message .. "\n"
    end

    -- Copier dans le presse-papier (si possible)
    if setclipboard then
        setclipboard(exportText)
        self:addLog("Logs copiés dans le presse-papier", "SUCCESS")
    else
        self:addLog("Export disponible dans la console", "INFO")
        print(exportText)
    end
end

function LogSystem:togglePanel()
    if not logsFrame then
        self:createLogsPanel()
    end

    logsFrame.Visible = not logsFrame.Visible

    if logsFrame.Visible then
        self:updateLogsDisplay()
        self:addLog("Panel des logs ouvert", "INFO")
    else
        self:addLog("Panel des logs fermé", "INFO")
    end
end

-- Système de détection d'anti-cheat avec analyse de failles
local AntiCheatDetector = {
    detectedSystems = {},
    activeThreats = {},
    vulnerabilities = {},
    exploitableFlaws = {},
    lastScan = 0,
    scanInterval = 1.5,
    patterns = {
        -- Patterns communs d'anti-cheat mal conçus
        remoteNames = {
            "anticheat", "ac", "security", "check", "verify", "ban", "kick",
            "speed", "exploit", "hack", "cheat", "detect", "monitor", "guard",
            "protection", "shield", "secure", "validate", "audit", "scan",
            "speedcheck", "playercheck", "validation", "anticheats"
        },
        scriptNames = {
            "AntiCheat", "AC", "Security", "Protection", "Guard", "Monitor",
            "SpeedCheck", "ExploitDetection", "HackProtection", "Verify",
            "PlayerMonitor", "GameGuard", "Antihack", "Checker"
        },
        folderNames = {
            "AntiCheat", "Security", "Protection", "AC", "Checks", "Guards"
        }
    },
    flawPatterns = {
        -- Failles communes dans les anti-cheats mal conçus
        CLIENT_SIDE_ONLY = "Anti-cheat côté client uniquement",
        NO_ENCRYPTION = "Communications non chiffrées",
        PREDICTABLE_TIMING = "Vérifications à intervalles fixes",
        WEAK_VALIDATION = "Validation faible des données",
        NO_RATE_LIMITING = "Pas de limitation de taux",
        OBVIOUS_REMOTES = "Noms de remotes évidents",
        SINGLE_CHECK = "Une seule méthode de vérification",
        NO_RANDOMIZATION = "Pas de randomisation",
        EXPOSED_VARIABLES = "Variables exposées",
        SIMPLE_THRESHOLD = "Seuils simples et fixes"
    }
}

-- Analyseur de failles avancé
function AntiCheatDetector:analyzeVulnerabilities()
    self.vulnerabilities = {}
    self.exploitableFlaws = {}

    for _, system in pairs(self.detectedSystems) do
        local flaws = self:findSystemFlaws(system)
        for _, flaw in pairs(flaws) do
            table.insert(self.vulnerabilities, {
                system = system,
                flaw = flaw,
                exploitMethod = self:getExploitMethod(flaw),
                severity = self:getFlawSeverity(flaw)
            })
        end
    end

    -- Identifier les failles exploitables
    for _, vuln in pairs(self.vulnerabilities) do
        if vuln.severity == "CRITICAL" or vuln.severity == "HIGH" then
            table.insert(self.exploitableFlaws, vuln)
        end
    end
end

-- Analyser les failles spécifiques d'un système
function AntiCheatDetector:findSystemFlaws(system)
    local flaws = {}

    if system.type == "Remote" then
        -- Analyser les failles des RemoteEvents
        local remote = system.object

        -- Faille 1: Nom évident et prévisible
        if self:isObviousName(remote.Name) then
            table.insert(flaws, self.flawPatterns.OBVIOUS_REMOTES)
        end

        -- Faille 2: Pas de rate limiting (test d'envoi rapide)
        if self:testRateLimit(remote) then
            table.insert(flaws, self.flawPatterns.NO_RATE_LIMITING)
        end

        -- Faille 3: Communications non sécurisées
        if self:testEncryption(remote) then
            table.insert(flaws, self.flawPatterns.NO_ENCRYPTION)
        end

    elseif system.type == "Script" then
        -- Analyser les failles des scripts
        local script = system.object

        -- Faille 1: Script côté client uniquement
        if script:IsA("LocalScript") then
            table.insert(flaws, self.flawPatterns.CLIENT_SIDE_ONLY)
        end

        -- Faille 2: Variables exposées
        if self:hasExposedVariables(script) then
            table.insert(flaws, self.flawPatterns.EXPOSED_VARIABLES)
        end

    elseif system.type == "StatValidator" then
        -- Analyser les failles des validateurs
        if self:hasWeakValidation(system.object) then
            table.insert(flaws, self.flawPatterns.WEAK_VALIDATION)
        end

        if self:hasPredictableTiming(system.object) then
            table.insert(flaws, self.flawPatterns.PREDICTABLE_TIMING)
        end
    end

    return flaws
end

-- Tester si un nom est évident et exploitable
function AntiCheatDetector:isObviousName(name)
    local obviousNames = {
        "AntiCheat", "AC", "BanPlayer", "KickPlayer", "SpeedCheck",
        "HackDetected", "CheatFound", "PlayerBan", "SecurityCheck"
    }

    for _, obvious in pairs(obviousNames) do
        if name:find(obvious) then
            return true
        end
    end
    return false
end

-- Tester l'absence de rate limiting
function AntiCheatDetector:testRateLimit(remote)
    if not remote:IsA("RemoteEvent") then return false end

    -- Simuler plusieurs appels rapides
    local success = 0
    for i = 1, 10 do
        pcall(function()
            remote:FireServer({test = "rate_limit_test"})
            success = success + 1
        end)
    end

    -- Si plus de 5 appels passent, rate limiting faible/absent
    return success > 5
end

-- Tester l'absence de chiffrement
function AntiCheatDetector:testEncryption(remote)
    -- Vérifier si les données sont envoyées en clair
    local testData = {
        speed = 999,
        position = Vector3.new(0, 1000, 0),
        suspicious = true
    }

    local success = pcall(function()
        remote:FireServer(testData) -- Si ça passe, pas de validation
    end)

    return success
end

-- Vérifier les variables exposées
function AntiCheatDetector:hasExposedVariables(script)
    -- Chercher des variables communes mal protégées
    local exposedPatterns = {
        "MaxSpeed", "SpeedLimit", "CheckInterval", "BanThreshold",
        "AllowedSpeed", "PlayerData", "SecurityKey"
    }

    for _, child in pairs(script:GetChildren()) do
        if child:IsA("NumberValue") or child:IsA("StringValue") or child:IsA("BoolValue") then
            for _, pattern in pairs(exposedPatterns) do
                if child.Name:find(pattern) then
                    return true
                end
            end
        end
    end
    return false
end

-- Vérifier la validation faible
function AntiCheatDetector:hasWeakValidation(humanoid)
    -- Tester avec des valeurs extrêmes
    local originalSpeed = humanoid.WalkSpeed
    local testPassed = false

    pcall(function()
        humanoid.WalkSpeed = 500 -- Valeur clairement suspecte
        wait(0.1)
        if humanoid.WalkSpeed == 500 then
            testPassed = true -- Validation faible si ça passe
        end
        humanoid.WalkSpeed = originalSpeed -- Restaurer
    end)

    return testPassed
end

-- Vérifier le timing prévisible
function AntiCheatDetector:hasPredictableTiming(humanoid)
    -- Observer les patterns de vérification
    local checkTimes = {}
    local connection

    connection = humanoid.Changed:Connect(function()
        table.insert(checkTimes, tick())
        if #checkTimes > 5 then
            connection:Disconnect()
        end
    end)

    -- Déclencher des changements
    for i = 1, 6 do
        humanoid.WalkSpeed = humanoid.WalkSpeed + 1
        wait(0.5)
    end

    -- Analyser la régularité
    if #checkTimes >= 3 then
        local intervals = {}
        for i = 2, #checkTimes do
            table.insert(intervals, checkTimes[i] - checkTimes[i-1])
        end

        -- Si les intervalles sont très similaires, timing prévisible
        local avgInterval = 0
        for _, interval in pairs(intervals) do
            avgInterval = avgInterval + interval
        end
        avgInterval = avgInterval / #intervals

        local variance = 0
        for _, interval in pairs(intervals) do
            variance = variance + (interval - avgInterval)^2
        end
        variance = variance / #intervals

        return variance < 0.1 -- Faible variance = timing prévisible
    end

    return false
end

-- Obtenir la méthode d'exploitation pour une faille
function AntiCheatDetector:getExploitMethod(flaw)
    local methods = {
        [self.flawPatterns.CLIENT_SIDE_ONLY] = "Hook et modification des fonctions locales",
        [self.flawPatterns.NO_ENCRYPTION] = "Interception et modification des données",
        [self.flawPatterns.PREDICTABLE_TIMING] = "Synchronisation avec les vérifications",
        [self.flawPatterns.WEAK_VALIDATION] = "Valeurs graduelles sous le seuil",
        [self.flawPatterns.NO_RATE_LIMITING] = "Spam de fausses données",
        [self.flawPatterns.OBVIOUS_REMOTES] = "Désactivation directe des remotes",
        [self.flawPatterns.EXPOSED_VARIABLES] = "Modification des variables exposées",
        [self.flawPatterns.SIMPLE_THRESHOLD] = "Contournement par micro-incréments"
    }

    return methods[flaw] or "Méthode d'exploitation inconnue"
end

-- Obtenir la sévérité d'une faille
function AntiCheatDetector:getFlawSeverity(flaw)
    local severities = {
        [self.flawPatterns.CLIENT_SIDE_ONLY] = "CRITICAL",
        [self.flawPatterns.WEAK_VALIDATION] = "CRITICAL",
        [self.flawPatterns.NO_ENCRYPTION] = "HIGH",
        [self.flawPatterns.OBVIOUS_REMOTES] = "HIGH",
        [self.flawPatterns.EXPOSED_VARIABLES] = "HIGH",
        [self.flawPatterns.PREDICTABLE_TIMING] = "MEDIUM",
        [self.flawPatterns.NO_RATE_LIMITING] = "MEDIUM",
        [self.flawPatterns.SIMPLE_THRESHOLD] = "LOW"
    }

    return severities[flaw] or "LOW"
end

-- Fonction de scan principale améliorée
function AntiCheatDetector:scanForAntiCheat()
    local currentTime = tick()
    if currentTime - self.lastScan < self.scanInterval then return end
    self.lastScan = currentTime

    self.detectedSystems = {}
    self.activeThreats = {}

    -- Scanner les composants
    self:scanRemotes()
    self:scanScripts()
    self:scanConnections()
    self:scanStatValidators()

    -- NOUVELLE: Analyser les vulnérabilités
    self:analyzeVulnerabilities()

    -- Analyser les patterns
    self:analyzePatterns()

    return #self.detectedSystems > 0
end

-- Fonction de scan des remotes améliorée
function AntiCheatDetector:scanRemotes()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            for _, pattern in pairs(self.patterns.remoteNames) do
                if name:find(pattern) then
                    table.insert(self.detectedSystems, {
                        type = "Remote",
                        object = obj,
                        threat = "Remote Anti-Cheat détecté",
                        severity = "HIGH",
                        location = obj:GetFullName()
                    })
                    break
                end
            end
        end
    end
end

-- Fonction de scan des scripts améliorée
function AntiCheatDetector:scanScripts()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("Script") then
            local name = obj.Name
            for _, pattern in pairs(self.patterns.scriptNames) do
                if name:find(pattern) then
                    table.insert(self.detectedSystems, {
                        type = "Script",
                        object = obj,
                        threat = "Script Anti-Cheat détecté",
                        severity = obj:IsA("LocalScript") and "CRITICAL" or "HIGH",
                        location = obj:GetFullName()
                    })
                    break
                end
            end
        end
    end
end

-- Fonction de scan des connexions
function AntiCheatDetector:scanConnections()
    local connections = getconnections and getconnections(RunService.Heartbeat) or {}
    if #connections > 5 then
        table.insert(self.detectedSystems, {
            type = "Connection",
            object = RunService.Heartbeat,
            threat = "Monitoring par Heartbeat détecté",
            severity = "MEDIUM",
            location = "RunService.Heartbeat"
        })
    end
end

-- Fonction de scan des validateurs de stats
function AntiCheatDetector:scanStatValidators()
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local connections = getconnections and getconnections(humanoid.Changed) or {}
            if #connections > 2 then
                table.insert(self.detectedSystems, {
                    type = "StatValidator",
                    object = humanoid,
                    threat = "Validateur de statistiques détecté",
                    severity = "HIGH",
                    location = "Humanoid.Changed"
                })
            end
        end
    end
end

-- Analyser les patterns de détection
function AntiCheatDetector:analyzePatterns()
    local highSeverityCount = 0
    local criticalCount = 0

    for _, system in pairs(self.detectedSystems) do
        if system.severity == "CRITICAL" then
            criticalCount = criticalCount + 1
        elseif system.severity == "HIGH" then
            highSeverityCount = highSeverityCount + 1
        end
    end

    -- Déterminer le niveau de menace global
    if criticalCount >= 2 then
        table.insert(self.activeThreats, "ADVANCED_ANTICHEAT")
    elseif criticalCount >= 1 or highSeverityCount >= 2 then
        table.insert(self.activeThreats, "MODERATE_ANTICHEAT")
    elseif highSeverityCount >= 1 then
        table.insert(self.activeThreats, "BASIC_ANTICHEAT")
    end
end

-- Système de bypass intelligent exploitant les failles
local AdvancedBypass = {
    hooks = {},
    spoofedRemotes = {},
    exploits = {},
    activeExploits = {},
    memoryProtection = false,
    networkInterception = false,
    heartbeatBypass = false,
    flawExploitation = false
}

-- Exploiter les failles détectées
function AdvancedBypass:exploitFlaws()
    if self.flawExploitation then return end
    self.flawExploitation = true

    for _, vulnerability in pairs(AntiCheatDetector.exploitableFlaws) do
        local exploit = self:createExploit(vulnerability)
        if exploit then
            table.insert(self.activeExploits, exploit)
            exploit:activate()
        end
    end

    LogSystem:addLog(#self.activeExploits .. " failles exploitées avec succès!", "EXPLOIT")
            print("💀 " .. #self.activeExploits .. " failles exploitées avec succès!")
end

-- Créer un exploit spécifique pour une vulnérabilité
function AdvancedBypass:createExploit(vulnerability)
    local flaw = vulnerability.flaw
    local system = vulnerability.system

    if flaw == AntiCheatDetector.flawPatterns.CLIENT_SIDE_ONLY then
        return self:createClientSideExploit(system)
    elseif flaw == AntiCheatDetector.flawPatterns.WEAK_VALIDATION then
        return self:createWeakValidationExploit(system)
    elseif flaw == AntiCheatDetector.flawPatterns.OBVIOUS_REMOTES then
        return self:createRemoteDisableExploit(system)
    elseif flaw == AntiCheatDetector.flawPatterns.PREDICTABLE_TIMING then
        return self:createTimingExploit(system)
    elseif flaw == AntiCheatDetector.flawPatterns.EXPOSED_VARIABLES then
        return self:createVariableExploit(system)
    end

    return nil
end

-- Exploit pour anti-cheat côté client uniquement
function AdvancedBypass:createClientSideExploit(system)
    return {
        name = "Client-Side Disable",
        target = system.object,
        activate = function()
            -- Désactiver complètement le script
            system.object.Disabled = true

            -- Créer un script factice pour tromper les vérifications
            local fakeScript = system.object:Clone()
            fakeScript.Name = system.object.Name
            fakeScript.Parent = system.object.Parent
            fakeScript.Disabled = true -- Mais inactif

            system.object.Name = system.object.Name .. "_DISABLED"
            system.object.Parent = nil

            print("🔥 Script côté client désactivé: " .. system.object.Name)
        end
    }
end

-- Exploit pour validation faible
function AdvancedBypass:createWeakValidationExploit(system)
    return {
        name = "Weak Validation Bypass",
        target = system.object,
        activate = function()
            -- Créer un hook qui intercepte et modifie les valeurs
            local humanoid = system.object
            local originalIndex = humanoid.__index

            humanoid.__index = function(self, key)
                if key == "WalkSpeed" then
                    return math.min(originalIndex(self, key), 16) -- Toujours retourner une valeur "normale"
                elseif key == "JumpPower" then
                    return math.min(originalIndex(self, key), 50)
                end
                return originalIndex(self, key)
            end

            print("🎭 Validation faible contournée via hook")
        end
    }
end

-- Exploit pour remotes évidents
function AdvancedBypass:createRemoteDisableExploit(system)
    return {
        name = "Remote Neutralization",
        target = system.object,
        activate = function()
            local remote = system.object

            if remote:IsA("RemoteEvent") then
                -- Remplacer FireServer par une fonction vide
                local originalFireServer = remote.FireServer
                remote.FireServer = function() 
                    -- Ne rien faire - neutraliser complètement
                end

                -- Sauvegarder pour restauration
                table.insert(self.hooks, {remote = remote, original = originalFireServer})

            elseif remote:IsA("RemoteFunction") then
                -- Remplacer par une fonction qui retourne toujours "OK"
                local originalInvokeServer = remote.InvokeServer
                remote.InvokeServer = function()
                    return "OK" -- Réponse factice
                end

                table.insert(self.hooks, {remote = remote, original = originalInvokeServer})
            end

            print("🚫 Remote neutralisé: " .. remote.Name)
        end
    }
end

-- Exploit pour timing prévisible
function AdvancedBypass:createTimingExploit(system)
    return {
        name = "Timing Sync Exploit",
        target = system.object,
        checkInterval = 0,
        activate = function(self)
            -- Observer et synchroniser avec le timing de vérification
            local lastCheck = tick()
            local connection

            connection = system.object.Changed:Connect(function()
                local now = tick()
                self.checkInterval = now - lastCheck
                lastCheck = now

                -- Après avoir appris le timing, se déconnecter
                if self.checkInterval > 0 then
                    connection:Disconnect()

                    -- Maintenant synchroniser nos changements juste après chaque vérification
                    spawn(function()
                        while boostActive do
                            wait(self.checkInterval + 0.05) -- Juste après la vérification
                            if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                                local humanoid = player.Character.Humanoid
                                humanoid.WalkSpeed = currentSpeed
                                humanoid.JumpPower = currentJumpPower
                            end
                        end
                    end)
                end
            end)

            print("🕐 Timing synchronisé - intervalle: " .. self.checkInterval .. "s")
        end
    }
end

-- Exploit pour variables exposées
function AdvancedBypass:createVariableExploit(system)
    return {
        name = "Variable Manipulation",
        target = system.object,
        activate = function()
            -- Chercher et modifier les variables exposées
            for _, child in pairs(system.object:GetChildren()) do
                if child:IsA("NumberValue") then
                    if child.Name:find("MaxSpeed") or child.Name:find("SpeedLimit") then
                        child.Value = 999 -- Augmenter la limite
                        print("📊 Variable modifiée: " .. child.Name .. " = " .. child.Value)
                    elseif child.Name:find("CheckInterval") then
                        child.Value = 999 -- Réduire la fréquence de vérification
                        print("📊 Variable modifiée: " .. child.Name .. " = " .. child.Value)
                    end
                elseif child:IsA("BoolValue") then
                    if child.Name:find("Enabled") or child.Name:find("Active") then
                        child.Value = false -- Désactiver
                        print("📊 Variable modifiée: " .. child.Name .. " = " .. child.Value)
                    end
                end
            end
        end
    }
end

-- Fonction principale d'activation du bypass adaptatif
function AdvancedBypass:activate()
    if bypassEnabled then return end
    bypassEnabled = true

    -- Scanner et analyser les vulnérabilités
    AntiCheatDetector:scanForAntiCheat()

    -- Exploiter les failles trouvées
    self:exploitFlaws()

    -- Activer les systèmes de protection standards
    self:setupAdaptiveNetworkInterception()
    self:setupAdvancedMemoryProtection()
    self:setupAdaptiveHeartbeatBypass()

    print("🛡️ Bypass Adaptatif activé avec exploitation de failles")
    print("📊 " .. #AntiCheatDetector.detectedSystems .. " systèmes analysés")
    print("💀 " .. #AntiCheatDetector.exploitableFlaws .. " failles exploitables")
    print("⚠️ " .. #AntiCheatDetector.activeThreats .. " menaces actives")
end

-- Fonction de désactivation améliorée
function AdvancedBypass:deactivate()
    bypassEnabled = false
    self.networkInterception = false
    self.memoryProtection = false
    self.heartbeatBypass = false
    self.flawExploitation = false
    gradualSpeedActive = false

    -- Nettoyer toutes les connexions
    for _, connection in pairs(bypassConnections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    bypassConnections = {}

    -- Nettoyer les exploits actifs
    for _, exploit in pairs(self.activeExploits) do
        if exploit.deactivate then
            exploit:deactivate()
        end
    end
    self.activeExploits = {}

    -- Nettoyer les hooks
    for _, hook in pairs(self.hooks) do
        if hook.remote and hook.original then
            if hook.remote:IsA("RemoteEvent") then
                hook.remote.FireServer = hook.original
            elseif hook.remote:IsA("RemoteFunction") then
                hook.remote.InvokeServer = hook.original
            end
        end
    end
    self.hooks = {}

    -- Réactiver les scripts désactivés
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            if obj.Name:find("_DISABLED") then
                obj.Name = obj.Name:gsub("_DISABLED", "")
                obj.Disabled = false
            end
        end
    end

    -- Nettoyer les variables
    AntiCheatDetector.detectedSystems = {}
    AntiCheatDetector.activeThreats = {}
    AntiCheatDetector.vulnerabilities = {}
    AntiCheatDetector.exploitableFlaws = {}
    spoofedStats = {}

    print("🛡️ Bypass Adaptatif désactivé - Exploits nettoyés")
end

-- Services de protection réseau et mémoire (identiques)
function AdvancedBypass:setupAdaptiveNetworkInterception()
    if self.networkInterception then return end
    self.networkInterception = true

    spawn(function()
        while self.networkInterception do
            AntiCheatDetector:scanForAntiCheat()
            self:exploitFlaws()
            wait(3)
        end
    end)

    game.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            for _, pattern in pairs(AntiCheatDetector.patterns.remoteNames) do
                if name:find(pattern) then
                    wait(0.1)
                    -- Analyser immédiatement les nouvelles failles
                    local newSystem = {type = "Remote", object = obj, threat = "Nouveau remote détecté", severity = "HIGH"}
                    table.insert(AntiCheatDetector.detectedSystems, newSystem)

                    local flaws = AntiCheatDetector:findSystemFlaws(newSystem)
                    for _, flaw in pairs(flaws) do
                        local vuln = {
                            system = newSystem,
                            flaw = flaw,
                            exploitMethod = AntiCheatDetector:getExploitMethod(flaw),
                            severity = AntiCheatDetector:getFlawSeverity(flaw)
                        }

                        if vuln.severity == "CRITICAL" or vuln.severity == "HIGH" then
                            local exploit = self:createExploit(vuln)
                            if exploit then
                                table.insert(self.activeExploits, exploit)
                                exploit:activate()
                            end
                        end
                    end
                    break
                end
            end
        end
    end)
end

function AdvancedBypass:setupAdvancedMemoryProtection()
    if self.memoryProtection then return end
    self.memoryProtection = true

    for layer = 1, 3 do
        local decoyFolder = Instance.new("Folder")
        decoyFolder.Name = "PlayerMetrics_" .. layer
        decoyFolder.Parent = workspace

        spawn(function()
            while self.memoryProtection do
                local fakeSpeed = Instance.new("NumberValue")
                fakeSpeed.Name = "CurrentSpeed"
                fakeSpeed.Value = math.random(14, 18)
                fakeSpeed.Parent = decoyFolder

                local fakePosition = Instance.new("Vector3Value")
                fakePosition.Name = "LastPosition"
                if player.Character and player.Character.HumanoidRootPart then
                    fakePosition.Value = player.Character.HumanoidRootPart.Position
                end
                fakePosition.Parent = decoyFolder

                wait(math.random(1, 3))

                if fakeSpeed.Parent then fakeSpeed:Destroy() end
                if fakePosition.Parent then fakePosition:Destroy() end
            end
        end)
    end
end

function AdvancedBypass:setupAdaptiveHeartbeatBypass()
    if self.heartbeatBypass then return end
    self.heartbeatBypass = true

    local lastSpeedCheck = 0
    local checkInterval = 0.5

    local heartbeatConnection = RunService.Heartbeat:Connect(function()
        local character = player.Character
        if not character or not boostActive then return end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        local currentTime = tick()
        if currentTime - lastSpeedCheck < checkInterval then return end
        lastSpeedCheck = currentTime

        if #AntiCheatDetector.activeThreats > 0 then
            checkInterval = math.random(0.1, 0.3)
        else
            checkInterval = math.random(0.5, 1.0)
        end

        local targetSpeed = currentSpeed + math.random(-2, 2)
        if humanoid.WalkSpeed ~= targetSpeed and boostActive then
            humanoid.WalkSpeed = targetSpeed
        end

        local targetJump = currentJumpPower + math.random(-5, 5)
        if humanoid.JumpPower ~= targetJump and boostActive then
            humanoid.JumpPower = targetJump
        end
    end)

    table.insert(bypassConnections, heartbeatConnection)
end

-- Variables de détection
local adminPanelDetected = false
local detectedPanels = {}
local scanActive = false
local processedPanels = {} -- Garder trace des panels déjà traités

-- Variables du panel de recherche personnalisé
local searchFrame = nil
local searchActive = false
local customSearchTerms = {}
local foundCustomItems = {}

-- Système de suivi des objets révélés
local RevealTracker = {
    revealedObjects = {},
    originalStates = {}
}

-- Enregistrer l'état original d'un objet
function RevealTracker:recordOriginalState(obj)
    local objPath = obj:GetFullName()
    
    if not self.originalStates[objPath] then
        if obj:IsA("ScreenGui") then
            self.originalStates[objPath] = {
                object = obj,
                type = "ScreenGui",
                originalState = obj.Enabled
            }
        elseif obj:IsA("GuiObject") then
            self.originalStates[objPath] = {
                object = obj,
                type = "GuiObject",
                originalState = obj.Visible
            }
        elseif obj:IsA("LocalScript") or obj:IsA("Script") then
            self.originalStates[objPath] = {
                object = obj,
                type = "Script",
                originalState = obj.Disabled
            }
        end
    end
end

-- Marquer un objet comme révélé
function RevealTracker:markAsRevealed(obj)
    local objPath = obj:GetFullName()
    self.revealedObjects[objPath] = {
        object = obj,
        revealTime = tick(),
        type = obj.ClassName
    }
end

-- Cacher tous les objets révélés
function RevealTracker:hideAllRevealed()
    local hiddenCount = 0
    
    print("🙈 Masquage de tous les éléments révélés en cours...")
    LogSystem:addLog("Début du masquage des éléments révélés", "INFO")
    
    -- Parcourir tous les objets révélés
    for objPath, revealInfo in pairs(self.revealedObjects) do
        local obj = revealInfo.object
        
        -- Vérifier que l'objet existe encore
        if obj and obj.Parent then
            local originalState = self.originalStates[objPath]
            
            if originalState then
                -- Restaurer l'état original
                if originalState.type == "ScreenGui" and obj:IsA("ScreenGui") then
                    obj.Enabled = originalState.originalState
                    hiddenCount = hiddenCount + 1
                    print("🙈 ScreenGui masqué: " .. obj.Name)
                elseif originalState.type == "GuiObject" and obj:IsA("GuiObject") then
                    obj.Visible = originalState.originalState
                    hiddenCount = hiddenCount + 1
                    print("🙈 GuiObject masqué: " .. obj.Name)
                elseif originalState.type == "Script" and (obj:IsA("LocalScript") or obj:IsA("Script")) then
                    obj.Disabled = originalState.originalState
                    hiddenCount = hiddenCount + 1
                    print("🙈 Script masqué: " .. obj.Name)
                end
            else
                -- Si pas d'état original enregistré, masquer par défaut
                if obj:IsA("ScreenGui") then
                    obj.Enabled = false
                    hiddenCount = hiddenCount + 1
                elseif obj:IsA("GuiObject") then
                    obj.Visible = false
                    hiddenCount = hiddenCount + 1
                elseif obj:IsA("LocalScript") or obj:IsA("Script") then
                    obj.Disabled = true
                    hiddenCount = hiddenCount + 1
                end
                print("🙈 Objet masqué (défaut): " .. obj.Name)
            end
            
            LogSystem:addLog("Masqué: " .. obj.Name .. " (" .. revealInfo.type .. ")", "SUCCESS")
        end
    end
    
    -- Nettoyer les listes
    self.revealedObjects = {}
    
    -- Masquer aussi les panels spéciaux
    if searchFrame and searchFrame.Visible then
        searchFrame.Visible = false
        searchActive = false
        hiddenCount = hiddenCount + 1
    end
    
    if logsFrame and logsFrame.Visible then
        logsFrame.Visible = false
        hiddenCount = hiddenCount + 1
    end
    
    -- Nettoyer les panels traités
    processedPanels = {}
    foundCustomItems = {}
    
    print("🎉 Masquage terminé!")
    print("✅ " .. hiddenCount .. " élément(s) masqué(s)!")
    LogSystem:addLog("Masquage terminé: " .. hiddenCount .. " éléments masqués", "SUCCESS")
    
    return hiddenCount
end

-- Système de détection d'admin panel
local AdminPanelDetector = {
    patterns = {
        guiNames = {
            "admin", "adminpanel", "moderator", "mod", "staff", "owner", 
            "developer", "console", "command", "executor", "dashboard", 
            "tools", "controls", "management", "gameadmin", "propriétaire",
            "proprietaire", "créateur", "createur", "fondateur", "patron",
            "chef", "boss", "leader", "directeur", "manager", "responsable",
            "vip", "premium", "donateur", "sponsor", "role", "rank", "grade"
        },
        suspiciousNames = {
            "AdminPanel", "ModPanel", "StaffGUI", "OwnerGUI", "AdminGUI",
            "ControlPanel", "Dashboard", "AdminTools", "ModTools", "DevTools",
            "CommandCenter", "AdminConsole", "StaffPanel", "AdminInterface",
            "GameAdminPanel", "ServerTools", "ModeratorTools", "ProprietaireGUI",
            "CreateurPanel", "FondateurGUI", "VIPPanel", "PremiumGUI", "RolePanel",
            "RankPanel", "GradeGUI", "ChefPanel", "BossGUI", "LeaderPanel"
        },
        buttonTexts = {
            "ban", "kick", "teleport", "give", "remove", "delete", "kill",
            "fly", "noclip", "speed", "jump", "money", "coins", "points",
            "admin", "mod", "staff", "owner", "dev", "developer", "créateur", "fondateur",
            "propriétaire", "proprietaire", "patron", "chef", "boss", "leader", 
            "directeur", "manager", "responsable", "vip", "premium", "donateur",
            "role", "rôle", "rank", "grade", "niveau", "statut", "permission",
            "autorisation", "accès", "access", "privilège", "privilege",
            "mute", "unmute", "warn", "jail", "unjail", "freeze", "unfreeze",
            "heal", "god", "ungod", "invisible", "visible", "tp", "bring",
            "goto", "spawn", "respawn", "reset", "clear", "clean", "refresh",
            "reload", "restart", "shutdown", "announce", "message", "broadcast",
            "whitelist", "unwhitelist", "promote", "demote", "rank", "setrank",
            "gamepass", "badge", "shirt", "pants", "accessory", "gear", "tool",
            "weather", "time", "lighting", "music", "sound", "volume",
            "private", "public", "vip", "premium", "donate", "robux",
            "execute", "script", "command", "console", "terminal", "debug",
            "logs", "history", "player", "players", "user", "users",
            "settings", "config", "options", "preferences", "controls",
            "menu", "home", "back", "close", "exit", "quit", "save", "load",
            "export", "import", "backup", "restore", "update", "patch",
            "version", "info", "help", "about", "credit", "credits"
        }
    },
    foundPanels = {}
}

-- Fonction de scan pour admin panels
function AdminPanelDetector:scanForAdminPanels()
    self.foundPanels = {}

    -- Scanner dans PlayerGui (interfaces du jeu)
    self:scanInContainer(playerGui, "PlayerGui")

    -- Scanner dans StarterGui (si accessible)
    pcall(function()
        self:scanInContainer(game:GetService("StarterGui"), "StarterGui")
    end)

    -- Scanner dans ReplicatedStorage pour les GUIs stockés
    pcall(function()
        local storage = game:GetService("ReplicatedStorage")
        for _, obj in pairs(storage:GetDescendants()) do
            if (obj:IsA("ScreenGui") or obj:IsA("Frame")) and self:isAdminPanel(obj) and not self:isRobloxSystemUI(obj) then
                table.insert(self.foundPanels, {
                    object = obj,
                    location = "ReplicatedStorage",
                    type = obj.ClassName,
                    name = obj.Name,
                    fullPath = obj:GetFullName()
                })
            end
        end
    end)

    return #self.foundPanels > 0
end

-- Scanner un conteneur spécifique
function AdminPanelDetector:scanInContainer(container, containerName)
    for _, obj in pairs(container:GetDescendants()) do
        if obj:IsA("ScreenGui") or obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextLabel") then
            local objPath = obj:GetFullName()

            -- Ignorer les interfaces système Roblox
            if self:isRobloxSystemUI(obj) then
                continue
            end

            -- Vérifier si ce panel n'a pas déjà été traité
            if not processedPanels[objPath] and self:isAdminPanel(obj) then
                table.insert(self.foundPanels, {
                    object = obj,
                    location = containerName,
                    type = obj.ClassName,
                    name = obj.Name,
                    fullPath = objPath
                })
            end
        end
    end
end

-- Vérifier si c'est une interface système Roblox à ignorer
function AdminPanelDetector:isRobloxSystemUI(obj)
    local objPath = obj:GetFullName()
    
    -- Interfaces système Roblox à ignorer
    local systemPaths = {
        "CoreGui",
        "RobloxGui",
        "CorePackages",
        "Chat",
        "Backpack",
        "PlayerList",
        "Freecam",
        "Settings",
        "Menu",
        "Purchase",
        "InGameMenu",
        "EmotesMenu",
        "NotificationGui",
        "BubbleChat",
        "TopBar",
        "HealthGui",
        "LoadingGui",
        "ErrorGui",
        "VehicleGui",
        "PurchasePrompt"
    }
    
    -- Noms d'interfaces système à ignorer
    local systemNames = {
        "RobloxGui", "Chat", "Backpack", "PlayerList", "Settings", 
        "InGameMenu", "TopBar", "HealthGui", "PurchasePrompt",
        "NotificationGui", "EmotesMenu", "BubbleChat", "LoadingGui",
        "TouchGui", "DevConsoleUI", "CoreGui", "SystemGui"
    }
    
    -- Vérifier le chemin complet
    for _, systemPath in pairs(systemPaths) do
        if objPath:find(systemPath) then
            return true
        end
    end
    
    -- Vérifier le nom de l'objet
    for _, systemName in pairs(systemNames) do
        if obj.Name:find(systemName) then
            return true
        end
    end
    
    -- Vérifier si c'est dans CoreGui (interfaces système)
    if objPath:find("CoreGui") and not objPath:find("PlayerGui") then
        return true
    end
    
    return false
end

-- Vérifier si un objet est un admin panel
function AdminPanelDetector:isAdminPanel(obj)
    local name = obj.Name:lower()
    local text = ""

    -- Obtenir le texte si c'est un TextButton ou TextLabel
    if obj:IsA("TextButton") or obj:IsA("TextLabel") then
        text = obj.Text:lower()
    end

    -- Vérifier les noms suspects
    for _, pattern in pairs(self.patterns.suspiciousNames) do
        if name:find(pattern:lower()) then
            return true
        end
    end

    -- Vérifier les patterns dans le nom
    local adminFound = false
    local panelFound = false

    for _, pattern in pairs(self.patterns.guiNames) do
        if name:find(pattern) then
            if pattern == "admin" or pattern == "mod" or pattern == "staff" or pattern == "owner" then
                adminFound = true
            elseif pattern == "panel" or pattern == "gui" or pattern == "interface" or pattern == "dashboard" then
                panelFound = true
            end
        end

        -- Vérifier aussi dans le texte
        if text:find(pattern) then
            if pattern == "admin" or pattern == "mod" or pattern == "staff" or pattern == "owner" then
                adminFound = true
            elseif pattern == "panel" or pattern == "gui" or pattern == "interface" or pattern == "dashboard" then
                panelFound = true
            end
        end
    end

    -- Si on trouve à la fois "admin" et "panel" (ou équivalents)
    if adminFound and panelFound then
        return true
    end

    -- Vérifier les textes de boutons suspects
    for _, buttonText in pairs(self.patterns.buttonTexts) do
        if text:find(buttonText) then
            return true
        end
    end

    -- Vérifier si l'objet a plusieurs enfants avec des noms suspects
    if obj:IsA("ScreenGui") or obj:IsA("Frame") then
        local suspiciousChildren = 0
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then
                local childName = child.Name:lower()
                local childText = ""
                if child:IsA("TextButton") or child:IsA("TextLabel") then
                    childText = child.Text:lower()
                end

                for _, pattern in pairs(self.patterns.guiNames) do
                    if childName:find(pattern) or childText:find(pattern) then
                        suspiciousChildren = suspiciousChildren + 1
                        break
                    end
                end
            end
        end

        -- Si 3+ enfants suspects, probablement un admin panel
        if suspiciousChildren >= 3 then
            return true
        end
    end

    return false
end

-- Fonction pour faire apparaître les admin panels détectés
function AdminPanelDetector:showDetectedPanels()
    local newPanelsShown = 0

    for _, panel in pairs(self.foundPanels) do
        local obj = panel.object
        local objPath = panel.fullPath

        -- Vérifier si ce panel n'a pas déjà été affiché
        if not processedPanels[objPath] then
            -- Enregistrer l'état original avant modification
            RevealTracker:recordOriginalState(obj)
            
            -- Rendre visible s'il était caché
            if obj:IsA("ScreenGui") then
                obj.Enabled = true
                RevealTracker:markAsRevealed(obj)
            elseif obj:IsA("GuiObject") then
                obj.Visible = true
                RevealTracker:markAsRevealed(obj)

                -- Remonter la hiérarchie pour rendre visible les parents
                local parent = obj.Parent
                while parent and parent:IsA("GuiObject") do
                    RevealTracker:recordOriginalState(parent)
                    parent.Visible = true
                    RevealTracker:markAsRevealed(parent)
                    parent = parent.Parent
                end

                -- Rendre visible le ScreenGui parent si nécessaire
                local screenGui = obj:FindFirstAncestorOfClass("ScreenGui")
                if screenGui then
                    RevealTracker:recordOriginalState(screenGui)
                    screenGui.Enabled = true
                    RevealTracker:markAsRevealed(screenGui)
                end
            end

            -- Marquer comme traité
            processedPanels[objPath] = true
            newPanelsShown = newPanelsShown + 1

            print("✅ Admin Panel rendu visible: " .. panel.name .. " (" .. panel.type .. ")")
            print("📍 Localisation: " .. panel.location)
            print("🔗 Chemin complet: " .. panel.fullPath)
        end
    end

    return newPanelsShown
end

-- Fonction principale de détection et affichage
function detectAndShowAdminPanels()
    local found = AdminPanelDetector:scanForAdminPanels()

    if found then
        adminPanelDetected = true
        detectedPanels = AdminPanelDetector.foundPanels

        -- Faire apparaître seulement les nouveaux panels détectés
        local newPanelsShown = AdminPanelDetector:showDetectedPanels()

        if newPanelsShown > 0 then
            LogSystem:addLog(newPanelsShown .. " nouveau(x) admin panel(s) rendu(s) visible(s)!", "DETECTION")
            print("🎯 " .. newPanelsShown .. " nouveau(x) admin panel(s) rendu(s) visible(s)!")
        end

        return true
    end

    return false
end

-- Scanner en continu pour nouveaux admin panels
function startAdminPanelMonitoring()
    if scanActive then return end
    scanActive = true

    print("👁️ Surveillance d'admin panels activée")

    -- Scanner initial
    detectAndShowAdminPanels()

    spawn(function()
        while scanActive do
            detectAndShowAdminPanels()
            wait(5) -- Scanner toutes les 5 secondes (réduit la fréquence)
        end
    end)

    -- Surveiller les nouveaux GUIs ajoutés
    game.DescendantAdded:Connect(function(obj)
        if not scanActive then return end

        if obj:IsA("ScreenGui") or obj:IsA("Frame") or obj:IsA("TextButton") then
            wait(0.5) -- Attendre que l'objet soit entièrement chargé

            local objPath = obj:GetFullName()

            -- Vérifier si ce panel n'a pas déjà été traité
            if not processedPanels[objPath] and AdminPanelDetector:isAdminPanel(obj) then
                local panel = {
                    object = obj,
                    location = obj.Parent and obj.Parent.Name or "Unknown",
                    type = obj.ClassName,
                    name = obj.Name,
                    fullPath = objPath
                }

                table.insert(AdminPanelDetector.foundPanels, panel)

                print("🆕 Nouveau admin panel détecté: " .. obj.Name)

                -- Afficher immédiatement ce nouveau panel
                AdminPanelDetector.foundPanels = {panel} -- Temporairement juste ce panel
                AdminPanelDetector:showDetectedPanels()
            end
        end
    end)
end

-- Arrêter la surveillance
function stopAdminPanelMonitoring()
    scanActive = false
    print("👁️ Surveillance d'admin panels désactivée")
end

-- Système de recherche personnalisé
local CustomSearchSystem = {
    results = {},
    maxResults = 50
}

-- Créer le panel de recherche
function CustomSearchSystem:createSearchPanel()
    if searchFrame then
        searchFrame:Destroy()
    end

    -- Créer le panel principal
    searchFrame = Instance.new("Frame")
    searchFrame.Name = "CustomSearchPanel"
    searchFrame.Size = UDim2.new(0, 500, 0, 600)
    searchFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    searchFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    searchFrame.BorderSizePixel = 3
    searchFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    searchFrame.Visible = false
    searchFrame.Parent = playerGui

    -- Titre
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    titleLabel.Text = "🔍 RECHERCHE PERSONNALISÉE"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = searchFrame

    -- Bouton fermer
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -40, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = searchFrame

    closeButton.MouseButton1Click:Connect(function()
        searchFrame.Visible = false
        searchActive = false
    end)

    -- Zone de saisie
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, -20, 0, 35)
    searchBox.Position = UDim2.new(0, 10, 0, 50)
    searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    searchBox.BorderSizePixel = 2
    searchBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
    searchBox.Text = ""
    searchBox.PlaceholderText = "Entrez le terme à rechercher..."
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.TextSize = 16
    searchBox.Font = Enum.Font.SourceSans
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = searchFrame

    -- Bouton rechercher
    local searchButton = Instance.new("TextButton")
    searchButton.Name = "SearchButton"
    searchButton.Size = UDim2.new(0, 100, 0, 30)
    searchButton.Position = UDim2.new(0, 10, 0, 95)
    searchButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    searchButton.Text = "🔍 Chercher"
    searchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchButton.TextScaled = true
    searchButton.Font = Enum.Font.SourceSansBold
    searchButton.Parent = searchFrame

    -- Bouton tout afficher
    local showAllButton = Instance.new("TextButton")
    showAllButton.Name = "ShowAllButton"
    showAllButton.Size = UDim2.new(0, 120, 0, 30)
    showAllButton.Position = UDim2.new(0, 120, 0, 95)
    showAllButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    showAllButton.Text = "👁️ Tout Afficher"
    showAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    showAllButton.TextScaled = true
    showAllButton.Font = Enum.Font.SourceSansBold
    showAllButton.Parent = searchFrame

    -- Zone de résultats
    local resultsFrame = Instance.new("ScrollingFrame")
    resultsFrame.Name = "ResultsFrame"
    resultsFrame.Size = UDim2.new(1, -20, 1, -140)
    resultsFrame.Position = UDim2.new(0, 10, 0, 130)
    resultsFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    resultsFrame.BorderSizePixel = 2
    resultsFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
    resultsFrame.ScrollBarThickness = 12
    resultsFrame.Parent = searchFrame

    -- Événements
    searchButton.MouseButton1Click:Connect(function()
        local searchTerm = searchBox.Text:lower()
        if searchTerm ~= "" then
            self:performCustomSearch(searchTerm)
        end
    end)

    showAllButton.MouseButton1Click:Connect(function()
        self:showAllFoundItems()
    end)

    searchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local searchTerm = searchBox.Text:lower()
            if searchTerm ~= "" then
                self:performCustomSearch(searchTerm)
            end
        end
    end)

    -- Rendre draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil

    titleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = searchFrame.Position
        end
    end)

    titleLabel.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            searchFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    titleLabel.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Effectuer une recherche personnalisée
function CustomSearchSystem:performCustomSearch(searchTerm)
    self.results = {}
    foundCustomItems = {}

    print("🔍 Recherche de: '" .. searchTerm .. "'")
    LogSystem:addLog("Recherche personnalisée: " .. searchTerm, "INFO")

    -- Rechercher dans tous les objets du jeu (sauf interfaces Roblox système)
    for _, obj in pairs(game:GetDescendants()) do
        if self:shouldSearchObject(obj) and self:matchesSearchTerm(obj, searchTerm) then
            local result = {
                object = obj,
                name = obj.Name,
                className = obj.ClassName,
                location = obj.Parent and obj.Parent.Name or "Unknown",
                fullPath = obj:GetFullName(),
                searchTerm = searchTerm,
                matchType = self:getMatchType(obj, searchTerm)
            }

            table.insert(self.results, result)
            table.insert(foundCustomItems, result)

            -- Limiter les résultats
            if #self.results >= self.maxResults then
                break
            end
        end
    end

    -- Afficher les résultats
    self:displayResults()

    print("✅ Recherche terminée: " .. #self.results .. " résultat(s) trouvé(s)")
    LogSystem:addLog(#self.results .. " résultats trouvés pour: " .. searchTerm, "SUCCESS")
end

-- Vérifier si on doit rechercher dans cet objet
function CustomSearchSystem:shouldSearchObject(obj)
    local objPath = obj:GetFullName()

    -- Ignorer les interfaces système Roblox
    local systemPaths = {
        "CoreGui", "RobloxGui", "CorePackages", "Chat", "Backpack", 
        "PlayerList", "Settings", "InGameMenu", "TopBar", "HealthGui",
        "PurchasePrompt", "NotificationGui", "EmotesMenu", "BubbleChat"
    }

    for _, systemPath in pairs(systemPaths) do
        if objPath:find(systemPath) then
            return false
        end
    end

    -- Accepter seulement les objets intéressants
    local interestingTypes = {
        "ScreenGui", "Frame", "TextButton", "TextLabel", "ImageLabel",
        "LocalScript", "Script", "RemoteEvent", "RemoteFunction",
        "Folder", "Configuration", "StringValue", "NumberValue",
        "BoolValue", "ObjectValue", "Model", "Part", "Tool"
    }

    for _, interestingType in pairs(interestingTypes) do
        if obj:IsA(interestingType) then
            return true
        end
    end

    return false
end

-- Vérifier si l'objet correspond au terme de recherche
function CustomSearchSystem:matchesSearchTerm(obj, searchTerm)
    local name = obj.Name:lower()
    local text = ""

    -- Obtenir le texte si disponible
    if obj:IsA("TextButton") or obj:IsA("TextLabel") then
        text = obj.Text:lower()
    end

    -- Recherche dans le nom
    if name:find(searchTerm) then
        return true
    end

    -- Recherche dans le texte
    if text:find(searchTerm) then
        return true
    end

    -- Recherche dans le nom de la classe
    if obj.ClassName:lower():find(searchTerm) then
        return true
    end

    -- Recherche dans les propriétés textuelles si disponibles
    pcall(function()
        for _, property in pairs({"Value", "Source", "Caption", "Title"}) do
            if obj[property] and type(obj[property]) == "string" then
                if obj[property]:lower():find(searchTerm) then
                    return true
                end
            end
        end
    end)

    return false
end

-- Déterminer le type de correspondance
function CustomSearchSystem:getMatchType(obj, searchTerm)
    local name = obj.Name:lower()
    local text = ""

    if obj:IsA("TextButton") or obj:IsA("TextLabel") then
        text = obj.Text:lower()
    end

    if name == searchTerm then
        return "Nom exact"
    elseif text == searchTerm then
        return "Texte exact"
    elseif name:find("^" .. searchTerm) then
        return "Début du nom"
    elseif text:find("^" .. searchTerm) then
        return "Début du texte"
    elseif name:find(searchTerm) then
        return "Dans le nom"
    elseif text:find(searchTerm) then
        return "Dans le texte"
    else
        return "Autre correspondance"
    end
end

-- Afficher les résultats
function CustomSearchSystem:displayResults()
    if not searchFrame then return end

    local resultsFrame = searchFrame:FindFirstChild("ResultsFrame")
    if not resultsFrame then return end

    -- Nettoyer les anciens résultats
    for _, child in pairs(resultsFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    -- Afficher les nouveaux résultats
    for i, result in pairs(self.results) do
        local resultFrame = Instance.new("Frame")
        resultFrame.Name = "Result" .. i
        resultFrame.Size = UDim2.new(1, -15, 0, 80)
        resultFrame.Position = UDim2.new(0, 5, 0, (i-1) * 85)
        resultFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        resultFrame.BorderSizePixel = 1
        resultFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
        resultFrame.Parent = resultsFrame

        -- Nom de l'objet
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -10, 0, 20)
        nameLabel.Position = UDim2.new(0, 5, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "📦 " .. result.name .. " (" .. result.className .. ")"
        nameLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        nameLabel.TextScaled = false
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = resultFrame

        -- Type de correspondance
        local matchLabel = Instance.new("TextLabel")
        matchLabel.Size = UDim2.new(1, -10, 0, 15)
        matchLabel.Position = UDim2.new(0, 5, 0, 25)
        matchLabel.BackgroundTransparency = 1
        matchLabel.Text = "🎯 " .. result.matchType
        matchLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        matchLabel.TextScaled = false
        matchLabel.TextSize = 12
        matchLabel.Font = Enum.Font.SourceSans
        matchLabel.TextXAlignment = Enum.TextXAlignment.Left
        matchLabel.Parent = resultFrame

        -- Localisation
        local locationLabel = Instance.new("TextLabel")
        locationLabel.Size = UDim2.new(1, -10, 0, 15)
        locationLabel.Position = UDim2.new(0, 5, 0, 40)
        locationLabel.BackgroundTransparency = 1
        locationLabel.Text = "📍 " .. result.location
        locationLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        locationLabel.TextScaled = false
        locationLabel.TextSize = 11
        locationLabel.Font = Enum.Font.SourceSans
        locationLabel.TextXAlignment = Enum.TextXAlignment.Left
        locationLabel.Parent = resultFrame

        -- Bouton afficher
        local showButton = Instance.new("TextButton")
        showButton.Size = UDim2.new(0, 80, 0, 15)
        showButton.Position = UDim2.new(1, -85, 0, 55)
        showButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        showButton.Text = "👁️ Afficher"
        showButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        showButton.TextScaled = true
        showButton.Font = Enum.Font.SourceSans
        showButton.Parent = resultFrame

        showButton.MouseButton1Click:Connect(function()
            self:makeObjectVisible(result.object)
            LogSystem:addLog("Objet rendu visible: " .. result.name, "SUCCESS")
        end)
    end

    -- Ajuster la taille du contenu
    resultsFrame.CanvasSize = UDim2.new(0, 0, 0, #self.results * 85)
end

-- Rendre un objet visible
function CustomSearchSystem:makeObjectVisible(obj)
    -- Enregistrer l'état original avant modification
    RevealTracker:recordOriginalState(obj)
    
    if obj:IsA("ScreenGui") then
        obj.Enabled = true
        RevealTracker:markAsRevealed(obj)
        print("✅ ScreenGui rendu visible: " .. obj.Name)
    elseif obj:IsA("GuiObject") then
        obj.Visible = true
        RevealTracker:markAsRevealed(obj)

        -- Remonter la hiérarchie pour rendre visible les parents
        local parent = obj.Parent
        while parent and parent:IsA("GuiObject") do
            RevealTracker:recordOriginalState(parent)
            parent.Visible = true
            RevealTracker:markAsRevealed(parent)
            parent = parent.Parent
        end

        -- Rendre visible le ScreenGui parent
        local screenGui = obj:FindFirstAncestorOfClass("ScreenGui")
        if screenGui then
            RevealTracker:recordOriginalState(screenGui)
            screenGui.Enabled = true
            RevealTracker:markAsRevealed(screenGui)
        end

        print("✅ GuiObject rendu visible: " .. obj.Name)
    elseif obj:IsA("Script") or obj:IsA("LocalScript") then
        RevealTracker:recordOriginalState(obj)
        obj.Disabled = false
        RevealTracker:markAsRevealed(obj)
        print("✅ Script activé: " .. obj.Name)
    else
        print("✅ Objet traité: " .. obj.Name .. " (" .. obj.ClassName .. ")")
    end
end

-- Afficher tous les objets trouvés
function CustomSearchSystem:showAllFoundItems()
    if #foundCustomItems == 0 then
        print("⚠️ Aucun objet à afficher")
        return
    end

    local shownCount = 0
    for _, result in pairs(foundCustomItems) do
        self:makeObjectVisible(result.object)
        shownCount = shownCount + 1
    end

    print("✅ " .. shownCount .. " objet(s) rendu(s) visible(s)!")
    LogSystem:addLog(shownCount .. " objets rendus visibles", "SUCCESS")
end

-- Toggle du panel de recherche
function CustomSearchSystem:togglePanel()
    if not searchFrame then
        self:createSearchPanel()
    end

    searchFrame.Visible = not searchFrame.Visible
    searchActive = searchFrame.Visible

    if searchActive then
        print("🔍 Panel de recherche ouvert")
        LogSystem:addLog("Panel de recherche ouvert", "INFO")
    else
        print("🔍 Panel de recherche fermé")
        LogSystem:addLog("Panel de recherche fermé", "INFO")
    end
end

-- Lancer la détection au démarrage
print("🚀 Script Admin Panel Detector chargé")
print("📝 Commandes disponibles:")
print("  - detectAndShowAdminPanels() : Scanner et afficher les admin panels")
print("  - startAdminPanelMonitoring() : Démarrer la surveillance continue")
print("  - stopAdminPanelMonitoring() : Arrêter la surveillance")

-- Fonction de téléportation de tous les joueurs
function teleportAllPlayersToMe()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        print("❌ Impossible de téléporter - votre personnage n'est pas disponible")
        return
    end

    local myPosition = player.Character.HumanoidRootPart.Position
    local teleportedCount = 0

    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Téléporter le joueur à votre position
            targetPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(myPosition + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
            teleportedCount = teleportedCount + 1
            print("📍 " .. targetPlayer.Name .. " téléporté vers vous")
        end
    end

    if teleportedCount > 0 then
        print("✅ " .. teleportedCount .. " joueur(s) téléporté(s) vers vous!")
    else
        print("⚠️ Aucun joueur à téléporter")
    end
end

-- Fonction d'attaque automatique avec épée
function attackAllPlayersWithSword()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        print("❌ Impossible d'attaquer - votre personnage n'est pas disponible")
        return
    end

    -- Chercher l'épée "Wood Sword to bash thieves!" dans l'inventaire
    local backpack = player:FindFirstChild("Backpack")
    local woodSword = nil

    if backpack then
        woodSword = backpack:FindFirstChild("Wood Sword to bash thieves!")
    end

    -- Vérifier aussi si l'épée est déjà équipée
    if not woodSword and player.Character then
        woodSword = player.Character:FindFirstChild("Wood Sword to bash thieves!")
    end

    if not woodSword then
        print("❌ Épée 'Wood Sword to bash thieves!' non trouvée dans l'inventaire")
        LogSystem:addLog("Épée 'Wood Sword to bash thieves!' non trouvée", "ERROR")
        return
    end

    -- Équiper l'épée si elle n'est pas déjà équipée
    if woodSword.Parent == backpack then
        player.Character.Humanoid:EquipTool(woodSword)
        wait(0.5) -- Attendre que l'épée soit équipée
    end

    local attackedCount = 0
    local originalPosition = player.Character.HumanoidRootPart.CFrame

    print("⚔️ Début de la séquence d'attaque avec l'épée!")
    LogSystem:addLog("Début de la séquence d'attaque avec l'épée", "EXPLOIT")

    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = targetPlayer.Character.HumanoidRootPart.Position

            -- Se téléporter près du joueur cible
            player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(2, 0, 2))
            wait(0.3)

            -- Activer l'épée (simuler le clic)
            if woodSword and woodSword:FindFirstChild("Handle") then
                -- Méthode 1: Déclencher l'événement Activated de l'outil
                if woodSword.Activated then
                    woodSword:Activate()
                end

                -- Méthode 2: Simuler un clic via RemoteEvent si présent
                for _, child in pairs(woodSword:GetChildren()) do
                    if child:IsA("RemoteEvent") and (child.Name:lower():find("attack") or child.Name:lower():find("hit") or child.Name:lower():find("swing")) then
                        child:FireServer(targetPlayer.Character.Humanoid)
                    end
                end

                -- Méthode 3: Manipulation directe du handle si possible
                local handle = woodSword:FindFirstChild("Handle")
                if handle then
                    -- Créer un événement de frappe
                    local hit = Instance.new("Explosion")
                    hit.Position = targetPlayer.Character.HumanoidRootPart.Position
                    hit.BlastRadius = 1
                    hit.BlastPressure = 0
                    hit.Parent = workspace
                    hit:Destroy()
                end

                attackedCount = attackedCount + 1
                print("⚔️ " .. targetPlayer.Name .. " attaqué avec l'épée!")
                LogSystem:addLog(targetPlayer.Name .. " attaqué avec l'épée", "EXPLOIT")
            end

            wait(0.8) -- Pause entre chaque attaque
        end
    end

    -- Retourner à la position originale
    player.Character.HumanoidRootPart.CFrame = originalPosition

    if attackedCount > 0 then
        print("✅ " .. attackedCount .. " joueur(s) attaqué(s) avec l'épée!")
        LogSystem:addLog(attackedCount .. " joueurs attaqués avec succès!", "SUCCESS")
    else
        print("⚠️ Aucun joueur n'a pu être attaqué")
        LogSystem:addLog("Aucun joueur n'a pu être attaqué", "WARNING")
    end
end

-- Fonction pour révéler tous les panels du jeu (F8)
function revealAllGamePanels()
    local revealedCount = 0
    local processedObjects = {}

    print("🔓 Révélation de tous les panels du jeu en cours...")
    LogSystem:addLog("Début de la révélation de tous les panels", "EXPLOIT")

    -- Scanner tous les objets du jeu
    for _, obj in pairs(game:GetDescendants()) do
        local objPath = obj:GetFullName()

        -- Ignorer les interfaces système Roblox
        if AdminPanelDetector:isRobloxSystemUI(obj) then
            continue
        end

        -- Éviter les doublons
        if processedObjects[objPath] then
            continue
        end

        local shouldReveal = false
        local objectType = ""

        -- Révéler les ScreenGuis cachés
        if obj:IsA("ScreenGui") and not obj.Enabled then
            RevealTracker:recordOriginalState(obj)
            obj.Enabled = true
            RevealTracker:markAsRevealed(obj)
            shouldReveal = true
            objectType = "ScreenGui"
        end

        -- Révéler les Frames et autres GuiObjects cachés
        if obj:IsA("GuiObject") and not obj.Visible then
            RevealTracker:recordOriginalState(obj)
            obj.Visible = true
            RevealTracker:markAsRevealed(obj)

            -- Remonter la hiérarchie pour rendre visible les parents
            local parent = obj.Parent
            while parent and parent:IsA("GuiObject") do
                if not parent.Visible then
                    RevealTracker:recordOriginalState(parent)
                    parent.Visible = true
                    RevealTracker:markAsRevealed(parent)
                end
                parent = parent.Parent
            end

            -- Rendre visible le ScreenGui parent
            local screenGui = obj:FindFirstAncestorOfClass("ScreenGui")
            if screenGui and not screenGui.Enabled then
                RevealTracker:recordOriginalState(screenGui)
                screenGui.Enabled = true
                RevealTracker:markAsRevealed(screenGui)
            end

            shouldReveal = true
            objectType = obj.ClassName
        end

        -- Activer les scripts désactivés (sauf anti-cheat)
        if (obj:IsA("LocalScript") or obj:IsA("Script")) and obj.Disabled then
            -- Vérifier que ce n'est pas un anti-cheat
            local name = obj.Name:lower()
            local isAntiCheat = false
            for _, pattern in pairs(AntiCheatDetector.patterns.scriptNames) do
                if name:find(pattern:lower()) then
                    isAntiCheat = true
                    break
                end
            end

            if not isAntiCheat then
                RevealTracker:recordOriginalState(obj)
                obj.Disabled = false
                RevealTracker:markAsRevealed(obj)
                shouldReveal = true
                objectType = obj.ClassName
            end
        end

        -- Révéler les objets avec des noms suspects (panels cachés)
        if obj:IsA("Frame") or obj:IsA("ScreenGui") then
            local name = obj.Name:lower()
            local suspiciousTerms = {
                "hidden", "secret", "admin", "panel", "gui", "interface",
                "menu", "dialog", "popup", "window", "screen", "ui",
                "control", "dashboard", "console", "manager", "tool",
                "caché", "cache", "secret", "masque", "invisible"
            }

            for _, term in pairs(suspiciousTerms) do
                if name:find(term) then
                    RevealTracker:recordOriginalState(obj)
                    if obj:IsA("ScreenGui") then
                        obj.Enabled = true
                    elseif obj:IsA("GuiObject") then
                        obj.Visible = true
                    end
                    RevealTracker:markAsRevealed(obj)
                    shouldReveal = true
                    objectType = obj.ClassName .. " (Suspect)"
                    break
                end
            end
        end

        if shouldReveal then
            processedObjects[objPath] = true
            revealedCount = revealedCount + 1
            print("👁️ Révélé: " .. obj.Name .. " (" .. objectType .. ")")
            LogSystem:addLog("Révélé: " .. obj.Name .. " (" .. objectType .. ")", "SUCCESS")
        end
    end

    -- Forcer la détection et l'affichage des admin panels
    AdminPanelDetector:scanForAdminPanels()
    local adminPanelsShown = AdminPanelDetector:showDetectedPanels()
    revealedCount = revealedCount + adminPanelsShown

    -- Recherche automatique de termes suspects
    local autoSearchTerms = {
        "admin", "mod", "panel", "gui", "menu", "interface", "control",
        "dashboard", "console", "tool", "manager", "owner", "staff",
        "proprietaire", "createur", "fondateur", "vip", "premium"
    }

    for _, term in pairs(autoSearchTerms) do
        CustomSearchSystem:performCustomSearch(term)
        for _, result in pairs(CustomSearchSystem.results) do
            CustomSearchSystem:makeObjectVisible(result.object)
        end
        wait(0.1) -- Petite pause entre chaque recherche
    end

    print("🎉 Révélation terminée!")
    print("✅ " .. revealedCount .. " élément(s) d'interface révélé(s)!")
    LogSystem:addLog("Révélation terminée: " .. revealedCount .. " éléments révélés", "SUCCESS")

    -- Afficher un résumé
    print("📊 Résumé de la révélation:")
    print("  - ScreenGuis activés")
    print("  - Frames et GuiObjects rendus visibles")
    print("  - Scripts non-anticheat activés")
    print("  - Admin panels détectés et affichés")
    print("  - Recherche automatique effectuée")
    
    return revealedCount
end

-- Gérer les inputs F2, F5, F8, F9, F10 et F12
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.F2 then
        CustomSearchSystem:togglePanel()
    elseif input.KeyCode == Enum.KeyCode.F5 then
        teleportAllPlayersToMe()
    elseif input.KeyCode == Enum.KeyCode.F8 then
        revealAllGamePanels()
    elseif input.KeyCode == Enum.KeyCode.F9 then
        RevealTracker:hideAllRevealed()
    elseif input.KeyCode == Enum.KeyCode.F10 then
        attackAllPlayersWithSword()
    elseif input.KeyCode == Enum.KeyCode.F12 then
        LogSystem:togglePanel()
    end
end)

-- Initialiser le système de logs
LogSystem:addLog("Script Admin Panel Detector chargé", "SUCCESS")
LogSystem:addLog("Système de logs initialisé", "INFO")

-- Démarrer automatiquement la surveillance
startAdminPanelMonitoring()

print("🔧 Commandes supplémentaires:")
print("  - F2 : Ouvrir/Fermer le panel de recherche personnalisé")
print("  - F5 : Téléporter tous les joueurs vers vous")
print("  - F8 : Révéler TOUS les panels du jeu (sauf Roblox système)")
print("  - F9 : Cacher TOUS les éléments qui ont été révélés")
print("  - F10 : Attaquer tous les joueurs avec l'épée 'Wood Sword to bash thieves!'")
print("  - F12 : Ouvrir/Fermer le panel des logs")
print("  - teleportAllPlayersToMe() : Téléporter manuellement tous les joueurs")
print("  - attackAllPlayersWithSword() : Attaquer manuellement tous les joueurs avec l'épée")
print("  - revealAllGamePanels() : Révéler manuellement tous les panels du jeu")
print("  - RevealTracker:hideAllRevealed() : Cacher manuellement tous les éléments révélés")
print("  - LogSystem:togglePanel() : Ouvrir/Fermer le panel des logs manuellement")
print("  - CustomSearchSystem:togglePanel() : Ouvrir/Fermer le panel de recherche manuellement")
