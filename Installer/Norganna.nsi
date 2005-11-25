;NSIS Install script for Norganna's AddOns
;Written by MentalPower

;--------------------------------
;Set Compression Standard

	SetCompressor /SOLID /FINAL lzma

;--------------------------------
;Include Modern UI and Section Handling

	!include "MUI.nsh"
	!include "Sections.nsh"

;--------------------------------
;General

	;Name and file
	Name "Auctioneer AddOns"
	OutFile "Auctioneer.exe"

	;Default installation folder
	InstallDir "$PROGRAMFILES\World of Warcraft"

	;Get installation folder from registry if available
	InstallDirRegKey HKLM "SOFTWARE\Blizzard Entertainment\World of Warcraft" "InstallPath"

;--------------------------------
;Interface Configuration

	!define MUI_HEADERIMAGE
	!define MUI_HEADERIMAGE_BITMAP "Header.bmp"
	!define MUI_ICON "Install.ico"
	!define MUI_UNICON "UnInstall.ico"
	!define MUI_WELCOMEFINISHPAGE_BITMAP "Welcome.bmp"
	!define MUI_ABORTWARNING

;--------------------------------
;Pages

	!insertmacro MUI_PAGE_INIT
	!insertmacro MUI_PAGE_WELCOME
	!insertmacro MUI_PAGE_LICENSE $(MUILicense)
	!insertmacro MUI_PAGE_DIRECTORY
	!insertmacro MUI_PAGE_COMPONENTS
	!insertmacro MUI_PAGE_INSTFILES
	!insertmacro MUI_PAGE_FINISH

	!insertmacro MUI_UNPAGE_CONFIRM
	!insertmacro MUI_UNPAGE_COMPONENTS
	!insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
;Languages
 
	!insertmacro MUI_LANGUAGE "English"
	!insertmacro MUI_LANGUAGE "German"
	!insertmacro MUI_LANGUAGE "French"
	!insertmacro MUI_LANGUAGE "Korean"
	!insertmacro MUI_LANGUAGE "SimpChinese"
	!insertmacro MUI_LANGUAGE "TradChinese"
	!insertmacro MUI_LANGUAGE "Spanish"
	!insertmacro MUI_LANGUAGE "Danish"
	!insertmacro MUI_LANGUAGE "Italian"
	!insertmacro MUI_LANGUAGE "Turkish"
	!insertmacro MUI_LANGUAGE "Czech"
	!insertmacro MUI_LANGUAGE "Portuguese"
	!insertmacro MUI_LANGUAGE "PortugueseBR"

;--------------------------------
;License Language String

	LicenseLangString MUILicense ${LANG_ENGLISH} GPL.txt
	LicenseLangString MUILicense ${LANG_GERMAN} "Licenses\German GPL.txt"
	LicenseLangString MUILicense ${LANG_FRENCH} "Licenses\French GPL.txt"
	LicenseLangString MUILicense ${LANG_KOREAN} "Licenses\Korean GPL.txt"
	LicenseLangString MUILicense ${LANG_SIMPCHINESE} "Licenses\Chinese Simplified GPL.txt"
	LicenseLangString MUILicense ${LANG_TRADCHINESE} "Licenses\Chinese Traditional GPL.txt"
	LicenseLangString MUILicense ${LANG_SPANISH} "Licenses\Spanish GPL.txt"
	LicenseLangString MUILicense ${LANG_DANISH} "Licenses\Danish GPL.txt"
	LicenseLangString MUILicense ${LANG_ITALIAN} "Licenses\Italian GPL.txt"
	LicenseLangString MUILicense ${LANG_TURKISH} "Licenses\Turkish GPL.txt"
	LicenseLangString MUILicense ${LANG_CZECH} "Licenses\Czech GPL.txt"
	LicenseLangString MUILicense ${LANG_PORTUGUESE} "Licenses\Portuguese GPL.txt"
	LicenseLangString MUILicense ${LANG_PORTUGUESEBR} "Licenses\PortugueseBR GPL.txt"

;--------------------------------
;Reserve Files

	;These files should be inserted before other files in the data block
	;Keep these lines before any File command
	;Only for solid compression (by default, solid compression is enabled for BZIP2 and LZMA)

	!insertmacro MUI_RESERVEFILE_LANGDLL

;--------------------------------
;Installer Sections
;@TODO: Add descriptions to the different sections and also make those descriptions localizable.

InstType "Full"
InstType "Auctioneer Only"
InstType "Libraries Only"

Section "!Libraries" Libraries

SectionIn 1 2 3 RO

;EnhTT

	SetOutPath "$INSTDIR\Interface\AddOns\EnhTooltip"
	File "..\EnhTooltip\EnhTooltip.toc"
	File "..\EnhTooltip\*.xml"
	File "..\EnhTooltip\*.lua"
	File "GPL.txt"
	File "nopatch"

;Create uninstaller
	WriteUninstaller "$INSTDIR\Auctioneer Uninstaller.exe"

;Stubby

	SetOutPath "$INSTDIR\Interface\AddOns\Stubby"
	File "..\Stubby\Stubby.toc"
	File "..\Stubby\*.xml"
	File "..\Stubby\*.lua"
	File "GPL.txt"
	File "nopatch"

;Add our information to the Windows Add/Remove Control Panel

	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Auctioneer" "DisplayName" "Auctioneer AddOns"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Auctioneer" "UninstallString" "$INSTDIR\Auctioneer Uninstaller.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Auctioneer" "InstallLocation" "$INSTDIR\Interface\AddOns\"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Auctioneer" "Publisher" "Norganna"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Auctioneer" "HelpLink" "www.norganna.org"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Auctioneer" "URLUpdateInfo" "www.norganna.org"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Auctioneer" "URLInfoAbout" "www.norganna.org"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Auctioneer" "DisplayVersion" "<%version%>"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Auctioneer" "VersionMajor" 3

	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Auctioneer" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Auctioneer" "NoRepair" 1

SectionEnd

Section "Auctioneer" Auctioneer

	SectionIn 1 2

	SetOutPath "$INSTDIR\Interface\AddOns\Auctioneer"
	File "..\Auctioneer\Auctioneer.toc"
	File "..\Auctioneer\*.xml"
	File "..\Auctioneer\*.lua"
	File "..\Auctioneer\Readme.txt"
	File "GPL.txt"
	File "nopatch"

SectionEnd

Section "Enchantrix" Enchantrix

	SectionIn 1

	SetOutPath "$INSTDIR\Interface\AddOns\Enchantrix"
	File "..\Enchantrix\Enchantrix.toc"
	File "..\Enchantrix\*.xml"
	File "..\Enchantrix\*.lua"
	File "..\Enchantrix\Readme.txt"
	File "GPL.txt"
	File "nopatch"

SectionEnd

Section "Informant" Informant

	SectionIn 1

	SetOutPath "$INSTDIR\Interface\AddOns\Informant"
	File "..\Informant\Informant.toc"
	File "..\Informant\*.xml"
	File "..\Informant\*.lua"
	File "GPL.txt"
	File "nopatch"

SectionEnd

;--------------------------------
;Installer Functions

Function .onInit

	!insertmacro MUI_LANGDLL_DISPLAY

FunctionEnd

;--------------------------------
;Descriptions

	;Language strings

	;English
	LangString DESC_Libraries ${LANG_ENGLISH} "This will install Stubby and Enhanced Tooltips. $\n$\nThese are required for the other AddOns to work."
	LangString DESC_Auctioneer ${LANG_ENGLISH} "This will install Auctioneer. $\n$\nThis AddOn scans and analyzes the World of Warcraft Auction House and gives item price recomendations."
	LangString DESC_Enchantrix ${LANG_ENGLISH} "This will install Enchantrix. $\n$\nThis AddOn attempts to predict what components an item will disenchant into."
	LangString DESC_Informant ${LANG_ENGLISH} "This will install Informant. $\n$\nThis AddOn gives detailed information on the properties and uses of an item."

	;German
	LangString DESC_Libraries ${LANG_GERMAN} "Dieses Programm installiert Stubby und Enhanced Tooltips. $\n$\nDiese werden für die Funktion der anderen AddOns benötigt."
	LangString DESC_Auctioneer ${LANG_GERMAN} "Dieses Programm installiert Auctioneer. $\n$\nDieses Addon durchsucht die verschiedenen Auktionshäuser von World of Warcraft, um die Preise für Gegenstände zu analysieren und mit diesen Daten Preisempfehlungen zu geben."
	LangString DESC_Enchantrix ${LANG_GERMAN} "Dieses Programm installiert Enchantrix. $\n$\nDieses AddOn versucht zu bestimmen, welche Materialien beim entzaubern eines Gegenstands entstehen."
	LangString DESC_Informant ${LANG_GERMAN} "Dieses Programm installiert Informant. $\n$\nDieses Addon zeigt detaillierte Information über Eigenschaften und Verwendungen eines Gegenstands an."

	;French
	LangString DESC_Libraries ${LANG_FRENCH} "Ce programme va installer Stubby et Enhanced Tooltips. $\n$\nCes addOns sont nécessaires pour le bon fonctionnement des autres AddOns."
	LangString DESC_Auctioneer ${LANG_FRENCH} "Ce programme va installer Auctioneer. $\n$\nCette AddOn scan et analyse les enchères de l'hotel des ventes et donne des recommandations de prix."
	LangString DESC_Enchantrix ${LANG_FRENCH} "Ce programme va installer Enchantrix. $\n$\nCette AddOn tente de prédire quels composants vont être obtenus par le désenchantement d'un objet."
	LangString DESC_Informant ${LANG_FRENCH} "Ce programme va installer Informant. $\n$\nCette AddOn donne des informations detaillée sur les propriétées et l'utilisation d'un objet."

	;Korean
	LangString DESC_Libraries ${LANG_KOREAN} ""
	LangString DESC_Auctioneer ${LANG_KOREAN} ""
	LangString DESC_Enchantrix ${LANG_KOREAN} ""
	LangString DESC_Informant ${LANG_KOREAN} ""

	;Simplified Chinese
	LangString DESC_Libraries ${LANG_SIMPCHINESE} ""
	LangString DESC_Auctioneer ${LANG_SIMPCHINESE} "�?�将安装Auctioneer(�?�?�行助手)$\n$\n这个�?�件能扫�??和分�?魔兽世界里的�?�?�行，并给你价格上的建议。"
	LangString DESC_Enchantrix ${LANG_SIMPCHINESE} ""
	LangString DESC_Informant ${LANG_SIMPCHINESE} ""

	;Traditional Chinese
	LangString DESC_Libraries ${LANG_TRADCHINESE} ""
	LangString DESC_Auctioneer ${LANG_TRADCHINESE} "�?�将安装Auctioneer(�?�?�行助手)$\n$\n这个�?�件能扫�??和分�?魔兽世界里的�?�?�行，并给你价格上的建议。"
	LangString DESC_Enchantrix ${LANG_TRADCHINESE} ""
	LangString DESC_Informant ${LANG_TRADCHINESE} ""

	;Spanish
	LangString DESC_Libraries ${LANG_SPANISH} "Esto instalará Stubby y Enhanced Tooltips. $\n$\nEstos son necesarios para la operación de los otros AddOns."
	LangString DESC_Auctioneer ${LANG_SPANISH} "Esto instalará Auctioneer. $\n$\nEste AddOn explora y analiza la Casa de Subastas de World of Warcraft y da recomendaciones de precios de artículos."
	LangString DESC_Enchantrix ${LANG_SPANISH} "Esto instalará Enchantrix. $\n$\nEste AddOn trata de predecir el resultado de desencantar artículos."
	LangString DESC_Informant ${LANG_SPANISH} "	Esto instalará Informant. $\n$\nEste AddOn da información detallada de las propiedades y usos de los artículos."

	;Danish
	LangString DESC_Libraries ${LANG_DANISH} "Dette vil installere Stubby og Enhanced Tooltips. De er påkrævet for at få de andre AddOns til at virke."
	LangString DESC_Auctioneer ${LANG_DANISH} "Dette vil installere Auctioneer. Dette AddOn skanner og analysere auktionshusene i World of Warcraft og giver tips til varepriser."
	LangString DESC_Enchantrix ${LANG_DANISH} "Dette vil installere Enchantrix. Dette AddOn forsøger at forudsige hvilke komponenter et given item/genstand vil disenchante til."
	LangString DESC_Informant ${LANG_DANISH} "Dette vil installere Informant. Dette AddOn giver detaljerede informationer om de egenskaber og brugsmåder et item/genstand har."

	;Italian
	LangString DESC_Libraries ${LANG_ITALIAN} "Questo programma installerà Stubby e Enhanced Tooltips. $\n$\nQuesti componenti sono necessari per il funzionamento degli altri AddOn."
	LangString DESC_Auctioneer ${LANG_ITALIAN} "Questo programma installerà Auctioneer. $\n$\nQuesto AddOn scorre e analizza la Casa d'Aste di World of Warcraft e fornisce raccomandazioni sul prezzo degli articoli."
	LangString DESC_Enchantrix ${LANG_ITALIAN} "Questo programma installerà Enchatrix. $\n$\nQuesto AddOn prova a predìre i componenti nei quali un articolo sarà disincantato."
	LangString DESC_Informant ${LANG_ITALIAN} "Questo programma installerà Informant. $\n$\nQuesto AddOn fornisce informazioni dettagliate sulle proprietà e gli usi di un oggetto."

	;Turkish
	LangString DESC_Libraries ${LANG_TURKISH} "Bu Stubby ve Enhanced Tooltips i yükleyecektir. $\n$\nBunlar diger AddOn ların çalişması için gereklidir."
	LangString DESC_Auctioneer ${LANG_TURKISH} "Bu Auctıoneer i yükleyecektir. $\n$\nBu Addon the World of Warcraft Müzayede Evini tarar, analiz eder ve parça fiyatlandırması için tavsiyelerede bulunur."
	LangString DESC_Enchantrix ${LANG_TURKISH} "Bu Enchantrix i yükleyecektir. $\n$\nBu Addon bir parçanın disenchant yapılması halinde nelere donüşeceğini tahmin etmeye çalışır."
	LangString DESC_Informant ${LANG_TURKISH} "Bu Informant i yükleyecektir. $\n$\nBu Addon bir parçanın özellikleri hakkında detaylı bilgi ve kullanım bilgilerini verir."

	;Czech
	LangString DESC_Libraries ${LANG_CZECH} ""
	LangString DESC_Auctioneer ${LANG_CZECH} ""
	LangString DESC_Enchantrix ${LANG_CZECH} ""
	LangString DESC_Informant ${LANG_CZECH} ""

	;Portuguese
	LangString DESC_Libraries ${LANG_PORTUGUESE} ""
	LangString DESC_Auctioneer ${LANG_PORTUGUESE} ""
	LangString DESC_Enchantrix ${LANG_PORTUGUESE} ""
	LangString DESC_Informant ${LANG_PORTUGUESE} ""

	;Brazilian Portuguese
	LangString DESC_Libraries ${LANG_PORTUGUESEBR} ""
	LangString DESC_Auctioneer ${LANG_PORTUGUESEBR} ""
	LangString DESC_Enchantrix ${LANG_PORTUGUESEBR} ""
	LangString DESC_Informant ${LANG_PORTUGUESEBR} ""
	
	

	; Assign language strings to sections
	!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN

		!insertmacro MUI_DESCRIPTION_TEXT ${Libraries} $(DESC_Libraries)

		!insertmacro MUI_DESCRIPTION_TEXT ${Auctioneer} $(DESC_Auctioneer)

		!insertmacro MUI_DESCRIPTION_TEXT ${Enchantrix} $(DESC_Enchantrix)

		!insertmacro MUI_DESCRIPTION_TEXT ${Informant} $(DESC_Informant)

	!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

InstType "un.All"
InstType "un.AddOns"

Section "!un.Libraries" un.Libraries
;If this section is selected delete everything
;@TODO: Make it so it will ONLY delete the installed files instead of the entire folders.

	SectionIn 1

;EnhTT
	RMDir /r "$INSTDIR\Interface\AddOns\EnhTooltip"

;Stubby
	RMDir /r "$INSTDIR\Interface\AddOns\Stubby"

;Auctioneer
	RMDir /r "$INSTDIR\Interface\AddOns\Auctioneer"

;Enchantrix
	RMDir /r "$INSTDIR\Interface\AddOns\Enchantrix"

;Informant
	RMDir /r "$INSTDIR\Interface\AddOns\Informant"

;Un-Installer
	Delete "$INSTDIR\Auctioneer Uninstaller.exe"

	RMDir "$INSTDIR\Interface\AddOns"
	RMDir "$INSTDIR\Interface"
	RMDir "$INSTDIR"

	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Auctioneer"

SectionEnd

Section "un.Auctioneer" un.Auctioneer

	SectionIn 1 2

	RMDir /r "$INSTDIR\Interface\AddOns\Auctioneer"

	RMDir "$INSTDIR\Interface\AddOns"
	RMDir "$INSTDIR\Interface"
	RMDir "$INSTDIR"

SectionEnd

Section "un.Enchantrix" un.Enchantrix

	SectionIn 1 2

	RMDir /r "$INSTDIR\Interface\AddOns\Enchantrix"

	RMDir "$INSTDIR\Interface\AddOns"
	RMDir "$INSTDIR\Interface"
	RMDir "$INSTDIR"

SectionEnd

Section "un.Informant" un.Informant

	SectionIn 1 2

	RMDir /r "$INSTDIR\Interface\AddOns\Informant"

	RMDir "$INSTDIR\Interface\AddOns"
	RMDir "$INSTDIR\Interface"
	RMDir "$INSTDIR"

SectionEnd

;--------------------------------
;UnInstaller Functions

Function un.onInit

	!insertmacro MUI_LANGDLL_DISPLAY

FunctionEnd