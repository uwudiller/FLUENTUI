--[[
	Fluent UI - Example Usage
	==========================
	This file demonstrates how to use the Fluent UI library.
	
	To use:
	1. Load the library via loadstring
	2. Create a window
	3. Add tabs, sections, and components
	
	Run this in a Roblox executor with the library loaded.
--]]

-- Load the library (replace URL with your hosting URL)
-- local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/fluent/main/fluent.lua"))()

-- For local testing (if you have the file in workspace):
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/uwudiller/FLUENTUI/refs/heads/main/fluent.lua"))()

-- If you want to host it locally, you can also do:
-- local Fluent = loadstring(game:GetObjects("rbxassetid://YOUR_ASSET_ID")[1].Source)()
-- or insert the library script directly into your executor

-- Create the main window
local Window = Fluent:CreateWindow({
	Title = "My Executor v1.0",
	Size = UDim2.new(0, 680, 0, 500),
	Position = UDim2.new(0.5, -340, 0.5, -250),
	Keybind = Enum.KeyCode.RightShift, -- Optional: keybind to toggle visibility
})

-- ============================================
-- TAB 1: HOME / GETTING STARTED
-- ============================================
local HomeTab = Window:AddTab("Home")

-- Documentation / welcome paragraph
HomeTab:AddParagraph("Welcome to Fluent UI", 
	"This is a modern, Fluent Design-inspired UI library for Roblox executors. " ..
	"It features a clean, dark-themed interface with smooth animations and responsive controls.\n\n" ..
	"<b>Key Features:</b>\n" ..
	"• Fluent Design aesthetics with custom rendering\n" ..
	"• Fully draggable windows with minimize/maximize\n" ..
	"• Tab navigation system with animated indicators\n" ..
	"• Buttons, Toggles, Sliders, Dropdowns, Keybinds & more\n" ..
	"• Notification system with slide-in animations\n" ..
	"• All components are fully customizable"
)

-- Separator
HomeTab:AddSeparator()

-- Quick actions section
local QuickSection = HomeTab:AddSection("Quick Actions")

QuickSection:AddButton("Load Latest Script", function()
	print("Loading latest script...")
	Fluent:Notify({
		Title = "Script Loaded",
		Content = "Latest script has been loaded successfully!",
		Duration = 3
	})
end, "Click to execute the latest script")

QuickSection:AddAccentButton("Execute Selected Script", function()
	print("Executing...")
	Fluent:Notify({
		Title = "Execution",
		Content = "Script executed successfully.",
		Duration = 2
	})
end, "Run the currently selected script")

-- ============================================
-- TAB 2: SETTINGS
-- ============================================
local SettingsTab = Window:AddTab("Settings")

-- Visual settings section
local VisualSection = SettingsTab:AddSection("Visual Settings")

VisualSection:AddToggle({
	Title = "Dark Mode",
	Description = "Toggle dark mode theme",
	Default = true,
	Callback = function(value)
		print("Dark Mode:", value)
	end
})

VisualSection:AddToggle({
	Title = "Auto-Execute",
	Description = "Auto-execute scripts on injection",
	Default = false,
	Callback = function(value)
		print("Auto-Execute:", value)
	end
})

VisualSection:AddToggle({
	Title = "Notifications",
	Description = "Show notifications for events",
	Default = true,
	Callback = function(value)
		print("Notifications:", value)
	end
})

-- Slider settings
local SliderSection = SettingsTab:AddSection("Preferences")

local SpeedSlider = SliderSection:AddSlider({
	Title = "Execution Speed",
	Description = "Adjust script execution speed",
	Default = 50,
	Min = 0,
	Max = 100,
	Suffix = "%",
	Precision = 0,
	Callback = function(value)
		print("Speed set to:", value .. "%")
	end
})

local VolumeSlider = SliderSection:AddSlider({
	Title = "Sound Volume",
	Description = "Adjust interface sound volume",
	Default = 75,
	Min = 0,
	Max = 100,
	Suffix = "%",
	Precision = 0,
	Callback = function(value)
		print("Volume set to:", value .. "%")
	end
})

local OpacitySlider = SliderSection:AddSlider({
	Title = "Window Opacity",
	Description = "Adjust window transparency",
	Default = 1.0,
	Min = 0.1,
	Max = 1.0,
	Suffix = "",
	Precision = 1,
	Callback = function(value)
		print("Opacity set to:", value)
	end
})

-- ============================================
-- TAB 3: SCRIPTS
-- ============================================
local ScriptsTab = Window:AddTab("Scripts")

-- Script management section
local ScriptSection = ScriptsTab:AddSection("Script Library")

ScriptSection:AddButton("Infinite Yield", function()
	print("Executing Infinite Yield...")
	-- loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
	Fluent:Notify({
		Title = "Infinite Yield",
		Content = "Infinite Yield admin script has been loaded.",
		Duration = 3
	})
end, "Popular admin commands script")

ScriptSection:AddButton("Dex Explorer", function()
	print("Executing Dex Explorer...")
	Fluent:Notify({
		Title = "Dex Explorer",
		Content = "Dex Explorer has been loaded.",
		Duration = 3
	})
end, "Roblox instance explorer")

ScriptSection:AddButton("Remote Spy", function()
	print("Executing Remote Spy...")
	Fluent:Notify({
		Title = "Remote Spy",
		Content = "Remote Spy has been loaded.",
		Duration = 3
	})
end, "Spy on remote events and functions")

-- Custom scripts section
local CustomSection = ScriptsTab:AddSection("Custom Script")

local ScriptInput = CustomSection:AddTextbox({
	Title = "Script Editor",
	Placeholder = "Paste your Lua script here...",
	Multiline = true,
	Default = "",
	Callback = function(value)
		-- This fires when focus is lost or Enter is pressed
	end
})

CustomSection:AddAccentButton("Execute Custom Script", function()
	print("Executing custom script...")
	-- local script = ScriptInput:GetText()
	-- local success, err = pcall(loadstring(script))
	-- if success then
	-- 	Fluent:Notify({Title = "Success", Content = "Script executed successfully.", Duration = 2})
	-- else
	-- 	Fluent:Notify({Title = "Error", Content = "Failed to execute: " .. tostring(err), Duration = 5, Type = "error"})
	-- end
end, "Run your custom Lua script")

-- ============================================
-- TAB 4: DROPDOWN & SELECTION
-- ============================================
local SelectionTab = Window:AddTab("Selection")

-- Dropdown section
local DropdownSection = SelectionTab:AddSection("Selection Options")

local ExecutionMode = DropdownSection:AddDropdown({
	Title = "Execution Mode",
	Description = "Select script execution mode",
	Values = {"Normal", "Fast", "Stealth", "Hybrid"},
	Default = "Normal",
	Callback = function(value)
		print("Execution Mode:", value)
	end
})

local ThemeDropdown = DropdownSection:AddDropdown({
	Title = "Theme Selection",
	Description = "Choose UI color scheme",
	Values = {"Dark (Default)", "Amethyst", "Emerald", "Ruby", "Sapphire"},
	Default = "Dark (Default)",
	Callback = function(value)
		print("Theme:", value)
		if value == "Amethyst" then
			-- Change accent color to purple
		elseif value == "Emerald" then
			-- Change accent color to green
		end
	end
})

local TargetDropdown = DropdownSection:AddDropdown({
	Title = "Target Player",
	Description = "Select target player for scripts",
	Values = {"All Players", "Nearest", "Random", "Specific..."},
	Default = "All Players",
	Callback = function(value)
		print("Target:", value)
	end
})

-- ============================================
-- TAB 5: KEYBINDS
-- ============================================
local KeybindsTab = Window:AddTab("Keybinds")

-- Keybind section
local KeybindSection = KeybindsTab:AddSection("Keybind Configuration")

KeybindSection:AddKeybind({
	Title = "Toggle UI",
	Description = "Show/hide the UI window",
	Default = Enum.KeyCode.RightShift,
	Callback = function(key)
		Window:ToggleVisibility()
		print("UI toggled with:", key)
	end
})

KeybindSection:AddKeybind({
	Title = "Execute Script",
	Description = "Quickly execute selected script",
	Default = Enum.KeyCode.F5,
	Callback = function(key)
		print("Script execution triggered with:", key)
		-- Execute logic here
	end
})

KeybindSection:AddKeybind({
	Title = "Toggle Console",
	Description = "Show/hide the debug console",
	Default = Enum.KeyCode.F6,
	Callback = function(key)
		print("Console toggled with:", key)
	end
})

-- Label section for instructions
KeybindSection:AddLabel("Keybind Instructions", 
	"Click on a keybind button above, then press any key to rebind it. " ..
	"Press Escape or click away to cancel the rebinding."
)

-- ============================================
-- TAB 6: ABOUT / INFO
-- ============================================
local AboutTab = Window:AddTab("About")

-- About section
AboutTab:AddParagraph("Fluent UI v1.0.0", 
	"<b>Fluent UI</b> is a modern, fully custom user interface library designed specifically for Roblox executors.\n\n" ..
	"Built with Fluent Design principles, it provides a clean, professional look with smooth " ..
	"animations and a responsive layout that adapts to any screen size."
)

AboutTab:AddSeparator()

AboutTab:AddParagraph("Component Reference", 
	"<b>Available Components:</b>\n\n" ..
	"• <b>Button</b> - Standard action button\n" ..
	"• <b>AccentButton</b> - Filled accent-colored button\n" ..
	"• <b>Toggle</b> - On/off switch with smooth animation\n" ..
	"• <b>Slider</b> - Draggable value selector\n" ..
	"• <b>Dropdown</b> - Expandable option selector\n" ..
	"• <b>Keybind</b> - Rebindable key input\n" ..
	"• <b>Textbox</b> - Text input field (single/multi-line)\n" ..
	"• <b>Label</b> - Static text display\n" ..
	"• <b>Paragraph</b> - Title + content block for documentation\n" ..
	"• <b>Separator</b> - Visual divider line\n" ..
	"• <b>Notifications</b> - Slide-in notification popups"
)

AboutTab:AddSeparator()

AboutTab:AddParagraph("API Documentation",
	"<b>Window Methods:</b>\n" ..
	"• <b>Window:AddTab(title, icon?)</b> - Create a new tab\n" ..
	"• <b>Window:SelectTab(name/index)</b> - Switch to a tab\n" ..
	"• <b>Window:SetMinimized(bool)</b> - Minimize/restore\n" ..
	"• <b>Window:ToggleVisibility()</b> - Show/hide window\n" ..
	"• <b>Window:Destroy()</b> - Remove the window\n\n" ..
	
	"<b>Tab Methods:</b>\n" ..
	"• <b>Tab:AddSection(title)</b> - Add a section container\n" ..
	"• <b>Tab:AddButton(text, callback, desc?)</b> - Quick add button\n" ..
	"• <b>Tab:AddToggle(config)</b> - Quick add toggle\n" ..
	"• <b>Tab:AddSlider(config)</b> - Quick add slider\n" ..
	"• <b>Tab:AddDropdown(config)</b> - Quick add dropdown\n" ..
	"• <b>Tab:AddKeybind(config)</b> - Quick add keybind\n" ..
	"• <b>Tab:AddLabel(text, desc?)</b> - Quick add label\n" ..
	"• <b>Tab:AddParagraph(title, content)</b> - Quick add paragraph\n" ..
	"• <b>Tab:AddTextbox(config)</b> - Quick add textbox\n\n" ..
	
	"<b>Section Methods:</b>\n" ..
	"• <b>Section:AddButton(text, callback, desc?)</b> - Add a button\n" ..
	"• <b>Section:AddAccentButton(text, callback, desc?)</b> - Add accent button\n" ..
	"• <b>Section:AddToggle(config)</b> - Add a toggle switch\n" ..
	"• <b>Section:AddSlider(config)</b> - Add a slider\n" ..
	"• <b>Section:AddDropdown(config)</b> - Add a dropdown\n" ..
	"• <b>Section:AddKeybind(config)</b> - Add a keybind\n" ..
	"• <b>Section:AddTextbox(config)</b> - Add a text input\n" ..
	"• <b>Section:AddLabel(text, desc?)</b> - Add a label\n" ..
	"• <b>Section:AddParagraph(title, content)</b> - Add documentation\n" ..
	"• <b>Section:AddSeparator()</b> - Add a divider\n\n" ..
	
	"<b>Notification:</b>\n" ..
	"• <b>Fluent:Notify({Title, Content, Duration})</b> - Show notification"
)

-- ============================================
-- DEMONSTRATE NOTIFICATIONS
-- ============================================

-- Show a welcome notification after a short delay
task.delay(0.5, function()
	Fluent:Notify({
		Title = "Welcome to Fluent UI",
		Content = "The UI has loaded successfully. Try out the different components!",
		Duration = 4
	})
end)

-- ============================================
-- DEMONSTRATE SCRIPT EDITING
-- ============================================

-- You can also dynamically update components:
-- SpeedSlider:SetValue(75)
-- SomeToggle:SetValue(true)
-- SomeDropdown:SetValues({"New", "Values", "Here"})

-- ============================================
-- NOTES
-- ============================================

--[[
	IMPORTANT NOTES:
	
	1. The UI is fully custom-drawn - it doesn't use any Roblox default UI styles.
	
	2. All components support :Destroy() for cleanup.
	
	3. Toggles, sliders, dropdowns, and keybinds support a "Flag" property
	   that can be used to save/load settings via Fluent.Flags table.
	
	4. You can chain methods:
	   Window:AddTab("Main"):AddSection("Section"):AddButton("Click", function() end)
	
	5. For dropdowns, you can update values dynamically:
	   local dd = Section:AddDropdown({...})
	   dd:SetValues({"New Option 1", "New Option 2"})
	   dd:SetValue("New Option 1")
	
	6. For sliders, you can update values:
	   local sl = Section:AddSlider({...})
	   sl:SetValue(75)
	   print(sl:GetValue())
	
	7. Keybinds listen globally for their key:
	   local kb = Section:AddKeybind({...})
	   print(kb:GetKey())
	   kb:SetKey(Enum.KeyCode.F1)
	
	8. Textboxes support both single-line and multi-line:
	   local tb = Section:AddTextbox({Title = "Input", Multiline = true})
	   tb:SetText("New text")
	   print(tb:GetText())
--]]

-- Print that the example has loaded
print("Fluent UI Example has loaded successfully!")
print("Press RightShift to toggle the UI visibility.")
