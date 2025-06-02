EnchantMentNpcConfig = {}
EnchantMentNpcConfig.npc = {}

function EnchantMentNpcConfig:init(config)
    self:initNpc(config)
end

function EnchantMentNpcConfig:initNpc(config)
    for i, v in pairs(config) do
        local item = {}
        item.position = VectorUtil.newVector3(tonumber(v.PosX), tonumber(v.PosY), tonumber(v.PosZ))
        item.yaw = tonumber(v.PosYaw) or 0
        item.actorName = tostring(v.ActorName) or ""
        item.name = tostring(v.Name) or ""
        item.type = tonumber(v.Type) or 0
        self.npc[i] = item
    end
end

function EnchantMentNpcConfig:prepareNpc()
    for i, v in pairs(self.npc) do
        if v.actorName ~= nil then
            v.entityId = EngineWorld:addSessionNpc(v.position, v.yaw, v.type, v.name, v.actorName, "body")
        end
    end
end

function EnchantMentNpcConfig:addLightColumnEffect()
    for k,v in pairs(EnchantMentNpcConfig.npc) do
        local pos = VectorUtil.newVector3(tonumber(v.position.x), tonumber(v.position.y - 1), tonumber(v.position.z))
        EngineWorld:addActorNpc(pos, v.yaw, "ranchers_door.actor", "", "", "", true, false)
    end
end

return EnchantMentNpcConfig