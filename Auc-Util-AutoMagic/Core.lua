--[[
	Auctioneer Advanced - AutoMagic Utility module
	Version: <%version%> (<%codename%>)
	Revision: $Id: Core.lua 3005 2008-04-05 15:13:13Z testleK $
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
local AppraiserValue, DisenchantValue, ProspectValue, VendorValue, bestmethod, bestvalue

-- Setting mats and gems itemID's to something understandable 
-- enchant mats
local VOID = 22450
local NEXUS = 20725
local LPRISMATIC = 22449
local LBRILLIANT = 14344
local LRADIANT = 11178
local LGLOWING = 11139
local LGLIMMERING = 11084
local SPRISMATIC = 22448
local SBRILLIANT = 14343
local SRADIANT = 11177
local SGLOWING = 11138
local SGLIMMERING = 10978
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
local ARCANE = 22445
local ILLUSION = 16204
local DREAM = 11176
local VISION = 11137
local SOUL = 11083
local STRANGE = 10940
-- gems
local TIGERSEYE = 818
local MALACHITE = 774
local SHADOWGEM = 1210
local LESSERMOONSTONE = 1705
local MOSSAGATE = 1206
local CITRINE = 3864
local JADE = 1529
local AQUAMARINE = 7909
local STARRUBY = 7910
local AZEROTHIANDIAMOND = 12800
local BLUESAPPHIRE = 12361
local LARGEOPAL = 12799
local HUGEEMERALD = 12364
local BLOODGARNET = 23077
local FLAMESPESSARITE = 21929
local GOLDENDRAENITE = 23112
local DEEPPERIDOT = 23709
local AZUREMOONSTONE = 23117
local SHADOWDRAENITE = 23107
local LIVINGRUBY = 23436
local NOBLETOPAZ = 23439
local DAWNSTONE = 23440
local TALASITE = 23427
local STAROFELUNE = 23428
local NIGHTSEYE = 23441

-- This table is validating that each ID within it is a gem from prospecting.
local isGem = 
	{
	[TIGERSEYE] = true,
	[MALACHITE] = true,
	[SHADOWGEM] = true,
	[LESSERMOONSTONE] = true,
	[MOSSAGATE] = true,
	[CITRINE] = true,
	[JADE] = true,
	[AQUAMARINE] = true,
	[STARRUBY] = true,
	[AZEROTHIANDIAMOND] = true,
	[BLUESAPPHIRE] = true,
	[LARGEOPAL] = true,
	[HUGEEMERALD] = true,
	[BLOODGARNET] = true,
	[FLAMESPESSARITE] = true,
	[GOLDENDRAENITE] = true,
	[DEEPPERIDOT] = true,
	[AZUREMOONSTONE] = true,
	[SHADOWDRAENITE] = true,
	[LIVINGRUBY] = true,
	[NOBLETOPAZ] = true,
	[DAWNSTONE] = true,
	[TALASITE] = true,
	[STAROFELUNE] = true,
	[NIGHTSEYE] = true,
}

-- This table is validating that each ID within it is a mat from disenchanting.
local isDEMats = 
	{
	[VOID] = true,
	[NEXUS] = true,
	[LPRISMATIC] = true,
	[LBRILLIANT] = true,
	[LRADIANT] = true,
	[LGLOWING] = true,
	[LGLIMMERING] = true,
	[SPRISMATIC] = true,
	[SBRILLIANT] = true,
	[SRADIANT] = true,
	[SGLOWING] = true,
	[SGLIMMERING] = true,
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
	[ARCANE] = true,
	[ILLUSION] = true,
	[DREAM] = true,
	[VISION] = true,
	[SOUL] = true,
	[STRANGE] = true,
}

function lib.doScanAndUse(bag,bagType,amBTMRule)	
	if (get("util.automagic.uierrormsg")) == 1 then return end   -- Return if ui error msg event is fired.
	for slot=1,GetContainerNumSlots(bag) do
		if (GetContainerItemLink(bag,slot)) then
			local _,itemCount = GetContainerItemInfo(bag,slot)
			local itemLink = GetContainerItemLink(bag,slot)
			if (itemLink == nil) then return end
			local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink) 	
			local _, itemID, _, _, _, _ = decode(itemLink)
					
			
			if amBTMRule == "demats" then	
				if (get("util.automagic.uierrormsg")) == 0 then				
					if isDEMats[ itemID ] then
						if (get("util.automagic.chatspam")) then 
							print("AutoMagic has loaded", itemName, " because it is a mat used for enchanting.")
						end
						UseContainerItem(bag, slot)
						set("util.automagic.uierrormsg", 1)
					end
				end
			end
			if amBTMRule == "gems" then
				if (get("util.automagic.uierrormsg")) == 0 then
					if isGem[ itemID ] then
						if (get("util.automagic.chatspam")) then 
							print("AutoMagic has loaded", itemName, " because it is a mat used for enchanting.")
						end
						UseContainerItem(bag, slot) 
						set("util.automagic.uierrormsg", 1)
					end
				end
			end
			if amBTMRule == "vendor" then
				if (get("util.automagic.uierrormsg")) == 0 then	
					if autoSellList[ itemID ] then 
						if (get("util.automagic.chatspam")) then 
							print("AutoMagic is selling", itemName," due to being it your custom auto sell list!")
						end
						UseContainerItem(bag, slot)
						set("util.automagic.uierrormsg", 1)
					elseif (get("util.automagic.autosellgrey")) then
						if itemRarity == 0 then
							UseContainerItem(bag, slot)
							set("util.automagic.uierrormsg", 1)
							if (get("util.automagic.chatspam")) then 
								print("AutoMagic has sold", itemName," due to item being grey")
							end
						end			
					end 			
				end
			end
			
			if BtmScan then
				if (get("util.automagic.uierrormsg")) == 0 then
					local reason, bids
					local id, suffix, enchant, seed = BtmScan.BreakLink(itemLink)
					local sig = ("%d:%d:%d"):format(id, suffix, enchant)
					local bidlist = BtmScan.Settings.GetSetting("bid.list")
					
					if (bidlist) then
						bids = bidlist[sig..":"..seed.."x"..itemCount]
						
						if amBTMRule == "vendor" then
							if (get("util.automagic.uierrormsg")) == 0 then
								if(bids and bids[1] and bids[1] == "vendor") then 
									if (get("util.automagic.chatspam")) then 
										print("AutoMagic has sold", itemName, " due to vendor btm status")		
									end
									UseContainerItem(bag, slot) 
									set("util.automagic.uierrormsg", 1)
								end 
							end
						end
						if amBTMRule == "disenchant" then	
							if (get("util.automagic.uierrormsg")) == 0 then
								if(bids and bids[1] and bids[1] == "disenchant") then 
									if (get("util.automagic.chatspam")) then 
										print("AutoMagic has loaded", itemName, " due to disenchant btm status")
									end
									UseContainerItem(bag, slot) 
									set("util.automagic.uierrormsg", 1)
								end 
							end
						end
						if amBTMRule == "prospect" then
							if (get("util.automagic.uierrormsg")) == 0 then
								if(bids and bids[1] and bids[1] == "prospect") then 
									if (get("util.automagic.chatspam")) then 
										print("AutoMagic has loaded", itemName, " due to prospect btm status")
									end
									UseContainerItem(bag, slot) 
									set("util.automagic.uierrormsg", 1)
								end 
							end
						end
					end
				end
			end
		end
	set("util.automagic.uierrormsg", 0)
	end
end