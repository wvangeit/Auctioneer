
-- Create a new instance of our lib with our parent
local lib, parent, private = AucSearchUI.NewSearcher("Disenchant")
if not lib then return end
local print,decode,recycle,acquire,clone,scrub = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "Disenchant"
-- Set our defaults
default("disenchant.profit.min", 1)
default("disenchant.profit.pct", 50)
default("disenchant.level.custom", false)
default("disenchant.level.min", 0)
default("disenchant.level.max", 375)
default("disenchant.adjust.brokerage", true)
default("disenchant.allow.bid", true)
default("disenchant.allow.buy", true)

-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	-- Get our tab and populate it with our controls
	local id = gui:AddTab(lib.tabname, "Searches")

	gui:AddControl(id, "Header",     0,      "Disenchant search criteria")

	local last = gui:GetLast(id)
	
	gui:AddControl(id, "MoneyFramePinned",  0, 1, "disenchant.profit.min", 1, 99999999, "Minimum Profit")
	gui:AddControl(id, "Slider",            0, 1, "disenchant.profit.pct", 1, 100, .5, "Min Discount: %0.01f%%")
	gui:AddControl(id, "Checkbox",          0, 1, "disenchant.level.custom", "Use custom levels")
	gui:AddControl(id, "Slider",            0, 2, "disenchant.level.min", 0, 375, 25, "Minimum skill: %s")
	gui:AddControl(id, "Slider",            0, 2, "disenchant.level.max", 25, 375, 25, "Maximum skill: %s")
	
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.42, 1, "disenchant.allow.bid", "Allow Bids")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.56, 1, "disenchant.allow.buy", "Allow Buyouts")

	gui:AddControl(id, "Subhead",           0.42,    "Fees Adjustment")
	gui:AddControl(id, "Checkbox",          0.42, 1, "disenchant.adjust.brokerage", "Subtract auction fees")
	
	gui:AddControl(id, "Subhead",           0.42,    "Note:")
	gui:AddControl(id, "Note",              0.42, 1, 290, 30, "The \"Pct\" Column is \% of DE Value")
end

function lib.Search(item)
	if not (Enchantrix and Enchantrix.Storage) then
		return
	end
	if (not item[Const.BUYOUT]) or (item[Const.BUYOUT] == 0) then
		return
	end
	if item[Const.QUALITY] <= 1 then
		return
	end
	local market, _, pctstring
	local minskill = 0
	local maxskill = 375
	if get("disenchant.level.custom") then
		minskill = get("disenchant.level.min")
		maxskill = get("disenchant.level.max")
	else
		maxskill = Enchantrix.Util.GetUserEnchantingSkill()
	end
	local skillneeded = Enchantrix.Util.DisenchantSkillRequiredForItemLevel(item[Const.ILEVEL], item[Const.QUALITY])
	if (skillneeded < minskill) or (skillneeded > maxskill) then
		return
	end
	_, _, _, market = Enchantrix.Storage.GetItemDisenchantTotals(item[Const.LINK])
	if (not market) or (market == 0) then
		return
	end
	
	--adjust for brokerage costs
	local brokerage = get("disenchant.adjust.brokerage")
	
	if brokerage then
		market = market * 0.95
	end
	local pct = get("disenchant.profit.pct")
	local minprofit = get("disenchant.profit.min")
	local value = market * (100-pct) / 100
	if value > (market - minprofit) then
		value = market - minprofit
	end
	if get("disenchant.allow.buy") and (item[Const.BUYOUT] > 0) and (item[Const.BUYOUT] <= value) then
		if AucAdvanced.Modules.Util.PriceLevel then
			local level, _, r, g, b = AucAdvanced.Modules.Util.PriceLevel.CalcLevel(item[Const.LINK], item[Const.COUNT], item[Const.CURBID], item[Const.BUYOUT], market)
			if level then
				level = math.floor(level)
				r = r*255
				g = g*255
				b = b*255
				pctstring = string.format("|cff%06d|cff%02x%02x%02x"..level, level, r, g, b) -- first color code is to allow
			end
		end
		return "buy", market, pctstring
	elseif get("disenchant.allow.bid") and (item[Const.PRICE] <= value) then
		if AucAdvanced.Modules.Util.PriceLevel then
			local level, _, r, g, b = AucAdvanced.Modules.Util.PriceLevel.CalcLevel(item[Const.LINK], item[Const.COUNT], item[Const.CURBID], item[Const.CURBID], market)
			if level then
				level = math.floor(level)
				r = r*255
				g = g*255
				b = b*255
				pctstring = string.format("|cff%06d|cff%02x%02x%02x"..level, level, r, g, b) -- first color code is to allow
			end
		end
		return "bid", market, pctstring
	end
end

AucAdvanced.RegisterRevision("$URL: http://dev.norganna.org/auctioneer/trunk/Auc-Util-SearchUI/SearcherGeneral.lua $", "$Rev: 2531 $")