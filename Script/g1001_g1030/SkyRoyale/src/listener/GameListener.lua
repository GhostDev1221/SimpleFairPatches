--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.vardump"
require "config.GameConfig"
require "config.RespawnConfig"
require "config.ChestConfig"
require "config.ShopConfig"
require "config.BlockConfig"
require "config.NewIslandConfig"
require "config.TeamConfig"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, self.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    GameMatch:initMatch()
    initPos.x = TeamConfig:getTeam(1).initPosX
    initPos.y = TeamConfig:getTeam(1).initPosY
    initPos.z = TeamConfig:getTeam(1).initPosZ
    EngineWorld:stopWorldTime()
    RespawnConfig:prepareRespawnGoods()
    ChestConfig:prepareChest()
    ShopConfig:prepareShop()
    BlockConfig:prepareBlockHardness()
    NewIslandConfig:generateIslandWall()
    if GameConfig.isKeepInventory == 1 then
        HostApi.setEntityItemLife(GameConfig.entityItemLifeTime * 20)
    end
    HostApi.startDBService()
end

return GameListener
--endregion
