local AHOpen = false
local FirstTime = true
local FavoritesCreated = {}
local ItemIDsIndex = 1

local function Send(itemID)
    local itemKey = C_AuctionHouse.MakeItemKey(itemID)
    local sorts = {
        {sortOrder=Enum.AuctionHouseSortOrder.Price, reverseSort=false},
    }
    C_AuctionHouse.SendSearchQuery(itemKey, sorts, false)
end

local function ArbitrageHelper()
    if not AHOpen then
        MerchUtil.PrettyPrint("AH is closed")
        return
    end

    if ItemIDsIndex > #ArbitrageCache.ItemIDs then
        MerchUtil.PrettyPrint("...done scanning for arbitrages")
        ItemIDsIndex = 1
        return
    end

    itemID = ArbitrageCache.ItemIDs[ItemIDsIndex]
    MerchUtil.PrettyPrint("  scan:", itemID, "("..ItemIDsIndex.."/"..#ArbitrageCache.ItemIDs..")")
    Send(itemID)

    C_Timer.After(0.2, ArbitrageHelper)
end

local function Arbitrage()
    if not AHOpen then
        MerchUtil.PrettyPrint("AH is closed")
        return
    end

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
    local itemID = 0
    local itemLevel = 0

    if event == "ITEM_SEARCH_RESULTS_UPDATED" then
        if item.itemID == ArbitrageCache.ItemIDs[ItemIDsIndex] then
            ItemIDsIndex = ItemIDsIndex + 1
        end
        local result = C_AuctionHouse.GetItemSearchResultInfo(item, 1)
        if result == nil then
            return
        end
        price = result.buyoutAmount
        itemID = item.itemID
        itemLevel = item.itemLevel
    elseif event == "COMMODITY_SEARCH_RESULTS_UPDATED" then
        if item == ArbitrageCache.ItemIDs[ItemIDsIndex] then
            ItemIDsIndex = ItemIDsIndex + 1
        end
        local result = C_AuctionHouse.GetCommoditySearchResultInfo(item, 1)
        if result == nil then
            return
        end
        price = result.unitPrice
        itemID = item
    end

    if price > 0 and price < PriceCache.VendorSellPrice(itemID) then
        local itemKey = {
            itemID = itemID,
            itemLevel = itemLevel,
            itemSuffix = 0,
            battlePetSpeciesID = 0,
        }
        C_AuctionHouse.SetFavoriteItem(itemKey, true)
        table.insert(FavoritesCreated, itemKey)
    end
end

local function Status()
    MerchUtil.PrettyPrint("AHOpen: ", AHOpen)
    MerchUtil.PrettyPrint(" ItemIDs: ", ItemIDsIndex, "/", #ArbitrageCache.ItemIDs)
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
