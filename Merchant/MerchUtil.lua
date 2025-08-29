local LastMessagePrinted = ""

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

-- Return the args concatenated into a single space-delimited string
local function ConcatArgs(...)
    local args = ""
    for i = 1, select("#", ...) do
        args = args.." "..tostring(select(i, ...))
    end
    return args
end

-- Print a message with the addon name (in color) as a prefix
local function PrettyPrint(...)
    local message = ConcatArgs(...)
    if message == LastMessagePrinted then
        -- Do not repeat messages
        return
    end

    local prefix = WrapTextInColorCode("Merchant: ", "cfF00CCF")
    print(prefix, ...)

    LastMessagePrinted = message
end

-- OnMap returns true if the player is on the given map
local function OnMap(a)
    return a.map == C_Map.GetBestMapForUnit("player")
end

-- InArea returns true if the player is currently in the given area
local function InArea(a)
    if not OnMap(a) then
        return false
    end

    if a.x2 < a.x1 then
        MerchUtil.PrettyPrint("x1 and x2 are inverted: ")
        MerchUtil.Dump(10, 10, a)
        return false
    end

    if a.y2 < a.y1 then
        MerchUtil.PrettyPrint("y1 and y2 are inverted: ")
        MerchUtil.Dump(10, 10, a)
        return false
    end

    local x, y, z, continent = UnitPosition("player")
    return x >= a.x1 and x <= a.x2 and y >= a.y1 and y <= a.y2
end

-- Version returns the addon version and whether it is in debug mode
local function Version()
    local debug = ""
    if C_CVar.GetCVar("scriptErrors") == "1" then
        debug = "(debug)"
    end
    return "v"..MerchGlobal.ADDON_VERSION.." "..debug
end

-- RemoveFavorites removes all of the favorites that were created this login session
local function RemoveFavorites(faves)
    for _, itemKey in pairs(faves) do
        C_AuctionHouse.SetFavoriteItem(itemKey, false)
    end
    faves = {}
end

MerchUtil = {
    Dump = Dump,
    InArea = InArea,
    OnMap = OnMap,
    PrettyPrint = PrettyPrint,
    RemoveFavorites = RemoveFavorites,
    Version = Version,
}
