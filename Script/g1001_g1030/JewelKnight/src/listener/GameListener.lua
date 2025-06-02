require "base.web.WebService"
require "base.util.vardump"
require "config.GameConfig"
require "config.ShopConfig"
require "config.ToolConfig"
require "config.SessionNpcConfig"
require "config.RankNpcConfig"
require "config.MerchantConfig"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, self.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    GameMatch:initMatch()
    initPos.x = GameConfig.initPos.x
    initPos.y = GameConfig.initPos.y
    initPos.z = GameConfig.initPos.z
    EngineWorld:stopWorldTime()
    ShopConfig:prepareShop()
    BlockConfig:prepareBlock()
    BlockConfig:prepareMine()
    ToolConfig:prepareTool()
    SessionNpcConfig:prepareNpc()
    MerchantConfig:prepareMerchant()
    MerchantConfig:prepareUpgradeMerchants()
    HostApi.startRedisDBService()
    RankNpcConfig:setZExpireat()
    RankNpcConfig:updateRank()
end

return GameListener
--endregion
