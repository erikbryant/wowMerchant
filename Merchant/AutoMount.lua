SWDwarvenAHStairs = {84, 61.57, 31.06, 62.00, 31.89}
SWDwarvenAHPlaza = {84, 62.00, 30.96, 62.70, 32.00}

-- interval returns the time to wait between location checks
function interval(area, i)
    if Utility.OnMap(area) then
        return i
    end
    return 10.0
end

-- AutoMount summons a mount if player is in the given area
function AutoMount()
    if InArea(SWDwarvenAHPlaza) and not IsMounted() then
        C_MountJournal.SummonByID(280) -- Traveler's Tundra Mammoth
    end
    C_Timer.After(interval(SWDwarvenAHPlaza, 2.5), AutoMount)
end

-- AutoDismount dismounts if the player is in the given area
function AutoDismount()
    if InArea(SWDwarvenAHStairs) then
        C_MountJournal.Dismiss()
    end
    C_Timer.After(interval(SWDwarvenAHStairs, 0.5), AutoDismount)
end

-- Start the area scans
AutoMount()
AutoDismount()
