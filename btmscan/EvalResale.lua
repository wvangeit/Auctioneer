--[[
This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

This is a module for BtmScan to evaluate an item for purchase.

If you wish to make your own module, do the following:
 -  Make a copy of the supplied "EvalTemplate.lua" file.
 -  Rename your copy to a name of your choosing.
 -  Edit your copy to do your own valuations of the item.
      (search for the "TODO" sections in the file)
 -  Insert your new file's name into the "BtmScan.toc" file.
 -  Optionally, put it up on the wiki at:
      http://norganna.org/wiki/BottomScanner/Evaluators

]]

-- If auctioneer is not loaded, then we cannot run.
if not (AucAdvanced or (Auctioneer and Auctioneer.Statistic)) then return end

local libName = "Resale"
local lcName = libName:lower()
local lib = { name = lcName, propername = libName }
table.insert(BtmScan.evaluators, lcName)
local define = BtmScan.Settings.SetDefault
local get = BtmScan.Settings.GetSetting
local set = BtmScan.Settings.SetSetting

BtmScan.evaluators[lcName] = lib

function lib:valuate(item, tooltip)
	local price = 0

	-- If we're not enabled, scadaddle!
	if (not get(lcName..".enable")) then return end

	-- If this item is not good enough, forget about it.
	if (get(lcName..".quality.check")) then
		if (item.qual < get(lcName..".quality.min")) then
			item:info("Abort: Quality < min")
			return
		end
	end

	-- Valuate this item
	local market, seen
	local useFour = get(lcName..".auct.usefour")
	local useHSP = get(lcName..".auct.usehsp")
	if Auctioneer and Auctioneer.Statistic and Auctioneer.Statistic.GetUsableMedian then
		if (AucAdvanced and useFour) or not AucAdvanced then
			if (useHSP) then
				market, seen = Auctioneer.Statistic.GetHSP(auctKey)
			end
			if not market then
				market, seen = Auctioneer.Statistic.GetUsableMedian(item.link)
			end
		end
	end
	if (AucAdvanced and not market) then
		market, seen = AucAdvanced.API.GetMarketValue(item.link)
	end

	-- If we don't know what it's worth, then there's not much we can do
	if not market then return end
	market = market * item.count
	item:info("Market price", market)

	-- Check to see if it meets the min seen count (if applicable)
	if (get(lcName..".seen.check")) then
		if (not seen or seen < get(lcName..".seen.mincount")) then
			item:info("Abort: Seen < min")
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
		item:info(" = Adjusted amount", adjusted)
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
	if (item.canbuy and not get(lcName..".never.buy") and item.buy < value) then
		price = item.buy
	elseif (item.canbid and not get(lcName..".never.bid") and item.bid < value) then
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
define(lcName..'.profit.pct', 30)
define(lcName..'.auct.usehsp', false)
define(lcName..'.quality.check', true)
define(lcName..'.quality.min', 1)
define(lcName..'.adjust.basis', "faction")
define(lcName..'.adjust.brokerage', true)
define(lcName..'.adjust.listings', 1)
define(lcName..'.seen.check', false)
define(lcName..'.seen.mincount', 10)
define(lcName..'.never.bid', false)
define(lcName..'.never.buyout', false)
function lib:setup(gui)
	id = gui:AddTab(libName)
	gui:AddControl(id, "Subhead",          0,    libName.." Settings")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".enable", "Enable purchasing for "..lcName)
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".never.buy", "Never buyout items")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".never.bid", "Never bid on items")
	gui:AddControl(id, "MoneyFramePinned", 0, 1, lcName..".profit.min", 1, 99999999, "Minimum Profit")
	gui:AddControl(id, "WideSlider",       0, 1, lcName..".profit.pct", 1, 100, 0.5, "Percent Profit: %0.01f%%")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".quality.check", "Enable quality checking:")
	gui:AddControl(id, "Selectbox",        0, 2, qualityTable, lcName..".quality.min", "Minimum item quality")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".seen.check", "Enable checking \"seen\" count:")
	gui:AddControl(id, "WideSlider",       0, 2, lcName..".seen.mincount", 1, 100, 1, "Minimum seen count: %s")
	if Auctioneer and Auctioneer.Statistic and Auctioneer.Statistic.GetUsableMedian then
		if AucAdvanced then
			gui:AddControl(id, "Checkbox",         0, 1, lcName..".auct.usefour", "Prefer Auctioneer 4 prices when avaiable")
		else
			gui:AddControl(id, "Subhead", 0, "Auctioneer options")
		end
		if Auctioneer.Statistic.GetHSP then
			gui:AddControl(id, "Checkbox",         0, 2, lcName..".auct.usehsp", "Prefer HSP instead of Median")
		end
	end
	gui:AddControl(id, "Subhead",          0,    "Fees adjustment")
	gui:AddControl(id, "Selectbox",        0, 1, ahList, lcName..".adjust.basis", "Deposit/fees basis")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".adjust.brokerage", "Subtract auction fees from projected profit")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".adjust.deposit", "Subtract deposit cost from projected profit")
	gui:AddControl(id, "WideSlider",       0, 2, lcName..".adjust.listings", 1, 10, 0.1, "Average relistings: %0.1fx")
end

