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
    BaseListener.registerCallBack(PlayerRespawnEvent, self.onPlayerRespawn)

    PlayerMoveEvent.registerCallBack(self.onPlayerMove)
    PlayerDieEvent.registerCallBack(self.onPlayerDied)
    PlayerAttackedEvent.registerCallBack(self.onPlayerHurt)
    PlayerBuyRespawnResultEvent.registerCallBack(self.onBuyRespawnResult)
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
    MsgSender.sendMsgToTarget(player.rakssid, IMessages:msgWelcomePlayer(Messages:gamename()))
    return 43200
end

function PlayerListener.onPlayerMove(player, x, y, z)
    return GameMatch.allowMove
end

function PlayerListener.onPlayerHurt(hurtPlayer, hurtFrom, damageType, hurtValue)

    if (GameMatch.allowPvp == false) then
        return false
    end

    local hurter = PlayerManager:getPlayerByPlayerMP(hurtPlayer)
    if (hurter ~= nil) then
        local addHurt = hurter:getDefence()
        hurtValue.value = hurtValue.value - addHurt
    end

    if (hurtFrom == nil) then
        return true
    end

    local fromer = PlayerManager:getPlayerByPlayerMP(hurtFrom)
    if (fromer ~= nil) then
        local addHurt = fromer:getAttack()
        hurtValue.value = hurtValue.value + addHurt
    end

    return true
end

function PlayerListener.onPlayerDied(diePlayer, iskillByPlayer, killPlayer)

    local dier = PlayerManager:getPlayerByPlayerMP(diePlayer)

    if (iskillByPlayer and killPlayer ~= nil and dier ~= nil) then
        local killer = PlayerManager:getPlayerByPlayerMP(killPlayer)

        if (killer ~= nil) then
            MsgSender.sendMsg(IMessages:msgPlayerKillPlayer(dier.name, killer.name))

            if (GameMatch.firstKill == false) then
                GameMatch.firstKill = true
                MsgSender.sendMsg(IMessages:msgFirstKill(killer.name))
            end

            killer:onKill()
        end
    end

    if (dier ~= nil) then
        GameMatch:onPlayerDie(dier)
    end

    return true
end

function PlayerListener.onPlayerRespawn(player)
    player:teleRespawnInitPos()
    return 43200
end

function PlayerListener.onBuyRespawnResult(rakssid, code)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        GameMatch:ifGameOver()
        return
    end
    if code == 0 then
        player:onDie()
        GameMatch:ifGameOver()
    end
    if code == 1 then
        MsgSender.sendMsg(IMessages:msgRespawn(player:getDisplayName()))
    end
end

return PlayerListener
--endregion
