---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Jimmy.
--- DateTime: 2019/1/8 0008 14:36
---
GameSeason = {}
GameSeason.UserSeasonInfoCache = {}
GameSeason.RewardType = {
    MONEY = 1,
    KEY = 2,
    HONOR_UP = 3,
    CHEST = 4,
    GUN_CHIP = 5,
    PROP_CHIP = 6
}

function GameSeason:getUserSeasonInfo(userId, isLast, retryTime)
    WebResponse:registerCallBack(function(data, userId, isLast, retryTime)
        local player = PlayerManager:getPlayerByUserId(userId)
        if not player then
            return
        end
        if not data then
            if retryTime > 0 then
                GameSeason:getUserSeasonInfo(userId, isLast, retryTime - 1)
            end
            return
        end
        if isLast then
            GameSeason:onGetUserLastSeasonInfo(player, data)
        else
            GameSeason:onGetUserCurrentSeasonInfo(player, data)
        end
    end, WebService:GetBlockymodsUserSeasonInfo(userId, isLast), userId, isLast, retryTime)
end

function GameSeason:onGetUserCurrentSeasonInfo(player, data)
    local honorId = data.segment
    local rank = data.rank
    local honor = data.integral
    local days = math.floor(data.timeRemains / 86400)
    GameSeason.UserSeasonInfoCache[tostring(player.userId)] = {
        honorId = honorId,
        rank = rank,
        honor = honor
    }
    HostApi.sendPlayerCurrentSeasonInfo(player.rakssid, honorId, rank, honor, days)
    if data.needReward == 1 then
        GameSeason:getUserSeasonInfo(player.userId, true, 3)
    end
end

function GameSeason:onGetUserLastSeasonInfo(player, data)
    local honorId = data.segment
    local rank = data.rank
    local honor = data.integral
    HostApi.sendPlayerLastSeasonInfo(player.rakssid, honorId, rank, honor)
    GameSeason:doPlayerSeasonReward(player, honorId, rank)
    WebService:UpdateBlockymodsUserSeasonReward(player.userId)
end

function GameSeason:doPlayerSeasonReward(player, honorId, rank)
    local curHonorId = honorId
    local season_info = GameSeason.UserSeasonInfoCache[tostring(player.userId)]
    if season_info then
        curHonorId = season_info.honorId
    end
    local season = SeasonConfig:getSeasonByHonorId(honorId)
    if not season then
        return
    end
    local rewards = {}
    if curHonorId > honorId then
        rewards = season.UpRewards
        local rankReward = SeasonRankRewardConfig:getRewardBySeasonIdAndRank(season.Id, rank)
        if rankReward ~= nil then
            table.insert(rewards, rankReward)
        end
    else
        rewards = season.NormalRewards
    end
    for _, reward in pairs(rewards) do
        if reward.Type == GameSeason.RewardType.MONEY then
            player:addCurrency(reward.Count)
        end
        if reward.Type == GameSeason.RewardType.KEY then
            player.yaoshi = player.yaoshi + reward.Count
            player:syncHallInfo()
        end
        if reward.Type == GameSeason.RewardType.CHEST then
            GameChestLottery:addPlayerLotteryChest(player, reward.RealId, reward.Count)
        end
        if reward.Type == GameSeason.RewardType.GUN_CHIP then
            GameChestLottery:onPlayerRewardGunChip(player, reward.RealId, reward.Count)
        end
        if reward.Type == GameSeason.RewardType.PROP_CHIP then
            GameChestLottery:onPlayerRewardPropChip(player, reward.RealId, reward.Count)
        end
    end
end

function GameSeason:onPlayerQuit(player)
    GameSeason.UserSeasonInfoCache[tostring(player.userId)] = nil
end

return GameSeason