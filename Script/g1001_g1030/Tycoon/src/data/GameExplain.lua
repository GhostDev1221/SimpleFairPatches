---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by work.
--- DateTime: 2018/8/7 15:24
---
require "base.util.VectorUtil"
require "base.util.StringUtil"
require "config.PublicResourceConfig"
require "config.DomainConfig"
require "data.GamePublicResource"
require "data.GameEquipBox"

GameExplain = class()
GameExplain.TYPE_TIP = 4
GameExplain.TYPE_MULI_TIP = 5
GameExplain.perparetest = {}
GameExplain.perparetest.equipboxs = {}
GameExplain.perparetest.resources = {}
GameExplain.sessionNpcIds = {}

function GameExplain:ctor(config)
    self.name = config.name
    self.actor = config.actor
    self.position = VectorUtil.newVector3(tonumber(config.x), tonumber(config.y), tonumber(config.z))
    self.yaw = tonumber(config.yaw)
    self.type = tonumber(config.type)
    self.title = config.title
    self.content = config.content

    self.occId = tonumber(config.id)
    self.offx = config.x
    self.offy = config.y
    self.offz = config.z

    self.domain = {}
    self.domain = DomainConfig:getDomainByOccupationId(self.occId)
    self:onCreate()
end

function GameExplain:onCreate()
    if self.type == GameExplain.TYPE_TIP then
        self.sessionNpcIds[#self.sessionNpcIds + 1] = EngineWorld:addSessionNpc(self.position, self.yaw, self.type, self.name, self.actor, "body", "", self.content)
    elseif GameExplain.TYPE_MULI_TIP then
        local data = {}
        data.title = self.title
        data.tips = StringUtil.split(self.content, "#")
        self.sessionNpcIds[#self.sessionNpcIds + 1] = EngineWorld:addSessionNpc(self.position, self.yaw, self.type, self.name, self.actor, "body", "", json.encode(data))
    end

    if self.domain == nil then
        return
    end

    for _, equipbox in pairs(self.domain.equipboxs) do
        local npc = GameEquipBox.new(0, equipbox)
        self.offx = self.offx - 2
        local pos = VectorUtil.newVector3(tonumber(self.offx), tonumber(self.offy), tonumber(self.offz))
        npc:buildEquipBox(pos, self.yaw)
        npc.builder:onRemove()
        self.perparetest.equipboxs[#self.perparetest.equipboxs + 1] = npc
        npc.builder:onRemove()
    end

    for _, resource in pairs(PublicResourceConfig:getPerpareResource()) do
        self.perparetest.resources[#self.perparetest.resources + 1] = GamePublicResource.new(resource)
    end
    GameManager.perpareResources = self.perparetest.resources
end

function GameExplain:onRemovePerperaNpc()
    for _, equipbox in pairs(self.perparetest.equipboxs) do
        equipbox.npc:onRemove()
    end
    for _, resource in pairs(self.perparetest.resources) do
        resource.receiveNpc:removeResource()
    end
    for _, entityId in pairs(self.sessionNpcIds) do
        EngineWorld:removeEntity(entityId)
    end
end

return GameExplain