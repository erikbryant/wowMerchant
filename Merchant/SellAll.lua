local MerchantOpen = false
local MaxBag = 4

-- Return the coordinates of the next slot (or false if at end of bags)
local function nextSlot(bag, slot)
    slots = C_Container.GetContainerNumSlots(bag)
    slot = slot + 1

    if slot > slots then
        slot = 1
        bag = bag + 1
        if bag > MaxBag then
            return -1, -1, false
        end
    end

    return bag, slot, true
end

-- Find the first slot after the marker item (the hearthstone)
local function findFirstAfterMarker()
    local bag = 0
    local slot = 1
    local markerFound = false
    local isSlot = true

    while isSlot do
        local name = C_Container.GetContainerItemLink(bag, slot)
        if name ~= nil and string.find(name, "[Hearthstone]", 0, true) then
            return nextSlot(bag, slot)
        end
        bag, slot, isSlot = nextSlot(bag, slot)
    end

    Utility.PrettyPrint("Hearthstone not found")
    return -1, -1, false
end

-- Sell all items from starting slot to end of bag
function sellOneBag(bag, slot)
    slots = C_Container.GetContainerNumSlots(bag)
    while slot <= slots do
        local name = C_Container.GetContainerItemLink(bag, slot)
        if name ~= nil then
            C_Container.UseContainerItem(bag, slot)
        end
        slot = slot + 1
    end
end

function sellFunc(bag, slot)
    return function() sellOneBag(bag, slot) end
end

-- End the merchant session
function endMerchant()
    CloseMerchant()
    C_MountJournal.Dismiss()
end

-- Sell all bag items after the marker
function SellAll()
    if not MerchantOpen then
        Utility.PrettyPrint("Go find a merchant!")
        return
    end

    local bag, slot, found = findFirstAfterMarker()
    if not found then
        return
    end

    while bag <= MaxBag do
        C_Timer.After(0.1, sellFunc(bag, slot))
        bag = bag + 1
        slot = 1
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

local SellAllFrame = CreateFrame("Frame", "SellAll", UIParent)
SellAllFrame:Hide()
SellAllFrame:SetScript("OnEvent", OnEvent)
SellAllFrame:RegisterEvent("MERCHANT_SHOW")
SellAllFrame:RegisterEvent("MERCHANT_CLOSED")
