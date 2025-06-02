---
--- Created by Yaoqiang.
--- DateTime: 2018/6/22 0025 17:50
---

require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "config.ShopConfig"
require "base.util.CsvUtil"
require "config.MerchantConfig"
require "config.ToolConfig"
require "config.RoomConfig"
require "config.TaskConfig"
require "config.SessionNpcConfig"
require "config.RanchItemConfig"

GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}

GameConfig.gameOverTime = 0
GameConfig.startPlayers = 0

function GameConfig:init()

    local configPath = self.RootPath

    local config = self:getConfigFromFile(configPath)
    GameConfig.initPos = VectorUtil.newVector3i(config.initPos[1], config.initPos[2], config.initPos[3])
    ShopConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "shop")))
    MerchantConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "merchant")))
    SessionNpcConfig:initNpc(self:getCsvConfig(string.gsub(configPath, "config.yml", "sessionNpc.csv")))
    RanchItemConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "RanchItems.csv")))
    ToolConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "tool")))
    RoomConfig:init(self:getConfigFromFile(string.gsub(configPath, "config", "exploreroom")))

    self.gameStartPos = config.gameStartPos
    self.readyToStartTime = tonumber(config.readyToStartTime)
    self.gameTime = tonumber(config.gameTime)
    self.gameOverTime = tonumber(config.gameOverTime)
    self.startPlayers = tonumber(config.startPlayers)
    self.blockHardness = tonumber(config.blockHardness)
    self.blockCanBreak = config.blockCanBreak
    self.blockCanPlace = config.blockCanPlace
    self.blockCanDrop = config.blockCanDrop
    self.taskInfo = config.taskInfo
    self.Gate = config.Gate
    self.TNTrange = tonumber(config.TNTrange)
    self.currentItemInfo = config.currentItemInfo
    self.boxMoneyGet = config.boxMoneyGet
    self.itemMailContent = config.itemMailContent
    self.itemMailTilte = config.itemMailTilte

    TaskConfig:initTask(self:getCsvConfig(string.gsub(configPath, "config.yml", "task.csv")))
    TaskConfig:initTaskGroup(self:getCsvConfig(string.gsub(configPath, "config.yml", "taskgroup.csv")))
end

function GameConfig:getConfigFromFile(path)
    local file = io.open(path, "r")
    local fileStream = file.read(file, "*a")
    return TinyParse(fileStream)
end

function GameConfig:prepareBlockHardness()
    for i = 1, 256 do
        HostApi.setBlockAttr(i, self.blockHardness)
    end
end

function GameConfig:getChestItem(config)
    local items = RoomConfig:randomItem(config.items, config.range[1], config.range[2])
    return items
end

function GameConfig:getCsvConfig(path)
    return CsvUtil.loadCsvFile(path, 2)
end

function GameConfig:CanBreak(id, meta)
    for k, v in pairs(self.blockCanBreak) do
        if v.meta == -1 then
            if v.id == id then
                return true
            end
        end
        if v.id == id and v.meta == meta then
            return true
        end
    end

    return false
end

function GameConfig:CanPlaceBreak(id, meta)
    for k, v in pairs(self.blockCanPlace) do
        if v.meta == -1 then
            if v.id == id then
                return true
            end
        end
        if v.id == id and v.meta == meta then
            return true
        end
    end

    return false
end

function GameConfig:CanDrop(id, meta)
    for k, v in pairs(self.blockCanDrop) do
        if v.meta == -1 then
            if v.id == id then
                return true
            end
        end
        if v.id == id and v.meta == meta then
            return true
        end
    end

    return false
end

function GameConfig:getCurrentItemDesById(id)
    if self.currentItemInfo then
        for k, v in pairs(self.currentItemInfo) do
            if tonumber(v.id) == id then
                return tostring(v.des)
            end
        end
    end
    return ""
end

function GameConfig:getBoxGetMoney()
    local pro = 0

    local random = math.random(1, 100)
    for k, v in pairs(self.boxMoneyGet) do
        if random > pro and random <= (pro + v.probability) then
            return v.money
        end
        pro = pro + v.probability
    end

    return 0
end

return GameConfig