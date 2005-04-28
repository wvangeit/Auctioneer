-- test Auctioneer

--a simple assertation function
function assertEquals(arg1, arg2, msg)
    local passed = true;
    if (arg1 ~= arg2) then
        Auctioneer_ChatPrint("Assertation FAILDED "..tostring(msg));
        expectedActual(arg1, arg2);
        passed = false;
    end
    return passed;
end

function expectedActual(expected, actual)
    Auctioneer_ChatPrint("expected <"..tostring(expected).."> was <"..tostring(actual)..">");
end

-- ====================================================================================
-- UTIL TESTS
-- =====================================================================================
function testGetMedian()
    --first test vanilla case and make sure result is right
    local values = {0,2,1,4,7,3,8,20,100,9,11,8}; --test an even length list first
    local median = getMedian(values);
    if (not assertEquals(median, 7.5, "testGetMedian")) then return; end
    
    --now test odd size table
    values = {0,2,1,4,20,100,9,11,8};
    median = getMedian(values);
    if (not assertEquals(median, 8, "testGetMedian")) then return; end
    
    --now test boundry conditions
    median = getMedian(nil);
    assert(not median);
    
    values = {};
    median = getMedian(values);
    assert(not median);
    
    values = {77}
    median = getMedian(values);
    if (not assertEquals(median, 77, "testGetMedian")) then return; end
    
    Auctioneer_ChatPrint("testGetMedian PASSED");
end

function testBalancedList()

    -- test the boundry condition of a single value
    local balancedList = newBalancedList();
    balancedList.insert(1);
    if (not assertEquals(1, balancedList.getMedian(), "balancedList:getMedian()")) then return; end
    
    
    -- assert that when we create a new object its has fresh state
    local newList = newBalancedList();
    if (not assertEquals(0, newList.size(), "newList:size()")) then return; end
    newList.insert(4);
    newList.insert(2);
    newList.insert(5);
    
    -- test that the list is the right size
    if (not assertEquals(3, newList:size(), "newList:size()")) then return; end
    
    -- make sure the list was ordered
    if (not assertEquals(2, newList.get(1), "newList.get(1)")) then return; end 
    if (not assertEquals(4, newList.get(2), "newList.get(2)")) then return; end 
    if (not assertEquals(5, newList.get(3), "newList.get(3)")) then return; end 
    
    -- make sure median is correct
    if (not assertEquals(4, newList.getMedian(), "newList.getMedian()")) then return; end 
    
    -- test inserting some boundry values
    newList.insert(0);
    if (not assertEquals(0, newList.get(1), "newList.get(1)")) then return; end 
    newList.insert(100);
    if (not assertEquals(100, newList.get(newList.size()), "newList.get(1)")) then return; end 
    
    newList.clear();
    if (not assertEquals(0, newList.size(), "newList.get(1)")) then return; end
    
    -- now test that the list balances itself if the insert pushes the list beond its maxsize
    local fixedSizeList = newBalancedList(4);
    if (not assertEquals(4, fixedSizeList.getMaxSize(), "newList.getMaxSize()")) then return; end 
    fixedSizeList.insert(1);
    fixedSizeList.insert(2);
    fixedSizeList.insert(3);
    fixedSizeList.insert(4);
    
    -- make sure the endpoints are what we expect
    if (not assertEquals(1, fixedSizeList.get(1), "fixedSizeList.get(1)")) then return; end 
    if (not assertEquals(4, fixedSizeList.get(fixedSizeList.size()), "fixedSizeList.get(fixedSizeList.size())")) then return; end
    -- now insert something that should push off the right side vlaue
    fixedSizeList.insert(2);
    if (not assertEquals(3, fixedSizeList.get(fixedSizeList.size()), "fixedSizeList.get(fixedSizeList.size())")) then return; end 
    -- now insert something that should push off the left side value
    fixedSizeList.insert(3);
    if (not assertEquals(2, fixedSizeList.get(1), "fixedSizeList.get(1)")) then return; end 
    if (not assertEquals(2.5, fixedSizeList.getMedian(), "fixedSizeList.getMedian()")) then return; end 
    
    
    -- now test an odd number sized list
    local fixedSizeList = newBalancedList(5);
    if (not assertEquals(0, fixedSizeList.size(), "fixedSizeList.size()")) then return; end 
    fixedSizeList.insert(3);
    fixedSizeList.insert(5);
    fixedSizeList.insert(7);
    fixedSizeList.insert(9);  
    fixedSizeList.insert(11);  
    -- assert our end points are correct
    if (not assertEquals(3, fixedSizeList.get(1), "fixedSizeList.get(1)")) then return; end 
    if (not assertEquals(11, fixedSizeList.get(fixedSizeList.size()), "fixedSizeList.get(fixedSizeList.size())")) then return; end 
    -- insert something that should push off the right end value
    fixedSizeList.insert(6);
    if (not assertEquals(9, fixedSizeList.get(fixedSizeList.size()), "fixedSizeList.get(fixedSizeList.size())")) then return; end
    -- insert something that should push off the left end value
    fixedSizeList.insert(7);
    if (not assertEquals(5, fixedSizeList.get(1), "fixedSizeList.get(1)")) then return; end 
    -- now test boundries
    fixedSizeList.insert(-1);
    if (not assertEquals(-1, fixedSizeList.get(1), "fixedSizeList.get(1)")) then return; end 
    if (not assertEquals(7, fixedSizeList.get(fixedSizeList.size()), "fixedSizeList.get(fixedSizeList.size())")) then return; end 
    fixedSizeList.insert(100000);
    if (not assertEquals(100000, fixedSizeList.get(fixedSizeList.size()), "fixedSizeList.get(fixedSizeList.size())")) then return; end
    if (not assertEquals(5, fixedSizeList.get(1), "fixedSizeList.get(1)")) then return; end 
    fixedSizeList.insert(nil);
    if (not assertEquals(100000, fixedSizeList.get(fixedSizeList.size()), "fixedSizeList.get(fixedSizeList.size())")) then return; end
    if (not assertEquals(5, fixedSizeList.get(1), "fixedSizeList.get(1)")) then return; end
    
    
    -- test setting from an external list
    local priceList = newBalancedList(3);
    priceList.setList({1, 2, 3});
    if (not assertEquals(3, priceList.size(), "priceList.size()")) then return; end
    
    -- now test setting from a list that is to large
    priceList.setList({3, 2, 1, 5, 4});
    if (not assertEquals(3, priceList.size(), "priceList.size()")) then return; end
    if (not assertEquals(3, priceList.get(1), "priceList.get(1)")) then return; end
    if (not assertEquals(5, priceList.get(priceList.size()), "priceList.get(priceList.size())")) then return; end
    
    -- now test boundry condition
    priceList.setList({});
    if (not assertEquals(0, priceList.size(), "priceList.size()")) then return; end
    priceList.setList(nil);
    if (not assertEquals(0, priceList.size(), "priceList.size()")) then return; end
    
    -- test getList
    priceList.setList({3,4,5});
    local myTable = priceList.getList();
    if (not assertEquals(3, table.getn(myTable), "table.getn(myTable)")) then return; end
    if (not assertEquals(3, myTable[1], "myTable[1]")) then return; end
    if (not assertEquals(4, myTable[2], "myTable[2]")) then return; end
    if (not assertEquals(5, myTable[3], "myTable[3]")) then return; end
   
    
    Auctioneer_ChatPrint("testBalancedList PASSED");
end

function testFindLowestPriceByItem()  
    -- test results are right for easy cases
    local auctionItem = nil;
    
    auctionItem = findLowestPriceByItem(gTestItemNameOne);
    assert("Zorvax" == auctionItem.owner);
    
    auctionItem = findLowestPriceByItem(gTestItemNameTwo);
    assert("Xofc" == auctionItem.owner)
        
    --test boundry conditions, nil argument, item not in snapshot
    auctionItem = findLowestPriceByItem("unkownItemName");
    assert(nil == auctionItem);
    
    auctionItem = findLowestPriceByItem(nil);
    assert(nil == auctionItem);
    
    Auctioneer_ChatPrint("testFindLowestPriceByItem PASSED");
end

function testGetResellableAuctions()
    local auctionsBelowMedian = getResellableAuctions(60);
        
    -- make sure that testItemNameOne was returned in the table
    assert(auctionsBelowMedian[gExpectedSignature1]);
    assert(auctionsBelowMedian[gExpectedSignature1].buyoutSeenCount == 7);
    assert(auctionsBelowMedian[gExpectedSignature1].totalHighestSellablePrice == 13600);
    assert(auctionsBelowMedian[gExpectedSignature1].profit == 13550);
    
    -- make sure that testItemNameTwo was returned in the results
    assert(auctionsBelowMedian[gExpectedSignature2]);
    assert(auctionsBelowMedian[gExpectedSignature2].buyoutSeenCount == 19);
    assert(auctionsBelowMedian[gExpectedSignature2].totalHighestSellablePrice == 64600);
    assert(auctionsBelowMedian[gExpectedSignature2].profit == 64100);
    
    -- make wure that the following signature is not in the results because it is not less than the median
    assert(AHSnapshot[gNonExpectedSignature1]);
    assert(not auctionsBelowMedian[gNonExpectedSignature1]);
    
    -- make sure that testItemNameThree was not returned, because it has not been seen enough times
    assert(AHSnapshot[gNonExpectedSignature2]);
    assert(not auctionsBelowMedian[gNonExpectedSignature2]);
    
    -- make sure this is not in the results becase it does not have a buyout
    assert(AHSnapshot[gNonExpectedSignature3]);
    assert(not auctionsBelowMedian[gNonExpectedSignature3]);    
    
    
    -- make sure dont get a worn dragon scale because it's buyout is not lower than the snapshot median
    assert(not auctionsBelowMedian[gNonExpectedSignature4]);
    
    Auctioneer_ChatPrint("testGetResellableAuctions PASSED");
end


function testGetItemSnapshotMedianBuyout()
    -- assert that we get the correct snapshot median for this item in the test data
    local snapshotMedian, count = getItemSnapshotMedianBuyout(gTestItemNameOne);
    assert(300 == snapshotMedian);
    assert(3 == count);
    
    -- test boundry condition
    snapshotMedian, count = getItemSnapshotMedianBuyout("unknown item");
    assert(not median and not count);
    snapshotMedian, count = getItemSnapshotMedianBuyout(nil);
    assert(not median and not count);  
end

local function testGetUsableMedian()
    local origMinSeenCount = MIN_BUYOUT_SEEN_COUNT;
    MIN_BUYOUT_SEEN_COUNT = 3;
    

    -- boundry conditions
    -- item doesnt exist in either price table
    local median, count = getUsableMedian("unknown item1");
    assert(not median and not count);
    -- item exists but is not seen enough times in either price table
    median, count = getUsableMedian("underMinSeenBothItem");
    assert(not median and not count);
    
    Auctioneer_ChatPrint("testGetUsableMedian PASSED");    
    
    MIN_BUYOUT_SEEN_COUNT = origMinSeenCount;
end

-- This method is a place to try out things in lua script for learning
function testLuaScriptingComponents()
end

function standAlone_auctionKey()
    return "test-key";
end

-- starting point for running all tests
function doTests()
    auctionKey_original = auctionKey
    auctionKey = standAlone_auctionKey;

    loadTestData();
    testLuaScriptingComponents();
    testGetMedian();
    testBalancedList();
    testFindLowestPriceByItem();
    testGetResellableAuctions();
    testGetItemSnapshotMedianBuyout();
    testGetUsableMedian();
    
    auctionKey = auctionKey_original;
end
