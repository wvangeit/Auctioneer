--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	Auctioneer utility functions.
	Functions to maniuplate items keys, signatures etc
]]
-- Auction time constants
TIME_LEFT_SHORT = 1;
TIME_LEFT_MEDIUM = 2;
TIME_LEFT_LONG = 3;
TIME_LEFT_VERY_LONG = 4;

TIME_LEFT_SECONDS = {
	[0] = 0,      -- Could expire any second... the current bid is relatively accurate.
	[1] = 1800,   -- If it disappears within 30 mins of last seing it, it was BO'd
	[2] = 7200,   -- Ditto but for 2 hours.
	[3] = 28800,  -- 8 hours.
	[4] = 86400,  -- 24 hours.
}

-- Item quality constants
QUALITY_EPIC = 4;
QUALITY_RARE = 3;
QUALITY_UNCOMMON = 2;
QUALITY_COMMON= 1;
QUALITY_POOR= 0;

-- return the string representation of the given timeLeft constant
function Auctioneer_GetTimeLeftString(timeLeft)
	local timeLeftString = "";
	if timeLeft == TIME_LEFT_SHORT then
		timeLeftString = _AUCT['TimeShort'];
	elseif timeLeft == TIME_LEFT_MEDIUM then
		timeLeftString = _AUCT['TimeMed'];
	elseif timeLeft == TIME_LEFT_LONG then
		timeLeftString = _AUCT['TimeLong'];
	elseif timeLeft == TIME_LEFT_VERY_LONG then
		timeLeftString = _AUCT['TimeVlong'];
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
	local factionGroup = UnitFactionGroup("player");
	return serverName.."-"..factionGroup;
end

-- Returns the current faction's opposing faction's auction signature
function Auctioneer_GetOppositeKey()
	local serverName = GetCVar("realmName");
	local factionGroup = UnitFactionGroup("player");
	if (factionGroup == "Alliance") then factionGroup="Horde"; else factionGroup="Alliance"; end
	return serverName.."-"..factionGroup;
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

-- function returns true, if the given parameter is a valid option for the also command, false otherwise
function Auctioneer_IsValidAlso(also)
	if (also == nil or type(also) ~= "string") then
		return false
	end

	if (also == 'opposite') or (also == 'off') then
		return true	-- allow special keywords
	end

	-- check if string matches: "[realm]-[faction]"
	local s, e, r, f = string.find(also, "^(.+)-(.+)$")
	if (s == nil) then
		return false	-- invalid string
	end

	-- check if faction = "Horde" or "Alliance"
	if (f ~= 'Horde') and (f ~= 'Alliance') then
		return false	-- invalid faction
	end

	return true
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

function Auctioneer_ChatPrint(str)
	if getglobal("ChatFrame"..Auctioneer_GetFrameIndex()) then
		getglobal("ChatFrame"..Auctioneer_GetFrameIndex()):AddMessage(str, 0.0, 1.0, 0.25);
	elseif (DEFAULT_CHAT_FRAME) then 
		DEFAULT_CHAT_FRAME:AddMessage(str, 0.0, 1.0, 0.25);
	end
end

function Auctioneer_SetFilterDefaults()
	for k,v in pairs(Auctioneer_FilterDefaults) do
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
		if (enable) then
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
					UIErrorsFrame:AddMessage(_AUCT['GuiNoWorldMap'], 0, 1, 0, 1.0, UIERRORS_HOLD_TIME)
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

--------------------------------------
--		Localization functions		--
--------------------------------------

Auctioneer_CommandMap = nil;
Auctioneer_CommandMapRev = nil;

function Auctioneer_DelocalizeFilterVal(value)
	if (value == _AUCT['CmdOn']) then
		return 'on';
	elseif (value == _AUCT['CmdOff']) then
		return 'off';
	elseif (value == _AUCT['CmdDefault']) then
		return 'default';
	elseif (value == _AUCT['CmdToggle']) then
		return 'toggle';
	else
		return value;
	end	
end

function Auctioneer_LocalizeFilterVal(value)
	local result
	if (value == 'on') then
		result = _AUCT['CmdOn'];
	elseif (value == 'off') then
		result = _AUCT['CmdOff'];
	elseif (value == 'default') then
		result = _AUCT['CmdDefault'];
	elseif (value == 'toggle') then
		result = _AUCT['CmdToggle'];
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
