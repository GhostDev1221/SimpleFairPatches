---
--- Created by Jimmy.
--- DateTime: 2018/4/10 0010 11:20
---
require "base.util.class"
require "base.util.VectorUtil"
require "base.util.DateUtil"
require "base.cache.UserInfoCache"
require "Match"

GameRankNpc = class()

function GameRankNpc:ctor(config)
    self:init(config)
end

function GameRankNpc:init(config)
    self.id = tonumber(config.id)
    self.initPos = VectorUtil.newVector3(config.initPos[1], config.initPos[2], config.initPos[3])
    self.yaw = tonumber(config.initPos[4])
    self.key = config.key
    self.name = config.name
    self.title = config.title
    self.entityId = EngineWorld:addRankNpc(self.initPos, self.yaw, self.name)
    self.RankData = {}
    self.RankData.week = {}
    self.RankData.day = {}
    self.sendTick = 0
    self.hasWeek = false
    self.hasDay = false
end

function GameRankNpc:setZExpireat()
    HostApi.ZExpireat(self:getWeekKey(), tostring(DateUtil.getWeekLastTime()))
    HostApi.ZExpireat(self:getDayKey(), tostring(DateUtil.getDayLastTime()))
end

function GameRankNpc:getPlayerRankData(player)
    local weekKey = self:getWeekKey()
    local dayKey = self:getDayKey()
    local uid = tostring(player.userId)
    HostApi.ZScore(weekKey, uid)
    HostApi.ZScore(dayKey, uid)
end

function GameRankNpc:sendRankToPlayers()
    self.sendTick = self.sendTick + 1
    if self.sendTick % 2 ~= 0 then
        return
    end
    local players = PlayerManager:getPlayers()
    for i, v in pairs(players) do
        self:getPlayerRankData(v)
    end
end

function GameRankNpc:savePlayerRankScore(player)
    if player.gameScore > 0 then
        local weekKey = self:getWeekKey()
        local dayKey = self:getDayKey()
        local uid = tostring(player.userId)
        HostApi.ZIncrBy(weekKey, uid, player.gameScore)
        HostApi.ZIncrBy(dayKey, uid, player.gameScore)
        player.gameScore = 0
    end
end

function GameRankNpc:updateRank()
    local weekKey = self:getWeekKey()
    local dayKey = self:getDayKey()
    HostApi.ZRange(weekKey, 0, 9)
    HostApi.ZRange(dayKey, 0, 9)
end

function GameRankNpc:rebuildRank(type)
    local items = {}
    local key = ""
    if type == RankListener.TYPE_WEEK then
        items = self.RankData.week
        key = self:getWeekKey()
    end
    if type == RankListener.TYPE_DAY then
        items = self.RankData.day
        key = self:getDayKey()
    end
    local userIds = {}
    for i, v in pairs(items) do
        userIds[i] = v.userId
    end
    UserInfoCache:GetCacheByUserIds(userIds, function(type, items)
        for i, v in pairs(items) do
            local info = UserInfoCache:GetCache(v.userId)
            if info ~= nil then
                v.vip = info.vip
                v.name = info.name
            end
        end
        if type == RankListener.TYPE_WEEK then
            self.RankData.week = items
            self.hasWeek = true
        end
        if type == RankListener.TYPE_DAY then
            self.RankData.day = items
            self.hasDay = true
        end
        self:sendRankToPlayers()
    end, key, type, items)
end

function GameRankNpc:getWeekKey()
    return GameMatch.gameType .. "." .. self.key  .. ".week." .. DateUtil.getYearWeek()
end

function GameRankNpc:getDayKey()
    return GameMatch.gameType .. "." .. self.key  .. ".day." .. DateUtil.getYearDay()
end

function GameRankNpc:addWeekRank(rank)
    self.RankData.week[#self.RankData.week + 1] = rank
end

function GameRankNpc:addDayRank(rank)
    self.RankData.day[#self.RankData.day + 1] = rank
end

function GameRankNpc:buildBaseData()
    local data = {}
    data.title = self.title
    data.subType = self.id
    data.ranks = self.RankData
    return data
end

function GameRankNpc:sendRankData(player)
    if self.hasDay and self.hasWeek then
        local data = self:buildBaseData()
        RankManager:sendPlayerRank(player.rakssid, self.key, data, self.entityId)
    end
end