--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	BeanCounterAPI - Functions for other addons to get BeanCounter Data
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
		You have an implicit licence to use this AddOn with these facilities
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

local lib = BeanCounter
lib.API = {}

local private = lib.Private
local print =  BeanCounter.Print
local _BC = private.localizations

local function debugPrint(...) 
    if private.getOption("util.beancounter.debugAPI") then
        private.debugPrint("BeanCounterAPI",...)
    end
end
--[[External Search Stub, allows other addons searches to search to display in BC or get results of a BC search
Can be item Name or Link or itemID 
If itemID or Link search will be faster than a plain text lookup
]]
local SearchRequest = {}
function lib.API.search(name, settings, queryReturn, count)
	if private.getOption("util.beancounter.externalSearch") then --is option enabled and have we already searched for this name (stop spam)
		--lets create a cache of the last search
		if SearchRequest[name] then
			name = name:gsub("|", "-")
			debugPrint("Cached search results returned", name, time())
			return(SearchRequest[1])
		else
			SearchRequest = {}
			SearchRequest[name] = 0
		end
		
		--the function getItemInfo will return a plain text name on itemID or itemLink searches and nil if a plain text search is passed
		local itemName, itemLink = private.getItemInfo(name, "itemid")
		if not itemLink then itemName, itemLink = tostring(name) end
		
		if not settings then
			settings = {["selectbox"] = {"1","server"}  , ["exact"] = false, ["classic"] = private.frame.classicCheck:GetChecked(), 
						["bid"] = true, ["outbid"] = private.frame.bidFailedCheck:GetChecked(), ["auction"] = true,
						["failedauction"] = private.frame.auctionFailedCheck:GetChecked() 
						}
		end
		--search data
		if itemLink then
			--itemKey is used to filter results if exact is used. We need the key to remove of the XXX style items from returns
			settings.itemKey = itemLink:match("item:.+:(.-):.-%[.-%]")
			if settings.itemKey == 0 then settings.itemKey = nil end
			SearchRequest[1] = private.searchByItemID(itemName, settings, queryReturn, count)
		else
			SearchRequest[1] = private.startSearch(itemName, settings, queryReturn, count)
		end
		--return data or displayItemName in select box
		if queryReturn then 
			return(SearchRequest[1])
		else
			if itemLink then
				private.frame.searchBox:SetText(itemLink:match("^|c%x+|H.+|h%[(.+)%]"))
			else
				private.frame.searchBox:SetText(itemName)
			end
		end
	end	
end

--[[ Returns the Sum of all AH sold vs AH buys along with the date range
If no player name is supplied then the entire server profit will be totaled
if no item name is provided then all items will be returned
if no date range is supplied then a sufficently large range to cover the entire BeanCounter History will be used. 
]]
function lib.API.getAHProfit(player, item, lowDate, highDate)
	if not player or player == "" then player = "server" end
	if not item then item = "" end

	local sum, high, low, number =  0, 0198796618, 2198796618 --high and low are date ranges that will always fall out of the BeanCounters range of Dates 
	local settings = {["selectbox"] = {"1", player} , ["bid"] =true, ["auction"] = true}
	local tbl = private.startSearch(item, settings, "none")
	
	for i,v in pairs(tbl.completedAuctions) do
		local Time = tonumber(v[5])
		number = tonumber(v[3]:match(".-;.-;.-;.-;.-;(.-);.*")) or 0
		--Allow the user to filter a time range to look at 
		if lowDate and highDate then
			if Time >= lowDate and Time <= highDate then  
				sum = sum + number
			end
		else --if no date ranges are supplied we find the min and max dates in the Database and return them as the range
			if Time > high then high = Time elseif Time < low then low = Time end 
			sum = sum + number
		end
	end
	for i,v in pairs(tbl["completedBids/Buyouts"]) do
		local Time = tonumber(v[5])
		number = tonumber(v[3]:match(".-;.-;.-;.-;.-;.-;(.-);.*")) or 0
		if lowDate and highDate then
			if Time >= lowDate and Time <= highDate then  
				sum = sum - number
			end
		else
			if Time > high then high = Time elseif Time < low then low = Time end
			sum = sum - number
		end
	end
	return sum, lowDate or low, highDate or high
end

--[[This will return profits in date segments  allow easy to create graphs
Similar to API.getProfit()  This utility return a table containing the profit earned in day based segments. useful for graphing a change over time
example: entering (player, "arcane dust", 7) would return the the profit for arcane dust in 7 day segments starting from most recent to oldest
]]
function lib.API.getAHProfitGraph(player, item ,days)
	if not player or player == "" then player = "server" end
	if not item then item = "" end
	if not days then days = 7 end
	--Get data from BeanCounter 
	local settings = {["selectbox"] = {"1", player} , ["bid"] =true, ["auction"] = true} 
	local tbl = private.startSearch(item, settings, "none") 
	--Merge and edit provided table to needed format
	for i,v in pairs(tbl) do
		for a,b in pairs(v) do
			table.insert(tbl, b)
		end
	end
	--remove now redundant table entries
	tbl.completedAuctions, tbl["completedBids/Buyouts"], tbl.failedAuctions, tbl.failedBids = nil, nil, nil, nil
	--check if we actually have any results from the search
	if #tbl == 0 then return {0}, 0, 0 end
	--sort by date
	table.sort(tbl, function(a,b) return a[5] > b[5] end)
	--get min and max dates.	
	local high, low, count, sum, number = tbl[1][5], tbl[#tbl][5], 1, 0, 0
	local range = high - (days* 86400)
	
	tbl.sums = {}
	tbl.sums[count] = {}
	for i,v in ipairs(tbl) do
		if tonumber(v[5]) >= range then
			if v[4] == "Auction successful" then
				number = tonumber(v[3]:match(".-;.-;.-;.-;.-;(.-);.*")) or 0
				sum = sum + number
			elseif v[4] == "Auction won" then
				number = tonumber(v[3]:match(".-;.-;.-;.-;.-;.-;(.-);.*")) or 0
				sum = sum - number
			end 
			tbl.sums[count] = sum	
		else
			count = count + 1
			range = range - (days * 86400)
			tbl.sums[count] = {}
			sum = 0
			if v[4] == "Auction successful" then
				number = tonumber(v[3]:match(".-;.-;.-;.-;.-;(.-);.*")) or 0
				sum = sum + number
			elseif v[4] == "Auction won" then
				number = tonumber(v[3]:match(".-;.-;.-;.-;.-;.-;(.-);.*")) or 0
				sum = sum - number
			end 
			tbl.sums[count] = sum
		end
	end
	return tbl.sums, low, high
end

--[[ Retrives the itemLink from the name array when passed an itemKey
we store itemKeys with a unique ID but our name array does not
]]
function lib.API.getItemLink(itemString)
	itemID, key = itemString:match("item:(.-):.*:(.-):.-")
	if BeanCounterDB.ItemIDArray[itemID..":"..key] then 
		return BeanCounterDB.ItemIDArray[itemID..":"..key]
	end
	debugPrint("Searching DB for ItemID..", key, itemID, "Failed Item does not exist")
	return nil
end

--[[===========================================================================
--|| Deprecation Alert Functions
--||=========================================================================]]
 --Ths function was created by Shirik all thanks and blame go to him :P
do
	local SOURCE_PATTERN = "([^\\/:]+:%d+): in function `([^\"']+)[\"']";
	local seenCalls = {};
	local uid = 0;
	-------------------------------------------------------------------------------
	-- Shows a deprecation alert. Indicates that a deprecated function has
	-- been called and provides a stack trace that can be used to help
	-- find the culprit.
	-- @param replacementName (Optional) The displayable name of the replacement function
	-- @param comments (Optional) Any extra text to display
	-------------------------------------------------------------------------------
	function lib.ShowDeprecationAlert(replacementName, comments)
		local caller, source, functionName =
		debugstack(3):match(SOURCE_PATTERN),        -- Keep in mind this will be truncated to only the first in the tuple
		debugstack(2):match(SOURCE_PATTERN);        -- This will give us both the source and the function name
		
		functionName = functionName .. "()";
			
		-- Check for this source & caller combination
		seenCalls[source] = seenCalls[source] or {};
		if not seenCalls[source][caller] then
			-- Not warned yet, so warn them!
			seenCalls[source][caller]=true
			-- Display it
			debugPrint(
			"Auctioneer Advanced: "..
			functionName .. " has been deprecated and was called by |cFF9999FF"..caller:match("^(.+)%.[lLxX][uUmM][aAlL]:").."|r. "..
				(replacementName and ("Please use "..replacementName.." instead. ") or "")..
				(comments or "")
				);
				geterrorhandler()(
				"Deprecated function call occurred in AuctioneerAdvanced API:\n     {{{Deprecated Function:}}} "..functionName..
				"\n     {{{Source Module:}}} "..source:match("^(.+)%.[lLxX][uUmM][aAlL]:")..
				"\n     {{{Calling Module:}}} "..caller:match("^(.+)%.[lLxX][uUmM][aAlL]:")..
				"\n     {{{Available Replacement:}}} "..replacementName..
				(comments and "\n\n"..comments or "")
				)
		end
		
	end
			
end