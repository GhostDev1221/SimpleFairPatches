--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.messages.IMessages"
require "base.util.MsgSender"
require "base.util.VectorUtil"
require "base.code.GameOverCode"
require "messages.Messages"
require "data.GamePlayer"
require "Match"

PlayerListener = {}

function PlayerListener:init()

    BaseListener.registerCallBack(PlayerLoginEvent,self.onPlayerLogin)
    BaseListener.registerCallBack(PlayerLogoutEvent,self.onPlayerLogout)
    BaseListener.registerCallBack(PlayerReadyEvent,self.PlayerReadyEvent)
   
    PlayerDieEvent.registerCallBack(self.onPlayerDied)
    PlayerAttackedEvent.registerCallBack(self.onPlayerHurt)
end

function PlayerListener.onPlayerLogin(clientPeer)
    if GameMatch.hasStartGame then
        return GameOverCode.GameStarted
    end
    local player = GamePlayer.new(clientPeer)
    player:init()
    return GameOverCode.Success, player, 1
end

function PlayerListener.onPlayerLogout(player)
    GameMatch:onPlayerQuit(player)
end

function PlayerListener.onPlayerReady(player)
    return 43200
end

function PlayerListener.onPlayerHurt(hurtPlayer, hurtFrom, damageType, hurtValue)
    return false
end

function PlayerListener.onPlayerDied(diePlayer, iskillByPlayer, killPlayer)
    return true
end

return PlayerListener
--endregion
