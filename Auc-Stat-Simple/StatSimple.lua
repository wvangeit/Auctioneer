--[[
	Auctioneer Advanced - StatSimple
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

local libType, libName = "Stat", "Simple"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()

local data

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
	elseif (callbackType == "config") then
		--Called when you should build your Configator tab.
		private.SetupConfigGui(...)
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
	local buyoutper = ceil(buyout/itemData.stackSize)
	if not buyout or buyout == 0 then return end

	-- In this case, we're only interested in the initial create, other
	-- Get the signature of this item and find it's stats.
	local itemType, itemId, property, factor = AucAdvanced.DecodeLink(itemData.link)
	if (factor ~= 0) then property = property.."x"..factor end

	local data = private.GetPriceData()
	if not data.daily then data.daily = { created = time() } end
	if not data.daily[itemId] then data.daily[itemId] = "" end
	local stats = private.UnpackStats(data.daily[itemId])
	if not stats[property] then stats[property] = { 0, 0 , buyoutper } end
	stats[property][1] = stats[property][1] + buyout
	stats[property][2] = stats[property][2] + itemData.stackSize
	if stats[property][3] > buyoutper then stats[property][3] = buyoutper end
	data.daily[itemId] = private.PackStats(stats)
	recycle(stats)
end

function lib.GetPrice(hyperlink, faction, realm)
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end
	if (factor ~= 0) then property = property.."x"..factor end

	if not faction then faction = AucAdvanced.GetFaction() end

	local data = private.GetPriceData(faction, realm)
	if not data then return end

	local dayTotal, dayCount, dayAverage, minBuyout = 0,0,0,0
	local seenDays, seenCount, avg3, avg7, avg14, avgmins = 0,0,0,0,0,0

	if data.daily and data.daily[itemId] then
		local stats = private.UnpackStats(data.daily[itemId])
		if stats[property] then
			dayTotal, dayCount, minBuyout = unpack(stats[property])
			dayAverage = dayTotal/dayCount
		end
		recycle(stats)
	end
	if data.means and data.means[itemId] then
		local stats = private.UnpackStats(data.means[itemId])
		if stats[property] then
			seenDays, seenCount, avg3, avg7, avg14, avgmins = unpack(stats[property])
		end
		recycle(stats)
	end
	return dayAverage, avg3, avg7, avg14, minBuyout, avgmins, false, dayTotal, dayCount, seenDays, seenCount
end

function lib.GetPriceColumns()
	return "Daily Avg", "3 Day Avg", "7 Day Avg", "14 Day Avg", "Min BO", "Avg MBO", false, "Daily Total", "Daily Count", "Seen Days", "Seen Count"
end

local array = {}
function lib.GetPriceArray(hyperlink, faction, realm)
	-- Clean out the old array
	while (#array > 0) do table.remove(array) end

	-- Get our statistics
	local dayAverage, avg3, avg7, avg14, minBuyout, avgmins, _, dayTotal, dayCount, seenDays, seenCount = lib.GetPrice(hyperlink, faction, realm)

	-- These 2 are the ones that most algorithms will look for
	if (avg3 and seenDays > 3) or dayCount == 0 then
		array.price = avg3
	elseif dayCount > 0 then
		array.price = dayAverage
	end
	array.seen = seenCount
	-- This is additional data
	array.avgday = dayAverage
	array.avg3 = avg3
	array.avg7 = avg7
	array.avg14 = avg14
	array.mbo = minBuyout
	array.avgmins = avgmins
	array.daytotal = dayTotal
	array.daycount = dayCount
	array.seendays = seenDays

	-- Return a temporary array. Data in this array is
	-- only valid until this function is called again.
	return array
end

function lib.OnLoad(addon)

end

local AAStatSimpleData

function lib.ClearItem(hyperlink, faction, realm)
	local linkType, itemID, property, factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then 
		return 
	end
	if (factor ~= 0) then property = property.."x"..factor end
	if not faction then faction = AucAdvanced.GetFaction() end
	if not realm then
		realm = GetRealmName()
	end
	if (not AAStatSimpleData) then private.LoadData() end
	print(libType.."-"..libName..": clearing data for "..hyperlink.." for {{"..faction.."}}")
	if (AAStatSimpleData.RealmData[realm] and AAStatSimpleData.RealmData[realm][faction]) then
		AAStatSimpleData.RealmData[realm][faction]["means"][itemID] = nil
		AAStatSimpleData.RealmData[realm][faction]["daily"][itemID] = nil
	end	
end


AucAdvanced.Settings.SetDefault("stat.simple.tooltip", true)
AucAdvanced.Settings.SetDefault("stat.simple.quantmul", true)

function private.SetupConfigGui(gui)
	id = gui:AddTab(lib.libName, lib.libType.." Modules")
	--gui:MakeScrollable(id)
	
	gui:AddHelp(id, "what simple stats",
		"What are simple stats?",
		"Simple stats are the numbers that are generated by the Simple module, the "..
		"Simple module averages all of the prices for items that it sees and provides"..
		"moving 3, 7, and 14 day averages.  It also provides daily minimum buyout"..
		"along with a running average minimum buyout within 10% variance.")

	gui:AddControl(id, "Header",     0,    libName.." options")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.simple.tooltip", "Show simple stats in the tooltips?")
	gui:AddTip(id, "Toggle display of stats from the Simple module on or off")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.simple.quantmul", "Multiply values by the number of items currently highlighted")	
end

--[[ Local functions ]]--

function private.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine whether or what you should
	-- display in the tooltip.
	
	if not AucAdvanced.Settings.GetSetting("stat.simple.tooltip") then return end
	
	if not quantity or quantity < 1 then quantity = 1 end
	if not AucAdvanced.Settings.GetSetting("stat.simple.quantmul") then quantity = 1 end
	local dayAverage, avg3, avg7, avg14, minBuyout, avgmins, _, dayTotal, dayCount, seenDays, seenCount = lib.GetPrice(hyperlink)
	if (not dayAverage) then return end

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
			EnhTooltip.AddLine("  Min BO", minBuyout*quantity)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
		if (seenDays > 0) then
			EnhTooltip.AddLine("  Average MBO", avgmins*quantity)
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

	local pdata, temp
	for itemId, stats in pairs(data.daily) do
		if (itemId ~= "created") then
			pdata = private.UnpackStats(stats)
			fdata = private.UnpackStats(data.means[itemId] or "")
			for property, info in pairs(pdata) do
				dailyAvg = info[1] / info[2]
				if not fdata[property] then
					fdata[property] = acquire(
						1,
						info[2],
						("%0.01f"):format(dailyAvg),
						("%0.01f"):format(dailyAvg),
						("%0.01f"):format(dailyAvg),
						("%0.01f"):format(info[3])
					)
				else
					fdata[property][1] = fdata[property][1] + 1
					fdata[property][2] = fdata[property][2] + info[2]
					fdata[property][3] = ("%0.01f"):format(((fdata[property][3] * 2) + dailyAvg)/3)
					fdata[property][4] = ("%0.01f"):format(((fdata[property][4] * 6) + dailyAvg)/7)
					fdata[property][5] = ("%0.01f"):format(((fdata[property][5] * 13) + dailyAvg)/14)
					temp = fdata[property][6]
					if temp < info[3] then
						if (temp*10/info[3]) < 9 then
							fdata[property][6] = ("%0.01f"):format((temp+info[3])/2)
						else
							fdata[property][6] = ("%0.01f"):format((temp+info[3]*3)/4)
						end
					else
						if (info[3]*10/temp) < 9 then
							fdata[property][6] = ("%0.01f"):format((temp+info[3])/2)
						else
							fdata[property][6] = ("%0.01f"):format((temp*7+info[3])/8)
						end
					end
				end
			end
			data.means[itemId] = private.PackStats(fdata)
			recycle(pdata)
			recycle(fdata)
		end
	end
	recycle(data.daily)
	data.daily = acquire()
	data.daily.created = time()
end

function private.UnpackStatIter(data, ...)
	local c = select("#", ...)
	local v
	for i = 1, c do
		v = select(i, ...)
		local property, info = strsplit(":", v)
		property = tonumber(property) or property
		if (property and info) then
			data[property] = AucAdvanced.Acquire(strsplit(";", info))
			local item
			for i=1, #data[property] do
				item = data[property][i]
				data[property][i] = tonumber(item) or item
			end
		end
	end
end

function private.UnpackStats(dataItem)
	local data = AucAdvanced.Acquire() 
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
function private.UpgradeDb()
	if (not AucAdvancedStatSimpleData.Version) then
		local newData = {Version = "1.0", RealmData = {}}
		for x, y in pairs(AucAdvancedStatSimpleData) do
			local t = acquire(strsplit(x, "-"))
			local realm, faction
			for _, z in ipairs(t) do
				if (faction) then
					if (realm) then realm = realm.."-"..faction
					else realm = faction end
				end
				faction = z
			end
			if (not newData.RealmData[realm]) then
				newData.RealmData[realm] = acquire()
			end
			newData.RealmData[realm][faction] = y
			recycle(t)
		end
		AucAdvancedStatSimpleData = newData
	end
end


function private.LoadData()
	if (AAStatSimpleData) then return end
	if (not AucAdvancedStatSimpleData) then AucAdvancedStatSimpleData = {Version='1.0', RealmData = {}} end
	private.UpgradeDb()
	AAStatSimpleData = AucAdvancedStatSimpleData
	private.DataLoaded()
end

function private.ClearData(faction, realmName)
	if (not AAStatSimpleData) then private.LoadData() end
	faction = faction or AucAdvanced.GetFaction()
	if (realmName) then
		print("Clearing "..libName.." stats for {{"..faction.."}}")
	else
		realmName = GetRealmName()
		print("Clearing "..libName.." stats for {{"..faction.."}} on {{"..realmName.."}}")
	end
	if (AAStatSimpleData.RealmData[realmName] and AAStatSimpleData.RealmData[realmName][faction]) then
		AAStatSimpleData.RealmData[realmName][faction] = nil
	end
end

function private.GetPriceData(faction, realm)
	if (not AAStatSimpleData) then private.LoadData() end
	faction = faction or AucAdvanced.GetFaction()
	realm = realm or GetRealmName()
	if (not AAStatSimpleData.RealmData[realm]) then AAStatSimpleData.RealmData[realm] = {} end
	if (not AAStatSimpleData.RealmData[realm][faction]) then AAStatSimpleData.RealmData[realm][faction] = {} end
	return AAStatSimpleData.RealmData[realm][faction]
end

function private.DataLoaded()
	if (not AAStatSimpleData) then return end
	-- This function gets called when the data is first loaded. You may do any required maintenence
	-- here before the data gets used.
	for realm, realmdata in pairs(AAStatSimpleData.RealmData) do
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

AucAdvanced.RegisterRevision("$URL$", "$Rev$")