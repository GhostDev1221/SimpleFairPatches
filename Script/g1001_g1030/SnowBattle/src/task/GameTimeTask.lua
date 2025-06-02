--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

require "base.util.class"
require "base.util.MsgSender"
require "base.task.ITask"
require "base.messages.IMessages"
require "messages.Messages"
require "base.messages.TextFormat"
require "config.GameConfig"
require "config.ScoreConfig"
require "config.ProduceConfig"

local CGameTimeTask = class("GameTimeTask", ITask)

function CGameTimeTask:onTick(ticks)

    if (ticks >= GameConfig.gameTime) then
        self:stop()
    end

    local seconds = GameConfig.gameTime - ticks

    if seconds >= 60 and seconds % 60 == 0 then
        MsgSender.sendMsg(IMessages:msgGameEndTimeHint(seconds / 60, IMessages.UNIT_MINUTE, false))
    elseif seconds >= 60 and seconds % 30 == 0 then
        if seconds % 60 == 0 then
            MsgSender.sendMsg(IMessages:msgGameEndTimeHint(seconds / 60, IMessages.UNIT_MINUTE, false))
        else
            MsgSender.sendMsg(IMessages:msgGameEndTimeHint(seconds / 60, IMessages.UNIT_MINUTE, true))
        end
    elseif seconds <= 10 and seconds > 0 then
        MsgSender.sendBottomTips(3, IMessages:msgGameEndTimeHint(seconds))
        if seconds <= 3 then
            HostApi.sendPlaySound(0, 12);
        else
            HostApi.sendPlaySound(0, 11);
        end
    end

    self:giveSnowball(ticks)

    self:showGameData()

    self:produceResource(ticks)

    GameMatch:setSnowBlock()
end

function CGameTimeTask:giveSnowball(ticks)
    if ticks % 10 ~= 0 then
        return
    end
    local players = PlayerManager:getPlayers()
    for i, v in pairs(players) do
        v:addSnowball(ticks)
    end
end

function CGameTimeTask:showGameData()
    local msg = ""
    for i, v in pairs(GameMatch.Teams) do
        msg = msg .. v:getDisplayKillNum() .. TextFormat.colorWrite .. " - "
    end
    local players = PlayerManager:getPlayers()
    for i, v in pairs(players) do
        MsgSender.sendTopTipsToTarget(v.rakssid, 3, Messages:msgGameData(msg, v.score))
    end
end

function CGameTimeTask:produceResource(ticks)
    for k, team in pairs(TeamConfig.teams) do
        team.produce:addPropToWorld(ticks)
    end
end

function CGameTimeTask:onCreate()
    GameMatch.curStatus = self.status
end

function CGameTimeTask:stop()
    SecTimer.stopTimer(self.timer)
    GameMatch:endMatch()
end

GameTimeTask = CGameTimeTask.new(3)

return GameTimeTask

--endregion
