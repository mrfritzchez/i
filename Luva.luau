local DynamicNames = {}
DynamicNames.__index = DynamicNames

local function GenerateDynamicName()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local special = "!@#$%^&*()_+-=[]{}|;':\",./<>?`~"
    local allChars = chars .. special
    local name = ""
    for i = 1, 128 do
        local rand = math.random(1, #allChars)
        name = name .. string.sub(allChars, rand, rand)
    end
    return name
end

local function CreateObfuscatedInstance(className, parent)
    local instance = Instance.new(className)
    instance.Name = GenerateDynamicName()
    if parent then
        instance.Parent = parent
    end
    return instance
end

local ExecutorDetector = {}

function ExecutorDetector:Detect()
    local executorInfo = {
        Name = "Unknown",
        UNC = 0,
        sUNC = 0,
        Identity = 0,
        Level = 0,
        SupportsFileSystem = false,
        SupportsHttp = false,
        SupportsClosure = false,
        SupportsDebug = false
    }

    if syn then
        executorInfo.Name = "Synapse X"
        executorInfo.UNC = 100
        executorInfo.sUNC = 100
        executorInfo.Identity = 8
        executorInfo.Level = 8
    elseif fluxus then
        executorInfo.Name = "Fluxus"
        executorInfo.UNC = 95
        executorInfo.sUNC = 90
        executorInfo.Identity = 8
        executorInfo.Level = 8
    elseif delta then
        executorInfo.Name = "Delta"
        executorInfo.UNC = 90
        executorInfo.sUNC = 85
        executorInfo.Identity = 7
        executorInfo.Level = 7
    elseif codex then
        executorInfo.Name = "Codex"
        executorInfo.UNC = 85
        executorInfo.sUNC = 80
        executorInfo.Identity = 7
        executorInfo.Level = 7
    elseif krnl then
        executorInfo.Name = "KRNL"
        executorInfo.UNC = 80
        executorInfo.sUNC = 75
        executorInfo.Identity = 6
        executorInfo.Level = 6
    elseif oxygen then
        executorInfo.Name = "Oxygen"
        executorInfo.UNC = 75
        executorInfo.sUNC = 70
        executorInfo.Identity = 6
        executorInfo.Level = 6
    elseif electron then
        executorInfo.Name = "Electron"
        executorInfo.UNC = 70
        executorInfo.sUNC = 65
        executorInfo.Identity = 5
        executorInfo.Level = 5
    elseif trigon then
        executorInfo.Name = "Trigon"
        executorInfo.UNC = 85
        executorInfo.sUNC = 80
        executorInfo.Identity = 7
        executorInfo.Level = 7
    elseif hydrogen then
        executorInfo.Name = "Hydrogen"
        executorInfo.UNC = 80
        executorInfo.sUNC = 75
        executorInfo.Identity = 6
        executorInfo.Level = 6
    elseif arceus then
        executorInfo.Name = "Arceus X"
        executorInfo.UNC = 60
        executorInfo.sUNC = 55
        executorInfo.Identity = 4
        executorInfo.Level = 4
    elseif codex then
        executorInfo.Name = "Codex"
        executorInfo.UNC = 85
        executorInfo.sUNC = 80
        executorInfo.Identity = 7
        executorInfo.Level = 7
    elseif getexecutorname then
        local success, name = pcall(getexecutorname)
        if success then
            executorInfo.Name = name
        end
    end

    if identifyexecutor then
        local success, result = pcall(identifyexecutor)
        if success then
            executorInfo.Name = result
        end
    end

    if getthreadidentity then
        local success, result = pcall(getthreadidentity)
        if success then
            executorInfo.Identity = result
            executorInfo.Level = result
        end
    elseif getidentity then
        local success, result = pcall(getidentity)
        if success then
            executorInfo.Identity = result
            executorInfo.Level = result
        end
    end

    executorInfo.SupportsFileSystem = (writefile ~= nil and readfile ~= nil and
                                       isfile ~= nil and isfolder ~= nil and
                                       makefolder ~= nil and delfile ~= nil)

    executorInfo.SupportsHttp = (request ~= nil or http_request ~= nil or
                                 syn and syn.request ~= nil or
                                 fluxus and fluxus.request ~= nil)

    executorInfo.SupportsClosure = (newcclosure ~= nil or iscclosure ~= nil or
                                    isluaclosure ~= nil)

    executorInfo.SupportsDebug = (debug ~= nil and debug.getupvalues ~= nil and
                                  debug.setupvalue ~= nil)

    return executorInfo
end

local AntiDetection = {}
AntiDetection.__index = AntiDetection

function AntiDetection.new()
    local self = setmetatable({}, AntiDetection)
    self.SecureMode = false
    self.CustomAssetID = nil
    self.DetectedHooks = {}
    self.ProtectedInstances = {}
    return self
end

function AntiDetection:EnableSecureMode()
    self.SecureMode = true

    self:SetupHookProtection()

    self:SetupInstanceProtection()

    self:EnableNameObfuscation()
end

function AntiDetection:SetupHookProtection()

    local function ProtectHook(original, hookName)
        if not original then return end

        local protected = newcclosure and newcclosure(function(...)
            return original(...)
        end) or function(...)
            return original(...)
        end

        self.DetectedHooks[hookName] = {
            Original = original,
            Protected = protected
        }

        return protected
    end

    if game and game.GetService then
        self._originalGetService = game.GetService
    end

    if Instance and Instance.new then
        self._originalInstanceNew = Instance.new
    end

    if require then
        self._originalRequire = require
    end
end

function AntiDetection:SetupInstanceProtection()

    local function ProtectInstance(instance)
        if not instance then return end

        instance.Name = GenerateDynamicName()

        self.ProtectedInstances[instance] = true

        if getrawmetatable and setreadonly then
            local mt = getrawmetatable(game)
            if mt then
                local oldIndex = mt.__index
                local oldNewIndex = mt.__newindex
                local oldNamecall = mt.__namecall
            end
        end
    end

    self.ProtectInstance = ProtectInstance
end

function AntiDetection:EnableNameObfuscation()

    spawn(function()
        while self.SecureMode do
            for instance, _ in pairs(self.ProtectedInstances) do
                if instance and instance.Parent then
                    pcall(function()
                        instance.Name = GenerateDynamicName()
                    end)
                end
            end
            task.wait(0.001)
        end
    end)
end

function AntiDetection:CheckForCheaters()

    local integrityChecks = {
        function() return _G.LUVA_LOADED == true end,
        function() return getfenv()["LUVA_SECURE"] == true end,
        function() return game.CoreGui:FindFirstChildOfClass("ScreenGui") ~= nil end
    }

    for _, check in ipairs(integrityChecks) do
        local success, result = pcall(check)
        if not success or not result then

            self:TriggerProtection()
            return false
        end
    end

    return true
end

function AntiDetection:TriggerProtection()

    pcall(function()
        if self.SecureMode then

            for instance, _ in pairs(self.ProtectedInstances) do
                if instance then
                    pcall(function() instance:Destroy() end)
                end
            end

            _G.LUVA_LOADED = nil
            _G.LUVA = nil
        end
    end)
end

local Themes = {}
Themes.Default = {
    Name = "Default",
    Background = Color3.fromRGB(30, 30, 30),
    Topbar = Color3.fromRGB(25, 25, 25),
    Sidebar = Color3.fromRGB(35, 35, 35),
    Primary = Color3.fromRGB(88, 101, 242),
    Secondary = Color3.fromRGB(60, 60, 60),
    Accent = Color3.fromRGB(88, 101, 242),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
    ElementBackground = Color3.fromRGB(45, 45, 45),
    ElementBackgroundHover = Color3.fromRGB(55, 55, 55),
    ElementStroke = Color3.fromRGB(60, 60, 60),
    Success = Color3.fromRGB(59, 165, 93),
    Warning = Color3.fromRGB(250, 168, 26),
    Error = Color3.fromRGB(237, 66, 69),
    Info = Color3.fromRGB(59, 130, 246),
    Shadow = Color3.fromRGB(0, 0, 0),
    Glow = Color3.fromRGB(88, 101, 242)
}

Themes.Dark = {
    Name = "Dark",
    Background = Color3.fromRGB(20, 20, 20),
    Topbar = Color3.fromRGB(15, 15, 15),
    Sidebar = Color3.fromRGB(25, 25, 25),
    Primary = Color3.fromRGB(114, 137, 218),
    Secondary = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(114, 137, 218),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(160, 160, 160),
    ElementBackground = Color3.fromRGB(35, 35, 35),
    ElementBackgroundHover = Color3.fromRGB(45, 45, 45),
    ElementStroke = Color3.fromRGB(50, 50, 50),
    Success = Color3.fromRGB(59, 165, 93),
    Warning = Color3.fromRGB(250, 168, 26),
    Error = Color3.fromRGB(237, 66, 69),
    Info = Color3.fromRGB(59, 130, 246),
    Shadow = Color3.fromRGB(0, 0, 0),
    Glow = Color3.fromRGB(114, 137, 218)
}

Themes.Light = {
    Name = "Light",
    Background = Color3.fromRGB(245, 245, 245),
    Topbar = Color3.fromRGB(235, 235, 235),
    Sidebar = Color3.fromRGB(255, 255, 255),
    Primary = Color3.fromRGB(88, 101, 242),
    Secondary = Color3.fromRGB(220, 220, 220),
    Accent = Color3.fromRGB(88, 101, 242),
    Text = Color3.fromRGB(30, 30, 30),
    TextDark = Color3.fromRGB(100, 100, 100),
    ElementBackground = Color3.fromRGB(255, 255, 255),
    ElementBackgroundHover = Color3.fromRGB(240, 240, 240),
    ElementStroke = Color3.fromRGB(200, 200, 200),
    Success = Color3.fromRGB(59, 165, 93),
    Warning = Color3.fromRGB(250, 168, 26),
    Error = Color3.fromRGB(237, 66, 69),
    Info = Color3.fromRGB(59, 130, 246),
    Shadow = Color3.fromRGB(200, 200, 200),
    Glow = Color3.fromRGB(88, 101, 242)
}

Themes.Midnight = {
    Name = "Midnight",
    Background = Color3.fromRGB(10, 10, 20),
    Topbar = Color3.fromRGB(5, 5, 15),
    Sidebar = Color3.fromRGB(15, 15, 25),
    Primary = Color3.fromRGB(138, 43, 226),
    Secondary = Color3.fromRGB(25, 25, 40),
    Accent = Color3.fromRGB(138, 43, 226),
    Text = Color3.fromRGB(230, 230, 255),
    TextDark = Color3.fromRGB(150, 150, 200),
    ElementBackground = Color3.fromRGB(20, 20, 35),
    ElementBackgroundHover = Color3.fromRGB(30, 30, 50),
    ElementStroke = Color3.fromRGB(40, 40, 60),
    Success = Color3.fromRGB(0, 255, 150),
    Warning = Color3.fromRGB(255, 200, 0),
    Error = Color3.fromRGB(255, 50, 100),
    Info = Color3.fromRGB(100, 150, 255),
    Shadow = Color3.fromRGB(0, 0, 10),
    Glow = Color3.fromRGB(138, 43, 226)
}

Themes.Ocean = {
    Name = "Ocean",
    Background = Color3.fromRGB(15, 25, 35),
    Topbar = Color3.fromRGB(10, 20, 30),
    Sidebar = Color3.fromRGB(20, 30, 40),
    Primary = Color3.fromRGB(0, 150, 200),
    Secondary = Color3.fromRGB(25, 35, 45),
    Accent = Color3.fromRGB(0, 200, 255),
    Text = Color3.fromRGB(220, 240, 255),
    TextDark = Color3.fromRGB(140, 170, 200),
    ElementBackground = Color3.fromRGB(25, 35, 45),
    ElementBackgroundHover = Color3.fromRGB(35, 50, 65),
    ElementStroke = Color3.fromRGB(40, 55, 70),
    Success = Color3.fromRGB(0, 255, 150),
    Warning = Color3.fromRGB(255, 200, 0),
    Error = Color3.fromRGB(255, 80, 80),
    Info = Color3.fromRGB(80, 180, 255),
    Shadow = Color3.fromRGB(0, 5, 15),
    Glow = Color3.fromRGB(0, 200, 255)
}

Themes.Crimson = {
    Name = "Crimson",
    Background = Color3.fromRGB(30, 10, 10),
    Topbar = Color3.fromRGB(25, 5, 5),
    Sidebar = Color3.fromRGB(35, 15, 15),
    Primary = Color3.fromRGB(220, 20, 60),
    Secondary = Color3.fromRGB(45, 20, 20),
    Accent = Color3.fromRGB(255, 50, 80),
    Text = Color3.fromRGB(255, 220, 220),
    TextDark = Color3.fromRGB(200, 150, 150),
    ElementBackground = Color3.fromRGB(45, 20, 20),
    ElementBackgroundHover = Color3.fromRGB(60, 30, 30),
    ElementStroke = Color3.fromRGB(70, 35, 35),
    Success = Color3.fromRGB(50, 255, 150),
    Warning = Color3.fromRGB(255, 200, 50),
    Error = Color3.fromRGB(255, 50, 50),
    Info = Color3.fromRGB(255, 100, 100),
    Shadow = Color3.fromRGB(10, 0, 0),
    Glow = Color3.fromRGB(255, 50, 80)
}

Themes.Forest = {
    Name = "Forest",
    Background = Color3.fromRGB(15, 30, 15),
    Topbar = Color3.fromRGB(10, 25, 10),
    Sidebar = Color3.fromRGB(20, 35, 20),
    Primary = Color3.fromRGB(34, 197, 94),
    Secondary = Color3.fromRGB(25, 45, 25),
    Accent = Color3.fromRGB(50, 255, 100),
    Text = Color3.fromRGB(220, 255, 220),
    TextDark = Color3.fromRGB(150, 200, 150),
    ElementBackground = Color3.fromRGB(25, 40, 25),
    ElementBackgroundHover = Color3.fromRGB(35, 55, 35),
    ElementStroke = Color3.fromRGB(40, 60, 40),
    Success = Color3.fromRGB(50, 255, 100),
    Warning = Color3.fromRGB(255, 200, 50),
    Error = Color3.fromRGB(255, 80, 80),
    Info = Color3.fromRGB(100, 255, 150),
    Shadow = Color3.fromRGB(0, 10, 0),
    Glow = Color3.fromRGB(50, 255, 100)
}

Themes.Sunset = {
    Name = "Sunset",
    Background = Color3.fromRGB(30, 20, 15),
    Topbar = Color3.fromRGB(25, 15, 10),
    Sidebar = Color3.fromRGB(35, 25, 20),
    Primary = Color3.fromRGB(255, 140, 50),
    Secondary = Color3.fromRGB(45, 30, 25),
    Accent = Color3.fromRGB(255, 180, 80),
    Text = Color3.fromRGB(255, 240, 220),
    TextDark = Color3.fromRGB(200, 170, 140),
    ElementBackground = Color3.fromRGB(45, 30, 25),
    ElementBackgroundHover = Color3.fromRGB(60, 40, 35),
    ElementStroke = Color3.fromRGB(70, 50, 40),
    Success = Color3.fromRGB(100, 255, 150),
    Warning = Color3.fromRGB(255, 220, 50),
    Error = Color3.fromRGB(255, 80, 80),
    Info = Color3.fromRGB(255, 180, 100),
    Shadow = Color3.fromRGB(15, 5, 0),
    Glow = Color3.fromRGB(255, 180, 80)
}

Themes.Amethyst = {
    Name = "Amethyst",
    Background = Color3.fromRGB(25, 15, 35),
    Topbar = Color3.fromRGB(20, 10, 30),
    Sidebar = Color3.fromRGB(30, 20, 40),
    Primary = Color3.fromRGB(155, 89, 182),
    Secondary = Color3.fromRGB(40, 25, 50),
    Accent = Color3.fromRGB(175, 122, 197),
    Text = Color3.fromRGB(240, 230, 255),
    TextDark = Color3.fromRGB(180, 150, 210),
    ElementBackground = Color3.fromRGB(35, 20, 45),
    ElementBackgroundHover = Color3.fromRGB(45, 30, 60),
    ElementStroke = Color3.fromRGB(55, 35, 70),
    Success = Color3.fromRGB(100, 255, 150),
    Warning = Color3.fromRGB(255, 200, 100),
    Error = Color3.fromRGB(255, 100, 100),
    Info = Color3.fromRGB(180, 130, 255),
    Shadow = Color3.fromRGB(10, 0, 20),
    Glow = Color3.fromRGB(155, 89, 182)
}

Themes.Aqua = {
    Name = "Aqua",
    Background = Color3.fromRGB(15, 30, 30),
    Topbar = Color3.fromRGB(10, 25, 25),
    Sidebar = Color3.fromRGB(20, 35, 35),
    Primary = Color3.fromRGB(0, 200, 180),
    Secondary = Color3.fromRGB(25, 45, 45),
    Accent = Color3.fromRGB(0, 255, 220),
    Text = Color3.fromRGB(220, 255, 250),
    TextDark = Color3.fromRGB(150, 200, 190),
    ElementBackground = Color3.fromRGB(25, 40, 40),
    ElementBackgroundHover = Color3.fromRGB(35, 55, 55),
    ElementStroke = Color3.fromRGB(40, 60, 60),
    Success = Color3.fromRGB(50, 255, 150),
    Warning = Color3.fromRGB(255, 220, 50),
    Error = Color3.fromRGB(255, 100, 100),
    Info = Color3.fromRGB(100, 255, 230),
    Shadow = Color3.fromRGB(0, 15, 15),
    Glow = Color3.fromRGB(0, 255, 220)
}

Themes.Rose = {
    Name = "Rose",
    Background = Color3.fromRGB(35, 20, 25),
    Topbar = Color3.fromRGB(30, 15, 20),
    Sidebar = Color3.fromRGB(40, 25, 30),
    Primary = Color3.fromRGB(255, 105, 130),
    Secondary = Color3.fromRGB(50, 30, 35),
    Accent = Color3.fromRGB(255, 150, 170),
    Text = Color3.fromRGB(255, 230, 235),
    TextDark = Color3.fromRGB(210, 160, 170),
    ElementBackground = Color3.fromRGB(45, 25, 30),
    ElementBackgroundHover = Color3.fromRGB(60, 35, 45),
    ElementStroke = Color3.fromRGB(70, 40, 50),
    Success = Color3.fromRGB(150, 255, 150),
    Warning = Color3.fromRGB(255, 220, 100),
    Error = Color3.fromRGB(255, 100, 100),
    Info = Color3.fromRGB(255, 180, 200),
    Shadow = Color3.fromRGB(20, 5, 10),
    Glow = Color3.fromRGB(255, 150, 170)
}

Themes.Gold = {
    Name = "Gold",
    Background = Color3.fromRGB(30, 25, 15),
    Topbar = Color3.fromRGB(25, 20, 10),
    Sidebar = Color3.fromRGB(35, 30, 20),
    Primary = Color3.fromRGB(255, 190, 50),
    Secondary = Color3.fromRGB(45, 38, 25),
    Accent = Color3.fromRGB(255, 215, 100),
    Text = Color3.fromRGB(255, 245, 220),
    TextDark = Color3.fromRGB(200, 180, 140),
    ElementBackground = Color3.fromRGB(40, 33, 20),
    ElementBackgroundHover = Color3.fromRGB(55, 45, 30),
    ElementStroke = Color3.fromRGB(65, 55, 35),
    Success = Color3.fromRGB(150, 255, 150),
    Warning = Color3.fromRGB(255, 220, 50),
    Error = Color3.fromRGB(255, 100, 100),
    Info = Color3.fromRGB(255, 200, 100),
    Shadow = Color3.fromRGB(15, 10, 0),
    Glow = Color3.fromRGB(255, 215, 100)
}

Themes.Ice = {
    Name = "Ice",
    Background = Color3.fromRGB(20, 25, 30),
    Topbar = Color3.fromRGB(15, 20, 25),
    Sidebar = Color3.fromRGB(25, 30, 35),
    Primary = Color3.fromRGB(180, 210, 255),
    Secondary = Color3.fromRGB(30, 35, 40),
    Accent = Color3.fromRGB(200, 230, 255),
    Text = Color3.fromRGB(235, 245, 255),
    TextDark = Color3.fromRGB(160, 180, 210),
    ElementBackground = Color3.fromRGB(28, 33, 38),
    ElementBackgroundHover = Color3.fromRGB(38, 45, 52),
    ElementStroke = Color3.fromRGB(45, 52, 60),
    Success = Color3.fromRGB(100, 255, 150),
    Warning = Color3.fromRGB(255, 220, 100),
    Error = Color3.fromRGB(255, 120, 120),
    Info = Color3.fromRGB(180, 220, 255),
    Shadow = Color3.fromRGB(5, 10, 15),
    Glow = Color3.fromRGB(200, 230, 255)
}

Themes.Neon = {
    Name = "Neon",
    Background = Color3.fromRGB(10, 10, 15),
    Topbar = Color3.fromRGB(5, 5, 10),
    Sidebar = Color3.fromRGB(15, 15, 20),
    Primary = Color3.fromRGB(0, 255, 150),
    Secondary = Color3.fromRGB(20, 20, 25),
    Accent = Color3.fromRGB(0, 255, 200),
    Text = Color3.fromRGB(220, 255, 240),
    TextDark = Color3.fromRGB(140, 180, 160),
    ElementBackground = Color3.fromRGB(15, 15, 20),
    ElementBackgroundHover = Color3.fromRGB(25, 25, 35),
    ElementStroke = Color3.fromRGB(0, 200, 120),
    Success = Color3.fromRGB(0, 255, 100),
    Warning = Color3.fromRGB(255, 255, 0),
    Error = Color3.fromRGB(255, 50, 50),
    Info = Color3.fromRGB(0, 255, 200),
    Shadow = Color3.fromRGB(0, 5, 0),
    Glow = Color3.fromRGB(0, 255, 150)
}

Themes.Coffee = {
    Name = "Coffee",
    Background = Color3.fromRGB(35, 28, 22),
    Topbar = Color3.fromRGB(30, 23, 17),
    Sidebar = Color3.fromRGB(40, 33, 27),
    Primary = Color3.fromRGB(180, 130, 80),
    Secondary = Color3.fromRGB(45, 38, 32),
    Accent = Color3.fromRGB(210, 160, 100),
    Text = Color3.fromRGB(240, 225, 210),
    TextDark = Color3.fromRGB(180, 160, 140),
    ElementBackground = Color3.fromRGB(42, 35, 28),
    ElementBackgroundHover = Color3.fromRGB(55, 45, 38),
    ElementStroke = Color3.fromRGB(65, 55, 45),
    Success = Color3.fromRGB(130, 200, 100),
    Warning = Color3.fromRGB(230, 190, 80),
    Error = Color3.fromRGB(210, 100, 80),
    Info = Color3.fromRGB(190, 160, 120),
    Shadow = Color3.fromRGB(15, 10, 5),
    Glow = Color3.fromRGB(210, 160, 100)
}

Themes.Sakura = {
    Name = "Sakura",
    Background = Color3.fromRGB(35, 25, 30),
    Topbar = Color3.fromRGB(30, 20, 25),
    Sidebar = Color3.fromRGB(40, 30, 35),
    Primary = Color3.fromRGB(255, 183, 197),
    Secondary = Color3.fromRGB(45, 35, 40),
    Accent = Color3.fromRGB(255, 200, 210),
    Text = Color3.fromRGB(255, 240, 245),
    TextDark = Color3.fromRGB(210, 170, 185),
    ElementBackground = Color3.fromRGB(42, 30, 36),
    ElementBackgroundHover = Color3.fromRGB(55, 40, 48),
    ElementStroke = Color3.fromRGB(65, 48, 58),
    Success = Color3.fromRGB(160, 230, 160),
    Warning = Color3.fromRGB(255, 220, 150),
    Error = Color3.fromRGB(255, 120, 120),
    Info = Color3.fromRGB(255, 200, 220),
    Shadow = Color3.fromRGB(20, 10, 15),
    Glow = Color3.fromRGB(255, 200, 210)
}

Themes.Cyberpunk = {
    Name = "Cyberpunk",
    Background = Color3.fromRGB(15, 10, 25),
    Topbar = Color3.fromRGB(10, 5, 20),
    Sidebar = Color3.fromRGB(20, 15, 30),
    Primary = Color3.fromRGB(255, 0, 128),
    Secondary = Color3.fromRGB(25, 20, 35),
    Accent = Color3.fromRGB(0, 255, 255),
    Text = Color3.fromRGB(255, 235, 250),
    TextDark = Color3.fromRGB(180, 140, 170),
    ElementBackground = Color3.fromRGB(22, 15, 32),
    ElementBackgroundHover = Color3.fromRGB(35, 25, 50),
    ElementStroke = Color3.fromRGB(255, 0, 128),
    Success = Color3.fromRGB(0, 255, 128),
    Warning = Color3.fromRGB(255, 200, 0),
    Error = Color3.fromRGB(255, 0, 80),
    Info = Color3.fromRGB(0, 200, 255),
    Shadow = Color3.fromRGB(10, 0, 20),
    Glow = Color3.fromRGB(255, 0, 128)
}

Themes.Vintage = {
    Name = "Vintage",
    Background = Color3.fromRGB(40, 35, 28),
    Topbar = Color3.fromRGB(35, 30, 23),
    Sidebar = Color3.fromRGB(45, 40, 33),
    Primary = Color3.fromRGB(180, 150, 100),
    Secondary = Color3.fromRGB(50, 45, 38),
    Accent = Color3.fromRGB(200, 170, 120),
    Text = Color3.fromRGB(235, 225, 210),
    TextDark = Color3.fromRGB(175, 160, 140),
    ElementBackground = Color3.fromRGB(48, 42, 35),
    ElementBackgroundHover = Color3.fromRGB(60, 52, 44),
    ElementStroke = Color3.fromRGB(70, 62, 52),
    Success = Color3.fromRGB(140, 180, 100),
    Warning = Color3.fromRGB(210, 180, 80),
    Error = Color3.fromRGB(190, 90, 70),
    Info = Color3.fromRGB(170, 150, 110),
    Shadow = Color3.fromRGB(20, 15, 10),
    Glow = Color3.fromRGB(200, 170, 120)
}

Themes.Mint = {
    Name = "Mint",
    Background = Color3.fromRGB(25, 35, 30),
    Topbar = Color3.fromRGB(20, 30, 25),
    Sidebar = Color3.fromRGB(30, 40, 35),
    Primary = Color3.fromRGB(100, 230, 180),
    Secondary = Color3.fromRGB(32, 42, 37),
    Accent = Color3.fromRGB(130, 255, 200),
    Text = Color3.fromRGB(230, 255, 245),
    TextDark = Color3.fromRGB(150, 200, 180),
    ElementBackground = Color3.fromRGB(30, 42, 36),
    ElementBackgroundHover = Color3.fromRGB(40, 55, 48),
    ElementStroke = Color3.fromRGB(48, 62, 55),
    Success = Color3.fromRGB(80, 220, 140),
    Warning = Color3.fromRGB(220, 200, 80),
    Error = Color3.fromRGB(220, 100, 100),
    Info = Color3.fromRGB(120, 230, 190),
    Shadow = Color3.fromRGB(10, 20, 15),
    Glow = Color3.fromRGB(130, 255, 200)
}

Themes.Rainbow = {
    Name = "Rainbow",
    Background = Color3.fromRGB(20, 20, 20),
    Topbar = Color3.fromRGB(15, 15, 15),
    Sidebar = Color3.fromRGB(25, 25, 25),
    Primary = Color3.fromRGB(255, 0, 0),
    Secondary = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(255, 165, 0),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
    ElementBackground = Color3.fromRGB(35, 35, 35),
    ElementBackgroundHover = Color3.fromRGB(45, 45, 45),
    ElementStroke = Color3.fromRGB(60, 60, 60),
    Success = Color3.fromRGB(0, 255, 0),
    Warning = Color3.fromRGB(255, 255, 0),
    Error = Color3.fromRGB(255, 0, 0),
    Info = Color3.fromRGB(0, 0, 255),
    Shadow = Color3.fromRGB(0, 0, 0),
    Glow = Color3.fromRGB(255, 0, 255),
    IsGradient = true,
    GradientColors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 165, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(75, 0, 130),
        Color3.fromRGB(238, 130, 238)
    }
}

Themes.NorthernLights = {
    Name = "NorthernLights",
    Background = Color3.fromRGB(10, 15, 20),
    Topbar = Color3.fromRGB(5, 10, 15),
    Sidebar = Color3.fromRGB(15, 20, 25),
    Primary = Color3.fromRGB(0, 255, 150),
    Secondary = Color3.fromRGB(20, 25, 30),
    Accent = Color3.fromRGB(100, 255, 200),
    Text = Color3.fromRGB(220, 255, 240),
    TextDark = Color3.fromRGB(140, 180, 170),
    ElementBackground = Color3.fromRGB(15, 22, 28),
    ElementBackgroundHover = Color3.fromRGB(25, 35, 42),
    ElementStroke = Color3.fromRGB(0, 180, 120),
    Success = Color3.fromRGB(0, 255, 120),
    Warning = Color3.fromRGB(200, 255, 100),
    Error = Color3.fromRGB(255, 80, 100),
    Info = Color3.fromRGB(100, 220, 255),
    Shadow = Color3.fromRGB(0, 5, 10),
    Glow = Color3.fromRGB(0, 255, 180),
    IsAnimated = true,
    AnimationColors = {
        Color3.fromRGB(0, 255, 150),
        Color3.fromRGB(100, 255, 200),
        Color3.fromRGB(0, 200, 255),
        Color3.fromRGB(150, 255, 150)
    }
}

local Utils = {}

Utils.NameGenerator = {}
Utils.NameGenerator.Active = false
Utils.NameGenerator.Instances = {}
Utils.NameGenerator.Connections = {}

local charset = {}
for i = 48, 57 do table.insert(charset, string.char(i)) end
for i = 65, 90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end
local specialChars = "!@#$%^&*()_+-=[]{}|;':\",./<>?`~"
for i = 1, #specialChars do
    table.insert(charset, string.sub(specialChars, i, i))
end

function Utils.NameGenerator:Generate(length)
    length = length or 128
    local name = ""
    for i = 1, length do
        name = name .. charset[math.random(1, #charset)]
    end
    return name
end

function Utils.NameGenerator:Register(instance)
    if not instance then return end
    table.insert(self.Instances, instance)

    pcall(function()
        instance.Name = self:Generate()
    end)
end

function Utils.NameGenerator:Start()
    if self.Active then return end
    self.Active = true

    spawn(function()
        while self.Active do
            for _, instance in ipairs(self.Instances) do
                if instance and instance.Parent then
                    pcall(function()
                        instance.Name = self:Generate()
                    end)
                end
            end
            task.wait(0.001)
        end
    end)
end

function Utils.NameGenerator:Stop()
    self.Active = false
end

function Utils.NameGenerator:Clear()
    self.Instances = {}
    self:Stop()
end

Utils.Encryption = {}

function Utils.Encryption:XOR(data, key)
    local result = ""
    for i = 1, #data do
        local dataByte = string.byte(data, i)
        local keyByte = string.byte(key, (i - 1) % #key + 1)
        result = result .. string.char(bit32.bxor(dataByte, keyByte))
    end
    return result
end

function Utils.Encryption:Caesar(text, shift)
    shift = shift or math.random(1, 25)
    local result = ""
    for i = 1, #text do
        local char = string.sub(text, i, i)
        local byte = string.byte(char)
        if byte >= 65 and byte <= 90 then
            result = result .. string.char((byte - 65 + shift) % 26 + 65)
        elseif byte >= 97 and byte <= 122 then
            result = result .. string.char((byte - 97 + shift) % 26 + 97)
        else
            result = result .. char
        end
    end
    return result
end

local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

function Utils.Encryption:Base64Encode(data)
    local result = ""
    local padding = ""
    local remainder = #data % 3

    if remainder == 1 then
        padding = "=="
        data = data .. string.char(0, 0)
    elseif remainder == 2 then
        padding = "="
        data = data .. string.char(0)
    end

    for i = 1, #data, 3 do
        local b1, b2, b3 = string.byte(data, i, i + 2)
        local n = b1 * 65536 + b2 * 256 + b3

        result = result .. string.sub(b64chars, math.floor(n / 262144) % 64 + 1, math.floor(n / 262144) % 64 + 1)
        result = result .. string.sub(b64chars, math.floor(n / 4096) % 64 + 1, math.floor(n / 4096) % 64 + 1)
        result = result .. string.sub(b64chars, math.floor(n / 64) % 64 + 1, math.floor(n / 64) % 64 + 1)
        result = result .. string.sub(b64chars, n % 64 + 1, n % 64 + 1)
    end

    return string.sub(result, 1, #result - #padding) .. padding
end

function Utils.Encryption:Base64Decode(data)
    local result = ""
    data = string.gsub(data, "[^" .. b64chars .. "=]", "")

    local padding = 0
    if string.sub(data, -2) == "==" then
        padding = 2
        data = string.sub(data, 1, -3) .. "AA"
    elseif string.sub(data, -1) == "=" then
        padding = 1
        data = string.sub(data, 1, -2) .. "A"
    end

    for i = 1, #data, 4 do
        local c1 = string.find(b64chars, string.sub(data, i, i), 1, true) - 1
        local c2 = string.find(b64chars, string.sub(data, i + 1, i + 1), 1, true) - 1
        local c3 = string.find(b64chars, string.sub(data, i + 2, i + 2), 1, true) - 1
        local c4 = string.find(b64chars, string.sub(data, i + 3, i + 3), 1, true) - 1

        local n = c1 * 262144 + c2 * 4096 + c3 * 64 + c4

        result = result .. string.char(math.floor(n / 65536) % 256)
        result = result .. string.char(math.floor(n / 256) % 256)
        result = result .. string.char(n % 256)
    end

    return string.sub(result, 1, #result - padding)
end

function Utils.Encryption:Hash(text)
    local hash = 5381
    for i = 1, #text do
        hash = bit32.bxor(bit32.lshift(hash, 5), hash) + string.byte(text, i)
    end
    return tostring(hash)
end

Utils.Obfuscation = {}

function Utils.Obfuscation:StringTable(strings)
    local obfuscated = {}
    local key = math.random(1000, 9999)

    for i, str in ipairs(strings) do
        local encrypted = Utils.Encryption:XOR(str, tostring(key + i))
        table.insert(obfuscated, {
            Index = i,
            Encrypted = Utils.Encryption:Base64Encode(encrypted),
            Key = key + i
        })
    end

    return obfuscated
end

function Utils.Obfuscation:ToBytecode(str)
    local bytes = {}
    for i = 1, #str do
        table.insert(bytes, string.byte(str, i))
    end
    return "string.char(" .. table.concat(bytes, ",") .. ")"
end

function Utils.Obfuscation:InsertJunk(str, amount)
    amount = amount or math.random(5, 15)
    local junk = ""
    for i = 1, amount do
        junk = junk .. string.char(math.random(1, 255))
    end
    return str .. junk
end

function Utils.Obfuscation:Reverse(str)
    local result = ""
    for i = #str, 1, -1 do
        result = result .. string.sub(str, i, i)
    end
    return result
end

Utils.AntiDetection = {}
Utils.AntiDetection.HookedFunctions = {}
Utils.AntiDetection.ProtectedInstances = {}
Utils.AntiDetection.SecureMode = false

function Utils.AntiDetection:EnableSecureMode()
    self.SecureMode = true
    self:ProtectHooks()
    self:ProtectInstances()
    self:SpoofMetrics()
end

function Utils.AntiDetection:ProtectHooks()

    local hooksToProtect = {
        "getgc",
        "getreg",
        "gettenv",
        "debug.getupvalues",
        "debug.getconstants",
        "getconnections"
    }

    for _, hookName in ipairs(hooksToProtect) do
        local func = getfenv()[hookName]
        if func then
            self.HookedFunctions[hookName] = func
        end
    end
end

function Utils.AntiDetection:ProtectInstances()

    spawn(function()
        while self.SecureMode do
            for instance, _ in pairs(self.ProtectedInstances) do
                if instance and instance.Parent then
                    pcall(function()

                        instance.Name = Utils.NameGenerator:Generate()
                    end)
                end
            end
            task.wait(0.001)
        end
    end)
end

function Utils.AntiDetection:RegisterInstance(instance)
    self.ProtectedInstances[instance] = true
end

function Utils.AntiDetection:SpoofMetrics()

    local env = getfenv()

    if env.identifyexecutor then
        local original = env.identifyexecutor
        env.identifyexecutor = function()
            return "RobloxStudio"
        end
    end

    if env.getexecutorname then
        local original = env.getexecutorname
        env.getexecutorname = function()
            return "RobloxStudio"
        end
    end
end

function Utils.AntiDetection:CheckIntegrity()

    for name, original in pairs(self.HookedFunctions) do
        if getfenv()[name] ~= original then
            return false, name
        end
    end
    return true
end

function Utils.AntiDetection:SelfDestruct()

    for instance, _ in pairs(self.ProtectedInstances) do
        if instance then
            pcall(function() instance:Destroy() end)
        end
    end

    self.ProtectedInstances = {}
    self.SecureMode = false
end

Utils.Executor = {}
Utils.Executor.Info = {
    Name = "Unknown",
    UNC = 0,
    sUNC = 0,
    Identity = 0,
    Level = 0,
    Supports = {
        FileSystem = false,
        Http = false,
        Closure = false,
        Debug = false,
        WebSocket = false,
        Drawing = false
    }
}

function Utils.Executor:Detect()
    local info = {
        Name = "Unknown",
        UNC = 0,
        sUNC = 0,
        Identity = 0,
        Level = 0,
        Supports = {
            FileSystem = false,
            Http = false,
            Closure = false,
            Debug = false,
            WebSocket = false,
            Drawing = false
        }
    }

    if syn then
        info.Name = "Synapse X"
        info.UNC = 100
        info.sUNC = 100
        info.Identity = 8
        info.Level = 8
    elseif fluxus then
        info.Name = "Fluxus"
        info.UNC = 95
        info.sUNC = 90
        info.Identity = 8
        info.Level = 8
    elseif identifyexecutor then
        local success, result = pcall(identifyexecutor)
        if success then
            info.Name = result
        end
    elseif getexecutorname then
        local success, result = pcall(getexecutorname)
        if success then
            info.Name = result
        end
    end

    if getthreadidentity then
        local success, result = pcall(getthreadidentity)
        if success then
            info.Identity = result
            info.Level = result
        end
    elseif getidentity then
        local success, result = pcall(getidentity)
        if success then
            info.Identity = result
            info.Level = result
        end
    end

    info.Supports.FileSystem = (writefile ~= nil and readfile ~= nil and
                                isfile ~= nil and isfolder ~= nil and
                                makefolder ~= nil and delfile ~= nil)

    info.Supports.Http = (request ~= nil or http_request ~= nil or
                          syn and syn.request ~= nil or
                          fluxus and fluxus.request ~= nil)

    info.Supports.Closure = (newcclosure ~= nil and iscclosure ~= nil and
                             isluaclosure ~= nil)

    info.Supports.Debug = (debug ~= nil and debug.getupvalues ~= nil and
                           debug.setupvalue ~= nil)

    info.Supports.WebSocket = (WebSocket ~= nil or WebSocket.connect ~= nil)

    info.Supports.Drawing = (Drawing ~= nil and Drawing.new ~= nil)

    self.Info = info
    return info
end

function Utils.Executor:IsSupported(feature)
    return self.Info.Supports[feature] or false
end

function Utils.Executor:GetLevel()
    return self.Info.Level
end

function Utils.Executor:GetIdentity()
    return self.Info.Identity
end

Utils.UI = {}

function Utils.UI:Tween(instance, properties, duration, easingStyle, easingDirection, callback)
    if not instance then return nil end

    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )

    local tween = tweenService:Create(instance, tweenInfo, properties)

    if callback then
        tween.Completed:Connect(callback)
    end

    tween:Play()
    return tween
end

function Utils.UI:CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 6)
    corner.Parent = parent
    return corner
end

function Utils.UI:CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(60, 60, 60)
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

function Utils.UI:CreateShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = Utils.NameGenerator:Generate()
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.ZIndex = -1
    shadow.Parent = parent
    return shadow
end

function Utils.UI:CreateGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color1 or Color3.fromRGB(88, 101, 242)),
        ColorSequenceKeypoint.new(1, color2 or Color3.fromRGB(60, 60, 60))
    }
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

function Utils.UI:MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Utils.UI:Ripple(button, x, y)
    if not button then return end

    local ripple = Instance.new("Frame")
    ripple.Name = Utils.NameGenerator:Generate()
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.6
    ripple.BorderSizePixel = 0
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.Position = UDim2.new(0, x or button.AbsoluteSize.X / 2, 0, y or button.AbsoluteSize.Y / 2)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Parent = button

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple

    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2

    self:Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    task.delay(0.6, function()
        if ripple then
            ripple:Destroy()
        end
    end)
end

function Utils.UI:ScaleTextToBounds(textLabel, maxWidth)
    if not textLabel or not maxWidth then return end

    local textSize = textLabel.TextSize
    textLabel.TextScaled = false

    while textLabel.TextBounds.X > maxWidth and textSize > 8 do
        textSize = textSize - 1
        textLabel.TextSize = textSize
    end
end

Utils.Math = {}

function Utils.Math:Lerp(a, b, t)
    return a + (b - a) * t
end

function Utils.Math:Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Utils.Math:Map(value, inMin, inMax, outMin, outMax)
    return outMin + (outMax - outMin) * ((value - inMin) / (inMax - inMin))
end

function Utils.Math:Round(value, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(value * mult + 0.5) / mult
end

function Utils.Math:RandomRange(min, max)
    return min + math.random() * (max - min)
end

Utils.Table = {}

function Utils.Table:DeepCopy(tbl)
    local copy = {}
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            copy[key] = self:DeepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

function Utils.Table:Merge(base, override)
    local result = self:DeepCopy(base)
    for key, value in pairs(override) do
        result[key] = value
    end
    return result
end

function Utils.Table:Find(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then
            return i
        end
    end
    return nil
end

function Utils.Table:Filter(tbl, predicate)
    local result = {}
    for _, value in ipairs(tbl) do
        if predicate(value) then
            table.insert(result, value)
        end
    end
    return result
end

function Utils.Table:Map(tbl, mapper)
    local result = {}
    for i, value in ipairs(tbl) do
        result[i] = mapper(value)
    end
    return result
end

Utils.File = {}

function Utils.File:Write(fileName, data)
    if not writefile then return false end

    return pcall(function()
        writefile(fileName, data)
    end)
end

function Utils.File:Read(fileName)
    if not readfile then return nil end

    local success, data = pcall(function()
        return readfile(fileName)
    end)

    if success then
        return data
    end
    return nil
end

function Utils.File:Exists(fileName)
    if not isfile then return false end

    return pcall(function()
        return isfile(fileName)
    end)
end

function Utils.File:Delete(fileName)
    if not delfile then return false end

    return pcall(function()
        delfile(fileName)
    end)
end

function Utils.File:CreateFolder(folderName)
    if not makefolder then return false end

    return pcall(function()
        if not isfolder(folderName) then
            makefolder(folderName)
        end
    end)
end

function Utils.File:WriteJSON(fileName, data)
    local json = game:GetService("HttpService"):JSONEncode(data)
    return self:Write(fileName, json)
end

function Utils.File:ReadJSON(fileName)
    local data = self:Read(fileName)
    if data then
        return game:GetService("HttpService"):JSONDecode(data)
    end
    return nil
end

Utils.HTTP = {}

function Utils.HTTP:Request(options)
    options = options or {}

    local httpFunc = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)

    if not httpFunc then
        warn("HTTP requests are not supported on this executor")
        return nil
    end

    local success, response = pcall(function()
        return httpFunc(options)
    end)

    if success then
        return response
    else
        warn("HTTP request failed: " .. tostring(response))
        return nil
    end
end

function Utils.HTTP:Get(url)
    return self:Request({
        Url = url,
        Method = "GET"
    })
end

function Utils.HTTP:Post(url, data, headers)
    return self:Request({
        Url = url,
        Method = "POST",
        Headers = headers or {["Content-Type"] = "application/json"},
        Body = data
    })
end

function Utils.HTTP:DownloadFile(url, fileName)
    local response = self:Get(url)
    if response and response.Body then
        return Utils.File:Write(fileName, response.Body)
    end
    return false
end

local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(parent)
    local self = setmetatable({}, NotificationSystem)

    self.Container = CreateObfuscatedInstance("Frame", parent)
    self.Container.Size = UDim2.new(0, 300, 1, -20)
    self.Container.Position = UDim2.new(1, -320, 0, 10)
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0

    self.Layout = CreateObfuscatedInstance("UIListLayout", self.Container)
    self.Layout.SortOrder = Enum.SortOrder.LayoutOrder
    self.Layout.Padding = UDim.new(0, 8)
    self.Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom

    self.Notifications = {}

    return self
end

function NotificationSystem:Notify(data)
    data = data or {}

    local notification = {}

    local frame = CreateObfuscatedInstance("Frame", self.Container)
    frame.Size = UDim2.new(1, 0, 0, 80)
    frame.BackgroundColor3 = data.Background or Themes.Default.ElementBackground
    frame.BorderSizePixel = 0
    frame.LayoutOrder = #self.Notifications

    Utils.UI:CreateCorner(frame, UDim.new(0, 8))
    Utils.UI:CreateStroke(frame, data.Stroke or Themes.Default.ElementStroke)

    Utils.UI:CreateShadow(frame)

    local icon = CreateObfuscatedInstance("ImageLabel", frame)
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0, 10, 0, 20)
    icon.BackgroundTransparency = 1
    icon.Image = data.Image or ""
    icon.ImageColor3 = data.ImageColor or Themes.Default.Primary

    Utils.UI:CreateCorner(icon, UDim.new(1, 0))

    local title = CreateObfuscatedInstance("TextLabel", frame)
    title.Size = UDim2.new(1, -70, 0, 25)
    title.Position = UDim2.new(0, 60, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = data.Title or "Notification"
    title.TextColor3 = data.TitleColor or Themes.Default.Text
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left

    local content = CreateObfuscatedInstance("TextLabel", frame)
    content.Size = UDim2.new(1, -70, 0, 40)
    content.Position = UDim2.new(0, 60, 0, 35)
    content.BackgroundTransparency = 1
    content.Text = data.Content or ""
    content.TextColor3 = data.ContentColor or Themes.Default.TextDark
    content.TextSize = 13
    content.Font = Enum.Font.Gotham
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextWrapped = true

    if data.Duration then
        local progressBar = CreateObfuscatedInstance("Frame", frame)
        progressBar.Size = UDim2.new(1, 0, 0, 3)
        progressBar.Position = UDim2.new(0, 0, 1, -3)
        progressBar.BackgroundColor3 = data.ProgressColor or Themes.Default.Primary
        progressBar.BorderSizePixel = 0

        Utils.UI:CreateCorner(progressBar, UDim.new(0, 2))

        Utils.UI:Tween(progressBar, {
            Size = UDim2.new(0, 0, 0, 3)
        }, data.Duration, Enum.EasingStyle.Linear)

        task.delay(data.Duration, function()
            Utils.UI:Tween(frame, {
                Position = UDim2.new(1, 50, 0, frame.AbsolutePosition.Y),
                BackgroundTransparency = 1
            }, 0.3)

            task.wait(0.3)
            frame:Destroy()
        end)
    end

    frame.Position = UDim2.new(1, 50, 0, 0)
    Utils.UI:Tween(frame, {
        Position = UDim2.new(0, 0, 0, 0)
    }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    table.insert(self.Notifications, notification)

    return notification
end

function NotificationSystem:Success(data)
    data.Image = data.Image or "rbxassetid://3944680095"
    data.ImageColor = Themes.Default.Success
    data.ProgressColor = Themes.Default.Success
    self:Notify(data)
end

function NotificationSystem:Warning(data)
    data.Image = data.Image or "rbxassetid://3944676352"
    data.ImageColor = Themes.Default.Warning
    data.ProgressColor = Themes.Default.Warning
    self:Notify(data)
end

function NotificationSystem:Error(data)
    data.Image = data.Image or "rbxassetid://3944679247"
    data.ImageColor = Themes.Default.Error
    data.ProgressColor = Themes.Default.Error
    self:Notify(data)
end

function NotificationSystem:Info(data)
    data.Image = data.Image or "rbxassetid://3944681800"
    data.ImageColor = Themes.Default.Info
    data.ProgressColor = Themes.Default.Info
    self:Notify(data)
end

local Luva = {}
Luva.__index = Luva

Luva.Flags = {}
Luva.Elements = {}
Luva.Windows = {}
Luva.CustomThemes = {}
Luva.CurrentTheme = Themes.Default
Luva.SecureMode = false
Luva.AntiDetection = AntiDetection.new()
Luva.ExecutorInfo = ExecutorDetector:Detect()

Luva.Version = "1.0.0"
Luva.Build = "Release"

function Luva:Init()

    _G.LUVA_LOADED = true
    _G.LUVA_SECURE = true

    if self.SecureMode then
        self.AntiDetection:EnableSecureMode()
    end

    spawn(function()
        while _G.LUVA_LOADED do
            if not self.AntiDetection:CheckForCheaters() then
                break
            end
            task.wait(5)
        end
    end)

    spawn(function()
        while _G.LUVA_LOADED do
            self:UpdateDynamicNames()
            task.wait(0.001)
        end
    end)
end

function Luva:UpdateDynamicNames()
    for _, window in ipairs(self.Windows) do
        if window and window.Instance then
            pcall(function()
                window.Instance.Name = GenerateDynamicName()
            end)
        end
    end
end

function Luva:CreateWindow(config)
    config = config or {}

    local guiService = game:GetService("CoreGui")
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    local screenGui = CreateObfuscatedInstance("ScreenGui")
    screenGui.Name = GenerateDynamicName()
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true

    local success = pcall(function()
        screenGui.Parent = guiService
    end)

    if not success then
        screenGui.Parent = playerGui
    end

    self.AntiDetection:ProtectInstance(screenGui)

    local window = CreateObfuscatedInstance("Frame", screenGui)
    window.Size = config.Size or UDim2.new(0, 600, 0, 400)
    window.Position = config.Position or UDim2.new(0.5, -300, 0.5, -200)
    window.BackgroundColor3 = self.CurrentTheme.Background
    window.BorderSizePixel = 0
    window.ClipsDescendants = true

    Utils.UI:CreateCorner(window, UDim.new(0, 10))
    Utils.UI:CreateShadow(window)

    local topbar = CreateObfuscatedInstance("Frame", window)
    topbar.Size = UDim2.new(1, 0, 0, 45)
    topbar.BackgroundColor3 = self.CurrentTheme.Topbar
    topbar.BorderSizePixel = 0

    Utils.UI:CreateCorner(topbar, UDim.new(0, 10))

    local topbarFix = CreateObfuscatedInstance("Frame", topbar)
    topbarFix.Size = UDim2.new(1, 0, 0.5, 0)
    topbarFix.Position = UDim2.new(0, 0, 0.5, 0)
    topbarFix.BackgroundColor3 = self.CurrentTheme.Topbar
    topbarFix.BorderSizePixel = 0

    if config.Icon then
        local icon = CreateObfuscatedInstance("ImageLabel", topbar)
        icon.Size = UDim2.new(0, 24, 0, 24)
        icon.Position = UDim2.new(0, 15, 0, 10)
        icon.BackgroundTransparency = 1
        icon.Image = config.Icon
        icon.ImageColor3 = self.CurrentTheme.Primary
    end

    local title = CreateObfuscatedInstance("TextLabel", topbar)
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, config.Icon and 45 or 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Name or "Luva Window"
    title.TextColor3 = self.CurrentTheme.Text
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left

    local controls = CreateObfuscatedInstance("Frame", topbar)
    controls.Size = UDim2.new(0, 90, 1, 0)
    controls.Position = UDim2.new(1, -95, 0, 0)
    controls.BackgroundTransparency = 1

    local minimizeBtn = CreateObfuscatedInstance("TextButton", controls)
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(0, 0, 0, 7)
    minimizeBtn.BackgroundColor3 = self.CurrentTheme.Secondary
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = self.CurrentTheme.Text
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold

    Utils.UI:CreateCorner(minimizeBtn, UDim.new(1, 0))

    local maximizeBtn = CreateObfuscatedInstance("TextButton", controls)
    maximizeBtn.Size = UDim2.new(0, 30, 0, 30)
    maximizeBtn.Position = UDim2.new(0, 35, 0, 7)
    maximizeBtn.BackgroundColor3 = self.CurrentTheme.Secondary
    maximizeBtn.Text = "□"
    maximizeBtn.TextColor3 = self.CurrentTheme.Text
    maximizeBtn.TextSize = 16
    maximizeBtn.Font = Enum.Font.GothamBold

    Utils.UI:CreateCorner(maximizeBtn, UDim.new(1, 0))

    local closeBtn = CreateObfuscatedInstance("TextButton", controls)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(0, 70, 0, 7)
    closeBtn.BackgroundColor3 = Color3.fromRGB(237, 66, 69)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold

    Utils.UI:CreateCorner(closeBtn, UDim.new(1, 0))

    local sidebar = CreateObfuscatedInstance("Frame", window)
    sidebar.Size = UDim2.new(0, 160, 1, -45)
    sidebar.Position = UDim2.new(0, 0, 0, 45)
    sidebar.BackgroundColor3 = self.CurrentTheme.Sidebar
    sidebar.BorderSizePixel = 0

    local sidebarCorner = CreateObfuscatedInstance("UICorner", sidebar)
    sidebarCorner.CornerRadius = UDim.new(0, 10)

    local sidebarFix = CreateObfuscatedInstance("Frame", sidebar)
    sidebarFix.Size = UDim2.new(0.5, 0, 1, 0)
    sidebarFix.Position = UDim2.new(0.5, 0, 0, 0)
    sidebarFix.BackgroundColor3 = self.CurrentTheme.Sidebar
    sidebarFix.BorderSizePixel = 0

    local tabContainer = CreateObfuscatedInstance("ScrollingFrame", sidebar)
    tabContainer.Size = UDim2.new(1, -10, 1, -20)
    tabContainer.Position = UDim2.new(0, 5, 0, 10)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ScrollBarThickness = 2
    tabContainer.ScrollBarImageColor3 = self.CurrentTheme.Primary
    tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local tabLayout = CreateObfuscatedInstance("UIListLayout", tabContainer)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)

    local contentArea = CreateObfuscatedInstance("Frame", window)
    contentArea.Size = UDim2.new(1, -160, 1, -45)
    contentArea.Position = UDim2.new(0, 160, 0, 45)
    contentArea.BackgroundColor3 = self.CurrentTheme.Background
    contentArea.BorderSizePixel = 0

    local contentScroll = CreateObfuscatedInstance("ScrollingFrame", contentArea)
    contentScroll.Size = UDim2.new(1, -20, 1, -20)
    contentScroll.Position = UDim2.new(0, 10, 0, 10)
    contentScroll.BackgroundTransparency = 1
    contentScroll.ScrollBarThickness = 4
    contentScroll.ScrollBarImageColor3 = self.CurrentTheme.Primary
    contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local contentLayout = CreateObfuscatedInstance("UIListLayout", contentScroll)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 10)

    Utils.UI:MakeDraggable(window, topbar)

    local windowObj = {
        Instance = window,
        ScreenGui = screenGui,
        Topbar = topbar,
        Sidebar = sidebar,
        ContentArea = contentArea,
        ContentScroll = contentScroll,
        TabContainer = tabContainer,
        Tabs = {},
        CurrentTab = nil,
        Config = config,
        IsVisible = true,
        IsMinimized = false
    }

    closeBtn.MouseButton1Click:Connect(function()
        Utils.UI:Tween(window, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(window.Position.X.Scale, window.Position.X.Offset + 300, window.Position.Y.Scale, window.Position.Y.Offset + 200)
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)

        task.wait(0.3)
        screenGui:Destroy()

        for i, w in ipairs(self.Windows) do
            if w == windowObj then
                table.remove(self.Windows, i)
                break
            end
        end
    end)

    minimizeBtn.MouseButton1Click:Connect(function()
        windowObj.IsMinimized = not windowObj.IsMinimized

        if windowObj.IsMinimized then
            Utils.UI:Tween(contentArea, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
            Utils.UI:Tween(sidebar, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
            Utils.UI:Tween(window, {Size = UDim2.new(0, 200, 0, 45)}, 0.3)
        else
            Utils.UI:Tween(window, {Size = config.Size or UDim2.new(0, 600, 0, 400)}, 0.3)
            Utils.UI:Tween(contentArea, {Size = UDim2.new(1, -160, 1, -45)}, 0.3)
            Utils.UI:Tween(sidebar, {Size = UDim2.new(0, 160, 1, -45)}, 0.3)
        end
    end)

    function windowObj:Toggle()
        self.IsVisible = not self.IsVisible
        screenGui.Enabled = self.IsVisible
    end

    function windowObj:SetVisible(visible)
        self.IsVisible = visible
        screenGui.Enabled = visible
    end

    function windowObj:Destroy()
        screenGui:Destroy()
        for i, w in ipairs(Luva.Windows) do
            if w == self then
                table.remove(Luva.Windows, i)
                break
            end
        end
    end

    table.insert(self.Windows, windowObj)

    self.AntiDetection:ProtectInstance(window)
    self.AntiDetection:ProtectInstance(screenGui)

    return windowObj
end

function Luva:CreateTab(window, config)
    config = config or {}

    if not window or not window.TabContainer then
        error("Invalid window provided to CreateTab")
        return
    end

    local tabBtn = CreateObfuscatedInstance("TextButton", window.TabContainer)
    tabBtn.Size = UDim2.new(1, -10, 0, 36)
    tabBtn.BackgroundColor3 = self.CurrentTheme.Secondary
    tabBtn.Text = config.Name or "Tab"
    tabBtn.TextColor3 = self.CurrentTheme.TextDark
    tabBtn.TextSize = 14
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.AutoButtonColor = false

    Utils.UI:CreateCorner(tabBtn, UDim.new(0, 8))

    if config.Icon then
        local icon = CreateObfuscatedInstance("ImageLabel", tabBtn)
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0, 10, 0, 8)
        icon.BackgroundTransparency = 1
        icon.Image = config.Icon
        icon.ImageColor3 = self.CurrentTheme.TextDark

        tabBtn.Text = "      " .. (config.Name or "Tab")
    end

    local tabContent = CreateObfuscatedInstance("Frame", window.ContentScroll)
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false

    local tabContentLayout = CreateObfuscatedInstance("UIListLayout", tabContent)
    tabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabContentLayout.Padding = UDim.new(0, 10)

    local tabObj = {
        Instance = tabContent,
        Button = tabBtn,
        Name = config.Name or "Tab",
        Elements = {},
        Window = window
    }

    local function SelectTab()

        for _, tab in ipairs(window.Tabs) do
            tab.Instance.Visible = false
            tab.Button.BackgroundColor3 = Luva.CurrentTheme.Secondary
            tab.Button.TextColor3 = Luva.CurrentTheme.TextDark

            local btnIcon = tab.Button:FindFirstChildOfClass("ImageLabel")
            if btnIcon then
                btnIcon.ImageColor3 = Luva.CurrentTheme.TextDark
            end
        end

        tabContent.Visible = true
        tabBtn.BackgroundColor3 = Luva.CurrentTheme.Primary
        tabBtn.TextColor3 = Luva.CurrentTheme.Text

        local btnIcon = tabBtn:FindFirstChildOfClass("ImageLabel")
        if btnIcon then
            btnIcon.ImageColor3 = Luva.CurrentTheme.Text
        end

        window.CurrentTab = tabObj
    end

    tabBtn.MouseButton1Click:Connect(function()
        Utils.UI:Ripple(tabBtn)
        SelectTab()
    end)

    tabObj.Select = SelectTab

    function tabObj:CreateSection(name)
        return Luva:CreateSection(tabObj, name)
    end

    function tabObj:CreateDivider()
        return Luva:CreateDivider(tabObj)
    end

    function tabObj:CreateButton(config)
        return Luva:CreateButton(tabObj, config)
    end

    function tabObj:CreateToggle(config)
        return Luva:CreateToggle(tabObj, config)
    end

    function tabObj:CreateSlider(config)
        return Luva:CreateSlider(tabObj, config)
    end

    function tabObj:CreateDropdown(config)
        return Luva:CreateDropdown(tabObj, config)
    end

    function tabObj:CreateInput(config)
        return Luva:CreateInput(tabObj, config)
    end

    function tabObj:CreateColorPicker(config)
        return Luva:CreateColorPicker(tabObj, config)
    end

    function tabObj:CreateKeybind(config)
        return Luva:CreateKeybind(tabObj, config)
    end

    function tabObj:CreateLabel(config)
        return Luva:CreateLabel(tabObj, config)
    end

    function tabObj:CreateParagraph(config)
        return Luva:CreateParagraph(tabObj, config)
    end

    table.insert(window.Tabs, tabObj)

    if #window.Tabs == 1 then
        SelectTab()
    end

    return tabObj
end

function Luva:CreateSection(tab, name)
    if not tab or not tab.Instance then return end

    local section = CreateObfuscatedInstance("Frame", tab.Instance)
    section.Size = UDim2.new(1, 0, 0, 30)
    section.BackgroundTransparency = 1
    section.LayoutOrder = #tab.Elements

    local sectionLabel = CreateObfuscatedInstance("TextLabel", section)
    sectionLabel.Size = UDim2.new(1, 0, 1, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = name or "Section"
    sectionLabel.TextColor3 = self.CurrentTheme.Text
    sectionLabel.TextSize = 14
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left

    local underline = CreateObfuscatedInstance("Frame", section)
    underline.Size = UDim2.new(0.3, 0, 0, 2)
    underline.Position = UDim2.new(0, 0, 1, -2)
    underline.BackgroundColor3 = self.CurrentTheme.Primary
    underline.BorderSizePixel = 0

    local sectionObj = {
        Instance = section,
        Label = sectionLabel,
        Set = function(self, newName)
            sectionLabel.Text = newName or "Section"
        end
    }

    table.insert(tab.Elements, sectionObj)
    return sectionObj
end

function Luva:CreateDivider(tab)
    if not tab or not tab.Instance then return end

    local divider = CreateObfuscatedInstance("Frame", tab.Instance)
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.BackgroundColor3 = self.CurrentTheme.ElementStroke
    divider.BorderSizePixel = 0
    divider.LayoutOrder = #tab.Elements

    local dividerObj = {
        Instance = divider,
        Set = function(self, visible)
            divider.Visible = visible ~= false
        end
    }

    table.insert(tab.Elements, dividerObj)
    return dividerObj
end

function Luva:CreateButton(tab, config)
    config = config or {}

    if not tab or not tab.Instance then return end

    local button = CreateObfuscatedInstance("TextButton", tab.Instance)
    button.Size = UDim2.new(1, 0, 0, 36)
    button.BackgroundColor3 = self.CurrentTheme.ElementBackground
    button.Text = config.Name or "Button"
    button.TextColor3 = self.CurrentTheme.Text
    button.TextSize = 14
    button.Font = Enum.Font.GothamSemibold
    button.AutoButtonColor = false
    button.LayoutOrder = #tab.Elements

    Utils.UI:CreateCorner(button, UDim.new(0, 8))
    Utils.UI:CreateStroke(button, self.CurrentTheme.ElementStroke)

    button.MouseEnter:Connect(function()
        Utils.UI:Tween(button, {BackgroundColor3 = self.CurrentTheme.ElementBackgroundHover}, 0.2)
    end)

    button.MouseLeave:Connect(function()
        Utils.UI:Tween(button, {BackgroundColor3 = self.CurrentTheme.ElementBackground}, 0.2)
    end)

    button.MouseButton1Down:Connect(function(x, y)
        Utils.UI:Ripple(button, x, y)
    end)

    button.MouseButton1Click:Connect(function()
        if config.Callback then
            pcall(config.Callback)
        end
    end)

    local buttonObj = {
        Instance = button,
        Set = function(self, newName)
            button.Text = newName or "Button"
        end
    }

    table.insert(tab.Elements, buttonObj)
    return buttonObj
end

function Luva:CreateToggle(tab, config)
    config = config or {}

    if not tab or not tab.Instance then return end

    local toggleFrame = CreateObfuscatedInstance("Frame", tab.Instance)
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.BackgroundColor3 = self.CurrentTheme.ElementBackground
    toggleFrame.BorderSizePixel = 0
    toggleFrame.LayoutOrder = #tab.Elements

    Utils.UI:CreateCorner(toggleFrame, UDim.new(0, 8))
    Utils.UI:CreateStroke(toggleFrame, self.CurrentTheme.ElementStroke)

    local label = CreateObfuscatedInstance("TextLabel", toggleFrame)
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Toggle"
    label.TextColor3 = self.CurrentTheme.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBg = CreateObfuscatedInstance("Frame", toggleFrame)
    toggleBg.Size = UDim2.new(0, 44, 0, 24)
    toggleBg.Position = UDim2.new(1, -56, 0, 8)
    toggleBg.BackgroundColor3 = self.CurrentTheme.Secondary
    toggleBg.BorderSizePixel = 0

    Utils.UI:CreateCorner(toggleBg, UDim.new(1, 0))

    local toggleCircle = CreateObfuscatedInstance("Frame", toggleBg)
    toggleCircle.Size = UDim2.new(0, 20, 0, 20)
    toggleCircle.Position = UDim2.new(0, 2, 0, 2)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0

    Utils.UI:CreateCorner(toggleCircle, UDim.new(1, 0))

    local currentValue = config.CurrentValue or false

    if config.Flag then
        self.Flags[config.Flag] = currentValue
    end

    local function UpdateToggle(value)
        currentValue = value

        if value then
            Utils.UI:Tween(toggleBg, {BackgroundColor3 = self.CurrentTheme.Success}, 0.2)
            Utils.UI:Tween(toggleCircle, {Position = UDim2.new(0, 22, 0, 2)}, 0.2)
        else
            Utils.UI:Tween(toggleBg, {BackgroundColor3 = self.CurrentTheme.Secondary}, 0.2)
            Utils.UI:Tween(toggleCircle, {Position = UDim2.new(0, 2, 0, 2)}, 0.2)
        end

        if config.Flag then
            self.Flags[config.Flag] = value
        end

        if config.Callback then
            pcall(config.Callback, value)
        end
    end

    local clickArea = CreateObfuscatedInstance("TextButton", toggleFrame)
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 2

    clickArea.MouseButton1Click:Connect(function()
        UpdateToggle(not currentValue)
    end)

    UpdateToggle(currentValue)

    local toggleObj = {
        Instance = toggleFrame,
        CurrentValue = currentValue,
        Set = function(self, value)
            UpdateToggle(value)
            self.CurrentValue = value
        end
    }

    table.insert(tab.Elements, toggleObj)
    return toggleObj
end

function Luva:CreateSlider(tab, config)
    config = config or {}

    if not tab or not tab.Instance then return end

    local sliderFrame = CreateObfuscatedInstance("Frame", tab.Instance)
    sliderFrame.Size = UDim2.new(1, 0, 0, 55)
    sliderFrame.BackgroundColor3 = self.CurrentTheme.ElementBackground
    sliderFrame.BorderSizePixel = 0
    sliderFrame.LayoutOrder = #tab.Elements

    Utils.UI:CreateCorner(sliderFrame, UDim.new(0, 8))
    Utils.UI:CreateStroke(sliderFrame, self.CurrentTheme.ElementStroke)

    local label = CreateObfuscatedInstance("TextLabel", sliderFrame)
    label.Size = UDim2.new(0.5, 0, 0, 25)
    label.Position = UDim2.new(0, 12, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Slider"
    label.TextColor3 = self.CurrentTheme.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = CreateObfuscatedInstance("TextLabel", sliderFrame)
    valueLabel.Size = UDim2.new(0.5, -20, 0, 25)
    valueLabel.Position = UDim2.new(0.5, 8, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(config.CurrentValue or config.Range[1] or 0) .. (config.Suffix or "")
    valueLabel.TextColor3 = self.CurrentTheme.Primary
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local sliderBg = CreateObfuscatedInstance("Frame", sliderFrame)
    sliderBg.Size = UDim2.new(1, -24, 0, 8)
    sliderBg.Position = UDim2.new(0, 12, 0, 35)
    sliderBg.BackgroundColor3 = self.CurrentTheme.Secondary
    sliderBg.BorderSizePixel = 0

    Utils.UI:CreateCorner(sliderBg, UDim.new(1, 0))

    local sliderFill = CreateObfuscatedInstance("Frame", sliderBg)
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = self.CurrentTheme.Primary
    sliderFill.BorderSizePixel = 0

    Utils.UI:CreateCorner(sliderFill, UDim.new(1, 0))

    local sliderKnob = CreateObfuscatedInstance("Frame", sliderBg)
    sliderKnob.Size = UDim2.new(0, 16, 0, 16)
    sliderKnob.Position = UDim2.new(0, -8, 0.5, -8)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.BorderSizePixel = 0

    Utils.UI:CreateCorner(sliderKnob, UDim.new(1, 0))

    local range = config.Range or {0, 100}
    local increment = config.Increment or 1
    local currentValue = config.CurrentValue or range[1]

    if config.Flag then
        self.Flags[config.Flag] = currentValue
    end

    local function UpdateSlider(value)
        value = math.clamp(value, range[1], range[2])
        value = math.floor(value / increment + 0.5) * increment

        currentValue = value

        local percent = (value - range[1]) / (range[2] - range[1])
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderKnob.Position = UDim2.new(percent, -8, 0.5, -8)
        valueLabel.Text = tostring(value) .. (config.Suffix or "")

        if config.Flag then
            self.Flags[config.Flag] = value
        end

        if config.Callback then
            pcall(config.Callback, value)
        end
    end

    local dragging = false

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            UpdateSlider(range[1] + pos * (range[2] - range[1]))
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            UpdateSlider(range[1] + pos * (range[2] - range[1]))
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UpdateSlider(currentValue)

    local sliderObj = {
        Instance = sliderFrame,
        CurrentValue = currentValue,
        Set = function(self, value)
            UpdateSlider(value)
            self.CurrentValue = value
        end
    }

    table.insert(tab.Elements, sliderObj)
    return sliderObj
end

function Luva:CreateDropdown(tab, config)
    config = config or {}

    if not tab or not tab.Instance then return end

    local dropdownFrame = CreateObfuscatedInstance("Frame", tab.Instance)
    dropdownFrame.Size = UDim2.new(1, 0, 0, 40)
    dropdownFrame.BackgroundColor3 = self.CurrentTheme.ElementBackground
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.ClipsDescendants = true
    dropdownFrame.LayoutOrder = #tab.Elements

    Utils.UI:CreateCorner(dropdownFrame, UDim.new(0, 8))
    Utils.UI:CreateStroke(dropdownFrame, self.CurrentTheme.ElementStroke)

    local label = CreateObfuscatedInstance("TextLabel", dropdownFrame)
    label.Size = UDim2.new(1, -50, 0, 40)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Dropdown"
    label.TextColor3 = self.CurrentTheme.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left

    local arrow = CreateObfuscatedInstance("TextLabel", dropdownFrame)
    arrow.Size = UDim2.new(0, 30, 0, 40)
    arrow.Position = UDim2.new(1, -35, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = self.CurrentTheme.TextDark
    arrow.TextSize = 14
    arrow.Font = Enum.Font.GothamBold

    local optionsFrame = CreateObfuscatedInstance("Frame", dropdownFrame)
    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
    optionsFrame.Position = UDim2.new(0, 0, 0, 40)
    optionsFrame.BackgroundTransparency = 1
    optionsFrame.Visible = false

    local optionsLayout = CreateObfuscatedInstance("UIListLayout", optionsFrame)
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Padding = UDim.new(0, 2)

    local options = config.Options or {}
    local currentOption = config.CurrentOption or {}
    local multipleOptions = config.MultipleOptions or false
    local isOpen = false

    if config.Flag then
        self.Flags[config.Flag] = currentOption
    end

    local optionButtons = {}

    local function RefreshOptions(newOptions)
        options = newOptions or {}

        for _, btn in ipairs(optionButtons) do
            btn:Destroy()
        end
        optionButtons = {}

        for i, option in ipairs(options) do
            local optionBtn = CreateObfuscatedInstance("TextButton", optionsFrame)
            optionBtn.Size = UDim2.new(1, -10, 0, 30)
            optionBtn.Position = UDim2.new(0, 5, 0, 0)
            optionBtn.BackgroundColor3 = self.CurrentTheme.Secondary
            optionBtn.Text = option
            optionBtn.TextColor3 = self.CurrentTheme.Text
            optionBtn.TextSize = 13
            optionBtn.Font = Enum.Font.Gotham
            optionBtn.LayoutOrder = i

            Utils.UI:CreateCorner(optionBtn, UDim.new(0, 6))

            optionBtn.MouseButton1Click:Connect(function()
                if multipleOptions then

                    local found = false
                    for j, selected in ipairs(currentOption) do
                        if selected == option then
                            table.remove(currentOption, j)
                            found = true
                            break
                        end
                    end
                    if not found then
                        table.insert(currentOption, option)
                    end
                else
                    currentOption = {option}
                    isOpen = false
                    optionsFrame.Visible = false
                    Utils.UI:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.2)
                    Utils.UI:Tween(arrow, {Rotation = 0}, 0.2)
                end

                label.Text = config.Name .. ": " .. table.concat(currentOption, ", ")

                if config.Flag then
                    self.Flags[config.Flag] = currentOption
                end

                if config.Callback then
                    pcall(config.Callback, currentOption)
                end
            end)

            table.insert(optionButtons, optionBtn)
        end

        optionsFrame.Size = UDim2.new(1, 0, 0, #options * 32)
    end

    local clickArea = CreateObfuscatedInstance("TextButton", dropdownFrame)
    clickArea.Size = UDim2.new(1, 0, 0, 40)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 2

    clickArea.MouseButton1Click:Connect(function()
        isOpen = not isOpen

        if isOpen then
            optionsFrame.Visible = true
            Utils.UI:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 40 + optionsFrame.Size.Y.Offset)}, 0.2)
            Utils.UI:Tween(arrow, {Rotation = 180}, 0.2)
        else
            Utils.UI:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.2)
            Utils.UI:Tween(arrow, {Rotation = 0}, 0.2)
            task.wait(0.2)
            optionsFrame.Visible = false
        end
    end)

    RefreshOptions(options)

    if #currentOption > 0 then
        label.Text = config.Name .. ": " .. table.concat(currentOption, ", ")
    end

    local dropdownObj = {
        Instance = dropdownFrame,
        CurrentOption = currentOption,
        Refresh = function(self, newOptions)
            RefreshOptions(newOptions)
        end,
        Set = function(self, newOption)
            currentOption = newOption
            label.Text = config.Name .. ": " .. table.concat(currentOption, ", ")

            if config.Flag then
                self.Flags[config.Flag] = currentOption
            end

            if config.Callback then
                pcall(config.Callback, currentOption)
            end
        end
    }

    table.insert(tab.Elements, dropdownObj)
    return dropdownObj
end

function Luva:CreateInput(tab, config)
    config = config or {}

    if not tab or not tab.Instance then return end

    local inputFrame = CreateObfuscatedInstance("Frame", tab.Instance)
    inputFrame.Size = UDim2.new(1, 0, 0, 40)
    inputFrame.BackgroundColor3 = self.CurrentTheme.ElementBackground
    inputFrame.BorderSizePixel = 0
    inputFrame.LayoutOrder = #tab.Elements

    Utils.UI:CreateCorner(inputFrame, UDim.new(0, 8))
    Utils.UI:CreateStroke(inputFrame, self.CurrentTheme.ElementStroke)

    local label = CreateObfuscatedInstance("TextLabel", inputFrame)
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Input"
    label.TextColor3 = self.CurrentTheme.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left

    local textBox = CreateObfuscatedInstance("TextBox", inputFrame)
    textBox.Size = UDim2.new(0.6, -20, 0, 30)
    textBox.Position = UDim2.new(0.4, 8, 0, 5)
    textBox.BackgroundColor3 = self.CurrentTheme.Secondary
    textBox.Text = config.CurrentValue or ""
    textBox.PlaceholderText = config.PlaceholderText or "Enter text..."
    textBox.TextColor3 = self.CurrentTheme.Text
    textBox.PlaceholderColor3 = self.CurrentTheme.TextDark
    textBox.TextSize = 13
    textBox.Font = Enum.Font.Gotham
    textBox.ClearTextOnFocus = false

    Utils.UI:CreateCorner(textBox, UDim.new(0, 6))

    if config.Flag then
        self.Flags[config.Flag] = textBox.Text
    end

    textBox.FocusLost:Connect(function()
        if config.RemoveTextAfterFocusLost then
            local text = textBox.Text
            textBox.Text = ""

            if config.Flag then
                self.Flags[config.Flag] = text
            end

            if config.Callback then
                pcall(config.Callback, text)
            end
        else
            if config.Flag then
                self.Flags[config.Flag] = textBox.Text
            end

            if config.Callback then
                pcall(config.Callback, textBox.Text)
            end
        end
    end)

    local inputObj = {
        Instance = inputFrame,
        TextBox = textBox,
        Set = function(self, text)
            textBox.Text = text or ""

            if config.Flag then
                Luva.Flags[config.Flag] = textBox.Text
            end

            if config.Callback then
                pcall(config.Callback, textBox.Text)
            end
        end
    }

    table.insert(tab.Elements, inputObj)
    return inputObj
end

function Luva:CreateColorPicker(tab, config)
    config = config or {}

    if not tab or not tab.Instance then return end

    local pickerFrame = CreateObfuscatedInstance("Frame", tab.Instance)
    pickerFrame.Size = UDim2.new(1, 0, 0, 40)
    pickerFrame.BackgroundColor3 = self.CurrentTheme.ElementBackground
    pickerFrame.BorderSizePixel = 0
    pickerFrame.ClipsDescendants = true
    pickerFrame.LayoutOrder = #tab.Elements

    Utils.UI:CreateCorner(pickerFrame, UDim.new(0, 8))
    Utils.UI:CreateStroke(pickerFrame, self.CurrentTheme.ElementStroke)

    local label = CreateObfuscatedInstance("TextLabel", pickerFrame)
    label.Size = UDim2.new(1, -60, 0, 40)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Color Picker"
    label.TextColor3 = self.CurrentTheme.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left

    local colorPreview = CreateObfuscatedInstance("Frame", pickerFrame)
    colorPreview.Size = UDim2.new(0, 30, 0, 30)
    colorPreview.Position = UDim2.new(1, -42, 0, 5)
    colorPreview.BackgroundColor3 = config.Color or Color3.fromRGB(255, 255, 255)
    colorPreview.BorderSizePixel = 0

    Utils.UI:CreateCorner(colorPreview, UDim.new(0, 6))

    local pickerPanel = CreateObfuscatedInstance("Frame", pickerFrame)
    pickerPanel.Size = UDim2.new(1, 0, 0, 200)
    pickerPanel.Position = UDim2.new(0, 0, 0, 40)
    pickerPanel.BackgroundTransparency = 1
    pickerPanel.Visible = false

    local hueSlider = CreateObfuscatedInstance("Frame", pickerPanel)
    hueSlider.Size = UDim2.new(1, -20, 0, 20)
    hueSlider.Position = UDim2.new(0, 10, 0, 10)
    hueSlider.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    hueSlider.BorderSizePixel = 0

    Utils.UI:CreateCorner(hueSlider, UDim.new(0, 4))

    local hueGradient = CreateObfuscatedInstance("UIGradient", hueSlider)
    hueGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }

    local svBox = CreateObfuscatedInstance("Frame", pickerPanel)
    svBox.Size = UDim2.new(1, -20, 0, 120)
    svBox.Position = UDim2.new(0, 10, 0, 40)
    svBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    svBox.BorderSizePixel = 0

    Utils.UI:CreateCorner(svBox, UDim.new(0, 4))

    local svGradient1 = CreateObfuscatedInstance("UIGradient", svBox)
    svGradient1.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }
    svGradient1.Rotation = 0

    local svGradient2 = CreateObfuscatedInstance("UIGradient", svBox)
    svGradient2.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    }
    svGradient2.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    }
    svGradient2.Rotation = -90

    local rgbFrame = CreateObfuscatedInstance("Frame", pickerPanel)
    rgbFrame.Size = UDim2.new(1, -20, 0, 30)
    rgbFrame.Position = UDim2.new(0, 10, 0, 170)
    rgbFrame.BackgroundTransparency = 1

    local rInput = self:CreateRGBInput(rgbFrame, "R", 0)
    local gInput = self:CreateRGBInput(rgbFrame, "G", 70)
    local bInput = self:CreateRGBInput(rgbFrame, "B", 140)

    local hue = 0
    local sat = 1
    local val = 1
    local currentColor = config.Color or Color3.fromRGB(255, 255, 255)

    if config.Flag then
        self.Flags[config.Flag] = currentColor
    end

    local function UpdateColor(color)
        currentColor = color
        colorPreview.BackgroundColor3 = color

        local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
        rInput.Text = tostring(r)
        gInput.Text = tostring(g)
        bInput.Text = tostring(b)

        if config.Flag then
            self.Flags[config.Flag] = color
        end

        if config.Callback then
            pcall(config.Callback, color)
        end
    end

    local hueDragging = false

    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
            hue = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
            svGradient1.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, 1, 1))
            }
            UpdateColor(Color3.fromHSV(hue, sat, val))
        end
    end)

    local svDragging = false

    svBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = true
            sat = math.clamp((input.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
            val = 1 - math.clamp((input.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
            UpdateColor(Color3.fromHSV(hue, sat, val))
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            hue = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
            svGradient1.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, 1, 1))
            }
            UpdateColor(Color3.fromHSV(hue, sat, val))
        end

        if svDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            sat = math.clamp((input.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
            val = 1 - math.clamp((input.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
            UpdateColor(Color3.fromHSV(hue, sat, val))
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
            svDragging = false
        end
    end)

    local isOpen = false

    local clickArea = CreateObfuscatedInstance("TextButton", pickerFrame)
    clickArea.Size = UDim2.new(1, 0, 0, 40)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 2

    clickArea.MouseButton1Click:Connect(function()
        isOpen = not isOpen

        if isOpen then
            pickerPanel.Visible = true
            Utils.UI:Tween(pickerFrame, {Size = UDim2.new(1, 0, 0, 250)}, 0.2)
        else
            Utils.UI:Tween(pickerFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.2)
            task.wait(0.2)
            pickerPanel.Visible = false
        end
    end)

    UpdateColor(currentColor)

    local pickerObj = {
        Instance = pickerFrame,
        CurrentColor = currentColor,
        Set = function(self, color)
            UpdateColor(color)
            self.CurrentColor = color
        end
    }

    table.insert(tab.Elements, pickerObj)
    return pickerObj
end

function Luva:CreateRGBInput(parent, label, xPos)
    local frame = CreateObfuscatedInstance("Frame", parent)
    frame.Size = UDim2.new(0, 60, 1, 0)
    frame.Position = UDim2.new(0, xPos, 0, 0)
    frame.BackgroundTransparency = 1

    local labelText = CreateObfuscatedInstance("TextLabel", frame)
    labelText.Size = UDim2.new(0, 20, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = self.CurrentTheme.Text
    labelText.TextSize = 12
    labelText.Font = Enum.Font.GothamBold

    local input = CreateObfuscatedInstance("TextBox", frame)
    input.Size = UDim2.new(0, 35, 1, 0)
    input.Position = UDim2.new(0, 25, 0, 0)
    input.BackgroundColor3 = self.CurrentTheme.Secondary
    input.Text = "255"
    input.TextColor3 = self.CurrentTheme.Text
    input.TextSize = 12
    input.Font = Enum.Font.Gotham
    input.ClearTextOnFocus = false

    Utils.UI:CreateCorner(input, UDim.new(0, 4))

    return input
end

function Luva:CreateKeybind(tab, config)
    config = config or {}

    if not tab or not tab.Instance then return end

    local keybindFrame = CreateObfuscatedInstance("Frame", tab.Instance)
    keybindFrame.Size = UDim2.new(1, 0, 0, 40)
    keybindFrame.BackgroundColor3 = self.CurrentTheme.ElementBackground
    keybindFrame.BorderSizePixel = 0
    keybindFrame.LayoutOrder = #tab.Elements

    Utils.UI:CreateCorner(keybindFrame, UDim.new(0, 8))
    Utils.UI:CreateStroke(keybindFrame, self.CurrentTheme.ElementStroke)

    local label = CreateObfuscatedInstance("TextLabel", keybindFrame)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Keybind"
    label.TextColor3 = self.CurrentTheme.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left

    local keyButton = CreateObfuscatedInstance("TextButton", keybindFrame)
    keyButton.Size = UDim2.new(0.4, -20, 0, 30)
    keyButton.Position = UDim2.new(0.6, 8, 0, 5)
    keyButton.BackgroundColor3 = self.CurrentTheme.Secondary
    keyButton.Text = config.CurrentKeybind or "None"
    keyButton.TextColor3 = self.CurrentTheme.Text
    keyButton.TextSize = 13
    keyButton.Font = Enum.Font.GothamBold
    keyButton.AutoButtonColor = false

    Utils.UI:CreateCorner(keyButton, UDim.new(0, 6))

    local currentKeybind = config.CurrentKeybind or "None"
    local listening = false
    local holdToInteract = config.HoldToInteract or false

    if config.Flag then
        self.Flags[config.Flag] = currentKeybind
    end

    keyButton.MouseButton1Click:Connect(function()
        listening = true
        keyButton.Text = "..."
    end)

    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if listening and not gameProcessed then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKeybind = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                keyButton.Text = currentKeybind
                listening = false

                if config.Flag then
                    self.Flags[config.Flag] = currentKeybind
                end
            end
        elseif not listening and not gameProcessed then
            local inputKey = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            if inputKey == currentKeybind then
                if holdToInteract then
                    if config.Callback then
                        pcall(config.Callback, true)
                    end
                else
                    if config.Callback then
                        pcall(config.Callback, inputKey)
                    end
                end
            end
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if holdToInteract then
            local inputKey = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            if inputKey == currentKeybind then
                if config.Callback then
                    pcall(config.Callback, false)
                end
            end
        end
    end)

    local keybindObj = {
        Instance = keybindFrame,
        CurrentKeybind = currentKeybind,
        Set = function(self, key)
            currentKeybind = key
            keyButton.Text = key

            if config.Flag then
                Luva.Flags[config.Flag] = key
            end
        end
    }

    table.insert(tab.Elements, keybindObj)
    return keybindObj
end

function Luva:CreateLabel(tab, config)
    config = config or {}

    if not tab or not tab.Instance then return end

    local labelFrame = CreateObfuscatedInstance("Frame", tab.Instance)
    labelFrame.Size = UDim2.new(1, 0, 0, 30)
    labelFrame.BackgroundTransparency = 1
    labelFrame.LayoutOrder = #tab.Elements

    local label = CreateObfuscatedInstance("TextLabel", labelFrame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Label"
    label.TextColor3 = config.Color or self.CurrentTheme.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true

    if config.Icon then
        local icon = CreateObfuscatedInstance("ImageLabel", labelFrame)
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0, 0, 0, 5)
        icon.BackgroundTransparency = 1
        icon.Image = config.Icon
        icon.ImageColor3 = config.Color or self.CurrentTheme.Text

        label.Size = UDim2.new(1, -30, 1, 0)
        label.Position = UDim2.new(0, 28, 0, 0)
    end

    local labelObj = {
        Instance = labelFrame,
        Set = function(self, text, icon, color)
            label.Text = text or "Label"
            if color then
                label.TextColor3 = color
            end
            if icon then
                local iconLabel = labelFrame:FindFirstChildOfClass("ImageLabel")
                if iconLabel then
                    iconLabel.Image = icon
                end
            end
        end
    }

    table.insert(tab.Elements, labelObj)
    return labelObj
end

function Luva:CreateParagraph(tab, config)
    config = config or {}

    if not tab or not tab.Instance then return end

    local paragraphFrame = CreateObfuscatedInstance("Frame", tab.Instance)
    paragraphFrame.Size = UDim2.new(1, 0, 0, 60)
    paragraphFrame.BackgroundColor3 = self.CurrentTheme.ElementBackground
    paragraphFrame.BorderSizePixel = 0
    paragraphFrame.LayoutOrder = #tab.Elements

    Utils.UI:CreateCorner(paragraphFrame, UDim.new(0, 8))
    Utils.UI:CreateStroke(paragraphFrame, self.CurrentTheme.ElementStroke)

    local title = CreateObfuscatedInstance("TextLabel", paragraphFrame)
    title.Size = UDim2.new(1, -20, 0, 25)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Title"
    title.TextColor3 = self.CurrentTheme.Text
    title.TextSize = 15
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left

    local content = CreateObfuscatedInstance("TextLabel", paragraphFrame)
    content.Size = UDim2.new(1, -20, 0, 25)
    content.Position = UDim2.new(0, 10, 0, 30)
    content.BackgroundTransparency = 1
    content.Text = config.Content or "Content"
    content.TextColor3 = self.CurrentTheme.TextDark
    content.TextSize = 13
    content.Font = Enum.Font.Gotham
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextWrapped = true

    local paragraphObj = {
        Instance = paragraphFrame,
        Set = function(self, data)
            title.Text = data.Title or "Title"
            content.Text = data.Content or "Content"
        end
    }

    table.insert(tab.Elements, paragraphObj)
    return paragraphObj
end

function Luva:SaveConfiguration(fileName)
    if not fileName then return end

    local configData = {}

    for flag, value in pairs(self.Flags) do
        if typeof(value) == "Color3" then
            configData[flag] = {
                Type = "Color3",
                R = value.R,
                G = value.G,
                B = value.B
            }
        else
            configData[flag] = value
        end
    end

    local jsonData = game:GetService("HttpService"):JSONEncode(configData)

    if writefile then
        pcall(function()
            if not isfolder("LuvaConfigs") then
                makefolder("LuvaConfigs")
            end
            writefile("LuvaConfigs/" .. fileName .. ".json", jsonData)
        end)
    end
end

function Luva:LoadConfiguration(fileName)
    if not fileName then return end

    if readfile and isfile then
        pcall(function()
            if isfile("LuvaConfigs/" .. fileName .. ".json") then
                local jsonData = readfile("LuvaConfigs/" .. fileName .. ".json")
                local configData = game:GetService("HttpService"):JSONDecode(jsonData)

                for flag, value in pairs(configData) do
                    if type(value) == "table" and value.Type == "Color3" then
                        self.Flags[flag] = Color3.new(value.R, value.G, value.B)
                    else
                        self.Flags[flag] = value
                    end
                end
            end
        end)
    end
end

function Luva:SetTheme(themeName)
    local theme = Themes[themeName] or self.CustomThemes[themeName]
    if not theme then
        warn("Theme '" .. themeName .. "' not found!")
        return
    end

    self.CurrentTheme = theme

    for _, window in ipairs(self.Windows) do
        self:UpdateWindowTheme(window, theme)
    end
end

function Luva:RegisterCustomTheme(name, theme)
    self.CustomThemes[name] = theme
    return theme
end

function Luva:UpdateWindowTheme(window, theme)
    if not window or not window.Instance then return end

    window.Instance.BackgroundColor3 = theme.Background
    window.Topbar.BackgroundColor3 = theme.Topbar
    window.Sidebar.BackgroundColor3 = theme.Sidebar
    window.ContentArea.BackgroundColor3 = theme.Background

end

function Luva:GetThemes()
    local themeList = {}
    for name, _ in pairs(Themes) do
        table.insert(themeList, name)
    end
    for name, _ in pairs(self.CustomThemes) do
        table.insert(themeList, name)
    end
    return themeList
end

function Luva:CreateKeySystem(config)
    config = config or {}

    local keyWindow = self:CreateWindow({
        Name = config.Title or "Key System",
        Size = UDim2.new(0, 400, 0, 250)
    })

    local tab = self:CreateTab(keyWindow, {Name = "Key"})

    self:CreateLabel(tab, {Text = config.Subtitle or "Enter your key to continue"})

    if config.Note then
        self:CreateLabel(tab, {Text = config.Note, Color = self.CurrentTheme.TextDark})
    end

    local keyInput = self:CreateInput(tab, {
        Name = "Key",
        PlaceholderText = "Enter key..."
    })

    local validKeys = config.Keys or {}
    local fileName = config.FileName or "LuvaKey"
    local saveKey = config.SaveKey ~= false

    self:CreateButton(tab, {
        Name = "Submit",
        Callback = function()
            local enteredKey = keyInput.TextBox.Text

            local isValid = false
            for _, key in ipairs(validKeys) do
                if enteredKey == key then
                    isValid = true
                    break
                end
            end

            if not isValid and saveKey and readfile then
                pcall(function()
                    if isfile(fileName .. ".txt") then
                        local savedKey = readfile(fileName .. ".txt")
                        if savedKey == enteredKey then
                            isValid = true
                        end
                    end
                end)
            end

            if isValid then

                if saveKey and writefile then
                    pcall(function()
                        writefile(fileName .. ".txt", enteredKey)
                    end)
                end

                keyWindow:Destroy()

                if config.Callback then
                    pcall(config.Callback, true)
                end
            else

                self.NotificationSystem:Error({
                    Title = "Invalid Key",
                    Content = "The key you entered is incorrect!",
                    Duration = 3
                })

                if config.Callback then
                    pcall(config.Callback, false)
                end
            end
        end
    })

    return keyWindow
end

function Luva:PromptDiscordJoin(config)
    config = config or {}

    if not config.Enabled then return end

    local invite = config.Invite or ""
    local rememberJoins = config.RememberJoins ~= false

    if rememberJoins and isfile then
        local joined = pcall(function()
            return isfile("LuvaDiscordJoined.txt")
        end)
        if joined then return end
    end

    local discordWindow = self:CreateWindow({
        Name = "Discord",
        Size = UDim2.new(0, 350, 0, 200)
    })

    local tab = self:CreateTab(discordWindow, {Name = "Join"})

    self:CreateLabel(tab, {Text = "Join our Discord server!"})
    self:CreateLabel(tab, {Text = "discord.gg/" .. invite, Color = self.CurrentTheme.Primary})

    self:CreateButton(tab, {
        Name = "Join Discord",
        Callback = function()
            if request then
                pcall(function()
                    request({
                        Url = "http://127.0.0.1:6463/rpc?v=1",
                        Method = "POST",
                        Headers = {
                            ["Content-Type"] = "application/json",
                            ["Origin"] = "https://discord.com"
                        },
                        Body = game:GetService("HttpService"):JSONEncode({
                            cmd = "INVITE_BROWSER",
                            nonce = game:GetService("HttpService"):GenerateGUID(false),
                            args = {code = invite}
                        })
                    })
                end)
            end

            if rememberJoins and writefile then
                pcall(function()
                    writefile("LuvaDiscordJoined.txt", "true")
                end)
            end

            discordWindow:Destroy()
        end
    })

    self:CreateButton(tab, {
        Name = "Skip",
        Callback = function()
            discordWindow:Destroy()
        end
    })
end

function Luva:Notify(data)
    if not self.NotificationSystem then

        local guiService = game:GetService("CoreGui")
        local notifGui = CreateObfuscatedInstance("ScreenGui")
        notifGui.Name = GenerateDynamicName()
        notifGui.ResetOnSpawn = false
        notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        pcall(function()
            notifGui.Parent = guiService
        end)

        if not notifGui.Parent then
            notifGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        end

        self.NotificationSystem = NotificationSystem.new(notifGui)
    end

    self.NotificationSystem:Notify(data)
end

function Luva:NotifySuccess(data)
    self:Notify(data)
end

function Luva:NotifyWarning(data)
    self:Notify(data)
end

function Luva:NotifyError(data)
    self:Notify(data)
end

function Luva:SetVisibility(visible)
    for _, window in ipairs(self.Windows) do
        window:SetVisible(visible)
    end
end

function Luva:IsVisible()
    for _, window in ipairs(self.Windows) do
        if window.IsVisible then
            return true
        end
    end
    return false
end

function Luva:Destroy()
    for _, window in ipairs(self.Windows) do
        pcall(function()
            window:Destroy()
        end)
    end

    self.Windows = {}
    _G.LUVA_LOADED = nil
    _G.LUVA = nil
end

Luva:Init()

return Luva
