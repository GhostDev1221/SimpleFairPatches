---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:16
---

require "base.util.tinyyaml"
require "base.util.VectorUtil"

GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}

GameConfig.prepareTime = 0
GameConfig.gameTime = 0
GameConfig.gameOverTime = 0

GameConfig.startPlayers = 0

function GameConfig:init()

    local configPath = self.RootPath

    local config = self:getConfigFromFile(configPath)
    GameConfig.initPos = VectorUtil.newVector3(config.initPos[1], config.initPos[2], config.initPos[3])

    self.prepareTime = tonumber(config.prepareTime or "10")
    self.gameTime = tonumber(config.gameTime or "60")
    self.gameOverTime = tonumber(config.gameOverTime or "10")

    self.startPlayers = tonumber(config.startPlayers or "1")

end

function GameConfig:getConfigFromFile(path)
    local file = io.open(path, "r")
    local fileStream = file.read(file, "*a")
    return TinyParse(fileStream)
end

return GameConfig