---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:16
---

require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "config.RespawnConfig"
require "config.SiteConfig"
require "base.util.CsvUtil"
require "config.TeamConfig"
require "config.GunConfig"
require "config.SupplyConfig"
require "config.ExtraAwardConfig"
require "config.ChestConfig"
require "config.PropConfig"
require "config.FirstAwardCheck"
require "config.SkillConfig"
require "config.AwardConfig"
require "config.ExpConfig"
require "config.SupplyItemConfig"
require "config.PropertyConfig"
require "config.HonorExponentConfig"

GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}
GameConfig.standByTime = 0
GameConfig.startPlayers = 0

function GameConfig:init()
    local configPath = self.RootPath

    local config = self:getConfigFromFile(configPath)
    GameMatch.gameType = config.gameType or "g1000"
    self.maxSupplyNum = tonumber(config.maxSupplyNum) or 5
    self.waitRespawnTime = tonumber(config.waitRespawnTime) or 5
    self.invincibleTime = tonumber(config.invincibleTime) or 10
    self.standByTime = tonumber(config.standByTime) or 30
    self.startPlayers = tonumber(config.startPlayers) or 6
    self.prepareTime = tonumber(config.prepareTime) or 20
    self.gameTime = tonumber(config.gameTime) or 200
    self.gameOverTime = tonumber(config.gameOverTime) or 20
    self.extraTime = tonumber(config.extraTime) or 10
    self.showRankTick = tonumber(config.showRankTick) or 10
    self.maxPlayers = tonumber(config.maxPlayers) or 12
    self.autoRespawnTime = tonumber(config.autoRespawnTime) or 10
    self.deathLineY = tonumber(config.deathLineY) or -256
    self.quitSubHonor = tonumber(config.quitSubHonor) or -10
    self.finalTime = tonumber(config.finalTime) or (self.gameTime / 2)

    GameConfig.initPos = VectorUtil.newVector3(config.initPos[1].x, config.initPos[1].y, config.initPos[1].z)
    GunConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "GunConfig.csv")))
    SupplyConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "SupplyConfig.csv")))
    ExtraAwardConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "ExtraAwardConfig.csv")))
    AwardConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "AwardConfig.csv")))
    HonorExponentConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "HonorExponentConfig.csv")))
    FirstAwardCheck:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "FirstAwardCheck.csv")))
    PropConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "PropConfig.csv")))
    SkillConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Skill.csv")))
    ExpConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "ExpConfig.csv")))
    SupplyItemConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "SupplyItemConfig.csv")))
    PropertyConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "PropertyConfig.csv")))

    if GameMatch.gameType == "g1043" then
        self:initTeamConfig(configPath)
    elseif GameMatch.gameType == "g1044" then
        self:initPersonalConfig(configPath)
    elseif GameMatch.gameType == "g1045" then
        self:initPvpConfig(configPath)
    end
end

function GameConfig:getConfigFromFile(path)
    local file = io.open(path, "r")
    local fileStream = file.read(file, "*a")
    return TinyParse(fileStream)
end

function GameConfig:getCsvConfig(path)
    return CsvUtil.loadCsvFile(path, 2)
end

function GameConfig:initTeamConfig(path)
    local config = self:getConfigFromFile(path)
    self.teamMaxPlayers = config.teamMaxPlayers or 4
    TeamConfig:init(self:getCsvConfig(string.gsub(path, "config.yml", "TeamConfig.csv")))
    RespawnConfig:init(self:getCsvConfig(string.gsub(path, "config.yml", "Respawn.csv")))
end

function GameConfig:initPersonalConfig(path)
    local config = self:getConfigFromFile(path)
    self.topNumber = tonumber(config.topNumber) or 1
    RespawnConfig:init(self:getCsvConfig(string.gsub(path, "config.yml", "PersonalRespawn.csv")))
end

function GameConfig:initPvpConfig(path)
    local config = self:getConfigFromFile(path)
    self.waitRevengeTime = tonumber(config.waitRevengeTime)
    self.selectTime = tonumber(config.selectTime) or 60
    ChestConfig:init(self:getCsvConfig(string.gsub(path, "config.yml", "ChestConfig.csv")))
    SiteConfig:init(self:getCsvConfig(string.gsub(path, "config.yml", "Site.csv")))
end

return GameConfig