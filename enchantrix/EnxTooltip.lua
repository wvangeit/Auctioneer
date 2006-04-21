--[[
	Enchantrix Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id: EnxUtil.lua 756 2006-03-18 23:09:49Z aradan $

	Tooltip functions.

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
--]]

-- Global functions
local addonLoaded	-- Enchantrix.Tooltip.AddonLoaded()
local tooltipFormat	-- Enchantrix.Tooltip.Format

-- Local functions
local itemTooltip
local enchantTooltip
local hookTooltip

-- Local function references
local _ENCH -- = Enchantrix.Locale.Localize

function addonLoaded()
	_ENCH = Enchantrix.Locale.Localize

	Stubby.RegisterFunctionHook("EnhTooltip.AddTooltip", 400, hookTooltip)
end

tooltipFormat = {
	currentFormat = "fancy",
	format = {
		["fancy"] = {
			-- counts = off
			['off'] = "  $conf% |q$name|r $rate",
			-- counts = on
			['on'] = "  $conf% |q$name|r $rate |e(B=$bcount L=$lcount)|r",
		},
		["default"] = {
			['off'] = "  $name: $prob% $rate",
			['on'] = "  $name: $prob% $rate |e(B=$bcount L=$lcount)|r",
		},
	},
	patterns = {
		-- Strings
		["$prob"]	= "",			-- Probability: "75"
		["$conf"]	= "",			-- Confidence interval: "<1", "72-78", ">99"
		["$count"]	= "",			-- Local + base counts: "51"
		["$lcount"] = "",			-- Local count: "13"
		["$bcount"] = "",			-- Base count: "38"
		["$name"]	= "",			-- Name: "Lesser Magic Essence"
		["$rate"]	= "",			-- Avg drop amount: "x1.5"
		-- Colors
		["|q"]		= "",			-- Quality color
		["|E"]		= "|cffcccc33",	-- Yellow ("Enchantrix" color)
		["|e"]		= "|cff7f7f00",	-- Dark yellow
		["|r"]		= "|r",			-- Reset color
	},
	SelectFormat = function(this, fmt)
		if this.format[fmt] then
			this.currentFormat = fmt
		else
			this.currentFormat = "default"
		end
	end,
	SetFormat = function(this, fmt, val, counts)
		if counts == nil then
			counts = Enchantrix.Config.GetFilter('counts')
		end
		if counts then
			this.format[fmt]['on'] = val
		else
			this.format[fmt]['off'] = val
		end
	end,
	GetFormat = function(this, fmt, counts)
		if not this.format[fmt] then return end
		if counts == nil then
			counts = Enchantrix.Config.GetFilter('counts')
		end
		if counts then
			return this.format[fmt]['on']
		else
			return this.format[fmt]['off']
		end
	end,
	GetString = function(this, counts)
		local line
		if counts == nil then
			counts = Enchantrix.Config.GetFilter('counts')
		end
		if counts then
			line = this.format[this.currentFormat]['on']
		else
			line = this.format[this.currentFormat]['off']
		end
		-- Replace patterns
		for pat, repl in pairs(this.patterns) do
			line = string.gsub(line, pat, repl or "")
		end
		return line
	end,
	SetPattern = function(this, pat, repl)
		this.patterns[pat] = repl
	end,
}

function itemTooltip(funcVars, retVal, frame, name, link, quality, count)
	local embed = Enchantrix.Config.GetFilter('embed');

	-- Check for disenchantable target
	local id = Enchantrix.Util.GetItemIdFromLink(link)
	if (not id or id == 0 or not Enchantrix.Util.IsDisenchantable(id)) then
		return
	end

	local disenchantsTo = Enchantrix.Storage.GetItemDisenchants(Enchantrix.Util.GetSigFromLink(link), name, true);

	-- Process the results
	local totals = disenchantsTo.totals;
	disenchantsTo.totals = nil;
	if (totals and totals.total > 0) then

		-- If it looks quirky, and we haven't disenchanted it, then ignore it...
		if (totals.iCount + totals.biCount < 1) then return; end

		-- Header
		local total = ""
		if (Enchantrix.Config.GetFilter('counts')) then
			total = string.format(" |cff7f7f00(%d)|r", totals.total)
		end
		EnhTooltip.AddLine(_ENCH('FrmtDisinto')..total, nil, embed);
		EnhTooltip.LineColor(0.8,0.8,0.2);

		local lines = {}
		for dSig, counts in pairs(disenchantsTo) do
			local p = (counts.biCount + counts.iCount) / totals.total
			local pmin, pmax = Enchantrix.Util.ConfidenceInterval(p, totals.total)

			-- Probabilities
			p, pmin, pmax = math.floor(p * 100 + 0.5), math.floor(pmin * 100 + 0.5), math.floor(pmax * 100 + 0.5)
			tooltipFormat:SetPattern("$prob", tostring(p))
			if pmin == 0 then
				tooltipFormat:SetPattern("$conf", "<"..max(pmax, 1))
			elseif pmax == 100 then
				tooltipFormat:SetPattern("$conf", ">"..min(pmin, 99))
			else
				if pmin ~= pmax then
					tooltipFormat:SetPattern("$conf", pmin.."-"..pmax)
				else
					tooltipFormat:SetPattern("$conf", tostring(p))
				end
			end

			-- Counts
			tooltipFormat:SetPattern("$count", tostring(counts.biCount + counts.iCount))
			tooltipFormat:SetPattern("$lcount", tostring(counts.iCount))
			tooltipFormat:SetPattern("$bcount", tostring(counts.biCount))

			-- Name and quality
			local name, _, quality = GetItemInfo(dSig)
			local _, _, _, color = GetItemQualityColor(quality or 0)
			tooltipFormat:SetPattern("|q", color or "|cffcccc33")
			tooltipFormat:SetPattern("$name", name or counts.name)

			-- Rate
			if counts.rate ~= 1 then
				tooltipFormat:SetPattern("$rate", string.format("x%0.1f", counts.rate))
			else
				tooltipFormat:SetPattern("$rate", "")
			end

			-- Store this line and sort key
			local line = tooltipFormat:GetString(Enchantrix.Config.GetFilter('counts'))
			table.insert(lines,  {str = line, sort = pmin})
		end

		-- Sort in order of decreasing probability before adding to tooltip
		table.sort(lines, function(a, b) return a.sort > b.sort end)
		for n, line in ipairs(lines) do
			EnhTooltip.AddLine(line.str, nil, embed)
			EnhTooltip.LineColor(0.8, 0.8, 0.2);
			if n >= 5 then break end -- Don't add more than 5 lines
		end

		if (Enchantrix.Config.GetFilter('valuate')) then
			local confidence = totals.conf;

			if (Enchantrix.Config.GetFilter('valuate-hsp') and totals.hspValue > 0) then
				EnhTooltip.AddLine(_ENCH('FrmtValueAuctHsp'), Enchantrix.Util.Digits(totals.hspValue * confidence, 3), embed);
				EnhTooltip.LineColor(0.1,0.6,0.6);
			end
			if (Enchantrix.Config.GetFilter('valuate-median') and totals.medValue > 0) then
				EnhTooltip.AddLine(_ENCH('FrmtValueAuctMed'), Enchantrix.Util.Digits(totals.medValue * confidence, 3), embed);
				EnhTooltip.LineColor(0.1,0.6,0.6);
			end
			if (Enchantrix.Config.GetFilter('valuate-baseline') and totals.mktValue > 0) then
				EnhTooltip.AddLine(_ENCH('FrmtValueMarket'), Enchantrix.Util.Digits(totals.mktValue * confidence, 3), embed);
				EnhTooltip.LineColor(0.1,0.6,0.6);
			end
		end
	end
end

function enchantTooltip(funcVars, retVal, frame, name, link)
	local embed = Enchantrix.Config.GetFilter('embed');

	local auctioneerLoaded = false
	if Auctioneer and Auctioneer.Statistic then
		auctioneerLoaded = true
	end

	local frameName = frame:GetName()
	local nLines = frame:NumLines()
	local reagents
	for i = 1, nLines do
		local obj = getglobal(frameName.."TextLeft"..i)
		local text = ""
		if obj and obj.GetText then
			text = obj:GetText()
		end
		local _, _, r = string.find(text, _ENCH('PatReagents'))
		if r then
			reagents = r
			break
		end
	end
	local price = 0
	local unknownPrices = false
	local reagentInfo = {}
	for reagent in Enchantrix.Util.Spliterator(reagents, ",") do
		-- Chomp whitespace
		reagent = string.gsub(reagent, "^%s*", "")
		reagent = string.gsub(reagent, "%s*$", "")
		-- ...and color codes
		reagent = string.gsub(reagent, "^%|c%x%x%x%x%x%x%x%x", "")
		reagent = string.gsub(reagent, "%|r$", "")

		local _, _, count = string.find(reagent, "%((%d+)%)$")
		if count then
			reagent = string.gsub(reagent, "%s*%(%d+%)$", "")
			count = tonumber(count)
		else
			count = 1
		end

		local link = Enchantrix.Util.GetLinkFromName(reagent)
		if link then
			local name, quality, color
			name, _, quality = GetItemInfo(link)
			if quality then
				_, _, _, color = GetItemQualityColor(quality)
			end
			local hsp, median, market = Enchantrix.Util.GetReagentPrice(link)
			table.insert(reagentInfo, {
				["name"] = reagent,
				["count"] = count,
				["price"] = hsp,
				["quality"] = quality,
				["color"] = color,
			})
			if hsp then
				price = price + count * hsp
			else
				unknownPrices = true
			end
		else
			table.insert(reagentInfo, {
				["name"] = reagent,
				["count"] = count,
			})
			unknownPrices = true
		end
	end
	table.sort(reagentInfo, function(a,b)
		if (not b) or (not a) then return end
		return ((b.quality or -1) < (a.quality or -1)) or ((b.price or 0) < (a.price or 0))
	end)

	-- No reagents
	if table.getn(reagentInfo) < 1 then
		return
	end

	if not embed then
		EnhTooltip.SetIcon("Interface\\Icons\\Spell_Holy_GreaterHeal")
		EnhTooltip.AddLine(name)
		EnhTooltip.AddLine(EnhTooltip.HyperlinkFromLink(link))
	end
	EnhTooltip.AddLine(_ENCH('FrmtSuggestedPrice'), nil, embed)
	EnhTooltip.LineColor(0.8,0.8,0.2)

	for _, reagent in pairs(reagentInfo) do
		local line = "  "

		if reagent.color then
			line = line..reagent.color
		end
		line = line..reagent.name
		if reagent.color then
			line = line.."|r"
		end
		line = line.." x"..reagent.count
		if reagent.count > 1 and reagent.price then
			line = line..string.format(" ".._ENCH('FrmtPriceEach'), EnhTooltip.GetTextGSC(Enchantrix.Util.Digits(reagent.price, 3)))
			EnhTooltip.AddLine(line, Enchantrix.Util.Digits(reagent.price * reagent.count, 3), embed)
		elseif reagent.price then
			EnhTooltip.AddLine(line, Enchantrix.Util.Digits(reagent.price, 3), embed)
		else
			EnhTooltip.AddLine(line, nil, embed)
		end
		EnhTooltip.LineColor(0.7,0.7,0.1)
	end

	if price > 0 then
		EnhTooltip.AddLine(_ENCH('FrmtTotal'), Enchantrix.Util.Digits(price, 3), embed)
		EnhTooltip.LineColor(0.8,0.8,0.2)
		if not auctioneerLoaded then
			EnhTooltip.AddLine(_ENCH('FrmtWarnAuctNotLoaded'))
			EnhTooltip.LineColor(0.6,0.6,0.1)
		end
		if unknownPrices then
			EnhTooltip.AddLine(_ENCH('FrmtWarnPriceUnavail'))
			EnhTooltip.LineColor(0.6,0.6,0.1)
		end
	else
		EnhTooltip.AddLine(_ENCH('FrmtWarnNoPrices'))
		EnhTooltip.LineColor(0.6,0.6,0.1)
	end
end

function hookTooltip(funcVars, retVal, frame, name, link, quality, count)
	-- nothing to do, if enchantrix is disabled
	if (not Enchantrix.Config.GetFilter('all')) then
		return
	end

	local ltype = EnhTooltip.LinkType(link)
	if ltype == "item" then
		itemTooltip(funcVars, retVal, frame, name, link, quality, count)
	elseif ltype == "enchant" then
		enchantTooltip(funcVars, retVal, frame, name, link)
	end
end

Enchantrix.Tooltip = {
	REVISION		= "$Revision$",

	AddonLoaded		= addonLoaded,
	Format			= tooltipFormat,
}
