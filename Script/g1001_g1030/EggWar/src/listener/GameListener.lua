--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.vardump"
require "base.util.WalletUtils"
require "base.messages.IMessages"
require "config.MoneyConfig"
require "config.TeamConfig"
require "config.BlockConfig"
require "config.MerchantConfig"
require "config.EnchantMentNpcConfig"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, GameListener.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    ShopConfig:prepareShop()
    initPos.x = TeamConfig:getTeam(1).initPos.x
    initPos.y = TeamConfig:getTeam(1).initPos.y
    initPos.z = TeamConfig:getTeam(1).initPos.z
    EngineWorld:stopWorldTime()
    WalletUtils:addCoinMappings(MoneyConfig.coinMapping)
    RespawnConfig:prepareRespawnGoods()
    MoneyConfig:prepareNpc()
    TeamConfig:prepareEgg()
    MerchantConfig:prepareShopTruck()
    BlockConfig:prepareBlock()
    EnchantMentNpcConfig:prepareNpc()
end

return GameListener
--endregion
