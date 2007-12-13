--[[
	Auctioneer Advanced
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

	Settings GUI

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit licence to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat


data layout:
		AucAdvancedConfig = {

			["profile.test4"] = {
				["miniicon.distance"] = 56,
				["miniicon.angle"] = 189,
				["show"] = true,
				["enable"] = true,
			},

			["profiles"] = {
				"Default", -- [1]
				"test4", -- [2]
			},

			["users.Foobar.Picksell"] = "test4",

			["profile.Default"] = {
				["miniicon.angle"] = 187,
				["miniicon.distance"] = 15,
			},

		}

if user does not have a set profile name, they get the default profile


Usage:
	def = AucAdvanced.Settings.GetDefault('ToolTipShowCounts')
	val = AucAdvanced.Settings.GetSetting('ToolTipShowCounts')
	AucAdvanced.Settings.SetSetting('ToolTipShowCounts', true );

]]

local lib = {}
AucAdvanced.Settings = lib
local private = {}
local gui

local function getUserSig()
	local userSig = string.format("users.%s.%s", GetRealmName(), UnitName("player"))
	return userSig
end

local function getUserProfileName()
	if (not AucAdvancedConfig) then AucAdvancedConfig = {} end
	local userSig = getUserSig()
	return AucAdvancedConfig[userSig] or "Default"
end

local function getUserProfile()
	if (not AucAdvancedConfig) then AucAdvancedConfig = {} end
	local profileName = getUserProfileName()
	if (not AucAdvancedConfig["profile."..profileName]) then
		if profileName ~= "Default" then
			profileName = "Default"
			AucAdvancedConfig[getUserSig()] = "Default"
		end
		if profileName == "Default" then
			AucAdvancedConfig["profile."..profileName] = {}
		end
	end
	return AucAdvancedConfig["profile."..profileName]
end


local function cleanse( profile )
	if (profile) then
		profile = {}
	end
end


-- Default setting values
local settingDefaults = {
	['all'] = true,
	['locale'] = 'default',
	['scandata.tooltip.display'] = false,
	['scandata.tooltip.modifier'] = true,
	['scandata.force'] = false,
	['scandata.summary'] = true,
	['clickhook.enable'] = true,
	['scancommit.speed'] = 20,
	['scancommit.progressbar'] = true,
}

local function getDefault(setting)
	local a,b,c = strsplit(".", setting)

	-- basic settings
	if (a == "show") then return true end
	if (b == "enable") then return true end

	-- lookup the simple settings
	local result = settingDefaults[setting];

	return result
end

function lib.GetDefault(setting)
	local val = getDefault(setting);
	return val;
end

function lib.SetDefault(setting, default)
	settingDefaults[setting] = default
end

local function setter(setting, value)
	if (not AucAdvancedConfig) then AucAdvancedConfig = {} end

	-- turn value into a canonical true or false
	if value == 'on' then
		value = true
	elseif value == 'off' then
		value = false
	end

	-- for defaults, just remove the value and it'll fall through
	if (value == 'default') or (value == getDefault(setting)) then
		-- Don't save default values
		value = nil
	end

	local a,b,c = strsplit(".", setting)
	if (a == "profile") then
		if (setting == "profile.save") then
			value = gui.elements["profile.name"]:GetText()

			-- Create the new profile
			AucAdvancedConfig["profile."..value] = {}

			-- Set the current profile to the new profile
			AucAdvancedConfig[getUserSig()] = value
			-- Get the new current profile
			local newProfile = getUserProfile()

			-- Clean it out and then resave all data
			cleanse(newProfile)
			gui:Resave()

			-- Add the new profile to the profiles list
			local profiles = AucAdvancedConfig["profiles"]
			if (not profiles) then
				profiles = { "Default" }
				AucAdvancedConfig["profiles"] = profiles
			end

			-- Check to see if it already exists
			local found = false
			for pos, name in ipairs(profiles) do
				if (name == value) then found = true end
			end

			-- If not, add it and then sort it
			if (not found) then
				table.insert(profiles, value)
				table.sort(profiles)
			end

		elseif (setting == "profile.delete") then
			-- User clicked the Delete button, see what the select box's value is.
			value = gui.elements["profile"].value

			-- If there's a profile name supplied
			if (value) then
				-- Clean it's profile container of values
				cleanse(AucAdvancedConfig["profile."..value])

				-- Delete it's profile container
				AucAdvancedConfig["profile."..value] = nil

				-- Find it's entry in the profiles list
				local profiles = AucAdvancedConfig["profiles"]
				if (profiles) then
					for pos, name in ipairs(profiles) do
						-- If this is it, then extract it
						if (name == value and name ~= "Default") then
							table.remove(profiles, pos)
						end
					end
				end

				-- If the user was using this one, then move them to Default
				if (getUserProfileName() == value) then
					AucAdvancedConfig[getUserSig()] = 'Default'
				end
			end

		elseif (setting == "profile.default") then
			-- User clicked the reset settings button

			-- Get the current profile from the select box
			value = gui.elements["profile"].value

			-- Clean it's profile container of values
			AucAdvancedConfig["profile."..value] = {}

		elseif (setting == "profile") then
			-- User selected a different value in the select box, get it
			value = gui.elements["profile"].value

			-- Change the user's current profile to this new one
			AucAdvancedConfig[getUserSig()] = value

		end

		-- Refresh all values to reflect current data
		gui:Refresh()
	else
		-- Set the value for this setting in the current profile
		local db = getUserProfile()
		if db[setting] == value then return end
		db[setting] = value
	end

	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.Processor) then
				engineLib.Processor("configchanged", setting, value)
			end
		end
	end
end

function lib.SetSetting(...)
	setter(...)
	if (gui) then
		gui:Refresh()
	end
end


local function getter(setting)
	if (not AucAdvancedConfig) then AucAdvancedConfig = {} end
	if not setting then return end

	local a,b,c = strsplit(".", setting)
	if (a == 'profile') then
		if (b == 'profiles') then
			local pList = AucAdvancedConfig["profiles"]
			if (not pList) then
				pList = { "Default" }
			end
			return pList
		end
	end

	if (setting == 'profile') then
		return getUserProfileName()
	end

	local db = getUserProfile()
	if ( db[setting] ~= nil ) then
		return db[setting]
	else
		return getDefault(setting)
	end
end

function lib.GetSetting(setting, default)
	local option = getter(setting)
	if ( option ~= nil ) then
		return option
	else
		return default
	end
end


function lib.Show()
	lib.MakeGuiConfig()
	gui:Show()
end

function lib.Hide()
	if (gui) then
		gui:Hide()
	end
end

function lib.Toggle()
	if (gui and gui:IsShown()) then
		lib.Hide()
	else
		lib.Show()
	end
end

function lib.MakeGuiConfig()
	if gui then return end

	local id, last, cont
	local Configator = LibStub:GetLibrary("Configator")
	gui = Configator:Create(setter, getter)
	lib.Gui = gui

  	gui:AddCat("Core Options")

	id = gui:AddTab("Profiles")
	gui:AddControl(id, "Header",     0,    "Setup, configure and edit profiles")
	gui:AddControl(id, "Subhead",    0,    "Activate a current profile")
	gui:AddControl(id, "Selectbox",  0, 1, "profile.profiles", "profile", "Switch to given profile")
	gui:AddTip(id, "Select the profile that you wish to use for this character")

	gui:AddControl(id, "Button",     0, 1, "profile.delete", "Delete")
	gui:AddTip(id, "Deletes the currently selected profile")

	gui:AddControl(id, "Subhead",    0,    "Create or replace a profile")
	gui:AddControl(id, "Text",       0, 1, "profile.name", "New profile name:")
	gui:AddTip(id, "Enter the name of the profile that you wish to create")

	gui:AddControl(id, "Button",     0, 1, "profile.save", "Save")
	gui:AddTip(id, "Click this button to create or overwrite the specified profile name")

	gui:AddHelp(id, "what is",
		"What is a profile?",
		"A profile is used to contain a group of settings, you can use different profiles for different characters, or switch between profiles for the same character when doing different tasks."
	)
	gui:AddHelp(id, "how create",
		"How do I create a new profile?",
		"You enter the name of the new profile that you wish to create into the textbox labelled \"New profile name\", and then click the \"Save\" button. A profile may be called whatever you wish, but it should reflect the purpose of the profile so that you may more easily recall that purpose at a later date."
	)
	gui:AddHelp(id, "how delete",
		"How do I delete a profile?",
		"To delete a profile, simply select the profile you wish to delete with the drop-down selecteion box and then click the Delete button"
	)
	gui:AddHelp(id, "why delete",
		"Why would I want to delete a profile?",
		"You can delete a profile when you don't want to use it anymore, or you want to create it from scratch again with default values. Deleting a profile will also affect any other characters who are using the profile."
	)

	id = gui:AddTab("General")
	gui:AddControl(id, "Header",     0,    "Main AucAdvanced options")
	gui:AddControl(id, "Checkbox",   0, 1, "scandata.tooltip.display", "Display scan data tooltip")
	gui:AddTip(id, "Enable the display of how many items in the current scan image match this item")
	gui:AddControl(id, "Checkbox",   0, 2, "scandata.tooltip.modifier", "Only show exact match unless SHIFT is held")
	gui:AddTip(id, "Makes the scan data to only display exact matches unless the shift key is held down")
	gui:AddControl(id, "Checkbox",   0, 2, "scandata.force", "Force load scan data")
	gui:AddTip(id, "Forces the scan data to load when AuctioneerAdvanced is first loaded rather than on demand when first needed")

	gui:AddControl(id, "Checkbox",   0, 1, "scandata.summary", "Enables the display of the post scan summary")
	gui:AddTip(id, "Display the summation of a Auction House scan")
	
	gui:AddControl(id, "Checkbox",   0, 1, "clickhook.enable", "Enable searching click-hooks")
	gui:AddTip(id, "Enables the click-hooks for searching")
	
	gui:AddControl(id, "Slider",     0, 1, "scancommit.speed", 1, 100, 1, "Processing priority: %d")
	gui:AddTip(id, "Sets the processing priority of the scan data. Higher values take less time, but cause more lag")
	
	gui:AddControl(id, "Checkbox",   0, 1, "scancommit.progressbar", "Enable processing progressbar")
	gui:AddTip(id, "Displays a progress bar while Auctioneer Advanced is processing data")
	
	gui:AddHelp(id, "what is scandata",
		"What is the scan data tooltip?",
		"The scan data tooltip is a line that appears in your tooltip that informs you how many of the current item have been seen in the auctionhouse image.")
	gui:AddHelp(id, "what is image",
		"What is an auctionhouse image?",
		"As you scan the auctionhouse, AuctioneerAdvanced builds up an image of what is at auction. This is the image. It represents AuctioneerAdvanced's best guess at what is currently being auctioned. If your scan is fresh, this will be reasonably accurate, if it is not, then it will not.")
	gui:AddHelp(id, "what is exact",
		"What is an exact match?",
		"Some items can vary slightly by suffix (for example: of the Bear/Eagle/Ferret etc), or exact stats (eg: two items both of the Bear, but have differing statistics). An exact match will not match anything that is not 100% the same.")
	gui:AddHelp(id, "why force load",
		"Why would you want to force load the scan data?",
		"If you are going to be using the image data in the game, some people would prefer to wait longer for the game to start, rather than the game lagging for a couple of seconds when the data is demand loaded.")
	gui:AddHelp(id, "why show summation",
		"What is the post scan summary?",
		"If you want to know the number on new, updated, or unchanged auctions gathered from a scan of the auction house.")
	gui:AddHelp(id, "what is clickhook",
		"What are the click-hooks?",
		"The click-hooks let you perform a search for an item either by Alt-rightclicking the item in your bags, or by Alt-clicking an itemlink in the chat pane.")
	gui:AddHelp(id, "what is priority",
		"What is the Processing Priority?",
		"The Processing Priority sets the speed to process the data at the end of the scan. Lower values will take longer, but will let you move around more easily.  Higher values will take less time, but may cause jitter.  Updated data will not be available until processing is complete.")
	
  	gui:AddCat("Stat Modules")
  	gui:AddCat("Filter Modules")
  	gui:AddCat("Match Modules")
  	gui:AddCat("Util Modules")

	-- Alert all modules that the config screen is being built, so that they
	-- may place their own configuration should they desire it.
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.Processor) then engineLib.Processor("config", gui) end
		end
	end
end

local sideIcon
if LibStub then
	local SlideBar = LibStub:GetLibrary("SlideBar", true)
	if SlideBar then
		sideIcon = SlideBar.AddButton("AucAdvanced", "Interface\\AddOns\\Auc-Advanced\\Textures\\AucAdvIcon")
		sideIcon:RegisterForClicks("LeftButtonUp","RightButtonUp")
		sideIcon:SetScript("OnClick", lib.Toggle)
		sideIcon.tip = {
			"Auctioneer Advanced",
			"Auctioneer Advanced allows you to scan the auction house and collect statistics about prices.",
			"It also provides a framework for creating auction related addons.",
			"{{Click}} to edit the configuration.",
		}
	end
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")