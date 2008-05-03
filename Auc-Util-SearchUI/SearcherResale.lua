
-- Create a new instance of our lib with our parent
local lib, parent, private = AucSearchUI.NewSearcher("Resale")
if not lib then return end
local print,decode,recycle,acquire,clone,scrub = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "Resale"
-- Set our defaults
default("resale.profit.min", 1)
default("resale.profit.pct", 50)
default("resale.seen.check", false)
default("resale.seen.min", 10)
default("resale.adjust.brokerage", true)
default("resale.adjust.deposit", true)
default("resale.adjust.listings", 3)
default("resale.allow.bid", true)
default("resale.allow.buy", true)

-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	-- Get our tab and populate it with our controls
	local id = gui:AddTab(lib.tabname, "Searches")

	gui:AddControl(id, "Header",     0,      "Resale search criteria")

	local last = gui:GetLast(id)
	
	gui:AddControl(id, "MoneyFramePinned",  0, 1, "resale.profit.min", 1, 99999999, "Minimum Profit")
	gui:AddControl(id, "Slider",            0, 1, "resale.profit.pct", 1, 100, .5, "Min Discount: %0.01f%%")
	gui:AddControl(id, "Checkbox",          0, 1, "resale.seen.check", "Check Seen count")
	gui:AddControl(id, "Slider",            0, 2, "resale.seen.min", 1, 100, 1, "Min seen count: %s")
	
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.42, 1, "resale.allow.bid", "Allow Bids")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.56, 1, "resale.allow.buy", "Allow Buyouts")

	gui:AddControl(id, "Subhead",           0.42,    "Fees Adjustment")
	gui:AddControl(id, "Checkbox",          0.42, 1, "resale.adjust.brokerage", "Subtract auction fees")
	gui:AddControl(id, "Checkbox",          0.42, 1, "resale.adjust.deposit", "Subtract deposit")
	gui:AddControl(id, "Slider",            0.42, 1, "resale.adjust.listings", 1, 10, .1, "Ave relistings: %0.1fx")
end

function lib.Search(item)
	local market, seen, _, curModel, pctstring
	
	market, _, _, seen, curModel = AucAdvanced.Modules.Util.Appraiser.GetPrice(item[Const.LINK])
	if not market then
		return
	end
	
	if (get("resale.seen.check")) and curModel ~= "fixed" then
		if ((not seen) or (seen < get("resale.seen.min"))) then
			return
		end
	end
	
	--adjust for brokerage/deposit costs
	local deposit = get("resale.adjust.deposit")
	local brokerage = get("resale.adjust.brokerage")
	
	if brokerage then
		market = market * 0.95
	end
	if deposit then
		local relistings = get("resale.adjust.listings")
		local rate = AucAdvanced.depositRate or 0.05
		local newfaction
		if rate == .25 then newfaction = "neutral" end
		local amount = GetDepositCost(item[Const.LINK], 12, newfaction, item[Const.COUNT])
		if not amount then
			amount = 0
		else
			amount = amount * relistings
		end
		market = market - amount
	end
	
	local pct = get("resale.profit.pct")
	local minprofit = get("resale.profit.min")
	local value = market * (100-pct) / 100
	if value > (market - minprofit) then
		value = market - minprofit
	end
	if get("resale.allow.buy") and (item[Const.BUYOUT] > 0) and (item[Const.BUYOUT] <= value) then
		if AucAdvanced.Modules.Util.PriceLevel then
			local level, _, r, g, b = AucAdvanced.Modules.Util.PriceLevel.CalcLevel(item[Const.LINK], item[Const.COUNT], item[Const.PRICE], item[Const.BUYOUT], market)
			if level then
				level = math.floor(level)
				r = r*255
				g = g*255
				b = b*255
				pctstring = string.format("|cff%06d|cff%02x%02x%02x"..level, level, r, g, b) -- first color code is to allow
			end
		end
		return "buy", market, pctstring
	elseif get("resale.allow.bid") and (item[Const.PRICE] <= value) then
		if AucAdvanced.Modules.Util.PriceLevel then
			local level, _, r, g, b = AucAdvanced.Modules.Util.PriceLevel.CalcLevel(item[Const.LINK], item[Const.COUNT], item[Const.PRICE], item[Const.PRICE], market)
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