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