-- Dispatch an incoming event
local function OnEvent(self, event)
    if event == "MAIL_INBOX_UPDATE" then
        OpenAllMail:OnClick()
    end
end

local AutoMail = CreateFrame("Frame", "AutoMail", UIParent)
AutoMail:Hide()
AutoMail:SetScript("OnEvent", OnEvent)
AutoMail:RegisterEvent("MAIL_INBOX_UPDATE")
