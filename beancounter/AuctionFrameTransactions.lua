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

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit licence to use this AddOn with these facilities
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

-------------------------------------------------------------------------------
-- Function Prototypes
-------------------------------------------------------------------------------
local doesNameMatch
local nilSafeCompareAscending
local nilSafeCompareDescending
local clearResultList
local updateResultList
local updateResultListFromSearchFrame
local enableResults
local disableResults

-------------------------------------------------------------------------------
-- Called, when the AuctionFrameTransaction form is loaded
-------------------------------------------------------------------------------
function AuctionFrameTransactions_OnLoad()
	-- Controls
	local frameName               = this:GetName()
	this.searchFrame              = getglobal(frameName.."Search")
	this.resultsList              = getglobal(frameName.."List")

	local searchFrameName         = this.searchFrame:GetName()
	this.searchFrame.searchEdit   = getglobal(searchFrameName.."SearchEdit")
	this.searchFrame.exactCheck   = getglobal(searchFrameName.."ExactSearchCheckBox")
	this.searchFrame.bidCheck     = getglobal(searchFrameName.."BidCheckBox")
	this.searchFrame.buyCheck     = getglobal(searchFrameName.."BuyCheckBox")
	this.searchFrame.auctionCheck = getglobal(searchFrameName.."AuctionCheckBox")
	this.searchFrame.sellCheck    = getglobal(searchFrameName.."SellCheckBox")
	this.searchFrame.searchButton = getglobal(searchFrameName.."SearchButton")


	-- Configure the logical columns
	this.logicalColumns =
	{
		Date =
		{
			title = _BC("UiDateHeader");
			dataType = "String";
			valueFunc = (function(record) return date("%x", record.date) end);
			compareAscendingFunc = (function(record1, record2) return nilSafeCompareAscending(record1.date, record2.date) end);
			compareDescendingFunc = (function(record1, record2) return nilSafeCompareDescending(record1.date, record2.date) end);
		},
		Type =
		{
			title = _BC("UiTransactionTypeHeader");
			dataType = "String";
			valueFunc = (function(record) return record.transaction end);
			compareAscendingFunc = (function(record1, record2) return nilSafeCompareAscending(record1.transaction, record2.transaction) end);
			compareDescendingFunc = (function(record1, record2) return nilSafeCompareDescending(record1.transaction, record2.transaction) end);
		},
		Quantity =
		{
			title = _BC("UiQuantityHeader");
			dataType = "Number";
			valueFunc = (function(record) return record.count end);
			compareAscendingFunc = (function(record1, record2) return nilSafeCompareAscending(record1.count, record2.count) end);
			compareDescendingFunc = (function(record1, record2) return nilSafeCompareDescending(record1.count, record2.count) end);
		},
		Name =
		{
			title = _BC("UiNameHeader");
			dataType = "String";
			valueFunc = (function(record) return record.name end);
			colorFunc = AuctionFrameTransactions_GetItemColor;
			compareAscendingFunc = (function(record1, record2) return nilSafeCompareAscending(record1.name, record2.name) end);
			compareDescendingFunc = (function(record1, record2) return nilSafeCompareDescending(record1.name, record2.name) end);
		},
		Net =
		{
			title = _BC("UiNetHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.net end);
			compareAscendingFunc = (function(record1, record2) return nilSafeCompareAscending(record1.net, record2.net) end);
			compareDescendingFunc = (function(record1, record2) return nilSafeCompareDescending(record1.net, record2.net) end);
		},
		NetPer =
		{
			title = _BC("UiNetPerHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.netPer end);
			compareAscendingFunc = (function(record1, record2) return nilSafeCompareAscending(record1.netPer, record2.netPer) end);
			compareDescendingFunc = (function(record1, record2) return nilSafeCompareDescending(record1.netPer, record2.netPer) end);
		},
		Price =
		{
			title = _BC("UiPriceHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.price end);
			compareAscendingFunc = (function(record1, record2) return nilSafeCompareAscending(record1.price, record2.price) end);
			compareDescendingFunc = (function(record1, record2) return nilSafeCompareDescending(record1.price, record2.price) end);
		},
		PricePer =
		{
			title = _BC("UiPricePerHeader");
			dataType = "Money";
			valueFunc = (function(record) return record.pricePer end);
			compareAscendingFunc = (function(record1, record2) return nilSafeCompareAscending(record1.pricePer, record2.pricePer) end);
			compareDescendingFunc = (function(record1, record2) return nilSafeCompareDescending(record1.pricePer, record2.pricePer) end);
		},
		BuyerSeller =
		{
			title = _BC("UiBuyerSellerHeader");
			dataType = "String";
			valueFunc = (function(record) return record.player end);
			compareAscendingFunc = (function(record1, record2) return nilSafeCompareAscending(record1.player, record2.player) end);
			compareDescendingFunc = (function(record1, record2) return nilSafeCompareDescending(record1.player, record2.player) end);
		},
	}

	-- Configure the transaction search columns
	this.transactionSearchPhysicalColumns =
	{
		{
			width = 90;
			logicalColumn = this.logicalColumns.Date;
			logicalColumns = { this.logicalColumns.Date };
			sortAscending = true;
		},
		{
			width = 80;
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
			width = 100;
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
	}
end

-------------------------------------------------------------------------------
-- Called, when the user hits the search button
-------------------------------------------------------------------------------
function AuctionFrameSearchTransactions_SearchButton_OnClick()
	enableResults() -- enables and updates the result list
end

-------------------------------------------------------------------------------
-- Updates the search frame, using the given settings
--
-- parameters:
--   itemName      = item name for the search box
--   itemNameExact = flag for the exact item Name checkbox
--   transactions  = table, containing a list of flags for the transaction
--                   checkboxes
--                      bidCheck  = flag for the bid checkbox
--                      purchases = flag for the purchases checkbox
--                      auctions  = flag for the auctions checkbox
--                      sales     = flag for the sales checkbox
-- Note:
--    Any value can be nil, in which case the related control will not be
--    changed.
-------------------------------------------------------------------------------
function AuctionFrameTransactions_UpdateSearchFrame(itemName, itemNameExact, transactions)
	local searchFrame = getglobal("AuctionFrameTransactionsSearch")
	
	if itemName ~= nil then
		searchFrame.searchEdit:SetText(itemName)
	end
	if itemNameExact ~= nil then
		searchFrame.exactCheck:SetChecked(itemNameExact)
	end
	
	if transactions ~= nil then
		if transactions.purchases ~= nil then
			searchFrame.buyCheck:SetChecked(transactions.purchases)
		end
		if transactions.bids ~= nil then
			searchFrame.bidCheck:SetChecked(transactions.bids)
		end
		if transactions.sales ~= nil then
			searchFrame.sellCheck:SetChecked(transactions.sales)
		end
		if transactions.auctions ~= nil then
			searchFrame.auctionCheck:SetChecked(transactions.auctions)
		end
	end
	
	-- set the frame to display the results
	enableResults()
end

-------------------------------------------------------------------------------
-- Called, when the AuctionFrameTransaction result list is loaded
-------------------------------------------------------------------------------
function AuctionFrameTransactionsList_OnLoad()
	-- initially do not show any results	
	disableResults()
end

-------------------------------------------------------------------------------
-- Called, when the AuctionFrameTransaction result list is shown
-------------------------------------------------------------------------------
function AuctionFrameTransactionsList_OnShow()
	if not getglobal("AuctionFrameTransactionsList").bDisplayResults then
		clearResultList()
	else -- this.bDisplayResults is true
		-- update the result list
		updateResultListFromSearchFrame()
	end
end

-------------------------------------------------------------------------------
-- Enables displaying of results in the result list and updates it, if the
-- frame is visible
-------------------------------------------------------------------------------
function enableResults()
	getglobal("AuctionFrameTransactionsList").bDisplayResults = true
	AuctionFrameTransactionsList_OnShow()
end

-------------------------------------------------------------------------------
-- Disables displaying of results in the result list and updates it, if the
-- frame is visible
-------------------------------------------------------------------------------
function disableResults()
	getglobal("AuctionFrameTransactionsList").bDisplayResults = false
	AuctionFrameTransactionsList_OnShow()
end

-------------------------------------------------------------------------------
-- Updates the result list using the settings from the search frame
-------------------------------------------------------------------------------
function updateResultListFromSearchFrame()
	local searchFrame     = getglobal("AuctionFrameTransactionsSearch")
	local itemName        = searchFrame.searchEdit:GetText()
	local exactNameSearch = searchFrame.exactCheck:GetChecked()

	local transactions     = {
		bids      = searchFrame.bidCheck:GetChecked(),
		purchases = searchFrame.buyCheck:GetChecked(),
		auctions  = searchFrame.auctionCheck:GetChecked(),
		sales     = searchFrame.sellCheck:GetChecked()
	}

	updateResultList(itemName, exactNameSearch, transactions)
end

-------------------------------------------------------------------------------
-- Clears the result list
-------------------------------------------------------------------------------
function clearResultList()
	local resultList = getglobal("AuctionFrameTransactionsList")
	local emptyList  = {}

	ListTemplate_Initialize(resultList, emptyList, emptyList)
end

-------------------------------------------------------------------------------
-- Updates the result list, using the given settings
--
-- parameters:
--   itemName      = name to search for
--                   "" or nil, if any transaction should be shown
--   itemNameExact = true, if the search results must exactly match the itemName
--                   false, if the search results must only contain the itemName
--   transactions  = table, containing a list of which transactions to be
--                   included in the result list
--                      bidCheck  = true, if own bids should be included
--                                  false, otherwise
--                      purchases = true, if own purchases should be included
--                                  false, otherwise
--                      auctions  = true, if own auctions should be included
--                                  false, otherwise
--                      sales     = true, if own sales should be included
--                                  false, otherwise
-------------------------------------------------------------------------------
function updateResultList(itemName, itemNameExact, transactions)
	-- create the content from purhcases database
	local results = {}
	local itemNames
	local transaction

	-- Add the purchases
	if transactions.purchases then
		itemNames = BeanCounter.Purchases.GetPurchasedItems()
		for itemNameIndex in pairs(itemNames) do
			-- Check if this item matches the search criteria
			if (doesNameMatch(itemNames[itemNameIndex], itemName, itemNameExact)) then
				local purchases = BeanCounter.Purchases.GetPurchasesForItem(itemNames[itemNameIndex])
				for purchaseIndex in pairs(purchases) do
					transaction             = {}
					transaction.transaction = "Buy" --_BC('UiBuyTransaction')
					transaction.date        = purchases[purchaseIndex].time
					transaction.count       = purchases[purchaseIndex].quantity
					transaction.name        = itemNames[itemNameIndex]
					transaction.price       = purchases[purchaseIndex].cost
					transaction.pricePer    = math.floor(purchases[purchaseIndex].cost / purchases[purchaseIndex].quantity)
					transaction.net         = -transaction.price
					transaction.netPer      = -transaction.pricePer
					transaction.player      = purchases[purchaseIndex].seller
					table.insert(results, transaction)
				end
			end
		end
	end
	
	-- Add the bids
	if transactions.bids then
		local itemNames = BeanCounter.Purchases.GetPendingBidItems()
		for itemNameIndex in pairs(itemNames) do
			-- Check if this item matches the search criteria
			if (doesNameMatch(itemNames[itemNameIndex], itemName, itemNameExact)) then
				local pendingBids = BeanCounter.Purchases.GetPendingBidsForItem(itemNames[itemNameIndex])
				for pendingBidIndex in pairs(pendingBids) do
					transaction             = {};
					transaction.transaction = "Bid" --_BC('UiBidTransaction')
					transaction.date        = pendingBids[pendingBidIndex].time
					transaction.count       = pendingBids[pendingBidIndex].quantity
					transaction.name        = itemNames[itemNameIndex]
					transaction.price       = pendingBids[pendingBidIndex].bid
					transaction.pricePer    = math.floor(pendingBids[pendingBidIndex].bid / pendingBids[pendingBidIndex].quantity)
					transaction.net         = -transaction.price
					transaction.netPer      = -transaction.pricePer
					transaction.player      = pendingBids[pendingBidIndex].seller
					table.insert(results, transaction)
				end
			end
		end
	end

	-- Add the sales
	if transactions.sales then
		local itemNames = BeanCounter.Sales.GetSoldItems()
		for itemNameIndex in pairs(itemNames) do
			-- Check if this item matches the search criteria
			if (doesNameMatch(itemNames[itemNameIndex], itemName, itemNameExact)) then
				local sales = BeanCounter.Sales.GetSalesForItem(itemNames[itemNameIndex])
				for saleIndex in pairs(sales) do
					transaction        = {}
					transaction.date   = sales[saleIndex].time
					transaction.name   = itemNames[itemNameIndex]
					transaction.count  = sales[saleIndex].quantity
					transaction.net    = sales[saleIndex].net
					transaction.netPer = math.floor(transaction.net / transaction.count)
					if (sales[saleIndex].result == 0) then
						transaction.transaction = "Sell" --_BC('UiSellTransaction')
						transaction.price       = sales[saleIndex].price
						transaction.pricePer    = math.floor(transaction.price / transaction.count)
						transaction.player      = sales[saleIndex].buyer
					else
						transaction.transaction = "Deposit" --_BC('UiDepositTransaction')
						transaction.price       = sales[saleIndex].buyout
						transaction.pricePer    = math.floor(transaction.price / transaction.count)
						transaction.player      = ""
					end
					table.insert(results, transaction)
				end
			end			
		end
	end

	-- Add the auctions
	if transactions.auctions then
		local itemNames = BeanCounter.Sales.GetPendingAuctionItems()
		for itemNameIndex in pairs(itemNames) do
			-- Check if this item matches the search criteria
			if (doesNameMatch(itemNames[itemNameIndex], itemName, itemNameExact)) then
				local auctions = BeanCounter.Sales.GetPendingAuctionsForItem(itemNames[itemNameIndex])
				for auctionIndex in pairs(auctions) do
					local transaction       = {}
					transaction.transaction = "Auction" --_BC('UiAuctionTransaction')
					transaction.date        = auctions[auctionIndex].time
					transaction.count       = auctions[auctionIndex].quantity
					transaction.name        = itemNames[itemNameIndex]
					transaction.price       = auctions[auctionIndex].buyout
					transaction.pricePer    = math.floor(transaction.price / transaction.count)
					transaction.net         = -auctions[auctionIndex].deposit
					transaction.netPer      = math.floor(transaction.net / transaction.count)
					transaction.player      = ""
					table.insert(results, transaction)
				end
			end			
		end
	end

	-- Hand the updated results to the list
	local transactionFrame = getglobal("AuctionFrameTransactions")
	ListTemplate_Initialize(transactionFrame.resultsList, transactionFrame.transactionSearchPhysicalColumns, transactionFrame.logicalColumns)
	ListTemplate_SetContent(transactionFrame.resultsList, results)
	ListTemplate_Sort(transactionFrame.resultsList, 1)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function doesNameMatch(name1, name2, exact)
	local match = true;
	if (name1 ~= nil and name2 ~= nil) then
		if (exact) then
			match = (name1:lower() == name2:lower())
		else
			match = (name1:lower():find(name2:lower(), 1, true) ~= nil)
		end
	end
	return match
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function nilSafeCompareAscending(value1, value2)
	if (value1 == nil and value2 == nil) then
		return false
	elseif (value1 == nil and value2 ~= nil) then
		return true
	elseif (value1 ~= nil and value2 == nil) then
		return false
	end
	return (value1 < value2)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function nilSafeCompareDescending(value1, value2)
	if (value1 == nil and value2 == nil) then
		return false
	elseif (value1 == nil and value2 ~= nil) then
		return false
	elseif (value1 ~= nil and value2 == nil) then
		return true
	end
	return (value1 > value2)
end
