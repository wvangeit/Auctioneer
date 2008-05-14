--[[
	Auctioneer Advanced - AutoMagic Utility module
	Version: <%version%> (<%codename%>)
	Revision: $Id$
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
local AppraiserValue, DisenchantValue, ProspectValue, VendorValue, bestmethod, bestvalue, runstop, _



function lib.vendorAction()
	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			if (GetContainerItemLink(bag,slot)) then
				local itemLink, itemCount = GetContainerItemLink(bag,slot)
				if itemCount == nil then _, itemCount = GetContainerItemInfo(bag, slot) end
				if itemCount == nil then itemCount = 1 end
				runstop = 0
				local _, itemID, _, _, _, _ = decode(itemLink)
				local itemName, _, itemRarity, _, _, _, _, _, _, _ = GetItemInfo(itemLink) 
				if autoSellList[ itemID ] then 
					if (get("util.automagic.chatspam")) then 
						print("AutoMagic is selling", itemName," due to being it your custom auto sell list!")
					end
					UseContainerItem(bag, slot)
					runstop = 1
				elseif (get("util.automagic.autosellgrey") and itemRarity == 0 and runstop == 0) then
					UseContainerItem(bag, slot)
					runstop = 1
					if (get("util.automagic.chatspam")) then 
						print("AutoMagic has sold", itemName," due to item being grey")
					end
					--end
					--[[if (get("util.automagic.overidebtmvendor") == true and runstop == 0) then
						local aimethod = lib.itemsuggest(itemLink, itemCount)
						if(aimethod == "Vendor") then 
							if (get("util.automagic.chatspam")) then 
								print("AutoMagic has sold", itemName, " due to Item Suggest(Vendor)")		
							end
							UseContainerItem(bag, slot) 
							runstop = 1
						end ]]
					--elseif (BtmScan and get("util.automagic.overidebtmmail") == false and runstop == 0) then
				elseif (BtmScan and runstop == 0) then
					local bidlist = BtmScan.Settings.GetSetting("bid.list")
					if (bidlist) then
						local reason, bids
						local id, suffix, enchant, seed = BtmScan.BreakLink(itemLink)
						local sig = ("%d:%d:%d"):format(id, suffix, enchant)
						bids = bidlist[sig..":"..seed.."x"..itemCount]
						if(bids and bids[1] and bids[1] == "vendor") then 
							if (get("util.automagic.chatspam")) then 
								print("AutoMagic has sold", itemName, " due to vendor btm status")		
							end
							UseContainerItem(bag, slot) 
							runstop = 1
						end 
					end
				end
			end
		end
	end
end


AucAdvanced.RegisterRevision("$URL$", "$Rev$")
