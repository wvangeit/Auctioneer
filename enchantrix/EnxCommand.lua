--[[
	Enchantrix Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	Slash command and GUI functions.
	
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
--]]

function Enchantrix_GetKhaosDefault(filter)
	if (Enchantrix_FilterDefaults[filter] == 'on') then
		return true;
	elseif (Enchantrix_FilterDefaults[filter] == 'off') then
		return false;
	else
		return Enchantrix_FilterDefaults[filter];
	end
end

local function getKhaosLocaleList()
	local options = { [_ENCH('CmdDefault')] = 'default' };
	for locale, data in EnchantrixLocalizations do
		options[locale] = locale;
	end
	return options
end

function Enchantrix_Register_Khaos()
	Enchantrix_optionSet = {
		id="Enchantrix";
		text="Enchantrix";
		helptext=_ENCH('GuiMainHelp');
		difficulty=1;
		default={checked=true};
		options={
			{
				id="Header";
				text="Enchantrix";
				helptext=_ENCH('GuiMainHelp');
				type=K_HEADER;
				difficulty=1;
			};
			{
				id="all";
				type=K_TEXT;
				text=_ENCH('GuiMainEnable');
				helptext=_ENCH('HelpOnoff');
				callback=function(state)
					if (state.checked) then
						Enchantrix_OnOff('on');
					else
						Enchantrix_OnOff('off');
					end
				end;
				feedback=function(state)
					if (state.checked) then
						return _ENCH('StatOn');
					else
						return _ENCH('StatOff');
					end
				end;
				check=true;
				default={checked=Enchantrix_GetKhaosDefault('all')};
				disabled={checked=false};
				difficulty=1;
			};
			{
				id="locale";
				type=K_PULLDOWN;
				setup = {
					options = getKhaosLocaleList();
					multiSelect = false;
				};
				text=_ENCH('GuiLocale');
				helptext=_ENCH('HelpLocale');
				callback = function(state)
					Enchantrix_SetLocale(state.value);
				end;
				feedback = function (state)
					return string.format(_ENCH('FrmtActSet'), _ENCH('CmdLocale'), state.value);
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
			--[[{
				id="LoadSettings";
				type=K_PULLDOWN;
				setup = {
					options = {
						[ENCH_GUI_LOAD_ALWAYS] = 'always',
						[ENCH_GUI_LOAD_NEVER] = 'never',};
					multiSelect = false;
				};
				text=ENCH_GUI_LOAD;
				helptext=ENCH_HELP_LOAD;
				callback=function(state) end;
				feedback=function(state)
					Enchantrix_Command("load " .. state.value, "GUI");
				end;
				default={value = 'always'};
				disabled={value = 'never'};
				difficulty=1;
			};]]
			{
				id="ReloadUI";
				type=K_BUTTON;
				setup={
					buttonText = _ENCH('GuiReloaduiButton');
				};
				text=_ENCH('GuiReloadui');
				helptext=_ENCH('GuiReloaduiHelp');
				callback=function()
					if(ReloadUI) then
						ReloadUIHandler("5");
					else
						ReloadUI();
					end
				end;
				feedback=function()
					return _ENCH('GuiReloaduiFeedback');
				end;
				difficulty=4;
			};
			{
				id="embed";
				type=K_TEXT;
				text=_ENCH('GuiEmbed');
				helptext=_ENCH('HelpEmbed');
				callback=function(state)
					Enchantrix_GenVarSet('embed', state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(_ENCH('FrmtActEnable'), _ENCH('ShowEmbed')));
					else
						return (string.format(_ENCH('FrmtActDisable'), _ENCH('ShowEmbed')));
					end
				end;
				check=true;
				default={checked=Enchantrix_GetKhaosDefault('embed')};
				disabled={checked=false};
				dependencies={all={checked=true;}};
				difficulty=1;
			};
			{
				id="counts";
				type=K_TEXT;
				text=_ENCH('GuiCount');
				helptext=_ENCH('HelpCount');
				callback=function(state)
					Enchantrix_GenVarSet('counts', state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(_ENCH('FrmtActEnable'), _ENCH('ShowCount')));
					else
						return (string.format(_ENCH('FrmtActDisable'), _ENCH('ShowCount')));
					end
				end;
				check=true;
				default={checked=Enchantrix_GetKhaosDefault('counts')};
				disabled={checked=false};
				dependencies={all={checked=true;}};
				difficulty=3;
			};			
			--[[{
				id="rates";
				type=K_TEXT;
				text=_ENCH('GuiRate');
				helptext=_ENCH('HelpRate');
				callback=function(state)
					Enchantrix_GenVarSet('rates', state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(_ENCH('FrmtActEnable'), _ENCH('ShowCount')));
					else
						return (string.format(_ENCH('FrmtActDisable'), _ENCH('ShowCount')));
					end
				end;
				check=true;
				default={checked=Enchantrix_GetKhaosDefault('rates')};
				disabled={checked=false};
				dependencies={all={checked=true;}};
				difficulty=3;
			};]]--
			{
				id="EnchantrixValuateHeader";
				type=K_HEADER;
				text=_ENCH('GuiValuateHeader');
				helptext=_ENCH('HelpValue');
				difficulty=2;
			};
			{
				id="valuate";
				type=K_TEXT;
				text=_ENCH('GuiValuateEnable');
				helptext=_ENCH('HelpValue').."\n".._ENCH('HelpGuessNoauctioneer');
				callback=function(state)
					Enchantrix_GenVarSet('valuate', state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(_ENCH('FrmtActEnable'), _ENCH('ShowValue')));
					else
						return (string.format(_ENCH('FrmtActDisable'), _ENCH('ShowValue')));
					end
				end;
				check=true;
				default={checked=Enchantrix_GetKhaosDefault('valuate')};
				disabled={checked=false};
				dependencies={all={checked=true;}};
				difficulty=1;
			};
			{
				id="valuate-baseline";
				type=K_TEXT;
				text=_ENCH('GuiValuateBaseline');
				helptext=_ENCH('HelpGuessBaseline');
				callback=function(state)
					Enchantrix_GenVarSet('valuate-baseline', state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(_ENCH('FrmtActEnable'), _ENCH('ShowGuessBaseline')));
					else
						return (string.format(_ENCH('FrmtActDisable'), _ENCH('ShowGuessBaseline')));
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
				text=_ENCH('GuiOtherHeader');
				helptext=_ENCH('GuiOtherHelp');
				difficulty=1;
			};
			{
				id="EnchantrixClearAll";
				type=K_BUTTON;
				setup={
					buttonText = _ENCH('GuiClearallButton');
				};
				text=_ENCH('GuiClearall');
				helptext=_ENCH('GuiClearallHelp');
				callback=function()
					Enchantrix_Clear(_ENCH('CmdClearAll'));
				end;
				feedback=function()
					return string.format(_ENCH('FrmtActClearall'),  _ENCH('GuiClearallNote'));
				end;
				dependencies={all={checked=true;}};
				difficulty=3;
			};
			{
				id="DefaultAll";
				type=K_BUTTON;
				setup={
					buttonText = _ENCH('GuiDefaultAllButton');
				};
				text=_ENCH('GuiDefaultAll');
				helptext=_ENCH('GuiDefaultAllHelp');
				callback=function() 
					Enchantrix_Default(_ENCH('CmdClearAll'));
				end;
				feedback=function()
					return _ENCH('FrmtActDefaultAll');
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
				text=_ENCH('GuiPrintin');
				helptext=_ENCH('HelpPrintin');
				callback=function(state)
					Enchantrix_SetFrame(state.value);
				end;
				feedback=function(state)
					local _, frameName = Enchantrix_GetFrameNames(state.value)
					return string.format(_ENCH('FrmtPrintin'), frameName);
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
				text=_ENCH('GuiDefaultOption');
				helptext=_ENCH('HelpDefault');
				callback = function(state)
					Enchantrix_Default(state.value);
				end;
				feedback = function (state)
					if (state.value == _ENCH('CmdClearAll')) then
						return _ENCH('FrmtActDefaultAll');
					else
						return string.format(_ENCH('FrmtActDefault'), state.value);
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
	Khaos.refresh();
	
	return true;
end

function Enchantrix_AuctioneerLoaded()
	if (not Enchantrix_Khaos_Registered) then return; end

	local insertPos = 9;

	if (Enchantrix_optionSet.options[insertPos].id == 'valuate-hsp') then
		return;
	end

	local AuctioneerOptions = {
		{
			id="valuate-hsp";
			type=K_TEXT;
			text=_ENCH('GuiValuateAverages');
			helptext=_ENCH('HelpGuessAuctioneerHsp');
			callback=function(state)
				Enchantrix_GenVarSet('valuate-hsp', state.checked);
			end;
			feedback=function(state)
				if (state.checked) then
					return (string.format(_ENCH('FrmtActEnable'), _ENCH('ShowGuessAuctioneerHsp')));
				else
					return (string.format(_ENCH('FrmtActDisable'), _ENCH('ShowGuessAuctioneerHsp')));
				end
			end;
			check=true;
			default={checked = Enchantrix_GetKhaosDefault('valuate-hsp')};
			disabled={checked = false};
			dependencies={valuate={checked=true;}, all={checked=true;}};
			difficulty=2;
		};
		{
			id="valuate-median";
			type=K_TEXT;
			text=_ENCH('GuiValuateMedian');
			helptext=_ENCH('HelpGuessAuctioneerMedian');
			callback=function(state)
				Enchantrix_GenVarSet('valuate-median', state.checked);
			end;
			feedback=function(state)
				if (state.checked) then
					return (string.format(_ENCH('FrmtActEnable'), _ENCH('ShowGuessAuctioneerMed')));
				else
					return (string.format(_ENCH('FrmtActDisable'), _ENCH('ShowGuessAuctioneerMed')));
				end
			end;
			check=true;
			default={checked = Enchantrix_GetKhaosDefault('valuate-median')};
			disabled={checked = false};
			dependencies={valuate={checked=true;}, all={checked=true;}};
			difficulty=2;
		};
	};

	Khaos.unregisterOptionSet("Enchantrix");

	Enchantrix_optionSet.options[insertPos - 1].helptext = _ENCH('HelpValue');
	
	for i, opt in ipairs(AuctioneerOptions) do
		tinsert(Enchantrix_optionSet.options, insertPos + i - 1, opt);
	end
	
	Khaos.registerOptionSet("tooltip", Enchantrix_optionSet);
	Khaos.refresh();
end

local function setKhaosSetKeyParameter(key, parameter, value)
	if (Enchantrix_Khaos_Registered) then
		if (Khaos.getSetKey("Enchantrix", key)) then
			Khaos.setSetKeyParameter("Enchantrix", key, parameter, value)
		else
			EnhTooltip.DebugPrint("setKhaosSetKeyParameter(): key " .. key .. " does not exist")
		end
	end
end

local function setKhaosSetKeyValue(key, value)
	if (Enchantrix_Khaos_Registered) then
		local kKey = Khaos.getSetKey("Enchantrix", key)

		if (not kKey) then
			EnhTooltip.DebugPrint("setKhaosSetKeyParameter(): key " .. key .. " does not exist")
		elseif (kKey.checked ~= nil) then
			-- EnhTooltip.DebugPrint("setKhaosSetKeyParameter(): setting ", value, " for key ", key)
			Khaos.setSetKeyParameter("Enchantrix", key, "checked", value)
		elseif (kKey.value ~= nil) then
			Khaos.setSetKeyParameter("Enchantrix", key, "value", value)
		else
			EnhTooltip.DebugPrint("setKhaosSetKeyParameter(): don't know how to update key ", key)
		end
	end
end

local function resetKhaos()
	if (Enchantrix_Khaos_Registered) then

		Khaos.unregisterOptionSet("Enchantrix");
		Enchantrix_Khaos_Registered = false;

		Enchantrix_Register_Khaos();

		if(Auctioneer) then
			Enchantrix_AuctioneerLoaded();
		end
	end
end

function Enchantrix_BuildCommandMap()
	Enchantrix_CommandMap = {
			[_ENCH('CmdDisable')] = 'disable',
			[_ENCH('CmdClear')] = 'clear',
			[_ENCH('CmdLocale')] = 'locale',
			[_ENCH('CmdDefault')] = 'default',
			[_ENCH('CmdPrintin')] = 'print-in',
			[_ENCH('CmdFindBidauct')] = 'bidbroker',
			[_ENCH('CmdFindBidauctShort')] = 'bidbroker',
			[_ENCH('CmdFindBuyauct')] = 'percentless',
			[_ENCH('CmdFindBuyauctShort')] = 'percentless',
			[_ENCH('ShowEmbed')] = 'embed',
			[_ENCH('ShowCount')] = 'counts',
			-- [_ENCH('ShowRate')] = 'rates',
			-- [_ENCH('ShowHeader')] = 'header',
			[_ENCH('ShowValue')] = 'valuate',
			[_ENCH('ShowGuessAuctioneerHsp')] = 'valuate-hsp',
			[_ENCH('ShowGuessAuctioneerMed')] = 'valuate-median',
			[_ENCH('ShowGuessBaseline')] = 'valuate-baseline',
		}

	Enchantrix_CommandMapRev = {}
	for k,v in pairs(Enchantrix_CommandMap) do
		Enchantrix_CommandMapRev[v] = k;
	end
end


-- Cleaner Command Handling Functions (added by MentalPower)
function Enchantrix_Command(command, source)

	-- To print or not to print, that is the question...
	local chatprint = nil;
	if (source == "GUI") then 
		chatprint = false;
	else 
		chatprint = true;
	end;

	-- Divide the large command into smaller logical sections (Shameless copy from the original function)
	local i,j, cmd, param = string.find(command, "^([^ ]+) (.+)$")
	if (not cmd) then cmd = command end
	if (not cmd) then cmd = "" end
	if (not param) then param = "" end
	cmd = Enchantrix_DelocalizeCommand(cmd)


	if ((cmd == "") or (cmd == "help")) then
		-- /enchantrix help
		Enchantrix_ChatPrint_Help();
		return;

	elseif (((cmd == _ENCH('CmdOn')) or (cmd == "on")) or ((cmd == _ENCH('CmdOff')) or (cmd == "off")) or ((cmd == _ENCH('CmdToggle')) or (cmd == "toggle"))) then
		-- /enchantrix on|off|toggle
		Enchantrix_OnOff(cmd, chatprint);

	elseif (cmd == 'disable') then
		-- /enchantrix disable
		Enchantrix_ChatPrint(_ENCH('MesgDisable'));
		Stubby.SetConfig("Enchantrix", "LoadType", "never");

	elseif (cmd == 'load') then
		-- /enchantrix load always|never
		if (param == "always") or (param == "never") then
			Stubby.SetConfig("Enchantrix", "LoadType", param);
			if (chatprint) then
				Enchantrix_ChatPrint("Setting Enchantrix to "..param.." load for this toon");
				setKhaosSetKeyValue("LoadSettings", param)
			end
		end

	elseif (cmd == 'clear') then
		-- /enchantrix clear
		Enchantrix_Clear(param, chatprint);

	elseif (cmd == 'locale') then
		-- /enchantrix locale
		Enchantrix_SetLocale(param, chatprint);

	elseif (cmd == 'default') then
		-- /enchantrix default
		Enchantrix_Default(param, chatprint);

	elseif (cmd == 'print-in') then
		-- /enchantrix print-in
		Enchantrix_SetFrame(param, chatprint)

	elseif (cmd == 'bidbroker') then
		-- /enchantrix bidbroker
		Enchantrix_DoBidBroker(param);

	elseif (cmd == 'percentless') then
		Enchantrix_DoPercentLess(param);

	-- elseif (cmd == _ENCH('ShowHeader') or cmd == 'header') then
	--	Enchantrix_GenVarSet('header', param, chatprint);

	elseif (cmd=='embed' or cmd=='valuate' or cmd=='counts' or
			-- cmd=='rates' or
			cmd=='valuate-hsp' or cmd=='valuate-median' or cmd=='valuate-baseline') then
		Enchantrix_GenVarSet(cmd, param, chatprint);

	elseif (chatprint) then
		Enchantrix_ChatPrint(string.format(_ENCH('FrmtActUnknown'), cmd));
	end
end

-- Help ME!! (The Handler) (Another shameless copy from the original function)
function Enchantrix_ChatPrint_Help()
Enchantrix_ChatPrint(_ENCH('FrmtUsage'));
		local onOffToggle = " (".._ENCH('CmdOn').."|".._ENCH('CmdOff').."|".._ENCH('CmdToggle')..")";
		local lineFormat = "  |cffffffff/enchantrix %s "..onOffToggle.."|r |cff2040ff[%s]|r - %s";

		Enchantrix_ChatPrint("  |cffffffff/enchantrix "..onOffToggle.."|r |cff2040ff["..Enchantrix_GetLocalizedFilterVal('all').."]|r - " .. _ENCH('HelpOnoff'));
		
		Enchantrix_ChatPrint("  |cffffffff/enchantrix ".._ENCH('CmdDisable').."|r - " .. _ENCH('HelpDisable'));

		-- Enchantrix_ChatPrint(string.format(lineFormat, _ENCH('ShowHeader'), Enchantrix_GetLocalizedFilterVal('header'), _ENCH('HelpHeader')));
		Enchantrix_ChatPrint(string.format(lineFormat, _ENCH('ShowCount'), Enchantrix_GetLocalizedFilterVal('counts'), _ENCH('HelpCount')));
		-- Enchantrix_ChatPrint(string.format(lineFormat, _ENCH('ShowRate'), Enchantrix_GetLocalizedFilterVal('rates'), _ENCH('HelpRate')));
		Enchantrix_ChatPrint(string.format(lineFormat, _ENCH('ShowEmbed'), Enchantrix_GetLocalizedFilterVal('embed'), _ENCH('HelpEmbed')));
		Enchantrix_ChatPrint(string.format(lineFormat, _ENCH('ShowValue'), Enchantrix_GetLocalizedFilterVal('valuate'), _ENCH('HelpValue')));
		if (AUCTIONEER_VERSION) then
			Enchantrix_ChatPrint(string.format(lineFormat, _ENCH('ShowGuessAuctioneerHsp'), Enchantrix_GetLocalizedFilterVal('valuate-hsp'), _ENCH('HelpGuessAuctioneerHsp')));
			Enchantrix_ChatPrint(string.format(lineFormat, _ENCH('ShowGuessAuctioneerMed'), Enchantrix_GetLocalizedFilterVal('valuate-median'), _ENCH('HelpGuessAuctioneerMedian')));
		else
			Enchantrix_ChatPrint(_ENCH('HelpGuessNoauctioneer'));
		end
		Enchantrix_ChatPrint(string.format(lineFormat, _ENCH('ShowGuessBaseline'), Enchantrix_GetLocalizedFilterVal('valuate-baseline'), _ENCH('HelpGuessBaseline')));

		lineFormat = "  |cffffffff/enchantrix %s %s|r - %s";
		Enchantrix_ChatPrint(string.format(lineFormat, _ENCH('CmdLocale'), _ENCH('OptLocale'), _ENCH('HelpLocale')));
		Enchantrix_ChatPrint(string.format(lineFormat, _ENCH('CmdClear'), _ENCH('OptClear'), _ENCH('HelpClear')));

		Enchantrix_ChatPrint(string.format(lineFormat, _ENCH('CmdFindBidauct'), _ENCH('OptFindBidauct'), _ENCH('HelpFindBidauct')));
		Enchantrix_ChatPrint(string.format(lineFormat, _ENCH('CmdFindBuyauct'), _ENCH('OptFindBuyauct'), _ENCH('HelpFindBuyauct')));
		Enchantrix_ChatPrint(string.format(lineFormat, _ENCH('CmdDefault'), _ENCH('OptDefault'), _ENCH('HelpDefault')));
		Enchantrix_ChatPrint(string.format(lineFormat, _ENCH('CmdPrintin'), _ENCH('OptPrintin'), _ENCH('HelpPrintin')));
end

-- The Enchantrix_OnOff(state, chatprint) function handles the state of the Enchantrix AddOn (whether it is currently on or off)
-- If "on" or "off" is specified in the "state" variable then Enchantrix's state is changed to that value,
-- If "toggle" is specified then it will toggle Enchantrix's state (if currently on then it will be turned off and vice-versa)
-- If no keyword is specified then the function will simply return the current state
--
-- If chatprint is "true" then the state will also be printed to the user.

function Enchantrix_OnOff(state, chatprint)
	state = Enchantrix_DelocalizeFilterVal(state)

	if ((state == nil) or (state == "")) then
		state = Enchantrix_GetFilterVal("all");
	elseif (state == 'on' or state == 'off') then
		Enchantrix_SetFilter('all', state);
	elseif (state == "toggle") then
		Enchantrix_SetFilter('all', not Enchantrix_GetFilter('all'))
	end

	-- Print the change and alert the GUI if the command came from slash commands. Do nothing if they came from the GUI.
	if (chatprint == true) then
		if (Enchantrix_GetFilter('all')) then
			Enchantrix_ChatPrint(_ENCH('StatOn'));
			setKhaosSetKeyParameter('all', "checked", true);
		else
			Enchantrix_ChatPrint(_ENCH('StatOff'));
			setKhaosSetKeyParameter('all', "checked", false);
		end
	end

	return state;
end

-- The following functions are almost verbatim copies of the original functions but modified in order to make them compatible with direct GUI access.
function Enchantrix_Clear(param, chatprint)
	if ((param == _ENCH('CmdClearAll')) or (param == "all")) then		
		EnchantedLocal = {};
		if (chatprint) then
			Enchantrix_ChatPrint(_ENCH('FrmtActClearall'));
		end
	else
		local items = Enchantrix_GetSigs(param);
		for _,itemKey in items do
			local aKey = itemKey.s;
			local aName = itemKey.n;
			EnchantedLocal[aKey] = { z=true };

			if (chatprint) then
				Enchantrix_ChatPrint(string.format(_ENCH('FrmtActClearOk'), aName));
			end
		end
	end
end

local function isValidLocale(param)

	--EnhTooltip.DebugPrint("Enchantrix.isValidlocale("..param..")");

	if((EnchantrixLocalizations) and (EnchantrixLocalizations[param])) then
		return true;

	else
		return false;
	end
end

function Enchantrix_SetLocale(param, chatprint)
	param = Enchantrix_DelocalizeFilterVal(param)
	if not Enchantrix_LocaleLastSet then Enchantrix_LocaleLastSet = ""; end
	--EnhTooltip.DebugPrint("Enchantrix_SetLocale("..param..") | "..Enchantrix_LocaleLastSet);
	local validLocale = nil;

	if (param == Enchantrix_LocaleLastSet) then
		validLocale = true;

	elseif (param == 'default') or (param == 'off') then
		Babylonian.SetOrder('');
		validLocale = true;

	elseif (isValidLocale(param)) then
		Babylonian.SetOrder(param);
		validLocale = true;

	else
		validLocale = false;
	end


	if (chatprint) then
		if (validLocale) then
			Enchantrix_ChatPrint(string.format(_ENCH('FrmtActSet'), _ENCH('CmdLocale'), param));
			if not (param == Enchantrix_LocaleLastSet) then
				EnhTooltip.DebugPrint("Changing Enchantrix's Khaos Language");
				setKhaosSetKeyValue('locale', param);
			end

		else
			Enchantrix_ChatPrint(string.format(_ENCH("FrmtActUnknownLocale"), param));
			local locales = "    ";
			for locale, data in pairs(EnchantrixLocalizations) do
				locales = locales .. " '" .. locale .. "' ";
			end
			Enchantrix_ChatPrint(locales);
		end
	end
		
	if Khaos and Enchantrix_Khaos_Registered then
		if not (param == Enchantrix_LocaleLastSet) then
			resetKhaos();
		end
	end

	Enchantrix_LocaleLastSet = param;

	Enchantrix_CommandMap = nil;
	Enchantrix_CommandMapRev = nil;
end

-- This function was added by MentalPower to implement the /enx default command
function Enchantrix_Default(param, chatprint)
	local paramLocalized

	if ( (param == nil) or (param == "") ) then
		return

	elseif ((param == _ENCH('CmdClearAll')) or (param == "all")) then
		param = "all"
		EnchantConfig.filters = {};

	else
		paramLocalized = param
		param = Enchantrix_DelocalizeCommand(param)
		Enchantrix_SetFilter(param, nil);
	end

	Enchantrix_SetFilterDefaults();		-- Apply defaults for settings that went missing 

	if (chatprint) then

		if (param == "all") then
			Enchantrix_ChatPrint(_ENCH('FrmtActDefaultAll'));

			for k,v in pairs(EnchantConfig.filters) do
				setKhaosSetKeyValue(k, Enchantrix_GetFilter(k));
			end

		else
			Enchantrix_ChatPrint(string.format(_ENCH('FrmtActDefault'), paramLocalized));
			setKhaosSetKeyValue(param, Enchantrix_GetFilter(param));
		end
	end
end



-- The following three functions were added by MentalPower to implement the /enx print-in command
function Enchantrix_GetFrameNames(index)

	local frames = {};
	local frameName = "";

	for i=1,10 do 
		local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(i);

		if ( name == "" ) then 

			if (i == 1) then
				frames[_ENCH('TextGeneral')] = 1;

			elseif (i == 2) then
				frames[_ENCH('TextCombat')] = 2;
			end

		else 
			frames[name] = i;
		end
	end

	if (index) then
		local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(index);
		if ( name == "" ) then 

			if (index == 1) then
				frameName = _ENCH('TextGeneral');

			elseif (index == 2) then
				frameName = _ENCH('TextCombat');
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

	-- If no arguments are passed, then set it to the default frame.
	if not (frame) then 
		frameNumber = 1;

	-- If the frame argument is a number then set our chatframe to that number.
	elseif ((frameVal) ~= nil) then 
		frameNumber = frameVal;

	-- If the frame argument is a string, find out if there's a chatframe with that name, and set our chatframe to that index. If not set it to the default frame.
	elseif (type(frame) == "string") then
		allFrames = Enchantrix_GetFrameNames();

		if (allFrames[frame]) then
			frameNumber = allFrames[frame];

		else
			frameNumber = 1;
		end

	-- If the argument is something else, set our chatframe to it's default value.
	else
		frameNumber = 1;
	end

	local _, frameName

	if (chatprint == true) then
		_, frameName = Enchantrix_GetFrameNames(frameNumber);

		if (Enchantrix_GetFrameIndex() ~= frameNumber) then
			Enchantrix_ChatPrint(string.format(_ENCH('FrmtPrintin'), frameName));
		end
	end

	Enchantrix_SetFilter("printframe", frameNumber);

	if (chatprint == true) then
		Enchantrix_ChatPrint(string.format(_ENCH('FrmtPrintin'), frameName));
		setKhaosSetKeyValue("printframe", frameNumber);
	end
end



function Enchantrix_GenVarSet(variable, param, chatprint)

	if (type(param) == "boolean") then
		if (param) then param = 'on'; else param = 'off'; end

	else
		param = Enchantrix_DelocalizeFilterVal(param);	
	end

	if (param == 'on' or param == 'off') then
		Enchantrix_SetFilter(variable, param);

	elseif (param == 'toggle' or param == nil or param == "") then
		Enchantrix_SetFilter(variable, not Enchantrix_GetFilter(variable))
	end

	if (chatprint) then
		if (Enchantrix_GetFilter(variable)) then
			Enchantrix_ChatPrint(string.format(_ENCH('FrmtActEnable'), Enchantrix_LocalizeCommand(variable)));
			setKhaosSetKeyParameter(variable, "checked", true);

		else
			Enchantrix_ChatPrint(string.format(_ENCH('FrmtActDisable'), Enchantrix_LocalizeCommand(variable)));
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
