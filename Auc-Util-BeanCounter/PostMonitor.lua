local libName = "BeanCounter"
local libType = "Util"
local lib = AucAdvanced.Modules[libType][libName]
local private = lib.Private

local print = AucAdvanced.Print
local debugPrint = private.debugPrint
-------------------------------------------------------------------------------
-- Called before StartAuction()
-------------------------------------------------------------------------------
function private.preStartAuctionHook(_, _, minBid, buyoutPrice, runTime)
	local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo();
	if (name and count and price) then
		local deposit = CalculateAuctionDeposit(runTime);
		private.addPendingPost(name, count, minBid, buyoutPrice, runTime, deposit);
	end
end

-------------------------------------------------------------------------------
-- Adds a pending post to the queue.
-------------------------------------------------------------------------------
function private.addPendingPost(name, count, minBid, buyoutPrice, runTime, deposit)
	-- Add a pending post to the queue.
	local pendingPost = {};
	pendingPost.name = name;
	pendingPost.count = count;
	pendingPost.minBid = minBid;
	pendingPost.buyoutPrice = buyoutPrice;
	pendingPost.runTime = runTime;
	pendingPost.deposit = deposit;
	table.insert(private.PendingPosts, pendingPost);
	debugPrint("private.addPendingPost() - Added pending post");
	
	-- Register for the response events if this is the first pending post.
	if (#private.PendingPosts == 1) then
		debugPrint("private.addPendingPost() - Registering for CHAT_MSG_SYSTEM and UI_ERROR_MESSAGE");
		Stubby.RegisterEventHook("CHAT_MSG_SYSTEM", "BeanCounter_PostMonitor", private.onEventHookPosting);
		Stubby.RegisterEventHook("UI_ERROR_MESSAGE", "BeanCounter_PostMonitor", private.onEventHookPosting);
	end
end

-------------------------------------------------------------------------------
-- Removes the pending post from the queue.
-------------------------------------------------------------------------------
function private.removePendingPost()
	if (#private.PendingPosts > 0) then
		-- Remove the first pending post.
		local post = private.PendingPosts[1];
		table.remove(private.PendingPosts, 1);
		debugPrint("private.removePendingPost() - Removed pending post");

		-- Unregister for the response events if this is the last pending post.
		if (#private.PendingPosts == 0) then
			debugPrint("private.removePendingPost() - Unregistering for CHAT_MSG_SYSTEM and UI_ERROR_MESSAGE");
			Stubby.UnregisterEventHook("CHAT_MSG_SYSTEM", "BeanCounter_PostMonitor", private.onEventHookPosting);
			Stubby.UnregisterEventHook("UI_ERROR_MESSAGE", "BeanCounter_PostMonitor", private.onEventHookPosting);
		end

		return post;
	end
	
	-- No pending post to remove!
	return nil;
end

-------------------------------------------------------------------------------
-- OnEvent handler Auctions. these are unhooked when not needed
-------------------------------------------------------------------------------
function private.onEventHookPosting(_, event, arg1)
	if (event == "CHAT_MSG_SYSTEM" and arg1) then
		debugPrint(event);
		if (arg1) then debugPrint("    "..arg1) end;
		if (arg1 == ERR_AUCTION_STARTED) then
		 	private.onAuctionCreated();
		end
	elseif (event == "UI_ERROR_MESSAGE" and arg1) then
		debugPrint(event);
		if (arg1) then debugPrint("    "..arg1) end;
		if (arg1 == ERR_NOT_ENOUGH_MONEY) then
			private.onPostFailed();
		end
	end
end

-------------------------------------------------------------------------------
-- Called when a post is accepted by the server.
-------------------------------------------------------------------------------
function private.onAuctionCreated()
	local post = private.removePendingPost();
	if (post) then
		-- Add to sales database
		local itemID, _ = private.getItemInfo(post.name, "itemid")
		local text = private.packString(post.name, post.count, post.minBid, post.buyoutPrice, post.runTime, post.deposit, time(), private.wealth)
		private.databaseAdd("postedAuctions", itemID, text)
	end
end

-------------------------------------------------------------------------------
-- Called when a post is rejected by the server.
-------------------------------------------------------------------------------
function onPostFailed()
	private.removePendingPost();
end

