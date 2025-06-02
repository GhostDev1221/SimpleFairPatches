---
--- Created by Jimmy.
--- DateTime: 2018/7/2 0002 16:39
---
RankManager = {}
RankManager.PlayerRanks = {}
RankManager.HistoryRecords = {}

function RankManager:removePlayerRank(rakssid)
    rakssid = tostring(rakssid)
    self.PlayerRanks[rakssid] = nil
    for key, record in pairs(self.HistoryRecords) do
        if StringUtil.split(key, "#")[1] == rakssid then
            self.HistoryRecords[key] = nil
        end
    end
end

function RankManager:buildPlayerRank(rakssid, key)
    local player_rank = self.PlayerRanks[tostring(rakssid)]
    if player_rank == nil then
        player_rank = {}
        player_rank[key] = {}
        player_rank[key].rakssid = rakssid
        player_rank[key].day = {}
        player_rank[key].week = {}
        player_rank[key].hasDay = false
        player_rank[key].hasWeek = false
        self.PlayerRanks[tostring(rakssid)] = player_rank
    else
        if player_rank[key] == nil then
            player_rank[key] = {}
            player_rank[key].rakssid = rakssid
            player_rank[key].day = {}
            player_rank[key].week = {}
            player_rank[key].hasDay = false
            player_rank[key].hasWeek = false
        end
    end
    return player_rank
end

function RankManager:addPlayerDayRank(player, key, rank, score, func, ...)
    local rank_data = self:buildPlayerRank(player.rakssid, key)
    local data = {}
    data.rank = rank
    data.userId = tonumber(tostring(player.userId))
    data.score = tonumber(score)
    data.name = player.name
    data.vip = player.vip
    rank_data[key].day = data
    if rank_data[key].hasDay and rank_data[key].hasWeek then
        rank_data[key].hasWeek = false
    end
    rank_data[key].hasDay = true
    if rank_data[key].hasDay and rank_data[key].hasWeek then
        func(...)
    end
end

function RankManager:addPlayerWeekRank(player, key, rank, score, func, ...)
    local rank_data = self:buildPlayerRank(player.rakssid, key)
    local data = {}
    data.rank = rank
    data.userId = tonumber(tostring(player.userId))
    data.score = tonumber(score)
    data.name = player.name
    data.vip = player.vip
    rank_data[key].week = data
    if rank_data[key].hasDay and rank_data[key].hasWeek then
        rank_data[key].hasDay = false
    end
    rank_data[key].hasWeek = true
    if rank_data[key].hasDay and rank_data[key].hasWeek then
        func(...)
    end
end

function RankManager:sendPlayerRank(rakssid, key, data, entityId)
    local player_rank = self:buildPlayerRank(rakssid, key)
    local rank_data = player_rank[key]
    if rank_data.hasDay and rank_data.hasWeek then
        local own = {}
        own.day = rank_data.day
        own.week = rank_data.week
        data.own = own
        local result = json.encode(data)
        local hash = tostring(rakssid) .. "#" .. tostring(entityId)
        if self.HistoryRecords[hash] == result then
            return
        end
        self.HistoryRecords[hash] = result
        HostApi.sendRankData(rakssid, entityId, result)
    end
end

function RankManager:clearRanks()
    self.PlayerRanks = {}
    self.HistoryRecords = {}
end

return RankManager