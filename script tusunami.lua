local player = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

-- تنظيف النسخ القديمة
if CoreGui:FindFirstChild("E15_Final_PRO") then
    CoreGui:FindFirstChild("E15_Final_PRO"):Destroy()
end

-- متغيرات التحكم
local jumping, afkEnabled = false, false
local vipActive, gapsActive, fpsActive = false, false, false
local instantEActive = false
local flightActive, espActive, brightActive = false, false, false
local originalHoldDurations = {}

-- 1. الواجهة الرئيسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "E15_Final_PRO"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- أيقونة الفتح (E15)
local OpenIcon = Instance.new("TextButton")
OpenIcon.Name = "OpenIcon"; OpenIcon.Visible = false; OpenIcon.Size = UDim2.new(0, 55, 0, 55)
OpenIcon.Position = UDim2.new(0.95, -55, 0.05, 0); OpenIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
OpenIcon.Text = "E15"; OpenIcon.TextColor3 = Color3.new(1,1,1); OpenIcon.Font = Enum.Font.FredokaOne
OpenIcon.TextSize = 18; OpenIcon.Parent = ScreenGui; OpenIcon.Draggable = true
Instance.new("UICorner", OpenIcon).CornerRadius = UDim.new(1, 0)
local IconStroke = Instance.new("UIStroke", OpenIcon)
IconStroke.Color = Color3.fromRGB(180, 50, 50); IconStroke.Thickness = 2

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 400); MainFrame.Position = UDim2.new(0.5, -140, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50); MainFrame.Active = true; MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

-- زر الإغلاق X
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25); CloseBtn.Position = UDim2.new(0.88, 0, 0.03, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50); CloseBtn.Parent = MainFrame
CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.new(1, 1, 1); CloseBtn.Font = Enum.Font.FredokaOne; CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenIcon.Visible = true end)
OpenIcon.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenIcon.Visible = false end)

local Header = Instance.new("TextLabel")
Header.Text = "E15 V10"; Header.Size = UDim2.new(1, 0, 0, 45); Header.TextColor3 = Color3.new(1, 1, 1)
Header.Font = Enum.Font.FredokaOne; Header.TextSize = 20; Header.BackgroundTransparency = 1; Header.Parent = MainFrame

-- نظام التبويبات
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(1, 0, 0.1, 0); TabContainer.Position = UDim2.new(0, 0, 0.12, 0); TabContainer.BackgroundTransparency = 1

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, 0, 0.75, 0); ContentFrame.Position = UDim2.new(0, 0, 0.25, 0); ContentFrame.BackgroundTransparency = 1

local MainContent = Instance.new("ScrollingFrame", ContentFrame)
MainContent.Size = UDim2.new(1, 0, 1, 0); MainContent.BackgroundTransparency = 1; MainContent.ScrollBarThickness = 0; MainContent.Visible = true

local EventContent = Instance.new("ScrollingFrame", ContentFrame)
EventContent.Size = UDim2.new(1, 0, 1, 0); EventContent.BackgroundTransparency = 1; EventContent.Visible = false; EventContent.ScrollBarThickness = 0

local WorldContent = Instance.new("ScrollingFrame", ContentFrame)
WorldContent.Size = UDim2.new(1, 0, 1, 0); WorldContent.BackgroundTransparency = 1; WorldContent.Visible = false; WorldContent.ScrollBarThickness = 0

local DevContent = Instance.new("ScrollingFrame", ContentFrame)
DevContent.Size = UDim2.new(1, 0, 1, 0); DevContent.BackgroundTransparency = 1; DevContent.Visible = false; DevContent.ScrollBarThickness = 0

local allTabs = {MainContent, EventContent, WorldContent, DevContent}
local allTabBtns = {}

local function createTabBtn(name, xPos, targetFrame)
    local btn = Instance.new("TextButton", TabContainer)
    btn.Text = name; btn.Size = UDim2.new(0.22, 0, 0, 30); btn.Position = UDim2.new(0.04 + xPos, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55); btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.FredokaOne; btn.TextSize = 9
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function()
        for _, content in pairs(allTabs) do content.Visible = false end
        for _, tBtn in pairs(allTabBtns) do 
            tBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            tBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        targetFrame.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(65, 65, 75); btn.TextColor3 = Color3.new(1, 1, 1)
    end)
    allTabBtns[name] = btn
    return btn
end

createTabBtn("MAIN", 0, MainContent)
createTabBtn("EVENT", 0.24, EventContent)
createTabBtn("WORLD", 0.48, WorldContent)
createTabBtn("DEV", 0.72, DevContent)

allTabBtns["MAIN"].BackgroundColor3 = Color3.fromRGB(65, 65, 75); allTabBtns["MAIN"].TextColor3 = Color3.new(1, 1, 1)

local function createBtn(text, yPos, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Text = text; btn.Size = UDim2.new(0.9, 0, 0, 38); btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 60); btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.FredokaOne; btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

-----------------------------------------------------------
-- قسم DEV (المعدل مع رابط الديسكورد)
-----------------------------------------------------------
local DiscordBtn = createBtn("📋 Discord", 10, DevContent)
DiscordBtn.MouseButton1Click:Connect(function()
    local discordLink = "https://discord.gg/4RaDMGcmff"
    setclipboard(discordLink)
    -- محاولة فتح الرابط للمنفذين الذين يدعمون ذلك
    if request then
        request({
            Url = "http://127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Origin"] = "https://discord.com"
            },
            Body = game:GetService("HttpService"):JSONEncode({
                cmd = "INVITE_BROWSER",
                args = {
                    code = "4RaDMGcmff"
                },
                nonce = game:GetService("HttpService"):GenerateGUID(false)
            }),
        })
    end
    DiscordBtn.Text = "✅ Link Copied!"
    task.wait(2)
    DiscordBtn.Text = "📋 Discord"
end)

local DevInfo = Instance.new("TextLabel", DevContent)
DevInfo.Size = UDim2.new(1, 0, 0, 150); DevInfo.Position = UDim2.new(0, 0, 0, 60)
DevInfo.BackgroundTransparency = 1; DevInfo.TextColor3 = Color3.new(1, 1, 1)
DevInfo.Font = Enum.Font.FredokaOne; DevInfo.TextSize = 14
DevInfo.Text = "E15 \nVIP + GAPS\nAuto Collect\nFlight System\nESP Players"
DevInfo.LineHeight = 1.5

-----------------------------------------------------------
-- قائمة WORLD
-----------------------------------------------------------
local FlightBtn = createBtn("✈️ Flight : OFF", 10, WorldContent)
local EspBtn = createBtn("🔴 Players ESP : OFF", 55, WorldContent)
local BrightBtn = createBtn("💡 Bright : OFF", 100, WorldContent)

FlightBtn.MouseButton1Click:Connect(function()
    flightActive = not flightActive
    FlightBtn.Text = flightActive and "✈️ Flight : ON" or "✈️ Flight : OFF"
    FlightBtn.BackgroundColor3 = flightActive and Color3.fromRGB(35, 150, 90) or Color3.fromRGB(55, 55, 60)
    if flightActive then loadstring(game:HttpGet("https://raw.githubusercontent.com/Al3nef/lua/refs/heads/main/protected_flyeyad.lua"))() end
end)

BrightBtn.MouseButton1Click:Connect(function()
    brightActive = not brightActive
    BrightBtn.Text = brightActive and "💡 Bright : ON" or "💡 Bright : OFF"
    BrightBtn.BackgroundColor3 = brightActive and Color3.fromRGB(35, 150, 90) or Color3.fromRGB(55, 55, 60)
    if brightActive then Lighting.ClockTime = 12; Lighting.GlobalShadows = false else Lighting.ClockTime = 14; Lighting.GlobalShadows = true end
end)

EspBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    EspBtn.Text = espActive and "🔴 ESP : ON" or "🔴 Players ESP : OFF"
    EspBtn.BackgroundColor3 = espActive and Color3.fromRGB(35, 150, 90) or Color3.fromRGB(55, 55, 60)
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character then
            local highlight = p.Character:FindFirstChild("PlayerHL")
            if espActive then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "PlayerHL"; highlight.FillColor = Color3.fromRGB(255, 0, 0)
                end
            else if highlight then highlight:Destroy() end end
        end
    end
end)

-----------------------------------------------------------
-- قائمة MAIN
-----------------------------------------------------------
local InfJumpBtn = createBtn("🦘 Infinite Jump : OFF", 10, MainContent)
local AntiAfkBtn = createBtn("🛡️ Anti-AFK : OFF", 55, MainContent)
local VipBtn = createBtn("🏆 VIP", 100, MainContent)
local GapsBtn = createBtn("⚡ GAPS", 145, MainContent)

InfJumpBtn.MouseButton1Click:Connect(function()
    jumping = not jumping
    InfJumpBtn.Text = jumping and "🦘 Infinite Jump : ON" or "🦘 Infinite Jump : OFF"
    InfJumpBtn.BackgroundColor3 = jumping and Color3.fromRGB(35, 150, 90) or Color3.fromRGB(55, 55, 60)
end)
UserInputService.JumpRequest:Connect(function() if jumping and player.Character then player.Character.Humanoid:ChangeState("Jumping") end end)

VipBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Al3nef/lua/refs/heads/main/vip%20walls%20unlock.lua"))()
    VipBtn.Text = "✅ VIP ACTIVE"; VipBtn.BackgroundColor3 = Color3.fromRGB(35, 150, 90)
end)

GapsBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Al3nef/lua/refs/heads/main/gabs%20teleport.lua"))()
    GapsBtn.Text = "✅ GAPS ACTIVE"; GapsBtn.BackgroundColor3 = Color3.fromRGB(35, 150, 90)
end)

-----------------------------------------------------------
-- قائمة EVENT
-----------------------------------------------------------
local InstantEBtn = createBtn("⚡ Instant E : OFF", 10, EventContent)
InstantEBtn.MouseButton1Click:Connect(function()
    instantEActive = not instantEActive
    InstantEBtn.Text = instantEActive and "⚡ Instant E : ON" or "⚡ Instant E : OFF"
    InstantEBtn.BackgroundColor3 = instantEActive and Color3.fromRGB(35, 150, 90) or Color3.fromRGB(55, 55, 60)
    for _, prompt in pairs(game:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = instantEActive and 0 or 1
        end
    end
end)