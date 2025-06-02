--GameMain
package.path = package.path ..';..\\?.lua';

require "Match"
require "base.BaseMain"
require "task.GameTimeTask"
require "listener.GameListener"
require "listener.PlayerListener"
require "listener.BlockListener"
require "listener.LogicListener"
require "listener.ChestListener"
require "listener.DBDataListener"

ScriptMain = {}

function ScriptMain.init()
    HostApi.log("ScriptMain.init")
    GameListener:init()
    PlayerListener:init()
    BlockListener:init()
    LogicListener:init()
    ChestListener:init()
    DBDataListener:init()
    BaseMain:setGameType(GameMatch.gameType)
    HostApi.setNeedFoodStats(false)
    HostApi.setHideClouds(true)
    HostApi.setSneakShowName(true)
    HostApi.setFoodHeal(false)
    HostApi.setCanCloseChest(false)
end

ScriptMain:init()