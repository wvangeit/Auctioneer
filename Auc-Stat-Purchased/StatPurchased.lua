--[[
	Auctioneer Advanced - StatPurchased
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

local libType, libName = "Stat", "Purchased"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()

local data

function lib.CommandHandler(command, ...)
	local myFaction = AucAdvanced.GetFaction()
	local realm = GetRealmName()
	if (command == "help") then
		print("Help for Auctioneer Advanced - "..libName)
		local line = AucAdvanced.Config.GetCommandLead(libType, libName)
		print(line, "help}} - this", libName, "help")
		print(line, "clear [faction [realm]]}} - clear "..libName.." price database ("..myFaction.." on "..realm.." by default)")
		print(line, "push [faction [realm]]}} - force the "..libName.." daily stats for faction to archive ("..myFaction.." on "..realm.." by default)")
	elseif (command == "clear") then
		private.ClearData(...)
	elseif (command == "push") then
		print("Archiving {{", myFaction, "}} daily stats and starting a new day")
		private.PushStats(myFaction, realmname)
	end
end

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		private.ProcessTooltip(...)
	elseif (callbackType == "config") then
		--Called when you should build your Configator tab.
		private.SetupConfigGui(...)
	elseif (callbackType == "load") then
		lib.OnLoad(...)
	end
end


lib.ScanProcessors = {}
local auctiondata
function lib.ScanProcessors.begin()
	auctiondata = private.GetAuctionData()
end
function lib.ScanProcessors.complete()
	auctiondata = nil
end

function lib.ScanProcessors.suspend(operation, itemData, oldData)
	if (itemData.buyoutPrice) then
		if (not auctiondata[itemData.id]) then auctiondata[itemData.id] = {} end
		auctiondata[itemData.id].boughtout = true
	end
end

function lib.ScanProcessors.update(operation, itemData, oldData)
	if (itemData.price ~= oldData.price) then
		if (not auctiondata[itemData.id]) then auctiondata[itemData.id] = {} end
		auctiondata[itemData.id].bidon = true
	end
end

function lib.ScanProcessors.delete(operation, itemData, oldData)
	if (itemData.buyoutPrice) then
		local stillpossible = false
		local auctionmaxtime = AucAdvanced.Const.AucMinTimes[itemData.timeLeft] or 86400
		if (time() - itemData.seenTime <= auctionmaxtime) then
			stillpossible = true
		end

		if (stillpossible) then
			if (not auctiondata[itemData.id]) then auctiondata[itemData.id] = {} end
			auctiondata[itemData.id].boughtout = true
		end
	end

	if (not auctiondata[itemData.id]) then return end

	local pricedata = private.GetPriceData()
	local itemType, itemId, property, factor = AucAdvanced.DecodeLink(itemData.link)
	if (factor ~= 0) then property = property.."x"..factor end
	local price = 0
	if not pricedata.daily then pricedata.daily = { created = time() } end
	if not pricedata.daily[itemId] then pricedata.daily[itemId] = "" end

	if (auctiondata[itemData.id].boughtout and itemData.buyoutPrice) then
		price = itemData.buyoutPrice
	else
		price = itemData.price
	end

	price = price / itemData.stackSize
	local stats = private.UnpackStats(pricedata.daily[itemId])
	if not stats[property] then stats[property] = { 0, 0 } end
	stats[property][1] = stats[property][1] + price
	stats[property][2] = stats[property][2] + 1
	pricedata.daily[itemId] = private.PackStats(stats)
	auctiondata[itemData.id] = nil
end

lib.Private = private

function lib.GetPrice(hyperlink, faction, realm)
	local data = private.GetPriceData(faction, realm)
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end
	if (factor ~= 0) then property = property.."x"..factor end

	if not data then return end
	local dayTotal, dayCount, dayAverage = 0,0,0
	local seenDays, seenCount, avg3, avg7, avg14 = 0,0,0,0,0

	if data.daily and data.daily[itemId] then
		local stats = private.UnpackStats(data.daily[itemId])
		if stats[property] then
			dayTotal, dayCount = unpack(stats[property])
			dayAverage = dayTotal/dayCount
		end
	end
	if data.means and data.means[itemId] then
		local stats = private.UnpackStats(data.means[itemId])
		if stats[property] then
			seenDays, seenCount, avg3, avg7, avg14 = unpack(stats[property])
		end
	end
	return dayAverage, avg3, avg7, avg14, false, dayTotal, dayCount, seenDays, seenCount
end

function lib.GetPriceColumns()
	return "Daily Avg", "3 Day Avg", "7 Day Avg", "14 Day Avg", false, "Daily Total", "Daily Count", "Seen Days", "Seen Count"
end

local array = {}
function lib.GetPriceArray(hyperlink, faction, realm)
	-- Clean out the old array
	while (#array > 0) do table.remove(array) end

	-- Get our statistics
	local dayAverage, avg3, avg7, avg14, _, dayTotal, dayCount, seenDays, seenCount = lib.GetPrice(hyperlink, faction, realm)

	-- These 2 are the ones that most algorithms will look for
	array.price = avg3 or dayAverage
	array.seen = seenCount
	-- This is additional data
	array.avgday = dayAverage
	array.avg3 = avg3
	array.avg7 = avg7
	array.avg14 = avg14
	array.daytotal = dayTotal
	array.daycount = dayCount
	array.seendays = seenDays

	-- Return a temporary array. Data in this array is
	-- only valid until this function is called again.
	return array
end

function lib.OnLoad(addon)
	AucAdvanced.Settings.SetDefault("stat.purchased.tooltip", true)
	AucAdvanced.Settings.SetDefault("stat.purchased.avg3", true)
	AucAdvanced.Settings.SetDefault("stat.purchased.avg7", true)
	AucAdvanced.Settings.SetDefault("stat.purchased.avg14", true)
	AucAdvanced.Settings.SetDefault("stat.purchased.quantmul", true)
end

AucAdvanced.Settings.SetDefault("stat.purchased.tooltip", true)

function private.SetupConfigGui(gui)
	id = gui:AddTab(lib.libName, lib.libType.." Modules")
	--gui:MakeScrollable(id)
	
	gui:AddHelp(id, "what purchased stats",
		"What are purchased stats?",
		"Purchased stats are the numbers that are generated by the Purchased module, the "..
		"Purchased module attempts to determine if an auction was bought out or purchased on "..
		"a bid.  It also calculates a Moving Average (3/7/14).")

	gui:AddHelp(id, "what moving day average purchased",
		"What does 'moving average' mean?",
		"Moving average means that it places more value on yesterday's moving average "..
		"than today's average.  The determined amount is then used for "..
		"tomorrow's moving average calculation.")
	
	gui:AddHelp(id, "how day average calculated purchased",
		"How is the moving day averages calculated exactly?",
		"Todays Moving Average is ((X-1)*YesterdaysMovingAverage + TodaysAverage) / X, "..
		"where X is the number of days (3,7, or 14).")

	gui:AddHelp(id, "no day saved purchased",
		"So you aren't saving a day-to-day average?",
		"No, that would not only take up space, but heavy calculations on each "..
		"auction house scan.")

	gui:AddHelp(id, "why multiply stack size stddev",
		"Why have the option to multiply stack size?",
		"The original Stat-Purchased multiplied by the stack size of the item, "..
		"but some like dealing on a per-item basis.")
		
	gui:AddControl(id, "Header",     0,    libName.." options")
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.purchased.tooltip", "Show purchased stats in the tooltips?")
	gui:AddTip(id, "Toggle display of stats from the Purchased module on or off")
	gui:AddControl(id, "Checkbox",   0, 2, "stat.simple.avg3", "Display Moving 3 Day Average")
	gui:AddTip(id, "Toggle display of 3-Day Average from the Simple module on or off")
	gui:AddControl(id, "Checkbox",   0, 2, "stat.simple.avg7", "Display Moving 7 Day Average")
	gui:AddTip(id, "Toggle display of 7-Day Average from the Simple module on or off")
	gui:AddControl(id, "Checkbox",   0, 2, "stat.simple.avg14", "Display Moving 14 Day Average")
	gui:AddTip(id, "Toggle display of 14-Day Average from the Simple module on or off")
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.purchased.quantmul", "Multiply by Stack Size")
	gui:AddTip(id, "Multiplies by current Stack Size if on")
	
end


--[[ Local functions ]]--
function private.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine what you should
	-- display in the tooltip.
	if not AucAdvanced.Settings.GetSetting("stat.purchased.tooltip") then return end
	
	if not quantity or quantity < 1 then quantity = 1 end
	if AucAdvanced.Settings.GetSetting("stat.purchased.quantmul") then quantity = 1 end
	local dayAverage, avg3, avg7, avg14, _, dayTotal, dayCount, seenDays, seenCount = lib.GetPrice(hyperlink)
	if (not dayAverage) then return end
	local dispAvg3 = AucAdvanced.Settings.GetSetting("stat.purchased.avg3")
	local dispAvg7 = AucAdvanced.Settings.GetSetting("stat.purchased.avg7")
	local dispAvg14 = AucAdvanced.Settings.GetSetting("stat.purchased.avg14")

	if (seenDays + dayCount > 0) then
		EnhTooltip.AddLine(libName.." prices:")
		EnhTooltip.LineColor(0.3, 0.9, 0.8)

		if (seenDays > 0) then
			if (dayCount>0) then seenDays = seenDays + 1 end
			EnhTooltip.AddLine("  Seen |cffddeeff"..(seenCount+dayCount).."|r over |cffddeeff"..seenDays.."|r days:")
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
		if (seenDays > 6) and dispAvg14 then
			EnhTooltip.AddLine("  14 day average", avg14*quantity)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
		if (seenDays > 2) and dispAvg7 then
			EnhTooltip.AddLine("  7 day average", avg7*quantity)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
		if (seenDays > 0) and dispAvg3 then
			EnhTooltip.AddLine("  3 day average", avg3*quantity)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
		if (dayCount > 0) then
			EnhTooltip.AddLine("  Seen |cffddeeff"..dayCount.."|r today", dayAverage*quantity)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
	end
end

-- This is a function which migrates the data from a daily average to the
-- Exponential Moving Averages over the 3, 7 and 14 day ranges.
function private.PushStats(faction, realm)
	local dailyAvg

	local data = private.GetPriceData(faction, realm)
	if not data then return end
	if not data.daily then return end
	if not data.means then data.means = {} end

	local pdata
	for itemId, stats in pairs(data.daily) do
		if (itemId ~= "created") then
			pdata = private.UnpackStats(stats)
			fdata = private.UnpackStats(data.means[itemId] or "")
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
			data.means[itemId] = private.PackStats(fdata)
		end
	end
	data.daily = { created = time() }
end

function private.UnpackStatIter(data, ...)
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

function private.UnpackStats(dataItem)
	local data = {}
	private.UnpackStatIter(data, strsplit(",", dataItem))
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

-- The following Functions are the routines used to access the permanent store data
local AAStatPurchasedData

function private.UpgradeDb()
	-- Do Nothing
end

function private.ClearData(faction, realmName)
	if (not AAStatPurchasedData) then private.LoadData() end
	faction = faction or AucAdvanced.GetFactionGroup()
	if (realmName) then
		print("Clearing "..libName.." stats for {{"..faction.."}}")
	else
		realmName = GetRealmName()
		print("Clearing "..libName.." stats for {{"..faction.."}} on {{"..realmName.."}}")
	end
	if (AAStatPurchasedData.RealmData[realmName] and AAStatPurchasedData.RealmData[realmName][faction]) then
		AAStatPurchasedData.RealmData[realmName][faction] = nil
	end
end

function private.GetAuctionData(faction, realm)
	if (not AAStatPurchasedData) then private.LoadData() end
	faction = faction or AucAdvanced.GetFactionGroup()
	realm = realm or GetRealmName()
	if (not AAStatPurchasedData.RealmData[realm]) then AAStatPurchasedData.RealmData[realm] = {} end
	if (not AAStatPurchasedData.RealmData[realm][faction]) then AAStatPurchasedData.RealmData[realm][faction] = {auctionData={}, stats={}} end
	return AAStatPurchasedData.RealmData[realm][faction].auctionData
end

function private.GetPriceData(faction, realm)
	if (not AAStatPurchasedData) then private.LoadData() end
	faction = faction or AucAdvanced.GetFactionGroup()
	realm = realm or GetRealmName()
	if (not AAStatPurchasedData.RealmData[realm]) then AAStatPurchasedData.RealmData[realm] = {} end
	if (not AAStatPurchasedData.RealmData[realm][faction]) then AAStatPurchasedData.RealmData[realm][faction] = {auctionData={}, stats={}} end
	return AAStatPurchasedData.RealmData[realm][faction].stats
end

function private.DataLoaded()
	if (not AAStatPurchasedData) then return end
	-- This function gets called when the data is first loaded. You may do any required maintenence
	-- here before the data gets used.
	for realm, realmdata in pairs(AAStatPurchasedData.RealmData) do
		for faction, stats in pairs(realmdata) do
			if not stats.daily then stats.daily = { created = time() } end
			if not stats.means then stats.means = {} end
			if stats.daily.created and time() - stats.daily.created > 3600*16 then
				-- This data is more than 16 hours old, we classify this as "yesterday's data"
				private.PushStats(faction, realm)
			end
		end
	end
end

function private.LoadData()
	if (AAStatPurchasedData) then return end
	if (not AucAdvancedStatPurchasedData) then AucAdvancedStatPurchasedData = {Version='1.0', RealmData = {}} end
	private.UpgradeDb()
	AAStatPurchasedData = AucAdvancedStatPurchasedData
	private.DataLoaded()
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")