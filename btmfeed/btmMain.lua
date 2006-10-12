--[[
	BottomFeeder
	Revision: $Id$
	Version: <%version%> (<%codename%>)

	This is an addon for World of Warcraft that allows searching and analysis
	of the auction contents for specific good buys. When it identifies something
	that is a "good buy" according to the rules you set, it can either place a
	bid or buyout the item.

	Please note that this addon is not intended for unattended usage. Any such
	usage of this addon is against the tennants set forth in the World of Warcraft
	Terms of Use and End User Licence Agreement, and will get your account banned.

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

BtmFeedData = {}
local tr = BtmFeed.Locales.Translate
local data, dataZone

-- Load function gets run when this addon has loaded.
BtmFeed.OnLoad = function ()
	BtmFeed.Print(tr("Welcome to BottomFeeder. Type /btm for help"))

	-- Register our command handlers
	SLASH_BTMFEED1 = "/btm"
	SLASH_BTMFEED2 = "/btmfeed"
	SLASH_BTMFEED3 = "/bottomfeed"
	SLASH_BTMFEED4 = "/bottomfeeder"
	SlashCmdList["BTMFEED"] = BtmFeed.Command

	-- Ensure sane defaults
	if (not BtmFeedData.config) then BtmFeedData.config = {} end
	if (not BtmFeedData.factions) then BtmFeedData.factions = {} end
	if (not BtmFeedData.refresh) then BtmFeedData.refresh = 25 end

	-- Hook into functions (if Stubby exists)
	if (Stubby and Stubby.RegisterFunctionHook) then
		Stubby.RegisterFunctionHook("EnhTooltip.AddTooltip", 600, BtmFeed.TooltipHook)
		Stubby.RegisterFunctionHook("QueryAuctionItems", 600, BtmFeed.QueryAuctionItems)
	end

	BtmFeed.timer = 0
end

-- Event handler
BtmFeed.OnEvent = function()
	if (event == "ADDON_LOADED") then
		if (string.lower(arg1) == "btmfeed") then
			BtmFeed.OnLoad()
		end
	end
end

-- Timing routines
BtmFeed.interval = 30
BtmFeed.offset = 0
BtmFeed.timer = 0
BtmFeed.OnUpdate = function()
	local elapsed = arg1

	if (not BtmFeed.lastTry) then BtmFeed.lastTry = 0 end
	if (not BtmFeed.LogFrame and AuctionFrame and BtmFeed.lastTry < BtmFeed.timer - 1 ) then
		BtmFeed.CreateLogWindow()
		if (BtmFeed.LogFrame) then BtmFeed.LogFrame.Update() end
		BtmFeed.lastTry = BtmFeed.timer
	end

	if (not BtmFeed.aucPriceModel and AuctionFramePost_AdditionalPricingModels) then
		BtmFeed.aucPriceModel = true
		table.insert(AuctionFramePost_AdditionalPricingModels, BtmFeed.AddAuctPriceModel)
	end

	BtmFeed.timer = BtmFeed.timer + elapsed
	if (BtmFeed.pageScan) then
		if (BtmFeed.timer > BtmFeed.pageScan) then
			BtmFeed.PageScan()
		elseif (BtmFeed.timer > BtmFeed.pageScan-0.25) then
			BtmFeed.LogParent:SetBackdropColor(0,0,0.5, 0.9)
		end
	end
	if (BtmFeed.timer < BtmFeed.interval) then
		return
	end
	BtmFeed.timer = BtmFeed.timer - BtmFeed.interval

	-- If we are supposed to be scanning, then let's do it!
	if (BtmFeed.scanning) then

		-- Time to scan the page
		if (not BtmFeed.pageCount) then
			BtmFeed.pageCount = -1
		end

		-- Get the current number of auctions
		local pageCount, totalCount = GetNumAuctionItems("list")
		local totalPages = math.floor((totalCount-1)/50)
		if (totalPages < 0) then totalPages = 0 end
		if (totalPages ~= BtmFeed.pageCount) then
			BtmFeed.pageCount = totalPages
			BtmFeed.interval = 6 -- Short cut the delay, we need to reload now damnit!
		else
			BtmFeed.interval = BtmFeedData.refresh
		end

		-- Check to see if the AH is open for business
		if (not CanSendAuctionQuery() or not (AuctionFrame and AuctionFrame:IsVisible())) then
			BtmFeed.interval = 1 -- Try again in one second
			return
		end

		-- Every 5 pages, go back a page just to double check that nothing got by us.
		BtmFeed.offset = math.mod(BtmFeed.offset + 1, 5)
		local offset = 0
		if (BtmFeed.offset == 0) then offset = 1 end

		-- Show me tha money!
		QueryAuctionItems("", "", "", nil, nil, nil, BtmFeed.pageCount-offset, nil, nil)
	end
end


BtmFeed.QueryAuctionItems = function(par,ret, name,lmin,lmax,itype,class,sclass,page,able,qual)
	if (not BtmFeed.scanning) then return end

	-- Kewl, lets schedule a scan of this page for 2 seconds into the future.
	BtmFeed.timer = 0
	BtmFeed.pageScan = 2
end

BtmFeed.PageScan = function()
	BtmFeed.pageScan = nil
	if (not BtmFeed.scanning) then return end

	-- Make sure the current zone is loaded and has defaults
	BtmFeed.GetZoneConfig("pagescan")

	-- Ok, we've just queried the auction house, page should be loaded etc.
	-- lets get the items on the list and scan them.
	local pageCount, totalCount = GetNumAuctionItems("list")

	local log = BtmFeed.Log
	if (BtmFeed.dryRun) then log = BtmFeed.Print end

	-- Ok, lets look at all these lovely items
	for i=1, pageCount do
		local itemLink = GetAuctionItemLink("list", i)

		-- If:
		--   * This item has been loaded
		if (itemLink) then

			-- Break apart the link and assemble the keys
			local itemID, itemRand, itemEnch, itemUniq = BtmFeed.BreakLink(itemLink)
			local sanityKey = itemID..":"..itemRand
			local auctKey = itemID..":"..itemRand..":"..itemEnch

			-- Check to see that we're not ignoring this item
			if (not data.ignore[sanityKey]) then

				-- Get the auction information for this this item
				local iName, iTex, iCount, iQual, iUse, iLvl, iMin, iInc, iBuy, iCur, iHigh, iOwner = GetAuctionItemInfo("list", i)

				-- Work out what the next bid will be
				local iBid = iMin
				if (iCur and iCur > 0) then iBid = iCur + iInc end

				-- If:
				--   * This item has a buyout price
				--   * It's not owned by us
				--   * It's not gonna break the bank
				if (iOwner ~= UnitName('player')) then

					-- Check to see if we have overspent the safetynet on this item
					-- Note that it is possible to overspend the safety amount, as
					-- the safetynet only kicks in once you have met or exceeded this
					-- amount spent.
					local ignoreItem = false
					if (not BtmFeed.sessionSpend) then BtmFeed.sessionSpend = {} end
					if (BtmFeed.sessionSpend[sanityKey]) then
						local sSpend = BtmFeed.sessionSpend[sanityKey]
						if (sSpend.count >= data.safetyCount) then
							ignoreItem = true
						elseif (sSpend.cost >= data.safetyCost) then
							ignoreItem = true
						end

						if (not BtmFeed.dryRun and ignoreItem and not sSpend.warned) then
							log(tr("Warning: Safety limit reached on item: %1", itemLink))
							BtmFeed.sessionSpend[sanityKey].warned = true
						end
					end

					-- If this item doesn't breach the safetynet
					if (not ignoreItem) then

						-- Get vendor price if available
						local vendorValue = BtmFeed.GetVendorPrice(itemID, iCount)

						-- Get disenchant value if available
						local disenchantValue = 0
						if (Enchantrix and Enchantrix.Storage) then
							local disenchantTo = Enchantrix.Storage.GetItemDisenchants(Enchantrix.Util.GetSigFromLink(itemLink), itemName, true)
							if (disenchantTo and disenchantTo.totals and disenchantTo.totals.hspValue and iQual > 1 and iCount <= 1) then
								disenchantValue = disenchantTo.totals.hspValue * disenchantTo.totals.conf
							end
						end

						-- Get snatch value if it has been set
						local snatchAmount = data.snatch[sanityKey]
						local snatchPrice, snatchCount, snatchStack
						if (type(snatchAmount) ~= "table") then
							snatchPrice = tonumber(snatchAmount) or 0
							snatchCount = 0
							snatchStack = 0
						else
							snatchPrice = tonumber(snatchAmount[1]) or 0
							snatchCount = tonumber(snatchAmount[2]) or 0
							snatchStack = tonumber(snatchAmount[3]) or 0
						end
						snatchPrice = snatchPrice * iCount
						local snatched = tonumber(data.snatched[sanityKey]) or 0
						if (snatched + iCount > snatchCount and snatchCount > 0) then
							snatchPrice = 0
						end

						local _,_,_,_,_,_,stackSize = GetItemInfo(itemID)
						if (not stackSize) then
							if (snatchStack > 0) then
								stackSize = snatchStack
							else
								stackSize = 1
							end
						end

						-- Initialize buyIt to false
						local buyIt = false
						local bidIt = false
						local ignoreIt = false
						local whyBuy = ""
						local noSafety = false
						local buying = itemLink
						local message

						if (iCount and iCount > 1) then buying = buying.."x"..iCount end

						-- If this item is not trash (grey) quality
						if (iQual > 0) then

							-- Grab the sane price from our list
							--   Note these are compiled averages from all factions and servers
							--   This is meant to "double check" the Auctioneer prices, if both
							--   agree that this item is a "good buy", only then will we buy it
							local sanity = BtmFeed.ConfidenceList[sanityKey]
							local iqm, iqwm, iqCount, bBase, bCount
							if (sanity) then
								local prices = BtmFeed.Split(sanity, ",")
								iqm = tonumber(prices[1])
								iqwm = tonumber(prices[2])
								iqCount = tonumber(prices[3])
								bCount = data.minSeen
								bBase = iqwm

								-- Use the worst case scenario from inbuilt or auctioneer prices
								-- (if available)
								local auctMedian, auctCount
								if (Auctioneer and Auctioneer.Statistic) then
									auctMedian, auctCount = Auctioneer.Statistic.GetUsableMedian(auctKey)
									bCount = 0
									if (auctMedian and auctCount) then
										if (bBase >= auctMedian) then
											bBase = auctMedian
										end
										bCount = auctCount
									end
								end
								if (not auctMedian) then auctMedian = 0 end
								if (not auctCount) then auctCount = 0 end

								if (not iCount or iCount < 1) then iCount = 1 end
								local deposit = BtmFeed.GetDepositCost(itemID, iCount)
								if (not deposit) then deposit = 0 end

								if (BtmFeed.BaseRule) then
									BtmFeed.prices = {
										consKey = sanityKey,
										consMean = iqm * iCount,
										consPrice = iqwm * iCount,
										consSeen = iqCount,
										auctKey = auctKey,
										auctPrice = auctMedian * iCount,
										auctSeen = auctCount,
										itemID = itemID,
										itemRand = itemRand,
										itemEnch = itemEnch,
										itemCount = iCount,
										buyPrice = iBuy,
										bidPrice = iBid,
										basePrice = bBase * iCount,
										depositCost = deposit,
									}
									bBase = BtmFeed.BaseRule()
								else
									bBase = bBase * iCount
								end

								-- If user has specified a specific worth for this item, use it
								if (data.worth[sanityKey]) then
									bBase = tonumber(data.worth[sanityKey]) * iCount
									bCount = data.minSeen
									noSafety = true
								end

								-- Work out what the required profit will be
								local requiredProfit = data.minProfit
								-- White or lower items have a multiplier added to them
								if (iQual < 2) then requiredProfit = requiredProfit * data.commonMult end

								-- Find out what the profitable price will be based on pctprofit
								local profitablePrice = iBuy * (1+data.pctProfit/100)
								local profitableBid = iBid * (1+data.pctProfit/100)
								-- Work out which is larger, pctProfit, or requiredProfit
								if (iBuy + requiredProfit > profitablePrice) then
									-- Use requiredProfit instead
									profitablePrice = iBuy + requiredProfit
								end
								if (iBid + requiredProfit > profitableBid) then
									profitableBid = iBid + requiredProfit
								end

								-- If:
								--    * It's base price (what we think it's worth) is better
								--      than what would be profitable for this item.
								--    * It's buyout cost is less than our maximum price
								--    * It meets our minimum seen count requirement
								if (bBase and bBase > 0 and bCount >= data.minSeen) then
									if (iBuy and iBuy>0 and bBase >= profitablePrice and iBuy <= data.maxPrice and GetMoney()-iBuy >= data.reserve) then
										whyBuy = tr("resale")
										message = tr("Buying %1 at %2 [%3 at %4 = %5 profit]", buying, BtmFeed.GSC(iBuy), whyBuy, tr("%1 (%2 med x%3 / %4 cons)", BtmFeed.GSC(bBase), BtmFeed.GSC(auctMedian), auctCount, BtmFeed.GSC(iqwm)), BtmFeed.GSC(bBase-iBuy))
										buyIt = true
									elseif (bBase >= profitableBid and iBid <= data.maxPrice and GetMoney()-iBid >= data.reserve) then
										whyBuy = tr("resale")
										message = tr("Bidding %1 at %2 [%3 at %4 = %5 profit]", buying, BtmFeed.GSC(iBid), whyBuy, tr("%1 (%2 med x%3 / %4 cons)", BtmFeed.GSC(bBase), BtmFeed.GSC(auctMedian), auctCount, BtmFeed.GSC(iqwm)), BtmFeed.GSC(bBase-iBid))
										bidIt = true
									end
								end

								if (iBuy > bBase * 100) then ignoreIt = true end
							end


							-- If:
							--   * We're not buying it
							--   * It has a disenchant value
							if (not buyIt and disenchantValue > 0) then

								-- We need to increase the required profit for disenchants
								-- since there is often a chance that it will not D/E into
								-- what we want it to. (/btm defactor)

								local profitablePrice = iBuy * (1+data.pctDeProfit/100)
								local profitableBid = iBid * (1+data.pctDeProfit/100)
								-- Work out which is larger, pctDeProfit, or minDeProfit
								if (iBuy + data.minDeProfit > profitablePrice) then
									-- Use minDeProfit instead
									profitablePrice = iBuy + data.minDeProfit
								end
								if (iBid + data.minDeProfit > profitableBid) then
									profitableBid = iBid + data.minDeProfit
								end

								-- If:
								--   * This item's de value is more than the profitable price
								--   * It's buyout cost is less than our maximum price
								if (iBuy and iBuy>0 and disenchantValue >= profitablePrice and iBuy <= data.maxPrice and GetMoney()-iBuy >= data.reserve) then
									whyBuy = tr("disenchant")
									message = tr("Buying %1 at %2 [%3 at %4 = %5 profit]", buying, BtmFeed.GSC(iBuy), whyBuy, BtmFeed.GSC(disenchantValue), BtmFeed.GSC(disenchantValue-iBuy))
									buyIt = true
									noSafety = true
								elseif (not bidIt and disenchantValue >= profitableBid and iBid <= data.maxPrice and GetMoney()-iBid >= data.reserve) then
									whyBuy = tr("disenchant")
									message = tr("Bidding %1 at %2 [%3 at %4 = %5 profit]", buying, BtmFeed.GSC(iBid), whyBuy, BtmFeed.GSC(disenchantValue), BtmFeed.GSC(disenchantValue-iBid))
									bidIt = true
									noSafety = true
								end
							end
						end --if (not trash)

						-- If:
						--   * We're not buying it
						--   * It has a vendor value
						if (not buyIt and vendorValue and vendorValue > 0) then
							local profitablePrice = iBuy + data.vendProfit
							local profitableBid = iBid + data.vendProfit

							-- If:
							--   * This item's vendor value is more than the profitable price
							--   * It's buyout cost is less than our maximum price
							if (iBuy and iBuy>0 and vendorValue >= profitablePrice and iBuy <= data.maxPrice and GetMoney()-iBuy >= data.reserve) then
								whyBuy = tr("vendor")
								message = tr("Buying %1 at %2 [%3 at %4 = %5 profit]", buying, BtmFeed.GSC(iBuy), whyBuy, BtmFeed.GSC(vendorValue), BtmFeed.GSC(vendorValue-iBuy))
								buyIt = true
								noSafety = true
							elseif (not bidIt and vendorValue >= profitableBid and iBid <= data.maxPrice and GetMoney()-iBid >= data.reserve) then
								whyBuy = tr("vendor")
								message = tr("Bidding %1 at %2 [%3 at %4 = %5 profit]", buying, BtmFeed.GSC(iBid), whyBuy, BtmFeed.GSC(vendorValue), BtmFeed.GSC(vendorValue-iBid))
								bidIt = true
								noSafety = true
							end

							if (iBuy > vendorValue * 100) then ignoreIt = true end
						end

						-- If:
						--   * We're not buying it
						--   * It has a snatch value
						local snatching
						if (not buyIt and snatchPrice > 0) then
							if (iBuy and iBuy>0 and iBuy < snatchPrice and GetMoney()-iBuy >= data.reserve) then
								whyBuy = tr("snatch")
								message = tr("Buying %1 at %2 [%3 at %4 = %5 profit]", buying, BtmFeed.GSC(iBuy), whyBuy, BtmFeed.GSC(snatchPrice), BtmFeed.GSC(snatchPrice-iBuy))
								buyIt = true
								noSafety = true
								snatching = true
							elseif (not bidIt and iBid <= snatchPrice and GetMoney()-iBid >= data.reserve) then
								whyBuy = tr("snatch")
								message = tr("Bidding %1 at %2 [%3 at %4 = %5 profit]", buying, BtmFeed.GSC(iBid), whyBuy, BtmFeed.GSC(snatchPrice), BtmFeed.GSC(snatchPrice-iBid))
								bidIt = true
								noSafety = true
							end

							if (iBuy > snatchPrice * 100) then ignoreIt = true end
						end

						-- If for some reason the buyIt flag was set above, then place a bid on this item
						-- equal to the buyout price (ie: buy it out)
						if (buyIt or bidIt) then
							local bidType, bidPrice
							if (buyIt) then
								bidType = tr("bought")
								bidPrice = iBuy
							elseif (bidIt and data.allowBids > 0 and not iHigh and not ignoreIt) then
								bidType = tr("bid on")
								bidPrice = iBid
							end
							
							if (bidPrice and GetMoney()-bidPrice >= data.reserve and bidPrice <= data.maxPrice) then
								log(message)
								if (BtmFeed.dryRun) then
									BtmFeed.Print(tr("Would have %1 %2 for %3, but we are doing a dry run.", bidType, buying, bidPrice))
								else
									local bidSig = itemLink.."x"..iCount
									data.bids[bidSig] = { whyBuy, bidPrice, bidType, time() }
									PlaceAuctionBid("list", i, bidPrice)
									-- Mark this item as "bought"
									if (not noSafety) then
										local bought = 1
										if (stackSize > 1) then
											bought = iCount / stackSize
										end
										
										if (BtmFeed.sessionSpend[sanityKey]) then
											BtmFeed.sessionSpend[sanityKey].count = BtmFeed.sessionSpend[sanityKey].count + bought 
											BtmFeed.sessionSpend[sanityKey].cost = BtmFeed.sessionSpend[sanityKey].cost + bidPrice
										else
											BtmFeed.sessionSpend[sanityKey] = { count = bought, cost = bidPrice }
										end
									end
									if (snatching) then
										data.snatched[sanityKey] = snatched + iCount
									end
								end
							end
						end
					end
				end
			end
		end
	end
	BtmFeed.LogParent:SetBackdropColor(0,0,0, 0.8)
end

-- Get a GSC value and work out what it's worth
BtmFeed.ParseGSC = function (price)
	price = string.gsub(price, "|c[0-9a-fA-F]+", " ")
	price = string.gsub(price, "[gG]", "0000 ")
	price = string.gsub(price, "[sS]", "00 ")
	price = string.gsub(price, "[^0-9]+", " ")

	local total = 0
	for q in string.gfind(price, "(%d+)") do
		local number = tonumber(q) or 0
		total = total + number
	end
	return total
end

-- Break an ItemID into it's component pieces
BtmFeed.BreakLink = function (link)
	if (type(link) ~= 'string') then return end
	local i,j, whole, itemID, enchant, randomProp, uniqID, name, remain = string.find(link, "(|c[0-9a-fA-F]+|Hitem:(%d+):(%d+):(%d+):(%d+)|h[[]([^]]+)[]]|h|r)(.*)")

	local i,j, count, nextpart = string.find(remain or "", "^x(%d+)(.*)")
	if (i) then
		count = tonumber(count) or 0
		remain = nextpart
	else count = 0 end
	local i,j, price, nextpart = string.find(remain or "", "^ at ([^ ]+)(.*)")
	if (i) then
		price = BtmFeed.ParseGSC(price)
		remain = nextpart
	else price = 0 end 
	return tonumber(itemID) or 0, tonumber(randomProp) or 0, tonumber(enchant) or 0, tonumber(uniqID) or 0, name, whole, count, price, remain
end

-- Item Designation used in several places
BtmFeed.ItemDes = function (link)
	local itemID, itemRand, _,_,_, itemLink, count, price, remain = BtmFeed.BreakLink(link)
	if (not itemID) then return end
	return string.format("%d:%d", tonumber(itemID) or 0, tonumber(itemRand) or 0), tonumber(count) or 0, tonumber(price) or 0, itemID, itemRand, itemLink, remain
end

-- Item Designation used in several places
BtmFeed.BreakItemDes = function (des)
	local i,j, itemID, itemRand = string.find(des, "(%d+):(%d+)")
	return tonumber(itemID) or 0, tonumber(itemRand) or 0
end

-- Makes up a pretend link based off the hyperlink code
BtmFeed.FakeLink = function (hyperlink, quality, name)
	if not hyperlink then return end
	local sName, sLink, iQuality = GetItemInfo(hyperlink)
	if (quality == nil) then quality = iQuality or -1 end
	if (name == nil) then name = sName or "unknown ("..hyperlink..")" end
	local _, _, _, color = GetItemQualityColor(quality)
	return color.. "|H"..hyperlink.."|h["..name.."]|h|r"
end



-- Split a string at a certain character
BtmFeed.Split = function (str, at)
	if (type(str) ~= "string") then return nil end
	local splut = {}
	if (not str) then str = "" end
	if (not at) then table.insert(splut, str)
	else for n, c in string.gfind(str, '([^%'..at..']*)(%'..at..'?)') do
		table.insert(splut, n)
		if (c == '') then break end
	end end
	return splut
end

BtmFeed.GetGSC = function (money)
	if (money == nil) then money = 0 end
	local g = math.floor(money / 10000)
	local s = math.floor((money - (g*10000)) / 100)
	local c = math.ceil(money - (g*10000) - (s*100))
	return g,s,c
end

-- formats money text by color for gold, silver, copper
BtmFeed.GSC = function (money, exact, dontUseColorCodes)
	if (type(money) ~= "number") then return end

	local TEXT_NONE = "0"

	local GSC_GOLD="ffd100"
	local GSC_SILVER="e6e6e6"
	local GSC_COPPER="c8602c"
	local GSC_START="|cff%s%d%s|r"
	local GSC_PART=".|cff%s%02d%s|r"
	local GSC_NONE="|cffa0a0a0"..TEXT_NONE.."|r"

	if (not money) then money = 0 end
	if (not exact) and (money >= 10000) then money = math.floor(money / 100 + 0.5) * 100 end
	local g, s, c = BtmFeed.GetGSC(money)

	local gsc = ""
	if (not dontUseColorCodes) then
		local fmt = GSC_START
		if (g > 0) then gsc = gsc..string.format(fmt, GSC_GOLD, g, 'g') fmt = GSC_PART end
		if (s > 0) or (c > 0) then gsc = gsc..string.format(fmt, GSC_SILVER, s, 's') fmt = GSC_PART end
		if (c > 0) then gsc = gsc..string.format(fmt, GSC_COPPER, c, 'c') end
		if (gsc == "") then gsc = GSC_NONE end
	else
		if (g > 0) then gsc = gsc .. g .. "g " end
		if (s > 0) then gsc = gsc .. s .. "s " end
		if (c > 0) then gsc = gsc .. c .. "c " end
		if (gsc == "") then gsc = TEXT_NONE end
	end
	return gsc
end

BtmFeed.Print = function (text, cRed, cGreen, cBlue, cAlpha, holdTime)
	local frameIndex = BtmFeed.getFrameIndex()

	if (cRed and cGreen and cBlue) then
		if getglobal("ChatFrame"..frameIndex) then
			getglobal("ChatFrame"..frameIndex):AddMessage(text, cRed, cGreen, cBlue, cAlpha, holdTime)

		elseif (DEFAULT_CHAT_FRAME) then
			DEFAULT_CHAT_FRAME:AddMessage(text, cRed, cGreen, cBlue, cAlpha, holdTime)
		end

	else
		if getglobal("ChatFrame"..frameIndex) then
			getglobal("ChatFrame"..frameIndex):AddMessage(text, 0.9, 0.6, 0.2)

		elseif (DEFAULT_CHAT_FRAME) then
			DEFAULT_CHAT_FRAME:AddMessage(text, 0.9, 0.6, 0.2)
		end
	end
end

BtmFeed.getFrameNames = function (index)
	local frames = {}
	local frameName = ""

	for i=1, 10 do
		local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(i)

		if ( name == "" ) then
			if (i == 1) then
				frames[string.lower(GENERAL)] = 1

			elseif (i == 2) then
				frames[string.lower(COMBAT_LOG)] = 2
			end

		else
			frames[string.lower(name)] = i
		end
	end

	if (type(index) == "number") then
		local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(index)

		if ( name == "" ) then
			if (index == 1) then
				frameName = GENERAL

			elseif (index == 2) then
				frameName = COMBAT_LOG
			end

		else
			frameName = name
		end
	end

	return frames, frameName
end

BtmFeed.getFrameIndex = function ()
	if not BtmFeedData.printFrame then return 1 end
	return tonumber(BtmFeedData.printFrame) or 1
end

BtmFeed.setFrame = function (frame, chatprint)
	local frameNumber
	local frameVal
	frameVal = tonumber(frame)

	--If no arguments are passed, then set it to the default frame.
	if not (frame) then
		frameNumber = 1

	--If the frame argument is a number then set our chatframe to that number.
	elseif ((frameVal) ~= nil) then
		frameNumber = frameVal

	--If the frame argument is a string, find out if there's a chatframe with that name, and set our chatframe to that index. If not set it to the default frame.
	elseif (type(frame) == "string") then
		local allFrames = BtmFeed.getFrameNames()
		if (allFrames[string.lower(frame)]) then
			frameNumber = allFrames[frame]
		else
			frameNumber = 1
		end

	--If the argument is something else, set our chatframe to its default value.
	else
		frameNumber = 1
	end

	local _, frameName

	_, frameName = BtmFeed.getFrameNames(frameNumber)
	if (BtmFeed.getFrameIndex() ~= frameNumber) then
		BtmFeed.Print(tr("BottomFeeder's messages will now print on the \"%1\" chat frame", frameName))
	end

	BtmFeedData.printFrame = frameNumber
	BtmFeed.Print(tr("BottomFeeder's messages will now print on the \"%1\" chat frame", frameName))
end

BtmFeed.Log = function (msg)
	-- Make sure the current zone is loaded and has defaults
	BtmFeed.GetZoneConfig("log")

	if (not data.logText) then data.logText = {} end
	table.insert(data.logText, { time(), msg })
	if (not BtmFeed.LogFrame) then BtmFeed.CreateLogWindow() end
	if (BtmFeed.LogFrame) then BtmFeed.LogFrame.Update() end
end

-- Command function handles the processing of slash commands.
BtmFeed.Command = function (msg)
	local i,j, ocmd, oparam = string.find(msg, "^([^ ]+) (.*)$")
	local i,j, cmd, param = string.find(string.lower(msg), "^([^ ]+) (.*)$")
	if (not i) then cmd = msg param = nil oparam = nil end
	if (oparam == "") then param = nil oparam = nil end

	if (not BtmFeedData.unlocked) then
		if (cmd == "agree") then
			BtmFeedData.unlocked = true
			BtmFeed.Print(tr("BottomFeeder is now unlocked."))
		else
			BtmFeed.Print(tr("BottomFeeder is subject to a Limited Licence."))
			BtmFeed.Print(tr("Please see Licence.txt to unlock this addon."))
		end
		return
	end

	-- Make sure the current zone is loaded and has defaults
	BtmFeed.GetZoneConfig("command")

	local help = false
	if (cmd == "maxprice") then
		if (param) then
			data.maxPrice = BtmFeed.ParseGSC(param)
		end
		BtmFeed.Print(tr("BottomFeeder has set %1 to %2", tr("Maximum Price"), BtmFeed.GSC(data.maxPrice,1)))
	elseif (cmd == "minprofit") then
		if (param) then
			data.minProfit = BtmFeed.ParseGSC(param)
		end
		BtmFeed.Print(tr("BottomFeeder has set %1 to %2", tr("Minimum Profit"), BtmFeed.GSC(data.minProfit,1)))
	elseif (cmd == "pctprofit") then
		if (param) then
			data.pctProfit = tonumber(param)
		end
		BtmFeed.Print(tr("BottomFeeder has set %1 to %2", tr("Percent Profit"), data.pctProfit.."%"))
	elseif (cmd == "mindeprofit") then
		if (param) then
			data.minDeProfit = BtmFeed.ParseGSC(param)
		end
		BtmFeed.Print(tr("BottomFeeder has set %1 to %2", tr("Minimum Disenchant Profit"), BtmFeed.GSC(data.minDeProfit,1)))
	elseif (cmd == "pctdeprofit") then
		if (param) then
			data.pctDeProfit = tonumber(param)
		end
		BtmFeed.Print(tr("BottomFeeder has set %1 to %2", tr("Percent Disenchant Profit"), data.pctDeProfit.."%"))
	elseif (cmd == "vendprofit") then
		if (param) then
			data.vendProfit = BtmFeed.ParseGSC(param)
		end
		BtmFeed.Print(tr("BottomFeeder has set %1 to %2", tr("Vendor Profit"), BtmFeed.GSC(data.vendProfit)))
	elseif (cmd == "reserve") then
		if (param) then
			data.reserve = BtmFeed.ParseGSC(param)
		end
		BtmFeed.Print(tr("BottomFeeder has set %1 to %2", tr("Reserve"), BtmFeed.GSC(data.reserve,1)))
	elseif (cmd == "defactor") then
		if (param) then
			data.deFactor = tonumber(param)
		end
		BtmFeed.Print(tr("BottomFeeder has set %1 to %2", tr("Disenchant Factor"), data.deFactor))
	elseif (cmd == "commonmult") then
		if (param) then
			data.commonMult = tonumber(param)
		end
		BtmFeed.Print(tr("BottomFeeder has set %1 to %2", tr("Common Item Multiplier"), data.commonMult))
	elseif (cmd == "allowbids") then
		if (param) then
			data.allowBids = tonumber(param)
		end
		local allowing = tr("Not Allowed")
		if (data.allowBids > 0) then
			allowing = tr("Allowed")
		end
		BtmFeed.Print(tr("BottomFeeder has set %1 to %2", tr("Item Bidding"), allowing))
	elseif (cmd == "safetynet") then
		local i,j, scount, scost = string.find(oparam, "^(%d+) (%d+)")
		if (i) then
			scount = tonumber(scount)
			scost = BtmFeed.ParseGSC(scost)
			if (scount < 0) then scount = 0 end
			if (scost < 0) then scost = 0 end
			data.safetyCount = scount
			data.safetyCost = scost
		end
		scount = data.safetyCount
		scost = data.safetyCost
		if (scount == 0) then scount = "unlimited" end
		if (scost == 0) then scost = "unlimited" else scost = BtmFeed.GSC(scost) end
		BtmFeed.Print(tr("BottomFeeder has set %1 to %2", tr("Safety Net"), tr("%1 items, %2 total spend", scount, scost)))
	elseif (cmd == "minseen") then
		if (param) then
			data.minSeen = tonumber(param)
		end
		BtmFeed.Print(tr("BottomFeeder has set %1 to %2", tr("Minimum Seen Count"), data.minSeen))
	elseif (cmd == "end" or cmd == "stop" or cmd == "cancel") then
		BtmFeed.EndScan()
	elseif (cmd == "begin" or cmd == "start" or cmd == "scan") then
		BtmFeed.dryRun = false
		BtmFeed.BeginScan()
	elseif (cmd == "dryrun") then
		BtmFeed.dryRun = true
		BtmFeed.BeginScan()
	elseif (cmd == "baserule") then
		if (oparam) then
			data.baseRule = oparam
			BtmFeed.CompileBaseRule()
		else
			BtmFeed.EditData("baseRule", BtmFeed.CompileBaseRule)
		end
	elseif (cmd == "ignore") then
		if (oparam) then
			local des = BtmFeed.ItemDes(oparam)
			data.ignore[des] = true
			BtmFeed.Print(tr("BottomFeeder will now %1 %2", tr("ignore"), oparam))
		else
			BtmFeed.Print(tr("Your current %1 list is:", tr("ignore")))
			if (data.ignore and next(data.ignore)) then
				for des, ignored in pairs(data.ignore) do
					local itemID, itemRand = BtmFeed.BreakItemDes(des)
					local itemString = "item:"..itemID..":0:"..itemRand..":0"
					local itemLink = BtmFeed.FakeLink(itemString)
					BtmFeed.Print(tr("  * %1", itemLink))
				end
			else
				BtmFeed.Print(tr("  -- Empty --"))
			end
		end
	elseif (cmd == "unignore") then
		if (oparam) then
			local des = BtmFeed.ItemDes(oparam)
			data.ignore[des] = nil
			BtmFeed.Print(tr("BottomFeeder will now %1 %2", tr("not ignore"), oparam))
		end
	elseif (cmd == "worth") then
		if (oparam) then
			local des, count, price, itemid,itemrand,itemlink, remain = BtmFeed.ItemDes(oparam)
			if (not des) then
				BtmFeed.Print(tr("Unable to understand command. Please see /btm help"))
				return
			end

			if (price <= 0) then
				price = BtmFeed.ParseGSC(remain) or 0
			end

			if (price <= 0) then
				BtmFeed.Print(tr("BottomFeeder will now %1 %2", tr("not value"), itemlink))
				data.worth[des] = nil
				return
			end

			local _,_,_,_,_,_,stack = GetItemInfo(itemid)
			if (not stack) then
				stack = 1
			end

			local stackText = ""
			if (stack > 1) then
				stackText = " ("..tr("%1 per %2 stack", BtmFeed.GSC(price*stack, 1), stack)..")"
			end

			data.worth[des] = price
			BtmFeed.Print(tr("BottomFeeder will now %1 %2", tr("value"), tr("%1 at %2", itemlink, tr("%1 per unit", BtmFeed.GSC(price, 1)))..stackText))
		else
			BtmFeed.Print(tr("Your current %1 list is:", tr("worth")))
			if (data.worth and data.worth ~= {}) then
				for des, amount in pairs(data.worth) do
					local itemID, itemRand = BtmFeed.BreakItemDes(des)
					local itemString = "item:"..itemID..":0:"..itemRand..":0"
					local itemLink = BtmFeed.FakeLink(itemString)

					local worthLine = ""
					amount = tonumber(amount) or 0

					worthLine = worthLine..tr("%1 per unit", BtmFeed.GSC(amount,1))
					local _,_,_,_,_,_,stack = GetItemInfo(itemID)
					stack = tonumber(stack) or 1;
					if (stack > 1) then
						worthLine = worthLine.." ("..tr("%1 per %2 stack", BtmFeed.GSC(amount*stack,1), stack)..")"
					end
					BtmFeed.Print(tr("  * %1 = %2", itemLink, worthLine))
				end
			else
				BtmFeed.Print(tr("  -- Empty --"))
			end
		end
	elseif (cmd == "snatch") then
		if (oparam) then
			local des, count, price, itemid,itemrand,itemlink, remain = BtmFeed.ItemDes(oparam)
			if (not des) then
				BtmFeed.Print(tr("Unable to understand command. Please see /btm help"))
				return
			end

			if (price <= 0) then
				price = BtmFeed.ParseGSC(remain) or 0
			end

			if (price <= 0) then
				BtmFeed.Print(tr("BottomFeeder will now %1 %2", tr("not snatch"), itemlink))
				data.snatched[des] = nil
				data.snatch[des] = nil
				return
			end

			local _,_,_,_,_,_,stack = GetItemInfo(itemid)
			if (not stack) then
				stack = 1
			end

			local stackText = ""
			if (stack > 1) then
				stackText = " ("..tr("%1 per %2 stack", BtmFeed.GSC(price*stack, 1), stack)..")"
			end
			local countText =""
			if (count > 0) then
				countText = tr("up to %1", count).." "
			else
				countText = tr("unlimited").." "
			end

			data.snatch[des] = { price, count, stack }
			data.snatched[des] = 0
			BtmFeed.Print(tr("BottomFeeder will now %1 %2", tr("snatch"), countText..tr("%1 at %2", itemlink, tr("%1 per unit", BtmFeed.GSC(price, 1)))..stackText))
		else
			BtmFeed.Print(tr("Your current %1 list is:", tr("snatch")))
			if (data.snatch and data.snatch ~= {}) then
				for des, amount in pairs(data.snatch) do
					local itemID, itemRand = BtmFeed.BreakItemDes(des)
					local itemString = "item:"..itemID..":0:"..itemRand..":0"
					local itemLink = BtmFeed.FakeLink(itemString)

					local price, count, stack
					local snatchLine = ""
					if (type(amount) ~= "table") then
						price = tonumber(amount) or 0
						count = 0
						stack = 0
					else
						price = tonumber(amount[1]) or 0
						count = tonumber(amount[2]) or 0
						stack = tonumber(amount[3]) or 0
					end

					if (count > 0) then
						local fulfilled = tonumber(data.snatched[des]) or 0
						snatchLine = snatchLine..tr("%1 / %2 at", fulfilled, count).." "
					end
					snatchLine = snatchLine..tr("%1 per unit", BtmFeed.GSC(price,1))
					if (stack > 1) then
						snatchLine = snatchLine.." ("..tr("%1 per %2 stack", BtmFeed.GSC(price*stack,1), stack)..")"
					end
					BtmFeed.Print(tr("  * %1 = %2", itemLink, snatchLine))
				end
			else
				BtmFeed.Print(tr("  -- Empty --"))
			end
		end
	elseif (cmd == "print-in") then
		BtmFeed.setFrame(oparam)
	elseif (cmd == "clear") then
		data.logText = { { time(), "--- Welcome to BottomFeeder ---" } }
		if (BtmFeed.LogFrame) then BtmFeed.LogFrame.Update() end
	elseif (cmd == "help" or cmd == "") then
		help = true
	else
		BtmFeed.Print(tr("BottomFeeder: %1 [%2]", tr("Unknown command"), cmd))
		help = true
	end

	if (help) then
		BtmFeed.Print(tr("BottomFeeder is using %1 configuration", dataZone))
		BtmFeed.Print(tr(" %1 [%2] = %3", "reserve <copper>", tr("Reserves a certain amount of your money from being spent"), BtmFeed.GSC(data.reserve,1)))
		BtmFeed.Print(tr(" %1 [%2] = %3", "maxprice <copper>", tr("Sets the maximum price that we will buy auctions for"), BtmFeed.GSC(data.maxPrice,1)))
		BtmFeed.Print(tr(" %1 [%2] = %3", "minprofit <copper>", tr("Sets the minimum profit that we consider an auction"), BtmFeed.GSC(data.minProfit,1)))
		BtmFeed.Print(tr(" %1 [%2] = %3", "pctprofit <percent>", tr("Sets the minimum percentage of profit to buy an auction"), data.pctProfit.."%"))
		BtmFeed.Print(tr(" %1 [%2] = %3", "mindeprofit <copper>", tr("Sets the minimum disenchant profit that we consider an auction"), BtmFeed.GSC(data.minDeProfit,1)))
		BtmFeed.Print(tr(" %1 [%2] = %3", "pctdeprofit <percent>", tr("Sets the minimum percentage of disenchant profit to buy an auction"), data.pctDeProfit.."%"))
		BtmFeed.Print(tr(" %1 [%2] = %3", "vendprofit <copper>", tr("Sets the minimum profit on vendorable items"), data.vendProfit))
		BtmFeed.Print(tr(" %1 [%2] = %3", "commonmult <factor>", tr("Sets a penalty factor on white items' profitability"), data.commonMult))
		local allowing = tr("Not Allowed") if (data.allowBids > 0) then allowing = tr("Allowed") end
		BtmFeed.Print(tr(" %1 [%2] = %3", "allowbids <0/1>", tr("Sets whether to allow bidding if the rules would have bought at that price"), allowing))
		BtmFeed.Print(tr(" %1 [%2] = %3", "minseen <count>", tr("Sets the minimum Auctioneer \"seen count\" before we will buy an item"), data.minSeen))

		local scount, scost
		scount = data.safetyCount
		scost = data.safetyCost
		if (scount == 0) then scount = "unlimited" end
		if (scost == 0) then scost = "unlimited" else scost = BtmFeed.GSC(scost) end
		BtmFeed.Print(tr(" %1 [%2] = %3", "safetynet <count> <copper>", tr("Sets the maximum number / cost of any single item that will be bought in any one session (0 for unlimited)"), tr("%1 items, %2 total spend", scount, scost)))

		BtmFeed.Print(tr(" %1 [%2]", "print-in (<frameIndex>[Number]|<frameName>[String])", tr("Sets the chatFrame that BottomFeeder's messages will be printed to")))
		BtmFeed.Print(tr(" %1 [%2]", "baserule <lua>", tr("Advanced users only: Specify your own lua code for calculating the base price")))

		BtmFeed.Print(tr(" %1 [%2]", "ignore <item>", tr("Ignores the specified item")))
		BtmFeed.Print(tr(" %1 [%2]", "unignore <item>", tr("Stops ignoring the specified item")))
		BtmFeed.Print(tr(" %1 [%2]", "snatch <item> <copper> <count>", tr("Sets the item's snatch value")))
		BtmFeed.Print(tr(" %1 [%2]", "worth <item> <copper>", tr("Sets the specified item's value")))
		BtmFeed.Print(tr(" %1 [%2]", "clear", tr("Clears the AH event log window")))
		BtmFeed.Print(tr(" %1 [%2]", "dryrun", tr("Begins a test scanning run (must have AH open)")))
		BtmFeed.Print(tr(" %1 [%2]", "begin", tr("Begins the scanning process (must have AH open)")))
		BtmFeed.Print(tr(" %1 [%2]", "end", tr("Ends the scanning process")))
	end
end

BtmFeed.BeginScan = function ()
	BtmFeed.Log(tr("BottomFeeder is now scanning"))
	BtmFeed.scanning = true
	BtmFeed.interval = 1
end
BtmFeed.EndScan = function ()
	BtmFeed.Log(tr("BottomFeeder is stopping scanning"))
	BtmFeed.scanning = false
end

BtmFeed.AddAuctPriceModel = function (itemID, itemRand, itemEnch, itemName, count)
	local sanityKey = itemID..":"..itemRand
	local sanity = BtmFeed.ConfidenceList[sanityKey]
	local iqm, iqwm
	if (sanity) then
		local prices = BtmFeed.Split(sanity, ",")
		iqm = tonumber(prices[1])
		iqwm = tonumber(prices[2])
		if (count and count > 1) then
			iqm = iqm * count
			iqwm = iqwm * count
		end
 		return {
			text = "BottomFeeder",
			note = "",
			bid = iqwm,
			buyout = iqm
		}
	end
	return nil
end

BtmFeed.CompileBaseRule = function()
	if not data or not data.baseRule or data.baseRule == "default" then
		BtmFeed.BaseRule = nil
		return
	end

	local script = -- Block script below:
[[
local consKey     = BtmFeed.prices.consKey
local consMean    = BtmFeed.prices.consMean
local consPrice   = BtmFeed.prices.consPrice
local consSeen    = BtmFeed.prices.consSeen
local auctKey     = BtmFeed.prices.auctKey
local auctPrice   = BtmFeed.prices.auctPrice
local auctSeen    = BtmFeed.prices.auctSeen
local itemID      = BtmFeed.prices.itemID
local itemRand    = BtmFeed.prices.itemRand
local itemEnch    = BtmFeed.prices.itemEnch
local itemCount   = BtmFeed.prices.itemCount
local bidPrice    = BtmFeed.prices.bidPrice
local buyPrice    = BtmFeed.prices.buyPrice
local basePrice   = BtmFeed.prices.basePrice
local depositCost = BtmFeed.prices.depositCost
local depositRate = BtmFeed.depositRate
local cutRate     = BtmFeed.cutRate
local auctionFee  = 0
]]..data.baseRule..[[

BtmFeed.prices.depositCost = depositCost
BtmFeed.prices.auctionFee = auctionFee
return basePrice
]]
	-- End of block script --

	local scriptFunc = loadstring(script)
	if (not scriptFunc) then
		BtmFeed.Print("Error compiling BottomFeeder BaseRule script")
		BtmFeed.BaseRule = nil
		return
	end
	BtmFeed.Print(tr("BottomFeeder has set %1 to %2", tr("Base Rule"), tr("the provided value")))
	BtmFeed.BaseRule = scriptFunc
end

BtmFeed.GetDepositCost = function (itemID, count)
	local vendorValue = BtmFeed.GetVendorPrice(itemID, count)
	if (not vendorValue) then return 0 end
	if (count and count > 1) then vendorValue = vendorValue * count end
	local baseDeposit = math.floor(vendorValue * BtmFeed.depositRate) -- 2 hr auction
	return baseDeposit * 12 -- 24 hour auction
end

BtmFeed.GetVendorPrice = function(itemID, count)
	local vendorValue = BtmFeed.VendorPrices[itemID]
	if (not vendorValue and Informant and Informant.GetItem) then
		local itemInfo = Informant.GetItem(itemID)
		if (itemInfo and itemInfo.sell) then
			vendorValue = tonumber(itemInfo.sell) or 0
		end
	end
	if not vendorValue then return end
	if (count and count > 1) then vendorValue = vendorValue * count end
	return vendorValue
end

BtmFeed.ConfigZone = function (whence)
	local realmName = GetRealmName()
	local currentZone = GetMinimapZoneText()
	local factionGroup
	
	if (not BtmFeedData.factions) then
		BtmFeed.Print(tr("BottomFeeder: %1", tr("Zone data uninitialized: %1", whence)))
		return
	end
	if (BtmFeedData.factions[currentZone]) then
		factionGroup = BtmFeedData.factions[currentZone]
	else
		SetMapToCurrentZone()
		local map = GetMapInfo()
		if ((map == "Taneris") or (map == "Winterspring") or (map == "Stranglethorn")) then
			factionGroup = "Neutral"
		end
		BtmFeedData.factions[currentZone] = factionGroup
	end

	if not factionGroup then factionGroup = UnitFactionGroup("player") end
	if not factionGroup then return end
	if (factionGroup == "Neutral") then
		BtmFeed.cutRate = 0.15
		BtmFeed.depositRate = 0.25
	else
		BtmFeed.cutRate = 0.05
		BtmFeed.depositRate = 0.05
	end
		
	return realmName.."-"..factionGroup
end

-- Gets the configdata for the current zone
BtmFeed.GetZoneConfig = function (whence)
	local newZone = BtmFeed.ConfigZone(whence.."getzone")
	if not newZone then
		BtmFeed.Print(tr("BottomFeeder: %1", tr("Unable to get config zone: %1", whence)))
		dataZone = ""
		data = {}
	elseif (newZone ~= dataZone) then
		BtmFeed.Print(tr("BottomFeeder: %1", tr("Switching to %1 config zone", newZone)))
		dataZone = newZone
		if (not BtmFeedData.config[dataZone]) then BtmFeedData.config[dataZone] = {} end
		data = BtmFeedData.config[dataZone]

		if (not BtmFeedData.version or BtmFeedData.version < 115) then
			for i,j in pairs(BtmFeedData) do
				-- Copy realm specific data to realm element
				if (i ~= "config" and i ~= "unlocked" and
				    i ~= "refresh" and i ~= "factions" and
				    i ~= "printFrame" and i ~= "version" and
				    not data[i]) then
					data[i] = j
					BtmFeedData[i] = nil
				end
			end
			BtmFeedData.version = 115
		end
	else
		return
	end

	-- Check config data
	if (not data.maxPrice) then data.maxPrice = 25000 end -- 2g50 max buyout
	if (not data.minProfit) then data.minProfit = 3000 end -- 30s min profit
	if (not data.pctProfit) then data.pctProfit = 30 end -- 30% min profit
	if (not data.minDeProfit) then data.minDeProfit = 4500 end -- 4g50
	if (not data.pctDeProfit) then data.pctDeProfit = 45 end -- 45%
	if (not data.reserve) then data.reserve = 20000 end -- 2gReserve
	if (not data.deFactor) then data.deFactor = 1.5 end -- 150%
	if (not data.minSeen) then data.minSeen = 3 end -- 150%
	if (not data.vendProfit) then data.vendProfit = 20 end -- 20c min vendor profit
	if (not data.commonMult) then data.commonMult = 1.5 end -- common multiplier
	if (not data.allowBids) then data.allowBids = 0 end -- to allow or not allow
	if (not data.ignore) then data.ignore = {} end -- ignore nothing
	if (not data.snatch) then data.snatch = {} end -- snatch list
	if (not data.snatched) then data.snatched = {} end -- snatched list
	if (not data.worth) then data.worth = {} end -- fixed price list
	if (not data.bids) then data.bids = {} end -- latest bids and reasons
	if (not data.safetyCount) then data.safetyCount = 6 end -- safetynet count
	if (not data.safetyCost) then
		data.safetyCost = data.safetyCount * data.maxPrice / 2
	end -- safetynet cost
	BtmFeed.CompileBaseRule()
end


BtmFeed.TooltipHook = function (funcVars, retVal, frame, name, link, quality, count)
	-- Make sure the current zone is loaded and has defaults
	BtmFeed.GetZoneConfig("tooltip")

	local ltype = EnhTooltip.LinkType(link)
	if ltype == "item" then
		local itemID, itemRand, itemEnch, itemUniq = BtmFeed.BreakLink(link)
		local sanityKey = itemID..":"..itemRand
		local auctKey = itemID..":"..itemRand..":"..itemEnch

		local sanity = BtmFeed.ConfidenceList[sanityKey]
		local iqm, iqwm, iqCount
		if (sanity) then
			local prices = BtmFeed.Split(sanity, ",")
			iqm = tonumber(prices[1])
			iqwm = tonumber(prices[2])
			iqCount = tonumber(prices[3])
			if (count and count > 1) then
				iqm = iqm * count
				iqwm = iqwm * count
			end

			EnhTooltip.AddLine(tr("BottomFeeder prices"))
			EnhTooltip.LineColor(0.9,0.6,0.2)
			EnhTooltip.AddLine("  "..tr("IQR Mean"), iqm)
			EnhTooltip.LineColor(0.9,0.6,0.2)
			EnhTooltip.AddLine("  "..tr("Conservative"), iqwm)
			EnhTooltip.LineColor(0.9,0.6,0.2)

			local baseIs = "Conservative"
			local basePrice = iqwm
			local auctMedian, auctCount
			if (Auctioneer and Auctioneer.Statistic) then
				auctMedian, auctCount = Auctioneer.Statistic.GetUsableMedian(auctKey)
				if (auctMedian and auctCount) then
					if (auctMedian > basePrice) then
						basePrice = auctMedian
						baseIs = "Auctioneer"
					end
				end
			end
			if (not auctMedian) then auctMedian = 0 end
			if (not auctCount) then auctCount = 0 end

			if (not count or count < 1) then count = 1 end
			local deposit = BtmFeed.GetDepositCost(itemID, count)
			if (not deposit) then deposit = 0 end
			if (BtmFeed.BaseRule) then
				BtmFeed.prices = {
					consKey = sanityKey,
					consMean = iqm * count,
					consPrice = iqwm * count,
					consSeen = iqCount,
					auctKey = auctKey,
					auctPrice = auctMedian * count,
					auctSeen = auctCount,
					itemID = itemID,
					itemRand = itemRand,
					itemEnch = itemEnch,
					itemCount = count,
					bidPrice = 0,
					buyPrice = 0,
					basePrice = basePrice * count,
					depositCost = deposit
				}
				local newBase = BtmFeed.BaseRule()
				if (not newBase or newBase <= 0) then
					basePrice = 0
				elseif (newBase ~= basePrice) then
					basePrice = newBase
					baseIs = "Custom"
				end
			else
				basePrice = basePrice * count
			end

			if (data.worth[sanityKey]) then
				basePrice = tonumber(data.worth[sanityKey]) or 0
				baseIs = "Fixed Worth"
			end

			if (not basePrice or basePrice <= 0) then
				basePrice = 0
				baseIs = "Don't Buy"
			end
	
			local auctionFee
			if (BtmFeed.prices) then
				auctionFee = BtmFeed.prices.auctionFee
			end
			if (not auctionFee or auctionFee <= 0) then
				auctionFee = basePrice * 0.05
			end

			if (BtmFeed.prices and BtmFeed.prices.depositCost and BtmFeed.prices.depositCost > 0) then
				deposit = BtmFeed.prices.depositCost
			end

			EnhTooltip.AddLine("  "..tr("Valuation (%1)", tr(baseIs)), basePrice)
			EnhTooltip.LineColor(0.9,0.9,0.2)
			if (basePrice > 0) then
				EnhTooltip.AddLine("    ("..tr("Auction Fee")..")", auctionFee)
				EnhTooltip.LineColor(0.9,0.8,0.4)
				EnhTooltip.AddLine("    ("..tr("Deposit Cost")..")", deposit)
				EnhTooltip.LineColor(0.9,0.8,0.4)
			end

			if (data.snatch[sanityKey]) then
				local sdata = data.snatch[sanityKey]
				local price, count, stack
				local snatchLine = ""
				if (type(sdata) ~= "table") then
					price = tonumber(amount) or 0
					count = 0
					stack = 0
				else
					price = tonumber(sdata[1]) or 0
					count = tonumber(sdata[2]) or 0
					stack = tonumber(sdata[3]) or 0
				end
				if (count == 0) then
					EnhTooltip.AddLine("  "..tr("Snatch it at"), price)
				else
					local fulfilled = tonumber(data.snatched[sanityKey]) or 0
					EnhTooltip.AddLine("  "..tr("Snatch %1 (%2 done)", count, fulfilled), price)
				end
				EnhTooltip.LineColor(0.9,0.9,0.2)
				if (stack > 1) then
					EnhTooltip.AddLine("    "..tr("(or per %1 stack)", stack), price * stack)
					EnhTooltip.LineColor(0.9,0.9,0.2)
				end
			end

			if (BtmFeed.sessionSpend and BtmFeed.sessionSpend[sanityKey]) then
				local sspend = BtmFeed.sessionSpend[sanityKey]
				EnhTooltip.AddLine("  "..tr("SafetyNet: %1 bought",  sspend.count), tonumber(sspend.cost) or 0)
				EnhTooltip.LineColor(0.9,0.6,0.2)
			end

			local bidSig = link.."x"..count
			if (data.bids and data.bids[bidSig]) then
				local whyBuy = data.bids[bidSig][1]
				local howMuch = data.bids[bidSig][2]
				local bidType = data.bids[bidSig][3] or tr("bought")
				local tStamp = data.bids[bidSig][4]
				local ago = ""
				if (tStamp) then
					local elapsed = time() - tStamp
					ago = tr(" (%1 ago)", SecondsToTime(elapsed))
				end
				EnhTooltip.AddLine("  "..tr("Last %1 for %2%3",  bidType, whyBuy, ago), tonumber(howMuch) or 0)
				EnhTooltip.LineColor(0.2,0.4,0.9)
			end
		end
	end
end

BtmFeed.DoTooltip = function ()
	if (not this.lineID) then return end

	local i = this.lineID
	local line = BtmFeed.LogFrame.Lines[i]:GetText()

	local itemID, itemRand, itemEnch, itemUniq, itemName, wholeLink, count, cost = BtmFeed.BreakLink(line)
	if (itemID and itemID > 0) then
		--GameTooltip:SetOwner(BtmFeed.LogFrame, "ANCHOR_NONE")
		GameTooltip:SetOwner(AuctionFrameCloseButton, "ANCHOR_NONE")
		GameTooltip:SetHyperlink("item:"..itemID..":"..itemEnch..":"..itemRand..":"..itemUniq)
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("TOPLEFT", "AuctionFrame", "TOPRIGHT", 10, -20)
		if (EnhTooltip) then
			EnhTooltip.TooltipCall(GameTooltip, itemName, wholeLink, -1, count, cost)
		end
	end
end
BtmFeed.UndoTooltip = function ()
	GameTooltip:Hide()
end

BtmFeed.InputData = {
	dataField = nil,
	callBack = nil
}
BtmFeed.InputShow = function ()
	if (BtmFeed.InputData.dataField) then
		BtmFeed.Input.Box:SetText(data[BtmFeed.InputData.dataField] or "")
	else
		BtmFeed.Input.Box:SetText("")
	end
end
BtmFeed.InputDone = function ()
	if (BtmFeed.InputData.dataField) then
		data[BtmFeed.InputData.dataField] = BtmFeed.Input.Box:GetText()
	end
	if (BtmFeed.InputData.callBack) then
		BtmFeed.InputData.callBack(BtmFeed.Input.Box:GetText())
	end
	BtmFeed.Input:Hide()
end
BtmFeed.EditData = function (dataField, callBack)
	BtmFeed.InputData.dataField = dataField
	BtmFeed.InputData.callBack = callBack
	BtmFeed.Input:Show()
end
BtmFeed.InputUpdate = function()
	BtmFeed.Input.Scroll:UpdateScrollChildRect()
--	local bar = getglobal(this:GetParent():GetName().."ScrollBar")
--	local min, max
--	min, max = bar:GetMinMaxValues()
--	if (max > 0 and this.max ~= max) then
--		this.max = max
--		bar:SetValue(max)
--	end
end

BtmFeed.Frame = CreateFrame("Frame")
BtmFeed.Frame:RegisterEvent("ADDON_LOADED")
BtmFeed.Frame:SetScript("OnEvent", BtmFeed.OnEvent)
BtmFeed.Frame:SetScript("OnUpdate", BtmFeed.OnUpdate)

BtmFeed.Input = CreateFrame("Frame", "", UIParent)
BtmFeed.Input:Hide()
BtmFeed.Input:SetPoint("CENTER", "UIParent", "CENTER")
BtmFeed.Input:SetFrameStrata("DIALOG")
BtmFeed.Input:SetHeight(280)
BtmFeed.Input:SetWidth(500)
BtmFeed.Input:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 9, right = 9, top = 9, bottom = 9 }
})
BtmFeed.Input:SetBackdropColor(0,0,0, 0.8)
BtmFeed.Input:SetScript("OnShow", BtmFeed.InputShow)

BtmFeed.Input.Done = CreateFrame("Button", "", BtmFeed.Input, "OptionsButtonTemplate")
BtmFeed.Input.Done:SetText(tr("Done"))
BtmFeed.Input.Done:SetPoint("BOTTOMRIGHT", BtmFeed.Input, "BOTTOMRIGHT", -10, 10)
BtmFeed.Input.Done:SetScript("OnClick", BtmFeed.InputDone)

BtmFeed.Input.Scroll = CreateFrame("ScrollFrame", "BtmFeedInputScroll", BtmFeed.Input, "UIPanelScrollFrameTemplate")
BtmFeed.Input.Scroll:SetPoint("TOPLEFT", BtmFeed.Input, "TOPLEFT", 20, -20)
BtmFeed.Input.Scroll:SetPoint("RIGHT", BtmFeed.Input, "RIGHT", -30, 0)
BtmFeed.Input.Scroll:SetPoint("BOTTOM", BtmFeed.Input.Done, "TOP", 0, 10)

BtmFeed.Input.Box = CreateFrame("EditBox", "BtmFeedEditBox", BtmFeed.Input.Scroll)
BtmFeed.Input.Box:SetWidth(460)
BtmFeed.Input.Box:SetHeight(85)
BtmFeed.Input.Box:SetMultiLine(true)
BtmFeed.Input.Box:SetAutoFocus(true)
BtmFeed.Input.Box:SetFontObject(GameFontHighlight)
BtmFeed.Input.Box:SetScript("OnEscapePressed", BtmFeed.InputDone)
BtmFeed.Input.Box:SetScript("OnTextChanged", BtmFeed.InputUpdate)

BtmFeed.Input.Scroll:SetScrollChild(BtmFeed.Input.Box)

BtmFeed.CreateLogWindow = function()
	if (BtmFeed.LogFrame) then return end
	if (not AuctionFrame) then return end

	-- Make sure the current zone is loaded and has defaults
	BtmFeed.GetZoneConfig("createlog")

	BtmFeed.LogParent = CreateFrame("Frame", "", AuctionFrame)
	BtmFeed.LogParent:SetPoint("TOPLEFT", "AuctionFrame", "BOTTOMLEFT", 15, 30)
	BtmFeed.LogParent:SetPoint("TOPRIGHT", "AuctionFrame", "BOTTOMRIGHT", -10, 30)
	BtmFeed.LogParent:SetFrameStrata("BACKGROUND")
	BtmFeed.LogParent:SetHeight(150)
	BtmFeed.LogParent:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 9, right = 9, top = 9, bottom = 9
	}})
	BtmFeed.LogParent:SetBackdropColor(0,0,0, 0.8)
	BtmFeed.LogParent:Show()

	BtmFeed.LogFrame = CreateFrame("ScrollFrame", "BtmFeedLogFrame", BtmFeed.LogParent, "FauxScrollFrameTemplate")
	BtmFeed.LogFrame:SetPoint("TOPLEFT", BtmFeed.LogParent, "TOPLEFT", 10, -50)
	BtmFeed.LogFrame:SetPoint("BOTTOMRIGHT", BtmFeed.LogParent, "BOTTOMRIGHT", -35, 10)

	BtmFeed.LogFrame.LineFrames = {}
	BtmFeed.LogFrame.Dates = {}
	BtmFeed.LogFrame.Lines = {}
	for i=1, 8 do
		BtmFeed.LogFrame.LineFrames[i] = CreateFrame("Frame", "BtmFeedLogFrame"..i, BtmFeed.LogFrame)
		if (i == 1) then
			BtmFeed.LogFrame.LineFrames[i]:SetPoint("TOPLEFT", BtmFeed.LogFrame, "TOPLEFT", 5, -2)
			BtmFeed.LogFrame.LineFrames[i]:SetPoint("RIGHT", BtmFeed.LogFrame, "RIGHT", -10, 0)

		else
			BtmFeed.LogFrame.LineFrames[i]:SetPoint("TOPLEFT", BtmFeed.LogFrame.LineFrames[i-1], "BOTTOMLEFT")
			BtmFeed.LogFrame.LineFrames[i]:SetPoint("RIGHT", BtmFeed.LogFrame.LineFrames[i-1], "RIGHT")
		end
		BtmFeed.LogFrame.LineFrames[i]:SetHeight(10)
		BtmFeed.LogFrame.LineFrames[i].lineID = i
		BtmFeed.LogFrame.LineFrames[i]:EnableMouse(true)
		BtmFeed.LogFrame.LineFrames[i]:SetScript("OnEnter", BtmFeed.DoTooltip)
		BtmFeed.LogFrame.LineFrames[i]:SetScript("OnLeave", BtmFeed.UndoTooltip)

		BtmFeed.LogFrame.Dates[i] = BtmFeed.LogFrame.LineFrames[i]:CreateFontString("BtmFeedLogDate"..i, "HIGH")
		BtmFeed.LogFrame.Dates[i]:SetPoint("TOPLEFT", BtmFeed.LogFrame.LineFrames[i], "TOPLEFT")
		BtmFeed.LogFrame.Dates[i]:SetWidth(150)
		BtmFeed.LogFrame.Dates[i]:SetFont("Fonts\\FRIZQT__.TTF",11)
		BtmFeed.LogFrame.Dates[i]:SetJustifyH("LEFT")
		BtmFeed.LogFrame.Dates[i]:SetText("Date"..i)
		BtmFeed.LogFrame.Dates[i]:Show()

		BtmFeed.LogFrame.Lines[i] = BtmFeed.LogFrame.LineFrames[i]:CreateFontString("BtmFeedLogLine"..i, "HIGH")
		BtmFeed.LogFrame.Lines[i]:SetFont("Fonts\\FRIZQT__.TTF",11)
		BtmFeed.LogFrame.Lines[i]:SetPoint("TOPLEFT", BtmFeed.LogFrame.Dates[i], "TOPRIGHT", 5, 0)
		BtmFeed.LogFrame.Lines[i]:SetPoint("RIGHT", BtmFeed.LogFrame.LineFrames[i], "RIGHT")
		BtmFeed.LogFrame.Lines[i]:SetJustifyH("LEFT")
		BtmFeed.LogFrame.Lines[i]:SetText("Text"..i)
		BtmFeed.LogFrame.Lines[i]:Show()
	end

	BtmFeed.LogFrame.Update = function()
		if (not data.logText) then
			data.logText = { { time(), "--- Welcome to BottomFeeder ---" } }
		end
		local rows = table.getn(data.logText)
		local scrollrows = rows
		if (scrollrows > 0 and scrollrows < 9) then scrollrows = 9 end
		FauxScrollFrame_Update(BtmFeed.LogFrame, scrollrows, 8, 16)
		local line
		for i=1, 8 do
			line = rows - (FauxScrollFrame_GetOffset(BtmFeedLogFrame) + i) + 1
			if (rows > 0 and line <= rows and line > 0) then
				BtmFeed.LogFrame.Dates[i]:SetText("["..date("%Y-%m-%d %H:%M:%S", data.logText[line][1]).."]")
				BtmFeed.LogFrame.Lines[i]:SetText(data.logText[line][2])
			else
				BtmFeed.LogFrame.Dates[i]:SetText("")
				BtmFeed.LogFrame.Lines[i]:SetText("")
			end
		end
	end
	BtmFeed.LogFrame:SetScript("OnVerticalScroll", function ()
		FauxScrollFrame_OnVerticalScroll(16, BtmFeed.LogFrame.Update)
	end)
	BtmFeed.LogFrame:SetScript("OnShow", function()
		BtmFeed.LogFrame.Update()
	end)

	BtmFeed.LogFrame:Show()
end

