--[[
	BeanCounter Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	MailMonitor - Handles all mailbox interactions

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
--]]

-------------------------------------------------------------------------------
-- Function Imports
-------------------------------------------------------------------------------
local chatPrint = BeanCounter.ChatPrint;
local nilSafe = BeanCounter.NilSafe;

-------------------------------------------------------------------------------
-- Function Prototypes
-------------------------------------------------------------------------------
local addTask;
local processMailMessage;
local isSenderAuctionHouse;
local isSubjectAuctionExpired;
local isSubjectAuctionCancelled;
local isSubjectAuctionWon;
local isSubjectAuctionSuccessful;
local isSubjectOutbidOn;
local getItemNameFromSubject;
local reconcileDatabases;
local debugPrint;

local InboxTask_OnEvent;
local InboxTask_Execute;
local createWaitForInboxUpdateTask;
local WaitForInboxUpdate_OnEvent;
local createWaitForTakeInboxItem;
local WaitForTakeInboxItem_OnEvent;
local createWaitForTakeInboxMoney;
local WaitForTakeInboxMoney_OnEvent;
local createWaitForDeleteInboxItem;
local WaitForDeleteInboxItem_OnEvent;
local createWaitForInvoiceTask;
local WaitForInvoiceTask_OnEvent;
local createWaitForReadMessage;
local WaitForReadMessage_OnEvent;
local createProcessMessageTask;
local ProcessMessageTask_Execute;
local createTakeInboxMoneyTask;
local TakeInboxMoneyTask_Execute;
local createTakeInboxItemTask;
local TakeInboxItemTask_Execute;

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
local MAX_DAYS_LEFT = 30; -- Maximum number of days left for an unread message

-------------------------------------------------------------------------------
-- Local variables
-------------------------------------------------------------------------------
local InboxTasks = {};
local LastMailCount = 0;
local MailDownloaded = false;
local MailDownloadTime = nil;
local MailBacklog = false;

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
local MAX_INBOX_MESSAGES = 50;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function MailMonitor_OnLoad()
	-- Hook all the methods we need!
	Stubby.RegisterFunctionHook("TakeInboxItem", -100, MailMonitor_PreTakeInboxItemHook);
	Stubby.RegisterFunctionHook("TakeInboxMoney", -100, MailMonitor_PreTakeInboxMoneyHook);
	Stubby.RegisterFunctionHook("GetInboxText", -100, MailMonitor_PreGetInboxTextHook);
	Stubby.RegisterFunctionHook("GetInboxText", 100, MailMonitor_PostGetInboxTextHook);
	Stubby.RegisterFunctionHook("DeleteInboxItem", -100, MailMonitor_DeleteInboxItemHook);
	
	-- Register for the events we need!
	Stubby.RegisterEventHook("MAIL_INBOX_UPDATE", "BeanCounter_MailMonitor", MailMonitor_OnEventHook);
	Stubby.RegisterEventHook("UI_ERROR_MESSAGE", "BeanCounter_MailMonitor", MailMonitor_OnEventHook);
	Stubby.RegisterEventHook("MAIL_SHOW", "BeanCounter_MailMonitor", MailMonitor_OnEventHook);
	Stubby.RegisterEventHook("MAIL_CLOSED", "BeanCounter_MailMonitor", MailMonitor_OnEventHook);
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function MailMonitor_OnEventHook(_, event, arg1)
	debugPrint(event);
	
	-- Check if we satisfied an event task.
	if (table.getn(InboxTasks) > 0) then
		local task = InboxTasks[1];
		table.remove(InboxTasks, 1);
		if (task:OnEvent(event, arg1)) then
			debugPrint("Satisfied event task: "..task.name);
		else
			table.insert(InboxTasks, 1, task);
		end
	end

	-- Check if we've got function tasks to perform.
	local executed = true;
	while (table.getn(InboxTasks) > 0 and executed) do
		local task = InboxTasks[1];
		table.remove(InboxTasks, 1);
		executed = task:Execute();
		if (executed) then
			debugPrint("Executed task: "..task.name);
		else
			table.insert(InboxTasks, 1, task);
		end
	end

	-- Reconcilation management.
	if (event == "MAIL_SHOW") then
		LastMailCount = GetInboxNumItems();
		MailDownloaded = false;
		MailDownloadTime = nil;
	elseif (event == "MAIL_INBOX_UPDATE") then
		local count = GetInboxNumItems();
		if (count > LastMailCount) then
			MailDownloaded = true;
			MailDownloadTime = time();
			MailBacklog = (count == MAX_INBOX_MESSAGES);
			if (MailBacklog) then
				debugPrint("Mail downloaded from server at "..date("%c", MailDownloadTime).." ("..count.." messages - backlog)");
			else
				debugPrint("Mail downloaded from server at "..date("%c", MailDownloadTime).." ("..count.." messages)");
			end			
		end
		LastMailCount = count;
	elseif (event == "MAIL_CLOSED") then
		if (MailDownloaded and MailDownloadTime ~= nil and not MailBacklog) then
			reconcileDatabases(MailDownloadTime);
		end
		MailDownloaded = false;
		MailDownloadTime = nil;
	end
end

-------------------------------------------------------------------------------
-- Hooks taking items from messages.
-------------------------------------------------------------------------------
function MailMonitor_PreTakeInboxItemHook(funcArgs, retVal, index)
	debugPrint("MailMonitor_PreTakeInboxItemHook("..nilSafe(index)..") called");

	-- Allow this method call if there is no pending tasks.
	if (index ~= nil and index > 0 and table.getn(InboxTasks) == 0) then
		-- Read the message, before allowing the TakeInboxItem() call.
		local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply = GetInboxHeaderInfo(index);
		if (not wasRead and isSenderAuctionHouse(sender)) then
			GetInboxText(index);
		end

		-- If there are pending tasks, we must delay the execution of
		-- TakeInboxItem().
		if (table.getn(InboxTasks) > 0) then
			-- Queue a task for taking the inbox item.
			addTask(createTakeInboxItemTask(index));

			-- Abort the execution of TakeInboxItem() for now...
			debugPrint("Delaying TakeInboxItem() call");
			return "abort";
		else
			-- Wait for the item to be taken.
			addTask(createWaitForTakeInboxItem(index));
		end
	else
		debugPrint("Ignoring TakeInboxItem() call");
		return "abort";
	end
end

-------------------------------------------------------------------------------
-- Hooks taking money from messages.
-------------------------------------------------------------------------------
function MailMonitor_PreTakeInboxMoneyHook(funcArgs, retVal, index)
	debugPrint("MailMonitor_PreTakeInboxMoneyHook("..nilSafe(index)..") called");

	-- Allow this method call if there is no pending action.
	if (index ~= nil and index > 0 and table.getn(InboxTasks) == 0) then
		-- Read the message, before allowing the TakeInboxMoney() call.
		local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply = GetInboxHeaderInfo(index);
		if (not wasRead and isSenderAuctionHouse(sender)) then
			GetInboxText(index);
		end
			
		-- If there are pending tasks, we must delay the execution of
		-- TakeInboxMoney().
		if (table.getn(InboxTasks) > 0) then
			-- Queue a task for taking the inbox money.
			addTask(createTakeInboxMoneyTask(index));

			-- Abort the execution of TakeInboxMoney() for now...
			debugPrint("Delaying TakeInboxMoney() call");
			return "abort";
		else
			-- Wait for the money to be taken.
			addTask(createWaitForTakeInboxMoney(index));
		end
	else
		debugPrint("Ignoring TakeInboxMoney() call");
		return "abort";
	end
end

-------------------------------------------------------------------------------
-- Hooks before reading a message.
-------------------------------------------------------------------------------
local getInboxTextRecursionLevel = 0;
local messageWasRead = true;
local messageDaysLeft = 0;
function MailMonitor_PreGetInboxTextHook(funcArgs, retVal, index)
	debugPrint("MailMonitor_PreGetInboxTextHook("..nilSafe(index)..") called");

	-- The GetInboxText is called re-entrantly in some cases. We only care
	-- about the first (outermost) call.
	getInboxTextRecursionLevel = getInboxTextRecursionLevel + 1;
	if (index > 0 and index <= GetInboxNumItems() and getInboxTextRecursionLevel == 1) then
		-- Check if we are reading the message for the first time. If so, this
		-- results in in an immediate client side MAIL_INBOX_UPDATE event to change
		-- the message to read.
		local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply = GetInboxHeaderInfo(index);
		messageWasRead = wasRead;
		messageDaysLeft = daysLeft;
		if (not messageWasRead) then
			-- Queue a task for marking the message as read. We add this to the
			-- front of the queue since its a client side operation.
			addTask(createWaitForReadMessage(index), true);
		end
	end
end

-------------------------------------------------------------------------------
-- Hooks after reading a message.
-------------------------------------------------------------------------------
function MailMonitor_PostGetInboxTextHook(funcArgs, retVal, index)
	debugPrint("MailMonitor_PostGetInboxTextHook("..nilSafe(index)..") called");

	-- We are only interested in unread messages.
	getInboxTextRecursionLevel = getInboxTextRecursionLevel - 1;
	if (index ~= nil and index > 0 and index <= GetInboxNumItems() and getInboxTextRecursionLevel == 0 and not messageWasRead) then
		local isInvoice = retVal[4];

		-- If this task has an invoice, get it.
		if (isInvoice) then
			-- Wait for the invoice if we don't have it yet.
			local invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(index);
			if (not playerName) then
				addTask(createWaitForInvoiceTask(index));
			end
		end

		-- Process the message.
		local messageAgeInSeconds = math.floor((MAX_DAYS_LEFT - messageDaysLeft) * 24 * 60 * 60);
		if (table.getn(InboxTasks) > 0) then
			addTask(createProcessMessageTask(index, messageAgeInSeconds));
		else
			processMailMessage(index, messageAgeInSeconds);
		end

		-- Consider the message read now.
		messageWasRead = true;
	end
end

-------------------------------------------------------------------------------
-- Hooks deleting a message.
-------------------------------------------------------------------------------
function MailMonitor_DeleteInboxItemHook(funcArgs, retVal, index)
	debugPrint("MailMonitor_DeleteInboxItemHook("..nilSafe(index)..") called");
end

-------------------------------------------------------------------------------
-- Adds a task.
-------------------------------------------------------------------------------
function addTask(task, front)
	if (front) then
		debugPrint("Added task to front: "..task.name);
		table.insert(InboxTasks, 1, task);
	else
		debugPrint("Added task to back: "..task.name);
		table.insert(InboxTasks, task);
	end
end

-------------------------------------------------------------------------------
-- Hooks reading a message.
-------------------------------------------------------------------------------
function processMailMessage(index, messageAgeInSeconds)
	if (index > 0) then
		debugPrint("Processing message "..index);
		local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply = GetInboxHeaderInfo(index);
		if (sender and isSenderAuctionHouse(sender)) then
			local timestamp = (time() - messageAgeInSeconds);
			debugPrint("Message "..index.." was from an auction house (delivered at "..date("%c", timestamp)..")");
			if (isSubjectAuctionSuccessful(subject) and money) then
				local itemName = getItemNameFromSubject(subject);
				debugPrint("Message "..index.." is an auction successful message: "..nilSafe(itemName));
				if (itemName) then
					-- Get the invoice info, which may or may not be present
					-- depending on if it was fetched from the server.
					local invoiceType, _, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(index);
					local isBuyout = nil;
					if (bid ~= nil and buyout ~= nil) then
						isBuyout = (bid == buyout);
					end
					debugPrint("Auction Successful: "..
						itemName..", "..
						nilSafe(nil)..", "..
						nilSafe(invoiceType)..", "..
						nilSafe(playerName)..", "..
						nilSafe(bid)..", "..
						nilSafe(buyout)..", "..
						nilSafe(deposit)..", "..
						nilSafe(consignment));
					BeanCounter.Sales.AddSuccessfulAuction(timestamp, itemName, money, bid, (bid == buyout), deposit, consignment, playerName);
				end
			elseif (isSubjectAuctionExpired(subject) and hasItem) then
				local itemName, _, itemCount = GetInboxItem(index);
				debugPrint("Message "..index.." is an auction expired message: "..nilSafe(itemName).. ", "..nilSafe(itemCount));
				if (itemName and itemCount) then
					debugPrint("Auction Expired: "..
						itemName..", "..
						nilSafe(itemCount));
					BeanCounter.Sales.AddExpiredAuction(timestamp, itemName, itemCount);
				end
			elseif (isSubjectAuctionCancelled(subject) and hasItem) then
				local itemName, _, itemCount = GetInboxItem(index);
				debugPrint("Message "..index.." is an auction cancelled message: "..nilSafe(itemName).. ", "..nilSafe(itemCount));
				if (itemName and itemCount) then
					debugPrint("Auction Cancelled: "..
						itemName..", "..
						nilSafe(itemCount));
					BeanCounter.Sales.AddExpiredAuction(timestamp, itemName, itemCount);
				end
			elseif (isSubjectAuctionWon(subject) and hasItem) then
				local itemName, _, itemCount = GetInboxItem(index);
				debugPrint("Message "..index.." is an auction won message: "..nilSafe(itemName).. ", "..itemCount);
				if (itemName and itemCount) then
					-- Get the invoice info, which may or may not be present
					-- depending on if it was fetched from the server.
					local invoiceType, _, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(index);
					local isBuyout = nil;
					if (bid ~= nil and buyout ~= nil) then
						isBuyout = (bid == buyout);
					end
					debugPrint("Auction Won: "..
						itemName..", "..
						itemCount..", "..
						nilSafe(invoiceType)..", "..
						nilSafe(playerName)..", "..
						nilSafe(bid)..", "..
						nilSafe(buyout)..", "..
						nilSafe(deposit)..", "..
						nilSafe(consignment));
					BeanCounter.Purchases.AddSuccessfulBid(timestamp, itemName, itemCount, bid, playerName, isBuyout);
				end
			elseif (isSubjectOutbidOn(subject) and money) then
				local itemName = getItemNameFromSubject(subject);
				debugPrint("Message "..index.." is an auction lost message: "..nilSafe(itemName).. ", "..money);
				if (itemName and money) then
					debugPrint("Out bid on: "..
						itemName..", "..
						nilSafe(money));
					BeanCounter.Purchases.AddFailedBid(timestamp, itemName, money);
				end
			elseif (isSubjectAuctionCancelled(subject) and money) then
				local itemName = getItemNameFromSubject(subject);
				debugPrint("Message "..index.." is an auction canceled message: "..nilSafe(itemName).. ", "..money);
				if (itemName and money) then
					debugPrint("Auction Cancelled: "..
						itemName..", "..
						nilSafe(money));
					BeanCounter.Purchases.AddFailedBid(timestamp, itemName, money);
				end
			else
				debugPrint("Unknown subject: "..subject);
			end
		else
			debugPrint("Message "..index.." was not from an auction house ("..nilSafe(sender)..")");
		end
	end
end

-------------------------------------------------------------------------------
-- Checks if the sender is the auction house
-------------------------------------------------------------------------------
function isSenderAuctionHouse(sender)
	return (sender and (sender == _BC('MailAllianceAuctionHouse') or sender == _BC('MailHordeAuctionHouse')));
end

-------------------------------------------------------------------------------
-- Functions that check the subject
-------------------------------------------------------------------------------
function isSubjectAuctionExpired(subject)
	return (string.find(subject, "^".._BC('MailAuctionExpiredSubject')..": .*") ~= nil);
end

function isSubjectAuctionCancelled(subject)
	return (string.find(subject, "^".._BC('MailAuctionCancelledSubject')..": .*") ~= nil);
end

function isSubjectAuctionWon(subject)
	return (string.find(subject, "^".._BC('MailAuctionWonSubject')..": .*") ~= nil);
end

function isSubjectAuctionSuccessful(subject)
	return (string.find(subject, "^".._BC('MailAuctionSuccessfulSubject')..": .*") ~= nil);
end

function isSubjectOutbidOn(subject)
	return (string.find(subject, "^".._BC('MailOutbidOnSubject')..": .*") ~= nil);
end

-------------------------------------------------------------------------------
-- Gets the item name from the subject
-------------------------------------------------------------------------------
function getItemNameFromSubject(subject)
	local itemName = nil;
	if (isSubjectAuctionExpired(subject)) then
		_, _, itemName = string.find(subject, "^".._BC('MailAuctionExpiredSubject')..": (.*)");
	elseif (isSubjectAuctionCancelled(subject)) then
		_, _, itemName = string.find(subject, "^".._BC('MailAuctionCancelledSubject')..": (.*)");
	elseif (isSubjectAuctionWon(subject)) then
		_, _, itemName = string.find(subject, "^".._BC('MailAuctionWonSubject')..": (.*)");
	elseif (isSubjectAuctionSuccessful(subject)) then
		_, _, itemName = string.find(subject, "^".._BC('MailAuctionSuccessfulSubject')..": (.*)");
	elseif (isSubjectOutbidOn(subject)) then
		_, _, itemName = string.find(subject, "^".._BC('MailOutbidOnSubject')..": (.*)");
	end
	return itemName;
end

-------------------------------------------------------------------------------
-- Reconcile the purchase and sale databases. This should only be called when
-- we know that all pending mail is currently in the inbox. In otherwords there
-- is no server backlog of messages nor any pending messages yet to arrive in
-- the inbox.
-------------------------------------------------------------------------------
function reconcileDatabases(reconcileTime)
	debugPrint("reconcileDatabases("..date("%c", reconcileTime)..") called");

	-- Tally up the number of pending e-mails in the inbox for each item. We
	-- only care about unread messages since the read messages have already
	-- been processed.
	local pendingBidsForItem = {};
	local pendingSalesForItem = {};
	for index = 1, GetInboxNumItems() do
		local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply = GetInboxHeaderInfo(index);
		if (not wasRead and sender and isSenderAuctionHouse(sender)) then
			if (isSubjectAuctionSuccessful(subject) and money) then
				local itemName = getItemNameFromSubject(subject);
				pendingSalesForItem[itemName] = true;
			elseif (isSubjectAuctionExpired(subject) and hasItem) then
				local itemName = GetInboxItem(index);
				pendingSalesForItem[itemName] = true;
			elseif (isSubjectAuctionCancelled(subject) and hasItem) then
				local itemName = GetInboxItem(index);
				pendingSalesForItem[itemName] = true;
			elseif (isSubjectAuctionWon(subject) and hasItem) then
				local itemName = GetInboxItem(index);
				pendingBidsForItem[itemName] = true;
			elseif (isSubjectOutbidOn(subject) and money) then
				local itemName = getItemNameFromSubject(subject);
				pendingBidsForItem[itemName] = true;
			elseif (isSubjectAuctionCancelled(subject) and money) then
				local itemName = getItemNameFromSubject(subject);
				pendingBidsForItem[itemName] = true;
			end
		end
	end

	-- Perform the sales database reconcilation.
	local reconciled, pendingDiscarded, completedDiscarded = BeanCounter.Sales.ReconcileAuctions(reconcileTime, pendingSalesForItem);
	if (reconciled > 0 or pendingDiscarded > 0) then
		chatPrint("Reconciled "..reconciled.." auctions ("..pendingDiscarded.. " discrepencies)");
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function debugPrint(message)
	BeanCounter.DebugPrint("[BeanCounter.MailMonitor] "..message);
end

-------------------------------------------------------------------------------
-- InboxTask::OnEvent
-------------------------------------------------------------------------------
function InboxTask_OnEvent(this, event)
	return false;
end

-------------------------------------------------------------------------------
-- InboxTask::Execute
-------------------------------------------------------------------------------
function InboxTask_Execute(this)
	return false;
end

-------------------------------------------------------------------------------
-- WaitForInboxUpdate constructor
-------------------------------------------------------------------------------
function createWaitForInboxUpdateTask()
	local task = {};
	task.name = "WaitForInboxUpdate";
	task.OnEvent = WaitForInboxUpdate_OnEvent;
	task.Execute = InboxTask_Execute;
	return task;
end

-------------------------------------------------------------------------------
-- WaitForInboxUpdate::OnEvent
-------------------------------------------------------------------------------
function WaitForInboxUpdate_OnEvent(this, event)
	local satisfied = false;
	if (event == "MAIL_INBOX_UPDATE") then
		satisfied = true;
	end
	return satisfied;
end

-------------------------------------------------------------------------------
-- WaitForTakeInboxItem constructor
-------------------------------------------------------------------------------
function createWaitForTakeInboxItem(index)
	local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply = GetInboxHeaderInfo(index);
	local task = {};
	task.index = index;
	task.isSenderAH = isSenderAuctionHouse(sender);
	task.name = "WaitForTakeInboxItem";
	task.OnEvent = WaitForTakeInboxItem_OnEvent;
	task.Execute = InboxTask_Execute;
	return task;
end

-------------------------------------------------------------------------------
-- WaitForTakeInboxItem::OnEvent
-------------------------------------------------------------------------------
function WaitForTakeInboxItem_OnEvent(this, event, arg1)
	local satisfied = false;
	if (event == "MAIL_INBOX_UPDATE") then
		-- TODO: Verify that the item was looted.
		satisfied = true;
		-- If the message was from the AH, it will be deleted automatically.
		if (this.isSenderAH) then
			addTask(createWaitForDeleteInboxItem(this.index), true);
		end
	elseif (event == "UI_ERROR_MESSAGE" and arg1) then
		-- Check for errors in taking the inbox item.
		if (arg1 == ERR_ITEM_MAX_COUNT or arg1 == ERR_INV_FULL) then
			satisfied = true;
		end
	end
	return satisfied;
end

-------------------------------------------------------------------------------
-- WaitForTakeInboxMoney constructor
-------------------------------------------------------------------------------
function createWaitForTakeInboxMoney(index)
	local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply = GetInboxHeaderInfo(index);
	local task = {};
	task.index = index;
	task.isSenderAH = isSenderAuctionHouse(sender);
	task.name = "WaitForTakeInboxMoney";
	task.OnEvent = WaitForTakeInboxMoney_OnEvent;
	task.Execute = InboxTask_Execute;
	return task;
end

-------------------------------------------------------------------------------
-- WaitForTakeInboxMoney::OnEvent
-------------------------------------------------------------------------------
function WaitForTakeInboxMoney_OnEvent(this, event)
	local satisfied = false;
	if (event == "MAIL_INBOX_UPDATE") then
		-- TODO: Verify that the money was looted.
		satisfied = true;
		-- If the message was from the AH, it will be deleted automatically.
		if (this.isSenderAH) then
			addTask(createWaitForDeleteInboxItem(this.index), true);
		end
	end
	return satisfied;
end

-------------------------------------------------------------------------------
-- WaitForDeleteInboxItem constructor
-------------------------------------------------------------------------------
function createWaitForDeleteInboxItem(index)
	local task = {};
	task.index = index;
	task.targetMessageCount = GetInboxNumItems() - 1;
	task.name = "WaitForDeleteInboxItem";
	task.OnEvent = WaitForDeleteInboxItem_OnEvent;
	task.Execute = InboxTask_Execute;
	return task;
end

-------------------------------------------------------------------------------
-- WaitForDeleteInboxItem::OnEvent
-------------------------------------------------------------------------------
function WaitForDeleteInboxItem_OnEvent(this, event)
	local satisfied = false;
	if (event == "MAIL_INBOX_UPDATE") then
		--  Check if the message was deleted
		satisfied = (this.targetMessageCount == GetInboxNumItems());
	end
	return satisfied;
end

-------------------------------------------------------------------------------
-- WaitForInvoiceTask constructor
-------------------------------------------------------------------------------
function createWaitForInvoiceTask(index)
	local task = {};
	task.index = index;
	task.name = "WaitForInvoiceTask";
	task.OnEvent = WaitForInvoiceTask_OnEvent;
	task.Execute = InboxTask_Execute;
	return task;
end

-------------------------------------------------------------------------------
-- WaitForInvoiceTask::OnEvent
-------------------------------------------------------------------------------
function WaitForInvoiceTask_OnEvent(this, event)
	local satisfied = false;
	if (event == "MAIL_INBOX_UPDATE") then
		local invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(this.index);
		if (playerName) then
			satisfied = true;
		end
	end
	return satisfied;
end

-------------------------------------------------------------------------------
-- WaitForReadMessage constructor
-------------------------------------------------------------------------------
function createWaitForReadMessage(index)
	local task = {};
	task.index = index;
	task.name = "WaitForReadMessage";
	task.OnEvent = WaitForReadMessage_OnEvent;
	task.Execute = InboxTask_Execute;
	return task;
end

-------------------------------------------------------------------------------
-- WaitForReadMessage::OnEvent
-------------------------------------------------------------------------------
function WaitForReadMessage_OnEvent(this, event)
	local satisfied = false;
	if (event == "MAIL_INBOX_UPDATE") then
		local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply = GetInboxHeaderInfo(this.index);
		if (wasRead) then
			satisfied = true;
		end
	end
	return satisfied;
end

-------------------------------------------------------------------------------
-- ProcessMessageTask constructor
-------------------------------------------------------------------------------
function createProcessMessageTask(index, messageAgeInSeconds)
	local task = {};
	task.index = index;
	task.messageAgeInSeconds = messageAgeInSeconds;
	task.name = "ProcessMessageTask";
	task.OnEvent = InboxTask_OnEvent;
	task.Execute = ProcessMessageTask_Execute;
	return task;
end

-------------------------------------------------------------------------------
-- ProcessMessageTask::Execute
-------------------------------------------------------------------------------
function ProcessMessageTask_Execute(this)
	processMailMessage(this.index, this.messageAgeInSeconds);
	return true;
end

-------------------------------------------------------------------------------
-- TakeInboxMoneyTask constructor
-------------------------------------------------------------------------------
function createTakeInboxMoneyTask(index)
	local task = {};
	task.index = index;
	task.name = "TakeInboxMoneyTask";
	task.OnEvent = InboxTask_OnEvent;
	task.Execute = TakeInboxMoneyTask_Execute;
	return task;
end

-------------------------------------------------------------------------------
-- TakeInboxMoneyTask::Execute
-------------------------------------------------------------------------------
function TakeInboxMoneyTask_Execute(this)
	TakeInboxMoney(this.index);
	return true;
end

-------------------------------------------------------------------------------
-- TakeInboxItemTask constructor
-------------------------------------------------------------------------------
function createTakeInboxItemTask(index)
	local task = {};
	task.index = index;
	task.name = "TakeInboxItemTask";
	task.OnEvent = InboxTask_OnEvent;
	task.Execute = TakeInboxItemTask_Execute;
	return task;
end

-------------------------------------------------------------------------------
-- TakeInboxItemTask::Execute
-------------------------------------------------------------------------------
function TakeInboxItemTask_Execute(this)
	TakeInboxItem(this.index);
	return true;
end


