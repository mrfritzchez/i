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

return Utils
