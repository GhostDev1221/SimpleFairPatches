require "base.util.vardump"
require "config.GameConfig"
require "web.RanchersWeb"
require "config.ShopConfig"
require "config.ManorConfig"
require "config.HardnessConfig"
require "config.SessionNpcConfig"
require "config.VehicleConfig"

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
    ShopConfig:prepareShop()
    ManorConfig:prepareGate()
    HardnessConfig:prepareBlockHardness()
    VehicleConfig:prepareVehicle()
    SessionNpcConfig:prepareNpc()
    RanchersWeb:init()
    HostApi.startDBService()
    HostApi.startRedisDBService()
    RanchersRankManager:updateRankData()
    RanchersWebResponse:registerCallBack(function(data, marked)
        if data ~= nil then
            RanchersRankManager:setClanData(data)
        end
    end, RanchersWeb:getClanProsperity())
    PlayerManager:setMaxPlayer(100)
end

return GameListener
--endregion
