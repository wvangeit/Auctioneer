--[[
WatchDatabase WoW AddOn
-----------------------
This addon is (c)2006 norganna.org
You are granted the right to copy and use this addon for personal uses and only in it's unaltered state.
You may not host nor distribute this addon in any fashion. All rights are reserved by Norganna's AddOns.
http://norganna.org/watcher/
-----------------------
$Id$
]]

Watcher.lootSpells = {
	["Disenchant"] = "Disenchant",
	["Désenchanter"] = "Disenchant",
	["Entzaubern"] = "Disenchant",
	["Herb Gathering"] = "Herbalism",
	["Cueillette"] = "Herbalism",
	["Kräutersammeln"] = "Herbalism",
	["Mining"] = "Mining",
	["Minage"] = "Mining",
	["Bergbau"] = "Mining",
	["Opening"] = "Opening",
	["Ouverture"] = "Opening",
	["Öffnen"] = "Opening",
	["Skinning"] = "Skinning",
	["Dépeçage"] = "Skinning",
	["Kürschnerei"] = "Skinning",
}
Watcher.curSpell = {}
Watcher.itemUse = {}

Watcher.processSpellEvent = function(event, a1,a2)
	if (event == "SPELLCAST_START") then
		-- Start tracking this spell
		if (Watcher.lootSpells[a1]) then
			Watcher.curSpell.spell = Watcher.lootSpells[a1]
		else
			Watcher.curSpell.spell = a1
		end
		if (not a2) then
			Watcher.debug("Not tracking instant cast spell: "..a1)
			return
		end
		Watcher.curSpell.duration = (a2/1000)
		Watcher.curSpell.start = time()
		Watcher.curSpell.ended = nil
		Watcher.debug("Now tracking spell: "..Watcher.curSpell.spell.." for "..Watcher.curSpell.duration.."s");
	elseif (event == "SPELLCAST_STOP") and (Watcher.curSpell.spell) then
		Watcher.curSpell.ended = time()
		local dur = Watcher.curSpell.ended - Watcher.curSpell.start
		local diff = dur - Watcher.curSpell.duration
		-- If the cast spell finished more than 10s after it was supposed to or 
		-- less than 1s before it was supposed to, cancel the tracking.
		if (diff < -1) or (diff > 10) then
			Watcher.debug("Cancelling out of time spell: "..Watcher.curSpell.spell);
			Watcher.curSpell.spell = nil
			Watcher.curSpell.target = nil
			Watcher.curSpell.duration = 0
			Watcher.curSpell.start = 0
			Watcher.curSpell.ended = nil
		else
			Watcher.debug("Found spell: "..Watcher.curSpell.spell);
		end
	elseif ((event == "SPELLCAST_INTERRUPTED") or (event == "SPELLCAST_FAILED")) then
		-- Spell failed, cancel the tracking
		Watcher.curSpell.spell = nil
		Watcher.curSpell.target = nil
		Watcher.curSpell.duration = 0
		Watcher.curSpell.start = 0
		Watcher.curSpell.ended = nil
		Watcher.debug("Cancelling failed spell");
	end
end

Watcher.processInventoryTarget = function(button, ignore)
	local bag = this:GetParent():GetID()
	local slot = this:GetID()

	if SpellIsTargeting() then
		local link = GetContainerItemLink(bag, slot)
		if (link) then
			Watcher.curSpell.target = link
			Watcher.debug("Found targetted item: "..link);
		end
	elseif (button == "RightButton") then
		local link = GetContainerItemLink(bag, slot)
		Watcher.itemUse.target = link
		Watcher.itemUse.time = time()
	end
end

Watcher.checkSpells = function()
	local now = time()
	if (Watcher.curSpell.ended) then
		local diff = now - Watcher.curSpell.ended
		-- Check to make sure this loot box corresponds to the 
		-- last cast spell
		if (diff < -1) or (diff > 10) then 
			Watcher.debug("Spell failed because time differential is "..diff);
			return "anonymous"
		else
			if (Watcher.curSpell.target) then
				-- This is a result of a spell on an item
				local itemDes = Watcher.getItemDes(Watcher.curSpell.target, 1)
				return string.format("spell:%s:i:%d", Watcher.curSpell.spell, itemDes)
			elseif UnitName("npc") then
				-- This is a result of a spell on an npc or doodad (doodad doesn't have a level)
				if (CheckInteractDistance("npc", 1)) then
					return string.format("spell:%s:u:%s", Watcher.curSpell.spell, UnitName("npc"))
				elseif (not UnitLevel("npc")) then
					return string.format("spell:%s:d:%s", Watcher.curSpell.spell, UnitName("npc"))
				end
			else
				return string.format("spell:%s:n", Watcher.curSpell.spell);
			end
		end
	else
		Watcher.debug("Spell hasn't ended yet");
	end

	-- Ok, Lets check the right-clicks
	if (Watcher.itemUse.time) then
		local diff = now - Watcher.itemUse.time
		if (diff > -1 and diff < 2) then
			-- This loot box appeared just after right-clicking an item
			local itemDes = Watcher.getItemDes(Watcher.itemUse.target, 1)
			return string.format("item:%d", itemDes)
		end
	end
	return "anonymous"
end

Watcher.checkSkinning = function()
	if (Watcher.curSpell.ended) then
		if (Watcher.curSpell.spell == "Skinning") then
			if (Watcher.checkSpells() ~= "anonymous") then
				return true
			end
		end
	end
	return false
end
