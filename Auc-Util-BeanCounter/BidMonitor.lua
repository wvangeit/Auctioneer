local libName = "BeanCounter"
local libType = "Util"
local lib = AucAdvanced.Modules[libType][libName]
local private = lib.Private

local print = AucAdvanced.Print

-------------------------------------------------------------------------------
-- Called after PlaceAuctionBid()
-------------------------------------------------------------------------------
function private.postPlaceAuctionBidHook(_, _, listType, index, bid)
	local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner = GetAuctionItemInfo(listType, index);
	local itemLink = GetAuctionItemLink(listType, index)
	local timeLeft = GetAuctionItemTimeLeft(listType, index);
	if (name and count and bid) then
		private.addPendingBid(name, count, bid, owner, (bid == buyoutPrice), highBidder, timeLeft, itemLink);
	end
end

-------------------------------------------------------------------------------
-- Adds a pending bid to the queue.
-------------------------------------------------------------------------------
function private.addPendingBid(name, count, bid, owner, isBuyout, isHighBidder, timeLeft, itemLink)
	-- Add a pending bid to the queue.
	local pendingBid = {};
	pendingBid.name = name;
	pendingBid.count = count;
	pendingBid.bid = bid;
	pendingBid.owner = owner;
	pendingBid.isBuyout = isBuyout;
	pendingBid.isHighBidder = isHighBidder;
	pendingBid.timeLeft = timeLeft;
	pendingBid.itemLink = itemLink;
	table.insert(private.PendingBids, pendingBid);
	private.debugPrint("addPendingBid() - Added pending bid");
	
	-- Register for the response events if this is the first pending bid.
	if (#private.PendingBids == 1) then
		private.debugPrint("addPendingBid() - Registering for CHAT_MSG_SYSTEM and UI_ERROR_MESSAGE");
		Stubby.RegisterEventHook("CHAT_MSG_SYSTEM", "BeanCounter_BidMonitor", private.onEventHookBid);
		Stubby.RegisterEventHook("UI_ERROR_MESSAGE", "BeanCounter_BidMonitor", private.onEventHookBid);
	end
end

-------------------------------------------------------------------------------
-- Removes the pending bid from the queue.
-------------------------------------------------------------------------------
function private.removePendingBid()
	if (#private.PendingBids > 0) then
		-- Remove the first pending bid.
		local bid = private.PendingBids[1];
		table.remove(private.PendingBids, 1);
		private.debugPrint("removePendingBid() - Removed pending bid");

		-- Unregister for the response events if this is the last pending bid.
		if (#private.PendingBids == 0) then
			private.debugPrint("removePendingBid() - Unregistering for CHAT_MSG_SYSTEM and UI_ERROR_MESSAGE");
			Stubby.UnregisterEventHook("CHAT_MSG_SYSTEM", "BeanCounter_BidMonitor", private.onEventHookBid);
			Stubby.UnregisterEventHook("UI_ERROR_MESSAGE", "BeanCounter_BidMonitor", private.onEventHookBid);
		end

		return bid;
	end
	
	-- No pending bid to remove!
	return nil;
end

-------------------------------------------------------------------------------
-- OnEvent handler BIDS. these are unhooked when not needed
-------------------------------------------------------------------------------
function private.onEventHookBid(_, event, arg1)
	if (event == "CHAT_MSG_SYSTEM" and arg1) then
		if (arg1 == ERR_AUCTION_BID_PLACED) then
		 	private.onBidAccepted();
		end
	elseif (event == "UI_ERROR_MESSAGE" and arg1) then
		if (arg1) then private.debugPrint("    "..arg1) end;
		if (arg1 == ERR_ITEM_NOT_FOUND or
			arg1 == ERR_NOT_ENOUGH_MONEY or
			arg1 == ERR_AUCTION_BID_OWN or
			arg1 == ERR_AUCTION_HIGHER_BID or 
			arg1 == ERR_ITEM_MAX_COUNT) then
			private.onBidFailed();
		end
	end
end

-------------------------------------------------------------------------------
-- Called when a bid is accepted by the server.
-------------------------------------------------------------------------------
function private.onBidAccepted()
	local bid = private.removePendingBid();
	if (bid) then
	
	local itemID = bid.itemLink:match("|c%x+|Hitem:(%d-):.-|h%[.-%]|h|r")
	local text = private.packString(bid.name, bid.count, bid.bid, bid.owner, bid.isBuyout, bid.timeLeft, time(),private.wealth)
		private.debugPrint(bid.isBuyout, bid.isHighBidder)		
		if (bid.isBuyout) then
			if bid.isHighBidder then-- If the player is buying out an auction they already bid on, we need to remove the pending bid
				private.debugPrint('private.databaseRemove(',"postedBids", itemID, bid.name, bid.owner, bid.bid)
				private.databaseRemove("postedBids", itemID, bid.name, bid.owner, bid.bid)
			end	
			private.databaseAdd("postedBuyouts", itemID, text) 
		else
		
		private.debugPrint('private.databaseAdd(pendingBids',itemID, text)
		private.databaseAdd("postedBids", itemID, text)
		end
	end
end

-------------------------------------------------------------------------------
-- Called when a bid is rejected by the server.
-------------------------------------------------------------------------------
function private.onBidFailed()
	private.removePendingBid();
end


