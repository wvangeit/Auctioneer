--[[
  Additional function hooks to allow hooks into more tooltips
  <%version%>
  $Id$
]]


TOOLTIPS_INCLUDED = getglobal("TOOLTIPS_INCLUDED");

if (TOOLTIPS_INCLUDED == nil) then
TOOLTIPS_INCLUDED = true;

ENHTOOLTIP_VERSION = "<%version%>";

TT_CurrentTip = nil;
TT_PopupKey = "alt";
local OldChatLinkItem = nil -- used to save last chat-link-item for redisplaying, if needed

local Orig_Chat_OnHyperlinkShow;
local Orig_AuctionFrameItem_OnEnter;
local Orig_ContainerFrameItemButton_OnEnter;
local Orig_ContainerFrame_Update;
local Orig_GameTooltip_SetLootItem;
local Orig_GameTooltip_SetQuestItem;
local Orig_GameTooltip_SetQuestLogItem;
local Orig_GameTooltip_SetInventoryItem;
local Orig_GameTooltip_SetMerchantItem;
local Orig_GameTooltip_SetCraftItem;
local Orig_GameTooltip_SetTradeSkillItem;
local Orig_GameTooltip_SetAuctionSellItem;
local Orig_GameTooltip_SetOwner;
local Orig_IMInv_ItemButton_OnEnter;
local Orig_ItemsMatrixItemButton_OnEnter;
local Orig_LootLinkItemButton_OnEnter;
local Orig_GameTooltip_OnHide;

if (ENHTOOLTIP_VERSION == "<".."%version%>") then
	ENHTOOLTIP_VERSION = "1.0.DEV";
end

function TT_OnLoad()
	if (TT_LOADED ~= nil) then 
		return; 
	end
		EnhancedTooltip:SetBackdropColor(0,0,0);
		TT_Clear();

	-- Hook in alternative Chat/Hyperlinking code
	Orig_Chat_OnHyperlinkShow = ChatFrame_OnHyperlinkShow;
	ChatFrame_OnHyperlinkShow = TT_Chat_OnHyperlinkShow;

	-- Hook in alternative Auctionhouse tooltip code
	Orig_AuctionFrameItem_OnEnter = AuctionFrameItem_OnEnter;
	AuctionFrameItem_OnEnter = TT_AuctionFrameItem_OnEnter;

	-- Container frame linking
	Orig_ContainerFrameItemButton_OnEnter = ContainerFrameItemButton_OnEnter;
	ContainerFrameItemButton_OnEnter = TT_ContainerFrameItemButton_OnEnter;
	Orig_ContainerFrame_Update = ContainerFrame_Update;
	ContainerFrame_Update = TT_ContainerFrame_Update;

	-- Game tooltips
	Orig_GameTooltip_SetLootItem = GameTooltip.SetLootItem;
	GameTooltip.SetLootItem = TT_GameTooltip_SetLootItem;
	Orig_GameTooltip_SetQuestItem = GameTooltip.SetQuestItem;
	GameTooltip.SetQuestItem = TT_GameTooltip_SetQuestItem;
	Orig_GameTooltip_SetQuestLogItem = GameTooltip.SetQuestLogItem;
	GameTooltip.SetQuestLogItem = TT_GameTooltip_SetQuestLogItem;
	Orig_GameTooltip_SetInventoryItem = GameTooltip.SetInventoryItem;
	GameTooltip.SetInventoryItem = TT_GameTooltip_SetInventoryItem;
	Orig_GameTooltip_SetMerchantItem = GameTooltip.SetMerchantItem;
	GameTooltip.SetMerchantItem = TT_GameTooltip_SetMerchantItem;
	Orig_GameTooltip_SetCraftItem = GameTooltip.SetCraftItem;
	GameTooltip.SetCraftItem = TT_GameTooltip_SetCraftItem;
	Orig_GameTooltip_SetTradeSkillItem = GameTooltip.SetTradeSkillItem;
	GameTooltip.SetTradeSkillItem = TT_GameTooltip_SetTradeSkillItem;
	Orig_GameTooltip_SetAuctionSellItem = GameTooltip.SetAuctionSellItem;
	GameTooltip.SetAuctionSellItem = TT_GameTooltip_SetAuctionSellItem;

	Orig_GameTooltip_SetOwner = GameTooltip.SetOwner;
	GameTooltip.SetOwner = TT_GameTooltip_SetOwner;

	-- Hook the ItemsMatrix tooltip functions
	Orig_IMInv_ItemButton_OnEnter = IMInv_ItemButton_OnEnter;
	IMInv_ItemButton_OnEnter = TT_IMInv_ItemButton_OnEnter;
	Orig_ItemsMatrixItemButton_OnEnter = ItemsMatrixItemButton_OnEnter;
	ItemsMatrixItemButton_OnEnter = TT_ItemsMatrixItemButton_OnEnter;

	-- Hook the LootLink tooltip function
	Orig_LootLinkItemButton_OnEnter = LootLinkItemButton_OnEnter;
	LootLinkItemButton_OnEnter = TT_LootLinkItemButton_OnEnter;

	-- Hook the AllInOneInventory tooltip function
	if (AllInOneInventory_ModifyItemTooltip ~= nil) then
		Orig_AllInOneInventory_ModifyItemTooltip = AllInOneInventory_ModifyItemTooltip;
		AllInOneInventory_ModifyItemTooltip = TT_AllInOneInventory_ModifyItemTooltip;
		TT_AIOI_Hooked = true;
	else
		TT_AIOI_Hooked = false;
		this:RegisterEvent("PLAYER_ENTERING_WORLD");
	end

	-- Hook the hide function so we can disappear
	Orig_GameTooltip_OnHide = GameTooltip_OnHide;
	GameTooltip_OnHide = TT_GameTooltip_OnHide;


	TT_LOADED = true;
end

function TT_OnEvent(event)
	if (event == "PLAYER_ENTERING_WORLD") then

		-- Since AIOI lists Auctioneer as an option dependancy, we may not have 
		-- registered the event hooks above... Check here to make certain!
		if (not TT_AIOI_Hooked) then
			if (AllInOneInventory_ModifyItemTooltip ~= nil) then
				Orig_AllInOneInventory_ModifyItemTooltip = AllInOneInventory_ModifyItemTooltip;
				AllInOneInventory_ModifyItemTooltip = TT_AllInOneInventory_ModifyItemTooltip;
				this:UnregisterEvent(event);
				TT_AIOI_Hooked = true;
			end
		else
			this:UnregisterEvent(event);
		end
	end
end


local function getRect(object)
	local rect = {};
	rect.t = object:GetTop() or 0; 
	rect.l = object:GetLeft() or 0;
	rect.b = object:GetBottom() or 0;
	rect.r = object:GetRight() or 0;
	rect.w = object:GetWidth() or 0;
	rect.h = object:GetHeight() or 0;
	rect.cx = rect.l + (rect.w / 2);
	rect.cy = rect.t - (rect.h / 2);
	return rect;
end

function TT_Show(currentTooltip)
	if (TT_Show_Ignore == true) then return end
	if (EnhancedTooltip.hasEmbed) then
		TT_EmbedRender();
		currentTooltip:Show();
	end
	if (not EnhancedTooltip.hasData) then
		return;
	end

	local height = 20;
	local width = EnhancedTooltip.minWidth;
	local lineCount = EnhancedTooltip.lineCount;
	if (lineCount == 0) then TT_Hide(); return; end

	local firstLine = EnhancedTooltipText1;
	local trackHeight = firstLine:GetHeight();
	for i = 2, lineCount do
		local currentLine = getglobal("EnhancedTooltipText"..i);
		trackHeight = trackHeight + currentLine:GetHeight() + 1;
	end
	height = 20 + trackHeight;

	local minWidth = width;

	local sWidth = GetScreenWidth();
	local sHeight = GetScreenHeight();

	local parentObject = currentTooltip.owner;
	if (parentObject) then
		local align = currentTooltip.anchor;

		local parentRect = getRect(currentTooltip.owner);
		
		local xAnchor, yAnchor;
		if (parentRect.l - width < sWidth * 0.2) then
			xAnchor = "RIGHT";
		elseif (parentRect.r + width > sWidth * 0.8) then
			xAnchor = "LEFT";
		elseif (align == "ANCHOR_RIGHT") then
			xAnchor = "RIGHT";
		elseif (align == "ANCHOR_LEFT") then
			xAnchor = "LEFT";
		else
			xAnchor = "RIGHT";
		end
		if (parentRect.cy < sHeight/2) then
			yAnchor = "TOP";
		else
			yAnchor = "BOTTOM";
		end

		currentTooltip:ClearAllPoints();
		EnhancedTooltip:ClearAllPoints();
		local anchor = yAnchor..xAnchor;

		if (anchor == "TOPLEFT") then
			EnhancedTooltip:SetPoint("BOTTOMRIGHT", parentObject:GetName(), "TOPLEFT", -5,5);
			currentTooltip:SetPoint("BOTTOMRIGHT", "EnhancedTooltip", "TOPRIGHT", 0,0);
		elseif (anchor == "TOPRIGHT") then
			EnhancedTooltip:SetPoint("BOTTOMLEFT", parentObject:GetName(), "TOPRIGHT", 5,5);
			currentTooltip:SetPoint("BOTTOMLEFT", "EnhancedTooltip", "TOPLEFT", 0,0);
		elseif (anchor == "BOTTOMLEFT") then
			currentTooltip:SetPoint("TOPRIGHT", parentObject:GetName(), "BOTTOMLEFT", -5,-5);
			EnhancedTooltip:SetPoint("TOPRIGHT", currentTooltip:GetName(), "BOTTOMRIGHT", 0,0);
		else -- BOTTOMRIGHT
			currentTooltip:SetPoint("TOPLEFT", parentObject:GetName(), "BOTTOMRIGHT", 5,-5);
			EnhancedTooltip:SetPoint("TOPLEFT", currentTooltip:GetName(), "BOTTOMLEFT", 0,0);
		end

	else
		-- No parent
		-- The only option is to tack the object underneath / shuffle it up if there aint enuff room
		currentTooltip:Show();
		local tipRect = getRect(currentTooltip);

		if (tipRect.b - height < 60) then
			currentTooltip:ClearAllPoints();
			currentTooltip:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", tipRect.l, height+60);
		end;
		EnhancedTooltip:ClearAllPoints();
		if (tipRect.cx < 6*sWidth/10) then
			EnhancedTooltip:SetPoint("TOPLEFT", currentTooltip:GetName(), "BOTTOMLEFT", 0,0);
		else
			EnhancedTooltip:SetPoint("TOPRIGHT", currentTooltip:GetName(), "BOTTOMRIGHT", 0,0);
		end
	end
	
	
	local cWidth = currentTooltip:GetWidth();
	if (cWidth < width) then
		getglobal(currentTooltip:GetName().."TextLeft1"):SetWidth(width - 20);
		currentTooltip:Show();
	elseif (cWidth > width) then
		width = cWidth;
	end
	
	EnhancedTooltip:SetHeight(height);
	EnhancedTooltip:SetWidth(width);
	
	for i = 1, 10 do
		local ttMoney = getglobal("EnhancedTooltipMoney"..i);
		if (ttMoney.myLine ~= nil) then
			ttMoneyWidth = ttMoney:GetWidth();
			ttMoneyLineWidth = getglobal(ttMoney.myLine):GetWidth();
			ttMoney:ClearAllPoints();
			ttMoney:SetPoint("LEFT", ttMoney.myLine, "RIGHT", width - ttMoneyLineWidth - ttMoneyWidth - TT_MoneySpacing*2, 0);
		end
	end
	
	EnhancedTooltip:Show();
end

function TT_Hide()
	EnhancedTooltip:Hide();
	TT_ChatCurrentItem = "";
	TT_HideAt = 0;
end

function TT_Clear()
	TT_Hide();
	EnhancedTooltip.hasEmbed = false;
	EnhancedTooltip.curEmbed = false;
	EnhancedTooltip.hasData = false;
	EnhancedTooltipIcon:Hide();
	EnhancedTooltipIcon:SetTexture("Interface\\Buttons\\UI-Quickslot2");
	for i = 1, 30 do
		local ttText = getglobal("EnhancedTooltipText"..i);
		ttText:Hide();
		ttText:SetTextColor(1.0,1.0,1.0);
	end
	for i = 1, 20 do
		local ttMoney = getglobal("EnhancedTooltipMoney"..i);
		ttMoney.myLine = nil;
		ttMoney:Hide();
	end
	EnhancedTooltip.lineCount = 0;
	EnhancedTooltip.moneyCount = 0;
	EnhancedTooltip.minWidth = 0;
	TT_Lines = {};
end

-- calculate the gold, silver, and copper values based the ammount of copper
function TT_GetGSC(money)
	if (money == nil) then money = 0; end
	local g = math.floor(money / 10000);
	local s = math.floor((money - (g*10000)) / 100);
	local c = math.floor(money - (g*10000) - (s*100));
	return g,s,c;
end

-- formats money text by color for gold, silver, copper
function TT_GetTextGSC(money, exact)
	if not exact then
	   exact = false
	end

	local TT_TEXT_NONE = "0";
	
	local GSC_GOLD="ffd100";
	local GSC_SILVER="e6e6e6";
	local GSC_COPPER="c8602c";
	local GSC_START="|cff%s%d|r";
	local GSC_PART=".|cff%s%02d|r";
	local GSC_NONE="|cffa0a0a0"..TT_TEXT_NONE.."|r";

	local g, s, c = TT_GetGSC(money);

	local gsc = "";
	if (g > 0) then
		gsc = string.format(GSC_START, GSC_GOLD, g);     
		if (s > 0) then
			gsc = gsc..string.format(GSC_PART, GSC_SILVER, s);
		end
		if exact then
		   gsc = gsc..string.format(GSC_PART,GSC_COPPER, c);
		end
	elseif (s > 0) then
		gsc = string.format(GSC_START, GSC_SILVER, s);
		if (c > 0) then
			gsc = gsc..string.format(GSC_PART, GSC_COPPER, c);
		end
	elseif (c > 0) then
		gsc = gsc..string.format(GSC_START, GSC_COPPER, c);
	else
		gsc = GSC_NONE;
	end

	return gsc;
end

TT_Lines = {};
function TT_EmbedRender()
	for pos, lData in TT_Lines do
		TT_CurrentTip:AddLine(lData.line);
		if (lData.r) then
			local lastLine = getglobal(TT_CurrentTip:GetName().."TextLeft"..TT_CurrentTip:NumLines());
			lastLine:SetTextColor(lData.r,lData.g,lData.b);
		end
	end
end

TT_MoneySpacing = 4;
function TT_AddLine(lineText, moneyAmount, embed)
	if (embed == nil) then embed = TT_EMBED; end
	if (embed) and (TT_CurrentTip) then
		EnhancedTooltip.hasEmbed = true;
		EnhancedTooltip.curEmbed = true;
		local line = "";
		if (moneyAmount) then
			line = lineText .. ": " .. TT_GetTextGSC(moneyAmount);
		else
			line = lineText;
		end
		table.insert(TT_Lines, {line = line});
		return;
	end
	EnhancedTooltip.hasData = true;
	EnhancedTooltip.curEmbed = false;

	local curLine = EnhancedTooltip.lineCount + 1;
	local line = getglobal("EnhancedTooltipText"..curLine);
	line:SetText(lineText);
	line:SetTextColor(1.0, 1.0, 1.0);
	line:Show();
	local lineWidth = line:GetWidth();

	EnhancedTooltip.lineCount = curLine;
	if (moneyAmount ~= nil) and (moneyAmount > 0) then
		local curMoney = EnhancedTooltip.moneyCount + 1;
		local money = getglobal("EnhancedTooltipMoney"..curMoney);
		money:SetPoint("LEFT", line:GetName(), "RIGHT", TT_MoneySpacing, 0);
		MoneyFrame_Update(money:GetName(), math.floor(moneyAmount));
		money.myLine = line:GetName();
		money:Show();
		local moneyWidth = money:GetWidth();
		lineWidth = lineWidth + moneyWidth + TT_MoneySpacing;
		getglobal("EnhancedTooltipMoney"..curMoney.."SilverButtonText"):SetTextColor(1.0,1.0,1.0);
		getglobal("EnhancedTooltipMoney"..curMoney.."CopperButtonText"):SetTextColor(0.86,0.42,0.19);
		EnhancedTooltip.moneyCount = curMoney;
	end
	lineWidth = lineWidth + 20;
	if (lineWidth > EnhancedTooltip.minWidth) then
		EnhancedTooltip.minWidth = lineWidth;
	end
end

function TT_LineColor(r, g, b)
	if (EnhancedTooltip.curEmbed) and (TT_CurrentTip) then
		local n = table.getn(TT_Lines);
		TT_Lines[n].r = r;
		TT_Lines[n].g = g;
		TT_Lines[n].b = b;
		return;
	end
	local curLine = EnhancedTooltip.lineCount;
	if (curLine == 0) then return; end
	local line = getglobal("EnhancedTooltipText"..curLine);
	line:SetTextColor(r, g, b);
end

function TT_LineQuality(quality)
	if ( quality ) then
		local color = ITEM_QUALITY_COLORS[quality];
		TT_LineColor(color.r, color.g, color.b);
	else
		TT_LineColor(1.0, 1.0, 1.0);
	end
end

function TT_SetIcon(iconPath)
	EnhancedTooltipIcon:SetTexture(iconPath);
	EnhancedTooltipIcon:Show();
	local width = EnhancedTooltipIcon:GetWidth();
	local tWid = EnhancedTooltipText1:GetWidth() + width + 20;
	if (tWid > EnhancedTooltip.minWidth) then
		EnhancedTooltip.minWidth = tWid;
	end
	tWid = EnhancedTooltipText2:GetWidth() + width + 20;
	if (tWid > EnhancedTooltip.minWidth) then
		EnhancedTooltip.minWidth = tWid;
	end
end

function TT_SetModel(class, file) return nil end

TT_CurTime = 0;
TT_HideAt = 0;
function TT_GameTooltip_OnHide()
	Orig_GameTooltip_OnHide();
	local curName = "";
	local hidingName = this:GetName();
	if (TT_CurrentTip) then curName = TT_CurrentTip:GetName(); end
	if (curName == hidingName) then
		TT_HideObj = hidingName;
		TT_HideAt = TT_CurTime + 0.1;
	end
end

function TT_OnUpdate(elapsed)
	TT_CurTime = TT_CurTime + elapsed;
	TT_CheckHide();
end

function TT_CheckHide()
	if (TT_HideAt == 0) then return end
	TT_CurrentItem = nil;

	if (TT_CurTime >= TT_HideAt) then
		TT_Hide();
		if (TT_HideObj and TT_HideObj == "ItemRefTooltip") then
			-- closing chatreferenceTT?
			OldChatLinkItem = nil -- remove old chatlink data
		elseif OldChatLinkItem then
			-- closing another tooltip (expecting that the gametooltip-mouseoverTT is being closed)

			local Backup = {['reference']=OldChatLinkItem.reference, ['link']=OldChatLinkItem.link, ['button']=OldChatLinkItem.button}
			-- redisplay old chatlinkdata, if there was one before
			HideUIPanel(ItemRefTooltip)
			TT_Chat_OnHyperlinkShow(Backup.reference, Backup.link, Backup.button)
			ShowUIPanel(ItemRefTooltip)
		end
	end
end

local function nameFromLink(link)
	local name;
	if( not link ) then
		return nil;
	end
	for name in string.gfind(link, "|c%x+|Hitem:%d+:%d+:%d+:%d+|h%[(.-)%]|h|r") do
		return name;
	end
	return nil;
end
TT_NameFromLink = nameFromLink;

local function hyperlinkFromLink(link)
        if( not link ) then
                return nil;
        end
        for hyperlink in string.gfind(link, "|H([^|]+)|h") do
                return hyperlink;
        end
        return nil;
end
TT_HyperlinkFromLink = hyperlinkFromLink;

local function  qualityFromLink(link)
	local color;
	if (not link) then return nil; end
	for color in string.gfind(link, "|c(%x+)|Hitem:%d+:%d+:%d+:%d+|h%[.-%]|h|r") do
		if (color == "ffa335ee") then return 4;--[[ Epic ]] end
		if (color == "ff0070dd") then return 3;--[[ Rare ]] end
		if (color == "ff1eff00") then return 2;--[[ Uncommon ]] end
		if (color == "ffffffff") then return 1;--[[ Common ]] end
		if (color == "ff9d9d9d") then return 0;--[[ Poor ]] end
	end
	return -1;
end
TT_QualityFromLink = qualityFromLink;

local function fakeLink(item, quality, name)
	-- make this function nilSafe, as it's a global one and might be used by external addons
	if not item then
		return nil
	end
	if (quality == nil) then quality = -1; end
	if (name == nil) then name = "unknown"; end
	local color = "ffffff";
	if (quality == 4) then color = "a335ee";
	elseif (quality == 3) then color = "0070dd";
	elseif (quality == 2) then color = "1eff00";
	elseif (quality == 0) then color = "9d9d9d";
	end
	return "|cff"..color.. "|H"..item.."|h["..name.."]|h|r";
end
TT_FakeLink = fakeLink;

TT_Show_Ignore = false;
function TT_TooltipCall(frame, name, link, quality, count, price, forcePopup, hyperlink)
	TT_CurrentTip = frame;
	TT_HideAt = 0;

	local itemSig = frame:GetName();
	if (link) then itemSig = itemSig..link end
	if (count) then itemSig = itemSig..count end
	if (price) then itemSig = itemSig..price end
	
	if (TT_CurrentItem and TT_CurrentItem == itemSig) then
		-- We are already showing this... No point doing it again.
		TT_Show(TT_CurrentTip);
		return;
	end

	TT_CurrentItem = itemSig;
	
	if (quality==nil or quality==-1) then
		local linkQuality = qualityFromLink(link);
		if (linkQuality and linkQuality > -1) then
			quality = linkQuality;
		else
			quality = -1;
		end
	end
	if (hyperlink == nil) then hyperlink = link end
	local extract = hyperlinkFromLink(hyperlink);
	if (extract) then hyperlink = extract end

	local showTip = true;
	local popupKeyPressed = (
		(TT_PopupKey == "ctrl" and IsControlKeyDown()) or
		(TT_PopupKey == "alt" and IsAltKeyDown()) or
		(TT_PopupKey == "shift" and IsShiftKeyDown())
	);
	
	if ((forcePopup == true) or ((forcePopup == nil) and (popupKeyPressed))) then
		local popupTest = TT_ItemPopup(name, link, quality, count, price, hyperlink);
		if (popupTest) then
			showTip = false;
		end
	end
	
	if (showTip) then
		TT_Clear();
		TT_Show_Ignore = true;
		TT_AddTooltip(frame, name, link, quality, count, price);
		TT_Show_Ignore = false;
		TT_Show(frame);
		return true;
	else
		frame:Hide();
		TT_Hide();
		return false;
	end
end

function TT_AddTooltip(frame, name, link, quality, count, price)
	-- Empty function; hook here if you want in on the action!
end

function TT_ItemPopup(name, link, quality, count, price, hyperlink)
	-- Empty function; hook here if you want to maybe display a popup menu

	-- This function should return true if some addon somewhere wants to popup it's own menu.
	-- If this function returns true, then EnhTooltip will not show a tooltip.

	-- NOTE: You should only answer false if you recognize the link, and are sure
	-- you want to popup something.

	-- Otherwise just pass the return value back up the chain.

	return false; 
end

function TT_Chat_OnHyperlinkShow(reference, link, button, ...)
	Orig_Chat_OnHyperlinkShow(reference, link, button);

	if (ItemRefTooltip:IsVisible()) then
		local itemName = ItemRefTooltipTextLeft1:GetText();
		if (itemName and TT_ChatCurrentItem ~= itemName) then
			TT_ChatCurrentItem = itemName;

			local testPopup = false;
			if (button == "RightButton") then
				testPopup = true;
			end
			if (TT_TooltipCall(ItemRefTooltip, itemName, link, -1, 1, 0, testPopup, hyperlink)) then 
				OldChatLinkItem = {['reference']=reference, ['link']=link, ['button']=button}
			end
		end
	end
end

function TT_AuctionFrameItem_OnEnter(type, index)
	Orig_AuctionFrameItem_OnEnter(type, index);

	local link = GetAuctionItemLink(type, index);
	if (link) then
		local name = nameFromLink(link);
		if (name) then
			local aiName, aiTexture, aiCount, aiQuality, aiCanUse, aiLevel, aiMinBid, aiMinIncrement, aiBuyoutPrice, aiBidAmount, aiHighBidder, aiOwner = GetAuctionItemInfo(type, index);
			TT_TooltipCall(GameTooltip, name, link, aiQuality, aiCount);
		end
	end
end

function TT_ContainerFrameItemButton_OnEnter()
	Orig_ContainerFrameItemButton_OnEnter();

	local frameID = this:GetParent():GetID();
	local buttonID = this:GetID();
	local link = GetContainerItemLink(frameID, buttonID);
	local name = nameFromLink(link);
	
	if (name) then
		local texture, itemCount, locked, quality, readable = GetContainerItemInfo(frameID, buttonID);
		if (quality==nil or quality==-1) then quality = qualityFromLink(link); end

		TT_TooltipCall(GameTooltip, name, link, quality, itemCount);
	end
end

function TT_ContainerFrame_Update(frame)
	Orig_ContainerFrame_Update(frame);

	local frameID = frame:GetID();
	local frameName = frame:GetName();
	local iButton;
	for iButton = 1, frame.size do
		local button = getglobal(frameName.."Item"..iButton);
		if (GameTooltip:IsOwned(button)) then
			local buttonID = button:GetID();
			local link = GetContainerItemLink(frameID, buttonID);
			local name = nameFromLink(link);
			
			if (name) then
				local texture, itemCount, locked, quality, readable = GetContainerItemInfo(frameID, buttonID);
				if (quality == nil) then quality = qualityFromLink(link); end

				TT_TooltipCall(GameTooltip, name, link, quality, itemCount);
			end
		end
	end
end


function TT_GameTooltip_SetLootItem(this, slot)
	Orig_GameTooltip_SetLootItem(this, slot);
	
	local link = GetLootSlotLink(slot);
	local name = nameFromLink(link);
	if (name) then
		local texture, item, quantity, quality = GetLootSlotInfo(slot);
		if (quality == nil) then quality = qualityFromLink(link); end
		TT_TooltipCall(GameTooltip, name, link, quality, quantity);
	end
end

function TT_GameTooltip_SetQuestItem(this, qtype, slot)
	Orig_GameTooltip_SetQuestItem(this, qtype, slot);
	local link = GetQuestItemLink(qtype, slot);
	if (link) then
		local name, texture, quantity, quality, usable = GetQuestItemInfo(qtype, slot);
		TT_TooltipCall(GameTooltip, name, link, quality, quantity);
	end
end

function TT_GameTooltip_SetQuestLogItem(this, qtype, slot)
	Orig_GameTooltip_SetQuestLogItem(this, qtype, slot);
	local link = GetQuestLogItemLink(qtype, slot);
	if (link) then
		local name, texture, quantity, quality, usable = GetQuestLogRewardInfo(slot);
		if (name == nil) then name = nameFromLink(link); end
		quality = qualityFromLink(link); -- I don't trust the quality returned from the above function.

		TT_TooltipCall(GameTooltip, name, link, quality, quantity);
	end
end

function TT_GameTooltip_SetInventoryItem(this, unit, slot)
	local hasItem, hasCooldown, repairCost = Orig_GameTooltip_SetInventoryItem(this, unit, slot);
	local link = GetInventoryItemLink(unit, slot);
	if (link) then
		local name = nameFromLink(link);
		local quantity = GetInventoryItemCount(unit, slot);
		local quality = GetInventoryItemQuality(unit, slot);
		if (quality == nil) then quality = qualityFromLink(link); end

		TT_TooltipCall(GameTooltip, name, link, quality, quantity);
	end

	return hasItem, hasCooldown, repairCost;
end

function TT_GameTooltip_SetMerchantItem(this, slot)
	Orig_GameTooltip_SetMerchantItem(this, slot);
	local link = GetMerchantItemLink(slot);
	if (link) then
		local name, texture, price, quantity, numAvailable, isUsable = GetMerchantItemInfo(slot);
		local quality = qualityFromLink(link);
		TT_TooltipCall(GameTooltip, name, link, quality, quantity, price);
	end
end

function TT_GameTooltip_SetCraftItem(this, skill, slot)
	Orig_GameTooltip_SetCraftItem(this, skill, slot);
	local link;
	if (slot) then
		link = GetCraftReagentItemLink(skill, slot);
		if (link) then
			local name, texture, quantity, quantityHave = GetCraftReagentInfo(skill, slot);
			local quality = qualityFromLink(link);
			TT_TooltipCall(GameTooltip, name, link, quality, quantity, 0);
		end
	else
		link = GetCraftItemLink(skill);
		if (link) then
			local name = nameFromLink(link);
			local quality = qualityFromLink(link);
			TT_TooltipCall(GameTooltip, name, link, quality, 1, 0);
		end
	end
end

function TT_GameTooltip_SetTradeSkillItem(this, skill, slot)
	Orig_GameTooltip_SetTradeSkillItem(this, skill, slot);
	local link;
	if (slot) then
		link = GetTradeSkillReagentItemLink(skill, slot);
		if (link) then
			local name, texture, quantity, quantityHave = GetTradeSkillReagentInfo(skill, slot);
			local quality = qualityFromLink(link);
			TT_TooltipCall(GameTooltip, name, link, quality, quantity, 0);
		end
	else
		link = GetTradeSkillItemLink(skill);
		if (link) then
			local name = nameFromLink(link);
			local quality = qualityFromLink(link);
			TT_TooltipCall(GameTooltip, name, link, quality, 1, 0);
		end
	end
end

-- Given a Blizzard item link, breaks it into it's itemID, randomProperty, enchantProperty, uniqueness and name
function TT_BreakLink(link)
	local i,j, itemID, enchant, randomProp, uniqID, name = string.find(link, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h[[]([^]]+)[]]|h");
	return tonumber(itemID or 0), tonumber(randomProp or 0), tonumber(enchant or 0), tonumber(uniqID or 0), name;
end


function TT_FindItemInBags(findName)
	for bag = 0, 4, 1 do
		size = GetContainerNumSlots(bag);
		if (size) then
			for slot = size, 1, -1 do
				local link = GetContainerItemLink(bag, slot);
				if (link) then
					local itemID, randomProp, enchant, uniqID, itemName = TT_BreakLink(link);
					if (itemName == findName) then
						return bag, slot, itemID, randomProp, enchant, uniqID;
					end
				end
			end
		end
	end
end

function TT_GameTooltip_SetAuctionSellItem(this)
	Orig_GameTooltip_SetAuctionSellItem(this);
    local name, texture, quantity, quality, canUse, price = GetAuctionSellItemInfo();
	if (name) then
		local bag, slot = TT_FindItemInBags(name);
		if (bag) then
			local link = GetContainerItemLink(bag, slot);
			if (link) then
				TT_TooltipCall(GameTooltip, name, link, quality, quantity, price);
			end
		end
	end
end

function TT_IMInv_ItemButton_OnEnter()
	Orig_IMInv_ItemButton_OnEnter();
	if(not IM_InvList) then return; end
	local id = this:GetID();

	if(id == 0) then
		id = this:GetParent():GetID();
	end
	local offset = FauxScrollFrame_GetOffset(ItemsMatrix_IC_ScrollFrame);
	local item = IM_InvList[id + offset];

	if (not item) then return; end
	local imlink = ItemsMatrix_GetHyperlink(item.name);
	local link = fakeLink(imlink, item.quality, item.name);
	if (link) then
		TT_TooltipCall(GameTooltip, item.name, link, item.quality, item.count, 0);
	end
end

function TT_ItemsMatrixItemButton_OnEnter()
	Orig_ItemsMatrixItemButton_OnEnter();
	local imlink = ItemsMatrix_GetHyperlink(this:GetText());
	if (imlink) then
		local name = this:GetText();
		local link = fakeLink(imlink, -1, name);
		TT_TooltipCall(GameTooltip, name, link, -1, 1, 0);
	end
end

local function getLootLinkServer()
	return LootLinkState.ServerNamesToIndices[GetCVar("realmName")];
end

local function getLootLinkLink(name)
	local itemLink = ItemLinks[name];
	if (itemLink and itemLink.c and itemLink.i and LootLink_CheckItemServer(itemLink, getLootLinkServer())) then
		local item = string.gsub(itemLink.i, "(%d+):(%d+):(%d+):(%d+)", "%1:0:%3:%4");
		local link = "|c"..itemLink.c.."|Hitem:"..item.."|h["..name.."]|h|r";
		return link;
	end
	return nil;
end

function TT_LootLinkItemButton_OnEnter()
	Orig_LootLinkItemButton_OnEnter();
	local name = this:GetText();
	local link = getLootLinkLink(name);
	if (link) then
		local quality = qualityFromLink(link);
		TT_TooltipCall(LootLinkTooltip, name, link, quality, 1, 0);
	end
end

function TT_AllInOneInventory_ModifyItemTooltip(bag, slot, tooltip)
	Orig_AllInOneInventory_ModifyItemTooltip(bag, slot, tooltip);

	local tooltip = getglobal(tooltipName);
	if (not tooltip) then
		tooltip = getglobal("GameTooltip");
		tooltipName = "GameTooltip";
	end
	if (not tooltip) then return false; end

	local link = GetContainerItemLink(bag, slot);
	local name = nameFromLink(link);
	if (name) then
		local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot);
		if (quality == nil) then quality = qualityFromLink(link); end

		TT_TooltipCall(GameTooltip, name, link, quality, itemCount, 0);
	end
end

function TT_GameTooltip_SetOwner(this, owner, anchor)
	Orig_GameTooltip_SetOwner(this, owner, anchor);
	this.owner = owner;
	this.anchor = anchor;
end

end
