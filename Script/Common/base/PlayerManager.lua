---
--- Created by Jimmy.
--- DateTime: 2018/10/9 0009 10:47
---
require "base.messages.IMessages"
require "base.util.MsgSender"
require "base.rank.RankManager"
require "base.exp.UserExpManager"
require "base.season.SeasonManager"

PlayerManager = {}
PlayerManager.Players = {}
PlayerManager.MaxPlayer = 8

function PlayerManager:setMaxPlayer(maxPlayer)
    self.MaxPlayer = maxPlayer
end

function PlayerManager:getMaxPlayer()
    return self.MaxPlayer
end

function PlayerManager:isPlayerFull()
    return self:getPlayerCount() >= self.MaxPlayer
end

function PlayerManager:isPlayerEmpty()
    return self:getPlayerCount() <= 0
end

function PlayerManager:isPlayerEnough(players)
    return self:getPlayerCount() >= (players or 1)
end

function PlayerManager:isPlayerExists()
    return self:getPlayerCount() > 0
end

function PlayerManager:addPlayer(player)
    self:subPlayer(player)
    table.insert(self.Players, player)
    MsgSender.sendMsg(IMessages:msgPlayerCount(self:getPlayerCount()))
    HostApi.log(string.format("PlayerManager:addPlayer(PlayerCount=%d)", self:getPlayerCount()))
end

function PlayerManager:subPlayer(player)
    RankManager:removePlayerRank(player.rakssid)
    PlayerClassInfo:removeClasses(player.userId)
    UserExpManager:removeExpCache(player.userId)
    local sendMsg = false
    for pos, c_player in pairs(self.Players) do
        if tostring(player.userId) == tostring(c_player.userId) then
            table.remove(self.Players, pos)
            sendMsg = true
        end
    end
    if sendMsg then
        MsgSender.sendMsg(IMessages:msgPlayerQuit(player:getDisplayName()))
        MsgSender.sendMsg(IMessages:msgPlayerLeft(self:getPlayerCount()))
        HostApi.log(string.format("PlayerManager:subPlayer(PlayerCount=%d)", self:getPlayerCount()))
    end
end

function PlayerManager:getPlayerCount()
    return #self.Players
end

function PlayerManager:getPlayerByRakssid(rakssId)
    for _, player in pairs(self.Players) do
        if player.rakssid == rakssId then
            return player
        end
    end
    return nil
end

function PlayerManager:getPlayerByUserId(userId)
    for _, player in pairs(self.Players) do
        if tostring(player.userId) == tostring(userId) then
            return player
        end
    end
    return nil
end

function PlayerManager:getPlayerByEntityId(entityId)
    for _, player in pairs(self.Players) do
        if player:getEntityId() == entityId then
            return player
        end
    end
    return nil
end

function PlayerManager:getPlayerByPlayerMP(playerMP)
    if playerMP == nil then
        return nil
    end
    return self:getPlayerByRakssid(playerMP:getRaknetID())
end

function PlayerManager:getPlayers()
    return self.Players
end

function PlayerManager:copyPlayers()
    local players = {}
    for _, player in pairs(self.Players) do
        table.insert(players, player)
    end
    return players
end

return PlayerManager
