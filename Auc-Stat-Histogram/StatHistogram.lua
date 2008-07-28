--[[
	Auctioneer Advanced - Histogram Statistics module
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

local libType, libName = "Stat", "Histogram"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,recycle,acquire,clone,_,get,set,default, debugPrint = AucAdvanced.GetModuleLocals()

--scrub(mytable)
--clears out all keys in mytable
--doesn't go into multi-level scrubbing, because we don't need to scrub multi-level tables in this module
local function scrub(mytable)
	for i in pairs(mytable) do
		mytable[i] = nil
	end
end

local data
local stattable = {}
local PDcurve = {}
local newstats = {}
local array = {}

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
		
	end
end

function lib.Processor(callbackType, ...)
	if (not data) then private.makeData() end
	if (callbackType == "tooltip") then
		lib.ProcessTooltip(...)
	elseif (callbackType == "config") then
		--Called when you should build your Configator tab.
		private.SetupConfigGui(...)
	elseif (callbackType == "load") then
		lib.OnLoad(...)
	end
end

function private.GetPriceData()
	if not stattable["count"] then
		debugPrint("GetPriceData: No stattable", libType.."-"..libName)
		return
	end
	local median = 0
	local Qone = 0
	local Qthree = 0
	local count = stattable["count"]
	debugPrint("getPricedata: "..tostring(stattable["count"]), libType.."-"..libName)
	local recount = 0
	--now find the Q1, median, and Q3 values
	for i = stattable["min"], stattable["max"] do
		recount = recount + (stattable[i] or 0)
		if Qone == 0 and count > 4 then --Q1 is meaningless with very little data
			if recount >= count/4 then
				Qone = i*stattable["step"]
			end
		elseif median == 0 then
			if recount >= count/2 then
				median = i*stattable["step"]
			end
		elseif Qthree == 0 and count > 4 then--Q3 is meaningless with very little data
			if recount >= count * 3/4 then
				Qthree = i*stattable["step"]
				break
			end
		else
			break
		end
	end
	local step = stattable["step"]
	local refactored = false
	if count > 30 then --we've seen enough to get a fairly decent price to base the precision on
		if (step > (median/150)) and (step > 1) then
			private.refactor(median*3, 750)
			refactored = true
		elseif step < (median/350) then
			private.refactor(median*3, 750)
			refactored = true
		end
	end
	return median, Qone, Qthree, step, count, refactored
end

function lib.GetPrice(link, faction)
	scrub(stattable)
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(link)
	if (linkType ~= "item") then return end
	if (factor and factor ~= 0) then property = property.."x"..factor end
	
	if not faction then faction = AucAdvanced.GetFaction() end
	if (not data[faction]) or (not data[faction][itemId]) or (not data[faction][itemId][property]) then
		debugPrint("GetPrice: No data", libType.."-"..libName)
		return
	end
	private.UnpackStats(data[faction][itemId][property])
	local median, Qone, Qthree, step, count, refactored = private.GetPriceData()
	if refactored then
		--data has been refactored, so we need to repack it
		data[faction][itemId][property] = private.PackStats()
		--get the updated data
		median, Qone, Qthree, step, count = private.GetPriceData()
	end
	--we're done with the data, so clear the table
	scrub(stattable)
	return median, Qone, Qthree, step, count
end


function lib.GetPriceColumns()
	return "Median", "Q1", "Q3", "step", "Seen"
end

function lib.GetPriceArray(link, faction)
	--make sure that array is empty
	scrub(array)
	local median, Qone, Qthree, step, count = lib.GetPrice(link, faction)
	--these are the two values that GetMarketPrice cares about
	array.price = median
	array.seen = count
	--additional data
	array.Qone = Qone
	array.Qthree = Qthree
	array.step = step
	
	-- Return a temporary array. Data in this array is
	-- only valid until this function is called again.
	return array
end

function private.ItemPDF(price)
	if not PDcurve["step"] then return 0 end
	local index = math.floor(price/PDcurve["step"])
	if (index >= PDcurve["min"]) and (index <= PDcurve["max"]) then
		return PDcurve[index]
	else
		return 0
	end
end

function lib.GetItemPDF(link, faction)
	scrub(PDcurve)
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(link)
	if (linkType ~= "item") then return end
	if (factor and factor ~= 0) then property = property.."x"..factor end
	
	if not faction then faction = AucAdvanced.GetFaction() end
	if not data[faction] then return end
	if not data[faction][itemId] then return end
	if not data[faction][itemId][property] then return end
	private.UnpackStats(data[faction][itemId][property])
	local median, Qone, Qthree, step, count, refactored = private.GetPriceData()
	if refactored then
		--data has been refactored, so we need to repack it
		data[faction][itemId][property] = private.PackStats()
		--get the updated data
		median, Qone, Qthree, step, count = private.GetPriceData()
	end
	if not count or count == 0 then
		return
	end
	local curcount = 0
	local area = 0
	local targetarea = math.min(1, count/30) --if count is less than thirty, we're not very sure about the price
	
	PDcurve["step"] = step
	PDcurve["min"] = stattable["min"]
	PDcurve["max"] = stattable["max"]
	
	for i = stattable["min"], stattable["max"] do
		curcount = curcount + stattable[i]
		PDcurve[i] = 1-(math.abs(2*curcount - count)/count)
		area = area + step*PDcurve[i]
	end
	
	local areamultiplier = 1
	if area > 0 then
		areamultiplier = targetarea/area
	end
	for i = PDcurve["min"], PDcurve["max"] do
		PDcurve[i]= PDcurve[i] * areamultiplier
	end
	return private.ItemPDF, PDcurve["min"], PDcurve["max"]
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
		buyout = buyout/itemData.stackSize
	end
	local priceindex
	
	-- Get the signature of this item and find it's stats.
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(itemData.link)
	if (linkType ~= "item") then return end
	if (factor and factor ~= 0) then property = property.."x"..factor end

	scrub(stattable)
	local faction = AucAdvanced.GetFaction()
	if not data[faction] then data[faction] = {} end
	if not data[faction][itemId] then data[faction][itemId] = {} end
	if data[faction][itemId][property] then
		private.UnpackStats(data[faction][itemId][property])
	end
	if not stattable["count"] then
		--start out with first 20 prices pushing max to 100.  This should help prevent losing data due to the first price being way too low
		--also keeps data small initially, as we don't need extremely accurate prices with that little data
		stattable["step"] = math.ceil(buyout / 100)
		stattable["count"] = 0
	end
	priceindex = math.ceil(buyout / stattable["step"])
	if priceindex <= 750 or stattable["count"] <= 20 then --we don't want prices too high: they'll bloat the data.  If range needs to go higher, we'll refactor later
		stattable["count"] = stattable["count"] + 1
		if not stattable["min"] then --first time we've seen this
			stattable["min"] = priceindex
			stattable["max"] = priceindex
			stattable[priceindex] = 0
		elseif stattable["min"] > priceindex then
			for i = priceindex, (stattable["min"]-1) do
				stattable[i] = 0
			end
			stattable["min"] = priceindex
		elseif stattable["max"] < priceindex then
			for i = (stattable["max"]+1),priceindex do
				stattable[i] = 0
			end
			stattable["max"] = priceindex
		end
		if not stattable[priceindex] then stattable[priceindex] = 0 end
		stattable[priceindex] = stattable[priceindex] + 1
		if stattable["count"] <= 20 and stattable["max"] > 100 then
			private.refactor(buyout, 100)--we're still on initial data collection, so shrink it back down
		end
		data[faction][itemId][property] = private.PackStats()
	end
	scrub(stattable)
end

function private.SetupConfigGui(gui)
	local id = gui:AddTab(lib.libName, lib.libType.." Modules")
	
	gui:AddHelp(id, "what histogram stats",
		"What are Histogram stats?",
		"Histogram stats record a histogram of past prices.")
	gui:AddHelp(id, "what advantages",
		"What advantages does Histogram have?",
		"Histogram stats don't have a limitation to how many, "..
		"or how long, it can keep data, so it can keep track of high-volume items well")
	gui:AddHelp(id, "what disadvantage",
		"What disadvantages does Histogram have?",
		"Histogram rounds prices slightly to help store them, so there is a slight precision loss."..
		"  However, it is precise to 1/250th of market price. (an item with market price 250g will have"..
		" prices stored to the nearest 1g)")
	gui:AddHelp(id, "what median",
		"What is the median?",
		"The median value is the value where half of the prices seen are above, and half are below.")
	gui:AddHelp(id, "what IQR",
		"What is the IQR?",
		"The IQR is a measure of spread.  The middle half of the prices seen is confined with the range of IQR."..
		"  An item with median 100g, and IQR 10g, has very consistent data.  If the IQR was 100g, the prices "..
		"are all over the place.")

	gui:MakeScrollable(id)
	gui:AddControl(id, "Header",     0,    "Histogram options")
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.histogram.tooltip", "Show Histogram stats in the tooltips?")
	gui:AddTip(id, "Toggle display of stats from the Histogram module on or off")
	gui:AddControl(id, "Checkbox",   0, 2, "stat.histogram.median", "Display Median")
	gui:AddTip(id, "Toggle display of 'Median' calculation in tooltips on or off")
	gui:AddControl(id, "Checkbox",   0, 2, "stat.histogram.iqr", "Display IQR")
	gui:AddTip(id, "Toggle display of 'IQR' calculation in tooltips on or off.  See help for further explanation.")
	gui:AddControl(id, "Checkbox",   0, 2, "stat.histogram.precision", "Display Precision")
	gui:AddTip(id, "Toggle display of 'precision' calculation in tooltips on or off")
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.histogram.quantmul", "Multiply by Stack Size")
	gui:AddTip(id, "Multiplies by current Stack Size if on")
end

function lib.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost, ...)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine whether or what you should
	-- display in the tooltip.
	
	if not get("stat.histogram.tooltip") then
		return
	end
	
	local quantmul = get("stat.histogram.quantmul")
	if (not quantmul) or (not quantity) or (quantity < 1) then quantity = 1 end
	local median, Qone, Qthree, step, count = lib.GetPrice(hyperlink)
	if not count then
		count = 0
	end
	if median then
		if quantity == 1 then
			EnhTooltip.AddLine(libName.." prices: (seen "..tostring(count)..")")
		else
			EnhTooltip.AddLine(libName.." prices x"..tostring(quantity)..": (seen "..tostring(count)..")")
		end
		EnhTooltip.LineColor(0.3, 0.9, 0.8)
		local iqr = Qthree-Qone
		if get("stat.histogram.median") then
			EnhTooltip.AddLine("  median:", median*quantity)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
			if quantity > 1 then
				EnhTooltip.AddLine("   (or individually):", median)
				EnhTooltip.LineColor(0.3, 0.9, 0.8)
			end
		end
		if (iqr > 0) and (get("stat.histogram.iqr")) then
			EnhTooltip.AddLine("  IQR:", iqr*quantity)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
		if get("stat.histogram.precision") then
		EnhTooltip.AddLine("  precision:", step*quantity)
		EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
		--EnhTooltip.AddLine("  index: "..tostring(math.floor(median/step)))
		--EnhTooltip.LineColor(0.3, 0.9, 0.8)
	end
end

function lib.OnLoad(addon)
	private.makeData()
	AucAdvanced.Settings.SetDefault("stat.histogram.tooltip", true)
	AucAdvanced.Settings.SetDefault("stat.histogram.median", true)
	AucAdvanced.Settings.SetDefault("stat.histogram.iqr", true)
	AucAdvanced.Settings.SetDefault("stat.histogram.precision", true)
	AucAdvanced.Settings.SetDefault("stat.histogram.quantmul", true)
end

function lib.ClearItem(hyperlink, faction)
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(link)
	if (linkType ~= "item") then return end
	if (factor and factor ~= 0) then property = property.."x"..factor end
	
	if not faction then faction = AucAdvanced.GetFaction() end
	if not data[faction] then return end
	if not data[faction][itemId] then return end
	data[faction][itemId][property] = nil
end

--[[ Local functions ]]--

function private.DataLoaded()
	-- This function gets called when the data is first loaded. You may do any required maintenence
	-- here before the data gets used.

end

function private.makeData()
	if data then return end
	if (not AucAdvancedStatHistogramData) then AucAdvancedStatHistogramData = {} end
	data = AucAdvancedStatHistogramData
	private.DataLoaded()
end

function private.UnpackStats(dataItem)
	scrub(stattable)
	if dataItem then
		local firstvalue, maxvalue, step, count, newdataItem = strsplit(";",dataItem)
		if not newdataItem then
			debugPrint("Unpack: dataItem only 4 long", libType.."-"..libName)
			return
		end
		stattable["min"] = tonumber(firstvalue)
		stattable["max"] = tonumber(maxvalue)
		stattable["step"] = tonumber(step)
		stattable["count"] = tonumber(count)
		local index = stattable["min"]
		if not index then
			print(dataItem)
		end
		for n in newdataItem:gmatch("[0-9]+") do
			stattable[index] = tonumber(n)
			index = index + 1
		end
	else
		debugPrint("Unpack: No data passed", libType.."-"..libName)
	end
end

function private.PackStats()
	local tempstr = ""
	local datastr = ""
	local imin = stattable["min"]
	tempstr = strjoin(";",imin,stattable["max"], stattable["step"], stattable["count"])
		datastr = tostring(stattable[imin] or 0)--this gets rid of the string starting as ",1,0,0..."
	for i = imin+1,stattable["max"] do
		datastr = datastr..","..tostring(stattable[i] or 0)
	end
	tempstr = tempstr..";"..datastr
	return tempstr
end

--private.refactor(pmax, precision)
--pmax is the max for the distribution
--redistributes the price data so that pmax is at precision
--this does cause some loss of accuracy, but should only be necessary every once in a great while
--and increases future accuracy.
--If data points would end up having an index > 750, they get cut off.  They're more than 3x market price, and should not be taken into account anyway
--called by the GetPrice function when price is detected as being too far off an index of 250
--Also called when adding new data early on that would push the max up.
function private.refactor(pmax, precision)
	if type(stattable) ~= "table" or type(pmax)~="number" or pmax == 0 then
		return
	end
	scrub(newstats)
	newstats["step"] = math.ceil(pmax/precision)
	local conversion = stattable["step"]/newstats["step"]
	newstats["min"] = math.ceil(conversion*stattable["min"])
	newstats["max"] = math.ceil(conversion*stattable["max"])
	local count = 0
	if newstats["max"] > 750 then
		--we need to crop off the top end
		newstats["max"] = 750
		stattable["max"] = math.floor(750/conversion)
	end
	for i = newstats["min"], newstats["max"] do
		newstats[i] = 0
	end
	for i = stattable["min"], stattable["max"] do
		local j = math.ceil(conversion*i)
		if not newstats[j] then newstats[j] = 0 end
		newstats[j]= newstats[j] + stattable[i]
		count = count + stattable[i]
	end
	scrub(stattable)
	for i,j in pairs(newstats) do
		stattable[i] = j
	end
	stattable["count"] = count
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")