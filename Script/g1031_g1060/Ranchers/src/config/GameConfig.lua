require "base.util.tinyyaml"
require "base.util.CsvUtil"
require "base.util.VectorUtil"
require "config.AreaConfig"
require "config.ManorConfig"
require "config.ShopConfig"
require "config.PlayerLevelConfig"
require "config.HardnessConfig"
require "config.FieldLevelConfig"
require "config.WareHouseConfig"
require "config.ItemsMappingConfig"
require "config.ItemsConfig"
require "config.SessionNpcConfig"
require "config.BuildingConfig"
require "config.HouseConfig"
require "config.AchievementConfig"
require "config.SeedLevelConfig"
require "config.TasksConfig"
require "config.TasksLevelConfig"
require "config.GiftConfig"
require "config.GiftLevelConfig"
require "config.TimePaymentConfig"
require "config.MailLanguageConfig"
require "config.AccelerateItemsConfig"
require "config.PlayerInitItemsConfig"
require "config.VehicleConfig"


GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}

function GameConfig:init()
    local configPath = self.RootPath
    local config = self:getConfigFromFile(configPath)
    self.basisExpend = tonumber(config.basisExpend)
    self.increasingExpend = tonumber(config.increasingExpend)
    self.taskStartLevel = tonumber(config.taskStartLevel)
    self.exploreStartLevel = tonumber(config.exploreStartLevel)
    self.boardCastStayTime = tonumber(config.boardCastStayTime)
    self.boardCastRollTime = tonumber(config.boardCastRollTime)
    self.playerInitMoney = tonumber(config.playerInitMoney)
    self.manorFileName = config.manorFileName

    GameConfig.initPos = VectorUtil.newVector3i(config.initPos[1], config.initPos[2], config.initPos[3])
    AreaConfig:initArea(self:getCsvConfig(string.gsub(configPath, "config.yml", "area.csv")))
    AreaConfig:initExpandConfig(self:getCsvConfig(string.gsub(configPath, "config.yml", "areaExpand.csv")))
    ManorConfig:initManor(self:getCsvConfig(string.gsub(configPath, "config.yml", "manor.csv")))
    PlayerLevelConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "playerLevel.csv")))
    HardnessConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "hardness.csv")))
    FieldLevelConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "fieldLevel.csv")))
    WareHouseConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "wareHouse.csv")))
    ItemsMappingConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "itemsMapping.csv")))
    ItemsConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "items.csv")))
    SessionNpcConfig:initNpc(self:getCsvConfig(string.gsub(configPath, "config.yml", "sessionNpc.csv")))
    BuildingConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "building.csv")))
    HouseConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "house.csv")))
    AchievementConfig:initAchievement(self:getCsvConfig(string.gsub(configPath, "config.yml", "achievement.csv")))
    SeedLevelConfig:initSeedLevel(self:getCsvConfig(string.gsub(configPath, "config.yml", "seedLevel.csv")))
    TasksConfig:initTasks(self:getCsvConfig(string.gsub(configPath, "config.yml", "tasks.csv")))
    TasksLevelConfig:initTasksLevel(self:getCsvConfig(string.gsub(configPath, "config.yml", "tasksLevel.csv")))
    GiftConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "gift.csv")))
    GiftLevelConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "giftLevel.csv")))
    TimePaymentConfig:initPayment(self:getCsvConfig(string.gsub(configPath, "config.yml", "timePayment.csv")))
    MailLanguageConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "mailLanguage.csv")))
    AccelerateItemsConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "accelerateItems.csv")))
    PlayerInitItemsConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "playerInitItems.csv")))
    VehicleConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "vehicle.csv")))
    PlayerInitItemsConfig:initInventory(config.playerInitInventory)
    ShopConfig:init(config.shop)
    AreaConfig:initUnlockedArea(config.initUnlockedArea)
    AreaConfig:initNpcName(config.landNpcName)
    AreaConfig:initNpcActorName(config.landNpcActorName)
    AreaConfig:initWaitForUnlockNpcName(config.waitForUnlockLandNpcName)
    AreaConfig:initWaitForUnlockNpcActorName(config.waitForUnlockLandNpcActorName)
    ManorConfig:initServiceCenter(config.serviceCenter)
    ManorConfig:initFieldPos(config.initFieldPos)
    ManorConfig:initRoadsPos(config.initRoadsPos)
    WareHouseConfig:initWareHousePos(config.wareHouseInitPos)
    BuildingConfig:initAnimalBuildingPos(config.animalBuildingInitPos)
    HouseConfig:initHousePos(config.houseInitPos)
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