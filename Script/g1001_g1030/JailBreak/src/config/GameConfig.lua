---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:16
---

require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "config.MerchantConfig"
require "config.ShopConfig"
require "config.WeaponConfig"
require "config.ScoreConfig"
require "config.CriminalConfig"
require "config.PoliceConfig"
require "config.MerchantConfig"
require "config.ChestConfig"
require "config.BlockConfig"
require "config.ProduceConfig"
require "config.LocationConfig"
require "config.VehicleConfig"
require "config.DoorConfig"
require "config.DamageConfig"
require "config.StrongboxConfig"
require "config.RankNpcConfig"
require "config.TransferGateConfig"

GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}
GameConfig.gameTipShowTime = 0
GameConfig.rankUpdateTime = 0
GameConfig.coinMapping = {}

function GameConfig:init()

    local configPath = self.RootPath
    local config = self:getConfigFromFile(configPath)

    GameConfig.initPos = VectorUtil.newVector3i(config.initPos[1], config.initPos[2], config.initPos[3])
    GameConfig.rankUpdateTime = tonumber(config.rankUpdateTime)
    GameConfig.gameTipShowTime = tonumber(config.gameTipShowTime)
    ShopConfig:init(config.shop)
    WeaponConfig:init(config.weapon)
    ScoreConfig:init(config.score)
    CriminalConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "criminal")))
    PoliceConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "police")))
    ChestConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "chest")))
    MerchantConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "merchant")))
    ProduceConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "produce")))
    BlockConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "block")))
    LocationConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "location")))
    VehicleConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "vehicle")))
    DoorConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "door")))
    DamageConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "damage")))
    StrongboxConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "strongbox")))
    RankNpcConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "rankNpc")))
    TransferGateConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "transferGate")))

end

function GameConfig:getConfigFromFile(path)
    local file = io.open(path, "r")
    local fileStream = file.read(file, "*a")
    return TinyParse(fileStream)
end

return GameConfig