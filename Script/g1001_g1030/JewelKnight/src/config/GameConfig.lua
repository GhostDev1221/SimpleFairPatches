require "base.util.tinyyaml"
require "base.util.CsvUtil"
require "config.BlockConfig"
require "config.ShopConfig"
require "config.ItemConfig"
require "config.TeamConfig"
require "config.ToolConfig"
require "config.SessionNpcConfig"
require "config.RankNpcConfig"
require "config.CommodityConfig"
require "config.MoneyConfig"
require "config.MerchantConfig"
require "config.JewelConfig"
require "config.ResourceConfig"

GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}

GameConfig.waitingPlayerTime = 0
GameConfig.gameTime = 0
GameConfig.gameOverTime = 0

GameConfig.startPlayers = 0

function GameConfig:init()

    local configPath = self.RootPath

    local config = self:getConfigFromFile(configPath)
    GameConfig.initPos = VectorUtil.newVector3i(config.initPos[1], config.initPos[2], config.initPos[3])
    GameConfig.yaw = tonumber(config.initPos[4])
    GameConfig.waitingPlayerTime = tonumber(config.waitingPlayerTime or "60")
    GameConfig.assignTeamTime = tonumber(config.assignTeamTime or "0")
    GameConfig.gameTime = tonumber(config.gameTime or "1200")
    GameConfig.gameCalculateTime = tonumber(config.gameCalculateTime or "15")
    GameConfig.gameOverTime = tonumber(config.gameOverTime or "30")
    GameConfig.startPlayers = tonumber(config.startPlayers or "4")
    GameConfig.fillBlockId = tonumber(config.fillBlockId)
    GameConfig.respawnTime = tonumber(config.respawnTime  or "1")
    GameConfig.gameTipShowTime = tonumber(config.gameTipShowTime  or "3")
    GameConfig.moneyFromKill = tonumber(config.moneyFromKill or "3")

    ShopConfig:init(config.shop)
    RankNpcConfig:init(config.rankNpc)
    MerchantConfig:initMerchants(config.merchants)
    MerchantConfig:initUpgradeMerchants(config.updateMerchants)
    MoneyConfig:initCoinMapping(config.coinMapping)
    ItemConfig:initRemoveItem(config.removeItem)
    BlockConfig:initBlock(self:getCsvConfig(string.gsub(configPath, "config.yml", "block.csv")))
    BlockConfig:initMine(self:getCsvConfig(string.gsub(configPath, "config.yml", "mine.csv")))
    BlockConfig:initItem(self:getCsvConfig(string.gsub(configPath, "config.yml", "item.csv")))
    BlockConfig:initArea(self:getCsvConfig(string.gsub(configPath, "config.yml", "mineArea.csv")))
    ItemConfig:initNoDropItem(self:getCsvConfig(string.gsub(configPath, "config.yml", "noDropItem.csv")))
    TeamConfig:initTeams(self:getCsvConfig(string.gsub(configPath, "config.yml", "teams.csv")))
    ToolConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "tools.csv")))
    SessionNpcConfig:initNpc(self:getCsvConfig(string.gsub(configPath, "config.yml", "sessionNpc.csv")))
    CommodityConfig:initCommoditys(self:getCsvConfig(string.gsub(configPath, "config.yml", "commodity.csv")))
    JewelConfig:initJewel(self:getCsvConfig(string.gsub(configPath, "config.yml", "jewel.csv")))
    MerchantConfig:initTools(self:getCsvConfig(string.gsub(configPath, "config.yml", "toolsShop.csv")))
    ResourceConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "resource.csv")))
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