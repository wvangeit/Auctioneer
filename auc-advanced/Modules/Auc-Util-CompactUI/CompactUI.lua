--[[
	Auctioneer Advanced - Price Level Utility module
	Revision: $Id$
	Version: <%version%>

	This is an addon for World of Warcraft that adds a price level indicator
	to auctions when browsing the Auction House, so that you may readily see
	which items are bargains or overpriced at a glance.

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

local libName = "CompactUI"
local libType = "Util"

AucAdvanced.Modules[libType][libName] = {}
local lib = AucAdvanced.Modules[libType][libName]
local private = {}
local print = AucAdvanced.Print

local data


--[[
The following functions are part of the module's exposed methods:
	GetName()         (required) Should return this module's full name
	CommandHandler()  (optional) Slash command handler for this module
	Processor()       (optional) Processes messages sent by Auctioneer
	ScanProcessor()   (optional) Processes items from the scan manager
*	GetPrice()        (required) Returns estimated price for item link
*	GetPriceColumns() (optional) Returns the column names for GetPrice
	OnLoad()          (optional) Receives load message for all modules

	(*) Only implemented in stats modules; util modules do not provide
]]

function lib.GetName()
	return libName
end

function lib.Processor(callbackType, ...)
	if (callbackType == "config") then
		private.SetupConfigGui(...)
	elseif (callbackType == "auctionui") then
		private.HookAH(...)
	end
end

function lib.OnLoad()
	--print("AucAdvanced: {{"..libType..":"..libName.."}} loaded!")
	AucAdvanced.Settings.SetDefault("util.compactui.activated", false)
	AucAdvanced.Settings.SetDefault("util.compactui.collapse", false)
end

--[[ Local functions ]]--
private.buttons = {}
function private.HookAH()
	if (not AucAdvanced.Settings.GetSetting("util.compactui.activated")) then
		return
	end

	AuctionFrameBrowse_Update = private.MyAuctionFrameUpdate
	local button, lastButton, origButton
	local line

	local NEW_NUM_BROWSE = 14
	for i = 1, NEW_NUM_BROWSE do
		if (i <= NUM_BROWSE_TO_DISPLAY) then
			origButton = getglobal("BrowseButton"..i)
			origButton:Hide()
			_G["BrowseButton"..i] = nil
		else
			origButton = nil
		end
		button = CreateFrame("Button", "BrowseButton"..i, AuctionFrameBrowse)
		button.Orig = origButton
		button.pos = i
		private.buttons[i] = button
		if (i == 1) then
			button:SetPoint("TOPLEFT", 188, -103)
		else
			button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT")
		end
		button:SetWidth(610)
		button:SetHeight(19)
		button:EnableMouse(true)
		if (i % 2 == 0) then
			line = button:CreateTexture()
			line:SetTexture(0.5,0.5,1, 0.1)
			line:SetPoint("TOPLEFT", 0,-1)
			line:SetPoint("BOTTOMRIGHT")
		else
			line = button:CreateTexture()
			line:SetTexture(0,0,0.5, 0.1)
			line:SetPoint("TOPLEFT", 0,-1)
			line:SetPoint("BOTTOMRIGHT")
		end
		button.LineTexture = line
		button.AddTexture = button:CreateTexture()
		button.AddTexture:SetPoint("TOPLEFT", 0,-1)
		button.AddTexture:SetPoint("BOTTOMRIGHT")

		button.Count = button:CreateFontString(nil,nil,"GameFontHighlight")
		button.Count:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
		button.Count:SetWidth(28)
		button.Count:SetHeight(19)
		button.Count:SetJustifyH("RIGHT")
		button.Count:SetFont(STANDARD_TEXT_FONT, 11)
		button.IconButton = CreateFrame("Button", nil, button)
		button.IconButton:SetPoint("TOPLEFT", button, "TOPLEFT", 30, -2)
		button.IconButton:SetWidth(16)
		button.IconButton:SetHeight(16)
		button.IconButton:SetScript("OnEnter", private.IconEnter)
		button.IconButton:SetScript("OnLeave", private.IconLeave)
		button.Icon = button.IconButton:CreateTexture()
		button.Icon:SetPoint("TOPLEFT")
		button.Icon:SetPoint("BOTTOMRIGHT")
		button.Name = button:CreateFontString(nil,nil,"GameFontHighlight")
		button.Name:SetPoint("TOPLEFT", button, "TOPLEFT", 50, 0)
		button.Name:SetWidth(210)
		button.Name:SetHeight(19)
		button.Name:SetJustifyH("LEFT")
		button.Name:SetFont(STANDARD_TEXT_FONT, 11)
		button.rLevel = button:CreateFontString(nil,nil,"GameFontHighlight")
		button.rLevel:SetPoint("TOPLEFT", button.Name, "TOPRIGHT", 2, 0)
		button.rLevel:SetWidth(30)
		button.rLevel:SetHeight(19)
		button.rLevel:SetJustifyH("RIGHT")
		button.rLevel:SetFont(STANDARD_TEXT_FONT, 11)
		button.iLevel = button:CreateFontString(nil,nil,"GameFontHighlight")
		button.iLevel:SetPoint("TOPLEFT", button.rLevel, "TOPRIGHT", 2, 0)
		button.iLevel:SetWidth(30)
		button.iLevel:SetHeight(19)
		button.iLevel:SetJustifyH("RIGHT")
		button.iLevel:SetFont(STANDARD_TEXT_FONT, 11)
		button.tLeft = button:CreateFontString(nil,nil,"GameFontHighlight")
		button.tLeft:SetPoint("TOPLEFT", button.iLevel, "TOPRIGHT", 2, 0)
		button.tLeft:SetWidth(35)
		button.tLeft:SetHeight(19)
		button.tLeft:SetJustifyH("CENTER")
		button.tLeft:SetFont(STANDARD_TEXT_FONT, 11)
		button.Owner = button:CreateFontString(nil,nil,"GameFontHighlight")
		button.Owner:SetPoint("TOPLEFT", button.tLeft, "TOPRIGHT", 2, 0)
		button.Owner:SetWidth(80)
		button.Owner:SetHeight(19)
		button.Owner:SetJustifyH("LEFT")
		button.Owner:SetFont(STANDARD_TEXT_FONT, 11)
		button.Bid = CreateFrame("Frame", "AucAdvancedUtilCompactUIMoneyBid"..i, button, "EnhancedTooltipMoneyTemplate")
		button.Bid.SetMoney = private.SetMoney
		button.Bid:SetPoint("TOPRIGHT", button.Owner, "TOPRIGHT", 122, 0)
		button.Bid:SetWidth(120)
		button.Bid:SetFrameStrata("MEDIUM")
		button.Buy = CreateFrame("Frame", "AucAdvancedUtilCompactUIMoneyBuy"..i, button, "EnhancedTooltipMoneyTemplate")
		button.Buy.SetMoney = private.SetMoney
		button.Buy:SetPoint("TOPRIGHT", button.Bid, "BOTTOMRIGHT", 0, 1)
		button.Buy:SetWidth(120)
		button.Buy:SetFrameStrata("MEDIUM")
		button.Value = button:CreateFontString(nil,nil,"GameFontHighlight")
		button.Value:SetPoint("TOPLEFT", button.Bid, "TOPRIGHT")
		button.Value:SetWidth(45)
		button.Value:SetHeight(19)
		button.Value:SetJustifyH("RIGHT")
		button.Value:SetFont(STANDARD_TEXT_FONT, 11)

		button.SetAuction = private.SetAuction
		button:SetScript("OnClick", private.ButtonClick)

		lastButton = button
	end
	NUM_BROWSE_TO_DISPLAY = NEW_NUM_BROWSE

	local tex
	
	private.candy = {}
	tex = AuctionFrameBrowse:CreateTexture()
	tex:SetTexture(1,1,1, 0.1)
	tex:SetPoint("TOPLEFT", private.buttons[1].rLevel, "TOPLEFT")
	tex:SetPoint("BOTTOMRIGHT", private.buttons[NEW_NUM_BROWSE].rLevel, "BOTTOMRIGHT")
	table.insert(private.candy, tex)
	
	tex = AuctionFrameBrowse:CreateTexture()
	tex:SetTexture(1,1,1, 0.1)
	tex:SetPoint("TOPLEFT", private.buttons[1].tLeft, "TOPLEFT")
	tex:SetPoint("BOTTOMRIGHT", private.buttons[NEW_NUM_BROWSE].tLeft, "BOTTOMRIGHT")
	table.insert(private.candy, tex)

	tex = AuctionFrameBrowse:CreateTexture()
	tex:SetTexture(1,1,1, 0.1)
	tex:SetPoint("TOPLEFT", private.buttons[1].Owner, "TOPRIGHT", 2, 0)
	tex:SetPoint("BOTTOMRIGHT", private.buttons[NEW_NUM_BROWSE].Buy, "BOTTOMRIGHT")
	table.insert(private.candy, tex)

	tex = AuctionFrameBrowse:CreateTexture()
	tex:SetTexture(1,1,0.5, 0.2)
	tex:SetPoint("TOPLEFT", private.buttons[NEW_NUM_BROWSE].Count, "BOTTOMLEFT", 0, -1)
	tex:SetWidth(610)
	tex:SetHeight(38)
	table.insert(private.candy, tex)

	BrowsePrevPageButton:ClearAllPoints()
	BrowsePrevPageButton:SetPoint("BOTTOMRIGHT", tex, "BOTTOMRIGHT", -170, -5)
	BrowseNextPageButton:ClearAllPoints()
	BrowseNextPageButton:SetPoint("BOTTOMRIGHT", tex, "BOTTOMRIGHT", -5, -5)
	BrowseSearchCountText:ClearAllPoints()
	BrowseSearchCountText:SetPoint("BOTTOMRIGHT", tex, "BOTTOMRIGHT", -10, 27)

	local check = CreateFrame("CheckButton", nil, AuctionFrameBrowse, "OptionsCheckButtonTemplate")
	private.PerItem = check
	check:SetChecked(false)
	check:SetPoint("TOPLEFT", tex, "TOPLEFT", 5, -5)
	check:SetScript("OnClick", AuctionFrameBrowse_Update)
	table.insert(private.candy, check)

	local text = AuctionFrameBrowse:CreateFontString(nil,nil,"GameFontNormal")
	text:SetPoint("LEFT", check, "LEFT", 30, 0)
	text:SetText("Show stacks as price per unit")
	table.insert(private.candy, text)

	text = AuctionFrameBrowse:CreateFontString(nil,nil,"GameFontNormalLarge")
	private.PageNum = text
	text:SetPoint("TOPLEFT", BrowsePrevPageButton, "TOPLEFT")
	text:SetPoint("BOTTOMRIGHT", BrowseNextPageButton, "BOTTOMRIGHT")
	text:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE")
	text:SetShadowOffset(1,1)
	table.insert(private.candy, text)
end

function private.SetMoney(me, value, hasBid, highBidder)
	value = math.floor(tonumber(value) or 0)
	if (value == 0) then me:Hide() return end
	me.small = true
	if (AucAdvanced.Settings.GetSetting("util.compactui.collapse")) then
		me.info.showSmallerCoins = false
	else
		me.info.showSmallerCoins = true
	end
	TinyMoneyFrame_Update(me, value)
	local r,g,b
	if (hasBid == true) then r,g,b = 1,1,1
	elseif (hasBid == false) then r,g,b = 0.7,0.7,0.7 end
	if (highBidder) then r,g,b = 0.4,1,0.2 end
	if (r and g and b) then
		local myName = me:GetName()
		getglobal(myName.."GoldButtonText"):SetTextColor(r,g,b)
		getglobal(myName.."SilverButtonText"):SetTextColor(r,g,b)
		getglobal(myName.."CopperButtonText"):SetTextColor(r,g,b)
	end
	me:Show()
end

function private.ButtonClick(me, mouseButton)
	if ( IsControlKeyDown() ) then
		DressUpItemLink(GetAuctionItemLink("list", me.id))
	elseif ( IsShiftKeyDown() ) then
		ChatEdit_InsertLink(GetAuctionItemLink("list", me.id))
	else
		if ( AUCTION_DISPLAY_ON_CHARACTER == "1" ) then
			DressUpItemLink(GetAuctionItemLink("list", me.id))
		end
		SetSelectedAuctionItem("list", me.id)
		-- Close any auction related popups
		CloseAuctionStaticPopups()
		AuctionFrameBrowse_Update()
	end
end

function private.IconEnter(this)
	local button = this:GetParent()
	button.Icon:ClearAllPoints()
	button.Icon:SetPoint("RIGHT", this, "LEFT")
	button.Icon:SetWidth(64)
	button.Icon:SetHeight(64)
	AuctionFrameItem_OnEnter("list", button.id)
end

function private.IconLeave(this)
	local button = this:GetParent()
	button.Icon:ClearAllPoints()
	button.Icon:SetPoint("TOPLEFT", this, "TOPLEFT")
	button.Icon:SetWidth(16)
	button.Icon:SetHeight(16)
	GameTooltip:Hide()
	ResetCursor()
end

function private.SetAuction(button, id)
	if not id then
		button:Hide()
		return
	end

	local selected = GetSelectedAuctionItem("list") or 0
	if (selected == id) then
		button.LineTexture:SetTexture(1,1,0.5, 0.33)
	elseif (id % 2 == 0) then
		button.LineTexture:SetTexture(0.5,0.5,1, 0.1)
	else
		button.LineTexture:SetTexture(0,0,0.5, 0.1)
	end
	button.id = id
	
	local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner  = GetAuctionItemInfo("list", id)
	local link = GetAuctionItemLink("list", id)
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
		itemEquipLoc, itemTexture = GetItemInfo(itemID or "itemString" or "itemName" or "itemLink") 
	local timeLeft = GetAuctionItemTimeLeft("list", id)
	if (timeLeft == 4) then timeLeft = "24h"
	elseif (timeLeft == 3) then timeLeft = "8h"
	elseif (timeLeft == 2) then timeLeft = "2h"
	else timeLeft = "30m" end
	if (not count or count < 1) then count = 1 end

	local requiredBid = minBid
	if ( bidAmount > 0 ) then
		requiredBid = bidAmount + minIncrement
	end

	if ( requiredBid >= MAXIMUM_BID_PRICE ) then
		-- Lie about our buyout price
		buyoutPrice = requiredBid
	end

	if (selected == id) then
		if (buyoutPrice > 0 and buyoutPrice >= minBid) then
			local canBuyout = 1
			if (GetMoney() < buyoutPrice) then
				if (not highBidder or GetMoney()+bidAmount < buyoutPrice) then
					canBuyout = nil
				end
			end
			if (canBuyout) then
				BrowseBuyoutButton:Enable()
				AuctionFrame.buyoutPrice = buyoutPrice
			end
		else
			AuctionFrame.buyoutPrice = nil
		end
		-- Set bid
		MoneyInputFrame_SetCopper(BrowseBidPrice, requiredBid)

		-- See if the user can bid on this
		if (not highBidder and owner ~= UnitName("player")) then
			if (GetMoney() >= MoneyInputFrame_GetCopper(BrowseBidPrice)) then
				if (MoneyInputFrame_GetCopper(BrowseBidPrice) <= MAXIMUM_BID_PRICE) then
					BrowseBidButton:Enable()
				end
			end
		end
	end

	local perUnit = 1
	if (private.PerItem:GetChecked()) then
		perUnit = count
	end

	button.Count:SetText(count)
	button.Icon:SetTexture(texture)
	button.Name:SetText(link)
	button.rLevel:SetText(itemMinLevel or level)
	button.iLevel:SetText(itemLevel or level)
	button.tLeft:SetText(timeLeft)
	button.Owner:SetText(owner)
	button.Bid:SetMoney(requiredBid/perUnit, requiredBid ~= minBid, highBidder)
	button.Buy:SetMoney(buyoutPrice/perUnit)
	button:Show()
end

function private.MyAuctionFrameUpdate()
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("list")
	local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
	local index, button
	BrowseBidButton:Disable()
	BrowseBuyoutButton:Disable()
	-- Update sort arrows
	SortButton_UpdateArrow(BrowseQualitySort, "list", "quality")
	SortButton_UpdateArrow(BrowseLevelSort, "list", "level")
	SortButton_UpdateArrow(BrowseDurationSort, "list", "duration")
	SortButton_UpdateArrow(BrowseHighBidderSort, "list", "seller")
	SortButton_UpdateArrow(BrowseCurrentBidSort, "list", "buyoutthenbid")

	if ( numBatchAuctions == 0 ) then
		BrowseNoResultsText:Show()
	else
		BrowseNoResultsText:Hide()
	end

	for i=1, NUM_BROWSE_TO_DISPLAY do
		index = offset + i + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)
		button = private.buttons[i]
		if ( index > (numBatchAuctions + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)) ) then
			button:SetAuction()
			-- If the last button is empty then set isLastSlotEmpty var
			if ( i == NUM_BROWSE_TO_DISPLAY ) then
				isLastSlotEmpty = 1
			end
		else
			button:SetAuction(offset+i)
		end
	end

	if (totalAuctions > 0) then
		for pos, candy in ipairs(private.candy) do candy:Show() end
		BrowsePrevPageButton:Show()
		BrowseNextPageButton:Show()
		BrowseSearchCountText:Show()
		local itemsMin = AuctionFrameBrowse.page * NUM_AUCTION_ITEMS_PER_PAGE + 1
		local itemsMax = itemsMin + numBatchAuctions - 1
		BrowseSearchCountText:SetText(format(NUMBER_OF_RESULTS_TEMPLATE, itemsMin, itemsMax, totalAuctions ))
		if ( isLastSlotEmpty ) then
			if ( AuctionFrameBrowse.page == 0 ) then
				BrowsePrevPageButton.isEnabled = nil
			else
				BrowsePrevPageButton.isEnabled = 1
			end
			if ( AuctionFrameBrowse.page == (ceil(totalAuctions/NUM_AUCTION_ITEMS_PER_PAGE) - 1) ) then
				BrowseNextPageButton.isEnabled = nil
			else
				BrowseNextPageButton.isEnabled = 1
			end
		else
			BrowsePrevPageButton.isEnabled = nil
			BrowseNextPageButton.isEnabled = nil
		end
		
		-- Artifically inflate the number of results so the scrollbar scrolls one extra row
		numBatchAuctions = numBatchAuctions + NUM_BROWSE_TO_DISPLAY
	else
		for pos, candy in ipairs(private.candy) do candy:Hide() end
		BrowsePrevPageButton:Hide()
		BrowseNextPageButton:Hide()
		BrowseSearchCountText:Hide()
	end
	
	private.PageNum:SetText(AuctionFrameBrowse.page+1)
	FauxScrollFrame_Update(BrowseScrollFrame, numBatchAuctions, NUM_BROWSE_TO_DISPLAY, AUCTIONS_BUTTON_HEIGHT)
	AucAdvanced.API.ListUpdate()
end

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	id = gui.AddTab(libName)
	gui.AddControl(id, "Header",     0,    libName.." options")
	gui.AddControl(id, "Checkbox",   0, 1, "util.compactui.activated", "Enable use of CompactUI (requires logout)")
	gui.AddControl(id, "Note",       0, 2, 600, 70, "Note: This module heavily modifies your standard auction browser window, and may not play well with other auction house addons. For this reason, it is disabled by default. Should you enable this module and notice any incompatabilities, please turn this module off again by unticking the above box and reloading you interface.\nThankyou.")
	gui.AddControl(id, "Checkbox",   0, 1, "util.compactui.collapse", "Remove smaller denomination coins when zero")
end

