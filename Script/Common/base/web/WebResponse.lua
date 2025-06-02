---
--- Created by Jimmy.
--- DateTime: 2018/6/28 0028 11:25
---
require "base.util.json"
require "base.PlayerManager"

WebResponse = {}
WebResponse.callbacks = {}

function WebResponse:registerCallBack(func, marked, ...)
    assert(type(marked) == "string")
    assert(func ~= nil)
    self:unregisterCallBack(marked)
    self.callbacks[marked] = { func, ... }
end

function WebResponse:unregisterCallBack(marked)
    if self.callbacks[marked] ~= nil then
        self.callbacks[marked] = nil
    end
end

function WebResponse:onCallFunc(data, marked)
    local callback = self.callbacks[marked]
    if callback ~= nil then
        self:unregisterCallBack(marked)
        callback[1](data, unpack(callback, 2))
    end
end

function WebResponse:onGetMcpeonlineUserAttr(result, marked)
    result = self:formatResult(result)
    local data = self:formatData(result)
    if data ~= nil then
        local player = PlayerManager:getPlayerByUserId(data.id)
        if player ~= nil then
            player.staticAttr.vip = data.vip
            player.staticAttr.supperPlayer = data.spp
            player.staticAttr.lv = data.lv
            player.staticAttr.attack = data.att
            player.staticAttr.defense = data.def
            player.staticAttr.health = data.heal
            player.staticAttr.title = data.title
            player.staticAttr.clanId = data.clanId
            player.staticAttr.clanName = string.gsub(data.clanName or "", "\n", "")
            player.staticAttr.classes = data.classes
            player.staticAttr.hasInit = true
            player.vip = player.staticAttr.vip
        else
            data = nil
        end
    end
    self:onCallFunc(data, marked)
end

function WebResponse:onGetMcpeonlineReward(result, marked)
    result = self:formatResult(result)
    local data = self:formatData(result)
    local settlement = {}
    settlement.kills = 0
    if data ~= nil then
        settlement.exp = data.gain_exp
        settlement.goldCoins = data.gain_gold
        settlement.activeValues = data.use_energy
    else
        settlement.exp = 0
        settlement.goldCoins = 0
        settlement.activeValues = 0
    end
    self:onCallFunc(settlement, marked)
end

function WebResponse:onGetMcpeonlineReport(result, marked)
    self:onCallFunc(result, marked)
end

function WebResponse:onGetBlockymodsUserAttr(result, marked)
    result = self:formatResult(result)
    local data = self:formatData(result)
    if data ~= nil then
        local player = PlayerManager:getPlayerByUserId(data.userId)
        if player ~= nil then
            player.staticAttr.clanName = data.clanName
            player.staticAttr.role = data.role
            player.staticAttr.props = data.propsId or {}
            player.staticAttr.hasInit = true
        else
            data = nil
        end
    end
    self:onCallFunc(data, marked)
end

function WebResponse:onGetBlockymodsReward(result, marked)
    result = self:formatResult(result)
    local reward = self:formatData(result)
    if reward ~= nil then
        local player = PlayerManager:getPlayerByUserId(reward.userId)
        if player ~= nil then
            player.gold = reward.golds or 0
            player.available = reward.available or 0
            player.hasGet = reward.hasGet or 0
            player.adSwitch = reward.adSwitch or 0
        end
    end
    self:onCallFunc(reward, marked)
end

function WebResponse:onGetBlockymodsGoldReward(result, marked)
    result = self:formatResult(result)
    local reward = self:formatData(result)
    if reward ~= nil then
        local player = PlayerManager:getPlayerByUserId(reward.userId)
        if player ~= nil then
            player.gold = reward.golds or 0
            player.available = reward.available or 0
            player.hasGet = reward.hasGet or 0
        end
    end
    self:onCallFunc(reward, marked)
end


function WebResponse:onGetBlockymodsExpRole(result, marked)
    result = self:formatResult(result)
    local data = self:formatData(result)
    if data ~= nil then
        ExpRule:initRole(data)
    else
        ExpRule:disable()
    end
    self:onCallFunc(result, marked)
end

function WebResponse:onGetBlockymodsExp(result, marked)
    result = self:formatResult(result)
    local expInfo = self:formatData(result)
    if expInfo ~= nil then
        local player = PlayerManager:getPlayerByUserId(expInfo.userId)
        if player ~= nil then
            UserExpManager:addExpCache(expInfo.userId, expInfo.level, expInfo.experience, expInfo.expGetToday)
        end
    end
    self:onCallFunc(result, marked)
end

function WebResponse:onSaveBlockymodsExp(result, marked)
    self:onCallFunc(result, marked)
end

function WebResponse:onSaveBlockymodsHonor(result, marked)
    self:onCallFunc(result, marked)
end

function WebResponse:onGetBlockymodsUserSeasonInfo(result, marked)
    result = self:formatResult(result)
    local info = self:formatData(result)
    self:onCallFunc(info, marked)
end

function WebResponse:onUpdateBlockymodsUserSeasonReward(result, marked)
    result = self:formatResult(result)
    local isSuccess = false
    if result == "{}" then
        isSuccess = false
    else
        local data = json.encode(result)
        if data.code ~= nil and data.code == 1 then
            isSuccess = true
        end
    end
    self:onCallFunc(isSuccess, marked)
end

function WebResponse:onReportBlockymodsData(result, marked)
    self:onCallFunc(result, marked)
end

function WebResponse:onGetBlockymodsUserInfos(result, marked)
    result = self:formatResult(result)
    local data = self:formatData(result)
    self:onCallFunc(data, marked)
end

function WebResponse:onGetBlockymodsRewardList(result, marked)
    result = self:formatResult(result)
    local rewards = self:formatData(result)
    if rewards ~= nil then
        for i, reward in pairs(rewards) do
            local player = PlayerManager:getPlayerByUserId(reward.userId)
            if player ~= nil then
                player.gold = reward.golds or 0
                player.available = reward.available or 0
                player.hasGet = reward.hasGet or 0
                player.adSwitch = reward.adSwitch or 0
            end
        end
    end
    self:onCallFunc(rewards, marked)
end

function WebResponse:onReportBlockymodsList(result, marked)
    self:onCallFunc(result, marked)
end

function WebResponse:onCheckMails(result, marked)
    result = self:formatResult(result)
    local data = WebResponse:formatData(result)
    if data ~= nil then
        local items = {}
        local index = 1
        for i, v in pairs(data) do
            if v.id ~= nil then
                local item = {}
                item.id = v.id
                item.title = v.title
                item.content = v.content
                item.fromUser = v.fromUser
                item.toUser = v.toUser
                item.status = v.status
                item.mailType = v.mailType
                items[index] = item
                index = index + 1
            end
        end
        self:onCallFunc(items, marked)
        return true
    end

    self:onCallFunc(nil, marked)
end

function WebResponse:onSendMails(result, marked)
    result = self:formatResult(result)
    if result ~= "{}" then
        self:onCallFunc(result, marked)
    else
        self:onCallFunc(nil, marked)
        HostApi.log("=== LuaLog: WebResponse:onSendMails send mail failure.")
    end
end

function WebResponse:onUpdateMails(result, marked)
    result = self:formatResult(result)
    if result ~= "{}" then
        self:onCallFunc(result, marked)
    else
        self:onCallFunc(nil, marked)
        HostApi.log("=== LuaLog: WebResponse:onUpdateMails update mail failure.")
    end
end

function WebResponse:formatResult(result)
    if result == nil or string.len(result) == 0 then
        return "{}"
    end

    if string.sub(result, 1, 1) == '{' and string.find(result, "\"code\":1") ~= nil then
        return result
    end

    return "{}"
end

function WebResponse:formatResultCode(result)
    if result == nil or string.len(result) == 0 then
        return "{}"
    end

    if string.sub(result, 1, 1) == '{' and string.find(result, "\"code\":") ~= nil then
        return result
    end

    return "{}"
end

function WebResponse:formatData(result)
    if result == "{}" then
        return nil
    end
    local result = json.decode(result)
    if result.code == 1 or result.data ~= nil then
        return result.data
    end
    return nil
end

return WebResponse