--[[
	Informant - An addon for World of Warcraft that shows pertinent information about
	an item in a tooltip when you hover over the item in the game.
	Version: <%version%> (<%codename%>)
	Revision: $Id: InfCommand.lua 3419 2008-08-26 04:14:54Z ccox $
	URL: http://auctioneeraddon.com/dl/Informant/

	Command handler. Assumes responsibility for allowing the user to set the
	options via slash command, MyAddon etc.

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
		InformantConfig = {

			["profile.test4"] = {
				["all"] = true,
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
	def = Informant.Settings.GetDefault('TooltipShowValues')
	val = Informant.Settings.GetSetting('TooltipShowValues')
	Informant.Settings.SetSetting('TooltipShowValues', true );


]]
Informant_RegisterRevision("$URL: http://dev.norganna.org/auctioneer/trunk/Informant/InfSettings.lua $", "$Rev: 3419 $")

local lib = {}
Informant.Settings = lib
local private = {}
local gui
local debugPrint

local function getUserSig()
	local userSig = string.format("users.%s.%s", GetRealmName(), UnitName("player"))
	return userSig
end

local function getUserProfileName()
	if (not InformantConfig) then InformantConfig = {} end
	local userSig = getUserSig()
	return InformantConfig[userSig] or "Default"
end

local function getUserProfile()
	if (not InformantConfig) then InformantConfig = {} end
	local profileName = getUserProfileName()
	if (not InformantConfig["profile."..profileName]) then
		if profileName ~= "Default" then
			profileName = "Default"
			InformantConfig[getUserSig()] = "Default"
		end
		if profileName == "Default" then
			InformantConfig["profile."..profileName] = {}
		end
	end
	return InformantConfig["profile."..profileName]
end


local function cleanse( profile )
	if (profile) then
		profile = {}
	end
end


-- reset all settings for the current user
function lib.RestoreDefaults()
	local profile = getUserProfile()
	cleanse(profile)
end


-- Default setting values
-- moved from InfMain.lua filterDefaults
local settingDefaults = {
	['all'] = true,
	['locale'] = 'default',
	['embed'] = false,
	['show-name'] = true,
	['show-vendor'] = true,
	['show-vendor-buy'] = true,
	['show-vendor-sell'] = true,
	['show-usage'] = true,
	['show-stack'] = true,
	['show-merchant'] = true,
	['show-zero-merchants'] = true,
	['show-quest'] = true,
	['show-icon'] = true,
	['show-ilevel'] = true,
	['show-link'] = false,
}

local function getDefault(setting)

	-- lookup the simple settings
	local result = settingDefaults[setting];

	-- no idea what this setting is, so log it for debugging purposes
	if (result == nil) then
		debugPrint("GetDefault", ENX_INFO, "Unknown key", "default requested for unknown key:" .. setting)
	end

	return result

end

function lib.GetDefault(setting)
	local val = getDefault(setting);
	return val;
end

local function setter(setting, value)
	if (not InformantConfig) then InformantConfig = {} end

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
			InformantConfig["profile."..value] = {}

			-- Set the current profile to the new profile
			InformantConfig[getUserSig()] = value
			-- Get the new current profile
			local newProfile = getUserProfile()

			-- Clean it out and then resave all data
			cleanse(newProfile)
			gui:Resave()

			-- Add the new profile to the profiles list
			local profiles = InformantConfig["profiles"]
			if (not profiles) then
				profiles = { "Default" }
				InformantConfig["profiles"] = profiles
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

			DEFAULT_CHAT_FRAME:AddMessage(_INFM("ChatSavedProfile")..value)

		elseif (setting == "profile.delete") then
			-- User clicked the Delete button, see what the select box's value is.
			value = gui.elements["profile"].value

			-- If there's a profile name supplied
			if (value) then
				-- Clean it's profile container of values
				cleanse(InformantConfig["profile."..value])

				-- Delete it's profile container
				InformantConfig["profile."..value] = nil

				-- Find it's entry in the profiles list
				local profiles = InformantConfig["profiles"]
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
					InformantConfig[getUserSig()] = 'Default'
				end

				DEFAULT_CHAT_FRAME:AddMessage(_INFM("ChatDeletedProfile")..value)

			end

		elseif (setting == "profile.default") then
			-- User clicked the reset settings button

			-- Get the current profile from the select box
			value = gui.elements["profile"].value

			-- Clean it's profile container of values
			InformantConfig["profile."..value] = {}

			DEFAULT_CHAT_FRAME:AddMessage(_INFM("ChatResetProfile")..value)

		elseif (setting == "profile") then
			-- User selected a different value in the select box, get it
			value = gui.elements["profile"].value

			-- Change the user's current profile to this new one
			InformantConfig[getUserSig()] = value

			DEFAULT_CHAT_FRAME:AddMessage(_INFM("ChatUsingProfile")..value)

		end

		-- Refresh all values to reflect current data
		gui:Refresh()

	else
		-- Set the value for this setting in the current profile
		local db = getUserProfile()
		db[setting] = value
	end

	if (a == "sideIcon") and Informant.SideIcon then
-- not implemented yet
--		Informant.SideIcon.Update()
	end

end

function lib.SetSetting(...)
	setter(...)
	if (gui) then
		gui:Refresh()
	end
end


local function getter(setting)
	if (not InformantConfig) then InformantConfig = {} end
	if not setting then return end

	local a,b,c = strsplit(".", setting)
	if (a == 'profile') then
		if (b == 'profiles') then
			local pList = InformantConfig["profiles"]
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

function lib.UpdateGuiConfig()
	if gui then
		if gui:IsVisible() then
			gui:Hide()
		end
		gui = nil
		lib.MakeGuiConfig()
	end
end

function lib.MakeGuiConfig()
	if gui then return end

	local id, last, cont
	local Configator = LibStub:GetLibrary("Configator")
	gui = Configator:Create(setter, getter)
	lib.Gui = gui

  	gui:AddCat("Informant")

	id = gui:AddTab(_INFM("GuiTabGeneral"))
	gui:AddControl(id, "Header",     0,    _INFM("GuiGeneralOptions"))
	gui:AddControl(id, "Checkbox",   0, 1, "all", _INFM('HelpOnoff') )					-- _INFM('GuiMainEnable')
	gui:AddControl(id, "Checkbox",   0, 1, "embed", _INFM('HelpEmbed') )				-- _INFM('GuiEmbed')
	gui:AddControl(id, "Checkbox",   0, 1, "show-name", _INFM('HelpName'))				-- _INFM('GuiInfoName')
	gui:AddControl(id, "Checkbox",   0, 1, "show-vendor", _INFM('HelpVendor'))			-- _INFM('GuiVendor')
	gui:AddControl(id, "Checkbox",   0, 1, "show-vendor-buy", _INFM('HelpVendorBuy'))	-- _INFM('GuiVendorBuy')
	gui:AddControl(id, "Checkbox",   0, 1, "show-vendor-sell", _INFM('HelpVendorSell'))	-- _INFM('GuiVendorSell')
	gui:AddControl(id, "Checkbox",   0, 1, "show-usage", _INFM('HelpUsage'))			-- _INFM('GuiInfoUsage')
	gui:AddControl(id, "Checkbox",   0, 1, "show-stack", _INFM('HelpStack'))			-- _INFM('GuiInfoStack')
	gui:AddControl(id, "Checkbox",   0, 1, "show-merchant", _INFM('HelpMerchant'))		-- _INFM('GuiInfoMerchant')
	gui:AddControl(id, "Checkbox",   0, 1, "show-zero-merchants", _INFM('HelpZeroMerchants'))	-- _INFM('GuiInfoMerchant')
	gui:AddControl(id, "Checkbox",   0, 1, "show-quest", _INFM('HelpQuest'))			-- _INFM('GuiInfoQuest')
	gui:AddControl(id, "Checkbox",   0, 1, "show-icon", _INFM('HelpIcon'))				-- _INFM('GuiInfoIcon')
	gui:AddControl(id, "Checkbox",   0, 1, "show-ilevel", _INFM('HelpILevel'))			-- _INFM('GuiInfoILevel')
	gui:AddControl(id, "Checkbox",   0, 1, "show-link", _INFM('HelpLink'))				-- _INFM('GuiInfoLink')


	id = gui:AddTab(_INFM("GuiTabProfiles"))
	gui:AddControl(id, "Header",     0,    _INFM("GuiConfigProfiles"))

	gui:AddControl(id, "Subhead",    0,    _INFM("GuiActivateProfile"))
	gui:AddControl(id, "Selectbox",  0, 1, "profile.profiles", "profile", "this string isn't shown")
	gui:AddControl(id, "Button",     0, 1, "profile.delete", _INFM("GuiDeleteProfileButton"))
	gui:AddControl(id, "Button",     0, 1, "profile.default", _INFM("GuiResetProfileButton"))

	gui:AddControl(id, "Subhead",    0,    _INFM("GuiCreateReplaceProfile"))
	gui:AddControl(id, "Text",       0, 1, "profile.name", _INFM("GuiNewProfileName"))
	gui:AddControl(id, "Button",     0, 1, "profile.save", _INFM("GuiSaveProfileButton"))

end





-------------------------------------------------------------------------------
-- Prints the specified message to nLog.
--
-- syntax:
--    errorCode, message = debugPrint([message][, title][, errorCode][, level])
--
-- parameters:
--    message   - (string) the error message
--                nil, no error message specified
--    title     - (string) the title for the debug message
--                nil, no title specified
--    errorCode - (number) the error code
--                nil, no error code specified
--    level     - (string) nLog message level
--                         Any nLog.levels string is valid.
--                nil, no level specified
--
-- returns:
--    errorCode - (number) errorCode, if one is specified
--                nil, otherwise
--    message   - (string) message, if one is specified
--                nil, otherwise
-------------------------------------------------------------------------------
function debugPrint(message, title, errorCode, level)
	return Informant.DebugPrint(message, "InfSettings", title, errorCode, level)
end

