﻿--[[

	Enchantrix v<%version%> (<%codename%>)
	$Id$

	By Norganna
	http://enchantrix.org/

	This is an addon for World of Warcraft that add a list of what an item
	disenchants into to the items that you mouse-over in the game.

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

]]
Enchantrix_RegisterRevision("$URL$", "$Rev$")

-- Local functions
local addonLoaded
local onLoad
local pickupInventoryItemHook
local useContainerItemHook
local onEvent

Enchantrix.Version = "<%version%>"
if (Enchantrix.Version == "<".."%version%>") then
	Enchantrix.Version = "3.9.DEV"
end

local DisenchantEvent = {}

-- This function differs from onLoad in that it is executed
-- after variables have been loaded.
function addonLoaded(hookArgs, event, addOnName)
	if (event ~= "ADDON_LOADED") or (addOnName:lower() ~= "enchantrix") then
		return
	end
	Stubby.UnregisterEventHook("ADDON_LOADED", "Enchantrix")

	-- Call AddonLoaded for other objects
	Enchantrix.Storage.AddonLoaded() -- Sets up saved variables so should be called first
	Enchantrix.Command.AddonLoaded()
	Enchantrix.Config.AddonLoaded()
	Enchantrix.Locale.AddonLoaded()
	Enchantrix.Tooltip.AddonLoaded()
	Enchantrix.MiniIcon.Reposition()

	Enchantrix.Revision = Enchantrix.Util.GetRevision("$Revision$")
	for name, obj in pairs(Enchantrix) do
		if type(obj) == "table" then
			Enchantrix.Revision = math.max(Enchantrix.Revision, Enchantrix.Util.GetRevision(obj.Revision))
		end
	end

	-- Register disenchant detection hooks (using secure post hooks)
	hooksecurefunc("UseContainerItem", useContainerItemHook)
	hooksecurefunc("PickupInventoryItem", pickupInventoryItemHook)

	-- events that we need to catch
	Stubby.RegisterEventHook("UNIT_SPELLCAST_SUCCEEDED", "Enchantrix", onEvent)
	Stubby.RegisterEventHook("UNIT_SPELLCAST_SENT", "Enchantrix", onEvent)
--	Stubby.RegisterEventHook("UNIT_SPELLCAST_START", "Enchantrix", onEvent)			-- not used right now
--	Stubby.RegisterEventHook("UNIT_SPELLCAST_STOP", "Enchantrix", onEvent)			-- not used right now
	Stubby.RegisterEventHook("UNIT_SPELLCAST_FAILED", "Enchantrix", onEvent)
	Stubby.RegisterEventHook("UNIT_SPELLCAST_INTERRUPTED", "Enchantrix", onEvent)
	Stubby.RegisterEventHook("LOOT_OPENED", "Enchantrix", onEvent)
--	Stubby.RegisterEventHook("ZONE_CHANGED", "Enchantrix", onEvent)			-- not used right now

	-- and hook into tooltips for more info
	hooksecurefunc("GameTooltip_OnHide", ENX_GameTooltip_OnHide);
	hooksecurefunc("GameTooltip_SetDefaultAnchor", ENX_GameTooltip_SetDefaultAnchor);
	ENX_SetTooltipHooks("GameTooltip");
	ENX_SetTooltipHooks("ItemRefTooltip");
	ENX_SetTooltipHooks("ShoppingTooltip1");
	ENX_SetTooltipHooks("ShoppingTooltip2");

	-- now print our version and credits
	local vstr = ("%s-%d"):format(Enchantrix.Version, Enchantrix.Revision)
	Enchantrix.Util.ChatPrint(_ENCH('FrmtWelcome'):format(vstr), 0.8, 0.8, 0.2)
	Enchantrix.Util.ChatPrint(_ENCH('FrmtCredit'), 0.6, 0.6, 0.1)
	
	-- check for auctioneer and version
	Enchantrix.Command.AuctioneerLoaded();
	
end

-- Register our temporary command hook with stubby
function onLoad()
	Stubby.RegisterBootCode("Enchantrix", "CommandHandler", [[
		local function cmdHandler(msg)
			local i,j, cmd, param = msg:lower():find("^([^ ]+) (.+)$")
			if (not cmd) then cmd = msg:lower() end
			if (not cmd) then cmd = "" end
			if (not param) then param = "" end
			if (cmd == "load") then
				if (param == "") then
					Stubby.Print("Manually loading Enchantrix...")
					LoadAddOn("Enchantrix")
				elseif (param == "always") then
					Stubby.Print("Setting Enchantrix to always load for this character")
					Stubby.SetConfig("Enchantrix", "LoadType", param)
					LoadAddOn("Enchantrix")
				elseif (param == "never") then
					Stubby.Print("Setting Enchantrix to never load automatically for this character (you may still load manually)")
					Stubby.SetConfig("Enchantrix", "LoadType", param)
				else
					Stubby.Print("Your command was not understood")
				end
			else
				Stubby.Print("Enchantrix is currently not loaded.")
				Stubby.Print("  You may load it now by typing |cffffffff/enchantrix load|r")
				Stubby.Print("  You may also set your loading preferences for this character by using the following commands:")
				Stubby.Print("  |cffffffff/enchantrix load always|r - Enchantrix will always load for this character")
				Stubby.Print("  |cffffffff/enchantrix load never|r - Enchantrix will never load automatically for this character (you may still load it manually)")
			end
		end
		SLASH_ENCHANTRIX1 = "/enchantrix"
		SLASH_ENCHANTRIX2 = "/enchant"
		SLASH_ENCHANTRIX3 = "/enx"
		SlashCmdList["ENCHANTRIX"] = cmdHandler
	]]);

	Stubby.RegisterBootCode("Enchantrix", "Triggers", [[
		if Stubby.GetConfig("Enchantrix", "LoadType") == "always" then
			LoadAddOn("Enchantrix")
		else
			Stubby.Print("]].._ENCH('MesgNotloaded')..[[")
		end
	]]);
	
	SLASH_ENCHANTRIX1 = "/enchantrix";
	SLASH_ENCHANTRIX2 = "/enchant";
	SLASH_ENCHANTRIX3 = "/enx";
	SlashCmdList["ENCHANTRIX"] = function(msg) Enchantrix.Command.HandleCommand(msg) end

	Stubby.RegisterEventHook("ADDON_LOADED", "Enchantrix", addonLoaded)
end


-- Big thanks to FizzWidget for figuring out how to get the tooltips hooked
-- names have been changed to prevent conflicts
ENX_TooltipHooks = {};

function ENX_GameTooltip_OnHide()
	local tooltipName = this:GetName();
	ENX_SetTooltipHooks(tooltipName);
end

function ENX_GameTooltip_SetDefaultAnchor(tooltip, parent)
	local tooltipName = tooltip:GetName();
	ENX_SetTooltipHooks(tooltipName);
end

function ENX_SetTooltipHooks(tooltipName)
	if (not tooltipName or tooltipName == "") then return; end
	local tooltip = getglobal(tooltipName);
	if (tooltip and tooltip:HasScript("OnTooltipSetItem") and not ENX_TooltipHooks[tooltipName]) then
		ENX_TooltipHooks[tooltipName] = {};
		ENX_TooltipHooks[tooltipName].OnTooltipSetItem = tooltip:GetScript("OnTooltipSetItem");
		tooltip:SetScript("OnTooltipSetItem", ENX_OnTooltipSetItem);
	end
end

function ENX_OnTooltipSetItem()
	local tooltipName = this:GetName();
	local tooltip = getglobal(tooltipName);
	if (ENX_TooltipHooks[tooltipName] and ENX_TooltipHooks[tooltipName].OnTooltipSetItem) then
		ENX_TooltipHooks[tooltipName].OnTooltipSetItem(tooltip);
	end
	local name, link = this:GetItem();
	if (link) then
		-- first, make sure that we think this item is disenchantable to start with (reduce false positives)
		if (Enchantrix.Util.GetIType(link)) then
			-- Ok, we think the item is disenchantable
			-- search the tooltip text for the non-disenchantable string
			for lineNum = 1, this:NumLines() do
				local leftText = getglobal(this:GetName().."TextLeft"..lineNum):GetText();
				if (leftText == ITEM_DISENCHANT_NOT_DISENCHANTABLE) then
					-- found the string, this item really isn't disenchantable
					Enchantrix.Storage.SaveNonDisenchantable(link)
					-- no need to continue
					return false;
				end
				
			end
		end
	end
	return false;
end

function pickupInventoryItemHook(slot)
	-- Remember last activated item
	if (not UnitCastingInfo("player")) then
		if slot then
			DisenchantEvent.spellTarget = GetInventoryItemLink("player", slot)
			DisenchantEvent.targetted = GetTime()
		end
	end
end

function useContainerItemHook(bag, slot)
	-- Remember last activated item
	if (not UnitCastingInfo("player")) then
		if bag and slot then
			DisenchantEvent.spellTarget = GetContainerItemLink(bag, slot)
			DisenchantEvent.targetted = GetTime()
		end
	end
end

function onEvent(funcVars, event, player, spell, rank, target)

	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		-- NOTE: we do get the spell name here
		DisenchantEvent.finished = nil
		if spell == _ENCH('ArgSpellname') then
			if (DisenchantEvent.spellTarget and GetTime() - DisenchantEvent.targetted < 10) then
				DisenchantEvent.finished = DisenchantEvent.spellTarget
			end
		end
		DisenchantEvent.sent = nil
	elseif event == "UNIT_SPELLCAST_FAILED" then
		-- NOTE: we don't get the spell name here
		-- Successful disenchant: SENT, START, STOP, SUCCEEDED
		-- Events for failed disenchant are: SENT, (sometimes START), FAILED
		-- For an item above our level, the events are: SENT, FAILED
		if (DisenchantEvent.sent
			and DisenchantEvent.spellTarget
			and GetTime() - DisenchantEvent.targetted < 5) then
			-- first, make sure that we think this item is disenchantable to start with (reduce false positives)
			if (Enchantrix.Util.GetIType(DisenchantEvent.spellTarget)) then
				-- this means that the item is not disenchantable, but we think it is!
				-- now make sure the user had enough skill to disenchant it
				-- make sure skill level is up to date
				local skill = Enchantrix.Util.GetUserEnchantingSkill();
				-- get the maximum item level the user can disenchant
				local maxLevel = Enchantrix.Util.MaxDisenchantItemLevel(skill);
				local name, link, _, itemLevel = GetItemInfo( DisenchantEvent.spellTarget );
				if (itemLevel <= maxLevel) then
					Enchantrix.Storage.SaveNonDisenchantable(DisenchantEvent.spellTarget)
				end
			end
		end
		DisenchantEvent.finished = nil
		DisenchantEvent.sent = nil
	elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
		-- disenchant interrupted
		DisenchantEvent.finished = nil
		DisenchantEvent.sent = nil
		DisenchantEvent.spellTarget = nil
		DisenchantEvent.targetted = nil

--[[
-- left here for debugging purposes
	elseif event == "UNIT_SPELLCAST_START" then
		-- NOTE: we don't get the spell name here
		Enchantrix.Util.DebugPrint("Spellcast", ENX_INFO, "cast start", "info:", funcVars, event, spell, rank, target )

	elseif event == "UNIT_SPELLCAST_STOP" then
		Enchantrix.Util.DebugPrint("Spellcast", ENX_INFO, "cast stop", "info:", funcVars, event, spell, rank, target )
]]

	elseif event == "UNIT_SPELLCAST_SENT" then
		-- NOTE: we do get the spell name here
		if spell == _ENCH('ArgSpellname') then
			if (DisenchantEvent.spellTarget and GetTime() - DisenchantEvent.targetted < 10) then
				DisenchantEvent.sent = true;
			end
		else
			DisenchantEvent.sent = nil;
			DisenchantEvent.spellTarget = nil;
		end
	elseif event == "LOOT_OPENED" then
		if DisenchantEvent.finished then
			Enchantrix.Util.ChatPrint(_ENCH("FrmtFound"):format(DisenchantEvent.finished))
			local sig = Enchantrix.Util.GetSigFromLink(DisenchantEvent.finished)
			for i = 1, GetNumLootItems(), 1 do
				if LootSlotIsItem(i) then
					local icon, name, quantity, rarity = GetLootSlotInfo(i)
					local link = GetLootSlotLink(i)
					Enchantrix.Util.ChatPrint(("  %s x%d"):format(link, quantity))
					-- Save result
					local reagentID = Enchantrix.Util.GetItemIdFromLink(link)
					if reagentID then
						Enchantrix.Storage.SaveDisenchant(sig, reagentID, quantity)
					end
				end
			end
		end
		DisenchantEvent.spellTarget = nil
		DisenchantEvent.targetted = nil
		DisenchantEvent.finished = nil
		DisenchantEvent.sent = nil
	end
end

-- Execute on load
onLoad()
