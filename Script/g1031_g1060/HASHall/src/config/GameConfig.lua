---
--- Created by longxiang.
--- DateTime: 2018/11/9  16:15
---


require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "base.util.CsvUtil"
require "config.ShopConfig"
require "config.LotteryNpcConfig"
require "config.ActorsConfig"
require "config.ModeNpcConfig"
require "config.RankNpcConfig"

GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}
function GameConfig:init()

    local configPath = self.RootPath
    local config = self:getConfigFromFile(configPath)
    GameConfig.initPos = VectorUtil.newVector3(config.initPos[1], config.initPos[2], config.initPos[3])
    ShopConfig:init(config.shop)
    self.todayFirstLogin = tonumber(config.todayFirstLogin) or 500

    self.lotteryOneTimesRare = config.lotteryOneTimesRare
    self.lotteryTenTimesRare = config.lotteryTenTimesRare
    self.standByTime = tonumber(config.standByTime) or 300
    self.gameTipShowTime = tonumber(config.gameTipShowTime) or 3
    self.rareItemBgImg = config.rareItemBgImg
    self.ordinaryItemBgImg = config.ordinaryItemBgImg

    LotteryNpcConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "LotteryNpc.csv")))
    ActorsConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Actors.csv")))
    ModeNpcConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "ModeNpc.csv")))
    RankNpcConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "RankNpc.csv")))
    self:initRandomSeed()
end

function GameConfig:initRandomSeed()
    for i = 1, 10 do
        local rareProbability = self.lotteryTenTimesRare
        rare = rareProbability[i]
        LotteryUtil:initRandomSeed(i, {rare, 1 - rare})
    end
end

function GameConfig:getCsvConfig(path)
    return CsvUtil.loadCsvFile(path, 2)
end

function GameConfig:getConfigFromFile(path)
    local file = io.open(path, "r")
    local fileStream = file.read(file, "*a")
    return TinyParse(fileStream)
end

return GameConfig