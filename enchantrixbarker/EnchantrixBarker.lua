--[[

	Enchantrix v<%version%> (<%codename%>)
	$Id: EnchantrixBarker.lua 1748 2007-04-25 00:32:05Z luke1410 $

	By Norganna
	http://enchantrix.org/

	This is an addon for World of Warcraft that add a list of what an item
	disenchants into to the items that you mouse-over in the game.

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
EnchantrixBarker_RegisterRevision("$URL: http://norganna@norganna.org/svn/auctioneer/trunk5/enchantrix/EnchantrixBarker.lua $", "$Rev: 1748 $")

local priorityList = {};

	-- this is used to search the trade categories
	-- the key is our internal value
	-- search is the string to look for in the enchant name
	-- print is what we print for the output
local categories = {
	['factor_item.bracer'] = {search = _BARKLOC('Bracer'), print = _BARKLOC('Bracer') },
	['factor_item.gloves'] = {search = _BARKLOC('Gloves'), print = _BARKLOC('Gloves') },
	['factor_item.boots'] = {search = _BARKLOC('Boots'), print = _BARKLOC('Boots') },
	['factor_item.shield'] = {search = _BARKLOC('Shield'), print = _BARKLOC('Shield') },
	['factor_item.chest'] = {search = _BARKLOC('Chest'), print = _BARKLOC('Chest') },
	['factor_item.cloak'] = {search = _BARKLOC('Cloak'), print = _BARKLOC('Cloak') },
	['factor_item.2hweap'] = {search = _BARKLOC('TwoHandWeapon'), print = _BARKLOC('TwoHandWeapon')},
	['factor_item.weapon'] = {search = _BARKLOC('Weapon'), print = _BARKLOC('AnyWeapon') },
	['factor_item.ring'] = {search = _BARKLOC('Ring'), print = _BARKLOC('Ring') },
};


	-- this is used internally only, to determine the order of enchants shown
local print_order = {
	'factor_item.bracer',
	'factor_item.gloves',
	'factor_item.boots',
	'factor_item.ring',
	'factor_item.chest', 
	'factor_item.cloak', 
	'factor_item.shield', 
	'factor_item.2hweap', 
	'factor_item.weapon',
};


	-- these are used to search the craft listing
	-- the order of items is important to get the longest match (ie: "resistance to shadow" before "resistance")
	--  	BUT that may not work with locallized strings!   Try to get longer string matches
	-- search is what we use to search the enchant description text
	--		all strings are reduced to lower case!
	-- key is how we lookup percentanges from the settings (internal only)
	-- print is what we print for the output
 -- TODO: check for mistakes and mis-classifications/exceptions
local attributes = {
	{ search = _BARKLOC("EnchSearchCrusader"), key = "other", print = _BARKLOC("Crusader") },	-- to differentiate from strength
	{ search = _BARKLOC("EnchSearchIntellect"), key = 'INT', print = _BARKLOC("INT") },
	{ search = _BARKLOC("EnchSearchStamina"), key = "STA", print = _BARKLOC("STA") },
	{ search = _BARKLOC("EnchSearchSpirit"), key = "SPI", print = _BARKLOC("SPI") },
	{ search = _BARKLOC("EnchSearchStrength"), key = "STR", print = _BARKLOC("STR") },
	{ search = _BARKLOC("EnchSearchAgility"), key = "AGI", print = _BARKLOC("AGI") },
	{ search = _BARKLOC("EnchSearchFireRes"), key = "fire res", print = _BARKLOC("FireRes") },
	{ search = _BARKLOC("EnchSearchResFire"), key = "fire res", print = _BARKLOC("FireRes") },
	{ search = _BARKLOC("EnchSearchFrostRes"), key = "frost res", print = _BARKLOC("FrostFes") },
	{ search = _BARKLOC("EnchSearchNatureRes"), key = "nature res", print = _BARKLOC("NatureRes") },
	{ search = _BARKLOC("EnchSearchResShadow"), key = "shadow res", print = _BARKLOC("ShadowRes") },
	{ search = _BARKLOC("EnchSearchAllStats"), key = "all stats", print = _BARKLOC("AllStats") },
	{ search = _BARKLOC("EnchSearchMana"), key = "mana", print = _BARKLOC("ShortMana") },
	{ search = _BARKLOC("EnchSearchHealth"), key = "health", print = _BARKLOC("ShortHealth") },
	{ search = _BARKLOC("EnchSearchArmor"), key = "armor", print = _BARKLOC("ShortArmor") },
	{ search = _BARKLOC("EnchSearchDMGAbsorption"), key = "DMG absorb", print = _BARKLOC("DMGAbsorb") },
	{ search = _BARKLOC("EnchSearchDamage1"), key = "DMG", print = _BARKLOC("DMG") },
	{ search = _BARKLOC("EnchSearchDamage2"), key = "DMG", print = _BARKLOC("DMG") },
	{ search = _BARKLOC("EnchSearchDefense"),  key = "DEF", print = _BARKLOC("DEF") },
	{ search = _BARKLOC("EnchSearchAllResistance1"), key = "all res", print = _BARKLOC("ShortAllRes") },
	{ search = _BARKLOC("EnchSearchAllResistance2"), key = "all res", print = _BARKLOC("ShortAllRes") },
	{ search = _BARKLOC("EnchSearchAllResistance3"), key = "all res", print = _BARKLOC("ShortAllRes") },
	
};


--[[
Other possible exceptions or additions

	{ search = 'damage to beasts', key = "other", print = "Beastslayer" },
	{ search = 'damage against elementals', key = "other", print = "Elementalslayer" },
	{ search = 'damage to demons', key = "other", print = "Demonslayer" },
	{ search = 'damage to spells', key = "other", print = "spell" },
	{ search = 'damage to all spells', key = "other", print = "spell" },
	{ search = 'spell damage', key = "other", print = "spell" },
	{ search = 'healing', key = "other", print = "heal" },
	{ search = 'frost spells', key = "other", print = "frost" },
	{ search = 'frost damage', key = "other", print = "frost" },
	{ search = 'shadow damage', key = "other", print = "shadow" },
	{ search = "increase fire damage", key = "other", print = "fire" },
	{ search = 'block rating', key = "other", print = "block" },
	{ search = 'block value', key = "other", print = "block" },

stealth  "increase to stealth"
dodge  "dodge rating"
assult  "increase attack power"
brawn  "increase Strength"
haste "attack speed bonus"
vitality  "restore [0-9]+ health and mana"
blasting  "spell critical strike rating"
spell penetration  "spell penetration"
savagery 	"attack power"
battlemaster "heal nearby party members"
spellsurge "restore [0-9]+ mana to all party members"
spellstrike "spell hit rating"
cat's swiftness "movement speed increase and [0-9]+ Agility"
boar's speed "movement speed increase and [0-9]+ Stamina"
surefooted "snare and root resistance"
mongoose "increase agility by [0-9]+ and attack speed"
sunfire  "fire and arcane spells"
soulfrost "frost and shadow spells"
crusader "heals for [0-9]+ to [0-9]+ and increases Strength"

enchanted leather "Enchanted Leather"
enchanted thorium "Enchanted Thorium Bar"

]]


	-- this is used to match up trade zone game names with short strings for the output
local short_location = {
	[_BARKLOC('Orgrimmar')] = _BARKLOC('ShortOrgrimmar'),
	[_BARKLOC('ThunderBluff')] = _BARKLOC('ShortThunderBluff'), 
	[_BARKLOC('Undercity')] = _BARKLOC('ShortUndercity'),
	[_BARKLOC('StormwindCity')] = _BARKLOC('ShortStormwind'),
	[_BARKLOC('Darnassus')] = _BARKLOC('ShortDarnassus'),
	[_BARKLOC('Ironforge')] = _BARKLOC('ShortIronForge'),
	[_BARKLOC('Shattrath')] = _BARKLOC('ShortShattrath'),
	[_BARKLOC('SilvermoonCity')] = _BARKLOC('ShortSilvermoon'),
	[_BARKLOC('TheExodar')] = _BARKLOC('ShortExodar'),
};


--[[
local config_defaults = {
	barker_chan_default = _BARKLOC('ChannelDefault')
};
]]

local relevelFrame;
local relevelFrames;

local addonName = "Enchantrix Barker"

-- UI code

function EnchantrixBarker_OnEvent()
	--Barker.Util.ChatPrint("GotUIEvent...");

	--Returns "Enchanting" for enchantwindow and nil for Beast Training
	local craftName, rank, maxRank = GetCraftDisplaySkillLine()

	if craftName then
		--Barker.Util.ChatPrint("Barker config is "..tostring(Barker.Settings.GetSetting('barker')) );
		if( event == "CRAFT_SHOW" ) then
			if( Barker.Settings.GetSetting('barker') ) then
				Enchantrix_BarkerDisplayButton:Show();
				Enchantrix_BarkerDisplayButton.tooltipText = _BARKLOC('OpenBarkerWindow');
			else
				Enchantrix_BarkerDisplayButton:Hide();
				Enchantrix_BarkerOptions_Frame:Hide();
			end
		elseif( event == "CRAFT_CLOSE" )then
			Enchantrix_BarkerDisplayButton:Hide();
			Enchantrix_BarkerOptions_Frame:Hide();
		--elseif(	event == "ZONE_CHANGED" ) then
		--	Enchantrix_BarkerOptions_ChanFilterDropDown_Initialize();
		end
	end
end

function Enchantrix_BarkerOptions_OnShow()
	Enchantrix_BarkerOptions_ShowFrame(1);
end

function Enchantrix_BarkerOnClick()
	local barker = Enchantrix_CreateBarker();
	local id = GetChannelName( _BARKLOC("TradeChannel") ) ;
	Barker.Util.DebugPrintQuick("Attempting to send barker ", barker, " Trade Channel ID ", id)

	if (id and (not(id == 0))) then
		if (barker) then
			SendChatMessage(barker,"CHANNEL", GetDefaultLanguage("player"), id);
		end
	else
		Barker.Util.ChatPrint( _BARKLOC("BarkerNotTradeZone") );
	end
end

function Barker.Barker.AddonLoaded()
	Barker.Util.ChatPrint( _BARKLOC("BarkerLoaded") );
end

function relevelFrame(frame)
	return relevelFrames(frame:GetFrameLevel() + 2, frame:GetChildren())
end

function relevelFrames(myLevel, ...)
	for i = 1, select("#", ...) do
		local child = select(i, ...)
		child:SetFrameLevel(myLevel)
		relevelFrame(child)
	end
end

local function craftUILoaded()

	Stubby.UnregisterAddOnHook("Blizzard_CraftUI", "Enchantrix")
	local useFrame = CraftFrame;
	
	if (ATSWFrame ~= nil) then
		Stubby.UnregisterAddOnHook("ATSWFrame", "Enchantrix")
		useFrame = ATSWFrame;
	end

	--Enchantrix_BarkerButton:SetParent(useFrame);
	--Enchantrix_BarkerButton:SetPoint("TOPRIGHT", useFrame, "TOPRIGHT", -185, -55 );

	Enchantrix_BarkerDisplayButton:SetParent(useFrame);
	--Enchantrix_BarkerDisplayButton:SetPoint("BOTTOMRIGHT", Enchantrix_BarkerButton, "BOTTOMLEFT");
	Enchantrix_BarkerDisplayButton:SetPoint("TOPRIGHT", useFrame, "TOPRIGHT", -185, -55 );

	Enchantrix_BarkerOptions_Frame:SetParent(useFrame);
	Enchantrix_BarkerOptions_Frame:SetPoint("TOPLEFT", useFrame, "TOPRIGHT");
	relevelFrame(Enchantrix_BarkerOptions_Frame)
end

function EnchantrixBarker_OnLoad()
	if (ATSWFrame ~= nil) then
		Stubby.RegisterAddOnHook("ATSWFrame", "Enchantrix", craftUILoaded)
	end
	Stubby.RegisterAddOnHook("Blizzard_CraftUI", "Enchantrix", craftUILoaded)
end

function Enchantrix_BarkerGetConfig( key )
	return Barker.Settings.GetSetting("barker."..key)
end

function Enchantrix_BarkerSetConfig( key, value )
	Barker.Settings.SetSetting("barker."..key, value)
end

function Enchantrix_BarkerOptions_SetDefaults()
	--Barker.Util.ChatPrint("Enchantrix: Setting Barker to defaults"); -- TODO: Localize
	Barker.Settings.SetSetting("barker.profit_margin", nil)
	Barker.Settings.SetSetting("barker.randomize", nil)
	Barker.Settings.SetSetting("barker.lowest_price", nil)

	if Enchantrix_BarkerOptions_Frame:IsVisible() then
		Enchantrix_BarkerOptions_Refresh()
	end
end

function Enchantrix_BarkerOptions_TestButton_OnClick()
	local barker = Enchantrix_CreateBarker();
	local id = GetChannelName( _BARKLOC("TradeChannel") )
	Barker.Util.DebugPrintQuick("Attempting to send test barker ", barker, "Trade Channel ID ", id)

	if (id and (not(id == 0))) then
		if (barker) then
			Barker.Util.ChatPrint(barker);
		end
	else
		Barker.Util.ChatPrint( _BARKLOC("BarkerNotTradeZone") );
	end
end

function Enchantrix_BarkerOptions_Factors_Slider_GetValue(id)
	if (not id) then
		id = this:GetID();
	end
	return Enchantrix_BarkerGetConfig(Enchantrix_BarkerOptions_TabFrames[Enchantrix_BarkerOptions_ActiveTab].options[id].key);
end

function Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged(id)
	if (not id) then
		id = this:GetID();
	end
	Enchantrix_BarkerSetConfig(Enchantrix_BarkerOptions_TabFrames[Enchantrix_BarkerOptions_ActiveTab].options[id].key, this:GetValue());
end

Enchantrix_BarkerOptions_ActiveTab = -1;


 --TODO: Localize
Enchantrix_BarkerOptions_TabFrames = {
	{
		title = _BARKLOC('BarkerOptionsTab1Title'),
		options = {
			{
				name = _BARKLOC('BarkerOptionsProfitMarginTitle'),
				tooltip = _BARKLOC('BarkerOptionsProfitMarginTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'profit_margin',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsHighestProfitTitle'),
				tooltip = _BARKLOC('BarkerOptionsHighestProfitTooltip'),
				units = 'money',
				min = 0,
				max = 250000,
				step = 500,
				key = 'highest_profit',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsLowestPriceTitle'),
				tooltip = _BARKLOC('BarkerOptionsLowestPriceTooltip'),
				units = 'money',
				min = 0,
				max = 50000,
				step = 500,
				key = 'lowest_price',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsPricePriorityTitle'),
				tooltip = _BARKLOC('BarkerOptionsPricePriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_price',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsPriceSweetspotTitle'),
				tooltip = _BARKLOC('BarkerOptionsPriceSweetspotTooltip'),
				units = 'money',
				min = 0,
				max = 500000,
				step = 5000,
				key = 'sweet_price',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsHighestPriceForFactorTitle'),
				tooltip = _BARKLOC('BarkerOptionsHighestPriceForFactorTooltip'),
				units = 'money',
				min = 0,
				max = 1000000,
				step = 50000,
				key = 'high_price',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsRandomFactorTitle'),
				tooltip = _BARKLOC('BarkerOptionsRandomFactorTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'randomise',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
		}
	},
	{
		title = 'Item Priorities',
		options = {
			{
				name = _BARKLOC('BarkerOptionsItemsPriority'),
				tooltip = _BARKLOC('BarkerOptionsItemsPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_item',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('TwoHandWeapon'),
				tooltip = _BARKLOC('BarkerOptions2HWeaponPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_item.2hweap',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('AnyWeapon'),
				tooltip = _BARKLOC('BarkerOptionsAnyWeaponPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_item.weapon',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('Bracer'),
				tooltip = _BARKLOC('BarkerOptionsBracerPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_item.bracer',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('Gloves'),
				tooltip = _BARKLOC('BarkerOptionsGlovesPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_item.gloves',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('Boots'),
				tooltip = _BARKLOC('BarkerOptionsBootsPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_item.boots',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('Chest'),
				tooltip = _BARKLOC('BarkerOptionsChestPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_item.chest',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('Cloak'),
				tooltip = _BARKLOC('BarkerOptionsCloakPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_item.cloak',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('Shield'),
				tooltip = _BARKLOC('BarkerOptionsShieldPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_item.shield',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('Ring'),
				tooltip = _BARKLOC('BarkerOptionsRingPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_item.ring',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
		}
	},
	{
		title = 'Stats 1',
		options = {
			{
				name = _BARKLOC('BarkerOptionsStatsPriority'),
				tooltip = _BARKLOC('BarkerOptionsStatsPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsIntellectPriority'),
				tooltip = _BARKLOC('BarkerOptionsIntellectPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.int',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsStrengthPriority'),
				tooltip = _BARKLOC('BarkerOptionsStrengthPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.str',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsAgilityPriority'),
				tooltip = _BARKLOC('BarkerOptionsAgilityPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.agi',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsStaminaPriority'),
				tooltip = _BARKLOC('BarkerOptionsStaminaPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.sta',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsSpiritPriority'),
				tooltip = _BARKLOC('BarkerOptionsSpiritPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.spi',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsArmorPriority'),
				tooltip = _BARKLOC('BarkerOptionsArmorPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.arm',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsAllStatsPriority'),
				tooltip = _BARKLOC('BarkerOptionsAllStatsPriorityTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.all',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
		}
	},
	{
		title = 'Stats 2',
		options = {
			{
				name = _BARKLOC('BarkerOptionsAllResistances'),
				tooltip = _BARKLOC('BarkerOptionsAllResistancesTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.res',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsFireResistance'),
				tooltip = _BARKLOC('BarkerOptionsFireResistanceTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.fir',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsFrostResistance'),
				tooltip = _BARKLOC('BarkerOptionsFrostResistanceTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.frr',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsNatureResistance'),
				tooltip = _BARKLOC('BarkerOptionsNatureResistanceTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.nar',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsShadowResistance'),
				tooltip = _BARKLOC('BarkerOptionsShadowResistanceTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.shr',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsMana'),
				tooltip = _BARKLOC('BarkerOptionsManaTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.mp',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsHealth'),
				tooltip = _BARKLOC('BarkerOptionsHealthTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.hp',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsDamage'),
				tooltip = _BARKLOC('BarkerOptionsDamageTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.dmg',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsDefense'),
				tooltip = _BARKLOC('BarkerOptionsDefenseTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.def',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
			{
				name = _BARKLOC('BarkerOptionsOther'),
				tooltip = _BARKLOC('BarkerOptionsOtherTooltip'),
				units = 'percentage',
				min = 0,
				max = 100,
				step = 1,
				key = 'factor_stat.ski',
				getvalue = Enchantrix_BarkerOptions_Factors_Slider_GetValue,
				valuechanged = Enchantrix_BarkerOptions_Factors_Slider_OnValueChanged
			},
		}
	}
};

function EnchantrixBarker_OptionsSlider_OnValueChanged()
	if Enchantrix_BarkerOptions_ActiveTab ~= -1 then
		--Barker.Util.ChatPrint( "Tab - Slider changed: "..Enchantrix_BarkerOptions_ActiveTab..' - '..this:GetID() );
		Enchantrix_BarkerOptions_TabFrames[Enchantrix_BarkerOptions_ActiveTab].options[this:GetID()].valuechanged();
		value = this:GetValue();
		--Enchantrix_BarkerOptions_TabFrames[Enchantrix_BarkerOptions_ActiveTab].options[this:GetID()].getvalue();

		valuestr = EnchantrixBarker_OptionsSlider_GetTextFromValue( value, Enchantrix_BarkerOptions_TabFrames[Enchantrix_BarkerOptions_ActiveTab].options[this:GetID()].units );

		getglobal(this:GetName().."Text"):SetText(Enchantrix_BarkerOptions_TabFrames[Enchantrix_BarkerOptions_ActiveTab].options[this:GetID()].name.." - "..valuestr );
	end
end

function EnchantrixBarker_OptionsSlider_GetTextFromValue( value, units )

	local valuestr = ''

	if units == 'percentage' then
		valuestr = value..'%'
	elseif units == 'money' then
		local p_gold,p_silver,p_copper = EnhTooltip.GetGSC(value);

		if( p_gold > 0 ) then
			valuestr = p_gold.."g";
		end
		if( p_silver > 0 ) then
			valuestr = valuestr..p_silver.."s";
		end
	end
	return valuestr;
end

function Enchantrix_BarkerOptions_Tab_OnClick()
	--Barker.Util.ChatPrint( "Clicked Tab: "..this:GetID() );
	Enchantrix_BarkerOptions_ShowFrame( this:GetID() )

end

function Enchantrix_BarkerOptions_Refresh()
	local cur = Enchantrix_BarkerOptions_ActiveTab
	if (cur and cur > 0) then
		Enchantrix_BarkerOptions_ShowFrame(cur)
	end
end

function Enchantrix_BarkerOptions_ShowFrame( frame_index )
	Enchantrix_BarkerOptions_ActiveTab = -1
	for index, frame in pairs(Enchantrix_BarkerOptions_TabFrames) do
		if ( index == frame_index ) then
			--Barker.Util.ChatPrint( "Showing Frame: "..index );
			for i = 1,10 do
				local slider = getglobal('EnchantrixBarker_OptionsSlider_'..i);
				slider:Hide();
			end
			for i, opt in pairs(frame.options) do
				local slidername = 'EnchantrixBarker_OptionsSlider_'..i
				local slider = getglobal(slidername);
				slider:SetMinMaxValues(opt.min, opt.max);
				slider:SetValueStep(opt.step);
				slider.tooltipText = opt.tooltip;
				getglobal(slidername.."High"):SetText();
				getglobal(slidername.."Low"):SetText();
				slider:Show();
			end
			Enchantrix_BarkerOptions_ActiveTab = index
			for i, opt in pairs(frame.options) do
				local slidername = 'EnchantrixBarker_OptionsSlider_'..i
				local slider = getglobal(slidername);
				local newValue = opt.getvalue(i);
				slider:SetValue(newValue);
				getglobal(slidername.."Text"):SetText(opt.name..' - '..EnchantrixBarker_OptionsSlider_GetTextFromValue(slider:GetValue(),opt.units));
			end
		end
	end
end

function Enchantrix_BarkerOptions_OnClick()
	--Barker.Util.ChatPrint("You pressed the options button." );
	--showUIPanel(Enchantrix_BarkerOptions_Frame);
	if not Enchantrix_BarkerOptions_Frame:IsShown() then
		Enchantrix_BarkerOptions_Frame:Show();
	else
		Enchantrix_BarkerOptions_Frame:Hide();
	end
end

function Enchantrix_CheckButton_OnShow()
end
function Enchantrix_CheckButton_OnClick()
end
function Enchantrix_CheckButton_OnEnter()
end
function Enchantrix_CheckButton_OnLeave()
end

--[[
function Enchantrix_BarkerOptions_ChanFilterDropDown_Initialize()

		local dropdown = this:GetParent();
		local frame = dropdown:GetParent();

		ChnPtyBtn		= {};
		ChnPtyBtn.text	= _BARKLOC('ChannelParty');
		ChnPtyBtn.func	= Enchantrix_BarkerOptions_ChanFilterDropDownItem_OnClick;
		ChnPtyBtn.owner	= dropdown
		UIDropDownMenu_AddButton(ChnPtyBtn)

		ChnRdBtn		= {};
	    ChnRdBtn.text	= _BARKLOC('ChannelRaid');
		ChnRdBtn.func	= Enchantrix_BarkerOptions_ChanFilterDropDownItem_OnClick;
		ChnRdBtn.owner	= dropdown
		UIDropDownMenu_AddButton(ChnRdBtn)

		ChnGldBtn		= {};
		ChnGldBtn.text	= _BARKLOC('ChannelGuild');
		ChnGldBtn.func	= Enchantrix_BarkerOptions_ChanFilterDropDownItem_OnClick;
		ChnGldBtn.owner	= dropdown
		UIDropDownMenu_AddButton(ChnGldBtn)

		ChnTlRBtn		= {};
		ChnTlRBtn.text	= _BARKLOC('ChannelTellRec');
		ChnTlRBtn.func	= Enchantrix_BarkerOptions_ChanFilterDropDownItem_OnClick;
		ChnTlRBtn.owner	= dropdown
		UIDropDownMenu_AddButton(ChnTlRBtn)

		ChnTlSBtn		= {};
		ChnTlSBtn.text	= _BARKLOC('ChannelTellSent');
		ChnTlSBtn.func	= Enchantrix_BarkerOptions_ChanFilterDropDownItem_OnClick;
		ChnTlSBtn.owner	= dropdown
		UIDropDownMenu_AddButton(ChnTlSBtn)

		ChnSayBtn		= {};
		ChnSayBtn.text	= _BARKLOC('ChannelSay');
		ChnSayBtn.func	= Enchantrix_BarkerOptions_ChanFilterDropDownItem_OnClick;
		ChnSayBtn.owner	= dropdown
		UIDropDownMenu_AddButton(ChnSayBtn)

		local chanlist = {GetChannelList()}; --GetChannelList can be buggy.
		local ZoneName = GetRealZoneText();

		for i = 1, table.getn(chanlist) do
			id, channame = GetChannelName(i);

			if ((channame) and  (channame ~= (_BARKLOC('ChannelGeneral')..ZoneName)) and 
			 (channame ~= (_BARKLOC('ChannelLocalDefense')..ZoneName)) and (channame ~= _BARKLOC('ChannelWorldDefense')) and 
			 (channame ~= _BARKLOC('ChannelGuildRecruitment')) and (channame ~= _BARKLOC('ChannelBlock1')) ) then
					info	= {};
				info.text	= channame;
				info.value	= i; 
				info.func	= Enchantrix_BarkerOptions_ChanFilterDropDownItem_OnClick;
				info.owner	= dropdown;
				UIDropDownMenu_AddButton(info)
			end
       end
end

function Enchantrix_BarkerOptions_ChanFilterDropDown_OnClick() 
       ToggleDropDownMenu(1, nil, Enchantrix_BarkerOptions_ChanFilterDropDown, "cursor");
end

-- The following is shamelessly lifted from auctioneer/UserInterace/AuctioneerUI.lua
-------------------------------------------------------------------------------
-- Wrapper for UIDropDownMenu_Initialize() that sets 'this' before calling
-- UIDropDownMenu_Initialize().
-------------------------------------------------------------------------------
function dropDownMenuInitialize(dropdown, func)
	-- Hide all the buttons to prevent any calls to Hide() inside
	-- UIDropDownMenu_Initialize() which will screw up the value of this.
	local button, dropDownList;
	for i = 1, UIDROPDOWNMENU_MAXLEVELS, 1 do
		dropDownList = getglobal("DropDownList"..i);
		if ( i >= UIDROPDOWNMENU_MENU_LEVEL or dropdown:GetName() ~= UIDROPDOWNMENU_OPEN_MENU ) then
			dropDownList.numButtons = 0;
			dropDownList.maxWidth = 0;
			for j=1, UIDROPDOWNMENU_MAXBUTTONS, 1 do
				button = getglobal("DropDownList"..i.."Button"..j);
				button:Hide();
			end
		end
	end

	-- Call the UIDropDownMenu_Initialize() after swapping in a value for 'this'.
	local oldThis = this;
	this = getglobal(dropdown:GetName().."Button");
	local newThis = this;
	UIDropDownMenu_Initialize(dropdown, func);
	-- Double check that the value of 'this' didn't change... this can screw us
	-- up and prevent the reason for this method!
	if (newThis ~= this) then
		Barker.Util.DebugPrintQuick("WARNING: The value of this changed during dropDownMenuInitialize()")
	end
	this = oldThis;
end

-------------------------------------------------------------------------------
-- Wrapper for UIDropDownMenu_SetSeletedID() that sets 'this' before calling
-- UIDropDownMenu_SetSelectedID().
-------------------------------------------------------------------------------
function dropDownMenuSetSelectedID(dropdown, index)
	local oldThis = this;
	this = dropdown;
	local newThis = this;
	UIDropDownMenu_SetSelectedID(dropdown, index);
	-- Double check that the value of 'this' didn't change... this can screw us
	-- up and prevent the reason for this method!
	if (newThis ~= this) then
		Barker.Util.DebugPrintQuick("WARNING: The value of this changed during dropDownMenuSetSelectedID()")
	end
	this = oldThis;
end

function Enchantrix_BarkerOptions_ChanFilterDropDownItem_OnClick()
	local index = this:GetID();
	local dropdown = this.owner;

	dropDownMenuSetSelectedID(dropdown, index);
	Enchantrix_BarkerSetConfig("barker_chan", this:GetText())
end
]]

-- end UI code

function Enchantrix_CreateBarker()
	local availableEnchants = {};
	local numAvailable = 0;
	local temp = GetCraftSkillLine(1);
	if EnchantrixBarker_BarkerGetZoneText() then
		EnchantrixBarker_ResetBarkerString();
		EnchantrixBarker_ResetPriorityList();
		if (temp) then
			Barker.Util.DebugPrintQuick("Starting creation of EnxBarker")
			for index=1, GetNumCrafts() do
				local craftName, craftSubSpellName, craftType, numEnchantsAvailable, isExpanded = GetCraftInfo(index);
				if((numEnchantsAvailable > 0) and (craftName:find("Enchant"))) then --have reagents and it is an enchant
					local cost = 0;
					for j=1,GetCraftNumReagents(index),1 do
						local a,b,c = GetCraftReagentInfo(index,j);
						reagent = GetCraftReagentItemLink(index,j);

						cost = cost + (Enchantrix_GetReagentHSP(reagent)*c);
					end

					local profit = cost * Enchantrix_BarkerGetConfig("profit_margin")*0.01;
					if( profit > Enchantrix_BarkerGetConfig("highest_profit") ) then
						profit = Enchantrix_BarkerGetConfig("highest_profit");
					end
					local price = EnchantrixBarker_RoundPrice(cost + profit);

					local enchant = {
						index = index,
						name = craftName,
						type = craftType,
						available = numEnchantsAvailable,
						isExpanded = isExpanded,
						cost = cost,
						price = price,
						profit = price - cost
					};
					availableEnchants[ numAvailable] = enchant;

					local p_gold,p_silver,p_copper = EnhTooltip.GetGSC(enchant.price);
					local pr_gold,pr_silver,pr_copper = EnhTooltip.GetGSC(enchant.profit);

					EnchantrixBarker_AddEnchantToPriorityList( enchant )
					numAvailable = numAvailable + 1;
				end
			end

			if numAvailable == 0 then
				Barker.Util.ChatPrint(_BARKLOC('BarkerNoEnchantsAvail'));
				return nil
			end

			for i,element in ipairs(priorityList) do
				EnchantrixBarker_AddEnchantToBarker( element.enchant );
			end

			return EnchantrixBarker_GetBarkerString();

		else
			Barker.Util.ChatPrint(_BARKLOC('BarkerEnxWindowNotOpen'));
		end
	end

	return nil
end

function EnchantrixBarker_ScoreEnchantPriority( enchant )

	local score_item = 0;

	if Enchantrix_BarkerGetConfig( EnchantrixBarker_GetItemCategoryKey(enchant.index) ) then
		score_item = Enchantrix_BarkerGetConfig( EnchantrixBarker_GetItemCategoryKey(enchant.index) );
		score_item = score_item * Enchantrix_BarkerGetConfig( 'factor_item' )*0.01;
	end

	local score_stat = Enchantrix_BarkerGetConfig( EnchantrixBarker_GetEnchantStat(enchant) );
	if not score_stat then
		score_stat = Enchantrix_BarkerGetConfig( 'other' );
	end

	score_stat = score_stat * Enchantrix_BarkerGetConfig( 'factor_stat' )*0.01;

	local score_price = 0;
	local price_score_floor = Enchantrix_BarkerGetConfig("sweet_price");
	local price_score_ceiling = Enchantrix_BarkerGetConfig("high_price");

	if enchant.price < price_score_floor then
		score_price = (price_score_floor - (price_score_floor - enchant.price))/price_score_floor * 100;
	elseif enchant.price < price_score_ceiling then
		range = (price_score_ceiling - price_score_floor);
		score_price = (range - (enchant.price - price_score_floor))/range * 100;
	end

	score_price = score_price * Enchantrix_BarkerGetConfig( 'factor_price' )*0.01;
	score_total = (score_item + score_stat + score_price);

	return score_total * (1 - Enchantrix_BarkerGetConfig("randomise")*0.01) + math.random(300) * Enchantrix_BarkerGetConfig("randomise")*0.01;
end

function EnchantrixBarker_ResetPriorityList()
	priorityList = {};
end

function EnchantrixBarker_AddEnchantToPriorityList(enchant)

	local enchant_score = EnchantrixBarker_ScoreEnchantPriority( enchant );

	for i,priorityentry in ipairs(priorityList) do
		if( priorityentry.score < enchant_score ) then
			table.insert( priorityList, i, {score = enchant_score, enchant = enchant} );
			return;
		end
	end

	table.insert( priorityList, {score = enchant_score, enchant = enchant} );
end

function EnchantrixBarker_RoundPrice( price )

	local round

	if( price < 5000 ) then
		round = 1000;
	elseif ( price < 20000 ) then
		round = 2500;
	elseif (price < 100000) then
		round = 5000;
	else
		round = 10000;
	end

	odd = math.fmod(price,round);

	price = price + (round - odd);

	if( price < Enchantrix_BarkerGetConfig("lowest_price") ) then
		price = Enchantrix_BarkerGetConfig("lowest_price");
	end

	return price
end

function Enchantrix_GetReagentHSP( itemLink )

	if ((not Enchantrix) or (not Enchantrix.Util)) then
		Barker.Util.ChatPrint(_BARKLOC("MesgNotloaded"));
		return 0;
	end

	local hsp, median, market, prices = Enchantrix.Util.GetReagentPrice( itemLink );

	if hsp == nil then
		hsp = 0;
	end

	return hsp;
end

local barkerString = '';
local barkerCategories = {};

function EnchantrixBarker_ResetBarkerString()
	barkerString = "("..EnchantrixBarker_BarkerGetZoneText()..") ".._BARKLOC('BarkerOpening');
	barkerCategories = {};
end

function EnchantrixBarker_BarkerGetZoneText()
	local result = short_location[GetZoneText()];
	if (not result) then
		Barker.Util.DebugPrintQuick("Attempting to use barker in zone", GetZoneText() )
	end
	return result;
end

function EnchantrixBarker_AddEnchantToBarker( enchant )

	local currBarker = EnchantrixBarker_GetBarkerString();

	local category_key = EnchantrixBarker_GetItemCategoryKey( enchant.index )
	local category_string = "";
	local test_category = {};
	if barkerCategories[ category_key ] then
		for i,element in ipairs(barkerCategories[category_key]) do
			--Barker.Util.ChatPrint("Inserting: "..i..", elem: "..element.index );
			table.insert(test_category, element);
		end
	end

	table.insert(test_category, enchant);

	category_string = EnchantrixBarker_GetBarkerCategoryString( test_category );


	if #currBarker + #category_string > 255 then
		return false;
	end

	if not barkerCategories[ category_key ] then
		barkerCategories[ category_key ] = {};
	end

	table.insert( barkerCategories[ category_key ],enchant );

	return true;
end

function EnchantrixBarker_GetBarkerString()
	if not barkerString then EnchantrixBarker_ResetBarkerString() end

	local barker = ""..barkerString;

	for index, key in ipairs(print_order) do
		if( barkerCategories[key] ) then
			barker = barker..EnchantrixBarker_GetBarkerCategoryString( barkerCategories[key] )
		end
	end

	return barker;
end

function EnchantrixBarker_GetBarkerCategoryString( barkerCategory )
	local barkercat = ""
	--Barker.Util.DebugPrintQuick("setting up ", barkerCategory[1].index, EnchantrixBarker_GetItemCategoryString(barkerCategory[1].index) );
	barkercat = barkercat.." ["..EnchantrixBarker_GetItemCategoryString(barkerCategory[1].index)..": ";
	for j,enchant in ipairs(barkerCategory) do
		if( j > 1) then
			barkercat = barkercat..", "
		end
		barkercat = barkercat..EnchantrixBarker_GetBarkerEnchantString(enchant);
	end
	barkercat = barkercat.."]"

	return barkercat
end

function EnchantrixBarker_GetBarkerEnchantString( enchant )
	local p_gold,p_silver,p_copper = EnhTooltip.GetGSC(enchant.price);

	enchant_barker = Enchantrix_GetShortDescriptor(enchant.index).." - ";
	if( p_gold > 0 ) then
		enchant_barker = enchant_barker..p_gold.._BARKLOC('OneLetterGold');
	end
	if( p_silver > 0 ) then
		enchant_barker = enchant_barker..p_silver.._BARKLOC('OneLetterSilver');
	end
	--enchant_barker = enchant_barker..", ";
	return enchant_barker
end

function EnchantrixBarker_GetItemCategoryString( index )

	local enchant = GetCraftInfo( index );

	for key,category in pairs(categories) do
		--Barker.Util.DebugPrintQuick( "cat key: ", key);
		if( enchant:find(category.search ) ~= nil ) then
			--Barker.Util.DebugPrintQuick( "cat key: ", key, ", name: ", category.print, ", enchant: ", enchant );
			return category.print;
		end
	end

	Barker.Util.DebugPrintQuick("Unknown category for", enchant )

	return 'Unknown';
end

function EnchantrixBarker_GetItemCategoryKey( index )

	local enchant = GetCraftInfo( index );

	for key,category in pairs(categories) do
		--Barker.Util.ChatPrint( "cat key: "..key..", name: "..category );
		if( enchant:find(category.search ) ~= nil ) then
			return key;
		end
	end

	Barker.Util.DebugPrintQuick("Unknown category for", enchant )
	
	return 'Unknown';

end

function EnchantrixBarker_GetCraftDescription( index )
	return GetCraftDescription(index) or "";
end

function Enchantrix_GetShortDescriptor( index )
	local long_str = EnchantrixBarker_GetCraftDescription(index):lower();

	for index,attribute in ipairs(attributes) do
		if( long_str:find(attribute.search ) ~= nil ) then
			statvalue = long_str:sub(long_str:find('[0-9]+[^%%]'));
			statvalue = statvalue:sub(statvalue:find('[0-9]+'));
			return "+"..statvalue..' '..attribute.print;
		end
	end
	local enchant = Barker.Util.Split(GetCraftInfo(index), "-");

	return enchant[#enchant];
end

function EnchantrixBarker_GetEnchantStat( enchant )
	local index = enchant.index;
	local long_str = EnchantrixBarker_GetCraftDescription(index):lower();

	for index,attribute in ipairs(attributes) do
		if( long_str:find(attribute.search ) ~= nil ) then
			return attribute.key;
		end
	end
	local enchant = Barker.Util.Split(GetCraftInfo(index), "-");

	return enchant[#enchant];
end
