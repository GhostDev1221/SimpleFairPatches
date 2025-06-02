require "base.util.tinyyaml"
require "base.util.CsvUtil"
require "base.util.VectorUtil"
require "config.TeamConfig"
require "config.BlockConfig"
require "config.ChestConfig"
require "config.EnchantmentShop"
require "config.ShopConfig"
require "config.ItemConfig"
require "config.NewIslandConfig"
require "config.BridgeConfig"
require "base.prop.AppProps"


GameConfig = {}
GameConfig.RootPath = ""

GameConfig.waitingPlayerTime = 0
GameConfig.gameTime = 0
GameConfig.gameOverTime = 0

GameConfig.startPlayers = 0

function GameConfig:init()

    local configPath = self.RootPath

    local config = self:getConfigFromFile(configPath)
    
    GameConfig.waitingPlayerTime = tonumber(config.waitingPlayerTime or "60")
    GameConfig.assignTeamTime = tonumber(config.assignTeamTime or "0")
    GameConfig.gameTime = tonumber(config.gameTime or "1200")
    GameConfig.gameOverTime = tonumber(config.gameOverTime or "30")
    GameConfig.startPlayers = tonumber(config.startPlayers or "1")
    GameConfig.respawnTime = tonumber(config.respawnTime or "3")
    GameConfig.gameTipShowTime = tonumber(config.gameTipShowTime or "3")
    GameConfig.hpRecoverCD = tonumber(config.hpRecoverCD)
    GameConfig.hpRecover = tonumber(config.hpRecover)
    GameConfig.entityItemLifeTime = tonumber(config.entityItemLifeTime or "6000")
    GameConfig.isKeepInventory = tonumber(config.isKeepInventory or "0")
    GameConfig.playerHp = tonumber(config.playerHp or "20")
    GameConfig.teamNum = tonumber(config.teamNum or "4")
    GameConfig.canRespawnBeforeTime = tonumber(config.canRespawnBeforeTime or "500")

    ShopConfig:init(config.shop)
    BridgeConfig:init(config.bridge)

    SnowBallConfig:initSnowBall(config.snowBall)
    SnowBallConfig:initDamage(tonumber(config.snowBallDamage or "1"))
    NewIslandConfig:initIslandWall(config.islandWall)

    ChestConfig:initChestArea(self:getCsvConfig(string.gsub(configPath, "config.yml", "chestArea.csv")))
    ChestConfig:initChestTeam(self:getCsvConfig(string.gsub(configPath, "config.yml", "chestTeam.csv")))
    ChestConfig:initChest(self:getCsvConfig(string.gsub(configPath, "config.yml", "chest.csv")))
    TeamConfig:initTeams(self:getCsvConfig(string.gsub(configPath, "config.yml", "teams.csv")))
    RespawnConfig:initRespawnGoods(self:getCsvConfig(string.gsub(configPath, "config.yml", "respawn.csv")))
    BlockConfig:initBlock(self:getCsvConfig(string.gsub(configPath, "config.yml", "block.csv")))
    BlockConfig:initBlockHardness(self:getCsvConfig(string.gsub(configPath, "config.yml", "blockHardness.csv")))
    EnchantmentShop:initEnchantment(self:getCsvConfig(string.gsub(configPath, "config.yml", "enchantmentShop.csv")))
    ItemConfig:initItem(self:getCsvConfig(string.gsub(configPath, "config.yml", "playerItem.csv")))
    AppProps:init(CsvUtil.loadCsvFile((string.gsub(configPath, "config.yml", "AppProps.csv")), 2))

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