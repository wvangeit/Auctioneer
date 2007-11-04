--[[
	Auctioneer Advanced - BasicFilter
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

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
]]

local libName = "Basic"
local libType = "Filter"


AucAdvanced.Modules[libType][libName] = {}
local lib = AucAdvanced.Modules[libType][libName]
local private = {}

private.print = AucAdvanced.Print

local data
local get = AucAdvanced.Settings.GetSetting

function lib.GetName()
	return libName
end

function lib.Processor(callbackType, ...)
	if callbackType == "config" then
		private.SetupConfigGui(...)
	end
end

function lib.AuctionFilter(operation, itemData)
	if (not data) then private.makeData() end
	local retval = false
	-- Get the signature of this item and find it's stats.
	--local itemType, itemId, property, factor = AucAdvanced.DecodeLink(itemData.link)
	local quality = EnhTooltip.QualityFromLink(itemData.link)
	local level = tonumber(itemData.itemLevel) or 0
	local seller = itemData.sellerName:lower()
	local minquality = tonumber(get("filter.basic.min.quality")) or 1
	local minlevel = tonumber(get("filter.basic.min.level")) or 0
	local sellersignored = get("filter.basic.sellersignored") or {}
	if (quality < minquality) then retval = true end
	if (level < minlevel) then retval = true end
	if (sellersignored[seller]) then retval = true end

	if nLog and retval then
		nLog.AddMessage("auc-"..libType.."-"..libName, "AuctionFilter", N_INFO, "Filtered Data", "Auction Filter Removed Data for ",
			itemData.itemName, " from ", (itemData.sellerName or "UNKNOWN"), ", quality ", tostring(quality or 0), ", item level ", tostring(itemData.itemLevel or 0))
	end
	return retval
end

function lib.OnLoad(addon)
	AucAdvanced.Settings.SetDefault("filter.basic.activated", true)
	AucAdvanced.Settings.SetDefault("filter.basic.min.quality", 1)
	AucAdvanced.Settings.SetDefault("filter.basic.min.level", 0)
	AucAdvanced.Settings.SetDefault("filter.basic.sellersignored", {})
	private.DataLoaded()
end

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	id = gui:AddTab(libName.." "..libType)

	gui:AddHelp(id, "what basic filter",
		"What is this Basic Filter?",
		"This filter allows you to specify certain minimums for an item to be entered into the data stream, such as the Minimum Item level, and the Minimum Quality (Junk, Common, Uncommon, Rare, etc)\n"..
		"It also allows you to specify that items from a certain seller not be recorded.  One use of this is if a particular seller posts all of his items well over or under the market price, you can ignore all of his/her items\n")

	gui:AddControl(id, "Header",	0,	libName.." "..libType.." options")
	
	gui:AddControl(id, "Checkbox",	0, 1, "filter.basic.activated", "Enable use of the Basic filter")
	gui:AddTip(id, "Ticking this box will enable the Basic filter to perform filtering your auction scans")
	
	gui:AddControl(id, "Subhead",	0, "Filter by Quality")
	gui:AddControl(id, "Slider",	0, 1, "filter.basic.min.quality", 0, 4, 1, "Minimum Quality: %d")
	gui:AddTip(id, "Use this slider to choose the minimum quality to go into the storage.\n"..
		"\n"..
		"0 = Junk (Grey),\n"..
		"1 = Common (White),\n"..
		"2 = Uncommon (Green),\n"..
		"3 = Rare (Blue),\n"..
		"4 = Epic (Purple)")
	
	gui:AddControl(id, "Subhead",	0, "Filter by Item Level")
	gui:AddControl(id, "NumberBox",	0, 1, "filter.basic.min.level", 0, 9, "Minimum item level")
	gui:AddTip(id, "Enter the minimum item level to go into the storage.")
	
end
		
--[[function lib.CommandHandler(command, parm1, ...)
	if (command == "ignoreseller") then
		private.print("adding", parm1, "to ignored sellers list")
		if (not data.SellersIgnored) then data.SellersIgnored = {} end
		data.SellersIgnored[parm1:lower()] = true

	elseif (command == "unignoreseller") then
		private.print("removing", parm1, "from ignored sellers list")
		if (not data.SellersIgnored) then data.SellersIgnored = {} end
		data.SellersIgnored[parm1:lower()] = nil

	elseif (command == "showignored") then
		private.print("{{Sellers Currently Ignored}}")
		for seller in pairs(data.SellersIgnored) do
			private.print("{{"..seller.."}}")
		end

	elseif (command == "clear") then
		for seller in pairs(data.SellersIgnored) do
			data.SellersIgnored[seller] = nil
		end
		data.MinQuality = 0
		data.MinLevel = 0
	end
end]]--

--[[ Local functions ]]--
function private.DataLoaded()
	-- This function gets called when the data is first loaded. You may do any required maintenence
	-- here before the data gets used.
end
