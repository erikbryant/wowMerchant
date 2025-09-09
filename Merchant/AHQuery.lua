local AHOpen = false
local FavoritesCreated = {}
local ItemIDs = {}
local ItemIDsIndex = 1
local Scanning = false

-- Display the favorites dialog
local function ShowFavorites()
    local sorts = {
        {sortOrder = Enum.AuctionHouseSortOrder.Price, reverseSort = false},
        {sortOrder = Enum.AuctionHouseSortOrder.Name, reverseSort = true},
    }
    C_AuctionHouse.SearchForFavorites(sorts)
end

-- RemoveFavorites removes all of the favorites that were created this login session
local function RemoveFavorites()
    MerchUtil.RemoveFavorites(FavoritesCreated)
    FavoritesCreated = {}
end

-- Return the next list of itemIDs to scan for
local function DefaultsOrFavorites()
    ItemIDsIndex = 1

    if #ItemIDs == 0 then
        return ArbitrageCache.ItemIDs
    end

    if #FavoritesCreated == 0 then
        return ArbitrageCache.ItemIDs
    end

    local itemIDs = {}
    for i=1, #FavoritesCreated do
        itemIDs[i] = FavoritesCreated[i].itemID
    end

    return itemIDs
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

    if ItemIDsIndex > #ItemIDs then
        MerchUtil.PrettyPrint("...done scanning for item arbitrages")
        Scanning = false
        ItemIDs = DefaultsOrFavorites()
        ShowFavorites()
        return
    end

    local itemID = ItemIDs[ItemIDsIndex]
    MerchUtil.PrettyPrint("  scan:", itemID, "("..ItemIDsIndex.."/"..#ItemIDs..")")
    Send(itemID)

    C_Timer.After(0.1, ArbitrageHelper)
end

-- Start a new run of arbitrage finding
local function Arbitrage()
    if not AHOpen then
        MerchUtil.PrettyPrint("AH is closed")
        return
    end

    MerchUtil.PrettyPrint("Scanning for item arbitrages...")
    ItemIDsIndex = 1
    if #ItemIDs == 0 then
        ItemIDs = ArbitrageCache.ItemIDs
    end
    RemoveFavorites()
    Scanning = true
    ArbitrageHelper()
end

-- Dispatch an incoming event
local function OnEvent(self, event, item)
    if event == "AUCTION_HOUSE_SHOW" then
        AHOpen = true
        Scanning = false
        Arbitrage()
    elseif event == "AUCTION_HOUSE_CLOSED" then
        AHOpen = false
        Scanning = false
        RemoveFavorites()
    elseif event == "ITEM_SEARCH_RESULTS_UPDATED" and Scanning and item.itemID == ItemIDs[ItemIDsIndex] then
        ItemIDsIndex = ItemIDsIndex + 1
        local result = C_AuctionHouse.GetItemSearchResultInfo(item, 1)
        if result == nil or result.buyoutAmount == nil then
            return
        end
        if result.buyoutAmount > 0 and result.buyoutAmount < PriceCache.VendorSellPrice(item.itemID) then
            C_AuctionHouse.SetFavoriteItem(item, true)
            table.insert(FavoritesCreated, item)
        end
    end
end

-- Dump state
local function Status()
    MerchUtil.PrettyPrint("AHQuery")
    MerchUtil.PrettyPrint("  AHOpen: ", AHOpen)
    MerchUtil.PrettyPrint("  Scanning: ", Scanning)
    MerchUtil.PrettyPrint("  #ArbitrageCache.ItemIDs: ", #ArbitrageCache.ItemIDs)
    MerchUtil.PrettyPrint("  ItemIDsIndex: ", ItemIDsIndex, "/", #ItemIDs)
    MerchUtil.PrettyPrint("  #FavoritesCreated: ", #FavoritesCreated)
end

local AHQueryFrame = CreateFrame("Frame", "AHQuery", UIParent)
AHQueryFrame:Hide()
AHQueryFrame:SetScript("OnEvent", OnEvent)
AHQueryFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
AHQueryFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
AHQueryFrame:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")

AHQuery = {
    Arbitrage = Arbitrage,
    Send = Send,
    Status = Status,
}
