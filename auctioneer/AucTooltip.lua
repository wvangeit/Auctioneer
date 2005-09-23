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
	local embedded = Auctioneer_GetFilter(_AUCT['CmdEmbed']);

	-- OUTPUT: seperator line
	if (embedded) then
		if (Auctioneer_GetFilter(_AUCT['ShowEmbedBlank'])) then
			TT_AddLine(" ", nil, embedded);
		end
	else
		TT_AddLine(name, nil, embedded);
		TT_LineQuality(quality);
	end

	if (Auctioneer_GetFilter(_AUCT['ShowLink'])) then
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
			TT_AddLine(string.format(_AUCT['FrmtInfoNever'], _AUCT['TextAuction']), nil, embedded);
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

			if (Auctioneer_GetFilter(_AUCT['ShowAverage'])) then -- show item's average auction price
				-- OUTPUT: "Seen [aCount] times at auction total"
				TT_AddLine(string.format(_AUCT['FrmtInfoSeen'], aCount), nil, embedded);
				TT_LineColor(0.5,0.8,0.1);
				if (not Auctioneer_GetFilter(_AUCT['ShowVerbose'])) then -- default mode
					if (avgQty > 1) then
						-- OUTPUT: "For 1: [avgMin] min/[avgBuy] BO ([avgBid] bid) [in [avgQty]'s]"
						TT_AddLine(string.format(_AUCT['FrmtInfoForone'], TT_GetTextGSC(avgMin), TT_GetTextGSC(avgBuy), TT_GetTextGSC(avgBid), avgQty), nil, embedded);
						TT_LineColor(0.1,0.8,0.5);
					else -- (avgQty = 1)
						-- OUTPUT: "[avgMin] min/[avgBuy] BO ([avgBid] bid)"
						TT_AddLine(string.format(_AUCT['FrmtInfoAverage'], TT_GetTextGSC(avgMin), TT_GetTextGSC(avgBuy), TT_GetTextGSC(avgBid)), nil, embedded);
						TT_LineColor(0.1,0.8,0.5);
					end
				else -- verbose mode
					if (count > 1) then
						-- OUTPUT: "Averages for [count] items:"
						TT_AddLine(string.format(_AUCT['FrmtInfoHeadMulti'], count), nil, embedded);
						TT_LineColor(0.4,0.5,1.0);
						-- OUTPUT: "  Minimum ([avgMin] ea)"
						TT_AddLine(string.format(_AUCT['FrmtInfoMinMulti'], TT_GetTextGSC(avgMin)), avgMin*count, embedded);
						TT_LineColor(0.4,0.5,0.8);
						if (Auctioneer_GetFilter(_AUCT['ShowStats'])) then -- show buyout/bidded percentages
							-- OUTPUT: "  Bidded ([bidPct]%, [avgBid] ea)"
							TT_AddLine(string.format(_AUCT['FrmtInfoBidMulti'], bidPct.."%, ", TT_GetTextGSC(avgBid)), avgBid*count, embedded);
							TT_LineColor(0.4,0.5,0.85);
							-- OUTPUT: "  Buyout ([buyPct]%, [avgBuy] ea)"
							TT_AddLine(string.format(_AUCT['FrmtInfoBuyMulti'], buyPct.."%, ", TT_GetTextGSC(avgBuy)), avgBuy*count, embedded);
							TT_LineColor(0.4,0.5,0.9);
						else -- don't show buyout/bidded percentages
							-- OUTPUT: "  Bidded ([avgBid] ea)"
							TT_AddLine(string.format(_AUCT['FrmtInfoBidMulti'], "", TT_GetTextGSC(avgBid)), avgBid*count, embedded);
							TT_LineColor(0.4,0.5,0.85);
							-- OUTPUT: "  Buyout ([avgBuy] ea)"
							TT_AddLine(string.format(_AUCT['FrmtInfoBuyMulti'], "", TT_GetTextGSC(avgBuy)), avgBuy*count, embedded);
							TT_LineColor(0.4,0.5,0.9);
						end
						if (median) then
							-- OUTPUT: "  Buyout median"
							TT_AddLine(_AUCT['FrmtInfoBuymedian'], median * count, embedded);
							TT_LineColor(0.4,0.5,0.95);
						end
					else -- (count = 0 | 1)
					   -- OUTPUT: "Averages for this item:"
						TT_AddLine(_AUCT['FrmtInfoHeadOne'], nil, embedded);
						TT_LineColor(0.4,0.5,1.0);
						-- OUTPUT: "  Minimum bid"
						TT_AddLine(_AUCT['FrmtInfoMinOne'], avgMin, embedded);
						TT_LineColor(0.4,0.5,0.8);
						if (Auctioneer_GetFilter(_AUCT['ShowStats'])) then -- show buyout/bidded percentages
							-- OUTPUT: "  Bidded [bidPct]%"
							TT_AddLine(string.format(_AUCT['FrmtInfoBidOne'], " "..bidPct.."%"), avgBid, embedded);
							TT_LineColor(0.4,0.5,0.85);
							-- OUTPUT: "  Buyout [buyPct]%"
							TT_AddLine(string.format(_AUCT['FrmtInfoBuyOne'], " "..buyPct.."%"), avgBuy, embedded);
							TT_LineColor(0.4,0.5,0.9);
						else -- don't show buyout/bidded percentages
						   -- OUTPUT: "  Bidded [bidPct]%"
							TT_AddLine(string.format(_AUCT['FrmtInfoBidOne'], ""), avgBid, embedded);
							TT_LineColor(0.4,0.5,0.85);
							-- OUTPUT: "  Buyout [buyPct]%"
							TT_AddLine(string.format(_AUCT['FrmtInfoBuyOne'], ""), avgBuy, embedded);
							TT_LineColor(0.4,0.5,0.9);
						end
						if (median) then
							-- OUTPUT: "  Buyout median"
							TT_AddLine(_AUCT['FrmtInfoBuymedian'], median, embedded);
							TT_LineColor(0.4,0.5,0.95);
						end
					end
					if (avgQty > 1) then
						-- OUTPUT: "  Average stack size: [avgQty] items"
						TT_AddLine(string.format(_AUCT['FrmtInfoStacksize'], avgQty), nil, embedded);
						TT_LineColor(0.4,0.5,1.0);
					end
				end

				if median and Auctioneer_GetFilter(_AUCT['ShowMedian']) then -- show item's median buyout price
					local historicalMedian, historicalMedCount = Auctioneer_GetItemHistoricalMedianBuyout(itemKey, auctKey);
					local snapshotMedian, snapshotMedCount = Auctioneer_GetItemSnapshotMedianBuyout(itemKey, auctKey);
					if historicalMedian and historicalMedCount > nullSafe(snapshotMedCount)  then
						-- OUTPUT: "Last [historicalMedCount], median BO (ea)"
						TT_AddLine(string.format(_AUCT['FrmtInfoHistmed'], historicalMedCount), historicalMedian, embedded)
						TT_LineColor(0.1,0.8,0.5);
					end
					if snapshotMedian then
						-- OUTPUT: "Scanned [snapshotMedCount], median BO (ea)"
						TT_AddLine(string.format(_AUCT['FrmtInfoSnapmed'], snapshotMedCount), snapshotMedian, embedded)
						TT_LineColor(0.1,0.8,0.5);
					end
				end
			end -- if(Auctioneer_GetFilter(_AUCT['ShowAverage'])) - show item's average auction price

			-- seperate line for suggested auction price (for clarification, even if the values have already been shown somewhere else
			if (Auctioneer_GetFilter(_AUCT['ShowSuggest'])) then -- show item's suggested auction price
				local hsp = Auctioneer_GetHSP(itemKey, auctKey);
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
				if (count > 1) then
					-- OUTPUT: "Suggested price for your [count] stack: [bidPrice] min/[buyPrice] BO"
					TT_AddLine(string.format(_AUCT['FrmtInfoSgststx'], count, TT_GetTextGSC(bidPrice, true), TT_GetTextGSC(buyPrice, true)), nil, embedded);
					TT_LineColor(0.5,0.5,0.8);
				else -- count = 0 | 1
					-- OUTPUT: "Suggested price: [bidPrice] min/[buyPrice] BO"
					TT_AddLine(string.format(_AUCT['FrmtInfoSgst'], TT_GetTextGSC(bidPrice, true), TT_GetTextGSC(buyPrice, true)), nil, embedded);
					TT_LineColor(0.5,0.5,0.8);
				end
			end
			if (not Auctioneer_GetFilter(_AUCT['ShowVerbose'])) then
				if (Auctioneer_GetFilter(_AUCT['ShowStats'])) then -- show buyout/bidded percentages
					-- OUTPUT: "[bidPct]% have bid, [buyPct]% have BO"
					TT_AddLine(string.format(_AUCT['FrmtInfoBidrate'], bidPct, buyPct), nil, embedded);
					TT_LineColor(0.1,0.5,0.8);
				end
			end
		end -- (aCount > 0)

		local also = Auctioneer_GetFilterVal("also");
		if (Auctioneer_IsValidAlso(also)) and (also ~= "off") then
			if (also == "opposite") then
				also = Auctioneer_GetOppositeKey();
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
				TT_AddLine(string.format(">> ".._AUCT['FrmtInfoNever'], also), nil, embedded);
				TT_LineColor(0.5,0.8,0.1);
			else
				if (Auctioneer_GetFilter(_AUCT['ShowAverage'])) then
					TT_AddLine(string.format(">> ".._AUCT['FrmtInfoAlsoseen'], aCount, also), nil, embedded);
					TT_LineColor(0.5,0.8,0.1);
					if (avgQty > 1) then
						TT_AddLine(string.format(">> ".._AUCT['FrmtInfoForone'], TT_GetTextGSC(avgMin), TT_GetTextGSC(avgBuy), TT_GetTextGSC(avgBid), avgQty), nil, embedded);
						TT_LineColor(0.1,0.8,0.5);
					else
						TT_AddLine(string.format(">> ".._AUCT['FrmtInfoAverage'], TT_GetTextGSC(avgMin), TT_GetTextGSC(avgBuy), TT_GetTextGSC(avgBid)), nil, embedded);
						TT_LineColor(0.1,0.8,0.5);
					end
					if (Auctioneer_GetFilter(_AUCT['ShowSuggest'])) then
						local hsp = Auctioneer_GetHSP(itemKey, also);
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
						if (count > 1) then
							-- OUTPUT: "Suggested price for your [count] stack: [bidPrice] min/[buyPrice] BO"
							TT_AddLine(string.format(">> ".._AUCT['FrmtInfoSgststx'], count, TT_GetTextGSC(bidPrice, true), TT_GetTextGSC(buyPrice, true)), nil, embedded);
							TT_LineColor(0.5,0.5,0.8);
						else -- count = 0 | 1
							-- OUTPUT: "Suggested price: [bidPrice] min/[buyPrice] BO"
							TT_AddLine(string.format(">> ".._AUCT['FrmtInfoSgst'], TT_GetTextGSC(bidPrice, true), TT_GetTextGSC(buyPrice, true)), nil, embedded);
							TT_LineColor(0.5,0.5,0.8);
						end
					end
				end
				if (Auctioneer_GetFilter(_AUCT['ShowStats'])) then
					TT_AddLine(string.format(">> ".._AUCT['FrmtInfoBidrate'], bidPct, buyPct), nil, embedded);
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

	if (Auctioneer_GetFilter(_AUCT['ShowVendor'])) then
		if ((buy > 0) or (sell > 0)) then
			local bgsc = TT_GetTextGSC(buy);
			local sgsc = TT_GetTextGSC(sell);

			if (count and (count > 1)) then
				local bqgsc = TT_GetTextGSC(buy*count);
				local sqgsc = TT_GetTextGSC(sell*count);
				if (Auctioneer_GetFilter(_AUCT['ShowVendorBuy'])) then
					TT_AddLine(string.format(_AUCT['FrmtInfoBuymult'], buyNote, count, bgsc), buy*count, embedded);
					TT_LineColor(0.8, 0.5, 0.1);
				end
				if (Auctioneer_GetFilter(_AUCT['ShowVendorSell'])) then
					TT_AddLine(string.format(_AUCT['FrmtInfoSellmult'], sellNote, count, sgsc), sell*count, embedded);
					TT_LineColor(0.8, 0.5, 0.1);
				end
			else
				if (Auctioneer_GetFilter(_AUCT['ShowVendorBuy'])) then
					TT_AddLine(string.format(_AUCT['FrmtInfoBuy'], buyNote), buy, embedded);
					TT_LineColor(0.8, 0.5, 0.1);
				end
				if (Auctioneer_GetFilter(_AUCT['ShowVendorSell'])) then
					TT_AddLine(string.format(_AUCT['FrmtInfoSell'], sellNote), sell, embedded);
					TT_LineColor(0.8, 0.5, 0.1);
				end
			end
		end
	end

	if (Auctioneer_GetFilter(_AUCT['ShowStack'])) then
		if (stacks > 1) then
			TT_AddLine(string.format(_AUCT['FrmtInfoStx'], stacks), nil, embedded);
		end
	end
	if (itemInfo and Auctioneer_GetFilter(_AUCT['ShowUsage'])) then
		local reagentInfo = "";
		if (itemInfo.classText) then
			reagentInfo = string.format(_AUCT['FrmtInfoClass'], itemInfo.classText);
			TT_AddLine(reagentInfo, nil, embedded);
			TT_LineColor(0.6, 0.4, 0.8);
		end
		if (itemInfo.usageText) then
			reagentInfo = string.format(_AUCT['FrmtInfoUse'], itemInfo.usageText);
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


