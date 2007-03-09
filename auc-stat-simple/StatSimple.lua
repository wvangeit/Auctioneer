--[[
	Auctioneer - StatSimple
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
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]

local libName = "Simple"

Auctioneer.Modules.Stat[libName] = {}
local lib = Auctioneer.Modules.Stat[libName]
lib.Print = Auctioneer.Print

local data
function makeData()
	if data then return end
	if (not AuctioneerStatSimpleData) then AuctioneerStatSimpleData = {} end
	data = AuctioneerStatSimpleData
	lib.DataLoaded()
end

function lib.GetName()
	return libName
end

function lib.CommandHandler(command, ...)
	if (not data) then makeData() end
	local myFaction = Auctioneer.GetFaction()
	if (command == "help") then
		lib.Print("Help for Auctioneer "..libName)
		local line = "  {{/aul "..libName:lower()
		lib.Print(line, "help}} - this", libName, "help")
		lib.Print(line, "clear}} - clear current", myFaction, libName, "price database")
		lib.Print(line, "push}} - force the", myFaction, libName, "daily stats to archive (start a new day)")
	elseif (command == "clear") then
		lib.Print("Clearing all stats for {{", myFaction, "}}")
		data[myFaction] = nil
	elseif (command == "push") then
		lib.Print("Archiving {{", myFaction, "}} daily stats and starting a new day")
		lib.PushStats(myFaction)
	end
end

function lib.Processor(callbackType, ...)
	if (not data) then makeData() end
	if (callbackType == "scan") then
		lib.ScanProcessor(...)
	elseif (callbackType == "tooltip") then
		lib.TooltipProcessor(...)
	elseif (callbackType == "load") then
		lib.OnLoad(...)
	end
end


local function unpackStatIter(data, ...)
	local c = select("#", ...)
	local v
	for i = 1, c do
		v = select(i, ...)
		local property, info = strsplit(":", v)
		property = tonumber(property)
		if (property and info) then
			data[property] = { strsplit(";", info) }
			local item
			for i=1, #data[property] do
				item = data[property][i]
				data[property][i] = tonumber(item) or item
			end
		end
	end
end
function lib.UnpackStats(dataItem)
	local data = {}
	unpackStatIter(data, strsplit(",", dataItem))
	return data
end
function lib.PackStats(data)
	local stats = ""
	local joiner = ""
	for property, info in pairs(data) do
		stats = stats..joiner..property..":"..strjoin(";", unpack(info))
		joiner = ","
	end
	return stats
end

function lib.ScanProcessor(operation, itemData, oldData)
	-- This function is responsible for processing and storing the stats after each scan
	-- Note: itemData gets reused over and over again, so do not make changes to it, or use
	-- it in places where you rely on it. Make a deep copy of it if you need it after this
	-- function returns.

	-- We're only interested in items with buyouts.
	local buyout = itemData.buyoutPrice
	if not buyout or buyout == 0 then return end
	buyout = buyout / itemData.stackSize

	-- In this case, we're only interested in the initial create, other
	-- stats modules may wish to do more fancy stuff on the other operations
	-- however for this simple case, it doesn't make sense.
	if (operation == "create") then
		-- Get the signature of this item and find it's stats.
		local itemType, itemId, property, factor = Auctioneer.DecodeLink(itemData.link)
		if (factor ~= 0) then property = property.."x"..factor end
		local faction = Auctioneer.GetFaction()
		if not data[faction] then data[faction] = {} end
		if not data[faction].daily then data[faction].daily = { created = time() } end
		if not data[faction].daily[itemId] then data[faction].daily[itemId] = "" end
		local stats = lib.UnpackStats(data[faction].daily[itemId])
		if not stats[property] then stats[property] = { 0, 0 } end
		stats[property][1] = stats[property][1] + buyout
		stats[property][2] = stats[property][2] + 1
		data[faction].daily[itemId] = lib.PackStats(stats)
	elseif (operation == "delete") then
	elseif (operation == "update") then
	elseif (operation == "leave") then
	end
end

function lib.GetPrice(hyperlink, faction)
	local linkType,itemId,property,factor = Auctioneer.DecodeLink(hyperlink)
	if (factor ~= 0) then property = property.."x"..factor end
	if (linkType ~= "item") then return end

	if not faction then faction = Auctioneer.GetFaction() end

	local dayTotal, dayCount, dayAverage = 0,0,0
	local seenDays, seenCount, avg3, avg7, avg14 = 0,0,0,0,0

	local faction = Auctioneer.GetFaction()
	if not data[faction] then return end

	if data[faction].daily and data[faction].daily[itemId] then
		local stats = lib.UnpackStats(data[faction].daily[itemId])
		if stats[property] then
			dayTotal, dayCount = unpack(stats[property])
			dayAverage = dayTotal/dayCount
		end
	end
	if data[faction].means and data[faction].means[itemId] then
		local stats = lib.UnpackStats(data[faction].means[itemId])
		if stats[property] then
			seenDays, seenCount, avg3, avg7, avg14 = unpack(stats[property])
		end
	end
	return dayAverage, avg3, avg7, avg14, false, dayTotal, dayCount, seenDays, seenCount
end

function lib.GetPriceColumns()
	return "Daily Avg", "3 Day Avg", "7 Day Avg", "14 Day Avg", false, "Daily Total", "Daily Count", "Seen Days", "Seen Count"
end

function lib.TooltipProcessor(frame, name, hyperlink, quality, quantity, cost)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine whether or what you should
	-- display in the tooltip.
	if not quantity or quantity < 1 then quantity = 1 end
	local dayAverage, avg3, avg7, avg14, _, dayTotal, dayCount, seenDays, seenCount = lib.GetPrice(hyperlink)

	if (seenDays + dayCount > 0) then
		EnhTooltip.AddLine(libName.." prices:")
		EnhTooltip.LineColor(0.3, 0.9, 0.8)
	
		if (seenDays > 0) then
			if (dayCount>0) then seenDays = seenDays + 1 end
			EnhTooltip.AddLine("  Seen |cffddeeff"..(seenCount+dayCount).."|r over |cffddeeff"..seenDays.."|r days:")
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
		if (seenDays > 6) then
			EnhTooltip.AddLine("  14 day average", avg14*quantity)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
		if (seenDays > 2) then
			EnhTooltip.AddLine("  7 day average", avg7*quantity)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
		if (seenDays > 0) then
			EnhTooltip.AddLine("  3 day average", avg3*quantity)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
		if (dayCount > 0) then
			EnhTooltip.AddLine("  Seen |cffddeeff"..dayCount.."|r today", dayAverage*quantity)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
	end
end

function lib.DataLoaded()
	-- This function gets called when the data is first loaded. You may do any required maintenence
	-- here before the data gets used.
	
	for faction, stats in pairs(data) do
		if not stats.daily then stats.daily = { created = time() } end
		if not stats.means then stats.means = {} end
		if stats.daily.created and time() - stats.daily.created > 3600*16 then
			-- This data is more than 16 hours old, we classify this as "yesterday's data"
			lib.PushStats(faction)
		end
	end
end

-- This is a function which migrates the data from a daily average to the
-- Exponential Moving Averages over the 3, 7 and 14 day ranges.
function lib.PushStats(faction)
	local dailyAvg
	if not data[faction] then return end
	if not data[faction].daily then return end
	if not data[faction].means then data[faction].means = {} end

	local pdata
	for itemId, stats in pairs(data[faction].daily) do
		if (itemId ~= "created") then
			pdata = lib.UnpackStats(stats)
			fdata = lib.UnpackStats(data[faction].means[itemId] or "")
			for property, info in pairs(pdata) do
				dailyAvg = info[1] / info[2]
				if not fdata[property] then
					fdata[property] = {
						1,
						info[2],
						("%0.01f"):format(dailyAvg), 
						("%0.01f"):format(dailyAvg),
						("%0.01f"):format(dailyAvg),
					}
				else
					fdata[property][1] = fdata[property][1] + 1
					fdata[property][2] = fdata[property][2] + info[2]
					fdata[property][3] = ("%0.01f"):format(((fdata[property][3] * 2) + dailyAvg)/3)
					fdata[property][4] = ("%0.01f"):format(((fdata[property][4] * 6) + dailyAvg)/7)
					fdata[property][5] = ("%0.01f"):format(((fdata[property][5] * 13) + dailyAvg)/14)
				end
			end
			data[faction].means[itemId] = lib.PackStats(fdata)
		end
	end
	data[faction].daily = { created = time() }
end

function lib.OnLoad(addon)
	if (addon == "auc-stat-simple") then
		makeData()
	end
end
