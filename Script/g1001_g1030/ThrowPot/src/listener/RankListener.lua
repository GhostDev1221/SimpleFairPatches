---
--- Created by Jimmy.
--- DateTime: 2018/3/8 0008 11:43
---
require "base.util.StringUtil"
require "config.RankNpcConfig"
require "util.RealRankUtil"

RankListener = {}
RankListener.TYPE_WEEK = 1
RankListener.TYPE_DAY = 2

function RankListener:init()
    ZScoreFromRedisDBEvent.registerCallBack(self.onZScoreFromRedisDB)
    ZRangeFromRedisDBEvent.registerCallBack(self.onZRangeFromRedisDB)
end

function RankListener.onZScoreFromRedisDB(key, userId, score, rank)
    local player = PlayerManager:getPlayerByUserId(userId)
    if player == nil then
        return
    end

    if key == RealRankUtil:getRankKey() then
        RealRankUtil:getRangeRank(userId, rank)
        return
    end

    local npcs = RankNpcConfig:getRankNpcByWeekKey(key)
    if #npcs > 0 then
        for _, npc in pairs(npcs) do
            player:setWeekRank(npc.id, rank, score)
        end
        return
    end

    npcs = RankNpcConfig:getRankNpcByDayKey(key)
    if #npcs > 0 then
        for _, npc in pairs(npcs) do
            player:setDayRank(npc.id, rank, score)
        end
    end

end

function RankListener.onZRangeFromRedisDB(key, data)
    local ranks = StringUtil.split(data, "#")

    if key == RealRankUtil:getRankKey() then
        RealRankUtil:rebuildRank(ranks)
        return
    end

    local npcs = RankNpcConfig:getRankNpcByWeekKey(key)
    if #npcs > 0 then
        for _, npc in pairs(npcs) do
            npc.RankData.week = {}
            for i, v in pairs(ranks) do
                local rank = {}
                local item = StringUtil.split(v, ":")
                rank.rank = i
                rank.userId = tonumber(item[1])
                rank.score = tonumber(item[2])
                rank.name = "Steve" .. rank.rank
                rank.vip = 0
                npc:addWeekRank(rank)
            end
            npc:rebuildRank(RankListener.TYPE_WEEK)
        end
        return
    end

    npcs = RankNpcConfig:getRankNpcByDayKey(key)
    if #npcs > 0 then
        for _, npc in pairs(npcs) do
            npc.RankData.day = {}
            for i, v in pairs(ranks) do
                local rank = {}
                local item = StringUtil.split(v, ":")
                rank.rank = i
                rank.userId = tonumber(item[1])
                rank.score = tonumber(item[2])
                rank.name = "Steve" .. rank.rank
                rank.vip = 0
                npc:addDayRank(rank)
            end
            npc:rebuildRank(RankListener.TYPE_DAY)
        end
    end
end

return RankListener