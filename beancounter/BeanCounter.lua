--[[
	BeanCounter Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	BeanCounter - trackes AH purchases and sales

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
-- Constants
-------------------------------------------------------------------------------
-- Auction houses (TODO: Make these localized strings)
ALLIANCE_AUCTION_HOUSE = "Alliance Auction House";
HORDE_AUCTION_HOUSE = "Horde Auction House";

-- Auction house subjects (TODO: Make these localized strings)
AUCTION_EXPIRED = "Auction expired: ";
AUCTION_CANCELLED = "Auction cancelled: ";
AUCTION_WON = "Auction won: ";
AUCTION_SUCCESSFUL = "Auction successful: ";
OUTBID_ON = "Outbid on ";

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local InboxTasks = {};

-------------------------------------------------------------------------------
-- Version
-------------------------------------------------------------------------------
BeanCounter = {};
BeanCounter.Version="<%version%>";
if (BeanCounter.Version == "<".."%version%>") then
	BeanCounter.Version = "3.3.DEV";
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function BeanCounter_OnLoad()
	-- Unhook some boot triggers if necessary.
	-- These might not exist on initial loading or if an addon depends on BeanCounter
	if (BeanCounter_CheckLoad) then
		Stubby.UnregisterFunctionHook("AuctionFrame_LoadUI", BeanCounter_CheckLoad);
		Stubby.UnregisterFunctionHook("CheckInbox", BeanCounter_CheckLoad);
	end
	if (BeanCounter_ShowNotLoaded) then
		Stubby.UnregisterFunctionHook("AuctionFrame_Show", BeanCounter_ShowNotLoaded);
	end

	-- Register our temporary command hook with stubby
	Stubby.RegisterBootCode("BeanCounter", "CommandHandler", [[
		local function cmdHandler(msg)
			local i,j, cmd, param = string.find(string.lower(msg), "^([^ ]+) (.+)$")
			if (not cmd) then cmd = string.lower(msg) end
			if (not cmd) then cmd = "" end
			if (not param) then param = "" end
			if (cmd == "load") then
				if (param == "") then
					Stubby.Print("Manually loading BeanCounter...")
					LoadAddOn("BeanCounter")
				elseif (param == "auctionhouse") then
					Stubby.Print("Setting BeanCounter to load when this character visits the auction house or mailbox")
					Stubby.SetConfig("BeanCounter", "LoadType", param)
				elseif (param == "always") then
					Stubby.Print("Setting BeanCounter to always load for this character")
					Stubby.SetConfig("BeanCounter", "LoadType", param)
					LoadAddOn("BeanCounter")
				elseif (param == "never") then
					Stubby.Print("Setting BeanCounter to never load automatically for this character (you may still load manually)")
					Stubby.SetConfig("BeanCounter", "LoadType", param)
				else
					Stubby.Print("Your command was not understood")
				end
			else
				Stubby.Print("BeanCounter is currently not loaded.")
				Stubby.Print("  You may load it now by typing |cffffffff/BeanCounter load|r")
				Stubby.Print("  You may also set your loading preferences for this character by using the following commands:")
				Stubby.Print("  |cffffffff/BeanCounter load auctionhouse|r - BeanCounter will load when you visit the auction house or mailbox")
				Stubby.Print("  |cffffffff/BeanCounter load always|r - BeanCounter will always load for this character")
				Stubby.Print("  |cffffffff/BeanCounter load never|r - BeanCounter will never load automatically for this character (you may still load it manually)")
			end
		end
		SLASH_BEANCOUNTER1 = "/beancounter"
		SLASH_BEANCOUNTER2 = "/bean"
		SLASH_BEANCOUNTER3 = "/bc"
		SlashCmdList["BEANCOUNTER"] = cmdHandler
	]]);
	Stubby.RegisterBootCode("BeanCounter", "Triggers", [[
		function BeanCounter_CheckLoad()
			local loadType = Stubby.GetConfig("BeanCounter", "LoadType")
			if (loadType == "auctionhouse" or not loadType) then
				LoadAddOn("BeanCounter")
			end
		end
		function BeanCounter_ShowNotLoaded()
		end
		local function onLoaded()
			Stubby.UnregisterAddOnHook("Blizzard_AuctionUI", "BeanCounter")
			if (not IsAddOnLoaded("BeanCounter")) then
				Stubby.RegisterFunctionHook("AuctionFrame_Show", 100, BeanCounter_ShowNotLoaded)
			end
		end
		Stubby.RegisterFunctionHook("AuctionFrame_LoadUI", 100, BeanCounter_CheckLoad)
		Stubby.RegisterFunctionHook("CheckInbox", 100, BeanCounter_CheckLoad);
		Stubby.RegisterAddOnHook("Blizzard_AuctionUI", "BeanCounter", onLoaded)
		local loadType = Stubby.GetConfig("BeanCounter", "LoadType")
		if (loadType == "always") then
			LoadAddOn("BeanCounter")
		else
			Stubby.Print("BeanCounter is not loaded. Type /beancounter for more info.");
		end
	]]);
	
	-- Register for notification of us being loaded.
	this:RegisterEvent("ADDON_LOADED");
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function BeanCounter_AddOnLoaded()
	debugPrint("BeanCounter_AddOnLoaded() called");

	-- Create a database version if one doesn't already exist.
	if (not AHPurchases.version) then AHPurchases.version = 30000; end
	
	-- Blizzard's auction UI may or may not have been loaded yet.
	if (IsAddOnLoaded("Blizzard_AuctionUI")) then
		BeanCounter_AuctionHouseLoaded();
	end
	
	-- Hook all the methods we need!
	Stubby.RegisterFunctionHook("TakeInboxItem", -100, BeanCounter_PreTakeInboxItemHook);
	Stubby.RegisterFunctionHook("TakeInboxMoney", -100, BeanCounter_PreTakeInboxMoneyHook);
	Stubby.RegisterFunctionHook("GetInboxText", -100, BeanCounter_PreGetInboxTextHook);
	Stubby.RegisterFunctionHook("GetInboxText", 100, BeanCounter_PostGetInboxTextHook);
	Stubby.RegisterFunctionHook("DeleteInboxItem", -100, BeanCounter_DeleteInboxItemHook);
	
	-- Register for the vents we need!
	this:RegisterEvent("MAIL_INBOX_UPDATE");
	this:RegisterEvent("BAG_UPDATE");
	this:RegisterEvent("UI_ERROR_MESSAGE");
	
	-- Hello world!
	chatPrint(string.format("BeanCounter v%s loaded", BeanCounter.Version));
	
	-- Fixes to work around CT_MailMod problems
	if (CT_MMForward_oldTakeInboxItem ~= nil) then
		CT_MMForward_oldTakeInboxItem = TakeInboxItem;
	end
	if (CT_MMForward_oldTakeInboxMoney ~= nil) then
		CT_MMForward_oldTakeInboxMoney = TakeInboxMoney;
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function BeanCounter_AuctionHouseLoaded()
	debugPrint("BeanCounter_AuctionHouseLoaded() called");

	-- Find the index of the first unused AuctionHouse tab
	local tabIndex = 1;
	while (getglobal("AuctionFrameTab"..tabIndex) ~= nil) do
		tabIndex = tabIndex + 1;
	end

	-- Add the Transactions tab
	AuctionFrameTransactions:SetParent("AuctionFrame")
	AuctionFrameTransactions:SetPoint("TOPLEFT", "AuctionFrame", "TOPLEFT", 0, 0)
	relevel(AuctionFrameTransactions);
	setglobal("AuctionFrameTab"..tabIndex, AuctionFrameTabTransactions);
	AuctionFrameTabTransactions:SetParent("AuctionFrame")
	debugPrint("AuctionFrameTab"..(tabIndex - 1));
	debugPrint(getglobal("AuctionFrameTab"..(tabIndex - 1)):GetName());

	AuctionFrameTabTransactions:SetPoint("TOPLEFT", getglobal("AuctionFrameTab"..(tabIndex - 1)):GetName(), "TOPRIGHT", -8, 0)
	AuctionFrameTabTransactions:SetID(tabIndex);
	AuctionFrameTabTransactions:Show();

	-- Tell the AuctionFrame that we've added tabs
	PanelTemplates_SetNumTabs(AuctionFrame, tabIndex)

	-- Hook the tab click method so we know when to show our tab.
	Stubby.RegisterFunctionHook("AuctionFrameTab_OnClick", 200, BeanCounter_AuctionFrameTab_OnClickHook)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function BeanCounter_OnEvent(event, arg1)
	debugPrint(event);
	
	if (event == "ADDON_LOADED") then
		debugPrint(arg1);
		if (string.lower(arg1) == "beancounter") then
			BeanCounter_AddOnLoaded();
		elseif (string.lower(arg1) == "blizzard_auctionui") then
			BeanCounter_AuctionHouseLoaded();
		end
	else
		-- Check if we satisfied an event task.
		if (table.getn(InboxTasks) > 0) then
			local task = InboxTasks[1];
			table.remove(InboxTasks, 1);
			if (task:OnEvent(event)) then
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
	end
end

-------------------------------------------------------------------------------
-- Hooks Blizzard's AuctionFrameTab_OnClick() method.
-------------------------------------------------------------------------------
function BeanCounter_AuctionFrameTab_OnClickHook(_, _, index)
	if (not index) then
		index = this:GetID();
	end

	-- Hide our tabs
	AuctionFrameTransactions:Hide();
	
	-- Show an Auctioneer tab if its the one clicked
	local tab = getglobal("AuctionFrameTab"..index);
	if (tab) then
		if (tab:GetName() == "AuctionFrameTabTransactions") then
			AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopLeft");
			AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Top");
			AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopRight");
			AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotLeft");
			AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Bot");
			AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotRight");
			AuctionFrameTransactions:Show();
		end
	end
end

-------------------------------------------------------------------------------
-- Hooks taking items from messages.
-------------------------------------------------------------------------------
function BeanCounter_PreTakeInboxItemHook(funcArgs, retVal, index)
	debugPrint("BeanCounter_PreTakeInboxItemHook("..index..") called");

	-- Allow this method call if there is no pending tasks.
	if (index > 0 and table.getn(InboxTasks) == 0) then
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
function BeanCounter_PreTakeInboxMoneyHook(funcArgs, retVal, index)
	debugPrint("BeanCounter_PreTakeInboxMoneyHook("..index..") called");

	-- Allow this method call if there is no pending action.
	if (index > 0 and table.getn(InboxTasks) == 0) then
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
function BeanCounter_PreGetInboxTextHook(funcArgs, retVal, index)
	debugPrint("BeanCounter_PreGetInboxTextHook("..index..") called");

	-- The GetInboxText is called re-entrantly in some cases. We only care
	-- about the first (outermost) call.
	getInboxTextRecursionLevel = getInboxTextRecursionLevel + 1;
	if (index > 0 and index <= GetInboxNumItems() and getInboxTextRecursionLevel == 1) then
		-- Check if we are reading the message for the first time. If so, this
		-- results in in an immediate client side MAIL_INBOX_UPDATE event to change
		-- the message to read.
		local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply = GetInboxHeaderInfo(index);
		messageWasRead = wasRead;
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
function BeanCounter_PostGetInboxTextHook(funcArgs, retVal, index)
	debugPrint("BeanCounter_PostGetInboxTextHook("..index..") called");

	-- We are only interested in unread messages.
	getInboxTextRecursionLevel = getInboxTextRecursionLevel - 1;
	if (index > 0 and index <= GetInboxNumItems() and getInboxTextRecursionLevel == 0 and not messageWasRead) then
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
		if (table.getn(InboxTasks) > 0) then
			addTask(createProcessMessageTask(index));
		else
			processMailMessage(index);
		end

		-- Consider the message read now.
		messageWasRead = true;
	end
end

-------------------------------------------------------------------------------
-- Hooks deleting a message.
-------------------------------------------------------------------------------
function BeanCounter_DeleteInboxItemHook(funcArgs, retVal, index)
	debugPrint("BeanCounter_DeleteInboxItemHook("..index..") called");
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
function processMailMessage(index)
	if (index > 0) then
		debugPrint("Processing message "..index);
		local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply = GetInboxHeaderInfo(index);
		if (sender and isSenderAuctionHouse(sender)) then
			debugPrint("Message "..index.." was from an auction house");
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
					debugPrint("Auction Successful: "..itemName..", <nil>, "..nilSafe(invoiceType)..", "..nilSafe(playerName)..", "..nilSafe(bid)..", "..nilSafe(buyout)..", "..nilSafe(deposit)..", "..nilSafe(consignment));
					-- TODO: Add to sales database
				end
			elseif (isSubjectAuctionExpired(subject) and hasItem) then
				local itemName, _, itemCount = GetInboxItem(index);
				debugPrint("Message "..index.." is an auction expired message: "..nilSafe(itemName).. ", "..nilSafe(itemCount));
				if (itemName and itemCount) then
					-- TODO: Add to sales database
				end
			elseif (isSubjectAuctionCancelled(subject) and hasItem) then
				local itemName, _, itemCount = GetInboxItem(index);
				debugPrint("Message "..index.." is an auction expired message: "..nilSafe(itemName).. ", "..nilSafe(itemCount));
				if (itemName and itemCount) then
					-- TODO: Add to sales database
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
					debugPrint("Auction Won: "..itemName..", "..itemCount..", "..nilSafe(invoiceType)..", "..nilSafe(playerName)..", "..nilSafe(bid)..", "..nilSafe(buyout)..", "..nilSafe(deposit)..", "..nilSafe(consignment));
					BeanCounter.Purchases.AddSuccessfulBid(itemName, itemCount, bid, playerName, isBuyout);
				end
			elseif (isSubjectOutbidOn(subject) and money) then
				local itemName = getItemNameFromSubject(subject);
				debugPrint("Message "..index.." is an auction lost message: "..nilSafe(itemName).. ", "..money);
				if (itemName and money) then
					BeanCounter.Purchases.AddFailedBid(itemName, money);
				end
			elseif (isSubjectAuctionCancelled(subject) and money) then
				local itemName = getItemNameFromSubject(subject);
				debugPrint("Message "..index.." is an auction canceled message: "..nilSafe(itemName).. ", "..money);
				if (itemName and money) then
					BeanCounter.Purchases.AddFailedBid(itemName, money);
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
	return (sender and (sender == ALLIANCE_AUCTION_HOUSE or sender == HORDE_AUCTION_HOUSE));
end

-------------------------------------------------------------------------------
-- Functions that check the subject
-------------------------------------------------------------------------------
function isSubjectAuctionExpired(subject)
	return (strfind(subject, AUCTION_EXPIRED));
end

function isSubjectAuctionCancelled(subject)
	return (strfind(subject, AUCTION_CANCELLED));
end

function isSubjectAuctionWon(subject)
	return (strfind(subject, AUCTION_WON));
end

function isSubjectAuctionSuccessful(subject)
	return (strfind(subject, AUCTION_SUCCESSFUL));
end

function isSubjectOutbidOn(subject)
	return (strfind(subject, OUTBID_ON));
end

-------------------------------------------------------------------------------
-- Gets the item name from the subject
-------------------------------------------------------------------------------
function getItemNameFromSubject(subject)
	local itemName = nil;
	if (strfind(subject, AUCTION_EXPIRED)) then
		itemName = strsub(subject, strfind(subject, AUCTION_EXPIRED) + strlen(AUCTION_EXPIRED));
	elseif (strfind(subject, AUCTION_CANCELLED)) then
		itemName = strsub(subject, strfind(subject, AUCTION_CANCELLED) + strlen(AUCTION_CANCELLED));
	elseif (strfind(subject, AUCTION_WON)) then
		itemName = strsub(subject, strfind(subject, AUCTION_WON) + strlen(AUCTION_WON));
	elseif (strfind(subject, AUCTION_SUCCESSFUL)) then
		itemName = strsub(subject, strfind(subject, AUCTION_SUCCESSFUL) + strlen(AUCTION_SUCCESSFUL));
	elseif (strfind(subject, OUTBID_ON)) then
		itemName = strsub(subject, strfind(subject, OUTBID_ON) + strlen(OUTBID_ON));
	end
	return itemName;
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function relevel(frame)
	local myLevel = frame:GetFrameLevel() + 1
	local children = { frame:GetChildren() }
	for _,child in pairs(children) do
		child:SetFrameLevel(myLevel)
		relevel(child)
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function nilSafe(string)
	if (string) then
		return string;
	end
	return "<nil>";
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function chatPrint(...)
	if (DEFAULT_CHAT_FRAME) then 
		local msg = ""
		for i=1, table.getn(arg) do
			if i==1 then msg = arg[i]
			else msg = msg.." "..arg[i]
			end
		end
		DEFAULT_CHAT_FRAME:AddMessage(msg, 1.0, 0.35, 0.15)
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
debugPrint = EnhTooltip.DebugPrint;




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
function createProcessMessageTask(index)
	local task = {};
	task.index = index;
	task.name = "ProcessMessageTask";
	task.OnEvent = InboxTask_OnEvent;
	task.Execute = ProcessMessageTask_Execute;
	return task;
end

-------------------------------------------------------------------------------
-- ProcessMessageTask::Execute
-------------------------------------------------------------------------------
function ProcessMessageTask_Execute(this)
	processMailMessage(this.index);
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


