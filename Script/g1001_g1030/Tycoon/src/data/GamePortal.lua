---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by work.
--- DateTime: 2018/7/16 12:12
---
require "data.GamePortalBuilder"
require "data.GameGetPortal"
require "data.GameExtraPortal"
require "config.BasicConfig"
require "config.ExtraPortalConfig"

GamePortal = class()

function GamePortal:ctor(domain, player, config)
    self.domain = domain
    self.player = player
    self.config = config
    self.portalers = {}

    self:onCreate()
end

--生成传送门购买NPC
function GamePortal:onCreate()
    if self.domain ~= 0 then
        local pos = BasicConfig:getPosByBasic(self.domain.basicId, self.config.npcPos)
        local yaw = BasicConfig:getYawByBasic(self.domain.basicId, self.config.npcYaw)
        GamePortalBuilder.new(self, pos, yaw, self.config.npcActor, self.config.npcName)
        self.domain:addPortalRecord(self.config.id)
    end
end

function GamePortal:hitPortal(rakssid, exitPos)
    HostApi.resetPos(rakssid, exitPos.x, exitPos.y, exitPos.z)
end

function GamePortal:getPlayer()
    return self.player
end

function GamePortal:getPrice()
    return self.config.price
end

function GamePortal:getValue()
    return self.config.value
end

function GamePortal:buildPortal()
    if self.domain ~= 0 then
        self.domain:addBuildProgress(self.config.value)
    end
    if GameManager.isOpenExtraPortal == false then
        for _, extraPortal in pairs(ExtraPortalConfig.PortalBuildings) do
            GameManager.extraPortals[#GameManager.extraPortals + 1] = GameExtraPortal.new(extraPortal)
        end
        GameManager.isOpenExtraPortal = true
    end
    local pos = BasicConfig:getPosByBasic(self.domain.basicId, self.config.portalEntryPos)
    local yaw = BasicConfig:getYawByBasic(self.domain.basicId, self.config.portalEntryYaw)
    self.portalers[1] = GameGetPortal.new(self, pos, yaw, self.config.actor, self.config.name, false)

    if GameManager.isGoBackPortal == false then
        GameManager.isGoBackPortal = true
        self.portalers[2] = GameGetPortal.new(self, self.config.gobackEntryPos, self.config.gobackEntryYaw, self.config.gobackActor, self.config.gobackName, true)
    end
end

return GamePortal