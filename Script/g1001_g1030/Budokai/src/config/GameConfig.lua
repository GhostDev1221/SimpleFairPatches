---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:16
---

require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "base.util.CsvUtil"
require "config.RankNpcConfig"
require "config.SiteConfig"
require "config.RoundConfig"
require "config.TitleConfig"
require "config.CommodityConfig"
require "config.RankRewardConfig"
require "config.TipNpcConfig"
require "config.EquipmentSetConfig"
require "config.TalentConfig"
require "config.SegmentConfig"
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

    self:initCoinMapping(config.coinMapping)
    self:initMerchants(config.merchants)
    RankNpcConfig:init(config.rankNpc)
    ShopConfig:init(config.shop)

    SiteConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Site.csv")))
    RoundConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Round.csv")))
    TitleConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Title.csv")))
    CommodityConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Commodity.csv")))
    RankRewardConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "RankReward.csv")))
    TipNpcConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "TipNPC.csv")))
    EquipmentSetConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "EquipmentSet.csv")))
    TalentConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Talent.csv")))
    SegmentConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Segment.csv")))

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