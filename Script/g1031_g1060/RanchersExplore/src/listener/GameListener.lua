--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

require "base.util.vardump"
require "config.GameConfig"
require "config.ShopConfig"
require "base.util.WalletUtils"
require "config.MerchantConfig"
require "config.ToolConfig"
require "config.TaskConfig"
require "config.SessionNpcConfig"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, self.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    GameMatch:initMatch()
    ToolConfig:prepareTool()
    TaskConfig:prepareTask()
    ShopConfig:prepareShop()
    WalletUtils:addCoinMappings(MerchantConfig.coinMapping)
    GameConfig:prepareBlockHardness()
    initPos.x = GameConfig.initPos.x
    initPos.y = GameConfig.initPos.y
    initPos.z = GameConfig.initPos.z
    EngineWorld:stopWorldTime()
    SessionNpcConfig:prepareNpc()
    HostApi.startDBServiceByGameType("g1031")
end

return GameListener
--endregion
