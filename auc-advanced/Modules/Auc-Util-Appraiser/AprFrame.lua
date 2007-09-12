--[[
	Auctioneer Advanced - Appraisals and Auction Posting
	Revision: $Id$
	Version: <%version%> (<%codename%>)

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

local frame

local NUM_ITEMS = 12

function private.CreateFrames()
	if frame then return end

	local nSelectBox = LibStub:GetLibrary("nSelectBox")
	local nScrollSheet = LibStub:GetLibrary("nScrollSheet")

	frame = CreateFrame("Frame", nil, AuctionFrame)
	private.frame = frame

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
					if AucAdvanced.Post.IsAuctionable(bag, slot) then
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
		local sig = item[1] or nil
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
		else
			frame.salebox.name:SetText("No item selected")
			frame.salebox.name:SetTextColor(0.5, 0.5, 0.7)
			frame.salebox.info:SetText("Select an item to the left to begin auctioning...")
			frame.salebox.info:SetTextColor(0.5, 0.5, 0.7)
			frame.imageview.sheet:SetData(private.empty)
			frame.UpdateControls()
		end
	end

	function frame.Reselect(posted)
		local reselect = (frame.selected == posted[1])
		frame.GenerateList()
		if reselect then
			frame.SelectItem(frame.selectedObj)
		end
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
		local data = {}
		for i = 1, #results do
			local result = results[i]
			local tLeft = result[Const.TLEFT]
			if (tLeft == 1) then tLeft = "30m"
			elseif (tLeft == 2) then tLeft = "2h"
			elseif (tLeft == 3) then tLeft = "8h"
			elseif (tLeft == 4) then tLeft = "24h"
			end
			local count = result[Const.COUNT]
			data[i] = {
				result[Const.NAME],
				result[Const.SELLER],
				tLeft,
				count,
				math.floor(0.5+result[Const.MINBID]/count),
				math.floor(0.5+result[Const.CURBID]/count),
				math.floor(0.5+result[Const.BUYOUT]/count),
				result[Const.MINBID],
				result[Const.CURBID],
				result[Const.BUYOUT],
			}
		end
		frame.imageview.sheet:SetData(data)
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
			frame.salebox.model:SetText("Default ("..curModel..")")
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

				-- Scale up for duration > 2 hours
				if deposit > 0 then
					local curDurationIdx = frame.salebox.duration:GetValue()
					local duration = private.durations[curDurationIdx][1]
					deposit = deposit * duration/120
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

		if (curModel ~= "fixed" and newBuy > 0 and newBid > newBuy) then
			newBuy = newBid
		end

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
			AucAdvanced.Settings.GetSetting('util.appraiser.duration') or 1440
		for i=1, #private.durations do
			if (curDuration == private.durations[i][1]) then
				frame.salebox.duration:SetValue(i)
				break
			end
		end

		local curStack = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".stack") or frame.salebox.stacksize
		frame.salebox.stack:SetValue(curStack)
		frame.UpdateControls()
		local curNumber = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".number") or -1 
		frame.salebox.number:SetValue(curNumber)

		local curModel = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".model") or "default"
		frame.salebox.model.value = curModel
		frame.salebox.model:UpdateValue()
		frame.SetPriceFromModel(curModel)

		frame.UpdateControls()
		frame.salebox.config = nil
	end

	function frame.UpdateControls()
		if not frame.salebox.sig then
			frame.salebox.icon:Hide()
			frame.salebox.stack:Hide()
			frame.salebox.number:Hide()
			frame.salebox.model:Hide()
			frame.salebox.bid:Hide()
			frame.salebox.buy:Hide()
			frame.salebox.duration:Hide()
			frame.manifest:Hide()
			frame.refresh:Disable()
			frame.go:Disable()
			return
		end
		frame.salebox.icon:Show()
		frame.salebox.stack:Show()
		frame.salebox.number:Show()
		frame.salebox.model:Show()
		frame.salebox.bid:Show()
		frame.salebox.buy:Show()
		frame.salebox.duration:Show()
		frame.refresh:Enable()
		frame.manifest:Show()
		frame.manifest.lines:Clear()
		frame.manifest:SetFrameLevel(AuctionFrame:GetFrameLevel())

		local curDurationIdx = frame.salebox.duration:GetValue() or 3
		local curDurationMins = private.durations[curDurationIdx][1]
		local curDurationText = private.durations[curDurationIdx][2]
		frame.salebox.duration.label:SetText(("Duration: %s"):format(curDurationText))
		
		local curIgnore = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".ignore") or false
		frame.salebox.icon:GetNormalTexture():SetDesaturated(curIgnore)

		local curBid = frame.salebox.bid.modelvalue or 0
		local curBuy = frame.salebox.buy.modelvalue or 0

		local sig = frame.salebox.sig
		local totalBid, totalBuy, totalDeposit = 0,0,0
		local bidVal, buyVal, depositVal

		local depositMult = curDurationMins / 120
		local curNumber = frame.salebox.number:GetValue()

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

			local maxStax = math.floor(count / curSize)
			local fullPop = maxStax*curSize
			local remain = count - fullPop
			frame.salebox.number:SetMinMaxValues(-2, maxStax)
			if (curNumber >= -2 and curNumber < 0) then
				if (curNumber == -2) then
					frame.salebox.number.label:SetText(("Number: %s"):format(("All full stacks (%d) = %d"):format(maxStax, fullPop)))
				else
					frame.salebox.number.label:SetText(("Number: %s"):format(("All stacks (%d) plus %d = %d"):format(maxStax, remain, count)))
				end

				if (maxStax > 0) then
					frame.manifest.lines:Add(("%d lots of %dx stacks:"):format(maxStax, curSize))
					bidVal = lib.RoundBid(curBid * curSize)
					buyVal = lib.RoundBuy(curBuy * curSize)
					depositVal = AucAdvanced.Post.GetDepositAmount(sig, curSize) * depositMult
					frame.manifest.lines:Add(("  Bid for %dx"):format(curSize), bidVal)
					frame.manifest.lines:Add(("  Buyout for %dx"):format(curSize), buyVal)
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
					frame.manifest.lines:Add(("  Bid for %dx"):format(remain), bidVal)
					frame.manifest.lines:Add(("  Buyout for %dx"):format(remain), buyVal)
					frame.manifest.lines:Add(("  Deposit for %dx"):format(remain), depositVal)

					totalBid = totalBid + bidVal
					totalBuy = totalBuy + buyVal
					totalDeposit = totalDeposit + depositVal
				end
			elseif (curNumber == 0) then
				frame.salebox.number.label:SetText(("Number: %s"):format("|cffffee30"..("%d stacks = %d"):format(0,0)))
			else
				frame.salebox.number.label:SetText(("Number: %s"):format(("%d stacks = %d"):format(curNumber, curNumber*curSize)))
				frame.manifest.lines:Add(("%d lots of %dx stacks:"):format(curNumber, curSize))
				bidVal = lib.RoundBid(curBid * curSize)
				buyVal = lib.RoundBuy(curBuy * curSize)
				depositVal = AucAdvanced.Post.GetDepositAmount(sig, curSize) * depositMult
				frame.manifest.lines:Add(("  Bid for %dx"):format(curSize), bidVal)
				frame.manifest.lines:Add(("  Buyout for %dx"):format(curSize), buyVal)
				frame.manifest.lines:Add(("  Deposit for %dx"):format(curSize), depositVal)

				totalBid = totalBid + (bidVal * curNumber)
				totalBuy = totalBuy + (buyVal * curNumber)
				totalDeposit = totalDeposit + (depositVal * curNumber)
			end

		else
			frame.salebox.stack:SetMinMaxValues(1,1)
			frame.salebox.stack:SetValue(1)
			frame.salebox.stack.label:SetText("Item is not stackable")
			frame.salebox.stack:SetAlpha(0.6)
		
			frame.salebox.number:SetMinMaxValues(-1, frame.salebox.count)
			if (curNumber == -1) then
				curNumber = frame.salebox.count
				frame.salebox.number.label:SetText(("Number: %s"):format(("All items = %d"):format(curNumber)))
			elseif (curNumber == 0) then
				frame.salebox.number.label:SetText(("Number: %s"):format("|cffffee30"..("%d items"):format(0)))
			else
				frame.salebox.number.label:SetText(("Number: %s"):format(("%d items"):format(curNumber)))
			end

			if curNumber > 0 then
				frame.manifest.lines:Add(("%d items"):format(curNumber))
				bidVal = lib.RoundBid(curBid)
				buyVal = lib.RoundBuy(curBuy)
				depositVal = AucAdvanced.Post.GetDepositAmount(sig) * depositMult
				frame.manifest.lines:Add(("  Bid /item"), bidVal)
				frame.manifest.lines:Add(("  Buyout /item"), buyVal)
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

		if (totalBid < 1) then
			frame.manifest.lines:Add(("------------------------------"))
			frame.manifest.lines:Add(("Note: No auctionable items"))
			if (curNumber == 0) then
				frame.manifest.lines:Add(("Check |cffffffffNumber|r is more than 0"))
			end
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
		local curNumber = frame.salebox.number:GetValue()
		local curDurationIdx = frame.salebox.duration:GetValue()
		local curDuration = private.durations[curDurationIdx][1]
		AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".stack", curStack)
		AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".number", curNumber)
		AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".duration", curDuration)

		local curModel
		if (obj and obj.element == "model") then
			curModel = select(2, ...)
			frame.SetPriceFromModel(curModel)
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

	function frame.ToggleDisabled()
		if not frame.salebox.sig then return end
		local curDisable = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..frame.salebox.sig..".ignore") or false
		AucAdvanced.Settings.SetSetting('util.appraiser.item.'..frame.salebox.sig..".ignore", not curDisable)
		frame.GenerateList()
	end

	function frame.RefreshView()
		local link = frame.salebox.link
		local name, _, rarity, _, itemMinLevel, itemType, itemSubType, stack, equipLoc = GetItemInfo(link)
		local itemTypeId, itemSubId
		for catId, catName in pairs(AucAdvanced.Const.CLASSES) do
			if catName == itemType then
				itemTypeId = catId
				for subId, subName in pairs(AucAdvanced.Const.SUBCLASSES) do
					if subName == itemSubType then
						itemSubId = subId
						break
					end
				end
				break
			end
		end
		if equipLoc == "" then equipLoc = nil end
		
		AucAdvanced.Scan.PushScan()
		AucAdvanced.Scan.StartScan(name, itemMinLevel, itemMinLevel, equipLoc, itemTypeId, itemSubId, nil, rarity)
	end

	function frame.PostAuctions(obj)
		local postType = obj.postType
		if postType == "single" then
			frame.PostBySig(frame.salebox.sig)
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
		assert(duration and duration == 120 or duration == 480 or duration == 1440)
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
					if (bidVal > buyVal) then buyVal = bidVal end
					print((" - Queueing {{%d}} lots of {{%d}}"):format(fullStacks, stack))
					if dryRun then
						print(" -- Post: ", sig, stack, bidVal, buyVal, duration, fullStacks)
					else
						AucAdvanced.Post.PostAuction(sig, stack, bidVal, buyVal, duration, fullStacks)
					end
					
					totalBid = totalBid + (bidVal * fullStacks)
					totalBuy = totalBuy + (buyVal * fullStacks)
					totalNum = totalNum + (stack * fullStacks)
				end
				if (number == -1 and remain > 0) then
					bidVal = lib.RoundBid(itemBid * remain)
					buyVal = lib.RoundBuy(itemBuy * remain)
					if (bidVal > buyVal) then buyVal = bidVal end
					print((" - Queueing {{%d}} lots of {{%d}}"):format(1, remain))
					if dryRun then
						print(" -- Post: ", sig, remain, bidVal, buyVal, duration)
					else
						AucAdvanced.Post.PostAuction(sig, remain, bidVal, buyVal, duration)
					end
					
					totalBid = totalBid + bidVal
					totalBuy = totalBuy + buyVal
					totalNum = totalNum + remain
				end
			else
				bidVal = lib.RoundBid(itemBid * stack)
				buyVal = lib.RoundBuy(itemBuy * stack)
				if (bidVal > buyVal) then buyVal = bidVal end
				print((" - Queueing {{%d}} lots of {{%d}}"):format(number, stack))
				if dryRun then
					print(" -- Post: ", sig, stack, bidVal, buyVal, duration, number)
				else
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
			if (bidVal > buyVal) then buyVal = bidVal end
			print((" - Queueing {{%d}} items"):format(number))
			if dryRun then
				print(" -- Post: ", sig, 1, bidVal, buyVal, duration, number)
			else
				AucAdvanced.Post.PostAuction(sig, 1, bidVal, buyVal, duration, number)
			end
				
			totalBid = totalBid + (bidVal * number)
			totalBuy = totalBuy + (buyVal * number)
			totalNum = totalNum + number
		end

		print("-----------------------------------")
		print(("Queued up {{%d}} items"):format(totalNum))
		print(("Total minbid value: %s"):format(EnhTooltip.GetTextGSC(totalBid, true)))
		print(("Total buyout value: %s"):format(EnhTooltip.GetTextGSC(totalBuy, true)))
		print("-----------------------------------")
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

	frame.config = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.config:SetPoint("TOPLEFT", frame, "TOPLEFT", 100, -45)
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
	frame.salebox.icon:SetScript("OnClick", frame.ToggleDisabled)

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

	frame.salebox.warn = frame.salebox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.warn:SetPoint("BOTTOMLEFT", frame.salebox.slot, "BOTTOMRIGHT", 5,7)
	frame.salebox.warn:SetPoint("RIGHT", frame.salebox, "RIGHT", -10,0)
	frame.salebox.warn:SetHeight(12)
	frame.salebox.warn:SetTextColor(1, 0.3, 0.06)
	frame.salebox.warn:SetText("")
	frame.salebox.warn:SetJustifyH("RIGHT")
	frame.salebox.warn:SetJustifyV("BOTTOM")

	frame.salebox.note = frame.salebox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.note:SetPoint("TOPLEFT", frame.salebox.warn, "BOTTOMLEFT", 0,0)
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

	frame.salebox.duration.label = frame.salebox.duration:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.duration.label:SetPoint("LEFT", frame.salebox.duration, "RIGHT", 3,2)
	frame.salebox.duration.label:SetJustifyH("LEFT")
	frame.salebox.duration.label:SetJustifyV("CENTER")

	frame.salebox.model = nSelectBox:Create("AppraiserSaleboxModel", frame.salebox, 140, frame.ChangeControls, private.GetExtraPriceModels, "default")
	frame.salebox.model:SetPoint("TOPLEFT", frame.salebox.duration, "BOTTOMLEFT", 0,-16)
	frame.salebox.model.element = "model"
	frame.salebox.model:Hide()

	frame.salebox.model.label = frame.salebox.model:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.salebox.model.label:SetPoint("BOTTOMLEFT", frame.salebox.model, "TOPLEFT", 0,0)
	frame.salebox.model.label:SetText("Pricing model to use:")

	frame.salebox.bid = CreateFrame("Frame", "AppraiserSaleboxBid", frame.salebox, "MoneyInputFrameTemplate")
	frame.salebox.bid:SetPoint("TOP", frame.salebox.number, "BOTTOM", 0,-5)
	frame.salebox.bid:SetPoint("RIGHT", frame.salebox, "RIGHT", 0,0)
	MoneyInputFrame_SetOnvalueChangedFunc(frame.salebox.bid, frame.ChangeControls)
	frame.salebox.bid.element = "bid"
	frame.salebox.bid:Hide()

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
	frame.gobatch:Disable()

	frame.refresh = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.refresh:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -167,15)
	frame.refresh:SetText("Refresh")
	frame.refresh:SetWidth(80)
	frame.refresh:SetScript("OnClick", frame.RefreshView)
	frame.refresh:Disable()

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
	frame.manifest.close:SetScript("OnClick", function() frame.manifest:Hide() end)

	local function lineHide(obj)
		local id = obj.id
		local line = frame.manifest.lines[id]
		line[1]:Hide()
		line[2]:Hide()
	end

	local function lineSet(obj, text, coins)
		local id = obj.id
		local line = frame.manifest.lines[id]
		line[1]:SetText(text)
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

	local function linesAdd(obj, text, coins)
		obj.pos = obj.pos + 1
		if (obj.pos > obj.max) then return end
		obj[obj.pos]:Set(text, coins)
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
	
	frame.imageview.sheet = nScrollSheet:Create(frame.imageview, {
		{ "Item", "TEXT", 120 },
		{ "Seller", "TEXT", 75 },
		{ "Left", "INT", 40 },
		{ "Stk", "INT", 30 },
		{ "Min/ea", "COIN", 85 },
		{ "Cur/ea", "COIN", 85 },
		{ "Buy/ea", "COIN", 85 },
		{ "MinBid", "COIN", 85 },
		{ "CurBid", "COIN", 85 },
		{ "Buyout", "COIN", 85 },
	})
	
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
	hooksecurefunc("AuctionFrameTab_OnClick", frame.ScanTab.OnClick)
end



