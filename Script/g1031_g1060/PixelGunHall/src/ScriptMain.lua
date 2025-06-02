--GameMain
package.path = package.path ..';..\\?.lua';

require "Match"
require "config.Define"
require "base.BaseMain"
require "task.GameTimeTask"
require "task.WaitUpgradeQueue"
require "listener.GameListener"
require "listener.DBDataListener"
require "listener.PlayerListener"
require "listener.BlockListener"
require "listener.CustomListener"
require "listener.GunStoreListener"

ScriptMain = {}

function ScriptMain.init()
    HostApi.log("ScriptMain.init")
    GameListener:init()
    PlayerListener:init()
    DBDataListener:init()
    BlockListener:init()
    CustomListener:init()
    GunStoreListener:init()
    BaseMain:setGameType(GameMatch.gameType)
    HostApi.setNeedFoodStats(false)
    HostApi.setFoodHeal(false)
end

ScriptMain:init()