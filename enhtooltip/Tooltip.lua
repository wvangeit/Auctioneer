--[[
  Additional function hooks to allow hooks into more tooltips
  <%version%>
  $Id$

  All you should need to do as a client is call:
    EnhTooltip.AddHook(hookType, hookFunc, position)
	 Where:
	  hookType = "tooltip" or "popup"
	  hookFunc is your function that you want to be called
	  position is an order that you want to be called in (lower is earlier)
	    [ Auctioneer is hooked at position 50, enchantrix is 150 ]

  Then use the following functions:
    EnhTooltip.HideTooltip()
    EnhTooltip.ClearTooltip()
    EnhTooltip.GetGSC(money)
    EnhTooltip.GetTextGSC(money, exact)
    EnhTooltip.AddLine(lineText, moneyAmount, embed)
    EnhTooltip.LineColor(r, g, b)
    EnhTooltip.LineQuality(quality)
    EnhTooltip.SetIcon(iconPath)
    EnhTooltip.NameFromLink(link)
    EnhTooltip.HyperlinkFromLink(link)
    EnhTooltip.QualityFromLink(link)
    EnhTooltip.FakeLink(item, quality, name)
    EnhTooltip.AddHook(hookType, hookFunc, position)
    EnhTooltip.BreakLink(link)
    EnhTooltip.FindItemInBags(findName)
    EnhTooltip.DoPlayerEnters()
    EnhTooltip.SetElapsed(elapsed)

]]


ENHTOOLTIP_VERSION = "<%version%>"
if (ENHTOOLTIP_VERSION == "<".."%version%>") then
	ENHTOOLTIP_VERSION = "1.0.DEV"
end

local function newTT()
	local self = {
		showIgnore = false,
		moneySpacing = 4,
		embedLines = {},
		eventTimer = 0,
		hideTime = 0,
		currentGametip = nil,
		currentItem = nil,
		forcePopupKey = "alt",
		oldChatItem = nil,
		hooks = {},
		notify = { tooltip = {}, popup = {} },
		notifyFuncs = {},
	}


	EnhancedTooltip:SetBackdropColor(0,0,0)
	clearTooltip()
	
	--[[
	----  Establish hooks to all the game tooltips.
	--]]

	-- Hook in alternative Chat/Hyperlinking code
	self.hooks.chatOnHyperlinkShow = ChatFrame_OnHyperlinkShow
	ChatFrame_OnHyperlinkShow = chatHookOnHyperlinkShow

	-- Hook in alternative Auctionhouse tooltip code
	self.hooks.afOnEnter = AuctionFrameItem_OnEnter
	AuctionFrameItem_OnEnter = afHookOnEnter

	-- Container frame linking
	self.hooks.cfOnEnter = ContainerFrameItemButton_OnEnter
	ContainerFrameItemButton_OnEnter = cfHookOnEnter

	self.hooks.cfUpdate = ContainerFrame_Update
	ContainerFrame_Update = cfHookUpdate

	-- Game tooltips
	self.hooks.gtSetLootItem = GameTooltip.SetLootItem
	GameTooltip.SetLootItem = gtHookSetLootItem

	self.hooks.gtSetQuestItem = GameTooltip.SetQuestItem
	GameTooltip.SetQuestItem = gtHookSetQuestItem
	
	self.hooks.gtSetQuestLogItem = GameTooltip.SetQuestLogItem
	GameTooltip.SetQuestLogItem = gtHookSetQuestLogItem
	
	self.hooks.gtSetInventoryItem = GameTooltip.SetInventoryItem
	GameTooltip.SetInventoryItem = gtHookSetInventoryItem
	
	self.hooks.gtSetMerchantItem = GameTooltip.SetMerchantItem
	GameTooltip.SetMerchantItem = gtHookSetMerchantItem
	
	self.hooks.gtSetCraftItem = GameTooltip.SetCraftItem
	GameTooltip.SetCraftItem = gtHookSetCraftItem
	
	self.hooks.gtSetTradeSkillItem = GameTooltip.SetTradeSkillItem
	GameTooltip.SetTradeSkillItem = gtHookSetTradeSkillItem
	
	self.hooks.gtSetAuctionSellItem = GameTooltip.SetAuctionSellItem
	GameTooltip.SetAuctionSellItem = gtHookSetAuctionSellItem

	self.hooks.gtSetOwner = GameTooltip.SetOwner
	GameTooltip.SetOwner = gtHookSetOwner

	-- Hook the ItemsMatrix tooltip functions
	self.hooks.imiOnEnter = IMInv_ItemButton_OnEnter
	IMInv_ItemButton_OnEnter = imiHookOnEnter
	
	self.hooks.imOnEnter = ItemsMatrixItemButton_OnEnter
	ItemsMatrixItemButton_OnEnter = imHookOnEnter

	-- Hook the LootLink tooltip function
	self.hooks.llOnEnter = LootLinkItemButton_OnEnter
	LootLinkItemButton_OnEnter = llHookOnEnter

	-- Hook the AllInOneInventory tooltip function
	if (AllInOneInventory_ModifyItemTooltip ~= nil) then
		self.hooks.aioModifyItemTooltip = AllInOneInventory_ModifyItemTooltip
		AllInOneInventory_ModifyItemTooltip = aioHookModifyItemTooltip
		AIOI_Hooked = true
	else
		AIOI_Hooked = false
		this:RegisterEvent("PLAYER_ENTERING_WORLD")
	end

	-- Hook the hide function so we can disappear
	self.hooks.gtOnHide = GameTooltip_OnHide
	GameTooltip_OnHide = gtHookOnHide




	local function getRect(object)
		local rect = {}
		rect.t = object:GetTop() or 0
		rect.l = object:GetLeft() or 0
		rect.b = object:GetBottom() or 0
		rect.r = object:GetRight() or 0
		rect.w = object:GetWidth() or 0
		rect.h = object:GetHeight() or 0
		rect.cx = rect.l + (rect.w / 2)
		rect.cy = rect.t - (rect.h / 2)
		return rect
	end

	local function showTooltip(currentTooltip)
		if (self.showIgnore == true) then return end
		if (EnhancedTooltip.hasEmbed) then
			embedRender()
			currentTooltip:Show()
		end
		if (not EnhancedTooltip.hasData) then
			return
		end

		local height = 20
		local width = EnhancedTooltip.minWidth
		local lineCount = EnhancedTooltip.lineCount
		if (lineCount == 0) then hideTooltip() return end

		local firstLine = EnhancedTooltipText1
		local trackHeight = firstLine:GetHeight()
		for i = 2, lineCount do
			local currentLine = getglobal("EnhancedTooltipText"..i)
			trackHeight = trackHeight + currentLine:GetHeight() + 1
		end
		height = 20 + trackHeight

		local minWidth = width

		local sWidth = GetScreenWidth()
		local sHeight = GetScreenHeight()

		local parentObject = currentTooltip.owner
		if (parentObject) then
			local align = currentTooltip.anchor

			local parentRect = getRect(currentTooltip.owner)
			
			local xAnchor, yAnchor
			if (parentRect.l - width < sWidth * 0.2) then
				xAnchor = "RIGHT"
			elseif (parentRect.r + width > sWidth * 0.8) then
				xAnchor = "LEFT"
			elseif (align == "ANCHOR_RIGHT") then
				xAnchor = "RIGHT"
			elseif (align == "ANCHOR_LEFT") then
				xAnchor = "LEFT"
			else
				xAnchor = "RIGHT"
			end
			if (parentRect.cy < sHeight/2) then
				yAnchor = "TOP"
			else
				yAnchor = "BOTTOM"
			end

			currentTooltip:ClearAllPoints()
			EnhancedTooltip:ClearAllPoints()
			local anchor = yAnchor..xAnchor

			if (anchor == "TOPLEFT") then
				EnhancedTooltip:SetPoint("BOTTOMRIGHT", parentObject:GetName(), "TOPLEFT", -5,5)
				currentTooltip:SetPoint("BOTTOMRIGHT", "EnhancedTooltip", "TOPRIGHT", 0,0)
			elseif (anchor == "TOPRIGHT") then
				EnhancedTooltip:SetPoint("BOTTOMLEFT", parentObject:GetName(), "TOPRIGHT", 5,5)
				currentTooltip:SetPoint("BOTTOMLEFT", "EnhancedTooltip", "TOPLEFT", 0,0)
			elseif (anchor == "BOTTOMLEFT") then
				currentTooltip:SetPoint("TOPRIGHT", parentObject:GetName(), "BOTTOMLEFT", -5,-5)
				EnhancedTooltip:SetPoint("TOPRIGHT", currentTooltip:GetName(), "BOTTOMRIGHT", 0,0)
			else -- BOTTOMRIGHT
				currentTooltip:SetPoint("TOPLEFT", parentObject:GetName(), "BOTTOMRIGHT", 5,-5)
				EnhancedTooltip:SetPoint("TOPLEFT", currentTooltip:GetName(), "BOTTOMLEFT", 0,0)
			end

		else
			-- No parent
			-- The only option is to tack the object underneath / shuffle it up if there aint enuff room
			currentTooltip:Show()
			local tipRect = getRect(currentTooltip)

			if (tipRect.b - height < 60) then
				currentTooltip:ClearAllPoints()
				currentTooltip:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", tipRect.l, height+60)
			end
			EnhancedTooltip:ClearAllPoints()
			if (tipRect.cx < 6*sWidth/10) then
				EnhancedTooltip:SetPoint("TOPLEFT", currentTooltip:GetName(), "BOTTOMLEFT", 0,0)
			else
				EnhancedTooltip:SetPoint("TOPRIGHT", currentTooltip:GetName(), "BOTTOMRIGHT", 0,0)
			end
		end
		
		
		local cWidth = currentTooltip:GetWidth()
		if (cWidth < width) then
			getglobal(currentTooltip:GetName().."TextLeft1"):SetWidth(width - 20)
			currentTooltip:Show()
		elseif (cWidth > width) then
			width = cWidth
		end
		
		EnhancedTooltip:SetHeight(height)
		EnhancedTooltip:SetWidth(width)
		
		for i = 1, 10 do
			local ttMoney = getglobal("EnhancedTooltipMoney"..i)
			if (ttMoney.myLine ~= nil) then
				ttMoneyWidth = ttMoney:GetWidth()
				ttMoneyLineWidth = getglobal(ttMoney.myLine):GetWidth()
				ttMoney:ClearAllPoints()
				ttMoney:SetPoint("LEFT", ttMoney.myLine, "RIGHT", width - ttMoneyLineWidth - ttMoneyWidth - self.moneySpacing*2, 0)
			end
		end
		
		EnhancedTooltip:Show()
	end

	local function hideTooltip()
		EnhancedTooltip:Hide()
		self.currentItem = ""
		self.hideTime = 0
	end

	local function clearTooltip()
		hideTooltip()
		EnhancedTooltip.hasEmbed = false
		EnhancedTooltip.curEmbed = false
		EnhancedTooltip.hasData = false
		EnhancedTooltipIcon:Hide()
		EnhancedTooltipIcon:SetTexture("Interface\\Buttons\\UI-Quickslot2")
		for i = 1, 30 do
			local ttText = getglobal("EnhancedTooltipText"..i)
			ttText:Hide()
			ttText:SetTextColor(1.0,1.0,1.0)
		end
		for i = 1, 20 do
			local ttMoney = getglobal("EnhancedTooltipMoney"..i)
			ttMoney.myLine = nil
			ttMoney:Hide()
		end
		EnhancedTooltip.lineCount = 0
		EnhancedTooltip.moneyCount = 0
		EnhancedTooltip.minWidth = 0
		self.embedLines = {}
	end

	-- calculate the gold, silver, and copper values based the ammount of copper
	local function getGSC(money)
		if (money == nil) then money = 0 end
		local g = math.floor(money / 10000)
		local s = math.floor((money - (g*10000)) / 100)
		local c = math.floor(money - (g*10000) - (s*100))
		return g,s,c
	end

	-- formats money text by color for gold, silver, copper
	local function getTextGSC(money, exact)
		if not exact then
		   exact = false
		end

		local TEXT_NONE = "0"
		
		local GSC_GOLD="ffd100"
		local GSC_SILVER="e6e6e6"
		local GSC_COPPER="c8602c"
		local GSC_START="|cff%s%d|r"
		local GSC_PART=".|cff%s%02d|r"
		local GSC_NONE="|cffa0a0a0"..TEXT_NONE.."|r"

		local g, s, c = getGSC(money)

		local gsc = ""
		if (g > 0) then
			gsc = string.format(GSC_START, GSC_GOLD, g)
			if (s > 0) then
				gsc = gsc..string.format(GSC_PART, GSC_SILVER, s)
			end
			if exact then
			   gsc = gsc..string.format(GSC_PART,GSC_COPPER, c)
			end
		elseif (s > 0) then
			gsc = string.format(GSC_START, GSC_SILVER, s)
			if (c > 0) then
				gsc = gsc..string.format(GSC_PART, GSC_COPPER, c)
			end
		elseif (c > 0) then
			gsc = gsc..string.format(GSC_START, GSC_COPPER, c)
		else
			gsc = GSC_NONE
		end

		return gsc
	end

	local function embedRender()
		for pos, lData in self.embedLines do
			self.currentGametip:AddLine(lData.line)
			if (lData.r) then
				local lastLine = getglobal(self.currentGametip:GetName().."TextLeft"..self.currentGametip:NumLines())
				lastLine:SetTextColor(lData.r,lData.g,lData.b)
			end
		end
	end

	local function addLine(lineText, moneyAmount, embed)
		if (embed) and (self.currentGametip) then
			EnhancedTooltip.hasEmbed = true
			EnhancedTooltip.curEmbed = true
			local line = ""
			if (moneyAmount) then
				line = lineText .. ": " .. getTextGSC(moneyAmount)
			else
				line = lineText
			end
			table.insert(self.embedLines, {line = line})
			return
		end
		EnhancedTooltip.hasData = true
		EnhancedTooltip.curEmbed = false

		local curLine = EnhancedTooltip.lineCount + 1
		local line = getglobal("EnhancedTooltipText"..curLine)
		line:SetText(lineText)
		line:SetTextColor(1.0, 1.0, 1.0)
		line:Show()
		local lineWidth = line:GetWidth()

		EnhancedTooltip.lineCount = curLine
		if (moneyAmount ~= nil) and (moneyAmount > 0) then
			local curMoney = EnhancedTooltip.moneyCount + 1
			local money = getglobal("EnhancedTooltipMoney"..curMoney)
			money:SetPoint("LEFT", line:GetName(), "RIGHT", self.moneySpacing, 0)
			MoneyFrame_Update(money:GetName(), math.floor(moneyAmount))
			money.myLine = line:GetName()
			money:Show()
			local moneyWidth = money:GetWidth()
			lineWidth = lineWidth + moneyWidth + self.moneySpacing
			getglobal("EnhancedTooltipMoney"..curMoney.."SilverButtonText"):SetTextColor(1.0,1.0,1.0)
			getglobal("EnhancedTooltipMoney"..curMoney.."CopperButtonText"):SetTextColor(0.86,0.42,0.19)
			EnhancedTooltip.moneyCount = curMoney
		end
		lineWidth = lineWidth + 20
		if (lineWidth > EnhancedTooltip.minWidth) then
			EnhancedTooltip.minWidth = lineWidth
		end
	end

	local function lineColor(r, g, b)
		if (EnhancedTooltip.curEmbed) and (self.currentGametip) then
			local n = table.getn(self.embedLines)
			self.embedLines[n].r = r
			self.embedLines[n].g = g
			self.embedLines[n].b = b
			return
		end
		local curLine = EnhancedTooltip.lineCount
		if (curLine == 0) then return end
		local line = getglobal("EnhancedTooltipText"..curLine)
		line:SetTextColor(r, g, b)
	end

	local function lineQuality(quality)
		if ( quality ) then
			local color = ITEM_QUALITY_COLORS[quality]
			lineColor(color.r, color.g, color.b)
		else
			lineColor(1.0, 1.0, 1.0)
		end
	end

	local function setIcon(iconPath)
		EnhancedTooltipIcon:SetTexture(iconPath)
		EnhancedTooltipIcon:Show()
		local width = EnhancedTooltipIcon:GetWidth()
		local tWid = EnhancedTooltipText1:GetWidth() + width + 20
		if (tWid > EnhancedTooltip.minWidth) then
			EnhancedTooltip.minWidth = tWid
		end
		tWid = EnhancedTooltipText2:GetWidth() + width + 20
		if (tWid > EnhancedTooltip.minWidth) then
			EnhancedTooltip.minWidth = tWid
		end
	end

	local function gtHookOnHide()
		self.hooks.gtOnHide()
		local curName = ""
		local hidingName = this:GetName()
		if (self.currentGametip) then curName = self.currentGametip:GetName() end
		if (curName == hidingName) then
			HideObj = hidingName
			self.hideTime = self.eventTimer + 0.1
		end
	end

	local function doHyperlink(reference, link, button)
		if (ItemRefTooltip:IsVisible()) then
			local itemName = ItemRefTooltipTextLeft1:GetText()
			if (itemName and self.currentItem ~= itemName) then
				self.currentItem = itemName

				local testPopup = false
				if (button == "RightButton") then
					testPopup = true
				end
				if (tooltipCall(ItemRefTooltip, itemName, link, -1, 1, 0, testPopup, reference)) then 
					self.oldChatItem = {['reference']=reference, ['link']=link, ['button']=button, ['embed']=EnhancedTooltip.hasEmbed}
				end
			end
		end
	end

	local function checkHide()
		if (self.hideTime == 0) then return end
		self.currentItem = nil

		if (self.eventTimer >= self.hideTime) then
			hideTooltip()
			if (HideObj and HideObj == "ItemRefTooltip") then
				-- closing chatreferenceTT?
				self.oldChatItem = nil -- remove old chatlink data
			elseif self.oldChatItem then
				-- closing another tooltip
				-- redisplay old chatlinkdata, if it was not embeded
				if not self.oldChatItem.embed then
					doHyperlink(self.oldChatItem.reference, self.oldChatItem.link, self.oldChatItem.button)
				end
			end
		end
	end

	local function nameFromLink(link)
		local name
		if( not link ) then
			return nil
		end
		for name in string.gfind(link, "|c%x+|Hitem:%d+:%d+:%d+:%d+|h%[(.-)%]|h|r") do
			return name
		end
		return nil
	end
	NameFromLink = nameFromLink

	local function hyperlinkFromLink(link)
			if( not link ) then
					return nil
			end
			for hyperlink in string.gfind(link, "|H([^|]+)|h") do
					return hyperlink
			end
			return nil
	end
	HyperlinkFromLink = hyperlinkFromLink

	local function qualityFromLink(link)
		local color
		if (not link) then return nil end
		for color in string.gfind(link, "|c(%x+)|Hitem:%d+:%d+:%d+:%d+|h%[.-%]|h|r") do
			if (color == "ffa335ee") then return 4 --[[ Epic ]] end
			if (color == "ff0070dd") then return 3 --[[ Rare ]] end
			if (color == "ff1eff00") then return 2 --[[ Uncommon ]] end
			if (color == "ffffffff") then return 1 --[[ Common ]] end
			if (color == "ff9d9d9d") then return 0 --[[ Poor ]] end
		end
		return -1
	end
	QualityFromLink = qualityFromLink

	local function fakeLink(item, quality, name)
		-- make this function nilSafe, as it's a global one and might be used by external addons
		if not item then
			return nil
		end
		if (quality == nil) then quality = -1 end
		if (name == nil) then name = "unknown" end
		local color = "ffffff"
		if (quality == 4) then color = "a335ee"
		elseif (quality == 3) then color = "0070dd"
		elseif (quality == 2) then color = "1eff00"
		elseif (quality == 0) then color = "9d9d9d"
		end
		return "|cff"..color.. "|H"..item.."|h["..name.."]|h|r"
	end
	FakeLink = fakeLink

	local function tooltipCall(frame, name, link, quality, count, price, forcePopup, hyperlink)
		self.currentGametip = frame
		self.hideTime = 0

		local itemSig = frame:GetName()
		if (link) then itemSig = itemSig..link end
		if (count) then itemSig = itemSig..count end
		if (price) then itemSig = itemSig..price end
		
		if (self.currentItem and self.currentItem == itemSig) then
			-- We are already showing this... No point doing it again.
			showTooltip(self.currentGametip)
			return
		end

		self.currentItem = itemSig
		
		if (quality==nil or quality==-1) then
			local linkQuality = qualityFromLink(link)
			if (linkQuality and linkQuality > -1) then
				quality = linkQuality
			else
				quality = -1
			end
		end
		if (hyperlink == nil) then hyperlink = link end
		local extract = hyperlinkFromLink(hyperlink)
		if (extract) then hyperlink = extract end

		local showTip = true
		local popupKeyPressed = (
			(self.forcePopupKey == "ctrl" and IsControlKeyDown()) or
			(self.forcePopupKey == "alt" and IsAltKeyDown()) or
			(self.forcePopupKey == "shift" and IsShiftKeyDown())
		)
		
		if ((forcePopup == true) or ((forcePopup == nil) and (popupKeyPressed))) then
			local popupTest = checkPopup(name, link, quality, count, price, hyperlink)
			if (popupTest) then
				showTip = false
			end
		end
		
		if (showTip) then
			clearTooltip()
			self.showIgnore = true
			addTooltip(frame, name, link, quality, count, price)
			self.showIgnore = false
			showTooltip(frame)
			return true
		else
			frame:Hide()
			hideTooltip()
			return false
		end
	end

	local function addHook(hookType, hookFunc, position)
		local insertPos = tonumber(position) or 100
		
		if (self.notify[hookType]) then
			while (self.notify[hookType][insertPos]) do
				insertPos = insertPos + 1
			end
			self.notify[hookType][insertPos] = hookFunc
		end
		
		self.notifyFuncs = {}
		for ht, hData in self.notify do
			self.notifyFuncs[ht] = {}

			local sortedPos = {};
			for hp, hf in hData do
				table.insert(sortedPos, hp)
			end
			table.sort(sortedPos)

			for rp, hp in sortedPos do
				table.insert(self.notifyFuncs[ht], hData[hp])
			end
		end
	end

	local function addTooltip(frame, name, link, quality, count, price)
		if (self.notifyFuncs and self.notifyFuncs.tooltip) then
			for pos, addTooltipHook in self.notifyFuncs.tooltip do
				addTooltipHook(frame, name, link, quality, count, price)
			end
		end
	end

	local function checkPopup(name, link, quality, count, price, hyperlink)
		if (self.notifyFuncs and self.notifyFuncs.tooltip) then
			for pos, checkPopupHook in self.notifyFuncs.popup do
				if (checkPopupHook(name, link, quality, count, price, hyperlink)) then
					return true
				end
			end
		end
		return false 
	end

	local function chatHookOnHyperlinkShow(reference, link, button, ...)
		self.hooks.chatOnHyperlinkShow(reference, link, button)
		doHyperlink(reference, link, button)
	end

	local function afHookOnEnter(type, index)
		self.hooks.afOnEnter(type, index)

		local link = GetAuctionItemLink(type, index)
		if (link) then
			local name = nameFromLink(link)
			if (name) then
				local aiName, aiTexture, aiCount, aiQuality, aiCanUse, aiLevel, aiMinBid, aiMinIncrement, aiBuyoutPrice, aiBidAmount, aiHighBidder, aiOwner = GetAuctionItemInfo(type, index)
				tooltipCall(GameTooltip, name, link, aiQuality, aiCount)
			end
		end
	end

	local function cfHookOnEnter()
		self.hooks.cfOnEnter()

		local frameID = this:GetParent():GetID()
		local buttonID = this:GetID()
		local link = GetContainerItemLink(frameID, buttonID)
		local name = nameFromLink(link)
		
		if (name) then
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo(frameID, buttonID)
			if (quality==nil or quality==-1) then quality = qualityFromLink(link) end

			tooltipCall(GameTooltip, name, link, quality, itemCount)
		end
	end

	local function cfHookUpdate(frame)
		self.hooks.cfUpdate(frame)

		local frameID = frame:GetID()
		local frameName = frame:GetName()
		local iButton
		for iButton = 1, frame.size do
			local button = getglobal(frameName.."Item"..iButton)
			if (GameTooltip:IsOwned(button)) then
				local buttonID = button:GetID()
				local link = GetContainerItemLink(frameID, buttonID)
				local name = nameFromLink(link)
				
				if (name) then
					local texture, itemCount, locked, quality, readable = GetContainerItemInfo(frameID, buttonID)
					if (quality == nil) then quality = qualityFromLink(link) end

					tooltipCall(GameTooltip, name, link, quality, itemCount)
				end
			end
		end
	end


	local function gtHookSetLootItem(this, slot)
		self.hooks.gtSetLootItem(this, slot)
		
		local link = GetLootSlotLink(slot)
		local name = nameFromLink(link)
		if (name) then
			local texture, item, quantity, quality = GetLootSlotInfo(slot)
			if (quality == nil) then quality = qualityFromLink(link) end
			tooltipCall(GameTooltip, name, link, quality, quantity)
		end
	end

	local function gtHookSetQuestItem(this, qtype, slot)
		self.hooks.gtSetQuestItem(this, qtype, slot)
		local link = GetQuestItemLink(qtype, slot)
		if (link) then
			local name, texture, quantity, quality, usable = GetQuestItemInfo(qtype, slot)
			tooltipCall(GameTooltip, name, link, quality, quantity)
		end
	end

	local function gtHookSetQuestLogItem(this, qtype, slot)
		self.hooks.gtSetQuestLogItem(this, qtype, slot)
		local link = GetQuestLogItemLink(qtype, slot)
		if (link) then
			local name, texture, quantity, quality, usable = GetQuestLogRewardInfo(slot)
			if (name == nil) then name = nameFromLink(link) end
			quality = qualityFromLink(link) -- I don't trust the quality returned from the above function.

			tooltipCall(GameTooltip, name, link, quality, quantity)
		end
	end

	local function gtHookSetInventoryItem(this, unit, slot)
		local hasItem, hasCooldown, repairCost = self.hooks.gtSetInventoryItem(this, unit, slot)
		local link = GetInventoryItemLink(unit, slot)
		if (link) then
			local name = nameFromLink(link)
			local quantity = GetInventoryItemCount(unit, slot)
			local quality = GetInventoryItemQuality(unit, slot)
			if (quality == nil) then quality = qualityFromLink(link) end

			tooltipCall(GameTooltip, name, link, quality, quantity)
		end

		return hasItem, hasCooldown, repairCost
	end

	local function gtHookSetMerchantItem(this, slot)
		self.hooks.gtSetMerchantItem(this, slot)
		local link = GetMerchantItemLink(slot)
		if (link) then
			local name, texture, price, quantity, numAvailable, isUsable = GetMerchantItemInfo(slot)
			local quality = qualityFromLink(link)
			tooltipCall(GameTooltip, name, link, quality, quantity, price)
		end
	end

	local function gtHookSetCraftItem(this, skill, slot)
		self.hooks.gtSetCraftItem(this, skill, slot)
		local link
		if (slot) then
			link = GetCraftReagentItemLink(skill, slot)
			if (link) then
				local name, texture, quantity, quantityHave = GetCraftReagentInfo(skill, slot)
				local quality = qualityFromLink(link)
				tooltipCall(GameTooltip, name, link, quality, quantity, 0)
			end
		else
			link = GetCraftItemLink(skill)
			if (link) then
				local name = nameFromLink(link)
				local quality = qualityFromLink(link)
				tooltipCall(GameTooltip, name, link, quality, 1, 0)
			end
		end
	end

	local function gtHookSetTradeSkillItem(this, skill, slot)
		self.hooks.gtSetTradeSkillItem(this, skill, slot)
		local link
		if (slot) then
			link = GetTradeSkillReagentItemLink(skill, slot)
			if (link) then
				local name, texture, quantity, quantityHave = GetTradeSkillReagentInfo(skill, slot)
				local quality = qualityFromLink(link)
				tooltipCall(GameTooltip, name, link, quality, quantity, 0)
			end
		else
			link = GetTradeSkillItemLink(skill)
			if (link) then
				local name = nameFromLink(link)
				local quality = qualityFromLink(link)
				tooltipCall(GameTooltip, name, link, quality, 1, 0)
			end
		end
	end

	-- Given a Blizzard item link, breaks it into it's itemID, randomProperty, enchantProperty, uniqueness and name
	local function breakLink(link)
		local i,j, itemID, enchant, randomProp, uniqID, name = string.find(link, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h[[]([^]]+)[]]|h")
		return tonumber(itemID or 0), tonumber(randomProp or 0), tonumber(enchant or 0), tonumber(uniqID or 0), name
	end


	local function findItemInBags(findName)
		for bag = 0, 4, 1 do
			size = GetContainerNumSlots(bag)
			if (size) then
				for slot = size, 1, -1 do
					local link = GetContainerItemLink(bag, slot)
					if (link) then
						local itemID, randomProp, enchant, uniqID, itemName = breakLink(link)
						if (itemName == findName) then
							return bag, slot, itemID, randomProp, enchant, uniqID
						end
					end
				end
			end
		end
	end

	local function gtHookSetAuctionSellItem(this)
		self.hooks.gtSetAuctionSellItem(this)
		local name, texture, quantity, quality, canUse, price = GetAuctionSellItemInfo()
		if (name) then
			local bag, slot = findItemInBags(name)
			if (bag) then
				local link = GetContainerItemLink(bag, slot)
				if (link) then
					tooltipCall(GameTooltip, name, link, quality, quantity, price)
				end
			end
		end
	end

	local function imiHookOnEnter()
		self.hooks.imiOnEnter()
		if(not IM_InvList) then return end
		local id = this:GetID()

		if(id == 0) then
			id = this:GetParent():GetID()
		end
		local offset = FauxScrollFrame_GetOffset(ItemsMatrix_IC_ScrollFrame)
		local item = IM_InvList[id + offset]

		if (not item) then return end
		local imlink = ItemsMatrix_GetHyperlink(item.name)
		local link = fakeLink(imlink, item.quality, item.name)
		if (link) then
			tooltipCall(GameTooltip, item.name, link, item.quality, item.count, 0)
		end
	end

	local function imHookOnEnter()
		self.hooks.imOnEnter()
		local imlink = ItemsMatrix_GetHyperlink(this:GetText())
		if (imlink) then
			local name = this:GetText()
			local link = fakeLink(imlink, -1, name)
			tooltipCall(GameTooltip, name, link, -1, 1, 0)
		end
	end

	local function getLootLinkServer()
		return LootLinkState.ServerNamesToIndices[GetCVar("realmName")]
	end

	local function getLootLinkLink(name)
		local itemLink = ItemLinks[name]
		if (itemLink and itemLink.c and itemLink.i and LootLink_CheckItemServer(itemLink, getLootLinkServer())) then
			local item = string.gsub(itemLink.i, "(%d+):(%d+):(%d+):(%d+)", "%1:0:%3:%4")
			local link = "|c"..itemLink.c.."|Hitem:"..item.."|h["..name.."]|h|r"
			return link
		end
		return nil
	end

	local function llHookOnEnter()
		self.hooks.llOnEnter()
		local name = this:GetText()
		local link = getLootLinkLink(name)
		if (link) then
			local quality = qualityFromLink(link)
			tooltipCall(LootLinkTooltip, name, link, quality, 1, 0)
		end
	end

	local function aioHookModifyItemTooltip(bag, slot, tooltip)
		self.hooks.aioModifyItemTooltip(bag, slot, tooltip)

		local tooltip = getglobal(tooltipName)
		if (not tooltip) then
			tooltip = getglobal("GameTooltip")
			tooltipName = "GameTooltip"
		end
		if (not tooltip) then return false end

		local link = GetContainerItemLink(bag, slot)
		local name = nameFromLink(link)
		if (name) then
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot)
			if (quality == nil) then quality = qualityFromLink(link) end

			tooltipCall(GameTooltip, name, link, quality, itemCount, 0)
		end
	end

	local function gtHookSetOwner(this, owner, anchor)
		self.hooks.gtSetOwner(this, owner, anchor)
		this.owner = owner
		this.anchor = anchor
	end


	local function doPlayerEnters()
		-- Since AIOI lists Auctioneer as an option dependancy, we may not have 
		-- registered the event hooks above... Check here to make certain!
		if (not AIOI_Hooked) then
			if (AllInOneInventory_ModifyItemTooltip ~= nil) then
				self.hooks.AllInOneInventory_ModifyItemTooltip = AllInOneInventory_ModifyItemTooltip
				AllInOneInventory_ModifyItemTooltip = AllInOneInventory_ModifyItemTooltip
				AIOI_Hooked = true
			end
		end
	end

	local function setElapsed(elapsed)
		self.eventTimer = self.eventTimer + elapsed
		checkHide()
	end

	return {
		AddLine           = addLine,
  		HideTooltip       = hideTooltip,
  		ClearTooltip      = clearTooltip,
  		GetGSC            = getGSC,
  		GetTextGSC        = getTextGSC,
  		AddLine           = addLine,
  		LineColor         = lineColor,
  		LineQuality       = lineQuality,
  		SetIcon           = setIcon,
  		NameFromLink      = nameFromLink,
  		HyperlinkFromLink = hyperlinkFromLink,
  		QualityFromLink   = qualityFromLink,
  		FakeLink          = fakeLink,
  		AddHook           = addHook,
  		BreakLink         = breakLink,
  		FindItemInBags    = findItemInBags,
  		DoPlayerEnters    = doPlayerEnters,
  		SetElapsed        = setElapsed,
	}
end

EnhTooltip = nil;
function OnLoad()
	EnhTooltip = newTT();
end

function OnUpdate(elapsed)
	EnhTooltip:SetElapsed(elapsed)
end

function OnEvent(event)
	if (event == "PLAYER_ENTERING_WORLD") then
		EnhTooltip:DoPlayerEnters();
		this:UnregisterEvent(event)
	end
end

