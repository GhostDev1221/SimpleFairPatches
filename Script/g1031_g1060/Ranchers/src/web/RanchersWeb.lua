require"base.util.json"

RanchersWeb = {}

RanchersWeb.askForHelpApi = "/gameaide/api/v1/inner/farm/asking-for-help"
RanchersWeb.finishHelpApi = "/gameaide/api/v1/inner/farm/finish-help"
RanchersWeb.finishOrderApi = "/gameaide/api/v1/inner/farm/finish-order"
RanchersWeb.updateOrderApi = "/gameaide/api/v1/inner/farm/update-order"
RanchersWeb.helpListApi = "/gameaide/api/v1/inner/farm/help-list"
RanchersWeb.helpListByIdApi = "/gameaide/api/v1/inner/farm/help-list/{id}"
RanchersWeb.sendInvitationApi = "/gameaide/api/v1/inner/farm/invite/send-invitation"
RanchersWeb.landApi = "/gameaide/api/v1/inner/farm/lands"
RanchersWeb.landByIdApi = "/gameaide/api/v1/inner/farm/lands/{userId}"
RanchersWeb.myHelpListApi = "/gameaide/api/v1/inner/farm/my-help-list"
RanchersWeb.giftSendApi = "/gameaide/api/v1/inner/game/gift/send"
RanchersWeb.clanProsperityApi = "/gameaide/api/v1/inner/farm/ranking-list/clan-prosperity"
RanchersWeb.myClanProsperityApi = "/gameaide/api/v1/inner/farm/ranking-list/my-clan"

function RanchersWeb:init()
    self.RewardAddr = WebService.BlockymodBaseUrl
end

function RanchersWeb:askForHelp(userId, userName, uniqueId, boxAmount, fullBoxNum, orderId, boxId, count, itemId, itemLevel, rewards, isHot)
    local path = self.RewardAddr .. self.askForHelpApi

    local data = {
        boxAmount = boxAmount,
        fullBoxNum = fullBoxNum,
        uniqueId = tostring(uniqueId),
        boxId = boxId,
        count = count,
        gameType = "g1031",
        itemId = itemId,
        lv = itemLevel,
        orderId = tostring(orderId),
        userId = tostring(userId),
        userName = tostring(userName),
        rewards = rewards,
        isHot = isHot,
    }

    local params = {}
    local dataJson = json.encode(data)
    local marked = RanchersWebRequestType.askForHelp .. tostring(userId)
    HttpRequest.asyncPost(path, params, dataJson, marked)

    return marked
end

function RanchersWeb:finishHelp(userId, helperId, helperName, helperSex, uniqueId, id)
    local path = self.RewardAddr .. self.finishHelpApi

    local data = {
        id = tostring(id),        -- http服务器通过help-list 或 my-help-list 返回的 订单的需求栏id
        uniqueId = tostring(uniqueId),
        helperId = tostring(helperId),
        helperName = helperName,
        helperSex = helperSex
    }

    local params = {}
    local dataJson = json.encode(data)

    local marked = RanchersWebRequestType.finishHelp .. tostring(userId)
    HttpRequest.asyncPost(path, params, dataJson, marked)

    return marked
end

function RanchersWeb:finishOrder(userId, uniqueId)
    local path = self.RewardAddr .. self.finishOrderApi

    local param1 = {}
    param1[1] = "uniqueId"
    param1[2] = tostring(uniqueId)

    local params = {}
    params[1] = param1

    local marked = RanchersWebRequestType.finishOrder .. tostring(userId)
    HttpRequest.asyncPost(path, params, "{}", marked)

    return marked
end

function RanchersWeb:updateOrder(userId, uniqueId, fullBoxNum)
    local path = self.RewardAddr .. self.updateOrderApi

    local data = {
        uniqueId = tostring(uniqueId),
        fullBoxNum = fullBoxNum,
    }

    local params = {}
    local dataJson = json.encode(data)

    local marked = RanchersWebRequestType.updateOrder .. tostring(userId)
    HttpRequest.asyncPost(path, params, dataJson, marked)

    return marked
end

function RanchersWeb:helpList(userIds, userId)
    local path = self.RewardAddr .. self.helpListApi
    local params = {}

    local param1 = {}
    param1[1] = "userId"
    param1[2] = tostring(userId)

    local param2 = {}
    param2[1] = "userIds"

    local ids = ""
    for i, v in pairs(userIds) do
        if i ~= #userIds then
            ids = ids .. v .. ","
        else
            ids = ids .. v
        end
    end

    param2[2] = ids

    params[1] = param1
    params[2] = param2

    local marked = RanchersWebRequestType.helpList .. tostring(userId)
    HttpRequest.asyncGet(path, params, marked)

    return marked
end

function RanchersWeb:helpListById(userId, id)
    local path = self.RewardAddr .. self.helpListByIdApi
    path = string.gsub(path, "{id}", tostring(id))

    local params = {}
    local marked = RanchersWebRequestType.helpListById .. tostring(userId)
    HttpRequest.asyncGet(path, params, marked)

    return marked
end

function RanchersWeb:myHelpList(userId)
    local path = self.RewardAddr .. self.myHelpListApi
    local params = {}
    local param1 = {}
    param1[1] = "userId"
    param1[2] = tostring(userId)
    params[1] = param1
    local marked = RanchersWebRequestType.myHelpList .. tostring(userId)
    HttpRequest.asyncGet(path, params, marked)
    return marked
end

function RanchersWeb:receiveLand(userId)
    local path = self.RewardAddr .. self.landApi

    local data = {
        userId =  tostring(userId),
    }

    local params = {}
    local dataJson = json.encode(data)

    local marked = RanchersWebRequestType.receiveLand .. tostring(userId)
    HttpRequest.asyncPost(path, params, dataJson, marked)

    return marked
end

function RanchersWeb:checkHasLand(userId)
    local path = self.RewardAddr .. self.landByIdApi
    path = string.gsub(path, "{userId}", tostring(userId))

    local params = {}
    local marked = RanchersWebRequestType.checkHasLand .. tostring(userId)
    HttpRequest.asyncGet(path, params, marked)

    return marked
end

function RanchersWeb:checkLandsInfo(userIds, key)
    local path = self.RewardAddr .. self.landApi
    local params = {}
    local param1 = {}

    local ids = ""
    for i, v in pairs(userIds) do
        if i ~= #userIds then
            ids = ids .. v .. ","
        else
            ids = ids .. v
        end
    end

    param1[1] = "ids"
    param1[2] = ids
    params[1] = param1
    local marked = RanchersWebRequestType.checkLandsInfo .. key
    HttpRequest.asyncGet(path, params, marked)
    return marked

end

function RanchersWeb:updateLandInfo(userId, exp, gift, level, prosperity)
    local path = self.RewardAddr .. self.landByIdApi
    path = string.gsub(path, "{userId}", tostring(userId))

    local data = {
        exp = exp,
        gift = gift,
        level = level,
        prosperity = prosperity,
    }

    local params = {}
    local dataJson = json.encode(data)

    local marked = RanchersWebRequestType.updateLandInfo .. tostring(userId)
    HttpRequest.asyncPost(path, params, dataJson, marked)

    return marked
end

function RanchersWeb:giftSend(fromUser, fromTitle, fromContent, fromMailType, toUser, toTitle, toContent, mailType, gameType)
    local path = self.RewardAddr .. self.giftSendApi

    local fromContent_json = json.encode(fromContent)
    local toContent_json = json.encode(toContent)

    local data = {
        fromUser = tostring(fromUser),
        fromTitle = fromTitle,
        fromContent = fromContent_json,
        fromMailType = fromMailType,
        toUser = tostring(toUser),
        title = toTitle,
        content = toContent_json,
        mailType = mailType,
        gameType = gameType
    }

    local params = {}
    local dataJson = json.encode(data)
    local marked = RanchersWebRequestType.giftSend .. tostring(fromUser)
    HttpRequest.asyncPost(path, params, dataJson, marked)

    return marked
end

function RanchersWeb:sendInvitation(userId, targetUserId, playerName)
    local path = self.RewardAddr .. self.sendInvitationApi
    local data = {
        gameType = "g1031",
        targetId = tostring(targetUserId),
        userId = tostring(userId),
        userName = tostring(playerName),
    }

    local params = {}
    local dataJson = json.encode(data)
    local marked = RanchersWebRequestType.sendInvitation .. tostring(userId)
    HttpRequest.asyncPost(path, params, dataJson, marked)
    return marked
end

function RanchersWeb:getClanProsperity()
    local path = self.RewardAddr .. self.clanProsperityApi
    local params = {}
    local marked = RanchersWebRequestType.clanProsperity
    HttpRequest.asyncGet(path, params, marked)

    return marked
end

function RanchersWeb:getMyClanProsperity(userId)

    local path = self.RewardAddr .. self.myClanProsperityApi
    local params = {}
    local param1 = {}
    param1[1] = "userId"
    param1[2] = tostring(userId)
    params[1] = param1
    local marked = RanchersWebRequestType.myClanProsperity .. tostring(userId)
    HttpRequest.asyncGet(path, params, marked)

    return marked
end
