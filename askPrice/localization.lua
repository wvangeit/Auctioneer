
-- DEFAULT_CHAT_FRAME:AddMessage("LLLLLLLLLLLLLOOOOOOOOOOOCCCCCCCCCCCC");

if (LOCALE_deDE) then

	ASKPRICE_LOADED_TEXT = "Mok's askPrice geladen. ";
	ASKPRICE_NEVER_SEEN = "Niemals als Auktion gesehen.";
	ASKPRICE_TIMES_SEEN = "x in einer Auktion gesehen.";
	ASKPRICE_BUYOUT_MEDIAN_HISTORICAL = "Sofortkauf-Median historisch: ";
	ASKPRICE_BUYOUT_LASTSCAN = "Sofortkauf-Median letzter Scan: ";
  ASKPRICE_VENDORPRICE = "Verkauf an NPC: "

	ASKPRICE_WHISPERLANGUAGE_HORDE = "Orcisch";
	ASKPRICE_WHISPERLANGUAGE_ALLIANCE = "Gemeinsprache";

	ASKPRICE_HELP_TEXT = "askPrice Optionen:\n help: Zeigt diese Nachricht ";
	ASKPRICE_HELP_VENDOR = " vendor: Schaltet NPC-Preis-Anzeige ein/aus ";
	ASKPRICE_HELP_PARTY = " party: Abfrage im Gruppenchat ein/aus ";
	ASKPRICE_HELP_GUILD = " guild: Abfrage im Gildenchat ein/aus ";
	ASKPRICE_HELP_SMART = " smart: Abfrage mit SmartWords ein/aus ";
	ASKPRICE_HELP_AD = " ad: Anzeige neuer Funktionen ein/aus ";

	ASKPRICE_AUCT_NOT_LOADED = "Auctioneer ist nicht geladen, sry.";
	ASKPRICE_ON = "ein";
	ASKPRICE_OFF = "aus";

	ASKPRICE_PARTY = "Abfrage in Gruppenchat: ";
	ASKPRICE_GUILD = "Abfrage in Gildenchat: ";

	ASKPRICE_SMARTWORD1 = "was";
	ASKPRICE_SMARTWORD2 = "wert";
	ASKPRICE_EACH = " je";
	ASKPRICE_AD = "Abfrage von Stacks: \?x\[ItemLink\] \(x = Anzahl\)";

elseif (LOCALE_enGB or LOCALE_enUS) then

	ASKPRICE_LOADED_TEXT = "Mok's askPrice loaded. ";
	ASKPRICE_NEVER_SEEN = "Never seen at auction.";
	ASKPRICE_TIMES_SEEN = "x seen at auction total.";
	ASKPRICE_BUYOUT_MEDIAN_HISTORICAL = "Buyout-median historical: ";
	ASKPRICE_BUYOUT_LASTSCAN = "Buyout-median last scan: ";
  ASKPRICE_VENDORPRICE = "Sell to Vendor: "

	ASKPRICE_WHISPERLANGUAGE_HORDE = "Orcish";
	ASKPRICE_WHISPERLANGUAGE_ALLIANCE = "Common";

	ASKPRICE_HELP_TEXT = "askPrice options:\n help: Shows this text ";
	ASKPRICE_HELP_VENDOR = " vendor: Toggles vendor-price display ";
	ASKPRICE_HELP_PARTY = " party: Toggles queries in partychat ";
	ASKPRICE_HELP_GUILD = " guild: Toggles queries in guildchat ";
	ASKPRICE_HELP_SMART = " smart: Toggles SmartWord check ";
	ASKPRICE_HELP_AD = " ad: Toggles new features Ad ";

	ASKPRICE_AUCT_NOT_LOADED = "Auctioneer not loaded, sry.";
	ASKPRICE_ON = "on";
	ASKPRICE_OFF = "off";

	ASKPRICE_PARTY = "Query in party chat: ";
	ASKPRICE_GUILD = "Query in guild chat: ";

	ASKPRICE_SMARTWORD1 = "what";
	ASKPRICE_SMARTWORD2 = "worth";
	ASKPRICE_EACH = " each";
	ASKPRICE_AD = "Get stack prices with \?x\[ItemLink\] \(x = stacksize\)";

end