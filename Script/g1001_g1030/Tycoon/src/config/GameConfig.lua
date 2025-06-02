--GameConfig.lua
require "base.util.WalletUtils"
require "base.util.VectorUtil"
require "base.prop.AppProps"
require "base.util.tinyyaml"
require "base.util.CsvUtil"
require "config.PrivateResourceConfig"
require "config.UpgradeEquipBoxConfig"
require "config.PublicResourceConfig"
require "config.GameExplainConfig"
require "config.ExtraPortalConfig"
require "config.SkillEffectConfig"
require "config.ResourceBuilding"
require "config.OccupationConfig"
require "config.InventoryConfig"
require "config.CommodityConfig"
require "config.EquipBoxConfig"
require "config.BuildingConfig"
require "config.MerchantConfig"
require "config.RespawnConfig"
require "config.PortalConfig"
require "config.DomainConfig"
require "config.BasicConfig"
require "config.SkillConfig"
require "config.GateConfig"
require "config.RankConfig"
require "config.ShopConfig"
require "Match"
GameConfig = {}
GameConfig.isChina = false
GameConfig.RootPath = ""

GameConfig.waitingTime = 0
GameConfig.prepareTime = 0
GameConfig.gameOverTime = 0
GameConfig.gameTime = 0
GameConfig.gameOverTime = 0

GameConfig.startPlayers = 0
GameConfig.maxPlayers = 0

GameConfig.initPos = {}
GameConfig.gamePos = {}

GameConfig.coinMapping = {}
GameConfig.baseOccIds = {}
function GameConfig:init()

    local configPath = self.RootPath
    local config = self:getConfigFromFile(configPath)

    self.waitingTime = tonumber(config.waitingTime or 30)
    self.prepareTime = tonumber(config.prepareTime or 10)
    self.selectRoleTime = tonumber(config.selectRoleTime or 20)
    self.gameTime = tonumber(config.gameTime or 1200)
    self.gameOverTime = tonumber(config.gameOverTime or 20)
    self.money = tonumber(config.money or 11)
    self.startPlayers = tonumber(config.startPlayers or 1)
    self.dropMoneyPercent = tonumber(config.dropMoneyPercentbyDie or 0.5)
    self.rewardMoneyPercent = tonumber(config.rewardMoneyPercent or 0.3)
    self.maxPlayers = PlayerManager:getMaxPlayer()
    self.occSelectMaxNum = tonumber(config.occSelectMaxNum or 2)
    self.CollisionDistance = tonumber(config.CollisionDistance or 2)
    self.initPos = VectorUtil.newVector3i(config.initPos[1], config.initPos[2], config.initPos[3])
    self.gamePos = VectorUtil.newVector3i(config.gamePos[1], config.gamePos[2], config.gamePos[3])
    self.selectRolePos = VectorUtil.newVector3i(config.selectRolePos[1], config.selectRolePos[2], config.selectRolePos[3])
    for _, id in pairs(config.baseOccIds) do
        table.insert(self.baseOccIds, id)
    end
    self:initCoinMapping(config.coinMapping)
    RankConfig:init(config.ranks)
    RespawnConfig:init(config.respawn)
    ShopConfig:init(config.shop)
    MerchantConfig:initMerchants(config.merchants)
    AppProps:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "AppProps.csv")))
    BasicConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "BasicPoint.csv")))
    InventoryConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Inventory.csv")))
    OccupationConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Occupation.csv")))
    GateConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Gate.csv")))
    UpgradeEquipBoxConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "UpgradeEquipBox.csv")))
    EquipBoxConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "EquipBox.csv")))
    BuildingConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Building.csv")))
    ResourceBuilding:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "ResourceBuilding.csv")))
    PrivateResourceConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "PrivateResource.csv")))
    PortalConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "PortalBuilding.csv")))
    ExtraPortalConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "ExtraPortal.csv")))
    DomainConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Domain.csv")))
    PublicResourceConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "PublicResource.csv")))
    SkillEffectConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "SkillEffect.csv")))
    SkillConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Skill.csv")))
    GameExplainConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "GameExplain.csv")))
    CommodityConfig:initCommoditys(self:getCsvConfig(string.gsub(configPath, "config.yml", "Commodity.csv")))
    PersonResourceConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "PersonResource.csv")))
    OccupationConfig:initUnlockOccupationInfo(self:getCsvConfig(string.gsub(configPath, "config.yml", "OccupationUnlock.csv")))
end

function GameConfig:getConfigFromFile(path)
    local file = io.open(path, "r")
    local fileStream = file.read(file, "*a")
    return TinyParse(fileStream)
end

function GameConfig:getCsvConfig(path)
    return CsvUtil.loadCsvFile(path, 2)
end

function GameConfig:initCoinMapping(config)
    for i, v in pairs(config) do
        self.coinMapping[i] = {}
        self.coinMapping[i].coinId = tonumber(v.coinId)
        self.coinMapping[i].itemId = tonumber(v.itemId)
    end
    WalletUtils:addCoinMappings(self.coinMapping)
end

function GameConfig:isCoinbyItemId(itemId)
    for _, item in pairs(self.coinMapping) do
        if tonumber(item.itemId) == tonumber(itemId) then
            return true
        end
    end
    return false
end

return GameConfig