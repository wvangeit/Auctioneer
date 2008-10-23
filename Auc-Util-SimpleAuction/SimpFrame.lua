--[[
	Auctioneer Advanced - Simplified Auction Posting
	Version: <%version%> (<%codename%>)
	Revision: $Id: AprFrame.lua 3576 2008-10-10 03:07:13Z aesir $
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds a simple dialog for
	easy posting of your auctionables when you are at the auction-house.

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
		You have an implicit license to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]
if not AucAdvanced then return end

local lib = AucAdvanced.Modules.Util.SimpleAuction
local private = lib.Private
local const = AucAdvanced.Const
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()

local frame
local TAB_NAME = "Post"

function private.ShiftFocus(frame, ...)
	print("Shifting focus on", frame:GetName(), ...)
	local dest
	if IsShiftKeyDown() then
		dest = frame.prevFrame
	else
		dest = frame.nextFrame
	end
	if dest and dest.SetFocus then
		dest:SetFocus()
	else
		frame:ClearFocus()
	end
end

function private.SetPrevNext(frame, prevFrame, nextFrame)
	frame.prevFrame = prevFrame
	frame.nextFrame = nextFrame
	frame:SetScript("OnTabPressed", private.ShiftFocus)
	frame:SetScript("OnEnterPressed", private.ShiftFocus)
end

function private.SigFromLink(link)
	local itype, id, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(link)
	if itype=="item" then
		if enchant ~= 0 then
			return ("%d:%d:%d:%d"):format(id, suffix, factor, enchant)
		elseif factor ~= 0 then
			return ("%d:%d:%d"):format(id, suffix, factor)
		elseif suffix ~= 0 then
			return ("%d:%d"):format(id, suffix)
		end
		return tostring(id)
	end
	-- returns nil
end

function private.GetItems(link)
	local matching = AucAdvanced.API.QueryImage({ link = link })
	local aSeen, lBid, lBuy, uBid, uBuy, aBuy = 0,0,0,0,0,0
	local items = {}

	local live = false
	if AuctionFrame:IsVisible() then
		live = true
		local n = GetNumAuctionItems("owner")
		if n and n > 0 then
			for i = 1, n do
				local item = AucAdvanced.Scan.GetAuctionItem("owner", i)
				if item then
					table.insert(items, item)
					local bid, buy, owner = item[const.MINBID], item[const.BUYOUT], item[const.OWNER]
					if not uBid then
						uBid = bid
					else
						uBid = min(uBid, bid)
					end
					if not uBuy then
						uBuy = buy
					elseif buy then
						uBuy = min(uBuy, buy)
					end
				end
			end
		end
	end

	for pos, item in ipairs(matching) do 
		local bid, buy, owner, stk = item[const.MINBID], item[const.BUYOUT], item[const.OWNER], item[const.COUNT]
		stk = stk or 1
		local bidea, buyea
		if bid then bidea = bid/stk end
		if buy then buyea = buy/stk end

		if owner == player then
			if not live then
				if not uBid then uBid = bidea else uBid = min(uBid, bidea) end
				if not uBuy then uBuy = buyea elseif buyea then uBuy = min(uBuy, buyea) end
			end
		else
			if not lBid then lBid = bidea else lBid = min(lBid, bidea) end
			if not lBuy then lBuy = buyea elseif buyea then lBuy = min(lBuy, buyea) end
			if buy then
				aBuy = aBuy + buy
				aSeen = aSeen + stk
			end
		end
	end
	return #items, items, uBid, uBuy, lBid, lBuy, aSeen, aBuy
end

local GOLD="ffd100"
local SILVER="e6e6e6"
local COPPER="c8602c"

local GSC_3 = "|cff%s%d|cff000000.|cff%s%02d|cff000000.|cff%s%02d|r"
local GSC_2 = "|cff%s%d|cff000000.|cff%s%02d|r"
local GSC_1 = "|cff%s%d|r"

local function coins(money)
	money = math.floor(tonumber(money) or 0)
	local g = math.floor(money / 10000)
	local s = math.floor(money % 10000 / 100)
	local c = money % 100

	if g > 0 then
		return GSC_3:format(GOLD, g, SILVER, s, COPPER, c)
	elseif s > 0 then
		return GSC_2:format(SILVER, s, COPPER, c)
	else
		return GSC_1:format(COPPER, c)
	end
end

function private.UpdateDisplay()
	local cBid, cBuy = MoneyInputFrame_GetCopper(frame.minprice), MoneyInputFrame_GetCopper(frame.buyout)
	local cStack = tonumber(frame.stacks.size:GetText())
	local cNum = tonumber(frame.stacks.num:GetText()) or 1
	local oStack, oBid, oBuy, oReason, oLink = unpack(frame.detail)
	local lStack = frame.stacks.size.lastSize or oStack

	print("Updating", unpack(frame.detail))

	local dBid = abs(cBid/lStack*oStack-oBid)
	local dBuy = abs(cBuy/lStack*oStack-oBuy)

	local priceType = "auto"
	if dBid >= 1 or dBuy >= 1 then
		priceType = "fixed"
		frame.err:SetText("Manual pricing on item")
	end

	if priceType == "auto" and cStack ~= oStack then
		return private.UpdatePricing()
	elseif priceType == "fixed" and cStack ~= lStack then
		cBid = cBid / lStack * cStack
		cBuy = cBuy / lStack * cStack
		MoneyInputFrame_ResetMoney(frame.minprice)
		MoneyInputFrame_SetCopper(frame.minprice, ceil(cBid))
		MoneyInputFrame_ResetMoney(frame.buyout)
		MoneyInputFrame_SetCopper(frame.buyout, ceil(cBuy))
		frame.err:SetText("Adjusted price to new stack size")
	end

	if GetSellValue then
		local vendor = GetSellValue(oLink) or 0
		if vendor > cBid / cStack then
			frame.err:SetText("Warning: Bid is below vendor price")
		end
	end

	local coinsBid, coinsBuy
	if cBid > 0 then
		coinsBid = coins(cBid)
	else
		coinsBid = "no"
		frame.err:SetText("Error: No bid price set")
	end
	if cBuy > 0 then
		coinsBuy = coins(cBuy)
		if cBuy < cBid then
			frame.err:SetText("Error: Buyout cannot be less than bid price")
		end
	else
		coinsBuy = "no"
	end

	local text = "Auctioning %d lots of %d sized stacks at %s bid / %s buyout per stack"
	frame.info:SetText(text:format(cNum, cStack, coinsBid, coinsBuy))
	frame.stacks.equals:SetText("= "..(cStack * cNum))
end

function private.UpdatePricing()
	local link = frame.icon.itemLink
	if link then
		local mid, seen = AucAdvanced.API.GetMarketValue(link)
		if not mid then
			mid = 0
		end
		if not seen then
			seen = 0
		end
		local imgseen, items, lBid, lBuy, uBid, uBuy = private.GetItems(link)

		local stack = tonumber(frame.stacks.size:GetText())
		local _,_,_,_,_,_,_,stx = GetItemInfo(link)
		local total = GetItemCount(link) or 0
		stx = min(stx, total)

		if not stack or stack > stx then
			stack = stx
			frame.stacks.size:SetText(stack)
		end

		local num = tonumber(frame.stacks.num:GetText())
		if not num then
			num = 1
			frame.stacks.num:SetText(num)
		end

		local bid, buy, reason
		
		if mid and (seen > 5 or imgseen < 3) then
			bid, buy, reason = mid * stack * 0.8, mid * stack, "Using market value"
		end
		if frame.options.matchmy:GetChecked() then
			if lBid or lBuy then
				bid, buy, reason = lBid * stack, lBuy * stack, "Matching your prices"
			end
		end
		if frame.options.undercut:GetChecked() then
			if uBid and uBuy and (uBid < bid or uBuy < buy) then
				bid, buy, reason = uBid * stack - 1, uBuy * stack - 1, "Undercutting market"
				if bid > buy * 0.8 then
					bid = bid * 0.8
				end
			end
		end

		if not buy and aBuy then
			bid, buy, reason = aBuy * stack * 0.8, aBuy * stack, "Using current market data"
		end

		if not buy and GetSellValue then
			local vendor = GetSellValue(link) or 0
			local vBuy = vendor * 3
			bid, buy, reason = vBuy * stack * 0.8, vBuy * stack, "Marking up vendor"
		end

		if not bid and buy then
			bid = buy * 0.8
		end
		if not bid then
			bid, buy, reason = 1, 0, "Unable to calculate price" 
		end

		bid, buy = tonumber(bid) or 1, tonumber(buy) or 0

		MoneyInputFrame_ResetMoney(frame.minprice)
		MoneyInputFrame_SetCopper(frame.minprice, ceil(bid))

		MoneyInputFrame_ResetMoney(frame.buyout)
		MoneyInputFrame_SetCopper(frame.buyout, ceil(buy))

		frame.detail = { stack, bid, buy, reason, link }
		frame.err:SetText(reason)

		private.UpdateDisplay(reason)
	end
end

function private.IconClicked()
	local objType, _, itemLink = GetCursorInfo()
	ClearCursor()
	if objType == "item" then
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink)
		local itemCount = GetItemCount(itemLink)
		frame.icon.itemLink = itemLink
		frame.icon:SetNormalTexture(itemTexture)
		local size = 18
		if itemCount > 999 then
			local size = 14
		elseif itemCount > 99 then
			local size = 16
		end
		frame.icon.count:SetFont(AucAdvSimpleNumberFontLarge.font, size, "OUTLINE")
		frame.icon.count:SetText(itemCount)

		frame.name:SetText(itemName)
		frame.name:SetTextColor(GetItemQualityColor(itemRarity))
	else
		frame.icon.itemLink = nil
		frame.icon:SetNormalTexture(nil)
		frame.icon.count:SetText("")
		frame.name:SetText("")
		frame.name:SetText(itemName)
	end
	frame.info:SetText("")
	frame.err:SetText("")
	frame.stacks.equals:SetText("= 0")
	private.UpdatePricing()
end

function private.DoTooltip()
end

function private.UndoTooltip
()
end

function private.CreateFrames()
	if frame then return end

	local SelectBox = LibStub:GetLibrary("SelectBox")
	local ScrollSheet = LibStub:GetLibrary("ScrollSheet")

	frame = CreateFrame("Frame", "AucAdvSimpFrame", AuctionFrame)
	private.frame = frame
	private.realmKey, private.realm = AucAdvanced.GetFaction()
	local DiffFromModel = 0
	local MatchString = ""
	frame.list = {}
	frame.cache = {}

	frame:SetParent(AuctionFrame)
	frame:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT")
	frame:SetPoint("BOTTOMRIGHT", AuctionFrame, "BOTTOMRIGHT")

	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.title:SetPoint("TOP", frame,  "TOP", 0, -20)
	frame.title:SetText("Simple Auction - Simplified auction posting interface.")

	frame.slot = frame:CreateTexture(nil, "BORDER")
	frame.slot:SetPoint("TOPLEFT", frame, "TOPLEFT", 80, -45)
	frame.slot:SetWidth(50)
	frame.slot:SetHeight(50)
	frame.slot:SetTexCoord(0.15, 0.85, 0.15, 0.85)
	frame.slot:SetTexture("Interface\\Buttons\\UI-EmptySlot")

	frame.name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	frame.name:SetPoint("TOPLEFT", frame.slot, "TOPRIGHT", 10, -2)
	frame.name:SetText("Drop item onto slot")

	frame.info = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.info:SetPoint("TOPLEFT", frame.name, "BOTTOMLEFT", 0, -3)
	frame.info:SetText("To auction an item, drag it from your bag.")

	frame.err = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.err:SetPoint("TOPLEFT", frame.info, "BOTTOMLEFT", 0, 0)
	frame.err:SetTextColor(1,0.2,0,1)
	frame.err:SetText("-- No item selected --")

	frame.icon = CreateFrame("Button", nil, frame)
	frame.icon:SetPoint("TOPLEFT", frame.slot, "TOPLEFT", 3, -3)
	frame.icon:SetWidth(42)
	frame.icon:SetHeight(42)
	frame.icon:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp")
	frame.icon:SetScript("OnClick", private.IconClicked)
	frame.icon:SetScript("OnReceiveDrag", private.IconClicked)
	frame.icon:SetScript("OnEnter", private.DoTooltip)
	frame.icon:SetScript("OnLeave", private.UndoTooltip)

	local numberFont = CreateFont("AucAdvSimpleNumberFontLarge")
	numberFont:CopyFontObject(GameFontHighlight)
	numberFont.font = numberFont:GetFont()
	numberFont:SetFont(numberFont.font, 12, "OUTLINE")
	numberFont:SetShadowColor(0,0,0)
	numberFont:SetShadowOffset(3,-2)

	frame.icon.count = frame.icon:CreateFontString(nil, "OVERLAY", "AucAdvSimpleNumberFontLarge")
	frame.icon.count:SetPoint("BOTTOMLEFT", frame.icon, "BOTTOMLEFT", 3, 5)

	frame.minprice = CreateFrame("Frame", "AucAdvSimpFrameStart", frame, "MoneyInputFrameTemplate")
	frame.minprice.isMoneyFrame = true
	frame.minprice:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -120)
	frame.minprice.label = frame.minprice:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.minprice.label:SetPoint("BOTTOMLEFT", frame.minprice, "TOPLEFT", 0, 0)
	frame.minprice.label:SetText("Starting price:")
	AucAdvSimpFrameStartGold:SetWidth(50)

	frame.buyout = CreateFrame("Frame", "AucAdvSimpFrameBuyout", frame, "MoneyInputFrameTemplate")
	frame.buyout.isMoneyFrame = true
	frame.buyout:SetPoint("TOPLEFT", frame.minprice, "BOTTOMLEFT", 0, -20)
	frame.buyout.label = frame.buyout:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.buyout.label:SetPoint("BOTTOMLEFT", frame.buyout, "TOPLEFT", 0, 0)
	frame.buyout.label:SetText("Buyout price:")
	AucAdvSimpFrameBuyoutGold:SetWidth(50)

	frame.duration = CreateFrame("Frame", "AucAdvSimpFrameDuration", frame)
	frame.duration:SetPoint("TOPLEFT", frame.buyout, "BOTTOMLEFT", 0, -20)
	frame.duration:SetWidth(140)
	frame.duration:SetHeight(20)
	frame.duration.label = frame.duration:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.duration.label:SetPoint("BOTTOMLEFT", frame.duration, "TOPLEFT", 0, 0)
	frame.duration.label:SetText("Duration:");
	
	frame.duration.time = {
		intervals = {12, 24, 48},
		selected = 48,
		OnClick = function (obj, ...)
			local self = frame.duration.time
			for pos, dur in ipairs(self.intervals) do
				if obj == self[pos] then
					self.selected = dur
					self[pos]:SetChecked(true)
				else
					self[pos]:SetChecked(false)
				end
			end
		end,
	}
	local t = frame.duration.time
	for pos, dur in ipairs(t.intervals) do
		t[pos] = CreateFrame("CheckButton", "AucAdvSimpFrameDuration"..dur, frame.duration, "OptionsCheckButtonTemplate")
		t[pos]:SetPoint("TOPLEFT", frame.duration, "TOPLEFT", (pos-1)*53,0)
		t[pos]:SetHitRectInsets(-1, -25, -1, -1)
		t[pos].label = t[pos]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		t[pos].label:SetPoint("LEFT", t[pos], "RIGHT", 0, 0)
		t[pos].label:SetText(dur.."h")
		t[pos].dur = dur
		t[pos]:SetScript("OnClick", t.OnClick)
		if dur == t.selected then
			t[pos]:SetChecked(true)
		else
			t[pos]:SetChecked(false)
		end
	end

	frame.stacks = CreateFrame("Frame", "AucAdvSimpFrameStacks", frame)
	frame.stacks:SetPoint("TOPLEFT", frame.duration, "BOTTOMLEFT", 0, -20)
	frame.stacks:SetWidth(140)
	frame.stacks:SetHeight(20)
	frame.stacks.label = frame.duration:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.stacks.label:SetPoint("BOTTOMLEFT", frame.stacks, "TOPLEFT", 0, 0)
	frame.stacks.label:SetText("Stacks: (number x size)");

	frame.stacks.num = CreateFrame("EditBox", "AucAdvSimpFrameStackNum", frame.stacks, "InputBoxTemplate")
	frame.stacks.num:SetPoint("TOPLEFT", frame.stacks, "TOPLEFT", 5, 0)
	frame.stacks.num:SetAutoFocus(false)
	frame.stacks.num:SetHeight(18)
	frame.stacks.num:SetWidth(40)

	frame.stacks.mult = frame.duration:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.stacks.mult:SetPoint("BOTTOMLEFT", frame.stacks.num, "BOTTOMRIGHT", 5, 0)
	frame.stacks.mult:SetText("x")

	frame.stacks.size = CreateFrame("EditBox", "AucAdvSimpFrameStackSize", frame.stacks, "InputBoxTemplate")
	frame.stacks.size:SetPoint("TOPLEFT", frame.stacks.num, "TOPRIGHT", 20, 0)
	frame.stacks.size:SetAutoFocus(false)
	frame.stacks.size:SetHeight(18)
	frame.stacks.size:SetWidth(30)

	frame.stacks.equals = frame.duration:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.stacks.equals:SetPoint("BOTTOMLEFT", frame.stacks.size, "BOTTOMRIGHT", 5, 0)
	frame.stacks.equals:SetText("= 0")

	frame.options = CreateFrame("Frame", "AucAdvSimpFrameOptions", frame)
	frame.options:SetPoint("TOPLEFT", frame.stacks, "BOTTOMLEFT", 0, -20)
	frame.options:SetWidth(140)
	frame.options:SetHeight(300)
	frame.options.label = frame.options:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.options.label:SetPoint("BOTTOMLEFT", frame.options, "TOPLEFT", 0, 0)
	frame.options.label:SetText("Options:")

	frame.create = CreateFrame("Button", "AucAdvSimpFrameCreate", frame, "OptionsButtonTemplate")
	frame.create:SetPoint("BOTTOMRIGHT", AuctionFrameMoneyFrame, "TOPRIGHT", 0, 10)
	frame.create:SetWidth(140)
	frame.create:SetText("Create Auction")

	frame.remember = CreateFrame("Button", "AucAdvSimpFrameRemember", frame, "OptionsButtonTemplate")
	frame.remember:SetPoint("BOTTOMRIGHT", frame.create, "TOPRIGHT", 0, 0)
	frame.remember:SetWidth(140)
	frame.remember:SetText("Remember")

	MoneyInputFrame_SetPreviousFocus(frame.minprice, frame.stacks.size)
	MoneyInputFrame_SetNextFocus(frame.minprice, AucAdvSimpFrameBuyoutGold)
	MoneyInputFrame_SetPreviousFocus(frame.buyout, AucAdvSimpFrameStartCopper)
	MoneyInputFrame_SetNextFocus(frame.buyout, frame.stacks.num)
	private.SetPrevNext(frame.stacks.num, AucAdvSimpFrameBuyoutCopper, frame.stacks.size)
	private.SetPrevNext(frame.stacks.size, frame.stacks.num, AucAdvSimpFrameStartGold)
	
	function frame.options:AddOption(option, text)
		local item = CreateFrame("CheckButton", "AucAdvSimpFrameOption_"..option, self, "OptionsCheckButtonTemplate")
		if self.last then
			item:SetPoint("TOPLEFT", self.last, "BOTTOMLEFT", 0,7)
		else
			item:SetPoint("TOPLEFT", self, "TOPLEFT", 0,0)
		end
		self.last = item

		item:SetHitRectInsets(-1, -140, 3, 3)

		item.label = item:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		item.label:SetPoint("LEFT", item, "RIGHT", 0, 0)
		item.label:SetText(text)

		self[option] = item
	end

	frame.options:AddOption("matchmy", "Match my current")
	frame.options:AddOption("undercut", "Undercut competitors")

	function frame.ClickBagHook(_,_,button)
		if (not AucAdvanced.Settings.GetSetting("util.simpleauc.clickhook")) then return end
		local bag = this:GetParent():GetID()
		local slot = this:GetID()
		local texture, count, noSplit = GetContainerItemInfo(bag, slot)
		local link = GetContainerItemLink(bag, slot)
		if link then
			if (button == "LeftButton") and (IsAltKeyDown()) then
				print("Got", button, link)
			end
		end
	end

	frame.tab = CreateFrame("Button", "AuctionFrameTabUtilSimple", AuctionFrame, "AuctionTabTemplate")
	frame.tab:SetText(TAB_NAME)
	frame.tab:Show()
	PanelTemplates_DeselectTab(frame.tab)
	AucAdvanced.AddTab(frame.tab, frame)

	function frame.tab.OnClick(_, _, index)
		if not index then index = this:GetID() end
		local tab = getglobal("AuctionFrameTab"..index)
		if (tab and tab:GetName() == "AuctionFrameTabUtilSimple") then
			AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopLeft")
			AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Top")
			AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopRight")
			AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotLeft")
			AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Bot")
			AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotRight")
			AuctionFrameMoneyFrame:Show()
			frame:Show()
			AucAdvanced.Scan.GetImage()
			--frame.GenerateList(true)
		else
			AuctionFrameMoneyFrame:Show()
			frame:Hide()
		end
	end

	function frame.ClickAnythingHook(link)
		if not AucAdvanced.Settings.GetSetting("util.simpleauc.clickhookany") then return end
		-- Ugly: we assume arg1/arg3 is still set from the original OnClick/OnHyperLinkClick handler
		if (arg1=="LeftButton" or arg3=="LeftButton") and IsAltKeyDown() then
			frame.SelectItem(nil, nil, link)
		end
	end

	Stubby.RegisterFunctionHook("ContainerFrameItemButton_OnModifiedClick", -300, frame.ClickBagHook)
	hooksecurefunc("AuctionFrameTab_OnClick", frame.tab.OnClick)

	hooksecurefunc("HandleModifiedItemClick", frame.ClickAnythingHook)
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
