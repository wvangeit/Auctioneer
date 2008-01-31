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
local libName = "AutoMagic"
local libType = "Util"

AucAdvanced.Modules[libType][libName] = {}
local lib,private = AucAdvanced.Modules[libType][libName]
local private = {}
local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()
local amBTMRule

local amgui = CreateFrame("Frame", "", UIParent)
amgui:Hide()

-- Reagents list
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

-- a table we can check for item ids
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
		"\n")
		gui:AddHelp(id, "AAMU: vendor options",
			"AAMU: vendor options?",
			"AutoMagic will sell items bought for vendoring to the vendor automatically if enabled. It also has the option of auto selling all grey items.\n\n"..
			"Auto Close Merchant Window: This is a very advanced command, if enabled it will sell items and close the merchant window without asking to close it. IF THIS IS ENABLED THE SECOND YOU OPEN A MERCHANT WINDOW ITEMS ARE SOLD(if any to sell) AND WINDOW IS CLOSED!!! This is a power user option and most people will want it disabled!\n\n"..
			"Caution: There are no warnings, open a merchant window and if this is enabled the items are sold without warning!!!  Again... No warnings just poof gone... \n\n"..
			"\n\n"..
		"\n")
		gui:AddControl(id, "Header",     0,    libName.." vendor options")
		gui:AddControl(id, "Checkbox",		0, 1, 	"util.automagic.autovendor", "Enable AutoMagic Vendoring (W A R N I N G: READ HELP) ")
		gui:AddControl(id, "Checkbox",		0, 1, 	"util.automagic.autosellgrey", "Allow AutoMagic to auto sell grey items in addition to bought for vendor items ")
		gui:AddControl(id, "Checkbox",		0, 1, 	"util.automagic.autoclosemerchant", "Auto Merchant Window Close(Power user feature READ HELP)")
			
		gui:AddHelp(id, "what is AutoMagic?",
			"What is AutoMagic?",
			"Mail GUI: This enables the mail interface that allows for auto-loading items into the sendmail window based on BTM Rules.\n\n"..
		"\n")
		gui:AddControl(id, "Header",     0,    libName.." GUI options")
		gui:AddControl(id, "Checkbox",		0, 1, 	"util.automagic.showmailgui", "Enable Mail GUI for addition mail features")
end


function lib.merchantShow()
	if (get("util.automagic.autovendor")) then 
		lib.doVendorSell()
		if (get("util.automagic.autoclosemerchant")) then 
			print("AutoMagic has closed the merchant window for you, to disable you must change this options in the settings.") 
			CloseMerchant()	
		end
	end
end


function lib.merchantClosed()
	--Place holder: Is fired when the merchant window is closed.
end

function lib.doScanAndUse(bag,bagType,amBTMRule)	
	if amBTMRule == nil then 
		print("AutoMagic:Debug: How did you get this message? amBTMRule is nil... please report") 
		return
	end

	for slot=1,GetContainerNumSlots(bag) do
		if (GetContainerItemLink(bag,slot)) then
			local _,itemCount = GetContainerItemInfo(bag,slot)
			local itemLink = GetContainerItemLink(bag,slot)
			local _, itemID, _, _, _, _ = decode(itemLink)
			local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink) 
			if amBTMRule == "demats" then	
				if isDEMats[ itemID ] then
					print("AutoMagic has loaded", itemName, " because it is a mat used for enchanting.")
					UseContainerItem(bag, slot) 
				end
			end
			if amBTMRule == "vendor" then
				if (get("util.automagic.autosellgrey")) then  
					if itemRarity == 0 then
						UseContainerItem(bag, slot)
						print("AutoMagic has sold", itemName," due to item being grey")
					end			
				end 			
			end
			
			if BtmScan then
				local reason, bids
				local id, suffix, enchant, seed = BtmScan.BreakLink(itemLink)
				local sig = ("%d:%d:%d"):format(id, suffix, enchant)
				local bidlist = BtmScan.Settings.GetSetting("bid.list")
				
				if (bidlist) then
					bids = bidlist[sig..":"..seed.."x"..itemCount]
					if amBTMRule == "vendor" then
						if(bids and bids[1] and bids[1] == "vendor") then 
							print("AutoMagic has sold", itemName, " due to vendor btm status")		
							UseContainerItem(bag, slot) 
						end 
					end
		
					if amBTMRule == "disenchant" then	
						if(bids and bids[1] and bids[1] == "disenchant") then 
							print("AutoMagic has loaded", itemName, " due to disenchant btm status")
							UseContainerItem(bag, slot) 
						end 
					end
				
					if amBTMRule == "prospect" then
						if(bids and bids[1] and bids[1] == "prospect") then 
							print("AutoMagic has loaded", itemName, " due to prospect btm status")
							UseContainerItem(bag, slot) 
						end 
					end
				end
			end
		end
	end
end


-- The next few functions just set the bid/list reason check for the scan function depending one why we are using it.		
function lib.doVendorSell()
	for bag=0,4 do
		lib.doScanAndUse(bag,"Bags","vendor")
	end
end
function lib.doMailDE()
	MailFrameTab_OnClick(2)
	for bag=0,4 do
		lib.doScanAndUse(bag,"Bags","disenchant") 
	end
end
function lib.doMailProspect()
	MailFrameTab_OnClick(2)
	for bag=0,4 do
		lib.doScanAndUse(bag,"Bags","prospect")
	end
end

function lib.doMailDEMats()
	MailFrameTab_OnClick(2)
	for bag=0,4 do
		lib.doScanAndUse(bag,"Bags","demats")
	end	
end

function lib.mailShow()
	if (get("util.automagic.showmailgui")) then 
		lib.mailGUI()
	end
end

--Fires on mail box closed event & hides mailgui
function lib.mailClosed()
	lib.makeMailGUI()
	amgui:Hide()
end

--Function is called from lib.mailShow()
function lib.mailGUI()
	lib.makeMailGUI()
	amgui:Show()
end


--Make mail GUI
function lib.makeMailGUI()
	-- Set frame visuals
	-- [name of frame]:SetPoint("[relative to point on my frame]","[frame we want to be relative to]","[point on relative frame]",-left/+right, -down/+up)
	amgui:SetPoint("BOTTOMLEFT", "SendMailFrame", "BOTTOMRIGHT", -25, 70)
	amgui:SetFrameStrata("DIALOG")
	amgui:SetHeight(90)
	amgui:SetWidth(220)
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
	

	--local mguimailfor, mguiheader, mguibtmrules
	-- Text Header
	mguiheader = amgui:CreateFontString(one, "OVERLAY", "NumberFontNormalYellow")
	mguiheader:SetText("AutoMagic: Mail GUI")
	mguiheader:SetJustifyH("CENTER")
	mguiheader:SetWidth(200)
	mguiheader:SetHeight(10)
	mguiheader:SetPoint("TOPLEFT",  amgui, "TOPLEFT", 0, 0)
	mguiheader:SetPoint("TOPRIGHT", amgui, "TOPRIGHT", 0, 0)
	amgui.mguiheader = mguiheader
	
	-- [name of frame]:SetPoint("[relative to point on my frame]","[frame we want to be relative to]","[point on relative frame]",-left/+right, -down/+up)
	--Make buttons -- Need slightly longer buttons or get text overlays worked out to better describe function
	-- LEFT COLUMN

	
	amgui.loadprospect = CreateFrame("Button", "", amgui, "OptionsButtonTemplate")
	amgui.loadprospect:SetText(("Prospect"))
	amgui.loadprospect:SetPoint("BOTTOMLEFT", amgui, "BOTTOMLEFT", 12, 35)
	amgui.loadprospect:SetScript("OnClick", lib.doMailProspect)	
		
	mguibtmrules = amgui:CreateFontString(two, "OVERLAY", "NumberFontNormalYellow")
	mguibtmrules:SetText("Mail by BTM rule")
	mguibtmrules:SetJustifyH("LEFT")
	mguibtmrules:SetWidth(250)
	mguibtmrules:SetHeight(10)
	mguibtmrules:SetPoint("BOTTOMLEFT",  amgui.loadprospect, "TOPLEFT", 0, 0)
	mguibtmrules:SetPoint("BOTTOMRIGHT", amgui.loadprospect, "TOPRIGHT", 0, 0)
	amgui.mguibtmrules = mguibtmrules
	
	amgui.loadde = CreateFrame("Button", "", amgui, "OptionsButtonTemplate")
	amgui.loadde:SetText(("Disenchant"))
	amgui.loadde:SetPoint("BOTTOMLEFT", amgui, "BOTTOMLEFT", 12, 12)
	amgui.loadde:SetScript("OnClick", lib.doMailDE)
	

	
	
	--RIGHT COLUMN
	

	
	amgui.loadgems = CreateFrame("Button", "", amgui, "OptionsButtonTemplate")
	amgui.loadgems:SetText(("DE:Mats2"))
	amgui.loadgems:SetPoint("BOTTOMRIGHT", amgui, "BOTTOMRIGHT", -12, 35)
	amgui.loadgems:SetScript("OnClick", lib.doMailDEMats)
	
	mguimailfor = amgui:CreateFontString(three, "OVERLAY", "NumberFontNormalYellow")
	mguimailfor:SetText("Mail")
	mguimailfor:SetJustifyH("RIGHT")
	mguimailfor:SetWidth(220)
	mguimailfor:SetHeight(10)
	mguimailfor:SetPoint("BOTTOMLEFT",  amgui.loadgems, "TOPLEFT", 0, 0)
	mguimailfor:SetPoint("BOTTOMRIGHT", amgui.loadgems, "TOPRIGHT", 0, 0)
	amgui.mguimailfor = mguimailfor
	
	amgui.loaddemats = CreateFrame("Button", "", amgui, "OptionsButtonTemplate")
	amgui.loaddemats:SetText(("DE:Mats1"))
	amgui.loaddemats:SetPoint("BOTTOMRIGHT", amgui, "BOTTOMRIGHT", -12, 12)
	amgui.loaddemats:SetScript("OnClick", lib.doMailDEMats)
end 
	


AucAdvanced.RegisterRevision("$URL$", "$Rev$")



	
