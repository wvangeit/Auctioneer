--[[
	Auctioneer Advanced - ScanData
	Revision: $Id$
	Version: <%version%>

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

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
--]]

local libName = "ScanData"
local libType = "Util"

AucAdvanced.Modules[libType][libName] = {}
local lib = AucAdvanced.Modules[libType][libName]
local private = {}
local print = AucAdvanced.Print
lib.Private = private

local data

--[[
The following functions are part of the module's exposed methods:
	GetName()         (required) Should return this module's full name
	CommandHandler()  (optional) Slash command handler for this module
	Processor()       (optional) Processes messages sent by Auctioneer
	ScanProcessor()   (optional) Processes items from the scan manager
*	GetPrice()        (required) Returns estimated price for item link
*	GetPriceColumns() (optional) Returns the column names for GetPrice
	OnLoad()          (optional) Receives load message for all modules

	(*) Only implemented in stats modules; util modules do not provide
]]

function lib.GetName()
	return libName
end

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		private.ProcessTooltip(...)
	end
end

--[[ Local functions ]]--
local Const = AucAdvanced.Const

local itemWorth = {}
local colorDist = {
	exact = { red=0, orange=0, yellow=0, green=0, blue=0 },
	suffix = { red=0, orange=0, yellow=0, green=0, blue=0 },
	base = { red=0, orange=0, yellow=0, green=0, blue=0 },
	all = { red=0, orange=0, yellow=0, green=0, blue=0 },
}
function colored(doIt, counts, alt)
	local text
	if (counts.blue > 0) then
		text = ("|cff3399ff%d|r"):format(counts.blue)
	end
	if (counts.green > 0) then
		if text then text = text .. " / " else text = "" end
		text = text..("|cff33ff44%d|r"):format(counts.green)
	end
	if (counts.yellow > 0) then
		if text then text = text .. " / " else text = "" end
		text = text..("|cffffff00%d|r"):format(counts.yellow)
	end
	if (counts.orange > 0) then
		if text then text = text .. " / " else text = "" end
		text = text..("|cffff9900%d|r"):format(counts.orange)
	end
	if (counts.red > 0) then
		if text then text = text .. " / " else text = "" end
		text = text..("|cffff0000%d|r"):format(counts.red)
	end
	if text then text = "( "..text.." )" else text = alt end
	return text
end
function private.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost)
	local getter = AucAdvanced.Settings.GetSetting
	if not getter("scandata.tooltip.display") then return  end

	local full = false
	local iType, iID, iSuffix, iFactor = AucAdvanced.DecodeLink(hyperlink)
	if (getter("scandata.tooltip.modifier") and IsShiftKeyDown()) then
		full = true
	end
	local scandata = AucAdvanced.Scan.GetScanData()

	local calcLevel, doColor
	if (AucAdvanced.Modules.Util and AucAdvanced.Modules.Util.PriceLevel) then
		calcLevel = AucAdvanced.Modules.Util.PriceLevel.CalcLevel
		doColor = true
		while (#itemWorth>0) do table.remove(itemWorth) end
		for k,v in pairs(colorDist) do
			for c,n in pairs(v) do
				colorDist[k][c] = 0
			end
		end
	end

	local exact, suffix, base = 0,0,0

	local n = #(scandata.image)
	local v, vID, vSuffix, vFactor, vSig, vLink, vLevel, vPer, vColor, vBid, vBuy, _
	for i=1, n do
		v = scandata.image[i]
		vID = v[Const.ITEMID]
		if (vID == iID) then
			vSuffix = v[Const.SUFFIX]
			vFactor = v[Const.FACTOR]
			vCount = v[Const.COUNT]

			if (calcLevel) then
				vLink = v[Const.LINK]
				vBid = v[Const.PRICE]
				vBuy = v[Const.BUYOUT]
				vSig = ("%d:%d:%d"):format(vID, vSuffix, vFactor)
				vLevel, vPer, _,_,_, vColor, itemWorth[vSig] = calcLevel(vLink, vCount, vBid, vBuy, itemWorth[vSig])
			end
		
			if (vSuffix == iSuffix) then
				if (vFactor == iFactor) then
					exact = exact + vCount
					if (vColor) then
						colorDist.exact[vColor] = colorDist.exact[vColor] + vCount
					end
				else
					suffix = suffix + vCount
					if (vColor) then
						colorDist.suffix[vColor] = colorDist.suffix[vColor] + vCount
					end
				end
			else
				base = base + vCount
				if (vColor) then
					colorDist.base[vColor] = colorDist.base[vColor] + vCount
				end
			end
			if (vColor) then
				colorDist.all[vColor] = colorDist.all[vColor] + vCount
			end
		end
	end		

	if full and (base+suffix+exact > 0) then
		EnhTooltip.AddLine("Items in image:")
		EnhTooltip.LineColor(0.3, 0.9, 0.8)
		if (exact > 0) then
			EnhTooltip.AddLine("  |cffddeeff"..exact.."|r exact "..colored(doColor, colorDist.exact, "matches"))
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
		if (suffix > 0) then
			EnhTooltip.AddLine("  |cffddeeff"..exact.."|r suffix "..colored(doColor, colorDist.suffix, "matches"))
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
		if (base > 0) then
			EnhTooltip.AddLine("  |cffddeeff"..exact.."|r base "..colored(doColor, colorDist.base, "matches"))
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
	elseif base+suffix+exact > 0 then
		if (suffix+base > 0) then
			EnhTooltip.AddLine("|cffddeeff"..exact.." +"..(suffix+base).."|r matches "..colored(doColor, colorDist.all, "in image"))
		else
			EnhTooltip.AddLine("|cffddeeff"..exact.."|r matches "..colored(doColor, colorDist.exact, "in image"))
		end
		EnhTooltip.LineColor(0.3, 0.9, 0.8)
	else
		EnhTooltip.AddLine("No matches in image.")
		EnhTooltip.LineColor(0.3, 0.9, 0.8)
	end
end
