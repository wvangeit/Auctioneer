--[[
	Auctioneer - Item Suggest module
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

	This is an Auctioneer module that allows the added tooltip for suggesting
	what should be done with an item based on weights and skills set. This module is also
	used by other modules in Auctioneer.

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
		You have an implicit license to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]
if not AucAdvanced then return end

local libType, libName = "Util", "ItemSuggest"
local lib = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local aucPrint,decode,_,_,replicate,empty,get,set,default,debugPrint,fill,_TRANS = AucAdvanced.GetModuleLocals()

local GetAprPrice = AucAdvanced.Modules.Util.Appraiser.GetPrice
local cutRate = 0.05 -- "home" AH cut / broker fee. todo: Is it worth introducing a "neutral" AH option?
local LastLink, LastQuantity, LastSuggest, LastValue
local ConfigGUI, ConfigID
local SliderLast, SliderSpacer

local Suggestors = {}
local setupSliderSettings = {}

--[[ Library functions ]]--

function lib.GetName()
	return libName
end

--[[ Suggest:
	suggestion, value = lib.Suggest(hyperlink, quantity)
	hyperlink (string) itemlink
	quantity (number, default = 1) stack size
	--
	suggestion (string) key representing best suggestion
	value (floating point number) estimated value of best suggestion (includes quantity and bias)
]]--
function lib.Suggest(hyperlink, quantity)
	if not hyperlink then return end
	if not quantity then quantity = 1 end
	if hyperlink == LastLink and quantity == LastQuantity then
		return LastSuggest, LastValue
	end
	local bestsuggest, bestvalue = "Unknown", 0

	for key, data in pairs(Suggestors) do
		local value = data.suggestor(hyperlink, quantity)
		if value and value > 0 then
			if data.bias then
				local bias = get(data.bias)
				if bias then
					value = value * bias / 100
				end
			end
			if value > bestvalue then
				bestvalue = value
				bestsuggest = key
			end
		end
	end
	LastLink, LastQuantity, LastSuggest, LastValue = hyperlink, quantity, bestsuggest, bestvalue
	return bestsuggest, bestvalue
end
lib.itemsuggest = lib.Suggest -- compatibility

function lib.NewSuggest(key, valueFunc, biasSetting, options)
	if type(key) ~= "string" or type(valueFunc) ~= "function" or (options and type(options) ~= "table") then
		return nil, "Invalid parameter(s)"
	end
	if Suggestors[key] then
		return nil, "Key already exists"
	end
	local data = {
		key = key,
		suggestor = valueFunc,
	}
	Suggestors[key] = data
	if biasSetting then
		data.bias = biasSetting
	end
	if options then
		if not biasSetting then data.bias = options.bias end
		lib.SetSuggestText(key, options.text, options.textHex or options.textRed, options.textGreen, options.textBlue)
		if options.slider or options.sliderText or options.sliderTip then
			lib.SetBiasSlider(key, options.sliderText, options.sliderTip)
		end
		-- more options to be added later
	end
	return true
end

function lib.SetSuggestText(key, text, colR, colG, colB)
	local data = Suggestors[key]
	if not data then return end
	if type(text) ~= "string" then return end
	data.plaintext = text
	local hex
	if type(colR) == "string" and colR:match("^%x%x%x%x%x%x$") then -- exactly 6 hexadecimal digits
		hex = colR
	elseif type(colR) == "number" and type(colG) == "number" and type(colB) == "number" then
		if colR>=0 and colR<=1 and colG>=0 and colG<=1 and colB>=0 and colB<=1 then
			hex = format("%02x%02x%02x", colR*255, colG*255, colB*255)
		end
	end
	if hex then
		data.displaytext = format("|cff%s%s|r", hex, text)
	end
	return true
end

--[[ GetSuggestText
	text = lib.GetSuggestText(key, useCol)
	key (string, required) suggestor key value (e.g. value returned by lib.Suggest)
	useCol (boolean, optional) 'true' to include colour codes in the text
	--
	text (string) display text (Note: safe to concatenate; will *always* return a string)
]]--
function lib.GetSuggestText(key, useCol)
	local data = Suggestors[key]
	if data then
		return useCol and data.displaytext or data.plaintext or key
	end
	return "Unknown"
end

function lib.SetBiasSlider(key, sliderText, tipText)
	local data = Suggestors[key]
	if not data or not data.bias or data.slider then return end
	if not ConfigGUI then
		if data.setupslider then return end
		-- gui has not been created yet, pack up our settings for when it gets created
		data.setupslider = true
		tinsert(setupSliderSettings, {key, sliderText, tipText})
		return true
	end
	data.setupslider = nil

	-- sliderText is optional: we use a default template if not provided
	if not sliderText then
		-- this will be localized sometime; the localized string may contain the token '@d' in place of '%d'
		-- note that SetSuggestTest should have been called first (to set data.plaintext)
		sliderText = format("%s Bias @d", data.plaintext or key)
	end
	sliderText = sliderText:gsub("@d", "%%d")

	local oldLast = ConfigGUI:GetLast(ConfigID)
	ConfigGUI:SetLast(ConfigID, SliderLast)
	data.slider = ConfigGUI:AddControl(ConfigID, "WideSlider", 0, 2, data.bias, 0, 200, 1, sliderText)
	if tipText then
		ConfigGUI:AddTip(ConfigID, tipText)
	end
	SliderLast = ConfigGUI:GetLast(ConfigID)
	SliderSpacer:SetPoint("BOTTOM", SliderLast, "BOTTOM")
	ConfigGUI:SetLast(ConfigID, oldLast)

	return true
end

--[[ Built-in Suggestors ]]--

function lib.GetAppraiserValue(hyperlink, quantity) -- deprecated function: will be converted to an internal-only function in future
	local AppraiserValue = GetAprPrice(hyperlink) or 0
	AppraiserValue = AppraiserValue * quantity
	if (get("util.itemsuggest.includebrokerage")) then
		AppraiserValue = AppraiserValue * (1 - cutRate)
	end
	if (get("util.itemsuggest.includedeposit")) then
		local aadvdepcost = GetDepositCost(hyperlink, get("util.itemsuggest.deplength"), nil, quantity) or 0
		AppraiserValue = AppraiserValue - aadvdepcost * get("util.itemsuggest.relisttimes")
	end

	return AppraiserValue
end

function lib.GetDisenchantValue(hyperlink, quantity) -- deprecated function
	if not (Enchantrix and Enchantrix.Storage) then return end
	local _, _, iQual, iLevel = GetItemInfo(hyperlink)
	if not iQual or iQual <= 1 or not iLevel then return end

	local skillneeded = Enchantrix.Util.DisenchantSkillRequiredForItemLevel(iLevel, iQual)
	if skillneeded > get("util.itemsuggest.enchantskill") then return end

	local _, _, _, market = Enchantrix.Storage.GetItemDisenchantTotals(hyperlink)
	if not market or market == 0 then return end

	if (get("util.itemsuggest.includebrokerage")) then
		market = market * (1 - cutRate)
	end

	return market * quantity -- quantity may be more than 1 when mousing over Appraiser
end

function lib.GetProspectValue(hyperlink, quantity) -- deprecated function
	if not Enchantrix then return end
	local jcSkillRequired = Enchantrix.Util.JewelCraftSkillRequiredForItem(hyperlink)
	if not jcSkillRequired or jcSkillRequired > get("util.itemsuggest.jewelcraftskill")  then
		return
	end
	local prospects = Enchantrix.Storage.GetItemProspects(hyperlink)
	if not prospects then return end

	local marketTotal, depositTotal = 0, 0
	local depositAucLength, depositRelistTimes
	local includeDeposit = get("util.itemsuggest.includedeposit")
	if includeDeposit then
		depositAucLength = get("util.itemsuggest.deplength")
		depositRelistTimes = get("util.itemsuggest.relisttimes")
	end

	for result, yield in pairs(prospects) do
		-- adjust for stack size
		yield = yield * quantity / 5

		-- fetch value of each result from Enchantrix
		local _, _, _, market = Enchantrix.Util.GetReagentPrice(result)
		market = market or 0 -- treat nil value as 0
		marketTotal = marketTotal + market * yield

		-- calculate deposit for each result
		if includeDeposit then
			local aadvdepcost = GetDepositCost(result, depositAucLength, nil, nil) or 0
			depositTotal = depositTotal + aadvdepcost * yield * depositRelistTimes
		end
	end

	-- Adjustments
	if get("util.itemsuggest.includebrokerage") then -- Auction House cut
		marketTotal = marketTotal * (1 - cutRate)
	end
	marketTotal = marketTotal - depositTotal

	return marketTotal
end

function lib.GetMillingValue(hyperlink, quantity) -- deprecated function
	if not Enchantrix then return end
	local insSkillRequired = Enchantrix.Util.InscriptionSkillRequiredForItem(hyperlink)
	if not insSkillRequired or insSkillRequired > get("util.itemsuggest.inscriptionskill")  then
		return
	end
	local pigments = Enchantrix.Storage.GetItemMilling(hyperlink)
	if not pigments then return end

	local marketTotal, depositTotal = 0, 0
	local depositAucLength, depositRelistTimes
	local includeDeposit = get("util.itemsuggest.includedeposit")
	if includeDeposit then
		depositAucLength = get("util.itemsuggest.deplength")
		depositRelistTimes = get("util.itemsuggest.relisttimes")
	end

	for result, yield in pairs(pigments) do
		-- adjust for stack size
		yield = yield * quantity / 5

		-- fetch value of each result from Enchantrix
		local _, _, _, market = Enchantrix.Util.GetReagentPrice(result)
		market = market or 0 -- treat nil value as 0
		marketTotal = marketTotal + market * yield

		-- calculate deposit for each result
		if includeDeposit then
			local aadvdepcost = GetDepositCost(result, depositAucLength, nil, nil) or 0
			depositTotal = depositTotal + aadvdepcost * yield * depositRelistTimes
		end
	end

	-- Adjustments
	if get("util.itemsuggest.includebrokerage") then -- Auction House cut
		marketTotal = marketTotal * (1 - cutRate)
	end
	marketTotal = marketTotal - depositTotal

	return marketTotal
end

local findConvertable = {}
do -- build table for Converter-suggest
	-- Copied and modified from SearcherConverter.lua
	-- todo: possibly modify SearchUI to export its table, and reuse the same table here?
	-- Set our constants
	--Essences
	local GCELESTIAL = 52719
	local LCELESTIAL = 52718
	local GCOSMIC = 34055
	local GPLANAR = 22446
	local GETERNAL = 16203
	local GNETHER = 11175
	local GMYSTIC = 11135
	local GASTRAL = 11082
	local GMAGIC = 10939
	local LCOSMIC = 34056
	local LPLANAR = 22447
	local LETERNAL = 16202
	local LNETHER = 11174
	local LMYSTIC = 11134
	local LASTRAL = 10998
	local LMAGIC = 10938
	--Motes/Primals
	local PAIR = 22451
	local MAIR = 22572
	local PEARTH= 22452
	local MEARTH = 22573
	local PFIRE = 21884
	local MFIRE = 22574
	local PLIFE = 21886
	local MLIFE = 22575
	local PMANA = 22457
	local MMANA = 22576
	local PSHADOW = 22456
	local MSHADOW = 22577
	local PWATER = 21885
	local MWATER = 22578
	--Crystallized/Eternal
	local CAIR = 37700
	local EAIR = 35623
	local CEARTH = 37701
	local EEARTH = 35624
	local CSHADOW = 37703
	local ESHADOW = 35627
	local CLIFE = 37704
	local ELIFE = 35625
	local CFIRE = 37702
	local EFIRE = 36860
	local CWATER = 37705
	local EWATER = 35622
	--Depleted items
	local DCBRACER = 32676 -- Depleted Cloth Bracers
	local DCBRACERTO = 32655 -- Crystalweave Bracers
	local DMGAUNTLETS = 32675 -- Depleted Mail Gauntlets
	local DMGAUNTLETSTO = 32656 -- Crystalhide Handwraps
	local DBADGE = 32672 -- Depleted Badge
	local DBADGETO = 32658 -- Badge of Tenacity
	local DCLOAK = 32677 -- Depleted Cloak
	local DCLOAKTO = 32665 -- Crystalweave Cape
	local DDAGGER = 32673 -- Depleted Dagger
	local DDAGGERTO = 32659	-- Crystal-Infused Shiv
	local DMACE = 32671 -- Depleted Mace
	local DMACETO = 32661 -- Apexis Crystal Mace
	local DRING = 32678 -- Depleted Ring
	local DRINGTO = 32664 -- Dreamcrystal Band
	local DSTAFF = 32679 -- Depleted Staff
	local DSTAFFTO = 32662 -- Flaming Quartz Staff
	local DSWORD = 32674 -- Depleted Sword
	local DSWORDTO = 32660 -- Crystalforged Sword
	local DTHAXE = 32670 -- Depleted Two-Handed Axe
	local DTHAXETO = 32663 -- Apexis Cleaver

	-- Temporary tables to help build the working table
	-- To add new conversions, edit these tables

	-- TWO WAY Tables

	local lesser_greater = {
		[LCELESTIAL] = GCELESTIAL,
		[LCOSMIC] = GCOSMIC,
		[LPLANAR] = GPLANAR,
		[LETERNAL] = GETERNAL,
		[LNETHER] = GNETHER,
		[LMYSTIC] = GMYSTIC,
		[LASTRAL] = GASTRAL,
		[LMAGIC] = GMAGIC,
	}
	local crystallized_eternal = {
		[CAIR] = EAIR,
		[CEARTH] = EEARTH,
		[CSHADOW] = ESHADOW,
		[CLIFE] = ELIFE,
		[CFIRE] = EFIRE,
		[CWATER] = EWATER,
	}

	-- ONE WAY Tables

	local mote2primal = {
		[MAIR] = PAIR,
		[MEARTH] = PEARTH,
		[MFIRE] = PFIRE,
		[MLIFE] = PLIFE,
		[MMANA] = PMANA,
		[MSHADOW] = PSHADOW,
		[MWATER] = PWATER,
	}
	local depleted2enhanced = {
		[DCBRACER] = DCBRACERTO,
		[DMGAUNTLETS] = DMGAUNTLETSTO,
		[DBADGE] = DBADGETO,
		[DCLOAK] = DCLOAKTO,
		[DDAGGER] = DDAGGERTO,
		[DMACE] = DMACETO,
		[DRING] = DRINGTO,
		[DSTAFF] = DSTAFFTO,
		[DSWORD] = DSWORDTO,
		[DTHAXE] = DTHAXETO,
	}

	-- Build the table
	-- ItemSuggest version
	-- Two-way
	for idl, idg in pairs (lesser_greater) do
		findConvertable[idl] = {idg, 1/3}
		findConvertable[idg] = {idl, 3}
	end
	for idc, ide in pairs (crystallized_eternal) do
		findConvertable[idc] = {ide, 0.1}
		findConvertable[ide] = {idc, 10}
	end
	-- One-way
	for id, idto in pairs (mote2primal) do
		findConvertable[id] = {idto, 0.1}
	end
	for id, idto in pairs (depleted2enhanced) do
		findConvertable[id] = {idto, 1}
	end
end

function lib.GetConvertValue (hyperlink, quantity) -- deprecated function
	-- assume type(hyperlink) == "string" in all cases... if not, insert test here
	local id = tonumber(strmatch(hyperlink, "item:(%d+):"))
	local convert = findConvertable[id]
	if not convert then return end

	id = convert[1] -- id of item we can convert to

	local market = GetAprPrice(id) or 0
	market = market * quantity
	if (get("util.itemsuggest.includebrokerage")) then
		market = market * (1 - cutRate)
	end
	if (get("util.itemsuggest.includedeposit")) then
		local aadvdepcost = GetDepositCost(id, get("util.itemsuggest.deplength"), nil, quantity) or 0
		market = market - aadvdepcost * get("util.itemsuggest.relisttimes")
	end

	-- Adjust for yield
	market = market * convert[2]

	return market
end

function lib.GetVendorValue(hyperlink, quantity) -- deprecated function
	local VendorValue = GetSellValue and GetSellValue(hyperlink) or 0
	VendorValue = VendorValue * quantity
return VendorValue end

--[[ Setup functions and Event Handlers ]]--

lib.NewSuggest("Auction", lib.GetAppraiserValue, "util.itemsuggest.auctionweight")
lib.NewSuggest("Disenchant", lib.GetDisenchantValue, "util.itemsuggest.disenchantweight")
lib.NewSuggest("Prospect", lib.GetProspectValue, "util.itemsuggest.prospectweight")
lib.NewSuggest("Mill", lib.GetMillingValue, "util.itemsuggest.millingweight")
lib.NewSuggest("Convert", lib.GetConvertValue, "util.itemsuggest.convertweight")
lib.NewSuggest("Vendor", lib.GetVendorValue, "util.itemsuggest.vendorweight")

local function OnLoadRunOnce()
	OnLoadRunOnce = nil

	default("util.itemsuggest.enablett", 1) --Enables Item Suggest from Item AI to be displayed in tooltip
	default("util.itemsuggest.enchantskill", 525) -- Used for item AI
	default("util.itemsuggest.jewelcraftskill", 525)-- Used for item AI
	default("util.itemsuggest.inscriptionskill", 525)-- Used for item AI
	default("util.itemsuggest.vendorweight", 100)-- Used for item AI
	default("util.itemsuggest.auctionweight", 100)-- Used for item AI
	default("util.itemsuggest.prospectweight", 100)-- Used for item AI
	default("util.itemsuggest.millingweight", 100)-- Used for item AI
	default("util.itemsuggest.disenchantweight", 100)-- Used for item AI
	default("util.itemsuggest.convertweight", 100)-- Used for item AI
	default("util.itemsuggest.relisttimes", 1)-- Used for item AI
	default("util.itemsuggest.includebrokerage", 1)-- Used for item AI
	default("util.itemsuggest.includedeposit", 1)-- Used for item AI
	default("util.itemsuggest.deplength", 48)
	default("util.itemsuggest.usecolour", true)

	lib.SetSuggestText("Auction", "Auction", "1fff00") -- green
	lib.SetBiasSlider("Auction", nil, "Weight ItemSuggest recommendations for auction resale higher or lower.")
	lib.SetSuggestText("Disenchant", "Disenchant", "ffff00") -- yellow
	lib.SetBiasSlider("Disenchant", nil, "Weight ItemSuggest recommendations for Disenchanting higher or lower.")
	lib.SetSuggestText("Prospect", "Prospect", "ffff00") -- yellow
	lib.SetBiasSlider("Prospect", nil, "Weight ItemSuggest recommendations for Prospecting higher or lower.")
	lib.SetSuggestText("Mill", "Mill", "ffff00") -- yellow
	lib.SetBiasSlider("Mill", nil, "Weight ItemSuggest recommendations for Milling higher or lower.")
	lib.SetSuggestText("Convert", "Convert", "007fee") -- blue
	lib.SetBiasSlider("Convert", nil, "Weight ItemSuggest recommendations for Conversion higher or lower.")
	lib.SetSuggestText("Vendor", "Vendor", "9d9d9d") -- grey
	lib.SetBiasSlider("Vendor", nil, "Weight ItemSuggest recommendations for vendor resale higher or lower.")
end

local function SetupConfigGui(gui)
	SetupConfigGui = nil
	local id = gui:AddTab(libName)
	ConfigGUI, ConfigID = gui, id
	gui:MakeScrollable(id)

	gui:AddHelp(id, "what itemsuggest",
        "What is the ItemSuggest module?",
        "ItemSuggest adds a tooltip line that suggests whether or not to auction, vendor, disenchant, prospect, mill or convert that item.")

	gui:AddControl(id, "Header", 0, "ItemSuggest Options")
	gui:AddControl(id, "Checkbox", 0, 1, "util.itemsuggest.enablett", "Display ItemSuggest tooltips")
	gui:AddTip(id,  "If enabled, will show ItemSuggest tooltip information.")
	gui:AddControl(id, "Checkbox", 0, 2, "util.itemsuggest.usecolour", "Use colours in tooltip")
	gui:AddTip(id, "Set whether the tooltip will display different colour text for the different suggestions.")

	gui:AddControl(id, "Header", 0, "ItemSuggest Recommendation Bias")
	SliderLast = gui:GetLast(id) -- bias sliders will be inserted at this point
	SliderSpacer = gui:AddControl(id, "Note", 0 ,0 ,0, "") -- invisible control used to correctly space controls following the sliders

    gui:AddControl(id, "Header", 0, "Skill usage Limits")
	gui:AddControl(id, "WideSlider", 0, 2, "util.itemsuggest.enchantskill", 25, 525, 25, "Max Enchanting Skill On Realm: %s")
	gui:AddTip(id, "Set ItemSuggest limits based upon Enchanting skill for your characters on this realm.")
	gui:AddControl(id, "WideSlider", 0, 2, "util.itemsuggest.jewelcraftskill", 25, 525, 25, "Max JewelCrafting Skill On Realm: %s")
	gui:AddTip(id, "Set ItemSuggest limits based upon Jewelcrafting skill for your characters on this realm.")
	gui:AddControl(id, "WideSlider", 0, 2, "util.itemsuggest.inscriptionskill", 25, 525, 25, "Max Inscription Skill On Realm: %s")
	gui:AddTip(id, "Set ItemSuggest limits based upon Inscription skill for your characters on this realm.")

	gui:AddControl(id, "Header", 0, "Deposit cost influence")
	gui:AddControl(id, "Checkbox", 0, 1, "util.itemsuggest.includedeposit", "Include deposit costs")
	gui:AddTip(id, "Set whether or not to include Auction House deposit costs as part of ItemSuggest tooltip calculations.")
	gui:AddControl(id, "Selectbox", 0, 1, AucAdvanced.selectorAuctionLength, "util.itemsuggest.deplength", "Base deposits on what length of auction.")
	gui:AddTip(id, "If Auction House deposit costs are included, set the default Auction period used for purposes of calculating Auction House deposit costs.")
	gui:AddControl(id, "WideSlider", 0, 2, "util.itemsuggest.relisttimes", 1, 20, 0.1, "Average # of listings: %0.1fx")
	gui:AddTip(id, "Set the estimated average number of times an auction item is relisted.")
	gui:AddControl(id, "Checkbox", 0, 1, "util.itemsuggest.includebrokerage", "Include AH brokerage costs")
	gui:AddTip(id, "Set whether or not to include Auction House brokerage costs as part of ItemSuggest tooltip calculations.")

	for _, packed in ipairs(setupSliderSettings) do
		lib.SetBiasSlider(unpack(packed, 1, 3))
	end
	setupSliderSettings = nil
end

lib.Processors = {}
function lib.Processors.tooltip(callbackType, tooltip, name, hyperlink, quality, quantity, cost, additional)
	if (get("util.itemsuggest.enablett")) then
		local text = lib.GetSuggestText(lib.Suggest(hyperlink, quantity), get("util.itemsuggest.usecolour"))
		tooltip:AddLine(format("Suggestion: %s this item", text))
	end
end

function lib.Processors.config(callbackType, gui)
	if SetupConfigGui then SetupConfigGui(gui) end
end

function lib.Processors.configchanged()--(callbackType, ...)
	LastLink = nil -- only necessary to nil one of the 4 cache values
end
lib.Processors.scanstats = lib.Processors.configchanged

function lib.OnLoad()
	--aucPrint("AucAdvanced: {{"..libType..":"..libName.."}} loaded!")
	if OnLoadRunOnce then OnLoadRunOnce() end
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
