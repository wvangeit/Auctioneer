local libName = "BeanCounter"
local libType = "Util"
local lib = AucAdvanced.Modules[libType][libName]
local private = lib.Private

local print = AucAdvanced.Print

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

		-- Section: Mail
		["MailAllianceAuctionHouse"]	= "Auktionshaus der Allianz";
		["MailAuctionCancelledSubject"]	= "Auktion abgebrochen";
		["MailAuctionExpiredSubject"]	= "Auktion abgelaufen";
		["MailAuctionSuccessfulSubject"]	= "Auktion erfolgreich";
		["MailAuctionWonSubject"]	= "Auktion gewonnen";
		["MailHordeAuctionHouse"]	= "Auktionshaus der Horde";
		["MailOutbidOnSubject"]	= "Höheres Gebot für";

		-- Section: User Interface
		["UiAuctions"]	= "Auktionen";
		["UiAuctionTransaction"]	= "Auktion";
		["UiBids"]	= "Gebote";
		["UiBidTransaction"]	= "Gebot";
		["UiBuyerSellerHeader"]	= "Käufer/Verkäufer";
		["UiBuyTransaction"]	= "Kaufen";
		["UiDateHeader"]	= "Datum";
		["UiDepositTransaction"]	= "Anzahlung";
		["UiExactNameSearch"]	= "Genaue Namenssuche";
		["UiNameHeader"]	= "Gegenstand";
		["UiNetHeader"]	= "Netz";
		["UiNetPerHeader"]	= "Netz pro";
		["UiPriceHeader"]	= "Preis";
		["UiPricePerHeader"]	= "Preisüberschrift";
		["UiPurchases"]	= "Einkäufe";
		["UiQuantityHeader"]	= "Anz";
		["UiSales"]	= "Verkäufe";
		["UiSearch"]	= "Suche";
		["UiSearchForLabel"]	= "Suche nach:";
		["UiSellTransaction"]	= "Verkaufen";
		["UiTransactions"]	= "Transaktionen";
		["UiTransactionsLabel"]	= "Transaktionen:";
		["UiTransactionTypeHeader"]	= "Typ";

	};

	enUS = {

		-- Section: Mail
		["MailAllianceAuctionHouse"]	= "Alliance Auction House";
		["MailAuctionCancelledSubject"]	= "Auction cancelled";
		["MailAuctionExpiredSubject"]	= "Auction expired";
		["MailAuctionSuccessfulSubject"]	= "Auction successful";
		["MailAuctionWonSubject"]	= "Auction won";
		["MailHordeAuctionHouse"]	= "Horde Auction House";
		["MailOutbidOnSubject"]	= "Outbid on";

		-- Section: User Interface
		["UiAuctions"]	= "Auctions";
		["UiAuctionTransaction"]	= "Auction";
		["UiBids"]	= "Bids";
		["UiBidTransaction"]	= "Bid";
		["UiBuyerSellerHeader"]	= "Buyer/Seller";
		["UiBuyTransaction"]	= "Buy";
		["UiDateHeader"]	= "Date";
		["UiDepositTransaction"]	= "Deposit";
		["UiExactNameSearch"]	= "Exact name search";
		["UiNameHeader"]	= "Item";
		["UiNetHeader"]	= "Net";
		["UiNetPerHeader"]	= "Net Per";
		["UiPriceHeader"]	= "Price";
		["UiPricePerHeader"]	= "Price Header";
		["UiPurchases"]	= "Purchases";
		["UiQuantityHeader"]	= "Qty";
		["UiSales"]	= "Sales";
		["UiSearch"]	= "Search";
		["UiSearchForLabel"]	= "Search for:";
		["UiSellTransaction"]	= "Sell";
		["UiTransactions"]	= "Transactions";
		["UiTransactionsLabel"]	= "Transactions:";
		["UiTransactionTypeHeader"]	= "Type";

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

		-- Section: Mail
		["MailAllianceAuctionHouse"]	= "Hôtel des ventes de l'Alliance";
		["MailAuctionCancelledSubject"]	= "Vente annulée ";
		["MailAuctionExpiredSubject"]	= "Vente aux enchères terminée ";
		["MailAuctionSuccessfulSubject"]	= "Vente aux enchères réussie ";
		["MailAuctionWonSubject"]	= "Vente gagnée ";
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

		-- Section: Mail
		["MailAllianceAuctionHouse"]	= "얼라이언스 경매장";
		["MailAuctionCancelledSubject"]	= "경매 취소";
		["MailAuctionExpiredSubject"]	= "경매 만료";
		["MailAuctionSuccessfulSubject"]	= "경매 완료";
		["MailAuctionWonSubject"]	= "경매 낙찰";
		["MailHordeAuctionHouse"]	= "호드 경매장";
		["MailOutbidOnSubject"]	= "보다 높은 가격이 제시됨";

		-- Section: User Interface
		["UiAuctions"]	= "경매품";
		["UiAuctionTransaction"]	= "경매";
		["UiBids"]	= "입찰품";
		["UiBidTransaction"]	= "입찰";
		["UiBuyerSellerHeader"]	= "구매자/판매자";
		["UiBuyTransaction"]	= "구입";
		["UiDateHeader"]	= "날짜";
		["UiDepositTransaction"]	= "보증금";
		["UiExactNameSearch"]	= "정확한 이름 찾기";
		["UiNameHeader"]	= "아이템";
		["UiNetHeader"]	= "항목";
		["UiNetPerHeader"]	= "항목내용";
		["UiPriceHeader"]	= "가격";
		["UiPricePerHeader"]	= "가격 항목";
		["UiPurchases"]	= "구입";
		["UiQuantityHeader"]	= "수량";
		["UiSales"]	= "판매";
		["UiSearch"]	= "검색";
		["UiSearchForLabel"]	= "검색:";
		["UiSellTransaction"]	= "판매";
		["UiTransactions"]	= "거래";
		["UiTransactionsLabel"]	= "거래:";
		["UiTransactionTypeHeader"]	= "형식";

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