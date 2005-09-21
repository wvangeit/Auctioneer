--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	Auctioneer tooltip functions.
	Functions to present and draw the tooltips.
]]

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


