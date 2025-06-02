--GameConfig.lua
require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "config.SceneConfig"
require "config.ShopConfig"
require "config.WeaponConfig"
require "config.HunterConfig"

GameConfig = {}
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
    self.gameOverTime = tonumber(config.gameOverTime)
    self.resetTime = tonumber(config.resetTime)
    self.assignRoleTime = tonumber(config.assignRoleTime)
    self.startPlayers = tonumber(config.startPlayers)
    --self.maxPlayers = tonumber(config.maxPlayers)

    GameConfig.initPos = VectorUtil.newVector3i(config.initPos[1], config.initPos[2], config.initPos[3])

    for i, v in pairs(config.scenes) do
        local scenePath = string.gsub(configPath, "config.yml", v.path)
        local sceneConfig = self:getConfigFromFile(scenePath)
        SceneConfig:addScene(sceneConfig)
    end

    ShopConfig:init(config.shop)
    WeaponConfig:init(config.weapon)
    HunterConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "hunter")))
end

function GameConfig:getConfigFromFile(path)
    local file = io.open(path, "r")
    local fileStream = file.read(file, "*a")
    return TinyParse(fileStream)
end

return GameConfig