--[[
	Auctioneer
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

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
		You have an implicit license to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]

--[[
	Auctioneer Posting Engine.

	This code helps modules that need to post things to do so in an extremely easy and
	queueable fashion.

	This code takes "sigs" as input to most of it's functions. A "sig" is simply a string that is a
	colon seperated concatenation of itemId, suffixId, suffixFactor, enchantId and seedId.
	A sig may be shortened by truncating trailing 0's in order to save storage space. Any missing
	values at the end will be set to zero when the sig is decoded.
	Also a zero seedId is special in that it will match all items regardless of seed, but a non-zero
	seedId will only match an item with exactly the same seedId.
]]
if not AucAdvanced then return end

if (not AucAdvanced.Post) then AucAdvanced.Post = {} end

local lib = AucAdvanced.Post
local private = {}
lib.Private = private

lib.Print = AucAdvanced.Print
local Const = AucAdvanced.Const
local print = lib.Print
local debugPrint = AucAdvanced.Debug.DebugPrint
local DecodeSig -- to be filled with AucAdvanced.API.DecodeSig when it has loaded

--[[
    Errors that may be "thrown" by the below functions.

	Note: We throw errors in the below functions instead of returning
	so that we can return all the way out of the function stack up to
	the controlling functions.

	When you call a function that is capable of throwing an error, you
	should do so using a pcall() and capture the success status and
	deal with any errors that are thrown.
]]
local ERROR_NOITEM = "ItemId is empty"
local ERROR_NOLOCAL = "Item is unknown"
local ERROR_NOBLANK = "No blank bag spaces available"
local ERROR_MAXSIZE = "Item cannot be stacked that high"
local ERROR_AHCLOSED = "Auctionhouse is not open"
local ERROR_NOTFOUND = "Item was not found in inventory"
local ERROR_NOTENOUGH = "Not enough of item available"
local ERROR_FAILRETRY = "Posting failed too many times"
local ERROR_FAILTIMEOUT = "Timeout while waiting for posted item to clear"

local ConstErrors = {
	ERROR_NOITEM = ERROR_NOITEM,
	[ERROR_NOITEM] = "ERROR_NOITEM",
	ERROR_NOLOCAL = ERROR_NOLOCAL,
	[ERROR_NOLOCAL] = "ERROR_NOLOCAL",
	ERROR_NOBLANK = ERROR_NOBLANK,
	[ERROR_NOBLANK] = "ERROR_NOBLANK",
	ERROR_MAXSIZE = ERROR_MAXSIZE,
	[ERROR_MAXSIZE] = "ERROR_MAXSIZE",
	ERROR_AHCLOSED = ERROR_AHCLOSED,
	[ERROR_AHCLOSED] = "ERROR_AHCLOSED",
	ERROR_NOTFOUND = ERROR_NOTFOUND,
	[ERROR_NOTFOUND] = "ERROR_NOTFOUND",
	ERROR_NOTENOUGH = ERROR_NOTENOUGH,
	[ERROR_NOTENOUGH] = "ERROR_NOTENOUGH",
	ERROR_FAILRETRY = ERROR_FAILRETRY,
	[ERROR_FAILRETRY] = "ERROR_FAILRETRY",
	ERROR_FAILTIMEOUT = ERROR_FAILTIMEOUT,
	[ERROR_FAILTIMEOUT] = "ERROR_FAILTIMEOUT",
}
lib.Const = ConstErrors

local BindTypes = {
	[ITEM_SOULBOUND] = "ITEM_SOULBOUND",
	[ITEM_BIND_QUEST] = "ITEM_BIND_QUEST",
	[ITEM_BIND_ON_PICKUP] = "ITEM_BIND_ON_PICKUP",
	[ITEM_CONJURED] = "ITEM_CONJURED",
	[ITEM_ACCOUNTBOUND] = "ITEM_ACCOUNTBOUND",
	[ITEM_BIND_TO_ACCOUNT] = "ITEM_BIND_TO_ACCOUNT",
}

-- local constants to index the posting 'request' tables
local REQ_ID = 0
local REQ_SIG = 1
local REQ_COUNT = 2
local REQ_BID = 3
local REQ_BUYOUT = 4
local REQ_DURATION = 5
local REQ_FAILCOUNT = 6
local REQ_POSTLINK = 7
local REQ_BAG = 8
local REQ_SLOT = 9

--[[
	Functions to safely handle the Post Request queue
	Direct access of private.postRequests is deprecated
]]
private.postRequests = {}
private.lastReported = 0
private.reportLock = 0
function private.QueueReport()
	if private.reportLock ~= 0 then return end
	local queuelength = #private.postRequests
	if private.lastReported ~= queuelength then
		private.lastReported = queuelength
		AucAdvanced.SendProcessorMessage("postqueue", queuelength)
	end
end
function private.SetQueueReports(activate)
	if activate then
		if private.reportLock > 0 then
			private.reportLock = private.reportLock - 1
		end
		private.QueueReport()
	else
		private.reportLock = private.reportLock + 1
	end
end
function private.QueueInsert(request)
	tinsert(private.postRequests, request)
	private.QueueReport()
end
function private.QueueRemove(index)
	index = index or 1
	if private.postRequests[index] then
		tremove(private.postRequests, index)
		private.QueueReport()
	end
end

--[[ GetQueueStatus
	(proposed: expand this function later with any other useful values)
--
function lib.GetQueueStatus()
	return #private.postRequests
end
]]

--[[ CancelPostQueue()
	Safely removes all possible Post requests from the Post queue
	If we are in the process of posting an auction, that request cannot be removed
--]]
function lib.CancelPostQueue()
	if #private.postRequests > 0 then
		local request = private.postRequests[1] -- save the first request
		wipe(private.postRequests)
		if request[REQ_POSTLINK] then -- if 'request' is currently being posted, put it back in the queue until the posting resolves
			tinsert(private.postRequests, request)
		end
		private.QueueReport()
	end
end

--[[
    PostAuction(sig, size, bid, buyout, duration, [multiple])
	Throws: ERROR_AHCLOSED

	Places the request to post a stack of the "sig" item, "size" high
	into the auction house for "bid" minimum bid, and "buy" buyout and
	posted for "duration" minutes. The request will be posted
	"multiple" number of times.
]]
private.lastPostId = 0
function lib.PostAuction(sig, size, bid, buyout, duration, multiple)
	if not AuctionFrame
	or not AuctionFrame:IsVisible()
	then
		return error(ERROR_AHCLOSED)
	end

	local postIds = {}
	if not multiple then multiple = 1 end
	private.SetQueueReports(false)
	for i = 1, multiple do
		local postId = private.lastPostId + 1
		private.lastPostId = postId

		private.QueueInsert({[0]=postId, sig, size, bid, buyout, duration, 0, false, 0, 0})
		tinsert(postIds, postId)
	end
	private.SetQueueReports(true)
	private.Wait(0) -- delay until next OnUpdate
	return postIds
end

--[[
    DecodeSig(sig)
    DecodeSig(itemid, suffix, factor, enchant, seed)
    Returns: itemid, suffix, factor, enchant, seed
	Retained for library compatibility
	Real function moved to AucAdvanced.API, with the other sig functions
]]
function lib.DecodeSig(matchId, matchSuffix, matchFactor, matchEnchant, matchSeed)
	if (type(matchId) == "string") then
		return DecodeSig(matchId)
	end
	matchId = tonumber(matchId)
	if not matchId or matchId == 0 then return end
	matchSuffix = tonumber(matchSuffix) or 0
	matchFactor = tonumber(matchFactor) or 0
	matchEnchant = tonumber(matchEnchant) or 0
	matchSeed = tonumber(matchSeed) or 0

	return matchId, matchSuffix, matchFactor, matchEnchant, matchSeed
end

--[[
    IsAuctionable(bag, slot)
      Returns: true if the item is possibly auctionable.

      This function does not check everything, but if it says no,
      then the item is definately not auctionable.
]]
function lib.IsAuctionable(bag, slot)
	local damage, maxdur = GetContainerItemDurability(bag, slot)
	if damage and damage ~= maxdur then
		return false
	end

	private.tip:SetOwner(UIParent, "ANCHOR_NONE")
	private.tip:ClearLines()
	private.tip:SetBagItem(bag, slot)
	local test = BindTypes[AppraiserTipTextLeft2:GetText()] or BindTypes[AppraiserTipTextLeft3:GetText()]
	private.tip:Hide()
	if test then
		return false
	end

	return true
end

--[[
	CountAvailableItems(sig)
	Returns: availableCount, totalCount, unpostableCount, queuedCount
	The Posting modules need to know how many items are available to be posted;
	this is not the same as the number of items currently in the bags
--]]
function lib.CountAvailableItems(sig)
	local matchId, matchSuffix, matchFactor, matchEnchant, matchSeed = DecodeSig(sig)
	if not matchId then return end
	local totalCount, unpostableCount, queuedCount = 0, 0, 0

	for bag = 0, NUM_BAG_FRAMES do
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link then
				local _, itemId, itemSuffix, itemFactor, itemEnchant, itemSeed = AucAdvanced.DecodeLink(link)
				if itemId == matchId
				and itemSuffix == matchSuffix
				and itemFactor == matchFactor
				and itemEnchant == matchEnchant
				and (matchSeed == 0 or itemSeed == matchSeed) then
					local _, count = GetContainerItemInfo(bag, slot)
					if not count or count < 1 then count = 1 end
					totalCount = totalCount + count
					if not lib.IsAuctionable(bag, slot) then
						unpostableCount = unpostableCount + count
					end
				end
			end
		end
	end

	for _, request in ipairs(private.postRequests) do
		local itemId, itemSuffix, itemFactor, itemEnchant, itemSeed = DecodeSig(request[1])
		if itemId == matchId
		and itemSuffix == matchSuffix
		and itemFactor == matchFactor
		and itemEnchant == matchEnchant
		and (matchSeed == 0 or itemSeed == matchSeed) then
			queuedCount = queuedCount + request[2]
		end
	end

	return (totalCount - unpostableCount - queuedCount), totalCount, unpostableCount, queuedCount
end

--[[
    FindMatchesInBags(sig)
    FindMatchesInBags(itemId, [suffix, [factor, [enchant, [seed] ] ] ])
    Returns: { {bag, slot, count}, ... }, itemCount, blankBagId, blankSlotNumber, foundLink, foundLocked
	Library wrapper for the internal version, to check parameters (and to support anticipated future changes)
]]
function lib.FindMatchesInBags(...)
	return private.FindMatchesInBags(lib.DecodeSig(...))
end
private.bagTypes = { GetAuctionItemSubClasses(3) }
private.bagInfo = {}
-- Internal implementation of FindMatchesInBags
function private.FindMatchesInBags(matchId, matchSuffix, matchFactor, matchEnchant, matchSeed)
	if not matchId then return end
	local matches = {}
	local blankBag, blankSlot
	local specialBlank = false
	local isLocked = false
	local foundLink
	local total = 0

	for bag=0,4 do
		local bagName = GetBagName(bag)
		if bagName then
			local bagType, isMultibag, _

			if bag == 0 then
				isMultibag = true
				bagType = "Bag"
			else
				_,_,_,_,_,_, bagType = GetItemInfo(bagName)
				isMultibag = (bagType == private.bagTypes[1])
			end

			if not (isMultibag or private.bagInfo[bagType]) then
				private.bagInfo[bagType] = {}
			end

			for slot=1,GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag,slot)
				if link then
					local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag,slot)
					if (locked) then
						isLocked = true
					end

					local itype, itemId, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(link)
					if not isMultibag then
						-- Store info that this bag can contain this item
						private.bagInfo[bagType][itemId] = true
					end

					if itype == "item"
					and itemId == matchId
					and suffix == matchSuffix
					and factor == matchFactor
					and enchant == matchEnchant
					and (matchSeed == 0 or seed == matchSeed)
					then
						if lib.IsAuctionable(bag, slot) then
							if not itemCount or itemCount < 0 then itemCount = 1 end
							tinsert(matches, {bag, slot, itemCount})
							total = total + itemCount
							foundLink = link
						end
					end
				else -- Blank slot
					if isMultibag then
						if not blankBag then
							blankBag = bag
							blankSlot = slot
						end
					elseif not specialBlank and private.bagInfo[bagType][matchId] then
						blankBag = bag
						blankSlot = slot
						specialBlank = true
					end
				end
			end
		end
	end
	return matches, total, blankBag, blankSlot, foundLink, isLocked
end

-- compare function to use in table.sort within FindOrMakeStack
function private.sortCompare(a,b)
	return a[3] < b[3]
end

--[[
    FindOrMakeStack(sig, size)
      Returns: bag, slot
      Throws: ERROR_NOITEM, ERROR_NOLOCAL, ERROR_MAXSIZE, ERROR_NOTFOUND,
	          ERROR_NOTENOUGH, ERROR_NOBLANK

      If it is possible to make a stack of the specified size, with items
      of the specified sig, this function will combine or split items to
      make the stack.
      Preference is given first to currently existing stacks of the correct
      size first.
      Next, stacks will be split or combined from the smallest stacks first
      until a correctly sized stack is created.
]]
private.moveWait = {}
private.moveEmpty = {}
function lib.FindOrMakeStack(sig, size)
	-- if we were splitting or combining a stack, check that the stack count has changed
	if private.moveWait[1] then
		local bag, slot, prev, wait = unpack(private.moveWait)
		if GetTime() < wait then
			local _, count = GetContainerItemInfo(bag,slot)
			if count == prev then
				return
			end
		end
		private.moveWait[1] = nil
	end
	-- if we were moving a stack to an empty slot, check that there is something in that slot now
	if private.moveEmpty[1] then
		local bag, slot, wait = unpack(private.moveEmpty)
		if GetTime() < wait then
			if not GetContainerItemLink(bag,slot) then
				return
			end
		end
		private.moveEmpty[1] = nil
	end

	-- If there is anything on the cursor we can't proceed until it is dropped
	if GetCursorInfo() or SpellIsTargeting() then
		return
	end

	local itemId, suffix, factor, enchant, seed = DecodeSig(sig)
	local _,link,_,_,_,_,_, maxSize = GetItemInfo(itemId)
	if not link then return error(ERROR_NOLOCAL) end

	if size > maxSize then
		return error(ERROR_MAXSIZE)
	end

	local matches, total, blankBag, blankSlot, _, locked = private.FindMatchesInBags(itemId, suffix, factor, enchant, seed)

	if locked then -- at least one of the stacks is locked - wait for it to clear
		return
	end

	if #matches == 0 then
		return error(ERROR_NOTFOUND)
	end

	if total < size then
		return error(ERROR_NOTENOUGH)
	end

	-- Try to find a stack that's exactly the right size
	for i=1, #matches do
		local match = matches[i]
		if match[3] == size then
			return match[1], match[2]
		end
	end

	-- Join up smallest to largest stacks to build a larger stack
	-- or, split a larger stack to the right size (if space available)
	table.sort(matches, private.sortCompare)
	if (matches[1][3] > size) then
		-- Our smallest stack is bigger than what we need
		-- We will need to split it
		if not blankBag then
			-- Dang, no slots to split stuff into
			return error(ERROR_NOBLANK)
		end

		SplitContainerItem(matches[1][1], matches[1][2], size)
		PickupContainerItem(blankBag, blankSlot)
		private.moveEmpty[1] = blankBag
		private.moveEmpty[2] = blankSlot
		private.moveEmpty[3] = GetTime() + 6
	elseif (matches[1][3] + matches[2][3] > size) then
		-- The smallest stack + next smallest is > than our needs, do a partial combine
		SplitContainerItem(matches[2][1], matches[2][2], size - matches[1][3])
		PickupContainerItem(matches[1][1], matches[1][2])
	else
		-- Combine the 2 smallest stacks
		PickupContainerItem(matches[1][1], matches[1][2])
		PickupContainerItem(matches[2][1], matches[2][2])
	end
	private.moveWait[1] = matches[1][1]
	private.moveWait[2] = matches[1][2]
	private.moveWait[3] = matches[1][3]
	private.moveWait[4] = GetTime() + 6
end

--[[
    GetDepositCost(item, duration, faction, count)
    You must pass item where item is -- itemID or "itemString" or "itemName" or "itemLink" --but faction duration(12, 24, or 48)[defaults to 24], faction("home" or "neutral")[defaults to home]
    and count(stacksize)[defaults to 1] are optional
]]
function GetDepositCost(item, duration, faction, count)
	-- Die if unable to complete function
	if not (item and GetSellValue) then return end

	-- Set up function defaults if not specifically provided
	if duration == 12 then duration = 1 elseif duration == 48 then duration = 4 else duration = 2 end
	if faction == "neutral" or faction == "Neutral" then faction = .75 else faction = .15 end
	count = count or 1

	local gsv = GetSellValue(item)
	if gsv then
		return math.floor(faction * gsv * count) * duration
	end
end

--[[
	PRIVATE: ProcessPosts()
	This function is responsible for maintaining and processing the post queue.
	Note:
	private.postRequests[queuenumber] = {
		[0]=postId, -- REQ_ID
		[1]=sig, -- REQ_SIG
		[2]=stackcount, -- REQ_COUNT
		[3]=bid, -- REQ_BID
		[4]=buyout, -- REQ_BUYOUT
		[5]=duration, -- REQ_DURATION
		[6]=failure, -- REQ_FAILCOUNT: initially 0. used for number of tries to post auction, then for expiry time after posting
		[7]=uniquelink, -- REQ_POSTLINK: initially false; serves as a flag for successful StartAuction and holds unique item link
		[8]=bag, -- REQ_BAG
		[9]=slot, -- REQ_SLOT
	}
]]
local LAG_ADJUST = (3 / 1000)
local POST_TIMEOUT = 6 -- seconds general timeout
local POST_ERROR_PAUSE = 6 -- seconds pause after error
local POST_RETRYS = 2 -- Numer of retrys after the original failed attempt. Must never exceed value of POST_TIMEOUT
local POST_THROTTLE = 0.1 -- time before starting to post the next item in the queue
function private.ProcessPosts(source)
	if #private.postRequests <= 0 or not (AuctionFrame and AuctionFrame:IsVisible()) then
		private.Wait() -- put timer to sleep
		return
	end

	local request = private.postRequests[1]

	-- use longer timeout delays if connectivity is bad, but always at least 1 second
	local _,_, lag = GetNetStats()
	lag = max(lag * LAG_ADJUST, 1)

	if request[REQ_POSTLINK] then
		-- We're waiting for the item to vanish from the bags
		local link = GetContainerItemLink(request[REQ_BAG], request[REQ_SLOT])
		if not link or link ~= request[REQ_POSTLINK] then
			-- Successful Auction!
			private.QueueRemove()
			private.Wait(POST_THROTTLE)
			AucAdvanced.SendProcessorMessage("postresult", true, request[REQ_ID], request)
		elseif GetTime() > request[REQ_FAILCOUNT] then
			-- Can't auction this item!
			local _, itemCount = GetContainerItemInfo(request[REQ_BAG], request[REQ_SLOT])
			local msg = ("Unable to confirm auction for %s x%d: %s"):format(link, itemCount, ERROR_FAILTIMEOUT)
			debugPrint(msg, "CorePost", "Posting timeout", "Warning")
			private.QueueRemove()
			private.Wait(POST_ERROR_PAUSE)
			AucAdvanced.SendProcessorMessage("postresult", false, request[REQ_ID], request, ERROR_FAILTIMEOUT)
			message(msg)
		end
		return
	end

	local success, bag, slot = pcall(lib.FindOrMakeStack, request[REQ_SIG], request[REQ_COUNT])
	if not success then
		local err = bag:match(": (.*)")
		local link, name = AucAdvanced.API.GetLinkFromSig(request[REQ_SIG])
		local msg
		if ConstErrors[err] then -- Check for our own special "errors"
			msg = ("Aborting post request for %s x%d: %s"):format(link, request[REQ_COUNT], err)
			debugPrint(msg, "CorePost", "Post request aborted", "Warning")
			private.QueueRemove()
			private.Wait(POST_ERROR_PAUSE)
			AucAdvanced.SendProcessorMessage("postresult", false, request[REQ_ID], request, err)
			message(msg)
		else -- Unexpected (probably real) error
			msg = ("Error during post request for %s x%d: %s"):format(link, request[REQ_COUNT], bag)
			debugPrint(msg, "CorePost", "Unexpected error", "Error")
			private.QueueRemove()
			private.Wait(POST_ERROR_PAUSE)
			AucAdvanced.SendProcessorMessage("postresult", false, request[REQ_ID], request, bag)
			error(msg)
		end
		return
	end

	if bag then
		local tries = request[REQ_FAILCOUNT]
		-- if tries > 0 then something went wrong last time
		-- we want to avoid spamming with the events just triggered by our failed attempt
		-- so we will wait for the timer
		if tries > 0 and source ~= "timer" then
			return
		end
		local link = GetContainerItemLink(bag,slot)
		PickupContainerItem(bag, slot)
		ClickAuctionSellItemButton()
		StartAuction(request[REQ_BID], request[REQ_BUYOUT], request[REQ_DURATION])
		ClickAuctionSellItemButton()
		if (CursorHasItem()) then -- Didn't auction successfully
			ClearCursor() -- Put it back in the bags

			tries = tries + 1
			request[REQ_FAILCOUNT] = tries
			if tries > POST_RETRYS then
				-- Can't auction this item!
				local _, itemCount = GetContainerItemInfo(bag,slot)
				local msg = ("Unable to create auction for %s x%d: %s"):format(link, itemCount, ERROR_FAILRETRY)
				debugPrint(msg, "CorePost", "Posting Failure", "Warning")
				private.QueueRemove()
				private.Wait(POST_ERROR_PAUSE)
				AucAdvanced.SendProcessorMessage("postresult", false, request[REQ_ID], request, ERROR_FAILRETRY)
				message(msg)
			else
				-- If we reach this point something has gone wrong, possibly because we are trying to post too fast
				-- we want to avoid spamming this 'posting' section; we will use a larger delay value in case 'lag' is too small
				-- Original plus POST_RETRYS attempts, at least (POST_TIMEOUT/POST_RETRYS) seconds apart = POST_TIMEOUT minimum timeout
				private.Wait(lag * POST_TIMEOUT / POST_RETRYS)
			end
			return
		else -- Successful post - wait for this item to vanish
			request[REQ_FAILCOUNT] = GetTime() + lag * POST_TIMEOUT
			request[REQ_POSTLINK] = link
			request[REQ_BAG] = bag
			request[REQ_SLOT] = slot
		end
	end
	private.Wait(lag)
end

--[[

    Our frames for feeding event functions and processing tooltips

]]

-- Simple timer to keep actions up-to-date even if an event misfires
--[[
	PRIVATE: Wait(delay)
	Used to control the timer
	Use delay = nil to stop the timer
	Use delay >= 0 to start the timer and set the delay length
--]]
function private.Wait(delay)
	if delay then
		if not private.updateFrame.timer then
			private.updateFrame:Show()
		end
		private.updateFrame.timer = delay
	else
		if private.updateFrame.timer then
			private.updateFrame:Hide()
			private.updateFrame.timer = nil
		end
	end
end

function lib.Processor(event, ...)
	if event == "inventory" then
		if private.updateFrame.timer then
			private.ProcessPosts(event)
		end
	elseif event == "auctionopen" then
		if #private.postRequests > 0 then
			private.ProcessPosts(event)
		end
	end
end

function lib.OnLoad(addon)
	if addon == "auc-advanced" then
		DecodeSig = AucAdvanced.API.DecodeSig
	end
end

private.updateFrame = CreateFrame("frame", nil, UIParent)
private.updateFrame:Hide()
private.updateFrame:SetScript("OnUpdate", function(obj, delay)
	obj.timer = obj.timer - delay
	if obj.timer <= 0 then
		obj.timer = 6 -- safety value, will be overwritten later
		private.ProcessPosts("timer")
	end
end)

-- Local tooltip for getting soulbound line from tooltip contents
private.tip = CreateFrame("GameTooltip", "AppraiserTip", UIParent, "GameTooltipTemplate")

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
