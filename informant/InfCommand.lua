--[[
----  Informant
----  An addon for World of Warcraft that shows pertinent information about
----  an item in a tooltip when you hover over the item in the game.
----  <%version%>
----  $Id$
----  Command handler. Assumes responsibility for allowing the user to set the
----  options via slash command, Khaos, MyAddon etc.
--]]

-- function prototypes
local commandHandler, cmdHelp, onOff, genVarSet, chatPrint, registerKhaos, restoreDefault, cmdLocale, setLocale
local setKhaosSetKeyValue

-- Localization function prototypes
local delocalizeFilterVal, localizeFilterVal, getLocalizedFilterVal, delocalizeCommand, localizeCommand, buildCommandMap

local commandMap = nil;
local commandMapRev = nil;

Informant_Slash_Registered = nil
Informant_GUI_Registered = nil
Informant_Khaos_Registered = nil

Informant.InitCommands = function()
	SLASH_INFORMANT1 = "/informant"
	SLASH_INFORMANT2 = "/inform"
	SLASH_INFORMANT3 = "/info"
	SLASH_INFORMANT4 = "/inf"
	SlashCmdList["INFORMANT"] = function(msg)
		commandHandler(msg, nil)
	end

	chatPrint(string.format(_INFORMANT['FrmtWelcome'], INFORMANT_VERSION))

	if (Khaos) then
		if (not Informant_Khaos_Registered) then
			Informant_GUI_Registered = registerKhaos()
			if (Informant_GUI_Registered == true) then return true end
		end
	end
end

function setKhaosSetKeyValue(key, value)
	if (Auctioneer_Khaos_Registered) then
		local kKey = Khaos.getSetKey("Informant", key)

		if (not kKey) then
			EnhTooltip.DebugPrint("setKhaosSetKeyParameter(): key " .. key .. " does not exist")
		elseif (kKey.checked ~= nil) then
			if (type(value) == "string") then value = (value == "on"); end
			Khaos.setSetKeyParameter("Informant", key, "checked", value)
		elseif (kKey.value ~= nil) then
			Khaos.setSetKeyParameter("Informant", key, "value", value)
		else
			EnhTooltip.DebugPrint("setKhaosSetKeyValue(): don't know how to update key ", key)
		end
	end
end

function buildCommandMap()
	commandMap = {
			[_INFORMANT['CmdOn']] = 'on',
			[_INFORMANT['CmdOff']] = 'off',
			[_INFORMANT['CmdToggle']] = 'toggle',
			[_INFORMANT['CmdDisable']] = 'disable',
			[_INFORMANT['CmdLocale']] = 'locale',
			[_INFORMANT['CmdDefault']] = 'default',
			[_INFORMANT['CmdEmbed']] = 'embed',
			[_INFORMANT['ShowStack']] = 'show-stack',
			[_INFORMANT['ShowUsage']] = 'show-usage',
			[_INFORMANT['ShowQuest']] = 'show-quest',
			[_INFORMANT['ShowMerchant']] = 'show-merchant',
			[_INFORMANT['ShowVendor']] = 'show-vendor',
			[_INFORMANT['ShowVendorBuy']] = 'show-vendor-buy',
			[_INFORMANT['ShowVendorSell']] = 'show-vendor-sell',
		}

	commandMapRev = {}
	for k,v in pairs(commandMap) do
		commandMapRev[v] = k;
	end
end

--Cleaner Command Handling Functions (added by MentalPower)
function commandHandler(command, source)
	--To print or not to print, that is the question...
	local chatprint = nil
	if (source == "GUI") then chatprint = false
	else chatprint = true end

	--Divide the large command into smaller logical sections (Shameless copy from the original function)
	local i,j, cmd, param = string.find(command, "^([^ ]+) (.+)$")
	if (not cmd) then cmd = command end
	if (not cmd) then cmd = "" end
	if (not param) then param = "" end
	cmd = delocalizeCommand(cmd);

	--Now for the real Command handling
	if ((cmd == "") or (cmd == "help")) then
		cmdHelp()
		return

	elseif (cmd == "on" or cmd == "off" or cmd == "toggle") then
		onOff(cmd, chatprint)
	elseif (cmd == "disable") then
		Stubby.SetConfig("Informant", "LoadType", "never");
	elseif (cmd == "load") then
		if (param == "always") or (param == "never") then
			chatPrint("Setting Informant to "..param.." load for this toon");
			Stubby.SetConfig("Informant", "LoadType", param);
		end
	elseif (cmd == "locale") then
		cmdLocale(param, chatprint)
	elseif (cmd == "default") then
		restoreDefault(param, chatprint)
	elseif (cmd == "embed" or cmd == "show-stack" or cmd == "show-usage" or
			cmd == "show-quest" or cmd == "show-merchant" or cmd == "show-vendor" or
			cmd == "show-vendor-buy" or cmd == "show-vendor-sell") then
		genVarSet(cmd, param, chatprint)
	else
		if (chatprint) then
			chatPrint(string.format(_INFORMANT['FrmtActUnknown'], cmd))
		end
	end
end

--Help ME!! (The Handler) (Another shameless copy from the original function)
function cmdHelp()

	local onOffToggle = " (".._INFORMANT['CmdOn'].."|".._INFORMANT['CmdOff'].."|".._INFORMANT['CmdToggle']..")"
	local lineFormat = "  |cffffffff/informant %s "..onOffToggle.."|r |cffff4020[%s]|r - %s"

	chatPrint(_INFORMANT['TextUsage'])
	chatPrint("  |cffffffff/informant "..onOffToggle.."|r |cffff4020["..getLocalizedFilterVal('all').."]|r - " .. _INFORMANT['HelpOnoff'])

	chatPrint("  |cffffffff/informant ".._INFORMANT['CmdDisable'].."|r - " .. _INFORMANT['HelpDisable']);

	chatPrint(string.format(lineFormat, _INFORMANT['ShowVendor'], getLocalizedFilterVal('show-vendor'), _INFORMANT['HelpVendor']))
	chatPrint(string.format(lineFormat, _INFORMANT['ShowVendorSell'], getLocalizedFilterVal('show-vendor-sell'), _INFORMANT['HelpVendorSell']))
	chatPrint(string.format(lineFormat, _INFORMANT['ShowVendorBuy'], getLocalizedFilterVal('show-vendor-buy'), _INFORMANT['HelpVendorBuy']))
	chatPrint(string.format(lineFormat, _INFORMANT['ShowUsage'], getLocalizedFilterVal('show-usage'), _INFORMANT['HelpUsage']))
	chatPrint(string.format(lineFormat, _INFORMANT['ShowStack'], getLocalizedFilterVal('show-stack'), _INFORMANT['HelpStack']))
	chatPrint(string.format(lineFormat, _INFORMANT['CmdEmbed'], getLocalizedFilterVal('embed'), _INFORMANT['HelpEmbed']))

	lineFormat = "  |cffffffff/informant %s %s|r |cffff4020[%s]|r - %s"
	chatPrint(string.format(lineFormat, _INFORMANT['CmdLocale'], _INFORMANT['OptLocale'], getLocalizedFilterVal('locale'), _INFORMANT['HelpLocale']))

	lineFormat = "  |cffffffff/informant %s %s|r - %s"
	chatPrint(string.format(lineFormat, _INFORMANT['CmdDefault'], "", _INFORMANT['HelpDefault']))
end

--The onOff(state, chatprint) function handles the state of the Informant AddOn (whether it is currently on or off)
--If "on" or "off" is specified in the " state" variable then Informant's state is changed to that value,
--If "toggle" is specified then it will toggle Informant's state (if currently on then it will be turned off and vice-versa)
--If no keyword is specified then the functione will simply return the current state
--
--If chatprint is "true" then the state will also be printed to the user.

local function onOff(state, chatprint)

	if ((state == nil) or (state == "")) then
		state = Informant.GetFilterVal("all")


	elseif ((state == _INFORMANT['CmdOn']) or (state == "on")) then
		Informant.SetFilter("all", "on")


	elseif ((state == _INFORMANT['CmdOff']) or (state == "off")) then
		Informant.SetFilter("all", "off")


	elseif ((state == _INFORMANT['CmdToggle']) or (state == "toggle")) then
		state = Informant.GetFilterVal("all")

		if (state == "off") then
			Informant.SetFilter("all", "on")
		else
			Informant.SetFilter("all", "off")
		end
	end

	--Print the change and alert the GUI if the command came from slash commands. Do nothing if they came from the GUI.
	if (chatprint == true) then
		if ((state == _INFORMANT['CmdOn']) or (state == "on")) then
			chatPrint(_INFORMANT['StatOn'])

			if (Informant_Khaos_Registered) then
				Khaos.setSetKeyParameter("Informant", "InformantEnable", "checked", true)
			end
		else
			chatPrint(_INFORMANT['StatOff'])

			if (Informant_Khaos_Registered) then
				Khaos.setSetKeyParameter("Informant", "InformantEnable", "checked", false)
			end
		end
	end

	return state
end

function cmdLocale(param, chatprint)
	param = delocalizeFilterVal(param);
	local validLocale = nil;

	if (param == Informant.GetFilterVal('locale')) then
		validLocale = true;
	elseif (setLocale(param)) then
		validLocale = true;
	end

	if (chatprint) then
		if (validLocale) then
			chatPrint(string.format(_INFORMANT['FrmtActSet'], _INFORMANT['CmdLocale'], localizeFilterVal(param)));
		else
			chatPrint(string.format(_INFORMANT['FrmtUnknownLocale'], param));
			if (INFORMANT_VALID_LOCALES) then
				for locale, x in pairs(INFORMANT_VALID_LOCALES) do
					chatPrint("  "..locale);
				end
			end
		end
	end
end

function restoreDefault(param, chatprint)
	local oldLocale = InformantConfig.filters['locale']
	
	if ( (param == nil) or (param == "") ) then
		return
	elseif ((param == _INFORMANT['CmdClearAll']) or (param == "all")) then
		param = "all";
		InformantConfig.filters = {};
	else
		paramLocalized = param
		param = delocalizeCommand(param)
		Informant.SetFilter(param, nil);
	end
	
	-- Apply defaults for settings that went missing
	Informant.SetFilterDefaults();		
	
	-- Apply new locale if needed 
	if (oldLocale ~= InformantConfig.filters['locale']) then setLocale(InformantConfig.filters['locale']); end

	if (chatprint) then
		if (param == "all") then
			chatPrint(_INFORMANT['FrmtActDefaultall']);
			for k,v in pairs(InformantConfig.filters) do
				setKhaosSetKeyValue(k, Informant.GetFilterVal(k));
			end
		else
			chatPrint(string.format(_INFORMANT['FrmtActDefault'], paramLocalized));
			setKhaosSetKeyValue(param, Informant.GetFilterVal(param));
		end
	end
end

function genVarSet(variable, param, chatprint)
	if (type(param) == "string") then
		param = delocalizeFilterVal(param);
	end

	if (param == "on" or param == "off" or type(param) == "boolean") then
		Informant.SetFilter(variable, param);
	elseif (param == "toggle" or param == nil or param == "") then
		param = Informant.SetFilter(variable, not Informant.GetFilter(variable));
	end

	if (chatprint) then
		if (Informant.GetFilter(variable)) then
			chatPrint(string.format(_INFORMANT['FrmtActEnable'], localizeCommand(variable)))
			setKhaosSetKeyValue(variable, true)
		else
			chatPrint(string.format(_INFORMANT['FrmtActDisable'], localizeCommand(variable)))
			setKhaosSetKeyValue(variable, false)
		end
	end
end

function registerKhaos()
	local optionSet = {
		id="Informant",
		text="Informant",
		helptext=_INFORMANT['GuiMainHelp'],
		difficulty=1,
		default={checked=true},
		options={
			{
				id="Header",
				text="Informant",
				helptext=_INFORMANT['GuiMainHelp'],
				type=K_HEADER,
				difficulty=1,
			},
			{
				id="enabled",
				type=K_TEXT,
				text=_INFORMANT['GuiMainEnable'],
				helptext=_INFORMANT['HelpOnoff'],
				callback=function(state)
					onOff(state.checked)
				end,
				feedback=function(state)
					if (state.checked) then
						return _INFORMANT['StatOn']
					else
						return _INFORMANT['StatOff']
					end
				end,
				check=true,
				default={checked=true},
				disabled={checked=false},
				difficulty=1,
			},
			{
				id="locale",
				type=K_EDITBOX,
				setup = {
					callOn = {"enter", "tab"}
				},
				text=_INFORMANT['GuiLocale'],
				helptext=_INFORMANT['HelpLocale'],
				callback = function(state)
					cmdLocale(state.value)
				end,
				feedback = function (state)
					return string.format(_INFORMANT['FrmtActSet'], _INFORMANT['CmdLocale'], state.value)
				end,
				default = {
					value = getLocale()
				},
				disabled = {
					value = getLocale()
				},
				dependencies={enabled={checked=true}},
				difficulty=2,
			},
			{
				id="ReloadUI",
				type=K_BUTTON,
				setup={
					buttonText = _INFORMANT['GuiReloaduiButton']
				},
				text=_INFORMANT['GuiReloadui'],
				helptext=_INFORMANT['GuiReloaduiHelp'],
				callback=function()
					ReloadUI()
				end,
				feedback=function()
					return _INFORMANT['GuiReloaduiFeedback'];
				end;
				difficulty=3,
			},
			{
				id="InformantInfoHeader",
				type=K_HEADER,
				text=_INFORMANT['GuiInfoHeader'],
				helptext=_INFORMANT['GuiInfoHelp'],
				difficulty=1,
			},
			{
				id="show-stack",
				type=K_TEXT,
				text=_INFORMANT['GuiInfoStack'],
				helptext=_INFORMANT['HelpStack'],
				callback=function(state)
					genVarSet("show-stack", state.checked)
				end,
				feedback=function(state)
					if (state.checked) then
						return (string.format(_INFORMANT['FrmtActEnable'],  _INFORMANT['ShowStack']))
					else
						return (string.format(_INFORMANT['FrmtActDisable'], _INFORMANT['ShowStack']))
					end
				end,
				check=true,
				default={checked=true},
				disabled={checked=false},
				dependencies={enabled={checked=true}},
				difficulty=1,
			},
			{
				id="show-usage",
				type=K_TEXT,
				text=_INFORMANT['GuiInfoUsage'],
				helptext=_INFORMANT['HelpUsage'],
				callback=function(state)
					genVarSet("show-usage", state.checked)
				end,
				feedback=function(state)
					if (state.checked) then
						return (string.format(_INFORMANT['FrmtActEnable'],  _INFORMANT['ShowUsage']))
					else
						return (string.format(_INFORMANT['FrmtActDisable'], _INFORMANT['ShowUsage']))
					end
				end,
				check=true,
				default={checked=true},
				disabled={checked=false},
				dependencies={enabled={checked=true}},
				difficulty=1,
			},
			--[[
			{
				id="show-quest",
				type=K_TEXT,
				text=_INFORMANT['GuiInfoQuest'],
				helptext=_INFORMANT['HelpQuest'],
				callback=function(state)
					genVarSet("show-quest", state.checked)
				end,
				feedback=function(state)
					if (state.checked) then
						return (string.format(_INFORMANT['FrmtActEnable'],  _INFORMANT['ShowQuest']))
					else
						return (string.format(_INFORMANT['FrmtActDisable'], _INFORMANT['ShowQuest']))
					end
				end,
				check=true,
				default={checked=true},
				disabled={checked=false},
				dependencies={enabled={checked=true}},
				difficulty=1,
			},
			{
				id="show-merchant",
				type=K_TEXT,
				text=_INFORMANT['GuiInfoMerchant'],
				helptext=_INFORMANT['HelpMerchant'],
				callback=function(state)
					genVarSet("show-merchant", state.checked)
				end,
				feedback=function(state)
					if (state.checked) then
						return (string.format(_INFORMANT['FrmtActEnable'],  _INFORMANT['ShowMerchant']))
					else
						return (string.format(_INFORMANT['FrmtActDisable'], _INFORMANT['ShowMerchant']))
					end
				end,
				check=true,
				default={checked=true},
				disabled={checked=false},
				dependencies={enabled={checked=true}},
				difficulty=1,
			},
			]]
			{
				id="InformantVendorHeader",
				type=K_HEADER,
				text=_INFORMANT['GuiVendorHeader'],
				helptext=_INFORMANT['GuiVendorHelp'],
				difficulty=1,
			},
			{
				id="show-vendor",
				type=K_TEXT,
				text=_INFORMANT['GuiVendor'],
				helptext=_INFORMANT['HelpVendor'],
				callback=function(state)
					genVarSet("show-vendor", state.checked)
				end,
				feedback=function(state)
					if (state.checked) then
						return (string.format(_INFORMANT['FrmtActEnable'], _INFORMANT['ShowVendor']))
					else
						return (string.format(_INFORMANT['FrmtActDisable'], _INFORMANT['ShowVendor']))
					end
				end,
				check=true,
				default={checked=true},
				disabled={checked=false},
				dependencies={enabled={checked=true}},
				difficulty=1,
			},
			{
				id="show-vendor-buy",
				type=K_TEXT,
				text=_INFORMANT['GuiVendorBuy'],
				helptext=_INFORMANT['HelpVendorBuy'],
				callback=function(state)
					genVarSet("show-vendor-buy", state.checked)
				end,
				feedback=function(state)
					if (state.checked) then
						return (string.format(_INFORMANT['FrmtActEnable'], _INFORMANT['ShowVendorBuy']))
					else
						return (string.format(_INFORMANT['FrmtActDisable'], _INFORMANT['ShowVendorBuy']))
					end
				end,
				check=true,
				default={checked=true},
				disabled={checked=false},
				dependencies={["show-vendor"]={checked=true}, enabled={checked=true}},
				difficulty=2,
			},
			{
				id="show-vendor-sell",
				type=K_TEXT,
				text=_INFORMANT['GuiVendorSell'],
				helptext=_INFORMANT['HelpVendorSell'],
				callback=function(state)
					genVarSet("show-vendor-sell", state.checked)
				end,
				feedback=function(state)
					if (state.checked) then
						return (string.format(_INFORMANT['FrmtActEnable'], _INFORMANT['ShowVendorSell']))
					else
						return (string.format(_INFORMANT['FrmtActDisable'], _INFORMANT['ShowVendorSell']))
					end
				end,
				check=true,
				default={checked=true},
				disabled={checked=false},
				dependencies={["show-vendor"]={checked=true}, enabled={checked=true}},
				difficulty=2,
			},

			{
				id="InformantEmbedHeader",
				type=K_HEADER,
				text=_INFORMANT['GuiEmbedHeader'],
				helptext=_INFORMANT['HelpEmbed'],
				difficulty=1,
			},
			{
				id="embed",
				type=K_TEXT,
				text=_INFORMANT['GuiEmbed'],
				helptext=_INFORMANT['HelpEmbed'],
				callback=function(state)
					genVarSet("embed", state.checked)				
				end,
				feedback=function(state)
					if (state.checked) then
						return (string.format(_INFORMANT['FrmtActEnable'], _INFORMANT['CmdEmbed']))
					else
						return (string.format(_INFORMANT['FrmtActDisable'], _INFORMANT['CmdEmbed']))
					end
				end,
				check=true,
				default={checked=false},
				disabled={checked=false},
				dependencies={enabled={checked=true}},
				difficulty=1,
			},
			{
				id="InformantOtherHeader",
				type=K_HEADER,
				text=_INFORMANT['GuiOtherHeader'],
				helptext=_INFORMANT['GuiOtherHelp'],
				difficulty=1,
			},
			{
				id="DefaultAll",
				type=K_BUTTON,
				setup={
					buttonText = _INFORMANT['GuiDefaultAllButton']
				},
				text=_INFORMANT['GuiDefaultAll'],
				helptext=_INFORMANT['GuiDefaultAllHelp'],
				callback=function()
					restoreDefault(_INFORMANT['CmdClearAll'])
				end,
				feedback=function()
					return _INFORMANT['FrmtActDefaultall'];
				end;
				dependencies={InformantEnable={checked=true}},
				difficulty=1,
			},
			{
				id="DefaultOption",
				type=K_EDITBOX,
				setup = {
					callOn = {"enter", "tab"}
				},
				text=_INFORMANT['GuiDefaultOption'],
				helptext=_INFORMANT['HelpDefault'],
				callback = function(state)
					restoreDefault(state.value)
				end,
				feedback = function (state)
					if (state.value == _INFORMANT['CmdClearAll']) then
						return _INFORMANT['FrmtActDefaultall']
					else
						return string.format(_INFORMANT['FrmtActDefault'], state.value)
					end
				end,
				default = {
					value = ""
				},
				disabled = {
					value = ""
				},
				dependencies={InformantEnable={checked=true}},
				difficulty=4,
			},
		}
	}

	Khaos.registerOptionSet("tooltip",optionSet)
	Informant_Khaos_Registered = true

	return true
end

Informant.Register = function()
	if (Khaos) then
		if (not Informant_Khaos_Registered) then
			Informant_GUI_Registered = registerKhaos()
		end
	end
	-- The following check is to accomodate other GUI libraries other than Khaos relatively easily.
	if (Informant_GUI_Registered == true) then
		return true
	else
		return false
	end
end

function setLocale(locale)
	locale = delocalizeFilterVal(locale);
	
	if (INFORMANT_VALID_LOCALES[locale]) then
		Informant.SetFilter('locale', locale);		
	elseif (locale == '') or (locale == 'default') or (locale == 'off') then
		locale = 'default';
		Informant.SetFilter('locale', 'default');
	else
		return false;
	end

	Informant_SetLocaleStrings(Informant.GetLocale());
	commandMap = nil;
	commandMapRev = nil;
		
	if Khaos and Informant_Khaos_Registered then
		setKhaosSetKeyValue('locale', locale);
		Khaos.unregisterOptionSet("Informant");
		Khaos.refresh();
		registerKhaos();
		Khaos.refresh();
	end
	
	return true;
end

function chatPrint(msg)
	if (DEFAULT_CHAT_FRAME) then 
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.25, 0.55, 1.0);
	end
end

--------------------------------------
--		Localization functions		--
--------------------------------------

function delocalizeFilterVal(value)
	if (value == _INFORMANT['CmdOn']) then
		return 'on';
	elseif (value == _INFORMANT['CmdOff']) then
		return 'off';
	elseif (value == _INFORMANT['CmdDefault']) then
		return 'default';
	elseif (value == _INFORMANT['CmdToggle']) then
		return 'toggle';
	else
		return value;
	end	
end

function localizeFilterVal(value)
	local result
	if (value == 'on') then
		result = _INFORMANT['CmdOn'];
	elseif (value == 'off') then
		result = _INFORMANT['CmdOff'];
	elseif (value == 'default') then
		result = _INFORMANT['CmdDefault'];
	elseif (value == 'toggle') then
		result = _INFORMANT['CmdToggle'];
	end
	if (result) then return result; else return value; end
end

function getLocalizedFilterVal(key)
	return localizeFilterVal(Informant.GetFilterVal(key))
end

-- Turns a localized slash command into the generic English version of the command
function delocalizeCommand(cmd)
	if (not commandMap) then buildCommandMap(); end
	local result = commandMap[cmd];
	if (result) then return result; else return cmd; end
end

-- Translate a generic English slash command to the localized version, if available
function localizeCommand(cmd)
	if (not commandMapRev) then buildCommandMap(); end
	local result = commandMapRev[cmd];
	if (result) then return result; else return cmd; end
end

-- Globally accessible functions
Informant.SetLocale = setLocale;