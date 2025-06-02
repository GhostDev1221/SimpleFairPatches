require "base.util.tinyyaml"
require "base.util.CsvUtil"
require "base.util.VectorUtil"
require "config.NestConfig"
require "manager.SceneManager"
require "config.PaymentConfig"
require "config.VipConfig"
require "config.BonusConfig"
require "config.BirdConfig"
require "config.MonsterConfig"
require "config.FieldConfig"
require "config.ChestConfig"
require "config.TaskConfig"
require "config.ToolConfig"
require "config.BackpackConfig"
require "config.ShopConfig"
require "config.InitItemsConfig"
require "config.StoreHouseConfig"
require "config.StoreHouseItems"
require "config.BirdBagConfig"
require "config.ActorNpcConfig"

GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}

function GameConfig:init()
    local configPath = self.RootPath
    local config = self:getConfigFromFile(configPath)
    GameConfig.initPos = VectorUtil.newVector3i(config.initPos[1], config.initPos[2], config.initPos[3])
    GameConfig.hp = config.hp
    GameConfig.moveSpeed = config.moveSpeed
    GameConfig.jump = config.jump
    GameConfig.withoutHurtSecond = config.withoutHurtSecond
    GameConfig.hpRecoverCD = config.hpRecoverCD
    GameConfig.hpRecover = config.hpRecover
    GameConfig.awayFromBattleCD = config.awayFromBattleCD
    GameConfig.convertRate = config.convertRate
    GameConfig.initMaxCarryBirdNum = config.initMaxCarryBirdNum
    GameConfig.initMaxCapacityBirdNum = config.initMaxCapacityBirdNum
    GameConfig.flyHigh = config.flyHigh
    GameConfig.arrowPointToNpc = config.arrowPointToNpc
    GameConfig.drawLuckyTaskId = config.drawLuckyTaskId
    GameConfig.drawLuckyPoint = VectorUtil.newVector3(config.drawLuckyPoint[1],config.drawLuckyPoint[2],config.drawLuckyPoint[3])
    GameConfig.arrowPointToNpcPos = VectorUtil.newVector3(config.arrowPointToNpcPos[1], config.arrowPointToNpcPos[2],config.arrowPointToNpcPos[3])
    GameConfig.shopTaskId = config.shopTaskId
    GameConfig.arrowPointToShopPos = VectorUtil.newVector3(config.arrowPointToShopPos[1], config.arrowPointToShopPos[2],config.arrowPointToShopPos[3])
    FieldConfig:initVipArea(config.vipArea)
    FieldConfig:initGuideShopArea(config.arrowShopArea)
    NestConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "nest.csv")))
    NestConfig:initIndex(self:getCsvConfig(string.gsub(configPath, "config.yml", "nestIndex.csv")))
    PaymentConfig:initPayment(self:getCsvConfig(string.gsub(configPath, "config.yml", "payment.csv")))
    VipConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "vip.csv")))
    BonusConfig:initBonusPools(self:getCsvConfig(string.gsub(configPath, "config.yml", "bonusPools.csv")))
    BonusConfig:initBonusTeams(self:getCsvConfig(string.gsub(configPath, "config.yml", "bonusTeams.csv")))
    BonusConfig:initBonusItems(self:getCsvConfig(string.gsub(configPath, "config.yml", "bonusItems.csv")))
    BonusConfig:initNpc(self:getCsvConfig(string.gsub(configPath, "config.yml", "bonusNpc.csv")))
    BirdConfig:initBirds(self:getCsvConfig(string.gsub(configPath, "config.yml", "bird.csv")))
    BirdConfig:initCombine(self:getCsvConfig(string.gsub(configPath, "config.yml", "birdCombine.csv")))
    BirdConfig:initRate(self:getCsvConfig(string.gsub(configPath, "config.yml", "birdRate.csv")))
    BirdConfig:initLevel(self:getCsvConfig(string.gsub(configPath, "config.yml", "birdLevel.csv")))
    BirdConfig:initGifts(self:getCsvConfig(string.gsub(configPath, "config.yml", "birdGifts.csv")))
    BirdConfig:initParts(self:getCsvConfig(string.gsub(configPath, "config.yml", "birdParts.csv")))
    BirdConfig:initFoods(self:getCsvConfig(string.gsub(configPath, "config.yml", "birdFoods.csv")))
    MonsterConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "monster.csv")))
    FieldConfig:initField(self:getCsvConfig(string.gsub(configPath, "config.yml", "field.csv")))
    FieldConfig:initDoor(self:getCsvConfig(string.gsub(configPath, "config.yml", "door.csv")))
    ChestConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "chest.csv")))
    TaskConfig:initMainTasks(self:getCsvConfig(string.gsub(configPath, "config.yml", "task.csv")))
    TaskConfig:initNpc(self:getCsvConfig(string.gsub(configPath, "config.yml", "taskNpc.csv")))
    TaskConfig:initContents(self:getCsvConfig(string.gsub(configPath, "config.yml", "taskContent.csv")))
    TaskConfig:initTaskRequirement(self:getCsvConfig(string.gsub(configPath, "config.yml", "taskRequirement.csv")))
    TaskConfig:initDailyTaskConfigs(self:getCsvConfig(string.gsub(configPath, "config.yml", "taskDaily.csv")))
    BackpackConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "backpack.csv")))
    ToolConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "tool.csv")))
    ShopConfig:initLabels(self:getCsvConfig(string.gsub(configPath, "config.yml", "shopLabels.csv")))
    ShopConfig:initTeams(self:getCsvConfig(string.gsub(configPath, "config.yml", "shopTeams.csv")))
    ShopConfig:initItems(self:getCsvConfig(string.gsub(configPath, "config.yml", "shopItems.csv")))
    InitItemsConfig:initItems(self:getCsvConfig(string.gsub(configPath, "config.yml", "initItems.csv")))
    StoreHouseItems:Init(self:getCsvConfig(string.gsub(configPath, "config.yml", "storeHouseItems.csv")))
    StoreHouseConfig:Init(self:getCsvConfig(string.gsub(configPath, "config.yml", "storeHouseConfig.csv")))
    BirdBagConfig:initCapacityBag(self:getCsvConfig(string.gsub(configPath, "config.yml", "birdCapacityBag.csv")))
    BirdBagConfig:initCarryBag(self:getCsvConfig(string.gsub(configPath, "config.yml", "birdCarryBag.csv")))
    ActorNpcConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "actorNpc.csv")))
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