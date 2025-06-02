---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:16
---

require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "base.util.CsvUtil"
require "config.GunsConfig"
require "config.ExperienceGunsConfig"
require "config.ModeNpcConfig"
require "config.GunsForgeNpcConfig"
require "config.ForgeProbabilityConfig"
require "config.TipNpcConfig"
require "config.ForgeGroupConfig"
require "config.ShopConfig"
require "config.SprayPaintConfig"
require "config.SpecialClothingConfig"

GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}

GameConfig.standByTime = 0

function GameConfig:init()

    local configPath = self.RootPath

    local config = self:getConfigFromFile(configPath)
    GameConfig.initPos = VectorUtil.newVector3(config.initPos[1], config.initPos[2], config.initPos[3])
    GameConfig.standByTime = tonumber(config.standByTime or "100")

    RankNpcConfig:init(config.rankNpc)

    GunsConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Guns.csv")))
    ExperienceGunsConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "ExperienceGuns.csv")))
    ModeNpcConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "ModeNpc.csv")))
    GunsForgeNpcConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "GunsForgeNpc.csv")))
    ForgeProbabilityConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "ForgeProbability.csv")))
    TipNpcConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "TipNpc.csv")))
    ForgeGroupConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "ForgeGroup.csv")))
    SprayPaintConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "SprayPaint.csv")))
    SpecialClothingConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "SpecialClothing.csv")))

    ShopConfig:init(config.shop)
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