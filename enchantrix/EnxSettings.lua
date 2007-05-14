--[[
	Enchantrix Addon for World of Warcraft(tm).
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
		EnchantConfig = {
		
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
			
			["users.Balnazzar.Picksell"] = "test4",
			
			["profile.Default"] = {
				["miniicon.angle"] = 187,
				["miniicon.distance"] = 15,
			},
			
		}

if user does not have a set profile name, they get the default profile


Usage:
	def = Enchantrix.Settings.GetDefault('ToolTipShowCounts')
	val = Enchantrix.Settings.GetSetting('ToolTipShowCounts')
	Enchantrix.Settings.SetSetting('ToolTipShowCounts', true );

]]

Enchantrix_RegisterRevision("$URL$", "$Rev$")

local lib = {}
Enchantrix.Settings = lib
local gui

local function getUserSig()
	local userSig = string.format("users.%s.%s", GetRealmName(), UnitName("player"))
	return userSig
end

local function getUserProfileName()
	if (not EnchantConfig) then EnchantConfig = {} end
	local userSig = getUserSig()
	return EnchantConfig[userSig] or "Default"
end

local function getUserProfile()
	if (not EnchantConfig) then EnchantConfig = {} end
	local profileName = getUserProfileName()
	if (not EnchantConfig["profile."..profileName]) then
		if profileName ~= "Default" then
			profileName = "Default"
			EnchantConfig[getUserSig()] = "Default"
		end
		if profileName == "Default" then
			EnchantConfig["profile."..profileName] = {}
		end
	end
	return EnchantConfig["profile."..profileName]
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
	['printframe'] = 1,
	
	['ToolTipShowCounts'] = false,
	['ToolTipEmbedInGameTip'] = false,
	['ToolTipTerseFormat'] = false,
	['TooltipShowValues'] = true,
	['TooltipShowAuctValueHSP'] = true,
	['TooltipShowAuctValueMedian'] = true,
	['TooltipShowBaselineValue'] = true,
	['TooltipShowAuctAdvValue'] = true,
	['TooltipShowDisenchantLevel'] = true,	-- should the item tooltip show the enchanting level needed to disenchant
	['TooltipShowDisenchantMats'] = true,	-- should the item tooltip show what it disenchants into? (for those who are just greedy)
	
	['profile.name'] = '',		-- not sure why this gets hit so often, might be a bug
	
	['maxBuyoutPrice'] = 800000,
	['defaultProfitMargin'] = 1000,		 -- default profit margin = 10s
	['minProfitMargin'] = 100,			 -- min allowed profit margin = 1s (100c)
	['defaultPercentLessThanHSP'] = 20,	 -- default for percentless scan = 20% under HSP
	['minPercentLessThanHSP'] = 5,		 -- min for percentless scan = 5% under HSP
	['defaultProfitPricePercent'] = 10,	 --default for bidbroker scan = 10% under HSP
	['minProfitPricePercent'] = 5,		 --minimum percent under for bidbroker scan = 5% under HSP
	['ScanValueType'] = "average",		-- what value to use for auction scans
	['RestrictToLevel'] = true,			-- should scans only show items that the user can disenchant at their current skill level
}

local ScanValueNames = {
	"average",
	"HSP",
	"median",
	"baseline"
}

local function getDefault(setting)
	local a,b,c = strsplit(".", setting)
	
	-- basic settings
	if (a == "show") then return true end
	if (b == "enable") then return true end
	
	-- reagent prices
	if (a == "value") then
		return Enchantrix.Constants.StaticPrices[tonumber(b) or 0]
	end

	-- miniicon settings
	if (setting == "miniicon.angle")          then return 118     end
	if (setting == "miniicon.distance")       then return 12      end
	
	-- lookup the simple settings
	local result = settingDefaults[setting];
	
	-- no idea what this setting is, so log it for debugging purposes
	if (result == nil) then
		Enchantrix.Util.DebugPrint("GetDefault", ENX_INFO, "Unknown key", "default requested for unknown key:" .. setting)
	end
	
	return result
	
end

function lib.GetDefault(setting)
	local val = getDefault(setting);
	return val;
end

local function setter(setting, value)
	if (not EnchantConfig) then EnchantConfig = {} end
	
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
			EnchantConfig["profile."..value] = {}

			-- Set the current profile to the new profile
			EnchantConfig[getUserSig()] = value
			-- Get the new current profile
			local newProfile = getUserProfile()
			
			-- Clean it out and then resave all data
			cleanse(newProfile)
			gui.Resave()

			-- Add the new profile to the profiles list
			local profiles = EnchantConfig["profiles"]
			if (not profiles) then
				profiles = { "Default" }
				EnchantConfig["profiles"] = profiles
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
			
-- TODO - localize string
			DEFAULT_CHAT_FRAME:AddMessage("Saved profile: "..value)
			
		elseif (setting == "profile.delete") then
			-- User clicked the Delete button, see what the select box's value is.
			value = gui.elements["profile"].value

			-- If there's a profile name supplied
			if (value) then
				-- Clean it's profile container of values
				cleanse(EnchantConfig["profile."..value])
				
				-- Delete it's profile container
				EnchantConfig["profile."..value] = nil
				
				-- Find it's entry in the profiles list
				local profiles = EnchantConfig["profiles"]
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
					EnchantConfig[getUserSig()] = 'Default'
				end
				
-- TODO - localize string
				DEFAULT_CHAT_FRAME:AddMessage("Deleted profile: "..value)
				
			end
			
		elseif (setting == "profile.default") then
			-- User clicked the reset settings button
			
			-- Get the current profile from the select box
			value = gui.elements["profile"].value

			-- Clean it's profile container of values
			EnchantConfig["profile."..value] = {}
			
-- TODO - localize string
			DEFAULT_CHAT_FRAME:AddMessage("Reset all settings for:"..value)
		
		elseif (setting == "profile") then
			-- User selected a different value in the select box, get it
			value = gui.elements["profile"].value

			-- Change the user's current profile to this new one
			EnchantConfig[getUserSig()] = value
			
-- TODO - localize string
			DEFAULT_CHAT_FRAME:AddMessage("Changing profile: "..value)
			
		end

		-- Refresh all values to reflect current data
		gui.Refresh()
	else
		-- Set the value for this setting in the current profile
		local db = getUserProfile()
		db[setting] = value
		--setUpdated()
	end

	if (a == "miniicon") then
		Enchantrix.MiniIcon.Reposition()
	end
		
end

function lib.SetSetting(...)
	setter(...)
	if (gui) then
		gui.Refresh()
	end
end
	

local function getter(setting)
	if (not EnchantConfig) then EnchantConfig = {} end
	if not setting then return end

	local a,b,c = strsplit(".", setting)
	if (a == 'profile') then
		if (b == 'profiles') then
			local pList = EnchantConfig["profiles"]
			if (not pList) then
				pList = { "Default" }
			end
			return pList
		end
	end

	if (a == 'scanvalue') then
		if (b == 'list') then
			local stList = ScanValueNames;
			if (not stList) then
				stList = { "average" }
			end
			return stList
		end
	end
	
	if (setting == 'profile') then
		return getUserProfileName()
	end
	if (setting == 'track.styles') then
		return {
			"Black",
			"Blue",
			"Cyan",
			"Green",
			"Magenta",
			"Red",
			"Test",
			"White",
			"Yellow",
		}
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


function lib.MakeGuiConfig()
	if gui then return end

	local id, last, cont
	gui = Configator.NewConfigator(setter, getter)
	lib.Gui = gui

  	gui.AddCat("Enchantrix")
  	
	id = gui.AddTab("Profiles")
	gui.AddControl(id, "Header",     0,    "Setup, configure and edit profiles")
	
	gui.AddControl(id, "Subhead",    0,    "Activate a current profile")
	gui.AddControl(id, "Selectbox",  0, 1, "profile.profiles", "profile", "Switch to given profile")
	gui.AddControl(id, "Button",     0, 1, "profile.delete", "Delete")
	gui.AddControl(id, "Button",     0, 1, "profile.default", "Reset")
	
	gui.AddControl(id, "Subhead",    0,    "Create or replace a profile")
	gui.AddControl(id, "Text",       0, 1, "profile.name", "New profile name:")
	gui.AddControl(id, "Button",     0, 1, "profile.save", "Save")


	id = gui.AddTab("General")
	gui.AddControl(id, "Header",     0,    "General Enchantrix options")
	gui.AddControl(id, "Checkbox",   0, 1, "TooltipShowDisenchantLevel", "Show the enchanting skill needed to disenchant an item in the tooltip")
	gui.AddControl(id, "Checkbox",   0, 1, "ToolTipShowCounts", "Show the exact disenchant counts from the database")
	gui.AddControl(id, "Checkbox",   0, 1, "ToolTipEmbedInGameTip", "Embed the text in the original game tooltip (note: certain features are disabled when this is selected)")
	gui.AddControl(id, "Checkbox",   0, 1, "TooltipShowDisenchantMats", "Show materials that the item may disenchant into")
-- TODO: locale -- what are the allowed values?
-- TODO: printframe  -- what are the allowed values?  Configurator really needs a restricted value number box (without a slider)
	
	gui.AddControl(id, "Subhead",    0,    "Valuations")
	gui.AddControl(id, "Checkbox",   0, 1, "TooltipShowValues", "Show disenchant values")
	gui.AddControl(id, "Checkbox",   0, 2, "ToolTipTerseFormat", "Show ToolTipTerseFormat disenchant value")
	if (Enchantrix.State.Auctioneer_Loaded) then
		gui.AddControl(id, "Checkbox",       0, 2, "TooltipShowAuctValueHSP", "Show Auctioneer HighestSellablePrice values")
		gui.AddControl(id, "Checkbox",       0, 2, "TooltipShowAuctValueMedian", "Show Auctioneer median values")
		if (AucAdvanced) then
			gui.AddControl(id, "Checkbox",       0, 2, "TooltipShowAuctAdvValue", "Show Auctioneer 5 value")
		end
	end
	gui.AddControl(id, "Checkbox",   0, 2, "TooltipShowBaselineValue", "Show built-in baseline values")

	gui.AddControl(id, "Subhead",    0,    "Minimap display options")
	gui.AddControl(id, "Checkbox",   0, 1, "miniicon.enable", "Display Minimap button")
	gui.AddControl(id, "Slider",     0, 2, "miniicon.angle", 0, 360, 1, "Button angle: %d")
	gui.AddControl(id, "Slider",     0, 2, "miniicon.distance", -80, 80, 1, "Distance: %d")
	
	
	id = gui.AddTab("Auction Scans")
	gui.AddControl(id, "Header",     0,    "Percentless and Bidbroker settings")
	gui.AddControl(id, "MoneyFramePinned", 0, 1, "maxBuyoutPrice", 1, 99999999, "Maximum Buyout price:")
	gui.AddControl(id, "MoneyFramePinned", 0, 1, "defaultProfitMargin", 1, nil, "Default Profit Margin:")
	gui.AddControl(id, "MoneyFramePinned", 0, 1, "minProfitMargin", 1, nil, "Minimum Profit Margin:")
	gui.AddControl(id, "Slider",     0, 1, "defaultPercentLessThanHSP", 5, 90, 1, "Default Percentage less than HSP: %d")
	gui.AddControl(id, "Slider",     0, 1, "minPercentLessThanHSP", 1, 10, 1, "Minimum Percentage less than HSP: %d")
	gui.AddControl(id, "Slider",     0, 1, "defaultProfitPricePercent", 5, 90, 1, "Default bidbroker profit Percentage: %d")
	gui.AddControl(id, "Slider",     0, 1, "minProfitPricePercent", 1, 10, 1, "Minimum bidbroker profit Percentage: %d")
	gui.AddControl(id, "Checkbox",   0, 1, "RestrictToLevel", "Only show items disenchantable at current skill")
	gui.AddControl(id, "Subhead",    0,    "Item value calculated from")
	gui.AddControl(id, "Selectbox",  0, 1, "scanvalue.list", "ScanValueType", "this string isn't shown")

end
