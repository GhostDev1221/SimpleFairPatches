ActorNpcConfig = {}
ActorNpcConfig.npc = {}

function ActorNpcConfig:init(config)
    for i, v in pairs(config) do
        local data = {}
        data.id = tonumber(v.id)
        data.name = v.name
        data.pos = Tools.CastToVector3(v.x, v.y, v.z)
        data.yaw = tonumber(v.yaw)
        data.actorName = v.actorName
        data.actorBody = v.actorBody
        data.actorBodyId = v.actorBodyId
        self.npc[data.id] = data
    end
end

function ActorNpcConfig:prepareNpc()
    for i, v in pairs(self.npc) do
        if v.name == "@@@" then
            EngineWorld:addSessionNpc(v.pos, v.yaw, 3, "", v.actorName, v.actorBody, v.actorBodyId)
        else
            EngineWorld:addSessionNpc(v.pos, v.yaw, 3, v.name, v.actorName, v.actorBody, v.actorBodyId)
        end
    end
end

return ActorNpcConfig