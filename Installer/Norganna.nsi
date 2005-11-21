;NSIS Install script for Norganna's AddOns
;Written by MentalPower

;--------------------------------
;Set Compression Standard

	SetCompressor /SOLID /FINAL lzma

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
	LicenseLangString MUILicense ${LANG_FRENCH} "Licenses\French GPL.txt"
	LicenseLangString MUILicense ${LANG_GERMAN} "Licenses\German GPL.txt"
	LicenseLangString MUILicense ${LANG_SPANISH} "Licenses\Spanish GPL.txt"
	LicenseLangString MUILicense ${LANG_SIMPCHINESE} "Licenses\Chinese Simplified GPL.txt"
	LicenseLangString MUILicense ${LANG_TRADCHINESE} "Licenses\Chinese Traditional GPL.txt"
	LicenseLangString MUILicense ${LANG_KOREAN} "Licenses\Korean GPL.txt"
	LicenseLangString MUILicense ${LANG_ITALIAN} "Licenses\Italian GPL.txt"
	LicenseLangString MUILicense ${LANG_DANISH} "Licenses\Danish GPL.txt"

;--------------------------------
;Reserve Files

	;These files should be inserted before other files in the data block
	;Keep these lines before any File command
	;Only for solid compression (by default, solid compression is enabled for BZIP2 and LZMA)

	!insertmacro MUI_RESERVEFILE_LANGDLL

;--------------------------------
;Installer Sections
;@TODO: Add Intalation Options like "Full", "Enchantrix", "AuctioneerOnly", etc.
;@TODO: Add descriptions to the different sections and also make those descriptions localizable.

Section "Libraries"

SectionIn RO

;EnhTT

	SetOutPath "$INSTDIR\Interface\AddOns\EnhTooltip"
	File "..\EnhTooltip\EnhTooltip.toc"
	File "..\EnhTooltip\*.xml"
	File "..\EnhTooltip\*.lua"
	File "GPL.txt"
	File "nopatch"

;Create uninstaller
	WriteUninstaller "$INSTDIR\Norganna's Uninstaller.exe"

;Stubby

	SetOutPath "$INSTDIR\Interface\AddOns\Stubby"
	File "..\Stubby\Stubby.toc"
	File "..\Stubby\*.xml"
	File "..\Stubby\*.lua"
	File "GPL.txt"
	File "nopatch"

;Add our information to the Windows Add/Remove Control Panel

	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Norganna" "DisplayName" "Norganna's AddOns"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Norganna" "UninstallString" "$INSTDIR\Norganna's Uninstaller.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Norganna" "InstallLocation" "$INSTDIR\Interface\AddOns\"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Norganna" "Publisher" "Norganna"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Norganna" "HelpLink" "www.norganna.org"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Norganna" "URLUpdateInfo" "www.norganna.org"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Norganna" "URLInfoAbout" "www.norganna.org"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Norganna" "DisplayVersion" "<%version%>"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Norganna" "VersionMajor" 3

	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Norganna" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Norganna" "NoRepair" 1

SectionEnd

Section "Auctioneer"

	SetOutPath "$INSTDIR\Interface\AddOns\Auctioneer"
	File "..\Auctioneer\Auctioneer.toc"
	File "..\Auctioneer\*.xml"
	File "..\Auctioneer\*.lua"
	File "..\Auctioneer\Readme.txt"
	File "GPL.txt"
	File "nopatch"

SectionEnd

Section "Enchantrix"

	SetOutPath "$INSTDIR\Interface\AddOns\Enchantrix"
	File "..\Enchantrix\Enchantrix.toc"
	File "..\Enchantrix\*.xml"
	File "..\Enchantrix\*.lua"
	File "..\Enchantrix\Readme.txt"
	File "GPL.txt"
	File "nopatch"

SectionEnd

Section "Informant"

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

	#Language strings
	; LangString DESC_SecDummy ${LANG_ENGLISH} "A test section."

	#Assign language strings to sections
	; !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
		; !insertmacro MUI_DESCRIPTION_TEXT ${SecDummy} $(DESC_SecDummy)
	; !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "un.Libraries"
;If this section is selected delete everything
;@TODO: Make it so it will ONLY delete the installed files instead of the entire folders.

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

	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Norganna"

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