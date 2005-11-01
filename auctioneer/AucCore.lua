--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	Auctioneer core functions and variables.
	Functions central to the major operation of Auctioneer. 
]]


MAX_ALLOWED_FORMAT_INT = 2000000000; -- numbers much greater than this overflow when using format("%d")

-- If non-nil, check for appearance of GameTooltip for adding information
lAuctioneerCheckTooltip = nil;

-- Timer for frequency of tooltip checks
lAuctioneerCheckTimer = 0;

-- Current Tooltip frame
lAuctioneerTooltip = nil;

-- Counter to count the total number of auctions scanned
lTotalAuctionsScannedCount = 0;
lNewAuctionsCount = 0;
lOldAuctionsCount = 0;
lDefunctAuctionsCount = 0;

-- Temp table that is copied into AHSnapshotItemPrices only when a scan fully completes
lSnapshotItemPrices = {};

-- The maximum number of elements we store in our buyout prices history table 
lMaxBuyoutHistorySize = 35;

-- Min median buyout price for an item to show up in the list of items below median
MIN_PROFIT_MARGIN = 5000;

-- Min median buyout price for an item to show up in the list of items below median
DEFAULT_COMPETE_LESS = 5;

-- Min times an item must be seen before it can show up in the list of items below median
MIN_BUYOUT_SEEN_COUNT = 5;

-- Max buyout price for an auction to display as a good deal item
MAX_BUYOUT_PRICE = 800000;

-- The default percent less, only find auctions that are at a minimum this percent less than the median
MIN_PERCENT_LESS_THAN_HSP = 60; -- 60% default

-- The minimum profit/price percent that an auction needs to be displayed as a resellable auction
MIN_PROFIT_PRICE_PERCENT = 30; -- 30% default

-- The minimum percent of bids placed on an item to be considered an "in-demand" enough item to be traded, this is only applied to Weapons and Armor and Recipies
MIN_BID_PERCENT = 10;

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
BID_BASED_CATEGORIES = {[1]=true, [2]=true, [8]=true, [10]=true}

--[[ SavedVariables --]]
AuctionConfig = {};        --Table that stores config settings
Auction_DoneItems = {};    --Table to keep a record of auction items that have been scanned
AuctionBackup = {}			--Table to backup old data which can't be converted at once
AuctionConfig.version = 30200;

-- Table to store our cached HSP values (since they're expensive to calculate)
Auctioneer_HSPCache = {};
Auctioneer_Lowests = {};

-- Default filter configuration
Auctioneer_FilterDefaults = {
		["all"] = "on",
		["autofill"] = "on",
		["embed"] = "off",
		["also"] = "off",
		["auction-click"] = "on",
		["protect-window"] = 1,
		["show-link"] = "off",
		["show-embed-blankline"] = "off",
		["show-verbose"] = "on",
		["show-stats"] = "on",
		["show-average"] = "on",
		["show-median"] = "on",
		["show-suggest"] = "on",
		["show-warning"] = "on",
		["scan-class1"]  = "on",
		["scan-class2"]  = "on",
		["scan-class3"]  = "on",
		["scan-class4"]  = "on",
		["scan-class5"]  = "on",
		["scan-class6"]  = "on",
		["scan-class7"]  = "on",
		["scan-class8"]  = "on",
		["scan-class9"]  = "on",
		["scan-class10"] = "on",
		['printframe'] = 1,
		['last-auction-duration'] = 1440,
		['auction-duration'] = 3,
		['pct-bidmarkdown'] = 20,
		['pct-markup'] = 300,
		['pct-maxless'] = 30, 
		['pct-nocomp'] = 2,
		['pct-underlow'] = 5,
		['pct-undermkt'] = 20,
		['locale'] = 'default',
	}

function Auctioneer_GetItemData(itemKey)
	local itemID, itemRand, enchant = Auctioneer_BreakItemKey(itemKey);
	if (Informant) then
		return Informant.GetItem(itemID);
	end
	return nil; 
end

function Auctioneer_GetItemDataByID(itemID)
	if (Informant) then
		return Informant.GetItem(itemID);
	end
	return nil; 
end

function Auctioneer_StoreMedianList(list)
	local hist = "";
	local function GrowList(last, n)
		if (n == 1) then
			if (hist == "") then hist = last;
			else hist = string.format("%s:%d", hist, last); end
		elseif (n ~= 0) then
			if (hist == "") then hist = string.format("%dx%d", last, n);
			else hist = string.format("%s:%dx%d", hist, last, n); end
		end
	end
	local n = 0;
	local last = 0;
	for pos, hPrice in pairs(list) do
		if (pos == 1) then
			last = hPrice;
		elseif (hPrice ~= last) then
			GrowList(last, n)
			last = hPrice;
			n = 0;
		end
		n = n + 1
	end
	GrowList(last, n)
	return hist;
end

function Auctioneer_LoadMedianList(str)
	local splut = {};
	if (str) then
		for x,c in string.gfind(str, '([^%:]*)(%:?)') do
			local _,_,y,n = string.find(x, '(%d*)x(%d*)')
			if (y == nil) then
				table.insert(splut, tonumber(x));
			else
				for i = 1,n do
					table.insert(splut, tonumber(y));
				end
			end
			if (c == '') then break end
		end
	end
	return splut;
end

-- Returns an AuctionConfig.data item from the table based on an item name
function Auctioneer_GetAuctionPriceItem(itemKey, from)
	local serverFaction;
	local auctionPriceItem, data,info;

	if (from ~= nil) then serverFaction = from;
	else serverFaction = Auctioneer_GetAuctionKey(); end;
	
	EnhTooltip.DebugPrint("Getting data from/for", serverFaction, itemKey);
	if (AuctionConfig.data == nil) then AuctionConfig.data = {}; end
	if (AuctionConfig.info == nil) then AuctionConfig.info = {}; end
	if (AuctionConfig.data[serverFaction] == nil) then
		EnhTooltip.DebugPrint("Data from serverfaction is nil");
		AuctionConfig.data[serverFaction] = {};
	else
		data = AuctionConfig.data[serverFaction][itemKey];
		info = AuctionConfig.info[itemKey];
	end

	auctionPriceItem = {};
	if (data) then
		local dataItem = Auctioneer_Split(data, "|");
		auctionPriceItem.data = dataItem[1];
		auctionPriceItem.buyoutPricesHistoryList = Auctioneer_LoadMedianList(dataItem[2]);
	end
	if (info) then
		local infoItem = Auctioneer_Split(info, "|");
		auctionPriceItem.category = infoItem[1];
		auctionPriceItem.name = infoItem[2];
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

	local hist = Auctioneer_StoreMedianList(iData.buyoutPricesHistoryList);

	AuctionConfig.data[auctKey][itemKey] = string.format("%s|%s", iData.data, hist);
	AuctionConfig.info[itemKey] = string.format("%s|%s", iData.category, iData.name);
	if (Auctioneer_HSPCache and Auctioneer_HSPCache[auctKey]) then
		Auctioneer_HSPCache[auctKey][itemKey] = nil;
	end
	if (Auctioneer_Lowests) then Auctioneer_Lowests = nil; end

	-- save median to the savedvariablesfile
	Auctioneer_SetHistMed(auctKey, itemKey, Auctioneer_GetMedian(iData.buyoutPricesHistoryList))
end

-- Returns the auction buyout history for this item
function Auctioneer_GetAuctionBuyoutHistory(itemKey, auctKey)
	local auctionItem = Auctioneer_GetAuctionPriceItem(itemKey, auctKey);
	local buyoutHistory = {};
	if (auctionItem) then 
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

-- Returns the category i.e. 1, 2 for an item
function Auctioneer_GetItemCategory(itemKey)
	local category;
	local auctionItem = Auctioneer_GetAuctionPriceItem(itemKey);
	if auctionItem then 
		category = auctionItem.category;
	end

	return category;
end

function Auctioneer_IsPlayerMade(itemKey, itemData)
	if (not itemData) and (Informant) then
		local itemID, itemRand, enchant = Auctioneer_BreakItemKey(itemKey)
		itemData = Informant.GetItem(itemID)
	end
	
	local reqSkill = 0
	local reqLevel = 0
	if (itemData) then
		reqSkill = itemData.reqSkill
		reqLevel = itemData.reqLevel
	end
	return (reqSkill ~= 0), reqSkill, reqLevel
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
			bidamount = tonumber(bid),
			owner = owner,
			dirty = dirty,
			lastSeenTime = tonumber(last),
			itemLink = link,
			category = cat,
			initialSeenTime = tonumber(fseen),
			level = level,
			timeLeft = tonumber(left),
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
	local buysplit = Auctioneer_LoadMedianList(buy);
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
		EnhTooltip.DebugPrint("Saving", server, cat, sig, "as", saveData); 
		AuctionConfig.snap[server][cat][sig] = saveData;
		local itemKey = Auctioneer_GetKeyFromSig(sig);
		if(Auctioneer_HSPCache) and (Auctioneer_HSPCache[server]) then
			Auctioneer_HSPCache[server][itemKey] = nil;
		end
		if (Auctioneer_Lowests) then Auctioneer_Lowests = nil; end
	else
		EnhTooltip.DebugPrint("Not saving", server, cat, sig, "because", dirty, bid, level, qual, left, fseen, last, link, owner); 
	end
end

function Auctioneer_SaveSnapshotInfo(server, itemKey, iData)
	AuctionConfig.sbuy[server][itemKey] = Auctioneer_StoreMedianList(iData.buyoutPrices);
	if (Auctioneer_HSPCache and Auctioneer_HSPCache[server]) then
		Auctioneer_HSPCache[server][itemKey] = nil;
	end
	if (Auctioneer_Lowests) then Auctioneer_Lowests = nil; end
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


function Auctioneer_AddonLoaded()
	Auctioneer_SetLocaleStrings(Auctioneer_GetLocale());

	-- Load the category and subcategory id's
	Auctioneer_LoadCategories();

	Auctioneer_SetFilterDefaults();

	if (not AuctionConfig.version) then AuctionConfig.version = 30000; end
	if (AuctionConfig.version < 30200) then
		StaticPopupDialogs["CONVERT_AUCTIONEER"] = {
			text = _AUCT['MesgConvert'],
			button1 = _AUCT['MesgConvertYes'],
			button2 = _AUCT['MesgConvertNo'],
			OnAccept = function()
				Auctioneer_Convert();
			end,
			OnCancel = function()
				Auctioneer_ChatPrint(_AUCT['MesgNotconverting']);
			end,
			timeout = 0,
			whileDead = 1,
			exclusive = 1
		};
		StaticPopup_Show("CONVERT_AUCTIONEER", "","");
	end
	Auctioneer_LockAndLoad();
end

function Auctioneer_FindEmptySlot()
	local name, i
	for bag = 0, 4 do
		name = GetBagName(bag)
		i = string.find(name, '(Quiver|Ammo|Bandolier)')
		if not i then
			for slot = 1, GetContainerNumSlots(bag),1 do
				if not (GetContainerItemInfo(bag,slot)) then
					return bag, slot;
				end
			end
		end
	end
end



-- This is the old (local) hookAuctionHouse() function
function Auctioneer_HookAuctionHouse()
	Stubby.RegisterEventHook("NEW_AUCTION_UPDATE", "Auctioneer", Auctioneer_NewAuction);
	Stubby.RegisterEventHook("AUCTION_HOUSE_SHOW", "Auctioneer", Auctioneer_AuctHouseShow);
	Stubby.RegisterEventHook("AUCTION_HOUSE_CLOSED", "Auctioneer", Auctioneer_AuctHouseClose);
	Stubby.RegisterEventHook("AUCTION_ITEM_LIST_UPDATE", "Auctioneer", Auctioneer_AuctHouseUpdate);

	Stubby.RegisterFunctionHook("Auctioneer_Event_StartAuctionScan", 200, Auctioneer_AuctionStart_Hook);
	Stubby.RegisterFunctionHook("Auctioneer_Event_ScanAuction", 200, Auctioneer_AuctionEntry_Hook);
	Stubby.RegisterFunctionHook("Auctioneer_Event_FinishedAuctionScan", 200, Auctioneer_FinishedAuctionScan_Hook);

	Stubby.RegisterFunctionHook("StartAuction", 200, Auctioneer_StartAuction)
	Stubby.RegisterFunctionHook("PlaceAuctionBid", 200, Auctioneer_PlaceAuctionBid)
	Stubby.RegisterFunctionHook("FilterButton_SetType", 200, Auctioneer_FilterButton_SetType);
	Stubby.RegisterFunctionHook("AuctionFrameFilters_UpdateClasses", 200, Auctioneer_AuctionFrameFilters_UpdateClasses);
	Stubby.RegisterFunctionHook("AuctionsRadioButton_OnClick", 200, Auctioneer_OnChangeAuctionDuration);

	Auctioneer_Orig_PickupContainerItem = PickupContainerItem
	PickupContainerItem = function(...)
		local bag = arg[1]
		local item = arg[2]
		if (not CursorHasItem() and AuctionFrameAuctions:IsVisible() and IsAltKeyDown()) then
			Auctioneer_Orig_PickupContainerItem(bag, item)
			if (CursorHasItem() and Auctioneer_GetFilter('auction-click')) then
				ClickAuctionSellItemButton()
				AuctionsFrameAuctions_ValidateAuction()
				local start = MoneyInputFrame_GetCopper(StartPrice)
				local buy = MoneyInputFrame_GetCopper(BuyoutPrice)
				local duration = AuctionFrameAuctions.duration
				if (AuctionsCreateAuctionButton:IsEnabled()) then
					StartAuction(start, buy, duration);
					Auctioneer_ChatPrint(string.format(_AUCT['FrmtAutostart'], EnhTooltip.GetTextGSC(start), EnhTooltip.GetTextGSC(buy), duration/60));
				end
			end
		else
			Auctioneer_Orig_PickupContainerItem(bag, item)
		end
	end

end

function Auctioneer_LockAndLoad()
	Stubby.RegisterFunctionHook("AuctionFrame_LoadUI", 100, Auctioneer_ConfigureAH);

	Auctioneer_Orig_ContainerFrameItemButton_OnClick = ContainerFrameItemButton_OnClick 
	ContainerFrameItemButton_OnClick = function(...)
		local button = arg[1]
		local ignoreShift = arg[2]
		local bag = this:GetParent():GetID()
		local slot = this:GetID()

		local texture, count, noSplit = GetContainerItemInfo(bag, slot)
		if (count and count > 1 and not noSplit) then
			if (button == "RightButton") and (IsAltKeyDown()) then
				local splitCount = math.floor(count / 2)
				local emptyBag, emptySlot = Auctioneer_FindEmptySlot()
				if (emptyBag) then
					SplitContainerItem(bag, slot, splitCount)
					PickupContainerItem(emptyBag, emptySlot)
				else
					Auctioneer_ChatPrint("Can't split, all bags are full")
				end
				return
			end
		end
		Auctioneer_Orig_ContainerFrameItemButton_OnClick(unpack(arg))
	end

	SLASH_AUCTIONEER1 = "/auctioneer";
	SLASH_AUCTIONEER2 = "/auction";
	SLASH_AUCTIONEER3 = "/auc";
	SlashCmdList["AUCTIONEER"] = function(msg)
		Auctioneer_Command(msg, nil);
	end

	-- Rearranges elements in the AH window.
	Auctioneer_ConfigureAH();
	
	--GUI Registration code added by MentalPower	
	Auctioneer_Register();

	Auctioneer_ChatPrint(string.format(_AUCT['FrmtWelcome'], AUCTIONEER_VERSION), 0.8, 0.8, 0.2);
end


