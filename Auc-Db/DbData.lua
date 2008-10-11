LibStub("LibRevision"):Set("$URL$","$Rev$","5.1.DEV.", 'auctioneer', 'libs')

if not AucDB then return end

local lib = AucDB

-- This activates the addon, without this, the addon lies dormant
lib.Enabled = true

-- Set this to the max uploaded timestamp
lib.UpToDate = 1190543147

-- These do the loading of the server-faction data
lib.Data = {
	[0] = {},
	["Akama"] = {
		Alliance = loadstring([[return {[2070]="4000000:10"}]])(),
	},
}
-- Or
lib.Data = {}
lib.Data["Akama"] = {}
lib.Data["Akama"].Alliance = loadstring([[return {[2070]="4000000:10"}]])()


