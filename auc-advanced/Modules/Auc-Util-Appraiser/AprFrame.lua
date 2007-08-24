--[[
	Auctioneer Advanced - Appraisals and Auction Posting
	Revision: $Id$
	Version: <%version%>

	This is an addon for World of Warcraft that adds an appriasals dialog for
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
		You have an implicit licence to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]

local lib = AucAdvanced.Modules.Util.Appraiser
local private = lib.Private
local print = AucAdvanced.Print

local frame

local NUM_ITEMS = 12

function private.CreateFrames()
	if frame then return end

	frame = CreateFrame("Frame", nil, AuctionFrame)
	private.frame = frame

	frame.tip = CreateFrame("GameTooltip", "ApraiserTooltip", frame, "GameTooltipTemplate")
	frame.tip:SetAlpha(0)

	frame.list = {}
	frame.buffer = {}
	frame.cache = {}
	function frame.GenerateList()
		local n = #(frame.list)
		for i=1, n do
			frame.list[i] = nil
		end

		for bag=0,4 do
			for slot=1,GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag,slot)
				if link then
					frame.tip:SetOwner(frame, "ANCHOR_NONE")
					frame.tip:ClearLines()
					frame.tip:SetBagItem(bag, slot)
					local bind = ApraiserTooltipTextLeft2:GetText()
					frame.tip:Hide()

					if bind ~= ITEM_SOULBOUND
					and bind ~= ITEM_BIND_QUEST
					and bind ~= ITEM_BIND_ON_PICKUP
					and bind ~= ITEM_CONJURED
					then
						-- Item is auctionable
						local itype, id, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(link)
						if itype == "item" then
							local sig = ("%d:%d:%d"):format(id, suffix, factor)
							local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag,slot)
							if not itemCount or itemCount < 0 then itemCount = 1 end
							local found = false
							for i = 1, #(frame.list) do
								if frame.list[i] then
									if frame.list[i][1] == sig then
										frame.list[i][6] = frame.list[i][6] + itemCount
										found = true
										break
									end
								end
							end

							if not found then
								local i = #(frame.list) + 1
								if not frame.buffer[i] then
									frame.buffer[i] = {}
								end
								local name, _,_,_,_,_,_, stack = GetItemInfo(link)
								frame.buffer[i][1] = sig
								frame.buffer[i][2] = name
								frame.buffer[i][3] = texture
								frame.buffer[i][4] = quality
								frame.buffer[i][5] = stack
								frame.buffer[i][6] = itemCount
								frame.buffer[i][7] = link
								table.insert(frame.list, frame.buffer[i])
								if AucAdvanced.Modules.Util
								and AucAdvanced.Modules.Util.ScanData
								and AucAdvanced.Modules.Util.ScanData.GetDistribution
								and not frame.cache[sig] then
									local exact, suffix, base, colorDist = AucAdvanced.Modules.Util.ScanData.GetDistribution(link)
									frame.cache[sig] = { exact, suffix, base, {} }
									for k,v in pairs(colorDist.exact) do
										frame.cache[sig][4][k] = v
									end
								end
							end
						end
					end
				end
			end
		end

		table.sort(frame.list, private.sortItems)

		local pos = 0
		n = #frame.list
		if (n <= NUM_ITEMS) then
			frame.scroller:Hide()
			frame.scroller:SetValue(0)
		else
			frame.scroller:Show()
			frame.scroller:SetMinMaxValues(0, n-NUM_ITEMS)
			-- Find the current item
			for i = 1, n do
				if frame.list[i][1] == frame.selected then
					pos = i
					break
				end
			end
		end
		frame.scroller:SetValue(math.max(0, math.min(n-NUM_ITEMS+1, pos-(NUM_ITEMS/2))))
		frame:SetScroll()
	end

	function frame.SelectItem(obj, ...)
		local pos = math.floor(frame.scroller:GetValue())
		local id = obj.id
		local item = frame.list[pos + id]
		local sig = item[1]
		frame.selected = sig
		frame.SetScroll()

		frame.salebox.icon:SetTexture(item[3])
		local _,_,_, hex = GetItemQualityColor(item[4])
		frame.salebox.name:SetText(hex.."["..item[2].."]|r")
		frame.salebox.info:SetText("You have "..item[6].." available to auction")
		frame.salebox.info:SetTextColor(1,1,1, 0.8)
		frame.salebox.link = item[7]
		frame.salebox.sig = sig
		frame.salebox.stacksize = item[5]
		frame.salebox.count = item[6]

		frame.InitControls()
	end

	function frame.SetPriceFromModel(curModel)
		AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".model", curModel)
		
		if curModel == "default" then
			curModel = AucAdvanced.Settings.GetSetting("util.appraiser.model") or "market"
		end
		
		local newBuy, newBid
		if curModel == "fixed" then
			newBuy = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".fixed.buy")
			newBid = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".fixed.bid")
		elseif curModel == "market" then
			newBuy = AucAdvanced.API.GetMarketValue(frame.salebox.link)
		else
			newBuy = AucAdvanced.API.GetAlgorithmValue(curModel, frame.salebox.link)
		end
		p("Valuate", curModel, newBid, newBuy)

		if newBuy and not newBid then
			local markdown = math.floor(AucAdvanced.Settings.GetSetting("util.appraiser.bid.markdown") or 0)/100
			local subtract = AucAdvanced.Settings.GetSetting("util.appraiser.bid.subtract") or 0
			local deposit = AucAdvanced.Settings.GetSetting("util.appraiser.bid.deposit") or false
			if (deposit) then
				local sell = GetSellValue(frame.salebox.link)
				if (sell) then
					deposit = sell * (AucAdvanced.depositRate or 0.05)
				else
					deposit = 0
				end
			else
				deposit = 0
			end
			markdown = newBuy * markdown

			p("Markdown", newBuy, markdown, subtract, deposit)
			newBid = newBuy - markdown - subtract - deposit
		end

		p("Preround", newBid, newBuy)
		if curModel ~= "fixed" then
			-- Check rounding
			local roundBid = AucAdvanced.Settings.GetSetting("util.appraiser.round.bid") or false
			local roundBuy = AucAdvanced.Settings.GetSetting("util.appraiser.round.buy") or false

			if newBid and roundBid then
				newBid = private.roundValue(newBid)
			end
			if newBuy and roundBuy then
				newBuy = private.roundValue(newBuy)
			end
			if newBid and (not newBuy or newBid > newBuy) then
				newBuy = newBid
			end
		end
		p("Postround", newBid, newBuy)

		MoneyInputFrame_SetCopper(frame.salebox.bid, newBid or 0)
		MoneyInputFrame_SetCopper(frame.salebox.buy, newBuy or 0)
		frame.salebox.bid.modelvalue = newBid or 0
		frame.salebox.buy.modelvalue = newBuy or 0
	end

	function frame.InitControls()
		frame.salebox.config = true
		frame.UpdateControls()
		local curStack = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".stack") or frame.salebox.stacksize
		frame.salebox.stack:SetValue(curStack)
		frame.UpdateControls()
		local curNumber = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".number") or 0
		frame.salebox.number:SetValue(curNumber)

		local curModel = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".model") or "default"
		frame.salebox.model:SetValue(curModel)
		frame.SetPriceFromModel(curModel)
		
		frame.UpdateControls()
		frame.salebox.config = nil
	end

	function frame.UpdateControls()
		frame.salebox.stack:Show()
		frame.salebox.number:Show()
		frame.salebox.model:Show()
		frame.salebox.bid:Show()
		frame.salebox.buy:Show()

		if (frame.salebox.stacksize > 1) then
			frame.salebox.stack:SetMinMaxValues(1, frame.salebox.stacksize)
			local curSize = frame.salebox.stack:GetValue()
			frame.salebox.stack.label:SetText(("Stack size: %d"):format(curSize))
			frame.salebox.stack:SetAlpha(1)

			local count = frame.salebox.count
			local maxStax = math.floor(count / curSize)
			local fullPop = maxStax*curSize
			local remain = count - fullPop
			frame.salebox.number:SetMinMaxValues(-2, maxStax)
			local curNumber = frame.salebox.number:GetValue()
			if (curNumber == -2) then
				frame.salebox.number.label:SetText(("Number: %s"):format(("All full stacks (%d) = %d"):format(maxStax, fullPop)))
			elseif (curNumber == -1) then
				frame.salebox.number.label:SetText(("Number: %s"):format(("All stacks (%d) plus %d = %d"):format(maxStax, remain, count)))
			elseif (curNumber == 0) then
				frame.salebox.number.label:SetText(("Number: %s"):format("|cffff5010".."Do not auction!"))
			else
				frame.salebox.number.label:SetText(("Number: %s"):format(("%d stacks = %d"):format(curNumber, curNumber*curSize)))
			end
		else
			frame.salebox.stack:SetMinMaxValues(1,1)
			frame.salebox.stack:SetValue(1)
			frame.salebox.stack.label:SetText("Item is not stackable")
			frame.salebox.stack:SetAlpha(0.6)
		
			frame.salebox.number:SetMinMaxValues(-1, frame.salebox.count)
			local curNumber = frame.salebox.number:GetValue()
			if (curNumber == -1) then
				frame.salebox.number.label:SetText(("Number: %s"):format(("All items = %d"):format(frame.salebox.count)))
			elseif (curNumber == 0) then
				frame.salebox.number.label:SetText(("Number: %s"):format("|cffff5010".."Do not auction!"))
			else
				frame.salebox.number.label:SetText(("Number: %s"):format(("%d items"):format(curNumber)))
			end
		end
	end

	function frame.ChangeControls(obj, ...)
		if frame.salebox.config then return end
		frame.salebox.config = true

		frame.UpdateControls()
		local curStack = frame.salebox.stack:GetValue()
		local curNumber = frame.salebox.number:GetValue()
		AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".stack", curStack)
		AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".number", curNumber)

		if (obj and obj.element == "model") then
			local curModel = select(2, ...)
			frame.SetPriceFromModel(curModel)
		end

		if (frame.salebox.bid.modelvalue ~= curBid) then
			frame.salebox.model:SetValue("fixed")
		end
		frame.salebox.config = false
		p("Commit")
	end

	function frame.SetScroll(...)
		local pos = math.floor(frame.scroller:GetValue())
		for i = 1, NUM_ITEMS do
			local item = frame.list[pos+i]
			local button = frame.items[i]
			if item then
				button.icon:SetTexture(item[3])
				local _,_,_, hex = GetItemQualityColor(item[4])
				button.name:SetText(hex.."["..item[2].."]|r")
				button.size:SetText("x "..item[6])
				local info = ""	
				if frame.cache[item[1]] then
					local exact, suffix, base, dist = unpack(frame.cache[item[1]])
					info = "Counts: "..exact.." +"..suffix.." +"..base
					if (dist) then
						info = AucAdvanced.Modules.Util.ScanData.Colored(true, dist)
					end
				end
				button.info:SetText(info)
				button:Show()
				if (item[1] == frame.selected) then
					button.bg:SetAlpha(0.6)
				else
					button.bg:SetAlpha(0.2)
				end
			else
				button:Hide()
			end
		end
	end

	frame.DoTooltip = function ()
		local id = this.id
		local pos = math.floor(frame.scroller:GetValue())
		local item = frame.list[pos + id]
		if item then
			local name = item[2]
			local link = item[7]
			local count = item[6]
			GameTooltip:SetOwner(frame.itembox, "ANCHOR_NONE")
			GameTooltip:SetHyperlink(link)
			if (EnhTooltip) then
				EnhTooltip.TooltipCall(GameTooltip, name, link, -1, count)
			end
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("TOPLEFT", frame.itembox, "TOPRIGHT", 10, 0)
		end
	end
	frame.UndoTooltip = function ()
		GameTooltip:Hide()
	end
	
	frame:SetPoint("TOPLEFT", "AuctionFrame", "TOPLEFT", 10,-70)
	frame:SetPoint("BOTTOMRIGHT", "AuctionFrame", "BOTTOMRIGHT", 0,0)

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", frame, "TOPLEFT", 80, -16)
	title:SetText("Appraiser: Auction posting interface")

	frame.itembox = CreateFrame("Frame", nil, frame)
	frame.itembox:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	frame.itembox:SetBackdropColor(0, 0, 0, 0.8)
	frame.itembox:SetPoint("TOPLEFT", frame, "TOPLEFT", 13, -71)
	frame.itembox:SetWidth(250)
	frame.itembox:SetHeight(340)

	frame.items = {}
	for i=1, NUM_ITEMS do
		local item = CreateFrame("Button", nil, frame.itembox)
		frame.items[i] = item
		item:SetScript("OnClick", frame.SelectItem)
		item:SetScript("OnEnter", frame.DoTooltip)
		item:SetScript("OnLeave", frame.UndoTooltip)
		if (i == 1) then
			item:SetPoint("TOPLEFT", frame.itembox, "TOPLEFT", 5,-8 )
		else
			item:SetPoint("TOPLEFT", frame.items[i-1], "BOTTOMLEFT", 0, -1)
		end
		item:SetPoint("RIGHT", frame.itembox, "RIGHT", -23,0)
		item:SetHeight(26)

		item.id = i

		item.icon = item:CreateTexture(nil, "OVERLAY")
		item.icon:SetHeight(26)
		item.icon:SetWidth(26)
		item.icon:SetPoint("LEFT", item, "LEFT", 3,0)
		item.icon:SetTexture("Interface\\InventoryItems\\WoWUnknownItem01")

		item.name = item:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		item.name:SetJustifyH("LEFT")
		item.name:SetJustifyV("TOP")
		item.name:SetPoint("TOPLEFT", item.icon, "TOPRIGHT", 3,-1)
		item.name:SetPoint("RIGHT", item, "RIGHT", -5,0)
		item.name:SetText("[None]")

		item.size = item:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		item.size:SetJustifyH("RIGHT")
		item.size:SetJustifyV("BOTTOM")
		item.size:SetPoint("BOTTOMLEFT", item.icon, "BOTTOMRIGHT", 3,2)
		item.size:SetPoint("RIGHT", item, "RIGHT", -10,0)
		item.size:SetText("25x")

		item.info = item:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		item.info:SetJustifyH("LEFT")
		item.info:SetJustifyV("BOTTOM")
		item.info:SetPoint("BOTTOMLEFT", item.icon, "BOTTOMRIGHT", 3,2)
		item.info:SetPoint("RIGHT", item, "RIGHT", -10,0)
		item.info:SetText("11/23/55/112")

		item.bg = item:CreateTexture(nil, "ARTWORK")
		item.bg:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
		item.bg:SetPoint("TOPLEFT", item, "TOPLEFT", 0,0)
		item.bg:SetPoint("BOTTOMRIGHT", item, "BOTTOMRIGHT", 0,0)
		item.bg:SetAlpha(0.2)
		item.bg:SetBlendMode("ADD")

		item:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
	end
	local scroller = CreateFrame("Slider", "AucApraiserItemScroll", frame.itembox)
	scroller:SetPoint("TOPRIGHT", frame.itembox, "TOPRIGHT", -1,-3)
	scroller:SetPoint("BOTTOM", frame.itembox, "BOTTOM", 0,3)
	scroller:SetWidth(20)
	scroller:SetOrientation("VERTICAL")
	scroller:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	scroller:SetMinMaxValues(1, 30)
	scroller:SetValue(1)
	scroller:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	scroller:SetBackdropColor(0, 0, 0, 0.8)
	scroller:SetScript("OnValueChanged", frame.SetScroll)
	frame.scroller = scroller

	frame.itembox:EnableMouseWheel(true)
	frame.itembox:SetScript("OnMouseWheel", function(obj, dir) scroller:SetValue(scroller:GetValue() - dir) frame.SetScroll() end)

	frame.salebox = CreateFrame("Frame", nil, frame)
	frame.salebox:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	frame.salebox:SetBackdropColor(0, 0, 0.6, 0.8)
	frame.salebox:SetPoint("TOPLEFT", frame.itembox, "TOPRIGHT", 0,0)
	frame.salebox:SetPoint("RIGHT", frame, "RIGHT", -10,0)
	frame.salebox:SetHeight(150)

	frame.salebox.slot = frame.salebox:CreateTexture(nil, "BORDER")
	frame.salebox.slot:SetPoint("TOPLEFT", frame.salebox, "TOPLEFT", 10, -10)
	frame.salebox.slot:SetWidth(40)
	frame.salebox.slot:SetHeight(40)
	frame.salebox.slot:SetTexCoord(0.15, 0.85, 0.15, 0.85)
	frame.salebox.slot:SetTexture("Interface\\Buttons\\UI-EmptySlot")

	frame.salebox.icon = frame.salebox:CreateTexture(nil, "ARTWORK")
	frame.salebox.icon:SetPoint("TOPLEFT", frame.salebox.slot, "TOPLEFT", 3, -3)
	frame.salebox.icon:SetWidth(32)
	frame.salebox.icon:SetHeight(32)
	frame.salebox.icon:SetTexture("Interface\\Icons\\Spell_unused2")

	frame.salebox.name = frame.salebox:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	frame.salebox.name:SetPoint("TOPLEFT", frame.salebox.slot, "TOPRIGHT", 5,-2)
	frame.salebox.name:SetHeight(20)
	frame.salebox.name:SetJustifyH("LEFT")
	frame.salebox.name:SetJustifyV("TOP")
	frame.salebox.name:SetText("No item selected")
	frame.salebox.name:SetTextColor(0.5, 0.5, 0.7)

	frame.salebox.info = frame.salebox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.salebox.info:SetPoint("BOTTOMLEFT", frame.salebox.slot, "BOTTOMRIGHT", 5,7)
	frame.salebox.info:SetHeight(20)
	frame.salebox.info:SetJustifyH("LEFT")
	frame.salebox.info:SetJustifyV("BOTTOM")
	frame.salebox.info:SetText("Select an item to the left to begin auctioning...")
	frame.salebox.info:SetTextColor(0.5, 0.5, 0.7)

	frame.salebox.stack = CreateFrame("Slider", "AppraiserSaleboxStack", frame.salebox, "OptionsSliderTemplate")
	frame.salebox.stack:SetPoint("TOPLEFT", frame.salebox.slot, "BOTTOMLEFT", 0, -5)
	frame.salebox.stack:SetHitRectInsets(0,0,0,0)
	frame.salebox.stack:SetMinMaxValues(1,20)
	frame.salebox.stack:SetValueStep(1)
	frame.salebox.stack:SetValue(20)
	frame.salebox.stack:SetWidth(250)
	frame.salebox.stack:SetScript("OnValueChanged", frame.ChangeControls)
	frame.salebox.stack.element = "stack"
	frame.salebox.stack:Hide()
	AppraiserSaleboxStackLow:SetText("")
	AppraiserSaleboxStackHigh:SetText("")

	frame.salebox.stack.label = frame.salebox.stack:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.stack.label:SetPoint("LEFT", frame.salebox.stack, "RIGHT", 3,2)
	frame.salebox.stack.label:SetJustifyH("LEFT")
	frame.salebox.stack.label:SetJustifyV("CENTER")

	frame.salebox.number = CreateFrame("Slider", "AppraiserSaleboxNumber", frame.salebox, "OptionsSliderTemplate")
	frame.salebox.number:SetPoint("TOPLEFT", frame.salebox.stack, "BOTTOMLEFT", 0,0)
	frame.salebox.number:SetHitRectInsets(0,0,0,0)
	frame.salebox.number:SetMinMaxValues(-1,20)
	frame.salebox.number:SetValueStep(1)
	frame.salebox.number:SetValue(-1)
	frame.salebox.number:SetWidth(250)
	frame.salebox.number:SetScript("OnValueChanged", frame.ChangeControls)
	frame.salebox.number.element = "number"
	frame.salebox.number:Hide()
	AppraiserSaleboxNumberLow:SetText("")
	AppraiserSaleboxNumberHigh:SetText("")

	frame.salebox.number.label = frame.salebox.number:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.number.label:SetPoint("LEFT", frame.salebox.number, "RIGHT", 3,2)
	frame.salebox.number.label:SetJustifyH("LEFT")
	frame.salebox.number.label:SetJustifyV("CENTER")

	frame.salebox.model = SelectBox.Create("AppraiserSaleboxModel", frame.salebox, 140, frame.ChangeControls, private.GetExtraPriceModels, "default")
	frame.salebox.model:SetPoint("TOPLEFT", frame.salebox.number, "BOTTOMLEFT", 0,-16)

	frame.salebox.model.label = frame.salebox.model:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.model.label:SetPoint("BOTTOMLEFT", frame.salebox.model, "TOPLEFT", 0,0)
	frame.salebox.model.label:SetText("Pricing model to use")
	frame.salebox.model.element = "model"
	frame.salebox.model:Hide()

	frame.salebox.bid = CreateFrame("Frame", "AppraiserSaleboxBid", frame.salebox, "MoneyInputFrameTemplate")
	frame.salebox.bid:SetPoint("TOP", frame.salebox.number, "BOTTOM", 0,-10)
	frame.salebox.bid:SetPoint("LEFT", frame.salebox.model, "RIGHT", 130,0)
	MoneyInputFrame_SetOnvalueChangedFunc(frame.salebox.bid, frame.ChangeControls)
	frame.salebox.bid.element = "bid"
	frame.salebox.bid:Hide()

	frame.salebox.bid.label = frame.salebox.bid:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.bid.label:SetPoint("LEFT", frame.salebox.model, "RIGHT", 5,0)
	frame.salebox.bid.label:SetPoint("TOPRIGHT", frame.salebox.bid, "TOPLEFT", 0,0)
	frame.salebox.bid.label:SetPoint("BOTTOMRIGHT", frame.salebox.bid, "BOTTOMLEFT", 0,0)
	frame.salebox.bid.label:SetText("Bid price/item:")

	frame.salebox.buy = CreateFrame("Frame", "AppraiserSaleboxBuy", frame.salebox, "MoneyInputFrameTemplate")
	frame.salebox.buy:SetPoint("TOPLEFT", frame.salebox.bid, "BOTTOMLEFT", 0,0)
	MoneyInputFrame_SetOnvalueChangedFunc(frame.salebox.buy, frame.ChangeControls)
	frame.salebox.buy.element = "buy"
	frame.salebox.buy:Hide()

	frame.salebox.buy.label = frame.salebox.buy:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.buy.label:SetPoint("LEFT", frame.salebox.model, "RIGHT", 5,0)
	frame.salebox.buy.label:SetPoint("TOPRIGHT", frame.salebox.buy, "TOPLEFT", 0,0)
	frame.salebox.buy.label:SetPoint("BOTTOMRIGHT", frame.salebox.buy, "BOTTOMLEFT", 0,0)
	frame.salebox.buy.label:SetText("Buy price/item:")

	frame.ScanTab = CreateFrame("Button", "AuctionFrameTabUtilAppraiser", AuctionFrame, "AuctionTabTemplate")
	frame.ScanTab:SetText("Appraiser")
	frame.ScanTab:Show()
	PanelTemplates_DeselectTab(frame.ScanTab)
	AucAdvanced.AddTab(frame.ScanTab, frame)

	function frame.ScanTab.OnClick(_, _, index)
		if not index then index = this:GetID() end
		local tab = getglobal("AuctionFrameTab"..index)
		if (tab and tab:GetName() == "AuctionFrameTabUtilAppraiser") then
			AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopLeft")
			AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-Top")
			AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopRight")
			AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotLeft")
			AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-Bot")
			AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight")
			AuctionFrameMoneyFrame:Hide()
			frame:Show()
			AucAdvanced.Scan.GetImage()
			frame.GenerateList()
		else
			AuctionFrameMoneyFrame:Show()
			frame:Hide()
		end
	end
	hooksecurefunc("AuctionFrameTab_OnClick", frame.ScanTab.OnClick)
end



