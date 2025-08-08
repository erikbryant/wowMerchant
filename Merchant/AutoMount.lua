SWDwarvenAHStairs = {84, 61.57, 31.06, 62.00, 31.89}
SWDwarvenAHPlaza = {84, 62.00, 30.96, 62.70, 32.00}

-- AutoMount summons a mount if player is in the given area
function AutoMount()
    if InArea(SWDwarvenAHPlaza) and not IsMounted() then
        C_MountJournal.SummonByID(280) -- Traveler's Tundra Mammoth
    end
end

-- AutoDismount dismounts if the player is in the given area
function AutoDismount()
    if InArea(SWDwarvenAHStairs) then
        C_MountJournal.Dismiss()
    end
end

C_Timer.NewTicker(2, AutoMount)
C_Timer.NewTicker(2, AutoDismount)
