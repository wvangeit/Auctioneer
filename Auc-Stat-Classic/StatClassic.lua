--[[
	Auctioneer Advanced - AucClassic Statistics module
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

local libType, libName = "Stat", "Classic"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()

local data

function private.makeData()
	if data then return end
	if (not AucAdvancedStatClassicData) then AucAdvancedStatClassicData = {} end
	data = AucAdvancedStatClassicData
end

function lib.CommandHandler(command, ...)
	if (not data) then private.makeData() end
	local myFaction = AucAdvanced.GetFaction()
	if (command == "help") then
		print("Help for Auctioneer Advanced - "..libName)
		local line = AucAdvanced.Config.GetCommandLead(libType, libName)
		print(line, "help}} - this", libName, "help")
		print(line, "import}} - import prices from AucClassic")
	elseif (command == "import") then
		lib.Import(...)
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

function lib.GetPrice(hyperlink, ahKey)
	if (not data) then private.makeData() end
	local linkType,itemId,property,factor,enchant = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end
	if not ahKey then
		ahKey = AucAdvanced.GetFaction() 
	end
	ahKey = ahKey:lower()
	local median, seen, confidence = 0, 0, 0.1
	local lastdata
	local ItemString = strjoin(":",itemId,property,enchant)
	local a, b, c = 0,0,0
	if Auctioneer and Auctioneer.Statistic and Auctioneer.Statistic.GetUsableMedian then
		median, seen = Auctioneer.Statistic.GetUsableMedian(ItemString, ahKey)
		--print(median, seen)
		if median and (median > 0) then
			confidence = 1 - math.exp(-seen/30)
			private.StoreData(ItemString, median, seen, ahKey)
		end
	else
		if not data[ahKey] then return end
		if not data[ahKey][ItemString] then return end
		median, seen, lastdata = strsplit(",", data[ahKey][ItemString])
		median = tonumber(median)
		seen = tonumber(seen)
		lastdata = tonumber(lastdata)
		confidence = 1 - math.exp(-seen/30)
		local age = time()
		age = 2^((age - lastdata)/300000)
		confidence = confidence/(age) --half confidence every week
	end

	return median, seen, confidence
end

function lib.GetPriceColumns()
	return "Median","Seen", "Confidence"
end

local array = {}
function lib.GetPriceArray(hyperlink, ahKey, realm)
	-- Clean out the old array
	while (#array > 0) do table.remove(array) end

	-- Get our statistics
	local median, seen, confidence = lib.GetPrice(hyperlink, ahKey, realm)

	-- These 3 are the ones that most algorithms will look for
	array.price = median
	array.seen = seen
	array.confidence = confidence

	-- Return a temporary array. Data in this array is
	-- only valid until this function is called again.
	return array
end

AucAdvanced.Settings.SetDefault("stat.classic.tooltip", true)

function private.SetupConfigGui(gui)
	local id = gui:AddTab(lib.libName, lib.libType.." Modules")
	--gui:MakeScrollable(id)
	
	gui:AddHelp(id, "what classic stats",
		"What are Classic stats?",
		"Classic stats are imported from the AucClassic data")

	gui:AddControl(id, "Header",     0,    libName.." options")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.classic.tooltip", "Show classic stats in the tooltips?")
	gui:AddTip(id, "Toggle display of stats from the classic module on or off")
	
end

function lib.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost, ...)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine whether or what you should
	-- display in the tooltip.
	
	if not AucAdvanced.Settings.GetSetting("stat.classic.tooltip") then return end
	
	if not quantity or quantity < 1 then quantity = 1 end
	local median, seen, confidence = lib.GetPrice(hyperlink)

	if (median and median > 0) then
		EnhTooltip.AddLine("AucClassic price: (x"..quantity..")", median*quantity)
		EnhTooltip.LineColor(0.3, 0.9, 0.8)

		if (quantity > 1) then
			EnhTooltip.AddLine("  (or individually)", median)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
		EnhTooltip.AddLine("  Seen Count: |cffddeeff"..seen.."|r")
		EnhTooltip.LineColor(0.3, 0.9, 0.8)	
	end
end

function lib.OnLoad(addon)
	private.updater = CreateFrame("Frame", nil, UIParent)
	private.updater:SetScript("OnUpdate", private.OnUpdate)

	private.makeData()
end

function lib.ClearItem(hyperlink, ahKey, realm)
	local linkType, itemID, property, factor, enchant = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then
		return
	end
	local ItemString = strjoin(":",itemID,property,enchant)
	if not ahKey then ahKey = AucAdvanced.GetFaction() end
	ahKey = ahKey:lower()
	if not realm then realm = GetRealmName() end
	if (not data) then private.makeData() end
	if (data[ahKey]) then
		print(libType.."-"..libName..": clearing data for "..hyperlink.." for {{"..ahKey.."}}")
		data[ahKey][ItemString] = nil
	end
end

--[[ Local functions ]]--
local importstarted = false
function lib.ImportRoutine()
	importstarted = true
	if Auctioneer and Auctioneer.Statistic and Auctioneer.Statistic.GetUsableMedian then
		--local ahKey = AucAdvanced.GetFaction()
		--local ahKey = ahKey:lower()
		local ClassicData = {}
		if AuctioneerHistoryDB then
			ClassicData = AuctioneerHistoryDB
		else
			print("AuctioneerHistoryDB not found")
		end
		for ahKey, k in pairs(ClassicData) do
			if ClassicData[ahKey]["buyoutPrices"] then
				local i = 0
				print("Importing "..ahKey)
				for itemKey, v in pairs(ClassicData[ahKey]["buyoutPrices"]) do
					local median, seen = Auctioneer.Statistic.GetUsableMedian(itemKey, ahKey)
					if median and seen then
						private.StoreData(itemKey, median, seen, ahKey)
					end
					i = i + 1
					if ((i/200) == floor(i/200)) then
						if ((i/1000) == floor(i/1000)) then
							print("Auc-Stat-Classic: Imported "..i)--.." of "..#(ClassicData[ahKey]["buyoutPrices"]))
						end
						coroutine.yield()
					end
				end
				print("Auc-Stat-Classic: Finished importing "..i.." items for "..ahKey.." from AucClassic")
			else
				print("No data for "..ahKey.." available")
			end
		end
	else
		print("AucClassic must be loaded to import any data from it")
	end
	importstarted = false
end

local co = coroutine.create(lib.ImportRoutine)

function lib.Import()
	if (coroutine.status(co) ~= "suspended") then
		co = coroutine.create(lib.ImportRoutine)
	end
	if (coroutine.status(co) ~= "dead") then
		coroutine.resume(co)
	end
end

local flip, flop = false, false
function private.OnUpdate()
	if importstarted then
		if (coroutine.status(co) == "suspended") then
			flip = not flip
			if flip then
				flop = not flop
				if flop then
					lib.Import()
				end
			end
		end
	end
end

function private.DataLoaded()
	-- This function gets called when the data is first loaded. You may do any required maintenence
	-- here before the data gets used.

end


function private.StoreData(ItemString, median, seen, ahKey)
	if (not data) then private.makeData() end
	local now = time()
	if not ahKey then
		ahKey = AucAdvanced.GetFaction() 
	end
	ahKey = ahKey:lower()
	local PriceString = strjoin(",", median, seen, time())
	--print(PriceString)
	if not data[ahKey] then data[ahKey] = {} end
	data[ahKey][ItemString] = PriceString
end

