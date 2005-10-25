--[[
	Enchantrix Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	General utility functions and localization helper functions
--]]

-- Convert a single key in a table of configuration settings
local function convertConfig(t, key, values, ...)
	local v = nil;
	
	for i,localizedKey in ipairs(arg) do
		if (t[localizedKey] ~= nil) then
			v = t[localizedKey];
			t[localizedKey] = nil;
		end
	end
	if (t[key] ~= nil) then v = t[key]; end
	
	if (v ~= nil) then
		if (values[v] ~= nil) then
			t[key] = values[v];
		else
			t[key] = v;
		end
	end
end

-- Convert Enchantrix filters to standardized keys and values
function Enchantrix_ConvertFilters()
	-- Abort if there's nothing to convert
	if (not EnchantConfig or not EnchantConfig.filters) then return; end

	-- Array that maps localized versions of strings to standardized
	local convertOnOff = {	['apagado'] = 'off',	-- esES
							['prendido'] = 'on',	-- esES
							}
	
	local localeConvMap = { ['apagado'] = 'default',
							['prendido'] = 'default',
							['off'] = 'default',
							['on'] = 'default',
							}
	
	-- Format: standardizedKey,		valueMap,		localizedKey,			localizedKey			...
	local conversions = {
			{ 'all',				convertOnOff },
			{ 'embed',				convertOnOff,	'integrar' },
			{ 'header',				convertOnOff,	'titulo' },
			{ 'counts',				convertOnOff,	'conteo' },
			{ 'rates',				convertOnOff,	'razones' },
			{ 'valuate',			convertOnOff,	'valorizar' },
			{ 'valuate-hsp',		convertOnOff,	'valorizar-pmv' },
			{ 'valuate-median',		convertOnOff,	'valorizar-mediano' },
			{ 'valuate-baseline',	convertOnOff,	'valorizar-referencia' },
			{ 'locale',				localeConvMap },
		}
		
	-- Run the defined conversions
	for i,c in ipairs(conversions) do
		table.insert(c, 1, EnchantConfig.filters)
		convertConfig(unpack(c))
	end
end

function Enchantrix_SetFilterDefaults()
	if (not EnchantConfig) then EnchantConfig = {}; end
	if (not EnchantConfig.filters) then EnchantConfig.filters = {}; end
	
	for k,v in pairs(Enchantrix_FilterDefaults) do
		if (EnchantConfig.filters[k] == nil) then
			EnchantConfig.filters[k] = v;
		end
	end
end

--------------------------------------
--		Localization functions		--
--------------------------------------

Enchantrix_CommandMap = nil;
Enchantrix_CommandMapRev = nil;

function Enchantrix_GetLocale()
	local locale = Enchantrix_GetFilterVal('locale');
	if (locale ~= 'default') then
		return locale;
	end
	return GetLocale();
end

function Enchantrix_GetLocalizedCmdString(value)
	return getglobal("ENCH_CMD_" .. string.upper(value))
end

function Enchantrix_DelocalizeFilterVal(value)
	if (value == ENCH_CMD_ON) then
		return 'on';
	elseif (value == ENCH_CMD_OFF) then
		return 'off';
	elseif (value == ENCH_CMD_DEFAULT) then
		return 'default';
	elseif (value == ENCH_CMD_TOGGLE) then
		return 'toggle';
	else
		return value;
	end	
end

function Enchantrix_LocalizeFilterVal(value)
	if (value == 'on' or value == 'off' or value == 'default') then
		return Enchantrix_GetLocalizedCmdString(value)
	else
		return value;
	end
end

function Enchantrix_GetLocalizedFilterVal(key)
	return Enchantrix_LocalizeFilterVal(Enchantrix_GetFilterVal(key))
end


-- Turns a localized slash command into the generic English version of the command
function Enchantrix_DelocalizeCommand(cmd)
	if (not Enchantrix_CommandMap) then Enchantrix_BuildCommandMap();end
	local result = Enchantrix_CommandMap[cmd];
	if (result) then return result; else return cmd; end
end

-- Translate a generic English slash command to the localized version, if available
function Enchantrix_LocalizeCommand(cmd)
	if (not Enchantrix_CommandMap) then	Enchantrix_BuildCommandMap(); end
	local result = Enchantrix_CommandMapRev[cmd];
	if (result) then return result; else return cmd; end
end