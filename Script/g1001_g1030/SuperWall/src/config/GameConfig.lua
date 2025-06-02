require "base.util.tinyyaml"
require "base.util.CsvUtil"
require "base.util.VectorUtil"
require "base.prop.AppProps"
require "config.ShopConfig"
require "config.CommodityConfig"
require "config.TeamConfig"
require "config.CannotDropItemConfig"
require "config.RespawnConfig"
require "config.BasicPropConfig"
require "config.AreaOfEliminateConfig"
require "config.BasementConfig"
require "config.TowerConfig"
require "config.MineResourceConfig"
require "config.BlockAttrConfig"
require "config.ToolAttrConfig"
require "config.AttackXConfig"
require "config.InventoryConfig"
require "config.OccupationNpcConfig"
require "config.OccupationConfig"
require "config.SkillEffectConfig"
require "config.SkillConfig"
require "data.GameMerchant"

GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}

GameConfig.waitingPlayerTime = 0
GameConfig.prepareTime = 0
GameConfig.gamePrepareTime = 0
GameConfig.gameTime = 0
GameConfig.gameOverTime = 0

GameConfig.startPlayers = 0

GameConfig.coinMapping = {}
GameConfig.merchants = {}
GameConfig.defaultAttr = {}

function GameConfig:init()

    local configPath = self.RootPath

    local config = self:getConfigFromFile(configPath)
    GameConfig.initPos = VectorUtil.newVector3i(config.initPos[1], config.initPos[2], config.initPos[3])
    GameConfig.yaw = tonumber(config.initPos[4])
    GameConfig.worldTime = tonumber(config.worldTime or "6000")

    GameConfig.waitingPlayerTime = tonumber(config.waitingPlayerTime or "60")
    GameConfig.prepareTime = tonumber(config.prepareTime or "60")
    GameConfig.gamePrepareTime = tonumber(config.gamePrepareTime or "60")
    GameConfig.gameTime = tonumber(config.gameTime or "1200")
    GameConfig.gameOverTime = tonumber(config.gameOverTime or "30")
    GameConfig.startPlayers = tonumber(config.startPlayers or "1")

    self:initDefaultAttr(config.defaultAttr)
    self:initCoinMapping(config.coinMapping)
    self:initMerchants(config.merchants)

    ShopConfig:init(config.shop)
    RankNpcConfig:init(config.rankNpc)
    RespawnConfig:init(config.respawn)

    AppProps:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "AppProps.csv")))
    CommodityConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Commodity.csv")))
    CannotDropItemConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "CannotDropItem.csv")))
    TeamConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "TeamConfig.csv")))
    BasicPropConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "BasicProp.csv")))
    AreaOfEliminateConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "AreaOfEliminate.csv")))
    BasementConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Basement.csv")))
    TowerConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Tower.csv")))
    MineResourceConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "MineResource.csv")))
    BlockAttrConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "BlockAttr.csv")))
    ToolAttrConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "ToolAttr.csv")))
    AttackXConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "AttackX.csv")))
    InventoryConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Inventory.csv")))
    OccupationNpcConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "OccupationNpc.csv")))
    OccupationConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Occupation.csv")))
    SkillEffectConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "SkillEffect.csv")))
    SkillConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "Skill.csv")))

end

function GameConfig:initDefaultAttr(defaultAttr)
    local attr = {}
    attr.type = defaultAttr.type
    attr.health = tonumber(defaultAttr.health)
    attr.speed = tonumber(defaultAttr.speed)
    attr.attack = tonumber(defaultAttr.attack)
    attr.defense = tonumber(defaultAttr.defense)
    attr.defenseX = tonumber(defaultAttr.defenseX)
    self.defaultAttr = attr
end
function GameConfig:initMerchants(merchants)
    for i, v in pairs(merchants) do
        local merchant = {}
        merchant.name = v.name
        merchant.initPos = VectorUtil.newVector3(tonumber(v.initPos[1]), tonumber(v.initPos[2]), tonumber(v.initPos[3]))
        merchant.yaw = tonumber(v.initPos[4])
        merchant.groupId = v.groupId
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

function GameConfig:initCoinMapping(coinMapping)
    for i, v in pairs(coinMapping) do
        self.coinMapping[i] = {}
        self.coinMapping[i].coinId = v.coinId
        self.coinMapping[i].itemId = v.itemId
    end
end

return GameConfig