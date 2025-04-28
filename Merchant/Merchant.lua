local MerchantOpen = false
local BackpackSlots = {}
local FirstBag = 0
local FirstSlot = 1
local MarkerFound = false

local function cacheBackpackSlots()
    for b=0,3 do
        BackpackSlots[b] = C_Container.GetContainerNumSlots(b)
    end
end

-- Return the coordinates of the next slot (or false if at end of bags)
local function nextSlot(bag, slot)
    slot = slot + 1

    if slot > BackpackSlots[bag] then
        slot = 1
        bag = bag + 1
        if bag > #BackpackSlots then
            return -1, -1, false
        end
    end

    return bag, slot, true
end

-- Find the first slot after the marker item (the hearthstone)
local function findFirstAfterMarker()
    if MarkerFound then
        return FirstBag, FirstSlot, MarkerFound
    end

    local isSlot = true

    while isSlot do
        local name = C_Container.GetContainerItemLink(FirstBag, FirstSlot)
        if name ~= nil and string.find(name, "[Hearthstone]", 0, true) then
            FirstBag, FirstSlot, MarkerFound = nextSlot(FirstBag, FirstSlot)
            return FirstBag, FirstSlot, MarkerFound
        end
        FirstBag, FirstSlot, isSlot = nextSlot(FirstBag, FirstSlot)
    end

    Utility.PrettyPrint("Hearthstone not found")
    return -1, -1, false
end

-- Sell all backpack items after the marker
function SellAll()
    if not MerchantOpen then
        Utility.PrettyPrint("Go find a merchant!")
        return
    end

    cacheBackpackSlots()
    local bag, slot, found = findFirstAfterMarker()

    while found do
        C_Container.UseContainerItem(bag, slot)
        bag, slot, found = nextSlot(bag, slot)
    end
end

-- Dispatch an incoming event
local function OnEvent(self, event)
    if event == "MERCHANT_SHOW" then
        FirstBag = 0
        FirstSlot = 1
        MarkerFound = false
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
