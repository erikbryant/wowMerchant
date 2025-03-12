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

Utility = {
    Dump = Dump,
    PrettyPrint = PrettyPrint,
}
