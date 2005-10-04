--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	Auctioneer tooltip functions.
	Functions to present and draw the tooltips.
]]

function Auctioneer_HookTooltip(frame, name, link, quality, count)
	if (not link) then Auctioneer_p("No link was passed to the client");  return; end

	-- nothing to do, if auctioneer is disabled
	if (not Auctioneer_GetFilter("all")) then
		return;
	end;
	
	local auctKey = Auctioneer_GetAuctionKey();
	
	-- initialize local variables
	local itemID, randomProp, enchant, uniqID, lame = EnhTooltip.BreakLink(link);
	local itemKey = itemID..":"..randomProp..":"..enchant;
	local embedded = Auctioneer_GetFilter(_AUCT['CmdEmbed']);

	-- OUTPUT: seperator line
	if (embedded) then
		if (Auctioneer_GetFilter(_AUCT['ShowEmbedBlank'])) then
			EnhTooltip.AddLine(" ", nil, embedded);
		end
	else
		EnhTooltip.AddLine(name, nil, embedded);
		EnhTooltip.LineQuality(quality);
	end

	if (Auctioneer_GetFilter(_AUCT['ShowLink'])) then
		-- OUTPUT: show item link
		EnhTooltip.AddLine("Link: " .. itemKey .. ":" .. uniqID, nil, embedded);
		EnhTooltip.LineQuality(quality);
	end

	local itemInfo = nil;

	-- show item info
	if (itemID > 0) then
		frame.eDone = 1;
		local auctionPriceItem = Auctioneer_GetAuctionPriceItem(itemKey, auctKey);
		local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = Auctioneer_GetAuctionPrices(auctionPriceItem.data);

		-- show auction info
		if (aCount == 0) then
			-- OUTPUT: "Never seen at auction"
			EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoNever'], _AUCT['TextAuction']), nil, embedded);
			EnhTooltip.LineColor(0.5, 0.8, 0.5);
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
				EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoSeen'], aCount), nil, embedded);
				EnhTooltip.LineColor(0.5,0.8,0.1);
				if (not Auctioneer_GetFilter(_AUCT['ShowVerbose'])) then -- default mode
					if (avgQty > 1) then
						-- OUTPUT: "For 1: [avgMin] min/[avgBuy] BO ([avgBid] bid) [in [avgQty]'s]"
						EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoForone'], EnhTooltip.GetTextGSC(avgMin), EnhTooltip.GetTextGSC(avgBuy), EnhTooltip.GetTextGSC(avgBid), avgQty), nil, embedded);
						EnhTooltip.LineColor(0.1,0.8,0.5);
					else -- (avgQty = 1)
						-- OUTPUT: "[avgMin] min/[avgBuy] BO ([avgBid] bid)"
						EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoAverage'], EnhTooltip.GetTextGSC(avgMin), EnhTooltip.GetTextGSC(avgBuy), EnhTooltip.GetTextGSC(avgBid)), nil, embedded);
						EnhTooltip.LineColor(0.1,0.8,0.5);
					end
				else -- verbose mode
					if (count > 1) then
						-- OUTPUT: "Averages for [count] items:"
						EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoHeadMulti'], count), nil, embedded);
						EnhTooltip.LineColor(0.4,0.5,1.0);
						-- OUTPUT: "  Minimum ([avgMin] ea)"
						EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoMinMulti'], EnhTooltip.GetTextGSC(avgMin)), avgMin*count, embedded);
						EnhTooltip.LineColor(0.4,0.5,0.8);
						if (Auctioneer_GetFilter(_AUCT['ShowStats'])) then -- show buyout/bidded percentages
							-- OUTPUT: "  Bidded ([bidPct]%, [avgBid] ea)"
							EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoBidMulti'], bidPct.."%, ", EnhTooltip.GetTextGSC(avgBid)), avgBid*count, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.85);
							-- OUTPUT: "  Buyout ([buyPct]%, [avgBuy] ea)"
							EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoBuyMulti'], buyPct.."%, ", EnhTooltip.GetTextGSC(avgBuy)), avgBuy*count, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.9);
						else -- don't show buyout/bidded percentages
							-- OUTPUT: "  Bidded ([avgBid] ea)"
							EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoBidMulti'], "", EnhTooltip.GetTextGSC(avgBid)), avgBid*count, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.85);
							-- OUTPUT: "  Buyout ([avgBuy] ea)"
							EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoBuyMulti'], "", EnhTooltip.GetTextGSC(avgBuy)), avgBuy*count, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.9);
						end
						if (median) then
							-- OUTPUT: "  Buyout median"
							EnhTooltip.AddLine(_AUCT['FrmtInfoBuymedian'], median * count, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.95);
						end
					else -- (count = 0 | 1)
					   -- OUTPUT: "Averages for this item:"
						EnhTooltip.AddLine(_AUCT['FrmtInfoHeadOne'], nil, embedded);
						EnhTooltip.LineColor(0.4,0.5,1.0);
						-- OUTPUT: "  Minimum bid"
						EnhTooltip.AddLine(_AUCT['FrmtInfoMinOne'], avgMin, embedded);
						EnhTooltip.LineColor(0.4,0.5,0.8);
						if (Auctioneer_GetFilter(_AUCT['ShowStats'])) then -- show buyout/bidded percentages
							-- OUTPUT: "  Bidded [bidPct]%"
							EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoBidOne'], " "..bidPct.."%"), avgBid, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.85);
							-- OUTPUT: "  Buyout [buyPct]%"
							EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoBuyOne'], " "..buyPct.."%"), avgBuy, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.9);
						else -- don't show buyout/bidded percentages
						   -- OUTPUT: "  Bidded [bidPct]%"
							EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoBidOne'], ""), avgBid, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.85);
							-- OUTPUT: "  Buyout [buyPct]%"
							EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoBuyOne'], ""), avgBuy, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.9);
						end
						if (median) then
							-- OUTPUT: "  Buyout median"
							EnhTooltip.AddLine(_AUCT['FrmtInfoBuymedian'], median, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.95);
						end
					end
					if (avgQty > 1) then
						-- OUTPUT: "  Average stack size: [avgQty] items"
						EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoStacksize'], avgQty), nil, embedded);
						EnhTooltip.LineColor(0.4,0.5,1.0);
					end
				end

				if median and Auctioneer_GetFilter(_AUCT['ShowMedian']) then -- show item's median buyout price
					local historicalMedian, historicalMedCount = Auctioneer_GetItemHistoricalMedianBuyout(itemKey, auctKey);
					local snapshotMedian, snapshotMedCount = Auctioneer_GetItemSnapshotMedianBuyout(itemKey, auctKey);
					if historicalMedian and historicalMedCount > nullSafe(snapshotMedCount)  then
						-- OUTPUT: "Last [historicalMedCount], median BO (ea)"
						EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoHistmed'], historicalMedCount), historicalMedian, embedded)
						EnhTooltip.LineColor(0.1,0.8,0.5);
					end
					if snapshotMedian then
						-- OUTPUT: "Scanned [snapshotMedCount], median BO (ea)"
						EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoSnapmed'], snapshotMedCount), snapshotMedian, embedded)
						EnhTooltip.LineColor(0.1,0.8,0.5);
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
					EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoSgststx'], count, EnhTooltip.GetTextGSC(bidPrice, true), EnhTooltip.GetTextGSC(buyPrice, true)), nil, embedded);
					EnhTooltip.LineColor(0.5,0.5,0.8);
				else -- count = 0 | 1
					-- OUTPUT: "Suggested price: [bidPrice] min/[buyPrice] BO"
					EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoSgst'], EnhTooltip.GetTextGSC(bidPrice, true), EnhTooltip.GetTextGSC(buyPrice, true)), nil, embedded);
					EnhTooltip.LineColor(0.5,0.5,0.8);
				end
			end
			if (not Auctioneer_GetFilter(_AUCT['ShowVerbose'])) then
				if (Auctioneer_GetFilter(_AUCT['ShowStats'])) then -- show buyout/bidded percentages
					-- OUTPUT: "[bidPct]% have bid, [buyPct]% have BO"
					EnhTooltip.AddLine(string.format(_AUCT['FrmtInfoBidrate'], bidPct, buyPct), nil, embedded);
					EnhTooltip.LineColor(0.1,0.5,0.8);
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
				EnhTooltip.AddLine(string.format(">> ".._AUCT['FrmtInfoNever'], also), nil, embedded);
				EnhTooltip.LineColor(0.5,0.8,0.1);
			else
				if (Auctioneer_GetFilter(_AUCT['ShowAverage'])) then
					EnhTooltip.AddLine(string.format(">> ".._AUCT['FrmtInfoAlsoseen'], aCount, also), nil, embedded);
					EnhTooltip.LineColor(0.5,0.8,0.1);
					if (avgQty > 1) then
						EnhTooltip.AddLine(string.format(">> ".._AUCT['FrmtInfoForone'], EnhTooltip.GetTextGSC(avgMin), EnhTooltip.GetTextGSC(avgBuy), EnhTooltip.GetTextGSC(avgBid), avgQty), nil, embedded);
						EnhTooltip.LineColor(0.1,0.8,0.5);
					else
						EnhTooltip.AddLine(string.format(">> ".._AUCT['FrmtInfoAverage'], EnhTooltip.GetTextGSC(avgMin), EnhTooltip.GetTextGSC(avgBuy), EnhTooltip.GetTextGSC(avgBid)), nil, embedded);
						EnhTooltip.LineColor(0.1,0.8,0.5);
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
							EnhTooltip.AddLine(string.format(">> ".._AUCT['FrmtInfoSgststx'], count, EnhTooltip.GetTextGSC(bidPrice, true), EnhTooltip.GetTextGSC(buyPrice, true)), nil, embedded);
							EnhTooltip.LineColor(0.5,0.5,0.8);
						else -- count = 0 | 1
							-- OUTPUT: "Suggested price: [bidPrice] min/[buyPrice] BO"
							EnhTooltip.AddLine(string.format(">> ".._AUCT['FrmtInfoSgst'], EnhTooltip.GetTextGSC(bidPrice, true), EnhTooltip.GetTextGSC(buyPrice, true)), nil, embedded);
							EnhTooltip.LineColor(0.5,0.5,0.8);
						end
					end
				end
				if (Auctioneer_GetFilter(_AUCT['ShowStats'])) then
					EnhTooltip.AddLine(string.format(">> ".._AUCT['FrmtInfoBidrate'], bidPct, buyPct), nil, embedded);
					EnhTooltip.LineColor(0.1,0.5,0.8);
				end
			end
		end
	end -- if (itemID > 0)
end


