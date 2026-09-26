-- When in a city there is a church bell that tolls the hours.
-- This sound annoys me. I have tried to mute that specific
-- sound file, but that did not work. The bell is something
-- other than a named sound file.
--
-- The bell sound is of type "Sound Effect". Pause SFX at
-- the top of the hour.

local function EnableSFX()
    C_CVar.SetCVar("Sound_EnableSFX", "1")
end

-- Pause sound effects at the top of the hour
local function PauseSFX()
    if not IsResting() then
        -- Only pause sound effects if we are in a city
        return
    end

    local d = C_DateAndTime.GetCurrentCalendarTime()
    if d.minute == 59 then
        MerchUtil.PrettyPrint("Pausing sound effects")
        C_CVar.SetCVar("Sound_EnableSFX", "0")
        C_Timer.After(100, EnableSFX)
    end
end

-- Dispatch an incoming event
local function OnEvent(self, event)
    if event == "PLAYER_LOGOUT" then
        EnableSFX()
   end
end

local AudioToggleFrame = CreateFrame("Frame", "AudioToggle", UIParent)
AudioToggleFrame:Hide()
AudioToggleFrame:SetScript("OnEvent", OnEvent)
AudioToggleFrame:RegisterEvent("PLAYER_LOGOUT")

C_Timer.NewTicker(50, PauseSFX)
