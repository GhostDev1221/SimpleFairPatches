--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.vardump"
require "base.util.WalletUtils"
require "messages.Messages"
require "config.GameConfig"
require "config.ShopConfig"
require "config.WeaponConfig"
require "config.ChestConfig"
require "config.MerchantConfig"
require "config.VehicleConfig"
require "config.StrongboxConfig"
require "config.RankNpcConfig"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, GameListener.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    WeaponConfig:prepareWeapon()
    ShopConfig:prepareShop()
    ChestConfig:prepareChest()
    BlockConfig:prepareAutoChangeBlock()
    VehicleConfig:prepareVehicle()
    DoorConfig:prepareDoor()
    StrongboxConfig:prepareStrongbox()
    WalletUtils:addCoinMappings(MerchantConfig.coinMapping)
    RankNpcConfig:prepareRankNpc()
    GameMatch:initMatch()
    initPos.x = GameConfig.initPos.x
    initPos.y = GameConfig.initPos.y
    initPos.z = GameConfig.initPos.z
    EngineWorld:stopWorldTime()
    HostApi.startDBService()
    HostApi.startRedisDBService()
end

return GameListener
--endregion
