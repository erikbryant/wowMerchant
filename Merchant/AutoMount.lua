--World coords: UnitPosition("player")
local SWDwarvenAHPlaza = {84, -8366.3, 632.1, -8349.5, 647.6}
local SWDwarvenAHStairs = {84, -8365.8, 643.6, -8359.4, 654.9}

-- interval returns the time to wait between location checks
local function interval(area, i)
    -- TODO: hook ZONE_CHANGED and ZONE_CHANGED_NEW_AREA events to turn timer on/off

    if MerchUtil.OnMap(area) then
        return i
    end
    return 10.0
end

-- AutoMount summons a mount if player is in the given area
local function AutoMount()
    if MerchUtil.InArea(SWDwarvenAHPlaza) and not IsMounted() then
        C_MountJournal.SummonByID(280) -- Traveler's Tundra Mammoth
    end
    C_Timer.After(interval(SWDwarvenAHPlaza, 2.5), AutoMount)
end

-- AutoDismount dismounts if the player is in the given area
local function AutoDismount()
    if MerchUtil.InArea(SWDwarvenAHStairs) then
        C_MountJournal.Dismiss()
    end
    C_Timer.After(interval(SWDwarvenAHStairs, 0.5), AutoDismount)
end

-- Start the area scans
AutoMount()
AutoDismount()
