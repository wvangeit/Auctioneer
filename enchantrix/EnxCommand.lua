--[[
	Enchantrix Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	Slash command and GUI functions.
--]]

function Enchantrix_GetKhaosDefault(filter)
	if (Enchantrix_FilterDefaults[filter] == 'on') then
		return true;
	elseif (Enchantrix_FilterDefaults[filter] == 'off') then
		return false;
	else
		return Enchantrix_FilterDefaults[filter]
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
				id="all";
				type=K_TEXT;
				text=ENCH_GUI_MAIN_ENABLE;
				helptext=ENCH_HELP_ONOFF;
				callback=function(state)
					if (state.checked) then
						Enchantrix_OnOff('on');
					else
						Enchantrix_OnOff('off');
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
				default={checked=Enchantrix_GetKhaosDefault('all')};
				disabled={checked=false};
				difficulty=1;
			};
			{
				id='locale';
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
				dependencies={all={checked=true;}};
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
				id='embed';
				type=K_TEXT;
				text=ENCH_GUI_EMBED;
				helptext=ENCH_HELP_EMBED;
				callback=function(state)
					Enchantrix_GenVarSet('embed', state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(ENCH_FRMT_ACT_ENABLE, ENCH_SHOW_EMBED));
					else
						return (string.format(ENCH_FRMT_ACT_DISABLE, ENCH_SHOW_EMBED));
					end
				end;
				check=true;
				default={checked=Enchantrix_GetKhaosDefault('embed')};
				disabled={checked=false};
				dependencies={all={checked=true;}};
				difficulty=1;
			};
			{
				id='counts';
				type=K_TEXT;
				text=ENCH_GUI_COUNT;
				helptext=ENCH_HELP_COUNT;
				callback=function(state)
					Enchantrix_GenVarSet('counts', state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(ENCH_FRMT_ACT_ENABLE, ENCH_SHOW_COUNT));
					else
						return (string.format(ENCH_FRMT_ACT_DISABLE, ENCH_SHOW_COUNT));
					end
				end;
				check=true;
				default={checked=Enchantrix_GetKhaosDefault('counts')};
				disabled={checked=false};
				dependencies={all={checked=true;}};
				difficulty=3;
			};			
			{
				id='rates';
				type=K_TEXT;
				text=ENCH_GUI_RATE;
				helptext=ENCH_HELP_RATE;
				callback=function(state)
					Enchantrix_GenVarSet('rates', state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(ENCH_FRMT_ACT_ENABLE, ENCH_SHOW_COUNT));
					else
						return (string.format(ENCH_FRMT_ACT_DISABLE, ENCH_SHOW_COUNT));
					end
				end;
				check=true;
				default={checked=Enchantrix_GetKhaosDefault('rates')};
				disabled={checked=false};
				dependencies={all={checked=true;}};
				difficulty=3;
			};			
			{
				id="EnchantrixValuateHeader";
				type=K_HEADER;
				text=ENCH_GUI_VALUATE_HEADER;
				helptext=ENCH_HELP_VALUE;
				difficulty=2;
			};
			{
				id='valuate';
				type=K_TEXT;
				text=ENCH_GUI_VALUATE_ENABLE;
				helptext=ENCH_HELP_VALUE;
				callback=function(state)
					Enchantrix_GenVarSet('valuate', state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(ENCH_FRMT_ACT_ENABLE, ENCH_SHOW_VALUE));
					else
						return (string.format(ENCH_FRMT_ACT_DISABLE, ENCH_SHOW_VALUE));
					end
				end;
				check=true;
				default={checked=Enchantrix_GetKhaosDefault('valuate')};
				disabled={checked=false};
				dependencies={all={checked=true;}};
				difficulty=1;
			};
			{
				id='valuate-baseline';
				type=K_TEXT;
				text=ENCH_GUI_VALUATE_BASELINE;
				helptext=ENCH_HELP_GUESS_BASELINE;
				callback=function(state)
					Enchantrix_GenVarSet('valuate-baseline', state.checked);				
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(ENCH_FRMT_ACT_ENABLE, ENCH_SHOW_GUESS_BASELINE));
					else
						return (string.format(ENCH_FRMT_ACT_DISABLE, ENCH_SHOW_GUESS_BASELINE));
					end
				end;
				check=true;
				default={checked=Enchantrix_GetKhaosDefault('valuate-baseline')};
				disabled={checked=false};
				dependencies={valuate={checked=true;}, all={checked=true;}};
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
				dependencies={all={checked=true;}};
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
				dependencies={all={checked=true;}};
				difficulty=1;
			};
			{
				id="printframe";
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
				dependencies={all={checked=true;}};
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
				dependencies={all={checked=true;}};
				difficulty=4;
			};
		};
	};

	Khaos.registerOptionSet("tooltip",Enchantrix_optionSet);
	Enchantrix_Khaos_Registered = true;
	
	return true;
end

function Enchantrix_AuctioneerLoaded()
	if (not Enchantrix_Khaos_Registered) then return; end
	
	Enchantrix_ChatPrint("function called");
	
	local insertPos = 10;

	if (Enchantrix_optionSet.options[insertPos].id == ENCH_SHOW_GUESS_AUCTIONEER_HSP) then
		Enchantrix_ChatPrint("options already added");
		return nil;
	end
	
	local AuctioneerOptions = {
		{
			id='valuate-hsp';
			type=K_TEXT;
			text=ENCH_GUI_VALUATE_AVERAGES;
			helptext=ENCH_HELP_GUESS_AUCTIONEER_HSP;
			callback=function(state)
				Enchantrix_GenVarSet('valuate-hsp', state.checked);
			end;
			feedback=function(state)
				if (state.checked) then
					return (string.format(ENCH_FRMT_ACT_ENABLE, ENCH_SHOW_GUESS_AUCTIONEER_HSP));
				else
					return (string.format(ENCH_FRMT_ACT_DISABLE, ENCH_SHOW_GUESS_AUCTIONEER_HSP));
				end
			end;
			check=true;
			default={checked=Enchantrix_GetKhaosDefault('valuate-hsp')};
			disabled={checked=false};
			dependencies={EnchantrixAuctioneer={checked=true;}, valuate={checked=true;}, all={checked=true;}};
			difficulty=2;
		};
		{
			id='valuate-median';
			type=K_TEXT;
			text=ENCH_GUI_VALUATE_MEDIAN;
			helptext=ENCH_HELP_GUESS_AUCTIONEER_MEDIAN;
			callback=function(state)
				Enchantrix_GenVarSet('valuate-median', state.checked);			
			end;
			feedback=function(state)
				if (state.checked) then
					return (string.format(ENCH_FRMT_ACT_ENABLE, ENCH_SHOW_GUESS_AUCTIONEER_MED));
				else
					return (string.format(ENCH_FRMT_ACT_DISABLE, ENCH_SHOW_GUESS_AUCTIONEER_MED));
				end
			end;
			check=true;
			default={checked=Enchantrix_GetKhaosDefault('valuate-median')};
			disabled={checked=false};
			dependencies={EnchantrixAuctioneer={checked=true;}, valuate={checked=true;}, all={checked=true;}};
			difficulty=2;
		};
	};

	Enchantrix_ChatPrint("unregistering");
	Khaos.unregisterOptionSet("Enchantrix");
	Enchantrix_ChatPrint("refreshing");
	Khaos.refresh();
	
	for i, opt in ipairs(AuctioneerOptions) do
		tinsert(Enchantrix_optionSet.options, insertPos + i - 1, opt);
	end
		
	Enchantrix_ChatPrint("registering");
	Khaos.registerOptionSet("tooltip",Enchantrix_optionSet);
	Enchantrix_ChatPrint("refresh2");
	Khaos.refresh();
	Enchantrix_ChatPrint("end");
end

local function setKhaosSetKeyParameter(key, parameter, value)
	if (Enchantrix_Khaos_Registered) then
		Khaos.setSetKeyParameter("Enchantrix", key, parameter, value)
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
		Enchantrix_ChatPrint(ENCH_MESG_DISABLE);
		Stubby.SetConfig("Enchantrix", "LoadType", "never");

	elseif (cmd == "load") then
		if (param == "always") or (param == "never") then
			Enchantrix_ChatPrint("Setting Enchantrix to "..param.." load for this toon");
			Stubby.SetConfig("Enchantrix", "LoadType", param);
		end

	elseif ((cmd == ENCH_CMD_CLEAR) or (cmd == "clear")) then
		Enchantrix_Clear(param, chatprint);

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
	elseif (cmd == ENCH_SHOW_EMBED or cmd == 'embed') then
		Enchantrix_GenVarSet('embed', param, chatprint);
	elseif (cmd == ENCH_SHOW_HEADER or cmd == 'header') then
		Enchantrix_GenVarSet('header', param, chatprint);
	elseif (cmd == ENCH_SHOW_COUNT or cmd == 'counts') then
		Enchantrix_GenVarSet('counts', param, chatprint);
	elseif (cmd == ENCH_SHOW_RATE or cmd == 'rates') then
		Enchantrix_GenVarSet('rates', param, chatprint);
	elseif (cmd == ENCH_SHOW_VALUE or cmd == 'valuate') then
		Enchantrix_GenVarSet('valuate', param, chatprint);
	elseif (cmd == ENCH_SHOW_GUESS_AUCTIONEER_HSP or cmd == 'valuate-hsp') then
		Enchantrix_GenVarSet('valuate-hsp', param, chatprint);
	elseif (cmd == ENCH_SHOW_GUESS_AUCTIONEER_MED or cmd == 'valuate-median') then
		Enchantrix_GenVarSet('valuate-median', param, chatprint);
	elseif (cmd == ENCH_SHOW_GUESS_BASELINE or cmd == 'valuate-baseline') then
		Enchantrix_GenVarSet('valuate-baseline', param, chatprint);
	elseif (chatprint == true) then
		Enchantrix_ChatPrint(string.format(ENCH_FRMT_ACT_UNKNOWN, cmd));
	end
end



--Help ME!! (The Handler) (Another shameless copy from the original function)
function Enchantrix_ChatPrint_Help()
Enchantrix_ChatPrint(ENCH_FRMT_USAGE);
		local onOffToggle = " ("..ENCH_CMD_ON.."|"..ENCH_CMD_OFF.."|"..ENCH_CMD_TOGGLE..")";
		local lineFormat = "  |cffffffff/enchantrix %s "..onOffToggle.."|r |cff2040ff[%s]|r - %s";

		Enchantrix_ChatPrint("  |cffffffff/enchantrix "..onOffToggle.."|r |cff2040ff["..Enchantrix_GetLocalizedFilterVal('all').."]|r - " .. ENCH_HELP_ONOFF);
		
		Enchantrix_ChatPrint("  |cffffffff/enchantrix "..ENCH_CMD_DISABLE.."|r - " .. ENCH_HELP_DISABLE);

		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_SHOW_HEADER, Enchantrix_GetLocalizedFilterVal('header'), ENCH_HELP_HEADER));
		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_SHOW_COUNT, Enchantrix_GetLocalizedFilterVal('counts'), ENCH_HELP_COUNT));
		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_SHOW_RATE, Enchantrix_GetLocalizedFilterVal('rates'), ENCH_HELP_RATE));
		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_SHOW_EMBED, Enchantrix_GetLocalizedFilterVal('embed'), ENCH_HELP_EMBED));
		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_SHOW_VALUE, Enchantrix_GetLocalizedFilterVal('valuate'), ENCH_HELP_VALUE));
		if (AUCTIONEER_VERSION) then
			Enchantrix_ChatPrint(string.format(lineFormat, ENCH_SHOW_GUESS_AUCTIONEER_HSP, Enchantrix_GetLocalizedFilterVal('valuate-hsp'), ENCH_HELP_GUESS_AUCTIONEER_HSP));
			Enchantrix_ChatPrint(string.format(lineFormat, ENCH_SHOW_GUESS_AUCTIONEER_MED, Enchantrix_GetLocalizedFilterVal('valuate-median'), ENCH_HELP_GUESS_AUCTIONEER_MEDIAN));
		else
			Enchantrix_ChatPrint(ENCH_HELP_GUESS_NOAUCTIONEER);
		end
		Enchantrix_ChatPrint(string.format(lineFormat, ENCH_SHOW_GUESS_BASELINE, Enchantrix_GetLocalizedFilterVal('valuate-baseline'), ENCH_HELP_GUESS_BASELINE));

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
	state = Enchantrix_DelocalizeFilterVal(state)
	
	if ((state == nil) or (state == "")) then
		state = Enchantrix_GetFilterVal("all");
	elseif (state == 'on' or state == 'off') then
		Enchantrix_SetFilter('all', state);
	elseif (state == "toggle") then
		Enchantrix_SetFilter('all', not Enchantrix_GetFilter('all'))
	end

	--Print the change and alert the GUI if the command came from slash commands. Do nothing if they came from the GUI.
	if (chatprint == true) then
		if (Enchantrix_GetFilter('all')) then
			Enchantrix_ChatPrint(ENCH_STAT_ON);
			setKhaosSetKeyParameter('all', "checked", true);
		else
			Enchantrix_ChatPrint(ENCH_STAT_OFF);
			setKhaosSetKeyParameter('all', "checked", false);
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
		if ((param == ENCH_CMD_CLEAR_ALL) or (param == 'all')) then
			Enchantrix_ChatPrint(ENCH_FRMT_ACT_CLEARALL);
		else
			Enchantrix_ChatPrint(string.format(ENCH_FRMT_ACT_CLEAR_OK, aName));
		end
	end
end

function Enchantrix_SetLocale(param, chatprint)
	param = Enchantrix_DelocalizeFilterVal(param)
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
			setKhaosSetKeyParameter("locale", "value", param);
		elseif (validLocale == nil) then
			Enchantrix_ChatPrint(string.format(ENCH_FRMT_ACT_UNKNOWN_LOCALE, param));
			if (ENCH_VALID_LOCALES) then
				for locale, x in pairs(ENCH_VALID_LOCALES) do
					Enchantrix_ChatPrint("  "..locale);
				end
			end
		else
			Enchantrix_ChatPrint(string.format(ENCH_FRMT_ACT_SET, ENCH_CMD_LOCALE, Enchantrix_LocalizeFilterVal('default')));
			setKhaosSetKeyParameter("locale", "value", "default");
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
	
	Enchantrix_SetFilterDefaults();		-- Apply defaults for settings that went missing 

	--@TODO: Communicate the applied default settings to Khaos.
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
	local value = EnchantConfig.filters['printframe'];

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

	local _, frameName
	if (chatprint == true) then
		_, frameName = Enchantrix_GetFrameNames(frameNumber);
		if (Enchantrix_GetFrameIndex() ~= frameNumber) then
			Enchantrix_ChatPrint(string.format(ENCH_FRMT_PRINTIN, frameName));
		end
	end
	
	Enchantrix_SetFilter("printframe", frameNumber);
	
	if (chatprint == true) then
		Enchantrix_ChatPrint(string.format(ENCH_FRMT_PRINTIN, frameName));
		setKhaosSetKeyParameter("EnchantrixPrintFrame", "value", frameNumber);
	end
end



function Enchantrix_GenVarSet(variable, param, chatprint)
	if (type(param) == "boolean") then
		if (param) then param = 'on'; else param = 'off'; end
	else
		param = Enchantrix_DelocalizeFilterVal(param);	
	end
	
	local enabled;
	
	if (param == 'on' or param == 'off') then
		Enchantrix_SetFilter(variable, param);
	elseif (param == 'toggle' or param == nil or param == "") then
		Enchantrix_SetFilter(variable, not Enchantrix_GetFilter(variable))
		enabled = Enchantrix_GetFilterVal(variable);
	end

	-- Enchantrix_ChatPrint("Enchantrix_GenVarSet " .. variable)
	if (chatprint == true) then	
		if (enabled) then
			Enchantrix_ChatPrint(string.format(ENCH_FRMT_ACT_ENABLE, variable));
			setKhaosSetKeyParameter(variable, "checked", true);
		else
			Enchantrix_ChatPrint(string.format(ENCH_FRMT_ACT_DISABLE, variable));
			setKhaosSetKeyParameter(variable, "checked", false);
		end
	end
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
