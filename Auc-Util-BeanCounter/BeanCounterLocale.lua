local libName = "BeanCounter"
local libType = "Util"
local lib = AucAdvanced.Modules[libType][libName]
local private = lib.Private

local print = AucAdvanced.Print


local Babylonian = LibStub("Babylonian")
assert(Babylonian, "Babylonian is not installed")

local babylonian = Babylonian(BeanCounterLocalizations)

BeanCounter_CustomLocalizations = {
	['MailAllianceAuctionHouse'] = GetLocale(),
	['MailAuctionCancelledSubject'] = GetLocale(),
	['MailAuctionExpiredSubject'] = GetLocale(),
	['MailAuctionSuccessfulSubject'] = GetLocale(),
	['MailAuctionWonSubject'] = GetLocale(),
	['MailHordeAuctionHouse'] = GetLocale(),
	['MailOutbidOnSubject'] = GetLocale(),
}

function _BC(stringKey, locale)
	if (locale) then
		if (type(locale) == "string") then
			return babylonian(locale, stringKey);
		else
			return babylonian(GetLocale(), stringKey);
		end
	elseif (BeanCounter_CustomLocalizations[stringKey]) then
		return babylonian(BeanCounter_CustomLocalizations[stringKey], stringKey)
	else
		return babylonian[stringKey] or stringKey
	end
end

