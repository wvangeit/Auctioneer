--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	BeanCounterSearch - Search routines for BeanCounter data
	URL: http://auctioneeraddon.com/

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
		You have an implicit license to use this AddOn with these facilities
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]
LibStub("LibRevision"):Set("$URL$","$Rev$","5.1.DEV.", 'auctioneer', 'libs')

local lib = BeanCounter
local private, print, get, set, _BC = lib.getLocals()

local function debugPrint(...)
    if get("util.beancounter.debugSearch") then
        private.debugPrint("BeanCounterSearch",...)
    end
end


local data = {}
local style = {}
local temp ={}
local tbl = {}

--This is all handled by ITEMIDS need to remove/rename this to be a utility to convert text searches to itemID searches
function private.startSearch(itemName, settings, queryReturn, count, itemTexture) --queryReturn is passed by the externalsearch routine, when an addon wants to see what data BeanCounter knows
	--Run the compression function once per session, use first search as trigger
	--Check the postedDB tables and remove any entries that are older than 31 Days
	if not private.compressed then private.refreshItemIDArray() private.sortArrayByDate() private.compactDB() private.prunePostedDB() private.sumDatabase() private.compressed = true end

	if not itemName then return end
	if not settings then settings = private.getCheckboxSettings() end

	tbl = {}
	for itemKey, data in pairs(BeanCounterDB["ItemIDArray"]) do
		if data:lower():find(itemName:lower(), 1, true)  then
			if settings.exact and private.frame.searchBox:GetText() ~= "" then --if the search field is blank do not exact check
				local _, name = strsplit(";", data)
				if itemName:lower() == name:lower() then
					local itemID, suffix = string.split(":", itemKey)--Create a list of itemIDs that match the search text
					settings.suffix = suffix -- Store Suffix used to later filter unwated results from the itemID search
					tbl[itemID] = itemID --Since its possible to have the same itemID returned multiple times this will only allow one instance to be recorded
					break
				end
			else
				local itemID = string.split(":", itemKey)--Create a list of itemIDs that match the search text
				tbl[itemID] = itemID --Since its possible to have the same itemID returned multiple times this will only allow one instance to be recorded
			end
		end
	end

	if queryReturn then --need to return the ItemID results to calling function
		return(private.searchByItemID(tbl, settings, queryReturn, count, itemTexture, itemName))
	else
		--get the itemTexture for display in the drop box
		for i, data in pairs(BeanCounterDB.ItemIDArray) do
			local _, name = strsplit(";", data)
			if name:lower() == itemName:lower() then
				local itemID = strsplit(":", i) or ""
				itemTexture = select(2, private.getItemInfo(itemID, "name"))
				break
			end
		end
		private.searchByItemID(tbl, settings, queryReturn, count, itemTexture, itemName)
	end
end


function private.searchByItemID(id, settings, queryReturn, count, itemTexture, classic)
	if not id then return end
	if not settings then settings = private.getCheckboxSettings() end
	if not count then count = get("numberofdisplayedsearchs") end --count determines how many results we show or display High # ~to display all

	tbl = {}
	if type(id) == "table" then --we can search for a sinlge itemID or an array of itemIDs
		for i,v in pairs(id)do
			table.insert(tbl, tostring(v))
		end
	else
		tbl[1] = tostring(id)
	end
	
	data = {}
	style = {}
	data.temp = {}
	data.temp.completedAuctions = {}
	data.temp["completedBids/Buyouts"] = {}
	data.temp.failedAuctions = {}
	data.temp.failedBids = {}
		
	if settings.servers then
		for index, serverName in ipairs(settings.servers)do		
			data = private.searchServerData(serverName, data, tbl, settings)
			if data then
				data, style = private.formatServerData(data, style, settings, count)
				data.temp = nil --remove the temp
			end
			
			settings.servers[index] = data
			--clear refrence to stored data --really needs to be cleaner
			data = {}
			data.temp = {}
			data.temp.completedAuctions = {}
			data.temp["completedBids/Buyouts"] = {}
			data.temp.failedAuctions = {}
			data.temp.failedBids = {}
		end
	else
		local serverName = GetRealmName()
		data = private.searchServerData(serverName, data, tbl, settings)
		if data then
			data, style = private.formatServerData(data, style, settings, count)
		end
	end
		
	if not queryReturn then --this lets us know it was not an external addon asking for beancounter data
		private.frame.resultlist.sheet:SetData(data, style) --Set the GUI scrollsheet
		
		--Adds itemtexture to display box and if possible the gan/loss on teh item
		if itemTexture then
			private.frame.icon:SetNormalTexture(itemTexture)
			local profit, low, high
			--Since a "" or full DB search takes a lot of time just pass teh already compiled data table for 48k trxn this means 0.24sec vs 8.5sec
			--However this lmits it to ONLY the results displayed in the scrollframe not entire DB
			if classic == "" then
				profit, low, high = lib.API.getAHProfit(nil, data) 
			else
				profit, low, high = lib.API.getAHProfit(nil, classic)
			end
			local change = "|CFF33FF33Gained"
			if profit < 0 then change = "|CFFFF3333Lost" profit = math.abs(profit) end-- if profit negative  ABS to keep tiplib from missrepresenting #
			profit = private.tooltip:Coins(profit)
			private.frame.slot.help:SetTextColor(.8, .5, 1)
			private.frame.slot.help:SetText(change..(" %s from %s to %s"):format(profit or "", date("%x", low) or "", date("%x", high) or ""))
		else
			private.frame.icon:SetNormalTexture(nil)
			private.frame.slot.help:SetTextColor(1, 0.8, 0)
			private.frame.slot.help:SetText(_BC('HelpGuiItemBox')) --"Drop item into box to search."
		end
		
		return data, style
	else --If Query return is true but not == to "none" then we return a formated table
		if settings.servers then
			return settings.servers[1], settings.servers[2], settings.servers[3], settings.servers[4]
		else
			return data
		end
	end
end
--Helper functions for the Search
function private.searchServerData(serverName, data, tbl, settings)
	local server = BeanCounterDB[serverName]
	if not server then return end
	--check servers are at least at current DB format.
	for _, player in pairs(server) do
		if player.version ~= private.version then
			assert(nil, "The data for "..serverName.." is not at the current BeanCounter DB version of "..private.version.." Please log into this realm to upgrade BeanCounters Data.")
			return
		end
		break
	end
		
	--Retrives all matching results
	for i in pairs(server) do
		if settings.selectbox[2] == "alliance" and server[i]["faction"] and server[i]["faction"]:lower() ~= settings.selectbox[2] then
			--If looking for alliance and player is not alliance fall into this null
		elseif settings.selectbox[2] == "horde" and server[i]["faction"] and server[i]["faction"]:lower() ~= settings.selectbox[2] then
			--If looking for horde and player is not horde fall into this null
		elseif (settings.selectbox[2] ~= "server" and settings.selectbox[2] ~= "alliance" and settings.selectbox[2] ~= "horde") and i ~= settings.selectbox[2] then
			--If we are not doing a whole server search and the chosen search player is not "i" then we fall into this null
			--otherwise we search the server or toon as normal
		else
			for _, id in pairs(tbl) do
				if settings.auction and server[i]["completedAuctions"][id] then
					for index, itemKey in pairs(server[i]["completedAuctions"][id]) do
						for _, text in ipairs(itemKey) do
							table.insert(data.temp.completedAuctions, {i, id, index,text})
						end
					end
				end
				if settings.failedauction and server[i]["failedAuctions"][id] then
					for index, itemKey in pairs(server[i]["failedAuctions"][id]) do
						for _, text in ipairs(itemKey) do
							table.insert(data.temp["failedAuctions"], {i, id, index,text})
						end
					end
				end
				if settings.bid and server[i]["completedBids/Buyouts"][id] then
					for index, itemKey in pairs(server[i]["completedBids/Buyouts"][id]) do
						for _, text in ipairs(itemKey) do
							table.insert(data.temp["completedBids/Buyouts"], {i, id, index,text})
						end
					end
				end
				if settings.failedbid and server[i]["failedBids"][id] then
					for index, itemKey in pairs(server[i]["failedBids"][id]) do
						for _, text in ipairs(itemKey) do
							table.insert(data.temp.failedBids, {i, id, index,text})
						end

					end
				end
			end
		end
	end
	return data
end
--take collected data and format
function private.formatServerData(data, style, settings, count)
	--reduce results to the latest XXXX ammount based on how many user wants returned or displayed
	if #data.temp.completedAuctions > count then
		data.temp.completedAuctions = private.reduceSize(data.temp.completedAuctions, count)
	end
	if #data.temp.failedAuctions > count then
		data.temp.failedAuctions = private.reduceSize(data.temp.failedAuctions, count)
	end
	if #data.temp["completedBids/Buyouts"] > count then
		data.temp["completedBids/Buyouts"] = private.reduceSize(data.temp["completedBids/Buyouts"], count)
	end
	if #data.temp.failedBids > count then
		data.temp.failedBids = private.reduceSize(data.temp.failedBids, count)
	end

	--Format Data for display via scroll private.frame or if requesting addon wants formated data
	local dateString = get("dateString") or "%c"
	for i,v in pairs(data.temp.completedAuctions) do
		local match = true
		--to provide exact match filtering for of the tems we compare names to the itemKey on API searches
		if settings.exact and settings.suffix then
			if v[3]:match(".*:("..settings.suffix.."):.-") then
				-- do nothing and add item to data table
			else
				match = false --we want exact matches and this is not one
			end
		end

		if match then
			table.insert(data, private.COMPLETEDAUCTIONS(v[2], v[3], v[4], settings))
			if not queryReturn then --do not create style tables if this data is being returned to an addon
				style[#data] = {}
				if get("colorizeSearch") then style[#data][1] = {["rowColor"] = {0.3, 0.9, 0.8, 0, get("colorizeSearchopacity") or 0, "Horizontal"}} end
				style[#data][12] = {["date"] = dateString}
				style[#data][2] = {["textColor"] = {0.3, 0.9, 0.8}}
				style[#data][8] ={["textColor"] = {0.3, 0.9, 0.8}}
			end
		end
	end
	for i,v in pairs(data.temp.failedAuctions) do
		local match = true
		--to provide exact match filtering for of the tems we compare names to the itemKey on API searches
		if settings.exact and settings.suffix then
			if v[3]:match(".*:("..settings.suffix.."):.-") then
				-- do nothing and add item to data table
			else
				match = false --we want exact matches and this is not one
			end
		end

		if match then
			table.insert(data, private.FAILEDAUCTIONS(v[2], v[3], v[4]))
			if not queryReturn then
				style[#data] = {}
				if get("colorizeSearch") then style[#data][1] = {["rowColor"] = {1, 0, 0, 0, get("colorizeSearchopacity") or 0, "Horizontal"}} end
				style[#data][12] = {["date"] = dateString}
				style[#data][2] = {["textColor"] = {1,0,0}}
				style[#data][8] ={["textColor"] = {1,0,0}}
			end
		end
	end
	for i,v in pairs(data.temp["completedBids/Buyouts"]) do
		local match = true
		--to provide exact match filtering for of the tems we compare names to the itemKey on API searches
		if settings.exact and settings.suffix then
			local _, suffix = lib.API.decodeLink(v[3])
			if suffix == settings.suffix then
				-- do nothing and add item to data table
			else
				match = false
			end
		end

		if match then
			table.insert(data, private.COMPLETEDBIDSBUYOUTS(v[2], v[3], v[4]))
			if not queryReturn then
				style[#data] = {}
				if get("colorizeSearch") then style[#data][1] = {["rowColor"] = {1, 1, 0, 0, get("colorizeSearchopacity") or 0, "Horizontal"}} end
				style[#data][12] = {["date"] = dateString}
				style[#data][2] = {["textColor"] = {1,1,0}}
				style[#data][8] ={["textColor"] = {1,1,0}}
			end
		end
	end
	for i,v in pairs(data.temp.failedBids) do
		local match = true
		--to provide exact match filtering for of the tems we compare names to the itemKey on API searches
		if settings.exact and settings.suffix then
			if v[3]:match(".*:("..settings.suffix.."):.-") then
				-- do nothing and add item to data table
			else
				match = false --we want exact matches and this is not one
			end
		end

		if match then
			table.insert(data, private.FAILEDBIDS(v[2], v[3], v[4]))
			if not queryReturn then
				style[#data] = {}
				if get("colorizeSearch") then style[#data][1] = {["rowColor"] = {1, 1, 1, 0, get("colorizeSearchopacity") or 0, "Horizontal"}} end
				style[#data][12] = {["date"] = dateString}
				style[#data][2] = {["textColor"] = {1,1,1}}
				style[#data][8] ={["textColor"] = {1,1,1}}
			end
		end
	end
	
	return data, style
end

function private.reduceSize(tbl, count)
	--The data provided is from multiple toons tables, so we need to resort the merged data back into sequential time order
	table.sort(tbl, function(a,b) return a[4]:match(".*;(%d+);.-") > b[4]:match(".*;(%d+);.-") end)
	tbl.sort = {}
	for i = 1, count do
		table.insert(tbl.sort, tbl[i])
	end
	return tbl.sort
end

--To simplify having two seperate search routines, the Data creation of each table has been made a local function
	function private.COMPLETEDAUCTIONS(id, itemKey, text) --this passes the player, itemID and text as string or as an already seperated table
			local uStack, uMoney, uDeposit , uFee, uBuyout , uBid, uSeller, uTime, uReason = private.unpackString(text)
			local pricePer = 0
			local stack = tonumber(uStack) or 0
			if stack > 0 then pricePer =  (uMoney - uDeposit + uFee)/stack end
			
			local itemID, suffix = lib.API.decodeLink(itemKey)
			local itemLink =  lib.API.createItemLinkFromArray(itemID..":"..suffix)

			if not itemLink then itemLink = private.getItemInfo(id, "name") end--if not in our DB ask the server

			return({
				itemLink or "Failed to get Link", --itemname
				_BC('UiAucSuccessful'), --status

				tonumber(uBid) or 0,  --bid
				tonumber(uBuyout) or 0,  --buyout
				tonumber(uMoney), --Profit,
				tonumber(stack),  --stacksize
				tonumber(pricePer), --Profit/per

				uSeller,  --seller/seller

				tonumber(uDeposit), --deposit
				tonumber(uFee), --fee
				uReason, --reason bought
				tonumber(uTime), --time, --Make this a user choosable option.
			})
	end
	--STACK; BUY; BID; DEPOSIT; TIME; DATE; WEALTH
	function private.FAILEDAUCTIONS(id, itemKey, text)
			local uStack, uMoney, uDeposit , uFee, uBuyout , uBid, uSeller, uTime, uReason = private.unpackString(text)
			
			local itemID, suffix = lib.API.decodeLink(itemKey)
			local itemLink =  lib.API.createItemLinkFromArray(itemID..":"..suffix)
			if not itemLink then itemLink = private.getItemInfo(id, "name") end--if not in our DB ask the server

			return({
				itemLink, --itemname
				_BC('UiAucExpired'), --status

				tonumber(uBid) or 0, --bid
				tonumber(uBuyout) or 0, --buyout
				0, --money,
				tonumber(uStack) or 0,
				0, --Profit/per

				"...",  --seller/buyer

				tonumber(uDeposit) or 0, --deposit
				0, --fee
				uReason, --reason bought
				tonumber(uTime), --time, --Make this a user choosable option.
			})
	end
	function private.COMPLETEDBIDSBUYOUTS(id, itemKey, text)
			--local value = "stack"], "money"], p"fee"], buyout"], "bid"], p"Seller/buyer"], ["time"], reason)
		
			local uStack, uMoney, uDeposit , uFee, uBuyout , uBid, uSeller, uTime, uReason = private.unpackString(text)
			
			--print("S=", uStack, "M=",uMoney, "D=",uDeposit , "F=",uFee, "Buy=",uBuyout , "Bid=",uBid, "Sell=",uSeller, "T=",uTime, "R=",uReason)
			
			local pricePer, stack, text = 0, tonumber(uStack), _BC('UiWononBuyout')
			--If the auction was won on bid change text, and adjust ProfitPer
			if uBuyout ~= uBid then
				text = _BC('UiWononBid')
				if stack > 0 then pricePer = (uBid - uMoney + uFee)/stack end
			else --Devide by BUY price if it was won on Buy
				if stack > 0 then pricePer = (uBuyout - uMoney + uFee)/stack end
			end

			local itemID, suffix = lib.API.decodeLink(itemKey)
			local itemLink =  lib.API.createItemLinkFromArray(itemID..":"..suffix)
			if not itemLink then itemLink = private.getItemInfo(id, "name") end--if not in our DB ask the server

			return({
				itemLink, --itemname
				text, --status

				tonumber(uBid), --bid
				tonumber(uBuyout), --buyout
				0, --money,
				tonumber(stack),  --stacksize
				tonumber(pricePer), --Profit/per

				uSeller,   --seller/buyer

				tonumber(uDeposit), --deposit
				tonumber(uFee), --fee
				uReason, --reason bought
				tonumber(uTime), --time, --Make this a user choosable option.
			})
	end
	function private.FAILEDBIDS(id, itemKey, text)
			
			local uStack, uMoney, uDeposit , uFee, uBuyout , uBid, uSeller, uTime, uReason = private.unpackString(text)
			
			local itemID, suffix = lib.API.decodeLink(itemKey)
			local itemLink =  lib.API.createItemLinkFromArray(itemID..":"..suffix)
			if not itemLink then itemLink = private.getItemInfo(id, "name") end--if not in our DB ask the server

			return({
				itemLink, --itemname
				_BC('UiOutbid'), --status

				tonumber(uBid), --bid
				0, --buyout
				tonumber(uMoney), --money,
				tonumber(uStack), --stack
				0, --Profit/per

				uSeller,  --seller/buyer

				tonumber(uDeposit), --deposit
				tonumber(uFee), --fee
				tonumber(uReason), --reason bought
				tonumber(uTime), --time, --Make this a user choosable option.
			})
	end
