--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	Auctioneer utility functions.
	Functions to maniuplate items keys, signatures etc

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
		along with this program(see GLP.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]
-- Auction time constants
TIME_LEFT_SHORT = 1;
TIME_LEFT_MEDIUM = 2;
TIME_LEFT_LONG = 3;
TIME_LEFT_VERY_LONG = 4;

TIME_LEFT_SECONDS = {
	[0] = 0,		-- Could expire any second... the current bid is relatively accurate.
	[1] = 1800,		-- If it disappears within 30 mins of last seing it, it was BO'd
	[2] = 7200,		-- Ditto but for 2 hours.
	[3] = 28800,	-- 8 hours.
	[4] = 86400,	-- 24 hours.
}

-- Item quality constants
QUALITY_LEGENDARY	=	5;
QUALITY_EPIC		=	4;
QUALITY_RARE		=	3;
QUALITY_UNCOMMON	=	2;
QUALITY_COMMON		=	1;
QUALITY_POOR		=	0;

-- return the string representation of the given timeLeft constant
function Auctioneer_GetTimeLeftString(timeLeft)
	local timeLeftString = "";

	if timeLeft == TIME_LEFT_SHORT then
		timeLeftString = _AUCT('TimeShort');

	elseif timeLeft == TIME_LEFT_MEDIUM then
		timeLeftString = _AUCT('TimeMed');

	elseif timeLeft == TIME_LEFT_LONG then
		timeLeftString = _AUCT('TimeLong');

	elseif timeLeft == TIME_LEFT_VERY_LONG then
		timeLeftString = _AUCT('TimeVlong');
	end

	return timeLeftString;
end

function Auctioneer_GetSecondsLeftString(secondsLeft)
	local timeLeft = nil;

	for i = table.getn(TIME_LEFT_SECONDS), 1, -1 do

		if (secondsLeft >= TIME_LEFT_SECONDS[i]) then
			timeLeft = i;
			break
		end
	end

	return Auctioneer_GetTimeLeftString(timeLeft);
end

function Auctioneer_GetGSC(money)
	local g,s,c = EnhTooltip.GetGSC(money);
	return g,s,c;
end

function Auctioneer_GetTextGSC(money)
	return EnhTooltip.GetGSC(money);
end

-- return an empty string if str is nil
function nilSafeString(str)
	if (not str) then str = "" end
	return str;
end

function Auctioneer_ColorTextWhite(text)
	if (not text) then text = ""; end

	local COLORING_START = "|cff%s%s|r";
	local WHITE_COLOR = "e6e6e6";

	return string.format(COLORING_START, WHITE_COLOR, ""..text);
end

function Auctioneer_GetWarnColor(warn)
	--Make "warn" a required parameter and verify that its a string
	if (not warn) or (not type(warn) == "String") then 
		return nil 
	end

	local cHex, cRed, cGreen, cRed;

	if (Auctioneer_GetFilter('warn-color')) then
		local FrmtWarnAbovemkt, FrmtWarnUndercut, FrmtWarnNocomp, FrmtWarnAbovemkt, FrmtWarnMarkup, FrmtWarnUser, FrmtWarnNodata, FrmtWarnMyprice

		FrmtWarnToolow = string.sub(_AUCT('FrmtWarnToolow'), 1, -5);
		FrmtWarnUndercut = string.sub(_AUCT('FrmtWarnUndercut'), 1, -5);
		FrmtWarnNocomp = string.sub(_AUCT('FrmtWarnNocomp'), 1, -5);
		FrmtWarnAbovemkt = string.sub(_AUCT('FrmtWarnAbovemkt'), 1, -5);
		FrmtWarnMarkup = string.sub(_AUCT('FrmtWarnMarkup'), 1, -5);
		FrmtWarnUser = string.sub(_AUCT('FrmtWarnUser'), 1, -5);
		FrmtWarnNodata = string.sub(_AUCT('FrmtWarnNodata'), 1, -5);
		FrmtWarnMyprice = string.sub(_AUCT('FrmtWarnMyprice'), 1, -5);

		if (string.find(warn, FrmtWarnToolow)) then
			--Color Red
			cHex = "ffff0000";
			cRed = 1.0;
			cGreen = 0.0;
			cBlue = 0.0;

		elseif (string.find(warn, FrmtWarnUndercut)) then
			--Color Yellow
			cHex = "ffffff00";
			cRed = 1.0;
			cGreen = 1.0;
			cBlue = 0.0;

		elseif (string.find(warn, FrmtWarnNocomp) or string.find(warn, FrmtWarnAbovemkt)) then
			--Color Green
			cHex = "ff00ff00";
			cRed = 0.0;
			cGreen = 1.0;
			cBlue = 0.0;

		elseif (string.find(warn, FrmtWarnMarkup) or string.find(warn, FrmtWarnUser) or string.find(warn, FrmtWarnNodata) or string.find(warn, FrmtWarnMyprice)) then
			--Color Gray
			cHex = "ff999999";
			cRed = 0.6;
			cGreen = 0.6;
			cBlue = 0.6;
		end

	else
		--Color Orange
		cHex = "ffe66600";
		cRed = 0.9;
		cGreen = 0.4;
		cBlue = 0.0;
	end

	return cHex, cRed, cGreen, cBlue
end

-- Used to convert variables that should be numbers but are nil to 0
function nullSafe(val)
	if (val == nil) then return 0; end
	if (0 + val > 0) then return 0 + val; end
	return 0;
end

-- We don't use this function anymore but other code may.
function Auctioneer_SanifyAHSnapshot()
	return Auctioneer_GetAuctionKey();
end

-- Returns the current faction's auction signature
function Auctioneer_GetAuctionKey()
	local serverName = GetCVar("realmName");
	local currentZone = GetMinimapZoneText();
	local factionGroup;

	--Added the ability to record Neutral AH auctions in its own tables.
	if ((currentZone == "Gadgetzan") or (currentZone == "Everlook") or (currentZone == "Booty Bay")) then
		factionGroup = "Neutral"

	else 
		factionGroup = UnitFactionGroup("player");
	end
	return serverName.."-"..factionGroup;
end

-- Returns the current faction's opposing faction's auction signature
function Auctioneer_GetOppositeKey()
	local serverName = GetCVar("realmName");
	local factionGroup = UnitFactionGroup("player");

	if (factionGroup == "Alliance") then factionGroup="Horde"; else factionGroup="Alliance"; end
	return serverName.."-"..factionGroup;
end

-- Returns the current faction's opposing faction's auction signature
function Auctioneer_GetNeutralKey()
	local serverName = GetCVar("realmName");

	return serverName.."-Neutral";
end

-- Returns the current faction's opposing faction's auction signature
function Auctioneer_GetHomeKey()
	local serverName = GetCVar("realmName");
	local factionGroup = UnitFactionGroup("player");

	return serverName.."-"..factionGroup;
end

-- function returns true, if the given parameter is a valid option for the also command, false otherwise
function Auctioneer_IsValidAlso(also)
	if (type(also) ~= "string") then
		return false
	end

	if ((also == 'opposite') or (also == 'off') or (also == 'neutral') or (also == 'home')) then
		return true		-- allow special keywords
	end

	-- check if string matches: "[realm]-[faction]"
	local s, e, r, f = string.find(also, "^(.+)-(.+)$")
	if (s == nil) then
		return false	-- invalid string
	end

	-- check if faction = "Horde" or "Alliance"
	if (f == 'Horde') or (f == 'Alliance')or (f == 'Neutral') then
		return true
	end

	return true
end

Auctioneer_BreakLink = EnhTooltip.BreakLink;
Auctioneer_FindItemInBags = EnhTooltip.FindItemInBags;


-- Given an item key, breaks it into it's itemID, randomProperty and enchantProperty
function Auctioneer_BreakItemKey(itemKey)
	local i,j, itemID, randomProp, enchant = string.find(itemKey, "(%d+):(%d+):(%d+)");
	return tonumber(itemID or 0), tonumber(randomProp or 0), tonumber(enchant or 0);
end


function Auctioneer_Split(str, at)
	local splut = {};

	if (type(str) ~= "string") then return nil end
	if (not str) then str = "" end

	if (not at)
		then table.insert(splut, str)

	else
		for n, c in string.gfind(str, '([^%'..at..']*)(%'..at..'?)') do
			table.insert(splut, n);

			if (c == '') then break end
		end
	end
	return splut;
end

function Auctioneer_FindClass(cName, sName)

	if (AuctionConfig and AuctionConfig.classes) then 

		for class, cData in pairs(AuctionConfig.classes) do

			if (cData.name == cName) then
				if (sName == nil) then return class, 0; end

				for sClass, sData in pairs(cData) do
					if (sClass ~= "name") and (sData == sName) then
						return class, sClass;
					end
				end
				return class, 0;
			end
		end
	end
	return 0,0;
end

function Auctioneer_GetCatName(number)
	if (number == 0) then return "" end;

	if (AuctionConfig.classes[number]) then
		return AuctionConfig.classes[number].name;
	end
	return nil;
end

function Auctioneer_GetCatNumberByName(name)
	if (not name) then return 0 end
	if (AuctionConfig and AuctionConfig.classes) then 

		for cat, class in pairs(AuctionConfig.classes) do
			if (name == class.name) then
				return cat;
			end
		end
	end
	return 0;
end

function Auctioneer_GetCatForKey(itemKey)
	local info = Auctioneer_GetInfo(itemKey);
	return info.category;
end

function Auctioneer_GetKeyFromSig(auctSig)
	local id, rprop, enchant = Auctioneer_GetItemSignature(auctSig);
	return id..":"..rprop..":"..enchant;
end

function Auctioneer_GetCatForSig(auctSig)
	local itemKey = Auctioneer_GetKeyFromSig(auctSig);
	return Auctioneer_GetCatForKey(itemKey);
end


function Auctioneer_GetItemLinks(str)
	if (not str) then return nil end
	local itemList = {};
	local listSize = 0;

	for link, item in string.gfind(str, "|Hitem:([^|]+)|h[[]([^]]+)[]]|h") do
		listSize = listSize+1;
		itemList[listSize] = item.." = "..link;
	end
	return itemList;
end


function Auctioneer_GetItems(str)
	if (not str) then return nil end
	local itemList = {};
	local listSize = 0;
	local itemKey;

	for itemID, randomProp, enchant, uniqID in string.gfind(str, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h") do
		itemKey = itemID..":"..randomProp..":"..enchant;
		listSize = listSize+1;
		itemList[listSize] = itemKey;
	end
	return itemList;
end

--Many thanks to the guys at irc://irc.datavertex.com/cosmostesters for their help in creating this function
function Auctioneer_GetItemHyperlinks(str)
	if (not str) then return nil end
	local itemList = {};
	local listSize = 0;

	for color, item, name in string.gfind(str, "|c(%x+)|Hitem:(%d+:%d+:%d+:%d+)|h%[(.-)%]|h|r") do
		listSize = listSize+1;
		itemList[listSize] = "|c"..color.."|Hitem:"..item.."|h["..name.."]|h|r"
	end
	return itemList;
end

function Auctioneer_LoadCategories()
	if (not AuctionConfig.classes) then AuctionConfig.classes = {} end
	Auctioneer_LoadCategoryClasses(GetAuctionItemClasses());
end

function Auctioneer_LoadCategoryClasses(...)
	for c=1, arg.n, 1 do
		AuctionConfig.classes[c] = {};
		AuctionConfig.classes[c].name = arg[c];
		Auctioneer_LoadCategorySubClasses(c, GetAuctionItemSubClasses(c));
	end
end

function Auctioneer_LoadCategorySubClasses(c, ...)
	for s=1, arg.n, 1 do
		AuctionConfig.classes[c][s] = arg[s];
	end
end

function Auctioneer_ChatPrint(text, cRed, cGreen, cBlue, cAlpha, holdTime)
	local frameIndex = Auctioneer_GetFrameIndex();

	if (cRed and cGreen and cBlue) then
		if getglobal("ChatFrame"..frameIndex) then
			getglobal("ChatFrame"..frameIndex):AddMessage(text, cRed, cGreen, cBlue, cAlpha, holdTime);

		elseif (DEFAULT_CHAT_FRAME) then 
			DEFAULT_CHAT_FRAME:AddMessage(text, cRed, cGreen, cBlue, cAlpha, holdTime);
		end

	else
		if getglobal("ChatFrame"..frameIndex) then
			getglobal("ChatFrame"..frameIndex):AddMessage(text, 0.0, 1.0, 0.25);

		elseif (DEFAULT_CHAT_FRAME) then 
			DEFAULT_CHAT_FRAME:AddMessage(text, 0.0, 1.0, 0.25);
		end
	end
end

function Auctioneer_SetFilterDefaults()
	if (not AuctionConfig.filters) then
		AuctionConfig.filters = {};
	end

	for k,v in ipairs(Auctioneer_FilterDefaults) do
		if (AuctionConfig.filters[k] == nil) then
			AuctionConfig.filters[k] = v;
		end
	end
end

-- Pass true to protect the Auction Frame from being undesireably closed, not true to disable this
function Auctioneer_ProtectAuctionFrame(enable)
	--Make sure we have an AuctionFrame before doing anything
	if (AuctionFrame) then
		--Handle enabling of protection

		if (enable and not Auctioneer_ProtectionEnabled and AuctionFrame:IsShown()) then
			--Remember that we are now protecting the frame
			Auctioneer_ProtectionEnabled = true;
			--If the frame is the current doublewide frame, then clear the doublewide

			if ( GetDoublewideFrame() == AuctionFrame ) then
				SetDoublewideFrame(nil)
			end
			--Remove the frame from the UI frame handling system
			UIPanelWindows["AuctionFrame"] = nil
			--If mobile frames is around, then remove AuctionFrame from Mobile Frames handling system

			if (MobileFrames_UIPanelWindowBackup) then
				MobileFrames_UIPanelWindowBackup.AuctionFrame = nil;
			end

			if (MobileFrames_UIPanelsVisible) then
				MobileFrames_UIPanelsVisible.AuctionFrame = nil;
			end
			--Hook the function to show the WorldMap, WorldMap has internal code that forces all these frames to close
			--so for it, we have to prevent it from showing at all

			if (not Auctioneer_ToggleWorldMap) then
				Auctioneer_ToggleWorldMap = ToggleWorldMap;
			end
			ToggleWorldMap = function ()

				if ( ( not Auctioneer_ProtectionEnabled ) or ( not ( AuctionFrame and AuctionFrame:IsVisible() ) ) ) then
					Auctioneer_ToggleWorldMap();

				else
					UIErrorsFrame:AddMessage(_AUCT('GuiNoWorldMap'), 0, 1, 0, 1.0, UIERRORS_HOLD_TIME)
				end
			end

		elseif (Auctioneer_ProtectionEnabled) then
			--Handle disabling of protection
			Auctioneer_ProtectionEnabled = nil;
			--If Mobile Frames is around, then put the frame back under its control if it is proper to do so

			if ( MobileFrames_UIPanelWindowBackup and MobileFrames_MasterEnableList and MobileFrames_MasterEnableList["AuctionFrame"] ) then
				MobileFrames_UIPanelWindowBackup.AuctionFrame = { area = "doublewide", pushable = 0 };

				if ( MobileFrames_UIPanelsVisible and AuctionFrame:IsVisible() ) then
					MobileFrames_UIPanelsVisible.AuctionFrame = 0;
				end

			else
				--Put the frame back into the UI frame handling system
				UIPanelWindows["AuctionFrame"] = { area = "doublewide", pushable = 0 };

				if ( AuctionFrame:IsVisible() ) then
					SetDoublewideFrame(AuctionFrame)
				end
			end
		end
	end
end

function Auctioneer_Round(x)
	local y = math.floor(x);

	if (x - y >= 0.5) then
		return y + 1;
	end
	return y;
end

-------------------------------------------------------------------------------
-- Localization functions
-------------------------------------------------------------------------------

Auctioneer_CommandMap = nil;
Auctioneer_CommandMapRev = nil;

function Auctioneer_DelocalizeFilterVal(value)
	if (value == _AUCT('CmdOn')) then
		return 'on';

	elseif (value == _AUCT('CmdOff')) then
		return 'off';

	elseif (value == _AUCT('CmdDefault')) then
		return 'default';

	elseif (value == _AUCT('CmdToggle')) then
		return 'toggle';

	else
		return value;
	end	
end

function Auctioneer_LocalizeFilterVal(value)
	local result

	if (value == 'on') then
		result = _AUCT('CmdOn');

	elseif (value == 'off') then
		result = _AUCT('CmdOff');

	elseif (value == 'default') then
		result = _AUCT('CmdDefault');

	elseif (value == 'toggle') then
		result = _AUCT('CmdToggle');
	end

	if (result) then return result; else return value; end
end

function Auctioneer_GetLocalizedFilterVal(key)
	return Auctioneer_LocalizeFilterVal(Auctioneer_GetFilterVal(key))
end

-- Turns a localized slash command into the generic English version of the command
function Auctioneer_DelocalizeCommand(cmd)
	if (not Auctioneer_CommandMap) then Auctioneer_BuildCommandMap();end
	local result = Auctioneer_CommandMap[cmd];

	if (result) then return result; else return cmd; end
end

-- Translate a generic English slash command to the localized version, if available
function Auctioneer_LocalizeCommand(cmd)
	if (not Auctioneer_CommandMapRev) then Auctioneer_BuildCommandMap(); end
	local result = Auctioneer_CommandMapRev[cmd];

	if (result) then return result; else return cmd; end
end

-------------------------------------------------------------------------------
-- Inventory modifying functions
-------------------------------------------------------------------------------

function Auctioneer_FindEmptySlot()
	local name, i
	for bag = 0, 4 do
		name = GetBagName(bag)
		i = string.find(name, '(Quiver|Ammo|Bandolier)')
		if not i then
			for slot = 1, GetContainerNumSlots(bag),1 do
				if not (GetContainerItemInfo(bag,slot)) then
					return bag, slot;
				end
			end
		end
	end
end


function Auctioneer_ContainerFrameItemButton_OnClick(hookParams, returnValue, button, ignoreShift)
	local bag = this:GetParent():GetID()
	local slot = this:GetID()

	local texture, count, noSplit = GetContainerItemInfo(bag, slot)
	if (count and count > 1 and not noSplit) then
		if (button == "RightButton") and (IsControlKeyDown()) then
			local splitCount = math.floor(count / 2)
			local emptyBag, emptySlot = Auctioneer_FindEmptySlot()
			if (emptyBag) then
				SplitContainerItem(bag, slot, splitCount)
				PickupContainerItem(emptyBag, emptySlot)
			else
				Auctioneer_ChatPrint("Can't split, all bags are full")
			end
			return
		end
	end

	if (AuctionFrame and AuctionFrame:IsVisible()) then
		local link = GetContainerItemLink(bag, slot)
		if (link) then
			if (button == "RightButton") and (IsAltKeyDown()) then
				AuctionFrameTab_OnClick(1)
				local itemID = EnhTooltip.BreakLink(link)
				if (itemID) then
					local itemName = GetItemInfo(tostring(itemID))
					if (itemName) then
						BrowseName:SetText(itemName)
						BrowseMinLevel:SetText("")
						BrowseMaxLevel:SetText("")
						AuctionFrameBrowse.selectedInvtype = nil
						AuctionFrameBrowse.selectedInvtypeIndex = nil
						AuctionFrameBrowse.selectedClass = nil
						AuctionFrameBrowse.selectedClassIndex = nil
						AuctionFrameBrowse.selectedSubclass = nil
						AuctionFrameBrowse.selectedSubclassIndex = nil
						AuctionFrameFilters_Update()
						IsUsableCheckButton:SetChecked(0)
						UIDropDownMenu_SetSelectedValue(BrowseDropDown, -1)
						AuctionFrameBrowse_Search()
						BrowseNoResultsText:SetText(BROWSE_NO_RESULTS)
					end
				end
				return
			end
		end
	end

	if (not CursorHasItem() and AuctionFrameAuctions and AuctionFrameAuctions:IsVisible() and IsAltKeyDown()) then
		PickupContainerItem(bag, slot)
		if (CursorHasItem() and Auctioneer_GetFilter('auction-click')) then
			ClickAuctionSellItemButton()
			AuctionsFrameAuctions_ValidateAuction()
			local start = MoneyInputFrame_GetCopper(StartPrice)
			local buy = MoneyInputFrame_GetCopper(BuyoutPrice)
			local duration = AuctionFrameAuctions.duration
			local warn = AuctionInfoWarnText:GetText()
			if (AuctionsCreateAuctionButton:IsEnabled() and IsShiftKeyDown()) then
				warn = ("|c"..Auctioneer_GetWarnColor(warn)..warn.."|r")
				StartAuction(start, buy, duration);
				Auctioneer_ChatPrint(string.format(_AUCT('FrmtAutostart'), EnhTooltip.GetTextGSC(start), EnhTooltip.GetTextGSC(buy), duration/60, warn));
			end
			return
		end
	end

	if (not CursorHasItem() and AuctionFramePost and AuctionFramePost:IsVisible() and button == "LeftButton" and IsAltKeyDown()) then
		local _, count = GetContainerItemInfo(bag, slot);
		if (count) then
			if (count > 1 and IsShiftKeyDown()) then
				this.SplitStack = function(button, split)
					local link = GetContainerItemLink(bag, slot)
					local _, _, _, _, name = Auctioneer_BreakLink(link);
					AuctionFramePost:SetAuctionItem(bag, slot, split);
				end
				OpenStackSplitFrame(count, this, "BOTTOMRIGHT", "TOPRIGHT");
			else
				local link = GetContainerItemLink(bag, slot)
				local _, _, _, _, name = Auctioneer_BreakLink(link);
				AuctionFramePost:SetAuctionItem(bag, slot, 1);
			end
			return
		end
	end
end
