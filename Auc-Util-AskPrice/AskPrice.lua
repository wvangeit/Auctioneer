--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

	Auctioneer AskPrice created by Mikezter and merged into
	Auctioneer Advanced by MentalPower. Swarm response
	functionallity added by Kandoko.

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

local libType, libName = "Util", "AskPrice"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()

private.raidUsers = {}
private.raidRoster = {}
private.guildUsers = {}
private.guildRoster = {}
private.whisperList = {}
private.sentRequest = {}
private.requestQueue = {}
private.sentAskPriceAd = {}
private.timeToWaitForPrices = 2
private.timeToWaitForResponse = 5
private.playerName = UnitName("player")

function lib.Processor(callbackType, ...)
	if (callbackType == "config") then
		private.SetupConfigGui(...)
	end
end

function lib.OnLoad(addon)
	private.frame = CreateFrame("Frame")

	private.frame:RegisterEvent("CHAT_MSG_RAID_LEADER")
	private.frame:RegisterEvent("CHAT_MSG_IGNORED")
	private.frame:RegisterEvent("CHAT_MSG_WHISPER")
	private.frame:RegisterEvent("CHAT_MSG_OFFICER")
	private.frame:RegisterEvent("CHAT_MSG_PARTY")
	private.frame:RegisterEvent("CHAT_MSG_GUILD")
	private.frame:RegisterEvent("CHAT_MSG_RAID")

	private.frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	private.frame:RegisterEvent("GUILD_ROSTER_UPDATE")
	private.frame:RegisterEvent("RAID_ROSTER_UPDATE")
	private.frame:RegisterEvent("CHAT_MSG_ADDON")
	private.frame:RegisterEvent("PLAYER_LOGIN")

	private.frame:SetScript("OnEvent", private.onEvent)
	private.frame:SetScript("OnUpdate", private.onUpdate)

	AucAdvanced.Const.PLAYERLANGUAGE = GetDefaultLanguage("player")

	Stubby.RegisterFunctionHook("ChatFrame_OnEvent", -200, private.onEventHook)

	--Setup Configator defaults
	for config, value in pairs(private.defaults) do
		AucAdvanced.Settings.SetDefault(config, value)
	end
end

--[[ Local functions ]]--
function private.onUpdate(frame, secondsSinceLastUpdate)
	--Nothing to do if AskPrice is disabled
	if (not private.getOption('util.askprice.activated')) then
		return
	end

	--Check the request queue for timeouts (We've finished waiting for other clients to send prices)
	for request, details in pairs(private.requestQueue) do
		if ((GetTime() - details.timer) >= private.timeToWaitForPrices) then
			private.sendRequest(request, details)
			private.requestQueue[request] = nil
		end
	end

	--Check the sent queue for timeouts (We've finished waiting the asker to ignore us)
	for request, details in pairs(private.sentRequest) do
		if ((GetTime() - details.timer) >= private.timeToWaitForResponse) then
			private.sentRequest[request] = nil
		end
	end
end

function private.onEvent(frame, event, ...)
	if (event == "CHAT_MSG_ADDON") then
		return private.addOnEvent(...)
	elseif (event == "GUILD_ROSTER_UPDATE") then
		return private.guildRosterEvent(...)
	elseif (event == "PARTY_MEMBERS_CHANGED") or (event == "RAID_ROSTER_UPDATE") then
		return private.raidRosterEvent(...)
	elseif (event == "PLAYER_LOGIN") then
		return private.playerLoginEvent(...)
	elseif (event == "CHAT_MSG_IGNORED") then
		return private.beingIgnored(...)
	else
		return private.chatEvent(event, ...)
	end
end

function private.playerLoginEvent()
	if (IsInGuild()) then
		GuildRoster() --Request the Guild data
		private.sendAddOnMessage("GUILD", "MAINR", "login")
	end
	private.sendAddOnMessage("RAID", "MAINR", "login")
end

function private.chatEvent(event, text, player)
	local channel
	if (((event == "CHAT_MSG_RAID") or (event == "CHAT_MSG_PARTY") or (event == "CHAT_MSG_RAID_LEADER")) and (private.raidUsers[1] == private.playerName))then
		channel = "RAID"
	end

	if (((event == "CHAT_MSG_GUILD") or (event == "CHAT_MSG_OFFICER") and (private.guildUsers[1] == private.playerName))) then
		channel = "GUILD"
	end

	if (((event == "CHAT_MSG_WHISPER") and (private.getOption('util.askprice.activated')))) then
		channel = "WHISPER"
	end

	if (not (
		text:find("|Hitem:", 1, true)
		and
		(
			text:sub(1, 1) == private.getOption('util.askprice.trigger')
			or
			(
				private.getOption('util.askprice.smart')
				and
				text:lower():find(private.getOption('util.askprice.word1'), 1, true)
				and
				text:lower():find(private.getOption('util.askprice.word2'), 1, true)
			)
		)
	)) then
		return
	end

	local items = private.getItems(text)
	if (channel == "GUILD") or (channel == "RAID") then
		for i = 1, #items, 2 do
			local count = items[i]
			local link = items[i+1]

			private.sendAddOnMessage(channel, "QUERY", link, count, player, channel)
		end
	elseif (channel == "WHISPER") then
		for i = 1, #items, 2 do
			local count = items[i]
			local link = items[i+1]

			private.sendResponse(link, count, player, 1, private.getData(link))
		end
	end
end

function private.sendRequest(request, details)
	local link = details.itemLink
	local count = details.stackCount
	local player = details.sourcePlayer
	local totalPrice = details.totalPrice
	local vendorPrice = details.vendorPrice
	local answerCount = details.answerCount
	local totalSeenCount = details.totalSeenCount
	
	--Format pricing data
	totalPrice = math.floor(totalPrice/totalSeenCount) 

	--Reset the timer and move the request over to the sent queue.
	details.timer = GetTime()
	private.sentRequest[request] = details

	--Send the response
	return private.sendResponse(link, count, player, answerCount, totalSeenCount, totalPrice, vendorPrice)
end

function private.sendResponse(link, count, player, answerCount, totalSeenCount, totalPrice, vendorPrice)
	local marketPrice = totalPrice

	--If the stack size is grater than one, add the unit price to the message
	local strMarketOne
	if (count > 1) then
		strMarketOne = ("(%s each)"):format(EnhTooltip.GetTextGSC(marketPrice, nil, true))
	else
		strMarketOne = ""
	end

	if (totalSeenCount > 0) then
		local averageSeenCount = math.floor(totalSeenCount/answerCount + 0.5)
		private.sendWhisper(
			("%s: Seen an average of %d times at auction by %d people using Auctioneer Advanced"):format(
				link,
				averageSeenCount,
				answerCount),
			player
		)
		private.sendWhisper(
			("%sMarket Value: %s%s"):format(
				"    ",
				EnhTooltip.GetTextGSC(marketPrice * count, nil, true),
				strMarketOne),
			player
		)
	else
		private.sendWhisper(
			("%s: Never seen at %s by Auctioneer Advanced"):format(
				link,
				AucAdvanced.GetFaction()
			),
			player
		)
	end

	--Send out vendor info if we have it
	if --[[private.getOption('util.askprice.vendor') and ]](vendorPrice and (vendorPrice > 0)) then

		local strVendOne
		--Again if the stack Size is greater than one, add the unit price to the message
		if (count > 1) then
			strVendOne = ("(%s each)"):format(EnhTooltip.GetTextGSC(vendorPrice, nil, true))
		else
			strVendOne = ""
		end

		private.sendWhisper(
			("%sSell to vendor for: %s%s"):format(
				"    ",
				EnhTooltip.GetTextGSC(
					vendorPrice * count,
					nil,
					true
				),
				strVendOne
			),
			player
		)
	end
	
	if (not (count > 1)) and (private.getOption('util.askprice.ad')) then
		if (not private.sentAskPriceAd[player]) then --If the player in question has been sent the ad message in this session, don't spam them again.
			private.sentAskPriceAd[player] = true
			private.sendWhisper(("Get stack prices with %sCount[ItemLink] (Count = stacksize)"):format(private.getOption('util.askprice.trigger')), player)
		end
	end
end

function private.onEventHook() --%ToDo% Change the prototype once Blizzard changes their functions to use parameters instead of globals.
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
	local vendorPrice = GetSellValue and GetSellValue(itemLink)

	return seenCount or 0, marketValue or 0, vendorPrice or 0
end

--Many thanks to the guys at irc://chat.freenode.net/wowi-lounge for their help in creating this function
local itemList = {}
function private.getItems(str)
	if (not str) then return nil end
	for i = #itemList, 1, -1 do
		itemList[i] = nil
	end

	for number, color, item, name in str:gmatch("(%d*)%s*|c(%x+)|Hitem:([^|]+)|h%[(.-)%]|h|r") do
		table.insert(itemList, tonumber(number) or 1)
		table.insert(itemList, "|c"..color.."|Hitem:"..item.."|h["..name.."]|h|r")
	end
	return itemList
end

function private.sendWhisper(message, player)
	private.whisperList[message] = true
	SendChatMessage(message, "WHISPER", AucAdvanced.Const.PLAYERLANGUAGE, player)
end

function private.sendAddOnMessage(channel, ...)
	local message = string.join(";", ...)
	SendAddonMessage("AucAdvAskPrice", message, channel)
end

function private.addOnEvent(prefix, message, sourceChannel, sourcePlayer)
	if (not (prefix == "AucAdvAskPrice")) then
		return
	end

	--Decode the message
	local requestType, link, count, player, channel, totalPrice, totalSeenCount, vendorPrice, answerCount = string.split(";", message)
	local request
	if (link and count and player and channel) then
		request = link..count..player..channel
	end

	if (sourceChannel == "PARTY") then --Adjust the source if its party.
		sourceChannel = "RAID"
	end

	if (requestType == "QUERY") then --AskPrice query was received by someone and is requesting prices for that query.
		if (
			(
				(channel == "GUILD")
				and
				(private.guildUsers[1] == private.playerName)
			) or (
				(channel == "RAID")
				and
				(private.raidUsers[1] == private.playerName)
			)
		) then
			private.requestQueue[request] = {
				timer = GetTime(),

				itemLink = link,
				stackCount = tonumber(count),
				sourcePlayer = player,
				sourceChannel = channel,

				totalPrice = 0,
				answerCount = 0,
				totalSeenCount = 0,
			}
		end

		local seenCount, marketValue, vendorPrice = private.getData(link)
		private.sendAddOnMessage(sourceChannel, "PRICE", link, count, player, channel, marketValue, seenCount, vendorPrice)
	elseif (requestType == "PRICE") then --AskPrice users are responding to the query. We only listen to these if we were the announcer when the QUERY event that pertained to this PRICE event was fired (see above)
		if (private.requestQueue[request]) then
			--Better stat average formula for each response: total = total + (price * seen) count = count + seen end  average = total/count
			local request = private.requestQueue[request]
			local count = request.totalSeenCount + totalSeenCount
			local total = request.totalPrice + (totalPrice * totalSeenCount)

			request.totalPrice = total
			request.totalSeenCount = count
			request.vendorPrice = request.vendorPrice or tonumber(vendorPrice)
			request.answerCount = request.answerCount + 1
		end
	elseif (requestType == "WFAIL") then --Whisper failed (Announcer is being ignored)
		if (
			(
				(channel == "GUILD")
				and
				private.binarySearch(private.guildUsers, private.playerName) == private.binarySearch(private.guildUsers, sourcePlayer) + 1
			) or (
				(channel == "RAID")
				and
				private.binarySearch(private.raidUsers, private.playerName) == private.binarySearch(private.raidUsers, sourcePlayer) + 1
			)
		) then
			local details = {
				timer = GetTime(),

				itemLink = link,
				stackCount = count,
				sourcePlayer = player,
				sourceChannel = channel,

				totalPrice = totalPrice,
				vendorPrice = vendorPrice,
				answerCount = answerCount,
				totalSeenCount = totalSeenCount
			}

			private.sendRequest(request, details)
		end
	elseif (requestType == "MAINR") then --General type of request (Version, login, etc)
		local subRequest = link

		if (subRequest == "login") then
			private.sendAddOnMessage(sourceChannel, "MAINR", "online")

		elseif (subRequest == "online") or (subRequest == "logout") then
			local askPriceUserList
			if (sourceChannel == "GUILD") then
				askPriceUserList = private.guildUsers
			elseif ((sourceChannel == "PARTY") or (sourceChannel == "RAID")) then
				askPriceUserList = private.raidUsers
			end

			local insertOrRemoveLocation = private.binarySearch(askPriceUserList, sourcePlayer)

			if (subRequest == "online") then
				if (not (askPriceUserList[insertOrRemoveLocation] == sourcePlayer)) then
					table.insert(askPriceUserList, insertOrRemoveLocation, sourcePlayer)
				end

			elseif (subRequest == "logout") then
				if (askPriceUserList[insertOrRemoveLocation] == sourcePlayer) then
					table.remove(askPriceUserList, insertOrRemoveLocation, sourcePlayer)
				end
			end

		elseif (subRequest == "version") then
			private.sendAddOnMessage(sourceChannel, "MAINR", "version:", private.GetVersion())
		end
	end
end

function private.beingIgnored(sourcePlayer)
	--Check the sent queue for occurances of the ignored player
	for request, details in pairs(private.sentRequest) do
		if (details.sourcePlayer == sourcePlayer) then
			local link, count, player, channel = details.itemLink, details.stackCount, details.sourcePlayer, details.sourceChannel
			local totalPrice, totalSeenCount, vendorPrice, answerCount = details.totalPrice, details.totalSeenCount, details.vendorPrice, details.answerCount
			private.sendAddOnMessage(sourceChannel, "WFAIL", link, count, player, channel, totalPrice, totalSeenCount, vendorPrice, answerCount)
		end
	end
end

--This will retrieve current online Guild members and remove anyone no longer online from the Guild AskPrice users list
function private.guildRosterEvent()
	if not (IsInGuild() and GetGuildInfo("player")) then
		return
	end

	for name in pairs(private.guildRoster) do
		private.guildRoster[name] = nil
	end

	for i = 1, GetNumGuildMembers(true) do
		local name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i)
		if (name and online) then
			private.guildRoster[name] = true
		end
	end

	for index, name in ipairs(private.guildUsers) do
	    if not private.guildRoster[name] then --Person is no longer online
			table.remove(private.guildUsers, index)
	    end
	end
end

function private.raidRosterEvent(...) --TODO: There MUST be a better way of doing this
	private.sendAddOnMessage("RAID", "MAINR", "login") --Always send a login event, since groups are volatile

	--Clear out the table in preparation for the online events to fire
	for i = #private.raidUsers, 1, -1 do
		private.raidUsers[i] = nil
	end
end

function private.GetVersion()
	return tonumber(("$Revision$"):match("(%d+)"))
end

local function compDefault(a, b) return a < b end
function private.binarySearch(table, value, compFunction)
	compFunction = compFunction or compDefault

	local startIndex, endIndex, middleIndex, stateIndex = 1, #table, 1, 0

	while (startIndex <= endIndex) do
		middleIndex = math.floor((startIndex + endIndex) / 2)

		if (compFunction(value, table[middleIndex])) then
			endIndex, stateIndex = middleIndex - 1, 0
		else
			startIndex, stateIndex = middleIndex + 1, 1
		end
	end

	local finalIndex = middleIndex + stateIndex
	if (table[finalIndex - 1] == value) then
		return finalIndex - 1
	else
		return finalIndex
	end
end

--[[ Configator Section ]]--
private.defaults = {
	["util.askprice.activated"]    = true,
	["util.askprice.ad"]           = true,
	["util.askprice.smart"]        = true,
	["util.askprice.trigger"]      = "?",
	["util.askprice.vendor"]       = false,
	["util.askprice.whispers"]     = true,
	["util.askprice.word1"]        = "what",
	["util.askprice.word2"]        = "worth",
}

function private.getOption(option)
	return AucAdvanced.Settings.GetSetting(option)
end

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	id = gui:AddTab(libName, libType.." Modules")
	gui:MakeScrollable(id)

	gui:AddHelp(id, "what askprice",
		"What is AskPrice and what does it do?",
		"AskPrice is a module that allows other players to obtain the values of items by sending special messages "..
		"to various channels, or by sending those messages to you directly, via whisper.")

	gui:AddControl(id, "Header",     0,    libName.." options")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.activated", "Respond to queries for item market values sent via chat.")
	gui:AddTip(id, "This checkbox will enable or disable the module")

	gui:AddHelp(id, "what triggers",
		"What are these triggers, and how are they used?",
		"The triggers control how someone needs to ask you for the price.\n"..
		"The Custom Smartwords allow Auctioneer to respond to natural language queries, while the Trigger Character allows for querying stack sizes\n\n"..
		"Custom smartwords defaults respond to \"what is [item link] worth?\"\n"..
		"Trigger character defaults respond to \"? (stack size) [item link]\"")

	gui:AddControl(id, "Subhead",    0,    "Triggers:")
	gui:AddControl(id, "Text",       0, 1, "util.askprice.word1", "Askprice Custom SmartWord #1")
	gui:AddTip(id, "The smart words allow for natural language queries")
	gui:AddControl(id, "Text",       0, 1, "util.askprice.word2", "Askprice Custom SmartWord #2")
	gui:AddTip(id, "The smart words allow for natural language queries")
	gui:AddControl(id, "Text",       0, 1, "util.askprice.trigger", "Askprice Trigger character")
	gui:AddTip(id, "The trigger character allows for querying total price of a stack")

	gui:AddControl(id, "Subhead",    0,    "Miscellaneous:")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.ad", "Enable new AskPrice features ad.")
	gui:AddTip(id, "If enabled, will send players who ask for prices a message telling them how to use the trigger character")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.smart", "Enable SmartWords checking.")
	gui:AddTip(id, "If enabled, will enable responses to the SmartWords")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.vendor", "Enable the sending of vendor pricing data.")
	gui:AddTip(id, "Allows you to enable sending the vendor price")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.whispers", "Show outgoing whispers from Askprice.")
	gui:AddTip(id, "Shows (enabled) or hides (disabled) outgoing whispers from Askprice.")

end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")