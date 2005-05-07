-- Auctioneer
AUCTIONEER_VERSION="<%version%>";
-- Revision: $Id$
-- Written by Norganna
--
-- This is an addon for World of Warcraft that works in combination with 
-- LootLink to add statistical history to the auction data that is collected
-- when the auction is scanned, so that you can easily determine what price
-- you will be able to sell an item for at auction or at a vendor whenever you
-- mouse-over an item in the game
--
-- (LootLink is an in-game item database)
--

-- Function hooks
local lOriginalGameTooltip_OnHide;
local lOriginalGameTooltip_ClearMoney;
local lOriginalSetItemRef;

-- If non-nil, check for appearance of GameTooltip for adding information
local lAuctioneerCheckTooltip;

-- Timer for frequency of tooltip checks
local lAuctioneerCheckTimer = 0;

-- Current Tooltip frame
local lAuctioneerTooltip = nil;

-- Counter to count the total number of auctions scanned
local lTotalAuctionsScannedCount = 0;
local lNewAuctionsCount = 0;
local lOldAuctionsCount = 0;
local lDefunctAuctionsCount = 0;

-- temp table that is copied into AHSnapshotItemPrices only when a scan fully completes
local lSnapshotItemPrices = {};

-- the maximum number of elements we store in our buyout prices history table 
local lMaxBuyoutHistorySize = 35;

-- min median buyout price for an item to show up in the list of items below median
local MIN_PROFIT_MARGIN = 8000;

-- min times an item must be seen before it can show up in the list of items below median
local MIN_BUYOUT_SEEN_COUNT = 7;

-- max buyout price for an auction to display as a good deal item
local MAX_BUYOUT_PRICE = 800000;

-- the default percent less, only find auctions that are at a minimum this percent less than the median
local MIN_PERCENT_LESS_THAN_MEDIAN = 60; -- 60% by default


--[[ SavedVariables --]]
AuctionConfig = {};        --Table that stores config settings
AuctionPrices = {};        --Table that keeps the price history of auctions
Auction_DoneItems = {};    --Table to keep a record of auction items that have been scanned
AHSnapshot = {};           --Table that will hold the Auction scan results
AHSnapshotItemPrices = {}; --Table that holds the lists of prices buy item name, for quick look up

-- Auction time constants
local TIME_LEFT_SHORT = 1;
local TIME_LEFT_MEDIUM = 2;
local TIME_LEFT_LONG = 3;
local TIME_LEFT_VERY_LONG = 4;

-- return the string representation of the given timeLeft constant
local function getTimeLeftString(timeLeft)
    local timeLeftString = "";
    if timeLeft == TIME_LEFT_SHORT then
        timeLeftString = "Short";
    elseif timeLeft == TIME_LEFT_MEDIUM then
        timeLeftString = "Medium";
    elseif timeLeft == TIME_LEFT_LONG then
        timeLeftString = "Long";
    elseif timeLeft == TIME_LEFT_VERY_LONG then
        timeLeftString = "Very Long";    
    end
    return timeLeftString;    
end

-- calculate the gold, silver, and copper values based the ammount of copper
function Auctioneer_GetGSC(money)
	if (money == nil) then money = 0; end
	local g = math.floor(money / 10000);
	local s = math.floor((money - (g*10000)) / 100);
	local c = math.floor(money - (g*10000) - (s*100));
	return g,s,c;
end

-- formats money text by color for gold, silver, copper
function Auctioneer_GetTextGSC(money)
    local GSC_GOLD="ffd100";
    local GSC_SILVER="e6e6e6";
    local GSC_COPPER="c8602c";
    local GSC_START="|cff%s%d|r";
    local GSC_PART=".|cff%s%02d|r";
    local GSC_NONE="|cffa0a0a0none|r";

	local g, s, c = Auctioneer_GetGSC(money);

	local gsc = "";
	if (g > 0) then
		gsc = format(GSC_START, GSC_GOLD, g);     
		if (s > 0) then
			gsc = gsc..format(GSC_PART, GSC_SILVER, s);
		end
	elseif (s > 0) then
		gsc = format(GSC_START, GSC_SILVER, s);
		if (c > 0) then
			gsc = gsc..format(GSC_PART, GSC_COPPER, c);
		end
	elseif (c > 0) then
		gsc = gsc..format(GSC_START, GSC_COPPER, c);
	else
		gsc = GSC_NONE;
	end

	return gsc;
end

-- return an empty string if str is nil
local function nilSafeString(str)
    if (not str) then str = "" end
    return str;
end

local function colorTextWhite(text)
    if (not text) then text = ""; end
    local COLORING_START = "|cff%s%s|r";
    local WHITE_COLOR = "e6e6e6";
    return format(COLORING_START, WHITE_COLOR, ""..text);
end

-- used to convert variables that should be numbers but are nil to 0
function nullSafe(val)
	if (val == nil) then return 0; end
	if (0 + val > 0) then return 0 + val; end
	return 0;
end

-- subtracts a percent from a value
local function subtractPercent(value, percentLess)
    return math.floor(value * ((100 - percentLess)/100));
end

-- returns the integer representation of the percent less value2 is from value1
-- example: value1=10, value2=7,  percentLess=30
local function percentLessThan(value1, value2)
    if nullSafe(value1) > 0 then
        return 100 - math.floor((100 * nullSafe(value2))/nullSafe(value1));
    else
        return 0;
    end
end

-- returns the median value of a given table one-dimentional table
function getMedian(valuesTable)
    if (not valuesTable or table.getn(valuesTable) == 0) then
        return nil; --make this function nil argument safe
    end
    
    local tableSize = table.getn(valuesTable);
    
    if (tableSize == 1) then
        return valuesTable[1];
    end
        
    local median; -- value to return
        
    table.sort(valuesTable);
    
    if (math.mod(tableSize, 2) == 0) then --first handle the case of even table size
        local middleIndex1 = tableSize / 2;
        local middleIndex2 = middleIndex1 + 1;
        local middleValue1 = valuesTable[middleIndex1];
        local middleValue2 = valuesTable[middleIndex2];
        median = (middleValue1 + middleValue2) / 2; --average the two middle values
    else -- the table size is odd
        local trueMiddleIndex = (tableSize + 1) / 2; -- calculate the middle index
        median = valuesTable[trueMiddleIndex];
    end
    
    return median;
end

-- format an itemname so it can be used as a key into a table
local function formatItemName(s)
   local itemName = s;

    _, _, item = string.find(itemName, "%[(.-)%]") -- strip shift-clicked characters
    if item then 
        itemName = item;
    end;
    
    -- upper case first letters of words, except for 'of' 'the'
    itemName = string.gsub(itemName, "^(%a)", function (n) return string.upper(n) end);
    itemName = string.gsub(itemName, "%s%a", function (n) return string.upper(n) end);
    itemName = string.gsub(itemName, "Of", "of");
    itemName = string.gsub(itemName, "The", "the");
    
    return itemName;
end

--this function sets the dirty flag to true for all the auctions in the snapshot
--this is done to indicate that the snapshot is out of date.
local function invalidateAHSnapshot()
    -- invalidate the snapshot
    for i,a in AHSnapshot do
        a.dirty = 1;
    end
end


-- called when the auction scan starts
local function Auctioneer_AuctionStart_Hook()
	Auctioneer_Old_AuctionStart_Hook();
	Auction_DoneItems = {};
    lSnapshotItemPrices = {};
    invalidateAHSnapshot();
    
    -- reset scan audit counters
    lTotalAuctionsScannedCount = 0;
    lNewAuctionsCount = 0;
    lOldAuctionsCount = 0;
    lDefunctAuctionsCount = 0;
end


-- this is called when an auction scan finishes and is used for clean up
local function Auctioneer_FinishedAuctionScan_Hook()
    -- only remove defunct auctions from snapshot if there was a good amount of auctions scanned.
    if lTotalAuctionsScannedCount > 250 then 
        for i,a in AHSnapshot do
            if (a.dirty == 1) then
                AHSnapshot[i] = nil; --clear defunct auctions
                lDefunctAuctionsCount = lDefunctAuctionsCount + 1;
            end
        end
    end
    
    -- copy the item prices into the Saved item prices table
    AHSnapshotItemPrices = lSnapshotItemPrices;

    local lDiscrepencyCount = lTotalAuctionsScannedCount - (lNewAuctionsCount + lOldAuctionsCount);
    
    Auctioneer_ChatPrint("Total auctions scanned: "..colorTextWhite(lTotalAuctionsScannedCount));
    Auctioneer_ChatPrint("New auctions scanned: "..colorTextWhite(lNewAuctionsCount));
    Auctioneer_ChatPrint("Previously scanned: "..colorTextWhite(lOldAuctionsCount));
    Auctioneer_ChatPrint("Defunct auctions removed: "..colorTextWhite(lDefunctAuctionsCount));
    
    if (nullSafe(lDiscrepencyCount) > 0) then
        Auctioneer_ChatPrint("Discrepencies: "..colorTextWhite(lDiscrepencyCount));
    end
end


-- returns a LootLink item link
local function Auctioneer_GetItemLink(itemName)
	if (ItemLinks == nil) then
		return nil; 
	end
	if (ItemLinks[itemName] == nil) then 
		return nil; 
	end
	return ItemLinks[itemName];
end


--returns the auction prices key to get the prices for this server and faction
function auctionKey()
	local serverName = GetCVar("realmName");
	local factionGroup = UnitFactionGroup("player");
	return serverName.."-"..factionGroup;
end

local function oppositeKey()
	local serverName = GetCVar("realmName");
	local factionGroup = UnitFactionGroup("player");
	if (factionGroup == "Alliance") then factionGroup="Horde"; else factionGroup="Alliance"; end
	return serverName.."-"..factionGroup;
end

function Auctioneer_GetAuctionKey()
	return auctionKey();
end

function Auctioneer_GetOppositeKey()
	return oppositeKey();
end

-- returns the numeric Lootlink ID for this item name
local function getNumericItemId(itemName)
    local itemLink = Auctioneer_GetItemLink(itemName);
    
    if (not itemLink or not itemLink.i) then return 0; end
    local i,j, baseItemID = string.find(itemLink.i, "^(%d+):");
    if (not baseItemID) then return 0; end
    baseItemID = 0 + baseItemID;
    
    return baseItemID;
end


-- returns an AuctionPrices item from the table based on an item name
local function getAuctionPriceItem(itemName, from)
    local server = auctionKey();
    if (from ~= nil) then server = from; end
	if (AuctionPrices[server] == nil) then
		AuctionPrices[server] = {};
	end
    return AuctionPrices[server][itemName];
end


-- returns the auction price data for an auction
local function getAuctionPriceData(itemName, from)
	local auctionItem = getAuctionPriceItem(itemName, from);
	if (auctionItem == nil) then 
		link = "0:0:0:0:0:0:0";
    else
        link = auctionItem.data;
	end
	return link;
end


-- returns the auction buyout history for this item
function getAuctionBuyoutHistory(itemName)
	local auctionItem = getAuctionPriceItem(itemName);
	if (auctionItem == nil) then 
		buyoutHistory = {};
    else
        buyoutHistory = auctionItem.buyoutPricesHistoryList;
	end
	return buyoutHistory;
end


-- returns the parsed auction price data
local function getAuctionPrices(priceData)
	local i,j, count,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = string.find(priceData, "^(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)");
	return nullSafe(count),nullSafe(minCount),nullSafe(minPrice),nullSafe(bidCount),nullSafe(bidPrice),nullSafe(buyCount),nullSafe(buyPrice);
end

-- parse the data from the auction signature
local function getItemSignature(sigData)
	local i,j, id,name,count,min,buyout = string.find(sigData, "^(%d+):(.-):(%d+):(.-):(.+)");
--~ Auctioneer_ChatPrint("id="..id);
--~ Auctioneer_ChatPrint("name="..name);
--~ Auctioneer_ChatPrint("cout="..count);
--~ Auctioneer_ChatPrint("min="..min);
--~ Auctioneer_ChatPrint("buyout="..buyout);
	if (name == nil) then name = ""; end
    if (tonumber(min) < 0) then min = 0 end -- handle number overflow
    if (tonumber(buyout) < 0) then buyout = 0 end -- handle number overflow
	return tonumber(id),name,tonumber(count),tonumber(min),tonumber(buyout);
end

-- returns the current snapshot median for an item
function getItemSnapshotMedianBuyout(itemName)
    local buyoutPrices = {};
    if AHSnapshotItemPrices[itemName] then 
        buyoutPrices = AHSnapshotItemPrices[itemName].buyoutPrices;
    else
        return nil, nil;
    end

    return getMedian(buyoutPrices), table.getn(buyoutPrices);
end

local function getItemHistoricalMedianBuyout(itemName)
    local buyoutHistoryTable = getAuctionBuyoutHistory(itemName);
    local historyMedian = getMedian(buyoutHistoryTable);
    local historySeenCount = table.getn(buyoutHistoryTable);
    return historyMedian, historySeenCount;
end

-- this function returns the most accurate median possible, 
-- if an accurate median cannot be obtained based on min seen counts then nil is returned
function getUsableMedian(itemName)
    local usableMedian = nil;
    local count = nil;

    --get snapshot median
    local snapshotMedian, snapshotCount = getItemSnapshotMedianBuyout(itemName);
   
    --get history median
    local historyMedian, historySeenCount = getItemHistoricalMedianBuyout(itemName);
    
    if not snapshotMedian or snapshotCount < MIN_BUYOUT_SEEN_COUNT or snapshotMedian > (historyMedian + (historyMedian * .15)) then
        if historySeenCount >= MIN_BUYOUT_SEEN_COUNT then -- could not obtain a usable median
            usableMedian = historyMedian;
            count = historySeenCount;
        end
    else
        usableMedian = snapshotMedian;
        count = snapshotCount;
    end
    
    return usableMedian, count;
end

-- returns a table containing auctions are good prospects for reselling for profit
-- It decides this based on the items historical median and current median.
-- Logic:
--    
--    1. If there is at least MIN_SNAPSHOT_BUYOUT_SEEN_COUNT then we will use the snapshot to base our decesion.
--    2. Else if the item has been seen at least MIN_BUYOUT_SEEN_COUNT times we will use this to base our decesion.
--    3. The item must have a buyout.
--    4. The item must be at least the <percentLess>% than whatever median we use.
--    5. The item must yeild profit >= MIN_PROFIT_MARGIN
--
-- @param percentLess the percent less than the median price to look for
local function getResellableAuctions(minProfit)
    local auctionsBelowMedian = {};
    if (not minProfit or minProfit == "") then
         --only find auctions that are at a minimum % less than the median
         minProfit = MIN_PROFIT_MARGIN; 
    else
        minProfit = tonumber(minProfit) * 100; -- convert to copper
    end    
    
    Auctioneer_ChatPrint("Minimum profit: "..Auctioneer_GetTextGSC(minProfit)..", HSP = 'Highest Sellable Price'");
    
    for auctionSignature,a in AHSnapshot do
        local id,name,count,min,buyout = getItemSignature(auctionSignature);
        local median, buyoutSeenCount = getUsableMedian(name);
        
        if median then -- we have a useable median
            local highestSellablePriceForOne = getHighestSellablePriceForOne(name, true);
            local totalHighestSellablePrice = highestSellablePriceForOne * count;
            local profit = totalHighestSellablePrice - buyout;

            --see if this auction should be added to the list of below median auctions
            if (buyout > 0 and buyout <= MAX_BUYOUT_PRICE and profit >= minProfit) then
                table.insert(auctionsBelowMedian, a); -- for some reason we have to use table.insert in order to use table.sort later
                local insertedIndex = table.getn(auctionsBelowMedian);
                auctionsBelowMedian[insertedIndex].signature = auctionSignature;
                auctionsBelowMedian[insertedIndex].buyoutSeenCount = buyoutSeenCount;
                auctionsBelowMedian[insertedIndex].totalHighestSellablePrice = totalHighestSellablePrice;
                auctionsBelowMedian[insertedIndex].profit = profit;
            end
        end        
    end    
        
    return auctionsBelowMedian;
end

-- returns a table containing auctions that have a short or medium time left and can be bid on for profit
local function getBidWorthyAuctions(minProfit) 
    local bidWorthyAuctions = {};
    if (not minProfit or minProfit == "") then
        --only find auctions that are at a minimum % less than the median
        minProfit = MIN_PROFIT_MARGIN; 
    else
        minProfit = tonumber(minProfit) * 100; -- convert to copper
    end  
    
    Auctioneer_ChatPrint("Minimum profit: "..Auctioneer_GetTextGSC(minProfit)..", HSP = 'Highest Sellable Price'");
    
    for auctionSignature, a in AHSnapshot do
        local id,name,count,min,buyout = getItemSignature(auctionSignature);
        local median, buyoutSeenCount = getUsableMedian(name);
        
        if median then -- we have a useable median
            local highestSellablePriceForOne = getHighestSellablePriceForOne(name, true);
            local totalHighestSellablePrice = highestSellablePriceForOne * count;
            local currentBid = a.bidamount;
            if currentBid == 0 then currentBid = min end
            local profit = totalHighestSellablePrice - currentBid;

            --see if this auction should be added to the list of below median auctions
            if (currentBid <= MAX_BUYOUT_PRICE and profit >= minProfit and a.timeLeft <= TIME_LEFT_MEDIUM) then
                table.insert(bidWorthyAuctions, a); -- for some reason we have to use table.insert in order to use table.sort later
                local insertedIndex = table.getn(bidWorthyAuctions);
                bidWorthyAuctions[insertedIndex].signature = auctionSignature;
                bidWorthyAuctions[insertedIndex].buyoutSeenCount = buyoutSeenCount;
                bidWorthyAuctions[insertedIndex].totalHighestSellablePrice = totalHighestSellablePrice;
                bidWorthyAuctions[insertedIndex].profit = profit;
                bidWorthyAuctions[insertedIndex].currentBid = currentBid;
            end
        end                
    end
    
    return bidWorthyAuctions;
end

local function getPercentLessAuctions(percentLess)
    local auctionsBelowMedian = {};
    
    if (percentLess == "") then
         --only find auctions that are at a minimum % less than the median
         percentLess = MIN_PERCENT_LESS_THAN_MEDIAN; 
    end
    
    Auctioneer_ChatPrint("Percent Less than median: "..percentLess.."%");
    
    for auctionSignature,a in AHSnapshot do
        local id,name,count,min,buyout = getItemSignature(auctionSignature);
        local averageBuyoutForOne = math.floor(buyout / count);
        
        local median, buyoutSeenCount = getUsableMedian(name);
        
        if median then
            local maximumBuyPriceForProfit = math.floor(median * ((100 - percentLess)/100));
            local totalMedian = median * count;
            local profit = totalMedian - buyout;

            --see if this auction should be added to the list of below median auctions
            if (averageBuyoutForOne > 0 and averageBuyoutForOne <= maximumBuyPriceForProfit and profit >= MIN_PROFIT_MARGIN) then                
                table.insert(auctionsBelowMedian, a); -- for some reason we have to use table.insert in order to use table.sort later
                local insertedIndex = table.getn(auctionsBelowMedian);
                auctionsBelowMedian[insertedIndex].signature = auctionSignature;
                auctionsBelowMedian[insertedIndex].buyoutSeenCount = buyoutSeenCount;
                auctionsBelowMedian[insertedIndex].totalMedian = totalMedian;
                auctionsBelowMedian[insertedIndex].profit = profit;                
            end
        end            
    end    
    
    return auctionsBelowMedian;
end

-- returns if an item is a recipe type
local function isItemRecipe(itemName) 
    local isRecipe = false;
    if string.find(itemName, "Pattern:") or string.find(itemName, "Recipe:") or
       string.find(itemName, "Plans:") or string.find(itemName, "Schematic:") or
       string.find(itemName, "Formula:") then
        isRecipe = true;
    end
    return isRecipe;
end
    
-- builds the list of auctions that can be bought and resold for profit
function doBroker(minProfit)

    local auctionsBelowMedian = getResellableAuctions(minProfit);
    
    -- sort by profit decending
    table.sort(auctionsBelowMedian, function(a, b) return (a.profit > b.profit) end);
    
    -- output the list of auctions below the median
    for _,a in auctionsBelowMedian do
        local _, name, count, _, buyout = getItemSignature(a.signature); 
        if not isItemRecipe(name) then
            Auctioneer_ChatPrint(colorTextWhite(count.."x")..a.itemLink..", Last "..a.buyoutSeenCount.." seen HSP: "..Auctioneer_GetTextGSC(a.totalHighestSellablePrice).." BO: "..Auctioneer_GetTextGSC(buyout).." Prof: "..Auctioneer_GetTextGSC(a.profit));
        end
    end
    
    Auctioneer_ChatPrint("Brokering done.");
end

-- builds the list of auctions that can be bought and resold for profit
function doBidBroker(minProfit)
    local bidWorthyAuctions = getBidWorthyAuctions(minProfit);
    
    table.sort(bidWorthyAuctions, function(a, b) return (a.timeLeft < b.timeLeft) end);
    
    -- output the list of auctions below the median
    for _,a in bidWorthyAuctions do
        local _, name, count, _, buyout = getItemSignature(a.signature); 
        if not isItemRecipe(name) then
            Auctioneer_ChatPrint(colorTextWhite(count.."x")..a.itemLink..", Last "..a.buyoutSeenCount.." seen HSP: "..Auctioneer_GetTextGSC(a.totalHighestSellablePrice).." CurrentBid: "..Auctioneer_GetTextGSC(a.currentBid).." Prof: "..Auctioneer_GetTextGSC(a.profit).." Time: "..colorTextWhite(getTimeLeftString(a.timeLeft)));
        end
    end
    
    Auctioneer_ChatPrint("Bid brokering done.");
end

-- builds the list of auctions that can be bought and resold for profit
function doPercentLess(percentLess)    

    local auctionsBelowMedian = getPercentLessAuctions(percentLess);
    
    table.sort(auctionsBelowMedian, function(a, b) return (a.profit > b.profit) end);
    
    -- output the list of auctions below the median
    for _,a in auctionsBelowMedian do
        local _, name, count, _, buyout = getItemSignature(a.signature); 
        if not isItemRecipe(name) then
            local snapshotMedian, lastSeenCount = getUsableMedian(name);
            Auctioneer_ChatPrint(colorTextWhite(count.."x")..a.itemLink..", Last "..lastSeenCount.." seen Median: "..Auctioneer_GetTextGSC(a.totalMedian).." BO: "..Auctioneer_GetTextGSC(buyout).." Prof: "..Auctioneer_GetTextGSC(a.profit).." Less: "..colorTextWhite(percentLessThan(getUsableMedian(name), buyout / count).."%"));
        end
    end
    
    Auctioneer_ChatPrint("Percent less done.");
end

-- given an item name, find the lowest price for that item in the current AHSnapshot
-- if the item does not exist in the snapshot or the snapshot does not exist
-- a nil is returned.
function findLowestAuctionForItem(itemName)
    if (not itemName) then return nil; end

    local lowSig = nil;
    local lowestPrice = 9000000; -- initialize to a very high value, 900 gold
    for sig,v in AHSnapshot do
        local id,name,count,min,buyout = getItemSignature(sig);
        local priceForOne = (buyout / count);
        if (string.lower(name) == string.lower(itemName) and buyout > 0 and priceForOne < lowestPrice) then
            lowSig = sig;
            lowestPrice = priceForOne;
        end
    end
    return lowSig;
end

-- quick index to lowest snapshot price of an item
function getLowestPriceQuick(itemName)
    local lowestPriceForOne = nil;
    
   if AHSnapshotItemPrices[itemName] then 
        buyoutPrices = AHSnapshotItemPrices[itemName].buyoutPrices;
        table.sort(buyoutPrices)
        lowestPriceForOne = buyoutPrices[1];
    end
    
    return lowestPriceForOne;
end

function doMedian(param)
    local itemName = formatItemName(param);
    local median, count = getUsableMedian(itemName);
    if (not median) then
        Auctioneer_ChatPrint("No auctions found for the item: "..colorTextWhite(itemName));
    else
        Auctioneer_ChatPrint("Of last "..count.." seen, median buyout for 1 "..colorTextWhite(itemName).." is: "..Auctioneer_GetTextGSC(median));
    end    
end

function getHighestSellablePriceForOne(itemName, useCachedPrices)
    local highestSellablePrice = 0;
    local lowestAllowedPercentBelowMedian = 40;
    local discountLowPercent = 5;
    local discountMedianPercent = 20;
    local median, count = getUsableMedian(itemName);
    
    local currentLowestBuyout = nil;
    local lowestAuctionSignature = nil;
    local lowestAuctionCount, lowestAuctionBuyout;
    if useCachedPrices then
        currentLowestBuyout = getLowestPriceQuick(itemName);
    else
        lowestAuctionSignature = findLowestAuctionForItem(itemName);
        if lowestAuctionSignature then
            _, _, lowestAuctionCount, _, lowestAuctionBuyout = getItemSignature(lowestAuctionSignature);
            currentLowestBuyout = lowestAuctionBuyout / lowestAuctionCount;
        end
    end
  
--~ Auctioneer_ChatPrint("itemName: "..itemName.." Median: "..nullSafe(median).." count: "..nullSafe(count).." currentLowestBuyout:  "..nullSafe(currentLowestBuyout));

    if median then
--~ Auctioneer_ChatPrint("if median then");
        if currentLowestBuyout then
--~ Auctioneer_ChatPrint("inside if median then, currentLowestBuyout then");        
            lowestBuyoutPriceAllowed = subtractPercent(median, lowestAllowedPercentBelowMedian);
            if lowestAuctionSignature and AHSnapshot[lowestAuctionSignature].owner == UnitName("player") then
--~ Auctioneer_ChatPrint("if lowestPriceForOne.owner == Araband then");            
                highestSellablePrice = currentLowestBuyout; -- If I am the lowest seller use same low price
            elseif (currentLowestBuyout < lowestBuyoutPriceAllowed) or (currentLowestBuyout > median) then
--~ Auctioneer_ChatPrint("elseif (currentLowestBuyout < lowestBuyoutPriceAllowed) or (currentLowestBuyout > median) then");            
                -- set highest price to "Discount median"
                highestSellablePrice = subtractPercent(median, discountMedianPercent);
            else -- use discount low
--~ Auctioneer_ChatPrint("else -- use discount low");            
                -- set highest price to "Discount low"
                highestSellablePrice = subtractPercent(currentLowestBuyout, discountLowPercent);
            end
        else -- no low buyout, use discount median
--~ Auctioneer_ChatPrint("else -- no low buyout, use discount median");        
            -- set highest price to "Discount median"
            highestSellablePrice = subtractPercent(median, discountMedianPercent);            
        end
    else -- no median
--~ Auctioneer_ChatPrint("else -- no median");    
        if currentLowestBuyout then
--~ Auctioneer_ChatPrint("inside else -- no median, if currentLowestBuyout then");        
            -- set highest price to "Discount low"
            highestSellablePrice = subtractPercent(currentLowestBuyout, discountLowPercent);
        end
    end
    
    return highestSellablePrice;
end

-- execute the '/auctioneer low <itemName>' that returns the auction for an item with the lowest buyout
function doLow(param)
    local itemName = formatItemName(param);

    local auctionSignature = findLowestAuctionForItem(itemName, AHSnapshot);
    if (not auctionSignature) then
        Auctioneer_ChatPrint("No auctions found for the item: "..colorTextWhite(itemName));
    else
        local _, _, count, _, buyout = getItemSignature(auctionSignature);
        local auction = AHSnapshot[auctionSignature];    
        Auctioneer_ChatPrint(colorTextWhite(count.."x")..auction.itemLink..", BO: "..Auctioneer_GetTextGSC(buyout).." Seller: "..colorTextWhite(auction.owner).." For one: "..Auctioneer_GetTextGSC(buyout / count).." Less than median: "..colorTextWhite(percentLessThan(getUsableMedian(itemName), buyout / count).."%"));
    end
end

function doHSP(param)
    local itemName = formatItemName(param);
    local highestSellablePrice = getHighestSellablePriceForOne(itemName, false);
    Auctioneer_ChatPrint("Highest Sellable Price for one "..colorTextWhite(itemName).." is: "..Auctioneer_GetTextGSC(nilSafeString(highestSellablePrice)));
end


-- Called buy lootlink hook when an auction item is scanned from the Auction house
-- we save the aution item to our tables, increment our counts etc
local function Auctioneer_AuctionEntry_Hook(name, count, item, page, index)
	Auctioneer_Old_AuctionEntry_Hook(name, count, item, page, index);
    
	if (not page) then
		return;
	end
	if (not Auction_DoneItems[page]) then
		Auction_DoneItems[page] = {};
	end
	if (Auction_DoneItems[page][index]) then
		return;
	end
    Auction_DoneItems[page][index] = true;

    lTotalAuctionsScannedCount = lTotalAuctionsScannedCount + 1;

	local aiName, aiTexture, aiCount, aiQuality, aiCanUse, aiLevel, aiMinBid, aiMinIncrement, aiBuyoutPrice, aiBidAmount, aiHighBidder, aiOwner = GetAuctionItemInfo("list", index);
    local aiTimeLeft = GetAuctionItemTimeLeft("list", index);
   
    -- do some validation of the auction data that was returned
    if (aiCount < 1) then aiCount = 1; end
    if (aiName == nil) then return; end --if name is nil skip this auction
        
    -- construct the unique auction signature for this aution
    local lAuctionSignature = string.format("%d:%s:%d:%d:%d", getNumericItemId(aiName), nilSafeString(aiName), nullSafe(aiCount), nullSafe(aiMinBid), nullSafe(aiBuyoutPrice));
    
    -- add this item's buyout price to the buyout price history for this item in the snapshot
    if (aiBuyoutPrice > 0) then
        local buyoutPriceForOne = (aiBuyoutPrice / aiCount);
        if (not lSnapshotItemPrices[aiName]) then
            lSnapshotItemPrices[aiName] = {buyoutPrices={buyoutPriceForOne}};
        else
            table.insert(lSnapshotItemPrices[aiName].buyoutPrices, buyoutPriceForOne);
        end
    end
    
    --if this auction is not in the snapshot add it to the AuctionPrices and AHSnapshot    
    if (not AHSnapshot[lAuctionSignature]) then 
    
        --Auctioneer_ChatPrint("New sig: "..lAuctionSignature);
    
        lNewAuctionsCount = lNewAuctionsCount + 1;
        
        -- get the item data from AuctionPrices table
        local itemData;
        local itemID = getNumericItemId(aiName);
        -- see if they are still using the itemID as the key
        if AuctionPrices[auctionKey()][itemID] then
            itemData = AuctionPrices[auctionKey()][itemID];
            AuctionPrices[auctionKey()][itemID] = nil; --clear entry using old ID key
        else
            itemData = getAuctionPriceData(aiName);
        end
        
        local count,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = getAuctionPrices(itemData);
     
     	-- Sanity check values to ensure they aren't whack. if prices are wack we dont want to skew the mean, but still can add to the median
        local hasWackPrice = false;
        if ((nullSafe(minCount) > 10) and (aiMinBid/aiCount > 5*minPrice/minCount)) then 
            hasWackPrice = true;
        elseif ((nullSafe(bidCount) > 10) and (aiBidAmount/aiCount > 5*bidPrice/bidCount)) then 
            hasWackPrice = true;
        elseif ((nullSafe(buyCount) > 10) and (aiBuyoutPrice/aiCount > 5*buyPrice/buyCount)) then 
            hasWackPrice = true;
        end
     
        if (not hasWackPrice) then 
            -- update counts and price data for this item
            count = nullSafe(count) + 1;
            minCount = nullSafe(minCount) + aiCount;
            minPrice = nullSafe(minPrice) + aiMinBid;
            if (aiBidAmount > 0) then 
                bidCount = nullSafe(bidCount) + aiCount;
                bidPrice = nullSafe(bidPrice) + aiBidAmount;
            end
            if (aiBuyoutPrice > 0) then
                buyCount = nullSafe(buyCount) + aiCount;
                buyPrice = nullSafe(buyPrice) + aiBuyoutPrice;
            end
        end
    
        itemData = string.format("%d:%d:%d:%d:%d:%d:%d", count,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice);
        
        -- now build the list of buyout prices seen for this auction to use to get the median        
        local newBuyoutPricesList = newBalancedList(lMaxBuyoutHistorySize);
        if (AuctionPrices[auctionKey()][aiName] and table.getn(AuctionPrices[auctionKey()][aiName].buyoutPricesHistoryList) > 0) then
            newBuyoutPricesList.setList(AuctionPrices[auctionKey()][aiName].buyoutPricesHistoryList);
        end
        if (nullSafe(aiBuyoutPrice) > 0) then
            newBuyoutPricesList.insert(math.floor(aiBuyoutPrice / aiCount));
        end        
        AuctionPrices[auctionKey()][aiName] = {data=itemData, buyoutPricesHistoryList=newBuyoutPricesList.getList()};
        
        -- finaly add the auction to the snapshot
        if (aiOwner == nil) then aiOwner = "unknown"; end
        local aiLink = GetAuctionItemLink("list", index);
        AHSnapshot[lAuctionSignature] = {itemLink=aiLink, quality=nullSafe(aiQuality), level=nullSafe(aiLevel), bidamount=nullSafe(aiBidAmount), owner=aiOwner, timeLeft=nullSafe(aiTimeLeft), dirty=0};
    else
        lOldAuctionsCount = lOldAuctionsCount + 1;
        --this is an auction that was already in the snapshot from a previous scan and is still in the auction house
        --just set its dirty flag to false so we know to keep it in the snapshot
        AHSnapshot[lAuctionSignature].dirty = 0; 
    end
end

local function Auctioneer_Tooltip_Hook(frame, name, count, data)
	Auctioneer_AddTooltipInfo(frame, name, count, data);
	Auctioneer_Old_Tooltip_Hook(frame, name, count, data);
end

function Auctioneer_AddTooltipInfo(frame, name, count, data)
	if (Auctioneer_GetFilter("all")) then
		local money = nil;
		local itemInfo = nil;

		local itemID = getNumericItemId(name);
		if (itemID > 0) then
			frame.eDone = 1;
			local itemData = getAuctionPriceData(name);
			local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = getAuctionPrices(itemData);
			itemInfo = Auctioneer_BasePrices[itemID];

			if (aCount == 0) then
				frame:AddLine("Never seen at auction", 0.5, 0.8, 0.5);
			else
				local avgQty = math.floor(minCount / aCount);
				local avgMin = math.floor(minPrice / minCount);

				local bidPct = math.floor(bidCount / minCount * 100);
				local avgBid = 0;
				if (buyCount > 0) then
					avgBid = math.floor(bidPrice / bidCount);
				end
				
				local buyPct = math.floor(buyCount / minCount * 100);
				local avgBuy = 0;
				if (buyCount > 0) then
					avgBuy = math.floor(buyPrice / buyCount);
				end
                
                
                local median, medCount = getUsableMedian(name);
                
				if (Auctioneer_GetFilter("average")) then
					frame:AddLine(format("Seen %d times at auction total", aCount), 0.5,0.8,0.1);
					if (avgQty > 1) then
						frame:AddLine(format("For 1: %s min/%s buyout (%s bid) [in %d's]", Auctioneer_GetTextGSC(avgMin), Auctioneer_GetTextGSC(avgBuy), Auctioneer_GetTextGSC(avgBid), avgQty), 0.1,0.8,0.5);
					else
						frame:AddLine(format("%s min/%s buyout (%s bid)", Auctioneer_GetTextGSC(avgMin), Auctioneer_GetTextGSC(avgBuy), Auctioneer_GetTextGSC(avgBid)), 0.1,0.8,0.5);
					end
                    if median and Auctioneer_GetFilter("median") then
                        local historicalMedian, historicalMedCount = getItemHistoricalMedianBuyout(name);
                        local snapshotMedian, snapshotMedCount = getItemSnapshotMedianBuyout(name);
                        if historicalMedian then
                            frame:AddLine(format("Last %d seen, buyout median: %s", historicalMedCount, Auctioneer_GetTextGSC(historicalMedian)),0.1,0.8,0.5);
                        end
                        if snapshotMedian and snapshotMedCount < historicalMedCount then
                            frame:AddLine(format("Last scan %d seen, buyout median: %s", snapshotMedCount, Auctioneer_GetTextGSC(snapshotMedian)),0.1,0.8,0.5);
                        end
                    end
				end
				if (Auctioneer_GetFilter("suggest")) then
					if (count > 1) then
                        local buyoutPriceForOne = median;
                        if not buyoutPriceForOne then buyoutPriceForOne = avgBuy end
                        if (avgMin > buyoutPriceForOne) then aveMin = buyoutPriceForOne / 2 end
						frame:AddLine(format("Your %d stack: %s min/%s buyout (%s bid)", count, Auctioneer_GetTextGSC(avgMin*count), Auctioneer_GetTextGSC(buyoutPriceForOne*count), Auctioneer_GetTextGSC(avgBid*count)), 0.5,0.5,0.8);
					end
				end
				if (Auctioneer_GetFilter("stats")) then
					frame:AddLine(format("%d%% have bids, %d%% have buyout", bidPct, buyPct), 0.1,0.5,0.8);
				end
			end
            
			local also = Auctioneer_GetFilterVal("also");
			if (also ~= "on") then
				if (also == "opposite") then
					also = oppositeKey();
				end
				local itemData = getAuctionPriceData(itemID, also);
				local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = getAuctionPrices(itemData);
				local avgQty = math.floor(minCount / aCount);
				local avgMin = math.floor(minPrice / minCount);

				local bidPct = math.floor(bidCount / minCount * 100);
				local avgBid = 0;
				if (buyCount > 0) then
					avgBid = math.floor(bidPrice / bidCount);
				end
				
				local buyPct = math.floor(buyCount / minCount * 100);
				local avgBuy = 0;
				if (buyCount > 0) then
					avgBuy = math.floor(buyPrice / buyCount);
				end

				if (aCount == 0) then
					frame:AddLine(format(">> Never seen at "..also, aCount), 0.5,0.8,0.1);
				else
					if (Auctioneer_GetFilter("average")) then
						frame:AddLine(format(">> %d times at "..also, aCount), 0.5,0.8,0.1);
						if (avgQty > 1) then
							frame:AddLine(format(">> For 1: %s min/%s buy (%s bid) [in %d's]", Auctioneer_GetTextGSC(avgMin), Auctioneer_GetTextGSC(avgBuy), Auctioneer_GetTextGSC(avgBid), avgQty), 0.1,0.8,0.5);
						else
							frame:AddLine(format(">> %s min/%s buy (%s bid)", Auctioneer_GetTextGSC(avgMin), Auctioneer_GetTextGSC(avgBuy), Auctioneer_GetTextGSC(avgBid)), 0.1,0.8,0.5);
						end
						if (Auctioneer_GetFilter("suggest")) then
							if (count > 1) then
								frame:AddLine(format(">> Your %d stack: %s min/%s buy (%s bid)", count, Auctioneer_GetTextGSC(avgMin*count), Auctioneer_GetTextGSC(avgBuy*count), Auctioneer_GetTextGSC(avgBid*count)), 0.5,0.5,0.8);
							end
						end
					end
					if (Auctioneer_GetFilter("stats")) then
						frame:AddLine(format(">> %d%% have bids, %d%% have buyout", bidPct, buyPct), 0.1,0.5,0.8);
					end
				end
			end            
            
			if ((data ~= nil) and (data.price ~= nil)) then
				money = data.price;
			else
				money = 0;
			end
		end
		if (money == nil) then
			money = 0;
		end

		local sellNote = "";
		local buyNote = "";
		local sell = money;
		local buy = sell * 4;
		local quant = 1;
		local stacks = 1;
		local class = "";
		local uses = "";
		if (itemInfo) then
			buyNote = "*"
			stacks = itemInfo.x;
			if (not stacks) then stacks = 1; end
			quant = nullSafe(itemInfo.q);
			if (quant < 1) then quant = 1; end
			if (quant > 1) then
				buyNote = "*";
			end
			buy = nullSafe(itemInfo.b) / quant;
			if ((not sell) or (sell == "") or (sell <= 0))  then
				sellNote = "*"
				sell = nullSafe(itemInfo.s);
			end;
			if (itemInfo.c) then
				class = itemInfo.c;
			end
			if (itemInfo.u) then
				uses = itemInfo.u;
			end
		end
			
		if (Auctioneer_GetFilter("vendor")) then
			if ((buy > 0) or (sell > 0)) then
				local bgsc = Auctioneer_GetTextGSC(buy);
				local sgsc = Auctioneer_GetTextGSC(sell);
                
				if (count and (count > 1)) then
					local bqgsc = Auctioneer_GetTextGSC(buy*count);
					local sqgsc = Auctioneer_GetTextGSC(sell*count);
					if (Auctioneer_GetFilter("vendorbuy")) then
						frame:AddLine(format("Buy%s %d at %s (%s ea)", buyNote, count, bqgsc, bgsc), 0.8, 0.5, 0.1);
					end
					if (Auctioneer_GetFilter("vendorsell")) then
						frame:AddLine(format("Sell%s %d at %s (%s ea)", sellNote, count, sqgsc, sgsc), 0.8, 0.5, 0.1);
					end
				else
					if (Auctioneer_GetFilter("vendorbuy")) then
						if (Auctioneer_GetFilter("vendorsell")) then
							frame:AddLine(format("Buy%s %s, Sell%s %s", buyNote, bgsc, sellNote, sgsc), 0.8, 0.5, 0.1);
						else 
							frame:AddLine(format("Buy%s %s", buyNote, bgsc), 0.8, 0.5, 0.1);
						end
					elseif (Auctioneer_GetFilter("vendorsell")) then
						frame:AddLine(format("Sell%s %s", sellNote, sgsc), 0.8, 0.5, 0.1);
					end
				end
			end
		end

		if (Auctioneer_GetFilter("stacksize")) then
			if (stacks > 1) then
				frame:AddLine(format("Stacks in lots of %d", stacks));
			end
		end
		if (Auctioneer_GetFilter("usage")) then
			local reagentInfo = "";
			if (class ~= "") then
				if (uses ~= "") then
					reagentInfo = "Class: "..class.." used for "..uses;
				else
					reagentInfo = "Class: "..class;
				end
			elseif (uses ~= "") then
				reagentInfo = "Used for: "..uses;
			end
			if (reagentInfo ~= "") then
				frame:AddLine(reagentInfo, 0.6, 0.4, 0.8);
			end
		end
	end
	frame:Show();
end

-- hook to capture data about an auction that was boughtout
function Auctioneer_PlaceAuctionBid(itemtype, itemindex, bidamount)    
    -- get the info for this auction
    local aiName, aiTexture, aiCount, aiQuality, aiCanUse, aiLevel, aiMinBid, aiMinIncrement,
          aiBuyout, aiBidAmount, aiHighBidder, aiOwner =
          GetAuctionItemInfo(AuctionFrame.type, GetSelectedAuctionItem(AuctionFrame.type));
          
    if bidamount == aiBuyout then -- only capture buyouts
        local auctionSignature = getNumericItemId(aiName)..":"..aiName..":"..aiCount..":"..aiMinBid..":"..aiBuyout;
        
        -- remove from snapshot
        Auctioneer_ChatPrint("Removing auction signature ".. auctionSignature .." from current AH snapshot..");
        AHSnapshot[auctionSignature] = nil;
    end    

    Auctioneer_Old_BidHandler(itemtype,itemindex,bidamount);
end

function Auctioneer_OnLoad()
	RegisterForSave("AuctionConfig");
	RegisterForSave("AuctionPrices");
    RegisterForSave("AHSnapshot");
    RegisterForSave("AHSnapshotItemPrices");
    
    -- register events
    this:RegisterEvent("NEW_AUCTION_UPDATE"); -- event that is fired when item changed in new auction frame
    this:RegisterEvent("AUCTION_HOUSE_SHOW"); -- auction house window opened
    
	lOriginalGameTooltip_ClearMoney = GameTooltip_ClearMoney;
	GameTooltip_ClearMoney = Auctioneer_GameTooltip_ClearMoney;

	lOriginalGameTooltip_OnHide = GameTooltip_OnHide;
	GameTooltip_OnHide = Auctioneer_GameTooltip_OnHide;

	lOriginalSetItemRef = SetItemRef;
	SetItemRef = Auctioneer_SetItemRef;
	
	Auctioneer_Old_Tooltip_Hook = LootLink_AddExtraTooltipInfo;
	LootLink_AddExtraTooltipInfo = Auctioneer_Tooltip_Hook;

	Auctioneer_Old_AuctionStart_Hook = LootLink_Event_StartAuctionScan;
	LootLink_Event_StartAuctionScan = Auctioneer_AuctionStart_Hook;

	Auctioneer_Old_AuctionEntry_Hook = LootLink_Event_ScanAuction;
	LootLink_Event_ScanAuction = Auctioneer_AuctionEntry_Hook;
    
    -- Hook PlaceAuctionBid
	Auctioneer_Old_BidHandler = PlaceAuctionBid;
	PlaceAuctionBid = Auctioneer_PlaceAuctionBid;
    
    LootLink_Event_FinishedAuctionScan = Auctioneer_FinishedAuctionScan_Hook;

	SLASH_AUCTIONEER1 = "/auctioneer";
	SlashCmdList["AUCTIONEER"] = function(msg)
		Auctioneer_Command(msg);
	end
	
	if ( DEFAULT_CHAT_FRAME ) then 
		DEFAULT_CHAT_FRAME:AddMessage("Auctioneer v"..AUCTIONEER_VERSION.." loaded", 0.8, 0.8, 0.2);
	end
end

function Auctioneer_Command(command)
	local i,j, cmd, param = string.find(command, "^([^ ]+) (.+)$");
	if (not cmd) then cmd = command; end
	if (not cmd) then cmd = ""; end
	if (not param) then param = ""; end

	if ((cmd == "") or (cmd == "help")) then
		Auctioneer_ChatPrint("Usage:");
		Auctioneer_ChatPrint("  |cffffffff/auctioneer (on|off|toggle)|r |cff2040ff["..Auctioneer_GetFilterVal("all").."]|r - turns the auction data display on and off");
		Auctioneer_ChatPrint("  |cffffffff/auctioneer average (on|off|toggle)|r |cff2040ff["..Auctioneer_GetFilterVal("average").."]|r - select whether to show item's average auction price");
        Auctioneer_ChatPrint("  |cffffffff/auctioneer median (on|off|toggle)|r |cff2040ff["..Auctioneer_GetFilterVal("median").."]|r - select whether to show item's median buyout price");
		Auctioneer_ChatPrint("  |cffffffff/auctioneer suggest (on|off|toggle)|r |cff2040ff["..Auctioneer_GetFilterVal("suggest").."]|r - select whether to show item's suggested auction price");
		Auctioneer_ChatPrint("  |cffffffff/auctioneer stats (on|off|toggle)|r |cff2040ff["..Auctioneer_GetFilterVal("stats").."]|r - select whether to show item's bidded/buyout percentages");
		Auctioneer_ChatPrint("  |cffffffff/auctioneer vendor (on|off|toggle)|r |cff2040ff["..Auctioneer_GetFilterVal("vendor").."]|r - select whether to show item's vendor pricing");
		Auctioneer_ChatPrint("  |cffffffff/auctioneer vendorsell (on|off|toggle)|r |cff2040ff["..Auctioneer_GetFilterVal("vendor").."]|r - select whether to show item's vendor sell pricing (req vendor=on)");
		Auctioneer_ChatPrint("  |cffffffff/auctioneer vendorbuy (on|off|toggle)|r |cff2040ff["..Auctioneer_GetFilterVal("vendor").."]|r - select whether to show item's vendor buy pricing (req vendor=on)");
		Auctioneer_ChatPrint("  |cffffffff/auctioneer usage (on|off|toggle)|r |cff2040ff["..Auctioneer_GetFilterVal("usage").."]|r - select whether to show tradeskill item's usage");
		Auctioneer_ChatPrint("  |cffffffff/auctioneer stacksize (on|off|toggle)|r |cff2040ff["..Auctioneer_GetFilterVal("stacksize").."]|r - select whether to show the item's stackable size");
		Auctioneer_ChatPrint("  |cffffffff/auctioneer clear <item|all>|r - clear the specified item's lootlink data (you may shift click insert multiple items into this command, or specify only one textually) If you specify 'all' by itself, the entire dataset for this server will be cleared");
	elseif (cmd == "on") then
		Auctioneer_SetFilter("all", "on");
		Auctioneer_ChatPrint("Displaying configured auction data");
	elseif (cmd == "off") then
		Auctioneer_SetFilter("all", "off");
		Auctioneer_ChatPrint("Not displaying any auction data");
	elseif (cmd == "toggle") then
		local cur = Auctioneer_GetFilterVal("all");
		if (cur == "off") then
			Auctioneer_SetFilter("all", "on");
			Auctioneer_ChatPrint("Displaying configured auction data");
		else
			Auctioneer_SetFilter("all", "off");
			Auctioneer_ChatPrint("Not displaying any auction data");
		end
	elseif (cmd == "clear") then
		if (param == "all") then
			local aKey = auctionKey();
			Auctioneer_ChatPrint("Clearing all auction data for "..aKey);
			AuctionPrices[aKey] = {};
            AHSnapshot = {};
            AHSnapshotItemPrices = {};
        elseif (param == "snapshot") then
            Auctioneer_ChatPrint("Clearing current Auction House snapshot.");
            AHSnapshot = {};
            AHSnapshotItemPrices = {};  
            lSnapshotItemPrices = {};            
		else
			local items = Auctioneer_GetItems(param);
			for _,item in items do
				local aKey = auctionKey();
				if (AuctionPrices[aKey][item] ~= nil) then
					AuctionPrices[aKey][item] = nil;
					Auctioneer_ChatPrint("Clearing data for item "..item);
				else
					Auctioneer_ChatPrint("Unable to find item "..item);
				end
			end
		end
	elseif (cmd == "also") then
		Auctioneer_SetFilter("also", param);        
	elseif (cmd == "broker") then
        doBroker(param);
    elseif (cmd == "bidbroker") then
        doBidBroker(param);        
	elseif (cmd == "percentless") then
        doPercentLess(param);           
    elseif (cmd == "test") then
        doTests();
    elseif (cmd == "low") then
        doLow(param);   
    elseif (cmd == "med") then
        doMedian(param);  
    elseif (cmd == "hsp") then
        doHSP(param);  
	elseif ((cmd == "average") or (cmd == "median") or(cmd == "suggest") or (cmd == "stats") or (cmd == "vendor") or (cmd == "usage") or (cmd == "stacksize") or (cmd == "vendorsell") or (cmd == "vendorbuy")) then
		if ((param == "false") or (param == "off") or (param == "no") or (param == "0")) then
			Auctioneer_SetFilter(cmd, "off");
			Auctioneer_ChatPrint("Not displaying item's "..cmd.." data");
		elseif (param == "toggle") then
			local cur = Auctioneer_GetFilterVal(cmd);
			if (cur == "on") then
				cur = "off";
				Auctioneer_ChatPrint("Not displaying item's "..cmd.." data");
			else
				cur = "on";
				Auctioneer_ChatPrint("Displaying item's "..cmd.." data");
			end
			Auctioneer_SetFilter(cmd, cur);
		else
			Auctioneer_SetFilter(cmd, "on");
			Auctioneer_ChatPrint("Displaying item's "..cmd.." data");
		end
	elseif (cmd == "bargains") then
		if (not AHSnapshot) then
			Auctioneer_ChatPrint("You must have scanned the auction house recently to use this feature.");
		else
			Auctioneer_ChatPrint("Searching for bargains in last auction scan...");
			Auctioneer_BargainScan();
		end        
	else
		Auctioneer_ChatPrint("Unknown command keyword: '"..cmd.."'");
	end
end

function Auctioneer_SetFilter(type, value)
	if (not AuctionConfig.filters) then AuctionConfig.filters = {}; end
	AuctionConfig.filters[type] = value;
end

function Auctioneer_GetFilterVal(type)
	if (not AuctionConfig.filters) then AuctionConfig.filters = {}; end
	value = AuctionConfig.filters[type];
	if (not value) then return "on"; end
	return value;
end

function Auctioneer_GetFilter(filter)
	value = Auctioneer_GetFilterVal(filter);
	if (value == "on") then return true;
	elseif (value == "off") then return false; end
	return true;
end

function Auctioneer_ChatPrint(str)
	if ( DEFAULT_CHAT_FRAME ) then 
		DEFAULT_CHAT_FRAME:AddMessage(str, 0.0, 1.0, 0.25);
	end
end

function Auctioneer_GetItems(str)
	local itemList = {};
	local listSize = 0;
	for item in string.gfind(str, "|Hitem:[^|]+|h[[]([^]]+)[]]|h") do
		listSize = listSize+1;
		itemList[listSize] = item;
	end
	if (listSize == 0) then
		listSize = listSize+1;
		itemList[listSize] = str;
	end
	return itemList;
end


function Auctioneer_GameTooltip_ClearMoney()
	lOriginalGameTooltip_ClearMoney();
	lAuctioneerCheckTooltip = Auctioneer_CheckTooltipInfo(GaeTooltip);
end

function Auctioneer_GameTooltip_OnHide()
	lOriginalGameTooltip_OnHide();
	GameTooltip.eDone = nil;
	if ( lAuctioneerTooltip ) then
		lAuctioneerTooltip.eDone = nil;
		lAuctioneerTooltip = nil;
	end
end

function Auctioneer_OnUpdate(elapsed)
	lAuctioneerCheckTimer = lAuctioneerCheckTimer + elapsed;
	if( lAuctioneerCheckTimer >= 0.2 ) then
		if( lAuctioneerCheckTooltip ) then
			lAuctioneerCheckTooltip = Auctioneer_CheckTooltipInfo(lAuctioneerTooltip);
		end
		lAuctioneerCheckTimer = 0;
	end
end

function Auctioneer_SetItemRef(link)
	lOriginalSetItemRef(link);
	lAuctioneerCheckTooltip = Auctioneer_CheckTooltipInfo(ItemRefTooltip);
end

function Auctioneer_CheckTooltipInfo(frame)
	-- If we've already added our information, no need to do it again
	if ( not frame or frame.eDone ) then
		return nil;
	end

	lAuctioneerTooltip = frame;

	if( frame:IsVisible() ) then
		local field = getglobal(frame:GetName().."TextLeft1");
		if( field and field:IsVisible() ) then
			local name = field:GetText();
			if( name ) then
				Auctioneer_AddTooltipInfo(frame, name);
				return nil;
			end
		end
	end
	
	return 1;
end


function Auctioneer_OnEvent(event)
	if (event=="NEW_AUCTION_UPDATE") then
        local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo();
        if name then
            local itemData = getAuctionPriceData(name);
			local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = getAuctionPrices(itemData);            
            
            -- get highest sellable price for buyout
            local hsp = getHighestSellablePriceForOne(name, false);
            if hsp == 0 and buyCount > 0 then
                hsp =  math.floor(buyPrice / buyCount); -- use mean buyout if median not available
            end
            
            -- calculate average min for start price
            local minbid = 0
            if minCount > 0 then 
                minbid = math.floor(minPrice / minCount);
            end
            if minbid > hsp then
                minbid = subtractPercent(hsp, 15); -- 15% less than median
            end
            
            if hsp > 0 and minbid > 0 then
                MoneyInputFrame_SetCopper(StartPrice, minbid * count);
                MoneyInputFrame_SetCopper(BuyoutPrice, hsp * count);
            elseif Auctioneer_BasePrices[getNumericItemId(name)].s then -- see if we have vendor sell info for this item
                -- use vendor prices if no auction data available
                local itemInfo = Auctioneer_BasePrices[getNumericItemId(name)];
                local vendorSell = nullSafe(itemInfo.s);
                MoneyInputFrame_SetCopper(StartPrice, (vendorSell * count) * 1.5);
                MoneyInputFrame_SetCopper(BuyoutPrice, (vendorSell * count) * 3);
            end
        end
	end
    if (event=="AUCTION_HOUSE_SHOW") then
        AuctionsShortAuctionButton:SetChecked(nil);
        AuctionsMediumAuctionButton:SetChecked(nil);
        AuctionsLongAuctionButton:SetChecked(nil);
    
        -- default to 24 hour auctions
        AuctionsLongAuctionButton:SetChecked(1);
        AuctionFrameAuctions.duration = 1440;
	end
end


local function getRRP(itemID, from)
	if (from == nil) then from = auctionKey(); end
	if (from == "also") then from = Auctioneer_GetFilterVal(also); end
	if ((from == "on") or (from == "off")) then return 0; end
	if (from == "opposite") then from = oppositeKey(); end
		
	local itemData = getAuctionPriceData(itemID, from);
	local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = getAuctionPrices(itemData);
--	p("Getting data from "..from.." for "..itemID, itemData);

	local bidRatio = bidCount/minCount;
	local avgMin = minPrice/minCount;
	local avgBid = bidPrice/bidCount;
	local diff = avgBid - avgMin;
	local rrp = diff * bidRatio + avgMin;

--	p("br = ", bidRatio, "am = ", avgMin, "ab = ", avgBid, "dif = ", diff, "rrp = ", rrp);
	
	return rrp;
end

function Auctioneer_BargainScan()
	local bargains = {};
	local lastBargain = 0;
	for key, val in AHSnapshot do
		local id,name,count,min,buyout = getItemSignature(key);
        local auctioner = val.owner;
		local bid = val.bidamount;
		local link = val.itemLink;

		id = 0+id;
		min = 0+min;
		buyout = 0+buyout;
		count = 0+count;

		local itemInfo = Auctioneer_BasePrices[id];

		local competition = 0;
		if (bid == 0) then bid = min; end
		competition = bid / min;

		local vendorBuy = 0;
		local vendorSell = 0;
		if (itemInfo) then
			if (itemInfo.b) then vendorBuy = 0+ itemInfo.b; end
			if (itemInfo.s) then vendorSell = 0+ itemInfo.s; end
		end

		local serverRRP = getRRP(id) * 1.05; -- costs about 5% to auction
		local otherRRP = getRRP(id, "also") * 1.15; -- costs about 15% to xfr to other faction
		
		local value = {s=serverRRP, o=otherRRP, bid=bid, buy=buyout, v=vendorSell};
		-- p(key, value);
		local bargain = nil;

		local best = 0;
		local profit = vendorSell-buyout;
		local action = "";
		if ((vendorSell > 0) and (buyout > 0) and (buyout < vendorSell)) then
			action = "buy and trash";
			best = profit;
		end
		profit = serverRRP-buyout;
		if ((buyout > 0) and (buyout < serverRRP)) then
			if (profit > best) then
				if (action == "buy and trash") then
					action = "buy and auction (or trash)";
				else
					action = "buy and auction";
				end
				best = profit;
			end
		end
		profit = otherRRP-buyout;
		if ((buyout > 0) and (buyout < otherRRP)) then
			if (profit > best) then
				action = "buy and transfer";
				best = profit;
			end
		end
		if (best == 0) then
			profit = vendorSell-bid;
			if ((vendorSell > 0) and (bid < vendorSell)) then
				action = "bid and trash";
				best = profit;
			end
			profit = serverRRP-bid;
			if ((bid < serverRRP) and (competition < 10)) then
				if (profit > best) then
					if (action == "bid and trash") then
						action = "bid and auction (or trash)";
					else
						action = "bid and auction";
					end
					best = profit;
				end
			end
			profit = otherRRP-bid;
			if ((bid < otherRRP) and (competition < 10)) then
				if (profit > best) then
					action = "bid and transfer";
					best = profit;
				end
			end
		end

		if (best > 0) then
			bargain = { s=key, a=action, c=competition, p=best, v=value };
			lastBargain = lastBargain + 1;
			bargains[lastBargain] = bargain;
		end
	end

--	table.sort(bargains, function(a,b) return a.r>b.r or a.p>b.p end);

	for i=1, 25 do
		local b = bargains[i];
		if  (b ~= nil) then
		    local id,name,count,min,buyout = getItemSignature(b.s);
            local auctioner = AHSnapshot[b.s].owner;
            local link = AHSnapshot[b.s].itemLink;
			if (auctioner == nil) then auctioner = "unknown"; end
			if (name == nil) then name = "unknown"; end
			local action = b.a;
			if (action == nil) then action = "unknown"; end
			local profit = b.p;
			if (profit == nil) then profit = 0; end
			profit = 0+ profit;
			Auctioneer_ChatPrint("Found a "..link.." from "..auctioner.." which you can "..action.." for "..Auctioneer_GetTextGSC(profit).." profit");
		end
	end
end
