;NSIS Modern User Interface
;Header Bitmap Example Script
;Written by Joost Verburg

;--------------------------------
;Include Modern UI

	!include "MUI.nsh"

;--------------------------------
;General

	;Name and file
	Name "Norganna's AddOns"
	OutFile "Norganna.exe"

	;Default installation folder
	InstallDir "$PROGRAMFILES\World of Warcraft"

	;Get installation folder from registry if available
	InstallDirRegKey HKLM "SOFTWARE\Blizzard Entertainment\World of Warcraft" "InstallPath"

;--------------------------------
;Interface Configuration

	!define MUI_HEADERIMAGE
	!define MUI_HEADERIMAGE_BITMAP "Header.bmp" ; optional
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
	!insertmacro MUI_LANGUAGE "Spanish"
	!insertmacro MUI_LANGUAGE "French"
	!insertmacro MUI_LANGUAGE "German"
	!insertmacro MUI_LANGUAGE "Italian"
	!insertmacro MUI_LANGUAGE "Danish"
	!insertmacro MUI_LANGUAGE "SimpChinese"
	!insertmacro MUI_LANGUAGE "TradChinese"
	!insertmacro MUI_LANGUAGE "Korean"

;--------------------------------
;License Language String

	LicenseLangString MUILicense ${LANG_ENGLISH} GPL.txt
	LicenseLangString MUILicense ${LANG_FRENCH} GPL.txt
	LicenseLangString MUILicense ${LANG_GERMAN} GPL.txt
	LicenseLangString MUILicense ${LANG_SPANISH} GPL.txt
	LicenseLangString MUILicense ${LANG_SIMPCHINESE} GPL.txt
	LicenseLangString MUILicense ${LANG_TRADCHINESE} GPL.txt
	LicenseLangString MUILicense ${LANG_KOREAN} GPL.txt
	LicenseLangString MUILicense ${LANG_ITALIAN} GPL.txt
	LicenseLangString MUILicense ${LANG_DANISH} GPL.txt

;--------------------------------
;Reserve Files

	;These files should be inserted before other files in the data block
	;Keep these lines before any File command
	;Only for solid compression (by default, solid compression is enabled for BZIP2 and LZMA)

	!insertmacro MUI_RESERVEFILE_LANGDLL

;--------------------------------
;Installer Sections

Section "Libraries"

SectionIn RO

;EnhTT
;AddSize 96

	SetOutPath "$INSTDIR\Interface\AddOns\EnhTooltip"
	File "..\EnhTooltip\EnhTooltip.toc"
	File "..\EnhTooltip\*.xml"
	File "..\EnhTooltip\*.lua"
	File "GPL.txt"
	File "nopatch"

	;Create uninstaller
	WriteUninstaller "$INSTDIR\Norganna's Uninstaller.exe"

;Stubby
;AddSize 47

	SetOutPath "$INSTDIR\Interface\AddOns\Stubby"
	File "..\Stubby\Stubby.toc"
	File "..\Stubby\*.xml"
	File "..\Stubby\*.lua"
	File "GPL.txt"
	File "nopatch"

SectionEnd

Section "Auctioneer"

;AddSize 337

	SetOutPath "$INSTDIR\Interface\AddOns\Auctioneer"
	File "..\Auctioneer\Auctioneer.toc"
	File "..\Auctioneer\*.xml"
	File "..\Auctioneer\*.lua"
	File "..\Auctioneer\Readme.txt"
	File "GPL.txt"
	File "nopatch"

SectionEnd

Section "Enchantrix"

;AddSize 737

	SetOutPath "$INSTDIR\Interface\AddOns\Enchantrix"
	File "..\Enchantrix\Enchantrix.toc"
	File "..\Enchantrix\*.xml"
	File "..\Enchantrix\*.lua"
	File "..\Enchantrix\Readme.txt"
	File "GPL.txt"
	File "nopatch"

SectionEnd

Section "Informant"

;AddSize 853

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
	LangString DESC_SecDummy ${LANG_ENGLISH} "A test section."

	;Assign language strings to sections
	!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
		!insertmacro MUI_DESCRIPTION_TEXT ${SecDummy} $(DESC_SecDummy)
	!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "un.Libraries"
;If this section is selected delete everything

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
	Delete "$INSTDIR\Norganna's Uninstaller.exe"

	RMDir "$INSTDIR\Interface\AddOns"
	RMDir "$INSTDIR\Interface"
	RMDir "$INSTDIR"
SectionEnd

Section "un.Auctioneer"

	RMDir /r "$INSTDIR\Interface\AddOns\Auctioneer"

	RMDir "$INSTDIR\Interface\AddOns"
	RMDir "$INSTDIR\Interface"
	RMDir "$INSTDIR"

SectionEnd

Section "un.Enchantrix"

	RMDir /r "$INSTDIR\Interface\AddOns\Enchantrix"

	RMDir "$INSTDIR\Interface\AddOns"
	RMDir "$INSTDIR\Interface"
	RMDir "$INSTDIR"

SectionEnd

Section "un.Informant"

	RMDir /r "$INSTDIR\Interface\AddOns\Informant"

	RMDir "$INSTDIR\Interface\AddOns"
	RMDir "$INSTDIR\Interface"
	RMDir "$INSTDIR"

SectionEnd