--[[
	WARNING: This file is automatically generated from those in the
	locales directory. Do not edit it directly.


	You may find the source versions of this file at the SourceForge
	project webpage, in the CVS repository.
	Please visit the homepage for more information.
		http://enchantrix.sf.net/

	$Id$
	Version: <%version%>
]]

-- Default locale strings are defined in English


ENCH_FRMT_WELCOME = "Enchantrix v%s loaded";
ENCH_FRMT_CREDIT = "  (go to http://enchantrix.org/ to share your data)";

ENCH_CMD_OFF = "off";
ENCH_CMD_ON = "on";
ENCH_CMD_TOGGLE = "toggle";
ENCH_CMD_CLEAR = "clear";
ENCH_CMD_CLEAR_ALL = "all";

ENCH_CMD_FIND_BUYAUCT = "percentless";
ENCH_CMD_FIND_BIDAUCT = "bidbroker";

ENCH_CMD_FIND_BUYAUCT_SHORT = "pl";
ENCH_CMD_FIND_BIDAUCT_SHORT = "bb";

ENCH_OPT_CLEAR = "([Item]|"..ENCH_CMD_CLEAR_ALL..")";
ENCH_OPT_FIND_BUYAUCT = "<percent>";
ENCH_OPT_FIND_BIDAUCT = "<silver>";

ENCH_SHOW_EMBED = "show-embedded";
ENCH_SHOW_HEADER = "show-header";
ENCH_SHOW_COUNT = "show-count";
ENCH_SHOW_RATE = "show-rate";
ENCH_SHOW_VALUE = "show-value";
ENCH_SHOW_GUESS_AUCTIONEER_HSP = "valuate-hsp";
ENCH_SHOW_GUESS_AUCTIONEER_MED = "valuate-median";
ENCH_SHOW_GUESS_BASELINE = "valuate-baseline";

ENCH_HELP_ONOFF = "Turns the enchant data display on and off";
ENCH_HELP_EMBED = "Embed the text in the original game tooltip (note: certain features are disabled when this is selected)";
ENCH_HELP_HEADER = "Select whether to show the header line";
ENCH_HELP_COUNT = "Select whether to show the exact counts in the database";
ENCH_HELP_RATE = "Select whether to show the average quantity of disenchant";

ENCH_HELP_VALUE = "Select whether to show item's estimated values based on the proportions of possible disenchants";
ENCH_HELP_GUESS_AUCTIONEER_HSP = "If valuation is enabled, and you have auctioneer installed, display the sellable price (HSP) valuation of disenchanting the item.";
ENCH_HELP_GUESS_AUCTIONEER_MEDIAN = "If valuation is enabled, and you have auctioneer installed, display the median based valuation of disenchanting the item.";
ENCH_HELP_GUESS_NOAUCTIONEER = "The "..ENCH_SHOW_GUESS_AUCTIONEER_HSP.." and "..ENCH_SHOW_GUESS_AUCTIONEER_MED.." commands are not available because you do not have auctioneer installed";
ENCH_HELP_GUESS_BASELINE = "If valuation is enabled, (auctioneer not needed) display the baseline valuation of disenchanting the item, based upon the inbuilt prices.";

ENCH_HELP_CLEAR = "Clear the specified item's data (you must shift click insert the item(s) into the command) You may also specify the special keyword \"all\"";
ENCH_HELP_FIND_BUYAUCT = "Find auctions whose possible disenchant value is a certain percent less than the buyout price";
ENCH_HELP_FIND_BIDAUCT = "Find auctions whose possible disenchant value is a certain silver amount less than the bid price";

ENCH_STAT_ON = "Displaying configured enchant data";
ENCH_STAT_OFF = "Not displaying any enchant data";

ENCH_FRMT_ACT_CLEARALL = "Clearing all auction data for %s";
ENCH_FRMT_ACT_CLEAR_OK = "Cleared data for item: %s";
ENCH_FRMT_ACT_CLEAR_FAIL = "Unable to find item: %s";
ENCH_FRMT_ACT_ENABLE = "Displaying item's %s data";
ENCH_FRMT_ACT_DISABLE = "Not displaying item's %s data";
ENCH_FRMT_ACT_ENABLED_ON = "Displaying item's %s on %s";
ENCH_FRMT_ACT_SET = "Set %s to '%s'";
ENCH_FRMT_ACT_UNKNOWN = "Unknown command keyword: '%s'";

ENCH_FRMT_DISINTO = "Disenchants into:";
ENCH_FRMT_FOUND = "Found that %s disenchants into:";
ENCH_FRMT_USAGE = "Usage:";

ENCH_FRMT_COUNTS = "    (base=%d, old=%d, new=%d)";
ENCH_FRMT_VALUE_AUCT_HSP = "Disenchant value (HSP)";
ENCH_FRMT_VALUE_AUCT_MED = "Disenchant value (Median)";
ENCH_FRMT_VALUE_MARKET = "Disenchant value (Baseline)";

ENCH_FRMT_BIDBROKER_HEADER = "Bids having %s silver savings on average disenchant value:";
ENCH_FRMT_BIDBROKER_MINBID = "minBid"
ENCH_FRMT_BIDBROKER_CURBID = "curBid"
ENCH_FRMT_BIDBROKER_LINE = "%s, Valued at: %s, %s: %s, Save: %s, Less %s, Time: %s";
ENCH_FRMT_BIDBROKER_DONE = "Bid brokering done";

ENCH_FRMT_PCTLESS_HEADER = "Buyouts having %d%% savings over average item disenchant value:";
ENCH_FRMT_PCTLESS_LINE = "%s, Valued at: %s, BO: %s, Save: %s, Less %s";
ENCH_FRMT_PCTLESS_DONE = "Percent less done.";


EssenceItemIDs = {};
EssenceItemIDs["Greater Astral Essence"] = 11082;
EssenceItemIDs["Greater Eternal Essence"] = 16203;
EssenceItemIDs["Greater Magic Essence"] = 10939;
EssenceItemIDs["Greater Mystic Essence"] = 11135;
EssenceItemIDs["Greater Nether Essence"] = 11175;
EssenceItemIDs["Lesser Astral Essence"] = 10998;
EssenceItemIDs["Lesser Eternal Essence"] = 16202;
EssenceItemIDs["Lesser Magic Essence"] = 10938;
EssenceItemIDs["Lesser Mystic Essence"] = 11134;
EssenceItemIDs["Lesser Nether Essence"] = 11174;
EssenceItemIDs["Large Brilliant Shard"] = 14344;
EssenceItemIDs["Large Glimmering Shard"] = 11084;
EssenceItemIDs["Large Glowing Shard"] = 11139;
EssenceItemIDs["Large Radiant Shard"] = 11178;
EssenceItemIDs["Small Brilliant Shard"] = 14343;
EssenceItemIDs["Small Glimmering Shard"] = 10978;
EssenceItemIDs["Small Glowing Shard"] = 11138;
EssenceItemIDs["Small Radiant Shard"] = 11177;
EssenceItemIDs["Dream Dust"] = 11176;
EssenceItemIDs["Illusion Dust"] = 16204;
EssenceItemIDs["Soul Dust"] = 11083;
EssenceItemIDs["Strange Dust"] = 10940;
EssenceItemIDs["Vision Dust"] = 11137;


