--GameMain
package.path = package.path ..';..\\?.lua';

require "Match"
require "base.BaseMain"
require "task.GameTimeTask"
require "listener.GameListener"
require "listener.PlayerListener"
require "listener.BlockListener"
require "listener.DBDataListener"
require "listener.LogicListener"

ScriptMain = {}

function ScriptMain.init()
    HostApi.log("ScriptMain.init")
    GameListener:init()
    PlayerListener:init()
    BlockListener:init()
    DBDataListener:init()
    LogicListener:init()
    HostApi.setNeedFoodStats(false)
    HostApi.setFoodHeal(false)
    HostApi.setAllowHeadshot(true)
end

ScriptMain:init()