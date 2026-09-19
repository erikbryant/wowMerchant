
local ItemIDs_EU = {
  
}
local ItemIDs_US = {
  
}

-- SelectRegion returns the ItemIDs applicable to the current region
local function SelectRegion()
    region = GetCurrentRegionName()
    if region == "US" then
        return ItemIDs_US
    elseif region == "EU" then
        return ItemIDs_EU
    else
        print("Region not implemented: ", region)
    end
end

ArbitrageCache = {
    ItemIDs = SelectRegion(),
}
