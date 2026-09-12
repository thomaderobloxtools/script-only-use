local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local DEV_ACCESS =
	RunService:IsStudio()
	or (
		game.CreatorType == Enum.CreatorType.User
		and game.CreatorId == LocalPlayer.UserId
	)

local GUI_NAME = "ThoScript"

local BLUE_1 = Color3.fromRGB(7, 18, 38)
local BLUE_2 = Color3.fromRGB(10, 28, 58)
local BLUE_3 = Color3.fromRGB(15, 48, 98)
local BLUE_4 = Color3.fromRGB(20, 91, 170)
local BLUE_5 = Color3.fromRGB(0, 170, 255)
local WHITE = Color3.fromRGB(235, 245, 255)
local MUTED = Color3.fromRGB(145, 170, 200)
local RED = Color3.fromRGB(255, 80, 95)
local GREEN = Color3.fromRGB(40, 220, 140)

local function tween(instance, time, properties, style, direction)
	local animation = TweenService:Create(
		instance,
		TweenInfo.new(
			time or 0.2,
			style or Enum.EasingStyle.Quart,
			direction or Enum.EasingDirection.Out
		),
		properties
	)
	animation:Play()
	return animation
end

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
	return c
end

local function stroke(parent, color, transparency, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Transparency = transparency or 0
	s.Thickness = thickness or 1
	s.Parent = parent
	return s
end

local function padding(parent, left, right, top, bottom)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, left or 0)
	p.PaddingRight = UDim.new(0, right or 0)
	p.PaddingTop = UDim.new(0, top or 0)
	p.PaddingBottom = UDim.new(0, bottom or 0)
	p.Parent = parent
	return p
end

local function makeText(parent, text, size, font, color)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextSize = size or 14
	label.Font = font or Enum.Font.Gotham
	label.TextColor3 = color or WHITE
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local old = LocalPlayer:FindFirstChildOfClass("PlayerGui"):FindFirstChild(GUI_NAME)
if old then
	old:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Loading = Instance.new("Frame")
Loading.Size = UDim2.fromScale(1, 1)
Loading.BackgroundColor3 = BLUE_1
Loading.BorderSizePixel = 0
Loading.Parent = ScreenGui

local LoadingGradient = Instance.new("UIGradient")
LoadingGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, BLUE_1),
	ColorSequenceKeypoint.new(0.5, BLUE_3),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 8, 20))
})
LoadingGradient.Rotation = 35
LoadingGradient.Parent = Loading

local Glow = Instance.new("Frame")
Glow.AnchorPoint = Vector2.new(0.5, 0.5)
Glow.Position = UDim2.fromScale(0.5, 0.46)
Glow.Size = UDim2.fromOffset(190, 190)
Glow.BackgroundColor3 = BLUE_5
Glow.BackgroundTransparency = 0.9
Glow.Parent = Loading
corner(Glow, 100)

local Title = makeText(Loading, "Tho Script", 31, Enum.Font.GothamBold, WHITE)
Title.AnchorPoint = Vector2.new(0.5, 0.5)
Title.Position = UDim2.fromScale(0.5, 0.45)
Title.Size = UDim2.fromOffset(300, 50)
Title.TextXAlignment = Enum.TextXAlignment.Center

local Subtitle = makeText(Loading, "Đang khởi tạo giao diện...", 14, Enum.Font.GothamMedium, MUTED)
Subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
Subtitle.Position = UDim2.fromScale(0.5, 0.51)
Subtitle.Size = UDim2.fromOffset(400, 30)
Subtitle.TextXAlignment = Enum.TextXAlignment.Center

local ProgressBackground = Instance.new("Frame")
ProgressBackground.AnchorPoint = Vector2.new(0.5, 0)
ProgressBackground.Position = UDim2.fromScale(0.5, 0.57)
ProgressBackground.Size = UDim2.fromOffset(320, 7)
ProgressBackground.BackgroundColor3 = Color3.fromRGB(30, 50, 80)
ProgressBackground.BorderSizePixel = 0
ProgressBackground.Parent = Loading
corner(ProgressBackground, 10)

local Progress = Instance.new("Frame")
Progress.Size = UDim2.new(0, 0, 1, 0)
Progress.BackgroundColor3 = BLUE_5
Progress.BorderSizePixel = 0
Progress.Parent = ProgressBackground
corner(Progress, 10)

local Percentage = makeText(Loading, "0%", 13, Enum.Font.GothamBold, WHITE)
Percentage.AnchorPoint = Vector2.new(0.5, 0)
Percentage.Position = UDim2.fromScale(0.5, 0.595)
Percentage.Size = UDim2.fromOffset(100, 25)
Percentage.TextXAlignment = Enum.TextXAlignment.Center

task.spawn(function()
	for i = 0, 100 do
		Progress.Size = UDim2.new(i / 100, 0, 1, 0)
		Percentage.Text = i .. "%"
		if i < 30 then
			Subtitle.Text = "Đang khởi tạo giao diện..."
		elseif i < 60 then
			Subtitle.Text = "Đang tải hệ thống..."
		elseif i < 90 then
			Subtitle.Text = "Đang hoàn thiện..."
		else
			Subtitle.Text = "Sẵn sàng"
		end
		task.wait(0.012)
	end

	task.wait(0.35)

	tween(Loading, 0.35, {
		BackgroundTransparency = 1
	})

	for _, object in ipairs(Loading:GetDescendants()) do
		if object:IsA("TextLabel") then
			tween(object, 0.25, {TextTransparency = 1})
		elseif object:IsA("Frame") then
			tween(object, 0.25, {BackgroundTransparency = 1})
		end
	end

	task.wait(0.4)
	Loading:Destroy()
end)

local Main = Instance.new("Frame")
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.fromOffset(850, 540)
Main.BackgroundColor3 = BLUE_1
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
corner(Main, 13)
stroke(Main, Color3.fromRGB(35, 105, 180), 0.35, 1)

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(7, 20, 44)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(9, 30, 65)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 17, 35))
})
MainGradient.Rotation = 25
MainGradient.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 58)
Header.BackgroundColor3 = Color3.fromRGB(8, 30, 62)
Header.BackgroundTransparency = 0.08
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderLine = Instance.new("Frame")
HeaderLine.AnchorPoint = Vector2.new(0, 1)
HeaderLine.Position = UDim2.fromScale(0, 1)
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.BackgroundColor3 = BLUE_5
HeaderLine.BackgroundTransparency = 0.65
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local MenuTitle = makeText(Header, "Tho Script", 19, Enum.Font.GothamBold, WHITE)
MenuTitle.Position = UDim2.fromOffset(20, 0)
MenuTitle.Size = UDim2.fromOffset(250, 58)

local MenuSubtitle = makeText(Header, "Personal utility interface", 11, Enum.Font.GothamMedium, MUTED)
MenuSubtitle.Position = UDim2.fromOffset(20, 31)
MenuSubtitle.Size = UDim2.fromOffset(250, 20)

local HeaderButtons = Instance.new("Frame")
HeaderButtons.AnchorPoint = Vector2.new(1, 0.5)
HeaderButtons.Position = UDim2.new(1, -10, 0.5, 0)
HeaderButtons.Size = UDim2.fromOffset(126, 34)
HeaderButtons.BackgroundTransparency = 1
HeaderButtons.Parent = Header

local HeaderLayout = Instance.new("UIListLayout")
HeaderLayout.FillDirection = Enum.FillDirection.Horizontal
HeaderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
HeaderLayout.Padding = UDim.new(0, 5)
HeaderLayout.Parent = HeaderButtons

local function makeHeaderButton(text)
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(36, 30)
	button.BackgroundColor3 = Color3.fromRGB(15, 47, 90)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextSize = 14
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = WHITE
	button.AutoButtonColor = false
	button.Parent = HeaderButtons
	corner(button, 7)

	button.MouseEnter:Connect(function()
		tween(button, 0.15, {
			BackgroundColor3 = BLUE_4
		})
	end)

	button.MouseLeave:Connect(function()
		tween(button, 0.15, {
			BackgroundColor3 = Color3.fromRGB(15, 47, 90)
		})
	end)

	return button
end

local MinimizeButton = makeHeaderButton("-")
local MaximizeButton = makeHeaderButton("□")
local CloseButton = makeHeaderButton("×")

local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(0, 58)
Sidebar.Size = UDim2.new(0, 190, 1, -58)
Sidebar.BackgroundColor3 = Color3.fromRGB(6, 24, 50)
Sidebar.BackgroundTransparency = 0.1
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarPadding = padding(Sidebar, 12, 12, 16, 15)

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 8)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar

local TabsTitle = makeText(Sidebar, "CHỨC NĂNG", 10, Enum.Font.GothamBold, MUTED)
TabsTitle.Size = UDim2.new(1, 0, 0, 25)

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(190, 58)
Content.Size = UDim2.new(1, -190, 1, -58)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.Parent = Main

local TabFrames = {}
local TabButtons = {}

local currentTab = "Player"

local function createTabButton(name, order)
	local button = Instance.new("TextButton")
	button.LayoutOrder = order
	button.Size = UDim2.new(1, 0, 0, 43)
	button.BackgroundColor3 = Color3.fromRGB(11, 39, 76)
	button.BackgroundTransparency = 0.35
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = Sidebar
	corner(button, 8)

	local Accent = Instance.new("Frame")
	Accent.Position = UDim2.fromOffset(0, 8)
	Accent.Size = UDim2.fromOffset(3, 27)
	Accent.BackgroundColor3 = BLUE_5
	Accent.BackgroundTransparency = 1
	Accent.BorderSizePixel = 0
	Accent.Parent = button
	corner(Accent, 5)

	local Label = makeText(button, name, 13, Enum.Font.GothamSemibold, MUTED)
	Label.Position = UDim2.fromOffset(15, 0)
	Label.Size = UDim2.new(1, -20, 1, 0)

	button.MouseEnter:Connect(function()
		if currentTab ~= name then
			tween(button, 0.15, {
				BackgroundTransparency = 0.12
			})
			tween(Label, 0.15, {
				TextColor3 = WHITE
			})
		end
	end)

	button.MouseLeave:Connect(function()
		if currentTab ~= name then
			tween(button, 0.15, {
				BackgroundTransparency = 0.35
			})
			tween(Label, 0.15, {
				TextColor3 = MUTED
			})
		end
	end)

	button.Activated:Connect(function()
		local previous = currentTab
		currentTab = name

		for tabName, frame in pairs(TabFrames) do
			if tabName == name then
				frame.Visible = true
				frame.Position = UDim2.fromOffset(20, 20)
				tween(frame, 0.22, {
					Position = UDim2.fromOffset(0, 20)
				})
			else
				frame.Visible = false
			end
		end

		for tabName, data in pairs(TabButtons) do
			if tabName == name then
				tween(data.button, 0.15, {
					BackgroundTransparency = 0.03
				})
				tween(data.label, 0.15, {
					TextColor3 = WHITE
				})
				tween(data.accent, 0.15, {
					BackgroundTransparency = 0
				})
			else
				tween(data.button, 0.15, {
					BackgroundTransparency = 0.35
				})
				tween(data.label, 0.15, {
					TextColor3 = MUTED
				})
				tween(data.accent, 0.15, {
					BackgroundTransparency = 1
				})
			end
		end
	end)

	TabButtons[name] = {
		button = button,
		label = Label,
		accent = Accent
	}

	return button
end

createTabButton("Player", 2)
createTabButton("Server", 3)

local function createPage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.Position = UDim2.fromOffset(0, 20)
	page.Size = UDim2.new(1, 0, 1, -20)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = BLUE_4
	page.CanvasSize = UDim2.new()
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.ScrollingDirection = Enum.ScrollingDirection.Y
	page.Visible = name == "Player"
	page.Parent = Content

	padding(page, 20, 20, 0, 20)

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page

	TabFrames[name] = page

	return page
end

local PlayerPage = createPage("Player")
local ServerPage = createPage("Server")

local function showNotice(text, success)
	local notice = Instance.new("Frame")
	notice.AnchorPoint = Vector2.new(1, 0)
	notice.Position = UDim2.new(1, -18, 0, 72)
	notice.Size = UDim2.fromOffset(290, 50)
	notice.BackgroundColor3 = success and Color3.fromRGB(10, 67, 59) or Color3.fromRGB(67, 29, 39)
	notice.BorderSizePixel = 0
	notice.ZIndex = 100
	notice.Parent = Main
	corner(notice, 9)
	stroke(notice, success and GREEN or RED, 0.55, 1)

	local label = makeText(notice, text, 12, Enum.Font.GothamSemibold, WHITE)
	label.Position = UDim2.fromOffset(14, 0)
	label.Size = UDim2.new(1, -28, 1, 0)
	label.TextWrapped = true
	label.ZIndex = 101

	notice.Position = UDim2.new(1, 20, 0, 72)
	tween(notice, 0.22, {
		Position = UDim2.new(1, -18, 0, 72)
	})

	task.delay(2.3, function()
		if notice.Parent then
			tween(notice, 0.2, {
				Position = UDim2.new(1, 20, 0, 72)
			})
			task.wait(0.25)
			notice:Destroy()
		end
	end)
end

local function createSectionTitle(parent, text, order)
	local holder = Instance.new("Frame")
	holder.LayoutOrder = order
	holder.Size = UDim2.new(1, 0, 0, 40)
	holder.BackgroundTransparency = 1
	holder.Parent = parent

	local title = makeText(holder, text, 18, Enum.Font.GothamBold, WHITE)
	title.Position = UDim2.fromOffset(2, 0)
	title.Size = UDim2.new(1, 0, 0, 25)

	local line = Instance.new("Frame")
	line.Position = UDim2.fromOffset(2, 31)
	line.Size = UDim2.new(1, -4, 0, 1)
	line.BackgroundColor3 = BLUE_3
	line.BorderSizePixel = 0
	line.Parent = holder

	return holder
end

local function createToggle(parent, titleText, descriptionText, defaultValue, callback, order)
	local holder = Instance.new("Frame")
	holder.LayoutOrder = order
	holder.Size = UDim2.new(1, 0, 0, 72)
	holder.BackgroundColor3 = Color3.fromRGB(8, 29, 58)
	holder.BackgroundTransparency = 0.22
	holder.BorderSizePixel = 0
	holder.Parent = parent
	corner(holder, 9)
	stroke(holder, Color3.fromRGB(31, 84, 140), 0.65, 1)

	local title = makeText(holder, titleText, 13, Enum.Font.GothamSemibold, WHITE)
	title.Position = UDim2.fromOffset(14, 9)
	title.Size = UDim2.new(1, -90, 0, 20)

	local desc = makeText(holder, descriptionText, 10, Enum.Font.Gotham, MUTED)
	desc.Position = UDim2.fromOffset(14, 32)
	desc.Size = UDim2.new(1, -105, 0, 30)
	desc.TextWrapped = true
	desc.TextYAlignment = Enum.TextYAlignment.Top

	local track = Instance.new("TextButton")
	track.AnchorPoint = Vector2.new(1, 0.5)
	track.Position = UDim2.new(1, -15, 0.5, 0)
	track.Size = UDim2.fromOffset(49, 26)
	track.BackgroundColor3 = Color3.fromRGB(29, 49, 77)
	track.BorderSizePixel = 0
	track.Text = ""
	track.AutoButtonColor = false
	track.Parent = holder
	corner(track, 20)

	local knob = Instance.new("Frame")
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 13, 0.5, 0)
	knob.Size = UDim2.fromOffset(19, 19)
	knob.BackgroundColor3 = Color3.fromRGB(180, 200, 220)
	knob.BorderSizePixel = 0
	knob.Parent = track
	corner(knob, 20)

	local state = defaultValue == true

	local function setState(value)
		state = value == true

		if state then
			tween(track, 0.18, {
				BackgroundColor3 = BLUE_4
			})
			tween(knob, 0.18, {
				Position = UDim2.new(1, -13, 0.5, 0),
				BackgroundColor3 = WHITE
			})
		else
			tween(track, 0.18, {
				BackgroundColor3 = Color3.fromRGB(29, 49, 77)
			})
			tween(knob, 0.18, {
				Position = UDim2.new(0, 13, 0.5, 0),
				BackgroundColor3 = Color3.fromRGB(180, 200, 220)
			})
		end

		if callback then
			callback(state)
		end
	end

	track.Activated:Connect(function()
		setState(not state)
	end)

	holder.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setState(not state)
		end
	end)

	setState(state)

	return {
		Set = setState,
		Get = function()
			return state
		end
	}
end

local function createButton(parent, titleText, descriptionText, callback, order)
	local holder = Instance.new("Frame")
	holder.LayoutOrder = order
	holder.Size = UDim2.new(1, 0, 0, 72)
	holder.BackgroundColor3 = Color3.fromRGB(8, 29, 58)
	holder.BackgroundTransparency = 0.22
	holder.BorderSizePixel = 0
	holder.Parent = parent
	corner(holder, 9)
	stroke(holder, Color3.fromRGB(31, 84, 140), 0.65, 1)

	local title = makeText(holder, titleText, 13, Enum.Font.GothamSemibold, WHITE)
	title.Position = UDim2.fromOffset(14, 9)
	title.Size = UDim2.new(1, -140, 0, 20)

	local desc = makeText(holder, descriptionText, 10, Enum.Font.Gotham, MUTED)
	desc.Position = UDim2.fromOffset(14, 32)
	desc.Size = UDim2.new(1, -140, 0, 30)
	desc.TextWrapped = true
	desc.TextYAlignment = Enum.TextYAlignment.Top

	local button = Instance.new("TextButton")
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -14, 0.5, 0)
	button.Size = UDim2.fromOffset(100, 34)
	button.BackgroundColor3 = BLUE_3
	button.BorderSizePixel = 0
	button.Text = "THỰC HIỆN"
	button.TextSize = 10
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = WHITE
	button.AutoButtonColor = false
	button.Parent = holder
	corner(button, 7)

	button.MouseEnter:Connect(function()
		tween(button, 0.15, {
			BackgroundColor3 = BLUE_4
		})
	end)

	button.MouseLeave:Connect(function()
		tween(button, 0.15, {
			BackgroundColor3 = BLUE_3
		})
	end)

	button.Activated:Connect(function()
		tween(button, 0.08, {
			Size = UDim2.fromOffset(94, 31)
		})
		task.delay(0.08, function()
			tween(button, 0.1, {
				Size = UDim2.fromOffset(100, 34)
			})
		end)

		if callback then
			callback()
		end
	end)

	return holder
end

local function createSlider(parent, titleText, descriptionText, minValue, maxValue, defaultValue, callback, order)
	local holder = Instance.new("Frame")
	holder.LayoutOrder = order
	holder.Size = UDim2.new(1, 0, 0, 92)
	holder.BackgroundColor3 = Color3.fromRGB(8, 29, 58)
	holder.BackgroundTransparency = 0.22
	holder.BorderSizePixel = 0
	holder.Parent = parent
	corner(holder, 9)
	stroke(holder, Color3.fromRGB(31, 84, 140), 0.65, 1)

	local title = makeText(holder, titleText, 13, Enum.Font.GothamSemibold, WHITE)
	title.Position = UDim2.fromOffset(14, 9)
	title.Size = UDim2.new(1, -105, 0, 20)

	local valueLabel = makeText(holder, tostring(defaultValue), 12, Enum.Font.GothamBold, BLUE_5)
	valueLabel.Position = UDim2.new(1, -75, 0, 9)
	valueLabel.Size = UDim2.fromOffset(60, 20)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right

	local desc = makeText(holder, descriptionText, 10, Enum.Font.Gotham, MUTED)
	desc.Position = UDim2.fromOffset(14, 31)
	desc.Size = UDim2.new(1, -28, 0, 22)
	desc.TextWrapped = true

	local sliderBackground = Instance.new("Frame")
	sliderBackground.Position = UDim2.new(0, 14, 1, -25)
	sliderBackground.Size = UDim2.new(1, -28, 0, 7)
	sliderBackground.BackgroundColor3 = Color3.fromRGB(26, 48, 78)
	sliderBackground.BorderSizePixel = 0
	sliderBackground.Parent = holder
	corner(sliderBackground, 10)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = BLUE_5
	fill.BorderSizePixel = 0
	fill.Parent = sliderBackground
	corner(fill, 10)

	local knob = Instance.new("Frame")
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	knob.Size = UDim2.fromOffset(15, 15)
	knob.BackgroundColor3 = WHITE
	knob.BorderSizePixel = 0
	knob.ZIndex = 3
	knob.Parent = sliderBackground
	corner(knob, 10)

	local dragging = false
	local currentValue = defaultValue

	local function apply(inputX)
		local startX = sliderBackground.AbsolutePosition.X
		local width = sliderBackground.AbsoluteSize.X
		local alpha = math.clamp((inputX - startX) / width, 0, 1)

		currentValue = math.floor(minValue + (maxValue - minValue) * alpha + 0.5)

		fill.Size = UDim2.new(alpha, 0, 1, 0)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		valueLabel.Text = tostring(currentValue)

		if callback then
			callback(currentValue)
		end
	end

	local initialAlpha = math.clamp(
		(defaultValue - minValue) / (maxValue - minValue),
		0,
		1
	)

	fill.Size = UDim2.new(initialAlpha, 0, 1, 0)
	knob.Position = UDim2.new(initialAlpha, 0, 0.5, 0)

	sliderBackground.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			apply(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			apply(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
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

local playerTitle = createSectionTitle(PlayerPage, "Player", 1)

local State = {
	flying = false,
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
	jumpPower = 50,
	spinSpeed = 15
}

local character
local humanoid
local root

local function refreshCharacter()
	character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	humanoid = character:FindFirstChildOfClass("Humanoid")
	root = character:FindFirstChild("HumanoidRootPart")
end

refreshCharacter()

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.3)
	refreshCharacter()
end)

local flyVelocity
local flyOrientation
local flyConnection

local function stopFly()
	State.flying = false

	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end

	if flyVelocity then
		flyVelocity:Destroy()
		flyVelocity = nil
	end

	if flyOrientation then
		flyOrientation:Destroy()
		flyOrientation = nil
	end

	if humanoid then
		humanoid.PlatformStand = false
	end
end

local function startFly()
	if not DEV_ACCESS then
		showNotice("Chức năng này chỉ dùng trong experience của bạn.", false)
		State.flying = false
		return
	end

	refreshCharacter()

	if not humanoid or not root then
		return
	end

	flyVelocity = Instance.new("LinearVelocity")
	flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	flyVelocity.MaxForce = math.huge
	flyVelocity.VectorVelocity = Vector3.zero

	local attachment = Instance.new("Attachment")
	attachment.Name = "_ThoFlyAttachment"
	attachment.Parent = root

	flyVelocity.Attachment0 = attachment
	flyVelocity.Parent = root

	flyOrientation = Instance.new("AlignOrientation")
	flyOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	flyOrientation.MaxTorque = math.huge
	flyOrientation.Responsiveness = 35
	flyOrientation.Attachment0 = attachment
	flyOrientation.Parent = root

	humanoid.PlatformStand = true

	flyConnection = RunService.RenderStepped:Connect(function()
		if not State.flying or not character or not character.Parent or not root then
			return
		end

		local camera = workspace.CurrentCamera
		local move = Vector3.zero

		local forward = camera.CFrame.LookVector
		local right = camera.CFrame.RightVector
		local up = Vector3.new(0, 1, 0)

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			move += forward
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			move -= forward
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			move += right
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			move -= right
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			move += up
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			move -= up
		end

		if move.Magnitude > 0 then
			move = move.Unit
		end

		flyVelocity.VectorVelocity = move * State.flySpeed
		flyOrientation.CFrame = CFrame.lookAt(Vector3.zero, camera.CFrame.LookVector)
	end)
end

local flyToggle = createToggle(
	PlayerPage,
	"Bay",
	"Cho phép nhân vật bay tự do với tốc độ có thể tùy chỉnh.",
	false,
	function(value)
		if value then
			startFly()
		else
			stopFly()
		end
	end,
	2
)

createSlider(
	PlayerPage,
	"Tốc độ bay",
	"Kéo thanh trượt để thay đổi tốc độ bay tối đa 200.",
	10,
	200,
	State.flySpeed,
	function(value)
		State.flySpeed = value
	end,
	3
)

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
	if not DEV_ACCESS then
		showNotice("Chức năng này chỉ dùng trong experience của bạn.", false)
		State.airWalk = false
		return
	end

	refreshCharacter()

	if not root then
		return
	end

	airPlatform = Instance.new("Part")
	airPlatform.Name = "_ThoAirWalk"
	airPlatform.Size = Vector3.new(4.5, 0.35, 4.5)
	airPlatform.Transparency = 1
	airPlatform.CanCollide = true
	airPlatform.Anchored = true
	airPlatform.CanQuery = false
	airPlatform.CanTouch = false
	airPlatform.Parent = workspace

	airConnection = RunService.Heartbeat:Connect(function()
		if not State.airWalk or not root or not root.Parent or not airPlatform then
			return
		end

		local position = root.Position - Vector3.new(0, 3.05, 0)
		airPlatform.CFrame = CFrame.new(position)
	end)
end

createToggle(
	PlayerPage,
	"Đi trên không",
	"Tạo điểm đỡ ổn định ngay dưới nhân vật để có thể đứng trên không.",
	false,
	function(value)
		State.airWalk = value

		if value then
			startAirWalk()
		else
			stopAirWalk()
		end
	end,
	4
)

local normalWalkSpeed = 16

local function applyWalkSpeed()
	refreshCharacter()

	if humanoid then
		humanoid.WalkSpeed = State.speed and State.walkSpeed or normalWalkSpeed
	end
end

createToggle(
	PlayerPage,
	"Chạy nhanh",
	"Điều chỉnh tốc độ di chuyển của nhân vật.",
	false,
	function(value)
		State.speed = value

		if not DEV_ACCESS then
			showNotice("Chức năng này chỉ dùng trong experience của bạn.", false)
			return
		end

		applyWalkSpeed()
	end,
	5
)

createSlider(
	PlayerPage,
	"Tốc độ chạy",
	"Giới hạn điều chỉnh từ 16 đến 200.",
	16,
	200,
	State.walkSpeed,
	function(value)
		State.walkSpeed = value
		if State.speed then
			applyWalkSpeed()
		end
	end,
	6
)

local normalJumpPower = 50

local function applyJump()
	refreshCharacter()

	if humanoid then
		humanoid.UseJumpPower = true
		humanoid.JumpPower = State.jump and State.jumpPower or normalJumpPower
	end
end

createToggle(
	PlayerPage,
	"Nhảy cao",
	"Tăng lực nhảy của nhân vật theo giá trị đã chọn.",
	false,
	function(value)
		State.jump = value

		if not DEV_ACCESS then
			showNotice("Chức năng này chỉ dùng trong experience của bạn.", false)
			return
		end

		applyJump()
	end,
	7
)

createSlider(
	PlayerPage,
	"Độ cao nhảy",
	"Điều chỉnh JumpPower tối đa 200.",
	50,
	200,
	State.jumpPower,
	function(value)
		State.jumpPower = value
		if State.jump then
			applyJump()
		end
	end,
	8
)

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
	if not DEV_ACCESS then
		showNotice("Chức năng này chỉ dùng trong experience của bạn.", false)
		State.noclip = false
		return
	end

	noclipConnection = RunService.Stepped:Connect(function()
		if not State.noclip or not character then
			return
		end

		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then
				object.CanCollide = false
			end
		end
	end)
end

createToggle(
	PlayerPage,
	"Đi xuyên tường",
	"Tắt va chạm các bộ phận nhân vật để kiểm tra map và collision trong experience.",
	false,
	function(value)
		State.noclip = value

		if value then
			startNoclip()
		else
			stopNoclip()
		end
	end,
	9
)

local lyingConnection

local function stopLying()
	State.lying = false

	if lyingConnection then
		lyingConnection:Disconnect()
		lyingConnection = nil
	end

	refreshCharacter()

	if humanoid then
		humanoid.AutoRotate = true
	end
end

local function startLying()
	if not DEV_ACCESS then
		showNotice("Chức năng này chỉ dùng trong experience của bạn.", false)
		State.lying = false
		return
	end

	refreshCharacter()

	if not humanoid or not root then
		return
	end

	humanoid.AutoRotate = false

	lyingConnection = RunService.RenderStepped:Connect(function()
		if not State.lying or not root or not root.Parent then
			return
		end

		local position = root.Position
		local look = root.CFrame.LookVector

		root.CFrame = CFrame.lookAt(position, position + look) * CFrame.Angles(0, 0, math.rad(90))
	end)
end

createToggle(
	PlayerPage,
	"Nằm",
	"Tạo tư thế nằm ngang cho nhân vật trong experience của bạn.",
	false,
	function(value)
		State.lying = value

		if value then
			startLying()
		else
			stopLying()
		end
	end,
	10
)

local function sitCharacter()
	if not DEV_ACCESS then
		showNotice("Chức năng này chỉ dùng trong experience của bạn.", false)
		return
	end

	refreshCharacter()

	if humanoid then
		humanoid.Sit = true
	end
end

local sitToggle

sitToggle = createToggle(
	PlayerPage,
	"Ngồi",
	"Đưa nhân vật vào trạng thái ngồi chuẩn của Humanoid.",
	false,
	function(value)
		State.sitting = value

		if not DEV_ACCESS then
			showNotice("Chức năng này chỉ dùng trong experience của bạn.", false)
			return
		end

		refreshCharacter()

		if humanoid then
			humanoid.Sit = value
		end
	end,
	11
)

local spinConnection

local function stopSpin()
	State.spin = false

	if spinConnection then
		spinConnection:Disconnect()
		spinConnection = nil
	end
end

local function startSpin()
	if not DEV_ACCESS then
		showNotice("Chức năng này chỉ dùng trong experience của bạn.", false)
		State.spin = false
		return
	end

	spinConnection = RunService.RenderStepped:Connect(function(delta)
		if not State.spin then
			return
		end

		refreshCharacter()

		if root then
			root.CFrame =
				root.CFrame
				* CFrame.Angles(
					0,
					math.rad(State.spinSpeed * 20) * delta,
					0
				)
		end
	end)
end

createToggle(
	PlayerPage,
	"Xoay",
	"Tự động xoay nhân vật liên tục theo tốc độ đã chọn.",
	false,
	function(value)
		State.spin = value

		if value then
			startSpin()
		else
			stopSpin()
		end
	end,
	12
)

createSlider(
	PlayerPage,
	"Tốc độ xoay",
	"Điều chỉnh tốc độ xoay từ 1 đến 50.",
	1,
	50,
	State.spinSpeed,
	function(value)
		State.spinSpeed = value
	end,
	13
)

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "_ThoESP"
ESPFolder.Parent = ScreenGui

local ESPObjects = {}

local function destroyESP(player)
	local data = ESPObjects[player]

	if not data then
		return
	end

	for _, object in pairs(data) do
		if typeof(object) == "Instance" and object.Parent then
			object:Destroy()
		end
	end

	ESPObjects[player] = nil
end

local function createESP(player)
	if player == LocalPlayer then
		return
	end

	if ESPObjects[player] then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = BLUE_5
	highlight.FillTransparency = 0.82
	highlight.OutlineColor = Color3.fromRGB(90, 205, 255)
	highlight.OutlineTransparency = 0.05
	highlight.Enabled = false
	highlight.Parent = ESPFolder

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "_Info"
	billboard.Size = UDim2.fromOffset(190, 58)
	billboard.StudsOffset = Vector3.new(0, 3.4, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = false
	billboard.Parent = ESPFolder

	local container = Instance.new("Frame")
	container.Size = UDim2.fromScale(1, 1)
	container.BackgroundTransparency = 1
	container.Parent = billboard

	local nameLabel = makeText(container, player.DisplayName, 12, Enum.Font.GothamBold, WHITE)
	nameLabel.Size = UDim2.new(1, 0, 0, 22)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center

	local infoLabel = makeText(container, "HP: -- | -- studs", 10, Enum.Font.GothamMedium, MUTED)
	infoLabel.Position = UDim2.fromOffset(0, 22)
	infoLabel.Size = UDim2.new(1, 0, 0, 20)
	infoLabel.TextXAlignment = Enum.TextXAlignment.Center

	ESPObjects[player] = {
		highlight = highlight,
		billboard = billboard,
		nameLabel = nameLabel,
		infoLabel = infoLabel
	}
end

local espConnection

local function stopESP()
	State.esp = false

	if espConnection then
		espConnection:Disconnect()
		espConnection = nil
	end

	for player in pairs(ESPObjects) do
		local data = ESPObjects[player]

		if data then
			data.highlight.Enabled = false
			data.billboard.Enabled = false
		end
	end
end

local function startESP()
	for _, player in ipairs(Players:GetPlayers()) do
		createESP(player)
	end

	if espConnection then
		espConnection:Disconnect()
	end

	espConnection = RunService.RenderStepped:Connect(function()
		local localCharacter = LocalPlayer.Character
		local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				createESP(player)

				local data = ESPObjects[player]
				local targetCharacter = player.Character
				local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
				local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

				if data and targetCharacter and targetRoot and targetHumanoid and localRoot then
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
		createESP(player)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	destroyESP(player)
end)

createToggle(
	PlayerPage,
	"Định vị người chơi",
	"Hiển thị khung, tên, máu và khoảng cách của người chơi khác; không hiển thị bản thân.",
	false,
	function(value)
		State.esp = value

		if not DEV_ACCESS then
			showNotice("Chức năng này chỉ dùng trong experience của bạn.", false)
			State.esp = false
			return
		end

		if value then
			startESP()
		else
			stopESP()
		end
	end,
	14
)

createSectionTitle(ServerPage, "Server", 1)

createButton(
	ServerPage,
	"Đổi máy chủ",
	"Đi tới một instance khác của chính experience hiện tại.",
	function()
		if not DEV_ACCESS then
			showNotice("Chỉ cho phép trong experience do bạn phát triển.", false)
			return
		end

		showNotice("Server hop cần được quản lý bởi hệ thống server của experience.", false)
	end,
	2
)

createButton(
	ServerPage,
	"Đổi máy chủ ít người",
	"Tìm instance có lượng người chơi thấp thông qua hệ thống server riêng của experience.",
	function()
		if not DEV_ACCESS then
			showNotice("Chỉ cho phép trong experience do bạn phát triển.", false)
			return
		end

		showNotice("Tính năng này cần server browser/API riêng của experience.", false)
	end,
	3
)

createButton(
	ServerPage,
	"Tham gia lại máy chủ",
	"Yêu cầu experience đưa bạn trở lại đúng instance đang chạy.",
	function()
		if not DEV_ACCESS then
			showNotice("Chỉ cho phép trong experience do bạn phát triển.", false)
			return
		end

		local jobId = game.JobId

		if jobId == "" then
			showNotice("Studio không có JobId để rejoin.", false)
			return
		end

		pcall(function()
			TeleportService:TeleportToPlaceInstance(
				game.PlaceId,
				jobId,
				LocalPlayer
			)
		end)
	end,
	4
)

createToggle(
	ServerPage,
	"Tự động chạy script",
	"Giữ trạng thái giao diện khi hệ thống của chính experience thực hiện teleport sang instance khác.",
	false,
	function(value)
		if not DEV_ACCESS then
			showNotice("Chỉ cho phép trong experience do bạn phát triển.", false)
			return
		end

		if value then
			showNotice("Đã bật trạng thái tự động khôi phục giao diện.", true)
		else
			showNotice("Đã tắt trạng thái tự động khôi phục.", true)
		end
	end,
	5
)

local originalSize = Main.Size
local originalPosition = Main.Position
local minimized = false
local maximized = false
local closed = false

local function setMinimized(value)
	minimized = value

	if value then
		Sidebar.Visible = false
		Content.Visible = false

		tween(Main, 0.25, {
			Size = UDim2.fromOffset(850, 58)
		})

		MenuSubtitle.Text = "Đã thu nhỏ"
	else
		tween(Main, 0.25, {
			Size = maximized and UDim2.fromOffset(1020, 650) or originalSize
		})

		task.delay(0.15, function()
			if not minimized and Main.Parent then
				Sidebar.Visible = true
				Content.Visible = true
			end
		end)

		MenuSubtitle.Text = "Personal utility interface"
	end
end

local function setMaximized(value)
	maximized = value

	if value then
		setMinimized(false)

		tween(Main, 0.28, {
			Size = UDim2.fromOffset(1020, 650)
		})
	else
		tween(Main, 0.28, {
			Size = originalSize
		})
	end
end

MinimizeButton.Activated:Connect(function()
	setMinimized(not minimized)
end)

MaximizeButton.Activated:Connect(function()
	setMaximized(not maximized)
end)

CloseButton.Activated:Connect(function()
	closed = true

	tween(Main, 0.22, {
		Size = UDim2.fromOffset(0, 0)
	})

	task.delay(0.25, function()
		if Main.Parent then
			Main.Visible = false
		end
	end)
end)

local function reopen()
	if not closed then
		return
	end

	closed = false
	Main.Visible = true
	Main.Size = UDim2.fromOffset(0, 0)

	tween(Main, 0.25, {
		Size = maximized and UDim2.fromOffset(1020, 650) or originalSize
	})
end

local dragging = false
local dragStart
local startPosition
local dragInput

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPosition = Main.Position
		dragInput = input
	end
end)

Header.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
		dragInput = nil
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart

		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.RightShift then
		if closed then
			reopen()
		else
			Main.Visible = not Main.Visible
		end
	end
end)

for tabName, data in pairs(TabButtons) do
	if tabName == "Player" then
		data.button.BackgroundTransparency = 0.03
		data.label.TextColor3 = WHITE
		data.accent.BackgroundTransparency = 0
	end
end

humanoid and humanoid.Died:Connect(function()
	stopFly()
	stopAirWalk()
	stopNoclip()
	stopLying()
	stopSpin()

	if State.esp then
		task.defer(function()
			if State.esp then
				startESP()
			end
		end)
	end
end)

task.spawn(function()
	while Main.Parent do
		if State.sitting then
			refreshCharacter()

			if humanoid and humanoid.Health > 0 then
				humanoid.Sit = true
			end
		end

		task.wait(0.25)
	end
end)

task.spawn(function()
	while Main.Parent do
		if State.speed then
			applyWalkSpeed()
		end

		if State.jump then
			applyJump()
		end

		task.wait(0.4)
	end
end)
