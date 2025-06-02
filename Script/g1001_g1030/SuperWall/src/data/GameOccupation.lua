---
--- Created by Jimmy.
--- DateTime: 2018/8/21 0021 15:43
---
GameOccupation = class()

function GameOccupation:ctor(config)
    self.entityId = 0
    self.name = config.name
    self.actor = config.actor
    self.position = config.position
    self.yaw = config.yaw
    self:onCreate()
end

function GameOccupation:onCreate()
    self.entityId = EngineWorld:addSessionNpc(self.position, self.yaw, 8, self.name, self.actor, "body")
end

return GameOccupation