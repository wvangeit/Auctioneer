-- This script is used to run the tests outside of WoW

-- load the test scripts
dofile("AuctioneerUtil.lua");
dofile("Auctioneer.lua");
dofile("TestData.lua");
dofile("TestAuctioneer.lua");

-- hook the output function to go to stdout
Auctioneer_ChatPrint = print;

-- hook other functions that require the WoW environment to run
format = string.format;

print("Running Auctioneer Tests...");
doTests();
print("Testing done.");