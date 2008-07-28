--[[
	Auctioneer Advanced - Search UI - Searcher Snatch
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

	This is a plugin module for the SearchUI that assists in searching by refined paramaters

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
-- Create a new instance of our lib with our parent
local lib, parent, private = AucSearchUI.NewSearcher("Snatch")
if not lib then return end
local print,decode,_,_,replicate,empty,_,_,_,debugPrint,fill = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "Snatch"

default("snatch.allow.bid", true)
default("snatch.allow.buy", true)

-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	-- Get our tab and populate it with our controls
	local id = gui:AddTab(lib.tabname, "Searches")
	
	if not (BtmScan and BtmScan.Settings) then
		gui:AddControl(id, "Header",     0,   "BtmScan not detected")
		gui:AddControl(id, "Note",    0.3, 1, 290, 30,    "BtmScan must be enabled to search with Snatch")
		return
	end

	local last = gui:GetLast(id)
	gui:AddControl(id, "Header",     0,      "Snatch search criteria")
	
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0, 1, "snatch.allow.bid", "Allow Bids")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0, 11,  "snatch.allow.buy", "Allow Buyouts")

	gui:AddControl(id, "Subhead",           0,    "Note:")
	gui:AddControl(id, "Note",              0, 1, 290, 30, "This search uses your Snatch list from BtmScan")
end

function lib.Search(item)
	-- LINK ILEVEL ITYPE ISUB IEQUIP PRICE TLEFT TIME NAME TEXTURE
	-- COUNT QUALITY CANUSE ULEVEL MINBID MININC BUYOUT CURBID
	-- AMHIGH SELLER FLAG ID ITEMID SUFFIX FACTOR ENCHANT SEED

	if not (BtmScan and BtmScan.Settings) then
		return false, "BtmScan not detected"
	end
	local itemid = item[Const.ITEMID]
	local itemConfigTable = BtmScan.Settings.GetSetting("itemconfig.list")
	local itemConfig = {}
	local value = 0
	local stackSize = 1
	for sig, itemConfigString in pairs(itemConfigTable) do
		BtmScan.unpackItemConfiguration(itemConfigString, itemConfig)
		if itemConfig.buyBelow and itemConfig.buyBelow>0 then
			local snatchitemID, _, _ = strsplit(':', sig)
		itemid = tonumber(itemid)
		snatchitemID = tonumber(snatchitemID)
		if itemid == snatchitemID then 
			value = itemConfig.buyBelow
			if value == nil then
				value = 0
			end
			stackSize = item[Const.COUNT]
			value = value * stackSize
			if --get("snatch.allow.buy") and 
			item[Const.BUYOUT] > 0 and item[Const.BUYOUT] <= value then
				return "buy", value
			elseif --get("snatch.allow.bid") and 
			item[Const.PRICE] <= value then
					return "bid", value
				end
			else
				return false, "Not in snatch list"
			end
		end
	end
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
