--[[
	AuctioneerAdvanced Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

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
			gui.Resave()

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
		gui.Refresh()
	else
		-- Set the value for this setting in the current profile
		local db = getUserProfile()
		db[setting] = value
	end

end

function lib.SetSetting(...)
	setter(...)
	if (gui) then
		gui.Refresh()
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
	gui = Configator.NewConfigator(setter, getter)
	lib.Gui = gui

  	gui.AddCat("Core Options")
  
	id = gui.AddTab("Profiles")
	gui.AddControl(id, "Header",     0,    "Setup, configure and edit profiles")
	gui.AddControl(id, "Subhead",    0,    "Activate a current profile")
	gui.AddControl(id, "Selectbox",  0, 1, "profile.profiles", "profile", "Switch to given profile")
	gui.AddControl(id, "Button",     0, 1, "profile.delete", "Delete")
	gui.AddControl(id, "Subhead",    0,    "Create or replace a profile")
	gui.AddControl(id, "Text",       0, 1, "profile.name", "New profile name:")
	gui.AddControl(id, "Button",     0, 1, "profile.save", "Save")
	
	id = gui.AddTab("General")
	gui.AddControl(id, "Header",     0,    "Main AucAdvanced options")

  	gui.AddCat("Modules")

	-- Alert all modules that the config screen is being built, so that they
	-- may place their own configuration should they desire it.
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.Processor) then engineLib.Processor("config", gui) end
		end
	end
end

local sideIcon
if (DongleStub and DongleStub.versions["nSideBar-0.1"]) then
	local nSideBar = DongleStub("nSideBar-0.1")
	if nSideBar then
		sideIcon = nSideBar.AddButton("AucAdvanced", "Interface\\AddOns\\Auc-Advanced\\Textures\\AucAdvIcon")
		sideIcon:RegisterForClicks("LeftButtonUp","RightButtonUp")
		sideIcon:SetScript("OnClick", lib.Toggle)
	end
end

