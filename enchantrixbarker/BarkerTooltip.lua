--[[
	Enchantrix:Barker Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id: BarkerTooltip.lua 1605 2007-03-26 05:19:07Z mentalpower $

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
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit licence to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]
EnchantrixBarker_RegisterRevision("$URL: http://norganna@norganna.org/svn/auctioneer/trunk5/enchantrix/EnxTooltip.lua $", "$Rev: 1605 $")

function enchantTooltip(funcVars, retVal, frame, name, link)

-- currently do all of this inside Enchantrix
--[[
	local embed = Barker.Settings.GetSetting('embed');

	local craftIndex
	for i = 1, GetNumCrafts() do
		local craftName = GetCraftInfo(i)
		if name == craftName then
			craftIndex = i
			break
		end
	end

	-- Get reagent list
	local reagentList
	if craftIndex then
		reagentList = getReagentsFromCraftFrame(craftIndex)
	else
		reagentList = getReagentsFromTooltip(frame)
	end

	if not reagentList or (#reagentList < 1) then
		return
	end

	-- Append additional reagent info
	for _, reagent in ipairs(reagentList) do
		local name, link, quality = Barker.Util.GetReagentInfo(reagent[1])
		local hsp, median, market = Barker.Util.GetReagentPrice(reagent[1])
		local _, _, _, color = GetItemQualityColor(quality)

		reagent[1] = name
		table.insert(reagent, quality)
		table.insert(reagent, color)
		table.insert(reagent, hsp)
	end

	local NAME, COUNT, QUALITY, COLOR, PRICE = 1, 2, 3, 4, 5

	-- Sort by rarity and price
	table.sort(reagentList, function(a,b)
		if (not b) or (not a) then return end
		return ((b[QUALITY] or -1) < (a[QUALITY] or -1)) or ((b[PRICE] or 0) < (a[PRICE] or 0))
	end)

	-- Header
	if not embed then
		local icon
		if craftIndex then
			icon = GetCraftIcon(craftIndex)
		else
			icon = "Interface\\Icons\\Spell_Holy_GreaterHeal"
		end
		EnhTooltip.SetIcon(icon)
		EnhTooltip.AddLine(name)
		EnhTooltip.AddLine(EnhTooltip.HyperlinkFromLink(link))
	end
	EnhTooltip.AddLine(_BARKLOC('FrmtSuggestedPrice'), nil, embed)
	EnhTooltip.LineColor(0.8,0.8,0.2)

	local price = 0
	local unknownPrices
	-- Add reagent list to tooltip and sum reagent prices
	for _, reagent in pairs(reagentList) do
		local line = "  "

		if reagent[COLOR] then
			line = line..reagent[COLOR]
		end
		line = line..reagent[NAME]
		if reagent[COLOR] then
			line = line.."|r"
		end
		line = line.." x"..reagent[COUNT]
		if reagent[COUNT] > 1 and reagent[PRICE] then
			line = line.." ".._BARKLOC('FrmtPriceEach'):format(EnhTooltip.GetTextGSC(Barker.Util.Round(reagent[PRICE], 3)))
			EnhTooltip.AddLine(line, Barker.Util.Round(reagent[PRICE] * reagent[COUNT], 3), embed)
			price = price + reagent[PRICE] * reagent[COUNT]
		elseif reagent[PRICE] then
			EnhTooltip.AddLine(line, Barker.Util.Round(reagent[PRICE], 3), embed)
			price = price + reagent[PRICE]
		else
			EnhTooltip.AddLine(line, nil, embed)
			unknownPrices = true
		end
		EnhTooltip.LineColor(0.7,0.7,0.1)
	end

	-- Barker price
	local margin = Enchantrix_BarkerGetConfig("profit_margin")
	local profit = price * margin * 0.01
	profit = math.min(profit, Enchantrix_BarkerGetConfig("highest_profit"))
	local barkerPrice = EnchantrixBarker_RoundPrice(price + profit)

	-- Totals
	if price > 0 then
		EnhTooltip.AddLine(_BARKLOC('FrmtTotal'), Barker.Util.Round(price, 2.5), embed)
		EnhTooltip.LineColor(0.8,0.8,0.2)
		if Barker.Settings.GetSetting('barker') then
			-- "Barker Price (%d%% margin)"
			EnhTooltip.AddLine(_BARKLOC('FrmtBarkerPrice'):format(Barker.Util.Round(margin)), barkerPrice, embed)
			EnhTooltip.LineColor(0.8,0.8,0.2)
		end

		if not Barker.State.Auctioneer_Loaded then
			EnhTooltip.AddLine(_BARKLOC('FrmtWarnAuctNotLoaded'))
			EnhTooltip.LineColor(0.6,0.6,0.1)
		end

		if unknownPrices then
			EnhTooltip.AddLine(_BARKLOC('FrmtWarnPriceUnavail'))
			EnhTooltip.LineColor(0.6,0.6,0.1)
		end
	else
		EnhTooltip.AddLine(_BARKLOC('FrmtWarnNoPrices'))
		EnhTooltip.LineColor(0.6,0.6,0.1)
	end
]]

end


function hookTooltip(funcVars, retVal, frame, name, link, quality, count)
	local ltype = EnhTooltip.LinkType(link)
	if ltype == "enchant" then
		enchantTooltip(funcVars, retVal, frame, name, link)
	end
end

Stubby.RegisterFunctionHook("EnhTooltip.AddTooltip", 500, hookTooltip)

