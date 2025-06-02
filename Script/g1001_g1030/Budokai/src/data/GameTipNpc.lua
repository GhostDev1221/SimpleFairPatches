---
--- Created by Jimmy.
--- DateTime: 2018/8/3 0003 14:42
---
require "base.util.VectorUtil"
require "base.util.StringUtil"

GameTipNpc = class()
GameTipNpc.TYPE_TIP = 4
GameTipNpc.TYPE_MULI_TIP = 5

function GameTipNpc:ctor(config)
    self.name = config.name
    self.actor = config.actor
    self.position = VectorUtil.newVector3(tonumber(config.x), tonumber(config.y), tonumber(config.z))
    self.yaw = tonumber(config.yaw)
    self.type = tonumber(config.type)
    self.title = config.title
    self.content = config.content
    self:onCreate()
end

function GameTipNpc:onCreate()
    if self.type == GameTipNpc.TYPE_TIP then
        EngineWorld:addSessionNpc(self.position, self.yaw, self.type, self.name, self.actor, "body", "", self.content)
    elseif GameTipNpc.TYPE_MULI_TIP then
        local data = {}
        data.title = self.title
        data.tips = StringUtil.split(self.content, "#")
        EngineWorld:addSessionNpc(self.position, self.yaw, self.type, self.name, self.actor, "body", "", json.encode(data))
    end
end

return GameTipNpc

