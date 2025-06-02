---
--- Created by Jimmy.
--- DateTime: 2018/9/25 0025 11:54
---
require "base.util.class"

GameGunMerchant = class()

function GameGunMerchant:ctor(config)
    self.entityId = 0
    self.id = config.id
    self.teamId = tonumber(config.teamId)
    self.name = config.name
    self.actor = config.actor
    self.position = VectorUtil.newVector3(tonumber(config.x), tonumber(config.y), tonumber(config.z))
    self.yaw = tonumber(config.yaw)
    self.startPos = VectorUtil.newVector3(tonumber(config.startX), tonumber(config.startY), tonumber(config.startZ))
    self.endPos = VectorUtil.newVector3(tonumber(config.endX), tonumber(config.endY), tonumber(config.endZ))
    self:onCreate()
end

function GameGunMerchant:onCreate()
    self.entityId = EngineWorld:addSessionNpc(self.position, self.yaw, 6, self.name, self.actor, "body")
    GameManager:onAddGunMerchant(self)
end

function GameGunMerchant:onPlayerInGame(player)
    if player:getTeamId() == self.teamId then
        player:setPersonalShopArea(self.startPos, self.endPos)
    end
end

return GameGunMerchant