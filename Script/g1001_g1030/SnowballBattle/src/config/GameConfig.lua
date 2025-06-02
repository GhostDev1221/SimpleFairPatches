--GameConfig.lua
require "base.util.tinyyaml"
require "config.TeamConfig"
require "config.ScoreConfig"
require "config.SnowballSpeed"

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
GameConfig.TNTPrice = {}

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
    for k, v in pairs(tinyObj.obstacle) do
        self.obstacle[k] = {}
        self.obstacle[k].id = tonumber(v.id)
        self.obstacle[k].hp = tonumber(v.hp)
    end

    self.TNTPrice.coinId = tonumber(tinyObj.TNTPrice[1])
    self.TNTPrice.blockymodsPrice = tonumber(tinyObj.TNTPrice[2])
    self.TNTPrice.blockmanPrice = tonumber(tinyObj.TNTPrice[3])

    self.pickupDuration = tonumber(tinyObj.pickupDuration)

    TeamConfig:init(tinyObj.teams)
    ScoreConfig:init(tinyObj.scores, tinyObj.winScore)
    SnowballSpeed:init(tinyObj.snowballSpeed)
end

return GameConfig