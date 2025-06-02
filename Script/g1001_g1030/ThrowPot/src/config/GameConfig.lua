---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:16
---

require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "base.util.CsvUtil"
require "config.ShopConfig"
require "config.RankNpcConfig"
require "config.RoundConfig"
require "config.TitleConfig"
require "config.CommodityConfig"
require "config.ChipConfig"
require "config.SkillConfig"
require "data.GameMerchant"

GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}
GameConfig.gamePos = {}

GameConfig.prepareTime = 0
GameConfig.gameOverTime = 0

GameConfig.startPlayers = 0
GameConfig.speedLevel = 0
GameConfig.isAllDay = true

GameConfig.tntActors = {}

GameConfig.coinMapping = {}
GameConfig.merchants = {}

function GameConfig:init()

    local configPath = self.RootPath

    local config = self:getConfigFromFile(configPath)
    GameConfig.initPos = VectorUtil.newVector3i(config.initPos[1], config.initPos[2], config.initPos[3])
    GameConfig.gamePos = VectorUtil.newVector3i(config.gamePos[1], config.gamePos[2], config.gamePos[3])

    self.prepareTime = tonumber(config.prepareTime or "10")
    self.gameOverTime = tonumber(config.gameOverTime or "10")
    self.startPlayers = tonumber(config.startPlayers or "1")
    self.speedLevel = tonumber(config.speedLevel or "0")
    self.isAllDay = tonumber(config.isAllDay or "1") == 1

    for i, v in pairs(config.tntActors) do
        local actor = {}
        actor.first = v.first
        actor.second = tonumber(v.second)
        self.tntActors[i] = actor
    end

    self:initCoinMapping(config.coinMapping)
    self:initMerchants(config.merchants)
    ShopConfig:init(config.shop)
    RankNpcConfig:init(config.rankNpc)

    RoundConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Round.csv")))
    TitleConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Title.csv")))
    CommodityConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Commodity.csv")))
    ChipConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Chip.csv")))
    SkillConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Skill.csv")))

end

function GameConfig:initCoinMapping(coinMapping)
    for i, v in pairs(coinMapping) do
        self.coinMapping[i] = {}
        self.coinMapping[i].coinId = v.coinId
        self.coinMapping[i].itemId = v.itemId
    end
end

function GameConfig:getItemIdByCoinId(coinId)
    for _, mapping in pairs(self.coinMapping) do
        if mapping.coinId == coinId then
            return mapping.itemId
        end
    end
    return 0
end

function GameConfig:initMerchants(merchants)
    for i, v in pairs(merchants) do
        local merchant = {}
        merchant.name = v.name
        merchant.initPos = VectorUtil.newVector3(tonumber(v.initPos[1]), tonumber(v.initPos[2]), tonumber(v.initPos[3]))
        merchant.yaw = tonumber(v.initPos[4])
        self.merchants[#self.merchants + 1] = GameMerchant.new(merchant)
    end
end

function GameConfig:syncMerchants(player)
    for _, merchant in pairs(self.merchants) do
        merchant:syncPlayer(player)
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

return GameConfig