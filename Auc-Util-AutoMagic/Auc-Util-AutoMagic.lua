--[[
	Auctioneer Advanced - AutoMagic Utility module
	Version: <%version%> (<%codename%>)
	Revision: $Id: Auc-Util-AutoMagic.lua 2530 2007-11-18 22:18:59Z testleK $
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
	--TODO: Allow for notification of what AutoMagic wants to do to something...
end

function lib.OnLoad()
-- Create a dummy frame for catching events
local frame = CreateFrame("Frame","")
	frame:SetScript("OnEvent", lib.onEventDo);
	frame:RegisterEvent("MERCHANT_SHOW");
	frame:RegisterEvent("MERCHANT_CLOSED");
	frame:RegisterEvent("MAIL_SHOW");
	frame:RegisterEvent("MAIL_CLOSED");

-- Sets defaults	
	print("AucAdvanced: {{"..libType..":"..libName.."}} loaded!")
	
	default("util.automagic.autovendor", false) -- DO NOT SET TRUE ALL AUTOMAGIC OPTIONS SHOULD BE TURNED ON MANUALLY BY END USER!!!!!!!
	default("util.automagic.autosellgrey", false)
	default("util.automagic.autocloseenable", false)
	default("util.automagic.showmailgui", false)
end

	-- define what event fires what function
	function lib.onEventDo(this, event)
		if event == 'MERCHANT_SHOW' then lib.merchantShow() end
		if event == "MERCHANT_CLOSED" then lib.merchantClosed() end
		if event == 'MAIL_SHOW' then lib.mailShow() end
		if event == "MAIL_CLOSED" then lib.mailClosed() end
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
		"\n\n"..
		"Mail GUI: This enables the mail interface that allows for addition mailbox automation. \n\n"..
	"\n")
	gui:AddControl(id, "Header",     0,    libName.." options")
		gui:AddControl(id, "Checkbox",		0, 1, 	"util.automagic.autovendor", "Enable AutoMagic Vendoring (W A R N I N G: READ HELP) ")
		gui:AddControl(id, "Checkbox",		0, 1, 	"util.automagic.autosellgrey", "Allow AutoMagic to auto sell grey items in addition to bought for vendor items ")
		gui:AddControl(id, "Checkbox",		0, 1, 	"util.automagic.autoclosemerchant", "Auto Merchant Window Close(Power user feature READ HELP)")
		gui:AddControl(id, "Checkbox",		0, 1, 	"util.automagic.showmailgui", "Enable Mail GUI for addition mail features")
end


function lib.merchantShow()
	if (get("util.automagic.autovendor")) then 
		lib.doVendorCheck()
		if (get("util.automagic.autoclosemerchant")) then 
			print("AutoMagic has closed the merchant window for you, to disable you must change this options in the settings.") 
			CloseMerchant()	
		end
	end
end


function lib.merchantClosed()
	--Place holder for limiting chat spam to single output line as an option
end

function lib.doScanAndSell(bag,bagType)	
	for slot=1,GetContainerNumSlots(bag) do
		if (GetContainerItemLink(bag,slot)) then
			local _,itemCount = GetContainerItemInfo(bag,slot)
			local itemLink = GetContainerItemLink(bag,slot)
			local _, itemID, _, _, _, _ = decode(itemLink)
			local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink) 
				if (get("util.automagic.autosellgrey")) then  
					if itemRarity == 0 then
						UseContainerItem(bag, slot)
						print("AutoMagic has sold", itemName," due to item being grey")
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
								print("AutoMagic has sold", itemName, " due to vendor btm status")
							end
						end

		end
	end
end

function lib.doVendorCheck()
	for bag=0,4 do
		lib.doScanAndSell(bag,"Bags")
	end
end

function lib.mailShow()
	--if (get("util.automagic.enable")) then     --The .enable definition not implemented
	if (get("util.automagic.showmailgui")) then 
			print("AutoMagic:Debug: lib.mailShow()") 
			lib.mailGUI()
		end
	--end
end

--Fires on mail box closed event & hides mailgui
function lib.mailClosed()
	if (get("util.automagic.showmailgui")) then
		amgui:Hide()
	end
end

--Scans bags for btm reason 'disenchant' and uses them (on use loads into send mail tab)
function lib.doScanAndMailDE(bag,bagType)	
	for slot=1,GetContainerNumSlots(bag) do
		if (GetContainerItemLink(bag,slot)) then
			local _,itemCount = GetContainerItemInfo(bag,slot)
			local itemLink = GetContainerItemLink(bag,slot)
			local _, itemID, _, _, _, _ = decode(itemLink)
			local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink) 
			local reason, bids
			local id, suffix, enchant, seed = BtmScan.BreakLink(itemLink)
			local sig = ("%d:%d:%d"):format(id, suffix, enchant)
			local bidlist = BtmScan.Settings.GetSetting("bid.list")
			if (bidlist) then
				bids = bidlist[sig..":"..seed.."x"..itemCount]
				if(bids and bids[1] and bids[1] == "disenchant") then
					UseContainerItem(bag, slot)
					print("AutoMagic has loaded", itemName, " due to Disenchant btm rule")
				end
			end

		end
	end
end

--Function toggles to sendmail tab and fires the load disenchants function
function lib.doMailDE()
	--print("running toggle")
	MailFrameTab_OnClick(2)
	for bag=0,4 do
		lib.doScanAndMailDE(bag,"Bags")
	end
end

--Function is called from lib.mailShow()
function lib.mailGUI()
	--print("AutoMagic: loading mail gui")
	lib.makeMailGUI()
	print("AutoMagic:Debug: Mail GUI loaded... continue")
	amgui:Show()
end


--Make mail GUI
function lib.makeMailGUI()
	--print("AutoMagic:Debug: lib.mailGUI()")
	-- Create then hide frame for faster access later.
	amgui= CreateFrame("Frame", "", UIParent)
	amgui:Hide()

	-- Set frame visuals
	-- [name of frame]:SetPoint("[relative to point on my frame]","[frame we want to be relative to]","[point on relative frame]",-left/+right, -down/+up)
	amgui:SetPoint("TOPLEFT", "SendMailFrame", "TOPRIGHT", -25, -10)
	amgui:SetFrameStrata("DIALOG")
	amgui:SetHeight(75)
	amgui:SetWidth(100)
	amgui:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 9, right = 9, top = 9, bottom = 9 }
	})
	amgui:SetBackdropColor(0,0,0, 0.8)
	amgui:EnableMouse(true)
	amgui:SetMovable(true)
	
	-- Make highlightable drag ar
	amgui.Drag = CreateFrame("Button", "", amgui)
	amgui.Drag:SetPoint("TOPLEFT", amgui, "TOPLEFT", 10,-5)
	amgui.Drag:SetPoint("TOPRIGHT", amgui, "TOPRIGHT", -10,-5)
	amgui.Drag:SetHeight(6)
	amgui.Drag:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
	amgui.Drag:SetScript("OnMouseDown", function() amgui:StartMoving() end)
	amgui.Drag:SetScript("OnMouseUp", function() amgui:StopMovingOrSizing() end)
	

	-- [name of frame]:SetPoint("[relative to point on my frame]","[frame we want to be relative to]","[point on relative frame]",-left/+right, -down/+up)
	
	--Make text overlays -- Still need to get header text functioning
--	amgui.text = CreateFontString("AutoDisenchantPromptLine","TOP", "HIGH")
--	amgui.text:SetText(("Wowsers its my headers"))
--	amgui.text:SetHeight(30)
--	amgui.text:SetWidth(100)
--	amgui.text:SetPoint("TOP", amgui, "TOP", 0, 0)
	
	--Make buttons -- Need slightly longer buttons or get text overlays worked out to better describe function
	amgui.loadde = CreateFrame("Button", "", amgui, "OptionsButtonTemplate")
	amgui.loadde:SetText(("test"))
	amgui.loadde:SetPoint("BOTTOM", amgui, "BOTTOM", 0, 12)
	amgui.loadde:SetScript("OnClick", lib.doMailDE)
	
	amgui.loadprospect = CreateFrame("Button", "", amgui, "OptionsButtonTemplate")
	amgui.loadprospect:SetText(("BTM: DE's"))
	amgui.loadprospect:SetPoint("BOTTOM", amgui.loadde, "TOP", 0, 5)
	amgui.loadprospect:SetScript("OnClick", lib.doMailDE)
end




	
