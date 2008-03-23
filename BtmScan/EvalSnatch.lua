--[[
	BottomScanner - An AddOn for WoW to alert you to good purchases as they appear on the AH
	Version: <%version%> (<%codename%>)
	Revision: $Id$
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

-- If auctioneer is not loaded, then we cannot run.
if not (AucAdvanced or (Auctioneer and Auctioneer.Statistic)) then return end

local libName = "Snatch"
local lcName = libName:lower()
local lib = { name = lcName, propername = libName }
table.insert(BtmScan.evaluators, lcName)
local define = BtmScan.Settings.SetDefault
local get = BtmScan.Settings.GetSetting
local set = BtmScan.Settings.SetSetting
local translate = BtmScan.Locales.Translate


BtmScan.evaluators[lcName] = lib

function lib:valuate(item, tooltip)
	local price = 0

	-- If we're not enabled, scadaddle!
	if (not get(lcName..".enable")) then return end

	if ((not item.itemconfig.buyBelow) or item.itemconfig.buyBelow==0) then return end

	local value = item.itemconfig.buyBelow * item.count

	-- If the current purchase price is more than our valuation,
	-- another module "wins" this purchase.
	if (value < item.purchase) then return end

	-- Check to see what the most we can pay for this item is.
	if (item.canbuy and get(lcName..".allow.buy") and item.buy < value) then
		price = item.buy
	elseif (item.canbid and get(lcName..".allow.bid") and item.bid < value) then
		price = item.bid
	end

	item.purchase = price
	item.reason = self.name
	item.what = self.name
	item.profit = value-price
	item.valuation = value
end

function lib.PrintHelp()
	BtmScan.Print("/btm snatch")
	BtmScan.Print("/btm snatch [ItemLink] maxPrice")
	BtmScan.Print("/btm snatch list")
end

function lib.AddSnatch(itemlink, price, count)	-- give price=(0 or nil) to stop snatching
	local itemid, itemsuffix, itemenchant, itemseed = BtmScan.BreakLink(itemlink)
	local itemsig = (":"):join(itemid, itemsuffix, itemenchant)
	local itemconfig = BtmScan.getItemConfig(itemsig)
	
	if price and price<=0 then
		price=nil
	end
	if count and count<=0 then
		count=nil
	end
	
	itemconfig.buyBelow = price
	itemconfig.maxCount = count
	
	if not price then
		BtmScan.Print(translate("BottomScanner will now %1 %2", translate("not snatch"), itemlink))
		BtmScan.storeItemConfig(itemconfig, itemsig)
		return
	end

	local _,_,_,_,_,_,_,stack = GetItemInfo(itemid)
	if (not stack) then
		stack = 1
	end

	local stackText = ""
	if (stack > 1) then
		stackText = " ("..translate("%1 per %2 stack", BtmScan.GSC(price*stack, 1), stack)..")"
	end
	local countText =""
	if count then
		countText = translate("up to %1", count).." "
	else
		countText = translate("unlimited").." "
	end

	BtmScan.Print(translate("BottomScanner will now %1 %2", translate("snatch"), countText..translate("%1 at %2", itemlink, translate("%1 per unit", BtmScan.GSC(price, 1)))..stackText))
	BtmScan.storeItemConfig(itemconfig, itemsig)
end

function lib.CommandHandler(msg)
	-- BtmScan.Print("called snatch-handler: "..msg)
	if (string.lower(msg) == "snatch") then 
		lib.snatchGUI()
		return
	end
	if (string.lower(msg) == "snatch list") then 
		lib.PrintList()
		return
	end
	local i,j, ocmd, oparam = string.find(msg, "^([^ ]+) (.*)$")
	local i,j, cmd, param = string.find(string.lower(msg), "^([^ ]+) (.*)$")
	if (not i) then cmd = msg param = nil oparam = nil end
	if (oparam == "") then param = nil oparam = nil end


	if (oparam) then
		local des, count, price, itemid,itemrand,itemlink, remain = BtmScan.ItemDes(oparam)
		if (not des) then
			BtmScan.Print(translate("Unable to understand command. Please see /btm help"))
			return
		end

		if (price <= 0) then
			price = BtmScan.ParseGSC(remain) or 0
		end

		lib.AddSnatch(itemlink, price, count)
	end

end

function lib.PrintList()
	local itemConfigTable = get("itemconfig.list")
	local itemConfig = {}
	for itemkey, itemConfigString in pairs(itemConfigTable) do
		BtmScan.unpackItemConfiguration(itemConfigString, itemConfig)
		if itemConfig.buyBelow and itemConfig.buyBelow > 0 then
			local itemID, itemsuffix, itemenchant = strsplit(":", itemkey)
			itemkey = strjoin(":", "item", itemID, itemenchant, 0, 0, 0, 0, itemsuffix)
			local _, itemlink = GetItemInfo(itemkey)
			if not itemlink then
				itemlink="(Uncached item "..itemkey..")"
			end
			if itemConfig.maxCount and itemConfig.maxCount>0 then
				BtmScan.Print(itemlink.."  "..BtmScan.GSC(itemConfig.buyBelow, 1).." (<="..itemConfig.maxCount..")")
			else
				BtmScan.Print(itemlink.."  "..BtmScan.GSC(itemConfig.buyBelow, 1))
			end
		end
	end
end

define(lcName..'.enable', true)
define(lcName..'.allow.bid', true)
define(lcName..'.allow.buy', true)
function lib:setup(gui)
	local id = gui:AddTab(libName)
	
	gui:AddHelp(id, "what snatch evaluator",
		"What is the snatch evaluator?",
		"This evaluator allows you to purchase items you want, based on criteria you specify.\n\n"..
		""..
		"Unfortunately, for right now, you must use slash commands in order to specify the items to purchase.\n\n"..
		""..
		"Please see /btm snatch help for more information.\n")
	
	gui:AddControl(id, "Subhead",          0,    libName.." Settings")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".enable", "Enable purchasing for "..lcName)
	gui:AddControl(id, "Checkbox",         0, 2, lcName..".allow.buy", "Allow buyout on items")
	gui:AddControl(id, "Checkbox",         0, 2, lcName..".allow.bid", "Allow bid on items")
end

--[[ Everything below this point belongs to the snatch ui
 the ui has not modified any of the original snatch code 
 except adding the command handler]]

local snatchconfigframe = CreateFrame("Frame", "snatchframe", UIParent)
snatchconfigframe:Hide()	
local print = BtmScan.Print
local SelectBox = LibStub:GetLibrary("SelectBox")
local ScrollSheet = LibStub:GetLibrary("ScrollSheet")
local workingItemLink

local tmpItemConfig={}
function lib.SetWorkingItem(link)
	snatchconfigframe.ClearWorkingItem()
	if type(link)~="string" then return false end
	local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(link)
	if not name or not texture then return false end
	workingItemLink = link
	
	snatchconfigframe.workingname:SetText(link)
	snatchconfigframe.icon.tx:SetTexture(texture)
	snatchconfigframe.icon.tx:Show()
	snatchconfigframe.additem:Show()
	
	
	BtmScan.getItemConfig(format("%d:%d:%d", BtmScan.BreakLink(link)),  tmpItemConfig)
	if tmpItemConfig.buyBelow then
		local g,s,c = BtmScan.GetGSC(tmpItemConfig.buyBelow)
		snatchconfigframe.gold:SetText(g)
		snatchconfigframe.silver:SetText(s)
		snatchconfigframe.copper:SetText(c)
		snatchconfigframe.additem:SetText("Update")
		snatchconfigframe.removeitem:Show()
	else
		snatchconfigframe.gold:SetText("")
		snatchconfigframe.silver:SetText("")
		snatchconfigframe.copper:SetText("")
		snatchconfigframe.additem:SetText("Add Item")
		snatchconfigframe.removeitem:Hide()
		
	end
	
	return true
end

local snatch = {}

function lib.populateSnatchSheet()
	local itemConfigTable = get("itemconfig.list")
	
	local display = {}
	
	local appraiser = AucAdvanced and AucAdvanced.Modules.Util.Appraiser
	
	local itemConfig = {}
	for sig, itemConfigString in pairs(itemConfigTable) do
		BtmScan.unpackItemConfiguration(itemConfigString, itemConfig)
		if itemConfig.buyBelow and itemConfig.buyBelow>0 then
			local itemID, itemsuffix, itemenchant = strsplit(':', sig)
			local itemString = strjoin(":", "item", itemID, itemenchant, 0, 0, 0, 0, itemsuffix)
			local _, itemlink = GetItemInfo(itemString)
			
			if not appraiser then
				table.insert(display,{
					itemlink,
					itemConfig.buyBelow,
				}) 
			else
				local abid, abuy = appraiser.GetPrice(itemlink, nil, true)
				table.insert(display,{
					itemlink,
					itemConfig.buyBelow,
					tonumber(abuy) or tonumber(abid) --Appraisers buyout value
				}) 
			end
		end
	end
		
	snatchconfigframe.snatchlist.sheet:SetData(display)
end 


function lib.snatchListClear()
	local itemConfig = {}
	for sig, itemConfigString in pairs(itemConfigTable) do
		BtmScan.unpackItemConfiguration(itemConfigString, itemConfig)
		if itemConfig.buyBelow then
			itemConfig.buyBelow = nil
			itemConfig.maxCount = nil
			 BtmScan.storeItemConfig(itemConfig, sig)
		end
	end
			
	lib.populateSnatchSheet()
end




function snatchconfigframe.removeitemfromlist()
	lib.AddSnatch(workingItemLink, nil)
	snatchconfigframe.ClearWorkingItem()
	lib.populateSnatchSheet()
end

function snatchconfigframe.snatchadditemtolist()
	local g = tonumber(snatchconfigframe.gold:GetText()) or 0
	local s = tonumber(snatchconfigframe.silver:GetText()) or 0
	local c = tonumber(snatchconfigframe.copper:GetText()) or 0
	
	lib.AddSnatch(workingItemLink, g*10000 + s*100 + c)
	snatchconfigframe.ClearWorkingItem()
	lib.populateSnatchSheet()	
end

function snatch.OnSnatchEnter(button, row, index)
	if snatchconfigframe.snatchlist.sheet.rows[row][index]:IsShown()then --Hide tooltip for hidden cells
		local link = snatchconfigframe.snatchlist.sheet.rows[row][index]:GetText() or "FAILED LINK"
		local name = GetItemInfo(link)
		if link and name then
			GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(link)
			if (EnhTooltip) then 
				EnhTooltip.TooltipCall(GameTooltip, name, link, -1, 1) 
			end
		end
	end		
end

function snatch.OnBagListEnter(button, row, index)
	if snatchconfigframe.baglist.sheet.rows[row][index]:IsShown() then --Hide tooltip for hidden cells
		local link = snatchconfigframe.baglist.sheet.rows[row][index]:GetText()
		local name = GetItemInfo(link)
		if link and name then
			GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(link)
			if (EnhTooltip) then 
				EnhTooltip.TooltipCall(GameTooltip, name, link, -1, 1) 
			end
		end
	end		
end

function snatch.OnLeave(button, row, index)
	GameTooltip:Hide()
end


function snatch.OnClickSnatchList(button, row, index)
	local link = snatchconfigframe.snatchlist.sheet.rows[row][1]:GetText()
	lib.SetWorkingItem(link)
end	

function snatch.OnClickBagList(button, row, index)
	local link = snatchconfigframe.baglist.sheet.rows[row][1]:GetText()
	lib.SetWorkingItem(link)
end	


function snatchconfigframe.ClearWorkingItem()
	snatchconfigframe.workingname:SetText("")
	snatchconfigframe.icon.tx:Hide()
	snatchconfigframe.additem:Hide()
	snatchconfigframe.removeitem:Hide()
	snatchconfigframe.gold:SetText("")
	snatchconfigframe.silver:SetText("")
	snatchconfigframe.copper:SetText("")
end

function snatchconfigframe.IconClicked()
	snatchconfigframe.ClearWorkingItem()
end 

function lib.snatchIconDrag()
	local objtype, _, itemlink = GetCursorInfo()
	if objtype == "item" then
		ClearCursor()
		lib.SetWorkingItem(itemlink)
	end
end

function lib.ClickLinkHook(_, _, _, link, button)
	if link and snatchconfigframe:IsVisible() then
		if (button == "LeftButton") then --and (IsAltKeyDown()) and itemName then -- Commented mod key, I want to catch any item clicked.
			lib.SetWorkingItem(link)
		end
	end
end

function lib.populateBagSheet()
	
	local unique={}
	local bagcontents = {}
	local appraiser = AucAdvanced and AucAdvanced.Modules.Util.Appraiser
	
	for bag=0,NUM_BAG_SLOTS do
		for slot=1,GetContainerNumSlots(bag) do
			local itemLink = GetContainerItemLink(bag,slot)
			if itemLink then
				local itemid, suffix, enchant, seed = BtmScan.BreakLink(itemLink)
				local sig = ("%d:%d"):format(itemid,suffix)
				if not unique[sig] then
					unique[sig]=true
					local _,itemCount = GetContainerItemInfo(bag,slot)
					local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink)
					local btmRule = ""
					
					local bidlist = get("bid.list")
					if (bidlist) then
						local bids = bidlist[("%d:%d:%d:%dx%d"):format(itemid,suffix,enchant,seed,itemCount)]
						if(bids and bids[1]) then 
							btmRule = bids[1]
						end 
					end
					
					if not appraiser then
						tinsert(bagcontents, {
							itemLink,
							btmRule
						})
					else
						local abid,abuy = appraiser.GetPrice(itemLink, nil, true)
						tinsert(bagcontents, {
							itemLink,
							tonumber(abuy) or tonumber(abid),
							btmRule
						})
					end
				end
			end
		end
	end
	
	snatchconfigframe.baglist.sheet:SetData(bagcontents) --Set the GUI scrollsheet
	lib.populateSnatchSheet()
end

function lib.snatchGUI() 
	if (snatchconfigframe:IsVisible()) then lib.closeSnatchGUI() end
	Stubby.RegisterFunctionHook("ChatFrame_OnHyperlinkShow", -50, lib.ClickLinkHook)
	snatchconfigframe:Show()
	lib.populateBagSheet()
	snatchconfigframe.ClearWorkingItem()
end

function lib.closeSnatchGUI()
	snatchconfigframe:Hide()
	Stubby.UnregisterFunctionHook("ChatFrame_OnHyperlinkShow", lib.ClickLinkHook)
end

function lib.makesnatchgui()
	snatchconfigframe:SetToplevel(true)
	snatchconfigframe:SetFrameStrata("HIGH")
	snatchconfigframe:SetBackdrop({
		bgFile = "Interface/Tooltips/ChatBubble-Background",
		edgeFile = "Interface/Tooltips/ChatBubble-BackDrop",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 32, right = 32, top = 32, bottom = 32 }
	})
	snatchconfigframe:SetBackdropColor(0,0,0, 1)
	snatchconfigframe:Hide()
	
	snatchconfigframe:SetPoint("CENTER", UIParent, "CENTER")
	snatchconfigframe:SetWidth(834.5)
	snatchconfigframe:SetHeight(450)
	
	snatchconfigframe:SetMovable(true)
	snatchconfigframe:EnableMouse(true)
	snatchconfigframe.Drag = CreateFrame("Button", nil, snatchconfigframe)
	snatchconfigframe.Drag:SetPoint("TOPLEFT", snatchconfigframe, "TOPLEFT", 10,-5)
	snatchconfigframe.Drag:SetPoint("TOPRIGHT", snatchconfigframe, "TOPRIGHT", -10,-5)
	snatchconfigframe.Drag:SetHeight(6)
	snatchconfigframe.Drag:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")

	snatchconfigframe.Drag:SetScript("OnMouseDown", function() snatchconfigframe:StartMoving() end)
	snatchconfigframe.Drag:SetScript("OnMouseUp", function() snatchconfigframe:StopMovingOrSizing() end)
	
	snatchconfigframe.DragBottom = CreateFrame("Button",nil, snatchconfigframe)
	snatchconfigframe.DragBottom:SetPoint("BOTTOMLEFT", snatchconfigframe, "BOTTOMLEFT", 10,5)
	snatchconfigframe.DragBottom:SetPoint("BOTTOMRIGHT", snatchconfigframe, "BOTTOMRIGHT", -10,5)
	snatchconfigframe.DragBottom:SetHeight(6)
	snatchconfigframe.DragBottom:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")

	snatchconfigframe.DragBottom:SetScript("OnMouseDown", function() snatchconfigframe:StartMoving() end)
	snatchconfigframe.DragBottom:SetScript("OnMouseUp", function() snatchconfigframe:StopMovingOrSizing() end)
	
	--Add Drag slot / Item icon
	snatchconfigframe.slot = snatchconfigframe:CreateTexture(nil, "BORDER")
	snatchconfigframe.slot:SetDrawLayer("Artwork") -- or the border shades it
	snatchconfigframe.slot:SetPoint("TOPLEFT", snatchconfigframe, "TOPLEFT", 23, -75)
	snatchconfigframe.slot:SetWidth(45)
	snatchconfigframe.slot:SetHeight(45)
	snatchconfigframe.slot:SetTexCoord(0.17, 0.83, 0.17, 0.83)
	snatchconfigframe.slot:SetTexture("Interface\\Buttons\\UI-EmptySlot")

	snatchconfigframe.icon = CreateFrame("Button", nil, snatchconfigframe)
	snatchconfigframe.icon:SetPoint("TOPLEFT", snatchconfigframe.slot, "TOPLEFT", 2, -2)
	snatchconfigframe.icon:SetPoint("BOTTOMRIGHT", snatchconfigframe.slot, "BOTTOMRIGHT", -2, 2)
	snatchconfigframe.icon:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp")
	snatchconfigframe.icon:SetScript("OnClick", snatchconfigframe.IconClicked)
	snatchconfigframe.icon:SetScript("OnReceiveDrag", lib.snatchIconDrag)
	snatchconfigframe.icon.tx = snatchconfigframe.icon:CreateTexture()
	snatchconfigframe.icon.tx:SetAllPoints(snatchconfigframe.icon)
	
	
	snatchconfigframe.slot.help = snatchconfigframe:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	snatchconfigframe.slot.help:SetPoint("LEFT", snatchconfigframe.slot, "RIGHT", 2, 7)
	snatchconfigframe.slot.help:SetText(("Drop item into box")) --"Drop item into box to search."
	snatchconfigframe.slot.help:SetWidth(80)
	
	snatchconfigframe.workingname = snatchconfigframe:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	snatchconfigframe.workingname:SetPoint("TOPLEFT", snatchconfigframe, "TOPLEFT", 15, -135)
	snatchconfigframe.workingname:SetWidth(160)
	snatchconfigframe.workingname:SetJustifyH("LEFT")
	
	
	--Add Title text
	local	snatchtitle = snatchconfigframe:CreateFontString(asuftitle, "OVERLAY", "GameFontNormalLarge")
	snatchtitle:SetText("BTM Snatch Configuration")
	snatchtitle:SetJustifyH("CENTER")
	snatchtitle:SetWidth(300)
	snatchtitle:SetHeight(10)
	snatchtitle:SetPoint("TOPLEFT",  snatchconfigframe, "TOPLEFT", 0, -17)
	snatchconfigframe.snatchtitle = snatchtitle
	
	-- Bag List
	snatchconfigframe.baglist = CreateFrame("Frame", nil, snatchconfigframe)
	snatchconfigframe.baglist:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	
	snatchconfigframe.baglist:SetBackdropColor(0, 0, 0.0, 0.5)
	snatchconfigframe.baglist:SetPoint("TOPLEFT", snatchconfigframe, "BOTTOMLEFT", 518, 417.5)
	snatchconfigframe.baglist:SetPoint("TOPRIGHT", snatchconfigframe, "TOPLEFT", 823, 0)
	snatchconfigframe.baglist:SetPoint("BOTTOM", snatchconfigframe, "BOTTOM", 0, 57)
	
	snatchconfigframe.bagscan = CreateFrame("Button", nil, snatchconfigframe, "OptionsButtonTemplate")
	snatchconfigframe.bagscan:SetPoint("TOP", snatchconfigframe.baglist, "BOTTOM", 0, -15)
	snatchconfigframe.bagscan:SetText(("Refresh Data"))
	snatchconfigframe.bagscan:SetScript("OnClick", lib.populateBagSheet)
	
	if not ( AucAdvanced and AucAdvanced.Modules.Util.Appraiser ) then
		snatchconfigframe.baglist.sheet = ScrollSheet:Create(snatchconfigframe.baglist, {
			{ "Bag Contents", "TOOLTIP", 150 }, 
			{ "BTM Rule", "TEXT", 25 }, 
			}, snatch.OnBagListEnter, snatch.OnLeave, snatch.OnClickBagList)
	else
		snatchconfigframe.baglist.sheet = ScrollSheet:Create(snatchconfigframe.baglist, {
			{ "Bag Contents", "TOOLTIP", 150 }, 
			{ "Appraiser", "COIN", 25 }, 
			{ "BTM Rule", "TEXT", 25 }, 
			{ "Test", "INT", -1 },
			}, snatch.OnBagListEnter, snatch.OnLeave, snatch.OnClickBagList)
	end
		
	--Create the snatch list results frame
	snatchconfigframe.snatchlist = CreateFrame("Frame", nil, snatchconfigframe)
	snatchconfigframe.snatchlist:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	
	snatchconfigframe.snatchlist:SetBackdropColor(0, 0, 0.0, 0.5)
	snatchconfigframe.snatchlist:SetPoint("TOPLEFT", snatchconfigframe, "BOTTOMLEFT", 187, 417.5)
	snatchconfigframe.snatchlist:SetPoint("TOPRIGHT", snatchconfigframe, "TOPLEFT", 492, 0)
	snatchconfigframe.snatchlist:SetPoint("BOTTOM", snatchconfigframe, "BOTTOM", 0, 57)
	
	--Add close button
	snatchconfigframe.closeButton = CreateFrame("Button", nil, snatchconfigframe, "OptionsButtonTemplate")
	snatchconfigframe.closeButton:SetPoint("BOTTOMRIGHT", snatchconfigframe, "BOTTOMRIGHT", -10, 10)
	snatchconfigframe.closeButton:SetText(("Close"))
	snatchconfigframe.closeButton:SetScript("OnClick",  lib.closeSnatchGUI)
	
	--Add Item to list button	
	snatchconfigframe.additem = CreateFrame("Button", nil, snatchconfigframe, "OptionsButtonTemplate")
	snatchconfigframe.additem:SetPoint("TOPLEFT", snatchconfigframe, "TOPLEFT", 10, -210)
	snatchconfigframe.additem:SetText(('Add Item'))
	snatchconfigframe.additem:SetScript("OnClick", snatchconfigframe.snatchadditemtolist)
	
	--[[
	snatchconfigframe.additem.help = snatchconfigframe:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	snatchconfigframe.additem.help:SetPoint("TOPLEFT", snatchconfigframe.additem, "TOPRIGHT", 1, 1)
	snatchconfigframe.additem.help:SetText(("(to Snatch list)")) 
	snatchconfigframe.additem.help:SetWidth(90)
	]]
	
	--Add coin boxes
	function lib.goldtosilver()
		snatchconfigframe.gold:ClearFocus()
		snatchconfigframe.silver:SetFocus()
	end
	
	function lib.silvertocopper()
		snatchconfigframe.silver:ClearFocus()
		snatchconfigframe.copper:SetFocus()
	end
	
	function lib.copper()
		snatchconfigframe.copper:ClearFocus()
	end

		
	snatchconfigframe.gold = CreateFrame("EditBox", "snatchgold", snatchconfigframe, "InputBoxTemplate")
	snatchconfigframe.gold:SetPoint("BOTTOMLEFT", snatchconfigframe.additem, "TOPLEFT", 10, 10)
	snatchconfigframe.gold:SetAutoFocus(false)
	snatchconfigframe.gold:SetHeight(15)
	snatchconfigframe.gold:SetWidth(40)
	snatchconfigframe.gold:SetScript("OnEnterPressed", lib.goldtosilver)
	snatchconfigframe.gold:SetScript("OnTabPressed", lib.goldtosilver)
	
	snatchconfigframe.silver = CreateFrame("EditBox", "snatchsilver", snatchconfigframe, "InputBoxTemplate")
	snatchconfigframe.silver:SetPoint("TOPLEFT", snatchconfigframe.gold, "TOPRIGHT", 10, 0)
	snatchconfigframe.silver:SetAutoFocus(false)
	snatchconfigframe.silver:SetHeight(15)
	snatchconfigframe.silver:SetWidth(20)
	snatchconfigframe.silver:SetMaxLetters(2)
	snatchconfigframe.silver:SetScript("OnEnterPressed", lib.silvertocopper)
	snatchconfigframe.silver:SetScript("OnTabPressed", lib.silvertocopper)
	
	snatchconfigframe.copper = CreateFrame("EditBox", "snatchcopper", snatchconfigframe, "InputBoxTemplate")
	snatchconfigframe.copper:SetPoint("TOPLEFT", snatchconfigframe.silver, "TOPRIGHT", 10, 0)
	snatchconfigframe.copper:SetAutoFocus(false)
	snatchconfigframe.copper:SetHeight(15)
	snatchconfigframe.copper:SetWidth(20)
	snatchconfigframe.copper:SetMaxLetters(2)
	snatchconfigframe.copper:SetScript("OnEnterPressed", lib.copper)
	snatchconfigframe.copper:SetScript("OnTabPressed", lib.copper)
	
	--Remove Item from list button	
	snatchconfigframe.removeitem = CreateFrame("Button", nil, snatchconfigframe, "OptionsButtonTemplate")
	snatchconfigframe.removeitem:SetPoint("TOPLEFT", snatchconfigframe.additem, "BOTTOMLEFT", 0, -20)
	snatchconfigframe.removeitem:SetText(('Remove Item'))
	snatchconfigframe.removeitem:SetScript("OnClick", snatchconfigframe.removeitemfromlist)
	
	--[[
	snatchconfigframe.removeitem.help = snatchconfigframe:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	snatchconfigframe.removeitem.help:SetPoint("TOPLEFT",  snatchconfigframe.removeitem, "TOPRIGHT", 1, 1)
	snatchconfigframe.removeitem.help:SetText(("(from Snatch list)")) 
	snatchconfigframe.removeitem.help:SetWidth(90)
	]]
	
	--Reset snatch list
	snatchconfigframe.resetList = CreateFrame("Button", nil, snatchconfigframe, "OptionsButtonTemplate")
	snatchconfigframe.resetList:SetPoint("TOP", snatchconfigframe.snatchlist, "BOTTOM", 0, -15)
	snatchconfigframe.resetList:SetText(("Reset List"))
	snatchconfigframe.resetList:SetScript("OnClick", lib.snatchListClear)
	
	if not ( AucAdvanced and AucAdvanced.Modules.Util.Appraiser ) then
		snatchconfigframe.snatchlist.sheet = ScrollSheet:Create(snatchconfigframe.snatchlist, {
		{ "Snatching", "TOOLTIP", 150 }, 
		{ "Buy at", "COIN", 70 }, 
		}, snatch.OnSnatchEnter, snatch.OnLeave, snatch.OnClickSnatchList)
	else
		snatchconfigframe.snatchlist.sheet = ScrollSheet:Create(snatchconfigframe.snatchlist, {
		{ "Snatching", "TOOLTIP", 150 }, 
		{ "Buy at", "COIN", 70}, 
		{ "Appraiser", "COIN", 70 }, 
		}, snatch.OnSnatchEnter, snatch.OnLeave, snatch.OnClickSnatchList)
	end
	lib.populateSnatchSheet()
end
lib.makesnatchgui()
