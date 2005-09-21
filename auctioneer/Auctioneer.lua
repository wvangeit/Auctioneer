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

-- Temp table that is copied into AHSnapshotItemPrices only when a scan fully completes
local lSnapshotItemPrices = {};

-- The maximum number of elements we store in our buyout prices history table 
local lMaxBuyoutHistorySize = 35;

-- Min median buyout price for an item to show up in the list of items below median
local MIN_PROFIT_MARGIN = 5000;

-- Min median buyout price for an item to show up in the list of items below median
local DEFAULT_COMPETE_LESS = 5;

-- Min times an item must be seen before it can show up in the list of items below median
local MIN_BUYOUT_SEEN_COUNT = 5;

-- Max buyout price for an auction to display as a good deal item
local MAX_BUYOUT_PRICE = 800000;

-- The default percent less, only find auctions that are at a minimum this percent less than the median
local MIN_PERCENT_LESS_THAN_HSP = 60; -- 60% default

-- The minimum profit/price percent that an auction needs to be displayed as a resellable auction
local MIN_PROFIT_PRICE_PERCENT = 30; -- 30% default

-- The minimum percent of bids placed on an item to be considered an "in-demand" enough item to be traded, this is only applied to Weapons and Armor and Recipies
local MIN_BID_PERCENT = 10;

-- categories that the brokers and HSP look at the bid data for
--  1 = weapon
--  2 = armor
--  3 = container
--  4 = dissipatable
--  5 = tradeskillitems
--  6 = projectile
--  7 = quiver
--  8 = recipe
--  9 = reagence
-- 10 = miscellaneous
local BID_BASED_CATEGORIES = {[1]=true, [2]=true, [8]=true, [10]=true}
local CLASS_TO_CATEGORY_MAP = {
	[2]  = 1,
	[4]  = 2,
	[1]  = 3,
	[0]  = 4,
	[7]  = 5,
	[6]  = 6,
	[11] = 7,
	[9]  = 8,
	[5]  = 9,
	[15] = 10,
};


-- GUI Init Variables (Added by MentalPower)
Auctioneer_GUI_Registered = nil;
Auctioneer_Khaos_Registered = nil;

--[[ SavedVariables --]]
AuctionConfig = {};        --Table that stores config settings
Auction_DoneItems = {};    --Table to keep a record of auction items that have been scanned
AuctionConfig.version = 30200;

-- Table to store our cached HSP values (since they're expensive to calculate)
Auctioneer_HSPCache = {};
Auctioneer_Lowests = {};


-- Auction time constants
local TIME_LEFT_SHORT = 1;
local TIME_LEFT_MEDIUM = 2;
local TIME_LEFT_LONG = 3;
local TIME_LEFT_VERY_LONG = 4;

local TIME_LEFT_SECONDS = {
	[1] = 0,      -- Could expire any second... the current bid is relatively accurate.
	[2] = 1800,   -- If it disappears within 30 mins of last seing it, it was BO'd
	[3] = 7200,   -- Ditto but for 2 hours.
	[4] = 28800,  -- 8 hours.
}

-- Item quality constants
local QUALITY_EPIC = 4;
local QUALITY_RARE = 3;
local QUALITY_UNCOMMON = 2;
local QUALITY_COMMON= 1;
local QUALITY_POOR= 0;

-- return the string representation of the given timeLeft constant
function Auctioneer_GetTimeLeftString(timeLeft)
	local timeLeftString = "";
	-- TODO: localize these strings
	if timeLeft == TIME_LEFT_SHORT then
		timeLeftString = AUCT_TIME_SHORT;
	elseif timeLeft == TIME_LEFT_MEDIUM then
		timeLeftString = AUCT_TIME_MED;
	elseif timeLeft == TIME_LEFT_LONG then
		timeLeftString = AUCT_TIME_LONG;
	elseif timeLeft == TIME_LEFT_VERY_LONG then
		timeLeftString = AUCT_TIME_VLONG;
	end
	return timeLeftString;
end

function Auctioneer_GetGSC(money)
	local g,s,c = TT_GetGSC(money);
	return g,s,c;
end
function Auctioneer_GetTextGSC(money)
	return TT_GetGSC(money);
end

-- return an empty string if str is nil
function nilSafeString(str)
	if (not str) then str = "" end
	return str;
end

function Auctioneer_ColorTextWhite(text)
	if (not text) then text = ""; end
	local COLORING_START = "|cff%s%s|r";
	local WHITE_COLOR = "e6e6e6";
	return string.format(COLORING_START, WHITE_COLOR, ""..text);
end

-- Used to convert variables that should be numbers but are nil to 0
function nullSafe(val)
	if (val == nil) then return 0; end
	if (0 + val > 0) then return 0 + val; end
	return 0;
end

-- Subtracts/Adds given percentage from/to a value
function Auctioneer_SubtractPercent(value, percentLess)
	return math.floor(value * ((100 - percentLess)/100));
end
function Auctioneer_AddPercent(value, percentMore)
	return math.floor(value * ((100 + percentMore)/100));
end

-- returns the integer representation of the percent less value2 is from value1
-- example: value1=10, value2=7,  percentLess=30
function Auctioneer_PercentLessThan(value1, value2)
	if nullSafe(value1) > 0 and nullSafe(value2) < nullSafe(value1) then
		return 100 - math.floor((100 * nullSafe(value2))/nullSafe(value1));
	else
		return 0;
	end
end

function Auctioneer_GetLowest(valuesTable)
	if (not valuesTable or table.getn(valuesTable) == 0) then
		return nil, nil;
	end
	local tableSize = table.getn(valuesTable);
	local lowest = tonumber(valuesTable[1]) or 0;
	local second = nil
	if (tableSize > 1) then
		for i=2, tableSize do
			second = tonumber(valuesTable[i]) or 0;
			if (second > lowest) then
				return lowest, second;
			end
		end
	end
	return lowest, nil;
end

-- Returns the median value of a given table one-dimentional table
function Auctioneer_GetMedian(valuesTable)
	if (not valuesTable or table.getn(valuesTable) == 0) then
		return nil; --make this function nil argument safe
	end

	local tableSize = table.getn(valuesTable);

	if (tableSize == 1) then
		return tonumber(valuesTable[1]), 1;
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

	return tonumber(median), tableSize or 0;
end

-- We don't use this function anymore but other code may.
function Auctioneer_SanifyAHSnapshot()
	return Auctioneer_GetAuctionKey();
end

-- This function sets the dirty flag to true for all the auctions in the snapshot
-- This is done to indicate that the snapshot is out of date.
function Auctioneer_InvalidateAHSnapshot()
	-- Invalidate the snapshot
	local auctKey = Auctioneer_GetAuctionKey();
	if (not AuctionConfig.snap) then
		AuctionConfig.snap = {};
	end
	if (not AuctionConfig.snap[auctKey]) then
		AuctionConfig.snap[auctKey] = {};
	end
	for cat,cData in pairs(AuctionConfig.snap[auctKey]) do
		-- Only invalidate the class group if we will be scanning it.
		if (Auctioneer_GetFilter("scan-class"..cat)) then
			for iKey, iData in pairs(cData) do
				-- The first char is the dirty flag (purposely)
				AuctionConfig.snap[auctKey][cat][iKey] = "1" .. string.sub(iData,2);
			end
		end
	end
end

-- Called when the auction scan starts
function Auctioneer_AuctionStart_Hook()
	Auction_DoneItems = {};
	lSnapshotItemPrices = {};
	Auctioneer_InvalidateAHSnapshot();

	-- Make sure AuctionConfig.data is initialized
	local serverFaction = Auctioneer_GetAuctionKey();
	if (AuctionConfig.data == nil) then AuctionConfig.data = {}; end
	if (AuctionConfig.data[serverFaction] == nil) then
		AuctionConfig.data[serverFaction] = {};
	end

	-- Reset scan audit counters
	lTotalAuctionsScannedCount = 0;
	lNewAuctionsCount = 0;
	lOldAuctionsCount = 0;
	lDefunctAuctionsCount = 0;
end

-- This is called when an auction scan finishes and is used for clean up
function Auctioneer_FinishedAuctionScan_Hook()
	-- Only remove defunct auctions from snapshot if there was a good amount of auctions scanned.
	local auctKey = Auctioneer_GetAuctionKey();

	local endTime = time();
	if lTotalAuctionsScannedCount >= 50 then 
		local snap,lastSeen,expiredSeconds,itemKey,buyList,listStr,listSplit,buyout,hist;
		if (AuctionConfig and AuctionConfig.snap and AuctionConfig.snap[auctKey]) then
			for cat,cData in pairs(AuctionConfig.snap[auctKey]) do
				for iKey, iData in pairs(cData) do
					snap = Auctioneer_GetSnapshotInfoFromData(iData);
					if (snap.dirty == 1) then
						-- This item should have been seen, but wasn't.
						-- We need to work out if it expired before or after it's time
						lastSeen = snap.lastSeenTime;
						expiredSeconds = endTime - lastSeen;
						if (expiredSeconds < TIME_LEFT_SECONDS[tonumber(snap.timeLeft)]) then
							-- Whoa! This item was bought out.
							itemKey = Auctioneer_GetKeyFromSig(iKey);
							if (not AuctionConfig.success) then AuctionConfig.success = {} end
							if (not AuctionConfig.success.buy) then AuctionConfig.success.buy = {} end
							if (not AuctionConfig.success.buy[auctKey]) then AuctionConfig.success.buy[auctKey] = {} end
							buyList = newBalancedList(lMaxBuyoutHistorySize);
							listStr = AuctionConfig.success.buy[auctKey][itemKey];
							if (listStr) then
								listSplit = Enchantrix_Split(listStr, ":");
								buyList.setList(listSplit);
							end
							x,x,x,x,x,x,buyout = Auctioneer_GetItemSignature(iKey); 
							buyList.insert(buyout);

							hist = "";
							if (buyList and buyList.list) then
								for pos, item in pairs(buyList.list) do
									if (hist == "") then hist = hist..item
									else hist = hist..":"..item;
									end
								end
							end
							AuctionConfig.success.buy[auctKey][itemKey] = hist;
						end
						if (snap.timeLeft == 1) and (snap.bidamount > 0) then
							-- This one expired at the final time interval, so it's likely
							-- that this is the best bid value we'll get for it.
							itemKey = Auctioneer_GetKeyFromSig(iKey);
							if (not AuctionConfig.success) then AuctionConfig.success = {} end
							if (not AuctionConfig.success.bid) then AuctionConfig.success.bid = {} end
							if (not AuctionConfig.success.bid[auctKey]) then AuctionConfig.success.bid[auctKey] = {} end
							bidList = newBalancedList(lMaxBuyoutHistorySize);
							listStr = AuctionConfig.success.bid[auctKey][itemKey];
							if (listStr) then
								listSplit = Enchantrix_Split(listStr, ":");
								bidList.setList(listSplit);
							end
							bidList.insert(snap.bidamount);

							hist = "";
							if (bidList and bidList.list) then
								for pos, item in pairs(bidList.list) do
									if (hist == "") then hist = hist..item
									else hist = hist..":"..item;
									end
								end
							end
							AuctionConfig.success.bid[auctKey][itemKey] = hist;
						end
					end
						
					if (string.sub(iData, 1,1) == "1") then
						
						AuctionConfig.snap[auctKey][cat][iKey] = nil; --clear defunct auctions
						lDefunctAuctionsCount = lDefunctAuctionsCount + 1;
					end
				end
			end
		end
	end

	if (not AuctionConfig.sbuy) then AuctionConfig.sbuy = {}; end
	if (not AuctionConfig.sbuy[auctKey]) then AuctionConfig.sbuy[auctKey] = {}; end

	-- Copy the item prices into the Saved item prices table
	local hist = "";
	if (lSnapshotItemPrices) then
		for sig, iData in pairs(lSnapshotItemPrices) do
			hist = "";
			if (iData.buyoutPrices) then
				for pos, hPrice in pairs(iData.buyoutPrices) do
					if (hist == "") then hist = string.format("%d", hPrice);
					else hist = string.format("%s:%d", hist, hPrice); end
				end
			end
			AuctionConfig.sbuy[auctKey][sig] = hist;
			lSnapshotItemPrices[sig] = nil;
		end
	end

	local lDiscrepencyCount = lTotalAuctionsScannedCount - (lNewAuctionsCount + lOldAuctionsCount);

	Auctioneer_ChatPrint(string.format(AUCTIONEER_AUCTION_TOTAL_AUCTS, Auctioneer_ColorTextWhite(lTotalAuctionsScannedCount)));
	Auctioneer_ChatPrint(string.format(AUCTIONEER_AUCTION_NEW_AUCTS, Auctioneer_ColorTextWhite(lNewAuctionsCount)));
	Auctioneer_ChatPrint(string.format(AUCTIONEER_AUCTION_OLD_AUCTS, Auctioneer_ColorTextWhite(lOldAuctionsCount)));
	Auctioneer_ChatPrint(string.format(AUCTIONEER_AUCTION_DEFUNCT_AUCTS, Auctioneer_ColorTextWhite(lDefunctAuctionsCount)));

	if (nullSafe(lDiscrepencyCount) > 0) then
		Auctioneer_ChatPrint(string.format(AUCTIONEER_AUCTION_DISCREPANCIES, Auctioneer_ColorTextWhite(lDiscrepencyCount)));
	end
end

-- Returns the current faction's auction signature
function Auctioneer_GetAuctionKey()
	local serverName = GetCVar("realmName");
	local factionGroup = UnitFactionGroup("player");
	return serverName.."-"..factionGroup;
end
-- Returns the current faction's opposing faction's auction signature
function Auctioneer_GetOppositeKey()
	local serverName = GetCVar("realmName");
	local factionGroup = UnitFactionGroup("player");
	if (factionGroup == "Alliance") then factionGroup="Horde"; else factionGroup="Alliance"; end
	return serverName.."-"..factionGroup;
end

Auctioneer_BreakLink = TT_BreakLink;

-- Given an item key, breaks it into it's itemID, randomProperty and enchantProperty
function Auctioneer_BreakItemKey(itemKey)
	local i,j, itemID, randomProp, enchant = string.find(itemKey, "(%d+):(%d+):(%d+)");
	return tonumber(itemID or 0), tonumber(randomProp or 0), tonumber(enchant or 0);
end


function Auctioneer_Split(str, at)
	local splut = {};

	if (type(str) ~= "string") then return nil end
	if (not str) then str = "" end
	if (not at) then table.insert(splut, str) end

	for n, c in string.gfind(str, '([^%'..at..']*)(%'..at..'?)') do
		table.insert(splut, n);
		if (c == '') then break end
	end
	return splut;
	
--	local pos = 1;
--	
--	if (type(str) ~= "string") then return nil end
--	if (not str) then str = "" end
--	if (not at) then table.insert(splut, str) end
--	
--	local match, mend = string.find(str, at, pos, true);
--	while match do
----		if (safe and string.sub(str, mend+1, mend+1) == " ") then
----			match, mend = string.find(str, at, mend+1, true);
----		end
--		table.insert(splut, string.sub(str, pos, match-1));
--		pos = mend+1;
--		match, mend = string.find(str, at, pos, true);
--	end
--	table.insert(splut, string.sub(str, pos));
end

function Auctioneer_GetItemData(itemKey)
	local itemID, itemRand, enchant = Auctioneer_BreakItemKey(itemKey);
--	p("Looking for", itemKey, itemID);
	return Auctioneer_GetItemDataByID(itemID);
end

function Auctioneer_GetItemDataByID(itemID)
	local baseData = Auctioneer_BasePrices[itemID];
	if (not baseData) then return nil end

	local baseSplit = Auctioneer_Split(baseData, ":");
	local buy = tonumber(baseSplit[1]);
	local sell = tonumber(baseSplit[2]);
	local class = tonumber(baseSplit[3]);
	local quality = tonumber(baseSplit[4]);
	local stack = tonumber(baseSplit[5]);
	local additional = baseSplit[6];
	local usedby = baseSplit[7];
	local cat = CLASS_TO_CATEGORY_MAP[class];

	local dataItem = {
		buy = buy,
		sell = sell,
		class = class,
		cat = cat,
		quality = quality,
		stack = stack,
		additional = additional,
		usedby = usedby,
	};

--	p("Data item so far", dataItem);

	local addition = "";
	if (additional ~= "") then
--		p("Get localization for", additional);
		addition = " - "..getglobal("AUCT_ADDIT_"..string.upper(additional));
	end
	local catName = Auctioneer_GetCatName(cat);
	if (not catName) then
--		p("Cat name is", catName, "for cat", cat);
		dataItem.classText = "Unknown"..addition;
	else
		dataItem.classText = catName..addition;
	end
	
	if (usedby ~= '') then
		local usedList = Auctioneer_Split(usedby, ",");
		local usage = "";
		local skillName, localized,localeString;
		if (usedList) then
			for pos, userSkill in pairs(usedList) do
				skillName = Auctioneer_Skills[tonumber(userSkill)];
				localized = "Unknown";
				if (skillName) then
					localeString = "AUCT_SKILL_"..string.upper(skillName);
					localized = getglobal(localeString);
				end
				if (usage == "") then
					usage = localized;
				else
					usage = usage .. ", " .. localized;
				end
			end
		end
		dataItem.usageText = usage;
	end

	local reqSkill = 0;
	local reqLevel = 0;
	local skillsRequired = Auctioneer_SkillsRequired[itemID];
	if (skillsRequired) then
		local skillSplit = Auctioneer_Split(skillsRequired, ":");
		reqSkill = skillSplit[1];
		reqLevel = skillSplit[2];
	end
	dataItem.isPlayerMade = (reqSkill ~= 0);
	dataItem.reqSkill = reqSkill;
	dataItem.reqLevel = reqLevel;

	return dataItem;
end
		

-- Returns an AuctionConfig.data item from the table based on an item name
function Auctioneer_GetAuctionPriceItem(itemKey, from)
	local serverFaction;
	local auctionPriceItem, data,info;

	if (from ~= nil) then serverFaction = from;
	else serverFaction = Auctioneer_GetAuctionKey(); end;
	
	--p("Getting data from/for", serverFaction, itemKey);
	if (AuctionConfig.data == nil) then AuctionConfig.data = {}; end
	if (AuctionConfig.info == nil) then AuctionConfig.info = {}; end
	if (AuctionConfig.data[serverFaction] == nil) then
--		p("Data from serverfaction is nil");
		AuctionConfig.data[serverFaction] = {};
	else
		data = AuctionConfig.data[serverFaction][itemKey];
		info = AuctionConfig.info[itemKey];
	end

	auctionPriceItem = {};
	if (data) then
		local dataItem = Auctioneer_Split(data, "|");
		auctionPriceItem.data = dataItem[1];
		auctionPriceItem.buyoutPricesHistoryList = Auctioneer_Split(dataItem[2], ":");
	end
	if (info) then
		local infoItem = Auctioneer_Split(info, "|");
		auctionPriceItem.category = infoItem[2];
		auctionPriceItem.name = infoItem[3];
	end

	local playerMade, reqSkill, reqLevel = Auctioneer_IsPlayerMade(itemKey);
	auctionPriceItem.playerMade = playerMade;
	auctionPriceItem.reqSkill = reqSkill;
	auctionPriceItem.reqLevel = reqLevel;

	return auctionPriceItem;
end

function Auctioneer_SaveAuctionPriceItem(auctKey, itemKey, iData)
	if (not auctKey) then return end
	if (not itemKey) then return end
	if (not iData) then return end

	if (not AuctionConfig.info) then AuctionConfig.info = {}; end
	if (not AuctionConfig.data) then AuctionConfig.data = {}; end
	if (not AuctionConfig.data[auctKey]) then AuctionConfig.data[auctKey] = {}; end

	local hist = "";
	if (iData and iData.buyoutPricesHistoryList) then
		for pos, hPrice in pairs(iData.buyoutPricesHistoryList) do
			if (hist == "") then hist = string.format("%d", hPrice);
			else hist = string.format("%s:%d", hist, hPrice); end
		end
	end

	AuctionConfig.data[auctKey][itemKey] = string.format("%s|%s", iData.data, hist);
	AuctionConfig.info[itemKey] = string.format("%s|%s", iData.category, iData.name);
	if (Auctioneer_HSPCache and Auctioneer_HSPCache[auctKey]) then
		Auctioneer_HSPCache[auctKey][itemKey] = nil;
	end
	if (Auctioneer_Lowests) then Auctioneer_Lowests = nil; end

	local median = Auctioneer_GetMedian(iData.buyoutPricesHistoryList);
	if (not AuctionConfig.stats) then AuctionConfig.stats = {} end
	if (not AuctionConfig.stats.histmed) then AuctionConfig.stats.histmed = {} end
	if (not AuctionConfig.stats.histmed[itemKey]) then AuctionConfig.stats.histmed[itemKey] = {} end
	AuctionConfig.stats.histmed[itemKey][itemKey] = median;
end

-- Returns the auction buyout history for this item
function Auctioneer_GetAuctionBuyoutHistory(itemKey, auctKey)
	local auctionItem = Auctioneer_GetAuctionPriceItem(itemKey, auctKey);
	if (auctionItem == nil) then 
		buyoutHistory = {};
	else
		buyoutHistory = auctionItem.buyoutPricesHistoryList;
	end
	return buyoutHistory;
end

-- Returns the parsed auction price data
function Auctioneer_GetAuctionPrices(priceData)
	if (not priceData) then return 0,0,0,0,0,0,0 end
	local i,j, count,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = string.find(priceData, "^(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)");
	return nullSafe(count),nullSafe(minCount),nullSafe(minPrice),nullSafe(bidCount),nullSafe(bidPrice),nullSafe(buyCount),nullSafe(buyPrice);
end

-- Parse the data from the auction signature
function Auctioneer_GetItemSignature(sigData)
	if (not sigData) then return nil end
	for id,rprop,enchant,name,count,min,buyout,uniq in string.gfind(sigData, "(%d+):(%d+):(%d+):(.-):(%d+):(.-):(%d+):(.+)") do
		if (name == nil) then name = ""; end
		return tonumber(id),tonumber(rprop),tonumber(enchant),name,tonumber(count),tonumber(min),tonumber(buyout),tonumber(uniq);
	end
	return nil;
end

-- Returns the category i.e. "Weapon", "Armor" for an item
function Auctioneer_GetItemCategory(itemKey)
	local category;
	local auctionItem = Auctioneer_GetAuctionPriceItem(itemKey);
	if auctionItem then 
		category = auctionItem.category;
	end

	return auctionItem.category;
end

-- Return all of the averages for an item
-- Returns: avgMin,avgBuy,avgBid,bidPct,buyPct,avgQty,aCount
function Auctioneer_GetMeans(itemKey, from)
	local auctionPriceItem = Auctioneer_GetAuctionPriceItem(itemKey, from);
	if (not auctionPriceItem.data) then
--		p("Error, GetAuctionPriceItem", itemKey, from, "returns", auctionPriceItem);
	end
	local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = Auctioneer_GetAuctionPrices(auctionPriceItem.data);
	local avgMin,avgBuy,avgBid,bidPct,buyPct,avgQty;

	if aCount > 0 then
		avgQty = math.floor(minCount / aCount);
		avgMin = math.floor(minPrice / minCount);
		bidPct = math.floor(bidCount / minCount * 100);
		buyPct = math.floor(buyCount / minCount * 100);

		avgBid = 0;
		if (bidCount > 0) then
			avgBid = math.floor(bidPrice / bidCount);
		end

		avgBuy = 0;
		if (buyCount > 0) then
			avgBuy = math.floor(buyPrice / buyCount);
		end
	end
	return avgMin,avgBuy,avgBid,bidPct,buyPct,avgQty,aCount;
end

-- Returns the current snapshot median for an item
function Auctioneer_GetItemSnapshotMedianBuyout(itemKey, auctKey, buyoutPrices)
	if (not buyoutPrices) then
		buyoutPrices = {};
		if (not auctKey) then auctKey = Auctioneer_GetAuctionKey() end
		local sbuy = Auctioneer_GetSnapshotInfo(auctKey, itemKey);
		if (sbuy) then
			buyoutPrices = sbuy.buyoutPrices;
		else
			return 0, 0;
		end
	end

	local snapMedian = Auctioneer_GetMedian(buyoutPrices);
	local snapSeenCount = table.getn(buyoutPrices);

	if (not AuctionConfig.stats) then AuctionConfig.stats = {} end
	if (not AuctionConfig.stats.snapmed) then AuctionConfig.stats.snapmed = {} end
	if (not AuctionConfig.stats.snapmed[auctKey]) then AuctionConfig.stats.snapmed[auctKey] = {} end
	if (not AuctionConfig.stats.snapcount) then AuctionConfig.stats.snapcount = {} end
	if (not AuctionConfig.stats.snapcount[auctKey]) then AuctionConfig.stats.snapcount[auctKey] = {} end
	if (snapSeenCount >= MIN_BUYOUT_SEEN_COUNT) then
		AuctionConfig.stats.snapmed[auctKey][itemKey] = snapMedian;
		AuctionConfig.stats.snapcount[auctKey][itemKey] = snapSeenCount;
	else
		AuctionConfig.stats.snapmed[auctKey][itemKey] = 0;
		AuctionConfig.stats.snapcount[auctKey][itemKey] = 0;
	end

	return tonumber(snapMedian) or 0, snapSeenCount or 0;
end

function Auctioneer_GetSnapMedian(itemKey, auctKey, buyoutPrices)
	if (not auctKey) then auctKey = Auctioneer_GetAuctionKey() end
	local stat = nil; local count = nil;
	if (AuctionConfig.stats and AuctionConfig.stats.snapmed and AuctionConfig.stats.snapmed[auctKey]) then
		stat = AuctionConfig.stats.snapmed[auctKey][itemKey];
	end
	if (AuctionConfig.stats and AuctionConfig.stats.snapcount and AuctionConfig.stats.snapcount[auctKey]) then
		count = AuctionConfig.stats.snapcount[auctKey][itemKey];
	end
	if (not stat) then
		stat, count = Auctioneer_GetItemSnapshotMedianBuyout(itemKey, auctKey, buyoutPrices);
	end
	return stat or 0, count or 0;
end

function Auctioneer_GetItemHistoricalMedianBuyout(itemKey, auctKey, buyoutHistoryTable)
	local historyMedian = 0;
	local historySeenCount = 0;
	if (not auctKey) then auctKey = Auctioneer_GetAuctionKey() end
	if (not buyoutHistoryTable) then
		local buyoutHistoryTable = Auctioneer_GetAuctionBuyoutHistory(itemKey, auctKey);
		if (buyoutHistoryTable) then
			historyMedian = Auctioneer_GetMedian(buyoutHistoryTable);
			historySeenCount = table.getn(buyoutHistoryTable);
		end
	end

	if (not AuctionConfig.stats) then AuctionConfig.stats = {} end
	if (not AuctionConfig.stats.histmed) then AuctionConfig.stats.histmed = {} end
	if (not AuctionConfig.stats.histmed[auctKey]) then AuctionConfig.stats.histmed[auctKey] = {} end
	if (not AuctionConfig.stats.histcount) then AuctionConfig.stats.histcount = {} end
	if (not AuctionConfig.stats.histcount[auctKey]) then AuctionConfig.stats.histcount[auctKey] = {} end
	if (historySeenCount >= MIN_BUYOUT_SEEN_COUNT) then
		AuctionConfig.stats.histmed[auctKey][itemKey] = historyMedian;
		AuctionConfig.stats.histcount[auctKey][itemKey] = historySeenCount;
	else
		AuctionConfig.stats.histmed[auctKey][itemKey] = 0;
		AuctionConfig.stats.histcount[auctKey][itemKey] = 0;
	end

	return tonumber(historyMedian) or 0, tonumber(historySeenCount) or 0;
end

function Auctioneer_GetHistMedian(itemKey, auctKey, buyoutHistoryTable)
	if (not auctKey) then auctKey = Auctioneer_GetAuctionKey() end
	local stat = nil; local count = nil;
	if (AuctionConfig.stats and AuctionConfig.stats.histmed and AuctionConfig.stats.histmed[auctKey]) then
		stat = AuctionConfig.stats.histmed[auctKey][itemKey];
		count = AuctionConfig.stats.histcount[auctKey][itemKey];
	end
	if (not stat) then
		stat, count = Auctioneer_GetItemHistoricalMedianBuyout(itemKey, auctKey, buyoutHistoryTable);
	end
	return stat or 0, count or 0;
end

-- this function returns the most accurate median possible, 
-- if an accurate median cannot be obtained based on min seen counts then nil is returned
function Auctioneer_GetUsableMedian(itemKey, realm, buyoutPrices)
	local usableMedian = nil;
	local count = nil;
	if not realm then
		realm = Auctioneer_GetAuctionKey();
	end

	--get snapshot median
	local snapshotMedian, snapCount = Auctioneer_GetSnapMedian(itemKey, realm, buyoutPrices)
	--get history median
	local historyMedian, histCount = Auctioneer_GetHistMedian(itemKey, realm);

	if snapshotMedian>0 and (historyMedian==0 or snapshotMedian<(historyMedian * 1.2)) then
		usableMedian = snapshotMedian;
	elseif (historyMedian) then
		usableMedian = historyMedian;
	end
	return usableMedian;
end

function Auctioneer_IsPlayerMade(itemKey)
	local itemID, itemRand, enchant = Auctioneer_BreakItemKey(itemKey);
	
	local reqSkill = 0;
	local reqLevel = 0;
	
	local skillsRequired = Auctioneer_SkillsRequired[itemID];
	if (skillsRequired) then
		local skillSplit = Auctioneer_Split(skillsRequired, ":");
		reqSkill = skillSplit[1];
		reqLevel = skillSplit[2];
	end
	return (reqSkill ~= 0), reqSkill, reqLevel;
end

-- Returns the current bid on an auction
function Auctioneer_GetCurrentBid(auctionSignature)
	local x,x,x, x, x,min,x,_ = Auctioneer_GetItemSignature(auctionSignature);
	local auctKey = Auctioneer_GetAuctionKey();
	local itemCat = Auctioneer_GetCatForSig(auctionSignature);
	local snap = Auctioneer_GetSnapshot(auctKey, itemCat, auctionSignature);
	if (not snap) then return 0 end
	local currentBid = tonumber(snap.bidamount) or 0;
	if currentBid == 0 then currentBid = min end
	return currentBid;
end

-- This filter will return true if an auction is a bad choice for reselling
function Auctioneer_IsBadResaleChoice(auctionSignature)
	local isBadChoice = false;
	local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(auctionSignature);
	local itemKey = id..":"..rprop..":"..enchant;
	local auctKey = Auctioneer_GetAuctionKey();
	local itemCat = Auctioneer_GetCatForKey(itemKey);
	local auctionItem = Auctioneer_GetSnapshot(auctKey, itemCat, auctionSignature);
	local auctionPriceItem = Auctioneer_GetAuctionPriceItem(itemKey, from);
	local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = Auctioneer_GetAuctionPrices(auctionPriceItem.data);
	local bidPercent = math.floor(bidCount / minCount * 100);
	local itemLevel = tonumber(auctionItem.level);
	local itemQuality = tonumber(auctionItem.quality);

	-- bad choice conditions
	if BID_BASED_CATEGORIES[auctionItem.category] and bidPercent < MIN_BID_PERCENT then 
		isBadChoice = true; -- bidbased items should have a minimum bid percent
	elseif (itemLevel >= 50 and itemQuality == QUALITY_UNCOMMON and bidPercent < MIN_BID_PERCENT) then 
		isBadChoice = true; -- level 50 and greater greens that do not have bids do not sell well  
	elseif auctionItem.owner == UnitName("player") or auctionItem.highBidder then 
		isBadChoice = true; -- don't display auctions that we own, or are high bidder on
	elseif itemQuality == QUALITY_POOR then 
		isBadChoice = true; -- gray items are never a good choice
	end

	return isBadChoice;
end

-- filters out all auctions except those that meet profit requirements
function Auctioneer_BrokerFilter(minProfit, signature)
	local filterAuction = true;
	local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(signature);
	local itemKey = id..":"..rprop..":"..enchant;

	if Auctioneer_GetUsableMedian(itemKey) then -- we have a useable median
		local hsp = Auctioneer_GetHSP(itemKey, Auctioneer_GetAuctionKey());
		local profit = (hsp * count) - buyout;
		local profitPricePercent = math.floor((profit / buyout) * 100);

		--see if this auction should not be filtered
		if (buyout and buyout > 0 and buyout <= MAX_BUYOUT_PRICE and profit >= minProfit and not Auctioneer_IsBadResaleChoice(signature) and profitPricePercent >= MIN_PROFIT_PRICE_PERCENT) then
			filterAuction = false;
		end
	end

	return filterAuction;
end

-- filters out all auctions except those that have short or medium time remaining and meet profit requirements
function Auctioneer_BidBrokerFilter(minProfit, signature)
	local filterAuction = true;
	local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(signature);
	local itemKey = id..":"..rprop..":"..enchant;

	if Auctioneer_GetUsableMedian(itemKey) then  -- only add if we have seen it enough times to have a usable median
		local auctKey = Auctioneer_GetAuctionKey();
		local currentBid = Auctioneer_GetCurrentBid(signature);
		local sbuy = Auctioneer_GetSnapshotInfo(auctKey, itemKey);
		local buyoutValues = {};
		if (sbuy) then buyoutValues = sbuy.buyoutPrices end
		local lowest, second = Auctioneer_GetLowest(buyoutValues);

		-- Take a generous stab in the dark at what the HSP will be
		-- If the current bid falls under that value, only then should
		-- we go to the effort of calculating actual profit.
		-- Note: if second == nil, this indicates no competition.
		if (second == nil or currentBid < second * 1.2) then
			local hsp, x,x,x, nhsp = Auctioneer_GetHSP(itemKey, auctKey, buyoutValues);
			-- hsp is the HSP with the lowest priced item still in the auction, nshp is the next highest price.

			local profit = (hsp * count) - currentBid;
			local profitPricePercent = math.floor((profit / currentBid) * 100);

			--see if this auction should not be filtered
			local auctKey = Auctioneer_GetAuctionKey();
			local itemCat = Auctioneer_GetCatForKey(itemKey);
			local snap = Auctioneer_GetSnapshot(auctKey, itemCat, signature);
			local timeLeft = tonumber(snap.timeLeft);
			if (currentBid <= MAX_BUYOUT_PRICE and profit >= minProfit and timeLeft <= TIME_LEFT_MEDIUM and not Auctioneer_IsBadResaleChoice(signature) and profitPricePercent >= MIN_PROFIT_PRICE_PERCENT) then
				filterAuction = false;
			end
		end
	end

	return filterAuction;
end

function Auctioneer_AuctionOwnerFilter(owner, signature)
	local auctKey = Auctioneer_GetAuctionKey();
	local itemCat = Auctioneer_GetCatForSig(signature);
	local snap = Auctioneer_GetSnapshot(auctKey, itemCat, signature);
	if (snap.owner == owner) then
		return false;
	end
	return true;
end

function Auctioneer_CompetingFilter(minLess, signature, myAuctions)
	local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(signature);
	if (count > 1) then buyout = buyout/count; end
	local itemKey = id..":"..rprop..":"..enchant;

	local auctKey = Auctioneer_GetAuctionKey();
	local itemCat = Auctioneer_GetCatForSig(signature);
	local snap = Auctioneer_GetSnapshot(auctKey, itemCat, signature);
	if (snap.owner ~= UnitName("player")) and
		(myAuctions[itemKey]) and
		(buyout > 0) and
		(buyout+minLess < myAuctions[itemKey]) then
		return false;
	end
	return true;
end


-- filters out all auctions that are not a given percentless than the median for that item.
function Auctioneer_PercentLessFilter(percentLess, signature)
	local filterAuction = true;
	local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(signature);
	local itemKey = id .. ":" .. rprop..":"..enchant;
	local hsp = Auctioneer_GetHSP(itemKey, Auctioneer_GetAuctionKey());

	if hsp > 0 then
		local profit = (hsp * count) - buyout;
		--see if this auction should not be filtered
		if (buyout > 0 and Auctioneer_PercentLessThan(hsp, buyout / count) >= tonumber(percentLess) and profit >= MIN_PROFIT_MARGIN) then
			filterAuction = false;
		end
	end

	return filterAuction;
end


-- generic function for querying the snapshot with a filter function that returns true if an auction should be filtered out of the result set.
function Auctioneer_QuerySnapshot(filter, param, extra1, extra2)
	local queryResults = {};
	param = param or "";

	local a;
	local auctKey = Auctioneer_GetAuctionKey();
	if (AuctionConfig and AuctionConfig.snap and AuctionConfig.snap[auctKey]) then
		for itemCat, iData in pairs(AuctionConfig.snap[auctKey]) do
			for auctionSignature, data in pairs(iData) do
				if(not filter(param, auctionSignature, extra1, extra2)) then
					a = Auctioneer_GetSnapshotFromData(data);
					a.signature = auctionSignature;
					table.insert(queryResults, a);
				end
			end
		end
	end

	return queryResults;
end
Auctioneer_QuerySnapshot = Auctioneer_QuerySnapshot;


-- method to pass to table.sort() that sorts auctions by profit descending
function Auctioneer_ProfitComparisonSort(a, b)
	local aid,arprop,aenchant, aName, aCount, x, aBuyout, x = Auctioneer_GetItemSignature(a.signature);
	local bid,brprop,benchant, bName, bCount, x, bBuyout, x = Auctioneer_GetItemSignature(b.signature);
	local aItemKey = aid .. ":" .. arprop..":"..aenchant;
	local bItemKey = bid .. ":" .. brprop..":"..benchant;
	local realm = Auctioneer_GetAuctionKey()
	local aProfit = (Auctioneer_GetHSP(aItemKey, realm) * aCount) - aBuyout;
	local bProfit = (Auctioneer_GetHSP(bItemKey, realm) * bCount) - bBuyout;
	return (aProfit > bProfit) 
end
Auctioneer_ProfitComparisonSort = Auctioneer_ProfitComparisonSort;


-- function returns true, if the given parameter is a valid option for the also command, false otherwise
function Auctioneer_IsValidAlso(also)
	-- make also a required parameter
	if (also == nil) then
		return false	-- missing parameter
	end

	if (also == 'opposite') or (also == 'off') then
		return true	-- allow special keywords
	end

	-- check if string matches: "[realm]-[faction]"
	local s, e, r, f = string.find(also, "^(.+)-(.+)$")
	if (s == nil) then
		return false	-- invalid string
	end

	-- check if faction = "Horde" or "Alliance"
	if (f ~= 'Horde') and (f ~= 'Alliance') then
		return false	-- invalid faction
	end

	return true
end


-- builds the list of auctions that can be bought and resold for profit
function Auctioneer_DoBroker(minProfit)
	if not minProfit or minProfit == "" then minProfit = MIN_PROFIT_MARGIN else minProfit = tonumber(minProfit) * 100  end
	local output = string.format(AUCT_FRMT_BROKER_HEADER, TT_GetTextGSC(minProfit));
	Auctioneer_ChatPrint(output);

	local resellableAuctions = Auctioneer_QuerySnapshot(Auctioneer_BrokerFilter, minProfit);

	-- sort by profit decending
	table.sort(resellableAuctions, Auctioneer_ProfitComparisonSort);

	-- output the list of auctions
	local id,rprop,enchant,name,count,min,buyout,uniq,itemKey,hsp,seenCount,profit,output;
	if (resellableAuctions) then
		for pos,a in pairs(resellableAuctions) do
			id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(a.signature); 
			itemKey = id .. ":" .. rprop..":"..enchant;
			hsp, seenCount = Auctioneer_GetHSP(itemKey, Auctioneer_GetAuctionKey());
			profit = (hsp * count) - buyout;
			output = string.format(AUCT_FRMT_BROKER_LINE, Auctioneer_ColorTextWhite(count.."x")..a.itemLink, seenCount, TT_GetTextGSC(hsp * count), TT_GetTextGSC(buyout), TT_GetTextGSC(profit));
			Auctioneer_ChatPrint(output);
		end
	end

	Auctioneer_ChatPrint(AUCT_FRMT_BROKER_DONE);
end

-- builds the list of auctions that can be bought and resold for profit
function Auctioneer_DoBidBroker(minProfit)
	if not minProfit or minProfit == "" then minProfit = MIN_PROFIT_MARGIN else minProfit = tonumber(minProfit) * 100  end
	local output = string.format(AUCT_FRMT_BIDBROKER_HEADER, TT_GetTextGSC(minProfit));
	Auctioneer_ChatPrint(output);

	local bidWorthyAuctions = Auctioneer_QuerySnapshot(Auctioneer_BidBrokerFilter, minProfit);

	table.sort(bidWorthyAuctions, function(a, b) return (a.timeLeft < b.timeLeft) end);

	-- output the list of auctions
	local id,rprop,enchant, name, count,min,buyout,uniq,itemKey,hsp,seenCount,currentBid,profit,bidText,output;
	if (bidWorthyAuctions) then
		for pos,a in pairs(bidWorthyAuctions) do
			id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(a.signature);
			itemKey = id .. ":" .. rprop..":"..enchant;
			hsp, seenCount = Auctioneer_GetHSP(itemKey, Auctioneer_GetAuctionKey());
			currentBid = Auctioneer_GetCurrentBid(a.signature);
			profit = (hsp * count) - currentBid;

			bidText = AUCT_FRMT_BIDBROKER_CURBID;
			if (currentBid == min) then
				bidText = AUCT_FRMT_BIDBROKER_MINBID;
			end
			output = string.format(AUCT_FRMT_BIDBROKER_LINE, Auctioneer_ColorTextWhite(count.."x")..a.itemLink, seenCount, TT_GetTextGSC(hsp * count), bidText, TT_GetTextGSC(currentBid), TT_GetTextGSC(profit), Auctioneer_ColorTextWhite(Auctioneer_GetTimeLeftString(a.timeLeft)));
			Auctioneer_ChatPrint(output);
		end
	end

	Auctioneer_ChatPrint(AUCT_FRMT_BIDBROKER_DONE);
end

function Auctioneer_DoCompeting(minLess)
	if not minLess or minLess == "" then minLess = DEFAULT_COMPETE_LESS * 100 else minLess = tonumber(minLess) * 100  end
	local output = string.format(AUCT_FRMT_COMPETE_HEADER, TT_GetTextGSC(minLess));
	Auctioneer_ChatPrint(output);

	local myAuctions = Auctioneer_QuerySnapshot(Auctioneer_AuctionOwnerFilter, UnitName("player"));
	local myHighestPrices = {}
	local id,rprop,enchant,name,count,min,buyout,uniq,itemKey,competingAuctions,currentBid,buyoutForOne,bidForOne,bidPrice,myBuyout,buyPrice,myPrice,priceLess,lessPrice,output;
	if (myAuctions) then
		for pos,a in pairs(myAuctions) do
			id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(a.signature);
			if (count > 1) then buyout = buyout/count; end
			itemKey = id .. ":" .. rprop..":"..enchant;
			if (not myHighestPrices[itemKey]) or (myHighestPrices[itemKey] < buyout) then
				myHighestPrices[itemKey] = buyout;
			end
		end
	end
	competingAuctions = Auctioneer_QuerySnapshot(Auctioneer_CompetingFilter, minLess, myHighestPrices);

	table.sort(competingAuctions, Auctioneer_ProfitComparisonSort);

	-- output the list of auctions
	if (competingAuctions) then
		for pos,a in pairs(competingAuctions) do
			id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(a.signature);
			itemKey = id .. ":" .. rprop..":"..enchant;
			currentBid = Auctioneer_GetCurrentBid(a.signature);

			buyoutForOne = buyout;
			bidForOne = currentBid;
			if (count > 1) then
				buyoutForOne = buyout/count;
				bidForOne = currentBid/count;
			end

			bidPrice = TT_GetTextGSC(bidForOne).."ea";
			if (currentBid == min) then
				bidPrice = "No bids ("..bidPrice..")";
			end

			myBuyout = myHighestPrices[itemKey];
			buyPrice = TT_GetTextGSC(buyoutForOne).."ea";
			myPrice = TT_GetTextGSC(myBuyout).."ea";
			priceLess = myBuyout - buyoutForOne;
			lessPrice = TT_GetTextGSC(priceLess);

			output = string.format(AUCT_FRMT_COMPETE_LINE, Auctioneer_ColorTextWhite(count.."x")..a.itemLink, bidPrice, buyPrice, myPrice, lessPrice);
			Auctioneer_ChatPrint(output);
		end
	end

	Auctioneer_ChatPrint(AUCT_FRMT_COMPETE_DONE);
end

-- builds the list of auctions that can be bought and resold for profit
function Auctioneer_DoPercentLess(percentLess)    
	if not percentLess or percentLess == "" then percentLess = MIN_PERCENT_LESS_THAN_HSP end
	local output = string.format(AUCT_FRMT_PCTLESS_HEADER, percentLess);
	Auctioneer_ChatPrint(output);

	local auctionsBelowHSP = Auctioneer_QuerySnapshot(Auctioneer_PercentLessFilter, percentLess);

	-- sort by profit based on median
	table.sort(auctionsBelowHSP, Auctioneer_ProfitComparisonSort);

	-- output the list of auctions
	local id,rprop,enchant,name,count,buyout,itemKey,hsp,seenCount,profit,output,x;
	if (auctionsBelowHSP) then
		for pos,a in pairs(auctionsBelowHSP) do
			id,rprop,enchant, name, count,x,buyout,x = Auctioneer_GetItemSignature(a.signature);
			itemKey = id ..":"..rprop..":"..enchant;
			hsp, seenCount = Auctioneer_GetHSP(itemKey, Auctioneer_GetAuctionKey());
			profit = (hsp * count) - buyout;
			output = string.format(AUCT_FRMT_PCTLESS_LINE, Auctioneer_ColorTextWhite(count.."x")..a.itemLink, seenCount, TT_GetTextGSC(hsp * count), TT_GetTextGSC(buyout), TT_GetTextGSC(profit), Auctioneer_ColorTextWhite(Auctioneer_PercentLessThan(hsp, buyout / count).."%"));
			Auctioneer_ChatPrint(output);
		end
	end

	Auctioneer_ChatPrint(AUCT_FRMT_PCTLESS_DONE);
end

-- given an item name, find the lowest price for that item in the current AHSnapshot
-- if the item does not exist in the snapshot or the snapshot does not exist
-- a nil is returned.
function Auctioneer_FindLowestAuctions(itemKey, auctKey) 
	local itemID, itemRand, enchant = Auctioneer_BreakItemKey(itemKey);
	if (itemID == nil) then return nil; end
	if (not auctKey) then
		auctKey = Auctioneer_GetAuctionKey();
	end
	if not (Auctioneer_Lowests and Auctioneer_Lowests.built) then Auctioneer_BuildLowestCache(auctKey) end

	lowKey = itemID..":"..itemRand..":";

	local itemCat = nil;
	local lowSig = nil;
	local nextSig = nil;
	local lowestPrice = 0;
	local nextLowest = 0;

	local lows = Auctioneer_Lowests[lowKey];
	if (lows) then
		lowSig = lows.lowSig;
		nextSig = lows.nextSig;
		lowestPrice = lows.lowestPrice or 0;
		nextLowest = lows.nextLowest or 0;
		itemCat = lows.cat;
	end

	return lowSig, lowestPrice, nextSig, nextLowest, itemCat;
end

function Auctioneer_BuildLowestCache(auctKey)
	Auctioneer_Lowests = {};
	local id, rprop, enchant, name, count, min, buyout, uniq, lowKey, priceForOne, curSig, curLowest;
	if (AuctionConfig and AuctionConfig.snap and AuctionConfig.snap[auctKey]) then
		for itemCat, cData in pairs(AuctionConfig.snap[auctKey]) do
			for sig, sData in pairs(cData) do
				id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(sig);
				lowKey = id..":"..rprop;
				if (not Auctioneer_Lowests[lowKey]) then Auctioneer_Lowests[lowKey] = {} end
				
				priceForOne = buyout;
				if (count and count > 0) then priceForOne = (buyout / count); end
					
				curSig = Auctioneer_Lowests[lowKey].lowSig;
				curLowest = Auctioneer_Lowests[lowKey].lowestPrice or 0;
				if (buyout > 0 and (curLowest == 0 or priceForOne < curLowest)) then 
					Auctioneer_Lowests[lowKey] = {
						nextSig = curSig, nextLowest = curLowest, lowSig = sig, lowestPrice = priceForOne, cat = itemCat
					};
				end
			end
		end
	end
	Auctioneer_Lowests.built = true;
end

function Auctioneer_DoMedian(link)
	local itemID, randomProp, enchant, uniqID, itemName = TT_BreakLink(link);
	local itemKey = itemID..":"..randomProp..":"..enchant;

	local median, count = Auctioneer_GetUsableMedian(itemKey);
	if (not median) then
		Auctioneer_ChatPrint(string.format(AUCT_FRMT_MEDIAN_NOAUCT, Auctioneer_ColorTextWhite(itemName)));
	else
		Auctioneer_ChatPrint(string.format(AUCT_FRMT_MEDIAN_LINE, count, Auctioneer_ColorTextWhite(itemName), TT_GetTextGSC(median)));
	end
end

function Auctioneer_GetBidBasedSellablePrice(itemKey,realm, avgMin,avgBuy,avgBid,bidPct,buyPct,avgQty,seenCount)
	-- We can pass these values along if we have them.
	if (seenCount == nil) then
		avgMin,avgBuy,avgBid,bidPct,buyPct,avgQty,seenCount = Auctioneer_GetMeans(itemKey, realm);
	end
	local bidBasedSellPrice = 0;
	local typicalBuyout = 0;

	local medianBuyout = Auctioneer_GetUsableMedian(itemKey, realm);
	if medianBuyout then
		typicalBuyout = math.min(avgBuy, medianBuyout)  ;
	else
		typicalBuyout = avgBuy;
	end

	bidBasedSellPrice = math.floor((3*typicalBuyout + avgBid) / 4);
	return bidBasedSellPrice;
end

-- returns the best market price - 0, if no market price could be calculated
function Auctioneer_GetMarketPrice(itemKey, realm, buyoutValues)
	-- make sure to call this function with valid parameters! No check is being performed!
	local buyoutMedian = nullSafe(Auctioneer_GetUsableMedian(itemKey, realm, buyoutValues))
	local avgMin, avgBuy, avgBid, bidPct, buyPct, avgQty, meanCount = Auctioneer_GetMeans(itemKey, realm)
	local commonBuyout = 0

	-- assign the best common buyout
	if buyoutMedian > 0 then
		commonBuyout = buyoutMedian
	elseif meanCount and meanCount > 0 then
		-- if a usable median does not exist, use the average buyout instead
		commonBuyout = avgBuy;
	end

	local playerMade, skill, level = Auctioneer_IsPlayerMade(itemKey);
	if BID_BASED_CATEGORIES[Auctioneer_GetItemCategory(itemKey)] and not (playerMade and level < 250 and commonBuyout < 100000) then
		-- returns bibasedSellablePrice for bidbaseditems, playermade items or if the buyoutprice is not present or less than 10g
		return Auctioneer_GetBidBasedSellablePrice(itemKey,realm, avgMin,avgBuy,avgBid,bidPct,buyPct,avgQty,seenCount)
	end

	-- returns buyoutMedian, if present - returns avgBuy otherwise, if meanCount > 0 - returns 0 otherwise
	return commonBuyout
end

-- Returns market information relating to the HighestSellablePrice for one of the given items.
-- If you use cached data it may be affected by buying/selling items.
HSPCOUNT = 0; CACHECOUNT = 0;
function Auctioneer_GetHSP(itemKey, realm, buyoutValues, itemCat)
	if (itemKey == nil) then                                 -- make itemKey a required parameter
		p("ERROR: Calling Auctioneer_GetHSP(itemKey, realm) - Function requires valid itemKey.");
		return nil;
	end
	if (realm == nil) then
		p("WARNING: Auctioneer_GetHSP(itemKey, realm) - Defaulting to player realm.");
		realm = Auctioneer_GetAuctionKey();
	end

	if (not Auctioneer_HSPCache) then Auctioneer_HSPCache = {}; end
	CACHECOUNT = CACHECOUNT + 1;

	if (not Auctioneer_HSPCache[realm]) then Auctioneer_HSPCache[realm] = {} end
	local cached = Auctioneer_HSPCache[realm][itemKey];
	if (cached) then
		local cache = Auctioneer_Split(cached, ";");
		return tonumber(cache[1]), tonumber(cache[2]), tonumber(cache[3]), cache[4], tonumber(cache[5]), cache[6];
	end
	HSPCOUNT = HSPCOUNT + 1;

	local highestSellablePrice = 0;
	local warn = AUCT_FRMT_WARN_NODATA;
	--p("Getting HSP, calling GetMarketPrice", itemKey, realm);
	if (not buyoutValues) then
		buyoutValues = Auctioneer_GetSnapshotInfo(itemKey, realm);
	end
	
	local marketPrice = Auctioneer_GetMarketPrice(itemKey, realm, buyoutValues);

	-- Get our user-set pricing parameters
	local lowestAllowedPercentBelowMarket = tonumber(Auctioneer_GetFilterVal(AUCT_CMD_PCT_MAXLESS, AUCT_OPT_PCT_MAXLESS_DEFAULT));
	local discountLowPercent = tonumber(Auctioneer_GetFilterVal(AUCT_CMD_PCT_UNDERLOW, AUCT_OPT_PCT_UNDERLOW_DEFAULT));
	local discountMarketPercent = tonumber(Auctioneer_GetFilterVal(AUCT_CMD_PCT_UNDERMKT, AUCT_OPT_PCT_UNDERMKT_DEFAULT));
	local discountNoCompetitionPercent = tonumber(Auctioneer_GetFilterVal(AUCT_CMD_PCT_NOCOMP, AUCT_OPT_PCT_NOCOMP_DEFAULT));
	local vendorSellMarkupPercent = tonumber(Auctioneer_GetFilterVal(AUCT_CMD_PCT_MARKUP, AUCT_OPT_PCT_MARKUP_DEFAULT));

	local x, histCount = Auctioneer_GetUsableMedian(itemKey, realm, buyoutValues);
	histCount = nullSafe(histCount);

	local id = Auctioneer_BreakItemKey(itemKey);

	-- Get the snapshot sigs of the two lowest auctions
	local currentLowestSig = nil;
	local currentLowestBuyout = nil;
	local currentLowestCount = nil;

	local nextLowestSig = nil;
	local nextLowestBuyout = nil;
	local nextLowestCount = nil;

	local lowSig, lowPrice, nextSig, nextPrice, itemCat = Auctioneer_FindLowestAuctions(itemKey, realm);
	if lowSig then
		currentLowestSig = lowSig;
		currentLowestBuyout = lowPrice;
		nextLowestSig = nextSig;
		nextLowestBuyout = nextPrice;
	end

	if (not itemCat) then itemCat = Auctioneer_GetCatForKey(itemKey) end

	local hsp, market, warn = Auctioneer_DeterminePrice(id, realm, marketPrice, currentLowestBuyout, currentLowestSig, lowestAllowedPercentBelowMarket, discountLowPercent, discountMarketPercent, discountNoCompetitionPercent, vendorSellMarkupPercent, itemCat);
	local nexthsp, x, nextwarn = Auctioneer_DeterminePrice(id, realm, marketPrice, nextLowestBuyout, nextLowestSig, lowestAllowedPercentBelowMarket, discountLowPercent, discountMarketPercent, discountNoCompetitionPercent, vendorSellMarkupPercent, itemCat);


	if (not hsp) then
		p("Unable to calc HSP for",id, realm, marketPrice, currentLowestBuyout, currentLowestSig);
		hsp = 0;
		warn = "";
	end
	if (not nexthsp) then nexthsp = 0; nextwarn = ""; end

--	p("Auction data: ", hsp, histCount, market, warn, nexthsp, nextwarn);

	local cache = string.format("%d;%d;%d;%s;%d;%s", hsp,histCount,market,warn, nexthsp,nextwarn);
	Auctioneer_HSPCache[realm][itemKey] = cache;

	return hsp, histCount, market, warn, nexthsp, nextwarn;
end
Auctioneer_GetHighestSellablePriceForOne = Auctioneer_GetHSP;
getHighestSellablePriceForOne = Auctioneer_GetHSP;

function Auctioneer_DeterminePrice(id, realm, marketPrice, currentLowestBuyout, currentLowestSig, lowestAllowedPercentBelowMarket, discountLowPercent, discountMarketPercent, discountNoCompetitionPercent, vendorSellMarkupPercent, itemCat)

	local warn, highestSellablePrice, lowestBuyoutPriceAllowed;
	
	if marketPrice and marketPrice > 0 then
		if currentLowestBuyout and currentLowestBuyout > 0 then
			lowestBuyoutPriceAllowed = Auctioneer_SubtractPercent(marketPrice, lowestAllowedPercentBelowMarket);
			if (not itemCat) then itemCat = Auctioneer_GetCatForSig(currentLowestSig) end

			-- since we don't want to decode the full data unless there's a chance it belongs to the player
			-- do a substring search for the players name first.
			local snap;
			if (string.find(AuctionConfig.snap[realm][itemCat][currentLowestSig], UnitName("player"), 1, true)) then
				snap = Auctioneer_GetSnapshot(realm, itemCat, currentLowestSig);
			end
			if snap and snap.owner == UnitName("player") then
				highestSellablePrice = currentLowestBuyout; -- If I am the lowest seller use same low price
				warn = AUCT_FRMT_WARN_MYPRICE;
			elseif (currentLowestBuyout < lowestBuyoutPriceAllowed) then
				highestSellablePrice = Auctioneer_SubtractPercent(marketPrice, discountMarketPercent);
				warn = AUCT_FRMT_WARN_TOOLOW;
			elseif (currentLowestBuyout > marketPrice) then
				highestSellablePrice = Auctioneer_SubtractPercent(marketPrice, discountNoCompetitionPercent);
				warn = AUCT_FRMT_WARN_ABOVEMKT;
			else -- use discount low
				-- set highest price to "Discount low"
				highestSellablePrice = Auctioneer_SubtractPercent(currentLowestBuyout, discountLowPercent);
				warn = string.format(AUCT_FRMT_WARN_UNDERCUT, discountLowPercent);
			end
		else -- no low buyout, use discount no competition
			-- set highest price to "Discount no competition"
			highestSellablePrice = Auctioneer_SubtractPercent(marketPrice, discountNoCompetitionPercent);
			warn = AUCT_FRMT_WARN_NOCOMP;
		end
	else -- no market
		-- Note: urentLowestBuyout is nil, incase the realm is not the current player's realm
		if currentLowestBuyout and currentLowestBuyout > 0 then
			-- set highest price to "Discount low"
--~ p("Discount low case 2");
			highestSellablePrice = Auctioneer_SubtractPercent(currentLowestBuyout, discountLowPercent);
			warn = string.format(AUCT_FRMT_WARN_UNDERCUT, discountLowPercent);
		else
			local baseData = Auctioneer_GetItemDataByID(id);
			if (baseData and baseData.sell) then
				-- use vendor prices if no auction data available
				local vendorSell = nullSafe(baseData.sell); -- use vendor prices
				highestSellablePrice = Auctioneer_AddPercent(vendorSell, vendorSellMarkupPercent);
				warn = string.format(AUCT_FRMT_WARN_MARKUP, vendorSellMarkupPercent);
			end
		end
	end

	return highestSellablePrice, marketPrice, warn;
end

-- execute the '/auctioneer low <itemName>' that returns the auction for an item with the lowest buyout
function Auctioneer_DoLow(link)
	local itemID, randomProp, enchant, uniqID, itemName = TT_BreakLink(link);
	local itemKey = itemID..":"..randomProp..":"..enchant;

	local auctionSignature = Auctioneer_FindLowestAuctions(itemKey);
	if (not auctionSignature) then
		Auctioneer_ChatPrint(string.format(AUCT_FRMT_NOAUCT, Auctioneer_ColorTextWhite(itemName)));
	else
		local auctKey = Auctioneer_GetAuctionKey();
		local itemCat = Auctioneer_GetCatForKey(itemKey);
		local auction = Auctioneer_GetSnapshot(auctKey, itemCat, auctionSignature);
		local x,x,x, x, count, x, buyout, x = Auctioneer_GetItemSignature(auctionSignature);
		Auctioneer_ChatPrint(string.format(AUCT_FRMT_LOW_LINE, Auctioneer_ColorTextWhite(count.."x")..auction.itemLink, TT_GetTextGSC(buyout), Auctioneer_ColorTextWhite(auction.owner), TT_GetTextGSC(buyout / count), Auctioneer_ColorTextWhite(Auctioneer_PercentLessThan(Auctioneer_GetUsableMedian(itemKey), buyout / count).."%")));
	end
end

function Auctioneer_DoHSP(link)
	local itemID, randomProp, enchant, uniqID, itemName = TT_BreakLink(link);
	local itemKey = itemID..":"..randomProp..":"..enchant;
	local highestSellablePrice = Auctioneer_GetHSP(itemKey, Auctioneer_GetAuctionKey());
	Auctioneer_ChatPrint(string.format(AUCT_FRMT_HSP_LINE, Auctioneer_ColorTextWhite(itemName), TT_GetTextGSC(nilSafeString(highestSellablePrice))));
end


-- Hook into this function if you want notification when we find a link.
function Auctioneer_ProcessLink(link)
	if (ItemsMatrix_ProcessLinks ~= nil) then
		ItemsMatrix_ProcessLinks(	link, -- itemlink
											nil,  -- not used atm
											nil,  -- vendorprice - TODO: not calculatable in AH?
											nil	-- event - TODO: donno, maybe only for chatevents?
										)
	end
	if (LootLink_ProcessLinks ~= nil) then
		LootLink_ProcessLinks(	link, -- itemlink
										true  -- TODO: uncertain? - ah is a trustable source?
									);
	end
end

-- Called by scanning hook when an auction item is scanned from the Auction house
-- we save the aution item to our tables, increment our counts etc
function Auctioneer_AuctionEntry_Hook(page, index, category)
--	p("Processing page", page, "item", index);
	local auctionDoneKey;
	if (not page or not index or not category) then
		return;
	else
		auctionDoneKey = category.."-"..page.."-"..index;
	end
	if (not Auction_DoneItems[auctionDoneKey]) then
		Auction_DoneItems[auctionDoneKey] = true;
	else
		return;
	end

	lTotalAuctionsScannedCount = lTotalAuctionsScannedCount + 1;

	local aiName, aiTexture, aiCount, aiQuality, aiCanUse, aiLevel, aiMinBid, aiMinIncrement, aiBuyoutPrice, aiBidAmount, aiHighBidder, aiOwner = GetAuctionItemInfo("list", index);
	if (aiOwner == nil) then aiOwner = "unknown"; end

	-- do some validation of the auction data that was returned
	if (aiName == nil or tonumber(aiBuyoutPrice) > MAX_ALLOWED_FORMAT_INT or tonumber(aiMinBid) > MAX_ALLOWED_FORMAT_INT) then return; end
	if (aiCount < 1) then aiCount = 1; end

	-- get other auctiondata
	local aiTimeLeft = GetAuctionItemTimeLeft("list", index);
	local aiLink = GetAuctionItemLink("list", index);

	-- Call some interested iteminfo addons
	Auctioneer_ProcessLink(aiLink);
	
	local aiItemID, aiRandomProp, aiEnchant, aiUniqID = TT_BreakLink(aiLink);
	local aiKey = aiItemID..":"..aiRandomProp..":"..aiEnchant;
	local hyperlink = string.format("item:%d:%d:%d:%d", aiItemID, aiEnchant, aiRandomProp, aiUniqID);

	-- Get all item data
	local iName, iLink, iQuality, iLevel, iClass, iSubClass, iCount, iMaxStack = GetItemInfo(hyperlink);
	local itemCat = Auctioneer_GetCatNumberByName(iClass);
	
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


	-- if this auction is not in the snapshot add it
	local auctKey = Auctioneer_GetAuctionKey();
	local snap = Auctioneer_GetSnapshot(auctKey, itemCat, lAuctionSignature);
	
	-- If we haven't seen this item (it's not in the old snapshot)
	if (not snap) then 
--		p("No snap");
		lNewAuctionsCount = lNewAuctionsCount + 1;

		-- now build the list of buyout prices seen for this auction to use to get the median
		local newBuyoutPricesList = newBalancedList(lMaxBuyoutHistorySize);

		local auctionPriceItem = Auctioneer_GetAuctionPriceItem(aiKey, auctKey);
		if (not auctionPriceItem) then auctionPriceItem = {} end
		
		local seenCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = Auctioneer_GetAuctionPrices(auctionPriceItem.data);
		seenCount = seenCount + 1;
		minCount = minCount + 1;
		minPrice = minPrice + nullSafe(aiMinBid);
		if (nullSafe(aiBidAmount) > 0) then
			bidCount = bidCount + 1;
			bidPrice = bidPrice + nullSafe(aiBidAmount);
		end
		if (nullSafe(aiBuyoutPrice) > 0) then
			buyCount = buyCount + 1;
			buyPrice = buyPrice + nullSafe(aiBuyoutPrice);
		end
		auctionPriceItem.data = string.format("%d:%d:%d:%d:%d:%d:%d", seenCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice);

		local bph = auctionPriceItem.buyoutPricesHistoryList;
		if (bph and table.getn(bph) > 0) then
			newBuyoutPricesList.setList(bph);
		end
		if (nullSafe(aiBuyoutPrice) > 0) then
			newBuyoutPricesList.insert(math.floor(aiBuyoutPrice / aiCount));
		end

		auctionPriceItem.buyoutPricesHistoryList = newBuyoutPricesList.getList();
		auctionPriceItem.name = aiName;
		auctionPriceItem.category = itemCat;
		Auctioneer_SaveAuctionPriceItem(auctKey, aiKey, auctionPriceItem);

		-- finaly add the auction to the snapshot
		if (aiOwner == nil) then aiOwner = "unknown"; end
		local initialTimeSeen = time();

		snap = {
			initialSeenTime=initialTimeSeen, 
			lastSeenTime=initialTimeSeen, 
			itemLink=aiLink, 
			quality=nullSafe(aiQuality), 
			level=nullSafe(aiLevel), 
			bidamount=nullSafe(aiBidAmount), 
			highBidder=aiHighBidder, 
			owner=aiOwner, 
			timeLeft=nullSafe(aiTimeLeft), 
			category=itemCat, 
			dirty=0
		};

	else
--		p("Snap!");
		lOldAuctionsCount = lOldAuctionsCount + 1;
		--this is an auction that was already in the snapshot from a previous scan and is still in the auction house
		snap.dirty = 0;                         --set its dirty flag to false so we know to keep it in the snapshot
		snap.lastSeenTime = time();             --set the time we saw it last
		snap.timeLeft = nullSafe(aiTimeLeft);   --update the time left
		snap.bidamount = nullSafe(aiBidAmount); --update the current bid amount
		snap.highBidder = aiHighBidder;         --update the high bidder
	end

	-- Commit the snapshot back to the table.
	Auctioneer_SaveSnapshot(auctKey, itemCat, lAuctionSignature, snap);
end

function Auctioneer_ItemPopup(name, link, quality, count, hyperlink)
	return Auctioneer_OldPopup(name, link, quality, count, hyperlink);
end

function Auctioneer_NewTooltip(frame, name, link, quality, count)
	Auctioneer_OldTooltip(frame, name, link, quality, count);
	
	if (not link) then p("No link was passed to the client");  return; end

	-- nothing to do, if auctioneer is disabled
	if (not Auctioneer_GetFilter("all")) then
		return;
	end;
	
	local auctKey = Auctioneer_GetAuctionKey();
	
	-- initialize local variables
	local itemID, randomProp, enchant, uniqID, lame = TT_BreakLink(link);
	local itemKey = itemID..":"..randomProp..":"..enchant;
	local embedded = Auctioneer_GetFilter(AUCT_CMD_EMBED);

	-- OUTPUT: seperator line
	if (embedded) then
		if (Auctioneer_GetFilter(AUCT_SHOW_EMBED_BLANK)) then
			TT_AddLine(" ", nil, embedded);
		end
	else
		TT_AddLine(name, nil, embedded);
		TT_LineQuality(quality);
	end

	if (Auctioneer_GetFilter(AUCT_SHOW_LINK)) then
		-- OUTPUT: show item link
		TT_AddLine("Link: " .. itemKey .. ":" .. uniqID, nil, embedded);
		TT_LineQuality(quality);
	end

	local itemInfo = nil;

	-- show item info
	if (itemID > 0) then
		frame.eDone = 1;
		local auctionPriceItem = Auctioneer_GetAuctionPriceItem(itemKey, auctKey);
		local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = Auctioneer_GetAuctionPrices(auctionPriceItem.data);

		itemInfo = Auctioneer_GetItemData(itemKey);

		-- show auction info
		if (aCount == 0) then
			-- OUTPUT: "Never seen at auction"
			TT_AddLine(string.format(AUCT_FRMT_INFO_NEVER, AUCT_TEXT_AUCTION), nil, embedded);
			TT_LineColor(0.5, 0.8, 0.5);
		else -- (aCount > 0)
			-- calculate auction values
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

			local median, medCount = Auctioneer_GetUsableMedian(itemKey, auctKey);

			if (Auctioneer_GetFilter(AUCT_SHOW_AVERAGE)) then -- show item's average auction price
				-- OUTPUT: "Seen [aCount] times at auction total"
				TT_AddLine(string.format(AUCT_FRMT_INFO_SEEN, aCount), nil, embedded);
				TT_LineColor(0.5,0.8,0.1);
				if (not Auctioneer_GetFilter(AUCT_SHOW_VERBOSE)) then -- default mode
					if (avgQty > 1) then
						-- OUTPUT: "For 1: [avgMin] min/[avgBuy] BO ([avgBid] bid) [in [avgQty]'s]"
						TT_AddLine(string.format(AUCT_FRMT_INFO_FORONE, TT_GetTextGSC(avgMin), TT_GetTextGSC(avgBuy), TT_GetTextGSC(avgBid), avgQty), nil, embedded);
						TT_LineColor(0.1,0.8,0.5);
					else -- (avgQty = 1)
						-- OUTPUT: "[avgMin] min/[avgBuy] BO ([avgBid] bid)"
						TT_AddLine(string.format(AUCT_FRMT_INFO_AVERAGE, TT_GetTextGSC(avgMin), TT_GetTextGSC(avgBuy), TT_GetTextGSC(avgBid)), nil, embedded);
						TT_LineColor(0.1,0.8,0.5);
					end
				else -- verbose mode
					if (count > 1) then
						-- OUTPUT: "Averages for [count] items:"
						TT_AddLine(string.format(AUCT_FRMT_INFO_HEAD_MULTI, count), nil, embedded);
						TT_LineColor(0.4,0.5,1.0);
						-- OUTPUT: "  Minimum ([avgMin] ea)"
						TT_AddLine(string.format(AUCT_FRMT_INFO_MIN_MULTI, TT_GetTextGSC(avgMin)), avgMin*count, embedded);
						TT_LineColor(0.4,0.5,0.8);
						if (Auctioneer_GetFilter(AUCT_SHOW_STATS)) then -- show buyout/bidded percentages
							-- OUTPUT: "  Bidded ([bidPct]%, [avgBid] ea)"
							TT_AddLine(string.format(AUCT_FRMT_INFO_BID_MULTI, bidPct.."%, ", TT_GetTextGSC(avgBid)), avgBid*count, embedded);
							TT_LineColor(0.4,0.5,0.85);
							-- OUTPUT: "  Buyout ([buyPct]%, [avgBuy] ea)"
							TT_AddLine(string.format(AUCT_FRMT_INFO_BUY_MULTI, buyPct.."%, ", TT_GetTextGSC(avgBuy)), avgBuy*count, embedded);
							TT_LineColor(0.4,0.5,0.9);
						else -- don't show buyout/bidded percentages
							-- OUTPUT: "  Bidded ([avgBid] ea)"
							TT_AddLine(string.format(AUCT_FRMT_INFO_BID_MULTI, "", TT_GetTextGSC(avgBid)), avgBid*count, embedded);
							TT_LineColor(0.4,0.5,0.85);
							-- OUTPUT: "  Buyout ([avgBuy] ea)"
							TT_AddLine(string.format(AUCT_FRMT_INFO_BUY_MULTI, "", TT_GetTextGSC(avgBuy)), avgBuy*count, embedded);
							TT_LineColor(0.4,0.5,0.9);
						end
						if (median) then
							-- OUTPUT: "  Buyout median"
							TT_AddLine(AUCT_FRMT_INFO_BUYMEDIAN, median * count, embedded);
							TT_LineColor(0.4,0.5,0.95);
						end
					else -- (count = 0 | 1)
					   -- OUTPUT: "Averages for this item:"
						TT_AddLine(AUCT_FRMT_INFO_HEAD_ONE, nil, embedded);
						TT_LineColor(0.4,0.5,1.0);
						-- OUTPUT: "  Minimum bid"
						TT_AddLine(AUCT_FRMT_INFO_MIN_ONE, avgMin, embedded);
						TT_LineColor(0.4,0.5,0.8);
						if (Auctioneer_GetFilter(AUCT_SHOW_STATS)) then -- show buyout/bidded percentages
							-- OUTPUT: "  Bidded [bidPct]%"
							TT_AddLine(string.format(AUCT_FRMT_INFO_BID_ONE, " "..bidPct.."%"), avgBid, embedded);
							TT_LineColor(0.4,0.5,0.85);
							-- OUTPUT: "  Buyout [buyPct]%"
							TT_AddLine(string.format(AUCT_FRMT_INFO_BUY_ONE, " "..buyPct.."%"), avgBuy, embedded);
							TT_LineColor(0.4,0.5,0.9);
						else -- don't show buyout/bidded percentages
						   -- OUTPUT: "  Bidded [bidPct]%"
							TT_AddLine(string.format(AUCT_FRMT_INFO_BID_ONE, ""), avgBid, embedded);
							TT_LineColor(0.4,0.5,0.85);
							-- OUTPUT: "  Buyout [buyPct]%"
							TT_AddLine(string.format(AUCT_FRMT_INFO_BUY_ONE, ""), avgBuy, embedded);
							TT_LineColor(0.4,0.5,0.9);
						end
						if (median) then
							-- OUTPUT: "  Buyout median"
							TT_AddLine(AUCT_FRMT_INFO_BUYMEDIAN, median, embedded);
							TT_LineColor(0.4,0.5,0.95);
						end
					end
					if (avgQty > 1) then
						-- OUTPUT: "  Average stack size: [avgQty] items"
						TT_AddLine(string.format(AUCT_FRMT_INFO_STACKSIZE, avgQty), nil, embedded);
						TT_LineColor(0.4,0.5,1.0);
					end
				end

				if median and Auctioneer_GetFilter(AUCT_SHOW_MEDIAN) then -- show item's median buyout price
					local historicalMedian, historicalMedCount = Auctioneer_GetItemHistoricalMedianBuyout(itemKey, auctKey);
					local snapshotMedian, snapshotMedCount = Auctioneer_GetItemSnapshotMedianBuyout(itemKey, auctKey);
					if historicalMedian and historicalMedCount > nullSafe(snapshotMedCount)  then
						-- OUTPUT: "Last [historicalMedCount], median BO (ea)"
						TT_AddLine(string.format(AUCT_FRMT_INFO_HISTMED, historicalMedCount), historicalMedian, embedded)
						TT_LineColor(0.1,0.8,0.5);
					end
					if snapshotMedian then
						-- OUTPUT: "Scanned [snapshotMedCount], median BO (ea)"
						TT_AddLine(string.format(AUCT_FRMT_INFO_SNAPMED, snapshotMedCount), snapshotMedian, embedded)
						TT_LineColor(0.1,0.8,0.5);
					end
				end
			end -- if(Auctioneer_GetFilter(AUCT_SHOW_AVERAGE)) - show item's average auction price

			-- seperate line for suggested auction price (for clarification, even if the values have already been shown somewhere else
			if (Auctioneer_GetFilter(AUCT_SHOW_SUGGEST)) then -- show item's suggested auction price
				local hsp = Auctioneer_GetHSP(itemKey, auctKey);
				if hsp == 0 and buyCount > 0 then
					hsp = math.floor(buyPrice / buyCount); -- use mean buyout if median not available
				end
				local discountBidPercent = tonumber(Auctioneer_GetFilterVal(AUCT_CMD_PCT_BIDMARKDOWN, AUCT_OPT_PCT_BIDMARKDOWN_DEFAULT));
				local countFix = count
				if countFix == 0 then
					countFix = 1
				end
				local buyPrice = Auctioneer_RoundDownTo95(nullSafe(hsp) * countFix);
				local bidPrice = Auctioneer_RoundDownTo95(Auctioneer_SubtractPercent(buyPrice, discountBidPercent));
				if (count > 1) then
					-- OUTPUT: "Suggested price for your [count] stack: [bidPrice] min/[buyPrice] BO"
					TT_AddLine(string.format(AUCT_FRMT_INFO_SGSTSTX, count, TT_GetTextGSC(bidPrice, true), TT_GetTextGSC(buyPrice, true)), nil, embedded);
					TT_LineColor(0.5,0.5,0.8);
				else -- count = 0 | 1
					-- OUTPUT: "Suggested price: [bidPrice] min/[buyPrice] BO"
					TT_AddLine(string.format(AUCT_FRMT_INFO_SGST, TT_GetTextGSC(bidPrice, true), TT_GetTextGSC(buyPrice, true)), nil, embedded);
					TT_LineColor(0.5,0.5,0.8);
				end
			end
			if (not Auctioneer_GetFilter(AUCT_SHOW_VERBOSE)) then
				if (Auctioneer_GetFilter(AUCT_SHOW_STATS)) then -- show buyout/bidded percentages
					-- OUTPUT: "[bidPct]% have bid, [buyPct]% have BO"
					TT_AddLine(string.format(AUCT_FRMT_INFO_BIDRATE, bidPct, buyPct), nil, embedded);
					TT_LineColor(0.1,0.5,0.8);
				end
			end
		end -- (aCount > 0)

		local also = Auctioneer_GetFilterVal("also");
		if (Auctioneer_IsValidAlso(also)) and (also ~= "off") then
			if (also == "opposite") then
				also = oppositeKey();
			end
			local auctionPriceItem = Auctioneer_GetAuctionPriceItem(itemKey, also);
			local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = Auctioneer_GetAuctionPrices(auctionPriceItem.data);
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
				TT_AddLine(string.format(">> "..AUCT_FRMT_INFO_NEVER, also), nil, embedded);
				TT_LineColor(0.5,0.8,0.1);
			else
				if (Auctioneer_GetFilter(AUCT_SHOW_AVERAGE)) then
					TT_AddLine(string.format(">> "..AUCT_FRMT_INFO_ALSOSEEN, aCount, also), nil, embedded);
					TT_LineColor(0.5,0.8,0.1);
					if (avgQty > 1) then
						TT_AddLine(string.format(">> "..AUCT_FRMT_INFO_FORONE, TT_GetTextGSC(avgMin), TT_GetTextGSC(avgBuy), TT_GetTextGSC(avgBid), avgQty), nil, embedded);
						TT_LineColor(0.1,0.8,0.5);
					else
						TT_AddLine(string.format(">> "..AUCT_FRMT_INFO_AVERAGE, TT_GetTextGSC(avgMin), TT_GetTextGSC(avgBuy), TT_GetTextGSC(avgBid)), nil, embedded);
						TT_LineColor(0.1,0.8,0.5);
					end
					if (Auctioneer_GetFilter(AUCT_SHOW_SUGGEST)) then
						local hsp = Auctioneer_GetHSP(itemKey, also);
						if hsp == 0 and buyCount > 0 then
							hsp = math.floor(buyPrice / buyCount); -- use mean buyout if median not available
						end
						local discountBidPercent = tonumber(Auctioneer_GetFilterVal(AUCT_CMD_PCT_BIDMARKDOWN, AUCT_OPT_PCT_BIDMARKDOWN_DEFAULT));
						local countFix = count
						if countFix == 0 then
							countFix = 1
						end
						local buyPrice = roundDownTo95(nullSafe(hsp) * countFix);
						local bidPrice = roundDownTo95(subtractPercent(buyPrice, discountBidPercent));
						if (count > 1) then
							-- OUTPUT: "Suggested price for your [count] stack: [bidPrice] min/[buyPrice] BO"
							TT_AddLine(string.format(">> "..AUCT_FRMT_INFO_SGSTSTX, count, TT_GetTextGSC(bidPrice, true), TT_GetTextGSC(buyPrice, true)), nil, embedded);
							TT_LineColor(0.5,0.5,0.8);
						else -- count = 0 | 1
							-- OUTPUT: "Suggested price: [bidPrice] min/[buyPrice] BO"
							TT_AddLine(string.format(">> "..AUCT_FRMT_INFO_SGST, TT_GetTextGSC(bidPrice, true), TT_GetTextGSC(buyPrice, true)), nil, embedded);
							TT_LineColor(0.5,0.5,0.8);
						end
					end
				end
				if (Auctioneer_GetFilter(AUCT_SHOW_STATS)) then
					TT_AddLine(string.format(">> "..AUCT_FRMT_INFO_BIDRATE, bidPct, buyPct), nil, embedded);
					TT_LineColor(0.1,0.5,0.8);
				end
			end
		end
	end -- if (itemID > 0)
	local sellNote = "";
	local buyNote = "";
	local sell = 0;
	local buy = 0;
	local stacks = 1;
	if (itemInfo) then
		stacks = itemInfo.stack;
		if (not stacks) then stacks = 1; end

		buy = nullSafe(itemInfo.buy);
		sell = nullSafe(itemInfo.sell);

		quant = stacks;
		if (sell > 0) then
			local ratio = buy / sell;
			if ((ratio > 3) and (ratio < 6)) then
				quant = 1;
			else
				ratio = buy / (sell * 5);
				if ((ratio > 3) and (ratio < 6)) then
					quant = 5;
				end
			end
		end

		buy = buy/quant;
	end

	if (Auctioneer_GetFilter(AUCT_SHOW_VENDOR)) then
		if ((buy > 0) or (sell > 0)) then
			local bgsc = TT_GetTextGSC(buy);
			local sgsc = TT_GetTextGSC(sell);

			if (count and (count > 1)) then
				local bqgsc = TT_GetTextGSC(buy*count);
				local sqgsc = TT_GetTextGSC(sell*count);
				if (Auctioneer_GetFilter(AUCT_SHOW_VENDOR_BUY)) then
					TT_AddLine(string.format(AUCT_FRMT_INFO_BUYMULT, buyNote, count, bgsc), buy*count, embedded);
					TT_LineColor(0.8, 0.5, 0.1);
				end
				if (Auctioneer_GetFilter(AUCT_SHOW_VENDOR_SELL)) then
					TT_AddLine(string.format(AUCT_FRMT_INFO_SELLMULT, sellNote, count, sgsc), sell*count, embedded);
					TT_LineColor(0.8, 0.5, 0.1);
				end
			else
				if (Auctioneer_GetFilter(AUCT_SHOW_VENDOR_BUY)) then
					TT_AddLine(string.format(AUCT_FRMT_INFO_BUY, buyNote), buy, embedded);
					TT_LineColor(0.8, 0.5, 0.1);
				end
				if (Auctioneer_GetFilter(AUCT_SHOW_VENDOR_SELL)) then
					TT_AddLine(string.format(AUCT_FRMT_INFO_SELL, sellNote), sell, embedded);
					TT_LineColor(0.8, 0.5, 0.1);
				end
			end
		end
	end

	if (Auctioneer_GetFilter(AUCT_SHOW_STACK)) then
		if (stacks > 1) then
			TT_AddLine(string.format(AUCT_FRMT_INFO_STX, stacks), nil, embedded);
		end
	end
	if (itemInfo and Auctioneer_GetFilter(AUCT_SHOW_USAGE)) then
		local reagentInfo = "";
		if (itemInfo.classText) then
			reagentInfo = string.format(AUCT_FRMT_INFO_CLASS, itemInfo.classText);
			TT_AddLine(reagentInfo, nil, embedded);
			TT_LineColor(0.6, 0.4, 0.8);
		end
		if (itemInfo.usageText) then
			reagentInfo = string.format(AUCT_FRMT_INFO_USE, itemInfo.usageText);
			TT_AddLine(reagentInfo, nil, embedded);
			TT_LineColor(0.6, 0.4, 0.8);
		end
	end
end

function Auctioneer_Tooltip_Hook(frame, name, count, data)
	Auctioneer_Old_Tooltip_Hook(frame, name, count, data);
end

function Auctioneer_AddTooltipInfo(frame, name, count, data)
end

-- hook to capture data about an auction that was boughtout
function Auctioneer_PlaceAuctionBid(itemtype, itemindex, bidamount)
	-- get the info for this auction
	local aiLink = GetAuctionItemLink(AuctionFrame.type, GetSelectedAuctionItem(AuctionFrame.type));
	local aiItemID, aiRandomProp, aiEnchant, aiUniqID = TT_BreakLink(aiLink);
	local aiKey = aiItemID..":"..aiRandomProp..":"..aiEnchant;
	local aiName, aiTexture, aiCount, aiQuality, aiCanUse, aiLevel, aiMinBid, aiMinIncrement,
		aiBuyout, aiBidAmount, aiHighBidder, aiOwner =
		GetAuctionItemInfo(AuctionFrame.type, GetSelectedAuctionItem(AuctionFrame.type));

	local auctionSignature = string.format("%d:%d:%d:%s:%d:%d:%d:%d", aiItemID, aiRandomProp, aiEnchant, nilSafeString(aiName), nullSafe(aiCount), nullSafe(aiMinBid), nullSafe(aiBuyout), aiUniqID);

	local playerName = UnitName("player");
	local eventTime = "e"..time();
	if (not AuctionConfig.bids[playerName]) then
		AuctionConfig.bids[playerName] = {};
	end
	AuctionConfig.bids[playerName][eventTime] = {
		signature = auctionSignature,
		bidAmount = bidamount,
		itemOwner = aiOwner,
		prevBidder = aiHighBidder,
		itemWon = false;
	}

	if bidamount == aiBuyout then -- only capture buyouts
		-- remove from snapshot
		Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_REMOVE, auctionSignature));
		local auctKey = Auctioneer_GetAuctionKey();
		local itemCat = Auctioneer_GetCatForKey(aiKey);
		AuctionConfig.snap[auctKey][itemCat][auctionSignature] = nil;
		AuctionConfig.bids[playerName][eventTime].itemWon = true;
		Auctioneer_HSPCache[auctKey][aiKey] = nil;
		if (Auctioneer_Lowests) then Auctioneer_Lowests = nil; end
		--Auctioneer_GetHSP(aiKey, auctKey);
	end

	Auctioneer_Old_BidHandler(itemtype,itemindex,bidamount);
end

function Auctioneer_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED"); -- get called when our vars have loaded
end

function Auctioneer_LockAndLoad()
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
	Auctioneer_OldPopup = TT_ItemPopup;
	TT_ItemPopup = Auctioneer_ItemPopup;

	-- Hook PlaceAuctionBid
	Auctioneer_Old_BidHandler = PlaceAuctionBid;
	PlaceAuctionBid = Auctioneer_PlaceAuctionBid;

	-- Hook in the FilterButton_SetType
	Auctioneer_Old_FilterButton_SetType = FilterButton_SetType;
	FilterButton_SetType = Auctioneer_FilterButton_SetType;

	SLASH_AUCTIONEER1 = "/auctioneer";
	SLASH_AUCTIONEER2 = "/auction";
	SLASH_AUCTIONEER3 = "/auc";
	SlashCmdList["AUCTIONEER"] = function(msg)
		Auctioneer_Command(msg, nil);
	end

	if ( DEFAULT_CHAT_FRAME ) then 
		DEFAULT_CHAT_FRAME:AddMessage(string.format(AUCT_FRMT_WELCOME, AUCTIONEER_VERSION), 0.8, 0.8, 0.2);
	end

	-- Rearranges elements in the AH window.
	Auctioneer_ConfigureAH();
end

function Auctioneer_LoadCategories()
	if (not AuctionConfig.classes) then AuctionConfig.classes = {} end
	Auctioneer_LoadCategoryClasses(GetAuctionItemClasses());
end

function Auctioneer_LoadCategoryClasses(...)
	for c=1, arg.n, 1 do
		AuctionConfig.classes[c] = {};
		AuctionConfig.classes[c].name = arg[c];
		Auctioneer_LoadCategorySubClasses(c, GetAuctionItemSubClasses(c));
	end
end

function Auctioneer_LoadCategorySubClasses(c, ...)
	for s=1, arg.n, 1 do
		AuctionConfig.classes[c][s] = arg[s];
	end
end

function Auctioneer_FindClass(cName, sName)
	if (AuctionConfig and AuctionConfig.classes) then 
		for class, cData in pairs(AuctionConfig.classes) do
			if (cData.name == cName) then
				if (sName == nil) then return class, 0; end
				for sClass, sData in pairs(cData) do
					if (sClass ~= "name") and (sData == sName) then
						return class, sClass;
					end
				end
				return class, 0;
			end
		end
	end
	return 0,0;
end


function Auctioneer_Register()
	if (Khaos) then
		if (not Auctioneer_Khaos_Registered) then
			Auctioneer_GUI_Registered = Auctioneer_Register_Khaos();
		end
	end
	-- The following check is to accomodate other GUI libraries other than Khaos relatively easily.
	if (Auctioneer_GUI_Registered == true) then
		return true;
	else 
		return false;
	end
end

function Auctioneer_GetCatName(number)
	if (number == 0) then return "" end;
	if (AuctionConfig.classes[number]) then
		return AuctionConfig.classes[number].name;
	end
	return nil;
end

function Auctioneer_GetCatNumberByName(name)
	if (not name) then return 0 end
	if (AuctionConfig and AuctionConfig.classes) then 
		for cat, class in pairs(AuctionConfig.classes) do
			if (name == class.name) then
				return cat;
			end
		end
	end
	return 0;
end

function Auctioneer_GetCatForKey(itemKey)
	local info = Auctioneer_GetInfo(itemKey);
	return info.category;
end

function Auctioneer_GetKeyFromSig(auctSig)
	local id, rprop, enchant = Auctioneer_GetItemSignature(auctSig);
	return id..":"..rprop..":"..enchant;
end

function Auctioneer_GetCatForSig(auctSig)
	local itemKey = Auctioneer_GetKeyFromSig(auctSig);
	return Auctioneer_GetCatForKey(itemKey);
end

function Auctioneer_GetInfo(itemKey)
	if (not AuctionConfig.info[itemKey]) then return {}; end
	local info = AuctionConfig.info[itemKey];
	local infosplit = Auctioneer_Split(info, "|");
	local cat = tonumber(infosplit[1]);
	local name = infosplit[2];
	return {
		category = cat,
		name = name,
	};
end

function Auctioneer_GetSnapshot(auctKey, catID, auctSig)
	if (not catID) then catID = 0 end

	if (not AuctionConfig.snap[auctKey]) then
		AuctionConfig.snap[auctKey] = {};
	end
	if (not AuctionConfig.snap[auctKey][catID]) then
		AuctionConfig.snap[auctKey][catID] = {};
	end
	if (not AuctionConfig.snap[auctKey][catID][auctSig]) then
		return nil;
	end

	local snap = AuctionConfig.snap[auctKey][catID][auctSig];
	return Auctioneer_GetSnapshotFromData(snap);
end

function Auctioneer_GetSnapshotFromData(snap)
	if (not snap) then return nil end

	for dirty,bid,level,quality,left,fseen,last,link,owner in string.gfind(snap, "(%d+);(%d+);(%d+);(%d+);(%d+);(%d+);(%d+);([^;]+);(.+)") do
		return {
			bidamount = bid,
			owner = owner,
			dirty = dirty,
			lastSeenTime = last,
			itemLink = link,
			category = cat,
			initialSeenTime = fseen,
			level = level,
			timeLeft = left,
			quality = quality,
		};
	end
	return nil;
end

function Auctioneer_GetSnapshotInfo(auctKey, itemKey)
	if (not AuctionConfig.sbuy) then AuctionConfig.sbuy = {}; end
	if (not AuctionConfig.sbuy[auctKey]) then AuctionConfig.sbuy[auctKey] = {}; end
	if (not AuctionConfig.sbuy[auctKey][itemKey]) then return nil; end

	local buy = AuctionConfig.sbuy[auctKey][itemKey];
	return Auctioneer_GetSnapshotInfoFromData(buy);
end

function Auctioneer_GetSnapshotInfoFromData(buy)
	local buysplit = Auctioneer_Split(buy, ":");
	return {
		buyoutPrices = buysplit,
	};
end

function Auctioneer_SaveSnapshot(server, cat, sig, iData)
	local bid = iData.bidamount;
	local owner = iData.owner;
	local dirty = iData.dirty;
	local last = iData.lastSeenTime;
	local link = iData.itemLink;
	local fseen = iData.initialSeenTime;
	local level = iData.level;
	local left = iData.timeLeft;
	local qual = iData.quality;

	if (not cat) then cat = 0 end

	if (not AuctionConfig.snap[server]) then
		AuctionConfig.snap[server] = {};
	end
	if (not AuctionConfig.snap[server][cat]) then
		AuctionConfig.snap[server][cat] = {};
	end
	if (dirty~=nil and bid~=nil and level~=nil and qual~=nil and left~=nil and fseen~=nil and last~=nil and link~=nil and owner~=nil) then 
		local saveData = string.format("%d;%d;%d;%d;%d;%d;%d;%s;%s", dirty, bid, level, qual, left, fseen, last, link, owner); 
--		p("Saving", server, cat, sig, "as", saveData); 
		AuctionConfig.snap[server][cat][sig] = saveData;
		local itemKey = Auctioneer_GetKeyFromSig(sig);
		if(Auctioneer_HSPCache) and (Auctioneer_HSPCache[server]) then
			Auctioneer_HSPCache[server][itemKey] = nil;
		end
		if (Auctioneer_Lowests) then Auctioneer_Lowests = nil; end
		--Auctioneer_GetHSP(itemKey, server);
--	else
--		p("Not saving", server, cat, sig, "because", dirty, bid, level, qual, left, fseen, last, link, owner); 
	end
end

function Auctioneer_SaveSnapshotInfo(server, itemKey, iData)
	local hist = "";
	if (iData and iData.buyoutPrices) then
		for pos, hPrice in pairs(iData.buyoutPrices) do
			if (hist == "") then hist = string.format("%d", hPrice);
			else hist = string.format("%s:%d", hist, hPrice); end
		end
	end
	AuctionConfig.sbuy[server][itemKey] = hist;
	if (Auctioneer_HSPCache and Auctioneer_HSPCache[server]) then
		Auctioneer_HSPCache[server][itemKey] = nil;
	end
	if (Auctioneer_Lowests) then Auctioneer_Lowests = nil; end
	--Auctioneer_GetHSP(itemKey, server);
	local median, seenCount = Auctioneer_GetMedian(iData.buyoutPrices);
	local low, second = Auctioneer_GetLowest(iData.buyoutPrices);

	if (not AuctionConfig.stats) then AuctionConfig.stats = {} end
	if (not AuctionConfig.stats.snapmed) then AuctionConfig.stats.snapmed = {} end
	if (not AuctionConfig.stats.snapmed[server]) then AuctionConfig.stats.snapmed[server] = {} end
	if (not AuctionConfig.stats.snapcount) then AuctionConfig.stats.snapcount = {} end
	if (not AuctionConfig.stats.snapcount[server]) then AuctionConfig.stats.snapcount[server] = {} end
	AuctionConfig.stats.snapmed[server][itemKey] = median;
	AuctionConfig.stats.snapcount[server][itemKey] = seenCount;
end

function Auctioneer_Convert()
	if (not AuctionConfig.version) then AuctionConfig.version = 30000; end
	if (AuctionConfig.version < 30200) then
		AuctionConfig.data = {};
		AuctionConfig.info = {};
		AuctionConfig.snap = {};
		AuctionConfig.sbuy = {};
		if (AHSnapshot) then
			for server, sData in pairs(AHSnapshot) do
				local colon = string.find(server, ":");
				local hyphen = string.find(server, "-");
				if (hyphen and not colon) then
					if (not AuctionConfig.snap[server]) then
						AuctionConfig.snap[server] = {};
					end
					for sig, iData in pairs(sData) do
						local catName = Auctioneer_GetCatName(tonumber(iData.category));
						if (not catName) then iData.category = Auctioneer_GetCatNumberByName(iData.category) end 
						local cat = iData.category;
						Auctioneer_SaveSnapshot(server, cat, sig, iData);
					end
				end
			end
		end
		
		if (AHSnapshotItemPrices) then
			for server, sData in pairs(AHSnapshotItemPrices) do
				local colon = string.find(server, ":");
				local hyphen = string.find(server, "-");
				if (hyphen and not colon) then
					if (not AuctionConfig.sbuy[server]) then
						AuctionConfig.sbuy[server] = {};
					end
					for itemKey, iData in pairs(sData) do
						Auctioneer_SaveSnapshotInfo(server, itemKey, iData);
					end
				end
			end
		end

		if (AuctionPrices) then
			for server, sData in pairs(AuctionPrices) do
				local colon = string.find(server, ":");
				local hyphen = string.find(server, "-");
				if (hyphen and not colon) then
					AuctionConfig.data[server] = {};
					for sig, iData in pairs(sData) do
						local catName = Auctioneer_GetCatName(tonumber(iData.category));
						if (not catName) then iData.category = Auctioneer_GetCatNumberByName(iData.category) end 
						local cat = iData.category;
						local data = iData.data;
						local hist = "";
						local name = iData.name;
						if (iData.buyoutPricesHistoryList) then
							for pos, hPrice in pairs(iData.buyoutPricesHistoryList) do
								if (hist == "") then hist = string.format("%d", hPrice);
								else hist = string.format("%s:%d", hist, hPrice); end
							end
						end
						if (name) then
							local newData = string.format("%s|%s", data, hist);
							local newInfo = string.format("%s|%s", cat, iData.name);
							AuctionConfig.data[server][sig] = newData;
							AuctionConfig.info[sig] = newInfo;
						end
					end
				end
			end
		end
		
		AuctionConfig.bids = {};
		if (AuctionBids) then
			for player, pData in pairs(AuctionBids) do
				AuctionConfig.bids[player] = {};
				for time, bData in pairs(pData) do
					local amount = bData.bidAmount;
					local sig = bData.signature;
					local owner = bData.itemOwner;
					local won = bData.itemWon;
					if (won) then won = "1"; else won = "0"; end

					local newBid = string.format("%s|%s|%s|%s", sig, amount, won, owner);
					AuctionConfig.bids[player][time] = newBid;
				end
			end
		end
	end

	-- Now the conversion is complete, wipe out the old data
	AHSnapshot = nil;
	AHSnapshotItemPrices = nil;
	AuctionPrices = nil;
	AuctionBids = nil;
	AuctionConfig.version = 30200;
end


function Auctioneer_Register_Khaos()
	
	
	local optionSet = {
		id="Auctioneer";
		text="Auctioneer";
		helptext=AUCTIONEER_GUI_MAIN_HELP;
		difficulty=1;
		default={checked=true};
		options={
			{
				id="Header";
				text="Auctioneer";
				helptext=AUCTIONEER_GUI_MAIN_HELP;
				type=K_HEADER;
				difficulty=1;
			};
			{
				id="AuctioneerEnable";
				type=K_TEXT;
				text=AUCTIONEER_GUI_MAIN_ENABLE;
				helptext=AUCT_HELP_ONOFF;
				callback=function(state) if (state.checked) then Auctioneer_Command(AUCT_CMD_ON, "GUI") else Auctioneer_Command(AUCT_CMD_OFF, "GUI") end end;
				feedback=function(state) if (state.checked) then return AUCT_STAT_ON else return AUCT_STAT_OFF end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				difficulty=1;
			};
			{
				id="AuctioneerLocale";
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=AUCTIONEER_GUI_LOCALE;
				helptext=AUCT_HELP_LOCALE;
				callback = function(state)
					Auctioneer_Command(AUCT_CMD_LOCALE.." "..state.value, "GUI");
				end;
				feedback = function (state)
					return string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_LOCALE, state.value);
				end;
				default = {
					value = Auctioneer_GetLocale();
				};
				disabled = {
					value = Auctioneer_GetLocale();
				};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=2;				
			};
			{
				id="ReloadUI";
				type=K_BUTTON;
				setup={
					buttonText = AUCTIONEER_GUI_RELOADUI_BUTTON;
				};
				text=AUCTIONEER_GUI_RELOADUI;
				helptext=AUCTIONEER_GUI_RELOADUI_HELP;
				callback=function() ReloadUI() end;
				feedback=AUCTIONEER_GUI_RELOADUI_FEEDBACK;
				difficulty=3;
			};
			{
				id=AUCT_SHOW_VERBOSE;
				type=K_TEXT;
				text=AUCTIONEER_GUI_VERBOSE;
				helptext=AUCT_HELP_VERBOSE;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_VERBOSE.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_VERBOSE.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_VERBOSE)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_VERBOSE)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=1;
			};
			{
				id="AuctioneerStatsHeader";
				type=K_HEADER;
				text=AUCTIONEER_GUI_STATS_HEADER;
				helptext=AUCTIONEER_GUI_STATS_HELP;
				difficulty=2;
			};
			{
				id=AUCT_SHOW_STATS;
				type=K_TEXT;
				text=AUCTIONEER_GUI_STATS_ENABLE;
				helptext=AUCT_HELP_STATS;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_STATS.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_STATS.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_STATS)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_STATS)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=1;
			};
			{
				id=AUCT_SHOW_AVERAGE;
				type=K_TEXT;
				text=AUCTIONEER_GUI_AVERAGES;
				helptext=AUCT_HELP_AVERAGE;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_AVERAGE.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_AVERAGE.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_AVERAGE)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_AVERAGE)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=2;
			};
			{
				id=AUCT_SHOW_MEDIAN;
				type=K_TEXT;
				text=AUCTIONEER_GUI_MEDIAN;
				helptext=AUCT_HELP_MEDIAN;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_MEDIAN.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_MEDIAN.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_MEDIAN)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_MEDIAN)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=2;
			};
			{
				id=AUCT_SHOW_SUGGEST;
				type=K_TEXT;
				text=AUCTIONEER_GUI_SUGGEST;
				helptext=AUCT_HELP_SUGGEST;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_SUGGEST.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_SUGGEST.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_SUGGEST)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_SUGGEST)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=2;
			};
			{
				id="AuctioneerVendorHeader";
				type=K_HEADER;
				text=AUCTIONEER_GUI_VENDOR_HEADER;
				helptext=AUCTIONEER_GUI_VENDOR_HELP;
				difficulty=1;
			};
			{
				id=AUCT_SHOW_VENDOR;
				key="AuctioneerVendor";
				type=K_TEXT;
				text=AUCTIONEER_GUI_VENDOR;
				helptext=AUCT_HELP_VENDOR;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_VENDOR.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_VENDOR.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_VENDOR)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_VENDOR)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=1;
			};
			{
				id=AUCT_SHOW_VENDOR_BUY;
				type=K_TEXT;
				text=AUCTIONEER_GUI_VENDOR_BUY;
				helptext=AUCT_HELP_VENDOR_BUY;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_VENDOR_BUY.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_VENDOR_BUY.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_VENDOR_BUY)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_VENDOR_BUY)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerVendor={checked=true;}, AuctioneerEnable={checked=true;}};
				difficulty=2;
			};
			{
				id=AUCT_SHOW_VENDOR_SELL;
				type=K_TEXT;
				text=AUCTIONEER_GUI_VENDOR_SELL;
				helptext=AUCT_HELP_VENDOR_SELL;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_VENDOR_SELL.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_VENDOR_SELL.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_VENDOR_SELL)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_VENDOR_SELL)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerVendor={checked=true;}, AuctioneerEnable={checked=true;}};
				difficulty=2;
			};
			{
				id="AuctioneerEmbedHeader";
				type=K_HEADER;
				text=AUCTIONEER_GUI_EMBED_HEADER;
				helptext=AUCT_HELP_EMBED;
				difficulty=1;
			};
			{
				id=AUCT_CMD_EMBED;
				key="AuctioneerEmbed";
				type=K_TEXT;
				text=AUCTIONEER_GUI_EMBED;
				helptext=AUCT_HELP_EMBED;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_CMD_EMBED.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_CMD_EMBED.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_CMD_EMBED)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_CMD_EMBED)) end end;
				check=true;
				default={checked=false};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=1;
			};
			{
				id=AUCT_SHOW_EMBED_BLANK;
				type=K_TEXT;
				text=AUCTIONEER_GUI_EMBED_BLANKLINE;
				helptext=AUCT_HELP_EMBED_BLANK;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_EMBED_BLANK.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_EMBED_BLANK.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_EMBED_BLANK)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_EMBED_BLANK)) end end;
				check=true;
				default={checked=false};
				disabled={checked=false};
				dependencies={AuctioneerEmbed={checked=true;}, AuctioneerEnable={checked=true;}};
				difficulty=1;
			};
			{
				id="AuctioneerClearHeader";
				type=K_HEADER;
				text=AUCTIONEER_GUI_CLEAR_HEADER;
				helptext=AUCTIONEER_GUI_CLEAR_HELP;
				difficulty=3;
			};
			{
				id="AuctioneerClearAll";
				type=K_BUTTON;
				setup={
					buttonText = AUCTIONEER_GUI_CLEARALL_BUTTON;
				};
				text=AUCTIONEER_GUI_CLEARALL;
				helptext=AUCTIONEER_GUI_CLEARALL_HELP;
				callback=function() Auctioneer_Command(string.format(AUCT_CMD_CLEAR.." "..AUCT_CMD_CLEAR_ALL), "GUI") end;
				feedback=string.format(AUCT_FRMT_ACT_CLEARALL,  AUCTIONEER_GUI_CLEARALL_NOTE);
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=3;
			};
			{
				id="AuctioneerClearSnapshot";
				type=K_BUTTON;
				setup={
					buttonText=AUCTIONEER_GUI_CLEARSNAP_BUTTON;
				};
				text=AUCTIONEER_GUI_CLEARSNAP;
				helptext=AUCTIONEER_GUI_CLEARSNAP_HELP;
				callback=function() Auctioneer_Command(string.format(AUCT_CMD_CLEAR.." "..AUCT_CMD_CLEAR_SNAPSHOT), "GUI")end;
				feedback=AUCT_FRMT_ACT_CLEARSNAP;
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=3;
			};
			{
				id="AuctioneerPercentsHeader";
				type=K_HEADER;
				text=AUCTIONEER_GUI_PERCENTS_HEADER;
				helptext=AUCTIONEER_GUI_PERCENTS_HELP;
				difficulty=4;
			};
			{
				id=AUCT_CMD_PCT_BIDMARKDOWN;
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=AUCTIONEER_GUI_BIDMARKDOWN;
				helptext=AUCT_HELP_PCT_BIDMARKDOWN;
				callback = function(state)
					Auctioneer_Command(string.format(AUCT_CMD_PCT_BIDMARKDOWN.." "..state.value), "GUI");
				end;
				feedback = function (state)
					return string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_PCT_BIDMARKDOWN, state.value.."%");
				end;
				default = {
					value = AUCT_OPT_PCT_BIDMARKDOWN_DEFAULT;
				};
				disabled = {
					value = AUCT_OPT_PCT_BIDMARKDOWN_DEFAULT;
				};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=4;				
			};
			{
				id=AUCT_CMD_PCT_MARKUP;
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=AUCTIONEER_GUI_MARKUP;
				helptext=AUCT_HELP_PCT_MARKUP;
				callback = function(state)
					Auctioneer_Command(string.format(AUCT_CMD_PCT_MARKUP.." "..state.value), "GUI");
				end;
				feedback = function (state)
					return string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_PCT_MARKUP, state.value.."%");
				end;
				default = {
					value = AUCT_OPT_PCT_MARKUP_DEFAULT;
				};
				disabled = {
					value = AUCT_OPT_PCT_MARKUP_DEFAULT;
				};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=4;
			};
			{
				id=AUCT_CMD_PCT_MAXLESS;
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=AUCTIONEER_GUI_MAXLESS;
				helptext=AUCT_HELP_PCT_MAXLESS;
				callback = function(state)
					Auctioneer_Command(string.format(AUCT_CMD_PCT_MAXLESS.." "..state.value), "GUI");
				end;
				feedback = function (state)
					return string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_PCT_MAXLESS, state.value.."%");
				end;
				default = {
					value = AUCT_OPT_PCT_MAXLESS_DEFAULT;
				};
				disabled = {
					value = AUCT_OPT_PCT_MAXLESS_DEFAULT;
				};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=4;
			};
			{
				id=AUCT_CMD_PCT_NOCOMP;
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=AUCTIONEER_GUI_NOCOMP;
				helptext=AUCT_HELP_PCT_NOCOMP;
				callback = function(state)
					Auctioneer_Command(string.format(AUCT_CMD_PCT_NOCOMP.." "..state.value), "GUI");
				end;
				feedback = function (state)
					return string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_PCT_NOCOMP, state.value.."%");
				end;
				default = {
					value = AUCT_OPT_PCT_NOCOMP_DEFAULT;
				};
				disabled = {
					value = AUCT_OPT_PCT_NOCOMP_DEFAULT;
				};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=4;
			};
			{
				id=AUCT_CMD_PCT_UNDERLOW;
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=AUCTIONEER_GUI_UNDERLOW;
				helptext=AUCT_HELP_PCT_UNDERLOW;
				callback = function(state)
					Auctioneer_Command(string.format(AUCT_CMD_PCT_UNDERLOW.." "..state.value), "GUI");
				end;
				feedback = function (state)
					return string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_PCT_UNDERLOW, state.value.."%");
				end;
				default = {
					value = AUCT_OPT_PCT_UNDERLOW_DEFAULT;
				};
				disabled = {
					value = AUCT_OPT_PCT_UNDERLOW_DEFAULT;
				};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=4;
			};
			{
				id=AUCT_CMD_PCT_UNDERMKT;
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=AUCTIONEER_GUI_UNDERMKT;
				helptext=AUCT_HELP_PCT_UNDERMKT;
				callback = function(state)
					Auctioneer_Command(string.format(AUCT_CMD_PCT_UNDERMKT.." "..state.value), "GUI");
				end;
				feedback = function (state)
					return string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_PCT_UNDERMKT, state.value.."%");
				end;
				default = {
					value = AUCT_OPT_PCT_UNDERMKT_DEFAULT;
				};
				disabled = {
					value = AUCT_OPT_PCT_UNDERMKT_DEFAULT;
				};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=4;
			};
			{
				id="AuctioneerOtherHeader";
				type=K_HEADER;
				text=AUCTIONEER_GUI_OTHER_HEADER;
				helptext=AUCTIONEER_GUI_OTHER_HELP;
				difficulty=1;
			};
			{
				id=AUCT_CMD_AUTOFILL;
				type=K_TEXT;
				text=AUCTIONEER_GUI_AUTOFILL;
				helptext=AUCT_HELP_AUTOFILL;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_CMD_AUTOFILL.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_CMD_AUTOFILL.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_CMD_AUTOFILL)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_CMD_AUTOFILL)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=1;
			};
			{
				id="AuctioneerInclude";
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=AUCTIONEER_GUI_ALSO;
				helptext=AUCT_HELP_ALSO;
				callback = function(state)
					Auctioneer_Command(string.format(AUCT_CMD_ALSO.." "..state.value), "GUI");
				end;
				feedback = function (state)
					if (state.value == opposite) then
						return AUCTIONEER_GUI_ALSO_OPPOSITE;
					elseif (state.value == off) then
						return AUCTIONEER_GUI_ALSO_OFF;
					elseif (not Auctioneer_IsValidAlso(param)) then
						string.format(AUCT_FRMT_UNKNOWN_RF, state.value)
					else
						return string.format(AUCTIONEER_GUI_ALSO_DISPLAY, state.value);
					end
				end;
				default = {
					value = AUCT_CMD_OFF;
				};
				disabled = {
					value = AUCT_CMD_OFF;
				};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=2;
			};
			--Oops, not yet implemented :)
			--[[
			{
				id=AUCT_SHOW_HSP;
				type=K_TEXT;
				text="Show Highest Sellable Price (HSP)";
				helptext=AUCT_HELP_HSP;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_HSP.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_HSP.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_HSP)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_HSP)) end end;
				check=true;
				default={checked=false};
				disabled={checked=false};
				difficulty=3;
			};
			]]--
			{
				id=AUCT_SHOW_LINK;
				type=K_TEXT;
				text=AUCTIONEER_GUI_LINK;
				helptext=AUCT_HELP_LINK;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_LINK.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_LINK.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_LINK)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_LINK)) end end;
				check=true;
				default={checked=false};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=3;
			};
		};
	};

	Khaos.registerOptionSet("tooltip",optionSet);
	Auctioneer_Khaos_Registered = true;
	
	return true;
end

function Auctioneer_FindFilterClass(text)
	local totalFilters = getn(CLASS_FILTERS);
	for currentFilter=1, totalFilters do
		if (text == CLASS_FILTERS[currentFilter]) then
			return currentFilter, totalFilters;
		end
	end
	return 0, totalFilters;
end

function AuctFilter_SetFilter(checkbox, filter)
	checkbox.filterVal = filter;
	checkbox:SetChecked(Auctioneer_GetFilter(filter));
	checkbox:SetScale(0.5);
	checkbox:Show();
end

function Auctioneer_GetLocale()
	local locale = Auctioneer_GetFilterVal('locale');
	if (locale ~= 'on') and (locale ~= 'off') and (locale ~= 'default') then
		return locale;
	end
	return GetLocale();
end

function Auctioneer_FilterButton_SetType(button, type, text, isLast)
	Auctioneer_Old_FilterButton_SetType(button, type, text, isLast);

	local buttonName = button:GetName();
	local i,j, buttonID = string.find(buttonName, "(%d+)$");
	buttonID = tonumber(buttonID);

	local checkbox = getglobal(button:GetName().."Checkbox");
	if (type == "class") then
		local classid, maxid = Auctioneer_FindFilterClass(text);
		if (classid > 0) then
			AuctFilter_SetFilter(checkbox, "scan-class"..classid);
			if (classid == maxid) and (buttonID < 15) then
				for i=buttonID+1, 15 do
					getglobal("AuctionFilterButton"..i):Hide();
				end
			end
		else
			checkbox:Hide();
		end
	else
		checkbox:Hide();
	end
end

function Auctioneer_ConfigureAH()
	AuctionsPriceText:ClearAllPoints();
	AuctionsPriceText:SetPoint("TOPLEFT", "AuctionsItemText", "TOPLEFT", 0, -56);
	AuctionsBuyoutText:ClearAllPoints();
	AuctionsBuyoutText:SetPoint("TOPLEFT", "AuctionsPriceText", "TOPLEFT", 0, -36);
	AuctionsBuyoutErrorText:ClearAllPoints();
	AuctionsBuyoutErrorText:SetPoint("TOPLEFT", "AuctionsBuyoutText", "TOPLEFT", 0, -32);
	AuctionsDurationText:ClearAllPoints();
	AuctionsDurationText:SetPoint("TOPLEFT", "AuctionsBuyoutErrorText", "TOPLEFT", 0, -10);
	AuctionsDepositText:ClearAllPoints();
	AuctionsDepositText:SetPoint("TOPLEFT", "AuctionsDurationText", "TOPLEFT", 0, -34);
	if (AuctionInfo ~= nil) then
		AuctionInfo:ClearAllPoints();
		AuctionInfo:SetPoint("TOPLEFT", "AuctionsDepositText", "TOPLEFT", -4, -36);
	end

	AuctionsShortAuctionButtonText:SetText("2");
	AuctionsMediumAuctionButtonText:SetText("8");
	AuctionsMediumAuctionButton:ClearAllPoints();
	AuctionsMediumAuctionButton:SetPoint("BOTTOMLEFT", "AuctionsShortAuctionButton", "BOTTOMRIGHT", 20,0);
	AuctionsLongAuctionButtonText:SetText("24 "..HOURS);
	AuctionsLongAuctionButton:ClearAllPoints();
	AuctionsLongAuctionButton:SetPoint("BOTTOMLEFT", "AuctionsMediumAuctionButton", "BOTTOMRIGHT", 20,0);
	
	-- set UI-texts
	BrowseScanButton:SetText(AUCT_TEXT_SCAN);
end

--Cleaner Command Handling Functions (added by MentalPower)
function Auctioneer_Command(command, source)
	
	--To print or not to print, that is the question...
	local chatprint = nil;
	if (source == "GUI") then 
		chatprint = false;
	else 
		chatprint = true;
	end;
	
	--Divide the large command into smaller logical sections (Shameless copy from the original function)
	local i,j, cmd, param = string.find(command, "^([^ ]+) (.+)$");

	if (not cmd) then
		cmd = command;
	end

	if (not cmd) then
		cmd = "";
	end

	if (not param) then
		param = "";
	end

	--Now for the real Command handling
	if ((cmd == "") or (cmd == "help")) then
		Auctioneer_ChatPrint_Help();
		return;

	elseif (((cmd == AUCT_CMD_ON) or (cmd == "on")) or ((cmd == AUCT_CMD_OFF) or (cmd == "off")) or ((cmd == AUCT_CMD_TOGGLE) or (cmd == "toggle"))) then
		Auctioneer_OnOff(cmd, chatprint);

	elseif ((cmd == AUCT_CMD_CLEAR) or (cmd == "clear")) then
		Auctioneer_Clear(param, chatprint);

	elseif ((cmd == AUCT_CMD_ALSO) or (cmd == "also")) then
		Auctioneer_AlsoInclude(param, chatprint);
	
	elseif ((cmd == AUCT_CMD_LOCALE) or (cmd == "locale")) then
		Auctioneer_SetLocale(param, chatprint);

	elseif ((cmd == AUCT_CMD_DEFAULT) or (cmd == "default")) then
		Auctioneer_Default(param, chatprint);

	--The following are copied verbatim from the original function. These functions are not supported in the current Khaos-based GUI implementation and as such have been left intact.
	elseif ((cmd == AUCT_CMD_BROKER) or (cmd == "broker")) then
		Auctioneer_DoBroker(param);

	elseif ((cmd == AUCT_CMD_BIDBROKER) or (cmd == AUCT_CMD_BIDBROKER_SHORT)
		or (cmd == "bidbroker") or (cmd == "bb")) then
		Auctioneer_DoBidBroker(param);

	elseif ((cmd == AUCT_CMD_PERCENTLESS) or (cmd == AUCT_CMD_PERCENTLESS_SHORT)
		or (cmd == "percentless") or (cmd == "pl")) then
		Auctioneer_DoPercentLess(param);

	elseif ((cmd == AUCT_CMD_COMPETE) or (cmd == "compete")) then
		Auctioneer_DoCompeting(param);

	elseif ((cmd == AUCT_CMD_SCAN) or (cmd == "scan")) then
		Auctioneer_RequestAuctionScan();

	elseif (cmd == "low") then
		Auctioneer_DoLow(param);

	elseif (cmd == "med") then
		Auctioneer_DoMedian(param);

	elseif (cmd == "hsp") then
		Auctioneer_DoHSP(param);

	elseif (
		((cmd == AUCT_CMD_EMBED) or (cmd == "embed")) or
		((cmd == AUCT_CMD_AUTOFILL) or (cmd == "autofill")) or
		((cmd == AUCT_SHOW_VERBOSE) or (cmd == "show-verbose")) or
		((cmd == AUCT_SHOW_AVERAGE) or (cmd == "show-average")) or
		((cmd == AUCT_SHOW_LINK) or (cmd == "show-link")) or
		((cmd == AUCT_SHOW_MEDIAN) or (cmd == "show median")) or
		((cmd == AUCT_SHOW_STACK) or (cmd == "show-stack")) or
		((cmd == AUCT_SHOW_STATS) or (cmd == "show-stats")) or
		((cmd == AUCT_SHOW_SUGGEST) or (cmd == "show-suggest")) or
		((cmd == AUCT_SHOW_USAGE) or (cmd == "show-usage")) or
		((cmd == AUCT_SHOW_VENDOR) or (cmd == "show-vendor")) or
		((cmd == AUCT_SHOW_VENDOR_BUY) or (cmd == "show-vendor-buy")) or
		((cmd == AUCT_SHOW_VENDOR_SELL) or (cmd == "show-vendor-sell")) or		
		((cmd == AUCT_SHOW_EMBED_BLANK) or (cmd == "show-embed-blankline")) or
		((cmd == AUCT_SHOW_HSP) or (cmd == "show-hsp")) --This command has not yet been implemented.
	) then
		Auctioneer_GenVarSet(cmd, param, chatprint);

	elseif (
		((cmd == AUCT_CMD_PCT_BIDMARKDOWN) or(cmd == "pct-bidmarkdown")) or
		((cmd == AUCT_CMD_PCT_MARKUP) or(cmd == "pct-markup")) or
		((cmd == AUCT_CMD_PCT_MAXLESS) or(cmd == "pct-maxless")) or
		((cmd == AUCT_CMD_PCT_NOCOMP) or(cmd == "pct-nocomp")) or
		((cmd == AUCT_CMD_PCT_UNDERLOW) or(cmd == "pct-underlow")) or
		((cmd == AUCT_CMD_PCT_UNDERMKT) or (cmd == "pct-undermkt"))
	) then
		Auctioneer_PercentVarSet(cmd, param, chatprint);

	else
		if (chatprint == true) then
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_UNKNOWN, cmd));
		end
	end
end

--Help ME!! (The Handler) (Another shameless copy from the original function)
function Auctioneer_ChatPrint_Help()

	local onOffToggle = " ("..AUCT_CMD_ON.."|"..AUCT_CMD_OFF.."|"..AUCT_CMD_TOGGLE..")";
	local lineFormat = "  |cffffffff/auctioneer %s "..onOffToggle.."|r |cff2040ff[%s]|r - %s";

	Auctioneer_ChatPrint(AUCT_TEXT_USAGE);
	Auctioneer_ChatPrint("  |cffffffff/auctioneer "..onOffToggle.."|r |cff2040ff["..Auctioneer_GetFilterVal("all").."]|r - " .. AUCT_HELP_ONOFF);
	
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_VERBOSE, Auctioneer_GetFilterVal(AUCT_SHOW_VERBOSE), AUCT_HELP_VERBOSE));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_AVERAGE, Auctioneer_GetFilterVal(AUCT_SHOW_AVERAGE), AUCT_HELP_AVERAGE));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_MEDIAN, Auctioneer_GetFilterVal(AUCT_SHOW_MEDIAN), AUCT_HELP_MEDIAN));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_SUGGEST, Auctioneer_GetFilterVal(AUCT_SHOW_SUGGEST), AUCT_HELP_SUGGEST));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_STATS, Auctioneer_GetFilterVal(AUCT_SHOW_STATS), AUCT_HELP_STATS));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_VENDOR, Auctioneer_GetFilterVal(AUCT_SHOW_VENDOR), AUCT_HELP_VENDOR));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_VENDOR_SELL, Auctioneer_GetFilterVal(AUCT_SHOW_VENDOR_SELL), AUCT_HELP_VENDOR_SELL));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_VENDOR_BUY, Auctioneer_GetFilterVal(AUCT_SHOW_VENDOR_BUY), AUCT_HELP_VENDOR_BUY));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_USAGE, Auctioneer_GetFilterVal(AUCT_SHOW_USAGE), AUCT_HELP_USAGE));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_STACK, Auctioneer_GetFilterVal(AUCT_SHOW_STACK), AUCT_HELP_STACK));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_LINK, Auctioneer_GetFilterVal(AUCT_SHOW_LINK), AUCT_HELP_LINK));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_AUTOFILL, Auctioneer_GetFilterVal(AUCT_CMD_AUTOFILL), AUCT_HELP_AUTOFILL));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_EMBED, Auctioneer_GetFilterVal(AUCT_CMD_EMBED), AUCT_HELP_EMBED));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_EMBED_BLANK, Auctioneer_GetFilterVal(AUCT_SHOW_EMBED_BLANK), AUCT_HELP_EMBED_BLANK));

	lineFormat = "  |cffffffff/auctioneer %s %s|r |cff2040ff[%s]|r - %s";
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_LOCALE, AUCT_OPT_LOCALE, Auctioneer_GetFilterVal('locale'), AUCT_HELP_LOCALE));

	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_PCT_MARKUP, AUCT_OPT_PCT_MARKUP, Auctioneer_GetFilterVal(AUCT_CMD_PCT_MARKUP, AUCT_OPT_PCT_MARKUP_DEFAULT), AUCT_HELP_PCT_MARKUP));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_PCT_BIDMARKDOWN, AUCT_OPT_PCT_BIDMARKDOWN, Auctioneer_GetFilterVal(AUCT_CMD_PCT_BIDMARKDOWN, AUCT_OPT_PCT_BIDMARKDOWN_DEFAULT), AUCT_HELP_PCT_BIDMARKDOWN));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_PCT_NOCOMP, AUCT_OPT_PCT_NOCOMP, Auctioneer_GetFilterVal(AUCT_CMD_PCT_NOCOMP, AUCT_OPT_PCT_NOCOMP_DEFAULT), AUCT_HELP_PCT_NOCOMP));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_PCT_UNDERLOW, AUCT_OPT_PCT_UNDERLOW, Auctioneer_GetFilterVal(AUCT_CMD_PCT_UNDERLOW, AUCT_OPT_PCT_UNDERLOW_DEFAULT), AUCT_HELP_PCT_UNDERLOW));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_PCT_UNDERMKT, AUCT_OPT_PCT_UNDERMKT, Auctioneer_GetFilterVal(AUCT_CMD_PCT_UNDERMKT, AUCT_OPT_PCT_UNDERMKT_DEFAULT), AUCT_HELP_PCT_UNDERMKT));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_PCT_MAXLESS, AUCT_OPT_PCT_MAXLESS, Auctioneer_GetFilterVal(AUCT_CMD_PCT_MAXLESS, AUCT_OPT_PCT_MAXLESS_DEFAULT), AUCT_HELP_PCT_MAXLESS));

	lineFormat = "  |cffffffff/auctioneer %s %s|r - %s";
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_CLEAR, AUCT_OPT_CLEAR, AUCT_HELP_CLEAR));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_ALSO, AUCT_OPT_ALSO, AUCT_HELP_ALSO));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_BROKER, AUCT_OPT_BROKER, AUCT_HELP_BROKER));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_BIDBROKER, AUCT_OPT_BIDBROKER, AUCT_HELP_BIDBROKER));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_PERCENTLESS, AUCT_OPT_PERCENTLESS, AUCT_HELP_PERCENTLESS));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_COMPETE, AUCT_OPT_COMPETE, AUCT_HELP_COMPETE));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_SCAN, AUCT_OPT_SCAN, AUCT_HELP_SCAN));

end

--The Auctioneer_OnOff(state, chatprint) function handles the state of the Auctioneer AddOn (whether it is currently on or off)
--If "on" or "off" is specified in the " state" variable then Auctioneer's state is changed to that value,
--If "toggle" is specified then it will toggle Auctioneer's state (if currently on then it will be turned off and vice-versa)
--If no keyword is specified then the functione will simply return the current state
--
--If chatprint is "true" then the state will also be printed to the user.

function Auctioneer_OnOff(state, chatprint)

	if ((state == nil) or (state == "")) then
		state = Auctioneer_GetFilterVal("all");


	elseif ((state == AUCT_CMD_ON) or (state == "on")) then
		Auctioneer_SetFilter("all", "on");


	elseif ((state == AUCT_CMD_OFF) or (state == "off")) then
		Auctioneer_SetFilter("all", "off");


	elseif ((state == AUCT_CMD_TOGGLE) or (state == "toggle")) then
		state = Auctioneer_GetFilterVal("all");

		if (state == "off") then
			Auctioneer_SetFilter("all", "on");
		else
			Auctioneer_SetFilter("all", "off");
		end
	end

	--Print the change and alert the GUI if the command came from slash commands. Do nothing if they came from the GUI.
	if (chatprint == true) then
		if ((state == AUCT_CMD_ON) or (state == "on")) then
			Auctioneer_ChatPrint(AUCT_STAT_ON);

			if (Auctioneer_Khaos_Registered) then
				Khaos.setSetKeyParameter("Auctioneer", "AuctioneerEnable", "checked", true);
			end
		else
			Auctioneer_ChatPrint(AUCT_STAT_OFF);

			if (Auctioneer_Khaos_Registered) then
				Khaos.setSetKeyParameter("Auctioneer", "AuctioneerEnable", "checked", false);
			end
		end
	end

	return state;	
end

--The following functions are almost verbatim copies of the original functions but modified in order to make them compatible with direct GUI access.
function Auctioneer_Clear(param, chatprint)

	local aKey = Auctioneer_GetAuctionKey();
	local clearok = nil;

	if ((param == AUCT_CMD_CLEAR_ALL) or (param == "all")) then

		AuctionConfig.data = {};
		AuctionConfig.info = {};
		AuctionConfig.snap = {};
		AuctionConfig.sbuy = {};

	elseif ((param == AUCT_CMD_CLEAR_SNAPSHOT) or (param == "snapshot")) then

		AuctionConfig.snap = {};
		AuctionConfig.sbuy = {};
		lSnapshotItemPrices = {}; 

	else

		local items = Auctioneer_GetItems(param);
		if (items) then
			for pos,itemKey in pairs(items) do
				if (AuctionConfig.data[aKey][itemKey] ~= nil) then
					AuctionConfig.data[aKey][itemKey] = nil;
					clearok = true;
				else
					clearok = false;
				end
			end
		end
	end

	if (chatprint == true) then

		if ((param == AUCT_CMD_CLEAR_ALL) or (param == "all")) then
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_CLEARALL, aKey));

		elseif ((param == AUCT_CMD_CLEAR_SNAPSHOT) or (param == "snapshot")) then
			Auctioneer_ChatPrint(AUCT_FRMT_ACT_CLEARSNAP);

		else
			if (clearok == true) then
				Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_CLEAR_OK, itemKey));

			else
				Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_CLEAR_FAIL, itemKey));
			end
		end
	end
end


function Auctioneer_AlsoInclude(param, chatprint)

	if ((param == AUCT_CMD_ALSO_OPPOSITE) or (param == "opposite")) then
		param = "opposite";
	end

	if (not Auctioneer_IsValidAlso(param)) then

		if (chatprint == true) then 
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_UNKNOWN_RF, param));
		end
		return
	end
	
	Auctioneer_SetFilter("also", param);
	
	if (chatprint == true) then 
		
		if (Auctioneer_Khaos_Registered) then 
			Khaos.setSetKeyParameter("Auctioneer", "AuctioneerInclude", "value", param);
		end

		if ((param == AUCT_CMD_OFF) or (param == "off")) then
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_DISABLE, AUCT_CMD_ALSO));	

		else
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_ALSO, param));
		end	
	end
end


function Auctioneer_SetLocale(param, chatprint)

local validLocale=nil;

	if (param == Auctioneer_GetLocale()) then
		--Do Nothing
		validLocale=true;
	elseif (AUCT_VALID_LOCALES[param]) then
		Auctioneer_SetFilter('locale', param);
		Auctioneer_SetLocaleStrings(Auctioneer_GetLocale());
		Auctioneer_BuildBaseData();
		validLocale=true;

	elseif (param == '') or (param == 'default') or (param == 'off') then
		Auctioneer_SetFilter('locale', 'default');
		Auctioneer_SetLocaleStrings(Auctioneer_GetLocale());
		validLocale=true;
	end
	
	
	if (chatprint == true) then

		if ((validLocale == true) and (AUCT_VALID_LOCALES[param])) then
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_LOCALE, param));
			
			if (Auctioneer_Khaos_Registered) then
				Khaos.setSetKeyParameter("Auctioneer", "AuctioneerLocale", "value", param);
			end

		elseif (validLocale == nil) then
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_UNKNOWN_LOCALE, param));

			if (AUCT_VALID_LOCALES) then
				for locale, x in pairs(AUCT_VALID_LOCALES) do
					Auctioneer_ChatPrint("  "..locale);
				end
			end

		else
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_LOCALE, 'default'));

			if (Auctioneer_Khaos_Registered) then
				Khaos.setSetKeyParameter("Auctioneer", "AuctioneerLocale", "value", "default");
			end
		end
	end
end


function Auctioneer_Default(param, chatprint)

	if ((param == AUCT_CMD_CLEAR_ALL) or (param == "all") or (param == "") or (param == nil)) then
		AuctionConfig = {};

	else
		Auctioneer_SetFilter(param, nil);
	end

	if (chatprint == true) then
		if ((param == AUCT_CMD_CLEAR_ALL) or (param == "all")) then
			Auctioneer_ChatPrint(AUCT_FRMT_ACT_DEFAULTALL);

		else
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_DEFAULT, param));
		end
	end
end


function Auctioneer_GenVarSet(variable, param, chatprint)

	if ((param == AUCT_CMD_ON) or (param == "on")) then
		Auctioneer_SetFilter(variable, "on");

	elseif ((param == AUCT_CMD_OFF) or (param == "off")) then
		Auctioneer_SetFilter(variable, "off");

	elseif ((param == AUCT_CMD_TOGGLE) or (param == "toggle") or (param == nil) or (param == "")) then
		param = Auctioneer_GetFilterVal(variable);

		if (param == "on") then
			param = "off";

		else
			param = "on";
		end

		Auctioneer_SetFilter(variable, param);
	end

	if (chatprint == true) then	

		if ((param == AUCT_CMD_ON) or (param == "on")) then
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_ENABLE, variable));

			--Account for different key name in the embed variable
			if ((variable == AUCT_CMD_EMBED) or (variable == "embed")) then

				if (Auctioneer_Khaos_Registered) then
					Khaos.setSetKeyParameter("Auctioneer", "AuctioneerEmbed", "checked", true);
				end
			else

				if (Auctioneer_Khaos_Registered) then
					Khaos.setSetKeyParameter("Auctioneer", variable, "checked", true);
				end
			end

		elseif ((param == AUCT_CMD_OFF) or (param == "off")) then
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_DISABLE, variable));

			--Account for different key name in the embed variable
			if ((variable == AUCT_CMD_EMBED) or (variable == "embed")) then

				if (Auctioneer_Khaos_Registered) then
					Khaos.setSetKeyParameter("Auctioneer", "AuctioneerEmbed", "checked", false);
				end
			else

				if (Auctioneer_Khaos_Registered) then
					Khaos.setSetKeyParameter("Auctioneer", variable, "checked", false);
				end
			end
		end
	end
end


function Auctioneer_PercentVarSet(variable, param, chatprint)

	local paramVal = tonumber(param);
	if paramVal == nil then
		-- failed to convert the param to a number
		if chatprint then
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_UNKNOWN_ARG, param, variable));
		end
		return -- invalid argument, don't do anything
	end
	-- param is a valid number, save it
	Auctioneer_SetFilter(variable, paramVal);

	if (chatprint == true) then
		Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_SET, variable, paramVal.."%"));

		if (Auctioneer_Khaos_Registered) then
			Khaos.setSetKeyParameter("Auctioneer", variable, "value", paramVal);
		end
	end
end

--This marks the end of the New Command processing code.
function Auctioneer_SetFilter(type, value)
	if (not AuctionConfig.filters) then AuctionConfig.filters = {}; end
	AuctionConfig.filters[type] = value;
end

function Auctioneer_GetFilterVal(type, default)
	if (default == nil) then default = "on"; end
	if (not AuctionConfig.filters) then AuctionConfig.filters = {}; end
	value = AuctionConfig.filters[type];
	if (not value) then
		if (type == AUCT_SHOW_LINK) then return "off"; end
		if (type == AUCT_CMD_EMBED) then return "off"; end
		return default;
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


function Auctioneer_Auctions_Clear()
	for i = 1, 5 do
		getglobal("AuctionInfoText"..i):Hide();
		getglobal("AuctionInfoMoney"..i):Hide();
	end
	AuctionInfoWarnText:Hide();
end

function Auctioneer_Auctions_SetWarn(textStr)
	if (AuctionInfoWarnText == nil) then p("Error, no text for AuctionInfo line "..line); end
	AuctionInfoWarnText:SetText(textStr);
	AuctionInfoWarnText:SetTextColor(0.9, 0.4, 0.0);
	AuctionInfoWarnText:Show();
end

function Auctioneer_Auctions_SetLine(line, textStr, moneyAmount)
	local text = getglobal("AuctionInfoText"..line);
	local money = getglobal("AuctionInfoMoney"..line);
	if (text == nil) then p("Error, no text for AuctionInfo line "..line); end
	if (money == nil) then p("Error, no money for AuctionInfo line "..line); end
	text:SetText(textStr);
	text:Show();
	if (money ~= nil) then
		MoneyFrame_Update("AuctionInfoMoney"..line, math.floor(nullSafe(moneyAmount)));
		getglobal("AuctionInfoMoney"..line.."SilverButtonText"):SetTextColor(1.0,1.0,1.0);
		getglobal("AuctionInfoMoney"..line.."CopperButtonText"):SetTextColor(0.86,0.42,0.19);
		money:Show();
	else
		money:Hide();
	end
end

function Auctioneer_GetItemLinks(str)
	if (not str) then return nil end
	local itemList = {};
	local listSize = 0;
	for link, item in string.gfind(str, "|Hitem:([^|]+)|h[[]([^]]+)[]]|h") do
		listSize = listSize+1;
		itemList[listSize] = item.." = "..link;
	end
	return itemList;
end


function Auctioneer_GetItems(str)
	if (not str) then return nil end
	local itemList = {};
	local listSize = 0;
	local itemKey;
	for itemID, randomProp, enchant, uniqID in string.gfind(str, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h") do
		itemKey = itemID..":"..randomProp..":"..enchant;
		listSize = listSize+1;
		itemList[listSize] = itemKey;
	end
	return itemList;
end

-- this function takes copper and rounds to 5 silver below the the nearest gold if it is less than 15 silver above of an even gold
-- example: this function changes 1g9s to 95s
-- example: 1.5g will be unchanged and remain 1.5g
function Auctioneer_RoundDownTo95(copper)
	local g,s,c = TT_GetGSC(copper);

	if g > 0 and s < 10 then
		return (copper - ((s + 5) * 100)); -- subtract enough copper to round to 95 silver
	end

	return copper;
end

Auctioneer_FindItemInBags = TT_FindItemInBags;

function Auctioneer_OnEvent(event)
--	p("Event", event);
	if (event=="NEW_AUCTION_UPDATE") then
		local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo()

		if (not name) then
			Auctioneer_Auctions_Clear()
			return
		end

		local bag, slot, id, rprop, enchant, uniq = TT_FindItemInBags(name);
		if (bag == nil) then
			-- is the item one of your bags?
			local i
			for i = 0, 4, 1 do
				if name == GetBagName(i) then
					id, rprop, enchant, uniq = breakLink(GetInventoryItemLink("player", ContainerIDToInventoryID(i)))
					break
				end
			end
		end

		-- still no corresponding item found?
		if id == nil then
			Auctioneer_Auctions_Clear()
			return
		end

		local startPrice, buyoutPrice, x;
		local itemKey = id..":"..rprop..":"..enchant;
		local auctionPriceItem = Auctioneer_GetAuctionPriceItem(itemKey);
		local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = Auctioneer_GetAuctionPrices(auctionPriceItem.data);

        -- Find the current lowest buyout for 1 of these in the current snapshot
        local currentLowestBuyout = Auctioneer_FindLowestAuctions(itemKey);
        if currentLowestBuyout then
		    x,x,x,x,lowStackCount,x,currentLowestBuyout = Auctioneer_GetItemSignature(currentLowestBuyout);
            currentLowestBuyout = currentLowestBuyout / lowStackCount;
        end 
        
		local historicalMedian, historicalMedCount = Auctioneer_GetItemHistoricalMedianBuyout(itemKey);
		local snapshotMedian, snapshotMedCount = Auctioneer_GetItemSnapshotMedianBuyout(itemKey);

		Auctioneer_Auctions_Clear();
		Auctioneer_Auctions_SetLine(1, string.format(AUCT_FRMT_AUCTINFO_HIST, historicalMedCount), historicalMedian * count); 
		Auctioneer_Auctions_SetLine(2, string.format(AUCT_FRMT_AUCTINFO_SNAP, snapshotMedCount), snapshotMedian * count); 
		if (snapshotMedCount and snapshotMedCount > 0 and currentLowestBuyout) then
			Auctioneer_Auctions_SetLine(3, AUCT_FRMT_AUCTINFO_LOW, currentLowestBuyout * count);
		else
			Auctioneer_Auctions_SetLine(3, AUCT_FRMT_AUCTINFO_NOLOW);
		end
		local blizPrice = MoneyInputFrame_GetCopper(StartPrice);

		local hsp, hspCount, mktPrice, warn = Auctioneer_GetHSP(itemKey, auctionKey);
		if hsp == 0 and buyCount > 0 then
			hsp = math.floor(buyPrice / buyCount); -- use mean buyout if median not available
		end
		local discountBidPercent = tonumber(Auctioneer_GetFilterVal(AUCT_CMD_PCT_BIDMARKDOWN, AUCT_OPT_PCT_BIDMARKDOWN_DEFAULT));
		local countFix = count
		if countFix == 0 then
			countFix = 1
		end
		local buyPrice = Auctioneer_RoundDownTo95(nullSafe(hsp) * countFix);
		local bidPrice = Auctioneer_RoundDownTo95(Auctioneer_SubtractPercent(buyPrice, discountBidPercent));

		if (Auctioneer_GetFilter(AUCT_CMD_AUTOFILL)) then
			Auctioneer_Auctions_SetLine(4, AUCT_FRMT_AUCTINFO_MKTPRICE, nullSafe(mktPrice)*countFix);
			Auctioneer_Auctions_SetLine(5, AUCT_FRMT_AUCTINFO_ORIG, blizPrice);
			Auctioneer_Auctions_SetWarn(warn);
			MoneyInputFrame_SetCopper(StartPrice, bidPrice);
			MoneyInputFrame_SetCopper(BuyoutPrice, buyPrice);
		else
			Auctioneer_Auctions_SetLine(4, AUCT_FRMT_AUCTINFO_SUGBID, bidPrice);
			Auctioneer_Auctions_SetLine(5, AUCT_FRMT_AUCTINFO_SUGBUY, buyPrice);
			Auctioneer_Auctions_SetWarn(warn);
		end
	elseif (event=="AUCTION_HOUSE_SHOW") then
		Auctioneer_ConfigureAH();
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
		if (Auctioneer_CheckCompleteScan()) then
			Auctioneer_ScanAuction();
		end
	elseif (event == "VARIABLES_LOADED") then
		Auctioneer_SetLocaleStrings(Auctioneer_GetLocale());

		-- Load the category and subcategory id's
		Auctioneer_LoadCategories();

		if (not AuctionConfig.version) then AuctionConfig.version = 30000; end
		if (AuctionConfig.version < 30200) then
			StaticPopupDialogs["CONVERT_AUCTIONEER"] = {
				text = AUCT_MESG_CONVERT,
				button1 = AUCT_MESG_CONVERT_YES,
				button2 = AUCT_MESG_CONVERT_NO,
				OnAccept = function()
					Auctioneer_Convert();
					Auctioneer_LockAndLoad();
				end,
				OnCancel = function()
					Auctioneer_ChatPrint(AUCT_MESG_NOTCONVERTING);
				end,
				timeout = 0,
				whileDead = 1,
				exclusive = 1
			};
			StaticPopup_Show("CONVERT_AUCTIONEER", "","");
		else
			Auctioneer_LockAndLoad();
		end
		
		--GUI Registration code added by MentalPower	
		Auctioneer_Register();
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
			if (d) then
				for k, v in pairs(d) do
					if (not first) then out = out .. ", "; end
					first = false;
					out = out .. dump(k);
					out = out .. " = ";
					out = out .. dump(v);
				end
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
		local t = type(arg[i]);
		if (t == "string") then
			out = out .. '"'..arg[i]..'"';
		elseif (t == "number") then
			out = out .. arg[i];
		else
			out = out .. dump(arg[i]);
		end
	end
	ChatFrame1:AddMessage(out, 1.0, 1.0, 0.0);
end
