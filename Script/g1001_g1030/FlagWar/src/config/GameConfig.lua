---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:16
---

require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "base.util.CsvUtil"
require "config.SceneConfig"
require "config.MoneyConfig"
require "config.CommodityConfig"
require "config.InventoryConfig"
require "config.OccupationConfig"
require "config.RespawnConfig"
require "config.PotionEffectConfig"
require "config.ArmsConfig"
require "config.FashionStoreConfig"
require "config.ShopConfig"
require "config.SkillEffectConfig"
require "config.SkillConfig"

GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}
GameConfig.selectRolePos = {}

GameConfig.waitingTime = 0
GameConfig.prepareTime = 0
GameConfig.selectRoleTime = 0
GameConfig.gameTime = 0
GameConfig.gameOverTime = 0

GameConfig.startPlayers = 0

function GameConfig:init()

    local configPath = self.RootPath

    local config = self:getConfigFromFile(configPath)
    GameConfig.initPos = VectorUtil.newVector3i(config.initPos[1], config.initPos[2], config.initPos[3])
    GameConfig.selectRolePos = VectorUtil.newVector3i(config.selectRolePos[1], config.selectRolePos[2], config.selectRolePos[3])

    self.waitingTime = tonumber(config.waitingTime or "30")
    self.prepareTime = tonumber(config.prepareTime or "30")
    self.selectRoleTime = tonumber(config.selectRoleTime or "30")
    self.gameTime = tonumber(config.gameTime or "1200")
    self.gameOverTime = tonumber(config.gameOverTime or "30")

    self.startPlayers = tonumber(config.startPlayers or "1")

    for i, scene in pairs(config.scenes) do
        SceneConfig:addScene(self:getConfigFromFile(string.gsub(configPath, "config.yml", scene.path)))
    end

    MoneyConfig:initCoinMapping(config.coinMapping)
    RespawnConfig:init(config.respawn)
    ShopConfig:init(config.shop)
    MoneyConfig:initMoneys(self:getConfigFromFile(string.gsub(configPath, "config.yml", "money.yml")))
    CommodityConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Commodity.csv")))
    InventoryConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Inventory.csv")))
    OccupationConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Occupation.csv")))
    PotionEffectConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "PotionEffect.csv")))
    ArmsConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Arms.csv")))
    FashionStoreConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "FashionStore.csv")))
    SkillEffectConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "SkillEffect.csv")))
    SkillConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Skill.csv")))

end

function GameConfig:getConfigFromFile(path)
    local file = io.open(path, "r")
    local fileStream = file.read(file, "*a")
    return TinyParse(fileStream)
end

function GameConfig:getCsvConfig(path)
    return CsvUtil.loadCsvFile(path, 2)
end

return GameConfig