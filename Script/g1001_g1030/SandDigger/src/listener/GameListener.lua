--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.vardump"
require "base.util.WalletUtils"
require "messages.Messages"
require "config.GameConfig"
require "config.BlockConfig"
require "config.ChestConfig"
require "config.ToolConfig"
require "config.ShopConfig"
require "config.NpcConfig"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, GameListener.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    BlockConfig:prepareBlock()
    ToolConfig:prepareTool()
    GameMatch:initMatch()
    initPos.x = GameConfig.initPos.x
    initPos.y = GameConfig.initPos.y
    initPos.z = GameConfig.initPos.z
    EngineWorld:stopWorldTime()
    ChestConfig:prepareChest()
    ShopConfig:prepareShop()
    NpcConfig:prepareRankNpc()
    WalletUtils:addCoinMappings(MerchantConfig.coinMapping)
    HostApi.startDBService()
    HostApi.startRedisDBService()
    GameMatch:setZExpireat()
    GameMatch:getRankTop10Players()
end

return GameListener
--endregion
