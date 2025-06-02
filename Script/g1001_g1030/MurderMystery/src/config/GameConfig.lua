--GameConfig.lua
require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "config.SceneConfig"

GameConfig = {}
GameConfig.isChina = false
GameConfig.RootPath = ""

GameConfig.prepareTime = 0
GameConfig.gameTime = 0
GameConfig.gameOverTime = 0
GameConfig.assignRoleTime = 0
GameConfig.resetTime = 0
GameConfig.startPlayers = 0

GameConfig.initPos = {}
GameConfig.teleportPos = {}

GameConfig.initItems = {}
GameConfig.sppItems = {}
GameConfig.clzItems = {}

GameConfig.coinMapping = {}

function GameConfig:init()

    local configPath = self.RootPath
    local config = self:getConfigFromFile(configPath)

    self.prepareTime = tonumber(config.prepareTime)
    self.gameTime = tonumber(config.gameTime)
    self.gameOverTime = tonumber(config.gameOverTime)
    self.resetTime = tonumber(config.resetTime)
    self.assignRoleTime = tonumber(config.assignRoleTime)
    self.startPlayers = tonumber(config.startPlayers)

    self:initCoinMapping(config.coinMapping)

    GameConfig.initPos = VectorUtil.newVector3i(config.initPos[1], config.initPos[2], config.initPos[3])

    for i, v in pairs(config.scenes) do
        local scenePath = string.gsub(configPath, "config.yml", v.path)
        local sceneConfig = self:getConfigFromFile(scenePath)
        SceneConfig:addScene(sceneConfig)
    end

end

function GameConfig:initCoinMapping(coinMapping)
    for i, v in pairs(coinMapping) do
        self.coinMapping[i] = {}
        self.coinMapping[i].coinId = v.coinId
        self.coinMapping[i].itemId = v.itemId
    end
end

function GameConfig:getConfigFromFile(path)
    local file = io.open(path, "r")
    local fileStream = file.read(file, "*a")
    return TinyParse(fileStream)
end

return GameConfig