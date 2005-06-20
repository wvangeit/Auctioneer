--[[

	File containing localized strings
	Test for French or German versions, defaults to English
	Version: <%version%>
	Revision: $Id$

]]


-- ENGLISH STRINGS;
--   Override these below in a locale specific section.

AUCT_CLAS_ARMOR = "Armor";
AUCT_CLAS_CLOTH = "Cloth";
AUCT_CLAS_CONTAINER = "Container";
AUCT_CLAS_DRINK = "Drink";
AUCT_CLAS_FISHING = "Fishing";
AUCT_CLAS_FOOD = "Food";
AUCT_CLAS_GEM = "Gem";
AUCT_CLAS_HERB = "Herb";
AUCT_CLAS_HIDE = "Hide";
AUCT_CLAS_LEATHER = "Leather";
AUCT_CLAS_MAGE = "Mage";
AUCT_CLAS_ORE = "Ore";
AUCT_CLAS_POTION = "Potion";
AUCT_CLAS_QUEST = "Quest";
AUCT_CLAS_SHAMAN = "Shaman";
AUCT_CLAS_WARLOCK = "Warlock";
AUCT_CLAS_WEAPON = "Weapon";
AUCT_CLAS_WRITTEN = "Written";

AUCT_TYPE_ALCHEM = "Alchemy";
AUCT_TYPE_COOK = "Cook";
AUCT_TYPE_ENCHANT = "Enchant";
AUCT_TYPE_ENGINEER = "Engineer";
AUCT_TYPE_FSTAID = "1stAid";
AUCT_TYPE_LEATHER = "Leather";
AUCT_TYPE_MINING = "Mining";
AUCT_TYPE_POISON = "Poison";
AUCT_TYPE_SMITH = "Smith";
AUCT_TYPE_TAILOR = "Tailor";

AUCT_RECIPE_PREFIXES = {
	"Recipe: ", "Pattern: ", "Plans: ", "Schematic: ", "Formula: "
};

AUCT_FRMT_BROKER_HEADER = "Minimum profit: %s, HSP = 'Highest Sellable Price'";
AUCT_FRMT_BROKER_LINE = "%s, Last %s seen, HSP: %s, BO: %s, Prof: %s";
AUCT_FRMT_BROKER_DONE = "Brokering done";

AUCT_FRMT_BIDBROKER_HEADER = "Minimum profit: %s, HSP = 'Highest Sellable Price'";
AUCT_FRMT_BIDBROKER_MINBID = "minBid"
AUCT_FRMT_BIDBROKER_CURBID = "currentBid"
AUCT_FRMT_BIDBROKER_LINE = "%s, Last %s seen, HSP: %s, %s: %s, Prof: %s, Time: %s";
AUCT_FRMT_BIDBROKER_DONE = "Bid brokering done";

AUCT_FRMT_PCTLESS_HEADER = "Percent Less than Highest Sellable Price (HSP): %d%%";
AUCT_FRMT_PCTLESS_LINE = "%s, Last %d seen, HSP: %s, BO: %s, Prof: %s, Less %s";
AUCT_FRMT_PCTLESS_DONE = "Percent less done.";

AUCT_FRMT_COMPETE_HEADER = "Competing auctions at least %s less per item.";
AUCT_FRMT_COMPETE_LINE = "%s, Bid: %s, BO %s vs %s, %s less";
AUCT_FRMT_COMPETE_DONE = "Competing auctions done.";

AUCT_FRMT_NOAUCT = "No auctions found for the item: %s";
AUCT_FRMT_MEDIAN_LINE = "Of last %d seen, median buyout for 1 %s is: %s";
AUCT_FRMT_LOW_LINE = "%s, BO: %s, Seller: %s, For one: %s, Less than median: %s";
AUCT_FRMT_HSP_LINE = "Highest Sellable Price for one %s is: %s";

AUCT_FRMT_INFO_SEEN = "Seen %d times at auction total";
AUCT_FRMT_INFO_FORONE = "For 1: %s min/%s buyout (%s bid) [in %d's]";
AUCT_FRMT_INFO_AVERAGE = "%s min/%s buyout (%s bid)"
AUCT_FRMT_INFO_HISTMED = "Last %d seen, buyout median:";
AUCT_FRMT_INFO_SNAPMED = "Last scan %d seen, buyout median:";
AUCT_FRMT_INFO_YOURSTX = "Your %d stack: %s min/%s buyout (%s bid)";
AUCT_FRMT_INFO_BIDRATE = "%d%% have bids, %d%% have buyout";

AUCT_FRMT_INFO_NEVER = "Never seen at %s";
AUCT_FRMT_INFO_ALSOSEEN = "Seen %d times at %s";

AUCT_FRMT_INFO_CLASSUSE = "Class: %s used for %s";
AUCT_FRMT_INFO_CLASS = "Class: %s";
AUCT_FRMT_INFO_USE = "Used for: %s";

AUCT_FRMT_INFO_BUY = "Buy%s from vendor";
AUCT_FRMT_INFO_SELL = "Sell%s to vendor";
AUCT_FRMT_INFO_BUYMULT = "Buy%s %d (%s each)";
AUCT_FRMT_INFO_SELLMULT = "Sell%s %d (%s each)";

AUCT_FRMT_INFO_STX = "Stacks in lots of %d";

AUCT_FRMT_ACT_REMOVE = "Removing auction signature %s from current AH snapshot.";

AUCT_CMD_OFF = "off";
AUCT_CMD_ON = "on";
AUCT_CMD_TOGGLE = "toggle";
AUCT_CMD_CLEAR = "clear";
AUCT_CMD_CLEAR_ALL = "all";
AUCT_CMD_CLEAR_SNAPSHOT = "snapshot";
AUCT_CMD_ALSO = "also";
AUCT_CMD_ALSO_OPPOSITE = "opposite";
AUCT_CMD_BROKER = "broker";
AUCT_CMD_BIDBROKER = "bidbroker";
AUCT_CMD_BIDBROKER_SHORT = "bb";
AUCT_CMD_EMBED = "embed";
AUCT_CMD_PERCENTLESS = "percentless";
AUCT_CMD_PERCENTLESS_SHORT = "pl";
AUCT_CMD_COMPETE = "compete";
AUCT_CMD_SCAN = "scan";

AUCT_OPT_CLEAR = "<[item]|"..AUCT_CMD_CLEAR_ALL.."|"..AUCT_CMD_CLEAR_SNAPSHOT..">";
AUCT_OPT_ALSO = "<realm-faction|"..AUCT_CMD_ALSO_OPPOSITE..">"
AUCT_OPT_BROKER = "[silver_profit]";
AUCT_OPT_BIDBROKER = "[silver_profit]";
AUCT_OPT_PERCENTLESS = "[percent]";
AUCT_OPT_COMPETE = "[silver_less]";
AUCT_OPT_SCAN = "[category]";

AUCT_SHOW_AVERAGE = "show-average";
AUCT_SHOW_LINK = "show-link";
AUCT_SHOW_MEDIAN = "show-median";
AUCT_SHOW_MESH = "show-mesh";
AUCT_SHOW_STACK = "show-stack";
AUCT_SHOW_STATS = "show-stats";
AUCT_SHOW_SUGGEST = "show-suggest";
AUCT_SHOW_USAGE = "show-usage";
AUCT_SHOW_VENDOR = "show-vendor";
AUCT_SHOW_VENDOR_BUY = "show-vendor-buy";
AUCT_SHOW_VENDOR_SELL = "show-vendor-sell";

AUCT_HELP_ONOFF = "Turns the auction data display on and off";
AUCT_HELP_AVERAGE = "Select whether to show item's average auction price";
AUCT_HELP_LINK = "Select whether to show the link id in the tooltip";
AUCT_HELP_MEDIAN = "Select whether to show item's median buyout price";
AUCT_HELP_MESH = "Select whether to show item's mesh if it has one";
AUCT_HELP_SUGGEST = "Select whether to show item's suggested auction price";
AUCT_HELP_STATS = "Select whether to show item's bidded/buyout percentages";
AUCT_HELP_VENDOR = "Select whether to show item's vendor pricing";
AUCT_HELP_VENDOR_SELL = "Select whether to show item's vendor sell pricing (req show-vendor=on)";
AUCT_HELP_VENDOR_BUY = "Select whether to show item's vendor buy pricing (req show-vendor=on)";
AUCT_HELP_USAGE = "Select whether to show tradeskill item's usage";
AUCT_HELP_STACK = "Select whether to show the item's stackable size";
AUCT_HELP_CLEAR = "Clear the specified item's data (you must shift click insert the item(s) into the command) You may also specify the special keywords \"all\" or \"snapshot\"";
AUCT_HELP_ALSO = "Also display another server's values in the tooltip. The special keyword \"opposite\" means the opposite faction, \"off\" disables the functionality.";
AUCT_HELP_BROKER = "Show any auctions from the most recent scan that may be bid on and then resold for profit";
AUCT_HELP_BIDBROKER = "Show short or medium term auctions from the recent scan that may be bid on for profit";
AUCT_HELP_EMBED = "Embed the text in the original game tooltip (note: certain features are disabled when this is selected)";
AUCT_HELP_PERCENTLESS = "Show any recently scanned auctions whose buyout is a certain percent less than the highest sellable price";
AUCT_HELP_COMPETE = "Show any recently scanned auctions whose buyout is less than one of your items";
AUCT_HELP_SCAN = "Perform a scan of the auction house at the next visit, or while you are there (there is also a button in the auction pane)";

AUCT_STAT_ON = "Displaying configured auction data";
AUCT_STAT_OFF = "Not displaying any auction data";

AUCT_FRMT_ACT_CLEARALL = "Clearing all auction data for %s";
AUCT_FRMT_ACT_CLEARSNAP = "Clearing current Auction House snapshot.";
AUCT_FRMT_ACT_CLEAR_OK = "Cleared data for item: %s";
AUCT_FRMT_ACT_CLEAR_FAIL = "Unable to find item: %s";
AUCT_FRMT_ACT_ENABLE = "Displaying item's %s data";
AUCT_FRMT_ACT_DISABLE = "Not displaying item's %s data";
AUCT_FRMT_ACT_UNKNOWN = "Unknown command keyword: '%s'";

AUCT_TEXT_SCAN = "Scan";

-- Locale specific translations for the German client

if (GetLocale() == "deDE") then

AUCT_CLAS_ARMOR = "R\195\188stung";
AUCT_CLAS_CLOTH = "Stoff";
AUCT_CLAS_CONTAINER = "Beh\195\164lter";
AUCT_CLAS_DRINK = "Getr\195\164nk";
AUCT_CLAS_FISHING = "Angeln";
AUCT_CLAS_FOOD = "Nahrung";
AUCT_CLAS_GEM = "Edelstein";
AUCT_CLAS_HERB = "Kr\195\164uter";
AUCT_CLAS_HIDE = "Haut";
AUCT_CLAS_LEATHER = "Leder";
AUCT_CLAS_MAGE = "Magier";
AUCT_CLAS_ORE = "Erz";
AUCT_CLAS_POTION = "Trank";
AUCT_CLAS_QUEST = "Quest";
AUCT_CLAS_SHAMAN = "Shamane";
AUCT_CLAS_WARLOCK = "Hexenmeister";
AUCT_CLAS_WEAPON = "Waffe";
AUCT_CLAS_WRITTEN = "Geschrieben";



AUCT_TYPE_ALCHEM = "Alchemist";
AUCT_TYPE_COOK = "Kochen";
AUCT_TYPE_ENCHANT = "Verzauberer";
AUCT_TYPE_ENGINEER = "Ingenieur";
AUCT_TYPE_FSTAID = "Erste Hilfe";
AUCT_TYPE_LEATHER = "Leder";
AUCT_TYPE_MINING = "Bergbau";
AUCT_TYPE_POISON = "Giftmischer";
AUCT_TYPE_SMITH = "Schmied";
AUCT_TYPE_TAILOR = "Schneider";

AUCT_RECIPE_PREFIXES = {
	"Rezept: ", "Muster: ", "Pl\195\164ne: ", "Schema: ", "Formel: "
};

AUCT_FRMT_BROKER_HEADER = "Minimaler Profit: %s, HSP = 'Highest Sellable Price'";
AUCT_FRMT_BROKER_LINE = "%s, Zuletzt %s gesehen, HSP: %s, BO: %s, Prof: %s";
AUCT_FRMT_BROKER_DONE = "Brokern erledigt";

AUCT_FRMT_BIDBROKER_HEADER = "Minimaler Profit: %s, HSP = 'Highest Sellable Price'";
AUCT_FRMT_BIDBROKER_MINBID = "minBid"
AUCT_FRMT_BIDBROKER_CURBID = "currentBid"
AUCT_FRMT_BIDBROKER_LINE = "%s, Zuletzt %s gesehen, HSP: %s, %s: %s, Prof: %s, Zeit: %s";
AUCT_FRMT_BIDBROKER_DONE = "Bidbroker erledigt";

AUCT_FRMT_PCTLESS_HEADER = "Prozent weniger als Highest Sellable Price (HSP): %d%%";
AUCT_FRMT_PCTLESS_LINE = "%s, Zuletzt %d gesehen, HSP: %s, BO: %s, Prof: %s, Weniger %s";
AUCT_FRMT_PCTLESS_DONE = "Weniger Prozent erledigt.";

AUCT_FRMT_COMPETE_HEADER = "Vergleichbare Auktionen liegen mindestens %s weniger pro Gegenstand.";
AUCT_FRMT_COMPETE_LINE = "%s, Gebot: %s, BO %s vs %s, %s weniger";
AUCT_FRMT_COMPETE_DONE = "Vergleichbare Auktionen erledigt.";

AUCT_FRMT_NOAUCT = "Keine Auktionen gefunden f\195\188r den Gegenstand: %s";
AUCT_FRMT_MEDIAN_LINE = "Zuletzt %d gesehen, medianer Sofortkauf von 1 %s ist: %s";
AUCT_FRMT_LOW_LINE = "%s, BO: %s, Verk\195\164ufer: %s, F\195\188r ein: %s, Weniger als Median: %s";
AUCT_FRMT_HSP_LINE = "Highest Sellable Price f\195\188r ein %s ist: %s";

AUCT_FRMT_INFO_SEEN = "%d mal insgesamt gesehen";
AUCT_FRMT_INFO_FORONE = "F\195\188r 1: %s min/%s Sofortkauf (%s geboten) [in %d Auktionen]";
AUCT_FRMT_INFO_AVERAGE = "%s min/%s Sofortkauf (%s geboten)"
AUCT_FRMT_INFO_HISTMED = "Zuletzt %d gesehen, Sofortkauf Median";
AUCT_FRMT_INFO_SNAPMED = "Beim letzten Scan %d gesehen, Sofortkauf Median";
AUCT_FRMT_INFO_YOURSTX = "Dein %d Stapel: %s min/%s Sofortkauf (%s geboten)";
AUCT_FRMT_INFO_BIDRATE = "%d%% haben Gebote, %d%% haben Sofortkauf";

AUCT_FRMT_INFO_NEVER = "Noch in keiner Auktion gesehen";
AUCT_FRMT_INFO_ALSOSEEN = "%d gesehen bei %s";

AUCT_FRMT_INFO_CLASSUSE = "Art: %s benutzt f\195\188r %s";
AUCT_FRMT_INFO_CLASS = "Art: %s";
AUCT_FRMT_INFO_USE = "Benutzt f\195\188r: %s";

AUCT_FRMT_INFO_BUY = "Einkauf beim H\195\164ndler";
AUCT_FRMT_INFO_SELL = "Verkauf beim H\195\164ndler";
AUCT_FRMT_INFO_BUYMULT = "Einkauf f\195\188r %d (%s pro St\195\188ck)";
AUCT_FRMT_INFO_SELLMULT = "Verkauf f\195\188r %d (%s pro St\195\188ck)";

AUCT_FRMT_INFO_STX = "Stapelbar bis %d St\195\188ck";

AUCT_FRMT_ACT_REMOVE = "Entferne Auktionssignatur %s vom aktuellen AH Schnappschuss.";

AUCT_CMD_OFF = "off";
AUCT_CMD_ON = "on";
AUCT_CMD_TOGGLE = "toggle";
AUCT_CMD_CLEAR = "clear";
AUCT_CMD_CLEAR_ALL = "all";
AUCT_CMD_CLEAR_SNAPSHOT = "snapshot";
AUCT_CMD_ALSO = "also";
AUCT_CMD_ALSO_OPPOSITE = "opposite";
AUCT_CMD_BROKER = "broker";
AUCT_CMD_BIDBROKER = "bidbroker";
AUCT_CMD_BIDBROKER_SHORT = "bb";
AUCT_CMD_EMBED = "embed";
AUCT_CMD_PERCENTLESS = "percentless";
AUCT_CMD_PERCENTLESS_SHORT = "pl";
AUCT_CMD_COMPETE = "compete";
AUCT_CMD_SCAN = "scan";

AUCT_OPT_CLEAR = "<[item]|"..AUCT_CMD_CLEAR_ALL.."|"..AUCT_CMD_CLEAR_SNAPSHOT..">";
AUCT_OPT_ALSO = "<realm-faction|"..AUCT_CMD_ALSO_OPPOSITE..">"
AUCT_OPT_BROKER = "[silver_profit]";
AUCT_OPT_BIDBROKER = "[silver_profit]";
AUCT_OPT_PERCENTLESS = "[percent]";
AUCT_OPT_COMPETE = "[silver_less]";
AUCT_OPT_SCAN = "[category]";

AUCT_SHOW_AVERAGE = "show-average";
AUCT_SHOW_LINK = "show-link";
AUCT_SHOW_MEDIAN = "show-median";
AUCT_SHOW_MESH = "show-mesh";
AUCT_SHOW_STACK = "show-stack";
AUCT_SHOW_STATS = "show-stats";
AUCT_SHOW_SUGGEST = "show-suggest";
AUCT_SHOW_USAGE = "show-usage";
AUCT_SHOW_VENDOR = "show-vendor";
AUCT_SHOW_VENDOR_BUY = "show-vendor-buy";
AUCT_SHOW_VENDOR_SELL = "show-vendor-sell";

AUCT_HELP_ONOFF = "Stellt die Anzeige der Auktionsdaten an (ON) und aus (OFF)";
AUCT_HELP_AVERAGE = "W\195\164hlt aus, ob der durchschnittliche Auktionspreis angezeigt wird";
AUCT_HELP_LINK = "W\195\164hlt aus, ob die Link ID im Tooltip gezeigt wird";
AUCT_HELP_MEDIAN = "W\195\164hlt aus, ob der Median des Gegenstandes gezeigt wird";
AUCT_HELP_MESH = "W\195\164hlt aus, ob der Mesh des Gegenstandes gezeigt wird, sofern er einen besitzt";
AUCT_HELP_SUGGEST = "W\195\164hlt aus, ob der vorgeschlagene Auktionspreis des Gegenstandes gezeigt wird";
AUCT_HELP_STATS = "W\195\164hlt aus, ob der Gebote/Sofortkauf Prozentsatz des Gegenstandes gezeigt wird";
AUCT_HELP_VENDOR = "W\195\164hlt aus, ob die H\195\164ndlerpreise des Gegenstandes gezeigt werden";
AUCT_HELP_VENDOR_SELL = "W\195\164hlt aus, ob der Verkaufspreis des Gegenstandes beim H\195\164ndler gezeigt wird (ben\195\182tigt show-vendor=on)";
AUCT_HELP_VENDOR_BUY = "W\195\164hlt aus, ob der Kaufpreis des Gegenstandes beim H\195\164ndler gezeigt wird (ben\195\182tigt show-vendor=on)";
AUCT_HELP_USAGE = "W\195\164hlt aus, ob angezeigt wird, wof\195\188r der Gegenstand nutzbar ist";
AUCT_HELP_STACK = "W\195\164hlt aus, ob die stapelbare Menge angezeigt wird";
AUCT_HELP_CLEAR = "L\195\182scht die Daten des angegebenen Gegenstandes (Gegenstand muﬂ durch Shiftklick in der Kommandozeile eingef\195\188gt werden) Kann auch mit den Befehlen \"all\" oder \"snapshot\" genutzt werden.";
AUCT_HELP_ALSO = "Zeigt ebenso die Daten eines anderen Servers im Tooltip. Der Befehl \"opposite\" meint die andere Fraktion, \"off\" stellt die Funktionalit\195\164t aus.";
AUCT_HELP_BROKER = "Zeigt alle Auktionen des letzten Scans, auf die geboten und der Gegenstand mit Profit wieder verkauft werden kann.";
AUCT_HELP_BIDBROKER = "Zeigt kurze oder mittellange Auktionen des letzten Scans, auf die f\195\188r Profit geboten werden kann.";
AUCT_HELP_EMBED = "F\195\188gt den Text im Originaltooltip des Spieles ein (Hinweis: Bestimmte Merkmale sind ausgestellt, wenn dies gew\195\164hlt wird).";
AUCT_HELP_PERCENTLESS = "Zeigt alle zuletzt gescannten Auktionen, deren Sofortkauf einen bestimmten Prozentsatz unter dem Highest Sellable Price (HSP) liegt.";
AUCT_HELP_COMPETE = "Zeigt alle zuletzt gescannten Auktionen deren Sofortkaufspreis unter dem Preis eines eigenen Gegenstandes";
AUCT_HELP_SCAN = "Startet den Scan des Auktionshauses beim n\195\164chsten Besuch oder wenn man dort ist (es gibt ebenso einen Knopf in der Auktionsleiste)";

AUCT_STAT_ON = "Zeige konfigurierte Auktionsdaten";
AUCT_STAT_OFF = "Zeige konfigurierte Auktionsdaten nicht";

AUCT_FRMT_ACT_CLEARALL = "L\195\182sche alle Auktionsdaten f\195\188r %s";
AUCT_FRMT_ACT_CLEARSNAP = "L\195\182sche aktuellen Auktionshaus-Schnappschuss.";
AUCT_FRMT_ACT_CLEAR_OK = "Daten gel\195\182scht f\195\188r: %s";
AUCT_FRMT_ACT_CLEAR_FAIL = "Kann folgenden Gegenstand nicht finden: %s";
AUCT_FRMT_ACT_ENABLE = "Zeige Daten f\195\188r den Gegenstand %s";
AUCT_FRMT_ACT_DISABLE = "Zeige Daten f\195\188r den Gegenstand %s nicht";
AUCT_FRMT_ACT_UNKNOWN = "Unbekannter Befehl: '%s'";

AUCT_TEXT_SCAN = "Scan";

-- Locale specific translations for the French client
elseif (GetLocale() == "frFR") then

end


