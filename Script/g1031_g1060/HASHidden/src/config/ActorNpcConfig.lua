---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaolai.
--- DateTime: 2018/11/12 17:14
---

require "base.util.VectorUtil"

ActorNpcConfig = {}
ActorNpcConfig.actorNpc = {}
ActorNpcConfig.model = {}
ActorNpcConfig.npcs = {}
ActorNpcConfig.price = 0


function ActorNpcConfig:init(config)
    self:initActorNpc(config)
end

function ActorNpcConfig:initActorNpc(ActorNpcs)
    for id, actornpc in pairs(ActorNpcs) do
        local item = {}
        item.id = actornpc.id
        item.actor = actornpc.actor
        item.name = actornpc.name
        item.pos = VectorUtil.newVector3(actornpc.x, actornpc.y, actornpc.z)
        item.yaw = tonumber(actornpc.yaw)
        item.image = actornpc.image
        item.tipHint = actornpc.tipHint
        item.type = actornpc.type
        item.blankActor = actornpc.blankActor
        self.actorNpc[id] = item
    end
end

function ActorNpcConfig:prepareActorNpc()
    for i, config in pairs(ActorNpcConfig.actorNpc) do
        GameNpc.new(config)
    end
end

function ActorNpcConfig:onAddActorNpc(npc)
    self.npcs[tostring(npc.entityId)] = npc
end

function ActorNpcConfig:onRemoveActorNpc(npc)
    self.npcs[tostring(npc.entityId)] = nil
end

function ActorNpcConfig:getActorByEntityId(entityId)
    return self.npcs[tostring(entityId)]
end

return ActorNpcConfig