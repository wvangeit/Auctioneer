--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id $

	BidManager - manages bid requests in the AH

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

-------------------------------------------------------------------------------
-- Data Members
-------------------------------------------------------------------------------

-- Queue of bid requests to be worked on
local RequestQueue = {};
local ProcessingRequestQueue = false;

-- Bid queue actions
local BID_AUCTION = "bid";
local BUYOUT_AUCTION = "buyout";

-- Parameters of QueryAuctionItems() last time it was called.
local CurrentSearchParams = 
{
	name = nil;
	minLevel = nil;
	maxLevel = nil;
	invTypeIndex = nil;
	classIndex = nil;
	subclassIndex = nil;
	page = nil;
	isUsable = nil;
	qualityIndex = nil;
	complete = true; -- Flag indicates if the entire response has been received
};

-- Queue of bids submitted to the server, but not yet accepted or rejected
local PendingBids = {};

-- List of players on the same account as the current player (including the
-- current player). Auctions owned by these players cannot be bid on.
local PlayersOnAccount = {};

-- Responses to bids received either via CHAT_MSG_SYSTEM or UI_ERROR_MESSAGE
-- events
local AUCTION_CREATED = "Auction created."; -- %localize%
local BID_ACCEPTED = "Bid accepted."; -- %localize%
local ITEM_NOT_FOUND = "The item was not found."; -- %localize%
local NOT_ENOUGH_MONEY = "You don't have enough money." -- %localize%
local CANNOT_BID_ON_OWN_AUCTION = "You cannot bid on your own auction." -- %localize%
local ALREADY_HIGHER_BID = "There is already a higher bid on that item." -- %localize%

-------------------------------------------------------------------------------
-- Function Prototypes
-------------------------------------------------------------------------------
local addPlayerToAccount;
local isPlayerOnAccount;
local isBidInProgress;
local placeAuctionBidHook;
local onBidResponse;
local isQueryInProgress;
local queryAuctionItemsHook;
local checkQueryComplete;
local addRequestToQueue;
local removeRequestFromQueue;
local beginProcessingRequestQueue;
local endProcessingRequestQueue;
local processRequestQueue;
local processPage;
local nilSafe;
local boolString;
local chatPrint;
local debugPrint;
local bidAuction;
local buyoutAuction;
local dumpState;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function BidManagerFrame_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("AUCTION_ITEM_LIST_UPDATE");
	this:RegisterEvent("CHAT_MSG_SYSTEM");
	this:RegisterEvent("UI_ERROR_MESSAGE");
	this:RegisterEvent("AUCTION_HOUSE_CLOSED");

	Stubby.RegisterFunctionHook("PlaceAuctionBid", -50, placeAuctionBidHook)
	Stubby.RegisterFunctionHook("QueryAuctionItems", -50, queryAuctionItemsHook)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function BidManagerFrame_OnEvent(...)
	if (arg[1] == "VARIABLES_LOADED") then
		addPlayerToAccount(UnitName("player"));
	elseif (arg[1] == "AUCTION_ITEM_LIST_UPDATE") then
		debugPrint("AUCTION_ITEM_LIST_UPDATE");
		checkQueryComplete();
		processRequestQueue();
	elseif (arg[1] == "CHAT_MSG_SYSTEM" and arg[2]) then
		 if (arg[2] == BID_ACCEPTED) then -- TODO: %localize%
		 	onBidResponse(true);
			processRequestQueue();
		end
	elseif (arg[1] == "UI_ERROR_MESSAGE" and arg[2]) then
		debugPrint("UI_ERROR_MESSAGE - "..arg[2]);
		if (arg[2] == ITEM_NOT_FOUND or
			arg[2] == NOT_ENOUGH_MONEY or
			arg[2] == CANNOT_BID_ON_OWN_AUCTION or
			arg[2] == ALREADY_HIGHER_BID) then -- TODO: %localize%
			onBidResponse(false, arg[2]);
			processRequestQueue();
		end
    elseif (arg[1] == "AUCTION_HOUSE_CLOSED") then
    	endProcessingRequestQueue();
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function BidManagerFrame_OnUpdate()
	processRequestQueue();
end

-------------------------------------------------------------------------------
-- Adds a player to the list of players on the current account.
-------------------------------------------------------------------------------
function addPlayerToAccount(player)
	table.insert(PlayersOnAccount, player);
end

-------------------------------------------------------------------------------
-- Checks if a player is on the same account as the current player.
-------------------------------------------------------------------------------
function isPlayerOnAccount(player)
	for _, p in pairs(PlayersOnAccount) do
		if (p == player) then
			return true;
		end
	end
	return false;
end


-------------------------------------------------------------------------------
-- Returns true if a bid request is in flight to the server
-------------------------------------------------------------------------------
function isBidInProgress()
	return (table.getn(PendingBids) > 0);
end

-------------------------------------------------------------------------------
-- Called before PlaceAuctionBid()
-------------------------------------------------------------------------------
function placeAuctionBidHook(_, _, listType, index, bid)
	debugPrint("placeAuctionBidHook()");
	local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner = GetAuctionItemInfo(listType, index);
	if (name and count and bid) then
		local pendingBid = {};
		pendingBid.name = name;
		pendingBid.count = count;
		pendingBid.bid = bid;
		pendingBid.owner = owner;
		pendingBid.request = nil;
		table.insert(PendingBids, pendingBid);
	end
end

-------------------------------------------------------------------------------
-- Called whenever a response to a bid is received
-------------------------------------------------------------------------------
function onBidResponse(accepted, reason)
	if (table.getn(PendingBids) > 0) then
		-- We always assume the bid response is for the next bid in PendingBids.
		local bid = PendingBids[1];
		local request = bid.request;
		if (accepted and request) then
			-- Check if there is a corresponding request and upate it to
			-- reflect the successful bid.
			if (request) then
				request.bidCount = request.bidCount + 1;
				if (request.bidCount == request.maxBids) then
					removeRequestFromQueue();
				end
			end
		elseif (not accepted) then
			-- We were expecting the list to update after our bid/buyout, but
			-- our bid/buyout failed so we won't be getting an update.
			CurrentSearchParams.complete = true;
			
			if (reason == NOT_ENOUGH_MONEY and request) then
				-- We ran out of money so we need to remove the request, lest
				-- we get stuck in a loop forever.
				removeRequestFromQueue();
			elseif (reason == CANNOT_BID_ON_OWN_AUCTION and bid.owner) then
				-- We tried bidding on our own auction! Blizzard doesn't
				-- allow bids from any player on the account that posted
				-- the bid. Therefore we keep a dynamic list of all
				-- of these failures so we can avoid these auctions in the
				-- future.
				addPlayerToAccount(bid.owner);
			end
		end
		
		-- Remove the pending bid.
		table.remove(PendingBids, 1);
	else
		-- TODO: We got out of sync somehow...
		chatPrint("Error: Bid queue out of sync!");
	end
end

-------------------------------------------------------------------------------
-- Returns true if a query is in progress
-------------------------------------------------------------------------------
function isQueryInProgress()
	return (not CurrentSearchParams.complete);
end

-------------------------------------------------------------------------------
-- Called before QueryAuctionItems()
-------------------------------------------------------------------------------
function queryAuctionItemsHook(_, _, name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
	if (not Auctioneer_isScanningRequested and CanSendAuctionQuery()) then
		CurrentSearchParams.name = name;
		CurrentSearchParams.minLevel = minLevel;
		CurrentSearchParams.maxLevel = maxLevel;
		CurrentSearchParams.invTypeIndex = invTypeIndex;
		CurrentSearchParams.classIndex = classIndex;
		CurrentSearchParams.subclassIndex = subclassIndex;
		CurrentSearchParams.page = page;
		CurrentSearchParams.isUsable = isUsable;
		CurrentSearchParams.qualityIndex = qualityIndex;
		CurrentSearchParams.complete = false;
		debugPrint("queryAuctionItemsHook()");
	else
		CurrentSearchParams.name = nil;
		CurrentSearchParams.minLevel = nil;
		CurrentSearchParams.maxLevel = nil;
		CurrentSearchParams.invTypeIndex = nil;
		CurrentSearchParams.classIndex = nil;
		CurrentSearchParams.subclassIndex = nil;
		CurrentSearchParams.page = nil;
		CurrentSearchParams.isUsable = nil;
		CurrentSearchParams.qualityIndex = nil;
		CurrentSearchParams.complete = true;
		debugPrint("queryAuctionItemsHook() (ignoring)");
	end
end

-------------------------------------------------------------------------------
-- Checks a query to see if its complete. Often times the owner information
-- of auctions are missing at first. Asking for it triggers another update
-- of the auction list.
-------------------------------------------------------------------------------
function checkQueryComplete()
	if (not CurrentSearchParams.complete) then
		-- Assume true until otherwise proven false.
		CurrentSearchParams.complete = true;
		local lastIndexOnPage, totalAuctions = GetNumAuctionItems("list");
		for indexOnPage = 1, lastIndexOnPage do
			local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner = GetAuctionItemInfo("list", indexOnPage);
			if (owner == nil) then
				-- No dice... there are more updates coming...
				CurrentSearchParams.complete = false;
				break;
			end
		end
		if (CurrentSearchParams.complete) then
			debugPrint("checkQueryComplete() - true");
		else
			debugPrint("checkQueryComplete() - false");
		end
	end
end

-------------------------------------------------------------------------------
-- Adds a request to the queue.
-------------------------------------------------------------------------------
function addRequestToQueue(action, name, count, owner, bid, buyout)
	debugPrint("Adding request to queue: "..action..", "..name..", "..count..", "..nilSafe(owner)..", "..nilSafe(bid)..", "..nilSafe(buyout));
	local request = {};
	request.action = action;
	request.name = name;
	request.count = count;
	request.owner = owner;
	request.bid = bid;
	request.buyout = buyout;
	request.bidCount = 0;
	request.maxBids = 1;
	request.currentPage = 0;
	table.insert(RequestQueue, request);
end

-------------------------------------------------------------------------------
-- Removes a request at the head of the queue.
-------------------------------------------------------------------------------
function removeRequestFromQueue()
	if (table.getn(RequestQueue) > 0) then
		local request = RequestQueue[1];
		if (request.bidCount == 0) then
			-- %localize%
			chatPrint("No auctions found: "..request.name.." (x"..request.count..")");
		elseif (request.bidCount == 1) then
			-- %localize%
			chatPrint("Bid on "..request.bidCount.." auction: "..request.name.." (x"..request.count..")");
		else
			-- %localize%
			chatPrint("Bid on "..request.bidCount.." auctions: "..request.name.." (x"..request.count..")");
		end
		table.remove(RequestQueue, 1);
	end
end

-------------------------------------------------------------------------------
-- Starts processing the request queue if possible. Returns true if started.
-------------------------------------------------------------------------------
function beginProcessingRequestQueue()
	if (not ProcessingRequestQueue and
		AuctionFrame:IsVisible() and
		table.getn(RequestQueue) > 0 and
		not Auctioneer_isScanningRequested and
		not isQueryInProgress() and
		not isBidInProgress()) then
		ProcessingRequestQueue = true;
		debugPrint("Begin processing the bid queue");
		
		-- TODO: Disable the Browse UI
	end
	return ProcessingRequestQueue;
end

-------------------------------------------------------------------------------
-- Ends processing the request queue
-------------------------------------------------------------------------------
function endProcessingRequestQueue()
	if (ProcessingRequestQueue) then
		-- TODO: Enable the Browse UI

		debugPrint("End processing the bid queue");
		ProcessingRequestQueue = false;
	end
end

-------------------------------------------------------------------------------
-- Attempt to process the request queue. Based on the current state, this
-- method performs the next action needed to process the queue.
-------------------------------------------------------------------------------
function processRequestQueue()
	if (beginProcessingRequestQueue()) then
		while (table.getn(RequestQueue) > 0 and not isQueryInProgress() and not isBidInProgress()) do
			local request = RequestQueue[1];
			--debugPrint("Processing bid queue: "..request.name..", "..request.count..", "..nilSafe(request.owner)..", "..nilSafe(request.bid)..", "..nilSafe(request.buyout));
			--debugPrint("CurrentSearchParams: ");
			--debugPrint("    name: "..nilSafe(CurrentSearchParams.name));
			--debugPrint("    minLevel: "..nilSafe(CurrentSearchParams.minLevel));
			--debugPrint("    maxLevel: "..nilSafe(CurrentSearchParams.maxLevel));
			if (CurrentSearchParams.name and
				CurrentSearchParams.name == request.name and
				CurrentSearchParams.minLevel == "" and
				CurrentSearchParams.maxLevel == "" and
				CurrentSearchParams.invTypeIndex == nil and
				CurrentSearchParams.classIndex == nil and
				CurrentSearchParams.page == request.currentPage and
				CurrentSearchParams.isUsable == nil and
				CurrentSearchParams.qualityIndex == nil) then
				processPage();
			elseif (CanSendAuctionQuery()) then
				QueryAuctionItems(request.name, "", "", nil, nil, nil, request.currentPage, nil, nil);
			end
		end
		
		-- If we've emptied the RequestQueue, then end the processing
		if (table.getn(RequestQueue) == 0) then
			endProcessingRequestQueue();
		end
	end
end

-------------------------------------------------------------------------------
-- Searches the current page for an auction matching the first request in
-- the request queue. If it finds the auction, it carries out the specified
-- action (bid/buyout).
-------------------------------------------------------------------------------
function processPage()
	local request = RequestQueue[1];
	
	-- Iterate through each item on the page, searching for a match
	local lastIndexOnPage, totalAuctions = GetNumAuctionItems("list");
	debugPrint("Processing page "..request.currentPage.." ("..lastIndexOnPage.." on page; "..totalAuctions.." in total)");
	--debugPrint("Searching for item: "..request.name..", "..request.count..", "..nilSafe(request.owner)..", "..nilSafe(request.bid)..", "..nilSafe(request.buyout));
	for indexOnPage = 1, lastIndexOnPage do
		-- Check if this item matches
		local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner = GetAuctionItemInfo("list", indexOnPage);
		--debugPrint("Comparing item "..indexOnPage);
		--debugPrint("Processing item: "..name..", "..count..", "..owner..", "..bidAmount..", "..buyoutPrice);
		if ((request.name == name) and
			(request.count == count) and
			(request.owner == nil or request.owner == owner) and
			(request.bid == nil or (bidAmount ~= 0 and request.bid == bidAmount) or (bidAmount == 0 and request.bid == minBid)) and
			(request.buyout == nil or request.buyout == buyoutPrice) and
			(not isPlayerOnAccount(owner))) then

			-- We've got a match so figure out what to do.
			local bid = nil;
			if (request.action == BID_AUCTION) then
				if (not highBidder) then
					-- Calculate the minimum amount to make us the high bidder.
					if (bidAmount == 0) then
						bid = minBid;
					else
						bid = bidAmount + minIncrement;
					end
				else
					-- We are already the high bidder.
					-- %localize%
					chatPrint("Already high bidder: "..name.." (x"..count..")");
				end
			elseif (request.action == BUYOUT_AUCTION) then
				bid = buyoutPrice;
			end

			-- Place the bid/buyout!
			if (bid) then
				-- %localize%
				debugPrint("Placing bid on "..name.. " at "..bid.." (index "..indexOnPage..")");
				PlaceAuctionBid("list", indexOnPage, bid);
				
				-- PlaceAuctionBid is hooked to append an item to the
				-- PendingBids table. Associate our request with the
				-- pending bid.
				PendingBids[table.getn(PendingBids)].request = request;
				
				-- Successful bid/buyouts result in the query results being
				-- updated. To prevent additional queries from being sent
				-- until the list is updated, we flip the complete flag
				-- back to false. If the bid fails we'll manually flip
				-- the flag back to true again.
				CurrentSearchParams.complete = false;
				break;
			end
		end
	end

	-- If not item as found to bid on...
	if (not isBidInProgress()) then
		-- When an item is bought out on the page, the item is not replaced
		-- with an item from a subsequent page. Nor is the item removed from
		-- the total count. Thus if there were 7 items total before the buyout,
		-- GetNumAuctionItems() will report 6 items on the page and but still
		-- 7 total after the buyout.
		if (lastIndexOnPage == 0 or 
			request.currentPage * NUM_AUCTION_ITEMS_PER_PAGE + lastIndexOnPage == totalAuctions) then
			-- Reached the end of the line for this item, remove it from the queue
			removeRequestFromQueue();
		else
			-- Continue looking for items on the next page.
			request.currentPage = request.currentPage + 1;
		end
	end
end

-------------------------------------------------------------------------------
-- Adds a bid request to the queue.
--
-- The owner and buyout parameters can be nil.
-------------------------------------------------------------------------------
function bidAuction(name, count, owner, bid, buyout)
	if (name and count and bid) then
		addRequestToQueue(BID_AUCTION, name, count, owner, bid, buyout);
		processRequestQueue();
	end
end

-------------------------------------------------------------------------------
-- Adds a buyout request to the queue.
--
-- The owner and bid parameters can be nil.
-------------------------------------------------------------------------------
function buyoutAuction(name, count, owner, bid, buyout)
	if (name and count and buyout) then
		addRequestToQueue(BUYOUT_AUCTION, name, count, owner, bid, buyout);
		processRequestQueue();
	end
end

-------------------------------------------------------------------------------
-- Dumps the state of the BidManager to the chat window.
-------------------------------------------------------------------------------
function dumpState()
	chatPrint("BidManager State:");
	chatPrint("    IsBidInProgress: "..boolString(isBidInProgress()));
	chatPrint("    IsQueryInProgress: "..boolString(isQueryInProgress()));
	chatPrint("    RequestQueue ("..table.getn(RequestQueue).."):");
	chatPrint("    PendingBids ("..table.getn(PendingBids).."):");
	chatPrint("    CurrentSearchParams:");
	chatPrint("        name: "..nilSafe(CurrentSearchParams.name));
	chatPrint("        minLevel: "..nilSafe(CurrentSearchParams.minLevel));
	chatPrint("        maxLevel: "..nilSafe(CurrentSearchParams.maxLevel));
	chatPrint("        invTypeIndex: "..nilSafe(CurrentSearchParams.invTypeIndex));
	chatPrint("        classIndex: "..nilSafe(CurrentSearchParams.classIndex));
	chatPrint("        subclassIndex: "..nilSafe(CurrentSearchParams.subclassIndex));
	chatPrint("        page: "..nilSafe(CurrentSearchParams.page));
	chatPrint("        isUsable: "..boolString(CurrentSearchParams.isUsable));
	chatPrint("        qualityIndex: "..nilSafe(CurrentSearchParams.qualityIndex));
	chatPrint("        complete: "..boolString(CurrentSearchParams.complete));
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function nilSafe(string)
	if (string) then
		return string;
	end
	return "<nil>";
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function boolString(value)
	if (value) then
		return "true";
	end
	return "false";
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function chatPrint(message)
	Auctioneer_ChatPrint(message);
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function debugPrint(message)
	--DEFAULT_CHAT_FRAME:AddMessage(message);
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------
BidManager = 
{
	BidAuction = bidAuction;
	BuyoutAuction = buyoutAuction;
	DumpState = dumpState;
};
