--[[
----  Informer
----  An addon for World of Warcraft that shows pertinent information about
----  an item in a tooltip when you hover over the item in the game.
----  <%version%>
----  $Id$
--]]

INFORMER_VERSION = "<%version%>"
if (INFORMER_VERSION == "<".."%version%>") then
	INFORMER_VERSION = "1.0.0.DEV"
end

-- GLOBAL FUNCTION PROTOTYPES:

local getItem--(itemID);     itemID is the first value in a blizzard hyperlink id
--                           this pattern would extract the id you need:
--                             "item:(%d+):%d+:%d+:%d+"



-- LOCAL FUNCTION PROTOTYPES:

local setSkills, setRequirements, setVendors, setDatabase
local tooltipHandler, getFilterVal, getFilter, setFilter
local getCatName, split

-- LOCAL VARIABLES

local self = {}
local InformerConfig = {}

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
};

-- FUNCTION DEFINITIONS

function split(str, at)
	local splut = {};

	if (type(str) ~= "string") then return nil end
	if (not str) then str = "" end
	if (not at)
		then table.insert(splut, str)
	else
		for n, c in string.gfind(str, '([^%'..at..']*)(%'..at..'?)') do
			table.insert(splut, n);
			if (c == '') then break end
		end
	end
	return splut;
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
		addition = " - ".._INFORMER["Addit"..additional]
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
		if (usedList) then
			for pos, userSkill in pairs(usedList) do
				skillName = self.skills[tonumber(userSkill)]
				localized = "Unknown"
				if (skillName) then
					localized = _INFORMER["Skill"..skillName]
				end
				if (usage == "") then
					usage = localized
				else
					usage = usage .. ", " .. localized
				end
			end
		end
		dataItem.usageText = usage
	end

	local reqSkill = 0
	local reqLevel = 0
	local skillsRequired = self.requirements[itemID]
	if (skillsRequired) then
		local skillSplit = split(skillsRequired, ":")
		reqSkill = skillSplit[1]
		reqLevel = skillSplit[2]
	end
	dataItem.isPlayerMade = (reqSkill ~= 0)
	dataItem.reqSkill = reqSkill
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
	Informer.SetSkills = nil -- Set only once
end

function setRequirements(requirements)
	self.requirements = requirements
	Informer.SetReqirements = nil -- Set only once
end

function setVendors(vendors)
	self.vendors = vendors
	Informer.SetVendors = nil -- Set only once
end

function setDatabase(database)
	self.database = database
	Informer.SetDatabase = nil -- Set only once
end


function setFilter(type, value)
	if (not InformerConfig.filters) then InformerConfig.filters = {} end
	InformerConfig.filters[type] = value
end

function getFilterVal(type, default)
	if (default == nil) then default = "on" end
	if (not InformerConfig.filters) then InformerConfig.filters = {} end
	local value = InformerConfig.filters[type]
	if (not value) then
		if (type == _INFORMER['CmdEmbed']) then return "off" end
		return default
	end
	return value
end

function getFilter(filter)
	value = getFilterVal(filter)
	if ((value == _INFORMER['CmdOn']) or (value == "on")) then return true
	elseif ((value == _INFORMER['CmdOff']) or (value == "off")) then return false end
	return true
end

local categories
function getCatName(catID)
	if (not categories) then categories = {GetAuctionItemClasses()} end
	for cat, name in categories do
		if (cat == catID) then return name end
	end
end

function tooltipHandler(frame, name, link, quality, count)
	local quant = 0
	local sell = 0
	local buy = 0
	local stacks = 1
	
	local itemID, randomProp, enchant, uniqID, lame = EnhTooltip.BreakLink(link)
	if (itemID > 0) and (Informer) then
		itemInfo = getItem(itemID)
	end
	if (itemInfo) then
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
	end

	local embedded = getFilter(_INFORMER['CmdEmbed'])

	if (getFilter(_INFORMER['ShowVendor'])) then
		if ((buy > 0) or (sell > 0)) then
			local bgsc = EnhTooltip.GetTextGSC(buy)
			local sgsc = EnhTooltip.GetTextGSC(sell)

			if (count and (count > 1)) then
				local bqgsc = EnhTooltip.GetTextGSC(buy*count)
				local sqgsc = EnhTooltip.GetTextGSC(sell*count)
				if (getFilter(_INFORMER['ShowVendorBuy'])) then
					EnhTooltip.AddLine(string.format(_INFORMER['FrmtInfoBuymult'], count, bgsc), buy*count, embedded)
					EnhTooltip.LineColor(0.8, 0.5, 0.1)
				end
				if (getFilter(_INFORMER['ShowVendorSell'])) then
					EnhTooltip.AddLine(string.format(_INFORMER['FrmtInfoSellmult'], count, sgsc), sell*count, embedded)
					EnhTooltip.LineColor(0.8, 0.5, 0.1)
				end
			else
				if (getFilter(_INFORMER['ShowVendorBuy'])) then
					EnhTooltip.AddLine(string.format(_INFORMER['FrmtInfoBuy']), buy, embedded)
					EnhTooltip.LineColor(0.8, 0.5, 0.1)
				end
				if (getFilter(_INFORMER['ShowVendorSell'])) then
					EnhTooltip.AddLine(string.format(_INFORMER['FrmtInfoSell']), sell, embedded)
					EnhTooltip.LineColor(0.8, 0.5, 0.1)
				end
			end
		end
	end

	if (getFilter(_INFORMER['ShowStack'])) then
		if (stacks > 1) then
			EnhTooltip.AddLine(string.format(_INFORMER['FrmtInfoStx'], stacks), nil, embedded)
		end
	end
	if (itemInfo and getFilter(_INFORMER['ShowMerchant'])) then
		if (itemInfo.vendors) then
			local merchantCount = table.getn(itemInfo.vendors);
			if (merchantCount > 0) then
				EnhTooltip.AddLine(string.format(_INFORMER['FrmtInfoMerchants'], merchantCount), nil, embed);
				EnhTooltip.LineColor(0.5, 0.8, 0.5)
			end
		end
	end
	if (itemInfo and getFilter(_INFORMER['ShowUsage'])) then
		local reagentInfo = ""
		if (itemInfo.classText) then
			reagentInfo = string.format(_INFORMER['FrmtInfoClass'], itemInfo.classText)
			EnhTooltip.AddLine(reagentInfo, nil, embedded)
			EnhTooltip.LineColor(0.6, 0.4, 0.8)
		end
		if (itemInfo.usageText) then
			reagentInfo = string.format(_INFORMER['FrmtInfoUse'], itemInfo.usageText)
			EnhTooltip.AddLine(reagentInfo, nil, embedded)
			EnhTooltip.LineColor(0.6, 0.4, 0.8)
		end
	end
	if (itemInfo and getFilter(_INFORMER['ShowQuest'])) then
		if (itemInfo.quests) then
			local questCount = table.getn(itemInfo.quests);
			if (questCount > 0) then
				EnhTooltip.AddLine(string.format(_INFORMER['FrmtInfoQuest'], questCount), nil, embed);
				EnhTooltip.LineColor(0.5, 0.5, 0.8)
			end
		end
	end
end

-- GLOBAL OBJECT

Informer = {
	version = INFORMER_VERSION,
	GetItem = getItem,

	-- These functions are only meant for internal use.
	SetSkills = setSkills,
	SetReqirements = setRequirements,
	SetVendors = setVendors,
	SetDatabase = setDatabase,
}


EnhTooltip.AddHook("tooltip", tooltipHandler, 120)

