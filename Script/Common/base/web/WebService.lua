--region *.lua
require "base.util.json"
require "base.web.WebRequestType"

WebService = {}
WebService.ver = nil
WebService.RankAddr = nil
WebService.RewardAddr = nil
WebService.PropAddr = nil
WebService.BlockymodBaseUrl = nil

WebService.UserAttrPath = "/minigame/i/api/{version}/user-details/{userId}"
WebService.RewardAPI = "/minigame/api/{version}/rewards/{gametype}/{userId}"
WebService.RankAPI = "/minigame/api/{version}/ranks/{gametype}"
WebService.ConsumeAPI = "/props/api/{version}/consume/{userid}"

WebService.BlockymodsUserInfos = "/user/api/v1/inner/simple-info"
WebService.BlockymodsUserAttr = "/user/api/v1/inner/user/details"
WebService.BlockymodsRewardAPI = "/game/api/v1/users/games/settlement"
WebService.BlockymodsRewardGoldAPI = "/game/api/v1/users/games/settlement/golds"
WebService.BlockymodsRewardList = "/game/api/v1/users/inner/games/settlement/list"
WebService.BlockymodsReportData = "/game/api/v1/inner/users/games/reporting"
WebService.BlockymodsReportList = "/game/api/v1/inner/users/games/reporting/list"
WebService.BlockymodsExpRule = "/activity/api/v1/inner/activity/games/settlement/rule"
WebService.BlockymodsUserExp = "/activity/api/v1/inner/activity/games/user/exp"
WebService.BlockymodsSaveExp = "/activity/api/v1/inner/activity/games/records"
WebService.BlockymodsSaveHonor = "/gameaide/api/v1/inner/user/segment/integral"
WebService.BlockymodsUserSeasonInfo = "/gameaide/api/v1/inner/user/segment/info"
WebService.BlockymodsUserSeasonReward = "/gameaide/api/v1/inner/segment/integral/reward"

WebService.MailsApi = "/gameaide/api/v1/inner/game/mails"
WebService.MailsStatusApi = "/gameaide/api/v1/inner/game/mails/{id}/status"
WebService.SendMsgApi = "/gameaide/api/v1/inner/msg/send"

function WebService:init(version, config)
    self.ver = version
    self.RankAddr = config.rankAddr
    self.RewardAddr = config.rewardAddr
    self.PropAddr = config.propAddr
    self.BlockymodBaseUrl = config.blockymodsRewardAddr
    self:initGameId()
end

function WebService:initGameId()
    local uuid = require "base.util.uuid"
    uuid.randomseed(os.time())
    self.gameId = uuid()
end

function WebService:GetUserAttr(userId, gameType)
    local path = self.RankAddr .. self.UserAttrPath
    path = string.gsub(path, "{version}", self.ver)
    path = string.gsub(path, "{userId}", tostring(userId))

    local params = {}
    local param = {}
    param[1] = "typeId"
    param[2] = gameType
    params[1] = param

    local marked = WebRequestType.MCPEONLINE_USER_ATTR .. tostring(userId)

    HttpRequest.asyncGet(path, params, marked)

    return marked
end

function WebService:GetPlayerReward(userId, gametype, kills, iswin, gameId)
    local path = self.RewardAddr .. self.RewardAPI
    path = string.gsub(path, "{version}", self.ver)
    path = string.gsub(path, "{userId}", tostring(userId))
    path = string.gsub(path, "{gametype}", gametype)

    local params = {}
    local param = {}
    param[1] = "gameId"
    param[2] = gameId or self.gameId
    params[1] = param

    local param2 = {}
    param2[1] = "kill"
    param2[2] = tostring(kills)
    params[2] = param2

    local param3 = {}
    param3[1] = "isWinner"
    param3[2] = tostring(iswin)
    params[3] = param3

    local marked = WebRequestType.MCPEONLINE_REWARD .. tostring(userId)

    HttpRequest.asyncPost(path, params, "{}", marked)

    return marked
end

function WebService:PostGameResult(gameType, resultJson)
    local path = self.RankAddr .. self.RankAPI;
    path = string.gsub(path, "{version}", self.ver)
    path = string.gsub(path, "{gametype}", gameType)

    local params = {}

    HttpRequest.asyncPost(path, params, resultJson, WebRequestType.MCPEONLINE_REPORT)

    return WebRequestType.MCPEONLINE_REPORT
end

function WebService:UseProps(userId, PropId)

end

function WebService:GetBlockymodsUserAttr(userId, gameType)
    local path = self.BlockymodBaseUrl .. self.BlockymodsUserAttr

    local params = {}
    local param1 = {}
    param1[1] = "userId"
    param1[2] = tostring(userId)
    params[1] = param1

    local param2 = {}
    param2[1] = "gameId"
    param2[2] = gameType
    params[2] = param2

    local marked = WebRequestType.BLOCKYMODS_USER_ATTR .. tostring(userId)

    HttpRequest.asyncGet(path, params, marked)

    return marked
end

function WebService:GetBlockymodsReward(userId, gameType, data)
    local path = self.BlockymodBaseUrl .. self.BlockymodsRewardAPI

    local params = {}
    local param1 = {}
    param1[1] = "gameId"
    param1[2] = gameType
    params[1] = param1

    local param2 = {}
    param2[1] = "userId"
    param2[2] = tostring(userId)
    params[2] = param2

    local dataJson = json.encode(data)

    local marked = WebRequestType.BLOCKYMODS_REWARD .. tostring(userId)

    HttpRequest.asyncPost(path, params, dataJson, marked)

    return marked
end

function WebService:GetBlockymodsGoldReward(userId, gameType, golds)
    local path = self.BlockymodBaseUrl .. self.BlockymodsRewardGoldAPI
    local params = {}
    local param1 = {}
    param1[1] = "gameId"
    param1[2] = gameType
    params[1] = param1

    local param2 = {}
    param2[1] = "userId"
    param2[2] = tostring(userId)
    params[2] = param2

    local param3 = {}
    param3[1] = "golds"
    param3[2] = tostring(golds)
    params[3] = param3

    local marked = WebRequestType.BLOCKYMODS_GOLD_REWARD .. tostring(userId)

    HttpRequest.asyncPost(path, params, "{}", marked)

    return marked
end

function WebService:GetBlockymodsUserInfos(userIds, key)
    local path = self.BlockymodBaseUrl .. self.BlockymodsUserInfos

    local params = {}

    local param1 = {}
    param1[1] = "userIdList"

    local ids = ""

    for i, v in pairs(userIds) do
        if i ~= #userIds then
            ids = ids .. v .. ","
        else
            ids = ids .. v
        end
    end

    param1[2] = ids
    params[1] = param1

    local marked = WebRequestType.BLOCKYMODS_USER_INFOS .. key

    HttpRequest.asyncGet(path, params, marked)

    return marked
end

function WebService:GetBlockymodsExpRule()
    local path = self.BlockymodBaseUrl .. self.BlockymodsExpRule

    local params = {}
    local param1 = {}
    param1[1] = "gameId"
    param1[2] = BaseMain:getGameType()
    params[1] = param1

    local marked = WebRequestType.BLOCKYMODS_EXP_RULE
    HttpRequest.asyncGet(path, params, marked)
    return marked
end

function WebService:GetBlockymodsUserExp(userId)
    local path = self.BlockymodBaseUrl .. self.BlockymodsUserExp
    local params = {}

    local param1 = {}
    param1[1] = "userId"
    param1[2] = tostring(userId)
    params[1] = param1

    local marked = WebRequestType.BLOCKYMODS_USER_EXP .. tostring(userId)

    HttpRequest.asyncGet(path, params, marked)

    return marked
end

function WebService:SaveBlockymodsUsersExp(data)
    local path = self.BlockymodBaseUrl .. self.BlockymodsSaveExp
    local params = {}
    local marked = WebRequestType.BLOCKYMODS_SAVE_EXP
    HttpRequest.asyncPost(path, params, json.encode(data), marked)
    return marked
end

function WebService:SaveBlockymodsUsersHonor(data)
    local path = self.BlockymodBaseUrl .. self.BlockymodsSaveHonor
    local params = {}
    local marked = WebRequestType.BLOCKYMODS_SAVE_HONOR
    HttpRequest.asyncPost(path, params, json.encode(data), marked)
    return marked
end

function WebService:GetBlockymodsUserSeasonInfo(userId, isLast)
    local path = self.BlockymodBaseUrl .. self.BlockymodsUserSeasonInfo
    local params = {}
    local param1 = {}
    param1[1] = "gameId"
    param1[2] = BaseMain:getGameType()
    params[1] = param1

    local param2 = {}
    param2[1] = "userId"
    param2[2] = tostring(userId)
    params[2] = param2

    local param3 = {}
    param3[1] = "lastSeason"
    if isLast then
        param3[2] = "1"
    else
        param3[2] = "0"
    end
    params[3] = param3

    local marked = WebRequestType.BLOCKYMODS_USER_SEASON_INFO .. tostring(userId)
    HttpRequest.asyncGet(path, params, marked)
    return marked
end

function WebService:UpdateBlockymodsUserSeasonReward(userId)
    local path = self.BlockymodBaseUrl .. self.BlockymodsUserSeasonReward
    local params = {}
    local param1 = {}
    param1[1] = "gameId"
    param1[2] = BaseMain:getGameType()
    params[1] = param1

    local param2 = {}
    param2[1] = "userId"
    param2[2] = tostring(userId)
    params[2] = param2
    local marked = WebRequestType.BLOCKYMODS_USER_SEASON_REWARD .. tostring(userId)
    HttpRequest.asyncPost(path, params, "{}", marked)
    return marked
end

function WebService:ReportBlockymodsData(userId, gameType, time, kills, rank, isCount, integral, type)
    local path = self.BlockymodBaseUrl .. self.BlockymodsReportData

    local data = {}
    data.gameId = gameType
    data.kill = kills
    data.meanTime = time
    data.rank = rank
    data.isCount = isCount
    data.integral = integral
    data.type = type

    local params = {}
    local param1 = {}
    param1[1] = "userId"
    param1[2] = tostring(userId)
    params[1] = param1

    local dataJson = json.encode(data)

    local marked = WebRequestType.BLOCKYMODS_REPORT .. tostring(userId)

    HttpRequest.asyncPost(path, params, dataJson, marked)

    return marked
end

function WebService:GetBlockymodsRewardList(data)
    local path = self.BlockymodBaseUrl .. self.BlockymodsRewardList

    local dataJson = json.encode(data)

    local params = {}

    HttpRequest.asyncPost(path, params, dataJson, WebRequestType.BLOCKYMODS_REWARD_LIST)

    return WebRequestType.BLOCKYMODS_REWARD_LIST
end

function WebService:ReportBlockymodsList(data)
    local path = self.BlockymodBaseUrl .. self.BlockymodsReportList

    local dataJson = json.encode(data)

    local params = {}

    HttpRequest.asyncPost(path, params, dataJson, WebRequestType.BLOCKYMODS_REPORT_LIST)

    return WebRequestType.BLOCKYMODS_REPORT_LIST
end

function WebService:checkMails(userId, gameType)
    local path = self.BlockymodBaseUrl .. self.MailsApi
    local params = {}

    local param1 = {}
    param1[1] = "userId"
    param1[2] = tostring(userId)

    local param2 = {}
    param2[1] = "gameType"
    param2[2] = gameType

    params[1] = param1
    params[2] = param2

    local marked = WebRequestType.CHECK_MAILS .. tostring(userId)
    HttpRequest.asyncGet(path, params, marked)
    return marked
end

function WebService:sendMails(fromUser, toUser, mailType, title, content, gameType)
    local path = self.BlockymodBaseUrl .. self.MailsApi
    local content_json = json.encode(content)
    local data = {
        fromUser = tostring(fromUser),
        toUser = tostring(toUser),
        mailType = mailType,
        title = title,
        content = content_json,
        gameType = gameType,
    }

    local params = {}
    local dataJson = json.encode(data)

    local marked = WebRequestType.SEND_MAILS .. tostring(fromUser)
    HttpRequest.asyncPost(path, params, dataJson, marked)

    return marked
end

function WebService:updateMails(userId, id, status)
    local path = self.BlockymodBaseUrl .. self.MailsStatusApi

    path = string.gsub(path, "{id}", id)

    local param1 = {}
    param1[1] = "status"
    param1[2] = status

    local params = {}
    params[1] = param1

    local marked = WebRequestType.UPDATE_MAILS .. tostring(userId)
    HttpRequest.asyncPost(path, params, "{}", marked)

    return marked
end

function WebService:sendMsg(userId, targetIds, content, msgType, scope, gameType)
    local path = self.BlockymodBaseUrl .. self.SendMsgApi
    local content_json = json.encode(content)

    local data = {
        content = content_json,
        gameType = gameType,
        msgType = msgType, -- 1: Ranch_order_help, 2:Ranch_finish_help, 3:Ranch_rank_enter_game
        scope = scope, -- 'all', 'game', 'user'
        targetIds = targetIds, -- array[int]
    }

    local params = {}
    local dataJson = json.encode(data)

    local marked = WebRequestType.SEND_MSG .. tostring(userId)
    HttpRequest.asyncPost(path, params, dataJson, marked)

    return marked
end

--endregion
