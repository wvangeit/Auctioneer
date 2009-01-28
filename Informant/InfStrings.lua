--[[
	WARNING: This is a generated file.
	If you wish to perform or update localizations, please go to our Localizer website at:
	http://localizer.norganna.org/

	AddOn: Informant
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

InformantLocalizations = {

	enUS = {

		-- Section: Help
		["INF_Help_FirstUse"]	= "|c40ff50ffWelcome to Informant|r\n\nSince this is the first time you are using Informant, this message appears to let you know that you must set a key to show this window from within the |cffffffffKeybindings|r section of the |cffffffffGame Menu|r.\n\nFrom then on to view advanced information about items in your inventory, simply move your mouse over the item you want to see information about and press the key that you bound, and this window will popup, filled with information about that item.\n\nAt that point, simply press the key again, or click the close button on this frame.\n\nClick the close button now to continue.";
		["INF_Help_HowInfoWin"]	= "How do I use the Information Window?";
		["INF_Help_HowInfoWinAnswer"]	= "You can bind a key to toggle the Informant Information Window to get more detailed information about items. To do this, you need to open the Game Menu, select \"Key Bindings\" and look for Informant: Toggle Information Window.";
		["INF_Help_Welcome"]	= "Informant v%s loaded";
		["INF_Help_WhatIs"]	= "What is Informant?";
		["INF_Help_WhatIsAnswer"]	= "Informant provides extra information about items in the tooltip, an information window, and to other addons.";

		-- Section: HelpTooltip
		["INF_HelpTooltip_ActivateProfile"]	= "Select the profile that you wish to use for this character";
		["INF_HelpTooltip_AutoUpdate"]	= "Allow Informant to scan your bags and merchant inventory for updates";
		["INF_Helptooltip_DefaultProfile"]	= "Reset all settings for the current profile";
		["INF_HelpTooltip_DeleteProfile"]	= "Deletes the currently selected profile";
		["INF_HelpTooltip_Embed"]	= "Embed most of the info in the original game-tooltip (note: the item's link cannot be embedded)";
		["INF_HelpTooltip_EnableInformant"]	= "Toggles Informant's data display on and off";
		["INF_HelpTooltip_ProfileName"]	= "Enter the name of the profile that you wish to create";
		["INF_HelpTooltip_ProfileSave"]	= "Click this button to create or overwrite the specified profile name";
		["INF_HelpTooltip_ShowIlevel"]	= "Toggle the display of an item's level (this is different from its use level)";
		["INF_HelpTooltip_ShowLink"]	= "Toggle the display of an item's link (link cannot be embedded)";
		["INF_HelpTooltip_ShowMerchant"]	= "Shows the number of merchants who sell an item in the tooltip, and their name & location in the Informant Information Window";
		["INF_HelpTooltip_ShowQuest"]	= "Toggles the display of detailed quest info for an item in the Information Window";
		["INF_HelpTooltip_ShowStack"]	= "Display the quantity of an item's stack size";
		["INF_HelpTooltip_ShowUsage"]	= "Display an item's sub-type or what tradeskill they're used in";
		["INF_HelpTooltip_ShowVendorBuy"]	= "Toggle the display of an item's vendor buy price";
		["INF_HelpTooltip_ShowVendorSell"]	= "Toggle the display of an item's vendor sell price";
		["INF_HelpTooltip_ShowZeroMerchants"]	= "Toggles the display of a tooltip message of zero merchants selling an item";
		["INF_HelpTooltip_VendorToggle"]	= "Toggle to show an item's vendor buy/sell pricing";

		-- Section: Interface
		["INF_Interface_ActivateProfile"]	= "Activate a current profile";
		["INF_Interface_AutoUpdate"]	= "Automatically update item information at merchants";
		["INF_Interface_BindingHeader"]	= "Informant";
		["INF_Interface_BindingTitle"]	= "Toggle Information Window";
		["INF_Interface_CreateProfile"]	= "Create or replace a profile";
		["INF_Interface_DefaultProfile"]	= "Default";
		["INF_Interface_Delete"]	= "Delete";
		["INF_Interface_Embed"]	= "Embed info into the in-game tooltip";
		["INF_Interface_EnableInformant"]	= "Enable Informant";
		["INF_Interface_General"]	= "General";
		["INF_Interface_GeneralOptions"]	= "General Options";
		["INF_Interface_InfWinInfoHeader"]	= "Information for |cff%s%s|r";
		["INF_Interface_InfWinNoItem"]	= "You must mouse over an item, then press the activation key.";
		["INF_Interface_InfWinPlayerMade"]	= "Made by level %d %s";
		["INF_Interface_InfWinQuest"]	= "Quest item for %d quests";
		["INF_Interface_InfWinQuestLine"]	= "Quest: %s";
		["INF_Interface_InfWinQuestMultiLine"]	= "%d needed: %s";
		["INF_Interface_InfWinQuestRequires"]	= "Required for %d quests:";
		["INF_Interface_InfWinQuestReward"]	= "Reward from %d quests:";
		["INF_Interface_InfWinQuestSource"]	= "Quest data provided by";
		["INF_Interface_InfWinQuestStart"]	= "Starts a quest:";
		["INF_Interface_InfWinQuestUnknown"]	= "Unknown quest: ID #%d";
		["INF_Interface_InfWinTitle"]	= "Informant Item Information";
		["INF_Interface_InfWinVendorCount"]	= "Available from %d merchants:";
		["INF_Interface_InfWinVendorName"]	= "   %s";
		["INF_Interface_ProfileName"]	= "New profile name";
		["INF_Interface_SaveProfile"]	= "Save";
		["INF_Interface_SetupProfiles"]	= "Setup, Configure and Edit Profiles";
		["INF_Interface_ShowIlevel"]	= "Show an item's level";
		["INF_Interface_ShowLink"]	= "Show an item's link";
		["INF_Interface_ShowMerchant"]	= "Show merchant info in the tooltip and Information Window";
		["INF_Interface_ShowQuest"]	= "Show quest info in the Informant Information Window";
		["INF_Interface_ShowStack"]	= "Show an item's stack size";
		["INF_Interface_ShowUsage"]	= "Show an item's use";
		["INF_Interface_ShowVendorBuy"]	= "Show a vendor's buy price";
		["INF_Interface_ShowVendorSell"]	= "Show an item's vendor sell price";
		["INF_Interface_ShowZeroMerchants"]	= "Show a message when no merchants are known";
		["INF_Interface_VendorToggle"]	= "Show Vendor Buy/Sell Prices";

		-- Section: Tooltip
		["INF_HelpTooltip_SkillBlacksmithing"]	= "Blacksmithing";
		["INF_HelpTooltip_SkillCooking"]	= "Cooking";
		["INF_Tooltip_Class"]	= "Class: %s";
		["INF_Tooltip_Fishing"]	= "Fishing";
		["INF_Tooltip_ItemLevel"]	= "Item Level: %d";
		["INF_Tooltip_ItemLink"]	= "Link: %s";
		["INF_Tooltip_NoKnownMerchants"]	= "Sold by no known merchants";
		["INF_Tooltip_ShowMerchant"]	= "Sold by %d merchants";
		["INF_Tooltip_ShowVendorBuy"]	= "Buy from vendor";
		["INF_Tooltip_ShowVendorBuyMult"]	= "Buy %d (%s each)";
		["INF_Tooltip_ShowVendorSell"]	= "Sell to vendor";
		["INF_Tooltip_ShowVendorSellMult"]	= "Sell %d (%s each)";
		["INF_Tooltip_SkillAlchemy"]	= "Alchemy";
		["INF_Tooltip_SkillBlacksmithing"]	= "Blacksmithing";
		["INF_Tooltip_SkillCooking"]	= "Cooking";
		["INF_Tooltip_SkillDeathKnight"]	= "Death Knight Skills";
		["INF_Tooltip_SkillDruid"]	= "Druid Spells";
		["INF_Tooltip_SkillEnchanting"]	= "Enchanting";
		["INF_Tooltip_SkillEngineering"]	= "Engineering";
		["INF_Tooltip_SkillFirstAid"]	= "First Aid";
		["INF_Tooltip_SkillFishing"]	= "Fishing";
		["INF_Tooltip_SkillHerbalism"]	= "Herbalism";
		["INF_Tooltip_SkillInscription"]	= "Inscription";
		["INF_Tooltip_SkillJewelcrafting"]	= "Jewelcrafting";
		["INF_Tooltip_SkillLeatherworking"]	= "Leatherworking";
		["INF_Tooltip_SkillMage"]	= "Mage Spells";
		["INF_Tooltip_SkillMining"]	= "Mining";
		["INF_Tooltip_SkillPaladin"]	= "Paladin Spells";
		["INF_Tooltip_SkillPriest"]	= "Priest Spells";
		["INF_Tooltip_SkillRiding"]	= "Riding";
		["INF_Tooltip_SkillRogue"]	= "Rogue Skills";
		["INF_Tooltip_SkillShaman"]	= "Shaman Spells";
		["INF_Tooltip_SkillTailoring"]	= "Tailoring";
		["INF_Tooltip_SkillWarlock"]	= "Warlock Spells";
		["INF_Tooltip_SkillWarrior"]	= "Warrior Skills";
		["INF_Tooltip_StackSize"]	= "Stacks in lots of %d";
		["INF_Tooltip_Use"]	= "Used for: %s";

	};

}