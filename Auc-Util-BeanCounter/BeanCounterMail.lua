--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id: BeanCounterDB.lua 1326 2007-01-12 03:25:09Z kandoko $

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
local lib = AucAdvanced.Modules[libType][libName]
local private = lib.Private

local print = AucAdvanced.Print


function private.mailMonitor(event,arg1)
	if (event == "MAIL_SHOW") then
		private.updateInboxStart()  
	elseif (event == "MAIL_INBOX_UPDATE") then
		private.updateInboxCurrent(arg1)			
	elseif (event == "MAIL_CLOSED") then
		--Well we may need it
	end
end
--Mailbox Snapshots
function private.updateInboxStart()  
	private.inboxStart = {} 
	for n = 1,GetInboxNumItems() do
		local _, _, sender, subject, money, _, daysLeft, _, wasRead, _, _, _ = GetInboxHeaderInfo(n);
		wasRead = wasRead or 0 --its nil unless its has been read
		if sender and subject then 
				table.insert(private.inboxStart, n,  {["sender"]=sender, ["subject"]=subject,["money"]=money, ["read"]=wasRead, ["age"] = daysLeft})
		end
	end
end
function private.updateInboxCurrent(arg1)
	private.inboxCurrent = {}
	for n = 1,GetInboxNumItems() do
		local _, _, sender, subject, money, _, daysLeft, _, wasRead, _, _, _ = GetInboxHeaderInfo(n);
		wasRead = wasRead or 0 --its nil unless its has been read
		if sender and subject then
			table.insert(private.inboxCurrent, n,  {["index"] = n,["sender"]=sender, ["subject"]=subject,["money"]=money, ["read"]=wasRead, ["age"] = daysLeft})
		end
	end
	private.reconcile()
end

--Record the mailbox as we read the items
function private.reconcile() 
	if (#private.inboxStart) == (#private.inboxCurrent) then --if the tables are still the same size. then look at read state
		for i in ipairs(private.inboxStart) do
			if private.inboxStart[i]["read"] ~= private.inboxCurrent[i]["read"] then
				table.insert(private.reconcilePending, private.inboxCurrent[i])
				private.inboxStart[i]["read"] = 1 --Change our initial image to read
			end
		end
--Can probably Merge these 2 togather as if (#private.inboxStart) ~= (#inboxCurrent) 	
	elseif (#private.inboxStart) > (#private.inboxCurrent) then --ok, tables are now diffrent sizes, user must have opened a message
		private.updateInboxStart()
		private.updateInboxCurrent()
		
	elseif (#private.inboxStart) < (#private.inboxCurrent) then--ok user recived a message. Can this occur without (event == "MAIL_SHOW") fireing?
		private.updateInboxStart()  
	end

end


function private.getInvoice(n,sender, subject)
	if (sender == "Alliance Auction House") or (sender == "Horde Auction House") then
		if  "Auction successful: " == (string.match( subject , "(Auction successful:%s)" )) or "Auction won: " == (string.match( subject , "(Auction won:%s)" )) then
			local invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(n);
			if  playerName then
				private.debugPrint("getInvoice", invoiceType, itemName, playerName, bid, buyout, deposit, consignment, "yes")
				return invoiceType, itemName, playerName, bid, buyout, deposit, consignment, "yes"
			else
				private.debugPrint("getInvoice", invoiceType, itemName, playerName, bid, buyout, deposit, consignment, "no")
				return invoiceType, itemName, playerName, bid, buyout, deposit, consignment, "no"
			end
		end
	else
		return 
	end
return 
end

--Hook, take money event, if this still has an unretrieved invoice we delay X sec or invoice retrieved
function private.PreTakeInboxMoneyHook(funcArgs, retVal, index, ignore)
	if not ignore then
		for i,v in pairs(private.reconcilePending) do
			if (private.reconcilePending[i]["index"] == index) then --ok lets get the invoice
				table.insert(private.Task, {["MailboxIndex"] = private.reconcilePending[i]["index"], ["time"] = time(), ["PendingIndex"] = i,  ["task"] = "money"})
				return "abort"
			end
		end
	end
end
--Dang if we want data on auctions Won we need another hook on take item
--Hook, take item event, if this still has an unretrieved invoice we delay X sec or invoice retrieved
	    
function private.PreTakeInboxItemHook(funcArgs, retVal, index, ignore)
	if not ignore then
		for i,v in pairs(private.reconcilePending) do
			if (private.reconcilePending[i]["index"] == index) then --ok lets get the invoice
				table.insert(private.Task, {["MailboxIndex"] = private.reconcilePending[i]["index"], ["time"] = time(), ["PendingIndex"] = i, ["task"] = "item"})
				return "abort"
			end
		end
	end
end

--This is the task handler, if we have a paused item/money hook this processes it
function private.mailonUpdate()
	if (#private.Task > 0) then
		local i, index = private.Task[1]["PendingIndex"], private.Task[1]["MailboxIndex"]

		if (time() - private.Task[1]["time"] < 10) and private.reconcilePending[i]["retrieved"] ~= "yes" then
private.reconcilePending[i]["type"], private.reconcilePending[i]["itemName"], private.reconcilePending[i]["Seller/buyer"], private.reconcilePending[i]["bid"], private.reconcilePending[i]["buyout"], private.reconcilePending[i]["deposit"], private.reconcilePending[i]["fee"], private.reconcilePending[i]["retrieved"] = private.getInvoice(index, private.reconcilePending[i]["sender"],private.reconcilePending[i]["subject"])	
		else
			if private.reconcilePending[i]["retrieved"] == "no" then --we failed to get invoice 
				private.reconcilePending[i]["retrieved"] = "failed"
					end
			if private.Task[1]["task"] == "money" then 
				table.remove(private.Task,1)
				TakeInboxMoney(index, "ignore")
			else
				table.remove(private.Task,1)
				TakeInboxItem(index, "ignore")
			end
		end
	
	elseif (#private.reconcilePending > 0) then		
		private.mailSort()
	end
end

function private.mailSort()
	for i,v in ipairs(private.reconcilePending) do
		--Get Age of message for timestamp 
		local messageAgeInSeconds = math.floor((30 - private.reconcilePending[i]["age"]) * 24 * 60 * 60)
		
		private.reconcilePending[i]["time"] = (time() - messageAgeInSeconds)
		
		private.debugPrint("mail sort")
		
		if (private.reconcilePending[i]["sender"] == "Alliance Auction House") or (private.reconcilePending[i]["sender"] == "Horde Auction House") then
			if  "Auction successful: " == (string.match(private.reconcilePending[i]["subject"], "(Auction successful:%s)" )) and (private.reconcilePending[i]["retrieved"] == "yes" or private.reconcilePending[i]["retrieved"] == "failed") then
				private.debugPrint("Auction successful: ")
				--Get itemID from database
				local itemName = string.match(private.reconcilePending[i]["subject"], "Auction successful:%s(.*)" )
				local itemID = private.matchDB("postedAuctions", itemName)
				if itemID then
					local value = private.packString(itemName, "Auction successful", private.reconcilePending[i]["money"], private.reconcilePending[i]["deposit"], private.reconcilePending[i]["fee"], private.reconcilePending[i]["buyout"], private.reconcilePending[i]["bid"], private.reconcilePending[i]["Seller/buyer"], private.reconcilePending[i]["time"], private.wealth)
					private.databaseAdd("completedAuctions", itemID, value)
				end
				table.remove(private.reconcilePending,i)
				
			elseif "Auction expired: " == (string.match(private.reconcilePending[i]["subject"], "(Auction expired:%s)" )) then
				local itemName = string.match(private.reconcilePending[i]["subject"], "Auction expired:%s(.*)" )
				local itemID = private.matchDB("postedAuctions", itemName)
				if itemID then    
				--Do we want to insert nil values into the exp auc string to match length with comp auc string?
				--local value = private.packString(itemName, "Auction expired", _, _, _, _, _, _, private.reconcilePending[i]["time"], private.wealth)
					private.debugPrint("Auction Expired")
					local value = private.packString(itemName, "Auction expired", private.reconcilePending[i]["time"], private.wealth)
					private.databaseAdd("failedAuctions", itemID, value)
				end
				
				table.remove(private.reconcilePending,i)
			
			elseif "Auction won: " == (string.match(private.reconcilePending[i]["subject"], "(Auction won:%s)" )) and (private.reconcilePending[i]["retrieved"] == "yes" or private.reconcilePending[i]["retrieved"] == "failed") then
				
				private.debugPrint("Auction WON", private.reconcilePending[i]["retrieved"])
				local itemName = string.match(private.reconcilePending[i]["subject"], "Auction won:%s(.*)" )
				local itemID = private.matchDB("postedBids", itemName)
				--try to get itemID from bids, if not then buyouts. One of these DB MUST have it
				if not itemID then itemID = private.matchDB("postedBuyouts", itemName) end
				
				if itemID then
					private.debugPrint("Auction won: ", itemID)
					local value = private.packString(itemName, "Auction won", private.reconcilePending[i]["money"], private.reconcilePending[i]["deposit"], private.reconcilePending[i]["fee"], private.reconcilePending[i]["buyout"], private.reconcilePending[i]["bid"], private.reconcilePending[i]["Seller/buyer"], private.reconcilePending[i]["time"], private.wealth)				
					private.databaseAdd("completedBids/Buyouts", itemID, value)
				end				
				table.remove(private.reconcilePending,i)			
			
			elseif "Outbid on " == (string.match(private.reconcilePending[i]["subject"], "(Outbid on%s)" )) then
				private.debugPrint("Outbid on ")
				
				local itemName = string.match(private.reconcilePending[i]["subject"], "Outbid on%s(.*)" )
				local itemID = private.matchDB("postedBids", itemName)
				if itemID then
				
				local value = private.packString(itemName, "Outbid",private.reconcilePending[i]["money"], private.reconcilePending[i]["time"], private.wealth)
				private.databaseAdd("failedBids", itemID, value)
				end
				
				table.remove(private.reconcilePending,i)
						
			elseif "Sale Pending: " == (string.match(private.reconcilePending[i]["subject"], "(Sale Pending:%s)" )) then
                private.debugPrint("Sale Pending: " )	--ignore We dont care about this message
                table.remove(private.reconcilePending,i)
			end	
	
			else --if its not AH do we care? We need to record cash arrival from other toons
			private.debugPrint("OTHER", private.reconcilePending[i]["subject"])
			table.remove(private.reconcilePending,i)
		end
	end
end

--retrieves the itemID from the DB
function private.matchDB(key, text)
	for i,v in pairs(private.playerData[key]) do
		if private.playerData[key][i][1] then
			if text == (string.match(private.playerData[key][i][1], "(.-):" )) then
				private.debugPrint("private.matchDB",private.playerData[key][i][1])
				return i 
			end
		else 
		private.debugPrint("private.matchDB", key, text, "Failed")
			return nil
		end
	end
end



