--local test_item = 5956 -- Blacksmith Hammer
--local test_commodity = 152579 -- Storm Silver Ore

local QueryPending = false

local function Send(itemID)
    if QueryPending then
        print("Query pending!")
        return
    end

    local itemKey = C_AuctionHouse.MakeItemKey(itemID)
    local sorts = {
        {sortOrder=Enum.AuctionHouseSortOrder.Price, reverseSort=false},
    }
    C_AuctionHouse.SendSearchQuery(itemKey, sorts, false)
    QueryPending = true
end

-- Dispatch an incoming event
local function OnEvent(self, event, item)
    if not QueryPending then
        -- The AH uses these events, only trigger on responses to our requests
        return
    end

    local price = -1
    local itemID = 0

    if event == "ITEM_SEARCH_RESULTS_UPDATED" then
        local result = C_AuctionHouse.GetItemSearchResultInfo(item, 1)
        if result ~= nil then
            price = result.buyoutAmount
            itemID = item.itemID
        end
    elseif event == "COMMODITY_SEARCH_RESULTS_UPDATED" then
        local result = C_AuctionHouse.GetCommoditySearchResultInfo(item, 1)
        if result ~= nil then
            price = result.unitPrice
            itemID = item
        end
    end

    QueryPending = false

    if price > 0 then
        print("ItemID: ", itemID, " at price:", price)
    end
end

local AHQueryFrame = CreateFrame("Frame", "AHQuery", UIParent)
AHQueryFrame:Hide()
AHQueryFrame:SetScript("OnEvent", OnEvent)
AHQueryFrame:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")
AHQueryFrame:RegisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED")
AHQueryFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")

AHQuery = {
    Send = Send,
}
