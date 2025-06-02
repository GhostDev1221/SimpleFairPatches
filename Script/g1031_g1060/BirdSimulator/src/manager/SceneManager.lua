SceneManager = {}
SceneManager.userNestIndex = {}
SceneManager.coin = {}

function SceneManager:deleteUserInfoByUid(userId)
    self:deleteUserNestIndex(userId)
end

function SceneManager:initUserNestIndex(userId, index)
    self.userNestIndex[tostring(userId)] = index
end

function SceneManager:getUserNestIndexByUid(userId)
    if self.userNestIndex[tostring(userId)] ~= nil then
        return self.userNestIndex[tostring(userId)]
    end

    return 0
end

function SceneManager:deleteUserNestIndex(userId)
    if self.userNestIndex[tostring(userId)] ~= nil then
        self.userNestIndex[tostring(userId)] = nil
    end
end

function SceneManager:addCoinLevel(entityId, level)
    self.coin[tostring(entityId)] = level
end

function SceneManager:getCoinLevel(entityId)
    if self.coin[tostring(entityId)] ~= nil then
        return self.coin[tostring(entityId)]
    end

    return nil
end

function SceneManager:removeCoinLevel(entityId)
    if self.coin[tostring(entityId)] ~= nil then
        self.coin[tostring(entityId)] = nil
    end
end

function SceneManager:removeCoinLevelByKey(key)
    local str = StringUtil.split(key, ":")
    if str[2] == nil then
        return
    end

    local entityId = str[2]
    if self.coin[tostring(entityId)] ~= nil then
        self.coin[tostring(entityId)] = nil
    end
end