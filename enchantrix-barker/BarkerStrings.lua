--[[
	WARNING: This is a generated file.
	If you wish to perform or update localizations, please go to our Localizer website at:
	http://norganna.org/localizer/

	AddOn: EnchantrixBarker
	Revision: $Id$
	Version: <%version%> (<%codename%>)

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
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

EnchantrixBarkerLocalizations = {

	csCZ = {

		-- Section: Command Messages
		["BarkerEnxWindowNotOpen"]	= "Enchantrix: Není otevřené okno Enchanting. Toto okno musí být otevřené aby bylo možné použít Vyvolávače (Trade chat spam).";
		["BarkerNoEnchantsAvail"]	= "Enchantrix: Buďto nemáš žádné enchanty anebo nemáš dostatek materiálů.";

		-- Section: Commands
		["CmdBarker"]	= "vyvolavac";
		["CmdClear"]	= "smazat";
		["CmdDefault"]	= "vychozi";
		["CmdDisable"]	= "vypnout";
		["CmdFindBidauct"]	= "bidbroker";
		["CmdFindBidauctShort"]	= "bb";
		["CmdFindBuyauct"]	= "procent-mene";
		["CmdFindBuyauctShort"]	= "pm";
		["CmdHelp"]	= "pomoc";
		["CmdLocale"]	= "jazyk";
		["CmdOff"]	= "vyp";
		["CmdOn"]	= "zap";
		["CmdPrintin"]	= "zobraz-v";
		["CmdToggle"]	= "prepnout";
		["ShowCount"]	= "pocet";
		["ShowEmbed"]	= "integrace";
		["ShowGuessAuctioneerHsp"]	= "urcit-nuc";
		["ShowGuessAuctioneerMed"]	= "urcit-stred";
		["ShowTerse"]	= "strucne";
		["ShowValue"]	= "ohodnotit";

		-- Section: Game Constants
		["BarkerOpening"]	= "Prodám enchanty:";
		["OneLetterGold"]	= "g";
		["OneLetterSilver"]	= "s";
		["ShortDarnassus"]	= "Dar";
		["ShortIronForge"]	= "IF";
		["ShortOrgrimmar"]	= "Org";
		["ShortStormwind"]	= "SW";
		["ShortThunderBluff"]	= "TB";
		["ShortUndercity"]	= "UC";

		-- Section: Tooltip Messages
		["FrmtBarkerPrice"]	= "Cena do chatu (%d %% zisk)";
		["FrmtPriceEach"]	= "(%s za kus)";
		["FrmtSuggestedPrice"]	= "Doporučená cena:";
		["FrmtTotal"]	= "Celkem";
		["FrmtWarnAuctNotLoaded"]	= "[Auctioneer nebyl nahrán, budu používat uložené ceny]";
		["FrmtWarnNoPrices"]	= "[Ceny nejsou dostupne]";
		["FrmtWarnPriceUnavail"]	= "[Nektere ceny nedostupne]";

		-- Section: User Interface
		["BarkerOptionsHighestPriceForFactorTitle"]	= "Nejvyšší cena";
		["BarkerOptionsHighestPriceForFactorTooltip"]	= "Enchanty s cenou vyšší než tato hodnota dostanou pro Trade chat nulovou prioritu.";
		["BarkerOptionsHighestProfitTitle"]	= "Nejvyšší zisk";
		["BarkerOptionsHighestProfitTooltip"]	= "Nastaví nejvyšší možný zisk na enchantu (v penězích, ne procentech).";
		["BarkerOptionsLowestPriceTitle"]	= "Nejnižší cena";
		["BarkerOptionsLowestPriceTooltip"]	= "Nejnižší cena, která bude požadována za tento enchant v Trade chatu.";
		["BarkerOptionsPricePriorityTitle"]	= "Celková priorita ceny";
		["BarkerOptionsPricePriorityTooltip"]	= "Tohle nastavuje důležitost ceny pro celkovou prioritu enchantů v Trade chatu.";
		["BarkerOptionsPriceSweetspotTitle"]	= "Ideální cena";
		["BarkerOptionsPriceSweetspotTooltip"]	= "Tímhle se zvýší priorita enchantů, jejichž cena je blízko této hodnoty.";
		["BarkerOptionsProfitMarginTitle"]	= "Míra zisku";
		["BarkerOptionsProfitMarginTooltip"]	= "Procentní přirážka k nákladům na materiály.";
		["BarkerOptionsRandomFactorTitle"]	= "Náhodný faktor";
		["BarkerOptionsRandomFactorTooltip"]	= "Míra náhody ve výběru enchantů pro Trade chat.";
		["BarkerOptionsTab1Title"]	= "Priority zisku a cen";

	};

	daDK = {

		-- Section: Command Messages
		["BarkerEnxWindowNotOpen"]	= "Enchantrix: Enchantment vinduet er ikke åbent. Enchantments vinduet skal være åbent for at du kan anvende \"Barker\".";
		["BarkerNoEnchantsAvail"]	= "Enchantrix: Du har, enten ikke nogen enchants eller du mangler reagenter for at kunne lave dem.";

		-- Section: Commands
		["CmdBarker"]	= "Imbonitore";
		["CmdClear"]	= "slet";
		["CmdDefault"]	= "standard";
		["CmdDisable"]	= "deaktiver";
		["CmdFindBidauct"]	= "bidbroker";
		["CmdFindBidauctShort"]	= "bb";
		["CmdFindBuyauct"]	= "procentunder";
		["CmdFindBuyauctShort"]	= "pu";
		["CmdHelp"]	= "hjælp";
		["CmdLocale"]	= "sprog";
		["CmdOff"]	= "fra";
		["CmdOn"]	= "til";
		["CmdPrintin"]	= "skriv-i";
		["CmdToggle"]	= "skift";
		["ShowCount"]	= "optælling";
		["ShowEmbed"]	= "integreret";
		["ShowGuessAuctioneerHsp"]	= "evaluer-hsp";
		["ShowGuessAuctioneerMed"]	= "evaluer-middel";
		["ShowTerse"]	= "conciso";
		["ShowValue"]	= "Evaluer";

		-- Section: Game Constants
		["BarkerOpening"]	= "Enchants til salg:";
		["OneLetterGold"]	= "g";
		["OneLetterSilver"]	= "s";
		["ShortDarnassus"]	= "Dar";
		["ShortIronForge"]	= "IF";
		["ShortOrgrimmar"]	= "Org";
		["ShortStormwind"]	= "SW";
		["ShortThunderBluff"]	= "TB";
		["ShortUndercity"]	= "UC";

		-- Section: Tooltip Messages
		["FrmtBarkerPrice"]	= "Udråbspris (%d%% margen)";
		["FrmtPriceEach"]	= "(%s/stk.)";
		["FrmtSuggestedPrice"]	= "Anbefalet pris:";
		["FrmtTotal"]	= "I alt";
		["FrmtWarnAuctNotLoaded"]	= "[Auctioneer ikke indlæst, bruger priser fra cachen]";
		["FrmtWarnNoPrices"]	= "[Ingen priser er tilgængelige]";
		["FrmtWarnPriceUnavail"]	= "[Nogen af priserne er ikke tilgængelige]";

		-- Section: User Interface
		["BarkerOptionsHighestPriceForFactorTitle"]	= "Højeste prisfaktor";
		["BarkerOptionsHighestPriceForFactorTooltip"]	= "Enchentments får en score på nul ved en pris prioritet på eller over denne værdi.";
		["BarkerOptionsHighestProfitTitle"]	= "Højeste profit.";
		["BarkerOptionsHighestProfitTooltip"]	= "Højeste totale kontante profit på en enchant.";
		["BarkerOptionsLowestPriceTitle"]	= "Laveste pris";
		["BarkerOptionsLowestPriceTooltip"]	= "Laveste kontante udbudspris for en enchantment.";
		["BarkerOptionsPricePriorityTitle"]	= "Totale pris prioritet";
		["BarkerOptionsPricePriorityTooltip"]	= "Dette bestemmer hvor vigtig prissætning er for den generelle annoncering.";
		["BarkerOptionsPriceSweetspotTitle"]	= "Pirsfaktor SweetSpot";
		["BarkerOptionsPriceSweetspotTooltip"]	= "Dette bruges til at prioritere enchantments omkring denne pris til annoncering.";
		["BarkerOptionsProfitMarginTitle"]	= "Profit margin";
		["BarkerOptionsProfitMarginTooltip"]	= "Profit procent der skal ligges til materialernes købspris.";
		["BarkerOptionsRandomFactorTitle"]	= "Tilfældig faktor";
		["BarkerOptionsRandomFactorTooltip"]	= "Graden af tilfældighed i enchantments der reklameres for i \"trade\" kanalen.";
		["BarkerOptionsTab1Title"]	= "Profit og pris prioritering";

	};

	deDE = {

		-- Section: Command Messages
		["BarkerEnxWindowNotOpen"]	= "Das Enchantrix-Fenster ist nicht geöffnet. Das Enchantrix-Fenster muss geöffnet sein um Barker nutzen zu können.";
		["BarkerNoEnchantsAvail"]	= "Enchantrix: Du hast entweder keine Verzauberungen oder zu wenig Reagenzien um welche herzustellen.";

		-- Section: Commands
		["CmdBarker"]	= "barker";
		["CmdClear"]	= "clear";
		["CmdDefault"]	= "default";
		["CmdDisable"]	= "disable";
		["CmdFindBidauct"]	= "bidbroker";
		["CmdFindBidauctShort"]	= "bb";
		["CmdFindBuyauct"]	= "percentless";
		["CmdFindBuyauctShort"]	= "pl";
		["CmdHelp"]	= "help";
		["CmdLocale"]	= "locale";
		["CmdOff"]	= "off";
		["CmdOn"]	= "on";
		["CmdPrintin"]	= "print-in";
		["CmdToggle"]	= "toggle";
		["ShowCount"]	= "counts";
		["ShowEmbed"]	= "embed";
		["ShowGuessAuctioneerHsp"]	= "valuate-hsp";
		["ShowGuessAuctioneerMed"]	= "valuate-median";
		["ShowTerse"]	= "terse";
		["ShowValue"]	= "valuate";

		-- Section: Game Constants
		["AnyWeapon"]	= "Alle Waffen";
		["BarkerOpening"]	= "Verkaufe Verzauberungen:";
		["Boots"]	= "Stiefel";
		["Bracer"]	= "Armschiene";
		["Chest"]	= "Brust";
		["Cloak"]	= "Umhang";
		["Darnassus"]	= "Darnassus";
		["EnchSearchAgility"]	= "beweglichkeit";
		["EnchSearchAllResistance1"]	= "Widerstand gegen alle Schulen von Magie";
		["EnchSearchAllResistance2"]	= "Widerstand gegen alle Magieschulen";
		["EnchSearchAllResistance3"]	= "alle widerstände";
		["EnchSearchAllStats"]	= "alle werte";
		["EnchSearchArmor"]	= "rüstung";
		["EnchSearchBattlemaster"]	= "heilt nahe stehende Gruppenmitglieder";
		["EnchSearchBeastslayer"]	= "Schaden gegen Wildtiere";
		["EnchSearchBoarSpeed"]	= "Bewegungsgeschwindigkeits Erhöhung und [0-9]+ Ausdauer";
		["EnchSearchCatSwiftness"]	= "Bewegungsgeschwindigkeits Erhöhung und [0-9]+ Beweglichkeit";
		["EnchSearchCrusader"]	= "heilt für [0-9]+ [0-9]+ und erhöht Stärke";
		["EnchSearchDamage1"]	= "? Punkte Schaden";
		["EnchSearchDamage2"]	= "\+[0-9]+ Schaden";
		["EnchSearchDefense"]	= "verteidigung";
		["EnchSearchDMGAbsorption"]	= "absorption";
		["EnchSearchFireRes"]	= "feuerwiderstand";
		["EnchSearchFrostRes"]	= "frostwiderstand";
		["EnchSearchHealth"]	= "gesundheit";
		["EnchSearchIntellect"]	= "intelligenz";
		["EnchSearchMana"]	= "mana";
		["EnchSearchMongoose"]	= "erhöht Beweglichkeit um [0-9]+ und Angriffsgeschwindigkeit";
		["EnchSearchNatureRes"]	= "naturwiderstand";
		["EnchSearchResFire"]	= "Feuerwiderstand";
		["EnchSearchResShadow"]	= "Schattenwiderstand";
		["EnchSearchSoulfrost"]	= "Frost- und Schattenzauber";
		["EnchSearchSpellPower1"]	= "Schaden von Zaubersprüchen";
		["EnchSearchSpellPower2"]	= "Schaden von Zaubersprüchen";
		["EnchSearchSpellPower3"]	= "durch Zauber und magische Effekte verursachten Schaden und Heilung";
		["EnchSearchSpellsurge"]	= "bei allen Gruppenmitgliedern 10 Sekunden lang 100 Mana wiederherstellen";
		["EnchSearchSpirit"]	= "willen";
		["EnchSearchStamina"]	= "ausdauer";
		["EnchSearchStrength"]	= "stärke";
		["EnchSearchSunfire"]	= "Feuer- und Arkanzauber";
		["EnchSearchVitality"]	= "alle 5 Sek. 4 Gesundheit und Mana wiederherstellen";
		["Gloves"]	= "Handschuhe";
		["Ironforge"]	= "Eisenschmiede";
		["OneLetterGold"]	= "G";
		["OneLetterSilver"]	= "S";
		["Orgrimmar"]	= "Orgrimmar";
		["Ring"]	= "Ring";
		["Shattrath"]	= "Shattrath";
		["Shield"]	= "Schild";
		["ShortDarnassus"]	= "Dar";
		["ShortExodar"]	= "Exo";
		["ShortIronForge"]	= "IF";
		["ShortOrgrimmar"]	= "Org";
		["ShortShattrath"]	= "Sha";
		["ShortSilvermoon"]	= "SM";
		["ShortStormwind"]	= "SW";
		["ShortThunderBluff"]	= "TB";
		["ShortUndercity"]	= "UC";
		["SilvermoonCity"]	= "Silbermond";
		["StormwindCity"]	= "Sturmwind";
		["TheExodar"]	= "Die Exodar";
		["ThunderBluff"]	= "Donnerfels";
		["TradeChannel"]	= "Handel - Hauptstädte";
		["TwoHandWeapon"]	= "Zweihandwaffe";
		["Undercity"]	= "Unterstadt";
		["Weapon"]	= "Waffe";

		-- Section: Generic Messages
		["BarkerLoaded"]	= "Enchantrix Barker geladen...";
		["BarkerNotTradeZone"]	= "Enchantrix Barker: Du bist in keiner Handelszone.";

		-- Section: Generic Strings
		["AGI"]	= "BEW";
		["AllStats"]	= "alle Werte";
		["Crusader"]	= "Kreuzfahrer";
		["DEF"]	= "VERT";
		["DMG"]	= "SCHA";
		["DMGAbsorb"]	= "SCHA absorb.";
		["FireRes"]	= "Feuerresi";
		["FrostRes"]	= "Frostresi";
		["INT"]	= "INT";
		["NatureRes"]	= "Naturresi";
		["ShadowRes"]	= "Schattenresi";
		["ShortAllRes"]	= "alle Resi";
		["ShortArmor"]	= "Rüstung";
		["ShortBattlemaster"]	= "Schlachtmeister";
		["ShortBeastslayer"]	= "Wildtier";
		["ShortBoarSpeed"]	= "Ebersflinkheit";
		["ShortCatSwiftness"]	= "Katzenschnelligkeit";
		["ShortHealth"]	= "GES";
		["ShortMana"]	= "Mana";
		["ShortMongoose"]	= "Mungo";
		["ShortSoulfrost"]	= "Seelenfrost";
		["ShortSpellPower"]	= "Zauber";
		["ShortSpellSurge"]	= "Zauberflut";
		["ShortSunfire"]	= "Sonnenfeuer";
		["ShortVitality"]	= "BEW";
		["SPI"]	= "WIL";
		["STA"]	= "AUS";
		["STR"]	= "STÄ";

		-- Section: Tooltip Messages
		["FrmtBarkerPrice"]	= "Barker Preis (%d%% Gewinn)";
		["FrmtPriceEach"]	= "(%s/stk)";
		["FrmtSuggestedPrice"]	= "vorgeschlagener Preis";
		["FrmtTotal"]	= "Gesamtsumme";
		["FrmtWarnAuctNotLoaded"]	= "Auktionstool nicht geladen, es werden gespeicherte Preise benutzt";
		["FrmtWarnNoPrices"]	= "Keine Preise verfügbar";
		["FrmtWarnPriceUnavail"]	= "Einige Preise nicht verfügbar";
		["OpenBarkerWindow"]	= "Öffnet das Barker Handelsfenster";

		-- Section: User Interface
		["BarkerOptions2HWeaponPriorityTooltip"]	= "Die Prioritätsstufe für Zweihandwaffenverzauberungen.";
		["BarkerOptionsAgilityPriority"]	= "Beweglichkeit";
		["BarkerOptionsAgilityPriorityTooltip"]	= "Die Prioritätsstufe für Beweglichkeitsverzauberungen.";
		["BarkerOptionsAllResistances"]	= "Alle Widerstände";
		["BarkerOptionsAllResistancesTooltip"]	= "Die Prioritätsstufe für Verzauberungen auf alle Widerstände.";
		["BarkerOptionsAllStatsPriority"]	= "Alle Werte";
		["BarkerOptionsAllStatsPriorityTooltip"]	= "Die Prioritätsstufe für Verzauberungen, welche alle Werte erhöht.";
		["BarkerOptionsAnyWeaponPriorityTooltip"]	= "Die Prioritätsstufe für Waffenverzauberungen.";
		["BarkerOptionsArmorPriority"]	= "Rüstung";
		["BarkerOptionsArmorPriorityTooltip"]	= "Die Prioritätsstufe für Rüstungsverzauberungen.";
		["BarkerOptionsBootsPriorityTooltip"]	= "Die Prioritätsstufe für Stiefelverzauberungen.";
		["BarkerOptionsBracerPriorityTooltip"]	= "Die Prioritätsstufe für Armschienenverzauberungen.";
		["BarkerOptionsChestPriorityTooltip"]	= "Die Prioritätsstufe für Brustverzauberungen.";
		["BarkerOptionsCloakPriorityTooltip"]	= "Die Prioritätsstufe für Umhangsverzauberungen.";
		["BarkerOptionsDamage"]	= "Schaden";
		["BarkerOptionsDamageTooltip"]	= "Die Prioritätsstufe für Schadensverzauberungen.";
		["BarkerOptionsDefense"]	= "Verteidigung";
		["BarkerOptionsDefenseTooltip"]	= "Die Prioritätsstufe für Verteidigungsverzauberungen.";
		["BarkerOptionsFireResistance"]	= "Feuerwiderstand";
		["BarkerOptionsFireResistanceTooltip"]	= "Die Prioritätsstufe für Feuerwiderstandsverzauberungen.";
		["BarkerOptionsFrostResistance"]	= "Frostwiderstand";
		["BarkerOptionsFrostResistanceTooltip"]	= "Die Prioritätsstufe für Frostwiderstandsverzauberungen.";
		["BarkerOptionsGlovesPriorityTooltip"]	= "Die Prioritätsstufe für Handschuhverzauberungen.";
		["BarkerOptionsHealth"]	= "Gesundheit";
		["BarkerOptionsHealthTooltip"]	= "Die Prioritätsstufe für Gesundheitsverzauberungen.";
		["BarkerOptionsHighestPriceForFactorTitle"]	= "Höchster Preisfaktor";
		["BarkerOptionsHighestPriceForFactorTooltip"]	= "Entzauberungen erhalten einen Score von null für die Preispriorität, auf diesem bzw. über diesem Wert.";
		["BarkerOptionsHighestProfitTitle"]	= "Höchster Gewinn";
		["BarkerOptionsHighestProfitTooltip"]	= "Höchster machbarer Gewinn für eine Entzauberung.";
		["BarkerOptionsIntellectPriority"]	= "Intelligenz";
		["BarkerOptionsIntellectPriorityTooltip"]	= "Die Prioritätsstufe für Intelligenzverzauberungen.";
		["BarkerOptionsItemsPriority"]	= "Allgemeine Gegenstandspriorität";
		["BarkerOptionsItemsPriorityTooltip"]	= "Dieses stellt ein, wie wichtig der Gegenstand im Vergleich zur gesamten Priorität für das Bewerben ist.";
		["BarkerOptionsLowestPriceTitle"]	= "Niedrigster Preis";
		["BarkerOptionsLowestPriceTooltip"]	= "Niedrigster Angebotspreis für eine Entzauberung. ";
		["BarkerOptionsMana"]	= "Mana";
		["BarkerOptionsManaTooltip"]	= "Die Prioritätsstufe für Manaverzauberungen.";
		["BarkerOptionsNatureResistance"]	= "Naturwiderstand";
		["BarkerOptionsNatureResistanceTooltip"]	= "Die Prioritätsstufe für Naturwiderstandsverzauberungen.";
		["BarkerOptionsOther"]	= "Andere";
		["BarkerOptionsOtherTooltip"]	= "Die Prioritätsstufe für Verzauberungen für Kürschnern, Bergbau, Reiten etc.";
		["BarkerOptionsPricePriorityTitle"]	= "Gesamt-Preispriorität";
		["BarkerOptionsPricePriorityTooltip"]	= "Legt die Wichtigkeit der Preisermittlung innerhalb der Gesamtpriorität der Werbemaßnahmen fest.";
		["BarkerOptionsPriceSweetspotTitle"]	= "Preisfaktor SweetSpot";
		["BarkerOptionsPriceSweetspotTooltip"]	= "Preisbereich der bevorzugten Entzauberungen für Werbemaßnahmen.";
		["BarkerOptionsProfitMarginTitle"]	= "Gewinnspanne";
		["BarkerOptionsProfitMarginTooltip"]	= "Der prozentuale Gewinnanteil, welcher zu den Standardkosten hinzuaddiert werden soll.";
		["BarkerOptionsRandomFactorTitle"]	= "Zufallsfaktor";
		["BarkerOptionsRandomFactorTooltip"]	= "Legt die Größe des Zufallsfaktors, in welchem Entzauberungen für die Handelsausrufe ausgewählt werden fest.";
		["BarkerOptionsRingPriorityTooltip"]	= "Die Prioritätsstufe für Ringverzauberungen.";
		["BarkerOptionsShadowResistance"]	= "Schattenwiderstand";
		["BarkerOptionsShadowResistanceTooltip"]	= "Die Prioritätsstufe für Schattenwiderstandsverzauberungen.";
		["BarkerOptionsShieldPriorityTooltip"]	= "Die Prioritätsstufe für Schildverzauberungen.";
		["BarkerOptionsSpiritPriority"]	= "Willenskraft";
		["BarkerOptionsSpiritPriorityTooltip"]	= "Die Prioritätsstufe für Willenskraftverzauberungen.";
		["BarkerOptionsStaminaPriority"]	= "Ausdauer";
		["BarkerOptionsStaminaPriorityTooltip"]	= "Die Prioritätsstufe für Ausdauerverzauberungen.";
		["BarkerOptionsStatsPriority"]	= "Allgemeine Wertepriorität";
		["BarkerOptionsStatsPriorityTooltip"]	= "Legt die Wichtigkeit der Werte innerhalb der Gesamtpriorität für Werbungen fest.";
		["BarkerOptionsStrengthPriority"]	= "Stärke";
		["BarkerOptionsStrengthPriorityTooltip"]	= "Die Prioritätsstufe für Stärkeverzauberungen.";
		["BarkerOptionsTab1Title"]	= "Gewinn und Preisprioritäten";

	};

	enUS = {

		-- Section: Command Messages
		["BarkerEnxWindowNotOpen"]	= "Enchantrix: The enchant window is not open. The enchanting window must be open in order to use the barker.";
		["BarkerNoEnchantsAvail"]	= "Enchantrix: You either don't have any enchants or don't have the reagents to make them.";

		-- Section: Commands
		["CmdBarker"]	= "barker";
		["CmdClear"]	= "clear";
		["CmdDefault"]	= "default";
		["CmdDisable"]	= "disable";
		["CmdFindBidauct"]	= "bidbroker";
		["CmdFindBidauctShort"]	= "bb";
		["CmdFindBuyauct"]	= "percentless";
		["CmdFindBuyauctShort"]	= "pl";
		["CmdHelp"]	= "help";
		["CmdLocale"]	= "locale";
		["CmdOff"]	= "off";
		["CmdOn"]	= "on";
		["CmdPrintin"]	= "print-in";
		["CmdToggle"]	= "toggle";
		["ShowCount"]	= "counts";
		["ShowEmbed"]	= "embed";
		["ShowGuessAuctioneerHsp"]	= "valuate-hsp";
		["ShowGuessAuctioneerMed"]	= "valuate-median";
		["ShowTerse"]	= "terse";
		["ShowValue"]	= "valuate";

		-- Section: Game Constants
		["AnyWeapon"]	= "Any Weapon";
		["BarkerOpening"]	= "Selling Enchants:";
		["Boots"]	= "Boots";
		["Bracer"]	= "Bracer";
		["Chest"]	= "Chest";
		["Cloak"]	= "Cloak";
		["Darnassus"]	= "Darnassus";
		["EnchSearchAgility"]	= "agility";
		["EnchSearchAllResistance1"]	= "resistance to all schools of magic";
		["EnchSearchAllResistance2"]	= "resistance to all magic schools";
		["EnchSearchAllResistance3"]	= "all resistances";
		["EnchSearchAllStats"]	= "all stats";
		["EnchSearchArmor"]	= "armor";
		["EnchSearchBattlemaster"]	= "heal nearby party members";
		["EnchSearchBeastslayer"]	= "damage to beasts";
		["EnchSearchBoarSpeed"]	= "movement speed increase and [0-9]+ Stamina";
		["EnchSearchCatSwiftness"]	= "movement speed increase and [0-9]+ Agility";
		["EnchSearchCrusader"]	= "heals for [0-9]+ to [0-9]+ and increases strength";
		["EnchSearchDamage1"]	= "points? of damage";
		["EnchSearchDamage2"]	= "\+[0-9]+ damage";
		["EnchSearchDefense"]	= "defense";
		["EnchSearchDMGAbsorption"]	= "absorption";
		["EnchSearchFireRes"]	= "fire resistance";
		["EnchSearchFrostRes"]	= "frost resistance";
		["EnchSearchHealth"]	= "health";
		["EnchSearchIntellect"]	= "intellect";
		["EnchSearchMana"]	= "mana";
		["EnchSearchManaPerFive"]	= "mana every 5 seconds";
		["EnchSearchMongoose"]	= "increase agility by [0-9]+ and attack speed";
		["EnchSearchNatureRes"]	= "nature resistance";
		["EnchSearchResFire"]	= "resistance to fire";
		["EnchSearchResShadow"]	= "resistance to shadow";
		["EnchSearchSoulfrost"]	= "frost and shadow spells";
		["EnchSearchSpellPower1"]	= "damage to spells";
		["EnchSearchSpellPower2"]	= "damage to all spells";
		["EnchSearchSpellPower3"]	= "spell damage";
		["EnchSearchSpellsurge"]	= "restore [0-9]+ mana to all party members";
		["EnchSearchSpirit"]	= "spirit";
		["EnchSearchStamina"]	= "stamina";
		["EnchSearchStrength"]	= "strength";
		["EnchSearchSunfire"]	= "fire and arcane spells";
		["EnchSearchVitality"]	= "restore [0-9]+ health and mana";
		["Gloves"]	= "Gloves";
		["Ironforge"]	= "City of Ironforge";
		["OneLetterGold"]	= "g";
		["OneLetterSilver"]	= "s";
		["Orgrimmar"]	= "Orgrimmar";
		["Ring"]	= "Ring";
		["Shattrath"]	= "Shattrath City";
		["Shield"]	= "Shield";
		["ShortDarnassus"]	= "Dar";
		["ShortExodar"]	= "Exo";
		["ShortIronForge"]	= "IF";
		["ShortOrgrimmar"]	= "Org";
		["ShortShattrath"]	= "Sha";
		["ShortSilvermoon"]	= "SmC";
		["ShortStormwind"]	= "SW";
		["ShortThunderBluff"]	= "TB";
		["ShortUndercity"]	= "UC";
		["SilvermoonCity"]	= "Silvermoon City";
		["StormwindCity"]	= "Stormwind City";
		["TheExodar"]	= "The Exodar";
		["ThunderBluff"]	= "Thunder Bluff";
		["TradeChannel"]	= "Trade - City";
		["TwoHandWeapon"]	= "2H Weapon";
		["Undercity"]	= "Undercity";
		["Weapon"]	= "Weapon";

		-- Section: Generic Messages
		["BarkerLoaded"]	= "Enchantrix Barker Loaded...";
		["BarkerNotTradeZone"]	= "Enchantrix Barker: You aren't in a trade zone.";

		-- Section: Generic Strings
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
		["ShortBattlemaster"]	= "Battlemaster";
		["ShortBeastslayer"]	= "Beast";
		["ShortBoarSpeed"]	= "Boar Speed";
		["ShortCatSwiftness"]	= "Cat Swiftness";
		["ShortHealth"]	= "health";
		["ShortMana"]	= "mana";
		["ShortManaPerFive"]	= "mana/5sec";
		["ShortMongoose"]	= "Mongoose";
		["ShortSoulfrost"]	= "Soulfrost";
		["ShortSpellPower"]	= "spell";
		["ShortSpellSurge"]	= "Spellsurge";
		["ShortSunfire"]	= "Sunfire";
		["ShortVitality"]	= "Vitality";
		["SPI"]	= "SPI";
		["STA"]	= "STA";
		["STR"]	= "STR";

		-- Section: Tooltip Messages
		["FrmtBarkerPrice"]	= "Barker Price (%d%% margin)";
		["FrmtPriceEach"]	= "(%s ea)";
		["FrmtSuggestedPrice"]	= "Suggested price:";
		["FrmtTotal"]	= "Total";
		["FrmtWarnAuctNotLoaded"]	= "[Auctioneer not loaded, using cached prices]";
		["FrmtWarnNoPrices"]	= "[No prices available]";
		["FrmtWarnPriceUnavail"]	= "[Some prices unavailable]";
		["OpenBarkerWindow"]	= "Opens the trade barker window.";

		-- Section: User Interface
		["BarkerOptions2HWeaponPriorityTooltip"]	= "The priority score for 2H weapon enchants.";
		["BarkerOptionsAgilityPriority"]	= "Agility";
		["BarkerOptionsAgilityPriorityTooltip"]	= "The priority score for Agility enchants.";
		["BarkerOptionsAllResistances"]	= "All Resistances";
		["BarkerOptionsAllResistancesTooltip"]	= "The priority score for enchants that boost all resistances.";
		["BarkerOptionsAllStatsPriority"]	= "All Stats";
		["BarkerOptionsAllStatsPriorityTooltip"]	= "The priority score for enchants that increase all stats.";
		["BarkerOptionsAnyWeaponPriorityTooltip"]	= "The priority score for enchants to any weapon.";
		["BarkerOptionsArmorPriority"]	= "Armor";
		["BarkerOptionsArmorPriorityTooltip"]	= "The priority score for armor enchants.";
		["BarkerOptionsBootsPriorityTooltip"]	= "The priority score for boots enchants.";
		["BarkerOptionsBracerPriorityTooltip"]	= "The priority score for bracer enchants.";
		["BarkerOptionsChestPriorityTooltip"]	= "The priority score for chest enchants.";
		["BarkerOptionsCloakPriorityTooltip"]	= "The priority score for cloak enchants.";
		["BarkerOptionsDamage"]	= "Damage";
		["BarkerOptionsDamageTooltip"]	= "The priority score for Damage enchants.";
		["BarkerOptionsDefense"]	= "Defense";
		["BarkerOptionsDefenseTooltip"]	= "The priority score for Defense enchants.";
		["BarkerOptionsFireResistance"]	= "Fire Resistance";
		["BarkerOptionsFireResistanceTooltip"]	= "The priority score for Fire Resistance enchants.";
		["BarkerOptionsFrostResistance"]	= "Frost Resistance";
		["BarkerOptionsFrostResistanceTooltip"]	= "The priority score for Frost Resistance enchants.";
		["BarkerOptionsGlovesPriorityTooltip"]	= "The priority score for glove enchants.";
		["BarkerOptionsHealth"]	= "Health";
		["BarkerOptionsHealthTooltip"]	= "The priority score for Health enchants.";
		["BarkerOptionsHighestPriceForFactorTitle"]	= "PriceFactor Highest";
		["BarkerOptionsHighestPriceForFactorTooltip"]	= "Enchants receive a score of zero for price priority at or above this value.";
		["BarkerOptionsHighestProfitTitle"]	= "Highest Profit";
		["BarkerOptionsHighestProfitTooltip"]	= "The highest total cash profit to make on an enchant.";
		["BarkerOptionsIntellectPriority"]	= "Intellect";
		["BarkerOptionsIntellectPriorityTooltip"]	= "The priority score for Intellect enchants.";
		["BarkerOptionsItemsPriority"]	= "Overall Items Priority";
		["BarkerOptionsItemsPriorityTooltip"]	= "This sets how important the item is to the overall priority for advertising.";
		["BarkerOptionsLowestPriceTitle"]	= "Lowest Price";
		["BarkerOptionsLowestPriceTooltip"]	= "The lowest cash price to quote for an enchant.";
		["BarkerOptionsMana"]	= "Mana";
		["BarkerOptionsManaTooltip"]	= "The priority score for Mana enchants.";
		["BarkerOptionsNatureResistance"]	= "Nature Resistance";
		["BarkerOptionsNatureResistanceTooltip"]	= "The priority score for Nature Resistance enchants.";
		["BarkerOptionsOther"]	= "Other";
		["BarkerOptionsOtherTooltip"]	= "The priority score for enchants such as skinning, mining, riding etc.";
		["BarkerOptionsPricePriorityTitle"]	= "Overall Price Priority";
		["BarkerOptionsPricePriorityTooltip"]	= "This sets how important pricing is to the overall priority for advertising.";
		["BarkerOptionsPriceSweetspotTitle"]	= "PriceFactor SweetSpot";
		["BarkerOptionsPriceSweetspotTooltip"]	= "This is used to prioritise enchants near this price for advertising.";
		["BarkerOptionsProfitMarginTitle"]	= "Profit Margin";
		["BarkerOptionsProfitMarginTooltip"]	= "The percentage profit to add to the base mats cost.";
		["BarkerOptionsRandomFactorTitle"]	= "Random Factor";
		["BarkerOptionsRandomFactorTooltip"]	= "The amount of randomness in the enchants chosen for the trade shout.";
		["BarkerOptionsRingPriorityTooltip"]	= "The priority score for ring enchants.";
		["BarkerOptionsShadowResistance"]	= "Shadow Resistance";
		["BarkerOptionsShadowResistanceTooltip"]	= "The priority score for Shadow Resistance enchants.";
		["BarkerOptionsShieldPriorityTooltip"]	= "The priority score for shield enchants.";
		["BarkerOptionsSpiritPriority"]	= "Spirit";
		["BarkerOptionsSpiritPriorityTooltip"]	= "The priority score for Spirit enchants.";
		["BarkerOptionsStaminaPriority"]	= "Stamina";
		["BarkerOptionsStaminaPriorityTooltip"]	= "The priority score for Stamina enchants.";
		["BarkerOptionsStatsPriority"]	= "Overall Stats Priority";
		["BarkerOptionsStatsPriorityTooltip"]	= "This sets how important the stat is to the overall priority for advertising.";
		["BarkerOptionsStrengthPriority"]	= "Strength";
		["BarkerOptionsStrengthPriorityTooltip"]	= "The priority score for Strength enchants.";
		["BarkerOptionsTab1Title"]	= "Profit and Price Priorities";

	};

	esES = {

		-- Section: Command Messages
		["BarkerEnxWindowNotOpen"]	= "Enchantrix: La ventana de encantamientos no está abierta. La ventana de encantamientos debe estar abierta para utilizar el pregonero.";
		["BarkerNoEnchantsAvail"]	= "Enchantrix: No tienes ningún encantamiento o los componentes para crearlos.";

		-- Section: Commands
		["CmdBarker"]	= "pregonero";
		["CmdClear"]	= "borrar";
		["CmdDefault"]	= "original";
		["CmdDisable"]	= "deshabilitar";
		["CmdFindBidauct"]	= "corredorofertas";
		["CmdFindBidauctShort"]	= "co";
		["CmdFindBuyauct"]	= "porcientomenos";
		["CmdFindBuyauctShort"]	= "pm";
		["CmdHelp"]	= "ayuda";
		["CmdLocale"]	= "localidad";
		["CmdOff"]	= "apagado";
		["CmdOn"]	= "prendido";
		["CmdPrintin"]	= "imprimir-en";
		["CmdToggle"]	= "invertir";
		["ShowCount"]	= "conteo";
		["ShowEmbed"]	= "integrar";
		["ShowGuessAuctioneerHsp"]	= "valorizar-pmv";
		["ShowGuessAuctioneerMed"]	= "valorizar-mediano";
		["ShowTerse"]	= "conciso";
		["ShowValue"]	= "valorizar";

		-- Section: Game Constants
		["BarkerOpening"]	= "Encanto:";
		["OneLetterGold"]	= "o";
		["OneLetterSilver"]	= "p";
		["ShortDarnassus"]	= "Dar";
		["ShortIronForge"]	= "FJ";
		["ShortOrgrimmar"]	= "Org";
		["ShortShattrath"]	= "Sha";
		["ShortStormwind"]	= "VT";
		["ShortThunderBluff"]	= "CdT";
		["ShortUndercity"]	= "E";

		-- Section: Tooltip Messages
		["FrmtBarkerPrice"]	= "Precio de Pregonero (margen de %d%%)";
		["FrmtPriceEach"]	= "(%s c/u)";
		["FrmtSuggestedPrice"]	= "Precio Sugerido:";
		["FrmtTotal"]	= "Total";
		["FrmtWarnAuctNotLoaded"]	= "[Auctioneer no se ha cargado, usando los precios guardados]";
		["FrmtWarnNoPrices"]	= "[No hay precios disponibles]";
		["FrmtWarnPriceUnavail"]	= "[Algunos precios no están disponibles]";

		-- Section: User Interface
		["BarkerOptionsHighestPriceForFactorTitle"]	= "Factor Precio Más Alto";
		["BarkerOptionsHighestPriceForFactorTooltip"]	= "Los encantamientos reciben una puntuación de cero en la prioridad de precio cuando tienen este precio o superior.";
		["BarkerOptionsHighestProfitTitle"]	= "Beneficio Más Alto";
		["BarkerOptionsHighestProfitTooltip"]	= "El beneficio máximo a conseguir en un encantamiento";
		["BarkerOptionsLowestPriceTitle"]	= "Precio Más Bajo";
		["BarkerOptionsLowestPriceTooltip"]	= "El precio mínimo para mencionar un encantamiento.";
		["BarkerOptionsPricePriorityTitle"]	= "Prioridad Global de Precio";
		["BarkerOptionsPricePriorityTooltip"]	= "Establece cuán importante es el precio en la prioridad global para ser anunciado";
		["BarkerOptionsPriceSweetspotTitle"]	= "Mejor Punto del Factor Precio";
		["BarkerOptionsPriceSweetspotTooltip"]	= "Los encantamientos que están cerca de este precio tendrán prioridad a la hora de anunciarse.";
		["BarkerOptionsProfitMarginTitle"]	= "Margen de Beneficio";
		["BarkerOptionsProfitMarginTooltip"]	= "El porcentaje de beneficio que se añade al coste base de los materiales";
		["BarkerOptionsRandomFactorTitle"]	= "Factor Aleatorio";
		["BarkerOptionsRandomFactorTooltip"]	= "La cantidad de aleatoriedad que se aplica a la hora de elegir qué encantamientos se anuncian.";
		["BarkerOptionsTab1Title"]	= "Prioridades de Beneficio y Precio";

	};

	frFR = {

		-- Section: Command Messages
		["BarkerEnxWindowNotOpen"]	= "Enchantrix : La fenêtre d'enchantement n'est pas ouverte. Elle doit l'être pour utiliser le Trader.";
		["BarkerNoEnchantsAvail"]	= "Enchantrix : Vous n'avez aucun enchantement ou vous ne disposez pas des ingrédients nécessaires pour les faire.";

		-- Section: Commands
		["CmdBarker"]	= "trader";
		["CmdClear"]	= "effacer";
		["CmdDefault"]	= "par défaut";
		["CmdDisable"]	= "désactiver";
		["CmdFindBidauct"]	= "agent-enchere";
		["CmdFindBidauctShort"]	= "ae";
		["CmdFindBuyauct"]	= "sans-pourcentage";
		["CmdFindBuyauctShort"]	= "pl";
		["CmdHelp"]	= "aide";
		["CmdLocale"]	= "langue";
		["CmdOff"]	= "arret";
		["CmdOn"]	= "marche";
		["CmdPrintin"]	= "afficher-dans";
		["CmdToggle"]	= "activer-desactiver";
		["ShowCount"]	= "comptes";
		["ShowEmbed"]	= "integrer";
		["ShowGuessAuctioneerHsp"]	= "evaluer-pvm";
		["ShowGuessAuctioneerMed"]	= "evaluer-median";
		["ShowTerse"]	= "concis";
		["ShowValue"]	= "evaluer";

		-- Section: Game Constants
		["BarkerOpening"]	= "Vends enchantements :";
		["OneLetterGold"]	= "po";
		["OneLetterSilver"]	= "pa";
		["ShortDarnassus"]	= "Darna";
		["ShortIronForge"]	= "IF";
		["ShortOrgrimmar"]	= "Orgri";
		["ShortShattrath"]	= "Sha";
		["ShortStormwind"]	= "SW";
		["ShortThunderBluff"]	= "TB";
		["ShortUndercity"]	= "UC";

		-- Section: Tooltip Messages
		["FrmtBarkerPrice"]	= "Prix Trader (marge : %d%%)";
		["FrmtPriceEach"]	= "(%s l'unité)";
		["FrmtSuggestedPrice"]	= "Prix suggéré:";
		["FrmtTotal"]	= "Total";
		["FrmtWarnAuctNotLoaded"]	= "[Auctioneer non chargé, utilisation du prix en cache]";
		["FrmtWarnNoPrices"]	= "[Aucun prix disponible]";
		["FrmtWarnPriceUnavail"]	= "[Quelques prix indisponibles]";

		-- Section: User Interface
		["BarkerOptionsHighestPriceForFactorTitle"]	= "Plus haut facteur prix";
		["BarkerOptionsHighestPriceForFactorTooltip"]	= "Les enchantements ont un score de zéro pour les priorités de prix égales ou supérieures à cette valeur";
		["BarkerOptionsHighestProfitTitle"]	= "Bénéfice le plus élevé";
		["BarkerOptionsHighestProfitTooltip"]	= "Le profit maximal par enchantement.";
		["BarkerOptionsLowestPriceTitle"]	= "Plus bas Prix";
		["BarkerOptionsLowestPriceTooltip"]	= "Le prix minimal à annoncer par enchantement.";
		["BarkerOptionsPricePriorityTitle"]	= "Priorité de prix générale";
		["BarkerOptionsPricePriorityTooltip"]	= "Spécifie l'importance du prix lors des annonces.";
		["BarkerOptionsPriceSweetspotTitle"]	= "Sweetspot pour le facteur prix";
		["BarkerOptionsPriceSweetspotTooltip"]	= "Ceci est utilisé pour donner la priorité aux enchantements proches de ce prix pour la publicité";
		["BarkerOptionsProfitMarginTitle"]	= "Marge bénéficiaire";
		["BarkerOptionsProfitMarginTooltip"]	= "Le pourcentage de bénéfice à ajouter au coût des matériaux de base";
		["BarkerOptionsRandomFactorTitle"]	= "Facteur aléatoire";
		["BarkerOptionsRandomFactorTooltip"]	= "La quantité de hasard dans les enchantements choisis pour les cris de commerce";
		["BarkerOptionsTab1Title"]	= "Priorités de bénéfice et de prix";

	};

	itIT = {

		-- Section: Command Messages
		["BarkerEnxWindowNotOpen"]	= "Enchantrix: la finestra per gli enchantments non è aperta. La finestra degli enchantments deve essere aperta per usare il barker";
		["BarkerNoEnchantsAvail"]	= "Enchantrix: non hai nessun enchantment o non hai ireagenti per poterlo fare";

		-- Section: Commands
		["CmdBarker"]	= "Imbonitore";
		["CmdClear"]	= "cancella";
		["CmdDefault"]	= "default";
		["CmdDisable"]	= "disabilita";
		["CmdFindBidauct"]	= "bidbroker";
		["CmdFindBidauctShort"]	= "bb";
		["CmdFindBuyauct"]	= "percentomeno";
		["CmdFindBuyauctShort"]	= "pm";
		["CmdHelp"]	= "aiuto";
		["CmdLocale"]	= "lingua";
		["CmdOff"]	= "fuori di";
		["CmdOn"]	= "abilitato";
		["CmdPrintin"]	= "stampa-in";
		["CmdToggle"]	= "inverti";
		["ShowCount"]	= "conteggio";
		["ShowEmbed"]	= "integra";
		["ShowGuessAuctioneerHsp"]	= "valuta-hsp";
		["ShowGuessAuctioneerMed"]	= "valuta-mediana";
		["ShowTerse"]	= "conciso";
		["ShowValue"]	= "valuta";

		-- Section: Game Constants
		["BarkerOpening"]	= "Vendita:";
		["OneLetterGold"]	= "g";
		["OneLetterSilver"]	= "s";
		["ShortDarnassus"]	= "Darn.";
		["ShortIronForge"]	= "IF";
		["ShortOrgrimmar"]	= "Org";
		["ShortStormwind"]	= "SW";
		["ShortThunderBluff"]	= "TB";
		["ShortUndercity"]	= "UC";

		-- Section: Tooltip Messages
		["FrmtBarkerPrice"]	= "Prezzo imbonitore (margine %d%%)";
		["FrmtPriceEach"]	= "(%s ognuno)";
		["FrmtSuggestedPrice"]	= "Prezzo suggerito:";
		["FrmtTotal"]	= "Totale";
		["FrmtWarnAuctNotLoaded"]	= "[Auctioneer non caricato, uso i prezzi nascosti]";
		["FrmtWarnNoPrices"]	= "[Prezzi non disponibili]";
		["FrmtWarnPriceUnavail"]	= "[Alcuni prezzi non disponibili]";

		-- Section: User Interface
		["BarkerOptionsHighestPriceForFactorTitle"]	= "Massimo prezzo di costo";
		["BarkerOptionsHighestPriceForFactorTooltip"]	= "Con questo valore l'enchant riceve un punteggio di 0 per la priorità di prezzo.";
		["BarkerOptionsHighestProfitTitle"]	= "Massimo profitto";
		["BarkerOptionsHighestProfitTooltip"]	= "Massimo profitto totale su un enchant.";
		["BarkerOptionsLowestPriceTitle"]	= "Prezzo più basso";
		["BarkerOptionsLowestPriceTooltip"]	= "Il prezzo piu' basso da riportare per un Enchantment.";
		["BarkerOptionsPricePriorityTitle"]	= "Priorita' totale del prezzo";
		["BarkerOptionsPricePriorityTooltip"]	= "Questo imposta l'importanza del prezzo sulla priorita' totale per l'annuncio.";
		["BarkerOptionsPriceSweetspotTitle"]	= "SweetSpot del Fattore di Prezzo";
		["BarkerOptionsPriceSweetspotTooltip"]	= "Questo si usa per dare priorita' agli enchant vicini a questo prezzo per la pubblicita'.";
		["BarkerOptionsProfitMarginTitle"]	= "Margine di profitto";
		["BarkerOptionsProfitMarginTooltip"]	= "La percentuale di profitto da aggiungere al prezzo della materia prima.";
		["BarkerOptionsRandomFactorTitle"]	= "Fattore casuale";
		["BarkerOptionsRandomFactorTooltip"]	= "Il grado di casualita' nella scelta degli enchant da proporre in vendita.";
		["BarkerOptionsTab1Title"]	= "Priorita' di profitto e prezzo";

	};

	koKR = {

		-- Section: Command Messages
		["BarkerEnxWindowNotOpen"]	= "Enchantrix: 마법부여 창이 열려있지 않습니다. Barker를 사용하려면 마법부여 창이 열려있어야만 합니다.";
		["BarkerNoEnchantsAvail"]	= "Enchantrix: 마법부여 재료가 하나도 없거나 추출할 재료가 하나도 없습니다.";

		-- Section: Commands
		["CmdBarker"]	= "알림";
		["CmdClear"]	= "삭제";
		["CmdDefault"]	= "기본값";
		["CmdDisable"]	= "비활성화";
		["CmdFindBidauct"]	= "입찰중개인";
		["CmdFindBidauctShort"]	= "bb";
		["CmdFindBuyauct"]	= "이하확률";
		["CmdFindBuyauctShort"]	= "pl ";
		["CmdHelp"]	= "도움말";
		["CmdLocale"]	= "지역";
		["CmdOff"]	= "끔";
		["CmdOn"]	= "켬";
		["CmdPrintin"]	= "출력하는곳";
		["CmdToggle"]	= "전환";
		["ShowCount"]	= "수량";
		["ShowEmbed"]	= "내장";
		["ShowGuessAuctioneerHsp"]	= "평가된 HSP";
		["ShowGuessAuctioneerMed"]	= "평가된 중앙값";
		["ShowTerse"]	= "간결";
		["ShowValue"]	= "평가";

		-- Section: Game Constants
		["BarkerOpening"]	= "마법부여 판매:";
		["Boots"]	= "장화";
		["Chest"]	= "가슴보호구";
		["Cloak"]	= "망토";
		["Darnassus"]	= "다르나서스";
		["EnchSearchAllResistance3"]	= "저항력";
		["EnchSearchAllStats"]	= "능력치";
		["EnchSearchFireRes"]	= "화염 저항력";
		["EnchSearchIntellect"]	= "지능";
		["EnchSearchMana"]	= "마나";
		["EnchSearchNatureRes"]	= "자연 저항력";
		["EnchSearchSpirit"]	= "정신력";
		["Gloves"]	= "장갑";
		["OneLetterGold"]	= "골드";
		["OneLetterSilver"]	= "실버";
		["Orgrimmar"]	= "오그리마";
		["Shattrath"]	= "샤트라스";
		["Shield"]	= "방패";
		["ShortDarnassus"]	= "다르";
		["ShortIronForge"]	= "아포";
		["ShortOrgrimmar"]	= "오그";
		["ShortShattrath"]	= "샤트";
		["ShortStormwind"]	= "스톰";
		["ShortThunderBluff"]	= "썬더";
		["ShortUndercity"]	= "언더";
		["ThunderBluff"]	= "썬더 블러프";
		["TwoHandWeapon"]	= "양손 무기";
		["Undercity"]	= "언더시티";
		["Weapon"]	= "무기";

		-- Section: Generic Messages
		["BarkerLoaded"]	= "Enchantrix Barker 로드됨.";

		-- Section: Generic Strings
		["ShortHealth"]	= "생명력";
		["ShortMana"]	= "마나";
		["ShortVitality"]	= "민첩성";
		["SPI"]	= "정신력";
		["STA"]	= "체력";
		["STR"]	= "힘";

		-- Section: Tooltip Messages
		["FrmtBarkerPrice"]	= "가격 알림 (%d%% 마진)";
		["FrmtPriceEach"]	= "(%s 개)";
		["FrmtSuggestedPrice"]	= "제안 가격:";
		["FrmtTotal"]	= "총";
		["FrmtWarnAuctNotLoaded"]	= "[Auctioneer가 실행되지 않아서 저장된 가격을 사용합니다.]";
		["FrmtWarnNoPrices"]	= "[가능한 가격 없음]";
		["FrmtWarnPriceUnavail"]	= "[일부 가격을 사용할 수 없음]";

		-- Section: User Interface
		["BarkerOptionsHighestPriceForFactorTitle"]	= "가격요건 최고가격";
		["BarkerOptionsHighestPriceForFactorTooltip"]	= "마법부여가 가격 우선순위에서 0점을 받았거나 이점수 이상입니다.";
		["BarkerOptionsHighestProfitTitle"]	= "최고 이익";
		["BarkerOptionsHighestProfitTooltip"]	= "마법부여를 하면 최고가로 이득이 됩니다.";
		["BarkerOptionsLowestPriceTitle"]	= "최저 가격";
		["BarkerOptionsLowestPriceTooltip"]	= "마법부여에 대한 시세가 최저 현금 가격으로 평가됩니다.";
		["BarkerOptionsPricePriorityTitle"]	= "전체 가격 정책";
		["BarkerOptionsPricePriorityTooltip"]	= "가격 중요도가 광고에 대한 전체 우선순위에서 얼마나 될지 설정합니다. ";
		["BarkerOptionsPriceSweetspotTitle"]	= "가격요건 관심구매가격";
		["BarkerOptionsPriceSweetspotTooltip"]	= "광고에 대해 이가격에 가까운 마법부여 우선순위를 결정한는데 사용됩니다.";
		["BarkerOptionsProfitMarginTitle"]	= "이윤폭";
		["BarkerOptionsProfitMarginTooltip"]	= "기본 비용에 추가하기 적합한 비율입니다.";
		["BarkerOptionsRandomFactorTitle"]	= "무작위 요건";
		["BarkerOptionsRandomFactorTooltip"]	= "마법부여에서 무작위로 거래 외침을 선택합니다.";
		["BarkerOptionsTab1Title"]	= "이익과 가격 우선순위";

	};

	nlNL = {

		-- Section: Command Messages
		["BarkerEnxWindowNotOpen"]	= "Enchantrix: Het enchant scherm is niet geopend. Het enchanting scherm moet geopend zijn om de barker te gebruiken.";
		["BarkerNoEnchantsAvail"]	= "Enchantrix: Je hebt geen enchants, of je hebt geen reagents om  iets te enchanten.";

		-- Section: Commands
		["CmdBarker"]	= "Omroeper";
		["ShowTerse"]	= "Beknopt";

		-- Section: Game Constants
		["BarkerOpening"]	= "Selling Enchants:";
		["OneLetterGold"]	= "g";
		["OneLetterSilver"]	= "s";
		["ShortDarnassus"]	= "Dar";
		["ShortIronForge"]	= "IF";
		["ShortOrgrimmar"]	= "Org";
		["ShortStormwind"]	= "SW";
		["ShortThunderBluff"]	= "TB";
		["ShortUndercity"]	= "UC";

		-- Section: Tooltip Messages
		["FrmtBarkerPrice"]	= "Omroep Prijs (%d%% marge)";
		["FrmtPriceEach"]	= "Prijs per item";
		["FrmtSuggestedPrice"]	= "Voorstel Prijs:";
		["FrmtTotal"]	= "Totaal";
		["FrmtWarnAuctNotLoaded"]	= "Auctioneer niet geladen. Opgeslagen waardes worden gebruikt.";
		["FrmtWarnNoPrices"]	= "Geen prijs beschikbaar ";
		["FrmtWarnPriceUnavail"]	= "Sommige prijzen niet beschikbaar";

		-- Section: User Interface
		["BarkerOptionsHighestProfitTitle"]	= "Maximale Winst";
		["BarkerOptionsLowestPriceTitle"]	= "Laagste Prijs";
		["BarkerOptionsProfitMarginTitle"]	= "Winstmarge";
		["BarkerOptionsRandomFactorTitle"]	= "Willekeurige Factor";

	};

	ptPT = {

		-- Section: Commands
		["CmdBarker"]	= "Vendedor";
		["CmdClear"]	= "apagar";
		["CmdDefault"]	= "por defeito";
		["CmdDisable"]	= "desactivar";
		["CmdHelp"]	= "ajuda";
		["CmdLocale"]	= "localização";
		["CmdOff"]	= "desligado";
		["CmdOn"]	= "ligado";
		["CmdPrintin"]	= "imprimir em";
		["CmdToggle"]	= "alternar";
		["ShowCount"]	= "contagens";
		["ShowEmbed"]	= "embebido";
		["ShowGuessAuctioneerMed"]	= "valor médio";
		["ShowTerse"]	= "breve";
		["ShowValue"]	= "avaliar";

		-- Section: Tooltip Messages
		["FrmtBarkerPrice"]	= "Preço de Vendedor (%d%% margem)";
		["FrmtPriceEach"]	= "(%s cada)";
		["FrmtSuggestedPrice"]	= "Preço sugerido:";
		["FrmtTotal"]	= "Total";
		["FrmtWarnAuctNotLoaded"]	= "[Auctioneer não carregado, usando preços em cache]";
		["FrmtWarnNoPrices"]	= "[Nenhuns Preços Disponiveis]";
		["FrmtWarnPriceUnavail"]	= "[Alguns preços indisponiveis]";

	};

	ruRU = {

		-- Section: Commands
		["CmdClear"]	= "Очистить";
		["CmdDefault"]	= "Стандартные";
		["CmdDisable"]	= "выведите из строя\n";
		["CmdFindBidauct"]	= "bidbroker ";
		["CmdFindBidauctShort"]	= "bb ";
		["CmdFindBuyauct"]	= "percentless ";
		["CmdFindBuyauctShort"]	= "pl ";
		["CmdHelp"]	= "помощь\n";
		["CmdOff"]	= "off";
		["CmdOn"]	= "на\n";
		["CmdPrintin"]	= "print-in ";
		["CmdToggle"]	= "переключить";
		["ShowCount"]	= "отсчеты\n";

		-- Section: Tooltip Messages
		["FrmtPriceEach"]	= "(%s каждая)";
		["FrmtSuggestedPrice"]	= "Рекомендуемая цена:";
		["FrmtTotal"]	= "Итого";
		["FrmtWarnAuctNotLoaded"]	= "[Auctioneer не загружен, использую полученные ранее данные]";
		["FrmtWarnNoPrices"]	= "[Цены неизвестны]";
		["FrmtWarnPriceUnavail"]	= "[Некоторые цены неизвестны]";

	};

	trTR = {

		-- Section: Commands
		["CmdDisable"]	= "iptal";

	};

	zhCN = {

		-- Section: Command Messages
		["BarkerEnxWindowNotOpen"]	= "附魔助手：附魔窗口没有打开。使用barker指令必须打开附魔窗口";
		["BarkerNoEnchantsAvail"]	= "附魔助手：您没有附魔技能或没有制作试剂";

		-- Section: Commands
		["CmdBarker"]	= "barker";
		["CmdClear"]	= "clear清除";
		["CmdDefault"]	= "default默认";
		["CmdDisable"]	= "disable禁用";
		["CmdFindBidauct"]	= "bidbroker出价代理";
		["CmdFindBidauctShort"]	= "bb(出价代理的缩写)";
		["CmdFindBuyauct"]	= "percentless比率差额";
		["CmdFindBuyauctShort"]	= "pl(比率差额的缩写)";
		["CmdHelp"]	= "help帮助";
		["CmdLocale"]	= "locale地域代码";
		["CmdOff"]	= "off关";
		["CmdOn"]	= "on开";
		["CmdPrintin"]	= "print-in输出于";
		["CmdToggle"]	= "toggle开关转换";
		["ShowCount"]	= "counts计数";
		["ShowEmbed"]	= "embed嵌入";
		["ShowGuessAuctioneerHsp"]	= "valuate-hsp估价-最高";
		["ShowGuessAuctioneerMed"]	= "valuate-median估价-中值";
		["ShowTerse"]	= "terse简洁";
		["ShowValue"]	= "valuate估价";

		-- Section: Game Constants
		["AnyWeapon"]	= "任意武器";
		["BarkerOpening"]	= "出售附魔：";
		["Boots"]	= "脚";
		["Bracer"]	= "腰部";
		["Chest"]	= "胸部";
		["Cloak"]	= "肩部";
		["Darnassus"]	= "达纳苏丝";
		["EnchSearchAgility"]	= "敏捷";
		["EnchSearchAllResistance1"]	= "所有抗性";
		["EnchSearchAllResistance2"]	= "所有抗性";
		["EnchSearchAllResistance3"]	= "所有抗性";
		["EnchSearchAllStats"]	= "所有状态";
		["EnchSearchArmor"]	= "护甲";
		["EnchSearchBattlemaster"]	= "治疗附近小队成员";
		["EnchSearchBeastslayer"]	= "野兽伤害";
		["EnchSearchBoarSpeed"]	= "移动速度提升和[0-9]+耐力";
		["EnchSearchCatSwiftness"]	= "移动速度提升和[0-9]+敏捷";
		["EnchSearchCrusader"]	= "治疗[0-9]+到[0-9]+和提升耐力";
		["EnchSearchDamage1"]	= "毒药?伤害";
		["EnchSearchDamage2"]	= "\+[0-9]+伤害";
		["EnchSearchDefense"]	= "防御";
		["EnchSearchDMGAbsorption"]	= "吸收";
		["EnchSearchFireRes"]	= "火焰抗性";
		["EnchSearchFrostRes"]	= "冰霜抗性";
		["EnchSearchHealth"]	= "生命";
		["EnchSearchIntellect"]	= "智力";
		["EnchSearchMana"]	= "魔法";
		["EnchSearchMongoose"]	= "提升敏捷[0-9]+和攻击速度";
		["EnchSearchNatureRes"]	= "自然抗性";
		["EnchSearchResFire"]	= "火焰抗性";
		["EnchSearchResShadow"]	= "暗影抗性";
		["EnchSearchSoulfrost"]	= "冰霜和暗影技能";
		["EnchSearchSpellPower1"]	= "法术伤害";
		["EnchSearchSpellPower2"]	= "法术伤害";
		["EnchSearchSpellPower3"]	= "法术伤害";
		["EnchSearchSpellsurge"]	= "恢复[0-9]+魔法附近小队成员";
		["EnchSearchSpirit"]	= "精神";
		["EnchSearchStamina"]	= "耐力";
		["EnchSearchStrength"]	= "力量";
		["EnchSearchSunfire"]	= "火焰与奥术法术";
		["EnchSearchVitality"]	= "恢复[0-9]+生命与魔法";
		["Gloves"]	= "手腕";
		["Ironforge"]	= "铁炉堡";
		["OneLetterGold"]	= "G";
		["OneLetterSilver"]	= "S";
		["Orgrimmar"]	= "奥格瑞玛";
		["Ring"]	= "耳环";
		["Shattrath"]	= "沙塔斯城";
		["Shield"]	= "盾牌";
		["ShortDarnassus"]	= "Dar ";
		["ShortExodar"]	= "Exo";
		["ShortIronForge"]	= "IF ";
		["ShortOrgrimmar"]	= "Org ";
		["ShortShattrath"]	= "Sha";
		["ShortSilvermoon"]	= "SmC";
		["ShortStormwind"]	= "SW ";
		["ShortThunderBluff"]	= "TB ";
		["ShortUndercity"]	= "UC ";
		["SilvermoonCity"]	= "银月城";
		["StormwindCity"]	= "暴风城";
		["TheExodar"]	= "埃索达";
		["ThunderBluff"]	= "雷霆崖";
		["TradeChannel"]	= "交易-城市";
		["TwoHandWeapon"]	= "双手武器";
		["Undercity"]	= "幽暗城";
		["Weapon"]	= "武器";

		-- Section: Generic Messages
		["BarkerLoaded"]	= "附魔助手代理已载入...";
		["BarkerNotTradeZone"]	= "附魔助手代理:你没有在贸易区[无交易频道]。";

		-- Section: Generic Strings
		["AGI"]	= "敏捷";
		["AllStats"]	= "所有属性";
		["Crusader"]	= "十字军";
		["DEF"]	= "防御";
		["DMG"]	= "伤害";
		["DMGAbsorb"]	= "伤害吸收";
		["FireRes"]	= "火抗";
		["FrostRes"]	= "冰抗";
		["INT"]	= "智力";
		["NatureRes"]	= "自然抗";
		["ShadowRes"]	= "暗抗";
		["ShortAllRes"]	= "所有抗性";
		["ShortArmor"]	= "护甲";
		["ShortBattlemaster"]	= "战场大师";
		["ShortBeastslayer"]	= "野兽";
		["ShortBoarSpeed"]	= "野豬之速";
		["ShortCatSwiftness"]	= "貓之迅捷";
		["ShortHealth"]	= "生命";
		["ShortMana"]	= "魔法";
		["ShortMongoose"]	= "猫鼬";
		["ShortSoulfrost"]	= "霜魂";
		["ShortSpellPower"]	= "法术";
		["ShortSpellSurge"]	= "Spellsurge";
		["ShortSunfire"]	= "Sunfire";
		["ShortVitality"]	= "生命力";
		["SPI"]	= "精神";
		["STA"]	= "耐力";
		["STR"]	= "力量";

		-- Section: Tooltip Messages
		["FrmtBarkerPrice"]	= "Barker价格(%d%% 最低利润)";
		["FrmtPriceEach"]	= "(每件%s)";
		["FrmtSuggestedPrice"]	= "建议价格：";
		["FrmtTotal"]	= "合计";
		["FrmtWarnAuctNotLoaded"]	= "[拍卖助手未加载，使用缓冲价格]";
		["FrmtWarnNoPrices"]	= "[无价可用]";
		["FrmtWarnPriceUnavail"]	= "[某些价格不可用]";
		["OpenBarkerWindow"]	= "打开商业代理界面";

		-- Section: User Interface
		["BarkerOptions2HWeaponPriorityTooltip"]	= "优先显示附魔-双手武器。";
		["BarkerOptionsAgilityPriority"]	= "敏捷";
		["BarkerOptionsAgilityPriorityTooltip"]	= "优先显示附魔-敏捷。";
		["BarkerOptionsAllResistances"]	= "所有抗性";
		["BarkerOptionsAllResistancesTooltip"]	= "优先显示附魔-所有抗性提升。";
		["BarkerOptionsAllStatsPriority"]	= "所有属性";
		["BarkerOptionsAllStatsPriorityTooltip"]	= "优先显示附魔-所有属性提升。";
		["BarkerOptionsAnyWeaponPriorityTooltip"]	= "优先显示附魔-武器。";
		["BarkerOptionsArmorPriority"]	= "护甲";
		["BarkerOptionsArmorPriorityTooltip"]	= "优先显示附魔-护甲。";
		["BarkerOptionsBootsPriorityTooltip"]	= "优先显示附魔-鞋。";
		["BarkerOptionsBracerPriorityTooltip"]	= "优先显示附魔-腰部。";
		["BarkerOptionsChestPriorityTooltip"]	= "优先显示附魔-胸部。";
		["BarkerOptionsCloakPriorityTooltip"]	= "优先显示附魔-肩部。";
		["BarkerOptionsDamage"]	= "伤害";
		["BarkerOptionsDamageTooltip"]	= "优先显示附魔-伤害";
		["BarkerOptionsDefense"]	= "防御";
		["BarkerOptionsDefenseTooltip"]	= "优先显示附魔-防御。";
		["BarkerOptionsFireResistance"]	= "火焰抗性";
		["BarkerOptionsFireResistanceTooltip"]	= "优先显示附魔-火焰抗性。";
		["BarkerOptionsFrostResistance"]	= "冰霜抗性";
		["BarkerOptionsFrostResistanceTooltip"]	= "优先显示附魔-冰霜抗性。";
		["BarkerOptionsGlovesPriorityTooltip"]	= "优先显示附魔-手腕。";
		["BarkerOptionsHealth"]	= "生命";
		["BarkerOptionsHealthTooltip"]	= "优先显示附魔-生命。";
		["BarkerOptionsHighestPriceForFactorTitle"]	= "最高价格因子";
		["BarkerOptionsHighestPriceForFactorTooltip"]	= "附魔接受比分价格为零或在这价值之上优先。";
		["BarkerOptionsHighestProfitTitle"]	= "最大收益";
		["BarkerOptionsHighestProfitTooltip"]	= "附魔获得最高的总收益金。";
		["BarkerOptionsIntellectPriority"]	= "智力";
		["BarkerOptionsIntellectPriorityTooltip"]	= "优先显示附魔-智力。";
		["BarkerOptionsItemsPriority"]	= "总体物品优先";
		["BarkerOptionsItemsPriorityTooltip"]	= "这个设置如何重要物品的总体优先广告";
		["BarkerOptionsLowestPriceTitle"]	= "最低标价";
		["BarkerOptionsLowestPriceTooltip"]	= "提供附魔最低的现贷价格。";
		["BarkerOptionsMana"]	= "魔法";
		["BarkerOptionsManaTooltip"]	= "优先显示附魔-魔法。";
		["BarkerOptionsNatureResistance"]	= "自然抗性";
		["BarkerOptionsNatureResistanceTooltip"]	= "优先显示附魔-自然抗性。";
		["BarkerOptionsOther"]	= "其他";
		["BarkerOptionsOtherTooltip"]	= "优先显示附魔-剥皮，采矿，骑术等。";
		["BarkerOptionsPricePriorityTitle"]	= "总体价格优先";
		["BarkerOptionsPricePriorityTooltip"]	= "此设置重要定价如何是到总体优先权为做广告。";
		["BarkerOptionsPriceSweetspotTitle"]	= "价格代理甜点";
		["BarkerOptionsPriceSweetspotTooltip"]	= "用于给予优先在这个价格附近附魔为做广告。";
		["BarkerOptionsProfitMarginTitle"]	= "边缘收益";
		["BarkerOptionsProfitMarginTooltip"]	= "增加赢利百分比到基本边际收益费用。";
		["BarkerOptionsRandomFactorTitle"]	= "随机要素";
		["BarkerOptionsRandomFactorTooltip"]	= "相当数量随机性在附魔为商业选择。";
		["BarkerOptionsRingPriorityTooltip"]	= "优先显示附魔-耳环。";
		["BarkerOptionsShadowResistance"]	= "暗影抗性";
		["BarkerOptionsShadowResistanceTooltip"]	= "优先显示附魔-暗影抗性。";
		["BarkerOptionsShieldPriorityTooltip"]	= "优先显示附魔-盾牌。";
		["BarkerOptionsSpiritPriority"]	= "精神";
		["BarkerOptionsSpiritPriorityTooltip"]	= "优先显示附魔-精神。";
		["BarkerOptionsStaminaPriority"]	= "耐力";
		["BarkerOptionsStaminaPriorityTooltip"]	= "优先显示附魔-耐力。";
		["BarkerOptionsStatsPriority"]	= "总体属性优先";
		["BarkerOptionsStatsPriorityTooltip"]	= "这个设置如何重要的属性总体优先广告";
		["BarkerOptionsStrengthPriority"]	= "力量";
		["BarkerOptionsStrengthPriorityTooltip"]	= "优先显示附魔-力量。";
		["BarkerOptionsTab1Title"]	= "收益与价格优先";

	};

	zhTW = {

		-- Section: Command Messages
		["BarkerEnxWindowNotOpen"]	= "附魔視窗沒有開啟。要使用barker指令必須打開附魔視窗";
		["BarkerNoEnchantsAvail"]	= "附魔助手：您没有附魔技能或没有相對應的材料";

		-- Section: Commands
		["CmdBarker"]	= "聲望提示";
		["CmdClear"]	= "clear";
		["CmdDefault"]	= "default";
		["CmdDisable"]	= "disable";
		["CmdFindBidauct"]	= "bidbroker";
		["CmdFindBidauctShort"]	= "bb";
		["CmdFindBuyauct"]	= "percentless";
		["CmdFindBuyauctShort"]	= "pl";
		["CmdHelp"]	= "幫助";
		["CmdLocale"]	= "locale";
		["CmdOff"]	= "off";
		["CmdOn"]	= "on";
		["CmdPrintin"]	= "print-in";
		["CmdToggle"]	= "toggle";
		["ShowCount"]	= "counts";
		["ShowEmbed"]	= "embed";
		["ShowGuessAuctioneerHsp"]	= "valuate-hsp";
		["ShowGuessAuctioneerMed"]	= "valuate-median";
		["ShowTerse"]	= "精簡";
		["ShowValue"]	= "valuate";

		-- Section: Game Constants
		["BarkerOpening"]	= "想出售附魔:";
		["OneLetterGold"]	= "金";
		["OneLetterSilver"]	= "銀";
		["ShortDarnassus"]	= "達納蘇斯";
		["ShortIronForge"]	= "鐵爐堡";
		["ShortOrgrimmar"]	= "奧格瑞瑪";
		["ShortShattrath"]	= "撒塔斯城";
		["ShortStormwind"]	= "暴風城";
		["ShortThunderBluff"]	= "雷霆崖";
		["ShortUndercity"]	= "幽暗城";

		-- Section: Tooltip Messages
		["FrmtBarkerPrice"]	= "Barker 價格 (%d%% 保証金) ";
		["FrmtPriceEach"]	= "(%s 每個) ";
		["FrmtSuggestedPrice"]	= "建議價格：";
		["FrmtTotal"]	= "總共";
		["FrmtWarnAuctNotLoaded"]	= "[Auctioneer未載入，使用暫存區價格]";
		["FrmtWarnNoPrices"]	= "[無有效價格]";
		["FrmtWarnPriceUnavail"]	= "[部分價格無效]";

		-- Section: User Interface
		["BarkerOptionsHighestProfitTitle"]	= "最高盈利";
		["BarkerOptionsLowestPriceTitle"]	= "最低價格";
		["BarkerOptionsProfitMarginTitle"]	= "淨利率";

	};

}