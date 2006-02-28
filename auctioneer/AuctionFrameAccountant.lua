--[[
	Auctioneer Addon for World of Warcraft(tm).
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
-------------------------------------------------------------------------------
function AuctionFrameAccountant_OnLoad()
	-- Methods
	this.SearchTransactions = AuctionFrameAccountant_SearchTransactions;

	-- Controls
	this.resultsList = getglobal(this:GetName().."List");

	-- Data members
	this.results = {};

	-- Configure the logical columns
	this.logicalColumns =
	{
		Date =
		{
			title = _AUCT("UiDate");
			dataType = "String";
			valueFunc = (function(record) return date("%c", record.date) end);
			compareAscendingFunc = (function(record1, record2) return record1.date < record2.date end);
			compareDescendingFunc = (function(record1, record2) return record1.date > record2.date end);
		},
		Quantity =
		{
			title = _AUCT("UiQuantityHeader");
			dataType = "Number";
			valueFunc = (function(record) return record.count end);
			compareAscendingFunc = (function(record1, record2) return record1.count < record2.count end);
			compareDescendingFunc = (function(record1, record2) return record1.count > record2.count end);
		},
		Name =
		{
			title = _AUCT("UiNameHeader");
			dataType = "String";
			valueFunc = (function(record) return record.name end);
			colorFunc = AuctionFrameAccountant_GetItemColor;
			compareAscendingFunc = (function(record1, record2) return record1.name < record2.name end);
			compareDescendingFunc = (function(record1, record2) return record1.name > record2.name end);
		},
		Net =
		{
			title = _AUCT("UiNetHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.net end);
			compareAscendingFunc = (function(record1, record2) return record1.net < record2.net end);
			compareDescendingFunc = (function(record1, record2) return record1.net > record2.net end);
		},
		NetPer =
		{
			title = _AUCT("UiNetPerHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.netPer end);
			compareAscendingFunc = (function(record1, record2) return record1.netPer < record2.netPer end);
			compareDescendingFunc = (function(record1, record2) return record1.netPer > record2.netPer end);
		},
		Price =
		{
			title = _AUCT("UiPriceHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.price end);
			compareAscendingFunc = (function(record1, record2) return record1.price < record2.price end);
			compareDescendingFunc = (function(record1, record2) return record1.price > record2.price end);
		},
		PricePer =
		{
			title = _AUCT("UiPricePerHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.pricePer end);
			compareAscendingFunc = (function(record1, record2) return record1.pricePer < record2.pricePer end);
			compareDescendingFunc = (function(record1, record2) return record1.pricePer > record2.pricePer end);
		},
		BuyerSeller =
		{
			title = _AUCT("UiBuyerSellerHeader");
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
			width = 140;
			logicalColumn = this.logicalColumns.Date;
			logicalColumns = { this.logicalColumns.Date };
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
function AuctionFrameAccountant_SearchTransactions(frame, itemName)
	-- Create the content from purhcases database.
	frame.results = {};
	if (itemName) then
		local purchases = Accountant.Purchases.GetPurchasesForItem(itemName);
		if (purchases) then
			for purchaseIndex in purchases do
				local purchase = {};
				purchase.date = purchases[purchaseIndex].time;
				purchase.count = purchases[purchaseIndex].quantity;
				purchase.name = itemName;
				purchase.price = purchases[purchaseIndex].cost;
				purchase.pricePer = math.floor(purchases[purchaseIndex].cost / purchases[purchaseIndex].quantity);
				purchase.net = -purchase.price;
				purchase.netPer = -purchase.pricePer;
				purchase.player = purchases[purchaseIndex].seller;
				table.insert(frame.results, purchase);
			end
		end
	else
		local itemNames = Accountant.Purchases.GetPurchasedItems();
		for itemNameIndex in itemNames do
			local purchases = Accountant.Purchases.GetPurchasesForItem(itemNames[itemNameIndex]);
			for purchaseIndex in purchases do
				local purchase = {};
				purchase.date = purchases[purchaseIndex].time;
				purchase.count = purchases[purchaseIndex].quantity;
				purchase.name = itemNames[itemNameIndex];
				purchase.price = purchases[purchaseIndex].cost;
				purchase.pricePer = math.floor(purchases[purchaseIndex].cost / purchases[purchaseIndex].quantity);
				purchase.net = -purchase.price;
				purchase.netPer = -purchase.pricePer;
				purchase.player = purchases[purchaseIndex].seller;
				table.insert(frame.results, purchase);
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

	frame:GetParent():SearchTransactions(itemName);
end

