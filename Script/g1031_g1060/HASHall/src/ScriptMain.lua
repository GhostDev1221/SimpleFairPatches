--GameMain
package.path = package.path ..';..\\?.lua';

require "Match"
require "base.BaseMain"
require "task.GameTimeTask"
require "listener.GameListener"
require "listener.PlayerListener"
require "listener.BlockListener"
require "listener.CustomListener"
require "listener.DBDataListener"
require "listener.RankListener"

ScriptMain = {}

function ScriptMain.init()
    HostApi.log("ScriptMain.init")
    GameListener:init()
    PlayerListener:init()
    BlockListener:init()
    CustomListener:init()
    DBDataListener:init()
    RankListener:init()
    BaseMain:setGameType(GameMatch.gameType)
    HostApi.setNeedFoodStats(false)
end

ScriptMain:init()