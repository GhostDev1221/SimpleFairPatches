--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

require "base.util.vardump"
require "config.GameConfig"
require "config.RankNpcConfig"
require "config.ShopConfig"
require "config.MerchantConfig"
require "base.util.WalletUtils"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, self.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    GameMatch:initMatch()
    ShopConfig:prepareShop()
    WalletUtils:addCoinMappings(MerchantConfig.coinMapping)
    GameConfig:prepareBlockHardness()
    initPos.x = GameConfig.initPos.x
    initPos.y = GameConfig.initPos.y
    initPos.z = GameConfig.initPos.z
    EngineWorld:stopWorldTime()
end

return GameListener
--endregion
