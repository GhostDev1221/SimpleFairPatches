--GameMain
package.path = package.path ..';..\\?.lua'

require "Match"
require "base.BaseMain"
require "task.GameTimeTask"
require "config.GameConfig"
require "listener.GameListener"
require "listener.PlayerListener"
require "listener.BlockListener"
require "listener.RankListener"
require "listener.LogicListener"

ScriptMain = {}

function ScriptMain.init()
    HostApi.log("ScriptMain.init")
    GameListener:init()
    PlayerListener:init()
    BlockListener:init()
    RankListener:init()
    LogicListener:init()
    BaseMain:setGameType(GameMatch.gameType)
    HostApi.setBreakBlockSoon(false)
    HostApi.setCanDamageItem(false)
    HostApi.setNeedFoodStats(false);
    HostApi.setDisableSelectEntity(true)
end

ScriptMain:init()