--World coords: UnitPosition("player")
local SWDwarvenAHPlaza = {map=84, x1=-8365.5, y1=633.0, x2=-8350.0, y2=645.0}
local SWDwarvenAHStairs = {map=84, x1=-8365.5, y1=645.5, x2=-8350.0, y2=655.0}

-- AutoMount summons a mount if player is in the given area
local function AutoMount()
    if not MerchUtil.OnMap(SWDwarvenAHPlaza) then
        return
    end

    if MerchUtil.InArea(SWDwarvenAHPlaza) and not IsMounted() then
        C_MountJournal.SummonByID(280) -- Traveler's Tundra Mammoth
    end

    C_Timer.After(2.5, AutoMount)
end

-- AutoDismount dismounts if the player is in the given area
local function AutoDismount()
    if not MerchUtil.OnMap(SWDwarvenAHStairs) then
        return
    end

    if MerchUtil.InArea(SWDwarvenAHStairs) then
        C_MountJournal.Dismiss()
    end

    C_Timer.After(0.5, AutoDismount)
end

-- Dispatch an incoming event
local function OnEvent(self, event)
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        AutoMount()
        AutoDismount()
    end
end

local AutoMountFrame = CreateFrame("Frame", "AutoMount", UIParent)
AutoMountFrame:Hide()
AutoMountFrame:SetScript("OnEvent", OnEvent)
AutoMountFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
AutoMountFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
