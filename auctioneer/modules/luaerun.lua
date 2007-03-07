local pathsep = [[/]]
if os.execute'uname' ~= 0 then pathsep = [[\]] end

local function files(dirname)
	local dh = assert(os.opendir(dirname))
	return function()
		return dh:read() or assert(dh:close()) and nil
	end
end

print("Scanning plugins folder...")
local dirs = {}
for fn in files(".") do
	if fn and fn:sub(0,4) == "auc-" then
		local info = os.stat(fn)
		if info and info.dir then
			print("Found addon: "..fn)
		end
	end
end
print("Done")

sleep(2.5)
exit()
