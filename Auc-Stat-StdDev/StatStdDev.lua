--[[
	Auctioneer Advanced - Standard Deviation Statistics module
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
--]]

local libName = "StdDev"
local libType = "Stat"

AucAdvanced.Modules[libType][libName] = {}
local lib = AucAdvanced.Modules[libType][libName]
local private = {}
local print = AucAdvanced.Print
local acquire = AucAdvanced.Acquire
local recycle = AucAdvanced.Recycle

local data
local ZValues = {.063, .126, .189, .253, .319, .385, .454, .525, .598, .675, .756, .842, .935, 1.037, 1.151, 1.282, 1.441, 1.646, 1.962, 20, 20000}
	

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
	if (not data) then private.makeData() end
	local myFaction = AucAdvanced.GetFaction()
	if (command == "help") then
		print("Help for Auctioneer Advanced - "..libName)
		local line = AucAdvanced.Config.GetCommandLead(libType, libName)
		print(line, "help}} - this", libName, "help")
		print(line, "clear}} - clear current", myFaction, libName, "price database")
	elseif (command == "clear") then
		print("Clearing "..libName.." stats for {{", myFaction, "}}")
		recycle(data, myFaction)
	end
end

function lib.Processor(callbackType, ...)
	if (not data) then private.makeData() end
	if (callbackType == "tooltip") then
		lib.ProcessTooltip(...)
	elseif (callbackType == "load") then
		lib.OnLoad(...)
	end
end

lib.ScanProcessors = {}
function lib.ScanProcessors.create(operation, itemData, oldData)
	if (not data) then private.makeData() end

	-- This function is responsible for processing and storing the stats after each scan
	-- Note: itemData gets reused over and over again, so do not make changes to it, or use
	-- it in places where you rely on it. Make a deep copy of it if you need it after this
	-- function returns.

	-- We're only interested in items with buyouts.
	local buyout = itemData.buyoutPrice
	if not buyout or buyout == 0 then return end
	if (itemData.stackSize > 1) then
		buyout = buyout.."/"..itemData.stackSize
	end

	-- Get the signature of this item and find it's stats.
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(itemData.link)
	if (linkType ~= "item") then return end
	if (factor and factor ~= 0) then property = property.."x"..factor end

	local faction = AucAdvanced.GetFaction()
	if not data[faction] then data[faction] = {} end
	local stats = private.UnpackStats(data[faction][itemId])
	if not stats[property] then stats[property] = {} end
	if #stats[property] >= 100 then
		table.remove(stats[property], 1)
	end
	table.insert(stats[property], buyout)
	data[faction][itemId] = private.PackStats(stats)
	recycle(stats)
end

function private.GetCfromZ(Z)
	--C = 0.05*i
	if (not Z) then
		return .05
	end
	if (Z > 10) then
		return .99
	end
	local i = 1
	while Z > ZValues[i] do
		i = i + 1
	end
	if i == 1 then 
		return .05
	else
		i = i - 1 + ((Z - ZValues[i-1]) / (ZValues[i] - ZValues[i-1]))
		return i*0.05
	end
end

function lib.GetPrice(hyperlink, faction)
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end
	if (factor and factor ~= 0) then property = property.."x"..factor end

	if not faction then faction = AucAdvanced.GetFaction() end
	if not data[faction] then return end

	if not data[faction][itemId] then return end

	local stats = private.UnpackStats(data[faction][itemId])
	if not stats[property] then return end

	local count = #stats[property]
	if (count < 1) then return end

	local total, number = 0, 0
	for i = 1, count do
		local price, stack = strsplit("/", stats[property][i])
		price = tonumber(price) or 0
		stack = tonumber(stack) or 1
		if (stack < 1) then stack = 1 end
		total = total + tonumber(price)
		number = number + stack
	end
	local mean = total / number

	if (count < 2) then return 0,0,0, mean, count end

	local variance = 0
	for i = 1, count do
		local price, stack = strsplit("/", stats[property][i])
		price = tonumber(price) or 0
		stack = tonumber(stack) or 1
		if (stack < 1) then stack = 1 end
		variance = variance + (math.abs(mean - price) ^ 2)
	end
	variance = variance / number
	local stdev = variance ^ 0.5

	local deviation = 1.5 * stdev

	total = 0
	number = 0
	for i = 1, count do
		local price, stack = strsplit("/", stats[property][i])
		price = tonumber(price) or 0
		stack = tonumber(stack) or 1
		if (stack < 1) then stack = 1 end
		if (math.abs(price - mean) < deviation) then
			total = total + price
			number = number + stack
		end
	end

	local confidence = .01
	recycle(stats)
	local average
	if (number > 0) then 
		average = total / number 
		confidence = (.15*average)*(number^0.5)/(stdev)
		confidence = private.GetCfromZ(confidence)
	end
	
	return average, mean, false, stdev, variance, count, confidence
end

function lib.GetPriceColumns()
	return "Average", "Mean", false, "Std Deviation", "Variance", "Count"
end

local array = {}
function lib.GetPriceArray(hyperlink, faction, realm)
	-- Clean out the old array
	while (#array > 0) do table.remove(array) end

	-- Get our statistics
	local average, mean, _, stdev, variance, count, confidence = lib.GetPrice(hyperlink, faction, realm)

	-- These 3 are the ones that most algorithms will look for
	array.price = average or mean
	array.seen = count
	array.confidence = confidence
	-- This is additional data
	array.normalized = average
	array.mean = mean
	array.deviation = stdev
	array.variance = variance

	-- Return a temporary array. Data in this array is
	-- only valid until this function is called again.
	return array
end

function lib.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost, ...)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine whether or what you should
	-- display in the tooltip.
	if not quantity or quantity < 1 then quantity = 1 end
	local average, mean, _, stdev, var, count, confidence = lib.GetPrice(hyperlink)

	if (mean and mean > 0) then
		EnhTooltip.AddLine(libName.." prices ("..count.." points):")
		EnhTooltip.LineColor(0.3, 0.9, 0.8)

		EnhTooltip.AddLine("  Mean price", mean*quantity)
		EnhTooltip.LineColor(0.3, 0.9, 0.8)
		if (average and average > 0) then
			EnhTooltip.AddLine("  Normalized", average*quantity)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
			if (quantity > 1) then
				EnhTooltip.AddLine("  (or individually)", average)
				EnhTooltip.LineColor(0.3, 0.9, 0.8)
			end
			EnhTooltip.AddLine("  Std Deviation", stdev)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
			EnhTooltip.AddLine("  Confidence: "..(floor(confidence*1000))/1000)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
	end
end

function lib.OnLoad(addon)
	private.makeData()
end

--[[ Local functions ]]--

function private.DataLoaded()
	-- This function gets called when the data is first loaded. You may do any required maintenence
	-- here before the data gets used.

end

function private.UnpackStatIter(data, ...)
	local c = select("#", ...)
	local v
	for i = 1, c do
		v = select(i, ...)
		local property, info = strsplit(":", v)
		property = tonumber(property) or property
		if (property and info) then
			data[property] = acquire( strsplit(";", info) )
			local item
			for i=1, #data[property] do
				item = data[property][i]
				data[property][i] = tonumber(item) or item
			end
		end
	end
end
function private.UnpackStats(dataItem)
	local data = acquire()
	if (dataItem) then
		private.UnpackStatIter(data, strsplit(",", dataItem))
	end
	return data
end
function private.PackStats(data)
	local stats = ""
	local joiner = ""
	for property, info in pairs(data) do
		stats = stats..joiner..property..":"..strjoin(";", unpack(info))
		joiner = ","
	end
	return stats
end

function private.makeData()
	if data then return end
	if (not AucAdvancedStatStdDevData) then AucAdvancedStatStdDevData = {} end
	data = AucAdvancedStatStdDevData
	private.DataLoaded()
end


