local OpeningMail = false

-- Dispatch an incoming event
local function OnEvent(self, event)
    if event == "MAIL_INBOX_UPDATE" then
        if OpeningMail then
            -- If we already opened the mail, don't keep opening
            local numItems, totalItems = GetInboxNumItems()
            if numItems == 0 then
                CloseMail()
                OpeningMail = false
            end
            return
        end
        OpeningMail = true
        OpenAllMail:OnClick()
    end
end

local AutoMailFrame = CreateFrame("Frame", "AutoMail", UIParent)
AutoMailFrame:Hide()
AutoMailFrame:SetScript("OnEvent", OnEvent)
AutoMailFrame:RegisterEvent("MAIL_INBOX_UPDATE")
