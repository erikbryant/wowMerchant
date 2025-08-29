local NumAuctionsFoundLastCheck = 0
local FavoritesCreated = {}
local Timers = {}

-- Create an AH favorite for each auction that is an arbitrage
local function FindArbitrages(firstAuction, numAuctions)
    MerchUtil.PrettyPrint("Searching auctions", firstAuction, "-", numAuctions)

    -- Optimization: Create local function pointers. This way we only
    -- search for the function in the global namespace once,
    -- instead of on every call.
    local getReplicateItemInfo = C_AuctionHouse.GetReplicateItemInfo
    local vendorSellPrice = PriceCache.VendorSellPrice
    local foundArbitrage = false

    for i = firstAuction, numAuctions-1 do
        local auction = {getReplicateItemInfo(i)}
        local buyoutPrice = auction[10]
        local itemID = auction[17]
        if buyoutPrice > 0 and buyoutPrice < vendorSellPrice(itemID) then
            foundArbitrage = true
            local itemInfo = {GetItemInfo(itemID)}
            local itemLevel = itemInfo[4]
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

    if foundArbitrage then
        PlaySound(SOUNDKIT.AUCTION_WINDOW_CLOSE)
        MerchUtil.PrettyPrint("Arbitrage auctions found and added to favorites!")
    end
end

-- Process any new AH scan results
local function CheckForAuctionResults()
    local numAuctions = C_AuctionHouse.GetNumReplicateItems()

    if numAuctions == 0 or numAuctions == NumAuctionsFoundLastCheck then
        -- No [new] auction results. Ask for results.
        C_AuctionHouse.ReplicateItems()
    else
        -- numAuctions > 0 and not numAuctions == NumAuctionsFoundLastCheck
        -- Received some auction results!
        if NumAuctionsFoundLastCheck > numAuctions then
            NumAuctionsFoundLastCheck = 0
        end
        FindArbitrages(NumAuctionsFoundLastCheck, numAuctions)
    end

    NumAuctionsFoundLastCheck = numAuctions
end

-- Status displays debug information
local function Status()
    MerchUtil.PrettyPrint("AHArbitrage")
    MerchUtil.PrettyPrint("  NumAuctionsFoundLastCheck:", NumAuctionsFoundLastCheck)
    MerchUtil.PrettyPrint("  #FavoritesCreated:", #FavoritesCreated)
    MerchUtil.PrettyPrint("  #Timers:", #Timers)
end

-- CancelTimers cancels each timer StartTimers started
local function CancelTimers()
    for _, timer in pairs(Timers) do
        timer:Cancel()
    end
    Timers = {}
end

-- ScanOpen starts an AH scan
local function ScanOpen()
    MerchUtil.PrettyPrint("Scanning for bargains...")
    C_AuctionHouse.ReplicateItems()
    Timers[#Timers+1] = C_Timer.NewTicker(5, CheckForAuctionResults)
    if C_AuctionHouse.HasFavorites() then
        MerchUtil.PrettyPrint("*** Delete your AH favorites! ***")
    end
end

-- ScanClosed lets the user know the AH is closed
local function ScanClosed()
    MerchUtil.PrettyPrint("AH is closed")
end

-- Dispatch an incoming event
local function OnEvent(self, event)
    if event == "AUCTION_HOUSE_SHOW" then
        AHArbitrage.Scan = ScanOpen
        CancelTimers()
        Timers[#Timers+1] = C_Timer.NewTicker(1, AHPatches.SetMinBuy)
        Timers[#Timers+1] = C_Timer.NewTicker(1, AHPatches.Unfavorite)
    elseif event == "AUCTION_HOUSE_CLOSED" then
        AHArbitrage.Scan = ScanClosed
        CancelTimers()
        MerchUtil.RemoveFavorites(FavoritesCreated)
   end
end

local AHArbitrageFrame = CreateFrame("Frame", "Arbitrage", UIParent)
AHArbitrageFrame:Hide()
AHArbitrageFrame:SetScript("OnEvent", OnEvent)
AHArbitrageFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
AHArbitrageFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")

AHArbitrage = {
    Scan = ScanClosed,
    Status = Status,
}
