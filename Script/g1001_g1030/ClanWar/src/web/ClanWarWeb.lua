--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require"base.util.json"

ClanWarWeb = {}
ClanWarWeb.ver = nil
ClanWarWeb.RankAddr = nil
ClanWarWeb.RewardAddr = nil
ClanWarWeb.PropAddr = nil

ClanWarWeb.userAttrPath = "/minigame/i/api/{version}/user-details/{userId}"
ClanWarWeb.consumeAPI = "/props/api/{version}/consume/{userid}";
ClanWarWeb.rewardAPI = "/clans/i/api/{version}/clans/war/rewards";

function ClanWarWeb:init(version, rankAddr, rewardAddr, propAddr, gameId)
    self.ver = version
    self.RankAddr = rankAddr
    self.RewardAddr = rewardAddr
    self.PropAddr = propAddr
    self.gameId = gameId
end

function ClanWarWeb:GetReward(dataList)
    local path = self.RewardAddr..self.rewardAPI;
    path = string.gsub(path, "{version}", self.ver)

    local params = {}
    local data = {}

    local uuid = require "base.util.uuid"
    uuid.randomseed(os.time())
    data.requestId = uuid()
    data.userdataList = dataList

    local body = json.encode(data)

    HostApi.log("data:" .. body)

    local resJson = HttpRequest.syncPost(path, params, body)

    return resJson
end

function ClanWarWeb:UseProps(userId, PropId)

end

function ClanWarWeb:GetUserAttr(userId, gameType)
    local path = self.RankAddr..self.userAttrPath;
    path = string.gsub(path, "{version}", self.ver)
    path = string.gsub(path, "{userId}", tostring(userId))
    
    local params = {}
    local param = {}
    param[1] = "typeId"
    param[2] = gameType
    params[1] = param
    return HttpRequest.syncGet(path, params)
end

--endregion
