--[[
	Auctioneer Advanced - AutoMagic Utility module
	Version: <%version%> (<%codename%>)
	Revision: $Id: Auc-Util-AutoMagic.lua 3005 2008-04-05 15:13:13Z RockSlice $
	URL: http://auctioneeraddon.com/
	AutoMagic is an Auctioneer Advanced module.
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

local lib = AucAdvanced.Modules.Util.AutoMagic
local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()
local GetAprPrice = AucAdvanced.Modules.Util.Appraiser.GetPrice
local AppraiserValue, DisenchantValue, ProspectValue, VendorValue, bestmethod, bestvalue
function lib.itemsuggest(frame, name, hyperlink, quality, quantity, cost, additional)
	
	-- Determine Base Values
	VendorValue = lib.GetVendorValue(hyperlink, quantity)
	AppraiserValue = lib.GetAppraiserValue(hyperlink, quantity)
	
	if (get("util.automagic.jewelcraftskill") == 0) then 
		ProspectValue = 0
	else 
		ProspectValue = lib.GetProspectValue(hyperlink, quantity)
	end
	
	if (get("util.automagic.enchantskill") == 0) then 
		DisenchantValue = 0
	else	
		DisenchantValue = lib.GetDisenchantValue(hyperlink, quantity)
	end
	
	-- Do super duper nil check
	if VendorValue == nil then VendorValue = 0 end
	if AppraiserValue == nil then AppraiserValue = 0 end
	if ProspectValue == nil then ProspectValue = 0 end
	if DisenchantValue == nil then DisenchantValue = 0 end
	
	-- Adjust final values based on custom weights by enduser
	local adjustment = get("util.automagic.vendorweight") or 0
	VendorValue = VendorValue * adjustment / 100
	adjustment = get("util.automagic.auctionweight") or 0
	AppraiserValue = AppraiserValue * adjustment / 100
	adjustment = get("util.automagic.prospectweight") or 0
	ProspectValue = ProspectValue * adjustment / 100
	adjustment = get("util.automagic.disenchantweight") or 0
	DisenchantValue = DisenchantValue * adjustment / 100

	-- Determine which method 'wins' the battle
	bestvalue = math.max(0, VendorValue, AppraiserValue, ProspectValue, DisenchantValue)
	bestmethod = "Unknown"
	if bestvalue == 0 then 
		bestmethod = "Unkown"
		bestvalue = "Unknown"
	elseif bestvalue == VendorValue then 
		bestmethod = "Vendor"
	elseif bestvalue == AppraiserValue then 
		bestmethod = "Auction"
	elseif bestvalue == ProspectValue then
		bestmethod = "Prospect"
	elseif bestvalue == DisenchantValue then
		bestmethod = "Disenchant"
	end
	
	-- Hand the winner back to the asker....
	return bestmethod, bestvalue 
end

function lib.GetAppraiserValue(hyperlink, quantity)
	AppraiserValue = GetAprPrice(hyperlink, nil, true) or 0
	AppraiserValue = AppraiserValue * quantity
	local brokerRate, depositRate = 0.05, 0.05
	if (get("util.automagic.includedeposit")) then
		local _, itemid, itemsuffix, _, itemenchant, itemseed = decode(hyperlink)  -- lType, id, suffix, factor, enchant, seed
		local itemsig = (":"):join(itemid, itemsuffix, itemenchant)
		local aadvdepcost = AucAdvanced.Post.GetDepositAmount(itemsig, quantity) or 0
		local depcost = depositCostList[itemid] * quantity or aadvdepcost
		AppraiserValue = AppraiserValue - depcost * get("util.automagic.relisttimes")
	end
	if (get("util.automagic.includebrokerage")) then
		AppraiserValue = AppraiserValue + AppraiserValue * brokerRate
	end
	
return AppraiserValue end

function lib.GetDisenchantValue(hyperlink, quantity)
	local DisenchantValue = 0
	local _, _, iQual, iLevel = GetItemInfo(hyperlink)
	local skillneeded = Enchantrix.Util.DisenchantSkillRequiredForItemLevel(iLevel, iQual)
	local market
	
	if (skillneeded > get("util.automagic.enchantskill"))  then
		return DisenchantValue
	else
		_, _, _, market = Enchantrix.Storage.GetItemDisenchantTotals(hyperlink)
		
		if (market == 0)  then
			return DisenchantValue
		end
	end	
		
	local adjusted = market or 0
	
	if (get("util.automagic.includebrokerage")) then
		local brokerRate, depositRate = 0.05, 0.05
		local amount = (adjusted * brokerRate)
		adjusted = adjusted - amount
	end
	
	DisenchantValue = adjusted
return DisenchantValue end

function lib.GetProspectValue(hyperlink, quantity)
	local ProspectValue = 0
	local prospects = Enchantrix.Storage.GetItemProspects(hyperlink)
	local jcSkillRequired = Enchantrix.Util.JewelCraftSkillRequiredForItem(hyperlink)
	if (jcSkillRequired == nil or jcSkillRequired > get("util.automagic.jewelcraftskill"))  then
		return ProspectValue
	else
		local _, itemid, _, _, _, _ = decode(hyperlink)  -- lType, id, suffix, factor, enchant, seed
		local trashTotal, marketTotal, depositTotal, brokerTotal = 0, 0, 0, 0
		local brokerRate, depositRate = 0.05, 0.05
		
		if (prospects) == nil then return ProspectValue end
		for result, yield in pairs(prospects) do
		-- adjust for stack size
		yield = yield * quantity / 5

			local _, _, quality = GetItemInfo(result)
			if quality == 0 then
				-- vendor trash (lower level powders)
				-- we need informant to get the vendor prices, if it is missing, use price of zero
				local vendor = GetSellValue(result) or 0
					trashTotal = trashTotal + vendor * yield
			else
				-- gem or non-trashy powder
				local _, _, _, market = Enchantrix.Util.GetReagentPrice(result)
				-- use a zero value if no price is available (may happen for reagents you haven't seen)
				market = market or 0
				local marketPrice = market * yield
				marketTotal = marketTotal + marketPrice

				-- calculate costs
				if (get("util.automagic.includedeposit")) then
					local _, itemid, itemsuffix, _, itemenchant, itemseed = decode(hyperlink)  -- lType, id, suffix, factor, enchant, seed
					local itemsig = (":"):join(itemid, itemsuffix, itemenchant)
					local aadvdepcost = AucAdvanced.Post.GetDepositAmount(itemsig, 1) or 0
					local depcost = depositCostList[itemid] or aadvdepcost
					depositTotal = depositTotal + depcost * get("util.automagic.relisttimes") * yield
				end
				if (get("util.automagic.includebrokerage")) then
					brokerTotal = brokerTotal + marketPrice * brokerRate
				end
			end
		end

		local resaleTotal = marketTotal - depositTotal - brokerTotal
		ProspectValue = resaleTotal
	end

return ProspectValue end

function lib.GetVendorValue(hyperlink, quantity)
	VendorValue = GetSellValue and GetSellValue(hyperlink) or 0
	VendorValue = VendorValue * quantity
return VendorValue end
