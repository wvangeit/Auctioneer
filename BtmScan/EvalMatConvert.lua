--[[
	BottomScanner - An AddOn for WoW to alert you to good purchases as they appear on the AH
	Version: <%version%> (<%codename%>)
	Revision: $Id: EvalMatConvert.lua 2649 2007-12-10 03:59:23Z testlek $
	URL: http://auctioneeraddon.com/dl/BottomScanner/
	Copyright (c) 2006, Norganna

	This is a module for BtmScan to evaluate an item for purchase.

TODO LIST: 

Fix btm prompt visual data fixed everything but discount rate doesnt show true discount rate (I dont think-- still ned to verify)
do some major code cleaning
Considering adding weights for conversions 
Considering adding ability to enable or disable a category or convertable item (maybe ties into weights?)
Considering adding skillable converts but don't want to step on other evaluators (like prospect or de)
(Add depleted items) Compare the depleted item cost to the real item cost (cause it's also a boe you can sell)

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

local libName = "EMatsConvert"
local lcName = libName:lower()
local lib = { name = lcName, propername = libName }
table.insert(BtmScan.evaluators, lcName)
local define = BtmScan.Settings.SetDefault
local get = BtmScan.Settings.GetSetting
local set = BtmScan.Settings.SetSetting

BtmScan.evaluators[lcName] = lib

function lib:valuate(item, tooltip)
	local	emcBuyFor = "EMC: Error.Debug"
	-- If we're not enabled, scadaddle!
	if (not get(lcName..".enable")) then return end

	-- If this item is grey, forget about it.
	if (item.qual == 0) then return end

	-- Fail and exit if enchantrix is not available. (really doesnt matter anymore we don't call enchantrix for squat its all appraiser based pricing now
		if not AucAdvanced.Modules.Util.Appraiser then
			item:info("EMC Debug: Appraiser not present")
		return end
			item:info("EMC: Debug: Appraiser is present")
			
	local price = 0
	local value = 0	
	local emcTrueSellValue = 0
	
	--Set names to item id so that I don't loose my mind trying to write this/ understand what I did before
	--essence's
	local GPLANAR = 22446
	local GETERNAL = 16203
	local GNETHER = 11175
	local GMYSTIC = 11135
	local GASTRAL = 11082
	local GMAGIC = 10939
	local LPLANAR = 22447
	local LETERNAL = 16202
	local LNETHER = 11174
	local LMYSTIC = 11134
	local LASTRAL = 10998
	local LMAGIC = 10938	
	--motes/primals
	local PAIR = 22451
	local MAIR = 22572	
	local PEARTH= 22452
	local MEARTH = 22573
	local PFIRE = 21884
	local MFIRE = 22574
	local PLIFE = 21886
	local MLIFE = 22575
	local PMANA = 22457
	local MMANA = 22576
	local PSHADOW = 22456
	local MSHADOW = 22577
	local PWATER = 21885
	local MWATER = 22578

	--Set convertable items table up
	local convertableMat = {
		[GPLANAR] = true,
		[GETERNAL] = true,
		[GNETHER] = true,
		[GMYSTIC] = true,
		[GASTRAL] = true,
		[GMAGIC] = true,
		[LPLANAR] = true,
		[LETERNAL] = true,
		[LNETHER] = true,
		[LMYSTIC] = true,
		[LASTRAL] = true,
		[LMAGIC] = true,
		--[PAIR] = false,  leaving the placeholders for the primals but keeping them commented for possible future use
		[MAIR] = true,
		--[PEARTH] = false, 	-- Blacksmiths can convert them back
		[MEARTH] = true,
		--[PFIRE] = false,           -- Blacksmiths can convert them back
		[MFIRE] = true,
		--[PLIFE] = false,
		[MLIFE] = true,
		--[PMANA] = false,
		[MMANA] = true,
		--[PSHADOW]= false,
		[MSHADOW] = true,
		--[PWATER] = false,
		[MWATER] = true,
	}

--Report failure and exit if the item is not in our convertableMat table 
if not convertableMat[ item.id ] then
	item:info("EMC Fail: Not a convertable item")
	return
end
	
local convertToValue = 0
local convertToID = 0


--if script breaks on next run its probably here where I did _ instead of seen...
local newBid = 0
local newBuy = 0
local curModelText = "Unknown"
local newBid, newBuy,_, curModelText = AucAdvanced.API.GetAppraiserValue(item.id, get(lcName..".matching.check"))

local reagentPrice = 0		
		
if get(lcName..".buyout.check") then
	reagentPrice = newBuy
else
	reagentPrice = newBid
end
	
	--set item we are looking at to evalPrice\
	local evalPrice = 0
	local evalPrice = reagentPrice

	--get stack size we are dealing with
	local stackSize = item.count
	
	-- set evalPrice to stack value for tooltip use
	local evalPrice = evalPrice * stackSize

	local convertsToL = {
		[GPLANAR] = true,
		[GETERNAL] = true,
		[GNETHER] = true,
		[GMYSTIC] = true,
		[GASTRAL] = true,
		[GMAGIC] = true,
	}
	
	if convertsToL[ item.id ] then
		if item.id == GPLANAR then convertToID = LPLANAR end
		if item.id == GETERNAL then convertToID = LETERNAL end
		if item.id == GNETHER then convertToID = LNETHER end
		if item.id == GMYSTIC then convertToID = LMYSTIC end
		if item.id == GASTRAL then convertToID = LASTRAL end
		if item.id == GMAGIC then convertToID = LMAGIC end
				newBid = 0
				newBuy = 0
				curModelText = "Unknown"
				newBid, newBuy, _, curModelText = AucAdvanced.API.GetAppraiserValue(convertToID, get(lcName..".matching.check"))

				--update value since greater = 3 lesser ( lesser value *  3 = correct value of one greater )
					if get(lcName..".buyout.check") then
						convertsToValue = newBuy * 3
					else
						convertsToValue = newBid * 3
					end
					
			
			convertsToValue = convertsToValue * stackSize
		value = convertsToValue
	end
	
	local convertsToG = {
		[LPLANAR] = true,
		[LETERNAL] = true,
		[LNETHER] = true,
		[LMYSTIC] = true,
		[LASTRAL] = true,
		[LMAGIC] = true,
	}
	
	if convertsToG[ item.id ] then
		if item.id == LPLANAR then convertToID = GPLANAR end
		if item.id == LETERNAL then convertToID = GETERNAL end
		if item.id == LNETHER then convertToID = GNETHER end
		if item.id == LMYSTIC then convertToID = GMYSTIC end
		if item.id == LASTRAL then convertToID = GASTRAL end
		if item.id == LMAGIC then convertToID = GMAGIC end
				newBid = 0
				newBuy = 0
				curModelText = "Unknown"
				newBid, newBuy, _, curModelText = AucAdvanced.API.GetAppraiserValue(convertToID, get(lcName..".matching.check"))
	
				--update value since 3 lesser = 1 greater ( greater value /  3 = correct value of one lesser )				
					if get(lcName..".buyout.check") then
						convertsToValue = newBuy / 3
					else
						convertsToValue = newBid / 3
					end

			convertsToValue = convertsToValue * stackSize

		value = convertsToValue
	end	
	
	local convertsToP = {
		[MAIR] = true,
		[MEARTH] = true,
		[MFIRE] = true,
		[MLIFE] = true,
		[MMANA] = true,
		[MSHADOW] = true,
		[MWATER] = true,
	}
	
	if convertsToP[ item.id ] then
		if item.id == MAIR then convertToID = PAIR end
		if item.id == MEARTH then convertToID = PEARTH end
		if item.id == MFIRE then convertToID = PFIRE end
		if item.id == MLIFE then convertToID = PLIFE end
		if item.id == MMANA then convertToID = PMANA end
		if item.id == MSHADOW then convertToID = PSHADOW end
		if item.id == MWATER then convertToID = PWATER end
		
				newBid = 0
				newBuy = 0
				curModelText = "Unknown"
				newBid, newBuy, _, curModelText = AucAdvanced.API.GetAppraiserValue(convertToID, get(lcName..".matching.check"))

			--update value since 10 motes = 1 primal do primal price / 10 				
					if get(lcName..".buyout.check") then
						convertsToValue = newBuy / 10
					else
						convertsToValue = newBid / 10
					end					

			convertsToValue = convertsToValue * stackSize
		value = convertsToValue
	end
	
		-- Adjust for brokerage costs
	local brokerage = get(lcName..'.adjust.brokerage')
	local emcAdjustedValue = value
	if (brokerage) then
		local basis = get(lcName..'.adjust.basis')
		local brokerRate, depositRate = 0.05, 0.05
		if (basis == "neutral") then
			brokerRate, depositRate = 0.15, 0.25
		end
		if (brokerage) then
			local amount = (value * brokerRate)
			emcAdjustedValue = value - amount
			item:info(" Converted Value", value)
			item:info(" - Brokerage", amount)
		item:info(" = Adjusted amount", emcAdjustedValue)		
		
			local evalPriceAmount = (evalPrice * brokerRate)
			evalPrice = evalPrice - evalPriceAmount
			item:info(" Non-Converted Value", evalPrice + evalPriceAmount)
			item:info(" - Brokerage", evalPriceAmount)
		item:info(" = Adjusted amount", evalPrice)			
		end

	end

	value = emcAdjustedValue
	
		-- Calculate the real value of this item once our profit is taken out
	local pct = get(lcName..".profit.pct")
	local min = get(lcName..".profit.min")
	local value, mkdown = BtmScan.Markdown(emcAdjustedValue, pct, min)
	item:info(("(Converted) - %d%% / %s markdown"):format(pct,BtmScan.GSC(min, true)), mkdown)
	item:info("mkdown", mkdown)
	item:info("emcAdjustedValue", emcAdjustedValue)
	item:info("Final Converted Value", value)
	
	if value > evalPrice then
		EnhTooltip.AddLine("|cff00FF00 EMC: Buy me! Convert Me!|r")
		emcBuyFor = "EMC: Convert 2 sell"
	else
		emcBuyFor = "EMC: Just sell me"
	end
	
	if emcAdjustedValue > evalPrice then
		EnhTooltip.AddLine("|cff00FF00 EMC: Convert me to sell! |r")
		emcBuyFor = "EMC: Convert 2 sell"	
		emcTrueSellValue = emcAdjustedValue
	else
		EnhTooltip.AddLine("|cffFF0000 EMC: Don't convert me, just sell me! |r")
		emcBuyFor = "EMC: Just sell me"
		emcTrueSellValue = evalPrice
	end
		
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
	if price > 0 then 
	profit = value - price 
	end
	
	-- If what we are willing to pay for this item beats what
	-- other modules are willing to pay, and we can make more
	-- profit, then we "win".
	if (price >= item.purchase and profit > item.profit) then
		item.purchase = price
		item.reason = emcBuyFor
		item.what = self.name
		item.profit = profit
		item.valuation = emcTrueSellValue
	end
end

--Setup GUI and GUI Defaults 
define(lcName..'.enable', false)
define(lcName..'.allow.buy', true)
define(lcName..'.allow.bid', true)
define(lcName..'.profit.min', 1)
define(lcName..'.profit.pct', 50)
local ahList = {
	{'faction', "Faction AH Fees"},
	{'neutral', "Neutral AH Fees"},
}
define(lcName..'.adjust.brokerage', true)
define(lcName..'.adjust.basis', "faction")
define(lcName..'.matching.check', true)
define(lcName..'.buyout.check', false)

function lib:setup(gui)
	local id = gui:AddTab(libName)	
	gui:AddHelp(id, "what is the Convert Mats evaluator",
		"What is the Convert Mats evaluator?",
		"This evaluator allows you to purchase items that can be changed to another item that is worth more (based on your settings here) by simply right clicking the item.\n\n"..
		""..
		"General Settings: This section allows you to configure if the evaluator is enabled and if it is enabled if you only want to allow it to bid or buyout items for converting\n\n"..
		""..
		"Custom Profit Settings: Minimum profit(discount from mat value) % and fixed $ amounts both must be met in order to allow an item to be purchased for this evaluator based on your settings here. You also have the option of turning on/off the use of market matchers when we valuate an item (it is suggested that you leave it on). You can also tell Convert Mats to use Bid price from Appraiser Tab instead of the Buyout price)\n\n"..
		""..
		"Fees Adjusments: This section allows you to select if you want brokerage (ah cut) and/or deposit costs figured in when valuating an item to prospect. You may also select how many times you project having to relist the mats before they will sell.\n\n"..
		""..
		"An example of a convertable item would be a greater essence into a lesser essence or visa versa.\n\n"..
		""..
		"Please note, this evaluator uses your last used fixed price or last used pricing module from appraiser tab, if you haven't posted a mat from appraiser tab it will use whatever pricing module you set as your default for appraiser.\n\n"..
		""..
		"This evaluator is in its very alpha stages and defaults to 'off' because it needs a performance boost and could probably use some more testing. Currently apears to work good for essence's and does not yet work for other non-skill required convertable items. Also it will prompt for bid/buyout sometimes even if converting it to its other form is not the right thing to do (the tooltip will tell you this) however it 's converted value is still meets your 'required' profit settings. When this happens it is a very good deal. buy and then do as your tool tip tells you (convert to sell or not to as the case may be) In the future this will be delivered in a more understandable fashion. \"Potential profit\" & \"Return on investment\" figures in the btm prompt are incorrect, please ignore them. profit over requirement is correct!\n\n"..
		""..
		"\n")

	gui:AddControl(id, "Subhead",		0,	libName.." General Settings")
	gui:AddControl(id, "Checkbox",		0, 1, 	lcName..".enable", " Read ALL of the help before you enable!!! Enable purchasing for "..lcName)
	gui:AddControl(id, "Checkbox",		0, 2, 	lcName..".allow.buy", "Allow buyout on items")
	gui:AddControl(id, "Checkbox",		0, 2, 	lcName..".allow.bid", "Allow bid on items")
		
	gui:AddControl(id, "Subhead",		0,	"Custom Profit Settings")
	gui:AddControl(id, "MoneyFramePinned", 0, 1, lcName..".profit.min", 1, 99999999, "Minimum Profit")
	gui:AddControl(id, "WideSlider",		0, 1, 	lcName..".profit.pct", 1, 100, 0.5, "Minimum Discount: %0.01f%%")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".matching.check", "We get a prices from Appraiser Tab. Check to use market matching (if enabled on the item [ Recommended ]")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".buyout.check", "Use Buyout Price instead of Bid Price:")	
	
	gui:AddControl(id, "Subhead",		0,    	"Fees adjustment")
	gui:AddControl(id, "Selectbox",		0, 1, 	ahList, lcName..".adjust.basis", "Deposit/fees basis")
	gui:AddControl(id, "Checkbox",		0, 1, 	lcName..".adjust.brokerage", "Subtract auction fees from convert profit")
end
