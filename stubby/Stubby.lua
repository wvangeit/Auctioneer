--[[  This addon's sole purpose is to hook and execute functions.
----  
----
----
----
--]]
local registerFunctionHook, registerAddonHook, registerTrigger, loadWatcher

local self = {
	notifyFuncs
}

-- This function takes all the items and their requested orders
-- and assigns an actual ordering to them.
local function rebuildNotifications(notifyItems)
	local notifyFuncs = {}
	for hookType, hData in notifyItems do
		notifyFuncs[hookType] = {}

		-- Sort all hooks for this type in ascending numerical order.
		local sortedPositions = {}
		for requestedPos,_ in hData do
			table.insert(sortedPositions, requestedPos)
		end
		table.sort(sortedPositions)

		-- Process the sorted request list and insert in correct
		-- order into the call list.
		for _,requestedPos in sortedPositions do
			local func = hData[requestedPos];
			func.pos = requestedPos;
			table.insert(notifyFuncs[hookType], hData[requestedPos])
		end
	end
	return notifyFuncs
end

-- This function's purpose is to execute all the attached
-- functions in order and the original call at just before
-- position 100.
local function hookCall(funcName, arguments)
	local orig = Stubby.GetOrigFunc(funcName);
	for _,func in pairs(calls.functions[funcName]) do
		if (orig and func.p >= 100) then
			orig(unpack(arguments))
			orig = nil
		end
		func.f(unpack(func.a));
	end
end

-- This function automatically hooks Stubby in place of the
-- original function, dynamically.
Stubby_NewFunction = nil;
local function hookInto(functionName)
	if (hooks.functions[functionName]) then return end
	hooks.origFuncs[functionName] = getglobal(functionName);
	
	RunScript("Stubby_NewFunction = function(...) Stubby.HookCall(\""..functionName.."\", arg) end");
	getglobal(functionName) = Stubby_NewFunction;
	Stubby_NewFunction = nil
end

-- This function causes a given function to be hooked by stubby and
-- configures the hook function to be called at the given position.
function registerFunctionHook(functionName, position, hookFunc, ...)
	local insertPos = tonumber(position) or 200
	local funcObj = { f=hookFunc, a=arg, p=position };

	if (calls.functions[hookType]) then
		while (calls.functions[hookType][insertPos]) do
			insertPos = insertPos + 1
		end
		calls.functions[functionName][insertPos] = funcObj
	end		
	hookInto(functionName)
end

-- This function registers a given function to be called when a given
-- addon is loaded, or immediatly if it is already loaded (this can be
-- used to setup a hooking function to execute when an addon is loaded
-- but not before)
local hookWaits = {}
function registerAddonHook(addonName, waiterName, hookFunction, ...)
	if (IsAddOnLoaded(addonName)) then
		hookFunction(unpack(arg));
	else
		local addon = string.lower(addonName)
		if (not hookWaits[addon]) then hookWaits[addon] = {} end
		table.insert(hookWaits[addon][waiterName] = { f=hookFunction, a=arg }
	end
end
function loadWatcher(loadedAddon)
	if (hookWaits[loadedAddon]) then
		local waiterName, hookDetail
		for waiterName, hookDetail in hookWaits[loadedAddon] do
			hookDetail.f(unpack(hookDetail.a));
		end
	end
end

Stubby = {
	LoadWatcher = loadWatcher,
	RegisterAddonHook = registerAddonHook,
};


-- Functions to check through all addons for dependants.
-- If any exist that we don't know about, and have a dependancy of us, then we will load them
-- once to give them a chance to register themselves with us.
local function shouldInspectAddon(addonName)
	if not StubbyConfig.inspected then StubbyConfig.inpected = {} end
	if not StubbyConfig.inspected[addonName] then return true end
	return false;
end
local function inspectAddon(addonName)
	LoadAddon(addonName);
	StubbyConfig.inspected[addonName] = true;
end
local function searchForNewAddons()
	local addonCount = GetNumAddOns();
	local name, title, notes, enabled, loadable, reason, security, requiresLoad
	for i=1, addonCount do
		requiresLoad = false;
		name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
		if (IsAddonLoadOnDemand(i) and shouldInspectAddon(name) and loadable) then
			local addonDeps = { GetAddOnDependancies(i) }
			for _, dependancy in pairs(addonDeps) do
				if (string.lower(dependancy) == "stubby") then
					requiresLoad = true;
				end
			end
		end

		if (requiresLoad) then inspectAddon(name) end
	end
end



-- Trigger the search for new life and new civilizations... or just addons maybe.
searchForNewAddons()

