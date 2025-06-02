--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.vardump"
require "base.messages.IMessages"
require "web.ClanWarWeb"
require "config.TeamConfig"
require "messages.Messages"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, GameListener.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    GameMatch:initMatch()
    initPos.x = GameMatch.Teams[1].initPos.x
    initPos.y = GameMatch.Teams[1].initPos.y
    initPos.z = GameMatch.Teams[1].initPos.z
    EngineWorld:stopWorldTime()
    ClanWarWeb:init(ver, config.rankAddr, config.rewardAddr, config.propAddr, config.gameId)
end

return GameListener
--endregion
