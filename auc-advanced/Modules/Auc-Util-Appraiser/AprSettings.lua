--[[
	Auctioneer Advanced - Appraisals and Auction Posting
	Revision: $Id$
	Version: <%version%>

	This is an addon for World of Warcraft that adds an appriasals dialog for
	easy posting of your auctionables when you are at the auction-house.

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

local lib = AucAdvanced.Modules.Util.Appraiser
local private = lib.Private
local print = AucAdvanced.Print

function private.GetPriceModels()
	if not private.scanValueNames then private.scanValueNames = {} end
	for i = 1, #private.scanValueNames do
		private.scanValueNames[i] = nil
	end

	table.insert(private.scanValueNames,{"market", "Market value"})
	local algoList = AucAdvanced.API.GetAlgorithms()
	for pos, name in ipairs(algoList) do
		if (name ~= lib.name) then
			table.insert(private.scanValueNames,{name, "Stats: "..name})
		end
	end
	return private.scanValueNames
end

function private.GetExtraPriceModels()
	local vals = private.GetPriceModels()
	table.insert(vals, {"fixed", "Fixed price"})
	table.insert(vals, {"default", "Default"})
	return vals
end

private.durations = {
	{ 120, "2 hours" },
	{ 480, "8 hours" },
	{ 1440, "24 hours" },
}

--[[ The items are stored as:
----   id, name, texture, quality
--]]
function private.sortItems(a,b)
	if a[4] > b[4] then
		return true
	elseif a[4] < b[4] then
		return false
	end
	if a[2] < b[2] then
		return true
	elseif a[2] > b[2] then
		return false
	end
	return a[1] < b[1]
end

-- Function to round a value according to the current rounding method
function private.roundValue(value)
	local method = AucAdvanced.Settings.GetSetting("util.appraiser.round.method") or "unit"
	local pos = AucAdvanced.Settings.GetSetting("util.appraiser.round.position") or 0.00
	local magstep = AucAdvanced.Settings.GetSetting("util.appraiser.round.magstep") or 5

	local magnitude
	if (value > 10000*magstep) then magnitude = 10000
	elseif (value > 100*magstep) then magnitude = 100
	else magnitude = 1 end

	local modulus = math.floor(value / magnitude) * magnitude
	local fractio = math.floor(value - modulus)
	if method == "unit" then
		pos = pos * magnitude
		if fractio > pos then
			modulus = modulus + magnitude
		end
		fractio = pos
	elseif method == "div" then
		pos = pos * magnitude
		local nextdiv = 0
		while nextdiv < fractio do
			nextdiv = nextdiv + pos
		end
		if nextdiv > magnitude then
			nextdiv = 0
			modulus = modulus + magnitude
		end
		fractio = nextdiv
	end
	value = modulus + fractio
	return math.floor(value + 0.5)
end

function lib.RoundBid(value)
	if AucAdvanced.Settings.GetSetting("util.appraiser.round.bid") then
		return private.roundValue(value)
	end
	return value
end

function lib.RoundBuy(value)
	if AucAdvanced.Settings.GetSetting("util.appraiser.round.buy") then
		return private.roundValue(value)
	end
	return value
end

local scrollItems = {}
function lib.UpdateList()
	local n = #scrollItems
	for i = 1, n do
		scrollItems[i] = nil
	end
	local filter = AucAdvanced.Settings.GetSetting('util.appraiser.filter') or ""
	private.currentfilter = filter
	filter = filter:lower()
	if (filter == "") then filter = nil end

	local d = AucAdvancedData.UtilAppraiser
	if not d then
		AucAdvancedData.UtilAppraiser = {}
		d = AucAdvancedData.UtilAppraiser
	end
	if not d.items then
		d.items = {}
	end

	local data
	for i = 1, #(d.items) do
		data = d.items[i]
		if AucAdvanced.Settings.GetSetting("util.appraiser.item."..data[1]..".model") then
			if not filter or data[2]:find(filter, 1, true) then
				table.insert(scrollItems, data)
			end
		end
	end
	table.sort(scrollItems, private.sortItems)

	local pos = 0
	n = #scrollItems
	if (n <= 8) then
		private.scroller:Hide()
		private.scroller:SetValue(0)
	else
		private.scroller:Show()
		private.scroller:SetMinMaxValues(0, n-7)
		-- Find the current item
		for i = 1, n do
			if scrollItems[i][1] == private.selected then
				pos = i
				break
			end
		end
	end
	private.scroller:SetValue(math.max(0, math.min(n-7, pos-4)))
	private:SetScroll()
end

function private:SetScroll()
	local pos = private.scroller:GetValue()
	for i = 0, 7 do
		local item = scrollItems[pos+i]
		local button = private.items[i+1]
		if item then
			button.icon:SetTexture(item[3])
			local _,_,_, hex = GetItemQualityColor(item[4])
			button.name:SetText(hex.."["..item[2].."]|r")
			button:Show()
			if (item[1] == private.selected) then
				button.bg:Show()
			else
				button.bg:Hide()
			end
		else
			button:Hide()
		end
	end
end

function private:SelectItem(...)
	private.selected = self.id
	private:SetScroll()
	private:SetVisibility()
end

function private:SetVisibility()
	if private.selected and private.selected ~= "" then
		private.itemModel.setting = "util.appraiser.item."..private.selected..".model"
		private.itemStack.setting = "util.appraiser.item."..private.selected..".stack"
		private.itemFixBid.setting = "util.appraiser.item."..private.selected..".fixed.bid"
		private.itemFixBuy.setting = "util.appraiser.item."..private.selected..".fixed.buy"
		private.gui.Refresh()

		private.itemModel:Show()
		private.itemStack:Show()
		private.itemStack.textEl:Show()
		if AucAdvanced.Settings.GetSetting("util.appraiser.item."..private.selected..".model") == "fixed" then
			private.itemFixBid:Show()
			private.itemFixBid.textEl:Show()
			private.itemFixBuy:Show()
			private.itemFixBuy.textEl:Show()
		else
			private.itemFixBid:Hide()
			private.itemFixBid.textEl:Hide()
			private.itemFixBuy:Hide()
			private.itemFixBuy.textEl:Hide()
		end
	else
		private.itemModel:Hide()
		private.itemStack:Hide()
		private.itemStack.textEl:Hide()
		private.itemFixBid:Hide()
		private.itemFixBid.textEl:Hide()
		private.itemFixBuy:Hide()
		private.itemFixBuy.textEl:Hide()
	end
end

-- Configure our defaults
AucAdvanced.Settings.SetDefault("util.appraiser.enable", false)
AucAdvanced.Settings.SetDefault("util.appraiser.model", "market")
AucAdvanced.Settings.SetDefault("util.appraiser.duration", 1440)
AucAdvanced.Settings.SetDefault("util.appraiser.round.bid", false)
AucAdvanced.Settings.SetDefault("util.appraiser.round.buy", false)
AucAdvanced.Settings.SetDefault("util.appraiser.round.method", "unit")
AucAdvanced.Settings.SetDefault("util.appraiser.round.position", 0.00)
AucAdvanced.Settings.SetDefault("util.appraiser.round.magstep", 5)
AucAdvanced.Settings.SetDefault("util.appraiser.bid.markdown", 10)
AucAdvanced.Settings.SetDefault("util.appraiser.bid.subtract", 0)
AucAdvanced.Settings.SetDefault("util.appraiser.bid.deposit", false)

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	id = gui.AddTab(lib.name)
	gui.MakeScrollable(id)
	
	gui.AddControl(id, "Header",     0,    lib.name.." options")
	gui.AddControl(id, "Checkbox",   0, 1, "util.appraiser.enable", "Show appraisal in the tooltips?")
	gui.AddControl(id, "Subhead",    0,    "Default pricing model")
	gui.AddControl(id, "Selectbox",  0, 1, private.GetPriceModels, "util.appraiser.model", "Default pricing model to use for appraisals")
	gui.AddControl(id, "Selectbox",  0, 1, private.durations, "util.appraiser.duration", "Default listing duration")

	gui.AddControl(id, "Note",       0, 2, 500, 40,
"This is the pricing model that will be used by default for all items. You may change the individual pricing models on a per item basis when creating the auctions"
	)

	gui.AddControl(id, "Subhead",    0,    "Starting bid calculation")
	gui.AddControl(id, "WideSlider", 0, 1, "util.appraiser.bid.markdown", 0, 100, 0.1, "Markdown by: %d%%")
	gui.AddControl(id, "MoneyFramePinned", 0, 1, "util.appraiser.bid.subtract", 0, 9999999, "Subtract amount:")
	gui.AddControl(id, "Checkbox",   0, 1, "util.appraiser.bid.deposit", "Subtract deposit cost")
	gui.AddControl(id, "Note",       0, 2, 500, 60,
"Except for fixed price items, the starting bid price is calculated based off the original buyout price.\n"..
"The above options allow you to specify how the bid price is reduced, and the options are cumulative, so if you set both a markdown percent, and subtract the deposit cost, then the bid value will be calculated as Buyout-Markdown-Deposit"
	)

	gui.AddControl(id, "Subhead",    0,    "Value rounding")
	gui.AddControl(id, "Checkbox",   0, 1, "util.appraiser.round.bid", "Round starting bid")
	gui.AddControl(id, "Checkbox",   0, 1, "util.appraiser.round.buy", "Round buyout value")
	gui.AddControl(id, "Selectbox",  0, 1, {{"unit","Stop value"},{"div","Divisions"}}, "util.appraiser.round.method", "Rounding method to use")
	gui.AddControl(id, "WideSlider", 0, 1, "util.appraiser.round.position", 0, 0.99, 0.01, "Rounding at: %0.02f")
	gui.AddControl(id, "WideSlider", 0, 1, "util.appraiser.round.magstep", 0, 100, 1, "Step magnitude at: %d")
	gui.AddControl(id, "Note",       0, 2, 500, 150,
"If you like your numbers being rounded off to a certain division (eg: multiples of 0.25 = 0.25, 0.50, 0.75, etc), or at a certain stop value (always at 0.95, 0.99, etc) then you can activate this option here.\n"..
"The method of rounding can be either at a fixed stop value (eg 0.95) or at a given division interval (eg 0.25).\n"..
"You set the rounding position by setting the slider to the value you want the number to be rounded to.\n"..
"Finally, set the magnitude step position to the place where you want the rounding to step-up to the next place (eg if this is set to 5, then 4g 72s 15c will round at the copper position, but 5g 72s 15c will round at the silver position)"
	)

	--[[
	gui.AddControl(id, "Subhead",    0,    "Item pricing models")

	local last = gui.GetLast(id)

	gui.scalewidth = 0.4
	local content = gui.tabs[id][3]

	local box = CreateFrame("Frame", nil, content)

	local filter = gui.AddControl(id, "Text", 0.01, 1, "util.appraiser.filter", "");
	filter.textEl:Hide()
	filter.textEl:SetHeight(0)
	filter:SetBackdropColor(0, 0, 0.6, 0.8)
	filter:SetTextInsets(50,0,0,0)
	filter.clearance = -5
	filter.text = filter:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	filter.text:SetPoint("LEFT", filter, "LEFT", 3,0)
	filter.text:SetText("Filter:")
	AucAdvanced.Settings.SetSetting('util.appraiser.filter', "")
	
	private.items = {}
	for i=1, 8 do
		local frame = CreateFrame("Button", "AucApraiserItem"..i, box)
		private.items[i] = frame
		frame:SetHeight(20)
		frame:SetScript("OnClick", private.SelectItem)
		frame.id = i

		frame.icon = frame:CreateTexture(nil, "OVERLAY")
		frame.icon:SetHeight(20)
		frame.icon:SetWidth(20)
		frame.icon:SetPoint("LEFT", frame, "LEFT", 0,0)
		frame.icon:SetTexture("Interface\\InventoryItems\\WoWUnknownItem01")

		frame.name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		frame.name:SetJustifyH("LEFT")
		frame.name:SetJustifyV("BOTTOM")
		frame.name:SetPoint("LEFT", frame.icon, "RIGHT", 3,0)
		frame.name:SetText("[None]")

		frame.bg = frame:CreateTexture(nil, "ARTWORK")
		frame.bg:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
		frame.bg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0,0)
		frame.bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0,0)
		frame.bg:SetAlpha(0.6)
		frame.bg:SetBlendMode("ADD")

		frame:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")

		frame.clearance = -3
		gui.AddControl(id, "Custom", 0, 1, frame)
	end
	gui.scalewidth = nil

	box:SetPoint("TOP", filter, "TOP", 0, 5)
	box:SetPoint("LEFT", private.items[8], "LEFT", -5, 0)
	box:SetPoint("BOTTOMRIGHT", private.items[8], "BOTTOMRIGHT", 25, -5)
	box:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	box:SetBackdropColor(0, 0, 0, 0.8)

	local scroller = CreateFrame("Slider", "AucApraiserItemScroll", content);
	scroller:SetPoint("TOPLEFT", private.items[1], "TOPRIGHT", 0,0)
	scroller:SetPoint("BOTTOMLEFT", private.items[8], "BOTTOMRIGHT", 0,0)
	scroller:SetWidth(20)
	scroller:SetOrientation("VERTICAL")
	scroller:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	scroller:SetMinMaxValues(1, 30)
	scroller:SetValue(1)
	scroller:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	scroller:SetBackdropColor(0, 0, 0, 0.8)
	scroller:SetScript("OnValueChanged", private.SetScroll)
	private.scroller = scroller

	local continue = gui.GetLast(id)

	gui.SetLast(id, last)

	private.itemModel = gui.AddControl(id, "Selectbox", 0.5, 1, private.GetExtraPriceModels, "util.appraiser.item.0.model", "Pricing model to use for this item")
	private.itemStack = gui.AddControl(id, "Slider", 0.5, 1, "util.appraiser.item.0.stack", 0, 20, 1, "Stack size: %s")
	private.itemFixBid = gui.AddControl(id, "MoneyFramePinned", 0.5, 1, "util.appraiser.item.0.fixed.bid", 0, 99999999, "Fixed bid:")
	private.itemFixBuy = gui.AddControl(id, "MoneyFramePinned", 0.5, 1, "util.appraiser.item.0.fixed.buy", 0, 99999999, "Fixed buyout:")

	gui.SetLast(id, continue)

	lib.UpdateList()
]]

	private.gui = gui
	private.guiId = id
end


