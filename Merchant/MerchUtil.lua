-- Enable script error reporting
C_CVar.SetCVar("scriptErrors", 1)

-- Dump is a wrapper for DevTools_Dump
local function Dump(maxEntryCutoff, maxDepthCutoff, ...)
    local oldMaxEntryCutoff = _G["DEVTOOLS_MAX_ENTRY_CUTOFF"]
    local oldMaxDepthCutoff = _G["DEVTOOLS_DEPTH_CUTOFF"]

    _G["DEVTOOLS_MAX_ENTRY_CUTOFF"] = maxEntryCutoff
    _G["DEVTOOLS_DEPTH_CUTOFF"] = maxDepthCutoff
    DevTools_Dump(...)
    _G["DEVTOOLS_MAX_ENTRY_CUTOFF"] = oldMaxEntryCutoff
    _G["DEVTOOLS_DEPTH_CUTOFF"] = oldMaxDepthCutoff
end

-- Print a message with the addon name (in color) as a prefix
local function PrettyPrint(...)
    local prefix = WrapTextInColorCode("Merchant: ", "cfCFF00C")
    print(prefix, ...)
end

-- getMap returns the map the player is on
function getMap()
    return C_Map.GetBestMapForUnit("player")
end

-- OnMap returns true if the player is on the given map
function OnMap(area)
    return area[1] == getMap()
end

-- InArea returns true if the player is currently in the given area
function InArea(area)
    local map = area[1]

    if not OnMap(area) then
        return false
    end

    local x1 = area[2]
    local y1 = area[3]
    local x2 = area[4]
    local y2 = area[5]

    if x2 < x1 then
        MerchUtil.PrettyPrint("x1 and x2 are inverted: ", area)
        return false
    end

    if y2 < y1 then
        MerchUtil.PrettyPrint("y1 and y2 are inverted: ", area)
        return false
    end

    local pos = C_Map.GetPlayerMapPosition(map, "player")
    local myX = pos.x*100
    local myY = pos.y*100

    return myX >= x1 and myX <= x2 and myY >= y1 and myY <= y2
end

-- Version returns the addon version and whether it is in debug mode
local function Version()
    local debug = ""
    if C_CVar.GetCVar("scriptErrors") == "1" then
        debug = "(debug)"
    end
    return "v"..MerchGlobal.ADDON_VERSION.." "..debug
end

MerchUtil = {
    Dump = Dump,
    InArea = InArea,
    OnMap = OnMap,
    PrettyPrint = PrettyPrint,
    Version = Version,
}
