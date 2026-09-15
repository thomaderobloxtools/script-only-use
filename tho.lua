-- [ThoScript] BUILD: 2026-09-15 #20
-- - Fix vùng an toàn: giảm 150 -> 60 studs, không bay quá cao
-- - Di chuyển magic teleport lên trên section "Khác"
-- - Thêm 3 shader: Bản đồ sáng, Bản đồ mưa, Bản đồ thư giãn (click 2 lần để toggle)
local SCRIPT_BUILD = "2026-09-15-#20"
local AUTORUN_URL = "https://raw.githubusercontent.com/thomaderobloxtools/script-only-use/main/tho.lua"
local SAVE_FILE = "tho_script_settings.json"

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

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
createTab("ESP", 3)
createTab("Visual", 4)
createTab("Server", 5)
createTab("Settings", 6)

local PlayerPage = createPage("Player")
local ESPPage = createPage("ESP")
local VisualPage = createPage("Visual")
local ServerPage = createPage("Server")
local SettingsPage = createPage("Settings")

-- ============================================================
-- NOTIFICATION (ngoài menu, góc phải)
-- ============================================================
local NOTICE_Z = 999999

local function showNotice(text, success)
	local notice = Instance.new("Frame")
	notice.AnchorPoint = Vector2.new(1, 0)
	notice.Position = UDim2.new(1, 320, 0, 12)
	notice.Size = UDim2.fromOffset(280, 50)
	notice.BackgroundColor3 = success and Color3.fromRGB(10, 67, 59) or Color3.fromRGB(67, 29, 39)
	notice.BorderSizePixel = 0
	notice.ZIndex = NOTICE_Z
	notice.Active = false
	notice.Parent = ScreenGui
	addCorner(notice, 10)
	addStroke(notice, success and GREEN or RED, 0.2, 2)

	local icon = addText(notice, success and "✓" or "✕", 20, Enum.Font.GothamBold, success and GREEN or RED)
	icon.Position = UDim2.fromOffset(8, 0)
	icon.Size = UDim2.fromOffset(28, 50)
	icon.TextXAlignment = Enum.TextXAlignment.Center
	icon.TextYAlignment = Enum.TextYAlignment.Center
	icon.ZIndex = NOTICE_Z + 1

	local label = addText(notice, text, 11, Enum.Font.GothamSemibold, WHITE)
	label.Position = UDim2.fromOffset(40, 0)
	label.Size = UDim2.new(1, -50, 1, 0)
	label.TextWrapped = true
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.ZIndex = NOTICE_Z + 1

	tween(notice, 0.28, {Position = UDim2.new(1, -16, 0, 12)})

	task.delay(2.4, function()
		if notice.Parent then
			tween(notice, 0.22, {Position = UDim2.new(1, 320, 0, 12)})
			task.wait(0.3)
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

local TOGGLE_REGISTRY = {}

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

		if callback and notify ~= false then
			local ok, err = pcall(callback, state)
			if not ok then warn("[ThoScript] Toggle error:", err) end
		end

		task.delay(0.05, function() busy = false end)
	end

	track.Activated:Connect(function() setState(not state) end)
	setState(state, false)

	local obj = {
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
		end,
		Title = title
	}
	TOGGLE_REGISTRY[title] = obj
	return obj
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
		if callback then
			local ok, err = pcall(callback)
			if not ok then warn("[ThoScript] Button error:", err) end
		end
	end)

	return button
end

-- Button đổi màu khi active (dùng cho shader button)
local function createStateButton(parent, title, description, onActivate, onDeactivate, order)
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
	button.Text = "BẬT"
	button.TextSize = 9
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = WHITE
	button.AutoButtonColor = false
	button.Parent = row
	addCorner(button, 6)

	local active = false

	button.MouseEnter:Connect(function()
		tween(button, 0.12, {BackgroundColor3 = active and Color3.fromRGB(200, 60, 60) or BLUE_4})
	end)
	button.MouseLeave:Connect(function()
		tween(button, 0.12, {BackgroundColor3 = active and Color3.fromRGB(180, 50, 50) or BLUE_3})
	end)

	button.Activated:Connect(function()
		active = not active

		if active then
			button.Text = "TẮT"
			button.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
			if onActivate then
				local ok, err = pcall(onActivate)
				if not ok then warn("[ThoScript] StateButton activate error:", err) end
			end
		else
			button.Text = "BẬT"
			button.BackgroundColor3 = BLUE_3
			if onDeactivate then
				local ok, err = pcall(onDeactivate)
				if not ok then warn("[ThoScript] StateButton deactivate error:", err) end
			end
		end

		tween(button, 0.07, {Size = UDim2.fromOffset(80, 26)})
		task.delay(0.07, function()
			if button.Parent then
				tween(button, 0.1, {Size = UDim2.fromOffset(84, 28)})
			end
		end)
	end)

	return button
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
	titleLabel.Size = UDim2.new(1, -120, 0, 18)

	local valueLabel = addText(row, tostring(defaultValue), 11, Enum.Font.GothamBold, BLUE_5)
	valueLabel.Position = UDim2.new(1, -90, 0, 6)
	valueLabel.Size = UDim2.fromOffset(40, 18)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right

	local lockBtn = Instance.new("TextButton")
	lockBtn.AnchorPoint = Vector2.new(1, 0)
	lockBtn.Position = UDim2.new(1, -8, 0, 4)
	lockBtn.Size = UDim2.fromOffset(24, 24)
	lockBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	lockBtn.BorderSizePixel = 0
	lockBtn.Text = "🔓"
	lockBtn.TextSize = 14
	lockBtn.Font = Enum.Font.GothamBold
	lockBtn.TextColor3 = WHITE
	lockBtn.AutoButtonColor = false
	lockBtn.ZIndex = 11
	lockBtn.Parent = row
	addCorner(lockBtn, 6)
	addStroke(lockBtn, Color3.fromRGB(80, 80, 120), 0.5, 1)

	local locked = false
	lockBtn.Activated:Connect(function()
		locked = not locked
		if locked then
			lockBtn.Text = "🔒"
			lockBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
		else
			lockBtn.Text = "🔓"
			lockBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
		end
	end)

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
		if locked then return end
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
			if locked then return end
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

-- ============================================================
-- PLAYER STATE
-- ============================================================
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
	espPro = false,
	espNPC = false,
	espTeam = false,
	antiLag = false,
	safeZone = false,
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

createSection(PlayerPage, "Player", 1)

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

	airPlatform = Instance.new("Part")
	airPlatform.Name = "_ThoAirWalk"
	airPlatform.Size = Vector3.new(14, 1, 14)
	airPlatform.Transparency = 0.75
	airPlatform.Color = Color3.fromRGB(100, 200, 255)
	airPlatform.Material = Enum.Material.SmoothPlastic
	airPlatform.CanCollide = true
	airPlatform.Anchored = true
	airPlatform.CFrame = CFrame.new(root.Position.X, root.Position.Y - 3.2, root.Position.Z)
	airPlatform.Parent = workspace

	airConnection = RunService.Heartbeat:Connect(function()
		if not airActive or not root or not root.Parent or not airPlatform then return end
		airPlatform.CFrame = CFrame.new(root.Position - Vector3.new(0, 3.2, 0))
	end)
end

createToggle(PlayerPage, "Đi trên không", "Tạo bệ đỡ di chuyển theo nhân vật, nhảy được trên không.", false, function(value)
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

-- ============================================================
-- SAFE ZONE (build #20 - giảm 150 -> 60 studs)
-- ============================================================
local safeZoneActive = false
local safeZoneSavedPos = nil
local safeZoneBP = nil
local safeZoneLoopThread = nil

local SAFE_HEIGHT_OFFSET = 60

local function getSafeHeight()
	refreshCharacter()
	if not root then return nil end
	local pos = root.Position
	local maxY = pos.Y

	for _, radius in ipairs({80, 200, 400}) do
		local ok, parts = pcall(function()
			return workspace:GetPartBoundsInBox(
				CFrame.new(pos.X, pos.Y + 100, pos.Z),
				Vector3.new(radius * 2, 300, radius * 2)
			)
		end)
		if ok and parts then
			for _, p in ipairs(parts) do
				if p.Anchored and p.CanCollide and p.Name ~= "_ThoAirWalk" then
					local top = p.Position.Y + p.Size.Y * 0.5
					if top > maxY then maxY = top end
				end
			end
		end
	end

	return maxY
end

local function stopSafeZone(teleportBack)
	safeZoneActive = false

	if safeZoneLoopThread then
		pcall(function() task.cancel(safeZoneLoopThread) end)
		safeZoneLoopThread = nil
	end

	if safeZoneBP then
		safeZoneBP:Destroy()
		safeZoneBP = nil
	end

	if teleportBack and safeZoneSavedPos then
		refreshCharacter()
		if root then
			root.CFrame = CFrame.new(safeZoneSavedPos + Vector3.new(0, 5, 0))
			pcall(function()
				root.AssemblyLinearVelocity = Vector3.zero
			end)
		end
	end

	safeZoneSavedPos = nil
end

local function startSafeZone()
	refreshCharacter()
	if not root then
		showNotice("Chưa có nhân vật.", false)
		return
	end

	safeZoneSavedPos = root.Position
	safeZoneActive = true

	if safeZoneLoopThread then
		pcall(function() task.cancel(safeZoneLoopThread) end)
		safeZoneLoopThread = nil
	end

	safeZoneLoopThread = task.spawn(function()
		task.wait(3)

		while safeZoneActive do
			refreshCharacter()

			if root and humanoid and humanoid.Health > 0 then
				local highestY = getSafeHeight() or root.Position.Y
				local targetY = highestY + SAFE_HEIGHT_OFFSET

				if not safeZoneBP or not safeZoneBP.Parent then
					safeZoneBP = Instance.new("BodyPosition")
					safeZoneBP.MaxForce = Vector3.new(1e9, 1e9, 1e9)
					safeZoneBP.P = 1e5
					safeZoneBP.D = 1000
					safeZoneBP.Parent = root
				end

				safeZoneBP.Position = Vector3.new(root.Position.X, targetY, root.Position.Z)

				pcall(function()
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
				end)
			else
				if safeZoneBP then
					safeZoneBP:Destroy()
					safeZoneBP = nil
				end
			end

			task.wait(0.4)
		end
	end)

	showNotice("Vùng an toàn đang bật (cách mặt đất " .. SAFE_HEIGHT_OFFSET .. " studs).", true)
end

createToggle(PlayerPage, "Tự động di chuyển tới vùng an toàn", "Bay 60 studs trên map, tự theo dõi khi map đổi. Bật để treo AFK.", false, function(value)
	State.safeZone = value
	if value then
		startSafeZone()
	else
		stopSafeZone(true)
	end
end, 14)

createButton(PlayerPage, "Di chuyển xuống lại mặt đất", "Quay về vị trí ban đầu trước khi bật vùng an toàn.", function()
	if safeZoneSavedPos then
		stopSafeZone(true)
		local t = TOGGLE_REGISTRY["Tự động di chuyển tới vùng an toàn"]
		if t then t.SetSilent(false) end
		State.safeZone = false
		showNotice("Đã trở về mặt đất.", true)
	else
		showNotice("Không có vị trí nào đã lưu.", false)
	end
end, 15)

-- ============================================================
-- MAGIC TELEPORT (order 16 - ngay dưới safe zone, trên "Khác")
-- ============================================================
local magicActive = false
local magicSplit = false
local freeCamActive = false
local magicButton = nil
local magicSavedWalk, magicSavedJump
local magicRenderName = "ThoMagicCam"
local freeCamRenderName = "ThoFreeCam"
local camYaw = 0
local camPitch = 0
local freeCamSavedWalk, freeCamSavedJump

local function getCamRot()
	return CFrame.fromEulerAnglesYXZ(math.rad(camPitch), math.rad(camYaw), 0)
end

local function getMoveInput()
	local rot = getCamRot()
	local look = rot.LookVector
	local right = rot.RightVector
	local move = Vector3.zero

	if humanoid then
		local md = humanoid.MoveDirection
		if md.Magnitude > 0 then
			local u = md.Unit
			local f = u:Dot(look)
			local r = u:Dot(right)
			move += look * f + right * r
		end
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += look end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= look end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += right end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= right end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end

	if move.Magnitude > 1 then
		move = move.Unit
	end
	return move
end

local function startMagicMode()
	refreshCharacter()
	if not root or not humanoid then
		showNotice("Chưa có nhân vật.", false)
		return false
	end
	magicSavedWalk = humanoid.WalkSpeed
	magicSavedJump = humanoid.JumpPower
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	return true
end

local function endMagicMode()
	refreshCharacter()
	if humanoid then
		humanoid.WalkSpeed = magicSavedWalk or 16
		humanoid.JumpPower = magicSavedJump or 50
	end
end

local function renderMagic(dt)
	if not magicSplit then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	cam.CameraType = Enum.CameraType.Scriptable

	local rot = getCamRot()
	local move = getMoveInput()
	local speed = 80
	local newPos = cam.CFrame.Position + move * speed * dt
	cam.CFrame = CFrame.new(newPos) * rot
end

local function splitCamera()
	local cam = workspace.CurrentCamera
	if not cam then return end
	magicSplit = true
	cam.CameraType = Enum.CameraType.Scriptable

	local look = cam.CFrame.LookVector
	camYaw = math.deg(math.atan2(-look.X, -look.Z))
	camPitch = math.deg(math.asin(math.clamp(look.Y, -1, 1)))

	pcall(function()
		RunService:UnbindFromRenderStep(magicRenderName)
	end)
	RunService:BindToRenderStep(magicRenderName, Enum.RenderPriority.Camera.Value + 10, renderMagic)

	if magicButton then
		magicButton.Text = "TP"
		magicButton.BackgroundColor3 = Color3.fromRGB(255, 100, 30)
	end
end

local function mergeCamera()
	local cam = workspace.CurrentCamera
	if not cam then return end
	local camPos = cam.CFrame.Position

	pcall(function()
		RunService:UnbindFromRenderStep(magicRenderName)
	end)

	refreshCharacter()
	if root then
		root.CFrame = CFrame.new(camPos + Vector3.new(0, 3, 0))
	end

	cam.CameraType = Enum.CameraType.Custom
	refreshCharacter()
	if humanoid then
		cam.CameraSubject = humanoid
	end

	magicSplit = false

	if magicButton then
		magicButton.Text = "CAM"
		magicButton.BackgroundColor3 = Color3.fromRGB(150, 30, 200)
	end
end

local function stopMagicTeleport()
	magicActive = false
	magicSplit = false

	pcall(function()
		RunService:UnbindFromRenderStep(magicRenderName)
	end)

	if magicButton then
		magicButton:Destroy()
		magicButton = nil
	end
	endMagicMode()

	local cam = workspace.CurrentCamera
	if cam then
		cam.CameraType = Enum.CameraType.Custom
		refreshCharacter()
		if humanoid then
			cam.CameraSubject = humanoid
		end
	end
end

local function startMagicTeleport()
	if not startMagicMode() then return end
	magicActive = true

	magicButton = Instance.new("TextButton")
	magicButton.Size = UDim2.fromOffset(64, 64)
	magicButton.Position = UDim2.new(0, 30, 0.5, -32)
	magicButton.BackgroundColor3 = Color3.fromRGB(150, 30, 200)
	magicButton.BorderSizePixel = 0
	magicButton.Text = "CAM"
	magicButton.TextSize = 16
	magicButton.TextColor3 = WHITE
	magicButton.Font = Enum.Font.GothamBold
	magicButton.AutoButtonColor = false
	magicButton.ZIndex = 300
	magicButton.Parent = ScreenGui
	addCorner(magicButton, 100)

	local stroke = addStroke(magicButton, Color3.fromRGB(0, 170, 255), 0, 6)
	local strokeGrad = Instance.new("UIGradient")
	strokeGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
		ColorSequenceKeypoint.new(0.25, Color3.fromRGB(0, 255, 200)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 150, 255)),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 255))
	})
	strokeGrad.Parent = stroke

	local dragging2 = false
	local dragOffset
	local moved = false
	local pressTime = 0

	magicButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging2 = true
			moved = false
			pressTime = tick()
			dragOffset = Vector2.new(input.Position.X, input.Position.Y) - magicButton.AbsolutePosition
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging2 and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local newPos = Vector2.new(input.Position.X, input.Position.Y) - dragOffset
			if (newPos - magicButton.AbsolutePosition).Magnitude > 8 then
				moved = true
			end
			magicButton.Position = UDim2.fromOffset(newPos.X, newPos.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			if dragging2 and not moved and (tick() - pressTime) < 0.5 then
				if magicSplit then
					mergeCamera()
					showNotice("Đã dịch chuyển!", true)
				else
					splitCamera()
					showNotice("Bấm lần nữa để teleport.", true)
				end
			end
			dragging2 = false
		end
	end)
end

local magicToggle
magicToggle = createToggle(PlayerPage, "Dịch chuyển ảo thuật", "Bấm CAM để tách camera, bấm TP để teleport. Chuột/ngón để xoay.", false, function(value)
	if value then
		startMagicTeleport()
	else
		stopMagicTeleport()
	end
end, 16)

-- "Khác" section (order 26 - dưới magic)
createSection(PlayerPage, "Khác", 26)

createButton(PlayerPage, "Đặt lại nhân vật", "Reset nhân vật về trạng thái ban đầu.", function()
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.Health = 0 end
end, 27)

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
end, 28)

-- ============================================================
-- ESP TAB
-- ============================================================
createSection(ESPPage, "Người chơi", 1)

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

createToggle(ESPPage, "Định vị người chơi", "Hiển thị khung, tên, máu và khoảng cách.", false, function(value)
	State.esp = value
	if value then startESP() else stopESP() end
end, 2)

local ESPPro = {
	active = false,
	folder = nil,
	topFrame = nil,
	topLabel = nil,
	players = {},
	indicators = {},
	bindName = "ThoESPProUpdate"
}

local function worldToViewport(pos)
	local cam = workspace.CurrentCamera
	if not cam then return Vector2.new(0, 0), false end
	local sp, onScreen = cam:WorldToViewportPoint(pos)
	if not onScreen or sp.Z <= 0 then
		return Vector2.new(sp.X, sp.Y), false
	end
	local vp = cam.ViewportSize
	if sp.X < 0 or sp.X > vp.X or sp.Y < 0 or sp.Y > vp.Y then
		return Vector2.new(sp.X, sp.Y), false
	end
	return Vector2.new(sp.X, sp.Y), true
end

local function createSkeleton(player)
	if ESPPro.players[player] then return end

	local gui = Instance.new("Frame")
	gui.BackgroundTransparency = 1
	gui.Size = UDim2.fromScale(1, 1)
	gui.ZIndex = 45000
	gui.Parent = ESPPro.folder

	local lines = {}
	for i = 1, 5 do
		local line = Instance.new("Frame")
		line.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
		line.BorderSizePixel = 0
		line.ZIndex = 45001
		line.Visible = false
		line.Parent = gui

		local head = Instance.new("Frame")
		head.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
		head.BorderSizePixel = 0
		head.ZIndex = 45001
		head.Visible = false
		head.Parent = gui

		lines[i] = { line = line, head = head }
	end

	ESPPro.players[player] = {
		gui = gui,
		lines = lines
	}
end

local function destroySkeleton(player)
	local d = ESPPro.players[player]
	if not d then return end
	if d.gui then d.gui:Destroy() end
	ESPPro.players[player] = nil

	local ind = ESPPro.indicators[player]
	if ind then
		ind:Destroy()
		ESPPro.indicators[player] = nil
	end
end

local function drawLine(l, a, b)
	local diff = b - a
	local dist = diff.Magnitude
	if dist <= 0 then l.Visible = false return end
	local center = (a + b) * 0.5
	local angle = math.deg(math.atan2(diff.Y, diff.X))
	l.Size = UDim2.fromOffset(dist, 2)
	l.Position = UDim2.fromOffset(center.X, center.Y)
	l.AnchorPoint = Vector2.new(0.5, 0.5)
	l.Rotation = angle
	l.Visible = true
end

local function updateSkeleton(player, targetCharacter)
	createSkeleton(player)
	local data = ESPPro.players[player]
	if not data then return end

	local parts = {
		Head = targetCharacter:FindFirstChild("Head"),
		Torso = targetCharacter:FindFirstChild("UpperTorso") or targetCharacter:FindFirstChild("Torso"),
		LeftArm = targetCharacter:FindFirstChild("LeftUpperArm") or targetCharacter:FindFirstChild("Left Arm"),
		RightArm = targetCharacter:FindFirstChild("RightUpperArm") or targetCharacter:FindFirstChild("Right Arm"),
		LeftLeg = targetCharacter:FindFirstChild("LeftUpperLeg") or targetCharacter:FindFirstChild("Left Leg"),
		RightLeg = targetCharacter:FindFirstChild("RightUpperLeg") or targetCharacter:FindFirstChild("Right Leg")
	}

	for _, p in pairs(parts) do
		if not p then
			for _, l in ipairs(data.lines) do
				l.line.Visible = false
				l.head.Visible = false
			end
			if ESPPro.indicators[player] then ESPPro.indicators[player].Visible = false end
			return
		end
	end

	local headScreen, headOn = worldToViewport(parts.Head.Position)
	local torsoScreen, torsoOn = worldToViewport(parts.Torso.Position)
	local lArmScreen, lArmOn = worldToViewport(parts.LeftArm.Position)
	local rArmScreen, rArmOn = worldToViewport(parts.RightArm.Position)
	local lLegScreen, lLegOn = worldToViewport(parts.LeftLeg.Position)
	local rLegScreen, rLegOn = worldToViewport(parts.RightLeg.Position)

	if not (headOn and torsoOn and lArmOn and rArmOn and lLegOn and rLegOn) then
		for _, l in ipairs(data.lines) do
			l.line.Visible = false
			l.head.Visible = false
		end
		if ESPPro.indicators[player] then ESPPro.indicators[player].Visible = false end
		return
	end

	drawLine(data.lines[1].line, headScreen, torsoScreen)
	drawLine(data.lines[2].line, torsoScreen, lArmScreen)
	drawLine(data.lines[3].line, torsoScreen, rArmScreen)
	drawLine(data.lines[4].line, torsoScreen, lLegScreen)
	drawLine(data.lines[5].line, torsoScreen, rLegScreen)

	local headCircle = data.lines[1].head
	local headSize = math.max(6, (lArmScreen - rArmScreen).Magnitude * 0.3)
	headCircle.Size = UDim2.fromOffset(headSize, headSize)
	headCircle.Position = UDim2.fromOffset(headScreen.X, headScreen.Y)
	headCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	local corner = headCircle:FindFirstChildOfClass("UICorner")
	if not corner then
		addCorner(headCircle, 100)
	end
	headCircle.Visible = true

	for i = 2, 5 do
		data.lines[i].head.Visible = false
	end

	if not ESPPro.indicators[player] then
		local line = Instance.new("Frame")
		line.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
		line.BorderSizePixel = 0
		line.ZIndex = 45002
		line.Parent = ESPPro.folder
		ESPPro.indicators[player] = line
	end

	local indicator = ESPPro.indicators[player]
	local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1000, 600)
	local topCenter = Vector2.new(vp.X * 0.5, 40)
	drawLine(indicator, topCenter, headScreen)
end

local function clearSkeleton(player)
	local d = ESPPro.players[player]
	if not d then return end
	for _, l in ipairs(d.lines) do
		l.line.Visible = false
		l.head.Visible = false
	end
	local ind = ESPPro.indicators[player]
	if ind then ind.Visible = false end
end

local function renderESPPro()
	if not ESPPro.active then return end
	local count = 0
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local targetCharacter = player.Character
			if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
				count += 1
				updateSkeleton(player, targetCharacter)
			else
				clearSkeleton(player)
			end
		end
	end

	if ESPPro.topLabel then
		ESPPro.topLabel.Text = "Người chơi: " .. count
	end
end

local function startESPPro()
	if ESPPro.active then return end
	ESPPro.active = true
	State.espPro = true

	ESPPro.folder = Instance.new("Folder")
	ESPPro.folder.Name = "_ThoESPPro"
	ESPPro.folder.Parent = ScreenGui

	ESPPro.topFrame = Instance.new("Frame")
	ESPPro.topFrame.AnchorPoint = Vector2.new(0.5, 0)
	ESPPro.topFrame.Position = UDim2.new(0.5, 0, 0, 8)
	ESPPro.topFrame.Size = UDim2.fromOffset(240, 32)
	ESPPro.topFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 40)
	ESPPro.topFrame.BackgroundTransparency = 0.15
	ESPPro.topFrame.BorderSizePixel = 0
	ESPPro.topFrame.ZIndex = 46000
	ESPPro.topFrame.Parent = ScreenGui
	addCorner(ESPPro.topFrame, 8)
	addStroke(ESPPro.topFrame, BLUE_5, 0.3, 2)

	ESPPro.topLabel = addText(ESPPro.topFrame, "Người chơi: 0", 14, Enum.Font.GothamBold, Color3.fromRGB(0, 255, 100))
	ESPPro.topLabel.Size = UDim2.fromScale(1, 1)
	ESPPro.topLabel.TextXAlignment = Enum.TextXAlignment.Center
	ESPPro.topLabel.ZIndex = 46001

	pcall(function()
		RunService:UnbindFromRenderStep(ESPPro.bindName)
	end)
	RunService:BindToRenderStep(ESPPro.bindName, Enum.RenderPriority.Camera.Value + 1, renderESPPro)
end

local function stopESPPro()
	ESPPro.active = false
	State.espPro = false

	pcall(function()
		RunService:UnbindFromRenderStep(ESPPro.bindName)
	end)

	for player, _ in pairs(ESPPro.players) do
		destroySkeleton(player)
	end
	ESPPro.players = {}

	for player, _ in pairs(ESPPro.indicators) do
		if ESPPro.indicators[player] then
			ESPPro.indicators[player]:Destroy()
		end
	end
	ESPPro.indicators = {}

	if ESPPro.folder then
		ESPPro.folder:Destroy()
		ESPPro.folder = nil
	end
	if ESPPro.topFrame then
		ESPPro.topFrame:Destroy()
		ESPPro.topFrame = nil
		ESPPro.topLabel = nil
	end
end

createToggle(ESPPage, "Định vị nâng cao", "Skeleton ESP + tia chỉ hướng + bảng đếm người chơi.", false, function(value)
	if value then startESPPro() else stopESPPro() end
end, 3)

-- NPC ESP
local NPCESP = {
	active = false,
	folder = nil,
	data = {},
	descConn = nil,
	bindName = "ThoNPCESPUpdate"
}

local function destroyNPCESP(model)
	local d = NPCESP.data[model]
	if not d then return end
	if d.highlight then d.highlight:Destroy() end
	if d.billboard then d.billboard:Destroy() end
	if d.box then d.box:Destroy() end
	NPCESP.data[model] = nil
end

local function ensureNPCESP(model)
	if NPCESP.data[model] then return end

	local highlight = Instance.new("Highlight")
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = Color3.fromRGB(0, 150, 255)
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = Color3.fromRGB(0, 200, 255)
	highlight.OutlineTransparency = 0.1
	highlight.Enabled = false
	highlight.Parent = NPCESP.folder

	local box = Instance.new("SelectionBox")
	box.LineThickness = 0.12
	box.Color3 = Color3.fromRGB(0, 200, 255)
	box.Transparency = 0
	box.Visible = false
	box.Parent = NPCESP.folder

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(180, 50)
	billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = false
	billboard.LightInfluence = 0
	billboard.Parent = NPCESP.folder

	local nameLabel = addText(billboard, "NPC", 13, Enum.Font.GothamBold, Color3.fromRGB(0, 200, 255))
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

	NPCESP.data[model] = {
		highlight = highlight,
		billboard = billboard,
		nameLabel = nameLabel,
		infoLabel = infoLabel,
		box = box
	}
end

local function isNPCModel(model)
	if not model:IsA("Model") then return false end
	if not model:FindFirstChildOfClass("Humanoid") then return false end
	if not model:FindFirstChild("HumanoidRootPart") then return false end
	if Players:GetPlayerFromCharacter(model) then return false end
	return true
end

local function scanNPCs()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and isNPCModel(obj) then
			ensureNPCESP(obj)
		end
	end
end

local function renderNPCESP()
	if not NPCESP.active then return end
	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")

	for model, data in pairs(NPCESP.data) do
		local targetRoot = model:FindFirstChild("HumanoidRootPart")
		local targetHumanoid = model:FindFirstChildOfClass("Humanoid")

		if model.Parent and targetRoot and targetHumanoid then
			data.highlight.Adornee = model
			data.highlight.Enabled = true
			data.billboard.Adornee = targetRoot
			data.billboard.Enabled = true
			data.box.Adornee = model
			data.box.Visible = true

			local distance = 0
			if localRoot then
				distance = math.floor((localRoot.Position - targetRoot.Position).Magnitude)
			end

			local name = model.Name
			if name == "" or name == "Model" or name:match("^Model$") then
				name = "N/A"
			end

			data.nameLabel.Text = name
			data.infoLabel.Text =
				"HP: " .. math.floor(targetHumanoid.Health)
				.. "/" .. math.floor(targetHumanoid.MaxHealth)
				.. " | " .. distance .. " studs"
		else
			destroyNPCESP(model)
		end
	end
end

local function startNPCESP()
	if NPCESP.active then return end
	NPCESP.active = true
	State.espNPC = true

	NPCESP.folder = Instance.new("Folder")
	NPCESP.folder.Name = "_ThoNPCESP"
	NPCESP.folder.Parent = ScreenGui

	scanNPCs()

	NPCESP.descConn = workspace.DescendantAdded:Connect(function(obj)
		if not NPCESP.active then return end
		if obj:IsA("Humanoid") then
			local model = obj.Parent
			if model and model:IsA("Model") and isNPCModel(model) then
				ensureNPCESP(model)
			end
		end
	end)

	pcall(function()
		RunService:UnbindFromRenderStep(NPCESP.bindName)
	end)
	RunService:BindToRenderStep(NPCESP.bindName, Enum.RenderPriority.Camera.Value + 1, renderNPCESP)
end

local function stopNPCESP()
	NPCESP.active = false
	State.espNPC = false

	pcall(function()
		RunService:UnbindFromRenderStep(NPCESP.bindName)
	end)

	if NPCESP.descConn then
		NPCESP.descConn:Disconnect()
		NPCESP.descConn = nil
	end

	for model, _ in pairs(NPCESP.data) do
		destroyNPCESP(model)
	end
	NPCESP.data = {}

	if NPCESP.folder then
		NPCESP.folder:Destroy()
		NPCESP.folder = nil
	end
end

createToggle(ESPPage, "Định vị NPC", "Hiển thị tên, máu, khoảng cách của NPC.", false, function(value)
	if value then startNPCESP() else stopNPCESP() end
end, 4)

-- Team ESP
local TeamESP = {
	active = false,
	folder = nil,
	data = {},
	bindName = "ThoTeamESPUpdate"
}

local function destroyTeamESP(player)
	local d = TeamESP.data[player]
	if not d then return end
	if d.highlight then d.highlight:Destroy() end
	if d.billboard then d.billboard:Destroy() end
	if d.box then d.box:Destroy() end
	TeamESP.data[player] = nil
end

local function ensureTeamESP(player)
	if TeamESP.data[player] then return end

	local highlight = Instance.new("Highlight")
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = Color3.fromRGB(0, 255, 100)
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = Color3.fromRGB(0, 255, 150)
	highlight.OutlineTransparency = 0
	highlight.Enabled = false
	highlight.Parent = TeamESP.folder

	local box = Instance.new("SelectionBox")
	box.LineThickness = 0.12
	box.Color3 = Color3.fromRGB(0, 255, 100)
	box.Transparency = 0
	box.Visible = false
	box.Parent = TeamESP.folder

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(180, 50)
	billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = false
	billboard.LightInfluence = 0
	billboard.Parent = TeamESP.folder

	local nameLabel = addText(billboard, player.DisplayName, 13, Enum.Font.GothamBold, Color3.fromRGB(0, 255, 100))
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

	TeamESP.data[player] = {
		highlight = highlight,
		billboard = billboard,
		nameLabel = nameLabel,
		infoLabel = infoLabel,
		box = box
	}
end

local function isTeammate(player)
	if player == LocalPlayer then return false end
	local myTeam = LocalPlayer.Team
	if not myTeam then return false end
	return player.Team == myTeam
end

local function renderTeamESP()
	if not TeamESP.active then return end
	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")

	for player, data in pairs(TeamESP.data) do
		if not isTeammate(player) then
			destroyTeamESP(player)
		else
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
				data.nameLabel.Text = "[TEAM] " .. player.DisplayName
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

	for _, player in ipairs(Players:GetPlayers()) do
		if isTeammate(player) then
			ensureTeamESP(player)
		end
	end
end

local function startTeamESP()
	if TeamESP.active then return end
	TeamESP.active = true
	State.espTeam = true

	TeamESP.folder = Instance.new("Folder")
	TeamESP.folder.Name = "_ThoTeamESP"
	TeamESP.folder.Parent = ScreenGui

	if not LocalPlayer.Team then
		showNotice("Bạn không ở trong team nào.", false)
	end

	pcall(function()
		RunService:UnbindFromRenderStep(TeamESP.bindName)
	end)
	RunService:BindToRenderStep(TeamESP.bindName, Enum.RenderPriority.Camera.Value + 1, renderTeamESP)
end

local function stopTeamESP()
	TeamESP.active = false
	State.espTeam = false

	pcall(function()
		RunService:UnbindFromRenderStep(TeamESP.bindName)
	end)

	for player, _ in pairs(TeamESP.data) do
		destroyTeamESP(player)
	end
	TeamESP.data = {}

	if TeamESP.folder then
		TeamESP.folder:Destroy()
		TeamESP.folder = nil
	end
end

createToggle(ESPPage, "Định vị đồng đội", "Hiển thị khung xanh lá cho player cùng team.", false, function(value)
	if value then startTeamESP() else stopTeamESP() end
end, 5)

-- ============================================================
-- VISUAL TAB
-- ============================================================
createSection(VisualPage, "Visual", 1)

local AntiLag = {
	active = false,
	originals = setmetatable({}, {__mode = "k"}),
	connections = {},
	pendingQueue = {},
	lightingBackup = nil,
	terrainBackup = nil,
	qualityBackup = nil,
	atmosphereBackup = nil,
	skyBackup = nil,
	heartbeatConn = nil
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
	Lighting.Brightness = 1
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	pcall(function()
		Lighting.Ambient = Color3.fromRGB(100, 100, 100)
		Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
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

	if character and obj:IsDescendantOf(character) then return end
	local cam = workspace.CurrentCamera
	if cam and obj:IsDescendantOf(cam) then return end

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
	elseif obj:IsA("SurfaceAppearance") then
		AntiLag.originals[obj] = { Parent = obj.Parent, type_ = "SurfaceAppearance" }
		pcall(function() obj.Parent = nil end)
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
			if i % 100 == 0 then task.wait() end
		end
	end)

	local descConn = workspace.DescendantAdded:Connect(function(obj)
		if not AntiLag.active then return end
		table.insert(AntiLag.pendingQueue, obj)
	end)

	local hbConn = RunService.Heartbeat:Connect(function()
		if not AntiLag.active then return end
		local processed = 0
		while #AntiLag.pendingQueue > 0 and processed < 30 do
			local obj = table.remove(AntiLag.pendingQueue, 1)
			optimizeObject(obj)
			processed += 1
		end
	end)

	AntiLag.heartbeatConn = hbConn
	table.insert(AntiLag.connections, descConn)
end

local function stopAntiLag()
	AntiLag.active = false
	AntiLag.pendingQueue = {}

	for _, conn in ipairs(AntiLag.connections) do
		pcall(function() conn:Disconnect() end)
	end
	AntiLag.connections = {}
	if AntiLag.heartbeatConn then
		pcall(function() AntiLag.heartbeatConn:Disconnect() end)
		AntiLag.heartbeatConn = nil
	end

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
				elseif data.type_ == "SurfaceAppearance" then
					obj.Parent = data.Parent
				end
			end)
		end
	end
	AntiLag.originals = setmetatable({}, {__mode = "k"})

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

createToggle(VisualPage, "Giảm lag", "Hạ đồ họa mạnh. Bật nếu FPS thấp.", false, function(value)
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

-- Camera helpers
local magicActive = false
local magicSplit = false
local freeCamActive = false
local magicButton = nil
local magicSavedWalk, magicSavedJump
local magicRenderName = "ThoMagicCam"
local freeCamRenderName = "ThoFreeCam"
local camYaw = 0
local camPitch = 0
local freeCamSavedWalk, freeCamSavedJump

local function getCamRot()
	return CFrame.fromEulerAnglesYXZ(math.rad(camPitch), math.rad(camYaw), 0)
end

local function getMoveInput()
	local rot = getCamRot()
	local look = rot.LookVector
	local right = rot.RightVector
	local move = Vector3.zero

	if humanoid then
		local md = humanoid.MoveDirection
		if md.Magnitude > 0 then
			local u = md.Unit
			local f = u:Dot(look)
			local r = u:Dot(right)
			move += look * f + right * r
		end
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += look end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= look end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += right end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= right end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end

	if move.Magnitude > 1 then
		move = move.Unit
	end
	return move
end

UserInputService.InputChanged:Connect(function(input)
	if not (magicSplit or freeCamActive) then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		camYaw -= input.Delta.X * 0.4
		camPitch = math.clamp(camPitch - input.Delta.Y * 0.4, -89, 89)
	elseif input.UserInputType == Enum.UserInputType.Touch then
		camYaw -= input.Delta.X * 0.4
		camPitch = math.clamp(camPitch - input.Delta.Y * 0.4, -89, 89)
	end
end)

local function renderFreeCam(dt)
	if not freeCamActive then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	cam.CameraType = Enum.CameraType.Scriptable

	local rot = getCamRot()
	local move = getMoveInput()
	local speed = 80
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then speed = 250 end
	local newPos = cam.CFrame.Position + move * speed * dt
	cam.CFrame = CFrame.new(newPos) * rot
end

local function stopFreeCam()
	freeCamActive = false
	pcall(function()
		RunService:UnbindFromRenderStep(freeCamRenderName)
	end)
	refreshCharacter()
	if humanoid then
		humanoid.WalkSpeed = freeCamSavedWalk or 16
		humanoid.JumpPower = freeCamSavedJump or 50
	end
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
	refreshCharacter()
	if not humanoid then return end

	freeCamSavedWalk = humanoid.WalkSpeed
	freeCamSavedJump = humanoid.JumpPower
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0

	local cam = workspace.CurrentCamera
	if not cam then return end
	freeCamActive = true
	cam.CameraType = Enum.CameraType.Scriptable

	local look = cam.CFrame.LookVector
	camYaw = math.deg(math.atan2(-look.X, -look.Z))
	camPitch = math.deg(math.asin(math.clamp(look.Y, -1, 1)))

	pcall(function()
		RunService:UnbindFromRenderStep(freeCamRenderName)
	end)
	RunService:BindToRenderStep(freeCamRenderName, Enum.RenderPriority.Camera.Value + 10, renderFreeCam)
end

createToggle(VisualPage, "Xem từ xa", "Nhân vật đứng yên, camera bay tự do.", false, function(value)
	if value then startFreeCam() else stopFreeCam() end
end, 5)

-- ============================================================
-- SHADER: BẢN ĐỒ SÁNG
-- ============================================================
local BrightMap = {
	active = false,
	backup = nil,
	colorCorrection = nil
}

local function startBrightMap()
	if BrightMap.active then return end
	BrightMap.active = true

	BrightMap.backup = {
		Brightness = Lighting.Brightness,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		GlobalShadows = Lighting.GlobalShadows,
		FogEnd = Lighting.FogEnd,
		FogStart = Lighting.FogStart,
		ExposureCompensation = Lighting.ExposureCompensation
	}

	Lighting.Brightness = 3
	Lighting.Ambient = Color3.fromRGB(200, 200, 200)
	Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 1e6
	Lighting.FogStart = 1e6
	Lighting.ExposureCompensation = 0.5

	BrightMap.colorCorrection = Instance.new("ColorCorrectionEffect")
	BrightMap.colorCorrection.Brightness = 0.15
	BrightMap.colorCorrection.Contrast = -0.1
	BrightMap.colorCorrection.Saturation = 0.05
	BrightMap.colorCorrection.Parent = Lighting
end

local function stopBrightMap()
	if not BrightMap.active then return end
	BrightMap.active = false

	if BrightMap.backup then
		for k, v in pairs(BrightMap.backup) do
			pcall(function() Lighting[k] = v end)
		end
		BrightMap.backup = nil
	end

	if BrightMap.colorCorrection then
		pcall(function() BrightMap.colorCorrection:Destroy() end)
		BrightMap.colorCorrection = nil
	end
end

-- ============================================================
-- SHADER: BẢN ĐỒ MƯA
-- ============================================================
local RainMap = {
	active = false,
	rainTop = nil,
	rainBottom = nil,
	rainDrop = nil,
	rainSplash = nil,
	rainSound = nil
}

local function startRainMap()
	if RainMap.active then return end
	RainMap.active = true

	local cam = workspace.CurrentCamera
	if not cam then return end

	RainMap.rainTop = Instance.new("Attachment")
	RainMap.rainTop.Position = Vector3.new(0, 40, 0)
	RainMap.rainTop.Parent = cam

	RainMap.rainBottom = Instance.new("Attachment")
	RainMap.rainBottom.Position = Vector3.new(0, -5, 0)
	RainMap.rainBottom.Parent = cam

	RainMap.rainDrop = Instance.new("ParticleEmitter")
	RainMap.rainDrop.Texture = "rbxassetid://241876428"
	RainMap.rainDrop.Rate = 600
	RainMap.rainDrop.Lifetime = NumberRange.new(0.5, 0.9)
	RainMap.rainDrop.Speed = NumberRange.new(60, 100)
	RainMap.rainDrop.SpreadAngle = Vector2.new(3, 3)
	RainMap.rainDrop.Acceleration = Vector3.new(0, -180, 0)
	RainMap.rainDrop.Size = NumberSequence.new(0.4)
	RainMap.rainDrop.Transparency = NumberSequence.new(0.4)
	RainMap.rainDrop.Color = ColorSequence.new(Color3.fromRGB(200, 220, 255))
	RainMap.rainDrop.LightInfluence = 0
	RainMap.rainDrop.LightEmission = 0.1
	RainMap.rainDrop.EmissionDirection = Enum.NormalId.Bottom
	RainMap.rainDrop.Rotation = NumberRange.new(0, 0)
	RainMap.rainDrop.RotSpeed = NumberRange.new(0, 0)
	RainMap.rainDrop.Squash = NumberSequence.new(3)
	RainMap.rainDrop.VelocityInheritance = 0
	RainMap.rainDrop.Parent = RainMap.rainTop

	RainMap.rainSplash = Instance.new("ParticleEmitter")
	RainMap.rainSplash.Texture = "rbxassetid://244221440"
	RainMap.rainSplash.Rate = 150
	RainMap.rainSplash.Lifetime = NumberRange.new(0.4, 0.7)
	RainMap.rainSplash.Speed = NumberRange.new(0, 3)
	RainMap.rainSplash.SpreadAngle = Vector2.new(180, 180)
	RainMap.rainSplash.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(1, 2.5)
	})
	RainMap.rainSplash.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})
	RainMap.rainSplash.Color = ColorSequence.new(Color3.fromRGB(180, 220, 255))
	RainMap.rainSplash.LightInfluence = 0
	RainMap.rainSplash.Rotation = NumberRange.new(0, 0)
	RainMap.rainSplash.RotSpeed = NumberRange.new(0, 0)
	RainMap.rainSplash.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp
	RainMap.rainSplash.Parent = RainMap.rainBottom

	RainMap.rainSound = Instance.new("Sound")
	RainMap.rainSound.SoundId = "rbxassetid://9046062719"
	RainMap.rainSound.Looped = true
	RainMap.rainSound.Volume = 0.8
	RainMap.rainSound.Parent = SoundService
	pcall(function() SoundService:PlayLocalSound(RainMap.rainSound) end)
end

local function stopRainMap()
	if not RainMap.active then return end
	RainMap.active = false

	if RainMap.rainDrop then pcall(function() RainMap.rainDrop:Destroy() end) RainMap.rainDrop = nil end
	if RainMap.rainSplash then pcall(function() RainMap.rainSplash:Destroy() end) RainMap.rainSplash = nil end
	if RainMap.rainTop then pcall(function() RainMap.rainTop:Destroy() end) RainMap.rainTop = nil end
	if RainMap.rainBottom then pcall(function() RainMap.rainBottom:Destroy() end) RainMap.rainBottom = nil end
	if RainMap.rainSound then
		pcall(function() RainMap.rainSound:Stop() end)
		pcall(function() RainMap.rainSound:Destroy() end)
		RainMap.rainSound = nil
	end
end

-- ============================================================
-- SHADER: BẢN ĐỒ THƯ GIÃN
-- ============================================================
local ChillMap = {
	active = false,
	backup = nil,
	effects = {},
	atmosphereBackup = nil
}

local function startChillMap()
	if ChillMap.active then return end
	ChillMap.active = true

	ChillMap.backup = {
		Brightness = Lighting.Brightness,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		GlobalShadows = Lighting.GlobalShadows,
		ExposureCompensation = Lighting.ExposureCompensation
	}

	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(150, 145, 140)
	Lighting.OutdoorAmbient = Color3.fromRGB(160, 155, 150)
	Lighting.GlobalShadows = true
	Lighting.ExposureCompensation = 0.2

	-- SunRays - tia nắng
	local sunRays = Instance.new("SunRaysEffect")
	sunRays.Intensity = 0.15
	sunRays.Spread = 0.9
	sunRays.Parent = Lighting
	table.insert(ChillMap.effects, sunRays)

	-- Bloom nhẹ
	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 1.2
	bloom.Size = 24
	bloom.Threshold = 0.85
	bloom.Parent = Lighting
	table.insert(ChillMap.effects, bloom)

	-- ColorCorrection ấm
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Brightness = 0.05
	cc.Contrast = 0.18
	cc.Saturation = 0.15
	cc.TintColor = Color3.fromRGB(255, 245, 230)
	cc.Parent = Lighting
	table.insert(ChillMap.effects, cc)

	-- DepthOfField nhẹ
	local dof = Instance.new("DepthOfFieldEffect")
	dof.FarIntensity = 0.15
	dof.FocusDistance = 30
	dof.InFocusRadius = 25
	dof.NearIntensity = 0.4
	dof.Parent = Lighting
	table.insert(ChillMap.effects, dof)

	-- Atmosphere mềm
	local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atmo then
		atmo = Instance.new("Atmosphere")
		atmo.Parent = Lighting
	end
	ChillMap.atmosphereBackup = {
		obj = atmo,
		Density = atmo.Density,
		Offset = atmo.Offset,
		Color = atmo.Color,
		Decay = atmo.Decay,
		Glare = atmo.Glare,
		Haze = atmo.Haze
	}
	pcall(function()
		atmo.Density = 0.3
		atmo.Offset = 0
		atmo.Color = Color3.fromRGB(200, 210, 220)
		atmo.Decay = Color3.fromRGB(106, 112, 125)
		atmo.Glare = 0.1
		atmo.Haze = 0.8
	end)
end

local function stopChillMap()
	if not ChillMap.active then return end
	ChillMap.active = false

	if ChillMap.backup then
		for k, v in pairs(ChillMap.backup) do
			pcall(function() Lighting[k] = v end)
		end
		ChillMap.backup = nil
	end

	for _, e in ipairs(ChillMap.effects) do
		pcall(function() e:Destroy() end)
	end
	ChillMap.effects = {}

	if ChillMap.atmosphereBackup then
		local a = ChillMap.atmosphereBackup
		pcall(function()
			a.obj.Density = a.Density
			a.obj.Offset = a.Offset
			a.obj.Color = a.Color
			a.obj.Decay = a.Decay
			a.obj.Glare = a.Glare
			a.obj.Haze = a.Haze
		end)
		ChillMap.atmosphereBackup = nil
	end
end

-- ============================================================
-- SECTION SHADER (trong tab Visual)
-- ============================================================
createSection(VisualPage, "Shader", 6)

createStateButton(VisualPage, "Bản đồ sáng", "Tăng độ sáng map, phù hợp game kinh dị tối. Bấm lần nữa để tắt.", function()
	startBrightMap()
	showNotice("Đã bật Bản đồ sáng.", true)
end, function()
	stopBrightMap()
	showNotice("Đã tắt Bản đồ sáng.", true)
end, 7)

createStateButton(VisualPage, "Bản đồ mưa", "Hiệu ứng mưa rơi + splash dưới đất + âm thanh. Bấm lần nữa để tắt.", function()
	startRainMap()
	showNotice("Đã bật Bản đồ mưa.", true)
end, function()
	stopRainMap()
	showNotice("Đã tắt Bản đồ mưa.", true)
end, 8)

createStateButton(VisualPage, "Bản đồ thư giãn", "Shader đẹp: tia nắng, bloom, color ấm. Khuyến khích máy mạnh.", function()
	startChillMap()
	showNotice("Đã bật Bản đồ thư giãn.", true)
end, function()
	stopChillMap()
	showNotice("Đã tắt Bản đồ thư giãn.", true)
end, 9)

-- ============================================================
-- SECTION HIỆU ỨNG (pose)
-- ============================================================
createSection(VisualPage, "Hiệu ứng", 20)

local poseConnection = nil
local poseName = nil
local poseSound = nil

local POSE_SOUNDS = {
	void = "rbxassetid://6667923288",
	shrine = "rbxassetid://6590147536"
}

local function playPoseSound(poseId)
	if poseSound then
		pcall(function() poseSound:Destroy() end)
		poseSound = nil
	end
	local id = POSE_SOUNDS[poseId]
	if not id then return end
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = 2
	s.Parent = SoundService
	poseSound = s
	pcall(function() SoundService:PlayLocalSound(s) end)
	s.Ended:Connect(function()
		if poseSound == s then poseSound = nil end
		pcall(function() s:Destroy() end)
	end)
	task.delay(15, function()
		if s and s.Parent then
			pcall(function() s:Destroy() end)
			if poseSound == s then poseSound = nil end
		end
	end)
end

local function stopPoseSound()
	if poseSound then
		pcall(function() poseSound:Stop() end)
		pcall(function() poseSound:Destroy() end)
		poseSound = nil
	end
end

local function resetPoseMotor(m)
	if m.Name == "Right Shoulder" or m.Name == "RightShoulder" then
		m.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0)
	elseif m.Name == "Left Shoulder" or m.Name == "LeftShoulder" then
		m.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
	end
end

local function applyPoseMotor(m, poseId)
	if not (m:IsA("Motor6D") or m:IsA("Motor")) then return end

	local isRight = m.Name == "Right Shoulder" or m.Name == "RightShoulder"
	local isLeft = m.Name == "Left Shoulder" or m.Name == "LeftShoulder"

	if poseId == "void" then
		if isRight then
			m.C0 = CFrame.new(1, 0.5, -0.3) * CFrame.Angles(math.rad(90), 0, 0)
		elseif isLeft then
			m.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
		end
	elseif poseId == "shrine" then
		if isRight then
			m.C0 = CFrame.new(0.9, 0.5, -0.5) * CFrame.Angles(math.rad(90), math.rad(-15), 0)
		elseif isLeft then
			m.C0 = CFrame.new(-0.9, 0.5, -0.5) * CFrame.Angles(math.rad(90), math.rad(15), 0)
		end
	end
end

local function resetPose()
	if poseConnection then poseConnection:Disconnect() poseConnection = nil end
	stopPoseSound()
	refreshCharacter()
	if not character then poseName = nil return end

	local animate = character:FindFirstChild("Animate")
	if animate then
		pcall(function() animate.Disabled = false end)
	end

	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("Motor6D") or obj:IsA("Motor") then
			resetPoseMotor(obj)
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
	playPoseSound(poseId)

	local function applyAll()
		for _, obj in ipairs(character:GetDescendants()) do
			applyPoseMotor(obj, poseId)
		end
	end

	applyAll()

	poseConnection = RunService.RenderStepped:Connect(function()
		if not character or not character.Parent then return end
		applyAll()
	end)
end

createButton(VisualPage, "Vô Lượng Không Xứ", "Tay phải giơ ra trước mặt (Gojo) + nhạc.", function()
	applyPose("void")
	showNotice("Đã kích hoạt Vô Lượng Không Xứ", true)
end, 21)

createButton(VisualPage, "Phục Ma Ngự Trù Tử", "Hai tay chắp trước ngực (Sukuna) + nhạc.", function()
	applyPose("shrine")
	showNotice("Đã kích hoạt Phục Ma Ngự Trù Tử", true)
end, 22)

createButton(VisualPage, "Tắt hiệu ứng", "Trở về tư thế bình thường.", function()
	resetPose()
	showNotice("Đã tắt hiệu ứng.", true)
end, 23)

-- ============================================================
-- SERVER TAB
-- ============================================================
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

createButton(ServerPage, "Lấy ID map này", "Hiện PlaceId và link map, kèm nút Copy.", function()
	local placeId = game.PlaceId
	local info = "PlaceID: " .. tostring(placeId)
		.. "\n\nLink: https://www.roblox.com/games/" .. tostring(placeId)
	showCopyPopup("Thông tin Map", info)
end, 5)

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
end, 6)

-- ============================================================
-- SETTINGS TAB
-- ============================================================
createSection(SettingsPage, "Script", 1)

createToggle(SettingsPage, "Tự động chạy lại script", "Tự chạy lại sau khi đổi server.", false, function(value)
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
end, 2)

createButton(SettingsPage, "Khởi động lại script", "Xóa GUI và chạy lại script mới nhất.", function()
	if getgenv()._ThoRestarting then
		return
	end
	getgenv()._ThoRestarting = true

	if AUTORUN_URL == "" then
		showNotice("Cần điền AUTORUN_URL ở đầu script.", false)
		getgenv()._ThoRestarting = false
		return
	end

	local ok, src = pcall(game.HttpGet, game, AUTORUN_URL)
	if not ok or not src then
		showNotice("Không tải được source mới.", false)
		getgenv()._ThoRestarting = false
		return
	end

	showNotice("Đang khởi động lại...", true)

	task.spawn(function()
		task.wait(0.4)

		pcall(function() if State.fly then stopFly() end end)
		pcall(function() if State.esp then stopESP() end end)
		pcall(function() if State.espPro then stopESPPro() end end)
		pcall(function() if State.espNPC then stopNPCESP() end end)
		pcall(function() if State.espTeam then stopTeamESP() end end)
		pcall(function() if State.antiLag then stopAntiLag() end end)
		pcall(function() if magicSplit then stopMagicTeleport() end end)
		pcall(function() if freeCamActive then stopFreeCam() end end)
		pcall(function() if poseName then resetPose() end end)
		pcall(function() if safeZoneActive then stopSafeZone(false) end end)
		pcall(function() if BrightMap.active then stopBrightMap() end end)
		pcall(function() if RainMap.active then stopRainMap() end end)
		pcall(function() if ChillMap.active then stopChillMap() end end)

		task.wait(0.3)

		pcall(function() ScreenGui:Destroy() end)
		pcall(function() FloatGui:Destroy() end)

		task.wait(0.5)

		getgenv()._ThoRestarting = false

		local fn = loadstring(src)
		if fn then
			task.spawn(fn)
		end
	end)
end, 3)

local saveEnabled = false
local function saveAllSettings()
	if not saveEnabled then return end
	if type(writefile) ~= "function" then return end
	local data = {}
	for title, t in pairs(TOGGLE_REGISTRY) do
		local ok, val = pcall(function() return t.Get() end)
		if ok then data[title] = val end
	end
	pcall(function()
		writefile(SAVE_FILE, HttpService:JSONEncode(data))
	end)
end

local function loadAllSettings()
	if type(readfile) ~= "function" or type(isfile) ~= "function" then
		return nil
	end
	local exists = false
	pcall(function() exists = isfile(SAVE_FILE) end)
	if not exists then return nil end

	local content
	pcall(function() content = readfile(SAVE_FILE) end)
	if not content then return nil end

	local data
	pcall(function() data = HttpService:JSONDecode(content) end)
	return data
end

createToggle(SettingsPage, "Lưu cài đặt chức năng", "Lưu trạng thái toggle vào file, tự khôi phục khi chạy lại.", false, function(value)
	saveEnabled = value
	if value then
		saveAllSettings()
		showNotice("Đã bật lưu. Trạng thái sẽ được giữ khi chuyển server.", true)
	else
		if type(writefile) == "function" and type(delfile) == "function" then
			pcall(function() delfile(SAVE_FILE) end)
		end
		showNotice("Đã tắt lưu. File cài đặt đã bị xóa.", true)
	end
end, 4)

-- ============================================================
-- FLOATING BUTTON
-- ============================================================
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

-- ============================================================
-- HOOK SAVE
-- ============================================================
for title, t in pairs(TOGGLE_REGISTRY) do
	local origSet = t.Set
	t.Set = function(value)
		origSet(value)
		task.defer(saveAllSettings)
	end
end

task.spawn(function()
	task.wait(1)

	local saved = loadAllSettings()
	if saved then
		local saveFlag = saved["Lưu cài đặt chức năng"]
		saveEnabled = saveFlag == true

		for title, value in pairs(saved) do
			if title ~= "Lưu cài đặt chức năng" then
				local t = TOGGLE_REGISTRY[title]
				if t then
					pcall(function() t.Set(value) end)
				end
			end
		end

		if saveEnabled then
			local t = TOGGLE_REGISTRY["Lưu cài đặt chức năng"]
			if t then pcall(function() t.SetSilent(true) end) end
		end
	end
end)

-- ============================================================
-- CHARACTER RESPAWN
-- ============================================================
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
		local pn = poseName
		task.delay(0.3, function()
			applyPose(pn)
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
