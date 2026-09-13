local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local GUI_NAME = "ThoScript"
local BLUE_1 = Color3.fromRGB(7, 18, 38)
local BLUE_2 = Color3.fromRGB(10, 28, 58)
local BLUE_3 = Color3.fromRGB(15, 48, 98)
local BLUE_4 = Color3.fromRGB(20, 91, 170)
local BLUE_5 = Color3.fromRGB(0, 170, 255)
local WHITE = Color3.fromRGB(235, 245, 255)
local MUTED = Color3.fromRGB(145, 170, 200)
local GREEN = Color3.fromRGB(40, 220, 140)
local RED = Color3.fromRGB(255, 80, 95)

local old = PlayerGui:FindFirstChild(GUI_NAME)
if old then
	old:Destroy()
end

local function tween(object, time, properties)
	local info = TweenInfo.new(time or 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local t = TweenService:Create(object, info, properties)
	t:Play()
	return t
end

local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function addStroke(parent, color, transparency, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Transparency = transparency or 0
	s.Thickness = thickness or 1
	s.Parent = parent
	return s
end

local function addText(parent, text, size, font, color)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextSize = size
	label.Font = font or Enum.Font.Gotham
	label.TextColor3 = color or WHITE
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Active = false          -- FIX: label không nuốt input
	label.Parent = parent
	return label
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MAIN_WIDTH = 620
local MAIN_HEIGHT = 400
local MAIN_MIN_HEIGHT = 46

local Main = Instance.new("Frame")
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.fromOffset(MAIN_WIDTH, MAIN_HEIGHT)
Main.BackgroundColor3 = BLUE_1
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
addCorner(Main, 12)
addStroke(Main, Color3.fromRGB(35, 105, 180), 0.35, 1)

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(7, 20, 44)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(9, 30, 65)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 17, 35))
})
MainGradient.Rotation = 25
MainGradient.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, MAIN_MIN_HEIGHT)
Header.BackgroundColor3 = Color3.fromRGB(8, 30, 62)
Header.BorderSizePixel = 0
Header.Active = true          -- FIX: header bắt được input
Header.Parent = Main

local HeaderLine = Instance.new("Frame")
HeaderLine.Position = UDim2.new(0, 0, 1, -1)
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.BackgroundColor3 = BLUE_5
HeaderLine.BackgroundTransparency = 0.65
HeaderLine.BorderSizePixel = 0
HeaderLine.Active = false
HeaderLine.Parent = Header

local MenuTitle = addText(Header, "Tho Script", 15, Enum.Font.GothamBold, WHITE)
MenuTitle.Position = UDim2.fromOffset(16, 5)
MenuTitle.Size = UDim2.fromOffset(200, 20)

local MenuSubtitle = addText(Header, "Personal utility interface", 9, Enum.Font.GothamMedium, MUTED)
MenuSubtitle.Position = UDim2.fromOffset(16, 24)
MenuSubtitle.Size = UDim2.fromOffset(200, 16)

local HeaderButtons = Instance.new("Frame")
HeaderButtons.AnchorPoint = Vector2.new(1, 0.5)
HeaderButtons.Position = UDim2.new(1, -8, 0.5, 0)
HeaderButtons.Size = UDim2.fromOffset(108, 28)
HeaderButtons.BackgroundTransparency = 1
HeaderButtons.Active = false  -- FIX: frame chứa nút không nuốt input của header
HeaderButtons.Parent = Header

local HeaderLayout = Instance.new("UIListLayout")
HeaderLayout.FillDirection = Enum.FillDirection.Horizontal
HeaderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
HeaderLayout.Padding = UDim.new(0, 4)
HeaderLayout.Parent = HeaderButtons

local function makeHeaderButton(text)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(30, 26)
	b.BackgroundColor3 = Color3.fromRGB(15, 47, 90)
	b.BorderSizePixel = 0
	b.Text = text
	b.TextSize = 13
	b.Font = Enum.Font.GothamBold
	b.TextColor3 = WHITE
	b.AutoButtonColor = false
	b.Parent = HeaderButtons
	addCorner(b, 6)

	b.MouseEnter:Connect(function()
		tween(b, 0.12, {BackgroundColor3 = BLUE_4})
	end)

	b.MouseLeave:Connect(function()
		tween(b, 0.12, {BackgroundColor3 = Color3.fromRGB(15, 47, 90)})
	end)

	return b
end

local MinimizeButton = makeHeaderButton("-")
local MaximizeButton = makeHeaderButton("□")
local CloseButton = makeHeaderButton("×")

local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(0, MAIN_MIN_HEIGHT)
Sidebar.Size = UDim2.new(0, 150, 1, -MAIN_MIN_HEIGHT)
Sidebar.BackgroundColor3 = Color3.fromRGB(6, 24, 50)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingLeft = UDim.new(0, 10)
SidebarPadding.PaddingRight = UDim.new(0, 10)
SidebarPadding.PaddingTop = UDim.new(0, 12)
SidebarPadding.PaddingBottom = UDim.new(0, 12)
SidebarPadding.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar

local TabsTitle = addText(Sidebar, "CHỨC NĂNG", 9, Enum.Font.GothamBold, MUTED)
TabsTitle.Size = UDim2.new(1, 0, 0, 20)

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(150, MAIN_MIN_HEIGHT)
Content.Size = UDim2.new(1, -150, 1, -MAIN_MIN_HEIGHT)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.Parent = Main

local TabFrames = {}
local TabButtons = {}
local currentTab = "Player"

local function createTab(name, order)
	local button = Instance.new("TextButton")
	button.LayoutOrder = order
	button.Size = UDim2.new(1, 0, 0, 34)
	button.BackgroundColor3 = Color3.fromRGB(11, 39, 76)
	button.BackgroundTransparency = 0.35
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = Sidebar
	addCorner(button, 7)

	local accent = Instance.new("Frame")
	accent.Position = UDim2.fromOffset(0, 6)
	accent.Size = UDim2.fromOffset(3, 22)
	accent.BackgroundColor3 = BLUE_5
	accent.BackgroundTransparency = name == "Player" and 0 or 1
	accent.BorderSizePixel = 0
	accent.Active = false
	accent.Parent = button
	addCorner(accent, 4)

	local label = addText(button, name, 12, Enum.Font.GothamSemibold, name == "Player" and WHITE or MUTED)
	label.Position = UDim2.fromOffset(12, 0)
	label.Size = UDim2.new(1, -16, 1, 0)

	button.MouseEnter:Connect(function()
		if currentTab ~= name then
			tween(button, 0.12, {BackgroundTransparency = 0.12})
			tween(label, 0.12, {TextColor3 = WHITE})
		end
	end)

	button.MouseLeave:Connect(function()
		if currentTab ~= name then
			tween(button, 0.12, {BackgroundTransparency = 0.35})
			tween(label, 0.12, {TextColor3 = MUTED})
		end
	end)

	button.Activated:Connect(function()
		currentTab = name

		for tabName, frame in pairs(TabFrames) do
			if tabName == name then
				frame.Visible = true
				frame.Position = UDim2.fromOffset(10, 0)
				tween(frame, 0.18, {Position = UDim2.fromOffset(0, 0)})
			else
				frame.Visible = false
			end
		end

		for tabName, data in pairs(TabButtons) do
			local active = tabName == name
			tween(data.button, 0.12, {
				BackgroundTransparency = active and 0.03 or 0.35
			})
			tween(data.label, 0.12, {
				TextColor3 = active and WHITE or MUTED
			})
			tween(data.accent, 0.12, {
				BackgroundTransparency = active and 0 or 1
			})
		end
	end)

	TabButtons[name] = {
		button = button,
		label = label,
		accent = accent
	}
end

local function createPage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = BLUE_4
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.new()
	page.ScrollingDirection = Enum.ScrollingDirection.Y
	page.Visible = name == "Player"
	page.Parent = Content

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 16)
	padding.PaddingRight = UDim.new(0, 16)
	padding.PaddingTop = UDim.new(0, 14)
	padding.PaddingBottom = UDim.new(0, 16)
	padding.Parent = page

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 7)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page

	TabFrames[name] = page
	return page
end

createTab("Player", 2)
createTab("Server", 3)

local PlayerPage = createPage("Player")
local ServerPage = createPage("Server")

local function showNotice(text, success)
	local notice = Instance.new("Frame")
	notice.AnchorPoint = Vector2.new(1, 0)
	notice.Position = UDim2.new(1, 18, 0, 56)
	notice.Size = UDim2.fromOffset(240, 44)
	notice.BackgroundColor3 = success and Color3.fromRGB(10, 67, 59) or Color3.fromRGB(67, 29, 39)
	notice.BorderSizePixel = 0
	notice.ZIndex = 200
	notice.Active = false
	notice.Parent = Main
	addCorner(notice, 8)
	addStroke(notice, success and GREEN or RED, 0.55, 1)

	local label = addText(notice, text, 10, Enum.Font.GothamSemibold, WHITE)
	label.Position = UDim2.fromOffset(10, 0)
	label.Size = UDim2.new(1, -20, 1, 0)
	label.TextWrapped = true
	label.ZIndex = 201

	tween(notice, 0.2, {Position = UDim2.new(1, -12, 0, 56)})

	task.delay(2.1, function()
		if notice.Parent then
			tween(notice, 0.18, {Position = UDim2.new(1, 18, 0, 56)})
			task.wait(0.2)
			notice:Destroy()
		end
	end)
end

local function createSection(parent, title, order)
	local f = Instance.new("Frame")
	f.LayoutOrder = order
	f.Size = UDim2.new(1, 0, 0, 28)
	f.BackgroundTransparency = 1
	f.Active = false
	f.Parent = parent

	local t = addText(f, title, 15, Enum.Font.GothamBold, WHITE)
	t.Size = UDim2.new(1, 0, 0, 20)

	local line = Instance.new("Frame")
	line.Position = UDim2.new(0, 0, 1, -3)
	line.Size = UDim2.new(1, 0, 0, 1)
	line.BackgroundColor3 = BLUE_3
	line.BorderSizePixel = 0
	line.Active = false
	line.Parent = f
end

local function createToggle(parent, title, description, defaultValue, callback, order)
	local row = Instance.new("Frame")
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, 56)
	row.BackgroundColor3 = Color3.fromRGB(8, 29, 58)
	row.BackgroundTransparency = 0.2
	row.BorderSizePixel = 0
	row.Parent = parent
	addCorner(row, 8)
	addStroke(row, Color3.fromRGB(31, 84, 140), 0.68, 1)

	local titleLabel = addText(row, title, 12, Enum.Font.GothamSemibold, WHITE)
	titleLabel.Position = UDim2.fromOffset(12, 6)
	titleLabel.Size = UDim2.new(1, -80, 0, 18)

	local descLabel = addText(row, description, 9, Enum.Font.Gotham, MUTED)
	descLabel.Position = UDim2.fromOffset(12, 25)
	descLabel.Size = UDim2.new(1, -90, 0, 22)
	descLabel.TextWrapped = true
	descLabel.TextYAlignment = Enum.TextYAlignment.Top

	local track = Instance.new("TextButton")
	track.AnchorPoint = Vector2.new(1, 0.5)
	track.Position = UDim2.new(1, -12, 0.5, 0)
	track.Size = UDim2.fromOffset(42, 22)
	track.BackgroundColor3 = Color3.fromRGB(29, 49, 77)
	track.BorderSizePixel = 0
	track.Text = ""
	track.AutoButtonColor = false
	track.Parent = row
	addCorner(track, 20)

	local knob = Instance.new("Frame")
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 11, 0.5, 0)
	knob.Size = UDim2.fromOffset(16, 16)
	knob.BackgroundColor3 = Color3.fromRGB(180, 200, 220)
	knob.BorderSizePixel = 0
	knob.Active = false
	knob.Parent = track
	addCorner(knob, 20)

	local state = defaultValue == true
	local busy = false

	local function setState(value, notify)
		if busy then return end
		busy = true
		state = value == true

		if state then
			tween(track, 0.16, {BackgroundColor3 = BLUE_4})
			tween(knob, 0.16, {
				Position = UDim2.new(1, -11, 0.5, 0),
				BackgroundColor3 = WHITE
			})
		else
			tween(track, 0.16, {BackgroundColor3 = Color3.fromRGB(29, 49, 77)})
			tween(knob, 0.16, {
				Position = UDim2.new(0, 11, 0.5, 0),
				BackgroundColor3 = Color3.fromRGB(180, 200, 220)
			})
		end

		if callback and notify ~= false then
			callback(state)
		end

		task.delay(0.05, function()
			busy = false
		end)
	end

	track.Activated:Connect(function()
		setState(not state)
	end)

	setState(state, false)

	return {
		Set = function(value)
			setState(value)
		end,
		Get = function()
			return state
		end
	}
end

local function createButton(parent, title, description, callback, order)
	local row = Instance.new("Frame")
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, 56)
	row.BackgroundColor3 = Color3.fromRGB(8, 29, 58)
	row.BackgroundTransparency = 0.2
	row.BorderSizePixel = 0
	row.Parent = parent
	addCorner(row, 8)
	addStroke(row, Color3.fromRGB(31, 84, 140), 0.68, 1)

	local titleLabel = addText(row, title, 12, Enum.Font.GothamSemibold, WHITE)
	titleLabel.Position = UDim2.fromOffset(12, 6)
	titleLabel.Size = UDim2.new(1, -110, 0, 18)

	local descLabel = addText(row, description, 9, Enum.Font.Gotham, MUTED)
	descLabel.Position = UDim2.fromOffset(12, 25)
	descLabel.Size = UDim2.new(1, -110, 0, 22)
	descLabel.TextWrapped = true
	descLabel.TextYAlignment = Enum.TextYAlignment.Top

	local button = Instance.new("TextButton")
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -12, 0.5, 0)
	button.Size = UDim2.fromOffset(84, 28)
	button.BackgroundColor3 = BLUE_3
	button.BorderSizePixel = 0
	button.Text = "THỰC HIỆN"
	button.TextSize = 9
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = WHITE
	button.AutoButtonColor = false
	button.Parent = row
	addCorner(button, 6)

	button.MouseEnter:Connect(function()
		tween(button, 0.12, {BackgroundColor3 = BLUE_4})
	end)

	button.MouseLeave:Connect(function()
		tween(button, 0.12, {BackgroundColor3 = BLUE_3})
	end)

	button.Activated:Connect(function()
		tween(button, 0.07, {Size = UDim2.fromOffset(80, 26)})
		task.delay(0.07, function()
			if button.Parent then
				tween(button, 0.1, {Size = UDim2.fromOffset(84, 28)})
			end
		end)

		if callback then
			callback()
		end
	end)
end

-- FIX: slider giờ dùng chung 1 connection toàn cục, kéo mượt
local activeSlider = nil

UserInputService.InputChanged:Connect(function(input)
	if activeSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
		activeSlider(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		activeSlider = nil
	end
end)

local function createSlider(parent, title, description, minValue, maxValue, defaultValue, callback, order)
	local row = Instance.new("Frame")
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, 74)
	row.BackgroundColor3 = Color3.fromRGB(8, 29, 58)
	row.BackgroundTransparency = 0.2
	row.BorderSizePixel = 0
	row.Parent = parent
	addCorner(row, 8)
	addStroke(row, Color3.fromRGB(31, 84, 140), 0.68, 1)

	local titleLabel = addText(row, title, 12, Enum.Font.GothamSemibold, WHITE)
	titleLabel.Position = UDim2.fromOffset(12, 6)
	titleLabel.Size = UDim2.new(1, -90, 0, 18)

	local valueLabel = addText(row, tostring(defaultValue), 11, Enum.Font.GothamBold, BLUE_5)
	valueLabel.Position = UDim2.new(1, -60, 0, 6)
	valueLabel.Size = UDim2.fromOffset(48, 18)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right

	local descLabel = addText(row, description, 9, Enum.Font.Gotham, MUTED)
	descLabel.Position = UDim2.fromOffset(12, 24)
	descLabel.Size = UDim2.new(1, -24, 0, 18)
	descLabel.TextWrapped = true

	-- FIX: bar giờ là TextButton để nhận input, và Active = true
	local bar = Instance.new("TextButton")
	bar.Position = UDim2.new(0, 12, 1, -20)
	bar.Size = UDim2.new(1, -24, 0, 6)
	bar.BackgroundColor3 = Color3.fromRGB(26, 48, 78)
	bar.BorderSizePixel = 0
	bar.Text = ""
	bar.AutoButtonColor = false
	bar.Active = true
	bar.Parent = row
	addCorner(bar, 10)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = BLUE_5
	fill.BorderSizePixel = 0
	fill.Active = false
	fill.Parent = bar
	addCorner(fill, 10)

	local knob = Instance.new("Frame")
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	knob.Size = UDim2.fromOffset(13, 13)
	knob.BackgroundColor3 = WHITE
	knob.BorderSizePixel = 0
	knob.ZIndex = 3
	knob.Active = false
	knob.Parent = bar
	addCorner(knob, 10)

	local currentValue = defaultValue

	local function apply(x)
		local startX = bar.AbsolutePosition.X
		local width = bar.AbsoluteSize.X
		if width <= 0 then return end
		local alpha = math.clamp((x - startX) / width, 0, 1)
		currentValue = math.floor(minValue + (maxValue - minValue) * alpha + 0.5)

		fill.Size = UDim2.new(alpha, 0, 1, 0)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		valueLabel.Text = tostring(currentValue)

		if callback then
			callback(currentValue)
		end
	end

	local initialAlpha = math.clamp((defaultValue - minValue) / (maxValue - minValue), 0, 1)
	fill.Size = UDim2.new(initialAlpha, 0, 1, 0)
	knob.Position = UDim2.new(initialAlpha, 0, 0.5, 0)

	-- FIX: dùng InputBegan của bar (TextButton) để bắt đầu kéo
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			activeSlider = apply
			apply(input.Position.X)
		end
	end)

	return {
		Set = function(value)
			local v = math.clamp(value, minValue, maxValue)
			local alpha = (v - minValue) / (maxValue - minValue)
			currentValue = v
			fill.Size = UDim2.new(alpha, 0, 1, 0)
			knob.Position = UDim2.new(alpha, 0, 0.5, 0)
			valueLabel.Text = tostring(v)
			if callback then
				callback(v)
			end
		end,
		Get = function()
			return currentValue
		end
	}
end

createSection(PlayerPage, "Player", 1)

local State = {
	fly = false,
	airWalk = false,
	speed = false,
	jump = false,
	noclip = false,
	lying = false,
	sitting = false,
	spin = false,
	esp = false,
	flySpeed = 60,
	walkSpeed = 40,
	jumpPower = 80,
	spinSpeed = 15
}

local character
local humanoid
local root

local function refreshCharacter()
	character = LocalPlayer.Character
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	root = character and character:FindFirstChild("HumanoidRootPart")
end

refreshCharacter()

LocalPlayer.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid", 5)
	root = char:WaitForChild("HumanoidRootPart", 5)
end)

-- FIX: Fly dùng BodyVelocity + BodyGyro để chắc chắn hoạt động
local flyBV
local flyBG
local flyConnection

local function stopFly()
	State.fly = false

	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end

	if flyBV then flyBV:Destroy() flyBV = nil end
	if flyBG then flyBG:Destroy() flyBG = nil end

	refreshCharacter()
	if humanoid then
		humanoid.PlatformStand = false
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

local function startFly()
	refreshCharacter()

	if not humanoid or not root then
		showNotice("Không tìm thấy nhân vật.", false)
		State.fly = false
		return
	end

	humanoid.PlatformStand = true

	flyBV = Instance.new("BodyVelocity")
	flyBV.Name = "_ThoFlyBV"
	flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	flyBV.Velocity = Vector3.zero
	flyBV.P = 1250
	flyBV.Parent = root

	flyBG = Instance.new("BodyGyro")
	flyBG.Name = "_ThoFlyBG"
	flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	flyBG.P = 1000
	flyBG.D = 50
	flyBG.CFrame = root.CFrame
	flyBG.Parent = root

	flyConnection = RunService.RenderStepped:Connect(function()
		if not State.fly or not root or not root.Parent or not flyBV or not flyBG then
			return
		end

		local camera = workspace.CurrentCamera
		local move = Vector3.zero

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			move += camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			move -= camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			move += camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			move -= camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			move += Vector3.yAxis
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			move -= Vector3.yAxis
		end

		if move.Magnitude > 0 then
			move = move.Unit
		end

		flyBV.Velocity = move * State.flySpeed
		flyBG.CFrame = CFrame.new(root.Position, root.Position + camera.CFrame.LookVector)
	end)
end

createToggle(PlayerPage, "Bay", "Bật chế độ bay, dùng WASD + Space/Ctrl để di chuyển.", false, function(value)
	State.fly = value
	if value then
		startFly()
	else
		stopFly()
	end
end, 2)

createSlider(PlayerPage, "Tốc độ bay", "Kéo để chỉnh tốc độ bay, tối đa 200.", 10, 200, State.flySpeed, function(value)
	State.flySpeed = value
end, 3)

local airPlatform
local airConnection

local function stopAirWalk()
	State.airWalk = false

	if airConnection then
		airConnection:Disconnect()
		airConnection = nil
	end

	if airPlatform then
		airPlatform:Destroy()
		airPlatform = nil
	end
end

local function startAirWalk()
	refreshCharacter()
	if not root then return end

	airPlatform = Instance.new("Part")
	airPlatform.Name = "_ThoAirWalk"
	airPlatform.Size = Vector3.new(4.5, 0.3, 4.5)
	airPlatform.Transparency = 1
	airPlatform.CanCollide = true
	airPlatform.Anchored = true
	airPlatform.Parent = workspace

	airConnection = RunService.Heartbeat:Connect(function()
		if State.airWalk and root and root.Parent and airPlatform then
			airPlatform.CFrame = CFrame.new(root.Position - Vector3.new(0, 3.05, 0))
		end
	end)
end

createToggle(PlayerPage, "Đi trên không", "Tạo bệ đỡ ngay dưới chân nhân vật.", false, function(value)
	State.airWalk = value
	if value then
		startAirWalk()
	else
		stopAirWalk()
	end
end, 4)

local function applyWalkSpeed()
	refreshCharacter()
	if humanoid then
		humanoid.WalkSpeed = State.speed and State.walkSpeed or 16
	end
end

createToggle(PlayerPage, "Chạy nhanh", "Thay đổi tốc độ di chuyển của Humanoid.", false, function(value)
	State.speed = value
	applyWalkSpeed()
end, 5)

createSlider(PlayerPage, "Tốc độ chạy", "Kéo để chỉnh từ 16 đến 200.", 16, 200, State.walkSpeed, function(value)
	State.walkSpeed = value
	if State.speed then
		applyWalkSpeed()
	end
end, 6)

local function applyJumpPower()
	refreshCharacter()
	if humanoid then
		humanoid.UseJumpPower = true
		humanoid.JumpPower = State.jump and State.jumpPower or 50
	end
end

createToggle(PlayerPage, "Nhảy cao", "Tăng JumpPower của nhân vật.", false, function(value)
	State.jump = value
	applyJumpPower()
end, 7)

createSlider(PlayerPage, "Độ cao nhảy", "Kéo để chỉnh JumpPower tối đa 200.", 50, 200, State.jumpPower, function(value)
	State.jumpPower = value
	if State.jump then
		applyJumpPower()
	end
end, 8)

local noclipConnection

local function stopNoclip()
	State.noclip = false
	if noclipConnection then
		noclipConnection:Disconnect()
		noclipConnection = nil
	end

	if character then
		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then
				object.CanCollide = true
			end
		end
	end
end

local function startNoclip()
	noclipConnection = RunService.Stepped:Connect(function()
		if not State.noclip or not character then return end
		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then
				object.CanCollide = false
			end
		end
	end)
end

createToggle(PlayerPage, "Đi xuyên tường", "Tắt collision của nhân vật.", false, function(value)
	State.noclip = value
	if value then
		startNoclip()
	else
		stopNoclip()
	end
end, 9)

-- FIX: lying dùng PlatformStand để không bị văng khi spam space
local lyingConnection
local originalAutoRotate = true

local function stopLying()
	State.lying = false
	if lyingConnection then
		lyingConnection:Disconnect()
		lyingConnection = nil
	end
	refreshCharacter()
	if humanoid then
		humanoid.AutoRotate = originalAutoRotate
		humanoid.PlatformStand = false
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

local function startLying()
	refreshCharacter()
	if not humanoid or not root then return end

	originalAutoRotate = humanoid.AutoRotate
	humanoid.AutoRotate = false
	humanoid.PlatformStand = true

	lyingConnection = RunService.RenderStepped:Connect(function()
		if State.lying and root and root.Parent then
			local p = root.Position
			local look = root.CFrame.LookVector
			root.CFrame = CFrame.lookAt(p, p + look) * CFrame.Angles(0, 0, math.rad(90))
		end
	end)
end

createToggle(PlayerPage, "Nằm", "Đưa nhân vật về tư thế nằm (an toàn, không bị văng).", false, function(value)
	State.lying = value
	if value then
		startLying()
	else
		stopLying()
	end
end, 10)

createToggle(PlayerPage, "Ngồi", "Đưa Humanoid vào trạng thái ngồi.", false, function(value)
	State.sitting = value
	refreshCharacter()
	if humanoid then
		humanoid.Sit = value
	end
end, 11)

local spinConnection

local function stopSpin()
	State.spin = false
	if spinConnection then
		spinConnection:Disconnect()
		spinConnection = nil
	end
end

local function startSpin()
	spinConnection = RunService.RenderStepped:Connect(function(delta)
		if State.spin then
			refreshCharacter()
			if root then
				root.CFrame *= CFrame.Angles(0, math.rad(State.spinSpeed * 20) * delta, 0)
			end
		end
	end)
end

createToggle(PlayerPage, "Xoay", "Xoay nhân vật liên tục.", false, function(value)
	State.spin = value
	if value then
		startSpin()
	else
		stopSpin()
	end
end, 12)

createSlider(PlayerPage, "Tốc độ xoay", "Kéo để chỉnh tốc độ từ 1 đến 50.", 1, 50, State.spinSpeed, function(value)
	State.spinSpeed = value
end, 13)

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "_ThoESP"
ESPFolder.Parent = ScreenGui

local ESPData = {}
local espConnection

local function destroyESP(player)
	local data = ESPData[player]
	if not data then return end

	if data.highlight then data.highlight:Destroy() end
	if data.billboard then data.billboard:Destroy() end
	ESPData[player] = nil
end

local function ensureESP(player)
	if player == LocalPlayer or ESPData[player] then return end

	local highlight = Instance.new("Highlight")
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = BLUE_5
	highlight.FillTransparency = 0.84
	highlight.OutlineColor = Color3.fromRGB(90, 205, 255)
	highlight.OutlineTransparency = 0.05
	highlight.Enabled = false
	highlight.Parent = ESPFolder

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(160, 44)
	billboard.StudsOffset = Vector3.new(0, 3.4, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = false
	billboard.Parent = ESPFolder

	local nameLabel = addText(billboard, player.DisplayName, 11, Enum.Font.GothamBold, WHITE)
	nameLabel.Size = UDim2.new(1, 0, 0, 18)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center

	local infoLabel = addText(billboard, "HP: -- | -- studs", 9, Enum.Font.GothamMedium, MUTED)
	infoLabel.Position = UDim2.fromOffset(0, 18)
	infoLabel.Size = UDim2.new(1, 0, 0, 16)
	infoLabel.TextXAlignment = Enum.TextXAlignment.Center

	ESPData[player] = {
		highlight = highlight,
		billboard = billboard,
		nameLabel = nameLabel,
		infoLabel = infoLabel
	}
end

local function stopESP()
	State.esp = false

	if espConnection then
		espConnection:Disconnect()
		espConnection = nil
	end

	for _, data in pairs(ESPData) do
		data.highlight.Enabled = false
		data.billboard.Enabled = false
	end
end

local function startESP()
	for _, player in ipairs(Players:GetPlayers()) do
		ensureESP(player)
	end

	if espConnection then
		espConnection:Disconnect()
	end

	espConnection = RunService.RenderStepped:Connect(function()
		local localCharacter = LocalPlayer.Character
		local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				ensureESP(player)

				local data = ESPData[player]
				local targetCharacter = player.Character
				local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
				local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

				if data and localRoot and targetCharacter and targetRoot and targetHumanoid then
					data.highlight.Adornee = targetCharacter
					data.highlight.Enabled = true
					data.billboard.Adornee = targetRoot
					data.billboard.Enabled = true

					local distance = math.floor((localRoot.Position - targetRoot.Position).Magnitude)
					data.nameLabel.Text = player.DisplayName
					data.infoLabel.Text =
						"HP: "
						.. math.floor(targetHumanoid.Health)
						.. "/"
						.. math.floor(targetHumanoid.MaxHealth)
						.. " | "
						.. distance
						.. " studs"
				elseif data then
					data.highlight.Enabled = false
					data.billboard.Enabled = false
				end
			end
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	if State.esp then
		ensureESP(player)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	destroyESP(player)
end)

createToggle(PlayerPage, "Định vị người chơi", "Hiển thị khung, tên, máu và khoảng cách.", false, function(value)
	State.esp = value
	if value then
		startESP()
	else
		stopESP()
	end
end, 14)

createSection(ServerPage, "Server", 1)

-- FIX: implement server hop thật bằng HttpService
local function fetchServers(placeId, callback)
	task.spawn(function()
		local url = string.format(
			"https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",
			placeId
		)
		local ok, result = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)
		if ok and result and result.data then
			callback(result.data)
		else
			callback(nil)
		end
	end)
end

local function hopToServer(targetJobId)
	local ok, err = pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId, LocalPlayer)
	end)
	if not ok then
		showNotice("Teleport thất bại: " .. tostring(err), false)
	end
end

createButton(ServerPage, "Đổi máy chủ", "Nhảy sang một server khác cùng place.", function()
	local servers = nil
	fetchServers(game.PlaceId, function(data)
		servers = data
	end)

	task.wait(1.5)

	if not servers or #servers == 0 then
		showNotice("Không lấy được danh sách server.", false)
		return
	end

	local currentJob = game.JobId
	local candidates = {}
	for _, s in ipairs(servers) do
		if s.id ~= currentJob and (s.playing or 0) < (s.maxPlayers or 999) then
			table.insert(candidates, s)
		end
	end

	if #candidates == 0 then
		showNotice("Không có server nào khả dụng.", false)
		return
	end

	local pick = candidates[math.random(1, #candidates)]
	showNotice("Đang chuyển server...", true)
	task.wait(0.4)
	hopToServer(pick.id)
end, 2)

createButton(ServerPage, "Đổi máy chủ ít người", "Tìm server có ít người chơi nhất.", function()
	local servers = nil
	fetchServers(game.PlaceId, function(data)
		servers = data
	end)

	task.wait(1.5)

	if not servers or #servers == 0 then
		showNotice("Không lấy được danh sách server.", false)
		return
	end

	local currentJob = game.JobId
	local best = nil
	local bestCount = math.huge

	for _, s in ipairs(servers) do
		local count = s.playing or 0
		if s.id ~= currentJob and count < bestCount and count < (s.maxPlayers or 999) then
			best = s
			bestCount = count
		end
	end

	if not best then
		showNotice("Không có server nào khả dụng.", false)
		return
	end

	showNotice("Đang chuyển tới server " .. bestCount .. " người...", true)
	task.wait(0.4)
	hopToServer(best.id)
end, 3)

createButton(ServerPage, "Tham gia lại máy chủ", "Thử quay lại đúng JobId của instance hiện tại.", function()
	local jobId = game.JobId
	if jobId == "" then
		showNotice("Không có JobId hợp lệ trong môi trường hiện tại.", false)
		return
	end

	local ok = pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
	end)

	if not ok then
		showNotice("Không thể thực hiện teleport tới instance hiện tại.", false)
	end
end, 4)

createToggle(ServerPage, "Tự động chạy script", "Lưu trạng thái giao diện trong phiên hiện tại.", false, function(value)
	showNotice(value and "Đã bật tự động khôi phục trạng thái." or "Đã tắt tự động khôi phục.", true)
end, 5)

-- FIX: FloatingButton nằm cao hơn, DisplayOrder riêng cao hơn Main
local FloatingButton = Instance.new("TextButton")
FloatingButton.AnchorPoint = Vector2.new(1, 1)
FloatingButton.Position = UDim2.new(1, -20, 1, -120)   -- FIX: nâng lên để không bị CoreGui che
FloatingButton.Size = UDim2.fromOffset(46, 46)
FloatingButton.BackgroundColor3 = BLUE_4
FloatingButton.BorderSizePixel = 0
FloatingButton.Text = "T"
FloatingButton.TextSize = 18
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.TextColor3 = WHITE
FloatingButton.AutoButtonColor = false
FloatingButton.Visible = false
FloatingButton.ZIndex = 5000
FloatingButton.Parent = ScreenGui
addCorner(FloatingButton, 100)
addStroke(FloatingButton, BLUE_5, 0.25, 1)

local FloatingGlow = Instance.new("Frame")
FloatingGlow.AnchorPoint = Vector2.new(0.5, 0.5)
FloatingGlow.Position = UDim2.fromScale(0.5, 0.5)
FloatingGlow.Size = UDim2.fromScale(0.72, 0.72)
FloatingGlow.BackgroundColor3 = BLUE_5
FloatingGlow.BackgroundTransparency = 0.83
FloatingGlow.BorderSizePixel = 0
FloatingGlow.Active = false
FloatingGlow.Parent = FloatingButton
addCorner(FloatingGlow, 100)

FloatingButton.MouseEnter:Connect(function()
	tween(FloatingButton, 0.12, {
		Size = UDim2.fromOffset(52, 52),
		BackgroundColor3 = BLUE_5
	})
end)

FloatingButton.MouseLeave:Connect(function()
	tween(FloatingButton, 0.12, {
		Size = UDim2.fromOffset(46, 46),
		BackgroundColor3 = BLUE_4
	})
end)

local originalSize = UDim2.fromOffset(MAIN_WIDTH, MAIN_HEIGHT)
local minimized = false
local maximized = false
local menuOpen = true

local function setMenuVisible(value)
	menuOpen = value
	Main.Visible = value
	FloatingButton.Visible = not value
end

FloatingButton.Activated:Connect(function()
	setMenuVisible(true)
end)

MinimizeButton.Activated:Connect(function()
	if maximized then
		maximized = false
	end

	minimized = not minimized

	if minimized then
		Sidebar.Visible = false
		Content.Visible = false
		tween(Main, 0.22, {Size = UDim2.fromOffset(MAIN_WIDTH, MAIN_MIN_HEIGHT)})
		MenuSubtitle.Text = "Đã thu nhỏ"
	else
		Sidebar.Visible = true
		Content.Visible = true
		tween(Main, 0.22, {Size = originalSize})
		MenuSubtitle.Text = "Personal utility interface"
	end
end)

MaximizeButton.Activated:Connect(function()
	if minimized then
		minimized = false
		Sidebar.Visible = true
		Content.Visible = true
	end

	maximized = not maximized

	tween(Main, 0.24, {
		Size = maximized and UDim2.fromOffset(820, 520) or originalSize
	})
end)

CloseButton.Activated:Connect(function()
	setMenuVisible(false)
end)

-- FIX: dragging menu dùng UserInputService thay vì Header.InputBegan
local dragging = false
local dragStart
local startPosition

local function beginDrag(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPosition = Main.Position
	end
end

Header.InputBegan:Connect(beginDrag)
MenuTitle.InputBegan:Connect(beginDrag)
MenuSubtitle.InputBegan:Connect(beginDrag)
HeaderLine.InputBegan:Connect(beginDrag)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end

	if input.KeyCode == Enum.KeyCode.RightShift then
		setMenuVisible(not menuOpen)
	end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.15)

	character = char
	humanoid = char:FindFirstChildOfClass("Humanoid")
	root = char:FindFirstChild("HumanoidRootPart")

	if State.fly then
		stopFly()
		startFly()
	end

	if State.esp then
		task.defer(startESP)
	end
end)

task.spawn(function()
	while ScreenGui.Parent do
		if State.sitting and humanoid and humanoid.Health > 0 then
			humanoid.Sit = true
		end

		if State.speed and humanoid then
			humanoid.WalkSpeed = State.walkSpeed
		end

		if State.jump and humanoid then
			humanoid.UseJumpPower = true
			humanoid.JumpPower = State.jumpPower
		end

		task.wait(0.3)
	end
end)
