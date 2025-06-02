--GameConfig.lua
require "base.util.tinyyaml"
require "config.TeamConfig"
require "config.ScoreConfig"
require "config.SnowballSpeed"
require "config.Area"

GameConfig = {}
GameConfig.isChina = false
GameConfig.RootPath = ""

GameConfig.waitingPlayerTime = 0
GameConfig.prepareTime = 0
GameConfig.gameTime = 0
GameConfig.gameOverTime = 0

GameConfig.sppItems = {}
GameConfig.clzItems = {}

GameConfig.enableBreak = false
GameConfig.obstacle = {}

GameConfig.changeSnowIds = {}
GameConfig.noSnowIds = {}

GameConfig.winCondition = 0

function GameConfig:init()
    local configPath = self.RootPath
    local file = io.open(configPath, "r")
    local fileStream = file.read(file, "*a")
    local tinyObj = TinyParse(fileStream)

    self.waitingPlayerTime = tonumber(tinyObj.waitingPlayerTime)
    self.prepareTime = tonumber(tinyObj.prepareTime)
    self.gameTime = tonumber(tinyObj.gameTime)
    self.gameOverTime = tonumber(tinyObj.gameOverTime)

    self.enableBreak = tinyObj.enableBreak

    for i, v in pairs(tinyObj.changeSnowIds) do
        self.changeSnowIds[tonumber(v)] = true
    end
    for i, v in pairs(tinyObj.noSnowIds) do
        self.noSnowIds[tonumber(v)] = true
    end

    self.winCondition = tinyObj.winCondition

    TeamConfig:init(tinyObj.teams)
    ScoreConfig:init(tinyObj.scores, tinyObj.winScore)
    SnowballSpeed:init(tinyObj.snowballSpeed)
end

return GameConfig