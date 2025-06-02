require "base.messages.IMessages"
require "base.util.MsgSender"
require "base.util.json"
require "base.util.DateUtil"
require "base.web.WebService"
require "messages.Messages"
require "manager.StoreHouseManager"
require "manager.ChestManager"
require "manager.TimerManager"
require "manager.PersonalStoreManager"
require "manager.DrawLuckyManager"
require "manager.TaskManager"
require "manager.NovicePackage"
GameMatch = {}

GameMatch.gameType = "g1041"

GameMatch.curTick = 0

function GameMatch:initMatch()
    GameTimeTask:start()
    StoreHouseManager:Init()
    PersonalStoreManager:Init()
    DrawLuckyManager:Init()
    TaskManager:Init()
    ChestManager:Init()
    NovicePackage:Init()
end

function GameMatch:onTick(ticks)
    self.curTick = ticks
    TimerManager.Update()
    self:recoverHp()
    self:generateMonster()
    self:removeMonster()
    self:addPlayerScore()
    DbUtil:saveAllPlayerData()
end

function GameMatch:onPlayerQuit(player)
    DbUtil:savePlayerAllData(player, true)
    DbUtil:onPlayerQuit(player)
    player:reward()
    player:onQuit()
end

function GameMatch:addPlayerScore()
    if self.curTick == 0 or self.curTick % 60 ~= 0 then
        return
    end
    local players = PlayerManager:getPlayers()
    for i, v in pairs(players) do
        v:addScore(10)
    end
end

function GameMatch:ifUpdateRank()
    if self.curTick == 0 or self.curTick % 14400 ~= 0 then
        return
    end
    local players = PlayerManager:getPlayers()
    RanchersRankManager:updateRankData()
    for i, v in pairs(players) do
        v:getPlayerRanks()
    end
end

function GameMatch:recoverHp()
    local players = PlayerManager:getPlayers()
    for i, v in pairs(players) do
        if v.isInBattle == false
        and os.time() - v:getHpChangeTime() >= GameConfig.hpRecoverCD
        and v.hp ~= v:getHealth() then
            v:addHealth(GameConfig.hpRecover)
            v:setHpChangeTime(os.time())
        end
    end
end

function GameMatch:generateMonster()
    local players = PlayerManager:getPlayers()
    for _, v in pairs(players) do
        if v.enterFieldIndex ~= 0 then
            v:generateMonster()
        end
    end
end

function GameMatch:removeMonster()
    local players = PlayerManager:getPlayers()
    for _, player in pairs(players) do
        if player.userMonster ~= nil then
            for _, v in pairs(player.userMonster.monsters) do
                if v.isLostTarget == true then
                    player.userMonster:removeMonsterByEntityId(v.entityId)
                end
            end
        end
    end
end

return GameMatch