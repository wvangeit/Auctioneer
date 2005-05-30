-- Auctioneer
AUCTIONEER_VERSION="<%version%>";
-- Revision: $Id$
-- Original version written by Norganna.
-- Contributors: Araband
--
-- This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
-- when the auction is scanned, so that you can easily determine what price
-- you will be able to sell an item for at auction or at a vendor whenever you
-- mouse-over an item in the game
--
--
if (AUCTIONEER_VERSION == "<".."%version%>") then
	AUCTIONEER_VERSION = "3.DEV";
end

local MAX_ALLOWED_FORMAT_INT = 2000000000; -- numbers much greater than this overflow when using format("%d")

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

-- min median buyout price for an item to show up in the list of items below median
local DEFAULT_COMPETE_LESS = 5;

-- min times an item must be seen before it can show up in the list of items below median
local MIN_BUYOUT_SEEN_COUNT = 7;

-- max buyout price for an auction to display as a good deal item
local MAX_BUYOUT_PRICE = 800000;

-- the default percent less, only find auctions that are at a minimum this percent less than the median
local MIN_PERCENT_LESS_THAN_MEDIAN = 60; -- 60% default

-- the minimum profit/price percent that an auction needs to be displayed as a resellable auction
local MIN_PROFIT_PRICE_PERCENT = 30; -- 30% default

-- the minimum percent of bids placed on an item to be considered an "in-demand" enough item to be traded, this is only applied to Weapons and Armor and Recipies
local MIN_BID_PERCENT = 10;


--[[ SavedVariables --]]
AuctionBids = {};          --Table that stores all your bids
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

-- Item quality constants
local QUALITY_EPIC = 4;
local QUALITY_RARE = 3;
local QUALITY_UNCOMMON = 2;
local QUALITY_COMMON= 1;
local QUALITY_POOR= 0;

-- return the string representation of the given timeLeft constant
local function getTimeLeftString(timeLeft)
    local timeLeftString = "";
    -- TODO: localize these strings
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
function nilSafeString(str)
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
    if nullSafe(value1) > 0 and nullSafe(value2) < nullSafe(value1) then
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

local function sanifyAHSnapshot()
	local auctKey = auctionKey();
	if (not AHSnapshot) then
		AHSnapshot = { [auctKey] = {}}; 
	elseif (not AHSnapshot[auctKey]) then
		AHSnapshot[auctKey] = {};
	end
	if (not AHSnapshotItemPrices) then
		AHSnapshotItemPrices = { [auctKey] = {}}; 
	elseif (not AHSnapshotItemPrices[auctKey]) then
		AHSnapshotItemPrices[auctKey] = {};
	end
	return auctKey;
end

--this function sets the dirty flag to true for all the auctions in the snapshot
--this is done to indicate that the snapshot is out of date.
local function invalidateAHSnapshot()
    -- invalidate the snapshot
	local auctKey = sanifyAHSnapshot();
    for i,a in AHSnapshot[auctKey] do
        a.dirty = 1;
    end
end


-- called when the auction scan starts
local function Auctioneer_AuctionStart_Hook()
	Auction_DoneItems = {};
    lSnapshotItemPrices = {};
    invalidateAHSnapshot();
    
    -- make sure AuctionPrices is initialized
    local serverFaction = auctionKey();
	if (AuctionPrices[serverFaction] == nil) then
		AuctionPrices[serverFaction] = {};
	end
    
    -- reset scan audit counters
    lTotalAuctionsScannedCount = 0;
    lNewAuctionsCount = 0;
    lOldAuctionsCount = 0;
    lDefunctAuctionsCount = 0;
end


-- this is called when an auction scan finishes and is used for clean up
local function Auctioneer_FinishedAuctionScan_Hook()
    -- only remove defunct auctions from snapshot if there was a good amount of auctions scanned.
	local auctKey = sanifyAHSnapshot();

    if lTotalAuctionsScannedCount > 250 then 
        for i,a in AHSnapshot[auctKey] do
            if (a.dirty == 1) then
                AHSnapshot[auctKey][i] = nil; --clear defunct auctions
                lDefunctAuctionsCount = lDefunctAuctionsCount + 1;
            end
        end
    end
    
    -- copy the item prices into the Saved item prices table
    AHSnapshotItemPrices[auctKey] = lSnapshotItemPrices;

    local lDiscrepencyCount = lTotalAuctionsScannedCount - (lNewAuctionsCount + lOldAuctionsCount);
    
    Auctioneer_ChatPrint("Total auctions scanned: "..colorTextWhite(lTotalAuctionsScannedCount));
    Auctioneer_ChatPrint("New auctions scanned: "..colorTextWhite(lNewAuctionsCount));
    Auctioneer_ChatPrint("Previously scanned: "..colorTextWhite(lOldAuctionsCount));
    Auctioneer_ChatPrint("Defunct auctions removed: "..colorTextWhite(lDefunctAuctionsCount));
    
    if (nullSafe(lDiscrepencyCount) > 0) then
        Auctioneer_ChatPrint("Discrepencies: "..colorTextWhite(lDiscrepencyCount));
    end
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

local function breakLink(link)
	local i,j, itemID, enchant, randomProp, uniqID, name = string.find(link, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h[[]([^]]+)[]]|h");
	return tonumber(itemID), tonumber(randomProp), tonumber(enchant), tonumber(uniqID), name;
end

local function breakItemKey(itemKey)
	local i,j, itemID, randomProp, enchant = string.find(itemKey, "(%d+):(%d+):(%d+)");
	return tonumber(itemID), tonumber(randomProp), tonumber(enchant);
end

-- returns an AuctionPrices item from the table based on an item name
local function getAuctionPriceItem(itemKey, from, name, id)
    local serverFaction = auctionKey();
    local auctionPriceItem;
    
    if (from ~= nil) then serverFaction = from; end
	if (AuctionPrices[serverFaction] == nil) then
		AuctionPrices[serverFaction] = {};
    elseif AuctionPrices[serverFaction][itemKey] then
        auctionPriceItem = AuctionPrices[serverFaction][itemKey];
    elseif AuctionPrices[serverFaction][name] then
        auctionPriceItem = AuctionPrices[serverFaction][name];
    elseif AuctionPrices[serverFaction][id] then
        auctionPriceItem = AuctionPrices[serverFaction][id];
    end
    
    return auctionPriceItem;
end


-- wrapper for getting AuctionPrices data that is backward compatible with old AuctionPrices keys
local function getAuctionPriceData(itemKey, from, name, id)
	local auctionItem = getAuctionPriceItem(itemKey, from, name, id);
	if (auctionItem == nil) or (auctionItem.data == nil) then 
		link = "0:0:0:0:0:0:0";
    else
        link = auctionItem.data;
	end
	return link;
end



-- returns the auction buyout history for this item
function getAuctionBuyoutHistory(itemKey, name)
	local auctionItem = getAuctionPriceItem(itemKey, nil, name);
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
	local i,j, id,rprop,enchant,name,count,min,buyout,uniq = string.find(sigData, "^(%d+):(%d+):(%d+):(.-):(%d+):(.-):(%d+):(.+)");
	if (name == nil) then name = ""; end
	return tonumber(id),tonumber(rprop),tonumber(enchant),name,tonumber(count),tonumber(min),tonumber(buyout),tonumber(uniq);
end

-- returns the category i.e. "Weapon", "Armor" for an item
local function getItemCategory(itemKey)
    local category;
    local auctionItem = getAuctionPriceItem(itemKey);
    if auctionItem then 
        category = auctionItem.category;
    end
    return category;
end


local function getItemPlayerMade(itemKey)
    local playerMade;
    local auctionItem = getAuctionPriceItem(itemKey);
    if auctionItem then 
        playerMade = auctionItem.playerMade;
    end
    return playerMade;
end

-- returns the current snapshot median for an item
function getItemSnapshotMedianBuyout(itemKey)
    local buyoutPrices = {};
	local auctKey = sanifyAHSnapshot();
    if AHSnapshotItemPrices[auctKey][itemKey] then 
        buyoutPrices = AHSnapshotItemPrices[auctKey][itemKey].buyoutPrices;
    else
        return nil, nil;
    end

    return getMedian(buyoutPrices), table.getn(buyoutPrices);
end

local function getItemHistoricalMedianBuyout(itemKey, name)
    local buyoutHistoryTable = getAuctionBuyoutHistory(itemKey, name);
    local historyMedian = getMedian(buyoutHistoryTable);
    local historySeenCount = table.getn(buyoutHistoryTable);
    return historyMedian, historySeenCount;
end

-- this function returns the most accurate median possible, 
-- if an accurate median cannot be obtained based on min seen counts then nil is returned
function getUsableMedian(itemKey, name)
    local usableMedian = nil;
    local count = nil;

    --get snapshot median
    local snapshotMedian, snapshotCount = getItemSnapshotMedianBuyout(itemKey);
   
    --get history median
    local historyMedian, historySeenCount = getItemHistoricalMedianBuyout(itemKey, name);
    
    if historyMedian and (not snapshotMedian or snapshotCount < MIN_BUYOUT_SEEN_COUNT or snapshotMedian > (historyMedian + (historyMedian * .20))) then
        if historySeenCount >= MIN_BUYOUT_SEEN_COUNT then -- could not obtain a usable median
            usableMedian = historyMedian;
            count = historySeenCount;
        end
    elseif snapshotMedian then
        usableMedian = snapshotMedian;
        count = snapshotCount;
    end
    
    return usableMedian, count;
end

-- returns true if they link is likely a player made item
local function isPossiblePlayerMadeItem(link)
    local itemID, randomProp, enchant, uniqID = breakLink(link);
    if randomProp == 0 and uniqID > 0 then
        return true;
    end
    return false;
end


-- returns the current bid on an auction
local function getCurrentBid(auctionSignature)
    local _,_,_, _, _,min,_,_ = getItemSignature(auctionSignature);
	local auctKey = sanifyAHSnapshot();
    local currentBid = AHSnapshot[auctKey][auctionSignature].bidamount;
    if currentBid == 0 then currentBid = min end   
    return currentBid;     
end


-- this filter will return true if an auction is a bad choice for reselling
local function isBadResaleChoice(auctionSignature)
    local isBadChoice = false;
    local id,rprop,enchant, name, count,min,buyout,uniq = getItemSignature(auctionSignature);
	local itemKey = id..":"..rprop..":"..enchant;
	local auctKey = sanifyAHSnapshot();
    local auctionItem = AHSnapshot[auctKey][auctionSignature];
    local itemData = getAuctionPriceData(itemKey);
    local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = getAuctionPrices(itemData);    
    local bidPercent = math.floor(bidCount / minCount * 100);
        
    -- bad choice conditions
    if (auctionItem.level >= 50 and auctionItem.quality == QUALITY_UNCOMMON and bidPercent < MIN_BID_PERCENT) then -- level 50 and greater greens do not sell well
        isBadChoice = true;    
    elseif auctionItem.owner == UnitName("player") or auctionItem.highBidder then -- don't display auctions that we own, or are high bidder on
        isBadChoice = true;
    elseif auctionItem.quality == QUALITY_POOR then -- gray items are never a good choice
        isBadChoice = true;
    end
    
    return isBadChoice;
end

-- filters out all auctions except those that meet profit requirements
local function brokerFilter(minProfit, signature)
    local filterAuction = true;
    local id,rprop,enchant, name, count,min,buyout,uniq = getItemSignature(signature);
	local itemKey = id..":"..rprop..":"..enchant;
        
    if getUsableMedian(itemKey) then -- we have a useable median
        local hsp = getHighestSellablePriceForOne(itemKey, true, AHSnapshot[sanifyAHSnapshot()][signature].category);
        local profit = (hsp * count) - buyout;
        local profitPricePercent = math.floor((profit / buyout) * 100);

        --see if this auction should not be filtered
        if (buyout > 0 and buyout <= MAX_BUYOUT_PRICE and profit >= minProfit and not isBadResaleChoice(signature) and profitPricePercent >= MIN_PROFIT_PRICE_PERCENT) then
            filterAuction = false;
        end
    end        
    
    return filterAuction;
end


-- filters out all auctions except those that have short or medium time remaining and meet profit requirements
local function bidBrokerFilter(minProfit, signature)
    local filterAuction = true;
    local id,rprop,enchant, name, count,min,buyout,uniq = getItemSignature(signature);
	local itemKey = id..":"..rprop..":"..enchant;
    
    if getUsableMedian(itemKey) then  -- only add if we have seen it enough times to have a usable median
        local currentBid = getCurrentBid(signature);
        local hsp = getHighestSellablePriceForOne(itemKey, true, AHSnapshot[sanifyAHSnapshot()][signature].category);
        local profit = (hsp * count) - currentBid;
        local profitPricePercent = math.floor((profit / currentBid) * 100);
        
        --see if this auction should not be filtered
		local auctKey = sanifyAHSnapshot();
        if (currentBid <= MAX_BUYOUT_PRICE and profit >= minProfit and AHSnapshot[auctKey][signature].timeLeft <= TIME_LEFT_MEDIUM and not isBadResaleChoice(signature) and profitPricePercent >= MIN_PROFIT_PRICE_PERCENT) then
            filterAuction = false;
        end
    end
    
    return filterAuction;
end

local function auctionOwnerFilter(owner, signature)
	local auctKey = sanifyAHSnapshot();
    if (AHSnapshot[auctKey][signature].owner == owner) then
		return false;
    end
    return true;
end

local function competingFilter(minLess, signature, myAuctions)
    local id,rprop,enchant, name, count,min,buyout,uniq = getItemSignature(signature);
	if (count > 1) then buyout = buyout/count; end
	local itemKey = id..":"..rprop..":"..enchant;
   
	local auctKey = sanifyAHSnapshot();
    if (AHSnapshot[auctKey][signature].owner ~= UnitName("player")) and
		(myAuctions[itemKey]) and
		(buyout > 0) and
		(buyout+minLess < myAuctions[itemKey]) then
		return false;
    end
    return true;
end


-- filters out all auctions that are not a given percentless than the median for that item.
local function percentLessFilter(percentLess, signature)
    local filterAuction = true;
    local id,rprop,enchant, name, count,min,buyout,uniq = getItemSignature(signature);
	local itemKey = id .. ":" .. rprop..":"..enchant;
    local median = getUsableMedian(itemKey);

    if median then
        local profit = (median * count) - buyout;
        
        --see if this auction should not be filtered
        if (buyout > 0 and percentLessThan(median, buyout / count) >= tonumber(percentLess) and profit >= MIN_PROFIT_MARGIN) then                        
            filterAuction = false;
        end
    end      

    return filterAuction;
end


-- generic function for querying the snapshot with a filter function that returns true if an auction should be filtered out of the result set.
local function querySnapshot(filter, param, extra1, extra2)
    local queryResults = {};
    param = param or "";
    
	local auctKey = sanifyAHSnapshot();
    for auctionSignature,a in AHSnapshot[auctKey] do
        if(not filter(param, auctionSignature, extra1, extra2)) then
            table.insert(queryResults, a); -- for some reason we have to use table.insert in order to use table.sort later
            queryResults[table.getn(queryResults)].signature = auctionSignature;         
        end
    end    
    
    return queryResults;
end


-- method to pass to table.sort() that sorts auctions by profit descending
local function profitComparisonSort(a, b)
        local aid,arprop,aenchant, aName, aCount, _, aBuyout, _ = getItemSignature(a.signature);             
        local bid,brprop,benchant, bName, bCount, _, bBuyout, _ = getItemSignature(b.signature);
		local aItemKey = aid .. ":" .. arprop..":"..aenchant;
		local bItemKey = bid .. ":" .. brprop..":"..benchant;
        local aProfit = (getHighestSellablePriceForOne(aItemKey, true, AHSnapshot[sanifyAHSnapshot()][a.signature].category) * aCount) - aBuyout;    
        local bProfit = (getHighestSellablePriceForOne(bItemKey, true, AHSnapshot[sanifyAHSnapshot()][b.signature].category) * bCount) - bBuyout;            
        return (aProfit > bProfit) 
end
        
        
-- builds the list of auctions that can be bought and resold for profit
function doBroker(minProfit)
    if not minProfit or minProfit == "" then minProfit = MIN_PROFIT_MARGIN else minProfit = tonumber(minProfit) * 100  end
	local output = string.format(AUCT_FRMT_BROKER_HEADER, Auctioneer_GetTextGSC(minProfit));
    Auctioneer_ChatPrint(output);
    
    local resellableAuctions = querySnapshot(brokerFilter, minProfit);
    
    -- sort by profit decending
    table.sort(resellableAuctions, profitComparisonSort);
    
    -- output the list of auctions
    for _,a in resellableAuctions do
        local id,rprop,enchant, name, count,min,buyout,uniq = getItemSignature(a.signature); 
		local itemKey = id .. ":" .. rprop..":"..enchant;
        local hsp, seenCount = getHighestSellablePriceForOne(itemKey, true, a.category);
        local profit = (hsp * count) - buyout;
		local output = string.format(AUCT_FRMT_BROKER_LINE, colorTextWhite(count.."x")..a.itemLink, seenCount, Auctioneer_GetTextGSC(hsp * count), Auctioneer_GetTextGSC(buyout), Auctioneer_GetTextGSC(profit));
        Auctioneer_ChatPrint(output);
    end
    
    Auctioneer_ChatPrint(AUCT_FRMT_BROKER_DONE);
end

-- builds the list of auctions that can be bought and resold for profit
function doBidBroker(minProfit)
    if not minProfit or minProfit == "" then minProfit = MIN_PROFIT_MARGIN else minProfit = tonumber(minProfit) * 100  end
	local output = string.format(AUCT_FRMT_BIDBROKER_HEADER, Auctioneer_GetTextGSC(minProfit));
    Auctioneer_ChatPrint(output);
    
    local bidWorthyAuctions = querySnapshot(bidBrokerFilter, minProfit);
    
    table.sort(bidWorthyAuctions, function(a, b) return (a.timeLeft < b.timeLeft) end);
    
    -- output the list of auctions 
    for _,a in bidWorthyAuctions do
        local id,rprop,enchant, name, count,min,buyout,uniq = getItemSignature(a.signature); 
		local itemKey = id .. ":" .. rprop..":"..enchant;
        local hsp, seenCount = getHighestSellablePriceForOne(itemKey, true, a.category);
        local currentBid = getCurrentBid(a.signature);
        local profit = (hsp * count) - currentBid;

		local bidText = Auctioneer_GetTextGSC(currentBid);
		if (currentBid == min) then
			bidText = "none ("..bidText.." min)";
		end
		local output = string.format(AUCT_FRMT_BIDBROKER_LINE, colorTextWhite(count.."x")..a.itemLink, seenCount, Auctioneer_GetTextGSC(hsp * count), bidText, Auctioneer_GetTextGSC(profit), colorTextWhite(getTimeLeftString(a.timeLeft)));
		Auctioneer_ChatPrint(output);
    end
    
    Auctioneer_ChatPrint(AUCT_FRMT_BIDBROKER_DONE);
end

function doCompeting(minLess)
    if not minLess or minLess == "" then minLess = DEFAULT_COMPETE_LESS * 100 else minLess = tonumber(minLess) * 100  end
	local output = string.format(AUCT_FRMT_COMPETE_HEADER, Auctioneer_GetTextGSC(minLess));
    Auctioneer_ChatPrint(output);
    
    local myAuctions = querySnapshot(auctionOwnerFilter, UnitName("player"));
	local myHighestPrices = {}
	for _,a in myAuctions do
        local id,rprop,enchant, name, count,min,buyout,uniq = getItemSignature(a.signature);
		if (count > 1) then buyout = buyout/count; end
		local itemKey = id .. ":" .. rprop..":"..enchant;
		if (not myHighestPrices[itemKey]) or (myHighestPrices[itemKey] < buyout) then
			myHighestPrices[itemKey] = buyout;
		end
	end
    local competingAuctions = querySnapshot(competingFilter, minLess, myHighestPrices);
    
    table.sort(competingAuctions, profitComparisonSort);
    
    -- output the list of auctions 
    for _,a in competingAuctions do
        local id,rprop,enchant, name, count,min,buyout,uniq = getItemSignature(a.signature); 
		local itemKey = id .. ":" .. rprop..":"..enchant;
        local currentBid = getCurrentBid(a.signature);

		local buyoutForOne = buyout;
		local bidForOne = currentBid;
		if (count > 1) then
			buyoutForOne = buyout/count;
			bidForOne = currentBid/count;
		end

		local bidPrice = Auctioneer_GetTextGSC(bidForOne).."ea";
		if (currentBid == min) then
			bidPrice = "No bids ("..bidPrice..")";
		end

		local myBuyout = myHighestPrices[itemKey];
		local buyPrice = Auctioneer_GetTextGSC(buyoutForOne).."ea";
		local myPrice = Auctioneer_GetTextGSC(myBuyout).."ea";
		local priceLess = myBuyout - buyoutForOne;
		local lessPrice = Auctioneer_GetTextGSC(priceLess);

		local output = string.format(AUCT_FRMT_COMPETE_LINE, colorTextWhite(count.."x")..a.itemLink, bidPrice, buyPrice, myPrice, lessPrice);
		Auctioneer_ChatPrint(output);
    end
    
    Auctioneer_ChatPrint(AUCT_FRMT_COMPETE_DONE);
end

-- builds the list of auctions that can be bought and resold for profit
function doPercentLess(percentLess)    
    if not percentLess or percentLess == "" then percentLess = MIN_PERCENT_LESS_THAN_MEDIAN end
	local output = string.format(AUCT_FRMT_PCTLESS_HEADER, percentLess);
    Auctioneer_ChatPrint(output);
    
    local auctionsBelowMedian = querySnapshot(percentLessFilter, percentLess);
    
    -- sort by profit based on median
    table.sort(auctionsBelowMedian, profitComparisonSort);
    
    -- output the list of auctions
    for _,a in auctionsBelowMedian do
        local id,rprop,enchant, name, count,_,buyout,_ = getItemSignature(a.signature);         
		local itemKey = id ..":"..rprop..":"..enchant;
        local median, seenCount = getUsableMedian(itemKey);
        local profit = (median * count) - buyout;
		local output = string.format(AUCT_FRMT_PCTLESS_LINE, colorTextWhite(count.."x")..a.itemLink, seenCount, Auctioneer_GetTextGSC(median * count), Auctioneer_GetTextGSC(buyout), Auctioneer_GetTextGSC(profit), colorTextWhite(percentLessThan(median, buyout / count).."%"));
        Auctioneer_ChatPrint(output);
    end
    
    Auctioneer_ChatPrint(AUCT_FRMT_PCTLESS_DONE);
end

-- given an item name, find the lowest price for that item in the current AHSnapshot
-- if the item does not exist in the snapshot or the snapshot does not exist
-- a nil is returned.
function findLowestAuctionForItem(itemKey)
	local itemID, itemRand, enchant = breakItemKey(itemKey);
	if (itemID == nil) then return nil; end
	
    local lowSig = nil;
    local lowestPrice = 9000000; -- initialize to a very high value, 900 gold
	local auctKey = sanifyAHSnapshot();
    for sig,v in AHSnapshot[auctKey] do
        local id,rprop,enchant, name, count,min,buyout,uniq = getItemSignature(sig);
        local priceForOne = 0;
		if (count and count > 0) then priceForOne = (buyout / count); end
        if (tonumber(itemID) == tonumber(id) and tonumber(itemRand) == tonumber(rprop) and buyout > 0 and priceForOne < lowestPrice) then 
            lowSig = sig;
            lowestPrice = priceForOne;
        end
    end
    return lowSig;
end

-- quick index to lowest snapshot price of an item
function getLowestPriceQuick(itemKey)
    local lowestPriceForOne = nil;
    
   local auctKey = sanifyAHSnapshot();
   if AHSnapshotItemPrices[auctKey][itemKey] then 
        buyoutPrices = AHSnapshotItemPrices[auctKey][itemKey].buyoutPrices;
        table.sort(buyoutPrices)
        lowestPriceForOne = buyoutPrices[1];
    end
    
    return lowestPriceForOne;
end

function doMedian(link)
	local itemID, randomProp, enchant, uniqID, itemName = breakLink(link);
	local itemKey = itemID..":"..randomProp..":"..enchant;

    local median, count = getUsableMedian(itemKey);
    if (not median) then
        Auctioneer_ChatPrint(string.format(AUCT_FRMT_MEDIAN_NOAUCT, colorTextWhite(itemName)));
    else
        Auctioneer_ChatPrint(string.format(AUCT_FRMT_MEDIAN_LINE, count, colorTextWhite(itemName), Auctioneer_GetTextGSC(median)));
    end    
end

local function getBidBasedSellablePrice(itemKey)
    local itemData = getAuctionPriceData(itemKey);
    local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = getAuctionPrices(itemData);      
    local bidBasedSellPrice = 0;
    local typicalBuyout = 0;
    local aveBuyout = 0;
    local aveBid = 0;
    if buyCount > 0 then
        aveBuyout = (buyPrice / buyCount);
    end
    if bidCount > 0 then
        aveBid = (bidPrice / bidCount);
    end
    
    local medianBuyout = getUsableMedian(itemKey)
    if medianBuyout then
        typicalBuyout = math.min(aveBuyout, medianBuyout)        
    else
        typicalBuyout = aveBuyout
    end
    
    bidBasedSellPrice = (typicalBuyout + aveBid) / 2;
    
    return bidBasedSellPrice;
end

function getHighestSellablePriceForOne(itemKey, useCachedPrices, category)
    if not category then category = "" end
    local bidBasedCategories = {Weapon=1, Armor=1, Recipe=1, Miscellaneous=1};
    local highestSellablePrice = 0;
    local marketPrice = 0;
    local lowestAllowedPercentBelowMarket = 30;
    local discountLowPercent = 5;
    local discountMarketPercent = 15;
    local buyoutMedian, count = getUsableMedian(itemKey);
    
    
    local currentLowestBuyout = nil;
    local lowestAuctionSignature = nil;
    local lowestAuctionCount, lowestAuctionBuyout;         
    if useCachedPrices then    
        currentLowestBuyout = getLowestPriceQuick(itemKey);
    else
        lowestAuctionSignature = findLowestAuctionForItem(itemKey);
        if lowestAuctionSignature then
            _,_,_, _, lowestAuctionCount, _, lowestAuctionBuyout, _ = getItemSignature(lowestAuctionSignature);
            currentLowestBuyout = lowestAuctionBuyout / lowestAuctionCount;
--~ p("currentLowestBuyout: "..currentLowestBuyout);           
        end
    end

    if bidBasedCategories[category] and not getItemPlayerMade(itemKey) then
--~ p("bid based");    
        marketPrice = getBidBasedSellablePrice(itemKey)
    else
--~ p("buyout based");    
        marketPrice = buyoutMedian;
    end
--~ p("marketPrice: ", marketPrice);  

    if marketPrice and marketPrice > 0 then
        if currentLowestBuyout then
            lowestBuyoutPriceAllowed = subtractPercent(marketPrice, lowestAllowedPercentBelowMarket);
			local auctKey = sanifyAHSnapshot();
            if lowestAuctionSignature and AHSnapshot[auctKey][lowestAuctionSignature].owner == UnitName("player") then
                highestSellablePrice = currentLowestBuyout; -- If I am the lowest seller use same low price
            elseif (currentLowestBuyout < lowestBuyoutPriceAllowed) or (currentLowestBuyout > marketPrice) then
                -- set highest price to "Discount market"
--~ p("Discount market case 1");                 
                highestSellablePrice = subtractPercent(marketPrice, discountMarketPercent);
            else -- use discount low
                -- set highest price to "Discount low"
--~ p("Discount low case 1");                
                highestSellablePrice = subtractPercent(currentLowestBuyout, discountLowPercent);
            end
        else -- no low buyout, use discount market
            -- set highest price to "Discount market"
--~ p("Discount market case 2");            
            highestSellablePrice = subtractPercent(marketPrice, discountMarketPercent);            
        end
    else -- no market
        if currentLowestBuyout then
            -- set highest price to "Discount low"
--~ p("Discount low case 2");            
            highestSellablePrice = subtractPercent(currentLowestBuyout, discountLowPercent);
--~         elseif Auctioneer_BasePrices[id].s then -- see if we have vendor sell info for this item
--~ p("vendor price");           
--~             -- use vendor prices if no auction data available
--~             local itemInfo = Auctioneer_BasePrices[id];
--~             local vendorSell = nullSafe(itemInfo.s); -- use vendor prices
        end
    end
    
    return highestSellablePrice, count;
end

-- execute the '/auctioneer low <itemName>' that returns the auction for an item with the lowest buyout
local function doLow(link)
	local itemID, randomProp, enchant, uniqID, itemName = breakLink(link);
	local itemKey = itemID..":"..randomProp..":"..enchant;
    
    local auctionSignature = findLowestAuctionForItem(itemKey);
    if (not auctionSignature) then
        Auctioneer_ChatPrint(string.format(AUCT_FRMT_NOAUCT, colorTextWhite(itemName)));
    else
        local _,_,_, _, count, _, buyout, _ = getItemSignature(auctionSignature);
		local auctKey = sanifyAHSnapshot();
        local auction = AHSnapshot[auctKey][auctionSignature];
        local itemKey = itemID..":"..randomProp..":"..enchant;
		Auctioneer_ChatPrint(string.format(AUCT_FRMT_LOW_LINE, colorTextWhite(count.."x")..auction.itemLink, Auctioneer_GetTextGSC(buyout), colorTextWhite(auction.owner), Auctioneer_GetTextGSC(buyout / count), colorTextWhite(percentLessThan(getUsableMedian(itemKey), buyout / count).."%")));
    end
end

local function doHSP(link)
	local itemID, randomProp, enchant, uniqID, itemName = breakLink(link);
	local itemKey = itemID..":"..randomProp..":"..enchant;
    local category = getItemCategory(itemKey);
p(category);    
    local highestSellablePrice = getHighestSellablePriceForOne(itemKey, false, category);
    Auctioneer_ChatPrint(string.format(AUCT_FRMT_HSP_LINE, colorTextWhite(itemName), Auctioneer_GetTextGSC(nilSafeString(highestSellablePrice))));
end

local function doTest(param)
    p(getBidBasedSellablePrice(param));
end

-- Called by scanning hook when an auction item is scanned from the Auction house
-- we save the aution item to our tables, increment our counts etc
local function Auctioneer_AuctionEntry_Hook(page, index, category)
    local auctionDoneKey;
	if (not page or not index or not category) then
		return;
    else
        auctionDoneKey = ""..category..page..index;
	end
	if (not Auction_DoneItems[auctionDoneKey]) then
		Auction_DoneItems[auctionDoneKey] = true;
    else
        return;
	end
    
    lTotalAuctionsScannedCount = lTotalAuctionsScannedCount + 1;

	local aiName, aiTexture, aiCount, aiQuality, aiCanUse, aiLevel, aiMinBid, aiMinIncrement, aiBuyoutPrice, aiBidAmount, aiHighBidder, aiOwner = GetAuctionItemInfo("list", index);
    local aiTimeLeft = GetAuctionItemTimeLeft("list", index);
   
    -- do some validation of the auction data that was returned
    if (aiCount < 1) then aiCount = 1; end    
    if (aiName == nil or tonumber(aiBuyoutPrice) > MAX_ALLOWED_FORMAT_INT or tonumber(aiMinBid) > MAX_ALLOWED_FORMAT_INT) then return; end
        
	local aiLink = GetAuctionItemLink("list", index);
	local aiItemID, aiRandomProp, aiEnchant, aiUniqID = breakLink(aiLink);
	local aiKey = aiItemID..":"..aiRandomProp..":"..aiEnchant;

    -- construct the unique auction signature for this aution
    local lAuctionSignature = string.format("%d:%d:%d:%s:%d:%d:%d:%d", aiItemID, aiRandomProp, aiEnchant, nilSafeString(aiName), nullSafe(aiCount), nullSafe(aiMinBid), nullSafe(aiBuyoutPrice), aiUniqID);
    
    -- add this item's buyout price to the buyout price history for this item in the snapshot
    if aiBuyoutPrice > 0 then
        local buyoutPriceForOne = (aiBuyoutPrice / aiCount);
        if (not lSnapshotItemPrices[aiKey]) then
            lSnapshotItemPrices[aiKey] = {buyoutPrices={buyoutPriceForOne}, name=aiName};
        else
            table.insert(lSnapshotItemPrices[aiKey].buyoutPrices, buyoutPriceForOne);
        end
    end
    
    
    --if this auction is not in the snapshot add it to the AuctionPrices and AHSnapshot    
	local auctKey = sanifyAHSnapshot();
    if (not AHSnapshot[auctKey][lAuctionSignature]) then 
    
        --Auctioneer_ChatPrint("New sig: "..lAuctionSignature);
    
        lNewAuctionsCount = lNewAuctionsCount + 1;
        
        -- get the item data from AuctionPrices table
        local itemData;
        local buyoutPricesHistory;
        -- see if they are still using the itemID as the key
        if AuctionPrices[auctionKey()][aiItemID] then
            itemData = AuctionPrices[auctionKey()][aiItemID];
            AuctionPrices[auctionKey()][aiItemID] = nil; --clear entry using old ID key
		-- else, see if they are still using the item name as the key
        elseif AuctionPrices[auctionKey()][aiName] then
            itemData = AuctionPrices[auctionKey()][aiName].data;
            buyoutPricesHistory = AuctionPrices[auctionKey()][aiName].buyoutPricesHistoryList;
            AuctionPrices[auctionKey()][aiKey] = {data=itemData, buyoutPricesHistoryList=buyoutPricesHistory};            
            AuctionPrices[auctionKey()][aiName] = nil; --clear entry using old Item Name key       
        else
            itemData = getAuctionPriceData(aiKey);
        end
        
        local seenCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = getAuctionPrices(itemData);
     
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
            seenCount = nullSafe(seenCount) + 1;
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
    
        itemData = string.format("%d:%d:%d:%d:%d:%d:%d", seenCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice);
        
        -- now build the list of buyout prices seen for this auction to use to get the median        
        local newBuyoutPricesList = newBalancedList(lMaxBuyoutHistorySize);
        if (AuctionPrices[auctionKey()][aiKey] and table.getn(AuctionPrices[auctionKey()][aiKey].buyoutPricesHistoryList) > 0) then
            newBuyoutPricesList.setList(AuctionPrices[auctionKey()][aiKey].buyoutPricesHistoryList);
        end
        if (nullSafe(aiBuyoutPrice) > 0) then
            newBuyoutPricesList.insert(math.floor(aiBuyoutPrice / aiCount));
        end        
        AuctionPrices[auctionKey()][aiKey] = {name=aiName, category=category, playerMade=isPossiblePlayerMadeItem(aiLink), data=itemData, buyoutPricesHistoryList=newBuyoutPricesList.getList()};
        
        -- finaly add the auction to the snapshot
        if (aiOwner == nil) then aiOwner = "unknown"; end
        local initialTimeSeen = time();
        AHSnapshot[auctKey][lAuctionSignature] = {initialSeenTime=initialTimeSeen, lastSeenTime=initialTimeSeen, itemLink=aiLink, quality=nullSafe(aiQuality), level=nullSafe(aiLevel), bidamount=nullSafe(aiBidAmount), highBidder=aiHighBidder, owner=aiOwner, timeLeft=nullSafe(aiTimeLeft), category=category, dirty=0};
    else
        lOldAuctionsCount = lOldAuctionsCount + 1;
        --this is an auction that was already in the snapshot from a previous scan and is still in the auction house
        AHSnapshot[auctKey][lAuctionSignature].dirty = 0;                         --set its dirty flag to false so we know to keep it in the snapshot
        AHSnapshot[auctKey][lAuctionSignature].lastSeenTime = time();             --set the time we saw it last
        AHSnapshot[auctKey][lAuctionSignature].timeLeft = nullSafe(aiTimeLeft);   --update the time left
        AHSnapshot[auctKey][lAuctionSignature].bidamount = nullSafe(aiBidAmount); --update the current bid amount
        AHSnapshot[auctKey][lAuctionSignature].highBidder = aiHighBidder;         --update the high bidder
    end
end

function Auctioneer_SetModelByID(itemID)
	if (Auctioneer_BasePrices[itemID]) then
		local dinfo = Auctioneer_BasePrices[itemID].d;
		if (dinfo) then
			local meshID = Auctioneer_DisplayInfo[dinfo];
			if (meshID) then
				local mesh = Auctioneer_MeshData[meshID];
				if (mesh) then
					local i,j, class, model = string.find(mesh, "([^/]+)/(.*)");
					if (class) then
						TT_SetModel(class, model);
					else Auctioneer_ChatPrint("No class for mesh "..mesh);
					end
				else Auctioneer_ChatPrint("No mesh for mesh id "..meshID);
				end
			end
		end
	end
end


function Auctioneer_NewTooltip(frame, name, link, quality, count)
	Auctioneer_OldTooltip(frame, name, link, quality, count);

	if (not link) then p("No link was passed to the client");  return; end
	local itemID, randomProp, enchant, uniqID, lame = breakLink(link);
	local itemKey = itemID..":"..randomProp..":"..enchant;
	if (Auctioneer_GetFilter("all")) then
		TT_AddLine(name);
		TT_LineQuality(quality);

		if (Auctioneer_GetFilter(AUCT_SHOW_LINK)) then
			TT_AddLine("Link: " .. itemKey .. ":" .. uniqID);
			TT_LineQuality(quality);
		end

		local money = nil;
		local itemInfo = nil;

		if (itemID > 0) then
			if (Auctioneer_GetFilter(AUCT_SHOW_MESH)) then
				Auctioneer_SetModelByID(itemID);
			end

			frame.eDone = 1;
			local itemData = getAuctionPriceData(itemKey, nil, name, itemID);
			local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = getAuctionPrices(itemData);
			itemInfo = Auctioneer_BasePrices[itemID];

			if (aCount == 0) then
				TT_AddLine("Never seen at auction");
				TT_LineColor(0.5, 0.8, 0.5);
			else
				local avgQty = math.floor(minCount / aCount);
				local avgMin = math.floor(minPrice / minCount);

				local bidPct = math.floor(bidCount / minCount * 100);
				local avgBid = 0;
				if (bidCount > 0) then
					avgBid = math.floor(bidPrice / bidCount);
				end
				
				local buyPct = math.floor(buyCount / minCount * 100);
				local avgBuy = 0;
				if (buyCount > 0) then
					avgBuy = math.floor(buyPrice / buyCount);
				end
                                
                local median, medCount = getUsableMedian(itemKey, name);

				if (Auctioneer_GetFilter(AUCT_SHOW_AVERAGE)) then
					TT_AddLine(string.format(AUCT_FRMT_INFO_SEEN, aCount));
					TT_LineColor(0.5,0.8,0.1);
					if (avgQty > 1) then
						TT_AddLine(string.format(AUCT_FRMT_INFO_FORONE, Auctioneer_GetTextGSC(avgMin), Auctioneer_GetTextGSC(avgBuy), Auctioneer_GetTextGSC(avgBid), avgQty));
						TT_LineColor(0.1,0.8,0.5);
					else
						TT_AddLine(string.format(AUCT_FRMT_INFO_AVERAGE, Auctioneer_GetTextGSC(avgMin), Auctioneer_GetTextGSC(avgBuy), Auctioneer_GetTextGSC(avgBid)));
						TT_LineColor(0.1,0.8,0.5);
					end
                    if median and Auctioneer_GetFilter(AUCT_SHOW_MEDIAN) then
                        local historicalMedian, historicalMedCount = getItemHistoricalMedianBuyout(itemKey, name);
                        local snapshotMedian, snapshotMedCount = getItemSnapshotMedianBuyout(itemKey);
                        if historicalMedian and historicalMedCount > nullSafe(snapshotMedCount)  then
                            TT_AddLine(string.format(AUCT_FRMT_INFO_HISTMED, historicalMedCount), historicalMedian)
							TT_LineColor(0.1,0.8,0.5);
                        end
                        if snapshotMedian then
                            TT_AddLine(string.format(AUCT_FRMT_INFO_SNAPMED, snapshotMedCount), snapshotMedian)
							TT_LineColor(0.1,0.8,0.5);
                        end
                    end
				end
				if (Auctioneer_GetFilter(AUCT_SHOW_SUGGEST)) then
					if (count > 1) then
                        local buyoutPriceForOne = median;
                        if not buyoutPriceForOne then buyoutPriceForOne = avgBuy end
                        if (avgMin > buyoutPriceForOne) then aveMin = buyoutPriceForOne / 2 end
						TT_AddLine(string.format(AUCT_FRMT_INFO_YOURSTX, count, Auctioneer_GetTextGSC(avgMin*count), Auctioneer_GetTextGSC(buyoutPriceForOne*count), Auctioneer_GetTextGSC(avgBid*count)));
						TT_LineColor(0.5,0.5,0.8);
					end
				end
				if (Auctioneer_GetFilter(AUCT_SHOW_STATS)) then
					TT_AddLine(string.format(AUCT_FRMT_INFO_BIDRATE, bidPct, buyPct));
					TT_LineColor(0.1,0.5,0.8);
				end
			end
            
			local also = Auctioneer_GetFilterVal(AUCT_CMD_ALSO);
			if (also ~= "on") then
				if (also == "opposite") then
					also = oppositeKey();
				end
				local itemData = getAuctionPriceData(itemKey, also, name, itemID);
				local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = getAuctionPrices(itemData);
				local avgQty = math.floor(minCount / aCount);
				local avgMin = math.floor(minPrice / minCount);

				local bidPct = math.floor(bidCount / minCount * 100);
				local avgBid = 0;
				if (bidCount > 0) then
					avgBid = math.floor(bidPrice / bidCount);
				end
				
				local buyPct = math.floor(buyCount / minCount * 100);
				local avgBuy = 0;
				if (buyCount > 0) then
					avgBuy = math.floor(buyPrice / buyCount);
				end

				if (aCount == 0) then
					TT_AddLine(string.format(">> "..AUCT_FRMT_INFO_NEVER, also));
					TT_LineColor(0.5,0.8,0.1);
				else
					if (Auctioneer_GetFilter(AUCT_SHOW_AVERAGE)) then
						TT_AddLine(string.format(">> "..AUCT_FRMT_INFO_ALSOSEEN, aCount, also));
						TT_LineColor(0.5,0.8,0.1);
						if (avgQty > 1) then
							TT_AddLine(string.format(">> "..AUCT_FRMT_INFO_FORONE, Auctioneer_GetTextGSC(avgMin), Auctioneer_GetTextGSC(avgBuy), Auctioneer_GetTextGSC(avgBid), avgQty));
							TT_LineColor(0.1,0.8,0.5);
						else
							TT_AddLine(string.format(">> "..AUCT_FRMT_INFO_AVERAGE, Auctioneer_GetTextGSC(avgMin), Auctioneer_GetTextGSC(avgBuy), Auctioneer_GetTextGSC(avgBid)));
							TT_LineColor(0.1,0.8,0.5);
						end
						if (Auctioneer_GetFilter(AUCT_SHOW_SUGGEST)) then
							if (count > 1) then
								TT_AddLine(string.format(">> "..AUCT_FRMT_INFO_YOURSTX, count, Auctioneer_GetTextGSC(avgMin*count), Auctioneer_GetTextGSC(avgBuy*count), Auctioneer_GetTextGSC(avgBid*count)));
								TT_LineColor(0.5,0.5,0.8);
							end
						end
					end
					if (Auctioneer_GetFilter(AUCT_SHOW_STATS)) then
						TT_AddLine(string.format(">> "..AUCT_FRMT_INFO_BIDRATE, bidPct, buyPct));
						TT_LineColor(0.1,0.5,0.8);
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

		if (Auctioneer_GetFilter(AUCT_SHOW_VENDOR)) then
			if ((buy > 0) or (sell > 0)) then
				local bgsc = Auctioneer_GetTextGSC(buy);
				local sgsc = Auctioneer_GetTextGSC(sell);
                
				if (count and (count > 1)) then
					local bqgsc = Auctioneer_GetTextGSC(buy*count);
					local sqgsc = Auctioneer_GetTextGSC(sell*count);
					if (Auctioneer_GetFilter(AUCT_SHOW_VENDOR_BUY)) then
						TT_AddLine(string.format(AUCT_FRMT_INFO_BUYMULT, buyNote, count, bgsc), buy*count);
						TT_LineColor(0.8, 0.5, 0.1);
					end
					if (Auctioneer_GetFilter(AUCT_SHOW_VENDOR_SELL)) then
						TT_AddLine(string.format(AUCT_FRMT_INFO_SELLMULT, sellNote, count, sgsc), sell*count);
						TT_LineColor(0.8, 0.5, 0.1);
					end
				else
					if (Auctioneer_GetFilter(AUCT_SHOW_VENDOR_BUY)) then
						TT_AddLine(string.format(AUCT_FRMT_INFO_BUY, buyNote), buy);
						TT_LineColor(0.8, 0.5, 0.1);
					end
					if (Auctioneer_GetFilter(AUCT_SHOW_VENDOR_SELL)) then
						TT_AddLine(string.format(AUCT_FRMT_INFO_SELL, sellNote), sell);
						TT_LineColor(0.8, 0.5, 0.1);
					end
				end
			end
		end

		if (Auctioneer_GetFilter(AUCT_SHOW_STACK)) then
			if (stacks > 1) then
				TT_AddLine(string.format(AUCT_FRMT_INFO_STX, stacks));
			end
		end
		if (Auctioneer_GetFilter(AUCT_SHOW_USAGE)) then
			local reagentInfo = "";
			if (class ~= "") then
				if (uses ~= "") then
					reagentInfo = string.format(AUCT_FRMT_INFO_CLASSUSE, class, uses);
				else
					reagentInfo = string.format(AUCT_FRMT_INFO_CLASS, class);
				end
			elseif (uses ~= "") then
				reagentInfo = string.format(AUCT_FRMT_INFO_USE, uses);
			end
			if (reagentInfo ~= "") then
				TT_AddLine(reagentInfo);
				TT_LineColor(0.6, 0.4, 0.8);
			end
		end
	end
	TT_Show(frame);
end


local function Auctioneer_Tooltip_Hook(frame, name, count, data)
	Auctioneer_Old_Tooltip_Hook(frame, name, count, data);
end
function Auctioneer_AddTooltipInfo(frame, name, count, data)
end

-- hook to capture data about an auction that was boughtout
function Auctioneer_PlaceAuctionBid(itemtype, itemindex, bidamount)    
    -- get the info for this auction
    local aiLink = GetAuctionItemLink(AuctionFrame.type, GetSelectedAuctionItem(AuctionFrame.type));
	local aiItemID, aiRandomProp, aiEnchant, aiUniqID = breakLink(aiLink);
	local aiKey = aiItemID..":"..aiRandomProp..":"..aiEnchant;
    local aiName, aiTexture, aiCount, aiQuality, aiCanUse, aiLevel, aiMinBid, aiMinIncrement,
          aiBuyout, aiBidAmount, aiHighBidder, aiOwner =
          GetAuctionItemInfo(AuctionFrame.type, GetSelectedAuctionItem(AuctionFrame.type));

    local auctionSignature = string.format("%d:%d:%d:%s:%d:%d:%d:%d", aiItemID, aiRandomProp, aiEnchant, nilSafeString(aiName), nullSafe(aiCount), nullSafe(aiMinBid), nullSafe(aiBuyout), aiUniqID);

	local playerName = UnitName("player");
	local eventTime = time();
	if (not AuctionBids[playerName]) then
		AuctionBids[playerName] = {};
	end
	AuctionBids[playerName][eventTime] = {
		signature = auctionSignature,
		bidAmount = bidamount,
		itemOwner = aiOwner,
		prevBidder = aiHighBidder,
		itemWon = false;
	}
		
    if bidamount == aiBuyout then -- only capture buyouts
        -- remove from snapshot
        Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_REMOVE, auctionSignature));
		local auctKey = sanifyAHSnapshot();
        AHSnapshot[auctKey][auctionSignature] = nil;
		AuctionBids[playerName][eventTime].itemWon=true;
    end    

    Auctioneer_Old_BidHandler(itemtype,itemindex,bidamount);
end

function Auctioneer_OnLoad()
    -- register events
    this:RegisterEvent("NEW_AUCTION_UPDATE"); -- event that is fired when item changed in new auction frame
    this:RegisterEvent("AUCTION_HOUSE_SHOW"); -- auction house window opened
    this:RegisterEvent("AUCTION_HOUSE_CLOSED"); -- auction house window closed
    this:RegisterEvent("AUCTION_ITEM_LIST_UPDATE"); -- event for scanning
    
	Auctioneer_Event_StartAuctionScan = Auctioneer_AuctionStart_Hook;
	Auctioneer_Event_ScanAuction = Auctioneer_AuctionEntry_Hook;
    Auctioneer_Event_FinishedAuctionScan = Auctioneer_FinishedAuctionScan_Hook;

	-- Hook in new tooltip code
	Auctioneer_OldTooltip = TT_AddTooltip;
	TT_AddTooltip = Auctioneer_NewTooltip;

    -- Hook PlaceAuctionBid
	Auctioneer_Old_BidHandler = PlaceAuctionBid;
	PlaceAuctionBid = Auctioneer_PlaceAuctionBid;
    
	SLASH_AUCTIONEER1 = "/auctioneer";
	SLASH_AUCTIONEER2 = "/auction";
	SLASH_AUCTIONEER2 = "/auc";
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
		local onOffToggle = " ("..AUCT_CMD_ON.."|"..AUCT_CMD_OFF.."|"..AUCT_CMD_TOGGLE..")";
		local lineFormat = "  |cffffffff/auctioneer %s "..onOffToggle.."|r |cff2040ff[%s]|r - %s";

		Auctioneer_ChatPrint("  |cffffffff/auctioneer "..onOffToggle.."|r |cff2040ff["..Auctioneer_GetFilterVal("all").."]|r - " .. AUCT_HELP_ONOFF);
		
		Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_AVERAGE, Auctioneer_GetFilterVal(AUCT_SHOW_AVERAGE), AUCT_HELP_AVERAGE));
		Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_MEDIAN, Auctioneer_GetFilterVal(AUCT_SHOW_MEDIAN), AUCT_HELP_MEDIAN));
		Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_SUGGEST, Auctioneer_GetFilterVal(AUCT_SHOW_SUGGEST), AUCT_HELP_SUGGEST));
		Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_STATS, Auctioneer_GetFilterVal(AUCT_SHOW_STATS), AUCT_HELP_STATS));
		Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_VENDOR, Auctioneer_GetFilterVal(AUCT_SHOW_VENDOR), AUCT_HELP_VENDOR));
		Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_VENDOR_SELL, Auctioneer_GetFilterVal(AUCT_SHOW_VENDOR_SELL), AUCT_HELP_VENDOR_SELL));
		Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_VENDOR_BUY, Auctioneer_GetFilterVal(AUCT_SHOW_VENDOR_BUY), AUCT_HELP_VENDOR_BUY));
		Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_USAGE, Auctioneer_GetFilterVal(AUCT_SHOW_USAGE), AUCT_HELP_USAGE));
		Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_STACK, Auctioneer_GetFilterVal(AUCT_SHOW_STACK), AUCT_HELP_STACK));

		lineFormat = "  |cffffffff/auctioneer %s %s|r - %s";
		Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_CLEAR, AUCT_OPT_CLEAR, AUCT_HELP_CLEAR));
		Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_ALSO, AUCT_OPT_ALSO, AUCT_HELP_ALSO));
		Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_BROKER, AUCT_OPT_BROKER, AUCT_HELP_BROKER));
		Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_BIDBROKER, AUCT_OPT_BIDBROKER, AUCT_HELP_BIDBROKER));
		Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_PERCENTLESS, AUCT_OPT_PERCENTLESS, AUCT_HELP_PERCENTLESS));
		Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_COMPETE, AUCT_OPT_COMPETE, AUCT_HELP_COMPETE));
		Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_SCAN, AUCT_OPT_SCAN, AUCT_HELP_SCAN));

	elseif (cmd == AUCT_CMD_ON) then
		Auctioneer_SetFilter("all", "on");
		Auctioneer_ChatPrint(AUCT_STAT_ON);
	elseif (cmd == AUCT_CMD_OFF) then
		Auctioneer_SetFilter("all", "off");
		Auctioneer_ChatPrint(AUCT_STAT_OFF);
	elseif (cmd == AUCT_CMD_TOGGLE) then
		local cur = Auctioneer_GetFilterVal("all");
		if (cur == "off") then
			Auctioneer_SetFilter("all", "on");
			Auctioneer_ChatPrint(AUCT_STAT_ON);
		else
			Auctioneer_SetFilter("all", "off");
			Auctioneer_ChatPrint(AUCT_STAT_OFF);
		end
	elseif (cmd == AUCT_CMD_CLEAR) then
		if (param == AUCT_CMD_CLEAR_ALL) then
			local aKey = auctionKey();
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_CLEARALL, aKey));
			AuctionPrices[aKey] = {};
            AHSnapshot = {};
            AHSnapshot[auctionKey()] = {};
            AHSnapshotItemPrices = {};
            AHSnapshotItemPrices[auctionKey()] = {};
        elseif (param == AUCT_CMD_CLEAR_SNAPSHOT) then
            Auctioneer_ChatPrint(AUCT_FRMT_ACT_CLEARSNAP);
            AHSnapshot = {};
            AHSnapshot[auctionKey()] = {};
            AHSnapshotItemPrices = {};  
            AHSnapshotItemPrices[auctionKey()] = {};  
            lSnapshotItemPrices = {};            
		else
			local items = Auctioneer_GetItems(param);
			for _,itemKey in items do
				local aKey = auctionKey();
				if (AuctionPrices[aKey][itemKey] ~= nil) then
					AuctionPrices[aKey][itemKey] = nil;
					Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_CLEAR_OK, itemKey));
				else
					Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_CLEAR_FAIL, itemKey));
				end
			end
		end
	elseif (cmd == AUCT_CMD_ALSO) then
		Auctioneer_SetFilter("also", param);        
	elseif (cmd == AUCT_CMD_BROKER) then
        doBroker(param);
    elseif (cmd == AUCT_CMD_BIDBROKER) or (cmd == AUCT_CMD_BIDBROKER_SHORT) then
        doBidBroker(param);
	elseif (cmd == AUCT_CMD_PERCENTLESS) or (cmd == AUCT_CMD_PERCENTLESS_SHORT) then
        doPercentLess(param);      
	elseif (cmd == AUCT_CMD_COMPETE) then
        doCompeting(param);      
    elseif (cmd == AUCT_CMD_SCAN) then
        Auctioneer_RequestAuctionScan();           
    elseif (cmd == "test") then
        doTest(param);
    elseif (cmd == "low") then
        doLow(param);   
    elseif (cmd == "med") then
        doMedian(param);  
    elseif (cmd == "hsp") then
        doHSP(param);           
	elseif (
		(cmd == AUCT_SHOW_AVERAGE) or 
		(cmd == AUCT_SHOW_MEDIAN) or
		(cmd == AUCT_SHOW_SUGGEST) or 
		(cmd == AUCT_SHOW_STATS) or 
		(cmd == AUCT_SHOW_VENDOR) or 
		(cmd == AUCT_SHOW_USAGE) or 
		(cmd == AUCT_SHOW_STACK) or 
		(cmd == AUCT_SHOW_VENDOR_SELL) or 
		(cmd == AUCT_SHOW_VENDOR_BUY) or 
		(cmd == AUCT_SHOW_MESH) or 
		(cmd == AUCT_SHOW_LINK) or 
		(cmd == AUCT_SHOW_HSP)
	) then
		if (param == AUCT_CMD_OFF) then
			Auctioneer_SetFilter(cmd, "off");
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_DISABLE, cmd));
		elseif (param == AUCT_CMD_TOGGLE) then
			local cur = Auctioneer_GetFilterVal(cmd);
			if (cur == "on") then
				cur = "off";
				Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_DISABLE, cmd));
			else
				cur = "on";
				Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_ENABLE, cmd));
			end
			Auctioneer_SetFilter(cmd, cur);
		else
			Auctioneer_SetFilter(cmd, "on");
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_ENABLE, cmd));
		end
	else
		Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_UNKNOWN, cmd));
	end
end

function Auctioneer_SetFilter(type, value)
	if (not AuctionConfig.filters) then AuctionConfig.filters = {}; end
	AuctionConfig.filters[type] = value;
end

function Auctioneer_GetFilterVal(type)
	if (not AuctionConfig.filters) then AuctionConfig.filters = {}; end
	value = AuctionConfig.filters[type];
	if (not value) then
		if (type == "showlink") then return "off"; end
		return "on";
	end
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

function Auctioneer_GetItemLinks(str)
	local itemList = {};
	local listSize = 0;
	for link, item in string.gfind(str, "|Hitem:([^|]+)|h[[]([^]]+)[]]|h") do
		listSize = listSize+1;
		itemList[listSize] = item.." = "..link;
	end
	return itemList;
end


function Auctioneer_GetItems(str)
	local itemList = {};
	local listSize = 0;
	for itemLink in string.gfind(str, "|Hitem:([^|]+)|h[[][^]]+[]]|h") do
		local itemID, randomProp, enchant, uniqID, lame = breakLink(link);
		local itemKey = itemID..":"..randomProp..":"..enchant;
		listSize = listSize+1;
		itemList[listSize] = itemKey;
	end
	return itemList;
end

-- this function takes copper and rounds to 5 silver below the the nearest gold if it is 15 silver above of an even gold
-- example: this function changes 1g15s to 95s
-- example: 1.5g will be unchanged and remain 1.5g
local function roundDownTo95(copper)
    local g,s,c = Auctioneer_GetGSC(copper);
    local roundedValue = copper;
    
    if g > 0 and s < 10 then
        roundedValue = roundedValue - ((s + 5) * 100); -- subtract enough copper to round to 95 silver
    end
    
    return roundedValue;
end

function Auctioneer_FindItemInBags(findName)
	for bag = 0, 4, 1 do
		size = GetContainerNumSlots(bag);
		if (size) then
			for slot = size, 1, -1 do
				local link = GetContainerItemLink(bag, slot);
				if (link) then
					local itemID, randomProp, enchant, uniqID, itemName = breakLink(link);
					if (itemName == findName) then
						return bag, slot, itemID, randomProp, enchant, uniqID;
					end
				end
			end
		end
	end
end

function Auctioneer_OnEvent(event)
	if (event=="NEW_AUCTION_UPDATE") then
        local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo();
        if name then  
            local startPrice, buyoutPrice;
			local bag, slot, id, rprop, enchant, uniq = Auctioneer_FindItemInBags(name);
			if (bag ~= nil) then
				local itemKey = id..":"..rprop..":"..enchant;
				local itemData = getAuctionPriceData(itemKey, nil, name, id);
				local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = getAuctionPrices(itemData);            
				
				-- get highest sellable price for buyout
				local hsp = getHighestSellablePriceForOne(itemKey, false);
				if hsp == 0 and buyCount > 0 then
					hsp =  math.floor(buyPrice / buyCount); -- use mean buyout if median not available
				end
				
				-- calculate average min for start price
				local minbid = 0
				if minCount > 0 then 
					minbid = math.floor(minPrice / minCount);
				end
				
				startPrice = roundDownTo95(minbid * count);
				buyoutPrice = roundDownTo95(nullSafe(hsp) * count);
				
				if startPrice > buyoutPrice then
					startPrice = roundDownTo95(subtractPercent(buyoutPrice, 15)); -- 15% less than buyout
				end
				
				if buyoutPrice > 0 and startPrice > 0 then
					MoneyInputFrame_SetCopper(StartPrice, startPrice);
					MoneyInputFrame_SetCopper(BuyoutPrice, buyoutPrice);
				elseif Auctioneer_BasePrices[id].s then -- see if we have vendor sell info for this item
					-- use vendor prices if no auction data available
					local itemInfo = Auctioneer_BasePrices[id];
					local vendorSell = nullSafe(itemInfo.s);
					startPrice = roundDownTo95((vendorSell * count) * 1.5);
					buyoutPrice = roundDownTo95((vendorSell * count) * 3);
					if startPrice > buyoutPrice then
						startPrice = roundDownTo95(subtractPercent(buyoutPrice, 15)); -- 15% less than buyout
					end                
					MoneyInputFrame_SetCopper(StartPrice, startPrice);
					MoneyInputFrame_SetCopper(BuyoutPrice, buyoutPrice);
				end
			end
        end
    elseif (event=="AUCTION_HOUSE_SHOW") then
        if Auctioneer_isScanningRequested then
            Auctioneer_StartAuctionScan();
        else
            AuctionsShortAuctionButton:SetChecked(nil);
            AuctionsMediumAuctionButton:SetChecked(nil);
            AuctionsLongAuctionButton:SetChecked(nil);
        
            -- default to 24 hour auctions
            AuctionsLongAuctionButton:SetChecked(1);
            AuctionFrameAuctions.duration = 1440;
        end
	elseif(event == "AUCTION_HOUSE_CLOSED") then
        if Auctioneer_isScanningRequested then
		    Auctioneer_StopAuctionScan();        
        end
	elseif(event == "AUCTION_ITEM_LIST_UPDATE" and Auctioneer_isScanningRequested) then
		Auctioneer_ScanAuction();   
    end        
end



function dump(...)
	local out = "";
	for i = 1, arg.n, 1 do
		local d = arg[i];
		local t = type(d);
		if (t == "table") then
			out = out .. "{";
			local first = true;
			for k, v in d do
				if (not first) then out = out .. ", "; end
				first = false;
				out = out .. dump(k);
				out = out .. " = ";
				out = out .. dump(v);
			end
			out = out .. "}";
		elseif (t == "nil") then
			out = out .. "NIL";
		elseif (t == "number") then
			out = out .. d;
		elseif (t == "string") then
			out = out .. "\"" .. d .. "\"";
		elseif (t == "boolean") then
			if (d) then
				out = out .. "true";
			else
				out = out .. "false";
			end
		else
			out = out .. string.upper(t) .. "??";
		end

		if (i < arg.n) then out = out .. ", "; end
	end
	return out;
end

function p(...)
	local out = "";
	for i = 1, arg.n, 1 do
		if (i > 1) then out = out .. ", "; end
		if (type(arg[i]) == "string") then
			out = out .. arg[i];
		else
			out = out .. dump(arg[i]);
		end
	end
	ChatFrame1:AddMessage(out, 1.0, 1.0, 0.0);
end


