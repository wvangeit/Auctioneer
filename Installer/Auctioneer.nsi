/*
	NSIS Install script for Norganna's Auctioneer AddOns
	Written by MentalPower

	Version: <%version%>
	Revision: $Id$
	
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
		along with this program(see GLP.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/
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
	OutFile "AuctioneerSetup.exe"

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
	!define WNDTITLE "World of Warcraft"

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

InstType "Full"
InstType "Auctioneer Only"
InstType "Libraries Only"

Section "!Libraries" Libraries

	SectionIn 1 2 3

	;EnhTT

	SetOutPath "$INSTDIR\Interface\AddOns\EnhTooltip"
	File "..\EnhTooltip\EnhTooltip.toc"
	File "..\EnhTooltip\*.xml"
	File "..\EnhTooltip\*.lua"
	File "GPL.txt"
	File "nopatch"

	;Stubby

	SetOutPath "$INSTDIR\Interface\AddOns\Stubby"
	File "..\Stubby\Stubby.toc"
	File "..\Stubby\*.xml"
	File "..\Stubby\*.lua"
	File "GPL.txt"
	File "nopatch"

SectionEnd

Section "UnInstaller" UnInstaller

	SectionIn 1 2 3

	;Create uninstaller
	WriteUninstaller "$INSTDIR\Auctioneer Uninstaller.exe"


;	Add our information to the Windows Add/Remove Control Panel

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
	retryCheck:
	FindWindow $0 "" "${WNDTITLE}"
		StrCmp $0 0 continueInstall
		MessageBox MB_ICONSTOP|MB_ABORTRETRYIGNORE|MB_DEFBUTTON1  "AddOns should not be modified while World of Warcraft is running, please close WoW before proceeding." IDIGNORE continueInstall IDRETRY retryCheck
	Abort
	continueInstall:

	!insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Function .onVerifyInstDir
	IfFileExists $INSTDIR\WoW.exe PathGood
		Abort
	PathGood:
FunctionEnd

Function .onSelChange
	GetCurInstType $0
	IntCmp $0 3 Yes Yes No
	Yes:
		!insertmacro SetSectionFlag Libraries 5
	No:
FunctionEnd


;--------------------------------
;Descriptions

	;Language strings

	!include InsStrings.nsh

	; Assign language strings to sections
	!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN

		!insertmacro MUI_DESCRIPTION_TEXT ${Libraries} $(DESC_Libraries)

		!insertmacro MUI_DESCRIPTION_TEXT ${UnInstaller} $(DESC_UnInstaller)

		!insertmacro MUI_DESCRIPTION_TEXT ${Auctioneer} $(DESC_Auctioneer)

		!insertmacro MUI_DESCRIPTION_TEXT ${Enchantrix} $(DESC_Enchantrix)

		!insertmacro MUI_DESCRIPTION_TEXT ${Informant} $(DESC_Informant)

	!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

InstType "un.All"
InstType "un.AddOns"

Section "!un.Libraries" un.Libraries

	SectionIn 1

;	EnhTT
	RMDir /r "$INSTDIR\Interface\AddOns\EnhTooltip"

;	Stubby
	RMDir /r "$INSTDIR\Interface\AddOns\Stubby"

	RMDir "$INSTDIR\Interface\AddOns"
	RMDir "$INSTDIR\Interface"
	RMDir "$INSTDIR"



SectionEnd

Section "un.UnInstaller" un.UnInstaller

	SectionIn 1

	Delete "$INSTDIR\Auctioneer Uninstaller.exe"

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
	retryCheck:
	FindWindow $0 "" "${WNDTITLE}"
		StrCmp $0 0 continueInstall
		MessageBox MB_ICONSTOP|MB_ABORTRETRYIGNORE|MB_DEFBUTTON1 "AddOns should not be modified while World of Warcraft is running, please close WoW before proceeding." IDIGNORE continueInstall IDRETRY retryCheck
	Abort
	continueInstall:

	!insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Function un.onVerifyInstDir
	IfFileExists $INSTDIR\WoW.exe PathGood
		Abort
	PathGood:
FunctionEnd

Function un.onSelChange
	GetCurInstType $0
	IntCmp $0 3 Yes Yes No
	Yes:
		!insertmacro SetSectionFlag Libraries 5
	No:
FunctionEnd
