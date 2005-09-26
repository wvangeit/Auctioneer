--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	Auctioneer scanning functions
	Functions to handle the auction scan procedure
]]


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
						--p("Expired item", iKey, cat, "last seen", lastSeen, expiredSeconds, "ago (",endTime,")");
						--p("Snap", snap);
						if (expiredSeconds < TIME_LEFT_SECONDS[tonumber(snap.timeLeft)]) then
							--p("Bought out");
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
							p("Bid out");
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
						else
							--p("Expired out");
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

	Auctioneer_ChatPrint(string.format(_AUCT['AuctionTotalAucts'], Auctioneer_ColorTextWhite(lTotalAuctionsScannedCount)));
	Auctioneer_ChatPrint(string.format(_AUCT['AuctionNewAucts'], Auctioneer_ColorTextWhite(lNewAuctionsCount)));
	Auctioneer_ChatPrint(string.format(_AUCT['AuctionOldAucts'], Auctioneer_ColorTextWhite(lOldAuctionsCount)));
	Auctioneer_ChatPrint(string.format(_AUCT['AuctionDefunctAucts'], Auctioneer_ColorTextWhite(lDefunctAuctionsCount)));

	if (nullSafe(lDiscrepencyCount) > 0) then
		Auctioneer_ChatPrint(string.format(_AUCT['AuctionDiscrepancies'], Auctioneer_ColorTextWhite(lDiscrepencyCount)));
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
	
	local aiItemID, aiRandomProp, aiEnchant, aiUniqID = EnhTooltip.BreakLink(aiLink);
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

-- hook to capture data about an auction that was boughtout
function Auctioneer_PlaceAuctionBid(itemtype, itemindex, bidamount)
	-- get the info for this auction
	local aiLink = GetAuctionItemLink(AuctionFrame.type, GetSelectedAuctionItem(AuctionFrame.type));
	local aiItemID, aiRandomProp, aiEnchant, aiUniqID = EnhTooltip.BreakLink(aiLink);
	local aiKey = aiItemID..":"..aiRandomProp..":"..aiEnchant;
	local aiName, aiTexture, aiCount, aiQuality, aiCanUse, aiLevel, aiMinBid, aiMinIncrement,
		aiBuyout, aiBidAmount, aiHighBidder, aiOwner =
		GetAuctionItemInfo(AuctionFrame.type, GetSelectedAuctionItem(AuctionFrame.type));

	local auctionSignature = string.format("%d:%d:%d:%s:%d:%d:%d:%d", aiItemID, aiRandomProp, aiEnchant, nilSafeString(aiName), nullSafe(aiCount), nullSafe(aiMinBid), nullSafe(aiBuyout), aiUniqID);

	local playerName = UnitName("player");
	local eventTime = "e"..time();
	if (not AuctionConfig.bids) then AuctionConfig.bids = {} end
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
		Auctioneer_ChatPrint(string.format(_AUCT['FrmtActRemove'], auctionSignature));
		local auctKey = Auctioneer_GetAuctionKey();
		local itemCat = Auctioneer_GetCatForKey(aiKey);
		if (itemCat and AuctionConfig and AuctionConfig.snap and AuctionConfig.snap[auctKey] and AuctionConfig.snap[auctKey][itemCat]) then
			AuctionConfig.snap[auctKey][itemCat][auctionSignature] = nil;
		end
		AuctionConfig.bids[playerName][eventTime].itemWon = true;
		Auctioneer_HSPCache[auctKey][aiKey] = nil;
		if (Auctioneer_Lowests) then Auctioneer_Lowests = nil; end
	end

	Auctioneer_Old_BidHandler(itemtype,itemindex,bidamount);
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
	BrowseScanButton:SetText(_AUCT['TextScan']);
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


function Auctioneer_NewAuction()
	local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo()

	if (not name) then
		Auctioneer_Auctions_Clear()
		return
	end

	local bag, slot, id, rprop, enchant, uniq = EnhTooltip.FindItemInBags(name);
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
	Auctioneer_Auctions_SetLine(1, string.format(_AUCT['FrmtAuctinfoHist'], historicalMedCount), historicalMedian * count); 
	Auctioneer_Auctions_SetLine(2, string.format(_AUCT['FrmtAuctinfoSnap'], snapshotMedCount), snapshotMedian * count); 
	if (snapshotMedCount and snapshotMedCount > 0 and currentLowestBuyout) then
		Auctioneer_Auctions_SetLine(3, _AUCT['FrmtAuctinfoLow'], currentLowestBuyout * count);
	else
		Auctioneer_Auctions_SetLine(3, _AUCT['FrmtAuctinfoNolow']);
	end
	local blizPrice = MoneyInputFrame_GetCopper(StartPrice);

	local hsp, hspCount, mktPrice, warn = Auctioneer_GetHSP(itemKey, auctionKey);
	if hsp == 0 and buyCount > 0 then
		hsp = math.floor(buyPrice / buyCount); -- use mean buyout if median not available
	end
	local discountBidPercent = tonumber(Auctioneer_GetFilterVal(_AUCT['CmdPctBidmarkdown'], _AUCT['OptPctBidmarkdownDefault']));
	local countFix = count
	if countFix == 0 then
		countFix = 1
	end
	local buyPrice = Auctioneer_RoundDownTo95(nullSafe(hsp) * countFix);
	local bidPrice = Auctioneer_RoundDownTo95(Auctioneer_SubtractPercent(buyPrice, discountBidPercent));

	if (Auctioneer_GetFilter(_AUCT['CmdAutofill'])) then
		Auctioneer_Auctions_SetLine(4, _AUCT['FrmtAuctinfoMktprice'], nullSafe(mktPrice)*countFix);
		Auctioneer_Auctions_SetLine(5, _AUCT['FrmtAuctinfoOrig'], blizPrice);
		Auctioneer_Auctions_SetWarn(warn);
		MoneyInputFrame_SetCopper(StartPrice, bidPrice);
		MoneyInputFrame_SetCopper(BuyoutPrice, buyPrice);
	else
		Auctioneer_Auctions_SetLine(4, _AUCT['FrmtAuctinfoSugbid'], bidPrice);
		Auctioneer_Auctions_SetLine(5, _AUCT['FrmtAuctinfoSugbuy'], buyPrice);
		Auctioneer_Auctions_SetWarn(warn);
	end
end

function Auctioneer_AuctHouseShow()
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
end


function Auctioneer_AuctHouseClose()
	if Auctioneer_isScanningRequested then
		Auctioneer_StopAuctionScan();
	end
end

function Auctioneer_AuctHouseUpdate()
	if (Auctioneer_CheckCompleteScan()) then
		Auctioneer_ScanAuction();
	end
end


