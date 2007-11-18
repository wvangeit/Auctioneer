
-- Create a new instance of our lib with our parent
local lib, parent, private = AucSearchUI.NewSearcher("General")
if not lib then return end
local print,decode,recycle,acquire,clone,scrub = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()

-- Set our defaults
default("general.name", "")
default("general.name.exact", false)
default("general.name.regexp", false)
default("general.ilevel.min", 0)
default("general.ilevel.max", 150)
default("general.clevel.min", 0)
default("general.clevel.max", 80)

-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	-- Get our tab and populate it with our controls
	id = gui:AddTab("General parameters", "Searches")

	gui:AddControl(id, "Header",     0,      "General search criteria")

	last = gui:GetLast(id)
	gui:SetControlWidth(0.35)
	gui:AddControl(id, "Text",       0,   1, "general.name", "Item name")
	cont = gui:GetLast(id)
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",   0.13, 0, "general.name.exact", "Exact")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",   0.25, 0, "general.name.regexp", "Regexp")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",   0.38, 0, "general.name.invert", "Invert")
	gui:SetLast(id, cont)

	last = cont
	gui:SetControlWidth(0.37)
	gui:AddControl(id, "NumeriSlider",     0,   1, "general.ilevel.min", 0, 200, 1, "Min item level")
	gui:SetControlWidth(0.37)
	gui:AddControl(id, "NumeriSlider",     0,   1, "general.ilevel.max", 0, 200, 1, "Max item level")
	cont = gui:GetLast(id)

	gui:SetLast(id, last)
	gui:SetControlWidth(0.17)
	gui:AddControl(id, "NumeriSlider",     0.6, 0, "general.clevel.min", 0, 80, 1, "Min user level")
	gui:SetControlWidth(0.17)
	gui:AddControl(id, "NumeriSlider",     0.6, 0, "general.clevel.max", 0, 80, 1, "Max user level")

	gui:SetLast(id, cont)
end

function lib.Search(item)
	if private.NameSearch(item[Const.NAME])
	and private.LevelSearch("ilevel", item[Const.ILEVEL])
	and private.LevelSearch("clevel", item[Const.ULEVEL])
	then return true end
end

function private.LevelSearch(levelType, itemLevel)
	local min = get("general."..levelType..".min")
	local max = get("general."..levelType..".max")

	if itemLevel < min then return false end
	if itemLevel > max then return false end
	return true
end

function private.NameSearch(itemName)
	local name = get("general.name")

	-- If there's no name, then this matches
	if not name or name == "" then return true end

	-- Lowercase the input
	name = name:lower()
	itemName = itemName:lower()

	-- Get the matching options
	local nameExact = get("general.name.exact")
	local nameRegexp = get("general.name.regexp")
	local nameInvert = get("general.name.invert")

	-- if we need to make a non-regexp, exact match:
	if nameExact and not nameRegexp then
		-- If the name matches or we are inverted
		if name == itemName and not nameInvert then
			return true
		elseif name ~= itemName and nameInvert then
			return true
		end
		return false
	end

	local plain, text
	text = name
	if not nameRegexp then
		plain = 1
	elseif nameExact then
		text = "^"..name.."$"
	end

	local matches = itemName:find(text, 1, plain)
	if matches and not nameInvert then
		return true
	elseif not matches and nameInvert then
		return true
	end
	return false
end

AucAdvanced.RegisterRevision("$URL: http://dev.norganna.org/auctioneer/trunk/Auctioneer/AucManifest.lua $", "$Rev: 1746 $")