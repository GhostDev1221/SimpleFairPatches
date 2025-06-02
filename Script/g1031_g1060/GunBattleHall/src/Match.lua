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
require "util.GameManager"

GameMatch = {}

GameMatch.gameType = "g1032"

GameMatch.curTick = 0

function GameMatch:initMatch()
    GameTimeTask:start()
end

function GameMatch:onTick(ticks)
    self.curTick = ticks
    self:ifUpdateRank()
    GameManager:onTick(ticks)
    DbUtil:saveAllPlayerData()
end

function GameMatch:onPlayerQuit(player)
    DbUtil:savePlayerData(player, true)
end

function GameMatch:ifUpdateRank()
    if self.curTick % 300 == 0 and PlayerManager:isPlayerExists() then
        RankNpcConfig:updateRank()
    end
end

return GameMatch