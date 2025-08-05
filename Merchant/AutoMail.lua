local OpenedMail = false

-- Dispatch an incoming event
local function OnEvent(self, event)
    if event == "MAIL_INBOX_UPDATE" then
        if OpenedMail then
            -- If we already opened the mail, don't keep opening
            return
        end
        OpenedMail = true
        OpenAllMail:OnClick()
    end
    if event == "MAIL_CLOSED" then
        OpenedMail = false
    end
end

local AutoMail = CreateFrame("Frame", "AutoMail", UIParent)
AutoMail:Hide()
AutoMail:SetScript("OnEvent", OnEvent)
AutoMail:RegisterEvent("MAIL_INBOX_UPDATE")
AutoMail:RegisterEvent("MAIL_CLOSED")
