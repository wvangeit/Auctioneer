--[[
	WARNING: This is a generated file.
	If you wish to perform or update localizations, please go to our Localizer website at:
	http://norganna.org/localizer/index.php

	AddOn: Enchantrix
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

EnchantrixLocalizations = {

	csCZ = {


		-- Section: Command Messages
		FrmtActClearall	= "Mažu všechna data o enchantech";
		FrmtActClearFail	= "Nelze najít předmět: %s";
		FrmtActClearOk	= "Smazána data k předmětu: %s";
		FrmtActDefault	= "Nastavení Enchantrixu '%s' bylo vráceno na základní hodnotu.";
		FrmtActDefaultAll	= "Všechna nastavení Enchantrixu byla vrácena na základní hodnoty.";
		FrmtActDisable	= "Vypnuto zobrazování dat předmětů o: %s";
		FrmtActEnable	= "Zapnuto zobrazování dat předmetů o: %s";
		FrmtActEnabledOn	= "Zobrazuji %s predmetu na %s";
		FrmtActSet	= "Nastavit %s na '%s'";
		FrmtActUnknown	= "Neznámý příkaz: '%s'";
		FrmtActUnknownLocale	= "Zvoleny jazyk ('%s') neni dostupny. Dostupne jsou: ";
		FrmtPrintin	= "Enchantrix bude zpravy zobrazovat v okne: \"%s\"";
		FrmtUsage	= "Pouzivani:";
		MesgDisable	= "Vypinam automaticke spusteni Enchantrix";
		MesgNotloaded	= "Enchantrix neni spusten. Napis /enchantrix a dozvis se vic.";


		-- Section: Command Options
		CmdClearAll	= "vse";
		OptClear	= "([Objekt]|vse)";
		OptDefault	= "(<nastaveni>|vse)";
		OptFindBidauct	= "<stribro>";
		OptFindBuyauct	= "<procent>";
		OptLocale	= "<jazyk>";
		OptPrintin	= "(<frameIndex>[Number]|<frameName>[String])";


		-- Section: Commands
		CmdClear	= "smazat";
		CmdDefault	= "vychozi";
		CmdDisable	= "vypnout";
		CmdFindBidauct	= "bidbroker";
		CmdFindBidauctShort	= "bb";
		CmdFindBuyauct	= "procent-mene";
		CmdFindBuyauctShort	= "pm";
		CmdHelp	= "pomoc";
		CmdLocale	= "jazyk";
		CmdOff	= "vyp";
		CmdOn	= "zap";
		CmdPrintin	= "zobraz-v";
		CmdToggle	= "prepnout";
		ShowCount	= "pocet";
		ShowEmbed	= "integrace";
		ShowGuessAuctioneerHsp	= "urcit-nuc";
		ShowGuessAuctioneerMed	= "urcit-stred";
		ShowGuessBaseline	= "urcit-zaklad";
		ShowHeader	= "nadpis";
		ShowRate	= "sazby";
		ShowTerse	= "strucne";
		ShowValue	= "ohodnotit";
		StatOff	= "Nejsou zobrazována žádná Enchant data";
		StatOn	= "Jsou zobrazována vybraná Enchant data";


		-- Section: Config Text
		GuiLoad	= "Spustit Enchantrix";
		GuiLoad_Always	= "vzdy";
		GuiLoad_Never	= "nikdy";


		-- Section: Game Constants
		ArgSpellname	= "Disenchant";
		Darnassus	= "Darnassus";
		Ironforge	= "City of Ironforge";
		OneLetterGold	= "g";
		OneLetterSilver	= "s";
		Orgrimmar	= "Orgrimmar";
		PatReagents	= "Materiály: (.+)";
		ShortDarnassus	= "Dar";
		ShortIronForge	= "IF";
		ShortOrgrimmar	= "Org";
		ShortStormwind	= "SW";
		ShortThunderBluff	= "TB";
		ShortUndercity	= "UC";
		StormwindCity	= "Stormwind City";
		TextCombat	= "Boj";
		TextGeneral	= "Obecne";
		ThunderBluff	= "Thunder Bluff";
		Undercity	= "Undercity";


		-- Section: Generic Messages
		FrmtCredit	= "(navštiv http://enchantrix.org/ a poděl se o svá data)";
		FrmtWelcome	= "Enchantrix v%s spuštěna";
		MesgAuctVersion	= "Enchantrix potřebuje Auctioneer od verze 3.4. Dokud neprovedeš update své instalace Auctioneer, tvá Enchantrix nebude umět některé věci.";


		-- Section: Help Text
		GuiClearall	= "Smazat všechna data Enchantrix";
		GuiClearallButton	= "Smazat vše";
		GuiClearallHelp	= "Klikni zde a smažou se všechny záznamy Enchantrix pro tento server";
		GuiClearallNote	= "pro tento server a stranu";
		GuiCount	= "Zobraz presne pocty v databazi";
		GuiDefaultAll	= "Obnov všechna nastavení Enchantrix na základní hodnoty";
		GuiDefaultAllButton	= "Obnovit vše";
		GuiDefaultAllHelp	= "Klikni zde pro obnoveni vsech nastavení Enchantrix na základní hodnoty. POZOR: Všechny změny nastavení budou ztraceny";
		GuiDefaultOption	= "Obnov toto nastavení";
		GuiEmbed	= "Vkládat informace do nápovědy";
		GuiLocale	= "Nastav jazyk na";
		GuiMainEnable	= "Aktivovat Enchantrix";
		GuiMainHelp	= "Obsahuje nastaveni Enchantrixu, AddOnu zobrazujího v nápovědách informace o zisku při provedení \"Disenchant\" na daný předmět.";
		GuiOtherHeader	= "Dalsi moznosti";
		GuiOtherHelp	= "Ruzne Enchantrix moznosti";
		GuiPrintin	= "Vyber si textove okno";
		GuiRate	= "Zobrazit prumerne mnozstvi odkouzleni";
		GuiReloadui	= "Znovu nahraj interface";
		GuiReloaduiButton	= "NahrajUI";
		GuiReloaduiFeedback	= "Nahravam WoW interface";
		GuiReloaduiHelp	= "Klikni zde pro nove nahrani interface. Bude take nahran zvoleny jazyk. Pozor: Toto muze trvat nekolik minut.";
		GuiTerse	= "Nastavit stručné zobrazení";
		GuiValuateAverages	= "Ohodnocovat podle průměrných hodnot od Auctioneer-a";
		GuiValuateBaseline	= "Ohodnocovat podle vlastních dat";
		GuiValuateEnable	= "Zapnout ohodnocování";
		GuiValuateHeader	= "Ohodnocování";
		GuiValuateMedian	= "Ohodnocovat podle mediánů od Auctioneer-a";
		HelpClear	= "Smazat data k urcenemu objektu (shift - klikem ho vlozite do prikazu, nebo pouzijte urceni \"vse\" nebo \"all\")";
		HelpCount	= "Nastavi zda se ma zobrazovat pocet zaznamu v databazi";
		HelpDefault	= "Vrati urcene Enchantrix nastaveni na vychozi. Take lze pouzit urceni \"vse\" nebo \"all\" pro navrat vsech nastaveni na vychozi.";
		HelpDisable	= "Deaktivuje automaticke zapinani Enchantrixu pri vstupu do hry";
		HelpEmbed	= "Vkládat informace do nápověd(pozor: nektere funkce nejsou v tomto rezimu dostupne)";
		HelpFindBidauct	= "Najde aukce u nichz je odhadovany zisk z \"Disenchant\" o urcenou sumu stribra vyssi nez momentalni naBIDka";
		HelpFindBuyauct	= "Najde aukce u nichz je odhadovany zisk z \"Disenchant\" o urcenou sumu stribra vyssi nez Vykupni cena";
		HelpGuessAuctioneerHsp	= "Je-li Ohodnocovani zapnuto a je-li instalovan Auctioneer - zobrazi Ohodnoceni podle Nejvyssi Uspesne Ceny (NUC) odhadovaného zisku z \"Disenchant\". ";
		HelpGuessAuctioneerMedian	= "Je-li Ohodnocovani zapnuto a je-li instalovan Auctioneer - zobrazi Ohodnoceni podle mediánu odhadovaného zisku z \"Disenchant\".";
		HelpGuessBaseline	= "Je-li Ohodnocovani zapnuto (a Auctioneer neni zapotrebi) - zobrazi jednoduche Ohodnoceni podle vlastních tabulek odhadovaného zisku z \"Disenchant\".";
		HelpGuessNoauctioneer	= "Ohodnocování NUC nebo mediánem nejsou k dispozici protoze nemas instalovany Auctioneer. ";
		HelpHeader	= "Nastavi zda se ma zobrazovat nadpis";
		HelpLoad	= "Nastavi spousteni Enchantrix pro tuto postavu";
		HelpLocale	= "Nastavi jazyk Enchantrix zprav";
		HelpOnoff	= "Nastavi zda se maji zobrazovat informace o ocarovani predmetu";
		HelpPrintin	= "Nastavi v kterem okne ma Enchantrix zobrazovat zpravy. Muzete zvolit nazev okna nebo jeho index.";
		HelpRate	= "Nastavi zda se ma zobrazovat prumerne mnozstvi odcarovaneho materialu";
		HelpTerse	= "Přepínač stručného zobrazení, kdy se ukazuje pouze hodnota \"Disenchant\". Dá se obejít podržením \"Control\".";
		HelpValue	= "Nastavi zda se ma zobrazovat odhadovaný zisk z \"Disenchant\" daného předmětu";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "soucBid";
		FrmtBidbrokerDone	= "Prihazovani dokonceno";
		FrmtBidbrokerHeader	= "Nabidky usetri %s stribra na prumerne hodnote odcarovani:";
		FrmtBidbrokerLine	= "%s, Hodnota na: %s, %s: %s, Usetrit: %s, Mene %s, Cas: %s";
		FrmtBidbrokerMinbid	= "minBid";
		FrmtBidBrokerSkipped	= "Celkem %d aukcí vynecháno pro nedostatečný percentuální zisk (%d%%)";
		FrmtPctlessDone	= "Procentuelni snizeni hotovo.";
		FrmtPctlessHeader	= "Vykupy usetri %d%% oproti prumerne hodnote odcarovani:";
		FrmtPctlessLine	= "%s, Hodnota na: %s, Vykup: %s, Usetrit: %s, Mene %s";
		FrmtPctlessSkipped	= "Celkem %d aukcí vynecháno pro nedostatečný peněžní zisk (%s)";


		-- Section: Tooltip Messages
		FrmtCounts	= "(základ=%d, stará=%d, nová=%d)";
		FrmtDisinto	= "Disenchant získá: ";
		FrmtFound	= "Zaznamenáno, že disenchant na %s získá:";
		FrmtPriceEach	= "(%s za kus)";
		FrmtSuggestedPrice	= "Doporučená cena:";
		FrmtTotal	= "Celkem";
		FrmtValueAuctHsp	= "Prodejní cena získaná Disenchantem (NUC)";
		FrmtValueAuctMed	= "Střední cena získaná Disenchantem (StredniCena)";
		FrmtValueMarket	= "Základní cena získaná Disenchantem (ZakladniCena)";
		FrmtWarnAuctNotLoaded	= "[Auctioneer nebyl nahrán, budu používat uložené ceny]";
		FrmtWarnNoPrices	= "[Ceny nejsou dostupne]";
		FrmtWarnPriceUnavail	= "[Nektere ceny nedostupne]";


		-- Section: User Interface

	};

	daDK = {


		-- Section: Command Messages
		FrmtActClearall	= "Nulstiller al Enchant data";
		FrmtActClearFail	= "Kan ikke finde item: %s";
		FrmtActClearOk	= "Data nulstillet for item: %s";
		FrmtActDefault	= "Enchantrix's %s indstilling er blevet nulstillet";
		FrmtActDefaultAll	= "Alle Enchantrix indstillinger er blevet gensat til normal";
		FrmtActDisable	= "Viser ikke item's %s data";
		FrmtActEnable	= "Viser item's %s data";
		FrmtActEnabledOn	= "Viser item's %s på %s";
		FrmtActSet	= "Sæt %s til '%s'";
		FrmtActUnknown	= "Ukendt kommando nøgleord: '%s'";
		FrmtActUnknownLocale	= "Sproget du har valgt ('%s') er ukendt. Tilladte sprog er:";
		FrmtPrintin	= "Encantrix's beskeder vil nu vises i \"%s\" chat rammen";
		FrmtUsage	= "Brug:";
		MesgDisable	= "Slår automatisk loading af Enchantrix fra";
		MesgNotloaded	= "Enchantrix er ikke indlæst. Skriv /enchantrix for mere information";


		-- Section: Command Options
		CmdClearAll	= "alt";
		OptClear	= "([Item]alt)";
		OptDefault	= "(<option>|alt)";
		OptFindBidauct	= "<sølv>";
		OptFindBuyauct	= "<procent>";
		OptLocale	= "<sprog>";
		OptPrintin	= "(<index>[Nummer]<rammenavn>[Streng])";


		-- Section: Commands
		CmdClear	= "slet";
		CmdDefault	= "standard";
		CmdDisable	= "deaktiver";
		CmdFindBidauct	= "bidbroker";
		CmdFindBidauctShort	= "bb";
		CmdFindBuyauct	= "procentunder";
		CmdFindBuyauctShort	= "pu";
		CmdHelp	= "hjælp";
		CmdLocale	= "sprog";
		CmdOff	= "fra";
		CmdOn	= "til";
		CmdPrintin	= "skriv-i";
		CmdToggle	= "skift";
		ShowCount	= "optælling";
		ShowEmbed	= "integreret";
		ShowGuessAuctioneerHsp	= "evaluer-hsp";
		ShowGuessAuctioneerMed	= "evaluer-middel";
		ShowGuessBaseline	= "evaluer-baseværdi";
		ShowHeader	= "Overskrift";
		ShowRate	= "Ratio";
		ShowTerse	= "conciso";
		ShowValue	= "Evaluer";
		StatOff	= "Viser ingen enchant data";
		StatOn	= "Viser konfigureret enchant data";


		-- Section: Config Text
		GuiLoad	= "Load Auctioneer";
		GuiLoad_Always	= "altid";
		GuiLoad_Never	= "aldrig";


		-- Section: Game Constants
		ArgSpellname	= "Disenchant";
		Darnassus	= "Darnassus";
		Ironforge	= "City of ironforge";
		OneLetterGold	= "g";
		OneLetterSilver	= "s";
		Orgrimmar	= "Orgrimmar";
		PatReagents	= "Ingredienser: (.+)";
		ShortDarnassus	= "Dar";
		ShortIronForge	= "IF";
		ShortOrgrimmar	= "Org";
		ShortStormwind	= "SW";
		ShortThunderBluff	= "TB";
		ShortUndercity	= "UC";
		StormwindCity	= "Stormwind City";
		TextCombat	= "Kamp";
		TextGeneral	= "Generelt";
		ThunderBluff	= "Thunder Bluff";
		Undercity	= "Undercity";


		-- Section: Generic Messages
		FrmtCredit	= "Gå til http://enchantrix.org/ for at dele dine data";
		FrmtWelcome	= "Enchantrix v%s læst ind";
		MesgAuctVersion	= "Enchantix kræver Auctioneer version 3.4 eller højere. Nogle muligheder vil være utilgængelige indtil du opdatere din Auctioneer installation.";


		-- Section: Help Text
		GuiClearall	= "Slet alle Enchantrix data";
		GuiClearallButton	= "Slet alt";
		GuiClearallHelp	= "Klik her for at slette alle Enchantrix data for den aktuelle server.";
		GuiClearallNote	= "for den aktuelle server/faktion";
		GuiCount	= "Vis de præcise tal fra databasen";
		GuiDefaultAll	= "Nulstil alle Enchantrix valg";
		GuiDefaultAllButton	= "Nulstil alt";
		GuiDefaultAllHelp	= "Klik her for at sætte alle Enchantrix options til deres standard værdi. ADVARSEL. Dette kan IKKE fortrydes.";
		GuiDefaultOption	= "Nulstil denne værdi";
		GuiEmbed	= "Vis indlejrede information i spillets tooltip";
		GuiLocale	= "Sæt sprog til";
		GuiMainEnable	= "Aktiver Enchantrix";
		GuiMainHelp	= "Indeholder værdier for Enchantrix et Add-On som viser information om hvad en ting bliver til ved disenchant.";
		GuiOtherHeader	= "Andre valg";
		GuiOtherHelp	= "Diverse Enchantrix valg";
		GuiPrintin	= "Vælg den ønskede meddelelses frame";
		GuiRate	= "Vis det gennemsnitlige antal af disenchant";
		GuiReloadui	= "Genindlæs bruger interface";
		GuiReloaduiButton	= "GenindlæsUI";
		GuiReloaduiFeedback	= "Genindlæser WoW UI";
		GuiReloaduiHelp	= "Klik her for at genindlæse WoW bruger interfacet efter at have ændret localet, så sproget i konfigurations skærmen passer med det som du har valgt. Bemærk: Dette kan tage nogle minutter.";
		GuiTerse	= "Aktiver kortfattet indstilling";
		GuiValuateAverages	= "Evaluer mod Auctioneer gennemsnit";
		GuiValuateBaseline	= "Evaluer mod standard data";
		GuiValuateEnable	= "Aktiver Evaluering";
		GuiValuateHeader	= "Evaluering";
		GuiValuateMedian	= "Evaluer mod Auctioneer middel";
		HelpClear	= "Slet det valgte item data (du skal shift-klikke item ind i kommandoen). Du kan ogsÃ¥ angive all for at slette alt.";
		HelpCount	= "Vælg om der skal vises nøjagtige tal fra databasen.";
		HelpDefault	= "Sæt et Enchantrix valg til dets standard vÃ¦rdi. Du kan også angive all for at sætte alle valg til deres standard værdi.";
		HelpDisable	= "Undlader at loade Enchantrix automatisk næste gang du logger ind.";
		HelpEmbed	= "Indlejrer teksten i spillets egne tooltip (BemÃ¦rk: Visse valg kan ikke bruges sammen med dette)";
		HelpFindBidauct	= "Find auktioner hvis potentielle disenchant værdi er et vist sølvbeløb mindre end bud prisen.";
		HelpFindBuyauct	= "Find auktioner hvis potentielle disenchant værdi er vis procent værdi mindre end bud prisen.";
		HelpGuessAuctioneerHsp	= "Hvis Evaluer er slået til og du har Auctioneer installeret, vis salgspris (HSP) vurderingen af at disenchante tingen.";
		HelpGuessAuctioneerMedian	= "Hvis Evaluer er slået til og du har Auctioneer installeret, vis middel værdien af at disenchante tingen.";
		HelpGuessBaseline	= "Hvis Evaluer er slået til (Auctioneer er ikke nødvendig) vis base værdien af at disenchante ting. Baseret på de indbyggede priser.";
		HelpGuessNoauctioneer	= "Kommandoerne evaluer-hsp og evaluer-middel er ikke tilgængelige fordi du ikke har Auctioneer installeret.";
		HelpHeader	= "Vælg om overskriften skal vises";
		HelpLoad	= "Ændre Enchantrix load indstillinger for denne karakter";
		HelpLocale	= "Ændrer sproget som bruges til at vises Enchantrix meddelelser";
		HelpOnoff	= "Skifter mellem om enchant data vises eller ej.";
		HelpPrintin	= "Vælg hvilken ramme Enchantrix viser sine meddelelser i.\nDu kan enten angive navnet eller nummeret.";
		HelpRate	= "Vælg om det gennemsnitlige antal af disenchant skal vises.";
		HelpTerse	= "Aktiver/deaktiver kortfattet indstilling. Viser kun disenchant værdi. Kan tilsidesættes ved at holde control-tasten nede.";
		HelpValue	= "Vælg om tingens værdi baseret pÃ udfaldet af mulige disenchants skal vises.";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "BudNu";
		FrmtBidbrokerDone	= "Gennemløb for lave priser udført.";
		FrmtBidbrokerHeader	= "Auktioner som har %s sølv besparelse baseret på gennemsnitlig disenchant værdi. (min %%mindre = %d): ";
		FrmtBidbrokerLine	= "%s, Vurderet til: %s, %s: %s. Besparelse: %s, Under %s, Tid: %s";
		FrmtBidbrokerMinbid	= "BudMin";
		FrmtBidBrokerSkipped	= "Sprang %d auktioner over, pga. for lille profit margin. (%d%%) ";
		FrmtPctlessDone	= "Bud under gennemfÃ¸rt.";
		FrmtPctlessHeader	= "Buyouts som har %d%% besparelse i forhold til gennemsnitlige disenchant værdi:";
		FrmtPctlessLine	= "%s, vurderet til: %s, BO: %s, spar: %d, %s under.";
		FrmtPctlessSkipped	= "Sprang %d auktioner over, pga. for lille profit mulighed. (%s) ";


		-- Section: Tooltip Messages
		FrmtCounts	= "(base=%d, gammel=%d, ny=%d)";
		FrmtDisinto	= "Disenchants til:";
		FrmtFound	= "Fandt at %s disenchants til:";
		FrmtPriceEach	= "(%s/stk.)";
		FrmtSuggestedPrice	= "Anbefalet pris:";
		FrmtTotal	= "I alt";
		FrmtValueAuctHsp	= "Disenchant værdi (HSP)";
		FrmtValueAuctMed	= "Disenchant værdi (Middel)";
		FrmtValueMarket	= "Disenchant værdi (Base)";
		FrmtWarnAuctNotLoaded	= "[Auctioneer ikke indlæst, bruger priser fra cachen]";
		FrmtWarnNoPrices	= "[Ingen priser er tilgængelige]";
		FrmtWarnPriceUnavail	= "[Nogen af priserne er ikke tilgængelige]";


		-- Section: User Interface

	};

	deDE = {


		-- Section: Command Messages
		FrmtActClearall	= "Lösche alle Entzauberungsdaten";
		FrmtActClearFail	= "Kann Gegenstand %s nicht finden";
		FrmtActClearOk	= "Daten für Gegenstand %s gelöscht";
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
		CmdClear	= "clear";
		CmdDefault	= "default";
		CmdDisable	= "disable";
		CmdFindBidauct	= "bidbroker";
		CmdFindBidauctShort	= "bb";
		CmdFindBuyauct	= "percentless";
		CmdFindBuyauctShort	= "pl";
		CmdHelp	= "help";
		CmdLocale	= "locale";
		CmdOff	= "off";
		CmdOn	= "on";
		CmdPrintin	= "print-in";
		CmdToggle	= "toggle";
		ShowCount	= "counts";
		ShowEmbed	= "embed";
		ShowGuessAuctioneerHsp	= "valuate-hsp";
		ShowGuessAuctioneerMed	= "valuate-median";
		ShowGuessBaseline	= "valuate-baseline";
		ShowHeader	= "header";
		ShowRate	= "rates";
		ShowTerse	= "terse";
		ShowValue	= "valuate";
		StatOff	= "Die Anzeige von Entzauberungsdaten wurde deaktiviert";
		StatOn	= "Die Anzeige von Entzauberungsdaten wurde aktiviert";


		-- Section: Config Text
		GuiLoad	= "Enchantrix laden";
		GuiLoad_Always	= "immer";
		GuiLoad_Never	= "nie";


		-- Section: Game Constants
		ArgSpellname	= "Entzaubern";
		Darnassus	= "Darnassus";
		Ironforge	= "Ironforge";
		OneLetterGold	= "G";
		OneLetterSilver	= "S";
		Orgrimmar	= "Orgrimmar";
		PatReagents	= "Reagenzien: (.+)";
		ShortDarnassus	= "Dar";
		ShortIronForge	= "IF";
		ShortOrgrimmar	= "Org";
		ShortStormwind	= "SW";
		ShortThunderBluff	= "TB";
		ShortUndercity	= "UC";
		StormwindCity	= "Stormwind";
		TextCombat	= "Kampflog";
		TextGeneral	= "Allgemein";
		ThunderBluff	= "Thunderbluff";
		Undercity	= "Undercity";


		-- Section: Generic Messages
		FrmtCredit	= "(besuche http://enchantrix.org/ um deine Entzauberdaten mit anderen zu teilen)";
		FrmtWelcome	= "Enchantrix v%s geladen";
		MesgAuctVersion	= "Enchantrix benötigt Auctioneer Version 3.4 oder höher. Einige Funktionen werden nicht verfügbar sein, bis Sie ihre Auctioneer Version aktualisieren.";


		-- Section: Help Text
		GuiClearall	= "Alle Enchantrix-Daten löschen";
		GuiClearallButton	= "Alles löschen";
		GuiClearallHelp	= "Hier klicken um alle Enchantrix-Daten auf dem aktuellen Realm zu löschen.";
		GuiClearallNote	= "der aktuellen Fraktion auf dem aktuellen Realm";
		GuiCount	= "Zeige die genaue Anzahl aus der Datenbank";
		GuiDefaultAll	= "Alle Einstellungen zurücksetzen";
		GuiDefaultAllButton	= "Zurücksetzen";
		GuiDefaultAllHelp	= "Hier klicken um alle Enchantrix-Optionen auf ihren Standardwert zu setzen.\nWARNUNG: Dieser Vorgang kann NICHT rückgängig gemacht werden.";
		GuiDefaultOption	= "Zurücksetzen folgender Einstellung";
		GuiEmbed	= "In-Game Tooltip zur Anzeige verwenden";
		GuiLocale	= "Setze das Gebietsschema auf";
		GuiMainEnable	= "Enchantrix aktivieren";
		GuiMainHelp	= "Einstellungen für Enchantrix - ein AddOn, das Informationen über die möglichen Entzauberungen eines Gegenstands als Tooltip anzeigt.";
		GuiOtherHeader	= "Sonstige Optionen";
		GuiOtherHelp	= "Sonstige Enchantrix-Optionen";
		GuiPrintin	= "Fenster für Meldungen auswählen";
		GuiRate	= "Zeige die durchschnittliche Anzahl der Entzauberungen";
		GuiReloadui	= "Benutzeroberfläche neu laden";
		GuiReloaduiButton	= "Neu laden";
		GuiReloaduiFeedback	= "WoW-Benutzeroberfläche wird neu geladen";
		GuiReloaduiHelp	= "Hier klicken um die WoW-Benutzeroberfläche nach einer \nÄnderung des Gebietsschemas neu zu laden, so dass die Sprache des Konfigurationsmenüs diesem entspricht.\nHinweis: Dieser Vorgang kann einige Minuten dauern.";
		GuiTerse	= "Kurzinfo-Modus aktivieren";
		GuiValuateAverages	= "Verkaufspreis anzeigen (Auctioneer Durchschnittswerte)";
		GuiValuateBaseline	= "Verkaufspreis anzeigen (Interne Preisliste)";
		GuiValuateEnable	= "Wertschätzung aktivieren";
		GuiValuateHeader	= "Wertschätzung";
		GuiValuateMedian	= "Ermitteln von Durchschnittspreisen (Auctioneer Median)";
		HelpClear	= "Lösche die Daten des angegebenen Gegenstands (Gegenstände müssen mit Shift-Klick einfügt werden). Mit dem Schlüsselwort \"all\" werden alle Daten gelöscht.";
		HelpCount	= "Auswählen ob die genaue Anzahl der Entzauberungen aus der Datenbank angezeigt wird";
		HelpDefault	= "Setzt die angegebene Enchantrix-Option auf ihren Standardwert zurück. Mit dem Schlüsselwort \"all\" werden alle Enchantrix-Optionen zurückgesetzt.";
		HelpDisable	= "Verhindert das automatische Laden von Enchantrix beim Login";
		HelpEmbed	= "Zeige den Text im In-Game Tooltip \n(Hinweis: Einige Funktionen stehen dann nicht zur Verfügung)";
		HelpFindBidauct	= "Suche Auktionen deren Entzauberungswert einen bestimmten Betrag (in Silber) unter dem Gebotspreis liegt";
		HelpFindBuyauct	= "Suche Auktionen deren Entzauberungswert einen bestimmten Prozentsatz unter dem Sofortkaufpreis liegt";
		HelpGuessAuctioneerHsp	= "Wenn die Wertschätzung aktiviert und Auctioneer installiert ist, zeige den maximalen Verkaufspreis (Auctioneer-HVP) für das Entzaubern";
		HelpGuessAuctioneerMedian	= "Wenn die Wertschätzung aktiviert und Auctioneer installiert ist, zeige den durchschnittlichen Verkaufspreis (Auctioneer-MEDIAN) für das Entzaubern";
		HelpGuessBaseline	= "Wenn die Wertschätzung aktiviert ist, zeige den Marktpreis aus der internen Preisliste (Auctioneer wird nicht benötigt)";
		HelpGuessNoauctioneer	= "Die Befehle \"valuate-hsp\" und \"valuate-median\" sind nicht verfügbar weil Auctioneer nicht installiert ist";
		HelpHeader	= "Auswählen ob die Kopfzeile angezeigt werden soll";
		HelpLoad	= "Ladeverhalten von Enchantrix für diesen Charakter ändern";
		HelpLocale	= "Ändern des Gebietsschemas das zur Anzeige \nvon Enchantrix-Meldungen verwendet wird";
		HelpOnoff	= "Schaltet die Anzeige von Entzauberungsdaten ein oder aus";
		HelpPrintin	= "Auswählen in welchem Fenster die Enchantrix-Meldungen angezeigt werden. Es kann entweder der Fensterindex oder der Fenstername angegeben werden.";
		HelpRate	= "Auswählen ob die durchschnittliche Anzahl der Entzauberungen angezeigt wird";
		HelpTerse	= "Aktivieren/Deaktivieren des Kurzinfo-Modus, bei dem nur der Entzauberungswert angezeigt wird. Durch drücken der STRG-Taste werden in diesem Modus alle Infos gezeigt.";
		HelpValue	= "Auswählen ob geschätzte Verkaufspreise aufgrund \nder Anteile an möglichen Entzauberungen angezeigt werden";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "aktGeb";
		FrmtBidbrokerDone	= "Die Auktionssuche (Betrag unter Gebotspreis) ist abgeschlossen.";
		FrmtBidbrokerHeader	= "Auktionen mit %s Silber Einsparung auf den durchschnittlichen Entzauberungswert:";
		FrmtBidbrokerLine	= "%s, Wert bei: %s, %s: %s, Ersparnis: %s, %s weniger, Zeit: %s";
		FrmtBidbrokerMinbid	= "minGeb";
		FrmtBidBrokerSkipped	= "%d Auktionen übersprungen da Gewinnspanne von (%d%%) unterschritten";
		FrmtPctlessDone	= "Die Auktionssuche (Prozent unter Sofortkauf) ist abgeschlossen.";
		FrmtPctlessHeader	= "Sofortkauf-Auktionen mit %d%% Einsparung auf durchschnittlichen Entzauberungswert:";
		FrmtPctlessLine	= "%s, Wert bei: %s, SK: %s, Ersparnis: %s, %s weniger";
		FrmtPctlessSkipped	= "%d Auktionen übersprungen, da Gewinngrenze von (%s) Prozen unterschritten";


		-- Section: Tooltip Messages
		FrmtCounts	= "(Basis=%d, Alt=%d, Neu=%d)";
		FrmtDisinto	= "Mögliche Entzauberung zu:";
		FrmtFound	= "%s wird entzaubert zu:";
		FrmtPriceEach	= "(%s/stk)";
		FrmtSuggestedPrice	= "vorgeschlagener Preis";
		FrmtTotal	= "Gesamtsumme";
		FrmtValueAuctHsp	= "Entzauberungswert (HVP)";
		FrmtValueAuctMed	= "Entzauberungswert (Median)";
		FrmtValueMarket	= "Entzauberungswert (Marktpreis)";
		FrmtWarnAuctNotLoaded	= "Auktionstool nicht geladen, es werden gespeicherte Preise benutzt";
		FrmtWarnNoPrices	= "Keine Preise verfügbar";
		FrmtWarnPriceUnavail	= "Einige Preise nicht verfügbar";


		-- Section: User Interface

	};

	enUS = {


		-- Section: Command Messages
		FrmtActClearall	= "Clearing all enchant data";
		FrmtActClearFail	= "Unable to find item: %s";
		FrmtActClearOk	= "Cleared data for item: %s";
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
		CmdClear	= "clear";
		CmdDefault	= "default";
		CmdDisable	= "disable";
		CmdFindBidauct	= "bidbroker";
		CmdFindBidauctShort	= "bb";
		CmdFindBuyauct	= "percentless";
		CmdFindBuyauctShort	= "pl";
		CmdHelp	= "help";
		CmdLocale	= "locale";
		CmdOff	= "off";
		CmdOn	= "on";
		CmdPrintin	= "print-in";
		CmdToggle	= "toggle";
		ShowCount	= "counts";
		ShowEmbed	= "embed";
		ShowGuessAuctioneerHsp	= "valuate-hsp";
		ShowGuessAuctioneerMed	= "valuate-median";
		ShowGuessBaseline	= "valuate-baseline";
		ShowHeader	= "header";
		ShowRate	= "rates";
		ShowTerse	= "terse";
		ShowValue	= "valuate";
		StatOff	= "Not displaying any enchant data";
		StatOn	= "Displaying configured enchant data";


		-- Section: Config Text
		GuiLoad	= "Load Enchantrix";
		GuiLoad_Always	= "always";
		GuiLoad_Never	= "never";


		-- Section: Game Constants
		ArgSpellname	= "Disenchant";
		Darnassus	= "Darnassus";
		Ironforge	= "City of Ironforge";
		OneLetterGold	= "g";
		OneLetterSilver	= "s";
		Orgrimmar	= "Orgrimmar";
		PatReagents	= "Reagents: (.+)";
		Shattrath	= "Shattrath City";
		ShortDarnassus	= "Dar";
		ShortIronForge	= "IF";
		ShortOrgrimmar	= "Org";
		ShortShattrath	= "Sha";
		ShortStormwind	= "SW";
		ShortThunderBluff	= "TB";
		ShortUndercity	= "UC";
		StormwindCity	= "Stormwind City";
		TextCombat	= "Combat";
		TextGeneral	= "General";
		ThunderBluff	= "Thunder Bluff";
		Undercity	= "Undercity";


		-- Section: Generic Messages
		FrmtCredit	= "  (go to http://enchantrix.org/ to share your data)";
		FrmtWelcome	= "Enchantrix v%s loaded";
		MesgAuctVersion	= "Enchantrix requires Auctioneer version 3.4 or higher. Some features will be unavailable until you update your Auctioneer installation.";


		-- Section: Help Text
		GuiClearall	= "Clear All Enchantrix Data";
		GuiClearallButton	= "Clear All";
		GuiClearallHelp	= "Click here to clear all of Enchantrix data for the current server-realm.";
		GuiClearallNote	= "for the current server-faction";
		GuiCount	= "Show the exact counts in the database";
		GuiDefaultAll	= "Reset All Enchantrix Options";
		GuiDefaultAllButton	= "Reset All";
		GuiDefaultAllHelp	= "Click here to set all Enchantrix options to their default values.\nWARNING: This action is NOT undoable.";
		GuiDefaultOption	= "Reset this setting";
		GuiEmbed	= "Embed info in in-game tooltip";
		GuiLocale	= "Set locale to";
		GuiMainEnable	= "Enable Enchantrix";
		GuiMainHelp	= "Contains settings for Enchantrix \nan AddOn that displays information in item tooltips pertaining to the results of disenchanting said item.";
		GuiOtherHeader	= "Other Options";
		GuiOtherHelp	= "Miscellaneous Enchantrix Options";
		GuiPrintin	= "Select the desired message frame";
		GuiRate	= "Show the average quantity of disenchant";
		GuiReloadui	= "Reload User Interface";
		GuiReloaduiButton	= "ReloadUI";
		GuiReloaduiFeedback	= "Now Reloading the WoW UI";
		GuiReloaduiHelp	= "Click here to reload the WoW User Interface after changing the locale so that the language in this configuration screen matches the one you selected.\nNote: This operation may take a few minutes.";
		GuiTerse	= "Enable terse mode";
		GuiValuateAverages	= "Valuate with Auctioneer Averages";
		GuiValuateBaseline	= "Valuate with Built-in Data";
		GuiValuateEnable	= "Enable Valuation";
		GuiValuateHeader	= "Valuation";
		GuiValuateMedian	= "Valuate with Auctioneer Medians";
		HelpClear	= "Clear the specified item's data (you must shift click insert the item(s) into the command) You may also specify the special keyword \"all\"";
		HelpCount	= "Select whether to show the exact counts in the database";
		HelpDefault	= "Set an Enchantrix option to it's default value. You may also specify the special keyword \"all\" to set all Enchantrix options to their default values.";
		HelpDisable	= "Stops enchantrix from automatically loading next time you log in";
		HelpEmbed	= "Embed the text in the original game tooltip (note: certain features are disabled when this is selected)";
		HelpFindBidauct	= "Find auctions whose possible disenchant value is a certain silver amount less than the bid price";
		HelpFindBuyauct	= "Find auctions whose buyout price is a certain percent less than the possible disenchant value (and, optionally, a certain amount less than the disenchant value)";
		HelpGuessAuctioneerHsp	= "If valuation is enabled, and you have Auctioneer installed, display the sellable price (HSP) valuation of disenchanting the item.";
		HelpGuessAuctioneerMedian	= "If valuation is enabled, and you have Auctioneer installed, display the median based valuation of disenchanting the item.";
		HelpGuessBaseline	= "If valuation is enabled, (Auctioneer not needed) display the baseline valuation of disenchanting the item, based upon the inbuilt prices.";
		HelpGuessNoauctioneer	= "The valuate-hsp and valuate-median commands are not available because you do not have auctioneer installed";
		HelpHeader	= "Select whether to show the header line";
		HelpLoad	= "Change Enchantrix's load settings for this toon";
		HelpLocale	= "Change the locale that is used to display Enchantrix messages";
		HelpOnoff	= "Turns the enchant data display on and off";
		HelpPrintin	= "Select which frame Enchantix will print out it's messages. You can either specify the frame's name or the frame's index.";
		HelpRate	= "Select whether to show the average quantity of disenchant";
		HelpTerse	= "Enable/disable terse mode, showing only disenchant value. Can be overridden by holding down the control key.";
		HelpValue	= "Select whether to show item's estimated values based on the proportions of possible disenchants";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "curBid";
		FrmtBidbrokerDone	= "Bid brokering done";
		FrmtBidbrokerHeader	= "Bids having %s silver savings on average disenchant value (min %%less = %d):";
		FrmtBidbrokerLine	= "%s, Valued at: %s, %s: %s, Save: %s, Less %s, Time: %s";
		FrmtBidbrokerMinbid	= "minBid";
		FrmtBidBrokerSkipped	= "Skipped %d auctions due to profit margin cutoff (%d%%)";
		FrmtPctlessDone	= "Percent less done.";
		FrmtPctlessHeader	= "Buyouts having %d%% savings over average item disenchant value (min savings = %s):";
		FrmtPctlessLine	= "%s, Valued at: %s, BO: %s, Save: %s, Less %s";
		FrmtPctlessSkipped	= "Skipped %d auctions due to profitability cutoff (%s)";


		-- Section: Tooltip Messages
		FrmtCounts	= "    (base=%d, old=%d, new=%d)";
		FrmtDisinto	= "Disenchants into:";
		FrmtFound	= "Found that %s disenchants into:";
		FrmtPriceEach	= "(%s ea)";
		FrmtSuggestedPrice	= "Suggested price:";
		FrmtTotal	= "Total";
		FrmtValueAuctHsp	= "Disenchant value (HSP)";
		FrmtValueAuctMed	= "Disenchant value (Median)";
		FrmtValueMarket	= "Disenchant value (Baseline)";
		FrmtWarnAuctNotLoaded	= "[Auctioneer not loaded, using cached prices]";
		FrmtWarnNoPrices	= "[No prices available]";
		FrmtWarnPriceUnavail	= "[Some prices unavailable]";


		-- Section: User Interface

	};

	esES = {


		-- Section: Command Messages
		FrmtActClearall	= "Eliminando toda información de encantamientos";
		FrmtActClearFail	= "Imposible encontrar artí­culo: %s";
		FrmtActClearOk	= "Información eliminada para el artí­culo: %s";
		FrmtActDefault	= "La opción %s de Enchantrix ha sido reestablecida a sus ajustes por defecto.";
		FrmtActDefaultAll	= "Todas las opciones de Enchantrix han sido reestablecidas a sus ajustes por defecto.";
		FrmtActDisable	= "Ocultando información del artículo: %s ";
		FrmtActEnable	= "Mostrando información del artí­culo: %s ";
		FrmtActEnabledOn	= "Mostrando %s de los artí­culos usando %s";
		FrmtActSet	= "%s establecido a '%s'";
		FrmtActUnknown	= "Comando o palabra clave desconocida: '%s'";
		FrmtActUnknownLocale	= "La localización que has especificado ('%s') no es válida. Las localizaciones válidas son:";
		FrmtPrintin	= "Los mensajes de Enchantrix se imprimirán en la ventana de chat \"%s\"";
		FrmtUsage	= "Uso:";
		MesgDisable	= "Desactivando la carga automática de Enchantrix";
		MesgNotloaded	= "Enchantrix no está cargado. Escriba /enchantrix para más información.";


		-- Section: Command Options
		CmdClearAll	= "todo";
		OptClear	= "([Item]|todo)";
		OptDefault	= "(<opción>|todo)";
		OptFindBidauct	= "<dinero>";
		OptFindBuyauct	= "<porcentaje>";
		OptLocale	= "<localización>";
		OptPrintin	= "(<indiceVentana>[Número]|<nombreVentana>[Serie])";


		-- Section: Commands
		CmdClear	= "borrar";
		CmdDefault	= "original";
		CmdDisable	= "deshabilitar";
		CmdFindBidauct	= "corredorofertas";
		CmdFindBidauctShort	= "co";
		CmdFindBuyauct	= "porcientomenos";
		CmdFindBuyauctShort	= "pm";
		CmdHelp	= "ayuda";
		CmdLocale	= "localidad";
		CmdOff	= "apagado";
		CmdOn	= "prendido";
		CmdPrintin	= "imprimir-en";
		CmdToggle	= "invertir";
		ShowCount	= "conteo";
		ShowEmbed	= "integrar";
		ShowGuessAuctioneerHsp	= "valorizar-pmv";
		ShowGuessAuctioneerMed	= "valorizar-mediano";
		ShowGuessBaseline	= "valorizar-referencia";
		ShowHeader	= "titulo";
		ShowRate	= "razones";
		ShowTerse	= "conciso";
		ShowValue	= "valorizar";
		StatOff	= "Ocultando toda información de los desencantamientos";
		StatOn	= "Mostrando la configuración corriente para la información de los desencantamientos";


		-- Section: Config Text
		GuiLoad	= "Cargar Enchantrix";
		GuiLoad_Always	= "siempre";
		GuiLoad_Never	= "nunca";


		-- Section: Game Constants
		ArgSpellname	= "Desencantar";
		Darnassus	= "Darnassus";
		Ironforge	= "Forjaz";
		OneLetterGold	= "o";
		OneLetterSilver	= "p";
		Orgrimmar	= "Orgrimmar";
		PatReagents	= "Reactivos: (.+)";
		ShortDarnassus	= "Dar";
		ShortIronForge	= "FJ";
		ShortOrgrimmar	= "Org";
		ShortStormwind	= "VT";
		ShortThunderBluff	= "CdT";
		ShortUndercity	= "E";
		StormwindCity	= "Ciudad de Ventormenta";
		TextCombat	= "Combate";
		TextGeneral	= "General";
		ThunderBluff	= "Cima del Trueno";
		Undercity	= "Entrañas";


		-- Section: Generic Messages
		FrmtCredit	= "(ve a http://enchantrix.org/ para comparti­r tu información)";
		FrmtWelcome	= "Enchantrix versión %s cargado";
		MesgAuctVersion	= "Enchantrix requiere la versión 3.4 o mayor de Auctioneer. Algunas características no estarán disponibles hasta que actualices tu instalación de Auctioneer.";


		-- Section: Help Text
		GuiClearall	= "Elimina toda la información de Enchantrix";
		GuiClearallButton	= "Elimina Todo";
		GuiClearallHelp	= "Clic aquí para eliminar toda la información de Enchantrix sobre el reino-facción actual.";
		GuiClearallNote	= "el reino-facción actual.";
		GuiCount	= "Muestra las cuentas exactas en la base de datos";
		GuiDefaultAll	= "Reestablece todas las opciones de Enchantrix";
		GuiDefaultAllButton	= "Reestablece Todo";
		GuiDefaultAllHelp	= "Clic aquí para establecer todas las opciones de Auctioneer a sus valores por defecto. ADVERTENCIA: Esta acción NO es reversible.";
		GuiDefaultOption	= "Reestablece esta opción";
		GuiEmbed	= "Integra la información en la caja de ayuda";
		GuiLocale	= "Establece la localización a";
		GuiMainEnable	= "Activa Enchantrix";
		GuiMainHelp	= "Contiene ajustes para Enchantrix, un accesorio que muestra información en la caja de ayuda de objetos sobre el desencantamiento del objeto en cuestión.";
		GuiOtherHeader	= "Otras Opciones";
		GuiOtherHelp	= "Otras Opciones de Enchantrix";
		GuiPrintin	= "Selecciona la ventana deseada";
		GuiRate	= "Muestra la cantidad promedio de desencantamiento";
		GuiReloadui	= "Recargar Interfaz";
		GuiReloaduiButton	= "Recargar";
		GuiReloaduiFeedback	= "Recargando el Interfaz de WoW";
		GuiReloaduiHelp	= "Presione aquí para recargar el interfaz de WoW tras cambiar la localización para que esta ventana de configuración concuerde con la que has seleccionado. Nota: Esta operación puede llevar unos minutos.";
		GuiTerse	= "Activa el modo conciso";
		GuiValuateAverages	= "Valora con Promedios de Auctioneer";
		GuiValuateBaseline	= "Valora con la información integrada";
		GuiValuateEnable	= "Activa Valoración";
		GuiValuateHeader	= "Valoración";
		GuiValuateMedian	= "Valora con Promedios de Auctioneer";
		HelpClear	= "Elimina la información sobre el objeto especificado (debes usar clic-mayúsculas para incluir el/los objeto(s) en el comando) También puedes especificar las palabra clave \"todo\"";
		HelpCount	= "Determina si se muestran las cuentas exactas en la base de datos";
		HelpDefault	= "Establece una opción de Enchantrix a su valor por defecto. También puedes especificar la palabra clave especial \"todo\" para establecer todas las opciones de Enchantrix a sus valores por defecto.";
		HelpDisable	= "Impide que Enchantrix se cargue automáticamente la próxima vez que te conectes";
		HelpEmbed	= "Inserta el texto en la caja de ayuda original del juego (nota: algunas características se desactivan cuando esta opción es seleccionada)";
		HelpFindBidauct	= "Encuentra subastas en las que el valor de desencantamiento posible es una cantidad de dinero menor que el precio de puja";
		HelpFindBuyauct	= "Encuentra subastas en las que el precio de compra es un porcentaje menor que el valor de desencantamiento posible (y, opcionalmente, una cantidad menor que el valor de desenctanemiento)";
		HelpGuessAuctioneerHsp	= "Si la valoración está activada y tienes Auctioneer instalado, muestra la valoración del precio de venta (PMV) al desencantar el objeto.";
		HelpGuessAuctioneerMedian	= "Si la valoración está activada y tienes Auctioneer instalado, muestra la valoración basada en promedios al desencantar el objeto.";
		HelpGuessBaseline	= "Si la valoración está activada (no se necesita Auctioneer) muestra la valoración base al desencantar el objeto, basado en los precios integrados.";
		HelpGuessNoauctioneer	= "Los comandos valorar-pmv y valorar-promedio no están disponibles porque no tienes Auctioneer instalado";
		HelpHeader	= "Determina si se muestra la línea de título";
		HelpLoad	= "Cambia las opciones de carga de Enchantrix para este personaje";
		HelpLocale	= "Cambia la localización que es usada para mostrar los mensajes de Enchantrix";
		HelpOnoff	= "Activa y desactiva la visualización de la información de encantamientos";
		HelpPrintin	= "Determina en qué ventana se imprimen los mensajes d eEnchantrix. Puedes especificar el nombre de la ventana o su índice.";
		HelpRate	= "Determina si se muestran las cantidades promedio de los desencantamientos";
		HelpTerse	= "Activa y desactiva el modo conciso, mostrando solo el valor de los desencantamientos. Puede ser desactivado temporalmente manteniendo pulsada la tecla Control.";
		HelpValue	= "Determina si se muestran los valores de objeto estimados basados en las proporciones de los posibles desencantamientos";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "pujaActual";
		FrmtBidbrokerDone	= "Corredor de pujas finalizado";
		FrmtBidbrokerHeader	= "Pujas que tienen un promedio de ahorro de %s de plata en el valor de desencantamiento (min %%menos= %d):";
		FrmtBidbrokerLine	= "%s, Valorado en: %s, %s: %s, Ahorra: %s, Menos %s, Tiempo: %s";
		FrmtBidbrokerMinbid	= "pujaMin";
		FrmtBidBrokerSkipped	= "Saltadas %d subastas que están por debajo del margen de beneficios (%d%%)";
		FrmtPctlessDone	= "Porcentajes menores finalizado.";
		FrmtPctlessHeader	= "Compras que tienen %d%% de ahorro sobre el precio promedio de desencantamiento del artí­culo (ahorro min= %s):";
		FrmtPctlessLine	= "%s, Valorado en: %s, Compra: %s, Ahorra: %s, Menos %s";
		FrmtPctlessSkipped	= "Saltadas %d subastas que están por debajo del margen de beneficios (%s)";


		-- Section: Tooltip Messages
		FrmtCounts	= "(referencia=%d, viejo=%d, nuevo=%d)";
		FrmtDisinto	= "Se desencanta en:";
		FrmtFound	= "Se encontró que %s se desencanta en:";
		FrmtPriceEach	= "(%s c/u)";
		FrmtSuggestedPrice	= "Precio Sugerido:";
		FrmtTotal	= "Total";
		FrmtValueAuctHsp	= "Valor de desencantamiento (PMV)";
		FrmtValueAuctMed	= "Valor de desencantamiento (Promedio)";
		FrmtValueMarket	= "Valor de desencantamiento (Referencia)";
		FrmtWarnAuctNotLoaded	= "[Auctioneer no se ha cargado, usando los precios guardados]";
		FrmtWarnNoPrices	= "[No hay precios disponibles]";
		FrmtWarnPriceUnavail	= "[Algunos precios no están disponibles]";


		-- Section: User Interface

	};

	frFR = {


		-- Section: Command Messages
		FrmtActClearall	= "Effacement de toutes les données d'enchantement";
		FrmtActClearFail	= "Impossible de trouver l'objet : %s";
		FrmtActClearOk	= "Information effacée pour l'objet : %s";
		FrmtActDefault	= "L'option %s d'Enchantrix a été réinitialisée à sa valeur par défaut";
		FrmtActDefaultAll	= "Toutes les options d'Enchantrix ont été réinitialisées à  leurs valeurs par défaut.";
		FrmtActDisable	= "N'affiche pas les données de l'objet %s";
		FrmtActEnable	= "Affichage des données de l'objet %s";
		FrmtActEnabledOn	= "Affichage de l'objet %s sur %s";
		FrmtActSet	= "Fixe la valeur de %s à '%s'";
		FrmtActUnknown	= "Mot-clé de commande inconnu : '%s'";
		FrmtActUnknownLocale	= "La langue que vous avez specifiée ('%s') est inconnue. Les langues valides sont :";
		FrmtPrintin	= "Les messages d'Enchantrix seront maintenant affichés dans la fenêtre de dialogue \"%s\"";
		FrmtUsage	= "Syntaxe :";
		MesgDisable	= "Désactivation du chargement automatique d'Enchantrix";
		MesgNotloaded	= "Enchantrix n'est pas chargé. Tapez /enchantrix pour plus d'informations.";


		-- Section: Command Options
		CmdClearAll	= "tout";
		OptClear	= "([Objet]|tout)";
		OptDefault	= "([option]|tout)";
		OptFindBidauct	= "<argent>";
		OptFindBuyauct	= "<pourcent>";
		OptLocale	= "<langue>";
		OptPrintin	= "(<fenetreIndex>[nombre]|<fenetreNom>[Chaine])";


		-- Section: Commands
		CmdClear	= "effacer";
		CmdDefault	= "par défaut";
		CmdDisable	= "désactiver";
		CmdFindBidauct	= "agent-enchere";
		CmdFindBidauctShort	= "ae";
		CmdFindBuyauct	= "sans-pourcentage";
		CmdFindBuyauctShort	= "pl";
		CmdHelp	= "aide";
		CmdLocale	= "langue";
		CmdOff	= "arret";
		CmdOn	= "marche";
		CmdPrintin	= "afficher-dans";
		CmdToggle	= "activer-desactiver";
		ShowCount	= "comptes";
		ShowEmbed	= "integrer";
		ShowGuessAuctioneerHsp	= "evaluer-pvm";
		ShowGuessAuctioneerMed	= "evaluer-median";
		ShowGuessBaseline	= "evaluer-reference";
		ShowHeader	= "en-tete";
		ShowRate	= "taux";
		ShowTerse	= "concis";
		ShowValue	= "evaluer";
		StatOff	= "Aucune donnée d'enchantement affichée";
		StatOn	= "Affichage des données d'enchantement formatées";


		-- Section: Config Text
		GuiLoad	= "Charger Enchantrix";
		GuiLoad_Always	= "toujours";
		GuiLoad_Never	= "jamais";


		-- Section: Game Constants
		ArgSpellname	= "Désenchanter";
		Darnassus	= "Darnassus";
		Ironforge	= "Ironforge";
		OneLetterGold	= "po";
		OneLetterSilver	= "pa";
		Orgrimmar	= "Orgrimmar";
		PatReagents	= "Ingrédients: (.+)";
		Shattrath	= "Ville de Shattrath";
		ShortDarnassus	= "Darna";
		ShortIronForge	= "IF";
		ShortOrgrimmar	= "Orgri";
		ShortShattrath	= "Sha";
		ShortStormwind	= "SW";
		ShortThunderBluff	= "TB";
		ShortUndercity	= "UC";
		StormwindCity	= "Cité de Stormwind";
		TextCombat	= "Combat";
		TextGeneral	= "Général";
		ThunderBluff	= "Thunder Bluff";
		Undercity	= "Undercity";


		-- Section: Generic Messages
		FrmtCredit	= "(visitez http://enchantrix.org/ pour partager vos données)";
		FrmtWelcome	= "Enchantrix v%s chargé";
		MesgAuctVersion	= "Enchantrix nécessite Auctioneer version 3.4 ou plus. Quelques fonctions seront désactivées tant que vous ne mettrez pas à jour auctioneer.";


		-- Section: Help Text
		GuiClearall	= "Réinitialiser toutes les données d'Enchantrix";
		GuiClearallButton	= "Effacer tout";
		GuiClearallHelp	= "Cliquer ici pour réinitialiser toutes les données d'Enchantrix pour le serveur-faction actuel.";
		GuiClearallNote	= "pour le serveur-faction actuel";
		GuiCount	= "Afficher le compte exact dans la base de données";
		GuiDefaultAll	= "Réinitialiser toutes les Options d'Enchantrix";
		GuiDefaultAllButton	= "Tout réinitialiser";
		GuiDefaultAllHelp	= "Cliquer ici pour réinitialiser toutes les options d'Enchantrix. ATTENTION: Cette opération est irréversible.";
		GuiDefaultOption	= "Réinitialiser ce réglage";
		GuiEmbed	= "Intégrer les infos dans les bulles d'aide originales";
		GuiLocale	= "Changer la langue pour";
		GuiMainEnable	= "Activer Enchantrix";
		GuiMainHelp	= "Contient les règlages d'Enchantrix, un AddOn qui affiche les informations liées au désenchantement des objets.";
		GuiOtherHeader	= "Autres Options";
		GuiOtherHelp	= "Options diverses d'Enchantrix";
		GuiPrintin	= "Choisir la fenêtre de message souhaitée";
		GuiRate	= "Afficher la quantité moyenne de désenchantement";
		GuiReloadui	= "Recharger l'Interface Utilisateur";
		GuiReloaduiButton	= "RechargerIU";
		GuiReloaduiFeedback	= "Rechargement de l'IU de WoW";
		GuiReloaduiHelp	= "Cliquer ici pour recharger l'Interface Utilisateur (IU) de WoW après avoir changé la langue afin de refléter les changements dans cet écran de configuration. Remarque: Cette opération peut prendre quelques minutes.";
		GuiTerse	= "Active le mode concis";
		GuiValuateAverages	= "Evaluer avec les moyennes d'Auctioneer";
		GuiValuateBaseline	= "Evaluer avec les données intégrées.";
		GuiValuateEnable	= "Activer Evaluation";
		GuiValuateHeader	= "Evaluation";
		GuiValuateMedian	= "Evaluer avec les moyennes d'Auctioneer";
		HelpClear	= "Efface les données de l'objet spécifié (vous devez maj-cliquer le ou les objets dans la ligne de commande) Vous pouvez également spécifier le mot-clef \"tout\"";
		HelpCount	= "Choisir d'afficher le compte exact dans la base de données.";
		HelpDefault	= "Réinitialise une option d'Enchantrix à sa valeur par défaut. Vous pouvez spécifier le mot-clef \"tout\" pour réinitialiser toutes les options d'Enchantrix.";
		HelpDisable	= "Empêche le chargement automatique d'Enchantrix lors de votre prochaine connexion.";
		HelpEmbed	= "Intègre le texte dans la bulle d'aide originale (Remarque: Certaines fonctionnalités sont désactivées dans ce cas)";
		HelpFindBidauct	= "Trouver les enchères dont la valeur de désenchantement potentielle est inférieure d'un certain montant en pièces d'argent au prix d'enchère.";
		HelpFindBuyauct	= "Trouver les enchères dont la valeur de désenchantement potentielle est infèrieure d'un certain pourcentage au prix d'achat immédiat.";
		HelpGuessAuctioneerHsp	= "Si évaluation est activé et qu'Auctioneer est installé, affiche l'estimation de plus haut prix de vente (HSP) de désenchantement de cet objet.";
		HelpGuessAuctioneerMedian	= "Si évaluation est activé et qu'Auctioneer est installé, affiche l'évaluation basée sur la moyenne de désenchantement de l'objet.";
		HelpGuessBaseline	= "Si évaluation est activé (Auctioneer n'est pas nécessaire), affiche les informations de base de désenchantement, en s'appuyant sur la liste de prix intégrée.";
		HelpGuessNoauctioneer	= "Les commandes \"evaluer-hsp\" et \"evaluer-moyenne\" ne sont pas disponibles car vous n'avez pas Auctioneer d'installé";
		HelpHeader	= "Choisir d'afficher la ligne d'en-tête";
		HelpLoad	= "Change les règlages de chargement pour ce personnage";
		HelpLocale	= "Change la langue utilisée pour afficher les messages d'Enchantrix";
		HelpOnoff	= "Active ou désactive les informations d'enchantement";
		HelpPrintin	= "Choisir dans quelle fenêtre Enchantrix affichera ses messages. Vous pouvez spécifier le nom de la fenêtre ou son index.";
		HelpRate	= "Choisir d'afficher la quantité moyenne de désenchantement";
		HelpTerse	= "Active ou désactive le mode concis, qui ne montre que les valeurs de désenchantement. Peut être annulé en appuyant sur la touche contrôle.";
		HelpValue	= "Choisir d'afficher les valeurs estimées basées sur les proportions de désenchantement possible";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "EnchAct";
		FrmtBidbrokerDone	= "L'agent d'enchères a terminé";
		FrmtBidbrokerHeader	= "Enchères présentant %s pièces d'argent d'économie sur la valeur moyenne de désenchantement (min. %d%% de moins) :";
		FrmtBidbrokerLine	= "%s, Estimé à : %s, %s: %s, Economie: %s, Moins %s, Temps: %s";
		FrmtBidbrokerMinbid	= "EnchMin";
		FrmtBidBrokerSkipped	= "%d enchères ignorées pour marge trop faible (%d%%)";
		FrmtPctlessDone	= "Pourcentage inférieur terminé.";
		FrmtPctlessHeader	= "Achats immédiats %d%% économisant plus que la valeur moyenne de désenchantement de l'objet (min. %s d'économie) :";
		FrmtPctlessLine	= "%s, Estimé à : %s, AI: %s, Economie: %s, Moins %s";
		FrmtPctlessSkipped	= "%d enchères ignorées pour marge trop faible (%s)";


		-- Section: Tooltip Messages
		FrmtCounts	= "(base=%d, ancienne=%d, nouvelle=%d)";
		FrmtDisinto	= "Se désenchante en :";
		FrmtFound	= "%s se désenchante en :";
		FrmtPriceEach	= "(%s l'unité)";
		FrmtSuggestedPrice	= "Prix suggéré:";
		FrmtTotal	= "Total";
		FrmtValueAuctHsp	= "Valeur désenchantée (HSP)";
		FrmtValueAuctMed	= "Valeur désenchantée (Moyenne)";
		FrmtValueMarket	= "Valeur désenchantée (Référence)";
		FrmtWarnAuctNotLoaded	= "[Auctioneer non chargé, utilisation du prix en cache]";
		FrmtWarnNoPrices	= "[Aucun prix disponible]";
		FrmtWarnPriceUnavail	= "[Quelques prix indisponibles]";


		-- Section: User Interface

	};

	itIT = {


		-- Section: Command Messages
		FrmtActClearall	= "Eliminando tutti i dati di enchant";
		FrmtActClearFail	= "Impossibile trovare l'oggetto: %s";
		FrmtActClearOk	= "Eliminati i dati dell'oggetto: %s";
		FrmtActDefault	= "L'opzione %s di Enchantrix e' stata resettata al valore di default";
		FrmtActDefaultAll	= "Tutte le opzioni di Enchantrix sono state resettate al valore di default.";
		FrmtActDisable	= "Non visualizzo i dati dell'oggetto %s";
		FrmtActEnable	= "Visualizzo i dati dell'oggetto %s";
		FrmtActEnabledOn	= "Visualizzo i %s dell'oggetto in %s";
		FrmtActSet	= "Imposta %s a '%s'";
		FrmtActUnknown	= "Comando sconosciuto: '%s'";
		FrmtActUnknownLocale	= "La lingua specificata ('%s') e' sconosciuta. Le lingue valide sono:";
		FrmtPrintin	= "I messaggi di Enchantrix compariranno nella chat \"%s\"";
		FrmtUsage	= "Sintassi:";
		MesgDisable	= "Il caricamento automatico di Enchantrix è disabilitato";
		MesgNotloaded	= "Enchantrix non e' caricato. Digita /enchantrix per maggiori informazioni.";


		-- Section: Command Options
		CmdClearAll	= "tutto";
		OptClear	= "([item]|tutto)";
		OptDefault	= "(<opzione>|tutto)";
		OptFindBidauct	= "<denaro>";
		OptFindBuyauct	= "<percento>";
		OptLocale	= "<lingua>";
		OptPrintin	= "(<frameIndex>[Numero]|<frameName>[Stringa])";


		-- Section: Commands
		CmdClear	= "cancella";
		CmdDefault	= "default";
		CmdDisable	= "disabilita";
		CmdFindBidauct	= "bidbroker";
		CmdFindBidauctShort	= "bb";
		CmdFindBuyauct	= "percentomeno";
		CmdFindBuyauctShort	= "pm";
		CmdHelp	= "aiuto";
		CmdLocale	= "lingua";
		CmdOff	= "fuori di";
		CmdOn	= "abilitato";
		CmdPrintin	= "stampa-in";
		CmdToggle	= "inverti";
		ShowCount	= "conteggio";
		ShowEmbed	= "integra";
		ShowGuessAuctioneerHsp	= "valuta-hsp";
		ShowGuessAuctioneerMed	= "valuta-mediana";
		ShowGuessBaseline	= "valuta-base";
		ShowHeader	= "intestazione";
		ShowRate	= "tassi";
		ShowTerse	= "conciso";
		ShowValue	= "valuta";
		StatOff	= "Visualizzazione dei dati di enchant disabilitata";
		StatOn	= "Visualizzazione dei dati di enchant configurati";


		-- Section: Config Text
		GuiLoad	= "Carica Enchantrix";
		GuiLoad_Always	= "sempre";
		GuiLoad_Never	= "mai";


		-- Section: Game Constants
		ArgSpellname	= "Disincanta";
		Darnassus	= "Darnassus";
		Ironforge	= "Ironforge";
		OneLetterGold	= "g";
		OneLetterSilver	= "s";
		Orgrimmar	= "Orgrimmar";
		PatReagents	= "Reagente:(.+)";
		ShortDarnassus	= "Darn.";
		ShortIronForge	= "IF";
		ShortOrgrimmar	= "Org";
		ShortStormwind	= "SW";
		ShortThunderBluff	= "TB";
		ShortUndercity	= "UC";
		StormwindCity	= "Stormwind";
		TextCombat	= "Combattimento";
		TextGeneral	= "Generico";
		ThunderBluff	= "Thunder Bluff";
		Undercity	= "Undercity";


		-- Section: Generic Messages
		FrmtCredit	= "(vai su http://enchantrix.org/ per condividere i tuoi dati) ";
		FrmtWelcome	= "Enchantrix v%s caricato";
		MesgAuctVersion	= "Enchantrix richiede Auctioneer versione 3.4 o superiore. Alcune funzionalità non saranno disponibili finché Auctioneer non verrà aggiornato.";


		-- Section: Help Text
		GuiClearall	= "Cancella tutti i dati di Enchantrix";
		GuiClearallButton	= "Cancella tutto";
		GuiClearallHelp	= "Clicca qui per eliminare tutti i dati di Enchantrix per il server/realm corrente";
		GuiClearallNote	= "per il corrente server/fazione";
		GuiCount	= "Mostra il conteggio esatto nel database";
		GuiDefaultAll	= "Ripristina tutte le opzioni di Enchantrix";
		GuiDefaultAllButton	= "Ripristina tutto";
		GuiDefaultAllHelp	= "Clicca qui per resettare tutte le opzioni di Enchantrix. ATTENZIONE: Questa azione non è reversibile.";
		GuiDefaultOption	= "Ripristina questa opzione";
		GuiEmbed	= "Aggiungi le informazioni al tooltip";
		GuiLocale	= "Imposta la lingua a";
		GuiMainEnable	= "Abilita Enchantrix";
		GuiMainHelp	= "Contiene le opzioni di Enchantrix, un AddOn che mostra nel tooltip informazioni relative al disenchant dell'oggetto selezionato";
		GuiOtherHeader	= "Altre opzioni";
		GuiOtherHelp	= "Opzioni aggiuntive di Enchantrix";
		GuiPrintin	= "Seleziona la finestra di chat desiderata";
		GuiRate	= "Mostra la quantità  media di disenchant";
		GuiReloadui	= "Ricarica l'interfaccia utente";
		GuiReloaduiButton	= "ReloadUI";
		GuiReloaduiFeedback	= "ReloadUI in corso";
		GuiReloaduiHelp	= "Dopo aver cambiato la lingua, cliccare qui per ricaricare l'interfaccia utente di WoW, e visualizzare così la lingua scelta. L'operazione può richiedere qualche minuto.";
		GuiTerse	= "Abilita modo conciso";
		GuiValuateAverages	= "Valuta con le medie di Auctioneer";
		GuiValuateBaseline	= "Valuta con i dati di base";
		GuiValuateEnable	= "Abilita la valutazione";
		GuiValuateHeader	= "Valutazione";
		GuiValuateMedian	= "Valuta con le mediane di Auctioneer";
		HelpClear	= "Cancella i dati sull'oggetto specificato (devi inserire l'oggetto nella linea di comando usando shift-click). Puoi anche specificare il comando speciale \"tutto\"";
		HelpCount	= "Scegli se visualizzare o meno i conteggi esatti nel database";
		HelpDefault	= "Imposta un'opzione di Enchantrix al suo valore di default. Puoi inoltre specificare la parola chiave \"tutto\" per impostare tutte le opzioni di Enchantrix ai loro valori di default.";
		HelpDisable	= "Impedisci che Enchantrix sia caricato automaticamente la prossima volta che entri nel gioco.";
		HelpEmbed	= "Integra il testo nel tooltip originale del gioco. (nota: alcune caratteristiche vengono disabilitate quando si seleziona questa opzione)";
		HelpFindBidauct	= "Trova gli oggetti con il valore possibile di disenchant  inferiore di un importo specificato all'offerta fatta in asta (bid)";
		HelpFindBuyauct	= "Trova glioggetti con il valore possibile di disenchant inferiore di una data percentuale all'offerta fatta in asta (bid)";
		HelpGuessAuctioneerHsp	= "Se la valutazione Ã¨ attivata, e tu hai Auctioneer installato, mostra la valutazione massima del prezzo di vendita dell'oggetto disincantato.";
		HelpGuessAuctioneerMedian	= "Se la valutazione è attivata, e tu hai Auctioneer installato, mostra la valutazione mediana dell'oggetto disincantato.";
		HelpGuessBaseline	= "Se la valutazione è abilitata (Auctioneer non è necessario), visualizza il prezzo di base per il disenchant dell'oggetto (dai dati interni)";
		HelpGuessNoauctioneer	= "I comandi valuate-hsp e valuate-median non sono disponibili perchè non hai auctioneer installato.";
		HelpHeader	= "Seleziona per mostrare la linea del titolo";
		HelpLoad	= "Cambia le impostazioni di caricamento di Enchantrix per questo personaggio";
		HelpLocale	= "Cambia la lingua con la quale vuoi che Enchantrix comunichi";
		HelpOnoff	= "Abilita o disabilita le informazioni sull'incantesimo";
		HelpPrintin	= "Seleziona in quale finestra di chat verranno mandati i messaggi di Enchantrix. Puoi specificare il nome del frame oppure l'indice.";
		HelpRate	= "Seleziona se visualizzare o meno la quantità media di disenchant";
		HelpTerse	= "Abilita/disabilita il modo conciso, facendo vedre solo il valore disenchant. Può essere cambiato tenendo premuto il tasto control.";
		HelpValue	= "Seleziona per visualizzare il valore stimato dell'oggetto in base alla proporzione dei disincantamenti possibili";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "curBid";
		FrmtBidbrokerDone	= "Bid brokering terminato";
		FrmtBidbrokerHeader	= "Bid che hanno %s silver di meno del valore medio di disenchant:";
		FrmtBidbrokerLine	= "%s, Valutato: %s, %s: %s, Risparmia: %s, Meno %s, Tempo: %s";
		FrmtBidbrokerMinbid	= "minBid";
		FrmtBidBrokerSkipped	= "Saltate le aste %d a causa del superamento del limite del margine di profitto (%d%%)";
		FrmtPctlessDone	= "Percentomeno completato";
		FrmtPctlessHeader	= "Buyout che hanno un risparmio di %s sul prezzo medio di disincantamento: ";
		FrmtPctlessLine	= "%s, Valutato: %s, BO: %s, Risparmio: %s, Meno %s ";
		FrmtPctlessSkipped	= "Saltate le aste %d per un taglio del profitto (%s)";


		-- Section: Tooltip Messages
		FrmtCounts	= "(base=%d, vecchio=%d, nuovo=%d) ";
		FrmtDisinto	= "Si disincanta in:";
		FrmtFound	= "%s si disincanta in: ";
		FrmtPriceEach	= "(%s ognuno)";
		FrmtSuggestedPrice	= "Prezzo suggerito:";
		FrmtTotal	= "Totale";
		FrmtValueAuctHsp	= "Valore di disincantamento(HSP)";
		FrmtValueAuctMed	= "Valore di disincantamento (Medio)";
		FrmtValueMarket	= "Valore di disincantamento (Base)";
		FrmtWarnAuctNotLoaded	= "[Auctioneer non caricato, uso i prezzi nascosti]";
		FrmtWarnNoPrices	= "[Prezzi non disponibili]";
		FrmtWarnPriceUnavail	= "[Alcuni prezzi non disponibili]";


		-- Section: User Interface

	};

	koKR = {


		-- Section: Command Messages
		FrmtActClearall	= "모든 마법부여 데이터를 삭제합니다.";
		FrmtActClearFail	= "아이템을 찾을 수 없음: %s";
		FrmtActClearOk	= "아이템 데이터 삭제: %s ";
		FrmtActDefault	= "Enchantrix의 %s 설정이 초기화 되었습니다.";
		FrmtActDefaultAll	= "모든 Enchantrix 설정이 초기화 되었습니다.";
		FrmtActDisable	= "아이템의 %s 데이터를 표시하지 않습니다.";
		FrmtActEnable	= "아이템의 %s 데이터를 표시합니다.";
		FrmtActEnabledOn	= "아이템의 %s 를 %s에 표시합니다.";
		FrmtActSet	= "%s를 '%s'|1으로;로; 설정합니다.";
		FrmtActUnknown	= "알 수 없는 명령어: '%s'";
		FrmtActUnknownLocale	= "('%s|1')은;')는; 알 수 없는 지역입니다. 올바른 지역 설정은 다음과 같습니다:";
		FrmtPrintin	= "Enchantrix의 메세지는 \"%s\" 채팅창에 출력됩니다.";
		FrmtUsage	= "사용법:";
		MesgDisable	= "Enchantrix를 자동 로딩하지 않습니다.";
		MesgNotloaded	= "Enchantrix가 로드되지 않았습니다. /enchantrix 를 입력하시면 더 많은 정보를 보실 수 있습니다.";


		-- Section: Command Options
		CmdClearAll	= "모두";
		OptClear	= "([아이템]|모두)";
		OptDefault	= "(<설정>|모두)";
		OptFindBidauct	= "<실버>";
		OptFindBuyauct	= "<퍼센트>";
		OptLocale	= "<지역>";
		OptPrintin	= "(<창번호>[번호]|<창이름>[문자열])";


		-- Section: Commands
		CmdClear	= "삭제";
		CmdDefault	= "기본값";
		CmdDisable	= "비활성화";
		CmdFindBidauct	= "입찰중개인";
		CmdFindBidauctShort	= "bb";
		CmdFindBuyauct	= "이하확률";
		CmdFindBuyauctShort	= "pl ";
		CmdHelp	= "도움말";
		CmdLocale	= "지역";
		CmdOff	= "끔";
		CmdOn	= "켬";
		CmdPrintin	= "출력하는곳";
		CmdToggle	= "전환";
		ShowCount	= "수량";
		ShowEmbed	= "내장";
		ShowGuessAuctioneerHsp	= "평가된 HSP";
		ShowGuessAuctioneerMed	= "평가된 중앙값";
		ShowGuessBaseline	= "평가된 기본값";
		ShowHeader	= "머리말";
		ShowRate	= "비율";
		ShowTerse	= "간결";
		ShowValue	= "평가";
		StatOff	= "어떤 마법부여자료도 표시하지 않음";
		StatOn	= "설정된 마법부여자료 표시";


		-- Section: Config Text
		GuiLoad	= "Enchantrix 로드";
		GuiLoad_Always	= "항상";
		GuiLoad_Never	= "사용안함";


		-- Section: Game Constants
		ArgSpellname	= "마력추출";
		Darnassus	= "다르나서스";
		Ironforge	= "아이언포지";
		OneLetterGold	= "골드";
		OneLetterSilver	= "실버";
		Orgrimmar	= "오그리마";
		PatReagents	= "재료: (.+)";
		ShortDarnassus	= "다르";
		ShortIronForge	= "아포";
		ShortOrgrimmar	= "오그";
		ShortStormwind	= "스톰";
		ShortThunderBluff	= "썬더";
		ShortUndercity	= "언더";
		StormwindCity	= "스톰윈드";
		TextCombat	= "전투";
		TextGeneral	= "일반";
		ThunderBluff	= "썬더블러프";
		Undercity	= "언더시티";


		-- Section: Generic Messages
		FrmtCredit	= "(당신의 데이터를 공유하려면 http://enchantrix.org/ 에 방문하십시오.)";
		FrmtWelcome	= "Enchantrix v%s 로딩완료";
		MesgAuctVersion	= "Enchantrix는 Auctioneer 버전 3.4 이상이 필요합니다. 여러분이 새로운 Auctioneer를 설치하기전까지 몇가지 기능을 사용할 수 없습니다.";


		-- Section: Help Text
		GuiClearall	= "모든 Enchantrix 데이터 삭제";
		GuiClearallButton	= "모두 삭제";
		GuiClearallHelp	= "클릭하면 현재 서버의 Enchantrix 자료가 모두 삭제됩니다.";
		GuiClearallNote	= "현재 서버-진영";
		GuiCount	= "자료의 정확한 수량 보기";
		GuiDefaultAll	= "모든 Enchantrix 옵션 초기화";
		GuiDefaultAllButton	= "모두 초기화";
		GuiDefaultAllHelp	= "클릭하면 Enchantrix의 설정을 기본값으로 돌립니다. 경고: 이 작업은 되돌릴 수 없습니다.";
		GuiDefaultOption	= "이 설정 초기화";
		GuiEmbed	= "정보를 기본 툴팁에 포함";
		GuiLocale	= "지역설정";
		GuiMainEnable	= "Enchantrix 활성화";
		GuiMainHelp	= "아이템에 대한 마력추출의 결과와 관련된 정보를 툴팁에 표시해주는 애드온인 Enchantrix에 관한 설정을 포함합니다.";
		GuiOtherHeader	= "기타 설정";
		GuiOtherHelp	= "기타 Enchantrix 설정";
		GuiPrintin	= "원하는 메시지 프레임을 선택";
		GuiRate	= "평균적인 마력추출 양 보기";
		GuiReloadui	= "UI 재시작";
		GuiReloaduiButton	= "UI 재시작";
		GuiReloaduiFeedback	= "WOW UI를 재시작하는 중";
		GuiReloaduiHelp	= "지역코드를 변경후에 WOW 사용자 인터페이스를 변경하려면 이곳을 클릭해서 여러분이 선택한 것과 설정 화면의 언어가 같아지도록 하십시오. 주의: 이 작업은 몇분 정도 걸릴 수 있습니다.";
		GuiTerse	= "간결 모드 사용";
		GuiValuateAverages	= "Auctioneer 평균으로 평가";
		GuiValuateBaseline	= "내장된 자료를 이용해 평가";
		GuiValuateEnable	= "평가 활성화";
		GuiValuateHeader	= "평가";
		GuiValuateMedian	= "Autctioneer 중앙값으로 평가";
		HelpClear	= "지정된 아이템의 데이타를 삭제합니다.(이때 아이템지정은 Shift-click 으로 명령어창에 넣어야합니다.) 모든 아이템데이타를 삭제하기 위해 \"모두\" 를 사용할 수 있습니다.";
		HelpCount	= "데이타베이스에 있는 정확한 수량을 표시할지 선택합니다.";
		HelpDefault	= "Enchantrix의 옵션을 기본값으로 설정합니다. 모든 Enchantrix 설정을 기본값으로 하시려면 \"모두\" 를 사용할 수 있습니다.";
		HelpDisable	= "다음 로그인시 자동으로 Enchantrix를 로드하지 않음";
		HelpEmbed	= "내용을 기본 게임 툴팁에 포함(이 설정이 선택되면, 일부 기능을 사용할수 없습니다.)";
		HelpFindBidauct	= "가능한 마력추출 가격이 입찰가 보다 낮은 경매품 찾기";
		HelpFindBuyauct	= "가능한 마력추출 가격이 즉시 구입가보다 낮은 경매품 찾기";
		HelpGuessAuctioneerHsp	= "만약 평가가 활성화 되었으면, 그리고 Auctioneer가 설치되어 있으면, 아이템을 마력추출시 가치의 최고판매가능가격(HSP)이 표시됩니다.";
		HelpGuessAuctioneerMedian	= "만약 평가가 활성화 되었으면, 그리고 Auctioneer가 설치되어 있으면, 아이템을 마력추출시 가치의 중앙값이 표시됩니다.";
		HelpGuessBaseline	= "만약 평가가 활성화 되었으면, (Autctionner는 필요하지 않습니다) 아이템을 마력추출시 가치의 기본값이 표시됩니다.";
		HelpGuessNoauctioneer	= "Auctioneer가 설치되어 있지 않아서 평가된 HSP, 평가된 중앙값 명령어를 사용할 수 없습니다.";
		HelpHeader	= "머리말 보기 여부 선택";
		HelpLoad	= "이 케릭터의 Enchantrix 로드 설정 변경";
		HelpLocale	= "Enchantrix가 메시지를 표시하기위해 사용하는 언어 변경";
		HelpOnoff	= "Enchantrix자료 표시 켬/끔";
		HelpPrintin	= "Enchantrix가 메시지를 출력할 프레임 선택. 프레임의 이름이나, 번호를 사용할 수 있습니다.";
		HelpRate	= "평균적인 마력추출 양의 보기 여부 선택";
		HelpTerse	= "마력추출 가격만 보이도록하는 간결 모드 사용/사용안함. 컨트롤 키를 눌러서 겹쳐쓸 수 있음.";
		HelpValue	= "가능한 마력추출 비율에 근거한 아이템의 평가값 보기 여부 선택";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "현재 입찰";
		FrmtBidbrokerDone	= "입찰 중개 완료";
		FrmtBidbrokerHeader	= "입찰이 평균 마력추출 가격에서 %S 실버 절약되었습니다. (최소 %%less = %d):";
		FrmtBidbrokerLine	= "%s, 가격: %s, %s: %s, 감소: %s, %s 이하, 시간: %s";
		FrmtBidbrokerMinbid	= "최소 입찰";
		FrmtBidBrokerSkipped	= "%d개의 경매품이 마진(%d%%)을 위해 건너뛰어짐";
		FrmtPctlessDone	= "완료 이하 확률. ";
		FrmtPctlessHeader	= "즉시 구입가격이 평균 마력추출 가격상에서 %d%% 절약되었습니다.:";
		FrmtPctlessLine	= "%s, 가격: %s, BO: %s, 감소: %s, %s 이하";
		FrmtPctlessSkipped	= "%d개의 경매품이 수익성(%s)을 위해 건너뛰어짐";


		-- Section: Tooltip Messages
		FrmtCounts	= "(기준=%d, 과거=%d, 신규=%d)";
		FrmtDisinto	= "마력 추출:";
		FrmtFound	= "%s|1이;가; 마력추출되는 아이템: ";
		FrmtPriceEach	= "(%s 개)";
		FrmtSuggestedPrice	= "제안 가격:";
		FrmtTotal	= "총";
		FrmtValueAuctHsp	= "마력추출 가격 (HSP)";
		FrmtValueAuctMed	= "마력추출 가격 (중앙값)";
		FrmtValueMarket	= "마력추출 가격 (기준값)";
		FrmtWarnAuctNotLoaded	= "[Auctioneer가 실행되지 않아서 저장된 가격을 사용합니다.]";
		FrmtWarnNoPrices	= "[가능한 가격 없음]";
		FrmtWarnPriceUnavail	= "[일부 가격을 사용할 수 없음]";


		-- Section: User Interface

	};

	nlNL = {


		-- Section: Command Messages
		FrmtActClearall	= "Wissen van alle enchant gegevens";
		FrmtActClearFail	= "Kan item niet vinden: %s";
		FrmtActClearOk	= "Data gewist voor item: %s";
		FrmtActDefault	= "Enchantrix' %s optie is teruggezet naar standaard instelling";
		FrmtActDefaultAll	= "Alle Enchantrix opties zijn teruggezet naar standaard instelling.";
		FrmtActDisable	= "Item's %s gegevens worden niet weergegeven";
		FrmtActEnable	= "Item's %s gegevens worden weergegeven";
		FrmtActEnabledOn	= "Weergeven Item's %s op %s";
		FrmtActSet	= "Stel %s naar '%s' in";
		FrmtActUnknown	= "Onbekende opdracht: '%s'";
		FrmtActUnknownLocale	= "De opgegeven taal ('%s') is onbekend. Geldige talen zijn:";
		FrmtPrintin	= "Berichten van Enchantrix worden nu weergegeven op de \"%s\" chat frame";
		FrmtUsage	= "Gebruik:";
		MesgDisable	= "Uitschakelen automatisch laden van Enchantrix";
		MesgNotloaded	= "Enchantrix is niet geladen. Type /enchantrix voor meer info.";


		-- Section: Command Options
		OptFindBidauct	= "<zilver>";
		OptFindBuyauct	= "<procent>";
		OptLocale	= "<taal>";
		OptPrintin	= "(<frameIndex>[Nummer]|<frameNaam>[Tekst])";


		-- Section: Commands
		ShowTerse	= "Beknopt";
		StatOff	= "Enchant gegevens worden niet getoond";
		StatOn	= "De geconfigureerde enchant gegevens worden getoond";


		-- Section: Config Text
		GuiLoad	= "Laden van Enchantrix";
		GuiLoad_Always	= "altijd";
		GuiLoad_Never	= "nooit";


		-- Section: Game Constants
		ArgSpellname	= "Disenchant";
		Darnassus	= "Darnassus";
		Ironforge	= "City of Ironforge";
		OneLetterGold	= "g";
		OneLetterSilver	= "s";
		Orgrimmar	= "Orgrimmar";
		PatReagents	= "Reagents: (.+)";
		ShortDarnassus	= "Dar";
		ShortIronForge	= "IF";
		ShortOrgrimmar	= "Org";
		ShortStormwind	= "SW";
		ShortThunderBluff	= "TB";
		ShortUndercity	= "UC";
		StormwindCity	= "Stormwind City";
		TextCombat	= "Combat";
		TextGeneral	= "General";
		ThunderBluff	= "Thunder Bluff";
		Undercity	= "Undercity";


		-- Section: Generic Messages
		FrmtCredit	= "(ga naar http://enchantrix.org/ om uw data te delen)";
		FrmtWelcome	= "Enchantrix v%s geladen";
		MesgAuctVersion	= "Enchantrix heeft Auctioneer versie 3.4 of hoger nodig. Sommige functionaliteiten zijn niet beschikbaar totdat Auctioneer is geupgrade.";


		-- Section: Help Text
		GuiClearall	= "Opschonen alle Enchantrix Data";
		GuiClearallButton	= "Alles opschonen";
		GuiClearallHelp	= "Klik hier om alle enchantrix data van de huidige Server/Realm op te schonen.";
		GuiClearallNote	= "voor de huidige Server-factie";
		GuiCount	= "Toon de exacte telling in de database.";
		GuiDefaultAll	= "Herstel alle Enchantrix Opties";
		GuiDefaultAllButton	= "Herstel Alles";
		GuiDefaultAllHelp	= "Klik hier om alle standaard waardes van de Enchantrix opties te laden. LET OP: Deze actie kan NIET ongedaan worde n gemaakt.";
		GuiDefaultOption	= "Herstel deze instelling";
		GuiLocale	= "Verander taal naar";
		GuiMainEnable	= "Enchantrix Activeren";
		GuiMainHelp	= "Bevat instellingen voor Enchantrix, een AddOn die mogelijke uitkomsten bij het disenchanten van een item weergeeft in een tooltip.";
		GuiOtherHeader	= "Andere Opties";
		GuiOtherHelp	= "Verschillende Enchantrix Opties";
		GuiPrintin	= "Selecteer het gewenste berichten scherm";
		GuiRate	= "Toon de gemiddelde hoeveelheid van de disenchant";
		GuiReloadui	= "Opnieuw laden Gebruikers scherm.";
		GuiReloaduiButton	= "HerladenUI";
		GuiReloaduiFeedback	= "Nu bezig met het herladen van de WoW UI";
		GuiReloaduiHelp	= "Klik hier om de WoW te herladen nadat je een andere taal hebt geselecteerd zodat de weergegeven tekst in de juiste taal verschijnt. Opmerking: Dit kan enkele minuten duren.";
		GuiTerse	= "Activeer Beknopte Mode";
		GuiValuateAverages	= "Taxatie met Auctioneer gemiddelden";
		GuiValuateBaseline	= "Taxatie met Standaard Data";
		GuiValuateEnable	= "Activeer Taxatie";
		GuiValuateHeader	= "Taxatie";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "HuidigBod";
		FrmtBidbrokerDone	= "Een regelend bod gedaan";
		FrmtBidbrokerHeader	= "Een bod bespaart %s zilver op de gemiddelde disenchant waarde:";
		FrmtBidbrokerLine	= "%s, Waarde van %s, %s: %s, Bespaard: %s, Minder %s, Tijd: %s";
		FrmtBidbrokerMinbid	= "MinimaleBod";
		FrmtPctlessDone	= "Percentage minder gedaan.";
		FrmtPctlessHeader	= "Opkoop waarde bespaard %d%% op de gemiddelde disenchant waarde:";
		FrmtPctlessLine	= "%s, Geschat op %s, BO: %s, Bespaar: %s, Minder %s";


		-- Section: Tooltip Messages
		FrmtCounts	= "basis=%d, oud=%d, nieuw=%d";
		FrmtDisinto	= "Gedisenchant in:";
		FrmtFound	= "Gevonden dat %s wordt gedisenchant in:";
		FrmtPriceEach	= "Prijs per item";
		FrmtSuggestedPrice	= "Voorstel Prijs:";
		FrmtTotal	= "Totaal";
		FrmtValueAuctHsp	= "Disenchant Waarde";
		FrmtValueAuctMed	= "Disenchant Waarde (Gemiddeld)";
		FrmtValueMarket	= "Disenchant Waarde";
		FrmtWarnAuctNotLoaded	= "Auctioneer niet geladen. Opgeslagen waardes worden gebruikt.";
		FrmtWarnNoPrices	= "Geen prijs beschikbaar ";
		FrmtWarnPriceUnavail	= "Sommige prijzen niet beschikbaar";


		-- Section: User Interface

	};

	zhCN = {


		-- Section: Command Messages
		FrmtActClearall	= "清除全部附魔数据。";
		FrmtActClearFail	= "无法找到物品：%s。";
		FrmtActClearOk	= "物品：%s的数据已清除。";
		FrmtActDefault	= "附魔助手的选项已重置为默认值。";
		FrmtActDefaultAll	= "所有附魔助手选项已重置为默认值。";
		FrmtActDisable	= "不显示物品的%s数据。";
		FrmtActEnable	= "显示物品的%s数据。";
		FrmtActEnabledOn	= "显示物品的%s于%s。";
		FrmtActSet	= "设置%s为'%s'。";
		FrmtActUnknown	= "未知命令关键字：'%s'。";
		FrmtActUnknownLocale	= "你输入的地域代码('%s')未知。有效的地域代码为：";
		FrmtPrintin	= "附魔助手信息现在将显示在\"%s\"对话框。";
		FrmtUsage	= "用途：";
		MesgDisable	= "禁用自动加载附魔助手。";
		MesgNotloaded	= "附魔助手没有加载。键入/enchantrix以获取更多信息。";


		-- Section: Command Options
		CmdClearAll	= "all全部";
		OptClear	= "([物品]|all全部)";
		OptDefault	= "(<选项>|all全部)";
		OptFindBidauct	= "<银币>";
		OptFindBuyauct	= "<比率>";
		OptLocale	= "<地域代码>";
		OptPrintin	= "(<窗口标签>[数字]|<窗口名称>[字符串])";


		-- Section: Commands
		CmdClear	= "clear清除";
		CmdDefault	= "default默认";
		CmdDisable	= "disable禁用";
		CmdFindBidauct	= "bidbroker出价代理";
		CmdFindBidauctShort	= "bb(出价代理的缩写)";
		CmdFindBuyauct	= "percentless比率差额";
		CmdFindBuyauctShort	= "pl(比率差额的缩写)";
		CmdHelp	= "help帮助";
		CmdLocale	= "locale地域代码";
		CmdOff	= "off关";
		CmdOn	= "on开";
		CmdPrintin	= "print-in输出于";
		CmdToggle	= "toggle开关转换";
		ShowCount	= "counts计数";
		ShowEmbed	= "embed嵌入";
		ShowGuessAuctioneerHsp	= "valuate-hsp估价-最高";
		ShowGuessAuctioneerMed	= "valuate-median估价-中值";
		ShowGuessBaseline	= "valuate-baseline估价-基准";
		ShowHeader	= "header标题";
		ShowRate	= "rates估价";
		ShowTerse	= "terse简洁";
		ShowValue	= "valuate估价";
		StatOff	= "Not displaying any enchant data不显示任何分解数据";
		StatOn	= "Displaying configured enchant data显示设定的分解数据";


		-- Section: Config Text
		GuiLoad	= "加载附魔助手。";
		GuiLoad_Always	= "总是";
		GuiLoad_Never	= "从不";


		-- Section: Game Constants
		ArgSpellname	= "分解";
		Darnassus	= "达纳苏斯";
		Ironforge	= "铁炉堡";
		OneLetterGold	= "G";
		OneLetterSilver	= "S";
		Orgrimmar	= "奥格瑞玛";
		PatReagents	= "材料：(.+)";
		ShortDarnassus	= "Dar ";
		ShortIronForge	= "IF ";
		ShortOrgrimmar	= "Org ";
		ShortStormwind	= "SW ";
		ShortThunderBluff	= "TB ";
		ShortUndercity	= "UC ";
		StormwindCity	= "暴风城";
		TextCombat	= "战斗";
		TextGeneral	= "普通";
		ThunderBluff	= "雷霆崖";
		Undercity	= "幽暗城";


		-- Section: Generic Messages
		FrmtCredit	= "(去http://enchantrix.org/网站共享数据)";
		FrmtWelcome	= "附魔助手(Enchantrix) v%s 已加载！";
		MesgAuctVersion	= "Enchantrix需要Auctioneer版本3.4或更高。某些特性会失效请升级你的Auctioneer";


		-- Section: Help Text
		GuiClearall	= "清除全部附魔助手数据。";
		GuiClearallButton	= "全部清除";
		GuiClearallHelp	= "点此清除对于当前服务器-阵营的全部附魔助手数据。";
		GuiClearallNote	= "对于当前服务器-阵营";
		GuiCount	= "显示精确的数据库计数。";
		GuiDefaultAll	= "重置全部附魔助手设置。";
		GuiDefaultAllButton	= "全部重置";
		GuiDefaultAllHelp	= "点此重置全部附魔助手选项为默认值。警告：此操作无法还原。";
		GuiDefaultOption	= "重置该设置";
		GuiEmbed	= "信息显示在游戏默认提示中。";
		GuiLocale	= "设置地域代码为";
		GuiMainEnable	= "启用附魔助手。";
		GuiMainHelp	= "包含插件 - 附魔助手的设置。它用于显示物品分解产物信息。";
		GuiOtherHeader	= "其他选项";
		GuiOtherHelp	= "附魔助手杂项";
		GuiPrintin	= "选择期望的讯息窗口。";
		GuiRate	= "显示分解平均数量。";
		GuiReloadui	= "重新加载用户界面。";
		GuiReloaduiButton	= "重载UI";
		GuiReloaduiFeedback	= "正在重新加载魔兽用户界面。";
		GuiReloaduiHelp	= "在改变地域代码后点此重新加载魔兽用户界面使此配置屏幕中的语言匹配选择。注意：此操作可能耗时几分钟。";
		GuiTerse	= "开启简洁模式";
		GuiValuateAverages	= "以拍卖助手平均价进行估价。";
		GuiValuateBaseline	= "以内置数据估价。";
		GuiValuateEnable	= "启用估价。";
		GuiValuateHeader	= "估价";
		GuiValuateMedian	= "以拍卖助手中位数价进行估价。";
		HelpClear	= "清除指定物品的数据(必须Shift+点击将物品插入命令)。你也可以指定特定关键字\"all\"。";
		HelpCount	= "选择是否显示数据库中的额外计数。";
		HelpDefault	= "设置某个附魔助手选项为默认值。你也可以输入特定关键字\"all\" 来设置所有附魔助手选项为默认值。";
		HelpDisable	= "阻止附魔助手下一次登录时自动加载。";
		HelpEmbed	= "嵌入文字到原游戏提示中(提示：某些特性在该模式下禁用)。";
		HelpFindBidauct	= "找到拍卖品其可能分解价值低于竞拍价一定银币额。";
		HelpFindBuyauct	= "找到拍卖品其可能分解价值低于一口价一定比率。";
		HelpGuessAuctioneerHsp	= "如果启用估价，并且安装了拍卖行助手(Auctioneer)，显示对于物品分解的曾售价格(最高价)。";
		HelpGuessAuctioneerMedian	= "如果启用估价，并且安装了拍卖助手(Auctioneer)，显示基于物品分解估价的中位数。";
		HelpGuessBaseline	= "如果启用估价，显示对于物品分解的基准估价，基于系统内置价格(不需要拍卖助手Auctioneer)。";
		HelpGuessNoauctioneer	= "价格评估上限与价格评估中位数命令不能使用是因为没有安装拍卖助手。";
		HelpHeader	= "选择是否显示标题线。";
		HelpLoad	= "改变附魔助手的加载设置。";
		HelpLocale	= "更改附魔助手显示讯息的地域代码。";
		HelpOnoff	= "打开/关闭附魔数据的显示。";
		HelpPrintin	= "选择附魔助手使用哪个窗口来显示输出讯息。你可以指定窗口名称或索引。";
		HelpRate	= "选择是否显示分解的平均数量。";
		HelpTerse	= "开启/关闭 简洁模式，只显示分解价值。能持续忽略控制键。";
		HelpValue	= "选择是否显示物品基于可能分解几率的预计价值。";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "目前的拍卖价";
		FrmtBidbrokerDone	= "交易价代理完成";
		FrmtBidbrokerHeader	= "比平均分解价值平%s银的拍卖：";
		FrmtBidbrokerLine	= "%s，估价：%s，%s：%s，节省：%s，差额%s，次数：%s";
		FrmtBidbrokerMinbid	= "最低拍卖价";
		FrmtBidBrokerSkipped	= "没有显示%d个拍卖因为净利率 cutoff 是 (%d%%)";
		FrmtPctlessDone	= "比率差额完成。";
		FrmtPctlessHeader	= "比平均分解价值平%s银的买断价:";
		FrmtPctlessLine	= "%s，估价：%s，买断价：%s，节省：%s，差额%s";
		FrmtPctlessSkipped	= "没有显示%d个拍卖因为获利能力 cutoff 是 (%s)";


		-- Section: Tooltip Messages
		FrmtCounts	= "(基本=%d，旧值=%d，新值=%d)";
		FrmtDisinto	= "可分解为:";
		FrmtFound	= "发现%s可分解为：";
		FrmtPriceEach	= "(每件%s)";
		FrmtSuggestedPrice	= "建议价格：";
		FrmtTotal	= "合计";
		FrmtValueAuctHsp	= "分解价值(最高)";
		FrmtValueAuctMed	= "分解价值(中位数)";
		FrmtValueMarket	= "分解价值(基准)";
		FrmtWarnAuctNotLoaded	= "[拍卖助手未加载，使用缓冲价格]";
		FrmtWarnNoPrices	= "[无价可用]";
		FrmtWarnPriceUnavail	= "[某些价格不可用]";


		-- Section: User Interface

	};

	zhTW = {


		-- Section: Command Messages
		FrmtActClearall	= "清除所有附魔資料";
		FrmtActClearFail	= "無法找到物品：%s";
		FrmtActClearOk	= "清除物品資料：%s ";
		FrmtActDefault	= "Enchantrix的%s設定已經重設為初始值";
		FrmtActDefaultAll	= "所有Enchantrix的設定已經重設為初始值";
		FrmtActDisable	= "不要顯示物品的 %s 資料";
		FrmtActEnable	= "顯示物品的 %s 資料";
		FrmtActEnabledOn	= "顯示物品的 %s 在 %s";
		FrmtActSet	= "設定%s為'%s'";
		FrmtActUnknown	= "未知的命令關鍵字：'%s'";
		FrmtActUnknownLocale	= "找不到您選擇的語言('%s')。可用的語言有：";
		FrmtPrintin	= "Encantrix的訊息將會顯示在 \"%s\" 聊天框架";
		FrmtUsage	= "用途:";
		MesgDisable	= "關閉Enchantrix之自動載入";
		MesgNotloaded	= "Enchantrix未載入,輸入 /enchantrix 取得說明";


		-- Section: Command Options
		CmdClearAll	= "all";
		OptClear	= "([Item]|all)";
		OptDefault	= "(<option>|all)";
		OptFindBidauct	= "<silver>";
		OptFindBuyauct	= "<percent>";
		OptLocale	= "<locale>";
		OptPrintin	= "(<frameIndex>[Number]|<frameName>[String])";


		-- Section: Commands
		CmdClear	= "clear";
		CmdDefault	= "default";
		CmdDisable	= "disable";
		CmdFindBidauct	= "bidbroker";
		CmdFindBidauctShort	= "bb";
		CmdFindBuyauct	= "percentless";
		CmdFindBuyauctShort	= "pl";
		CmdHelp	= "幫助";
		CmdLocale	= "locale";
		CmdOff	= "off";
		CmdOn	= "on";
		CmdPrintin	= "print-in";
		CmdToggle	= "toggle";
		ShowCount	= "counts";
		ShowEmbed	= "embed";
		ShowGuessAuctioneerHsp	= "valuate-hsp";
		ShowGuessAuctioneerMed	= "valuate-median";
		ShowGuessBaseline	= "valuate-baseline";
		ShowHeader	= "header";
		ShowRate	= "rates";
		ShowTerse	= "精簡";
		ShowValue	= "valuate";
		StatOff	= "不顯示任何附魔資料";
		StatOn	= "顯示已設定附魔資料中";


		-- Section: Config Text
		GuiLoad	= "載入Enchantrix";
		GuiLoad_Always	= "always";
		GuiLoad_Never	= "never";


		-- Section: Game Constants
		ArgSpellname	= "分解";
		Darnassus	= "達納蘇斯";
		Ironforge	= "鐵爐堡";
		OneLetterGold	= "金";
		OneLetterSilver	= "銀";
		Orgrimmar	= "奧格瑞瑪";
		PatReagents	= "魔法元素: (.+) ";
		ShortDarnassus	= "達納蘇斯";
		ShortIronForge	= "鐵爐堡";
		ShortOrgrimmar	= "奧格瑞瑪";
		ShortStormwind	= "暴風城";
		ShortThunderBluff	= "雷霆崖";
		ShortUndercity	= "幽暗城";
		StormwindCity	= "暴風城";
		TextCombat	= "戰鬥記錄";
		TextGeneral	= "綜合";
		ThunderBluff	= "雷霆崖";
		Undercity	= "幽暗城";


		-- Section: Generic Messages
		FrmtCredit	= " (請至 http://enchantrix.org/ 以分享您的資料) ";
		FrmtWelcome	= "Enchantrix v%s 已載入";
		MesgAuctVersion	= "Enchantrix需要Auctioneer3.4或更新版本。某些功能在您未更新您的Auctioneer前無法使用。";


		-- Section: Help Text
		GuiClearall	= "清除所有附魔資料";
		GuiClearallButton	= "清除全部";
		GuiClearallHelp	= "點擊此處，清除目前伺服器之所有附魔資料";
		GuiClearallNote	= "目前的伺服器";
		GuiCount	= "顯示在資料庫中的確切數量";
		GuiDefaultAll	= "重置所有Enchantrix選項";
		GuiDefaultAllButton	= "重設所有設定";
		GuiDefaultAllHelp	= "點擊這裡以重設所有Enchantrix的選項回預設值。警告：這個動作是無法還原的。";
		GuiDefaultOption	= "重設這個設定";
		GuiEmbed	= "在遊戲提示中嵌入資訊";
		GuiLocale	= "設定語言為";
		GuiMainEnable	= "啟動 Enchantrix";
		GuiMainHelp	= "把附魔資訊嵌入遊戲資訊窗";
		GuiOtherHeader	= "其他選項";
		GuiOtherHelp	= "其他 Enchantrix 雜項設定";
		GuiPrintin	= "選擇崁入的訊息框架";
		GuiRate	= "顯示分析後的分解資訊";
		GuiReloadui	= "重新載入使用者界面";
		GuiReloaduiButton	= "重新載入UI";
		GuiReloaduiFeedback	= "正在重新啟動UI";
		GuiReloaduiHelp	= "點選後將重新啟動UI，並轉換為玩家所選擇的語言版本。注意︰此次操作可能花費幾分鐘。 ";
		GuiTerse	= "啟用精簡模式";
		GuiValuateAverages	= "拍賣評估";
		GuiValuateBaseline	= "崁入拍賣資料";
		GuiValuateEnable	= "啟動評估系統";
		GuiValuateHeader	= "估價";
		GuiValuateMedian	= "評估拍賣平均價值";
		HelpClear	= "清除指定物品的數據(必須Shift+點擊將物品插入命令)。你也可以指定特定關鍵字\"all\"。";
		HelpCount	= "選擇是否在數據庫裡顯示精確的數字 ";
		HelpDefault	= "設置某個附魔助手選項為預設值。你也可以輸入特定關鍵字\"all\" 來設置所有附魔助手選項為預設值。";
		HelpDisable	= "停止附魔助手在下一次登錄時自動載入。";
		HelpEmbed	= "嵌入文字到原游戲提示中(提示：某些特性在該模式下無法使用)。";
		HelpFindBidauct	= "找到分解價值可能低于競拍價一定銀幣額的拍賣品。";
		HelpFindBuyauct	= "找到分解價值可能低于買斷價一定比率的拍賣品。";
		HelpGuessAuctioneerHsp	= "If valuation is enabled, and you have Auctioneer installed, display the sellable price (HSP) valuation of disenchanting the item.";
		HelpGuessAuctioneerMedian	= "If valuation is enabled, and you have Auctioneer installed, display the median based valuation of disenchanting the item.";
		HelpGuessBaseline	= "If valuation is enabled, (Auctioneer not needed) display the baseline valuation of disenchanting the item, based upon the inbuilt prices.";
		HelpGuessNoauctioneer	= "The valuate-hsp and valuate-median commands are not available because you do not have auctioneer installed";
		HelpHeader	= "選擇是否顯示標題列";
		HelpLoad	= "Change Enchantrix's load settings for this toon";
		HelpLocale	= "改變用來顯示Enchantrix訊息的語言";
		HelpOnoff	= "附魔資料開啟或關閉";
		HelpPrintin	= "選擇Enchantrix訊息顯示的框架。你可以輸入框架名字或者是index。";
		HelpRate	= "選擇是否顯示分解的平均量";
		HelpTerse	= "開啟/關閉 簡略模式，只顯示分解價值。能持續忽略控制鍵。";
		HelpValue	= "Select whether to show item's estimated values based on the proportions of possible disenchants";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "目前的拍賣價";
		FrmtBidbrokerDone	= "交易價代理完成";
		FrmtBidbrokerHeader	= "比平均分解價值平%s銀的拍賣：";
		FrmtBidbrokerLine	= "%s，估價：%s，%s：%s，節省：%s，差額%s，次數：%s";
		FrmtBidbrokerMinbid	= "最低拍賣價";
		FrmtBidBrokerSkipped	= "没有顯示%d個拍賣因為淨利率 cutoff 是 (%d%%)";
		FrmtPctlessDone	= "比率差額完成";
		FrmtPctlessHeader	= "比平均分解價值平%s銀的買斷價:";
		FrmtPctlessLine	= "%s，估價：%s，買斷價：%s，節省：%s，差額%s";
		FrmtPctlessSkipped	= "没有顯示%d個拍賣因為獲利能力 cutoff 是 (%s)";


		-- Section: Tooltip Messages
		FrmtCounts	= "(原本=%d, 舊=%d, 新=%d)";
		FrmtDisinto	= "分解成：";
		FrmtFound	= "%s可分解成：";
		FrmtPriceEach	= "(%s 每個) ";
		FrmtSuggestedPrice	= "建議價格：";
		FrmtTotal	= "總共";
		FrmtValueAuctHsp	= "分解價值(HSP)";
		FrmtValueAuctMed	= "分解價值(Median)";
		FrmtValueMarket	= "分解價值(Baseline)";
		FrmtWarnAuctNotLoaded	= "[Auctioneer未載入，使用暫存區價格]";
		FrmtWarnNoPrices	= "[無有效價格]";
		FrmtWarnPriceUnavail	= "[部分價格無效]";


		-- Section: User Interface

	};

	ptPT = {


		-- Section: Command Messages
		FrmtActClearall	= "A limpar toda a informação de enchanting";
		FrmtActClearFail	= "Impossível encontrar objecto: %s";
		FrmtActClearOk	= "Informação eliminada do objecto: %s";
		FrmtActDefault	= "%s do Enchantrix voltaram às definições padrão";
		FrmtActDefaultAll	= "Todas as opções Enchantrix revertidas para o normal.";
		FrmtActDisable	= "Não está a ser mostrada informação do objecto %s";
		FrmtActEnable	= "Está a ser mostrada informação do objecto %s";
		FrmtActEnabledOn	= "A mostrar o objecto %s em %s";
		FrmtActSet	= "Definir %s para '%s'";
		FrmtActUnknown	= "Comando de palavra-chave desconhecido: '%s'";
		FrmtActUnknownLocale	= "A localização dada ('%s') nao foi encontrada. Localizações válidas são:";
		FrmtPrintin	= "Mensagens do Enchantrix vão ser mostradas no chat \"%s\"";
		FrmtUsage	= "Uso:";
		MesgDisable	= "A desactivar o carregamento automático do Enchantrix";
		MesgNotloaded	= "Enchantrix não está carregado.  Escreva /enchantrix para mais informações.";


		-- Section: Command Options
		CmdClearAll	= "todos";
		OptClear	= "[Objecto]|todos";
		OptDefault	= "(<opção>|todos)";
		OptFindBidauct	= "<prata>";
		OptFindBuyauct	= "<percentagem>";
		OptLocale	= "<local>";
		OptPrintin	= "(<frameIndex>[Número]<frameName>[Corda])";


		-- Section: Commands
		CmdClear	= "apagar";
		CmdDefault	= "por defeito";
		CmdDisable	= "desactivar";
		CmdHelp	= "ajuda";
		CmdLocale	= "localização";
		CmdOff	= "desligado";
		CmdOn	= "ligado";
		CmdPrintin	= "imprimir em";
		CmdToggle	= "alternar";
		ShowCount	= "contagens";
		ShowEmbed	= "embebido";
		ShowGuessAuctioneerMed	= "valor médio";
		ShowGuessBaseline	= "valor base";
		ShowHeader	= "cabeçalho";
		ShowRate	= "taxas";
		ShowTerse	= "breve";
		ShowValue	= "avaliar";
		StatOff	= "Não está a ser mostrada informação do enchant";
		StatOn	= "Está a ser mostrada a informação configurada do enchant";


		-- Section: Config Text
		GuiLoad	= "A carregar Enchantrix";
		GuiLoad_Always	= "sempre";
		GuiLoad_Never	= "nunca";


		-- Section: Game Constants
		ArgSpellname	= "Desencantar";
		PatReagents	= "Reagentes: (.+)";
		TextCombat	= "Combate";
		TextGeneral	= "Geral";


		-- Section: Generic Messages
		FrmtCredit	= "(vai a http://enchantrix.org para partilhares a tua informação)";
		FrmtWelcome	= "Enchantrix v%s carregado";
		MesgAuctVersion	= "Enchantrix requer a versão 3.4 do Auctioneer ou mais elevado. Algumas características serão desligadas até que você actualize sua instalação do Auctioneer. ";


		-- Section: Help Text
		GuiClearall	= "Limpar toda a informação do Enchantrix";
		GuiClearallButton	= "Limpar tudo";
		GuiClearallHelp	= "Carrega aqui para limpar toda a informação do Enchantrix do servidor actual.";
		GuiClearallNote	= "para o servidor/facção actual";
		GuiCount	= "Mostrar a contagem exacta na base de dados";
		GuiDefaultAll	= "Limpar todas as opções do Enchantrix";
		GuiDefaultAllButton	= "Limpar tudo";
		GuiDefaultAllHelp	= "Carrega aqui para voltar às definições padrão do Enchantrix. ATENÇÃO: Esta acção NÃO é reversível.";
		GuiDefaultOption	= "Limpar esta definição";
		GuiEmbed	= "Informação junta na tooltip do jogo";
		GuiLocale	= "Definir localização para";
		GuiMainEnable	= "Activar Enchantrix";
		GuiMainHelp	= "Contém definições para o Enchantrix, um AddOn que mostra informação na tooltip dos objectos com possíveis resultados de desencantamento do dito objecto.";
		GuiOtherHeader	= "Outras Opções";
		GuiOtherHelp	= "Outras Opções do Enchantrix";
		GuiPrintin	= "Seleccionar a expressão desejada da mensagem";
		GuiRate	= "Mostrar a quantidade média de desencanto";
		GuiReloadui	= "Recarregar o Interface do Utilizador";
		GuiReloaduiButton	= "RecarregarUI";
		GuiReloaduiFeedback	= "A recarregar o UI do WoW";
		GuiReloaduiHelp	= "Carrega aqui para recarregar o Interface de Utilizador (UI) do WoW após mudar a localização para que a linguagem neste menu de configuração confira com a que escolheste. Nota: Esta operação poderá demorar alguns minutos.";
		GuiTerse	= "Ligar modo breve";
		GuiValuateAverages	= "Validar com as médias Auctioneer";
		GuiValuateBaseline	= "Validar com a Data Padrão";
		GuiValuateEnable	= "Activar Validação";
		GuiValuateHeader	= "Validação";
		GuiValuateMedian	= "Validar com os Números Médios Auctioneer";
		HelpClear	= "Limpar a informação específica de um objecto (tem de carregar shift+click o objecto no comando) Também podes especificar a palavra especial \"Todos\"";
		HelpCount	= "Seleccionar se quer ver a contagem exacta dos objectos na Database";
		HelpDefault	= "Aplicar uma opção do Enchantrix para o seu Padrão. Também podes especificar a palavra especial \"Todos\" para por todos as opções Padrão.";
		HelpDisable	= "Proíbir o Enchantrix de se ligar da próxima vez que entrar no jogo";
		HelpEmbed	= "Encaixar o texto no tooltip original do jogo (nota: determinadas características são desligadas quando esta opção é selecionada)";
		HelpFindBidauct	= "Encontrar os leilões cujo possível valor do desencanto é uma determinada quantidade de prata menos do que o preço de oferta";
		HelpFindBuyauct	= "Encontrar os auctions cujo possível valor de desencanto é um determinado por cento menos do que o preço compra directa";
		HelpGuessAuctioneerHsp	= "Se a validação estiver permitida, e você tiver o Auctioneer instalado, indicar o preço de venda (HSP) de disencanto do artigo. ";
		HelpGuessAuctioneerMedian	= "Se a validação estiver permitida, e você tiver o Auctioneer instalado, indicar o valor baseado mediano de disencanto do artigo. ";
		HelpGuessBaseline	= "Se a validação for permitida, (Auctioneer não necessitado) indicar o valor da linha de base de disencanto do artigo, baseado nos preços inbutidos. ";
		HelpGuessNoauctioneer	= "Se a validação for permitida, (Auctioneer não necessitado) indicar o valor da linha de base de disencanto do artigo, baseado nos preços inbutidos";
		HelpHeader	= "Selecionar se quer mostrar o cabeçalho";
		HelpLoad	= "Mudar as opções de carregamento para este personagem";
		HelpLocale	= "Mudar a localização que é usada para mostrar as mensagens do Enchantrix";
		HelpOnoff	= "Liga e Desliga a exposição de dados do Enchant";
		HelpPrintin	= "Selecionar em que janela o Enchantrix irá imprimir as suas mensagens. Poderás expecificar o nome da janela ou o inicio da janela.";
		HelpRate	= "Seleccionar se quer exibir as quantidades médias do desencanto.";
		HelpTerse	= "Ligar/Desligar o modo breve, montrando somente o valor do desencanto. Pode ser sobreposto carregando na tecla Ctrl.";
		HelpValue	= "Seleccionar se quer ver os valores estimados baseados em proporções possiveis dos desencantos.";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "Ofcur";
		FrmtBidbrokerDone	= "Oferta do corrector feita";
		FrmtBidbrokerHeader	= "As ofertas que têm as economias de prata de %s na média do valor disencanto:";
		FrmtBidbrokerLine	= "%s, Avaliado em: %s, %s: %s, Excepto: %s, Menos %s, Tempo: %s";
		FrmtBidbrokerMinbid	= "Ofmin";
		FrmtPctlessDone	= "Percentagem menos feito";
		FrmtPctlessHeader	= "As Compras Directas que têm excesso do artigo médio das economias de %d%% do valor do desencanto: ";
		FrmtPctlessLine	= "%s, Avaliado em: %s, BO: %s, Excepto: %s, Menos %s ";


		-- Section: Tooltip Messages
		FrmtCounts	= "(base=%d, antigo=%d, novo=%d) ";
		FrmtDisinto	= "Desencanta em:";
		FrmtFound	= "Observado que %s desencanta em: ";
		FrmtPriceEach	= "(%s cada)";
		FrmtSuggestedPrice	= "Preço sugerido:";
		FrmtTotal	= "Total";
		FrmtValueAuctHsp	= "Valor do Desencanto (MPV)";
		FrmtValueAuctMed	= "Valor do Desencanto (Números médios)";
		FrmtValueMarket	= "Valor de Disencanto (Referência)";
		FrmtWarnAuctNotLoaded	= "[Auctioneer não carregado, usando preços em cache]";
		FrmtWarnNoPrices	= "[Nenhuns Preços Disponiveis]";
		FrmtWarnPriceUnavail	= "[Alguns preços indisponiveis]";

	};

	ruRU = {


		-- Section: Command Messages
		FrmtActClearall	= "Очищает всю информацию о энчантах";
		FrmtActClearFail	= "Не могу найти предмет: %s";
		FrmtActClearOk	= "Убрана информация о предмете: %s";
		FrmtActDefault	= "Enchantrix's %s опция была сброшена";
		FrmtActDefaultAll	= "Все Enchantrix были сброшены\n";
		FrmtActDisable	= "Показ данных по %s деталя\n";
		FrmtActEnable	= "Показ данных по %s деталя\n";
		FrmtActEnabledOn	= "Показ %s деталя на %s\n";
		FrmtActSet	= "Установите %s к ' %s'\n";
		FrmtActUnknown	= "Неизвестный keyword команды: ' %s'\n";
		FrmtActUnknownLocale	= "Locale, котор вы определили (' %s') неизвестны. Действительные locales являются следующими:\n";
		FrmtPrintin	= "Сообщения Encantrix's теперь напечатают на рамке бормотушк \"%s\"\n";
		FrmtUsage	= "Использование:\n";
		MesgDisable	= "Выводя из строя автоматическая нагрузка Enchantrix\n";
		MesgNotloaded	= "Enchantrix не нагружено. Напечатайте /enchantrix на машинке для больше info.\n";


		-- Section: Command Options
		CmdClearAll	= "все\n";
		OptClear	= "([Item]|all) ";
		OptDefault	= "(<option>|all) ";
		OptFindBidauct	= "<silver> ";
		OptFindBuyauct	= "<percent> ";
		OptLocale	= "<locale> ";
		OptPrintin	= "(<frameIndex>[Number]|<frameName>[String]) ";


		-- Section: Commands
		CmdClear	= "Очистить";
		CmdDefault	= "Стандартные";
		CmdDisable	= "выведите из строя\n";
		CmdFindBidauct	= "bidbroker ";
		CmdFindBidauctShort	= "bb ";
		CmdFindBuyauct	= "percentless ";
		CmdFindBuyauctShort	= "pl ";
		CmdHelp	= "помощь\n";
		CmdOff	= "off";
		CmdOn	= "на\n";
		CmdPrintin	= "print-in ";
		CmdToggle	= "переключить";
		ShowCount	= "отсчеты\n";
		ShowHeader	= "заголовок";
		ShowRate	= "оценивается";


		-- Section: Config Text
		GuiLoad	= "Загрузить Enchantrix ";
		GuiLoad_Always	= "всегда";
		GuiLoad_Never	= "никогда";


		-- Section: Game Constants
		ArgSpellname	= "Дизенчант";
		PatReagents	= "Реагенты: (.+) ";
		TextGeneral	= "Основной";


		-- Section: Generic Messages
		FrmtCredit	= "(на http://enchantrix.org/ можо поделиться своими данными)";
		FrmtWelcome	= "Enchantrix v%s загружен";
		MesgAuctVersion	= "Для Enchantrix требуется Auctioneer версии 3.4 или выше. Некоторые функции будут недоступны, пока вы не обновите Auctioneer.";


		-- Section: Help Text
		GuiClearall	= "Обнулить все данные Enchantrix";
		GuiClearallButton	= "Обнулить всё";
		GuiClearallHelp	= "Нажмите сюда, чтобы обнулить все данные Enchantrix для текущего сервера";
		GuiCount	= "Показать точное количество в базе данных";
		GuiDefaultAll	= "Восстановить все настройки Enchantrix по умолчанию";
		GuiDefaultAllButton	= "Сбросить всё";
		GuiDefaultAllHelp	= "Нажмите сюда для возврата всех настроек Enchantrix к их первоначальным значениям. WARNING: Это действие НЕЛЬЗЯ ОТМЕНИТЬ.";
		GuiDefaultOption	= "Восстановить данный параметр";
		GuiLocale	= "Сменить язык на";
		GuiMainEnable	= "Включить Enchantrix";
		GuiOtherHeader	= "Другие настройки";
		GuiReloadui	= "Перезагруза интерфейса пользователя";
		GuiReloaduiFeedback	= "Идет перезагрузка интерфейса пользователя";
		HelpDisable	= "Не загружать enchantrix в следующий раз, когда вы войдете в игру";


		-- Section: Tooltip Messages
		FrmtPriceEach	= "(%s каждая)";
		FrmtSuggestedPrice	= "Рекомендуемая цена:";
		FrmtTotal	= "Итого";
		FrmtWarnAuctNotLoaded	= "[Auctioneer не загружен, использую полученные ранее данные]";
		FrmtWarnNoPrices	= "[Цены неизвестны]";
		FrmtWarnPriceUnavail	= "[Некоторые цены неизвестны]";

	};

	trTR = {


		-- Section: Command Messages
		FrmtActClearall	= "TÃ¼m enchant verilerini siliyor";
		FrmtActClearFail	= "Cisim bulunamadÄ±: %s";
		FrmtActClearOk	= "Verileri silinen cisim: %s";
		FrmtActDefault	= "Enchantrix'in %s seÃ§eneÄŸi varsayÄ±lan haline dÃ¶ndÃ¼rÃ¼ldÃ¼.";
		FrmtActDefaultAll	= "TÃ¼m Enchantrix seÃ§enekleri varsayÄ±lan hallerine dÃ¶ndÃ¼rÃ¼ldÃ¼.";
		FrmtActDisable	= "Cismin %s verisi gÃ¶sterilmiyor";
		FrmtActEnable	= "Cismin %s verisi gÃ¶steriliyor";
		FrmtActEnabledOn	= "Cismin %s si %s de gÃ¶steriliyor";
		FrmtActSet	= "%s yi '%s' ye ayarla";
		FrmtActUnknown	= "Bilinmeyen komut anahtar kelimesi: '%s' ";


		-- Section: Commands
		CmdDisable	= "iptal";

	};
}
