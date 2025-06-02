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

    PlayerMoveEvent.registerCallBack(self.onPlayerMove)
    PlayerDieEvent.registerCallBack(self.onPlayerDied)
    PlayerAttackedEvent.registerCallBack(self.onPlayerHurt)
    PlayerChangeItemInHandEvent.registerCallBack(self.onChangeItemInHandEvent)
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
    HostApi.sendPlaySound(player.rakssid, 10012)
    MsgSender.sendMsgToTarget(player.rakssid, IMessages:msgWelcomePlayer(Messages:gamename()))
    if player.staticAttr.supperPlayer == 2 then
        player:addMoveSpeedPotionEffect(43200)
    end
    return 43200
end

function PlayerListener.onPlayerMove(player, x, y, z)
    if x == 0 and y == 0 and z == 0 then
        return true
    end
    local p = PlayerManager:getPlayerByPlayerMP(player)
    if p ~= nil then
        p.positionX = x
        p.positionY = y
        p.positionZ = z
        p.lastMoveTime = tonumber(HostApi.curTimeString())
        if GameMatch:isGameStart() then
            p:addRemoveBlock(x, y, z)
            p:removeFootBlock()
            GameMatch:removeFootBlock()
        end
    end
    return true
end

function PlayerListener.onPlayerHurt(hurtPlayer, hurtFrom, damageType, hurtValue)
    if damageType == "outOfWorld" then
        return true
    end
    hurtValue.value = 0
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
        GameMatch:ifGameOver()
    end

    return true
end

function PlayerListener.onChangeItemInHandEvent(rakssid, itemId, itemMeta)
    if itemId ~= 159 then
        return
    end
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player ~= nil then
        if tonumber(HostApi.curTimeString()) - player.loginTime > 2 * 1000 then
            if player.staticAttr.supperPlayer > 0 then
                if itemMeta == 0 then
                    player:becomeRole(GamePlayer.ROLE_RUNNING_MAN)
                end
                if itemMeta == 1 then
                    player:becomeRole(GamePlayer.ROLE_DESTROYER)
                    GameMatch.hasDestory = true
                end
            end
        end
    end
end

return PlayerListener
--endregion
