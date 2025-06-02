require "base.util.vardump"
require "config.GameConfig"

GameListener = {}

function GameListener:init()
    BaseListener.registerCallBack(GameInitEvent, GameListener.onGameInit)
end

function GameListener.onGameInit(GamePath, initPos)
    GameConfig.RootPath = GamePath
    GameConfig:init()
    GameMatch:initMatch()
    initPos.x = GameConfig.initPos.x
    initPos.y = GameConfig.initPos.y
    initPos.z = GameConfig.initPos.z
    EngineWorld:stopWorldTime()
    PlayerManager:setMaxPlayer(100)
    HostApi.startDBService()
    MonsterConfig:prepareMonster()
    ActorNpcConfig:prepareNpc()
    FieldConfig:prepareDoorActor()
end

return GameListener
--endregion
