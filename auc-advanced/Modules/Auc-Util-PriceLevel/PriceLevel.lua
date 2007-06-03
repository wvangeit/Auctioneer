--[[
	Auctioneer Advanced - Price Level Utility module
	Revision: $Id$
	Version: <%version%>

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

local libName = "PriceLevel"
local libType = "Util"

AucAdvanced.Modules[libType][libName] = {}
local lib = AucAdvanced.Modules[libType][libName]
local private = {}
local print = AucAdvanced.Print

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
		lib.ProcessTooltip(...)
	elseif (callbackType == "config") then
		private.SetupConfigGui(...)
	elseif (callbackType == "listupdate") then
		private.ListUpdate(...)
	end
end

function lib.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost, additional)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine whether or what you should
	-- display in the tooltip.
	if not additional or additional[0] ~= "AuctionPrices" then return end
	local buyPrice, bidPrice = additional[1], additional[3]

	local priceLevel, perItem, r,g,b = private.CalcLevel(hyperlink, quantity, bidPrice, buyPrice)
	if (not priceLevel) then return end

	EnhTooltip.AddLine(("Price Level: %d%%"):format(priceLevel), perItem)
	EnhTooltip.LineColor(r,g,b)
end

function lib.OnLoad()
	AucAdvanced.Settings.SetDefault("util.pricelevel.colorize", true)
	AucAdvanced.Settings.SetDefault("util.pricelevel.single", true)
	AucAdvanced.Settings.SetDefault("util.pricelevel.model", "market")
	AucAdvanced.Settings.SetDefault("util.pricelevel.basis", "buy")
	AucAdvanced.Settings.SetDefault("util.pricelevel.yellow", 95)
	AucAdvanced.Settings.SetDefault("util.pricelevel.orange", 115)
	AucAdvanced.Settings.SetDefault("util.pricelevel.red", 130)
end

--[[ Local functions ]]--

function private.GetPriceModels()
	if not private.scanValueNames then private.scanValueNames = {} end
	for i = 1, #private.scanValueNames do
		private.scanValueNames[i] = nil
	end

	table.insert(private.scanValueNames,{"market", "Market value"})
	local algoList = AucAdvanced.API.GetAlgorithms()
	for pos, name in ipairs(algoList) do
		table.insert(private.scanValueNames,{name, "Stats: "..name})
	end
	return private.scanValueNames
end

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	id = gui.AddTab(libName)
	gui.AddControl(id, "Header",     0,    libName.." options")
	gui.AddControl(id, "Checkbox",   0, 1, "util.pricelevel.single", "Show unit price of stacked item in the tooltip")
	gui.AddControl(id, "Checkbox",   0, 1, "util.pricelevel.colorize", "Change the color of items in the Auction House")
	gui.AddControl(id, "Subhead",    0,    "Price valuation method:")
	gui.AddControl(id, "Selectbox",  0, 1, private.GetPriceModels, "util.pricelevel.model", "Pricing model to use for the valuation")
	gui.AddControl(id, "Subhead",    0,    "Price level basis:")
	gui.AddControl(id, "Selectbox",  0, 1, {
		{"cur", "Next bid price"},
		{"buy", "Buyout only"},
		{"try", "Buyout or bid"},
	}, "util.pricelevel.basis", "Which price to use for the price level")
	gui.AddControl(id, "Subhead",    0,    "Pricing points:")
	gui.AddControl(id, "WideSlider", 0, 1, "util.pricelevel.yellow", 0, 500, 5, "Yellow price level: %d%%")
	gui.AddControl(id, "WideSlider", 0, 1, "util.pricelevel.orange", 0, 500, 5, "Orange price level: %d%%")
	gui.AddControl(id, "WideSlider", 0, 1, "util.pricelevel.red",    0, 500, 5, "Red price level: %d%%")
end

function private.ResetBars()
	local tex
	for i=1, NUM_BROWSE_TO_DISPLAY do
		tex = getglobal("BrowseButton"..i.."PriceLevel")
		if (tex) then tex:Hide() end
	end
end

function private.SetBar(i, r,g,b, pct)
	local tex
	local button = getglobal("BrowseButton"..i)
	if (button.AddTexture) then
		tex = button.AddTexture
		if (button.Value) then
			if (pct) then
				if pct > 999 then
					button.Value:SetText(">999%")
				else
					button.Value:SetText(("%d%%"):format(pct))
				end
				button.Value:SetTextColor(r,g,b)
			else
				button.Value:SetText("")
				button.Value:SetTextColor(1,1,1)
			end
		end
	else
		tex = getglobal("BrowseButton"..i.."PriceLevel")
	end
	if not tex then
		tex = button:CreateTexture("BrowseButton"..i.."PriceLevel")
		tex:SetPoint("TOPLEFT")
		tex:SetPoint("BOTTOMRIGHT", 0, 5)
	end

	if (r and g and b) then
		tex:SetTexture(1,1,1, 0.33)
		tex:SetGradientAlpha("Horizontal", r,g,b, 0, r,g,b, 0.8)
		tex:Show()
	else
		tex:Hide()
	end
end

function private.ListUpdate()
	private.ResetBars()
	if not AucAdvanced.Settings.GetSetting("util.pricelevel.colorize") then return end

	local index, link, quantity, minBid, minInc, buyPrice, bidPrice, priceLevel, perItem, r,g,b, _
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
	local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
	
	for i=1, NUM_BROWSE_TO_DISPLAY do
		index = offset + i + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page);
		if (index <= numBatchAuctions + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)) then
			link =  GetAuctionItemLink("list", offset + i)
			_,_, quantity, _,_,_, minBid, minInc, buyPrice, bidPrice =  GetAuctionItemInfo("list", offset + i)
			if bidPrice>0 then bidPrice = bidPrice + minInc
			else bidPrice = minBid end
			priceLevel, perItem, r,g,b = private.CalcLevel(link, quantity, bidPrice, buyPrice)
			private.SetBar(i, r,g,b, priceLevel)
		end
	end
end

function private.CalcLevel(link, quantity, bidPrice, buyPrice)
	if not quantity or quantity < 1 then quantity = 1 end

	local showPerUnit = AucAdvanced.Settings.GetSetting("util.pricelevel.single")
	if not showPerUnit then return end
	
	local priceModel = AucAdvanced.Settings.GetSetting("util.pricelevel.model")
	local priceBasis = AucAdvanced.Settings.GetSetting("util.pricelevel.basis")
	local itemWorth

	local stackPrice
	if (priceBasis == "bid") then
		stackPrice = bidPrice
	elseif (priceBasis == "buy") then
		if not buyPrice or buyPrice <= 0 then return end
		stackPrice = buyPrice
	elseif (priceBasis == "try") then
		stackPrice = buyPrice or 0
		if stackPrice <= 0 then
			stackPrice = bidPrice
		end
	end

	if (priceModel == "market") then
		itemWorth = AucAdvanced.API.GetMarketValue(link)
	else
		itemWorth = AucAdvanced.API.GetAlgorithmValue(priceModel, link)
	end
	if not itemWorth then return end

	local perItem = stackPrice / quantity
	local priceLevel = perItem / itemWorth * 100

	local r, g, b = 0.2,1.0,0.2
	if priceLevel > AucAdvanced.Settings.GetSetting("util.pricelevel.red") then
		r,g,b = 1.0,0.0,0.0
	elseif priceLevel > AucAdvanced.Settings.GetSetting("util.pricelevel.orange") then
		r,g,b = 1.0,0.6,0.1
	elseif priceLevel > AucAdvanced.Settings.GetSetting("util.pricelevel.yellow") then
		r,g,b = 1.0,1.0,0.0
	end

	return priceLevel, perItem, r,g,b
end

