local function PressOpenAllButton()
    if OpenAllMail.timeUntilNextRetrieval ~= nil then
        -- Already pressed
        return
    end
    OpenAllMail:OnClick()
end

-- Dispatch an incoming event
local function OnEvent(self, event)
    if event == "MAIL_INBOX_UPDATE" then
        local numItems, totalItems = GetInboxNumItems()
        if numItems == 0 then
            CloseMail()
            return
        end
        PressOpenAllButton()
    end
end

local AutoMailFrame = CreateFrame("Frame", "AutoMail", UIParent)
AutoMailFrame:Hide()
AutoMailFrame:SetScript("OnEvent", OnEvent)
AutoMailFrame:RegisterEvent("MAIL_INBOX_UPDATE")
