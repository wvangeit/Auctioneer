--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

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

	private.frame:SetScript("OnEvent", private.eventHandler)

	AucAdvanced.Const.PLAYERLANGUAGE = GetDefaultLanguage("player");

	Stubby.RegisterFunctionHook("ChatFrame_OnEvent", -200, private.onEventHook);

	--Setup Configator defaults
	for config, value in pairs(private.defaults) do
		AucAdvanced.Settings.SetDefault(config, value)
	end
end


--[[ Local functions ]]--
function private.eventHandler(self, event, text, player, ignoreTrigger)
	--Nothing to do if askprice is disabled
	if (not private.getOption('util.askprice.activated')) then
		return;
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
		return;
	end

	local seenCount, marketValue, vendorPrice, askedCount, items, usedStack, multipleItems;

	-- Check for marker (trigger char or "smart" words) only if the ignore option is not set
	if (not (ignoreTrigger == true)) then --We need to check for "true" here, since Blizzard might decide to send us a fourth parameter.
		if (not (text:sub(1, 1) == private.getOption('util.askprice.trigger'))) then

			--If the trigger char was not found scan the text for SmartWords (if the feature has been enabled)
			if (private.getOption('util.askprice.smart')) then
				-- Check if the custom SmartWords are present in the chat message
				-- Note, that both words must be contained in the text, to be identified as a valid askprice request.
				if (not (
					text:lower():find(private.getOption('util.askprice.word1'), 1, true) and
					text:lower():find(private.getOption('util.askprice.word2'), 1, true)
				)) then
					return;
				end
			else
				return;
			end
		end
	end

	-- Check for itemlink after trigger
	if (not (text:find("|Hitem:"))) then
		return;
	end

	--Parse the text and separate out the different links
	items = private.getItems(text)

	for key, item in ipairs(items) do --Do the items in the order they were recieved.
		seenCount, marketValue, vendorPrice = private.getData(item.link);
		local askedCount;

		--If there are multiple items send a separator line (since we can't send \n's as those would cause DC's)
		if (multipleItems) then
			Auctioneer.AskPrice.SendWhisper("    ", player);
		end

		local strMarketOne
		--If the stackSize is grater than one, add the unit price to the message
		if (item.count > 1) then
			strMarketOne = ("(%s each)"):format(EnhTooltip.GetTextGSC(marketValue, nil, true));
		else
			strMarketOne = ""
		end

		if (seenCount > 0) then
			private.sendWhisper(("%s: Seen %d times at auction total by Auctioneer Advanced"):format(item.link, seenCount), player);
			private.sendWhisper(
				("%sMarket Value: %s%s"):format(
					"    ",
					EnhTooltip.GetTextGSC(marketValue*item.count, nil, true),
					strMarketOne),
				player
			)
		else
			private.sendWhisper(item.link..": "..("Never seen at %s by Auctioneer Advanced"):format(AucAdvanced.GetFaction()), player);
		end

		--Send out vendor info if we have it
		if (private.getOption('util.askprice.vendor') and (vendorPrice > 0)) then

			local strVendOne
			--Again if the stackSize is grater than one, add the unit price to the message
			if (item.count > 1) then
				strVendOne = ("(%s each)"):format(EnhTooltip.GetTextGSC(vendorPrice, nil, true));
			else
				strVendOne = "";
			end

			private.sendWhisper(
				("%sSell to vendor for: %s%s"):format(
					"    ",
					EnhTooltip.GetTextGSC(vendorPrice * item.count, nil, true),
					strVendOne),
				player
			);
		end

		usedStack = usedStack or (item.count > 1)
		multipleItems = true;
	end

	--Once we're done sending out the itemInfo, check if the person used the stack size feature, if not send them the ad message.
	if ((not usedStack) and (private.getOption('util.askprice.ad'))) then
		if (not private.sentAskPriceAd[player]) then --If the player in question has been sent the ad message in this session, don't spam them again.
			private.sentAskPriceAd[player] = true
			private.sendWhisper(("Get stack prices with %sx[ItemLink] (x = stacksize)"):format(private.getOption('util.askprice.trigger')), player)
		end
	end
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
	return itemList;
end

function private.sendWhisper(message, player)
	private.whisperList[message] = true
	SendChatMessage(message, "WHISPER", AucAdvanced.Const.PLAYERLANGUAGE, player)
end

--[[ Configator Section ]]--
private.defaults = {
	["util.askprice.activated"]    = true,
	["util.askprice.ad"]           = true,
	["util.askprice.guild"]        = false,
	["util.askprice.smart"]        = false,
	["util.askprice.party"]        = false,
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
	id = gui:AddTab(libName)
	gui:AddControl(id, "Header",     0,    libName.." options")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.activated", "Respond to queries for item market values sent via chat.")

	gui:AddControl(id, "Subhead",    0,    "Respond from:")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.guild", "Respond to queries made in guild and officer chat.")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.party", "Respond to queries made in party and raid chat.")

	gui:AddControl(id, "Subhead",    0,    "Triggers:")
	gui:AddControl(id, "Text",       0, 1, "util.askprice.word1", "Askprice Custom SmartWord #1")
	gui:AddControl(id, "Text",       0, 1, "util.askprice.word2", "Askprice Custom SmartWord #2")
	gui:AddControl(id, "Text",       0, 1, "util.askprice.trigger", "Askprice Trigger character")

	gui:AddControl(id, "Subhead",    0,    "Miscellaneous:")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.ad", "Enable or disable new AskPrice features ad.")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.smart", "Enable or disable SmartWords checking.")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.vendor", "Enable or disable the sending of vendor pricing data.")
	gui:AddControl(id, "Checkbox",   0, 1, "util.askprice.whispers", "Shows (enabled) or hides (disabled) outgoing whispers from Askprice.")
end
