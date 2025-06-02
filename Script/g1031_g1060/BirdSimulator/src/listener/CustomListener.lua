
require "manager.ConsumeDiamondsManager"
CustomListener = {}

function CustomListener:init()
    ConsumeDiamondsEvent.registerCallBack(self.onConsumeDiamonds)
end

function CustomListener.onConsumeDiamonds(rakssid, isSuccess, message, extra, payId)
    if isSuccess == false then
        return ConsumeDiamondsManager.OnConsumeFail(rakssid, message, extra, payId)
    end

    return ConsumeDiamondsManager.OnConsumeSuccess(rakssid, message, extra, payId)
end

return CustomListener
