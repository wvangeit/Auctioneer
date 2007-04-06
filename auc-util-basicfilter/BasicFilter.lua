--[[
	Auctioneer Advanced - BasicFilter
	Revision: $Id$
	Version: <%version%>

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

local libName = "BasicFilter"
local libType = "Util"


AucAdvanced.Modules[libType][libName] = {}
local lib = AucAdvanced.Modules[libType][libName]
local private = {}

private.print = AucAdvanced.Print

local data

function lib.GetName()
	return libName
end

function lib.CommandHandler(command, parm1, ...)
	if (not data) then private.makeData() end
	local myFaction = AucAdvanced.GetFaction()

	if (not command or command == "" or command == "help") then
		local line = AucAdvanced.Config.GetCommandLead(libType, libName)

		private.print("Help for Auctioneer Advanced - "..libName)
		private.print(line, "help}} - this", libName, "help")
		private.print(line, "clear}} - clear out all filters")
		private.print(line, "minquality QUALITY}} - sets minimum quality allowed to QUALITY ["..tostring(data.MinQuality or 0).."]")
		private.print(line, "minlevel LEVEL}} - sets minimum item level allowed to LEVEL ["..tostring(data.MinLevel or 0).."]")
		private.print(line, "ignoreseller SELLER}} - adds seller to the ignored sellers list")
		private.print(line, "showignored}} - shows list of ignored sellers")

	elseif (command == "minquality") then
		private.print("setting minimum quality to ", parm1)
		data.MinQuality = tonumber(parm1)

	elseif (command == "minlevel") then
		private.print("setting minimum level to ", parm1)
		data.MinLevel = tonumber(parm1)

	elseif (command == "ignoreseller") then
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

	else
		private.print("{{Command not recognized}}")
		lib.CommandHandler("help")
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
	local minquality = tonumber(data.MinQuality) or 0
	local minlevel = tonumber(data.MinLevel) or 0
	local sellersignored = data.SellersIgnored or {}
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
	private.makeData()
end

--[[ Local functions ]]--
function private.DataLoaded()
	-- This function gets called when the data is first loaded. You may do any required maintenence
	-- here before the data gets used.
end

function private.makeData()
	if data then return end
	if (not AucAdvancedUtilBasicFilter) then AucAdvancedUtilBasicFilter = {MinQuality=1, MinLevel=0, SellersIgnored={}} end
	data = AucAdvancedUtilBasicFilter
	private.DataLoaded()
end
