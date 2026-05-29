--[[
	Fluent UI v1.0.0
	A modern Fluent Design-inspired UI library for Roblox executors.
	
	Features:
	- Clean, modern Fluent Design aesthetics
	- Custom rendering (no default Roblox UI)
	- Tab system with navigation
	- Buttons with hover effects
	- Toggles with smooth animations
	- Sliders with draggable thumbs
	- Sections and dividers
	- Dropdown menus
	- Text inputs
	- Keybinds
	- Labels
	- Notifications
	- Lightweight and optimized
--]]

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- The library table
local Fluent = {}
Fluent.__index = Fluent

-- Version
Fluent.Version = "1.0.0"

-- Active windows list
local ActiveWindows = {}

-- ============================================
-- THEME
-- ============================================

local Theme = {
	Background = Color3.fromRGB(20, 20, 20),
	BackgroundSecondary = Color3.fromRGB(28, 28, 28),
	BackgroundTertiary = Color3.fromRGB(36, 36, 36),
	Border = Color3.fromRGB(50, 50, 50),
	Accent = Color3.fromRGB(0, 120, 212),
	AccentLight = Color3.fromRGB(0, 140, 240),
	AccentDark = Color3.fromRGB(0, 100, 180),
	Text = Color3.fromRGB(230, 230, 230),
	TextSecondary = Color3.fromRGB(180, 180, 180),
	TextMuted = Color3.fromRGB(130, 130, 130),
	TextInverse = Color3.fromRGB(20, 20, 20),
	Success = Color3.fromRGB(76, 175, 80),
	Warning = Color3.fromRGB(255, 193, 7),
	Error = Color3.fromRGB(244, 67, 54),
	Button = Color3.fromRGB(45, 45, 45),
	ButtonHover = Color3.fromRGB(55, 55, 55),
	ButtonPress = Color3.fromRGB(35, 35, 35),
	ButtonAccent = Color3.fromRGB(0, 120, 212),
	ButtonAccentHover = Color3.fromRGB(0, 140, 240),
	ToggleOn = Color3.fromRGB(0, 120, 212),
	ToggleOff = Color3.fromRGB(70, 70, 70),
	ToggleThumb = Color3.fromRGB(200, 200, 200),
	SliderTrack = Color3.fromRGB(70, 70, 70),
	SliderFill = Color3.fromRGB(0, 120, 212),
	SliderThumb = Color3.fromRGB(200, 200, 200),
	Scrollbar = Color3.fromRGB(60, 60, 60),
	TabActive = Color3.fromRGB(0, 120, 212),
	TabInactive = Color3.fromRGB(160, 160, 160),
	TabBackground = Color3.fromRGB(22, 22, 22),
}

-- ============================================
-- HELPERS
-- ============================================

local function New(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		pcall(function()
			inst[k] = v
		end)
	end
	return inst
end

local function Tween(obj, props, time)
	local info = TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(obj, info, props)
	tween:Play()
	return tween
end

local function MakeDraggable(frame, dragObj)
	dragObj = dragObj or frame
	local dragging, dragStart, startPos
	
	dragObj.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	
	local dragInput = nil
	dragObj.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	
	-- Stop dragging on release
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
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
		Keybind = config.Keybind or nil,
	}
	
	self.Tabs = {}
	self.ActiveTab = nil
	self._Minimized = false
	self._Maximized = false
	
	-- ScreenGui
	self.ScreenGui = New("ScreenGui", {
		Name = "FluentUI_" .. tostring(math.random(1, 99999)),
		DisplayOrder = 999,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		Enabled = true,
	})
	
	-- Main frame
	self.Main = New("Frame", {
		Name = "Window",
		Parent = self.ScreenGui,
		BackgroundColor3 = Theme.Background,
		Size = self.Config.Size,
		Position = self.Config.Position,
		ClipsDescendants = true,
		BorderSize = 0,
	})
	
	New("UICorner", { Parent = self.Main, CornerRadius = UDim.new(0, 8) })
	New("UIStroke", { Parent = self.Main, Color = Theme.Border, Thickness = 1 })
	
	-- Shadow
	New("ImageLabel", {
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
	
	-- Title bar
	self.TitleBar = New("Frame", {
		Name = "TitleBar",
		Parent = self.Main,
		BackgroundColor3 = Theme.BackgroundSecondary,
		Size = UDim2.new(1, 0, 0, 40),
		BorderSize = 0,
	})
	New("UICorner", { Parent = self.TitleBar, CornerRadius = UDim.new(0, 8) })
	
	-- Cover corners
	New("Frame", {
		Parent = self.TitleBar,
		BackgroundColor3 = Theme.BackgroundSecondary,
		Size = UDim2.new(0, 20, 0, 10),
		Position = UDim2.new(0, 0, 1, -10),
		BorderSize = 0,
	})
	New("Frame", {
		Parent = self.TitleBar,
		BackgroundColor3 = Theme.BackgroundSecondary,
		Size = UDim2.new(0, 20, 0, 10),
		Position = UDim2.new(1, -20, 1, -10),
		BorderSize = 0,
	})
	
	-- Bottom line
	New("Frame", {
		Parent = self.TitleBar,
		BackgroundColor3 = Theme.Border,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BorderSize = 0,
	})
	
	-- Title
	New("TextLabel", {
		Name = "Icon",
		Parent = self.TitleBar,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "●",
		TextColor3 = Theme.Accent,
		TextSize = 18,
		Position = UDim2.new(0, 14, 0, 10),
		Size = UDim2.new(0, 20, 0, 20),
	})
	
	self.TitleLabel = New("TextLabel", {
		Name = "Title",
		Parent = self.TitleBar,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = self.Config.Title,
		TextColor3 = Theme.Text,
		TextSize = 16,
		Position = UDim2.new(0, 42, 0, 0),
		Size = UDim2.new(1, -140, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	})
	
	-- Window controls
	local function MakeControlButton(parent, pos, text, textSize, hoverColor)
		local btn = New("TextButton", {
			Parent = parent,
			BackgroundColor3 = Color3.fromRGB(45, 45, 45),
			Size = UDim2.new(0, 34, 0, 26),
			Position = pos,
			Text = text,
			TextColor3 = Theme.Text,
			TextSize = textSize,
			Font = Enum.Font.Gotham,
			AutoButtonColor = false,
			BorderSize = 0,
			ZIndex = 5,
		})
		New("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 4) })
		
		btn.MouseEnter:Connect(function()
			Tween(btn, { BackgroundColor3 = hoverColor or Color3.fromRGB(60, 60, 60) }, 0.1)
		end)
		btn.MouseLeave:Connect(function()
			Tween(btn, { BackgroundColor3 = Color3.fromRGB(45, 45, 45) }, 0.15)
		end)
		
		return btn
	end
	
	self.MinimizeBtn = MakeControlButton(self.TitleBar, UDim2.new(1, -112, 0, 7), "−", 18)
	self.MaximizeBtn = MakeControlButton(self.TitleBar, UDim2.new(1, -75, 0, 7), "□", 14)
	self.CloseBtn = MakeControlButton(self.TitleBar, UDim2.new(1, -38, 0, 7), "✕", 14, Color3.fromRGB(196, 43, 28))
	
	-- Close
	self.CloseBtn.MouseButton1Click:Connect(function()
		self:Destroy()
	end)
	
	-- Minimize
	self.MinimizeBtn.MouseButton1Click:Connect(function()
		self:SetMinimized(not self._Minimized)
	end)
	
	-- Maximize
	self.MaximizeBtn.MouseButton1Click:Connect(function()
		self:ToggleMaximize()
	end)
	
	-- Navigation sidebar
	self.NavBar = New("Frame", {
		Name = "Navigation",
		Parent = self.Main,
		BackgroundColor3 = Theme.TabBackground,
		Size = UDim2.new(0, 48, 1, -41),
		Position = UDim2.new(0, 0, 0, 41),
		BorderSize = 0,
	})
	New("Frame", {
		Parent = self.NavBar,
		BackgroundColor3 = Theme.Border,
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		BorderSize = 0,
	})
	
	-- Tab container
	self.TabContainer = New("ScrollingFrame", {
		Name = "TabContainer",
		Parent = self.NavBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 0,
		BorderSize = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	})
	
	-- Tab indicator
	self.TabIndicator = New("Frame", {
		Name = "TabIndicator",
		Parent = self.NavBar,
		BackgroundColor3 = Theme.Accent,
		Size = UDim2.new(0, 3, 0, 24),
		Position = UDim2.new(1, -3, 0, 10),
		BorderSize = 0,
		ZIndex = 3,
	})
	New("UICorner", { Parent = self.TabIndicator, CornerRadius = UDim.new(0, 2) })
	
	-- Page container
	self.PageContainer = New("Frame", {
		Name = "PageContainer",
		Parent = self.Main,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -49, 1, -41),
		Position = UDim2.new(0, 49, 0, 41),
		BorderSize = 0,
		ClipsDescendants = true,
	})
	
	-- Make draggable
	MakeDraggable(self.Main, self.TitleBar)
	
	-- Keybind toggle
	if self.Config.Keybind then
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed and input.KeyCode == self.Config.Keybind then
				self:ToggleVisibility()
			end
		end)
	end
	
	table.insert(ActiveWindows, self)
	
	return self
end

-- Window Methods
function Window:SetMinimized(minimized)
	self._Minimized = minimized
	if minimized then
		Tween(self.Main, { Size = UDim2.new(0, self.Config.Size.X.Offset, 0, 40) }, 0.2)
		self.PageContainer.Visible = false
		self.NavBar.Visible = false
	else
		self.PageContainer.Visible = true
		self.NavBar.Visible = true
		Tween(self.Main, { Size = self.Config.Size }, 0.2)
	end
end

function Window:ToggleVisibility()
	self.ScreenGui.Enabled = not self.ScreenGui.Enabled
end

function Window:SetVisibility(visible)
	self.ScreenGui.Enabled = visible
end

function Window:ToggleMaximize()
	if self._Maximized then
		Tween(self.Main, {
			Size = self._PreviousSize or self.Config.Size,
			Position = self._PreviousPosition or self.Config.Position,
		}, 0.2)
		self._Maximized = false
	else
		self._PreviousSize = self.Main.Size
		self._PreviousPosition = self.Main.Position
		local vp = workspace.CurrentCamera.ViewportSize
		Tween(self.Main, {
			Size = UDim2.new(0, vp.X - 40, 0, vp.Y - 40),
			Position = UDim2.new(0, 20, 0, 20),
		}, 0.2)
		self._Maximized = true
	end
end

function Window:AddTab(title, icon)
	local tab = {}
	tab._window = self
	tab.Title = title or "Tab"
	tab.Icon = icon or nil
	tab.Index = #self.Tabs + 1
	tab.Sections = {}
	tab.Destroyed = false
	tab.Active = false
	
	setmetatable(tab, { __index = TabMethods })
	
	-- Tab button
	tab.Button = New("TextButton", {
		Name = "Tab_" .. tostring(title):gsub("%s+", "_"),
		Parent = self.TabContainer,
		BackgroundColor3 = Color3.fromRGB(28, 28, 28),
		Size = UDim2.new(1, 0, 0, 44),
		Position = UDim2.new(0, 0, 0, (tab.Index - 1) * 44),
		Text = "",
		AutoButtonColor = false,
		BorderSize = 0,
	})
	
	local displayText = icon or string.upper(string.sub(title, 1, 1))
	
	tab.Label = New("TextLabel", {
		Parent = tab.Button,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = displayText,
		TextColor3 = Theme.TabInactive,
		TextSize = 18,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		TextYAlignment = Enum.TextYAlignment.Center,
	})
	
	-- Page (scrolling content area)
	tab.Page = New("ScrollingFrame", {
		Name = tostring(title),
		Parent = self.PageContainer,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 1, -20),
		Position = UDim2.new(0, 10, 0, 10),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Scrollbar,
		BorderSize = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		Visible = false,
	})
	
	-- Tab events
	tab.Button.MouseEnter:Connect(function()
		if not tab.Active then
			Tween(tab.Label, { TextColor3 = Theme.Text }, 0.1)
		end
	end)
	tab.Button.MouseLeave:Connect(function()
		if not tab.Active then
			Tween(tab.Label, { TextColor3 = Theme.TabInactive }, 0.15)
		end
	end)
	tab.Button.MouseButton1Click:Connect(function()
		self:SelectTab(tab.Index)
	end)
	
	table.insert(self.Tabs, tab)
	
	-- Auto-activate first tab
	if #self.Tabs == 1 then
		self:SelectTab(1)
	end
	
	return tab
end

function Window:SelectTab(identifier)
	local target = nil
	
	if type(identifier) == "number" then
		target = self.Tabs[identifier]
	elseif type(identifier) == "string" then
		for _, t in ipairs(self.Tabs) do
			if t.Title == identifier then
				target = t
				break
			end
		end
	end
	
	if not target or target.Destroyed then return end
	
	-- Deactivate all
	for _, t in ipairs(self.Tabs) do
		if t ~= target then
			t.Active = false
			t.Page.Visible = false
			Tween(t.Label, { TextColor3 = Theme.TabInactive, TextSize = 18 }, 0.15)
			Tween(t.Button, { BackgroundColor3 = Color3.fromRGB(28, 28, 28) }, 0.1)
		end
	end
	
	-- Activate target
	target.Active = true
	target.Page.Visible = true
	self.ActiveTab = target
	
	local targetY = (target.Index - 1) * 44 + 10
	Tween(self.TabIndicator, { Position = UDim2.new(1, -3, 0, targetY) }, 0.15)
	Tween(target.Label, { TextColor3 = Theme.Accent, TextSize = 20 }, 0.15)
	Tween(target.Button, { BackgroundColor3 = Color3.fromRGB(24, 24, 24) }, 0.1)
end

function Window:Destroy()
	self.ScreenGui:Destroy()
	for i, w in ipairs(ActiveWindows) do
		if w == self then
			table.remove(ActiveWindows, i)
			break
		end
	end
end

-- ============================================
-- TAB METHODS (mixed into tab objects)
-- ============================================

local TabMethods = {}

function TabMethods:AddSection(title)
	local section = {}
	section._tab = self
	section.Title = title or ""
	section.Components = {}
	
	-- Container
	section.Container = New("Frame", {
		Name = "Section_" .. tostring(title):gsub("%s+", "_"),
		Parent = self.Page,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderSize = 0,
	})
	
	New("UIPadding", {
		Parent = section.Container,
		PaddingTop = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 5),
	})
	
	local layout = New("UIListLayout", {
		Parent = section.Container,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
	})
	
	if title and title ~= "" then
		New("TextLabel", {
			Parent = section.Container,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Text = title,
			TextColor3 = Theme.Accent,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, 5, 0, 0),
			Size = UDim2.new(1, -10, 0, 22),
			LayoutOrder = 0,
			BorderSize = 0,
		})
		
		New("Frame", {
			Parent = section.Container,
			BackgroundColor3 = Theme.Border,
			Size = UDim2.new(1, -10, 0, 1),
			Position = UDim2.new(0, 5, 0, 22),
			LayoutOrder = 0,
			BorderSize = 0,
		})
	end
	
	-- Update tab canvas when content changes
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if self.Page then
			self.Page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
		end
	end)
	
	table.insert(self.Sections, section)
	
	-- Mix in section methods
	setmetatable(section, { __index = SectionMethods })
	
	return section
end

-- Convenience methods on tab
function TabMethods:AddButton(text, cb, desc)
	local s = self:AddSection("")
	return s:AddButton(text, cb, desc)
end

function TabMethods:AddToggle(config)
	local s = self:AddSection("")
	return s:AddToggle(config)
end

function TabMethods:AddSlider(config)
	local s = self:AddSection("")
	return s:AddSlider(config)
end

function TabMethods:AddDropdown(config)
	local s = self:AddSection("")
	return s:AddDropdown(config)
end

function TabMethods:AddLabel(text, desc)
	local s = self:AddSection("")
	return s:AddLabel(text, desc)
end

function TabMethods:AddKeybind(config)
	local s = self:AddSection("")
	return s:AddKeybind(config)
end

function TabMethods:AddParagraph(title, content)
	local s = self:AddSection("")
	return s:AddParagraph(title, content)
end

function TabMethods:AddTextbox(config)
	local s = self:AddSection("")
	return s:AddTextbox(config)
end

function TabMethods:AddSeparator()
	local s = self:AddSection("")
	return s:AddSeparator()
end

-- ============================================
-- SECTION METHODS
-- ============================================

local SectionMethods = {}

-- BUTTON
function SectionMethods:AddButton(text, callback, description)
	local comp = {}
	comp.Type = "Button"
	
	local container = New("Frame", {
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 38),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	comp.Container = container
	
	local frame = New("Frame", {
		Parent = container,
		BackgroundColor3 = Theme.Button,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSize = 0,
	})
	New("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 6) })
	
	local label = New("TextLabel", {
		Parent = frame,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 14,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -24, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSize = 0,
	})
	comp.Label = label
	
	if description then
		New("TextLabel", {
			Parent = frame,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = description,
			TextColor3 = Theme.TextMuted,
			TextSize = 12,
			Position = UDim2.new(0, 12, 0, 0),
			Size = UDim2.new(1, -24, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Center,
			BorderSize = 0,
		})
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Center
	end
	
	local btn = New("TextButton", {
		Parent = frame,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 2,
		BorderSize = 0,
	})
	
	btn.MouseButton1Click:Connect(function()
		pcall(callback)
	end)
	btn.MouseEnter:Connect(function()
		Tween(frame, { BackgroundColor3 = Theme.ButtonHover }, 0.1)
	end)
	btn.MouseLeave:Connect(function()
		Tween(frame, { BackgroundColor3 = Theme.Button }, 0.15)
	end)
	btn.MouseButton1Down:Connect(function()
		Tween(frame, { BackgroundColor3 = Theme.ButtonPress }, 0.05)
	end)
	btn.MouseButton1Up:Connect(function()
		Tween(frame, { BackgroundColor3 = Theme.ButtonHover }, 0.08)
	end)
	
	comp.SetText = function(_, newText)
		label.Text = newText
	end
	
	comp.Destroy = function()
		container:Destroy()
	end
	
	table.insert(self.Components, comp)
	return comp
end

-- ACCENT BUTTON
function SectionMethods:AddAccentButton(text, callback, description)
	local comp = {}
	comp.Type = "AccentButton"
	
	local container = New("Frame", {
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 38),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	comp.Container = container
	
	local frame = New("Frame", {
		Parent = container,
		BackgroundColor3 = Theme.ButtonAccent,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSize = 0,
	})
	New("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 6) })
	
	New("TextLabel", {
		Parent = frame,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = text,
		TextColor3 = Theme.TextInverse,
		TextSize = 14,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -24, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Center,
		BorderSize = 0,
	})
	
	local btn = New("TextButton", {
		Parent = frame,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 2,
		BorderSize = 0,
	})
	
	btn.MouseButton1Click:Connect(function()
		pcall(callback)
	end)
	btn.MouseEnter:Connect(function()
		Tween(frame, { BackgroundColor3 = Theme.ButtonAccentHover }, 0.1)
	end)
	btn.MouseLeave:Connect(function()
		Tween(frame, { BackgroundColor3 = Theme.ButtonAccent }, 0.15)
	end)
	btn.MouseButton1Down:Connect(function()
		Tween(frame, { BackgroundColor3 = Theme.AccentDark }, 0.05)
	end)
	btn.MouseButton1Up:Connect(function()
		Tween(frame, { BackgroundColor3 = Theme.ButtonAccentHover }, 0.08)
	end)
	
	comp.Destroy = function()
		container:Destroy()
	end
	
	table.insert(self.Components, comp)
	return comp
end

-- TOGGLE
function SectionMethods:AddToggle(config)
	config = config or {}
	
	local comp = {}
	comp.Type = "Toggle"
	comp.Value = config.Default or false
	comp.Callback = config.Callback or config.OnChanged or config.callback or function() end
	local title = config.Title or config.title or "Toggle"
	local desc = config.Description or config.description or nil
	
	local container = New("Frame", {
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 36),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	comp.Container = container
	
	local bg = New("Frame", {
		Parent = container,
		BackgroundColor3 = Theme.BackgroundTertiary,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSize = 0,
	})
	New("UICorner", { Parent = bg, CornerRadius = UDim.new(0, 6) })
	
	local label = New("TextLabel", {
		Parent = bg,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 14,
		Position = UDim2.new(0, 12, 0, desc and 2 or 0),
		Size = UDim2.new(1, -80, desc and 16 or 36, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = desc and Enum.TextYAlignment.Bottom or Enum.TextYAlignment.Center,
		BorderSize = 0,
	})
	comp.Label = label
	
	if desc then
		New("TextLabel", {
			Parent = bg,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = desc,
			TextColor3 = Theme.TextMuted,
			TextSize = 11,
			Position = UDim2.new(0, 12, 0, 18),
			Size = UDim2.new(1, -80, 0, 14),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			BorderSize = 0,
		})
	end
	
	-- Track
	local track = New("Frame", {
		Parent = bg,
		BackgroundColor3 = comp.Value and Theme.ToggleOn or Theme.ToggleOff,
		Size = UDim2.new(0, 44, 0, 22),
		Position = UDim2.new(1, -56, 0.5, -11),
		BorderSize = 0,
	})
	New("UICorner", { Parent = track, CornerRadius = UDim.new(1, 0) })
	comp.Track = track
	
	-- Thumb
	local thumb = New("Frame", {
		Parent = track,
		BackgroundColor3 = Theme.ToggleThumb,
		Size = UDim2.new(0, 16, 0, 16),
		Position = comp.Value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
		BorderSize = 0,
	})
	New("UICorner", { Parent = thumb, CornerRadius = UDim.new(1, 0) })
	New("UIStroke", { Parent = thumb, Color = Color3.fromRGB(30, 30, 30), Thickness = 0.5, Transparency = 0.5 })
	comp.Thumb = thumb
	
	-- Click area
	local btn = New("TextButton", {
		Parent = bg,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 2,
		BorderSize = 0,
	})
	
	local function SetState(value)
		comp.Value = value
		if value then
			Tween(track, { BackgroundColor3 = Theme.ToggleOn }, 0.12)
			Tween(thumb, { Position = UDim2.new(1, -19, 0.5, -8) }, 0.15)
		else
			Tween(track, { BackgroundColor3 = Theme.ToggleOff }, 0.12)
			Tween(thumb, { Position = UDim2.new(0, 3, 0.5, -8) }, 0.15)
		end
		pcall(comp.Callback, value)
	end
	
	btn.MouseButton1Click:Connect(function()
		SetState(not comp.Value)
	end)
	btn.MouseEnter:Connect(function()
		Tween(bg, { BackgroundColor3 = Color3.fromRGB(42, 42, 42) }, 0.1)
	end)
	btn.MouseLeave:Connect(function()
		Tween(bg, { BackgroundColor3 = Theme.BackgroundTertiary }, 0.15)
	end)
	
	comp.SetValue = function(_, val)
		SetState(val)
	end
	comp.GetValue = function()
		return comp.Value
	end
	comp.Destroy = function()
		container:Destroy()
	end
	
	table.insert(self.Components, comp)
	return comp
end

-- SLIDER
function SectionMethods:AddSlider(config)
	config = config or {}
	
	local comp = {}
	comp.Type = "Slider"
	comp.Min = config.Min or config.MinValue or 0
	comp.Max = config.Max or config.MaxValue or 100
	comp.Suffix = config.Suffix or config.Unit or config.unit or ""
	comp.Precision = config.Precision or config.DecimalPlaces or 0
	comp.Callback = config.Callback or config.OnChanged or config.callback or function() end
	local title = config.Title or config.title or "Slider"
	
	comp.Value = math.clamp(config.Default or config.DefaultValue or 0, comp.Min, comp.Max)
	
	local container = New("Frame", {
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 48),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	comp.Container = container
	
	local bg = New("Frame", {
		Parent = container,
		BackgroundColor3 = Theme.BackgroundTertiary,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSize = 0,
	})
	New("UICorner", { Parent = bg, CornerRadius = UDim.new(0, 6) })
	
	New("TextLabel", {
		Parent = bg,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 14,
		Position = UDim2.new(0, 12, 0, 6),
		Size = UDim2.new(1, -80, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSize = 0,
	})
	
	local valLabel = New("TextLabel", {
		Parent = bg,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = tostring(comp.Value) .. comp.Suffix,
		TextColor3 = Theme.Accent,
		TextSize = 14,
		Position = UDim2.new(0, 0, 0, 6),
		Size = UDim2.new(1, -20, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSize = 0,
	})
	comp.ValueLabel = valLabel
	
	-- Track
	local track = New("Frame", {
		Parent = bg,
		BackgroundColor3 = Theme.SliderTrack,
		Size = UDim2.new(1, -24, 0, 4),
		Position = UDim2.new(0, 12, 1, -14),
		BorderSize = 0,
	})
	New("UICorner", { Parent = track, CornerRadius = UDim.new(1, 0) })
	
	-- Fill
	local fill = New("Frame", {
		Parent = track,
		BackgroundColor3 = Theme.SliderFill,
		Size = UDim2.new(0, 0, 1, 0),
		BorderSize = 0,
	})
	New("UICorner", { Parent = fill, CornerRadius = UDim.new(1, 0) })
	comp.Fill = fill
	
	-- Thumb
	local thumb = New("Frame", {
		Parent = track,
		BackgroundColor3 = Theme.SliderThumb,
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0, 0, 0.5, -8),
		BorderSize = 0,
		ZIndex = 3,
	})
	New("UICorner", { Parent = thumb, CornerRadius = UDim.new(1, 0) })
	New("UIStroke", { Parent = thumb, Color = Color3.fromRGB(30, 30, 30), Thickness = 1, Transparency = 0.4 })
	comp.Thumb = thumb
	
	-- Set initial position
	local function UpdatePosition(value)
		local pct = (value - comp.Min) / (comp.Max - comp.Min)
		fill.Size = UDim2.new(pct, 0, 1, 0)
		thumb.Position = UDim2.new(pct, -8, 0.5, -8)
		valLabel.Text = tostring(value) .. comp.Suffix
		comp.Value = value
		pcall(comp.Callback, value)
	end
	
	-- Interactive area
	local hitArea = New("TextButton", {
		Parent = container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 4,
		BorderSize = 0,
	})
	
	local dragging = false
	
	local function UpdateFromMouse(input)
		local tPos = track.AbsolutePosition
		local tSize = track.AbsoluteSize.X
		local rx = math.clamp(input.Position.X - tPos.X, 0, tSize)
		local pct = rx / tSize
		local range = comp.Max - comp.Min
		local raw = comp.Min + pct * range
		local val = math.floor(raw * (10 ^ comp.Precision) + 0.5) / (10 ^ comp.Precision)
		UpdatePosition(val)
	end
	
	hitArea.MouseButton1Click:Connect(function(input)
		UpdateFromMouse(input)
	end)
	
	hitArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			UpdateFromMouse(input)
		end
	end)
	
	hitArea.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	-- Global tracking for drag
	local conn = UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local hit = nil
			-- Use just the current mouse position
			local tPos = track.AbsolutePosition
			local tSize = track.AbsoluteSize.X
			local rx = math.clamp(input.Position.X - tPos.X, 0, tSize)
			local pct = rx / tSize
			local range = comp.Max - comp.Min
			local raw = comp.Min + pct * range
			local val = math.floor(raw * (10 ^ comp.Precision) + 0.5) / (10 ^ comp.Precision)
			UpdatePosition(val)
		end
	end)
	
	-- Hover
	hitArea.MouseEnter:Connect(function()
		Tween(bg, { BackgroundColor3 = Color3.fromRGB(42, 42, 42) }, 0.1)
	end)
	hitArea.MouseLeave:Connect(function()
		Tween(bg, { BackgroundColor3 = Theme.BackgroundTertiary }, 0.15)
	end)
	
	-- Init
	if config.Default or config.DefaultValue then
		UpdatePosition(comp.Value)
	end
	
	comp.SetValue = function(_, val)
		UpdatePosition(math.clamp(val, comp.Min, comp.Max))
	end
	comp.GetValue = function()
		return comp.Value
	end
	comp.Destroy = function()
		conn:Disconnect()
		container:Destroy()
	end
	
	table.insert(self.Components, comp)
	return comp
end

-- DROPDOWN
function SectionMethods:AddDropdown(config)
	config = config or {}
	
	local comp = {}
	comp.Type = "Dropdown"
	local title = config.Title or config.title or "Dropdown"
	local desc = config.Description or config.description or nil
	local values = config.Values or config.values or config.Options or config.options or {}
	local cb = config.Callback or config.OnChanged or config.callback or config.OnSelected or function() end
	
	comp.Values = values
	comp.Selected = config.Default or config.default or (values[1] or "None")
	comp.Open = false
	
	local container = New("Frame", {
		Name = "Dropdown_" .. tostring(title):gsub("%s+", "_"),
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 36),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
		ClipsDescendants = false,
		ZIndex = 10,
	})
	comp.Container = container
	
	local bg = New("Frame", {
		Parent = container,
		BackgroundColor3 = Theme.BackgroundTertiary,
		Size = UDim2.new(1, 0, 0, 36),
		BorderSize = 0,
	})
	New("UICorner", { Parent = bg, CornerRadius = UDim.new(0, 6) })
	
	New("TextLabel", {
		Parent = bg,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 14,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -80, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSize = 0,
	})
	
	local valLabel = New("TextLabel", {
		Parent = bg,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = tostring(comp.Selected),
		TextColor3 = Theme.Accent,
		TextSize = 12,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -40, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSize = 0,
	})
	comp.ValueLabel = valLabel
	
	local arrow = New("TextLabel", {
		Parent = bg,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "▼",
		TextColor3 = Theme.TextMuted,
		TextSize = 10,
		Position = UDim2.new(1, -24, 0, 0),
		Size = UDim2.new(0, 20, 1, 0),
		BorderSize = 0,
	})
	comp.Arrow = arrow
	
	-- Dropdown list
	local list = New("Frame", {
		Parent = container,
		BackgroundColor3 = Theme.BackgroundSecondary,
		Size = UDim2.new(1, -10, 0, 0),
		Position = UDim2.new(0, 5, 0, 38),
		BorderSize = 0,
		Visible = false,
		ClipsDescendants = true,
		ZIndex = 20,
	})
	New("UICorner", { Parent = list, CornerRadius = UDim.new(0, 6) })
	New("UIStroke", { Parent = list, Color = Theme.Border, Thickness = 1 })
	
	local listLayout = New("UIListLayout", {
		Parent = list,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
	})
	
	local listItems = {}
	
	local function RebuildItems(newValues)
		-- Clear old
		for _, item in ipairs(listItems) do
			item:Destroy()
		end
		listItems = {}
		
		comp.Values = newValues or comp.Values
		
		for _, v in ipairs(comp.Values) do
			local item = New("TextButton", {
				Parent = list,
				BackgroundColor3 = Color3.fromRGB(32, 32, 32),
				Size = UDim2.new(1, -8, 0, 30),
				Position = UDim2.new(0, 4, 0, 0),
				Text = tostring(v),
				TextColor3 = Theme.Text,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutoButtonColor = false,
				BorderSize = 0,
				ZIndex = 21,
			})
			New("UIPadding", { Parent = item, PaddingLeft = UDim.new(0, 8) })
			New("UICorner", { Parent = item, CornerRadius = UDim.new(0, 4) })
			
			item.MouseEnter:Connect(function()
				Tween(item, { BackgroundColor3 = Color3.fromRGB(45, 45, 45) }, 0.08)
			end)
			item.MouseLeave:Connect(function()
				Tween(item, { BackgroundColor3 = Color3.fromRGB(32, 32, 32) }, 0.1)
			end)
			item.MouseButton1Click:Connect(function()
				comp.Selected = v
				valLabel.Text = tostring(v)
				pcall(cb, v)
				comp:Close()
			end)
			
			table.insert(listItems, item)
		end
		
		-- Set default
		if #comp.Values > 0 then
			comp.Selected = comp.Values[1]
			valLabel.Text = tostring(comp.Values[1])
		end
	end
	
	RebuildItems(values)
	
	-- Toggle button
	local btn = New("TextButton", {
		Parent = bg,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 11,
		BorderSize = 0,
	})
	
	btn.MouseButton1Click:Connect(function()
		if comp.Open then
			comp:Close()
		else
			comp:Open()
		end
	end)
	
	btn.MouseEnter:Connect(function()
		Tween(bg, { BackgroundColor3 = Color3.fromRGB(42, 42, 42) }, 0.1)
	end)
	btn.MouseLeave:Connect(function()
		Tween(bg, { BackgroundColor3 = Theme.BackgroundTertiary }, 0.15)
	end)
	
	comp.Open = function()
		if comp.Open or #comp.Values == 0 then return end
		comp.Open = true
		list.Visible = true
		arrow.Text = "▲"
		
		local h = #comp.Values * 32 + 4
		list.Size = UDim2.new(1, -10, 0, h)
		list.ZIndex = 20
		
		Tween(arrow, { Rotation = 180 }, 0.15)
	end
	
	comp.Close = function()
		if not comp.Open then return end
		comp.Open = false
		arrow.Text = "▼"
		Tween(arrow, { Rotation = 0 }, 0.12)
		task.delay(0.05, function()
			list.Visible = false
		end)
	end
	
	comp.SetValues = function(_, newVals)
		comp:Close()
		RebuildItems(newVals)
	end
	
	comp.SetValue = function(_, val)
		comp.Selected = val
		valLabel.Text = tostring(val)
		pcall(cb, val)
	end
	
	comp.GetValue = function()
		return comp.Selected
	end
	
	comp.Destroy = function()
		container:Destroy()
	end
	
	table.insert(self.Components, comp)
	return comp
end

-- LABEL
function SectionMethods:AddLabel(text, description)
	local comp = {}
	comp.Type = "Label"
	
	local container = New("Frame", {
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, description and 44 or 28),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	comp.Container = container
	
	local lbl = New("TextLabel", {
		Parent = container,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 14,
		Position = UDim2.new(0, 5, 0, description and 2 or 0),
		Size = UDim2.new(1, -10, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSize = 0,
	})
	comp.Label = lbl
	
	if description then
		New("TextLabel", {
			Parent = container,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = description,
			TextColor3 = Theme.TextMuted,
			TextSize = 11,
			Position = UDim2.new(0, 5, 0, 22),
			Size = UDim2.new(1, -10, 0, 18),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			BorderSize = 0,
		})
	end
	
	comp.SetText = function(_, newText)
		lbl.Text = newText
	end
	
	comp.Destroy = function()
		container:Destroy()
	end
	
	table.insert(self.Components, comp)
	return comp
end

-- KEYBIND
function SectionMethods:AddKeybind(config)
	config = config or {}
	
	local comp = {}
	comp.Type = "Keybind"
	local title = config.Title or config.title or "Keybind"
	local desc = config.Description or config.description or nil
	local cb = config.Callback or config.OnChanged or config.callback or function() end
	
	comp.Key = config.Default or config.default or Enum.KeyCode.Unknown
	comp.Listening = false
	
	local container = New("Frame", {
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 36),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	comp.Container = container
	
	local bg = New("Frame", {
		Parent = container,
		BackgroundColor3 = Theme.BackgroundTertiary,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSize = 0,
	})
	New("UICorner", { Parent = bg, CornerRadius = UDim.new(0, 6) })
	
	New("TextLabel", {
		Parent = bg,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 14,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -90, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSize = 0,
	})
	
	-- Key display
	local function GetKeyName(key)
		if key == Enum.KeyCode.Unknown then return "None" end
		local name = tostring(key):gsub("Enum.KeyCode.", "")
		local map = {
			LeftShift = "L-Shift", RightShift = "R-Shift",
			LeftControl = "L-Ctrl", RightControl = "R-Ctrl",
			LeftAlt = "L-Alt", RightAlt = "R-Alt",
			Backspace = "Bksp", Return = "Enter",
		}
		return map[name] or name
	end
	
	local keyBtn = New("TextButton", {
		Parent = bg,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		Size = UDim2.new(0, 70, 0, 24),
		Position = UDim2.new(1, -78, 0.5, -12),
		Text = GetKeyName(comp.Key),
		TextColor3 = Theme.Accent,
		TextSize = 12,
		Font = Enum.Font.GothamSemibold,
		AutoButtonColor = false,
		BorderSize = 0,
		ZIndex = 2,
	})
	New("UICorner", { Parent = keyBtn, CornerRadius = UDim.new(0, 4) })
	comp.KeyLabel = keyBtn
	
	keyBtn.MouseEnter:Connect(function()
		if not comp.Listening then
			Tween(keyBtn, { BackgroundColor3 = Color3.fromRGB(50, 50, 50) }, 0.08)
		end
	end)
	keyBtn.MouseLeave:Connect(function()
		if not comp.Listening then
			Tween(keyBtn, { BackgroundColor3 = Color3.fromRGB(40, 40, 40) }, 0.1)
		end
	end)
	
	keyBtn.MouseButton1Click:Connect(function()
		comp.Listening = true
		keyBtn.Text = "..."
		keyBtn.TextColor3 = Theme.Warning
		Tween(keyBtn, { BackgroundColor3 = Color3.fromRGB(60, 30, 30) }, 0.1)
	end)
	
	-- Listen for keypresses
	local conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if comp.Listening and not gameProcessed then
			comp.Key = input.KeyCode
			keyBtn.Text = GetKeyName(input.KeyCode)
			keyBtn.TextColor3 = Theme.Accent
			comp.Listening = false
			Tween(keyBtn, { BackgroundColor3 = Color3.fromRGB(40, 40, 40) }, 0.1)
			pcall(cb, input.KeyCode)
		elseif not comp.Listening and not gameProcessed then
			if input.KeyCode == comp.Key and comp.Key ~= Enum.KeyCode.Unknown then
				pcall(cb, input.KeyCode)
			end
		end
	end)
	
	comp.GetKey = function()
		return comp.Key
	end
	
	comp.SetKey = function(_, keyCode)
		comp.Key = keyCode
		keyBtn.Text = GetKeyName(keyCode)
	end
	
	comp.Destroy = function()
		conn:Disconnect()
		container:Destroy()
	end
	
	table.insert(self.Components, comp)
	return comp
end

-- TEXTBOX
function SectionMethods:AddTextbox(config)
	config = config or {}
	
	local comp = {}
	comp.Type = "Textbox"
	local title = config.Title or config.title or "Input"
	local desc = config.Description or config.description or nil
	local placeholder = config.Placeholder or config.placeholder or "Type here..."
	local defaultValue = config.Default or config.default or ""
	local cb = config.Callback or config.OnChanged or config.callback or function() end
	local multiline = config.Multiline or config.multiline or false
	local numeric = config.Numeric or config.numeric or false
	
	local height = multiline and 80 or 52
	
	local container = New("Frame", {
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, height),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	comp.Container = container
	
	local bg = New("Frame", {
		Parent = container,
		BackgroundColor3 = Theme.BackgroundTertiary,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSize = 0,
	})
	New("UICorner", { Parent = bg, CornerRadius = UDim.new(0, 6) })
	
	New("TextLabel", {
		Parent = bg,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 14,
		Position = UDim2.new(0, 12, 0, 6),
		Size = UDim2.new(1, -24, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSize = 0,
	})
	
	local inputH = multiline and 48 or 24
	
	local inputContainer = New("Frame", {
		Parent = bg,
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),
		Size = UDim2.new(1, -24, 0, inputH),
		Position = UDim2.new(0, 12, 0, 26),
		BorderSize = 0,
	})
	New("UICorner", { Parent = inputContainer, CornerRadius = UDim.new(0, 4) })
	
	local stroke = New("UIStroke", {
		Parent = inputContainer,
		Color = Color3.fromRGB(50, 50, 50),
		Thickness = 1,
	})
	
	local input = New("TextBox", {
		Parent = inputContainer,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = defaultValue,
		TextColor3 = Theme.Text,
		TextSize = 13,
		PlaceholderText = placeholder,
		PlaceholderColor3 = Theme.TextMuted,
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(1, -16, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
		ClearTextOnFocus = false,
		BorderSize = 0,
		MultiLine = multiline,
	})
	comp.Input = input
	
	input.Focused:Connect(function()
		Tween(inputContainer, { BackgroundColor3 = Color3.fromRGB(38, 38, 38) }, 0.08)
		Tween(stroke, { Color = Theme.Accent }, 0.1)
	end)
	
	input.FocusLost:Connect(function()
		Tween(inputContainer, { BackgroundColor3 = Color3.fromRGB(32, 32, 32) }, 0.08)
		Tween(stroke, { Color = Color3.fromRGB(50, 50, 50) }, 0.1)
		
		local val = input.Text
		if numeric then
			local num = tonumber(val)
			if num then
				val = tostring(num)
				input.Text = val
			else
				val = defaultValue
				input.Text = val
			end
		end
		pcall(cb, val)
	end)
	
	comp.SetText = function(_, text)
		input.Text = text
	end
	
	comp.GetText = function()
		return input.Text
	end
	
	comp.Destroy = function()
		container:Destroy()
	end
	
	table.insert(self.Components, comp)
	return comp
end

-- PARAGRAPH
function SectionMethods:AddParagraph(ptitle, content)
	local comp = {}
	comp.Type = "Paragraph"
	
	local container = New("Frame", {
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	comp.Container = container
	
	if ptitle and ptitle ~= "" then
		local titleLbl = New("TextLabel", {
			Parent = container,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Text = ptitle,
			TextColor3 = Theme.Text,
			TextSize = 16,
			Position = UDim2.new(0, 5, 0, 0),
			Size = UDim2.new(1, -10, 0, 24),
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSize = 0,
		})
		comp.TitleLabel = titleLbl
	end
	
	if content and content ~= "" then
		local yPos = (ptitle and ptitle ~= "") and 26 or 0
		local contentLbl = New("TextLabel", {
			Parent = container,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = content,
			TextColor3 = Theme.TextSecondary,
			TextSize = 12,
			Position = UDim2.new(0, 5, 0, yPos),
			Size = UDim2.new(1, -10, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			RichText = true,
			BorderSize = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		comp.ContentLabel = contentLbl
	end
	
	comp.SetTitle = function(_, text)
		if comp.TitleLabel then comp.TitleLabel.Text = text end
	end
	
	comp.SetContent = function(_, text)
		if comp.ContentLabel then comp.ContentLabel.Text = text end
	end
	
	comp.Destroy = function()
		container:Destroy()
	end
	
	table.insert(self.Components, comp)
	return comp
end

-- SEPARATOR
function SectionMethods:AddSeparator()
	local comp = {}
	comp.Type = "Separator"
	
	local container = New("Frame", {
		Parent = self.Container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 12),
		LayoutOrder = #self.Components + 1,
		BorderSize = 0,
	})
	comp.Container = container
	
	New("Frame", {
		Parent = container,
		BackgroundColor3 = Theme.Border,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0.5, 0),
		BorderSize = 0,
	})
	
	comp.Destroy = function()
		container:Destroy()
	end
	
	table.insert(self.Components, comp)
	return comp
end

-- ============================================
-- NOTIFICATIONS
-- ============================================

function Fluent:Notify(config)
	config = config or {}
	
	local title = config.Title or config.title or "Notification"
	local content = config.Content or config.content or config.Description or config.description or ""
	local duration = config.Duration or config.duration or 4
	
	local window = ActiveWindows[1]
	if not window then return end
	
	-- Container
	local notifContainer = window.Main:FindFirstChild("NotificationContainer")
	if not notifContainer then
		notifContainer = New("Frame", {
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
		New("UIListLayout", {
			Parent = notifContainer,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		})
	end
	
	-- Notification frame
	local notif = New("Frame", {
		Parent = notifContainer,
		BackgroundColor3 = Theme.BackgroundSecondary,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderSize = 0,
		ZIndex = 101,
	})
	New("UICorner", { Parent = notif, CornerRadius = UDim.new(0, 6) })
	New("UIStroke", { Parent = notif, Color = Theme.Border, Thickness = 1 })
	
	-- Accent bar
	local accentBar = New("Frame", {
		Name = "AccentBar",
		Parent = notif,
		BackgroundColor3 = Theme.Accent,
		Size = UDim2.new(0, 3, 1, -4),
		Position = UDim2.new(0, 0, 0, 2),
		BorderSize = 0,
		ZIndex = 102,
	})
	New("UICorner", { Parent = accentBar, CornerRadius = UDim.new(0, 2) })
	
	-- Title
	local titleLbl = New("TextLabel", {
		Name = "Title",
		Parent = notif,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 14,
		Position = UDim2.new(0, 14, 0, 8),
		Size = UDim2.new(1, -28, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSize = 0,
		ZIndex = 102,
	})
	
	-- Content
	local contentLbl = New("TextLabel", {
		Name = "Content",
		Parent = notif,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = content,
		TextColor3 = Theme.TextSecondary,
		TextSize = 12,
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
	local approxH = math.max(50, contentLbl.TextBounds.Y + 42)
	notif.Size = UDim2.new(1, 0, 0, approxH)
	
	-- Start invisible for animation
	notif.Position = UDim2.new(0, 0, 0, 50)
	notif.BackgroundTransparency = 1
	accentBar.BackgroundTransparency = 1
	titleLbl.TextTransparency = 1
	contentLbl.TextTransparency = 1
	
	task.wait(0.05)
	
	-- Animate in
	Tween(notif, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0 }, 0.2)
	Tween(accentBar, { BackgroundTransparency = 0 }, 0.25)
	Tween(titleLbl, { TextTransparency = 0 }, 0.2)
	Tween(contentLbl, { TextTransparency = 0 }, 0.25)
	
	-- Auto-dismiss
	task.delay(duration, function()
		if notif and notif.Parent then
			Tween(notif, { Position = UDim2.new(0, 0, 0, -20), BackgroundTransparency = 1 }, 0.15)
			Tween(titleLbl, { TextTransparency = 1 }, 0.12)
			Tween(contentLbl, { TextTransparency = 1 }, 0.12)
			task.delay(0.2, function()
				pcall(notif.Destroy, notif)
			end)
		end
	end)
end

-- Return the library
return Fluent
