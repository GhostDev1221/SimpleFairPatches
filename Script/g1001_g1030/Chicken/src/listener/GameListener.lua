--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.vardump"
require "base.util.WalletUtils"
require "messages.Messages"
require "config.GameConfig"
require "config.AirplaneConfig"
require "config.ChestConfig"
require "config.WeaponConfig"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, GameListener.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    GameMatch:initMatch()
    WeaponConfig:prepareWeapon()
    initPos.x = GameConfig.initPos.x
    initPos.y = GameConfig.initPos.y
    initPos.z = GameConfig.initPos.z
    EngineWorld:stopWorldTime()
    HostApi.setMedicineHealAmount(PotionItemID.POTION_MEDICINE_PACK, GameConfig.medicinePack)
    HostApi.setMedicineHealAmount(PotionItemID.POTION_MEDICINE_POTION, GameConfig.medicinePotion)
end

return GameListener
--endregion
