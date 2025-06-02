---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:16
---

require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "base.util.CsvUtil"
require "config.FuncNpcConfig"
require "config.ModeSelectConfig"
require "config.ModeSelectMapConfig"
require "config.GunConfig"
require "config.GunLevelConfig"
require "config.PropConfig"
require "config.PropLevelConfig"
require "config.AttributeConfig"
require "config.ExpConfig"
require "config.ChestRewardConfig"
require "config.ChestConfig"
require "config.ArmorConfig"
require "config.SeasonRewardConfig"
require "config.SeasonConfig"
require "config.SeasonRankRewardConfig"
require "config.AppShopConfig"
require "config.PropertyConfig"
require "config.GuideArrowConfig"

GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}

GameConfig.startPlayers = 0

function GameConfig:init()

    local configPath = self.RootPath
    local config = self:getConfigFromFile(configPath)
    self.standByTime = config.standByTime or 300
    self.initExp = tonumber(config.initExp) or 0
    GameConfig.initPos = VectorUtil.newVector3(config.initPos[1], config.initPos[2], config.initPos[3])

    FuncNpcConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "FuncNpc.csv")))
    ModeSelectConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "ModeSelect.csv")))
    ModeSelectMapConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "ModeSelectMap.csv")))
    GunConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "setting/GunSetting.csv"), 3))
    GunLevelConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "setting/GunLevelSetting.csv"), 3))
    PropConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "setting/PropSetting.csv"), 3))
    PropLevelConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "setting/PropLevelSetting.csv"), 3))
    AttributeConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "setting/AttributeSetting.csv"), 3))
    ExpConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "ExpConfigHall.csv")))
    ChestRewardConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "setting/ChestRewardSetting.csv"), 3))
    ChestConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "setting/ChestSetting.csv"), 3))
    ArmorConfig:initArmor(self:getCsvConfig(string.gsub(configPath, "config.yml", "Armor.csv")))
    SeasonRewardConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "setting/SeasonRewardSetting.csv"), 3))
    SeasonConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "setting/SeasonSetting.csv"), 3))
    SeasonRankRewardConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "setting/SeasonRankRewardSetting.csv"), 3))
    AppShopConfig:initTabConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "AppShopTab.csv")))
    AppShopConfig:initGoodsConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "AppShopGoods.csv")))
    PropertyConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "PropertyConfig.csv")))
    GuideArrowConfig:initConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "GuideArrow.csv")))

end

function GameConfig:getConfigFromFile(path)
    local file = io.open(path, "r")
    local fileStream = file.read(file, "*a")
    return TinyParse(fileStream)
end

function GameConfig:getCsvConfig(path, row)
    if row == 1 then
        return CsvUtil.loadCsvFile(path, 2)
    else
        return CsvUtil.loadCsvFile(path, row)
    end
end

return GameConfig