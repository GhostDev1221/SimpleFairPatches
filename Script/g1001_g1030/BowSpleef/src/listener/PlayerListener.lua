--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "data.GamePlayer"
require "Match"
require "base.messages.IMessages"
require "messages.Messages"
require "base.util.MsgSender"
require "base.code.GameOverCode"

PlayerListener = {}

function PlayerListener:init()
    BaseListener.registerCallBack(PlayerLoginEvent, self.onPlayerLogin)
    BaseListener.registerCallBack(PlayerLogoutEvent, self.onPlayerLogout)
    BaseListener.registerCallBack(PlayerReadyEvent, self.onPlayerReady)

    PlayerDieEvent.registerCallBack(self.onPlayerDied)
    PlayerAttackedEvent.registerCallBack(self.onPlayerHurt)
    PlayerUseThrowableItemEvent.registerCallBack(self.onUseThrowableItem)
end

function PlayerListener.onPlayerLogin(clientPeer)
    if GameMatch.hasStartGame then
        return GameOverCode.GameStarted
    end
    local player = GamePlayer.new(clientPeer)
    player:init()
    if GameMatch.startWait == false then
        GameMatch.startWait = true
        WaitingPlayerTask:start()
    end
    if PlayerManager:isPlayerFull() then
        WaitPlayerTask:stop()
    end
    return GameOverCode.Success, player
end

function PlayerListener.onPlayerLogout(player)
    GameMatch:onPlayerQuit(player)
end

function PlayerListener.onPlayerReady(player)
    player.isReady = true
    MsgSender.sendMsgToTarget(player.rakssid, IMessages:msgWelcomePlayer(Messages:gamename()));
    if GameMatch.isPrepareGame then
        player:teleTeleportPos()
        player:initInvItem()
    end
    HostApi.sendPlaySound(player.rakssid, 10021)
    return 43200
end

function PlayerListener.onPlayerHurt(hurtPlayer, hurtFrom, damageType, hurtValue)

    if GameMatch:isGameStart() == false then
        return false
    end

    if damageType == "outOfWorld" then
        return true
    end

    if damageType == "thrown" then
        hurtValue.value = hurtValue.value / 5.0
    else
        hurtValue.value = hurtValue.value / 3.0
    end

    return true
end

function PlayerListener.onPlayerDied(diePlayer, iskillByPlayer, killPlayer)

    local dier = PlayerManager:getPlayerByPlayerMP(diePlayer)

    if (dier ~= nil) then

        if GameMatch:isGameStart() == false then
            dier:overGame(true, false)
            return true
        end

        dier:onDie()

        GameMatch.curDeaths = GameMatch.curDeaths + 1
        local players = PlayerManager:getPlayers()
        for i, v in pairs(players) do
            v.kills = GameMatch.curDeaths
        end

        if killPlayer ~= nil then
            local killer = PlayerManager:getPlayerByPlayerMP(killPlayer)
            if killer ~= nil then
                killer:onKill()
            end
        end

        GameMatch:ifGameOver()
    end

    return true
end

function PlayerListener.onUseThrowableItem(itemId)
    if GameMatch:isGameStart() then
        return true
    end
    return false
end

return PlayerListener
--endregion
