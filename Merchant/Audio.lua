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
    local d = C_DateAndTime.GetCurrentCalendarTime()

    -- Pause if we are in a city at the top of the hour
    if (d.minute >= 58 or d.minute <= 1) and IsResting() then
        MerchUtil.PrettyPrint("Pausing sound effects at:", d.minute)
        C_CVar.SetCVar("Sound_EnableSFX", "0")
    else
        EnableSFX()
    end

    C_Timer.After(30, PauseSFX)
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

-- For the first moments after logging in, IsResting() returns false whether the
-- character is resting or not. Put in a slight delay before starting the check.
C_Timer.After(5, PauseSFX)
