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
	
	EnhancedTooltip:SetHeight(height);
	EnhancedTooltip:SetWidth(width);
	EnhancedTooltip:SetPoint("TOPLEFT", currentTooltip:GetName(), "BOTTOMLEFT", 0, 0);
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
	EnhancedTooltipPreview:SetModel("Item\\ObjectComponents\\" .. class .. "\\" .. file .. ".mdx");
	EnhancedTooltipPreview:SetLight(1, 0.2, 0, -0.9, -0.707, 0.7, 1.0, 0.5, 0.5, 0.8, 0.5, 0.5, 1.0);
	EnhancedTooltipPreview:SetPosition(0.0, 0.0, 0.0);
	EnhancedTooltipPreview:SetRotation(1.5);
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

function TT_AddTooltip(name, frame, count)

end

function TT_Chat_OnHyperlinkShow(link)
        Orig_Chat_OnHyperlinkShow(link);

        local name = ItemRefTooltipTextLeft1:GetText();
        if( name and TT_ChatCurrentItem ~= name ) then
                TT_ChatCurrentItem = name;
                
				TT_Clear();
				TT_AddTooltip(ItemRefTooltip, name, -1, 1);
				TT_Show(ItemRefTooltip);
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
                        TT_AddTooltip(GameTooltip, name, aiQuality, aiCount);
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

		TT_Clear();
		TT_AddTooltip(GameTooltip, name, quality, itemCount);
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

				TT_Clear()
				TT_AddTooltip(GameTooltip, name, quality, itemCount);
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
		TT_Clear()
		TT_AddTooltip(GameTooltip, name, quality, quantity);
		TT_Show(GameTooltip);
	end
end

function TT_GameTooltip_SetQuestItem(this, qtype, slot)
	Orig_GameTooltip_SetQuestItem(this, qtype, slot);
	local name, texture, quantity, quality, usable = GetQuestItemInfo(qtype, slot);
	TT_Clear();
	TT_AddTooltip(GameTooltip, name, quality, quantity);
	TT_Show(GameTooltip);
end



end
