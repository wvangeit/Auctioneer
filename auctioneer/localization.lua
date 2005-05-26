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
AUCT_FRMT_BIDBROKER_LINE = "%s, Last %s seen, HSP: %s, CurrentBid: %s, Prof: %s, Time: %s";
AUCT_FRMT_BIDBROKER_DONE = "Bid brokering done";

AUCT_FRMT_PCTLESS_HEADER = "Percent Less than median: %d%%";
AUCT_FRMT_PCTLESS_LINE = "%s, Last %d seen, Median: %s, BO: %s, Prof: %s, Less %s%%";
AUCT_FRMT_PCTLESS_DONE = "Percent less done.";

AUCT_FRMT_NOAUCT = "No auctions found for the item: %s";
AUCT_FRMT_MEDIAN_LINE = "Of last %d seen, median buyout for 1 %s is: %s";
AUCT_FRMT_LOW_LINE = "%s, BO: %s, Seller: %s, For one: %s, Less than median: %s%%";
AUCT_FRMT_HSP_LINE = "Highest Sellable Price for one %s is: %s";

AUCT_FRMT_INFO_SEEN = "Seen %d times at auction total";
AUCT_FRMT_INFO_FORONE = "For 1: %s min/%s buyout (%s bid) [in %d's]";
AUCT_FRMT_INFO_AVERAGE = "%s min/%s buyout (%s bid)"
AUCT_FRMT_INFO_HISTMED = "Last %d seen, buyout median: %s";
AUCT_FRMT_INFO_SNAPMED = "Last scan %d seen, buyout median: %s";
AUCT_FRMT_INFO_YOURSTX = "Your %d stack: %s min/%s buyout (%s bid)";
AUCT_FRMT_INFO_BIDRATE = "%d%% have bids, %d%% have buyout";

AUCT_FRMT_INFO_NEVER = "Never seen at %s";
AUCT_FRMT_INFO_ALSOSEEN = "Seen %d times at %s";

AUCT_FRMT_INFO_CLASSUSE = "Class: %s used for %s";
AUCT_FRMT_INFO_CLASS = "Class: %s";
AUCT_FRMT_INFO_USE = "Used for: %s";

AUCT_FRMT_INFO_BUY = "Buy%s %s";
AUCT_FRMT_INFO_SELL = "Sell%s %s";
AUCT_FRMT_INFO_BUYSELL = "Buy%s %s, Sell%s %s";
AUCT_FRMT_INFO_BUYMULT = "Buy%s %d at %s (%s ea)";
AUCT_FRMT_INFO_SELLMULT = "Sell%s %d at %s (%s ea)";

AUCT_FRMT_INFO_STX = "Stacks in lots of %d";

AUCT_FRMT_ACT_REMOVE = "Removing auction signature %s from current AH snapshot.";

AUCT_HELP_ONOFF = "turns the auction data display on and off";
AUCT_HELP_AVERAGE = "select whether to show item's average auction price";
AUCT_HELP_MEDIAN = "select whether to show item's median buyout price";
AUCT_HELP_SUGGEST = "select whether to show item's suggested auction price";
AUCT_HELP_STATS = "select whether to show item's bidded/buyout percentages";
AUCT_HELP_VENDOR = "select whether to show item's vendor pricing";
AUCT_HELP_VENDORSELL = "select whether to show item's vendor sell pricing (req vendor=on)";
AUCT_HELP_VENDORBUY = "select whether to show item's vendor buy pricing (req vendor=on)";
AUCT_HELP_USAGE = "select whether to show tradeskill item's usage";
AUCT_HELP_STACKSIZE = "select whether to show the item's stackable size";
AUCT_HELP_CLEAR = "clear the specified item's data (you may shift click insert multiple items into this command, or specify only one textually) If you specify 'all' by itself, the entire dataset for this server will be cleared";

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
--	AUCT_CLAS_ARMOR = "Armor";
--	AUCT_CLAS_CLOTH = "Cloth";
--	AUCT_CLAS_CONTAINER = "Container";
	AUCT_CLAS_DRINK = "Trunk";
--	AUCT_CLAS_FISHING = "Fishing";
	AUCT_CLAS_FOOD = "Nahrung";
	AUCT_CLAS_GEM = "Juwel";
	AUCT_CLAS_HERB = "Kraut";
--	AUCT_CLAS_HIDE = "Hide";
	AUCT_CLAS_LEATHER = "Leder";
--	AUCT_CLAS_MAGE = "Mage";
	AUCT_CLAS_ORE = "Erz";
	AUCT_CLAS_POTION = "Zaubertrank";
--	AUCT_CLAS_QUEST = "Quest";
--	AUCT_CLAS_SHAMAN = "Shaman";
--	AUCT_CLAS_WARLOCK = "Warlock";
--	AUCT_CLAS_WEAPON = "Weapon";
--	AUCT_CLAS_WRITTEN = "Written";

	AUCT_TYPE_ALCHEM = "Alchemie";
	AUCT_TYPE_COOK = "Koch";
	AUCT_TYPE_ENCHANT = "Verzaubern";
	AUCT_TYPE_ENGINEER = "Ingenieur";
	AUCT_TYPE_FSTAID = "Heilkunst";
	AUCT_TYPE_LEATHER = "Lederverarb";
	AUCT_TYPE_MINING = "Bergbau";
	AUCT_TYPE_POISON = "Giftmischer";
	AUCT_TYPE_SMITH = "Schmied";
	AUCT_TYPE_TAILOR = "Schneider";


-- Locale specific translations for the French client
elseif (GetLocale() == "frFR") then

end


