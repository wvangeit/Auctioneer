--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	Auctioneer Search Auctions tab
	
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
--]]

local TIME_LEFT_NAMES = 
{
	AUCTION_TIME_LEFT1, -- Short
	AUCTION_TIME_LEFT2, -- Medium
	AUCTION_TIME_LEFT3, -- Long
	AUCTION_TIME_LEFT4  -- Very Long
};

local AUCTION_STATUS_UNKNOWN = 1;
local AUCTION_STATUS_HIGH_BIDDER = 2;
local AUCTION_STATUS_NOT_FOUND = 3;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AuctionFrameSearch_OnLoad()
	-- Methods
	this.SearchBids = AuctionFrameSearch_SearchBids;
	this.SearchBuyouts = AuctionFrameSearch_SearchBuyouts;
	this.SearchCompetition = AuctionFrameSearch_SearchCompetition;
	this.SearchPlain = AuctionFrameSearch_SearchPlain;
	this.SelectResultByIndex = AuctionFrameSearch_SelectResultByIndex;

	-- Controls
	this.searchDropDown = getglobal(this:GetName().."SearchDropDown");
	this.bidFrame = getglobal(this:GetName().."Bid");
	this.buyoutFrame = getglobal(this:GetName().."Buyout");
	this.competeFrame = getglobal(this:GetName().."Compete");
	this.plainFrame = getglobal(this:GetName().."Plain");
	this.resultsList = getglobal(this:GetName().."List");
	this.bidButton = getglobal(this:GetName().."BidButton");
	this.buyoutButton = getglobal(this:GetName().."BuyoutButton");

	-- Data members
	this.results = {};
	this.resultsType = nil;
	this.selectedResult = nil;

	-- Initialize the Search drop down
	local frame = this;
	this = this.searchDropDown;
	UIDropDownMenu_Initialize(this, AuctionFrameSearch_SearchDropDown_Initialize);
	AuctionFrameSearch_SearchDropDownItem_SetSelectedID(this, 1);
	this = frame;
	
	-- Configure the logical columns
	this.logicalColumns = 
	{
		Quantity =
		{
			title = _AUCT("UiQuantityHeader");
			dataType = "Number";
			valueFunc = (function(record) return record.count end);
			alphaFunc = AuctionFrameSearch_GetAuctionAlpha;
			compareAscendingFunc = (function(record1, record2) return record1.count < record2.count end);
			compareDescendingFunc = (function(record1, record2) return record1.count > record2.count end);
		},
		Name =
		{
			title = _AUCT("UiNameHeader");
			dataType = "String";
			valueFunc = (function(record) return record.name end);
			colorFunc = AuctionFrameSearch_GetItemColor;
			alphaFunc = AuctionFrameSearch_GetAuctionAlpha;
			compareAscendingFunc = (function(record1, record2) return record1.name < record2.name end);
			compareDescendingFunc = (function(record1, record2) return record1.name > record2.name end);
		},
		TimeLeft =
		{
			title = _AUCT("UiTimeLeftHeader");
			dataType = "String";
			valueFunc = (function(record) return Auctioneer_GetTimeLeftString(record.timeLeft) end);
			alphaFunc = AuctionFrameSearch_GetAuctionAlpha;
			compareAscendingFunc = (function(record1, record2) return record1.timeLeft < record2.timeLeft end);
			compareDescendingFunc = (function(record1, record2) return record1.timeLeft > record2.timeLeft end);
		},
		Bid =
		{
			title = _AUCT("UiBidHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.bid end);
			alphaFunc = AuctionFrameSearch_GetAuctionAlpha;
			compareAscendingFunc = (function(record1, record2) return record1.bid < record2.bid end);
			compareDescendingFunc = (function(record1, record2) return record1.bid > record2.bid end);
		},
		BidPer =
		{
			title = _AUCT("UiBidPerHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.bidPer end);
			alphaFunc = AuctionFrameSearch_GetAuctionAlpha;
			compareAscendingFunc = (function(record1, record2) return record1.bidPer < record2.bidPer end);
			compareDescendingFunc = (function(record1, record2) return record1.bidPer > record2.bidPer end);
		},
		Buyout =
		{
			title = _AUCT("UiBuyoutHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.buyout end);
			alphaFunc = AuctionFrameSearch_GetAuctionAlpha;
			compareAscendingFunc = (function(record1, record2) return record1.buyout < record2.buyout end);
			compareDescendingFunc = (function(record1, record2) return record1.buyout > record2.buyout end);
		},
		BuyoutPer =
		{
			title = _AUCT("UiBuyoutPerHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.buyoutPer end);
			alphaFunc = AuctionFrameSearch_GetAuctionAlpha;
			compareAscendingFunc = (function(record1, record2) return record1.buyoutPer < record2.buyoutPer end);
			compareDescendingFunc = (function(record1, record2) return record1.buyoutPer > record2.buyoutPer end);
		},
		Profit =
		{
			title = _AUCT("UiProfitHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.profit end);
			alphaFunc = AuctionFrameSearch_GetAuctionAlpha;
			compareAscendingFunc = (function(record1, record2) return record1.profit < record2.profit end);
			compareDescendingFunc = (function(record1, record2) return record1.profit > record2.profit end);
		},
		ProfitPer =
		{
			title = _AUCT("UiProfitPerHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.profitPer end);
			alphaFunc = AuctionFrameSearch_GetAuctionAlpha;
			compareAscendingFunc = (function(record1, record2) return record1.profitPer < record2.profitPer end);
			compareDescendingFunc = (function(record1, record2) return record1.profitPer > record2.profitPer end);
		},
		PercentLess =
		{
			title = _AUCT("UiPercentLessHeader");
			dataType = "Number";
			valueFunc = (function(record) return record.percentLess end);
			alphaFunc = AuctionFrameSearch_GetAuctionAlpha;
			compareAscendingFunc = (function(record1, record2) return record1.percentLess < record2.percentLess end);
			compareDescendingFunc = (function(record1, record2) return record1.percentLess > record2.percentLess end);
		},
		ItemLevel =
		{
			title = _AUCT("UiItemLevelHeader");
			dataType = "Number";
			valueFunc = (function(record) return record.level end);
			alphaFunc = AuctionFrameSearch_GetAuctionAlpha;
			compareAscendingFunc = (function(record1, record2) return record1.level < record2.level end);
			compareDescendingFunc = (function(record1, record2) return record1.level > record2.level end);
		},
	};

	-- Configure the bid search physical columns
	this.bidSearchPhysicalColumns = 
	{
		{
			width = 40;
			logicalColumn = this.logicalColumns.Quantity;
			logicalColumns = { this.logicalColumns.Quantity };
			sortAscending = true;
		},
		{
			width = 170;
			logicalColumn = this.logicalColumns.Name;
			logicalColumns = { this.logicalColumns.Name };
			sortAscending = true;
		},
		{
			width = 90;
			logicalColumn = this.logicalColumns.TimeLeft;
			logicalColumns = { this.logicalColumns.TimeLeft };
			sortAscending = true;
		},
		{
			width = 130;
			logicalColumn = this.logicalColumns.Bid;
			logicalColumns =
			{
				this.logicalColumns.Bid,
				this.logicalColumns.BidPer
			};
			sortAscending = true;
		},
		{
			width = 130;
			logicalColumn = this.logicalColumns.Profit;
			logicalColumns =
			{
				this.logicalColumns.Profit,
				this.logicalColumns.ProfitPer,
				this.logicalColumns.Buyout,
				this.logicalColumns.BuyoutPer
			};
			sortAscending = true;
		},
		{
			width = 50;
			logicalColumn = this.logicalColumns.PercentLess;
			logicalColumns =
			{
				this.logicalColumns.PercentLess
			};
			sortAscending = true;
		},
	};

	-- Configure the buyout search physical columns
	this.buyoutSearchPhysicalColumns = 
	{
		{
			width = 40;
			logicalColumn = this.logicalColumns.Quantity;
			logicalColumns = { this.logicalColumns.Quantity };
			sortAscending = true;
		},
		{
			width = 260;
			logicalColumn = this.logicalColumns.Name;
			logicalColumns = { this.logicalColumns.Name };
			sortAscending = true;
		},
		{
			width = 130;
			logicalColumn = this.logicalColumns.Buyout;
			logicalColumns =
			{
				this.logicalColumns.Bid,
				this.logicalColumns.BidPer,
				this.logicalColumns.Buyout,
				this.logicalColumns.BuyoutPer
			};
			sortAscending = true;
		},
		{
			width = 130;
			logicalColumn = this.logicalColumns.Profit;
			logicalColumns =
			{
				this.logicalColumns.Bid,
				this.logicalColumns.BidPer,
				this.logicalColumns.Profit,
				this.logicalColumns.ProfitPer
			};
			sortAscending = true;
		},
		{
			width = 50;
			logicalColumn = this.logicalColumns.PercentLess;
			logicalColumns =
			{
				this.logicalColumns.PercentLess
			};
			sortAscending = true;
		},
	};

	-- Configure the compete search physical columns
	this.competeSearchPhysicalColumns = 
	{
		{
			width = 40;
			logicalColumn = this.logicalColumns.Quantity;
			logicalColumns = { this.logicalColumns.Quantity };
			sortAscending = true;
		},
		{
			width = 260;
			logicalColumn = this.logicalColumns.Name;
			logicalColumns = { this.logicalColumns.Name };
			sortAscending = true;
		},
		{
			width = 130;
			logicalColumn = this.logicalColumns.Bid;
			logicalColumns =
			{
				this.logicalColumns.Bid,
				this.logicalColumns.BidPer
			};
			sortAscending = true;
		},
		{
			width = 130;
			logicalColumn = this.logicalColumns.Buyout;
			logicalColumns =
			{
				this.logicalColumns.Buyout,
				this.logicalColumns.BuyoutPer
			};
			sortAscending = true;
		},
		{
			width = 50;
			logicalColumn = this.logicalColumns.PercentLess;
			logicalColumns =
			{
				this.logicalColumns.PercentLess
			};
			sortAscending = true;
		},
	};

	-- Configure the plain search physical columns
	this.plainSearchPhysicalColumns = 
	{
		{
			width = 40;
			logicalColumn = this.logicalColumns.Quantity;
			logicalColumns = { this.logicalColumns.Quantity };
			sortAscending = true;
		},
		{
			width = 170;
			logicalColumn = this.logicalColumns.Name;
			logicalColumns = { this.logicalColumns.Name };
			sortAscending = true;
		},
		{
			width = 90;
			logicalColumn = this.logicalColumns.TimeLeft;
			logicalColumns = { this.logicalColumns.TimeLeft };
			sortAscending = true;
		},
		{
			width = 130;
			logicalColumn = this.logicalColumns.Bid;
			logicalColumns =
			{
				this.logicalColumns.Bid,
				this.logicalColumns.BidPer,
				this.logicalColumns.Buyout,
				this.logicalColumns.BuyoutPer
			};
			sortAscending = true;
		},
		{
			width = 130;
			logicalColumn = this.logicalColumns.Buyout;
			logicalColumns =
			{
				this.logicalColumns.Profit,
				this.logicalColumns.ProfitPer,
				this.logicalColumns.Buyout,
				this.logicalColumns.BuyoutPer
			};
			sortAscending = true;
		},
		{
			width = 50;
			logicalColumn = this.logicalColumns.PercentLess;
			logicalColumns =
			{
				this.logicalColumns.PercentLess,
				this.logicalColumns.ItemLevel
			};
			sortAscending = true;
		},
	};


	-- Initialize the list to show nothing at first.
	ListTemplate_Initialize(this.resultsList, this.results, this.results);
	this:SelectResultByIndex(nil);
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
AUCTIONEER_SEARCH_TYPES = {}
function AuctionFrameSearch_SearchDropDown_Initialize()
	local dropdown = this:GetParent();
	local frame = dropdown:GetParent();
	
	AUCTIONEER_SEARCH_TYPES[1] = _AUCT("UiSearchTypeBids");
	AUCTIONEER_SEARCH_TYPES[2] = _AUCT("UiSearchTypeBuyouts");
	AUCTIONEER_SEARCH_TYPES[3] = _AUCT("UiSearchTypeCompetition");
	AUCTIONEER_SEARCH_TYPES[4] = _AUCT("UiSearchTypePlain");

	for i=1, 4 do
		UIDropDownMenu_AddButton({
			text = AUCTIONEER_SEARCH_TYPES[i],
			func = AuctionFrameSearch_SearchDropDownItem_OnClick,
			owner = dropdown
		})
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AuctionFrameSearch_MinQualityDropDown_Initialize()
	local dropdown = this:GetParent();
	local frame = dropdown:GetParent();
	
	for i=0, 6 do
		UIDropDownMenu_AddButton({
			text = getglobal("ITEM_QUALITY"..i.."_DESC"),
			func = AuctionFrameSearch_MinQualityDropDownItem_OnClick,
			value = i,
			owner = dropdown
		});
	end
end

function AuctionFrameSearch_SavedSearchDropDownItem_OnClick()
	local index = this:GetID();
	local dropdown = this.owner;
	local frame = dropdown:GetParent();
	local frameName = frame:GetName();
	local text;

	if (index > 1) then
		text = this.value
		local searchData = AuctionConfig.SavedSearches[text];
		local searchParams = Auctioneer_Split(searchData, "\t");
		
		local searchType = tonumber(searchParams[1])
		getglobal(frameName.."SearchDropDown").selectedID = searchType;
		getglobal(frameName.."SearchDropDownText"):SetText(AUCTIONEER_SEARCH_TYPES[searchType]);

		if (searchType == 1) then
			-- Bid search
			MoneyInputFrame_SetCopper(getglobal(frameName.."BidMinProfit"), tonumber(searchParams[2]))
			getglobal(frameName.."BidMinPercentLessEdit"):SetText(searchParams[3])

			local timeLeft = tonumber(searchParams[4])
			getglobal(frameName.."BidTimeLeftDropDown").selectedID = timeLeft
			getglobal(frameName.."BidTimeLeftDropDownText"):SetText(TIME_LEFT_NAMES[timeLeft])

			local catid = tonumber(searchParams[5])
			getglobal(frameName.."BidCategoryDropDown").selectedID = catid
			getglobal(frameName.."BidCategoryDropDownText"):SetText(AuctionConfig.classes[catid-1].name)
		
			local quality = tonumber(searchParams[6])
			getglobal(frameName.."BidMinQualityDropDown").selectedID = quality
			getglobal(frameName.."BidMinQualityDropDownText"):SetText(getglobal("ITEM_QUALITY"..(quality-1).."_DESC"))
		
			getglobal(frameName.."BidSearchEdit"):SetText(searchParams[7])

			frame.bidFrame:Show();
			frame.buyoutFrame:Hide();
			frame.competeFrame:Hide();
			frame.plainFrame:Hide();
		elseif (searchType == 2) then
			-- Buyout search
			MoneyInputFrame_SetCopper(getglobal(frameName.."BuyoutMinProfit"), tonumber(searchParams[2]))
			getglobal(frameName.."BuyoutMinPercentLessEdit"):SetText(searchParams[3])

			local catid = tonumber(searchParams[4])
			getglobal(frameName.."BuyoutCategoryDropDown").selectedID = catid
			getglobal(frameName.."BuyoutCategoryDropDownText"):SetText(AuctionConfig.classes[catid-1].name)

			local quality = tonumber(searchParams[5])
			getglobal(frameName.."BuyoutMinQualityDropDown").selectedID = quality
			getglobal(frameName.."BuyoutMinQualityDropDownText"):SetText(getglobal("ITEM_QUALITY"..(quality-1).."_DESC"))
		
			getglobal(frameName.."BuyoutSearchEdit"):SetText(searchParams[6])

			frame.bidFrame:Hide();
			frame.buyoutFrame:Show();
			frame.competeFrame:Hide();
			frame.plainFrame:Hide();
		elseif (searchType == 3) then
			-- Compete search
			MoneyInputFrame_SetCopper(getglobal(frameName.."CompeteUndercut"), tonumber(searchParams[2]))

			frame.bidFrame:Hide();
			frame.buyoutFrame:Hide();
			frame.competeFrame:Show();
			frame.plainFrame:Hide();
		elseif (searchType == 4) then
			-- Plain search
			MoneyInputFrame_SetCopper(getglobal(frameName.."PlainMaxPrice"), tonumber(searchParams[2]))

			local catid = tonumber(searchParams[3])
			getglobal(frameName.."PlainCategoryDropDown").selectedID = catid
			getglobal(frameName.."PlainCategoryDropDownText"):SetText(AuctionConfig.classes[catid-1].name)

			local quality = tonumber(searchParams[4])
			getglobal(frameName.."PlainMinQualityDropDown").selectedID = quality
			getglobal(frameName.."PlainMinQualityDropDownText"):SetText(getglobal("ITEM_QUALITY"..(quality-1).."_DESC"))
		
			getglobal(frameName.."PlainSearchEdit"):SetText(searchParams[5])

			frame.bidFrame:Hide();
			frame.buyoutFrame:Hide();
			frame.competeFrame:Hide();
			frame.plainFrame:Show();
		end
	end
	getglobal(frameName.."SaveSearchEdit"):SetText(text);
end

function AuctionFrameSearch_SavedSearchDropDown_Initialize()
	local dropdown = AuctionFrameSearchSavedSearchDropDown
	local frame = dropdown:GetParent()
	
--	UIDropDownMenu_ClearAll(dropdown)
	if (not AuctionConfig.SavedSearches) then
		UIDropDownMenu_AddButton({
			text = "",
			func = AuctionFrameSearch_SavedSearchDropDownItem_OnClick,
			owner = dropdown
		});
		UIDropDownMenu_SetSelectedID(dropdown, 1);
		return
	end
	
	local savedSearchDropDownElements = {}
	for name, search in pairs(AuctionConfig.SavedSearches) do
		table.insert(savedSearchDropDownElements, name);
	end
	table.sort(savedSearchDropDownElements);

	UIDropDownMenu_AddButton({
		text = "",
		func = AuctionFrameSearch_SavedSearchDropDownItem_OnClick,
		owner = dropdown
	});
	for pos, name in savedSearchDropDownElements do
		UIDropDownMenu_AddButton({
			text = name,
			func = AuctionFrameSearch_SavedSearchDropDownItem_OnClick,
			owner = dropdown
		});
	end
	UIDropDownMenu_SetSelectedID(dropdown, 1);
end
			
		
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AuctionFrameSearch_MinQualityDropDownItem_OnClick()
	local index = this:GetID();
	local dropdown = this.owner;
	UIDropDownMenu_SetSelectedID(dropdown, index);
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AuctionFrameSearch_SearchDropDownItem_OnClick()
	local index = this:GetID();
	local dropdown = this.owner;
	AuctionFrameSearch_SearchDropDownItem_SetSelectedID(dropdown, index);
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AuctionFrameSearch_SearchDropDownItem_SetSelectedID(dropdown, index)
	local frame = dropdown:GetParent();
	frame.bidFrame:Hide();
	frame.buyoutFrame:Hide();
	frame.competeFrame:Hide();
	frame.plainFrame:Hide();
	if (index == 1) then
		frame.bidFrame:Show();
	elseif (index == 2) then
		frame.buyoutFrame:Show();
	elseif (index == 3) then
		frame.competeFrame:Show();
	elseif (index == 4) then
		frame.plainFrame:Show();
	end
	UIDropDownMenu_SetSelectedID(dropdown, index);
end

function AuctionFrameSearch_RemoveSearchButton_OnClick(button)
	local frame = button:GetParent();
	local frameName = frame:GetName();

	local searchName = getglobal(frameName.."SaveSearchEdit"):GetText()
	if (AuctionConfig.SavedSearches) then
		AuctionConfig.SavedSearches[searchName] = nil
	end
	getglobal(frameName.."SaveSearchEdit"):SetText("")
end

function AuctionFrameSearch_SaveSearchButton_OnClick(button)
	local frame = button:GetParent();
	local frameName = frame:GetName();
	local searchDropdown = getglobal(frameName.."SearchDropDown")

	local searchType = UIDropDownMenu_GetSelectedID(searchDropdown);
	local searchData = nil
	if (searchType == 1) then
		-- Bid-based search
		searchData = string.format("%d\t%d\t%s\t%d\t%d\t%d\t%s",
			searchType, 
			MoneyInputFrame_GetCopper(getglobal(frameName.."BidMinProfit")),
			getglobal(frameName.."BidMinPercentLessEdit"):GetText(),
			UIDropDownMenu_GetSelectedID(getglobal(frameName.."BidTimeLeftDropDown")),
			UIDropDownMenu_GetSelectedID(getglobal(frameName.."BidCategoryDropDown")),
			UIDropDownMenu_GetSelectedID(getglobal(frameName.."BidMinQualityDropDown")),
			getglobal(frameName.."BidSearchEdit"):GetText()
		);
	elseif (searchType == 2) then
		-- Buyout-based search
		searchData = string.format("%d\t%d\t%s\t%d\t%d\t%s",
			searchType, 
			MoneyInputFrame_GetCopper(getglobal(frameName.."BuyoutMinProfit")),
			getglobal(frameName.."BuyoutMinPercentLessEdit"):GetText(),
			UIDropDownMenu_GetSelectedID(getglobal(frameName.."BuyoutCategoryDropDown")),
			UIDropDownMenu_GetSelectedID(getglobal(frameName.."BuyoutMinQualityDropDown")),
			getglobal(frameName.."BuyoutSearchEdit"):GetText()
		);
	elseif (searchType == 3) then
		-- Compete-based search
		searchData = string.format("%d\t%d",
			searchType, 
			MoneyInputFrame_GetCopper(getglobal(frameName.."CompeteUndercut"))
		);
	elseif (searchType == 4) then
		-- Plain-based search
		searchData = string.format("%d\t%d\t%d\t%d\t%s",
			searchType, 
			MoneyInputFrame_GetCopper(getglobal(frameName.."PlainMaxPrice")),
			UIDropDownMenu_GetSelectedID(getglobal(frameName.."PlainCategoryDropDown")),
			UIDropDownMenu_GetSelectedID(getglobal(frameName.."PlainMinQualityDropDown")),
			getglobal(frameName.."PlainSearchEdit"):GetText()
		);
	end
	
	if (searchData) then
		local searchName = getglobal(frameName.."SaveSearchEdit"):GetText()
		if (not AuctionConfig.SavedSearches) then
			AuctionConfig.SavedSearches = {}
		end

		AuctionConfig.SavedSearches[searchName] = searchData
	end

--	AuctionFrameSearch_SavedSearchDropDown_Initialize()
end

	

-------------------------------------------------------------------------------
-- The Bid button has been clicked
-------------------------------------------------------------------------------
function AuctionFrameSearch_BidButton_OnClick(button)
	local frame = button:GetParent();
	local result = frame.selectedResult;
	if (result and result.name and result.count and result.bid) then
		local context = { frame = frame, auction = result };
		AucBidManager.BidAuction(result.bid, result.signature, AuctionFrameSearch_OnBidResult, context);
	end
end

-------------------------------------------------------------------------------
-- The Buyout button has been clicked.
-------------------------------------------------------------------------------
function AuctionFrameSearch_BuyoutButton_OnClick(button)
	local frame = button:GetParent();
	local result = frame.selectedResult;
	if (result and result.name and result.count and result.buyout) then
		local context = { frame = frame, auction = result };
		AucBidManager.BidAuction(result.buyout, result.signature, AuctionFrameSearch_OnBidResult, context);
	end
end

-------------------------------------------------------------------------------
-- Returns the item color for the specified result
-------------------------------------------------------------------------------
function AuctionFrameSearch_GetItemColor(result)
	_, _, rarity = GetItemInfo(result.item);
	return ITEM_QUALITY_COLORS[rarity];
end

-------------------------------------------------------------------------------
-- Perform a bid search (aka bidBroker)
-------------------------------------------------------------------------------
function AuctionFrameSearch_SearchBids(frame, minProfit, minPercentLess, maxTimeLeft, category, minQuality, itemName)
	-- Create the content from auctioneer.
	frame.results = {};
	local bidWorthyAuctions = Auctioneer_QuerySnapshot(Auctioneer_BidBrokerFilter, minProfit, maxTimeLeft, category, minQuality, itemName);
	if (bidWorthyAuctions) then
		local player = UnitName("player");
		for pos,a in pairs(bidWorthyAuctions) do
			if (a.owner ~= player) then
				local id,rprop,enchant,name, count,min,buyout,uniq = Auctioneer_GetItemSignature(a.signature);
				local itemKey = id .. ":" .. rprop..":"..enchant;
				local hsp, seenCount = Auctioneer_GetHSP(itemKey, Auctioneer_GetAuctionKey());
				local currentBid = Auctioneer_GetCurrentBid(a.signature);
				local percentLess = 100 - math.floor(100 * currentBid / (hsp * count));
				if (percentLess >= minPercentLess) then
					local auction = {};
					auction.id = id;
					auction.item = string.format("item:%s:%s:%s:0", id, enchant, rprop);
					auction.link = a.itemLink;
					auction.name = name;
					auction.count = count;
					auction.owner = a.owner;
					auction.timeLeft = a.timeLeft;
					auction.bid = currentBid;
					auction.bidPer = math.floor(auction.bid / count);
					auction.buyout = buyout;
					auction.buyoutPer = math.floor(auction.buyout / count);
					auction.profit = (hsp * count) - currentBid;
					auction.profitPer = math.floor(auction.profit / count);
					auction.percentLess = percentLess;
					auction.signature = a.signature;
					if (a.highBidder) then
						auction.status = AUCTION_STATUS_HIGH_BIDDER;
					else
						auction.status = AUCTION_STATUS_UNKNOWN;
					end
					table.insert(frame.results, auction);
				end
			end
		end
	end

	-- Hand the updated results to the list.
	frame.resultsType = "BidSearch";
	frame:SelectResultByIndex(nil);
	ListTemplate_Initialize(frame.resultsList, frame.bidSearchPhysicalColumns, frame.auctioneerListLogicalColumns);
	ListTemplate_SetContent(frame.resultsList, frame.results);
	ListTemplate_Sort(frame.resultsList, 2);
	ListTemplate_Sort(frame.resultsList, 3);
end

-------------------------------------------------------------------------------
-- Perform a buyout search (aka percentLess)
-------------------------------------------------------------------------------
function AuctionFrameSearch_SearchBuyouts(frame, minProfit, minPercentLess, category, minQuality, itemName)
	-- Create the content from auctioneer.
	frame.results = {};
	local buyoutWorthyAuctions = Auctioneer_QuerySnapshot(Auctioneer_PercentLessFilter, minPercentLess, category, minQuality, itemName);
	if (buyoutWorthyAuctions) then
		local player = UnitName("player");
		for pos,a in pairs(buyoutWorthyAuctions) do
			if (a.owner ~= player) then
				local id,rprop,enchant,name,count,min,buyout,uniq = Auctioneer_GetItemSignature(a.signature);
				local itemKey = id .. ":" .. rprop..":"..enchant;
				local hsp, seenCount = Auctioneer_GetHSP(itemKey, Auctioneer_GetAuctionKey());
				local profit = (hsp * count) - buyout;
				if (profit >= minProfit) then
					local auction = {};
					auction.id = id;
					auction.item = string.format("item:%s:%s:%s:0", id, enchant, rprop);
					auction.link = a.itemLink;
					auction.name = name;
					auction.count = count;
					auction.owner = a.owner;
					auction.timeLeft = a.timeLeft;
					auction.buyout = buyout;
					auction.buyoutPer = math.floor(auction.buyout / count);
					auction.profit = profit;
					auction.profitPer = math.floor(auction.profit / count);
					auction.percentLess = 100 - math.floor(100 * buyout / (hsp * count));
					auction.signature = a.signature;
					if (a.highBidder) then
						auction.status = AUCTION_STATUS_HIGH_BIDDER;
					else
						auction.status = AUCTION_STATUS_UNKNOWN;
					end
					table.insert(frame.results, auction);
				end
			end
		end
	end

	-- Hand the updated content to the list.
	frame.resultsType = "BuyoutSearch";
	frame:SelectResultByIndex(nil);
	ListTemplate_Initialize(frame.resultsList, frame.buyoutSearchPhysicalColumns, frame.auctioneerListLogicalColumns);
	ListTemplate_SetContent(frame.resultsList, frame.results);
	ListTemplate_Sort(frame.resultsList, 5);
end

-------------------------------------------------------------------------------
-- Perform a competition search (aka compete)
-------------------------------------------------------------------------------
function AuctionFrameSearch_SearchCompetition(frame, minUndercut)
	-- Create the content from auctioneer.
	frame.results = {};

	-- Get the highest prices for my auctions.	
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

	-- Search for competing auctions less than mine.	
	competingAuctions = Auctioneer_QuerySnapshot(Auctioneer_CompetingFilter, minUndercut, myHighestPrices);
	if (competingAuctions) then
		table.sort(competingAuctions, Auctioneer_ProfitComparisonSort);
		for pos,a in pairs(competingAuctions) do
			local id,rprop,enchant,name,count,min,buyout,uniq = Auctioneer_GetItemSignature(a.signature);
			local itemKey = id .. ":" .. rprop..":"..enchant;
			local myBuyout = myHighestPrices[itemKey];
			local currentBid = Auctioneer_GetCurrentBid(a.signature);
			
			local auction = {};
			auction.id = id;
			auction.item = string.format("item:%s:%s:%s:0", id, enchant, rprop);
			auction.link = a.itemLink;
			auction.name = name;
			auction.count = count;
			auction.owner = a.owner;
			auction.timeLeft = a.timeLeft;
			auction.bid = currentBid;
			auction.bidPer = math.floor(auction.bid / count);
			auction.buyout = buyout;
			auction.buyoutPer = math.floor(auction.buyout / count);
			auction.percentLess = math.floor(((myBuyout - auction.buyoutPer) / myBuyout) * 100);
			auction.signature = a.signature;
			if (a.highBidder) then
				auction.status = AUCTION_STATUS_HIGH_BIDDER;
			else
				auction.status = AUCTION_STATUS_UNKNOWN;
			end
			table.insert(frame.results, auction);
		end
	end

	-- Hand the updated content to the list.
	frame.resultsType = "CompeteSearch";
	frame:SelectResultByIndex(nil);
	ListTemplate_Initialize(frame.resultsList, frame.competeSearchPhysicalColumns, frame.auctioneerListLogicalColumns);
	ListTemplate_SetContent(frame.resultsList, frame.results);
end

-------------------------------------------------------------------------------
-- Perform a plain search
-------------------------------------------------------------------------------
function AuctionFrameSearch_SearchPlain(frame, maxPrice, category, minQuality, itemName)
	-- Create the content from auctioneer.
	frame.results = {};
	local bidWorthyAuctions = Auctioneer_QuerySnapshot(Auctioneer_PlainFilter, maxPrice, category, minQuality, itemName);
	if (bidWorthyAuctions) then
		local player = UnitName("player");
		for pos,a in pairs(bidWorthyAuctions) do
			if (a.owner ~= player) then
				local id,rprop,enchant,name, count,min,buyout,uniq = Auctioneer_GetItemSignature(a.signature);
				local itemKey = id .. ":" .. rprop..":"..enchant;
				local hsp, seenCount = Auctioneer_GetHSP(itemKey, Auctioneer_GetAuctionKey());
				local currentBid = Auctioneer_GetCurrentBid(a.signature);
				local percentLess = 100 - math.floor(100 * currentBid / (hsp * count));

				local _,_,_,iLevel = GetItemInfo(id);

				local auction = {};
				auction.id = id;
				auction.item = string.format("item:%s:%s:%s:0", id, enchant, rprop);
				auction.link = a.itemLink;
				auction.level = iLevel;
				auction.name = name;
				auction.count = count;
				auction.owner = a.owner;
				auction.timeLeft = a.timeLeft;
				auction.bid = currentBid;
				auction.bidPer = math.floor(auction.bid / count);
				auction.buyout = buyout;
				auction.buyoutPer = math.floor(auction.buyout / count);
				auction.profit = (hsp * count) - currentBid;
				auction.profitPer = math.floor(auction.profit / count);
				auction.percentLess = percentLess;
				auction.signature = a.signature;
				if (a.highBidder) then
					auction.status = AUCTION_STATUS_HIGH_BIDDER;
				else
					auction.status = AUCTION_STATUS_UNKNOWN;
				end
				table.insert(frame.results, auction);
			end
		end
	end

	-- Hand the updated results to the list.
	frame.resultsType = "BidSearch";
	frame:SelectResultByIndex(nil);
	ListTemplate_Initialize(frame.resultsList, frame.plainSearchPhysicalColumns, frame.auctioneerListLogicalColumns);
	ListTemplate_SetContent(frame.resultsList, frame.results);
	ListTemplate_Sort(frame.resultsList, 2);
	ListTemplate_Sort(frame.resultsList, 3);
end


-------------------------------------------------------------------------------
-- Select a search result by index.
-------------------------------------------------------------------------------
function AuctionFrameSearch_SelectResultByIndex(frame, index)
	if (index and index <= table.getn(frame.results) and frame.resultsType) then
		-- Select the item
		local result = frame.results[index];
		frame.selectedResult = result;
		ListTemplate_SelectRow(frame.resultsList, index);

		-- Update the bid button
		if (frame.resultsType == "BidSearch") then
			frame.bidButton:Enable();
			frame.buyoutButton:Disable();
		elseif (frame.resultsType == "BuyoutSearch") then
			frame.bidButton:Disable();
			frame.buyoutButton:Enable();
		end
	else
		-- Clear the selection
		frame.selectedResult = nil;
		ListTemplate_SelectRow(frame.resultsList, nil);
		frame.bidButton:Disable();
		frame.buyoutButton:Disable();
	end
end

-------------------------------------------------------------------------------
-- An item in the list is moused over.
-------------------------------------------------------------------------------
function AuctionFrameSearch_ListItem_OnEnter(row)
	local frame = this:GetParent():GetParent();
	local results = frame.results;
	if (results and row <= table.getn(results)) then
		local result = results[row];
		if (result) then
			local name = result.name;
			local _, link, rarity = GetItemInfo(results[row].item);
			local count = result.count;
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
			GameTooltip:SetHyperlink(link);
			GameTooltip:Show();
			EnhTooltip.TooltipCall(GameTooltip, name, result.link, rarity, count);
		end
	end
end

-------------------------------------------------------------------------------
-- An item in the list is clicked.
-------------------------------------------------------------------------------
function AuctionFrameSearch_ListItem_OnClick(row)
	local frame = this:GetParent():GetParent();
	
	-- Select the item clicked.
	frame:SelectResultByIndex(row);

	-- Bid or buyout the item if the alt key is down.
	if (frame.resultsType and IsAltKeyDown()) then
		if (IsShiftKeyDown()) then
			-- Bid or buyout the item.
			if (frame.resultsType == "BidSearch") then
				AuctionFrameSearch_BidButton_OnClick(frame.bidButton);
			elseif (frame.resultsType == "BuyoutSearch") then
				AuctionFrameSearch_BuyoutButton_OnClick(frame.buyoutButton);
			end
		else
			-- Search for the item and switch to the Browse tab.
			BrowseName:SetText(frame.results[row].name)
			BrowseMinLevel:SetText("")
			BrowseMaxLevel:SetText("")
			AuctionFrameBrowse.selectedInvtype = nil
			AuctionFrameBrowse.selectedInvtypeIndex = nil
			AuctionFrameBrowse.selectedClass = nil
			AuctionFrameBrowse.selectedClassIndex = nil
			AuctionFrameBrowse.selectedSubclass = nil
			AuctionFrameBrowse.selectedSubclassIndex = nil
			AuctionFrameFilters_Update()
			IsUsableCheckButton:SetChecked(0)
			UIDropDownMenu_SetSelectedValue(BrowseDropDown, -1)
			AuctionFrameBrowse_Search()
			AuctionFrameTab_OnClick(1);
		end
	end
end

-------------------------------------------------------------------------------
-- Initialize the content of a Category dropdown list
-------------------------------------------------------------------------------
function AuctionFrameSearch_CategoryDropDown_Initialize()
	local dropdown = this:GetParent();
	local frame = dropdown:GetParent();
	UIDropDownMenu_AddButton({
		text = "",
		func = AuctionFrameSearch_CategoryDropDownItem_OnClick,
		owner = dropdown
	})

	if (AuctionConfig.classes) then
		for classid, cdata in AuctionConfig.classes do
			UIDropDownMenu_AddButton({
				text = cdata.name,
				func = AuctionFrameSearch_CategoryDropDownItem_OnClick,
				owner = dropdown
			});
		end
	end
end

-------------------------------------------------------------------------------
-- An item in a CategoryDrownDown has been clicked
-------------------------------------------------------------------------------
function AuctionFrameSearch_CategoryDropDownItem_OnClick()
	local index = this:GetID();
	local dropdown = this.owner;
	UIDropDownMenu_SetSelectedID(dropdown, index);
end

-------------------------------------------------------------------------------
-- Initialize the content of a TimeLeft dropdown list
-------------------------------------------------------------------------------
function AuctionFrameSearch_TimeLeftDropDown_Initialize()
	local dropdown = this:GetParent();
	local frame = dropdown:GetParent();
	for index in TIME_LEFT_NAMES do
		local info = {};
		info.text = TIME_LEFT_NAMES[index];
		info.func = AuctionFrameSearch_TimeLeftDropDownItem_OnClick;
		info.owner = dropdown;
		UIDropDownMenu_AddButton(info);
	end
end

-------------------------------------------------------------------------------
-- An item a TimeLeftDrownDown has been clicked
-------------------------------------------------------------------------------
function AuctionFrameSearch_TimeLeftDropDownItem_OnClick()
	local index = this:GetID();
	local dropdown = this.owner;
	UIDropDownMenu_SetSelectedID(dropdown, index);
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AuctionFrameSearchBid_SearchButton_OnClick(button)
	local frame = button:GetParent();
	local frameName = frame:GetName();
	local profitMoneyFrame = getglobal(frameName.."MinProfit");
	local percentLessEdit = getglobal(frameName.."MinPercentLessEdit"); 
	local timeLeftDropDown = getglobal(frameName.."TimeLeftDropDown");

	local minProfit = MoneyInputFrame_GetCopper(profitMoneyFrame);
	local minPercentLess = percentLessEdit:GetNumber();
	local catID = (UIDropDownMenu_GetSelectedID(getglobal(frameName.."CategoryDropDown")) or 1) - 1;
	local minQuality = (UIDropDownMenu_GetSelectedID(getglobal(frameName.."MinQualityDropDown")) or 1) - 1;
	local itemName = getglobal(frameName.."SearchEdit"):GetText();
	if (itemName == "") then itemName = nil end
	
	local timeLeft = TIME_LEFT_SECONDS[UIDropDownMenu_GetSelectedID(timeLeftDropDown)];
	frame:GetParent():SearchBids(minProfit, minPercentLess, timeLeft, catID, minQuality, itemName);
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AuctionFrameSearchBuyout_SearchButton_OnClick(button)
	local frame = button:GetParent();
	local profitMoneyFrame = getglobal(frame:GetName().."MinProfit");
	local percentLessEdit = getglobal(frame:GetName().."MinPercentLessEdit"); 

	local minProfit = MoneyInputFrame_GetCopper(profitMoneyFrame);
	local minPercentLess = percentLessEdit:GetNumber();
	local catID = (UIDropDownMenu_GetSelectedID(getglobal(frameName.."CategoryDropDown")) or 1) - 1
	local minQuality = (UIDropDownMenu_GetSelectedID(getglobal(frameName.."MinQualityDropDown")) or 1) - 1;
	local itemName = getglobal(frameName.."SearchEdit"):GetText();
	if (itemName == "") then itemName = nil end
	
	frame:GetParent():SearchBuyouts(minProfit, minPercentLess, catID, minQuality, itemName);
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AuctionFrameSearchPlain_SearchButton_OnClick(button)
	local frame = button:GetParent();
	local frameName = frame:GetName();

	local maxPrice = MoneyInputFrame_GetCopper(getglobal(frameName.."MaxPrice")) or 0
	local catID = (UIDropDownMenu_GetSelectedID(getglobal(frameName.."CategoryDropDown")) or 1) - 1
	local minQuality = (UIDropDownMenu_GetSelectedID(getglobal(frameName.."MinQualityDropDown")) or 1) - 1;
	local itemName = getglobal(frameName.."SearchEdit"):GetText();
	if (itemName == "") then itemName = nil end
	
	frame:GetParent():SearchPlain(maxPrice, catID, minQuality, itemName);
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AuctionFrameSearchCompete_SearchButton_OnClick(button)
	local frame = button:GetParent();
	local undercutMoneyFrame = getglobal(frame:GetName().."Undercut");

	local minUndercut = MoneyInputFrame_GetCopper(undercutMoneyFrame);
	frame:GetParent():SearchCompetition(minUndercut);
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AuctionFrameSearch_OnBidResult(context, bidRequest)
	if (table.getn(bidRequest.results) == 0) then
		-- No auctions matched.
		context.auction.status = AUCTION_STATUS_NOT_FOUND;
	else
		-- Assume we are now the high bidder on all the matching auctions
		-- until proven otherwise.
		context.auction.status = AUCTION_STATUS_HIGH_BIDDER;
		for _,result in pairs(bidRequest.results) do
			if (result ~= BidResultCodes["BidAccepted"] and
				result ~= BidResultCodes["AlreadyHighBidder"] and
				result ~= BidResultCodes["OwnAuction"]) then
				context.auction.status = AUCTION_STATUS_UNKNOWN;
				break;
			end
		end
	end
	ListTemplateScrollFrame_Update(getglobal(context.frame.resultsList:GetName().."ScrollFrame"));
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AuctionFrameSearch_GetAuctionAlpha(auction)
	local status = auction.status;
	if (status and (status == AUCTION_STATUS_NOT_FOUND or status == AUCTION_STATUS_HIGH_BIDDER)) then
		return 0.4;
	end
	return 1.0;
end


