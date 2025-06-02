--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.vardump"
require "config.GameConfig"
require "config.ShopConfig"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, GameListener.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    ShopConfig:prepareShop()
    GameMatch:initMatch()
    initPos.x = GameConfig.initPos.x
    initPos.y = GameConfig.initPos.y
    initPos.z = GameConfig.initPos.z
    EngineWorld:stopWorldTime()
    HostApi.startDBService()
end

return GameListener
--endregion
