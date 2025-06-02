---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:16
---
require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "config.XTeamConfig"
require "base.util.CsvUtil"
require "config.XTools"
require "config.XMoneyConfig"
require "config.XInitItemConfig"
require "config.XNpcShopConfig"
require "config.XNpcShopGoodsConfig"
require "config.XRespawnConfig"
require "config.XAppShopConfig"
require "config.XTipsConfig"
require "config.XActorConfig"
require "config.XPlayerShopItems"
require "config.XRailRouteConfig"
require "config.XCarBuffConfig"
require "config.XCarConfig"
require "config.XSkillConfig"
require "config.XPrivilegeConfig"
require "config.XCannonConfig"

GameConfig = {}
GameConfig.RootPath = ""
GameConfig.initPos = {}

GameConfig.prepareTime = 0
GameConfig.prestartTime = 12
GameConfig.gameTime = 0

GameConfig.startPlayers = 0

GameConfig.attackAddMoneyPars = 0
GameConfig.physicalStrength = false
GameConfig.GetMoneyFromSuccessfulCart = 0
GameConfig.closeServerTime = 10

function GameConfig:init()
    local configPath = self.RootPath

    local config = self:getConfigFromFile(configPath)
    GameConfig.initPos = XTools:CastToVector(config.playerInitPosX, config.playerInitPosY, config.playerInitPosZ)

    self.prepareTime = tonumber(config.prepareTime) or 10
    self.prestartTime = tonumber(config.prestartTime) or 12
    self.gameTime = tonumber(config.gameTime) or 60
    self.startPlayers = tonumber(config.startPlayers) or 1
    self.closeServerTime = tonumber(config.closeServerTime) or 10
    self.attackAddMoneyPars = tonumber(config.attackAddMoneyPars) or 1
    self.physicalStrength = config.physicalStrength or false
    self.playerShopName = config.playerShopName
    self.basicHealth = tonumber(config.basicHealth) or 20
    self.addMoneyFromCart = tonumber(config.addMoneyFromCart) or 0
    self.playerActionTime = tonumber(config.playerActionWaitTime) or 0
    self.playExplosionWaitTime = tonumber(config.playExplosionWaitTime) or 0
    self.magmahurtValue = tonumber(config.magmahurtValue) or 1
    self.fishingRodDamage = tonumber(config.fishingRodDamage) or 2
    self.killPlayerAddMoney = tonumber(config.killPlayerAddMoney) or 0
    self.TntHitVlaue = tonumber(config.TntHitVlaue) or 20
    self.LongClockCarTime = tonumber(config.LongClockCarTime) or 20
   
    local callback = self.physicalStrength and function()
        HostApi.setNeedFoodStats(true)
        HostApi.setFoodHeal(true)
    end or function()
        HostApi.setNeedFoodStats(false)
        HostApi.setFoodHeal(false)
    end
    if type(callback) == 'function' then
        callback()
    end

    HostApi.setBlockmanEmptyHitTimes(self.LongClockCarTime * 10) -- before add car

    XMoneyConfig:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XMoneyConfig.csv")))
    XTeamConfig:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XTeamConfig.csv")))
    XInitItemConfig:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XInitItemConfig.csv")))
    XNpcShopConfig:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XNpcShopConfig.csv")))
    XNpcShopGoodsConfig:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XNpcShopGoodsConfig.csv")))
    XRespawnConfig:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XRespawnConfig.csv")))
    XAppShopPrivilege:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XAppShopPrivilege.csv")))
    XAppShopConfig:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XAppShopConfig.csv")))
    XTipsConfig:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XTipsConfig.csv")))
    XActorConfig:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XActorConfig.csv")))
    XPlayerShopItems:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XPlayerShopItems.csv")), self.playerShopName)
    XRailRouteConfig:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XRailRouteConfig.csv")))
    XCarBuffConfig:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XCarBuffConfig.csv")))
    XCarConfig:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XCarConfig.csv")))
    XSkillConfig:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XSkillConfig.csv")))
    XPrivilegeConfig:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XPrivilegeConfig.csv")))
    XCannonConfig:OnInit(self:getCsvConfig(string.gsub(configPath, "config.yml", "XCannonConfig.csv")))
    AppProps:init(self:getCsvConfig(string.gsub(configPath, "config.yml", "XAppProps.csv")))

    XCannonConfig:prepareCannons()
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