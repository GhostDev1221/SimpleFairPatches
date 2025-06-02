---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:16
---

require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "config.MerchantConfig"
require "config.ManorNpcConfig"
require "config.YardConfig"
require "config.HouseConfig"
require "config.ShopConfig"
require "config.FurnitureConfig"
require "config.BlockConfig"
require "config.VehicleConfig"

GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}
GameConfig.repairItemId = 0
GameConfig.repairItemMeta = 0
GameConfig.exchangeRate = 0

function GameConfig:init()
    local configPath = self.RootPath
    local config = self:getConfigFromFile(configPath)
    GameConfig.initPos = VectorUtil.newVector3i(config.initPos[1], config.initPos[2], config.initPos[3])
    GameConfig.repairItemId = tonumber(config.repairItemId)
    GameConfig.repairItemMeta = tonumber(config.repairItemMeta)
    GameConfig.exchangeRate = tonumber(config.exchangeRate)
    MerchantConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "merchant")))
    ManorNpcConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "manorNpc")))
    YardConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "yard")))
    HouseConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "house")))
    FurnitureConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "furniture")))
    ShopConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "shop")))
    BlockConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "block")))
    VehicleConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "vehicle")))
end

function GameConfig:getConfigFromFile(path)
    local file = io.open(path, "r")
    local fileStream = file.read(file, "*a")
    return TinyParse(fileStream)
end

return GameConfig