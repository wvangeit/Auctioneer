--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	Auctioneer filtering functions.
	Functions to filter auctions based upon various parameters.
]]

function Auctioneer_BrokerFilter(minProfit, signature)
	local filterAuction = true;
	local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(signature);
	local itemKey = id..":"..rprop..":"..enchant;

	if (buyout and buyout > 0 and buyout <= MAX_BUYOUT_PRICE and Auctioneer_GetUsableMedian(itemKey)) then
		local auctKey = Auctioneer_GetAuctionKey();
		local itemCat = Auctioneer_GetCatForKey(itemKey);
		local snap = Auctioneer_GetSnapshot(auctKey, itemCat, signature);
			
		if (snap) then
			local timeLeft = snap.timeLeft;
			local elapsedTime = time() - snap.lastSeenTime;
			local secondsLeft = TIME_LEFT_SECONDS[timeLeft] - elapsedTime;
			
			if (secondsLeft > 0) then
				local hsp, seenCount = Auctioneer_GetHSP(itemKey, auctKey);
				local profit = (hsp * count) - buyout;
				local profitPricePercent = math.floor((profit / buyout) * 100);

				if (profit >= minProfit and profitPricePercent >= MIN_PROFIT_PRICE_PERCENT and seenCount >= MIN_BUYOUT_SEEN_COUNT and not Auctioneer_IsBadResaleChoice(signature)) then
					filterAuction = false;
				end
			end
			
		end
	end

	return filterAuction;
end


-- filters out all auctions except those that have no more than maximumTime remaining and meet profit requirements
function Auctioneer_BidBrokerFilter(minProfit, signature, maximumTime)
	local filterAuction = true;
	local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(signature);
	local itemKey = id..":"..rprop..":"..enchant;
	if (not maximumTime) then maximumTime = 100000 end
	
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
		if (second == nil or currentBid < second * 1.2 and currentBid <= MAX_BUYOUT_PRICE) then
			local itemCat = Auctioneer_GetCatForKey(itemKey);
			local snap = Auctioneer_GetSnapshot(auctKey, itemCat, signature);

			if (snap) then
				local timeLeft = tonumber(snap.timeLeft);
				local elapsedTime = time() - tonumber(snap.lastSeenTime);
				local secondsLeft = TIME_LEFT_SECONDS[timeLeft] - elapsedTime;

				if (secondsLeft <= maximumTime and secondsLeft > 0) then
					-- hsp is the HSP with the lowest priced item still in the auction, nshp is the next highest price.
					local hsp, seenCount, x, x, nhsp = Auctioneer_GetHSP(itemKey, auctKey, buyoutValues);
					local profit = (hsp * count) - currentBid;
					local profitPricePercent = math.floor((profit / currentBid) * 100);

					if (profit >= minProfit and profitPricePercent >= MIN_PROFIT_PRICE_PERCENT and seenCount >= MIN_BUYOUT_SEEN_COUNT and not Auctioneer_IsBadResaleChoice(signature)) then 
						filterAuction = false;
					end
				end
			end
		end
	end

	return filterAuction;
end

function Auctioneer_AuctionOwnerFilter(owner, signature)
	local auctKey = Auctioneer_GetAuctionKey();
	local itemCat = Auctioneer_GetCatForSig(signature);
	local snap = Auctioneer_GetSnapshot(auctKey, itemCat, signature);
	if (snap and snap.owner == owner) then
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
	if (snap and snap.owner ~= UnitName("player")) and
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
	local auctKey = Auctioneer_GetAuctionKey();

	local hsp, seenCount = Auctioneer_GetHSP(itemKey, auctKey)

	if hsp > 0 and seenCount >= MIN_BUYOUT_SEEN_COUNT then
		local profit = (hsp * count) - buyout;
		--see if this auction should not be filtered
		if (buyout > 0 and Auctioneer_PercentLessThan(hsp, buyout / count) >= tonumber(percentLess) and profit >= MIN_PROFIT_MARGIN) then
			local itemCat = Auctioneer_GetCatForKey(itemKey);
			local snap = Auctioneer_GetSnapshot(auctKey, itemCat, signature);
			if (snap) then
				local timeLeft = tonumber(snap.timeLeft);
				local elapsedTime = time() - tonumber(snap.lastSeenTime);
				local secondsLeft = TIME_LEFT_SECONDS[timeLeft] - elapsedTime;

				if (secondsLeft > 0) then
					filterAuction = false;
				end
			end
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
				if (not filter(param, auctionSignature, extra1, extra2)) then
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

-- builds the list of auctions that can be bought and resold for profit
function Auctioneer_DoBroker(minProfit)
	if not minProfit or minProfit == "" then
		minProfit = MIN_PROFIT_MARGIN
	elseif (tonumber(minProfit)) then
		minProfit = tonumber(minProfit) * 100
	else
		Auctioneer_ChatPrint(string.format(_AUCT['FrmtActUnknown'], minProfit))
		return
	end
	
	local output = string.format(_AUCT['FrmtBrokerHeader'], EnhTooltip.GetTextGSC(minProfit));
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
			output = string.format(_AUCT['FrmtBrokerLine'], Auctioneer_ColorTextWhite(count.."x")..a.itemLink, seenCount, EnhTooltip.GetTextGSC(hsp * count), EnhTooltip.GetTextGSC(buyout), EnhTooltip.GetTextGSC(profit));
			Auctioneer_ChatPrint(output);
		end
	end

	Auctioneer_ChatPrint(_AUCT['FrmtBrokerDone']);
end

-- builds the list of auctions that can be bought and resold for profit
function Auctioneer_DoBidBroker(minProfit)
	if not minProfit or minProfit == "" then
		minProfit = MIN_PROFIT_MARGIN
	elseif (tonumber(minProfit)) then
		minProfit = tonumber(minProfit) * 100
	else
		Auctioneer_ChatPrint(string.format(_AUCT['FrmtActUnknown'], minProfit))
		return
	end
	
	local output = string.format(_AUCT['FrmtBidbrokerHeader'], EnhTooltip.GetTextGSC(minProfit));
	Auctioneer_ChatPrint(output);

	local bidWorthyAuctions = Auctioneer_QuerySnapshot(Auctioneer_BidBrokerFilter, minProfit, TIME_LEFT_SECONDS[TIME_LEFT_MEDIUM]);

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

			bidText = _AUCT['FrmtBidbrokerCurbid'];
			if (currentBid == min) then
				bidText = _AUCT['FrmtBidbrokerMinbid'];
			end
			EnhTooltip.DebugPrint("a", a);
			
			-- local secondsLeft = TIME_LEFT_SECONDS[a.timeLeft] + a.lastSeenTime - time()
			output = string.format(_AUCT['FrmtBidbrokerLine'], Auctioneer_ColorTextWhite(count.."x")..a.itemLink, seenCount, EnhTooltip.GetTextGSC(hsp * count), bidText, EnhTooltip.GetTextGSC(currentBid), EnhTooltip.GetTextGSC(profit), Auctioneer_ColorTextWhite(Auctioneer_GetTimeLeftString(a.timeLeft)));
			Auctioneer_ChatPrint(output);
		end
	end

	Auctioneer_ChatPrint(_AUCT['FrmtBidbrokerDone']);
end

function Auctioneer_DoCompeting(minLess)
	if not minLess or minLess == "" then
		minLess = DEFAULT_COMPETE_LESS * 100
	elseif (tonumber(minLess)) then
		minLess = tonumber(minLess) * 100
	else
		Auctioneer_ChatPrint(string.format(_AUCT['FrmtActUnknown'], minLess))
		return
	end
	
	local output = string.format(_AUCT['FrmtCompeteHeader'], EnhTooltip.GetTextGSC(minLess));
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

			bidPrice = EnhTooltip.GetTextGSC(bidForOne).."ea";
			if (currentBid == min) then
				bidPrice = "No bids ("..bidPrice..")";
			end

			myBuyout = myHighestPrices[itemKey];
			buyPrice = EnhTooltip.GetTextGSC(buyoutForOne).."ea";
			myPrice = EnhTooltip.GetTextGSC(myBuyout).."ea";
			priceLess = myBuyout - buyoutForOne;
			lessPrice = EnhTooltip.GetTextGSC(priceLess);

			output = string.format(_AUCT['FrmtCompeteLine'], Auctioneer_ColorTextWhite(count.."x")..a.itemLink, bidPrice, buyPrice, myPrice, lessPrice);
			Auctioneer_ChatPrint(output);
		end
	end

	Auctioneer_ChatPrint(_AUCT['FrmtCompeteDone']);
end

-- builds the list of auctions that can be bought and resold for profit
function Auctioneer_DoPercentLess(percentLess)
	if not percentLess or percentLess == "" then percentLess = MIN_PERCENT_LESS_THAN_HSP end
	local output = string.format(_AUCT['FrmtPctlessHeader'], percentLess);
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
			output = string.format(_AUCT['FrmtPctlessLine'], Auctioneer_ColorTextWhite(count.."x")..a.itemLink, seenCount, EnhTooltip.GetTextGSC(hsp * count), EnhTooltip.GetTextGSC(buyout), EnhTooltip.GetTextGSC(profit), Auctioneer_ColorTextWhite(Auctioneer_PercentLessThan(hsp, buyout / count).."%"));
			Auctioneer_ChatPrint(output);
		end
	end

	Auctioneer_ChatPrint(_AUCT['FrmtPctlessDone']);
end


