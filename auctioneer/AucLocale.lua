--[[

	Localization routines
	$Id$
	Version: <%version%>

]]

Auctioneer_CustomLocalizations = {
	['TextGeneral'] = GetLocale(),
	['TextCombat'] = GetLocale(),
}

function _AUCT(stringKey, locale)
	if (locale) then
		if (type(locale) == "string") then
			return Babylonian.FetchString(AuctioneerLocalizations, locale, stringKey);
		else
			return Babylonian.FetchString(AuctioneerLocalizations, GetLocale(), stringKey);
		end
	elseif (Auctioneer_CustomLocalizations[stringKey]) then
		return Babylonian.FetchString(AuctioneerLocalizations, Auctioneer_CustomLocalizations[stringKey])
	else
		return Babylonian.GetString(AuctioneerLocalizations, stringKey)
	end
end

