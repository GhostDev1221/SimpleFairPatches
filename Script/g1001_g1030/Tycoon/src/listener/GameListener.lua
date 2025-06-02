--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.vardump"
require "base.messages.IMessages"
require "data.GameRank"
local GameRank = require "data.GameRank"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, self.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    HostApi.startDBService()
    HostApi.startRedisDBService()
    HostApi.setMaxInventorySize(9)
    HostApi.setBreakBlockSoon(false)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    ShopConfig:prepareShop()
    GameRank:init()
    GameMatch:init()
    MerchantConfig:prepareMerchant()
    initPos.x = GameConfig.initPos.x
    initPos.y = GameConfig.initPos.y
    initPos.z = GameConfig.initPos.z
    EngineWorld:stopWorldTime()
end

return GameListener
--endregion
