--[[
	BottomScanner - An AddOn for WoW to alert you to good purchases as they appear on the AH
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/dl/BottomScanner/
	Copyright (c) 2006, Norganna

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

local libName = "Comparable"
local lcName = libName:lower()
local lib = { name = lcName, propername = libName }
table.insert(BtmScan.evaluators, lcName)
local define = BtmScan.Settings.SetDefault
local get = BtmScan.Settings.GetSetting
local set = BtmScan.Settings.SetSetting

BtmScan.evaluators[lcName] = lib



-- this is our master list of comparable items
-- it is broken down by categories of item, each of which has a list of items in that category
-- at runtime we generate a reverse lookup table of items -> category
-- at runtime we generate a list of prices for each category based on the items in that category

-- TODO - remove all BOP items from the list (BOE is fine for bags)
-- if a category ends up with a single item, remove that category!

lib.masterCategories = {

["BAG_6_SLOT"] = { 5572, 4496, 5762, 5081, 4957, 805, 828, 4238, 5571 },
["BAG_8_SLOT"] = { 4240, 856, 5574, 3233, 4498, 4241, 5763, 5573, 2657 },
["BAG_10_SLOT"] = { 5576, 857, 4245, 804, 932, 5764, 5765, 6446, 1470, 4497, 933, 5575 },
["BAG_12_SLOT"] = { 1652, 1725, 4499, 10051, 10050 },
["BAG_14_SLOT"] = { 3914, 1685, 14046 },
["BAG_16_SLOT"] = { 14155, 4500 },
["BAG_18_SLOT"] = { 21843, 14156 },

["FOOD_30Health"] = { 6291, 6299, 6303, 11109, 8683 },
["FOOD_61Health"] = { 6289, 6317, 6361, 6458, 2681, 117, 787, 961, 2070, 2679 },
["FOOD_243Health"] = { 6308, 414, 1113, 1326, 2287, 4537, 4541, 4592, 4605, 5066 },
["FOOD_552Health"] = { 6362, 8365, 422, 1114, 3770, 4538, 4542, 4593, 4606, 7228 },
["FOOD_874Health"] = { 4603, 13754, 13755, 13756, 13758, 13759, 13760, 1487, 1707, 3771 },
["FOOD_1392Health"] = { 8959, 13888, 13889, 13893, 18255, 3927, 4599, 4601, 4602, 4608, 13930 },
["FOOD_2148Health"] = { 8932, 8948, 8950, 8952, 8953, 8957, 11415, 11444, 13933 },
["FOOD_4320Health"] = { 27661, 27654, 27855, 27856, 27857, 27858, 27859, 28486, 29393, 29412, 30458, 30610, 24408 },
["FOOD_7500Health"] = { 29394, 29448, 29449, 29450, 29451, 29452, 29453, 30355, 32685, 33048 },

["FOOD_61Health2StaSpr"] = { 5474, 2888, 23756, 24105, 27635, 2680, 5472, 6888, 12224, 17197 },
["FOOD_243Health4StaSpr"] = { 724, 2683, 2684, 2687, 3220, 3662, 5476, 5477, 5525, 22645, 27636 },
["FOOD_552Health6StaSpr"] = { 1017, 3663, 3664, 3665, 3666, 3726, 3727, 5480, 5527, 12209, 5479, 1082 },
["FOOD_874Health8StaSpr"] = { 3729, 4457, 6038, 12210, 12212, 12213, 12214, 13851, 3728, 20074 },
["FOOD_1392Health12StaSpr"] = { 12216, 12218, 16971, 18045, 12215, 17222 },
-- TODO - shouldn't there be a 2148 category?
["FOOD_4320Health20StaSpr"] = { 27651, 27662, 30155 },
["FOOD_7500Health20StaSpr"] = { 27660, 31672 },

["FOOD_294HealthMana"] = { 2682, 3448 },
["FOOD_4320Health10Sta"] = { 24008, 24009, 13934, 28501 },
["FOOD_2148Health20Str"] = { 20452, 29292 },
["FOOD_7500Health20StrSpr"] = { 30359, 27658 },
["FOOD_7500Health30Sta20Spr"] = { 33052, 27667 },
["FOOD_7500Health20AgiSpr"] = { 30358, 27659, 27664 },		-- BOP?
["FOOD_7500Health23Spell20Spr"] = { 30361, 27657, 27665, 31673 },	-- BOP?
["FOOD_7500Health44Heal20Spr"] = { 30357, 27666 },		-- BOP?

}



-- this is our master list of things that everyone can convert one direction
-- this is result = component and count
-- (right now it's just motes -> primals)

-- at runtime we generate a reverse lookup table of items -> category
-- at runtime we generate a list of prices for each category based on the items in that category

lib.masterConvertables = {
	[22451] = { item = 22572, count = 10 },		-- Primal Air = 10x Mote of Air
	[22452] = { item = 22573, count = 10 },		-- Primal Earth = 10x Mote of Earth
	[21884] = { item = 22574, count = 10 },		-- Primal Fire = 10x Mote of Fire
	[21886] = { item = 22575, count = 10 },		-- Primal Life = 10x Mote of Life
	[22457] = { item = 22576, count = 10 },		-- Primal Mana = 10x Mote of Mana
	[22456] = { item = 22577, count = 10 },		-- Primal Shadow = 10x Mote of Shadow
	[21885] = { item = 22578, count = 10 },		-- Primal Water = 10x Mote of Water
}


-- calculate category price and cache it
local function getPriceForCategory( itemID )

	-- if the category reverse lookup is not initialized, create it now
	-- this will only happen once per session
	if (not lib.itemToCategory) then
		lib.itemToCategory = {}
		for category, itemList in pairs(lib.masterCategories) do
			local n = #itemList;
			for i = 1, n do
				local itemID = itemList[i]
				lib.itemToCategory[itemID] = category
			end
		end
	end
	
	local category = lib.itemToCategory[ itemID ]
	
	-- if it's not in our list, then we're not interested
	if (not category) then
		return nil
	end

	-- if the cache has not been created, create it now
	if (not lib.PriceForCategory) then
		lib.PriceForCategory = {}
	end

	local value = lib.PriceForCategory[ category ]

	if (not value) then
		-- we need to build the value and cache it
		
-- TODO - update cache of prices periodically (not every time, and not once per session!)
-- maybe once every 30 seconds?

		-- run over the items in the category and calculate the overall price
		local itemList = lib.masterCategories[ category ]
		
		local runningSum = 0
		local itemCount = 0		-- because we may not get values for all items
		
		local n = #itemList;
		for i = 1, n do
			local itemID = itemList[i]
			
-- TODO - allow more flexible pricing
			local market
			if AucAdvanced then
				market = AucAdvanced.API.GetMarketValue(itemID)
			else
				market = Auctioneer.Statistic.GetUsableMedian(itemID)
			end
			if (market) then
				runningSum = runningSum + market
				itemCount = itemCount + 1
			end
		end

-- TODO - allow something better than an average
		if (itemCount) then
			value = runningSum / itemCount
		else
			value = 0
		end

		-- now store this value in our cache
		lib.PriceForCategory[ category ] = value
	end
	
	return value or 0
end



local function getConvertablePrice(itemID)
	
	-- if the convertable reverse lookup is not initialized, create it now
	-- this will only happen once per session
	if (not lib.itemToConvertable) then
		lib.itemToConvertable = {}
		for resultItem, componentData in pairs(lib.masterConvertables) do
			local componentItemID = componentData.item
			local componentCount = componentData.count
			local newData = {}
			newData.result = resultItem
			newData.count = componentCount
			lib.itemToConvertable[ componentItemID ] = newData
		end
	end

	local convertData = lib.itemToConvertable[itemID]

	-- item isn't in our table?  then we don't care
	if (not convertData) then
		return nil
	end
	
	-- return the price of the result item divided by the count
	local resultValue
	if AucAdvanced then
		resultValue = AucAdvanced.API.GetMarketValue(convertData.result)
	else
		resultValue = Auctioneer.Statistic.GetUsableMedian(convertData.result)
	end
	if not resultValue or resultValue == 0 then
		return
	end
	
	local value = resultValue / convertData.count;
	
	return value
end



-- do the valuation for an item
function lib:valuate(item, tooltip)
	local price = 0

	-- If we're not enabled, scadaddle!
	if (not get(lcName..".enable")) then return end
		
	-- Check for bogus/corrupted item links
	if not (item) then return end


-- TODO - ccox - make this more efficient!
-- I should only have to do one lookup for all items
	
	local market = getPriceForCategory( item.id  )

	if (not market) then
		-- check convertables
		market = getConvertablePrice(item.id)
	end

	if (not market) then
		return
	end
	
	market = market * item.count


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


-- UI bits
local ahList = {
	{'faction', "Faction AH Fees"},
	{'neutral', "Neutral AH Fees"},
}

define(lcName..'.enable', false)
define(lcName..'.profit.min', 4500)
define(lcName..'.profit.pct', 45)
define(lcName..'.adjust.brokerage', true)
define(lcName..'.adjust.basis', "faction")
define(lcName..'.allow.bid', true)
define(lcName..'.allow.buy', true)

function lib:setup(gui)
	local id = gui:AddTab(libName)
	gui:AddControl(id, "Subhead",          0,    libName.." Settings")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".enable", "Enable purchasing for "..lcName)
	gui:AddControl(id, "Checkbox",         0, 2, lcName..".allow.buy", "Allow buyout on items")
	gui:AddControl(id, "Checkbox",         0, 2, lcName..".allow.bid", "Allow bid on items")

	gui:AddControl(id, "MoneyFramePinned", 0, 1, lcName..".profit.min", 1, 99999999, "Minimum Profit")
	gui:AddControl(id, "WideSlider",       0, 1, lcName..".profit.pct", 1, 100, 0.5, "Minimum Discount: %0.01f%%")
	gui:AddControl(id, "Subhead",          0,    "Fees adjustment")
	gui:AddControl(id, "Selectbox",        0, 1, ahList, lcName..".adjust.basis", "Auction fees basis")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".adjust.brokerage", "Subtract auction fees from projected profit")
end

