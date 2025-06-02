--GameConfig.lua
require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "base.util.CsvUtil"
require "base.prop.AppProps"
require "config.MerchantConfig"
require "config.TeamConfig"
require "config.MoneyConfig"
require "config.BridgeConfig"
require "config.TeleportConfig"
require "config.ShopConfig"
require "config.RespawnConfig"
require "config.BlockConfig"
require "config.SkillConfig"
require "config.KeepItemConfig"
require "config.AppPropConfig"
require "config.CenterMerchantConfig"

GameConfig = {}
GameConfig.isChina = false
GameConfig.RootPath = ""

GameConfig.waitingPlayerTime = 0
GameConfig.prepareTime = 0
GameConfig.gameTime = 0
GameConfig.gameOverTime = 0

GameConfig.maxLevel = 0
GameConfig.updateSuccess = ""
GameConfig.updateFailed = ""
GameConfig.updateSound = 0
GameConfig.standUpTime = 0

GameConfig.sppItems = {}
GameConfig.clzItems = {}

function GameConfig:init()

    local configPath = self.RootPath
    local file = io.open(configPath, "r")
    local fileStream = file.read(file, "*a")
    local tinyObj = TinyParse(fileStream)

    self.waitingPlayerTime = tonumber(tinyObj.waitingPlayerTime)
    self.prepareTime = tonumber(tinyObj.prepareTime)
    self.gameTime = tonumber(tinyObj.gameTime)
    self.gameOverTime = tonumber(tinyObj.gameOverTime)
    self.maxLevel = tonumber(tinyObj.maxLevel)
    self.updateSuccess = tostring(tinyObj.updateSuccess)
    self.updateFailed = tostring(tinyObj.updateFailed)
    self.updateSound = tonumber(tinyObj.updateSound)
    self.standTime = tonumber(tinyObj.standTime)
    self.enchantmentEquip = tinyObj.enchantmentEquip
    self.enchantmentEffect = tinyObj.enchantmentEffect
    self.enchantmentConsume = tonumber(tinyObj.enchantmentConsume)
    self.enchantmentOpenTime = tonumber(tinyObj.enchantmentOpenTime)
    self.enchantmentQuickMoney = tonumber(tinyObj.enchantmentQuickMoney)

    local sppi = 0
    for i, v in pairs(tinyObj.sppItems) do
        sppi = sppi + 1
        self.sppItems[sppi] = {}
        self.sppItems[sppi].id = tonumber(i)
        self.sppItems[sppi].num = tonumber(v)
    end

    for i, v in pairs(tinyObj.clzItems) do
        self.clzItems[i] = {}
        local clzi = 0
        for si, sv in pairs(v) do
            clzi = clzi + 1
            self.clzItems[i][clzi] = {}
            self.clzItems[i][clzi].id = tonumber(si)
            self.clzItems[i][clzi].num = tonumber(sv)
        end
    end

    TeamConfig:initTeams(tinyObj.teams)
    MerchantConfig:initGoods(tinyObj.storeInfo.goods)
    MerchantConfig:initShopTruck(tinyObj.shopTruck)
    MoneyConfig:init(tinyObj.money)
    MoneyConfig:initCoinMapping(tinyObj.coinMapping)
    BridgeConfig:init(tinyObj.bridge)
    TeleportConfig:init(tinyObj.teleport)
    ShopConfig:init(tinyObj.shop)
    RespawnConfig:init(tinyObj.respawn)
    BlockConfig:init(tinyObj.block)
    CenterMerchantConfig:init(tinyObj.centerMerchant)

    SkillConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "SkillConfig.csv")))
    AppProps:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "AppProps.csv")))
    KeepItemConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "KeepItem.csv")))
    AppPropConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "AppProps.csv")))
    EnchantMentNpcConfig:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "EnchantmentNpc.csv")))

end

function GameConfig:getCsvConfig(path)
    return CsvUtil.loadCsvFile(path, 2)
end

function GameConfig:canEnchantment(id)
    for _, item in pairs(self.enchantmentEquip) do
        if tonumber(item) == id then
            return true
        end
    end
    return false
end

function GameConfig:getEnchantmentEffect(index)
    for idx, item in pairs(self.enchantmentEffect) do
        if index == idx then
            return item.id, item.level
        end
    end
    return 0, 0
end

function GameConfig:getEnchantmentEffectDes(index)
    for idx, item in pairs(self.enchantmentEffect) do
        if index == idx then
            return item.title, item.des
        end
    end
    return "", ""
end

return GameConfig