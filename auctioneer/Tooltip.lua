--[[
  Additional function hooks to allow hooks into more tooltips
  <%version%>
  $Id$
]]

-- Example: /script TT_Clear(); TT_AddLine("ItemName"); TT_LineQuality(3); TT_AddLine("Average bid: ", 105000); TT_AddLine("Median bid: ", 110000); TT_AddLine("Vendor buy: ", 9050); TT_AddLine("Vendor sell: ", 25000); TT_Show(GameTooltip);

if (TOOLTIPS_INCLUDED == nil) then
TOOLTIPS_INCLUDED = true;

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

		-- Hook the hide function so we can disappear
		Orig_GameTooltip_OnHide = GameTooltip_OnHide;
		GameTooltip_OnHide = TT_GameTooltip_OnHide;


        TT_LOADED = true;
end

function TT_Show(currentTooltip)
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

	if (EnhancedTooltipPreview:IsVisible()) then
		if (width < 256) then width = 256; end
		EnhancedTooltipPreview:SetHeight(128 + 40);
		EnhancedTooltipPreview:ClearAllPoints();
		EnhancedTooltipPreview:SetWidth(width + 40);
		EnhancedTooltipPreview:SetPoint("TOP", "EnhancedTooltip", "TOP", 0, 76-height);
		height = height + 72;
	end

	currentTooltip:Show();

	local reposition = false;
	local fTop = currentTooltip:GetTop();
	local fLeft = currentTooltip:GetLeft();
	local fRight = currentTooltip:GetRight();
	local fBottom = currentTooltip:GetBottom();
	local fWidth = currentTooltip:GetWidth();
	local fHeight = currentTooltip:GetHeight();

	if (fWidth > minWidth) and (width > fWidth) then
		width = fWidth;
	elseif (width < fWidth) and (width + 20 > fWidth) then
		width = fWidth;
	end

	local sWidth = GetScreenWidth();
	local sHeight = GetScreenHeight();

	local tBottom = fBottom - height - 64;
	local tRight = fRight + 20;

--	p("fTop:",fTop, "fLeft:",fLeft, "fBottom:",fBottom, "fRight",fRight, "fWidth:",fWidth, "sWidth:",sWidth, "sHeight:",sHeight, "tBottom",tBottom, "tRight:", tRight);
	if (tBottom < 0) then 
		reposition = true;
		fTop = fTop - tBottom;
	end
	if (tRight > sWidth) then 
		reposition = true;
		fLeft = fLeft - (tRight - sWidth);
	end
	if (reposition) then
--		p("Repositioning to", fLeft, fTop);
		currentTooltip:ClearAllPoints();
		currentTooltip:SetPoint("BOTTOMRIGHT", "UIParent", "TOPLEFT", fLeft+fWidth, (sHeight-fTop+fHeight)*-1 );
	end
	
	EnhancedTooltip:SetHeight(height);
	EnhancedTooltip:SetWidth(width);
	EnhancedTooltip:SetPoint("TOPRIGHT", currentTooltip:GetName(), "BOTTOMRIGHT", 0, 0);
	EnhancedTooltip:Show();
end

function TT_Hide()
	EnhancedTooltip:Hide();
	TT_ChatCurrentItem = "";
end

function TT_Clear()
	TT_Hide();
	EnhancedTooltipPreview:Hide();
	EnhancedTooltipIcon:Hide();
	EnhancedTooltipIcon:SetTexture("Interface\\Buttons\\UI-Quickslot2");
	for i = 1, 20 do
		local ttText = getglobal("EnhancedTooltipText"..i);
		ttText:Hide();
		ttText:SetTextColor(1.0,1.0,1.0);
	end
	for i = 1, 10 do
		local ttMoney = getglobal("EnhancedTooltipMoney"..i);
		ttMoney:Hide();
	end
	EnhancedTooltip.lineCount = 0;
	EnhancedTooltip.moneyCount = 0;
	EnhancedTooltip.minWidth = 0;
end

TT_MoneySpacing = 4;
function TT_AddLine(lineText, moneyAmount)
	local curLine = EnhancedTooltip.lineCount + 1;
	local line = getglobal("EnhancedTooltipText"..curLine);
	line:SetText(lineText);
	local lineWidth = line:GetWidth();
	line:SetTextColor(1.0, 1.0, 1.0);
	line:Show();
	EnhancedTooltip.lineCount = curLine;
	if (moneyAmount ~= nil) and (moneyAmount > 0) then
		local curMoney = EnhancedTooltip.moneyCount + 1;
		local money = getglobal("EnhancedTooltipMoney"..curMoney);
		money:SetPoint("LEFT", line:GetName(), "RIGHT", TT_MoneySpacing, 0);
		lineWidth = lineWidth + money:GetWidth() + TT_MoneySpacing;
		MoneyFrame_Update(money:GetName(), math.floor(moneyAmount));
		money:Show();
		EnhancedTooltip.moneyCount = curMoney;
	end
	lineWidth = lineWidth + 20;
	if (lineWidth > EnhancedTooltip.minWidth) then
		EnhancedTooltip.minWidth = lineWidth;
	end
end

function TT_LineColor(r, g, b)
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

function TT_SetModel(class, file)
	local scale = 1.0;
	local pos = 0.6;
	local gender = "M";
	local _, race = UnitRace("player");
	if (strsub(class, -1) == "*") then
		class = strsub(class, 0, -2);
		race = strsub(race, 0, 2);
		if (UnitSex("player") > 0) then gender = "F"; end
		file = file .. "_" .. race .. gender;
	end
	if (gender == "F") then scale = scale * 1.1; end
	if (race == "Ta") or (race == "Or") then scale = scale * 0.9; end
	if (race == "Gn") or (race == "Dw") then scale = scale * 1.1; end
	if (class == "Head") then scale = scale * 1.8; pos = 0.3; end
	if (class == "Shoulder") then scale = scale * 1.8; pos = 0.5; end
	if (class == "Weapon") then
		local typ = strsub(file, 0, 3);
		if (typ == "Axe") then scale = 0.8; pos = 0.9; end
		if (typ == "Bow") then scale = 1.0; pos = 0.2; end
		if (typ == "Clu") then scale = 0.9; pos = 0.8; end
		if (typ == "Fir") then scale = 0.8; pos = 1.0; end
		if (typ == "Gla") then scale = 1.0; end
		if (typ == "Ham") then scale = 0.8; end
		if (typ == "Han") then scale = 1.3; end
		if (typ == "Kni") then scale = 2.0; end
		if (typ == "Mac") then scale = 1.0; end
		if (typ == "Mis") then scale = 1.5; end
		if (typ == "Pol") then scale = 0.8; end
		if (typ == "Sta") then scale = 0.8; pos = 0.3; end
		if (typ == "Swo") then scale = 1.0; pos = 0.8; end
		if (typ == "Thr") then scale = 1.6; pos = 0.8; end
		if (typ == "Tot") then scale = 1.5; end
		if (typ == "Wan") then scale = 1.8; end
	end
--	p("Setting model: ", class, file);
	EnhancedTooltipPreview:SetModel("Item\\ObjectComponents\\" .. class .. "\\" .. file .. ".mdx");
	EnhancedTooltipPreview:SetLight(1, 0.2, 0, -0.9, -0.707, 0.7, 0.9, 0.6, 0.25, 0.8, 0.25, 0.6, 0.9);
	EnhancedTooltipPreview:SetPosition(pos, -0.1, 0);
	EnhancedTooltipPreview:SetRotation(1.5);
	EnhancedTooltipPreview:SetScale(scale);
	EnhancedTooltipPreview:Show();
end


function TT_GameTooltip_OnEvent(ev)
	p("Game Tooltip Event: " .. ev);
end

function TT_GameTooltip_OnHide()
	TT_Hide();
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

function TT_AddTooltip(frame, name, link, quality, count, price)
	-- Empty function; hook here if you want in on the action!
end

function TT_Chat_OnHyperlinkShow(link)
	Orig_Chat_OnHyperlinkShow(link);

	if (ItemRefTooltip:IsVisible()) then
		local name = ItemRefTooltipTextLeft1:GetText();
		if( name and TT_ChatCurrentItem ~= name ) then
			local fabricatedLink = "|H"..link.."|h["..name.."]|h";
			TT_ChatCurrentItem = name;
			
			TT_Clear();
			TT_AddTooltip(ItemRefTooltip, name, fabricatedLink, -1, 1);
			TT_Show(ItemRefTooltip);
		end
	end
end

function TT_AuctionFrameItem_OnEnter(type, index)
        Orig_AuctionFrameItem_OnEnter(type, index);

        local link = GetAuctionItemLink(type, index);
        if( link ) then
                local name = nameFromLink(link);
                if( name ) then
                        local aiName, aiTexture, aiCount, aiQuality, aiCanUse, aiLevel, aiMinBid, aiMinIncrement, aiBuyoutPrice, aiBidAmount, aiHighBidder, aiOwner = GetAuctionItemInfo(type, index);
						TT_Clear();
                        TT_AddTooltip(GameTooltip, name, link, aiQuality, aiCount);
						TT_Show(GameTooltip);
                end
        end
end

function TT_ContainerFrameItemButton_OnEnter()
	Orig_ContainerFrameItemButton_OnEnter();

	local frameID = this:GetParent():GetID();
	local buttonID = this:GetID();
	local link = GetContainerItemLink(frameID, buttonID);
	local name = nameFromLink(link);
	
	if( name ) then
		local texture, itemCount, locked, quality, readable = GetContainerItemInfo(frameID, buttonID);
		if (quality == nil) then quality = qualityFromLink(link); end

		TT_Clear();
		TT_AddTooltip(GameTooltip, name, link, quality, itemCount);
		TT_Show(GameTooltip);
	end
end

function TT_ContainerFrame_Update(frame)
	Orig_ContainerFrame_Update(frame);

	local frameID = frame:GetID();
	local frameName = frame:GetName();
	local iButton;
	for iButton = 1, frame.size do
		local button = getglobal(frameName.."Item"..iButton);
		if( GameTooltip:IsOwned(button) ) then
			local buttonID = button:GetID();
			local link = GetContainerItemLink(frameID, buttonID);
			local name = nameFromLink(link);
			
			if( name ) then
				local texture, itemCount, locked, quality, readable = GetContainerItemInfo(frameID, buttonID);
				if (quality == nil) then quality = qualityFromLink(link); end

				TT_Clear()
				TT_AddTooltip(GameTooltip, name, link, quality, itemCount);
				TT_Show(GameTooltip);
			end
		end
	end
end


function TT_GameTooltip_SetLootItem(this, slot)
	Orig_GameTooltip_SetLootItem(this, slot);
	
	local link = GetLootSlotLink(slot);
	local name = nameFromLink(link);
	if( name ) then
		local texture, item, quantity, quality = GetLootSlotInfo(slot);
		if (quality == nil) then quality = qualityFromLink(link); end
		TT_Clear()
		TT_AddTooltip(GameTooltip, name, link, quality, quantity);
		TT_Show(GameTooltip);
	end
end

function TT_GameTooltip_SetQuestItem(this, qtype, slot)
	Orig_GameTooltip_SetQuestItem(this, qtype, slot);
	local link = GetQuestItemLink(qtype, slot);
	if (link) then
		local name, texture, quantity, quality, usable = GetQuestItemInfo(qtype, slot);
		TT_Clear();
		TT_AddTooltip(GameTooltip, name, link, quality, quantity);
		TT_Show(GameTooltip);
	end
end

function TT_GameTooltip_SetQuestLogItem(this, qtype, slot)
	Orig_GameTooltip_SetQuestLogItem(this, qtype, slot);
	local link = GetQuestLogItemLink(qtype, slot);
	if (link) then
		local name, texture, quantity, quality, usable = GetQuestLogRewardInfo(slot);
		if (name == nil) then name = nameFromLink(link); end
		quality = qualityFromLink(link); -- I don't trust the quality returned from the above function.

		TT_Clear();
		TT_AddTooltip(GameTooltip, name, link, quality, quantity);
		TT_Show(GameTooltip);
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

		TT_Clear();
		TT_AddTooltip(GameTooltip, name, link, quality, quantity);
		TT_Show(GameTooltip);
	end

	return hasItem, hasCooldown, repairCost;
end

function TT_GameTooltip_SetMerchantItem(this, slot)
	Orig_GameTooltip_SetMerchantItem(this, slot);
	local link = GetMerchantItemLink(slot);
	if (link) then
		local name, texture, price, quantity, numAvailable, isUsable = GetMerchantItemInfo(slot);
		local quality = qualityFromLink(link);
		TT_Clear();
		TT_AddTooltip(GameTooltip, name, link, quality, quantity, price);
		TT_Show(GameTooltip);
	end
end




end
