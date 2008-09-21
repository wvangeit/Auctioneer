--[[
	Auctioneer Advanced - Search UI - Searcher Snatch
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

	This is a plugin module for the SearchUI that assists in searching by refined paramaters

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

--if not BtmScan then return end --Stopgap measure for problem with Btmscan not found in embedded version
-- Create a new instance of our lib with our parent
local lib, parent, private = AucSearchUI.NewSearcher("Snatch")
if not lib then return end
local print,decode,_,_,replicate,empty,_,_,_,debugPrint,fill = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "Snatch"
lib.Private = private

default("snatch.allow.bid", true)
default("snatch.allow.buy", true)
if not get("snatch.itemsList") then set("snatch.itemsList", {}) end

private.workingItemLink = nil
local frame 


-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	-- Get our tab and populate it with our controls
	local id = gui:AddTab(lib.tabname, "Searches")
	gui:MakeScrollable(id)	
	--we add a single invisible element to set the normal gui
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")

	
	local SelectBox = LibStub:GetLibrary("SelectBox")
	local ScrollSheet = LibStub:GetLibrary("ScrollSheet")
	--Add Drag slot / Item icon
	frame = gui.tabs[id].content
	private.frame = frame
	
	--Create the snatch list results frame
	frame.snatchlist = CreateFrame("Frame", nil, frame)
	frame.snatchlist:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	
	frame.snatchlist:SetBackdropColor(0, 0, 0.0, 0.5)
	frame.snatchlist:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, 2)
	frame.snatchlist:SetPoint("BOTTOM", frame, "BOTTOM", 0, 110)
	frame.snatchlist:SetWidth(360)

	frame.slot = frame:CreateTexture(nil, "BORDER")
	frame.slot:SetDrawLayer("Artwork") -- or the border shades it
	frame.slot:SetPoint("BOTTOM", frame.snatchlist, "BOTTOM", 0, -100)
	frame.slot:SetWidth(45)
	frame.slot:SetHeight(45)
	frame.slot:SetTexCoord(0.17, 0.83, 0.17, 0.83)
	frame.slot:SetTexture("Interface\\Buttons\\UI-EmptySlot")

	
	--ICON box, used to drag item and display Icon
	function frame.IconClicked()
		local objtype, _, link = GetCursorInfo()
		ClearCursor()
		if objtype == "item" then
			lib.SetWorkingItem(link)
		end
	end 
	frame.icon = CreateFrame("Button", nil, frame)
	frame.icon:SetPoint("TOPLEFT", frame.slot, "TOPLEFT", 2, -2)
	frame.icon:SetPoint("BOTTOMRIGHT", frame.slot, "BOTTOMRIGHT", -2, 2)
	frame.icon:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp")
	frame.icon:SetScript("OnClick", frame.IconClicked)
	frame.icon:SetScript("OnReceiveDrag", frame.IconClicked)
	
	frame.slot.help = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.slot.help:SetPoint("LEFT", frame.slot, "RIGHT", 2, 7)
	frame.slot.help:SetText(("Drop item into box")) --"Drop item into box to search."
	frame.slot.help:SetWidth(100)
		
	
	if not ( AucAdvanced and AucAdvanced.Modules.Util.Appraiser ) then
		frame.snatchlist.sheet = ScrollSheet:Create(frame.snatchlist, {
		{ "Snatching", "TOOLTIP", 176 }, 
		{ "Buy each", "COIN", 70 }, 
		}, private.OnEnterScratch, private.OnLeave, private.OnClickSnatch, private.OnResize)
	else
		frame.snatchlist.sheet = ScrollSheet:Create(frame.snatchlist, {
		{ "Snatching", "TOOLTIP", 176 }, 
		{ "Buy each", "COIN", 70}, 
		{ "App. value", "COIN", 70 }, 
		}, private.OnEnterScratch, private.OnLeave, private.OnClickSnatch, private.OnResize)
	end
	
	-- Bag List
	frame.baglist = CreateFrame("Frame", nil, frame)
	frame.baglist:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	
	frame.baglist:SetBackdropColor(0, 0, 0.0, 0.5)
	frame.baglist:SetPoint("TOPLEFT", frame.snatchlist, "TOPRIGHT", 10, 0)
	--frame.baglist:SetPoint("RIGHT", frame, "RIGHT", -30, -0)
	frame.baglist:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
	frame.baglist:SetPoint("BOTTOM", frame.snatchlist, "BOTTOM", 0, 0)
	
	frame.bagscan = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.bagscan:SetPoint("TOP", frame.baglist, "BOTTOM", 0, -15)
	frame.bagscan:SetText(("Refresh Bag Data"))
	frame.bagscan:SetWidth(130)
	frame.bagscan:SetScript("OnClick", lib.PopulateBagSheet)
	
	if not ( AucAdvanced and AucAdvanced.Modules.Util.Appraiser ) then
		frame.baglist.sheet = ScrollSheet:Create(frame.baglist, {
			{ "Bag Contents", "TOOLTIP", 208 }, 
			{ "BTM Rule", "TEXT", 70 }, 
			}, private.OnEnterBag, private.OnLeave, private.OnClickBag, private.OnResize)
	else
		frame.baglist.sheet = ScrollSheet:Create(frame.baglist, {
			{ "Bag Contents", "TOOLTIP", 208 }, 
			{ "Appraiser", "COIN", 70 }, 
			}, private.OnEnterBag, private.OnLeave, private.OnClickBag, private.OnResize)
	end

	
	
	--[[
	frame.additem.help = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.additem.help:SetPoint("TOPLEFT", frame.additem, "TOPRIGHT", 1, 1)
	frame.additem.help:SetText(("(to Snatch list)")) 
	frame.additem.help:SetWidth(90)
	]]
	
	--Add coin boxes
	local function goldtosilver()
		frame.silver:SetFocus()
	end
	
	local function silvertocopper()
		frame.copper:SetFocus()
	end
	
	local function copper()
		frame.copper:ClearFocus()
	end
	
		
	frame.gold = CreateFrame("EditBox", "snatchgold", frame, "InputBoxTemplate")
	frame.gold:SetPoint("LEFT", frame.slot, "RIGHT", 10, -20)
	frame.gold:SetAutoFocus(false)
	frame.gold:SetHeight(15)
	frame.gold:SetWidth(40)
	frame.gold:SetScript("OnEnterPressed", goldtosilver)
	frame.gold:SetScript("OnTabPressed", goldtosilver)
	
	frame.silver = CreateFrame("EditBox", "snatchsilver", frame, "InputBoxTemplate")
	frame.silver:SetPoint("TOPLEFT", frame.gold, "TOPRIGHT", 10, 0)
	frame.silver:SetAutoFocus(false)
	frame.silver:SetHeight(15)
	frame.silver:SetWidth(20)
	frame.silver:SetMaxLetters(2)
	frame.silver:SetScript("OnEnterPressed", silvertocopper)
	frame.silver:SetScript("OnTabPressed", silvertocopper)
	
	frame.copper = CreateFrame("EditBox", "snatchcopper", frame, "InputBoxTemplate")
	frame.copper:SetPoint("TOPLEFT", frame.silver, "TOPRIGHT", 10, 0)
	frame.copper:SetAutoFocus(false)
	frame.copper:SetHeight(15)
	frame.copper:SetWidth(20)
	frame.copper:SetMaxLetters(2)
	frame.copper:SetScript("OnEnterPressed", copper)
	frame.copper:SetScript("OnTabPressed", copper)
	
	
	--Add Item to list button	
	frame.additem = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.additem:SetPoint("LEFT", frame.gold, "RIGHT", 70, 0)
	frame.additem:SetText(('Add Item'))
	frame.additem:SetScript("OnClick", function() 	
								local g = tonumber(frame.gold:GetText()) or 0
								local s = tonumber(frame.silver:GetText()) or 0
								local c = tonumber(frame.copper:GetText()) or 0
								lib.AddSnatch(private.workingItemLink, g*10000 + s*100 + c)
							end)
	
	--Remove Item from list button	
	frame.removeitem = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.removeitem:SetPoint("LEFT", frame.additem, "RIGHT", 10, 0)
	frame.removeitem:SetText(('Remove Item'))
	frame.removeitem:SetScript("OnClick", function() lib.RemoveSnatch(private.workingItemLink) end)
		
	--Reset snatch list
	frame.resetList = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.resetList:SetPoint("TOP", frame.snatchlist, "BOTTOM", 0, -15)
	frame.resetList:SetText(("Clear List"))
	frame.resetList:SetScript("OnClick", function() 
								if ( IsAltKeyDown() and IsShiftKeyDown() and IsControlKeyDown() )then 
									private.snatchList = {}
									set("snatch.itemsList", private.snatchList)
									lib.refreshData()
								else 
									print("This will clear the snatch list permanently. To use hold ALT+CTR+SHIFT while clicking this button") 
								end 
							end)
	
	private.snatchList =  get("snatch.itemsList")
	
	--Set our "last" frame anchor point this will be the "top" area for normal config GUI elements
	local last = gui:GetLast(id)
	local  locationA, Frame, locationB, x, y = last:GetPoint()
		last:SetPoint(locationA, Frame, locationB, x, -270)
	gui:SetLast(id, last)
	
	gui:AddControl(id, "Subhead",0, "Snatch search settings:")
	gui:AddControl(id, "Note", 0, 1, nil, nil, " ")
	last = gui:GetLast(id)	
	gui:AddControl(id, "Checkbox", 0, 1, "snatch.allow.bid", "Allow Bids")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox", 0, 11,  "snatch.allow.buy", "Allow Buyouts")
	
	
	lib.refreshData()
	lib.PopulateBagSheet()
end
function private.OnEnterScratch(button, row, index)
	if frame.snatchlist.sheet.rows[row][index]:IsShown() then --Hide tooltip for hidden cells
		local link = frame.snatchlist.sheet.rows[row][index]:GetText()
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
function private.OnEnterBag(button, row, index)
	if frame.baglist.sheet.rows[row][index]:IsShown() then --Hide tooltip for hidden cells
		local link = frame.baglist.sheet.rows[row][index]:GetText()
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
function private.OnLeave()
	GameTooltip:Hide()
end
function private.OnClickBag(button, row, index)
	local link = frame.baglist.sheet.rows[row][1]:GetText()
	lib.SetWorkingItem(link)
end
function private.OnClickSnatch(button, row, index)
	local link = frame.snatchlist.sheet.rows[row][1]:GetText()
	lib.SetWorkingItem(link)
end
function private.OnResize(...)
	--print(...)
end



--[[
ItemTable[Const.LINK]    = hyperlink
	ItemTable[Const.ILEVEL]  = iLevel
	ItemTable[Const.ITYPE]   = iType
	ItemTable[Const.ISUB]    = iSubType
	ItemTable[Const.IEQUIP]  = iEquip
	ItemTable[Const.PRICE]   = price
	ItemTable[Const.TLEFT]   = timeleft
	ItemTable[Const.NAME]    = name
	ItemTable[Const.COUNT]   = count
	ItemTable[Const.QUALITY] = quality
	ItemTable[Const.CANUSE]  = canUse
	ItemTable[Const.ULEVEL]  = level
	ItemTable[Const.MINBID]  = minBid
	ItemTable[Const.MININC]  = minInc
	ItemTable[Const.BUYOUT]  = buyout
	ItemTable[Const.CURBID]  = curBid
	ItemTable[Const.AMHIGH]  = isHigh
	ItemTable[Const.SELLER]  = owner
	ItemTable[Const.ITEMID]  = itemid
	ItemTable[Const.SUFFIX]  = suffix
	ItemTable[Const.FACTOR]  = factor
	ItemTable[Const.ENCHANT]  = enchant
	ItemTable[Const.SEED]  = seed
]]
function lib.Search(item)
	
	local itemsig = (":"):join(item[Const.ITEMID], item[Const.SUFFIX] , item[Const.ENCHANT])
	
	local value = 0
	local stackSize = item[Const.COUNT] or 1
		
	if private.snatchList[itemsig] then
		value =  stackSize * private.snatchList[itemsig].price
		
		if item[Const.BUYOUT] > 0 and item[Const.BUYOUT] <= value and get("snatch.allow.buy") then
			return "buy", value
		elseif item[Const.PRICE] <= value and get("snatch.allow.bid") then
			return "bid", value
		else
			return false, "Price not low enough or bid/buy not checked."
			
		end
	end
	
	return false, "Not in snatch list"
end

--[[Snatch GUI functinality code]]


function lib.AddSnatch(itemlink, price, count)	-- give price=(0 or nil) to stop snatching
	
	local _, itemid, itemsuffix, itemenchant, itemseed = AucAdvanced.DecodeLink(itemlink)
	
	if not itemid then return end 
	
	local itemsig = (":"):join(itemid, itemsuffix, itemenchant)
		
	if price and price<=0 then
		price=nil
	end
	if count and count<=0 then
		count=nil
	end
	--get appraiser price if possible
	local abid, abuy, appraiser 
	if AucAdvanced and AucAdvanced.Modules.Util.Appraiser then
		abid, abuy = AucAdvanced.Modules.Util.Appraiser.GetPrice(itemlink, nil, true)
		appraiser = tonumber(abuy) or tonumber(abid)
	end
	--add item to snatch list
	private.snatchList[itemsig] = {["link"] =  itemlink, ["price"] = price, ["count"] = count, ["appraiser"] = appraiser}
	set("snatch.itemsList", private.snatchList)
	lib.finishedItem()
end
function lib.RemoveSnatch(itemlink)
	local _, itemid, itemsuffix, itemenchant, itemseed = AucAdvanced.DecodeLink(itemlink)
	if not itemid then return end 
	
	local itemsig = (":"):join(itemid, itemsuffix, itemenchant)
	--remove from snatch list
	private.snatchList[itemsig] = nil
	set("snatch.itemsList", private.snatchList)
	lib.finishedItem()
end
--set UI for next item choice
function lib.finishedItem()
	--reset UI
	frame.slot.help:SetText(("Drop item into box"))
	frame.icon:SetNormalTexture(nil)
	--reset current working item
	private.workingItemLink = nil
	--refresh displays
	lib.refreshData()
end
--get teh current item we may want to add or remove
function lib.SetWorkingItem(link)
	if type(link)~="string" then return end
	
	local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(link)
	
	if not name or not texture then return end
	--set edit box texture and name
	frame.icon:SetNormalTexture(texture)
	frame.slot.help:SetText(link)
	
	--set current working item
	private.workingItemLink = link

end
function lib.ClickLinkHook(_, link, button)
	if link and private.frame and private.frame:IsShown() then
		if (button == "LeftButton") then --and (IsAltKeyDown()) and itemName then -- Commented mod key, I want to catch any item clicked.
			lib.SetWorkingItem(link)
		end
	end
end
hooksecurefunc("ChatFrame_OnHyperlinkShow", lib.ClickLinkHook)


function lib.refreshData()
	local Data, Style = {}, {}
	for item, v in pairs(private.snatchList) do
		table.insert(Data, {v.link, v.price, v.appraiser})
	end
	frame.snatchlist.sheet:SetData(Data, Style)
end

function lib.PopulateBagSheet()
	
	local unique={}
	local bagcontents = {}
	local appraiser = AucAdvanced and AucAdvanced.Modules.Util.Appraiser
	
	for bag=0,NUM_BAG_SLOTS do
		for slot=1,GetContainerNumSlots(bag) do
			local itemLink = GetContainerItemLink(bag,slot)
			if itemLink then
				local _, itemid, suffix, enchant, seed = AucAdvanced.DecodeLink(itemLink)
				local sig = ("%d:%d"):format(itemid,suffix)
				if not unique[sig] then
					unique[sig]=true
					local _,itemCount = GetContainerItemInfo(bag,slot)
					local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink)
										
								
					if not appraiser then
						tinsert(bagcontents, {
							itemLink,
							0
						})
					else
						local abid,abuy = appraiser.GetPrice(itemLink, nil, true)
						tinsert(bagcontents, {
							itemLink,
							tonumber(abuy) or tonumber(abid)
						})
					end
				end
			end
		end
	end
	
	frame.baglist.sheet:SetData(bagcontents) --Set the GUI scrollsheet
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
