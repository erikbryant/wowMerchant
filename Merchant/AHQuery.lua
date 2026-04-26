local AHOpen = false
local FavoritesCreated = {}
local ItemIDs = {}
local ItemIDsIndex = 1
local Scanning = false

local IdToLevel = {
    -- iLvl 80
    {237948, 180, 186, 192, 199, 206}, -- Thalassian Blacksmith's Toolbox (Profession)
    {238011, 180, 186, 206},           -- Thalassian Skinning Knife (Profession)
    {238012, 180, 186, 192, 199, 206}, -- Thalassian Leatherworker's Knife (Profession)
    {239641, 180, 186, 192, 199, 206}, -- Bright Linen Alchemy Apron (Profession)
    {239642, 180, 186, 192, 206},      -- Chef's Bright Linen Cooking Chapeau (Profession)
    {239646, 180, 186, 192, 199, 206}, -- Bright Linen Tailoring Robe (Profession)
    {240953, 180, 186, 192, 199, 206}, -- Bold Biographer's Bifocals (Profession)
    {240954, 180, 186, 192, 199, 206}, -- Fantastic Font Focuser (Profession)
    {240955, 180, 183, 186, 189, 193}, -- Silvermoon Loupes (Profession)
    {244175, 180, 186, 192, 199, 206}, -- Runed Refulgent Copper Rod (Profession)
    {244618, 180, 186, 192, 199, 206}, -- Tinker's Handguard (Profession)
    {244619, 180, 186, 192, 199, 206}, -- Hideworker's Cover (Profession)
    {244627, 180, 186, 192, 199, 206}, -- Apprentice Smith's Apron (Profession)

    -- iLvl 106
    {237952, 206, 212, 218, 225, 232}, -- Sun-Blessed Blacksmith's Toolbox (Profession)
    {238018, 212, 218, 225, 232},      -- Sun-Blessed Blacksmith's Hammer (Profession)
    {240959, 206, 212, 218, 225, 232}, -- Sin'dorei Jeweler's Loupes (Profession)
    {244718, 206, 212, 218, 225, 232}, -- Turbo-Junker's Multitool v1 (Profession)

    -- iLvl 317
    {191235, 71, 72, 73, 74},     -- Draconium Blacksmith's Toolbox (Profession)
    {191236, 71, 72, 73, 74},     -- Draconium Leatherworker's Toolset (Profession)
    {191237, 70, 71, 72, 73, 74}, -- Draconium Blacksmith's Hammer (Profession)
    {191238, 71, 72, 73, 74},     -- Draconium Leatherworker's Knife (Profession)
    {191239, 71, 72, 73, 74},     -- Draconium Needle Set (Profession)
    {191240, 71, 72, 73, 74},     -- Draconium Skinning Knife (Profession)
    {191241, 70, 71, 72, 74},     -- Draconium Sickle (Profession)
    {191242, 70, 71, 72, 74},     -- Draconium Pickaxe (Profession)
    {193486, 70, 71, 72, 74},     -- Resilient Smock (Profession)
    {224114, 79, 85, 91, 105},    -- Runed Bismuth Rod (Profession)

    -- iLvl 486
    {215120, 79, 85, 91, 98, 105}, -- Radiant Loupes (Profession)
    {221797, 79, 85, 91, 98, 105}, -- Bismuth-Fueled Samophlange (Profession)
    {244709, 180, 186, 192, 206},  -- Junker's Junk Visor (Profession)

    -- iLvl 535
    {244626, 206, 212, 218, 225, 232}, -- Sin'dorei Alchemist's Hat (Profession)
}

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

local function LookupItemLevel(itemID, itemLevel)
    for i=1, #IdToLevel do
        if itemID == IdToLevel[i][1] then
            return IdToLevel[i][2]
        end
    end
    return itemLevel
end

-- Send a search query to the AH
local function Send(itemID)
    local itemKey = C_AuctionHouse.MakeItemKey(itemID)
    local sorts = {
        {sortOrder=Enum.AuctionHouseSortOrder.Price, reverseSort=false},
    }
    itemKey.itemLevel = LookupItemLevel(itemID, itemKey.itemLevel)
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
        -- Results are sorted by price, so we only need to check the first result
        local result = C_AuctionHouse.GetItemSearchResultInfo(item, 1)
        if result ~= nil and result.buyoutAmount ~= nil and result.buyoutAmount > 0 and result.buyoutAmount < PriceCache.VendorSellPrice(item.itemID) then
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
