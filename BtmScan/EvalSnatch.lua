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
local snatchconfigframe = CreateFrame("Frame", "snatchframe", UIParent); snatchconfigframe:Hide()	
local bagcontents = {}
local myworkingtable = {}
local snatchprice

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
	BtmScan.Print("/btm snatch item maxPrice ")
	BtmScan.Print("/btm snatch list")
end

function lib.CommandHandler(msg)
	BtmScan.Print("called snatch-handler"..msg)
	if (AucAdvanced) then
		if (string.lower(msg) == "snatch") then 
			lib.snatchGUI()
			return
		end
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

		local itemid, itemsuffix, itemenchant, itemseed = BtmScan.BreakLink(itemlink)
		local itemsig = (":"):join(itemid, itemsuffix, itemenchant)
		local itemconfig = BtmScan.getItemConfig(itemsig)


		if (price <= 0) then
			price = BtmScan.ParseGSC(remain) or 0
		end

		if (price <= 0) then
			BtmScan.Print(translate("BottomScanner will now %1 %2", translate("not snatch"), itemlink))
			itemconfig.buyBelow=price
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
		if (count > 0) then
			countText = translate("up to %1", count).." "
		else
			countText = translate("unlimited").." "
		end

		BtmScan.Print(translate("BottomScanner will now %1 %2", translate("snatch"), countText..translate("%1 at %2", itemlink, translate("%1 per unit", BtmScan.GSC(price, 1)))..stackText))
		itemconfig.buyBelow=price
		BtmScan.storeItemConfig(itemconfig, itemsig)
	end

end

function lib.PrintList()
	local itemConfigTable = get("itemconfig.list")
	for itemkey, itemConfig in pairs(itemConfigTable) do
		itemConfig = BtmScan.unpackItemConfiguration(itemConfig)
		if itemConfig.buyBelow and itemConfig.buyBelow > 0 then
			local itemID, itemsuffix, itemenchant = strsplit(":", itemkey)
			itemkey = strjoin(":", "item", itemID, itemenchant, 0, 0, 0, 0, itemsuffix)
			local _, itemlink = GetItemInfo(itemkey)
			BtmScan.Print(itemlink.."  "..BtmScan.GSC(itemConfig.buyBelow, 1))
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


if (AucAdvanced) then

	local print, decode = AucAdvanced.GetModuleLocals()  -- needs removed replaced with btm
	local SelectBox = LibStub:GetLibrary("SelectBox")
	local ScrollSheet = LibStub:GetLibrary("ScrollSheet")


	function lib.setWorkingItem(setname, setid)
		for k, n in pairs(myworkingtable) do	
			myworkingtable[k] = nil
		end
		if (setid == nil and setname == nil) then return end
		if (setid == nil) then setid = setname end
		local wrkname, wrklink, wrkrarity, wrklevel, wrkMinLevel, wrkType, wrkSubType, wrkStackCount, wrkEquipLoc, wrkTexture = GetItemInfo(setid)
		local _, wrkid, _, _, _, _ = decode(wrklink)

		snatchconfigframe.workingname:SetText(wrkname)
		snatchconfigframe.slot:SetTexture(wrkTexture)

		myworkingtable[wrkid] = wrkname
	end

	local snatch = {}
	function snatch.OnSnatchEnter(button, row, index)
		local link, name
		link = snatchconfigframe.snatchlist.sheet.rows[row][index]:GetText() or "FAILED LINK"
		if link:match("^(|c%x+|H.+|h%[.+%])") then
			name = string.match(link, "^|c%x+|H.+|h%[(.+)%]")
		end
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
		if snatchconfigframe.snatchlist.sheet.rows[row][index]:IsShown()then --Hide tooltip for hidden cells
			if link and name then
				GameTooltip:SetHyperlink(link)
				if (EnhTooltip) then EnhTooltip.TooltipCall(GameTooltip, name, link, -1, 1) end
			else
				GameTooltip:SetText("Unable to get Tooltip Info", 1.0, 1.0, 1.0)
			end
		end		
		namefromenter = name
		linkfromenter= link
	end

	local workingsnatchtable = {}
	function lib.populateSnatchSheet()
		for k, v in pairs(workingsnatchtable)do workingsnatchtable[k] = nil; end --Reset 'data' table to ensure fresh data.

		local itemConfigTable = get("itemconfig.list")
		
		for key, config in pairs(itemConfigTable) do
			local itemID, itemSuffix, itemEnchant = strsplit(":", key)
			local maxPrice, isIgnore, ignoreModuleList, buyBelow = strsplit(";", config)
			if not(buyBelow == "nil") then
				local snatchKey = strjoin(':', itemID, itemSuffix, itemEnchant)
				local snatchValue = strjoin(';', maxPrice, isIgnore, ignoreModuleList, buyBelow)
				local snatchKeyAndValue = strjoin('|', snatchKey, snatchValue)
				workingsnatchtable[itemID] = snatchKeyAndValue	
			end
		end
			
		local displaysnatchtable = {}
		for k, v in pairs(displaysnatchtable)do displaysnatchtable[k] = nil; end --Reset 'data' table to ensure fresh data.
		for key, v in pairs(workingsnatchtable) do 
			if (key == nil) then return end
			local	btmskey, btmsvalue = strsplit('|', v)
			local _, _, _, ibelow = strsplit(';', btmsvalue) 
			local itemID, itemsuffix, itemenchant = strsplit(':', btmskey)
			itemkey = strjoin(":", "item", itemID, itemenchant, 0, 0, 0, 0, itemsuffix)
			local _, itemlink = GetItemInfo(itemkey)
			local _, itemlink, _, _, _, _, _, _, _, _ = GetItemInfo(key)
			local a, b, c = BtmScan.GetGSC(ibelow)
			ibelow = strjoin('', a, "g ", b, "s ", c, "c")
			table.insert(displaysnatchtable,{
				itemlink, --col2(itemname)as link form for mouseover tooltips to work
				ibelow, --btm rule
				key, --itemid
			}) 
		end
			
		snatchconfigframe.snatchlist.sheet:SetData(displaysnatchtable, style) --Set the GUI scrollsheet
	end 

	function lib.buildkeyfromid(itemid)
		---------------------------------------------------------Need to grab this data from an updated working table / equiv else we are overwriting 
		---- the current data with 0's or nil's
		local key = strjoin(':', itemid, "0", "0")	
		return key 
	end

	function lib.buildvaluefrombuyBelow(buyBelow)
		---------------------------------------------------------Need to grab this data from an updated working table / equiv else we are overwriting 
		---- the current data with 0's or nil's
		local value = strjoin(';', "nil", "nil", "nil", buyBelow)	
		return value
	end	

	function lib.snatchListClear()
		local cleartable = {}
		for k, v in pairs (cleartable) do
			cleartable[k] = nil
		end
		set("itemconfig.list", cleartable) --Inserts our re-built itemconfig.list take into BTM Settings
		lib.populateSnatchSheet()
	end

	function lib.commitSnatchList(commitfor, commitwhat)	
		local snatchcommit = {}
		local commitfor = commitfor
		local commitwhat = commitwhat
		local tempblanktable = {}
		
		for k, v in pairs(tempblanktable) do tempblanktable[k] = nil; end -- Clears our data table to ensure fresh data.
		for k, v in pairs(snatchcommit) do snatchcommit[k] = nil; end -- Clears our data table to ensure fresh data.
		if (commitfor == "add") then
			snatchprice = 1
			local gnum = snatchconfigframe.gold:GetNumLetters()
			local snum = snatchconfigframe.silver:GetNumLetters()		
			local cnum = snatchconfigframe.copper:GetNumLetters()		
			local gold = snatchconfigframe.gold:GetText()
			local silver = snatchconfigframe.silver:GetText()
			local copper = snatchconfigframe.copper:GetText()
			gold = tonumber(gold)
			if (gold == nil) then 
				gold = 0.01
			else
				gold = gold * 10000
			end
			silver = tonumber(silver)
			
			if (silver == nil) then
				silver = 0.0001
			else
				silver = silver * 100
			end
			copper = tonumber(copper)
			if (copper == nil) then
				copper = 0.01
			else
				copper = copper * 1
			end
			snatchprice = copper + silver + gold
			if (snatchprice < 0) then
				print("We would love to add this item, but we need a snatch below price set to do it!")
			return end
			snatchprice, _ = strsplit('.', snatchprice)
			local key = lib.buildkeyfromid(commitwhat)
			local value = lib.buildvaluefrombuyBelow(snatchprice)
			local keyvalue = strjoin('|', key, value)
			tempblanktable[commitwhat] = keyvalue
			snatchcommit[key] = value
			for k, v in pairs(workingsnatchtable) do 
				if (k == nil) then return end
				local	btmskey, btmsvalue = strsplit('|', v)
				snatchcommit[btmskey] = btmsvalue
			end
		end
		
		if (commitfor == "remove") then
			snatchprice = 10 -- doesn't matter we are removing it just need to be sure there is a number here to build the new value.
			local key = lib.buildkeyfromid(commitwhat)
			local value = lib.buildvaluefrombuyBelow(snatchprice)
			local tone, ttwo, tthree, tfour = strsplit(';', value)
			value = strjoin(';', tone, ttwo, tthree, "nil")
			local keyvalue = strjoin('|', key, value)
			tempblanktable[commitwhat] = keyvalue
			for k, v in pairs(workingsnatchtable) do 
				if (k == nil) then return end
				local	btmskey, btmsvalue = strsplit('|', v)
				snatchcommit[btmskey] = btmsvalue
			end
			snatchcommit[key] = value
		end
		
		set("itemconfig.list", snatchcommit) --Inserts our re-built itemconfig.list take into BTM Settings
		
		for k, v in pairs (tempblanktable) do
			tempblanktable[k] = nil
		end
		lib.populateSnatchSheet()
	end


	function snatchconfigframe.removeitemfromlist()
		
		for iid, n in pairs(myworkingtable) do
			local asnum = tonumber(iid)
			myworkingtable[iid] = nil
			lib.commitSnatchList("remove", asnum)	
		end
		snatchconfigframe.ClearIcon()
		lib.populateSnatchSheet()
	end

	function snatchconfigframe.snatchadditemtolist()
		for iid, n in pairs(myworkingtable) do
			local asnum = tonumber(iid)
			myworkingtable[iid] = nil
			lib.commitSnatchList("add", asnum)	
		end
		snatchconfigframe.ClearIcon()
		lib.populateSnatchSheet()	
	end

	function snatch.OnBagListEnter(button, row, index)
		local link, name
		link = snatchconfigframe.baglist.sheet.rows[row][index]:GetText() or "FAILED LINK"
		if link:match("^(|c%x+|H.+|h%[.+%])") then
			name = string.match(link, "^|c%x+|H.+|h%[(.+)%]")
		end
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
		if snatchconfigframe.baglist.sheet.rows[row][index]:IsShown()then --Hide tooltip for hidden cells
			if link and name then
				GameTooltip:SetHyperlink(link)
				if (EnhTooltip) then EnhTooltip.TooltipCall(GameTooltip, name, link, -1, 1) end
			else
				GameTooltip:SetText("Unable to get Tooltip Info", 1.0, 1.0, 1.0)
			end
		end		
		namefromenter = name
		linkfromenter= link
	end

	function snatch.OnLeave(button, row, index)
		GameTooltip:Hide()
		linkfromenter = "emptylink"
		namefromenter = "emptyname"
	end

	function snatch.OnClick(button, row, index)
		if (linkfromenter == nil) then return end
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(linkfromenter)
		local _, itemID, _, _, _, _ = decode(linkfromenter)
		lib.setWorkingItem(itemName, itemID)
	end	

	function snatchconfigframe.ClearIcon()
		snatchconfigframe.workingname:SetText("Item Name")
		snatchconfigframe.slot:SetTexture("Interface\\Buttons\\UI-EmptySlot")
		snatchconfigframe.gold:SetText("")
		snatchconfigframe.silver:SetText("")
		snatchconfigframe.copper:SetText("")
		wrkname = nil	
		wrkid = nil
	end

	function snatchconfigframe.IconClicked()
		snatchconfigframe.ClearIcon()
	end 

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


	function lib.snatchIconDrag()
		local objtype, _, itemlink = GetCursorInfo()
		ClearCursor()
		if objtype == "item" then
			lib.GetItemByLink(itemlink)
			if (itemlink == nil) then 
				return 
			end
				local itemName, newlink, _, _, _, _, _, _, _, _ = GetItemInfo(itemlink) 
				local _, itemID, _, _, _, _ = decode(itemlink)
				lib.setWorkingItem(itemName, itemID)
		end
	end


	function lib.ClickLinkHook(_, _, _, link, button)
		if (snatchconfigframe:IsVisible()) then
			if link then
				local itemID, itemName = link:match("^|c%x+|Hitem:(.-):.*|h%[(.+)%]")
				if (itemID == nil) then return end
				if (button == "LeftButton") then --and (IsAltKeyDown()) and itemName then -- Commented mod key, I want to catch any item clicked.
					lib.setWorkingItem(itemName, itemID)
				end
			end
		end
	end

	function lib.populateDataSheet()
		for k, v in pairs(bagcontents) do bagcontents[k] = nil; end --Reset table to ensure fresh data.
		for bag=0,4 do
			for slot=1,GetContainerNumSlots(bag) do
				if (GetContainerItemLink(bag,slot)) then
					local _,itemCount = GetContainerItemInfo(bag,slot)
					local itemLink = GetContainerItemLink(bag,slot)
					local _, itemID, _, _, _, _ = decode(itemLink)
					if (itemLink == nil) then return end
					local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink)
					local btmRule = "~"
					local reason, bids
					local id, suffix, enchant, seed = BtmScan.BreakLink(itemLink)
					local sig = ("%d:%d:%d"):format(id, suffix, enchant)
					local bidlist = get("bid.list")
					
					if (bidlist) then
						bids = bidlist[sig..":"..seed.."x"..itemCount]
						if(bids and bids[1]) then 
							btmRule = bids[1]
						end 
					end
									
					local joinedBagString = strjoin('|', itemName, btmRule)
					bagcontents[itemID] = joinedBagString	
				end
			end
		end
		local bagcontentsnodups = {}
		for k, v in pairs(bagcontentsnodups) do bagcontentsnodups[k] = nil; end --Reset 'data' table to ensure fresh data.
		for col1, col2 in pairs(bagcontents) do 
			if (col1 == nil) then return end
			local	iName, iRule = strsplit('|', col2)
			local _, itemLink, _, _, _, _, _, _, _, _ = GetItemInfo(col1)
			table.insert(bagcontentsnodups,{
			itemLink, --col2(itemlink) for mouseover tooltips to work
			iRule, --btm rule
			col1, --itemid
			}) 
		end 
		snatchconfigframe.baglist.sheet:SetData(bagcontentsnodups, style) --Set the GUI scrollsheet
		lib.populateSnatchSheet()
	end

	function lib.snatchGUI() 
		if (snatchconfigframe:IsVisible()) then lib.closeSnatchGUI() end
		Stubby.RegisterFunctionHook("ChatFrame_OnHyperlinkShow", -50, lib.ClickLinkHook)
		snatchconfigframe:Show()		
		lib.populateDataSheet()
		snatchconfigframe.ClearIcon()
	end

	function lib.closeSnatchGUI()
		snatchconfigframe:Hide()
		Stubby.UnregisterFunctionHook("ChatFrame_OnHyperlinkShow", lib.ClickLinkHook)
	end

	function lib.makesnatchgui()
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
		snatchconfigframe.slot:SetPoint("TOPLEFT", snatchconfigframe, "TOPLEFT", 23, -75)
		snatchconfigframe.slot:SetWidth(45)
		snatchconfigframe.slot:SetHeight(45)
		snatchconfigframe.slot:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		snatchconfigframe.slot:SetTexture("Interface\\Buttons\\UI-EmptySlot")

		snatchconfigframe.icon = CreateFrame("Button", nil, snatchconfigframe)
		snatchconfigframe.icon:SetPoint("TOPLEFT", snatchconfigframe.slot, "TOPLEFT", 3, -3)
		snatchconfigframe.icon:SetWidth(38)
		snatchconfigframe.icon:SetHeight(38)
		snatchconfigframe.icon:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp")
		snatchconfigframe.icon:SetScript("OnClick", snatchconfigframe.IconClicked)
		snatchconfigframe.icon:SetScript("OnReceiveDrag", lib.snatchIconDrag)
		
		snatchconfigframe.slot.help = snatchconfigframe:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		snatchconfigframe.slot.help:SetPoint("LEFT", snatchconfigframe.slot, "RIGHT", 2, 7)
		snatchconfigframe.slot.help:SetText(("Drop item into box")) --"Drop item into box to search."
		snatchconfigframe.slot.help:SetWidth(100)
		
		snatchconfigframe.workingname = snatchconfigframe:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		snatchconfigframe.workingname:SetPoint("TOPLEFT", snatchconfigframe, "TOPLEFT", 15, -135)
		snatchconfigframe.workingname:SetText(("")) 
		snatchconfigframe.workingname:SetWidth(90)
		
		
		--Add Title text
		local	snatchtitle = snatchconfigframe:CreateFontString(asuftitle, "OVERLAY", "GameFontNormalLarge")
		snatchtitle:SetText("BTM Snatch Configuration!")
		snatchtitle:SetJustifyH("CENTER")
		snatchtitle:SetWidth(300)
		snatchtitle:SetHeight(10)
		snatchtitle:SetPoint("TOPLEFT",  snatchconfigframe, "TOPLEFT", 0, -17)
		snatchconfigframe.snatchtitle = asnatchtitle	
		
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
		snatchconfigframe.bagscan:SetScript("OnClick", lib.populateDataSheet)
		
		snatchconfigframe.baglist.sheet = ScrollSheet:Create(snatchconfigframe.baglist, {
			{ ('Bag Contents:'), "TOOLTIP", 170 }, 
			{ ('BTM Rule'), "TEXT", 25 }, 
			{ ('ID #'), "TEXT", 25 }, 
		}, snatch.OnBagListEnter, snatch.OnLeave, snatch.OnClick)
			
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
		
		snatchconfigframe.additem.help = snatchconfigframe:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		snatchconfigframe.additem.help:SetPoint("TOPLEFT", snatchconfigframe.additem, "TOPRIGHT", 1, 1)
		snatchconfigframe.additem.help:SetText(("(to Snatch list)")) 
		snatchconfigframe.additem.help:SetWidth(90)
		
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
		
		snatchconfigframe.removeitem.help = snatchconfigframe:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		snatchconfigframe.removeitem.help:SetPoint("TOPLEFT",  snatchconfigframe.removeitem, "TOPRIGHT", 1, 1)
		snatchconfigframe.removeitem.help:SetText(("(from Snatch list)")) 
		snatchconfigframe.removeitem.help:SetWidth(90)
		
		--Reset snatch list
		snatchconfigframe.resetList = CreateFrame("Button", nil, snatchconfigframe, "OptionsButtonTemplate")
		snatchconfigframe.resetList:SetPoint("TOP", snatchconfigframe.snatchlist, "BOTTOM", 0, -15)
		snatchconfigframe.resetList:SetText(("Reset List"))
		snatchconfigframe.resetList:SetScript("OnClick", lib.snatchListClear)
		
		snatchconfigframe.snatchlist.sheet = ScrollSheet:Create(snatchconfigframe.snatchlist, {
			{ ('Snatching:'), "TOOLTIP", 170 }, 
			{ ('Buy Below:'), "TEXT", 25 }, 
			{ ('ID #'), "TEXT", 25 }, 
		}, snatch.OnSnatchEnter, snatch.OnLeave, snatch.OnClick) 


		lib.populateSnatchSheet()
	end
	lib.makesnatchgui()
end