--[[
----  Informant
----  An addon for World of Warcraft that shows pertinent information about
----  an item in a tooltip when you hover over the item in the game.
----  <%version%>
----  $Id$
--]]

INFORMANT_VERSION = "<%version%>"
if (INFORMANT_VERSION == "<".."%version%>") then
	INFORMANT_VERSION = "3.1.DEV"
end

-- GLOBAL FUNCTION PROTOTYPES:

local getItem--(itemID);     itemID is the first value in a blizzard hyperlink id
--                           this pattern would extract the id you need:
--                             "item:(%d+):%d+:%d+:%d+"



-- LOCAL FUNCTION PROTOTYPES:
local addLine          -- addLine(text, color)
local clear            -- clear()
local frameActive      -- frameActive(isActive)
local frameLoaded      -- frameLoaded()
local getCatName       -- getCatName(catID)
local getFilter        -- getFilter(filter)
local getFilterVal     -- getFilterVal(type, default)
local getItem          -- getItem(itemID)
local getRowCount      -- getRowCount()
local onLoad           -- onLoad()
local onQuit           -- onQuit()
local scrollUpdate     -- scrollUpdate(offset)
local setDatabase      -- setDatabase(database)
local setFilter        -- setFilter(type, value)
local setRequirements  -- setRequirements(requirements)
local setSkills        -- setSkills(skills)
local setVendors       -- setVendors(vendors)
local showHideInfo     -- showHideInfo()
local skillToName      -- skillToName(userSkill)
local split            -- split(str, at)
local tooltipHandler   -- tooltipHandler(funcVars, retVal, frame, name, link, quality, count, price)

-- LOCAL VARIABLES

local self = {}
local lines = {}
local itemInfo = nil

-- GLOBAL VARIABLES

InformantConfig = {}

-- LOCAL DEFINES

CLASS_TO_CATEGORY_MAP = {
	[2]  = 1,
	[4]  = 2,
	[1]  = 3,
	[0]  = 4,
	[7]  = 5,
	[6]  = 6,
	[11] = 7,
	[9]  = 8,
	[5]  = 9,
	[15] = 10,
}

-- FUNCTION DEFINITIONS

function split(str, at)
	local splut = {}

	if (type(str) ~= "string") then return nil end
	if (not str) then str = "" end
	if (not at)
		then table.insert(splut, str)
	else
		for n, c in string.gfind(str, '([^%'..at..']*)(%'..at..'?)') do
			table.insert(splut, n)
			if (c == '') then break end
		end
	end
	return splut
end

function skillToName(userSkill)
	local skillName = self.skills[tonumber(userSkill)]
	local localized = "Unknown"
	if (skillName) then
		if (_INFORMANT["Skill"..skillName]) then
			localized = _INFORMANT["Skill"..skillName]
		else
			localized = "Unknown:"..skillName
		end
	end
	return localized, skillName
end

function getItem(itemID)
	local baseData = self.database[itemID]
	if (not baseData) then return nil end

	local baseSplit = split(baseData, ":")
	local buy = tonumber(baseSplit[1])
	local sell = tonumber(baseSplit[2])
	local class = tonumber(baseSplit[3])
	local quality = tonumber(baseSplit[4])
	local stack = tonumber(baseSplit[5])
	local additional = baseSplit[6]
	local usedby = baseSplit[7]
	local quantity = baseSplit[8]
	local limited = baseSplit[9]
	local merchantlist = baseSplit[10]
	local cat = CLASS_TO_CATEGORY_MAP[class]

	local dataItem = {
		['buy'] = buy,
		['sell'] = sell,
		['class'] = class,
		['cat'] = cat,
		['quality'] = quality,
		['stack'] = stack,
		['additional'] = additional,
		['usedby'] = usedby,
		['quantity'] = quantity,
		['limited'] = limited,
	}

	local addition = ""
	if (additional ~= "") then
		addition = " - ".._INFORMANT["Addit"..additional]
	end
	local catName = getCatName(cat)
	if (not catName) then
		dataItem.classText = "Unknown"..addition
	else
		dataItem.classText = catName..addition
	end

	if (usedby ~= '') then
		local usedList = split(usedby, ",")
		local skillName, localized, localeString
		local usage = ""
		dataItem.usedList = {}
		if (usedList) then
			for pos, userSkill in pairs(usedList) do
				localized = skillToName(userSkill)
				if (usage == "") then
					usage = localized
				else
					usage = usage .. ", " .. localized
				end
				table.insert(dataItem.usedList, localized)
			end
		end
		dataItem.usageText = usage
	end

	local reqSkill = 0
	local reqLevel = 0
	local skillName = ""

	local skillsRequired = self.requirements[itemID]
	if (skillsRequired) then
		local skillSplit = split(skillsRequired, ":")
		reqSkill = skillSplit[1]
		reqLevel = skillSplit[2]
		skillName = skillToName(reqSkill)
	end

	dataItem.isPlayerMade = (reqSkill ~= 0)
	dataItem.reqSkill = reqSkill
	dataItem.reqSkillName = skillName
	dataItem.reqLevel = reqLevel

	if (merchantlist ~= '') then
		local merchList = split(merchantlist, ",")
		local vendName
		local vendList = {}
		if (merchList) then
			for pos, merchID in pairs(merchList) do
				vendName = self.vendors[tonumber(merchID)]
				if (vendName) then
					table.insert(vendList, vendName)
				end
			end
		end
		dataItem.vendors = vendList
	end

	return dataItem
end


function setSkills(skills)
	self.skills = skills
	Informant.SetSkills = nil -- Set only once
end

function setRequirements(requirements)
	self.requirements = requirements
	Informant.SetRequirements = nil -- Set only once
end

function setVendors(vendors)
	self.vendors = vendors
	Informant.SetVendors = nil -- Set only once
end

function setDatabase(database)
	self.database = database
	Informant.SetDatabase = nil -- Set only once
end


function setFilter(type, value)
	if (not InformantConfig.filters) then InformantConfig.filters = {} end
	InformantConfig.filters[type] = value
end

function getFilterVal(type, default)
	if (default == nil) then default = "on" end
	if (not InformantConfig.filters) then InformantConfig.filters = {} end
	local value = InformantConfig.filters[type]
	if (not value) then
		if (type == _INFORMANT['CmdEmbed']) then return "off" end
		return default
	end
	return value
end

function getFilter(filter)
	value = getFilterVal(filter)
	if ((value == _INFORMANT['CmdOn']) or (value == "on")) then return true
	elseif ((value == _INFORMANT['CmdOff']) or (value == "off")) then return false end
	return true
end

local categories
function getCatName(catID)
	if (not categories) then categories = {GetAuctionItemClasses()} end
	for cat, name in categories do
		if (cat == catID) then return name end
	end
end

function tooltipHandler(funcVars, retVal, frame, name, link, quality, count, price)
	local quant = 0
	local sell = 0
	local buy = 0
	local stacks = 1

	local itemID, randomProp, enchant, uniqID, lame = EnhTooltip.BreakLink(link)
	if (itemID > 0) and (Informant) then
		itemInfo = getItem(itemID)
	end
	if (not itemInfo) then return end
	
	itemInfo.itemName = name
	itemInfo.itemLink = link
	itemInfo.itemCount = count
	itemInfo.itemQuality = quality

	stacks = itemInfo.stack
	if (not stacks) then stacks = 1 end

	buy = tonumber(itemInfo.buy) or 0
	sell = tonumber(itemInfo.sell) or 0
	quant = tonumber(itemInfo.quantity) or 0

	if (quant == 0) and (sell > 0) then
		local ratio = buy / sell
		if ((ratio > 3) and (ratio < 6)) then
			quant = 1
		else
			ratio = buy / (sell * 5)
			if ((ratio > 3) and (ratio < 6)) then
				quant = 5
			end
		end
	end
	if (quant == 0) then quant = 1 end

	buy = buy/quant

	itemInfo.itemBuy = buy
	itemInfo.itemSell = sell
	itemInfo.itemQuant = quant

	local embedded = getFilter(_INFORMANT['CmdEmbed'])

	if (getFilter(_INFORMANT['ShowVendor'])) then
		if ((buy > 0) or (sell > 0)) then
			local bgsc = EnhTooltip.GetTextGSC(buy)
			local sgsc = EnhTooltip.GetTextGSC(sell)

			if (count and (count > 1)) then
				local bqgsc = EnhTooltip.GetTextGSC(buy*count)
				local sqgsc = EnhTooltip.GetTextGSC(sell*count)
				if (getFilter(_INFORMANT['ShowVendorBuy'])) then
					EnhTooltip.AddLine(string.format(_INFORMANT['FrmtInfoBuymult'], count, bgsc), buy*count, embedded)
					EnhTooltip.LineColor(0.8, 0.5, 0.1)
				end
				if (getFilter(_INFORMANT['ShowVendorSell'])) then
					EnhTooltip.AddLine(string.format(_INFORMANT['FrmtInfoSellmult'], count, sgsc), sell*count, embedded)
					EnhTooltip.LineColor(0.8, 0.5, 0.1)
				end
			else
				if (getFilter(_INFORMANT['ShowVendorBuy'])) then
					EnhTooltip.AddLine(string.format(_INFORMANT['FrmtInfoBuy']), buy, embedded)
					EnhTooltip.LineColor(0.8, 0.5, 0.1)
				end
				if (getFilter(_INFORMANT['ShowVendorSell'])) then
					EnhTooltip.AddLine(string.format(_INFORMANT['FrmtInfoSell']), sell, embedded)
					EnhTooltip.LineColor(0.8, 0.5, 0.1)
				end
			end
		end
	end

	if (getFilter(_INFORMANT['ShowStack'])) then
		if (stacks > 1) then
			EnhTooltip.AddLine(string.format(_INFORMANT['FrmtInfoStx'], stacks), nil, embedded)
		end
	end
	if (getFilter(_INFORMANT['ShowMerchant'])) then
		if (itemInfo.vendors) then
			local merchantCount = table.getn(itemInfo.vendors)
			if (merchantCount > 0) then
				EnhTooltip.AddLine(string.format(_INFORMANT['FrmtInfoMerchants'], merchantCount), nil, embed)
				EnhTooltip.LineColor(0.5, 0.8, 0.5)
			end
		end
	end
	if (getFilter(_INFORMANT['ShowUsage'])) then
		local reagentInfo = ""
		if (itemInfo.classText) then
			reagentInfo = string.format(_INFORMANT['FrmtInfoClass'], itemInfo.classText)
			EnhTooltip.AddLine(reagentInfo, nil, embedded)
			EnhTooltip.LineColor(0.6, 0.4, 0.8)
		end
		if (itemInfo.usageText) then
			reagentInfo = string.format(_INFORMANT['FrmtInfoUse'], itemInfo.usageText)
			EnhTooltip.AddLine(reagentInfo, nil, embedded)
			EnhTooltip.LineColor(0.6, 0.4, 0.8)
		end
	end
	if (getFilter(_INFORMANT['ShowQuest'])) then
		if (itemInfo.quests) then
			local questCount = table.getn(itemInfo.quests)
			if (questCount > 0) then
				EnhTooltip.AddLine(string.format(_INFORMANT['FrmtInfoQuest'], questCount), nil, embed)
				EnhTooltip.LineColor(0.5, 0.5, 0.8)
			end
		end
	end
end

function showHideInfo()
	if (InformantFrame:IsVisible()) then
		InformantFrame:Hide()
	elseif (itemInfo) then
		InformantFrameTitle:SetText(_INFORMANT['FrameTitle'])

		-- Woohoo! We need to provide any information we can from the item currently in itemInfo
		local quality = itemInfo.itemQuality or itemInfo.quality or 0

		local color = "ffffff"
		if (quality == 4) then color = "a335ee"
		elseif (quality == 3) then color = "0070dd"
		elseif (quality == 2) then color = "1eff00"
		elseif (quality == 0) then color = "9d9d9d"
		end

		clear()
		addLine(string.format(_INFORMANT['InfoHeader'], color, itemInfo.itemName))

		local buy = itemInfo.itemBuy or itemInfo.buy or 0
		local sell = itemInfo.itemSell or itemInfo.sell or 0
		local quant = itemInfo.itemQuant or itemInfo.quantity or 0
		local count = itemInfo.itemCount or 1

		if ((buy > 0) or (sell > 0)) then
			local bgsc = EnhTooltip.GetTextGSC(buy)
			local sgsc = EnhTooltip.GetTextGSC(sell)

			if (count and (count > 1)) then
				local bqgsc = EnhTooltip.GetTextGSC(buy*count)
				local sqgsc = EnhTooltip.GetTextGSC(sell*count)
				addLine(string.format(_INFORMANT['FrmtInfoBuymult'], count, bgsc)..": "..bqgsc, "ee8822")
				addLine(string.format(_INFORMANT['FrmtInfoSellmult'], count, sgsc)..": "..sqgsc, "ee8822")
			else
				addLine(string.format(_INFORMANT['FrmtInfoBuy'])..": "..bgsc, "ee8822")
				addLine(string.format(_INFORMANT['FrmtInfoSell'])..": "..sgsc, "ee8822")
			end
		end

		if (itemInfo.stack > 1) then
			addLine(string.format(_INFORMANT['FrmtInfoStx'], itemInfo.stack))
		end

		local reagentInfo = ""
		if (itemInfo.classText) then
			reagentInfo = string.format(_INFORMANT['FrmtInfoClass'], itemInfo.classText)
			addLine(reagentInfo, "aa66ee")
		end
		if (itemInfo.usageText) then
			reagentInfo = string.format(_INFORMANT['FrmtInfoUse'], itemInfo.usageText)
			addLine(reagentInfo, "aa66ee")
		end

		if (itemInfo.isPlayerMade) then
			addLine(string.format(_INFORMANT['InfoPlayerMade'], itemInfo.reqLevel, itemInfo.reqSkillName), "5060ff")
		end

		if (itemInfo.quests) then
			local questCount = table.getn(itemInfo.quests)
			if (questCount > 0) then
				addLine("")
				addLine(string.format(_INFORMANT['FrmtInfoQuest'], questCount), nil, embed)
				addLine(string.format(_INFORMANT['InfoQuestHeader'], questCount), "70ee90")
				local questName
				for pos, quest in itemInfo.quests do
					questName = getQuestName(quest)
					addLine(string.format(_INFORMANT['InfoQuestName'], quest), "80ee80")
				end
			end
		end

		if (itemInfo.vendors) then
			local vendorCount = table.getn(itemInfo.vendors)
			if (vendorCount > 0) then
				addLine("")
				addLine(string.format(_INFORMANT['InfoVendorHeader'], vendorCount), "ddff40")
				for pos, merchant in itemInfo.vendors do
					addLine(string.format(_INFORMANT['InfoVendorName'], merchant), "eeee40")
				end
			end
		end
		InformantFrame:Show()
	else
		clear()
		addLine(_INFORMANT['InfoNoItem'], "ff4010")
		InformantFrame:Show()
	end
end

function onQuit()
	if (not InformantConfig.position) then
		InformantConfig.position = { }
	end
	InformantConfig.position.x, InformantConfig.position.y = InformantFrame:GetCenter()
end

function onLoad()
	if (not InformantConfig) then InformantConfig = { } end

	InformantFrameTitle:SetText(_INFORMANT['FrameTitle'])

	if (InformantConfig.position) then
		InformantFrame:ClearAllPoints()
		InformantFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", InformantConfig.position.x, InformantConfig.position.y)
	end

	if (not InformantConfig.welcomed) then
		clear()
		addLine(_INFORMANT['Welcome'])
		InformantConfig.welcomed = true
	end

	Informant.InitCommands()
end

local function frameLoaded()
	Stubby.RegisterEventHook("PLAYER_LEAVING_WORLD", "Informant", onQuit)
	Stubby.RegisterFunctionHook("EnhTooltip.AddTooltip", 300, tooltipHandler)

	onLoad()

	-- Setup the default for stubby to always load (people can override this on a
	-- per toon basis)
	Stubby.SetConfig("Informant", "LoadType", "always", true)

	-- Register our temporary command hook with stubby
	Stubby.RegisterBootCode("Informant", "CommandHandler", [[
		local function cmdHandler(msg)
			local i,j, cmd, param = string.find(string.lower(msg), "^([^ ]+) (.+)$")
			if (not cmd) then cmd = string.lower(msg) end 
			if (not cmd) then cmd = "" end 
			if (not param) then param = "" end
			if (cmd == "load") then
				if (param == "") then
					Stubby.Print("Manually loading Informant...")
					LoadAddOn("Informant")
				elseif (param == "always") then
					Stubby.Print("Setting Informant to always load for this character")
					Stubby.SetConfig("Informant", "LoadType", param)
					LoadAddOn("Informant")
				elseif (param == "never") then
					Stubby.Print("Setting Informant to never load automatically for this character (you may still load manually)")
					Stubby.SetConfig("Informant", "LoadType", param)
				else
					Stubby.Print("Your command was not understood")
				end
			else
				Stubby.Print("Informant is currently not loaded.")
				Stubby.Print("  You may load it now by typing |cffffffff/informant load|r")
				Stubby.Print("  You may also set your loading preferences for this character by using the following commands:")
				Stubby.Print("  |cffffffff/informant load always|r - Informant will always load for this character")
				Stubby.Print("  |cffffffff/informant load never|r - Informant will never load automatically for this character (you may still load it manually)")
			end
		end
		SLASH_INFORMANT1 = "/informant"
		SLASH_INFORMANT2 = "/inform"
		SLASH_INFORMANT3 = "/info"
		SLASH_INFORMANT4 = "/inf"
		SlashCmdList["INFORMANT"] = cmdHandler
	]]);
	Stubby.RegisterBootCode("Informant", "Triggers", [[
		local loadType = Stubby.GetConfig("Informant", "LoadType")
		if (loadType == "always") then
			LoadAddOn("Informant")
		else
			Stubby.Print("]].._INFORMANT['MesgNotLoaded']..[[");
		end
	]]);
end

function frameActive(isActive)
	if (isActive) then
		scrollUpdate(0)
	end
end

function getRowCount()
	return table.getn(lines)
end

function scrollUpdate(offset)
	local numLines = getRowCount()
	if (numLines > 25) then
		if (not offset) then
			offset = FauxScrollFrame_GetOffset(InformantFrameScrollBar)
		else
			if (offset > numLines - 25) then offset = numLines - 25 end
			FauxScrollFrame_SetOffset(InformantFrameScrollBar, offset)
		end
	else
		offset = 0
	end
	local line
	for i=1, 25 do
		line = lines[i+offset]
		local f = getglobal("InformantFrameText"..i)
		if (line) then
			f:SetText(line)
			f:Show()
		else
			f:Hide()
		end
	end
	if (numLines > 25) then
		FauxScrollFrame_Update(InformantFrameScrollBar, numLines, 25, numLines)
		InformantFrameScrollBar:Show()
	else
		InformantFrameScrollBar:Hide()
	end
end

function addLine(text, color)
	if (type(text) == "table") then
		for pos, line in text do
			addLine(line, color)
		end
		return
	end

	if (not text) then
		table.insert(lines, "nil")
	elseif (color) then
		table.insert(lines, string.format("|cff%s%s|r", color, text))
	else
		table.insert(lines, text)
	end
	scrollUpdate()
end

function clear()
	lines = {}
	scrollUpdate()
end

-- GLOBAL OBJECT

Informant = {
	version = INFORMANT_VERSION,
	GetItem = getItem,
	GetRowCount = getRowCount,
	AddLine = addLine,
	Clear = clear,
	ShowHideInfo = showHideInfo,

	-- These functions are only meant for internal use.
	SetSkills = setSkills,
	SetRequirements = setRequirements,
	SetVendors = setVendors,
	SetDatabase = setDatabase,
	FrameActive = frameActive,
	FrameLoaded = frameLoaded,
	ScrollUpdate = scrollUpdate,
	GetFilter = getFilter,
	GetFilterVal = getFilterVal,
	SetFilter = setFilter
}

