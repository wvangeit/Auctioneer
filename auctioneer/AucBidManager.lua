--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

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
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]

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

-- Function hooks that are used when processing requests
local Original_CanSendAuctionQuery;
local Original_AuctionFrameBrowse_OnEvent;
local Original_AuctionFrameBrowse_Update;

-- Result codes for bid requests.
BidResultCodes = {}
BidResultCodes["BidAccepted"] = 0;
BidResultCodes["ItemNotFound"] = 1;
BidResultCodes["NotEnoughMoney"] = 2;
BidResultCodes["OwnAuction"] = 3;
BidResultCodes["AlreadyHigherBid"] = 4;
BidResultCodes["AlreadyHighBidder"] = 5;
BidResultCodes["CurrentBidLower"] = 6;

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
local isProcessingRequest;
local beginProcessingRequestQueue;
local endProcessingRequestQueue;
local processRequestQueue;
local processPage;
local nilSafe;
local boolString;
local chatPrint;
local debugPrint;
local bidAuction;
local dumpState;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AucBidManagerFrame_OnLoad()
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
function AucBidManagerFrame_OnEvent(event)
	if (event == "VARIABLES_LOADED") then
		addPlayerToAccount(UnitName("player"));
	elseif (event == "AUCTION_ITEM_LIST_UPDATE") then
		debugPrint(event);
		checkQueryComplete();
		processRequestQueue();
	elseif (event == "CHAT_MSG_SYSTEM" and arg1) then
		debugPrint(event);
		if (arg1) then debugPrint("    "..arg1) end;
		 if (arg1 == ERR_AUCTION_BID_PLACED) then
		 	onBidResponse(BidResultCodes["BidAccepted"]);
			processRequestQueue();
		end
	elseif (event == "UI_ERROR_MESSAGE" and arg1) then
		debugPrint(event);
		if (arg1) then debugPrint("    "..arg1) end;
		if (arg1 == ERR_ITEM_NOT_FOUND) then
			onBidResponse(BidResultCodes["ItemNotFound"]);
		elseif (arg1 == ERR_NOT_ENOUGH_MONEY) then
			onBidResponse(BidResultCodes["NotEnoughMoney"]);
		elseif (arg1 == ERR_AUCTION_BID_OWN) then
			onBidResponse(BidResultCodes["OwnAuction"]);
		elseif (arg1 == ERR_AUCTION_HIGHER_BID) then
			onBidResponse(BidResultCodes["AlreadyHigherBid"]);
		end
		processRequestQueue();
	elseif (event == "AUCTION_HOUSE_CLOSED") then
		endProcessingRequestQueue();
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AucBidManagerFrame_OnUpdate()
	processRequestQueue();
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AucBidManager_CanSendAuctionQuery()
	-- Intentionally empty; don't allow the auction UI to update while we're processing requests
	return false;
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AucBidManager_AuctionFrameBrowse_OnEvent()
	-- Intentionally empty; don't allow the auction UI to update while we're processing requests
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AucBidManager_AuctionFrameBrowse_Update()
	-- Intentionally empty; don't allow the auction UI to update while we're processing requests
end

-------------------------------------------------------------------------------
-- Adds a player to the list of players on the current account.
-------------------------------------------------------------------------------
function addPlayerToAccount(player)
	-- List of players on the same account as the current player (including the
	-- current player). Auctions owned by these players cannot be bid on.
	if (not AuctionConfig.players) then AuctionConfig.players = {}; end
	table.insert(AuctionConfig.players, player);
end

-------------------------------------------------------------------------------
-- Checks if a player is on the same account as the current player.
-------------------------------------------------------------------------------
function isPlayerOnAccount(player)
	if (not AuctionConfig.players) then AuctionConfig.players = {}; end
	for _, p in pairs(AuctionConfig.players) do
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
function onBidResponse(result)
	if (table.getn(PendingBids) > 0) then
		-- We always assume the bid response is for the next bid in PendingBids.
		local bid = PendingBids[1];

		-- If there is an associated request, add our result to it.
		local request = bid.request;
		if (request) then
			if (result == BidResultCodes["BidAccepted"]) then
				table.insert(request.results, result);

				if (request.bid == request.buyout) then
					local output = string.format(_AUCT('FrmtBoughtAuction'), request.name, request.count);
					chatPrint(output);

				else
					local output = string.format(_AUCT('FrmtBidAuction'), request.name, request.count);
					chatPrint(output);
				end

			elseif (result == BidResultCodes["ItemNotFound"]) then
				-- nothing to do

			elseif (result == BidResultCodes["NotEnoughMoney"]) then
				table.insert(request.results, result);
				local output = string.format(_AUCT('FrmtNotEnoughMoney'), request.name, request.count);
				chatPrint(output);

			elseif (result == BidResultCodes["OwnAuction"]) then
				table.insert(request.results, result);
				local output = string.format(_AUCT('FrmtSkippedBiddingOnOwnAuction'), request.name, request.count);
				chatPrint(output);

			elseif (result == BidResultCodes["AlreadyHigherBid"]) then
				table.insert(request.results, result);
				local output = string.format(_AUCT('FrmtSkippedAuctionWithHigherBid'), request.name, request.count);
				chatPrint(output);
			end
		end

		-- Process the bid result		.
		if (result == BidResultCodes["BidAccepted"] and request) then
			-- Check if there is a corresponding request and upate it to
			-- reflect the successful bid.
			if (request) then
				request.bidCount = request.bidCount + 1;

				-- Remove the request if we've reached the max bids.
				if (request.bidCount == request.maxBids) then
					removeRequestFromQueue();

				-- Safety check for debugging. Prevents stack overflows so we can
				-- see what the hell went wrong.
				elseif (request.bidAttempts > 10) then
					debugPrint("Reached max bid attempts!");
					removeRequestFromQueue();

				-- Increment the request's current index if the auction was not bought out.
				elseif (request.bid ~= request.buyout) then
					request.currentIndex = request.currentIndex + 1;

				end
			end

		elseif (result ~= BidResultCodes["BidAccepted"]) then
			-- We were expecting the list to update after our bid/buyout, but
			-- our bid/buyout failed so we won't be getting an update.
			CurrentSearchParams.complete = true;

			-- Skip over the auction we failed to bid on.
			request.currentIndex = request.currentIndex + 1;

			if (result == BidResultCodes["OwnAuction"] and bid.owner) then
				-- We tried bidding on our own auction! Blizzard doesn't
				-- allow bids from any player on the account that posted
				-- the auction. Therefore we keep a dynamic list of all
				-- of these failures so we can avoid these auctions in the
				-- future.
				addPlayerToAccount(bid.owner);
			end
		end

		-- Remove the pending bid.
		table.remove(PendingBids, 1);
	else
		-- We got out of sync somehow... this indicates a bug in how we determine
		-- the results of bid requests.
		chatPrint(_AUCT('FrmtBidQueueOutOfSync'));
	end
end

-------------------------------------------------------------------------------
-- Returns true if a query is in progress
-------------------------------------------------------------------------------
function isQueryInProgress()
	return (not CurrentSearchParams.complete);
end

-------------------------------------------------------------------------------
-- Wrapper around CanSendAuctionQuery() that always calls the Blizzard version.
-------------------------------------------------------------------------------
function canSendAuctionQuery()
	if (Original_CanSendAuctionQuery) then
		return Original_CanSendAuctionQuery();
	end
	return CanSendAuctionQuery();
end

-------------------------------------------------------------------------------
-- Called before QueryAuctionItems()
-------------------------------------------------------------------------------
function queryAuctionItemsHook(_, _, name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
	if (not Auctioneer.Scanning.IsScanningRequested and canSendAuctionQuery()) then
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
		debugPrint("LastIndexOnPage = "..lastIndexOnPage);
		debugPrint("TotalAuctions = "..totalAuctions);

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
function addRequestToQueue(request)
	-- Add the request state information and then add the request to the queue.
	request.bidAttempts = 0;
	request.bidCount = 0;
	request.maxBids = 1000;
	request.currentPage = 0;
	request.currentIndex = 1;
	request.results = {};
	table.insert(RequestQueue, request);
	debugPrint("Added request to queue: "..request.name..", "..request.count..", "..nilSafe(request.buyout)..", "..nilSafe(request.bid));
end

-------------------------------------------------------------------------------
-- Removes a request at the head of the queue.
-------------------------------------------------------------------------------
function removeRequestFromQueue()
	if (table.getn(RequestQueue) > 0) then
		local request = RequestQueue[1];
		local callback = request.callback;

		if (callback and callback.func) then
			callback.func(callback.param, request);
		end

		if (table.getn(request.results) == 0) then
			local output = string.format(_AUCT('FrmtNoAuctionsFound'), request.name, request.count);
			chatPrint(output);
		end
		table.remove(RequestQueue, 1);
	end
end

-------------------------------------------------------------------------------
-- Checks if the BidManager is currently working on a request.
-------------------------------------------------------------------------------
function isProcessingRequest()
	return ProcessingRequestQueue;
end

-------------------------------------------------------------------------------
-- Starts processing the request queue if possible. Returns true if started.
-------------------------------------------------------------------------------
function beginProcessingRequestQueue()
	if (not ProcessingRequestQueue and
		AuctionFrame and AuctionFrame:IsVisible() and
		table.getn(RequestQueue) > 0 and
		not Auctioneer.Scanning.IsScanningRequested and
		not isQueryInProgress() and
		not isBidInProgress()) then

		ProcessingRequestQueue = true;
		debugPrint("Begin processing the bid queue");

		-- Hook the functions to disable the Browse UI
		if (not Original_CanSendAuctionQuery) then
			Original_CanSendAuctionQuery = CanSendAuctionQuery;
			CanSendAuctionQuery = AucBidManager_CanSendAuctionQuery;
		end
		if (not Original_AuctionFrameBrowse_OnEvent) then
			Original_AuctionFrameBrowse_OnEvent = AuctionFrameBrowse_OnEvent;
			AuctionFrameBrowse_OnEvent = AucBidManager_AuctionFrameBrowse_OnEvent;
		end
		if (not Original_AuctionFrameBrowse_Update) then
			Original_AuctionFrameBrowse_Update = AuctionFrameBrowse_Update;
			AuctionFrameBrowse_Update = AucBidManager_AuctionFrameBrowse_Update;
		end

		-- Hide the UI from any current results, show the no results text so we can use it
		BrowseNoResultsText:Show();
		BrowseNoResultsText:SetText(_AUCT('UiProcessingBidRequests'));
		for iButton = 1, NUM_BROWSE_TO_DISPLAY do
			button = getglobal("BrowseButton"..iButton);
			button:Hide();
		end
		BrowsePrevPageButton:Hide();
		BrowseNextPageButton:Hide();
		BrowseSearchCountText:Hide();
		BrowseBidButton:Disable();
		BrowseBuyoutButton:Disable();
	end
	return ProcessingRequestQueue;
end

-------------------------------------------------------------------------------
-- Ends processing the request queue
-------------------------------------------------------------------------------
function endProcessingRequestQueue()
	if (ProcessingRequestQueue) then
		-- Unhook the functions
		if( Original_CanSendAuctionQuery ) then
			CanSendAuctionQuery = Original_CanSendAuctionQuery;
			Original_CanSendAuctionQuery = nil;
		end
		if( Original_AuctionFrameBrowse_OnEvent ) then
			AuctionFrameBrowse_OnEvent = Original_AuctionFrameBrowse_OnEvent;
			Original_AuctionFrameBrowse_OnEvent = nil;
		end
		if( Original_AuctionFrameBrowse_Update ) then
			AuctionFrameBrowse_Update = Original_AuctionFrameBrowse_Update;
			Original_AuctionFrameBrowse_Update = nil;
		end

		-- Update the Browse UI.
		AuctionFrameBrowse_Update();

		debugPrint("End processing the bid queue");
		ProcessingRequestQueue = false;
		AucBidManagerFrame:Hide();
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

			elseif (canSendAuctionQuery()) then
				-- Turn off the OnUpdate calls and run our query
				AucBidManagerFrame:Hide();
				QueryAuctionItems(request.name, "", "", nil, nil, nil, request.currentPage, nil, nil);

			else
				-- Turn on the OnUpdate calls and wait to be able to send a query.
				AucBidManagerFrame:Show();
				break;
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
	debugPrint("Searching for item: "..request.id..", "..request.rprop..", "..request.enchant..", "..request.name..", "..request.count..", "..request.min..", "..request.buyout..", "..request.unique..", "..request.bid);

	for indexOnPage = request.currentIndex, lastIndexOnPage do
		-- Check if this item matches
		local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner = GetAuctionItemInfo("list", indexOnPage);
		local link = GetAuctionItemLink("list", indexOnPage);
		local id, rprop, enchant, unique = EnhTooltip.BreakLink(link);
		debugPrint("Processing item "..indexOnPage..": "..id..", "..rprop..", "..enchant..", "..name..", "..count..", "..minBid..", "..buyoutPrice..", "..unique..", "..bidAmount);

		if ((request.id == id) and
			(request.rprop == rprop) and
			(request.enchant == enchant) and
			(request.name == name) and
			(request.count == count) and
			(request.min == minBid) and
			(request.buyout == buyoutPrice) and
			(request.unique == unique)) then

			local bid = nil;

			-- Check if the auction is owned by the player.
			if (isPlayerOnAccount(owner)) then
				table.insert(request.results, BidResultCodes["OwnAuction"]);
				local output = string.format(_AUCT('FrmtSkippedBiddingOnOwnAuction'), request.name, request.count);
				chatPrint(output);

			-- Check for a buyout request
			elseif (request.buyout == request.bid) then
				bid = request.buyout;

			-- Otherwise it must be a bid request
			else
				-- Check if we are already the high bidder
				if (highBidder) then
					table.insert(request.results, BidResultCodes["AlreadyHighBidder"]);
					local output = string.format(_AUCT('FrmtAlreadyHighBidder'), request.name, request.count);
					chatPrint(output);

				-- Check if the item has been bid on
				elseif (bidAmount ~= 0) then
					-- Check the bid matches what we are looking for
					if (bidAmount == request.bid) then
						bid = bidAmount + minIncrement;

					-- Check if there is already a higher bidder
					elseif (bidAmount > request.bid) then
						table.insert(request.results, BidResultCodes["AlreadyHigherBid"]);
						local output = string.format(_AUCT('FrmtSkippedAuctionWithHigherBid'), request.name, request.count);
						chatPrint(output);

					-- Otherwise the bid must be lower...
					else
						table.insert(request.results, BidResultCodes["CurrentBidLower"]);
						local output = string.format(_AUCT('FrmtSkippedAuctionWithLowerBid'), request.name, request.count);
						chatPrint(output);
					end

				-- Otherwise the item hasn't been bid on
				else
					-- Check the bid matches what we are looking for
					if (minBid == request.bid) then
						bid = minBid;

					-- Otherwise the min bid is lower...
					else
						table.insert(request.results, BidResultCodes["CurrentBidLower"]);
						local output = string.format(_AUCT('FrmtSkippedAuctionWithLowerBid'), request.name, request.count);
						chatPrint(output);
					end
				end
			end

			-- If we've settled on a bid, do it now!
			if (bid) then
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

				-- Update the starting point for this page
				request.currentIndex = indexOnPage;
				request.bidAttempts = request.bidAttempts + 1;
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
			request.currentIndex = 1;
		end
	end
end

-------------------------------------------------------------------------------
-- Adds a bid request to the queue. For bids, the bid parameter should be the
-- current bid (or minimum bid in the case the item isn't bid on). For buyouts,
-- the bid parameter should be the buyout price.
-------------------------------------------------------------------------------
function bidAuction(bid, signature, callbackFunc, callbackParam)
	debugPrint("BidAuction("..bid..", "..signature..")");
	local id,rprop,enchant,name,count,min,buyout,unique = Auctioneer.Core.GetItemSignature(signature);

	if (bid and id and rprop and enchant and name and count and min and buyout and unique) then
		local request = {};
		request.id = id;
		request.rprop = rprop;
		request.enchant = enchant;
		request.name = name;
		request.count = count;
		request.min = min;
		request.buyout = buyout;
		request.unique = unique;
		request.bid = bid;
		request.callback = { func = callbackFunc, param = callbackParam };
		addRequestToQueue(request);
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
chatPrint = Auctioneer.Util.ChatPrint;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
debugPrint = EnhTooltip.DebugPrint;

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------
AucBidManager =
{
	-- Exported functions
	BidAuction = bidAuction;
	IsProcessingRequest = isProcessingRequest;
	DumpState = dumpState;
};
