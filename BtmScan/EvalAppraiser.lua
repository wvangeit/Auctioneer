--[[
	BottomScanner - An AddOn for WoW to alert you to good purchases as they appear on the AH
	Version: 5.0.PRE.2319 (Kinesia)
	Revision: $Id: EvalAppraiser.lua 2193 2007-10-26 06:10:48Z Kinesia $
	URL: http://auctioneeraddon.com/dl/BottomScanner/
	Copyright (c) 2006, Norganna

	This is a module for BtmScan to evaluate an item for purchase.

	If you wish to make your own module, do the following:
	 -  Make a copy of the supplied "EvalTemplate.lua" file.
	 -  Rename your copy to a name of your choosing.
	 -  Edit your copy to do your own valuations of the item.
	      (search for the "TODO" sections in the file)
	 -  Insert your new file's name into the "BtmScan.toc" file.
	 -  Optionally, put it up on the wiki at:
	      http://norganna.org/wiki/BottomScanner/Evaluators

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
]]

-- If auctioneer is not loaded, then we cannot run.
if not (AucAdvanced or (Auctioneer and Auctioneer.Statistic)) then return end

local libName = "Appraiser"
local lcName = libName:lower()
local lib = { name = lcName, propername = libName }
table.insert(BtmScan.evaluators, lcName)
local define = BtmScan.Settings.SetDefault
local get = BtmScan.Settings.GetSetting
local set = BtmScan.Settings.SetSetting

BtmScan.evaluators[lcName] = lib



function lib.GetAppraiserValue(itemLink, defaultOnly)
	-- itemLink is a link
	-- defaultOnly is whether to only use default prices or not (ie. whether to ignore fixed values, etc)
	
	local itype, id, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(itemLink)
	local sig = tostring(id)
	local link=itemLink
	
	if not sig then 
		return 0, 0, 0, "Unknown" 
	end
	
	local curModel = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..sig..".model") or "default"
	local curModelText = curModel

	-- This is the code to get whether the "Price matching" is turned on or not.
	-- Currently choosing not to use this information as it only applies to current market and BTMscan may not have a current full scan to work with, so it needs to use the historical values	
	-- 		local Match = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..sig..".match") or false


	if curModel == "default" then
		curModel = AucAdvanced.Settings.GetSetting("util.appraiser.model") or "market"
		if ((curModel == "market") and ((not AucAdvanced.API.GetMarketValue(link)) or (AucAdvanced.API.GetMarketValue(link) <= 0))) or
		   ((not (curModel == "fixed")) and (not (curModel == "market")) and ((not AucAdvanced.API.GetAlgorithmValue(curModel, link)) or (AucAdvanced.API.GetAlgorithmValue(curModel, link) <= 0))) then
			curModel = AucAdvanced.Settings.GetSetting("util.appraiser.altModel")
		end
		curModelText = curModelText.."("..curModel..")"
	end

	local defMatch = AucAdvanced.Settings.GetSetting("util.appraiser.match")
	local curMatch = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..sig..".match")
	if curMatch == nil then
		curMatch = defMatch
	end
	local match = (curMatch == "on")
		
	local newBuy, newBid, seen, __, DiffFromModel
	if curModel == "fixed" then
		newBuy = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..sig..".fixed.buy")
		newBid = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..sig..".fixed.bid")
		seen = 99
	elseif curModel == "market" then
		newBuy, seen = AucAdvanced.API.GetMarketValue(link)
	else
		newBuy, seen = AucAdvanced.API.GetAlgorithmValue(curModel, link)
	end
	if match then
		newBuy, _, _, DiffFromModel = AucAdvanced.API.GetBestMatch(link, curModel)
	end

	if curModel ~= "fixed" then
		if newBuy and not newBid then
			local markdown = math.floor(AucAdvanced.Settings.GetSetting("util.appraiser.bid.markdown") or 0)/100
			local subtract = AucAdvanced.Settings.GetSetting("util.appraiser.bid.subtract") or 0
			local deposit = AucAdvanced.Settings.GetSetting("util.appraiser.bid.deposit") or false
			if (deposit) then
				local rate
				deposit, rate = AucAdvanced.Post.GetDepositAmount(sig)
				if not rate then rate = AucAdvanced.depositRate or 0.05 end
			end
			if (not deposit) then deposit = 0 end

			-- Scale up for duration > 12 hours
			-- Assume 24 hours since we can't get this info
			if deposit > 0 then
				deposit = deposit * 2
			end

			markdown = newBuy * markdown

			newBid = math.max(newBuy - markdown - subtract - deposit, 1)
		end

		if newBid and (not newBuy or newBid > newBuy) then
			newBuy = newBid
		end
	end

	-- Ok, market price is the Bid price, not the buyout. This makes it very conservative, but allows you to use your other settings better and is safer for beginners.
	
	return newBid, newBuy, seen, curModelText
end

function lib:valuate(item, tooltip)
	local price = 0
	local curModelText = "Unknown"

	-- If we're not enabled, scadaddle!
	if (not get(lcName..".enable")) then return end

	-- If this item is not good enough, forget about it.
	if (get(lcName..".quality.check")) then
		if (item.qual < get(lcName..".quality.min")) then
			item:info("Abort: Quality < min")
			return
		end
	end

	local market, seen, newBid, newBuy
	-- Valuate this item
	if not AucAdvanced then
		-- Auctioneer Classic
		local useFour = get(lcName..".auct.usefour")
		local useHSP = get(lcName..".auct.usehsp")
		if Auctioneer and Auctioneer.Statistic and Auctioneer.Statistic.GetUsableMedian then
			local _, itemId, enchant, _, _, _, _, property, _ = strsplit(":", item.link)
			local auctKey = strjoin(":",itemId,property,enchant)
			if (AucAdvanced and useFour) or not AucAdvanced then
				if (useHSP) then
					market, seen = Auctioneer.Statistic.GetHSP(auctKey)
					curModelText = "Classic HSP"
				end
				if not market then
					market, seen = Auctioneer.Statistic.GetUsableMedian(auctKey)
					curModelText = "Classic Median"
				end
			end
		end
	elseif (AucAdvanced and not AucAdvanced.Modules.Util.Appraiser) then -- Auctioneer Advanced without Appraiser
		market, seen = AucAdvanced.API.GetMarketValue(item.link)
		curModelText = "Market"
	else -- Auctioneer Advanced with Appraiser
		newBid, newBuy, seen, curModelText = lib.GetAppraiserValue(item.link)
		
		newBid = math.floor((newBid or 0) + 0.5)
		newBuy = math.floor((newBuy or 0) + 0.5)

		item:info("Estimated Bid: "..item.count.." x",newBid)
		item:info("Estimated Buy: "..item.count.." x",newBuy)
		
		market = newBid
	end
	item:info("Pricing Model:"..curModelText)
	
	-- If we don't know what it's worth, then there's not much we can do
	if not market then return end
	market = market * item.count
	item:info("Market price", market)

	-- Check to see if it meets the min seen count (if applicable)
	if (get(lcName..".seen.check")) and  curModel ~= "fixed" then
		if (not seen or seen < get(lcName..".seen.mincount")) then
			item:info("Abort: Seen < "..get(lcName..".seen.mincount"))
			return
		end
	end

	-- Adjust for brokerage / deposit costs
	local adjusted = market
	local deposit = get(lcName..'.adjust.deposit')
	local brokerage = get(lcName..'.adjust.brokerage')

	if (deposit or brokerage) then
		local basis = get(lcName..'.adjust.basis')
		local brokerRate, depositRate = 0.05, 0.05
		if (basis == "neutral") then
			brokerRate, depositRate = 0.15, 0.25
		end
		if (deposit) then
			local relistings = get(lcName..'.adjust.listings')
			local amount = (BtmScan.GetDepositCost(item.id, item.count, depositRate) * relistings)
			adjusted = adjusted - amount
			item:info(" - "..relistings.." x deposit", amount)
		end
		if (brokerage) then
			local amount = (market * brokerRate)
			adjusted = adjusted - amount
			item:info(" - Brokerage", amount)
		end
		if (adjusted<0) then
			item:info(" = Adjusted value below zero")
			return
		else
			item:info(" = Adjusted value: ", adjusted)
		end
	end

	-- Valuate this item
	local pct = get(lcName..".profit.pct")
	local min = get(lcName..".profit.min")
	local value, mkdown = BtmScan.Markdown(adjusted, pct, min)
	item:info((" - %d%% / %s markdown"):format(pct,BtmScan.GSC(min, true)), mkdown)

	-- Check for tooltip evaluation
	if (tooltip) then
		item.what = self.name
		item.valuation = value
		if (item.bid == 0) then
			return
		end
	end

	-- If the current purchase price is more than our valuation,
	-- another module "wins" this purchase.
	if (value < item.purchase) then return end

	-- Check to see what the most we can pay for this item is.
	if (item.canbuy and get(lcName..".allow.buy") and item.buy < value) then
		price = item.buy
	elseif (item.canbid and get(lcName..".allow.bid") and item.bid < value) then
		price = item.bid
	end

	-- Check our projected profit level
	local profit = 0
	if price > 0 then profit = value - price end

	-- If what we are willing to pay for this item beats what
	-- other modules are willing to pay, and we can make more
	-- profit, then we "win".
	if (price >= item.purchase and profit > item.profit) then
		item.purchase = price
		item.reason = self.name
		item.what = self.name
		item.profit = profit
		item.valuation = market
	end
end

local qualityTable = {
	{0, ITEM_QUALITY0_DESC},
	{1, ITEM_QUALITY1_DESC},
	{2, ITEM_QUALITY2_DESC},
	{3, ITEM_QUALITY3_DESC},
	{4, ITEM_QUALITY4_DESC},
	{5, ITEM_QUALITY5_DESC},
	{6, ITEM_QUALITY6_DESC},
}
local ahList = {
	{'faction', "Faction AH Fees"},
	{'neutral', "Neutral AH Fees"},
}

define(lcName..'.enable', true)
define(lcName..'.profit.min', 3000)
define(lcName..'.profit.pct', 50)
define(lcName..'.auct.usehsp', false)
define(lcName..'.quality.check', true)
define(lcName..'.quality.min', 1)
define(lcName..'.adjust.basis', "faction")
define(lcName..'.adjust.brokerage', true)
define(lcName..'.adjust.listings', 1)
define(lcName..'.seen.check', false)
define(lcName..'.seen.mincount', 10)
define(lcName..'.allow.bid', true)
define(lcName..'.allow.buy', true)
function lib:setup(gui)
	local id = gui:AddTab(libName)
	gui:MakeScrollable(id)
	gui:AddHelp(id, "what appraiser evaluator",
		"What is the appraiser evaluator?",
	"If you are using Auctioneer Advanced and Appraiser this Evaluator uses your Appraiser settings to value items."..
	"\nOtherwise it will use the standard pricing schemes that you do have installed."..
	"\nFor most items it will use whatever your default Pricing model is, falling back to your alternate model when the default has no value."..
	"\nIf you have fixed values for some items or another pricing model selected for an item then it will use those instead."..
	"\nIt takes the markdown percentage you have set into account as well and values things at your Bid price."..
    "\nYou can take the item you've bought out of the mailbox and post it in the AuctionHouse using Appraiser without changing any settings."..
    "\nThis should simplify your handling of large numbers of auctions.")
	gui:AddControl(id, "Subhead",          0,    libName.." Settings")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".enable", "Enable purchasing for "..lcName)
	gui:AddControl(id, "Checkbox",         0, 2, lcName..".allow.buy", "Allow buyout on items")
	gui:AddControl(id, "Checkbox",         0, 2, lcName..".allow.bid", "Allow bid on items")
	local note
	if not AucAdvanced then
		note = "You are using Auctioneer Classic for pricing."
	elseif AucAdvanced.Modules.Util.Appraiser then
		local defModel = AucAdvanced.Settings.GetSetting("util.appraiser.model") or "market"
		local markdown = math.floor(AucAdvanced.Settings.GetSetting("util.appraiser.bid.markdown") or 0)
		note = "You are using Auctioneer Advanced and Appraiser."..
	    	"\nWhen you logged on your default pricing plan was: "..defModel
	else
	    note = "You are using Auctioneer Advanced without Appraiser."..
	    	"\nUsing market price for evaluations."
	end
	gui:AddControl(id, "Note",             0, 0, 400, 50, note)
	gui:AddControl(id, "MoneyFramePinned", 0, 1, lcName..".profit.min", 1, 99999999, "Minimum Profit")
	gui:AddControl(id, "WideSlider",       0, 1, lcName..".profit.pct", 1, 100, 0.5, "Minimum Discount: %0.01f%%")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".quality.check", "Enable quality checking:")
	gui:AddControl(id, "Selectbox",        0, 2, qualityTable, lcName..".quality.min", "Minimum item quality")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".seen.check", "Enable checking \"seen\" count:")
	gui:AddControl(id, "WideSlider",       0, 2, lcName..".seen.mincount", 1, 100, 1, "Minimum seen count: %s")
		gui:AddControl(id, "Subhead",          0,    "Fees adjustment")
	gui:AddControl(id, "Selectbox",        0, 1, ahList, lcName..".adjust.basis", "Deposit/fees basis")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".adjust.brokerage", "Subtract auction fees from projected profit")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".adjust.deposit", "Subtract deposit cost from projected profit")
	gui:AddControl(id, "WideSlider",       0, 2, lcName..".adjust.listings", 1, 10, 0.1, "Average relistings: %0.1fx")
end

