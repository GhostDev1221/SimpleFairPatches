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
require "process.PersonalProcess"
require "process.TeamProcess"
require "process.PvpProcess"
require "data.GameTeam"
require "manager.SupplyManager"
require "manager.SkillManager"
require "manager.DeBuffManager"

GameMatch = {}

GameMatch.gameType = ""
GameMatch.Process = nil

function GameMatch:initMatch()
    self:setProcess()
    GameTimeTask:start()
    SupplyManager:InitSupplyPoint(GameConfig.maxSupplyNum)
end

function GameMatch:setProcess()
    if self.gameType == "g1043" then
        self.Process = require "process.TeamProcess"
        TeamManager:InitTeams()
    elseif self.gameType == "g1044" then
        self.Process = require "process.PersonalProcess"
    elseif self.gameType == "g1045" then
        self.Process = require "process.PvpProcess"
    end
end

function GameMatch:onTick(ticks)
    self.Process:onTick(ticks)
    SkillManager:onTick(ticks)
    DeBuffManager:onTick(ticks)
end

function GameMatch:onPlayerKill(killer, dier)
    killer:onKill(dier)
    GameMatch.Process:onPlayerKill(killer)
    if GameMatch.Process:isGameEnd() then
        dier:onDie(true, true)
    else
        dier:onDie(false, true)
        dier:sendReviveData(killer, true)
    end
end

function GameMatch:onPlayerQuit(player)
    GameMatch.Process:onPlayerQuit(player)
    DbUtil:savePlayerData(player, true)
    DbUtil:onPlayerQuit(player)
end

return GameMatch