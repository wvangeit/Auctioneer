--[[

	Enchantrix v<%version%> (<%codename%>)
	$Id:  $

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
		along with this program(see GLP.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

]]

local priorityList = {};

local categories = {
    Bracer = {search = "Bracer", print = "Bracer" },
    Gloves = {search = "Gloves", print = "Gloves" },
    Boots = {search = "Boots", print = "Boots" },
    Shield = {search = "Shield", print = "Shield" },
    Chest = {search = "Chest", print = "Chest" },
    Cloak = {search = "Cloak", print = "Cloak" },
    TwoHanded = {search = "2H", print = "2H Weapon"},
    AnyWeapon = {search = "Enchant Weapon", print = "Any Weapon" }
};


local print_order = { 'Bracer', 'Gloves', 'Boots', 'Chest', 'Cloak', 'Shield', 'TwoHanded', 'AnyWeapon' };

local attributes = {
    'intellect',
    'stamina',
    'spirit',
    'strength',
    'agility',
    'fire resistance',
    'resistance',
    'all stats',
    'mana',
    'health',
    'additional armor',
    'additional points of armor',
    'increase armor',
    'absorption',
    'damage to beasts',
    'points? of damage',
    '\+[0-9]+ damage',
    'defense'
};

local short_attributes = {
    'INT',
    'STA',
    'SPI',
    'STR',
    'AGI',
    'fire res',
    'all res',
    'all stats',
    'mana',
    'health',
    'armour',
    'armour',
    'armour',
    'DMG absorb',
    'Beastslayer',
    'DMG',
    'DMG',
    'DEF'
};


local overall_category_priority = {
    item = {    
        factor = 0.4, 
        priorities = {
            AnyWeapon = 100,
            TwoHanded = 90,
            Bracer = 70,
            Gloves = 70,
            Boots = 70,
            Chest = 70, 
            Cloak = 70,
            Shield = 70 
        } 
    },
    stat = {
        factor = 0.4, 
        priorities = {
            INT = 90,
            DMG = 90,
            DEF = 60,
            STA = 70,
            AGI = 70,
            STR = 70,
            ["all stats"] = 75,
            ["all res"] = 55,
            armour = 65,
            SPI = 45,
            ["fire res"] = 85,
            mana = 35,
            health = 40,
            DEF = 40,
            other = 70
        } 
    },
    price = {factor = 0.2, priorities = nil },
    train = {factor = 0.1, priorities = nil } 
};

-- UI code


function EnchantrixBarker_OnEvent()
    --Enchantrix_ChatPrint("GotUIEvent...");
    
    if( event == "CRAFT_SHOW" ) then
        Enchantrix_BarkerButton:SetParent(CraftFrame);
        Enchantrix_BarkerButton:SetPoint("TOPRIGHT", CraftFrame, "TOPRIGHT", -40, -60 );
        Enchantrix_BarkerButton:Show();
        Enchantrix_BarkerButton.tooltipText = 'Posts a sales message to the Trade channel, if available.';
    
        Enchantrix_BarkerOptionsButton:SetParent(CraftFrame);
        Enchantrix_BarkerOptionsButton:SetPoint("BOTTOMRIGHT", Enchantrix_BarkerButton, "BOTTOMLEFT");
        Enchantrix_BarkerOptionsButton:Show();
        Enchantrix_BarkerButton.tooltipText = 'Opens the barker options window.';
        UpdateItemPriorities();
    elseif( event == "CRAFT_CLOSE" )then
        Enchantrix_BarkerButton:Hide();
        Enchantrix_BarkerOptionsButton:Hide();
        Enchantrix_BarkerOptions_Frame:Hide();
    end
        
end

function Enchantrix_BarkerOptions_OnShow()
    Enchantrix_BarkerOptions_ShowFrame(1);
end

function Enchantrix_BarkerOnClick()
    --Enchantrix_ChatPrint(Enchantrix_CreateBarker());
    barker = Enchantrix_CreateBarker();
    
    if barker ~= nil then
        SendChatMessage(barker,"CHANNEL", this.language,"2");
    else
        Enchantrix_ChatPrint("Enchantrix: You aren't in a trade zone or you have no enchants available.");
    end
end


function EnchantrixBarker_OnLoad()
    Enchantrix_ChatPrint("Barker Loaded...");
    if( not EnchantConfig.barker ) then
        EnchantConfig.barker = {};
    end    
    --EnchantConfig.barker = EnchantConfig.barker;
    if( not EnchantConfig.barker.profit_margin ) then
        EnchantConfig.barker.profit_margin = 0.1;
    end    
    if( not EnchantConfig.barker.randomise ) then
        EnchantConfig.barker.randomise = 0.1;
    end    
    if( not EnchantConfig.barker.lowest_price ) then
        EnchantConfig.barker.lowest_price = 100;
    end    
    UpdateItemPriorities();

end
    


local config_defaults = {
    lowest_price = 5000,
    sweet_price = 50000,
    high_price = 500000,
    profit_margin = 0.1,
    highest_profit = 100000,
    randomise = 0.1,
    item_anyweapon = 100,
    item_twohander = 90,
    item_bracer = 70,
    item_gloves = 70,
    item_boots = 70,
    item_chest = 70, 
    item_cloak = 70,
    item_shield = 70 
    
};

function Enchantrix_BarkerGetConfig( key )
    if( not EnchantConfig.barker ) then
        EnchantConfig.barker = {};
    end    
    config = EnchantConfig.barker;
    
    if( not config[key] ) then
        config[key] = config_defaults[key];
    end
    --Enchantrix_ChatPrint("Getting config: "..key.." - "..config[key]);
    
    return config[key];
end

function Enchantrix_BarkerSetConfig( key, value )
    --Enchantrix_ChatPrint("Setting config: "..key.." - "..value);
    if( not EnchantConfig.barker ) then
        EnchantConfig.barker = {};
    end    
    config = EnchantConfig.barker;

    config[key] = value;
end

function Enchantrix_BarkerOptions_TestButton_OnClick()
    barker = Enchantrix_CreateBarker();
    
    if barker ~= nil then
        Enchantrix_ChatPrint(barker);
    else
        Enchantrix_ChatPrint("Enchantrix: You aren't in a trade zone or you have no enchants available.");
    end
end


function Enchantrix_BarkerOptions_ProfitSlider_GetValue()
    return Enchantrix_BarkerGetConfig("profit_margin")*100;
end
function Enchantrix_BarkerOptions_ProfitSlider_OnValueChanged()
    Enchantrix_BarkerSetConfig("profit_margin", this:GetValue()/100);
end

function Enchantrix_BarkerOptions_HighestProfitSlider_GetValue()
    return Enchantrix_BarkerGetConfig("highest_profit");
end
function Enchantrix_BarkerOptions_HighestProfitSlider_OnValueChanged()
    Enchantrix_BarkerSetConfig("highest_profit", this:GetValue() );
end

function Enchantrix_BarkerOptions_RandomFactorSlider_GetValue()
    return Enchantrix_BarkerGetConfig("randomise")*100;
end
function Enchantrix_BarkerOptions_RandomFactorSlider_OnValueChanged()
    Enchantrix_BarkerSetConfig("randomise", this:GetValue()/100);
end

function Enchantrix_BarkerOptions_LowestPriceSlider_GetValue()
    return Enchantrix_BarkerGetConfig("lowest_price");
end

function Enchantrix_BarkerOptions_LowestPriceSlider_OnValueChanged()
    Enchantrix_BarkerSetConfig("lowest_price", this:GetValue());
end

function Enchantrix_BarkerOptions_PriceFactorSweetSlider_GetValue()
    return Enchantrix_BarkerGetConfig("sweet_price");
end

function Enchantrix_BarkerOptions_PriceFactorSweetSlider_OnValueChanged()
    Enchantrix_BarkerSetConfig("sweet_price", this:GetValue());
end

function Enchantrix_BarkerOptions_PriceFactorHighSlider_GetValue()
    return Enchantrix_BarkerGetConfig("high_price");
end

function Enchantrix_BarkerOptions_PriceFactorHighSlider_OnValueChanged()
    Enchantrix_BarkerSetConfig("high_price", this:GetValue());
end

function UpdateItemPriorities()
    overall_category_priority.item.priorities['TwoHander'] = Enchantrix_BarkerGetConfig("item_twohander");
    overall_category_priority.item.priorities['AnyWeapon'] = Enchantrix_BarkerGetConfig("item_anyweapon");
    overall_category_priority.item.priorities['Gloves'] = Enchantrix_BarkerGetConfig("item_gloves");
    overall_category_priority.item.priorities['Boots'] = Enchantrix_BarkerGetConfig("item_boots");
    overall_category_priority.item.priorities['Bracer'] = Enchantrix_BarkerGetConfig("item_bracer");
    overall_category_priority.item.priorities['Chest'] = Enchantrix_BarkerGetConfig("item_chest");
    overall_category_priority.item.priorities['Shield'] = Enchantrix_BarkerGetConfig("item_shield");
    overall_category_priority.item.priorities['Cloak'] = Enchantrix_BarkerGetConfig("item_cloak");
end

function Enchantrix_BarkerOptions_ItemFactors_TwoHandedSlider_GetValue()
    return Enchantrix_BarkerGetConfig("item_twohander");
end

function Enchantrix_BarkerOptions_ItemFactors_TwoHandedSlider_OnValueChanged()
    Enchantrix_BarkerSetConfig("item_twohander", this:GetValue());
    UpdateItemPriorities();
end

function Enchantrix_BarkerOptions_ItemFactors_AnyWeaponSlider_GetValue()
    return Enchantrix_BarkerGetConfig("item_anyweapon");
end

function Enchantrix_BarkerOptions_ItemFactors_AnyWeaponSlider_OnValueChanged()
    Enchantrix_BarkerSetConfig("item_anyweapon", this:GetValue());
    UpdateItemPriorities();
end

function Enchantrix_BarkerOptions_ItemFactors_BracerSlider_GetValue()
    return Enchantrix_BarkerGetConfig("item_bracer");
end

function Enchantrix_BarkerOptions_ItemFactors_BracerSlider_OnValueChanged()
    Enchantrix_BarkerSetConfig("item_bracer", this:GetValue());
    UpdateItemPriorities();
end

function Enchantrix_BarkerOptions_ItemFactors_GlovesSlider_GetValue()
    return Enchantrix_BarkerGetConfig("item_gloves");
end

function Enchantrix_BarkerOptions_ItemFactors_GlovesSlider_OnValueChanged()
    Enchantrix_BarkerSetConfig("item_gloves", this:GetValue());
    UpdateItemPriorities();
end

function Enchantrix_BarkerOptions_ItemFactors_BootsSlider_GetValue()
    return Enchantrix_BarkerGetConfig("item_boots");
end

function Enchantrix_BarkerOptions_ItemFactors_BootsSlider_OnValueChanged()
    Enchantrix_BarkerSetConfig("item_boots", this:GetValue());
    UpdateItemPriorities();
end

function Enchantrix_BarkerOptions_ItemFactors_ChestSlider_GetValue()
    return Enchantrix_BarkerGetConfig("item_chest");
end

function Enchantrix_BarkerOptions_ItemFactors_ChestSlider_OnValueChanged()
    Enchantrix_BarkerSetConfig("item_chest", this:GetValue());
    UpdateItemPriorities();
end

function Enchantrix_BarkerOptions_ItemFactors_ShieldSlider_GetValue()
    return Enchantrix_BarkerGetConfig("item_shield");
end

function Enchantrix_BarkerOptions_ItemFactors_ShieldSlider_OnValueChanged()
    Enchantrix_BarkerSetConfig("item_shield", this:GetValue());
    UpdateItemPriorities();
end

function Enchantrix_BarkerOptions_ItemFactors_CloakSlider_GetValue()
    return Enchantrix_BarkerGetConfig("item_cloak");
end

function Enchantrix_BarkerOptions_ItemFactors_CloakSlider_OnValueChanged()
    Enchantrix_BarkerSetConfig("item_cloak", this:GetValue());
    UpdateItemPriorities();
end



local tabframes = { 
    { 
        title = 'Profit and Price Priotities',
        options = {
            {
                name = 'Profit Margin',
                tooltip = 'The percentage profit to add to the base mats cost.',
                units = 'percentage',
                min = 0,
                max = 100,
                step = 1,
                getvalue = Enchantrix_BarkerOptions_ProfitSlider_GetValue,
                valuechanged = Enchantrix_BarkerOptions_ProfitSlider_OnValueChanged
            },
            {
                name = 'Highest Profit',
                tooltip = 'The highest total cash profit to make on an enchant.',
                units = 'money',
                min = 0,
                max = 250000,
                step = 500,
                getvalue = Enchantrix_BarkerOptions_HighestProfitSlider_GetValue,
                valuechanged = Enchantrix_BarkerOptions_HighestProfitSlider_OnValueChanged
            },
            {
                name = 'Random Factor',
                tooltip = 'The amount of randomness in the enchants chosen for the trade shout.',
                units = 'percentage',
                min = 0,
                max = 100,
                step = 1,
                getvalue = Enchantrix_BarkerOptions_RandomFactorSlider_GetValue,
                valuechanged = Enchantrix_BarkerOptions_RandomFactorSlider_OnValueChanged
            },
            {
                name = 'Lowest Price',
                tooltip = 'The lowest cash price to quote for an enchant.',
                units = 'money',
                min = 0,
                max = 50000,
                step = 500,
                getvalue = Enchantrix_BarkerOptions_LowestPriceSlider_GetValue,
                valuechanged = Enchantrix_BarkerOptions_LowestPriceSlider_OnValueChanged
            },
            {
                name = 'PriceFactor SweetSpot',
                tooltip = 'This is used to prioritise enchants near this price for advertising.',
                units = 'money',
                min = 0,
                max = 500000,
                step = 5000,
                getvalue = Enchantrix_BarkerOptions_PriceFactorSweetSlider_GetValue,
                valuechanged = Enchantrix_BarkerOptions_PriceFactorSweetSlider_OnValueChanged
            },
            {
                name = 'PriceFactor Highest',
                tooltip = 'Enchants receive a score of zero for price priority at or above this value.',
                units = 'money',
                min = 0,
                max = 1000000,
                step = 50000,
                getvalue = Enchantrix_BarkerOptions_PriceFactorHighSlider_GetValue,
                valuechanged = Enchantrix_BarkerOptions_PriceFactorHighSlider_OnValueChanged
            },
        }
    },
    { 
        title = 'Item Priorities',
        options = {
            {
                name = '2H Weapon',
                tooltip = 'The priority score for 2H weapon enchants.',
                units = 'percentage',
                min = 0,
                max = 100,
                step = 1,
                getvalue = Enchantrix_BarkerOptions_ItemFactors_TwoHandedSlider_GetValue,
                valuechanged = Enchantrix_BarkerOptions_ItemFactors_TwoHandedSlider_OnValueChanged
            },
            {
                name = 'Any Weapon',
                tooltip = 'The priority score for enchants to any weapon.',
                units = 'percentage',
                min = 0,
                max = 100,
                step = 1,
                getvalue = Enchantrix_BarkerOptions_ItemFactors_AnyWeaponSlider_GetValue,
                valuechanged = Enchantrix_BarkerOptions_ItemFactors_AnyWeaponSlider_OnValueChanged
            },
            {
                name = 'Bracer',
                tooltip = 'The priority score for bracer enchants.',
                units = 'percentage',
                min = 0,
                max = 100,
                step = 1,
                getvalue = Enchantrix_BarkerOptions_ItemFactors_BracerSlider_GetValue,
                valuechanged = Enchantrix_BarkerOptions_ItemFactors_BracerSlider_OnValueChanged
            },
            {
                name = 'Gloves',
                tooltip = 'The priority score for glove enchants.',
                units = 'percentage',
                min = 0,
                max = 100,
                step = 1,
                getvalue = Enchantrix_BarkerOptions_ItemFactors_GlovesSlider_GetValue,
                valuechanged = Enchantrix_BarkerOptions_ItemFactors_GlovesSlider_OnValueChanged
            },
            {
                name = 'Boots',
                tooltip = 'The priority score for boots enchants.',
                units = 'percentage',
                min = 0,
                max = 100,
                step = 1,
                getvalue = Enchantrix_BarkerOptions_ItemFactors_BootsSlider_GetValue,
                valuechanged = Enchantrix_BarkerOptions_ItemFactors_BootsSlider_OnValueChanged
            },
            {
                name = 'Chest',
                tooltip = 'The priority score for chest enchants.',
                units = 'percentage',
                min = 0,
                max = 100,
                step = 1,
                getvalue = Enchantrix_BarkerOptions_ItemFactors_ChestSlider_GetValue,
                valuechanged = Enchantrix_BarkerOptions_ItemFactors_ChestSlider_OnValueChanged
            },
            {
                name = 'Cloak',
                tooltip = 'The priority score for cloak enchants.',
                units = 'percentage',
                min = 0,
                max = 100,
                step = 1,
                getvalue = Enchantrix_BarkerOptions_ItemFactors_CloakSlider_GetValue,
                valuechanged = Enchantrix_BarkerOptions_ItemFactors_CloakSlider_OnValueChanged
            }
        }
    }
};

local active_tab = -1;

function EnchantrixBarker_OptionsSlider_OnValueChanged()
    if active_tab ~= -1 then
        --Enchantrix_ChatPrint( "Tab - Slider changed: "..active_tab..' - '..this:GetID() );
        tabframes[active_tab].options[this:GetID()].valuechanged();
        value = this:GetValue();
        --tabframes[active_tab].options[this:GetID()].getvalue();
        
        valuestr = EnchantrixBarker_OptionsSlider_GetTextFromValue( value, tabframes[active_tab].options[this:GetID()].units );
        
        getglobal(this:GetName().."Text"):SetText(tabframes[active_tab].options[this:GetID()].name.." - "..valuestr );
    end
end

function EnchantrixBarker_OptionsSlider_GetTextFromValue( value, units )
    
    valuestr = ''
    
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
    --Enchantrix_ChatPrint( "Clicked Tab: "..this:GetID() );
    Enchantrix_BarkerOptions_ShowFrame( this:GetID() )
        
end

function Enchantrix_BarkerOptions_ShowFrame( frame_index )
    active_tab = -1
    for index, frame in tabframes do
        if ( index == frame_index ) then
            --Enchantrix_ChatPrint( "Showing Frame: "..index );
            for i = 1,10 do
                slider = getglobal('EnchantrixBarker_OptionsSlider_'..i);
                slider:Hide();
            end
            for i, opt in frame.options do
                slidername = 'EnchantrixBarker_OptionsSlider_'..i
                slider = getglobal(slidername);
                slider:SetFrameLevel(Enchantrix_BarkerOptions_Frame:GetFrameLevel()+4);
                slider:SetMinMaxValues(opt.min, opt.max);
                slider:SetValueStep(opt.step);
                slider.tooltipText = opt.tooltip;
                getglobal(slidername.."High"):SetText();
                getglobal(slidername.."Low"):SetText();
                slider:Show();
            end
            active_tab = index
            for i, opt in frame.options do
                slidername = 'EnchantrixBarker_OptionsSlider_'..i
                slider = getglobal(slidername);
                slider:SetValue(opt.getvalue());
                getglobal(slidername.."Text"):SetText(opt.name..' - '..EnchantrixBarker_OptionsSlider_GetTextFromValue(slider:GetValue(),opt.units));
            end
        end
    end
end

function Enchantrix_BarkerOptions_OnClick()
    --Enchantrix_ChatPrint("You pressed the options button." );
    Enchantrix_BarkerOptions_Frame:SetParent(Enchantrix_BarkerOptionsButton);
    Enchantrix_BarkerOptions_Frame:SetPoint("TOPLEFT", CraftFrame, "TOPRIGHT");
    Enchantrix_BarkerOptions_Frame:Show();
    --ShowUIPanel(Enchantrix_BarkerOptions_Frame);
end


function Enchantrix_CheckButton_OnShow()
end
function Enchantrix_CheckButton_OnClick()
end
function Enchantrix_CheckButton_OnEnter()
end
function Enchantrix_CheckButton_OnLeave()
end


-- end UI code


function Enchantrix_CreateBarker()
    local availableEnchants = {};
    local numAvailable = 0;
    local temp = GetCraftSkillLine(1);
    if Enchantrix_BarkerGetZoneText() ~= nil then
        Enchantrix_ResetBarkerString();
        Enchantrix_ResetPriorityList();
        if (temp) then
            for i=0, GetNumCrafts(),1 do
                craftName, craftSubSpellName, craftType, numEnchantsAvailable, isExpanded = GetCraftInfo(i);
                if( ( numEnchantsAvailable > 0 ) and ( string.find( craftName, "Enchant" ) ~= nil ) ) then --have reagents and it is an enchant
                    --Enchantrix_ChatPrint(""..craftName, 0.8, 0.8, 0.2);
                    local cost = 0;
                    for j=1,GetCraftNumReagents(i),1 do
                        local a,b,c = GetCraftReagentInfo(i,j);
                        reagent = GetCraftReagentItemLink(i,j);
                        
                        --Enchantrix_ChatPrint("Adding: "..reagent.." - "..Enchantrix_GetReagentHSP(reagent).." x "..c.." = " ..(Enchantrix_GetReagentHSP(reagent)*c/10000));
                        cost = cost + (Enchantrix_GetReagentHSP(reagent)*c);
                    end
                    
                    local profit = cost * Enchantrix_BarkerGetConfig("profit_margin");
                    if( profit > Enchantrix_BarkerGetConfig("highest_profit") ) then
                        profit = Enchantrix_BarkerGetConfig("highest_profit");
                    end
                    local price = Enchantrix_RoundPrice(cost + profit);
                    
                    local enchant = {
                        index = i,
                        name = craftName,
                        type = craftType,
                        available = numEnchantsAvailable,
                        isExpanded = isExpanded,
                        cost = cost,
                        price = price,
                        profit = price - cost
                    };
                    availableEnchants[ numAvailable] = enchant;
                    
                    --Enchantrix_ChatPrint(GetCraftDescription(i));
                    --local p_gold,p_silver,p_copper = EnhTooltip.GetGSC(enchant.price);
                    --local pr_gold,pr_silver,pr_copper = EnhTooltip.GetGSC(enchant.profit);
                    --Enchantrix_ChatPrint("Price: "..p_gold.."."..p_silver.."g, profit: "..pr_gold.."."..pr_silver.."g");
                    
                    Enchantrix_AddEnchantToPriorityList( enchant )
                    --Enchantrix_ChatPrint( "numReagents: "..GetCraftNumReagents(i) );
                    numAvailable = numAvailable + 1;
                end
            end
            
            if numAvailable == 0 then
                return nil
            end
            
            for i,element in priorityList do
                --Enchantrix_ChatPrint(""..element.enchant.name, 0.8, 0.8, 0.2);
                Enchantrix_AddEnchantToBarker( element.enchant );
            end
            
            return Enchantrix_GetBarkerString();
            
        else
            Enchantrix_ChatPrint("Enchant Window not open");
        end
    end
    
    return nil
end



function Enchantrix_ScoreEnchantPriority( enchant )

    local score_item = 0;
    
    if( overall_category_priority.item.priorities[Enchantrix_GetItemCategoryKey(enchant.index)] ) then
        score_item = overall_category_priority.item.priorities[Enchantrix_GetItemCategoryKey(enchant.index)];
        score_item = score_item * overall_category_priority.item.factor;
    end

--Enchantrix_ChatPrint( "Item Key: "..Enchantrix_GetItemCategoryKey(enchant.index)..", Score: "..score_item);    
    local score_stat = 0;
    
    if( overall_category_priority.stat.priorities[Enchantrix_GetEnchantStat(enchant)] ) then
        score_stat = overall_category_priority.stat.priorities[Enchantrix_GetEnchantStat(enchant)];
    else
        score_stat = overall_category_priority.stat.priorities.other;
    end
        
    score_stat = score_stat * overall_category_priority.stat.factor;
        
    local score_price = 0;
    local price_score_floor = Enchantrix_BarkerGetConfig("sweet_price");
    local price_score_ceiling = Enchantrix_BarkerGetConfig("high_price");
    
    if enchant.price < price_score_floor then
        score_price = (price_score_floor - (price_score_floor - enchant.price))/price_score_floor * 100;
    elseif enchant.price < price_score_ceiling then
        range = (price_score_ceiling - price_score_floor);
        score_price = (range - (enchant.price - price_score_floor))/range * 100;
    end
    
    score_price = score_price * overall_category_priority.price.factor;
    score_total = (score_item + score_stat + score_price);
    
    return score_total * (1 - Enchantrix_BarkerGetConfig("randomise")) + math.random(300) * Enchantrix_BarkerGetConfig("randomise");
end

function Enchantrix_ResetPriorityList()
    priorityList = {};
end

function Enchantrix_AddEnchantToPriorityList(enchant)

    enchant_score = Enchantrix_ScoreEnchantPriority( enchant );

    for i,priorityentry in priorityList do
        if( priorityentry.score < enchant_score ) then
            table.insert( priorityList, i, {score = enchant_score, enchant = enchant} );
            return;
        end
    end
    
    table.insert( priorityList, {score = enchant_score, enchant = enchant} );
end


function Enchantrix_RoundPrice( price )

    
    if( price < 5000 ) then
        round = 1000;
    elseif ( price < 20000 ) then
        round = 2500;
    else
        round = 5000;
    end

    odd = math.mod(price,round);
    
    price = price + (round - odd);
    
    if( price < Enchantrix_BarkerGetConfig("lowest_price") ) then
        price = Enchantrix_BarkerGetConfig("lowest_price");
    end
    
    return price
end

function Enchantrix_GetReagentHSP( itemLink )

    local itemID = Enchantrix_BreakLink(itemLink);
    local itemKey = string.format("%s:0:0", itemID);
				

    -- Work out what version if any of auctioneer is installed
    local auctVerStr;
    if (not Auctioneer) then
        auctVerStr = AUCTIONEER_VERSION or "0.0.0";
    else
        auctVerStr = AUCTIONEER_VERSION or Auctioneer.Version or "0.0.0";
    end
    local auctVer = Enchantrix_Split(auctVerStr, ".");
    local major = tonumber(auctVer[1]) or 0;
    local minor = tonumber(auctVer[2]) or 0;
    local rev = tonumber(auctVer[3]) or 0;
    if (auctVer[3] == "DEV") then rev = 0; minor = minor + 1; end
    local hsp = nil;
    
    if (major == 3 and minor == 0 and rev <= 11) then
        --Enchantrix_ChatPrint("Calling Auctioneer_GetHighestSellablePriceForOne");
        
        if (rev == 11) then
            hsp = Auctioneer_GetHighestSellablePriceForOne(itemKey, false, Auctioneer_GetAuctionKey());
        else
            if (Auctioneer_GetHighestSellablePriceForOne) then
                hsp = Auctioneer_GetHighestSellablePriceForOne(itemKey, false);
            elseif (getHighestSellablePriceForOne) then
                hsp = getHighestSellablePriceForOne(itemKey, false);
            end
        end
    elseif (major == 3 and (minor > 0 and minor <= 3) and (rev > 11 and rev < 675)) then
        --Enchantrix_ChatPrint("Calling GetHSP");
        hsp = Auctioneer_GetHSP(itemKey, Auctioneer_GetAuctionKey());
    elseif (major >= 3 and minor >= 3 and (rev >= 675 or rev == 0)) then
        --Enchantrix_ChatPrint("Calling Statistic.GetHSP");
        hsp = Auctioneer.Statistic.GetHSP(itemKey, Auctioneer.Util.GetAuctionKey());
    else
        Enchantrix_ChatPrint("Calling Nothing: "..major..", "..minor..", "..rev);
    end
    if hsp == nil then 
        hsp = 0; 
    end
    
    return hsp;
end

local barkerString = '';
local barkerCategories = {};

function Enchantrix_ResetBarkerString()
    barkerString = "("..Enchantrix_BarkerGetZoneText()..") Selling Enchants:";
    barkerCategories = {};
end

local short_location = {
    Orgrimmar = 'Org',
    ['Thunder Bluff'] = 'TB',
    Undercity = 'UC',
    ['Stormwind City'] = 'SW',
    Darnassus = 'Dar',
    ['City of Ironforge'] = 'IF'
};

function Enchantrix_BarkerGetZoneText()
    --Enchantrix_ChatPrint(GetZoneText());
    return short_location[GetZoneText()];
end

function Enchantrix_AddEnchantToBarker( enchant )

    currBarker = Enchantrix_GetBarkerString();
    
    category_key = Enchantrix_GetItemCategoryKey( enchant.index )
    category_string = "";
    test_category = {};
    if barkerCategories[ category_key ] then
        for i,element in barkerCategories[category_key] do
            --Enchantrix_ChatPrint("Inserting: "..i..", elem: "..element.index );
            table.insert(test_category, element);
        end
    end
    
    table.insert(test_category, enchant);
    
    category_string = Enchantrix_GetBarkerCategoryString( test_category );
    
    
    if string.len(currBarker) + string.len(category_string) > 255 then
        return false;
    end
    
    if not barkerCategories[ category_key ] then
       barkerCategories[ category_key ] = {}; 
    end
    
    table.insert( barkerCategories[ category_key ],enchant );
    
    return true;    
end


function Enchantrix_GetBarkerString()
    local barker = ""..barkerString;
    
    for index, key in print_order do
        if( barkerCategories[key] ) then
            barker = barker..Enchantrix_GetBarkerCategoryString( barkerCategories[key] )
        end
    end
    
    return barker;
end

function Enchantrix_GetBarkerCategoryString( barkerCategory )
    barkercat = ""
    barkercat = barkercat.." ["..Enchantrix_GetItemCategoryString(barkerCategory[1].index)..": "; 
    for j,enchant in barkerCategory do
        if( j > 1) then
            barkercat = barkercat..", "
        end
        barkercat = barkercat..Enchantrix_GetBarkerEnchantString(enchant);
    end
    barkercat = barkercat.."]"
   
    return barkercat
end

function Enchantrix_GetBarkerEnchantString( enchant )
    local p_gold,p_silver,p_copper = EnhTooltip.GetGSC(enchant.price);
    
    enchant_barker = Enchantrix_GetShortDescriptor(enchant.index).." - ";
    if( p_gold > 0 ) then
        enchant_barker = enchant_barker..p_gold.."g";
    end
    if( p_silver > 0 ) then
        enchant_barker = enchant_barker..p_silver.."s";
    end
    --enchant_barker = enchant_barker..", ";
    return enchant_barker    
end




function Enchantrix_GetItemCategoryString( index )
    
    local enchant = GetCraftInfo( index );
    
    for key,category in categories do
        --Enchantrix_ChatPrint( "cat key: "..key);
        if( string.find( enchant, category.search ) ~= nil ) then
            --Enchantrix_ChatPrint( "cat key: "..key..", name: "..category.print..", enchant: "..enchant );
            return category.print;
        end
    end
    
    return 'Unknown';
end

function Enchantrix_GetItemCategoryKey( index )
    
    local enchant = GetCraftInfo( index );
    
    for key,category in categories do
        --Enchantrix_ChatPrint( "cat key: "..key..", name: "..category );
        if( string.find( enchant, category.search ) ~= nil ) then
            return key;
        end
    end
    
    return 'Unknown';
    
end

function Enchantrix_GetShortDescriptor( index )
    local long_str = string.lower(GetCraftDescription(index))
    
    for index,attribute in attributes do
        if( string.find( long_str, attribute ) ~= nil ) then
            statvalue = string.sub(long_str ,string.find(long_str,'[0-9]+[^%%]'));
            statvalue = string.sub(statvalue ,string.find(statvalue,'[0-9]+'));
            return "+"..statvalue..' '..short_attributes[index];
        end
    end
    local enchant = Enchantrix_Split(GetCraftInfo(index), " - ");
		
    return enchant[table.getn(enchant)];
end

function Enchantrix_GetEnchantStat( enchant )
    local index = enchant.index;
    local long_str = string.lower(GetCraftDescription(index))
    
    for index,attribute in attributes do
        if( string.find( long_str, attribute ) ~= nil ) then
            return short_attributes[index];
        end
    end
    local enchant = Enchantrix_Split(GetCraftInfo(index), " - ");
		
    return enchant[table.getn(enchant)];
end
