--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	Auctioneer command functions.
	Functions to allow setting of values, switching commands etc.
]]


-- GUI Init Variables (Added by MentalPower)
Auctioneer_GUI_Registered = nil;
Auctioneer_Khaos_Registered = nil;


function Auctioneer_Register()
	if (Khaos) then
		if (not Auctioneer_Khaos_Registered) then
			Auctioneer_GUI_Registered = Auctioneer_Register_Khaos();
		end
	end

	return Auctioneer_GUI_Registered;
end

-- Convert a single key in a table of configuration settings
local function convertConfig(t, key, values, ...)
	local modified = false;
	local v = nil;

	for i,localizedKey in ipairs(arg) do
		if (t[localizedKey] ~= nil) then
			v = t[localizedKey];
			t[localizedKey] = nil;
			modified = true;
		end
	end
	if (t[key] ~= nil) then v = t[key]; end

	if (v ~= nil) then
		if (values[v] ~= nil) then
			t[key] = values[v];
			modified = true;
		else
			t[key] = v;
		end
	end

	return modified;
end

-- Convert Khaos options to standardized keys and values
function Auctioneer_Convert_Khaos()
	-- Array that maps localized versions of strings to standardized
	local convertOnOff = {	['apagado'] = 'off',	-- esES
							['prendido'] = 'on',	-- esES
							}

	local localeConvMap = { ['apagado'] = 'default',
							['prendido'] = 'default',
							['off'] = 'default',
							['on'] = 'default',
							}

	-- Format: standardizedKey,			valueMap,		esES,						localizedKey
	local conversions = {
			-- Localized stuff to get rid of
			{ 'show-warning',			convertOnOff,	'ver-advertencia' },
			{ 'show-verbose',			convertOnOff,	'ver-literal' },
			{ 'show-stats',				convertOnOff,	'ver-estadisticas'},
			{ 'show-average',			convertOnOff,	'ver-promedio' },
			{ 'show-median',			convertOnOff,	'ver-mediano' },
			{ 'show-suggest',			convertOnOff,	'ver-sugerencia' },
			{ 'embed',					convertOnOff,	'integrado' },
			{ 'show-embed-blankline',	convertOnOff,	'ver-integrado-lineavacia' },
			{ 'pct-bidmarkdown',		convertOnOff,	'pct-menosoferta' },
			{ 'pct-markup',				convertOnOff,	'pct-mas' },
			{ 'pct-maxless',			convertOnOff,	'pct-sinmaximo' },
			{ 'pct-nocomp',				convertOnOff,	'pct-sincomp' },
			{ 'pct-underlow',			convertOnOff,	'pct-bajomenor' },
			{ 'pct-undermkt',			convertOnOff,	'pct-bajomercado' },
			{ 'autofill',				convertOnOff,	'autoinsertar' },
			{ 'show-link',				convertOnOff,	'ver-enlace' },

			-- Changed key names
			{ 'locale',					convertOnOff,	'AuctioneerLocale' },
			{ 'printframe',				convertOnOff,	'AuctioneerPrintFrame' },
			{ 'also',					convertOnOff,	'AuctioneerInclude' },
			{ 'enabled',				convertOnOff,	'AuctioneerEnable' },
		}
		
	-- Prepend placeholder for the table parameter
	for i,c in ipairs(conversions) do
		table.insert(c, 1, nil)
	end			

	for i,config in ipairs(Khaos_Configurations) do
		if (not config.configuration or not config.configuration.Auctioneer) then break; end

		local converted = false;
		-- Run the defined conversions
		for i,c in ipairs(conversions) do
			-- Replace first parameter with actual table to process
			-- Inserting here will cause problems for the second iteration
			c[1] = config.configuration.Auctioneer
			converted = convertConfig(unpack(c)) or converted
		end

		if (converted) then
			Auctioneer_ChatPrint("Converted old Khaos configuration \"" .. config.name .. "\"")
		end
	end
end

function Auctioneer_GetKhaosDefault(filter)
	if (Auctioneer_FilterDefaults[filter] == 'on') then
		return true;
	elseif (Auctioneer_FilterDefaults[filter] == 'off') then
		return false;
	else
		return Auctioneer_FilterDefaults[filter]
	end
end

function Auctioneer_Register_Khaos()

	-- Convert old Khaos settings to current optionSet
	Auctioneer_Convert_Khaos();
	
	local optionSet = {
		id="Auctioneer";
		text="Auctioneer";
		helptext=_AUCT['GuiMainHelp'];
		difficulty=1;
		default={checked=true};
		options={
			{
				id="Header";
				text="Auctioneer";
				helptext=_AUCT['GuiMainHelp'];
				type=K_HEADER;
				difficulty=1;
			};
			{
				id="enabled";
				type=K_TEXT;
				text=_AUCT['GuiMainEnable'];
				helptext=_AUCT['HelpOnoff'];
				callback=function(state)
					if (state.checked) then
						Auctioneer_OnOff(_AUCT['CmdOn']);
					else
						Auctioneer_OnOff(_AUCT['CmdOff']);
					end
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT['StatOn'];
					else
						return _AUCT['StatOff'];
					end
				end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				difficulty=1;
			};
			{
				id="locale";
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=_AUCT['GuiLocale'];
				helptext=_AUCT['HelpLocale'];
				callback = function(state)
					Auctioneer_SetLocale(state.value);
				end;
				feedback = function (state)
					return string.format(_AUCT['FrmtActSet'], _AUCT['CmdLocale'], state.value);
				end;
				default = {
					value = Auctioneer_GetLocale();
				};
				disabled = {
					value = Auctioneer_GetLocale();
				};
				dependencies={enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="ReloadUI";
				type=K_BUTTON;
				setup={
					buttonText = _AUCT['GuiReloaduiButton'];
				};
				text=_AUCT['GuiReloadui'];
				helptext=_AUCT['GuiReloaduiHelp'];
				callback=function()
					ReloadUI();
				end;
				feedback=function()
					return _AUCT['GuiReloaduiFeedback'];
				end;
				difficulty=3;
			};
			{
				id="show-warning";
				type=K_TEXT;
				text=_AUCT['GuiRedo'];
				helptext=_AUCT['HelpRedo'];
				callback=function(state)
					Auctioneer_GenVarSet("show-warning", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(_AUCT['FrmtActEnable'], _AUCT['ShowRedo']));
					else
						return (string.format(_AUCT['FrmtActDisable'], _AUCT['ShowRedo']));
					end
				end;
				check=true;
				default={checked=Auctioneer_GetKhaosDefault('show-warning')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=1;
			};
			{
				id="protect-window";
				type=K_PULLDOWN;
				setup = {
					options = {
						[_AUCT['CmdProtectWindow0']] = 0,
						[_AUCT['CmdProtectWindow1']] = 1,
						[_AUCT['CmdProtectWindow2']] = 2 };
					multiSelect = false;
				};
				text=_AUCT['GuiProtectWindow'];
				helptext=_AUCT['HelpProtectWindow'];
				callback=function(state)
					Auctioneer_CmdProtectWindow(state.value);
				end;
				feedback=function(state)
					return string.format(_AUCT['FrmtProtectWindow'], _AUCT['CmdProtectWindow'..Auctioneer_GetFilterVal('protect-window')]);
				end;
				default = { value = _AUCT['CmdProtectWindow'..Auctioneer_FilterDefaults['protect-window']] };
				disabled = { value = _AUCT['CmdProtectWindow'..Auctioneer_FilterDefaults['protect-window']] };
				dependencies={enabled={checked=true;}};
				difficulty=3;
			};			
			{
				id="show-verbose";
				type=K_TEXT;
				text=_AUCT['GuiVerbose'];
				helptext=_AUCT['HelpVerbose'];
				callback=function(state)
					Auctioneer_GenVarSet("show-verbose", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(_AUCT['FrmtActEnable'], _AUCT['ShowVerbose']));
					else
						return (string.format(_AUCT['FrmtActDisable'], _AUCT['ShowVerbose']));
					end
				end;
				check=true;
				default={checked=Auctioneer_GetKhaosDefault('show-verbose')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=1;
			};
			{
				id="AuctioneerStatsHeader";
				type=K_HEADER;
				text=_AUCT['GuiStatsHeader'];
				helptext=_AUCT['GuiStatsHelp'];
				difficulty=2;
			};
			{
				id="show-stats";
				type=K_TEXT;
				text=_AUCT['GuiStatsEnable'];
				helptext=_AUCT['HelpStats'];
				callback=function(state)
					Auctioneer_GenVarSet("show-stats", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(_AUCT['FrmtActEnable'], _AUCT['ShowStats']));
					else
						return (string.format(_AUCT['FrmtActDisable'], _AUCT['ShowStats']));
					end
				end;
				check=true;
				default={checked=Auctioneer_GetKhaosDefault('show-stats')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=1;
			};
			{
				id="show-average";
				type=K_TEXT;
				text=_AUCT['GuiAverages'];
				helptext=_AUCT['HelpAverage'];
				callback=function(state)
					Auctioneer_GenVarSet("show-average", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(_AUCT['FrmtActEnable'], _AUCT['ShowAverage']));
					else
						return (string.format(_AUCT['FrmtActDisable'], _AUCT['ShowAverage']));
					end
				end;
				check=true;
				default={checked=Auctioneer_GetKhaosDefault('show-average')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="show-median";
				type=K_TEXT;
				text=_AUCT['GuiMedian'];
				helptext=_AUCT['HelpMedian'];
				callback=function(state)
					Auctioneer_GenVarSet("show-median", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(_AUCT['FrmtActEnable'], _AUCT['ShowMedian']));
					else
						return (string.format(_AUCT['FrmtActDisable'], _AUCT['ShowMedian']));
					end
				end;
				check=true;
				default={checked=Auctioneer_GetKhaosDefault('show-median')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="show-suggest";
				type=K_TEXT;
				text=_AUCT['GuiSuggest'];
				helptext=_AUCT['HelpSuggest'];
				callback=function(state)
					Auctioneer_GenVarSet("show-suggest", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(_AUCT['FrmtActEnable'], _AUCT['ShowSuggest']));
					else
						return (string.format(_AUCT['FrmtActDisable'], _AUCT['ShowSuggest']));
					end
				end;
				check=true;
				default={checked=Auctioneer_GetKhaosDefault('show-suggest')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="AuctioneerEmbedHeader";
				type=K_HEADER;
				text=_AUCT['GuiEmbedHeader'];
				helptext=_AUCT['HelpEmbed'];
				difficulty=1;
			};
			{
				id="embed";
				type=K_TEXT;
				text=_AUCT['GuiEmbed'];
				helptext=_AUCT['HelpEmbed'];
				callback=function(state)
					Auctioneer_GenVarSet("embed", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(_AUCT['FrmtActEnable'], _AUCT['CmdEmbed']));
					else
						return (string.format(_AUCT['FrmtActDisable'], _AUCT['CmdEmbed']));
					end
				end;
				check=true;
				default={checked=Auctioneer_GetKhaosDefault('embed')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=1;
			};
			{
				id="show-embed-blankline";
				type=K_TEXT;
				text=_AUCT['GuiEmbedBlankline'];
				helptext=_AUCT['HelpEmbedBlank'];
				callback=function(state)
					Auctioneer_GenVarSet("show-embed-blankline", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(_AUCT['FrmtActEnable'], _AUCT['ShowEmbedBlank']));
					else
						return (string.format(_AUCT['FrmtActDisable'], _AUCT['ShowEmbedBlank']));
					end
				end;
				check=true;
				default={checked=Auctioneer_GetKhaosDefault('show-embed-blankline')};
				disabled={checked=false};
				dependencies={embed={checked=true;}, enabled={checked=true;}};
				difficulty=1;
			};
			{
				id="AuctioneerClearHeader";
				type=K_HEADER;
				text=_AUCT['GuiClearHeader'];
				helptext=_AUCT['GuiClearHelp'];
				difficulty=3;
			};
			{
				id="AuctioneerClearAll";
				type=K_BUTTON;
				setup={
					buttonText = _AUCT['GuiClearallButton'];
				};
				text=_AUCT['GuiClearall'];
				helptext=_AUCT['GuiClearallHelp'];
				callback=function()
					Auctioneer_Clear("all");
				end;
				feedback=function()
					return string.format(_AUCT['FrmtActClearall'],  _AUCT['GuiClearallNote']);
				end;
				dependencies={enabled={checked=true;}};
				difficulty=3;
			};
			{
				id="AuctioneerClearSnapshot";
				type=K_BUTTON;
				setup={
					buttonText=_AUCT['GuiClearsnapButton'];
				};
				text=_AUCT['GuiClearsnap'];
				helptext=_AUCT['GuiClearsnapHelp'];
				callback=function()
					Auctioneer_Clear(_AUCT['CmdClearSnapshot']);
				end;
				feedback=function()
					return _AUCT['FrmtActClearsnap'];
				end;
				dependencies={enabled={checked=true;}};
				difficulty=3;
			};
			{
				id="AuctioneerPercentsHeader";
				type=K_HEADER;
				text=_AUCT['GuiPercentsHeader'];
				helptext=_AUCT['GuiPercentsHelp'];
				difficulty=4;
			};
			{
				id="pct-bidmarkdown";
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=_AUCT['GuiBidmarkdown'];
				helptext=_AUCT['HelpPctBidmarkdown'];
				callback = function(state)
					Auctioneer_PercentVarSet("pct-bidmarkdown", state.value);
				end;
				feedback = function (state)
					return string.format(_AUCT['FrmtActSet'], _AUCT['CmdPctBidmarkdown'], state.value.."%");
				end;
				default = {	value = Auctioneer_GetKhaosDefault('pct-bidmarkdown') };
				disabled = { value = Auctioneer_GetKhaosDefault('pct-bidmarkdown') };
				dependencies={enabled={checked=true;}};
				difficulty=4;
			};
			{
				id="pct-markup";
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=_AUCT['GuiMarkup'];
				helptext=_AUCT['HelpPctMarkup'];
				callback = function(state)
					Auctioneer_PercentVarSet("pct-markup", state.value);
				end;
				feedback = function (state)
					return string.format(_AUCT['FrmtActSet'], _AUCT['CmdPctMarkup'], state.value.."%");
				end;
				default = {	value = Auctioneer_GetKhaosDefault('pct-markup') };
				disabled = { value = Auctioneer_GetKhaosDefault('pct-markup') };
				dependencies={enabled={checked=true;}};
				difficulty=4;
			};
			{
				id="pct-maxless";
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=_AUCT['GuiMaxless'];
				helptext=_AUCT['HelpPctMaxless'];
				callback = function(state)
					Auctioneer_PercentVarSet("pct-maxless", state.value);
				end;
				feedback = function (state)
					return string.format(_AUCT['FrmtActSet'], _AUCT['CmdPctMaxless'], state.value.."%");
				end;
				default = {	value = Auctioneer_GetKhaosDefault('pct-maxless') };
				disabled = { value = Auctioneer_GetKhaosDefault('pct-maxless') };
				dependencies={enabled={checked=true;}};
				difficulty=4;
			};
			{
				id="pct-nocomp";
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=_AUCT['GuiNocomp'];
				helptext=_AUCT['HelpPctNocomp'];
				callback = function(state)
					Auctioneer_PercentVarSet("pct-nocomp", state.value);
				end;
				feedback = function (state)
					return string.format(_AUCT['FrmtActSet'], _AUCT['CmdPctNocomp'], state.value.."%");
				end;
				default = {	value = Auctioneer_GetKhaosDefault('pct-nocomp') };
				disabled = { value = Auctioneer_GetKhaosDefault('pct-nocomp') };
				dependencies={enabled={checked=true;}};
				difficulty=4;
			};
			{
				id="pct-underlow";
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=_AUCT['GuiUnderlow'];
				helptext=_AUCT['HelpPctUnderlow'];
				callback = function(state)
					Auctioneer_PercentVarSet("pct-underlow", state.value);
				end;
				feedback = function (state)
					return string.format(_AUCT['FrmtActSet'], _AUCT['CmdPctUnderlow'], state.value.."%");
				end;
				default = {	value = Auctioneer_GetKhaosDefault('pct-underlow') };
				disabled = { value = Auctioneer_GetKhaosDefault('pct-underlow') };
				dependencies={enabled={checked=true;}};
				difficulty=4;
			};
			{
				id="pct-undermkt";
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=_AUCT['GuiUndermkt'];
				helptext=_AUCT['HelpPctUndermkt'];
				callback = function(state)
					Auctioneer_PercentVarSet("pct-undermkt", state.value);
				end;
				feedback = function (state)
					return string.format(_AUCT['FrmtActSet'], _AUCT['CmdPctUndermkt'], state.value.."%");
				end;
				default = {	value = Auctioneer_GetKhaosDefault('pct-undermkt') };
				disabled = { value = Auctioneer_GetKhaosDefault('pct-undermkt') };
				dependencies={enabled={checked=true;}};
				difficulty=4;
			};
			{
				id="AuctioneerOtherHeader";
				type=K_HEADER;
				text=_AUCT['GuiOtherHeader'];
				helptext=_AUCT['GuiOtherHelp'];
				difficulty=1;
			};
			{
				id="autofill";
				type=K_TEXT;
				text=_AUCT['GuiAutofill'];
				helptext=_AUCT['HelpAutofill'];
				callback=function(state)
					Auctioneer_GenVarSet("autofill", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(_AUCT['FrmtActEnable'], _AUCT['CmdAutofill']));
					else
						return (string.format(_AUCT['FrmtActDisable'], _AUCT['CmdAutofill']));
					end
				end;
				check=true;
				default={checked=Auctioneer_GetKhaosDefault('autofill')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=1;
			};
			{
				id="also";
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=_AUCT['GuiAlso'];
				helptext=_AUCT['HelpAlso'];
				callback = function(state)
					Auctioneer_AlsoInclude(state.value);
				end;
				feedback = function (state)
					if (state.value == _AUCT['CmdAlsoOpposite']) then
						return _AUCT['GuiAlsoOpposite'];
					elseif (state.value == _AUCT['CmdOff']) then
						return _AUCT['GuiAlsoOff'];
					elseif (not Auctioneer_IsValidAlso(param)) then
						string.format(_AUCT['FrmtUnknownRf'], state.value)
					else
						return string.format(_AUCT['GuiAlsoDisplay'], state.value);
					end
				end;
				default = { value = Auctioneer_GetKhaosDefault('also') };
				disabled = { value = Auctioneer_GetKhaosDefault('also') };
				dependencies={enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="DefaultAll";
				type=K_BUTTON;
				setup={
					buttonText = _AUCT['GuiDefaultAllButton'];
				};
				text=_AUCT['GuiDefaultAll'];
				helptext=_AUCT['GuiDefaultAllHelp'];
				callback=function()
					Auctioneer_Default(_AUCT['CmdClearAll']);
				end;
				feedback=function()
					return _AUCT['FrmtActDefaultall'];
				end;
				dependencies={enabled={checked=true;}};
				difficulty=1;
			};
			{
				id="DefaultOption";
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=_AUCT['GuiDefaultOption'];
				helptext=_AUCT['HelpDefault'];
				callback = function(state)
					Auctioneer_Default(state.value);
				end;
				feedback = function (state)
					if (state.value == _AUCT['CmdClearAll']) then
						return _AUCT['FrmtActDefaultall'];
					else
						return string.format(_AUCT['FrmtActDefault'], state.value);
					end
				end;
				default = {
					value = "";
				};
				disabled = {
					value = "";
				};
				dependencies={enabled={checked=true;}};
				difficulty=4;
			};
			{
				id="printframe";
				type=K_PULLDOWN;
				setup = {
					options = Auctioneer_GetFrameNames();
					multiSelect = false;
				};
				text=_AUCT['GuiPrintin'];
				helptext=_AUCT['HelpPrintin'];
				callback=function(state)
					Auctioneer_SetFrame(state.value);
				end;
				feedback=function(state)
					local _, frameName = Auctioneer_GetFrameNames(state.value)
					return string.format(_AUCT['FrmtPrintin'], frameName);
				end;
				default = { value = Auctioneer_GetKhaosDefault('printframe') };
				disabled = { value = Auctioneer_GetKhaosDefault('printframe') };
				dependencies={enabled={checked=true;}};
				difficulty=3;
			};
			{
				id="show-link";
				type=K_TEXT;
				text=_AUCT['GuiLink'];
				helptext=_AUCT['HelpLink'];
				callback=function(state)
					Auctioneer_GenVarSet("show-link", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return (string.format(_AUCT['FrmtActEnable'], _AUCT['ShowLink']))
					else
						return (string.format(_AUCT['FrmtActDisable'], _AUCT['ShowLink']))
					end
				end;
				check=true;
				default={Auctioneer_GetKhaosDefault('show-link')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=3;
			};
		};
	};

	Khaos.registerOptionSet("tooltip", optionSet);
	Auctioneer_Khaos_Registered = true;

	return true;
end

local function setKhaosSetKeyParameter(key, parameter, value)
	if (Auctioneer_Khaos_Registered) then
		if (Khaos.getSetKey("Auctioneer", key)) then
			Khaos.setSetKeyParameter("Auctioneer", key, parameter, value)
		else
			EnhTooltip.DebugPrint("setKhaosSetKeyParameter(): key " .. key .. " does not exist")
		end
	end
end

local function setKhaosSetKeyValue(key, value)
	if (Auctioneer_Khaos_Registered) then
		local kKey = Khaos.getSetKey("Auctioneer", key)

		if (not kKey) then
			EnhTooltip.DebugPrint("setKhaosSetKeyParameter(): key " .. key .. " does not exist")
		elseif (kKey.checked ~= nil) then
			if (type(value) == "string") then value = (value == "on"); end
			Khaos.setSetKeyParameter("Auctioneer", key, "checked", value)
		elseif (kKey.value ~= nil) then
			Khaos.setSetKeyParameter("Auctioneer", key, "value", value)
		else
			EnhTooltip.DebugPrint("setKhaosSetKeyValue(): don't know how to update key ", key)
		end
	end
end

function Auctioneer_BuildCommandMap()
	Auctioneer_CommandMap = {
			[_AUCT['CmdOn']] = 'on',
			[_AUCT['CmdOff']] = 'off',
			[_AUCT['CmdToggle']] = 'toggle',
			[_AUCT['CmdDisable']] = 'disable',
			[_AUCT['CmdClear']] = 'clear',
			[_AUCT['CmdLocale']] = 'locale',
			[_AUCT['CmdDefault']] = 'default',
			[_AUCT['CmdPrintin']] = 'print-in',
			[_AUCT['CmdAlso']] = 'also',
			[_AUCT['CmdEmbed']] = 'embed',
			[_AUCT['CmdPercentless']] = 'percentless',
			[_AUCT['CmdPercentlessShort']] = 'percentless',
			[_AUCT['CmdCompete']] = 'compete',
			[_AUCT['CmdScan']] = 'scan',
			[_AUCT['CmdAutofill']] = 'autofill',
			[_AUCT['CmdProtectWindow']] = 'protect-window',
			[_AUCT['CmdBroker']] = 'broker';
			[_AUCT['CmdBidbroker']] = 'bidbroker',
			[_AUCT['CmdBidbrokerShort']] = 'bidbroker',
			[_AUCT['CmdAuctionClick']] = 'auction-click';
			[_AUCT['CmdPctBidmarkdown']] = 'pct-bidmarkdown';
			[_AUCT['CmdPctMarkup']]      = 'pct-markup';
			[_AUCT['CmdPctMaxless']]     = 'pct-maxless';
			[_AUCT['CmdPctNocomp']]      = 'pct-nocomp';
			[_AUCT['CmdPctUnderlow']]    = 'pct-underlow';
			[_AUCT['CmdPctUndermkt']]    = 'pct-undermkt';
		}

	Auctioneer_CommandMapRev = {}
	for k,v in pairs(Auctioneer_CommandMap) do
		Auctioneer_CommandMapRev[v] = k;
	end
end

--Cleaner Command Handling Functions (added by MentalPower)
function Auctioneer_Command(command, source)

	--To print or not to print, that is the question...
	local chatprint = nil;
	if (source == "GUI") then
		chatprint = false;
	else
		chatprint = true;
	end;

	--Divide the large command into smaller logical sections (Shameless copy from the original function)
	local i,j, cmd, param = string.find(command, "^([^ ]+) (.+)$");

	if (not cmd) then cmd = command; end
	if (not cmd) then cmd = "";	end
	if (not param) then	param = ""; end
	cmd = Auctioneer_DelocalizeCommand(cmd);

	--Now for the real Command handling
	if ((cmd == "") or (cmd == "help")) then
		Auctioneer_ChatPrint_Help();
		return;
	elseif (cmd == 'on' or cmd == 'off' or cmd == 'toggle') then
		Auctioneer_OnOff(cmd, chatprint);
	elseif (cmd == 'disable') then
		Auctioneer_ChatPrint(_AUCT['DisableMsg']);
		Stubby.SetConfig("Auctioneer", "LoadType", "never");
	elseif (cmd == 'load') then
		if (param == "always") or (param == "never") or (param == "auctionhouse") then
			Auctioneer_ChatPrint("Setting Auctioneer to "..param.." load for this toon");
			Stubby.SetConfig("Auctioneer", "LoadType", param);
		end
	elseif (cmd == 'clear') then
		Auctioneer_Clear(param, chatprint);
	elseif (cmd == 'also') then
		Auctioneer_AlsoInclude(param, chatprint);
	elseif (cmd == 'locale') then
		Auctioneer_SetLocale(param, chatprint);
	elseif (cmd == 'default') then
		Auctioneer_Default(param, chatprint);
	elseif (cmd == 'print-in') then
		Auctioneer_SetFrame(param, chatprint)
	elseif (cmd == 'broker') then
		Auctioneer_DoBroker(param);
	elseif (cmd == 'bidbroker') then
		Auctioneer_DoBidBroker(param);
	elseif (cmd == 'percentless') then
		Auctioneer_DoPercentLess(param);
	elseif (cmd == 'compete') then
		Auctioneer_DoCompeting(param);
	elseif (cmd == 'scan') then
		Auctioneer_RequestAuctionScan();
	elseif (cmd == 'protect-window') then
		Auctioneer_CmdProtectWindow(param, chatprint);
	elseif (cmd == 'low') then
		Auctioneer_DoLow(param);
	elseif (cmd == 'med') then
		Auctioneer_DoMedian(param);
	elseif (cmd == 'hsp') then
		Auctioneer_DoHSP(param);
	elseif (cmd == 'embed' or cmd == 'autofill' or cmd == 'auction-click' or
			cmd == 'show-verbose' or cmd == 'show-average' or cmd == 'show-link' or
			cmd == 'show median' or cmd == 'show-stats' or cmd == 'show-suggest' or
			cmd == 'show-embed-blankline' or cmd == 'show-warning') then
		Auctioneer_GenVarSet(cmd, param, chatprint);
	elseif (cmd == 'pct-bidmarkdown' or cmd == 'pct-markup' or cmd == "pct-maxless" or
			cmd == "pct-nocomp" or cmd == "pct-underlow" or cmd == "pct-undermkt") then
		Auctioneer_PercentVarSet(cmd, param, chatprint);
	else
		if (chatprint) then
			Auctioneer_ChatPrint(string.format(_AUCT['FrmtActUnknown'], cmd));
		end
	end
end

--Help ME!! (The Handler) (Another shameless copy from the original function)
function Auctioneer_ChatPrint_Help()

	local onOffToggle = " (".._AUCT['CmdOn'].."|".._AUCT['CmdOff'].."|".._AUCT['CmdToggle']..")";
	local lineFormat = "  |cffffffff/auctioneer %s "..onOffToggle.."|r |cff2040ff[%s]|r - %s";

	Auctioneer_ChatPrint(_AUCT['TextUsage']);
	Auctioneer_ChatPrint("  |cffffffff/auctioneer "..onOffToggle.."|r |cff2040ff["..Auctioneer_GetLocalizedFilterVal("all").."]|r - " .. _AUCT['HelpOnoff']);
	Auctioneer_ChatPrint("  |cffffffff/auctioneer ".._AUCT['CmdDisable'].."|r - " .. _AUCT['HelpDisable']);

	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['ShowVerbose'], Auctioneer_GetLocalizedFilterVal('show-verbose'), _AUCT['HelpVerbose']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['ShowAverage'], Auctioneer_GetLocalizedFilterVal('show-average'), _AUCT['HelpAverage']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['ShowMedian'], Auctioneer_GetLocalizedFilterVal('show-median'), _AUCT['HelpMedian']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['ShowSuggest'], Auctioneer_GetLocalizedFilterVal('show-suggest'), _AUCT['HelpSuggest']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['ShowStats'], Auctioneer_GetLocalizedFilterVal('show-stats'), _AUCT['HelpStats']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['ShowLink'], Auctioneer_GetLocalizedFilterVal('show-link'), _AUCT['HelpLink']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdAutofill'], Auctioneer_GetLocalizedFilterVal('autofill'), _AUCT['HelpAutofill']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdEmbed'], Auctioneer_GetLocalizedFilterVal('embed'), _AUCT['HelpEmbed']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['ShowEmbedBlank'], Auctioneer_GetLocalizedFilterVal('show-embed-blankline'), _AUCT['HelpEmbedBlank']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['ShowRedo'], Auctioneer_GetLocalizedFilterVal('show-warning'), _AUCT['HelpRedo']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdAuctionClick'], Auctioneer_GetLocalizedFilterVal('auction-click'), _AUCT['HelpAuctionClick']));

	lineFormat = "  |cffffffff/auctioneer %s %s|r |cff2040ff[%s]|r - %s";
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdProtectWindow'], _AUCT['OptProtectWindow'], _AUCT['CmdProtectWindow'..Auctioneer_GetFilterVal('protect-window')], _AUCT['HelpProtectWindow']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdLocale'], _AUCT['OptLocale'], Auctioneer_GetLocalizedFilterVal("locale"), _AUCT['HelpLocale']));

	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdPctMarkup'], _AUCT['OptPctMarkup'], Auctioneer_GetFilterVal('pct-markup'), _AUCT['HelpPctMarkup']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdPctBidmarkdown'], _AUCT['OptPctBidmarkdown'], Auctioneer_GetFilterVal('pct-bidmarkdown'), _AUCT['HelpPctBidmarkdown']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdPctNocomp'], _AUCT['OptPctNocomp'], Auctioneer_GetFilterVal('pct-nocomp'), _AUCT['HelpPctNocomp']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdPctUnderlow'], _AUCT['OptPctUnderlow'], Auctioneer_GetFilterVal('pct-underlow'), _AUCT['HelpPctUnderlow']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdPctUndermkt'], _AUCT['OptPctUndermkt'], Auctioneer_GetFilterVal('pct-undermkt'), _AUCT['HelpPctUndermkt']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdPctMaxless'], _AUCT['OptPctMaxless'], Auctioneer_GetFilterVal('pct-maxless'), _AUCT['HelpPctMaxless']));

	lineFormat = "  |cffffffff/auctioneer %s %s|r - %s";
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdClear'], _AUCT['OptClear'], _AUCT['HelpClear']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdAlso'], _AUCT['OptAlso'], _AUCT['HelpAlso']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdBroker'], _AUCT['OptBroker'], _AUCT['HelpBroker']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdBidbroker'], _AUCT['OptBidbroker'], _AUCT['HelpBidbroker']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdPercentless'], _AUCT['OptPercentless'], _AUCT['HelpPercentless']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdCompete'], _AUCT['OptCompete'], _AUCT['HelpCompete']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdScan'], _AUCT['OptScan'], _AUCT['HelpScan']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdDefault'], _AUCT['OptDefault'], _AUCT['HelpDefault']));
	Auctioneer_ChatPrint(string.format(lineFormat, _AUCT['CmdPrintin'], _AUCT['OptPrintin'], _AUCT['HelpPrintin']));

end

--The Auctioneer_OnOff(state, chatprint) function handles the state of the Auctioneer AddOn (whether it is currently on or off)
--If "on" or "off" is specified in the " state" variable then Auctioneer's state is changed to that value,
--If "toggle" is specified then it will toggle Auctioneer's state (if currently on then it will be turned off and vice-versa)
--
--If chatprint is "true" then the state will also be printed to the user.

function Auctioneer_OnOff(state, chatprint)
	if (state == 'on' or state == 'off') then
		Auctioneer_SetFilter('all', state);
	elseif (state == 'toggle') then
		Auctioneer_SetFilter(not Auctioneer_GetFilter(all));
	end

	--Print the change and alert the GUI if the command came from slash commands. Do nothing if they came from the GUI.
	if (chatprint) then
		state = Auctioneer_GetFilter(all)
		setKhaosSetKeyValue("enabled", state)

		if (state) then
			Auctioneer_ChatPrint(_AUCT['StatOn']);
		else
			Auctioneer_ChatPrint(_AUCT['StatOff']);
		end
	end
end

--The following functions are almost verbatim copies of the original functions but modified in order to make them compatible with direct GUI access.
function Auctioneer_Clear(param, chatprint)

	local aKey = Auctioneer_GetAuctionKey();
	local clearok = nil;

	if ((param == _AUCT['CmdClearAll']) or (param == "all")) then
		AuctionConfig.data = {};
		AuctionConfig.info = {};
		AuctionConfig.snap = {};
		AuctionConfig.sbuy = {};
	elseif ((param == _AUCT['CmdClearSnapshot']) or (param == "snapshot")) then
		AuctionConfig.snap = {};
		AuctionConfig.sbuy = {};
		lSnapshotItemPrices = {};
	else
		local items = Auctioneer_GetItems(param);
		if (items) then
			for pos,itemKey in pairs(items) do
				if (AuctionConfig.data[aKey][itemKey] ~= nil) then
					AuctionConfig.data[aKey][itemKey] = nil;

					if (AuctionConfig.stats["snapmed"][aKey][itemKey] ~= nil) then
						AuctionConfig.stats["snapmed"][aKey][itemKey] = nil;
					end

					if (AuctionConfig.stats["histmed"][aKey][itemKey] ~= nil) then
						AuctionConfig.stats["histmed"][aKey][itemKey] = nil;
					end

					if (AuctionConfig.stats["histcount"][aKey][itemKey] ~= nil) then
						AuctionConfig.stats["histcount"][aKey][itemKey] = nil;
					end

					if (AuctionConfig.stats["snapcount"][aKey][itemKey] ~= nil) then
						AuctionConfig.stats["snapcount"][aKey][itemKey] = nil;
					end

					if (AuctionConfig.sbuy[aKey][itemKey] ~= nil) then
						AuctionConfig.sbuy[aKey][itemKey] = nil;
					end

					local count = 0;
					while (AuctionConfig.snap[aKey][count] ~= nil) do
						if (AuctionConfig.snap[aKey][count][itemKey] ~= nil) then
							AuctionConfig.snap[aKey][count][itemKey] =nil;
						end
						count = count+1;
					end

					if (Auctioneer_HSPCache[aKey][itemKey] ~= nil) then
						Auctioneer_HSPCache[aKey][itemKey] = nil;
					end

					--These are not included in the print statement below because there could be the possiblity
					--that an item's data was cleared but another's was not
					if (chatprint) then
						Auctioneer_ChatPrint(string.format(_AUCT['FrmtActClearOk'], param));
					end
				else
					if (chatprint) then
						Auctioneer_ChatPrint(string.format(_AUCT['FrmtActClearFail'], param));
					end
				end
			end
		end
	end

	if (chatprint) then
		if ((param == _AUCT['CmdClearAll']) or (param == "all")) then
			Auctioneer_ChatPrint(string.format(_AUCT['FrmtActClearall'], aKey));
		elseif ((param == _AUCT['CmdClearSnapshot']) or (param == "snapshot")) then
			Auctioneer_ChatPrint(_AUCT['FrmtActClearsnap']);
		end
	end
end


function Auctioneer_AlsoInclude(param, chatprint)
	if ((param == _AUCT['CmdAlsoOpposite']) or (param == "opposite")) then
		param = "opposite";
	end

	if (not Auctioneer_IsValidAlso(param)) then
		if (chatprint) then
			Auctioneer_ChatPrint(string.format(_AUCT['FrmtUnknownRf'], param));
		end
		return
	end

	Auctioneer_SetFilter('also', param);

	if (chatprint) then
		setKhaosSetKeyValue('also', param);

		if ((param == _AUCT['CmdOff']) or (param == "off")) then
			Auctioneer_ChatPrint(string.format(_AUCT['FrmtActDisable'], _AUCT['CmdAlso']));
		else
			Auctioneer_ChatPrint(string.format(_AUCT['FrmtActSet'], _AUCT['CmdAlso'], param));
		end
	end
end


function Auctioneer_SetLocale(param, chatprint)
	local validLocale=nil;
	param = Auctioneer_DelocalizeFilterVal(param);

	if (param == Auctioneer_GetLocale()) then
		--Do Nothing
		validLocale=true;
	elseif (AUCT_VALID_LOCALES[param]) then
		Auctioneer_SetFilter('locale', param);
		Auctioneer_SetLocaleStrings(Auctioneer_GetLocale());
		Auctioneer_CommandMap = nil
		Auctioneer_CommandMapRev = nil
		validLocale=true;
	elseif ((param == '') or (param == _AUCT['CmdDefault']) or (param == 'default') or (param == _AUCT['CmdOff']) or (param == 'off')) then
		Auctioneer_SetFilter('locale', _AUCT['CmdDefault']);
		Auctioneer_SetLocaleStrings(Auctioneer_GetLocale());
		Auctioneer_CommandMap = nil
		Auctioneer_CommandMapRev = nil
		validLocale=true;
	end

	if (chatprint) then
		if (validLocale and (AUCT_VALID_LOCALES[param])) then
			Auctioneer_ChatPrint(string.format(_AUCT['FrmtActSet'], _AUCT['CmdLocale'], param));
			setKhaosSetKeyValue('locale', param);
		elseif (not validLocale) then
			Auctioneer_ChatPrint(string.format(_AUCT['FrmtUnknownLocale'], param));
			if (AUCT_VALID_LOCALES) then
				for locale, x in pairs(AUCT_VALID_LOCALES) do
					Auctioneer_ChatPrint("  "..locale);
				end
			end
		else
			Auctioneer_ChatPrint(string.format(_AUCT['FrmtActSet'], _AUCT['CmdLocale'], _AUCT['CmdDefault']));
			setKhaosSetKeyValue('locale', param);
		end
	end
end

function Auctioneer_Default(param, chatprint)
	local paramLocalized

	if ( (param == nil) or (param == "") ) then
		return
	elseif ((param == _AUCT['CmdClearAll']) or (param == "all")) then
		param = "all"
		AuctionConfig.filters = {};
	else
		paramLocalized = param
		param = Auctioneer_DelocalizeCommand(param)
		Auctioneer_SetFilter(param, nil);
	end

	Auctioneer_SetFilterDefaults();		-- Apply defaults for settings that went missing

	if (chatprint) then
		if (param == "all") then
			Auctioneer_ChatPrint(_AUCT['FrmtActDefaultall']);
			for k,v in pairs(AuctionConfig.filters) do
				setKhaosSetKeyValue(k, Auctioneer_GetFilterVal(k));
			end
		else
			Auctioneer_ChatPrint(string.format(_AUCT['FrmtActDefault'], paramLocalized));
			setKhaosSetKeyValue(param, Auctioneer_GetFilterVal(param));
		end
	end
end

--The following three functions were added by MentalPower to implement the /auc print-in command
function Auctioneer_GetFrameNames(index)

	local frames = {};
	local frameName = "";

	for i=1,10 do
		local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(i);

		if ( name == "" ) then
			if (i == 1) then
				frames[_AUCT['TextGeneral']] = 1;
			elseif (i == 2) then
				frames[_AUCT['TextCombat']] = 2;
			end
		else
			frames[name] = i;
		end
	end

	if (index) then
		local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(index);

		if ( name == "" ) then
			if (index == 1) then
				frameName = _AUCT['TextGeneral'];
			elseif (index == 2) then
				frameName = _AUCT['TextCombat'];
			end
		else
			frameName = name;
		end
	end

	return frames, frameName;
end


function Auctioneer_GetFrameIndex()
	if (not AuctionConfig.filters) then AuctionConfig.filters = {}; end
	local value = AuctionConfig.filters["printframe"];

	if (not value) then
		return 1;
	end
	return value;
end


function Auctioneer_SetFrame(frame, chatprint)
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
		allFrames = Auctioneer_GetFrameNames();
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
		_, frameName = Auctioneer_GetFrameNames(frameNumber);
		if (Auctioneer_GetFrameIndex() ~= frameNumber) then
			Auctioneer_ChatPrint(string.format(_AUCT['FrmtPrintin'], frameName));
		end
	end

	Auctioneer_SetFilter("printframe", frameNumber);

	if (chatprint == true) then
		Auctioneer_ChatPrint(string.format(_AUCT['FrmtPrintin'], frameName));

		if (Auctioneer_Khaos_Registered) then
			Khaos.setSetKeyParameter("Auctioneer", "AuctioneerPrintFrame", "value", frameNumber);
		end
	end
end

function Auctioneer_CmdProtectWindow(param, chatprint)
	local mode;
	
	if (param == 'never' or param == 'off' or param == _AUCT['CmdProtectWindow0'] or param == _AUCT['CmdOff'] or param == "0") then
		mode = 0;
	elseif (param == 'scan' or param == _AUCT['CmdProtectWindow1'] or param == "1") then
		mode = 1;
	elseif (param == 'always' or param == _AUCT['CmdProtectWindow2'] or param == "2") then
		mode = 2;
	else
		Auctioneer_ChatPrint(string.format(_AUCT['FrmtUnknownArg'], param, Auctioneer_DelocalizeCommand("protect-window")));
		return
	end
	
	Auctioneer_SetFilter("protect-window", mode);
	
	if (chatprint) then
		Auctioneer_ChatPrint(string.format(_AUCT['FrmtProtectWindow'], _AUCT['CmdProtectWindow' .. mode]));
		setKhaosSetKeyVale("protect-window", _AUCT['CmdProtectWindow' .. mode]);
	end
end

function Auctioneer_GenVarSet(variable, param, chatprint)
	if (type(param) == "string") then
		param = Auctioneer_DelocalizeFilterVal(param);
	end

	if (param == "on" or param == "off" or type(param) == "boolean") then
		Auctioneer_SetFilter(variable, param);
	elseif (param == "toggle" or param == nil or param == "") then
		param = Auctioneer_SetFilter(variable, not Auctioneer_GetFilter(variable));
	end

	if (chatprint) then
		if (Auctioneer_GetFilter(variable)) then
			Auctioneer_ChatPrint(string.format(_AUCT['FrmtActEnable'], Auctioneer_LocalizeCommand(variable)));
			setKhaosSetKeyValue(variable, true)
		else
			Auctioneer_ChatPrint(string.format(_AUCT['FrmtActDisable'], Auctioneer_LocalizeCommand(variable)));
			setKhaosSetKeyValue(variable, false)
		end
	end
end


function Auctioneer_PercentVarSet(variable, param, chatprint)
	local paramVal = tonumber(param);
	if paramVal == nil then
		-- failed to convert the param to a number
		if chatprint then
			Auctioneer_ChatPrint(string.format(_AUCT['FrmtUnknownArg'], param, variable));
		end
		return -- invalid argument, don't do anything
	end
	-- param is a valid number, save it
	Auctioneer_SetFilter(variable, paramVal);

	if (chatprint) then
		Auctioneer_ChatPrint(string.format(_AUCT['FrmtActSet'], variable, paramVal.."%"));
		setKhaosSetKeyValue(variable, paramVal);
	end
end

--This marks the end of the New Command processing code.


function Auctioneer_SetFilter(key, value)
	if (not AuctionConfig.filters) then AuctionConfig.filters = {}; end
	if (type(value) == "boolean") then
		if (value) then
			AuctionConfig.filters[key] = 'on';
		else
			AuctionConfig.filters[key] = 'off';
		end
	else
		AuctionConfig.filters[key] = value;
	end
end

function Auctioneer_GetFilterVal(type)
	if (not AuctionConfig.filters) then
		AuctionConfig.filters = {};
		Auctioneer_SetFilterDefaults();
	end
	return AuctionConfig.filters[type];
end

function Auctioneer_GetFilter(filter)
	value = Auctioneer_GetFilterVal(filter);
	if ((value == _AUCT['CmdOn']) or (value == "on")) then return true;
	elseif ((value == _AUCT['CmdOff']) or (value == "off")) then return false; end
	return true;
end



function Auctioneer_FindFilterClass(text)
	local totalFilters = getn(CLASS_FILTERS);
	for currentFilter=1, totalFilters do
		if (text == CLASS_FILTERS[currentFilter]) then
			return currentFilter, totalFilters;
		end
	end
	return 0, totalFilters;
end

function AuctFilter_SetFilter(checkbox, filter)
	checkbox.filterVal = filter;
	checkbox:SetChecked(Auctioneer_GetFilter(filter));
	checkbox:Show();
end

function Auctioneer_GetLocale()
	local locale = Auctioneer_GetFilterVal('locale');
	if (locale ~= 'on') and (locale ~= 'off') and (locale ~= 'default') then
		return locale;
	end
	return GetLocale();
end

-- execute the '/auctioneer low <itemName>' that returns the auction for an item with the lowest buyout
function Auctioneer_DoLow(link)
	local itemID, randomProp, enchant, uniqID, itemName = EnhTooltip.BreakLink(link);
	local itemKey = itemID..":"..randomProp..":"..enchant;

	local auctionSignature = Auctioneer_FindLowestAuctions(itemKey);
	if (not auctionSignature) then
		Auctioneer_ChatPrint(string.format(_AUCT['FrmtNoauct'], Auctioneer_ColorTextWhite(itemName)));
	else
		local auctKey = Auctioneer_GetAuctionKey();
		local itemCat = Auctioneer_GetCatForKey(itemKey);
		local auction = Auctioneer_GetSnapshot(auctKey, itemCat, auctionSignature);
		local x,x,x, x, count, x, buyout, x = Auctioneer_GetItemSignature(auctionSignature);
		Auctioneer_ChatPrint(string.format(_AUCT['FrmtLowLine'], Auctioneer_ColorTextWhite(count.."x")..auction.itemLink, EnhTooltip.GetTextGSC(buyout), Auctioneer_ColorTextWhite(auction.owner), EnhTooltip.GetTextGSC(buyout / count), Auctioneer_ColorTextWhite(Auctioneer_PercentLessThan(Auctioneer_GetUsableMedian(itemKey), buyout / count).."%")));
	end
end

function Auctioneer_DoHSP(link)
	local itemID, randomProp, enchant, uniqID, itemName = EnhTooltip.BreakLink(link);
	local itemKey = itemID..":"..randomProp..":"..enchant;
	local highestSellablePrice = Auctioneer_GetHSP(itemKey, Auctioneer_GetAuctionKey());
	Auctioneer_ChatPrint(string.format(_AUCT['FrmtHspLine'], Auctioneer_ColorTextWhite(itemName), EnhTooltip.GetTextGSC(nilSafeString(highestSellablePrice))));
end


