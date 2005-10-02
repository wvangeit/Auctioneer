--[[
----  Informant
----  An addon for World of Warcraft that shows pertinent information about
----  an item in a tooltip when you hover over the item in the game.
----  <%version%>
----  $Id$
----  Command handler. Assumes responsibility for allowing the user to set the
----  options via slash command, Khaos, MyAddon etc.
--]]


local commandHandler, doHelp, onOff, genVarSet, chatPrint, registerKhaos, restoreDefault, setLocale, getLocale

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

	if (Khaos) then
		if (not Informant_Khaos_Registered) then
			Informant_GUI_Registered = registerKhaos()
			if (Informant_GUI_Registered == true) then return true end
		end
	end

end


--Cleaner Command Handling Functions (added by MentalPower)
commandHandler = function (command, source)

	--To print or not to print, that is the question...
	local chatprint = nil
	if (source == "GUI") then chatprint = false
	else chatprint = true end

	--Divide the large command into smaller logical sections (Shameless copy from the original function)
	local i,j, cmd, param = string.find(command, "^([^ ]+) (.+)$")
	if (not cmd) then cmd = command end
	if (not cmd) then cmd = "" end
	if (not param) then param = "" end

	--Now for the real Command handling
	if ((cmd == "") or (cmd == "help")) then
		doHelp()
		return

	elseif (((cmd == _INFORMANT['CmdOn']) or (cmd == "on")) or ((cmd == _INFORMANT['CmdOff']) or (cmd == "off")) or ((cmd == _INFORMANT['CmdToggle']) or (cmd == "toggle"))) then
		onOff(cmd, chatprint)

	elseif ((cmd == _INFORMANT['CmdLocale']) or (cmd == "locale")) then
		setLocale(param, chatprint)

	elseif ((cmd == _INFORMANT['CmdDefault']) or (cmd == "default")) then
		restoreDefault(param, chatprint)

	elseif (
		((cmd == _INFORMANT['CmdEmbed']) or (cmd == "embed")) or
		((cmd == _INFORMANT['ShowStack']) or (cmd == "show-stack")) or
		((cmd == _INFORMANT['ShowUsage']) or (cmd == "show-usage")) or
		((cmd == _INFORMANT['ShowQuest']) or (cmd == "show-vendor")) or
		((cmd == _INFORMANT['ShowMerchant']) or (cmd == "show-vendor")) or
		((cmd == _INFORMANT['ShowVendor']) or (cmd == "show-vendor")) or
		((cmd == _INFORMANT['ShowVendorBuy']) or (cmd == "show-vendor-buy")) or
		((cmd == _INFORMANT['ShowVendorSell']) or (cmd == "show-vendor-sell"))
	) then
		genVarSet(cmd, param, chatprint)

	else
		if (chatprint == true) then
			chatPrint(string.format(_INFORMANT['FrmtActUnknown'], cmd))
		end
	end
end

--Help ME!! (The Handler) (Another shameless copy from the original function)
function doHelp()

	local onOffToggle = " (".._INFORMANT['CmdOn'].."|".._INFORMANT['CmdOff'].."|".._INFORMANT['CmdToggle']..")"
	local lineFormat = "  |cffffffff/informant %s "..onOffToggle.."|r |cff2040ff[%s]|r - %s"

	chatPrint(_INFORMANT['TextUsage'])
	chatPrint("  |cffffffff/informant "..onOffToggle.."|r |cff2040ff["..Informant.GetFilterVal("all").."]|r - " .. _INFORMANT['HelpOnoff'])

	chatPrint(string.format(lineFormat, _INFORMANT['ShowVendor'], Informant.GetFilterVal(_INFORMANT['ShowVendor']), _INFORMANT['HelpVendor']))
	chatPrint(string.format(lineFormat, _INFORMANT['ShowVendorSell'], Informant.GetFilterVal(_INFORMANT['ShowVendorSell']), _INFORMANT['HelpVendorSell']))
	chatPrint(string.format(lineFormat, _INFORMANT['ShowVendorBuy'], Informant.GetFilterVal(_INFORMANT['ShowVendorBuy']), _INFORMANT['HelpVendorBuy']))
	chatPrint(string.format(lineFormat, _INFORMANT['ShowUsage'], Informant.GetFilterVal(_INFORMANT['ShowUsage']), _INFORMANT['HelpUsage']))
	chatPrint(string.format(lineFormat, _INFORMANT['ShowStack'], Informant.GetFilterVal(_INFORMANT['ShowStack']), _INFORMANT['HelpStack']))
	chatPrint(string.format(lineFormat, _INFORMANT['CmdEmbed'], Informant.GetFilterVal(_INFORMANT['CmdEmbed']), _INFORMANT['HelpEmbed']))

	lineFormat = "  |cffffffff/informant %s %s|r |cff2040ff[%s]|r - %s"
	chatPrint(string.format(lineFormat, _INFORMANT['CmdLocale'], _INFORMANT['OptLocale'], Informant.GetFilterVal('locale'), _INFORMANT['HelpLocale']))

	lineFormat = "  |cffffffff/informant %s %s|r - %s"
	chatPrint(string.format(lineFormat, _INFORMANT['CmdDefault'], "", _INFORMANT['HelpDefault']))

end

--The onOff(state, chatprint) function handles the state of the Informant AddOn (whether it is currently on or off)
--If "on" or "off" is specified in the " state" variable then Informant's state is changed to that value,
--If "toggle" is specified then it will toggle Informant's state (if currently on then it will be turned off and vice-versa)
--If no keyword is specified then the functione will simply return the current state
--
--If chatprint is "true" then the state will also be printed to the user.

function onOff(state, chatprint)

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

function setLocale(param, chatprint)

local validLocale=nil;

	if (param == getLocale()) then
		--Do Nothing
		validLocale=true;
	elseif (INFORMANT_VALID_LOCALES[param]) then
		Informant.SetFilter('locale', param);
		Informant_SetLocaleStrings(getLocale());
		validLocale=true;

	elseif (param == '') or (param == 'default') or (param == 'off') then
		Informant.SetFilter('locale', 'default');
		Informant_SetLocaleStrings(getLocale());
		validLocale=true;
	end
	
	
	if (chatprint == true) then

		if ((validLocale == true) and (INFORMANT_VALID_LOCALES[param])) then
			chatPrint(string.format(_INFORMANT['FrmtActSet'], _INFORMANT['CmdLocale'], param));
			
			if (Informant_Khaos_Registered) then
				Khaos.setSetKeyParameter("Informant", "InformantLocale", "value", param);
			end

		elseif (validLocale == nil) then
			chatPrint(string.format(_INFORMANT['FrmtUnknownLocale'], param));

			if (INFORMANT_VALID_LOCALES) then
				for locale, x in pairs(INFORMANT_VALID_LOCALES) do
					chatPrint("  "..locale);
				end
			end

		else
			chatPrint(string.format(_INFORMANT['FrmtActSet'], _INFORMANT['CmdLocale'], 'default'));

			if (Informant_Khaos_Registered) then
				Khaos.setSetKeyParameter("Informant", "InformantLocale", "value", "default");
			end
		end
	end
end

function restoreDefault(param, chatprint)
	if ( (param == nil) or (param == "") ) then
		return

	elseif ((param == _INFORMANT['CmdClearAll']) or (param == "all")) then
		InformantConfig.filters = {};

	else
		Informant.SetFilter(param, nil);
	end

	--@TODO: Move the default setting for the different functions over here to be able to communicate to Khaos what those setting are.
	if (chatprint == true) then
		if ((param == _INFORMANT['CmdClearAll']) or (param == "all")) then
			chatPrint(_INFORMANT['FrmtActDefaultall']);

		else
			chatPrint(string.format(_INFORMANT['FrmtActDefault'], param));
		end
	end
end

function genVarSet(variable, param, chatprint)
	if ((param == _INFORMANT['CmdOn']) or (param == "on")) then
		Informant.SetFilter(variable, "on")

	elseif ((param == _INFORMANT['CmdOff']) or (param == "off")) then
		Informant.SetFilter(variable, "off")

	elseif ((param == _INFORMANT['CmdToggle']) or (param == "toggle") or (param == nil) or (param == "")) then
		param = Informant.GetFilterVal(variable)

		if ((param == _INFORMANT['CmdOn']) or (param == "on")) then
			param = _INFORMANT['CmdOff']

		else
			param = _INFORMANT['CmdOn']
		end

		Informant.SetFilter(variable, param)
	end

	if (chatprint == true) then

		if ((param == _INFORMANT['CmdOn']) or (param == "on")) then
			chatPrint(string.format(_INFORMANT['FrmtActEnable'], variable))

			if (Informant_Khaos_Registered) then
				Khaos.setSetKeyParameter("Informant", variable, "checked", true)
			end

		elseif ((param == _INFORMANT['CmdOff']) or (param == "off")) then
			chatPrint(string.format(_INFORMANT['FrmtActDisable'], variable))

			if (Informant_Khaos_Registered) then
				Khaos.setSetKeyParameter("Informant", variable, "checked", false)
			end
		end
	end
end

Informant.Register = function()
	if (Khaos) then
		if (not Informant_Khaos_Registered) then
			Informant_GUI_Registered = Informant_Register_Khaos()
		end
	end
	-- The following check is to accomodate other GUI libraries other than Khaos relatively easily.
	if (Informant_GUI_Registered == true) then
		return true
	else
		return false
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
				id="InformantEnable",
				type=K_TEXT,
				text=_INFORMANT['GuiMainEnable'],
				helptext=_INFORMANT['HelpOnoff'],
				callback=function(state)
					if (state.checked) then
						onOff(_INFORMANT['CmdOn'])
					else
						onOff(_INFORMANT['CmdOff'])
					end
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
				id="InformantLocale",
				type=K_EDITBOX,
				setup = {
					callOn = {"enter", "tab"}
				},
				text=_INFORMANT['GuiLocale'],
				helptext=_INFORMANT['HelpLocale'],
				callback = function(state)
					setLocale(state.value)
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
				dependencies={InformantEnable={checked=true}},
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
				id=_INFORMANT['ShowStack'],
				key="InformantStack",
				type=K_TEXT,
				text=_INFORMANT['GuiInfoStack'],
				helptext=_INFORMANT['HelpStack'],
				callback=function(state)
					if (state.checked) then
						genVarSet(_INFORMANT['ShowStack'], _INFORMANT['CmdOn'])
					else
						genVarSet(_INFORMANT['ShowStack'], _INFORMANT['CmdOff'])
					end
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
				dependencies={InformantEnable={checked=true}},
				difficulty=1,
			},
			{
				id=_INFORMANT['ShowUsage'],
				key="InformantUsage",
				type=K_TEXT,
				text=_INFORMANT['GuiInfoUsage'],
				helptext=_INFORMANT['HelpUsage'],
				callback=function(state)
					if (state.checked) then
						genVarSet(_INFORMANT['ShowUsage'], _INFORMANT['CmdOn'])
					else
						genVarSet(_INFORMANT['ShowUsage'], _INFORMANT['CmdOff'])
					end
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
				dependencies={InformantEnable={checked=true}},
				difficulty=1,
			},
			{
				id=_INFORMANT['ShowQuest'],
				key="InformantQuest",
				type=K_TEXT,
				text=_INFORMANT['GuiInfoQuest'],
				helptext=_INFORMANT['HelpQuest'],
				callback=function(state)
					if (state.checked) then
						genVarSet(_INFORMANT['ShowQuest'], _INFORMANT['CmdOn'])
					else
						genVarSet(_INFORMANT['ShowQuest'], _INFORMANT['CmdOff'])
					end
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
				dependencies={InformantEnable={checked=true}},
				difficulty=1,
			},
			{
				id=_INFORMANT['ShowMerchant'],
				key="InformantMerchant",
				type=K_TEXT,
				text=_INFORMANT['GuiInfoMerchant'],
				helptext=_INFORMANT['HelpMerchant'],
				callback=function(state)
					if (state.checked) then
						genVarSet(_INFORMANT['ShowMerchant'], _INFORMANT['CmdOn'])
					else
						genVarSet(_INFORMANT['ShowMerchant'], _INFORMANT['CmdOff'])
					end
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
				dependencies={InformantEnable={checked=true}},
				difficulty=1,
			},
			{
				id="InformantVendorHeader",
				type=K_HEADER,
				text=_INFORMANT['GuiVendorHeader'],
				helptext=_INFORMANT['GuiVendorHelp'],
				difficulty=1,
			},
			{
				id=_INFORMANT['ShowVendor'],
				key="InformantVendor",
				type=K_TEXT,
				text=_INFORMANT['GuiVendor'],
				helptext=_INFORMANT['HelpVendor'],
				callback=function(state)
					if (state.checked) then
						genVarSet(_INFORMANT['ShowVendor'], _INFORMANT['CmdOn'])
					else
						genVarSet(_INFORMANT['ShowVendor'], _INFORMANT['CmdOff'])
					end
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
				dependencies={InformantEnable={checked=true}},
				difficulty=1,
			},
			{
				id=_INFORMANT['ShowVendorBuy'],
				type=K_TEXT,
				text=_INFORMANT['GuiVendorBuy'],
				helptext=_INFORMANT['HelpVendorBuy'],
				callback=function(state)
					if (state.checked) then
						genVarSet(_INFORMANT['ShowVendorBuy'], _INFORMANT['CmdOn'])
					else
						genVarSet(_INFORMANT['ShowVendorBuy'], _INFORMANT['CmdOff'])
					end
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
				dependencies={InformantVendor={checked=true}, InformantEnable={checked=true}},
				difficulty=2,
			},
			{
				id=_INFORMANT['ShowVendorSell'],
				type=K_TEXT,
				text=_INFORMANT['GuiVendorSell'],
				helptext=_INFORMANT['HelpVendorSell'],
				callback=function(state)
					if (state.checked) then
						genVarSet(_INFORMANT['ShowVendorSell'], _INFORMANT['CmdOn'])
					else
						genVarSet(_INFORMANT['ShowVendorSell'], _INFORMANT['CmdOff'])
					end
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
				dependencies={InformantVendor={checked=true}, InformantEnable={checked=true}},
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
				id=_INFORMANT['CmdEmbed'],
				type=K_TEXT,
				text=_INFORMANT['GuiEmbed'],
				helptext=_INFORMANT['HelpEmbed'],
				callback=function(state)
					if (state.checked) then
						genVarSet(_INFORMANT['CmdEmbed'], _INFORMANT['CmdOn'])
					else
						genVarSet(_INFORMANT['CmdEmbed'], _INFORMANT['CmdOff'])
					end
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
				dependencies={InformantEnable={checked=true}},
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


function chatPrint(msg)
	if (DEFAULT_CHAT_FRAME) then 
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 0.25, 1.0);
	end
end

function getLocale()
	local locale = Informant.GetFilterVal('locale');
	if (locale ~= 'on') and (locale ~= 'off') and (locale ~= 'default') then
		return locale;
	end
	return GetLocale();
end