--[[
	Auctioneer Advanced
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
]]

AucAdvanced.API = {}
local lib = AucAdvanced.API
local private = {}

lib.Print = AucAdvanced.Print
local Const = AucAdvanced.Const
local recycle = AucAdvanced.Recycle
local acquire = AucAdvanced.Acquire
local clone = AucAdvanced.Clone

--[[
	The following functions are defined for modules's exposed methods:

	GetName()         (ALL*)  Should return this module's full name
	OnLoad()          (ALL*)  Receives load message for all modules
	Processor()       (ALL)   Processes messages sent by Auctioneer
	CommandHandler()  (ALL)   Slash command handler for this module
	ScanProcessor {}  (ALL)   Processes items from the scan manager
	GetPrice()        (STAT*) Returns estimated price for item link
	GetPriceColumns() (STAT)  Returns the column names for GetPrice
	StartScan()       (SCAN*) Begins an AH scan session
	IsScanning()      (SCAN*) Indicates an AH scan is in session
	AbortScan()       (SCAN)  Cancels the currently running scan
	Hook { }          (ALL)   Functions that are hooked by the module
    GetItemPDF()      (STAT*) Provides a probability distribution function for an item price


	Module type in parentheses to describe which ones provide.
	Possible Module Types are STAT, UTIL, SCAN.  ALL is a shorthand for all three.
	A * after the module type states the function is REQUIRED.

	Please visit http://norganna.org/wiki/Auctioneer/5.0/Modules_API for a
	more complete specification.
]]


--[[
	This function acquires the current market value of the mentioned item using
	a configurable algorithm to process the data used by the other installed
	algorithms.
	The result of this function does not take into account competition, it
	simply returns what a particular item is "Worth", and not what you could
	currently sell it for.

	AucAdvanced.API.GetMarketValue(itemLink, serverKey)
]]
function lib.GetMarketValue(itemLink, serverKey)
	-- TODO: Make a configurable algorithm.
	-- This algorithm is currently less than adequate.

	local total, count, seen = 0, 0, 0
	local weight, totalweight = 0, 0
	for engine, engineLib in pairs(AucAdvanced.Modules.Stat) do
		if not engineLib.CanSupplyMarket
		or engineLib.CanSupplyMarket(itemLink, serverKey) then
			weight = 0.25
			if (engineLib.GetPriceArray) then
				local array = engineLib.GetPriceArray(itemLink, serverKey)
				if (array and array.price and array.price > 0) then
					if array.confidence then
						weight = array.confidence
					end
					if (weight > 1) then weight = 1 end
					total = total + array.price * weight
					totalweight = totalweight + weight
					if (array.seen) and (array.seen > seen) then
						seen = array.seen
					end
					count = count + 1
				end
			elseif (engineLib.GetPrice) then
				local price = engineLib.GetPrice(itemLink, serverKey)
				if (price and price > 0) then
					total = total + price * weight
					totalweight = totalweight + weight
					count = count + 1
				end
			end
		end
	end
	if (total > 0) and (count > 0) then
		return total/totalweight, seen, count
	end
end

function lib.ClearItem(itemLink, serverKey)
	for engine, engineLib in pairs(AucAdvanced.Modules.Stat) do
		if engineLib.ClearItem then
			engineLib.ClearItem(itemLink, serverKey)
		end
	end
end

function lib.GetAlgorithms(itemLink)
	local engines = acquire()
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if engineLib.GetPrice or engineLib.GetPriceArray then
				if not engineLib.IsValidAlgorithm
				or engineLib.IsValidAlgorithm(itemLink) then
					table.insert(engines, engine)
				end
			end
		end
	end
	return engines
end

function lib.IsValidAlgorithm(algorithm, itemLink)
	local engines = acquire()
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if engine == algorithm and (engineLib.GetPrice or engineLib.GetPriceArray) then
				if engineLib.IsValidAlgorithm then
					return engineLib.IsValidAlgorithm(itemLink)
				end
				return true
			end
		end
	end
	return false
end

private.algorithmstack = acquire()
function lib.GetAlgorithmValue(algorithm, itemLink, faction, realm)
	if (not algorithm) then
		error("No pricing algorithm supplied")
	end
	if (not itemLink) then
		error("No itemLink supplied")
	end
	faction = faction or AucAdvanced.GetFaction()
	realm = realm or GetRealmName()
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if engine == algorithm and (engineLib.GetPrice or engineLib.GetPriceArray) then
				if engineLib.IsValidAlgorithm
				and not engineLib.IsValidAlgorithm(itemLink) then
					return
				end
				local algosig = strjoin(":", algorithm, itemLink, faction, realm)
				for pos, history in ipairs(private.algorithmstack) do
					if (history == algosig) then
						-- We are looping
						local origAlgo = private.algorithmstack[1]
						local endSize = #(private.algorithmstack)+1
						while (#(private.algorithmstack)) do
							table.remove(private.algorithmstack)
						end
						error(("Cannot solve price algorithm for: %s. (Recursion at level %d->%d: %s)"):format(origAlgo, algosig, endSize, pos))
					end
				end

				local price, seen, array
				table.insert(private.algorithmstack, algosig)
				if (engineLib.GetPriceArray) then
					array = engineLib.GetPriceArray(itemLink, faction, realm)
					if (array) then
						price = array.price
						seen = array.seen
					end
				else
					price = engineLib.GetPrice(itemLink, faction, realm)
				end
				table.remove(private.algorithmstack, -1)
				return price, seen, array
			end
		end
	end
	--error(("Cannot find pricing algorithm: %s"):format(algorithm))
	return
end


private.queryTime = 0
private.prevQuery = { empty = true }
private.curResults = acquire()
function lib.QueryImage(query, faction, realm, ...)
	local scandata = AucAdvanced.Scan.GetScanData(faction, realm)

	local prevQuery = private.prevQuery
	local curResults = private.curResults

	local invalid = false
	for k,v in pairs(prevQuery) do
		if k ~= "page" and v ~= query[k] then invalid = true end
	end
	for k,v in pairs(query) do
		if k ~= "page" and v ~= prevQuery[k] then invalid = true end
	end
	if (private.queryTime ~= scandata.time) then invalid = true end
	if not invalid then return curResults end

	local numResults = #curResults
	for i=1, numResults do curResults[i] = nil end
	for k,v in pairs(prevQuery) do prevQuery[k] = v end

	local ptr, max = 1, #scandata.image
	while ptr <= max do
		repeat
			local data = scandata.image[ptr] ptr = ptr + 1
			if (not data) then break end
			if bit.band(data[Const.FLAG] or 0, Const.FLAG_UNSEEN) == Const.FLAG_UNSEEN then break end
			if query.filter and query.filter(data, ...) then break end
			if query.link and data[Const.LINK] ~= query.link then break end
			if query.itemId and data[Const.ITEMID] ~= query.itemId then break end
			if query.suffix and data[Const.SUFFIX] ~= query.suffix then break end
			if query.factor and data[Const.FACTOR] ~= query.factor then break end
			if query.minUseLevel and data[Const.ULEVEL] < query.minUseLevel then break end
			if query.maxUseLevel and data[Const.ULEVEL] > query.maxUseLevel then break end
			if query.minItemLevel and data[Const.ILEVEL] < query.minItemLevel then break end
			if query.maxItemLevel and data[Const.ILEVEL] > query.maxItemLevel then break end
			if query.class and data[Const.ITYPE] ~= query.class then break end
			if query.subclass and data[Const.ISUB] ~= query.subclass then break end
			if query.quality and data[Const.QUALITY] ~= query.quality then break end
			if query.invType and data[Const.IEQUIP] ~= query.invType then break end
			if query.seller and data[Const.SELLER] ~= query.seller then break end
			if query.name then
				local name = data[Const.NAME]
				if not (name and name:lower():find(query.name:lower(), 1, true)) then break end
			end

			local stack = data[Const.COUNT]
			local nextBid = data[Const.PRICE]
			local buyout = data[Const.BUYOUT]
			if query.perItem and stack > 1 then
				nextBid = math.ceil(nextBid / stack)
				buyout = math.ceil(buyout / stack)
			end
			if query.minStack and stack < query.minStack then break end
			if query.maxStack and stack > query.maxStack then break end
			if query.minBid and nextBid < query.minBid then break end
			if query.maxBid and nextBid > query.maxBid then break end
			if query.minBuyout and buyout < query.minBuyout then break end
			if query.maxBuyout and buyout > query.maxBuyout then break end

			-- If we're still here, then we've got a winner
			table.insert(curResults, data)
		until true
	end

	private.queryTime = scandata.time
	return curResults
end

function lib.UnpackImageItem(item)
	return AucAdvanced.Scan.UnpackImageItem(item)
end

function lib.ListUpdate()
	if lib.IsBlocked() then return end
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.Processor) then
				engineLib.Processor("listupdate")
			end
		end
	end
end


function lib.BlockUpdate(block, propagate)
	local blocked
	if block == true then
		blocked = true
		private.isBlocked = true
		AuctionFrameBrowse:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
	else
		blocked = false
		private.isBlocked = nil
		AuctionFrameBrowse:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
	end

	if (propagate) then
		for system, systemMods in pairs(AucAdvanced.Modules) do
			for engine, engineLib in pairs(systemMods) do
				if (engineLib.Processor) then
					engineLib.Processor("blockupdate", blocked)
				end
			end
		end
	end
end

function lib.IsBlocked()
	return private.isBlocked == true
end

--Market matcher APIs
private.matcherlist = AucAdvanced.Settings.GetSetting("matcherlist")
function lib.GetBestMatch(itemLink, algorithm, faction, realm)
	-- TODO: Make a configurable algorithm.
	-- This algorithm is currently less than adequate.

	local matchers = lib.GetMatchers(itemLink)
	local total, count, diff, _ = 0, 0, 0

	faction = faction or AucAdvanced.GetFaction()
	realm = realm or GetRealmName()
	local priceArray = {}
	
	if algorithm == "market" then
		priceArray.price, priceArray.seen = lib.GetMarketValue(itemLink, faction, realm)
	elseif type(algorithm) == "string" then
		_, _, priceArray = lib.GetAlgorithmValue(algorithm, itemLink, faction, realm)
	else
		priceArray.price = algorithm
	end
		
	local InfoString = ""
	if not priceArray or not priceArray.price then return end
	for index, matcher in ipairs(matchers) do
		if lib.IsValidMatcher(matcher, itemLink) then
			local value, MatchpriceArray = lib.GetMatcherValue(matcher, itemLink, priceArray.price)
			priceArray.price = value
			count = count + 1
			diff = diff + MatchpriceArray.diff
			if MatchpriceArray.returnstring then
				InfoString = strjoin("\n", InfoString, MatchpriceArray.returnstring)
			end
		end
	end
	
	if (priceArray.price > 0) then
		return priceArray.price, total, count, diff/count, InfoString
	end
end

function lib.GetMatcherDropdownList()
	private.matcherlist = AucAdvanced.Settings.GetSetting("matcherlist")
	if not private.matcherlist or #private.matcherlist == 0 then 
		lib.GetMatchers() 
	end
	if not private.matcherlist or #private.matcherlist == 0 then
		return
	end
	local dropdownlist = {}
	for index, value in ipairs(private.matcherlist) do
		dropdownlist[index] = tostring(index)..": "..tostring(private.matcherlist[index])
	end
	return dropdownlist
end

function lib.GetMatchers(itemLink)
	private.matcherlist = AucAdvanced.Settings.GetSetting("matcherlist")
	local engines = acquire()
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if engineLib.GetMatchArray then
				if not engineLib.IsValidMatcher
				or engineLib.IsValidMatcher(itemLink) then
					table.insert(engines, engine)
				end
			end
		end
	end
	local insetting = false
	local stillactive = false
	--check to see if there are any new matchers.  If so, add them to the end of the running order.
	--There is no check to see if matchers are missing, as this would destroy the saved order.  Instead, invalid matchers can be called without errors.
	if private.matcherlist then
		for index, matcher in ipairs(engines) do
			for i, j in ipairs(private.matcherlist) do
				if matcher == j then insetting = true
				end
			end
			if not insetting then
				AucAdvanced.Print("AucAdvanced: New matcher found: "..tostring(matcher))
				table.insert(private.matcherlist, matcher)
			end
			insetting = false
		end
	else
		private.matcherlist = engines
	end
	AucAdvanced.Settings.SetSetting("matcherlist", private.matcherlist)
	return private.matcherlist
end

function lib.IsValidMatcher(matcher, itemLink)
	local engines = acquire()
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if engine == matcher and engineLib.GetMatchArray then
				if engineLib.IsValidMatcher then
					return engineLib.IsValidMatcher(itemLink)
				end
				return engineLib
			end
		end
	end
	return false
end

function lib.GetMatcherValue(matcher, itemLink, price)
	if (type(matcher) == "string") then
		matcher = lib.IsValidMatcher(matcher, itemLink)
	end
	if not matcher then return end
	--If matcher is not a table at this point, the following code will throw an "attempt to index a <something> value" type error
	local matchArray = matcher.GetMatchArray(itemLink, price)
	if not matchArray then
		matchArray = {}
		matchArray.value = price
		matchArray.diff = 0
	end

	return matchArray.value, matchArray
end


-- Allows the return of Appraiser price values to other functions.
-- If Appraiser is not loaded it uses Market Price
function lib.GetAppraiserValue(itemLink, useMatching)	
	local newBuy, newBid, _, seen, curModelText, MatchString, stack, number, duration
	if not AucAdvanced.Modules.Util.Appraiser then
		newBuy, seen = AucAdvanced.API.GetMarketValue(itemLink)
		curModelText = "Market"
		return newBuy, newBuy, seen, curModelText
	end
	
	newBuy, newBid, _, seen, curModelText, MatchString, stack, number, duration = AucAdvanced.Modules.Util.Appraiser.GetPrice(itemLink, 0, useMatching)
	lib.ShowDeprecationAlert("AucAdvanced.Modules.Util.Appraiser.GetPrice(itemLink, _, useMatching)");
    
	return newBid, newBuy, seen, curModelText, MatchString, stack, number, duration
end


-------------------------------------------------------------------------------
-- Statistical devices created by Matthew 'Shirik' Del Buono
-- For Auctioneer Advanced
-------------------------------------------------------------------------------
local sqrtpi = math.sqrt(math.pi);
local sqrtpiinv = 1/sqrtpi;
local sq2pi = math.sqrt(2*math.pi);
local pi = math.pi;
local exp = math.exp;
local bellCurveMeta = {
    __index = {
        SetParameters = function(self, mean, stddev)
            self.mean = mean;
            self.stddev = stddev;
            self.param1 = 1/(stddev*sq2pi);     -- Make __call a little faster where we can
            self.param2 = 2*stddev^2;
        end
    },
    -- Simple bell curve call
    __call = function(self, x)
        return self.param1*exp(-(x-self.mean)^2/self.param2);
    end
}
-------------------------------------------------------------------------------
-- Creates a bell curve object that can then be manipulated to pass
-- as a PDF function. This is a recyclable object -- the mean and 
-- standard deviation can be updated as necessary so that it does not have
-- to be regenerated
--
-- Note: This creates a bell curve with a standard deviation of 1 and 
-- mean of 0. You will probably want to update it to your own desired
-- values by calling return:SetParameters(mean, stddev)
-------------------------------------------------------------------------------
function lib.GenerateBellCurve()
    return setmetatable({mean=0, stddev=1, param1=sqrtpiinv, param2=2}, bellCurveMeta);
end


--[[===========================================================================
--|| Deprecation Alert Functions
--||=========================================================================]]
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
            
            -- Display it            
            AucAdvanced.Print(
                "Auctioneer Advanced: "..
                functionName .. " has been deprecated and was called by |cFF9999FF"..caller:match("^(.+)%.[lLxX][uUmM][aAlL]:").."|r. "..
                (replacementName and ("Please use "..replacementName.." instead. ") or "")..
                (comments or "")
            );
        end
        

        -- Always call this to keep count accurate
        Swatter.OnError(
            "Deprecated function call occurred in AuctioneerAdvanced API:\n     {{{Deprecated Function:}}} "..functionName..
                "\n     {{{Source Module:}}} "..source:match("^(.+)%.[lLxX][uUmM][aAlL]:")..
                "\n     {{{Calling Module:}}} "..caller:match("^(.+)%.[lLxX][uUmM][aAlL]:")..
                "\n     {{{Available Replacement:}}} "..replacementName..
                "\n\n"..
                (comments and comments.."\n\n" or ""),
            nil,
            debugstack(2)
        );


        
        
    end
    
end



AucAdvanced.RegisterRevision("$URL$", "$Rev$")
