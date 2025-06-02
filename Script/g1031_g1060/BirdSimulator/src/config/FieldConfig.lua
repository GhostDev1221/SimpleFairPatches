require "util.Tools"
require "config.Area"

FieldConfig = {}
FieldConfig.fields = {}
FieldConfig.door = {}
FieldConfig.vipArea = {}
FieldConfig.shopArea = {}

function FieldConfig:initField(config)
    for i, v in pairs(config) do
        local data = {}
        data.id = tonumber(v.id)
        data.minPos = Tools.CastToVector3i(v.x1, v.y1, v.z1)
        data.maxPos = Tools.CastToVector3i(v.x2, v.y2, v.z2)
        data.monsterIds = StringUtil.split(v.monsterIds, "#")
        data.monsterPos = StringUtil.split(v.monsterPos, "#")
        data.fruitId = StringUtil.split(v.fruitId, "#")
        data.chance = StringUtil.split(v.chance, "#")
        data.type = tonumber(v.type)
        self.fields[data.id] = data
    end
end

function FieldConfig:initDoor(config)
    for i, v in pairs(config) do
        local data = {}
        data.id = tonumber(v.id)
        data.entityId = tonumber(0)
        data.type = tonumber(v.type)
        data.requirement = tonumber(v.requirement)
        data.minPos = Tools.CastToVector3i(v.x1, v.y1, v.z1)
        data.maxPos = Tools.CastToVector3i(v.x2, v.y2, v.z2)
        data.pos = Tools.CastToVector3(v.x, v.y, v.z)
        data.yaw = tonumber(v.yaw)
        data.actorName = v.actorName
        data.bodyName = v.bodyName
        data.bodyId1 = v.bodyId1
        data.bodyId2 = v.bodyId2
        self.door[data.id] = data
    end
end

function FieldConfig:initVipArea(vipArea)
    self.vipArea = Area.new(vipArea)
end

function FieldConfig:initGuideShopArea(shopArea)
    self.shopArea = Area.new(shopArea)
end

function FieldConfig:enterGuideShopArea(player)
    if self.shopArea:inArea(player:getPosition()) then
        player.isShowShopArrow = false
        HostApi.changeGuideArrowStatus(player.rakssid, GameConfig.arrowPointToShopPos, false)
    end
end

function FieldConfig:enterFieldArea(player)
    if player.enterFieldIndex ~= 0 then
        if self.fields[player.enterFieldIndex] ~= nil then
            local fieldPos = self:getAreaPos(self.fields[player.enterFieldIndex])
            if fieldPos:inArea(player:getPosition()) then
                return
            end
        end
        
        player.enterFieldIndex = 0
        return
    end

    if player.enterFieldIndex == 0 then
        for _, v in pairs(self.fields) do
            local fieldPos = self:getAreaPos(v)
            if fieldPos:inArea(player:getPosition()) then
                player.enterFieldIndex = v.id
                return
            end
        end
    end
end

function FieldConfig:enterDoor(player)
    if player.enterDoorIndex ~= 0 then
        if self.door[player.enterDoorIndex] ~= nil then
            local door = self.door[player.enterDoorIndex]
            local doorPos = self:getAreaPos(door)
            if doorPos:inArea(player:getPosition()) then
                if door.type == 0 and player.userBirdBag.maxCarryBirdNum < door.requirement then
                    player:setHealth(0)
                end

                if door.type == 1 and player.isVipArea == false then
                    player:setHealth(0)
                end
                return
            end
        end

        player.enterDoorIndex = 0
        return
    end

    if player.enterDoorIndex == 0 then
        for _, v in pairs(self.door) do
            local doorPos = self:getAreaPos(v)
            if doorPos:inArea(player:getPosition()) then
                player.enterDoorIndex = v.id
                return
            end
        end
    end
end

function FieldConfig:enterVipArea(player)
    if self.vipArea:inArea(player:getPosition()) then
        if player.isInVipArea == false and player.isVipArea == false then
            player.isInVipArea = true
            HostApi.sendCommonTipByType(player.rakssid, 14, "vipArea")
        end
    else
        if player.isInVipArea == true then
            player.isInVipArea = false
        end
    end
end

function FieldConfig:getAreaPos(data)
    local pos = {}
    pos[1] = {}
    pos[1][1] = data.minPos.x
    pos[1][2] = data.minPos.y
    pos[1][3] = data.minPos.z
    pos[2] = {}
    pos[2][1] = data.maxPos.x
    pos[2][2] = data.maxPos.y
    pos[2][3] = data.maxPos.z
    return Area.new(pos)
end

function FieldConfig:getFieldIdByPos(pos)
    for i, v in pairs(self.fields) do
        local fieldPos = self:getAreaPos(v)
        if fieldPos:inArea(pos) then
            return v.id
        end
    end

    return 0
end

function FieldConfig:getFieldInfoByPos(pos)
    for i, v in pairs(self.fields) do
        local fieldPos = self:getAreaPos(v)
        if fieldPos:inArea(pos) then
            return v
        end
    end

    return nil
end

function FieldConfig:generateCoin(id, vec3)
    if self.fields[id] == nil then
        print("FieldConfig:generateCoin: can not find fields[" .. id .."] 's info ")
        return
    end

    if #self.fields[id].fruitId ~= #self.fields[id].chance then
        print("FieldConfig:generateCoin: the count of 'fruitId' is not equal to 'chance'")
        return
    end

    for i = 1, #self.fields[id].fruitId do
        if self.fields[id].fruitId[i] ~= "@@@" and self.fields[id].chance[i] ~= "@@@" then
            --local randomNum = math.random(1, 10000)
            local randomNum = HostApi.random("fieldBuff", 1, 10000)
            if randomNum <= tonumber(self.fields[id].chance[i]) then
                local num = 1
                local meta = 0
                local lifeTime = 10
                local x = math.random(vec3.x - 2, vec3.x + 2)
                local y = vec3.y + 1
                local z = math.random(vec3.z - 2, vec3.z + 2)
                local pos = VectorUtil.newVector3(x, y, z)
                EngineWorld:addEntityItem(self.fields[id].fruitId[i], num, meta, lifeTime, pos)
            end
        end
    end
end

function FieldConfig:prepareDoorActor()
    for i, v in pairs(self.door) do
        if v.actorName ~= "@@@" or v.bodyName ~= "@@@" or v.bodyId1 ~= "@@@" then
            local entityId =  EngineWorld:addSessionNpc(v.pos, v.yaw, 3, "", v.actorName, v.bodyName, v.bodyId1, "", true, true)
            self.door[i].entityId = entityId

        end
    end
end

return FieldConfig