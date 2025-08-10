local MerchantOpen = false
local MaxBag = 4
local ItemsToSell = 0

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
    local isSlot = true

    while isSlot do
        local name = C_Container.GetContainerItemLink(bag, slot)
        if name ~= nil and string.find(name, "[Hearthstone]", 0, true) then
            return nextSlot(bag, slot)
        end
        bag, slot, isSlot = nextSlot(bag, slot)
    end

    MerchUtil.PrettyPrint("Hearthstone not found")
    return -1, -1, false
end

-- Increment global to-sell counter
function INC()
    ItemsToSell = ItemsToSell + 1
end

-- Decrement global to-sell counter
function DEC()
    ItemsToSell = ItemsToSell - 1
    if ItemsToSell == 0 then
        CloseMerchant()
        C_MountJournal.Dismiss()
    end
end

-- Return a function closure
function sellFunc(bag, slot)
    return function() sell(bag, slot) end
end

-- Repeat until item is sold
function sell(bag, slot)
    local itemID = C_Container.GetContainerItemID(bag, slot)
    if itemID == nil then
        DEC()
        return
    end

    if not MerchantOpen then
        return
    end

    C_Container.UseContainerItem(bag, slot)
    C_Timer.After(0.4, sellFunc(bag, slot))
end

-- Try to sell given slot
function tryToSell(bag, slot)
    local itemID = C_Container.GetContainerItemID(bag, slot)
    if itemID == nil then
        return
    end

    itemID = tonumber(itemID)
    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(
        function()
            local itemInfo = { C_Item.GetItemInfo(itemID) }
            local sellPrice = itemInfo[11]
            if sellPrice <= 0 then
                return
            end
            INC()
            sell(bag, slot)
        end
    )
end

-- Sell all bag items after the marker
function SellAll()
    if not MerchantOpen then
        MerchUtil.PrettyPrint("Go find a merchant!")
        return
    end

    local bag, slot, isSlot = findFirstAfterMarker()
    while isSlot do
        tryToSell(bag, slot)
        bag, slot, isSlot = nextSlot(bag, slot)
    end
end

-- Dispatch an incoming event
local function OnEvent(self, event)
    if event == "MERCHANT_SHOW" then
        MerchantOpen = true
        ItemsToSell = 0
    elseif event == "MERCHANT_CLOSED" then
        MerchantOpen = false
   end
end

local SellAllFrame = CreateFrame("Frame", "SellAll", UIParent)
SellAllFrame:Hide()
SellAllFrame:SetScript("OnEvent", OnEvent)
SellAllFrame:RegisterEvent("MERCHANT_SHOW")
SellAllFrame:RegisterEvent("MERCHANT_CLOSED")
