package.path = package.path ..';..\\?.lua';

require "base.BaseMain"
require "config.GameConfig"

local define = require "define"
local listener = require "listener"

listener:init()

BaseMain:setGameType(define.gameType)
HostApi.setNeedFoodStats(false)
ReportManager:setRankType(ReportManager.RankType.Max)
