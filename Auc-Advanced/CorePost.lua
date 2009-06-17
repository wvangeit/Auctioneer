--[[
	Auctioneer Advanced
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

-- Current queue of items to post.
private.postRequests = {}

-- Items which we have moved and are waiting for the moves to complete.
private.moveWait = {}
private.moveEmpty = {}

-- Stores the known bag types so we can work out which bags are for
-- holding special item classes.
private.bagTypes = { GetAuctionItemSubClasses(3) }
private.bagInfo = {}

--[[
    DecodeSig(sig)
    DecodeSig(itemid, suffix, factor, enchant, seed)
      Returns: itemid, suffix, factor, enchant, seed
      Throws: ERROR_NOITEM

      This function can take either an encoded sig or predecoded values
      in order to save time.
]]
function lib.DecodeSig(...)
	local matchId, matchSuffix, matchFactor, matchEnchant, matchSeed = ...
	if (type(matchId) == "string") then
		matchId, matchSuffix, matchFactor, matchEnchant, matchSeed = strsplit(":", matchId)
	end
	matchId = tonumber(matchId) or 0
	matchSuffix = tonumber(matchSuffix) or 0
	matchFactor = tonumber(matchFactor) or 0
	matchEnchant = tonumber(matchEnchant) or 0
	matchSeed = tonumber(matchSeed) or 0

	if matchId == 0 then return error(ERROR_NOITEM) end
	return matchId, matchSuffix, matchFactor, matchEnchant, matchSeed
end

--[[
    IsAuctionable(bag, slot)
      Returns: true if the item is possibly auctionable.

      This function does not check everything, but if it says no,
      then the item is definately not auctionable.
]]
function lib.IsAuctionable(bag, slot)
	private.tip:SetOwner(UIParent, "ANCHOR_NONE")
	private.tip:ClearLines()
	private.tip:SetBagItem(bag, slot)

	if BindTypes[AppraiserTipTextLeft2:GetText()] or BindTypes[AppraiserTipTextLeft3:GetText()] then
		private.tip:Hide()
		return false
	end

	local damage, maxdur = GetContainerItemDurability(bag, slot)
	if damage then
		damage = maxdur - damage
	else
		damage = 0
	end

	private.tip:Hide()
	if damage == 0 then
		return true
	end
end

--[[
    FindMatchesInBags(sig)
    FindMatchesInBags(itemId, [suffix, [factor, [enchant, [seed] ] ] ])
      Returns: { {bag, slot, count}, ... }
	  Throws: ERROR_NOITEM

      The table is expanded as needed to hold all the matches in all the
      inventory bags that the user has. Does not include bank or other
      special bags, which are not searched at all.
]]
function lib.FindMatchesInBags(...)
	local matches = {}
	local matchId, matchSuffix, matchFactor, matchEnchant, matchSeed = lib.DecodeSig(...)
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
							table.insert(matches, {bag, slot, itemCount})
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

	local itemId, suffix, factor, enchant, seed = lib.DecodeSig(sig)
	local _,link,_,_,_,_,_, maxSize = GetItemInfo(itemId)
	if not link then return error(ERROR_NOLOCAL) end

	if size > maxSize then
		return error(ERROR_MAXSIZE)
	end

	local matches, total, blankBag, blankSlot, _, locked = lib.FindMatchesInBags(itemId, suffix, factor, enchant, seed)

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
    PostAuction(sig, size, bid, buyout, duration, [multiple])
	Throws: ERROR_AHCLOSED

	Places the request to post a stack of the "sig" item, "size" high
	into the auction house for "bid" minimum bid, and "buy" buyout and
	posted for "duration" minutes. The request will be posted
	"multiple" number of times.
]]
function lib.PostAuction(sig, size, bid, buyout, duration, multiple)
	if not AuctionFrame
	or not AuctionFrame:IsVisible()
	then
		return error(ERROR_AHCLOSED)
	end

	local postIds = {}
	if not multiple then multiple = 1 end
	for i = 1, multiple do
		local postId = (private.lastPostId or 0) + 1
		private.lastPostId = postId

		table.insert(private.postRequests, { [0]=postId, sig, size, bid, buyout, duration, 0, false, 0, 0 })
		table.insert(postIds, postId)
	end
	private.Wait(0) -- delay until next OnUpdate
	return postIds
end

--[[
    GetDepositAmount(sig, [count]) has been depreciated in favor of GetDepositCost(item, duration, faction, count)
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

-- lib.GetDepositAmount(sig, count) has been depreciated please use new global GetDepositCost(item, duration, faction, count)
function lib.GetDepositAmount(sig, count)
	AucAdvanced.API.ShowDeprecationAlert("GetDepositCost(item, duration, faction, count)", "item must be itemID or \"itemString\" or \"itemName\" or \"itemLink\" instead. Item sig will no longer be supported.");

    local itemid = strsplit(":", sig)
	local rate = AucAdvanced.depositRate
	local newfaction
	if rate == .25 then newfaction = "neutral" end
	local deposit = GetDepositCost(itemid, 12, newfaction, count)
	return deposit, rate, true
end

--[[
	PRIVATE: ProcessPosts()
	This function is responsible for maintaining and processing the post queue.
	Note:
	private.postRequests[queuenumber] = {
		[0]=postId, 
		[1]=sig, 
		[2]=size, 
		[3]=bid, 
		[4]=buyout, 
		[5]=duration, 
		[6]=failure, -- initially 0. used for number of tries to post auction, then for expiry time after posting
		[7]=uniquelink, -- initially false
		[8]=bag, 
		[9]=slot, 
	}
]]
function private.ProcessPosts(source)
	if #private.postRequests <= 0 or not (AuctionFrame and AuctionFrame:IsVisible()) then
		private.Wait() -- put timer to sleep
		return
	end

	local request = private.postRequests[1]

	-- use longer timeout delays if connectivity is bad
	local _,_, lag = GetNetStats()
	lag = max(lag * 0.003, 1)

	if request[7] then
		-- We're waiting for the item to vanish from the bags
		local link = GetContainerItemLink(request[8], request[9])
		if not link or link ~= request[7] then
			-- Successful Auction!
			tremove(private.postRequests, 1)
			private.Wait(.1) -- small delay before trying to post next auction
			AucAdvanced.SendProcessorMessage("postresult", true, request[0], request)
		elseif GetTime() > request[6] then
			-- Can't auction this item!
			local _, itemCount = GetContainerItemInfo(request[8], request[9])
			local msg = ("Unable to confirm auction for %s x%d: %s"):format(link, itemCount, ERROR_FAILTIMEOUT)
			debugPrint(msg, "CorePost", "Posting timeout", "Warning")
			message(msg)
			tremove(private.postRequests, 1)
			private.Wait(6) -- wait 6 seconds after an error message
			AucAdvanced.SendProcessorMessage("postresult", false, request[0], request, ERROR_FAILTIMEOUT)
		end
		return
	end

	local success, bag, slot = pcall(lib.FindOrMakeStack, request[1], request[2])
	if not success then
		local err = bag:match(": (.*)")
		local link, name = AucAdvanced.API.GetLinkFromSig(request[1])
		local msg
		if ConstErrors[err] then -- Check for our own special "errors"
			msg = ("Aborting post request for %s x%d: %s"):format(link, request[2], err)
			debugPrint(msg, "CorePost", "Post request aborted", "Warning")
			message(msg)
			tremove(private.postRequests, 1)
			private.Wait(6) -- wait 6 seconds after an error message
			AucAdvanced.SendProcessorMessage("postresult", false, request[0], request, err)
		else -- Unexpected (probably real) error
			msg = ("Error during post request for %s x%d: %s"):format(link, request[2], bag)
			debugPrint(msg, "CorePost", "Unexpected error", "Error")
			tremove(private.postRequests, 1)
			private.Wait(6) -- wait 6 seconds after an error message
			AucAdvanced.SendProcessorMessage("postresult", false, request[0], request, bag)
			error(msg)
		end
		return
	end

	if bag then
		local tries = request[6]
		-- if tries > 0 then something went wrong last time
		-- we want to avoid spamming with the events just triggered by our failed attempt
		-- so we will wait for the timer
		if tries > 0 and source ~= "timer" then
			return
		end
		local link = GetContainerItemLink(bag,slot)
		PickupContainerItem(bag, slot)
		ClickAuctionSellItemButton()
		StartAuction(request[3], request[4], request[5])
		ClickAuctionSellItemButton()
		if (CursorHasItem()) then -- Didn't auction successfully
			-- Put it back in the bags
			ClearCursor()

			tries = tries + 1
			request[6] = tries
			if tries >= 3 then -- up to 3 attempts
				-- Can't auction this item!
				local _, itemCount = GetContainerItemInfo(bag,slot)
				local msg = ("Unable to create auction for %s x%d: %s"):format(link, itemCount, ERROR_FAILRETRY)
				debugPrint(msg, "CorePost", "Posting Failure", "Warning")
				message(msg)
				tremove(private.postRequests, 1)
				private.Wait(6) -- wait 6 seconds after an error message
				AucAdvanced.SendProcessorMessage("postresult", false, request[0], request, ERROR_FAILRETRY)
			else
				-- If we reach this point something has gone wrong, possibly because we are trying to post too fast
				-- we want to avoid spamming this 'posting' section; we will use a larger delay value in case 'lag' is too small
				-- up to 3 attempts at least 3 seconds apart = 6 second minimum timeout
				private.Wait(lag * 3)
			end
			return
		else -- Successful post
			-- Need to wait for this item to vanish
			-- timeout at least 6 seconds
			request[6] = GetTime() + lag * 6
			request[7] = link
			request[8] = bag
			request[9] = slot
		end
	end
	private.Wait(lag) -- waiting for an event
end

--[[

    Our frames for feeding event functions and processing tooltips

]]

-- Simple timer to keep actions up-to-date even if an event misfires
--[[
	PRIVATE: Wait(delay)
	Used to control the timer
	Use delay = nil to stop the time
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
			private.ProcessPosts("inventory")
		end
	elseif event == "auctionopen" then
		if #private.postRequests > 0 then
			private.ProcessPosts("auctionopen")
		end
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
