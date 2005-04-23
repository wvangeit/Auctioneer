--[[ keys for testFindLowestPriceByItem() --]]
gTestItemNameOne = "gTestItemNameOne";
gTestItemNameTwo = "gTestItemNameTwo";    

--[[ keys for testGetAuctionsBelowMedian --]]
gExpectedSignature1 = "testItemNameOne:1:16876:20000:test";
gExpectedSignature2 = "testItemNameTwo:2:250:1000:test";
gNonExpectedSignature1 = "testItemNameOne:1:16876:8000:test";
gNonExpectedSignature2 = "testItemNameThree:1:9885:10000:test"
gNonExpectedSignature3 = "testItemNameTwo:1:250:0:test";
gNonExpectedSignature4 = "WornDragonscale:2:5000:10000";
gAuctionPricesTestKey = "test-key";

function loadTestData()
    --[[ TEST DATA FOR testFindLowestPriceByItem()                                         --]]
    AHSnapshot[gTestItemNameOne..":18:4100:3000"] = {
        ["minbid"] = 4100,
        ["bidamount"] = 0,
        ["owner"] = "Zorvax",
        ["dirty"] = 0,
        ["name"] = gTestItemNameOne,
        ["buyout"] = 3000,
        ["level"] = 1,
        ["count"] = 20,
        ["quality"] = 1,
        ["test"] = true,
    }
    AHSnapshot[gTestItemNameOne..":18:4100:5000"] = {
        ["minbid"] = 4100,
        ["bidamount"] = 0,
        ["owner"] = "Araband",
        ["dirty"] = 0,
        ["name"] = gTestItemNameOne,
        ["buyout"] = 2000,
        ["level"] = 1,
        ["count"] = 2,
        ["quality"] = 1,
        ["test"] = true,
    }
    AHSnapshot[gTestItemNameOne..":18:4100:6000"] = {
        ["minbid"] = 4100,
        ["bidamount"] = 0,
        ["owner"] = "Duir",
        ["dirty"] = 0,
        ["name"] = gTestItemNameOne,
        ["buyout"] = 6000,
        ["level"] = 1,
        ["count"] = 20,
        ["quality"] = 1,
        ["test"] = true,
    }
    AHSnapshot[gTestItemNameOne..":18:4100:0"] = {
        ["minbid"] = 4100,
        ["bidamount"] = 0,
        ["owner"] = "Delassana",
        ["dirty"] = 0,
        ["name"] = gTestItemNameOne,
        ["buyout"] = 0,
        ["level"] = 1,
        ["count"] = 18,
        ["quality"] = 1,
        ["test"] = true,
    }
    AHSnapshot[gTestItemNameTwo..":1:25504:26000"] = {
        ["minbid"] = 25504,
        ["bidamount"] = 0,
        ["owner"] = "Xofc",
        ["dirty"] = 0,
        ["buyout"] = 26000,
        ["name"] = gTestItemNameTwo,
        ["level"] = 49,
        ["count"] = 1,
        ["quality"] = 2,
        ["test"] = true,
    }
    
    --[[  test data for testGetResellableAuctions() --]]
    AuctionPrices[gAuctionPricesTestKey] = {
        ["testItemNameOne"] = {
            ["data"] = "7:7:51432:1:176:7:73500",
            ["buyoutPricesHistoryList"] = {
                [1] = 7500,
                [2] = 7500,
                [3] = 8000,
                [4] = 8000,
                [5] = 8500,
                [6] = 14000,
                [7] = 20000,
            },
        },
        ["testItemNameTwo"] = {
            ["data"] = "20:65:126029:8:2397:60:192750",
            ["buyoutPricesHistoryList"] = {
                [1] = 5000,
                [2] = 6000,
                [3] = 17800,
                [4] = 20000,
                [5] = 20000,
                [6] = 20000,
                [7] = 20000,
                [8] = 30000,
                [9] = 30000,
                [10] = 38000,
                [11] = 40000,
                [12] = 40000,
                [13] = 40500,
                [14] = 42000,
                [15] = 45000,
                [16] = 50000,
                [17] = 51250,
                [18] = 65000,
                [19] = 75000,
            }
        },
       ["testItemNameThree"] = {
            ["data"] = "5:5:49255:0:0:4:80000",
            ["buyoutPricesHistoryList"] = {
                [1] = 10000,
                [2] = 20000,
                [3] = 20000,
                [4] = 30000,
            },
        },   
        ["WornDragonscale"] = {
            ["buyoutPricesHistoryList"] = {
                [1] = 10000,
                [2] = 20000,
                [3] = 30000,
                [4] = 40000,
                [5] = 50000,
                [6] = 60000,
                [7] = 70000,
            },
            ["data"] = "79:509:2017400:51:87250:433:2453599",
        },
    }
    AHSnapshot[gExpectedSignature1] = {
        ["minbid"] = 16876,
        ["bidamount"] = 0,
        ["owner"] = "",
        ["dirty"] = 0,
        ["name"] = "testItemNameOne",
        ["buyout"] = 50,
        ["level"] = 35,
        ["count"] = 2,
        ["quality"] = 2,
    }
    AHSnapshot[gNonExpectedSignature1] = {
        ["minbid"] = 16876,
        ["bidamount"] = 0,
        ["owner"] = "",
        ["dirty"] = 0,
        ["name"] = "testItemNameOne",
        ["buyout"] = 8000,
        ["level"] = 35,
        ["count"] = 1,
        ["quality"] = 2,
    }
    AHSnapshot[gNonExpectedSignature2] = {
        ["minbid"] = 9885,
        ["bidamount"] = 0,
        ["owner"] = "",
        ["dirty"] = 0,
        ["name"] = "testItemNameThree",
        ["buyout"] = 5000,
        ["level"] = 29,
        ["count"] = 1,
        ["quality"] = 2,
    }
    AHSnapshot[gExpectedSignature2] = {
        ["minbid"] = 250,
        ["bidamount"] = 0,
        ["owner"] = "Gned",
        ["dirty"] = 0,
        ["buyout"] = 500,
        ["name"] = "testItemNameTwo",
        ["level"] = 1,
        ["count"] = 2,
        ["quality"] = 1,
    }
    AHSnapshot[gNonExpectedSignature3] = {
        ["minbid"] = 250,
        ["bidamount"] = 0,
        ["owner"] = "jared",
        ["dirty"] = 0,
        ["buyout"] = 0,
        ["name"] = "testItemNameTwo",
        ["level"] = 1,
        ["count"] = 1,
        ["quality"] = 1,
    }
	AHSnapshot[gNonExpectedSignature4] = {
		["minbid"] = 5000,
		["bidamount"] = 0,
		["owner"] = "Frenny",
		["dirty"] = 0,
		["buyout"] = 7000,
		["name"] = "WornDragonscale",
		["level"] = 1,
		["count"] = 1,
		["quality"] = 1,
	}    
    AHSnapshot["WornDragonscale:3:6050:7500"] = {
		["minbid"] = 6050,
		["bidamount"] = 0,
		["owner"] = "Araband",
		["dirty"] = 0,
		["name"] = "WornDragonscale",
		["buyout"] = 8000,
		["level"] = 1,
		["count"] = 1,
		["quality"] = 1,
	}
    AHSnapshot["WornDragonscale:1:750:2500"] = {
		["minbid"] = 750,
		["bidamount"] = 0,
		["owner"] = "",
		["dirty"] = 0,
		["buyout"] = 9000,
		["name"] = "WornDragonscale",
		["level"] = 1,
		["count"] = 1,
		["quality"] = 1,
	}
    AHSnapshot["WornDragonscale:1:750:1500"] = {
		["minbid"] = 750,
		["bidamount"] = 0,
		["owner"] = "",
		["dirty"] = 0,
		["buyout"] = 10000,
		["name"] = "WornDragonscale",
		["level"] = 1,
		["count"] = 1,
		["quality"] = 1,
	}
	AHSnapshot["WornDragonscale:18:23500:27000"] = {
		["minbid"] = 23500,
		["bidamount"] = 0,
		["owner"] = "Honstin",
		["dirty"] = 0,
		["name"] = "WornDragonscale",
		["buyout"] = 11000,
		["level"] = 1,
		["count"] = 1,
		["quality"] = 1,
	}   
	AHSnapshot["WornDragonscale:18:23500:2700123"] = {
		["minbid"] = 23500,
		["bidamount"] = 0,
		["owner"] = "1233",
		["dirty"] = 0,
		["name"] = "WornDragonscale",
		["buyout"] = 12000,
		["level"] = 1,
		["count"] = 1,
		["quality"] = 1,
	}      
    AHSnapshot["WornDragonscale:12:23200:27230123"] = {
		["minbid"] = 23500,
		["bidamount"] = 0,
		["owner"] = "1233",
		["dirty"] = 0,
		["name"] = "WornDragonscale",
		["buyout"] = 13000,
		["level"] = 1,
		["count"] = 1,
		["quality"] = 1,
	}      
    
    AHSnapshotItemPrices["WornDragonscale"] = {
		["buyoutPrices"] = {
			[1] = 7000,
            [2] = 8000,
            [3] = 9000,
            [4] = 10000,
            [5] = 11000,
            [6] = 12000,
            [7] = 13000,
		},
	}  
    AHSnapshotItemPrices[gTestItemNameOne] = {
		["buyoutPrices"] = {
			[1] = 150,
            [2] = 1000,
            [3] = 300,
		},
	}      
    
    
    
    --[[     test data for getUsableMedian --]]
    AuctionPrices[gAuctionPricesTestKey]["underMinSeenBothItem"] = {
        ["data"] = "7:7:51432:1:176:7:73500",
        ["buyoutPricesHistoryList"] = {
            [1] = 7500,
            [2] = 7500,
        },
    }
    AHSnapshot["underMinSeenBothItem:12:23200:27230123"] = {
		["minbid"] = 23500,
		["bidamount"] = 0,
		["owner"] = "1233",
		["dirty"] = 0,
		["name"] = "underMinSeenBothItem",
		["buyout"] = 13000,
		["level"] = 1,
		["count"] = 1,
		["quality"] = 1,
	}         
    
end -- loadTestData()
