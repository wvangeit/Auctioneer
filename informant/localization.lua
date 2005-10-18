--[[
	WARNING: This file is automatically generated from those in the
	locales directory. Do not edit it directly.


	$Id$
	Version: <%version%>
]]






-- ============= AUTOMATICALLY GENERATED FILE =============
-- ================= DON'T EDIT THIS FILE =================

-- ============= AUTOMATICALLY GENERATED FILE =============
-- ================= DON'T EDIT THIS FILE =================

-- ============= AUTOMATICALLY GENERATED FILE =============
-- ================= DON'T EDIT THIS FILE =================

-- ============= AUTOMATICALLY GENERATED FILE =============
-- ================= DON'T EDIT THIS FILE =================

-- ============= AUTOMATICALLY GENERATED FILE =============
-- ================= DON'T EDIT THIS FILE =================

-- ============= AUTOMATICALLY GENERATED FILE =============
-- ================= DON'T EDIT THIS FILE =================






_INFORMANT = {};

INFORMANT_VALID_LOCALES = {["deDE"] = true, ["enUS"] = true, ["esES"] = true, ["frFR"] = true};

function Informant_SetLocaleStrings(locale)
-- Default locale strings are defined in English
	
	
	BINDING_HEADER_INFORMANT_HEADER = "Informant"
	BINDING_NAME_INFORMANT_POPUPDOWN = "Toggle Information Window"
	
	_INFORMANT['Welcome'] = {
		"|c40ff50ffWelcome to Informant|r",
		"",
		"Since this is the first time you are using",
		"Informant, this message appears to let you",
		"know that you must set a key to show this",
		"window from within the |cffffffffKeybindings|r section",
		"of the |cffffffffGame Menu|r.",
		"",
		"From then on to view advanced information",
		"about items in your inventory, simply move",
		"your mouse over the item you want to see",
		"information about and press the key that",
		"you bound, and this window will popup,",
		"filled with information about that item.",
		"",
		"At that point, simply press the key again,",
		"or click the close button on this frame.",
		"",
		"Click the close button now to continue.",
	}
	
	_INFORMANT['AdditAlcohol'] = "Alcohol"
	_INFORMANT['AdditBuff'] = "Buff"
	_INFORMANT['AdditDrink'] = "Drink"
	_INFORMANT['AdditFirework'] = "Firework"
	_INFORMANT['AdditFood'] = "Food"
	_INFORMANT['AdditGiftwrap'] = "Giftwrap"
	_INFORMANT['AdditLure'] = "Lure"
	_INFORMANT['AdditPoison'] = "Poison"
	_INFORMANT['AdditPotion'] = "Potion"
	_INFORMANT['AdditRestorative'] = "Restorative"
	_INFORMANT['AdditScroll'] = "Scroll"
	
	_INFORMANT['SkillAlchemy'] = "Alchemy"
	_INFORMANT['SkillBlacksmithing'] = "Smithing"
	_INFORMANT['SkillCooking'] = "Cooking"
	_INFORMANT['SkillEnchanting'] = "Enchanting"
	_INFORMANT['SkillEngineering'] = "Engineering"
	_INFORMANT['SkillFirstAid'] = "First Aid"
	_INFORMANT['SkillLeatherworking'] = "Leatherworking"
	_INFORMANT['SkillMining'] = "Mining"
	_INFORMANT['SkillTailoring'] = "Tailoring"
	_INFORMANT['SkillDruid'] = "Druid spells"
	_INFORMANT['SkillMage'] = "Mage spells"
	_INFORMANT['SkillPaladin'] = "Paladin spells"
	_INFORMANT['SkillPriest'] = "Priest spells"
	_INFORMANT['SkillRogue'] = "Rogue skills"
	_INFORMANT['SkillShaman'] = "Shaman spells"
	_INFORMANT['SkillWarlock'] = "Warlock spells"
	
	_INFORMANT['FrmtWelcome'] = "Informant v%s loaded"
	_INFORMANT['FrameTitle'] = "Informant Item Information"
	
	_INFORMANT['FrmtInfoMerchants'] = "Sold by %d merchants"
	_INFORMANT['FrmtInfoQuest'] = "Quest item in %d quests"
	_INFORMANT['FrmtInfoClass'] = "Class: %s"
	_INFORMANT['FrmtInfoUse'] = "Used for: %s"
	_INFORMANT['FrmtInfoBuy'] = "Buy from vendor"
	_INFORMANT['FrmtInfoSell'] = "Sell to vendor"
	_INFORMANT['FrmtInfoBuymult'] = "Buy %d (%s each)"
	_INFORMANT['FrmtInfoSellmult'] = "Sell %d (%s each)"
	_INFORMANT['FrmtInfoStx'] = "Stacks in lots of %d"
	
	_INFORMANT['InfoHeader'] = "Information on |cff%s%s|r"
	
	_INFORMANT['InfoVendorHeader'] = "Available from %d merchants:"
	_INFORMANT['InfoVendorName'] = "  %s"
	
	_INFORMANT['InfoQuestHeader'] = "Used in %d quests:"
	_INFORMANT['InfoQuestName'] = "  %s"
	
	_INFORMANT['InfoPlayerMade'] = "Made by level %d %s"
	
	_INFORMANT['InfoNoItem'] = {
		"You must first move over an item,",
		"then press the activation key",
	}
	
	_INFORMANT['CmdOff'] = "off"
	_INFORMANT['CmdOn'] = "on"
	_INFORMANT['CmdToggle'] = "toggle"
	_INFORMANT['CmdDisable'] = "disable";
	_INFORMANT['CmdDefault'] = "default"
	_INFORMANT['CmdLocale'] = "locale"
	_INFORMANT['CmdEmbed'] = "embed"
	_INFORMANT['CmdClearAll'] = "all";
	
	_INFORMANT['OptLocale'] = "<locale>"
	
	_INFORMANT['ShowStack'] = "show-stack"
	_INFORMANT['ShowUsage'] = "show-usage"
	_INFORMANT['ShowQuest'] = "show-quest"
	_INFORMANT['ShowMerchant'] = "show-merchant"
	_INFORMANT['ShowVendor'] = "show-vendor"
	_INFORMANT['ShowVendorBuy'] = "show-vendor-buy"
	_INFORMANT['ShowVendorSell'] = "show-vendor-sell"
	
	_INFORMANT['HelpOnoff'] = "Turns the auction data display on and off"
	_INFORMANT['HelpDisable'] = "Stops informant from automatically loading next time you log in";
	_INFORMANT['HelpVendor'] = "Select whether to show item's vendor pricing"
	_INFORMANT['HelpVendorSell'] = "Select whether to show item's vendor sell pricing (req show-vendor=on)"
	_INFORMANT['HelpVendorBuy'] = "Select whether to show item's vendor buy pricing (req show-vendor=on)"
	_INFORMANT['HelpUsage'] = "Select whether to show tradeskill items' usage"
	_INFORMANT['HelpQuest'] = "Select whether to show quests items' usage"
	_INFORMANT['HelpMerchant'] = "Select whether to show merchants who supply items"
	_INFORMANT['HelpStack'] = "Select whether to show the item's stackable size"
	_INFORMANT['HelpEmbed'] = "Embed the text in the original game tooltip (note: certain features are disabled when this is selected)"
	_INFORMANT['HelpLocale'] = "Change the locale that is used to display informant messages"
	_INFORMANT['HelpEmbed'] = "Embed the text in the original game tooltip (note: certain features are disabled when this is selected)"
	_INFORMANT['HelpDefault'] = "Set an informant option to it's default value. You may also specify the special keyword \"all\" to set all informant options to their default values."
	
	_INFORMANT['MesgNotLoaded'] = "Informant is not loaded. Type /informant for more info.";
	
	_INFORMANT['FrmtActEnable'] = "Displaying item's %s data"
	_INFORMANT['FrmtActDisable'] = "Not displaying item's %s data"
	_INFORMANT['FrmtActEnabledOn'] = "Displaying item's %s on %s"
	_INFORMANT['FrmtActSet'] = "Set %s to '%s'"
	_INFORMANT['FrmtActUnknown'] = "Unknown command keyword: '%s'"
	_INFORMANT['FrmtActDefaultall'] = "All informant options have been reset to default settings."
	_INFORMANT['FrmtActDefault'] = "Informant's %s option has been reset to its default setting"
	_INFORMANT['FrmtUnknownLocale'] = "The locale you specified ('%s') is unknown. Valid locales are:";
	
	
	
	_INFORMANT['GuiMainHelp'] = "Contains settings for Informant \nan AddOn that displays detailed item information"
	_INFORMANT['GuiMainEnable'] = "Enable Informant"
	_INFORMANT['GuiLocale'] = "Set locale to"
	_INFORMANT['GuiVendorHeader'] = "Vendor Prices"
	_INFORMANT['GuiVendorHelp'] = "Options related to NPC buy/sell prices."
	_INFORMANT['GuiVendor'] = "Show Vendor Prices"
	_INFORMANT['GuiVendorBuy'] = "Show Vendor Buy Prices"
	_INFORMANT['GuiVendorSell'] = "Show Vendor Sell Prices"
	_INFORMANT['GuiInfoHeader'] = "Additional information"
	_INFORMANT['GuiInfoHelp'] = "Controls what additional information is shown in tooltips"
	_INFORMANT['GuiInfoStack'] = "Show stack sizes"
	_INFORMANT['GuiInfoUsage'] = "Show usage information"
	_INFORMANT['GuiInfoQuest'] = "Show quest information"
	_INFORMANT['GuiInfoMerchant'] = "Show merchants"
	_INFORMANT['GuiVendorSell'] = "Show Vendor Sell Prices"
	_INFORMANT['GuiEmbedHeader'] = "Embed"
	_INFORMANT['GuiEmbed'] = "Embed info in in-game tooltip"
	_INFORMANT['GuiOtherHeader'] = "Other Options"
	_INFORMANT['GuiOtherHelp'] = "Miscellaneous Informant Options"
	_INFORMANT['GuiReloadui'] = "Reload User Interface"
	_INFORMANT['GuiReloaduiHelp'] = "Click here to reload the WoW User Interface after changing the locale so that the language in this configuration screen matches the one you selected.\nNote: This operation may take a few minutes."
	_INFORMANT['GuiReloaduiButton'] = "ReloadUI"
	_INFORMANT['GuiReloaduiFeedback'] = "Now Reloading the WoW UI"
	_INFORMANT['GuiDefaultAllButton'] = "Reset All"
	_INFORMANT['GuiDefaultAll'] = "Reset All Informant Options"
	_INFORMANT['GuiDefaultAllHelp'] = "Click here to set all Informant options to their default values.\nWARNING: This action is NOT undoable."
	_INFORMANT['GuiDefaultOption'] = "Reset this setting"
	

-- Locale strings for the deDE locale
if locale == "deDE" then
		-- Encoded in UTF8
		
		_INFORMANT['AdditAlcohol']     = "Alkohol";
		_INFORMANT['AdditBuff']        = "Buff";
		_INFORMANT['AdditDrink']       = "Getr\195\164nk";
		_INFORMANT['AdditFirework']    = "Feuerwerk";
		_INFORMANT['AdditFood']        = "Nahrung";
		_INFORMANT['AdditGiftwrap']    = "Geschenkpapier";
		_INFORMANT['AdditLure']        = "K\195\182der";
		_INFORMANT['AdditPoison']      = "Gift";
		_INFORMANT['AdditPotion']      = "Trank";
		_INFORMANT['AdditRestorative'] = "St\195\164rkungstrank";
		_INFORMANT['AdditScroll']      = "Zauberspruchrolle";
		
		_INFORMANT['SkillAlchemy']        = "Alchimie";
		_INFORMANT['SkillBlacksmithing']  = "Schmieden";
		_INFORMANT['SkillCooking']        = "Kochen";
		_INFORMANT['SkillEnchanting']     = "Verzauberungen";
		_INFORMANT['SkillEngineering']    = "Ingenieurskunst";
		_INFORMANT['SkillFirstAid']       = "Erste Hilfe";
		_INFORMANT['SkillLeatherworking'] = "Lederverarbeitung";
		_INFORMANT['SkillMining']         = "Bergbau";
		_INFORMANT['SkillTailoring']      = "Schneiderei";
		_INFORMANT['SkillDruid']          = "Druidenzauber";
		_INFORMANT['SkillMage']           = "Magierzauber";
		_INFORMANT['SkillPaladin']        = "Paladinzauber";
		_INFORMANT['SkillPriest']         = "Priesterzauber";
		_INFORMANT['SkillRogue']          = "Diebeszubeh\195\182r";
		_INFORMANT['SkillShaman']         = "Schamanenzauber";
		_INFORMANT['SkillWarlock']        = "Hexerzauber";
		
		_INFORMANT['FrmtWelcome'] = "Informant v%s geladen";
		
		_INFORMANT['FrmtInfoClass']    = "Klasse: %s";
		_INFORMANT['FrmtInfoUse']      = "Benutzt f\195\188r: %s";
		_INFORMANT['FrmtInfoBuy']      = "Einkauf beim H\195\164ndler";
		_INFORMANT['FrmtInfoSell']     = "Verkauf beim H\195\164ndler";
		_INFORMANT['FrmtInfoBuymult']  = "Einkauf f\195\188r %d (%s pro St\195\188ck)";
		_INFORMANT['FrmtInfoSellmult'] = "Verkauf f\195\188r %d (%s pro St\195\188ck)";
		_INFORMANT['FrmtInfoStx']      = "%d pro Stapel";
		
		_INFORMANT['CmdOff']           = "off";
		_INFORMANT['CmdOn']            = "on";
		_INFORMANT['CmdToggle']        = "toggle";
		_INFORMANT['CmdDefault']       = "default";
		
		_INFORMANT['CmdEmbed']            = "embed";
		
		_INFORMANT['ShowStack']      = "show-stack";
		_INFORMANT['ShowUsage']      = "show-usage";
		_INFORMANT['ShowVendor']     = "show-vendor";
		_INFORMANT['ShowVendorBuy']  = "show-vendor-buy";
		_INFORMANT['ShowVendorSell'] = "show-vendor-sell";
		
		_INFORMANT['HelpOnoff']          = "Schaltet die Anzeige der Auktionsdaten ein/aus.";
		_INFORMANT['HelpVerbose']        = "Schaltet die detaillierte Anzeige der Durchschnittswerte und Preisempfehlungen ein/aus. Deaktivieren reduziert die Datenanzeige auf eine Zeile.";
		_INFORMANT['HelpVendor']         = "Schaltet die Anzeige des H\195\164ndlerpreieses ein/aus.";
		_INFORMANT['HelpVendorSell']     = "Schaltet die Anzeige des H\195\164ndlerverkaufspreises ein/aus (show-vendor muss eingeschaltet sein).";
		_INFORMANT['HelpVendorBuy']      = "Schaltet die Anzeige des H\195\164ndlerkaufspreises ein/aus (show-vendor muss eingeschaltet sein).";
		_INFORMANT['HelpUsage']          = "Schaltet die Anzeige des Verwendungszweckes f\195\188r Handwerker ein/aus.";
		_INFORMANT['HelpStack']          = "Schaltet die Anzeige der Stapelgr\195\182\195\159e ein/aus.";
		_INFORMANT['HelpEmbed']          = "Bindet den Auktionsinfotext in den WoW-Tooltip ein (Hinweis: Einige Funktionen sind in diesem Modus deaktiviert).";
		
		_INFORMANT['StatOn']  = "Auktionsdaten werden angezeigt.";
		_INFORMANT['StatOff'] = "Auktionsdaten werden nicht angezeigt.";
		
		_INFORMANT['FrmtActEnable']     = "%s wird angezeigt";
		_INFORMANT['FrmtActDisable']    = "%s wird nicht angezeigt";
		_INFORMANT['FrmtActEnabledOn']  = "Zeige %s auf %s";
		_INFORMANT['FrmtActSet']        = "Setze %s auf '%s'";
		_INFORMANT['FrmtActUnknown']    = "Unbekannter Befehl: '%s'";
		_INFORMANT['FrmtActDefaultall'] = "Alle Einstellungen wurden auf Standardwerte zur\195\188ckgesetzt.";
		_INFORMANT['FrmtActDefault']    = "%s wurde auf den Standardwert zur\195\188ckgesetzt.";
		
		
		-- GUI localizations
		
		_INFORMANT['GuiVendorHeader']     = "Zeige H\195\164ndlerpreise an.";
		_INFORMANT['GuiVendorHelp']       = "Einstellungen im Zusammenhang mit Verkaufs-/Einkaufspreise von NPCs.";
		_INFORMANT['GuiVendor']           = "Zeige H\195\164ndlerpreise an.";
		_INFORMANT['GuiVendorBuy']        = "Zeige H\195\164ndler-Einkaufspreise an";
		_INFORMANT['GuiVendorSell']       = "Zeige H\195\164ndler-Verkaufspreise an";


		-- The following definitions are missing in this locale:
		--	BINDING_HEADER_INFORMANT_HEADER = "";
		--	BINDING_NAME_INFORMANT_POPUPDOWN = "";
end

-- Locale strings for the esES locale
if locale == "esES" then
		-- Encoded in UTF8
		
		_INFORMANT['AdditAlcohol'] = "Alcohol";
		_INFORMANT['AdditBuff'] = "Mejora";
		_INFORMANT['AdditDrink'] = "Bebida";
		_INFORMANT['AdditFirework'] = "Fuegos Artificiales";
		_INFORMANT['AdditFood'] = "Comida";
		_INFORMANT['AdditGiftwrap'] = "Envoltura";
		_INFORMANT['AdditLure'] = "Se\195\177uelo";
		_INFORMANT['AdditPoison'] = "Veneno";
		_INFORMANT['AdditPotion'] = "Poci\195\179n";
		_INFORMANT['AdditRestorative'] = "Restaurativo";
		_INFORMANT['AdditScroll'] = "Voluta";
		
		_INFORMANT['SkillAlchemy'] = "Alqu\195\173mia";
		_INFORMANT['SkillBlacksmithing'] = "Herrer\195\173a";
		_INFORMANT['SkillCooking'] = "Cocinar";
		_INFORMANT['SkillEnchanting'] = "Encantar";
		_INFORMANT['SkillEngineering'] = "Ingenier\195\173a";
		_INFORMANT['SkillFirstAid'] = "Primeros Auxilios";
		_INFORMANT['SkillLeatherworking'] = "Peleter\195\173a";
		_INFORMANT['SkillMining'] = "Miner\195\173a";
		_INFORMANT['SkillTailoring'] = "Sastrer\195\173a";
		_INFORMANT['SkillDruid'] = "Encantos de Druidas";
		_INFORMANT['SkillMage'] = "Encantos de Magos";
		_INFORMANT['SkillPaladin'] = "Encantos de Paladines";
		_INFORMANT['SkillPriest'] = "Encantos de Sacerdotes";
		_INFORMANT['SkillRogue'] = "Encantos de P\195\173caros";
		_INFORMANT['SkillShaman'] = "Encantos de Chamanes";
		_INFORMANT['SkillWarlock'] = "Encantos de Brujos";
		
		
		_INFORMANT['FrmtWelcome'] = "Informant versi\195\179n %s cargado";
		
		
		_INFORMANT['FrmtInfoClass'] = "Clase: %s";
		_INFORMANT['FrmtInfoUse'] = "Usado para: %s";
		_INFORMANT['FrmtInfoBuy'] = "Compra del vendedor";
		_INFORMANT['FrmtInfoSell'] = "Vende al vendedor";
		_INFORMANT['FrmtInfoBuymult'] = "Compra %d (%s c/u)";
		_INFORMANT['FrmtInfoSellmult'] = "Vende %d (%s c/u)";
		_INFORMANT['FrmtInfoStx'] = "Amontonable en lotes de art\195\173culos %d por paquete";
		
		_INFORMANT['CmdOff'] = "apagado";
		_INFORMANT['CmdOn'] = "prendido";
		_INFORMANT['CmdToggle'] = "invertir";
		_INFORMANT['CmdDefault'] = "original";
		
		_INFORMANT['CmdEmbed'] = "integrado";
		
		
		
		
		
		_INFORMANT['ShowStack'] = "ver-paquete";
		_INFORMANT['ShowUsage'] = "ver-uso";
		_INFORMANT['ShowVendor'] = "ver-vendedor";
		_INFORMANT['ShowVendorBuy'] = "ver-vendedor-compra";
		_INFORMANT['ShowVendorSell'] = "ver-vendedor-venta";
		
		_INFORMANT['HelpOnoff'] = "Enciande o apaga la informacion sobre las subastas";
		_INFORMANT['HelpVerbose'] = "Selecciona para mostrar promedios literales (O apaga para que aparezcan en una sola linea)";
		_INFORMANT['HelpVendor'] = "Selecciona para mostrar precios de vendedor para el art\195\173culo";
		_INFORMANT['HelpVendorSell'] = "Selecciona para mostrar precio de venta del vendedor (requiere ver-vendedor prendido)";
		_INFORMANT['HelpVendorBuy'] = "Selecciona para mostrar precio de compra del vendedor (requiere ver-vendedor prendido)";
		_INFORMANT['HelpUsage'] = "Selecciona para mostrar uso del art\195\173culo en profesiones";
		_INFORMANT['HelpStack'] = "Selecciona para mostrar tama\195\177o maximo del paquete";
		_INFORMANT['HelpEmbedBlank'] = "Selecciona para mostrar una linea en blanco entre informacion de la caja de ayuda y la informacion de subasta cuando el modo integrado esta seleccionado";
		_INFORMANT['HelpEmbed'] = "Insertar el texto en la caja de ayuda original del juego (nota: Algunas funciones se desabilitan cuando esta opci\195\179n es seleccionada)";
		
		_INFORMANT['StatOn'] = "Mostrando la configuracion corriente para la informacion de subastas";
		_INFORMANT['StatOff'] = "Ocultando toda la informacion de subastas";
		
		_INFORMANT['FrmtActEnable'] = "Mostrando informacion del art\195\173culo: %s ";
		_INFORMANT['FrmtActDisable'] = "Ocultando informacion de articulo: %s ";
		_INFORMANT['FrmtActEnabledOn'] = "Mostrando %s de los art\195\173culos usando %s";
		_INFORMANT['FrmtActSet'] = "%s ajustado(a) a '%s'";
		_INFORMANT['FrmtActUnknown'] = "Comando o palabra clave desconocida: '%s'";
		_INFORMANT['FrmtActDefaultall'] = "Todas las opciones de Auctioneer han sido revertidas a sus configuraciones de f\195\161brica.";
		_INFORMANT['FrmtActDefault'] = "La opci\195\179n %s de Auctioneer ha sido revertida a su configuraci\195\179n de f\195\161brica.";
		
		
		-- AH Scanning localizations
		
		
		
		
		-- GUI localizations
		


		-- The following definitions are missing in this locale:
		--	BINDING_HEADER_INFORMANT_HEADER = "";
		--	BINDING_NAME_INFORMANT_POPUPDOWN = "";
end

-- Locale strings for the frFR locale
if locale == "frFR" then
		-- Encoded in UTF8
		_INFORMANT['AdditBuff']        = "Buff";
		_INFORMANT['AdditDrink']       = "Boisson";
		_INFORMANT['AdditFood']        = "Nourriture";
		_INFORMANT['AdditPoison']      = "Poison";
		_INFORMANT['AdditPotion']      = "Potion";
		
		_INFORMANT['SkillAlchemy']        = "Alchimie";
		_INFORMANT['SkillBlacksmithing']  = "Forgeron";
		_INFORMANT['SkillCooking']        = "Cuisine";
		_INFORMANT['SkillEnchanting']     = "Enchantement";
		_INFORMANT['SkillEngineering']    = "Ing\195\169nieur";
		_INFORMANT['SkillFirstAid']       = "Premiers Soins";
		_INFORMANT['SkillLeatherworking'] = "Travail du Cuir";
		_INFORMANT['SkillMining']         = "Minage";
		_INFORMANT['SkillTailoring']      = "Tailleur";
		
		_INFORMANT['FrmtInfoClass'] = "Classe: %s";
		_INFORMANT['FrmtInfoUse'] = "Utilis\195\169 pour: %s";
		_INFORMANT['FrmtInfoBuy'] = "Achat%s au marchand";
		_INFORMANT['FrmtInfoSell'] = "Vente%s au marchand";
		_INFORMANT['FrmtInfoBuymult'] = "Achat%s %d (%s chacun)";
		_INFORMANT['FrmtInfoSellmult'] = "Vente%s %d (%s chacun)";
		_INFORMANT['FrmtInfoStx'] = "Pile par lots de %d";
		
		-- AH Scanning localizations
		


		-- The following definitions are missing in this locale:
		--	BINDING_HEADER_INFORMANT_HEADER = "";
		--	BINDING_NAME_INFORMANT_POPUPDOWN = "";
end

end

Informant_SetLocaleStrings(GetLocale);

