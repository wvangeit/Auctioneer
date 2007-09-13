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

local libName = "Disenchant"
local lcName = libName:lower()
local lib = { name = lcName, propername = libName }
table.insert(BtmScan.evaluators, lcName)
local define = BtmScan.Settings.SetDefault
local get = BtmScan.Settings.GetSetting
local set = BtmScan.Settings.SetSetting

BtmScan.evaluators[lcName] = lib

function lib:valuate(item, tooltip)
	local price = 0

	-- Unless Enchantrix is running, the rest is moot
	if not (Enchantrix and Enchantrix.Storage) then return end

	-- If we're not enabled, scadaddle!
	if (not get(lcName..".enable")) then return end

	-- If this item is white or lower, forget about it.
	if (item.qual <= 1) then return end

	-- Check to see if the ilevel is below the disenchant threshold
	local _, _, iQual, iLevel = GetItemInfo(item.id)
	if (get(lcName..".level.custom")) then
		if (NonDisenchantables) then
			if (NonDisenchantables[item.id..":0:0"]) then
				item:info("Abort: Not DEable")
				return true
			end
		end
		
		-- We have to test a custom level
		local canDe, required = BtmScan.isDEAble(iLevel, iQual, get(lcName..".level.max"))

		-- If it's not disenchantable by our maxlevel, we don't want it
		if not canDe then
			item:info("Abort: DE level > max")
			return
		end
		-- If it's not disenchantable by our maxlevel, we don't want it
		if (required < get(lcName..".level.min")) then
			item:info("Abort: DE level < min")
			return
		end
	else
		-- Otherwise, just use our current level
		if (BtmScan.isDEAble(iLevel, iQual)) then
			item:info("Abort: DE level > current")
			return
		end
	end

	-- Valuate this item
	local market
	if (BtmScan.deReagentTable) then
		market = Enchantrix.Storage.GetItemDisenchantFromTable(item.link, BtmScan.deReagentTable)
	else
		local disenchantTo = Enchantrix.Storage.GetItemDisenchants(Enchantrix.Util.GetSigFromLink(item.link), item.name, true)
		if (disenchantTo and disenchantTo.totals and disenchantTo.totals.hspValue and item.qual > 1 and item.count <= 1) then
			market = disenchantTo.totals.hspValue * disenchantTo.totals.conf
		end
	end
	if not market then 
		item:info("Unable to get DE value")
		return
	end
	item:info("Disenchant value", market)

	-- Adjust for brokerage / deposit costs
	local adjusted = market
	local brokerage = get(lcName..'.adjust.brokerage')

	if (brokerage) then
		local basis = get(lcName..'.adjust.basis')
		local brokerRate, depositRate = 0.05, 0.05
		if (basis == "neutral") then
			brokerRate, depositRate = 0.15, 0.25
		end
		if (brokerage) then
			local amount = (market * brokerRate)
			adjusted = adjusted - amount
			item:info(" - Brokerage", amount)
		end
		item:info(" = Adjusted amount", adjusted)
	end

	-- Calculate the real value of this item once our profit is taken out
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
	if (item.canbuy and item.buy < value) then
		price = item.buy
	elseif (item.canbid and item.bid < value) then
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

local ahList = { 
	{'faction', "Faction AH Fees"},
	{'neutral', "Neutral AH Fees"},
}

define(lcName..'.enable', true)
define(lcName..'.profit.min', 4500)
define(lcName..'.profit.pct', 45)
define(lcName..'.level.custom', false)
define(lcName..'.level.min', 0)
define(lcName..'.level.max', 375)
define(lcName..'.adjust.brokerage', true)
define(lcName..'.adjust.basis', "faction")

function lib:setup(gui)
	id = gui:AddTab(libName)
	gui:AddControl(id, "Subhead",          0,    libName.." Settings")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".enable", "Enable purchasing for "..lcName)
	gui:AddControl(id, "MoneyFramePinned", 0, 1, lcName..".profit.min", 1, 99999999, "Minimum Profit")
	gui:AddControl(id, "WideSlider",       0, 1, lcName..".profit.pct", 1, 100, 0.5, "Minimum Discount: %0.01f%%")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".level.custom", "Use custom levels")
	gui:AddControl(id, "Slider",           0, 2, lcName..".level.min", 0, 375, 25, "Minimum skill: %s")
	gui:AddControl(id, "Slider",           0, 2, lcName..".level.max", 25, 375, 25, "Maximum skill: %s")
	gui:AddControl(id, "Subhead",          0,    "Fees adjustment")
	gui:AddControl(id, "Selectbox",        0, 1, ahList, lcName..".adjust.basis", "Auction fees basis")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".adjust.brokerage", "Subtract auction fees from projected profit")
end

