--[[
	WARNING: This is a generated file.
	If you wish to perform or update localizations, please go to our Localizer website at:
	http://norganna.org/localizer/index.php

	AddOn: Enchantrix
	Revision: $Id: EnxStrings.lua 1547 2007-03-04 17:11:14Z luke1410 $
	Version: 3.9.0.1560 (Wallaby)

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit licence to use this AddOn with these facilities
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

BarkerLocalizations = {

	csCZ = {

	};

	daDK = {

	};

	deDE = {


		-- Section: Command Messages
		BarkerEnxWindowNotOpen	= "Das Enchantrix-Fenster ist nicht geöffnet. Das Enchantrix-Fenster muss geöffnet sein um Barker nutzen zu können.";
		BarkerNoEnchantsAvail	= "Enchantrix: Sie haben entweder keine Entzauberungen oder keine Gegenstände um welche herzustellen.";

		FrmtActDefault	= "Die Enchantrix-Option '%s' wurde auf den Standardwert zurückgesetzt.";
		FrmtActDefaultAll	= "Alle Enchantrix-Optionen wurden auf die Standardwerte zurückgesetzt.";
		FrmtActDisable	= "Zeige keine Daten von Gegenstand %s";
		FrmtActEnable	= "Zeige Daten von Gegenstand %s";
		FrmtActEnabledOn	= "Zeige Gegenstand %s auf %s";
		FrmtActSet	= "Setze %s zu '%s'";
		FrmtActUnknown	= "Unbekannter Befehl: '%s'";
		FrmtActUnknownLocale	= "Das angegebene Gebietsschema ('%s') ist unbekannt. Gültige Gebietsschemata sind:";
		FrmtPrintin	= "Die Enchantrix-Meldungen werden nun im Chat-Fenster \"%s\" angezeigt";
		FrmtUsage	= "Syntax:";
		MesgDisable	= "Das automatische Laden von Enchantrix wird deaktiviert";
		MesgNotloaded	= "Enchantrix ist nicht geladen. Geben Sie /enchantrix ein um mehr Informationen zu erhalten.";


		-- Section: Command Options
		CmdClearAll	= "all";
		OptClear	= "([Gegenstand]|all)";
		OptDefault	= "(<Option>|all)";
		OptFindBidauct	= "<Silber>";
		OptFindBuyauct	= "<Prozent>";
		OptLocale	= "<Sprache>";
		OptPrintin	= "(<Fenster-Index>[Nummer]|<Fenster-Name>[String])";


		-- Section: Commands
		BarkerOff	= "Barker ausgeschaltet.";
		BarkerOn	= "Barker eingeschaltet.";
		CmdBarker	= "barker";
		CmdClear	= "clear";
		CmdDefault	= "default";
		CmdDisable	= "disable";
		CmdHelp	= "help";
		CmdLocale	= "locale";
		CmdOff	= "off";
		CmdOn	= "on";
		CmdPrintin	= "print-in";
		CmdToggle	= "toggle";
		ShowEmbed	= "embed";
		ShowGuessAuctioneerHsp	= "valuate-hsp";
		ShowGuessAuctioneerMed	= "valuate-median";
		ShowGuessBaseline	= "valuate-baseline";
		ShowHeader	= "header";
		ShowRate	= "rates";
		ShowTerse	= "terse";
		ShowValue	= "valuate";


		-- Section: Config Text
		GuiLoad	= "Enchantrix laden";
		GuiLoad_Always	= "immer";
		GuiLoad_Never	= "nie";


		-- Section: Game Constants
		ArgSpellname	= "Entzaubern";
		BarkerOpening	= "Verkaufe Verzauberungen:";
		Darnassus	= "Darnassus";
		Ironforge	= "Eisenschmiede";
		OneLetterGold	= "G";
		OneLetterSilver	= "S";
		Orgrimmar	= "Orgrimmar";
		PatReagents	= "Reagenzien: (.+)";
		Shattrath	= "Shattrath";
		ShortDarnassus	= "Dar";
		ShortIronForge	= "IF";
		ShortOrgrimmar	= "Org";
		ShortShattrath	= "Sha";
		ShortStormwind	= "SW";
		ShortThunderBluff	= "TB";
		ShortUndercity	= "UC";
		StormwindCity	= "Sturmwind";
		TextCombat	= "Kampflog";
		TextGeneral	= "Allgemein";
		ThunderBluff	= "Donnerfels";
		Undercity	= "Unterstadt";
		["ShortExodar"]	= "Exo";
		["ShortSilvermoon"]	= "SM";
		["SilvermoonCity"]	= "Silbermond";
		["TheExodar"]	= "Exodar";


		-- Section: Generic Messages
		FrmtCredit	= "(besuche http://enchantrix.org/ um deine Entzauberdaten mit anderen zu teilen)";
		FrmtWelcome	= "Enchantrix v%s geladen";
		MesgAuctVersion	= "Enchantrix benötigt Auctioneer Version 3.4 oder höher. Einige Funktionen werden nicht verfügbar sein, bis Sie ihre Auctioneer Version aktualisieren.";


		-- Section: Help Text
		GuiBarker	= "Barker aktivieren";
		HelpBarker	= "Schaltet Barker ein und aus";
		HelpDefault	= "Setzt die angegebene Enchantrix-Option auf ihren Standardwert zurück. Mit dem Schlüsselwort \"all\" werden alle Enchantrix-Optionen zurückgesetzt.";
		HelpDisable	= "Verhindert das automatische Laden von Enchantrix beim Login";
		HelpEmbed	= "Zeige den Text im In-Game Tooltip \n(Hinweis: Einige Funktionen stehen dann nicht zur Verfügung)";
		HelpGuessAuctioneerHsp	= "Wenn die Wertschätzung aktiviert und Auctioneer installiert ist, zeige den maximalen Verkaufspreis (Auctioneer-HVP) für das Entzaubern";
		HelpGuessAuctioneerMedian	= "Wenn die Wertschätzung aktiviert und Auctioneer installiert ist, zeige den durchschnittlichen Verkaufspreis (Auctioneer-MEDIAN) für das Entzaubern";
		HelpGuessBaseline	= "Wenn die Wertschätzung aktiviert ist, zeige den Marktpreis aus der internen Preisliste (Auctioneer wird nicht benötigt)";
		HelpGuessNoauctioneer	= "Die Befehle \"valuate-hsp\" und \"valuate-median\" sind nicht verfügbar weil Auctioneer nicht installiert ist";
		HelpHeader	= "Auswählen ob die Kopfzeile angezeigt werden soll";
		HelpLoad	= "Ladeverhalten von Enchantrix für diesen Charakter ändern";
		HelpLocale	= "Ändern des Gebietsschemas das zur Anzeige \nvon Enchantrix-Meldungen verwendet wird";
		HelpOnoff	= "Schaltet die Anzeige von Entzauberungsdaten ein oder aus";
		HelpPrintin	= "Auswählen in welchem Fenster die Enchantrix-Meldungen angezeigt werden. Es kann entweder der Fensterindex oder der Fenstername angegeben werden.";
		HelpValue	= "Auswählen ob geschätzte Verkaufspreise aufgrund \nder Anteile an möglichen Entzauberungen angezeigt werden";


		-- Section: Report Messages


		-- Section: Tooltip Messages
		FrmtBarkerPrice	= "Barker Preis (%d%% Gewinn)";
		FrmtPriceEach	= "(%s/stk)";
		FrmtSuggestedPrice	= "vorgeschlagener Preis";
		FrmtTotal	= "Gesamtsumme";
		FrmtWarnAuctNotLoaded	= "Auktionstool nicht geladen, es werden gespeicherte Preise benutzt";
		FrmtWarnNoPrices	= "Keine Preise verfügbar";
		FrmtWarnPriceUnavail	= "Einige Preise nicht verfügbar";


		-- Section: User Interface
		BarkerOptionsHighestPriceForFactorTitle	= "Höchster Preisfaktor";
		BarkerOptionsHighestPriceForFactorTooltip	= "Entzauberungen erhalten einen Score von null für die Preispriorität, auf diesem bzw. über diesem Wert.";
		BarkerOptionsHighestProfitTitle	= "Höchster Gewinn";
		BarkerOptionsHighestProfitTooltip	= "Höchster machbarer Gewinn für eine Entzauberung.";
		BarkerOptionsLowestPriceTitle	= "Niedrigster Preis";
		BarkerOptionsLowestPriceTooltip	= "Niedrigster Angebotspreis für eine Entzauberung. ";
		BarkerOptionsPricePriorityTitle	= "Gesamt-Preispriorität";
		BarkerOptionsPricePriorityTooltip	= "Legt die Wichtigkeit, der Preisermittlung innerhalb der Gesamtpriorität der Werbemaßnahmen, fest.";
		BarkerOptionsPriceSweetspotTitle	= "Preisfaktor SweetSpot";
		BarkerOptionsPriceSweetspotTooltip	= "Preisbereich der bevorzugten Entzauberungen für Werbemaßnahmen.";
		BarkerOptionsProfitMarginTitle	= "Gewinnspanne";
		BarkerOptionsProfitMarginTooltip	= "Der prozentuale Gewinnanteil, welcher zu den Standartkosten hinzuaddiert werden soll.";
		BarkerOptionsRandomFactorTitle	= "Zufallsfaktor";
		BarkerOptionsRandomFactorTooltip	= "Legt die Größe des Zufallsfaktors, in welchem Entzauberungen für die Handelsausrufe ausgewählt werden fest.";
		BarkerOptionsTab1Title	= "Gewinn und Preisprioritäten";

	};

	enUS = {


		-- Section: Command Messages
		BarkerEnxWindowNotOpen	= "Enchantrix: The enchant window is not open. The enchanting window must be open in order to use the barker.";
		BarkerNoEnchantsAvail	= "Enchantrix: You either don't have any enchants or don't have the reagents to make them.";

		FrmtActDefault	= "Enchantrix's %s option has been reset to its default setting";
		FrmtActDefaultAll	= "All Enchantrix options have been reset to default settings.";
		FrmtActDisable	= "Not displaying item's %s data";
		FrmtActEnable	= "Displaying item's %s data";
		FrmtActEnabledOn	= "Displaying item's %s on %s";
		FrmtActSet	= "Set %s to '%s'";
		FrmtActUnknown	= "Unknown command keyword: '%s'";
		FrmtActUnknownLocale	= "The locale you specified ('%s') is unknown. Valid locales are:";
		FrmtPrintin	= "Enchantrix's messages will now print on the \"%s\" chat frame";
		FrmtUsage	= "Usage:";
		MesgDisable	= "Disabling automatic loading of Enchantrix";
		MesgNotloaded	= "Enchantrix is not loaded. Type /enchantrix for more info.";


		-- Section: Command Options
		CmdClearAll	= "all";
		OptClear	= "([Item]|all)";
		OptDefault	= "(<option>|all)";
		OptFindBidauct	= "<silver>";
		OptFindBuyauct	= "<percent>";
		OptLocale	= "<locale>";
		OptPrintin	= "(<frameIndex>[Number]|<frameName>[String])";


		-- Section: Commands
		BarkerOff	= "Barker function disabled.";
		BarkerOn	= "Barker function enabled.";
		CmdBarker	= "barker";
		CmdClear	= "clear";
		CmdDefault	= "default";
		CmdDisable	= "disable";
		CmdHelp	= "help";
		CmdLocale	= "locale";
		CmdOff	= "off";
		CmdOn	= "on";
		CmdPrintin	= "print-in";
		CmdToggle	= "toggle";
		ShowEmbed	= "embed";
		ShowGuessAuctioneerHsp	= "valuate-hsp";
		ShowGuessAuctioneerMed	= "valuate-median";
		ShowGuessBaseline	= "valuate-baseline";
		ShowValue	= "valuate";


		-- Section: Config Text
		GuiLoad	= "Load Enchantrix";
		GuiLoad_Always	= "always";
		GuiLoad_Never	= "never";


		-- Section: Game Constants
		ArgSpellname	= "Disenchant";
		BarkerOpening	= "Selling Enchants:";
		Darnassus	= "Darnassus";
		Ironforge	= "City of Ironforge";
		OneLetterGold	= "g";
		OneLetterSilver	= "s";
		Orgrimmar	= "Orgrimmar";
		PatReagents	= "Reagents: (.+)";
		Shattrath	= "Shattrath City";
		ShortDarnassus	= "Dar";
		ShortExodar = "Exo";
		ShortIronForge	= "IF";
		ShortOrgrimmar	= "Org";
		ShortShattrath	= "Sha";
		ShortStormwind	= "SW";
		ShortThunderBluff	= "TB";
		ShortUndercity	= "UC";
		SilvermoonCity = "Silvermoon City";
		ShortSilvermoon = "SmC";
		StormwindCity	= "Stormwind City";
		TextCombat	= "Combat";
		TextGeneral	= "General";
		TheExodar = "The Exodar";
		ThunderBluff	= "Thunder Bluff";
		Undercity	= "Undercity";
		
		Bracer		= "Bracer";
		Gloves		= "Gloves";
		Boots		= "Boots";
		Shield		= "Shield";
		Chest		= "Chest";
		Cloak		= "Cloak";
		TwoHandWeapon	= "2H Weapon";
		AnyWeapon		= "Any Weapon";
		Weapon		= "Weapon";
		Ring		= "Ring";
		
		["EnchSearchCrusader"] = 'heals for [0-9]+ to [0-9]+ and increases strength';
		["EnchSearchIntellect"] = 'intellect';
		["EnchSearchStamina"] = 'stamina';
		["EnchSearchSpirit"] = 'spirit';
		["EnchSearchStrength"] = 'strength';
		["EnchSearchAgility"] = 'agility';
		["EnchSearchFireRes"] = 'fire resistance';
		["EnchSearchResFire"] = 'resistance to fire';
		["EnchSearchFrostRes"] = 'frost resistance';
		["EnchSearchNatureRes"] = 'nature resistance';
		["EnchSearchResShadow"] = 'resistance to shadow';
		["EnchSearchAllStats"] = 'all stats';
		["EnchSearchMana"] = 'mana';
		["EnchSearchHealth"] = 'health';
		["EnchSearchArmor"] = 'armor';
		["EnchSearchDMGAbsorption"] = 'absorption';
		["EnchSearchDamage1"] = 'points? of damage';
		["EnchSearchDamage2"] = '\+[0-9]+ damage';
		["EnchSearchDefense"] = 'defense';
		["EnchSearchAllResistance1"] = 'resistance to all schools of magic';
		["EnchSearchAllResistance2"] = 'resistance to all magic schools';
		["EnchSearchAllResistance3"] = 'all resistances';
		["EnchSearchVitality"] = 'restore [0-9]+ health and mana';
		["EnchSearchBattlemaster"] = 'heal nearby party members';
		["EnchSearchSpellsurge"] = 'restore [0-9]+ mana to all party members';
		["EnchSearchCatSwiftness"] = 'movement speed increase and [0-9]+ Agility';
		["EnchSearchBoarSpeed"] = 'movement speed increase and [0-9]+ Stamina';
		["EnchSearchMongoose"] = 'increase agility by [0-9]+ and attack speed';
		["EnchSearchSunfire"] = 'fire and arcane spells';
		["EnchSearchSoulfrost"] = 'frost and shadow spells';
		["EnchSearchBeastmaster"] = 'damage to beasts';
		["EnchSearchSpellPower1"] = 'damage to spells';
		["EnchSearchSpellPower2"] = 'damage to all spells';
		["EnchSearchSpellPower3"] = 'spell damage';
		
		["TradeChannel"] = "Trade - City";


		-- Section: Generic Messages
		FrmtCredit	= "  (go to http://enchantrix.org/ to share your data)";
		FrmtWelcome	= "Enchantrix v%s loaded";
		MesgAuctVersion	= "Enchantrix requires Auctioneer version 3.4 or higher. Some features will be unavailable until you update your Auctioneer installation.";
		["AGI"]	= "AGI";
		["AllStats"]	= "all stats";
		["Crusader"]	= "Crusader";
		["DEF"]	= "DEF";
		["DMG"]	= "DMG";
		["DMGAbsorb"]	= "DMG absorb";
		["FireRes"]	= "fire res";
		["FrostRes"]	= "frost res";
		["INT"]	= "INT";
		["NatureRes"]	= "nature res";
		["ShadowRes"]	= "shadow res";
		["ShortAllRes"]	= "all res";
		["ShortArmor"]	= "armor";
		["ShortHealth"]	= "health";
		["ShortMana"]	= "mana";
		["SPI"]	= "SPI";
		["STA"]	= "STA";
		["STR"]	= "STR";
		["BarkerNotTradeZone"] = "Enchantrix Barker: You aren't in a trade zone.";
		["BarkerLoaded"] = "Enchantrix Barker Loaded...";
		["ShortVitality"] = "Vitality";
		["ShortBattlemaster"]	= "Battlemaster";
		["ShortSpellSurge"] = "Spellsurge";
		["ShortCatSwiftness"] = "Cat Swiftness";
		["ShortBoarSpeed"] = "Boar Speed";
		["ShortMongoose"] = "Mongoose";
		["ShortSunfire"] = "Sunfire";
		["ShortSoulfrost"] = "Soulfrost";
		["ShortBeastmaster"] = "Beast";
		["ShortSpellPower"] = "spell";

		-- Section: Help Text
		GuiBarker	= "Enable Barker";
		HelpBarker	= "Turns Barker on and off";
		HelpDefault	= "Set an Enchantrix option to it's default value. You may also specify the special keyword \"all\" to set all Enchantrix options to their default values.";
		HelpDisable	= "Stops enchantrix from automatically loading next time you log in";
		HelpEmbed	= "Embed the text in the original game tooltip (note: certain features are disabled when this is selected)";
		HelpGuessAuctioneerHsp	= "If valuation is enabled, and you have Auctioneer installed, display the sellable price (HSP) valuation of disenchanting the item.";
		HelpGuessAuctioneerMedian	= "If valuation is enabled, and you have Auctioneer installed, display the median based valuation of disenchanting the item.";
		HelpGuessBaseline	= "If valuation is enabled, (Auctioneer not needed) display the baseline valuation of disenchanting the item, based upon the inbuilt prices.";
		HelpGuessNoauctioneer	= "The valuate-hsp and valuate-median commands are not available because you do not have auctioneer installed";
		HelpHeader	= "Select whether to show the header line";
		HelpLoad	= "Change Enchantrix's load settings for this toon";
		HelpLocale	= "Change the locale that is used to display Enchantrix messages";
		HelpOnoff	= "Turns the enchant data display on and off";
		HelpPrintin	= "Select which frame Enchantix will print out it's messages. You can either specify the frame's name or the frame's index.";
		HelpValue	= "Select whether to show item's estimated values based on the proportions of possible disenchants";


		-- Section: Report Messages


		-- Section: Tooltip Messages
		FrmtBarkerPrice	= "Barker Price (%d%% margin)";
		FrmtPriceEach	= "(%s ea)";
		FrmtSuggestedPrice	= "Suggested price:";
		FrmtTotal	= "Total";
		FrmtWarnAuctNotLoaded	= "[Auctioneer not loaded, using cached prices]";
		FrmtWarnNoPrices	= "[No prices available]";
		FrmtWarnPriceUnavail	= "[Some prices unavailable]";
		["OpenBarkerWindow"]  = "Opens the trade barker window.";


		-- Section: User Interface
		BarkerOptionsHighestPriceForFactorTitle	= "PriceFactor Highest";
		BarkerOptionsHighestPriceForFactorTooltip	= "Enchants receive a score of zero for price priority at or above this value.";
		BarkerOptionsHighestProfitTitle	= "Highest Profit";
		BarkerOptionsHighestProfitTooltip	= "The highest total cash profit to make on an enchant.";
		BarkerOptionsLowestPriceTitle	= "Lowest Price";
		BarkerOptionsLowestPriceTooltip	= "The lowest cash price to quote for an enchant.";
		BarkerOptionsPricePriorityTitle	= "Overall Price Priority";
		BarkerOptionsPricePriorityTooltip	= "This sets how important pricing is to the overall priority for advertising.";
		BarkerOptionsPriceSweetspotTitle	= "PriceFactor SweetSpot";
		BarkerOptionsPriceSweetspotTooltip	= "This is used to prioritise enchants near this price for advertising.";
		BarkerOptionsProfitMarginTitle	= "Profit Margin";
		BarkerOptionsProfitMarginTooltip	= "The percentage profit to add to the base mats cost.";
		BarkerOptionsRandomFactorTitle	= "Random Factor";
		BarkerOptionsRandomFactorTooltip	= "The amount of randomness in the enchants chosen for the trade shout.";
		BarkerOptionsTab1Title	= "Profit and Price Priorities";
		
		BarkerOptionsItemsPriority = 'Overall Items Priority';
		BarkerOptionsItemsPriorityTooltip = 'This sets how important the item is to the overall priority for advertising.';
		BarkerOptions2HWeaponPriorityTooltip = 'The priority score for 2H weapon enchants.';
		BarkerOptionsAnyWeaponPriorityTooltip = 'The priority score for enchants to any weapon.';
		BarkerOptionsBracerPriorityTooltip = 'The priority score for bracer enchants.';
		BarkerOptionsGlovesPriorityTooltip = 'The priority score for glove enchants.';
		BarkerOptionsBootsPriorityTooltip = 'The priority score for boots enchants.';
		BarkerOptionsChestPriorityTooltip = 'The priority score for chest enchants.';
		BarkerOptionsCloakPriorityTooltip = 'The priority score for cloak enchants.';
		BarkerOptionsShieldPriorityTooltip = 'The priority score for shield enchants.';
		BarkerOptionsRingPriorityTooltip = 'The priority score for ring enchants.';
		
		BarkerOptionsStatsPriority = 'Overall Stats Priority';
		BarkerOptionsStatsPriorityTooltip = 'This sets how important the stat is to the overall priority for advertising.';
		BarkerOptionsIntellectPriority = 'Intellect';
		BarkerOptionsIntellectPriorityTooltip = 'The priority score for Intellect enchants.';
		BarkerOptionsStrengthPriority = 'Strength';
		BarkerOptionsStrengthPriorityTooltip = 'The priority score for Strength enchants.';
		BarkerOptionsAgilityPriority = 'Agility';
		BarkerOptionsAgilityPriorityTooltip = 'The priority score for Agility enchants.';
		BarkerOptionsStaminaPriority = 'Stamina';
		BarkerOptionsStaminaPriorityTooltip = 'The priority score for Stamina enchants.';
		BarkerOptionsSpiritPriority = 'Spirit';
		BarkerOptionsSpiritPriorityTooltip = 'The priority score for Spirit enchants.';
		BarkerOptionsArmorPriority = 'Armor';
		BarkerOptionsArmorPriorityTooltip = 'The priority score for armor enchants.';
		BarkerOptionsAllStatsPriority = 'All Stats';
		BarkerOptionsAllStatsPriorityTooltip = 'The priority score for enchants that increase all stats.';
		
		BarkerOptionsAllResistances = 'All Resistances';
		BarkerOptionsAllResistancesTooltip = 'The priority score for enchants that boost all resistances.';
		BarkerOptionsFireResistance = 'Fire Resistance';
		BarkerOptionsFireResistanceTooltip = 'The priority score for Fire Resistance enchants.';
		BarkerOptionsFrostResistance = 'Frost Resistance';
		BarkerOptionsFrostResistanceTooltip = 'The priority score for Frost Resistance enchants.';
		BarkerOptionsNatureResistance = 'Nature Resistance';
		BarkerOptionsNatureResistanceTooltip = 'The priority score for Nature Resistance enchants.';
		BarkerOptionsShadowResistance = 'Shadow Resistance';
		BarkerOptionsShadowResistanceTooltip = 'The priority score for Shadow Resistance enchants.';
		BarkerOptionsMana = 'Mana';
		BarkerOptionsManaTooltip = 'The priority score for Mana enchants.';
		BarkerOptionsHealth = 'Health';
		BarkerOptionsHealthTooltip = 'The priority score for Health enchants.';
		BarkerOptionsDamage = 'Damage';
		BarkerOptionsDamageTooltip = 'The priority score for Damage enchants.';
		BarkerOptionsDefense = 'Defense';
		BarkerOptionsDefenseTooltip = 'The priority score for Defense enchants.';
		BarkerOptionsOther = 'Other';
		BarkerOptionsOtherTooltip = 'The priority score for enchants such as skinning, mining, riding etc.';

	};

	esES = {

	};

	frFR = {

	};

	itIT = {

	};

	koKR = {

	};

	nlNL = {
	
	};

	zhCN = {

	};

	zhTW = {

	};

	ptPT = {
	};

	ruRU = {
	
	};

	trTR = {

	};
}