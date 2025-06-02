---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:16
---

require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "base.util.CsvUtil"
require "config.GunsConfig"
require "config.TeamConfig"
require "config.GunMerchantConfig"
require "config.KillRewardConfig"
require "config.RespawnConfig"
require "config.PropGroupConfig"
require "config.ItemsConfig"
require "config.PropsConfig"
require "config.ItemSettingConfig"
require "config.InitItemsConfig"
require "config.ShopConfig"
require "config.SpecialClothingConfig"
require "config.BulletConfig"

GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}
GameConfig.initPlayerHealth = ""

GameConfig.prepareTime = 0
GameConfig.gameTime = 0
GameConfig.gameOverTime = 0

GameConfig.startPlayers = 0
GameConfig.teamMaxPlayers = 0
GameConfig.redTeamActor = ""
GameConfig.blueTeamActor = ""
GameConfig.winKill = 0
GameConfig.standByTime = 0
GameConfig.unableMoveTick = 0
GameConfig.showShopTick = 0
GameConfig.showRankTick = 0
GameConfig.itemLifeTime = 0

function GameConfig:init()

    local configPath = self.RootPath

    local config = self:getConfigFromFile(configPath)
    GameConfig.initPos = VectorUtil.newVector3(config.initPos[1], config.initPos[2], config.initPos[3])
    self.initPlayerHealth = config.initPlayerHealth or "20"

    self.prepareTime = tonumber(config.prepareTime or "10")
    self.gameTime = tonumber(config.gameTime or "60")
    self.gameOverTime = tonumber(config.gameOverTime or "10")

    RankNpcConfig:init(config.rankNpc)
    ShopConfig:init(config.shop)
    BulletConfig:init(config.bullet)

    self.standByTime = tonumber(config.standByTime or "100")
    self.startPlayers = tonumber(config.startPlayers or "1")
    self.teamMaxPlayers = tonumber(config.teamMaxPlayers or "1")
    self.redTeamActor = config.redTeamActor or ""
    self.blueTeamActor = config.blueTeamActor or ""
    self.winKill = tonumber(config.winKill or "10")
    self.unableMoveTick = tonumber(config.unableMoveTick or "1")
    self.showShopTick = tonumber(config.showShopTick or "1")
    self.showRankTick = tonumber(config.showRankTick or "1")
    self.itemLifeTime = tonumber(config.itemLifeTime or "1")

    GunsConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Guns.csv")))
    TeamConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Team.csv")))
    GunMerchantConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "GunMerchant.csv")))
    KillRewardConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "KillReward.csv")))
    RespawnConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Respawn.csv")))
    ItemsConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Items.csv")))
    PropsConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Props.csv")))
    PropGroupConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "PropGroup.csv")))
    ItemSettingConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "ItemSetting.csv")))
    InitItemsConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "InitItems.csv")))
    SpecialClothingConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "SpecialClothing.csv")))
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