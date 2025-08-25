local AHOpen = false

-- sort generated/bargains.log| uniq > x
-- while IFS= read -r line; do
--   go run listItems/listItems.go -passPhrase unlock | egrep "$line"
-- done < x > y
-- sort -n y | cut -c 1-8,76-900 | awk '{ print $1 ", -- " $2 " " $3 " " $4 " " $5 " " $6 " " $7 " " $8 " " $9 }'
local ItemIDs = {
    12365, -- Dense Stone
    12833, -- Plans: Hammer of the Titans
    17682, -- Book: Gift of the Wild
    17683, -- Book: Gift of the Wild
    18567, -- Elemental Flux
    21882, -- Soul Essence
    22146, -- Book: Gift of the Wild
    23572, -- Primal Nether
    25044, -- Rubellite Ring
    30183, -- Nether Vortex
    30306, -- Pattern: Boots of Utter Darkness
    30307, -- Pattern: Boots of the Crimson Hawk
    30324, -- Plans: Red Havoc Boots
    43574, -- Dissolved Soul Essence
    49908, -- Primordial Saronite
    72988, -- Windwool Cloth
    82441, -- Bolt of Windwool Cloth
    94573, -- Direhorn Runt
    112276, -- Three of Iron
    153637, -- Rubellite Staff of Intuition
    153701, -- Rubellite
    153714, -- Natant Rubellite
    154898, -- Meaty Haunch
    160298, -- Durable Flux
    172052, -- Aethereal Meat
    172053, -- Tenebrous Ribs
    173110, -- Umbryl
    179315, -- Shadowy Shank
    191235, -- Draconium Blacksmith's Toolbox
    191304, -- Sturdy Expedition Shovel
    191578, -- Recipe: Transmute: Awakened Fire
    191580, -- Recipe: Transmute: Awakened Earth
    192636, -- Woolly Mountain Pelt
    192647, -- Terrene Speck
    192658, -- High-Fiber Leaf
    192662, -- Pyretic Speck
    193879, -- Pattern: Infurious Footwraps of Indemnity
    194485, -- Plans: Infurious Warboots of Impunity
    199956, -- Enchant Ring - Devotion of Versatility
    199998, -- Enchant Ring - Devotion of Versatility
    200040, -- Enchant Ring - Devotion of Versatility
    200788, -- Mantacorn Horns
    200789, -- Beckoning Kite
    202070, -- Exceptional Pelt
    218338, -- Bottled Storm
    218339, -- Burning Cinderbee Setae
    220219, -- Mound of Night Soil
    220225, -- Tattered Standard
    220229, -- Dormant Core
    220242, -- Razored Tail-Blade
    220256, -- Clump of Rotting Detritus
    220261, -- Pungent Mushroom
    220264, -- Jaw with Barbed Teeth
    220267, -- Combustible Gland
    220282, -- Tuft of Whiskers
    220283, -- Pileus Puff
    220289, -- Venomous Stinger
    221754, -- Ringing Deeps Ingot
    221756, -- Vial of Kaheti Oils
    221872, -- Potion Bomb of Speed
    221873, -- Potion Bomb of Speed
    221874, -- Potion Bomb of Speed
    221876, -- Potion Bomb of Recovery
    221877, -- Potion Bomb of Recovery
    221878, -- Potion Bomb of Recovery
    221904, -- Tinker: Earthen Delivery Drill
    221905, -- Tinker: Earthen Delivery Drill
    221906, -- Tinker: Earthen Delivery Drill
    221914, -- Overclocked Cogwheel
    221915, -- Overclocked Cogwheel
    221916, -- Overclocked Cogwheel
    221920, -- Adjustable Cogwheel
    221921, -- Adjustable Cogwheel
    221922, -- Adjustable Cogwheel
    221923, -- Recalibrated Safety Switch
    221924, -- Recalibrated Safety Switch
    221925, -- Recalibrated Safety Switch
    221926, -- Blame Redirection Device
    221927, -- Blame Redirection Device
    221928, -- Blame Redirection Device
    221932, -- Complicated Fuse Box
    221933, -- Complicated Fuse Box
    221934, -- Complicated Fuse Box
    221935, -- Pouch of Pocket Grenades
    221936, -- Pouch of Pocket Grenades
    221937, -- Pouch of Pocket Grenades
    222868, -- Dawnthread Lining
    222869, -- Dawnthread Lining
    222870, -- Dawnthread Lining
    222882, -- Weavercloth Embroidery Thread
    222883, -- Weavercloth Embroidery Thread
    222884, -- Weavercloth Embroidery Thread
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
    223663, -- Enchant Ring - Glimmering Haste
    223664, -- Enchant Ring - Glimmering Haste
    223665, -- Enchant Ring - Glimmering Haste
    223666, -- Enchant Ring - Glimmering Mastery
    223667, -- Enchant Ring - Glimmering Mastery
    223668, -- Enchant Ring - Glimmering Mastery
    223669, -- Enchant Ring - Glimmering Versatility
    223670, -- Enchant Ring - Glimmering Versatility
    223671, -- Enchant Ring - Glimmering Versatility
    223714, -- Enchant Bracer - Whisper of Armored Leech
    223715, -- Enchant Bracer - Whisper of Armored Leech
    223716, -- Enchant Bracer - Whisper of Armored Leech
    223720, -- Enchant Bracer - Whisper of Armored Speed
    223721, -- Enchant Bracer - Whisper of Armored Speed
    223722, -- Enchant Bracer - Whisper of Armored Speed
    223732, -- Enchant Cloak - Whisper of Silken Leech
    223733, -- Enchant Cloak - Whisper of Silken Leech
    223734, -- Enchant Cloak - Whisper of Silken Leech
    224424, -- Pattern: Artisan Chef's Hat
    224434, -- Pattern: Dawnthread Lining
    224434, -- Pattern: Dawnthread Lining
    226034, -- Vantus Rune: Nerub-ar Palace
    226035, -- Vantus Rune: Nerub-ar Palace
    226036, -- Vantus Rune: Nerub-ar Palace
    226643, -- Plans: Beledar's Bulwark
    228509, -- Diaphanous Webbing
    232935, -- Vantus Rune: Liberation of Undermine
    232936, -- Vantus Rune: Liberation of Undermine
    232937, -- Vantus Rune: Liberation of Undermine
    234380, -- Steamboil Fuel Tank
    234381, -- Handcrank Fuel Tank
    234386, -- Handcrank Fuel Injector
    234415, -- Handcrank Casing
    234416, -- Steamboil Casing
    234417, -- Handcrank Gears
    234418, -- Steamboil Gears
    234419, -- Steamboil Mounting System
    234420, -- Handcrank Mounting System
    238874, -- Congealed Mana
    0, -- Sacrificial entry to "prime the pump"
}

local function Send(itemID)
    if not AHOpen then
        MerchUtil.PrettyPrint("AH is closed")
        return
    end

    local itemKey = C_AuctionHouse.MakeItemKey(itemID)
    local sorts = {
        {sortOrder=Enum.AuctionHouseSortOrder.Price, reverseSort=false},
    }
    C_AuctionHouse.SendSearchQuery(itemKey, sorts, false)
end

local function BargainsHelper()
    if #ItemIDs == 0 then
        MerchUtil.PrettyPrint("...done scanning for bargains")
        return
    end

    itemID = table.remove(ItemIDs)
    MerchUtil.PrettyPrint("  scan: ", itemID)
    Send(itemID)
    C_Timer.After(0.1, BargainsHelper)
end

local function Bargains()
    if not AHOpen then
        MerchUtil.PrettyPrint("Go to an auction house")
        return
    end

    MerchUtil.PrettyPrint("Scanning for bargains...")
    BargainsHelper()
end

-- /dump AHQuery.Send(223101)

-- Dispatch an incoming event
local function OnEvent(self, event, item)
    if event == "AUCTION_HOUSE_SHOW" then
        AHOpen = true
        return
    elseif event == "AUCTION_HOUSE_CLOSED" then
        AHOpen = false
        return
    end

    local price = -1
    local itemID = 0
    local itemLevel = 0

    if event == "ITEM_SEARCH_RESULTS_UPDATED" then
        local result = C_AuctionHouse.GetItemSearchResultInfo(item, 1)
        if result == nil then
            return
        end
        price = result.buyoutAmount
        itemID = item.itemID
        itemLevel = item.itemLevel
    elseif event == "COMMODITY_SEARCH_RESULTS_UPDATED" then
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
    end
end

local function Status()
    MerchUtil.PrettyPrint("AHOpen: ", AHOpen)
end

local AHQueryFrame = CreateFrame("Frame", "AHQuery", UIParent)
AHQueryFrame:Hide()
AHQueryFrame:SetScript("OnEvent", OnEvent)
AHQueryFrame:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")
AHQueryFrame:RegisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED")
AHQueryFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
AHQueryFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")

AHQuery = {
    Bargains = Bargains,
    Send = Send,
    Status = Status,
}
