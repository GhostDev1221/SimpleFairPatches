---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Jimmy.
--- DateTime: 2018/10/23 0023 12:28
---

XRailRoute = class()

function XRailRoute:ctor(config)
    self.id = config.id
    self.startPos = config.StartPos
    self.endPos = config.EndPos
    self.rails = {}
    self:onFindRoute()
end

function XRailRoute:onFindRoute()
    local position = VectorUtil.newVector3i(self.startPos.x, self.startPos.y, self.startPos.z)
    local finished = false
    local progress = 0
    while not finished do
        local find = false
        local blockId = EngineWorld:getBlockId(position)
        if self:isRailBlock(blockId) then
            self.rails[VectorUtil.hashVector3(position)] = progress
            progress = progress + 1
        end
        if VectorUtil.equal(position, self.endPos) then
            finished = true
        end
        if finished then
            break
        end
        if not find then
            local posX = VectorUtil.newVector3i(position.x + 1, position.y, position.z)
            blockId = EngineWorld:getBlockId(posX)
            if self:isRailBlock(blockId) and self.rails[VectorUtil.hashVector3(posX)] == nil then
                find = true
                position = posX
            end
        end
        if not find then
            local negX = VectorUtil.newVector3i(position.x - 1, position.y, position.z)
            blockId = EngineWorld:getBlockId(negX)
            if self:isRailBlock(blockId) and self.rails[VectorUtil.hashVector3(negX)] == nil  then
                find = true
                position = negX
            end
        end
        if not find then
            local posZ = VectorUtil.newVector3i(position.x, position.y, position.z + 1)
            blockId = EngineWorld:getBlockId(posZ)
            if self:isRailBlock(blockId) and self.rails[VectorUtil.hashVector3(posZ)] == nil  then
                find = true
                position = posZ
            end
        end
        if not find then
            local negZ = VectorUtil.newVector3i(position.x, position.y, position.z - 1)
            blockId = EngineWorld:getBlockId(negZ)
            if self:isRailBlock(blockId) and self.rails[VectorUtil.hashVector3(negZ)] == nil  then
                find = true
                position = negZ
            end
        end
        if not find then
            finished = true
        end
    end
    local min = 100000
    local minKey = nil
    local max = -1
    local maxKey = nil
    for key, value in pairs(self.rails) do
        if min > value then
            minKey = key            
        end
        if max < value then
            maxKey = key
        end
    end
    self.rails[minKey] = nil
    self.rails[maxKey] = nil
    progress = progress - 2
    for key, value in pairs(self.rails) do
        self.rails[key] = value - 1
    end
    for key, value in pairs(self.rails) do
        self.rails[key] = value * 100 / (progress - 1)
    end
end

function XRailRoute:isRailBlock(blockId)
    if blockId == BlockID.RAIL or
            blockId == BlockID.RAIL_POWERED or
            blockId == BlockID.RAIL_DETECTOR or
            blockId == BlockID.RAIL_ACTIVATOR or
            blockId == BlockID.RAIL_RECEIVE then
        return true
    end
    return false
end

function XRailRoute:getProgress(pos)
    local position = VectorUtil.toBlockVector3(pos.x, pos.y, pos.z)
    local key = VectorUtil.hashVector3(position)
    local progress = self.rails[key]
    if progress then
        return progress
    end
    return 50
end

return XRailRoute