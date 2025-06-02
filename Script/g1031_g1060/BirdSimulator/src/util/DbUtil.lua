DbUtil = {}
DbUtil.TAG_PLAYER = 1
DbUtil.TAG_BIRD = 2
DbUtil.TAG_BAG = 3
DbUtil.TAG_TASK = 4
DbUtil.TAG_CHEST = 5
DbUtil.TAG_MONSTER = 6

DbUtil.GetDataCaches = {}

function DbUtil:getPlayerData(player)
    DBManager:getPlayerData(player.userId, DbUtil.TAG_PLAYER)

    local cache = {
        { DataType = DbUtil.TAG_PLAYER, HasGet = false },
        { DataType = DbUtil.TAG_BIRD, HasGet = false },
        { DataType = DbUtil.TAG_BAG, HasGet = false },
        { DataType = DbUtil.TAG_TASK, HasGet = false },
        { DataType = DbUtil.TAG_CHEST, HasGet = false },
        { DataType = DbUtil.TAG_MONSTER, HasGet = false }
    }
    DbUtil.GetDataCaches[tostring(player.userId)] = cache
end

function DbUtil:onPlayerGetDataFinish(player, data, subKey)
    local cache = DbUtil.GetDataCaches[tostring(player.userId)]
    if not cache then
        cache = {
            { DataType = DbUtil.TAG_PLAYER, HasGet = false },
            { DataType = DbUtil.TAG_BIRD, HasGet = false },
            { DataType = DbUtil.TAG_BAG, HasGet = false },
            { DataType = DbUtil.TAG_TASK, HasGet = false },
            { DataType = DbUtil.TAG_CHEST, HasGet = false },
            { DataType = DbUtil.TAG_MONSTER, HasGet = false }
        }
    end
    for _, tag in pairs(cache) do
        if tag.DataType == subKey then
            tag.HasGet = true
            break
        end
    end
    DbUtil.GetDataCaches[tostring(player.userId)] = cache
    player:initDataFromDB(data, subKey)
end

function DbUtil:onPlayerQuit(player)
    DbUtil.GetDataCaches[tostring(player.userId)] = nil
end

function DbUtil:saveAllPlayerData()
    if GameMatch.curTick == 0 or GameMatch.curTick % 60 ~= 0 then
        return
    end

    local players = PlayerManager:getPlayers()
    for i, player in pairs(players) do
        self:savePlayerAllData(player)
    end
end

function DbUtil:savePlayerAllData(player, immediate)
    if player == nil then
        return
    end

    DbUtil:savePlayerData(player, immediate)
    DbUtil:saveBirdData(player, immediate)
    DbUtil:saveBirdBagData(player, immediate)
    DbUtil:saveMonsterData(player, immediate)
    DbUtil:saveTaskData(player)
end

function DbUtil:savePlayerData(player, immediate)
    if DbUtil:CanSavePlayerData(player, DbUtil.TAG_PLAYER) then
        local playerData = player:prepareDataSaveToDB()
        DBManager:savePlayerData(player.userId, DbUtil.TAG_PLAYER, json.encode(playerData), immediate)
    end
end

function DbUtil:saveBirdData(player, immediate)
    if DbUtil:CanSavePlayerData(player, DbUtil.TAG_BIRD) then
        if player.userBird ~= nil then
            local birdData = player.userBird:prepareDataSaveToDB()
            DBManager:savePlayerData(player.userId, DbUtil.TAG_BIRD, json.encode(birdData), immediate)
        end
    end
end

function DbUtil:saveBirdBagData(player, immediate)
    if DbUtil:CanSavePlayerData(player, DbUtil.TAG_BAG) then
        if player.userBirdBag ~= nil then
            local bagData = player.userBirdBag:prepareDataSaveToDB()
            DBManager:savePlayerData(player.userId, DbUtil.TAG_BAG, json.encode(bagData), immediate)
        end
    end
end

function DbUtil:saveMonsterData(player, immediate)
    if DbUtil:CanSavePlayerData(player, DbUtil.TAG_MONSTER) then
        if player.userMonster ~= nil then
            local monsterData = player.userMonster:prepareDataSaveToDB()
            DBManager:savePlayerData(player.userId, DbUtil.TAG_MONSTER, json.encode(monsterData), immediate)
        end
    end
end

function DbUtil:saveTaskData(player)
    if DbUtil:CanSavePlayerData(player, DbUtil.TAG_TASK) then
        if player.taskControl ~= nil then
            player.taskControl:SaveData()
        end
    end
end

function DbUtil:CanSavePlayerData(player, subKey)
    local cache = DbUtil.GetDataCaches[tostring(player.userId)]
    if not cache then
        return false
    end
    for _, tag in pairs(cache) do
        if tag.DataType == subKey then
            return tag.HasGet
        end
    end
    return false
end

return DbUtil