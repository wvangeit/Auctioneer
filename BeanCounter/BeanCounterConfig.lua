--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/
	
	BeanCounterConfig - Controls Configuration data

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
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]
--Most of this code is from enchantrix 
local libName = "BeanCounter"
local libType = "Util"
local lib = BeanCounter
local private = lib.Private
local print =  BeanCounter.Print

local gui
local settings

local function debugPrint(...)
    if private.getOption("util.beancounter.debugConfig") then
        private.debugPrint("BeanCounterConfig",...)
    end
end

local function getUserSig()
	local userSig = string.format("users.%s.%s", GetRealmName(), UnitName("player"))
	return userSig
end

local function getUserProfileName()
	if (not settings) then settings = BeanCounterDB["settings"] end
	local userSig = getUserSig()
	return settings[userSig] or "Default"
end

local function getUserProfile()
	if (not settings) then settings = BeanCounterDB["settings"] end
	local profileName = getUserProfileName()
	if (not settings["profile."..profileName]) then
		if profileName ~= "Default" then
			profileName = "Default"
			settings[getUserSig()] = "Default"
		end
		if profileName == "Default" then
			settings["profile."..profileName] = {}
		end
	end
	return settings["profile."..profileName]
end


local function cleanse( profile )
	if (profile) then
		profile = {}
	end
end


-- Default setting values
private.settingDefaults = {
	["util.beancounter.activated"] = true,
	["util.beancounter.debug"] = false,
	["util.beancounter.debugMail"] = true,
	["util.beancounter.debugCore"] = true,
	["util.beancounter.debugConfig"] = true,
	["util.beancounter.debugVendor"] = true,
	["util.beancounter.debugBid"] = true,
	["util.beancounter.debugPost"] = true,
	["util.beancounter.debugUpdate"] = true,
	["util.beancounter.debugFrames"] = true,
	
	["util.beacounter.invoicetime"] = 5,
	["util.beancounter.mailrecolor"] = "both",
	["util.beancounter.externalSearch"] = true,
	
	["util.beancounter.hasUnreadMail"] = false,
	
	--["util.beancounter.dateFormat"] = "%c",
	["dateString"] = "%c", 
    }

local function getDefault(setting)
	local a,b,c = strsplit(".", setting)

	-- basic settings
	if (a == "show") then return true end
	if (b == "enable") then return true end
	
	-- lookup the simple settings
	local result = private.settingDefaults[setting];

	return result
end

function lib.GetDefault(setting)
	local val = getDefault(setting);
	return val;
end
local tbl = {}
local function setter(setting, value)
	if (not settings) then settings = BeanCounterDB["settings"] end
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

	local a,b = strsplit(".", setting)
	if (a == "dateString") then --used to update the Config GUI when a user enters a new date string 
		if not value then value = "%c" end
		tbl = {}
		for w in string.gmatch(value, "%%(.)" ) do --look for the date commands prefaced by %  
			tinsert(tbl, w)
		end
		
		local valid, count = {'a','A','b','B','c','d','H','I','m','M','p','S','U','w','x','X','y', 'Y'} --valid date commands
		local count = #tbl
		for i,v in pairs(tbl) do
			for ii, vv in pairs(valid) do
				if v == vv then count = count - 1 break end
			end
		end
		if count > 0 then print("Invalid Date Format")  return end --Prevent processing if we have an inalid command
		
		local text = gui.elements.dateString:GetText()
		gui.elements.dateStringdisplay.textEl:SetText("|CCFFFCC00Example Date: "..date(text, 1196303661))
	end
	
	if (a == "profile") then
		if (setting == "profile.save") then
			value = gui.elements["profile.name"]:GetText()

			-- Create the new profile
			settings["profile."..value] = {}

			-- Set the current profile to the new profile
			settings[getUserSig()] = value
			-- Get the new current profile
			local newProfile = getUserProfile()

			-- Clean it out and then resave all data
			cleanse(newProfile)
			gui:Resave()

			-- Add the new profile to the profiles list
			local profiles = settings["profiles"]
			if (not profiles) then
				profiles = { "Default" }
				settings["profiles"] = profiles
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

			print("ChatSavedProfile",value)

		elseif (setting == "profile.delete") then
			-- User clicked the Delete button, see what the select box's value is.
			value = gui.elements["profile"].value

			-- If there's a profile name supplied
			if (value) then
				-- Clean it's profile container of values
				cleanse(settings["profile."..value])

				-- Delete it's profile container
				settings["profile."..value] = nil

				-- Find it's entry in the profiles list
				local profiles = settings["profiles"]
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
					settings[getUserSig()] = 'Default'
				end

				print("ChatDeletedProfile",value)

			end

		elseif (setting == "profile.default") then
			-- User clicked the reset settings button

			-- Get the current profile from the select box
			value = gui.elements["profile"].value

			-- Clean it's profile container of values
			settings["profile."..value] = {}

			print("ChatResetProfile",value)

		elseif (setting == "profile") then
			-- User selected a different value in the select box, get it
			value = gui.elements["profile"].value

			-- Change the user's current profile to this new one
			settings[getUserSig()] = value

			print("ChatUsingProfile",value)

		end

		-- Refresh all values to reflect current data
		gui:Refresh()
	else
		-- Set the value for this setting in the current profile
		local db = getUserProfile()
		db[setting] = value
		--setUpdated()
	end

end

function lib.SetSetting(...)
	setter(...)
	if (gui) then
		gui:Refresh()
	end
end


local function getter(setting)
	if (not settings) then settings = BeanCounterDB["settings"] end
	if not setting then return end

	local a,b,c = strsplit(".", setting)
	if (a == 'profile') then
		if (b == 'profiles') then
			local pList = settings["profiles"]
			if (not pList) then
				pList = { "Default" }
			end
			return pList
		end
	end

	if (a == 'scanvalue') then
		if (b == 'list') then
			if not private.scanValueNames then private.scanValueNames = {} end

			for i = 1, #private.scanValueNames do
				private.scanValueNames[i] = nil
			end

			table.insert(private.scanValueNames,{"average", "GuiItemValueAverage"})
			table.insert(private.scanValueNames,{"baseline", "GuiItemValueBaseline"})
			if AucAdvanced then
				table.insert(private.scanValueNames,{"adv:market", "GuiItemValueAuc5Market" })
				local algoList = AucAdvanced.API.GetAlgorithms()
				for pos, name in ipairs(algoList) do
					table.insert(private.scanValueNames,{"aucadv:stat:"..name, "AucAdv Stat:"..name})
				end
			end
			if Auctioneer then
				table.insert(private.scanValueNames,{"auc4:hsp", "GuiItemValueAuc4HSP" })
				table.insert(private.scanValueNames,{"auc4:med", "GuiItemValueAuc4Median" })
			end

			return private.scanValueNames
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

private.setter = setter
private.getter = getter
function lib.MakeGuiConfig()

	
	if gui then return end
	
	local id
	local Configator = LibStub:GetLibrary("Configator")
	gui = Configator:Create(setter, getter)
		
	local baseGUI
	lib.Gui = gui

  	gui:AddCat("BeanCounter")
	
	id = gui:AddTab("BeanCounter Config")
	gui:MakeScrollable(id)
	gui:AddControl(id, "Header",     0,    "BeanCounter options")
	gui:AddControl(id, "WideSlider", 0, 1, "util.beacounter.invoicetime",    1, 10, 1, "Mail Invoice Timeout = %d seconds")
	gui:AddTip(id, "Chooses how long BeanCounter will attempt to get a mail invoice from the server before giving up. Lower == quicker but more chance of missing data, Higher == slower but improves chances of getting data if the Mail server is extremely busy")
	gui:AddControl(id, "Subhead",    0,    "Mail Re-Color Method")
	gui:AddControl(id, "Selectbox",  0, 1, {{"off","No Re-Color"},{"icon","Re-Color Icons"},{"both","Re-Color Icons and Text"},{"text","Re-Color Text"}}, "util.beancounter.mailrecolor", "Mail Re-Color Method")
	gui:AddTip(id, "Choose how Mail will appear after BeanCounter has scanned the Mail Box")
	gui:AddControl(id, "Checkbox",   0, 1, "util.beancounter.externalSearch", "Allow External Addons to use BeanCounter's Search?")
	gui:AddTip(id, "When entering a search in another addon, BeanCounter will also display a search for that item.")
	
	gui:AddControl(id, "Text",       0, 1, "dateString", "|CCFFFCC00Date format to use:")
	gui:AddTip(id, "Enter the format that you would like your date field to show. Default is %c")
	gui:AddControl(id, "Checkbox",   0, 1, "dateStringdisplay", "|CCFFFCC00Example Date: 11/28/07 21:34:21")
	gui:AddTip(id, "Displays an example of what your formated date will look like")
	
	gui:AddHelp(id, "what is invoice",
		"What is Mail Invoice Timeout?",
		"The length of time BeanCounter will wait on the server to respond to an invoice request. A invoice is the who, what, how of an Auction house mail"
		)
	gui:AddHelp(id, "what is recolor",
		"What is Mail Re-Color Method?",
		"BeanCounter reads all mail from the Auction House, This option tells Beancounter how the user want's to Recolor the messages to make them look unread."
		)
	gui:AddHelp(id, "what is external",
		"Allow External Addons to use BeanCounter?",
		"Other addons can have BeanCounter search for an item to be displayed in BeanCounter's GUI. For example this allows BeanCounter to show what items you are looking at in Appraiser"
		)
	gui:AddHelp(id, "what is date",
		"Date Format to use?",
		"This controls how the Date field of BeanCounter's GUI is shown. Commands are prefaced by % and multiple commands and text can be mixed. For example %a == %X would display Wed == 21:34:21"
		)
	gui:AddHelp(id, "what is date command",
			"Acceptable Date Commands?",
			"Commands: \n %a = abr. weekday name, \n %A = weekday name, \n %b = abr. month name, \n %B = month name,\n %c = date and time, \n %d = day of the month (01-31),\n %H = hour (24), \n %I = hour (12),\n %M = minute, \n %m = month,\n %p = am/pm, \n %S = second,\n %U = week number of the year ,\n %w = numerical weekday (0-6),\n %x = date, \n %X = time,\n %Y = full year (2007), \n %y = two-digit year (07)"
			)			
	
	id = gui:AddTab("BeanCounter Debug")
	gui:AddControl(id, "Header",     0,    "BeanCounter Debug")
	gui:AddControl(id, "Checkbox",   0, 1, "util.beancounter.debug", "Turn on BeanCounter Debugging.")
	gui:AddControl(id, "Subhead",    0,    "Reports From Specific Modules")

	gui:AddControl(id, "Checkbox",   0, 2, "util.beancounter.debugMail", "Mail")
	gui:AddControl(id, "Checkbox",   0, 2, "util.beancounter.debugCore", "Core")
	gui:AddControl(id, "Checkbox",   0, 2, "util.beancounter.debugConfig", "Config")
	gui:AddControl(id, "Checkbox",   0, 2, "util.beancounter.debugVendor", "Vendor")
	gui:AddControl(id, "Checkbox",   0, 2, "util.beancounter.debugBid", "Bid")
	gui:AddControl(id, "Checkbox",   0, 2, "util.beancounter.debugPost", "Post")
	gui:AddControl(id, "Checkbox",   0, 2, "util.beancounter.debugUpdate", "Update")
	gui:AddControl(id, "Checkbox",   0, 2, "util.beancounter.debugFrames", "Frames")

end
