--[[
	Auctioneer Advanced - Appraisals and Auction Posting
	Revision: $Id$
	Version: <%version%>

	This is an addon for World of Warcraft that adds an appriasals dialog for
	easy posting of your auctionables when you are at the auction-house.

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
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]

local libName = "Appraiser"
local libType = "Util"

AucAdvanced.Modules[libType][libName] = {}
local lib = AucAdvanced.Modules[libType][libName]
local private = {}
lib.Private = private
local print = AucAdvanced.Print
lib.name = libName

local data

local ERROR_NOITEM = "ItemId is empty"
local ERROR_NOLOCAL = "Item is unknown"
local ERROR_NOBLANK = "No blank spaces available"
local ERROR_MAXSIZE = "Item cannot stack that big"
local ERROR_AHCLOSED = "AH is not open"
local ERROR_NOTFOUND = "Item was not found in inventory"
local ERROR_NOTENOUGH = "Not enough of item available"
lib.Const = {
	ERROR_NOITEM = ERROR_NOITEM,
	ERROR_NOLOCAL = ERROR_NOLOCAL,
	ERROR_NOBLANK = ERROR_NOBLANK,
	ERROR_MAXSIZE = ERROR_MAXSIZE,
	ERROR_AHCLOSED = ERROR_AHCLOSED,
	ERROR_NOTFOUND = ERROR_NOTFOUND,
	ERROR_NOTENOUGH = ERROR_NOTENOUGH,
}

--[[
The following functions are part of the module's exposed methods:
	GetName()         (required) Should return this module's full name
	CommandHandler()  (optional) Slash command handler for this module
	Processor()       (optional) Processes messages sent by Auctioneer
	ScanProcessor()   (optional) Processes items from the scan manager
*	GetPrice()        (required) Returns estimated price for item link
*	GetPriceColumns() (optional) Returns the column names for GetPrice
	OnLoad()          (optional) Receives load message for all modules

	(*) Only implemented in stats modules; util modules do not provide
]]

function lib.GetName()
	return libName
end

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		lib.ProcessTooltip(...)
	elseif (callbackType == "auctionui") then
		private.CreateFrames(...)
	elseif (callbackType == "config") then
		private.SetupConfigGui(...)
	elseif (callbackType == "configchanged") then
		if private.frame then
			private.frame.salebox.config = true
			private.frame.SetPriceFromModel()
			private.frame.UpdateControls()
			private.frame.salebox.config = nil
		end
	elseif (callbackType == "inventory") then
		if private.frame and private.frame:IsVisible() then
			private.frame.GenerateList()
		end
		private.ProcessPosts()
	elseif (callbackType == "scanstats") then
		if private.frame then
			private.frame.cache = {}
			private.frame.GenerateList()
			private.frame.UpdateImage()
		end
	end
end

function lib.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost, additional)
	if not AucAdvanced.Settings.GetSetting("util.appraiser.model") then return end

	local itype, id, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(hyperlink)
	if itype == "item" then
		local sig
		if enchant ~= 0 then
			sig = ("%d:%d:%d:%d"):format(id, suffix, factor, enchant)
		elseif factor ~= 0 then
			sig = ("%d:%d:%d"):format(id, suffix, factor)
		elseif suffix ~= 0 then
			sig = ("%d:%d"):format(id, suffix)
		else
			sig = tostring(id)
		end

		local curModel = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..sig..".model") or "default"
		if curModel == "default" then
			curModel = AucAdvanced.Settings.GetSetting("util.appraiser.model") or "market"
		end

		local value
		if curModel == "fixed" then
			value = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".fixed.buy")
			if not value then
				value = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".fixed.bid")
			end
		elseif curModel == "market" then
			value = AucAdvanced.API.GetMarketValue(hyperlink)
		else
			value = AucAdvanced.API.GetAlgorithmValue(curModel, hyperlink)
		end

		if value then
			EnhTooltip.AddLine("Appraiser |cffddeeff("..curModel..")|r x|cffddeeff"..quantity.."|r", value * quantity)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
	end
end

function lib.OnLoad()
	AucAdvanced.Settings.SetDefault("util.appraiser.model", "market")
end


function lib.AuctionSlot(sig, bag, slot)

end

function private.DecodeSig(...)
	local matchId, matchSuffix, matchFactor, matchEnchant, matchSeed
	local sig = select(1, ...)
	if (type(sig) == "string") then
		matchId, matchSuffix, matchFactor, matchEnchant, matchSeed = strsplit(":", sig)
		matchId = tonumber(matchId)
		matchSuffix = tonumber(matchSuffix) or 0
		matchFactor = tonumber(matchFactor) or 0
		matchEnchant = tonumber(matchEnchant) or 0
		matchSeed = tonumber(matchSeed) or 0
	end
	if not matchId or matchId == 0 then matchId = select(1, ...) end
	if not matchSuffix or matchSuffix == 0 then matchSuffix = select(2, ...) end
	if not matchFactor or matchFactor == 0 then matchFactor = select(3, ...) end
	if not matchEnchant or matchEnchant == 0 then matchEnchant = select(4, ...) end
	if not matchSeed or matchSeed == 0 then matchSeed = select(5, ...) end
	matchId = tonumber(matchId)
	matchSuffix = tonumber(matchSuffix) or 0
	matchFactor = tonumber(matchFactor) or 0
	matchEnchant = tonumber(matchEnchant) or 0
	matchSeed = tonumber(matchSeed) or 0

	if matchId == 0 then return error(ERROR_NOITEM) end
	return matchId, matchSuffix, matchFactor, matchEnchant, matchSeed
end


function private.IsAuctionable(bag, slot)
	private.tip:SetOwner(UIParent, "ANCHOR_NONE")
	private.tip:ClearLines()
	private.tip:SetBagItem(bag, slot)
	local bind = AppraiserTipTextLeft2:GetText()
	private.tip:Hide()

	if bind ~= ITEM_SOULBOUND
	and bind ~= ITEM_BIND_QUEST
	and bind ~= ITEM_BIND_ON_PICKUP
	and bind ~= ITEM_CONJURED
	then
		return true
	end
end


private.BagTypes = { GetAuctionItemSubClasses(3) }
private.BagInfo = {}

-- Usage:
--   FindMatchesInBags(sig)
--   FindMatchesInBags(id, [suffix, [factor, [enchant, [seed]]]])
-- Returns:
--   { {bag, slot, count}, ... }
function private.FindMatchesInBags(...)
	local matches = {}
	local matchId, matchSuffix, matchFactor, matchEnchant, matchSeed = private.DecodeSig(...)
	local blankBag, blankSlot
	local specialBlank = false
	local isLocked = true
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
				isMultibag = (bagType == private.BagTypes[1])
			end

			if not (isMultibag or private.BagInfo[bagType]) then
				private.BagInfo[bagType] = {}
			end

			for slot=1,GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag,slot)
				if link then
					local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag,slot)
					if (locked) then
						isLocked = true
					end
						
					local itype, id, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(link)
					if not isMultibag then
						-- Store info that this bag can contain this item
						private.BagInfo[bagType][id] = true
					end

					if itype == "item"
					and id == matchId
					and suffix == matchSuffix
					and factor == matchFactor
					and enchant == matchEnchant
					and (matchSeed == 0 or seed == matchSeed)
					then
						if private.IsAuctionable(bag, slot) then
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
					elseif not specialBlank and private.BagInfo[bagType][matchId] then
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

-- /run p(AucAdvanced.Modules.Util.Appraiser.FindOrMakeStack(28399, 5))
function lib.FindOrMakeStack(sig, size)
	local itemId, s
	local id, suffix, factor, enchant, seed = private.DecodeSig(sig)
	local _,link,_,_,_,_,_, maxSize = GetItemInfo(id)
	if not link then return error(ERROR_NOLOCAL) end

	if size > maxSize then
		return error(ERROR_MAXSIZE)
	end

	local matches, total, blankBag, blankSlot = private.FindMatchesInBags(id, suffix, factor, enchant, seed)

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

	-- We will have to wait for the current process to complete
	if (CursorHasItem() or SpellIsTargeting()) then
		return
	end

	-- Join up smallest to largest stacks to build a larger stack
	-- or, split a larger stack to the right size (if space available)
	table.sort(matches, function (a,b) return a[3] < b[3] end)
	if (matches[1][3] > size) then
		-- Our smallest stack is bigger than what we need
		-- We will need to split it
		if not blankBag then
			-- Dang, no slots to split stuff into
			return error(ERROR_NOBLANK)
		end

		SplitContainerItem(matches[1][1], matches[1][2], size)
		PickupContainerItem(blankBag, blankSlot)
	elseif (matches[1][3] + matches[2][3] > size) then
		-- The smallest stack + next smallest is > than our needs, do a partial combine
		SplitContainerItem(matches[2][1], matches[2][2], size - matches[1][3])
		PickupContainerItem(matches[1][1], matches[1][2])
	else
		-- Combine the 2 smallest stacks
		PickupContainerItem(matches[1][1], matches[1][2])
		PickupContainerItem(matches[2][1], matches[2][2])
	end

end

-- Simple updater to keep actions up-to-date even if an event misfires
local updateFrame = CreateFrame("frame", nil, UIParent)
updateFrame.timer = -5 
updateFrame:SetScript("OnUpdate", function(obj, delay)
	obj.timer = obj.timer + delay
	if obj.timer > 0 then
		obj.timer = -1
		private.ProcessPosts()
	end
end)

-- Posting manager
-- /run p(AucAdvanced.Modules.Util.Appraiser.PostAuction(28399, 5, 10000, 12000, 1440))
private.postRequests = {}
function lib.PostAuction(sig, size, bid, buyout, duration, multiple)
	if not AuctionFrame
	or not AuctionFrame:IsVisible()
	then
		return error(ERROR_AHCLOSED)
	end

	if not multiple then multiple = 1 end
	for i = 1, multiple do
		table.insert(private.postRequests, { sig, size, bid, buyout, duration, 0 })
	end
	updateFrame.timer = -1
end

function private.ProcessPosts()
	if #private.postRequests <= 0
	or not AuctionFrame
	or not AuctionFrame:IsVisible()
	then
		updateFrame.timer = -10
		return
	end

	local request = private.postRequests[1]

	if (request[7]) then
		-- We're waiting for the item to vanish from the bags
		local bag, slot, origLink, expire = unpack(request[7])
		local link = GetContainerItemLink(bag,slot)
		if not link or link ~= origLink then
			-- Successful Auction!
			table.remove(private.postRequests, 1)
			updateFrame.timer = -0.1
		elseif GetTime() > expire then
			local tries = (request[6] or 0) + 1
			request[6] = tries
			if tries > 5 then
				-- Can't auction this item!
				local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag,slot)
				print(("Error attempting to auction item: %s x%d"):format(link, itemCount))
				table.remove(private.postRequests, 1)
				updateFrame.timer = -5
			else
				request[7] = nil
				updateFrame.timer = -1
			end
		end
		return
	end
		
	local success, bag, slot = pcall(lib.FindOrMakeStack, request[1], request[2])
	if not success then
		updateFrame.timer = -1
		return
	end

	if (CursorHasItem() or SpellIsTargeting()) then return end
	if bag then
		local link = GetContainerItemLink(bag,slot)
		PickupContainerItem(bag, slot)
		ClickAuctionSellItemButton()
		StartAuction(request[3], request[4], request[5])
		ClickAuctionSellItemButton()
		if (CursorHasItem()) then -- Didn't auction successfully
			-- Put it back in the bags
			ClearCursor()

			local tries = (request[6] or 0) + 1
			request[6] = tries
			if tries > 5 then
				-- Can't auction this item!
				local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag,slot)
				print(("Error attempting to auction item: %s x%d"):format(link, itemCount))
				table.remove(private.postRequests, 1)
				updateFrame.timer = -5
			else
				updateFrame.timer = -1
			end
			return
		end

		local _,_, lag = GetNetStats()
		lag = 2.5 * lag / 1000
		local expire = GetTime() + lag
		request[7] = { bag, slot, link, expire }
		updateFrame.timer = -1
	end
end


-- Pass it a sig, it will do it's best to determine the deposit rate for the item
-- Returns:
--   deposit, rate, accuracy
-- Where accuracy is:
--   true = Calculated just now from the actual AH data
--   nil = Cached result from past actual AH data
--   false = Best guess deposit rate from GetSellValue() provider and/or guessed AH rate based off location
local depositCache = {}
function lib.GetDepositAmount(sig, count)
	if not count then count = 1 end

	local deposit, rate, sellBasis

	if depositCache[sig] then
		sellBasis = depositCache[sig]
	end

	if not (AuctionFrame and AuctionFrame:IsVisible()) then
		if sellBasis then
			AucAdvanced.GetFaction()
			rate = AucAdvanced.depositRate
			deposit = math.floor(sellBasis * rate * count)

			return deposit, rate, nil
		else
			return
		end
	end

	rate = GetAuctionHouseDepositRate() / 100
	AucAdvanced.depositRate = rate
	if sellBasis then
		deposit = math.floor(sellBasis * rate * count)
		return deposit, rate, nil
	end

	if not sellBasis and GetSellValue then
		-- Check for a GetSellValue valuation
		local itemId = strsplit(":", sig)
		local sell = GetSellValue(itemId)
		if (sell) then
			deposit = math.floor(sell * rate * count)
		end
	end

	-- Well, there's no cached price, we'll have to get it ourselves!

	-- If there's an item on the cursor, we can't do it
	if CursorHasItem() or SpellIsTargeting() then return deposit, rate, false end

	-- Check to see if there's an item already in the AuctionSlot
	ClickAuctionSellItemButton()
	if (CursorHasItem()) then
		ClickAuctionSellItemButton()
		return deposit, rate, false
	end

	-- Ok, so find the item in our bags
	local success, matches = pcall(private.FindMatchesInBags, sig)
	if success==false or #matches <= 0 then return deposit, rate, false end

	-- For the best resolution, find the largest stack
	table.sort(matches, function (a,b) return a[3] > b[3] end)
	local match = matches[1]
	local bag, slot, count = unpack(match)

	-- Drop it in the auction slot, so we can get the per item / 2 hour deposit rate
	PickupContainerItem(bag, slot)
	ClickAuctionSellItemButton()
	deposit = CalculateAuctionDeposit(120)
	deposit = deposit / count
	-- Take it back out of the auction slot again
	ClickAuctionSellItemButton()
	ClearCursor()

	-- Work out the sell basis for this item and cache it
	sellBasis = deposit / rate
	depositCache[sig] = sellBasis

	deposit = math.floor(sellBasis * rate * count)
	-- Return the deposit cost and the auction rate
	return deposit, rate, true
end

private.tip = CreateFrame("GameTooltip", "AppraiserTip", UIParent, "GameTooltipTemplate")
