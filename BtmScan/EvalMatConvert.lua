--[[
	BottomScanner - An AddOn for WoW to alert you to good purchases as they appear on the AH
	Version: <%version%> (<%codename%>)
	Revision: $Id: EvalTemplate.lua 2649 2007-12-10 03:59:23Z ccox $
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

local libName = "EMatsConvert"
local lcName = libName:lower()
local lib = { name = lcName, propername = libName }
table.insert(BtmScan.evaluators, lcName)
local define = BtmScan.Settings.SetDefault
local get = BtmScan.Settings.GetSetting
local set = BtmScan.Settings.SetSetting

BtmScan.evaluators[lcName] = lib

function lib:valuate(item, tooltip)
	local price = 0
	local value = 0

	-- If we're not enabled, scadaddle!
	if (not get(lcName..".enable")) then return end

	-- If this item is grey, forget about it.
	if (item.qual == 0) then return end

	-- Fail and exit if enchantrix is not available. (really doesnt matter anymore we don't call enchantrix for squat its all appraiser based pricing now
	if not (Enchantrix and Enchantrix.Storage) then return end
	
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
newBid = 0
newBuy = 0
--seen = 0
curModelText = "Unknown"
newBid, newBuy,_, curModelText = AucAdvanced.API.GetAppraiserValue(item.id, get(lcName..".matching.check"))
--		EnhTooltip.AddLine("  selfbid  ", newBid)
reagentPrice = 0				
if get(lcName..".buyout.check") then
	reagentPrice = newBuy
else
	reagentPrice = newBid
end
				
--	if (reagentPrice == nil or 0) then item:info("error? reagentPrice is nil") return  end
	
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
				seen = 1
				curModelText = "Unknown"
				--newBid, newBuy, seen, curModelText = AucAdvanced.API.GetAppraiserValue(item.link, get(lcName..".matching.check"))
				--EnhTooltip.AddLine("  greaterbid  ", newBid)
				newBid, newBuy, seen, curModelText = AucAdvanced.API.GetAppraiserValue(convertToID, get(lcName..".matching.check"))
	--			EnhTooltip.AddLine("  converttobid  ", newBid)
				
					if get(lcName..".buyout.check") then
						convertsToValue = newBuy * 3
					else
						convertsToValue = newBid * 3
					end
					EnhTooltip.AddLine("  converttobid *3 ", convertsToValue)
					
			--update value since greater = 3 lesser ( lesser value *  3 = correct value of one greater )
			-- convertsToValue = convertsToValue * 3
			convertsToValue = convertsToValue * stackSize
			--EnhTooltip.AddLine("  |cffddeeff 1x greater = 3x lesser |r  ", convertsToValue)
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
				seen = 1
				curModelText = "Unknown"
				newBid, newBuy, seen, curModelText = AucAdvanced.API.GetAppraiserValue(convertToID, get(lcName..".matching.check"))
			--	EnhTooltip.AddLine("  Convert to value  ", newBid)
				
					if get(lcName..".buyout.check") then
						convertsToValue = newBuy / 3
					else
						convertsToValue = newBid / 3
					end
					
			--		EnhTooltip.AddLine("  Convert to greater (gvalue /3) ", convertsToValue)
			--update value since 3 lesser = 1 greater ( greater value /  3 = correct value of one lesser )
			--convertsToValue = convertsToValue / 3
			convertsToValue = convertsToValue * stackSize
		--	EnhTooltip.AddLine("  |cffddeeff converts to * starcksize |r  ", convertsToValue)
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
				seen = 1
				curModelText = "Unknown"
		--		newBid, newBuy, seen, curModelText = AucAdvanced.API.GetAppraiserValue(item.link, get(lcName..".matching.check"))
		--		EnhTooltip.AddLine("  greaterbid  ", newBid)
				newBid, newBuy, seen, curModelText = AucAdvanced.API.GetAppraiserValue(convertToID, get(lcName..".matching.check"))
		--		EnhTooltip.AddLine("  converttobid  ", newBid)
				
					if get(lcName..".buyout.check") then
						convertsToValue = newBuy / 10
					else
						convertsToValue = newBid / 10
					end
	--				EnhTooltip.AddLine("  converttobid / 10 ", convertsToValue)
					
			--update value since 10 motes = 1 primal do primal price / 10 
			convertsToValue = convertsToValue * stackSize
	--		EnhTooltip.AddLine("  |cffddeeff 10x mote = 1x primal |r  ", convertsToValue)
		value = convertsToValue
	end
	
		-- Adjust for brokerage costs
	local brokerage = get(lcName..'.adjust.brokerage')
	emcAdjustedValue = value
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
	--- most of the next few lines are debug crap
	newBid = 0
	newBuy = 0
	seen = 1
	curModelText = "Unknown"
	
	newBid, newBuy, seen, curModelText = AucAdvanced.API.GetAppraiserValue(item.link, get(lcName..".matching.check"))
	--	EnhTooltip.AddLine("  newBid  ", newBid)
	--		EnhTooltip.AddLine("  newBuy  ", newBuy)
	--			EnhTooltip.AddLine("  seen  ", seen)
	--				EnhTooltip.AddLine("EMC using:", curModelText)
	--EnhTooltip.AddLine("  |cffddeeff (Non-Converted) Mat Value: |r  ", evalPrice)
	--EnhTooltip.LineColor(0.3, 0.9, 0.8)
	
	local value = emcAdjustedValue
	
		-- Calculate the real value of this item once our profit is taken out
	local pct = get(lcName..".profit.pct")
	local min = get(lcName..".profit.min")
	local value, mkdown = BtmScan.Markdown(emcAdjustedValue, pct, min)
	item:info(("(Converted) - %d%% / %s markdown"):format(pct,BtmScan.GSC(min, true)), mkdown)
	
	item:info("Final Converted Value", value)
	
	if value > evalPrice then
		EnhTooltip.AddLine("|cff00FF00 EMC: Buy me! Convert Me!|r")
		--EnhTooltip.LineColor(0.3, 0.9, 0.8)
		--EnhTooltip.AddLine("|cff00FF00(value) Ok to buy for convert!|r", value)
		--EnhTooltip.LineColor(0.3, 0.9, 0.8)
	else
		EnhTooltip.AddLine("|cffFF0000 EMC: Don't buy me to convert.|r")
		--EnhTooltip.LineColor(0.3, 0.9, 0.8)
		--EnhTooltip.AddLine("|cffFF0000 (value) Don't buy to Convert|r", value)
		--EnhTooltip.LineColor(0.3, 0.9, 0.8)
	end
	
	if emcAdjustedValue > evalPrice then
		EnhTooltip.AddLine("|cff00FF00 EMC: Convert me to sell! |r")
		--EnhTooltip.LineColor(0.3, 0.9, 0.8)
		--EnhTooltip.AddLine("|cff00FF00(value) Convert to sell!|r", emcAdjustedValue)
		--EnhTooltip.LineColor(0.3, 0.9, 0.8)
	else
		EnhTooltip.AddLine("|cffFF0000 EMC: Don't convert me, just sell me! |r")
		--EnhTooltip.LineColor(0.3, 0.9, 0.8)
		--EnhTooltip.AddLine("|cffFF0000 (value) Don't Convert to sell|r", emcAdjustedValue)
		--EnhTooltip.LineColor(0.3, 0.9, 0.8)
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

	--TODO: I think I need to change the profit figure to make the btmprompt display the proper 'potential profit' and 'rio' figures, currently the way I have it all its displaying the end result (meaning that my minimum pct + fixed min values and brokerage(if applicable) costs are already calculated what we need it to still calculate brokerage into this but ignore min profit settings for 'potential profit' and 'roi' displayed figures without screwing up the end valuation of the item.
	
	-- If what we are willing to pay for this item beats what
	-- other modules are willing to pay, and we can make more
	-- profit, then we "win".
	if (price >= item.purchase and profit > item.profit) then
		item.purchase = price
		item.reason = self.name  -- should be 'purchasing for xxx'
		item.what = self.name
		item.profit = profit
		item.valuation = value
	end
end

-- Setting defaults


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

--[[
TODO LIST: 

Finish cleaning up tooltip
Fix btm prompt visual data 
do some major code cleaning
Considering adding weights for conversions 
Considering adding ability to enable or disable a category or converts
Considering adding skillable converts but don't want to step on other evaluators (like prospect or de)

]]