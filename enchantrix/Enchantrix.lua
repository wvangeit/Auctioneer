--[[

Enchantrix v<%version%>
$Id$

By Norganna
http://enchantrix.org/

This is an addon for World of Warcraft that add a list of what an item 
disenchants into to the items that you mouse-over in the game.

]]
ENCHANTRIX_VERSION = "<%version%>";

-- GUI Init Variables (Added by MentalPower)
Enchantrix_GUI_Registered = nil;
Enchantrix_Khaos_Registered = nil;

EnchantedLocal = {};
EnchantConfig = {};

-- These are market norm prices.
Enchantrix_StaticPrices = {
	[11082] =  7500, -- Greater Astral Essence
	[16203] = 35000, -- Greater Eternal Essence
	[10939] =  3500, -- Greater Magic Essence
	[11135] =  8500, -- Greater Mystic Essence
	[11175] = 30000, -- Greater Nether Essence
	[10998] =  3500, -- Lesser Astral Essence
	[16202] = 10000, -- Lesser Eternal Essence
	[10938] =  1000, -- Lesser Magic Essence
	[11134] =  4000, -- Lesser Mystic Essence
	[11174] = 12000, -- Lesser Nether Essence
	[14344] = 50000, -- Large Brilliant Shard
	[11084] = 10000, -- Large Glimmering Shard
	[11139] = 24500, -- Large Glowing Shard
	[11178] = 70000, -- Large Radiant Shard
	[14343] = 43500, -- Small Brilliant Shard
	[10978] =  3500, -- Small Glimmering Shard
	[11138] =  9000, -- Small Glowing Shard
	[11177] = 32500, -- Small Radiant Shard
	[11176] =  5000, -- Dream Dust
	[16204] = 12500, -- Illusion Dust
	[11083] =   800, -- Soul Dust
	[10940] =   600, -- Strange Dust
	[11137] =  1600, -- Vision Dust
}

-- Default filter configuration
Enchantrix_FilterDefaults = {
		['all'] = 'on',
		['embed'] = 'off',
		['counts'] = 'off',
		['header'] = 'on',
		['rates'] = 'on',
		['valuate'] = 'on',
		['valuate-hsp'] = 'on',
		['valuate-median'] = 'on',
		['valuate-baseline'] = 'on',
		['locale'] = 'default',
		['printframe'] = 1,
	}

local ItemEssences = {};
for name, id in EssenceItemIDs do
	ItemEssences[id] = name;
end


local MAX_BUYOUT_PRICE = 800000;

local MIN_PROFIT_MARGIN = 1000;
local MIN_PERCENT_LESS_THAN_HSP = 20; -- 20% default
local MIN_PROFIT_PRICE_PERCENT = 10; -- 10% default


if (ENCHANTRIX_VERSION == "<".."%version%>") then
	ENCHANTRIX_VERSION = "3.1.DEV";
end

function Enchantrix_CheckTooltipInfo(frame)
	-- If we've already added our information, no need to do it again
	if ( not frame or frame.eDone ) then
		return nil;
	end

	lEnchantrixTooltip = frame;

	if( frame:IsVisible() ) then
		local field = getglobal(frame:GetName().."TextLeft1");
		if( field and field:IsVisible() ) then
			local name = field:GetText();
			if( name ) then
				Enchantrix_AddTooltipInfo(frame, name);
				return nil;
			end
		end
	end
	
	return 1;
end

function Enchantrix_HookTooltip(funcVars, retVal, frame, name, link, quality, count)
	local embed = Enchantrix_GetFilter('embed');

	local sig, sigNR = Enchantrix_SigFromLink(link);

	local _,_,data = Enchantrix_FindSigInBags(sig);
	if (not data) then _,_,data = Enchantrix_FindSigInBags(sigNR); end


	-- Check for correct item quality
	if (data) then
		if (data.quality > -1) and (data.quality < 2) then
			-- The item data says the quality is not right, zero it out.
			EnchantedLocal[sig] = { z = true; };
			EnchantedLocal[sigNR] = { z = true; };
		end
	else
		-- We can't get definative proof that this item is not disenchant quality, 
		-- but the tooltip says it's not good enough quality though so don't display it.
		if (quality) and (quality > -1) and (quality < 2) then return; end
	end

	local disenchantsTo = Enchantrix_GetItemDisenchants(sig, sigNR, name, true);

	local itemID = Enchantrix_BreakLink(link);
	if (Enchantrix_StaticPrices[itemID]) then return end

	-- Process the results
	local totals = disenchantsTo.totals;
	disenchantsTo.totals = nil;
	if (totals and totals.total > 0) then

		-- If it looks quirky, and we haven't disenchanted it, then ignore it...
		if (totals.bCount < 10) and (totals.iCount + totals.biCount < 1) then return; end

		local total = totals.total;
		local note = "";
		if (not totals.exact) then note = "*"; end

		EnhTooltip.AddLine(ENCH_FRMT_DISINTO..note, nil, embed);
		EnhTooltip.LineColor(0.8,0.8,0.2);
		for dSig, counts in disenchantsTo do
			if (counts.rate > 1) then
				EnhTooltip.AddLine(string.format("  %s: %0.1f%% x%0.1f", counts.name, counts.pct, counts.rate), nil, embed);
			else
				EnhTooltip.AddLine(string.format("  %s: %0.1f%%", counts.name, counts.pct), nil, embed);
			end
			EnhTooltip.LineColor(0.6,0.6,0.1);

			if (Enchantrix_GetFilter('counts')) then
				EnhTooltip.AddLine(string.format(ENCH_FRMT_COUNTS, counts.bCount, counts.oCount, counts.dCount), nil, embed);
				EnhTooltip.LineColor(0.5,0.5,0.0);
			end
		end

		if (Enchantrix_GetFilter('valuate')) then
			local confidence = totals.conf;

			if (Enchantrix_GetFilter('valuate-hsp') and totals.hspValue > 0) then
				EnhTooltip.AddLine(ENCH_FRMT_VALUE_AUCT_HSP, totals.hspValue * confidence, embed);
				EnhTooltip.LineColor(0.1,0.6,0.6);
			end
			if (Enchantrix_GetFilter('valuate-median') and totals.medValue > 0) then
				EnhTooltip.AddLine(ENCH_FRMT_VALUE_AUCT_MED, totals.medValue * confidence, embed);
				EnhTooltip.LineColor(0.1,0.6,0.6);
			end
			if (Enchantrix_GetFilter('valuate-baseline') and totals.mktValue > 0) then
				EnhTooltip.AddLine(ENCH_FRMT_VALUE_MARKET, totals.mktValue * confidence, embed);
				EnhTooltip.LineColor(0.1,0.6,0.6);
			end
		end
	end
end

function Enchantrix_NameFromLink(link)
	local name;
	if( not link ) then
		return nil;
	end
	for name in string.gfind(link, "|c%x+|Hitem:%d+:%d+:%d+:%d+|h%[(.-)%]|h|r") do
		return name;
	end
	return nil;
end

function Enchantrix_SigFromLink(link)
	local name;
	if( not link ) then
		return nil;
	end
	for id,enchant,rand in string.gfind(link, "|c%x+|Hitem:(%d+):(%d+):(%d+):%d+|h%[.-%]|h|r") do
		local sig = string.format("%s:%s:%s", id, 0, rand);
		local sigNR = string.format("%s:%s:%s", id, 0, 0);
		return sig, sigNR;
	end
	return nil;
end

function Enchantrix_TakeInventory()
	local bagid, slotid, size;
	local inventory = {};

	for bagid = 0, 4, 1 do
		inventory[bagid] = {};

		size = GetContainerNumSlots(bagid);
		if( size ) then
			for slotid = size, 1, -1 do
				inventory[bagid][slotid] = {};

				local link = GetContainerItemLink(bagid, slotid);
				if( link ) then
					local name = Enchantrix_NameFromLink(link);
					local sig = Enchantrix_SigFromLink(link);
					local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bagid, slotid);
					if (quality > -1) and (quality < 2) and (DisenchantList[sig]) then 
						EnchantedLocal = { z = true; };
					end
					if ((not itemCount) or (itemCount < 1)) then
						itemCount = 1;
					end
					if (name) then
						inventory[bagid][slotid].name = name;
						inventory[bagid][slotid].tx = texture;
						inventory[bagid][slotid].sig = sig;
						inventory[bagid][slotid].link = link;
						inventory[bagid][slotid].count = itemCount;
					end
				end
			end
		end
	end
	return inventory;
end

function Enchantrix_FullDiff(invA, invB)
	local bagid, slotid, size;
	local diffData = {};
	local aStuff = {};
	local bStuff = {};

	for bag, bagStuff in invA do
		for slot, slotStuff in bagStuff do
			if (slotStuff.sig) then
				if (not aStuff[slotStuff.sig]) then
					aStuff[slotStuff.sig] = { c=slotStuff.count, n=slotStuff.name, t=slotStuff.tx, l=slotStuff.link };
				else
					aStuff[slotStuff.sig].c = aStuff[slotStuff.sig].c + slotStuff.count;
				end
			end
		end
	end
	for bag, bagStuff in invB do
		for slot, slotStuff in bagStuff do
			if (slotStuff.sig) then
				if (not bStuff[slotStuff.sig]) then
					bStuff[slotStuff.sig] = { c=slotStuff.count, n=slotStuff.name, t=slotStuff.tx, l=slotStuff.link };
				else
					bStuff[slotStuff.sig].c = bStuff[slotStuff.sig].c + slotStuff.count;
				end
			end
		end
	end

	for sig, slotStuff in aStuff do
		local count = slotStuff.c;
		local bCount;
		if (bStuff[sig]) then bCount = bStuff[sig].c; end
		if (bCount == nil) then bCount = 0; end
		if (bCount < count) then
			local diffCount = bCount - count;
			diffData[sig] = { s=sig, d=diffCount, n=slotStuff.n, t=slotStuff.t, l=slotStuff.l };
		end
	end
	for sig, slotStuff in bStuff do
		local count = slotStuff.c;
		local aCount;
		if (aStuff[sig]) then aCount = aStuff[sig].c; end
		if (aCount == nil) then aCount = 0; end
		if (aCount < count) then
			local diffCount = count - aCount;
			diffData[sig] = { s=sig, d=diffCount, n=slotStuff.n, t=slotStuff.t, l=slotStuff.l };
		end
	end
	return diffData;
end

function Enchantrix_OnEvent(funcVars, event, argument)
	
	if ((event == "SPELLCAST_START") and (argument == ENCH_ARG_SPELLNAME)) then
		Enchantrix_Disenchanting = true;
		Enchantrix_WaitingPush = false;
		Enchantrix_StartInv = Enchantrix_TakeInventory();
		Enchantrix_Disenchants = {};

		return;
	end
	if ((event == "SPELLCAST_FAILED") or (event == "SPELLCAST_INTERRUPTED")) then
		Enchantrix_Disenchanting = false;
		Enchantrix_WaitingPush = false;
		return;
	end
	if ((event == "SPELLCAST_STOP") and (Enchantrix_Disenchanting)) then
		Enchantrix_Disenchanting = false;
		Enchantrix_WaitingPush = true;
		return;
	end
	if ((event == "ITEM_PUSH") and (Enchantrix_WaitingPush)) then
		local textureType = strsub(arg2, 1, 28);
		local receivedItem = strsub(arg2, 29);
		if (not receivedItem) then return; end
		if (textureType == "Interface\\Icons\\INV_Enchant_") then
			Enchantrix_Disenchants[arg2] = receivedItem;
			Enchantrix_Disenchants.exists = true;
		end
		return;
	end
	if ((event == "BAG_UPDATE") and (Enchantrix_Disenchants and Enchantrix_Disenchants.exists)) then
		
		-- /script inv = Enchantrix_TakeInventory()
		-- /script p(Enchantrix_FullDiff(inv, Enchantrix_TakeInventory()))
		-- /script p(Enchantrix_FullDiff(Enchantrix_StartInv, Enchantrix_TakeInventory()))
		local nowInv = Enchantrix_TakeInventory();
		local invDiff = Enchantrix_FullDiff(Enchantrix_StartInv, nowInv);

		local foundItem = "";
		for sig, data in invDiff do
			if (data.d == -1) then
				if (foundItem ~= "") then
					-- Unable to determine which item was disenchanted, ignore DE to avoid incorrect data
					Enchantrix_Disenchants = {};
					Enchantrix_Disenchanting = false;
					Enchantrix_WaitingPush = false;					
					return;
				end					
				foundItem = data;
			end
		end
		if (foundItem == "") then return; end
		
		local gainedItem = {};
		for sig, data in invDiff do
			if (data.d > 0) and (Enchantrix_Disenchants[data.t]) then
				gainedItem[sig] = data;
			end
		end
		if (next(gainedItem) == nil) then return; end
		
		if (EnchantedLocal[foundItem.n]) then
			EnchantedLocal[foundItem.s] = { o = ""..EnchantedLocal[foundItem.n] };
		end

		local itemData = Enchantrix_GetLocal(foundItem.s);
		
		DEFAULT_CHAT_FRAME:AddMessage(string.format(ENCH_FRMT_FOUND, foundItem.l), 0.8, 0.8, 0.2);
		for sig, data in gainedItem do
			local i,j, strItemID = string.find(sig, "^(%d+):");
			local itemID = 0;
			if (strItemID) then itemID = tonumber(strItemID); end
			if (itemID > 0) and (ItemEssences[itemID]) then
				-- We are interested cause this is an essence that was gained since last snaphot
				local iCount = 0; local dCount = 0;
				local curData = itemData[itemID];
				if (curData == nil) then curData = {}; end
				if (curData.i) then iCount = tonumber(curData.i); end
				if (curData.d) then dCount = tonumber(curData.d); end
				curData.i = ""..(iCount + 1);
				curData.d = ""..(dCount + data.d);
				itemData[itemID] = curData;
				DEFAULT_CHAT_FRAME:AddMessage("  " .. data.n .. " x" .. data.d, 0.6, 0.6, 0.1);
			end
		end
		
		Enchantrix_SaveLocal(foundItem.s, itemData);

		Enchantrix_Disenchants = {};
		Enchantrix_Disenchanting = false;
		Enchantrix_WaitingPush = false;
		
		return
	end
end

function Enchantrix_ChatPrint(str)
	if getglobal("ChatFrame"..Enchantrix_GetFrameIndex()) then
		getglobal("ChatFrame"..Enchantrix_GetFrameIndex()):AddMessage(str, 1.0, 0.5, 0.25);
	end
end

function Enchantrix_OnLoad()
	-- Hook in new tooltip code
	Stubby.RegisterFunctionHook("EnhTooltip.AddTooltip", 400, Enchantrix_HookTooltip)

	Stubby.RegisterAddOnHook("Auctioneer", "Enchantrix", Enchantrix_AuctioneerLoaded);

	Stubby.RegisterEventHook("SPELLCAST_FAILED", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("SPELLCAST_INTERRUPTED", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("SPELLCAST_START", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("SPELLCAST_STOP", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("ITEM_PUSH", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("BAG_UPDATE", "Enchantrix", Enchantrix_OnEvent);

	-- Register our temporary command hook with stubby
	Stubby.RegisterBootCode("Enchantrix", "CommandHandler", [[
		local function cmdHandler(msg)
			local i,j, cmd, param = string.find(string.lower(msg), "^([^ ]+) (.+)$")
			if (not cmd) then cmd = string.lower(msg) end 
			if (not cmd) then cmd = "" end 
			if (not param) then param = "" end
			if (cmd == "load") then
				if (param == "") then
					Stubby.Print("Manually loading Enchantrix...")
					LoadAddOn("Enchantrix")
				elseif (param == "always") then
					Stubby.Print("Setting Enchantrix to always load for this character")
					Stubby.SetConfig("Enchantrix", "LoadType", param)
					LoadAddOn("Enchantrix")
				elseif (param == "never") then
					Stubby.Print("Setting Enchantrix to never load automatically for this character (you may still load manually)")
					Stubby.SetConfig("Enchantrix", "LoadType", param)
				else
					Stubby.Print("Your command was not understood")
				end
			else
				Stubby.Print("Enchantrix is currently not loaded.")
				Stubby.Print("  You may load it now by typing |cffffffff/enchantrix load|r")
				Stubby.Print("  You may also set your loading preferences for this character by using the following commands:")
				Stubby.Print("  |cffffffff/enchantrix load always|r - Enchantrix will always load for this character")
				Stubby.Print("  |cffffffff/enchantrix load never|r - Enchantrix will never load automatically for this character (you may still load it manually)")
			end
		end
		SLASH_ENCHANTRIX1 = "/enchantrix"
		SLASH_ENCHANTRIX2 = "/enchant"
		SLASH_ENCHANTRIX3 = "/enx"
		SlashCmdList["ENCHANTRIX"] = cmdHandler
	]]);
	Stubby.RegisterBootCode("Enchantrix", "Triggers", [[
		local loadType = Stubby.GetConfig("Enchantrix", "LoadType")
		if (loadType == "always") then
			LoadAddOn("Enchantrix")
		else
			Stubby.Print("]]..ENCH_MESG_NOTLOADED..[[")
		end
	]]);

	Enchantrix_DisenchantCount = 0;
	Enchantrix_DisenchantResult = {};
	Enchantrix_Disenchanting = false;
	Enchantrix_WaitingPush = false;

	SLASH_ENCHANTRIX1 = "/enchantrix";
	SLASH_ENCHANTRIX2 = "/enchant";
	SLASH_ENCHANTRIX3 = "/enx";
	SlashCmdList["ENCHANTRIX"] = function(msg)
		Enchantrix_Command(msg);
	end

	--GUI Registration code added by MentalPower	
	Enchantrix_Register();
end

-- This function differs from Enchantrix_OnLoad in that it is executed
-- after variables have been loaded.
function Enchantrix_AddonLoaded()
	this:UnregisterEvent("ADDON_LOADED")

	Enchantrix_ConvertFilters();		-- Convert old localized settings
	Enchantrix_SetFilterDefaults();		-- Apply defaults

	Enchantrix_SetLocaleStrings(Enchantrix_GetLocale());
		
	Enchantrix_ChatPrint(string.format(ENCH_FRMT_WELCOME, ENCHANTRIX_VERSION), 0.8, 0.8, 0.2);
	Enchantrix_ChatPrint(ENCH_FRMT_CREDIT, 0.6, 0.6, 0.1);
end


function Enchantrix_SetFilter(key, value)
	if (not EnchantConfig.filters) then EnchantConfig.filters = {}; end
	if (type(value) == "boolean") then
		if (value) then 
			EnchantConfig.filters[key] = 'on';
		else
			EnchantConfig.filters[key] = 'off';
		end
	else
		EnchantConfig.filters[key] = value;
	end
end

function Enchantrix_GetFilterVal(key)
	if (not EnchantConfig.filters) then
		EnchantConfig.filters = {};
		Enchantrix_SetFilterDefaults();
	end
	return EnchantConfig.filters[key]
end

function Enchantrix_GetFilter(filter)
	value = Enchantrix_GetFilterVal(filter);
	return (value ~= "off");
end

function Enchantrix_GetSigs(str)
	local itemList = {};
	local listSize = 0;
	for sig, item in string.gfind(str, "|Hitem:(%d+:%d+:%d+):%d+|h[[]([^]]+)[]]|h") do
		listSize = listSize+1;
		itemList[listSize] = { s=sig, n=item };
	end
	return itemList;
end


function Enchantrix_PercentLessFilter(percentLess, signature)
    local filterAuction = true;
    local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(signature);
	local disenchantsTo = Enchantrix_GetAuctionItemDisenchants(signature, true);
	if not disenchantsTo.totals then return filterAuction; end

	local hspValue = disenchantsTo.totals.hspValue or 0;
	local medValue = disenchantsTo.totals.medValue or 0;
	local mktValue = disenchantsTo.totals.mktValue or 0;
	local confidence = disenchantsTo.totals.conf or 0;

	local myValue = confidence * (hspValue + medValue + mktValue) / 3;
	local margin = Auctioneer_PercentLessThan(myValue, buyout/count);
	local profit = (myValue * count) - buyout;

	local results = {
		buyout = buyout,
		count = count,
		value = myValue,
		margin = margin,
		profit = profit,
		conf = confidence
	};
	if (buyout > 0) and (margin >= tonumber(percentLess)) and (profit >= MIN_PROFIT_MARGIN) then
		filterAuction = false;
		Enchantrix_ProfitMargins[signature] = results;
	end

	return filterAuction;
end

function Enchantrix_BidBrokerFilter(minProfit, signature)
    local filterAuction = true;
    local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(signature);
    local currentBid = Auctioneer_GetCurrentBid(signature);
	local disenchantsTo = Enchantrix_GetAuctionItemDisenchants(signature, true);
	if not disenchantsTo.totals then return filterAuction; end

	local hspValue = disenchantsTo.totals.hspValue or 0;
	local medValue = disenchantsTo.totals.medValue or 0;
	local mktValue = disenchantsTo.totals.mktValue or 0;
	local confidence = disenchantsTo.totals.conf or 0;

	local myValue = confidence * (hspValue + medValue + mktValue) / 3;
	local margin = Auctioneer_PercentLessThan(myValue, currentBid/count);
	local profit = (myValue * count) - currentBid;
    local profitPricePercent = math.floor((profit / currentBid) * 100);

	local results = {
		buyout = buyout,
		count = count,
		value = myValue,
		margin = margin,
		profit = profit,
		conf = confidence
	};
	if (currentBid <= MAX_BUYOUT_PRICE) and (profit >= tonumber(minProfit)) and (profit >= MIN_PROFIT_MARGIN) and (profitPricePercent >= MIN_PROFIT_PRICE_PERCENT) then
		filterAuction = false;
		Enchantrix_ProfitMargins[signature] = results;
	end
	return filterAuction;
end

function Enchantrix_ProfitComparisonSort(a, b)
	if (not a) or (not b) then return false; end
	local aSig = a.signature;
	local bSig = b.signature;
	if (not aSig) or (not bSig) then return false; end
	local aEpm = Enchantrix_ProfitMargins[aSig];
	local bEpm = Enchantrix_ProfitMargins[bSig];
	if (not aEpm) and (not bEpm) then return false; end
	local aProfit = aEpm.profit or 0;
	local bProfit = bEpm.profit or 0;
	local aMargin = aEpm.margin or 0;
	local bMargin = bEpm.margin or 0;
	local aValue  = aEpm.value or 0;
	local bValue  = bEpm.value or 0;
	if (aProfit > bProfit) then return true; end
	if (aProfit < bProfit) then return false; end
	if (aMargin > bMargin) then return true; end
	if (aMargin < bMargin) then return false; end
	if (aValue > bValue) then return true; end
	if (aValue < bValue) then return false; end
	return false;
end

function Enchantrix_BidBrokerSort(a, b)
	if (not a) or (not b) then return false; end
	local aTime = a.timeLeft or 0;
	local bTime = b.timeLeft or 0;
	if (aTime > bTime) then return true; end
	if (aTime < bTime) then return false; end
	return Enchantrix_ProfitComparisonSort(a, b);
end

function Enchantrix_DoPercentLess(percentLess)
	if (not AUCTIONEER_VERSION) then
		Enchantrix_ChatPrint("You do not have auctioneer installed. Auctioneer must be installed to do an enchanting percentless scan");
		return;
	elseif (not Auctioneer_QuerySnapshot) then
		Enchantrix_ChatPrint("You do not have the correct version of Auctioneer installed, this feature requires Auctioneer v3.0.8 or later");
		return;
	end

    if not percentLess or percentLess == "" then percentLess = MIN_PERCENT_LESS_THAN_HSP end
	local output = string.format(ENCH_FRMT_PCTLESS_HEADER, percentLess);
    Enchantrix_ChatPrint(output);
    
	Enchantrix_PriceCache = {t=time()};
	Enchantrix_ProfitMargins = {};
    local targetAuctions = Auctioneer_QuerySnapshot(Enchantrix_PercentLessFilter, percentLess);
    
    -- sort by profit based on median
    table.sort(targetAuctions, Enchantrix_ProfitComparisonSort);
    
    -- output the list of auctions
    for _,a in targetAuctions do
		if (a.signature and Enchantrix_ProfitMargins[a.signature]) then
			local quality = EnhTooltip.QualityFromLink(a.itemLink);
			if (quality and quality >= 2) then
				local id,rprop,enchant, name, count,_,buyout,_ = Auctioneer_GetItemSignature(a.signature);
				local value = Enchantrix_ProfitMargins[a.signature].value;
				local margin = Enchantrix_ProfitMargins[a.signature].margin;
				local profit = Enchantrix_ProfitMargins[a.signature].profit;
				local output = string.format(ENCH_FRMT_PCTLESS_LINE, Auctioneer_ColorTextWhite(count.."x")..a.itemLink, EnhTooltip.GetTextGSC(value * count), EnhTooltip.GetTextGSC(buyout), EnhTooltip.GetTextGSC(profit * count), Auctioneer_ColorTextWhite(margin.."%"));
				Auctioneer_ChatPrint(output);
			end
		end
    end
    
    Auctioneer_ChatPrint(ENCH_FRMT_PCTLESS_DONE);
end

function Enchantrix_DoBidBroker(minProfit)
	if (not AUCTIONEER_VERSION) then
		Enchantrix_ChatPrint("You do not have auctioneer installed. Auctioneer must be installed to do an enchanting percentless scan");
		return;
	elseif (not Auctioneer_QuerySnapshot) then
		Enchantrix_ChatPrint("You do not have the correct version of Auctioneer installed, this feature requires Auctioneer v3.0.8 or later");
		return;
	end

    if not minProfit or minProfit == "" then minProfit = MIN_PROFIT_MARGIN; else minProfit = tonumber(minProfit) * 100; end
	local output = string.format(ENCH_FRMT_BIDBROKER_HEADER, EnhTooltip.GetTextGSC(minProfit));
    Enchantrix_ChatPrint(output);
    
	Enchantrix_PriceCache = {t=time()};
	Enchantrix_ProfitMargins = {};
    local targetAuctions = Auctioneer_QuerySnapshot(Enchantrix_BidBrokerFilter, minProfit);
    
    -- sort by profit based on median
    table.sort(targetAuctions, Enchantrix_BidBrokerSort);
    
    -- output the list of auctions
    for _,a in targetAuctions do
		if (a.signature and Enchantrix_ProfitMargins[a.signature]) then
			local quality = EnhTooltip.QualityFromLink(a.itemLink);
			if (quality and quality >= 2) then
				local id,rprop,enchant, name, count, min, buyout,_ = Auctioneer_GetItemSignature(a.signature);
				local currentBid = Auctioneer_GetCurrentBid(a.signature);
				local value = Enchantrix_ProfitMargins[a.signature].value;
				local margin = Enchantrix_ProfitMargins[a.signature].margin;
				local profit = Enchantrix_ProfitMargins[a.signature].profit;
				local bidText = ENCH_FRMT_BIDBROKER_CURBID;
				if (currentBid == min) then
					bidText = ENCH_FRMT_BIDBROKER_MINBID;
				end
				local output = string.format(ENCH_FRMT_BIDBROKER_LINE, Auctioneer_ColorTextWhite(count.."x")..a.itemLink, EnhTooltip.GetTextGSC(value * count), bidText, EnhTooltip.GetTextGSC(currentBid), EnhTooltip.GetTextGSC(profit * count), Auctioneer_ColorTextWhite(margin.."%"), Auctioneer_ColorTextWhite(Auctioneer_GetTimeLeftString(a.timeLeft)));
				Enchantrix_ChatPrint(output);
			end
		end
    end
    
    Enchantrix_ChatPrint(ENCH_FRMT_BIDBROKER_DONE);
end

function Enchantrix_GetAuctionItemDisenchants(auctionSignature, useCache)
    local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(auctionSignature);
	local sig = string.format("%d:%d:%d", id, enchant, rprop);
	local sigNR = string.format("%d:%d:%d", id, 0, 0);
	return Enchantrix_GetItemDisenchants(sig, sigNR, name, useCache);
end

function Enchantrix_Split(str, at)
	local splut = {};
	local pos = 1;
	
	local match, mend = string.find(str, at, pos, true);
	while match do
		table.insert(splut, string.sub(str, pos, match-1));
		pos = mend+1;
		match, mend = string.find(str, at, pos, true);
	end
	table.insert(splut, string.sub(str, pos));
	return splut;
end

function Enchantrix_SaveLocal(sig, lData)
	local str = "";
	for eResult, eData in lData do
		if (eData and type(eData) == "table") then
			local iCount = tonumber(eData.i) or 0;
			local dCount = tonumber(eData.d) or 0;
			local oCount = tonumber(eData.o) or 0;
			local serial = string.format("%d:%d:%d:%d", eResult, iCount, dCount, oCount);
			if (str == "") then str = serial else str = str..";"..serial end
		else
			eData = nil;
		end
	end
	EnchantedLocal[sig] = str;
end

function Enchantrix_GetLocal(sig)
	local enchantItem = {};
	if (EnchantedLocal and EnchantedLocal[sig]) then
		if (type(EnchantedLocal[sig]) == "table") then
			-- Time to convert it into the new serialized format
			Enchantrix_SaveLocal(sig, EnchantedLocal[sig]);
		end

		-- Get the string and break it apart
		local enchantSerial = EnchantedLocal[sig];
		local enchantResults = Enchantrix_Split(enchantSerial, ";");
		for pos, enchantResult in enchantResults do
			local enchantBreak = Enchantrix_Split(enchantResult, ":");
			local rSig = tonumber(enchantBreak[1]) or 0;
			local iCount = tonumber(enchantBreak[2]) or 0;
			local dCount = tonumber(enchantBreak[3]) or 0;
			local oCount = tonumber(enchantBreak[4]) or 0;

			enchantItem[rSig] = { i=iCount, d=dCount, o=oCount };
		end
	end
	return enchantItem;
end

function Enchantrix_GetItemDisenchants(sig, sigNR, name, useCache)
	local disenchantsTo = {};

	if (not Enchantrix_PriceCache) or (time()-Enchantrix_PriceCache.t > 300) then
		Enchantrix_PriceCache = {t=time()};
	end

	-- Automatically convert any named EnchantedLocal items to new items
	if (name and EnchantedLocal[name]) then
		for dName, count in EnchantedLocal[name] do
			local dSig = EssenceItemIDs[dName];
			if (dSig ~= nil) then
				if (not EnchantedLocal[sig]) then EnchantedLocal[sig] = {}; end
				if (not EnchantedLocal[sig][dSig]) then EnchantedLocal[sig][dSig] = {}; end
				local oCount = tonumber(EnchantedLocal[sig][dSig].o);
				if (oCount == nil) then oCount = 0; end
				EnchantedLocal[sig][dSig].o = ""..count;
			end
		end
		EnchantedLocal[name] = nil;
	end

	-- If there is data, then work out the disenchant data
	if ((DisenchantList[sig]) or (sigNR and DisenchantList[sigNR]) or (EnchantedLocal[sig])) then
		local bTotal = 0;
		local biTotal = 0;
		local bdTotal = 0;
		local oTotal = 0;
		local iTotal = 0;
		local dTotal = 0;

		local exactMatch = true;

		local baseDisenchant = DisenchantList[sig];
		
		if (not baseDisenchant) and (sigNR) then
			baseDisenchant = DisenchantList[sigNR];
			if (baseDisenchant) then
				exactMatch = false;
			end
		end
		
		if (baseDisenchant) then
			-- Base Disenchantments are now serialized
			local baseResults = Enchantrix_Split(baseDisenchant, ";");
			for pos, baseResult in baseResults do
				local baseBreak = Enchantrix_Split(baseResult, ":");
				local dSig = tonumber(baseBreak[1]) or 0;
				local biCount = tonumber(baseBreak[2]) or 0;
				local bdCount = tonumber(baseBreak[3]) or 0;
				local bCount = tonumber(baseBreak[4]) or 0;
				
				if (dSig > 0) and (bCount+biCount > 0) then
					disenchantsTo[dSig] = {};
					disenchantsTo[dSig].bCount = bCount;
					disenchantsTo[dSig].biCount = biCount;
					disenchantsTo[dSig].bdCount = bdCount;
					disenchantsTo[dSig].oCount = 0;
					disenchantsTo[dSig].iCount = 0;
					disenchantsTo[dSig].dCount = 0;
					bTotal = bTotal + bCount;
					biTotal = biTotal + biCount;
					bdTotal = bdTotal + bdCount;
				end
			end
		end

		local enchantedLocal = Enchantrix_GetLocal(sig);
		if (enchantedLocal) then
			for dSigStr, data in enchantedLocal do
				local dSig = tonumber(dSigStr);
				if (dSig and dSig > 0) then
					local oCount = 0;
					local dCount = 0;
					local iCount = 0;
					if (data.o) then oCount = tonumber(data.o); end
					if (data.d) then dCount = tonumber(data.d); end
					if (data.i) then iCount = tonumber(data.i); end
						
					if (not disenchantsTo[dSig]) then
						disenchantsTo[dSig] = {};
						disenchantsTo[dSig].bCount = 0;
					end
					if (data.z) then 
						local bCount = disenchantsTo[dSig].bCount;
						disenchantsTo[dSig].bCount = 0;
						bTotal = bTotal - bCount;
					end
					disenchantsTo[dSig].oCount = oCount;
					disenchantsTo[dSig].dCount = dCount;
					disenchantsTo[dSig].iCount = iCount;
					oTotal = oTotal + oCount;
					dTotal = dTotal + dCount;
					iTotal = iTotal + iCount;
				end
			end
		end

		local total = bTotal + biTotal + oTotal + iTotal;

		local hspGuess = 0;
		local medianGuess = 0;
		local marketGuess = 0;
		if (total > 0) then
			for dSig, counts in disenchantsTo do
				local itemID = 0;
				if (dSig) then itemID = tonumber(dSig); end
				local dName = ItemEssences[itemID];
				if (not dName) then dName = "Item "..dSig; end
				local oldCount, itemCount, disenchantCount;
				local count = (counts.bCount or 0) + (counts.biCount or 0) + (counts.oCount or 0) + (counts.iCount or 0);
				local countI = (counts.biCount or 0) + (counts.iCount or 0);
				local countD = (counts.bdCount or 0) + (counts.dCount or 0);
				local pct = tonumber(string.format("%0.1f", count / total * 100));
				local rate = 0;
				if (countI > 0) then
					rate = tonumber(string.format("%0.1f", countD / countI));
					if (not rate) then rate = 0; end
				end

				local count = 1;
				if (rate and rate > 0) then count = rate; end
				disenchantsTo[dSig].name = dName;
				disenchantsTo[dSig].pct = pct;
				disenchantsTo[dSig].rate = count;
				local mkt = Enchantrix_StaticPrices[itemID];

				-- Work out what version if any of auctioneer is installed
				local auctVerStr = AUCTIONEER_VERSION or "0.0.0";
				local auctVer = Enchantrix_Split(auctVerStr, ".");
				local major = tonumber(auctVer[1]) or 0;
				local minor = tonumber(auctVer[2]) or 0;
				local rev = tonumber(auctVer[3]) or 0;
				if (auctVer[3] == "DEV") then rev = 0; minor = minor + 1; end
					
				local itemKey = string.format("%s:0:0", itemID);
				if (useCache and not Enchantrix_PriceCache[itemKey]) then
					Enchantrix_PriceCache[itemKey] = {};
				end

				local hsp, median;
				if (useCache and Enchantrix_PriceCache[itemKey].hsp) then
					hsp = Enchantrix_PriceCache[itemKey].hsp;
				end

				if ((not hsp or hsp < 1) and (major >= 3)) then
					if (major == 3 and minor == 0 and rev <= 11) then
						if (rev == 11) then
							hsp = Auctioneer_GetHighestSellablePriceForOne(itemKey, false, Auctioneer_GetAuctionKey());
						else
							if (Auctioneer_GetHighestSellablePriceForOne) then
								hsp = Auctioneer_GetHighestSellablePriceForOne(itemKey, false);
							elseif (getHighestSellablePriceForOne) then
								hsp = getHighestSellablePriceForOne(itemKey, false);
							end
						end
					elseif (major > 3 or minor > 0 or rev > 11) then
						hsp = Auctioneer_GetHSP(itemKey, Auctioneer_GetAuctionKey());
					end
				end
				if hsp == nil then hsp = mkt * 0.98; end
				if (useCache) then Enchantrix_PriceCache[itemKey].hsp = hsp; end

				if (useCache and Enchantrix_PriceCache[itemKey].median) then
					median = Enchantrix_PriceCache[itemKey].median;
				end

				if ((not median or median < 1) and (major >= 3)) then
					median = Auctioneer_GetUsableMedian(itemKey);
				end
				if median == nil then median = mkt * 0.95; end
				if (useCache) then Enchantrix_PriceCache[itemKey].median = median; end

				local hspValue = (hsp * pct * count / 100);
				local medianValue = (median * pct * count / 100);
				disenchantsTo[dSig].hspValue = hspValue;
				disenchantsTo[dSig].medValue = medValue;
				hspGuess = hspGuess + hspValue;
				medianGuess = medianGuess + medianValue;

				local mktValue = (mkt * pct * count / 100);
				disenchantsTo[dSig].mktValue = mktValue;
				marketGuess = marketGuess + mktValue;
			end
		end

		local confidence = math.log(math.min(total, 19)+1)/3;

		disenchantsTo.totals = {};
		disenchantsTo.totals.exact = exactMatch;
		disenchantsTo.totals.hspValue = hspGuess or 0;
		disenchantsTo.totals.medValue = medianGuess or 0;
		disenchantsTo.totals.mktValue = marketGuess or 0;
		disenchantsTo.totals.bCount = bTotal or 0;
		disenchantsTo.totals.biCount = biTotal or 0;
		disenchantsTo.totals.bdCount = bdTotal or 0;
		disenchantsTo.totals.oCount = oTotal or 0;
		disenchantsTo.totals.dCount = dTotal or 0;
		disenchantsTo.totals.iCount = iTotal or 0;
		disenchantsTo.totals.total = total or 0;
		disenchantsTo.totals.conf = confidence or 0;
	end

	return disenchantsTo;
end

function Enchantrix_BreakLink(link)
	local i,j, itemID, enchant, randomProp, uniqID, name = string.find(link, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h[[]([^]]+)[]]|h");
	return tonumber(itemID or 0), tonumber(randomProp or 0), tonumber(enchant or 0), tonumber(uniqID or 0), name;
end


function Enchantrix_FindSigInBags(sig)
	for bag = 0, 4, 1 do
		size = GetContainerNumSlots(bag);
		if (size) then
			for slot = size, 1, -1 do
				local link = GetContainerItemLink(bag, slot);
				if (link) then
					local itemID, randomProp, enchant, uniqID, itemName = Enchantrix_BreakLink(link);
					if (itemName == findName) then
						local texture, itemCount, locked, quality, readable = GetContainerItemInfo(frameID, buttonID);
						local data = {
							name = itemName, link = link,
							sig = string.format("%d:%d:%d", itemID, enchant, randomProp),
							id = itemID, rand = randomProp, ench = enchant, uniq = uniqID,
							quality = quality
						}

						return bag, slot, data;
					end
				end
			end
		end
	end
end
