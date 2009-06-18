
if not AucAdvanced then return end

local libType, libName = "Util", "Glypher"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()
local tooltip = LibStub("nTipHelper:1")

function lib.Processor(callbackType, ...)
	if (callbackType == "config") then
		private.SetupConfigGui(...)
	elseif (callbackType == "configchanged") then
		private.ConfigChanged(...)
	elseif (callbackType == "auctionui") then
		private.auctionHook() ---When AuctionHouse loads hook the auction function we need
	end
end
--after Auction House Loads Hook the Window Display event
function private.auctionHook()
	hooksecurefunc("AuctionFrameAuctions_Update", private.storeCurrentAuctions)
end

function lib.OnLoad()
	default("util.glypher.moneyframeprofit", 100000)
	default("util.glypher.normalstack", 5)
	default("util.glypher.highstack", 10)
	default("util.glypher.lowstack", 2)
	default("util.glypher.history", 14)
	
	local sideIcon
	if LibStub then
		local SlideBar = LibStub:GetLibrary("SlideBar", true)
		if SlideBar then
			sideIcon = SlideBar.AddButton("Glypher", "Interface\\AddOns\\Auc-Util-Glypher\\Images\\Glypher")
			sideIcon:RegisterForClicks("LeftButtonUp","RightButtonUp") --What type of click you want to respond to
			sideIcon:SetScript("OnClick", privateSlideBarClick) --same function that the addons current minimap button calls
			sideIcon.tip = {
			"BUTTON MOUSEOVER NAME",
			"BUTTON MOUSEOVER DISCRIPTION",
			"{{Click}} BUTTON MOUSEOVER CLICK DESCRIPTION IF WANTED",
			"{{Right-Click}} BUTTON MOUSEOVER CLICK DESCRIPTION IF WANTED",--remove lines if not wanted
			}
		end
	end
	private.sideIcon = sideIcon
end

function privateSlideBarClick(_, button)
	if private.gui and private.gui:IsShown() then
		AucAdvanced.Settings.Hide()
	else
		AucAdvanced.Settings.Show()
		private.gui:ActivateTab(private.id)
	end
end


--[[ Local functions ]]--

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	local id = gui:AddTab(libName, libType.." Modules")

	local SelectBox = LibStub:GetLibrary("SelectBox")
	local ScrollSheet = LibStub:GetLibrary("ScrollSheet")
	--Add Drag slot / Item icon
	frame = gui.tabs[id].content
	private.gui = gui
	private.id = id
	private.frame = frame

	
	gui:AddControl(id, "Subhead", 0, "Glypher: Profitable Glyph Queue")
	gui:AddControl(id, "MoneyFrame", 0, 1, "util.glypher.moneyframeprofit", "Minimum profit needed")
		
	gui:AddControl(id, "Text", 0, 1, "util.glypher.ink", "Ink to use in crafting,  leave blank to use all inks")
	
	gui:AddControl(id, "NumberBox",  0, 1, "util.glypher.highstack", 0, 100, "Number to post for high selling items")
	gui:AddControl(id, "NumberBox",  0, 1, "util.glypher.normalstack", 0, 100, "Number to post for average selling items")
	gui:AddControl(id, "NumberBox",  0, 1, "util.glypher.lowstack", 0, 100, "Number to post for low selling items")

	gui:AddControl(id, "NumeriSlider", 0, 1, "util.glypher.history",    0, 84, 7, "Date range to look for sales")
	
	
	
	frame.searchButton = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.searchButton:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 15, 105)
	frame.searchButton:SetWidth(150)
	frame.searchButton:SetText("Get Profitable Glyphs")
	frame.searchButton:SetScript("OnClick", function() private.findGlyphs() end)
	
	frame.skilletButton = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.skilletButton:SetPoint("TOP", frame.searchButton, "BOTTOM", 0, -5)
	frame.skilletButton:SetWidth(120)
	frame.skilletButton:SetText("Add to TradeSkill")
	frame.skilletButton:SetScript("OnClick", function() private.addtoCraft() end)
		
	
	--Create the glyph list results frame
	frame.glypher = CreateFrame("Frame", nil, frame)
	frame.glypher:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})

	frame.glypher:SetBackdropColor(0, 0, 0.0, 0.5)
	frame.glypher:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 2)
	frame.glypher:SetPoint("BOTTOM", frame, "BOTTOM", 0, 0)
	frame.glypher:SetWidth(310)
	
	
	frame.glypher.sheet = ScrollSheet:Create(frame.glypher, {
		{ "Glyph", "TOOLTIP", 170 },
		{ "#", "NUMBER", 25 },
		{ "Profit", "COIN", 70},
		--{ "index", "TEXT",0 },
		})
	
	function frame.glypher.sheet.Processor(callback, self, button, column, row, order, curDir, ...)
		if (callback == "OnMouseDownCell")  then
			
		elseif (callback == "OnClickCell") then
			
		elseif (callback == "ColumnOrder") then
			
		elseif (callback == "ColumnWidthSet") then
			
		elseif (callback == "ColumnWidthReset") then
			
		elseif (callback == "ColumnSort") then
			
		elseif (callback == "OnEnterCell")  then
			private.sheetOnEnter(button, row, column)
		elseif (callback == "OnLeaveCell") then
			GameTooltip:Hide()
		end
	end
	
end

function private.sheetOnEnter(button, row, column)
	local link, name, _
	link = frame.glypher.sheet.rows[row][column]:GetText() or "FAILED LINK"
	if link:match("^(|c%x+|H.+|h%[.+%])") then
		name = GetItemInfo(link)
	end
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	if frame.glypher.sheet.rows[row][column]:IsShown()then --Hide tooltip for hidden cells
		if link and name then
			GameTooltip:SetHyperlink(link)
		end
	end
end

function private.ConfigChanged(setting, value, ...)
	if setting == "util.glypher.craft" and value then
		private.addtoCraft()
		set("util.glypher.craft", nil) --for some reason teh button will not toggle a setting http://jira.norganna.org/browse/CNFG-89
	
	elseif setting == "util.glypher.getglyphs" and value then
		private.findGlyphs()
		set("util.glypher.getglyphs", nil)
	end
end

function private.findGlyphs()
	local MinimumProfit = get("util.glypher.moneyframeprofit")
	local stacks = get("util.glypher.normalstack")
	local highSeller = get("util.glypher.highstack")
	local lowSeller = get("util.glypher.lowstack")
	local quality = 2 --no rare quality items
	local history = get("util.glypher.history") --how far back in beancounter to look
	local INK =  get("util.glypher.ink") or ""
	
	if not private.auctionCount or not BeanCounter then return end
	
	private.data = {}
	private.Display = {}
	--check that we have inscription as our chosen TS
	local hasInscription = GetSpellInfo("Inscription")
	local currentSelection = GetTradeSkillLine(1)
	if not hasInscription then print("It does not look like this character has Inscription") return end
	
	if currentSelection ~= "Inscription" then
		CastSpellByName("Inscription") --open trade skill
	end
	
	
	for ID = GetFirstTradeSkill(), GetNumTradeSkills() do
		local link = GetTradeSkillItemLink(ID)
		local itemName = GetTradeSkillInfo(ID)
		
		if link and link:match("^|c%x+|Hitem.+|h%[.*%]") and itemName and select(3, GetItemInfo(link)) <= quality then --if its a craftable line and not a header and lower than our Quality
			
			local price = AucAdvanced.API.GetMarketValue(link)
			
			local sold, failed
			if BeanCounter and BeanCounter.API and BeanCounter.API.isLoaded and BeanCounter.API.getAHSoldFailed then
				sold, failed = BeanCounter.API.getAHSoldFailed(UnitName("player"), link, history) --history == days to go back
			end
			local reagentCost = 0
			--Sum the cost of the mats to craft this item, parchment is not considered its realy too cheap to matter
			local inkMatch = false --only match inks choosen by user
			for i = 1 ,GetTradeSkillNumReagents(ID) do
				local inkName, _, count = GetTradeSkillReagentInfo(ID, 1)
				local link = GetTradeSkillReagentItemLink(ID, i)
				local inkPrice = AucAdvanced.API.GetMarketValue(link) or 0
				reagentCost =  (reagentCost + (inkPrice * count) )
				if INK:match("-") then -- ignore a specific ink
					local INK = INK:gsub("-","")
					inkMatch = true
					if inkName:lower():match(INK:lower()) then
						inkMatch = false
					end
				else
					if inkName:lower():match(INK:lower()) then 
						inkMatch = true 
					end
				end
			end
			
			--if we match the ink and our profits high enough, check how many we currently have on AH
			if price and (price - reagentCost) >= MinimumProfit and inkMatch then
				
				local currentAuctions = private.auctionCount[itemName] or 0
				
				local make
				if sold and failed and (sold/failed) > 0.75 then
					-- increase stacks for high selling items
					make = highSeller
				elseif sold and failed and (sold/failed) < 0.25 then
					--decrease stacks for low selling items
					make = lowSeller
				else --use default #
					make = stacks
				end
				
				make = make - currentAuctions
				if make > 0 then
					--print(make ,currentAuctions)
					table.insert(private.data, { ["link"] = link, ["ID"] = ID, ["count"] = make, ["name"] = itemName} )
					table.insert(private.Display, {link, make, price - reagentCost} )
				end
			end
		end
	end
	
	frame.glypher.sheet:SetData(private.Display, Style)
end
--store the players current auctions
function private.storeCurrentAuctions()
	local count = {}
	local _, totalAuctions = GetNumAuctionItems("owner");
	
	if totalAuctions > 0 then
		for i = 1, totalAuctions do
			local name = GetAuctionItemInfo("owner", i)
			if name then
				if not count[name] then
					count[name] = 0
				end
				count[name] = (count[name]+1)
			end
		end
	end
	private.auctionCount = count
	private.auctionCountRefresh = time()
end


function private.addtoCraft()
	if Skillet and Skillet.QueueAppendCommand then
		if not Skillet.reagentsChanged then Skillet.reagentsChanged = {} end --this required table is nil when we use teh queue
		for i, glyph in ipairs(private.data) do
			local command = {}
			--index is needed for skillet to properly make use of our  data
			local _, index = Skillet:GetRecipeDataByTradeIndex(45357, glyph.ID)
			
			command["recipeID"] = index
			command["op"] = "iterate"
			command["count"] = glyph.count
			Skillet:QueueAppendCommand(command, true)
		end
		Skillet:UpdateTradeSkillWindow()
	elseif ATSW_AddJobRecursive then
		for i, glyph in ipairs(private.data) do
			ATSW_AddJobRecursive(glyph.name, glyph.count)
		end
	end
end