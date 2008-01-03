--[[
	Auctioneer Advanced - Appraisals and Auction Posting
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

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
local Const = AucAdvanced.Const
local recycle = AucAdvanced.Recycle
local acquire = AucAdvanced.Acquire
local clone = AucAdvanced.Clone

local frame

local NUM_ITEMS = 12

function private.CreateFrames()
	if frame then return end

	local SelectBox = LibStub:GetLibrary("SelectBox")
	local ScrollSheet = LibStub:GetLibrary("ScrollSheet")

	frame = CreateFrame("Frame", nil, AuctionFrame)
	private.frame = frame
	local DiffFromModel = 0
	local MatchString = ""
	frame.list = {}
	frame.buffer = {}
	frame.cache = {}
	
	function frame.GenerateList(repos)
		local n = #(frame.list)
		for i=1, n do
			frame.list[i] = nil
		end

		for bag=0,4 do
			for slot=1,GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag,slot)
				if link then
					local isDirect = false
					if frame.direct and frame.direct == link then
						isDirect = true
					end

					if AucAdvanced.Post.IsAuctionable(bag, slot) or isDirect then
						local itype, id, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(link)
						if itype == "item" then
							local sig
							if enchant ~= 0 then
								sig = ("%d:%d:%d:%d"):format(id, suffix, factor, enchant)
							elseif factor ~= 0 then
								sig = ("%d:%d:%d"):format(id, suffix, factor)
							elseif suffix ~= 0 then
								sig = ("%d:%d"):format(id, suffix)
							else
								sig = tostring(id)
							end

							local texture, itemCount, locked, special, readable = GetContainerItemInfo(bag,slot)
							if special == -1 then special = true else special = false end
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
								local ignore = 0
								if (AucAdvanced.Settings.GetSetting('util.appraiser.item.'..sig..".ignore")) then
									ignore = 1
								end

								if frame.showHidden or ignore == 0 or isDirect then
									local name, _,rarity,_,_,_,_, stack = GetItemInfo(link)
									frame.buffer[i][0] = ignore
									frame.buffer[i][1] = sig
									frame.buffer[i][2] = name
									frame.buffer[i][3] = texture
									frame.buffer[i][4] = rarity
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
		end

		table.sort(frame.list, private.sortItems)

		local pos = 0
		n = #frame.list
		if (n <= NUM_ITEMS) then
			frame.scroller:Hide()
			frame.scroller:SetMinMaxValues(0, 0)
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
		if (repos) then
			frame.scroller:SetValue(math.max(0, math.min(n-NUM_ITEMS+1, pos-(NUM_ITEMS/2))))
		end
		frame:SetScroll()

		if frame.itembox.sig then
			frame.UpdateControls()
		end
		return pos
	end

	private.empty = {}
	function frame.SelectItem(obj, button)
		if not obj.id then obj = obj:GetParent() end
		local pos = math.floor(frame.scroller:GetValue())
		local id = obj.id
		pos = math.min(pos + id, #frame.list)
		local item = frame.list[pos]
		local sig = nil
		if item then
			sig = item[1] or nil
		end
		if button and sig == frame.selected then
			sig = nil
			pos = nil
		end
		frame.selected = sig
		frame.selectedPos = pos
		frame.selectedObj = obj
		frame.SetScroll()

		frame.salebox.sig = sig
		if sig then
			local _,_,_, hex = GetItemQualityColor(item[4])
			frame.salebox.icon:SetNormalTexture(item[3])
			frame.salebox.name:SetText(hex.."["..item[2].."]|r")
			frame.salebox.info:SetText("You have "..item[6].." available to auction")
			frame.salebox.info:SetTextColor(1,1,1, 0.8)
			frame.salebox.link = item[7]
			frame.salebox.stacksize = item[5]
			frame.salebox.count = item[6]

			frame.UpdateImage()
			frame.InitControls()
			--Also pass this search to BeanCounter's frame
			if BeanCounter and BeanCounter.externalSearch then
				BeanCounter.externalSearch(item[1], nil, nil, 50)
			end			
		else
			frame.salebox.name:SetText("No item selected")
			frame.salebox.name:SetTextColor(0.5, 0.5, 0.7)
			if not AucAdvanced.Settings.GetSetting("util.appraiser.classic") then
				frame.salebox.info:SetText("Select an item to the left to begin auctioning...")
			else
				frame.salebox.info:SetText("Select an item to begin auctioning...")
			end
			frame.salebox.info:SetTextColor(0.5, 0.5, 0.7)
			frame.imageview.sheet:SetData(private.empty)
			frame.imageviewclassic.sheet:SetData(private.empty)
			frame.UpdateControls()
		end

		if not (frame.direct and item and item[7] and frame.direct == item[7]) then
			frame.direct = nil
			frame.GenerateList()
		end
	end

	function frame.Reselect(posted)
		local reselect = (frame.selected == posted[1])
		local reselectenabled = AucAdvanced.Settings.GetSetting("util.appraiser.reselect")
		frame.GenerateList()
		if reselect then
			if reselectenabled then
				frame.SelectItem(frame.selectedObj)
			else
				frame.selected = nil
				frame.selectedPos = nil
				frame.salebox.sig = nil
				frame.salebox.name:SetText("No item selected")
				frame.salebox.name:SetTextColor(0.5, 0.5, 0.7)
				if not AucAdvanced.Settings.GetSetting("util.appraiser.classic") then
					frame.salebox.info:SetText("Select an item to the left to begin auctioning...")
				else
					frame.salebox.info:SetText("Select an item to begin auctioning...")
				end
				frame.salebox.info:SetTextColor(0.5, 0.5, 0.7)
				frame.imageview.sheet:SetData(private.empty)
				frame.imageviewclassic.sheet:SetData(private.empty)
				frame.UpdateControls()
			end
		end
	end

	function frame.DirectSelect(link)
		if frame.direct == link then return end
		frame.direct = link
		local sig
		local itype, id, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(link)
		if enchant ~= 0 then
			sig = ("%d:%d:%d:%d"):format(id, suffix, factor, enchant)
		elseif factor ~= 0 then
			sig = ("%d:%d:%d"):format(id, suffix, factor)
		elseif suffix ~= 0 then
			sig = ("%d:%d"):format(id, suffix)
		else
			sig = tostring(id)
		end
		frame.GenerateList()
		frame.GetItemByLink(link)
		frame.GenerateList(true)
	end

	function frame.UpdateImage()
		if not frame.salebox.sig then return end

		local itemId, suffix, factor = strsplit(":", frame.salebox.sig)
		itemId = tonumber(itemId)
		suffix = tonumber(suffix) or 0
		factor = tonumber(factor) or 0

		local results = AucAdvanced.API.QueryImage({
			itemId = itemId,
			suffix = suffix,
			factor = factor,
		})
		local itemkey = string.join(":", "item", itemId, "0", "0", "0", "0", "0", suffix, factor)
		
		local data = acquire()
		local style = acquire()
		for i = 1, #results do
			local result = results[i]
			local tLeft = result[Const.TLEFT]
			if (tLeft == 1) then tLeft = "30m"
			elseif (tLeft == 2) then tLeft = "2h"
			elseif (tLeft == 3) then tLeft = "12h"
			elseif (tLeft == 4) then tLeft = "48h"
			end
			local count = result[Const.COUNT]
			data[i] = acquire (
				result[Const.NAME],
				result[Const.SELLER],
				tLeft,
				count,
				math.floor(0.5+result[Const.MINBID]/count),
				math.floor(0.5+result[Const.CURBID]/count),
				math.floor(0.5+result[Const.BUYOUT]/count),
				result[Const.MINBID],
				result[Const.CURBID],
				result[Const.BUYOUT]
			)
			local color = frame.SetPriceColor(itemkey, count, result[Const.CURBID], result[Const.BUYOUT])
			if color then
				style[i] = acquire()
				style[i][1] = acquire()
				style[i][1].textColor = color
			end
		end
		frame.SetPriceFromModel(curModel)
		frame.refresh:Enable()
		frame.switchUI:Enable()
		frame.imageview.sheet:SetData(data, style)
		frame.imageviewclassic.sheet:SetData(data, style)
		recycle(data)
		recycle(style)
		--reset scroll position if new items list is too short to show
		if  not frame.imageview.sheet.rows[1][1]:IsShown() then
			frame.imageview.sheet.panel:ScrollToCoords(0,0)
		end
		
	end

	function frame.SetPriceColor(itemID, count, requiredBid, buyoutPrice)
		if AucAdvanced.Settings.GetSetting('util.appraiser.color') and AucAdvanced.Modules.Util.PriceLevel then
		local _, link, _, _, _, _, _, _, _, _ = GetItemInfo(itemID)
		local _, _, r,g,b = AucAdvanced.Modules.Util.PriceLevel.CalcLevel(link, count, requiredBid, buyoutPrice)
			if r and g and b then
				return acquire(r,g,b)
			else
				return nil
			end
		end
		return nil
	end
		
	function frame.SetPriceFromModel(curModel)
		if not frame.salebox.sig then return end
		if not curModel then
			curModel = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".model") or "default"
		else
			AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".model", curModel)
		end
		frame.salebox.warn:SetText("")
		if curModel == "default" then
			curModel = AucAdvanced.Settings.GetSetting("util.appraiser.model") or "market"
			if ((curModel == "market") and ((not AucAdvanced.API.GetMarketValue(frame.salebox.link)) or (AucAdvanced.API.GetMarketValue(frame.salebox.link) <= 0))) or
			   ((not (curModel == "fixed")) and (not (curModel == "market")) and ((not AucAdvanced.API.GetAlgorithmValue(curModel, frame.salebox.link)) or (AucAdvanced.API.GetAlgorithmValue(curModel, frame.salebox.link) <= 0))) then
				curModel = AucAdvanced.Settings.GetSetting("util.appraiser.altModel")
			end
			frame.salebox.model:SetText("Default ("..curModel..")")
		end

		local newBuy, newBid
		local match = frame.salebox.matcher:GetChecked()
		if (frame.salebox.matcher:IsEnabled() == 0) then
			match = false
		end
		if curModel == "fixed" then
			newBuy = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".fixed.buy")
			newBid = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".fixed.bid")
		elseif curModel == "market" then
			if match then
				local _
				newBuy, _, _, DiffFromModel, MatchString = AucAdvanced.API.GetBestMatch(frame.salebox.link, curModel)
			else
				newBuy = AucAdvanced.API.GetMarketValue(frame.salebox.link)
			end
		else
			if match then
				local _
				newBuy, _, _, DiffFromModel, MatchString = AucAdvanced.API.GetBestMatch(frame.salebox.link, curModel)
			else
				newBuy = AucAdvanced.API.GetAlgorithmValue(curModel, frame.salebox.link)
			end
		end

		if curModel ~= "fixed" then
			if not newBuy or newBuy <= 0 then
				frame.salebox.warn:SetText(("No %s price available!"):format(curModel))
				MoneyInputFrame_ResetMoney(frame.salebox.bid)
				MoneyInputFrame_ResetMoney(frame.salebox.buy)
				frame.salebox.bid.modelvalue = 0
				frame.salebox.buy.modelvalue = 0
				return
			end

			if newBuy and not newBid then
				local markdown = math.floor(AucAdvanced.Settings.GetSetting("util.appraiser.bid.markdown") or 0)/100
				local subtract = AucAdvanced.Settings.GetSetting("util.appraiser.bid.subtract") or 0
				local deposit = AucAdvanced.Settings.GetSetting("util.appraiser.bid.deposit") or false
				if (deposit) then
					local rate
					deposit, rate = AucAdvanced.Post.GetDepositAmount(frame.salebox.sig)
					if not rate then rate = AucAdvanced.depositRate or 0.05 end
				else deposit = 0 end

				-- Scale up for duration > 12 hours
				if deposit > 0 then
					local curDurationIdx = frame.salebox.duration:GetValue()
					local duration = private.durations[curDurationIdx][1]
					deposit = deposit * duration/720
				end

				markdown = newBuy * markdown

				newBid = math.max(newBuy - markdown - subtract - deposit, 1)
			end

			if newBid and (not newBuy or newBid > newBuy) then
				newBuy = newBid
			end
		end

		newBid = math.floor((newBid or 0) + 0.5)
		newBuy = math.floor((newBuy or 0) + 0.5)

		MoneyInputFrame_ResetMoney(frame.salebox.bid)
		MoneyInputFrame_ResetMoney(frame.salebox.buy)
		MoneyInputFrame_SetCopper(frame.salebox.bid, newBid)
		MoneyInputFrame_SetCopper(frame.salebox.buy, newBuy)
		frame.salebox.bid.modelvalue = newBid
		frame.salebox.buy.modelvalue = newBuy
	end

	function frame.InitControls()
		if frame.salebox.config then return end
		frame.salebox.config = true
		frame.UpdateControls()

		local curDuration = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".duration") or
			AucAdvanced.Settings.GetSetting('util.appraiser.duration') or 2880

		for i=1, #private.durations do
			if (curDuration == private.durations[i][1]) then
				frame.salebox.duration:SetValue(i)
				break
			end
		end

		local defStack = AucAdvanced.Settings.GetSetting("util.appraiser.stack")
		if defStack == "max" then
			defStack = frame.salebox.stacksize
		elseif (not (tonumber(defStack))) then
			defStack = frame.salebox.stacksize
			AucAdvanced.Settings.SetSetting("util.appraiser.stack", "max")
		end
		defStack = tonumber(defStack)
		if defStack > frame.salebox.stacksize then
			defStack = frame.salebox.stacksize
		end
		local curStack = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".stack") or defStack
		frame.salebox.stack:SetValue(curStack)
		frame.UpdateControls()
		
		local defStack = AucAdvanced.Settings.GetSetting("util.appraiser.number")
		if defStack == "maxplus" then
			defStack = -1
		elseif defStack == "maxfull" then
			defStack = -2
		elseif (not (tonumber(defStack))) then
			defStack = -1
			AucAdvanced.Settings.SetSetting("util.appraiser.number", "maxplus")
		else
			defStack = tonumber(defStack)
		end
		local curNumber = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".number") or defStack
		frame.salebox.number:SetAdjustedValue(curNumber)
		
		local defMatch = AucAdvanced.Settings.GetSetting("util.appraiser.match")
		local curMatch = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".match")
		if curMatch == nil then
			curMatch = defMatch
		end
		if curMatch == "on" then
			frame.salebox.matcher:SetChecked(true)
		elseif curMatch == "off" then
			frame.salebox.matcher:SetChecked(false)
		else
			frame.salebox.matcher:SetChecked(curMatch)
		end

		local curBulk = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".bulk") or false
		frame.salebox.bulk:SetChecked(curBulk)


		local curModel = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".model") or "default"
		frame.salebox.model.value = curModel
		frame.salebox.model:UpdateValue()
		frame.SetPriceFromModel(curModel)

		frame.UpdateControls()
		frame.salebox.config = nil
	end

	function frame.UpdateControls()
		if not frame.salebox.sig then
			frame.salebox.icon:SetAlpha(0)
			frame.salebox.stack:Hide()
			frame.salebox.number:Hide()
			frame.salebox.stackentry:Hide()
			frame.salebox.numberentry:Hide()
			frame.salebox.model:Hide()
			frame.salebox.matcher:Hide()
			frame.salebox.bid:Hide()
			frame.salebox.buy:Hide()
			frame.salebox.duration:Hide()
			frame.salebox.warn:SetText("")
			frame.manifest:Hide()
			frame.toggleManifest:Disable()
			frame.age:SetText("")
			frame.refresh:Disable()
			frame.go:Disable()
			frame.salebox.depositcost:SetText("")
			frame.salebox.totalbid:SetText("")
			frame.salebox.totalbuyout:SetText("")
			frame.salebox.ignore:Hide()
			frame.salebox.bulk:Hide()
			return
		end
		frame.salebox.icon:SetAlpha(1)
		frame.salebox.matcher:Show()
		frame.salebox.bid:Show()
		frame.salebox.model:Show()
		frame.salebox.buy:Show()
		frame.salebox.duration:Show()
		frame.manifest.lines:Clear()
		frame.manifest:SetFrameLevel(AuctionFrame:GetFrameLevel())
		if frame.itembox:IsShown() then
			frame.salebox.ignore:Show()
			frame.salebox.bulk:Show()
			frame.salebox.number:Show()
			frame.salebox.stack:Show()
			frame.salebox.stackentry:Show()
			frame.salebox.numberentry:Show()
			frame.toggleManifest:Enable()
			if frame.toggleManifest:GetText() == "Close Sidebar" then
				frame.manifest:Show()
			end
		else
			frame.salebox.stackentry:Show()
			frame.salebox.stacksoflabel:Show()
			frame.salebox.numberentry:Show()
			frame.salebox.depositcost:Show()
			frame.salebox.totalbid:Show()
			frame.salebox.totalbuyout:Show()
		end
		frame.refresh:Enable()
		frame.switchUI:Enable()

		local matchers = AucAdvanced.Settings.GetSetting("matcherlist")
		if not matchers or #matchers == 0 then
			frame.salebox.matcher:Disable()
			frame.salebox.matcher.label:SetTextColor(.5, .5, .5)
		else
			frame.salebox.matcher:Enable()
			frame.salebox.matcher.label:SetTextColor(1, 1, 1)
		end

		local itemId, suffix, factor = strsplit(":", frame.salebox.sig)
		itemId = tonumber(itemId)
		suffix = tonumber(suffix) or 0
		factor = tonumber(factor) or 0

		local itemKey = string.join(":", "item", itemId, "0", "0", "0", "0", "0", suffix, factor)
		itemId = tonumber(itemId)
		suffix = tonumber(suffix) or 0
		factor = tonumber(factor) or 0
		
		local results = AucAdvanced.API.QueryImage({
			itemId = itemId,
			suffix = suffix,
			factor = factor,
		})
		
		if results[1] then 
			local seen = results[1][Const.TIME]
			if (time() - seen) < 60 then
				frame.age:SetText("Data is < 1 minute old")
			elseif ((time() - seen) / 3600) <= 48 then
				frame.age:SetText("Data is "..SecondsToTime(time() - seen, true).." old")
			else
				frame.age:SetText("Data is > 48 hours old")
			end
		else
			frame.age:SetText("No data for "..string.sub(frame.salebox.name:GetText(), 12, -4))
		end

		local curDurationIdx = frame.salebox.duration:GetValue() or 3
		local curDurationMins = private.durations[curDurationIdx][1]
		local curDurationText = private.durations[curDurationIdx][2]
		frame.salebox.duration.label:SetText(("Duration: %s"):format(curDurationText))

		local curIgnore = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".ignore") or false
		frame.salebox.icon:GetNormalTexture():SetDesaturated(curIgnore)
		frame.salebox.ignore:SetChecked(curIgnore)

		local curBid = frame.salebox.bid.modelvalue or 0
		local curBuy = frame.salebox.buy.modelvalue or 0

		local sig = frame.salebox.sig
		local totalBid, totalBuy, totalDeposit = 0,0,0
		local bidVal, buyVal, depositVal

		local color, r,g,b, a
		local colored = AucAdvanced.Settings.GetSetting('util.appraiser.manifest.color')
		local tinted = AucAdvanced.Settings.GetSetting('util.appraiser.tint.color')
		r,g,b, a = 0,0,0, 0
		if tinted then
			color = frame.SetPriceColor(itemKey, 1, curBid, curBid)
			if color then
				r,g,b = unpack(color)
				a = 0.4
				recycle(color)
			end
		end
		AppraiserSaleboxBidGold:SetBackdropColor(r,g,b, a)
		AppraiserSaleboxBidSilver:SetBackdropColor(r,g,b, a)
		AppraiserSaleboxBidCopper:SetBackdropColor(r,g,b, a)
		if tinted then
			color = frame.SetPriceColor(itemKey, 1, curBuy, curBuy)
			if color then
				r,g,b = unpack(color)
				a = 0.4
				recycle(color)
			end
		end
		AppraiserSaleboxBuyGold:SetBackdropColor(r,g,b, a)
		AppraiserSaleboxBuySilver:SetBackdropColor(r,g,b, a)
		AppraiserSaleboxBuyCopper:SetBackdropColor(r,g,b, a)

		local depositMult = curDurationMins / 720
		local curNumber = frame.salebox.number:GetAdjustedValue()

		if (frame.salebox.stacksize > 1) then
			local count = frame.salebox.count

			frame.salebox.stack:SetMinMaxValues(1, frame.salebox.stacksize)
			local curSize = frame.salebox.stack:GetValue()
			local extra = ""
			if (curSize > count) then
				extra = "  |cffffaa40" .. "(Stack > Available)"
			end
			frame.salebox.stack.label:SetText(("Stack size: %d"):format(curSize)..extra)
			frame.salebox.stack:SetAlpha(1)
			frame.salebox.stackentry:SetNumber(curSize)

			local maxStax = math.floor(count / curSize)
			local fullPop = maxStax*curSize
			local remain = count - fullPop
			frame.salebox.number:SetAdjustedRange(maxStax, -2, -1)
			if (curNumber >= -2 and curNumber < 0) then
				if (curNumber == -2) then
					frame.salebox.number.label:SetText(("Number: %s"):format(("All full stacks (%d) = %d"):format(maxStax, fullPop)))
					frame.salebox.totalsize:SetText("("..(fullPop)..")")
					frame.salebox.numberentry:SetText("Full")
				else
					frame.salebox.number.label:SetText(("Number: %s"):format(("All stacks (%d) plus %d = %d"):format(maxStax, remain, count)))
					frame.salebox.totalsize:SetText("("..(count)..")")
					frame.salebox.numberentry:SetText("All")
				end
				--frame.salebox.numberentry:SetNumber(maxStax)
				if (maxStax > 0) then
					frame.manifest.lines:Add(("%d lots of %dx stacks:"):format(maxStax, curSize))
					bidVal = lib.RoundBid(curBid * curSize)
					buyVal = lib.RoundBuy(curBuy * curSize)
					depositVal = AucAdvanced.Post.GetDepositAmount(sig, curSize) * depositMult
					
					if colored then
						color = frame.SetPriceColor(itemKey, curSize, bidVal, bidVal)
						if color then
							r,g,b = unpack(color)
							recycle(color)
						end
					end
					frame.manifest.lines:Add(("  Bid for %dx"):format(curSize), bidVal, r,g,b)
					if colored then
						color = frame.SetPriceColor(itemKey, curSize, buyVal, buyVal)
						if color then
							r,g,b = unpack(color)
							recycle(color)
						end
					end
					frame.manifest.lines:Add(("  Buyout for %dx"):format(curSize), buyVal, r,g,b)
					frame.manifest.lines:Add(("  Deposit for %dx"):format(curSize), depositVal)

					totalBid = totalBid + (bidVal * maxStax)
					totalBuy = totalBuy + (buyVal * maxStax)
					totalDeposit = totalDeposit + (depositVal * maxStax)
				end
				if (curNumber == -1 and remain > 0) then
					bidVal = lib.RoundBid(curBid * remain)
					buyVal = lib.RoundBuy(curBuy * remain)
					depositVal = AucAdvanced.Post.GetDepositAmount(sig, remain) * depositMult
					frame.manifest.lines:Add(("%d lots of %dx stacks:"):format(1, remain))
					if colored then
						color = frame.SetPriceColor(itemKey, remain, bidVal, bidVal)
						if color then
							r,g,b = unpack(color)
							recycle(color)
						end
					end
					frame.manifest.lines:Add(("  Bid for %dx"):format(remain), bidVal, r,g,b)
					if colored then
						color = frame.SetPriceColor(itemKey, remain, buyVal, buyVal)
						if color then
							r,g,b = unpack(color)
							recycle(color)
						end
					end
					frame.manifest.lines:Add(("  Buyout for %dx"):format(remain), buyVal, r,g,b)
					frame.manifest.lines:Add(("  Deposit for %dx"):format(remain), depositVal)

					totalBid = totalBid + bidVal
					totalBuy = totalBuy + buyVal
					totalDeposit = totalDeposit + depositVal
				end
			else
				frame.salebox.number.label:SetText(("Number: %s"):format(("%d stacks = %d"):format(curNumber, curNumber*curSize)))
				frame.salebox.totalsize:SetText("("..(curNumber*curSize)..")")
				frame.salebox.numberentry:SetNumber(curNumber)
				frame.manifest.lines:Add(("%d lots of %dx stacks:"):format(curNumber, curSize))
				bidVal = lib.RoundBid(curBid * curSize)
				buyVal = lib.RoundBuy(curBuy * curSize)
				depositVal = AucAdvanced.Post.GetDepositAmount(sig, curSize) * depositMult
				if colored then
					color = frame.SetPriceColor(itemKey, curSize, bidVal, bidVal)
					if color then
						r,g,b = unpack(color)
						recycle(color)
					end
				end
				frame.manifest.lines:Add(("  Bid for %dx"):format(curSize), bidVal, r,g,b)
				if colored then
					color = frame.SetPriceColor(itemKey, curSize, buyVal, buyVal)
					if color then
						r,g,b = unpack(color)
						recycle(color)
					end
				end
				frame.manifest.lines:Add(("  Buyout for %dx"):format(curSize), buyVal, r,g,b)
				frame.manifest.lines:Add(("  Deposit for %dx"):format(curSize), depositVal)

				totalBid = totalBid + (bidVal * curNumber)
				totalBuy = totalBuy + (buyVal * curNumber)
				totalDeposit = totalDeposit + (depositVal * curNumber)
			end

		else
			frame.salebox.stack:SetMinMaxValues(1,1)
			frame.salebox.stack:SetValue(1)
			frame.salebox.stack.label:SetText("Item is not stackable")
			frame.salebox.stackentry:SetNumber(1)
			frame.salebox.stack:SetAlpha(0.6)

			frame.salebox.number:SetAdjustedRange(frame.salebox.count, -1)
			if (curNumber == -1) then
				curNumber = frame.salebox.count
				frame.salebox.number.label:SetText(("Number: %s"):format(("All items = %d"):format(curNumber)))
				frame.salebox.totalsize:SetText("("..(curNumber)..")")
				frame.salebox.numberentry:SetText("All")
			else
				frame.salebox.number.label:SetText(("Number: %s"):format(("%d items"):format(curNumber)))
				frame.salebox.totalsize:SetText("("..(curNumber)..")")
				frame.salebox.numberentry:SetNumber(curNumber)
			end
			
			if curNumber > 0 then
				frame.manifest.lines:Add(("%d items"):format(curNumber))
				bidVal = lib.RoundBid(curBid)
				buyVal = lib.RoundBuy(curBuy)
				local baseDeposit = AucAdvanced.Post.GetDepositAmount(sig) or 0 
				depositVal = baseDeposit * depositMult
				if colored then
					color = frame.SetPriceColor(itemKey, 1, bidVal, bidVal)
					if color then
						r,g,b = unpack(color)
						recycle(color)
					end
				end
				frame.manifest.lines:Add(("  Bid /item"), bidVal, r,g,b)
				if colored then
					color = frame.SetPriceColor(itemKey, 1, buyVal, buyVal)
					if color then
						r,g,b = unpack(color)
						recycle(color)
					end
				end
				frame.manifest.lines:Add(("  Buyout /item"), buyVal, r,g,b)
				frame.manifest.lines:Add(("  Deposit /item"), depositVal)
				totalBid = totalBid + (bidVal * curNumber)
				totalBuy = totalBuy + (buyVal * curNumber)
				totalDeposit = totalDeposit + (depositVal * curNumber)
			end
		end
		frame.manifest.lines:Add(("Totals:"))
		frame.manifest.lines:Add(("  Total Bid"), totalBid)
		frame.manifest.lines:Add(("  Total Buyout"), totalBuy)
		frame.manifest.lines:Add(("  Total Deposit"), totalDeposit)
		frame.salebox.depositcost:SetText("Deposit:      "..EnhTooltip.GetTextGSC(totalDeposit, true))
		frame.salebox.totalbid:SetText("Total Bid:    "..EnhTooltip.GetTextGSC(totalBid, true))
		frame.salebox.totalbuyout:SetText("Total Buyout: "..EnhTooltip.GetTextGSC(totalBuy, true))
		local curModel = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".model") or "default"
		if (frame.salebox.matcher:GetChecked() and (frame.salebox.matcher:IsEnabled()==1) and (DiffFromModel) and (curModel ~= "fixed")) then
			local MatchStringList = {strsplit("\n", MatchString)}
			for i in pairs(MatchStringList) do
				frame.manifest.lines:Add((MatchStringList[i]))
			end
		end
		
		if (totalBid < 1) then
			frame.manifest.lines:Add(("------------------------------"))
			frame.manifest.lines:Add(("Note: No auctionable items"))
		end

		local canAuction = true
		local warnText = frame.salebox.warn:GetText()
		if warnText and warnText ~= "" then
			canAuction = false
		end

		if totalBid < 1 then
			canAuction = false
		end

		if canAuction then
			frame.go:Enable()
		else
			frame.go:Disable()
		end

		-- Give this function a chance to save the current settings
		-- (if we're not already running within it)
		if not frame.salebox.config then
			frame.ChangeControls()
		end
	end

	function frame.ChangeControls(obj, ...)
		if frame.salebox.config then return end
		frame.salebox.config = true

		frame.UpdateControls()
		local curStack = frame.salebox.stack:GetValue()
		local curNumber = frame.salebox.number:GetAdjustedValue()
		local curDurationIdx = frame.salebox.duration:GetValue()
		local curDuration = private.durations[curDurationIdx][1]
		local curMatch = frame.salebox.matcher:GetChecked()
		local curBulk = frame.salebox.bulk:GetChecked()
		local curIgnore = frame.salebox.ignore:GetChecked()

		if curIgnore then curIgnore = true else curIgnore = false end
		if curBulk then curBulk = true else curBulk = false end
		AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".stack", curStack)
		AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".number", curNumber)
		AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".duration", curDuration)
		AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".bulk", curBulk)
		AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".ignore", curIgnore)
		if curMatch then
			curMatch = "on"
		else
			curMatch = "off"
		end  --must be something other than true/false, as false == nil, so false would cause default to be used
		AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".match", curMatch)

		local curModel
		if (obj and obj.element == "model") then
			curModel = select(2, ...)
			if curModel ~= "fixed" then
				frame.SetPriceFromModel(curModel)
			end
		else
			curModel = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".model")
		end

		local curBid = MoneyInputFrame_GetCopper(frame.salebox.bid)
		local curBuy = MoneyInputFrame_GetCopper(frame.salebox.buy)
		if frame.salebox.bid.modelvalue ~= curBid
		or frame.salebox.buy.modelvalue ~= curBuy
		then
			curModel = "fixed"
			AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".model", curModel)
			AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".fixed.bid", curBid)
			AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".fixed.buy", curBuy)
			frame.salebox.model.value = curModel
			frame.salebox.model:UpdateValue()
		end
		AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".bid", curBid)
		AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".buy", curBuy)

		local good = true
		if curModel == "fixed" and curBid <= 0 then
			frame.salebox.warn:SetText("Bid price must be > 0")
			good = false
		elseif (curBuy > 0 and curBid > curBuy) then
			frame.salebox.warn:SetText("Buy price must be > bid")
			good = false
		end
		if (good and curModel == "fixed") then
			frame.salebox.warn:SetText("")
		end

		frame.salebox.note:SetText("")
		if GetSellValue then
			local sellValue = GetSellValue(frame.salebox.link)
			if (sellValue and sellValue > 0) then
				if curBuy > 0 and curBuy < sellValue then
					frame.salebox.note:SetText("|cffff8010".."Note: Buyout < Vendor")
				elseif curBid > 0 and curBid < sellValue then
					frame.salebox.note:SetText("Note: Min Bid < Vendor")
				end
			end
		end

		frame.salebox.config = false
	end
	
	function frame.ChangeUI()
		if AucAdvanced.Settings.GetSetting("util.appraiser.classic") then
			frame.itembox:Hide()
			frame.salebox:SetPoint("TOPLEFT", frame, "TOPLEFT", 13, -71)
			frame.salebox:SetPoint("RIGHT", frame, "LEFT", 253, 0)
			frame.salebox:SetHeight(340) 
			frame.salebox.stack:Hide()
			frame.salebox.number:Hide()
			frame.manifest:Hide()
			frame.toggleManifest:Disable()
			frame.salebox.model:SetPoint("TOPLEFT", frame.salebox.icon, "BOTTOMLEFT", 0, -45)
			frame.salebox.bid:ClearAllPoints()
			frame.salebox.bid:SetPoint("TOP", frame.salebox.model, "BOTTOM", 0, -35)
			frame.salebox.bid:SetPoint("LEFT", frame.salebox, "LEFT", 25, 0)
			frame.salebox.bid.label:ClearAllPoints()
			frame.salebox.bid.label:SetPoint("BOTTOMLEFT", frame.salebox.bid, "TOPLEFT", 0, 2)
			frame.salebox.buy:SetPoint("TOPLEFT", frame.salebox.bid, "BOTTOMLEFT", 0, -20)
			frame.salebox.buy.label:ClearAllPoints()
			frame.salebox.buy.label:SetPoint("BOTTOMLEFT", frame.salebox.buy, "TOPLEFT", 0, 2)
			frame.salebox.duration:SetPoint("TOPLEFT", frame.salebox.buy, "BOTTOMLEFT", -10, -10)
			frame.gobatch:Hide()
			frame.go:SetPoint("BOTTOMRIGHT", frame.salebox, "BOTTOMRIGHT", -20, 15)
			frame.salebox.info:ClearAllPoints()
			frame.salebox.info:SetPoint("TOPLEFT", frame.salebox.slot, "BOTTOMLEFT", 0, 8)
			frame.imageview:Hide()
			frame.imageviewclassic:Show()
			frame.salebox.numberentry:SetPoint("TOPLEFT", frame.salebox.duration, "BOTTOMLEFT", 20, -5)
			frame.salebox.stackentry:SetPoint("TOPLEFT", frame.salebox.stacksoflabel, "TOPRIGHT", 5, 0)
			if not frame.salebox.sig then
				frame.salebox.info:SetText("Select an item to begin auctioning...")
			else
				frame.salebox.stackentry:Show()
				frame.salebox.stacksoflabel:Show()
				frame.salebox.numberentry:Show()
				frame.salebox.totalsize:Show()
				frame.salebox.depositcost:Show()
				frame.salebox.totalbid:Show()
				frame.salebox.totalbuyout:Show()
			end
			frame.salebox.name:SetHeight(36)
			frame.salebox.warn:SetJustifyH("LEFT")
			frame.salebox.warn:SetPoint("BOTTOMLEFT", frame.salebox.slot, "BOTTOMLEFT", 0, -25)
			frame.salebox.oldnote = frame.salebox.note
			frame.salebox.note = frame.salebox.warn
			frame.salebox.ignore:Hide()
			frame.salebox.bulk:Hide()
		else
			frame.salebox.stackentry:SetPoint("TOPLEFT", frame.salebox.stack, "TOPRIGHT", 5, 0)
			frame.salebox.numberentry:SetPoint("TOPLEFT", frame.salebox.number, "TOPRIGHT", 5, 0)
			frame.salebox.stacksoflabel:Hide()
			frame.salebox.totalsize:Hide()
			frame.salebox.numberentry:Hide()
			frame.salebox.depositcost:Hide()
			frame.salebox.totalbid:Hide()
			frame.salebox.totalbuyout:Hide()
			frame.salebox.ignore:Show()
			frame.salebox.bulk:Show()
			frame.itembox:Show()
			frame.salebox:SetPoint("TOPLEFT", frame.itembox, "TOPRIGHT", -3,35)
			frame.salebox:SetPoint("RIGHT", frame, "RIGHT", -5,0)
			frame.salebox:SetHeight(170)
			if frame.salebox.sig then
				frame.toggleManifest:Enable()
				if (frame.toggleManifest:GetText() == "Close Sidebar") then
					if not frame.manifest:IsVisible() then
						frame.manifest:Show()
					end
				elseif frame.manifest:IsVisible() then
					frame.manifest:Hide()
				end
				frame.salebox.stack:Show()
				frame.salebox.stackentry:Show()
				frame.salebox.numberentry:Show()
				frame.salebox.number:Show()
			else
				frame.salebox.info:SetText("Select an item to the left to begin auctioning...")
			end
			frame.salebox.icon:SetScript("OnClick", frame.IconClicked)
			frame.salebox.bid:ClearAllPoints()
			frame.salebox.bid:SetPoint("TOP", frame.salebox.number, "BOTTOM", 0,-5)
			frame.salebox.bid:SetPoint("RIGHT", frame.salebox, "RIGHT", 0,0)
			frame.salebox.buy:SetPoint("TOPLEFT", frame.salebox.bid, "BOTTOMLEFT", 0,-5)
			frame.salebox.duration:SetPoint("TOPLEFT", frame.salebox.number, "BOTTOMLEFT", 0,0)
			frame.salebox.model:SetPoint("TOPLEFT", frame.salebox.duration, "BOTTOMLEFT", 0,-16)
			frame.salebox.bid.label:ClearAllPoints()
			frame.salebox.bid.label:SetPoint("LEFT", frame.salebox.model, "RIGHT", 5,0)
			frame.salebox.bid.label:SetPoint("TOPRIGHT", frame.salebox.bid, "TOPLEFT", -5,0)
			frame.salebox.bid.label:SetPoint("BOTTOMRIGHT", frame.salebox.bid, "BOTTOMLEFT", -5,0)
			frame.salebox.buy.label:ClearAllPoints()
			frame.salebox.buy.label:SetPoint("LEFT", frame.salebox.model, "RIGHT", 5,0)
			frame.salebox.buy.label:SetPoint("TOPRIGHT", frame.salebox.buy, "TOPLEFT", -5,0)
			frame.salebox.buy.label:SetPoint("BOTTOMRIGHT", frame.salebox.buy, "BOTTOMLEFT", -5,0)
			frame.gobatch:Show()
			frame.go:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -7,15)
			frame.salebox.info:ClearAllPoints()
			frame.salebox.info:SetPoint("BOTTOMLEFT", frame.salebox.slot, "BOTTOMRIGHT", 5,7)
			frame.imageview:Show()
			frame.imageviewclassic:Hide()
			frame.salebox.name:SetHeight(20)
			frame.salebox.warn:SetJustifyH("RIGHT")
			frame.salebox.warn:SetPoint("BOTTOMLEFT", frame.salebox.slot, "BOTTOMRIGHT", 5, 0)
			frame.salebox.note = frame.salebox.oldnote or frame.salebox.note 
			frame.salebox.oldnote = nil
		end
	end

	function frame.GetItemByLink(link)
		local sig
		local itype, id, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(link)
		assert(itype and itype == "item", "Item must be a valid link")

		if enchant ~= 0 then
			sig = ("%d:%d:%d:%d"):format(id, suffix, factor, enchant)
		elseif factor ~= 0 then
			sig = ("%d:%d:%d"):format(id, suffix, factor)
		elseif suffix ~= 0 then
			sig = ("%d:%d"):format(id, suffix)
		else
			sig = tostring(id)
		end
		for i = 1, #(frame.list) do
			if frame.list[i] then
				if frame.list[i][1] == sig then
					local obj = {}
					obj.id = i
					local pos = math.floor(frame.scroller:GetValue())
					obj.id = obj.id - pos
					frame.SelectItem(obj)
					frame.scroller:SetValue(i-(NUM_ITEMS*(i/#frame.list)))
					return
				end
			end
		end
		frame.DirectSelect(link)
	end
	
	function frame.IconClicked()
		local objtype, _, itemlink = GetCursorInfo()
		ClearCursor()
		if objtype == "item" then
			frame.GetItemByLink(itemlink)
		else
			if not AucAdvanced.Settings.GetSetting("util.appraiser.classic") then
				frame.ToggleDisabled()
			end
		end
	end
	
	function frame.ToggleDisabled()
		if not frame.salebox.sig then return end
		local curDisable = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".ignore") or false
		AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".ignore", not curDisable)
		frame.GenerateList()
	end

	function frame.RefreshView(background)
		frame.refresh:Disable()
		local link = frame.salebox.link
		local name, _, rarity, _, itemMinLevel, itemType, itemSubType, stack, equipLoc = GetItemInfo(link)
		local itemTypeId, itemSubId
		for catId, catName in pairs(AucAdvanced.Const.CLASSES) do
			if catName == itemType then
				itemTypeId = catId
				for subId, subName in pairs(AucAdvanced.Const.SUBCLASSES[itemTypeId]) do
					if subName == itemSubType then
						itemSubId = subId
						break
					end
				end
				break
			end
		end
		if equipLoc == "" then equipLoc = nil end

		print(("Refreshing view of {{%s}}"):format(name))
		if background and type(background) == 'boolean' then
			AucAdvanced.Scan.StartPushedScan(name, itemMinLevel, itemMinLevel, equipLoc, itemTypeId, itemSubId, nil, rarity)
		else
			AucAdvanced.Scan.PushScan()
			AucAdvanced.Scan.StartScan(name, itemMinLevel, itemMinLevel, equipLoc, itemTypeId, itemSubId, nil, rarity)
		end
	end

	function frame.PostAuctions(obj)
		local postType = obj.postType
		if postType == "single" then
			frame.PostBySig(frame.salebox.sig)
		elseif postType == "batch" then
			if not IsModifierKeyDown() then
				message("This button requires you to press a combination of keys when clicked.\nSee help printed in the chat frame for further details.")
				print("The batch post mechanism will allow you to perform automated actions on all the items in your inventory marked for batch posting.")
				print("You must hold down one of the following keys when you click the button:")
				print("  - Alt = Auto-refresh all batch postable items.")
				print("  - Shift = List all auctions that would be posted without actually posting them.")
				print("  - Control+Alt+Shift = Auto-post all batch postable items.")
				return
			end

			local a = IsAltKeyDown()
			local s = IsShiftKeyDown()
			local c = IsControlKeyDown()

			local mode
			if a and c and s then mode = "autopost" end
			if a and not c and not s then mode = "refresh" end
			if not a and not c and s then mode = "list" end

			if not mode then
				message("Unknown key combination pressed while clicking batch post button.")
				return
			end
			
			if mode == "list" then
				print "The following items would have be auto-posted:"
			end
			
			local bg = false
			local obj = acquire()
			for i = 1, #(frame.list) do
				if frame.list[i] then
					local sig = frame.list[i][1]
					if AucAdvanced.Settings.GetSetting('util.appraiser.item.'..sig..".bulk") then
						obj.id = i

						frame.SelectItem(obj)
						if mode == "autopost" then
							-- Auto post these items
							frame.PostBySig(sig)
						elseif mode == "list" then
							-- List these items
							frame.PostBySig(sig, true)
						elseif mode == "refresh" then
							-- Refresh these items
							frame.RefreshView(bg)
							bg = true
						end
					end
				end
			end
			
		end
	end

	function frame.PostBySig(sig, dryRun)
		local stack = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..sig..".stack")
		local number = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..sig..".number")
		local itemBid = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..sig..".bid")
		local itemBuy = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..sig..".buy")
		local duration = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..sig..".duration")
		local success, errortext, total, _,_, link = pcall(AucAdvanced.Post.FindMatchesInBags, sig)
		if success==false then
			UIErrorsFrame:AddMessage("Unable to post auctions at this time")
			print("Cannot post auctions: ", errortext)
			return
		end

		-- Just a quick bit of sanity checking first
		assert(stack and stack >= 1)
		assert(number and number >= -2)
		assert(number ~= 0)
		assert(itemBid and itemBid > 0)
		assert(itemBuy and itemBuy == 0 or itemBuy >= itemBid)
		assert(duration and duration == 720 or duration == 1440 or duration == 2880)
		if not (total and total > 0) or (number > 0 and number * stack > total) then
			UIErrorsFrame:AddMessage("You do not have enough items to do that")
			print("You do not have enough items to do that")
		end
		if (number == -2) then
			assert(stack <= total)
		end

		print(("Posting batch of: %s"):format(link))

		print((" - Duration: {{%d hours}}"):format(duration/60))

		local bidVal, buyVal
		local totalBid, totalBuy, totalNum = 0,0,0

		if (stack > 1) then
			local fullStacks = math.floor(total / stack)
			local fullPop = fullStacks * stack
			local remain = total - fullPop

			if (number < 0) then
				if (fullStacks > 0) then
					bidVal = lib.RoundBid(itemBid * stack)
					buyVal = lib.RoundBuy(itemBuy * stack)
					if (buyVal ~= 0 and bidVal > buyVal) then buyVal = bidVal end
					if dryRun then
						print((" - Pretending to post {{%d}} stacks of {{%d}} at {{%s}} min and {{%s}} buyout per stack"):format(fullStacks, stack, EnhTooltip.GetTextGSC(bidVal, true), EnhTooltip.GetTextGSC(buyVal, true)))
					else
						print((" - Queueing {{%d}} lots of {{%d}}"):format(fullStacks, stack))
						AucAdvanced.Post.PostAuction(sig, stack, bidVal, buyVal, duration, fullStacks)
					end

					totalBid = totalBid + (bidVal * fullStacks)
					totalBuy = totalBuy + (buyVal * fullStacks)
					totalNum = totalNum + (stack * fullStacks)
				end
				if (number == -1 and remain > 0) then
					bidVal = lib.RoundBid(itemBid * remain)
					buyVal = lib.RoundBuy(itemBuy * remain)
					if (buyVal ~= 0 and bidVal > buyVal) then buyVal = bidVal end
					if dryRun then
						print((" - Pretending to post {{%d}} stacks of {{%d}} at {{%s}} min and {{%s}} buyout per stack"):format(1, remain, EnhTooltip.GetTextGSC(bidVal, true), EnhTooltip.GetTextGSC(buyVal, true)))
					else
						print((" - Queueing {{%d}} lots of {{%d}}"):format(1, remain))
						AucAdvanced.Post.PostAuction(sig, remain, bidVal, buyVal, duration)
					end

					totalBid = totalBid + bidVal
					totalBuy = totalBuy + buyVal
					totalNum = totalNum + remain
				end
			else
				bidVal = lib.RoundBid(itemBid * stack)
				buyVal = lib.RoundBuy(itemBuy * stack)
				if (buyVal ~= 0 and bidVal > buyVal) then buyVal = bidVal end
				if dryRun then
					print((" - Pretending to post {{%d}} stacks of {{%d}} at {{%s}} min and {{%s}} buyout per stack"):format(number, stack, EnhTooltip.GetTextGSC(bidVal, true), EnhTooltip.GetTextGSC(buyVal, true)))
				else
					print((" - Queueing {{%d}} lots of {{%d}}"):format(number, stack))
					AucAdvanced.Post.PostAuction(sig, stack, bidVal, buyVal, duration, number)
				end

				totalBid = totalBid + (bidVal * number)
				totalBuy = totalBuy + (buyVal * number)
				totalNum = totalNum + (stack * number)
			end
		else
			if number < 0 then number = total end
			bidVal = lib.RoundBid(itemBid)
			buyVal = lib.RoundBuy(itemBuy)
			if (buyVal ~= 0 and bidVal > buyVal) then buyVal = bidVal end
			if dryRun then
				print((" - Pretending to post {{%d}} items at {{%s}} min and {{%s}} buyout"):format(number, EnhTooltip.GetTextGSC(bidVal, true), EnhTooltip.GetTextGSC(buyVal, true)))
			else
				print((" - Queueing {{%d}} items"):format(number))
				AucAdvanced.Post.PostAuction(sig, 1, bidVal, buyVal, duration, number)
			end

			totalBid = totalBid + (bidVal * number)
			totalBuy = totalBuy + (buyVal * number)
			totalNum = totalNum + number
		end

		print("-----------------------------------")
		if dryRun then
			print(("Pretended {{%d}} items"):format(totalNum))
		else
			print(("Queued up {{%d}} items"):format(totalNum))
		end
		print(("Total minbid value: %s"):format(EnhTooltip.GetTextGSC(totalBid, true)))
		print(("Total buyout value: %s"):format(EnhTooltip.GetTextGSC(totalBuy, true)))
		print("-----------------------------------")
	end

	function frame.ClickBagHook(_,_,button)
		if (not AucAdvanced.Settings.GetSetting("util.appraiser.clickhook")) then return end
		local bag = this:GetParent():GetID()
		local slot = this:GetID()
		local texture, count, noSplit = GetContainerItemInfo(bag, slot)
		local link = GetContainerItemLink(bag, slot)
		if (frame.salebox and frame.salebox:IsVisible()) then
			if link then
				if (button == "LeftButton") and (IsAltKeyDown()) then
					frame.GetItemByLink(link)
					if (IsShiftKeyDown()) 
					and (AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".bid"))
					and (0 < (AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".bid"))) then
						
						local stack = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".stack")
						local number = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".number")
						AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".stack", count)
						AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".number", 1)
						frame.PostBySig(frame.salebox.sig)
						AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".stack", stack)
						AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".number", number)
						
					end
				end
			end
		end
	end
	
	function frame.SetScroll(...)
		local pos = math.floor(frame.scroller:GetValue())
		for i = 1, NUM_ITEMS do
			local item = frame.list[pos+i]
			local button = frame.items[i]
			if item then
				local curIgnore = item[0] == 1

				button.icon:SetTexture(item[3])
				button.icon:SetDesaturated(curIgnore)

				local _,_,_, hex = GetItemQualityColor(item[4])
				local stackX = "x "
				if (curIgnore) then
					hex = "|cff444444"
					stackX = hex..stackX
				end

				button.name:SetText(hex.."["..item[2].."]|r")
				button.size:SetText(stackX..item[6])
				local info = ""
				if frame.cache[item[1]] and not curIgnore then
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
				elseif curIgnore then
					button.bg:SetAlpha(0.1)
				else
					button.bg:SetAlpha(0.2)
				end
				button.bg:SetDesaturated(curIgnore)
			else
				button:Hide()
			end
		end
	end

	frame.DoTooltip = function ()
		if not this.id then this = this:GetParent() end
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

	frame.toggleManifest = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.toggleManifest:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -26, -13)
	frame.toggleManifest:SetScript("OnClick", function()
		if frame.manifest:IsShown() then
			frame.toggleManifest:SetText("Open Sidebar")
			frame.manifest:Hide()
		else
			frame.toggleManifest:SetText("Close Sidebar")
			frame.manifest:Show()
		end
	end)
	frame.toggleManifest:SetWidth(120)
	frame.toggleManifest:SetText("Close Sidebar")
	frame.toggleManifest:Disable()
	frame.toggleManifest:Show()

	frame.config = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.config:SetPoint("TOPRIGHT", frame.toggleManifest, "TOPLEFT", 3, 0)
	frame.config:SetText("Configure")
	frame.config:SetScript("OnClick", function()
		AucAdvanced.Settings.Show()
		private.gui:ActivateTab(private.guiId)
	end)

	frame.itembox = CreateFrame("Frame", nil, frame)
	frame.itembox:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	frame.itembox:SetBackdropColor(0, 0, 0, 0.8)
	frame.itembox:SetPoint("TOPLEFT", frame, "TOPLEFT", 13, -71)
	frame.itembox:SetWidth(240)
	frame.itembox:SetHeight(340)

	frame.itembox.hide = CreateFrame("Button", nil, frame.itembox, "OptionsButtonTemplate")
	frame.itembox.hide:SetPoint("BOTTOM", frame.itembox, "TOP", 0,0)
	frame.itembox.hide:SetScript("OnClick", function()
		if (frame.showHidden) then
			frame.showHidden = false
		else
			frame.showHidden = true
		end
		frame.GenerateList()
	end)
	frame.itembox.hide:SetText("Toggle Hidden")
	frame.itembox.hide:SetWidth(120)
	frame.itembox.hide:Show()

	frame.items = {}
	for i=1, NUM_ITEMS do
		local item = CreateFrame("Button", nil, frame.itembox)
		frame.items[i] = item
		item:SetScript("OnClick", frame.SelectItem)
		if (i == 1) then
			item:SetPoint("TOPLEFT", frame.itembox, "TOPLEFT", 5,-8 )
		else
			item:SetPoint("TOPLEFT", frame.items[i-1], "BOTTOMLEFT", 0, -1)
		end
		item:SetPoint("RIGHT", frame.itembox, "RIGHT", -23,0)
		item:SetHeight(26)

		item.id = i

		item.iconbutton = CreateFrame("Button", nil, item)
		item.iconbutton:SetHeight(26)
		item.iconbutton:SetWidth(26)
		item.iconbutton:SetPoint("LEFT", item, "LEFT", 3,0)
		item.iconbutton:SetScript("OnClick", frame.SelectItem)
		item.iconbutton:SetScript("OnEnter", frame.DoTooltip)
		item.iconbutton:SetScript("OnLeave", frame.UndoTooltip)

		item.icon = item.iconbutton:CreateTexture(nil, "OVERLAY")
		item.icon:SetPoint("TOPLEFT", item.iconbutton, "TOPLEFT", 0,0)
		item.icon:SetPoint("BOTTOMRIGHT", item.iconbutton, "BOTTOMRIGHT", 0,0)
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
	local scroller = CreateFrame("Slider", "AucAppraiserItemScroll", frame.itembox)
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
	frame.salebox:SetBackdropColor(0, 0, 0, 0.8)
	frame.salebox:SetPoint("TOPLEFT", frame.itembox, "TOPRIGHT", -3,35)
	frame.salebox:SetPoint("RIGHT", frame, "RIGHT", -5,0)
	frame.salebox:SetHeight(170)

	frame.salebox.slot = frame.salebox:CreateTexture(nil, "BORDER")
	frame.salebox.slot:SetPoint("TOPLEFT", frame.salebox, "TOPLEFT", 10, -10)
	frame.salebox.slot:SetWidth(40)
	frame.salebox.slot:SetHeight(40)
	frame.salebox.slot:SetTexCoord(0.15, 0.85, 0.15, 0.85)
	frame.salebox.slot:SetTexture("Interface\\Buttons\\UI-EmptySlot")

	frame.salebox.icon = CreateFrame("Button", nil, frame.salebox)
	frame.salebox.icon:SetPoint("TOPLEFT", frame.salebox.slot, "TOPLEFT", 3, -3)
	frame.salebox.icon:SetWidth(32)
	frame.salebox.icon:SetHeight(32)
	frame.salebox.icon:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp")
	frame.salebox.icon:SetScript("OnClick", frame.IconClicked)
	frame.salebox.icon:SetScript("OnReceiveDrag", frame.IconClicked)
	
	frame.salebox.name = frame.salebox:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	frame.salebox.name:SetPoint("TOPLEFT", frame.salebox.slot, "TOPRIGHT", 5,-2)
	frame.salebox.name:SetPoint("RIGHT", frame.salebox, "RIGHT", -15)
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

	frame.salebox.warn = frame.salebox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.warn:SetPoint("BOTTOMLEFT", frame.salebox.slot, "BOTTOMRIGHT", 5,0)
	frame.salebox.warn:SetPoint("RIGHT", frame.salebox, "RIGHT", -10,0)
	frame.salebox.warn:SetHeight(12)
	frame.salebox.warn:SetTextColor(1, 0.3, 0.06)
	frame.salebox.warn:SetText("")
	frame.salebox.warn:SetJustifyH("RIGHT")
	frame.salebox.warn:SetJustifyV("BOTTOM")

	frame.salebox.note = frame.salebox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.note:SetPoint("BOTTOMLEFT", frame.salebox, "BOTTOMLEFT", 0,10)
	frame.salebox.note:SetPoint("RIGHT", frame.salebox, "RIGHT", -10,0)
	frame.salebox.note:SetHeight(12)
	frame.salebox.note:SetTextColor(1, 0.8, 0.1)
	frame.salebox.note:SetText("")
	frame.salebox.note:SetJustifyH("RIGHT")
	frame.salebox.note:SetJustifyV("BOTTOM")

	frame.salebox.stack = CreateFrame("Slider", "AppraiserSaleboxStack", frame.salebox, "OptionsSliderTemplate")
	frame.salebox.stack:SetPoint("TOPLEFT", frame.salebox.slot, "BOTTOMLEFT", 0, -5)
	frame.salebox.stack:SetHitRectInsets(0,0,0,0)
	frame.salebox.stack:SetMinMaxValues(1,20)
	frame.salebox.stack:SetValueStep(1)
	frame.salebox.stack:SetValue(20)
	frame.salebox.stack:SetWidth(255)
	frame.salebox.stack:SetScript("OnValueChanged", frame.ChangeControls)
	frame.salebox.stack.element = "stack"
	frame.salebox.stack:Hide()
	
	frame.salebox.stack:EnableMouseWheel(1)
	frame.salebox.stack:SetScript("OnMouseWheel", function()
		frame.salebox.stack:SetValue(frame.salebox.stack:GetValue() + -arg1)
	end)
	
	AppraiserSaleboxStackLow:SetText("")
	AppraiserSaleboxStackHigh:SetText("")

	frame.salebox.stack.label = frame.salebox.stack:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.stack.label:SetPoint("LEFT", frame.salebox.stack, "RIGHT", 33,2)
	frame.salebox.stack.label:SetJustifyH("LEFT")
	frame.salebox.stack.label:SetJustifyV("CENTER")
	
	frame.salebox.number = CreateFrame("Slider", "AppraiserSaleboxNumber", frame.salebox, "OptionsSliderTemplate")
	frame.salebox.number:SetPoint("TOPLEFT", frame.salebox.stack, "BOTTOMLEFT", 0,0)
	frame.salebox.number:SetHitRectInsets(0,0,0,0)
	frame.salebox.number:SetMinMaxValues(1,1)
	frame.salebox.number:SetValueStep(1)
	frame.salebox.number:SetValue(1)
	frame.salebox.number:SetWidth(255)
	frame.salebox.number:SetScript("OnValueChanged", frame.ChangeControls)
	frame.salebox.number.element = "number"
	frame.salebox.number:Hide()
	AppraiserSaleboxNumberLow:SetText("")
	AppraiserSaleboxNumberHigh:SetText("")

	
	function frame.salebox.number:GetAdjustedValue()
		local maxStax = self.maxStax or 0
		local value = self:GetValue()
		if value > maxStax then
			local extraPos = value - maxStax
			value = self.extra[extraPos]
		end
		return value or 1
	end
	function frame.salebox.number:SetAdjustedValue(value)
		local maxStax = self.maxStax or 0
		if value < 1 or value > maxStax then
			for i = 1, #self.extra do
				if self.extra[i] == value then
					value = maxStax + i
					break
				end
			end
		end
		self:SetValue(value)
	end
	frame.salebox.number.extra = {}
	function frame.salebox.number:SetAdjustedRange(maxStax, ...)
		local curVal = self:GetAdjustedValue()
		self.maxStax = maxStax
		local n = select("#", ...)
		for i = 1, #self.extra do self.extra[i] = nil end
		for i = 1, select("#", ...) do self.extra[i] = select(i, ...) end
		self:SetMinMaxValues(1, maxStax+n)
		self:SetAdjustedValue(math.min(curVal, maxStax))
	end
	
	frame.salebox.number:EnableMouseWheel(1)
	frame.salebox.number:SetScript("OnMouseWheel", function()
		frame.salebox.number:SetValue(frame.salebox.number:GetValue() + -arg1)
	end)
	
	frame.salebox.number.label = frame.salebox.number:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.number.label:SetPoint("LEFT", frame.salebox.number, "RIGHT", 33,2)
	frame.salebox.number.label:SetJustifyH("LEFT")
	frame.salebox.number.label:SetJustifyV("CENTER")

	frame.salebox.duration = CreateFrame("Slider", "AppraiserSaleboxDuration", frame.salebox, "OptionsSliderTemplate")
	frame.salebox.duration:SetPoint("TOPLEFT", frame.salebox.number, "BOTTOMLEFT", 0,0)
	frame.salebox.duration:SetHitRectInsets(0,0,0,0)
	frame.salebox.duration:SetMinMaxValues(1,3)
	frame.salebox.duration:SetValueStep(1)
	frame.salebox.duration:SetValue(3)
	frame.salebox.duration:SetWidth(80)
	frame.salebox.duration:SetScript("OnValueChanged", frame.ChangeControls)
	frame.salebox.duration.element = "duration"
	frame.salebox.duration:Hide()
	AppraiserSaleboxDurationLow:SetText("")
	AppraiserSaleboxDurationHigh:SetText("")

	frame.salebox.duration:EnableMouseWheel(1)
	frame.salebox.duration:SetScript("OnMouseWheel", function()
		frame.salebox.duration:SetValue(frame.salebox.duration:GetValue() + arg1)
	end)
	
	frame.salebox.duration.label = frame.salebox.duration:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.duration.label:SetPoint("LEFT", frame.salebox.duration, "RIGHT", 3,2)
	frame.salebox.duration.label:SetJustifyH("LEFT")
	frame.salebox.duration.label:SetJustifyV("CENTER")

	function frame.GetLinkPriceModels()
		return private.GetExtraPriceModels(frame.salebox.link)
	end
	frame.salebox.model = SelectBox:Create("AppraiserSaleboxModel", frame.salebox, 140, frame.ChangeControls, frame.GetLinkPriceModels, "default")
	frame.salebox.model:SetPoint("TOPLEFT", frame.salebox.duration, "BOTTOMLEFT", 0,-16)
	frame.salebox.model.element = "model"
	frame.salebox.model:Hide()

	frame.salebox.model.label = frame.salebox.model:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.model.label:SetPoint("BOTTOMLEFT", frame.salebox.model, "TOPLEFT", 0,0)
	frame.salebox.model.label:SetText("Pricing model to use:")
	
	frame.salebox.matcher = CreateFrame("CheckButton", "AppraiserSaleboxMatch", frame.salebox, "UICheckButtonTemplate")
	frame.salebox.matcher:SetPoint("TOPLEFT", frame.salebox.model, "BOTTOMLEFT", 22, 7)
	frame.salebox.matcher:SetHeight(20)
	frame.salebox.matcher:SetWidth(20)
	frame.salebox.matcher:SetChecked(false)
	frame.salebox.matcher:SetScript("OnClick", frame.ChangeControls)
	frame.salebox.matcher:Hide()
	
	frame.salebox.matcher.label = frame.salebox.matcher:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.matcher.label:SetPoint("BOTTOMLEFT", frame.salebox.matcher, "BOTTOMRIGHT", 0, 6)
	frame.salebox.matcher.label:SetText("Enable price matching")

	frame.salebox.ignore = CreateFrame("CheckButton", "AppraiserSaleboxIgnore", frame.salebox, "UICheckButtonTemplate")
	frame.salebox.ignore:SetPoint("TOPRIGHT", frame.salebox, "TOPRIGHT", -10, -3)
	frame.salebox.ignore:SetHeight(20)
	frame.salebox.ignore:SetWidth(20)
	frame.salebox.ignore:SetChecked(false)
	frame.salebox.ignore:SetScript("OnClick", frame.IconClicked)
	frame.salebox.ignore:Hide()
	
	frame.salebox.ignore.label = frame.salebox.ignore:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.ignore.label:SetPoint("BOTTOMRIGHT", frame.salebox.ignore, "BOTTOMLEFT", -5, 6)
	frame.salebox.ignore.label:SetText("Hide this item")

	frame.salebox.bulk = CreateFrame("CheckButton", "AppraiserSaleboxBulk", frame.salebox, "UICheckButtonTemplate")
	frame.salebox.bulk:SetPoint("TOPRIGHT", frame.salebox.ignore, "BOTTOMRIGHT", 0, 3)
	frame.salebox.bulk:SetHeight(20)
	frame.salebox.bulk:SetWidth(20)
	frame.salebox.bulk:SetChecked(false)
	frame.salebox.bulk:SetScript("OnClick", frame.ChangeControls)
	frame.salebox.bulk:Hide()
	
	frame.salebox.bulk.label = frame.salebox.bulk:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.bulk.label:SetPoint("BOTTOMRIGHT", frame.salebox.bulk, "BOTTOMLEFT", -5, 6)
	frame.salebox.bulk.label:SetText("Enable batch posting")

	frame.salebox.bid = CreateFrame("Frame", "AppraiserSaleboxBid", frame.salebox, "MoneyInputFrameTemplate")
	frame.salebox.bid:SetPoint("TOP", frame.salebox.number, "BOTTOM", 0,-5)
	frame.salebox.bid:SetPoint("RIGHT", frame.salebox, "RIGHT", 0,0)
	MoneyInputFrame_SetOnvalueChangedFunc(frame.salebox.bid, frame.ChangeControls)
	frame.salebox.bid.element = "bid"
	frame.salebox.bid:Hide()
	AppraiserSaleboxBidGold:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
		tile = true, tileSize = 32, 
		insets = { left = -2, right = 3, top = 4, bottom = 2}
	})
	AppraiserSaleboxBidGold:SetBackdropColor(0,0,0, 0)
	AppraiserSaleboxBidSilver:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
		tile = true, tileSize = 32, 
		insets = { left = -2, right = 12, top = 4, bottom = 2}
	})
	AppraiserSaleboxBidSilver:SetBackdropColor(0,0,0, 0)
	AppraiserSaleboxBidCopper:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
		tile = true, tileSize = 32, 
		insets = { left = -2, right = 12, top = 4, bottom = 2}
	})
	AppraiserSaleboxBidCopper:SetBackdropColor(0,0,0, 0)

	frame.salebox.bid.label = frame.salebox.bid:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.bid.label:SetPoint("LEFT", frame.salebox.model, "RIGHT", 5,0)
	frame.salebox.bid.label:SetPoint("TOPRIGHT", frame.salebox.bid, "TOPLEFT", -5,0)
	frame.salebox.bid.label:SetPoint("BOTTOMRIGHT", frame.salebox.bid, "BOTTOMLEFT", -5,0)
	frame.salebox.bid.label:SetText("Bid price/item:")
	frame.salebox.bid.label:SetJustifyH("RIGHT")

	frame.salebox.buy = CreateFrame("Frame", "AppraiserSaleboxBuy", frame.salebox, "MoneyInputFrameTemplate")
	frame.salebox.buy:SetPoint("TOPLEFT", frame.salebox.bid, "BOTTOMLEFT", 0,-5)
	MoneyInputFrame_SetOnvalueChangedFunc(frame.salebox.buy, frame.ChangeControls)
	frame.salebox.buy.element = "buy"
	frame.salebox.buy:Hide()
	AppraiserSaleboxBuyGold:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
		tile = true, tileSize = 32, 
		insets = { left = -2, right = 3, top = 4, bottom = 2}
	})
	AppraiserSaleboxBuyGold:SetBackdropColor(0,0,0, 0)
	AppraiserSaleboxBuySilver:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
		tile = true, tileSize = 32, 
		insets = { left = -2, right = 12, top = 4, bottom = 2}
	})
	AppraiserSaleboxBuySilver:SetBackdropColor(0,0,0, 0)
	AppraiserSaleboxBuyCopper:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
		tile = true, tileSize = 32, 
		insets = { left = -2, right = 12, top = 4, bottom = 2}
	})
	AppraiserSaleboxBuyCopper:SetBackdropColor(0,0,0, 0)

	MoneyInputFrame_SetNextFocus(frame.salebox.bid, AppraiserSaleboxBuyGold)
	MoneyInputFrame_SetPreviousFocus(frame.salebox.bid, AppraiserSaleboxBuyCopper)
	MoneyInputFrame_SetNextFocus(frame.salebox.buy, AppraiserSaleboxBidGold)
	MoneyInputFrame_SetPreviousFocus(frame.salebox.buy, AppraiserSaleboxBidCopper)

	frame.salebox.buy.label = frame.salebox.buy:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.buy.label:SetPoint("LEFT", frame.salebox.model, "RIGHT", 5,0)
	frame.salebox.buy.label:SetPoint("TOPRIGHT", frame.salebox.buy, "TOPLEFT", -5,0)
	frame.salebox.buy.label:SetPoint("BOTTOMRIGHT", frame.salebox.buy, "BOTTOMLEFT", -5,0)
	frame.salebox.buy.label:SetText("Buy price/item:")
	frame.salebox.buy.label:SetJustifyH("RIGHT")

	frame.go = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.go:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -7,15)
	frame.go:SetText("Post items")
	frame.go:SetWidth(80)
	frame.go:SetScript("OnClick", frame.PostAuctions)
	frame.go.postType = "single"
	frame.go:Disable()

	frame.gobatch = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.gobatch:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -87,15)
	frame.gobatch:SetText("Batch post")
	frame.gobatch:SetWidth(80)
	frame.gobatch:SetScript("OnClick", frame.PostAuctions)
	frame.gobatch.postType = "batch"
	frame.gobatch:Enable()

	frame.refresh = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.refresh:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -167,15)
	frame.refresh:SetText("Refresh")
	frame.refresh:SetWidth(80)
	frame.refresh:SetScript("OnClick", frame.RefreshView)
	frame.refresh:Disable()
	
	frame.switchUI = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.switchUI:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -247,15)
	frame.switchUI:SetText("Switch UI")
	frame.switchUI:SetWidth(80)
	frame.switchUI:SetScript("OnClick", function()
		AucAdvanced.Settings.SetSetting("util.appraiser.classic", (not AucAdvanced.Settings.GetSetting("util.appraiser.classic")))
		frame.ChangeUI()
	end)
	frame.switchUI:Enable()

	frame.age = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.age:SetPoint("RIGHT", frame.refresh, "LEFT", -85,0)
	frame.age:SetTextColor(1, 0.8, 0)
	frame.age:SetText("")
	frame.age:SetJustifyH("RIGHT")
	--frame.age:SetJustifyV("BOTTOM")

	frame.manifest = CreateFrame("Frame", nil, frame)
	frame.manifest:SetBackdrop({
		bgFile = "Interface\\Tooltips\\ChatBubble-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	frame.manifest:SetBackdropColor(0, 0, 0, 1)
	frame.manifest:SetPoint("TOPLEFT", frame, "TOPRIGHT", -20,-30)
	frame.manifest:SetPoint("BOTTOM", frame, "BOTTOM", 0,30)
	frame.manifest:SetWidth(230)
	frame.manifest:SetFrameStrata("MEDIUM")
	frame.manifest:SetFrameLevel(AuctionFrame:GetFrameLevel())
	frame.manifest:Hide()

	frame.manifest.close = CreateFrame("Button", nil, frame.manifest)
	frame.manifest.close:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
	frame.manifest.close:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
	frame.manifest.close:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
	frame.manifest.close:SetDisabledTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Disabled")
	frame.manifest.close:SetPoint("TOPRIGHT", frame.manifest, "TOPRIGHT", 0,0)
	frame.manifest.close:SetWidth(26)
	frame.manifest.close:SetHeight(26)
	frame.manifest.close:SetScript("OnClick", function()
		frame.manifest:Hide()
		frame.toggleManifest:SetText("Open Sidebar")
	end)

	local function lineHide(obj)
		local id = obj.id
		local line = frame.manifest.lines[id]
		line[1]:Hide()
		line[2]:Hide()
	end

	local function lineSet(obj, text, coins, r,g,b)
		local id = obj.id
		local line = frame.manifest.lines[id]
		line[1]:SetText(text)
		if r and g and b then
			line[1]:SetTextColor(r,g,b)
		else
			line[1]:SetTextColor(1,1,1)
		end
		line[1]:Show()
		line[2]:Show()

		local zero = false
		local money = 0
		if coins then
			money = math.floor(tonumber(coins) or 0)
			if money == 0 then zero = true end
		end
		TinyMoneyFrame_Update(line[2], money)
		if zero then
			getglobal("AppraisalManifestCoins"..id.."CopperButton"):Show()
		end
	end

	local function lineReset(obj, text, coins)
		local id = obj.id
		local line = frame.manifest.lines[id]
		line[1]:SetText("")
		TinyMoneyFrame_Update(line[2], 0)
	end

	local function linesClear(obj)
		obj.pos = 0
		for i = 1, obj.max do
			obj[i]:Hide()
		end
	end

	local function linesAdd(obj, text, coins, r,g,b)
		obj.pos = obj.pos + 1
		if (obj.pos > obj.max) then return end
		obj[obj.pos]:Set(text, coins, r,g,b)
	end


	local myStrata = frame.manifest:GetFrameStrata()

	frame.manifest.header = frame.manifest:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.manifest.header:SetPoint("TOPLEFT", frame.manifest, "TOPLEFT", 24, -5)
	frame.manifest.header:SetPoint("RIGHT", frame.manifest, "RIGHT", 0,0)
	frame.manifest.header:SetJustifyH("LEFT")
	frame.manifest.header:SetText("Auction detail:")

	local lines = { pos = 0, max = 40, Clear = linesClear, Add = linesAdd }
	for i=1, lines.max do
		local text = frame.manifest:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		if i == 1 then
			text:SetPoint("TOPLEFT", frame.manifest, "TOPLEFT", 26,-18)
		else
			text:SetPoint("TOPLEFT", lines[i-1][1], "BOTTOMLEFT", 0,0)
		end
		text:SetPoint("RIGHT", frame.manifest, "RIGHT", 0,0)
		text:SetJustifyH("LEFT")
		text:SetHeight(9)

		local coins = CreateFrame("Frame", "AppraisalManifestCoins"..i, frame.manifest, "EnhancedTooltipMoneyTemplate")
		coins:SetPoint("RIGHT", text, "RIGHT", 0,0)
		coins:SetFrameStrata(myStrata)
		coins.info.showSmallerCoins = "backpack"
		coins:SetScale(0.85)

		local line = { text, coins, id = i, Hide = lineHide, Set = lineSet, Reset = lineReset }
		lines[i] = line
	end
	frame.manifest.lines = lines

	frame.imageview = CreateFrame("Frame", nil, frame)
	frame.imageview:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	frame.imageview:SetBackdropColor(0, 0, 0, 0.8)
	frame.imageview:SetPoint("TOPLEFT", frame.salebox, "BOTTOMLEFT")
	frame.imageview:SetPoint("TOPRIGHT", frame.salebox, "BOTTOMRIGHT")
	frame.imageview:SetPoint("BOTTOM", frame.itembox, "BOTTOM")

	frame.imageview.sheet = ScrollSheet:Create(frame.imageview, {
		{ "Item",   "TEXT", 120 },
		{ "Seller", "TEXT", 75  },
		{ "Left",   "INT",  40  },
		{ "Stk",    "INT",  30  },
		{ "Min/ea", "COIN", 85, { DESCENDING=true } },
		{ "Cur/ea", "COIN", 85, { DESCENDING=true } },
		{ "Buy/ea", "COIN", 85, { DESCENDING=true, DEFAULT=true } },
		{ "MinBid", "COIN", 85, { DESCENDING=true } },
		{ "CurBid", "COIN", 85, { DESCENDING=true } },
		{ "Buyout", "COIN", 85, { DESCENDING=true } },
	})
	
	frame.imageviewclassic = CreateFrame("Frame", nil, frame)
	frame.imageviewclassic:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	
	frame.imageviewclassic:SetBackdropColor(0, 0, 0, 0.8)
	frame.imageviewclassic:SetPoint("TOPLEFT", frame.itembox, "TOPRIGHT", -3, 35)
	frame.imageviewclassic:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
	frame.imageviewclassic:SetPoint("BOTTOM", frame.itembox, "BOTTOM")
	frame.imageviewclassic.sheet = ScrollSheet:Create(frame.imageviewclassic, {
		{ "Item",   "TEXT", 120 },
		{ "Seller", "TEXT", 75  },
		{ "Left",   "INT",  40  },
		{ "Stk",    "INT",  30  },
		{ "Min/ea", "COIN", 85, { DESCENDING=true } },
		{ "Cur/ea", "COIN", 85, { DESCENDING=true } },
		{ "Buy/ea", "COIN", 85, { DESCENDING=true, DEFAULT=true } },
		{ "MinBid", "COIN", 85, { DESCENDING=true } },
		{ "CurBid", "COIN", 85, { DESCENDING=true } },
		{ "Buyout", "COIN", 85, { DESCENDING=true } },
	})
	frame.imageviewclassic:Hide()
	
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
			if (AuctionDressUpFrame:IsVisible()) then
				AuctionDressUpFrame:Hide()
				AuctionDressUpFrame.reshow = true
			end
			frame:Show()
			AucAdvanced.Scan.GetImage()
			frame.GenerateList(true)
		else
			if (AuctionDressUpFrame.reshow) then
				AuctionDressUpFrame:Show()
				AuctionDressUpFrame.reshow = nil
			end
			AuctionFrameMoneyFrame:Show()
			frame:Hide()
		end
	end
	
	frame.salebox.numberentry = CreateFrame("EditBox", "AppraiserSaleboxNumberEntry", frame.salebox, "InputBoxTemplate")
	frame.salebox.numberentry:SetPoint("TOPLEFT", frame.salebox.duration, "BOTTOMLEFT", 20, -5)
	frame.salebox.numberentry:SetNumeric(false)
	frame.salebox.numberentry:SetHeight(16)
	frame.salebox.numberentry:SetWidth(30)
	frame.salebox.numberentry:SetNumber(0)
	frame.salebox.numberentry:SetAutoFocus(false)
	frame.salebox.numberentry:SetScript("OnEnterPressed", function()
		local text = frame.salebox.numberentry:GetText()
		if (text:lower() == "full") then
			frame.salebox.numberentry:SetNumber(-2)
		elseif (text:lower() == "all") then
			frame.salebox.numberentry:SetNumber(-1)
		end
		frame.salebox.number:SetAdjustedValue(frame.salebox.numberentry:GetNumber())
		frame.salebox.numberentry:ClearFocus()
		frame.UpdateControls()
	end)
	frame.salebox.numberentry:SetScript("OnTabPressed", function()
		local text = frame.salebox.numberentry:GetText()
		if (text:lower() == "full") then
			frame.salebox.numberentry:SetNumber(-2)
		elseif (text:lower() == "all") then
			frame.salebox.numberentry:SetNumber(-1)
		end
		frame.salebox.number:SetAdjustedValue(frame.salebox.numberentry:GetNumber())
		frame.salebox.stackentry:SetFocus()
		frame.UpdateControls()
	end)
	frame.salebox.numberentry:SetScript("OnTextChanged", function()
		local text = frame.salebox.numberentry:GetText()
		if text ~= "" then
			if (text:lower() == "full") then
				if (frame.salebox.stacksize > 1) then
					frame.salebox.numberentry:SetText("Full")
					frame.salebox.number:SetAdjustedValue(-2)
				else
					frame.salebox.numberentry:SetText("All")
					frame.salebox.number:SetAdjustedValue(-1)
				end
			elseif (text:lower() == "all") then
				frame.salebox.numberentry:SetText("All")
				frame.salebox.number:SetAdjustedValue(-1)
			else
				if frame.salebox.numberentry:GetNumber() ~= 0 or frame.salebox.numberentry:GetText() == "0" then
					frame.salebox.number:SetAdjustedValue(frame.salebox.numberentry:GetNumber())
					frame.UpdateControls()
				end
			end
		end
		--frame.UpdateControls()
	end)
	frame.salebox.numberentry:SetScript("OnEscapePressed", function()
		frame.salebox.numberentry:ClearFocus()
	end)
	frame.salebox.numberentry:Hide()
	
	frame.salebox.stacksoflabel = frame.salebox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.stacksoflabel:SetPoint("TOPLEFT", frame.salebox.numberentry, "TOPRIGHT", 5, 0)
	frame.salebox.stacksoflabel:SetJustifyH("LEFT")
	frame.salebox.stacksoflabel:SetJustifyV("CENTER")
	frame.salebox.stacksoflabel:SetText("stacks of")
	frame.salebox.stacksoflabel:Hide()
	
	frame.salebox.stackentry = CreateFrame("EditBox", "AppraiserSaleboxStackEntry", frame.salebox, "InputBoxTemplate")
	frame.salebox.stackentry:SetPoint("TOPLEFT", frame.salebox.stacksoflabel, "TOPRIGHT", 5, 0)
	frame.salebox.stackentry:SetNumeric(true)
	frame.salebox.stackentry:SetNumber(0)
	frame.salebox.stackentry:SetHeight(16)
	frame.salebox.stackentry:SetWidth(30)
	frame.salebox.stackentry:SetAutoFocus(false)
	frame.salebox.stackentry:SetScript("OnEnterPressed", function()
		frame.salebox.stack:SetValue(frame.salebox.stackentry:GetNumber())
		frame.salebox.stackentry:ClearFocus()
		frame.UpdateControls()
	end)
	frame.salebox.stackentry:SetScript("OnTabPressed", function()
		frame.salebox.stack:SetValue(frame.salebox.stackentry:GetNumber())
		frame.salebox.numberentry:SetFocus()
		frame.UpdateControls()
	end)
	frame.salebox.stackentry:SetScript("OnTextChanged", function()
		local text = frame.salebox.stackentry:GetText()
		if text ~= "" then
			frame.salebox.stack:SetValue(frame.salebox.stackentry:GetNumber())
			frame.UpdateControls()
		end
	end)
	frame.salebox.stackentry:SetScript("OnEscapePressed", function()
		frame.salebox.stackentry:ClearFocus()
	end)
	frame.salebox.stackentry:Hide()
	
	frame.salebox.totalsize = frame.salebox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.totalsize:SetPoint("TOPLEFT", frame.salebox.stackentry, "TOPRIGHT", 3, 0)
	frame.salebox.totalsize:SetJustifyH("LEFT")
	frame.salebox.totalsize:SetJustifyV("CENTER")
	frame.salebox.totalsize:SetText("()")
	frame.salebox.totalsize:Hide()
	
	frame.salebox.depositcost = frame.salebox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.depositcost:SetPoint("TOPLEFT", frame.salebox.numberentry, "BOTTOMLEFT", -15, -5)
	frame.salebox.depositcost:SetJustifyH("LEFT")
	frame.salebox.depositcost:SetJustifyV("CENTER")
	frame.salebox.depositcost:Hide()
	frame.salebox.totalbid = frame.salebox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.totalbid:SetPoint("TOPLEFT", frame.salebox.depositcost, "BOTTOMLEFT", 0, 0)
	frame.salebox.totalbid:SetJustifyH("LEFT")
	frame.salebox.totalbid:SetJustifyV("CENTER")
	frame.salebox.totalbid:Hide()
	frame.salebox.totalbuyout = frame.salebox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.totalbuyout:SetPoint("TOPLEFT", frame.salebox.totalbid, "BOTTOMLEFT", 0, 0)
	frame.salebox.totalbuyout:SetJustifyH("LEFT")
	frame.salebox.totalbuyout:SetJustifyV("CENTER")
	frame.salebox.totalbuyout:Hide()
	
	Stubby.RegisterFunctionHook("ContainerFrameItemButton_OnModifiedClick", -300, frame.ClickBagHook)
	frame.ChangeUI()
	hooksecurefunc("AuctionFrameTab_OnClick", frame.ScanTab.OnClick)
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
