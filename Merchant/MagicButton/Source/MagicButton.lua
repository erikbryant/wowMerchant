function MagicButton_Print(message)
  print("|cc935e0ffMagic Button|r: " .. message)
end

function MagicButton()
  if AuctionHouseFrame == nil then
    MagicButton_Print("Go find an Auction House")
    return
  end

  if AuctionHouseFrame.ItemBuyFrame:IsVisible() then
    AuctionHouseFrame.ItemBuyFrame.BuyoutFrame.BuyoutButton:Click()
    StaticPopup1Button1:Click()
  end

  if AuctionHouseFrame.CommoditiesBuyFrame:IsVisible() then
    MagicButton_BuyCommodityMagic()
  end
end

local function CreateCommodityBuyFrame()
  if not MagicButtonUndercutFrame then
    frame = CreateFrame(
      "FRAME",
      "MagicButtonCommodityBuyFrame",
      nil,
      "MagicButtonCommodityBuyFrameTemplate"
    )
  end
end

function MagicButton_BuyCommodityMagic()
  if not MagicButtonCommodityBuyFrame then
    CreateCommodityBuyFrame()
  end
  MagicButtonCommodityBuyFrame:ButtonPress()
end
