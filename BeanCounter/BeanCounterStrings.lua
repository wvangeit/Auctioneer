--[[
	WARNING: This is a generated file.
	If you wish to perform or update localizations, please go to our Localizer website at:
	http://localizer.norganna.org/

	AddOn: BeanCounter
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

BeanCounterLocalizations = {

	csCZ = {

		-- Section: Mail
		["MailAllianceAuctionHouse"]	= "Aliancni aukce";
		["MailAuctionCancelledSubject"]	= "Aukce zrusena";
		["MailAuctionExpiredSubject"]	= "Platnost aukce vyprsela";
		["MailAuctionSuccessfulSubject"]	= "Aukce probehla uspesne";
		["MailAuctionWonSubject"]	= "Vyhral/a jste aukci";
		["MailHordeAuctionHouse"]	= "Hordacka aukce";
		["MailOutbidOnSubject"]	= "Prehozen/a na";

		-- Section: User Interface
		["UiAuctions"]	= "Aukce";
		["UiAuctionTransaction"]	= "Aukce";
		["UiBids"]	= "Bidy";
		["UiBidTransaction"]	= "Bid";
		["UiBuyerSellerHeader"]	= "Zakaznik/prodavajici";
		["UiBuyTransaction"]	= "Kup";
		["UiDateHeader"]	= "Datum";
		["UiDepositTransaction"]	= "Sklad";
		["UiExactNameSearch"]	= "Presny nazev";
		["UiNameHeader"]	= "Vec";
		["UiNetHeader"]	= "Sit";
		["UiNetPerHeader"]	= "Sit per";
		["UiPriceHeader"]	= "Cena";
		["UiPricePerHeader"]	= "Cenova hlava";
		["UiPurchases"]	= "Nakupy";
		["UiQuantityHeader"]	= "Mnozstvi";
		["UiSales"]	= "Prodeje";
		["UiSearch"]	= "Hledat";
		["UiSearchForLabel"]	= "Hledej";
		["UiSellTransaction"]	= "Prodej";
		["UiTransactions"]	= "Transakce";
		["UiTransactionsLabel"]	= "Transakce";
		["UiTransactionTypeHeader"]	= "Typ";

	};

	daDK = {

		-- Section: Mail
		["MailAllianceAuctionHouse"]	= "Alliance Auktions Hus";
		["MailAuctionCancelledSubject"]	= "Auktion afbrudt";
		["MailAuctionExpiredSubject"]	= "Auktion udløbet";
		["MailAuctionSuccessfulSubject"]	= "Auktion succesfuld";
		["MailAuctionWonSubject"]	= "Auktion vundet";
		["MailHordeAuctionHouse"]	= "Horde Auktions Hus";
		["MailOutbidOnSubject"]	= "Overbudt på";

		-- Section: User Interface
		["UiAuctions"]	= "Auktioner";
		["UiAuctionTransaction"]	= "Auktion";
		["UiBids"]	= "Bud";
		["UiBidTransaction"]	= "Byd";
		["UiBuyerSellerHeader"]	= "Køber/Sælger";
		["UiBuyTransaction"]	= "Køb";
		["UiDateHeader"]	= "Dato";
		["UiDepositTransaction"]	= "Indskud";
		["UiExactNameSearch"]	= "Eksakt navne-søgning";
		["UiNameHeader"]	= "Item";
		["UiNetHeader"]	= "Net";
		["UiNetPerHeader"]	= "Net Per";
		["UiPriceHeader"]	= "Pris";
		["UiPricePerHeader"]	= "Styk Pris";
		["UiPurchases"]	= "Køb";
		["UiQuantityHeader"]	= "Stk";
		["UiSales"]	= "Salg";
		["UiSearch"]	= "Søg";
		["UiSearchForLabel"]	= "Søg efter:";
		["UiSellTransaction"]	= "Sælg";
		["UiTransactions"]	= "Transaktioner";
		["UiTransactionsLabel"]	= "Transaktioner:";
		["UiTransactionTypeHeader"]	= "Type";

	};

	deDE = {

		-- Section: Config Text
		["C_BeanCounterConfig"]	= "BeanCounter Konfig.";
		["C_BeanCounterOptions"]	= "BeanCounter Optionen";
		["C_DateString"]	= "|CCFFFCC00 Zu verwendendes Datumsformat:";
		["C_DateStringExample"]	= "|CCFFFCC00 Beispieldatum:";
		["C_ExtenalSearch"]	= "Externen AddOns die BeanCounter Suche erlauben";
		["C_MailInvoiceTimeout"]	= "Mail-Zeitüberschreitung = %d Sekunden";
		["C_MailRecolor"]	= "Mail einfärben";

		-- Section: Generic Strings
		["NoRe-Color"]	= "Kein einfärben";
		["off"]	= "aus";
		["on"]	= "ein";
		["Re-ColorIcons"]	= "Icons einfärben";
		["Re-ColorIconsandText"]	= "Icons und Text einfärben";
		["Re-ColorText"]	= "Text einfärben";

		-- Section: Help Text
		["A_DateString"]	= "Dies bestimmt, wie das Datum vom GUI BeanCounters angezeigt wird. Befehle werden durch % eingeleitet und mehrfache Befehle und Text können gemischt werden. Z.B. würde %a == %X Mi == 21:34:21 anzeigen";
		["A_DateStringCommands"]	= "Commands: \n %a = gek. Wochentagsname, \n %A = voller Wochentagsname, \n %b = gek. Monatsname, \n %B = voller Monatsname,\n %c = Datum und Zeit, \n %d = Monatstag (01-31),\n %H = Stunde (24), \n %I = Stunde (12),\n %M = Minute, \n %m = Monat,\n %p = am/pm, \n %S = Sekunde,\n %U = Jahreswochennummer ,\n %w = Nummerischer Wochentag (0-6),\n %x = Datum, \n %X = Zeit,\n %Y = Jahr lang (2007), \n %y = Jahr kurz (07)";
		["A_ExtenalSearch"]	= "Andere Addons können BeanCounters Suche nutzen, damit ein Item im GUI von BeanCounter angezeigt werden kann. Dies läßt BeanCounter z.B. zeigen, welche Items Sie in Appraiser betrachten";
		["A_MailInvoiceTimeout"]	= "Die Zeitspanne, die BeanCounter auf eine Antwort des Servers wartet, um auf eine Mailabfrage zu reagieren. Eine Abfrage ist das wer, was, wie von Auktionshausmails.";
		["A_MailRecolor"]	= "BeanCounter liest alle Mails vom Auktionshaus. Diese Option bestimmt, wie BeanCounter die Anzeige der Mails einfärben soll, um sie als ungelesen darzustellen.";
		["HelpGuiItemBox"]	= "Ziehe ein Item in die Box für Suche";
		["Q_DateString"]	= "Anzuwendendes Datumsformat ?";
		["Q_DateStringCommands"]	= "Gültige Datumsbefehle ?";
		["Q_ExtenalSearch"]	= "Erlaube ext. AddOns die Benutzung von BeanCounter ?";
		["Q_MailInvoiceTimeout"]	= "Was ist eine Mail-Zeitüberschreitung ?";
		["Q_MailRecolor"]	= "Was ist Mail einfärben ?";

		-- Section: Mail
		["MailAllianceAuctionHouse"]	= "Auktionshaus der Allianz";
		["MailAuctionCancelledSubject"]	= "Auktion abgebrochen";
		["MailAuctionExpiredSubject"]	= "Auktion abgelaufen";
		["MailAuctionSuccessfulSubject"]	= "Auktion erfolgreich";
		["MailAuctionWonSubject"]	= "Auktion gewonnen";
		["MailHordeAuctionHouse"]	= "Auktionshaus der Horde";
		["MailOutbidOnSubject"]	= "Höheres Gebot für";
		["MailSalePendingOnSubject"]	= "Ausstehender Verkauf";

		-- Section: Tooltip Messages
		["TTDateString"]	= "Tragen Sie das Format ein, wie Sie das Datum darstellen möchten. Standard ist %c";
		["TTDateStringExample"]	= "Zeigt ein Beispiel an, wie Ihre Datumsausgabe aussehen wird";
		["TTExtenalSearch"]	= "Wenn eine Suche in ein anderes AddOn eingetragen wird, zeigt BeanCounter auch eine Suche nach diesem Item an.";
		["TTMailInvoiceTimeout"]	= "Bestimmt wie lange BeanCounter versucht, eine Mail vom Server zu erhalten, bevor es aufgibt. Tiefer == schneller, aber grössere Wahrscheinlichkeit auf fehlende Daten; Höher == langsamer, verbessert aber die Wahrscheinlichkeit alle Daten zu erhalten, wenn der Mailserver extrem beschäftigt ist.";
		["TTMailRecolor"]	= "Wählen Sie, wie die Mailanzeige erscheint, nachdem BeanCounter den Briefkasten durchsucht hat.";

		-- Section: User Interface
		["UiAddonTitle"]	= "BeanCounter: Auktionenverlauf Datenbank";
		["UiAucExpired"]	= "Auktion abgelaufen";
		["UiAucSuccessful"]	= "Auktion erfolgreich";
		["UiAuctions"]	= "Auktionen";
		["UiAuctionTransaction"]	= "Auktion";
		["UiBids"]	= "Gebote";
		["UiBidTransaction"]	= "Gebot";
		["UiBuyerSellerHeader"]	= "Käufer/Verkäufer";
		["UiBuyTransaction"]	= "Kaufen";
		["UiClassicCheckBox"]	= "Zeige klassische BC-Daten";
		["UiData"]	= "Daten";
		["UiDateHeader"]	= "Datum";
		["UiDepositTransaction"]	= "Anzahlung";
		["UiDone"]	= "Fertig";
		["UiExactNameSearch"]	= "Genaue Namenssuche";
		["UiFailedAuctions"]	= "Fehlgeschlagene Auktion";
		["UiFee"]	= "Gebühr";
		["UiNameHeader"]	= "Gegenstand";
		["UiNetHeader"]	= "Netto";
		["UiNetPerHeader"]	= "Netto pro";
		["UiOutbid"]	= "Überboten";
		["UiOutbids"]	= "Überboten";
		["UiPriceHeader"]	= "Preis";
		["UiPriceper"]	= "Einzelpreis";
		["UiPricePerHeader"]	= "Preisüberschrift";
		["UiPurchases"]	= "Einkäufe";
		["UiQuantityHeader"]	= "Anz.";
		["UiSales"]	= "Verkäufe";
		["UiSearch"]	= "Suche";
		["UiSearchForLabel"]	= "Suche nach:";
		["UiSellTransaction"]	= "Verkaufen";
		["UiServer"]	= "Server";
		["UiTransactions"]	= "Transaktionen";
		["UiTransactionsLabel"]	= "Transaktionen:";
		["UiTransactionTypeHeader"]	= "Typ";
		["UiWealth"]	= "Vermögen";
		["UiWononBid"]	= "Gebotskauf";
		["UiWononBuyout"]	= "Sofortkauf";

	};

	enUS = {

		-- Section: Config Text
		["C_BeanCounterConfig"]	= "BeanCounter Config";
		["C_BeanCounterOptions"]	= "BeanCounter options";
		["C_DateString"]	= "|CCFFFCC00 Date format to use:";
		["C_DateStringExample"]	= "|CCFFFCC00 Example Date:";
		["C_ExtenalSearch"]	= "Allow External Addons to use BeanCounter's Search?";
		["C_MailInvoiceTimeout"]	= "Mail Invoice Timeout = %d seconds";
		["C_MailRecolor"]	= "Mail Re-Color Method";

		-- Section: Generic Strings
		["NoRe-Color"]	= "No Re-Color";
		["off"]	= "off";
		["on"]	= "on";
		["Re-ColorIcons"]	= "Re-Color Icons";
		["Re-ColorIconsandText"]	= "Re-Color Icons and Text";
		["Re-ColorText"]	= "Re-Color Text";

		-- Section: Help Text
		["A_DateString"]	= "This controls how the Date field of BeanCounter's GUI is shown. Commands are prefaced by % and multiple commands and text can be mixed. For example %a == %X would display Wed == 21:34:21";
		["A_DateStringCommands"]	= "Commands: \n %a = abr. weekday name, \n %A = weekday name, \n %b = abr. month name, \n %B = month name,\n %c = date and time, \n %d = day of the month (01-31),\n %H = hour (24), \n %I = hour (12),\n %M = minute, \n %m = month,\n %p = a";
		["A_ExtenalSearch"]	= "Other addons can have BeanCounter search for an item to be displayed in BeanCounter's GUI. For example this allows BeanCounter to show what items you are looking at in Appraiser";
		["A_MailInvoiceTimeout"]	= "The length of time BeanCounter will wait on the server to respond to an invoice request. A invoice is the who, what, how of an Auction house mail.";
		["A_MailRecolor"]	= "BeanCounter reads all mail from the Auction House, This option tells BeanCounter how the user wants to Recolor the messages to make them look unread.";
		["HelpGuiItemBox"]	= "Drop item into box to search.";
		["Q_DateString"]	= "Date Format to use?";
		["Q_DateStringCommands"]	= "Acceptable Date Commands?";
		["Q_ExtenalSearch"]	= "Allow External Addons to use BeanCounter?";
		["Q_MailInvoiceTimeout"]	= "What is Mail Invoice Timeout?";
		["Q_MailRecolor"]	= "What is recolor?";

		-- Section: Mail
		["MailAllianceAuctionHouse"]	= "Alliance Auction House";
		["MailAuctionCancelledSubject"]	= "Auction cancelled";
		["MailAuctionExpiredSubject"]	= "Auction expired";
		["MailAuctionSuccessfulSubject"]	= "Auction successful";
		["MailAuctionWonSubject"]	= "Auction won";
		["MailHordeAuctionHouse"]	= "Horde Auction House";
		["MailOutbidOnSubject"]	= "Outbid on";
		["MailSalePendingOnSubject"]	= "Sale Pending";

		-- Section: Tooltip Messages
		["TTDateString"]	= "Enter the format that you would like your date field to show. Default is %c";
		["TTDateStringExample"]	= "Displays an example of what your formated date will look like";
		["TTExtenalSearch"]	= "When entering a search in another addon, BeanCounter will also display a search for that item.";
		["TTMailInvoiceTimeout"]	= "Chooses how long BeanCounter will attempt to get a mail invoice from the server before giving up. Lower == quicker but more chance of missing data, Higher == slower but improves chances of getting data if the Mail server is extremely busy.";
		["TTMailRecolor"]	= "Choose how Mail will appear after BeanCounter has scanned the Mail Box.";

		-- Section: User Interface
		["UiAddonTitle"]	= "BeanCounter: Auction History Database";
		["UiAucExpired"]	= "Auc Expired";
		["UiAucSuccessful"]	= "Auc Successful";
		["UiAuctions"]	= "Auctions";
		["UiAuctionTransaction"]	= "Auction";
		["UiBids"]	= "Bids";
		["UiBidTransaction"]	= "Bid";
		["UiBuyerSellerHeader"]	= "Buyer/Seller";
		["UiBuyTransaction"]	= "Buy";
		["UiClassicCheckBox"]	= "Show BC Classic data.";
		["UiData"]	= "Data";
		["UiDateHeader"]	= "Date";
		["UiDepositTransaction"]	= "Deposit";
		["UiDone"]	= "Done";
		["UiExactNameSearch"]	= "Exact name search";
		["UiFailedAuctions"]	= "Failed Auctions ";
		["UiFee"]	= "Fee";
		["UiNameHeader"]	= "Item";
		["UiNetHeader"]	= "Net";
		["UiNetPerHeader"]	= "Net Per";
		["UiOutbid"]	= "Outbid";
		["UiOutbids"]	= "Outbids";
		["UiPriceHeader"]	= "Price";
		["UiPriceper"]	= "Price/Per";
		["UiPricePerHeader"]	= "Price Header";
		["UiPurchases"]	= "Purchases";
		["UiQuantityHeader"]	= "Qty";
		["UiSales"]	= "Sales";
		["UiSearch"]	= "Search";
		["UiSearchForLabel"]	= "Search for:";
		["UiSellTransaction"]	= "Sell";
		["UiServer"]	= "Server";
		["UiTransactions"]	= "Transactions";
		["UiTransactionsLabel"]	= "Transactions:";
		["UiTransactionTypeHeader"]	= "Type";
		["UiWealth"]	= "Wealth";
		["UiWononBid"]	= "Won on Bid";
		["UiWononBuyout"]	= "Won on Buyout";

	};

	esES = {

		-- Section: Mail
		["MailAllianceAuctionHouse"]	= "Casa de subastas de la Alianza";
		["MailAuctionCancelledSubject"]	= "Subasta cancelada";
		["MailAuctionExpiredSubject"]	= "Subasta terminada";
		["MailAuctionSuccessfulSubject"]	= "Subasta conseguida";
		["MailAuctionWonSubject"]	= "Subasta ganada";
		["MailHordeAuctionHouse"]	= "Casa de subastas de la Horda";
		["MailOutbidOnSubject"]	= "Puja superada en";

		-- Section: User Interface
		["UiAuctions"]	= "Subastas";
		["UiAuctionTransaction"]	= "Subasta";
		["UiBids"]	= "Pujas";
		["UiBidTransaction"]	= "Puja";
		["UiBuyerSellerHeader"]	= "Comprador/Vendedor";
		["UiBuyTransaction"]	= "Compra";
		["UiDateHeader"]	= "Fecha";
		["UiDepositTransaction"]	= "Depósito";
		["UiExactNameSearch"]	= "Búsqueda de nombre exacto";
		["UiNameHeader"]	= "Artículo";
		["UiNetHeader"]	= "Neto";
		["UiNetPerHeader"]	= "Neto c/u";
		["UiPriceHeader"]	= "Precio";
		["UiPricePerHeader"]	= "Precio c/u";
		["UiPurchases"]	= "Compras";
		["UiQuantityHeader"]	= "Ctd";
		["UiSales"]	= "Ventas";
		["UiSearch"]	= "Buscar";
		["UiSearchForLabel"]	= "Buscar por:";
		["UiSellTransaction"]	= "Vender";
		["UiTransactions"]	= "Transacciones";
		["UiTransactionsLabel"]	= "Transacciones:";
		["UiTransactionTypeHeader"]	= "Tipo";

	};

	frFR = {

		-- Section: Config Text
		["C_BeanCounterConfig"]	= "BeanCounter Configuration";
		["C_BeanCounterOptions"]	= "BeanCounter Options";
		["C_DateString"]	= "|CCFFFCC00 Format date a utiliser:";
		["C_DateStringExample"]	= "|CCFFFCC00 Exemple Date:";
		["C_ExtenalSearch"]	= "Autorise les Addons Externes a utiliser la recherche BeanCounter?";

		-- Section: Mail
		["MailAllianceAuctionHouse"]	= "Hôtel des ventes de l'Alliance";
		["MailAuctionCancelledSubject"]	= "Vente annulée";
		["MailAuctionExpiredSubject"]	= "Vente aux enchères terminée";
		["MailAuctionSuccessfulSubject"]	= "Vente aux enchères réussie";
		["MailAuctionWonSubject"]	= "Vente gagnée";
		["MailHordeAuctionHouse"]	= "Hôtel des ventes de la Horde";
		["MailOutbidOnSubject"]	= "Augmenter l'offre pour";

		-- Section: User Interface
		["UiAuctions"]	= "Enchères";
		["UiAuctionTransaction"]	= "Enchère";
		["UiBids"]	= "Offres";
		["UiBidTransaction"]	= "Offre";
		["UiBuyerSellerHeader"]	= "Acheteur/Vendeur";
		["UiBuyTransaction"]	= "Acheter";
		["UiDateHeader"]	= "Date";
		["UiDepositTransaction"]	= "Dépôt";
		["UiExactNameSearch"]	= "Nom exact";
		["UiNameHeader"]	= "Objet";
		["UiNetHeader"]	= "Net";
		["UiNetPerHeader"]	= "Net unit.";
		["UiPriceHeader"]	= "Prix";
		["UiPricePerHeader"]	= "Prix unit.";
		["UiPurchases"]	= "Achats";
		["UiQuantityHeader"]	= "Qte";
		["UiSales"]	= "Ventes";
		["UiSearch"]	= "Recherche";
		["UiSearchForLabel"]	= "Rechercher :";
		["UiSellTransaction"]	= "Vendre";
		["UiTransactions"]	= "Transactions";
		["UiTransactionsLabel"]	= "Transactions:";
		["UiTransactionTypeHeader"]	= "Type";

	};

	itIT = {

		-- Section: Mail
		["MailAllianceAuctionHouse"]	= "Casa d'aste dell'Alleanza";
		["MailAuctionCancelledSubject"]	= "Asta annullata";
		["MailAuctionExpiredSubject"]	= "Asta espirata";
		["MailAuctionSuccessfulSubject"]	= "Asta riuscita";
		["MailAuctionWonSubject"]	= "Asta vinta";
		["MailHordeAuctionHouse"]	= "Casa d'aste dell'Orda";
		["MailOutbidOnSubject"]	= "Battuto su";

		-- Section: User Interface
		["UiAuctions"]	= "Aste";
		["UiAuctionTransaction"]	= "Asta";
		["UiBids"]	= "Offerte";
		["UiBidTransaction"]	= "Offerta";
		["UiBuyerSellerHeader"]	= "Compratore/Venditore";
		["UiBuyTransaction"]	= "Compra";
		["UiDateHeader"]	= "Data";
		["UiDepositTransaction"]	= "Deposito";
		["UiExactNameSearch"]	= "Ricerca nome esatto";
		["UiNameHeader"]	= "Oggetto";
		["UiNetHeader"]	= "Netto";
		["UiNetPerHeader"]	= "Netto per";
		["UiPriceHeader"]	= "Prezzo";
		["UiPricePerHeader"]	= "Prezzo per";
		["UiPurchases"]	= "Compere";
		["UiQuantityHeader"]	= "Q.tà";
		["UiSales"]	= "Vendite";
		["UiSearch"]	= "Ricerca";
		["UiSearchForLabel"]	= "Cerca per:";
		["UiSellTransaction"]	= "Vendi";
		["UiTransactions"]	= "Transazioni";
		["UiTransactionsLabel"]	= "Transazioni:";
		["UiTransactionTypeHeader"]	= "Tipo";

	};

	koKR = {

		-- Section: Config Text
		["C_BeanCounterConfig"]	= "콩순이 설정";
		["C_BeanCounterOptions"]	= "콩순이 옵션";
		["C_DateString"]	= "|CCFFFCC00 사용할 날짜 형식: ";
		["C_DateStringExample"]	= "|CCFFFCC00 날짜 예제: ";
		["C_ExtenalSearch"]	= "외부 애드온이 콩순이 검색을 사용하도록 허락합니까?";
		["C_MailInvoiceTimeout"]	= "우편 송장 타임아웃 = %d 초";
		["C_MailRecolor"]	= "우편에 다시 색입히는 방법";

		-- Section: Generic Strings
		["NoRe-Color"]	= "다시 색을 입히지 않음";
		["off"]	= "끄기";
		["on"]	= "켜기";
		["Re-ColorIcons"]	= "아이콘에 다시 색입히기";
		["Re-ColorIconsandText"]	= "아이콘과 글자에 다시 색입히기";
		["Re-ColorText"]	= "글씨에 다시 색입히기";

		-- Section: Help Text
		["A_DateString"]	= "콩순이의 GUI창에 보이는 날짜의 형식을 결정합니다.\n명령어 앞에 %를 붙여야 하고, 복수의 명령어와 글씨가 혼합될 수 있습니다.\n예를 들어 %a == %X라고 하면 수요일 == 21:34:21로 표시됩니다.";
		["A_DateStringCommands"]	= "명령어 : \n %a = 요일 약자, \n %A = 요일, \n %b = 월 약자, \n %B = 월,\n %c = 날짜와 시간, \n %d = 일(01-31일),\n %H = 시간 (24시간제), \n %I = 시간(12시간제),\n %M = 분, \n %m = 월(숫자),\n %p = a ";
		["A_ExtenalSearch"]	= "다른 애드온이 콩순이를 이용해 아이템을 검색하여 콩순이 GUI에 보이도록 할 수 있습니다. 예를 들면 Appraiser에서 보고있는 아이템이 무엇인지 콩순이가 보여주도록 합니다.";
		["A_MailInvoiceTimeout"]	= "송장 요청에 서버가 반응하기를 기다리는 시간입니다. 송장이란 경매장에서 온 우편의 누구, 무엇, 어떻게 부분입니다.";
		["A_MailRecolor"]	= "콩순이는 경매장에서 온 모든 우편을 읽습니다. 이 옵션은 우편을 안 읽은 것처럼 다시 색을 입힐지를 결정합니다.";
		["HelpGuiItemBox"]	= "아이템을 검색창에 떨굽니다.";
		["Q_DateString"]	= "사용할 날짜 형식이란?";
		["Q_DateStringCommands"]	= "알맞는 날짜 명령어란?";
		["Q_ExtenalSearch"]	= "외부 애드온의 콩순이 사용이란?";
		["Q_MailInvoiceTimeout"]	= "우편 송장 타임아웃이란?";
		["Q_MailRecolor"]	= "다시 색입히기란?";

		-- Section: Mail
		["MailAllianceAuctionHouse"]	= "얼라이언스 경매장";
		["MailAuctionCancelledSubject"]	= "경매 취소";
		["MailAuctionExpiredSubject"]	= "경매 만료";
		["MailAuctionSuccessfulSubject"]	= "경매 완료";
		["MailAuctionWonSubject"]	= "경매 낙찰";
		["MailHordeAuctionHouse"]	= "호드 경매장";
		["MailOutbidOnSubject"]	= "보다 높은 가격이 제시됨";
		["MailSalePendingOnSubject"]	= "판매 예정";

		-- Section: Tooltip Messages
		["TTDateString"]	= "날짜 부분에 보일 형식을 넣습니다. 기본값은 %c입니다.";
		["TTDateStringExample"]	= "설정된 날짜 형식의 예제를 보여줍니다.";
		["TTExtenalSearch"]	= "다른 애드온에서 검색을 하면, 콩순이도 그 아이템에 대한 검색결과를 보여줍니다.";
		["TTMailInvoiceTimeout"]	= "서버로부터 우편 송장을 얻기 위해 몇번이나 시도할지를 정합니다. 값을 낮추면 빠르지만 데이터가 빠져있을 확률이 있고, 값을 높이면 느리지만 우편 서버가 극히 바쁠경우 데이터를 가져올 확률을 높입니다.";
		["TTMailRecolor"]	= "콩순이가 우편함을 검색한 다음에 우편이 어떻게 보일지를 결정합니다.";

		-- Section: User Interface
		["UiAddonTitle"]	= "콩순이: 경매결과 데이터베이스";
		["UiAucExpired"]	= "경매 만료";
		["UiAucSuccessful"]	= "경매 완료";
		["UiAuctions"]	= "경매품";
		["UiAuctionTransaction"]	= "경매";
		["UiBids"]	= "입찰품";
		["UiBidTransaction"]	= "입찰";
		["UiBuyerSellerHeader"]	= "구매자/판매자";
		["UiBuyTransaction"]	= "구입";
		["UiClassicCheckBox"]	= "불타는 성전의 옛 데이터 표시";
		["UiData"]	= "데이터";
		["UiDateHeader"]	= "날짜";
		["UiDepositTransaction"]	= "보증금";
		["UiDone"]	= "완료";
		["UiExactNameSearch"]	= "정확한 이름 찾기";
		["UiFailedAuctions"]	= "실패한 경매";
		["UiFee"]	= "수수료";
		["UiNameHeader"]	= "아이템";
		["UiNetHeader"]	= "항목";
		["UiNetPerHeader"]	= "항목내용";
		["UiOutbid"]	= "상회 입찰";
		["UiOutbids"]	= "상회 입찰";
		["UiPriceHeader"]	= "가격";
		["UiPriceper"]	= "개당 가격";
		["UiPricePerHeader"]	= "가격 항목";
		["UiPurchases"]	= "구입";
		["UiQuantityHeader"]	= "수량";
		["UiSales"]	= "판매";
		["UiSearch"]	= "검색";
		["UiSearchForLabel"]	= "검색:";
		["UiSellTransaction"]	= "판매";
		["UiServer"]	= "서버";
		["UiTransactions"]	= "거래";
		["UiTransactionsLabel"]	= "거래:";
		["UiTransactionTypeHeader"]	= "형식";
		["UiWealth"]	= "재산";
		["UiWononBid"]	= "구입";
		["UiWononBuyout"]	= "즉시 구입";

	};

	nlNL = {

		-- Section: Mail
		["MailAllianceAuctionHouse"]	= "Alliance Auction House";
		["MailAuctionCancelledSubject"]	= "Auction cancelled";
		["MailAuctionExpiredSubject"]	= "Auction expired";
		["MailAuctionSuccessfulSubject"]	= "Auction successful";
		["MailAuctionWonSubject"]	= "Auction won";
		["MailHordeAuctionHouse"]	= "Horde Auction House";
		["MailOutbidOnSubject"]	= "Outbid on";

		-- Section: User Interface
		["UiAuctions"]	= "Veilingen";
		["UiAuctionTransaction"]	= "Veiling";
		["UiBids"]	= "Biedingen";
		["UiBidTransaction"]	= "Bod";
		["UiBuyerSellerHeader"]	= "Koper/Verkoper";
		["UiBuyTransaction"]	= "Koop";
		["UiDateHeader"]	= "Datum";
		["UiDepositTransaction"]	= "Storting";
		["UiExactNameSearch"]	= "Zoek op exacte naam";
		["UiNameHeader"]	= "Item";
		["UiNetHeader"]	= "Net";
		["UiNetPerHeader"]	= "Net Per";
		["UiPriceHeader"]	= "Prijs";
		["UiPricePerHeader"]	= "Stuksprijs";
		["UiPurchases"]	= "Aankopen";
		["UiQuantityHeader"]	= "Hoev.";
		["UiSales"]	= "Verkopen";
		["UiSearch"]	= "Zoek";
		["UiSearchForLabel"]	= "Zoek naar:";
		["UiSellTransaction"]	= "Verkoop";
		["UiTransactions"]	= "Transacties";
		["UiTransactionsLabel"]	= "Transacties:";
		["UiTransactionTypeHeader"]	= "Type";

	};

	ptPT = {

		-- Section: Mail
		["MailAllianceAuctionHouse"]	= "Leilão da Alliance";
		["MailAuctionCancelledSubject"]	= "Leilão Cancelado";
		["MailAuctionExpiredSubject"]	= "Leilão Expirou";
		["MailAuctionSuccessfulSubject"]	= "Leilão Bem Sucedido";
		["MailAuctionWonSubject"]	= "Leilão Ganho";
		["MailHordeAuctionHouse"]	= "Leilão da Horde";
		["MailOutbidOnSubject"]	= "Sobrebidado em";

		-- Section: User Interface
		["UiAuctions"]	= "Leilões";
		["UiAuctionTransaction"]	= "Leilão";
		["UiBids"]	= "Ofertas";
		["UiBidTransaction"]	= "Oferta";
		["UiBuyerSellerHeader"]	= "Comprador/Vendedor";
		["UiBuyTransaction"]	= "Compra";
		["UiDateHeader"]	= "Data";
		["UiDepositTransaction"]	= "Depósito";
		["UiExactNameSearch"]	= "Procura por nome exacto";
		["UiNameHeader"]	= "Objecto";
		["UiNetHeader"]	= "Rede";
		["UiNetPerHeader"]	= "Rede por";
		["UiPriceHeader"]	= "Preço";
		["UiPricePerHeader"]	= "Cabeçalho de Preço";
		["UiPurchases"]	= "Compras";
		["UiQuantityHeader"]	= "Qtn";
		["UiSales"]	= "Vendas";
		["UiSearch"]	= "Procura";
		["UiSearchForLabel"]	= "Procurar por:";
		["UiSellTransaction"]	= "Vender";
		["UiTransactions"]	= "Transacções";
		["UiTransactionsLabel"]	= "Transacções";
		["UiTransactionTypeHeader"]	= "Tipo";

	};

	ruRU = {

		-- Section: Mail
		["MailHordeAuctionHouse"]	= "Аукцион Орды";

		-- Section: User Interface
		["UiAuctions"]	= "Аукционы";
		["UiAuctionTransaction"]	= "Аукцион";
		["UiBids"]	= "Ставки";
		["UiBidTransaction"]	= "Ставка";
		["UiBuyerSellerHeader"]	= "Покупатель/Продавец";
		["UiBuyTransaction"]	= "Купить";
		["UiDateHeader"]	= "Дата";
		["UiDepositTransaction"]	= "Депозит";
		["UiExactNameSearch"]	= "Поиск точного имени";
		["UiNameHeader"]	= "Предмет";
		["UiNetHeader"]	= "Net";
		["UiNetPerHeader"]	= "Net за";
		["UiPriceHeader"]	= "Цена";
		["UiPricePerHeader"]	= "Цена Заголовка";
		["UiPurchases"]	= "Покупок";
		["UiQuantityHeader"]	= "Кол-во";
		["UiSales"]	= "Продажи";
		["UiSearch"]	= "Поиск";
		["UiSearchForLabel"]	= "Поиск:";
		["UiSellTransaction"]	= "Продажа";
		["UiTransactions"]	= "Переводы";
		["UiTransactionsLabel"]	= "Переводы:";
		["UiTransactionTypeHeader"]	= "Тип";

	};

	zhCN = {

		-- Section: Mail
		["MailAllianceAuctionHouse"]	= "联盟拍卖行";
		["MailAuctionCancelledSubject"]	= "拍卖取消";
		["MailAuctionExpiredSubject"]	= "拍卖已到期";
		["MailAuctionSuccessfulSubject"]	= "拍卖成功";
		["MailAuctionWonSubject"]	= "竞拍获胜";
		["MailHordeAuctionHouse"]	= "部落拍卖行";
		["MailOutbidOnSubject"]	= "出价被压过";

		-- Section: User Interface
		["UiAuctions"]	= "拍卖";
		["UiAuctionTransaction"]	= "拍卖";
		["UiBids"]	= "出价";
		["UiBidTransaction"]	= "竞标";
		["UiBuyerSellerHeader"]	= "买主/卖主";
		["UiBuyTransaction"]	= "购买";
		["UiDateHeader"]	= "日期";
		["UiDepositTransaction"]	= "保管费";
		["UiExactNameSearch"]	= "确切名字搜索";
		["UiNameHeader"]	= "物品";
		["UiNetHeader"]	= "净利";
		["UiNetPerHeader"]	= "单件净利";
		["UiPriceHeader"]	= "价格";
		["UiPricePerHeader"]	= "单件价格";
		["UiPurchases"]	= "购买";
		["UiQuantityHeader"]	= "数量";
		["UiSales"]	= "销售";
		["UiSearch"]	= "搜索";
		["UiSearchForLabel"]	= "搜索";
		["UiSellTransaction"]	= "出售";
		["UiTransactions"]	= "交易";
		["UiTransactionsLabel"]	= "交易";
		["UiTransactionTypeHeader"]	= "类型";

	};

	zhTW = {

		-- Section: Mail
		["MailAllianceAuctionHouse"]	= "聯盟拍賣場";
		["MailAuctionCancelledSubject"]	= "拍賣已取消";
		["MailAuctionExpiredSubject"]	= "拍賣過期";
		["MailAuctionSuccessfulSubject"]	= "拍賣成功";
		["MailAuctionWonSubject"]	= "得標";
		["MailHordeAuctionHouse"]	= "部落拍賣場";
		["MailOutbidOnSubject"]	= "出價失敗";

		-- Section: User Interface
		["UiAuctions"]	= "拍賣場";
		["UiAuctionTransaction"]	= "拍賣";
		["UiBids"]	= "出價";
		["UiBidTransaction"]	= "出價";
		["UiBuyerSellerHeader"]	= "買方/賣方";
		["UiBuyTransaction"]	= "買";
		["UiDateHeader"]	= "日期";
		["UiDepositTransaction"]	= "保管費";
		["UiExactNameSearch"]	= "完整名稱比對";
		["UiNameHeader"]	= "物品";
		["UiNetHeader"]	= "淨利";
		["UiNetPerHeader"]	= "單件淨利";
		["UiPriceHeader"]	= "價格";
		["UiPricePerHeader"]	= "價格標題";
		["UiPurchases"]	= "購買";
		["UiQuantityHeader"]	= "數量";
		["UiSales"]	= "銷售";
		["UiSearch"]	= "搜尋";
		["UiSearchForLabel"]	= "搜尋";
		["UiSellTransaction"]	= "出售";
		["UiTransactions"]	= "交易";
		["UiTransactionsLabel"]	= "交易";
		["UiTransactionTypeHeader"]	= "類別";

	};

}