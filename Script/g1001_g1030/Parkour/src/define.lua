require "base.util.DateUtil"

local define = {}


define.gameType = "g1021"

define.MATCH_STAGE_NONE     = 0     -- 初始状态
define.MATCH_STAGE_WAIT     = 1     -- 等待玩家
define.MATCH_STAGE_READY    = 2     -- 准备阶段
define.MATCH_STAGE_START    = 3     -- 比赛期间
define.MATCH_STAGE_CLOSE    = 4     -- 比赛结束

define.RANK_WEEK_FLAG       = string.format("%s.week", define.gameType)
define.RANK_HIST_FLAG       = string.format("%s.hist", define.gameType)

define.PLAYER_DB_CHUNK_DEFAULT = 1

return define
