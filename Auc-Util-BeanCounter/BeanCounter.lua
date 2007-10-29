--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	BeanCounterCore - BeanCounter: Auction House History
	URL: http://auctioneeraddon.com/
	
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

AucAdvanced.Modules[libType][libName] = {}
local lib = AucAdvanced.Modules[libType][libName]
--[[todo
add monitoring of Vendor Sells/Buys to track expeditures
add ability to track wealth over time /per toon or server...
]]
local private = {
	--BeanCounterCore
	playerName = UnitName("player"),
	realmName = GetRealmName(), 
	faction, _ = UnitFactionGroup(UnitName("player")),
	version = 1.02,
	wealth, --This characters current net worth. This will be appended to each transaction.
	playerData, --Alias for BeanCounterDB[private.realmName][private.playerName]
	serverData, --Alias for BeanCounterDB[private.realmName]
	debug = false,
	
	--BeanCounter Bids/posts
	PendingBids = {},
	PendingPosts = {},
	
	--BeanCounterMail 
	reconcilePending = {},
	inboxStart = {},
	inboxCurrent = {},
	Task ={},
	TakeInboxIgnore = false,
	}
	
lib.Private = private --allow beancounter's sub lua's access
local print = AucAdvanced.Print

local function debugPrint(...) 
private.debugPrint("BeanCounterCore",...)
end


function lib.GetName()
	return libName
end

function lib.Processor(callbackType, ...)
	if (callbackType == "config") then
		private.SetupConfigGui(...)
	elseif(callbackType == "auctionui") then
		--Called to inform the module that the auction house has been loaded.
		private.CreateFrames()
	--elseif(callbackType == "postresult") then
		-- The hooks we use Already record appraiser and regular posts
	end
end

function lib.OnLoad(addon)
	private.frame = CreateFrame("Frame")

	private.frame:RegisterEvent("PLAYER_MONEY")
	
	private.frame:RegisterEvent("MAIL_INBOX_UPDATE")
	private.frame:RegisterEvent("UI_ERROR_MESSAGE")
	private.frame:RegisterEvent("MAIL_SHOW")
	private.frame:RegisterEvent("MAIL_CLOSED")
	
	private.frame:RegisterEvent("MERCHANT_SHOW")	
	private.frame:RegisterEvent("MERCHANT_UPDATE")
	private.frame:RegisterEvent("MERCHANT_CLOSED")
	
	private.frame:SetScript("OnEvent", private.onEvent)
	private.frame:SetScript("OnUpdate", private.onUpdate)
	
	-- Hook all the methods we need!
	Stubby.RegisterFunctionHook("TakeInboxMoney", -100, private.PreTakeInboxMoneyHook);
	Stubby.RegisterFunctionHook("TakeInboxItem", -100, private.PreTakeInboxItemHook);
	--Bids
	Stubby.RegisterFunctionHook("PlaceAuctionBid", 50, private.postPlaceAuctionBidHook)
	--Posting
	Stubby.RegisterFunctionHook("StartAuction", -50, private.preStartAuctionHook)
	--Vendor
	hooksecurefunc("BuyMerchantItem", private.merchantBuy)
	
	
	AucAdvanced.Const.PLAYERLANGUAGE = GetDefaultLanguage("player")

	--Setup Configator defaults
	for config, value in pairs(private.defaults) do
		AucAdvanced.Settings.SetDefault(config, value)
	end
	
	
	private.initializeDB() --create or initialize the saved DB
end

--Create the database
function private.initializeDB()  
--TESTING TABLES REMOVE
	if not reconcilePending then
		reconcilePending = {}
	end
	if not Task then
		Task = {}
	end
--**************************************************************
	if not BeanCounterDB  then
		BeanCounterDB  = {}
	end
	if not BeanCounterDB[private.realmName] then
		BeanCounterDB[private.realmName] = {}
		
	end
	if not BeanCounterDB[private.realmName][private.playerName] then
		BeanCounterDB[private.realmName][private.playerName] = {}
		BeanCounterDB[private.realmName][private.playerName]["version"] = private.version
		
		BeanCounterDB[private.realmName][private.playerName]["faction]"] = private.faction
		BeanCounterDB[private.realmName][private.playerName]["wealth"] = GetMoney()
		
		BeanCounterDB[private.realmName][private.playerName]["vendorbuy"] = {}
		BeanCounterDB[private.realmName][private.playerName]["vendorsell"] = {}
		
		BeanCounterDB[private.realmName][private.playerName]["postedAuctions"] = {}
		BeanCounterDB[private.realmName][private.playerName]["completedAuctions"] = {}
		BeanCounterDB[private.realmName][private.playerName]["failedAuctions"] = {}
		
		BeanCounterDB[private.realmName][private.playerName]["postedBids"] = {}
		BeanCounterDB[private.realmName][private.playerName]["postedBuyouts"] = {}
		BeanCounterDB[private.realmName][private.playerName]["completedBids/Buyouts"]  = {}
		BeanCounterDB[private.realmName][private.playerName]["failedBids"]  = {}
		
	end
--OK we now have our Database ready, lets create an Alias to make refrencing easier
private.playerData = BeanCounterDB[private.realmName][private.playerName]
private.serverData = BeanCounterDB[private.realmName]

--Ok, create a fake table telling folks what our database means
	BeanCounterDBFormat = {"This is a diagram for the layout of the BeanCounterDB.",
	'POSTING DATABASE -- records Auction house activities',
	"['postedAuctions'] == Item, post.count, post.minBid, post.buyoutPrice, post.runTime, post.deposit, time(), current wealth",
	"['postedBids'] == itemName, count, bid, owner, isBuyout, timeLeft, time(),current wealth",
	"['postedBuyouts'] ==  itemName, count, bid, owner, isBuyout, timeLeft, time(), current wealth",
	' ',
	' ',
	'MAIL DATABASE --records mail received from Auction House',	
	'(Some of these values will be nil If we were unable to Retrieve the Invoice), current wealth',
	"['completedAuctions'] == itemName, Auction successful, money, deposit , fee, buyout , bid, buyer, (time the mail arrived in our mailbox), current wealth",
	"['failedAuctions'] == itemName, Auction expired, (time the mail arrived in our mailbox), current wealth",
	"completedBids/Buyouts are a combination of the mail data from postedBuyouts and postedBids, current wealth",
	"['completedBids/Buyouts] == itemName, Auction won, money, deposit , fee, buyout , bid, buyer, (time the mail arrived in our mailbox), current wealth",
	"[failedBids] == itemName, Outbid, money, (time the mail arrived in our mailbox), current wealth",
	'',
	'APIs',
    'TODO',
    }
    --[[
	'private.playerData is an alias for BeanCounterDB[private.realmName][private.playerName]',
	'private.packString(...) --will return any length arguments into a : seperated string',
	'private.databaseAdd(key, itemID, value)  --Adds to the DB. Example "postedBids", itemID, ( : seperated string)',
	'private.databaseRemove(key, itemID, ITEM, NAME, BID) --This is only for ["postedBids"]  NAME == Auction Owners Name',
	}]]

	private.wealth = GetMoney()
	private.playerData["wealth"] = private.wealth

	private.UpgradeDatabaseVersion() 
 
end

--[[ Configator Section ]]--
private.defaults = {
	["util.beancounter.activated"] = true,
	["util.beancounter.debug"] = false,
	}

function private.getOption(option)
	return AucAdvanced.Settings.GetSetting(option)
end

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	id = gui:AddTab(libName)
	gui:MakeScrollable(id)
	gui:AddControl(id, "Header",     0,    libName.." options")
	gui:AddControl(id, "Checkbox",   0, 1, "util.beancounter.debug", "Turn on BeanCounter Debugging.")

	--gui:AddControl(id, "Subhead",    0,    "Debug from specific modules:")
	--gui:AddControl(id, "Checkbox",   0, 1, "util.beancounter.Maildebug", "Show BeanCounterMail Debugging Messages.")
	--gui:AddControl(id, "Checkbox",   0, 1, "util.beancounter.Framedebug", "Show BeanCounterFrames Debugging Messages.")
	--gui:AddControl(id, "Checkbox",   0, 1, "util.beancounter.Framedebug", "Show BeanCounterPosting/Bid Debugging Messages.")	
end


--[[ Local functions ]]--
function private.onUpdate()
	private.mailonUpdate()
end

function private.onEvent(frame, event, ...)
	if (event == "PLAYER_MONEY") then
		private.wealth = GetMoney()
		private.playerData["wealth"] = private.wealth
	
	elseif (event == "MAIL_INBOX_UPDATE") or (event == "MAIL_SHOW") or (event == "MAIL_CLOSED") then
		private.mailMonitor(event,...)
	
	elseif (event == "MERCHANT_CLOSED") or (event == "MERCHANT_SHOW") or (event == "MERCHANT_UPDATE") then
		private.vendorOnevent(event,...)
	end
	
	
	
end


--[[ Utility Functions]]--
--will return any length arguments into a ; seperated string
function private.packString(...)
	for n = 1, select("#", ...) do
		local msg = select(n, ...)
		if msg == nil then 
			msg = "<nil>" 
		elseif msg == true then
			msg = "boolean true"
		elseif msg == false then
			msg = "boolean false"
		end
		if n == 1 then  --This prevents a seperator from being the first character.  :foo:foo:
			String = msg
		else
			String = strjoin(";",String,msg)
		end
	end
	return(String)
end
--Will split any string and return a table value
function private.unpackString(text)
	return {strsplit(";", text)}
end

--Add data to DB
function private.databaseAdd(key, itemID, value)
	if private.playerData[key][itemID] then
		table.insert(private.playerData[key][itemID], value)
	else
		private.playerData[key][itemID]={value}
	end
end
--remove item (for pending bids only atm) Can I make this universal?
function private.databaseRemove(key, itemID, ITEM, NAME)
	if key == "postedBids" then	
		for i,v in pairs(private.playerData[key][itemID]) do
			local tbl = private.unpackString(text)
			if tbl and itemID and ITEM and NAME then
				if tbl[1] == ITEM and tbl[4] == NAME then
                if (#playerData[key][itemID] == 1) then --itemID needs to be removed if we are deleting the only value              
			playerData[key][itemID] = nil
                        break
                    else
                        table.remove(playerData[key][itemID],i)--Just remove the key
                        break
                    end
				end
			end
		end
	end
end
--Get item Info or a specific subset. accepts itemID or "itemString" or "itemName ONLY IF THE ITEM IS IN PLAYERS BAG" or "itemLink"
function private.getItemInfo(link, cmd) 
debugPrint(link, cmd)
local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(link)
	if not cmd and itemLink then --return all
		return itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture
	elseif itemLink and (cmd == "itemid") then
		local itemID = itemLink:match("|c%x+|Hitem:(%d-):.-|h%[.-%]|h|r")
		return itemID, itemLink
	end
end

function private.debugPrint(...)
	if private.getOption("util.beancounter.debug") then
		print(...)
	end
end
function private.nilSafe(string)
	if (string) then
		return string;
	end
	return "<nil>";
end