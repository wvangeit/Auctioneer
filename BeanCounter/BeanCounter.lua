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

--AucAdvanced.Modules["Util"]["BeanCounter"]

local libName = "BeanCounter"
local libType = "Util"
local lib
BeanCounter={}
lib = BeanCounter

local private = {
	--BeanCounterCore
	playerName = UnitName("player"),
	realmName = GetRealmName(), 
	faction, _ = UnitFactionGroup(UnitName("player")),
	version = 1.04,
	wealth, --This characters current net worth. This will be appended to each transaction.
	playerData, --Alias for BeanCounterDB[private.realmName][private.playerName]
	serverData, --Alias for BeanCounterDB[private.realmName]
		
	--BeanCounter Bids/posts
	PendingBids = {},
	PendingPosts = {},
	
	--BeanCounterMail 
	reconcilePending = {},
	inboxStart = {},
	}
	
lib.Private = private --allow beancounter's sub lua's access
--Taken from AucAdvCore
function BeanCounter.Print(...)
	local output, part
	for i=1, select("#", ...) do
		part = select(i, ...)
		part = tostring(part):gsub("{{", "|cffddeeff"):gsub("}}", "|r")
		if (output) then output = output .. " " .. part
		else output = part end
	end
	DEFAULT_CHAT_FRAME:AddMessage(output, 0.3, 0.9, 0.8)
end

local print = BeanCounter.Print

local function debugPrint(...) 
    if private.getOption("util.beancounter.debugCore") then
        private.debugPrint("BeanCounterCore",...)
    end
end

function lib.OnLoad(addon)
	private.scriptframe:RegisterEvent("PLAYER_MONEY")
	
	private.scriptframe:RegisterEvent("MAIL_INBOX_UPDATE")
	private.scriptframe:RegisterEvent("UI_ERROR_MESSAGE")
	private.scriptframe:RegisterEvent("MAIL_SHOW")
	private.scriptframe:RegisterEvent("MAIL_CLOSED")
	private.scriptframe:RegisterEvent("UPDATE_PENDING_MAIL")
	private.scriptframe:RegisterEvent("MERCHANT_SHOW")	
	private.scriptframe:RegisterEvent("MERCHANT_UPDATE")
	private.scriptframe:RegisterEvent("MERCHANT_CLOSED")
			
	private.scriptframe:SetScript("OnUpdate", private.onUpdate)
	
	-- Hook all the methods we need
	Stubby.RegisterAddOnHook("Blizzard_AuctionUi", "BeanCounter", private.AuctionUI) --To be standalone we cannot depend on AucAdv for lib.Processor
	--mail
	Stubby.RegisterFunctionHook("TakeInboxMoney", -100, private.PreTakeInboxMoneyHook);
	Stubby.RegisterFunctionHook("TakeInboxItem", -100, private.PreTakeInboxItemHook);
	--Bids
	Stubby.RegisterFunctionHook("PlaceAuctionBid", 50, private.postPlaceAuctionBidHook)
	--Posting
	Stubby.RegisterFunctionHook("StartAuction", -50, private.preStartAuctionHook)
	--Vendor
	hooksecurefunc("BuyMerchantItem", private.merchantBuy)
	
	private.initializeDB() --create or initialize the saved DB
	lib.MakeGuiConfig() --create the configurator GUI frame
	private.CreateFrames() --create our framework used for AH and GUI
	private.slidebar() --create slidebar icon
end

--Create the database
function private.initializeDB()  
	if not BeanCounterDB  then
		BeanCounterDB  = {}
		BeanCounterDB["settings"] = {}
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
		
		BeanCounterDB[private.realmName][private.playerName]["mailbox"] = {}
		
	end
	
	
	 --OK we now have our Database ready, lets create an Alias to make refrencing easier
	private.playerData = BeanCounterDB[private.realmName][private.playerName]
	private.serverData = BeanCounterDB[private.realmName]
	
--[[Ok, create a fake table telling folks what our database means
	BeanCounterDBFormat = {"This is a diagram for the layout of the BeanCounterDB.",
	'POSTING DATABASE -- records Auction house activities',
	"['postedAuctions'] == Item, post.count, post.minBid, post.buyoutPrice, post.runTime, post.deposit, time(), current wealth, date",
	"['postedBids'] == itemName, count, bid, owner, isBuyout, timeLeft, time(),current wealth, date",
	"['postedBuyouts'] ==  itemName, count, bid, owner, isBuyout, timeLeft, time(), current wealth, date",
	' ',
	' ',
	'MAIL DATABASE --records mail received from Auction House',	
	'(Some of these values will be nil If we were unable to Retrieve the Invoice), current wealth, date',
	"['completedAuctions'] == itemName, Auction successful, money, deposit , fee, buyout , bid, buyer, (time the mail arrived in our mailbox), current wealth, date",
	"['failedAuctions'] == itemName, Auction expired, (time the mail arrived in our mailbox), current wealth, date",
	"completedBids/Buyouts are a combination of the mail data from postedBuyouts and postedBids, current wealth, date",
	"['completedBids/Buyouts] == itemName, Auction won, money, deposit , fee, buyout , bid, buyer, (time the mail arrived in our mailbox), current wealth, date",
	"[failedBids] == itemName, Outbid, money, (time the mail arrived in our mailbox), current wealth, date",
	'',
	'APIs',
    'TODO',
    }]]
    --[[
	'private.playerData is an alias for BeanCounterDB[private.realmName][private.playerName]',
	'private.packString(...) --will return any length arguments into a : seperated string',
	'private.databaseAdd(key, itemID, value)  --Adds to the DB. Example "postedBids", itemID, ( : seperated string)',
	'private.databaseRemove(key, itemID, ITEM, NAME, BID) --This is only for ["postedBids"]  NAME == Auction Owners Name',
	}]]
	
	private.wealth = private.playerData["wealth"]
	private.UpgradeDatabaseVersion() 
	 
end

--[[ Configator Section ]]--
--See BeanCounterConfig.lua
function private.getOption(option)
	return lib.GetSetting(option)
end


--[[Sidebar Section]]--
local sideIcon
function private.slidebar()
	if LibStub then
		local SlideBar = LibStub:GetLibrary("SlideBar", true)
		if SlideBar then
			sideIcon = SlideBar.AddButton("BeanCounter", "Interface\\AddOns\\BeanCounter\\Textures\\BeanCounterIcon")
			sideIcon:RegisterForClicks("LeftButtonUp","RightButtonUp")
			sideIcon:SetScript("OnClick", private.GUI)
			sideIcon.tip = {
				"BeanCounter",
				"BeanCounter tracks your trading activities so that you may review your expenditures and income, perform searches and use this data to determine your successes and failures.",
				"{{Click}} to view your activity report.",
				"{{Right-Click}} to edit the configuration.",
			}
		end
	end
end

--[[ Local functions ]]--
function private.onUpdate()
	private.mailonUpdate()
end

function private.onEvent(frame, event, arg, ...)
	if (event == "PLAYER_MONEY") then
		private.wealth = GetMoney()
		private.playerData["wealth"] = private.wealth
	
	elseif (event == "MAIL_INBOX_UPDATE") or (event == "MAIL_SHOW") or (event == "MAIL_CLOSED") then
		private.mailMonitor(event, arg, ...)
	
	elseif (event == "MERCHANT_CLOSED") or (event == "MERCHANT_SHOW") or (event == "MERCHANT_UPDATE") then
			--private.vendorOnevent(event, arg, ...)
			
	elseif (event == "UPDATE_PENDING_MAIL") then 
		private.hasUnreadMail()
		
	elseif (event == "ADDON_LOADED") then
		if arg == "BeanCounter" then
		   lib.OnLoad()
		end
	end
end


--[[ Utility Functions]]--
--External Search Stub, allows other addons searches to search to display in BC
--Can be item Name or link or itemID
function lib.externalSearch(name)
	 if private.getOption("util.beancounter.externalSearch") then
		local frame = private.frame
		--the function getItemInfo will return a plain text name on itemID or itemlink searches and nil if a plain text search is passed
		local itemName, itemTexture = private.getItemInfo(name, "name") or name
		frame.searchBox:SetText(itemName)
		local settings = {["selectbox"] = {"1","server"}  , ["exact"] = false, ["classic"] = frame.classicCheck:GetChecked(), 
						["bid"] = true, ["outbid"] = frame.bidFailedCheck:GetChecked(), ["auction"] = true,
						["failedauction"] = frame.auctionFailedCheck:GetChecked() 
						}
		private.startSearch(itemName, settings, itemTexture)
	end
end

--will return any length arguments into a ; seperated string
function private.packString(...)
local String
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
	text = text:gsub("<nil>", 0) --Remove out <NIL> holder with 0
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
--remove item (for pending bids only atm)
function private.databaseRemove(key, itemID, ITEM, NAME)
	if key == "postedBids" then	
		for i,v in pairs(private.playerData[key][itemID]) do
			local tbl = private.unpackString(v)
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
	
	elseif itemName and itemTexture  and (cmd == "name") then
		return itemName, itemTexture
	end
end

function private.debugPrint(...)
	if private.getOption("util.beancounter.debug") then
		print(...)
	end
end

--[[Bootstrap Code]]
private.scriptframe = CreateFrame("Frame")
private.scriptframe:RegisterEvent("ADDON_LOADED")
private.scriptframe:SetScript("OnEvent", private.onEvent)
Babylonian.private.order = {"deDE"}