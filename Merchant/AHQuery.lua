local AHOpen = false
local FirstTime = true
local FavoritesCreated = {}

-- sort generated/arbitrageItems.log | sed "s/ *[0-9.]*$//1" | uniq > x
-- while IFS= read -r line; do
--   go run listItems/listItems.go -passPhrase unlock | egrep "$line$"
-- done < x > y
-- sort -n y | cut -c 1-8,76-900 | awk '{ print $1 ", -- " $2 " " $3 " " $4 " " $5 " " $6 " " $7 " " $8 " " $9 }'
local ItemIDsIndex = 1
local ItemIDs = {
    30323, -- Plans: Boots of the Protector
    191578, -- Recipe: Transmute: Awakened Fire
    223051, -- Plans: Artisan Skinning Knife
    223060, -- Technique: Patient Alchemist's Mixing Rod
    223061, -- Technique: Inscribed Rolling Pin
    223085, -- Design: Fractured Gemstone Locket
    223086, -- Design: Insightful Blasphemite
    223087, -- Design: Culminating Blasphemite
    223096, -- Pattern: Roiling Thunderstrike Talons
    223098, -- Pattern: Waders of the Unifying Flame
    223101, -- Pattern: Reinforced Setae Flyers
    223102, -- Pattern: Busy Bee's Buckle
}

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

    if ItemIDsIndex > #ItemIDs then
        MerchUtil.PrettyPrint("...done scanning for arbitrages")
        ItemIDsIndex = 1
        return
    end

    itemID = ItemIDs[ItemIDsIndex]
    MerchUtil.PrettyPrint("  scan:", itemID, "("..ItemIDsIndex.."/"..#ItemIDs..")")
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
        if item.itemID == ItemIDs[ItemIDsIndex] then
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
        if item == ItemIDs[ItemIDsIndex] then
            ItemIDsIndex = ItemIDsIndex + 1
        end
        local result = C_AuctionHouse.GetCommoditySearchResultInfo(item, 1)
        if result == nil then
            return
        end
        price = result.unitPrice
        itemID = item
    end

    if price > 0 and price < AhaPriceCache.VendorSellPrice(itemID) then
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
    MerchUtil.PrettyPrint(" ItemIDs: ", ItemIDsIndex, "/", #ItemIDs)
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
