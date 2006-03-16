
function askPrice_onLoad()
	SLASH_ASKPRICE1 = "/askprice";
	SlashCmdList["ASKPRICE"] = askPrice_slashhandler;
	DEFAULT_CHAT_FRAME:AddMessage(ASKPRICE_LOADED_TEXT);
	this:RegisterEvent("CHAT_MSG_WHISPER");
	this:RegisterEvent("CHAT_MSG_PARTY");
	this:RegisterEvent("CHAT_MSG_GUILD");
end

function askPrice_getOption(option)
	-- returns (ON) or (OFF)
	if (option) then
		return "\(" .. ASKPRICE_ON .. "\)"
	else
		return "\(" .. ASKPRICE_OFF .. "\)"
	end
end

function askPrice_slashhandler(cmd)
  if (string.find(cmd, 'help') or cmd == '') then
		DEFAULT_CHAT_FRAME:AddMessage(ASKPRICE_HELP_TEXT);
		DEFAULT_CHAT_FRAME:AddMessage(ASKPRICE_HELP_VENDOR .. askPrice_getOption(AP_ShowVendor));
		DEFAULT_CHAT_FRAME:AddMessage(ASKPRICE_HELP_GUILD .. askPrice_getOption(AP_guild));
		DEFAULT_CHAT_FRAME:AddMessage(ASKPRICE_HELP_PARTY .. askPrice_getOption(AP_party));
		DEFAULT_CHAT_FRAME:AddMessage(ASKPRICE_HELP_SMART .. askPrice_getOption(AP_smartWords));
	end

	if string.find(cmd, 'vendor') then
		if (AP_ShowVendor) then
			DEFAULT_CHAT_FRAME:AddMessage('AskPrice: ' .. ASKPRICE_VENDORPRICE .. ASKPRICE_OFF);
			AP_ShowVendor = nil;
		else
			DEFAULT_CHAT_FRAME:AddMessage('AskPrice: ' .. ASKPRICE_VENDORPRICE .. ASKPRICE_ON);
			AP_ShowVendor = 1;

		end
	end

	if string.find(cmd, 'party') then
		if (AP_party) then
			DEFAULT_CHAT_FRAME:AddMessage('AskPrice: ' .. ASKPRICE_PARTY .. ASKPRICE_OFF);
			AP_party = nil;
		else
			DEFAULT_CHAT_FRAME:AddMessage('AskPrice: ' .. ASKPRICE_PARTY .. ASKPRICE_ON);
			AP_party = 1;

		end
	end

	if string.find(cmd, 'guild') then
		if (AP_guild) then
			DEFAULT_CHAT_FRAME:AddMessage('AskPrice: ' .. ASKPRICE_GUILD .. ASKPRICE_OFF);
			AP_guild = nil;
		else
			DEFAULT_CHAT_FRAME:AddMessage('AskPrice: ' .. ASKPRICE_GUILD .. ASKPRICE_ON);
			AP_guild = 1;
		end
	end

	if string.find(cmd, 'smart') then
		if (AP_smartWords) then
			DEFAULT_CHAT_FRAME:AddMessage('AskPrice: ' .. "SmartWords: " .. ASKPRICE_OFF);
			AP_smartWords = nil;
		else
			DEFAULT_CHAT_FRAME:AddMessage('AskPrice: ' .. "SmartWords: " .. ASKPRICE_ON .. " (" .. ASKPRICE_SMARTWORD1 .. ", " .. ASKPRICE_SMARTWORD2 .. ")" );
			AP_smartWords = 1;
		end
	end

	if string.find(cmd, 'ad') then
		if (AP_smartWords) then
			DEFAULT_CHAT_FRAME:AddMessage('AskPrice: ' .. "Ad: " .. ASKPRICE_OFF);
			AP_ad = nil;
		else
			DEFAULT_CHAT_FRAME:AddMessage('AskPrice: ' .. "Ad: " .. ASKPRICE_ON);
			AP_ad = 1;
		end
	end

end

function getGSC(money)
	if (money == nil) then money = 0 end
	local g = math.floor(money / 10000)
	local s = math.floor((money - (g*10000)) / 100)
	local c = math.floor(money - (g*10000) - (s*100))


	local moneyText = "";
	if (g > 0) then moneyText = moneyText .. g .. "g";end;
	if (s > 0) then moneyText = moneyText .. s .. "s";end;
	if (c > 0) then moneyText = moneyText .. c .. "c";end;
	return moneyText;
end

function auctioneerOO(itemLink, player)

	-- nothing to do, if auctioneer is disabled
	if (not Auctioneer.Command.GetFilter("all")) then
		SendChatMessage(ASKPRICE_AUCT_NOT_LOADED, "WHISPER", ASKPRICE_WHISPERLANGUAGE, player);
		return;
	end;

	local itemID, randomProp, enchant, uniqID, lame = EnhTooltip.BreakLink(itemLink);


	local auctKey = Auctioneer.Util.GetAuctionKey();
	local itemKey = itemID..":"..randomProp..":"..enchant;

	local auctionPriceItem = Auctioneer.Core.GetAuctionPriceItem(itemKey, auctKey);
	local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = Auctioneer.Core.GetAuctionPrices(auctionPriceItem.data);
	local historicalMedian, historicalMedCount = Auctioneer.Statistic.GetItemHistoricalMedianBuyout(itemKey, auctKey);
	local snapshotMedian, snapshotMedCount = Auctioneer.Statistic.GetItemSnapshotMedianBuyout(itemKey, auctKey);
	local median, medCount = Auctioneer.Statistic.GetUsableMedian(itemKey, auctKey);

	-- DEFAULT_CHAT_FRAME:AddMessage(itemID..":"..randomProp..":"..enchant..":"..uniqID..":"..lame);

	if (aCount == 0) then

		-- OUTPUT: "Never seen at auction"
		SendChatMessage(ASKPRICE_NEVER_SEEN, "WHISPER", ASKPRICE_WHISPERLANGUAGE, player);
		return 0, 0, 0;

	end;

	-- show auction info
	if (aCount > 0) then
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
	end

	return aCount, historicalMedian, snapshotMedian;

end

function auctioneerFO(itemLink, player)

	-- nothing to do, if auctioneer is disabled
	if (not Auctioneer_GetFilter("all")) then
		SendChatMessage(ASKPRICE_AUCT_NOT_LOADED, "WHISPER", ASKPRICE_WHISPERLANGUAGE, player);
		return;
	end;

	local itemID, randomProp, enchant, uniqID, lame = EnhTooltip.BreakLink(itemLink);

	local auctKey = Auctioneer_GetAuctionKey();
	local itemKey = itemID..":"..randomProp..":"..enchant;

	local auctionPriceItem = Auctioneer_GetAuctionPriceItem(itemKey, auctKey);
	local aCount,minCount,minPrice,bidCount,bidPrice,buyCount,buyPrice = Auctioneer_GetAuctionPrices(auctionPriceItem.data);
	local historicalMedian, historicalMedCount = Auctioneer_GetItemHistoricalMedianBuyout(itemKey, auctKey);
	local snapshotMedian, snapshotMedCount = Auctioneer_GetItemSnapshotMedianBuyout(itemKey, auctKey);
	local median, medCount = Auctioneer_GetUsableMedian(itemKey, auctKey);

	-- DEFAULT_CHAT_FRAME:AddMessage(itemID..":"..randomProp..":"..enchant..":"..uniqID..":"..lame);

	if (aCount == 0) then

		-- OUTPUT: "Never seen at auction"
		SendChatMessage(ASKPRICE_NEVER_SEEN, "WHISPER", ASKPRICE_WHISPERLANGUAGE, player);
		return 0, 0, 0;

	end;

	-- show auction info
	if (aCount > 0) then
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
	end

	return aCount, historicalMedian, snapshotMedian;

end

function askPrice_getVendorPrice(itemLink, count, player)

  -- Thanks Tarog for "decrypting" informant :)
	local itemID = EnhTooltip.BreakLink(itemLink);
	local itemInfo = Informant.GetItem(itemID);
	local vendorSell = 0;
	if (itemInfo) then
		vendorSell = tonumber(itemInfo.sell) or 0
	end
	local eachstring = "";
  if (count ~= 1) then
		eachstring = " \(" .. getGSC(vendorSell) .. ASKPRICE_EACH .. "\)";
  end

	SendChatMessage("" .. ASKPRICE_VENDORPRICE .. getGSC(vendorSell * count) .. eachstring, "WHISPER", ASKPRICE_WHISPERLANGUAGE, player);

	return vendorSell;

end


function askPrice_onEvent()

if ((event == "CHAT_MSG_WHISPER") or ((event== "CHAT_MSG_GUILD") and AP_guild) or ((event == "CHAT_MSG_PARTY") and AP_party)) then
    -- DEFAULT_CHAT_FRAME:AddMessage("!!!Whisper!!!");
    local text = arg1;
    local player = arg2;
    local itemLink = string.sub(text, 2);
		local askedCount = 0;


    -- check for marker (? or "smart" words)
	  -- if activatet, check for "smart" words
  	-- alter ASKPRICE_SMARTWORD1, ASKPRICE_SMARTWORD2 in localization.lua to your needs

    if (string.sub(text, 1, 1) ~= "?") then
      if (AP_smartWords) then
          if (not (string.find(text, ASKPRICE_SMARTWORD1) and string.find(text, ASKPRICE_SMARTWORD2))) then
            return;
          end
      end
      if (not AP_smartWords) then
          return;
      end
    end

  -- check for itemlink after ?
    if (not (string.find(itemLink, "|Hitem:"))) then
      return;
    end

    _, _, askedCount = string.find(text, "%?(%d+)");
    askedCount = tonumber(askedCount);
    if (not askedCount) then askedCount = 1; end

    -- check faction
    if (UnitFactionGroup("player") == "Alliance") then
			ASKPRICE_WHISPERLANGUAGE = ASKPRICE_WHISPERLANGUAGE_ALLIANCE;
    else
			ASKPRICE_WHISPERLANGUAGE = ASKPRICE_WHISPERLANGUAGE_HORDE;
    end

    -- DEFAULT_CHAT_FRAME:AddMessage(ASKPRICE_WHISPERLANGUAGE);
    local aCount, historicalMedian, snapshotMedian, vendorSell;

    -- check auctioneer version (Object Oriented or Function Oriented)
    if (Auctioneer.Version) then aCount, historicalMedian, snapshotMedian = auctioneerOO(itemLink, player); end
    if (AUCTIONEER_VERSION) then aCount, historicalMedian, snapshotMedian = auctioneerFO(itemLink, player); end

  local eachstring;

  if (askedCount ~= 1) then
		eachstring = " \(" .. getGSC(historicalMedian) .. ASKPRICE_EACH .. "\)";
  else
  	eachstring = "";
  end
  
  if (aCount and aCount ~= 0) then
		SendChatMessage(aCount .. ASKPRICE_TIMES_SEEN, "WHISPER", ASKPRICE_WHISPERLANGUAGE, player);
		SendChatMessage("  " .. ASKPRICE_BUYOUT_MEDIAN_HISTORICAL .. getGSC(historicalMedian*askedCount) .. eachstring,  "WHISPER", ASKPRICE_WHISPERLANGUAGE, player);
		SendChatMessage("  " .. ASKPRICE_BUYOUT_LASTSCAN .. getGSC(snapshotMedian*askedCount) .. eachstring, "WHISPER", ASKPRICE_WHISPERLANGUAGE, player);
	end

	if (AP_ShowVendor) then
		askPrice_getVendorPrice(itemLink, askedCount, player);
	end	

	if ((askedCount == 1) and (AP_ad)) then
		SendChatMessage(ASKPRICE_AD, ASKPRICE_WHISPERLANGUAGE, player)
	end
	
end
end