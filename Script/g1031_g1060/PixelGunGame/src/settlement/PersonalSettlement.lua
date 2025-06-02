require "settlement.SettlementBase"
require "config.GameConfig"

PersonalSettlement = class("PersonalSettlement", SettlementBase)
--  第一个参数 参与排序的玩家  第二个是延时时间 第三个参数表示游戏开始时间
function PersonalSettlement:SendSettlementResult(players, time)
    if #players == 0 then
        return
    end
    self:sortPlayers(players)
    for index = 1, #players do
        local player = players[index]
        player.outCome = GameResult.LOSE
    end
    LuaTimer:schedule(function()
        self:doReward(players, 0)
        self:doReport(players)
    end, time)
end

function PersonalSettlement:doGameReward(players)
    local data = {}
    data.player_list = {}
    for rank, player in pairs(players) do
        local image = "set:season_rank.json image:ic_honor_lv" .. (player.honorId + 1)
        table.insert(data.player_list, {
            rank = rank,
            duam_img = image,
            lv = player.level,
            name = player.name,
            kills = player.kills
        })
    end

    for rank, player in pairs(players) do
        local own_data = data
        own_data.reward_gold_num = player.gold
        own_data.reward_list = self:getPlayerRewardData(player, rank, false)
        own_data.self_rank = rank
        HostApi.sendOpenPixelResult(player.rakssid, true, json.encode(own_data), 1)
        player:showLvUpReward()
    end
end