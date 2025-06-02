--GameMain
package.path = package.path ..';..\\?.lua';

require "Match"
require "base.BaseMain"
require "task.GameTimeTask"
require "listener.GameListener"
require "listener.PlayerListener"
require "listener.BlockListener"
require "listener.GameHttpListener"
require "listener.LogicListener"
require "listener.DBDataListener"
require "listener.CustomListener"
require "listener.RankListener"

ScriptMain = {}

function ScriptMain.init()
    HostApi.log("ScriptMain.init")
    GameListener:init()
    PlayerListener:init()
    BlockListener:init()
    GameHttpListener:init()
    LogicListener:init()
    DBDataListener:init()
    CustomListener:init()
    RankListener:init()
    BaseMain:setGameType(GameMatch.gameType)
    HostApi.setCanDamageItem(false)
    HostApi.setNeedFoodStats(false)
end

ScriptMain:init()