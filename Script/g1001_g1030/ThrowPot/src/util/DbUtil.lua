---
--- Created by Jimmy.
--- DateTime: 2018/7/18 0018 15:36
---
DbUtil = {}

function DbUtil:getPlayerData(player)
    DBManager:getPlayerData(player.userId, 1)
end

function DbUtil:saveAllPlayerData()
    if GameMatch.curTick == 0 or GameMatch.curTick % 30 ~= 0 then
        return
    end
    local players = PlayerManager:getPlayers()
    for i, player in pairs(players) do
        self:savePlayerData(player)
    end
end

function DbUtil:savePlayerData(player, immediate)
    if player == nil then
        return
    end
    if player.isReady == false then
        return
    end
    local data = {}
    data.money = player.money
    data.games = player.games
    data.integral = player.integral
    data.hasWin = player.hasWin
    data.titles = player.titles
    data.skills = player.skills
    data.chips = player.chips
    DBManager:savePlayerData(player.userId, 1, json.encode(data), immediate)
end

return DbUtil