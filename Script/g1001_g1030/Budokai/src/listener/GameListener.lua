--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

require "base.util.vardump"
require "base.util.WalletUtils"
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
    WalletUtils:addCoinMappings(GameConfig.coinMapping)
    ShopConfig:prepareShop()
    GameMatch:initMatch()
    initPos.x = GameConfig.initPos.x
    initPos.y = GameConfig.initPos.y
    initPos.z = GameConfig.initPos.z
    EngineWorld:stopWorldTime()
    HostApi.startDBService()
    HostApi.startRedisDBService()
    RankNpcConfig:setZExpireat()
    RankNpcConfig:updateRank()
end

return GameListener
--endregion
