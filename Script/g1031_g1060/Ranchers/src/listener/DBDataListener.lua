require "Match"
require "config.SceneManager"

DBDataListener = {}

function DBDataListener:init()
    GetDataFromDBEvent.registerCallBack(self.onGetDataFromDB)
    GetDataFromDBErrorEvent.registerCallBack(self.onGetDataFromDBError)
end

function DBDataListener.onGetDataFromDB(userId, tag, data)
    DBManager:initPlayerData(userId, tag, data)
    SceneManager:initDataFromDB(userId, data, tag)
end

function DBDataListener.onGetDataFromDBError(userId, tag)
    -- 保存错误玩家id
    SceneManager:initErrorTarget(userId)

    -- 拆除 领地相关建筑
    local buildingInfo = SceneManager:getUserBuildingInfoByUid(userId)
    if buildingInfo ~= nil then
        buildingInfo:removeAllBuildingFromWorld()
    end

    local houseInfo = SceneManager:getUserHouseInfoByUid(userId)
    if houseInfo ~= nil then
        houseInfo:removeHouseFromWorld(houseInfo.houseLevel)
    end

    local wareHouseInfo = SceneManager:getUserWareHouseInfoByUid(userId)
    if wareHouseInfo ~= nil then
        wareHouseInfo:removeWareHouseFromWorld()
    end

    local manorInfo = SceneManager:getUserManorInfoByUid(userId)
    if manorInfo ~= nil then
        manorInfo:removeAllManorFromWorld()
    end

    local fieldInfo = SceneManager:getUserFieldInfoByUid(userId)
    if fieldInfo ~= nil then
        fieldInfo:removeAllFieldAndRoadsFromWorld()
    end

    -- 清空 领地所有的数据
    SceneManager:deleteUserManorInfoByUid(userId)
    SceneManager:deleteUserAchievementInfoByUid(userId)
    SceneManager:deleteUserBuildingInfoByUid(userId)
    SceneManager:deleteUserHouseInfoByUid(userId)
    SceneManager:deleteUserTaskInfoByUid(userId)
    SceneManager:deleteUserWareHouseInfoByUid(userId)
    SceneManager:deleteUserFieldInfoByUid(userId)
    SceneManager:deleteUserAccelerateItemsInfoByUid(userId)

    -- 通知room服务 领地被回收
    HostApi.sendReleaseManor(userId)

    HostApi.log("=== LuaLog:[error] DBDataListener.onGetDataFromDBError : player["..tostring(userId).."]:tag[".. tag .."] get mysql data fail.")

end

return DBDataListener

--endregion
