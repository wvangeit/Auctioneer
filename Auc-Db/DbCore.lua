--[[
	AuctioneerDB
	Revision: $Id$
	Version: <%version%>

	This is an addon for World of Warcraft that integrates with the online
	auction database site at http://auctioneerdb.com.
	This addon provides detailed price data for auctionable items based off
	an online database that is contributed to by users just like you.
	If you want to contribute your data and keep your price up-to-date, you
	can easily update your pricelist by using the sychronization utility
	which is provided with this addon.
	To syncronize you data, run the SyncDb executable for your platform.

	License:
		AuctioneerDB AddOn for World of Warcraft.
		Copyright (C) 2007, Norganna's AddOns Pty Ltd.

		This program is free software: you can redistribute it and/or modify
		it under the terms of the GNU General Public License as published by
		the Free Software Foundation, either version 3 of the License, or
		(at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program.  If not, see <http://www.gnu.org/licenses/>.

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit licence to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]

local libType, libName = "Util", "AucDB"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,recycle,acquire,clone,scrub = AucAdvanced.GetModuleLocals()

AucDB = lib

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
	--	private.ProcessTooltip(...)
	end
end

local function getTime()
	return time()
end

local rope = LibStub("StringRope"):New()
local faction, scanid
function private.process(operation, itemData, oldData)
	if (faction and scanid) then
		if not rope:IsEmpty() then rope:Add(";") end
		rope:AddDelimited(":", itemData.itemId, itemData.itemSuffix, itemData.itemEnchant, itemData.itemFactor, itemData.itemSeed, itemData.stackSize, itemData.sellerName, itemData.minBid, itemData.buyoutPrice, itemData.curBid, itemData.timeLeft)

		AucDbData.names[("%d:%d:%d"):format(itemData.itemId,itemData.itemSuffix,itemData.itemEnchant)] = itemData.itemName;
	end
end

if true or lib.Enabled then
	lib.ScanProcessors = {
		begin = function ()
			rope:Clear()
			scanid = getTime()
			faction = AucAdvanced.GetFaction()
			if not AucDbData then AucDbData = {} end
			if not AucDbData[faction] then AucDbData[faction] = {} end
		end,
		create = private.process,
		update = private.process,
		complete = function ()
			AucDbData[faction][scanid] = rope:Get()
			rope:Clear()
		end
	}
end

lib.LoadTriggers = { ["auc-db"] = true }
function lib.OnLoad()
	if not AucDbData then AucDbData = { names = {} } return end
	if not AucDbData.names then AucDbData.names = {} end

	local expires = time() - (86400 * 3) -- 3 day expiry
	for realm, rData in pairs(AucDbData) do
		if (realm ~= "names") then
			for tStamp, tData in pairs(rData) do
				if tStamp < expires then
					rData[tStamp] = nil
				end
			end
		end
	end
end
