local AHOpen = false
local FirstTime = true
local FavoritesCreated = {}
local ItemIDsIndex = 1

-- Display the favorites dialog
local function ShowFavorites()
    local sorts = {
        {sortOrder = Enum.AuctionHouseSortOrder.Price, reverseSort = false},
        {sortOrder = Enum.AuctionHouseSortOrder.Name, reverseSort = true},
    }
    C_AuctionHouse.SearchForFavorites(sorts)
end

-- Send a search query to the AH
local function Send(itemID)
    local itemKey = C_AuctionHouse.MakeItemKey(itemID)
    local sorts = {
        {sortOrder=Enum.AuctionHouseSortOrder.Price, reverseSort=false},
    }
    C_AuctionHouse.SendSearchQuery(itemKey, sorts, false)
end

-- Find arbitrages in the AH
local function ArbitrageHelper()
    if not AHOpen then
        MerchUtil.PrettyPrint("AH is closed")
        return
    end

    if ItemIDsIndex > #ArbitrageCache.ItemIDs then
        MerchUtil.PrettyPrint("...done scanning for arbitrages")
        ItemIDsIndex = 1
        ShowFavorites()
        return
    end

    local itemID = ArbitrageCache.ItemIDs[ItemIDsIndex]
    MerchUtil.PrettyPrint("  scan:", itemID, "("..ItemIDsIndex.."/"..#ArbitrageCache.ItemIDs..")")
    Send(itemID)

    C_Timer.After(0.1, ArbitrageHelper)
end

-- Start a new run of arbitrage finding
local function Arbitrage()
    if not AHOpen then
        MerchUtil.PrettyPrint("AH is closed")
        return
    end

    MerchUtil.RemoveFavorites(FavoritesCreated)

    if ItemIDsIndex == 1 then
        MerchUtil.PrettyPrint("Scanning for arbitrages...")
    end

    ArbitrageHelper()
end

-- Dispatch an incoming event
local function OnEvent(self, event, item)
    if event == "AUCTION_HOUSE_SHOW" then
        AHOpen = true
        if FirstTime then
            FirstTime = false
            Arbitrage()
        end
        return
    elseif event == "AUCTION_HOUSE_CLOSED" then
        AHOpen = false
        MerchUtil.RemoveFavorites(FavoritesCreated)
        return
    end

    local price = -1
    local itemKey = {
        itemID = 0,
        itemLevel = 0,
        itemSuffix = 0,
        battlePetSpeciesID = 0,
    }

    if event == "ITEM_SEARCH_RESULTS_UPDATED" then
        itemKey = item
        if itemKey.itemID ~= ArbitrageCache.ItemIDs[ItemIDsIndex] then
            -- Not the item we are looking for
            return
        end
        ItemIDsIndex = ItemIDsIndex + 1
        local result = C_AuctionHouse.GetItemSearchResultInfo(item, 1)
        if result == nil then
            return
        end
        price = result.buyoutAmount
    elseif event == "COMMODITY_SEARCH_RESULTS_UPDATED" then
        itemKey.itemID = item
        if itemKey.itemID ~= ArbitrageCache.ItemIDs[ItemIDsIndex] then
            -- Not the item we are looking for
            return
        end
        ItemIDsIndex = ItemIDsIndex + 1
        local result = C_AuctionHouse.GetCommoditySearchResultInfo(item, 1)
        if result == nil then
            return
        end
        price = result.unitPrice
    end

    if price == nil then
        return
    end

    if price > 0 and price < PriceCache.VendorSellPrice(itemID) then
        C_AuctionHouse.SetFavoriteItem(itemKey, true)
        table.insert(FavoritesCreated, itemKey)
    end
end

-- Dump state
local function Status()
    MerchUtil.PrettyPrint("AHQuery")
    MerchUtil.PrettyPrint("  AHOpen: ", AHOpen)
    MerchUtil.PrettyPrint("  ItemIDsIndex: ", ItemIDsIndex, "/", #ArbitrageCache.ItemIDs)
    MerchUtil.PrettyPrint("  FirstTime: ", FirstTime)
    MerchUtil.PrettyPrint("  #FavoritesCreated: ", #FavoritesCreated)
end

local AHQueryFrame = CreateFrame("Frame", "AHQuery", UIParent)
AHQueryFrame:Hide()
AHQueryFrame:SetScript("OnEvent", OnEvent)
AHQueryFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
AHQueryFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
AHQueryFrame:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")
AHQueryFrame:RegisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED")

AHQuery = {
    Arbitrage = Arbitrage,
    Send = Send,
    Status = Status,
}
