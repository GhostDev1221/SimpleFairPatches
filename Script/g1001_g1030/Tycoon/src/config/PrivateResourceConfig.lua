---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by work.
--- DateTime: 2018/7/2 17:38
---
require "config.ResourceBuilding"

PrivateResourceConfig = {}
PrivateResourceConfig.privateResources = {}

function PrivateResourceConfig:init(priResourses)
    self:initResourse(priResourses)
end

--配置私有资源点配置文件
function PrivateResourceConfig:initResourse(priResourses)
    for i, priRes in pairs(priResourses) do
        local item = {}
        item.id = tonumber(priRes.id)
        item.resSaveMax = tonumber(priRes.resSaveMax)
        item.color = priRes.color
        item.interval = tonumber(priRes.interval)
        item.output = tonumber(priRes.output)
        item.recNpcActor = priRes.recNpcActor
        item.recNpcName = priRes.recNpcName
        item.recNpcEffect = priRes.recNpcEffect
        item.initPos = VectorUtil.newVector3(tonumber(priRes.recNpcX), tonumber(priRes.recNpcY), tonumber(priRes.recNpcZ))
        item.yaw = tonumber(priRes.recNpcYaw)
        item.getCd = tonumber(priRes.getCd)
        item.builds = ResourceBuilding:getBuildsByGroupId(item.id)
        item.maxLv = #item.builds
        self.privateResources[tonumber(i)] = item
    end
end

function PrivateResourceConfig:getResourses(resourceId)
    return self.privateResources[tonumber(resourceId)]
end

return PrivateResourceConfig