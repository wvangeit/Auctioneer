--[[

	Localization routines
	$Id$
	Version: <%version%>

]]

Enchantrix_CustomLocalizations = {
	['TextGeneral'] = GetLocale(),
	['TextCombat'] = GetLocale(),
}

function _ENCH(stringKey, locale)
	if (locale) then
		if (type(locale) == "string") then
			return Babylonian.FetchString(EnchantrixLocalizations, locale, stringKey);
		else
			return Babylonian.FetchString(EnchantrixLocalizations, GetLocale(), stringKey);
		end
	elseif (Enchantrix_CustomLocalizations[stringKey]) then
		return Babylonian.FetchString(EnchantrixLocalizations, Enchantrix_CustomLocalizations[stringKey], stringKey)
	else
		return Babylonian.GetString(EnchantrixLocalizations, stringKey)
	end
end

