--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.vardump"
require "config.GameConfig"
require "base.util.WalletUtils"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent,self.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    GameMatch:initMatch()
    initPos.x = GameConfig.initPos.x
    initPos.y = GameConfig.initPos.y
    initPos.z = GameConfig.initPos.z
    HostApi.startDBService()
    HostApi.startRedisDBService()
    RankNpcConfig:updateRank()
    EngineWorld:stopWorldTime()
    ShopConfig:prepareShop()
    PlayerManager:setMaxPlayer(100)
end

return GameListener
--endregion
