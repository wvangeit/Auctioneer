--[[
	Auctioneer Advanced
	Version: <%version%> (<%codename%>)
	Revision: $Id: CorePost.lua 2904 2008-03-05 16:22:10Z rockslice $
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

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

--[[
	Auctioneer Purchasing Engine.

	This code helps modules that need to purchase things to do so in an extremely easy and
	queueable fashion.
]]

if (not AucAdvanced) then AucAdvanced = {} end
if (not AucAdvanced.Buy) then AucAdvanced.Buy = {} end

local lib = AucAdvanced.Buy
local private = {}
lib.Private = private

lib.Print = AucAdvanced.Print
local Const = AucAdvanced.Const
local print = lib.Print
local _

private.BuyRequests = {}
private.CurAuction = {}

--[[
	to add an auction to the Queue:
	AucAdvanced.Buy.QueueBuy(link, seller, count, minbid, buyout, price)
	price = price to pay
	AucAdv will buy the first auction it sees fitting the specifics at price.
	If item cannot be found in current scandata, entry is removed.
]]
function lib.QueueBuy(link, seller, count, minbid, buyout, price)
	table.insert(private.BuyRequests, {link, seller, count, minbid, buyout, price})
end

function lib.PushSearch()
	private.CurAuction["link"] = private.BuyRequests[1][1]
	private.CurAuction["sellername"] = private.BuyRequests[1][2]
	private.CurAuction["count"] = private.BuyRequests[1][3]
	private.CurAuction["minbid"] = private.BuyRequests[1][4]
	private.CurAuction["buyout"] = private.BuyRequests[1][5]
	private.CurAuction["price"] = private.BuyRequests[1][6]
	if private.CurAuction["price"] > private.CurAuction["buyout"] then
		private.CurAuction["price"] = private.CurAuction["buyout"]
	end
	table.remove(private.BuyRequests, 1)
	local minlevel, equiploc, itemType, itemSubType, stack, rarity, TypeID, SubTypeID
	private.CurAuction["itemname"], _, rarity, _, minlevel, itemType, itemSubType, stack, equiploc = GetItemInfo(private.CurAuction["link"])
	for catId, catName in pairs(AucAdvanced.Const.CLASSES) do
		if catName == itemType then
			TypeID = catId
			for subId, subName in pairs(AucAdvanced.Const.SUBCLASSES[TypeID]) do
				if subName == itemSubType then
					SubTypeID = subId
					break
				end
			end
			break
		end
	end
	if equiploc == "" then
		equiploc = nil
	end
	AucAdvanced.Scan.PushScan()
	AucAdvanced.Scan.StartScan(private.CurAuction["itemname"], minlevel, minlevel, equiploc, TypeID, SubTypeID, nil, rarity)
end

function lib.FinishedSearch(query)
	if private.CurAuction["link"] then
		local _, _, rarity, _, minlevel, _, _, _, equiploc = GetItemInfo(private.CurAuction["link"])
		if minlevel == 0 then
			minlevel = nil
		end
		if equiploc == "" then
			equiploc = nil
		end
		if (rarity == query.quality) and (minlevel == query.minUseLevel) and (equiploc == query.invType)
		and (private.CurAuction["itemname"] == query.name) then
			print("Auction for "..private.CurAuction["link"].." no longer exists")
			private.CurAuction = {}
		end
	end
end

function private.PromptPurchase()
	AucAdvanced.Scan.SetPaused(true)
	private.Prompt:Show()
	if private.CurAuction["price"] < private.CurAuction["buyout"] then
		private.Prompt.Text:SetText("Are you sure you want to bid on")
	else
		private.Prompt.Text:SetText("Are you sure you want to buyout")
	end
	private.Prompt.Value:SetText(private.CurAuction["link"].." for "..EnhTooltip.GetTextGSC(private.CurAuction["price"],true).."?")
	private.Prompt.Item.tex:SetTexture(private.CurAuction["texture"])
end

function lib.ScanPage()
	if not private.CurAuction["link"] then
		return
	end
	local batch = GetNumAuctionItems("list")
	for i = 1, batch do
		local link = GetAuctionItemLink("list", i)
		if link == private.CurAuction["link"] then
			local name, texture, count, _, _, _, minBid, minIncrement, buyout, curBid, owner = GetAuctionItemInfo("list", i)
			if ((not owner) or (owner == private.CurAuction["sellername"])) 
			and (count == private.CurAuction["count"]) and (minBid == private.CurAuction["minbid"]) 
			and (buyout == private.CurAuction["buyout"]) then --found the auction we were looking for
				if (private.CurAuction["price"] >= (curBid + minIncrement)) or (private.CurAuction["price"] >= buyout) then
					private.CurAuction["index"] = i
					private.CurAuction["texture"] = texture
					private.PromptPurchase()
					return
				else
					print("Unable to bid on "..link..". Price invalid")
					private.CurAuction = {}
				end
			end
		end
	end
end

function private.PerformPurchase()
	PlaceAuctionBid("list", private.CurAuction["index"], private.CurAuction["price"])
	private.CurAuction = {}
	private.Prompt:Hide()
	AucAdvanced.Scan.SetPaused(false)
end

function private.CancelPurchase()
	private.CurAuction = {}
	private.Prompt:Hide()
	AucAdvanced.Scan.SetPaused(false)
end

--[[
    PRIVATE: SendProcessor
	Sends out processor callback messages to all registered modules
]]
function private.SendProcessor(...)
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.Processor) then
				engineLib.Processor(...)
			end
		end
	end
end

function private.OnUpdate()
	if AuctionFrame and AuctionFrame:IsVisible() then
		if (not private.CurAuction["link"]) and (#private.BuyRequests > 0) then
			lib.PushSearch()
		end
	elseif private.CurAuction["link"] then --AH was closed, so reinsert current request back into the queue
		table.insert(private.BuyRequests, 1, {
			private.CurAuction["link"], 
			private.CurAuction["sellername"],
			private.CurAuction["count"],
			private.CurAuction["minbid"],
			private.CurAuction["buyout"],
			private.CurAuction["price"]
		})
	end
end

--[[
    Our frames for feeding event functions
]]

function private.OnEvent(...)
	if (event == "AUCTION_ITEM_LIST_UPDATE") then
		lib.ScanPage()
	end
end

function private.ShowTooltip()
	GameTooltip:SetOwner(AuctionFrameCloseButton, "ANCHOR_NONE")
	GameTooltip:SetHyperlink(private.CurAuction["link"])
	EnhTooltip.TooltipCall(GameTooltip, private.CurAuction["itemname"], private.CurAuction["link"], -1, private.CurAuction["count"], private.CurAuction["price"])
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint("TOPRIGHT", private.Prompt.Item, "TOPLEFT", -10, -20)
end

function private.HideTooltip()
	GameTooltip:Hide()
end

-- Simple timer to keep actions up-to-date even if an event misfires
private.updateFrame = CreateFrame("frame", nil, UIParent)
private.updateFrame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
private.updateFrame:SetScript("OnUpdate", private.OnUpdate)
private.updateFrame:SetScript("OnEvent", private.OnEvent)

private.Prompt = CreateFrame("frame", "AucAdvancedBuyPrompt", UIParent)
private.Prompt:Hide()
private.Prompt:SetPoint("TOP", "UIParent", "TOP", 0, -100)
private.Prompt:SetFrameStrata("DIALOG")
private.Prompt:SetHeight(100)
private.Prompt:SetWidth(400)
private.Prompt:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 9, right = 9, top = 9, bottom = 9 }
})
private.Prompt:SetBackdropColor(0,0,0,0.8)
private.Prompt:SetMovable(true)

private.Prompt.Item = CreateFrame("Button", "AucAdvancedBuyPromptItem", private.Prompt)
private.Prompt.Item:SetNormalTexture("Interface\\Buttons\\UI-Slot-Background")
private.Prompt.Item:GetNormalTexture():SetTexCoord(0,0.640625, 0, 0.640625)
private.Prompt.Item:SetPoint("TOPLEFT", private.Prompt, "TOPLEFT", 15, -15)
private.Prompt.Item:SetHeight(37)
private.Prompt.Item:SetWidth(37)
private.Prompt.Item:SetScript("OnEnter", private.ShowTooltip)
private.Prompt.Item:SetScript("OnLeave", private.HideTooltip)
private.Prompt.Item.tex = private.Prompt.Item:CreateTexture(nil, "OVERLAY")
private.Prompt.Item.tex:SetPoint("TOPLEFT", private.Prompt.Item, "TOPLEFT", 0, 0)
private.Prompt.Item.tex:SetPoint("BOTTOMRIGHT", private.Prompt.Item, "BOTTOMRIGHT", 0, 0)

private.Prompt.Text = private.Prompt:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
private.Prompt.Text:SetPoint("TOPLEFT", private.Prompt, "TOPLEFT", 52, -20)
private.Prompt.Text:SetPoint("TOPRIGHT", private.Prompt, "TOPRIGHT", -15, -20)
private.Prompt.Text:SetJustifyH("CENTER")

private.Prompt.Value = private.Prompt:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
private.Prompt.Value:SetPoint("TOP", private.Prompt.Text, "BOTTOM", -3)

private.Prompt.Yes = CreateFrame("Button", "AucAdvancedBuyPromptYes", private.Prompt, "OptionsButtonTemplate")
private.Prompt.Yes:SetText("Yes")
private.Prompt.Yes:SetPoint("BOTTOMRIGHT", private.Prompt, "BOTTOMRIGHT", -10, 10)
private.Prompt.Yes:SetScript("OnClick", private.PerformPurchase)

private.Prompt.No = CreateFrame("Button", "AucAdvancedBuyPromptNo", private.Prompt, "OptionsButtonTemplate")
private.Prompt.No:SetText("Cancel")
private.Prompt.No:SetPoint("BOTTOMRIGHT", private.Prompt.Yes, "BOTTOMLEFT", -20, 0)
private.Prompt.No:SetScript("OnClick", private.CancelPurchase)


AucAdvanced.RegisterRevision("$URL: http://dev.norganna.org/auctioneer/trunk/Auc-Advanced/CorePost.lua $", "$Rev: 2904 $")