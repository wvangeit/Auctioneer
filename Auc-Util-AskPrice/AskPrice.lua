--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

	Auctioneer AskPrice created by Mikezter and merged into
	Auctioneer Advanced by MentalPower.

	Functions responsible for AskPrice's operation.

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
]]

local libName = "AskPrice"
AucAdvanced.Modules.Util[libName] = {}
local lib = AucAdvanced.Modules.Util[libName]
local private = {sentAskPriceAd = {}, whisperList = {}}
local print = AucAdvanced.Print


--Static Variable Table
--Set to local when done debugging
local SVT = {
		Users = {},
		Announcer = true,
		PricePending = {},--Table containing all data from users and later Average of all data received
		items = {}, --Table value containing all data from msg
		PlayerName =  UnitName("player"),
		UpdateInterval = 0.5, --how often OnUpdate code will execute in seconds
		TimeSinceLastUpdate = 0,
		QuestionAsked = false,
		FinishedLoading = 0,
		private = {sentAskPriceAd = {}, whisperList = {}}
	}
		
table.insert(SVT.Users,SVT.PlayerName)  --Places player into the user table at start		


function lib.GetName()
	return libName
end

function lib.Processor(callbackType, ...)
	if (callbackType == "config") then
		private.SetupConfigGui(...)
	end
end

function lib.OnLoad(addon)

	private.frame = CreateFrame("Frame")

	private.frame:RegisterEvent("CHAT_MSG_RAID_LEADER")
	private.frame:RegisterEvent("CHAT_MSG_WHISPER")
	private.frame:RegisterEvent("CHAT_MSG_OFFICER")
	private.frame:RegisterEvent("CHAT_MSG_PARTY")
	private.frame:RegisterEvent("CHAT_MSG_GUILD")
	private.frame:RegisterEvent("CHAT_MSG_RAID")

	private.frame:RegisterEvent("GUILD_ROSTER_UPDATE")--Used to monitor guild so we update USER table 
	private.frame:RegisterEvent("CHAT_MSG_ADDON") --standard addon event
	private.frame:RegisterEvent("PLAYER_LOGIN")  --we use this event to anncounce we are a USER
		
	private.frame:SetScript("OnEvent", private.eventHandler)
	private.frame:SetScript("OnUpdate", private.OnUpdate)
	
	AucAdvanced.Const.PLAYERLANGUAGE = GetDefaultLanguage("player")

	Stubby.RegisterFunctionHook("ChatFrame_OnEvent", -200, private.onEventHook)

	--Setup Configator defaults
	for config, value in pairs(private.defaults) do
		AucAdvanced.Settings.SetDefault(config, value)
	end
	
	SVT.FinishedLoading = time() --Start the countdown till we monitor the first GuildrosterUpdate .
end


--[[ Local functions ]]--
function private.OnUpdate()

	if SVT.QuestionAsked == false then return end --If we have nothing pending skip it all
	 if not (time()-SVT.TimeSinceLastUpdate > SVT.UpdateInterval) then return end --Delay to allow time to recive answers.
	
	local Value, Seen = 0,0
	--Better stat average formula for each response: total = total + (price * seen); count = count + seen; end;  average = total/count
	for link,t in pairs(SVT.PricePending) do
	  local size = #(SVT.PricePending[link])--Take size of table use that to iterate over values in the for/do
	    for count = 1,size do
	 	Seen = Seen + SVT.PricePending[link][count]["seen"]
		Value = Value + (SVT.PricePending[link][count]["value"] * SVT.PricePending[link][count]["seen"])		
	    end
	   Value = (Value/Seen) --Weighted Average by # of times seen by each client
	   SVT.PricePending[link] = nil --This nukes that particulair key from the table
	   SVT.PricePending[link] = {["seen"]=Seen,["value"]=Value} --This replaces the key
	   Seen,Value = 0,0 --reset 
	end
	--We have now converted the Table to a Average price count of all data
	SVT.TimeSinceLastUpdate = time()
	SVT.QuestionAsked = false
	
	private.Format_Whisper()
end

function private.eventHandler(event, ...)
    local event, prefix, msg, how, who = select(1, ...) --This is for an CHAT_MSG_ADDON event

    --Nothing to do if askprice is disabled
	if (not private.getOption('util.askprice.activated')) then
		return
	end
	
	if (event == "CHAT_MSG_ADDON") then 
	     private.CHAT_MSG_ADDON(event,...)--used to collect a ADDON Message
	elseif (event == "PLAYER_LOGIN") then --lets annouce we are a USER
            SendAddonMessage("AskPrice$", "login", "GUILD") --send msg to tell em' we joined and see who is out there. 
	elseif (event == "GUILD_ROSTER_UPDATE") then
	    private.Guild_Roster_Update() --updates the current Announcers/remove offline
	end 

	--Make sure that we recieve the proper events and that our settings allow a response
	if (not ((event == "CHAT_MSG_WHISPER")
		or (
			((event == "CHAT_MSG_GUILD") or
			(event == "CHAT_MSG_OFFICER")) and
			private.getOption('util.askprice.guild')
		)
		or (
			((event == "CHAT_MSG_PARTY") or
			(event == "CHAT_MSG_RAID") or
			(event == "CHAT_MSG_RAID_LEADER")) and
			private.getOption('util.askprice.party'))
		)) then
		return
	end
local event, text, player = select(1, ...) --This is format for a "CHAT_MSG_WHISPER"
	private.eventSwarm(event, text, player)
end

--Ok we need to collect all necessary info
function private.eventSwarm(event, text, player, client)

 if private.getOption('util.askprice.debug') and (event ~= "CHAT_MSG_GUILD")then print("Swarm Start",event," Text ", text, " Player ", player, " Client ",client) end
	-- Check for marker (trigger char or "smart" words) only if the ignore option is not set
		if (not (text:sub(1, 1) == private.getOption('util.askprice.trigger'))) then
			--If the trigger char was not found scan the text for SmartWords (if the feature has been enabled)
			if (private.getOption('util.askprice.smart')) then
				-- Check if the custom SmartWords are present in the chat message
				-- Note, that both words must be contained in the text, to be identified as a valid askprice request.
				if (not (
					text:lower():find(private.getOption('util.askprice.word1'), 1, true) and
					text:lower():find(private.getOption('util.askprice.word2'), 1, true)
				)) then
					return
				end
			else
				return
			end
		end

	-- Check for itemlink after trigger
	if (not (text:find("|Hitem:"))) then
		return
	end

--Need a way to handle party/raid when non announcer client is present. Possibly second/announcer list? 
--Or shall we just keep it simple i.e. if non annoucer present spam the question even if multiple non announcer clients present.
	if (SVT.Announcer == false) then --If not the announcer ignore
	   if private.getOption('util.askprice.debug') then print("not announcer "..event) end
		if (event == "CHAT_MSG_WHISPER") then --Needed to have a way to respond to a whisper to a non announcer client. 
			SendAddonMessage("AskPrice$", "WHISP: "..player.." "..text, "GUILD") --Send to the Addon channel, the current Announcer will handle it and respond to questioner
		elseif (event == "CHAT_MSG_PARTY") and (not UnitInParty(SVT.Users[1]))then
			SendAddonMessage("AskPrice$", "WHISP: "..player.." "..text, "GUILD")
		elseif (event == "CHAT_MSG_RAID") or (event == "CHAT_MSG_RAID_LEADER") and (not UnitInRaid(SVT.Users[1]))then
			SendAddonMessage("AskPrice$", "WHISP: "..player.." "..text, "GUILD")
		end
	   return
	end 

	--OK Lets QUERY our clients for item info
	SVT.items = private.getItems(text)	--Parse the text and separate out the different links
		
	SVT.TimeSinceLastUpdate = time() --keeps the onupdate from fireing, as long as we are reciving data
	--Query other users using addon channel 
	for key, item in ipairs(SVT.items) do
		SVT.items[key]["name"] = player --add player whooriginally asked the question 
		SVT.items[key]["client"] = client --client who sent question
		SVT.QuestionAsked = true --used to prevent onupdate from running unless we need it 
		SendAddonMessage("AskPrice$", "QUERY: "..item.link, "GUILD")
	end
 if private.getOption('util.askprice.debug') then print("Swarm End") end
end

function private.Format_Whisper()
	local seenCount, marketValue, vendorPrice, askedCount, usedStack, multipleItems, count, player,client
	--Parse the text and separate out the different links
	for link,v in pairs(SVT.PricePending) do

		  _, _, vendorPrice = private.getData(link)
		seenCount = SVT.PricePending[link]["seen"]
		marketValue = SVT.PricePending[link]["value"]
		
			for key, item in ipairs(SVT.items) do --Do the items in the order they were recieved.
			   if link == item.link then
				count = item.count
				player = item.name
				client = item.client	
			   end
			end
			
		--If this is a raid/party/whisper message to a non announcer client lets send the data to them. they will whisper to Original questioner
		if client and player then --client is nil on normal operations, only valid if its a PRW
			if not count then count = 0 end
			local msg = strjoin(":", client, player, count, seenCount, marketValue)
			if private.getOption('util.askprice.debug') then print(client, player, count, seenCount, marketValue) end
			SendAddonMessage("AskPrice$", "PRW: "..msg.." "..link, "GUILD") 
		end
	
			--If there are multiple items send a separator line (since we can't send \n's as those would cause DC's)
			if (multipleItems) then
				private.sendWhisper("    ", player)
			end

			local strMarketOne
			--If the stackSize is grater than one, add the unit price to the message
		if not count then count = 0 end
			if (count > 1) then
				strMarketOne = ("(%s each)"):format(EnhTooltip.GetTextGSC(marketValue, nil, true))
			else
				strMarketOne = ""
			end

			if (seenCount > 0) then
				private.sendWhisper(("%s: Seen %d times at auction total by Auctioneer Advanced"):format(link, seenCount), player)
				private.sendWhisper(
					("%sMarket Value: %s%s"):format(
						"    ",
						EnhTooltip.GetTextGSC(marketValue*count, nil, true),
						strMarketOne),
					player
				)
			else
				private.sendWhisper(link..": "..("Never seen at %s by Auctioneer Advanced"):format(AucAdvanced.GetFaction()), player)
			end

			--Send out vendor info if we have it
		if not vendorPrice then vendorPrice = 0 end --Hearthstone and other non vendor pice items threw errors here
			if (private.getOption('util.askprice.vendor') and (vendorPrice > 0)) then

				local strVendOne
				--Again if the stackSize is greater than one, add the unit price to the message
				if (count > 1) then
					strVendOne = ("(%s each)"):format(EnhTooltip.GetTextGSC(vendorPrice, nil, true))
				else
					strVendOne = ""
				end

				private.sendWhisper(
					("%sSell to vendor for: %s%s"):format(
						"    ",
						EnhTooltip.GetTextGSC(vendorPrice * count, nil, true),
						strVendOne),
					player
				)
			end

			usedStack = usedStack or (count > 1)
			multipleItems = true
	end

	--Once we're done sending out the itemInfo, check if the person used the stack size feature, if not send them the ad message.
	if ((not usedStack) and (private.getOption('util.askprice.ad'))) then
		if (not private.sentAskPriceAd[player]) then --If the player in question has been sent the ad message in this session, don't spam them again.
			private.sentAskPriceAd[player] = true
			private.sendWhisper(("Get stack prices with %sCount[ItemLink] (Count = stacksize)"):format(private.getOption('util.askprice.trigger')), player)
		end
	end

SVT.PricePending = {}	
end

--Send a response to the addon channel when a QUERY is sent by the announcer
function private.Util_Query(_, prefix, msg, how, player) 
	if private.getOption('util.askprice.debug') then print("Query sent") end 

	local  _,link = string.match( msg, "(QUERY:%s)(.*)" )
	local seenCount, marketValue, _ =  private.getData(link)
	if not seenCount then seenCount = 0 end
	if not marketValue then marketValue = 0 end
	
	if (seenCount) and (marketValue) then
		SendAddonMessage("AskPrice$", "PRICE: "..seenCount.." "..marketValue.." "..link, "GUILD") 
	end
end
--WHISP this even is triggered by a non announcer client in a party/raid/direct whisp setting
function private.Util_Whisper(_, prefix, msg, how, client) 
	local  _, player, text = string.match( msg, "(WHISP:%s)(.-)%s(.*)" ) 
	local event = "CHAT_MSG_WHISPER"
	
	if private.getOption('util.askprice.debug') then print("Whisper from non announcer Received ", text, player, client) end
	private.eventSwarm(event, text, player, client)

end
--PRW Party/Raid/Whisper to Announcer to client response
function private.Util_PRW(_, prefix, msg, how, who) 
	if private.getOption('util.askprice.debug') then print("Announcer response from party/raid/whisper client received") end
			
	local  _,data, link = string.match(msg, "(PRW:%s)(.-)%s(.+)" )
	local _, player, count, seen, value = strsplit(":", data)
	--Bah need to convert my values back to Numeric
	count = tonumber(count) or 0; seen = tonumber(seen) or 0; value = tonumber(value) or 0
						
	table.insert(SVT.items, {["link"] = link, ["count"] = count, ["name"] = player,})
	
	if not SVT.PricePending[link] then SVT.PricePending[link]={} end 
	local S = (#(SVT.PricePending[link])+1) --Size of the table +1
	SVT.PricePending[link][S]={["seen"]=seen,["value"]=value}
	SVT.QuestionAsked = true --used to prevent onupdate from running unless we need it 
end

function private.Util_Response(_, prefix, msg, how, who)
	if private.getOption('util.askprice.debug') then print("response sent") end

	local  _,seen,value,link = string.match(msg, "(PRICE:%s)(%d-%s)(.-%s)(.+)" )
	if not SVT.PricePending[link] then SVT.PricePending[link]={} end 
	local S = (#(SVT.PricePending[link])+1) --Size of the table +1
	SVT.PricePending[link][S]={["seen"]=seen,["value"]=value}

if private.getOption('util.askprice.debug') then print("Response "..link.." "..seen.." "..value) end		
end


function private.onEventHook() --%ToDo% Change the prototype once Blizzard changes their functions to use paramenters instead of globals.
	if (event == "CHAT_MSG_WHISPER_INFORM") then
		if (private.whisperList[arg1]) then
			private.whisperList[arg1] = nil
			if (private.getOption('util.askprice.whispers') == false) then
				return "killorig"
			end
		end
	end
end

function private.getData(itemLink)
	local marketValue, seenCount = AucAdvanced.API.GetMarketValue(itemLink, AucAdvanced.GetFaction())
	local vendorPrice = GetSellValue(itemLink)

	return seenCount, marketValue, vendorPrice
end


--Many thanks to the guys at irc://chat.freenode.net/wowi-lounge for their help in creating this function
local itemList = {}
function private.getItems(str)
	if (not str) then return nil end
	for k in pairs(itemList) do
		itemList[k] = nil
	end

	for number, color, item, name in str:gmatch("(%d*)%s*|c(%x+)|Hitem:([^|]+)|h%[(.-)%]|h|r") do
		table.insert(itemList, {link = "|c"..color.."|Hitem:"..item.."|h["..name.."]|h|r", count = tonumber(number) or 1})
	end
	return itemList
end

function private.sendWhisper(message, player)
	private.whisperList[message] = true
	SendChatMessage(message, "WHISPER", AucAdvanced.Const.PLAYERLANGUAGE, player)
end

--[[ Configator Section ]]--
private.defaults = {
	["util.askprice.activated"]    = true,
	["util.askprice.ad"]           = true,
	["util.askprice.guild"]        = true,
	["util.askprice.smart"]        = true,
	["util.askprice.party"]        = true,
	["util.askprice.trigger"]      = "?",
	["util.askprice.vendor"]       = false,
	["util.askprice.whispers"]     = true,
	["util.askprice.word1"]        = "what",
	["util.askprice.word2"]        = "worth",
	["util.askprice.login"]		= true,
	["util.askprice.debug"]		= false,	
}

function private.getOption(option)
	return AucAdvanced.Settings.GetSetting(option)
end

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	id = gui:AddTab(libName)
	gui:MakeScrollable(id)
	gui:AddControl(id, "Header",     0,    libName.." options")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.activated", "Respond to queries for item market values sent via chat.")

	gui:AddControl(id, "Subhead",    0,    "Respond from:")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.guild", "Respond to queries made in guild and officer chat.")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.party", "Respond to queries made in party and raid chat.")

	gui:AddControl(id, "Subhead",    0,    "Triggers:")
	gui:AddControl(id, "Text",       0, 1, "util.askprice.word1", "Askprice Custom SmartWord #1")
	gui:AddControl(id, "Text",       0, 1, "util.askprice.word2", "Askprice Custom SmartWord #2")
	gui:AddControl(id, "Text",       0, 1, "util.askprice.trigger", "Askprice Trigger character")

	gui:AddControl(id, "Subhead",    0,    "Swarm:")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.login", "Shows (enabled) or hides (disabled) Login/Online/Anouncer message.")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.debug", "Shows (enabled) or hides (disabled) debug messages.")
	
	gui:AddControl(id, "Subhead",    0,    "Miscellaneous:")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.ad", "Enable new AskPrice features ad.")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.smart", "Enable SmartWords checking.")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.vendor", "Enable the sending of vendor pricing data.")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.whispers", "Shows (enabled) or hides (disabled) outgoing whispers from Askprice.")
	
end


function private.CHAT_MSG_ADDON(event, ...)
	local event, prefix, msg, how, who = select(1, ...)
	
	if ( prefix ~= "AskPrice$" ) then return end --Event for deciding who the guild announcer is
      
	if  "QUERY: " == (string.match( msg, "(QUERY:%s)" )) then --This handles a query for a price check from teh guild addon channel
		private.Util_Query(event, prefix, msg, how, who)
			return
	elseif  "PRICE: " == (string.match( msg, "(PRICE:%s)" )) and (SVT.Announcer == true) then --This handles a response for a price check from the guild addon channel
		private.Util_Response(event, prefix, msg, how, who) 
			return 
	elseif  "WHISP: " == (string.match( msg, "(WHISP:%s)" )) and (SVT.Announcer == true) then --This handles a Whsiper when we are not the announcer
		private.Util_Whisper(event, prefix, msg, how, who) 
			return
	elseif ("PRW: "..SVT.PlayerName) == (string.match( msg, "(PRW:%s%a-):" )) then --This handles a GuildAnnouncer response to a client in PartyRaidWhisper question
		private.Util_PRW(event, prefix, msg, how, who) 
			return
	elseif ( msg == "login" ) or ( msg == "online" ) and (who ~= SVT.PlayerName) then  --prevents the event from firing when we login and announce	
		local PlayerInTable = false

		if ( msg == "login" )  then --handles logins after our login
		   SendAddonMessage("AskPrice$", "online", "GUILD") --send alert letting them know we are online
			if private.getOption('util.askprice.login') then print("we received a login msg from "..who) end --send a login/online message if the user wants to see it
		elseif ( msg == "online" )  then --handles logins before our login
			if private.getOption('util.askprice.login') then print("we received a online msg from "..who) end--send a login/online message if the user wants to see it
		end

		for index,value in pairs(SVT.Users) do
			if who == value then 
			    PlayerInTable = true  --set true if player is in table already
			end
		end
				
		if PlayerInTable == false then  --adds the player to the list of share users
		    table.insert(SVT.Users,who)
		end

		table.sort(SVT.Users, function (a,b)
			return (a < b)
		end)

		 if private.getOption('util.askprice.login') then print("announcer is "..SVT.Users[1] ) end --send a login/online message if the user wants to see it
			
		if SVT.Users[1] == SVT.PlayerName then 
			SVT.Announcer = true
		else    
			SVT.Announcer = false
		end  
	end
 
end

-- *****************************************************************************
-- This will retrive current online Guild members.
-- *****************************************************************************
function private.Guild_Roster_Update()

	if (time() - SVT.FinishedLoading) < 60 then return end --We have to Delay or we get an unknown unit token error on login
	local guildName, _,_ = GetGuildInfo(SVT.PlayerName) --this little statement prevents us from trying to update a guild if the character is not guilded
	if guildName == nil then return end --this little statement prevents us from trying to update a guild if the character is not guilded

	local count = GetNumGuildMembers(true)
	local tempTable={}
	local OnlineTable = {}  --this will give us a clean table on every Guild update event


	for i=1,count
	do
	    local name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i)
	    if(name and online)
	    then
		table.insert(OnlineTable,name)
	    end
	end

	for index,value in pairs(SVT.Users) do
	    for i,v in pairs(OnlineTable) do
		if v == value then --name is online
		    table.insert(tempTable,value)
		end
	    end
	end

	SVT.Users = tempTable  --replace old table with new

	table.sort(SVT.Users, function (a,b)
		return (a < b)
	end)

	--DOH we need change the variable if we become announcer 
	if SVT.Users[1] == SVT.PlayerName then 
	   SVT.Announcer = true
	else    
	   SVT.Announcer = false
	end  

end 
