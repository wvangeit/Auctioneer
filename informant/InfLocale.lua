--[[

	Localization routines
	$Id$
	Version: <%version%>

]]

Informant_CustomLocalizations = {
}

function _INFM(stringKey, locale)
	if (locale) then
		if (type(locale) == "string") then
			return Babylonian.FetchString(InformantLocalizations, locale, stringKey);
		else
			return Babylonian.FetchString(InformantLocalizations, GetLocale(), stringKey);
		end
	elseif (Informant_CustomLocalizations[stringKey]) then
		return Babylonian.FetchString(InformantLocalizations, Informant_CustomLocalizations[stringKey])
	else
		return Babylonian.GetString(InformantLocalizations, stringKey)
	end
end

