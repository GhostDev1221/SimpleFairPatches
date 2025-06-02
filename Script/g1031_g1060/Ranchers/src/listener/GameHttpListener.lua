require "web.RanchersWebRequestType"
require "web.RanchersWebResponse"


GameHttpListener = {}

function GameHttpListener:init()
    HttpResponseEvent.registerCallBack(self.onHttpResponse)
end

function GameHttpListener.onHttpResponse(result, marked)
    if string.find(marked, RanchersWebRequestType.receiveLand) ~= nil then
        RanchersWebResponse:onReceiveLand(result, marked)
        return
    end

    if string.find(marked, RanchersWebRequestType.checkHasLand) ~= nil then
        RanchersWebResponse:onCheckHasLand(result, marked)
        return
    end

    if string.find(marked, RanchersWebRequestType.updateLandInfo) ~= nil then
        RanchersWebResponse:onUpdateLandInfo(result, marked)
        return
    end

    if string.find(marked, RanchersWebRequestType.askForHelp) ~= nil then
        RanchersWebResponse:onAskForHelp(result, marked)
        return
    end

    if string.find(marked, RanchersWebRequestType.finishHelp) ~= nil then
        RanchersWebResponse:onFinishHelp(result, marked)
        return
    end

    if string.find(marked, RanchersWebRequestType.helpList) ~= nil then
        RanchersWebResponse:onHelpList(result, marked)
        return
    end

    if string.find(marked, RanchersWebRequestType.myHelpList) ~= nil then
        RanchersWebResponse:onMyHelpList(result, marked)
        return
    end

    if string.find(marked, RanchersWebRequestType.finishOrder) ~= nil then
        RanchersWebResponse:onFinishOrder(result, marked)
        return
    end

    if string.find(marked, RanchersWebRequestType.updateOrder) ~= nil then
        RanchersWebResponse:onUpdateOrder(result, marked)
        return
    end

    if string.find(marked, RanchersWebRequestType.helpListById) ~= nil then
        RanchersWebResponse:onHelpListById(result, marked)
        return
    end

    if string.find(marked, RanchersWebRequestType.giftSend) ~= nil then
        RanchersWebResponse:onGiftSend(result, marked)
        return
    end

    if string.find(marked, RanchersWebRequestType.checkLandsInfo) ~= nil then
        RanchersWebResponse:onCheckLandsInfo(result, marked)
        return
    end

    if string.find(marked, RanchersWebRequestType.sendInvitation) ~= nil then
        RanchersWebResponse:onSendInvitation(result, marked)
        return
    end

    if string.find(marked, RanchersWebRequestType.clanProsperity) ~= nil then
        RanchersWebResponse:onClanProsperity(result, marked)
        return
    end

    if string.find(marked, RanchersWebRequestType.myClanProsperity) ~= nil then
        RanchersWebResponse:onMyClanProsperity(result, marked)
        return
    end

end

return GameHttpListener