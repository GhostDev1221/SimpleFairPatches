---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:16
---

require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "config.BlockConfig"
require "config.ToolConfig"
require "config.ChestConfig"
require "config.MerchantConfig"
require "config.BackpackConfig"
require "config.ShopConfig"
require "config.NpcConfig"

GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}
GameConfig.coinMapping = {}
GameConfig.teleportCD = 0
GameConfig.crashTime = 0
GameConfig.initEquip = {}

function GameConfig:init()

    local configPath = self.RootPath
    local config = self:getConfigFromFile(configPath)
    self.teleportCD = config.teleportCD
    self.crashTime = config.crashTime

    for i, v in pairs(config.initEquip) do
        self.initEquip[i] = {}
        self.initEquip[i].id = v.id
        self.initEquip[i].num = v.num
    end

    GameConfig.initPos = VectorUtil.newVector3i(config.initPos[1], config.initPos[2], config.initPos[3])
    BlockConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "block")))
    ToolConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "tool")))
    ChestConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "chest")))
    BackpackConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "backpack")))
    MerchantConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "merchant")))
    ShopConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "shop")))
    NpcConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "npc")))
end

function GameConfig:getConfigFromFile(path)
    local file = io.open(path, "r")
    local fileStream = file.read(file, "*a")
    return TinyParse(fileStream)
end

return GameConfig