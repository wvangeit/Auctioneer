--[[
	Auctioneer Advanced - Search UI
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds a price level indicator
	to auctions when browsing the Auction House, so that you may readily see
	which items are bargains or overpriced at a glance.

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

local libType, libName = "Util", "SearchUI"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()

local Const = AucAdvanced.Const
local gui

-- Our official name:
AucSearchUI = lib

function lib.GetName()
	return libName
end

function lib.Processor(callbackType, ...)
	if (callbackType == "config") then
		--private.SetupConfigGui(...)
		-- We don't have one of these
	end
end

local function getSearchParamName()
	if (not AucAdvancedData.UtilSearchUI) then AucAdvancedData.UtilSearchUI = {} end
	return AucAdvancedData.UtilSearchUI.lastSearch or "Default"
end

local function getSearchParam()
	if (not AucAdvancedData.UtilSearchUI) then AucAdvancedData.UtilSearchUI = {} end
	local searchName = getSearchParamName()
	if (not AucAdvancedData.UtilSearchUI["search."..searchName]) then
		if searchName ~= "Default" then
			searchName = "Default"
			AucAdvancedData.UtilSearchUI[getSearchParamName()] = "Default"
		end
		if searchName == "Default" then
			AucAdvancedData.UtilSearchUI["search."..searchName] = {}
		end
	end
	return AucAdvancedData.UtilSearchUI["search."..searchName]
end


local function cleanse( search )
	if (search) then
		search = {}
	end
end

-- Default setting values
local settingDefaults = {
}

local function getDefault(setting)
	local a,b,c = strsplit(".", setting)
	local result = settingDefaults[setting];
	return result
end

function lib.GetDefault(setting)
	local val = getDefault(setting);
	return val;
end

function lib.SetDefault(setting, default)
	settingDefaults[setting] = default
end

local function setter(setting, value)
	if (not AucAdvancedData.UtilSearchUI) then AucAdvancedData.UtilSearchUI = {} end

	-- turn value into a canonical true or false
	if value == 'on' then
		value = true
	elseif value == 'off' then
		value = false
	end

	-- for defaults, just remove the value and it'll fall through
	if (value == 'default') or (value == getDefault(setting)) then
		-- Don't save default values
		value = nil
	end

	local a,b,c = strsplit(".", setting)
	if (a == "search") then
		if (setting == "search.save") then
			value = gui.elements["search.name"]:GetText()

			-- Create the new search 
			AucAdvancedData.UtilSearchUI["search."..value] = {}

			-- Set the current search to the new search 
			AucAdvancedData.UtilSearchUI[getSearchParamName()] = value
			-- Get the new current search 
			local newSearch = getSearchParam()

			-- Clean it out and then resave all data
			cleanse(newSearch)
			gui:Resave()

			-- Add the new search to the searches list
			local searches = AucAdvancedData.UtilSearchUI["searches"]
			if (not searches) then
				searches = { "Default" }
				AucAdvancedData.UtilSearchUI["searches"] = searches
			end

			-- Check to see if it already exists
			local found = false
			for pos, name in ipairs(searches) do
				if (name == value) then found = true end
			end

			-- If not, add it and then sort it
			if (not found) then
				table.insert(searches, value)
				table.sort(searches)
			end

		elseif (setting == "search.delete") then
			-- User clicked the Delete button, see what the select box's value is.
			value = gui.elements["search"].value

			-- If there's a search name supplied
			if (value) then
				-- Clean it's search container of values
				cleanse(AucAdvancedData.UtilSearchUI["search."..value])

				-- Delete it's search container
				AucAdvancedData.UtilSearchUI["search."..value] = nil

				-- Find it's entry in the searches list
				local searches = AucAdvancedData.UtilSearchUI["searches"]
				if (searches) then
					for pos, name in ipairs(searches) do
						-- If this is it, then extract it
						if (name == value and name ~= "Default") then
							table.remove(searches, pos)
						end
					end
				end

				-- If the user was using this one, then move them to Default
				if (getSearchParamName() == value) then
					AucAdvancedData.UtilSearchUI[getSearchParamName()] = 'Default'
				end
			end

		elseif (setting == "search.default") then
			-- User clicked the reset settings button

			-- Get the current search from the select box
			value = gui.elements["search"].value

			-- Clean it's search container of values
			AucAdvancedData.UtilSearchUI["search."..value] = {}

		elseif (setting == "search") then
			-- User selected a different value in the select box, get it
			value = gui.elements["search"].value

			-- Change the user's current search to this new one
			AucAdvancedData.UtilSearchUI[getSearchParamName()] = value

		end

		-- Refresh all values to reflect current data
		gui:Refresh()
	else
		-- Set the value for this setting in the current search 
		local db = getSearchParam()
		if db[setting] == value then return end
		db[setting] = value
	end

	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.Processor) then
				engineLib.Processor("configchanged", setting, value)
			end
		end
	end
end

function lib.SetSetting(...)
	setter(...)
	if (gui) then
		gui:Refresh()
	end
end


local function getter(setting)
	if (not AucAdvancedData.UtilSearchUI) then AucAdvancedData.UtilSearchUI = {} end
	if not setting then return end

	local a,b,c = strsplit(".", setting)
	if (a == 'search') then
		if (b == 'searches') then
			local pList = AucAdvancedData.UtilSearchUI["searches"]
			if (not pList) then
				pList = { "Default" }
			end
			return pList
		end
	end

	if (setting == 'search') then
		return getSearchParamName()
	end

	local db = getSearchParam()
	if ( db[setting] ~= nil ) then
		return db[setting]
	else
		return getDefault(setting)
	end
end

function lib.GetSetting(setting, default)
	local option = getter(setting)
	if ( option ~= nil ) then
		return option
	else
		return default
	end
end

function lib.Show()
	lib.MakeGuiConfig()
	gui:Show()
end

function lib.Hide()
	if (gui) then
		gui:Hide()
	end
end

function lib.Toggle()
	if (gui and gui:IsShown()) then
		lib.Hide()
	else
		lib.Show()
	end
end

private.callbacks = {}
function lib.AddCallback(name, callback)
	if (gui) then 
		callback(gui)
		return
	end
	private.callbacks[name] = callback
end

local searcherKit = {}
function searcherKit:GetName()
	return self.name
end

lib.Searchers = {}
function lib.NewSearcher(searcherName)
	if not lib.Searchers[searcherName] then
		local searcher = {}
		searcher.name = searcherName
		for k,v in pairs(searcherKit) do
			searcher[k] = v
		end

		lib.Searchers[searcherName] = searcher
		return searcher, lib, {}
	end
end

function lib.GetSearchLocals()
	return lib.GetSetting, lib.SetSetting, lib.SetDefault, Const
end

function lib.MakeGuiConfig()
	if gui then return end

	local Configator = LibStub("Configator")
	local ScrollSheet = LibStub("ScrollSheet")
	local id, last, cont

	gui = Configator:Create(setter,getter, 900, 500, 0, 300)

	private.gui = gui
	gui.frame = CreateFrame("Frame", nil, gui)
	gui.frame:SetPoint("BOTTOMRIGHT", gui.Done, "TOPRIGHT", 0,0) 
	gui.frame:SetPoint("LEFT", gui:GetButton(1), "RIGHT", 5,0) 
	gui.frame:SetHeight(300)
	gui.frame:SetBackdrop({
		bgFile = "Interface/Tooltips/ChatBubble-Background",
		edgeFile = "Interface/Tooltips/ChatBubble-BackDrop",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 32, right = 32, top = 32, bottom = 32 }
	})
	gui.frame:SetBackdropColor(0, 0, 0, 1)



function lib.OnEnterSheet(button, row, index)
	if gui.sheet.rows[row][index]:IsShown()then --Hide tooltip for hidden cells
		local link, name
		link = gui.sheet.rows[row][index]:GetText() 
		local name = GetItemInfo(link)
		if link and name then
			GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(link)
			if (EnhTooltip) then 
				EnhTooltip.TooltipCall(GameTooltip, name, link, -1, 1) 
			end
		end		
	end
end

function lib.OnLeaveSheet(button, row, index)
	GameTooltip:Hide()
end

function lib.OnClickSheet(button, row, index)
	local link = gui.sheet.rows[row][1]:GetText()
--	lib.DoSomethingWithLinkFunctionHere(link)
end	



	gui.sheet = ScrollSheet:Create(gui.frame, {
		{ "Item",   "TOOLTIP", 120 },
		{ "Seller", "TEXT", 75  },
		{ "Left",   "INT",  40  },
		{ "Stk",    "INT",  30  },
		{ "Min/ea", "COIN", 85, { DESCENDING=true } },
		{ "Cur/ea", "COIN", 85, { DESCENDING=true } },
		{ "Buy/ea", "COIN", 85, { DESCENDING=true, DEFAULT=true } },
		{ "MinBid", "COIN", 85, { DESCENDING=true } },
		{ "CurBid", "COIN", 85, { DESCENDING=true } },
		{ "Buyout", "COIN", 85, { DESCENDING=true } },
	}, lib.OnEnterSheet, lib.OnLeaveSheet, lib.OnClickSheet) 
	

	gui.Search = CreateFrame("Button", "AucSearchUISearchButton", gui, "OptionsButtonTemplate")
	gui.Search:SetPoint("BOTTOMRIGHT", gui.frame, "TOPRIGHT", -10, 15)
	gui.Search:SetText("Search")
	gui.Search:SetScript("OnClick", lib.PerformSearch)

	gui:AddCat("Searches")
	id = gui:AddTab("General parameters", "Searches") -- Merely a place holder

	id = gui:AddTab("Saved searches")
	gui:AddControl(id, "Header",     0,    "Setup, configure and edit searches")
	last = gui:GetLast(id)
	gui:AddControl(id, "Subhead",    0,    "Select a saved search")
	gui:AddControl(id, "Selectbox",  0, 1, "search.search", "search", "Switch to given search")
	gui:AddControl(id, "Button",     0, 1, "search.delete", "Delete")
	cont = gui:GetLast(id)
	gui:SetLast(id, last)
	gui:AddControl(id, "Subhead",    0.5,    "Create or replace a search")
	gui:AddControl(id, "Text",       0.5, 1, "search.name", "New search name:")
	last = gui:GetLast(id)
	gui:AddControl(id, "Button",     0.5, 1, "search.save", "Create new")
	gui:SetLast(id, last)
	gui:AddControl(id, "Button",     0.7, 1, "search.copy", "Create copy")


	lib.gui = gui

	-- Alert our searchers?
	for name, searcher in pairs(lib.Searchers) do
		if searcher.MakeGuiConfig then
			searcher:MakeGuiConfig(gui)
		end
	end
	-- Any callbacks?
	for name, callback in pairs(private.callbacks) do
		callback(gui)
	end
end

local sideIcon
local SlideBar = LibStub:GetLibrary("SlideBar", true)
if SlideBar then
	--Need to figure out if we're embedded first
	local embedded = false
	if AucAdvanced and AucAdvanced.EmbeddedModules then
		for _, module in ipairs(AucAdvanced.EmbeddedModules) do 
			if module == "Auc-Util-SearchUI"  then 
				embedded = true 
			end 
		end
	end
	if embedded then
		sideIcon = SlideBar.AddButton("Auc-Util-SearchUI", "Interface\\AddOns\\Auc-Advanced\\Modules\\Auc-Util-SearchUI\\Textures\\SearchUIIcon", 300)
	else
		sideIcon = SlideBar.AddButton("Auc-Util-SearchUI", "Interface\\AddOns\\Auc-Util-SearchUI\\Textures\\SearchUIIcon", 300)
	end
	sideIcon:RegisterForClicks("LeftButtonUp","RightButtonUp")
	sideIcon:SetScript("OnClick", lib.Toggle)
	sideIcon.tip = {
		"Auction SearchUI",
		"Allows you to perform searches on the AuctioneerAdvanced auction cache, even when away from the AuctionHouse",
		"{{Click}} to open the Search UI.",
	}
end


function private.QueryFilter(item)
	for name, searcher in pairs(lib.Searchers) do
		if searcher and searcher.Search then
			if not searcher.Search(item) then -- The search fails
				return true -- "Yes, filter OUT this item"
			end
		end
	end
end

local queryFilter = { filter = private.QueryFilter }
function lib.PerformSearch()
	gui:ClearFocus()
	local results = AucAdvanced.API.QueryImage(queryFilter)

	-- Now we have the results, it's time to populate the sheet
	local sheetData = acquire()

	-- LINK ILEVEL ITYPE ISUB IEQUIP PRICE TLEFT TIME NAME TEXTURE
	-- COUNT QUALITY CANUSE ULEVEL MINBID MININC BUYOUT CURBID
	-- AMHIGH SELLER FLAG ID ITEMID SUFFIX FACTOR ENCHANT SEED
	for pos, data in ipairs(results) do
		local count = data[Const.COUNT]
		local min = data[Const.MINBID]
		local cur = data[Const.CURBID]
		local buy = data[Const.BUYOUT]
		table.insert(sheetData, acquire(
			data[Const.LINK],
			data[Const.SELLER],
			data[Const.TLEFT],
			count,
			min/count,
			cur/count,
			buy/count,
			min,
			cur,
			buy
		))
	end

	gui.sheet:SetData(sheetData)

	recycle(sheetData)
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")