---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:10
---

require "base.messages.IMessages"
require "base.util.MsgSender"
require "base.util.json"
require "base.util.DateUtil"
require "base.web.WebService"
require "messages.Messages"
require "util.DbUtil"

GameMatch = {}

GameMatch.gameType = "g1042"
GameMatch.curTick = 0

function GameMatch:initMatch()
    GameTimeTask:start()
end

function GameMatch:onTick(ticks)
    self.curTick = ticks
    DbUtil:saveAllPlayerData()
    WaitUpgradeQueue:onTick()
	local players = PlayerManager:getPlayers()
    for i, player in pairs(players) do
        player:onTick()
    end
end

function GameMatch:onPlayerQuit(player)
    DbUtil:savePlayerData(player, true)
    DbUtil:onPlayerQuit(player)
    GameSeason:onPlayerQuit(player)
end

return GameMatch