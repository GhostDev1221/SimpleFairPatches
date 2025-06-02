--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.vardump"
require "base.util.WalletUtils"
require "config.GameConfig"
require "config.ManorNpcConfig"
require "config.ShopConfig"
require "config.FurnitureConfig"
require "config.VehicleConfig"
require "config.BlockConfig"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, GameListener.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    GameMatch:initMatch()
    initPos.x = GameConfig.initPos.x
    initPos.y = GameConfig.initPos.y
    initPos.z = GameConfig.initPos.z
    EngineWorld:stopWorldTime()
    WalletUtils:addCoinMappings(MerchantConfig.coinMapping)
    ManorNpcConfig:prepareManorNpc()
    ManorNpcConfig:prepareSessionNpc()
    ManorNpcConfig:prepareRankNpc()
    ShopConfig:prepareShop()
    FurnitureConfig:prepareFurnitureShow()
    VehicleConfig:prepareVehicle()
    BlockConfig:prepareBlockHardness()
    HostApi.loadManorConfig()
    HostApi.loadManorCharmRank(30)
    HostApi.loadManorPotentialRank(30)
    PlayerManager:setMaxPlayer(100)
end

return GameListener
--endregion
