--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.vardump"
require "config.GameConfig"
require "config.RankNpcConfig"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, GameListener.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    RespawnConfig:prepareRespawnGoods()
    ShopConfig:prepareShop()
    GameMatch:initMatch()
    initPos.x = GameConfig.initPos.x
    initPos.y = GameConfig.initPos.y
    initPos.z = GameConfig.initPos.z
    EngineWorld:stopWorldTime()
    HostApi.startRedisDBService()
    HostApi.startDBService()
    RankNpcConfig:setZExpireat()
    RankNpcConfig:updateRank()
end

return GameListener
--endregion
