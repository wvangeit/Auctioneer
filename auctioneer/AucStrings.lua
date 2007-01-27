﻿--[[
	WARNING: This is a generated file.
	If you wish to perform or update localizations, please go to our Localizer website at:
	http://norganna.org/localizer/index.php

	AddOn: Auctioneer
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
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

AuctioneerLocalizations = {

	csCZ = {


		-- Section: AskPrice Messages
		AskPriceAd	= "Zjisti cenu sady/stacku %sx[ItemLink] (x = velikost sady) ";
		FrmtAskPriceBuyoutMedianHistorical	= "%sVykup-median historicky: %s%s";
		FrmtAskPriceBuyoutMedianSnapshot	= "%sVykup-median posledni zaznam: %s%s";
		FrmtAskPriceDisable	= "Vypinam nastaveni %s VychoziCena";
		FrmtAskPriceEach	= "(%s kazdy)";
		FrmtAskPriceEnable	= "Zapinam nastaveni %s VychoziCena";
		FrmtAskPriceVendorPrice	= "%sProdejne v obchode za: %s%s";


		-- Section: Auction Messages
		FrmtActRemove	= "Predmet byl odstranen z aukce %s .";
		FrmtAuctinfoHist	= "%d zaznamy";
		FrmtAuctinfoLow	= "Nejnizsi cena";
		FrmtAuctinfoMktprice	= "Obvykla trzni cena";
		FrmtAuctinfoNolow	= "Predmet zatim nebyl v aukci zaznamenan.";
		FrmtAuctinfoOrig	= "Puvodni nabidka";
		FrmtAuctinfoSnap	= "%d posledni zaznam";
		FrmtAuctinfoSugbid	= "Pocatecni nabidka";
		FrmtAuctinfoSugbuy	= "Vykupni cena";
		FrmtWarnAbovemkt	= "Zvolena cena je NADprumerna";
		FrmtWarnMarkup	= "Navyseni vendor ceny o %s%%";
		FrmtWarnMyprice	= "Pouzita dosavadni cena";
		FrmtWarnNocomp	= "Neni konkurence";
		FrmtWarnNodata	= "Malo zaznamu k stanoveni nejvyssi vhodne ceny";
		FrmtWarnToolow	= "Existuje konkurencni nabidka pod cenou";
		FrmtWarnUndercut	= "Podcenuji objekt o %s%%";
		FrmtWarnUser	= "Pouzita jiz zvolena cena";


		-- Section: Bid Messages
		FrmtAlreadyHighBidder	= "Momentalne jste vedouci v teto aukci: %s (x%d)";
		FrmtBidAuction	= "Bid na aukci: %s (x%d)";
		FrmtBidQueueOutOfSync	= "Chyba: Bid fronta nebyla syncovana!";
		FrmtBoughtAuction	= "Vykoupena aukce: %s (x%d)";
		FrmtMaxBidsReached	= "Bylo nalezeno vice aukci %s (x%d), ale bidovaci limit byl jiz dosazen {%d)";
		FrmtNoAuctionsFound	= "Nenalezena zadna aukce: %s (x%d)";
		FrmtNoMoreAuctionsFound	= "Zadna dalsi aukce nebyla nalezenea: %s (x%d)";
		FrmtNotEnoughMoney	= "Nedostatek penez na bid teto aukce: %s (x%d)";
		FrmtSkippedAuctionWithHigherBid	= "Nelze bidovat s vyssim bidem: %s (x%d)";
		FrmtSkippedAuctionWithLowerBid	= "Nelze bidovat s mensim bidem: %s (x%d)";
		FrmtSkippedBiddingOnOwnAuction	= "Nelze bidovat na vlastni aukci: %s (x%d)";
		UiProcessingBidRequests	= "Provadim bidovaci pozadavek...";


		-- Section: Command Messages
		ConstantsCritical	= "VÁŽNÉ: Soubor Auctioneera \"SavedVariables\" je už naplněn z %.3f%%!";
		ConstantsMessage	= "Soubor Auctioneera \"SavedVariables\" je už naplněn z %.3f%%!";
		ConstantsWarning	= "VAROVÁNÍ: Soubor Auctioneera \"SavedVariables\" je už naplněn z %.3f%%!";
		FrmtActClearall	= "Mazu vsechna aukcni data k %s";
		FrmtActClearFail	= "Nelze najit předmět: %s";
		FrmtActClearOk	= "Smazana data k předmětu: %s";
		FrmtActClearsnap	= "Mazu cely posledni zaznam z AH.";
		FrmtActDefault	= "Obnoveny základní hodnoty pro nastavení %s ";
		FrmtActDefaultall	= "Všechna nastavení Auctioneera byla vrácena na základní hodnoty.";
		FrmtActDisable	= "Nezobrazuji data předmětu o %s";
		FrmtActEnable	= "Zobrazuji data předmětu o %s";
		FrmtActSet	= "Nastavuji %s na '%s'";
		FrmtActUnknown	= "Neznamy prikaz: '%s'";
		FrmtAuctionDuration	= "Zakladni trvani aukce nastaveno na: %s";
		FrmtAutostart	= "Auto-cena nastavena: %s naBIDka a %s Vykup (%dh)\n%s";
		FrmtFinish	= "Po skonceni skenu bude %s";
		FrmtPrintin	= "Zpravy z Auctioneeru se nyni budou zobrazovat v okne \"%s\"";
		FrmtProtectWindow	= "Ochrana AH okna proti zavreni nastavena na: %s";
		FrmtUnknownArg	= "'%s'neni platna hodnota pro '%s'";
		FrmtUnknownLocale	= "Zadany jazyk ('%s') je neznamy. Dostupne jsou:";
		FrmtUnknownRf	= "Neznamy parametr ('%s'). Platny format je: [server]-[strana]. Napriklad: Shadow Moon-Horde";


		-- Section: Command Options
		OptAlso	= "(server-frakce|protivnik)";
		OptAskPriceSend	= "(<PlayerName> <AskPrice Query>)";
		OptAuctionDuration	= "(trvani||2h||8h||24h)";
		OptBidbroker	= "<stribro_zisk>";
		OptBidLimit	= "<cislo>";
		OptBroker	= "<stribro_zisk>";
		OptClear	= "([Objekt]|vse|zaznam)";
		OptCompete	= "<stribro_mene>";
		OptDefault	= "(<nastaveni>|vse)";
		OptFinish	= "(off|logout|exit|reloadui)";
		OptLocale	= "<jazyk>";
		OptPctBidmarkdown	= "<procent>";
		OptPctMarkup	= "<procent>";
		OptPctMaxless	= "<procent>";
		OptPctNocomp	= "<procent>";
		OptPctUnderlow	= "<procento>";
		OptPctUndermkt	= "<procent>";
		OptPercentless	= "<procent>";
		OptPrintin	= "(<oknoIndex>[Cislo]|<oknoJmeno>[String])";
		OptProtectWindow	= "(nikdy||sken||vzdy)";
		OptScale	= "<rozmer_nasobek>";
		OptScan	= "<sken_parametr>";


		-- Section: Commands
		CmdAlso	= "take";
		CmdAlsoOpposite	= "protistrana";
		CmdAlt	= "Alt";
		CmdAskPriceAd	= "oznameni";
		CmdAskPriceGuild	= "guilda";
		CmdAskPriceParty	= "parta";
		CmdAskPriceSend	= "odeslat";
		CmdAskPriceSmart	= "chytre";
		CmdAskPriceSmartWord1	= "co";
		CmdAskPriceSmartWord2	= "cenny";
		CmdAskPriceTrigger	= "spoustec";
		CmdAskPriceVendor	= "vendor";
		CmdAskPriceWhispers	= "whispers";
		CmdAskPriceWord	= "word";
		CmdAuctionClick	= "aukcni-klik";
		CmdAuctionDuration	= "trvani-aukce";
		CmdAuctionDuration0	= "posledni";
		CmdAuctionDuration1	= "2hod";
		CmdAuctionDuration2	= "8hod";
		CmdAuctionDuration3	= "24hod";
		CmdAutofill	= "autoceny";
		CmdBidbroker	= "bidfiltr";
		CmdBidbrokerShort	= "bf";
		CmdBidLimit	= "bid-limit";
		CmdBroker	= "filtr";
		CmdClear	= "smazat";
		CmdClearAll	= "vse";
		CmdClearSnapshot	= "zapomen";
		CmdCompete	= "konkurfiltr";
		CmdCtrl	= "Ctrl";
		CmdDefault	= "vychozi";
		CmdDisable	= "deaktivovat";
		CmdEmbed	= "integrovat";
		CmdFinish	= "dokonci";
		CmdFinish0	= "vypni";
		CmdFinish1	= "logout";
		CmdFinish2	= "quit";
		CmdFinish3	= "realoadui";
		CmdFinishSound	= "konec-zvonec";
		CmdHelp	= "pomoc";
		CmdLocale	= "jazyk";
		CmdOff	= "vypnout";
		CmdOn	= "zapnout";
		CmdPctBidmarkdown	= "proc-snizit";
		CmdPctMarkup	= "proc-zvysit";
		CmdPctMaxless	= "proc-maxztr";
		CmdPctNocomp	= "proc-bezkonkr";
		CmdPctUnderlow	= "proc-nejsleva";
		CmdPctUndermkt	= "proc-podtrhem";
		CmdPercentless	= "procfiltr";
		CmdPercentlessShort	= "pf";
		CmdPrintin	= "zobrazovat-v";
		CmdProtectWindow	= "ochran-okno";
		CmdProtectWindow0	= "nikdy";
		CmdProtectWindow1	= "sken";
		CmdProtectWindow2	= "vzdy";
		CmdScan	= "skenuj";
		CmdShift	= "Shift";
		CmdToggle	= "prepnout";
		CmdUpdatePrice	= "update-cena";
		CmdWarnColor	= "varovat-barva";
		ShowAverage	= "zobraz-prumer";
		ShowEmbedBlank	= "integruj-oddelovac";
		ShowLink	= "zobraz-linky";
		ShowMedian	= "zobraz-stred";
		ShowRedo	= "zobraz-varovani";
		ShowStats	= "zobraz-statistiky";
		ShowSuggest	= "zobraz-doporuceni";
		ShowVerbose	= "zobraz-podrobnosti";


		-- Section: Config Text
		GuiAlso	= "Take zobraz data o";
		GuiAlsoDisplay	= "Zobrazuji data o %s";
		GuiAlsoOff	= "Nezobrazuji data o jinych serverech/frakcich.";
		GuiAlsoOpposite	= "Zobrazuji take data o protistrane.";
		GuiAskPrice	= "Zapnout AskPrice";
		GuiAskPriceAd	= "Zaslat data ";
		GuiAskPriceGuild	= "Odpovedet na guildchat";
		GuiAskPriceHeader	= "AskPrice nastaveni";
		GuiAskPriceHeaderHelp	= "Zmenit AskPrice chovani";
		GuiAskPriceParty	= "Odpovedet na partychat";
		GuiAskPriceSmart	= "Pouzit \"SmartWords\"";
		GuiAskPriceTrigger	= "AskPrice prepinac";
		GuiAskPriceVendor	= "Zaslat info o vendorovi";
		GuiAskPriceWhispers	= "Zobrazovat odesilane \"whispers\"";
		GuiAskPriceWord	= "Vlastní \"SmartWord\" %d";
		GuiAuctionDuration	= "Zakladni trvani aukce";
		GuiAuctionHouseHeader	= "Aukci Dum - nastaveni";
		GuiAuctionHouseHeaderHelp	= "Tato nastaveni ovlivnuji fungovani Aukcniho Domu";
		GuiAutofill	= "Automaticke zadavani cen v Aukci";
		GuiAverages	= "Zobraz prumery";
		GuiBidmarkdown	= "Procento z ceny";
		GuiClearall	= "Smaz vsechny Auctioneer zaznamy";
		GuiClearallButton	= "Smaz Vse";
		GuiClearallHelp	= "Klikni zde pro smazani vsech zaznamu pro zvoleny server";
		GuiClearallNote	= "pro zvoleny server a frakci.";
		GuiClearHeader	= "Mazani zaznamu";
		GuiClearHelp	= "Smaze Auctioneerovi zaznamy. Vyberte - vse, nebo posledni zaznam. POZOR: Smazana data nelze obnovit.";
		GuiClearsnap	= "Smazat posledni zaznam";
		GuiClearsnapButton	= "Smazat zaznam";
		GuiClearsnapHelp	= "Klikni zde pro smazani posledniho Auctioneer zaznamu.";
		GuiDefaultAll	= "Obnov vsechna vychozi Auctioneer nastaveni.";
		GuiDefaultAllButton	= "Obnov vse";
		GuiDefaultAllHelp	= "Klikni zde pro navrat vsech Auctioneer nastaveni na vychozi hodnoty. POZOR: Nelze vratit! ";
		GuiDefaultOption	= "Obnov vychozi nastaveni";
		GuiEmbed	= "Vkládat informace do nápověd";
		GuiEmbedBlankline	= "Integruj oddelovac do popisek objektu";
		GuiEmbedHeader	= "Integrace";
		GuiFinish	= "Po skonceni scanu";
		GuiFinishSound	= "Po skončení skenu zahrát zvuk";
		GuiLink	= "Zobraz cislo linku";
		GuiLoad	= "Spust Auctioneer";
		GuiLoad_Always	= "vzdy";
		GuiLoad_AuctionHouse	= "v Aukcnim Dome";
		GuiLoad_Never	= "nikdy";
		GuiLocale	= "Nastavit jazyk na";
		GuiMainEnable	= "Spustit Auctioneer";
		GuiMainHelp	= "Obsahuje nastaveni pro Auctioneer - AddOn ktery sbira a zobrazuje informace z aukce ohledne cen. Klikni na \"Sken\" v Aukci pro zaznamenani aktualnich statistik. ";
		GuiMarkup	= "Procento navyseni vendor ceny";
		GuiMaxless	= "Nejvyssi mozna sleva vuci trzni cene";
		GuiMedian	= "Zobrazuj stredni hodnoty";
		GuiNocomp	= "Neni konkurence - nelze slevit";
		GuiNoWorldMap	= "Auctioneer: Protekce Aukce - Zablokovano otevreni mapy!";
		GuiOtherHeader	= "Dalsi nastaveni";
		GuiOtherHelp	= "Rozlicna Auctioneer nastaveni ";
		GuiPercentsHeader	= "Procentuelne limitujici nastaveni";
		GuiPercentsHelp	= "POZOR: Nasledujici nastaveni urcuji trzni strategii nastavovani cen pomoci Auctioneeru. Jakekoliv zmeny proto zvazte, nejste-li zkuseni hraci a ekonomove.";
		GuiPrintin	= "Vyber textove okno";
		GuiProtectWindow	= "Ochran Aukci proti nechtenemu zavreni";
		GuiRedo	= "Zobraz varovani zasekleho skenu";
		GuiReloadui	= "Znovu nahraj interface\n";
		GuiReloaduiButton	= "NahrajInterface";
		GuiReloaduiFeedback	= "Nahravam interface";
		GuiReloaduiHelp	= "Klikni zde pro opetovne nahrani herniho interface vcetne zvoleneho jazyka. Nahravani muze trvat nekolik minut.";
		GuiRememberText	= "Ukladej ceny";
		GuiStatsEnable	= "Zobrazuj statistiky";
		GuiStatsHeader	= "Statistiky cen objektu";
		GuiStatsHelp	= "Zobrazuj tyto statistiky v popiskach";
		GuiSuggest	= "Zobrazuj doporucene ceny";
		GuiUnderlow	= "Nejnizsi zlevneni trzni ceny";
		GuiUndermkt	= "Krizova sleva z trzni ceny pro pripad ze \"maxztrata\" nestaci";
		GuiVerbose	= "Podrobny mod";
		GuiWarnColor	= "Barevny cenovy model";


		-- Section: Conversion Messages
		MesgConvert	= "Prevod Auctioneer databaze. Nejdriv si prosim zalohujte soubor SavedVariables\Auctioneer.lua first.%s%s";
		MesgConvertNo	= "Vypnout Auctioneer";
		MesgConvertYes	= "Prevest";
		MesgNotconverting	= "Neprevedli jste vasi databazi, Auctioneer ale nebude fungovat dokud tak neucinite. ";


		-- Section: Game Constants
		TimeLong	= "Dlouze";
		TimeMed	= "Stredne";
		TimeShort	= "Kratce";
		TimeVlong	= "Velmi douze";


		-- Section: Generic Messages
		ConfirmBidBuyout	= "Určitě chceš %s\n%dx%s pro:";
		DisableMsg	= "Deaktivuji automaticke zapinani Auctioneeru";
		FrmtWelcome	= "Auctioneer v%s poprve spusten, pripraven k akci!";
		MesgNotLoaded	= "Auctioneer neni spusten. Zadejte /auctioneer pro vice informaci. ";
		StatAskPriceOff	= "AskPrice je vypnut";
		StatAskPriceOn	= "AskPrice je zapnut";
		StatOff	= "Nezobrazuji zadna data.";
		StatOn	= "Zobrazuji (vami) nastavene polozky.";


		-- Section: Generic Strings
		TextCombat	= "Boj";
		TextGeneral	= "Hlavni";
		TextNone	= "nic";
		TextScan	= "Sken\n";
		TextUsage	= "Uziti:";


		-- Section: Help Text
		HelpAlso	= "Prikaz Also zobrazi do popisku statistiky platne pro JINY server. Server a frakci zvolite zadanim nazvu nebo slovem \"protistrana\". Pouziti: /auctioneer also Shadow Moon-Horde.";
		HelpAskPrice	= "Zapnout nebo vypnout AskPrice.";
		HelpAskPriceAd	= "Zapnout nebo vypnout nove schopnosti AskPrice";
		HelpAskPriceGuild	= "Odpovedet na dotazy v guild chatu.";
		HelpAskPriceParty	= "Odpovedet na dotazy v party chatu.";
		HelpAskPriceSend	= "Ručně odeslat hráči výsledek dotazu \"AskPrice\".";
		HelpAskPriceSmart	= "Zapnout nebo vypnout kontrolu SmartWords.";
		HelpAskPriceTrigger	= "Zmenit znak, ktery spousti AskPrice.";
		HelpAskPriceVendor	= "Zapnout nebo vypnout odesilani dat o cenach u prodavacu.";
		HelpAskPriceWhispers	= "Přepíná zobrazení odchozích zpráv \"AskPrice\" (viditelné nebo neviditelné).";
		HelpAskPriceWord	= "Přidat nebo změnit vlastní \"SmartWords\" pro \"AskPrice\".";
		HelpAuctionClick	= "Umoznuje automaticky vlozit předmět z inventare do aukce pomoci Alt-Kliku a založit pro něj aukci.";
		HelpAuctionDuration	= "Pri otevreni Aukce nastavi zvolenou vychozi hodnotu jejiho trvani. ";
		HelpAutofill	= "Nastavi zda ma Auctioneer vyplnit doporucene ceny pri vytvareni aukce (ty vzdy lze zmenit)";
		HelpAverage	= "Nastavi zda se maji zobrazovat prumerne aukci ceny";
		HelpBidbroker	= "Zobrazi kratke a stredni aukce z posledniho zaznamu jejichz momentalni nabidka je pod cenou a tak na nich lze vydelat";
		HelpBidLimit	= "Maximalni pocet aukci, na ktere se da bidovat nebo buyoutovat, kdyz stisknete Bid nebo Buyout tlacitko na Search Auctions karte.";
		HelpBroker	= "Zobrazi vsechny aukce z posledniho zaznamu, ktere koupene za momentalni naBIDku lze pozdeji prodat se ziskem";
		HelpClear	= "Smaze zaznamy k vybranemu objektu (objekt vlozite do prikazu Shift-Klikem) nebo zadanim \"vse\" nebo jen posledni \"zaznam\". ";
		HelpCompete	= "Zobrazi vsechny aukce z posledniho zaznamu, jejichz Vykupni cena je nizsi, nez ta vase za stejny predmet";
		HelpDefault	= "Obnovi vychozu hodnotu zvoleneho nastaveni Auctioneeru. Take lze zadat \"vse\" pro obnoveni vsech nastaveni na vychozi hodnoty. ";
		HelpDisable	= "Deaktivuje automaticke zapinani Auctioneeru pri pristim prihlaseni ";
		HelpEmbed	= "Prida/integruje Auctioneer statistiky do puvodniho popisku objektu (ale nektere moznosti jsou v tomto modu nedostupne)";
		HelpEmbedBlank	= "Nastavi zda se ma zobrazovat prazdny radek mezi puvodnim popiskem predmetu a pridanymi statistikami, jsou-li integrovane do popisku objektu";
		HelpFinish	= "Nastavit, jestli automaticky odhlasit nebo vypnout hru po ukonceni skenovani aukci";
		HelpFinishSound	= "Nastaví zda se má po skončení skenu zahrát zvuk.";
		HelpLink	= "Nastavi zda se ma zobrazovat ID/cislo linku objektu do popisku";
		HelpLoad	= "Zmeni zapinani Auctioneeru pro tuto postavu";
		HelpLocale	= "Zmeni jazyk, v jakem s vami Auctioneer komunikuje";
		HelpMedian	= "Nastavi zda se ma zobrazovat \"median\" vykupni cena predmetu";
		HelpOnoff	= "Zapne nebo vypne zobrazovani ziskanych cenovych zaznamu";
		HelpPctBidmarkdown	= "Nastavi procento Vykupni ceny, podle ktereho se urci pocatecni nabidka";
		HelpPctMarkup	= "Nastavi procento, o ktere se nadsadi vykupni cena v obchode, nejsou-li k dispozici jine udaje";
		HelpPctMaxless	= "Nastavi maximalni procento, o ktere se Auctioneer pokusi slevit z bezne trzni ceny";
		HelpPctNocomp	= "Nastavi procento o ktere Auctioneer slevi z bezne trzni ceny, kdyz neexistuje konkurence";
		HelpPctUnderlow	= "Nastavi procento, o ktere ma Auctioneer \"podrazit\" nejnizsi cenu daneho objektu v aktualnim zaznamu";
		HelpPctUndermkt	= "Procento slevy z trzni ceny pro prekonani konkurence kdyz rozdil prekonal \"maxztrata\" limit";
		HelpPercentless	= "Zobrazi vsechny aukce z posledniho zaznamu, jejichz vykupni cena je o urcene procento nizsi, nez jejich zaznamenana nejvyssi uspesna vykupni cena";
		HelpPrintin	= "Nastavi v kterem okne ma Auctioneer vypisovat zpravy. Muzete zvolit jmeno okna nebo jeho index.";
		HelpProtectWindow	= "Zabrani nechtenemu zavreni Aukcniho okna";
		HelpRedo	= "Nastavi zda se ma zobrazovat varovani, kdyz nacitani aktualni aukcni stranky trva prilis dlouho kvuli pretizeni serveru.";
		HelpScan	= "Provede sken vybrannych aukci pri vasi pristi navsteve, nebo hned (take je zde \"sken\" tlacitko v aukcnim okne). Zaskrtnete ktere kategorie chcete naskenovat.";
		HelpStats	= "Nastavi zda se ma zobrazovat procenta u nabidky a vykupni ceny";
		HelpSuggest	= "Nastavi zda se ma zobrazovat doporucena aukci cena";
		HelpUpdatePrice	= "Automaticky updatuje pocatecni cenu pro aukci na tabulce Podavani aukci, pri zmene Vykupni ceny.";
		HelpVerbose	= "Nastavi zda se maji zobrazovat detailni prumerne a doporucene ceny (\"vypnuto\" znamena ze se budou zobrazovat v jednom radku)";
		HelpWarnColor	= "Vyber jestli ukazovat aktualni AH cenovy model v intuitivnich barvach.";


		-- Section: Post Messages
		FrmtNoEmptyPackSpace	= "Zadne volne pack misto pro vytvoreni aukce!";
		FrmtNotEnoughOfItem	= "Nedostatek %s penez pro vytvoreni aukce!";
		FrmtPostedAuction	= "Podana 1 aukce %s (x%d)";
		FrmtPostedAuctions	= "Podano %d aukci %s (x%d)";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "tedNabidka";
		FrmtBidbrokerDone	= "Vypis nabidek dokoncen";
		FrmtBidbrokerHeader	= "Minimalni zisk: %s, NDC = 'Nejvyssi Dosazitelna Cena'";
		FrmtBidbrokerLine	= "%s, poslecnich %s zaznamenanych, NDC: %s, %s: %s, Zisk: %s, Cas: %s";
		FrmtBidbrokerMinbid	= "minNabidka";
		FrmtBrokerDone	= "Vypis dokoncen";
		FrmtBrokerHeader	= "Minimalni zisk: %s, NDC = 'Nejvyssi Dosazitelna Cena'";
		FrmtBrokerLine	= "%s, poslednich %s zaznamenanych, NDC: %s, Vykup: %s, zisk: %s";
		FrmtCompeteDone	= "Prebijeni aukci dokonceno";
		FrmtCompeteHeader	= "Prebit aukce alespon o %s za 1 kus.";
		FrmtCompeteLine	= "%s, Nabidka: %s, Vykup %s vs %s, %s levnejsi";
		FrmtHspLine	= "Nejvyssi Dosazitelna Cena za jeden %s je: %s";
		FrmtLowLine	= "%s, Vykup: %s, Prodejce: %s, Za jeden: %s, Mene nez median: %s";
		FrmtMedianLine	= "U poslednich %d zaznamenanych, median Vykup za 1 kus %s je: %s";
		FrmtNoauct	= "Nenalezeny zadne aukce predmetu: %s";
		FrmtPctlessDone	= "Vypis \"percentless\" dokoncen. ";
		FrmtPctlessHeader	= "Procentuelni rozdil od Nejvyssi Dosazitelne Ceny (NDC): %d%%";
		FrmtPctlessLine	= "%s, Poslednich %d zaznamenanych, NDC: %s, Vykup: %s, Zisk: %s, Levnejsi %s";


		-- Section: Scanning Messages
		AuctionDefunctAucts	= "Neplatnych aukci odstraneno: %s";
		AuctionDiscrepancies	= "Odlisnosti: %s";
		AuctionNewAucts	= "Novych aukci zaznamenano: %s";
		AuctionPageN	= "Auctioneer: skenuji %s, stranu %d z %d Aukci za vterinu: %s Odhadovany cas do konce: %s";
		AuctionScanDone	= "Auctioneer: Skenovani aukci ukonceno.";
		AuctionScanNexttime	= "Auctioneer provede kompletni sken aukci pri pristi navsteve.";
		AuctionScanNocat	= "Musi byt vybrana alespon jedna kategorie.";
		AuctionScanRedo	= "Posledni strana trvala pres %d vterin, zkousim to znovu...";
		AuctionScanStart	= "Auctioneer: Skenuji prvni stranu %s...";
		AuctionTotalAucts	= "Celkem zaznamenano aukci: %s";


		-- Section: Tooltip Messages
		FrmtInfoAlsoseen	= "Videno %d -krat na %s";
		FrmtInfoAverage	= "%s min/%s Vykup (%s nabidka)";
		FrmtInfoBidMulti	= "Nabidnuto (%s%s za kus)";
		FrmtInfoBidOne	= "Nabidnuto %s";
		FrmtInfoBidrate	= "%d%% ma nabidku, %d%% ma Vykup";
		FrmtInfoBuymedian	= "Median vykup ";
		FrmtInfoBuyMulti	= "Vykup (%s%s za kus)";
		FrmtInfoBuyOne	= "Vykup %s";
		FrmtInfoForone	= "Za 1: %s min/%s Vykup (%s nabidka) [v %d's]";
		FrmtInfoHeadMulti	= "Prumery pro %d predmetu: ";
		FrmtInfoHeadOne	= "Prumery pro tento predmet: ";
		FrmtInfoHistmed	= "Poslednich %d, median vykup za kus";
		FrmtInfoMinMulti	= "Prvni nabidka (%s za kus)";
		FrmtInfoMinOne	= "Prvni nabidka";
		FrmtInfoNever	= "Nikdy nezaznamenano na %s";
		FrmtInfoSeen	= "Zaznamenano %d-krat na aukci";
		FrmtInfoSgst	= "Doporucena cena: %s min/%s Vykup";
		FrmtInfoSgststx	= "Doporucena cena za vasi %d sadu: %s min/%s Vykup";
		FrmtInfoSnapmed	= "Zaznamenano %d, stredni Vykup (za kus)";
		FrmtInfoStacksize	= "Prumerna velikost sady: %d objektu";


		-- Section: User Interface
		BuySortTooltip	= "Setřídit stránku výsledků podle výkupní ceny (se SHIFT-em bude třídit podle názvu předmětu)";
		ClearTooltip	= "Vymazat všechny hodnoty z políček pro vyhledávání.";
		FrmtLastSoldOn	= "Naposledy prodáno %s";
		RefreshTooltip	= "Odeslat znovu dotaz na této stránce.";
		UiBid	= "Nabídka";
		UiBidHeader	= "Nabídka";
		UiBidPerHeader	= "Nabídka za kus";
		UiBuyout	= "Výkup";
		UiBuyoutHeader	= "Výkup";
		UiBuyoutPerHeader	= "Výkup za kus";
		UiBuyoutPriceLabel	= "Výkupní cena:";
		UiBuyoutPriceTooLowError	= "(Příliš nízká)";
		UiCategoryLabel	= "Omezení kategorie:";
		UiDepositLabel	= "Záloha:";
		UiDurationLabel	= "Trvání:";
		UiItemLevelHeader	= "Lvl";
		UiMakeFixedPriceLabel	= "Zapamatuj si cenu";
		UiMaxError	= "(%d Max)";
		UiMaximumPriceLabel	= "Nejvyšší cena:";
		UiMaximumTimeLeftLabel	= "Maximalni zbyvajici doba:";
		UiMinimumProfitLabel	= "Nejmenší zisk:";
		UiMinimumQualityLabel	= "Nejnizsi kvalita:";
		UiMinimumUndercutLabel	= "Nejmensi prebiti:";
		UiNameHeader	= "Jmeno";
		UiNoPendingBids	= "Vsechny pozadovane nabidky dokonceny!";
		UiNotEnoughError	= "(nedostatek)";
		UiPendingBidInProgress	= "1 pozadavek na nabidku se zpracovava...";
		UiPendingBidsInProgress	= "%d pozadavku na nabidky se zpracovava...";
		UiPercentLessHeader	= "Pct";
		UiPost	= "Podat";
		UiPostAuctions	= "Podat aukci";
		UiPriceBasedOnLabel	= "Cena podle:";
		UiPriceModelAuctioneer	= "Auctioneer ceny";
		UiPriceModelCustom	= "Vlastní ceny";
		UiPriceModelFixed	= "Pevná cena";
		UiPriceModelLastSold	= "Cena posledního prodeje";
		UiProfitHeader	= "Zisk";
		UiProfitPerHeader	= "Zisk za kus";
		UiQuantityHeader	= "Množství";
		UiQuantityLabel	= "Množství:";
		UiRemoveSearchButton	= "Smazat";
		UiSavedSearchLabel	= "Uložená vyhledávání:";
		UiSaveSearchButton	= "Uložit";
		UiSaveSearchLabel	= "Ulozit toto vyhledavani:";
		UiSearch	= "Hledat";
		UiSearchAuctions	= "Prohledat aukce";
		UiSearchDropDownLabel	= "Hledat:";
		UiSearchForLabel	= "Vyhledat předmět:";
		UiSearchTypeBids	= "NaBIDky";
		UiSearchTypeBuyouts	= "Výkupy";
		UiSearchTypeCompetition	= "Konkurence";
		UiSearchTypePlain	= "Předmět";
		UiStacksLabel	= "Balíčky";
		UiStackTooBigError	= "(Moc velký balíček)";
		UiStackTooSmallError	= "(Moc malý balíček)";
		UiStartingPriceLabel	= "Vychozi cena:";
		UiStartingPriceRequiredError	= "(Nutne)";
		UiTimeLeftHeader	= "Zbyvajici cas";
		UiUnknownError	= "(tajuplna chyba)";

	};

	daDK = {


		-- Section: AskPrice Messages
		AskPriceAd	= "Hent stak priser for %sx[ItemLink] (x = stacksize) ";
		FrmtAskPriceBuyoutMedianHistorical	= "%sOpkøbs-median historisk: %s%s ";
		FrmtAskPriceBuyoutMedianSnapshot	= "%sOpkøbs-median ved sidste skanning: %s%s";
		FrmtAskPriceDisable	= "Deaktiver AskPrices %s funktionen";
		FrmtAskPriceEach	= "(%s pr. stk.)";
		FrmtAskPriceEnable	= "Aktiverer AskPrices %s funktionen";
		FrmtAskPriceVendorPrice	= "%sSælg til forhandler for: %s%s";


		-- Section: Auction Messages
		FrmtActRemove	= "Fjerner auktion %s fra nuværende Auktionshus snapshot.";
		FrmtAuctinfoHist	= "%d historisk";
		FrmtAuctinfoLow	= "Mindste pris";
		FrmtAuctinfoMktprice	= "Markedspris";
		FrmtAuctinfoNolow	= "Ikke set ved sidste skanning";
		FrmtAuctinfoOrig	= "Oprindeligt bud";
		FrmtAuctinfoSnap	= "%d sidste scanning";
		FrmtAuctinfoSugbid	= "Foreslået startbud";
		FrmtAuctinfoSugbuy	= "Foreslået opkøbspris";
		FrmtWarnAbovemkt	= "Konkurrence ligger over markedet";
		FrmtWarnMarkup	= "Overbyder forhandlere med %s%%";
		FrmtWarnMyprice	= "Bruger min nuværende pris";
		FrmtWarnNocomp	= "Ingen konkurrence";
		FrmtWarnNodata	= "Ingen data for HSP";
		FrmtWarnToolow	= "Kan ikke konkurrere med laveste pris";
		FrmtWarnUndercut	= "Underbyder med %s%%";
		FrmtWarnUser	= "Anvender brugerdefineret pris";


		-- Section: Bid Messages
		FrmtAlreadyHighBidder	= "Allerede den højestbydende på auktion: %s (x%d)";
		FrmtBidAuction	= "Byd på auktion: %s (x%d)";
		FrmtBidQueueOutOfSync	= "Fejl: Bud kø ude af synkronisering!";
		FrmtBoughtAuction	= "Opkøbt auktion: %s (x%d)";
		FrmtMaxBidsReached	= "Flere auktioner af %s (x%d) fundet, men bud grænse nået (%d)";
		FrmtNoAuctionsFound	= "Ingen auktioner fundet: %s (x%d)";
		FrmtNoMoreAuctionsFound	= "Ikke flere auktioner fundet: %s (x%d)";
		FrmtNotEnoughMoney	= "Ikke nok penge til at byde på auktion: %s (x%d)";
		FrmtSkippedAuctionWithHigherBid	= "Sprang over auktion med højere bud: %s (x%d)";
		FrmtSkippedAuctionWithLowerBid	= "Sprang over auktion med lavere bud: %s (x%d)";
		FrmtSkippedBiddingOnOwnAuction	= "Sprang over egen auktion: %s (x%d)";
		UiProcessingBidRequests	= "Bearbejder bud forespørgelser...";


		-- Section: Command Messages
		ConstantsCritical	= "KRITISK ADVARSEL:Din Auctioneer SavedVariables fil er %.3f%% fuld";
		ConstantsMessage	= "Din Auctioneer SavedVariables fil er %.3f%% fuld";
		ConstantsWarning	= "ADVARSEL:Din Auctioneer SavedVariables fil er %.3f%% fuld";
		FrmtActClearall	= "Fjerner alle data for auktionen %s";
		FrmtActClearFail	= "Kan ikke finde genstand: %s";
		FrmtActClearOk	= "Fjerner data for genstand: %s";
		FrmtActClearsnap	= "Fjerner nuværende Auktionhus data.";
		FrmtActDefault	= "Auctioneers %s indstillinger er blevet nulstillet til standard værdier";
		FrmtActDefaultall	= "Alle Auctioneers indstillinger er blevet nulstillet til standard værdier.";
		FrmtActDisable	= "Viser ikke data for: %s ";
		FrmtActEnable	= "Viser data for: %s ";
		FrmtActSet	= "Sætter %s til '%s'";
		FrmtActUnknown	= "Ukendt kommando eller nøgleord: '%s'";
		FrmtAuctionDuration	= "Normal auktions tid sat til: %s";
		FrmtAutostart	= "Starter automatisk auktion for %s minimum, %s opkøb (%dh)\n%s";
		FrmtFinish	= "Efter en scanning er afsluttet, skal vi %s";
		FrmtPrintin	= "Auctioneers beskeder vil nu blive skrevet til \"%s\" chat ramme";
		FrmtProtectWindow	= "Auktionshus vinduebeskyttelse sat til: %s";
		FrmtUnknownArg	= "'%s' er ikke et gyldigt argument for '%s'";
		FrmtUnknownLocale	= "Sproget du har angivet: ('%s') er ukendt. Gyldige sprog er:";
		FrmtUnknownRf	= "Ugyldig parameter ('%s'). Parameteret skal se sådan ud: [realm]-[faction]. Eksempelvis: Al'Akir-Horde";


		-- Section: Command Options
		OptAlso	= "(realm-faction|modsat|hjemme|neutral)";
		OptAuctionDuration	= "(sidst||2t||8t||24t)";
		OptBidbroker	= "<fortjeneste_i_sølv>";
		OptBidLimit	= "<nummer>";
		OptBroker	= "<fortjeneste_i_sølv>";
		OptClear	= "([Genstand]alt|snapshot)";
		OptCompete	= "<sølv_under>";
		OptDefault	= "(<Indstilling>|alt)";
		OptFinish	= "(sluk|log af|slut|genindlæsUI) ";
		OptLocale	= "<lokal>";
		OptPctBidmarkdown	= "<procent>";
		OptPctMarkup	= "<procent>";
		OptPctMaxless	= "<procent>";
		OptPctNocomp	= "<procent>";
		OptPctUnderlow	= "<procent>";
		OptPctUndermkt	= "<procent>";
		OptPercentless	= "<procent>";
		OptPrintin	= "(<frameIndex>[Nummer]|<frameNavn>[Streng]) ";
		OptProtectWindow	= "(aldrig|scan|altid) ";
		OptScale	= "<skalerings_faktor>";
		OptScan	= "<>";


		-- Section: Commands
		CmdAlso	= "også";
		CmdAlsoOpposite	= "modsatte";
		CmdAlt	= "alt";
		CmdAskPriceAd	= "reklame";
		CmdAskPriceGuild	= "guild";
		CmdAskPriceParty	= "gruppe";
		CmdAskPriceSmart	= "smart";
		CmdAskPriceSmartWord1	= "Hvad";
		CmdAskPriceSmartWord2	= "værd";
		CmdAskPriceTrigger	= "udløser";
		CmdAskPriceVendor	= "forhandler";
		CmdAskPriceWhispers	= "private beskeder";
		CmdAskPriceWord	= "ord";
		CmdAuctionClick	= "auktion-klik";
		CmdAuctionDuration	= "Auktionsvarighed";
		CmdAuctionDuration0	= "sidst";
		CmdAuctionDuration1	= "2t";
		CmdAuctionDuration2	= "8t";
		CmdAuctionDuration3	= "24t";
		CmdAutofill	= "auto udfyld";
		CmdBidbroker	= "bidbroker";
		CmdBidbrokerShort	= "bb";
		CmdBidLimit	= "bud-grænse";
		CmdBroker	= "broker";
		CmdClear	= "ryd";
		CmdClearAll	= "alt";
		CmdClearSnapshot	= "billede";
		CmdCompete	= "konkurrere";
		CmdCtrl	= "ctrl";
		CmdDefault	= "standard";
		CmdDisable	= "slå fra";
		CmdEmbed	= "indkapsle";
		CmdFinish	= "færdig";
		CmdFinish0	= "sluk";
		CmdFinish1	= "log af";
		CmdFinish2	= "luk";
		CmdFinish3	= "genindlæsUI";
		CmdFinishSound	= "Slut lyd";
		CmdHelp	= "hjælp";
		CmdLocale	= "lokal";
		CmdOff	= "sluk";
		CmdOn	= "tænd";
		CmdPctBidmarkdown	= "pct-bidmarkdown ";
		CmdPctMarkup	= "pct-markup ";
		CmdPctMaxless	= "pct-maxless ";
		CmdPctNocomp	= "pct-nocomp ";
		CmdPctUnderlow	= "pct-underlow ";
		CmdPctUndermkt	= "pct-undermkt ";
		CmdPercentless	= "percentless ";
		CmdPercentlessShort	= "pl";
		CmdPrintin	= "print-til";
		CmdProtectWindow	= "beskyt-vindue";
		CmdProtectWindow0	= "aldrig";
		CmdProtectWindow1	= "scan";
		CmdProtectWindow2	= "altid";
		CmdScan	= "scan";
		CmdShift	= "skift";
		CmdToggle	= "tænd/sluk";
		CmdUpdatePrice	= "opdater-pris";
		CmdWarnColor	= "advarsels-farve";
		ShowAverage	= "vis-gennemsnit";
		ShowEmbedBlank	= "vis-indkapsle-blanklinje";
		ShowLink	= "vis-link";
		ShowMedian	= "vis-median";
		ShowRedo	= "vis-advarsel";
		ShowStats	= "vis-stats";
		ShowSuggest	= "vis-forslag";
		ShowVerbose	= "vis-ordrig";


		-- Section: Config Text
		GuiAlso	= "Vis også data for";
		GuiAlsoDisplay	= "Viser data for %s";
		GuiAlsoOff	= "Viser ikke længere data fra andre realm-fraktioner.";
		GuiAlsoOpposite	= "Viser nu også data for modsatte fraktion.";
		GuiAskPrice	= "Slå AskPrice til";
		GuiAskPriceAd	= "Send reklame for egenskaber";
		GuiAskPriceGuild	= "Svar på guildchat forespørgsler";
		GuiAskPriceHeader	= "AskPrice indstillinger";
		GuiAskPriceHeaderHelp	= "Skift AskPrices opførsel";
		GuiAskPriceParty	= "Svar på partychat forespørgsler";
		GuiAskPriceSmart	= "Brug smarte ord";
		GuiAskPriceTrigger	= "AskPrice udløser";
		GuiAskPriceVendor	= "Send forhandler informationer";
		GuiAskPriceWhispers	= "Vis udgående private beskeder";
		GuiAskPriceWord	= "brugerdefineret SmartWord %d";
		GuiAuctionDuration	= "Normal auktions varighed";
		GuiAuctionHouseHeader	= "Auktionshus vindue";
		GuiAuctionHouseHeaderHelp	= "Ændr Auktionshusets vinduesindstillinger";
		GuiAutofill	= "Autoudfyld priser i Auktionshuset";
		GuiAverages	= "Vis middel";
		GuiBidmarkdown	= "Nedsæt bud med xx procent";
		GuiClearall	= "Ryd alle data fra Auctioneer";
		GuiClearallButton	= "Ryd alt";
		GuiClearallHelp	= "Klik her for at fjerne alle data fra Auctioneer for den nuværende server-realm.";
		GuiClearallNote	= "for den nuværende server-fraktion";
		GuiClearHeader	= "Ryd data";
		GuiClearHelp	= "Ryd Auctioneer data. \nVælg alle data eller det nuværende snapshot.\nADVARSEL: Disse handlinger kan IKKE fortrydes.";
		GuiClearsnap	= "Ryd Snapshotdata";
		GuiClearsnapButton	= "Fjern Snapshot";
		GuiClearsnapHelp	= "Klik her for at slette den sidste skanning af auktionen.";
		GuiDefaultAll	= "Nulstil alle Auctioneer indstillinger";
		GuiDefaultAllButton	= "Nulstil alt";
		GuiDefaultAllHelp	= "Klik her for at sætte alle Auctioneer valg til standard værdier.\nADVARSEL: Denne handling kan IKKE fortrydes.";
		GuiDefaultOption	= "Nulstil denne opsætning.";
		GuiEmbed	= "Indrammet info i spillets tooltip";
		GuiEmbedBlankline	= "Viser blank linje i spillets tooltip";
		GuiEmbedHeader	= "Indrammet";
		GuiFinish	= "Efter en skanning er afsluttet";
		GuiFinishSound	= "Afspil lyd når scaning er afsluttet";
		GuiLink	= "Viser LinkID";
		GuiLoad	= "Hent Auctioneer";
		GuiLoad_Always	= "altid";
		GuiLoad_AuctionHouse	= "ved Auktionshuset";
		GuiLoad_Never	= "aldrig";
		GuiLocale	= "Sæt sprog til";
		GuiMainEnable	= "Start Auctioneer";
		GuiMainHelp	= "Indeholder værdier for Auctioneer. En AddOn som viser information om genstande og analysere auktionsdata. \nKlik på \"Skan\" knappen på Auktionshuset for at indsamle auktionsdata.";
		GuiMarkup	= "Procent overbud iht. forhandler";
		GuiMaxless	= "Procent maks. under markeds pris";
		GuiMedian	= "Vis medianer";
		GuiNocomp	= "Procent under markedets pris ved ingen konkurence";
		GuiNoWorldMap	= "Auctioneer: Undertrykker visningen af World Map";
		GuiOtherHeader	= "Andre indstillinger";
		GuiOtherHelp	= "Diverse indstillinger til Auctioneer";
		GuiPercentsHeader	= "Auctioneer graense procent";
		GuiPercentsHelp	= "Advarsel: De følgende valgmuligheder er KUN for Superbrugere.\nVed at ændre på følgende muligheder ændrer du hvor aggresivt Auctioneer vil være når den udregner profit.";
		GuiPrintin	= "Vaelg den oenskede chat ramme.";
		GuiProtectWindow	= "Forhindrer lukning af Auktionshus vindue ved uheld";
		GuiRedo	= "Vis advarsel ved lang skanning.";
		GuiReloadui	= "Genindlæser brugerflade.";
		GuiReloaduiButton	= "GenindlæsUI";
		GuiReloaduiFeedback	= "Genindlæser nu WoW UI";
		GuiReloaduiHelp	= "Klik her for at genindlaese WoW brugerfladen efter at have ændret sprog.\nBemærk: Dette kan tage et par minutter.";
		GuiRememberText	= "Husk prisen";
		GuiStatsEnable	= "Vis Statistik";
		GuiStatsHeader	= "Genstand Pris Statistik";
		GuiStatsHelp	= "Vis følgende statistikker i tooltippet.";
		GuiSuggest	= "Vis foreslåede priser";
		GuiUnderlow	= "Laveste auktionspris";
		GuiUndermkt	= "Underbyd markedet når der ingen maxpris findes.";
		GuiVerbose	= "Tekst Mode";
		GuiWarnColor	= "Farve Pris Model";


		-- Section: Conversion Messages
		MesgConvert	= "Konverterer Auctioneer Databasen. Tag venligst en backup af SavedVariables\\Auctioneer.lua inden.%s%s";
		MesgConvertNo	= "Indlaes ikke Auctioneer";
		MesgConvertYes	= "Konventer nu";
		MesgNotconverting	= "Auctioneer konventerer ikke din database, men vil ikke virke faar du goer.";


		-- Section: Game Constants
		TimeLong	= "Lang";
		TimeMed	= "Middel";
		TimeShort	= "Kort";
		TimeVlong	= "Meget Lang";


		-- Section: Generic Messages
		ConfirmBidBuyout	= "Er sikker på du vil %s\n%dx%s til:";
		DisableMsg	= "Stopper automatisk indlaesning af Auctioneer";
		FrmtWelcome	= "Auctioneer v%s er indlaest";
		MesgNotLoaded	= "Auctioneer er ikke indlaest. Skriv /auctioneer for mere info.";
		StatAskPriceOff	= "AskPrice er nu deaktiveret.";
		StatAskPriceOn	= "AskPrice er nu aktiveret.";
		StatOff	= "Viser ikke nogen auktionsdata.";
		StatOn	= "Viser konfigureret auktionsdata.";


		-- Section: Generic Strings
		TextCombat	= "Kamp";
		TextGeneral	= "General";
		TextNone	= "ingen";
		TextScan	= "Scan";
		TextUsage	= "Brug:";


		-- Section: Help Text
		HelpAlso	= "Viser ogsaa en anden servers priser i tooltipet. For realm, indsaet realmnavnet og faction navnet. Som eksempel: \"/auctioneer also Al'Akir-Horde\". Det speciale noegleord \"opposite\" betyder den modstridne fraktion, \"off\" stopper denne funktion.";
		HelpAskPrice	= "Slå AskPrice til eller fra";
		HelpAskPriceAd	= "Tillad eller bloker nye AskPrice funktions reklame.";
		HelpAskPriceGuild	= "Svarer på en forspørgelse lavet i guild chat.";
		HelpAskPriceParty	= "Svarer på en forspørgelse lavet i party chat.";
		HelpAskPriceSmart	= "Tillad eller bloker SmartWrods check";
		HelpAskPriceTrigger	= "Ændre AskPrice's kommando.";
		HelpAskPriceVendor	= "Tillad eller bloker sendingen af vendor pris data.";
		HelpAskPriceWhispers	= "Vis eller skjul prisforspørgelser i udgående private beskeder";
		HelpAskPriceWord	= "Tilføje eller ændre AskPrice´s brugerdefinerede SmartWords.";
		HelpAuctionClick	= "Tillader Alt-klik paa et objekt i dine tasker for automatisk at starte en auktion for det";
		HelpAuctionDuration	= "Saet den normale auktions varighed ved aabning af AH vindue";
		HelpAutofill	= "Saet om Auctioneer skal autoudfylde priser naar objekter overfoeres til auktionshusets boks.";
		HelpAverage	= "Vaelger om middelprisen paa en auktion skal vises.";
		HelpBidbroker	= "Viser korte og middel auktioner som kan blive budt paa og solgt med fortjeneste.";
		HelpBidLimit	= "Maksimalt antal af auktion på bud eller opkøb når Byd eller Opkøb knappen er valgt på Søg Auktioner fanen";
		HelpBroker	= "Viser auktioner fra sidste scanning som kan blive opkoebt og solgt med fortjeneste.";
		HelpClear	= "Sletter data for et specifikt objekt (du skal shift-klikke på objektet så det kommer ned i kommando boxen.) Du kan også specifisere enkelte nøgle ord som \"all\" eller \"snapshot\"";
		HelpCompete	= "Viser objekter fra sidste skanning som har lavere opkøbspris end dine ting.";
		HelpDefault	= "Sætter Auctioneer til dens standard værdi. Du kan eventuelt bruge nøgleord som: \"all\" for at sætte alle valg til deres standard værdier.";
		HelpDisable	= "Stopper Auctioneer så det ikke indlæses automatisk næste gang du logger ind.";
		HelpEmbed	= "Indrammer teksten i spillets egen tooltip (bemærk: nogle muligheder vil være utilgængelige i denne mode.)";
		HelpEmbedBlank	= "Vælg om der skal være blanke linjer mellem tooltip info og auktions info når embedded mode er valgt";
		HelpFinish	= "set for automatisk logge ud eller exit spil ved auktions scan afslutning";
		HelpFinishSound	= "Vælg om der skal afspilles en lyd når skanning af aktionshuset er færdig.";
		HelpLink	= "Vælger om der skal vises link id i tooltippet.";
		HelpLoad	= "Ændre Auctioneers load indstillinger for denne karakter";
		HelpLocale	= "Skifter sprog på auctioneer scriptet.";
		HelpMedian	= "Vælger om der skal vises middel opkøbspris.";
		HelpOnoff	= "Slår visning af auktions data til og fra.";
		HelpPctBidmarkdown	= "Sæt procenter Auctioneer vil sætte prisen under objektets opkøbspris.";
		HelpPctMarkup	= "Procenten som Auctioneer vil overbyde forhandleren på et objekt hvor prisen ikke kendes.";
		HelpPctMaxless	= "SÃ¦t den maksimale procent som Auctioneer vil gÃ¥ under markeds vÃ¦rdi inden den giver op.";
		HelpPctNocomp	= "Procenten Auctioneer vil gÃ¥ under markedet pris nÃ¥r der ikke findes konkurrenter";
		HelpPctUnderlow	= "SÃ¦t procenter some Auctioneer vil gÃ¥ under den laveste pris";
		HelpPctUndermkt	= "Procenter Auctioneer vil bruge hvis den ikke kan gÃ¥ under konkurrenter (pga. maks/min)";
		HelpPercentless	= "Viser objekter fra sidste skanning hvis opkÃ¸bspris er en bestemt procent lavere end den hÃ¸jst sÃ¦lgende pris.";
		HelpPrintin	= "Vælg hvilken ramme Auctioneer vil skrive til. Du kan enten angive et ramme navn eller rammens indeks nummer.";
		HelpProtectWindow	= "Forhindrer dig i at lukke AH vinduet ved et uheld";
		HelpRedo	= "VÃ¦lg om der skal vises en advarsel hvis den nuvÃ¦rende skanning har taget for lang tid pÃ¥ grund af server lag.";
		HelpScan	= "UdfÃ¸rer en scan af auktionshuset nÃ¦ste gang du besÃ¸ger det, eller mens du er der.(Der er ogsÃ¥ en knap i auktionshuset under browse, der kan du ogsÃ¥ vÃ¦lge hvilke katagorier du Ã¸nsker at skanne ved at bruge flueben..";
		HelpStats	= "Vaelger om der skal vises bud/opkoebs pris i procenter.";
		HelpSuggest	= "Vaelger om der skal vises foreslået salgspris ved auktion.";
		HelpUpdatePrice	= "Automatisk opdater start prisen for en auktion på Post Auctions fanebladdet når udkøbsprisen ændres.";
		HelpVerbose	= "Vaelger hvordan teksten formuleres. (forslag, middelpriser eller off for at vise dem paa en enkelt linje.)";
		HelpWarnColor	= "Vælg at vise den nuværende AH pris model (Underbydde med...) i intuitive farver.";


		-- Section: Post Messages
		FrmtNoEmptyPackSpace	= "Ingen tomme pack rum fundet til at lave auktionen!";
		FrmtNotEnoughOfItem	= "Ikke nok %s fundet til at lave auktionen!";
		FrmtPostedAuction	= "(x%d) %s sat på auktion";
		FrmtPostedAuctions	= "%d auktioner af (x%d) %s lavet";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "Nuvaerende bud";
		FrmtBidbrokerDone	= "Prisliste faerdig";
		FrmtBidbrokerHeader	= "Minimum profit: %s, HSP = 'Hoejeste Saelgende Pris'";
		FrmtBidbrokerLine	= "%s, sidst %s set, HSP: %s, %s: %s, Profit: %s, Tid: %s";
		FrmtBidbrokerMinbid	= "Mindste bud";
		FrmtBrokerDone	= "Liste faerdig.";
		FrmtBrokerHeader	= "Minimum profit: %s, HSP = 'Hoejeste Saelgende Pris'";
		FrmtBrokerLine	= "%s, Sidst %s set, HSP: %s, KoebNu: %s, Profit: %s";
		FrmtCompeteDone	= "Konkurerende auktioner er afsluttet";
		FrmtCompeteHeader	= "Konkurerende auktioner er mindst %s under pr. vare.";
		FrmtCompeteLine	= "%s, Bud: %s, BO %s mod %s, %s mindre";
		FrmtHspLine	= "HÃ¸jeste SÃ¦lgende Pris for en %s er: %s";
		FrmtLowLine	= "%s, BO: %s, sÃ¦lger: %s, For en: %s, under middel: %s";
		FrmtMedianLine	= "Af sidste %d set, middel BO for 1 %s er: %s";
		FrmtNoauct	= "Ingen auktioner blev fundet for: %s";
		FrmtPctlessDone	= "Udregning af Procenter faerdig.";
		FrmtPctlessHeader	= "Procent mindre end hoejeste saelgende pris(HSP): %d%%";
		FrmtPctlessLine	= "%s, sidst %d set, HSP: %s, BO: %s, Profit: %s, Mindre %s";


		-- Section: Scanning Messages
		AuctionDefunctAucts	= "Afsluttede auktioner fjernet: %s";
		AuctionDiscrepancies	= "Uoverensstemmelser: %s";
		AuctionNewAucts	= "Nye auktioner skannet: %s";
		AuctionPageN	= "Auctioneer: skanner nu %s side %d af %d\nAuktioner pr sekund: %s\nBeregnet tid tilbage: %s";
		AuctionScanDone	= "Auctioneer: Skanningen af auktionerne er faerdig.";
		AuctionScanNexttime	= "Auctioneer vil udfoere en komplet scanning af auktionshuset naeste gang du snakker med en auktioaer.";
		AuctionScanNocat	= "Du skal vaelge mindst en kategori for at kan skanne.";
		AuctionScanRedo	= "Nuvaerende side tog mere end %d sekunder at faerdigoere, forsoeger at indlaese siden igen.";
		AuctionScanStart	= "Auctioneer: skanner %s side 1...";
		AuctionTotalAucts	= "Auktioner skannet ialt: %s";


		-- Section: Tooltip Messages
		FrmtInfoAlsoseen	= "Set %d gange paa %s";
		FrmtInfoAverage	= "%s min/%s BO (%s bud)";
		FrmtInfoBidMulti	= "Bud (%s%s stk.)";
		FrmtInfoBidOne	= "Bud%s";
		FrmtInfoBidrate	= "%d%% har budt, %d%% har BO";
		FrmtInfoBuymedian	= "Opkøb median";
		FrmtInfoBuyMulti	= "Opkøb (%s%s Stk)";
		FrmtInfoBuyOne	= "Opkøb%s";
		FrmtInfoForone	= "For 1: %s min/%s BO (%s bud) [i %d's]";
		FrmtInfoHeadMulti	= "Middel for %d stk.:";
		FrmtInfoHeadOne	= "Middel for denne vare:";
		FrmtInfoHistmed	= "Sidste %d, middel BO (stk)";
		FrmtInfoMinMulti	= "Start bud (%s stk.)";
		FrmtInfoMinOne	= "Start bud";
		FrmtInfoNever	= "Aldrig set paa %s";
		FrmtInfoSeen	= "Set %d gange paa auktion ialt";
		FrmtInfoSgst	= "Prisforslag: %s min/%s BO";
		FrmtInfoSgststx	= "Prisforslag for dine %d stk: %s min/%s BO";
		FrmtInfoSnapmed	= "Skannede %d, middel BO (stk)";
		FrmtInfoStacksize	= "Normal bundt stoerrelse: %d stk.";


		-- Section: User Interface
		FrmtLastSoldOn	= "Sidst solgt den";
		UiBid	= "bud";
		UiBidHeader	= "bud";
		UiBidPerHeader	= "Bud pr.";
		UiBuyout	= "Opkøb";
		UiBuyoutHeader	= "Opkøb";
		UiBuyoutPerHeader	= "Opkøb pr.";
		UiBuyoutPriceLabel	= "Opkøb bud:";
		UiBuyoutPriceTooLowError	= "(For lav)";
		UiCategoryLabel	= "kategori begrænsning:";
		UiDepositLabel	= "Depositum";
		UiDurationLabel	= "Varighed:";
		UiItemLevelHeader	= "Lvl";
		UiMakeFixedPriceLabel	= "Opret fixed pris";
		UiMaxError	= "(%d - Max)";
		UiMaximumPriceLabel	= "Maximum pris:";
		UiMaximumTimeLeftLabel	= "Maximum tid tilbage:";
		UiMinimumProfitLabel	= "Minimum profit:";
		UiMinimumQualityLabel	= "Minimum kvalitet:";
		UiMinimumUndercutLabel	= "Minimum underbyder";
		UiNameHeader	= "Navn";
		UiNoPendingBids	= "Alle bud anmodninger færdige";
		UiNotEnoughError	= "(Ikke nok)";
		UiPendingBidInProgress	= "1 bud anmodning i gang...";
		UiPendingBidsInProgress	= "%d bud anmodninger i gang.";
		UiPercentLessHeader	= "procent";
		UiPost	= "Opret";
		UiPostAuctions	= "Set auktioner";
		UiPriceBasedOnLabel	= "Pris baseret på:";
		UiPriceModelAuctioneer	= "Auctioneer Pris";
		UiPriceModelCustom	= "Personlig pris";
		UiPriceModelFixed	= "Fast pris";
		UiPriceModelLastSold	= "Sidste salgspris";
		UiProfitHeader	= "Profit";
		UiProfitPerHeader	= "Profit pr.";
		UiQuantityHeader	= "Kvalitet";
		UiQuantityLabel	= "Mængde:";
		UiRemoveSearchButton	= "Slet";
		UiSavedSearchLabel	= "Gemte søgninger:";
		UiSaveSearchButton	= "Gem";
		UiSaveSearchLabel	= "Gem denne søgning:";
		UiSearch	= "Søg";
		UiSearchAuctions	= "Søg auktioner";
		UiSearchDropDownLabel	= "Søg:";
		UiSearchForLabel	= "Søg efter genstand:";
		UiSearchTypeBids	= "Bud";
		UiSearchTypeBuyouts	= "køb";
		UiSearchTypeCompetition	= "Konkurrence";
		UiSearchTypePlain	= "Genstand";
		UiStacksLabel	= "Stakke";
		UiStackTooBigError	= "(Stak for stor)";
		UiStackTooSmallError	= "(Stak for lille)";
		UiStartingPriceLabel	= "Start pris:";
		UiStartingPriceRequiredError	= "(nødvendig)";
		UiTimeLeftHeader	= "Tid tilbage";
		UiUnknownError	= "(ukendt fejl)";

	};

	deDE = {


		-- Section: AskPrice Messages
		AskPriceAd	= "Stapelpreis mit %sx[ItemLink] (x = Stapelgröße)";
		FrmtAskPriceBuyoutMedianHistorical	= "%sSofortkauf Median: %s%s";
		FrmtAskPriceBuyoutMedianSnapshot	= "%sSofortkauf Median letzter Scan: %s%s";
		FrmtAskPriceDisable	= "Preisabfrage %s Option ausgeschaltet";
		FrmtAskPriceEach	= "(%s pro Stück)";
		FrmtAskPriceEnable	= "Preisabfrage %s Option eingeschaltet";
		FrmtAskPriceVendorPrice	= "%sVerkauf an NPC für: %s%s";


		-- Section: Auction Messages
		FrmtActRemove	= "Entferne Auktion %s vom derzeitigen AH-Abbild.";
		FrmtAuctinfoHist	= "%d historisch";
		FrmtAuctinfoLow	= "niedrigster Preis";
		FrmtAuctinfoMktprice	= "Marktpreis";
		FrmtAuctinfoNolow	= "Item nicht im letzten AH-Abbild enthalten";
		FrmtAuctinfoOrig	= "Originalgebot";
		FrmtAuctinfoSnap	= "%d aus letztem Scan";
		FrmtAuctinfoSugbid	= "Anfangsgebot";
		FrmtAuctinfoSugbuy	= "Empf. Sofortkauf";
		FrmtWarnAbovemkt	= "Konkurrenz keine Gefahr";
		FrmtWarnMarkup	= "%s%% erhöhter Händlerpreis";
		FrmtWarnMyprice	= "Verwende eigenen Preis";
		FrmtWarnNocomp	= "Monopol";
		FrmtWarnNodata	= "Keine HVP-Daten";
		FrmtWarnToolow	= "Konkurrenz zu günstig";
		FrmtWarnUndercut	= "Unterbiete um %s%%";
		FrmtWarnUser	= "Verwende Benutzer-Preisvorgabe";


		-- Section: Bid Messages
		FrmtAlreadyHighBidder	= "Bereits Höchstbietender für Auktion: %s (x%d)";
		FrmtBidAuction	= "Gebot für Auktion: %s (x%d) ";
		FrmtBidQueueOutOfSync	= "Fehler: Gebotsliste nicht synchron!";
		FrmtBoughtAuction	= "Direktkauf der Auktion: %s (x%d) ";
		FrmtMaxBidsReached	= "Mehr Auktionen von %s (x%d)gefunden, aber Gebotsbegrenzung erreicht (%d) ";
		FrmtNoAuctionsFound	= "Keine Auktionen gefunden: %s (x%d) ";
		FrmtNoMoreAuctionsFound	= "Keine weiteren Auktionen gefunden: %s (x%d) ";
		FrmtNotEnoughMoney	= "Nicht genug Geld für Gebot auf Auktion: %s (x%d) ";
		FrmtSkippedAuctionWithHigherBid	= "Überspringe Auktion mit höherem Gebot: %s (x%d) ";
		FrmtSkippedAuctionWithLowerBid	= "Überspringe Auktion mit niedrigerem Gebot: %s (x%d)";
		FrmtSkippedBiddingOnOwnAuction	= "Überspringe Gebot auf eigene Auktion: %s (x%d)";
		UiProcessingBidRequests	= "Bearbeite Gebote...";


		-- Section: Command Messages
		ConstantsCritical	= "KRITISCH: Deine gespeicherten Auctioneer Daten sind zu %.3f%% voll!";
		ConstantsMessage	= "Deine gespeicherten Auctioneer Daten sind zu %.3f%% voll";
		ConstantsWarning	= "WARNUNG: Deine gespeicherten Auctioneer Daten sind zu %.3f%% voll";
		FrmtActClearall	= "Lösche alle Auktionsdaten für %s";
		FrmtActClearFail	= "Objekt nicht gefunden: %s";
		FrmtActClearOk	= "Daten gelöscht für: %s";
		FrmtActClearsnap	= "Lösche aktuelles Auktionshaus-Abbild.";
		FrmtActDefault	= "%s wurde auf den Standardwert zurückgesetzt.";
		FrmtActDefaultall	= "Alle Einstellungen wurden auf Standardwerte zurückgesetzt.";
		FrmtActDisable	= "%s wird nicht angezeigt";
		FrmtActEnable	= "%s wird angezeigt";
		FrmtActSet	= "Setze %s auf '%s'";
		FrmtActUnknown	= "Unbekannter Befehl: '%s'";
		FrmtAuctionDuration	= "Standard-Auktionsdauer wurde auf \"%s\" gesetzt";
		FrmtAutostart	= "Automatischer Start der Auktion für %s:\n%s Minimum, %s Sofortkauf (%dh)\n%s";
		FrmtFinish	= "Nach abgeschlossenem Scan werden wir %s";
		FrmtPrintin	= "Die Auctioneer-Meldungen werden nun im Chat-Fenster \"%s\" angezeigt";
		FrmtProtectWindow	= "Schutzmodus des Auktionshaus-Fensters auf \"%s\" gesetzt";
		FrmtUnknownArg	= "'%s' ist kein gültiges Argument für '%s'";
		FrmtUnknownLocale	= "Das angegebene Gebietsschema ('%s') ist unbekannt. Gültige Gebietsschemen sind:";
		FrmtUnknownRf	= "Ungültiger Parameter ('%s'). Der Parameter erfordert das Format: [Realm]-[Fraktion]. Bspw.: Al'Akir-Horde";


		-- Section: Command Options
		OptAlso	= "([Realm]-[Fraktion]|opposite|home|neutral)";
		OptAskPriceSend	= "(<Spielername> <Preisnachfrage-Ergebnis>)";
		OptAuctionDuration	= "(last|2h|8h|24h)";
		OptBidbroker	= "<Profit in Silber>";
		OptBidLimit	= "<Nummer> ";
		OptBroker	= "<Profit in Silber>";
		OptClear	= "([Gegenstand]|all|snapshot)";
		OptCompete	= "<silber_weniger>";
		OptDefault	= "(<Option>|all)";
		OptFinish	= "(off|logout|exit|reloadui)";
		OptLocale	= "<Sprache>";
		OptPctBidmarkdown	= "<Prozent>";
		OptPctMarkup	= "<Prozent>";
		OptPctMaxless	= "<Prozent>";
		OptPctNocomp	= "<Prozent>";
		OptPctUnderlow	= "<Prozent>";
		OptPctUndermkt	= "<Prozent>";
		OptPercentless	= "<Prozent>";
		OptPrintin	= "(<Fenster-Index>[Nummer]|<Fenster-Name>[String])";
		OptProtectWindow	= "(never|scan|always)";
		OptScale	= "<Skalierungsfaktor>";
		OptScan	= "Befehlsformat der Scanparameter";


		-- Section: Commands
		CmdAlso	= "also";
		CmdAlsoOpposite	= "opposite";
		CmdAlt	= "alt";
		CmdAskPriceAd	= "ad";
		CmdAskPriceGuild	= "guild";
		CmdAskPriceParty	= "party";
		CmdAskPriceSend	= "send";
		CmdAskPriceSmart	= "smart";
		CmdAskPriceSmartWord1	= "what";
		CmdAskPriceSmartWord2	= "worth";
		CmdAskPriceTrigger	= "trigger";
		CmdAskPriceVendor	= "vendor";
		CmdAskPriceWhispers	= "whispers";
		CmdAskPriceWord	= "word";
		CmdAuctionClick	= "auction-click";
		CmdAuctionDuration	= "auction-duration";
		CmdAuctionDuration0	= "last";
		CmdAuctionDuration1	= "2h";
		CmdAuctionDuration2	= "8h";
		CmdAuctionDuration3	= "24h";
		CmdAutofill	= "autofill";
		CmdBidbroker	= "bidbroker";
		CmdBidbrokerShort	= "bb";
		CmdBidLimit	= "bid-limit";
		CmdBroker	= "broker";
		CmdClear	= "clear";
		CmdClearAll	= "all";
		CmdClearSnapshot	= "snapshot";
		CmdCompete	= "compete";
		CmdCtrl	= "strg";
		CmdDefault	= "default";
		CmdDisable	= "disable";
		CmdEmbed	= "embed";
		CmdFinish	= "finish";
		CmdFinish0	= "off";
		CmdFinish1	= "logout";
		CmdFinish2	= "exit";
		CmdFinish3	= "reloadui";
		CmdFinishSound	= "finish-sound";
		CmdHelp	= "help";
		CmdLocale	= "locale";
		CmdOff	= "off";
		CmdOn	= "on";
		CmdPctBidmarkdown	= "pct-bidmarkdown";
		CmdPctMarkup	= "pct-markup";
		CmdPctMaxless	= "pct-maxless";
		CmdPctNocomp	= "pct-nocomp";
		CmdPctUnderlow	= "pct-underlow";
		CmdPctUndermkt	= "pct-undermkt";
		CmdPercentless	= "percentless";
		CmdPercentlessShort	= "pl";
		CmdPrintin	= "print-in";
		CmdProtectWindow	= "protect-window";
		CmdProtectWindow0	= "never";
		CmdProtectWindow1	= "scan";
		CmdProtectWindow2	= "always";
		CmdScan	= "scan";
		CmdShift	= "shift";
		CmdToggle	= "toggle";
		CmdUpdatePrice	= "update-price";
		CmdWarnColor	= "warn-color";
		ShowAverage	= "show-average";
		ShowEmbedBlank	= "show-embed-blankline";
		ShowLink	= "show-link";
		ShowMedian	= "show-median";
		ShowRedo	= "show-warning";
		ShowStats	= "show-stats";
		ShowSuggest	= "show-suggest";
		ShowVerbose	= "show-verbose";


		-- Section: Config Text
		GuiAlso	= "Zeige zusätzlich Daten von";
		GuiAlsoDisplay	= "Zeige Daten für %s an";
		GuiAlsoOff	= "Daten für andere Realm-Fraktion werden nicht mehr angezeigt.";
		GuiAlsoOpposite	= "Daten der gegnerischen Fraktion werden jetzt ebenfalls angezeigt.";
		GuiAskPrice	= "AskPrice einschalten";
		GuiAskPriceAd	= "Sende feature Werbung";
		GuiAskPriceGuild	= "Reagiere auf Gildenchat-Anfragen";
		GuiAskPriceHeader	= "AskPrice Optionen";
		GuiAskPriceHeaderHelp	= "Ändere AskPrice Verhalten";
		GuiAskPriceParty	= "Reagiere auf Gruppenchat-Anfragen";
		GuiAskPriceSmart	= "Benutze Schlagwörter";
		GuiAskPriceTrigger	= "AskPrice Auslöser";
		GuiAskPriceVendor	= "Sende Händler Info";
		GuiAskPriceWhispers	= "Ausgehende Whispers anzeigen";
		GuiAskPriceWord	= "Eigenes SmartWord %d";
		GuiAuctionDuration	= "Auktionsstandarddauer";
		GuiAuctionHouseHeader	= "Auktionshausfenster";
		GuiAuctionHouseHeaderHelp	= "Verhalten des Auktionshausfensters ändern";
		GuiAutofill	= "Preise im AH automatisch eintragen";
		GuiAverages	= "Durchschnitt anzeigen";
		GuiBidmarkdown	= "Gebot um %x unterbieten";
		GuiClearall	= "Lösche alle Auctioneerdaten";
		GuiClearallButton	= "Alles löschen";
		GuiClearallHelp	= "Hier drücken, um die gesamten Auctioneerdaten des aktuellen Realms zu löschen.";
		GuiClearallNote	= "der aktuellen Fraktion dieses Realms";
		GuiClearHeader	= "Daten löschen";
		GuiClearHelp	= "Auctioneerdaten löschen.\nWähle entweder alle Daten oder das aktuelle Abbild.\nWARNUNG: Der Löschvorgang kann NICHT rückgängig gemacht werden!";
		GuiClearsnap	= "Abbilddaten löschen";
		GuiClearsnapButton	= "Abbild löschen";
		GuiClearsnapHelp	= "Zum Löschen der letzten Auctioneer-Abbild-Daten, hier klicken.";
		GuiDefaultAll	= "Alle Einstellungen zurücksetzen";
		GuiDefaultAllButton	= "Alles zurücksetzen";
		GuiDefaultAllHelp	= "Hier klicken, um alle Auctioneer-Optionen auf ihren Standardwert zu setzen.\nWARNUNG: Dieser Vorgang kann NICHT rückgängig gemacht werden.";
		GuiDefaultOption	= "Zurücksetzen dieser Einstellung";
		GuiEmbed	= "Info im In-Game Tooltipp anzeigen";
		GuiEmbedBlankline	= "Leerzeile im In-Game Tooltipp einfügen";
		GuiEmbedHeader	= "Art der Anzeige";
		GuiFinish	= "Nach abgeschlossenem Scan";
		GuiFinishSound	= "Spiele Ton ab nach Beenden des Scans";
		GuiLink	= "Zeige LinkID an";
		GuiLoad	= "Auctioneer laden";
		GuiLoad_Always	= "immer";
		GuiLoad_AuctionHouse	= "im Auktionshaus";
		GuiLoad_Never	= "nie";
		GuiLocale	= "Setze das Gebietsschema auf";
		GuiMainEnable	= "Auctioneer aktivieren";
		GuiMainHelp	= "Einstellungen für Auctioneer.\nEinem AddOn, das zusätzliche Informationen zu Gegenständen anzeigt und Auktionsdaten analysiert.\nDrücke den \"Scannen\"-Knopf im Auktionshaus, um Auktionsdaten zu sammeln.";
		GuiMarkup	= "Händlerpreis um x% erhöhen";
		GuiMaxless	= "Marktpreis um max. x% unterbieten";
		GuiMedian	= "Zeige Mediane an.";
		GuiNocomp	= "Marktpreis um x% bei Monopol\nverringern";
		GuiNoWorldMap	= "Auctioneer: Die Anzeige der Weltkarte wurde unterdrückt";
		GuiOtherHeader	= "Sonstige Einstellungen";
		GuiOtherHelp	= "Sonstige Auctioneer-Einstellungen";
		GuiPercentsHeader	= "Auctioneer Prozent-Schwellenwerte";
		GuiPercentsHelp	= "WARNUNG: Die folgenden Einstellungen sind NUR für erfahrene Benutzer.\nVerändere die folgenden Werte um festzulegen, wie aggressiv Auctioneer beim Bestimmen profitabler Preise vorgehen soll.";
		GuiPrintin	= "Fenster für Meldungen auswählen";
		GuiProtectWindow	= "Versehentliches Schließen des AH-Fensters verhindern";
		GuiRedo	= "Zeige Warnung bei langer Scandauer";
		GuiReloadui	= "Benutzeroberfläche neu laden";
		GuiReloaduiButton	= "Interface neu laden";
		GuiReloaduiFeedback	= "WoW-Benutzeroberfläche wird neu geladen";
		GuiReloaduiHelp	= "Hier klicken, um die WoW-Benutzeroberfläche nach einer \nÄnderung des Gebietsschemas neu zu laden, so dass die Sprache des Konfigurationsmenüs diesem entspricht.\nHinweis: Dieser Vorgang kann einige Minuten dauern.";
		GuiRememberText	= "Preis merken";
		GuiStatsEnable	= "Statistiken anzeigen";
		GuiStatsHeader	= "Preisstatistiken";
		GuiStatsHelp	= "Zeigt die folgenden Statistiken im Tooltip an.";
		GuiSuggest	= "Zeige empfohlene Preise an.";
		GuiUnderlow	= "Günstigste Auktion unterbieten";
		GuiUndermkt	= "Marktpreis unterbieten, wenn\nKonkurrenz zu günstig ist";
		GuiVerbose	= "Detaillierte Informationen";
		GuiWarnColor	= "Farbiges Preismodell";


		-- Section: Conversion Messages
		MesgConvert	= "Auctioneer Datenbankkonvertierung. Bitte zuerst eine Sicherung von SavedVariables\\Auctioneer.lua anlegen!%s%s";
		MesgConvertNo	= "Deaktivieren";
		MesgConvertYes	= "Konvertieren";
		MesgNotconverting	= "Auctioneer konvertiert die Datenbank nicht, bleibt aber außer Funktion, bis dies erfolgt.";


		-- Section: Game Constants
		SubTypeBag	= "Behälter";
		TimeLong	= "Lang";
		TimeMed	= "Mittel";
		TimeShort	= "Kurz";
		TimeVlong	= "Sehr lang";


		-- Section: Generic Messages
		ConfirmBidBuyout	= "Auktionskauf f\195\188r:";
		DisableMsg	= "Das automatische Laden von Auctioneer wird deaktiviert.";
		FrmtWelcome	= "Auctioneer v%s geladen.";
		MesgNotLoaded	= "Auctioneer ist nicht geladen. Gib /auctioneer für mehr Informationen ein.";
		ScanCancel	= "Scan abgebrochen";
		ScanComplete	= "Scan komplett";
		ScanFailed	= "Scan fehlgeschlagen";
		StatAskPriceOff	= "Preisnachfrage deaktiviert.";
		StatAskPriceOn	= "Preisnachfrage aktiviert.";
		StatOff	= "Auktionsdaten werden nicht angezeigt.";
		StatOn	= "Auktionsdaten werden angezeigt.";
		UIScanCanceled	= "Auctioneer: Auktionenscan abgebrochen";
		UIScanComplete	= "Auctioneer: Auktionenscan abgeschlossen";
		UIScanFailed	= "Auctioneer: Auktionenscan fehlgeschlagen";


		-- Section: Generic Strings
		TextCombat	= "Kampflog";
		TextGeneral	= "Allgemein";
		TextNone	= "nichts";
		TextScan	= "Scannen";
		TextUsage	= "Syntax:";


		-- Section: Help Text
		HelpAlso	= "Zeigt ebenfalls die Werte anderer Server im Tooltip an. Setze den Namen des Realms für Realm und den Namen der Fraktion für Fraktion ein. Zum Beispiel: \"/auctioneer auch Kil'Jaeden-Alliance\". Das spezielle Schlüsselwort \"Gegenseite\" bezeichnet die gegnerische Fraktion, \"aus\" deaktiviert die Funktionalität.";
		HelpAskPrice	= "Preisnachfrage ein-/ausschalten.";
		HelpAskPriceAd	= "Anzeige der neuen Preisnachfrage-Eigenschaften ein-/ausschalten.";
		HelpAskPriceGuild	= "Auf Gildenchat-Anfragen reagieren.";
		HelpAskPriceParty	= "Auf Gruppenchat-Anfragen reagieren.";
		HelpAskPriceSend	= "Einem Spieler manuell das Ergebnis einer Preisnachfrage senden.";
		HelpAskPriceSmart	= "Schlagwortcheck ein-/ausschalten.";
		HelpAskPriceTrigger	= "Ändere AskPrice Auslöser.";
		HelpAskPriceVendor	= "Anzeige von Händlerinformationen ein-/ausschalten.";
		HelpAskPriceWhispers	= "Aktiviere oder deaktiviere das Verbergen von allen von AskPrice abgehenden geflüsterten Meldungen.";
		HelpAskPriceWord	= "Hinzufügen bzw. modifizieren von eigenen AskPrice SmartWords.";
		HelpAuctionClick	= "Mittels Alt-Klick auf einen Gegenstand in einer Tasche wird automatisch eine Auktion dafür erstellt.";
		HelpAuctionDuration	= "Setzt die Standard-Auktionsdauer beim Öffnen des Auktionshausfensters";
		HelpAutofill	= "Festlegen, ob die Preise automatisch ausgefüllt werden sollen, wenn ein Gegenstand in das Auktionshaus gelegt wird.";
		HelpAverage	= "Festlegen, ob der durchschnittliche Auktionspreis angezeigt wird.";
		HelpBidbroker	= "Zeigt vom letzten Abbild alle Auktionen mit kurzer oder mittlerer Laufzeit an, auf die für Profit geboten werden könnte.";
		HelpBidLimit	= "Maximum Auktionen auf die geboten werden soll oder Sofortkauf wenn der Gebots- oder Sofortkaufbutton geklickt wurde, während eine Suchaktion läuft.";
		HelpBroker	= "Zeigt alle Auktionen vom letzten Abbild an, auf die geboten und die mit Gewinn wieder verkauft werden könnten.";
		HelpClear	= "Löscht die Daten der angegebenen Gegenstände (Gegenstände müssen dem Befehl mittels Shift + Klick hinzugefügt werden). Es können auch die speziellen Schlüsselworte \"alle\" und \"Abbild\" hinzugefügt werden.";
		HelpCompete	= "Zeigt alle Auktionen des letzten Scans an, deren Sofortkaufpreis geringer ist als der eines eigenen im AH angebotenen Gegenstandes.";
		HelpDefault	= "Setzt eine Auctioneer-Einstellung auf ihren Standardwert zurück. Mit dem Schlüsselwort \"alle\" werden alle Auctioneer-Einstellungen zurückgesetzt.";
		HelpDisable	= "Stoppt den Autostart von Auctioneer ab dem nächsten Einloggen.";
		HelpEmbed	= "Bettet den Auktionsinfotext in den WoW-Tooltip ein (Hinweis: Einige Funktionen sind in diesem Modus deaktiviert)";
		HelpEmbedBlank	= "Schaltet die Anzeige einer Leerzeile zwischen der Tooltipinfo und der Auktionsinfo im Einbettungsmodus ein/aus.";
		HelpFinish	= "Wähle zwischen automatischem Ausloggen oder Beenden des Spieles nach abgeschlossenem Scan";
		HelpFinishSound	= "Legt fest, ob nach Beenden eines Scans ein Ton abgespielt werden soll.";
		HelpLink	= "Schaltet die Anzeige der Link-ID im Tooltip ein/aus.";
		HelpLoad	= "Ladeverhalten von Auctioneer für diesen Charakter ändern";
		HelpLocale	= "Ändern des Gebietsschemas das zur Anzeige \nvon Auctioneer-Meldungen verwendet wird";
		HelpMedian	= "Schaltet die Anzeige des Median-Sofortkaufpreises ein/aus";
		HelpOnoff	= "Schaltet die Anzeige der Auktionsdaten ein/aus";
		HelpPctBidmarkdown	= "Legt den Prozentsatz fest, um den das Mindestgebot niedriger als der Sofortkaufpreis ist.";
		HelpPctMarkup	= "Legt den Prozentsatz für erhöhte Händlerpreise fest, der verwendet wird, falls sonst keine anderen Werte verfügbar sind.";
		HelpPctMaxless	= "Legt den maximalen Prozentsatz fest, um den Auctioneer den Marktpreis höchstens unterschreiten darf.";
		HelpPctNocomp	= "Legt den Prozentsatz fest, um den der Marktpreis bei Monopol unterboten wird.";
		HelpPctUnderlow	= "Legt den Prozentsatz fest, um den das günstigste konkurrierende Angebot unterboten wird.";
		HelpPctUndermkt	= "Legt den Prozentsatz fest, um den der Marktpreis unterboten wird, wenn durch den gewählten Prozentsatz für maxless ein konkurrierendes Angebot nicht unterboten werden kann.";
		HelpPercentless	= "Zeigt alle Auktionen des letzten Abbilds an, deren Sofortkaufpreis einen gewissen Prozentsatz unter dem höchstmöglichen Verkaufspreis liegt.";
		HelpPrintin	= "Auswählen in welchem Fenster die Auctioneer-Meldungen angezeigt werden. Es kann entweder der Fensterindex oder der Fenstername angegeben werden.";
		HelpProtectWindow	= "Verhindert das versehentliche Schließen des Auktionshaus-Fensters.";
		HelpRedo	= "Legt fest, ob eine Warnung angezeigt wird, wenn das Scannen der aktuellen Seite im Auktionshaus wegen Serverlag zu lange dauert.";
		HelpScan	= "Führt einen Scan des Auktionshauses beim nächsten Besuch durch bzw. sofort, wenn man schon dort ist (es gibt ebenfalls einen Knopf im Auktionshausfenster). Über die Auswahlboxen können die zu scannenden Kategorien gewählt werden.";
		HelpStats	= "Schaltet die Prozentanzeige vom Gebot/Sofortkauf ein/aus.";
		HelpSuggest	= "Schaltet die Anzeige des empfohlenen Auktionspreises ein/aus.";
		HelpUpdatePrice	= "Aktualisiert automatisch das Startgebot für eine Auktion auf der Auktionserstellungsseite wenn sich der Sofortkaufpreis ändert.";
		HelpVerbose	= "Legt fest, ob Durchschnittswerte und Preisempfehlungen ausführlich angezeigt werden (Ausschalten für Anzeige in einzelner Zeile)";
		HelpWarnColor	= "Festlegen, ob das aktuelle AH-Preismodell (Unterbiete um ...) mit intuitiven Farben angezeigt wird.";


		-- Section: Post Messages
		FrmtNoEmptyPackSpace	= "Keinen leeren Taschenplatz gefunden, um die Auktion zu erstellen!";
		FrmtNotEnoughOfItem	= "Nicht genug %s gefunden, um die Auktion zu erstellen!";
		FrmtPostedAuction	= "Es wurde 1 Auktion mit %s (x%d) erstellt.";
		FrmtPostedAuctions	= "Es wurden %d Auktionen mit %s (x%d) erstellt.";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "aktGebot";
		FrmtBidbrokerDone	= "Gebotsmakeln fertig";
		FrmtBidbrokerHeader	= "Mindestprofit: %s, HVP = 'Höchster Verkaufspreis'";
		FrmtBidbrokerLine	= "%s, zuletzt %s gesehen, HVP: %s, %s: %s, Profit: %s, Restzeit: %s";
		FrmtBidbrokerMinbid	= "niedrGebot";
		FrmtBrokerDone	= "Makeln beendet";
		FrmtBrokerHeader	= "Mindestprofit: %s, HVP = 'Höchster Verkaufspreis'";
		FrmtBrokerLine	= "%s, zuletzt %s gesehen, HVP: %s, Sofortkauf: %s, Profit: %s";
		FrmtCompeteDone	= "Konkurrierende Auktionen abgeschlossen.";
		FrmtCompeteHeader	= "Konkurrierende Auktionen mindestens %s billiger pro Stück.";
		FrmtCompeteLine	= "%s, Gebot: %s, Sofortkauf %s gg. %s, %s billiger";
		FrmtHspLine	= "Höchster Verkaufspreis pro %s ist: %s";
		FrmtLowLine	= "%s, Sofortkauf: %s, Verkäufer: %s, %s/Stück, %s unter dem Median";
		FrmtMedianLine	= "Aus %d ist der Median-Sofortkaufpreis für 1 %s: %s";
		FrmtNoauct	= "Keine Aktionen für %s gefunden.";
		FrmtPctlessDone	= "Prozent unter HVP beendet.";
		FrmtPctlessHeader	= "Prozent billiger als der höchste Verkaufspreis (HVP): %d%%";
		FrmtPctlessLine	= "%s, zuletzt %d gesehen, HVP: %s, Sofortkauf: %s, Profit: %s, Billiger %s";


		-- Section: Scanning Messages
		AuctionDefunctAucts	= "Abgelaufene Auktionen: %s";
		AuctionDiscrepancies	= "Unstimmigkeiten: %s";
		AuctionNewAucts	= "Davon neu: %s";
		AuctionPageN	= "Auctioneer: Erfasse \"%s\", Seite %d von %d\nAuktionen pro Sekunde: %s\nGeschätzte Restzeit: %s";
		AuctionScanAll	= "Scanne alle Auktionen.";
		AuctionScanAuctions	= "Scanne Auktionen.";
		AuctionScanCat	= "Scanne alle Auktionen fuer: %s.";
		AuctionScanDone	= "Auctioneer: Scan abgeschlossen";
		AuctionScanNexttime	= "Auctioneer wird einen vollständigen Auktionsscan durchführen, wenn das nächste Mal ein Auktionator angesprochen wird.";
		AuctionScanNocat	= "Zum Scannen muss mindestens eine Kategorie ausgewählt sein.";
		AuctionScanRedo	= "Das Erfassen der aktuelle Seite benötigte mehr als %d Sekunden, erneuter Versuch.";
		AuctionScanStart	= "Auctioneer: %s Seite 1...";
		AuctionTotalAucts	= "Insgesamt gescannte Auktionen: %s";
		AuctionUpdatedAucts	= "Upgedatete/Geänderte Auktionen: %s";


		-- Section: Tooltip Messages
		FrmtInfoAlsoseen	= "%d mal für %s gesehen";
		FrmtInfoAverage	= "%s min/%s Sofortkauf (%s geboten)";
		FrmtInfoBidMulti	= "Geboten (%s%s pro Stück)";
		FrmtInfoBidOne	= "Geboten %s";
		FrmtInfoBidrate	= "%d%% mit Gebot, %d%% mit Sofortkauf";
		FrmtInfoBuymedian	= "Sofortkaufsmedian";
		FrmtInfoBuyMulti	= "Sofortkauf (%s%s pro Stück)";
		FrmtInfoBuyOne	= "Sofortkauf %s";
		FrmtInfoForone	= "Pro Stück: %s min/%s Sofortkauf (%s geboten) [in %d]";
		FrmtInfoHeadMulti	= "Durchschnitt für %d Stück:";
		FrmtInfoHeadOne	= "Durchschnitt für dieses Objekt:";
		FrmtInfoHistmed	= "Sofortkaufmedian (pro Stück) der %d letzten Auktionen:";
		FrmtInfoMinMulti	= "Startgebot (%s pro Stück)";
		FrmtInfoMinOne	= "Startgebot";
		FrmtInfoNever	= "Noch nie in %s gesehen";
		FrmtInfoNeverAtAll	= "Noch nie im AH gesehn.";
		FrmtInfoSeen	= "Insgesamt %d mal in Auktionen gesehen";
		FrmtInfoSgst	= "Empfohlener Preis: %s min/%s Sofortkauf";
		FrmtInfoSgststx	= "Empfohlener Preis für diesen %der Stapel: %s min/%s Sofortkauf (%s/%s pro Stück)";
		FrmtInfoSnapmed	= "Sofortkaufsmedian (pro Stück) aus %d gescannten Auktionen:";
		FrmtInfoStacksize	= "Durchschnittliche Stapelgröße: %d Stück";


		-- Section: User Interface
		BuySortTooltip	= "Ergebnisseite nach Verkaufspreis sortieren (drücke SHIFT um nach Itemnamen zu sortieren)";
		ClearTooltip	= "Eingaben im Suchfeld löschen";
		FrmtLastSoldOn	= "Zuletzt verkauft für %s";
		RefreshTooltip	= "Suchanfrage der aktuellen Seite wiederholen";
		UiBid	= "Gebot";
		UiBidHeader	= "Gebot";
		UiBidPerHeader	= "Gebot pro";
		UiBuyout	= "Sofortkauf";
		UiBuyoutHeader	= "Sofortkauf";
		UiBuyoutPerHeader	= "Sofortkauf pro";
		UiBuyoutPriceLabel	= "Sofortkaufpreis:";
		UiBuyoutPriceTooLowError	= "(zu niedrig)";
		UiCategoryLabel	= "Kategoriebeschränkung:";
		UiDepositLabel	= "Anzahlung:";
		UiDurationLabel	= "Dauer:";
		UiItemLevelHeader	= "Stufe";
		UiMakeFixedPriceLabel	= "Als Festpreis setzen";
		UiMaxError	= "(%d Max)";
		UiMaximumPriceLabel	= "Maximaler Preis:";
		UiMaximumTimeLeftLabel	= "Maximale Restzeit:";
		UiMinimumBidPercentLabel	= "Mindestgebot %";
		UiMinimumPercentLessShortLabel	= "Mindestens % weniger:";
		UiMinimumProfitLabel	= "Mindestgewinn:";
		UiMinimumQualityLabel	= "Mindestqualität:";
		UiMinimumUndercutLabel	= "Unterbieten um:";
		UiNameHeader	= "Name";
		UiNoPendingBids	= "Alle Gebotsanfragen komplett!";
		UiNotEnoughError	= "(nicht genug)";
		UiPendingBidInProgress	= "1 Gebotsanfrage in Bearbeitung...";
		UiPendingBidsInProgress	= "%d Gebotsanfragen in Bearbeitung...";
		UiPercentLessHeader	= "%";
		UiPost	= "Erstellen";
		UiPostAuctions	= "Erstelle Auktionen";
		UiPriceBasedOnLabel	= "Preis basiert auf:";
		UiPriceModelAuctioneer	= "Auctioneer-Preis";
		UiPriceModelCustom	= "Benutzerdef. Preis";
		UiPriceModelFixed	= "Festpreis";
		UiPriceModelLastSold	= "Zuletzt verkauft für";
		UiProfitHeader	= "Gewinn";
		UiProfitPerHeader	= "Gewinn pro";
		UiQuantityHeader	= "Anz.";
		UiQuantityLabel	= "Anzahl:";
		UiRemoveSearchButton	= "Löschen";
		UiSavedSearchLabel	= "Gespeicherte Suchen:";
		UiSaveSearchButton	= "Speichern";
		UiSaveSearchLabel	= "Suche speichern:";
		UiSearch	= "Suche";
		UiSearchAuctions	= "Durchsuche Auktionen";
		UiSearchDropDownLabel	= "Suche:";
		UiSearchForLabel	= "Gegenstand suchen:";
		UiSearchForOwnerLabel	= "Suche nach Items von:";
		UiSearchTypeBids	= "Gebote";
		UiSearchTypeBuyouts	= "Sofortkäufe";
		UiSearchTypeCompetition	= "Konkurrenz";
		UiSearchTypeOwner	= "Verkäufer";
		UiSearchTypePlain	= "Gegenstand";
		UiStacksLabel	= "Stapel";
		UiStackTooBigError	= "(Stapel zu groß)";
		UiStackTooSmallError	= "(Stapel zu klein)";
		UiStartingPriceLabel	= "Startpreis:";
		UiStartingPriceRequiredError	= "(erforderlich)";
		UiTimeLeftHeader	= "Restzeit";
		UiUnknownError	= "(Unbekannt)";

	};

	enUS = {


		-- Section: AskPrice Messages
		AskPriceAd	= "Get stack prices with %sx[ItemLink] (x = stacksize)";
		FrmtAskPriceBuyoutMedianHistorical	= "%sBuyout-median historical: %s%s";
		FrmtAskPriceBuyoutMedianSnapshot	= "%sBuyout-median last scan: %s%s";
		FrmtAskPriceDisable	= "Disabling AskPrice's %s option";
		FrmtAskPriceEach	= "(%s each)";
		FrmtAskPriceEnable	= "Enabling AskPrice's %s option";
		FrmtAskPriceVendorPrice	= "%sSell to vendor for: %s%s";


		-- Section: Auction Messages
		FrmtActRemove	= "Removing auction signature %s from current AH snapshot.";
		FrmtAuctinfoHist	= "%d historical";
		FrmtAuctinfoLow	= "Snapshot Low";
		FrmtAuctinfoMktprice	= "Market price";
		FrmtAuctinfoNolow	= "Item not seen last snapshot";
		FrmtAuctinfoOrig	= "Original Bid";
		FrmtAuctinfoSnap	= "%d last scan";
		FrmtAuctinfoSugbid	= "Starting bid";
		FrmtAuctinfoSugbuy	= "Suggested buyout";
		FrmtWarnAbovemkt	= "Competition above market";
		FrmtWarnMarkup	= "Marking up vendor by %s%%";
		FrmtWarnMyprice	= "Using my current price";
		FrmtWarnNocomp	= "No competition";
		FrmtWarnNodata	= "No data for HSP";
		FrmtWarnToolow	= "Cannot match lowest price";
		FrmtWarnUndercut	= "Undercutting by %s%%";
		FrmtWarnUser	= "Using user pricing";


		-- Section: Bid Messages
		FrmtAlreadyHighBidder	= "Already the high bidder on auction: %s (x%d)";
		FrmtBidAuction	= "Bid on auction: %s (x%d)";
		FrmtBidQueueOutOfSync	= "Error: Bid queue out of sync!";
		FrmtBoughtAuction	= "Bought out auction: %s (x%d)";
		FrmtMaxBidsReached	= "More auctions of %s (x%d) found, but bid limit reached (%d)";
		FrmtNoAuctionsFound	= "No auctions found: %s (x%d)";
		FrmtNoMoreAuctionsFound	= "No more auctions found: %s (x%d)";
		FrmtNotEnoughMoney	= "Not enough money to bid on auction: %s (x%d)";
		FrmtSkippedAuctionWithHigherBid	= "Skipped auction with higher bid: %s (x%d)";
		FrmtSkippedAuctionWithLowerBid	= "Skipped auction with lower bid: %s (x%d)";
		FrmtSkippedBiddingOnOwnAuction	= "Skipped bidding on own auction: %s (x%d)";
		UiProcessingBidRequests	= "Processing bid requests...";


		-- Section: Command Messages
		ConstantsCritical	= "CRITICAL: Your Auctioneer SavedVariables file is %.3f%% Full!";
		ConstantsMessage	= "Your Auctioneer SavedVariables file is %.3f%% Full";
		ConstantsWarning	= "WARNING: Your Auctioneer SavedVariables file is %.3f%% Full";
		FrmtActClearall	= "Clearing all auction data for %s";
		FrmtActClearFail	= "Unable to find item: %s";
		FrmtActClearOk	= "Cleared data for item: %s";
		FrmtActClearsnap	= "Clearing current Auction House snapshot.";
		FrmtActDefault	= "Auctioneer's %s option has been reset to its default setting";
		FrmtActDefaultall	= "All Auctioneer options have been reset to default settings.";
		FrmtActDisable	= "Not displaying item's %s data";
		FrmtActEnable	= "Displaying item's %s data";
		FrmtActSet	= "Set %s to '%s'";
		FrmtActUnknown	= "Unknown command or keyword: '%s'";
		FrmtAuctionDuration	= "Default action duration set to: %s";
		FrmtAutostart	= "Automatically starting auction for %s: %s minimum, %s buyout (%dh)\n%s";
		FrmtFinish	= "After a scan has finished, we will %s";
		FrmtPrintin	= "Auctioneer's messages will now print on the \"%s\" chat frame";
		FrmtProtectWindow	= "Auction House window protection set to: %s";
		FrmtUnknownArg	= "'%s' is no valid argument for '%s'";
		FrmtUnknownLocale	= "The locale you specified ('%s') is unknown. Valid locales are:";
		FrmtUnknownRf	= "Invalid parameter ('%s'). The parameter must be formated like: [realm]-[faction]. For example: Al'Akir-Horde";


		-- Section: Command Options
		OptAlso	= "(realm-faction||opposite||home||neutral)";
		OptAskPriceSend	= "(<PlayerName> <AskPrice Query>)";
		OptAuctionDuration	= "(last||2h||8h||24h)";
		OptBidbroker	= "<silver_profit>";
		OptBidLimit	= "<number>";
		OptBroker	= "<silver_profit>";
		OptClear	= "([Item]||all||snapshot)";
		OptCompete	= "<silver_less>";
		OptDefault	= "(<option>||all)";
		OptFinish	= "(off||logout||exit)";
		OptLocale	= "<locale>";
		OptPctBidmarkdown	= "<percent>";
		OptPctMarkup	= "<percent>";
		OptPctMaxless	= "<percent>";
		OptPctNocomp	= "<percent>";
		OptPctUnderlow	= "<percent>";
		OptPctUndermkt	= "<percent>";
		OptPercentless	= "<percent>";
		OptPrintin	= "(<frameIndex>[Number]||<frameName>[String])";
		OptProtectWindow	= "(never||scan||always)";
		OptScale	= "<scale_factor>";
		OptScan	= "<>";


		-- Section: Commands
		CmdAlso	= "also";
		CmdAlsoOpposite	= "opposite";
		CmdAlt	= "alt";
		CmdAskPriceAd	= "ad";
		CmdAskPriceGuild	= "guild";
		CmdAskPriceParty	= "party";
		CmdAskPriceSend	= "send";
		CmdAskPriceSmart	= "smart";
		CmdAskPriceSmartWord1	= "what";
		CmdAskPriceSmartWord2	= "worth";
		CmdAskPriceTrigger	= "trigger";
		CmdAskPriceVendor	= "vendor";
		CmdAskPriceWhispers	= "whispers";
		CmdAskPriceWord	= "word";
		CmdAuctionClick	= "auction-click";
		CmdAuctionDuration	= "auction-duration";
		CmdAuctionDuration0	= "last";
		CmdAuctionDuration1	= "2h";
		CmdAuctionDuration2	= "8h";
		CmdAuctionDuration3	= "24h";
		CmdAutofill	= "autofill";
		CmdBidbroker	= "bidbroker";
		CmdBidbrokerShort	= "bb";
		CmdBidLimit	= "bid-limit";
		CmdBroker	= "broker";
		CmdClear	= "clear";
		CmdClearAll	= "all";
		CmdClearSnapshot	= "snapshot";
		CmdCompete	= "compete";
		CmdCtrl	= "ctrl";
		CmdDefault	= "default";
		CmdDisable	= "disable";
		CmdEmbed	= "embed";
		CmdFinish	= "finish";
		CmdFinish0	= "off";
		CmdFinish1	= "logout";
		CmdFinish2	= "exit";
		CmdFinish3	= "reloadui";
		CmdFinishSound	= "finish-sound";
		CmdHelp	= "help";
		CmdLocale	= "locale";
		CmdOff	= "off";
		CmdOn	= "on";
		CmdPctBidmarkdown	= "pct-bidmarkdown";
		CmdPctMarkup	= "pct-markup";
		CmdPctMaxless	= "pct-maxless";
		CmdPctNocomp	= "pct-nocomp";
		CmdPctUnderlow	= "pct-underlow";
		CmdPctUndermkt	= "pct-undermkt";
		CmdPercentless	= "percentless";
		CmdPercentlessShort	= "pl";
		CmdPrintin	= "print-in";
		CmdProtectWindow	= "protect-window";
		CmdProtectWindow0	= "never";
		CmdProtectWindow1	= "scan";
		CmdProtectWindow2	= "always";
		CmdScan	= "scan";
		CmdShift	= "shift";
		CmdToggle	= "toggle";
		CmdUpdatePrice	= "update-price";
		CmdWarnColor	= "warn-color";
		ShowAverage	= "show-average";
		ShowEmbedBlank	= "show-embed-blankline";
		ShowLink	= "show-link";
		ShowMedian	= "show-median";
		ShowRedo	= "show-warning";
		ShowStats	= "show-stats";
		ShowSuggest	= "show-suggest";
		ShowVerbose	= "show-verbose";


		-- Section: Config Text
		GuiAlso	= "Also display data for";
		GuiAlsoDisplay	= "Displaying data for %s";
		GuiAlsoOff	= "No longer displaying other realm-faction data.";
		GuiAlsoOpposite	= "Now also displaying data for opposite faction.";
		GuiAskPrice	= "Enable AskPrice";
		GuiAskPriceAd	= "Send features ad";
		GuiAskPriceGuild	= "Respond to guildchat queries";
		GuiAskPriceHeader	= "AskPrice Options";
		GuiAskPriceHeaderHelp	= "Change AskPrice's behaviour";
		GuiAskPriceParty	= "Respond to partychat queries";
		GuiAskPriceSmart	= "Use smartwords";
		GuiAskPriceTrigger	= "AskPrice trigger";
		GuiAskPriceVendor	= "Send vendor info";
		GuiAskPriceWhispers	= "Show outgoing whispers";
		GuiAskPriceWord	= "Custom SmartWord %d";
		GuiAuctionDuration	= "Default auction duration";
		GuiAuctionHouseHeader	= "Auction House window";
		GuiAuctionHouseHeaderHelp	= "Change the behavior of the Auction House window";
		GuiAutofill	= "Autofill prices in the AH";
		GuiAverages	= "Show Averages";
		GuiBidmarkdown	= "Bid Markdown Percent";
		GuiClearall	= "Clear All Auctioneer Data";
		GuiClearallButton	= "Clear All";
		GuiClearallHelp	= "Click here to clear all of Auctioneer data for the current server-realm.";
		GuiClearallNote	= "for the current server-faction";
		GuiClearHeader	= "Clear Data";
		GuiClearHelp	= "Clears Auctioneer data. \nSelect either all data or the current snapshot.\nWARNING: These actions are NOT undoable.";
		GuiClearsnap	= "Clear Snapshot data";
		GuiClearsnapButton	= "Clear Snapshot";
		GuiClearsnapHelp	= "Click here to clear the last Auctioneer snapshot data.";
		GuiDefaultAll	= "Reset All Auctioneer Options";
		GuiDefaultAllButton	= "Reset All";
		GuiDefaultAllHelp	= "Click here to set all Auctioneer options to their default values.\nWARNING: This action is NOT undoable.";
		GuiDefaultOption	= "Reset this setting";
		GuiEmbed	= "Embed info in in-game tooltip";
		GuiEmbedBlankline	= "Show blankline in in-game tooltip";
		GuiEmbedHeader	= "Embed";
		GuiFinish	= "After a scan has finished";
		GuiFinishSound	= "Play sound on scan finish";
		GuiLink	= "Show LinkID";
		GuiLoad	= "Load Auctioneer";
		GuiLoad_Always	= "always";
		GuiLoad_AuctionHouse	= "at Auction House";
		GuiLoad_Never	= "never";
		GuiLocale	= "Set locale to";
		GuiMainEnable	= "Enable Auctioneer";
		GuiMainHelp	= "Contains settings for Auctioneer \nan AddOn that displays item info and analyzes auction data. \nClick the \"Scan\" button at the AH to collect auction data.";
		GuiMarkup	= "Vendor Price Markup Percent";
		GuiMaxless	= "Max Market Undercut Percent";
		GuiMedian	= "Show Medians";
		GuiNocomp	= "No Competition Undercut Percent";
		GuiNoWorldMap	= "Auctioneer: suppressed displaying of world map";
		GuiOtherHeader	= "Other Options";
		GuiOtherHelp	= "Miscellaneous Auctioneer Options";
		GuiPercentsHeader	= "Auctioneer Threshold Percents";
		GuiPercentsHelp	= "WARNING: The following setting are for Power Users ONLY.\nAdjust the following values to change how aggresive Auctioneer will be when deciding profitable levels.";
		GuiPrintin	= "Select the desired message frame";
		GuiProtectWindow	= "Prevent accidental closing of AH window";
		GuiRedo	= "Show Long Scan Warning";
		GuiReloadui	= "Reload User Interface";
		GuiReloaduiButton	= "ReloadUI";
		GuiReloaduiFeedback	= "Now Reloading the WoW UI";
		GuiReloaduiHelp	= "Click here to reload the WoW User Interface after changing the locale so that the language in this configuration screen matches the one you selected.\nNote: This operation may take a few minutes.";
		GuiRememberText	= "Remember price";
		GuiStatsEnable	= "Show Stats";
		GuiStatsHeader	= "Item Price Statistics";
		GuiStatsHelp	= "Show the following statistics in the tooltip.";
		GuiSuggest	= "Show Suggested Prices";
		GuiUnderlow	= "Lowest Auction Undercut";
		GuiUndermkt	= "Undercut Market When Maxless";
		GuiVerbose	= "Verbose Mode";
		GuiWarnColor	= "Color Pricing Model";


		-- Section: Conversion Messages
		MesgConvert	= "Auctioneer Database Conversion. Please backup your SavedVariables\\Auctioneer.lua first.%s%s";
		MesgConvertNo	= "Disable Auctioneer";
		MesgConvertYes	= "Convert";
		MesgNotconverting	= "Auctioneer is not converting your database, but will not function until you do.";


		-- Section: Game Constants
		SubTypeBag	= "Bag";
		TimeLong	= "Long";
		TimeMed	= "Medium";
		TimeShort	= "Short";
		TimeVlong	= "Very Long";


		-- Section: Generic Messages
		ConfirmBidBuyout	= "Are you sure you want to %s\n%dx%s for:";
		DisableMsg	= "Disabling automatic loading of Auctioneer";
		FrmtWelcome	= "Auctioneer v%s loaded";
		MesgNotLoaded	= "Auctioneer is not loaded. Type /auctioneer for more info.";
		ScanCancel	= "Scan canceled";
		ScanComplete	= "Scan complete";
		ScanFailed	= "Scan failed";
		StatAskPriceOff	= "AskPrice is now disabled.";
		StatAskPriceOn	= "AskPrice is now enabled.";
		StatOff	= "Not displaying any auction data";
		StatOn	= "Displaying configured auction data";
		UIScanCanceled	= "Auctioneer: Auction scanning canceled";
		UIScanComplete	= "Auctioneer: Auction scanning completed";
		UIScanFailed	= "Auctioneer: Auction scanning failed";


		-- Section: Generic Strings
		TextCombat	= "Combat";
		TextGeneral	= "General";
		TextNone	= "none";
		TextScan	= "Scan";
		TextUsage	= "Usage:";


		-- Section: Help Text
		HelpAlso	= "Also display another server's values in the tooltip. For realm, insert the realmname and for faction the faction's name. For example: \"/auctioneer also Al'Akir-Horde\". The special keyword \"opposite\" means the opposite faction, \"off\" disables the functionality.";
		HelpAskPrice	= "Enable or disable AskPrice.";
		HelpAskPriceAd	= "Enable or disable new AskPrice features ad.";
		HelpAskPriceGuild	= "Respond to queries made in guild chat.";
		HelpAskPriceParty	= "Respond to queries made in party chat.";
		HelpAskPriceSend	= "Manually send a player the result of an AskPrice query.";
		HelpAskPriceSmart	= "Enable or disable SmartWords checking.";
		HelpAskPriceTrigger	= "Change AskPrice's trigger character.";
		HelpAskPriceVendor	= "Enable or disable the sending of vendor pricing data.";
		HelpAskPriceWhispers	= "Enable or disable the hiding of all AskPrice outgoing whispers.";
		HelpAskPriceWord	= "Add or modify AskPrice's custom SmartWords.";
		HelpAuctionClick	= "Allows you to Alt-Click an item in your bag to automatically start an auction for it";
		HelpAuctionDuration	= "Set the default auction duration upon opening the Auction House interface";
		HelpAutofill	= "Set whether to autofill prices when dropping new auction items into the auction house window";
		HelpAverage	= "Select whether to show item's average auction price";
		HelpBidbroker	= "Show short or medium term auctions from the recent scan that may be bid on for profit";
		HelpBidLimit	= "Maximum number of auctions to bid on or buyout when the Bid or Buyout button is clicked on the Search Auctions tab.";
		HelpBroker	= "Show any auctions from the most recent scan that may be bid on and then resold for profit";
		HelpClear	= "Clear the specified item's data (you must shift click insert the item(s) into the command) You may also specify the special keywords \"all\" or \"snapshot\"";
		HelpCompete	= "Show any recently scanned auctions whose buyout is less than one of your items";
		HelpDefault	= "Set an Auctioneer option to it's default value. You may also specify the special keyword \"all\" to set all Auctioneer options to their default values.";
		HelpDisable	= "Stops Auctioneer from automatically loading next time you log in";
		HelpEmbed	= "Embed the text in the original game tooltip (note: certain features are disabled when this is selected)";
		HelpEmbedBlank	= "Select whether to show a blank line between the tooltip info and the auction info when embedded mode is on";
		HelpFinish	= "Set whether to automatically logout or exit the game upon finishing an auction house scan";
		HelpFinishSound	= "Set whether to play a sound at the end of an Auction House scan.";
		HelpLink	= "Select whether to show the link id in the tooltip";
		HelpLoad	= "Change Auctioneer's load settings for this toon";
		HelpLocale	= "Change the locale that is used to display Auctioneer messages";
		HelpMedian	= "Select whether to show item's median buyout price";
		HelpOnoff	= "Turns the auction data display on and off";
		HelpPctBidmarkdown	= "Set the percentage that Auctioneer will mark down bids from the buyout price";
		HelpPctMarkup	= "The percentage that vendor prices will be marked up when no other values are available";
		HelpPctMaxless	= "Set the maximum percentage that Auctioneer will undercut market value before it gives up";
		HelpPctNocomp	= "The percentage that Auctioneer will undercut market value when there is no competition";
		HelpPctUnderlow	= "Set the percentage that Auctioneer will undercut the lowest auction price";
		HelpPctUndermkt	= "Percentage to cut market value by when unable to beat competition (due to maxless)";
		HelpPercentless	= "Show any recently scanned auctions whose buyout is a certain percent less than the highest sellable price";
		HelpPrintin	= "Select which frame Auctioneer will print out it's messages. You can either specify the frame's name or the frame's index.";
		HelpProtectWindow	= "Prevents you from accidentally closing the Auction House interface";
		HelpRedo	= "Select whether to show a warning when the currently scanned AH page has taken too long to scan due to server lag.";
		HelpScan	= "Perform a scan of the auction house at the next visit, or while you are there (there is also a button in the auction pane). Choose which categories you want to scan with the checkboxes.";
		HelpStats	= "Select whether to show item's bid/buyout percentages";
		HelpSuggest	= "Select whether to show item's suggested auction price";
		HelpUpdatePrice	= "Automatically update the starting price for an auction on the Post Auctions tab when the buyout price changes.";
		HelpVerbose	= "Select whether to show averages and suggestions verbosely (or off to show them on a single line)";
		HelpWarnColor	= "Select whether to show the current AH pricing model (Undercutting by...) in intuitive colors.";


		-- Section: Post Messages
		FrmtNoEmptyPackSpace	= "No empty pack space found to create auction!";
		FrmtNotEnoughOfItem	= "Not enough %s found to create auction!";
		FrmtPostedAuction	= "Posted 1 auction of %s (x%d)";
		FrmtPostedAuctions	= "Posted %d auctions of %s (x%d)";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "curBid";
		FrmtBidbrokerDone	= "Bid brokering done";
		FrmtBidbrokerHeader	= "Minimum profit: %s, HSP = 'Highest Sellable Price'";
		FrmtBidbrokerLine	= "%s, Last %s seen, HSP: %s, %s: %s, Prof: %s, Time: %s";
		FrmtBidbrokerMinbid	= "minBid";
		FrmtBrokerDone	= "Brokering done";
		FrmtBrokerHeader	= "Minimum profit: %s, HSP = 'Highest Sellable Price'";
		FrmtBrokerLine	= "%s, Last %s seen, HSP: %s, BO: %s, Prof: %s";
		FrmtCompeteDone	= "Competing auctions done.";
		FrmtCompeteHeader	= "Competing auctions at least %s less per item.";
		FrmtCompeteLine	= "%s, Bid: %s, BO %s vs %s, %s less";
		FrmtHspLine	= "Highest Sellable Price for one %s is: %s";
		FrmtLowLine	= "%s, BO: %s, Seller: %s, For one: %s, Less than median: %s";
		FrmtMedianLine	= "Of last %d seen, median BO for 1 %s is: %s";
		FrmtNoauct	= "No auctions found for the item: %s";
		FrmtPctlessDone	= "Percent less done.";
		FrmtPctlessHeader	= "Percent Less than Highest Sellable Price (HSP): %d%%";
		FrmtPctlessLine	= "%s, Last %d seen, HSP: %s, BO: %s, Prof: %s, Less %s";


		-- Section: Scanning Messages
		AuctionDefunctAucts	= "Defunct auctions removed: %s";
		AuctionDiscrepancies	= "Discrepancies: %s";
		AuctionNewAucts	= "New auctions scanned: %s";
		AuctionPageN	= "Auctioneer: scanning %s page %d of %d\nAuctions per second: %s\nEstimated time left: %s\nAdded to snapshot: %s";
		AuctionScanAll	= "Scanning all auctions.";
		AuctionScanAuctions	= "Scanning auctions.";
		AuctionScanCat	= "Scanning all %s auctions.";
		AuctionScanDone	= "Auctioneer: auction scanning finished";
		AuctionScanNexttime	= "Auctioneer will perform a full auction scan the next time you talk to an auctioneer.";
		AuctionScanNocat	= "You must have at least one category selected to scan.";
		AuctionScanRedo	= "Current page took more than %d seconds to complete, retrying page.";
		AuctionScanStart	= "Auctioneer: %s Page 1...";
		AuctionTotalAucts	= "Total auctions scanned: %s";
		AuctionUpdatedAucts	= "Updated/Changed auctions: %s";


		-- Section: Tooltip Messages
		FrmtInfoAlsoseen	= "Seen %d times at %s";
		FrmtInfoAverage	= "%s min/%s BO (%s bid)";
		FrmtInfoBidMulti	= "Bids (%s%s ea)";
		FrmtInfoBidOne	= "Bids%s";
		FrmtInfoBidrate	= "%d%% have bids, %d%% have BO";
		FrmtInfoBuymedian	= "Buyout median";
		FrmtInfoBuyMulti	= "Buyout (%s%s ea)";
		FrmtInfoBuyOne	= "Buyout%s";
		FrmtInfoForone	= "For 1: %s min/%s BO (%s bid) [in %d's]";
		FrmtInfoHeadMulti	= "Averages for %d items:";
		FrmtInfoHeadOne	= "Averages for this item:";
		FrmtInfoHistmed	= "Last %d, median BO (ea)";
		FrmtInfoMinMulti	= "Starting bid (%s ea)";
		FrmtInfoMinOne	= "Starting bid";
		FrmtInfoNever	= "Never seen at %s";
		FrmtInfoNeverAtAll	= "Never seen at auction";
		FrmtInfoSeen	= "Seen %d times at auction total";
		FrmtInfoSgst	= "Suggested price: %s min/%s BO";
		FrmtInfoSgststx	= "Suggested price for your %d stack: %s min/%s BO (%s/%s ea)";
		FrmtInfoSnapmed	= "Scanned %d, median BO (ea)";
		FrmtInfoStacksize	= "Average stack size: %d items";


		-- Section: User Interface
		BuySortTooltip	= "Sort results page by buyout price (hold SHIFT to sort by item name instead)";
		ClearTooltip	= "Clear any custom search parameters from search fields.";
		FrmtLastSoldOn	= "Last Sold on %s";
		RefreshTooltip	= "Resubmit search query at the current page number.";
		UiBid	= "Bid";
		UiBidHeader	= "Bid";
		UiBidPerHeader	= "Bid Per";
		UiBuyout	= "Buyout";
		UiBuyoutHeader	= "Buyout";
		UiBuyoutPerHeader	= "Buyout Per";
		UiBuyoutPriceLabel	= "Buyout Price:";
		UiBuyoutPriceTooLowError	= "(Too Low)";
		UiCategoryLabel	= "Category Restriction:";
		UiDepositLabel	= "Deposit:";
		UiDurationLabel	= "Duration:";
		UiItemLevelHeader	= "Lvl";
		UiMakeFixedPriceLabel	= "Make fixed price";
		UiMaxError	= "(%d Max)";
		UiMaximumPriceLabel	= "Maximum Price:";
		UiMaximumTimeLeftLabel	= "Maximum Time Left:";
		UiMinimumBidPercentLabel	= "Min Bid %:";
		UiMinimumPercentLessShortLabel	= "Min Pct Less:";
		UiMinimumProfitLabel	= "Minimum Profit:";
		UiMinimumQualityLabel	= "Minimum Quality:";
		UiMinimumUndercutLabel	= "Minimum Undercut:";
		UiNameHeader	= "Name";
		UiNoPendingBids	= "All bid requests complete!";
		UiNotEnoughError	= "(Not Enough)";
		UiPendingBidInProgress	= "1 bid request in progress...";
		UiPendingBidsInProgress	= "%d bid requests in progress...";
		UiPercentLessHeader	= "Pct";
		UiPost	= "Post";
		UiPostAuctions	= "Post Auctions";
		UiPriceBasedOnLabel	= "Price Based On:";
		UiPriceModelAuctioneer	= "Auctioneer Price";
		UiPriceModelCustom	= "Custom Price";
		UiPriceModelFixed	= "Fixed Price";
		UiPriceModelLastSold	= "Last Price Sold";
		UiProfitHeader	= "Profit";
		UiProfitPerHeader	= "Profit Per";
		UiQuantityHeader	= "Qty";
		UiQuantityLabel	= "Quantity:";
		UiRemoveSearchButton	= "Delete";
		UiSavedSearchLabel	= "Saved searches:";
		UiSaveSearchButton	= "Save";
		UiSaveSearchLabel	= "Save this search:";
		UiSearch	= "Search";
		UiSearchAuctions	= "Search Auctions";
		UiSearchDropDownLabel	= "Search:";
		UiSearchForLabel	= "Search For Item:";
		UiSearchForOwnerLabel	= "Search For Item's Posted By:";
		UiSearchTypeBids	= "Bids";
		UiSearchTypeBuyouts	= "Buyouts";
		UiSearchTypeCompetition	= "Competition";
		UiSearchTypeOwner	= "Seller";
		UiSearchTypePlain	= "Item";
		UiStacksLabel	= "Stacks";
		UiStackTooBigError	= "(Stack Too Big)";
		UiStackTooSmallError	= "(Stack Too Small)";
		UiStartingPriceLabel	= "Starting Price:";
		UiStartingPriceRequiredError	= "(Required)";
		UiTimeLeftHeader	= "Time Left";
		UiUnknownError	= "(Unknown)";

	};

	esES = {


		-- Section: AskPrice Messages
		AskPriceAd	= "Recibe precios para paquetes con %sx[Enlace de Artículo] (x = tamaño del paquete)";
		FrmtAskPriceBuyoutMedianHistorical	= "%sMedia histórica: %s%s";
		FrmtAskPriceBuyoutMedianSnapshot	= "%sPromedio de compra en última búsqueda: %s%s";
		FrmtAskPriceDisable	= "Deshabilitando la opción %s de PreguntarPrecios";
		FrmtAskPriceEach	= "(%s c/u)";
		FrmtAskPriceEnable	= "Activando la opción %s de PreguntarPrecios";
		FrmtAskPriceVendorPrice	= "%sVender a vendedor por: %s%s";


		-- Section: Auction Messages
		FrmtActRemove	= "Quitando subasta %s de los datos actuales de la casa de subastas.";
		FrmtAuctinfoHist	= "%d Histórico";
		FrmtAuctinfoLow	= "Precio más bajo";
		FrmtAuctinfoMktprice	= "Precio de mercado";
		FrmtAuctinfoNolow	= "El objeto no ha sido visto antes en la Casa de Subastas";
		FrmtAuctinfoOrig	= "Puja Original";
		FrmtAuctinfoSnap	= "%d en la última exploración";
		FrmtAuctinfoSugbid	= "Puja inicial";
		FrmtAuctinfoSugbuy	= "Precio de compra sugerido";
		FrmtWarnAbovemkt	= "Competencia por encima del mercado";
		FrmtWarnMarkup	= "Superando vendedor por %s%%";
		FrmtWarnMyprice	= "Usando mi precio actual";
		FrmtWarnNocomp	= "Sin competencia";
		FrmtWarnNodata	= "Sin información para PMV";
		FrmtWarnToolow	= "Imposible igualar mínimo";
		FrmtWarnUndercut	= "Rebajando en un %s%%";
		FrmtWarnUser	= "Usando precio de usuario";


		-- Section: Bid Messages
		FrmtAlreadyHighBidder	= "Ya eres el pujador más alto en la subasta: %s (x%d)";
		FrmtBidAuction	= "Puja en la subasta: %s (x%d)";
		FrmtBidQueueOutOfSync	= "Error: ¡Lista de pujas desincronizada!";
		FrmtBoughtAuction	= "Se compró subasta: %s (x%d)";
		FrmtMaxBidsReached	= "Mas subastas de %s (x%d) encontradas, pero se llegó al limite de pujas(%d)";
		FrmtNoAuctionsFound	= "No se ha encontrado la subasta: %s (x%d)";
		FrmtNoMoreAuctionsFound	= "No se encontraron más subastas: %s (x%d)";
		FrmtNotEnoughMoney	= "No tienes suficiente dinero para pujar en la subasta: %s (x%d)";
		FrmtSkippedAuctionWithHigherBid	= "Saltando subasta con puja mayor: %s (x%d)";
		FrmtSkippedAuctionWithLowerBid	= "Saltando subasta con puja menor: %s (x%d)";
		FrmtSkippedBiddingOnOwnAuction	= "Saltando puja en subasta propia: %s (x%d)";
		UiProcessingBidRequests	= "Procesando petición de pujas...";


		-- Section: Command Messages
		ConstantsCritical	= "CRÍTICO: Su archivo de variables de Auctioneer está %.3f%% Lleno!";
		ConstantsMessage	= "Su archivo de variables de Auctioneer está %.3f%% Lleno";
		ConstantsWarning	= "ADVERTENCIA: Su archivo de variables de Auctioneer está %.3f%% Lleno";
		FrmtActClearall	= "Eliminando toda la información de subastas para %s";
		FrmtActClearFail	= "Imposible encontrar artí­culo: %s";
		FrmtActClearOk	= "Información eliminada para el artí­culo: %s";
		FrmtActClearsnap	= "Eliminando información actual de la casa de subastas.";
		FrmtActDefault	= "La configuración %s de Auctioneer ha sido restaurada a su estado original";
		FrmtActDefaultall	= "Todas las opciones de Auctioneer han sido cambiadas a su estado original";
		FrmtActDisable	= "Ocultando información de: %s ";
		FrmtActEnable	= "Mostrando informacion de: %s ";
		FrmtActSet	= "%s ajustado(a) a '%s'";
		FrmtActUnknown	= "Palabra clave o comando desconocido: '%s'";
		FrmtAuctionDuration	= "Duración de las subastas fijado a: %s";
		FrmtAutostart	= "Comenzando subasta automáticamente para %s: %s mí­nimo, %s compra (%dh)\n%s";
		FrmtFinish	= "Después de que una exploración haya terminado, nosotros %s";
		FrmtPrintin	= "Los mensajes de Auctioneer se imprimirán en la ventana de chat \"%s\"";
		FrmtProtectWindow	= "Protección de la ventana de la Casa de Subastas fijado a: %s";
		FrmtUnknownArg	= "'%s' no es un argumento válido para '%s'";
		FrmtUnknownLocale	= "La localización que ha especifícado ('%s') no es válida. Las localizaciones válidas son:";
		FrmtUnknownRf	= "Parámetro inválido ('%s'). El parámetro debe de estar en la forma de: [reino]-[facción]. Por ejemplo: Al'Akir-Horda";


		-- Section: Command Options
		OptAlso	= "(reino-facción||opuesta||casa||neutral)";
		OptAskPriceSend	= "(<NombreDeJugador> <Pregunta para AskPrice>)";
		OptAuctionDuration	= "(última|2h|8h|24h)";
		OptBidbroker	= "<ganancia_plata>";
		OptBidLimit	= "<número>";
		OptBroker	= "<ganancia_plata>";
		OptClear	= "([Artí­culo]||todo||imagen)";
		OptCompete	= "<plata_menos>";
		OptDefault	= "(<opción>||todo)";
		OptFinish	= "(apagado||de-registrarse||salir)";
		OptLocale	= "<localización>";
		OptPctBidmarkdown	= "<porciento>";
		OptPctMarkup	= "<porciento>";
		OptPctMaxless	= "<porciento>";
		OptPctNocomp	= "<porciento>";
		OptPctUnderlow	= "<porciento>";
		OptPctUndermkt	= "<porciento>";
		OptPercentless	= "<porciento>";
		OptPrintin	= "(<índiceVentana>[Número]||<nombreVentana>[Serie])";
		OptProtectWindow	= "(nunca||explorar||siempre)";
		OptScale	= "<escala>";
		OptScan	= "<>";


		-- Section: Commands
		CmdAlso	= "tambien";
		CmdAlsoOpposite	= "opuesta";
		CmdAlt	= "Alt";
		CmdAskPriceAd	= "anuncio";
		CmdAskPriceGuild	= "gremio";
		CmdAskPriceParty	= "grupo";
		CmdAskPriceSend	= "enviar";
		CmdAskPriceSmart	= "inteligente";
		CmdAskPriceSmartWord1	= "cuanto";
		CmdAskPriceSmartWord2	= "vale";
		CmdAskPriceTrigger	= "gatillo";
		CmdAskPriceVendor	= "vendedor";
		CmdAskPriceWhispers	= "susurros";
		CmdAskPriceWord	= "palabra";
		CmdAuctionClick	= "click-subasta";
		CmdAuctionDuration	= "duracion-subasta";
		CmdAuctionDuration0	= "última";
		CmdAuctionDuration1	= "2h";
		CmdAuctionDuration2	= "8h";
		CmdAuctionDuration3	= "24h";
		CmdAutofill	= "autoinsertar";
		CmdBidbroker	= "corredor de ofertas";
		CmdBidbrokerShort	= "co";
		CmdBidLimit	= "limite-peticiones";
		CmdBroker	= "corredor";
		CmdClear	= "borrar";
		CmdClearAll	= "todo";
		CmdClearSnapshot	= "imagen";
		CmdCompete	= "competir";
		CmdCtrl	= "Ctrl";
		CmdDefault	= "original";
		CmdDisable	= "deshabilitar";
		CmdEmbed	= "integrado";
		CmdFinish	= "terminar";
		CmdFinish0	= "apagado";
		CmdFinish1	= "salir";
		CmdFinish2	= "salir";
		CmdFinish3	= "recargar";
		CmdFinishSound	= "sonido-terminar";
		CmdHelp	= "ayuda";
		CmdLocale	= "localidad";
		CmdOff	= "apagado";
		CmdOn	= "activar";
		CmdPctBidmarkdown	= "pct-menosoferta";
		CmdPctMarkup	= "pct-mas";
		CmdPctMaxless	= "pct-sinmaximo";
		CmdPctNocomp	= "pct-sincomp";
		CmdPctUnderlow	= "pct-bajomenor";
		CmdPctUndermkt	= "pct-bajomercado";
		CmdPercentless	= "porcientomenos";
		CmdPercentlessShort	= "pm";
		CmdPrintin	= "imprimir-en";
		CmdProtectWindow	= "protejer-ventana";
		CmdProtectWindow0	= "nunca";
		CmdProtectWindow1	= "explorar";
		CmdProtectWindow2	= "siempre";
		CmdScan	= "explorar";
		CmdShift	= "Shift";
		CmdToggle	= "invertir";
		CmdUpdatePrice	= "actualización-precio";
		CmdWarnColor	= "color-advertencia";
		ShowAverage	= "ver-promedio";
		ShowEmbedBlank	= "ver-integrado-lineavacia";
		ShowLink	= "ver-enlace";
		ShowMedian	= "ver-promedio";
		ShowRedo	= "ver-advertencia";
		ShowStats	= "ver-estadísticas";
		ShowSuggest	= "ver-sugerencia";
		ShowVerbose	= "ver-literal";


		-- Section: Config Text
		GuiAlso	= "También mostrar valores para";
		GuiAlsoDisplay	= "Mostrando información para %s";
		GuiAlsoOff	= "Dejar de mostrar información para otro(s) reino(s)-facción(es)";
		GuiAlsoOpposite	= "Mostrando información para la facción opuesta.";
		GuiAskPrice	= "Encender AskPrice";
		GuiAskPriceAd	= "Enviar anuncio";
		GuiAskPriceGuild	= "Responder a las peticiones del chat de hermandad";
		GuiAskPriceHeader	= "Opciones de AskPrice";
		GuiAskPriceHeaderHelp	= "Cambia el functionamiento de AskPrice";
		GuiAskPriceParty	= "Responder a las peticiones del chat de grupo";
		GuiAskPriceSmart	= "Usar palabras inteligentes";
		GuiAskPriceTrigger	= "Activador de AskPrice";
		GuiAskPriceVendor	= "Enviar información de Venta a Vendedores";
		GuiAskPriceWhispers	= "Ver susurros salientes";
		GuiAskPriceWord	= "Palabra inteligente particular %d";
		GuiAuctionDuration	= "Duración por defecto de las subastas";
		GuiAuctionHouseHeader	= "Ventana de la Casa de Subastas";
		GuiAuctionHouseHeaderHelp	= "Modificar el comportamiento de la ventana de la Casa de Subastas";
		GuiAutofill	= "Autocompletar precios en la casa de subastas";
		GuiAverages	= "Mostrar Promedios";
		GuiBidmarkdown	= "Porcentaje de rebaja de la puja";
		GuiClearall	= "Eliminar toda la información";
		GuiClearallButton	= "Eliminar Todo";
		GuiClearallHelp	= "Clic aquí para eliminar toda la información de Auctioneer para el servidor-reino actual.";
		GuiClearallNote	= "para el servidor-facción actual.";
		GuiClearHeader	= "Eliminar Información";
		GuiClearHelp	= "Elimina la informacion de Auctioneer. \nSelecciona si eliminar toda la información o solamente la imágen actual.\nADVERTENCIA: Estas acciones NO son reversibles.";
		GuiClearsnap	= "Eliminar los datos de la imagen";
		GuiClearsnapButton	= "Eliminar Imagen";
		GuiClearsnapHelp	= "Clic aquí para eliminar la última imagen de información de Auctioneer.";
		GuiDefaultAll	= "Restaurar todas las opciones";
		GuiDefaultAllButton	= "Restaurar Todo";
		GuiDefaultAllHelp	= "Seleccione aquí para restaurar todas las opciones de Auctioneer a sus configuraciones por defecto.\nADVERTENCIA: Esta acción NO es reversible.";
		GuiDefaultOption	= "Restaurar esta opción";
		GuiEmbed	= "Integrar información en la caja de ayuda";
		GuiEmbedBlankline	= "Mostrar linea en blanco en el tooltip.";
		GuiEmbedHeader	= "Integración";
		GuiFinish	= "Después de completar exploración";
		GuiFinishSound	= "Reproducir sonido al completar exploración";
		GuiLink	= "Ver número de enlace";
		GuiLoad	= "Cargar Auctioneer";
		GuiLoad_Always	= "siempre";
		GuiLoad_AuctionHouse	= "en la Casa de Subastas";
		GuiLoad_Never	= "nunca";
		GuiLocale	= "Ajustar localización a";
		GuiMainEnable	= "Activar Auctioneer";
		GuiMainHelp	= "Contiene ajustes para Auctioneer \nun accesorio que muestra información sobre artículos y analiza información de subastas. \nSeleccione \"Explorar\" en la casa de subastas para recopilar información sobre las subastas.";
		GuiMarkup	= "Porcentaje de margen sobre vendedor";
		GuiMaxless	= "Porcentaje máximo de rebaja de mercado";
		GuiMedian	= "Mostrar Promedios";
		GuiNocomp	= "Porcentaje de rebaja sin competencia.";
		GuiNoWorldMap	= "Auctioneer: no se mostrará el mapa del mundo";
		GuiOtherHeader	= "Otras Opciones";
		GuiOtherHelp	= "Otras Opciones de Auctioneer";
		GuiPercentsHeader	= "Límite de Porcentajes de Auctioneer";
		GuiPercentsHelp	= "ADVERTENCIA: Las siguientes opciones son para usuarios expertos SOLAMENTE.\nAjuste los siguientes valores para cambiar cuan agresivo es Auctioneer al determinar niveles provechosos.";
		GuiPrintin	= "Seleccione la ventana deseada";
		GuiProtectWindow	= "Prevenir el cierre accidental de la ventana de la Casa de Subastas";
		GuiRedo	= "Mostrar Advertencia de Exploración Larga";
		GuiReloadui	= "Recargar Interfaz";
		GuiReloaduiButton	= "Recargar";
		GuiReloaduiFeedback	= "Recargando el Interfaz de WoW";
		GuiReloaduiHelp	= "Presione aquí para recargar el interfaz de WoW tras haber seleccionado una localización diferente. Esto es para que el lenguaje de configuración sea el mismo que el de Auctioneer.\nNota: Esta operación puede llevar unos minutos.";
		GuiRememberText	= "Recordar precio";
		GuiStatsEnable	= "Ver estadísticas";
		GuiStatsHeader	= "Estadísticas de precios de artículos";
		GuiStatsHelp	= "Mostrar las siguientes estadísticas en la caja de ayuda.";
		GuiSuggest	= "Mostrar Precios Sugeridos";
		GuiUnderlow	= "Rebaja más baja de subasta";
		GuiUndermkt	= "Rebajar mercado cuando Sinmáximo";
		GuiVerbose	= "Modo extendido";
		GuiWarnColor	= "Colorear Modelo de Valoración";


		-- Section: Conversion Messages
		MesgConvert	= "Conversión de base de datos de Auctioneer. Por favor, haz primero una copia de seguridad de SavedVariables\\Auctioneer.lua.%s%s";
		MesgConvertNo	= "Desactivar Auctioneer";
		MesgConvertYes	= "Convertir";
		MesgNotconverting	= "Auctioneer no convertirá su base de datos, pero no funcionará hasta que la base de datos sea convertida.";


		-- Section: Game Constants
		SubTypeBag	= "Bolsa";
		TimeLong	= "Largo";
		TimeMed	= "Medio";
		TimeShort	= "Corto";
		TimeVlong	= "Muy Largo";


		-- Section: Generic Messages
		ConfirmBidBuyout	= "Estás seguro de que quieres %s\n%dx%s por:";
		DisableMsg	= "Desactivando la carga automática de Auctioneer";
		FrmtWelcome	= "Auctioneer versión %s cargada";
		MesgNotLoaded	= "Auctioneer no está cargado. Escriba /auctioneer para más información.";
		ScanCancel	= "Exploración Cancelada";
		ScanComplete	= "Exploración Completada";
		ScanFailed	= "Exploración Fracasada";
		StatAskPriceOff	= "AskPrice ha sido desactivado";
		StatAskPriceOn	= "AskPrice ha sido activado";
		StatOff	= "Ocultando toda información de subastas";
		StatOn	= "Mostrando los datos de subasta configurados";
		UIScanCanceled	= "Auctioneer: La exploración de las subastas se cancelo";
		UIScanComplete	= "Auctioneer: La exploración de las subastas ha completado";
		UIScanFailed	= "Auctioneer: La exploración de las subastas ha fallado";


		-- Section: Generic Strings
		TextCombat	= "Combate";
		TextGeneral	= "General";
		TextNone	= "nada";
		TextScan	= "Explorar";
		TextUsage	= "Uso:";


		-- Section: Help Text
		HelpAlso	= "Mostrar también los valores de otros servidores en la caja de ayuda. Para el reino escribe el nombre del reino y para facción escribe el nombre de la facción. Por ejemplo: \"/auctioneer tambien Al'Akir-Horde\". La palabra clave \"opuesta\" significa facción opuesta, \"desactivar\" deshabilita la funcionalidad.";
		HelpAskPrice	= "Activa o desactiva AskPrice.";
		HelpAskPriceAd	= "Activa o desactiva el anuncio de AskPrice.";
		HelpAskPriceGuild	= "Responder a peticiones hechas en el chat de hermandad.";
		HelpAskPriceParty	= "Responder a peticiones hechas en el chat de grupo.";
		HelpAskPriceSend	= "Enviar manualmente a un jugador el resultado de una petición de AskPrice.";
		HelpAskPriceSmart	= "Activa o desactiva la comprobación de palabras inteligentes.";
		HelpAskPriceTrigger	= "Cambiar el carácter que activa AskPrice";
		HelpAskPriceVendor	= "Activa o desactiva el envío de información del precio de vendedor.";
		HelpAskPriceWhispers	= "Activa o desactiva la ocultación de todos los susurros salientes de AskPrice.";
		HelpAskPriceWord	= "Añade o modifica las palabras inteligentes personalizadas de AskPrice.";
		HelpAuctionClick	= "Permite hacer Alt-Clic en un objeto en tu bolsa para subastarlo automáticamente.";
		HelpAuctionDuration	= "Establece la duración por defecto de las subastas al abrir el interfaz de la Casa de Subastas";
		HelpAutofill	= "Auto-completar precios cuando se añadan artí­culos a subastar en el panel de la casa de subastas";
		HelpAverage	= "Determina si se muestra el precio medio de subasta de un objeto.";
		HelpBidbroker	= "Muestra subastas de corto o medio plazo de la exploración más reciente en las que puedes pujar y obtener beneficios";
		HelpBidLimit	= "Número máximo de subastas a las que pujar o comprar cuando los botones de Pujar o Comprar son presionados en la pestaña de Explorar Subastas.";
		HelpBroker	= "Muestra las subastas de la exploración más reciente en las que puedes pujar y después revender para obtener beneficios";
		HelpClear	= "Elimina la informacion especificada del artí­culo (debes usar clic-mayúsculas para insertar el/los articulo(s) en el comando) También puedes especificar las palabras claves \"todo\" o \"imagen\"";
		HelpCompete	= "Muestra cualquier subasta explorada recientemente cuyo precio de compra es menor que alguno de tus artí­culos";
		HelpDefault	= "Reajusta una opción de Auctioneer a su valor por defecto. También puedes especificar la palabra clave \"todo\" para reajustar todas las opciones de Auctioneer a sus valores por defecto.";
		HelpDisable	= "Impide que Auctioneer se cargue automáticamente la próxima vez que te conectas";
		HelpEmbed	= "Inserta el texto en la caja de ayuda original del juego (nota: algunas características se desactivan cuando esta opción es seleccionada)";
		HelpEmbedBlank	= "Determina si se muestra una línea en blanco entre la información de la caja de ayuda y la información de subasta cuando el modo integrado está seleccionado";
		HelpFinish	= "Determina si el juego se desconecta o finaliza tras terminar una exploración de la casa de subastas";
		HelpFinishSound	= "Determina si se reproduce un sonido al finalizar una exploración de la casa de subastas";
		HelpLink	= "Selecciona para mostrar el número de enlace del artículo en la caja de ayuda";
		HelpLoad	= "Cambia las opciones de carga de Auctioneer para este personaje";
		HelpLocale	= "Cambia la localización a utilizar para mostrar los mensajes de Auctioneer";
		HelpMedian	= "Determina si se muestra el precio promedio de compra del artículo";
		HelpOnoff	= "Activa y desactiva la información sobre las subastas";
		HelpPctBidmarkdown	= "Determina el porcentaje en el que Auctioneer rebajará las pujas del precio de compra";
		HelpPctMarkup	= "El porcentaje que será incrementado el precio del vendedor cuando no existan otros valores disponibles.";
		HelpPctMaxless	= "Establece el porcentaje máximo que Auctioneer usará para rebajar el precio de mercado antes de rendirse";
		HelpPctNocomp	= "El porcentaje que Auctioneer rebajará sobre el precio de mercado cuando no hay competencia";
		HelpPctUnderlow	= "Establece el porcentaje que Auctioneer rebajará el precio de subasta más bajo";
		HelpPctUndermkt	= "Porcentaje a rebajar sobre el precio de mercado cuando sea imposible vencer a la competencia (debido a sinmáximo)";
		HelpPercentless	= "Muestra cualquier subasta recientemente explorada en la que el precio de compra es un porcentaje menor que el precio de venta más alto.";
		HelpPrintin	= "Selecciona qué ventana va a usar Auctioneer para imprimir su información. Puedes especificar tanto el nombre como el í­ndice de la ventana.";
		HelpProtectWindow	= "Previene que cierres accidentalmente el interfaz de la Casa de Subastas";
		HelpRedo	= "Determina si se muestra un aviso cuando la página de la Casa de Subastas actualmente explorada ha llevado demasiado tiempo de exploración debido al lag del servidor.";
		HelpScan	= "Realiza una exploración de la casa de subastas en la próxima visita, o mientras estás allí (tambien existe un botón en el panel de subastas). Selecciona qué categorías quieres explorar  activando las casillas correspondientes.";
		HelpStats	= "Determina si se muestran los porcentajes de pujas/compras del artí­culo";
		HelpSuggest	= "Determina si se muestra el precio de subasta sugerido para el artí­culo";
		HelpUpdatePrice	= "Actualiza automáticamente el precio de salida de una subasta en la pestaña Publicar Subastas cuando el precio de compra cambia.";
		HelpVerbose	= "Determina si se muestran los promedios y sugerencias en formato extendido (o en una sola línea si es desactivado)";
		HelpWarnColor	= "Determina si se muestra el modelo de precio actual de la casa de subastas (Rebajando un...) en colores intuitivos.";


		-- Section: Post Messages
		FrmtNoEmptyPackSpace	= "¡No se encontró espacio en tu inventario para crear la subasta!";
		FrmtNotEnoughOfItem	= "¡No se encontró suficiente %s para crear la subasta!";
		FrmtPostedAuction	= "Se creó una subasta de %s (x%d)";
		FrmtPostedAuctions	= "Se crearon %d subastas de %s (x%d)";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "OfertaActual";
		FrmtBidbrokerDone	= "Corredor de pujas finalizado";
		FrmtBidbrokerHeader	= "Beneficio Mínimo: %s, PMV = 'Precio Máximo de Venta'";
		FrmtBidbrokerLine	= "%s, Último(s) %s visto(s), PMV: %s, %s: %s, Benef: %s, Tiempo: %s";
		FrmtBidbrokerMinbid	= "pujaMínima";
		FrmtBrokerDone	= "Corredor finalizado";
		FrmtBrokerHeader	= "Beneficio Mínimo: %s, PMV = 'Precio Maximo de Venta'";
		FrmtBrokerLine	= "%s, Último(s) %s visto(s), PMV: %s, C: %s, Benef: %s";
		FrmtCompeteDone	= "Subastas compitiendo finalizado.";
		FrmtCompeteHeader	= "Subastas compitiendo por al menos %s debajo por artí­culo.";
		FrmtCompeteLine	= "%s, Puja: %s, C %s contra %s, %s menos";
		FrmtHspLine	= "El Precio Máximo de Venta para un %s es: %s";
		FrmtLowLine	= "%s, C: %s, Vendedor: %s, Por uno: %s, Menor al promedio: %s";
		FrmtMedianLine	= "De los últimos(s) %d vistos, el precio medio de compra para 1 %s es: %s";
		FrmtNoauct	= "No se hallaron subastas para el artí­culo: %s";
		FrmtPctlessDone	= "Porcentajes menores finalizado.";
		FrmtPctlessHeader	= "Porcentaje bajo el Precio Maximo de Venta (PMV): %d%%";
		FrmtPctlessLine	= "%s, Último(s) %d visto(s), PMV: %s, C: %s, Benef: %s, menos %s";


		-- Section: Scanning Messages
		AuctionDefunctAucts	= "Subastas terminadas eliminadas: %s";
		AuctionDiscrepancies	= "Discrepancias: %s";
		AuctionNewAucts	= "Nuevas subastas exploradas: %s";
		AuctionPageN	= "Auctioneer: Explorando \"%s\" página %d de %d\nSubastas por segundo: %s\nTiempo restante estimado: %s\nAñadido a imagen: %s";
		AuctionScanDone	= "Auctioneer: La exploración de las subastas ha finalizado";
		AuctionScanNexttime	= "Auctioneer realizará una exploración completa de las subastas la próxima vez que hables con un subastador.";
		AuctionScanNocat	= "Debes tener al menos una categoría seleccionada para poder explorar.";
		AuctionScanRedo	= "La página actual ha llevado más de %d segundos para ser completada. Reintentando la página.";
		AuctionScanStart	= "Auctioneer: Explorando \"%s\" página 1...";
		AuctionTotalAucts	= "Total de subastas exploradas: %s";
		AuctionUpdatedAucts	= "Subastas actualizadas/cambiadas: %s";


		-- Section: Tooltip Messages
		FrmtInfoAlsoseen	= "Visto %d veces en %s";
		FrmtInfoAverage	= "%s min/%s C (%s puja)";
		FrmtInfoBidMulti	= "Pujas (%s%s c/u)";
		FrmtInfoBidOne	= " %s con pujas";
		FrmtInfoBidrate	= "%d%% tienen pujas, %d%% tienen precio de compra";
		FrmtInfoBuymedian	= "Promedio de precio de compra";
		FrmtInfoBuyMulti	= "  Compra (%s%s c/u)";
		FrmtInfoBuyOne	= " %s con opción a compra";
		FrmtInfoForone	= "Por 1: %s min/%s OC (%s puja) [en %d's]";
		FrmtInfoHeadMulti	= "Promedios para %d artí­culos:";
		FrmtInfoHeadOne	= "Promedios para este artí­culo:";
		FrmtInfoHistmed	= "Último(s) %d, promedio de precio de compra (c/u)";
		FrmtInfoMinMulti	= "  Puja inicial (%s c/u)";
		FrmtInfoMinOne	= "  Puja inicial";
		FrmtInfoNever	= "Nunca visto en %s";
		FrmtInfoSeen	= "Visto un total de %d veces en subasta";
		FrmtInfoSgst	= "Precio sugerido: %s min/%s compra";
		FrmtInfoSgststx	= "Precio sugerido para su lote de %d: %s min/%s compra";
		FrmtInfoSnapmed	= "Explorados %d, promedio de precio de compra (c/u)";
		FrmtInfoStacksize	= "Tamaño promedio del paquete: %d artÃ­culos";


		-- Section: User Interface
		BuySortTooltip	= "Muestra la página de resultados por precio de compra (mantén pulsado MAYÚSCULAS para ordenarlos por nombre de artículo)";
		ClearTooltip	= "Limpia cualquier parámetro personalizado de los campos de búsqueda.";
		FrmtLastSoldOn	= "Última venta en %s";
		RefreshTooltip	= "Realiza de nuevo la búsqueda en el número de página actual.";
		UiBid	= "Pujar";
		UiBidHeader	= "Pujas";
		UiBidPerHeader	= "Pujas c/u";
		UiBuyout	= "Comprar";
		UiBuyoutHeader	= "Compras";
		UiBuyoutPerHeader	= "Compras c/u";
		UiBuyoutPriceLabel	= "Precio de Compra:";
		UiBuyoutPriceTooLowError	= "(Demasiado Bajo)";
		UiCategoryLabel	= "Restricción de Categoría:";
		UiDepositLabel	= "Depósito:";
		UiDurationLabel	= "Duración:";
		UiItemLevelHeader	= "Nivel";
		UiMakeFixedPriceLabel	= "Hacer precio fijo";
		UiMaxError	= "(%d Max)";
		UiMaximumPriceLabel	= "Precio Máximo:";
		UiMaximumTimeLeftLabel	= "Tiempo Restante Máximo:";
		UiMinimumBidPercentLabel	= "Mín. Puja %:";
		UiMinimumPercentLessShortLabel	= "Mín. Pct:";
		UiMinimumProfitLabel	= "Beneficio Mínimo:";
		UiMinimumQualityLabel	= "Calidad Mínima:";
		UiMinimumUndercutLabel	= "Rebaja Mínima:";
		UiNameHeader	= "Nombre";
		UiNoPendingBids	= "¡Todas las peticiones de puja completadas!";
		UiNotEnoughError	= "(No Hay Suficiente)";
		UiPendingBidInProgress	= "1 petición de puja en marcha...";
		UiPendingBidsInProgress	= "%d peticiones de puja en marcha...";
		UiPercentLessHeader	= "Pct";
		UiPost	= "Publicar";
		UiPostAuctions	= "Publicar Subastas";
		UiPriceBasedOnLabel	= "Precio Basado En:";
		UiPriceModelAuctioneer	= "Precio de Auctioneer";
		UiPriceModelCustom	= "Precio Personalizado";
		UiPriceModelFixed	= "Precio Fijo";
		UiPriceModelLastSold	= "Último Precio Vendido";
		UiProfitHeader	= "Beneficio";
		UiProfitPerHeader	= "Beneficio c/u";
		UiQuantityHeader	= "Cantidad";
		UiQuantityLabel	= "Cantidad:";
		UiRemoveSearchButton	= "Borrar";
		UiSavedSearchLabel	= "Búsquedas guardadas:";
		UiSaveSearchButton	= "Guardar";
		UiSaveSearchLabel	= "Guardar esta búsqueda";
		UiSearch	= "Buscar";
		UiSearchAuctions	= "Buscar Subastas";
		UiSearchDropDownLabel	= "Buscar:";
		UiSearchForLabel	= "Buscar por artículo:";
		UiSearchTypeBids	= "Pujas";
		UiSearchTypeBuyouts	= "Compras";
		UiSearchTypeCompetition	= "Competencia";
		UiSearchTypePlain	= "Artículo";
		UiStacksLabel	= "Lotes";
		UiStackTooBigError	= "(Lote Demasiado Grande)";
		UiStackTooSmallError	= "(Lote Demasiado Pequeño)";
		UiStartingPriceLabel	= "Precio Inicial:";
		UiStartingPriceRequiredError	= "(Requerido)";
		UiTimeLeftHeader	= "Tiempo restante";
		UiUnknownError	= "(Desconocido)";

	};

	frFR = {


		-- Section: AskPrice Messages
		AskPriceAd	= "Prix de la pile pour %sx[LienItem] (x=quantité)";
		FrmtAskPriceBuyoutMedianHistorical	= "%sAchat immédiat - historique médian: %s%s";
		FrmtAskPriceBuyoutMedianSnapshot	= "%sAchat immédiat - médian dernier scan: %s%s";
		FrmtAskPriceDisable	= "Désactiver l'option Demande Prix %s";
		FrmtAskPriceEach	= "(%s chaque)";
		FrmtAskPriceEnable	= "Activer l'option Demande Prix %s";
		FrmtAskPriceVendorPrice	= "%sVente au marchand pour : %s%s";


		-- Section: Auction Messages
		FrmtActRemove	= "Suppression de %s de l'image de l'HV.";
		FrmtAuctinfoHist	= "%d historique";
		FrmtAuctinfoLow	= "Prix le plus bas";
		FrmtAuctinfoMktprice	= "Prix du marché";
		FrmtAuctinfoNolow	= "Objet non détecté à la dernière analyse";
		FrmtAuctinfoOrig	= "Prix de départ";
		FrmtAuctinfoSnap	= "%d à la dernière analyse";
		FrmtAuctinfoSugbid	= "Mise à prix";
		FrmtAuctinfoSugbuy	= "AI suggéré";
		FrmtWarnAbovemkt	= "Concurrence au-dessus du marché";
		FrmtWarnMarkup	= "Prix marchand + %s%%";
		FrmtWarnMyprice	= "Utiliser mon prix actuel";
		FrmtWarnNocomp	= "Aucune concurrence";
		FrmtWarnNodata	= "Prix de vente maximum inconnu";
		FrmtWarnToolow	= "Plus bas prix pratiquable";
		FrmtWarnUndercut	= "Moins cher de %s%%";
		FrmtWarnUser	= "Prix défini par l'utilisateur";


		-- Section: Bid Messages
		FrmtAlreadyHighBidder	= "Déjà le plus haut enchérisseur sur l'enchère : %s (x%d)";
		FrmtBidAuction	= "Offre sur l'enchère : %s (x%d)";
		FrmtBidQueueOutOfSync	= "Erreur : File d'enchère désynchronisée";
		FrmtBoughtAuction	= "Achat direct : %s (x%d)";
		FrmtMaxBidsReached	= "D'autres enchères de %s (x%d) trouvées, mais nombre limite d'enchères atteint (%d)";
		FrmtNoAuctionsFound	= "Aucune enchère trouvée : %s (x%d)";
		FrmtNoMoreAuctionsFound	= "Plus d'autres enchères trouvées : %s (x%d)";
		FrmtNotEnoughMoney	= "Pas assez d'argent pour l'enchère : %s (x%d)";
		FrmtSkippedAuctionWithHigherBid	= "Ignore enchères avec une offre plus élevée : %s (x%d)";
		FrmtSkippedAuctionWithLowerBid	= "Ignore enchères avec l'offre inférieure : %s (x%d)";
		FrmtSkippedBiddingOnOwnAuction	= "Ignore mes propres enchères : %s (x%d)";
		UiProcessingBidRequests	= "Traitement des enchères...";


		-- Section: Command Messages
		ConstantsCritical	= "CRITIQUE: Le fichier SavedVariables d'Auctioneer est %.3f%% plein";
		ConstantsMessage	= "Le fichier SavedVariables d'Auctioneer est %.3f%% plein";
		ConstantsWarning	= "ATTENTION: Le fichier SavedVariables d'Auctioneer est %.3f%% plein";
		FrmtActClearall	= "Effacer toutes les données pour l'enchère %s";
		FrmtActClearFail	= "Objet introuvable : %s";
		FrmtActClearOk	= "Effacer les infos de l'objet : %s";
		FrmtActClearsnap	= "Effacement de l'image actuelle de l'Hôtel des Ventes";
		FrmtActDefault	= "Réinitialisation de l'option %s à sa valeur par défaut";
		FrmtActDefaultall	= "Toutes les options d'Auctioneer ont été réinitialisées à leur valeur par défaut";
		FrmtActDisable	= "Les données de %s ne sont pas affichées";
		FrmtActEnable	= "Les données de %s sont affichées";
		FrmtActSet	= "Valeur de %s changée en %s";
		FrmtActUnknown	= "Commande inconnue : %s";
		FrmtAuctionDuration	= "La durée par défaut des enchères est désormais de %s";
		FrmtAutostart	= "Enchère automatique pour %s: mise à prix %s, achat immédiat %s (%dh) %s";
		FrmtFinish	= "Après la fin d'un scan, nous allons %s \n";
		FrmtPrintin	= "Les messages d'Auctioneer s'afficheront désormais dans la fenêtre de dialogue \"%s\"";
		FrmtProtectWindow	= "Protection de la fenêtre de l'Hôtel des Ventes : \"%s\"";
		FrmtUnknownArg	= "'%s' : argument invalide pour '%s'";
		FrmtUnknownLocale	= "La langue que vous avez spécifiée ('%s') est inconnue. Les langues valides sont :";
		FrmtUnknownRf	= "'%s' n'est pas un paramètre valide, doit être au format [Royaume]-[Faction] ! Ex : Medhiv-Alliance";


		-- Section: Command Options
		OptAlso	= "(royaume-faction|oppose|allie|neutre)";
		OptAskPriceSend	= "<NomJoueur> <Requête de Prix>";
		OptAuctionDuration	= "(court|2h|8h|24h)";
		OptBidbroker	= "<gain_argent>";
		OptBidLimit	= "<nombre>";
		OptBroker	= "<gain_argent>";
		OptClear	= "([Objet]|tout|capture)";
		OptCompete	= "<argent_moins>";
		OptDefault	= "(<option>|tout)";
		OptFinish	= "(arret|deconnecter|quitter|rechargeIU)";
		OptLocale	= "<langue>";
		OptPctBidmarkdown	= "<pourcentage>";
		OptPctMarkup	= "<pourcentage>";
		OptPctMaxless	= "<pourcentage>";
		OptPctNocomp	= "<pourcentage>";
		OptPctUnderlow	= "<pourcentage>";
		OptPctUndermkt	= "<pourcentage>";
		OptPercentless	= "<pourcentage>";
		OptPrintin	= "(<IndexFenetre>[Nombre]|<NomFenetre>[Chaine])";
		OptProtectWindow	= "(jamais|analyse|toujours)";
		OptScale	= "<facteur_échelle>";
		OptScan	= "<parametre_d_analyse>";


		-- Section: Commands
		CmdAlso	= "aussi";
		CmdAlsoOpposite	= "oppose";
		CmdAlt	= "alt";
		CmdAskPriceAd	= "annonce";
		CmdAskPriceGuild	= "guilde";
		CmdAskPriceParty	= "groupe";
		CmdAskPriceSend	= "envoi";
		CmdAskPriceSmart	= "intelligent";
		CmdAskPriceSmartWord1	= "que";
		CmdAskPriceSmartWord2	= "vaut";
		CmdAskPriceTrigger	= "declencheur";
		CmdAskPriceVendor	= "vendeur";
		CmdAskPriceWhispers	= "chuchotements";
		CmdAskPriceWord	= "mot-cle";
		CmdAuctionClick	= "enchere-clic";
		CmdAuctionDuration	= "duree-enchere";
		CmdAuctionDuration0	= "dernier";
		CmdAuctionDuration1	= "2h";
		CmdAuctionDuration2	= "8h";
		CmdAuctionDuration3	= "24h";
		CmdAutofill	= "remplissage-auto";
		CmdBidbroker	= "agent-enchere";
		CmdBidbrokerShort	= "ae";
		CmdBidLimit	= "limite-offre";
		CmdBroker	= "agent";
		CmdClear	= "effacer";
		CmdClearAll	= "tout";
		CmdClearSnapshot	= "capture";
		CmdCompete	= "concurrence";
		CmdCtrl	= "ctrl";
		CmdDefault	= "defaut";
		CmdDisable	= "desactiver";
		CmdEmbed	= "integrer";
		CmdFinish	= "fin";
		CmdFinish0	= "arret";
		CmdFinish1	= "deconnection";
		CmdFinish2	= "quitter";
		CmdFinish3	= "rechargeIU";
		CmdFinishSound	= "son-final";
		CmdHelp	= "aide";
		CmdLocale	= "langue";
		CmdOff	= "arret";
		CmdOn	= "marche";
		CmdPctBidmarkdown	= "pct-baisse";
		CmdPctMarkup	= "pct-hausse";
		CmdPctMaxless	= "pct-baissemaxi";
		CmdPctNocomp	= "pct-pasdeconcurrence";
		CmdPctUnderlow	= "pct-sousbas";
		CmdPctUndermkt	= "pct-sousmarche";
		CmdPercentless	= "pct-moins";
		CmdPercentlessShort	= "pm";
		CmdPrintin	= "afficher-dans";
		CmdProtectWindow	= "proteger-fenetre";
		CmdProtectWindow0	= "jamais";
		CmdProtectWindow1	= "analyse";
		CmdProtectWindow2	= "toujours";
		CmdScan	= "analyse";
		CmdShift	= "shift";
		CmdToggle	= "active-desactive";
		CmdUpdatePrice	= "actualiser-prix";
		CmdWarnColor	= "couleur-avertissement";
		ShowAverage	= "voir-moyenne";
		ShowEmbedBlank	= "voir-ligneblanche-integree";
		ShowLink	= "voir-lien";
		ShowMedian	= "voir-median";
		ShowRedo	= "voir-avertissement";
		ShowStats	= "voir-stats";
		ShowSuggest	= "voir-suggestion";
		ShowVerbose	= "voir-detail";


		-- Section: Config Text
		GuiAlso	= "Afficher aussi les données pour";
		GuiAlsoDisplay	= "Affichage des données pour %s";
		GuiAlsoOff	= "Ne plus afficher les données provenant d'autres royaumes/factions.";
		GuiAlsoOpposite	= "Afficher maintenant les données de la faction opposée.";
		GuiAskPrice	= "Activer DemandePrix";
		GuiAskPriceAd	= "Envoyer les dispositifs d'annonce";
		GuiAskPriceGuild	= "Répondre aux demandes sur le canal de guilde";
		GuiAskPriceHeader	= "Options de DemandePrix";
		GuiAskPriceHeaderHelp	= "Changer le comportement de DemandePrix";
		GuiAskPriceParty	= "Répondre aux requêtes sur le canal de groupe";
		GuiAskPriceSmart	= "Utiliser mots-clés intelligents";
		GuiAskPriceTrigger	= "Activateur de DemandePrix";
		GuiAskPriceVendor	= "Envoyer les info du vendeur";
		GuiAskPriceWhispers	= "Montrer chuchotements envoyés";
		GuiAskPriceWord	= "Mot-clé intelligent personnalisé %d";
		GuiAuctionDuration	= "Durée de l'enchère par défaut";
		GuiAuctionHouseHeader	= "Fenêtre de l'Hôtel des Ventes";
		GuiAuctionHouseHeaderHelp	= "Change le comportement de la fenêtre de l'Hôtel des Ventes";
		GuiAutofill	= "Remplit automatiquement les prix à l'HV";
		GuiAverages	= "Voir moyennes";
		GuiBidmarkdown	= "Pourcentage de baisse d'enchère";
		GuiClearall	= "Effacer toutes les données d'Auctioneer";
		GuiClearallButton	= "Tout effacer";
		GuiClearallHelp	= "Cliquer ici pour effacer toutes les donnèes d'Auctioneer pour le royaume actuel.";
		GuiClearallNote	= "pour la faction courante du serveur";
		GuiClearHeader	= "Effacer les données";
		GuiClearHelp	= "Effacement des données d'Auctioneer. Sélectionnez toutes les données ou l'image courante. ATTENTION : Ces opèrations sont irreversibles.";
		GuiClearsnap	= "Effacer les données de l'image";
		GuiClearsnapButton	= "Effacer l'image";
		GuiClearsnapHelp	= "Cliquer ici pour effacer les données de la dernière image d'Auctioneer";
		GuiDefaultAll	= "Réinitialisation de toutes les options d'Auctioneer";
		GuiDefaultAllButton	= "Réinitialiser tout";
		GuiDefaultAllHelp	= "Cliquer ici pour réinitialiser toutes les options d'Auctioneer. ATTENTION : Cette opération est irréversible.";
		GuiDefaultOption	= "Réinitialiser ce paramètre";
		GuiEmbed	= "Intégrer les informations dans la bulle d'aide originale";
		GuiEmbedBlankline	= "Afficher une ligne blanche dans la bulle d'aide";
		GuiEmbedHeader	= "Intégrer";
		GuiFinish	= "Après la fin d'une analyse";
		GuiFinishSound	= "Jouer un son à la fin d'une analyse";
		GuiLink	= "Montrer ID du Lien";
		GuiLoad	= "Charger Auctioneer";
		GuiLoad_Always	= "toujours";
		GuiLoad_AuctionHouse	= "à l'Hôtel des Ventes";
		GuiLoad_Never	= "jamais";
		GuiLocale	= "Changer la langue en";
		GuiMainEnable	= "Activer Auctioneer";
		GuiMainHelp	= "Contient les réglages d'Auctionner, un AddOn affichant les infos des objets et analyse les données de vente aux enchères. Cliquez le bouton \"Analyse\" de l'Hôtel des Ventes pour récupérer les données.";
		GuiMarkup	= "Pourcentage de hausse du prix des vendeurs PNJ";
		GuiMaxless	= "Pourcentage maximal de remise par rapport au marché";
		GuiMedian	= "Voir prix médians";
		GuiNocomp	= "Pourcentage de remise en cas de monopole";
		GuiNoWorldMap	= "Auctioneer : affichage de la carte du monde bloquée";
		GuiOtherHeader	= "Autres Options";
		GuiOtherHelp	= "Options diverses d'Auctioneer";
		GuiPercentsHeader	= "Pourcentage de tolérance d'Auctioneer";
		GuiPercentsHelp	= "ATTENTION: Les options suivantes sont pour les utilisateurs expérimentés SEULEMENT. La Modification de ces valeurs change l'aggressivité d'Auctioneer sur le niveau de marge nécessaire pour la profitabilité.";
		GuiPrintin	= "Sélectionner la fenêtre de discussion voulue";
		GuiProtectWindow	= "Empêche la fermeture accidentelle de la fenêtre de l'HV";
		GuiRedo	= "Afficher l'avertissement d'analyse trop longue";
		GuiReloadui	= "Recharger l'interface utilisateur";
		GuiReloaduiButton	= "RechargerUI";
		GuiReloaduiFeedback	= "Redémarrage de l'UI de WoW";
		GuiReloaduiHelp	= "Cliquer ici pour recharger l'Interface Utilisateur (UI) de WoW après avoir changé la langue afin de prendre en compte les changements dans cet écran de configuration. Remarque : cette opération peut prendre quelques minutes.";
		GuiRememberText	= "Mémoriser le prix";
		GuiStatsEnable	= "Voir Statistiques";
		GuiStatsHeader	= "Statistiques du Prix de l'Objet";
		GuiStatsHelp	= "Afficher les statistiques suivantes dans la bulle d'aide";
		GuiSuggest	= "Voir les Prix Suggérés";
		GuiUnderlow	= "Réduire le prix de l'enchère la plus basse";
		GuiUndermkt	= "En dessous du marché si inférieur";
		GuiVerbose	= "Mode détaillé";
		GuiWarnColor	= "Couleur du modèle de prix";


		-- Section: Conversion Messages
		MesgConvert	= "Conversion de la base de données d'Auctioneer. Veuillez sauvegarder votre fichier SavedVariables\\Auctioneer.lua avant. %s%s";
		MesgConvertNo	= "Désactiver Auctioneer";
		MesgConvertYes	= "Convertir";
		MesgNotconverting	= "Auctioneer ne convertit pas votre base de données, mais ne fonctionnera pas tant que vous ne l'aurez pas fait.";


		-- Section: Game Constants
		SubTypeBag	= "Sac";
		TimeLong	= "Longue";
		TimeMed	= "Moyenne";
		TimeShort	= "Courte";
		TimeVlong	= "Très Longue";


		-- Section: Generic Messages
		ConfirmBidBuyout	= "Etes-vous sûr que vous voulez %s\n%dx%s pour:";
		DisableMsg	= "Désactiver le chargement automatique d'Auctioneer";
		FrmtWelcome	= "Auctioneer v%s est chargé";
		MesgNotLoaded	= "Auctioneer n'est pas chargé. Tapez /auctioneer pour plus d'informations.";
		ScanCancel	= "Scan annulé";
		ScanComplete	= "Scan terminé";
		ScanFailed	= "Scan raté";
		StatAskPriceOff	= "La fonction DemandePrix est désormais désactivée.";
		StatAskPriceOn	= "La fonction DemandePrix est désormais activée.";
		StatOff	= "Aucune enchère à afficher";
		StatOn	= "Afficher la configuration des enchères";
		UIScanCanceled	= "Auctioneer: Scan d'actions annulé";
		UIScanComplete	= "Auctioneer: Scan d'actions terminé";
		UIScanFailed	= "Auctioneer: Scan d'actions raté";


		-- Section: Generic Strings
		TextCombat	= "Combat";
		TextGeneral	= "Général";
		TextNone	= "Aucun";
		TextScan	= "Analyser";
		TextUsage	= "Utilisation :";


		-- Section: Help Text
		HelpAlso	= "Afficher également les données d'un autre serveur dans la bulle d'aide. Pour le royaume, insérer le nom du royaume et pour la faction, le nom de la faction. Par exemple : \"/auctioneer additionnel Medhiv-Horde\". Le mot-clef \"opposé\" indique la faction opposée, \"arrêt\" désactive cette fonctionnalité.";
		HelpAskPrice	= "Activer ou désactiver DemandePrix.";
		HelpAskPriceAd	= "Activer ou désactiver la nouvelle fonction d'annonce DemandePrix.";
		HelpAskPriceGuild	= "Répondre aux demandes faites dans le canal de guilde.";
		HelpAskPriceParty	= "Répondre aux demandes faites dans le canal de groupe.";
		HelpAskPriceSend	= "Envoi manuel au joueur du résultat d'une requête de prix";
		HelpAskPriceSmart	= "Activer ou désactiver la vérification de MotClé";
		HelpAskPriceTrigger	= "Changer la clef d'amorcage de DemandePrix.";
		HelpAskPriceVendor	= "Activer ou désactiver l'envoie des infos de prix au marchand";
		HelpAskPriceWhispers	= "Cacher ou non les chuchotements envoyés par DemandePrix\n";
		HelpAskPriceWord	= "Ajouter ou modifier un mot-clé intelligent personnalisé de DemandePrix.";
		HelpAuctionClick	= "ALT-Clic d'un objet de votre sac pour le placer automatiquement aux enchères";
		HelpAuctionDuration	= "Définit la durée d'enchère par défaut lors de l'ouverture de la fenêtre de l'Hôtel de Ventes";
		HelpAutofill	= "Active le remplissage automatique du prix de vente lors de la mise aux enchères d'un objet dans la fenêtre de l'Hôtel des Ventes";
		HelpAverage	= "Choisir d'afficher le prix moyen d'enchère des objets";
		HelpBidbroker	= "Afficher les enchères à court ou moyen terme de l'analyse la plus récente sur lesquelles enchérir pour revendre avec bénéfice";
		HelpBidLimit	= "Nombre maximum d'enchères sur lesquelless enchérir ou acheter immédiatement lorsque le bouton Enchérir ou Acheter est sélectionné dans l'onglet Recherche Enchères";
		HelpBroker	= "Montrer toutes les enchères de l'analyse la plus récente sur lesquelles enchérir pour revendre avec bénéfice";
		HelpClear	= "Effacer les données d'un objet spécifié (vous devez 'SHIFT-cliquer' l'objet dans la ligne de commande) Vous pouvez également spécifier les mots-clés \"tout\" ou \"capture\"";
		HelpCompete	= "Montrer parmi les enchères récemment scannées celles dont le prix d'achat immédiat est inférieur à celui d'un de vos objets.";
		HelpDefault	= "Réinitialise une option d'Auctionner à sa valeur par défaut. Vous pouvez également spécifier le mot-clé \"tout\" pour réinitialiser toutes les options d'Autionneer à leurs valeurs par défaut.";
		HelpDisable	= "Empêche le chargement automatique d'Auctioneer lors de votre prochaine connexion";
		HelpEmbed	= "Intègre le texte dans les bulles d'aide originale (remarque: certaines fonctions seront désactivées)";
		HelpEmbedBlank	= "Choisir d'afficher une ligne vide entre les infos de bulle d'aide et d'enchère en mode intégré";
		HelpFinish	= "Se déconnecter ou sortir du jeu après avoir fini un scan de l'Hôtel des ventes";
		HelpFinishSound	= "Détermine si il faut jouer un son à la fin d'une analyse de l'Hôtel des ventes";
		HelpLink	= "Choisir d'afficher l'identifiant du lien dans la bulle d'aide";
		HelpLoad	= "Change les réglages de chargement pour ce personnage";
		HelpLocale	= "Choisir la langue dans laquelle afficher les messages d'Auctioneer";
		HelpMedian	= "Choisir d'afficher le prix d'achat immédiat moyen";
		HelpOnoff	= "Active ou désactive l'affichage des données des enchères";
		HelpPctBidmarkdown	= "Définit le pourcentage de réduction par rapport au prix d'achat immédiat utilisé par Auctioneer";
		HelpPctMarkup	= "Pourcentage à utiliser par rapport au prix des marchands quand aucune autre donnée n'est disponible";
		HelpPctMaxless	= "Définit la réduction maximale en pourcentage qu'Auctionner utilisera par rapport au prix du marché avant d'abandonner";
		HelpPctNocomp	= "Pourcentage qu'Auctionner doit utiliser pour générer  une réduction par rapport au prix du marché quand il n'y a pas de concurrence";
		HelpPctUnderlow	= "Définit le pourcentage de réduction par rapport au prix le plus bas de l'Hôtel des ventes qu'Auctionner doit utiliser ";
		HelpPctUndermkt	= "Pourcentage de réduction par rapport au prix du marché quand la concurrence ne peut être battue (à cause du maxbas)";
		HelpPercentless	= "Afficher parmi les enchères récemment scannées celles dont le prix d'achat immédiat est inférieur d'un certain pourcentage au prix de vente maximum";
		HelpPrintin	= "Choisir quelle fenêtre affichera les messages d'Auctioneer. Vous pouvez spécifier le nom de la fenêtre ou son indice.";
		HelpProtectWindow	= "Empêche la fermeture accidentelle de la fenêtre de l'Hôtel des Ventes";
		HelpRedo	= "Choisir d'afficher un avertissement lorsque l'analyse de la page actuelle de l'Hôtel des Ventes prend trop longtemps en raison d'une latence du serveur.";
		HelpScan	= "Exécute une analyse de l'Hôtel des ventes lors de votre prochaine visite, ou immédiatement si vous y êtes (il y a également un bouton dans l'interface de l'Hôtel des ventes). Choisissez les catégories que vous souhaitez analyser avec les cases à cocher.";
		HelpStats	= "Choisir d'afficher les pourcentages d'enchère/achat immédiat";
		HelpSuggest	= "Choisir d'afficher le prix suggéré pour l'objet";
		HelpUpdatePrice	= "Dans l'onglet 'Ventes avancées', mettre à jour automatiquement le prix de départ quand le prix d'achat directe change.";
		HelpVerbose	= "Choisir d'afficher les moyennes et les suggestions de manière détaillée (ou \"arrêt\" pour les afficher sur une seule ligne)";
		HelpWarnColor	= "Choisir de montrer le modèle de prix de l'HV courant (en dessous du marché, ...) avec des couleurs intuitives.";


		-- Section: Post Messages
		FrmtNoEmptyPackSpace	= "Aucun emplacement vide n'a été trouvé pour créer l'enchère !";
		FrmtNotEnoughOfItem	= "Pas assez de %s trouvé pour créer l'enchère !";
		FrmtPostedAuction	= "Créé 1 enchère de %s (x%d)";
		FrmtPostedAuctions	= "Créé %d enchères de %s (x%d)";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "EnchAct";
		FrmtBidbrokerDone	= "L'agent d'enchère à terminé";
		FrmtBidbrokerHeader	= "Gain minimum : %s, PVM = 'Prix de Vente Maximum'";
		FrmtBidbrokerLine	= "%s, Derniers %s vus, PVM : %s, %s : %s, Gain : %s, Temps : %s";
		FrmtBidbrokerMinbid	= "EnchMin";
		FrmtBrokerDone	= "L'agent a terminé";
		FrmtBrokerHeader	= "Gain Minimum : %s, PVM = 'Prix de Vente Maximum'";
		FrmtBrokerLine	= "%s, Derniers %s vus, PVM : %s, AI : %s, Gain : %s";
		FrmtCompeteDone	= "Enchères en concurrence terminées.";
		FrmtCompeteHeader	= "Enchères en concurrence d'au moins %s de moins par objet.";
		FrmtCompeteLine	= "%s, Ench : %s, AI %s vs %s, %s de moins";
		FrmtHspLine	= "Le prix de vente maximum pour un %s est de : %s";
		FrmtLowLine	= "%s, AI : %s, Vendeur : %s, L'unitée : %s, Inférieur au médian de : %s";
		FrmtMedianLine	= "Des derniers %d vus, l'achat moyen pour 1 %s est de : %s";
		FrmtNoauct	= "Pas d'enchères trouvées pour l'objet : %s";
		FrmtPctlessDone	= "Pourcentage inférieur terminé.";
		FrmtPctlessHeader	= "Réduction par rapport au PVM : %d%%";
		FrmtPctlessLine	= "%s, Derniers %d vus, PVM : %s, AI : %s, Gain : %s, Moins %s";


		-- Section: Scanning Messages
		AuctionDefunctAucts	= "Ventes terminées retirées : %s";
		AuctionDiscrepancies	= "Ecarts : %s";
		AuctionNewAucts	= "Nouvelles enchères analysées : %s";
		AuctionPageN	= "Auctioneer : analyse en cours, catégorie '%s', \npage %d sur %d,\n%s enchères/s. \nTemps restant estimé : %s";
		AuctionScanDone	= "Auctioneer : analyse terminée";
		AuctionScanNexttime	= "Auctioneer fera une analyse complète de l'Hôtel des Ventes la prochaine fois que vous parlerez à un commissaire-priseur.";
		AuctionScanNocat	= "Vous devez sélectionner au moins une catégorie pour analyser.";
		AuctionScanRedo	= "La page actuelle a mis plus de %d secondes pour être analysée, nouvelle tentative.";
		AuctionScanStart	= "Auctioneer : analyse '%s', page 1";
		AuctionTotalAucts	= "Nb total d'enchères analysées : %s";
		AuctionUpdatedAucts	= "Actions changées/mises à jour: %s";


		-- Section: Tooltip Messages
		FrmtInfoAlsoseen	= "Vu %d fois à %s";
		FrmtInfoAverage	= "%s min/%s AI (%s enchère)";
		FrmtInfoBidMulti	= "Offre (%s%s l'unité)";
		FrmtInfoBidOne	= "Offre (%s)";
		FrmtInfoBidrate	= "%d%% avec offre, %d%% avec AI";
		FrmtInfoBuymedian	= "Achat Immédiat médian";
		FrmtInfoBuyMulti	= "Achat immédiat (%s%s l'unité)";
		FrmtInfoBuyOne	= "Achat immédiat (%s)";
		FrmtInfoForone	= "Pour 1 : %s min/%s AI (%s enchère) [par %d]";
		FrmtInfoHeadMulti	= "Moyennes pour %d objets :";
		FrmtInfoHeadOne	= "Moyennes pour cet objet :";
		FrmtInfoHistmed	= "%d derniers vus. AI moyen (l'unité) :";
		FrmtInfoMinMulti	= "Mise à prix initiale (%s l'unité)";
		FrmtInfoMinOne	= "Mise à prix initiale";
		FrmtInfoNever	= "Jamais vu en %s";
		FrmtInfoSeen	= "Vu %d fois aux enchères";
		FrmtInfoSgst	= "Prix suggéré : %s min/%s AI";
		FrmtInfoSgststx	= "Prix suggéré pour votre pile de %d : %s min/%s AI";
		FrmtInfoSnapmed	= "Vu %d fois à la dernière analyse, AI moyen (pce) :";
		FrmtInfoStacksize	= "Nombre moyen d'objets par pile : %d";


		-- Section: User Interface
		BuySortTooltip	= "Trier les résultats par prix d'achat (maintenir MAJUSCULE pour tri par nom)";
		ClearTooltip	= "Effacer toute recherche personnalisée des champs";
		FrmtLastSoldOn	= "Dernière vente le %s";
		RefreshTooltip	= "Resoumettre la requête au numéro de page courant";
		UiBid	= "Offre";
		UiBidHeader	= "Offre";
		UiBidPerHeader	= "Offre par";
		UiBuyout	= "Acheter";
		UiBuyoutHeader	= "Achat Immédiat";
		UiBuyoutPerHeader	= "Achat Immédiat par";
		UiBuyoutPriceLabel	= "Prix d'achat :";
		UiBuyoutPriceTooLowError	= "(Trop faible)";
		UiCategoryLabel	= "Restriction de catégorie : \n";
		UiDepositLabel	= "Dépôt :";
		UiDurationLabel	= "Durée :";
		UiItemLevelHeader	= "Niv";
		UiMakeFixedPriceLabel	= "Mémoriser le prix";
		UiMaxError	= "(%d Max)";
		UiMaximumPriceLabel	= "Prix maximum :";
		UiMaximumTimeLeftLabel	= "Temps restant maximum :";
		UiMinimumBidPercentLabel	= "Offre minimale %:";
		UiMinimumPercentLessShortLabel	= "Pourcentage minimal inférieur:";
		UiMinimumProfitLabel	= "Gain minimum : ";
		UiMinimumQualityLabel	= "Qualité minimum :";
		UiMinimumUndercutLabel	= "Marge minimum :";
		UiNameHeader	= "Nom";
		UiNoPendingBids	= "Toutes les offres ont été soumises!";
		UiNotEnoughError	= "(Pas assez)";
		UiPendingBidInProgress	= "1 offre en cours...";
		UiPendingBidsInProgress	= "%d offres en cours...";
		UiPercentLessHeader	= "% de";
		UiPost	= "Vendre";
		UiPostAuctions	= "Vendre";
		UiPriceBasedOnLabel	= "Prix Basé sur :";
		UiPriceModelAuctioneer	= "Prix Auctioneer";
		UiPriceModelCustom	= "Prix personnalisé";
		UiPriceModelFixed	= "Prix mémorisé";
		UiPriceModelLastSold	= "Dernier prix de vente";
		UiProfitHeader	= "Bénéfices";
		UiProfitPerHeader	= "Bénéfices par";
		UiQuantityHeader	= "Qté";
		UiQuantityLabel	= "Quantité :";
		UiRemoveSearchButton	= "Supprimer";
		UiSavedSearchLabel	= "Recherches sauvegardées :";
		UiSaveSearchButton	= "Sauvegarder";
		UiSaveSearchLabel	= "Sauvegarder cette recherche :";
		UiSearch	= "Recherche";
		UiSearchAuctions	= "Recherche Enchères";
		UiSearchDropDownLabel	= "Recherche :";
		UiSearchForLabel	= "Recherche d'un objet :";
		UiSearchTypeBids	= "Offres";
		UiSearchTypeBuyouts	= "Achats Immédiats";
		UiSearchTypeCompetition	= "Concurrence ";
		UiSearchTypePlain	= "Objet";
		UiStacksLabel	= "Piles";
		UiStackTooBigError	= "(Pile trop grosse)";
		UiStackTooSmallError	= "(Pile trop petite)";
		UiStartingPriceLabel	= "Prix de départ :";
		UiStartingPriceRequiredError	= "(Requis)";
		UiTimeLeftHeader	= "Temps restant";
		UiUnknownError	= "(Inconnu)";

	};

	itIT = {


		-- Section: AskPrice Messages
		AskPriceAd	= "Prezzo di uno stack da %sx[ItemLink]";
		FrmtAskPriceBuyoutMedianHistorical	= "%sBuyout-medio degli scan: %s%s";
		FrmtAskPriceBuyoutMedianSnapshot	= "%sBuyout-medio ultimo scan: %s%s";
		FrmtAskPriceDisable	= "Disabilita l'opzione Prezzo Richiesto di %s";
		FrmtAskPriceEach	= "(%s l'una)";
		FrmtAskPriceEnable	= "Attivando l'opzione %s di AskPrice";
		FrmtAskPriceVendorPrice	= "%sVendi al vendor per: %s%s";


		-- Section: Auction Messages
		FrmtActRemove	= "Asta %s rimossa dalla lista corrente.";
		FrmtAuctinfoHist	= "%d storico";
		FrmtAuctinfoLow	= "Prezzo minimo";
		FrmtAuctinfoMktprice	= "Prezzo di mercato";
		FrmtAuctinfoNolow	= "Oggetto non visto nell'ultimo scan";
		FrmtAuctinfoOrig	= "Offerta originale";
		FrmtAuctinfoSnap	= "%d ultimo scan";
		FrmtAuctinfoSugbid	= "Offerta suggerita";
		FrmtAuctinfoSugbuy	= "Prezzo d'acquisto suggerito";
		FrmtWarnAbovemkt	= "Prezzo superiore alla media di mercato.";
		FrmtWarnMarkup	= "Oltre il prezzo del vendor di %s%%";
		FrmtWarnMyprice	= "Sto usando il mio prezzo attuale";
		FrmtWarnNocomp	= "Nessuna competizione";
		FrmtWarnNodata	= "Nessun dato per HSP";
		FrmtWarnToolow	= "Minimo troppo inferiore al prezzo di mercato";
		FrmtWarnUndercut	= "Prezzo ribassato del %s%%";
		FrmtWarnUser	= "Il prezzo coincide con il prezzo del vendor";


		-- Section: Bid Messages
		FrmtAlreadyHighBidder	= "E' già la piu' alta richiesta all'asta: %s (x%d)";
		FrmtBidAuction	= "Offerta all'asta: %s (x%d)";
		FrmtBidQueueOutOfSync	= "Errore: La coda delle offerte e' fuori sincrono!";
		FrmtBoughtAuction	= "Comprato di Buyout: %s (x%d)";
		FrmtMaxBidsReached	= "Altre aste per %s (x%d) sono state trovate, ma il limite di offerta e' stato raggiunto (%d) ";
		FrmtNoAuctionsFound	= "Nessuna asta trovata: %s (x%d)";
		FrmtNoMoreAuctionsFound	= "Nessun'altra asta trovata: %s (x%d)";
		FrmtNotEnoughMoney	= "Denaro insufficiente per fare un offerta: %s (x%d)";
		FrmtSkippedAuctionWithHigherBid	= "Escluse aste con bid piu' alto: %s (x%d)";
		FrmtSkippedAuctionWithLowerBid	= "Escluse aste con bid piu' basso: %s (x%d)";
		FrmtSkippedBiddingOnOwnAuction	= "Saltata offerta su una propria asta: %s (x%d)";
		UiProcessingBidRequests	= "Analisi delle richieste di bid...";


		-- Section: Command Messages
		FrmtActClearall	= "Sto eliminando tutti i dati per %s";
		FrmtActClearFail	= "Impossibile trovare: %s";
		FrmtActClearOk	= "Rimossi dati per l'oggetto: %s";
		FrmtActClearsnap	= "Sto cancellando la lista attuale.";
		FrmtActDefault	= "Opzione %s riportata al valore predefinito";
		FrmtActDefaultall	= "Tutte le opzioni riportate ai valori predefiniti.";
		FrmtActDisable	= "I dati per %s non sono visualizzati";
		FrmtActEnable	= "I dati per %s sono visualizzati";
		FrmtActSet	= "Opzione %s impostata a '%s'";
		FrmtActUnknown	= "Comando non riconosciuto: '%s'";
		FrmtAuctionDuration	= "Durata predefinita: %s";
		FrmtAutostart	= "Asta automatica per %s minimo, %s buyout(%dh)\n%s";
		FrmtFinish	= "Quando lo scan sia finito, %s";
		FrmtPrintin	= "I messaggi di Auctioneer saranno visualizzati nella chat \"%s\"";
		FrmtProtectWindow	= "Protezione della finestra AH impostata a: %s";
		FrmtUnknownArg	= "'%s' non e' un argomento valido per '%s'";
		FrmtUnknownLocale	= "La lingua specificata ('%s') e' sconosciuta. Lingue valide:";
		FrmtUnknownRf	= "Parametro non valido('%s'). Il parametro deve avere un formato [reame]-[fazione]. Esempio: Al'Akir-Horde";


		-- Section: Command Options
		OptAlso	= "(reame-fazione|opposta)";
		OptAuctionDuration	= "(durata||2h||8h||24h)";
		OptBidbroker	= "<guadagno_silver>";
		OptBidLimit	= "<numero>";
		OptBroker	= "<guadagno_silver>";
		OptClear	= "([Oggetto]|tutto|lista) ";
		OptCompete	= "<silver_in_meno>";
		OptDefault	= "(<opzione>|tutto) ";
		OptFinish	= "(spento||stacca||esci)";
		OptLocale	= "<lingua>";
		OptPctBidmarkdown	= "<percento>";
		OptPctMarkup	= "<percento>";
		OptPctMaxless	= "<percento>";
		OptPctNocomp	= "<percento>";
		OptPctUnderlow	= "<percento>";
		OptPctUndermkt	= "<percento>";
		OptPercentless	= "<percento>";
		OptPrintin	= "(<Indiceframe>[Numero]|<Nomeframe>[Stringa]) ";
		OptProtectWindow	= "(mai||scan||sempre)";
		OptScale	= "<fattore_scala>";
		OptScan	= "parametri di scan";


		-- Section: Commands
		CmdAlso	= "anche";
		CmdAlsoOpposite	= "opposta";
		CmdAlt	= "alt";
		CmdAskPriceAd	= "aggiunto";
		CmdAskPriceGuild	= "gilda";
		CmdAskPriceParty	= "gruppo";
		CmdAskPriceSmart	= "corte";
		CmdAskPriceSmartWord1	= "che";
		CmdAskPriceSmartWord2	= "Ricerca multipla";
		CmdAskPriceTrigger	= "automatismo";
		CmdAskPriceVendor	= "Venditore";
		CmdAskPriceWhispers	= "Whispers";
		CmdAskPriceWord	= "word";
		CmdAuctionClick	= "auction-click";
		CmdAuctionDuration	= "durata-asta";
		CmdAuctionDuration0	= "precedente";
		CmdAuctionDuration1	= "2h";
		CmdAuctionDuration2	= "8h";
		CmdAuctionDuration3	= "24h";
		CmdAutofill	= "auto-riempimento";
		CmdBidbroker	= "Agente d'Offerta";
		CmdBidbrokerShort	= "ao";
		CmdBidLimit	= "limite-offerta";
		CmdBroker	= "Agente";
		CmdClear	= "cancella";
		CmdClearAll	= "tutto";
		CmdClearSnapshot	= "lista";
		CmdCompete	= "competere";
		CmdCtrl	= "ctrl";
		CmdDefault	= "default";
		CmdDisable	= "disabilita";
		CmdEmbed	= "integra";
		CmdFinish	= "finale";
		CmdFinish0	= "spento";
		CmdFinish1	= "stacca";
		CmdFinish2	= "esci";
		CmdFinish3	= "Ricarica l'Interfaccia";
		CmdFinishSound	= "avviso sonoro al termine";
		CmdHelp	= "aiuto";
		CmdLocale	= "lingua";
		CmdOff	= "disattivo";
		CmdOn	= "attivo";
		CmdPctBidmarkdown	= "pct-bidmarkdown";
		CmdPctMarkup	= "pct-markup";
		CmdPctMaxless	= "pct-senzamassimo";
		CmdPctNocomp	= "pct-nocomp";
		CmdPctUnderlow	= "pct-underlow";
		CmdPctUndermkt	= "pct-sottomercato";
		CmdPercentless	= "percentless";
		CmdPercentlessShort	= "pl";
		CmdPrintin	= "stampa-in";
		CmdProtectWindow	= "proteggere-finestra";
		CmdProtectWindow0	= "mai";
		CmdProtectWindow1	= "scan";
		CmdProtectWindow2	= "sempre";
		CmdScan	= "scan";
		CmdShift	= "shift";
		CmdToggle	= "attiva-disattiva";
		CmdUpdatePrice	= "aggiorna-prezzo";
		CmdWarnColor	= "avviso-colore";
		ShowAverage	= "mostra-media";
		ShowEmbedBlank	= "mostra-lineavuota-integrata";
		ShowLink	= "mostra-collegamento";
		ShowMedian	= "mostra-media";
		ShowRedo	= "mostra-avvertenze";
		ShowStats	= "mostra-statistiche";
		ShowSuggest	= "mostra-consigli";
		ShowVerbose	= "mostra-dettagliato";


		-- Section: Config Text
		GuiAlso	= "Mostra informazioni anche per";
		GuiAlsoDisplay	= "Mostra informazioni per %s";
		GuiAlsoOff	= "Visualizzazione informazioni di altri reami-fazioni disabilitata.";
		GuiAlsoOpposite	= "Visualizzazione informazioni di altri reami-fazioni abilitata.";
		GuiAskPrice	= "Attivare AskPrice";
		GuiAskPriceAd	= "Manda le novità";
		GuiAskPriceGuild	= "Rispondi alle richieste in chat gilda";
		GuiAskPriceHeader	= "Opzioni di AskPrice";
		GuiAskPriceHeaderHelp	= "Cambia le opzioni del PrezzoRichiesto";
		GuiAskPriceParty	= "Rispondi alle richieste in chat gruppo";
		GuiAskPriceSmart	= "Usa parole-corte";
		GuiAskPriceTrigger	= "PrezzoRichiesto automatico";
		GuiAskPriceVendor	= "Manda le info del vendor";
		GuiAskPriceWhispers	= "Mostra i whispers in uscita";
		GuiAskPriceWord	= "Parola chiave personalizzata %d";
		GuiAuctionDuration	= "Durata asta predefinita";
		GuiAuctionHouseHeader	= "Finestra Casa d'Aste (AH)";
		GuiAuctionHouseHeaderHelp	= "Impostazioni della finestra Casa d'Aste (AH)";
		GuiAutofill	= "Inserimento automatico prezzi";
		GuiAverages	= "Mostra Medie";
		GuiBidmarkdown	= "Percentuale di bid markdown";
		GuiClearall	= "Cancella tutti i dati di Auctioneer";
		GuiClearallButton	= "Cancella dati fazione-reame attuali";
		GuiClearallHelp	= "Fare click qui per cancellare tutti i dati della fazione-reame attuale.";
		GuiClearallNote	= "per la fazione-reame attuale.";
		GuiClearHeader	= "Cancella Dati";
		GuiClearHelp	= "Cancella i dati di Auctioneer. Selezionare tutti i dati o solo la lista attuale. ATTENZIONE: queste operazioni NON sono annullabili.";
		GuiClearsnap	= "Cancella lista attuale";
		GuiClearsnapButton	= "Cancella lista";
		GuiClearsnapHelp	= "Fare click qui per canecllare l'ultima lista.";
		GuiDefaultAll	= "Reimposta tutte le opzioni di Auctioneer";
		GuiDefaultAllButton	= "Reimposta tutto";
		GuiDefaultAllHelp	= "Fare click qui per riportare tutte le opzioni ai loro valori predefiniti. ATTENZIONE: questa azione NON e' annullabile.";
		GuiDefaultOption	= "Reimposta al valore predefinito";
		GuiEmbed	= "Includi info nei tooltip";
		GuiEmbedBlankline	= "Mostra linea vuota nei tooltip";
		GuiEmbedHeader	= "Integra";
		GuiFinish	= "Dopo finita una scansione";
		GuiFinishSound	= "Avvisa con un suono quando lo scan è terminato";
		GuiLink	= "Mostra LinkID";
		GuiLoad	= "Carica Auctioneer";
		GuiLoad_Always	= "sempre";
		GuiLoad_AuctionHouse	= "nella Casa d'Aste (AH)";
		GuiLoad_Never	= "mai";
		GuiLocale	= "Imposta lingua a";
		GuiMainEnable	= "Attiva Auctioneer";
		GuiMainHelp	= "Contiene le impostazioni per Auctioneer, un AddOn che mostra informazioni sugli oggetti e analizza i dati delle aste. Fare click sul pulsante \"Scan\" nella Casa d'Aste (AH) per acquisire le informazioni.";
		GuiMarkup	= "Percentuale di Markup sul prezzo del vendor";
		GuiMaxless	= "Percentuale massima di ribasso";
		GuiMedian	= "Mostra mediane";
		GuiNocomp	= "Percentuale di ribasso senza concorrenti";
		GuiNoWorldMap	= "Auctioneer: visualizzazione Atlante impedita ";
		GuiOtherHeader	= "Altre opzioni";
		GuiOtherHelp	= "Opzioni varie";
		GuiPercentsHeader	= "Percentuali soglia di Auctioneer";
		GuiPercentsHelp	= "ATTENZIONE: I parametri seguenti sono SOLAMENTE per utenti esperti. Modifica i valori seguenti per impostare quanto aggressivo deve essere Auctioneer nel determinare i livelli di profitto.";
		GuiPrintin	= "Seleziona la finestra desiderata";
		GuiProtectWindow	= "Previeni chiusure accidentali della finestra della CdA";
		GuiRedo	= "Mostra avvertimento scansione lunga";
		GuiReloadui	= "Ricarica l'interfaccia utente";
		GuiReloaduiButton	= "RicaricaIU";
		GuiReloaduiFeedback	= "Caricamento Interfaccia di WoW";
		GuiReloaduiHelp	= "Clicca qui per ricaricare l'Interfaccia Utente di WoW dopo aver modificato la localizzazione. Facendo ciò la lingua delle schermate di configurazione coinciderà  con quella di Auctioneer. Nota: questa operazione può richiedere alcuni minuti.";
		GuiRememberText	= "Ricorda il prezzo";
		GuiStatsEnable	= "Mostra statistiche";
		GuiStatsHeader	= "Statistiche del prezzo dell'oggetto";
		GuiStatsHelp	= "Mostra le seguenti statistiche nel Tooltip";
		GuiSuggest	= "Mostra prezzo consigliato";
		GuiUnderlow	= "Ribasso maggiore";
		GuiUndermkt	= "Ribasso se Maxless";
		GuiVerbose	= "Informazioni dettagliate";
		GuiWarnColor	= "Colora Modello Prezzi";


		-- Section: Conversion Messages
		MesgConvert	= "Conversione del Database di Auctioneer. Fate prima una copia del vostro SavedVariables\\Auctioneer.lua %s%s";
		MesgConvertNo	= "Disattiva Auctioneer";
		MesgConvertYes	= "Convertire";
		MesgNotconverting	= "Auctioneer non sta convertendo il tuo database, ma non funzionerà finchè il database non sarà convertito.";


		-- Section: Game Constants
		TimeLong	= "Lungo";
		TimeMed	= "Medio";
		TimeShort	= "Breve";
		TimeVlong	= "Molto Lungo";


		-- Section: Generic Messages
		DisableMsg	= "Disattiva il caricamento automatico di Auctioneer";
		FrmtWelcome	= "Auctioneer v%s caricato";
		MesgNotLoaded	= "Auctioneer non e' caricato. digita /auctioneer per maggiori informazioni.";
		StatAskPriceOff	= "AskPrice e' disattivato ora.";
		StatAskPriceOn	= "AskPrice e' attivato ora.";
		StatOff	= "Visualizzazione delle informazioni sulle aste disattivata";
		StatOn	= "Visualizzazione delle informazioni sulle aste attivata";


		-- Section: Generic Strings
		TextCombat	= "Combattimento";
		TextGeneral	= "Generale";
		TextNone	= "nessuno";
		TextScan	= "Scan";
		TextUsage	= "Sintassi:";


		-- Section: Help Text
		HelpAlso	= "Mostra anche i valori di un altro server nei suggerimenti. Occorre inserire nome del reame e della fazione. Esempio: \"/auctioneer also Al'Akir-Horde\". Con la parola chiave \"opposite\" si specifica la fazione opposta, mentre \"off\" disattiva la funzionalita' .";
		HelpAskPrice	= "Attiva o disattiva AskPrice.";
		HelpAskPriceAd	= "Attiva o disattiva l'annuncio delle caratteristiche nuove di AskPrice.";
		HelpAskPriceGuild	= "Rispondi alle richieste fatte nella chat di gilda";
		HelpAskPriceParty	= "Rispondi alle richieste fatte nella chat del gruppo";
		HelpAskPriceSmart	= "Attiva o disattiva il controllo sulle SmartWords";
		HelpAskPriceTrigger	= "Cambia il carattere del PrezzoRichiesto";
		HelpAskPriceVendor	= "Attiva o Disattiva l'invio dei prezzi del vendor.";
		HelpAskPriceWhispers	= "Attiva o disattiva l'occultamento di tutti i whispers AskPrice in uscita";
		HelpAskPriceWord	= "Aggiungi o modifica le SmartWords abituali dell'AskPrice";
		HelpAuctionClick	= "Consente di creare automaticamente un'asta tenendo premuto Alt e cliccando su di un oggetto nell'inventario";
		HelpAuctionDuration	= "Imposta la durata di default delle aste all'apertura dell'interfaccia della Casa d'Aste";
		HelpAutofill	= "Imposta se auto-inserire o meno i prezzi quando si mette all'asta un nuovo oggetto nella finestra della Casa d'Aste";
		HelpAverage	= "Imposta la visualizzazione del prezzo d'asta medio dell'oggetto";
		HelpBidbroker	= "Mostra le aste a breve o medio termine selezionate dall'ultima scansione su cui puoi fare un'offerta per trarne profitto";
		HelpBidLimit	= "Numero massimo le aste da fare un'offerta sopra o buyout di quando il tasto di buyout o di offerta è scattato sulla linguetta delle aste di ricerca.";
		HelpBroker	= "Mostra tutte le aste selezionate dall'ultima scansione su cui puoi fare un'offerta per trarne profitto rivendendo";
		HelpClear	= "Elimina i dati sull'oggetto specificato (inserisci l'oggetto nel comando con shift-click). Puoi anche usare le parole chiave \"all\" o \"snapshot\"";
		HelpCompete	= "Mostra tutte le aste scansionate di recente il cui buyout è inferiore ad uno dei tuoi oggetti";
		HelpDefault	= "Imposta un opzione di Auctioneer al valore di default. Puoi anche usare la parola chiave \"all\" per impostare tutte le opzioni di Auctioneer ai valori di default.";
		HelpDisable	= "Non attivare automaticamente Auctioneer la prossima volta che ti colleghi";
		HelpEmbed	= "Integra il testo nei tooltip originali del gioco (nota: alcune funzionalità  vengono disabilitate quando quest'opzione è attiva)";
		HelpEmbedBlank	= "Imposta se visualizzare o meno una riga vuota fra le informazioni del tooltip e le informazioni sull'asta quando il modo integrato è attivo";
		HelpFinish	= "Imposta se effettuare il LogOut o Chiudere  automaticamente il gioco alla fine di uno scan dell AH";
		HelpFinishSound	= "Seleziona se avere o meno un avviso sonoro alla fine dello scan della casa d'aste";
		HelpLink	= "Imposta se visualizzare il link id nel tooltip";
		HelpLoad	= "Cambia le impostazioni di caricamento di Auctioneer per questo personaggio";
		HelpLocale	= "Cambia la lingua utilizzata per i messaggi di Auctioneer";
		HelpMedian	= "Imposta se visualizzare il buyout medio dell'oggetto";
		HelpOnoff	= "Attiva/disattiva la visualizzazione dei dati dell'asta";
		HelpPctBidmarkdown	= "Regola la percentuale con cui auctioneer contrassegnerà  le offerte al ribasso dal prezzo di buyout";
		HelpPctMarkup	= "La percentuale dei prezzi del vendor sarà evidenziata quando non ci saranno altri valori disponibili";
		HelpPctMaxless	= "Regola la percentuale massima con cui auctioneer diminuira' il valore del mercato prima che scada";
		HelpPctNocomp	= "La percentuale con cui auctioneer diminuira' il valore del mercato dell'oggetto quando non c'è concorrenza";
		HelpPctUnderlow	= "Regola la percentuale con cui auctioneer abbassera' il prezzo dell'asta più basso";
		HelpPctUndermkt	= "Percentuale da diminuire al valore del mercato quando non si può battere la concorrenza (senza limiti)";
		HelpPercentless	= "Mostra tutte le aste nelle ultime scansioni il cui buyout e' piu' basso di una certa percentuale rispetto al prezzo di vendita più alto";
		HelpPrintin	= "Seleziona in quale frame Auctioneer visualizzera'  i suoi messaggi. Puoi specificare il nome del frame o il suo numero.";
		HelpProtectWindow	= "Impedisce la chiusura accidentale dell'interfaccia dell'AH";
		HelpRedo	= "Seleziona per mostare un avviso quando lo scan di una pagina dell'AH ha impiegato troppo tempo a causa del lag.";
		HelpScan	= "Eseguire uno scan dell'AH alla prossima visita, o mentre sei li (c'e' un bottone sulla finestra dell'asta). Scegli su quali categorie vuoi eseguire lo scan con i checkbox.";
		HelpStats	= "Seleziona per mostrare le percentuali di bid/buyout di un oggetto";
		HelpSuggest	= "Seleziona per mostrare i prezzi d'asta consigliati di un oggetto";
		HelpUpdatePrice	= "Aggiorni automaticamente il prezzo iniziante per un'asta sulla linguetta delle aste dell'alberino quando il prezzo buyout cambia.";
		HelpVerbose	= "Seleziona per mostrare le medie e i consigli completi (oppure disattiva per mostrarli su linea singola)";
		HelpWarnColor	= "Seleziona se mostrare il modello dei prezzi attuale (Ribassato da...) in colori intuitivi.";


		-- Section: Post Messages
		FrmtNoEmptyPackSpace	= "Non hai spazio sufficente per poter creare l'asta!";
		FrmtNotEnoughOfItem	= "%s insufficenti per creare l'asta!";
		FrmtPostedAuction	= "Inserita 1 asta su %s (x%d)";
		FrmtPostedAuctions	= "Inserite %d aste su %s (x%d)";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "OffertaCorrente";
		FrmtBidbrokerDone	= "Bid brokering completato.";
		FrmtBidbrokerHeader	= "Profitto minimo: %s, HSP ='Prezzo Massimo Applicabile(Vendibile)'";
		FrmtBidbrokerLine	= "%s, Ultimi %s visti, HSP: %s, %s: %s, Prof: %s, Volte: %s";
		FrmtBidbrokerMinbid	= "OffertaMinima";
		FrmtBrokerDone	= "Brokeraggio completato";
		FrmtBrokerHeader	= "Profitto minimo: %s, PMV = 'Prezzo Massimo di Vendita' ";
		FrmtBrokerLine	= "%s, Ultimi %s visti, HSP: %s, BO: %s, Prof: %s";
		FrmtCompeteDone	= "Confronto delle auction completato.";
		FrmtCompeteHeader	= "Confrontando auction con ribasso di almeno %s per oggetto.";
		FrmtCompeteLine	= "%s, Puntata: %s, BO %s vs %s, %s meno";
		FrmtHspLine	= "Prezzo Massimo di Vendita per un %s è: %s";
		FrmtLowLine	= "%s, BO: %s, Venditore: %s, Per uno: %s, Meno della mediana: %s";
		FrmtMedianLine	= "Degli ultimi %d visti, BO mediano per 1 %s è: %s ";
		FrmtNoauct	= "Nessuna asta trovata per: %s ";
		FrmtPctlessDone	= "Ribasso applicato.";
		FrmtPctlessHeader	= "Ribasso sul Prezzo Applicabile Massimo (HSP): %d%%";
		FrmtPctlessLine	= "%s, Ultime %d viste, HSP: %s, BO: %s, Prof: %s, Ribasso %s";


		-- Section: Scanning Messages
		AuctionDefunctAucts	= "Aste obsolete rimosse: %s ";
		AuctionDiscrepancies	= "Discrepanze: %s  ";
		AuctionNewAucts	= "Nuove aste scansionate: %s";
		AuctionPageN	= "Auctioneer: scansione %s pagina %d di %d,\nAste al secondo: %s,\nTempo rimasto: %s ";
		AuctionScanDone	= "Auctioneer: scansione delle aste completata";
		AuctionScanNexttime	= "Auctioneer eseguira' una scansione completa delle aste la prossima volta che parlerai con un banditore.";
		AuctionScanNocat	= "Selezionare almeno una categoria per la scansione.";
		AuctionScanRedo	= "La pagina corrente ha impiegato piu' di %d secondi per essere scansionata, nuovo tentativo di scansione .";
		AuctionScanStart	= "Auctioneer: scansione %s pagina 1... ";
		AuctionTotalAucts	= "Totale aste scansionate: %s";


		-- Section: Tooltip Messages
		FrmtInfoAlsoseen	= "Visto %d volte a %s";
		FrmtInfoAverage	= "%s min/%s BO (%s offerta)";
		FrmtInfoBidMulti	= "Offerta (%s%s cad)";
		FrmtInfoBidOne	= "Con offerte%s";
		FrmtInfoBidrate	= "%d%% hanno offerte, %d%% hanno BO";
		FrmtInfoBuymedian	= "Buyout mediano";
		FrmtInfoBuyMulti	= "Buyout (%s%s cad) ";
		FrmtInfoBuyOne	= "Buyout%s";
		FrmtInfoForone	= "Per 1: %s min/%s BO (%s offerta) [in %d]";
		FrmtInfoHeadMulti	= "Medie per %d oggetti:";
		FrmtInfoHeadOne	= "Medie per questo oggetto:";
		FrmtInfoHistmed	= "Ultimo %d, BO mediano (cad)";
		FrmtInfoMinMulti	= "Offerta iniziale (%s cad)";
		FrmtInfoMinOne	= "Offerta iniziale";
		FrmtInfoNever	= "Mai visto a %s";
		FrmtInfoSeen	= "Visto un totale di %d volte all'asta";
		FrmtInfoSgst	= "Prezzo suggerito: %s min/%s BO";
		FrmtInfoSgststx	= "Prezzo suggerito per la tua pila di %d: %s min/%s BO";
		FrmtInfoSnapmed	= "Scansionato %d, BO mediano (cad)";
		FrmtInfoStacksize	= "Dimensione media della pila: %d oggetti";


		-- Section: User Interface
		FrmtLastSoldOn	= "Ultima Vendita a %s";
		UiBid	= "Bid";
		UiBidHeader	= "Bid";
		UiBidPerHeader	= "Percentuale Bid:";
		UiBuyout	= "Buyout";
		UiBuyoutHeader	= "Buyout";
		UiBuyoutPerHeader	= "Percentuale Buyout";
		UiBuyoutPriceLabel	= "Prezzo Buyout:";
		UiBuyoutPriceTooLowError	= "(Troppo Basso)";
		UiCategoryLabel	= "Filtro Categoria:";
		UiDepositLabel	= "Deposito:";
		UiDurationLabel	= "Durata:";
		UiItemLevelHeader	= "Liv";
		UiMakeFixedPriceLabel	= "Usa prezzo fisso";
		UiMaxError	= "(%d Max)";
		UiMaximumPriceLabel	= "Prezzo Massimo:";
		UiMaximumTimeLeftLabel	= "Massimo Tempo Mancante:";
		UiMinimumProfitLabel	= "Profitto Minimo:";
		UiMinimumQualityLabel	= "Qualita' minima:";
		UiMinimumUndercutLabel	= "Ribasso minimo:";
		UiNameHeader	= "Nome";
		UiNoPendingBids	= "Tutte le richieste di bid completate!";
		UiNotEnoughError	= "(Non Abbastanza)";
		UiPendingBidInProgress	= "1 richiesta di bid in corso...";
		UiPendingBidsInProgress	= "%d richieste di bid in corso...";
		UiPercentLessHeader	= "%";
		UiPost	= "Inserisci";
		UiPostAuctions	= "Inserisci Asta";
		UiPriceBasedOnLabel	= "Prezzo basato su:";
		UiPriceModelAuctioneer	= "Prezzo Auctioneer";
		UiPriceModelCustom	= "Prezzo personale";
		UiPriceModelFixed	= "Prezzo fisso";
		UiPriceModelLastSold	= "Ultimo Prezzo di Vendita";
		UiProfitHeader	= "Guadagno";
		UiProfitPerHeader	= "Guadagno %";
		UiQuantityHeader	= "Q.ta'";
		UiQuantityLabel	= "Quantita':";
		UiRemoveSearchButton	= "Cancella";
		UiSavedSearchLabel	= "Ricerche salvate:";
		UiSaveSearchButton	= "Salva";
		UiSaveSearchLabel	= "Salva questa ricerca:";
		UiSearch	= "Cerca";
		UiSearchAuctions	= "Cerca Aste";
		UiSearchDropDownLabel	= "Cerca:";
		UiSearchForLabel	= "Cerca un oggetto:";
		UiSearchTypeBids	= "Offerte";
		UiSearchTypeBuyouts	= "Buyout";
		UiSearchTypeCompetition	= "Competizione";
		UiSearchTypePlain	= "Oggetto";
		UiStacksLabel	= "Pile";
		UiStackTooBigError	= "(Pila troppo grande)";
		UiStackTooSmallError	= "(Pila troppo piccola)";
		UiStartingPriceLabel	= "Prezzo di partenza:";
		UiStartingPriceRequiredError	= "(Obbligatorio)";
		UiTimeLeftHeader	= "Tempo rimanente";
		UiUnknownError	= "(Sconosciuto)";

	};

	koKR = {


		-- Section: AskPrice Messages
		AskPriceAd	= "%sx[아이템링크]에 대한 묶음 가격을 얻어옵니다.(x=묶음수량)";
		FrmtAskPriceBuyoutMedianHistorical	= "%s 기록되어있는 즉시 구입가 중간값: %s%s";
		FrmtAskPriceBuyoutMedianSnapshot	= "%s 최근 검색된 즉시 구입가 중간값: %s%s";
		FrmtAskPriceDisable	= "가격요청의 %s 설정 비활성화";
		FrmtAskPriceEach	= "(개당 %s)";
		FrmtAskPriceEnable	= "가격요청의 %s 설정 활성화";
		FrmtAskPriceVendorPrice	= "%s 상점 판매가: %s%s";


		-- Section: Auction Messages
		FrmtActRemove	= "현재 경매장 기록에서 %s|1을;를; 삭제합니다.";
		FrmtAuctinfoHist	= "기존 %d개";
		FrmtAuctinfoLow	= "낮은 기록";
		FrmtAuctinfoMktprice	= "상점가";
		FrmtAuctinfoNolow	= "최근 기록된 정보에서 본 적이 없는 아이템.";
		FrmtAuctinfoOrig	= "원래 입찰가";
		FrmtAuctinfoSnap	= "최근 검색 %d개";
		FrmtAuctinfoSugbid	= "제안된 입찰가";
		FrmtAuctinfoSugbuy	= "제안된 즉시 구입가";
		FrmtWarnAbovemkt	= "상점가 이상만 경합";
		FrmtWarnMarkup	= "상점가 보다 %s%% 높게";
		FrmtWarnMyprice	= "내 현재 가격 사용";
		FrmtWarnNocomp	= "경합 없음";
		FrmtWarnNodata	= "최고 판매가능가(HSP)에대한 데이터 없음";
		FrmtWarnToolow	= "최저가에 맞출 수 없습니다.";
		FrmtWarnUndercut	= "%s%% 만큼 할인";
		FrmtWarnUser	= "사용자 가격 사용";


		-- Section: Bid Messages
		FrmtAlreadyHighBidder	= "경매에 이미 더 높은 입찰자가 있음: %s (x%d)";
		FrmtBidAuction	= "경매에 입찰: %s (x%d)";
		FrmtBidQueueOutOfSync	= "오류: 입찰 대기열 동기화에 문제가 발생하였습니다!";
		FrmtBoughtAuction	= "즉시구입된 경매: %s (x%d)";
		FrmtMaxBidsReached	= "%s (x%d)의 경매품들을 좀더 찾았지만, 입찰 한계에 도달했습니다.(%d)";
		FrmtNoAuctionsFound	= "경매를 찾을 수 없음: %s (x%d)";
		FrmtNoMoreAuctionsFound	= "더이상 경매품을 찾을 수 없습니다: %s (x%d)";
		FrmtNotEnoughMoney	= "경매에 입찰하기 위한 돈이 부족합니다: %s (x%d)";
		FrmtSkippedAuctionWithHigherBid	= "더 높은 입찰로 인해 건너뛴 경매: %s (x%d)";
		FrmtSkippedAuctionWithLowerBid	= "더 낮은 입찰로 인해 건너뛴 경매: %s (x$d)";
		FrmtSkippedBiddingOnOwnAuction	= "자신의 경매라서 입찰을 건너뜀: %s (x%d)";
		UiProcessingBidRequests	= "입찰 요청 수행중...";


		-- Section: Command Messages
		ConstantsCritical	= "위험: Auctioneer SavedVariables 파일을 %.3f%% 사용하고 있습니다.";
		ConstantsMessage	= "Auctioneer SavedVariables 파일을 %.3f%% 사용하고 있습니다.";
		ConstantsWarning	= "경고: Auctioneer SavedVariables 파일을 %.3f%% 사용하고 있습니다.";
		FrmtActClearall	= "%s에 대한 모든 경매 데이터 삭제";
		FrmtActClearFail	= "찾을 수 없는 아이템: %s";
		FrmtActClearOk	= "아이템관련 삭제된 데이타: %s";
		FrmtActClearsnap	= "현재 경매장 기록 정보 삭제";
		FrmtActDefault	= "Auctioneer의 %s 설정이 초기화되었습니다.";
		FrmtActDefaultall	= "Auctioneer의 모든 설정이 초기화되었습니다.";
		FrmtActDisable	= "아이템의 %s 데이터 표시하지 않음";
		FrmtActEnable	= "아이템의 %s 데이터 표시";
		FrmtActSet	= "%s|1을;를; '%s|1'으로;'로; 설정";
		FrmtActUnknown	= "알 수 없는 명령어: '%s'";
		FrmtAuctionDuration	= "기본 경매 기간으로 설정함: %s ";
		FrmtAutostart	= "자동으로 경매 시작: 최저가 %s, 즉시 구입가 %s(%d시간) %s";
		FrmtFinish	= "검색이 끝나면, %s|1을;를; 수행합니다.";
		FrmtPrintin	= "Auctioneer의 메시지가 \"%s\" 채팅 창에 표시됩니다.";
		FrmtProtectWindow	= "경매장 창 보호가 설정됨: %s";
		FrmtUnknownArg	= "'%s|1'은;'는; '%s'에 유효하지 않은 매개변수 입니다.";
		FrmtUnknownLocale	= "('%s|1')은;')는; 알 수 없는 지역입니다. 유효한 지역은 다음과 같습니다:";
		FrmtUnknownRf	= "매개변수 ('%s|1')이;')가; 유효하지 않습니다. 매개변수의 형식은 다음과 같아야 합니다: [realm]-[faction]. 예: 듀로탄-호드";


		-- Section: Command Options
		OptAlso	= "(서버-진영|적진영|아군진영|중립진영)";
		OptAskPriceSend	= "(<플레이어이름> <요청가격 질의>)";
		OptAuctionDuration	= "(지난|2시간|8시간|24시간)";
		OptBidbroker	= "<실버_이윤>";
		OptBidLimit	= "<숫자>";
		OptBroker	= "<실버_이윤>";
		OptClear	= "([아이템]|모두|스넵샷) ";
		OptCompete	= "<실버_이하>";
		OptDefault	= "(<설정>|모두)";
		OptFinish	= "(끔|로그아웃|나가기|리로드) ";
		OptLocale	= "<지역>";
		OptPctBidmarkdown	= "<퍼센트>";
		OptPctMarkup	= "<퍼센트>";
		OptPctMaxless	= "<퍼센트>";
		OptPctNocomp	= "<퍼센트>";
		OptPctUnderlow	= "<퍼센트>";
		OptPctUndermkt	= "<퍼센트>";
		OptPercentless	= "<퍼센트>";
		OptPrintin	= "(<프레임인덱스>[숫자]|<프레임이름>[문자열]) ";
		OptProtectWindow	= "(사용안함|검색|항상사용) ";
		OptScale	= "<비율_인자> ";
		OptScan	= "<>";


		-- Section: Commands
		CmdAlso	= "also";
		CmdAlsoOpposite	= "적진영";
		CmdAlt	= "Alt";
		CmdAskPriceAd	= "광고";
		CmdAskPriceGuild	= "길드";
		CmdAskPriceParty	= "파티";
		CmdAskPriceSend	= "보내기";
		CmdAskPriceSmart	= "스마트";
		CmdAskPriceSmartWord1	= "무엇";
		CmdAskPriceSmartWord2	= "가치";
		CmdAskPriceTrigger	= "트리거";
		CmdAskPriceVendor	= "상점";
		CmdAskPriceWhispers	= "귓속말";
		CmdAskPriceWord	= "단어";
		CmdAuctionClick	= "경매-클릭 ";
		CmdAuctionDuration	= "경매-기간";
		CmdAuctionDuration0	= "최근";
		CmdAuctionDuration1	= "2시간";
		CmdAuctionDuration2	= "8시간";
		CmdAuctionDuration3	= "24시간";
		CmdAutofill	= "자동 입력";
		CmdBidbroker	= "입찰중계인";
		CmdBidbrokerShort	= "bb ";
		CmdBidLimit	= "입찰-한계";
		CmdBroker	= "중계인";
		CmdClear	= "삭제";
		CmdClearAll	= "모두";
		CmdClearSnapshot	= "스넵샷";
		CmdCompete	= "경합";
		CmdCtrl	= "Ctrl";
		CmdDefault	= "기본값";
		CmdDisable	= "비활성화";
		CmdEmbed	= "포함";
		CmdFinish	= "마침";
		CmdFinish0	= "끔";
		CmdFinish1	= "접속종료";
		CmdFinish2	= "나가기";
		CmdFinish3	= "리로드";
		CmdFinishSound	= "종료 소리";
		CmdHelp	= "도움말";
		CmdLocale	= "지역";
		CmdOff	= "끔";
		CmdOn	= "켬";
		CmdPctBidmarkdown	= "pct-bidmarkdown";
		CmdPctMarkup	= "pct-markup";
		CmdPctMaxless	= "pct-maxless";
		CmdPctNocomp	= "pct-nocomp";
		CmdPctUnderlow	= "pct-underlow";
		CmdPctUndermkt	= "pct-undermkt";
		CmdPercentless	= "percentless";
		CmdPercentlessShort	= "pl";
		CmdPrintin	= "print-in";
		CmdProtectWindow	= "protect-window";
		CmdProtectWindow0	= "사용안함";
		CmdProtectWindow1	= "검색";
		CmdProtectWindow2	= "항상사용";
		CmdScan	= "검색";
		CmdShift	= "Shift";
		CmdToggle	= "토글";
		CmdUpdatePrice	= "갱신-가격";
		CmdWarnColor	= "경고-색상";
		ShowAverage	= "표시-평균";
		ShowEmbedBlank	= "표시-포함-공백줄";
		ShowLink	= "표시-링크";
		ShowMedian	= "표시-중간값";
		ShowRedo	= "표시-경고";
		ShowStats	= "표시-통계";
		ShowSuggest	= "표시-제안값";
		ShowVerbose	= "표시-알림";


		-- Section: Config Text
		GuiAlso	= "Also 데이타 표시";
		GuiAlsoDisplay	= "%s에 관한 데이터 표시";
		GuiAlsoOff	= "더이상 다른 서버-진영 데이터를 표시하지 않습니다.";
		GuiAlsoOpposite	= "Also로 적대 진영에 대한 데이터를 표시합니다.";
		GuiAskPrice	= "가격요청 활성화";
		GuiAskPriceAd	= "특징 광고 전송";
		GuiAskPriceGuild	= "길드대화 쿼리 응답";
		GuiAskPriceHeader	= "가격요청 설정";
		GuiAskPriceHeaderHelp	= "가격요청의 방법 변경";
		GuiAskPriceParty	= "파티대화 쿼리 응답";
		GuiAskPriceSmart	= "스마트워드 사용";
		GuiAskPriceTrigger	= "가격요청 트리거";
		GuiAskPriceVendor	= "상점 정보 전송";
		GuiAskPriceWhispers	= "귓속말 보이기";
		GuiAskPriceWord	= "추가 스마트워드 %d";
		GuiAuctionDuration	= "기본 경매 기간";
		GuiAuctionHouseHeader	= "경매장 창";
		GuiAuctionHouseHeaderHelp	= "경매장 창의 동작 변경";
		GuiAutofill	= "경매장에서 자동으로 가격 입력";
		GuiAverages	= "평균값 표시";
		GuiBidmarkdown	= "입찰 가격 인하 비율";
		GuiClearall	= "모든 Auctioneer 데이타 삭제";
		GuiClearallButton	= "모두 삭제";
		GuiClearallHelp	= "현재 서버-진영에 대한 모든 Auctioneer 데이타를 삭제하려면 이곳을 클릭하십시오.";
		GuiClearallNote	= "현재 서버-진영";
		GuiClearHeader	= "데이터 삭제";
		GuiClearHelp	= "Auctioneer 데이터를 삭제합니다. 모든 데이타 또는 현재 기록을 선택하십시오. 경고: 삭제된 경매 정보는 복구할 수 없습니다.";
		GuiClearsnap	= "기록 정보 삭제";
		GuiClearsnapButton	= "기록 삭제";
		GuiClearsnapHelp	= "최근의 Auctioneer 기록 정보를 삭제하려면 이곳을 클릭하십시오.";
		GuiDefaultAll	= "모든 Auctioneer 설정 초기화";
		GuiDefaultAllButton	= "모두 초기화";
		GuiDefaultAllHelp	= "Auctioneer 설정을 기본값으로 설정하려면 여기를 클릭하십시오. 경고: 기존의 설정값은 복구할 수 없습니다.";
		GuiDefaultOption	= "설정 초기화";
		GuiEmbed	= "게임 툴팁에 정보를 포함시킴";
		GuiEmbedBlankline	= "게임 툴팁에 빈줄 표시";
		GuiEmbedHeader	= "포함";
		GuiFinish	= "검색이 끝나면";
		GuiFinishSound	= "검색이 끝나면 소리 재생";
		GuiLink	= "링크아이디 보기";
		GuiLoad	= "Auctioneer 불러오기";
		GuiLoad_Always	= "항상사용";
		GuiLoad_AuctionHouse	= "경매장에서";
		GuiLoad_Never	= "사용안함";
		GuiLocale	= "지역 설정:";
		GuiMainEnable	= "Auctioneer 활성화";
		GuiMainHelp	= "아이템 정보와 경매 데이타를 분석하여 표시해주는 애드온인 Auctioneer에 대한 설정을 포함. 경매장에서 경매 데이타를 수집하려면 \"검색\" 버튼을 클릭하십시오.";
		GuiMarkup	= "상점 가격 인상 비율";
		GuiMaxless	= "최대 시장가 절삭 비율";
		GuiMedian	= "중앙값 보기";
		GuiNocomp	= "경합 절삭 비율 없음";
		GuiNoWorldMap	= "Auctioneer: 월드맵 표시를 위해 감춰짐";
		GuiOtherHeader	= "기타 옵션들";
		GuiOtherHelp	= "자세한 경매인 옵션들";
		GuiPercentsHeader	= "Auctioneer 경계값 퍼센트";
		GuiPercentsHelp	= "경고: 다음 설정은 고급 사용자만을 위한 것입니다. 다음 조절값들은 얼마나 적극적으로 Auctioneer가 이윤 수준을 결정할 것인지에 관한 것입니다.";
		GuiPrintin	= "원하는 메시지 프레임 선택";
		GuiProtectWindow	= "실수로 경매장 창 닫기 방지";
		GuiRedo	= "장기 검색 경고 표시";
		GuiReloadui	= "사용자 인터페이스 리로드";
		GuiReloaduiButton	= "UI리로드";
		GuiReloaduiFeedback	= "WoW UI를 리로드 하는중";
		GuiReloaduiHelp	= "이 설정 화면에 맞는 지역 언어를 선택한 후에 WoW 사용자 인터페이서를 다시 로드하기 위해 이 곳을 클릭하십시오.\n주의: 이 옵션은 몇분 정도 걸릴 수 있습니다.";
		GuiRememberText	= "가격 기억";
		GuiStatsEnable	= "통계 보기";
		GuiStatsHeader	= "아이템 가격 통계";
		GuiStatsHelp	= "툴팁에 다음 통계량을 표시합니다.";
		GuiSuggest	= "제안가 보기";
		GuiUnderlow	= "가장 낮은 경매가 절삭";
		GuiUndermkt	= "Maxless일 때 절삭된 시장가";
		GuiVerbose	= "알림 모드";
		GuiWarnColor	= "가격 모델 색상";


		-- Section: Conversion Messages
		MesgConvert	= "Auctioneer 데이터베이스를 새롭게 변환합니다. SavedVariables\\Auctioneer.lua 파일을 미리 백업해두시길 권장합니다.%s%s";
		MesgConvertNo	= "Auctioneer 비활성화";
		MesgConvertYes	= "변환";
		MesgNotconverting	= "데이터베이스를 변환하지 않았습니다. 그러나 변환을 하지 않으면 Auctioneer는 동작하지 않을 것입니다.";


		-- Section: Game Constants
		SubTypeBag	= "가방";
		TimeLong	= "장기";
		TimeMed	= "중기";
		TimeShort	= "단기";
		TimeVlong	= "최장기";


		-- Section: Generic Messages
		ConfirmBidBuyout	= "%dx%s|1을;를; 정말로 %s하시겠습니까?\n가격: ";
		DisableMsg	= "Auctioneer 자동으로 불러오기 비활성화";
		FrmtWelcome	= "Auctioneer v%s 로드됨.";
		MesgNotLoaded	= "Auctioneer 로드되지 않음. 더 많은 정보를 보려면 /auctioneer 라고 입력하세요.";
		ScanCancel	= "검색 취소됨";
		ScanComplete	= "검색 완료";
		ScanFailed	= "검색 실패";
		StatAskPriceOff	= "가격요청이 비활성화됩니다.";
		StatAskPriceOn	= "가격요청이 활성화됩니다.";
		StatOff	= "어떤 경매 데이타도 표시하지 않음";
		StatOn	= "설정된 경매 데이타 표시";
		UIScanCanceled	= "Auctioneer: 경매 검색이 취소되었습니다.";
		UIScanComplete	= "Auctioneer: 경매 검색이 완료되었습니다.";
		UIScanFailed	= "Auctioneer: 경매 검색이 실패했습니다.";


		-- Section: Generic Strings
		TextCombat	= "전투";
		TextGeneral	= "일반";
		TextNone	= "없음";
		TextScan	= "검색";
		TextUsage	= "사용법:";


		-- Section: Help Text
		HelpAlso	= "다른 서버에서의 가격을 툴팁에 표시합니다. 서버명과 진영을 넣어야 합니다. 예제: \"/auctioneer also 달라란-얼라이언스\". 추가 옵션으로 \"적진영\"은 적대 진영을 의미하고, \"끔\"은 기능을 끕니다.";
		HelpAskPrice	= "가격요청을 활성화 또는 비활성화합니다.";
		HelpAskPriceAd	= "새로운 가격요청 기능의 광고를 활성화 또는 비활성화합니다.";
		HelpAskPriceGuild	= "길드 대화창에서 생성된 쿼리에 응답합니다.";
		HelpAskPriceParty	= "파티 대화창에서 생성된 쿼리에 응답합니다.";
		HelpAskPriceSend	= "수동으로 요청가격 질의에 대한 결과를 플레이어에게 전송합니다.";
		HelpAskPriceSmart	= "스마트워드 체크를 활성화 또는 비활성화합니다.";
		HelpAskPriceTrigger	= "가격요청의 트리거 문자를 변경합니다.";
		HelpAskPriceVendor	= "상점 가격 데이타의 전송을 활성화 또는 비활성화합니다.";
		HelpAskPriceWhispers	= "가격요청이 하는 귓속말 숨기기를 활성화 또는 비활성화합니다.";
		HelpAskPriceWord	= "가격요청의 추가 스마트워드를 추가하거나 변경합니다.";
		HelpAuctionClick	= "가방에 있는 아이템을 Alt-클릭하면 자동으로 경매를 시작하게 합니다.";
		HelpAuctionDuration	= "경매장 창을 열때 기본 경매 기간을 설정합니다.";
		HelpAutofill	= "경매장 창에 아이템을 올려놓으면 자동으로 가격을 입력할지 설정합니다.";
		HelpAverage	= "아이템의 평균 경매가 표시 여부를 선택합니다.";
		HelpBidbroker	= "최근 검색한 이익을 위해 입찰한 경매에서 단기 또는 중기인 경매를 표시합니다.";
		HelpBidLimit	= "경매 검색 탭에서 입찰 또는 즉시 구입 버튼이 클릭 되었을 때 입찰 또는 즉시 구입할 경매품의 최대 수량";
		HelpBroker	= "최근 검색한 경매에서 입찰 후 다시 팔경우 이익이 생기는 아이템을 모두 표시합니다.";
		HelpClear	= "특정 아이템에 대한 정보를 삭제합니다. (반드시 Shift 클릭을 통해 명령줄에 아이템을 입력해야합니다.) 또한 \"모두\" 또는 \"기록\" 키워드를 사용할수 있습니다.";
		HelpCompete	= "최근 검색된 경매에서 자신보다 낮은 즉시 구입가를 가진 아이템을 표시합니다.";
		HelpDefault	= "Auctioneer의 설정을 기본값으로 되돌립니다. \"모두\" 키워드를 통해서 모든 설정을 기본값으로 되돌릴 수 있습니다.";
		HelpDisable	= "다음 로그인 부터 자동으로 Auctioneer를 로드하지 않습니다.";
		HelpEmbed	= "기본 게임 툴팁에 텍스트를 포함합니다.(주의: 이것을 선택하면 일부 기능이 비활성화됩니다.)";
		HelpEmbedBlank	= "텍스트 포함 모드가 켜있을 때 툴팁 정보와 경매 정보 사이에 한 줄을 띕니다.";
		HelpFinish	= "경매 검색이 끝나면 자동으로 접속종료 또는 게임을 나갈지를 설정합니다.";
		HelpFinishSound	= "경매 검색이 끝나면 소리를 재생합니다.";
		HelpLink	= "툴팁에 링크 아이디를 표시합니다.";
		HelpLoad	= "Auctioneer 로드 설정을 변경합니다.";
		HelpLocale	= "경매인 메세지 표시에 사용되는 지역 정보를 변경합니다.";
		HelpMedian	= "아이템의 즉시 구입가 중앙값을 표시합니다.";
		HelpOnoff	= "경매 데이타 표시를 켜거나 끕니다.";
		HelpPctBidmarkdown	= "Auctioneer가 즉시 구입가보다 낮은 가격에 입찰할 비율을 설정합니다.";
		HelpPctMarkup	= "다른 값이 없을 때 상점 가격을 선택할 비율입니다.";
		HelpPctMaxless	= "포기하기 전에 Auctioneer가 시장가를 절삭할 최대 비율을 설정합니다.";
		HelpPctNocomp	= "경합이 없을 때 Auctioneer가 시장가를 절삭할 비율입니다.";
		HelpPctUnderlow	= "Auctioneer가 가장 낮은 경매가를 절삭할 비율을 설정합니다.";
		HelpPctUndermkt	= "(maxless에 의해) 경합에서 이길 수 없을 때 시장 가격을 절삭할 비율.";
		HelpPercentless	= "최근 검색된 경매 물품들중에서 즉시 구입가가 최고 판매가능가보다 특정 퍼센트 미만인 물품을 표시합니다.";
		HelpPrintin	= "Auctioneer가 메시지를 표시할 창을 선택합니다. 프레임명이나 프레임번호로 지정할수 있습니다.";
		HelpProtectWindow	= "실수로 경매장 창을 닫는 것을 방지합니다.";
		HelpRedo	= "서버 랙 때문에 현재 페이지의 경매 검색이 오래 걸릴 경우 경고를 보여줄지를 결정합니다.";
		HelpScan	= "다음번 경매장 방문 때 또는 경매장에 있는 동안(경매창에도 버튼이 있습니다.) 경매장 검색을 수행합니다. 검색할 분류에 체크 상자를 선택하십시오.";
		HelpStats	= "아이템의 입찰/즉시 구입 퍼센트 표시 여부를 설정합니다.";
		HelpSuggest	= "아이템의 제안 경매가 표시 여부를 설정합니다.";
		HelpUpdatePrice	= "경매품 탭에서 즉시 구입가가 변경되면 경매품에 대한 시작가를 자동으로 갱신합니다.";
		HelpVerbose	= "평균 가격과 제안 가격을 여러줄로 표시합니다.(\"끔\"으로 하면 한줄로 표시합니다.)";
		HelpWarnColor	= "현재 경매장 가격 모델(절삭 등)을 직관적인 색상으로 표시합니다.";


		-- Section: Post Messages
		FrmtNoEmptyPackSpace	= "경매 생성을 위한 빈 공간이 없음";
		FrmtNotEnoughOfItem	= "경매 생성을 위한 %s|1이;가; 충분하지 않습니다.";
		FrmtPostedAuction	= "%s (x%d) 1개를 게시하였습니다.";
		FrmtPostedAuctions	= "%d개의 %s (x%d) 경매를 게시하였습니다.";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "현재입찰";
		FrmtBidbrokerDone	= "입찰 중개 완료";
		FrmtBidbrokerHeader	= "최저 이윤: %s, HSP = '최고 판매가능가'";
		FrmtBidbrokerLine	= "%s, 최근 %s회 검색됨, 최고 판매가능가(HSP): %s, %s: %s, 이윤: %s, 시간: %s";
		FrmtBidbrokerMinbid	= "최저입찰";
		FrmtBrokerDone	= "입찰 중개 완료";
		FrmtBrokerHeader	= "최저 이윤: %s, HSP = '최고 판매가능가'";
		FrmtBrokerLine	= "%s, 최근 %s회 검색됨, 최고 판매가능가(HSP): %s, 즉시 구입가(BO): %s, 이윤: %s";
		FrmtCompeteDone	= "경매 물품 경합 완료.";
		FrmtCompeteHeader	= "적어도 아이템 당 %s 이하의 경매 물품에 경합.";
		FrmtCompeteLine	= "%s, 입찰: %s, 즉시 구입가(BO) %s 대 %s, %s 이하";
		FrmtHspLine	= "%s 개당 최고 판매가능가는: %s";
		FrmtLowLine	= "%s, 즉시 구입가: %s, 판매자: %s, 개당: %s, 중앙값 이하: %s";
		FrmtMedianLine	= "최근 %d회 검색됨, %s 한 개당 즉시 구입가 중앙값: %s";
		FrmtNoauct	= "해당 아이템에 대해 찾을 수 없음: %s";
		FrmtPctlessDone	= "성사되지 않을 확률.";
		FrmtPctlessHeader	= "최고 판매가능가(HSP)보다 낮을 확률: %d%%";
		FrmtPctlessLine	= "%s, 최근 %d회 검색됨, 최고 판매가능가(HSP): %s, 즉시 구입가(BO): %s, 이윤: %s, %s 이하";


		-- Section: Scanning Messages
		AuctionDefunctAucts	= "삭제된 기본 경매 물품 수량: %s";
		AuctionDiscrepancies	= "차이나는 수량: %s";
		AuctionNewAucts	= "새롭게 검색된 경매 물품 수량: %s";
		AuctionPageN	= "Auctioneer: %s %d/%d 페이지 검색중..\n초당 검색 경매품: %s\n남은 예상 시간: %s\n기록에 추가됨: %s";
		AuctionScanDone	= "Auctioneer: 경매 물품 검색 완료";
		AuctionScanNexttime	= "다음번 경매인과 대화할 때, Auctioneer는 전체 검색을 할 것입니다.";
		AuctionScanNocat	= "검색을 위해 최소한 한개 이상의 분류를 선택하여야 합니다.";
		AuctionScanRedo	= "현재 페이지를 완료하는데 %d 초 이상이 걸렸습니다. 페이지를 재시도합니다.";
		AuctionScanStart	= "Auctioneer: %s 1 페이지 검색중...";
		AuctionTotalAucts	= "검색된 경매 물품 총 수량: %s";
		AuctionUpdatedAucts	= "갱신/변경된 경매 물품: %s";


		-- Section: Tooltip Messages
		FrmtInfoAlsoseen	= "%s에서 %d회 검색됨";
		FrmtInfoAverage	= "최저 %s/%s 즉시 구입가 (%s에 입찰)";
		FrmtInfoBidMulti	= "입찰 (%s%s 개)";
		FrmtInfoBidOne	= "입찰 %s";
		FrmtInfoBidrate	= "입찰 확률 %d%%, 즉시 구입 확률 %d%%";
		FrmtInfoBuymedian	= "즉시 구입가 중앙값";
		FrmtInfoBuyMulti	= "즉시 구입가 (%s%s 개)";
		FrmtInfoBuyOne	= "즉시 구입가 %s";
		FrmtInfoForone	= "개당: 최저 %s/%s 즉시 구입가 (%s 입찰) [%d개의 수량 중]";
		FrmtInfoHeadMulti	= "%d개의 평균:";
		FrmtInfoHeadOne	= "평균:";
		FrmtInfoHistmed	= "최근 %d, 즉시 구입가 중앙값 (개)";
		FrmtInfoMinMulti	= "경매 시작가 (%s 개)";
		FrmtInfoMinOne	= "경매 시작가";
		FrmtInfoNever	= "%s에서 검색된적 없음";
		FrmtInfoSeen	= "전체 경매에서 %d회 검색됨";
		FrmtInfoSgst	= "제안 가격: 최저 %s /%s 즉시 구입가";
		FrmtInfoSgststx	= "%d 개에 대한 제안 가격: 최저가 %s/ 즉시 구입가 %s";
		FrmtInfoSnapmed	= "%d회 검색됨, 즉시 구입가 중앙값 (개)";
		FrmtInfoStacksize	= "평균 한 묶음 수량: %d개";


		-- Section: User Interface
		BuySortTooltip	= "즉시 구입가격순으로 정렬합니다. (아이템 이름으로 정렬하려면 SHIFT를 누르고 계십시오)";
		ClearTooltip	= "검색창의 설정값을 지워줍니다.";
		FrmtLastSoldOn	= "최근 판매가 : %s";
		RefreshTooltip	= "현재 페이지를 다시 검색합니다.";
		UiBid	= "입찰";
		UiBidHeader	= "입찰";
		UiBidPerHeader	= "개당 입찰";
		UiBuyout	= "즉시 구입";
		UiBuyoutHeader	= "즉시 구입";
		UiBuyoutPerHeader	= "개당 즉시 구입";
		UiBuyoutPriceLabel	= "즉시 구입가";
		UiBuyoutPriceTooLowError	= "(너무 낮음)";
		UiCategoryLabel	= "분류 제한:";
		UiDepositLabel	= "보증금";
		UiDurationLabel	= "경매 기간";
		UiItemLevelHeader	= "레벨";
		UiMakeFixedPriceLabel	= "가격 고정";
		UiMaxError	= "(최대 %d)";
		UiMaximumPriceLabel	= "최고가:";
		UiMaximumTimeLeftLabel	= "최대 남은 기간";
		UiMinimumBidPercentLabel	= "최소 입찰 %:";
		UiMinimumPercentLessShortLabel	= "최소 하한 %:";
		UiMinimumProfitLabel	= "최소 이익";
		UiMinimumQualityLabel	= "최소 품질:";
		UiMinimumUndercutLabel	= "최소 삭감:";
		UiNameHeader	= "이름";
		UiNoPendingBids	= "모든 입찰 요청이 완료되었습니다!";
		UiNotEnoughError	= "(충분하지 않음)";
		UiPendingBidInProgress	= "1개의 입찰 요청 처리중...";
		UiPendingBidsInProgress	= "%d개의 결정되지않은 입찰 요청 처리중...";
		UiPercentLessHeader	= "%";
		UiPost	= "게시";
		UiPostAuctions	= "경매 게시";
		UiPriceBasedOnLabel	= "가격 근거:";
		UiPriceModelAuctioneer	= "Auctioneer 가격";
		UiPriceModelCustom	= "사용자 가격";
		UiPriceModelFixed	= "고정된 가격";
		UiPriceModelLastSold	= "최근 판매가";
		UiProfitHeader	= "이익";
		UiProfitPerHeader	= "개당 이익";
		UiQuantityHeader	= "수량";
		UiQuantityLabel	= "수량:";
		UiRemoveSearchButton	= "삭제";
		UiSavedSearchLabel	= "저장된 검색내용:";
		UiSaveSearchButton	= "저장";
		UiSaveSearchLabel	= "이번 검색 저장:";
		UiSearch	= "검색";
		UiSearchAuctions	= "경매 검색";
		UiSearchDropDownLabel	= "검색";
		UiSearchForLabel	= "아이템으로 검색:";
		UiSearchForOwnerLabel	= "아이템 게시자로 검색:";
		UiSearchTypeBids	= "입찰";
		UiSearchTypeBuyouts	= "즉시 구입";
		UiSearchTypeCompetition	= "경쟁";
		UiSearchTypeOwner	= "판매자";
		UiSearchTypePlain	= "아이템";
		UiStacksLabel	= "묶음";
		UiStackTooBigError	= "(묶음이 너무 큼)";
		UiStackTooSmallError	= "(묶음이 너무 작음)";
		UiStartingPriceLabel	= "경매 시작가:";
		UiStartingPriceRequiredError	= "(필요함)";
		UiTimeLeftHeader	= "남은 시간";
		UiUnknownError	= "(알수없음)";

	};

	nlNL = {


		-- Section: AskPrice Messages
		AskPriceAd	= "Verkrijg stapel prijzen met %sx[ItemLink] (x = stapelprijs)";
		FrmtAskPriceBuyoutMedianHistorical	= "%sOpkoop-mediaan historisch: %s%s";
		FrmtAskPriceBuyoutMedianSnapshot	= "%sOpkoop-mediaan laatste scan: %s%s";
		FrmtAskPriceDisable	= "AskPrice's %s optie uitgeschakeld";
		FrmtAskPriceEach	= "(%s ieder)";
		FrmtAskPriceEnable	= "AskPrice's %s optie ingeschakeld";
		FrmtAskPriceVendorPrice	= "%sVerkoop aan winkelier voor: %s%s";


		-- Section: Auction Messages
		FrmtActRemove	= "Veiling-id %s verwijderd van huidige AH momentopname.";
		FrmtAuctinfoHist	= "%d historisch";
		FrmtAuctinfoLow	= "Momentopname Laag";
		FrmtAuctinfoMktprice	= "Marktprijs";
		FrmtAuctinfoNolow	= "Item niet gezien in laatste Momentopname";
		FrmtAuctinfoOrig	= "Oorspronkelijk Bod";
		FrmtAuctinfoSnap	= "%d laatste scan";
		FrmtAuctinfoSugbid	= "Startbod";
		FrmtAuctinfoSugbuy	= "Opkoop voorstel";
		FrmtWarnAbovemkt	= "Competitie boven de markt";
		FrmtWarnMarkup	= "Winkelprijs opgehoogd met %s%%";
		FrmtWarnMyprice	= "Gebruik mijn huidige prijs";
		FrmtWarnNocomp	= "Geen concurrentie";
		FrmtWarnNodata	= "Geen gegevens voor HVP";
		FrmtWarnToolow	= "Kan de laagste prijs niet matchen";
		FrmtWarnUndercut	= "Onderbieden met %s%%";
		FrmtWarnUser	= "Gebruik gebruikersprijs";


		-- Section: Bid Messages
		FrmtAlreadyHighBidder	= "Al hoogste bieder op veiling: %s (x%d)";
		FrmtBidAuction	= "Geboden op veiling: %s (x%d)";
		FrmtBidQueueOutOfSync	= "Error: ongesynchroniseerde bod rij";
		FrmtBoughtAuction	= "Veiling opgekocht: %s (x%d)";
		FrmtMaxBidsReached	= "Meer veilingen van %s (x%d) gevonden, maar bodlimiet bereikt (%d)";
		FrmtNoAuctionsFound	= "Geen veilingen gevonden: %s (x%d)";
		FrmtNoMoreAuctionsFound	= "Geen verdere veilingen gevonden: %s (x%d)";
		FrmtNotEnoughMoney	= "Niet genoeg geld om te bieden op veiling: %s (x%d)";
		FrmtSkippedAuctionWithHigherBid	= "Veiling met hoger bod overgeslagen: %s (x%d)";
		FrmtSkippedAuctionWithLowerBid	= "Veiling met lager bod overgeslagen: %s (x%d)";
		FrmtSkippedBiddingOnOwnAuction	= "Bieden op eigen veiling overgeslagen: %s (x%d)";
		UiProcessingBidRequests	= "Bezig biedingen te verwerken...";


		-- Section: Command Messages
		ConstantsCritical	= "KRITIEK: Je Auctioneer SavedVariables bestand is %.3f%% vol!";
		ConstantsMessage	= "Je Auctioneer SavedVariables bestand is %.3f%% vol";
		ConstantsWarning	= "WAARSCHUWING: Je Auctioneer SavedVariables bestand is %.3f%% vol";
		FrmtActClearall	= "Alle veiling-gegevens voor %s worden verwijderd";
		FrmtActClearFail	= "Kan item niet vinden: %s";
		FrmtActClearOk	= "Veiling-gegevens voor item verwijderd: %s";
		FrmtActClearsnap	= "Bezig huidige AH momentopname te wissen";
		FrmtActDefault	= "Auctioneers %s optie is hersteld naar zijn standaardwaarde";
		FrmtActDefaultall	= "Alle Auctioneer opties zijn hersteld naar de standaardwaarden.";
		FrmtActDisable	= "Verberg item's %s gegevens";
		FrmtActEnable	= "Toon item's %s gegevens";
		FrmtActSet	= "%s op '%s' gezet";
		FrmtActUnknown	= "Onbekend commando of sleutelwoord: '%s'";
		FrmtAuctionDuration	= "Standaard veilingduur ingesteld op: %s";
		FrmtAutostart	= "Automatisch veiling gemaakt voor %s: %s minimum, %s buyout (%d uur) %s";
		FrmtFinish	= "Nadat een scan is afgelopen, zullen we %s";
		FrmtPrintin	= "Auctioneers berichten worden nu naar het \"%s\" chat frame geprint";
		FrmtProtectWindow	= "AH-venster bescherming ingesteld op: %s";
		FrmtUnknownArg	= "'%s' is geen geldig argument voor '%s'";
		FrmtUnknownLocale	= "De opgegeven taal ('%s') is onbekend. Geldige talen zijn:";
		FrmtUnknownRf	= "Ongeldige parameter ('%s'). De parameter moet zo geformatteerd zijn: [realm]-[faction]. Bijvoorbeeld: Al'Akir-Horde";


		-- Section: Command Options
		OptAskPriceSend	= "(<SpelerNaam> <AskPrice Vraag>)";
		OptBidbroker	= "<opbrengst in zilver>";
		OptBidLimit	= "<nummer>";
		OptBroker	= "<opbrengst in zilver>";
		OptCompete	= "<verschil in zilver>";
		OptLocale	= "<taal>";
		OptPctBidmarkdown	= "<procent>";
		OptPctMarkup	= "<procent>";
		OptPctMaxless	= "<procent>";
		OptPctNocomp	= "<procent>";
		OptPctUnderlow	= "<procent>";
		OptPctUndermkt	= "<procent>";
		OptPercentless	= "<procent>";
		OptPrintin	= "(<frameIndex>[Nummer]|<frameNaam>[Tekst])";
		OptScale	= "<schaalfactor>";
		OptScan	= "<>";


		-- Section: Commands
		CmdAskPriceSend	= "stuur";
		CmdAskPriceWhispers	= "fluister berichten";
		CmdAskPriceWord	= "woord";
		CmdFinishSound	= "einde geluid";


		-- Section: Config Text
		GuiAlso	= "Toon ook gegevens voor";
		GuiAlsoDisplay	= "Gegevens voor %s worden getoond";
		GuiAlsoOff	= "Andere realm-faction gegevens worden niet meer getoond.";
		GuiAlsoOpposite	= "Gegevens voor tegengestelde faction worden nu ook getoond.";
		GuiAskPrice	= "Gebruik AskPrice";
		GuiAskPriceAd	= "Stuur nieuwe features";
		GuiAskPriceGuild	= "Reageer op guildchat vragen";
		GuiAskPriceHeader	= "AskPrice opties";
		GuiAskPriceHeaderHelp	= "Verander AskPrice's gedrag";
		GuiAskPriceParty	= "Reageer op partychat vragen";
		GuiAskPriceSmart	= "Gebruik smartwords";
		GuiAskPriceTrigger	= "VraagPrijs trigger";
		GuiAskPriceVendor	= "Verstuur verkoper info";
		GuiAskPriceWhispers	= "Toon uitgaande privéberichten";
		GuiAskPriceWord	= "Custom SmartWord %d";
		GuiAuctionDuration	= "Standaard veiling duur";
		GuiAuctionHouseHeader	= "Veiling venster";
		GuiAuctionHouseHeaderHelp	= "Verander de standaard instellingen van het veiling venster";
		GuiAutofill	= "Vul prijzen in de AH automatisch aan";
		GuiAverages	= "Toon gemiddelden";
		GuiBidmarkdown	= "Bod verlaag percentage";
		GuiClearall	= "Verwijder alle auctioneer data";
		GuiClearallButton	= "Verwijder alles";
		GuiClearallHelp	= "Klik hier om alle auctioneer data voor de huidige realm te verwijderen";
		GuiClearallNote	= "voor de huidige server-factie";
		GuiClearHeader	= "Verwijder data";
		GuiClearHelp	= "Verwijdert auctioneer data. Selecteer alle data of de laatste scan. WAARSCHUWING: Deze acties zijn onomkeerbaar";
		GuiClearsnap	= "Verwijder scan data";
		GuiClearsnapButton	= "Verwijder scan";
		GuiClearsnapHelp	= "Klik hier om de data van de laatste scan te verwijderen";
		GuiDefaultAll	= "Herstel alle auctioneer opties";
		GuiDefaultAllButton	= "Herstel alles";
		GuiDefaultAllHelp	= "Klik hier om alle auctioneer opties te herstellen naar de originele waarden. WAARSCHUWING: Deze actie is onomkeerbaar.";
		GuiDefaultOption	= "Herstel deze instelling";
		GuiEmbed	= "Intergreer info in de in-game tooltip";
		GuiEmbedBlankline	= "Toon een lege regel in de in-game tooltip";
		GuiEmbedHeader	= "Intergreer";
		GuiFinish	= "Nadat een scan is voltooid";
		GuiFinishSound	= "Speel geluid na het voltooien van een scan";
		GuiLink	= "Toon linkID";
		GuiLoad	= "Laad Auctioneer";
		GuiLoad_Always	= "altijd";
		GuiLoad_AuctionHouse	= "bij het veilinghuis";
		GuiLoad_Never	= "nooit";
		GuiLocale	= "Stel de localisering in op";
		GuiMainEnable	= "Gebruik Auctioneer";
		GuiMainHelp	= "Bevat instellingen voor auctioneer, een AddOn die item info toont en auctionhouse data analiseert. Klik de 'scan' knop bij de auctionhouse om veiling gegevens te verzamelen";
		GuiMarkup	= "Verkoper prijs ophoog percentage";
		GuiMaxless	= "Max markt onderbod percentage";
		GuiMedian	= "Toon gemiddelden";
		GuiNocomp	= "Onderbod percentage zonder concurentie";
		GuiNoWorldMap	= "Auctioneer: Tonen van de wereldkaart onderdrukt";
		GuiOtherHeader	= "Andere opties";
		GuiOtherHelp	= "Andere auctioneer opties";
		GuiPercentsHeader	= "Auctioneer grens percentages";
		GuiPercentsHelp	= "WAARSCHUWING: De volgende instellingen zijn ALLEEN voor ervaren gebruikers. Pas de volgende waarden aan om te veranderen hoe aggressief auctioneer is bij het bepalen van winstgevende waarden";
		GuiPrintin	= "Selecteer het gewenste berichtscherm";
		GuiProtectWindow	= "Voorkom per ongeluk sluiten van het AH venster";
		GuiRedo	= "Toon langdurige scan waarschuwing";
		GuiReloadui	= "Herlaad gebruikers interface";
		GuiReloaduiButton	= "ReloadUI";
		GuiReloaduiFeedback	= "Nu de WoW UI aan het herladen";
		GuiReloaduiHelp	= "Klik hier om de WOW Gebruikers interface te herladen na het aanpassen van de localisatie zodat de taal in dit configuratiescherm gelijk wordt aan de gekozen taal. Let op: Dit kan enkele minuten duren.";
		GuiRememberText	= "Onthoud prijs";
		GuiStatsEnable	= "Toon statistieken";
		GuiStatsHeader	= "Item prijs statistieken";
		GuiStatsHelp	= "Toon de volgende statistieken in de tooltip";
		GuiSuggest	= "Toon geadviseerde prijs";
		GuiUnderlow	= "Laagste veiling onderbod";
		GuiUndermkt	= "Onderbied de maxloze markt";
		GuiVerbose	= "Verbose modus";
		GuiWarnColor	= "Kleur prijzenmodel";


		-- Section: Conversion Messages
		MesgConvert	= "Auctioneer Database Conversie. Backup uw SavedVariables\\Auctioneer.lua eerst. %s%s";
		MesgConvertNo	= "Uitschakelen van Auctioneer";
		MesgConvertYes	= "Converteer";
		MesgNotconverting	= "Auctioneer converteert uw database niet. Het zal dan ook niet functioneren totdat u dit wel doet.";


		-- Section: Game Constants
		TimeLong	= "Lang";
		TimeMed	= "Gemiddeld";
		TimeShort	= "Kort";
		TimeVlong	= "Zeer Lang";


		-- Section: Generic Messages
		ConfirmBidBuyout	= "Weet je zeker dat je dit wilt %s?\n%dx%s voor:";
		DisableMsg	= "Automatisch laden van Auctioneer uitgeschakeld";
		FrmtWelcome	= "Auctioneer v%s geladen";
		MesgNotLoaded	= "Auctioneer is niet geladen. Type /auctioneer voor meer info.";
		StatAskPriceOff	= "AskPrice is nu uitgeschakeld.";
		StatAskPriceOn	= "AskPrice is nu ingeschakeld.";
		StatOff	= "Veiling-gegevens worden niet weergegeven";
		StatOn	= "Ingestelde veiling-gegevens worden weergegeven";


		-- Section: Generic Strings
		TextCombat	= "Gevecht";
		TextGeneral	= "Algemeen";
		TextNone	= "geen";
		TextScan	= "Scan";
		TextUsage	= "Gebruik:";


		-- Section: Help Text
		HelpAlso	= "Toon ook gegevens van een andere server in de tooltip. Vul bij 'realm' de realmnaam in en bij 'faction' de naam van de faction. Bijvoorbeeld: \"/auctioneer also Al'Akir-Horde\". Het speciale sleutelwoord \"opposite\" betekent de andere faction, \"off\" schakelt de functionalitiet uit.";
		HelpAskPrice	= "Zet AskPrice aan of uit.";
		HelpAskPriceAd	= "Zet de nieuwe reclame-feature van AskPrice aan of uit.";
		HelpAskPriceGuild	= "Reageer op vragen in de guildchat.";
		HelpAskPriceParty	= "Reageer op vragen in de partychat.";
		HelpAskPriceSend	= "Stuur een speler handmatig het resultaat van een AskPrice vraag.";
		HelpAskPriceSmart	= "Zet SmartWords controle aan of uit.";
		HelpAskPriceTrigger	= "Verander het trigger-karakter van AskPrice.";
		HelpAskPriceVendor	= "Zet het verzenden van verkoper gegevens aan of uit.";
		HelpAskPriceWhispers	= "Zet het verbergen van alle uitgaande AskPrice privéberichten aan of uit.";
		HelpAskPriceWord	= "Voeg persoonlijke AskPrice SmartWords toe of verander ze.";
		HelpAuctionClick	= "Stelt je in staat automatisch een veiling te beginnen voor een item in je inventaris door Alt-Klik.";
		HelpAuctionDuration	= "Stel de standaard veilingduur in met het openen van het AH venster";
		HelpAutofill	= "Stel in of prijzen automatisch ingevuld moeten worden wanneer er een item op de AH wordt gezet.";
		HelpAverage	= "Selecteer of de gemiddelde veilingprijs van items getoond moet worden";
		HelpBidbroker	= "Toon kort of gemiddeld durende veilingen van de recente scan waar met een bod winst te behalen is.";
		HelpBidLimit	= "Maximum aantal veilingen om op te bieden of op te kopen wanneer op de bod- of opkoopknop wordt geklikt in het Zoek Veilingen tabblad.";
		HelpBroker	= "Toon veilingen van de recentste scan waar op geboden kan worden om door te verkopen met winst.";
		HelpClear	= "Wis de data voor het aangegeven item (voeg de items in het commando met shift-klik). Je kunt ook de speciale sleutelwoorden \"all\" of \"snapshot\" aangeven.";
		HelpCompete	= "Toon alle recent gescande veilingen waarvan de opkoopprijs minder is dan die van een van jouw items.";
		HelpDefault	= "Zet een Auctioneer-optie op zijn standaardwaarde. Je kunt ook het speciale keyword \"all\" gebruiken om alle Auctioneer-opties op hun standaardwaarde te zetten.";
		HelpDisable	= "Stopt het automatisch laden van Auctioneer de volgende keer dat je inlogt.";
		HelpEmbed	= "Integreer de tekst in het originele spel tooltip (NB.: Bepaalde features worden uitgezet wanneer dit geselecteerd is)";
		HelpEmbedBlank	= "Selecteer of een lege regel getoond moet worden tussen de tooltip info en de auction info als embedded mode aan staat.";
		HelpFinish	= "Geef aan of World of Warcraft automatich moet afsluiten als het Scannen van het veilinghuis compleet is.";
		HelpFinishSound	= "Zet het spelen van een geluid aan aan het einde van een Auction House scan.";
		HelpLink	= "Selecteer of het link id in de tooltip getoond moet worden";
		HelpLoad	= "Verander Auctioneer's laad settings voor dit karakter.";
		HelpLocale	= "Verander de taal die gebruikt wordt om Auctioneer berichten te tonen.";
		HelpMedian	= "Selecteer dat de median buyout prijs van het item wordt getoond.";
		HelpOnoff	= "Zet het tonen van veilinggegevens aan en uit.";
		HelpPctBidmarkdown	= "Zet het percentage waarmee Auctioneer de bid-prijs onder de buyout prijs noteert.";
		HelpPctMarkup	= "Het percentage waarmee vendor prijzen hoger genoteerd worden wanneer geen andere waarden beschikbaar zijn";
		HelpPctMaxless	= "Legt percentage vast tot waar Auctioneer de markt prijs blijft onderbieden voordat het opgeeft";
		HelpPctNocomp	= "Het percentage waarmee Auctioneer onder de marktprijs bied als er geen concurentie is";
		HelpPctUnderlow	= "Legt het percentage vast waarmee Auctioneer onder de laagste auction prijs bied";
		HelpPctUndermkt	= "Percentage waarmee de marktprijs onderboden wordt wanneer de prijs van de concurentie niet meer onderboden kan worden (vanwege maxless)\n";
		HelpPercentless	= "Toon alle recent gescande veilingen waarvan de opkoopprijs een bepaald percentage minder is dan de maximale verkoopprijs.";
		HelpPrintin	= "Selecteer in welk frame Auctioneer zijn berichten toont. Je kunt of de naam van het frame of de index aangeven.";
		HelpProtectWindow	= "Voorkom dat je perongeluk het veilinghuis interface sluit";
		HelpRedo	= "Selecteer of je een waarschuwing wilt krijgen als de te scennen pagina van het veilinghuis er te lang over doet door een server probleem (Server Lag)";
		HelpScan	= "Doe een Veilinghuis scan bij het eerstvolgende bezoek aan het veilinghuis, of gelijk als je er al bent (er is ook een knop in het veilinghuis paneel) Kies welke catagorieen je wild scannen met de checkboxen (naast de catagorieen)";
		HelpStats	= "Selecteer of je het bod of opkoop percentage van items wilt zien.";
		HelpSuggest	= "Selecteer of je de adviesprijs wilt zien.";
		HelpUpdatePrice	= "Past automatisch de startprijs aan van een veiling in de \"plaats veiling tab\" als de opkoop prijs verandert";
		HelpVerbose	= "Selecteerd of gemiddelden en suggesties voledig getoond moeten worden (of off om ze op een enkele regel te tonen).\n";
		HelpWarnColor	= "Selecteer of het huidige AH prijs model (b.v. Undercutting by...) getoond moet worden in intuitieve kleuren.\n";


		-- Section: Post Messages
		FrmtNoEmptyPackSpace	= "Geen lege ruimte gevonden om veiling te starten!";
		FrmtNotEnoughOfItem	= "Niet genoeg %s gevonden om veiling te starten!";
		FrmtPostedAuction	= "1 Veiling van %s (x%d) geplaatst";
		FrmtPostedAuctions	= "%d veilingen van %s (x%d) geplaatst";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "HuidigBod";
		FrmtBidbrokerDone	= "Bod bepalen voltooid";
		FrmtBidbrokerHeader	= "Minimum winst: %s, HVP ='Hoogst Verkoopbare Prijs'";
		FrmtBidbrokerLine	= "%s, Laatst %s gezien, HVP: %s, %s, Winst: %s, Tijd: %s";
		FrmtBidbrokerMinbid	= "MinBod";
		FrmtBrokerDone	= "Prijsbepaling voltooid";
		FrmtBrokerHeader	= "Minimale winst: %s, HVP ='Hoogst Verkoopbare Prijs'";
		FrmtBrokerLine	= "%s, Laatst %s gezien, HVP: %s, BO: %s, Winst: %s";
		FrmtCompeteDone	= "Concurerende veilingen voltooid";
		FrmtCompeteHeader	= "Concurerende veilingen ten minste %s minder per item";
		FrmtCompeteLine	= "%s, Bod: %s, BO %s vs %s, %s minder";
		FrmtHspLine	= "Hoogst Verkoopbare Prijs voor 1 %s is: %s";
		FrmtLowLine	= "%s, BO: %s, Verkopen: %s, Voor 1: %s, Minder dan gemiddeld: %s";
		FrmtMedianLine	= "Van de laatste %d gezien, gemiddelde BO voor 1 %s is: %s";
		FrmtNoauct	= "Geen veilingen gevonden voor item: %s";
		FrmtPctlessDone	= "Procenten minder voltooid";
		FrmtPctlessHeader	= "Procent minder dan Hoogst verkoopbare prijs (HVP): %d%%";
		FrmtPctlessLine	= "%s, Laatste %d gezien, HVP: %s, BO: %s, Winst: %s, Minder: %s";


		-- Section: Scanning Messages
		AuctionDefunctAucts	= "Niet meer bestaande veilingen verwijderd: %s";
		AuctionDiscrepancies	= "Discrepanties: %s";
		AuctionNewAucts	= "Nieuwe veilingen gescand: %s";
		AuctionPageN	= "Auctioneer: scannen van %s pagina %d van %d Veilingen per seconde: %s Verwachte tijdsduur: %s";
		AuctionScanDone	= "Auctioneer: veiling scan klaar";
		AuctionScanNexttime	= "Auctioneer zal een volledige scan uitvoeren de volgende keer dat gepraat wordt met een veilingmeester.";
		AuctionScanNocat	= "U moet tenminste één categorie hebben geselecteerd om te kunnen scannen.";
		AuctionScanRedo	= "Huidige pagina deed er meer dan %d secondes over om te laden, nieuwe poging.";
		AuctionScanStart	= "Auctioneer: scannen %s pagina 1...";
		AuctionTotalAucts	= "Totaal aantal veilingen gescand: %s";


		-- Section: Tooltip Messages
		FrmtInfoAlsoseen	= "%d keer gezien voor %s";
		FrmtInfoAverage	= "%s min/%s BO (%s bod)";
		FrmtInfoBidMulti	= "Boden (%s%s ea)";
		FrmtInfoBidOne	= "Boden%s";
		FrmtInfoBidrate	= "%d%% hebben een bod, %d%% hebben BO";
		FrmtInfoBuymedian	= "BO gemiddelde";
		FrmtInfoBuyMulti	= "Buyout (%s%s ea)";
		FrmtInfoBuyOne	= "Buyout%s";
		FrmtInfoForone	= "Voor 1: %s min/%s BO (%s geboden) [in %d's]";
		FrmtInfoHeadMulti	= "Gemiddelden voor %d items:";
		FrmtInfoHeadOne	= "Gemiddelden voor dit item";
		FrmtInfoHistmed	= "Laatste %d, gemiddelde BO (ea)";
		FrmtInfoMinMulti	= "Begin bod (%s ea)";
		FrmtInfoMinOne	= "Begin bod";
		FrmtInfoNever	= "Nooit gezien in %s";
		FrmtInfoSeen	= "Totaal %d keer gezien bij de AH";
		FrmtInfoSgst	= "Geadviseerde prijs: %s min/%s BO";
		FrmtInfoSgststx	= "Geadviseerde prijs voor jouw %d stack: %s min/%s BO";
		FrmtInfoSnapmed	= "%d gescanned, gemiddelde BO (ea)";
		FrmtInfoStacksize	= "Gemiddelde stack grootte: %d items";


		-- Section: User Interface
		FrmtLastSoldOn	= "Laatst Verkocht op %s";
		UiBid	= "Bod";
		UiBidHeader	= "Bod";
		UiBidPerHeader	= "Bod Per";
		UiBuyout	= "Opkoop";
		UiBuyoutHeader	= "Opkoop";
		UiBuyoutPerHeader	= "Opkoop Per";
		UiBuyoutPriceLabel	= "Opkoopprijs:";
		UiBuyoutPriceTooLowError	= "(Te laag)";
		UiCategoryLabel	= "Categorie beperking:";
		UiDepositLabel	= "Storting:";
		UiDurationLabel	= "Duur:";
		UiItemLevelHeader	= "Lvl";
		UiMakeFixedPriceLabel	= "Maak vaste prijs";
		UiMaxError	= "(%d Max)";
		UiMaximumPriceLabel	= "Maximum Prijs:";
		UiMaximumTimeLeftLabel	= "Maximale Tijd Over:";
		UiMinimumProfitLabel	= "Minimale Opbrengst:";
		UiMinimumQualityLabel	= "Minimum Kwaliteit:";
		UiMinimumUndercutLabel	= "Minimum Onderbieding:";
		UiNameHeader	= "Naam";
		UiNoPendingBids	= "Alle bodverzoeken compleet!";
		UiNotEnoughError	= "(Niet genoeg)";
		UiPendingBidInProgress	= "1 bodverzoek in behandeling...";
		UiPendingBidsInProgress	= "%d bodverzoeken in behandeling...";
		UiPercentLessHeader	= "Pct";
		UiPost	= "Plaats";
		UiPostAuctions	= "Plaats Veiling";
		UiPriceBasedOnLabel	= "Prijs Gebaseerd Op:";
		UiPriceModelAuctioneer	= "Auctioneer Prijs";
		UiPriceModelCustom	= "Eigen Prijs";
		UiPriceModelFixed	= "Vaste Prijs";
		UiPriceModelLastSold	= "Laatste verkoopprijs";
		UiProfitHeader	= "Winst";
		UiProfitPerHeader	= "Winst Per";
		UiQuantityHeader	= "Hoev.";
		UiQuantityLabel	= "Hoeveelheid:";
		UiRemoveSearchButton	= "Verwijder";
		UiSavedSearchLabel	= "Bewaarde zoekopdrachten:";
		UiSaveSearchButton	= "Bewaar";
		UiSaveSearchLabel	= "Bewaar deze zoekopdracht:";
		UiSearch	= "Zoek";
		UiSearchAuctions	= "Zoek Veilingen";
		UiSearchDropDownLabel	= "Zoek:";
		UiSearchForLabel	= "Zoek Naar Item:";
		UiSearchTypeBids	= "Biedingen";
		UiSearchTypeBuyouts	= "Opkopingen";
		UiSearchTypeCompetition	= "Concurrentie";
		UiSearchTypePlain	= "Item";
		UiStacksLabel	= "Stapels";
		UiStackTooBigError	= "(Stapel Te Groot)";
		UiStackTooSmallError	= "(Stapel Te Klein)";
		UiStartingPriceLabel	= "Start Prijs:";
		UiStartingPriceRequiredError	= "(Benodigd)";
		UiTimeLeftHeader	= "Tijd over";
		UiUnknownError	= "(Onbekend)";

	};

	ptPT = {


		-- Section: AskPrice Messages
		AskPriceAd	= "Obtenha preço da pilha com %sx[ItemLink] (x = stacksize) ";
		FrmtAskPriceBuyoutMedianHistorical	= "%sHistórico médio das vendas: %s%s ";
		FrmtAskPriceBuyoutMedianSnapshot	= "%sHistorico medio do ultimo scan: %s%s ";
		FrmtAskPriceDisable	= "Desativar perguntar preço";
		FrmtAskPriceEach	= "(%s cada)";
		FrmtAskPriceEnable	= "Activar perguntar preço %s";
		FrmtAskPriceVendorPrice	= "%sVenda para fornecedor por: %s%s ";


		-- Section: Auction Messages
		FrmtActRemove	= "Removendo %s da image corrente da AH";
		FrmtAuctinfoHist	= "%d historial";
		FrmtAuctinfoLow	= "Preço mais baixo";
		FrmtAuctinfoMktprice	= "Preço de mercado";
		FrmtAuctinfoNolow	= "Objecto não visto no último leilão";
		FrmtAuctinfoOrig	= "Oferta original";
		FrmtAuctinfoSnap	= "%d do último scan";
		FrmtAuctinfoSugbid	= "Oferta inicial";
		FrmtAuctinfoSugbuy	= "Preço de saida proposto";
		FrmtWarnAbovemkt	= "Preço acima do mercado";
		FrmtWarnMarkup	= "Colocando preço %s%% acima do vendedor";
		FrmtWarnMyprice	= "Usando preço actual";
		FrmtWarnNocomp	= "Sem competição";
		FrmtWarnNodata	= "Sem informaçãoo para preço mais alto";
		FrmtWarnToolow	= "Impossivel igualar preço minimo";
		FrmtWarnUndercut	= "Baixando o preço em %s%%";
		FrmtWarnUser	= "Usando o seu preço actual";


		-- Section: Bid Messages
		FrmtAlreadyHighBidder	= "Esse bid é teu: %s (x%d) ";
		FrmtBidAuction	= "Bid no leilão: %s (x%d)";
		FrmtBidQueueOutOfSync	= "Error: Bid queue out of sync!\nErro: Fila de ofertas fora de sincronia!";
		FrmtBoughtAuction	= "Leilão comprado: %s (x%d)";
		FrmtMaxBidsReached	= "Mais auctions de %s (x%d)encontrado, mas ofereça o limite alcançado (%d)";
		FrmtNoAuctionsFound	= "Nenhum leilão encontrado: %s (x%d)";
		FrmtNoMoreAuctionsFound	= "Não mais auctions encontrados: %s (x%d)";
		FrmtNotEnoughMoney	= "Não bastante dinheiro a oferecer no auction: %s (x%d)";
		FrmtSkippedAuctionWithHigherBid	= "Auction saltado com oferta mais elevada:  %s (x%d)";
		FrmtSkippedAuctionWithLowerBid	= "Auction saltado com oferta mais elevada: %s (x%d)";
		FrmtSkippedBiddingOnOwnAuction	= "Oferecer saltado em próprio auction: %s (x%d)";
		UiProcessingBidRequests	= "Processando pedidos oferecidos...";


		-- Section: Command Messages
		FrmtActClearall	= "Removendo todos dados para o leilÃ£o %s";
		FrmtActClearFail	= "Impossivel encontrar o objeto: %s";
		FrmtActClearOk	= "Removida a informaÃ§Ã£o para o objecto %s";
		FrmtActClearsnap	= "Removendo a informaÃ§Ã£o actual da casa de leilÃµes";
		FrmtActDefault	= "A opÃ§Ã£o %s do Auctioneer foi alterada para o modo original";
		FrmtActDefaultall	= "Todas as opÃ§Ãµes do Auctioneer foram alteradas para o modo original";
		FrmtActDisable	= "Ocultando informaÃ§Ã£o para %s";
		FrmtActEnable	= "Mostrando informaÃ§Ã£o para %s";
		FrmtActSet	= "%s alterado para '%s'";
		FrmtActUnknown	= "Comando ou palavra-chave desconhecida: '%s'";
		FrmtAuctionDuration	= "Tempo da acÃ§Ã£o original mudado para: %s";
		FrmtAutostart	= "Mudando leilÃ£o automÃ¡tico para %s minimo, %s preÃ§o de saÃ­da (%dh)\n%s";
		FrmtFinish	= "Depois de uma pesquisa terminar, nós faremos %s";
		FrmtPrintin	= "Mensagens do Auctioneer vÃ£o agora ser mostradas na janela de comunicaÃ§Ã£o \"%s\"";
		FrmtProtectWindow	= "ProtecÃ§Ã£o da janela de leilÃµes mudada para: %s";
		FrmtUnknownArg	= "'%s' nÃ£o Ã© um argumento valido para '%s'";
		FrmtUnknownLocale	= "A localizaÃ§Ã£o que especificou ('%s') Ã© desconhecida. LocalizaÃ§Ãµes vÃ¡lidas sÃ£o:";
		FrmtUnknownRf	= "Parametro invÃ¡lido ('%s'). O parametro tem de estar na forma: [reino]-[facÃ§Ã£o]. Por exemplo: Al'Akir-Horde";


		-- Section: Command Options
		OptAlso	= "(reino-facÃ§Ã£o|oposto)";
		OptAuctionDuration	= "(última||2h||8h||24h)";
		OptBidbroker	= "<proveito_prata>";
		OptBidLimit	= "<número>";
		OptBroker	= "<proveito_prata>";
		OptClear	= "([Item]|todo|imagem)";
		OptCompete	= "<prata_menos>";
		OptDefault	= "(<opÃ§Ã£o>|todo)";
		OptFinish	= "(desligar||sair||terminar)";
		OptLocale	= "<localidade>";
		OptPctBidmarkdown	= "<porcento>";
		OptPctMarkup	= "<porcento>";
		OptPctMaxless	= "<porcento>";
		OptPctNocomp	= "<porcento>";
		OptPctUnderlow	= "<porcento>";
		OptPctUndermkt	= "<porcento>";
		OptPercentless	= "<porcento>";
		OptPrintin	= "(<indiceJanela>[NÃºmero]|<nomeJanela>[Serie])";
		OptProtectWindow	= "(nunca||pesquisa||sempre)";
		OptScale	= "<factor_escala>";
		OptScan	= "parâmetro de pesquisa";


		-- Section: Commands
		CmdAlso	= "tambÃ©m";
		CmdAlsoOpposite	= "oposto";
		CmdAlt	= "alt";
		CmdAskPriceAd	= "ad";
		CmdAskPriceGuild	= "guild ";
		CmdAskPriceParty	= "party";
		CmdAskPriceSmart	= "esperto";
		CmdAskPriceSmartWord1	= "que";
		CmdAskPriceSmartWord2	= "valor";
		CmdAskPriceTrigger	= "disparador";
		CmdAskPriceVendor	= "vendor";
		CmdAskPriceWhispers	= "suspiros";
		CmdAskPriceWord	= "palavra";
		CmdAuctionClick	= "click-leilÃ£o";
		CmdAuctionDuration	= "duraÃ§Ã£o-leilÃ£o";
		CmdAuctionDuration0	= "último";
		CmdAuctionDuration1	= "2h";
		CmdAuctionDuration2	= "8h";
		CmdAuctionDuration3	= "24h";
		CmdAutofill	= "autoinserir";
		CmdBidbroker	= "corretor-ofertas";
		CmdBidbrokerShort	= "co";
		CmdBidLimit	= "ofereç-limite";
		CmdBroker	= "corretor";
		CmdClear	= "limpar";
		CmdClearAll	= "tudo";
		CmdClearSnapshot	= "imagem";
		CmdCompete	= "competir";
		CmdCtrl	= "ctrl";
		CmdDefault	= "iriginal";
		CmdDisable	= "desligar";
		CmdEmbed	= "integrado";
		CmdFinish	= "finish";
		CmdFinish0	= "off";
		CmdFinish1	= "logout";
		CmdFinish2	= "exit";
		CmdFinish3	= "reloadui";
		CmdFinishSound	= "som final";
		CmdHelp	= "ajuda";
		CmdLocale	= "localizaÃ§Ã£o";
		CmdOff	= "desligado";
		CmdOn	= "ligado";
		CmdPctBidmarkdown	= "pct-menosoferta";
		CmdPctMarkup	= "pct-mais";
		CmdPctMaxless	= "pct-semmaximo";
		CmdPctNocomp	= "pct-semcomp";
		CmdPctUnderlow	= "pct-abaixomenor";
		CmdPctUndermkt	= "pct-abaixomercado";
		CmdPercentless	= "sempercentagem";
		CmdPercentlessShort	= "sp";
		CmdPrintin	= "imprimir-em";
		CmdProtectWindow	= "proteger-janela";
		CmdProtectWindow0	= "nunca";
		CmdProtectWindow1	= "scan";
		CmdProtectWindow2	= "sempre";
		CmdScan	= "scan";
		CmdShift	= "shift";
		CmdToggle	= "mudar";
		CmdUpdatePrice	= "update-preço ";
		CmdWarnColor	= "aviso-cor";
		ShowAverage	= "ver-media";
		ShowEmbedBlank	= "ver-integrado-linhavazia";
		ShowLink	= "ver-link";
		ShowMedian	= "ver-mediano";
		ShowRedo	= "ver-aviso";
		ShowStats	= "ver-estatisticas";
		ShowSuggest	= "ver-sugerido";
		ShowVerbose	= "ver-detalhe";


		-- Section: Config Text
		GuiAlso	= "Também mostrar informação para";
		GuiAlsoDisplay	= "Mostrando informação para %s";
		GuiAlsoOff	= "NÃ£o mostrando informação de outro reino-facção";
		GuiAlsoOpposite	= "Mostrando informação da facção oposta";
		GuiAskPrice	= "Permita AskPrice";
		GuiAskPriceAd	= "Emita características ad";
		GuiAskPriceGuild	= "Responda às perguntas do guildchat";
		GuiAskPriceHeader	= "Opções De AskPrice";
		GuiAskPriceHeaderHelp	= "Mude o comportamento de AskPrice";
		GuiAskPriceParty	= "Responda às perguntas do partychat";
		GuiAskPriceSmart	= "Use smartwords";
		GuiAskPriceTrigger	= "Disparador de AskPrice";
		GuiAskPriceVendor	= "Emita o vendor info ";
		GuiAskPriceWhispers	= "Mostrar suspiros enviados";
		GuiAskPriceWord	= "SmartWord regular %d";
		GuiAuctionDuration	= "Duração de leilões pre-definida";
		GuiAuctionHouseHeader	= "Janela da casa de leilões";
		GuiAuctionHouseHeaderHelp	= "Mudar o comportamento da janela da casa de leilões";
		GuiAutofill	= "Auto completar preços na casa de leilões";
		GuiAverages	= "Mostrar medias";
		GuiBidmarkdown	= "Porcento menos oferta";
		GuiClearall	= "Eliminar toda a informação do Auctioneer";
		GuiClearallButton	= "Eliminar tudo";
		GuiClearallHelp	= "Seleccione aqui para eliminar toda a informação do Auctioneer para o reino-facção actual.";
		GuiClearallNote	= "para o reino-facção actual";
		GuiClearHeader	= "Eliminar informação";
		GuiClearHelp	= "Elimina a informação do Auctioneer. Selecione toda a informação ou só a imagem actual. AVISO: Esta alteração é irreversivel.";
		GuiClearsnap	= "Eliminar Imagem actual";
		GuiClearsnapButton	= "Eliminar Imagem";
		GuiClearsnapHelp	= "Pressione aqui para eliminar a ultima imagem de informação do Auctioneer.";
		GuiDefaultAll	= "Reverter todas as opções";
		GuiDefaultAllButton	= "Reverter tudo";
		GuiDefaultAllHelp	= "Pressione aqui para reverter todas as opções do Auctioneer de volta ao inicial. AVISO: Estas acções não são reversiveis.";
		GuiDefaultOption	= "Reverter esta opção";
		GuiEmbed	= "Integrar informação na caixa de ajuda";
		GuiEmbedBlankline	= "Mostrar linha em branco na caixa de ajuda";
		GuiEmbedHeader	= "Integrar";
		GuiFinish	= "Depois da pesquisa acabar";
		GuiFinishSound	= "Tocar som quando acabar scan";
		GuiLink	= "Mostrar LinkID";
		GuiLoad	= "Carregar o Auctioneer";
		GuiLoad_Always	= "sempre";
		GuiLoad_AuctionHouse	= "na casa de leilões";
		GuiLoad_Never	= "nunca";
		GuiLocale	= "Ajustar localidade para";
		GuiMainEnable	= "Activar Auctioneer";
		GuiMainHelp	= "ContÃ©m opções para o Auctioneer, um AddOn que mostra informação acerca de items e analiza a casa de leilões. Pressione \"Scan\" na janela de leilões para receber a informação dos leilões.";
		GuiMarkup	= "Percentagem sobre o vendedor";
		GuiMaxless	= "Percentagem máxima abaixo do mercado";
		GuiMedian	= "Mostrar Medianos";
		GuiNocomp	= "Percentagem sem competição";
		GuiNoWorldMap	= "Auctioneer: suprimiu a mostra do mapa do mundo";
		GuiOtherHeader	= "Outras Opções";
		GuiOtherHelp	= "Opções diversas do Auctioneer";
		GuiPercentsHeader	= "Limites de Percentagem do Auctioneer";
		GuiPercentsHelp	= "AVISO: As seguintes opções são apenas para utilizadores experientes. Ajuste os seguintes valores para mudar o quÃ£o agressivo o Auctioneer vai ser quando decidindo valores proveitosos.";
		GuiPrintin	= "Seleccione a janela desejada";
		GuiProtectWindow	= "Prevenir o encerrar acidental da janela de leilões";
		GuiRedo	= "Mostrar advertência de scan longo";
		GuiReloadui	= "Recarregar interface de utilizador";
		GuiReloaduiButton	= "RecarregarUI";
		GuiReloaduiFeedback	= "Recarregando o interface do WoW";
		GuiReloaduiHelp	= "Pressione aqui para recarregar o interface de utilizador após mudar a localidade para que a linguagem neste ecrã de configuração coincida com a que você escolheu. Nota: Esta operação pode durar alguns minutos.";
		GuiRememberText	= "Recordar preço";
		GuiStatsEnable	= "Mostrar estatísticas";
		GuiStatsHeader	= "Estatístissa de preço de itens";
		GuiStatsHelp	= "Mostrar as seguintes estatísticas na tooltip.";
		GuiSuggest	= "Mostrar preços sugeridos";
		GuiUnderlow	= "Redução de leilão mais baixa";
		GuiUndermkt	= "Abaixo de mercado quando sem máximo";
		GuiVerbose	= "Modo detalhe";
		GuiWarnColor	= "Modelo de coloração dos preços";


		-- Section: Conversion Messages
		MesgConvert	= "ConverÃ§Ã£o da informaÃ§Ã£o do Auctioneer. Por favor guarde uma cÃ³pia de SavedVariables\Auctioneer.lua primeiro. %s%s";
		MesgConvertNo	= "Desactivar Auctioneer";
		MesgConvertYes	= "Converter";
		MesgNotconverting	= "O Auctioneer nÃ£o estÃ¡ a converter a sua base de dados, mas nÃ£o funcionarÃ¡ atÃ© que o faÃ§a.";


		-- Section: Game Constants
		TimeLong	= "Longo";
		TimeMed	= "MÃ©dio";
		TimeShort	= "Curto";
		TimeVlong	= "Muito Longo";


		-- Section: Generic Messages
		DisableMsg	= "Desactivando o carregamento automÃ¡tico do Auctioneer";
		FrmtWelcome	= "Auctioneer v%s inicializado. Boas Compras.";
		MesgNotLoaded	= "O Auctioneer nÃ£o estÃ¡ inicializado. Estreca /auctioneer para mais informaÃ§Ã£o.";
		StatAskPriceOff	= "AskPrice é incapacitado agora.";
		StatAskPriceOn	= "AskPrice é incapacitado agora.";
		StatOff	= "Ocultando informaÃ§Ã£o de leilÃµes";
		StatOn	= "Mostrando informaÃ§Ã£o de leilÃµes";


		-- Section: Generic Strings
		TextCombat	= "Combate";
		TextGeneral	= "Geral";
		TextNone	= "nenhum";
		TextScan	= "Scan";
		TextUsage	= "UtilizaÃ§Ã£o:";


		-- Section: Help Text
		HelpAlso	= "Mostrar também valores de outros servidores na janela. Para o reino, insira o nome do reino e para facção insira o nome da facção. Por exemplo: \"/auctioneer also Al'Akir-Horde\". A palavra chave \"oposto\" significa a facção oposta, \"off\" desliga a funcionalidade.";
		HelpAskPrice	= "Permita ou incapacite AskPrice.";
		HelpAskPriceAd	= "Permita ou incapacite características novas de AskPrice ad.";
		HelpAskPriceGuild	= "Responda às perguntas feitas no bate-papo do guild.";
		HelpAskPriceParty	= "Responda às perguntas feitas no bate-papo do partido.";
		HelpAskPriceSmart	= "Permita ou incapacite verificar de SmartWords.";
		HelpAskPriceTrigger	= "Mude o caráter do disparador de AskPrice.";
		HelpAskPriceVendor	= "Permita ou incapacite a emissão de dados fixando o preço do vendor.";
		HelpAskPriceWhispers	= "Mostrar ou Esconder todos os suspiros de ida do AskPrice.";
		HelpAskPriceWord	= "Adicionar ou Modificar as SmartWords do AskPrice.";
		HelpAuctionClick	= "Permite fazer Alt-Click a um objecto nas suas malas para iniciar automaticamente um leilão desse objecto";
		HelpAuctionDuration	= "Selecciona a duração padrão de leilões ao abrir a janela de leilões";
		HelpAutofill	= "Define se auto-completa preços quando se coloca um novo leilão na janela de leilões";
		HelpAverage	= "Define se mostra o preço médio do produto em leilão";
		HelpBidbroker	= "Mostrar leilães de tempo curto ou médio do recente scan que podem ser comprados para proveito";
		HelpBidLimit	= "Número máximo dos auctions a oferecer sobre ou do buyout quando a tecla da oferta ou do buyout for estalada na aba dos auctions da busca.";
		HelpBroker	= "Mostrar leilÃµes do recente scan que podem ser comprados e depois re-leiloados para proveito";
		HelpClear	= "Eliminar a informação do produto especificado (tem que premir Shift-Clique no(s) produto(s) para o colocar na caixa de texto) Também pode espicificar as palavras-chave \"todo\" ou \"imagem\"";
		HelpCompete	= "Mostrar leilões recentes cujo preço de saÃída seja menor que um dos seus produtos.";
		HelpDefault	= "Reverter uma opção ao seu valor original. Você tambem pode usar a palavra-chave \"tudo\" para reverter todas as opções do Auctioneer ao seu valor inicial.";
		HelpDisable	= "Impede o Auctioneer de carregar automaticamente na proxima vez que entrar no jogo";
		HelpEmbed	= "Inserir o texto na caixa de ajuda original. (note: algumas capacidades são desactivadas quando esta opção é seleccionada)";
		HelpEmbedBlank	= "Selecciona se mostra uma linha branca entre a janela de ajuda e a informação de leilão quando o modo avançado está seleccionado";
		HelpFinish	= "Selecciona se sai ou se termina após o fim de uma pesquisa na casa de leilões";
		HelpFinishSound	= "Escolher se quer tocar um som no fim do scan da Casa de Leilões.";
		HelpLink	= "Seleccionar se mostra o LinkID na janela de ajuda";
		HelpLoad	= "Mudar as opções e carregamento para este personagem";
		HelpLocale	= "Alterar o local que éusado para mostrar mensagens do Auctioneer";
		HelpMedian	= "Define se mostra a media do preço de saida";
		HelpOnoff	= "Define se a informaÃ§Ã£o de leilÃµes estÃ¡ ligada ou desligada";
		HelpPctBidmarkdown	= "Define a percentagem que o Auctioneer vai marcar preÃ§os abaixo do preÃ§o de saÃ­da";
		HelpPctMarkup	= "A percentagem que o preÃ§o de vendedores vai ser inflaccionada quando nÃ£o existem outros valores disponiveis";
		HelpPctMaxless	= "Define a percentagem mÃ¡xima que o Auctioneer vai reduzir em relaÃ§Ã£o ao preÃ§o de mercado antes de desistir";
		HelpPctNocomp	= "A percentagem que o Auctioneer vai reduzir em relaÃ§Ã£o ao preÃ§o de mercado quando nÃ£o existir competÃªncia";
		HelpPctUnderlow	= "Define a percentagem qua o Auctioneer vai reduzir em relaÃ§Ã£o ao leilÃ£o mais baixo";
		HelpPctUndermkt	= "Percentagem a reduzir em relaÃ§Ã£o ao preÃ§o de mercado quando for impossivel bater a competÃªncia (devido ao semmÃ¡ximo)";
		HelpPercentless	= "Mostra qualquer leilÃ£o scaneado recentemente cujo buyout apresenta porcentagem menor do que o mais alto preÃ§o de venda";
		HelpPrintin	= "Seleciona qual janela irÃ¡ mostrar mensagens. VocÃª pode tambÃ©m especificar o nome da janela ou o tÃ­tulo.";
		HelpProtectWindow	= "Previne que vocÃª feche acidentalmente a janela";
		HelpRedo	= "Selecciona se mostra um aviso quando a pagina da AH actualmente a ser pesquisada demorou muito devido a lag no servidor.";
		HelpScan	= "Efectua uma pesquisa da casa de leilÃµes na próxima visita, ou enquanto vocÃª lá está (há tambÃ©m um botÃ£o na janela de leilÃµes). Escolha que categorias quer pesquisar usando as chackboxes.";
		HelpStats	= "Selecionar se mostra as percentagens de licitaçÃ£o/saÃ­ddd os itens.";
		HelpSuggest	= "Selecionar se mostra o preÃ§o de licitaçÃ£o/saÃ­ad dos itens";
		HelpUpdatePrice	= "Atualize automaticamente o preço começando para um auction na aba dos auctions do borne quando o preço buyout muda.";
		HelpVerbose	= "Selecionar se mostra medias e sugestÃµes (ou desligar para mostrá-las numa linha única)";
		HelpWarnColor	= "Selecione se mostrar o atual AH fixando o preço do modelo (que undercutting por...) em cores intuitive.";


		-- Section: Post Messages
		FrmtNoEmptyPackSpace	= "Nenhum espaço vazio do bloco encontrou para criar o auction!";
		FrmtNotEnoughOfItem	= "Não bastantes %s encontrado para criar o auction! ";
		FrmtPostedAuction	= "Afixado 1 auction de %s (x%d)";
		FrmtPostedAuctions	= "Afixado %d auctions de %s (x%d) ";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "curOferta";
		FrmtBidbrokerDone	= "Brokering da oferta feito";
		FrmtBidbrokerHeader	= "Lucro mínimo: %s, HSP = 'Valor de venda mais elevado'";
		FrmtBidbrokerLine	= "%s, visto última vez, HSP: %s, %s: %s, Lucro: %s, Tempo: %s";
		FrmtBidbrokerMinbid	= "liciMin";
		FrmtBrokerDone	= "CorreçÃ£o acabada";
		FrmtBrokerHeader	= "Lucro mínimo: %s, HSP = 'Valor de venda mais elevado'";
		FrmtBrokerLine	= "%s,Último %s visto, HSP: %s, BO: %s, lucro: %s";
		FrmtCompeteDone	= "Auctions competindo feitos.";
		FrmtCompeteHeader	= "Auctions competindo ao menos %s mais menos cada uns.";
		FrmtCompeteLine	= "%s, oferta: %s, BO %s vs %s, %s menos ";
		FrmtHspLine	= "O preço o mais elevado de Sellable para um %s é: %s";
		FrmtLowLine	= "%s, BO:  %s, seller:  %s, para um:  %s, menos do que o número médio:  %s";
		FrmtMedianLine	= "De último %d visto, BO mediano para 1 %s é:  %s";
		FrmtNoauct	= "Nenhum auctions encontrou para o artigo:  %s";
		FrmtPctlessDone	= "Por cento feitos mais menos.";
		FrmtPctlessHeader	= "Preço de Sellable dos por cento menos do que o mais altamente (HSP):  %d%%";
		FrmtPctlessLine	= "%s, último %d visto, HSP:  %s, BO:  %s, prof:  %s, menos %s";


		-- Section: Scanning Messages
		AuctionDefunctAucts	= "Os auctions defunct removeram:  %s";
		AuctionDiscrepancies	= "Discrepâncias:  %s";
		AuctionNewAucts	= "Auctions novos feitos a varredura:  %s";
		AuctionPageN	= "Auctioneer:  página %d da exploração %s de auctions de %d por o segundo:  tempo de %s estimado deixado:  %s";
		AuctionScanDone	= "Auctioneer:  a exploração do auction terminou";
		AuctionScanNexttime	= "Auctioneer irÃ¡ iniciar o full scan na proxima vez que vocÃª falar com o com o auctioneer.";
		AuctionScanNocat	= "Você deve ter ao menos uma categoria selecionada para fazer a varredura";
		AuctionScanRedo	= "A página atual fêz exame de mais do que segundos de %d para terminar, retrying a página";
		AuctionScanStart	= "Auctioneer: Procurando %s pÃ¡gina 1...";
		AuctionTotalAucts	= "Os auctions totais fizeram a varredura: %s";


		-- Section: Tooltip Messages
		FrmtInfoAlsoseen	= "Visto %d vezes em %s";
		FrmtInfoAverage	= "%s min/%s BO (%s oferecido)";
		FrmtInfoBidMulti	= "Ofertas (%s%s ea)";
		FrmtInfoBidOne	= "Com o valor %s";
		FrmtInfoBidrate	= "%d%% tem oferta, %d%% tem compra directa";
		FrmtInfoBuymedian	= "Compra Directa valor mÃ©dio";
		FrmtInfoBuyMulti	= "Compra Directa (%s%s)";
		FrmtInfoBuyOne	= "Compra Directa %s";
		FrmtInfoForone	= "Por 1: %s min/%s BO (%s oferta) [em %d]";
		FrmtInfoHeadMulti	= "Medias por %d unidades:";
		FrmtInfoHeadOne	= "MÃ©dias para esta unidade:";
		FrmtInfoHistmed	= "Ultima vez visto a %d, preÃ§o mÃ©dio (ea)";
		FrmtInfoMinMulti	= "Oferta inicial (%s unidade)";
		FrmtInfoMinOne	= "Oferta inicial";
		FrmtInfoNever	= "Nunca visto na %s";
		FrmtInfoSeen	= "Visto %d vezes em leilÃ£o";
		FrmtInfoSgst	= "PreÃ§o recomendado: %s min/%s BO";
		FrmtInfoSgststx	= "PreÃ§o recomendado para os %d: %s min/%s BO";
		FrmtInfoSnapmed	= "Visto a %d, BO (ea)";
		FrmtInfoStacksize	= "Quantidade mÃ©dia: %d items";


		-- Section: User Interface
		FrmtLastSoldOn	= "Ultima Venda";
		UiBid	= "Oferta";
		UiBidHeader	= "Oferta";
		UiBidPerHeader	= "Oferta Por";
		UiBuyout	= "Compra Directa";
		UiBuyoutHeader	= "Compra Directa";
		UiBuyoutPerHeader	= "Compra Directa Por";
		UiBuyoutPriceLabel	= "Preço de Compra Directa:";
		UiBuyoutPriceTooLowError	= "(Demasiado Baixo)";
		UiCategoryLabel	= "Limitação Da Categoria:";
		UiDepositLabel	= "Depósito:";
		UiDurationLabel	= "Duração:";
		UiItemLevelHeader	= "Nível";
		UiMakeFixedPriceLabel	= "Fazer preço fixo";
		UiMaxError	= "(%d máximo)";
		UiMaximumPriceLabel	= "Preço Máximo:";
		UiMaximumTimeLeftLabel	= "Tempo Máximo Deixado:";
		UiMinimumProfitLabel	= "Lucro Mínimo:";
		UiMinimumQualityLabel	= "Qualidade Mínima:";
		UiMinimumUndercutLabel	= "O Mínimo Cortado:";
		UiNameHeader	= "Nome";
		UiNoPendingBids	= "Todos os pedidos completos!";
		UiNotEnoughError	= "(Não Suficientes)";
		UiPendingBidInProgress	= "1 pedido oferecido em andamento... ";
		UiPendingBidsInProgress	= "%d a oferta pedida em progresso... ";
		UiPercentLessHeader	= "Pct";
		UiPost	= "Postado";
		UiPostAuctions	= "Leilões Postados";
		UiPriceBasedOnLabel	= "Preço Baseado Sobre:";
		UiPriceModelAuctioneer	= "Preço De Auctioneer";
		UiPriceModelCustom	= "Preço Costume";
		UiPriceModelFixed	= "Preço Fixo";
		UiPriceModelLastSold	= "Ultimo Preço Vendido";
		UiProfitHeader	= "Lucro";
		UiProfitPerHeader	= "Lucro Por";
		UiQuantityHeader	= "Qtn";
		UiQuantityLabel	= "Quantidade:";
		UiRemoveSearchButton	= "Apagar";
		UiSavedSearchLabel	= "Salvar pesquisas:";
		UiSaveSearchButton	= "Salvar";
		UiSaveSearchLabel	= "Salvar esta Pesquisa:";
		UiSearch	= "Procurar";
		UiSearchAuctions	= "Procurar Leilões";
		UiSearchDropDownLabel	= "Procurar:";
		UiSearchForLabel	= "Procurar Pelo Item:";
		UiSearchTypeBids	= "Ofertas";
		UiSearchTypeBuyouts	= "Compras Directas";
		UiSearchTypeCompetition	= "Competição";
		UiSearchTypePlain	= "Objecto";
		UiStacksLabel	= "Pacote";
		UiStackTooBigError	= "(Pacote Muito Grande)";
		UiStackTooSmallError	= "(Pacote Muito Pequeno)";
		UiStartingPriceLabel	= "Preço Inicial:";
		UiStartingPriceRequiredError	= "(Requerido)";
		UiTimeLeftHeader	= "Tempo Restante";
		UiUnknownError	= "(Desconhecido)";

	};

	ruRU = {


		-- Section: AskPrice Messages
		AskPriceAd	= "Получите цены на кучу с %sx[ItemLink] (x = размер кучи)";
		FrmtAskPriceBuyoutMedianHistorical	= "%sсредний выкуп за все время: %s%s\n";
		FrmtAskPriceBuyoutMedianSnapshot	= "%sСредний выкуп за посл. сканирование: %s%s";
		FrmtAskPriceDisable	= "Выключение %s опции AskPrice";
		FrmtAskPriceEach	= "(%s каждое)\n";
		FrmtAskPriceEnable	= "Включение %s опции AskPrice\n";
		FrmtAskPriceVendorPrice	= "%s Продажа в магазин: %s%s\n";


		-- Section: Auction Messages
		FrmtActRemove	= "Стираем информацию об аукционе %s из текущего снимка аукционов.";
		FrmtAuctinfoHist	= "%d за все время";
		FrmtAuctinfoLow	= "Нижайшая в снимке";
		FrmtAuctinfoMktprice	= "Рыночная цена";
		FrmtAuctinfoNolow	= "Предмет не увиден в последнем снимке.";
		FrmtAuctinfoOrig	= "Первоначальная ставка";
		FrmtAuctinfoSnap	= "%d последний скан";
		FrmtAuctinfoSugbid	= "Начальная ставка";
		FrmtAuctinfoSugbuy	= "Рекомендуемая цена выкупа";
		FrmtWarnAbovemkt	= "Конкуренция с рынком";
		FrmtWarnMarkup	= "Увеличение цены вендора на %s%%";
		FrmtWarnMyprice	= "Использование моей текущей цены";
		FrmtWarnNocomp	= "Нет конкурентов";
		FrmtWarnNodata	= "Нет данных для макс. цены продажи\n";
		FrmtWarnToolow	= "Невозможно сопоставить самой низкой цене\n";
		FrmtWarnUndercut	= "Уценка на %s%%";
		FrmtWarnUser	= "Цена, определенная пользователем";


		-- Section: Bid Messages
		FrmtAlreadyHighBidder	= "Ваша ставка уже самая высокая: %s (x%d)\n";
		FrmtBidAuction	= "Ставить на аукцион: %s (x%d)\n";
		FrmtBidQueueOutOfSync	= "Ошибка: ошибка последовательности ставок";
		FrmtBoughtAuction	= "Выкуплено: %s (x%d)\n";
		FrmtMaxBidsReached	= "Аукционов %s (x%d) было найдено больше, но лимит ставок достигнут (%d)";
		FrmtNoAuctionsFound	= "Не найдено: %s (x%d)\n";
		FrmtNoMoreAuctionsFound	= "Больше не найдено: %s (x%d)\n";
		FrmtNotEnoughMoney	= "Не хватает денег для ставки на: %s (x%d)";
		FrmtSkippedAuctionWithHigherBid	= "Пропущен аукцион с более высокой заявкой: %s (x%d)\n";
		FrmtSkippedAuctionWithLowerBid	= "Пропущен аукцион с более низкой заявкой: %s (x%d)\n";
		FrmtSkippedBiddingOnOwnAuction	= "Пропущена ставка на собственный аукцион: %s (x%d)";
		UiProcessingBidRequests	= "Обработка запросов на ставки...\n";


		-- Section: Command Messages
		ConstantsCritical	= "КРИТИЧЕСКИ: Ваш файл SavedVariables, используемый для хранения переменных полон на %.3f%% !";
		ConstantsMessage	= "Ваш файл SavedVariables, используемый для хранения переменных полон на %.3f%%";
		ConstantsWarning	= "ВНИМАНИЕ: Ваш файл SavedVariables, используемый для хранения переменных полон на %.3f%%";
		FrmtActClearall	= "Очистка всех данных аукциона для %s\n";
		FrmtActClearFail	= "Невозможно найти предмет: %s";
		FrmtActClearOk	= "Данные предмета удалены: %s\n";
		FrmtActClearsnap	= "Очистка текущего снимка с аукциона.\n";
		FrmtActDefault	= "Настройка аукционера %s была переустановлена на значение по умолчанию";
		FrmtActDefaultall	= "Все настройки аукционера были переустановлены к начальным установкам.\n";
		FrmtActDisable	= "Не показывать %s данные по предмету";
		FrmtActEnable	= "Показывать %s данные по предмету";
		FrmtActSet	= "Установка %s на ' %s'\n";
		FrmtActUnknown	= "Неизвестная команда или ключ: '%s' ";
		FrmtAuctionDuration	= "Продолжительность действия по умолчанию установлена на: %s\n";
		FrmtAutostart	= "Автоматически начинать аукцион для %s: %s минимум, %s выкуп (%dh) %s\n";
		FrmtFinish	= "После сканирования аукциона мы будем %s";
		FrmtPrintin	= "Сообщения аукционера теперь будут выводиться в \"%s\" окне чата\n";
		FrmtProtectWindow	= "Защита окна аукциона установлена на: %s\n";
		FrmtUnknownArg	= "'%s' не является правильным аргументом для '%s'\n";
		FrmtUnknownLocale	= "Локализация, указанная вами ('%s') неправильна. Правильные локализации:";
		FrmtUnknownRf	= "Неверный параметр (' %s'). Ожидаемый формат: [ realm]-[faction ]. Например: Al'Akir-Horde\n";


		-- Section: Command Options
		OptAlso	= "(царство-faction|opposite|home|neutral)";
		OptAskPriceSend	= "(<PlayerName> <AskPrice Query>) ";
		OptAuctionDuration	= "(посл|2ч|8ч|24ч) ";
		OptBidbroker	= "<прибыль_серебро> ";
		OptBidLimit	= "<число>";
		OptBroker	= "<прибыль_серебро>";
		OptClear	= "([предмет]|все|snapshot) ";
		OptCompete	= "<silver_less> ";
		OptDefault	= "(<настройки>|все) ";
		OptFinish	= " (выключить|выйти|выйти|перегрузить)  ";
		OptLocale	= "<локализация> ";
		OptPctBidmarkdown	= "<процент>";
		OptPctMarkup	= "<процент>";
		OptPctMaxless	= "<процент>";
		OptPctNocomp	= "<процент>";
		OptPctUnderlow	= "<процент>";
		OptPctUndermkt	= "<процент>";
		OptPercentless	= "<процент>";
		OptPrintin	= "(<frameIndex>[номер]|<frameName>[String]) ";
		OptProtectWindow	= "(не когда|скан|всёравно) ";
		OptScale	= "<scale_factor> ";
		OptScan	= "<> ";


		-- Section: Commands
		CmdAlso	= "также\n";
		CmdAlsoOpposite	= "противоположно\n";
		CmdAlt	= "alt";
		CmdAskPriceAd	= "объявление\n";
		CmdAskPriceGuild	= "гильдия\n";
		CmdAskPriceParty	= "группа\n";
		CmdAskPriceSend	= "отправить";
		CmdAskPriceSmart	= "умный";
		CmdAskPriceSmartWord1	= "что";
		CmdAskPriceSmartWord2	= "ценность";
		CmdAskPriceTrigger	= "триггер";
		CmdAskPriceVendor	= "продавец";
		CmdAskPriceWhispers	= "приваты";
		CmdAskPriceWord	= "слово";
		CmdAuctionClick	= "аукцион-один клик";
		CmdAuctionDuration	= "аукцион-длительность";
		CmdAuctionDuration0	= "прошлый";
		CmdAuctionDuration1	= "2ч";
		CmdAuctionDuration2	= "8ч";
		CmdAuctionDuration3	= "24ч";
		CmdAutofill	= "автозаполнять  ";
		CmdBidbroker	= "заявко-маклер";
		CmdBidbrokerShort	= "зм";
		CmdBidLimit	= "предел предложения";
		CmdBroker	= "маклер";
		CmdClear	= "убирать";
		CmdClearAll	= "всё";
		CmdClearSnapshot	= "снимок";
		CmdCompete	= "конкурировать";
		CmdCtrl	= "ctrl";
		CmdDefault	= "стандарт";
		CmdDisable	= "отключить";
		CmdEmbed	= "включить";
		CmdFinish	= "конец";
		CmdFinish0	= "выключить";
		CmdFinish1	= "logout";
		CmdFinish2	= "выход";
		CmdFinish3	= "перегрузить интерфейс";
		CmdFinishSound	= "звук по окончанию";
		CmdHelp	= "помощь";
		CmdLocale	= "язык";
		CmdOff	= "выключить";
		CmdOn	= "включить";
		CmdPctBidmarkdown	= "%-марка предложения вниз";
		CmdPctMarkup	= "%-повысить";
		CmdPctMaxless	= "%-mакс меньше";
		CmdPctNocomp	= "%-никакое соревнование";
		CmdPctUnderlow	= "%-под низко";
		CmdPctUndermkt	= "%-под рынком";
		CmdPercentless	= "процент меньше";
		CmdPercentlessShort	= "пм";
		CmdPrintin	= "печать-в";
		CmdProtectWindow	= "защищать-окно";
		CmdProtectWindow0	= "никогда";
		CmdProtectWindow1	= "просмотр";
		CmdProtectWindow2	= "всегда";
		CmdScan	= "просмотр";
		CmdShift	= "shift";
		CmdToggle	= "изменение-пуговицы";
		CmdUpdatePrice	= "цена-на-модернизацию";
		CmdWarnColor	= "предупреждающий цвет";
		ShowAverage	= "показать-среднее";
		ShowEmbedBlank	= "показ включает чистую линию";
		ShowLink	= "показать-связь";
		ShowMedian	= "показать-среднее";
		ShowRedo	= "показать-предупреждения";
		ShowStats	= "показать-статистику";
		ShowSuggest	= "показать-рекомендуемые";
		ShowVerbose	= "показать-расширенно";


		-- Section: Config Text
		GuiAlso	= "Также покажите данные для";
		GuiAlsoDisplay	= "Показываются данные для %s";
		GuiAlsoOff	= "Информация по другим мирам больше не показывается.";
		GuiAlsoOpposite	= "Теперь также показываются данные за противоположные силы.";
		GuiAskPrice	= "Включить AskPrice";
		GuiAskPriceAd	= "Посылать объявления о возможностях";
		GuiAskPriceGuild	= "Отвечать на запросы в чате гильдии";
		GuiAskPriceHeader	= "Настройки AskPrice";
		GuiAskPriceHeaderHelp	= "Изменение поведения AskPrice";
		GuiAskPriceParty	= "Отвечать на запросы в чате группы";
		GuiAskPriceSmart	= "Использовать умные слова";
		GuiAskPriceTrigger	= "AskPrice триггер";
		GuiAskPriceVendor	= "Посылать информацию продавца";
		GuiAskPriceWhispers	= "Показывать исходящие висперы";
		GuiAskPriceWord	= "Собственный настройки SmartWord %d";
		GuiAuctionDuration	= "Продолжительность действия по умолчанию";
		GuiAuctionHouseHeader	= "Окно Аукциона";
		GuiAuctionHouseHeaderHelp	= "Изменение поведения окна Аукциона";
		GuiAutofill	= "Автозаполнение цен на аукционе";
		GuiAverages	= "Показывать Среднее";
		GuiBidmarkdown	= "Скидка с цены выкупа ";
		GuiClearall	= "Очистить все данные аукционера";
		GuiClearallButton	= "Очистить все";
		GuiClearallHelp	= "Нажмите сюда для того, чтобы очистить все данные Аукционера для этого сервера.";
		GuiClearallNote	= "для текущей стороны";
		GuiClearHeader	= "Очистка Данных";
		GuiClearHelp	= "Очищает данные Аукционера. Выберете или все данные, или текущий снимок. ОСТОРОЖНО: эти действия отменить НЕВОЗМОЖНО.";
		GuiClearsnap	= "Очистить данные снимка";
		GuiClearsnapButton	= "Очистить снимок";
		GuiClearsnapHelp	= "Нажмите здесь для того, чтобы очистить данные по последнему снимку Аукционера.";
		GuiDefaultAll	= "Сброс всех настроек Аукционера";
		GuiDefaultAllButton	= "Сбросить все";
		GuiDefaultAllHelp	= "Нажмите здесь, чтобы сбросить все настройки Аукционера к первоначальным значениям. ОСТОРОЖНО: эти действия отменить НЕВОЗМОЖНО.";
		GuiDefaultOption	= "Сбросить эти настройки";
		GuiEmbed	= "Выводить данные в окно предмета";
		GuiEmbedBlankline	= "Добавлять пустую строку";
		GuiEmbedHeader	= "Интеграция";
		GuiFinish	= "После окончания сканирования";
		GuiFinishSound	= "Проигрывать звук по окончанию сканирования аукциона";
		GuiLink	= "Показывать LinkID";
		GuiLoad	= "Загружать Аукционер";
		GuiLoad_Always	= "всегда";
		GuiLoad_AuctionHouse	= "в здании Аукциона";
		GuiLoad_Never	= "никогда";
		GuiLocale	= "Локализация";
		GuiMainEnable	= "Включить Аукционер";
		GuiMainHelp	= "Содержит настройки для Аукционера. АддОна, показывающего информацию о вещах и анализирующего данные с аукциона. Нажмите кнопку \"Скан\" на Аукционе для сбора данных";
		GuiMarkup	= "Процент надбавки от цены вендора";
		GuiMaxless	= "Максимальный процент сбивания рыночной цены";
		GuiMedian	= "Показать средние цены";
		GuiNocomp	= "Процент сбивания цены если нет конкурренции";
		GuiNoWorldMap	= "Ауцкионер: карту мира не показана";
		GuiOtherHeader	= "Прочее";
		GuiOtherHelp	= "Смешанные опции Аукционера";
		GuiPercentsHeader	= "Пороговые величины Аукционера";
		GuiPercentsHelp	= "ВНИМАНИЕ: ТОЛЬКО для опытных пользователей. Настройка значений того, насколько агрессивен будет Аукционер, подбирая доходные значения";
		GuiPrintin	= "Выберите желаемое окно сообщений";
		GuiProtectWindow	= "Защитить от случайного закрытия окна аукциона";
		GuiRedo	= "Показывать предупреждение задержки сканирования";
		GuiReloadui	= "Перезагрузить UI";
		GuiReloaduiButton	= "Перезагрузить UI";
		GuiReloaduiFeedback	= "Перезагружается пользовательский интерфейс";
		GuiReloaduiHelp	= "После смены языка, нажмите здесь чтобы перезагрузить интерфейс, для того чтобы изменения вступили в силу. Эта операция может занять несколько минут. ";
		GuiRememberText	= "Запоминать цену";
		GuiStatsEnable	= "Показать статистику";
		GuiStatsHeader	= "Статистика предмета";
		GuiStatsHelp	= "Показывать следующую статистику в подсказке";
		GuiSuggest	= "Показывать предлагаемые цены";
		GuiUnderlow	= "Самое маленькое сбивание цены";
		GuiUndermkt	= "Сбивание рынка";
		GuiVerbose	= "Многословный режим";
		GuiWarnColor	= "Цветовая подсветка цен";


		-- Section: Conversion Messages
		MesgConvert	= "Необходимо произвести преобразование базы данных Аукционера. Пожалуйста, предварительно сделайте резервные копии файла SavedVariables\\Auctioneer.lua";
		MesgConvertNo	= "Выключить Аукционер";
		MesgConvertYes	= "Преобразовать";
		MesgNotconverting	= "Аукционер не преобразовывает свою базу и не работает.";


		-- Section: Game Constants
		TimeLong	= "Долгий";
		TimeMed	= "Средний";
		TimeShort	= "Короткий";
		TimeVlong	= "Очень долгий";


		-- Section: Generic Messages
		ConfirmBidBuyout	= "Вы уверены, что вы хотите %s\n%dx%s для:";
		DisableMsg	= "Выключение автоматической загрузки Аукционера";
		FrmtWelcome	= "Аукционер v%s загружен";
		MesgNotLoaded	= "Аукционер не загружен. Наберите /auctioneer для дополнительной информации.";
		ScanCancel	= "Сканирование отменено";
		ScanComplete	= "Сканирование завершено";
		ScanFailed	= "Сканирование неудачно";
		StatAskPriceOff	= "AskPrice теперь выключен.";
		StatAskPriceOn	= "AskPrice теперь включен.";
		StatOff	= "Не показывается никакой информации по аукциону";
		StatOn	= "Показывается информация по аукциону";
		UIScanCanceled	= "Аукционер: Сканирование аукциона отменено";
		UIScanComplete	= "Аукционер: Сканирование аукциона завершено";
		UIScanFailed	= "Аукционер: Сканирование аукциона неудачно";


		-- Section: Generic Strings
		TextCombat	= "Бой";
		TextGeneral	= "Основной";
		TextNone	= "нет";
		TextScan	= "Сканировать";
		TextUsage	= "Использование:";


		-- Section: Help Text
		HelpAlso	= "Так же показывать данные других серверов в подсказке. Вставьте имя сервера, и имя фракции. Например: \"/auctioneer also Warsong-Horde\". Слово \"opposite\" обозначает противоположную фракцию, \"off\" - отключает функции.";
		HelpAskPrice	= "Включить или выключить AskPrice";
		HelpAskPriceAd	= "Включить или выключить рекламу новых функций AskPrice";
		HelpAskPriceGuild	= "Отвечать на запросы, сделанные на канале гильдии";
		HelpAskPriceParty	= "Отвечать на запросы, сделанные на канале группы";
		HelpAskPriceSend	= "Отправка ответа на запрос AskPrice в ручную";
		HelpAskPriceSmart	= "Включить или выключить проверку на ключевые слова";
		HelpAskPriceTrigger	= "Изменить переключающий символ AskPrice'а";
		HelpAskPriceVendor	= "Включить или выключить отсылку цен торговца.";
		HelpAskPriceWhispers	= "Включить или выключить все исходящие приваты AskPrice'а";
		HelpAskPriceWord	= "Добавить или изменить ключевые слова AskPrice'а, задаваемые пользователем.";
		HelpAuctionClick	= "Позволяет нажатием Alt-Click на вещи в вашем инвентаре автоматичестки поставить ее на аукцион";
		HelpAuctionDuration	= "Устанавливает продолжительность аукциона, прелагаемую по умолчанию.";
		HelpAutofill	= "Установите, чтобы автоматически заполнять цены при создании нового аукциона";
		HelpAverage	= "Выберите, чтобы показывать среднюю цены на аукционе на эту вещь";
		HelpBidbroker	= "Выберите, какой длительности аукционы с последнего сканирования будут анализироваться на предмет получения прибыли.";
		HelpBidLimit	= "Максимальное количество аукционов на которые делается ставка или выкупается при нажатии на кнопку в окне поиска.";
		HelpBroker	= "Показывает все аукционы с последнего сканирования, на которые может быть сделана ставка с целью дальнейшего получения прибыли.";
		HelpClear	= "Отчищает данные по конкретной вещи (shift-click для вставки названия) Вы также можете использовать слова: \"All\" (все) и \"snapshot\" (последний скан)";
		HelpCompete	= "Показывать любые ранее просканированые аукционы, на которых цена выкупа ниже чем на одну из ваших вещей";
		HelpDefault	= "Установить настройку в значение по умолчанию. Вы также можете использовать ключевое слово \"all\", чтобы установить все настройки Аукционера в их значения по умолчанию.";
		HelpDisable	= "Не загружать Аукционер автоматически при следующем входе в игру.";
		HelpEmbed	= "Встроить текст в оригинальную подсказку игры (некоторые опции выключаются, когда включена эта)";
		HelpEmbedBlank	= "Выбор, показывать ли пустую строку, чтобы отделить информацию Аукционера от остальной, когда включен режим встраивания";
		HelpFinish	= "Выбор, как нужно выходить из игры по окончанию сканирования аукциона";
		HelpFinishSound	= "Выбор, нужно ли проигрывать звук по окончанию сканирования аукциона.";
		HelpLink	= "Выбор, ужно ли поазывать ссылку в подсказке";
		HelpLoad	= "Изменить настройки загрузки Аукционера";
		HelpLocale	= "Изменить локализацию, которая будет использоваться для того, чтобы показывать сообщения Аукционера";
		HelpMedian	= "Выбрать, показывать ли среднюю цену выкупа для венщи";
		HelpOnoff	= "Включает и выключает показ данных аукциона";
		HelpPctBidmarkdown	= "Установка, на сколько Аукционер будет снижать цену от цены выкупа";
		HelpPctMarkup	= "На сколько процентов будет повышаться цена торговца в случае, когда другие способы рассчета цены не возможны.";
		HelpPctMaxless	= "На сколько процентов Аукционер будет просаживать рынок перед тем, как сдаться";


		-- Section: Post Messages
		FrmtNoEmptyPackSpace	= "Не хватает свободного места в сумках для создания аукциона!";
		FrmtNotEnoughOfItem	= "У вас недостаточно %s для создания аукциона!";
		FrmtPostedAuction	= "Создан 1 аукцион из %s (x%d)";
		FrmtPostedAuctions	= "Создано %d аукционов из %s (x%d)";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "текСтавка";
		FrmtBidbrokerMinbid	= "минСтавка";
		FrmtNoauct	= "Не найдено ни одного аукциона для предмета: %s";


		-- Section: Scanning Messages
		AuctionDefunctAucts	= "Удалено не существующих аукционов: %s";
		AuctionDiscrepancies	= "Найдено несоответствий: %s";
		AuctionNewAucts	= "Отсканировано новых аукционов: %s";
		AuctionPageN	= "Аукционер: сканируется %s страница %d из %d Аукционов в секунду: %s Осталось времени %s";
		AuctionScanDone	= "Аукционер: сканирование аукциона завершено.";
		AuctionScanNexttime	= "Аукционер сделает полное сканирование аукциона, когда Вы в следующий раз поговорите с аукционером.";
		AuctionScanNocat	= "Вы должны выбрать не менее одной категории для сканирования.";
		AuctionScanRedo	= "Текущая страница заняла больше чем %d секунд для обработки. Повторная обработка.";
		AuctionScanStart	= "Аукционер: сканируется %s страница 1...";
		AuctionTotalAucts	= "Всего аукционов отсканировано: %s";
		AuctionUpdatedAucts	= "Обновленных/Измененных аукционов: %s";


		-- Section: Tooltip Messages
		FrmtInfoAlsoseen	= "Виден %d раз в %s";
		FrmtInfoAverage	= "%s мин/%s Выкуп (%s ставка)";
		FrmtInfoBidMulti	= "Ставки (%s%s за шт)";
		FrmtInfoBidOne	= "Ставки%s";
		FrmtInfoBidrate	= "%d %% имеют ставки, %d %% имеют цену выкупа";
		FrmtInfoBuymedian	= "Средняя цена выкупа";
		FrmtInfoBuyMulti	= "Выкуп (%s%s за шт)";
		FrmtInfoBuyOne	= "Выкуп%s";
		FrmtInfoForone	= "За 1: %s мин/%s выкуп (%s ставка) [в %d's]";
		FrmtInfoHeadMulti	= "Среднее за %d шт:";
		FrmtInfoHeadOne	= "Среднее за эту вещь:";
		FrmtInfoHistmed	= "Последний %d, средний выкуп (за шт)";
		FrmtInfoMinMulti	= "Начальная ставка (%s за шт)";
		FrmtInfoMinOne	= "Начальная ставка";
		FrmtInfoNever	= "Ни разу не был замечен на %s";
		FrmtInfoSeen	= "Итого %d раз виден на аукционе";
		FrmtInfoSgst	= "Предлагаемая цена: %s мин/%s выкуп";
		FrmtInfoSgststx	= "Предлагаемая цена за %d шт: %s мин/%s выкуп";
		FrmtInfoSnapmed	= "Сканированный %d, средний выкуп (за шт)";
		FrmtInfoStacksize	= "Средний размер кучи: %d шт";


		-- Section: User Interface
		BuySortTooltip	= "Сортировать результаты по цене выкупа (держите SHIFT для сортировки по названию предмета)";
		ClearTooltip	= "Очистить все заданные пользователем параметры поиска.";
		FrmtLastSoldOn	= "Последняя продажа %s";
		RefreshTooltip	= "Использовать заново параметры поиска на текущей странице.";
		UiBid	= "Предложение";
		UiBidHeader	= "Предложение";
		UiBidPerHeader	= "Ставка за";
		UiBuyout	= "Выкупить";
		UiBuyoutHeader	= "Скупка";
		UiBuyoutPerHeader	= "Выкупить за";
		UiBuyoutPriceLabel	= "Цена Выкупа:";
		UiBuyoutPriceTooLowError	= "(Слишком низкая)";
		UiCategoryLabel	= "Ограничение категории:";
		UiDepositLabel	= "Депозит:";
		UiDurationLabel	= "Длительность";
		UiItemLevelHeader	= "Уровень";
		UiMakeFixedPriceLabel	= "Макс. фиксированная цена";
		UiMaxError	= "(%d Макс) ";
		UiMaximumPriceLabel	= "Макс. цена";
		UiMaximumTimeLeftLabel	= "Макс. время осталось:";
		UiMinimumProfitLabel	= "Минимальная прибыль:";
		UiMinimumQualityLabel	= "Минимальное кол-во";
		UiMinimumUndercutLabel	= "Минимальная уценка";
		UiNameHeader	= "Имя";
		UiNoPendingBids	= "Все ставки обработаны!";
		UiNotEnoughError	= "(Недостаточно)";
		UiPendingBidInProgress	= "1 ставка обрабатывается...";
		UiPendingBidsInProgress	= "%d ставок обрабатывается...";
		UiPercentLessHeader	= "%";
		UiPost	= "Поставить";
		UiPostAuctions	= "Поставить на аукцион";
		UiPriceBasedOnLabel	= "Цена базирующаяся на:";
		UiPriceModelAuctioneer	= "Цена аукционера";
		UiPriceModelCustom	= "Цена вручную";
		UiPriceModelFixed	= "Фикс. Цена";
		UiPriceModelLastSold	= "Последняя Цена Продажи";
		UiProfitHeader	= "Прибыль";
		UiProfitPerHeader	= "Прибыль за";
		UiQuantityHeader	= "Кол-во";
		UiQuantityLabel	= "Кол-во";
		UiRemoveSearchButton	= "Удалить";
		UiSavedSearchLabel	= "Сохраненные поиски";
		UiSaveSearchButton	= "Сохранить";
		UiSaveSearchLabel	= "Сохранить поиск";
		UiSearch	= "Искать";
		UiSearchAuctions	= "Искать в аукционах";
		UiSearchDropDownLabel	= "Поиск:";
		UiSearchForLabel	= "Поиск предмета:";
		UiSearchTypeBids	= "Ставки";
		UiSearchTypeBuyouts	= "Цены выкупа";
		UiSearchTypeCompetition	= "конкуренция";
		UiSearchTypePlain	= "предмет";
		UiStacksLabel	= "Куча";
		UiStackTooBigError	= "(Куча Слишком Велика)";
		UiStackTooSmallError	= "(Куча Слишком Мала)";
		UiStartingPriceLabel	= "Нач. цена";
		UiStartingPriceRequiredError	= "(Требуется)";
		UiTimeLeftHeader	= "Оставшееся время";
		UiUnknownError	= "(Неизвестный)";

	};

	zhCN = {


		-- Section: AskPrice Messages
		AskPriceAd	= "以%sx[物品链接](x=堆叠数量)获取堆叠价格。";
		FrmtAskPriceBuyoutMedianHistorical	= "%s既往一口价中位数：%s%s";
		FrmtAskPriceBuyoutMedianSnapshot	= "%s最近扫描一口价中位数：%s%s";
		FrmtAskPriceDisable	= "禁用询价%s选项。";
		FrmtAskPriceEach	= "(每件%s)";
		FrmtAskPriceEnable	= "启用询价%s选项。";
		FrmtAskPriceVendorPrice	= "%s售于商贩：%s%s";


		-- Section: Auction Messages
		FrmtActRemove	= "从当前拍卖行汇总中删除标识%s。";
		FrmtAuctinfoHist	= "既往%d次";
		FrmtAuctinfoLow	= "汇总后降至";
		FrmtAuctinfoMktprice	= "市场价格";
		FrmtAuctinfoNolow	= "最近汇总未发现该物品";
		FrmtAuctinfoOrig	= "原起拍价";
		FrmtAuctinfoSnap	= "刚扫描到%d次";
		FrmtAuctinfoSugbid	= "建议起拍价";
		FrmtAuctinfoSugbuy	= "建议一口价";
		FrmtWarnAbovemkt	= "竞卖超出行情";
		FrmtWarnMarkup	= "标高为商贩收购价的%s%%";
		FrmtWarnMyprice	= "使用当前自定价";
		FrmtWarnNocomp	= "无竞价";
		FrmtWarnNodata	= "无最高曾售价的数据";
		FrmtWarnToolow	= "无法匹配最低价";
		FrmtWarnUndercut	= "削价%s%%";
		FrmtWarnUser	= "使用自定价";


		-- Section: Bid Messages
		FrmtAlreadyHighBidder	= "已是应拍：%s (x%d)的最高出价人。";
		FrmtBidAuction	= "出价竞拍：%s (x%d)。";
		FrmtBidQueueOutOfSync	= "错误：竞拍队列不同步！";
		FrmtBoughtAuction	= "一口价应拍：%s (x%d)。";
		FrmtMaxBidsReached	= "找到更多拍卖：%s (x%d),但是已达到竞拍限度(%d)。";
		FrmtNoAuctionsFound	= "未找到拍卖：%s (x%d)。";
		FrmtNoMoreAuctionsFound	= "未找到更多拍卖：%s (x%d)。";
		FrmtNotEnoughMoney	= "竞拍资金不足：%s (x%d)。";
		FrmtSkippedAuctionWithHigherBid	= "忽略更高出价的拍卖：%s (x%d)。";
		FrmtSkippedAuctionWithLowerBid	= "忽略更低出价的拍卖：%s (x%d)。";
		FrmtSkippedBiddingOnOwnAuction	= "忽略对自身拍卖的出价：%s (x%d)。";
		UiProcessingBidRequests	= "出价请求处理中...";


		-- Section: Command Messages
		ConstantsCritical	= "严重:你的拍卖助手扫描数据文件(SavedVariables )%.3f%%已满";
		ConstantsMessage	= "你的拍卖助手扫描数据文件(SavedVariables )%.3f%%已满";
		ConstantsWarning	= "警告:你的拍卖助手扫描数据文件(SavedVariables )%.3f%%已满";
		FrmtActClearall	= "清除%s的全部拍卖数据。";
		FrmtActClearFail	= "无法找到物品:%s。";
		FrmtActClearOk	= "%s的数据已清除。";
		FrmtActClearsnap	= "清除当前拍卖行汇总。";
		FrmtActDefault	= "拍卖助手选项%s已重置为默认设置。";
		FrmtActDefaultall	= "全部拍卖助手选项已重置为默认设置。";
		FrmtActDisable	= "隐藏物品%s的数据。";
		FrmtActEnable	= "显示物品%s的数据。";
		FrmtActSet	= "设置%s为'%s'。";
		FrmtActUnknown	= "未知命令或关键字：'%s'。";
		FrmtAuctionDuration	= "默认拍卖时限设置为：%s。";
		FrmtAutostart	= "自动开始拍卖：最低价%s，一口价%s(%d小时)%s。";
		FrmtFinish	= "扫描完成之后，将%s。";
		FrmtPrintin	= "拍卖助手讯息现在将显示在'%s'对话框中。";
		FrmtProtectWindow	= "拍卖行窗口保护设为：%s。";
		FrmtUnknownArg	= "对'%s'而言，'%s'是无效值。";
		FrmtUnknownLocale	= "你指定的地域代码('%s')未知。有效的地域代码为：";
		FrmtUnknownRf	= "错误的数据('%s')：正确的格式为：[服务器名]-[阵营]，其中阵营为英文(联盟-Alliance，部落-Horde)。例如：泰兰德-Alliance。";


		-- Section: Command Options
		OptAlso	= "(服务器名-阵营|opposite对立)";
		OptAuctionDuration	= "(last最终||2h小时||8h小时||24h小时)";
		OptBidbroker	= "<银币计利润>";
		OptBidLimit	= "<数目>";
		OptBroker	= "<银币计利润>";
		OptClear	= "([物品]|all全部|snapshot汇总)";
		OptCompete	= "<银币计差额>";
		OptDefault	= "(<选项>|all全部)";
		OptFinish	= "(off关闭||logout注销||exit退出)";
		OptLocale	= "<地域代码>";
		OptPctBidmarkdown	= "<比率>";
		OptPctMarkup	= "<比率>";
		OptPctMaxless	= "<比率>";
		OptPctNocomp	= "<比率>";
		OptPctUnderlow	= "<比率>";
		OptPctUndermkt	= "<比率>";
		OptPercentless	= "<比率>";
		OptPrintin	= "(<窗口标签>[数字]|<窗口名称>[字符串])";
		OptProtectWindow	= "(never从不|scan扫描|always总是)";
		OptScale	= "<比例系数>";
		OptScan	= "<>";


		-- Section: Commands
		CmdAlso	= "also而且";
		CmdAlsoOpposite	= "opposite对立";
		CmdAlt	= "Alt";
		CmdAskPriceAd	= "ad启事";
		CmdAskPriceGuild	= "guild公会";
		CmdAskPriceParty	= "party队伍";
		CmdAskPriceSmart	= "smart灵活";
		CmdAskPriceSmartWord1	= "what什么";
		CmdAskPriceSmartWord2	= "worth值钱";
		CmdAskPriceTrigger	= "trigger触发器";
		CmdAskPriceVendor	= "vendor商贩";
		CmdAskPriceWhispers	= "whispers 密语";
		CmdAskPriceWord	= "word 关键字";
		CmdAuctionClick	= "auction-click拍卖点击";
		CmdAuctionDuration	= "auction-duration拍卖时限";
		CmdAuctionDuration0	= "last最近";
		CmdAuctionDuration1	= "2h小时";
		CmdAuctionDuration2	= "8h小时";
		CmdAuctionDuration3	= "24h小时";
		CmdAutofill	= "autofill自动填价";
		CmdBidbroker	= "bidbroker出价代理";
		CmdBidbrokerShort	= "bb(出价代理的缩写)";
		CmdBidLimit	= "bid-limit竞拍限数";
		CmdBroker	= "broker代理";
		CmdClear	= "clear清除";
		CmdClearAll	= "all全部";
		CmdClearSnapshot	= "snapshot汇总";
		CmdCompete	= "compete竞卖";
		CmdCtrl	= "Ctrl";
		CmdDefault	= "default默认";
		CmdDisable	= "disable禁用";
		CmdEmbed	= "embed嵌入";
		CmdFinish	= "finish完成";
		CmdFinish0	= "off关闭";
		CmdFinish1	= "logout注销";
		CmdFinish2	= "exit退出";
		CmdFinish3	= "reloadui重新加载用户界面";
		CmdFinishSound	= "finish-sound完成播放声音";
		CmdHelp	= "help帮助";
		CmdLocale	= "locale地域代码";
		CmdOff	= "off关";
		CmdOn	= "on开";
		CmdPctBidmarkdown	= "pct-bidmarkdown起价降低比率";
		CmdPctMarkup	= "pct-markup涨价比率";
		CmdPctMaxless	= "pct-maxless最大削价比率";
		CmdPctNocomp	= "pct-nocomp无竞价比率";
		CmdPctUnderlow	= "pct-underlow最低价比率";
		CmdPctUndermkt	= "pct-undermkt市场价压低比率";
		CmdPercentless	= "percentless比率差额";
		CmdPercentlessShort	= "pl(比率差额的缩写)";
		CmdPrintin	= "print-in输出";
		CmdProtectWindow	= "protect-window保护窗口";
		CmdProtectWindow0	= "never从不";
		CmdProtectWindow1	= "scan扫描";
		CmdProtectWindow2	= "always总是";
		CmdScan	= "scan扫描";
		CmdShift	= "Shift";
		CmdToggle	= "toggle开关转换";
		CmdUpdatePrice	= "update-price更新价格";
		CmdWarnColor	= "warn-color警示色";
		ShowAverage	= "show-average显示均值";
		ShowEmbedBlank	= "show-embed-blankline显示嵌入空行";
		ShowLink	= "show-link显示链接";
		ShowMedian	= "show-median显示中值";
		ShowRedo	= "show-warning显示警告";
		ShowStats	= "show-stats显示统计";
		ShowSuggest	= "show-suggest显示建议";
		ShowVerbose	= "show-verbose显示细节";


		-- Section: Config Text
		GuiAlso	= "同时显示数据";
		GuiAlsoDisplay	= "显示%s的数据";
		GuiAlsoOff	= "不再显示其他服务器-阵营的数据。";
		GuiAlsoOpposite	= "同时显示对立阵营的数据。";
		GuiAskPrice	= "启用询价";
		GuiAskPriceAd	= "发送特色启事";
		GuiAskPriceGuild	= "响应公会频道查询";
		GuiAskPriceHeader	= "询价选项";
		GuiAskPriceHeaderHelp	= "更改询价方式";
		GuiAskPriceParty	= "响应队伍频道查询";
		GuiAskPriceSmart	= "使用智能字";
		GuiAskPriceTrigger	= "询价触发器";
		GuiAskPriceVendor	= "发送商贩信息";
		GuiAskPriceWhispers	= "显示已发送密语";
		GuiAskPriceWord	= "自定义智能关键字 %d";
		GuiAuctionDuration	= "默认拍卖时限";
		GuiAuctionHouseHeader	= "拍卖行窗口";
		GuiAuctionHouseHeaderHelp	= "更改拍卖行窗口方式";
		GuiAutofill	= "拍卖行中自动填价";
		GuiAverages	= "显示平均价格";
		GuiBidmarkdown	= "竞拍减价比率";
		GuiClearall	= "清除全部拍卖助手数据";
		GuiClearallButton	= "清除全部";
		GuiClearallHelp	= "点此清除当前服务器拍卖助手的全部数据。";
		GuiClearallNote	= "对于当前服务器-阵营";
		GuiClearHeader	= "清除数据";
		GuiClearHelp	= "清除拍卖助手数据。选择清除全部数据或当前汇总数据。警告：这些操作无法还原。";
		GuiClearsnap	= "清除汇总数据";
		GuiClearsnapButton	= "清除汇总";
		GuiClearsnapHelp	= "点此清除上次拍卖助手汇总数据。";
		GuiDefaultAll	= "重置全部拍卖助手选项";
		GuiDefaultAllButton	= "重置全部";
		GuiDefaultAllHelp	= "点击恢复拍卖助手所有选项为默认值。警告：这些操作无法还原。";
		GuiDefaultOption	= "重置这项设置";
		GuiEmbed	= "嵌入信息到游戏提示中";
		GuiEmbedBlankline	= "在游戏提示中显示空行";
		GuiEmbedHeader	= "嵌入";
		GuiFinish	= "当扫描完成后";
		GuiFinishSound	= "扫描完成后播放声效";
		GuiLink	= "显示链接标识";
		GuiLoad	= "加载拍卖助手";
		GuiLoad_Always	= "总是";
		GuiLoad_AuctionHouse	= "在拍卖行";
		GuiLoad_Never	= "从不";
		GuiLocale	= "设置地域代码为";
		GuiMainEnable	= "启用拍卖助手";
		GuiMainHelp	= "包含插件 - 拍卖助手的设置。它用于显示物品信息，并分析拍卖数据。在拍卖行点击\"扫描\"按钮来收集拍卖数据。";
		GuiMarkup	= "商贩价涨幅比率";
		GuiMaxless	= "市场价最大削减比率";
		GuiMedian	= "显示一口价中位数";
		GuiNocomp	= "无竞拍削价比率";
		GuiNoWorldMap	= "拍卖助手：防止显示世界地图";
		GuiOtherHeader	= "其他选项";
		GuiOtherHelp	= "拍卖助手杂项";
		GuiPercentsHeader	= "拍卖助手极限比率";
		GuiPercentsHelp	= "警告：下列设置仅适合于高级用户。调整下列数值以改变拍卖助手判定收益水平的力度。";
		GuiPrintin	= "选择期望的讯息窗口。";
		GuiProtectWindow	= "防止意外关闭拍卖行窗口。";
		GuiRedo	= "显示长时间搜索警告。";
		GuiReloadui	= "重新加载用户界面。";
		GuiReloaduiButton	= "重载UI ";
		GuiReloaduiFeedback	= "现在正重新加载魔兽用户界面。";
		GuiReloaduiHelp	= "在改变地域代码后点此重新加载魔兽用户界面使此配置屏幕中的语言匹配选择。注意：此操作可能耗时几分钟。";
		GuiRememberText	= "记住价格";
		GuiStatsEnable	= "显示统计";
		GuiStatsHeader	= "物品价格统计";
		GuiStatsHelp	= "在提示中显示下列统计信息";
		GuiSuggest	= "显示建议价格";
		GuiUnderlow	= "最低拍卖削价比率";
		GuiUndermkt	= "最大幅降价时削减市场价比率";
		GuiVerbose	= "详细模式";
		GuiWarnColor	= "彩色标价模式";


		-- Section: Conversion Messages
		MesgConvert	= "拍卖助手数据库转换。请先备份你的SavedVariables\Auctioneer.lua文件。%s%s";
		MesgConvertNo	= "禁用拍卖助手";
		MesgConvertYes	= "转换";
		MesgNotconverting	= "拍卖助手未转换你的数据库，但完成之前将停止工作。";


		-- Section: Game Constants
		TimeLong	= "长";
		TimeMed	= "中";
		TimeShort	= "短";
		TimeVlong	= "非常长";


		-- Section: Generic Messages
		ConfirmBidBuyout	= "是否确实要 %s\n%dx%s ：";
		DisableMsg	= "禁止自动加载拍卖助手。";
		FrmtWelcome	= "拍卖助手(Auctioneer) v%s已加载！";
		MesgNotLoaded	= "拍卖助手(Auctioneer)未加载。键入/auctioneer有更多信息。";
		StatAskPriceOff	= "询价目前被禁用。";
		StatAskPriceOn	= "询价目前被启用。";
		StatOff	= "不显示任何拍卖数据。";
		StatOn	= "显示设定的拍卖数据。";


		-- Section: Generic Strings
		TextCombat	= "战斗";
		TextGeneral	= "常规";
		TextNone	= "无";
		TextScan	= "扫描";
		TextUsage	= "用途：";


		-- Section: Help Text
		HelpAlso	= "提示中显示其他服务器上的价格。输入[服务器名]-[阵营]，其中阵营为英文(联盟-Alliance，部落-Horde)。例如：\"/auctioneer also 泰兰德-Alliance\"。特定的关键字：\"opposite\"是指对立阵营，\"off\"禁用该功能。";
		HelpAskPrice	= "启用或禁用询价。";
		HelpAskPriceAd	= "启用或禁用新的询价特色启事。";
		HelpAskPriceGuild	= "响应公会频道中的查询。";
		HelpAskPriceParty	= "响应队伍频道中的查询。";
		HelpAskPriceSmart	= "启用或禁用智能字检查。";
		HelpAskPriceTrigger	= "更改询价触发器特性。";
		HelpAskPriceVendor	= "启用或禁用发送商贩定价数据。";
		HelpAskPriceWhispers	= "隐藏或显示所有询价外发密语";
		HelpAskPriceWord	= "增加或修改询价自定义智能关键字";
		HelpAuctionClick	= "允许你Alt点击背包中的物品来自动开始拍卖。";
		HelpAuctionDuration	= "设置打开拍卖行界面上的默认拍卖时限。";
		HelpAutofill	= "设置向拍卖行窗口加入新拍卖物品时是否自动填价。";
		HelpAverage	= "选择是否显示物品的平均拍卖价格。";
		HelpBidbroker	= "显示最近扫描中可应拍获利的中短期拍卖。";
		HelpBidLimit	= "当在搜索拍卖页面上点击竞拍或一口价按钮时，出价或一口价应拍的最大数目。";
		HelpBroker	= "显示最近扫描中任何可应拍并转手获利的拍卖。";
		HelpClear	= "清除指定的物品数据(你必须用Shift+点击把品名插入命令中)。你也可以指定关键字\"all\"或\"snapshot\"。";
		HelpCompete	= "显示最近扫描中任何比你的一口价低的拍卖。";
		HelpDefault	= "设置一个拍卖助手选项为其默认值,你也可以指定特殊关键字\"all\"来重置全部拍卖助手选项为其默认值。";
		HelpDisable	= "阻止拍卖助手在下次登录时自动加载。";
		HelpEmbed	= "嵌入文字到游戏默认提示中(注意：某些特性在该模式下不可用)。";
		HelpEmbedBlank	= "选择当嵌入模式启用时是否在提示信息和拍卖行信息中插入空行。";
		HelpFinish	= "设置拍卖行扫描完成后是否自动注销或退出游戏。";
		HelpFinishSound	= "设置是否在拍卖行扫描完成后播放声效";
		HelpLink	= "选择是否在提示中显示链接标识。";
		HelpLoad	= "改变拍卖助手对这个角色的加载设置。";
		HelpLocale	= "改变用于显示拍卖助手讯息的语言设置。";
		HelpMedian	= "选择是否显示物品的一口价中位数。";
		HelpOnoff	= "打开/关闭拍卖行数据显示。";
		HelpPctBidmarkdown	= "设置拍卖助手由一口价削减出价的比率。";
		HelpPctMarkup	= "当没有可参考价格时按商贩价涨幅比率。";
		HelpPctMaxless	= "设置拍卖助手放弃拍卖之前削减市场价的最大比率。";
		HelpPctNocomp	= "设置无竞拍时拍卖助手削减市场价的比率。";
		HelpPctUnderlow	= "设置拍卖助手削减最低拍卖价格的比率。";
		HelpPctUndermkt	= "当无法击败竞卖对手时削减市场价的比率(期至最大削价比率)。";
		HelpPercentless	= "显示最近扫描过所有一口价低于最高曾售价确定比率的拍卖。";
		HelpPrintin	= "选择拍卖助手讯息将显示在哪个窗口。可以指定窗口名称或索引。";
		HelpProtectWindow	= "防止意外关闭拍卖行界面。";
		HelpRedo	= "选择当服务器延迟导致当前搜索的拍卖行页面已耗时太长时是否显示警告。";
		HelpScan	= "下次降临或驻足拍卖行时执行扫描(拍卖行面板上也有一个扫描按钮)。勾选想要扫描的种类。";
		HelpStats	= "选择是否显示物品的以竞拍价/一口价成交的比率。";
		HelpSuggest	= "选择是否显示物品的建议拍卖价格。";
		HelpUpdatePrice	= "当一口价改变时，自动更新拍卖品在发布拍卖页面上的起拍价。";
		HelpVerbose	= "选择是否详细显示平均和建议价格(关闭则显示于单行)。";
		HelpWarnColor	= "选择是否用直观的颜色表示拍卖行标价模式。";


		-- Section: Post Messages
		FrmtNoEmptyPackSpace	= "背包没有空间来发布新拍卖项！";
		FrmtNotEnoughOfItem	= "无足够%s用于新拍卖项！";
		FrmtPostedAuction	= "已发布1件拍卖：%s (x%d)。";
		FrmtPostedAuctions	= "已发布%d件拍卖：%s (x%d)。";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "当前出价";
		FrmtBidbrokerDone	= "交易价代理完成。";
		FrmtBidbrokerHeader	= "最低利润：%s，最高曾售价='曾见于拍卖行中的最高价格'";
		FrmtBidbrokerLine	= "%s，最近出现%s次，最高曾售价：%s，%s：%s，利润：%s，次数：%s";
		FrmtBidbrokerMinbid	= "最低出价";
		FrmtBrokerDone	= "代理完成。";
		FrmtBrokerHeader	= "最低利润：%s，最高曾售价='曾见于拍卖行中的最高价格'";
		FrmtBrokerLine	= "%s，最近出现%s次，最高曾售价：%s，一口价：%s，利润：%s";
		FrmtCompeteDone	= "竞拍完成。";
		FrmtCompeteHeader	= "竞拍最少每项削减%s。";
		FrmtCompeteLine	= "%s，竞拍价：%s，一口价%s vs %s，差额%s";
		FrmtHspLine	= "每件%s的最高曾售价为：%s";
		FrmtLowLine	= "%s，一口价：%s，出售者：%s，单价：%s，低于中值:%s";
		FrmtMedianLine	= "最近出现%d次，每件%s一口价中位数为：%s";
		FrmtNoauct	= "物品：%s没有拍卖记录";
		FrmtPctlessDone	= "比率差额完成。";
		FrmtPctlessHeader	= "低于最高曾售价比率：%d%%";
		FrmtPctlessLine	= "%s，最近出现%d次，最高曾售价：%s，一口价：%s，利润：%s，差额%s";


		-- Section: Scanning Messages
		AuctionDefunctAucts	= "删除过期拍卖：%s项";
		AuctionDiscrepancies	= "出入之处：%s项";
		AuctionNewAucts	= "扫描新增拍卖：%s项";
		AuctionPageN	= "拍卖助手：正扫描%s\n第%d页 共%d页 %s项/秒\n估计剩余时间: %s";
		AuctionScanDone	= "拍卖助手：拍卖扫描完毕。";
		AuctionScanNexttime	= "拍卖助手将在下次与拍卖员对话时进行完全扫描。";
		AuctionScanNocat	= "必须至少选择一类进行扫描。";
		AuctionScanRedo	= "当前页需要多于%d秒才能完成，正重试页面。";
		AuctionScanStart	= "拍卖助手：正扫描%s\n第1页...";
		AuctionTotalAucts	= "已扫描全部拍卖：%s项";


		-- Section: Tooltip Messages
		FrmtInfoAlsoseen	= "出现过%d次于%s";
		FrmtInfoAverage	= "最低价%s/一口价%s(竞拍价%s)";
		FrmtInfoBidMulti	= "竞拍价(%s每件%s)";
		FrmtInfoBidOne	= "竞拍价%s";
		FrmtInfoBidrate	= "竞拍价%d%%,一口价%d%%";
		FrmtInfoBuymedian	= "一口价中位数";
		FrmtInfoBuyMulti	= "一口价(%s每件%s)";
		FrmtInfoBuyOne	= "一口价%s";
		FrmtInfoForone	= "每件:最低价%s/一口价%s(竞拍价%s)[%d件]";
		FrmtInfoHeadMulti	= "%d件物品平均:";
		FrmtInfoHeadOne	= "该物品平均:";
		FrmtInfoHistmed	= "之前有%d次,一口价中位数(每件)";
		FrmtInfoMinMulti	= "起拍价(每件%s)";
		FrmtInfoMinOne	= "起拍价";
		FrmtInfoNever	= "从未在%s出现过";
		FrmtInfoSeen	= "拍卖合计出现过%d次";
		FrmtInfoSgst	= "建议价格:最低价%s/一口价%s";
		FrmtInfoSgststx	= "对于堆叠%d件的建议价格:最低价%s/一口价%s";
		FrmtInfoSnapmed	= "扫描到%d次,一口价中位数(每件)";
		FrmtInfoStacksize	= "平均堆叠数量:%d件";


		-- Section: User Interface
		FrmtLastSoldOn	= "最终以%s售出";
		UiBid	= "竞标";
		UiBidHeader	= "出价";
		UiBidPerHeader	= "单件出价";
		UiBuyout	= "一口价";
		UiBuyoutHeader	= "一口价";
		UiBuyoutPerHeader	= "一口单价";
		UiBuyoutPriceLabel	= "一口价：";
		UiBuyoutPriceTooLowError	= "(过低)";
		UiCategoryLabel	= "种类限制";
		UiDepositLabel	= "保管费：";
		UiDurationLabel	= "拍卖时限：";
		UiItemLevelHeader	= "等级";
		UiMakeFixedPriceLabel	= "形成固定价格";
		UiMaxError	= "(最多%d件)";
		UiMaximumPriceLabel	= "最高价格";
		UiMaximumTimeLeftLabel	= "最多剩余时间：";
		UiMinimumProfitLabel	= "最低利润：";
		UiMinimumQualityLabel	= "最低品质：";
		UiMinimumUndercutLabel	= "最低削价：";
		UiNameHeader	= "名称";
		UiNoPendingBids	= "全部竞标请求完成！";
		UiNotEnoughError	= "(不够)";
		UiPendingBidInProgress	= "1件竞拍请求正在进行...";
		UiPendingBidsInProgress	= "%d件竞拍请求正在进行...";
		UiPercentLessHeader	= "比率";
		UiPost	= "发布处";
		UiPostAuctions	= "发布拍卖";
		UiPriceBasedOnLabel	= "标价基于：";
		UiPriceModelAuctioneer	= "拍卖助手标价";
		UiPriceModelCustom	= "自定价格";
		UiPriceModelFixed	= "固定价格";
		UiPriceModelLastSold	= "最终售价";
		UiProfitHeader	= "利润";
		UiProfitPerHeader	= "单件利润";
		UiQuantityHeader	= "数量";
		UiQuantityLabel	= "数量：";
		UiRemoveSearchButton	= "删除";
		UiSavedSearchLabel	= "现有搜索：";
		UiSaveSearchButton	= "保存";
		UiSaveSearchLabel	= "保存此次搜索";
		UiSearch	= "搜索";
		UiSearchAuctions	= "搜索拍卖";
		UiSearchDropDownLabel	= "搜索";
		UiSearchForLabel	= "搜索物品";
		UiSearchTypeBids	= "出价";
		UiSearchTypeBuyouts	= "一口价";
		UiSearchTypeCompetition	= "竞卖";
		UiSearchTypePlain	= "物品";
		UiStacksLabel	= "堆叠";
		UiStackTooBigError	= "(堆叠太多)";
		UiStackTooSmallError	= "(堆叠太少)";
		UiStartingPriceLabel	= "起拍价：";
		UiStartingPriceRequiredError	= "(必要的)";
		UiTimeLeftHeader	= "剩余时间";
		UiUnknownError	= "(未知)";

	};

	zhTW = {


		-- Section: AskPrice Messages
		AskPriceAd	= "得到每疊價格: %sx[ItemLink ] (x = stacksize)\n";
		FrmtAskPriceBuyoutMedianHistorical	= "%s歷來平均售出價: %s%s";
		FrmtAskPriceBuyoutMedianSnapshot	= "%s上次掃瞄平均售出價: %s%s";
		FrmtAskPriceDisable	= "禁用詢價選項:%s";
		FrmtAskPriceEach	= "%s 每件";
		FrmtAskPriceEnable	= "啟用詢價選項:%s";
		FrmtAskPriceVendorPrice	= "%sNPC回收價: %s%s";


		-- Section: Auction Messages
		FrmtActRemove	= "從目前拍賣場快照中移除 %s。";
		FrmtAuctinfoHist	= "%d 行記錄";
		FrmtAuctinfoLow	= "價格低於上次掃描";
		FrmtAuctinfoMktprice	= "市場價";
		FrmtAuctinfoNolow	= "未在上次掃描發現該物品";
		FrmtAuctinfoOrig	= "起標價";
		FrmtAuctinfoSnap	= "%d 上次掃描";
		FrmtAuctinfoSugbid	= "建議起標價";
		FrmtAuctinfoSugbuy	= "建議直購價";
		FrmtWarnAbovemkt	= "價格比市場價高";
		FrmtWarnMarkup	= "定價比商店高 %s%%";
		FrmtWarnMyprice	= "使用此當前價格";
		FrmtWarnNocomp	= "無人競價";
		FrmtWarnNodata	= "沒有最高售價格數據";
		FrmtWarnToolow	= "低於市面上最低價";
		FrmtWarnUndercut	= "削減價格 %s%%";
		FrmtWarnUser	= "採用自訂價格";


		-- Section: Bid Messages
		FrmtAlreadyHighBidder	= "已經是最高出價者: %s (x%d) ";
		FrmtBidAuction	= "下標：%s (x%d)";
		FrmtBidQueueOutOfSync	= "錯誤：標價排程已非同步";
		FrmtBoughtAuction	= "直接購買：%s (x%d)";
		FrmtMaxBidsReached	= "找到更多拍賣項目:%s (x%d), 但是已經到達查詢數量限制(%d)";
		FrmtNoAuctionsFound	= "未找到拍賣：%s (x%d)";
		FrmtNoMoreAuctionsFound	= "找不到新的拍賣項目:%s (x%d) ";
		FrmtNotEnoughMoney	= "錢不夠標拍賣：%s (x%d) ";
		FrmtSkippedAuctionWithHigherBid	= "忽略高標價的拍賣：%s (x%d) ";
		FrmtSkippedAuctionWithLowerBid	= "忽略低標價的拍賣：%s (x%d) ";
		FrmtSkippedBiddingOnOwnAuction	= "忽略下標自己的拍賣：%s (x%d)";
		UiProcessingBidRequests	= "進行下標要求中．．．";


		-- Section: Command Messages
		FrmtActClearall	= "清除所有%s資料";
		FrmtActClearFail	= "未找到：%s";
		FrmtActClearOk	= "清除所有：%s的資料";
		FrmtActClearsnap	= "清除目前掃瞄的結果快照";
		FrmtActDefault	= "拍賣助手選項 %s 已重置為預設值";
		FrmtActDefaultall	= "重置所有設定為預設值。";
		FrmtActDisable	= "隱藏物品 %s 的資料";
		FrmtActEnable	= "顯示物品的 %s 的資料";
		FrmtActSet	= "設定 %s 為 '%s'";
		FrmtActUnknown	= "無效命令或關鍵字：'%s'";
		FrmtAuctionDuration	= "預設拍賣時間設定為：%s";
		FrmtAutostart	= "自動拍賣開始：起標價 %s ,直購價 %s (%dh)%s";
		FrmtFinish	= "在掃描完成了之後, 我想%s";
		FrmtPrintin	= "拍賣助手的訊息將顯示在\"%s\"對話框中";
		FrmtProtectWindow	= "拍賣行視窗保護設定為：%s";
		FrmtUnknownArg	= "對'%s'而言,'%s'是無效值";
		FrmtUnknownLocale	= "您指定的語言('%s')無法辨識。目前支援的語言版本為：";
		FrmtUnknownRf	= "錯誤的數據 ('%s').正確的格式為：[伺服器]-[陣營]，例如：布蘭卡德-聯盟.";


		-- Section: Command Options
		OptAlso	= "(伺服器-聯盟|部落|opposite(敵對陣營))";
		OptAuctionDuration	= "(last(上次)|2h(2小時)|8h(8小時)|24h(24小時))";
		OptBidbroker	= "<可得利潤>";
		OptBidLimit	= "<數量>";
		OptBroker	= "<可得利潤>";
		OptClear	= "([物品名稱]|all(全部)|snapshot(快照))";
		OptCompete	= "<損失利潤>";
		OptDefault	= "(<特定選項>|all(全部))";
		OptFinish	= "(off(關閉)||logout(登出)||exit(離開))";
		OptLocale	= "<語言>";
		OptPctBidmarkdown	= "<百分比>";
		OptPctMarkup	= "<百分比>";
		OptPctMaxless	= "<百分比>";
		OptPctNocomp	= "<百分比>";
		OptPctUnderlow	= "<％>";
		OptPctUndermkt	= "<％>";
		OptPercentless	= "<％>";
		OptPrintin	= "(<frameIndex>[Number]|<frameName>[String])";
		OptProtectWindow	= "(never(絕不)||scan(掃瞄時)||always(總是))";
		OptScale	= "<比例係數>";
		OptScan	= "<>";


		-- Section: Commands
		CmdAlso	= "also";
		CmdAlsoOpposite	= "opposite";
		CmdAlt	= "alt";
		CmdAskPriceAd	= "ad";
		CmdAskPriceGuild	= "guild";
		CmdAskPriceParty	= "party";
		CmdAskPriceSmart	= "smart";
		CmdAskPriceSmartWord1	= "what";
		CmdAskPriceSmartWord2	= "worth";
		CmdAskPriceTrigger	= "trigger";
		CmdAskPriceVendor	= "vendor";
		CmdAskPriceWhispers	= "whispers";
		CmdAskPriceWord	= "word";
		CmdAuctionClick	= "auction-click";
		CmdAuctionDuration	= "auction-duration";
		CmdAuctionDuration0	= "last";
		CmdAuctionDuration1	= "2h";
		CmdAuctionDuration2	= "8h";
		CmdAuctionDuration3	= "24h";
		CmdAutofill	= "autofill";
		CmdBidbroker	= "bidbroker";
		CmdBidbrokerShort	= "bb";
		CmdBidLimit	= "bid-limit";
		CmdBroker	= "broker";
		CmdClear	= "clear";
		CmdClearAll	= "all";
		CmdClearSnapshot	= "snapshot";
		CmdCompete	= "compete";
		CmdCtrl	= "Ctrl";
		CmdDefault	= "default";
		CmdDisable	= "disable";
		CmdEmbed	= "embed";
		CmdFinish	= "finish";
		CmdFinish0	= "off";
		CmdFinish1	= "logout";
		CmdFinish2	= "exit";
		CmdFinish3	= "reloadui";
		CmdFinishSound	= "finish-sound";
		CmdHelp	= "help";
		CmdLocale	= "locale";
		CmdOff	= "off";
		CmdOn	= "on";
		CmdPctBidmarkdown	= "pct-bidmarkdown";
		CmdPctMarkup	= "pct-markup";
		CmdPctMaxless	= "pct-maxless";
		CmdPctNocomp	= "pct-nocomp";
		CmdPctUnderlow	= "pct-underlow";
		CmdPctUndermkt	= "pct-undermkt";
		CmdPercentless	= "percentless";
		CmdPercentlessShort	= "pl";
		CmdPrintin	= "print-in";
		CmdProtectWindow	= "protect-window";
		CmdProtectWindow0	= "never";
		CmdProtectWindow1	= "scan";
		CmdProtectWindow2	= "always";
		CmdScan	= "scan";
		CmdShift	= "Shift";
		CmdToggle	= "toggle";
		CmdUpdatePrice	= "update-price";
		CmdWarnColor	= "warn-color";
		ShowAverage	= "show-average";
		ShowEmbedBlank	= "show-embed-blankline";
		ShowLink	= "show-link";
		ShowMedian	= "show-median";
		ShowRedo	= "show-stats";
		ShowStats	= "show-stats";
		ShowSuggest	= "show-suggest";
		ShowVerbose	= "show-verbose";


		-- Section: Config Text
		GuiAlso	= "總是顯示資料";
		GuiAlsoDisplay	= "顯示 %s 的資料";
		GuiAlsoOff	= "不再顯示其他伺服器-陣營的資料。";
		GuiAlsoOpposite	= "同時顯示敵立陣營的數據。";
		GuiAskPrice	= "啟動詢價功能";
		GuiAskPriceAd	= "發送新功能廣告";
		GuiAskPriceGuild	= "回應團隊頻道的詢價";
		GuiAskPriceHeader	= "詢價選項";
		GuiAskPriceHeaderHelp	= "變更詢價功能模式";
		GuiAskPriceParty	= "回應隊伍頻道的詢價";
		GuiAskPriceSmart	= "使用智慧觸發字元(smartwords)\n";
		GuiAskPriceTrigger	= "詢價(AskPrice)觸發器\n";
		GuiAskPriceVendor	= "送供應商信息\n";
		GuiAskPriceWhispers	= "顯示送出的耳語";
		GuiAskPriceWord	= "自訂智慧觸發字元(smartwords)";
		GuiAuctionDuration	= "預設拍賣時間";
		GuiAuctionHouseHeader	= "拍賣場視窗";
		GuiAuctionHouseHeaderHelp	= "更改拍賣場視窗狀態";
		GuiAutofill	= "在拍賣時自動填入價格";
		GuiAverages	= "顯示平均成交價格";
		GuiBidmarkdown	= "削價%";
		GuiClearall	= "清除所有拍賣助手資料";
		GuiClearallButton	= "清除所有";
		GuiClearallHelp	= "點擊清除目前伺服器的所有拍賣助手資料";
		GuiClearallNote	= "在當前伺服器-陣營";
		GuiClearHeader	= "清除資料";
		GuiClearHelp	= "清除拍賣助手數據。選擇清除所有資料或當前快照。警告：這些操作無法還原。";
		GuiClearsnap	= "清除目前快照資料";
		GuiClearsnapButton	= "清除快照";
		GuiClearsnapHelp	= "點擊清除上次快照資料.";
		GuiDefaultAll	= "還原所有拍賣助手選項";
		GuiDefaultAllButton	= "全部重置";
		GuiDefaultAllHelp	= "點擊重置拍賣助手所有選項為預設值。警告：這些操作無法還原。";
		GuiDefaultOption	= "重置此設定";
		GuiEmbed	= "嵌入信息到遊戲提示中";
		GuiEmbedBlankline	= "在遊戲提示中顯示空行";
		GuiEmbedHeader	= "嵌入";
		GuiFinish	= "在掃瞄完成之後";
		GuiFinishSound	= "掃瞄完成之後播放音效";
		GuiLink	= "顯示 LinkID";
		GuiLoad	= "載入拍賣助手";
		GuiLoad_Always	= "總是自動載入";
		GuiLoad_AuctionHouse	= "只在拍賣場時載入";
		GuiLoad_Never	= "永不自動載入";
		GuiLocale	= "設定語言為";
		GuiMainEnable	= "啟用拍賣助手";
		GuiMainHelp	= "包括拍賣助手的設置。一個顯示物品信息，並分析拍賣數據的插件。在拍賣行點擊\"掃描\"按鈕來收集拍賣數據。";
		GuiMarkup	= "商店價格比例";
		GuiMaxless	= "最大低於市場價格比例";
		GuiMedian	= "顯示平均價";
		GuiNocomp	= "無人競標降價比例";
		GuiNoWorldMap	= "拍賣助手：暫時禁止顯示世界地圖";
		GuiOtherHeader	= "其他選項";
		GuiOtherHelp	= "拍賣助手雜項";
		GuiPercentsHeader	= "拍賣助手閥值百分比";
		GuiPercentsHelp	= "警告：下列設置僅適合高級用戶。改變下列數值將改變拍賣助手對收益的判斷。";
		GuiPrintin	= "選擇目標訊息框架";
		GuiProtectWindow	= "防止意外關閉拍賣場視窗";
		GuiRedo	= "顯示掃描時間過長的警告訊息";
		GuiReloadui	= "重新載入使用者介面(UI)";
		GuiReloaduiButton	= "重新載入UI";
		GuiReloaduiFeedback	= "正在重新載入『魔獸世界』UI";
		GuiReloaduiHelp	= "點擊這裡來重新載入UI來套用新的語言設置。注意：這個操作可能需要較長時間。";
		GuiRememberText	= "記住價格";
		GuiStatsEnable	= "顯示狀態";
		GuiStatsHeader	= "物品價格統計";
		GuiStatsHelp	= "在提示中顯示下列統計信息";
		GuiSuggest	= "顯示建議價格";
		GuiUnderlow	= "拍賣場最低降價比例";
		GuiUndermkt	= "市場價格降價比例";
		GuiVerbose	= "詳細模式";
		GuiWarnColor	= "彩色標價模式";


		-- Section: Conversion Messages
		MesgConvert	= "拍賣助手資料庫轉換。請先備份 SavedVariables\Auctioneer.lua.%s%s";
		MesgConvertNo	= "停用拍賣助手";
		MesgConvertYes	= "轉換";
		MesgNotconverting	= "您的資料庫尚未經過轉換更新，您必須轉換資料庫才能使用拍賣助手。";


		-- Section: Game Constants
		TimeLong	= "長";
		TimeMed	= "中";
		TimeShort	= "短";
		TimeVlong	= "非常長";


		-- Section: Generic Messages
		DisableMsg	= "禁止自動載入拍賣助手";
		FrmtWelcome	= "拍賣助手 v%s 已載入";
		MesgNotLoaded	= "拍賣助手尚未載入。 輸入 /auctioneer 取得說明。";
		StatAskPriceOff	= "詢價功能關閉。";
		StatAskPriceOn	= "詢價功能啟動。";
		StatOff	= "不顯示任何拍賣資訊";
		StatOn	= "顯示設定好的拍賣資料";


		-- Section: Generic Strings
		TextCombat	= "戰鬥";
		TextGeneral	= "一般";
		TextNone	= "無";
		TextScan	= "掃描";
		TextUsage	= "使用：";


		-- Section: Help Text
		HelpAlso	= "提示中顯示其他伺服器上的價格。例如: \"/auctioneer also 阿薩斯-部落\" 或是使用參數：opposite(對立陣營), off(關閉功能)";
		HelpAskPrice	= "啟用或禁用詢價功能";
		HelpAskPriceAd	= "啟用或關閉新的詢價功能廣告。";
		HelpAskPriceGuild	= "回應團隊頻道的詢價。";
		HelpAskPriceParty	= "回應隊伍頻道的詢價。";
		HelpAskPriceSmart	= "允許或關閉智慧觸發字元偵測(SmartWords checking)。\n";
		HelpAskPriceTrigger	= "改變詢價(AskPrice)的觸發字元。";
		HelpAskPriceVendor	= "允許或關閉商店價格資料發送。\n";
		HelpAskPriceWhispers	= "隱藏或顯示所有發送的耳語。";
		HelpAskPriceWord	= "新增或改變自訂智慧觸發字元(smartwords)";
		HelpAuctionClick	= "允許你 Alt+點擊背包中的物品 來自動開始拍賣";
		HelpAuctionDuration	= "設置在開啟拍賣場視窗時，使用預設拍賣時間";
		HelpAutofill	= "設置在拍賣物品的時候，是否在自動填寫價格";
		HelpAverage	= "選擇是否顯示物品的平均拍賣價格";
		HelpBidbroker	= "顯示當前掃描中發現的可用於標下以獲取利潤的中短期拍賣物品";
		HelpBidLimit	= "在拍賣頁面，可以同時競標或直接購買的最大數量。";
		HelpBroker	= "顯示在當前掃描中，可能可以標下再賣出並獲取利潤的所有拍賣物品";
		HelpClear	= "清除特定的物品數據(你必須Shift+點選來把物品加入到命令裡面)。你也可以用特定關鍵詞\"all\"或\"snapshot\"";
		HelpCompete	= "顯示所有最近掃描的比你的直購價低的拍賣品";
		HelpDefault	= "重置一個拍賣助手選項為其預設值，你也可以使用\"all\"來重置所有選項為其預設值";
		HelpDisable	= "禁止拍賣助手在下次登入時自動載入";
		HelpEmbed	= "把文字嵌入到遊戲的原始提示中(注意：某些功能在該模式下無法使用)";
		HelpEmbedBlank	= "選擇是否在提示信息和拍賣行信息中間插入空行(需要嵌入模式設置為on)";
		HelpFinish	= "設置當掃描完畢後，是否自動登出或退出遊戲";
		HelpFinishSound	= "選擇是否在掃描完畢之後播放音效";
		HelpLink	= "選擇是否在提示中顯示link id";
		HelpLoad	= "改變拍賣助手的載入設置";
		HelpLocale	= "改變顯示拍賣助手訊息的語言";
		HelpMedian	= "選擇是否顯示物品的平均直購價";
		HelpOnoff	= "開啟／關閉拍賣資料顯示";
		HelpPctBidmarkdown	= "設置比例(百分比)來以直購價自動設置起標價";
		HelpPctMarkup	= "當沒有其他參考價格的時候，設置比例(百分比)來以商店售價自動設定起標價";
		HelpPctMaxless	= "設置拍賣助手自動標價時，低於市場價格的比例(百分比)的下限，若低於下限將自動放棄該項拍賣";
		HelpPctNocomp	= "設置如果無人競標時，拍賣助手依據市場價再次降價的比例(百分比)";
		HelpPctUnderlow	= "設置拍賣助手相對於拍賣行最低價再削減的比例(百分比)";
		HelpPctUndermkt	= "設置當該拍賣品沒有人參與競標的比例(百分比)為多少時，開始削價拍賣(直到最大降價比例)";
		HelpPercentless	= "顯示在當前掃描中，直購價低於最高賣出價格特定百分比的所有拍賣品";
		HelpPrintin	= "設置拍賣助手把文字顯示在哪個框架，你可以使用框架名字，也可以用編號";
		HelpProtectWindow	= "防止您意外關閉拍賣場界面";
		HelpRedo	= "設置當由於服務器延遲導致搜索時間太長時是否顯示警告";
		HelpScan	= "進行拍賣掃瞄(若你正在拍賣場界面，相當於按下掃瞄按鈕)或是在下次你訪問拍賣行的時候開始進行掃瞄。選擇你想要掃描的種類然後打勾。";
		HelpStats	= "選擇是否顯示物品的成交價／直購價百分比";
		HelpSuggest	= "選擇是否顯示物品的建議價格";
		HelpUpdatePrice	= "新增拍賣時，當直購價改變時自動更新起標價";
		HelpVerbose	= "選擇是否以多行顯示詳細的平均價格和建議(選擇關閉將以單行顯示)";
		HelpWarnColor	= "選擇是否用不同顏色來標示特殊情況的價格(例如：賤價出售)";


		-- Section: Post Messages
		FrmtNoEmptyPackSpace	= "拍賣行沒有空間進行新拍賣";
		FrmtNotEnoughOfItem	= "拍賣行沒有 %s 個空間進行新拍賣";
		FrmtPostedAuction	= "已經成功進行拍賣 1 件 %s (x%d) ";
		FrmtPostedAuctions	= "已經成功進行拍賣 %d 件 %s (x%d) ";


		-- Section: Report Messages
		FrmtBidbrokerCurbid	= "當前標價";
		FrmtBidbrokerDone	= "交易價代理(Bid broker)完成";
		FrmtBidbrokerHeader	= "最小利潤：%s,上限='最高可售價'";
		FrmtBidbrokerLine	= "%s, 出現過 %s 次, 最高價：%s, %s：%s, 利潤：%s, 次數：%s";
		FrmtBidbrokerMinbid	= "最低交易價";
		FrmtBrokerDone	= "代理(Broker)完成";
		FrmtBrokerHeader	= "最小利潤：%s,上限='最高可售價'";
		FrmtBrokerLine	= "%s,出現%s次,上限：%s,直接購買：%s,利潤：%s";
		FrmtCompeteDone	= "完成競標";
		FrmtCompeteHeader	= "競標每項物品至少差價%s";
		FrmtCompeteLine	= "%s, 標價：%s, 直購價：%s vs %s, 差價 %s";
		FrmtHspLine	= "每個 %s 的最高售價為：%s";
		FrmtLowLine	= "%s, 直購價：%s, 出售者：%s, 單價：%s, 低於平均價：%s";
		FrmtMedianLine	= "共掃瞄到 %d 次, 每個 %s 平均成交價格為：%s";
		FrmtNoauct	= "該物品沒有拍賣記錄：%s";
		FrmtPctlessDone	= "依百分比削減完成";
		FrmtPctlessHeader	= "低於最高可售價格百分比（HSP）：%d%%";
		FrmtPctlessLine	= "%s, 出現過 %d 次, 最高價：%s, 直購價：%s, 利潤：%s, 低於 %s";


		-- Section: Scanning Messages
		AuctionDefunctAucts	= "已移除過期的拍賣：%s";
		AuctionDiscrepancies	= "有改變的項目：%s";
		AuctionNewAucts	= "掃描到的新拍賣：%s";
		AuctionPageN	= "拍賣助手: \n正在掃描 %s 第%d頁 共%d頁\n每秒掃描筆數：%s \n預計剩下時間：%s";
		AuctionScanDone	= "拍賣助手：拍賣掃描完成";
		AuctionScanNexttime	= "拍賣助手將會在下次與拍賣員說話時進行完全掃描";
		AuctionScanNocat	= "你必須最少選擇一個類別進行掃描。";
		AuctionScanRedo	= "目前這頁花了超過 %d 秒掃描，重試本頁。";
		AuctionScanStart	= "拍賣助手：正在掃描 %s 第1頁．．．";
		AuctionTotalAucts	= "掃描到的拍賣數量：%s";


		-- Section: Tooltip Messages
		FrmtInfoAlsoseen	= "在 %s 看過 %d 次";
		FrmtInfoAverage	= "%s 底價/%s 直購 (%s 出價)";
		FrmtInfoBidMulti	= "下標(每個 %s%s)";
		FrmtInfoBidOne	= "下標 %s";
		FrmtInfoBidrate	= "%d%% 已下標, %d%% 有直購價";
		FrmtInfoBuymedian	= "平均直購價";
		FrmtInfoBuyMulti	= "直購(每個 %s%s)";
		FrmtInfoBuyOne	= "直購 %s";
		FrmtInfoForone	= "單個：最低 %s／直購 %s(出價 %s) [%d 個]";
		FrmtInfoHeadMulti	= "%d 個物品平均價格：";
		FrmtInfoHeadOne	= "該物品平均價格：";
		FrmtInfoHistmed	= "共出現 %d 次，平均直購價(每個)";
		FrmtInfoMinMulti	= "起標價(每個 %s)";
		FrmtInfoMinOne	= "起標價";
		FrmtInfoNever	= "從未出現在 %s 過";
		FrmtInfoSeen	= "在拍賣場中出現過 %d 次";
		FrmtInfoSgst	= "建議價格：起標 %s／直購 %s";
		FrmtInfoSgststx	= "對你這一疊共 %d 個的建議價格：起標 %s／直購 %s";
		FrmtInfoSnapmed	= "掃描到 %d 筆，平均直購價(每個)";
		FrmtInfoStacksize	= "平均堆疊數量：%d個";


		-- Section: User Interface
		FrmtLastSoldOn	= "最後售出價格";
		UiBid	= "出價";
		UiBidHeader	= "出價";
		UiBidPerHeader	= "每個標價";
		UiBuyout	= "直購";
		UiBuyoutHeader	= "直購";
		UiBuyoutPerHeader	= "每個直購";
		UiBuyoutPriceLabel	= "直購價：";
		UiBuyoutPriceTooLowError	= "(不可低於起始價)";
		UiCategoryLabel	= "限定類別：";
		UiDepositLabel	= "保管費：";
		UiDurationLabel	= "拍賣時限：";
		UiItemLevelHeader	= "等級";
		UiMakeFixedPriceLabel	= "設定固定價格";
		UiMaxError	= "(%d 最大)";
		UiMaximumPriceLabel	= "最高價格：";
		UiMaximumTimeLeftLabel	= "最大剩餘時間：";
		UiMinimumProfitLabel	= "最小利潤：";
		UiMinimumQualityLabel	= "過濾最低級別：";
		UiMinimumUndercutLabel	= "最低削價：";
		UiNameHeader	= "名字";
		UiNoPendingBids	= "已完成所有出價要求!";
		UiNotEnoughError	= "(不足)";
		UiPendingBidInProgress	= "有1個出價要求正在處理中...";
		UiPendingBidsInProgress	= "%d出價要求正在處理中...";
		UiPercentLessHeader	= "％";
		UiPost	= "專業拍賣";
		UiPostAuctions	= "專業拍賣";
		UiPriceBasedOnLabel	= "定價基於：";
		UiPriceModelAuctioneer	= "拍賣價格";
		UiPriceModelCustom	= "自定價格";
		UiPriceModelFixed	= "固定價格";
		UiPriceModelLastSold	= "最後賣出價";
		UiProfitHeader	= "利潤";
		UiProfitPerHeader	= "每個利潤";
		UiQuantityHeader	= "數量";
		UiQuantityLabel	= "設定數量：";
		UiRemoveSearchButton	= "刪除";
		UiSavedSearchLabel	= "已存搜尋記錄：";
		UiSaveSearchButton	= "存檔";
		UiSaveSearchLabel	= "儲存這次搜尋結果：";
		UiSearch	= "搜尋";
		UiSearchAuctions	= "搜尋拍賣";
		UiSearchDropDownLabel	= "搜尋：";
		UiSearchForLabel	= "尋找物品：";
		UiSearchTypeBids	= "出價查詢";
		UiSearchTypeBuyouts	= "直購價查詢";
		UiSearchTypeCompetition	= "競標";
		UiSearchTypePlain	= "物品";
		UiStacksLabel	= "疊";
		UiStackTooBigError	= "(疊數太多)";
		UiStackTooSmallError	= "(疊數太少)";
		UiStartingPriceLabel	= "起始價格：";
		UiStartingPriceRequiredError	= "(必需填寫)";
		UiTimeLeftHeader	= "剩餘時間";
		UiUnknownError	= "(未知)";

	};

	elGR = {


		-- Section: Auction Messages
		FrmtActRemove	= "Αφαίρεση της υπογραφης %s απο τη δημοπρασια.";
		FrmtAuctinfoHist	= "%d Ιστορικο";
		FrmtAuctinfoMktprice	= "Τιμη κοστους";
		FrmtAuctinfoNolow	= "Αντικειμενο δεν εχει ειδω8ει στη τελευταια δημοπρασια";
		FrmtAuctinfoOrig	= "Αρχικη Προσφορα";
		FrmtAuctinfoSnap	= "%d τελευταια αναζητηση.";
		FrmtAuctinfoSugbid	= "Πρωτη προσφορα";
		FrmtAuctinfoSugbuy	= "Προτεινωμενη τιμη αγορας";
		FrmtWarnAbovemkt	= "Ανταγωνισμος σε ανωτερα επιπεδα απο την τιμη κοστους";
		FrmtWarnMyprice	= "Χρηση της τωρινης τιμης";
		FrmtWarnNocomp	= "Χωρις Ανταγωνισμο";
		FrmtWarnNodata	= "Δεν υπαρχουν πληροφοριες για HSP ";
		FrmtWarnToolow	= "Δεν μπορει να πιαστει η κατωτερη τιμη";
		FrmtWarnUndercut	= "Μειωση κατα %s%% ";
		FrmtWarnUser	= "Χρηση τιμης του χρηστη";


		-- Section: Game Constants
		TimeLong	= "Μακρυ";
		TimeMed	= "Μεσαια";
		TimeShort	= "Συντομα";
		TimeVlong	= "Εχεις καιρο";

	};

	trTR = {


		-- Section: Auction Messages
		FrmtActRemove	= "%s Bu parÃ§a Mevcut AH taramasÄ±ndan kaldÄ±rÄ±ldÄ±.";
		FrmtAuctinfoHist	= "%d geÃ§miÅŸi";
		FrmtAuctinfoLow	= "En dÃ¼ÅŸÃ¼k fiyat";
		FrmtAuctinfoMktprice	= "Pazar fiyatÄ±";
		FrmtAuctinfoNolow	= "Bu parÃ§a daha Ã¶nce hiÃ§ gÃ¶rÃ¼lmedi";
		FrmtAuctinfoOrig	= "Orijinal teklif";
		FrmtAuctinfoSnap	= "%d son tarama";
		FrmtAuctinfoSugbid	= "BaÅŸlangÄ±Ã§ fiyatÄ±";
		FrmtAuctinfoSugbuy	= "Tavsiye edilen hemen-al fiyatÄ±";
		FrmtWarnAbovemkt	= "FiyatÄ±nÄ±z pazarÄ±n Ã¼zerinde ";
		FrmtWarnMarkup	= "FiyatÄ± tÃ¼ccar alÄ±ÅŸ fiyatÄ±nÄ±n %s%% fazlasÄ±na eÅŸitliyor";
		FrmtWarnMyprice	= "Mevcut fiyat kullanÄ±lÄ±yor";
		FrmtWarnNocomp	= "Rekabet yok";
		FrmtWarnNodata	= "HSP iÃ§in veri yok";
		FrmtWarnToolow	= "En dÃ¼ÅŸÃ¼k fiyatla Ã§akÄ±ÅŸmÄ±yor";
		FrmtWarnUndercut	= "Rekabet: Fiyat eksi %s%% ";
		FrmtWarnUser	= "KullanÄ±cÄ± fiyatlandÄ±rmasÄ± kullanÄ±lÄ±yor";


		-- Section: Bid Messages
		FrmtNoAuctionsFound	= "Subasta no encontrada: %s(x%d)";


		-- Section: Command Messages
		FrmtActClearall	= "%s iÃ§in bÃ¼tÃ¼n aÃ§Ä±k artÄ±rma verileri siliniyor ";
		FrmtActClearFail	= "ParÃ§a bulunamadÄ±: %s";
		FrmtActClearOk	= "ParÃ§a iÃ§in tÃ¼m bilgiler temizlendi: %s";
		FrmtActClearsnap	= "Son mÃ¼zayede evi (AH) taramasÄ± temizlendi";
		FrmtActDefault	= "%s seÃ§eneÄŸi varsayÄ±lan deÄŸerine getirildi";
		FrmtActDefaultall	= "BÃ¼tÃ¼n seÃ§enekler varsayÄ±lan deÄŸere indirgendi.";
		FrmtActDisable	= "%s parÃ§asÄ±nÄ±n verisi gÃ¶sterilmiyor";
		FrmtActEnable	= "%s parÃ§asÄ±nÄ±n verisi gÃ¶steriliyor";
		FrmtActSet	= "%s '%s' olarak ayarlandÄ±";
		FrmtActUnknown	= "Bilinmeyen komut: '%s'";
		FrmtAuctionDuration	= "VarsayÄ±lan aÃ§Ä±k artÄ±rma sÃ¼resi %s olarak ayarlandÄ±";
		FrmtAutostart	= "Otomatik olarak mÃ¼zayedeye baÅŸlanÄ±yor. Minimum: %s / Hemen-al: %s (%dh)\n%s";
		FrmtPrintin	= "Auctioneer mesajÄ± ÅŸimdi %s chat penceresinde yazÄ±lacak.";
		FrmtProtectWindow	= "MÃ¼zayede evinin penceresinin korumasÄ± %s olarak ayarlandÄ±";
		FrmtUnknownArg	= "'%s' '%s' iÃ§in geÃ§erli bir komut deÄŸil ";
		FrmtUnknownLocale	= "BelirttiÄŸiniz yer ('%s') bilinmiyor. Belirlenen yerler:";
		FrmtUnknownRf	= "GeÃ§ersiz komut ('%s').  Komut ÅŸu ÅŸekilde formatlanmalÄ±: [sunucu]-[taraf]. Ã–rnek: Al'Akir-Horde";


		-- Section: Command Options
		OptAlso	= "(sunucu-taraf|karÅŸÄ±)";
		OptAuctionDuration	= "(son||2s||8s||24s) ";
		OptBidbroker	= "<gÃ¼mÃ¼ÅŸ_kazanÃ§>";
		OptBroker	= "<gÃ¼mÃ¼ÅŸ_kazanÃ§>";
		OptClear	= "([ParÃ§a]|hepsi|son tarama) ";
		OptCompete	= "<gÃ¼mÃ¼ÅŸ_az> ";
		OptDefault	= "(<seÃ§enek>|hepsi) ";
		OptLocale	= "<yer>";
		OptPctBidmarkdown	= "<yÃ¼zde>";
		OptPctMarkup	= "<yÃ¼zde>";
		OptPctMaxless	= "<yÃ¼zde>";
		OptPctNocomp	= "<yÃ¼zde>";
		OptPctUnderlow	= "<yÃ¼zde>";
		OptPctUndermkt	= "<yÃ¼zde>";
		OptPercentless	= "<yÃ¼zde>";
		OptPrintin	= "(<BaÅŸlangÄ±Ã§ Penceresi>[Numara]|<Pencere AdÄ±>[YazÄ±]) ";
		OptProtectWindow	= "(asla||taramada||her zaman)";
		OptScale	= "<oran_faktÃ¶r>";
		OptScan	= "<Tarama parametresi> ";


		-- Section: Commands
		CmdAlso	= "ek olarak";
		CmdAlsoOpposite	= "karÅŸÄ±";
		CmdAlt	= "Alt";
		CmdAuctionClick	= "mÃ¼zayede-tÄ±klama";
		CmdAuctionDuration	= "mÃ¼zayede sÃ¼resi";
		CmdAuctionDuration0	= "son";
		CmdAuctionDuration1	= "2s";
		CmdAuctionDuration2	= "8s";
		CmdAuctionDuration3	= "24s";
		CmdAutofill	= "otomatik doldurma";
		CmdBidbroker	= "bidbroker";
		CmdBidbrokerShort	= "bb";
		CmdBroker	= "broker";
		CmdClear	= "sil";
		CmdClearAll	= "hepsi";
		CmdClearSnapshot	= "Sontarama";
		CmdCompete	= "Rekabet";
		CmdCtrl	= "Ctrl";
		CmdDefault	= "Orijinal";
		CmdDisable	= "iptal";
		CmdEmbed	= "yerlestir";
		CmdLocale	= "yerbelirle";
		CmdOff	= "kapat";
		CmdOn	= "ac";
		CmdPctBidmarkdown	= "fiyat-dus";
		CmdPctMarkup	= "fiyat-art";
		CmdPctMaxless	= "fiyat-max-az";
		CmdPctNocomp	= "fiyat-rekabet-yok";
		CmdPctUnderlow	= "fiyat-en-asagi";
		CmdPctUndermkt	= "fiyat-pazar-altÄ±";
		CmdPercentless	= "yuzdeucuz";
		CmdPercentlessShort	= "yu";
		CmdPrintin	= "buraya_aktar";
		CmdProtectWindow	= "pencere-koru";
		CmdProtectWindow0	= "asla";
		CmdProtectWindow1	= "taramada";
		CmdProtectWindow2	= "daima";
		CmdScan	= "tara";
		CmdShift	= "shift";
		CmdToggle	= "degistir";
		ShowAverage	= "ortalamayÄ±-goster";
		ShowEmbedBlank	= "goster-yerlestir-beyazcizgi";
		ShowLink	= "goster-sekme";
		ShowMedian	= "goster-ortanca";
		ShowRedo	= "goster-uyarÄ±";
		ShowStats	= "goster-istatistik";
		ShowSuggest	= "goster-oneri";
		ShowVerbose	= "goster-detayli";


		-- Section: Config Text
		GuiAlso	= "Ek veri gÃ¶sterlecek";
		GuiAlsoDisplay	= "%s iÃ§in veri gÃ¶steriliyor";
		GuiAlsoOff	= "DiÄŸer sunucu/taraf verisi gÃ¶sterilmiyor";
		GuiAlsoOpposite	= "DiÄŸer taraf iÃ§in de bilgi gÃ¶steriliyor.";
		GuiAuctionDuration	= "VarsayÄ±lan mÃ¼zayede sÃ¼resi";
		GuiAuctionHouseHeader	= "MÃ¼zayede evi (AH) penceresi";
		GuiAuctionHouseHeaderHelp	= "MÃ¼zayede evi (AH) penceresinin ayarlarÄ±nÄ± deÄŸiÅŸtir";
		GuiAutofill	= "MÃ¼zayede evinde (AH) fiyatlarÄ± otomatik olarak gir.";
		GuiAverages	= "OrtalamalarÄ± gÃ¶ster";
		GuiBidmarkdown	= "%x daha dÃ¼ÅŸÃ¼k fiyata koy";
		GuiClearall	= "BÃ¼tÃ¼n Auctioneer verilerini sil";
		GuiClearallButton	= "Hepsini Sil";
		GuiClearallHelp	= "Aktif sunucudaki tÃ¼m Auctioneer verilerini siler";
		GuiClearallNote	= "Aktif sunucu ve tarafÄ±n tÃ¼m verileri";
		GuiClearHeader	= "Verileri Sil";
		GuiClearHelp	= "Auctioneer verilerini siler. TÃ¼m verileri veya son taramayÄ± seÃ§iniz. UYARI: bu iÅŸlemin geri dÃ¶nÃ¼ÅŸÃ¼ yok";
		GuiClearsnap	= "Son tarama verilerini sil";
		GuiClearsnapButton	= "Son tarama sil";
		GuiClearsnapHelp	= "Auctioneer in son tarama verilerini silmek iÃ§in tÄ±klayÄ±n.";
		GuiDefaultAll	= "Auctioneer ayarlarÄ±nÄ± sÄ±fÄ±rla";
		GuiDefaultAllButton	= "Hepsini SÄ±fÄ±rla";
		GuiDefaultAllHelp	= "Auctioneer ayarlarÄ±nÄ±n hepsini sÄ±fÄ±rlamak iÃ§in tÄ±klayÄ±nÄ±z. UYARI: Bu iÅŸlemin geri dÃ¶nÃ¼ÅŸÃ¼ yoktur";
		GuiDefaultOption	= "Bu ayarÄ± sÄ±fÄ±rla";
		GuiEmbed	= "Bilgileri oyun iÃ§i imgeÃ§ ucuna yerleÅŸtir";
		GuiEmbedBlankline	= "Oyun iÃ§i imgeÃ§ ucunda boÅŸ satÄ±r gÃ¶ster";
		GuiEmbedHeader	= "YerleÅŸtir";
		GuiLink	= "LinkID gÃ¶ster";
		GuiLoad	= "Auctioneer i otomatik yÃ¼kle";
		GuiLoad_Always	= "daima";
		GuiLoad_AuctionHouse	= "MÃ¼zayede Evinde";
		GuiLoad_Never	= "asla";
		GuiLocale	= "Yer ayarla";
		GuiMainEnable	= "Etkinkil Auctioneer";
		GuiMaxless	= "Max pazar fiyatinin altÄ±na inme yÃ¼zdesi";
		GuiMedian	= "OrtancalarÄ± gÃ¶ster";
		GuiNocomp	= "Rekabet yokken indirim yÃ¼zdesi";
		GuiNoWorldMap	= "Auctioneer: DÃ¼nya haritasÄ±nÄ±n gÃ¶sterimi engellendi";
		GuiOtherHeader	= "DiÄŸer seÃ§enekler";
		GuiOtherHelp	= "DiÄŸer Auctioneer seÃ§enekleri";
		GuiPercentsHeader	= "Auctioneer limit yÃ¼zdeleri";
		GuiPercentsHelp	= "DÄ°KKAT: Takip eden seÃ§enekler SADECE uzman oyuncular iÃ§indir. Auctioneer'in karlÄ±lÄ±k belirlemesi yaparken ne kadar hÄ±rslÄ± olmasÄ±nÄ± istediÄŸinizi bu deÄŸerleri deÄŸiÅŸtirerek ayarlayÄ±n. ";
		GuiPrintin	= "Ã‡Ä±ktÄ± penceresi seÃ§";
		GuiProtectWindow	= "MÃ¼zayede penceresinin istenmeden kapanmasÄ±nÄ± engelle";
		GuiRedo	= "Uzun tarama uyarÄ±sÄ±";
		GuiReloadui	= "KullanÄ±cÄ± arabirimini yeniden yÃ¼kler";
		GuiReloaduiFeedback	= "WoW arabirimi yÃ¼kleniyor";
		GuiReloaduiHelp	= "AyarlarÄ±nÄ±zÄ± yaptÄ±ktan sonra WoW arayÃ¼zÃ¼nÃ¼ tekrar yÃ¼klemek iÃ§in buraya tÄ±klayÄ±nÄ±z ki ayarlarÄ±nÄ±z uyuÅŸsun.";
		GuiRememberText	= "FiyatÄ± hatÄ±rla";
		GuiStatsEnable	= "Ä°statistikleri gÃ¶ster";
		GuiStatsHeader	= "Fiyat Ä°statistikleri";
		GuiStatsHelp	= "Bu Ä°statistikleri Tooltip'de gÃ¶ster";
		GuiSuggest	= "Tavsiye edilen fiyatÄ± gÃ¶ster";
		GuiUnderlow	= "En dÃ¼ÅŸÃ¼k rakibin altÄ±na inme yÃ¼zdesi";
		GuiUndermkt	= "Pazar altÄ±na inme yÃ¼zdesi";
		GuiVerbose	= "DetaylÄ± Mode";


		-- Section: Conversion Messages
		MesgConvert	= "Auctioneer veritabanÄ± dnÃ¼ÅŸtÃ¼rÃ¼mÃ¼. LÃ¼tfen Ã¶nce SavedVariables\Auctioneer.lua dosyanÄ±zÄ± yedekleyin.%s%s";
		MesgConvertNo	= "Auctioneer'i devre dÄ±ÅŸÄ± bÄ±rak";
		MesgConvertYes	= "DÃ¶nÃ¼ÅŸtÃ¼r";
		MesgNotconverting	= "Auctioneer veritabanÄ±nÄ±zÄ± dÃ¶nÃ¼ÅŸtÃ¼rmÃ¼yor, fakat bu iÅŸlemi yapmadÄ±ÄŸÄ±nÄ±z sÃ¼rece de Ã§alÄ±ÅŸmayacaktÄ±r.";


		-- Section: Game Constants
		TimeLong	= "Uzun";
		TimeMed	= "Orta";
		TimeShort	= "KÄ±sa";
		TimeVlong	= "Ã‡ok Uzun";


		-- Section: Generic Messages
		DisableMsg	= "Auctioneer'in otomatik yÃ¼klenmesini devre dÄ±ÅŸÄ± bÄ±rak.";
		FrmtWelcome	= "Auctioneer v%s yÃ¼klendi";
		MesgNotLoaded	= "Auctioneer yÃ¼klenmedi. Daha fazla bilgi iÃ§in /auctioneer yazÄ±nÄ±z.";
		StatOff	= "AÃ§Ä±k arttÄ±rma verileri gÃ¶sterilmiyor.";
		StatOn	= "TanÄ±mlanmÄ±ÅŸ aÃ§Ä±k arttÄ±rma verileri gÃ¶rÃ¼ntÃ¼leniyor.";


		-- Section: Generic Strings
		TextCombat	= "DÃ¶vÃ¼ÅŸ";
		TextGeneral	= "Genel";
		TextNone	= "hiÃ§birÅŸey";
		TextScan	= "Tarama";
		TextUsage	= "KullanÄ±mÄ±:";


		-- Section: Scanning Messages
		AuctionDiscrepancies	= "TutarsÄ±zlÄ±klar: %s";
		AuctionScanDone	= "Auctioneer: Tarama sonuÃ§landÄ±";
		AuctionScanNocat	= "En azÄ±ndan bir kategori tarama iÃ§in seÃ§ilmiÅŸ olmalÄ±";
		AuctionScanRedo	= "Su anki sayfanÄ±n tamamlanmasÄ± %d saniyeden uzun sÃ¼rdÃ¼, sayfayÄ± tekrar deniyor.";
		AuctionScanStart	= "Auctioneer: taranÄ±yor %s sayfa 1... ";
		AuctionTotalAucts	= "Taranan toplam aÃ§Ä±k artÄ±rma: %s ";


		-- Section: Tooltip Messages
		FrmtInfoAlsoseen	= "%s 'de %d kere gÃ¶rÃ¼ldÃ¼ ";
		FrmtInfoAverage	= "%s min/%s SA (%s teklif almÄ±ÅŸ) ";
		FrmtInfoBidMulti	= "Teklif edilen (%s%s herbir) ";
		FrmtInfoBidOne	= "Teklif edilen%s";
		FrmtInfoBidrate	= "%d%% sine teklif var, %d%% sinin SA si var";
		FrmtInfoBuymedian	= "SatÄ±n al ortancasÄ±";
		FrmtInfoBuyMulti	= "SatÄ±n al (%s%s herbir) ";
		FrmtInfoBuyOne	= "SatÄ±n al%s ";
		FrmtInfoForone	= "1 adet iÃ§in: %s min/%s SA (%s teklif almÄ±ÅŸ) [in %d's] ";
		FrmtInfoHeadMulti	= "%d adet iÃ§in ortalama: ";
		FrmtInfoHeadOne	= "Bu cisim iÃ§in ortalamalar";
		FrmtInfoHistmed	= "Son %d, ortanca SA () ";
		FrmtInfoMinMulti	= "BaÅŸlangÄ±Ã§ fiyatÄ± (%s herbir) ";
		FrmtInfoMinOne	= "BaÅŸlangÄ±Ã§ fiyatÄ±";
		FrmtInfoNever	= "%s 'de hiÃ§ gÃ¶rÃ¼lmedi";
		FrmtInfoSeen	= "%d kere aÃ§Ä±k artÄ±rmada gÃ¶rÃ¼ldÃ¼ toplamda";
		FrmtInfoSgst	= "Tavsiye edilen fiyat: %s min/%s SA";
		FrmtInfoSgststx	= "%d adetlik grubunuz iÃ§in tavsiye edilen fiyat: %s min/%s SA";
		FrmtInfoSnapmed	= "Taranan %d, ortanca SA (herbir) ";
		FrmtInfoStacksize	= "Ortalama grup bÃ¼yÃ¼klÃ¼ÄŸÃ¼: %d adet";

	};
}