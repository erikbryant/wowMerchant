-- sort generated/arbitrageItems.log | sed "s/ *[0-9.]*$//1" | uniq > x
-- while IFS= read -r line; do
--   go run listItems/listItems.go -passPhrase unlock | egrep "$line$"
-- done < x > y
-- sort -n y | cut -c 1-8,76-900 | awk '{ print $1 ", -- " $2 " " $3 " " $4 " " $5 " " $6 " " $7 " " $8 " " $9 }'
-- rm x y
local ItemIDs = {
    18257, -- Recipe: Major Rejuvenation Potion
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
    224424, -- Pattern: Artisan Chef's Hat
}

BargainCache = {
    ItemIDs = ItemIDs,
}
