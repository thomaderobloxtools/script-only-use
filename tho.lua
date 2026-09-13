-- [ThoScript] BUILD: 2026-09-13 #11
-- - Fix fly: thêm BodyVelocity counter gravity, không giật khi đứng im
-- - Fix đi trên không: platform sát chân hơn, dày hơn
-- - Thêm "Dịch chuyển ảo thuật" (Player): camera tách, nút tròn teleport
-- - Thêm "Xem từ xa" (Visual): free camera
-- - Thêm pose "Vô Lượng Không Xứ" và "Phục Ma Ngự Trù Tử"
local SCRIPT_BUILD = "2026-09-13-#11"
local AUTORUN_URL = "https://raw.githubusercontent.com/thomaderobloxtools/script-only-use/main/tho.lua"

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local GUI_NAME = "ThoScript"
local BLUE_1 = Color3.fromRGB(7, 18, 38)
local BLUE_3 = Color3.fromRGB(15, 48, 98)
local BLUE_4 = Color3.fromRGB(20, 91, 170)
local BLUE_5 = Color3.fromRGB(0, 170, 255)
local WHITE = Color3.fromRGB(235, 245, 255)
local MUTED = Color3.fromRGB(145, 170, 200)
local GREEN = Color3.fromRGB(40, 220, 140)
local RED = Color3.fromRGB(255, 80, 95)

local old = PlayerGui:FindFirstChild(GUI_NAME)
if old then old:Destroy() end
local oldFloat = PlayerGui:FindFirstChild(GUI_NAME .. "_Float")
if oldFloat then oldFloat:Destroy() end

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
	label.Active = false
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
Main.Position = UDim2.new(0.5, -MAIN_WIDTH / 2, 0.5, -MAIN_HEIGHT / 2)
Main.Size = UDim2.fromOffset(MAIN_WIDTH, MAIN_HEIGHT)
Main.BackgroundColor3 = BLUE_1
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.ZIndex = 60000
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
Header.Active = true
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

local MenuSubtitle = addText(Header, "Build " .. SCRIPT_BUILD, 9, Enum.Font.GothamMedium, MUTED)
MenuSubtitle.Position = UDim2.fromOffset(16, 24)
MenuSubtitle.Size = UDim2.fromOffset(200, 16)

local HeaderButtons = Instance.new("Frame")
HeaderButtons.AnchorPoint = Vector2.new(1, 0.5)
HeaderButtons.Position = UDim2.new(1, -8, 0.5, 0)
HeaderButtons.Size = UDim2.fromOffset(108, 28)
HeaderButtons.BackgroundTransparency = 1
HeaderButtons.Active = false
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
	b.MouseEnter:Connect(function() tween(b, 0.12, {BackgroundColor3 = BLUE_4}) end)
	b.MouseLeave:Connect(function() tween(b, 0.12, {BackgroundColor3 = Color3.fromRGB(15, 47, 90)}) end)
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
			tween(data.button, 0.12, {BackgroundTransparency = active and 0.03 or 0.35})
			tween(data.label, 0.12, {TextColor3 = active and WHITE or MUTED})
			tween(data.accent, 0.12, {BackgroundTransparency = active and 0 or 1})
		end
	end)

	TabButtons[name] = { button = button, label = label, accent = accent }
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
createTab("Visual", 4)

local PlayerPage = createPage("Player")
local ServerPage = createPage("Server")
local VisualPage = createPage("Visual")

local function showNotice(text, success)
	local notice = Instance.new("Frame")
	notice.AnchorPoint = Vector2.new(1, 0)
	notice.Position = UDim2.new(1, 18, 0, 56)
	notice.Size = UDim2.fromOffset(240, 44)
	notice.BackgroundColor3 = success and Color3.fromRGB(10, 67, 59) or Color3.fromRGB(67, 29, 39)
	notice.BorderSizePixel = 0
	notice.ZIndex = 70000
	notice.Active = false
	notice.Parent = Main
	addCorner(notice, 8)
	addStroke(notice, success and GREEN or RED, 0.55, 1)

	local label = addText(notice, text, 10, Enum.Font.GothamSemibold, WHITE)
	label.Position = UDim2.fromOffset(10, 0)
	label.Size = UDim2.new(1, -20, 1, 0)
	label.TextWrapped = true
	label.ZIndex = 70001

	tween(notice, 0.2, {Position = UDim2.new(1, -12, 0, 56)})
	task.delay(2.1, function()
		if notice.Parent then
			tween(notice, 0.18, {Position = UDim2.new(1, 18, 0, 56)})
			task.wait(0.2)
			notice:Destroy()
		end
	end)
end

local function showCopyPopup(title, copyText)
	local popup = Instance.new("Frame")
	popup.AnchorPoint = Vector2.new(0.5, 0.5)
	popup.Position = UDim2.fromScale(0.5, 0.5)
	popup.Size = UDim2.fromOffset(440, 220)
	popup.BackgroundColor3 = Color3.fromRGB(12, 30, 60)
	popup.BorderSizePixel = 0
	popup.ZIndex = 80000
	popup.Parent = ScreenGui
	addCorner(popup, 10)
	addStroke(popup, BLUE_5, 0.3, 1)

	local t = addText(popup, title, 13, Enum.Font.GothamBold, WHITE)
	t.Position = UDim2.fromOffset(14, 10)
	t.Size = UDim2.new(1, -60, 0, 20)
	t.ZIndex = 80001

	local closeB = Instance.new("TextButton")
	closeB.Size = UDim2.fromOffset(28, 28)
	closeB.Position = UDim2.new(1, -34, 0, 8)
	closeB.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	closeB.BorderSizePixel = 0
	closeB.Text = "×"
	closeB.TextColor3 = WHITE
	closeB.Font = Enum.Font.GothamBold
	closeB.TextSize = 16
	closeB.AutoButtonColor = false
	closeB.ZIndex = 80001
	closeB.Parent = popup
	addCorner(closeB, 6)

	local box = Instance.new("TextBox")
	box.Position = UDim2.fromOffset(14, 44)
	box.Size = UDim2.new(1, -28, 1, -100)
	box.BackgroundColor3 = Color3.fromRGB(8, 20, 40)
	box.BorderSizePixel = 0
	box.Text = copyText
	box.TextColor3 = WHITE
	box.Font = Enum.Font.Code
	box.TextSize = 11
	box.TextWrapped = true
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.TextYAlignment = Enum.TextYAlignment.Top
	box.ClearTextOnFocus = false
	box.MultiLine = true
	box.ZIndex = 80001
	box.Parent = popup
	addCorner(box, 6)

	local copyB = Instance.new("TextButton")
	copyB.AnchorPoint = Vector2.new(0.5, 0)
	copyB.Position = UDim2.new(0.5, 0, 1, -40)
	copyB.Size = UDim2.fromOffset(120, 30)
	copyB.BackgroundColor3 = BLUE_4
	copyB.BorderSizePixel = 0
	copyB.Text = "COPY"
	copyB.TextColor3 = WHITE
	copyB.Font = Enum.Font.GothamBold
	copyB.TextSize = 12
	copyB.AutoButtonColor = false
	copyB.ZIndex = 80001
	copyB.Parent = popup
	addCorner(copyB, 6)

	copyB.MouseButton1Click:Connect(function()
		local ok = pcall(function()
			if setclipboard then setclipboard(copyText) end
		end)
		if ok then
			copyB.Text = "ĐÃ COPY!"
			task.delay(1.2, function() copyB.Text = "COPY" end)
		else
			copyB.Text = "LỖI"
			task.delay(1.2, function() copyB.Text = "COPY" end)
		end
	end)

	closeB.MouseButton1Click:Connect(function()
		popup:Destroy()
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
			tween(knob, 0.16, {Position = UDim2.new(1, -11, 0.5, 0), BackgroundColor3 = WHITE})
		else
			tween(track, 0.16, {BackgroundColor3 = Color3.fromRGB(29, 49, 77)})
			tween(knob, 0.16, {Position = UDim2.new(0, 11, 0.5, 0), BackgroundColor3 = Color3.fromRGB(180, 200, 220)})
		end

		if callback and notify ~= false then callback(state) end

		task.delay(0.05, function() busy = false end)
	end

	track.Activated:Connect(function() setState(not state) end)
	setState(state, false)

	return {
		Set = function(value) setState(value) end,
		Get = function() return state end,
		SetSilent = function(value)
			state = value == true
			if state then
				track.BackgroundColor3 = BLUE_4
				knob.Position = UDim2.new(1, -11, 0.5, 0)
				knob.BackgroundColor3 = WHITE
			else
				track.BackgroundColor3 = Color3.fromRGB(29, 49, 77)
				knob.Position = UDim2.new(0, 11, 0.5, 0)
				knob.BackgroundColor3 = Color3.fromRGB(180, 200, 220)
			end
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

	button.MouseEnter:Connect(function() tween(button, 0.12, {BackgroundColor3 = BLUE_4}) end)
	button.MouseLeave:Connect(function() tween(button, 0.12, {BackgroundColor3 = BLUE_3}) end)

	button.Activated:Connect(function()
		tween(button, 0.07, {Size = UDim2.fromOffset(80, 26)})
		task.delay(0.07, function()
			if button.Parent then
				tween(button, 0.1, {Size = UDim2.fromOffset(84, 28)})
			end
		end)
		if callback then callback() end
	end)
end

local activeSlider = nil

UserInputService.InputChanged:Connect(function(input)
	if activeSlider and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
		activeSlider(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
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

	local bar = Instance.new("Frame")
	bar.Position = UDim2.new(0, 12, 1, -22)
	bar.Size = UDim2.new(1, -24, 0, 8)
	bar.BackgroundColor3 = Color3.fromRGB(26, 48, 78)
	bar.BorderSizePixel = 0
	bar.Active = false
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
	knob.Size = UDim2.fromOffset(15, 15)
	knob.BackgroundColor3 = WHITE
	knob.BorderSizePixel = 0
	knob.ZIndex = 3
	knob.Active = false
	knob.Parent = bar
	addCorner(knob, 10)

	local hitbox = Instance.new("TextButton")
	hitbox.Position = UDim2.new(0, 8, 1, -38)
	hitbox.Size = UDim2.new(1, -16, 0, 42)
	hitbox.BackgroundTransparency = 1
	hitbox.Text = ""
	hitbox.AutoButtonColor = false
	hitbox.Active = true
	hitbox.ZIndex = 10
	hitbox.Parent = row

	local currentValue = defaultValue

	local function applyFromHitbox(x)
		local startX = hitbox.AbsolutePosition.X
		local width = hitbox.AbsoluteSize.X
		if width <= 0 then return end
		local alpha = math.clamp((x - startX) / width, 0, 1)
		currentValue = math.floor(minValue + (maxValue - minValue) * alpha + 0.5)

		fill.Size = UDim2.new(alpha, 0, 1, 0)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		valueLabel.Text = tostring(currentValue)

		if callback then callback(currentValue) end
	end

	local initialAlpha = math.clamp((defaultValue - minValue) / (maxValue - minValue), 0, 1)
	fill.Size = UDim2.new(initialAlpha, 0, 1, 0)
	knob.Position = UDim2.new(initialAlpha, 0, 0.5, 0)

	hitbox.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			activeSlider = applyFromHitbox
			applyFromHitbox(input.Position.X)
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
			if callback then callback(v) end
		end,
		Get = function() return currentValue end
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
	antiLag = false,
	flySpeed = 100,
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

local ALL_STATES = {
	Enum.HumanoidStateType.Climbing,
	Enum.HumanoidStateType.FallingDown,
	Enum.HumanoidStateType.Flying,
	Enum.HumanoidStateType.Freefall,
	Enum.HumanoidStateType.GettingUp,
	Enum.HumanoidStateType.Jumping,
	Enum.HumanoidStateType.Landed,
	Enum.HumanoidStateType.Physics,
	Enum.HumanoidStateType.PlatformStanding,
	Enum.HumanoidStateType.Ragdoll,
	Enum.HumanoidStateType.Running,
	Enum.HumanoidStateType.RunningNoPhysics,
	Enum.HumanoidStateType.Seated,
	Enum.HumanoidStateType.StrafingNoPhysics,
	Enum.HumanoidStateType.Swimming
}

local flyConnection, flyActive, flyBV

local function stopFly()
	State.fly = false
	flyActive = false
	if flyConnection then flyConnection:Disconnect() flyConnection = nil end
	if flyBV then flyBV:Destroy() flyBV = nil end
	refreshCharacter()
	if humanoid then
		for _, state in ipairs(ALL_STATES) do
			pcall(function() humanoid:SetStateEnabled(state, true) end)
		end
		pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics) end)
	end
	if character and character:FindFirstChild("Animate") then
		pcall(function() character.Animate.Disabled = false end)
	end
end

local function startFly()
	refreshCharacter()
	if not humanoid or not root then
		showNotice("Không tìm thấy nhân vật.", false)
		State.fly = false
		return
	end

	flyActive = true

	for _, state in ipairs(ALL_STATES) do
		pcall(function() humanoid:SetStateEnabled(state, false) end)
	end
	pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Swimming) end)

	if character and character:FindFirstChild("Animate") then
		pcall(function() character.Animate.Disabled = true end)
	end

	pcall(function()
		for _, v in next, humanoid:GetPlayingAnimationTracks() do
			v:AdjustSpeed(0)
		end
	end)

	flyBV = Instance.new("BodyVelocity")
	flyBV.Name = "_ThoFlyBV"
	flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	flyBV.Velocity = Vector3.zero
	flyBV.P = 1e5
	flyBV.Parent = root

	flyConnection = RunService.RenderStepped:Connect(function(dt)
		if not flyActive or not root or not root.Parent then return end
		local cam = workspace.CurrentCamera
		if not cam then return end

		local move = Vector3.zero
		local md = humanoid.MoveDirection
		if md.Magnitude > 0 then
			move = md
		else
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
		end

		local vert = 0
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vert = 1 end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vert = -1 end

		local vel = move + Vector3.yAxis * vert
		if vel.Magnitude > 0 then
			vel = vel.Unit * State.flySpeed
		end

		if flyBV then
			flyBV.Velocity = vel
		end

		local newPos = root.Position + vel * dt
		root.CFrame = CFrame.new(newPos, newPos + cam.CFrame.LookVector)
	end)
end

createToggle(PlayerPage, "Bay", "Dùng joystick/WASD, Space/Ctrl để lên xuống.", false, function(value)
	State.fly = value
	if value then startFly() else stopFly() end
end, 2)

createSlider(PlayerPage, "Tốc độ bay", "Kéo để chỉnh tốc độ bay, tối đa 1000.", 10, 1000, State.flySpeed, function(value)
	State.flySpeed = value
end, 3)

local airPlatform
local airConnection
local airActive = false
local airBaseY = 0

local function stopAirWalk()
	State.airWalk = false
	airActive = false
	if airConnection then airConnection:Disconnect() airConnection = nil end
	if airPlatform then airPlatform:Destroy() airPlatform = nil end
end

local function startAirWalk()
	refreshCharacter()
	if not root then return end
	airActive = true

	airBaseY = root.Position.Y - 3.2

	airPlatform = Instance.new("Part")
	airPlatform.Name = "_ThoAirWalk"
	airPlatform.Size = Vector3.new(14, 6, 14)
	airPlatform.Transparency = 0.75
	airPlatform.Color = Color3.fromRGB(100, 200, 255)
	airPlatform.Material = Enum.Material.SmoothPlastic
	airPlatform.CanCollide = true
	airPlatform.Anchored = true
	airPlatform.CFrame = CFrame.new(root.Position.X, airBaseY, root.Position.Z)
	airPlatform.Parent = workspace

	airConnection = RunService.Heartbeat:Connect(function()
		if not airActive or not root or not root.Parent or not airPlatform then return end
		airPlatform.CFrame = CFrame.new(root.Position.X, airBaseY, root.Position.Z)
	end)
end

createToggle(PlayerPage, "Đi trên không", "Tạo bệ đỡ cố định ngay dưới chân nhân vật.", false, function(value)
	State.airWalk = value
	if value then startAirWalk() else stopAirWalk() end
end, 4)

local function applyWalkSpeed()
	refreshCharacter()
	if humanoid then
		humanoid.WalkSpeed = State.speed and State.walkSpeed or 16
	end
end

createToggle(PlayerPage, "Chạy nhanh", "Thay đổi tốc độ di chuyển.", false, function(value)
	State.speed = value
	applyWalkSpeed()
end, 5)

createSlider(PlayerPage, "Tốc độ chạy", "Kéo để chỉnh từ 16 đến 1000.", 16, 1000, State.walkSpeed, function(value)
	State.walkSpeed = value
	if State.speed then applyWalkSpeed() end
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

createSlider(PlayerPage, "Độ cao nhảy", "Kéo để chỉnh JumpPower tối đa 1000.", 50, 1000, State.jumpPower, function(value)
	State.jumpPower = value
	if State.jump then applyJumpPower() end
end, 8)

local noclipConnection

local function stopNoclip()
	State.noclip = false
	if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
	if character then
		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then object.CanCollide = true end
		end
	end
end

local function startNoclip()
	noclipConnection = RunService.Stepped:Connect(function()
		if not State.noclip or not character then return end
		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then object.CanCollide = false end
		end
	end)
end

createToggle(PlayerPage, "Đi xuyên tường", "Tắt collision của nhân vật.", false, function(value)
	State.noclip = value
	if value then startNoclip() else stopNoclip() end
end, 9)

local lyingConnection
local lyingToggle

local function stopLying()
	State.lying = false
	if lyingConnection then lyingConnection:Disconnect() lyingConnection = nil end
	refreshCharacter()
	if humanoid then
		humanoid.PlatformStand = false
		humanoid.AutoRotate = true
		pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
	end
end

local function startLying()
	refreshCharacter()
	if not humanoid or not root then return end

	humanoid.PlatformStand = true
	humanoid.AutoRotate = false

	lyingConnection = RunService.RenderStepped:Connect(function()
		if not State.lying or not root or not root.Parent then return end
		local pos = root.Position
		local yaw = math.rad(root.Orientation.Y)
		root.CFrame = CFrame.new(pos) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(math.rad(90), 0, 0)
	end)
end

lyingToggle = createToggle(PlayerPage, "Nằm", "Nằm ngửa. Nhấn Space để thoát.", false, function(value)
	State.lying = value
	if value then startLying() else stopLying() end
end, 10)

createToggle(PlayerPage, "Ngồi", "Đưa Humanoid vào trạng thái ngồi.", false, function(value)
	State.sitting = value
	refreshCharacter()
	if humanoid then humanoid.Sit = value end
end, 11)

local spinConnection

local function stopSpin()
	State.spin = false
	if spinConnection then spinConnection:Disconnect() spinConnection = nil end
end

local function startSpin()
	spinConnection = RunService.RenderStepped:Connect(function(delta)
		if not State.spin then return end
		refreshCharacter()
		if root then
			root.CFrame *= CFrame.Angles(0, math.rad(State.spinSpeed * 30) * delta, 0)
		end
	end)
end

createToggle(PlayerPage, "Xoay", "Xoay nhân vật liên tục kể cả khi di chuyển.", false, function(value)
	State.spin = value
	if value then startSpin() else stopSpin() end
end, 12)

createSlider(PlayerPage, "Tốc độ xoay", "Kéo để chỉnh tốc độ từ 1 đến 200.", 1, 200, State.spinSpeed, function(value)
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
	if data.box then data.box:Destroy() end
	ESPData[player] = nil
end

local function ensureESP(player)
	if player == LocalPlayer or ESPData[player] then return end

	local highlight = Instance.new("Highlight")
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = BLUE_5
	highlight.FillTransparency = 0.35
	highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
	highlight.OutlineTransparency = 0
	highlight.Enabled = false
	highlight.Parent = ESPFolder

	local box = Instance.new("SelectionBox")
	box.LineThickness = 0.15
	box.Color3 = Color3.fromRGB(0, 255, 255)
	box.Transparency = 0
	box.Visible = false
	box.Parent = ESPFolder

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(180, 50)
	billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = false
	billboard.LightInfluence = 0
	billboard.Parent = ESPFolder

	local nameLabel = addText(billboard, player.DisplayName, 13, Enum.Font.GothamBold, Color3.fromRGB(0, 255, 255))
	nameLabel.Size = UDim2.new(1, 0, 0, 20)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

	local infoLabel = addText(billboard, "HP: -- | -- studs", 11, Enum.Font.GothamBold, WHITE)
	infoLabel.Position = UDim2.fromOffset(0, 20)
	infoLabel.Size = UDim2.new(1, 0, 0, 18)
	infoLabel.TextXAlignment = Enum.TextXAlignment.Center
	infoLabel.TextStrokeTransparency = 0
	infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

	ESPData[player] = {
		highlight = highlight,
		billboard = billboard,
		nameLabel = nameLabel,
		infoLabel = infoLabel,
		box = box
	}
end

local function stopESP()
	State.esp = false
	if espConnection then espConnection:Disconnect() espConnection = nil end
	for _, data in pairs(ESPData) do
		data.highlight.Enabled = false
		data.billboard.Enabled = false
		data.box.Visible = false
	end
end

local function startESP()
	for _, player in ipairs(Players:GetPlayers()) do ensureESP(player) end
	if espConnection then espConnection:Disconnect() end

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
					data.box.Adornee = targetCharacter
					data.box.Visible = true

					local distance = math.floor((localRoot.Position - targetRoot.Position).Magnitude)
					data.nameLabel.Text = player.DisplayName
					data.infoLabel.Text =
						"HP: " .. math.floor(targetHumanoid.Health)
						.. "/" .. math.floor(targetHumanoid.MaxHealth)
						.. " | " .. distance .. " studs"
				elseif data then
					data.highlight.Enabled = false
					data.billboard.Enabled = false
					data.box.Visible = false
				end
			end
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	if State.esp then ensureESP(player) end
end)

Players.PlayerRemoving:Connect(function(player)
	destroyESP(player)
end)

createToggle(PlayerPage, "Định vị người chơi", "Hiển thị khung, tên, máu và khoảng cách.", false, function(value)
	State.esp = value
	if value then startESP() else stopESP() end
end, 14)

createButton(PlayerPage, "Đặt lại nhân vật", "Reset nhân vật về trạng thái ban đầu.", function()
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.Health = 0 end
end, 16)

createButton(PlayerPage, "Dịch chuyển về điểm hồi sinh", "Teleport nhân vật về SpawnLocation của game.", function()
	local spawn
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("SpawnLocation") then
			spawn = obj
			break
		end
	end

	refreshCharacter()
	if not root then
		showNotice("Chưa có nhân vật.", false)
		return
	end

	if spawn then
		root.CFrame = spawn.CFrame + Vector3.new(0, 4, 0)
	else
		root.CFrame = CFrame.new(0, 50, 0)
		showNotice("Không tìm thấy spawn, dùng mặc định.", true)
	end
end, 17)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Space and State.lying and lyingToggle then
		lyingToggle.Set(false)
	end
end)

local magicActive = false
local magicConnection = nil
local magicSavedCFrame = nil
local magicButton = nil
local magicSpeed = 1

local function stopMagicTeleport()
	magicActive = false
	if magicConnection then magicConnection:Disconnect() magicConnection = nil end
	if magicButton then magicButton:Destroy() magicButton = nil end

	local cam = workspace.CurrentCamera
	if cam then
		cam.CameraType = Enum.CameraType.Custom
		refreshCharacter()
		if humanoid then
			cam.CameraSubject = humanoid
		end
	end
	magicSavedCFrame = nil
end

local function startMagicTeleport()
	refreshCharacter()
	if not root or not humanoid then
		showNotice("Chưa có nhân vật.", false)
		return
	end

	local cam = workspace.CurrentCamera
	if not cam then return end

	magicActive = true
	magicSavedCFrame = cam.CFrame

	cam.CameraType = Enum.CameraType.Scriptable

	magicConnection = RunService.RenderStepped:Connect(function(dt)
		if not magicActive then return end

		local move = Vector3.zero
		local md = humanoid.MoveDirection
		if md.Magnitude > 0 then
			move = md
		else
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
		end

		local vert = 0
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vert = 1 end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vert = -1 end

		local vel = move + Vector3.yAxis * vert
		if vel.Magnitude > 0 then
			vel = vel.Unit * 80
		end

		local newPos = cam.CFrame.Position + vel * dt
		cam.CFrame = CFrame.new(newPos, newPos + cam.CFrame.LookVector)
	end)

	magicButton = Instance.new("TextButton")
	magicButton.Size = UDim2.fromOffset(56, 56)
	magicButton.Position = UDim2.new(0, 30, 0.5, -28)
	magicButton.BackgroundColor3 = Color3.fromRGB(150, 30, 200)
	magicButton.BorderSizePixel = 0
	magicButton.Text = "⚡"
	magicButton.TextSize = 24
	magicButton.TextColor3 = WHITE
	magicButton.Font = Enum.Font.GothamBold
	magicButton.AutoButtonColor = false
	magicButton.ZIndex = 300
	magicButton.Parent = ScreenGui
	addCorner(magicButton, 100)
	addStroke(magicButton, Color3.fromRGB(200, 100, 255), 0.2, 2)

	local magicDragging = false
	local magicDragOffset

	magicButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			magicDragging = true
			magicDragOffset = Vector2.new(input.Position.X, input.Position.Y) - magicButton.AbsolutePosition
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if magicDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local newPos = Vector2.new(input.Position.X, input.Position.Y) - magicDragOffset
			magicButton.Position = UDim2.fromOffset(newPos.X, newPos.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			magicDragging = false
		end
	end)

	magicButton.Activated:Connect(function()
		if not magicActive then return end
		local camPos = cam.CFrame.Position
		refreshCharacter()
		if root then
			root.CFrame = CFrame.new(camPos)
		end
		stopMagicTeleport()
		showNotice("Đã dịch chuyển!", true)
	end)
end

local magicToggle
magicToggle = createToggle(PlayerPage, "Dịch chuyển ảo thuật", "Tách camera khỏi nhân vật, di chuyển tới vị trí mong muốn rồi bấm nút tròn để teleport.", false, function(value)
	if value then
		startMagicTeleport()
	else
		stopMagicTeleport()
	end
end, 18)

createSection(VisualPage, "Visual", 1)

local AntiLag = {
	active = false,
	originals = {},
	connections = {},
	lightingBackup = nil,
	terrainBackup = nil,
	qualityBackup = nil,
	atmosphereBackup = nil,
	skyBackup = nil
}

local function backupLighting()
	if AntiLag.lightingBackup then return end
	AntiLag.lightingBackup = {
		Brightness = Lighting.Brightness,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		GlobalShadows = Lighting.GlobalShadows,
		FogEnd = Lighting.FogEnd,
		FogStart = Lighting.FogStart,
		EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
		EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
	}
end

local function restoreLighting()
	if not AntiLag.lightingBackup then return end
	for k, v in pairs(AntiLag.lightingBackup) do
		pcall(function() Lighting[k] = v end)
	end
	AntiLag.lightingBackup = nil
end

local function applyLighting()
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 1e6
	Lighting.FogStart = 1e6
	Lighting.Brightness = 2
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	pcall(function()
		Lighting.Ambient = Color3.fromRGB(180, 180, 180)
		Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
	end)

	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("PostEffect") then
			if not AntiLag.originals[effect] then
				AntiLag.originals[effect] = { Enabled = effect.Enabled, type_ = "PostEffect" }
			end
			pcall(function() effect.Enabled = false end)
		elseif effect:IsA("Atmosphere") then
			if not AntiLag.atmosphereBackup then
				AntiLag.atmosphereBackup = {
					obj = effect,
					Density = effect.Density,
					Haze = effect.Haze,
					Glare = effect.Glare
				}
			end
			pcall(function()
				effect.Density = 0
				effect.Haze = 0
				effect.Glare = 0
			end)
		elseif effect:IsA("Sky") then
			if not AntiLag.skyBackup then
				AntiLag.skyBackup = { obj = effect, parent = effect.Parent }
			end
			pcall(function() effect.Parent = nil end)
		end
	end
end

local function optimizeObject(obj)
	if not obj or not obj.Parent then return end
	if AntiLag.originals[obj] then return end

	if obj:IsA("MeshPart") then
		AntiLag.originals[obj] = {
			RenderFidelity = obj.RenderFidelity,
			CastShadow = obj.CastShadow,
			Material = obj.Material,
			Reflectance = obj.Reflectance,
			type_ = "MeshPart"
		}
		pcall(function()
			obj.RenderFidelity = Enum.RenderFidelity.Performance
			obj.CastShadow = false
			obj.Material = Enum.Material.SmoothPlastic
			obj.Reflectance = 0
		end)
	elseif obj:IsA("BasePart") then
		AntiLag.originals[obj] = {
			CastShadow = obj.CastShadow,
			Reflectance = obj.Reflectance,
			Material = obj.Material,
			type_ = "BasePart"
		}
		pcall(function()
			obj.CastShadow = false
			obj.Reflectance = 0
			if obj.Material ~= Enum.Material.SmoothPlastic then
				obj.Material = Enum.Material.SmoothPlastic
			end
		end)
	elseif obj:IsA("ParticleEmitter") then
		AntiLag.originals[obj] = { Rate = obj.Rate, Enabled = obj.Enabled, type_ = "ParticleEmitter" }
		pcall(function()
			obj.Rate = 0
			obj.Enabled = false
		end)
	elseif obj:IsA("Trail") then
		AntiLag.originals[obj] = { Enabled = obj.Enabled, type_ = "Trail" }
		pcall(function() obj.Enabled = false end)
	elseif obj:IsA("Beam") then
		AntiLag.originals[obj] = { Enabled = obj.Enabled, type_ = "Beam" }
		pcall(function() obj.Enabled = false end)
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		AntiLag.originals[obj] = { Transparency = obj.Transparency, type_ = "Decal" }
		pcall(function() obj.Transparency = 1 end)
	elseif obj:IsA("Light") then
		AntiLag.originals[obj] = { Enabled = obj.Enabled, type_ = "Light" }
		pcall(function() obj.Enabled = false end)
	elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
		AntiLag.originals[obj] = { Enabled = obj.Enabled, type_ = "Fire" }
		pcall(function() obj.Enabled = false end)
	end
end

local function startAntiLag()
	if AntiLag.active then return end
	AntiLag.active = true

	pcall(function()
		AntiLag.qualityBackup = settings().Rendering.QualityLevel
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	end)

	backupLighting()
	applyLighting()

	local terrain = workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		if not AntiLag.terrainBackup then
			AntiLag.terrainBackup = {
				WaterWaveSize = terrain.WaterWaveSize,
				WaterWaveSpeed = terrain.WaterWaveSpeed,
				WaterReflectance = terrain.WaterReflectance,
				WaterTransparency = terrain.WaterTransparency
			}
		end
		pcall(function()
			terrain.WaterWaveSize = 0
			terrain.WaterWaveSpeed = 0
			terrain.WaterReflectance = 0
			terrain.WaterTransparency = 1
		end)
	end

	task.spawn(function()
		local descendants = workspace:GetDescendants()
		for i = 1, #descendants do
			if not AntiLag.active then break end
			optimizeObject(descendants[i])
			if i % 200 == 0 then task.wait() end
		end
	end)

	local conn = workspace.DescendantAdded:Connect(function(obj)
		task.defer(function()
			if AntiLag.active then optimizeObject(obj) end
		end)
	end)
	table.insert(AntiLag.connections, conn)
end

local function stopAntiLag()
	AntiLag.active = false

	for _, conn in ipairs(AntiLag.connections) do
		pcall(function() conn:Disconnect() end)
	end
	AntiLag.connections = {}

	restoreLighting()

	pcall(function()
		if AntiLag.qualityBackup then
			settings().Rendering.QualityLevel = AntiLag.qualityBackup
			AntiLag.qualityBackup = nil
		end
	end)

	if AntiLag.atmosphereBackup and AntiLag.atmosphereBackup.obj then
		pcall(function()
			AntiLag.atmosphereBackup.obj.Density = AntiLag.atmosphereBackup.Density
			AntiLag.atmosphereBackup.obj.Haze = AntiLag.atmosphereBackup.Haze
			AntiLag.atmosphereBackup.obj.Glare = AntiLag.atmosphereBackup.Glare
		end)
	end

	if AntiLag.skyBackup and AntiLag.skyBackup.obj and AntiLag.skyBackup.parent then
		pcall(function() AntiLag.skyBackup.obj.Parent = AntiLag.skyBackup.parent end)
	end

	for obj, data in pairs(AntiLag.originals) do
		if obj and obj.Parent then
			pcall(function()
				if data.type_ == "PostEffect" then
					obj.Enabled = data.Enabled
				elseif data.type_ == "MeshPart" then
					obj.RenderFidelity = data.RenderFidelity
					obj.CastShadow = data.CastShadow
					obj.Material = data.Material
					obj.Reflectance = data.Reflectance
				elseif data.type_ == "BasePart" then
					obj.CastShadow = data.CastShadow
					obj.Reflectance = data.Reflectance
					obj.Material = data.Material
				elseif data.type_ == "ParticleEmitter" then
					obj.Rate = data.Rate
					obj.Enabled = data.Enabled
				elseif data.type_ == "Trail" or data.type_ == "Beam"
					or data.type_ == "Light" or data.type_ == "Fire" then
					obj.Enabled = data.Enabled
				elseif data.type_ == "Decal" then
					obj.Transparency = data.Transparency
				end
			end)
		end
	end

	local terrain = workspace:FindFirstChildOfClass("Terrain")
	if terrain and AntiLag.terrainBackup then
		pcall(function()
			terrain.WaterWaveSize = AntiLag.terrainBackup.WaterWaveSize
			terrain.WaterWaveSpeed = AntiLag.terrainBackup.WaterWaveSpeed
			terrain.WaterReflectance = AntiLag.terrainBackup.WaterReflectance
			terrain.WaterTransparency = AntiLag.terrainBackup.WaterTransparency
		end)
		AntiLag.terrainBackup = nil
	end
end

createToggle(VisualPage, "Giảm lag", "Hạ đồ họa mạnh (SmoothPlastic, tắt đèn, decal, sky, atmosphere).", false, function(value)
	State.antiLag = value
	if value then startAntiLag() else stopAntiLag() end
end, 2)

local whiteOverlay = Instance.new("Frame")
whiteOverlay.Size = UDim2.fromScale(1, 1)
whiteOverlay.BackgroundColor3 = Color3.new(1, 1, 1)
whiteOverlay.BorderSizePixel = 0
whiteOverlay.Visible = false
whiteOverlay.ZIndex = 50000
whiteOverlay.Active = true
whiteOverlay.Parent = ScreenGui

local blackOverlay = Instance.new("Frame")
blackOverlay.Size = UDim2.fromScale(1, 1)
blackOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
blackOverlay.BorderSizePixel = 0
blackOverlay.Visible = false
blackOverlay.ZIndex = 50000
blackOverlay.Active = true
blackOverlay.Parent = ScreenGui

createToggle(VisualPage, "Màn hình trắng", "Che toàn màn hình màu trắng (treo game).", false, function(value)
	whiteOverlay.Visible = value
end, 3)

createToggle(VisualPage, "Màn hình đen", "Che toàn màn hình màu đen (treo game).", false, function(value)
	blackOverlay.Visible = value
end, 4)

local freeCamActive = false
local freeCamConnection = nil
local freeCamSavedSubject = nil

local function stopFreeCam()
	freeCamActive = false
	if freeCamConnection then freeCamConnection:Disconnect() freeCamConnection = nil end
	local cam = workspace.CurrentCamera
	if cam then
		cam.CameraType = Enum.CameraType.Custom
		refreshCharacter()
		if humanoid then
			cam.CameraSubject = humanoid
		end
	end
end

local function startFreeCam()
	local cam = workspace.CurrentCamera
	if not cam then return end

	freeCamActive = true
	freeCamSavedSubject = cam.CameraSubject

	cam.CameraType = Enum.CameraType.Scriptable

	freeCamConnection = RunService.RenderStepped:Connect(function(dt)
		if not freeCamActive then return end

		local move = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end

		local speed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 200 or 80
		local newPos = cam.CFrame.Position + move.Unit * speed * dt * (move.Magnitude > 0 and 1 or 0)
		if move.Magnitude > 0 then
			cam.CFrame = CFrame.new(newPos, newPos + cam.CFrame.LookVector)
		end
	end)
end

createToggle(VisualPage, "Xem từ xa", "Tách camera ra khỏi nhân vật, dùng WASD + Space/Ctrl để di chuyển tự do.", false, function(value)
	if value then startFreeCam() else stopFreeCam() end
end, 5)

createSection(VisualPage, "Hiệu ứng", 6)

local poseConnection = nil
local poseName = nil

local function resetPose()
	if poseConnection then poseConnection:Disconnect() poseConnection = nil end
	refreshCharacter()
	if not character then poseName = nil return end

	if humanoid then
		pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
	end
	local animate = character:FindFirstChild("Animate")
	if animate then
		pcall(function() animate.Disabled = false end)
	end

	local function resetMotor(m)
		if m:IsA("Motor6D") or m:IsA("Motor") then
			if m.Name == "Right Shoulder" then
				m.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0)
			elseif m.Name == "Left Shoulder" then
				m.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
			end
		end
	end

	for _, obj in ipairs(character:GetDescendants()) do
		resetMotor(obj)
	end
	if character:FindFirstChild("UpperTorso") then
		for _, obj in ipairs(character.UpperTorso:GetChildren()) do
			if obj:IsA("Motor6D") and (obj.Name == "RightShoulder" or obj.Name == "LeftShoulder") then
				if obj.Name == "RightShoulder" then
					obj.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0)
				elseif obj.Name == "LeftShoulder" then
					obj.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
				end
			end
		end
	end

	poseName = nil
end

local function applyPose(poseId)
	resetPose()
	refreshCharacter()
	if not character or not humanoid then return end

	local animate = character:FindFirstChild("Animate")
	if animate then
		pcall(function() animate.Disabled = true end)
	end

	poseName = poseId

	local function applyMotor(m)
		if not (m:IsA("Motor6D") or m:IsA("Motor")) then return end
		if m.Name == "Right Shoulder" or m.Name == "RightShoulder" then
			if poseId == "void" then
				m.C0 = CFrame.new(0.9, 0.7, 0.2) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-40))
			elseif poseId == "shrine" then
				m.C0 = CFrame.new(0.3, 0.4, -0.4) * CFrame.Angles(math.rad(-90), math.rad(-20), math.rad(-30))
			end
		elseif m.Name == "Left Shoulder" or m.Name == "LeftShoulder" then
			if poseId == "void" then
				m.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
			elseif poseId == "shrine" then
				m.C0 = CFrame.new(-0.3, 0.4, -0.4) * CFrame.Angles(math.rad(-90), math.rad(20), math.rad(30))
			end
		end
	end

	for _, obj in ipairs(character:GetDescendants()) do
		applyMotor(obj)
	end
	if character:FindFirstChild("UpperTorso") then
		for _, obj in ipairs(character.UpperTorso:GetChildren()) do
			if obj:IsA("Motor6D") then applyMotor(obj) end
		end
	end

	poseConnection = RunService.RenderStepped:Connect(function()
		if not character or not character.Parent then return end
		for _, obj in ipairs(character:GetDescendants()) do
			applyMotor(obj)
		end
		if character:FindFirstChild("UpperTorso") then
			for _, obj in ipairs(character.UpperTorso:GetChildren()) do
				if obj:IsA("Motor6D") then applyMotor(obj) end
			end
		end
	end)
end

createButton(VisualPage, "Vô Lượng Không Xứ", "Tay phải giơ lên gần mặt (Gojo).", function()
	applyPose("void")
	showNotice("Đã kích hoạt Vô Lượng Không Xứ", true)
end, 7)

createButton(VisualPage, "Phục Ma Ngự Trù Tử", "Hai tay chắp trước ngực (Sukuna).", function()
	applyPose("shrine")
	showNotice("Đã kích hoạt Phục Ma Ngự Trù Tử", true)
end, 8)

createButton(VisualPage, "Tắt hiệu ứng", "Trở về tư thế bình thường.", function()
	resetPose()
	showNotice("Đã tắt hiệu ứng.", true)
end, 9)

createSection(ServerPage, "Server", 1)

local autoRun = false

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

local function queueScript()
	if not autoRun then return end
	if AUTORUN_URL == "" then return end
	local source = "loadstring(game:HttpGet('" .. AUTORUN_URL .. "'))()"
	pcall(function()
		if type(queue_on_teleport) == "function" then
			queue_on_teleport(source)
		elseif type(syn) == "table" and type(syn.queue_on_teleport) == "function" then
			syn.queue_on_teleport(source)
		end
	end)
end

local function hopToServer(targetJobId)
	queueScript()
	local ok, err = pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId, LocalPlayer)
	end)
	if not ok then
		showNotice("Teleport thất bại: " .. tostring(err), false)
	end
end

createButton(ServerPage, "Đổi máy chủ", "Nhảy sang một server khác cùng place.", function()
	local servers = nil
	fetchServers(game.PlaceId, function(data) servers = data end)
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
	fetchServers(game.PlaceId, function(data) servers = data end)
	task.wait(1.5)

	if not servers or #servers == 0 then
		showNotice("Không lấy được danh sách server.", false)
		return
	end

	local currentJob = game.JobId
	local best, bestCount = nil, math.huge
	for _, s in ipairs(servers) do
		local count = s.playing or 0
		if s.id ~= currentJob and count < bestCount and count < (s.maxPlayers or 999) then
			best, bestCount = s, count
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
		showNotice("Không có JobId hợp lệ.", false)
		return
	end
	queueScript()
	local ok = pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
	end)
	if not ok then
		showNotice("Không thể teleport tới instance hiện tại.", false)
	end
end, 4)

createToggle(ServerPage, "Tự động chạy lại script", "Tự chạy lại sau khi đổi server (cần URL + executor hỗ trợ queue_on_teleport).", false, function(value)
	autoRun = value
	if not value then
		showNotice("Đã tắt tự động chạy lại.", true)
		return
	end

	if AUTORUN_URL == "" then
		showNotice("Cần điền AUTORUN_URL ở đầu script.", false)
		return
	end

	local hasQueue = false
	pcall(function()
		if type(queue_on_teleport) == "function" then hasQueue = true end
		if type(syn) == "table" and type(syn.queue_on_teleport) == "function" then hasQueue = true end
	end)

	if hasQueue then
		showNotice("Đã bật. Script sẽ tự chạy lại sau khi đổi server.", true)
	else
		showNotice("Executor không hỗ trợ queue_on_teleport.", false)
	end
end, 5)

createButton(ServerPage, "Lấy ID map này", "Hiện PlaceId và link map, kèm nút Copy.", function()
	local placeId = game.PlaceId
	local info = "PlaceID: " .. tostring(placeId)
		.. "\n\nLink: https://www.roblox.com/games/" .. tostring(placeId)
	showCopyPopup("Thông tin Map", info)
end, 6)

createButton(ServerPage, "Lấy JobID + script vào map", "Hiện JobID và script teleport vào map hiện tại.", function()
	local jobId = game.JobId
	local placeId = game.PlaceId

	if jobId == "" then
		showNotice("Không có JobID (có thể đang ở Studio).", false)
		return
	end

	local script = string.format(
		"game:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s', game.Players.LocalPlayer)",
		placeId, jobId
	)

	local info = "JobID: " .. jobId
		.. "\nPlaceID: " .. tostring(placeId)
		.. "\n\nScript teleport:\n" .. script

	showCopyPopup("JobID và Script", info)
end, 7)

local FloatGui = Instance.new("ScreenGui")
FloatGui.Name = GUI_NAME .. "_Float"
FloatGui.ResetOnSpawn = false
FloatGui.IgnoreGuiInset = true
FloatGui.DisplayOrder = 2000000
FloatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FloatGui.Parent = PlayerGui

local FloatingButton = Instance.new("TextButton")
FloatingButton.AnchorPoint = Vector2.new(1, 0)
FloatingButton.Position = UDim2.new(1, -20, 0, 100)
FloatingButton.Size = UDim2.fromOffset(50, 50)
FloatingButton.BackgroundColor3 = BLUE_4
FloatingButton.BorderSizePixel = 0
FloatingButton.Text = "T"
FloatingButton.TextSize = 20
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.TextColor3 = WHITE
FloatingButton.AutoButtonColor = false
FloatingButton.Visible = true
FloatingButton.ZIndex = 10
FloatingButton.Parent = FloatGui
addCorner(FloatingButton, 100)
addStroke(FloatingButton, BLUE_5, 0.2, 2)

local FloatingGlow = Instance.new("Frame")
FloatingGlow.AnchorPoint = Vector2.new(0.5, 0.5)
FloatingGlow.Position = UDim2.fromScale(0.5, 0.5)
FloatingGlow.Size = UDim2.fromScale(0.75, 0.75)
FloatingGlow.BackgroundColor3 = BLUE_5
FloatingGlow.BackgroundTransparency = 0.8
FloatingGlow.BorderSizePixel = 0
FloatingGlow.Active = false
FloatingGlow.ZIndex = 11
FloatingGlow.Parent = FloatingButton
addCorner(FloatingGlow, 100)

FloatingButton.MouseEnter:Connect(function()
	tween(FloatingButton, 0.12, {Size = UDim2.fromOffset(56, 56), BackgroundColor3 = BLUE_5})
end)
FloatingButton.MouseLeave:Connect(function()
	tween(FloatingButton, 0.12, {Size = UDim2.fromOffset(50, 50), BackgroundColor3 = BLUE_4})
end)

local originalSize = UDim2.fromOffset(MAIN_WIDTH, MAIN_HEIGHT)
local minimized = false
local maximized = false
local menuOpen = true

local function resizeKeepingTopLeft(newSize)
	local cam = workspace.CurrentCamera
	if not cam then
		Main.Size = newSize
		return
	end
	local vp = cam.ViewportSize
	local oldX = Main.AbsolutePosition.X
	local oldY = Main.AbsolutePosition.Y

	Main.Size = newSize

	task.defer(function()
		local ns = Main.AbsoluteSize
		local newX = math.clamp(oldX, 0, math.max(0, vp.X - ns.X))
		local newY = math.clamp(oldY, 0, math.max(0, vp.Y - ns.Y))
		Main.Position = UDim2.fromOffset(newX, newY)
	end)
end

local function setMenuVisible(value)
	menuOpen = value
	Main.Visible = value
end

FloatingButton.Activated:Connect(function()
	setMenuVisible(not menuOpen)
end)

MinimizeButton.Activated:Connect(function()
	if maximized then maximized = false end
	minimized = not minimized
	if minimized then
		Sidebar.Visible = false
		Content.Visible = false
		resizeKeepingTopLeft(UDim2.fromOffset(MAIN_WIDTH, MAIN_MIN_HEIGHT))
		MenuSubtitle.Text = "Đã thu nhỏ"
	else
		Sidebar.Visible = true
		Content.Visible = true
		resizeKeepingTopLeft(originalSize)
		MenuSubtitle.Text = "Build " .. SCRIPT_BUILD
	end
end)

MaximizeButton.Activated:Connect(function()
	if minimized then
		minimized = false
		Sidebar.Visible = true
		Content.Visible = true
	end
	maximized = not maximized
	resizeKeepingTopLeft(maximized and UDim2.fromOffset(820, 520) or originalSize)
end)

CloseButton.Activated:Connect(function()
	setMenuVisible(false)
end)

local dragging = false
local dragStartPos
local dragStartMouse

local function beginDrag(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStartPos = Vector2.new(Main.AbsolutePosition.X, Main.AbsolutePosition.Y)
		dragStartMouse = Vector2.new(input.Position.X, input.Position.Y)
	end
end

Header.InputBegan:Connect(beginDrag)
MenuTitle.InputBegan:Connect(beginDrag)
MenuSubtitle.InputBegan:Connect(beginDrag)
HeaderLine.InputBegan:Connect(beginDrag)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
		local cam = workspace.CurrentCamera
		if not cam then return end
		local vp = cam.ViewportSize
		local size = Main.AbsoluteSize
		local dx = input.Position.X - dragStartMouse.X
		local dy = input.Position.Y - dragStartMouse.Y
		local newX = math.clamp(dragStartPos.X + dx, 0, math.max(0, vp.X - size.X))
		local newY = math.clamp(dragStartPos.Y + dy, 0, math.max(0, vp.Y - size.Y))
		Main.Position = UDim2.fromOffset(newX, newY)
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

	if State.fly then stopFly() startFly() end
	if State.esp then task.defer(startESP) end
	if State.antiLag then
		task.delay(1, function()
			if State.antiLag then startAntiLag() end
		end)
	end
	if magicToggle and magicToggle.Get() then
		stopMagicTeleport()
		task.delay(0.5, function()
			magicToggle.SetSilent(false)
		end)
	end
	if poseName then
		task.delay(0.3, function()
			applyPose(poseName)
		end)
	end
end)

task.spawn(function()
	while ScreenGui.Parent do
		if State.sitting and humanoid and humanoid.Health > 0 then
			humanoid.Sit = true
		end
		if State.speed and humanoid and not State.fly then
			humanoid.WalkSpeed = State.walkSpeed
		end
		if State.jump and humanoid and not State.fly then
			humanoid.UseJumpPower = true
			humanoid.JumpPower = State.jumpPower
		end
		task.wait(0.3)
	end
end)

print("[ThoScript] Loaded build " .. SCRIPT_BUILD)
