--GameMain
package.path = package.path ..';..\\?.lua';

require "Match"
require "base.BaseMain"
require "config.GameConfig"
require "listener.GameListener"
require "listener.PlayerListener"
require "listener.BlockListener"

require "task.WaitingPlayerTask"
require "task.GamePrepareTask"
require "task.GameTimeTask"
require "task.GameOverTask"

ScriptMain = {}

function ScriptMain.init()
    HostApi.log("ScriptMain.init")
    GameListener:init()
    PlayerListener:init()
    BlockListener:init()
    BaseMain:setGameType(GameMatch.gameType)
end

ScriptMain:init()
