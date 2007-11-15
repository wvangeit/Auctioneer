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

local libName = "BeanCounter"
local libType = "Util"
local lib = BeanCounter
local private = lib.Private
local print =  BeanCounter.Print

local debugPrint 

local function debugPrint(...) 
    if private.getOption("util.beancounter.debugMail") then
        private.debugPrint("BeanCounterMail",...)
    end
end

function private.mailMonitor(event,arg1)
	if (event == "MAIL_INBOX_UPDATE") then
		private.updateInboxStart() 
	elseif (event == "MAIL_SHOW") then 
	hooksecurefunc("InboxFrame_OnClick", private.mailFrameClick)
	hooksecurefunc("InboxFrame_Update", private.mailFrameUpdate)
		--We cannot use mail show since the GetInboxNumItems() returns 0 till the first "MAIL_INBOX_UPDATE"
	elseif (event == "MAIL_CLOSED") then
		InboxCloseButton:Show()
		InboxFrame:Show()
		MailFrameTab2:Show()
		private.MailGUI:Hide()
		HideMailGUI = false
	end
end

--Mailbox Snapshots
local HideMailGUI = false
function private.updateInboxStart()
	for n = 1,GetInboxNumItems() do
		local _, _, sender, subject, money, _, daysLeft, _, wasRead, _, _, _ = GetInboxHeaderInfo(n);
		if sender and subject and not wasRead then --record unread messages, so we know what indexes need to be added
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
		InboxCloseButton:Hide()
		InboxFrame:Hide()
		MailFrameTab2:Hide()
		private.MailGUI:Show()
	end
	private.mailBoxReadStart()
end

function private.getInvoice(n,sender, subject)
	if (sender == "Alliance Auction House") or (sender == "Horde Auction House") then
		if  "Auction successful: " == (string.match( subject , "(Auction successful:%s)" )) or "Auction won: " == (string.match( subject , "(Auction won:%s)" )) then
			local invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(n);
			if  playerName then
				debugPrint("getInvoice", invoiceType, itemName, playerName, bid, buyout, deposit, consignment, "yes")
				return invoiceType, itemName, playerName, bid, buyout, deposit, consignment, "yes", time()
			else
				debugPrint("getInvoice", invoiceType, itemName, playerName, bid, buyout, deposit, consignment, "no")
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
			debugPrint("not a invoice mail type")
		
		elseif  data.retrieved == "failed" then
			table.insert(private.reconcilePending, data)
			private.inboxStart[i] = nil
			debugPrint("data.retrieved == failed")
		
		elseif  data.retrieved == "yes" then
			table.insert(private.reconcilePending, data)
			private.inboxStart[i] = nil
			debugPrint("data.retrieved == yes")
		
		elseif  time() - data.startTime > private.getOption("util.beacounter.invoicetime") then --time exceded so fail it and process on next update
			debugPrint("time to retieve invoice exceded")
			tbl["retrieved"] = "failed" 
		else 
			debugPrint("Invoice retieve attempt",tbl["subject"])
	tbl["invoiceType"], tbl["itemName"], tbl["Seller/buyer"], tbl['bid'], tbl["buyout"] , tbl["deposit"] , tbl["fee"], tbl["retrieved"], _ = private.getInvoice(data.n, data.sender, data.subject)
		end
	end
	
	if (#private.reconcilePending > 0) then		
		private.mailSort()
	end
	
	if (#private.inboxStart == 0) and (HideMailGUI == true) then
		InboxCloseButton:Show()
		InboxFrame:Show()
		MailFrameTab2:Show()
		private.MailGUI:Hide()
		HideMailGUI = false
	end
	
end

function private.mailSort()
	for i,v in ipairs(private.reconcilePending) do
		--Get Age of message for timestamp 
		local messageAgeInSeconds = math.floor((30 - private.reconcilePending[i]["age"]) * 24 * 60 * 60)
		
		private.reconcilePending[i]["time"] = (time() - messageAgeInSeconds)
		
		--debugPrint("mail sort")
		
		if (private.reconcilePending[i]["sender"] == "Alliance Auction House") or (private.reconcilePending[i]["sender"] == "Horde Auction House") then
			if  "Auction successful: " == (string.match(private.reconcilePending[i]["subject"], "(Auction successful:%s)" )) and (private.reconcilePending[i]["retrieved"] == "yes" or private.reconcilePending[i]["retrieved"] == "failed") then
				debugPrint("Auction successful: ")
				--Get itemID from database
				local itemName = string.match(private.reconcilePending[i]["subject"], "Auction successful:%s(.*)" )
				local itemID, itemLink = private.matchDB("postedAuctions", itemName)
				if itemID then
					local value = private.packString(itemLink, "Auction successful", private.reconcilePending[i]["money"], private.reconcilePending[i]["deposit"], private.reconcilePending[i]["fee"], private.reconcilePending[i]["buyout"], private.reconcilePending[i]["bid"], private.reconcilePending[i]["Seller/buyer"], private.reconcilePending[i]["time"], private.wealth)
					private.databaseAdd("completedAuctions", itemID, value)
				end
				table.remove(private.reconcilePending,i)
				
			elseif "Auction expired: " == (string.match(private.reconcilePending[i]["subject"], "(Auction expired:%s)" )) then
				local itemName = string.match(private.reconcilePending[i]["subject"], "Auction expired:%s(.*)" )
				local itemID, itemLink = private.matchDB("postedAuctions", itemName)
				if itemID then    
				--Do we want to insert nil values into the exp auc string to match length with comp auc string?
				--local value = private.packString(itemName, "Auction expired", _, _, _, _, _, _, private.reconcilePending[i]["time"], private.wealth)
					debugPrint("Auction Expired")
					local value = private.packString(itemLink, "Auction expired", private.reconcilePending[i]["time"], private.wealth)
					private.databaseAdd("failedAuctions", itemID, value)
				end
				
				table.remove(private.reconcilePending,i)
			
			elseif "Auction won: " == (string.match(private.reconcilePending[i]["subject"], "(Auction won:%s)" )) and (private.reconcilePending[i]["retrieved"] == "yes" or private.reconcilePending[i]["retrieved"] == "failed") then
				
				debugPrint("Auction WON", private.reconcilePending[i]["retrieved"])
				local itemName = string.match(private.reconcilePending[i]["subject"], "Auction won:%s(.*)" )
				local itemID, itemLink = private.matchDB("postedBids", itemName)
	
				--try to get itemID from bids, if not then buyouts. One of these DB MUST have it
				if not itemID then itemID = private.matchDB("postedBuyouts", itemName) end
				
				if itemID then
				local  _, itemLink = private.getItemInfo(itemID, "itemid") 
					debugPrint("Auction won: ", itemID)
					local value = private.packString(itemLink, "Auction won", private.reconcilePending[i]["money"], private.reconcilePending[i]["deposit"], private.reconcilePending[i]["fee"], private.reconcilePending[i]["buyout"], private.reconcilePending[i]["bid"], private.reconcilePending[i]["Seller/buyer"], private.reconcilePending[i]["time"], private.wealth)				
					private.databaseAdd("completedBids/Buyouts", itemID, value)
				end				
				table.remove(private.reconcilePending,i)			
			
			elseif "Outbid on " == (string.match(private.reconcilePending[i]["subject"], "(Outbid on%s)" )) then
				debugPrint("Outbid on ")
				
				local itemName = string.match(private.reconcilePending[i]["subject"], "Outbid on%s(.*)" )
				local itemID, itemLink = private.matchDB("postedBids", itemName)
				if itemID then
				
				local value = private.packString(itemLink, "Outbid",private.reconcilePending[i]["money"], private.reconcilePending[i]["time"], private.wealth)
				private.databaseAdd("failedBids", itemID, value)
				end
				
				table.remove(private.reconcilePending,i)
						
			elseif "Sale Pending: " == (string.match(private.reconcilePending[i]["subject"], "(Sale Pending:%s)" )) then
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
	for i,v in pairs(private.playerData[key]) do
		if private.playerData[key][i][1] then
			if text == (string.match(private.playerData[key][i][1], "^|c%x+|H.+|h%[(.+)%]" )) then
			    local itemLink = private.playerData[key][i][1]:match("(.-);")
				--debugPrint("Searching DB for ItemID..",private.playerData[key][i][1], "Sucess")
				return i, itemLink
			else
				--debugPrint("Searching DB for ItemID..", key, text, "Item Name does not match")
			end
		else 
				--debugPrint("Searching DB for ItemID..", key, text, "Failed")
			return nil
		end
	end
end

--Hook, take money event, if this still has an unretrieved invoice we delay X sec or invoice retrieved
function private.PreTakeInboxMoneyHook(funcArgs, retVal, index, ignore)
	if #private.inboxStart > 0 then
		print("Please allow BeanCounter time to reconcile the mail box")
		return "abort"
	end
	table.remove(BeanCounterDB[private.realmName][private.playerName]["mailbox"], i)
end

--Hook, take item event, if this still has an unretrieved invoice we delay X sec or invoice retrieved
function private.PreTakeInboxItemHook( ignore, retVal, index)
	if #private.inboxStart > 0 then
		print("Please allow BeanCounter time to reconcile the mail box")
		return "abort"
	end
	table.remove(BeanCounterDB[private.realmName][private.playerName]["mailbox"], i)
end


--[[The below code manages the mailboxes Icon color /rad/unread status]]--
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
			
		local itemindex = ((InboxFrame.pageNum * 7) - 7 +i) --this gives us the actual itemindex as oposed to teh 1-7 button index
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
function private.mailBoxReadStart()
	mailCurrent = {} --clean table every update
	
	for n = 1,GetInboxNumItems() do
		local _, _, sender, subject, money, _, daysLeft, _, wasRead, _, _, _ = GetInboxHeaderInfo(n);
		mailCurrent[n] = {["time"] = daysLeft ,["sender"] = sender, ["subject"] = subject, ["read"] = wasRead or 0 }
	end
		

	if #BeanCounterDB[private.realmName][private.playerName]["mailbox"] > (#mailCurrent+1) or #BeanCounterDB[private.realmName][private.playerName]["mailbox"] == 0 then
		debugPrint("Mail tables too far out of sync, resyncing #mailCurrent", #mailCurrent,"#mailData" ,#BeanCounterDB[private.realmName][private.playerName]["mailbox"])
		BeanCounterDB[private.realmName][private.playerName]["mailbox"] = {}
		for i, v in pairs(mailCurrent) do
			BeanCounterDB[private.realmName][private.playerName]["mailbox"][i] = v
		end
			
	--[[ lets try using our mail delet hooks to know the exact index to remove.This may solve the items with same name inherit the deleted color
	elseif #private.mailData > #mailCurrent then --mail was deleted  
		for i,v in ipairs(private.mailData) do
			if not mailCurrent[i] then
				debugPrint("#private.mailData > #mailCurrent removing non existant", i, private.mailData[i]["subject"])
				table.remove(private.mailData, i)
			elseif mailCurrent[i]["subject"] ~= private.mailData[i]["subject"] then
				debugPrint("#private.mailData > #mailCurrent removing", i, private.mailData[i]["subject"])
				table.remove(private.mailData, i)
			end
		end]]
	elseif #BeanCounterDB[private.realmName][private.playerName]["mailbox"] <= #mailCurrent then --mail was added
		for i,v in ipairs(mailCurrent) do
			if BeanCounterDB[private.realmName][private.playerName]["mailbox"][i] then
				if mailCurrent[i]["subject"] ~=  BeanCounterDB[private.realmName][private.playerName]["mailbox"][i]["subject"] then
					debugPrint("#private.mailData < #mailCurrent adding", i, mailCurrent[i]["subject"])
					table.insert(BeanCounterDB[private.realmName][private.playerName]["mailbox"], i, v)
				end
			else
			--debugPrint("need to add key ", i)
			--table.insert(BeanCounterDB[private.realmName][private.playerName]["mailbox"], i, v)
			end
		end
	end
		
	private.mailFrameUpdate()
end

