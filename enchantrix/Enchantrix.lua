--[[

Enchantrix v<%version%>
$Id$

By Norganna
http://enchantrix.sf.net/

This is an addon for World of Warcraft that add a list of what an item 
disenchants into to the items that you mouse-over in the game.

]]
ENCHANTRIX_VERSION = "<%version%>";

-- GUI Init Variables (Added by MentalPower)
Auctioneer_GUI_Registered = nil;
Auctioneer_Khaos_Registered = nil;

EnchantedLocal = {};
EnchantConfig = {};

-- These are market norm prices.
Enchantrix_StaticPrices = {
	[11082] =  7500, -- Greater Astral Essence
	[16203] = 35000, -- Greater Eternal Essence
	[10939] =  3500, -- Greater Magic Essence
	[11135] =  8500, -- Greater Mystic Essence
	[11175] = 30000, -- Greater Nether Essence
	[10998] =  3500, -- Lesser Astral Essence
	[16202] = 10000, -- Lesser Eternal Essence
	[10938] =  1000, -- Lesser Magic Essence
	[11134] =  4000, -- Lesser Mystic Essence
	[11174] = 12000, -- Lesser Nether Essence
	[14344] = 50000, -- Large Brilliant Shard
	[11084] = 10000, -- Large Glimmering Shard
	[11139] = 24500, -- Large Glowing Shard
	[11178] = 70000, -- Large Radiant Shard
	[14343] = 43500, -- Small Brilliant Shard
	[10978] =  3500, -- Small Glimmering Shard
	[11138] =  9000, -- Small Glowing Shard
	[11177] = 32500, -- Small Radiant Shard
	[11176] =  5000, -- Dream Dust
	[16204] = 12500, -- Illusion Dust
	[11083] =   800, -- Soul Dust
	[10940] =   600, -- Strange Dust
	[11137] =  1600, -- Vision Dust
}

local ItemEssences = {};
for name, id in EssenceItemIDs do
	ItemEssences[id] = name;
end


local MAX_BUYOUT_PRICE = 800000;

local MIN_PROFIT_MARGIN = 1000;
local MIN_PERCENT_LESS_THAN_HSP = 20; -- 20% default
local MIN_PROFIT_PRICE_PERCENT = 10; -- 10% default


if (ENCHANTRIX_VERSION == "<".."%version%>") then
	ENCHANTRIX_VERSION = "3.1.DEV";
end

function Enchantrix_CheckTooltipInfo(frame)
	-- If we've already added our information, no need to do it again
	if ( not frame or frame.eDone ) then
		return nil;
	end

	lEnchantrixTooltip = frame;

	if( frame:IsVisible() ) then
		local field = getglobal(frame:GetName().."TextLeft1");
		if( field and field:IsVisible() ) then
			local name = field:GetText();
			if( name ) then
				Enchantrix_AddTooltipInfo(frame, name);
				return nil;
			end
		end
	end
	
	return 1;
end

function Enchantrix_HookTooltip(funcVars, retVal, frame, name, link, quality, count)
	local embed = Enchantrix_GetFilter(ENCH_SHOW_EMBED);

	local sig, sigNR = Enchantrix_SigFromLink(link);

	local _,_,data = Enchantrix_FindSigInBags(sig);
	if (not data) then _,_,data = Enchantrix_FindSigInBags(sigNR); end


	-- Check for correct item quality
	if (data) then
		if (data.quality > -1) and (data.quality < 2) then
			-- The item data says the quality is not right, zero it out.
			EnchantedLocal[sig] = { z = true; };
			EnchantedLocal[sigNR] = { z = true; };
		end
	else
		-- We can't get definative proof that this item is not disenchant quality, 
		-- but the tooltip says it's not good enough quality though so don't display it.
		if (quality) and (quality > -1) and (quality < 2) then return; end
	end

	local disenchantsTo = Enchantrix_GetItemDisenchants(sig, sigNR, name, true);

	local itemID = Enchantrix_BreakLink(link);
	if (Enchantrix_StaticPrices[itemID]) then return end

	-- Process the results
	local totals = disenchantsTo.totals;
	disenchantsTo.totals = nil;
	if (totals and totals.total > 0) then

		-- If it looks quirky, and we haven't disenchanted it, then ignore it...
		if (totals.bCount < 10) and (totals.iCount + totals.biCount < 1) then return; end

		local total = totals.total;
		local note = "";
		if (not totals.exact) then note = "*"; end

		EnhTooltip.AddLine(ENCH_FRMT_DISINTO..note, nil, embed);
		EnhTooltip.LineColor(0.8,0.8,0.2);
		for dSig, counts in disenchantsTo do
			if (counts.rate > 1) then
				EnhTooltip.AddLine(string.format("  %s: %0.1f%% x%0.1f", counts.name, counts.pct, counts.rate), nil, embed);
			else
				EnhTooltip.AddLine(string.format("  %s: %0.1f%%", counts.name, counts.pct), nil, embed);
			end
			EnhTooltip.LineColor(0.6,0.6,0.1);

			if (Enchantrix_GetFilter(ENCH_SHOW_COUNT)) then
				EnhTooltip.AddLine(string.format(ENCH_FRMT_COUNTS, counts.bCount, counts.oCount, counts.dCount), nil, embed);
				EnhTooltip.LineColor(0.5,0.5,0.0);
			end
		end

		if (Enchantrix_GetFilter(ENCH_SHOW_VALUE)) then
			local confidence = totals.conf;

			if (Enchantrix_GetFilter(ENCH_SHOW_GUESS_AUCTIONEER_HSP)) and (totals.hspValue > 0) then
				EnhTooltip.AddLine(ENCH_FRMT_VALUE_AUCT_HSP, totals.hspValue * confidence, embed);
				EnhTooltip.LineColor(0.1,0.6,0.6);
			end
			if (Enchantrix_GetFilter(ENCH_SHOW_GUESS_AUCTIONEER_MED)) and (totals.medValue > 0) then
				EnhTooltip.AddLine(ENCH_FRMT_VALUE_AUCT_MED, totals.medValue * confidence, embed);
				EnhTooltip.LineColor(0.1,0.6,0.6);
			end
			if (Enchantrix_GetFilter(ENCH_SHOW_GUESS_BASELINE)) and (totals.mktValue > 0) then
				EnhTooltip.AddLine(ENCH_FRMT_VALUE_MARKET, totals.mktValue * confidence, embed);
				EnhTooltip.LineColor(0.1,0.6,0.6);
			end
		end
	end
end

function Enchantrix_NameFromLink(link)
	local name;
	if( not link ) then
		return nil;
	end
	for name in string.gfind(link, "|c%x+|Hitem:%d+:%d+:%d+:%d+|h%[(.-)%]|h|r") do
		return name;
	end
	return nil;
end

function Enchantrix_SigFromLink(link)
	local name;
	if( not link ) then
		return nil;
	end
	for id,enchant,rand in string.gfind(link, "|c%x+|Hitem:(%d+):(%d+):(%d+):%d+|h%[.-%]|h|r") do
		local sig = string.format("%s:%s:%s", id, 0, rand);
		local sigNR = string.format("%s:%s:%s", id, 0, 0);
		return sig, sigNR;
	end
	return nil;
end

function Enchantrix_TakeInventory()
	local bagid, slotid, size;
	local inventory = {};

	for bagid = 0, 4, 1 do
		inventory[bagid] = {};

		size = GetContainerNumSlots(bagid);
		if( size ) then
			for slotid = size, 1, -1 do
				inventory[bagid][slotid] = {};

				local link = GetContainerItemLink(bagid, slotid);
				if( link ) then
					local name = Enchantrix_NameFromLink(link);
					local sig = Enchantrix_SigFromLink(link);
					local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bagid, slotid);
					if (quality > -1) and (quality < 2) and (DisenchantList[sig]) then 
						EnchantedLocal = { z = true; };
					end
					if ((not itemCount) or (itemCount < 1)) then
						itemCount = 1;
					end
					if (name) then
						inventory[bagid][slotid].name = name;
						inventory[bagid][slotid].tx = texture;
						inventory[bagid][slotid].sig = sig;
						inventory[bagid][slotid].link = link;
						inventory[bagid][slotid].count = itemCount;
					end
				end
			end
		end
	end
	return inventory;
end

function Enchantrix_FullDiff(invA, invB)
	local bagid, slotid, size;
	local diffData = {};
	local aStuff = {};
	local bStuff = {};

	for bag, bagStuff in invA do
		for slot, slotStuff in bagStuff do
			if (slotStuff.sig) then
				if (not aStuff[slotStuff.sig]) then
					aStuff[slotStuff.sig] = { c=slotStuff.count, n=slotStuff.name, t=slotStuff.tx, l=slotStuff.link };
				else
					aStuff[slotStuff.sig].c = aStuff[slotStuff.sig].c + slotStuff.count;
				end
			end
		end
	end
	for bag, bagStuff in invB do
		for slot, slotStuff in bagStuff do
			if (slotStuff.sig) then
				if (not bStuff[slotStuff.sig]) then
					bStuff[slotStuff.sig] = { c=slotStuff.count, n=slotStuff.name, t=slotStuff.tx, l=slotStuff.link };
				else
					bStuff[slotStuff.sig].c = bStuff[slotStuff.sig].c + slotStuff.count;
				end
			end
		end
	end

	for sig, slotStuff in aStuff do
		local count = slotStuff.c;
		local bCount;
		if (bStuff[sig]) then bCount = bStuff[sig].c; end
		if (bCount == nil) then bCount = 0; end
		if (bCount < count) then
			local diffCount = bCount - count;
			diffData[sig] = { s=sig, d=diffCount, n=slotStuff.n, t=slotStuff.t, l=slotStuff.l };
		end
	end
	for sig, slotStuff in bStuff do
		local count = slotStuff.c;
		local aCount;
		if (aStuff[sig]) then aCount = aStuff[sig].c; end
		if (aCount == nil) then aCount = 0; end
		if (aCount < count) then
			local diffCount = count - aCount;
			diffData[sig] = { s=sig, d=diffCount, n=slotStuff.n, t=slotStuff.t, l=slotStuff.l };
		end
	end
	return diffData;
end

function Enchantrix_OnEvent(funcVars, event, argument)
	
	if ((event == "SPELLCAST_START") and (argument == ENCH_ARG_SPELLNAME)) then
		Enchantrix_Disenchanting = true;
		Enchantrix_WaitingPush = false;
		Enchantrix_StartInv = Enchantrix_TakeInventory();
		Enchantrix_Disenchants = {};

		return;
	end
	if ((event == "SPELLCAST_FAILED") or (event == "SPELLCAST_INTERRUPTED")) then
		Enchantrix_Disenchanting = false;
		Enchantrix_WaitingPush = false;
		return;
	end
	if ((event == "SPELLCAST_STOP") and (Enchantrix_Disenchanting)) then
		Enchantrix_Disenchanting = false;
		Enchantrix_WaitingPush = true;
		return;
	end
	if ((event == "ITEM_PUSH") and (Enchantrix_WaitingPush)) then
		local textureType = strsub(arg2, 1, 28);
		local receivedItem = strsub(arg2, 29);
		if (not receivedItem) then return; end
		if (textureType == "Interface\\Icons\\INV_Enchant_") then
			Enchantrix_Disenchants[arg2] = receivedItem;
			Enchantrix_Disenchants.exists = true;
		end
		return;
	end
	if ((event == "BAG_UPDATE") and (Enchantrix_Disenchants and Enchantrix_Disenchants.exists)) then
		
		-- /script inv = Enchantrix_TakeInventory()
		-- /script p(Enchantrix_FullDiff(inv, Enchantrix_TakeInventory()))
		-- /script p(Enchantrix_FullDiff(Enchantrix_StartInv, Enchantrix_TakeInventory()))
		local nowInv = Enchantrix_TakeInventory();
		local invDiff = Enchantrix_FullDiff(Enchantrix_StartInv, nowInv);

		local foundItem = "";
		for sig, data in invDiff do
			if (data.d == -1) then
				if (foundItem ~= "") then
					-- Unable to determine which item was disenchanted, ignore DE to avoid incorrect data
					Enchantrix_Disenchants = {};
					Enchantrix_Disenchanting = false;
					Enchantrix_WaitingPush = false;					
					return;
				end					
				foundItem = data;
			end
		end
		if (foundItem == "") then return; end
		
		local gainedItem = {};
		for sig, data in invDiff do
			if (data.d > 0) and (Enchantrix_Disenchants[data.t]) then
				gainedItem[sig] = data;
			end
		end
		if (next(gainedItem) == nil) then return; end
		
		if (EnchantedLocal[foundItem.n]) then
			EnchantedLocal[foundItem.s] = { o = ""..EnchantedLocal[foundItem.n] };
		end

		local itemData = Enchantrix_GetLocal(foundItem.s);
		
		DEFAULT_CHAT_FRAME:AddMessage(string.format(ENCH_FRMT_FOUND, foundItem.l), 0.8, 0.8, 0.2);
		for sig, data in gainedItem do
			local i,j, strItemID = string.find(sig, "^(%d+):");
			local itemID = 0;
			if (strItemID) then itemID = tonumber(strItemID); end
			if (itemID > 0) and (ItemEssences[itemID]) then
				-- We are interested cause this is an essence that was gained since last snaphot
				local iCount = 0; local dCount = 0;
				local curData = itemData[itemID];
				if (curData == nil) then curData = {}; end
				if (curData.i) then iCount = tonumber(curData.i); end
				if (curData.d) then dCount = tonumber(curData.d); end
				curData.i = ""..(iCount + 1);
				curData.d = ""..(dCount + data.d);
				itemData[itemID] = curData;
				DEFAULT_CHAT_FRAME:AddMessage("  " .. data.n .. " x" .. data.d, 0.6, 0.6, 0.1);
			end
		end
		
		Enchantrix_SaveLocal(foundItem.s, itemData);

		Enchantrix_Disenchants = {};
		Enchantrix_Disenchanting = false;
		Enchantrix_WaitingPush = false;
		
		return
	end
end

function Enchantrix_ChatPrint(str)
	if getglobal("ChatFrame"..Enchantrix_GetFrameIndex()) then
		getglobal("ChatFrame"..Enchantrix_GetFrameIndex()):AddMessage(str, 1.0, 0.5, 0.25);
	end
end

function Enchantrix_OnLoad()
	-- Hook in new tooltip code
	Stubby.RegisterFunctionHook("EnhTooltip.AddTooltip", 400, Enchantrix_HookTooltip)

	Stubby.RegisterAddOnHook("Auctioneer", "Enchantrix", Enchantrix_AuctioneerLoaded);

	Stubby.RegisterEventHook("SPELLCAST_FAILED", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("SPELLCAST_INTERRUPTED", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("SPELLCAST_START", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("SPELLCAST_STOP", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("ITEM_PUSH", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("BAG_UPDATE", "Enchantrix", Enchantrix_OnEvent);

	-- Register our temporary command hook with stubby
	Stubby.RegisterBootCode("Enchantrix", "CommandHandler", [[
		local function cmdHandler(msg)
			local i,j, cmd, param = string.find(string.lower(msg), "^([^ ]+) (.+)$")
			if (not cmd) then cmd = string.lower(msg) end 
			if (not cmd) then cmd = "" end 
			if (not param) then param = "" end
			if (cmd == "load") then
				if (param == "") then
					Stubby.Print("Manually loading Enchantrix...")
					LoadAddOn("Enchantrix")
				elseif (param == "always") then
					Stubby.Print("Setting Enchantrix to always load for this character")
					Stubby.SetConfig("Enchantrix", "LoadType", param)
					LoadAddOn("Enchantrix")
				elseif (param == "never") then
					Stubby.Print("Setting Enchantrix to never load automatically for this character (you may still load manually)")
					Stubby.SetConfig("Enchantrix", "LoadType", param)
				else
					Stubby.Print("Your command was not understood")
				end
			else
				Stubby.Print("Enchantrix is currently not loaded.")
				Stubby.Print("  You may load it now by typing |cffffffff/enchantrix load|r")
				Stubby.Print("  You may also set your loading preferences for this character by using the following commands:")
				Stubby.Print("  |cffffffff/enchantrix load always|r - Enchantrix will always load for this character")
				Stubby.Print("  |cffffffff/enchantrix load never|r - Enchantrix will never load automatically for this character (you may still load it manually)")
			end
		end
		SLASH_ENCHANTRIX1 = "/enchantrix"
		SLASH_ENCHANTRIX2 = "/enchant"
		SLASH_ENCHANTRIX3 = "/enx"
		SlashCmdList["ENCHANTRIX"] = cmdHandler
	]]);
	Stubby.RegisterBootCode("Enchantrix", "Triggers", [[
		local loadType = Stubby.GetConfig("Enchantrix", "LoadType")
		if (loadType == "always") then
			LoadAddOn("Enchantrix")
		else
			Stubby.Print("]]..ENCH_MESG_NOTLOADED..[[")
		end
	]]);

	Enchantrix_DisenchantCount = 0;
	Enchantrix_DisenchantResult = {};
	Enchantrix_Disenchanting = false;
	Enchantrix_WaitingPush = false;

	SLASH_ENCHANTRIX1 = "/enchantrix";
	SLASH_ENCHANTRIX2 = "/enchant";
	SLASH_ENCHANTRIX3 = "/enx";
	SlashCmdList["ENCHANTRIX"] = function(msg)
		Enchantrix_Command(msg);
	end

	--GUI Registration code added by MentalPower	
	Enchantrix_Register();
end

-- This function differs from Enchantrix_OnLoad in that it is executed
-- after variables have been loaded.
function Enchantrix_AddonLoaded()
	Enchantrix_SetLocaleStrings(Enchantrix_GetLocale());
	this:UnregisterEvent("ADDON_LOADED")
		
	Enchantrix_ChatPrint(string.format(ENCH_FRMT_WELCOME, ENCHANTRIX_VERSION), 0.8, 0.8, 0.2);
	Enchantrix_ChatPrint(ENCH_FRMT_CREDIT, 0.6, 0.6, 0.1);
end

function Enchantrix_Register()
	if (Khaos) then
		if (not Enchantrix_Khaos_Registered) then
			Enchantrix_GUI_Registered = Enchantrix_Register_Khaos();
		end
	end
	-- The following check is to accomodate other GUI libraries other than Khaos relatively easily.
	if (Enchantrix_GUI_Registered == true) then
		return true;
	else 
		return false;
	end
end

function Enchantrix_Register_Khaos()
	Enchantrix_optionSet = {
		id="Enchantrix";
		text="Enchantrix";
		helptext=ENCH_GUI_MAIN_HELP;
		difficulty=1;
		default={checked=true};
		options={
			{
				id="Header";
				text="Enchantrix";
				helptext=ENCH_GUI_MAIN_HELP;
				type=K_HEADER;
				difficulty=1;
			};
			{
				id="EnchantrixEnable";
				type=K_TEXT;
				text=ENCH_GUI_MAIN_ENABLE;
				helptext=ENCH_HELP_ONOFF;
				callback=function(state)
					if (state.checked) then
						Enchantrix_OnOff(ENCH_CMD_ON);
					else
						Enchantrix_OnOff(ENCH_CMD_OFF);
					end
				end;
				feedback=function(state)
					if (state.checked) then
						return ENCH_STAT_ON;
					else
						return ENCH_STAT_OFF;
					end
				end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				difficulty=1;
			};
			{
				id="EnchantrixLocale";
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=ENCH_GUI_LOCALE;
				helptext=ENCH_HELP_LOCALE;
				callback = function(state)
					Enchantrix_SetLocale(state.value);
				end;
				feedback = function (state)
					return string.format(ENCH_FRMT_ACT_SET, ENCH_CMD_LOCALE, state.value);
				end;
				default = {
					value = Enchantrix_GetLocale();
				};
				disabled = {
					value = Enchantrix_GetLocale();
				};
				dependencies={EnchantrixEnable={checked=true;}};
				difficulty=2;				
			};
			{
				id="ReloadUI";
				type=K_BUTTON;
				setup={
					buttonText = ENCH_GUI_RELOADUI_BUTTON;
				};
				text=ENCH_GUI_RELOADUI;
				helptext=ENCH_GUI_RELOADUI_HELP;
				callback=function()
					ReloadUI();
				end;
				feedback=function()
					return ENCH_GUI_RELOADUI_FEEDBACK;
				end;
				difficulty=3;
			};
			{
				id=ENCH_SHOW_EMBED;
				type=K_TEXT;
				text=ENCH_GUI_EMBED;
				helptext=ENCH_HELP_EMBED;
				callback=function(state)
					if (state.checked) then
						Enchantrix_GenVarSet(ENCH_SHOW_EMBED, ENCH_CMD_ON);
					else
						Enchantrix_GenVarSet(ENCH_SHOW_EMBED, ENCH_CMD_OFF);
					end
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(ENCH_FRMT_ACT_ENABLE, ENCH_SHOW_EMBED));
					else
						return (string.format(ENCH_FRMT_ACT_DISABLE, ENCH_SHOW_EMBED));
					end
				end;
				check=true;
				default={checked=false};
				disabled={checked=false};
				dependencies={EnchantrixEnable={checked=true;}};
				difficulty=1;
			};
			{
				id="EnchantrixValuateHeader";
				type=K_HEADER;
				text=ENCH_GUI_VALUATE_HEADER;
				helptext=ENCH_HELP_VALUE;
				difficulty=2;
			};
			{
				id=ENCH_SHOW_VALUE;
				key="EnchantrixValuate";
				type=K_TEXT;
				text=ENCH_GUI_VALUATE_ENABLE;
				helptext=ENCH_HELP_VALUE;
				callback=function(state)
					if (state.checked) then
						Enchantrix_GenVarSet(ENCH_SHOW_VALUE, ENCH_CMD_ON);
					else
						Enchantrix_GenVarSet(ENCH_SHOW_VALUE, ENCH_CMD_OFF);
					end
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(ENCH_FRMT_ACT_ENABLE, ENCH_SHOW_VALUE));
					else
						return (string.format(ENCH_FRMT_ACT_DISABLE, ENCH_SHOW_VALUE));
					end
				end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={EnchantrixEnable={checked=true;}};
				difficulty=1;
			};
			{
				id=ENCH_SHOW_GUESS_BASELINE;
				type=K_TEXT;
				text=ENCH_GUI_VALUATE_BASELINE;
				helptext=ENCH_HELP_GUESS_BASELINE;
				callback=function(state)
					if (state.checked) then
						Enchantrix_GenVarSet(ENCH_SHOW_GUESS_BASELINE, ENCH_CMD_ON);
					else
						Enchantrix_GenVarSet(ENCH_SHOW_GUESS_BASELINE, ENCH_CMD_OFF);
					end
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(ENCH_FRMT_ACT_ENABLE, ENCH_SHOW_GUESS_BASELINE));
					else
						return (string.format(ENCH_FRMT_ACT_DISABLE, ENCH_SHOW_GUESS_BASELINE));
					end
				end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={EnchantrixValuate={checked=true;}, EnchantrixEnable={checked=true;}};
				difficulty=2;
			};
			{
				id="EnchantrixOtherHeader";
				type=K_HEADER;
				text=ENCH_GUI_OTHER_HEADER;
				helptext=ENCH_GUI_OTHER_HELP;
				difficulty=1;
			};
			{
				id="EnchantrixClearAll";
				type=K_BUTTON;
				setup={
					buttonText = ENCH_GUI_CLEARALL_BUTTON;
				};
				text=ENCH_GUI_CLEARALL;
				helptext=ENCH_GUI_CLEARALL_HELP;
				callback=function()
					Enchantrix_Clear(ENCH_CMD_CLEAR_ALL);
				end;
				feedback=function()
					return string.format(ENCH_FRMT_ACT_CLEARALL,  ENCH_GUI_CLEARALL_NOTE);
				end;
				dependencies={EnchantrixEnable={checked=true;}};
				difficulty=3;
			};
			{
				id="DefaultAll";
				type=K_BUTTON;
				setup={
					buttonText = ENCH_GUI_DEFAULT_ALL_BUTTON;
				};
				text=ENCH_GUI_DEFAULT_ALL;
				helptext=ENCH_GUI_DEFAULT_ALL_HELP;
				callback=function() 
					Enchantrix_Default(ENCH_CMD_CLEAR_ALL);
				end;
				feedback=function()
					return ENCH_FRMT_ACT_DEFAULT_ALL;
				end;
				dependencies={EnchantrixEnable={checked=true;}};
				difficulty=1;
			};
			{
				id="EnchantrixPrintFrame";
				type=K_PULLDOWN;
				setup = {
					options = Enchantrix_GetFrameNames();
					multiSelect = false;
				};
				text=ENCH_GUI_PRINTIN;
				helptext=ENCH_HELP_PRINTIN;
				callback=function(state)
					Enchantrix_SetFrame(state.value);
				end;
				feedback=function(state)
					local _, frameName = Enchantrix_GetFrameNames(state.value)
					return string.format(ENCH_FRMT_PRINTIN, frameName);
				end;
				default = {
					value=Enchantrix_GetFrameIndex();
				};
				disabled = {
					value=Enchantrix_GetFrameIndex();
				};
				dependencies={EnchantrixEnable={checked=true;}};
				difficulty=3;
			};
			{
				id="DefaultOption";
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=ENCH_GUI_DEFAULT_OPTION;
				helptext=ENCH_HELP_DEFAULT;
				callback = function(state)
					Enchantrix_Default(state.value);
				end;
				feedback = function (state)
					if (state.value == ENCH_CMD_CLEAR_ALL) then
						return ENCH_FRMT_ACT_DEFAULT_ALL;
					else
						return string.format(ENCH_FRMT_ACT_DEFAULT, state.value);
					end
				end;
				default = {
					value = "";
				};
				disabled = {
					value = "";
				};
				dependencies={EnchantrixEnable={checked=true;}};
				difficulty=4;
			};
		};
	};

	Khaos.registerOptionSet("tooltip",Enchantrix_optionSet);
	Enchantrix_Khaos_Registered = true;
	
	return true;
end

function Enchantrix_AuctioneerLoaded()
if (Enchantrix_Khaos_Registered) then
	Enchantrix_ChatPrint("function called");

	if (Enchantrix_optionSet.options[8].id == ENCH_SHOW_GUESS_AUCTIONEER_HSP) then
		Enchantrix_ChatPrint("options already added");
		return nil;
	end
	
	local AuctioneerOptions = {
		{
			id=ENCH_SHOW_GUESS_AUCTIONEER_HSP;
			type=K_TEXT;
			text=ENCH_GUI_VALUATE_AVERAGES;
			helptext=ENCH_HELP_GUESS_AUCTIONEER_HSP;
			callback=function(state)
				if (state.checked) then
					Enchantrix_GenVarSet(ENCH_SHOW_GUESS_AUCTIONEER_HSP, ENCH_CMD_ON);
				else
					Enchantrix_GenVarSet(ENCH_SHOW_GUESS_AUCTIONEER_HSP, ENCH_CMD_OFF);
				end
			end;
			feedback=function(state)
				if (state.checked) then
					return (string.format(ENCH_FRMT_ACT_ENABLE, ENCH_SHOW_GUESS_AUCTIONEER_HSP));
				else
					return (string.format(ENCH_FRMT_ACT_DISABLE, ENCH_SHOW_GUESS_AUCTIONEER_HSP));
				end
			end;
			check=true;
			default={checked=true};
			disabled={checked=false};
			dependencies={EnchantrixAuctioneer={checked=true;}, EnchantrixValuate={checked=true;}, EnchantrixEnable={checked=true;}};
			difficulty=2;
		};
		{
			id=ENCH_SHOW_GUESS_AUCTIONEER_MED;
			type=K_TEXT;
			text=ENCH_GUI_VALUATE_MEDIAN;
			helptext=ENCH_HELP_GUESS_AUCTIONEER_MEDIAN;
			callback=function(state)
				if (state.checked) then
					Enchantrix_GenVarSet(ENCH_SHOW_GUESS_AUCTIONEER_MED, ENCH_CMD_ON);
				else
					Enchantrix_GenVarSet(ENCH_SHOW_GUESS_AUCTIONEER_MED, ENCH_CMD_OFF);
				end
			end;
			feedback=function(state)
				if (state.checked) then
					return (string.format(ENCH_FRMT_ACT_ENABLE, ENCH_SHOW_GUESS_AUCTIONEER_MED));
				else
					return (string.format(ENCH_FRMT_ACT_DISABLE, ENCH_SHOW_GUESS_AUCTIONEER_MED));
				end
			end;
			check=true;
			default={checked=true};
			disabled={checked=false};
			dependencies={EnchantrixAuctioneer={checked=true;}, EnchantrixValuate={checked=true;}, EnchantrixEnable={checked=true;}};
			difficulty=2;
		};
	};

	Enchantrix_ChatPrint("unregistering");
	Khaos.unregisterOptionSet("Enchantrix");
	Enchantrix_ChatPrint("refreshing");
	Khaos.refresh();
	
	Enchantrix_ChatPrint("tinsert 1");
	tinsert (Enchantrix_optionSet.options, 8, AuctioneerOptions[1]);
	Enchantrix_ChatPrint("tinsert2");
	tinsert (Enchantrix_optionSet.options, 9, AuctioneerOptions[2]);

	Enchantrix_ChatPrint("registering");
	Khaos.registerOptionSet("tooltip",Enchantrix_optionSet);
	Enchantrix_ChatPrint("refresh2");
	Khaos.refresh();
	Enchantrix_ChatPrint("end");
	end
end

--Cleaner Command Handling Functions (added by MentalPower)
function Enchantrix_Command(command, source)
	
	--To print or not to print, that is the question...
	local chatprint = nil;
	if (source == "GUI") then 
		chatprint = false;
	else 
		chatprint = true;
	end;
	
	--Divide the large command into smaller logical sections (Shameless copy from the original function)
	local i,j, cmd, param = string.find(command, "^([^ ]+) (.+)$")
	if (not cmd) then cmd = command end
	if (not cmd) then cmd = "" end
	if (not param) then param = "" end

	if ((cmd == "") or (cmd == "help")) then
		Enchantrix_ChatPrint_Help();
		return;

	elseif (((cmd == ENCH_CMD_ON) or (cmd == "on")) or ((cmd == ENCH_CMD_OFF) or (cmd == "off")) or ((cmd == ENCH_CMD_TOGGLE) or (cmd == "toggle"))) then
		Enchantrix_OnOff(cmd, chatprint);

	elseif ((cmd == ENCH_CMD_DISABLE) or (cmd == "disable")) then
		Stubby.SetConfig("Enchantrix", "LoadType", "never");

	elseif (cmd == "load") then
		if (param == "always") or (param == "never") then
			Enchantrix_ChatPrint("Setting Enchantrix to "..param.." load for this toon");
			Stubby.SetConfig("Enchantrix", "LoadType", param);
		end

	elseif ((cmd == ENCH_CMD_CLEAR) or (cmd == "clear")) then
		Auctioneer_Clear(param, chatprint);

	elseif ((cmd == ENCH_CMD_LOCALE) or (cmd == "locale")) then
		Enchantrix_SetLocale(param, chatprint);

	elseif ((cmd == ENCH_CMD_DEFAULT) or (cmd == "default")) then
		Enchantrix_Default(param, chatprint);

	elseif ((cmd == ENCH_CMD_PRINTIN) or (cmd == "print-in")) then
		Enchantrix_SetFrame(param, chatprint)

	--The following are copied verbatim from the original function. These functions are not supported in the current Khaos-based GUI implementation and as such have been left intact.
	elseif (cmd == ENCH_CMD_FIND_BIDAUCT) or (cmd == ENCH_CMD_FIND_BIDAUCT_SHORT) then
		Enchantrix_DoBidBroker(param);

	elseif (cmd == ENCH_CMD_FIND_BUYAUCT) or (cmd == ENCH_CMD_FIND_BUYAUCT_SHORT) then
		Enchantrix_DoPercentLess(param);

	--These commands have been changed to match those used by Auctioneer/Informant. Others have been simplified.
	elseif (
		((cmd == ENCH_SHOW_EMBED) or (cmd == "embed")) or
		((cmd == ENCH_SHOW_HEADER) or (cmd == "header")) or
		((cmd == ENCH_SHOW_COUNT) or (cmd == "counts")) or
		((cmd == ENCH_SHOW_RATE) or (cmd == "rates")) or
		((cmd == ENCH_SHOW_VALUE) or (cmd == "valuate")) or
		((cmd == ENCH_SHOW_GUESS_AUCTIONEER_HSP) or (cmd == "valuate-hsp")) or
		((cmd == ENCH_SHOW_GUESS_AUCTIONEER_MED) or (cmd == "valuate-median")) or
		((cmd == ENCH_SHOW_GUESS_BASELINE) or (cmd == "valuate-baseline"))
	) then
		Enchantrix_GenVarSet(cmd, param, chatprint);

	elseif (chatprint == true) then
		Enchantrix_ChatPrint(string.format(ENCH_FRMT_ACT_UNKNOWN, cmd));
	end
end

--Help ME!! (The Handler) (Another shameless copy from the original function)
function Enchantrix_ChatPrint_Help()
Enchantrix_ChatPrint(ENCH_FRMT_USAGE);
		local onOffToggle = " ("..ENCH_CMD_ON.."|"..ENCH_CMD_OFF.."|"..ENCH_CMD_TOGGLE..")";
		local lineFormat = "  |cffffffff/enchantrix %s "..onOffToggle.."|r |cff2040ff[%s]|r - %s";

		Enchantrix_ChatPrint("  |cffffffff/enchantrix "..onOffToggle.."|r |cff2040ff["..Enchantrix_GetFilterVal("all").."]|r - " .. ENCH_HELP_ONOFF);
		
		Enchantrix_ChatPrint("  |cffffffff/enchantrix "..ENCH_CMD_DISABLE.."|r - " .. ENCH_HELP_DISABLE);

		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_SHOW_HEADER, Enchantrix_GetFilterVal(ENCH_SHOW_HEADER), ENCH_HELP_HEADER));
		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_SHOW_COUNT, Enchantrix_GetFilterVal(ENCH_SHOW_COUNT), ENCH_HELP_COUNT));
		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_SHOW_RATE, Enchantrix_GetFilterVal(ENCH_SHOW_RATE), ENCH_HELP_RATE));
		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_SHOW_EMBED, Enchantrix_GetFilterVal(ENCH_SHOW_EMBED), ENCH_HELP_EMBED));
		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_SHOW_VALUE, Enchantrix_GetFilterVal(ENCH_SHOW_VALUE), ENCH_HELP_VALUE));
		if (AUCTIONEER_VERSION) then
			Enchantrix_ChatPrint(string.format(lineFormat, ENCH_SHOW_GUESS_AUCTIONEER_HSP, Enchantrix_GetFilterVal(ENCH_SHOW_GUESS_AUCTIONEER_HSP), ENCH_HELP_GUESS_AUCTIONEER_HSP));
			Enchantrix_ChatPrint(string.format(lineFormat, ENCH_SHOW_GUESS_AUCTIONEER_MED, Enchantrix_GetFilterVal(ENCH_SHOW_GUESS_AUCTIONEER_MED), ENCH_HELP_GUESS_AUCTIONEER_MEDIAN));
		else
			Enchantrix_ChatPrint(ENCH_HELP_GUESS_NOAUCTIONEER);
		end
		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_SHOW_GUESS_BASELINE, Enchantrix_GetFilterVal(ENCH_SHOW_GUESS_BASELINE), ENCH_HELP_GUESS_BASELINE));

		lineFormat = "  |cffffffff/enchantrix %s %s|r - %s";
		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_CMD_LOCALE, ENCH_OPT_LOCALE, ENCH_HELP_LOCALE));
		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_CMD_CLEAR, ENCH_OPT_CLEAR, ENCH_HELP_CLEAR));
		
		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_CMD_FIND_BIDAUCT, ENCH_OPT_FIND_BIDAUCT, ENCH_HELP_FIND_BIDAUCT));
		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_CMD_FIND_BUYAUCT, ENCH_OPT_FIND_BUYAUCT, ENCH_HELP_FIND_BUYAUCT));
		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_CMD_DEFAULT, ENCH_OPT_DEFAULT, ENCH_HELP_DEFAULT));
		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_CMD_PRINTIN, ENCH_OPT_PRINTIN, ENCH_HELP_PRINTIN));
		
end

--The Enchantrix_OnOff(state, chatprint) function handles the state of the Enchantrix AddOn (whether it is currently on or off)
--If "on" or "off" is specified in the " state" variable then Enchantrix's state is changed to that value,
--If "toggle" is specified then it will toggle Enchantrix's state (if currently on then it will be turned off and vice-versa)
--If no keyword is specified then the function will simply return the current state
--
--If chatprint is "true" then the state will also be printed to the user.

function Enchantrix_OnOff(state, chatprint)

	if ((state == nil) or (state == "")) then
		state = Enchantrix_GetFilterVal("all");


	elseif ((state == ENCH_CMD_ON) or (state == "on")) then
		Enchantrix_SetFilter("all", "on");


	elseif ((state == ENCH_CMD_OFF) or (state == "off")) then
		Enchantrix_SetFilter("all", "off");


	elseif ((state == ENCH_CMD_TOGGLE) or (state == "toggle")) then
		state = Enchantrix_GetFilterVal("all");

		if (state == "off") then
			Enchantrix_SetFilter("all", "on");
		else
			Enchantrix_SetFilter("all", "off");
		end
	end

	--Print the change and alert the GUI if the command came from slash commands. Do nothing if they came from the GUI.
	if (chatprint == true) then
		if ((state == ENCH_CMD_ON) or (state == "on")) then
			Enchantrix_ChatPrint(ENCH_STAT_ON);

			if (Enchantrix_Khaos_Registered) then
				Khaos.setSetKeyParameter("Enchantrix", "EnchantrixEnable", "checked", true);
			end
		else
			Enchantrix_ChatPrint(ENCH_STAT_OFF);

			if (Enchantrix_Khaos_Registered) then
				Khaos.setSetKeyParameter("Enchantrix", "EnchantrixEnable", "checked", false);
			end
		end
	end

	return state;	
end

--The following functions are almost verbatim copies of the original functions but modified in order to make them compatible with direct GUI access.
function Enchantrix_Clear(param, chatprint)

	if ((param == ENCH_CMD_CLEAR_ALL) or (param == "all")) then		
		EnchantedLocal = {};

	else
		local items = Enchantrix_GetSigs(param);

		for _,itemKey in items do

			local aKey = itemKey.s;
			local aName = itemKey.n;
			EnchantedLocal[aKey] = { z=true };
		end
	end

	if (chatprint == true) then

		if ((param == ENCH_CMD_CLEAR_ALL) or (param == "all")) then
			Enchantrix_ChatPrint(string.format(ENCH_FRMT_ACT_CLEARALL, aKey));

		else
			Enchantrix_ChatPrint(string.format(ENCH_FRMT_ACT_CLEAR_OK, aName));
		end
	end
end

function Enchantrix_SetLocale(param, chatprint)
	local validLocale=nil;

	if (param == Enchantrix_GetLocale()) then
		--Do Nothing
		validLocale=true;
	elseif (ENCH_VALID_LOCALES[param]) then
		Enchantrix_SetFilter('locale', param);
		Enchantrix_SetLocaleStrings(Enchantrix_GetLocale());
		validLocale=true;

	elseif (param == '') or (param == 'default') or (param == 'off') then
		Enchantrix_SetFilter('locale', 'default');
		Enchantrix_SetLocaleStrings(Enchantrix_GetLocale());
		validLocale=true;
	end
	
	
	if (chatprint == true) then

		if ((validLocale == true) and (ENCH_VALID_LOCALES[param])) then
			Enchantrix_ChatPrint(string.format(ENCH_FRMT_ACT_SET, ENCH_CMD_LOCALE, param));
			
			if (Enchantrix_Khaos_Registered) then
				Khaos.setSetKeyParameter("Enchantrix", "EnchantrixLocale", "value", param);
			end

		elseif (validLocale == nil) then
			Enchantrix_ChatPrint(string.format(ENCH_FRMT_ACT_UNKNOWN_LOCALE, param));

			if (ENCH_VALID_LOCALES) then
				for locale, x in pairs(ENCH_VALID_LOCALES) do
					Enchantrix_ChatPrint("  "..locale);
				end
			end

		else
			Enchantrix_ChatPrint(string.format(ENCH_FRMT_ACT_SET, ENCH_CMD_LOCALE, 'default'));

			if (Enchantrix_Khaos_Registered) then
				Khaos.setSetKeyParameter("Enchantrix", "EnchantrixLocale", "value", "default");
			end
		end
	end
end

--This function was added by MentalPower to implement the /enx default command
function Enchantrix_Default(param, chatprint)

	if ( (param == nil) or (param == "") ) then
		return

	elseif ((param == ENCH_CMD_CLEAR_ALL) or (param == "all")) then
		EnchantConfig.filters = {};

	else
		Enchantrix_SetFilter(param, nil);
	end

	--@TODO: Move the default setting for the different functions over here to be able to communicate to Khaos what those setting are.
	if (chatprint == true) then
		if ((param == ENCH_CMD_CLEAR_ALL) or (param == "all") or (param == "") or (param == nil)) then
			Enchantrix_ChatPrint(ENCH_FRMT_ACT_DEFAULT_ALL);

		else
			Enchantrix_ChatPrint(string.format(ENCH_FRMT_ACT_DEFAULT, param));
		end
	end
end

--The following three functions were added by MentalPower to implement the /enx print-in command
function Enchantrix_GetFrameNames(index)

	local frames = {};
	local frameName = "";

	for i=1,10 do 
		local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(i);

		if ( name == "" ) then 
			if (i == 1) then
				frames[ENCH_TEXT_GENERAL] = 1;
			elseif (i == 2) then
				frames[ENCH_TEXT_COMBAT] = 2;
			end
		else 
			frames[name] = i;
		end
	end

	if (index) then
		local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(index);

		if ( name == "" ) then 
			if (index == 1) then
				frameName = ENCH_TEXT_GENERAL;
			elseif (index == 2) then
				frameName = ENCH_TEXT_COMBAT;
			end
		else 
			frameName = name;
		end
	end
	
	return frames, frameName;
end


function Enchantrix_GetFrameIndex()

	if (not EnchantConfig.filters) then EnchantConfig.filters = {}; end
	local value = EnchantConfig.filters["printframe"];

	if (not value) then
		return 1;
	end
	return value;
end


function Enchantrix_SetFrame(frame, chatprint)
	local frameNumber
	local frameVal
	frameVal = tonumber(frame)

	--If no arguments are passed, then set it to the default frame.
	if not (frame) then 
		frameNumber = 1;

	--If the frame argument is a number then set our chatframe to that number.
	elseif ((frameVal) ~= nil) then 
		frameNumber = frameVal;

	--If the frame argument is a string, find out if there's a chatframe with that name, and set our chatframe to that index. If not set it to the default frame.
	elseif (type(frame) == "string") then
		allFrames = Enchantrix_GetFrameNames();
		if (allFrames[frame]) then
			frameNumber = allFrames[frame];
		else
			frameNumber = 1;
		end

	--If the argument is something else, set our chatframe to it's default value.
	else
		frameNumber = 1;
	end

	Enchantrix_SetFilter("printframe", frameNumber);
	
	local _, frameName
	if (chatprint == true) then
		_, frameName = Enchantrix_GetFrameNames(frameNumber);
		if (Enchantrix_GetFrameIndex() ~= frameNumber) then
			Enchantrix_ChatPrint(string.format(_AUCT['FrmtPrintin'], frameName));
		end
	end
	
	if (chatprint == true) then
		Enchantrix_ChatPrint(string.format(_AUCT['FrmtPrintin'], frameName));

		if (Enchantrix_Khaos_Registered) then
			Khaos.setSetKeyParameter("Enchantrix", "EnchantrixPrintFrame", "value", frameNumber);
		end
	end
end


function Enchantrix_GenVarSet(variable, param, chatprint)

	if ((param == ENCH_CMD_ON) or (param == "on")) then
		Enchantrix_SetFilter(variable, "on");

	elseif ((param == ENCH_CMD_OFF) or (param == "off")) then
		Enchantrix_SetFilter(variable, "off");

	elseif ((param == ENCH_CMD_TOGGLE) or (param == "toggle") or (param == nil) or (param == "")) then
		param = Enchantrix_GetFilterVal(variable);

		if ((param == ENCH_CMD_ON) or (param == "on")) then
			param = ENCH_CMD_OFF;

		else
			param = ENCH_CMD_ON;
		end

		Enchantrix_SetFilter(variable, param);
	end

	if (chatprint == true) then	

		if ((param == ENCH_CMD_ON) or (param == "on")) then
			Enchantrix_ChatPrint(string.format(ENCH_FRMT_ACT_ENABLE, variable));

			if (Enchantrix_Khaos_Registered) then
				Khaos.setSetKeyParameter("Enchantrix", variable, "checked", true);
			end

		elseif ((param == ENCH_CMD_OFF) or (param == "off")) then
			Enchantrix_ChatPrint(string.format(ENCH_FRMT_ACT_DISABLE, variable));

			if (Enchantrix_Khaos_Registered) then
				Khaos.setSetKeyParameter("Enchantrix", variable, "checked", false);
			end
		end
	end
end


function Enchantrix_SetFilter(type, value)
	if (not EnchantConfig.filters) then EnchantConfig.filters = {}; end
	EnchantConfig.filters[type] = value;
end

function Enchantrix_GetFilterVal(type, default)
	if (default == nil) then default = "on"; end
	if (not EnchantConfig.filters) then EnchantConfig.filters = {}; end
	value = EnchantConfig.filters[type];
	if (not value) then
		if (type == ENCH_SHOW_EMBED) then return "off"; end
		if (type == ENCH_SHOW_COUNT) then return "off"; end
		return default;
	end
	return value;
end

function Enchantrix_GetFilter(filter)
	value = Enchantrix_GetFilterVal(filter);
	if (value == "on") then return true;
	elseif (value == "off") then return false; end
	return true;
end

function Enchantrix_GetLocale()
	local locale = Enchantrix_GetFilterVal('locale');
	if (locale ~= 'on') and (locale ~= 'off') and (locale ~= 'default') then
		return locale;
	end
	return GetLocale();
end

function Enchantrix_GetSigs(str)
	local itemList = {};
	local listSize = 0;
	for sig, item in string.gfind(str, "|Hitem:(%d+:%d+:%d+):%d+|h[[]([^]]+)[]]|h") do
		listSize = listSize+1;
		itemList[listSize] = { s=sig, n=item };
	end
	return itemList;
end


function Enchantrix_PercentLessFilter(percentLess, signature)
    local filterAuction = true;
    local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(signature);
	local disenchantsTo = Enchantrix_GetAuctionItemDisenchants(signature, true);
	if not disenchantsTo.totals then return filterAuction; end

	local hspValue = disenchantsTo.totals.hspValue or 0;
	local medValue = disenchantsTo.totals.medValue or 0;
	local mktValue = disenchantsTo.totals.mktValue or 0;
	local confidence = disenchantsTo.totals.conf or 0;

	local myValue = confidence * (hspValue + medValue + mktValue) / 3;
	local margin = Auctioneer_PercentLessThan(myValue, buyout/count);
	local profit = (myValue * count) - buyout;

	local results = {
		buyout = buyout,
		count = count,
		value = myValue,
		margin = margin,
		profit = profit,
		conf = confidence
	};
	if (buyout > 0) and (margin >= tonumber(percentLess)) and (profit >= MIN_PROFIT_MARGIN) then
		filterAuction = false;
		Enchantrix_ProfitMargins[signature] = results;
	end

	return filterAuction;
end
function Enchantrix_BidBrokerFilter(minProfit, signature)
    local filterAuction = true;
    local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(signature);
    local currentBid = Auctioneer_GetCurrentBid(signature);
	local disenchantsTo = Enchantrix_GetAuctionItemDisenchants(signature, true);
	if not disenchantsTo.totals then return filterAuction; end

	local hspValue = disenchantsTo.totals.hspValue or 0;
	local medValue = disenchantsTo.totals.medValue or 0;
	local mktValue = disenchantsTo.totals.mktValue or 0;
	local confidence = disenchantsTo.totals.conf or 0;

	local myValue = confidence * (hspValue + medValue + mktValue) / 3;
	local margin = Auctioneer_PercentLessThan(myValue, currentBid/count);
	local profit = (myValue * count) - currentBid;
    local profitPricePercent = math.floor((profit / currentBid) * 100);

	local results = {
		buyout = buyout,
		count = count,
		value = myValue,
		margin = margin,
		profit = profit,
		conf = confidence
	};
	if (currentBid <= MAX_BUYOUT_PRICE) and (profit >= tonumber(minProfit)) and (profit >= MIN_PROFIT_MARGIN) and (profitPricePercent >= MIN_PROFIT_PRICE_PERCENT) then
		filterAuction = false;
		Enchantrix_ProfitMargins[signature] = results;
	end
	return filterAuction;
end

function Enchantrix_ProfitComparisonSort(a, b)
	if (not a) or (not b) then return false; end
	local aSig = a.signature;
	local bSig = b.signature;
	if (not aSig) or (not bSig) then return false; end
	local aEpm = Enchantrix_ProfitMargins[aSig];
	local bEpm = Enchantrix_ProfitMargins[bSig];
	if (not aEpm) and (not bEpm) then return false; end
	local aProfit = aEpm.profit or 0;
	local bProfit = bEpm.profit or 0;
	local aMargin = aEpm.margin or 0;
	local bMargin = bEpm.margin or 0;
	local aValue  = aEpm.value or 0;
	local bValue  = bEpm.value or 0;
	if (aProfit > bProfit) then return true; end
	if (aProfit < bProfit) then return false; end
	if (aMargin > bMargin) then return true; end
	if (aMargin < bMargin) then return false; end
	if (aValue > bValue) then return true; end
	if (aValue < bValue) then return false; end
	return false;
end
function Enchantrix_BidBrokerSort(a, b)
	if (not a) or (not b) then return false; end
	local aTime = a.timeLeft or 0;
	local bTime = b.timeLeft or 0;
	if (aTime > bTime) then return true; end
	if (aTime < bTime) then return false; end
	return Enchantrix_ProfitComparisonSort(a, b);
end

function Enchantrix_DoPercentLess(percentLess)
	if (not AUCTIONEER_VERSION) then
		Enchantrix_ChatPrint("You do not have auctioneer installed. Auctioneer must be installed to do an enchanting percentless scan");
		return;
	elseif (not Auctioneer_QuerySnapshot) then
		Enchantrix_ChatPrint("You do not have the correct version of Auctioneer installed, this feature requires Auctioneer v3.0.8 or later");
		return;
	end

    if not percentLess or percentLess == "" then percentLess = MIN_PERCENT_LESS_THAN_HSP end
	local output = string.format(ENCH_FRMT_PCTLESS_HEADER, percentLess);
    Enchantrix_ChatPrint(output);
    
	Enchantrix_PriceCache = {t=time()};
	Enchantrix_ProfitMargins = {};
    local targetAuctions = Auctioneer_QuerySnapshot(Enchantrix_PercentLessFilter, percentLess);
    
    -- sort by profit based on median
    table.sort(targetAuctions, Enchantrix_ProfitComparisonSort);
    
    -- output the list of auctions
    for _,a in targetAuctions do
		if (a.signature and Enchantrix_ProfitMargins[a.signature]) then
			local quality = EnhTooltip.QualityFromLink(a.itemLink);
			if (quality and quality >= 2) then
				local id,rprop,enchant, name, count,_,buyout,_ = Auctioneer_GetItemSignature(a.signature);
				local value = Enchantrix_ProfitMargins[a.signature].value;
				local margin = Enchantrix_ProfitMargins[a.signature].margin;
				local profit = Enchantrix_ProfitMargins[a.signature].profit;
				local output = string.format(ENCH_FRMT_PCTLESS_LINE, Auctioneer_ColorTextWhite(count.."x")..a.itemLink, EnhTooltip.GetTextGSC(value * count), EnhTooltip.GetTextGSC(buyout), EnhTooltip.GetTextGSC(profit * count), Auctioneer_ColorTextWhite(margin.."%"));
				Auctioneer_ChatPrint(output);
			end
		end
    end
    
    Auctioneer_ChatPrint(ENCH_FRMT_PCTLESS_DONE);
end

function Enchantrix_DoBidBroker(minProfit)
	if (not AUCTIONEER_VERSION) then
		Enchantrix_ChatPrint("You do not have auctioneer installed. Auctioneer must be installed to do an enchanting percentless scan");
		return;
	elseif (not Auctioneer_QuerySnapshot) then
		Enchantrix_ChatPrint("You do not have the correct version of Auctioneer installed, this feature requires Auctioneer v3.0.8 or later");
		return;
	end

    if not minProfit or minProfit == "" then minProfit = MIN_PROFIT_MARGIN; else minProfit = tonumber(minProfit) * 100; end
	local output = string.format(ENCH_FRMT_BIDBROKER_HEADER, EnhTooltip.GetTextGSC(minProfit));
    Enchantrix_ChatPrint(output);
    
	Enchantrix_PriceCache = {t=time()};
	Enchantrix_ProfitMargins = {};
    local targetAuctions = Auctioneer_QuerySnapshot(Enchantrix_BidBrokerFilter, minProfit);
    
    -- sort by profit based on median
    table.sort(targetAuctions, Enchantrix_BidBrokerSort);
    
    -- output the list of auctions
    for _,a in targetAuctions do
		if (a.signature and Enchantrix_ProfitMargins[a.signature]) then
			local quality = EnhTooltip.QualityFromLink(a.itemLink);
			if (quality and quality >= 2) then
				local id,rprop,enchant, name, count, min, buyout,_ = Auctioneer_GetItemSignature(a.signature);
				local currentBid = Auctioneer_GetCurrentBid(a.signature);
				local value = Enchantrix_ProfitMargins[a.signature].value;
				local margin = Enchantrix_ProfitMargins[a.signature].margin;
				local profit = Enchantrix_ProfitMargins[a.signature].profit;
				local bidText = ENCH_FRMT_BIDBROKER_CURBID;
				if (currentBid == min) then
					bidText = ENCH_FRMT_BIDBROKER_MINBID;
				end
				local output = string.format(ENCH_FRMT_BIDBROKER_LINE, Auctioneer_ColorTextWhite(count.."x")..a.itemLink, EnhTooltip.GetTextGSC(value * count), bidText, EnhTooltip.GetTextGSC(currentBid), EnhTooltip.GetTextGSC(profit * count), Auctioneer_ColorTextWhite(margin.."%"), Auctioneer_ColorTextWhite(Auctioneer_GetTimeLeftString(a.timeLeft)));
				Enchantrix_ChatPrint(output);
			end
		end
    end
    
    Enchantrix_ChatPrint(ENCH_FRMT_BIDBROKER_DONE);
end

function Enchantrix_GetAuctionItemDisenchants(auctionSignature, useCache)
    local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer_GetItemSignature(auctionSignature);
	local sig = string.format("%d:%d:%d", id, enchant, rprop);
	local sigNR = string.format("%d:%d:%d", id, 0, 0);
	return Enchantrix_GetItemDisenchants(sig, sigNR, name, useCache);
end

function Enchantrix_Split(str, at)
	local splut = {};
	local pos = 1;
	
	local match, mend = string.find(str, at, pos, true);
	while match do
		table.insert(splut, string.sub(str, pos, match-1));
		pos = mend+1;
		match, mend = string.find(str, at, pos, true);
	end
	table.insert(splut, string.sub(str, pos));
	return splut;
end

function Enchantrix_SaveLocal(sig, lData)
	local str = "";
	for eResult, eData in lData do
		if (eData and type(eData) == "table") then
			local iCount = tonumber(eData.i) or 0;
			local dCount = tonumber(eData.d) or 0;
			local oCount = tonumber(eData.o) or 0;
			local serial = string.format("%d:%d:%d:%d", eResult, iCount, dCount, oCount);
			if (str == "") then str = serial else str = str..";"..serial end
		else
			eData = nil;
		end
	end
	EnchantedLocal[sig] = str;
end

function Enchantrix_GetLocal(sig)
	local enchantItem = {};
	if (EnchantedLocal and EnchantedLocal[sig]) then
		if (type(EnchantedLocal[sig]) == "table") then
			-- Time to convert it into the new serialized format
			Enchantrix_SaveLocal(sig, EnchantedLocal[sig]);
		end

		-- Get the string and break it apart
		local enchantSerial = EnchantedLocal[sig];
		local enchantResults = Enchantrix_Split(enchantSerial, ";");
		for pos, enchantResult in enchantResults do
			local enchantBreak = Enchantrix_Split(enchantResult, ":");
			local rSig = tonumber(enchantBreak[1]) or 0;
			local iCount = tonumber(enchantBreak[2]) or 0;
			local dCount = tonumber(enchantBreak[3]) or 0;
			local oCount = tonumber(enchantBreak[4]) or 0;

			enchantItem[rSig] = { i=iCount, d=dCount, o=oCount };
		end
	end
	return enchantItem;
end

function Enchantrix_GetItemDisenchants(sig, sigNR, name, useCache)
	local disenchantsTo = {};

	if (not Enchantrix_PriceCache) or (time()-Enchantrix_PriceCache.t > 300) then
		Enchantrix_PriceCache = {t=time()};
	end

	-- Automatically convert any named EnchantedLocal items to new items
	if (name and EnchantedLocal[name]) then
		for dName, count in EnchantedLocal[name] do
			local dSig = EssenceItemIDs[dName];
			if (dSig ~= nil) then
				if (not EnchantedLocal[sig]) then EnchantedLocal[sig] = {}; end
				if (not EnchantedLocal[sig][dSig]) then EnchantedLocal[sig][dSig] = {}; end
				local oCount = tonumber(EnchantedLocal[sig][dSig].o);
				if (oCount == nil) then oCount = 0; end
				EnchantedLocal[sig][dSig].o = ""..count;
			end
		end
		EnchantedLocal[name] = nil;
	end

	-- If there is data, then work out the disenchant data
	if ((DisenchantList[sig]) or (sigNR and DisenchantList[sigNR]) or (EnchantedLocal[sig])) then
		local bTotal = 0;
		local biTotal = 0;
		local bdTotal = 0;
		local oTotal = 0;
		local iTotal = 0;
		local dTotal = 0;

		local exactMatch = true;

		local baseDisenchant = DisenchantList[sig];
		
		if (not baseDisenchant) and (sigNR) then
			baseDisenchant = DisenchantList[sigNR];
			if (baseDisenchant) then
				exactMatch = false;
			end
		end
		
		if (baseDisenchant) then
			-- Base Disenchantments are now serialized
			local baseResults = Enchantrix_Split(baseDisenchant, ";");
			for pos, baseResult in baseResults do
				local baseBreak = Enchantrix_Split(baseResult, ":");
				local dSig = tonumber(baseBreak[1]) or 0;
				local biCount = tonumber(baseBreak[2]) or 0;
				local bdCount = tonumber(baseBreak[3]) or 0;
				local bCount = tonumber(baseBreak[4]) or 0;
				
				if (dSig > 0) and (bCount+biCount > 0) then
					disenchantsTo[dSig] = {};
					disenchantsTo[dSig].bCount = bCount;
					disenchantsTo[dSig].biCount = biCount;
					disenchantsTo[dSig].bdCount = bdCount;
					disenchantsTo[dSig].oCount = 0;
					disenchantsTo[dSig].iCount = 0;
					disenchantsTo[dSig].dCount = 0;
					bTotal = bTotal + bCount;
					biTotal = biTotal + biCount;
					bdTotal = bdTotal + bdCount;
				end
			end
		end

		local enchantedLocal = Enchantrix_GetLocal(sig);
		if (enchantedLocal) then
			for dSigStr, data in enchantedLocal do
				local dSig = tonumber(dSigStr);
				if (dSig and dSig > 0) then
					local oCount = 0;
					local dCount = 0;
					local iCount = 0;
					if (data.o) then oCount = tonumber(data.o); end
					if (data.d) then dCount = tonumber(data.d); end
					if (data.i) then iCount = tonumber(data.i); end
						
					if (not disenchantsTo[dSig]) then
						disenchantsTo[dSig] = {};
						disenchantsTo[dSig].bCount = 0;
					end
					if (data.z) then 
						local bCount = disenchantsTo[dSig].bCount;
						disenchantsTo[dSig].bCount = 0;
						bTotal = bTotal - bCount;
					end
					disenchantsTo[dSig].oCount = oCount;
					disenchantsTo[dSig].dCount = dCount;
					disenchantsTo[dSig].iCount = iCount;
					oTotal = oTotal + oCount;
					dTotal = dTotal + dCount;
					iTotal = iTotal + iCount;
				end
			end
		end

		local total = bTotal + biTotal + oTotal + iTotal;

		local hspGuess = 0;
		local medianGuess = 0;
		local marketGuess = 0;
		if (total > 0) then
			for dSig, counts in disenchantsTo do
				local itemID = 0;
				if (dSig) then itemID = tonumber(dSig); end
				local dName = ItemEssences[itemID];
				if (not dName) then dName = "Item "..dSig; end
				local oldCount, itemCount, disenchantCount;
				local count = (counts.bCount or 0) + (counts.biCount or 0) + (counts.oCount or 0) + (counts.iCount or 0);
				local countI = (counts.biCount or 0) + (counts.iCount or 0);
				local countD = (counts.bdCount or 0) + (counts.dCount or 0);
				local pct = tonumber(string.format("%0.1f", count / total * 100));
				local rate = 0;
				if (countI > 0) then
					rate = tonumber(string.format("%0.1f", countD / countI));
					if (not rate) then rate = 0; end
				end

				local count = 1;
				if (rate and rate > 0) then count = rate; end
				disenchantsTo[dSig].name = dName;
				disenchantsTo[dSig].pct = pct;
				disenchantsTo[dSig].rate = count;
				local mkt = Enchantrix_StaticPrices[itemID];

				-- Work out what version if any of auctioneer is installed
				local auctVerStr = AUCTIONEER_VERSION or "0.0.0";
				local auctVer = Enchantrix_Split(auctVerStr, ".");
				local major = tonumber(auctVer[1]) or 0;
				local minor = tonumber(auctVer[2]) or 0;
				local rev = tonumber(auctVer[3]) or 0;
				if (auctVer[3] == "DEV") then rev = 0; minor = minor + 1; end
					
				local itemKey = string.format("%s:0:0", itemID);
				if (useCache and not Enchantrix_PriceCache[itemKey]) then
					Enchantrix_PriceCache[itemKey] = {};
				end

				local hsp, median;
				if (useCache and Enchantrix_PriceCache[itemKey].hsp) then
					hsp = Enchantrix_PriceCache[itemKey].hsp;
				end

				if ((not hsp or hsp < 1) and (major >= 3)) then
					if (major == 3 and minor == 0 and rev <= 11) then
						if (rev == 11) then
							hsp = Auctioneer_GetHighestSellablePriceForOne(itemKey, false, Auctioneer_GetAuctionKey());
						else
							if (Auctioneer_GetHighestSellablePriceForOne) then
								hsp = Auctioneer_GetHighestSellablePriceForOne(itemKey, false);
							elseif (getHighestSellablePriceForOne) then
								hsp = getHighestSellablePriceForOne(itemKey, false);
							end
						end
					elseif (major > 3 or minor > 0 or rev > 11) then
						hsp = Auctioneer_GetHSP(itemKey, Auctioneer_GetAuctionKey());
					end
				end
				if hsp == nil then hsp = mkt * 0.98; end
				if (useCache) then Enchantrix_PriceCache[itemKey].hsp = hsp; end

				if (useCache and Enchantrix_PriceCache[itemKey].median) then
					median = Enchantrix_PriceCache[itemKey].median;
				end

				if ((not median or median < 1) and (major >= 3)) then
					median = Auctioneer_GetUsableMedian(itemKey);
				end
				if median == nil then median = mkt * 0.95; end
				if (useCache) then Enchantrix_PriceCache[itemKey].median = median; end

				local hspValue = (hsp * pct * count / 100);
				local medianValue = (median * pct * count / 100);
				disenchantsTo[dSig].hspValue = hspValue;
				disenchantsTo[dSig].medValue = medValue;
				hspGuess = hspGuess + hspValue;
				medianGuess = medianGuess + medianValue;

				local mktValue = (mkt * pct * count / 100);
				disenchantsTo[dSig].mktValue = mktValue;
				marketGuess = marketGuess + mktValue;
			end
		end

		local confidence = math.log(math.min(total, 19)+1)/3;

		disenchantsTo.totals = {};
		disenchantsTo.totals.exact = exactMatch;
		disenchantsTo.totals.hspValue = hspGuess or 0;
		disenchantsTo.totals.medValue = medianGuess or 0;
		disenchantsTo.totals.mktValue = marketGuess or 0;
		disenchantsTo.totals.bCount = bTotal or 0;
		disenchantsTo.totals.biCount = biTotal or 0;
		disenchantsTo.totals.bdCount = bdTotal or 0;
		disenchantsTo.totals.oCount = oTotal or 0;
		disenchantsTo.totals.dCount = dTotal or 0;
		disenchantsTo.totals.iCount = iTotal or 0;
		disenchantsTo.totals.total = total or 0;
		disenchantsTo.totals.conf = confidence or 0;
	end

	return disenchantsTo;
end

function Enchantrix_BreakLink(link)
	local i,j, itemID, enchant, randomProp, uniqID, name = string.find(link, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h[[]([^]]+)[]]|h");
	return tonumber(itemID or 0), tonumber(randomProp or 0), tonumber(enchant or 0), tonumber(uniqID or 0), name;
end


function Enchantrix_FindSigInBags(sig)
	for bag = 0, 4, 1 do
		size = GetContainerNumSlots(bag);
		if (size) then
			for slot = size, 1, -1 do
				local link = GetContainerItemLink(bag, slot);
				if (link) then
					local itemID, randomProp, enchant, uniqID, itemName = Enchantrix_BreakLink(link);
					if (itemName == findName) then
						local texture, itemCount, locked, quality, readable = GetContainerItemInfo(frameID, buttonID);
						local data = {
							name = itemName, link = link,
							sig = string.format("%d:%d:%d", itemID, enchant, randomProp),
							id = itemID, rand = randomProp, ench = enchant, uniq = uniqID,
							quality = quality
						}

						return bag, slot, data;
					end
				end
			end
		end
	end
end
