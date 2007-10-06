--[[
	Auctioneer Advanced - StatDebug
	Version: <%version%> (<%codename%>)
	Revision: $Id: StatSimple.lua 2193 2007-09-18 06:10:48Z mentalpower $
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
--]]

local libName = "Debug"
local libType = "Stat"

AucAdvanced.Modules[libType][libName] = {}
local lib = AucAdvanced.Modules[libType][libName]
local private = {}
local print = AucAdvanced.Print

local data

--[[
The following functions are part of the module's exposed methods:
	GetName()         (required) Should return this module's full name
	CommandHandler()  (optional) Slash command handler for this module
	Processor()       (optional) Processes messages sent by Auctioneer
	ScanProcessor()   (optional) Processes items from the scan manager
*	GetPrice()        (required) Returns estimated price for item link
*	GetPriceColumns() (optional) Returns the column names for GetPrice
	OnLoad()          (optional) Receives load message for all modules

	(*) Only implemented in stats modules; util modules do not provide
]]

function lib.GetName()
	return libName
end

function lib.CommandHandler(command, ...)
	local myFaction = AucAdvanced.GetFaction()
	if (command == "help") then
		print("Help for Auctioneer Advanced - "..libName)
		local line = AucAdvanced.Config.GetCommandLead(libType, libName)
		print(line, "help}} - this", libName, "help")
		print(line, "clear}} - clear current", myFaction, libName, "price database")
		print(line, "push}} - force the", myFaction, libName, "daily stats to archive (start a new day)")
	elseif (command == "clear") then
		print("Clearing Simple stats for {{", myFaction, "}}")
		private.ClearData()
	elseif (command == "push") then
		print("Archiving {{", myFaction, "}} daily stats and starting a new day")
		private.PushStats(myFaction)
	end
end

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		private.ProcessTooltip(...)
	elseif (callbackType == "load") then
		lib.OnLoad(...)
	end
end


lib.ScanProcessors = {}
function lib.ScanProcessors.create(operation, itemData, oldData)
	-- This function is responsible for processing and storing the stats after each scan
	-- Note: itemData gets reused over and over again, so do not make changes to it, or use
	-- it in places where you rely on it. Make a deep copy of it if you need it after this
	-- function returns.

	-- We're only interested in items with buyouts.
	local buyout = itemData.buyoutPrice
	if not buyout or buyout == 0 then return end
	local count = itemData.stackSize or 1
	if count < 1 then count = 1 end

	-- In this case, we're only interested in the initial create, other
	-- Get the signature of this item and find it's stats.
	local itemType, itemId, property, factor = AucAdvanced.DecodeLink(itemData.link)
	local id = strjoin(":", itemId, property, factor)

	local data = private.GetPriceData()
	if not data[id] then data[id] = {} end

	while (#data[id] >= 10) do table.remove(data[id], 1) end
	table.insert(data[id], buyout/count)
end

function lib.GetPrice(hyperlink)
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end

	local id = strjoin(":", itemId, property, factor)
	local data = private.GetPriceData()
	if not data then return end
	return unpack(data[id])
end

local array = {}
function lib.GetPriceArray(hyperlink)
	-- Clean out the old array
	while (#array > 0) do table.remove(array) end

	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end

	local id = strjoin(":", itemId, property, factor)
	local data = private.GetPriceData()
	if not data then return end
	if not data[id] then return end

	array.seen = #data[id]
	array.price = data[id][array.seen]
	array.pricelist = data[id]

	-- Return a temporary array. Data in this array is
	-- only valid until this function is called again.
	return array
end

function lib.OnLoad(addon)

end

function lib.CanSupplyMarket()
	return false
end


--[[ Local functions ]]--

function private.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine whether or what you should
	-- display in the tooltip.
	if not quantity or quantity < 1 then quantity = 1 end
	local array = lib.GetPriceArray(hyperlink)
	if not array then
		EnhTooltip.AddLine("  Debug: No price data")
		EnhTooltip.LineColor(0.3, 0.9, 0.8)
		return
	end

	for i = 1, #array.pricelist do
		EnhTooltip.AddLine("  Debug "..i..":", array.pricelist[i])
		EnhTooltip.LineColor(0.3, 0.9, 0.8)
	end
end

local StatData

function private.LoadData()
	if (StatData) then return end
	if (not AucAdvancedStatDebugData) then AucAdvancedStatDebugData = {Version='1.0', Data = {}} end
	StatData = AucAdvancedStatDebugData
	private.DataLoaded()
end

function private.ClearData(faction, realmName)
	if (not StatData) then private.LoadData() end
	print("Clearing "..libName.." stats")
	StatData.Data =  {}
end

function private.GetPriceData()
	if (not StatData) then private.LoadData() end
	return StatData.Data
end

function private.DataLoaded()
	if (not StatData) then return end
end
