local MerchantOpen = false

function SellAll()
    if not MerchantOpen then
        Utility.PrettyPrint("Go find a merchant!")
        return
    end

    local bag = 0
    local slot = 1
    local foundMarker = false

    while true do
        local name = C_Container.GetContainerItemLink(bag, slot)
        if name ~= nil then
            if foundMarker then
                C_Container.UseContainerItem(bag,slot)
            else
                if string.find(name, "[Hearthstone]", 0, true) then
                    foundMarker = true
                end
            end
        end

        slot = slot + 1
        if slot > C_Container.GetContainerNumSlots(bag) then
            slot = 1
            bag = bag + 1
            if bag > 4 then
                break
            end
        end
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
