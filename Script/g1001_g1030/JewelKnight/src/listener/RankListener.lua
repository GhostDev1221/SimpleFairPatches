require "base.util.StringUtil"

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

    local npc = RankNpcConfig:getRankNpcByWeekKey(key)
    if npc then
        player:setWeekRank(npc.id, rank, score)
        return
    end

    npc = RankNpcConfig:getRankNpcByDayKey(key)
    if npc then
        player:setDayRank(npc.id, rank, score)
    end
end

function RankListener.onZRangeFromRedisDB(key, data)
    local ranks = StringUtil.split(data, "#")

    local npc = RankNpcConfig:getRankNpcByWeekKey(key)
    if npc then
        npc.RankData.week = {}
        for i, v in pairs(ranks) do
            local rank = {}
            local item = StringUtil.split(v, ":")
            rank.rank = i
            rank.userId = tonumber(item[1])
            rank.score = tonumber(item[2])
            rank.name = "Steve" .. rank.rank
            rank.vip = 0
            if rank.score ~= 0 then
                npc:addWeekRank(rank)
            end
        end
        npc:rebuildRank(RankListener.TYPE_WEEK)
        return
    end

    npc = RankNpcConfig:getRankNpcByDayKey(key)
    if npc then
        npc.RankData.day = {}
        for i, v in pairs(ranks) do
            local rank = {}
            local item = StringUtil.split(v, ":")
            rank.rank = i
            rank.userId = tonumber(item[1])
            rank.score = tonumber(item[2])
            rank.name = "Steve" .. rank.rank
            rank.vip = 0
            if rank.score ~= 0 then
                npc:addDayRank(rank)
            end
        end
        npc:rebuildRank(RankListener.TYPE_DAY)
    end
end

return RankListener