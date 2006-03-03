--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	PurchasesDB - manages the database of AH purchases

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
-- Data Members
-------------------------------------------------------------------------------
AHPurchases = {};

local NIL_VALUE = "<nil>";

-------------------------------------------------------------------------------
-- Function Prototypes
-------------------------------------------------------------------------------
local addPendingBid;
local packPendingBid;
local unpackPendingBid;
local getPendingBidsTableForItem;
local isPendingBid;
local printPendingBids;

local addSuccessfulBid;
local addFailedBid;
local addCompletedBid;
local packCompletedBid;
local unpackCompletedBid;
local getCompletedBidsTableForItem;
local printCompletedBids;

local addPurchase;
local packPurchase;
local unpackPurchase;
local getPurchasesTableForItem;
local getPurchasedItems;
local getPurchasesForItem;
local printPurchases;

local reconcileBids;
local reconcileBidsByQuantity;
local reconcileBidsByBid;
local reconcileMatchingBidList;

local resetDatabase;
local getBidNonNilFieldCount;
local compareBidsByNonNilFieldCount;
local stringFromBoolean;
local booleanFromString;
local stringFromNumber;
local numberFromString;
local nilSafeStringFromString;
local stringFromNilSafeString;

--=============================================================================
-- Pending Bids functions
--=============================================================================

-------------------------------------------------------------------------------
-- Adds a pending bid to the database
-------------------------------------------------------------------------------
function addPendingBid(item, quantity, bid, seller, isBuyout)
	if (item and quantity and bid) then
		-- If its a buyout, record a purchase now.
		if (isBuyout) then
			addPurchase(time(), item, quantity, bid, seller, isBuyout, true);
		end

		-- Create a packed record.
		local pendingBid = {};
		pendingBid.time = time();
		pendingBid.quantity = quantity;
		pendingBid.bid = bid;
		pendingBid.seller = seller;
		pendingBid.isBuyout = isBuyout;
		local packedPendingBid = packPendingBid(pendingBid);

		-- Add the pending bid to the table.
		local pendingBidsTable = getPendingBidsTableForItem(item);
		table.insert(pendingBidsTable, packedPendingBid);

		-- Debugging noise.
		debugPrint("[Purchases] Added pending bid: "..date("%c", pendingBid.time)..", "..item..", "..pendingBid.quantity..", "..pendingBid.bid..", "..nilSafeStringFromString(pendingBid.seller)..", "..stringFromBoolean(pendingBid.isBuyout));
	else
		debugPrint("Invalid call to addPendingBid()");
	end
end

-------------------------------------------------------------------------------
-- Converts a pending bid into a ';' delimited string.
-------------------------------------------------------------------------------
function packPendingBid(pendingBid)
	return
		pendingBid.time..";"..
		stringFromNumber(pendingBid.quantity)..";"..
		stringFromNumber(pendingBid.bid)..";"..
		nilSafeStringFromString(pendingBid.seller)..";"..
		stringFromBoolean(pendingBid.isBuyout);
end

-------------------------------------------------------------------------------
-- Converts a ';' delimited string into a pending bid.
-------------------------------------------------------------------------------
function unpackPendingBid(packedPendingBid)
	local pendingBid = {};
	_, _, pendingBid.time, pendingBid.quantity, pendingBid.bid, pendingBid.seller, pendingBid.isBuyout = string.find(packedPendingBid, "(%d+);(%d+);(%d+);(.+);(.+)");
	pendingBid.quantity = numberFromString(pendingBid.quantity);
	pendingBid.bid = numberFromString(pendingBid.bid);
	pendingBid.seller = stringFromNilSafeString(pendingBid.seller);
	pendingBid.isBuyout = booleanFromString(pendingBid.isBuyout);
	return pendingBid;
end

-------------------------------------------------------------------------------
-- Gets the pending bids table for the specified item. The table contains
-- packed records.
-------------------------------------------------------------------------------
function getPendingBidsTableForItem(item)
	local pendingBidsTable = AHPurchases.PendingBids;
	if (pendingBidsTable == nil) then
		pendingBidsTable = {};
		AHPurchases.PendingBids = pendingBidsTable;
	end
	local pendingBidsForItemTable = pendingBidsTable[item];
	if (pendingBidsForItemTable == nil) then
		pendingBidsForItemTable = {};
		pendingBidsTable[item] = pendingBidsForItemTable;
	end
	return pendingBidsForItemTable;
end

-------------------------------------------------------------------------------
-- Prints the pending bids.
-------------------------------------------------------------------------------
function printPendingBids()
	chatPrint("Pending Bids:");
	if (AHPurchases.PendingBids) then
		for item in AHPurchases.PendingBids do
			local pendingBidsTable = AHPurchases.PendingBids[item];
			for index = 1, table.getn(pendingBidsTable) do
				local pendingBid = unpackPendingBid(pendingBidsTable[index]);
				chatPrint(date("%c", pendingBid.time)..", "..item..", "..stringFromNumber(pendingBid.quantity)..", "..stringFromNumber(pendingBid.bid)..", "..nilSafeStringFromString(pendingBid.seller)..", "..stringFromBoolean(pendingBid.isBuyout)..", "..stringFromBoolean(pendingBid.isSuccessful));
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Checks if there is a potential pending bid.
-------------------------------------------------------------------------------
function isPendingBid(item, quantity, bid, seller, isBuyout, isSuccessful)
	local pendingBids = getPendingBidsTableForItem(item);
	for index = 1, table.getn(pendingBids) do
		local pendingBid = unpackPendingBid(pendingBids[index]);
		if ((quantity == nil or pendingBid.quantity == nil or quantity == pendingBid.quantity) and
			(bid == nil or pendingBid.bid == nil or bid == pendingBid.bid) and
			(seller == nil or pendingBid.seller == nil or seller == pendingBid.seller) and
			(isBuyout == nil or pendingBid.isBuyout == nil or isBuyout == pendingBid.isBuyout) and
			(isSuccessful == nil or pendingBid.isSuccessful == nil or isSuccessful == pendingBid.isSuccessful)) then
			return true;
		end
	end
	return false;
end

--=============================================================================
-- Completed Bids functions
--=============================================================================

-------------------------------------------------------------------------------
-- Adds a successful bid to the database
-------------------------------------------------------------------------------
function addSuccessfulBid(item, quantity, bid, seller, isBuyout)
	addCompletedBid(item, quantity, bid, seller, isBuyout, true);
end

-------------------------------------------------------------------------------
-- Adds a successful bid to the database
-------------------------------------------------------------------------------
function addFailedBid(item, bid)
	addCompletedBid(item, nil, bid, nil, nil, false);
end

-------------------------------------------------------------------------------
-- Adds a completed bid to the database
-------------------------------------------------------------------------------
function addCompletedBid(item, quantity, bid, seller, isBuyout, isSuccessful)
	if (item and (quantity or bid)) then
		-- Check if we have enough information to add the purchase now.
		local isPurchaseRecorded = false;
		if (quantity and bid and seller and isBuyout ~= nil and isSuccessful) then
			addPurchase(time(), item, quantity, bid, seller, isBuyout, true);
			isPurchaseRecorded = true;
		end

		-- Add the completed bid.
		if (isPendingBid(item, quantity, bid, seller, isBuyout, isSuccessful)) then
			-- Create a packed record.
			local completedBid = {};
			completedBid.time = time();
			completedBid.quantity = quantity;
			completedBid.bid = bid;
			completedBid.seller = seller;
			completedBid.isBuyout = isBuyout;
			completedBid.isSuccessful = isSuccessful;
			completedBid.isPurchaseRecorded = isPurchaseRecorded;
			local packedCompletedBid = packCompletedBid(completedBid);

			-- Add the completed bid to the table.
			local completedBids = getCompletedBidsTableForItem(item);
			table.insert(completedBids, packedCompletedBid);
			debugPrint("[Purchases] Added completed bid: "..date("%c", completedBid.time)..", "..item..", "..stringFromNumber(completedBid.quantity)..", "..stringFromNumber(completedBid.bid)..", "..nilSafeStringFromString(completedBid.seller)..", "..stringFromBoolean(completedBid.isBuyout)..", "..stringFromBoolean(completedBid.isSuccessful)..", "..stringFromBoolean(completedBid.isPurchaseRecorded));

			-- Attmept to reconcile bids for this item.
			reconcileBids(item);
		end
	else
		debugPrint("Invalid call to addCompletedBid()");
	end
end

-------------------------------------------------------------------------------
-- Converts a completed bid into a ';' delimited string.
-------------------------------------------------------------------------------
function packCompletedBid(completedBid)
	return 
		completedBid.time..";"..
		stringFromNumber(completedBid.quantity)..";"..
		stringFromNumber(completedBid.bid)..";"..
		nilSafeStringFromString(completedBid.seller)..";"..
		stringFromBoolean(completedBid.isBuyout)..";"..
		stringFromBoolean(completedBid.isSuccessful)..";"..
		stringFromBoolean(completedBid.isPurchaseRecorded);
end

-------------------------------------------------------------------------------
-- Converts a ';' delimited string into a completed bid.
-------------------------------------------------------------------------------
function unpackCompletedBid(packedCompletedBid)
	local completedBid = {};
	_, _, completedBid.time, completedBid.quantity, completedBid.bid, completedBid.seller, completedBid.isBuyout, completedBid.isSuccessful, completedBid.isPurchaseRecorded = string.find(packedCompletedBid, "(%d+);(.+);(.+);(.+);(.+);(.+);(.+)");
	completedBid.quantity = numberFromString(completedBid.quantity);
	completedBid.bid = numberFromString(completedBid.bid);
	completedBid.seller = stringFromNilSafeString(completedBid.seller);
	completedBid.isBuyout = booleanFromString(completedBid.isBuyout);
	completedBid.isSuccessful = booleanFromString(completedBid.isSuccessful);
	completedBid.isPurchaseRecorded = booleanFromString(completedBid.isPurchaseRecorded);
	return completedBid;
end

-------------------------------------------------------------------------------
-- Gets the completed bids table for the specified item. The table contains
-- packed records.
-------------------------------------------------------------------------------
function getCompletedBidsTableForItem(item)
	local completedBidsTable = AHPurchases.CompletedBids;
	if (completedBidsTable == nil) then
		completedBidsTable = {};
		AHPurchases.CompletedBids = completedBidsTable;
	end
	local completedBidsForItemTable = completedBidsTable[item];
	if (completedBidsForItemTable == nil) then
		completedBidsForItemTable = {};
		completedBidsTable[item] = completedBidsForItemTable;
	end
	return completedBidsForItemTable;
end

-------------------------------------------------------------------------------
-- Prints the completed bids.
-------------------------------------------------------------------------------
function printCompletedBids()
	chatPrint("Completed Bids:");
	if (AHPurchases.CompletedBids) then
		for item in AHPurchases.CompletedBids do
			local completedBidsTable = AHPurchases.CompletedBids[item];
			for index = 1, table.getn(completedBidsTable) do
				local completedBid = unpackCompletedBid(completedBidsTable[index]);
				chatPrint(date("%c", completedBid.time)..", "..item..", "..stringFromNumber(completedBid.quantity)..", "..stringFromNumber(completedBid.bid)..", "..nilSafeStringFromString(completedBid.seller)..", "..stringFromBoolean(completedBid.isBuyout)..", "..stringFromBoolean(completedBid.isSuccessful));
			end
		end
	end
end

--=============================================================================
-- Purchases functions
--=============================================================================

-------------------------------------------------------------------------------
-- Adds a purchase to the database.
-------------------------------------------------------------------------------
function addPurchase(time, item, quantity, cost, seller, isBuyout)
	if (item and quantity and cost) then
		-- Create a packed record.
		local purchase = {};
		purchase.time = time;
		purchase.quantity = quantity;
		purchase.cost = cost;
		purchase.seller = seller;
		purchase.isBuyout = isBuyout;
		local packedPurchase = packPurchase(purchase);

		-- Add the purchase to the table.
		local purchasesTable = getPurchasesTableForItem(item, true);
		table.insert(purchasesTable, packedPurchase);

		-- Debugging noise.
		debugPrint("[Purchases] Added purchase: "..date("%c", purchase.time)..", "..item..", "..purchase.quantity..", "..purchase.cost..", "..nilSafeStringFromString(purchase.seller)..", "..stringFromBoolean(purchase.isBuyout));
	else
		debugPrint("Invalid call to addPurchase()");
	end
end

-------------------------------------------------------------------------------
-- Converts a purchase into a ';' delimited string.
-------------------------------------------------------------------------------
function packPurchase(purchase)
	return
		purchase.time..";"..
		stringFromNumber(purchase.quantity)..";"..
		stringFromNumber(purchase.cost)..";"..
		nilSafeStringFromString(purchase.seller)..";"..
		stringFromBoolean(purchase.isBuyout);
end

-------------------------------------------------------------------------------
-- Converts a ';' delimited string into a purchase.
-------------------------------------------------------------------------------
function unpackPurchase(packedPurchase)
	local purchase = {};
	_, _, purchase.time, purchase.quantity, purchase.cost, purchase.seller, purchase.isBuyout = string.find(packedPurchase, "(%d+);(%d+);(%d+);(.+);(.+)");
	purchase.quantity = stringFromNilSafeString(purchase.quantity);
	purchase.cost = numberFromString(purchase.cost);
	purchase.seller = stringFromNilSafeString(purchase.seller);
	purchase.isBuyout = booleanFromString(purchase.isBuyout);
	return purchase;
end

-------------------------------------------------------------------------------
-- Gets the purchases table for the specified item. The table contains packed
-- records.
-------------------------------------------------------------------------------
function getPurchasesTableForItem(item, create)
	local purchasesTable = AHPurchases.Purchases;
	if (purchasesTable == nil) then
		purchasesTable = {};
		AHPurchases.Purchases = purchasesTable;
	end
	local purchasesForItemTable = purchasesTable[item];
	if (purchasesForItemTable == nil and create) then
		purchasesForItemTable = {};
		purchasesTable[item] = purchasesForItemTable;
	end
	return purchasesForItemTable;
end

-------------------------------------------------------------------------------
-- Gets the list of puchased items.
-------------------------------------------------------------------------------
function getPurchasedItems(item)
	local items = {};
	if (AHPurchases.Purchases) then
		for item in AHPurchases.Purchases do
			local purchasesTable = getPurchasesTableForItem(item);
			if (purchasesTable and table.getn(purchasesTable) > 0) then
				table.insert(items, item);
			end
		end
	end
	return items;
end

-------------------------------------------------------------------------------
-- Gets the purchases (unpacked) for the specified item
-------------------------------------------------------------------------------
function getPurchasesForItem(item)
	local purchases = {};
	local purchasesTable = getPurchasesTableForItem(item);
	if (purchasesTable) then
		for index in purchasesTable do
			local purchase = unpackPurchase(purchasesTable[index]);
			table.insert(purchases, purchase);
		end
	end
	return purchases;
end

-------------------------------------------------------------------------------
-- Prints the purchases.
-------------------------------------------------------------------------------
function printPurchases()
	chatPrint("Purchases:");
	if (AHPurchases.Purchases) then
		for item in AHPurchases.Purchases do
			local purchasesTable = AHPurchases.Purchases[item];
			for index = 1, table.getn(purchasesTable) do
				local purchase = unpackPurchase(purchasesTable[index]);
				chatPrint(date("%c", purchase.time)..", "..item..", "..purchase.quantity..", "..purchase.cost..", "..nilSafeStringFromString(purchase.seller)..", "..stringFromBoolean(purchase.isBuyout));
			end
		end
	end
end

--=============================================================================
-- Bid reconcilation functions
--=============================================================================

-------------------------------------------------------------------------------
-- Attempts to match completed bids with pending bids
-------------------------------------------------------------------------------
function reconcileBids(item)
	debugPrint("[Purchases] -- Begin reconciling bids for "..item.."--");

	-- Now attempt to reconcile bids by either quantity or bid.
	local index = 1;
	local quantitiesAttempted = {};
	local bidsAttempted = {};
	local completedBids = getCompletedBidsTableForItem(item);
	while (index <= table.getn(completedBids)) do
		local completedBid = unpackCompletedBid(completedBids[index]);
		if (completedBid.quantity and not quantitiesAttempted[completedBid.quantity]) then
			quantitiesAttempted[completedBid.quantity] = true;
			if (reconcileBidsByQuantity(item, completedBid.quantity)) then
				index = 1;
				bidsAttempted = {};
			else
				index = index + 1;
			end
		elseif (completedBid.bid and not bidsAttempted[completedBid.bid]) then
			bidsAttempted[completedBid.bid] = true;
			if (reconcileBidsByBid(item, completedBid.bid)) then
				index = 1;
				quantitiesAttempted = {};
			else
				index = index + 1;
			end
		else
			index = index + 1;
		end
	end

	debugPrint("[Purchases] -- End reconciling bids for "..item.." --");
end

-------------------------------------------------------------------------------
-- Attempts to reconcile bids by quantity
-------------------------------------------------------------------------------
function reconcileBidsByQuantity(item, quantity)
	debugPrint("[Purchases] reconcileBidsByQuantity("..item..", "..quantity..")");
	local reconciled = false;

	-- Get all the pending bids matching the quantity
	local pendingBidIndicies = {};
	local pendingBids = getPendingBidsTableForItem(item);
	for index = 1, table.getn(pendingBids) do
		local pendingBid = unpackPendingBid(pendingBids[index]);
		if (pendingBid.quantity == quantity) then
			table.insert(pendingBidIndicies, index);
		end
	end
	debugPrint("[Purchases] "..table.getn(pendingBidIndicies).." matching pending bids");
	
	-- Get all the completed bids matching the quantity
	local completedBidIndicies = {};
	local completedBids = getCompletedBidsTableForItem(item);
	for index = 1, table.getn(completedBids) do
		local completedBid = unpackCompletedBid(completedBids[index]);
		if (completedBid.quantity == quantity) then
			table.insert(completedBidIndicies, index);
		end
	end
	debugPrint("[Purchases] "..table.getn(completedBidIndicies).." matching completed bids");
	
	-- We can reconcile all the bids if the number of bids match. Otherwise
	-- we can reconcile some of the bids if all of the pending bids match.
	if (table.getn(pendingBidIndicies) == table.getn(completedBidIndicies)) then
		-- The number of pending and completed bids match, so reconcile them all!
		reconcileMatchingBidList(item, pendingBids, pendingBidIndicies, completedBids, completedBidIndicies);
		reconciled = true;
	elseif (table.getn(pendingBidIndicies) > 0 and table.getn(completedBidIndicies) > 0) then
		-- The number of pending and completed bids don't match, but we can still
		-- reconcile some of them if all of the pending bids match.
		reconciled = true;
		local pendingBid = unpackPendingBid(pendingBids[pendingBidIndicies[1]]);
		local bid = pendingBid.bid;
		local seller = pendingBid.seller;
		local isBuyout = pendingBid.isBuyout;
		for index = 2, table.getn(pendingBidIndicies) do
			local pendingBid = unpackPendingBid(pendingBids[pendingBidIndicies[index]]);
			if (bid ~= pendingBid.bid or
				seller ~= pendingBid.seller or
				isBuyout ~= pendingBid.isBuyout) then
				reconciled = false;
				break;
			end
		end
		
		-- If all of the pending bids match we can reconcile the completed bids.
		if (reconciled) then
			reconcileMatchingBidList(item, pendingBids, pendingBidIndicies, completedBids, completedBidIndicies);
		end
	end
	
	return reconciled;
end

-------------------------------------------------------------------------------
-- Attempts to reconcile bids by bid
-------------------------------------------------------------------------------
function reconcileBidsByBid(item, bid)
	debugPrint("[Purchases] reconcileBidsByBid("..item..", "..bid..")");
	local reconciled = false;

	-- Get all the pending bids matching the bid
	local pendingBidIndicies = {};
	local pendingBids = getPendingBidsTableForItem(item);
	for index = 1, table.getn(pendingBids) do
		local pendingBid = unpackPendingBid(pendingBids[index]);
		if (pendingBid.bid == bid) then
			table.insert(pendingBidIndicies, index);
		end
	end
	debugPrint("[Purchases] "..table.getn(pendingBidIndicies).." matching pending bids");
	
	-- Get all the completed bids matching the bid
	local completedBidIndicies = {};
	local completedBids = getCompletedBidsTableForItem(item);
	for index = 1, table.getn(completedBids) do
		local completedBid = unpackCompletedBid(completedBids[index]);
		if (completedBid.bid == bid) then
			table.insert(completedBidIndicies, index);
		end
	end
	debugPrint("[Purchases] "..table.getn(pendingBidIndicies).." matching completed bids");
	
	-- We can reconcile all the bids if the number of bids match
	if (table.getn(pendingBidIndicies) == table.getn(completedBidIndicies)) then
		reconcileMatchingBidList(item, pendingBids, pendingBidIndicies, completedBids, completedBidIndicies);
		reconciled = true;
	elseif (table.getn(pendingBidIndicies) > 0 and table.getn(completedBidIndicies) > 0) then
		-- The number of pending and completed bids don't match, but we can still
		-- reconcile some of them if all of the pending bids match.
		reconciled = true;
		local pendingBid = unpackPendingBid(pendingBids[pendingBidIndicies[1]]);
		local quantity = pendingBid.quantity;
		local seller = pendingBid.seller;
		local isBuyout = pendingBid.isBuyout;
		for index = 2, table.getn(pendingBidIndicies) do
			local pendingBid = unpackPendingBid(pendingBids[pendingBidIndicies[index]]);
			if (quantity ~= pendingBid.quantity or
				seller ~= pendingBid.seller or
				isBuyout ~= pendingBid.isBuyout) then
				reconciled = false;
				break;
			end
		end
		
		-- If all of the pending bids match we can reconcile the completed bids.
		if (reconciled) then
			reconcileMatchingBidList(item, pendingBids, pendingBidIndicies, completedBids, completedBidIndicies);
		end
	end
	
	return reconciled;
end

-------------------------------------------------------------------------------
-- Reconciles the list of completed bid indicies against the pending bid list.
-------------------------------------------------------------------------------
function reconcileMatchingBidList(item, pendingBidsTable, pendingBidIndicies, completedBidsTable, completedBidIndicies)
	-- Construct an unpacked list of pending bids.
	local pendingBids = {};
	for index in pendingBidIndicies do
		local pendingBid = unpackPendingBid(pendingBidsTable[pendingBidIndicies[index]]);
		pendingBid.index = pendingBidIndicies[index];
		table.insert(pendingBids, pendingBid);
	end
	table.sort(pendingBids, compareBidsByNonNilFieldCount);

	-- Construct an unpacked list of completed bids.
	local completedBids = {};
	for index in completedBidIndicies do
		local completedBid = unpackCompletedBid(completedBidsTable[completedBidIndicies[index]]);
		completedBid.index = completedBidIndicies[index];
		table.insert(completedBids, completedBid);
	end
	table.sort(completedBids, compareBidsByNonNilFieldCount);

	-- Now match up each completed bid with a pending bid.
	while (table.getn(pendingBids) > 0 and table.getn(completedBids) > 0) do
		local completedBid = completedBids[1];

		-- Remove the completed bid.
		table.remove(completedBids, 1);
		local completedBidTablesIndex = completedBid.index;
		table.remove(completedBidsTable, completedBidTablesIndex);
		debugPrint("[Purchases] Removed completed bid: "..date("%c", completedBid.time)..", "..item..", "..stringFromNumber(completedBid.quantity)..", "..stringFromNumber(completedBid.bid)..", "..stringFromBoolean(completedBid.isBuyout)..", "..stringFromBoolean(completedBid.isPurchaseRecorded));

		-- Update the remaining completed bid indicies.
		for index in completedBids do
			local bid = completedBids[index];
			if (bid.index > completedBidTablesIndex) then
				bid.index = bid.index - 1;
			end
		end
		
		-- Look for a matching pending bid.
		local index = 1;
		local pendingBid = nil;
		local pendingBidIndex = nil;
		for index in pendingBids do
			local thisPendingBid = pendingBids[index];
			if ((completedBid.quantity == nil or thisPendingBid.quantity == nil or completedBid.quantity == thisPendingBid.quantity) and
				(completedBid.bid == nil or thisPendingBid.bid == nil or completedBid.bid == thisPendingBid.bid) and
				(completedBid.seller == nil or thisPendingBid.seller == nil or completedBid.seller == thisPendingBid.seller) and
				(completedBid.isBuyout == nil or thisPendingBid.isBuyout == nil or completedBid.isBuyout == thisPendingBid.isBuyout) and
				(completedBid.isSuccessful or not thisPendingBid.isBuyout)) then
				pendingBid = thisPendingBid;
				pendingBidIndex = index;
				break;
			end
		end
		
		-- Check if we found matching pending bid.
		if (pendingBid) then
			-- Remove the pending bid.
			table.remove(pendingBids, pendingBidIndex);
			local pendingBidsTableIndex = pendingBid.index;
			table.remove(pendingBidsTable, pendingBidsTableIndex);
			debugPrint("[Purchases] Removed pending bid: "..date("%c", pendingBid.time)..", "..item..", "..stringFromNumber(pendingBid.quantity)..", "..stringFromNumber(pendingBid.bid)..", "..stringFromBoolean(pendingBid.isBuyout));

			-- Update the remaining pending bid indicies.
			for index in pendingBids do
				local bid = pendingBids[index];
				if (bid.index > pendingBidsTableIndex) then
					bid.index = bid.index - 1;
				end
			end
			
			-- Add a purchase (if it was a successful bid and not already recorded)
			if (completedBid.isSuccessful and not pendingBid.isBuyout and not completedBid.isPurchaseRecorded) then
				addPurchase(pendingBid.time, item, pendingBid.quantity, pendingBid.bid, pendingBid.seller, pendingBid.isBuyout);
			end
		end
	end
end

--=============================================================================
-- Utility functions
--=============================================================================

-------------------------------------------------------------------------------
-- Clears the purchases database
-------------------------------------------------------------------------------
function resetDatabase()
	AHPurchases.PendingBids = {};
	AHPurchases.CompletedBids = {};
	AHPurchases.Purchases = {};
	debugPrint("[Purchases] Reset Database");
end

-------------------------------------------------------------------------------
-- Gets the number of non-nil fields in a bid.
-------------------------------------------------------------------------------
function getBidNonNilFieldCount(bid)
	local count = 0;
	if (bid.quantity) then count = count + 1 end;
	if (bid.bid) then count = count + 1 end;
	if (bid.seller) then count = count + 1 end;
	if (bid.isBuyout) then count = count + 1 end;
	return count;
end

-------------------------------------------------------------------------------
-- Compares the bids by number of non-nil fields.
-------------------------------------------------------------------------------
function compareBidsByNonNilFieldCount(bid1, bid2)
	local count1 = getBidNonNilFieldCount(bid1);
	local count2 = getBidNonNilFieldCount(bid2);
	if (count1 > count2) then
		return true;
	end
	return false;
end

-------------------------------------------------------------------------------
-- Converts boolean into a numeric string.
-------------------------------------------------------------------------------
function stringFromBoolean(boolean)
	if (boolean == nil) then
		return NIL_VALUE;
	elseif (boolean) then
		return "1";
	end
	return "0";
end

-------------------------------------------------------------------------------
-- Converts a numeric string into a boolean.
-------------------------------------------------------------------------------
function booleanFromString(string)
	if (string == NIL_VALUE) then
		return nil;
	elseif (string == "0") then
		return false;
	end
	return true;
end

-------------------------------------------------------------------------------
-- Converts number into a numeric string.
-------------------------------------------------------------------------------
function stringFromNumber(number)
	if (number == nil) then
		return NIL_VALUE;
	end
	return tostring(number);
end

-------------------------------------------------------------------------------
-- Converts numeric string into a number.
-------------------------------------------------------------------------------
function numberFromString(number)
	if (number == NIL_VALUE) then
		return nil;
	end
	return tonumber(number);
end

-------------------------------------------------------------------------------
-- Converts a string into a nil safe string (nil -> "<nil>")
-------------------------------------------------------------------------------
function nilSafeStringFromString(string)
	if (string == nil) then
		return NIL_VALUE;
	end
	return string;
end

-------------------------------------------------------------------------------
-- Converts a nil safe string into a string ("<nil>" -> nil)
-------------------------------------------------------------------------------
function stringFromNilSafeString(nilSafeString)
	if (nilSafeString == NIL_VALUE) then
		return nil;
	end
	return nilSafeString;
end

--[[
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function testme()
	addPurchase(time(), "Silver Bar", 10, 1000, "Stupid", false);
	printPurchases();
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function testme1()
	resetDatabase();

	addPendingBid("Silver Bar", 1, 3500, "Sucker1", false);
	addPendingBid("Silver Bar", 1, 3000, "Sucker1", true);
	addPendingBid("Silver Bar", 1, 4000, "Sucker1", false);
	addPendingBid("Silver Bar", 2, 3500, "Sucker2", false);
	addPendingBid("Silver Bar", 2, 3000, "Sucker2", false);
	addPendingBid("Silver Bar", 2, 4000, "Sucker2", false);
	printPendingBids();
	printCompletedBids();
	printPurchases();

	addSuccessfulBid("Silver Bar", 1, 4000, "Sucker1", false);
	addSuccessfulBid("Silver Bar", 1);
	addSuccessfulBid("Silver Bar", 1);
	addFailedBid("Silver Bar", 4000);
	addFailedBid("Silver Bar", 3000);
	addFailedBid("Silver Bar", 3500);
	printPendingBids();
	printCompletedBids();
	printPurchases();
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function testme2()
	resetDatabase();

	addPendingBid("Silver Bar", 1, 3500, "Sucker", false);
	addPendingBid("Silver Bar", 1, 3500, "Sucker", false);
	addPendingBid("Silver Bar", 1, 3500, "Sucker", false);
	printPendingBids();
	printCompletedBids();
	printPurchases();

	addSuccessfulBid("Silver Bar", 1);
	printPendingBids();
	printCompletedBids();
	printPurchases();

	addFailedBid("Silver Bar", 3500);
	printPendingBids();
	printCompletedBids();
	printPurchases();

	addSuccessfulBid("Silver Bar", 1);
	printPendingBids();
	printCompletedBids();
	printPurchases();
end
--]]

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------
BeanCounter.Purchases = 
{
	AddPendingBid = addPendingBid;
	AddSuccessfulBid = addSuccessfulBid;
	AddFailedBid = addFailedBid;
	GetPurchasedItems = getPurchasedItems;
	GetPurchasesForItem = getPurchasesForItem;
	PrintPendingBids = printPendingBids;
	PrintCompletedBids = printCompletedBids;
	PrintPurchases = printPurchases;
	ResetDatabase = resetDatabase;
};