-- Dispatch an incoming event
local function OnEvent(self, event)
    if event == "MAIL_INBOX_UPDATE" then
        if GetInboxNumItems() == 0 then
            CloseMail()
        else
            AutoLootMailItem(1)
        end
   end
end

local AutoMail = CreateFrame("Frame", "AutoMail", UIParent)
AutoMail:Hide()
AutoMail:SetScript("OnEvent", OnEvent)
AutoMail:RegisterEvent("MAIL_INBOX_UPDATE")
