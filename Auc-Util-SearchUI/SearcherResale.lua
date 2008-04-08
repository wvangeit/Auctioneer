
-- Create a new instance of our lib with our parent
local lib, parent, private = AucSearchUI.NewSearcher("Resale")
if not lib then return end
local print,decode,recycle,acquire,clone,scrub = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "Resale-Buyout"
-- Set our defaults
default("resale.profit.min", 1)
default("resale.profit.pct", 50)
default("resale.seen.check", false)
default("resale.seen.min", 10)
default("resale.adjust.basis", "faction")
default("resale.adjust.deposit", true)
default("resale.adjust.listings", 3)

local ahList = {
	{"faction", "Faction AH Fees"},
	{"neutral", "Neutral AH Fees"},
}

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
	gui:AddControl(id, "Subhead",           0.42,    "Fees Adjustment")
	gui:AddControl(id, "Checkbox",          0.42, 1, "resale.adjust.brokerage", "Subtract auction fees")
	gui:AddControl(id, "Checkbox",          0.42, 1, "resale.adjust.deposit", "Subtract deposit")
	gui:AddControl(id, "Slider",            0.42, 1, "resale.adjust.listings", 1, 10, .1, "Ave relistings: %0.1fx")
	
end

function lib.Search(item)
	if (not item[Const.BUYOUT]) or (item[Const.BUYOUT] == 0) then
		return
	end
	local price = 0
	local market, seen, _, curModel
	
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
		local amount = AucAdvanced.Post.GetDepositAmount(item[Const.LINK], item[Const.COUNT])
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
	if item[Const.BUYOUT] <= value then
		return true
	end
end

AucAdvanced.RegisterRevision("$URL: http://dev.norganna.org/auctioneer/trunk/Auc-Util-SearchUI/SearcherGeneral.lua $", "$Rev: 2531 $")