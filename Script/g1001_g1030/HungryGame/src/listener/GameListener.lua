--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.InventoryUtil"
require "base.util.VectorUtil"
require "base.util.vardump"
require "base.messages.IMessages"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, self.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    initPos.x = GameConfig.initPos[1].x
    initPos.y = GameConfig.initPos[1].y
    EngineWorld:stopWorldTime()
    InventoryUtil:prepareChest(GameConfig.inventory[1].pos)
    RespawnConfig:prepareRespawnGoods()
end

return GameListener
--endregion
