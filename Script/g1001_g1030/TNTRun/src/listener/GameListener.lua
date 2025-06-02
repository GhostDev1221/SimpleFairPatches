--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.InventoryUtil"
require "base.util.vardump"
require "base.messages.IMessages"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, GameListener.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    initPos.x = GameConfig.initPos.x
    initPos.y = GameConfig.initPos.y
    initPos.z = GameConfig.initPos.z
    EngineWorld:stopWorldTime()
end

return GameListener
--endregion
