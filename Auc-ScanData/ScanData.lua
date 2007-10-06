--[[
	Auctioneer Advanced - ScanData
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

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

private.cache = {}
function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		private.ProcessTooltip(...)
	elseif (callbackType == "scanstats") then
		private.cache = {}
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
function lib.Colored(doIt, counts, alt)
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
	if alt then
		if text then
			text = "( "..text.." )"
		else
			text = alt
		end
	end
	return text
end

function lib.GetImageCounts(hyperlink, maxPrice, items)
	local scandata = AucAdvanced.Scan.GetScanData()

	local itemID, itemSuffix, itemFactor
	if type(hyperlink) == "number" then
		itemID = hyperlink
		itemSuffix = 0
		itemFactor = 0
	else
		local iType, iID, iSuffix, iFactor = AucAdvanced.DecodeLink(hyperlink)
		if iType == "item" then
			itemID = iID
			itemSuffix = iSuffix
			itemFactor = iFactor
		end
	end

	local totalBid, totalBuy = 0

	local n = #(scandata.image)
	local v, vID, vSuffix, vFactor, vSig, vLink, vLevel, vPer, vColor, vBid, vBuy, _
	for i=1, n do
		v = scandata.image[i]
		vID = v[Const.ITEMID]
		if (vID == iID) then
			vSuffix = v[Const.SUFFIX]
			vFactor = v[Const.FACTOR]
			vCount = v[Const.COUNT]

			if (vSuffix == iSuffix) then
				if (vFactor == iFactor) then
					vBid = v[Const.PRICE]
					vBuy = v[Const.BUYOUT]

					local matched = false
					if (maxPrice) then
						if (vBuy and vBuy > 0 and vBuy < maxPrice) then
							totalBuy = totalBuy + count
							matched = true
						elseif (not maxPrice or vBid < maxPrice) then
							totalBid = totalBid + count
							matched = true
						end
					else
						if (vBuy and vBuy > 0) then
							totalBuy = totalBuy + 1
							matched = true
						else
							totalBid = totalBid + 1
							matched = true
						end
					end
					if items and matched then
						table.insert(items, v)
					end
				end
			end
		end
	end

	return totalBuy, totalBid
end

function lib.GetDistribution(hyperlink)

	local iType, iID, iSuffix, iFactor = AucAdvanced.DecodeLink(hyperlink)
	local sig = strjoin(":", iID, iSuffix, iFactor)
	if private.cache[sig] then return unpack(private.cache[sig]) end

	local scandata = AucAdvanced.Scan.GetScanData()

	local calcLevel, doColor, myColors
	if (AucAdvanced.Modules.Util and AucAdvanced.Modules.Util.PriceLevel) then
		calcLevel = AucAdvanced.Modules.Util.PriceLevel.CalcLevel
		while (#itemWorth>0) do table.remove(itemWorth) end
		myColors = {}
		for k,v in pairs(colorDist) do
			myColors[k] = {}
			for c,n in pairs(v) do
				myColors[k][c] = 0
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
						myColors.exact[vColor] = myColors.exact[vColor] + vCount
					end
				else
					suffix = suffix + vCount
					if (vColor) then
						myColors.suffix[vColor] = myColors.suffix[vColor] + vCount
					end
				end
			else
				base = base + vCount
				if (vColor) then
					myColors.base[vColor] = myColors.base[vColor] + vCount
				end
			end
			if (vColor) then
				myColors.all[vColor] = myColors.all[vColor] + vCount
			end
		end
	end

	private.cache[sig] = {exact, suffix, base, myColors}
	return exact, suffix, base, myColors
end

function private.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost)
	local getter = AucAdvanced.Settings.GetSetting
	if not getter("scandata.tooltip.display") then return  end

	local full = false
	if (getter("scandata.tooltip.modifier") and IsShiftKeyDown()) then
		full = true
	end

	local doColor = false
	local exact, suffix, base, dist = lib.GetDistribution(hyperlink)
	if hasColor then doColor = true end

	if full and (base+suffix+exact > 0) then
		EnhTooltip.AddLine("Items in image:")
		EnhTooltip.LineColor(0.3, 0.9, 0.8)
		if (exact > 0) then
			EnhTooltip.AddLine("  |cffddeeff"..exact.."|r exact "..lib.Colored(doColor, dist.exact, "matches"))
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
		if (suffix > 0) then
			EnhTooltip.AddLine("  |cffddeeff"..exact.."|r suffix "..lib.Colored(doColor, dist.suffix, "matches"))
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
		if (base > 0) then
			EnhTooltip.AddLine("  |cffddeeff"..exact.."|r base "..lib.Colored(doColor, dist.base, "matches"))
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
	elseif base+suffix+exact > 0 then
		if (suffix+base > 0) then
			EnhTooltip.AddLine("|cffddeeff"..exact.." +"..(suffix+base).."|r matches "..lib.Colored(doColor, dist.all, "in image"))
		else
			EnhTooltip.AddLine("|cffddeeff"..exact.."|r matches "..lib.Colored(doColor, dist.exact, "in image"))
		end
		EnhTooltip.LineColor(0.3, 0.9, 0.8)
	else
		EnhTooltip.AddLine("No matches in image.")
		EnhTooltip.LineColor(0.3, 0.9, 0.8)
	end
end

function lib.Unpack(realm)
	if not (AucScanData and AucScanData.scans) then return end
	if not realm then realm = GetRealmName() end
	local sData = AucScanData.scans[realm]
	if not sData then return end

	for faction, fData in pairs(sData) do
		if fData.image and type(fData.image) == "string" then
			local loader, err = loadstring(fData.image)
			if (loader) then
				fData.image = loader()
				collectgarbage()
			else
				print("Error loading scan image: {{", err, "}}")
			end
		end
	end
end

function lib.OnLoad()
	lib.Unpack()
end

function lib.OnUnload()
	local StringRope = LibStub:GetLibrary("StringRope")
	local rope = StringRope:New()

	if not (AucScanData and AucScanData.scans) then return end
	
	-- If you only scan 3 servers, then you don't need the overflow protection
	local count = 0
	for server in pairs(AucScanData.scans) do
		count = count+1
	end
	if count <= 3 then return end
		
	-- Convert all image data to loadstring strings
	for server, sData in pairs(AucScanData.scans) do
		for faction, fData in pairs(sData) do
			if fData.image and type(fData.image) == "table" then
				rope:Add("return {")
				local fCount = #fData.image
				for i = 1, fCount do
					local item = fData.image[i]
					if item and type(item) == "table" then
						rope:Add("{")
						local pos = 1
						while item[pos] or item[pos+1] or item[pos+2] or item[pos+3] do
							local v = item[pos]
							if v == nil then
								rope:Add("nil,")
							else
								local t = type(v)
								if t == "string" then
									rope:Add(("%q,"):format(v))
								elseif t == "number" then
									rope:Add(v..",")
								end
							end
							pos = pos + 1
						end
						rope:Add("},")
					elseif item == nil then
						rope:Add("nil,")
					end
				end
				rope:Add("}")
				fData.image = rope:Get()
				rope:Clear()
			end
		end
	end
end
