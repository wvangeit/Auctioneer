--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/
	
	BeanCounteMail - Handles recording of all auction house related mail 

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
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

local lib = BeanCounter
local private = lib.Private
local print =  BeanCounter.Print
local _BC = private.localizations

local function debugPrint(...) 
    if private.getOption("util.beancounter.debugMail") then
        private.debugPrint("BeanCounterMail",...)
    end
end

function private.mailMonitor(event,arg1)
	if (event == "MAIL_INBOX_UPDATE") then
		private.updateInboxStart() 
	elseif (event == "MAIL_SHOW") then 
		private.inboxStart = {} --clear the inbox list, if we errored out this should give us a fresh start.
		hooksecurefunc("InboxFrame_OnClick", private.mailFrameClick)
		hooksecurefunc("InboxFrame_Update", private.mailFrameUpdate)
		--We cannot use mail show since the GetInboxNumItems() returns 0 till the first "MAIL_INBOX_UPDATE"
	elseif (event == "MAIL_CLOSED") then
		InboxCloseButton:Show()
		InboxFrame:Show()
		MailFrameTab2:Show()
		private.MailGUI:Hide()
	end
end

--Mailbox Snapshots
local HideMailGUI
function private.updateInboxStart()
	for n = 1,GetInboxNumItems() do
		local _, _, sender, subject, money, _, daysLeft, _, wasRead, _, _, _ = GetInboxHeaderInfo(n);
		if ((sender == _BC('MailAllianceAuctionHouse')) or (sender == _BC('MailHordeAuctionHouse'))) and subject and not wasRead then --record unread messages, so we know what indexes need to be added
			HideMailGUI = true
			wasRead = wasRead or 0 --its nil unless its has been read
			local invoiceType, itemName, playerName, bid, buyout, deposit, consignment, retrieved, startTime = private.getInvoice(n,sender, subject)
			table.insert(private.inboxStart, {["n"] = n,["sender"]=sender, ["subject"]=subject,["money"]=money, ["read"]=wasRead, ["age"] = daysLeft, 
					["invoiceType"] = invoiceType, ["itemName"] = itemName, ["Seller/buyer"] = playerName, ['bid'] = bid, ["buyout"] = buyout, 
					["deposit"] = deposit, ["fee"] = consignment, ["retrieved"] = retrieved, ["startTime"] = startTime
					})
			GetInboxText(n) --read message
		end
	end
	
	if HideMailGUI == true then
		debugPrint("MailFrame Hidden")
		InboxCloseButton:Hide()
		InboxFrame:Hide()
		MailFrameTab2:Hide()
		private.MailGUI:Show()
	end
	private.mailBoxColorStart()
end

function private.getInvoice(n,sender, subject)
	if (sender == _BC('MailAllianceAuctionHouse')) or (sender == _BC('MailHordeAuctionHouse')) then
		if  (string.match(subject, _BC('MailAuctionSuccessfulSubject')..".-:.-(%w.*)")) or (string.match( subject , _BC('MailAuctionWonSubject')..".-:.-(%w.*)")) then
			local invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(n);
			if  playerName then
				--debugPrint("getInvoice", invoiceType, itemName, playerName, bid, buyout, deposit, consignment, "yes")
				return invoiceType, itemName, playerName, bid, buyout, deposit, consignment, "yes", time()
			else
				--debugPrint("getInvoice", invoiceType, itemName, playerName, bid, buyout, deposit, consignment, "no")
				return invoiceType, itemName, playerName, bid, buyout, deposit, consignment, "no", time()
			end
		end
	else
		return 
	end
	return 
end

function private.mailonUpdate()
local count = 1
local total = #private.inboxStart
	for i,data in pairs(private.inboxStart) do
		--update mail GUI Count
		if count <= total then 
			private.CountGUI:SetText("Recording: "..count.." of "..total.." items")
			count = count + 1 
		end	
			
		local tbl = private.inboxStart[i]
		if not data.retrieved then --Send non invoiceable mails through
			table.insert(private.reconcilePending, data)
			private.inboxStart[i] = nil
			--debugPrint("not a invoice mail type")
		
		elseif  data.retrieved == "failed" then
			table.insert(private.reconcilePending, data)
			private.inboxStart[i] = nil
			--debugPrint("data.retrieved == failed")
		
		elseif  data.retrieved == "yes" then
			table.insert(private.reconcilePending, data)
			private.inboxStart[i] = nil
			--debugPrint("data.retrieved == yes")
		
		elseif  time() - data.startTime > private.getOption("util.beacounter.invoicetime") then --time exceded so fail it and process on next update
			debugPrint("time to retieve invoice exceded")
			tbl["retrieved"] = "failed, time to get invoice exceded" 
		else 
			--debugPrint("Invoice retieve attempt",tbl["subject"])
	tbl["invoiceType"], tbl["itemName"], tbl["Seller/buyer"], tbl['bid'], tbl["buyout"] , tbl["deposit"] , tbl["fee"], tbl["retrieved"], _ = private.getInvoice(data.n, data.sender, data.subject)
		end
	end
	if (#private.inboxStart == 0) and (HideMailGUI == true) then
		debugPrint("MailFrame Show")
		InboxCloseButton:Show()
		InboxFrame:Show()
		MailFrameTab2:Show()
		private.MailGUI:Hide()
		HideMailGUI = false
	end
	
	if (#private.reconcilePending > 0) then		
		private.mailSort()
	end
end

function private.mailSort()
	for i,v in ipairs(private.reconcilePending) do
		--Get Age of message for timestamp 
		local messageAgeInSeconds = math.floor((30 - private.reconcilePending[i]["age"]) * 24 * 60 * 60)
		
		private.reconcilePending[i]["time"] = (time() - messageAgeInSeconds)
		 
		--debugPrint("mail sort")
		
		if (private.reconcilePending[i]["sender"] == _BC('MailAllianceAuctionHouse')) or (private.reconcilePending[i]["sender"] == _BC('MailHordeAuctionHouse')) then
			if string.match(private.reconcilePending[i]["subject"], _BC('MailAuctionSuccessfulSubject')..".-:.*") and (private.reconcilePending[i]["retrieved"] == "yes" or private.reconcilePending[i]["retrieved"] == "failed") then
				debugPrint("Auction successful: ", i)
				--Get itemID from database
				local itemName = string.match(private.reconcilePending[i]["subject"], _BC('MailAuctionSuccessfulSubject')..".-:.-(%w.*)")
				local itemID, itemLink = private.matchDB("postedAuctions", itemName)
				if itemID then  --Get the Bid and stack size if possible
					local stack, bid = private.findStackcompletedAuctions("postedAuctions", itemID, private.reconcilePending[i]["deposit"], private.reconcilePending[i]["buyout"], private.reconcilePending[i]["time"]) 
					local value = private.packString(itemLink, "Auction successful", stack, private.reconcilePending[i]["money"], private.reconcilePending[i]["deposit"], private.reconcilePending[i]["fee"], private.reconcilePending[i]["buyout"], bid, private.reconcilePending[i]["Seller/buyer"], private.reconcilePending[i]["time"], private.wealth)
					private.databaseAdd("completedAuctions", itemID, value)
				end
				table.remove(private.reconcilePending, i)
				
			elseif string.match(private.reconcilePending[i]["subject"], _BC('MailAuctionExpiredSubject')..".-:.*")then
				local itemName = string.match(private.reconcilePending[i]["subject"], _BC('MailAuctionExpiredSubject')..".-:.-(%w.*)")
				local itemID, itemLink = private.matchDB("postedAuctions", itemName)
				if itemID then    
					local _, _, stackSecondary, _, _ = GetInboxItem(i)
					debugPrint("Auction Expired",i)
					local stack, buyout, bid, deposit = private.findStackfailedAuctions("postedAuctions", itemID, private.reconcilePending[i]["time"])
					local value = private.packString(itemLink, "Auction expired", stack or stackSecondary, buyout, bid, deposit, private.reconcilePending[i]["time"], private.wealth)
					private.databaseAdd("failedAuctions", itemID, value)
				end
				table.remove(private.reconcilePending,i)
			
			elseif string.match(private.reconcilePending[i]["subject"], _BC('MailAuctionWonSubject')..".-:.*") and (private.reconcilePending[i]["retrieved"] == "yes" or private.reconcilePending[i]["retrieved"] == "failed") then
				
				--debugPrint("Auction WON", private.reconcilePending[i]["retrieved"])
				local itemName = string.match(private.reconcilePending[i]["subject"], _BC('MailAuctionWonSubject')..".-:.-(%w.*)")
				local itemID, itemLink = private.matchDB("postedBids", itemName)
	
				--try to get itemID from bids, if not then buyouts. One of these DB MUST have it
				if not itemID then itemID, itemLink = private.matchDB("postedBuyouts", itemName) end
				
				if itemID and itemLink then
					debugPrint("Auction won: ", itemID)
					--For a Won Auction money, deposit, fee are always 0  so we can use them as placeholders for BeanCounter Data
					local stack = private.findStackcompletedBids(itemID, private.reconcilePending[i]["Seller/buyer"], private.reconcilePending[i]["buyout"], private.reconcilePending[i]["bid"], itemName)
					local value = private.packString(itemLink, "Auction won",stack, private.reconcilePending[i]["money"], private.reconcilePending[i]["fee"], private.reconcilePending[i]["buyout"], private.reconcilePending[i]["bid"], private.reconcilePending[i]["Seller/buyer"], private.reconcilePending[i]["time"], private.wealth)				
					private.databaseAdd("completedBids/Buyouts", itemID, value)
				end				
				table.remove(private.reconcilePending,i)			
			
			elseif string.match(private.reconcilePending[i]["subject"], _BC('MailOutbidOnSubject')..".-:.*") then
				debugPrint("Outbid on ")
				
				local itemName = string.match(private.reconcilePending[i]["subject"],_BC('MailOutbidOnSubject')..".-:.-(%w.*)")
				local itemID, itemLink = private.matchDB("postedBids", itemName)
				
				if itemID then
					local value = private.packString(itemLink, "Outbid",private.reconcilePending[i]["money"], private.reconcilePending[i]["time"], private.wealth)
					private.databaseAdd("failedBids", itemID, value)
				end
				 
				table.remove(private.reconcilePending,i)
			--Need localization			
			elseif string.match(private.reconcilePending[i]["subject"], "Sale Pending:.-:.*") then
				debugPrint("Sale Pending: " )	--ignore We dont care about this message
				table.remove(private.reconcilePending,i)
			else
				debugPrint("We had an Auction mail that failed mailsort() ")
				table.remove(private.reconcilePending,i)	
			end	
	
		else --if its not AH do we care? We need to record cash arrival from other toons
			debugPrint("OTHER", private.reconcilePending[i]["subject"])
			table.remove(private.reconcilePending,i)
				
		end
	end
end
--|cffffffff|Hitem:4238:0:0:0:0:0:0:801147302|h[Linen Bag]|h|r
--retrieves the itemID from the DB
function private.matchDB(key, text)
	local itemID = BeanCounterDB["ItemIDArray"][text:lower()] --All itemID array names are stored in lowercase ALWAYS use :lower() on any query
	if itemID and private.playerData[key][itemID] then
		for index = #private.playerData[key][itemID] , 1, -1 do
			if private.playerData[key][itemID][index]:find(text, 1, true) then
				local itemLink = private.playerData[key][itemID][index]:match("(.-);")
				debugPrint("Searching",key,"for",text,"Sucess: link is",itemLink)
				return itemID, itemLink
			end
		end
		--debugPrint("Searching", key,"for" ,text, "Item Name does not match any in this database")
	end
	debugPrint("Searching DB for ItemID..", key, text, "Failed ItemID does not exist")
	return nil
end
--Find the stack information in postedAuctions to add into the completedAuctions DB on mail arrivial
function private.findStackcompletedAuctions(key , itemID, soldDeposit, soldBuy, soldTime)
	local soldDeposit, soldBuy, soldTime , oldestPossible = tonumber(soldDeposit), tonumber(soldBuy),tonumber(soldTime), tonumber(soldTime - 173900)
	for index = #private.playerData[key][itemID] , 1, -1 do
		local tbl2 = private.unpackString(private.playerData[key][itemID][index])
		local postDeposit, postBuy, postTime = tonumber(tbl2[6]), tonumber(tbl2[4]),tonumber(tbl2[7])
		--if the deposits and buyouts match, check if time range would make this a possible match
		if postDeposit ==  soldDeposit and postBuy == soldBuy then
			if (soldTime > postTime) and (oldestPossible < postTime) then
				return tonumber(tbl2[2]), tonumber(tbl2[3])
			end
		end
	end
end
--find stack information from postedBids and postedBuyouts add into the completedBids/Buyouts table
function private.findStackcompletedBids(itemID, seller, buy, bid, itemName)
	local buy, bid = tonumber(buy),tonumber(bid)
	if private.playerData["postedBids"][itemID] then
		for index = #private.playerData["postedBids"][itemID] , 1, -1 do
			local tbl = private.unpackString(private.playerData["postedBids"][itemID][index])
			local stack, postBid, postSeller, Type = tonumber(tbl[2]), tonumber(tbl[3]), tbl[4], tbl[5]
			if seller ==  postSeller and postBid == bid and itemName == tbl[1]:match(".-%[(.-)%].-") then
				return stack
			end
		end
	end
	if private.playerData["postedBuyouts"][itemID] then
		for index = #private.playerData["postedBuyouts"][itemID] , 1, -1 do
			local tbl = private.unpackString(private.playerData["postedBuyouts"][itemID][index])
			local stack, postBuy, postSeller, Type = tonumber(tbl[2]), tonumber(tbl[3]), tbl[4], tbl[5]
			if seller ==  postSeller and postBuy == buy  and itemName == tbl[1]:match(".-%[(.-)%].-") then
				return stack
			end
		end
	end
	return 0 --failed to find stack
end
--find stack, bid and buy info for failedauctions
function private.findStackfailedAuctions(key, itemID, expiredTime)
	for index = #private.playerData[key][itemID], 1, -1 do
		local tbl2 = private.unpackString(private.playerData[key][itemID][index])
		local timeAuctionPosted, timeFailedAuctionStarted = tonumber(tbl2[7]), tonumber(expiredTime - (tbl2[5]*60)) --Time this message should have been posted
		if (timeAuctionPosted - 500) <= timeFailedAuctionStarted and timeFailedAuctionStarted <= (timeAuctionPosted + 500) then
			return tonumber(tbl2[2]), tonumber(tbl2[4]), tonumber(tbl2[3]), tonumber(tbl2[6])
		end
	end
end

--Hook, take money event, if this still has an unretrieved invoice we delay X sec or invoice retrieved
local inboxHookMessage = false --Stops spam of the message.
function private.PreTakeInboxMoneyHook(funcArgs, retVal, index, ignore)
	if #private.inboxStart > 0 and not inboxHookMessage then
		print("Please allow BeanCounter time to reconcile the mail box")
		inboxHookMessage = true
		return "abort"
	end
end

--Hook, take item event, if this still has an unretrieved invoice we delay X sec or invoice retrieved
function private.PreTakeInboxItemHook( ignore, retVal, index)
	if #private.inboxStart > 0 and not inboxHookMessage then
		print("Please allow BeanCounter time to reconcile the mail box")
		inboxHookMessage = true
		return "abort"
	end
end


--[[The below code manages the mailboxes Icon color /read/unread status]]--
function private.mailFrameClick(index)
	if BeanCounterDB[private.realmName][private.playerName]["mailbox"][index] then
		BeanCounterDB[private.realmName][private.playerName]["mailbox"][index]["read"] = 2
	end
end
function private.mailFrameUpdate()
--Change Icon back color if only addon read
if not BeanCounterDB[private.realmName][private.playerName]["mailbox"] then return end  --we havn't read mail yet
if private.getOption("util.beancounter.mailrecolor") == "off" then return end

	local numItems = GetInboxNumItems();
	local  index
	if (InboxFrame.pageNum * 7) < numItems then
		index = 7
	else
		index = 7 - ((InboxFrame.pageNum * 7) - numItems)
	end
	for i = 1,index do
		local button = getglobal("MailItem"..i.."Button")
		local buttonIcon = getglobal("MailItem"..i.."ButtonIcon")
		local senderText = getglobal("MailItem"..i.."Sender")
		local subjectText = getglobal("MailItem"..i.."Subject")
		button:Show()
			
		local itemindex = ((InboxFrame.pageNum * 7) - 7 + i) --this gives us the actual itemindex as oposed to teh 1-7 button index
		local _, _, sender, subject, money, _, daysLeft, _, wasRead, _, _, _ = GetInboxHeaderInfo(itemindex);
		if BeanCounterDB[private.realmName][private.playerName]["mailbox"][itemindex] then
			if (BeanCounterDB[private.realmName][private.playerName]["mailbox"][itemindex]["read"] < 2) then
				if private.getOption("util.beancounter.mailrecolor") == "icon" or private.getOption("util.beancounter.mailrecolor") == "both" then 
					getglobal("MailItem"..i.."ButtonSlot"):SetVertexColor(1.0, 0.82, 0)
					SetDesaturation(buttonIcon, nil)
				end
				if private.getOption("util.beancounter.mailrecolor") == "text" or private.getOption("util.beancounter.mailrecolor") == "both" then 
					senderText = getglobal("MailItem"..i.."Sender");senderText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
					subjectText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
				end
			end
		end
	end

end

local mailCurrent
local group = {["n"] = "", ["start"] = nil, ["end"] = nil} --stores the start and end locations for a group of same name items
function private.mailBoxColorStart()
	mailCurrent = {} --clean table every update
	
	for n = 1,GetInboxNumItems() do
		local _, _, sender, subject, money, _, daysLeft, _, wasRead, _, _, _ = GetInboxHeaderInfo(n);
		mailCurrent[n] = {["time"] = daysLeft ,["sender"] = sender, ["subject"] = subject, ["read"] = wasRead or 0 }
	end
	
	--Fix reported errors of mail DB not existing for some reason.
	if not BeanCounterDB[private.realmName][private.playerName]["mailbox"] then BeanCounterDB[private.realmName][private.playerName]["mailbox"] = {} end 
	--Create Characters Mailbox, or resync if we get more that 5 mails out of tune
	if #BeanCounterDB[private.realmName][private.playerName]["mailbox"] > (#mailCurrent+2) or #BeanCounterDB[private.realmName][private.playerName]["mailbox"] == 0 then
		debugPrint("Mail tables too far out of sync, resyncing #mailCurrent", #mailCurrent,"#mailData" ,#BeanCounterDB[private.realmName][private.playerName]["mailbox"])
		BeanCounterDB[private.realmName][private.playerName]["mailbox"] = {}
		for i, v in pairs(mailCurrent) do
			BeanCounterDB[private.realmName][private.playerName]["mailbox"][i] = v
		end
	end
	
	if #BeanCounterDB[private.realmName][private.playerName]["mailbox"] >= #mailCurrent then --mail removed or same
		for i in ipairs(mailCurrent) do 
			if BeanCounterDB[private.realmName][private.playerName]["mailbox"][i]["subject"] == group["n"] then
				if group["start"] then group["end"] = i else group["start"] = i end
			else
				group["n"], group["start"], group["end"] = BeanCounterDB[private.realmName][private.playerName]["mailbox"][i]["subject"], i, i
			end
			
			if mailCurrent[i]["subject"] ~= BeanCounterDB[private.realmName][private.playerName]["mailbox"][i]["subject"] then
				debugPrint("group = ",group["n"], group["start"], group["end"])
				if BeanCounterDB[private.realmName][private.playerName]["mailbox"][i]["read"] == 2 then
					debugPrint("This is marked read so removing ", i)
					table.remove(BeanCounterDB[private.realmName][private.playerName]["mailbox"], i)
					break
				elseif BeanCounterDB[private.realmName][private.playerName]["mailbox"][i]["read"] < 2 then
	--This message has not been read, so we have a sequence of messages with the same name. Need to go back recursivly till we find the "Real read" message that need removal
					for V = group["end"], group["start"], -1 do
						if BeanCounterDB[private.realmName][private.playerName]["mailbox"][V]["read"] == 2 then
							debugPrint("recursive read group",group["end"] ,"--",group["start"], "found read at",V )
							table.remove(BeanCounterDB[private.realmName][private.playerName]["mailbox"], V)
							break
						end
					end
				end
				break
			end
		end
	elseif #BeanCounterDB[private.realmName][private.playerName]["mailbox"] < #mailCurrent then --mail added
		for i,v in ipairs(mailCurrent) do
			if BeanCounterDB[private.realmName][private.playerName]["mailbox"][i] then
				if mailCurrent[i]["subject"] ~=  BeanCounterDB[private.realmName][private.playerName]["mailbox"][i]["subject"] then
					debugPrint("#private.mailData < #mailCurrent adding", i, mailCurrent[i]["subject"])
					table.insert(BeanCounterDB[private.realmName][private.playerName]["mailbox"], i, v)
				end
			else
			debugPrint("need to add key ", i)
				table.insert(BeanCounterDB[private.realmName][private.playerName]["mailbox"], i, v)
			end
		end
		
	end	
	private.mailFrameUpdate()
	private.hasUnreadMail()
end

function private.hasUnreadMail()
	--[[if HasNewMail() then MiniMapMailFrame:Show() debugPrint("We have real unread mail, mail icon show/hide code bypassed") return end  --no need to process if we have real unread messages waiting
	if not private.getOption("util.beancounter.mailrecolor") then MiniMapMailFrame:Hide() return end --no need to do this if user isn't using recolor system, and mail icon should not show since HasnewMail() failed

	local mailunread = false
	for i,v in pairs(BeanCounterDB[private.realmName][private.playerName]["mailbox"]) do
		if BeanCounterDB[private.realmName][private.playerName]["mailbox"][i]["read"] < 2 then
		    mailunread = true
		end
	end
	if mailunread then
		lib.SetSetting("util.beancounter.hasUnreadMail", true)
		MiniMapMailFrame:Show()
	else
		lib.SetSetting("util.beancounter.hasUnreadMail", false)
		MiniMapMailFrame:Hide()
	end]]
end