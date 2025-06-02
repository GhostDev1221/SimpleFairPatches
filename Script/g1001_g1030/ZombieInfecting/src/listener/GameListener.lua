--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.InventoryUtil"
require "config.GameConfig"
require "config.ShopConfig"
require "config.InventoryConfig"
require "config.WeaponConfig"
require "messages.Messages"
require "base.util.vardump"


GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, self.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    ShopConfig:prepareShop()
    WeaponConfig:prepareWeapon()
    GameMatch:initMatch()
    initPos.x = GameConfig.initPos.x
    initPos.y = GameConfig.initPos.y
    initPos.z = GameConfig.initPos.z
    EngineWorld:stopWorldTime()
    InventoryUtil:prepareChest(GameMatch:getCurGameScene().inventoryConfig.pos)
end

return GameListener
--endregion
