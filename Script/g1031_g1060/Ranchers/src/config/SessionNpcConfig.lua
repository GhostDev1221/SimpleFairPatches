SessionNpcConfig = {}
SessionNpcConfig.sessionNpc = {}
SessionNpcConfig.RanchHouseNpc = 4
SessionNpcConfig.MULTI_TIP_INTERACTION_NPC = 9

function SessionNpcConfig:initNpc(config)
    for i, npc in pairs(config) do
        local data = {}
        data.id = tonumber(npc.id)
        data.name = tostring(npc.name)
        data.actor = tostring(npc.actor)
        data.interactionType = tonumber(npc.interactionType)
        data.position = VectorUtil.newVector3(tonumber(npc.x), tonumber(npc.y), tonumber(npc.z))
        data.yaw = tonumber(npc.yaw)
        data.title = tostring(npc.title)
        data.sureContent = tostring(npc.sureContent)
        data.message = StringUtil.split(npc.message, "#")
        self.sessionNpc[data.id] = data
    end
end

function SessionNpcConfig:prepareNpc()
    for _, v in pairs(self.sessionNpc) do
        local message = {}
        message.title = v.title
        message.tips = {}
        message.interactionType = v.interactionType
        message.sureContent = v.sureContent
        for i, v in pairs(v.message) do
            message.tips[i] = v
        end
        if v.interactionType ~= SessionNpcConfig.RanchHouseNpc then
            v.entityId = EngineWorld:addSessionNpc(v.position, v.yaw, SessionNpcConfig.MULTI_TIP_INTERACTION_NPC, v.name, v.actor, "body", "", json.encode(message))
        end
    end
end

function SessionNpcConfig:getNpcInfoById(id)
    if self.sessionNpc[id] ~= nil then
        return self.sessionNpc[id]
    end

    return nil
end

return SessionNpcConfig