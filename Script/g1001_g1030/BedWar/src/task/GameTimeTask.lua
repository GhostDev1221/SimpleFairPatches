--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

require "base.util.class"
require "base.util.MsgSender"
require "base.util.VectorUtil"
require "base.task.ITask"
require "base.messages.IMessages"
require "config.GameConfig"
require "config.TeamConfig"
require "config.MoneyConfig"
require "base.messages.TextFormat"
require "config.EnchantMentNpcConfig"

local CGameTimeTask = class("GameTimeTask", ITask)

function CGameTimeTask:onTick(ticks)

    if (ticks >= GameConfig.gameTime) then
        self:stop()
    end

    local seconds = GameConfig.gameTime - ticks

    if ticks == GameConfig.enchantmentOpenTime then
        MsgSender.sendCenterTips(3, Messages:EnchantMentOpen())
        GameMatch.allowEnchantment = true
        EnchantMentNpcConfig:addLightColumnEffect()
    end

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
            HostApi.sendPlaySound(0, 12)
        else
            HostApi.sendPlaySound(0, 11)
        end
    end

    --self:sendGameData()

    self:addMoneyToWorld(ticks)

    self:teleportStandTime()

    self.tick = ticks
end

function CGameTimeTask:teleportStandTime()
    local players = PlayerManager:getPlayers()
    for i, player in pairs(players) do
        if player.entityPlayerMP ~= nil then
            local currentPosition = player.entityPlayerMP:getBottomPos()
            if player.lastPosition ~= nil and VectorUtil.equal(player.lastPosition, currentPosition) then
                if os.time() - player.standTime >= GameConfig.standTime then
                    if player.isLife or player.realLife then
                        player:teleInitPos()
                        player.standTime = os.time()
                    end
                end
            else
                player.standTime = os.time()
                player.lastPosition = {}
                player.lastPosition.x = currentPosition.x
                player.lastPosition.y = currentPosition.y
                player.lastPosition.z = currentPosition.z
            end
        end
    end
end

function CGameTimeTask:addMoneyToWorld(ticks)
    for i, v in pairs(TeamConfig.teams) do
        local ironLv = GameMatch:getTeamMoneyLv(v.id, 265)
        local iron = MoneyConfig:getMoneyItem(ironLv, 265)
        if ticks % iron.time == 0 then
            EngineWorld:addEntityItem(iron.id, iron.num, 0, iron.life, v.ironPos)
        end
        local goldLv = GameMatch:getTeamMoneyLv(v.id, 266)
        local gold = MoneyConfig:getMoneyItem(goldLv, 266)
        if ticks % gold.time == 0 then
            EngineWorld:addEntityItem(gold.id, gold.num, 0, gold.life, v.goldPos)
        end
    end
    for i, v in pairs(MoneyConfig.publicMoney) do
        local money = MoneyConfig:getMoneyItem(v.level, v.id)
        if ticks % money.time == 0 then
            EngineWorld:addEntityItem(money.id, money.num, 0, money.life, v.pos)
        end
    end
end

function CGameTimeTask:sendGameData()
    local msg = ""
    for i, v in pairs(GameMatch.Teams) do
        msg = msg .. v:getDisplayStatus() .. TextFormat.colorWrite .. " - "
    end
    if #msg ~= 0 then
        local players = PlayerManager:getPlayers()
        for i, v in pairs(players) do
            local pmsg = msg .. v.team.color .. " T : " .. v.team.name ..
            TextFormat.colorWrite .. " - " .. TextFormat.colorGold .. " Score : " .. v.score .. TextFormat.colorEnd
            MsgSender.sendBottomTipsToTarget(v.rakssid, 3, pmsg)
        end
    end
end

function CGameTimeTask:stop()
    SecTimer.stopTimer(self.timer)
    GameMatch:endMatch()
end

function CGameTimeTask:onCreate()
    GameMatch.curStatus = self.status
end

GameTimeTask = CGameTimeTask.new(3)

return GameTimeTask

--endregion
