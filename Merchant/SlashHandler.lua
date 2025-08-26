-- SlashUsage prints a usage message for the slash commands
local function SlashUsage()
    local x, y, _, _ = UnitPosition("player")
    local pos = string.format("(%.2f, %.2f)", x, y)
    MerchUtil.PrettyPrint(MerchUtil.Version(), "  ", UnitName("player").."-"..GetRealmName(), "  ", pos)
    MerchUtil.PrettyPrint("Usage '"..MerchGlobal.SLASH_CMD.." [command]' where command is:")
    MerchUtil.PrettyPrint("  debug 0/1           - debugging")
    MerchUtil.PrettyPrint("  status                 - dump internal state")
    MerchUtil.PrettyPrint("  scan                   - start an AH commodities scan")
    MerchUtil.PrettyPrint("  arbitrage             - start an AH arbitrage scan")
    MerchUtil.PrettyPrint("  validate              - validate the price cache")
end

-- SlashHandler processes the slash command the player typed
local function SlashHandler(msg, ...)
    msg = string.lower(msg)
    if msg == "debug 1" or msg == "d1" then
        C_CVar.SetCVar("scriptErrors", 1)
        MerchUtil.PrettyPrint("Debugging enabled")
    elseif msg == "debug 0" or msg == "d0" then
        C_CVar.SetCVar("scriptErrors", 0)
        MerchUtil.PrettyPrint("Debugging disabled")
    elseif msg == "status" then
        AHArbitrage.Status()
        AHQuery.Status()
    elseif msg == "scan" then
        AHArbitrage.Scan()
    elseif msg == "arbitrage" then
        AHQuery.Arbitrage()
    elseif msg == "validate" then
        PriceCache.ValidatePriceCache()
    else
        if msg ~= "" then
            MerchUtil.PrettyPrint("Unknown slash command:", msg)
        end
        SlashUsage()
    end
end

-- Register the slash handlers
_G["SLASH_"..MerchGlobal.ADDON_NAME.."1"] = MerchGlobal.SLASH_CMD
SlashCmdList[MerchGlobal.ADDON_NAME] = SlashHandler
