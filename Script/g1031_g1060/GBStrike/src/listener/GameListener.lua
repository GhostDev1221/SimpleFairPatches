--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.vardump"
require "config.GameConfig"
require "config.ShopConfig"
require "config.RankNpcConfig"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, self.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    GameMatch:initMatch()
    ShopConfig:prepareShop()
    initPos.x = GameConfig.initPos.x
    initPos.y = GameConfig.initPos.y
    initPos.z = GameConfig.initPos.z
    EngineWorld:stopWorldTime()
    HostApi.startDBServiceByGameType("g1032")
    HostApi.startRedisDBService()
    HostApi.setRedisDBHost(1)
    RankNpcConfig:setZExpireat()
    RankNpcConfig:updateRank()
    HostApi.setEntityItemLife(GameConfig.itemLifeTime * 20)
    PlayerManager:setMaxPlayer(100)
end

return GameListener
--endregion
