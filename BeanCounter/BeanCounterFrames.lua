--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/
	
	BeanCounterFrames - AuctionHouse UI for Beancounter 

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
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

local lib = BeanCounter
local private = lib.Private
local print =  BeanCounter.Print
local _BC = private.localizations

local function debugPrint(...) 
    if private.getOption("util.beancounter.debugFrames") then
        private.debugPrint("BeanCounterFrames",...)
    end
end

local frame
function private.AuctionUI()
	if frame then return end
	frame = private.frame
	
	--Create the TAB
	frame.ScanTab = CreateFrame("Button", "AuctionFrameTabUtilBeanCounter", AuctionFrame, "AuctionTabTemplate")
	frame.ScanTab:SetText("BeanCounter")
	frame.ScanTab:Show()
	
	PanelTemplates_DeselectTab(frame.ScanTab)
	
	if AucAdvanced then
		AucAdvanced.AddTab(frame.ScanTab, frame)
	else
		private.AddTab(frame.ScanTab, frame)
	end
	
	function frame.ScanTab.OnClick(_, _, index)
		if private.frame:GetParent() == BeanCounterBaseFrame then
			BeanCounterBaseFrame:Hide()
			private.frame:SetParent(AuctionFrame)
			frame:SetPoint("TOPLEFT", "AuctionFrame", "TOPLEFT")
			--private.frame:SetWidth(834.
			--private.frame:SetHeight(450)
			private.relevelFrame(frame)--make sure our frame stays in proper order		
		end
	
		if not index then index = this:GetID() end
		local tab = getglobal("AuctionFrameTab"..index)
		if (tab and tab:GetName() == "AuctionFrameTabUtilBeanCounter") then
			--Modified Textures
			AuctionFrameTopLeft:SetTexture("Interface\\AddOns\\BeanCounter\\Textures\\BC-TopLeft")
			AuctionFrameTop:SetTexture("Interface\\AddOns\\BeanCounter\\Textures\\BC-Top")
			AuctionFrameTopRight:SetTexture("Interface\\AddOns\\BeanCounter\\Textures\\BC-TopRight")
			--Default AH textures
			AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotLeft")
			AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-Bot")
			AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight")
			
			--print(tab:GetName())
			
			if (AuctionDressUpFrame:IsVisible()) then
				AuctionDressUpFrame:Hide()
				AuctionDressUpFrame.reshow = true
			end
			frame:Show()
		else
			if (AuctionDressUpFrame.reshow) then
				AuctionDressUpFrame:Show()
				AuctionDressUpFrame.reshow = nil
			end
			AuctionFrameMoneyFrame:Show()
			frame:Hide()
		end
	end
	
	hooksecurefunc("AuctionFrameTab_OnClick", frame.ScanTab.OnClick)
end
--Change parent to our GUI base frame/ Also used to display our Config frame
function private.GUI(_, button)
	if (button == "LeftButton") then
		if private.frame:GetParent() == AuctionFrame then 
			--BeanCounterBaseFrame:SetWidth(800)
			--BeanCounterBaseFrame:SetHeight(450)
			
			private.frame:SetParent("BeanCounterBaseFrame")
			private.frame:SetPoint("TOPLEFT", BeanCounterBaseFrame, "TOPLEFT")
			--BeanCounterBaseFrame:SetPoint("TOPLEFT", lib.Gui, "TOPLEFT")
			--private.frame:SetPoint("BOTTOMRIGHT", lib.Gui, "BOTTOMRIGHT", 0,0)
		end
		if not BeanCounterBaseFrame:IsVisible() then
			if AuctionFrame then AuctionFrame:Hide() end
			BeanCounterBaseFrame:Show()
			private.frame:SetFrameStrata("FULLSCREEN")
			private.frame:Show()
		else
			BeanCounterBaseFrame:Hide()
		end
	else 
		if not lib.Gui:IsVisible() then
			lib.Gui:Show()
		else
			lib.Gui:Hide()
		end
	end
		
end

--Seperated frame items from frame creation, this should allow the same code to be reused for AH UI and Standalone UI
function private.CreateFrames()

	--Create the base frame for external GUI
	local base = CreateFrame("Frame", "BeanCounterBaseFrame", UIParent)
	base:SetFrameStrata("HIGH")
	base:SetBackdrop({
		bgFile = "Interface/Tooltips/ChatBubble-Background",
		edgeFile = "Interface/Tooltips/ChatBubble-BackDrop",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 32, right = 32, top = 32, bottom = 32 }
	})
	base:SetBackdropColor(0,0,0, 1)
	base:Hide()
	
	base:SetPoint("CENTER", UIParent, "CENTER")
	base:SetWidth(834.5)
	base:SetHeight(450)
	
	--base:SetToplevel(true)
	base:SetMovable(true)
	base:EnableMouse(true)
	base.Drag = CreateFrame("Button", nil, base)
	base.Drag:SetPoint("TOPLEFT", base, "TOPLEFT", 10,-5)
	base.Drag:SetPoint("TOPRIGHT", base, "TOPRIGHT", -10,-5)
	base.Drag:SetHeight(6)
	base.Drag:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")

	base.Drag:SetScript("OnMouseDown", function() base:StartMoving() end)
	base.Drag:SetScript("OnMouseUp", function() base:StopMovingOrSizing() private.setter("configator.left", base:GetLeft()) private.setter("configator.top", base:GetTop()) end)
	
	base.DragBottom = CreateFrame("Button",nil, base)
	base.DragBottom:SetPoint("BOTTOMLEFT", base, "BOTTOMLEFT", 10,5)
	base.DragBottom:SetPoint("BOTTOMRIGHT", base, "BOTTOMRIGHT", -10,5)
	base.DragBottom:SetHeight(6)
	base.DragBottom:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")

	base.DragBottom:SetScript("OnMouseDown", function() base:StartMoving() end)
	base.DragBottom:SetScript("OnMouseUp", function() base:StopMovingOrSizing() private.setter("configator.left", base:GetLeft()) private.setter("configator.top", base:GetTop()) end)
			
	--Launch BeanCounter GUI Config frame
	base.Config = CreateFrame("Button", nil, base, "OptionsButtonTemplate")
	base.Config:SetPoint("BOTTOMRIGHT", base, "BOTTOMRIGHT", -10, 10)
	base.Config:SetScript("OnClick", function() base:Hide() end)
	base.Config:SetText(_BC('UiDone'))
			
	--Create the Actual Usable Frame
	local frame = CreateFrame("Frame", "BeanCounterUiFrame", base)
	private.frame = frame
	frame:Hide()
	
	private.frame:SetPoint("TOPLEFT", base, "TOPLEFT")
	private.frame:SetWidth(828)
	private.frame:SetHeight(450)	
	
	--Add Title to the Top
	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", frame, "TOPLEFT", 80, -17)
	title:SetText(_BC("UiAddonTitle")) 

	local SelectBox = LibStub:GetLibrary("SelectBox")
	local ScrollSheet = LibStub:GetLibrary("ScrollSheet")
		
	--Add Configuration Button for those who dont use sidebar.
	frame.Config = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.Config:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -139, -13)
	frame.Config:SetScript("OnClick", function() private.GUI() end)
	frame.Config:SetText("Configure")
	
	--ICON box, used to drag item and display ICo for item being searched. Based Appraiser Code
	function frame.IconClicked()
	local objtype, _, link = GetCursorInfo()
		ClearCursor()
		if objtype == "item" then
			local itemID, itemName = link:match("^|c%x+|Hitem:(.-):.*|h%[(.+)%]")
			local itemTexture = select(2, private.getItemInfo(link, "name")) 
			frame.searchBox:SetText(itemName)
			private.searchByItemID(itemID, frame.getCheckboxSettings(), nil, 150, itemTexture, itemName)
		end
	end 
	
	frame.slot = frame:CreateTexture(nil, "BORDER")
	frame.slot:SetPoint("TOPLEFT", frame, "TOPLEFT", 23, -125)
	frame.slot:SetWidth(45)
	frame.slot:SetHeight(45)
	frame.slot:SetTexCoord(0.15, 0.85, 0.15, 0.85)
	frame.slot:SetTexture("Interface\\Buttons\\UI-EmptySlot")

	frame.icon = CreateFrame("Button", nil, frame)
	frame.icon:SetPoint("TOPLEFT", frame.slot, "TOPLEFT", 3, -3)
	frame.icon:SetWidth(38)
	frame.icon:SetHeight(38)
	frame.icon:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp")
	frame.icon:SetScript("OnClick", frame.IconClicked)
	frame.icon:SetScript("OnReceiveDrag", frame.IconClicked)
	--[[tooltip script
	frame.icon:SetScript("OnEnter", function() GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		 if (frame.icon.tootip) then
		    local name, link = frame.icon.tootip[1], frame.icon.tootip[2]
		    GameTooltip:SetHyperlink(link)
		    if (EnhTooltip) then EnhTooltip.TooltipCall(GameTooltip, name, link, -1, 1) end
		else
		    GameTooltip:SetText("Drag and drop an item to search or Type the item name in the search box", 1.0, 1.0, 1.0)
		end        
        end)

	frame.icon:SetScript("OnLeave", function() GameTooltip:Hide() end)]]
	--help text
	frame.slot.help = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.slot.help:SetPoint("LEFT", frame.slot, "RIGHT", 2, 7)
	frame.slot.help:SetText(_BC('HelpGuiItemBox')) --"Drop item into box to search."
	frame.slot.help:SetWidth(100)
			
	--Select box, used to chooose where the stats comefrom we show server/faction/player/all
	frame.SelectBoxSetting = {"1","server"}
	function private.ChangeControls(obj, arg1,arg2,...)
		frame.SelectBoxSetting = {arg1, arg2}
	end
	--Default Server wide
	--Used GLOBALSTRINGS for the horde alliance translations
	local vals = {{"server", private.realmName.." ".._BC('UiData')},{"alliance", FACTION_ALLIANCE.." ".._BC('UiData')},{"horde", FACTION_HORDE.." ".._BC('UiData')},}
	for name,data in pairs(private.serverData) do 
		table.insert(vals,{name, name.." ".._BC('UiData')})
	end	
	
	frame.selectbox = CreateFrame("Frame", "BeanCounterSelectBox", frame)
	frame.selectbox.box = SelectBox:Create("BeanCounterSelectBox", frame.selectbox, 140, private.ChangeControls, vals, "default")
	frame.selectbox.box:SetPoint("TOPLEFT", frame, "TOPLEFT", 4,-80)
	frame.selectbox.box.element = "selectBox"
	frame.selectbox.box:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.selectbox.box:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0,-90)
	frame.selectbox.box:SetText(private.realmName.." ".._BC('UiData'))
	
	--Search box
	frame.searchBox = CreateFrame("EditBox", "BeancountersearchBox", frame, "InputBoxTemplate")
	frame.searchBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 29, -180)
	frame.searchBox:SetAutoFocus(false)
	frame.searchBox:SetHeight(15)
	frame.searchBox:SetWidth(150)
	frame.searchBox:SetScript("OnEnterPressed", function()
		private.startSearch(frame.searchBox:GetText(), frame.getCheckboxSettings())
	end)
	
	--Search Button
	frame.searchButton = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.searchButton:SetPoint("TOPLEFT", frame.searchBox, "BOTTOMLEFT", -6, -1)
	frame.searchButton:SetText(_BC('UiSearch'))
	frame.searchButton:SetScript("OnClick", function()
		private.startSearch(frame.searchBox:GetText(), frame.getCheckboxSettings())
	end)
	--Clicking for BC search --Thanks for the code Rockslice
	function private.ClickBagHook(_,_,button)
		if (frame.searchBox and frame.searchBox:IsVisible()) then
			local bag = this:GetParent():GetID()
			local slot = this:GetID()
			local link = GetContainerItemLink(bag, slot)
			if link then
				local itemID, itemName = link:match("^|c%x+|Hitem:(.-):.*|h%[(.+)%]")
				local itemTexture = select(2, private.getItemInfo(link, "name")) 
				if (button == "LeftButton") and (IsAltKeyDown()) and itemName then
					--debugPrint(itemName, itemID,itemTexture, link)
					frame.searchBox:SetText(itemName)
					private.searchByItemID(itemID, frame.getCheckboxSettings(), nil, 150, itemTexture, itemName) 
				end
			end
		end
	end	
	Stubby.RegisterFunctionHook("ContainerFrameItemButton_OnModifiedClick", -50, private.ClickBagHook)	
	
	function private.ClickLinkHook(_, _, _, link, button)
		if (frame.searchBox and frame.searchBox:IsVisible()) then
			if link then
				local itemID, itemName = link:match("^|c%x+|Hitem:(.-):.*|h%[(.+)%]")
				local itemTexture = select(2, private.getItemInfo(link, "name")) 
				if (button == "LeftButton") and (IsAltKeyDown()) and itemName then
					--debugPrint(itemName, itemID,itemTexture, link)
					frame.searchBox:SetText(itemName)
					private.searchByItemID(itemID, frame.getCheckboxSettings(), nil, 150, itemTexture, itemName) 
				end
			end
		end
	end
	Stubby.RegisterFunctionHook("ChatFrame_OnHyperlinkShow", -50, private.ClickLinkHook)
	
	--Check boxes to narrow our search
	frame.exactCheck = CreateFrame("CheckButton", "BeancounterexactCheck", frame, "OptionsCheckButtonTemplate")
	frame.exactCheck:SetChecked(private.getOption("util.beancounter.ButtonExactCheck")) --get the last used checked/unchecked value Then use below script to store state changes
	frame.exactCheck:SetScript("OnClick", function() local set if frame.exactCheck:GetChecked() then set = true end private.setOption("util.beancounter.ButtonExactCheck", set) end)
	getglobal("BeancounterexactCheckText"):SetText(_BC('UiExactNameSearch'))
	frame.exactCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 19, -217)

	--search classic data
	frame.classicCheck = CreateFrame("CheckButton", "BeancounterclassicCheck", frame, "OptionsCheckButtonTemplate")
	frame.classicCheck:SetChecked(false) --Set this to false We only want this to be true/searchabe if there is a classic DB to search
	frame.classicCheck:SetScript("OnClick", function() local set if frame.classicCheck:GetChecked() then set = true end private.setOption("util.beancounter.ButtonClassicCheck", set) end)
	getglobal("BeancounterclassicCheckText"):SetText(_BC('UiClassicCheckBox'))
	frame.classicCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 19, -242)	
	frame.classicCheck:Hide()
	--no need to show this button if theres no classic data to search
	if BeanCounterAccountDB then
		if BeanCounterAccountDB[private.realmName] then 
			frame.classicCheck:Show() --Show id classic has server data
			frame.classicCheck:SetChecked(private.getOption("util.beancounter.ButtonClassicCheck")) --Recall last checked state
		end
	end
	
	--search bids
	frame.bidCheck = CreateFrame("CheckButton", "BeancounterbidCheck", frame, "OptionsCheckButtonTemplate")
	frame.bidCheck:SetChecked(private.getOption("util.beancounter.ButtonBidCheck"))
	frame.bidCheck:SetScript("OnClick", function() local set if frame.bidCheck:GetChecked() then set = true end private.setOption("util.beancounter.ButtonBidCheck", set) end)
	getglobal("BeancounterbidCheckText"):SetText(_BC('UiBids'))
	frame.bidCheck:SetScale(0.85)
	frame.bidCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 25, -335)
	
	frame.bidFailedCheck = CreateFrame("CheckButton", "BeancounterbidFailedCheck", frame, "OptionsCheckButtonTemplate")
	frame.bidFailedCheck:SetChecked(private.getOption("util.beancounter.ButtonBidFailedCheck"))
	frame.bidFailedCheck:SetScript("OnClick", function() local set if frame.bidFailedCheck:GetChecked() then set = true end private.setOption("util.beancounter.ButtonBidFailedCheck", set) end)
	frame.bidFailedCheck:SetScale(0.85)
	getglobal("BeancounterbidFailedCheckText"):SetText(_BC('UiOutbids'))
	frame.bidFailedCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 25, -435)
	
	--search Auctions
	frame.auctionCheck = CreateFrame("CheckButton", "BeancounterauctionCheck", frame, "OptionsCheckButtonTemplate")
	frame.auctionCheck:SetChecked(private.getOption("util.beancounter.ButtonAuctionCheck"))
	frame.auctionCheck:SetScript("OnClick", function() local set if frame.auctionCheck:GetChecked() then set = true end private.setOption("util.beancounter.ButtonAuctionCheck", set) end)
	getglobal("BeancounterauctionCheckText"):SetText(_BC('UiAuctions'))
	frame.auctionCheck:SetScale(0.85)
	frame.auctionCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 25, -360)
	
	frame.auctionFailedCheck = CreateFrame("CheckButton", "BeancounterauctionFailedCheck", frame, "OptionsCheckButtonTemplate")
	frame.auctionFailedCheck:SetChecked(private.getOption("util.beancounter.ButtonAuctionFailedCheck"))
	frame.auctionFailedCheck:SetScript("OnClick", function() local set if frame.auctionFailedCheck:GetChecked() then set = true end private.setOption("util.beancounter.ButtonAuctionFailedCheck", set) end)
	frame.auctionFailedCheck:SetScale(0.85)
	getglobal("BeancounterauctionFailedCheckText"):SetText(_BC('UiFailedAuctions')) 
	frame.auctionFailedCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 25, -460)
	
	
	
	--[[search Purchases (vendor/trade)
	frame.buyCheck = CreateFrame("CheckButton", "BeancounterbuyCheck", frame, "OptionsCheckButtonTemplate")
	frame.buyCheck:SetChecked(true)
	getglobal(BeancounterbuyCheck:GetName().."Text"):SetText("Buys")
	frame.buyCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 19, -255)
	--search Sold (vendor/trade)
	frame.sellCheck = CreateFrame("CheckButton", "BeancountersellCheck", frame, "OptionsCheckButtonTemplate")
	frame.sellCheck:SetChecked(true)
	getglobal(BeancountersellCheck:GetName().."Text"):SetText("Sold")
	frame.sellCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 19, -330)]]
		
	--Create the results window
	frame.resultlist = CreateFrame("Frame", nil, frame)
	frame.resultlist:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	
	frame.resultlist:SetBackdropColor(0, 0, 0.0, 0.5)
	frame.resultlist:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 187, 417.5)
	frame.resultlist:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 3, 0)
	frame.resultlist:SetPoint("BOTTOM", frame, "BOTTOM", 0, 37)
	
	--Scripts that are executed when we mouse over a TOOLTIP frame	
	function private.scrollSheetOnEnter(button, row, index)
		--print("row",row, "index", index)
		--print(frame.resultlist.sheet.rows[row][index]:GetText())
		local link, name
		link = frame.resultlist.sheet.rows[row][index]:GetText() or "FAILED LINK"
		if link:match("^(|c%x+|H.+|h%[.+%])") then
			name = string.match(link, "^|c%x+|H.+|h%[(.+)%]")
		end
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
		if frame.resultlist.sheet.rows[row][index]:IsShown()then --Hide tooltip for hidden cells
			if link and name then
				GameTooltip:SetHyperlink(link)
				if (EnhTooltip) then EnhTooltip.TooltipCall(GameTooltip, name, link, -1, 1) end
			else
				GameTooltip:SetText("Unable to get Tooltip Info", 1.0, 1.0, 1.0)
			end
		end			
        end
	function private.scrollSheetOnLeave(button, row, index)
			GameTooltip:Hide()
	end
	--records the column width changes
	 --store width by header name, that way if column reorginizing is added we apply size to proper column
	function private.onResize(self, column,  width)
		if not width then 
			private.setOption("columnwidth."..self.labels[column]:GetText(), "default") --reset column if no width is passed. We use CTRL+rightclick to reset column
			self.labels[column].button:SetWidth(private.getOption("columnwidth."..self.labels[column]:GetText()))
		else
			private.setOption("columnwidth."..self.labels[column]:GetText(), width)
		end
	end
		
	--localize UI text
	local Buyer, Seller = string.match(_BC('UiBuyerSellerHeader'), "(.*)/(.*)")
	frame.resultlist.sheet = ScrollSheet:Create(frame.resultlist, {
		{ _BC('UiNameHeader'), "TOOLTIP",  private.getOption("columnwidth.".._BC('UiNameHeader')) },
		{ _BC('UiTransactions'), "TEXT", private.getOption("columnwidth.".._BC('UiTransactions')) },
		
		{_BC('UiBidTransaction') , "COIN", private.getOption("columnwidth.".._BC('UiBidTransaction')) },
		{ _BC('UiBuyTransaction') , "COIN", private.getOption("columnwidth.".._BC('UiBuyTransaction')) },
		{ _BC('UiNetHeader'), "COIN", private.getOption("columnwidth.".._BC('UiNetHeader')) },
		{ _BC('UiQuantityHeader'), "TEXT", private.getOption("columnwidth.".._BC('UiQuantityHeader')) },
		{ _BC('UiPriceper'), "COIN", private.getOption("columnwidth.".._BC('UiPriceper')) }, 
		
		{ "|CFFFFFF00"..Seller.."/|CFF4CE5CC"..Buyer, "TEXT", private.getOption("columnwidth.".."|CFFFFFF00"..Seller.."/|CFF4CE5CC"..Buyer) },
				
		{ _BC('UiDepositTransaction'), "COIN", private.getOption("columnwidth.".._BC('UiDepositTransaction')) },
		{ _BC("UiFee"), "COIN", private.getOption("columnwidth.".._BC("UiFee")) }, 
		{ _BC('UiReason'), "TEXT", private.getOption("columnwidth.".._BC('UiReason')) }, 
		{ _BC('UiDateHeader'), "text", private.getOption("columnwidth.".._BC('UiDateHeader')) },
	}, private.scrollSheetOnEnter, private.scrollSheetOnLeave, nil, private.onResize)
		
	
	--All the UI settings are stored here. We then split it to get the appropriate search settings
	function frame.getCheckboxSettings()
		return {["selectbox"] = frame.SelectBoxSetting , ["exact"] = frame.exactCheck:GetChecked(), ["classic"] = frame.classicCheck:GetChecked(), 
			["bid"] = frame.bidCheck:GetChecked(), ["failedbid"] = frame.bidFailedCheck:GetChecked(), ["auction"] = frame.auctionCheck:GetChecked(),
			["failedauction"] = frame.auctionFailedCheck:GetChecked() 
			}
	end
	
	local data = {}
	local style = {}
	local temp ={}
	local tbl = {}
	--This is all handled by ITEMIDS need to remove/rename this to be a utility to convert text searches to itemID searches
	function private.startSearch(itemName, settings, queryReturn, count, itemTexture) --queryReturn is passed by the externalsearch routine, when an addon wants to see what data BeanCounter knows
		--Run the compression function once per session, use first search as trigger
		if not private.compressed then private.refreshItemIDArray() private.compactDB() private.compressed = true end
		
		if not itemName then return end
		tbl = {}
		for itemKey, itemLink in pairs(BeanCounterDB["ItemIDArray"]) do
			if itemLink:lower():find(itemName:lower(), 1, true)  then
				if settings.exact and frame.searchBox:GetText() ~= "" then --if the search field is blank do not exact check
					local name = itemLink:match("^|c%x+|H.+|h%[(.+)%].*") or "failed name"
					if itemName:lower() == name:lower() then
						local itemID = string.split(":", itemKey)--Create a list of itemIDs that match the search text
						tbl[itemID] = itemID --Since its possible to have the same itemID returned multiple times this will only allow one instance to be recorded
						break
					end
				else
					local itemID = string.split(":", itemKey)--Create a list of itemIDs that match the search text
					tbl[itemID] = itemID --Since its possible to have the same itemID returned multiple times this will only allow one instance to be recorded
				end
			end
		end
		
		if queryReturn then --need to return the ItemID results to calling function
			return(private.searchByItemID(tbl, settings, queryReturn, count, itemTexture, itemName))
		else
			--get the itemTexture for display in the drop box
			for i, itemLink in pairs(BeanCounterDB.ItemIDArray) do
				if itemLink:lower():match("%[("..itemName:lower()..")%]")then
					itemTexture = select(2, private.getItemInfo(itemLink, "name"))
					break
				end
			end
			private.searchByItemID(tbl, settings, queryReturn, count, itemTexture, itemName)
		end
	end
	
	function private.searchByItemID(id, settings, queryReturn, count, itemTexture, classic)
	
		if not id then return end
		if not settings then settings = frame.getCheckboxSettings() end
		if not count then count = 500 end --count determines how many results we show or display High # ~to display all
	
		tbl = {}
		if type(id) == "table" then --we can search for a sinlge itemID or an array of itemIDs
			for i,v in pairs(id)do
				table.insert(tbl, tostring(v))
			end
		else
			tbl[1] = tostring(id)
		end

		data = {}
		style = {}
		data.temp = {}
		data.temp.completedAuctions = {}
		data.temp["completedBids/Buyouts"] = {}
		data.temp.failedAuctions = {}
		data.temp.failedBids = {}
		
		--debugPrint(id, settings, queryReturn, count, itemTexture)
		
		--Retrives all matching results
		local link
		for i in pairs(private.serverData) do
			if settings.selectbox[2] == "alliance" and private.serverData[i]["faction"] and private.serverData[i]["faction"]:lower() ~= settings.selectbox[2] then
				--If looking for alliance and player is not alliance fall into this null
			elseif settings.selectbox[2] == "horde" and private.serverData[i]["faction"] and private.serverData[i]["faction"]:lower() ~= settings.selectbox[2] then
				--If looking for horde and player is not horde fall into this null
			elseif (settings.selectbox[2] ~= "server" and settings.selectbox[2] ~= "alliance" and settings.selectbox[2] ~= "horde") and i ~= settings.selectbox[2] then
				--If we are not doing a whole server search and the chosen search player is not "i" then we fall into this null
				--otherwise we search the server or toon as normal
			else
				for _, id in pairs(tbl) do
					if settings.auction and private.serverData[i]["completedAuctions"][id] then
						for index, itemKey in pairs(private.serverData[i]["completedAuctions"][id]) do
							for _, text in ipairs(itemKey) do
								table.insert(data.temp.completedAuctions, {i, id, index,text})
							end
						end
					end
					if settings.failedauction and private.serverData[i]["failedAuctions"][id] then
						for index, itemKey in pairs(private.serverData[i]["failedAuctions"][id]) do
							for _, text in ipairs(itemKey) do
								table.insert(data.temp["failedAuctions"], {i, id, index,text})
							end
						end
					end
					if settings.bid and private.serverData[i]["completedBids/Buyouts"][id] then
						for index, itemKey in pairs(private.serverData[i]["completedBids/Buyouts"][id]) do
							for _, text in ipairs(itemKey) do
								table.insert(data.temp["completedBids/Buyouts"], {i, id, index,text})
							end
						end
					end
					if settings.failedbid and private.serverData[i]["failedBids"][id] then
						for index, itemKey in pairs(private.serverData[i]["failedBids"][id]) do
							for _, text in ipairs(itemKey) do
								table.insert(data.temp.failedBids, {i, id, index,text})
							end
							
						end
					end
				end
			end
		end
		--reduce results to the latest XXXX ammount based on how many user wants returned or displayed
		if #data.temp.completedAuctions > count then
			data.temp.completedAuctions = private.reduceSize(data.temp.completedAuctions, count)
		end
		if #data.temp.failedAuctions > count then
			data.temp.failedAuctions = private.reduceSize(data.temp.failedAuctions, count)
		end
		if #data.temp["completedBids/Buyouts"] > count then
			data.temp["completedBids/Buyouts"] = private.reduceSize(data.temp["completedBids/Buyouts"], count)
		end
		if #data.temp.failedBids > count then
			data.temp.failedBids = private.reduceSize(data.temp.failedBids, count)
		end
		
		--Return Data as raw if requesting addon wants un-formated data --FAST
		if queryReturn == "none" then
			for i,v in pairs(data.temp)do
				for a,b in pairs(v)do
					b[5] = b[4]:match(".*;(.-);") --Makes the time stamp more accesable so addon can sort easier
				end
			end
			return data.temp
		end
		--Format Data for display via scroll frame or if requesting addon wants formated data  --SLOW
		local dateString = private.getOption("dateString") or "%c"
		for i,v in pairs(data.temp.completedAuctions) do
			local match = true
			--to provide exact match filtering for of the tems we compare names to the itemKey on API searches
			if settings.exact and settings.itemKey then
				if v[3]:match(".*:("..settings.itemKey.."):.-") then
					-- do nothing and add item to data table
				else
					match = false --we want exact matches and this is not one
				end
			end
			
			if match then
				table.insert(data, private.COMPLETEDAUCTIONS(v[2], v[3], v[4], settings))
				if not queryReturn then --do not create style tables if this data is being returned to an addon
					style[#data] = {}
					style[#data][12] = {["date"] = dateString}
					style[#data][2] = {["textColor"] = {0.3, 0.9, 0.8}}
					style[#data][8] ={["textColor"] = {0.3, 0.9, 0.8}}
				end
			end
		end
		for i,v in pairs(data.temp.failedAuctions) do
			local match = true
			--to provide exact match filtering for of the tems we compare names to the itemKey on API searches
			if settings.exact and settings.itemKey then
				if v[3]:match(".*:("..settings.itemKey.."):.-") then
					-- do nothing and add item to data table
				else
					match = false --we want exact matches and this is not one
				end
			end
			
			if match then
				table.insert(data, private.FAILEDAUCTIONS(v[2], v[3], v[4]))
				if not queryReturn then
					style[#data] = {}
					style[#data][12] = {["date"] = dateString}
					style[#data][2] = {["textColor"] = {1,0,0}}
					style[#data][8] ={["textColor"] = {1,0,0}}
				end
			end
		end
		for i,v in pairs(data.temp["completedBids/Buyouts"]) do
			local match = true
			--to provide exact match filtering for of the tems we compare names to the itemKey on API searches
			if settings.exact and settings.itemKey then
				if v[3]:match(".*:("..settings.itemKey.."):.-") then
					-- do nothing and add item to data table
				else
					match = false --we want exact matches and this is not one
				end
			end
			
			if match then
				table.insert(data, private.COMPLETEDBIDSBUYOUTS(v[2], v[3], v[4]))
				if not queryReturn then
					style[#data] = {}
					style[#data][12] = {["date"] = dateString}
					style[#data][2] = {["textColor"] = {1,1,0}}
					style[#data][8] ={["textColor"] = {1,1,0}}
				end
			end
		end
		for i,v in pairs(data.temp.failedBids) do
			local match = true
			--to provide exact match filtering for of the tems we compare names to the itemKey on API searches
			if settings.exact and settings.itemKey then
				if v[3]:match(".*:("..settings.itemKey.."):.-") then
					-- do nothing and add item to data table
				else
					match = false --we want exact matches and this is not one
				end
			end
			
			if match then
				table.insert(data, private.FAILEDBIDS(v[2], v[3], v[4]))
				if not queryReturn then
					style[#data] = {}
					style[#data][12] = {["date"] = dateString}
					style[#data][2] = {["textColor"] = {1,1,1}}
					style[#data][8] ={["textColor"] = {1,1,1}}
				end
			end
		end
		
		--BC CLASSIC DATA SEARCH Only usable when a plain text search is used
		if settings.classic and classic and not tonumber(classic)then
			data, style = private.classicSearch(data, style, classic, settings, dateString)
		end
		if not queryReturn then --this lets us know it was not an external addon asking for beancounter data
			frame.resultlist.sheet:SetData(data, style) --Set the GUI scrollsheet
			frame.resultlist.sheet:ButtonClick(12, "click") --This tells the scroll sheet to sort by column 11 (time)
			frame.resultlist.sheet:ButtonClick(12, "click") --and fired again puts us most recent to oldest
			
			--If the user has scrolled to far and search is not showing scroll back to starting position
			if  not frame.resultlist.sheet.rows[1][1]:IsShown() then
				frame.resultlist.sheet.panel:ScrollToCoords(0,0)
			end
		else --If Query return is true but not == to "none" then we return a formated table
			return(data)
		end
	end
	function private.reduceSize(tbl, count)
		--The data provided is from multiple toons tables, so we need to resort the merged data back into sequential time order
		table.sort(tbl, function(a,b) return a[4]:match(".*;(%d+);.-") > b[4]:match(".*;(%d+);.-") end)
		tbl.sort = {}
		for i = 1, count do
			table.insert(tbl.sort, tbl[i])
		end
		return tbl.sort
	end

	--To simplify having two seperate search routines, the Data creation of each table has been made a local function
		function private.COMPLETEDAUCTIONS(id, itemKey, text) --this passes the player, itemID and text as string or as an already seperated table
				tbl = text
				if type(text) == "string" then tbl = private.unpackString(text) end
			
				local pricePer = 0
				local stack = tonumber(tbl[1]) or 0
				if stack > 0 then pricePer =  (tbl[2]-tbl[3]+tbl[4])/stack end
								
				local key, suffix = itemKey:match("^item:(%d-):.+:(.+):.-")
				local itemLink =  BeanCounterDB["ItemIDArray"][key:lower()..":"..suffix]
				if not itemLink then itemLink = private.getItemInfo(id, "name") end--if not in our DB ask the server
				
				return({
					itemLink or "Failed to get Link", --itemname
					_BC('UiAucSuccessful'), --status
					 
					tonumber(tbl[6]) or 0,  --bid
					tonumber(tbl[5]) or 0,  --buyout
					tonumber(tbl[2]), --Profit,
					tonumber(stack),  --stacksize
					tonumber(pricePer), --Profit/per

					tbl[7],  --seller/seller

					tonumber(tbl[3]), --deposit
					tonumber(tbl[4]), --fee
					tbl[9], --current wealth
					tbl[8], --time, --Make this a user choosable option.
				})
		end
		--STACK; BUY; BID; DEPOSIT; TIME; DATE; WEALTH
		function private.FAILEDAUCTIONS(id, itemKey, text)
				tbl = text
				if type(text) == "string" then tbl = private.unpackString(text) end
				
				local key, suffix = itemKey:match("^item:(%d-):.+:(.+):.-")
				local itemLink =  BeanCounterDB["ItemIDArray"][key:lower()..":"..suffix]
				if not itemLink then itemLink = private.getItemInfo(id, "name") end--if not in our DB ask the server
				
				return({
					itemLink, --itemname
					_BC('UiAucExpired'), --status

					tonumber(tbl[3]) or 0, --bid
					tonumber(tbl[2]) or 0, --buyout
					0, --money,
					tonumber(tbl[1]) or 0,
					0, --Profit/per

					"...",  --seller/buyer

					tonumber(tbl[4]) or 0, --deposit
					0, --fee
					tbl[6], --current wealth
					tbl[5], --time,
				})
		end
		function private.COMPLETEDBIDSBUYOUTS(id, itemKey, text)
				tbl = text
				if type(text) == "string" then tbl= private.unpackString(text) end
				
				local pricePer, stack, text = 0, tonumber(tbl[1]), _BC('UiWononBuyout')
				--If the auction was won on bid change text, and adjust ProfitPer
				if tbl[5] ~= tbl[4] then	
					text = _BC('UiWononBid') 
					if stack > 0 then	pricePer = (tbl[5]-tbl[2]+tbl[3])/stack end
				else --Devide by BUY price if it was won on Buy
					if stack > 0 then	pricePer = (tbl[4]-tbl[2]+tbl[3])/stack end
				end
				
				local key, suffix = itemKey:match("^item:(%d-):.+:(.+):.-")
				local itemLink =  BeanCounterDB["ItemIDArray"][key..":"..suffix]
				if not itemLink then itemLink = private.getItemInfo(id, "name") end--if not in our DB ask the server
				
				return({
					itemLink, --itemname
					text, --status

					tonumber(tbl[5]), --bid
					tonumber(tbl[4]), --buyout
					tonumber(0), --money,
					tonumber(stack),  --stacksize
					pricePer, --Profit/per

					tbl[6],   --seller/buyer

					tonumber(tbl[2]), --deposit
					tonumber(tbl[3]), --fee
					tbl[8], --current wealth
					tbl[7], --time,
				})
		end
		function private.FAILEDBIDS(id, itemKey, text)
				tbl = text
				if type(text) == "string" then tbl= private.unpackString(text) end

				local key, suffix = itemKey:match("^item:(%d-):.+:(.+):.-")
				local itemLink =  BeanCounterDB["ItemIDArray"][key:lower()..":"..suffix]
				if not itemLink then itemLink = private.getItemInfo(id, "name") end--if not in our DB ask the server
				return({
					itemLink, --itemname
					_BC('UiOutbid'), --status

					tonumber(tbl[1]), --bid
					0, --buyout
					0, --money,
					0, --stack
					0, --Profit/per

					"-",  --seller/buyer

					0, --deposit
					0, --fee
					tbl[3], --current wealth
					tbl[2], --time,
				})
		end
	--Only used by classic search now	
	function private.fragmentsearch(compare, itemName, exact, classic)
		if exact and frame.searchBox:GetText() ~= "" then 
			if compare:lower() == itemName:lower() then return true end --If we are searching older classic data 
		else
			local match = (compare:lower():find(itemName:lower(), 1, true) ~= nil)
			return match
		end
	end
	
	private.CreateMailFrames()

end

function private.CreateMailFrames()
	local frame = CreateFrame("Frame", "BeanCounterMail", MailFrame)
	frame:Hide()
	private.MailGUI = frame
	local count, total = 0,0
	
	frame:SetPoint("TOPLEFT", MailFrame, "TOPLEFT", 19,-71)
	frame:SetPoint("BOTTOMRIGHT", MailFrame, "BOTTOMRIGHT", -39,115)
	--Add Title to the Top
	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("CENTER", frame, "CENTER", 0,60)
	title:SetText("BeanCounter is recording your mail")
	
	local body = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	body:SetPoint("CENTER", frame, "CENTER", 0, 30)
	body:SetText("Please do not close the mail frame or")
	local body1 = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	body1:SetPoint("CENTER", frame, "CENTER", 0,0)
	body1:SetText("Auction Items will not be recorded")
		
	local countdown = frame:CreateFontString("BeanCounterMailCount", "OVERLAY", "GameFontNormalLarge")
	private.CountGUI = countdown
	countdown:SetPoint("CENTER", frame, "CENTER", 0, -60)
	countdown:SetText("Recording: "..count.." of "..total.." items")
end

--ONLOAD Error frame, used to show missmatched DB versus client errors that stop BC load NEEDS LOCALIZATION
function private.CreateErrorFrames(error, expectedVersion, playerVersion)
	frame = private.scriptframe
	frame.loadError = CreateFrame("Frame", nil, UIParent)
	frame.loadError:SetFrameStrata("HIGH")
	frame.loadError:SetBackdrop({
		bgFile = "Interface/Tooltips/ChatBubble-Background",
		edgeFile = "Interface/Tooltips/ChatBubble-BackDrop",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 32, right = 32, top = 32, bottom = 32 }
	})
	frame.loadError:SetBackdropColor(0,0,0, 1)
	frame.loadError:Show()

	frame.loadError:SetPoint("CENTER", UIParent, "CENTER")
	frame.loadError:SetWidth(300)
	frame.loadError:SetHeight(200)

	frame.loadError.close = CreateFrame("Button", nil, frame.loadError, "OptionsButtonTemplate")
	frame.loadError.close:SetPoint("BOTTOMRIGHT", frame.loadError, "BOTTOMRIGHT", -10, 10)
	frame.loadError.close:SetScript("OnClick", function() frame.loadError:Hide() end)
	frame.loadError.close:SetText("Ok")

	frame.loadError.text = frame.loadError:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.loadError.text:SetPoint("LEFT", frame.loadError, "LEFT", 25, 30)
	frame.loadError.text:SetWidth(250)
	if error == "bean older" then
		print ("Your database has been created with a newer version of BeanCounter than the one you are currently using. BeanCounter will not load to prevent possibly corrupting the saved data. Please go to http://auctioneeraddon.com and update to the latest version")
		frame.loadError.text:SetText("Your database has been created with a newer version of BeanCounter "..playerVersion.." than the one you are currently using. "..expectedVersion.." BeanCounter will not load to prevent possibly corrupting the saved data. Please go to http://auctioneeraddon.com and update to the latest version")
	elseif error == "failed update" then
		print ("Your database has failed to update. BeanCounter expects "..private.version.."BeanCounter will not load to prevent possibly corrupting the saved data. Please go to the forums at http://auctioneeraddon.com")
		frame.loadError.text:SetText("Your database has failed to update. BeanCounter expects "..expectedVersion.." But the player's version is still "..playerVersion.." BeanCounter will not load to prevent possibly corrupting the saved data. Please go to the forums at http://auctioneeraddon.com")
	else
		frame.loadError.text:SetText("Unknow Error on loading. BeanCounter will not load to prevent possibly corrupting the saved data. Please go to the forums at http://auctioneeraddon.com")
	end
	frame.loadError.title = frame.loadError:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	frame.loadError.title:SetPoint("CENTER", frame.loadError, "TOP", 0,-15)
	frame.loadError.title:SetText("|CFFFF0000 BEANCOUNTER WARNING")
end

--Taken from AucCore to make beancounter Standalone, Need to remove Redudundant stuff
function private.AddTab(tabButton, tabFrame)
	-- Count the number of auction house tabs (including the tab we are going
	-- to insert).
	local tabCount = 1;
	while (getglobal("AuctionFrameTab"..(tabCount))) do
		tabCount = tabCount + 1;
	end

	-- Find the correct location to insert our Search Auctions and Post Auctions
	-- tabs. We want to insert them at the end or before BeanCounter's
	-- Transactions tab.
	local tabIndex = 1;
	while (getglobal("AuctionFrameTab"..(tabIndex)) and
		   getglobal("AuctionFrameTab"..(tabIndex)):GetName() ~= "AuctionFrameTabTransactions") do
		tabIndex = tabIndex + 1;
	end

	-- Make room for the tab, if needed.
	for index = tabCount, tabIndex + 1, -1  do
		setglobal("AuctionFrameTab"..(index), getglobal("AuctionFrameTab"..(index - 1)));
		getglobal("AuctionFrameTab"..(index)):SetID(index);
	end

	-- Configure the frame.
	tabFrame:SetParent("AuctionFrame");
	tabFrame:SetPoint("TOPLEFT", "AuctionFrame", "TOPLEFT", 0, 0);
	private.relevelFrame(tabFrame);

	-- Configure the tab button.
	setglobal("AuctionFrameTab"..tabIndex, tabButton);
	tabButton:SetParent("AuctionFrame");
	tabButton:SetPoint("TOPLEFT", getglobal("AuctionFrameTab"..(tabIndex - 1)):GetName(), "TOPRIGHT", -8, 0);
	tabButton:SetID(tabIndex);
	tabButton:Show();

	-- Update the tab count.
	PanelTemplates_SetNumTabs(AuctionFrame, tabCount)
end

function private.relevelFrame(frame)
	return private.relevelFrames(frame:GetFrameLevel() + 2, frame:GetChildren())
end

function private.relevelFrames(myLevel, ...)
	for i = 1, select("#", ...) do
		local child = select(i, ...)
		child:SetFrameLevel(myLevel)
		private.relevelFrame(child)
	end
end

function private.processTooltip(frame, name, itemLink, quality, quantity, cost, ...)
	
	if not itemLink then return end
	local itemString, itemID, suffix = itemLink:match("^|c%x+|H(item:(%d+):.+:(.-):.+)|h%[.+%].-")
	
	--print(itemID, type(itemID))
	local quan, bid, reason, D
	
	if private.playerData["completedBids/Buyouts"][itemID] and private.playerData["completedBids/Buyouts"][itemID][itemString] then
		for i,v in pairs(private.playerData["completedBids/Buyouts"][itemID][itemString]) do
			--print(i,v)
			quan, bid, D, reason = v:match("^(.-);.*;(.-);.-;(.-);(%w*)")
			D= date("%c", D)
		end
	end
	
	if not reason then return end
	
	if tonumber(quan) == tonumber(quantity) then
		EnhTooltip.AddLine( string.format("Last bought for: %s { %s }", reason, D ), tonumber(bid))
		EnhTooltip.LineColor(0.5, 0.5, 0)
	end
end


local tbl = {}
--Search BeancounterClassic Data
function private.classicSearch(data, style, itemName, settings, dateString)
	if settings.auction or settings.failedauction then
		for name, v in pairs(BeanCounterAccountDB[private.realmName]["sales"]) do
			for index, text in pairs(v) do

				tbl= {strsplit(";", text)}
				local match = false
				match = private.fragmentsearch(name, itemName, settings.exact, "classic")
				if match then
					--    1    2        3         4       5          6          7           8        9       10
					--"time;saleResult;quantity;bid;buyout;netPrice;price;isBuyout;buyerName;sellerId"
					--"1173571623;1;1;11293;22000;-1500;<nil>;<nil>;<nil>;2"
					--tbl[2]  0 = sold 1 exp 3 = CANCELED
					local status = _BC('UiAucSuccessful').." CL"

					if tbl[2] == "1" then
						if not settings.failedauction then break end --used to filter Exp auc 
						status = _BC('UiAucExpired').." CL"
						tbl[9] = "-"
					else   
						if not settings.auction then break end --used to filter comp auc if user only wants expend
					end
					
					local stack = tonumber(tbl[3]) or 1
					local price = tonumber(tbl[6]) or 0
					if stack < 1 then    stack = 1 end
					local pricePer = (price/stack)

					table.insert(data,{
							name, --itemname
							status, --status

							tonumber(tbl[4]) or 0,  --bid
							tonumber(tbl[5]) or 0, --buyout
							price, --money,
							tonumber(stack),  --stacksize
							pricePer, --Profit/per

							tbl[9],  --seller/buyer

							0, --deposit
							0,  --fee
							0, --current wealth
							tbl[1], --time,
							})   
							
					style[#data] = {}
					style[#data][12] = {["date"] = dateString}
					if status == _BC('UiAucSuccessful').." CL" then
						style[#data][2] = {["textColor"] = {0.3, 0.9, 0.8}}
						style[#data][8] ={["textColor"] = {0.3, 0.9, 0.8}}
					else
						style[#data][2] = {["textColor"] = {1,0,0}}
						style[#data][8] ={["textColor"] = {1,0,0}}
					end

				end
			end
		end
	end
	
	if settings.bid then
		for name, v in pairs(BeanCounterAccountDB[private.realmName]["purchases"]) do
			for index, text in pairs(v) do
				tbl= {strsplit(";", text)}
				local match = false
				match = private.fragmentsearch(name, itemName, settings.exact, "classic")
				if match then
					--    1                 2        3         4       5          6          7           8        9       10
					--time; quantity;value;seller;isBuyout;buyerId
					--"1178840165;1;980000;Eruder;1;5",
					local bid, buyout, status = 0,0,"Invalid data"
					if tbl[5] == "1" then --is bid
						status = _BC('UiWononBuyout').." CL"
						buyout = tbl[3]
						bid = 0
					else
						status = _BC('UiWononBid').." CL"
						buyout = 0
						bid = tbl[3]
					end

					table.insert(data,{
							name, --itemname
							status, --status

							tonumber(bid),  --bid
							tonumber(buyout), --buyout
							0, --money,
							tonumber(tbl[2]),  --stacksize,
							tonumber(tbl[3]) / tonumber(tbl[2]) or 1, --Profit/per

							tbl[4],  --seller/buyer

							0,--deposit
							0, --fee
							0, --current wealth
							tbl[1], --time,
							})
					style[#data] = {}
					style[#data][12] = {["date"] = dateString}	
					style[#data][2] = {["textColor"] = {1,1,0}}
					style[#data][8] ={["textColor"] = {1,1,0}}
				end
			end
		end
	end
	return data, style
end

