GameMonster = class ()

function GameMonster:ctor(userId)
    self.userId = userId
    self.monsters = {}
    self.countDown = {}
end

function GameMonster:initDataFromDB(data)
    local item = json.decode(data)
    self:initCountDownFromDB(item.CD)
end

function GameMonster:initCountDownFromDB(data)
    for _, v in pairs(data) do
        self:setCountDown(v.sign, v.time)
    end
end

function GameMonster:prepareDataSaveToDB()
    local data = {
        CD = self:prepareCountDownToDB()
    }
    return data
end

function GameMonster:prepareCountDownToDB()
    local data = {}
    for i, v in pairs(self.countDown) do
        local item = {}
        item.sign = tostring(i)
        item.time = v.time
        table.insert(data, item)
    end

    return data
end

function GameMonster:generateMonster(vec3)
    local fieldInfo = FieldConfig:getFieldInfoByPos(vec3)
    if fieldInfo == nil then
        return
    end

    if #fieldInfo.monsterIds ~= #fieldInfo.monsterPos then
        return
    end

    for i, v in pairs(fieldInfo.monsterPos) do
        local pos = StringUtil.split(v, ",")
        if pos[1] == nil or pos[2] == nil or pos[3] == nil then
            break
        end

        local monsterInfo = MonsterConfig:getMonsterInfoById(fieldInfo.monsterIds[i])
        if monsterInfo == nil then
            break
        end

        local sign = pos[1] .. ":" .. pos[2] .. ":" .. pos[3]
        local monster = self:getMonsterBySign(sign)
        if monster ~= nil then
            -- monster already in the world. do nothing...
            break
        end

        local monsterPos = VectorUtil.newVector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3]))
        local countDown = self:getCountDown(sign)
        if countDown == nil then
            self:addMonsterToWorld(sign, fieldInfo.monsterIds[i], monsterPos, monsterInfo, fieldInfo.minPos, fieldInfo.maxPos)
        else
            local cd = monsterInfo.refreshCD
            if os.time() - countDown.time >= cd then
                self:addMonsterToWorld(sign, fieldInfo.monsterIds[i], monsterPos, monsterInfo, fieldInfo.minPos, fieldInfo.maxPos)
            end
        end
    end

end

function GameMonster:addMonsterToWorld(sign, monsterId, monsterPos, monsterInfo, minPos, maxPos)
    local entityId = EngineWorld:addCreatureNpc(monsterPos, monsterId, 0, monsterInfo.actorName, monsterInfo.name, self.userId)
    local homePos = VectorUtil.newVector3i(monsterPos.x ,monsterPos.y, monsterPos.z)
    EngineWorld:getWorld():setCreatureHome(entityId, homePos)
    self:addMonster(sign, entityId, monsterId, monsterInfo, minPos, maxPos)
    EngineWorld:getWorld():setEntityHealth(entityId, tonumber(monsterInfo.hp), tonumber(monsterInfo.hp))
end

function GameMonster:setMonsterLostTarget()
    for i, v in pairs(self.monsters) do
        v.isLostTarget = true
    end
end

function GameMonster:removeMonster()
    for i, v in pairs(self.monsters) do
        self:removeMonsterByEntityId(v.entityId)
    end
end

function GameMonster:removeMonsterByEntityId(entityId)
    local monster = self:getMonsterByEntityId(entityId)
    if monster ~= nil then
        self.monsters[monster.sign] = nil
    end
    EngineWorld:removeEntity(entityId)
end

function GameMonster:getMonsterBySign(sign)
    if self.monsters[sign] ~= nil then
        return self.monsters[sign]
    end

    return nil
end

function GameMonster:getMonsterByEntityId(entityId)
    for i, v in pairs(self.monsters) do
        if v.entityId == entityId then
            return v
        end
    end

    return nil
end

function GameMonster:addMonster(sign, entityId, monsterId, monsterInfo, minPos, maxPos)
    if entityId ~= 0 then
        self.monsters[sign] = {}
        self.monsters[sign].sign = sign
        self.monsters[sign].entityId = tonumber(entityId)
        self.monsters[sign].monsterId = tonumber(monsterId)
        self.monsters[sign].hp = tonumber(monsterInfo.hp)
        self.monsters[sign].maxHp = tonumber(monsterInfo.hp)
        self.monsters[sign].attack = tonumber(monsterInfo.attack)
        self.monsters[sign].attackCD = tonumber(monsterInfo.attackCD)
        self.monsters[sign].moveSpeed = tonumber(monsterInfo.moveSpeed)
        self.monsters[sign].minPos = minPos
        self.monsters[sign].maxPos = maxPos
        self.monsters[sign].userId = self.userId
        self.monsters[sign].isLostTarget = false
    end
end


function GameMonster:setMonsterDead(entityId)
    local monster = self:getMonsterByEntityId(entityId)
    if monster ~= nil then
        --monster.isLostTarget = true
        self.monsters[monster.sign] = nil
        EngineWorld:getWorld():killCreature(entityId)
        self:setCountDown(monster.sign, os.time())
        local player = PlayerManager:getPlayerByUserId(self.userId)
        if player ~= nil then
            -- reward
            local monsterInfo = MonsterConfig:getMonsterInfoById(monster.monsterId)
            if monsterInfo ~= nil then
                local exp = monsterInfo.exp
                if player.userBird ~= nil then
                    for _, v in pairs(player.userBird.birds) do
                        -- add exp
                        if v.entityId ~= 0 then
                            player.userBird:addExp(v.id, exp)
                        end
                    end
                end

                for i, itemId in pairs(monsterInfo.reward) do
                    local num = monsterInfo.num[i]
                    if tonumber(itemId) > 0 and tonumber(num) > 0 then
                        player:addProp(tonumber(itemId), tonumber(num))
                    end
                end
            end

            -- task
            TaskHelper.dispatch(TaskType.BeaMonsterTaskEvent,player.rakssid, monster.monsterId, 1)
        end
    end
end

function GameMonster:attackPlayer(entityId, player)
    for i, v in pairs(self.monsters) do
        if v.entityId == entityId then
            player.isInBattle = true
            local name = "playerHit:" .. tostring(player.userId)
            TimerManager.RemoveListenerById(name)
            TimerManager.AddDelayListener(name, GameConfig.withoutHurtSecond, player.resetBattleState, player)
            player:subHealth(v.attack)
        end
    end
end

function GameMonster:getCountDown(sign)
    if self.countDown[sign] ~= nil then
        return self.countDown[sign]
    end

    return nil
end

function GameMonster:setCountDown(sign, time)
    if self.countDown[sign] == nil then
        self.countDown[sign] = {}
    end

    self.countDown[sign].time = time
end