--[[
	Auctioneer Advanced - AutoMagic Utility module
	Version: <%version%> (<%codename%>)
	Revision: $Id: Example.lua 2530 2007-11-18 22:18:59Z testleK $
	URL: http://auctioneeraddon.com/

	AutoMagic is an Auctioneer Advanced module that tries to automate simple process's.

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
local libName = "AutoMagic"
local libType = "Util"

AucAdvanced.Modules[libType][libName] = {}
local lib,private = AucAdvanced.Modules[libType][libName]
local private = {}
local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()

function lib.GetName()
	return libName
end

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		--Called when the tooltip is being drawn.
		lib.ProcessTooltip(...)
	elseif (callbackType == "config") then
		--Called when you should build your Configator tab.
		private.SetupConfigGui(...)
	elseif (callbackType == "listupdate") then
		--Called when the AH Browse screen receives an update.
	elseif (callbackType == "configchanged") then
		--Called when your config options (if Configator) have been changed.
	end
end

function lib.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost, additional)
	--TODO: move around code make a isItemAutoVendorable function and if it is then insert a tooltip notice notifing end user item is to be sold @ next merchant stop
end

function lib.OnLoad()
-- creates eventcatcherframe to catch events. this is a dummy frame that is hidden.
local frame = CreateFrame("Frame","")
	frame:SetScript("OnEvent", onEventDo);
	frame:RegisterEvent("MERCHANT_SHOW");
	frame:RegisterEvent("MERCHANT_CLOSED");
-- Sets defaults	
	print("AucAdvanced: {{"..libType..":"..libName.."}} loaded!")
	default("util.automagic.enable", false) -- DO NOT SET TRUE ALL AUTOMAGIC OPTIONS SHOULD BE TURNED ON MANUALLY BY END USER!!!!!!!
	default("util.automagic.autosellgrey", false)
	default("util.automagic.autocloseenable", false)
end

-- define what event fires what function
function onEventDo(this, event)
	if event == 'MERCHANT_SHOW' then merchantShow() end
	if event == "MERCHANT_CLOSED" then merchantClosed() end
end

function private.SetupConfigGui(gui)
	local id = gui:AddTab(libName)
	gui:MakeScrollable(id)
		gui:AddHelp(id, "what is AutoMagic?",
		"What is AutoMagic?",
		"AutoMagic is a work-in-progress. Its goal is to automate tasks that auctioneers run into that can be a pain to do, as long as it is within the bounds set by blizzard.\n\n"..
		"AutoMagic currently will auto sells any item bought via btm for vendor, or any item that is grey (if enabled) there are no warnings they just disapear when a merchant window is opened if enabled.\n\n"..
		"Auto Close Merchant Window: This is a very advanced command, if enabled it will sell items and close the merchant window without asking to close it. IF THIS IS ENABLED THE SECOND YOU OPEN A MERCHANT WINDOW ITEMS ARE SOLD(if any to sell) AND WINDOW IS CLOSED!!! This is a power user option and most people will want it disabled!\n\n"..
		"Caution: There are no warnings, open a merchant window and if this is enabled the items are sold without warning!!!  Again... No warnings just poof gone... \n\n"..
	"\n")
	gui:AddControl(id, "Header",     0,    libName.." options")
		gui:AddControl(id, "Checkbox",		0, 1, 	"util.automagic.enable", "Enable AutoMagic Vendoring (W A R N I N G: READ HELP) ")
		gui:AddControl(id, "Checkbox",		0, 1, 	"util.automagic.autosellgrey", "Allow AutoMagic to auto sell grey items in addition to bought for vendor items ")
		gui:AddControl(id, "Checkbox",		0, 1, 	"util.automagic.autoclosemerchant", "Auto Merchant Window Close(Power user feature READ HELP)")
end



function merchantShow()
	if (get("util.automagic.enable")) then 
		doBagCheck()
		if (get("util.automagic.autoclosemerchant")) then 
			print("AutoMagic has closed the merchant window for you, to disable you must change this options in the settings.") 
			CloseMerchant()	
		end
	end
end


function merchantClosed()
	--Place holder for limiting chat spam to single output line as an option
end

function doScanAndSell(bag,bagType)	
	for slot=1,GetContainerNumSlots(bag) do
		if (GetContainerItemLink(bag,slot)) then
			local _,itemCount = GetContainerItemInfo(bag,slot)
			local itemLink = GetContainerItemLink(bag,slot)
			local _, itemID, _, _, _, _ = decode(itemLink)
			local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink) 
				if (get("util.automagic.autosellgrey")) then  
					if itemRarity == 0 then
						UseContainerItem(bag, slot)
						print("AutoMagic has sold", itemName," do to item being grey")
					end
				end
				local reason, bids
					local id, suffix, enchant, seed = BtmScan.BreakLink(itemLink)
					local sig = ("%d:%d:%d"):format(id, suffix, enchant)
					local bidlist = BtmScan.Settings.GetSetting("bid.list")
						if (bidlist) then
							bids = bidlist[sig..":"..seed.."x"..itemCount]
							if(bids and bids[1] and bids[1] == "vendor") then
								UseContainerItem(bag, slot)
								print("AutoMagic has sold", itemName, " do to vendor btm status")
							end
						end

		end
	end
end

function doBagCheck()
	for bag=0,4 do
		doScanAndSell(bag,"Bags")
	end
end






	
