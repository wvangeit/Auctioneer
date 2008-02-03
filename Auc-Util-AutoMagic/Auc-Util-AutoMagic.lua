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
local uiErrorMessage = 0
function lib.GetName()
	return libName
end
local ammailgui = CreateFrame("Frame", "", UIParent)
ammailgui:Hide()
local amautosellgui = CreateFrame("Frame", "", UIParent)
amautosellgui:Hide()

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

autoSellList ={}
--default("util.automagic.table", {})

function lib.displayMyAutoSellList()
	print("--------------------Auto Magic--------------------")
	print("The following information is in your Auto Sell db and will be sold if in your bags and you visit a merchant (if auto sell is enabled)")
	for itemID, itemName in pairs(autoSellList) do
		print(itemName,"itemID: ", itemID)
	end
	print("--------------------Auto Magic--------------------")
end


function lib.autoSellListClear()
	print("--------------------Auto Magic--------------------")
	for itemID, itemName in pairs (autoSellList) do
		print(itemName,"itemID: ", itemID, "Removed from the table")
		autoSellList[itemID] = nil
	end
	print("All items you manually added to your Auto Sell list have been deleted!")
	print("--------------------Auto Magic--------------------")
	--amautosellgui:Hide()
	--lib.makeAutoSellGUI()
	--amautosellgui:Show()
end



function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then lib.ProcessTooltip(...) --Called when the tooltip is being drawn.
	elseif (callbackType == "config") then private.SetupConfigGui(...) --Called when you should build your Configator tab.
	elseif (callbackType == "listupdate") then --Called when the AH Browse screen receives an update.
	elseif (callbackType == "configchanged") then --Called when your config options (if Configator) have been changed.
		if (get("util.automagic.autosellgui")) then
			ConfigatorDialog_2:Hide()
			lib.autoSellGUI() 
			set("util.automagic.autosellgui", false) -- Resetting our toggle switch
		end

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
	frame:RegisterEvent("UI_ERROR_MESSAGE");

-- Sets defaults	
	print("AucAdvanced: {{"..libType..":"..libName.."}} loaded!")
	
	default("util.automagic.autovendor", false) -- DO NOT SET TRUE ALL AUTOMAGIC OPTIONS SHOULD BE TURNED ON MANUALLY BY END USER!!!!!!!
	default("util.automagic.autosellgrey", false)
	default("util.automagic.autocloseenable", false)
	default("util.automagic.showmailgui", false)
	default("util.automagic.autosellgui", false) -- Acts as a button and reverts to false anyway
end

	-- define what event fires what function
	function lib.onEventDo(this, event)
		if event == 'MERCHANT_SHOW' 		then lib.merchantShow() 		end
		if event == "MERCHANT_CLOSED" 	then lib.merchantClosed() 		end
		if event == 'MAIL_SHOW' 			then lib.mailShow() 			end  
		if event == "MAIL_CLOSED" 		then lib.mailClosed() 			end
		if event == "UI_ERROR_MESSAGE" 	then uiErrorMessage = 1 		end
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
		gui:AddControl(id, "Checkbox",     0, 1, "util.automagic.autosellgui", "Check the box to view the Auto-Sell configuration GUI")
			
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
	
	if uiErrorMessage == 1 then return end   -- Return if ui error msg event is fired.
	
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
			if amBTMRule == "gems" then	
				if isGem[ itemID ] then
					print("AutoMagic has loaded", itemName, " because it is a mat used for enchanting.")
					UseContainerItem(bag, slot) 
				end
			end
			if amBTMRule == "vendor" then
				if autoSellList[ itemID ] then 
					print("AutoMagic is selling", itemName," due to being it your custom auto sell list!")
					UseContainerItem(bag, slot)
				elseif (get("util.automagic.autosellgrey")) then  
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
	uiErrorMessage = 0
	for bag=0,4 do
		lib.doScanAndUse(bag,"Bags","vendor")
	end
end
function lib.doMailDE()
	uiErrorMessage = 0
	MailFrameTab_OnClick(2)
	for bag=0,4 do
		lib.doScanAndUse(bag,"Bags","disenchant") 
	end
end
function lib.doMailProspect()
	uiErrorMessage = 0
	MailFrameTab_OnClick(2)
	for bag=0,4 do
		lib.doScanAndUse(bag,"Bags","prospect")
	end
end

function lib.doMailGems()
	uiErrorMessage = 0
	MailFrameTab_OnClick(2)
	for bag=0,4 do
		lib.doScanAndUse(bag,"Bags","gems")
	end	
end

function lib.doMailDEMats()
	uiErrorMessage = 0
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

function lib.mailClosed() --Fires on mail box closed event & hides mailgui
	lib.makeMailGUI()
	ammailgui:Hide()
end

function lib.mailGUI() --Function is called from lib.mailShow()
	lib.makeMailGUI()
	ammailgui:Show()
end

function lib.autoSellGUI() 
	lib.makeAutoSellGUI()
	amautosellgui:Show()
end

function lib.closeAutoSellGUI()
	amautosellgui:Hide()
end

--Make mail GUI
function lib.makeMailGUI()
	-- Set frame visuals
	-- [name of frame]:SetPoint("[relative to point on my frame]","[frame we want to be relative to]","[point on relative frame]",-left/+right, -down/+up)
	ammailgui:SetPoint("BOTTOMLEFT", "SendMailFrame", "BOTTOMRIGHT", -25, 70)
	ammailgui:SetFrameStrata("DIALOG")
	ammailgui:SetHeight(90)
	ammailgui:SetWidth(220)
	ammailgui:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 9, right = 9, top = 9, bottom = 9 }
	})
	ammailgui:SetBackdropColor(0,0,0, 0.8)
	ammailgui:EnableMouse(true)
	ammailgui:SetMovable(true)
	
	-- Make highlightable drag bar
	ammailgui.Drag = CreateFrame("Button", "", ammailgui)
	ammailgui.Drag:SetPoint("TOPLEFT", ammailgui, "TOPLEFT", 10,-5)
	ammailgui.Drag:SetPoint("TOPRIGHT", ammailgui, "TOPRIGHT", -10,-5)
	ammailgui.Drag:SetHeight(6)
	ammailgui.Drag:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
	ammailgui.Drag:SetScript("OnMouseDown", function() ammailgui:StartMoving() end)
	ammailgui.Drag:SetScript("OnMouseUp", function() ammailgui:StopMovingOrSizing() end)
	

	--local mguimailfor, mguiheader, mguibtmrules
	-- Text Header
	local	mguiheader = ammailgui:CreateFontString(one, "OVERLAY", "NumberFontNormalYellow")
	mguiheader:SetText("AutoMagic: Mail Loader")
	mguiheader:SetJustifyH("CENTER")
	mguiheader:SetWidth(200)
	mguiheader:SetHeight(10)
	mguiheader:SetPoint("TOPLEFT",  ammailgui, "TOPLEFT", 0, 0)
	mguiheader:SetPoint("TOPRIGHT", ammailgui, "TOPRIGHT", 0, 0)
	ammailgui.mguiheader = mguiheader
	
	-- [name of frame]:SetPoint("[relative to point on my frame]","[frame we want to be relative to]","[point on relative frame]",-left/+right, -down/+up)
	--Make buttons -- Need slightly longer buttons or get text overlays worked out to better describe function
	
	
	-- LEFT COLUMN

	
	ammailgui.loadprospect = CreateFrame("Button", "", ammailgui, "OptionsButtonTemplate")
	ammailgui.loadprospect:SetText(("Prospect"))
	ammailgui.loadprospect:SetPoint("BOTTOMLEFT", ammailgui, "BOTTOMLEFT", 12, 35)
	ammailgui.loadprospect:SetScript("OnClick", lib.doMailProspect)	
		
	local	mguibtmrules = ammailgui:CreateFontString(two, "OVERLAY", "NumberFontNormalYellow")
	mguibtmrules:SetText("BTM Rule:")
	mguibtmrules:SetJustifyH("LEFT")
	mguibtmrules:SetWidth(250)
	mguibtmrules:SetHeight(10)
	mguibtmrules:SetPoint("BOTTOMLEFT",  ammailgui.loadprospect, "TOPLEFT", 0, 0)
	mguibtmrules:SetPoint("BOTTOMRIGHT", ammailgui.loadprospect, "TOPRIGHT", 0, 0)
	ammailgui.mguibtmrules = mguibtmrules
	
	ammailgui.loadde = CreateFrame("Button", "", ammailgui, "OptionsButtonTemplate")
	ammailgui.loadde:SetText(("Disenchant"))
	ammailgui.loadde:SetPoint("BOTTOMLEFT", ammailgui, "BOTTOMLEFT", 12, 12)
	ammailgui.loadde:SetScript("OnClick", lib.doMailDE)
	

	
	
	--RIGHT COLUMN
	

	
	ammailgui.loadgems = CreateFrame("Button", "", ammailgui, "OptionsButtonTemplate")
	ammailgui.loadgems:SetText(("Gems"))
	ammailgui.loadgems:SetPoint("BOTTOMRIGHT", ammailgui, "BOTTOMRIGHT", -12, 35)
	ammailgui.loadgems:SetScript("OnClick", lib.doMailGems)
	
	local	mguimailfor = ammailgui:CreateFontString(three, "OVERLAY", "NumberFontNormalYellow")
	mguimailfor:SetText("Other:")
	mguimailfor:SetJustifyH("RIGHT")
	mguimailfor:SetWidth(220)
	mguimailfor:SetHeight(10)
	mguimailfor:SetPoint("BOTTOMLEFT",  ammailgui.loadgems, "TOPLEFT", 0, 0)
	mguimailfor:SetPoint("BOTTOMRIGHT", ammailgui.loadgems, "TOPRIGHT", 0, 0)
	ammailgui.mguimailfor = mguimailfor
	
	ammailgui.loaddemats = CreateFrame("Button", "", ammailgui, "OptionsButtonTemplate")
	ammailgui.loaddemats:SetText(("Chant Mats"))
	ammailgui.loaddemats:SetPoint("BOTTOMRIGHT", ammailgui, "BOTTOMRIGHT", -12, 12)
	ammailgui.loaddemats:SetScript("OnClick", lib.doMailDEMats)
end 
	
local amautoselladjustiframeh = 97
local amautoselladjustiframew = 200

function lib.makeAutoSellGUI()
--	local totalsells = 0
--	for k, v in pairs(autoSellList) do
--		totalsells = totalsells + 1
--	end
--	local amautosellguiheightadjust = totalsells * 5
--	amautoselladjustiframeh = amautoselladjustiframeh + amautosellguiheightadjust
		
	-- Set frame visuals
	-- [name of frame]:SetPoint("[relative to point on my frame]","[frame we want to be relative to]","[point on relative frame]",-left/+right, -down/+up)
	amautosellgui:SetPoint("BOTTOMLEFT", "SendMailFrame", "BOTTOMRIGHT", 12, 12)
	amautosellgui:SetFrameStrata("DIALOG")
	amautosellgui:SetHeight(amautoselladjustiframeh)
	amautosellgui:SetWidth(amautoselladjustiframew)
	amautosellgui:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 9, right = 9, top = 9, bottom = 9 }
	})
	amautosellgui:SetBackdropColor(0,0,0, 0.8)
	amautosellgui:EnableMouse(true)
	amautosellgui:SetMovable(true)
	
	-- Make highlightable drag ar
	amautosellgui.Drag = CreateFrame("Button", "amautoselldragslot", amautosellgui)
	amautosellgui.Drag:SetPoint("TOPLEFT", amautosellgui, "TOPLEFT", 10,-5)
	amautosellgui.Drag:SetPoint("TOPRIGHT", amautosellgui, "TOPRIGHT", -10,-5)
	amautosellgui.Drag:SetHeight(6)
	amautosellgui.Drag:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
	amautosellgui.Drag:SetScript("OnMouseDown", function() amautosellgui:StartMoving() end)
	amautosellgui.Drag:SetScript("OnMouseUp", function() amautosellgui:StopMovingOrSizing() end)
	
	-- Text Header
	local	amautosellguiheader = amautosellgui:CreateFontString(one, "OVERLAY", "NumberFontNormalYellow")
	amautosellguiheader:SetText("AutoMagic: Auto Sell Config")
	amautosellguiheader:SetJustifyH("CENTER")
	amautosellguiheader:SetWidth(300)
	amautosellguiheader:SetHeight(10)
	amautosellguiheader:SetPoint("TOPLEFT",  amautosellgui, "TOPLEFT", 0, 5)
	amautosellguiheader:SetPoint("TOPRIGHT", amautosellgui, "TOPRIGHT", 0, 0)
	amautosellgui.amautosellguiheader = amautosellguiheader
	
	-- [name of frame]:SetPoint("[relative to point on my frame]","[frame we want to be relative to]","[point on relative frame]",-left/+right, -down/+up)
	--Make buttons -- Need slightly longer buttons or get text overlays worked out to better describe function
	
	amautosellgui.done = CreateFrame("Button", "", amautosellgui, "OptionsButtonTemplate")
	amautosellgui.done:SetText(("Close"))
	amautosellgui.done:SetPoint("BOTTOMRIGHT", amautosellgui, "BOTTOMRIGHT", -12, 12)
	amautosellgui.done:SetScript("OnClick", lib.closeAutoSellGUI)	

	amautosellgui.displayautoselllist = CreateFrame("Button", "", amautosellgui, "OptionsButtonTemplate")
	amautosellgui.displayautoselllist:SetText(("Auto Sell List"))
	amautosellgui.displayautoselllist:SetPoint("TOPRIGHT", amautosellgui, "TOPRIGHT", -12, -12)
	amautosellgui.displayautoselllist:SetScript("OnClick", lib.displayMyAutoSellList)

	amautosellgui.displayautoselllistclear = CreateFrame("Button", "", amautosellgui, "OptionsButtonTemplate")
	amautosellgui.displayautoselllistclear:SetText(("Reset AutoSell"))
	amautosellgui.displayautoselllistclear:SetPoint("TOPRIGHT", amautosellgui.displayautoselllist, "BOTTOMRIGHT", 0, -5)
	amautosellgui.displayautoselllistclear:SetScript("OnClick", lib.autoSellListClear)	
	
	function lib.GetItemByLink(link)
		local sig
		local itype, id, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(link)
		assert(itype and itype == "item", "Item must be a valid link")
			if enchant ~= 0 then
			sig = ("%d:%d:%d:%d"):format(id, suffix, factor, enchant)
		elseif factor ~= 0 then
			sig = ("%d:%d:%d"):format(id, suffix, factor)
		elseif suffix ~= 0 then
			sig = ("%d:%d"):format(id, suffix)
		else
			sig = tostring(id)
		end
	end
	function lib.amautosellguidraggedin()
		local objtype, _, itemlink = GetCursorInfo()
		ClearCursor()
		if objtype == "item" then
			lib.GetItemByLink(itemlink)
		end
		print(itemlink, " draged into box!")
		local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemlink) 
		local _, itemID, _, _, _, _ = decode(itemlink)
		print( "Added ID ",itemID," | ",itemName," to the Auto Sell db")		
		autoSellList[itemID] = itemName
	--	amautosellgui:Hide()
	--	lib.makeAutoSellGUI()
	--	amautosellgui:Show()
	end

	-- drag item to slot 
	amautosellgui.item = CreateFrame("Button", "", amautosellgui)
	amautosellgui.item:SetNormalTexture("Interface\\Buttons\\UI-Slot-Background")
	amautosellgui.item:SetPoint("TOPLEFT", amautosellgui, "TOPLEFT", 35, -35)
	amautosellgui.item:SetHeight(37)
	amautosellgui.item:SetWidth(37)
	amautosellgui.item:SetScript("OnClick", lib.amautosellguidraggedin)
	amautosellgui.item:SetScript("OnReceiveDrag", lib.amautosellguidraggedin)	
	
--[[		-- Set defaults for the following for ... do loop
		local amautosellleftright = -15; local amautosellupdown = -5; local amautosellleftright2 = amautosellleftright; local amautosellupdown2 = amautosellupdown; local amautoselltestwidth = 0; local amautosellloopcount = 1; local newwidth = 0
		-- This loop prints out items in the auto sell list, tests the size of the string and makes the gui wider if it won't if.
		for itemIDS, itemName in pairs(autoSellList) do
			local amautosellguitextloop = amautosellgui:CreateFontString("testtext"..itemIDS, "OVERLAY", "NumberFontNormalYellow")
			
			if (amautosellloopcount == 1) then
				amautosellguitextloop:SetPoint("TOPLEFT", amautosellgui.item, "BOTTOMLEFT", amautosellleftright, amautosellupdown)
			else
				amautosellguitextloop:SetPoint("TOPLEFT", amautosellgui.item, "BOTTOMLEFT", amautosellleftright2, amautosellupdown2)
			end
			
		--	function dothis()
		--	print("do this")
		--	end
			
			amautosellguitextloop:SetWidth(350)
			amautosellguitextloop:SetJustifyH("LEFT")
			amautosellguitextloop:SetText(itemName)
			--amautosellguitextloop:SetScript("OnClick", dothis)
			amautoselltestwidth = amautosellguitextloop:GetStringWidth();
			
			if (amautoselladjustiframew - 40 < amautoselltestwidth) then  
				newwidth = amautoselltestwidth +40
				amautoselladjustiframew = newwidth
				amautosellgui:Hide()
				lib.makeAutoSellGUI()
				amautosellgui:Show()
			end 
			amautosellupdown2 = amautosellupdown2 -13			
			amautosellloopcount = amautosellloopcount + 1
			
			amautosellleftright2 = amautosellleftright2

		end]]
end 

AucAdvanced.RegisterRevision("$URL$", "$Rev$")



	
