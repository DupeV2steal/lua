local player = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- 1. تنظيف النسخ القديمة
if CoreGui:FindFirstChild("VIP_System_Mini_V22") then
    CoreGui:FindFirstChild("VIP_System_Mini_V22"):Destroy()
end

-- 2. قاعدة البيانات (كل الإحداثيات المحدثة 3، 5، 7، 8)
local returnPoint = Vector3.new(122.55, 3.23, 10.89) 
local vipPositions = {
    [1] = Vector3.new(242.00, 3.28, 136.10),
    [2] = Vector3.new(341.69, 3.28, 136.72),
    [3] = Vector3.new(473.77, 3.28, 137.52), 
    [4] = Vector3.new(652.35, 3.28, 137.15),
    [5] = Vector3.new(918.35, 3.28, 137.37), 
    [6] = Vector3.new(1317.10, 3.28, 136.09),
    [7] = Vector3.new(1974.78, 3.28, 136.71),
    [8] = Vector3.new(2416.45, 3.28, 137.60), -- تم التحديث بناءً على آخر صورة
}

local currentVIP = 0

-- 3. بناء الواجهة الرسومية (تصميم Mini)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VIP_System_Mini_V22"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 230)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -115)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Text = "🏆 VIP SYSTEM"
Title.Size = UDim2.new(1, 0, 1, 0)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.FredokaOne
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.Parent = Header

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0.16, 0)
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.Font = Enum.Font.FredokaOne
StatusLabel.TextSize = 16
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = MainFrame

-- 4. الأزرار المصغرة
local function createBtn(text, pos, size, color)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Position = pos
    btn.Size = size
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.FredokaOne
    btn.TextSize = 13
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local UpBtn = createBtn("⬆️ UP", UDim2.new(0.05, 0, 0.32, 0), UDim2.new(0, 100, 0, 35), Color3.fromRGB(60, 60, 68))
local DownBtn = createBtn("⬇️ DOWN", UDim2.new(0.52, 0, 0.32, 0), UDim2.new(0, 100, 0, 35), Color3.fromRGB(60, 60, 68))
local UnlockBtn = createBtn("🔓 UNLOCK DOORS", UDim2.new(0.05, 0, 0.52, 0), UDim2.new(0.9, 0, 0, 32), Color3.fromRGB(160, 40, 40))
local ZoomBtn = createBtn("🔍 UNLOCK ZOOM", UDim2.new(0.05, 0, 0.68, 0), UDim2.new(0.9, 0, 0, 32), Color3.fromRGB(40, 100, 160))
local CloseBtn = createBtn("إغلاق", UDim2.new(0.05, 0, 0.85, 0), UDim2.new(0.9, 0, 0, 25), Color3.fromRGB(75, 75, 80))

-- 5. تحديث النصوص ديناميكياً
local function updateUI()
    if currentVIP == 8 then
        UpBtn.Text = "🏁 الأخير"
    else
        UpBtn.Text = "⬆️ UP"
    end

    if currentVIP == 0 then
        DownBtn.Text = "🏠 الأول"
    else
        DownBtn.Text = "⬇️ DOWN"
    end
    StatusLabel.Text = "VIP Wall " .. currentVIP
end

-- 6. نظام النقل والسرعات
local function vipTeleport(targetPos, wallNumber, isGoingDown)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local distance = (hrp.Position - targetPos).Magnitude
        local speed = 1200 
        local easingStyle = Enum.EasingStyle.Linear
        
        if isGoingDown then
            speed = 850 
            easingStyle = Enum.EasingStyle.Quad
        elseif wallNumber == 7 or wallNumber == 8 then
            speed = 800
            easingStyle = Enum.EasingStyle.Quad
        end
        
        TweenService:Create(hrp, TweenInfo.new(distance/speed, easingStyle, Enum.EasingDirection.Out), {CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))}):Play()
    end
end

-- وظائف السكربت
local function autoDetect()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local bestMatch = 0
    local shortestDistance = 25
    for i, pos in ipairs(vipPositions) do
        local dist = (hrp.Position - pos).Magnitude
        if dist < shortestDistance then bestMatch = i shortestDistance = dist end
    end
    currentVIP = bestMatch
    updateUI()
end

UpBtn.MouseButton1Click:Connect(function()
    if currentVIP < #vipPositions then
        currentVIP = currentVIP + 1
        updateUI()
        vipTeleport(vipPositions[currentVIP], currentVIP, false)
    end
end)

DownBtn.MouseButton1Click:Connect(function()
    if currentVIP > 1 then
        currentVIP = currentVIP - 1
        updateUI()
        vipTeleport(vipPositions[currentVIP], currentVIP, true)
    else
        currentVIP = 0
        updateUI()
        vipTeleport(returnPoint, 0, true)
    end
end)

ZoomBtn.MouseButton1Click:Connect(function()
    player.CameraMaxZoomDistance = 10000
    ZoomBtn.Text = "✅ ZOOM UNLOCKED"
    task.wait(2)
    ZoomBtn.Text = "🔍 UNLOCK ZOOM"
end)

UnlockBtn.MouseButton1Click:Connect(function()
    UnlockBtn.Text = "⏳ UNLOCKING..."
    local shared = game.Workspace:FindFirstChild("DefaultMap_SharedInstances")
    if shared and shared:FindFirstChild("VIPWalls") then
        shared.VIPWalls:Destroy()
        UnlockBtn.Text = "✅ VIP DOORS REMOVED"
    else
        local backup = game.Workspace:FindFirstChild("VIPWalls", true)
        if backup then backup:Destroy() UnlockBtn.Text = "✅ VIP DOORS REMOVED" end
    end
    task.wait(2)
    UnlockBtn.Text = "🔓 UNLOCK DOORS"
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

autoDetect()
player.CharacterAdded:Connect(function() task.wait(1) autoDetect() end)