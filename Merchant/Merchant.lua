local MerchantOpen = false

-- Return the coordinates of the next slot (or false if at end of bags)
local function nextSlot(bag, slot)
    slot = slot + 1

    if slot > C_Container.GetContainerNumSlots(bag) then
        slot = 1
        bag = bag + 1
        if bag > 4 then
            -- Ignore the reagent bag
            return -1, -1, false
        end
    end

    return bag, slot, true
end

-- Find the first slot after the marker item (the hearthstone)
local function findFirstSellable()
    local bag = 0
    local slot = 1
    local found = true

    while found do
        local name = C_Container.GetContainerItemLink(bag, slot)
        if name ~= nil and string.find(name, "[Hearthstone]", 0, true) then
            return nextSlot(bag, slot)
        end
        bag, slot, found = nextSlot(bag, slot)
    end

    Utility.PrettyPrint("Hearthstone not found")
    return -1, -1, false
end

-- Sell all items after the marker and before the reagent bag
function SellAll()
    if not MerchantOpen then
        Utility.PrettyPrint("Go find a merchant!")
        return
    end

    local bag, slot, found = findFirstSellable()
    while found do
        C_Container.UseContainerItem(bag,slot)
        bag, slot, found = nextSlot(bag, slot)
    end
end

-- Dispatch an incoming event
local function OnEvent(self, event)
    if event == "MERCHANT_SHOW" then
        MerchantOpen = true
    elseif event == "MERCHANT_CLOSED" then
        MerchantOpen = false
   end
end

local Merchant = CreateFrame("Frame", "Merchant", UIParent)
Merchant:Hide()
Merchant:SetScript("OnEvent", OnEvent)
Merchant:RegisterEvent("MERCHANT_SHOW")
Merchant:RegisterEvent("MERCHANT_CLOSED")

Utility.PrettyPrint("Loaded and ready to sell!")
