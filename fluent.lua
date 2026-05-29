--[[
	Fluent UI v1.0.0
	A modern Fluent Design-inspired UI library for Roblox executors.
	
	Features:
	- Clean, modern Fluent Design aesthetics
	- Custom rendering (no default Roblox UI)
	- Tab system with navigation
	- Buttons with ripple effects
	- Toggles with smooth animations
	- Sliders with draggable thumbs
	- Sections and dividers
	- Dropdown menus
	- Text inputs
	- Keybinds
	- Labels
	- Anti-detection measures
	- Lightweight and optimized
	
	Usage:
		local Fluent = loadstring(game:HttpGet("URL_HERE"))()
		local Window = Fluent:CreateWindow({
			Title = "My Executor",
			Size = UDim2.new(0, 600, 0, 450),
			Position = UDim2.new(0.5, -300, 0.5, -225)
		})
		local Tab = Window:AddTab("Main")
		local Section = Tab:AddSection("Section Name")
		Section:AddButton("Click Me", function() print("Clicked!") end)
--]]

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- Anti-detection: Hook metatables to prevent detection via __namecall
local oldNamecall
local oldIndex

-- Protected environment for the library
local Fluent = {}
Fluent.__index = Fluent

-- Version
Fluent.Version = "1.0.0"

-- Internal state
local Instances = {}
local Connections = {}
local Themes = {}
local ActiveWindows = {}

-- ============================================
-- THEME SYSTEM
-- ============================================

local DefaultTheme = {
	-- Background colors
	Background = Color3.fromRGB(20, 20, 20),
	BackgroundSecondary = Color3.fromRGB(28, 28, 28),
	BackgroundTertiary = Color3.fromRGB(36, 36, 36),
	BackgroundLight = Color3.fromRGB(45, 45, 45),
	
	-- Surface colors
	Surface = Color3.fromRGB(28, 28, 28),
	SurfaceLight = Color3.fromRGB(36, 36, 36),
	Border = Color3.fromRGB(50, 50, 50),
	
	-- Accent colors
	Accent = Color3.fromRGB(0, 120, 212),
	AccentLight = Color3.fromRGB(0, 140, 240),
	AccentDark = Color3.fromRGB(0, 100, 180),
	AccentGlow = Color3.fromRGB(0, 120, 212),
	
	-- Text colors
	Text = Color3.fromRGB(230, 230, 230),
	TextSecondary = Color3.fromRGB(180, 180, 180),
	TextMuted = Color3.fromRGB(130, 130, 130),
	TextInverse = Color3.fromRGB(20, 20, 20),
	
	-- State colors
	Success = Color3.fromRGB(76, 175, 80),
	Warning = Color3.fromRGB(255, 193, 7),
	Error = Color3.fromRGB(244, 67, 54),
	Info = Color3.fromRGB(33, 150, 243),
	
	-- Button colors
	Button = Color3.fromRGB(45, 45, 45),
	ButtonHover = Color3.fromRGB(55, 55, 55),
	ButtonPress = Color3.fromRGB(35, 35, 35),
	ButtonAccent = Color3.fromRGB(0, 120, 212),
	ButtonAccentHover = Color3.fromRGB(0, 140, 240),
	ButtonDisabled = Color3.fromRGB(60, 60, 60),
	
	-- Toggle colors
	ToggleOn = Color3.fromRGB(0, 120, 212),
	ToggleOff = Color3.fromRGB(70, 70, 70),
	ToggleThumb = Color3.fromRGB(200, 200, 200),
	
	-- Slider colors
	SliderTrack = Color3.fromRGB(70, 70, 70),
	SliderFill = Color3.fromRGB(0, 120, 212),
	SliderThumb = Color3.fromRGB(200, 200, 200),
	
	-- Scrollbar
	Scrollbar = Color3.fromRGB(60, 60, 60),
	ScrollbarHover = Color3.fromRGB(80, 80, 80),
	
	-- Tab colors
	TabActive = Color3.fromRGB(0, 120, 212),
	TabInactive = Color3.fromRGB(160, 160, 160),
	TabHover = Color3.fromRGB(50, 50, 50),
	TabBackground = Color3.fromRGB(22, 22, 22),
	
	-- Font
	Font = Enum.Font.GothamSemibold,
	FontSecondary = Enum.Font.Gotham,
	TextSize = 14,
	TextSizeSmall = 12,
	TextSizeLarge = 16,
	TextSizeTitle = 20,
	
	-- Rounding
	CornerRadius = UDim.new(0, 6),
	CornerRadiusSmall = UDim.new(0, 4),
	CornerRadiusLarge = UDim.new(0, 8),
	CornerRadiusRound = UDim.new(1, 0),
	
	-- Animation
	TweenSpeed = 0.15,
	TweenSpeedSlow = 0.3,
	
	-- Shadow
	ShadowColor = Color3.fromRGB(0, 0, 0),
	ShadowTransparency = 0.6,
	ShadowSize = UDim.new(0, 10),
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local Utilities = {}

function Utilities:Create(class, properties)
	local inst = Instance.new(class)
	for prop, value in pairs(properties or {}) do
		inst[prop] = value
	end
	return inst
end

function Utilities:Tween(obj, props, time, easing, direction)
	local tweenInfo = TweenInfo.new(
		time or DefaultTheme.TweenSpeed,
		easing or Enum.EasingStyle.Quad,
		direction or Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(obj, tweenInfo, props)
	tween:Play()
	return tween
end

function Utilities:MakeDraggable(frame, dragObj)
	dragObj = dragObj or frame
	local dragging, dragInput, dragStart, startPos
	
	dragObj.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
	
	dragObj.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
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

function Utilities:RoundVector(v, places)
	return Vector2.new(
		math.floor(v.X * (10 ^ (places or 0)) + 0.5) / (10 ^ (places or 0)),
		math.floor(v.Y * (10 ^ (places or 0)) + 0.5) / (10 ^ (places or 0))
	)
end

function Utilities:Clamp(val, min, max)
	return math.max(min, math.min(max, val))
end

-- Ripple Effect
function Utilities:Ripple(button, x, y)
	local corner = button.FindFirstChildWhichIsA(button, "UICorner") or Utilities:Create("UICorner", {
		Parent = button,
		CornerRadius = DefaultTheme.CornerRadius
	})
	
	local rippleSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
	local ripple = Utilities:Create("Frame", {
		Name = "Ripple",
		Parent = button,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.85,
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(0, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 10
	})
	
	Utilities:Create("UICorner", {
		Parent = ripple,
		CornerRadius = UDim.new(1, 0)
	})
	
	-- Animate ripple
	Utilities:Tween(ripple, {
		Size = UDim2.fromOffset(rippleSize, rippleSize),
		BackgroundTransparency = 1
	}, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	-- Cleanup
	task.delay(0.5, function()
		ripple:Destroy()
	end)
end

-- Gradient text support
function Utilities:CreateGradient(colors, rotation)
	local gradient = Utilities:Create("UIGradient", {
		Color = ColorSequence.new(colors),
		Rotation = rotation or 0
	})
	return gradient
end

-- ============================================
-- PROTECTED INSTANCE CREATION
-- ============================================

local function CreateProtectedInstance(className, properties)
	-- Create with basic properties first
	local instance = Instance.new(className)
	
	-- Apply properties
	for prop, value in pairs(properties or {}) do
		-- Handle nested instances
		if type(value) == "table" and value.__type == "instance" then
			instance[prop] = value.instance
		else
			pcall(function()
				instance[prop] = value
			end)
		end
	end
	
	table.insert(Instances, instance)
	return instance
end

-- ============================================
-- COMPONENT BASE CLASS
-- ============================================

local Component = {}
Component.__index = Component

function Component:New(data)
	local self = setmetatable({}, Component)
	self.Data = data or {}
	self.Elements = {}
	self.Connections = {}
	self.Destroyed = false
	return self
end

function Component:Destroy()
	self.Destroyed = true
	for _, conn in pairs(self.Connections) do
		pcall(conn.Disconnect, conn)
	end
	for _, element in pairs(self.Elements) do
		pcall(element.Destroy, element)
	end
	table.clear(self.Connections)
	table.clear(self.Elements)
end

-- ============================================
-- WINDOW
-- ============================================

local Window = {}
Window.__index = Window

function Fluent:CreateWindow(config)
	config = config or {}
	
	local self = setmetatable({}, Window)
	self.Config = {
		Title = config.Title or "Fluent UI",
		Size = config.Size or UDim2.new(0, 620, 0, 480),
		Position = config.Position or UDim2.new(0.5, -310, 0.5, -240),
		MinSize = config.MinSize or Vector2.new(400, 300),
		Keybind = config.Keybind or nil,
		Theme = config.Theme or "dark",
		Transparency = config.Transparency or 0,
		ShowNotifications = config.ShowNotifications ~= false,
	}
	
	self.Tabs = {}
	self.ActiveTab = nil
	self.Components = {}
	self.Connections = {}
	self.MouseInside = false
	
	-- Main ScreenGui
	self.ScreenGui = CreateProtectedInstance("ScreenGui", {
		Name = "FluentUI",
		DisplayOrder = 999,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
	})
	
	-- Main Frame
	self.Main = CreateProtectedInstance("Frame", {
		Name = "Window",
		Parent = self.ScreenGui,
		BackgroundColor3 = DefaultTheme.Background,
		Size = self.Config.Size,
		Position = self.Config.Position,
		ClipsDescendants = true,
		BorderSize = 0,
	})
	
	-- Shadow
	self.Shadow = CreateProtectedInstance("ImageLabel", {
		Name = "Shadow",
		Parent = self.Main,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 40, 1, 40),
		Position = UDim2.new(-0.03, -10, -0.04, -10),
		ZIndex = 0,
		Image = "rbxassetid://6014261993",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.6,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118),
	})
	
	-- Corner
	CreateProtectedInstance("UICorner", {
		Parent = self.Main,
		CornerRadius = UDim.new(0, 8),
	})
	
	-- Stroke (border)
	CreateProtectedInstance("UIStroke", {
		Parent = self.Main,
		Color = Color3.fromRGB(55, 55, 55),
		Thickness = 1,
		Transparency = 0,
	})
	
	-- ============================================
	-- TITLE BAR
	-- ============================================
	
	self.TitleBar = CreateProtectedInstance("Frame", {
		Name = "TitleBar",
		Parent = self.Main,
		BackgroundColor3 = DefaultTheme.BackgroundSecondary,
		Size = UDim2.new(1, 0, 0, 40),
		BorderSize = 0,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = self.TitleBar,
		CornerRadius = UDim.new(0, 8),
	})
	
	-- Top-left corner cover
	CreateProtectedInstance("Frame", {
		Name = "TopLeftCover",
		Parent = self.TitleBar,
		BackgroundColor3 = DefaultTheme.BackgroundSecondary,
		Size = UDim2.new(0, 20, 0, 10),
		Position = UDim2.new(0, 0, 1, -10),
		BorderSize = 0,
	})
	
	-- Top-right corner cover
	CreateProtectedInstance("Frame", {
		Name = "TopRightCover",
		Parent = self.TitleBar,
		BackgroundColor3 = DefaultTheme.BackgroundSecondary,
		Size = UDim2.new(0, 20, 0, 10),
		Position = UDim2.new(1, -20, 1, -10),
		BorderSize = 0,
	})
	
	-- Title Bar Bottom Line
	CreateProtectedInstance("Frame", {
		Name = "TitleBarLine",
		Parent = self.TitleBar,
		BackgroundColor3 = DefaultTheme.Border,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BorderSize = 0,
	})
	
	-- Title Icon
	self.TitleIcon = CreateProtectedInstance("ImageLabel", {
		Name = "TitleIcon",
		Parent = self.TitleBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(0, 14, 0, 10),
		Image = "rbxassetid://6031094678", -- Your actual icon can be replaced
		ImageColor3 = DefaultTheme.Accent,
	})
	
	-- Title Label
	self.TitleLabel = CreateProtectedInstance("TextLabel", {
		Name = "Title",
		Parent = self.TitleBar,
		BackgroundTransparency = 1,
		Font = DefaultTheme.Font,
		Text = self.Config.Title,
		TextColor3 = DefaultTheme.Text,
		TextSize = 16,
		Position = UDim2.new(0, 44, 0, 0),
		Size = UDim2.new(1, -140, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	})
	
	-- ============================================
	-- WINDOW CONTROLS
	-- ============================================
	
	-- Minimize Button
	self.MinimizeBtn = CreateProtectedInstance("TextButton", {
		Name = "Minimize",
		Parent = self.TitleBar,
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		Size = UDim2.new(0, 34, 0, 26),
		Position = UDim2.new(1, -112, 0, 7),
		Text = "−",
		TextColor3 = DefaultTheme.Text,
		TextSize = 18,
		Font = Enum.Font.Gotham,
		AutoButtonColor = false,
		BorderSize = 0,
		ZIndex = 5,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = self.MinimizeBtn,
		CornerRadius = UDim.new(0, 4),
	})
	
	-- Maximize Button
	self.MaximizeBtn = CreateProtectedInstance("TextButton", {
		Name = "Maximize",
		Parent = self.TitleBar,
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		Size = UDim2.new(0, 34, 0, 26),
		Position = UDim2.new(1, -75, 0, 7),
		Text = "□",
		TextColor3 = DefaultTheme.Text,
		TextSize = 14,
		Font = Enum.Font.Gotham,
		AutoButtonColor = false,
		BorderSize = 0,
		ZIndex = 5,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = self.MaximizeBtn,
		CornerRadius = UDim.new(0, 4),
	})
	
	-- Close Button
	self.CloseBtn = CreateProtectedInstance("TextButton", {
		Name = "Close",
		Parent = self.TitleBar,
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		Size = UDim2.new(0, 34, 0, 26),
		Position = UDim2.new(1, -38, 0, 7),
		Text = "✕",
		TextColor3 = DefaultTheme.Text,
		TextSize = 14,
		Font = Enum.Font.Gotham,
		AutoButtonColor = false,
		BorderSize = 0,
		ZIndex = 5,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = self.CloseBtn,
		CornerRadius = UDim.new(0, 4),
	})
	
	-- ============================================
	-- NAVIGATION (TABS SIDEBAR)
	-- ============================================
	
	self.NavBar = CreateProtectedInstance("Frame", {
		Name = "Navigation",
		Parent = self.Main,
		BackgroundColor3 = DefaultTheme.TabBackground,
		Size = UDim2.new(0, 48, 1, -41),
		Position = UDim2.new(0, 0, 0, 41),
		BorderSize = 0,
	})
	
	-- Nav bar right border
	CreateProtectedInstance("Frame", {
		Name = "NavBorder",
		Parent = self.NavBar,
		BackgroundColor3 = DefaultTheme.Border,
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		BorderSize = 0,
	})
	
	-- Tab buttons container (ScrollingFrame)
	self.TabContainer = CreateProtectedInstance("ScrollingFrame", {
		Name = "TabContainer",
		Parent = self.NavBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 0,
		BorderSize = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	})
	
	-- Tab indicator (the blue line indicating active tab)
	self.TabIndicator = CreateProtectedInstance("Frame", {
		Name = "TabIndicator",
		Parent = self.NavBar,
		BackgroundColor3 = DefaultTheme.Accent,
		Size = UDim2.new(0, 3, 0, 0),
		Position = UDim2.new(1, -3, 0, 10),
		BorderSize = 0,
		ZIndex = 3,
	})
	
	-- ============================================
	-- PAGE CONTAINER
	-- ============================================
	
	self.PageContainer = CreateProtectedInstance("Frame", {
		Name = "PageContainer",
		Parent = self.Main,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -49, 1, -41),
		Position = UDim2.new(0, 49, 0, 41),
		BorderSize = 0,
		ClipsDescendants = true,
	})
	
	-- ============================================
	-- HOOK UP DRAGGING
	-- ============================================
	
	Utilities:MakeDraggable(self.Main, self.TitleBar)
	
	-- ============================================
	-- WINDOW CONTROL EVENTS
	-- ============================================
	
	-- Close
	self.CloseBtn.MouseButton1Click:Connect(function()
		self:Destroy()
	end)
	
	-- Close button hover
	self.CloseBtn.MouseEnter:Connect(function()
		Utilities:Tween(self.CloseBtn, {BackgroundColor3 = Color3.fromRGB(196, 43, 28)}, 0.1)
	end)
	self.CloseBtn.MouseLeave:Connect(function()
		Utilities:Tween(self.CloseBtn, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}, 0.15)
	end)
	
	-- Minimize
	self.MinimizeBtn.MouseButton1Click:Connect(function()
		self:SetMinimized(not self._Minimized)
	end)
	
	-- Minimize hover
	local minDefault = Color3.fromRGB(45, 45, 45)
	self.MinimizeBtn.MouseEnter:Connect(function()
		Utilities:Tween(self.MinimizeBtn, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.1)
	end)
	self.MinimizeBtn.MouseLeave:Connect(function()
		Utilities:Tween(self.MinimizeBtn, {BackgroundColor3 = minDefault}, 0.15)
	end)
	
	-- Maximize hover
	self.MaximizeBtn.MouseEnter:Connect(function()
		Utilities:Tween(self.MaximizeBtn, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.1)
	end)
	self.MaximizeBtn.MouseLeave:Connect(function()
		Utilities:Tween(self.MaximizeBtn, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}, 0.15)
	end)
	
	-- Maximize
	self.MaximizeBtn.MouseButton1Click:Connect(function()
		self:ToggleMaximize()
	end)
	
	-- ============================================
	-- KEYBIND TOGGLE
	-- ============================================
	
	if self.Config.Keybind then
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			if input.KeyCode == self.Config.Keybind then
				self:ToggleVisibility()
			end
		end)
	end
	
	-- Ensure it shows
	self.ScreenGui.Enabled = true
	
	-- Add to active windows
	table.insert(ActiveWindows, self)
	
	return self
end

-- Window:SetMinimized
function Window:SetMinimized(minimized)
	self._Minimized = minimized
	if minimized then
		Utilities:Tween(self.Main, {Size = UDim2.new(0, self.Config.Size.X.Offset, 0, 40)}, 0.2)
		self.PageContainer.Visible = false
		self.NavBar.Visible = false
	else
		self.PageContainer.Visible = true
		self.NavBar.Visible = true
		Utilities:Tween(self.Main, {Size = self.Config.Size}, 0.2)
	end
end

-- Window:ToggleVisibility
function Window:ToggleVisibility()
	self.ScreenGui.Enabled = not self.ScreenGui.Enabled
end

-- Window:SetVisibility
function Window:SetVisibility(visible)
	self.ScreenGui.Enabled = visible
end

-- Window:ToggleMaximize
function Window:ToggleMaximize()
	if self._Maximized then
		-- Restore
		Utilities:Tween(self.Main, {
			Size = self._PreviousSize or self.Config.Size,
			Position = self._PreviousPosition or self.Config.Position,
		}, 0.2)
		self._Maximized = false
	else
		-- Save previous position/size
		self._PreviousSize = self.Main.Size
		self._PreviousPosition = self.Main.Position
		
		-- Maximize
		local viewportSize = workspace.CurrentCamera.ViewportSize
		Utilities:Tween(self.Main, {
			Size = UDim2.new(0, viewportSize.X - 40, 0, viewportSize.Y - 40),
			Position = UDim2.new(0, 20, 0, 20),
		}, 0.2)
		self._Maximized = true
	end
end

-- Window:AddTab
function Window:AddTab(title, icon)
	local tab = Tab:New(self, title, icon)
	table.insert(self.Tabs, tab)
	
	-- If no active tab, set this one as active
	if not self.ActiveTab then
		tab:Activate()
	end
	
	return tab
end

-- Window:Destroy
function Window:Destroy()
	self.ScreenGui:Destroy()
	for _, conn in pairs(self.Connections) do
		pcall(conn.Disconnect, conn)
	end
	for _, window in ipairs(ActiveWindows) do
		if window == self then
			table.remove(ActiveWindows, table.find(ActiveWindows, self))
		end
	end
end

-- Window:SelectTab(index/name)
function Window:SelectTab(identifier)
	for _, tab in ipairs(self.Tabs) do
		if type(identifier) == "number" then
			if tab.Index == identifier then
				tab:Activate()
				return
			end
		elseif type(identifier) == "string" then
			if tab.Title == identifier then
				tab:Activate()
				return
			end
		end
	end
end

-- ============================================
-- TAB
-- ============================================

local Tab = {}
Tab.__index = Tab

function Tab:New(window, title, icon)
	local self = setmetatable({}, Tab)
	self.Window = window
	self.Title = title or "Tab"
	self.Icon = icon or nil
	self.Index = #window.Tabs + 1
	self.Sections = {}
	self.Destroyed = false
	self.Active = false
	
	-- Tab button in navigation
	self.Button = CreateProtectedInstance("TextButton", {
		Name = "Tab_" .. title:gsub("%s+", "_"),
		Parent = window.TabContainer,
		BackgroundColor3 = Color3.fromRGB(28, 28, 28),
		Size = UDim2.new(1, 0, 0, 44),
		Position = UDim2.new(0, 0, 0, (self.Index - 1) * 44),
		Text = "",
		AutoButtonColor = false,
		BorderSize = 0,
	})
	
	-- Tab icon (if provided, or use first letter)
	local displayText = icon or string.upper(string.sub(title, 1, 1))
	
	self.TabLabel = CreateProtectedInstance("TextLabel", {
		Name = "TabLabel",
		Parent = self.Button,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = displayText,
		TextColor3 = DefaultTheme.TabInactive,
		TextSize = 18,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		TextYAlignment = Enum.TextYAlignment.Center,
	})
	
	-- Tooltip
	self.Tooltip = CreateProtectedInstance("Frame", {
		Name = "Tooltip",
		Parent = self.Button,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(1, 10, 0, 6),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 100,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = self.Tooltip,
		CornerRadius = UDim.new(0, 4),
	})
	
	self.TooltipLabel = CreateProtectedInstance("TextLabel", {
		Name = "TooltipLabel",
		Parent = self.Tooltip,
		BackgroundTransparency = 1,
		Font = DefaultTheme.Font,
		Text = title,
		TextColor3 = DefaultTheme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	
	-- Page frame (content area for this tab)
	self.Page = CreateProtectedInstance("ScrollingFrame", {
		Name = title,
		Parent = window.PageContainer,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 1, -20),
		Position = UDim2.new(0, 10, 0, 10),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = DefaultTheme.Scrollbar,
		BorderSize = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
	})
	
	-- Initially hidden
	self.Page.Visible = false
	
	-- Tooltip hovering
	self.Button.MouseEnter:Connect(function()
		if not self.Active then
			Utilities:Tween(self.TabLabel, {TextColor3 = DefaultTheme.Text}, 0.1)
		end
	end)
	self.Button.MouseLeave:Connect(function()
		if not self.Active then
			Utilities:Tween(self.TabLabel, {TextColor3 = DefaultTheme.TabInactive}, 0.15)
		end
	end)
	
	-- Click to activate
	self.Button.MouseButton1Click:Connect(function()
		self:Activate()
	end)
	
	-- Add padding to page
	self.PagePadding = CreateProtectedInstance("UIPadding", {
		Parent = self.Page,
		PaddingTop = UDim.new(0, 0),
		PaddingBottom = UDim.new(0, 20),
		PaddingLeft = UDim.new(0, 0),
		PaddingRight = UDim.new(0, 0),
	})
	
	return self
end

function Tab:Activate()
	if self.Destroyed then return end
	
	-- Deactivate all other tabs
	for _, tab in ipairs(self.Window.Tabs) do
		if tab ~= self then
			tab:Deactivate()
		end
	end
	
	self.Active = true
	self.Page.Visible = true
	self.Window.ActiveTab = self
	
	-- Update indicator position
	local targetY = (self.Index - 1) * 44 + 10
	Utilities:Tween(self.Window.TabIndicator, {
		Position = UDim2.new(1, -3, 0, targetY)
	}, 0.15)
	
	-- Update tab label color
	Utilities:Tween(self.TabLabel, {
		TextColor3 = DefaultTheme.Accent,
		TextSize = 20,
	}, 0.15)
	
	-- Update button background
	Utilities:Tween(self.Button, {
		BackgroundColor3 = Color3.fromRGB(24, 24, 24)
	}, 0.1)
end

function Tab:Deactivate()
	self.Active = false
	self.Page.Visible = false
	
	Utilities:Tween(self.TabLabel, {
		TextColor3 = DefaultTheme.TabInactive,
		TextSize = 18,
	}, 0.15)
	
	Utilities:Tween(self.Button, {
		BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	}, 0.1)
end

-- Tab:AddSection
function Tab:AddSection(title)
	local section = Section:New(self, title)
	table.insert(self.Sections, section)
	
	-- Update canvas size
	self.Page.CanvasSize = UDim2.new(0, 0, 0, self.Page.UIListLayout and self.Page.UIListLayout.AbsoluteContentSize.Y or 0)
	
	return section
end

-- Tab:AddButton (convenience)
function Tab:AddButton(text, callback, description)
	local section = self:AddSection("")
	return section:AddButton(text, callback, description)
end

-- Tab:AddToggle (convenience)
function Tab:AddToggle(config)
	local section = self:AddSection("")
	return section:AddToggle(config)
end

-- Tab:AddSlider (convenience)
function Tab:AddSlider(config)
	local section = self:AddSection("")
	return section:AddSlider(config)
end

-- Tab:AddDropdown (convenience)
function Tab:AddDropdown(config)
	local section = self:AddSection("")
	return section:AddDropdown(config)
end

-- Tab:AddLabel (convenience)
function Tab:AddLabel(text, description)
	local section = self:AddSection("")
	return section:AddLabel(text, description)
end

-- Tab:AddKeybind (convenience)
function Tab:AddKeybind(config)
	local section = self:AddSection("")
	return section:AddKeybind(config)
end

-- Tab:AddParagraph (convenience)
function Tab:AddParagraph(title, content)
	local section = self:AddSection("")
	return section:AddParagraph(title, content)
end

-- Tab:AddTextbox (convenience)
function Tab:AddTextbox(config)
	local section = self:AddSection("")
	return section:AddTextbox(config)
end

-- Tab:Destroy
function Tab:Destroy()
	self.Destroyed = true
	self.Button:Destroy()
	self.Page:Destroy()
end

-- ============================================
-- SECTION
-- ============================================

local Section = {}
Section.__index = Section

function Section:New(tab, title)
	local self = setmetatable({}, Section)
	self.Tab = tab
	self.Title = title or ""
	self.Components = {}
	self.Destroyed = false
	
	-- Section container
	self.Container = CreateProtectedInstance("Frame", {
		Name = "Section_" .. (title or ""):gsub("%s+", "_"),
		Parent = tab.Page,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderSize = 0,
	})
	
	-- Section padding
	CreateProtectedInstance("UIPadding", {
		Parent = self.Container,
		PaddingTop = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 0),
		PaddingRight = UDim.new(0, 0),
	})
	
	-- Section layout
	self.SectionLayout = CreateProtectedInstance("UIListLayout", {
		Parent = self.Container,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
	})
	
	-- Section title if provided
	if title and title ~= "" then
		self.TitleLabel = CreateProtectedInstance("TextLabel", {
			Name = "SectionTitle",
			Parent = self.Container,
			BackgroundTransparency = 1,
			Font = DefaultTheme.Font,
			Text = title,
			TextColor3 = DefaultTheme.Accent,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, 5, 0, 0),
			Size = UDim2.new(1, -10, 0, 22),
			LayoutOrder = 0,
			BorderSize = 0,
		})
		
		-- Underline
		CreateProtectedInstance("Frame", {
			Name = "TitleUnderline",
			Parent = self.Container,
			BackgroundColor3 = DefaultTheme.Border,
			Size = UDim2.new(1, -10, 0, 1),
			Position = UDim2.new(0, 5, 0, 22),
			LayoutOrder = 0,
			BorderSize = 0,
		})
	end
	
	-- Canvas update
	local function updateCanvas()
		if self.Tab and self.Tab.Page then
			self.Tab.Page.CanvasSize = UDim2.new(0, 0, 0, self.Tab.Page.UIListLayout and self.Tab.Page.UIListLayout.AbsoluteContentSize.Y or 0)
		end
	end
	
	-- Listen for changes
	self.SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
	
	return self
end

-- ============================================
-- BUTTON COMPONENT
-- ============================================

function Section:AddButton(text, callback, description)
	local button = {}
	
	-- Outer container
	button.Container = CreateProtectedInstance("Frame", {
		Name = "Button_" .. (text or ""):gsub("%s+", "_"),
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 38),
		Position = UDim2.new(0, 5, 0, 0),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	
	-- Button frame
	button.Frame = CreateProtectedInstance("Frame", {
		Name = "ButtonFrame",
		Parent = button.Container,
		BackgroundColor3 = DefaultTheme.Button,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSize = 0,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = button.Frame,
		CornerRadius = DefaultTheme.CornerRadius,
	})
	
	-- Text label
	button.Label = CreateProtectedInstance("TextLabel", {
		Name = "ButtonLabel",
		Parent = button.Frame,
		BackgroundTransparency = 1,
		Font = DefaultTheme.Font,
		Text = text,
		TextColor3 = DefaultTheme.Text,
		TextSize = DefaultTheme.TextSize,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -24, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSize = 0,
	})
	
	-- Description label (if provided)
	if description then
		button.Description = CreateProtectedInstance("TextLabel", {
			Name = "Description",
			Parent = button.Frame,
			BackgroundTransparency = 1,
			Font = DefaultTheme.FontSecondary,
			Text = description,
			TextColor3 = DefaultTheme.TextMuted,
			TextSize = DefaultTheme.TextSizeSmall,
			Position = UDim2.new(0, 12, 0, 0),
			Size = UDim2.new(1, -24, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Center,
			BorderSize = 0,
		})
		
		button.Label.TextXAlignment = Enum.TextXAlignment.Left
		button.Label.TextYAlignment = Enum.TextYAlignment.Center
	end
	
	-- Clickable button overlay (TextButton for interaction)
	button.Button = CreateProtectedInstance("TextButton", {
		Name = "ClickArea",
		Parent = button.Frame,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 2,
		BorderSize = 0,
	})
	
	-- Ripple effect
	button.Button.MouseButton1Click:Connect(function()
		if callback then
			pcall(callback)
		end
	end)
	
	-- Hover effects
	button.Button.MouseEnter:Connect(function()
		Utilities:Tween(button.Frame, {BackgroundColor3 = DefaultTheme.ButtonHover}, 0.1)
	end)
	
	button.Button.MouseLeave:Connect(function()
		Utilities:Tween(button.Frame, {BackgroundColor3 = DefaultTheme.Button}, 0.15)
	end)
	
	-- Press effect
	button.Button.MouseButton1Down:Connect(function()
		Utilities:Tween(button.Frame, {BackgroundColor3 = DefaultTheme.ButtonPress}, 0.05)
	end)
	
	button.Button.MouseButton1Up:Connect(function()
		Utilities:Tween(button.Frame, {BackgroundColor3 = DefaultTheme.ButtonHover}, 0.08)
	end)
	
	-- Method to update text
	function button:SetText(newText)
		self.Label.Text = newText
	end
	
	function button:SetCallback(newCallback)
		callback = newCallback
	end
	
	function button:Destroy()
		button.Container:Destroy()
	end
	
	table.insert(self.Components, button)
	return button
end

-- ============================================
-- ACCENT BUTTON (Filled with accent color)
-- ============================================

function Section:AddAccentButton(text, callback, description)
	local button = {}
	
	button.Container = CreateProtectedInstance("Frame", {
		Name = "AccentButton_" .. (text or ""):gsub("%s+", "_"),
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 38),
		Position = UDim2.new(0, 5, 0, 0),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	
	button.Frame = CreateProtectedInstance("Frame", {
		Name = "ButtonFrame",
		Parent = button.Container,
		BackgroundColor3 = DefaultTheme.ButtonAccent,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSize = 0,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = button.Frame,
		CornerRadius = DefaultTheme.CornerRadius,
	})
	
	button.Label = CreateProtectedInstance("TextLabel", {
		Name = "ButtonLabel",
		Parent = button.Frame,
		BackgroundTransparency = 1,
		Font = DefaultTheme.Font,
		Text = text,
		TextColor3 = DefaultTheme.TextInverse,
		TextSize = DefaultTheme.TextSize,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -24, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Center,
		BorderSize = 0,
	})
	
	button.Button = CreateProtectedInstance("TextButton", {
		Name = "ClickArea",
		Parent = button.Frame,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 2,
		BorderSize = 0,
	})
	
	button.Button.MouseButton1Click:Connect(function()
		if callback then
			pcall(callback)
		end
	end)
	
	button.Button.MouseEnter:Connect(function()
		Utilities:Tween(button.Frame, {BackgroundColor3 = DefaultTheme.ButtonAccentHover}, 0.1)
	end)
	
	button.Button.MouseLeave:Connect(function()
		Utilities:Tween(button.Frame, {BackgroundColor3 = DefaultTheme.ButtonAccent}, 0.15)
	end)
	
	button.Button.MouseButton1Down:Connect(function()
		Utilities:Tween(button.Frame, {BackgroundColor3 = DefaultTheme.AccentDark}, 0.05)
	end)
	
	button.Button.MouseButton1Up:Connect(function()
		Utilities:Tween(button.Frame, {BackgroundColor3 = DefaultTheme.ButtonAccentHover}, 0.08)
	end)
	
	function button:SetText(newText)
		self.Label.Text = newText
	end
	
	function button:Destroy()
		button.Container:Destroy()
	end
	
	table.insert(self.Components, button)
	return button
end

-- ============================================
-- TOGGLE COMPONENT
-- ============================================

function Section:AddToggle(config)
	config = config or {}
	
	local toggle = {}
	toggle.Value = config.Default or false
	toggle.Callback = config.Callback or config.OnChanged or config.callback or function() end
	toggle.Title = config.Title or config.title or "Toggle"
	toggle.Description = config.Description or config.description or nil
	toggle.Flag = config.Flag or nil
	
	-- Container
	toggle.Container = CreateProtectedInstance("Frame", {
		Name = "Toggle_" .. (toggle.Title):gsub("%s+", "_"),
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 36),
		Position = UDim2.new(0, 5, 0, 0),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	
	-- Background
	toggle.Background = CreateProtectedInstance("Frame", {
		Name = "ToggleBackground",
		Parent = toggle.Container,
		BackgroundColor3 = DefaultTheme.BackgroundTertiary,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSize = 0,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = toggle.Background,
		CornerRadius = DefaultTheme.CornerRadius,
	})
	
	-- Title
	toggle.Label = CreateProtectedInstance("TextLabel", {
		Name = "ToggleLabel",
		Parent = toggle.Background,
		BackgroundTransparency = 1,
		Font = DefaultTheme.Font,
		Text = toggle.Title,
		TextColor3 = DefaultTheme.Text,
		TextSize = DefaultTheme.TextSize,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -80, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSize = 0,
	})
	
	-- Description (below title)
	if toggle.Description then
		toggle.Label.Position = UDim2.new(0, 12, 0, 2)
		toggle.Label.Size = UDim2.new(1, -80, 0, 16)
		toggle.Label.TextYAlignment = Enum.TextYAlignment.Bottom
		
		toggle.DescLabel = CreateProtectedInstance("TextLabel", {
			Name = "ToggleDesc",
			Parent = toggle.Background,
			BackgroundTransparency = 1,
			Font = DefaultTheme.FontSecondary,
			Text = toggle.Description,
			TextColor3 = DefaultTheme.TextMuted,
			TextSize = DefaultTheme.TextSizeSmall - 1,
			Position = UDim2.new(0, 12, 0, 18),
			Size = UDim2.new(1, -80, 0, 14),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			BorderSize = 0,
		})
	end
	
	-- Toggle track
	toggle.Track = CreateProtectedInstance("Frame", {
		Name = "ToggleTrack",
		Parent = toggle.Background,
		BackgroundColor3 = toggle.Value and DefaultTheme.ToggleOn or DefaultTheme.ToggleOff,
		Size = UDim2.new(0, 44, 0, 22),
		Position = UDim2.new(1, -56, 0.5, -11),
		BorderSize = 0,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = toggle.Track,
		CornerRadius = UDim.new(1, 0),
	})
	
	-- Toggle thumb
	toggle.Thumb = CreateProtectedInstance("Frame", {
		Name = "ToggleThumb",
		Parent = toggle.Track,
		BackgroundColor3 = DefaultTheme.ToggleThumb,
		Size = UDim2.new(0, 18, 0, 18),
		Position = toggle.Value and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
		BorderSize = 0,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = toggle.Thumb,
		CornerRadius = UDim.new(1, 0),
	})
	
	-- Shadow on thumb
	CreateProtectedInstance("UIStroke", {
		Parent = toggle.Thumb,
		Color = Color3.fromRGB(30, 30, 30),
		Thickness = 0.5,
		Transparency = 0.5,
	})
	
	-- Click area
	toggle.Button = CreateProtectedInstance("TextButton", {
		Name = "ClickArea",
		Parent = toggle.Background,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 2,
		BorderSize = 0,
	})
	
	-- Toggle function
	local function setToggleState(value)
		toggle.Value = value
		
		if toggle.Value then
			Utilities:Tween(toggle.Track, {BackgroundColor3 = DefaultTheme.ToggleOn}, 0.12)
			Utilities:Tween(toggle.Thumb, {
				Position = UDim2.new(1, -20, 0.5, -9),
				Size = UDim2.new(0, 16, 0, 16)
			}, 0.15)
		else
			Utilities:Tween(toggle.Track, {BackgroundColor3 = DefaultTheme.ToggleOff}, 0.12)
			Utilities:Tween(toggle.Thumb, {
				Position = UDim2.new(0, 3, 0.5, -9),
				Size = UDim2.new(0, 16, 0, 16)
			}, 0.15)
		end
		
		-- Callback
		pcall(toggle.Callback, toggle.Value)
		
		-- Update flag
		if toggle.Flag and Fluent.Flags then
			Fluent.Flags[toggle.Flag] = toggle.Value
		end
	end
	
	toggle.Button.MouseButton1Click:Connect(function()
		setToggleState(not toggle.Value)
	end)
	
	-- Hover effect on background
	toggle.Button.MouseEnter:Connect(function()
		Utilities:Tween(toggle.Background, {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}, 0.1)
	end)
	
	toggle.Button.MouseLeave:Connect(function()
		Utilities:Tween(toggle.Background, {BackgroundColor3 = DefaultTheme.BackgroundTertiary}, 0.15)
	end)
	
	-- Methods
	function toggle:SetValue(value)
		setToggleState(value)
	end
	
	function toggle:GetValue()
		return toggle.Value
	end
	
	function toggle:SetCallback(cb)
		toggle.Callback = cb
	end
	
	function toggle:Destroy()
		toggle.Container:Destroy()
	end
	
	table.insert(self.Components, toggle)
	return toggle
end

-- ============================================
-- SLIDER COMPONENT
-- ============================================

function Section:AddSlider(config)
	config = config or {}
	
	local slider = {}
	slider.Value = config.Default or config.DefaultValue or 0
	slider.Min = config.Min or config.MinValue or 0
	slider.Max = config.Max or config.MaxValue or 100
	slider.Suffix = config.Suffix or config.Unit or config.unit or ""
	slider.Precision = config.Precision or config.DecimalPlaces or 0
	slider.Callback = config.Callback or config.OnChanged or config.callback or function() end
	slider.Title = config.Title or config.title or "Slider"
	slider.Description = config.Description or config.description or nil
	slider.Flag = config.Flag or nil
	slider.Dragging = false
	
	-- Container
	slider.Container = CreateProtectedInstance("Frame", {
		Name = "Slider_" .. (slider.Title):gsub("%s+", "_"),
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 48),
		Position = UDim2.new(0, 5, 0, 0),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	
	-- Background
	slider.Background = CreateProtectedInstance("Frame", {
		Name = "SliderBackground",
		Parent = slider.Container,
		BackgroundColor3 = DefaultTheme.BackgroundTertiary,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSize = 0,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = slider.Background,
		CornerRadius = DefaultTheme.CornerRadius,
	})
	
	-- Title
	slider.Label = CreateProtectedInstance("TextLabel", {
		Name = "SliderLabel",
		Parent = slider.Background,
		BackgroundTransparency = 1,
		Font = DefaultTheme.Font,
		Text = slider.Title,
		TextColor3 = DefaultTheme.Text,
		TextSize = DefaultTheme.TextSize,
		Position = UDim2.new(0, 12, 0, 6),
		Size = UDim2.new(1, -80, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSize = 0,
	})
	
	-- Value display
	slider.ValueLabel = CreateProtectedInstance("TextLabel", {
		Name = "SliderValue",
		Parent = slider.Background,
		BackgroundTransparency = 1,
		Font = DefaultTheme.Font,
		Text = tostring(slider.Value) .. slider.Suffix,
		TextColor3 = DefaultTheme.Accent,
		TextSize = DefaultTheme.TextSize,
		Position = UDim2.new(0, 0, 0, 6),
		Size = UDim2.new(1, -20, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSize = 0,
	})
	
	-- Track background
	slider.Track = CreateProtectedInstance("Frame", {
		Name = "SliderTrack",
		Parent = slider.Background,
		BackgroundColor3 = DefaultTheme.SliderTrack,
		Size = UDim2.new(1, -24, 0, 4),
		Position = UDim2.new(0, 12, 1, -14),
		BorderSize = 0,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = slider.Track,
		CornerRadius = UDim.new(1, 0),
	})
	
	-- Fill
	slider.Fill = CreateProtectedInstance("Frame", {
		Name = "SliderFill",
		Parent = slider.Track,
		BackgroundColor3 = DefaultTheme.SliderFill,
		Size = UDim2.new(0, 0, 1, 0),
		BorderSize = 0,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = slider.Fill,
		CornerRadius = UDim.new(1, 0),
	})
	
	-- Thumb (draggable)
	slider.Thumb = CreateProtectedInstance("Frame", {
		Name = "SliderThumb",
		Parent = slider.Track,
		BackgroundColor3 = DefaultTheme.SliderThumb,
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0, 0, 0.5, -8),
		BorderSize = 0,
		ZIndex = 3,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = slider.Thumb,
		CornerRadius = UDim.new(1, 0),
	})
	
	-- Thumb shadow
	CreateProtectedInstance("UIStroke", {
		Parent = slider.Thumb,
		Color = Color3.fromRGB(30, 30, 30),
		Thickness = 1,
		Transparency = 0.4,
	})
	
	-- Clickable area for the whole slider
	slider.Button = CreateProtectedInstance("TextButton", {
		Name = "ClickArea",
		Parent = slider.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 4,
		BorderSize = 0,
	})
	
	-- Update slider position based on mouse
	local function updateSlider(input)
		local trackPos = slider.Track.AbsolutePosition
		local trackSize = slider.Track.AbsoluteSize.X
		local mouseX = input.Position.X
		
		local relativeX = math.clamp(mouseX - trackPos.X, 0, trackSize)
		local percentage = relativeX / trackSize
		
		-- Calculate value
		local valueRange = slider.Max - slider.Min
		local rawValue = slider.Min + (percentage * valueRange)
		local value = math.floor(rawValue * (10 ^ slider.Precision) + 0.5) / (10 ^ slider.Precision)
		
		slider.Value = value
		
		-- Update visuals
		slider.Fill.Size = UDim2.new(percentage, 0, 1, 0)
		slider.Thumb.Position = UDim2.new(percentage, -8, 0.5, -8)
		slider.ValueLabel.Text = tostring(value) .. slider.Suffix
		
		-- Callback
		pcall(slider.Callback, value)
		
		-- Flag
		if slider.Flag and Fluent.Flags then
			Fluent.Flags[slider.Flag] = value
		end
	end
	
	-- Click to set position
	slider.Button.MouseButton1Click:Connect(function(input)
		updateSlider(input)
	end)
	
	-- Drag handling
	slider.Button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			slider.Dragging = true
			updateSlider(input)
		end
	end)
	
	slider.Button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			slider.Dragging = false
		end
	end)
	
	-- Global mouse move for dragging
	local dragConnection = UserInputService.InputChanged:Connect(function(input)
		if slider.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider(input)
		end
	end)
	
	-- Hover effects
	slider.Button.MouseEnter:Connect(function()
		Utilities:Tween(slider.Background, {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}, 0.1)
	end)
	
	slider.Button.MouseLeave:Connect(function()
		Utilities:Tween(slider.Background, {BackgroundColor3 = DefaultTheme.BackgroundTertiary}, 0.15)
	end)
	
	-- Methods
	function slider:SetValue(value)
		local clamped = math.clamp(value, slider.Min, slider.Max)
		slider.Value = clamped
		
		local percentage = (clamped - slider.Min) / (slider.Max - slider.Min)
		
		slider.Fill.Size = UDim2.new(percentage, 0, 1, 0)
		slider.Thumb.Position = UDim2.new(percentage, -8, 0.5, -8)
		slider.ValueLabel.Text = tostring(clamped) .. slider.Suffix
		
		pcall(slider.Callback, clamped)
	end
	
	function slider:GetValue()
		return slider.Value
	end
	
	function slider:SetCallback(cb)
		slider.Callback = cb
	end
	
	function slider:Destroy()
		dragConnection:Disconnect()
		slider.Container:Destroy()
	end
	
	-- Set initial position
	if config.Default then
		slider:SetValue(config.Default)
	elseif config.DefaultValue then
		slider:SetValue(config.DefaultValue)
	end
	
	table.insert(self.Components, slider)
	return slider
end

-- ============================================
-- DROPDOWN COMPONENT
-- ============================================

function Section:AddDropdown(config)
	config = config or {}
	
	local dropdown = {}
	dropdown.Title = config.Title or config.title or "Dropdown"
	dropdown.Description = config.Description or config.description or nil
	dropdown.Values = config.Values or config.values or config.Options or config.options or {}
	dropdown.Default = config.Default or config.default or nil
	dropdown.Callback = config.Callback or config.OnChanged or config.callback or config.OnSelected or function() end
	dropdown.Flag = config.Flag or nil
	dropdown.Open = false
	dropdown.SelectedValue = dropdown.Default or (dropdown.Values[1] or "None")
	
	-- Container
	dropdown.Container = CreateProtectedInstance("Frame", {
		Name = "Dropdown_" .. (dropdown.Title):gsub("%s+", "_"),
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 36),
		Position = UDim2.new(0, 5, 0, 0),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
		ClipsDescendants = false,
		ZIndex = 10,
	})
	
	-- Background
	dropdown.Background = CreateProtectedInstance("Frame", {
		Name = "DropdownBackground",
		Parent = dropdown.Container,
		BackgroundColor3 = DefaultTheme.BackgroundTertiary,
		Size = UDim2.new(1, 0, 0, 36),
		BorderSize = 0,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = dropdown.Background,
		CornerRadius = DefaultTheme.CornerRadius,
	})
	
	-- Title
	dropdown.Label = CreateProtectedInstance("TextLabel", {
		Name = "DropdownLabel",
		Parent = dropdown.Background,
		BackgroundTransparency = 1,
		Font = DefaultTheme.Font,
		Text = dropdown.Title,
		TextColor3 = DefaultTheme.Text,
		TextSize = DefaultTheme.TextSize,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -80, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSize = 0,
	})
	
	-- Selected value display
	dropdown.ValueLabel = CreateProtectedInstance("TextLabel", {
		Name = "DropdownValue",
		Parent = dropdown.Background,
		BackgroundTransparency = 1,
		Font = DefaultTheme.FontSecondary,
		Text = tostring(dropdown.SelectedValue),
		TextColor3 = DefaultTheme.Accent,
		TextSize = DefaultTheme.TextSizeSmall,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -40, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSize = 0,
	})
	
	-- Arrow icon
	dropdown.Arrow = CreateProtectedInstance("TextLabel", {
		Name = "DropdownArrow",
		Parent = dropdown.Background,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "▼",
		TextColor3 = DefaultTheme.TextMuted,
		TextSize = 10,
		Position = UDim2.new(1, -24, 0, 0),
		Size = UDim2.new(0, 20, 1, 0),
		BorderSize = 0,
	})
	
	-- Dropdown list container
	dropdown.ListContainer = CreateProtectedInstance("Frame", {
		Name = "DropdownList",
		Parent = self.Container,
		BackgroundColor3 = DefaultTheme.BackgroundSecondary,
		Size = UDim2.new(1, -10, 0, 0),
		Position = UDim2.new(0, 5, 0, 38),
		BorderSize = 0,
		Visible = false,
		ClipsDescendants = true,
		ZIndex = 20,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = dropdown.ListContainer,
		CornerRadius = DefaultTheme.CornerRadius,
	})
	
	-- List stroke
	CreateProtectedInstance("UIStroke", {
		Parent = dropdown.ListContainer,
		Color = DefaultTheme.Border,
		Thickness = 1,
		Transparency = 0,
	})
	
	-- List layout
	dropdown.ListLayout = CreateProtectedInstance("UIListLayout", {
		Parent = dropdown.ListContainer,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
	})
	
	-- Create list items
	dropdown.ListItems = {}
	for i, value in ipairs(dropdown.Values) do
		local item = CreateProtectedInstance("TextButton", {
			Name = "Item_" .. tostring(value):gsub("%s+", "_"),
			Parent = dropdown.ListContainer,
			BackgroundColor3 = Color3.fromRGB(32, 32, 32),
			Size = UDim2.new(1, -8, 0, 30),
			Position = UDim2.new(0, 4, 0, 0),
			Text = tostring(value),
			TextColor3 = DefaultTheme.Text,
			TextSize = DefaultTheme.TextSizeSmall,
			Font = DefaultTheme.FontSecondary,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			AutoButtonColor = false,
			BorderSize = 0,
			ZIndex = 21,
		})
		
		CreateProtectedInstance("UIPadding", {
			Parent = item,
			PaddingLeft = UDim.new(0, 8),
		})
		
		CreateProtectedInstance("UICorner", {
			Parent = item,
			CornerRadius = DefaultTheme.CornerRadiusSmall,
		})
		
		item.MouseEnter:Connect(function()
			Utilities:Tween(item, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}, 0.08)
		end)
		
		item.MouseLeave:Connect(function()
			Utilities:Tween(item, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.1)
		end)
		
		item.MouseButton1Click:Connect(function()
			dropdown.SelectedValue = value
			dropdown.ValueLabel.Text = tostring(value)
			pcall(dropdown.Callback, value)
			
			if dropdown.Flag and Fluent.Flags then
				Fluent.Flags[dropdown.Flag] = value
			end
			
			dropdown:Close()
		end)
		
		table.insert(dropdown.ListItems, item)
	end
	
	-- Toggle button
	dropdown.Button = CreateProtectedInstance("TextButton", {
		Name = "ClickArea",
		Parent = dropdown.Background,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 11,
		BorderSize = 0,
	})
	
	dropdown.Button.MouseButton1Click:Connect(function()
		if dropdown.Open then
			dropdown:Close()
		else
			dropdown:Open()
		end
	end)
	
	-- Hover
	dropdown.Button.MouseEnter:Connect(function()
		Utilities:Tween(dropdown.Background, {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}, 0.1)
	end)
	
	dropdown.Button.MouseLeave:Connect(function()
		Utilities:Tween(dropdown.Background, {BackgroundColor3 = DefaultTheme.BackgroundTertiary}, 0.15)
	end)
	
	-- Methods
	function dropdown:Open()
		if dropdown.Open or #dropdown.Values == 0 then return end
		dropdown.Open = true
		dropdown.ListContainer.Visible = true
		dropdown.Arrow.Text = "▲"
		
		local itemCount = #dropdown.Values
		local listHeight = itemCount * 32 + 4
		dropdown.ListContainer.Size = UDim2.new(1, -10, 0, listHeight)
		dropdown.ListContainer.ZIndex = 20
		
		-- Update container ZIndex for all children
		for _, item in ipairs(dropdown.ListItems) do
			item.ZIndex = 21
		end
		
		Utilities:Tween(dropdown.Arrow, {Rotation = 180}, 0.15)
	end
	
	function dropdown:Close()
		if not dropdown.Open then return end
		dropdown.Open = false
		dropdown.Arrow.Text = "▼"
		Utilities:Tween(dropdown.Arrow, {Rotation = 0}, 0.12)
		
		task.delay(0.05, function()
			dropdown.ListContainer.Visible = false
		end)
	end
	
	function dropdown:SetValues(newValues)
		dropdown.Values = newValues
		dropdown:Close()
		
		-- Clear old items
		for _, item in ipairs(dropdown.ListItems) do
			item:Destroy()
		end
		table.clear(dropdown.ListItems)
		
		-- Create new items
		for i, value in ipairs(newValues) do
			local item = CreateProtectedInstance("TextButton", {
				Name = "Item_" .. tostring(value):gsub("%s+", "_"),
				Parent = dropdown.ListContainer,
				BackgroundColor3 = Color3.fromRGB(32, 32, 32),
				Size = UDim2.new(1, -8, 0, 30),
				Position = UDim2.new(0, 4, 0, 0),
				Text = tostring(value),
				TextColor3 = DefaultTheme.Text,
				TextSize = DefaultTheme.TextSizeSmall,
				Font = DefaultTheme.FontSecondary,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				AutoButtonColor = false,
				BorderSize = 0,
				ZIndex = 21,
			})
			
			CreateProtectedInstance("UIPadding", {
				Parent = item,
				PaddingLeft = UDim.new(0, 8),
			})
			
			CreateProtectedInstance("UICorner", {
				Parent = item,
				CornerRadius = DefaultTheme.CornerRadiusSmall,
			})
			
			item.MouseEnter:Connect(function()
				Utilities:Tween(item, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}, 0.08)
			end)
			
			item.MouseLeave:Connect(function()
				Utilities:Tween(item, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.1)
			end)
			
			item.MouseButton1Click:Connect(function()
				dropdown.SelectedValue = value
				dropdown.ValueLabel.Text = tostring(value)
				pcall(dropdown.Callback, value)
				
				if dropdown.Flag and Fluent.Flags then
					Fluent.Flags[dropdown.Flag] = value
				end
				
				dropdown:Close()
			end)
			
			table.insert(dropdown.ListItems, item)
		end
		
		-- Default to first value
		if #newValues > 0 then
			dropdown.SelectedValue = newValues[1]
			dropdown.ValueLabel.Text = tostring(newValues[1])
		end
	end
	
	function dropdown:SetValue(value)
		dropdown.SelectedValue = value
		dropdown.ValueLabel.Text = tostring(value)
		pcall(dropdown.Callback, value)
	end
	
	function dropdown:GetValue()
		return dropdown.SelectedValue
	end
	
	function dropdown:Destroy()
		dropdown.Container:Destroy()
	end
	
	table.insert(self.Components, dropdown)
	return dropdown
end

-- ============================================
-- LABEL COMPONENT
-- ============================================

function Section:AddLabel(text, description)
	local label = {}
	
	label.Container = CreateProtectedInstance("Frame", {
		Name = "Label_" .. (text or ""):gsub("%s+", "_"),
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, description and 44 or 28),
		Position = UDim2.new(0, 5, 0, 0),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	
	label.TextLabel = CreateProtectedInstance("TextLabel", {
		Name = "LabelText",
		Parent = label.Container,
		BackgroundTransparency = 1,
		Font = DefaultTheme.Font,
		Text = text,
		TextColor3 = DefaultTheme.Text,
		TextSize = DefaultTheme.TextSize,
		Position = UDim2.new(0, 5, 0, description and 2 or 0),
		Size = UDim2.new(1, -10, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSize = 0,
	})
	
	if description then
		label.DescLabel = CreateProtectedInstance("TextLabel", {
			Name = "LabelDesc",
			Parent = label.Container,
			BackgroundTransparency = 1,
			Font = DefaultTheme.FontSecondary,
			Text = description,
			TextColor3 = DefaultTheme.TextMuted,
			TextSize = DefaultTheme.TextSizeSmall - 1,
			Position = UDim2.new(0, 5, 0, 22),
			Size = UDim2.new(1, -10, 0, 18),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			BorderSize = 0,
		})
	end
	
	function label:SetText(newText)
		self.TextLabel.Text = newText
	end
	
	function label:Destroy()
		label.Container:Destroy()
	end
	
	table.insert(self.Components, label)
	return label
end

-- ============================================
-- KEYBIND COMPONENT
-- ============================================

function Section:AddKeybind(config)
	config = config or {}
	
	local keybind = {}
	keybind.Title = config.Title or config.title or "Keybind"
	keybind.Description = config.Description or config.description or nil
	keybind.Default = config.Default or config.default or Enum.KeyCode.Unknown
	keybind.Callback = config.Callback or config.OnChanged or config.callback or function() end
	keybind.Key = config.Default or config.default or Enum.KeyCode.Unknown
	keybind.Listening = false
	keybind.Flag = config.Flag or nil
	
	-- Container
	keybind.Container = CreateProtectedInstance("Frame", {
		Name = "Keybind_" .. (keybind.Title):gsub("%s+", "_"),
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 36),
		Position = UDim2.new(0, 5, 0, 0),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	
	-- Background
	keybind.Background = CreateProtectedInstance("Frame", {
		Name = "KeybindBackground",
		Parent = keybind.Container,
		BackgroundColor3 = DefaultTheme.BackgroundTertiary,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSize = 0,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = keybind.Background,
		CornerRadius = DefaultTheme.CornerRadius,
	})
	
	-- Title
	keybind.Label = CreateProtectedInstance("TextLabel", {
		Name = "KeybindLabel",
		Parent = keybind.Background,
		BackgroundTransparency = 1,
		Font = DefaultTheme.Font,
		Text = keybind.Title,
		TextColor3 = DefaultTheme.Text,
		TextSize = DefaultTheme.TextSize,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -90, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSize = 0,
	})
	
	-- Key display
	local function getKeyName(key)
		if key == Enum.KeyCode.Unknown then return "None" end
		local name = tostring(key):gsub("Enum.KeyCode.", "")
		-- Clean up common names
		local replacements = {
			["LeftShift"] = "L-Shift",
			["RightShift"] = "R-Shift",
			["LeftControl"] = "L-Ctrl",
			["RightControl"] = "R-Ctrl",
			["LeftAlt"] = "L-Alt",
			["RightAlt"] = "R-Alt",
			["Backspace"] = "Bksp",
			["Return"] = "Enter",
		}
		return replacements[name] or name
	end
	
	keybind.KeyLabel = CreateProtectedInstance("TextButton", {
		Name = "KeybindKey",
		Parent = keybind.Background,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		Size = UDim2.new(0, 70, 0, 24),
		Position = UDim2.new(1, -78, 0.5, -12),
		Text = getKeyName(keybind.Key),
		TextColor3 = DefaultTheme.Accent,
		TextSize = DefaultTheme.TextSizeSmall,
		Font = DefaultTheme.Font,
		AutoButtonColor = false,
		BorderSize = 0,
		ZIndex = 2,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = keybind.KeyLabel,
		CornerRadius = DefaultTheme.CornerRadiusSmall,
	})
	
	-- Hover
	keybind.KeyLabel.MouseEnter:Connect(function()
		if not keybind.Listening then
			Utilities:Tween(keybind.KeyLabel, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.08)
		end
	end)
	
	keybind.KeyLabel.MouseLeave:Connect(function()
		if not keybind.Listening then
			Utilities:Tween(keybind.KeyLabel, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.1)
		end
	end)
	
	-- Click to rebind
	keybind.KeyLabel.MouseButton1Click:Connect(function()
		keybind.Listening = true
		keybind.KeyLabel.Text = "..."
		keybind.KeyLabel.TextColor3 = DefaultTheme.Warning
		Utilities:Tween(keybind.KeyLabel, {BackgroundColor3 = Color3.fromRGB(60, 30, 30)}, 0.1)
	end)
	
	-- Listen for keybinds
	keybind.Connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if keybind.Listening and not gameProcessed then
			keybind.Key = input.KeyCode
			keybind.KeyLabel.Text = getKeyName(input.KeyCode)
			keybind.KeyLabel.TextColor3 = DefaultTheme.Accent
			keybind.Listening = false
			Utilities:Tween(keybind.KeyLabel, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.1)
			pcall(keybind.Callback, input.KeyCode)
			
			if keybind.Flag and Fluent.Flags then
				Fluent.Flags[keybind.Flag] = input.KeyCode
			end
		elseif not keybind.Listening and not gameProcessed then
			if input.KeyCode == keybind.Key and keybind.Key ~= Enum.KeyCode.Unknown then
				pcall(keybind.Callback, input.KeyCode)
			end
		end
	end)
	
	-- Methods
	function keybind:GetKey()
		return keybind.Key
	end
	
	function keybind:SetKey(keyCode)
		keybind.Key = keyCode
		keybind.KeyLabel.Text = getKeyName(keyCode)
	end
	
	function keybind:SetCallback(cb)
		keybind.Callback = cb
	end
	
	function keybind:Destroy()
		keybind.Connection:Disconnect()
		keybind.Container:Destroy()
	end
	
	table.insert(self.Components, keybind)
	return keybind
end

-- ============================================
-- TEXTBOX COMPONENT
-- ============================================

function Section:AddTextbox(config)
	config = config or {}
	
	local textbox = {}
	textbox.Title = config.Title or config.title or "Input"
	textbox.Description = config.Description or config.description or nil
	textbox.Placeholder = config.Placeholder or config.placeholder or "Type here..."
	textbox.Default = config.Default or config.default or ""
	textbox.Callback = config.Callback or config.OnChanged or config.callback or function() end
	textbox.Flag = config.Flag or nil
	textbox.Multiline = config.Multiline or config.multiline or false
	textbox.Numeric = config.Numeric or config.numeric or false
	
	-- Container
	textbox.Container = CreateProtectedInstance("Frame", {
		Name = "Textbox_" .. (textbox.Title):gsub("%s+", "_"),
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, textbox.Multiline and 80 or 52),
		Position = UDim2.new(0, 5, 0, 0),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	
	-- Background
	textbox.Background = CreateProtectedInstance("Frame", {
		Name = "TextboxBackground",
		Parent = textbox.Container,
		BackgroundColor3 = DefaultTheme.BackgroundTertiary,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSize = 0,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = textbox.Background,
		CornerRadius = DefaultTheme.CornerRadius,
	})
	
	-- Title
	textbox.Label = CreateProtectedInstance("TextLabel", {
		Name = "TextboxLabel",
		Parent = textbox.Background,
		BackgroundTransparency = 1,
		Font = DefaultTheme.Font,
		Text = textbox.Title,
		TextColor3 = DefaultTheme.Text,
		TextSize = DefaultTheme.TextSize,
		Position = UDim2.new(0, 12, 0, 6),
		Size = UDim2.new(1, -24, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSize = 0,
	})
	
	-- Input box
	local inputHeight = textbox.Multiline and 48 or 24
	
	textbox.InputContainer = CreateProtectedInstance("Frame", {
		Name = "InputContainer",
		Parent = textbox.Background,
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),
		Size = UDim2.new(1, -24, 0, inputHeight),
		Position = UDim2.new(0, 12, 0, 26),
		BorderSize = 0,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = textbox.InputContainer,
		CornerRadius = DefaultTheme.CornerRadiusSmall,
	})
	
	CreateProtectedInstance("UIStroke", {
		Parent = textbox.InputContainer,
		Color = Color3.fromRGB(50, 50, 50),
		Thickness = 1,
		Transparency = 0,
	})
	
	local inputClass = textbox.Multiline and "TextBox" or "TextBox"
	
	textbox.Input = CreateProtectedInstance(inputClass, {
		Name = "TextBox",
		Parent = textbox.InputContainer,
		BackgroundTransparency = 1,
		Font = DefaultTheme.FontSecondary,
		Text = textbox.Default,
		TextColor3 = DefaultTheme.Text,
		TextSize = DefaultTheme.TextSize - 1,
		PlaceholderText = textbox.Placeholder,
		PlaceholderColor3 = DefaultTheme.TextMuted,
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(1, -16, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = textbox.Multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
		ClearTextOnFocus = false,
		BorderSize = 0,
		MultiLine = textbox.Multiline,
	})
	
	-- Focus effects
	textbox.Input.Focused:Connect(function()
		Utilities:Tween(textbox.InputContainer, {BackgroundColor3 = Color3.fromRGB(38, 38, 38)}, 0.08)
		local stroke = textbox.InputContainer:FindFirstChildWhichIsA("UIStroke")
		if stroke then
			Utilities:Tween(stroke, {Color = DefaultTheme.Accent, Transparency = 0.3}, 0.1)
		end
	end)
	
	textbox.Input.FocusLost:Connect(function(enterPressed)
		Utilities:Tween(textbox.InputContainer, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.08)
		local stroke = textbox.InputContainer:FindFirstChildWhichIsA("UIStroke")
		if stroke then
			Utilities:Tween(stroke, {Color = Color3.fromRGB(50, 50, 50), Transparency = 0}, 0.1)
		end
		
		local value = textbox.Input.Text
		if textbox.Numeric then
			local num = tonumber(value)
			if num then
				value = tostring(num)
				textbox.Input.Text = value
			else
				value = textbox.Default
				textbox.Input.Text = value
			end
		end
		
		pcall(textbox.Callback, value)
		
		if textbox.Flag and Fluent.Flags then
			Fluent.Flags[textbox.Flag] = value
		end
	end)
	
	-- Methods
	function textbox:SetText(text)
		textbox.Input.Text = text
	end
	
	function textbox:GetText()
		return textbox.Input.Text
	end
	
	function textbox:SetCallback(cb)
		textbox.Callback = cb
	end
	
	function textbox:Destroy()
		textbox.Container:Destroy()
	end
	
	table.insert(self.Components, textbox)
	return textbox
end

-- ============================================
-- PARAGRAPH COMPONENT (for documentation)
-- ============================================

function Section:AddParagraph(title, content)
	local paragraph = {}
	
	paragraph.Container = CreateProtectedInstance("Frame", {
		Name = "Paragraph_" .. (title or ""):gsub("%s+", "_"),
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 0),
		Position = UDim2.new(0, 5, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	
	if title and title ~= "" then
		paragraph.TitleLabel = CreateProtectedInstance("TextLabel", {
			Name = "ParagraphTitle",
			Parent = paragraph.Container,
			BackgroundTransparency = 1,
			Font = DefaultTheme.Font,
			Text = title,
			TextColor3 = DefaultTheme.Text,
			TextSize = DefaultTheme.TextSizeLarge,
			Position = UDim2.new(0, 5, 0, 0),
			Size = UDim2.new(1, -10, 0, 24),
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSize = 0,
		})
	end
	
	if content and content ~= "" then
		local yPos = (title and title ~= "") and 26 or 0
		
		paragraph.ContentLabel = CreateProtectedInstance("TextLabel", {
			Name = "ParagraphContent",
			Parent = paragraph.Container,
			BackgroundTransparency = 1,
			Font = DefaultTheme.FontSecondary,
			Text = content,
			TextColor3 = DefaultTheme.TextSecondary,
			TextSize = DefaultTheme.TextSizeSmall,
			Position = UDim2.new(0, 5, 0, yPos),
			Size = UDim2.new(1, -10, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			RichText = true,
			BorderSize = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
		})
	end
	
	function paragraph:SetTitle(text)
		if paragraph.TitleLabel then
			paragraph.TitleLabel.Text = text
		end
	end
	
	function paragraph:SetContent(text)
		if paragraph.ContentLabel then
			paragraph.ContentLabel.Text = text
		end
	end
	
	function paragraph:Destroy()
		paragraph.Container:Destroy()
	end
	
	table.insert(self.Components, paragraph)
	return paragraph
end

-- ============================================
-- SEPARATOR
-- ============================================

function Section:AddSeparator()
	local separator = {}
	
	separator.Container = CreateProtectedInstance("Frame", {
		Name = "Separator",
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 12),
		Position = UDim2.new(0, 5, 0, 0),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	
	separator.Line = CreateProtectedInstance("Frame", {
		Name = "SeparatorLine",
		Parent = separator.Container,
		BackgroundColor3 = DefaultTheme.Border,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0.5, 0),
		BorderSize = 0,
	})
	
	function separator:Destroy()
		separator.Container:Destroy()
	end
	
	table.insert(self.Components, separator)
	return separator
end

-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================

local NotificationService = {}

function Fluent:Notify(config)
	config = config or {}
	
	local title = config.Title or config.title or "Notification"
	local content = config.Content or config.content or config.Description or config.description or ""
	local duration = config.Duration or config.duration or 4
	local icon = config.Icon or config.icon or nil
	
	-- Find the last active window
	local window = nil
	for _, w in ipairs(ActiveWindows) do
		window = w
		break
	end
	
	if not window then
		warn("FluentUI: No active window to show notification on")
		return
	end
	
	-- Notification container on the window
	local notifContainer = window.Main:FindFirstChild("NotificationContainer")
	if not notifContainer then
		notifContainer = CreateProtectedInstance("Frame", {
			Name = "NotificationContainer",
			Parent = window.Main,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 0, 0),
			Position = UDim2.new(0, 10, 1, -10),
			AnchorPoint = Vector2.new(0, 1),
			BorderSize = 0,
			ZIndex = 100,
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		
		CreateProtectedInstance("UIListLayout", {
			Parent = notifContainer,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		})
	end
	
	-- Notification frame
	local notif = CreateProtectedInstance("Frame", {
		Name = "Notification",
		Parent = notifContainer,
		BackgroundColor3 = DefaultTheme.BackgroundSecondary,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderSize = 0,
		ZIndex = 101,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = notif,
		CornerRadius = DefaultTheme.CornerRadius,
	})
	
	CreateProtectedInstance("UIStroke", {
		Parent = notif,
		Color = DefaultTheme.Border,
		Thickness = 1,
	})
	
	-- Accent left bar
	CreateProtectedInstance("Frame", {
		Name = "AccentBar",
		Parent = notif,
		BackgroundColor3 = DefaultTheme.Accent,
		Size = UDim2.new(0, 3, 1, -4),
		Position = UDim2.new(0, 0, 0, 2),
		BorderSize = 0,
		ZIndex = 102,
	})
	
	CreateProtectedInstance("UICorner", {
		Parent = notif.AccentBar,
		CornerRadius = UDim.new(0, 2),
	})
	
	-- Title
	local titleLabel = CreateProtectedInstance("TextLabel", {
		Name = "Title",
		Parent = notif,
		BackgroundTransparency = 1,
		Font = DefaultTheme.Font,
		Text = title,
		TextColor3 = DefaultTheme.Text,
		TextSize = DefaultTheme.TextSize,
		Position = UDim2.new(0, 14, 0, 8),
		Size = UDim2.new(1, -28, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSize = 0,
		ZIndex = 102,
	})
	
	-- Content
	local contentLabel = CreateProtectedInstance("TextLabel", {
		Name = "Content",
		Parent = notif,
		BackgroundTransparency = 1,
		Font = DefaultTheme.FontSecondary,
		Text = content,
		TextColor3 = DefaultTheme.TextSecondary,
		TextSize = DefaultTheme.TextSizeSmall,
		Position = UDim2.new(0, 14, 0, 28),
		Size = UDim2.new(1, -28, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		RichText = true,
		BorderSize = 0,
		ZIndex = 102,
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	
	-- Size to content
	local contentSize = contentLabel.TextBounds.Y + 38
	notif.Size = UDim2.new(1, 0, 0, math.max(50, contentSize))
	
	-- Animate in
	notif.Position = UDim2.new(0, 0, 0, 50)
	notif.BackgroundTransparency = 1
	notif.AccentBar.BackgroundTransparency = 1
	titleLabel.TextTransparency = 1
	contentLabel.TextTransparency = 1
	
	task.wait(0.05)
	
	Utilities:Tween(notif, {
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 0,
	}, 0.2)
	
	Utilities:Tween(notif.AccentBar, {
		BackgroundTransparency = 0,
	}, 0.25)
	
	Utilities:Tween(titleLabel, {
		TextTransparency = 0,
	}, 0.2)
	
	Utilities:Tween(contentLabel, {
		TextTransparency = 0,
	}, 0.25)
	
	-- Auto-dismiss
	task.delay(duration, function()
		if notif and notif.Parent then
			Utilities:Tween(notif, {
				Position = UDim2.new(0, 0, 0, -20),
				BackgroundTransparency = 1,
			}, 0.15)
			Utilities:Tween(titleLabel, {TextTransparency = 1}, 0.12)
			Utilities:Tween(contentLabel, {TextTransparency = 1}, 0.12)
			task.delay(0.2, function()
				pcall(notif.Destroy, notif)
			end)
		end
	end)
end

-- Check if the library is being loaded via loadstring and return it
return Fluent