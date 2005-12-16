--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	Auctioneer tooltip functions.
	Functions to present and draw the tooltips.
	
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
		along with this program(see GLP.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]

function Auctioneer_HookTooltip(funcVars, retVal, frame, name, link, quality, count)
	EnhTooltip.DebugPrint("Displaying "..name)
	if (not link) then EnhTooltip.DebugPrint("No link was passed to the client");  return; end

	-- nothing to do, if auctioneer is disabled
	if (not Auctioneer_GetFilter("all")) then
		return;
	end;
	
	local auctKey = Auctioneer_GetAuctionKey();
	
	-- initialize local variables
	local itemID, randomProp, enchant, uniqID, lame = EnhTooltip.BreakLink(link);
	local itemKey = itemID..":"..randomProp..":"..enchant;
	local embedded = Auctioneer_GetFilter('embed');

	-- OUTPUT: seperator line
	if (embedded) then
		if (Auctioneer_GetFilter('show-embed-blankline')) then
			EnhTooltip.AddLine(" ", nil, embedded);
		end
	else
		EnhTooltip.AddLine(name, nil, embedded);
		EnhTooltip.LineQuality(quality);
	end

	if (Auctioneer_GetFilter('show-link')) then
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
			EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoNever'), _AUCT('TextAuction')), nil, embedded);
			EnhTooltip.LineColor(0.5, 0.8, 0.5);
		else -- (aCount > 0)
			-- calculate auction values
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

			if (Auctioneer_GetFilter('show-average')) then -- show item's average auction price
				-- OUTPUT: "Seen [aCount] times at auction total"
				EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoSeen'), aCount), nil, embedded);
				EnhTooltip.LineColor(0.5,0.8,0.1);
				if (not Auctioneer_GetFilter('show-verbose')) then -- default mode
					-- OUTPUT: "[avgMin] min/[avgBuy] BO ([avgBid] bid)"
					EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoAverage'), EnhTooltip.GetTextGSC(avgMin), EnhTooltip.GetTextGSC(avgBuy), EnhTooltip.GetTextGSC(avgBid)), nil, embedded);
					EnhTooltip.LineColor(0.1,0.8,0.5);
				else -- verbose mode
					if (count > 1) then
						-- OUTPUT: "Averages for [count] items:"
						EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoHeadMulti'), count), nil, embedded);
						EnhTooltip.LineColor(0.4,0.5,1.0);
						-- OUTPUT: "  Minimum ([avgMin] ea)"
						EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoMinMulti'), EnhTooltip.GetTextGSC(avgMin)), avgMin*count, embedded);
						EnhTooltip.LineColor(0.4,0.5,0.8);
						if (Auctioneer_GetFilter('show-stats')) then -- show buyout/bidded percentages
							-- OUTPUT: "  Bidded ([bidPct]%, [avgBid] ea)"
							EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoBidMulti'), bidPct.."%, ", EnhTooltip.GetTextGSC(avgBid)), avgBid*count, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.85);
							-- OUTPUT: "  Buyout ([buyPct]%, [avgBuy] ea)"
							EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoBuyMulti'), buyPct.."%, ", EnhTooltip.GetTextGSC(avgBuy)), avgBuy*count, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.9);
						else -- don't show buyout/bidded percentages
							-- OUTPUT: "  Bidded ([avgBid] ea)"
							EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoBidMulti'), "", EnhTooltip.GetTextGSC(avgBid)), avgBid*count, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.85);
							-- OUTPUT: "  Buyout ([avgBuy] ea)"
							EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoBuyMulti'), "", EnhTooltip.GetTextGSC(avgBuy)), avgBuy*count, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.9);
						end
						if (median) then
							-- OUTPUT: "  Buyout median"
							EnhTooltip.AddLine(_AUCT('FrmtInfoBuymedian'), median * count, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.95);
						end
					else -- (count = 0 | 1)
					   -- OUTPUT: "Averages for this item:"
						EnhTooltip.AddLine(_AUCT('FrmtInfoHeadOne'), nil, embedded);
						EnhTooltip.LineColor(0.4,0.5,1.0);
						-- OUTPUT: "  Minimum bid"
						EnhTooltip.AddLine(_AUCT('FrmtInfoMinOne'), avgMin, embedded);
						EnhTooltip.LineColor(0.4,0.5,0.8);
						if (Auctioneer_GetFilter('show-stats')) then -- show buyout/bidded percentages
							-- OUTPUT: "  Bidded [bidPct]%"
							EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoBidOne'), " "..bidPct.."%"), avgBid, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.85);
							-- OUTPUT: "  Buyout [buyPct]%"
							EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoBuyOne'), " "..buyPct.."%"), avgBuy, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.9);
						else -- don't show buyout/bidded percentages
						   -- OUTPUT: "  Bidded [bidPct]%"
							EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoBidOne'), ""), avgBid, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.85);
							-- OUTPUT: "  Buyout [buyPct]%"
							EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoBuyOne'), ""), avgBuy, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.9);
						end
						if (median) then
							-- OUTPUT: "  Buyout median"
							EnhTooltip.AddLine(_AUCT('FrmtInfoBuymedian'), median, embedded);
							EnhTooltip.LineColor(0.4,0.5,0.95);
						end
					end
				end

				if median and Auctioneer_GetFilter('show-median') then -- show item's median buyout price
					local historicalMedian, historicalMedCount = Auctioneer_GetItemHistoricalMedianBuyout(itemKey, auctKey);
					local snapshotMedian, snapshotMedCount = Auctioneer_GetItemSnapshotMedianBuyout(itemKey, auctKey);
					if historicalMedian and historicalMedCount > nullSafe(snapshotMedCount)  then
						-- OUTPUT: "Last [historicalMedCount], median BO (ea)"
						EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoHistmed'), historicalMedCount), historicalMedian, embedded)
						EnhTooltip.LineColor(0.1,0.8,0.5);
					end
					if snapshotMedian then
						-- OUTPUT: "Scanned [snapshotMedCount], median BO (ea)"
						EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoSnapmed'), snapshotMedCount), snapshotMedian, embedded)
						EnhTooltip.LineColor(0.1,0.8,0.5);
					end
				end
			end -- if(Auctioneer_GetFilter('show-average')) - show item's average auction price

			-- seperate line for suggested auction price (for clarification, even if the values have already been shown somewhere else
			if (Auctioneer_GetFilter('show-suggest')) then -- show item's suggested auction price
				local hsp, histCount, market, warn, nexthsp, nextwarn = Auctioneer_GetHSP(itemKey, auctKey);
				if hsp == 0 and buyCount > 0 then
					hsp = math.floor(buyPrice / buyCount); -- use mean buyout if median not available
				end
				local discountBidPercent = tonumber(Auctioneer_GetFilterVal('pct-bidmarkdown'));
				local countFix = count
				if countFix == 0 then
					countFix = 1
				end
				local buyPrice = Auctioneer_RoundDownTo95(nullSafe(hsp) * countFix);
				local bidPrice = Auctioneer_RoundDownTo95(Auctioneer_SubtractPercent(buyPrice, discountBidPercent));
				if (count > 1) then
					-- OUTPUT: "Suggested price for your [count] stack: [bidPrice] min/[buyPrice] BO"
					EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoSgststx'), count, EnhTooltip.GetTextGSC(bidPrice, true), EnhTooltip.GetTextGSC(buyPrice, true)), nil, embedded);
					EnhTooltip.LineColor(0.5,0.5,0.8);
				else -- count = 0 | 1
					-- OUTPUT: "Suggested price: [bidPrice] min/[buyPrice] BO"
					EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoSgst'), EnhTooltip.GetTextGSC(bidPrice, true), EnhTooltip.GetTextGSC(buyPrice, true)), nil, embedded);
					EnhTooltip.LineColor(0.5,0.5,0.8);
				end
				EnhTooltip.AddLine(warn);
				if (Auctioneer_GetFilter('warn-color')) then
					local FrmtWarnAbovemkt, FrmtWarnUndercut, FrmtWarnNocomp, FrmtWarnAbovemkt, FrmtWarnMarkup, FrmtWarnUser, FrmtWarnNodata, FrmtWarnMyprice

					FrmtWarnToolow = string.sub(_AUCT('FrmtWarnToolow'), 1, -5);
					FrmtWarnUndercut = string.sub(_AUCT('FrmtWarnUndercut'), 1, -5);
					FrmtWarnNocomp = string.sub(_AUCT('FrmtWarnNocomp'), 1, -5);
					FrmtWarnAbovemkt = string.sub(_AUCT('FrmtWarnAbovemkt'), 1, -5);
					FrmtWarnMarkup = string.sub(_AUCT('FrmtWarnMarkup'), 1, -5);
					FrmtWarnUser = string.sub(_AUCT('FrmtWarnUser'), 1, -5);
					FrmtWarnNodata = string.sub(_AUCT('FrmtWarnNodata'), 1, -5);
					FrmtWarnMyprice = string.sub(_AUCT('FrmtWarnMyprice'), 1, -5);

					if (string.find(warn, FrmtWarnToolow)) then
						--Color Red
						EnhTooltip.LineColor(1.0, 0.0, 0.0);

					elseif (string.find(warn, FrmtWarnUndercut)) then
						--Color Yellow
						EnhTooltip.LineColor(1.0, 1.0, 0.0);

					elseif (string.find(warn, FrmtWarnNocomp) or string.find(warn, FrmtWarnAbovemkt)) then
						--Color Green
						EnhTooltip.LineColor(0.0, 1.0, 0.0);

					elseif (string.find(warn, FrmtWarnMarkup) or string.find(warn, FrmtWarnUser) or string.find(warn, FrmtWarnNodata) or string.find(warn, FrmtWarnMyprice)) then
						--Color Gray
						EnhTooltip.LineColor(0.6, 0.6, 0.6);
					end

				else
					--Color Orange
					EnhTooltip.LineColor(0.9, 0.4, 0.0);
				end
			end
			if (not Auctioneer_GetFilter('show-verbose')) then
				if (Auctioneer_GetFilter('show-stats')) then -- show buyout/bidded percentages
					-- OUTPUT: "[bidPct]% have bid, [buyPct]% have BO"
					EnhTooltip.AddLine(string.format(_AUCT('FrmtInfoBidrate'), bidPct, buyPct), nil, embedded);
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
				EnhTooltip.AddLine(string.format(">> ".._AUCT('FrmtInfoNever'), also), nil, embedded);
				EnhTooltip.LineColor(0.5,0.8,0.1);
			else
				if (Auctioneer_GetFilter('show-average')) then
					EnhTooltip.AddLine(string.format(">> ".._AUCT('FrmtInfoAlsoseen'), aCount, also), nil, embedded);
					EnhTooltip.LineColor(0.5,0.8,0.1);
					EnhTooltip.AddLine(string.format(">> ".._AUCT('FrmtInfoAverage'), EnhTooltip.GetTextGSC(avgMin), EnhTooltip.GetTextGSC(avgBuy), EnhTooltip.GetTextGSC(avgBid)), nil, embedded);
					EnhTooltip.LineColor(0.1,0.8,0.5);
					if (Auctioneer_GetFilter('show-suggest')) then
						local hsp = Auctioneer_GetHSP(itemKey, also);
						if hsp == 0 and buyCount > 0 then
							hsp = math.floor(buyPrice / buyCount); -- use mean buyout if median not available
						end
						local discountBidPercent = tonumber(Auctioneer_GetFilterVal('pct-bidmarkdown'));
						local countFix = count
						if countFix == 0 then
							countFix = 1
						end
						local buyPrice = Auctioneer_RoundDownTo95(nullSafe(hsp) * countFix);
						local bidPrice = Auctioneer_RoundDownTo95(Auctioneer_SubtractPercent(buyPrice, discountBidPercent));
						if (count > 1) then
							-- OUTPUT: "Suggested price for your [count] stack: [bidPrice] min/[buyPrice] BO"
							EnhTooltip.AddLine(string.format(">> ".._AUCT('FrmtInfoSgststx'), count, EnhTooltip.GetTextGSC(bidPrice, true), EnhTooltip.GetTextGSC(buyPrice, true)), nil, embedded);
							EnhTooltip.LineColor(0.5,0.5,0.8);
						else -- count = 0 | 1
							-- OUTPUT: "Suggested price: [bidPrice] min/[buyPrice] BO"
							EnhTooltip.AddLine(string.format(">> ".._AUCT('FrmtInfoSgst'), EnhTooltip.GetTextGSC(bidPrice, true), EnhTooltip.GetTextGSC(buyPrice, true)), nil, embedded);
							EnhTooltip.LineColor(0.5,0.5,0.8);
						end
					end
				end
				if (Auctioneer_GetFilter('show-stats')) then
					EnhTooltip.AddLine(string.format(">> ".._AUCT('FrmtInfoBidrate'), bidPct, buyPct), nil, embedded);
					EnhTooltip.LineColor(0.1,0.5,0.8);
				end
			end
		end
	end -- if (itemID > 0)
end


