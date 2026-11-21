local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. عرض رسالة التشغيل أسفل الشاشة لمدة 3 ثوانٍ
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NotificationGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local messageLabel = Instance.new("TextLabel")
messageLabel.Size = UDim2.new(0, 280, 0, 45)
messageLabel.Position = UDim2.new(0.5, -140, 0.85, 0)
messageLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
messageLabel.BackgroundTransparency = 0.25
messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
messageLabel.TextSize = 20
messageLabel.Font = Enum.Font.SourceSansBold
messageLabel.Text = "تم تشغيل السكربت"
messageLabel.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = messageLabel

task.delay(3, function()
	if screenGui then
		screenGui:Destroy()
	end
end)

-- دالة للتحقق مما إذا كان العنصر في الشريط السفلي (حتى لا يتم تلوينه بالأسود)
local function isBottomFooter(uiElement)
	if not uiElement:IsDescendantOf(playerGui) then return false end
	
	-- التحقق من أن ارتفاع العنصر صغير جداً (مثل شريط المعلومات السفلي الرفيع) ومكانه في آخر الشاشة
	local cam = workspace.CurrentCamera
	local screenHeight = cam and cam.ViewportSize.Y or 0
	if screenHeight > 0 then
		if uiElement.AbsolutePosition.Y >= (screenHeight - 35) and uiElement.AbsoluteSize.Y <= 35 then
			return true
		end
	end
	return false
end

-- 2. دالة شاملة لتغطية الاسم فقط (دون لمس الشريط السفلي أو أزرار الريدي)
local function applyBlackMask(uiElement)
	if uiElement:IsA("TextLabel") or uiElement:IsA("TextButton") or uiElement:IsA("TextBox") then
		if uiElement == messageLabel then return end

		local function updateMask()
			-- إذا كان العنصر هو الشريط السفلي الرفيع، لا تضع عليه لوناً أسود واتركه يظهر طبيعياً
			if isBottomFooter(uiElement) then return end

			local text = uiElement.Text
			if text == "" then return end
			
			-- البحث عن الاسم فقط (تم إزالة البحث عن رقم السيرفر حتى لا يتلون الشريط السفلي)
			local hasName = string.find(text, player.Name, 1, true) or string.find(text, player.DisplayName, 1, true)
			
			if hasName then
				uiElement.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				uiElement.BackgroundTransparency = 0
				uiElement.TextColor3 = Color3.fromRGB(0, 0, 0)
				uiElement.TextStrokeTransparency = 1
			end
		end
		
		updateMask()
		uiElement:GetPropertyChangedSignal("Text"):Connect(updateMask)
	end
end

-- فحص جميع العناصر في PlayerGui و Workspace
for _, element in ipairs(playerGui:GetDescendants()) do
	applyBlackMask(element)
end
for _, element in ipairs(workspace:GetDescendants()) do
	applyBlackMask(element)
end

-- مراقبة أي لوحات أو نصوص جديدة تظهر لاحقاً
playerGui.DescendantAdded:Connect(applyBlackMask)
workspace.DescendantAdded:Connect(applyBlackMask)
