--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	Auctioneer statistical functions.
	Functions to calculate various forms of statistics from the auction data.
]]

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
	if (valuesTable == nil) or (type(valuesTable) ~= "table") then
		return nil   -- make valuesTable a required table argument
	end
	if table.getn(valuesTable) == 0 then
		return 0, 0; -- if there is an empty table, returns median = 0, count = 0
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

	local snapMedian, snapSeenCount = Auctioneer_GetMedian(buyoutPrices);

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
	end
	if (buyoutHistoryTable) then
		historyMedian, historySeenCount = Auctioneer_GetMedian(buyoutHistoryTable);
	end

	-- save median to the savedvariablesfile
	Auctioneer_SetHistMed(auctKey, itemKey, historyMedian, historySeenCount)

	return tonumber(historyMedian) or 0, tonumber(historySeenCount) or 0;
end

function Auctioneer_GetHistMedian(itemKey, auctKey, buyoutHistoryTable)
	if (not auctKey) then auctKey = Auctioneer_GetAuctionKey() end
	local stat = nil; local count = nil;
	if (AuctionConfig.stats and AuctionConfig.stats.histmed and AuctionConfig.stats.histmed[auctKey]) then
		stat = AuctionConfig.stats.histmed[auctKey][itemKey];
	end
	if (AuctionConfig.stats.histcount and AuctionConfig.stats.histcount[auctKey]) then
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
		count = snapCount;
	elseif (historyMedian) then
		usableMedian = historyMedian;
		count = histCount;
	end
	return usableMedian, count;
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
function Auctioneer_IsBadResaleChoice(auctSig, auctKey)
	if (not auctKey) then auctKey = Auctioneer_GetAuctionKey() end

	local isBadChoice = false;
	local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(auctSig);
	local itemKey = id..":"..rprop..":"..enchant;
	local itemCat = Auctioneer_GetCatForKey(itemKey);
	local auctionItem = Auctioneer_GetSnapshot(auctKey, itemCat, auctSig);
	local auctionPriceItem = Auctioneer_GetAuctionPriceItem(itemKey, auctKey);
	local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = Auctioneer_GetAuctionPrices(auctionPriceItem.data);
	local bidPercent = math.floor(bidCount / minCount * 100);

	if (auctionItem) then
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
	end

	return isBadChoice;
end

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

-- this function takes copper and rounds to 5 silver below the the nearest gold if it is less than 15 silver above of an even gold
-- example: this function changes 1g9s to 95s
-- example: 1.5g will be unchanged and remain 1.5g
function Auctioneer_RoundDownTo95(copper)
	local g,s,c = EnhTooltip.GetGSC(copper);
	if g > 0 and s < 10 then
		return (copper - ((s + 5) * 100)); -- subtract enough copper to round to 95 silver
	end
	return copper;
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

	local lowKey = itemID..":"..itemRand;

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
	local itemID, randomProp, enchant, uniqID, itemName = EnhTooltip.BreakLink(link);
	local itemKey = itemID..":"..randomProp..":"..enchant;

	local median, count = Auctioneer_GetUsableMedian(itemKey);
	if (not median) then
		Auctioneer_ChatPrint(string.format(_AUCT['FrmtMedianNoauct'], Auctioneer_ColorTextWhite(itemName)));
	else
		if (not count) then count = 0 end
		Auctioneer_ChatPrint(string.format(_AUCT['FrmtMedianLine'], count, Auctioneer_ColorTextWhite(itemName), EnhTooltip.GetTextGSC(median)));
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
	if medianBuyout and avgBuy then
		typicalBuyout = math.min(avgBuy, medianBuyout);
	elseif medianBuyout then
		typicalBuyout = medianBuyout;
	else
		typicalBuyout = avgBuy or 0;
	end

	if (avgBid) then
		bidBasedSellPrice = math.floor((3*typicalBuyout + avgBid) / 4);
	else
		bidBasedSellPrice = typicalBuyout;
	end
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
		p("This is only some debugging code. THIS IS NO BUG!");
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
	local warn = _AUCT['FrmtWarnNodata'];
	--p("Getting HSP, calling GetMarketPrice", itemKey, realm);
	if (not buyoutValues) then
		buyoutValues = Auctioneer_GetSnapshotInfo(realm, itemKey);
	end
	
	local marketPrice = Auctioneer_GetMarketPrice(itemKey, realm, buyoutValues);

	-- Get our user-set pricing parameters
	local lowestAllowedPercentBelowMarket = tonumber(Auctioneer_GetFilterVal(_AUCT['CmdPctMaxless'],  _AUCT['OptPctMaxlessDefault']));
	local discountLowPercent              = tonumber(Auctioneer_GetFilterVal(_AUCT['CmdPctUnderlow'], _AUCT['OptPctUnderlowDefault']));
	local discountMarketPercent           = tonumber(Auctioneer_GetFilterVal(_AUCT['CmdPctUndermkt'], _AUCT['OptPctUndermktDefault']));
	local discountNoCompetitionPercent    = tonumber(Auctioneer_GetFilterVal(_AUCT['CmdPctNocomp'],   _AUCT['OptPctNocompDefault']));
	local vendorSellMarkupPercent         = tonumber(Auctioneer_GetFilterVal(_AUCT['CmdPctMarkup'],   _AUCT['OptPctMarkupDefault']));

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

	--p("Auction data: ", hsp, histCount, market, warn, nexthsp, nextwarn);

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
				warn = _AUCT['FrmtWarnMyprice'];
			elseif (currentLowestBuyout < lowestBuyoutPriceAllowed) then
				highestSellablePrice = Auctioneer_SubtractPercent(marketPrice, discountMarketPercent);
				warn = _AUCT['FrmtWarnToolow'];
			elseif (currentLowestBuyout > marketPrice) then
				highestSellablePrice = Auctioneer_SubtractPercent(marketPrice, discountNoCompetitionPercent);
				warn = _AUCT['FrmtWarnAbovemkt'];
			else -- use discount low
				-- set highest price to "Discount low"
				highestSellablePrice = Auctioneer_SubtractPercent(currentLowestBuyout, discountLowPercent);
				warn = string.format(_AUCT['FrmtWarnUndercut'], discountLowPercent);
			end
		else -- no low buyout, use discount no competition
			-- set highest price to "Discount no competition"
			highestSellablePrice = Auctioneer_SubtractPercent(marketPrice, discountNoCompetitionPercent);
			warn = _AUCT['FrmtWarnNocomp'];
		end
	else -- no market
		-- Note: urentLowestBuyout is nil, incase the realm is not the current player's realm
		if currentLowestBuyout and currentLowestBuyout > 0 then
			-- set highest price to "Discount low"
--~ p("Discount low case 2");
			highestSellablePrice = Auctioneer_SubtractPercent(currentLowestBuyout, discountLowPercent);
			warn = string.format(_AUCT['FrmtWarnUndercut'], discountLowPercent);
		else
			local baseData;
			if (Informant) then baseData = Informant.GetItem(id) end

			if (baseData and baseData.sell) then
				-- use vendor prices if no auction data available
				local vendorSell = nullSafe(baseData.sell); -- use vendor prices
				highestSellablePrice = Auctioneer_AddPercent(vendorSell, vendorSellMarkupPercent);
				warn = string.format(_AUCT['FrmtWarnMarkup'], vendorSellMarkupPercent);
			end
		end
	end

	return highestSellablePrice, marketPrice, warn;
end


