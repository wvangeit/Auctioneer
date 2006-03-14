--[[
	BeanCounter Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	Auctioneer Accoutant tab

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
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
--]]

-------------------------------------------------------------------------------
-- Function Prototypes
-------------------------------------------------------------------------------
local doesNameMatch;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AuctionFrameTransactions_OnLoad()
	-- Methods
	this.SearchTransactions = AuctionFrameTransactions_SearchTransactions;

	-- Controls
	this.resultsList = getglobal(this:GetName().."List");

	-- Data members
	this.results = {};

	-- Configure the logical columns
	this.logicalColumns =
	{
		Date =
		{
			title = _BC("UiDate");
			dataType = "String";
			valueFunc = (function(record) return date("%x", record.date) end);
			compareAscendingFunc = (function(record1, record2) return record1.date < record2.date end);
			compareDescendingFunc = (function(record1, record2) return record1.date > record2.date end);
		},
		Type =
		{
			title = _BC("UiTypeHeader");
			dataType = "String";
			valueFunc = (function(record) return record.transaction end);
			compareAscendingFunc = (function(record1, record2) return record1.transaction < record2.transaction end);
			compareDescendingFunc = (function(record1, record2) return record1.transaction > record2.transaction end);
		},
		Quantity =
		{
			title = _BC("UiQuantityHeader");
			dataType = "Number";
			valueFunc = (function(record) return record.count end);
			compareAscendingFunc = (function(record1, record2) return record1.count < record2.count end);
			compareDescendingFunc = (function(record1, record2) return record1.count > record2.count end);
		},
		Name =
		{
			title = _BC("UiNameHeader");
			dataType = "String";
			valueFunc = (function(record) return record.name end);
			colorFunc = AuctionFrameTransactions_GetItemColor;
			compareAscendingFunc = (function(record1, record2) return record1.name < record2.name end);
			compareDescendingFunc = (function(record1, record2) return record1.name > record2.name end);
		},
		Net =
		{
			title = _BC("UiNetHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.net end);
			compareAscendingFunc = (function(record1, record2) return record1.net < record2.net end);
			compareDescendingFunc = (function(record1, record2) return record1.net > record2.net end);
		},
		NetPer =
		{
			title = _BC("UiNetPerHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.netPer end);
			compareAscendingFunc = (function(record1, record2) return record1.netPer < record2.netPer end);
			compareDescendingFunc = (function(record1, record2) return record1.netPer > record2.netPer end);
		},
		Price =
		{
			title = _BC("UiPriceHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.price end);
			compareAscendingFunc = (function(record1, record2) return record1.price < record2.price end);
			compareDescendingFunc = (function(record1, record2) return record1.price > record2.price end);
		},
		PricePer =
		{
			title = _BC("UiPricePerHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.pricePer end);
			compareAscendingFunc = (function(record1, record2) return record1.pricePer < record2.pricePer end);
			compareDescendingFunc = (function(record1, record2) return record1.pricePer > record2.pricePer end);
		},
		BuyerSeller =
		{
			title = _BC("UiBuyerSellerHeader");
			dataType = "String";
			valueFunc = (function(record) return record.player end);
			compareAscendingFunc = (function(record1, record2) return record1.player < record2.player end);
			compareDescendingFunc = (function(record1, record2) return record1.player > record2.player end);
		},
	};

	-- Configure the transaction search columns
	this.transactionSearchPhysicalColumns =
	{
		{
			width = 80;
			logicalColumn = this.logicalColumns.Date;
			logicalColumns = { this.logicalColumns.Date };
			sortAscending = true;
		},
		{
			width = 60;
			logicalColumn = this.logicalColumns.Type;
			logicalColumns = { this.logicalColumns.Type };
			sortAscending = true;
		},
		{
			width = 50;
			logicalColumn = this.logicalColumns.Quantity;
			logicalColumns = { this.logicalColumns.Quantity };
			sortAscending = true;
		},
		{
			width = 160;
			logicalColumn = this.logicalColumns.Name;
			logicalColumns = { this.logicalColumns.Name };
			sortAscending = true;
		},
		{
			width = 130;
			logicalColumn = this.logicalColumns.Net;
			logicalColumns =
			{
				this.logicalColumns.Net,
				this.logicalColumns.NetPer,
				this.logicalColumns.Price,
				this.logicalColumns.PricePer
			};
			sortAscending = true;
		},
		{
			width = 130;
			logicalColumn = this.logicalColumns.BuyerSeller;
			logicalColumns = { this.logicalColumns.BuyerSeller };
			sortAscending = true;
		},
	};

	-- Initialize the list to show nothing at first.
	ListTemplate_Initialize(this.resultsList, this.results, this.results);
end

-------------------------------------------------------------------------------
-- Perform a transaction search
-------------------------------------------------------------------------------
function AuctionFrameTransactions_SearchTransactions(frame, itemName, itemNameExact, transactions)
	-- Create the content from purhcases database.
	frame.results = {};
	
	-- Add the purchases
	if (transactions == nil or transactions.purchases) then
		local itemNames = BeanCounter.Purchases.GetPurchasedItems();
		for itemNameIndex in itemNames do
			-- Check if this item matches the search criteria
			if (doesNameMatch(itemNames[itemNameIndex], itemName, itemNameExact)) then
				local purchases = BeanCounter.Purchases.GetPurchasesForItem(itemNames[itemNameIndex]);
				for purchaseIndex in purchases do
					local transaction = {};
					transaction.transaction = "Buy"; --_BC('UiBuyTransaction');
					transaction.date = purchases[purchaseIndex].time;
					transaction.count = purchases[purchaseIndex].quantity;
					transaction.name = itemNames[itemNameIndex];
					transaction.price = purchases[purchaseIndex].cost;
					transaction.pricePer = math.floor(purchases[purchaseIndex].cost / purchases[purchaseIndex].quantity);
					transaction.net = -transaction.price;
					transaction.netPer = -transaction.pricePer;
					transaction.player = purchases[purchaseIndex].seller;
					table.insert(frame.results, transaction);
				end
			end
		end
	end
	
	-- Add the bids
	if (transactions == nil or transactions.bids) then
		local itemNames = BeanCounter.Purchases.GetPendingBidItems();
		for itemNameIndex in itemNames do
			-- Check if this item matches the search criteria
			if (doesNameMatch(itemNames[itemNameIndex], itemName, itemNameExact)) then
				local pendingBids = BeanCounter.Purchases.GetPendingBidsForItem(itemNames[itemNameIndex]);
				for pendingBidIndex in pendingBids do
					local transaction = {};
					transaction.transaction = "Bid"; --_BC('UiBidTransaction');
					transaction.date = pendingBids[pendingBidIndex].time;
					transaction.count = pendingBids[pendingBidIndex].quantity;
					transaction.name = itemNames[itemNameIndex];
					transaction.price = pendingBids[pendingBidIndex].bid;
					transaction.pricePer = math.floor(pendingBids[pendingBidIndex].bid / pendingBids[pendingBidIndex].quantity);
					transaction.net = -transaction.price;
					transaction.netPer = -transaction.pricePer;
					transaction.player = pendingBids[pendingBidIndex].seller;
					table.insert(frame.results, transaction);
				end
			end
		end
	end

	-- Hand the updated results to the list.
	ListTemplate_Initialize(frame.resultsList, frame.transactionSearchPhysicalColumns, frame.logicalColumns);
	ListTemplate_SetContent(frame.resultsList, frame.results);
	ListTemplate_Sort(frame.resultsList, 1);
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AuctionFrameSearchTransactions_SearchButton_OnClick(button)
	local frame = button:GetParent();
	local frameName = frame:GetName();

	local itemName = getglobal(frameName.."SearchEdit"):GetText();
	if (itemName == "") then itemName = nil end
	local exactNameSearch = getglobal(frame:GetName().."ExactSearchCheckBox"):GetChecked();
	local transactions = {};
	transactions.bids = getglobal(frame:GetName().."BidCheckBox"):GetChecked();
	transactions.purchases = getglobal(frame:GetName().."BuyCheckBox"):GetChecked();

	frame:GetParent():SearchTransactions(itemName, exactNameSearch, transactions);
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function doesNameMatch(name1, name2, exact)
	local match = true;
	if (name1 ~= nil and name2 ~= nil) then
		if (exact) then
			match = (string.lower(name1) == string.lower(name2));
		else
			match = (string.find(string.lower(name1), string.lower(name2), 1, true) ~= nil);
		end
	end
	return match;
end
