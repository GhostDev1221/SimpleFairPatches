require "Match"

DBDataListener = {}

function DBDataListener:init()
    GetDataFromDBEvent.registerCallBack(self.onGetDataFromDB)
    GetDataFromDBErrorEvent.registerCallBack(self.onGetDataFromDBError)
end

function DBDataListener.onGetDataFromDB(userId, tag, data)
    local player = PlayerManager:getPlayerByUserId(userId)
    if player == nil then
        return
    end

    DbUtil:onPlayerGetDataFinish(player, data, tag)
end

function DBDataListener.onGetDataFromDBError(userId, tag)
    local player = PlayerManager:getPlayerByUserId(userId)
    if player ~= nil then
        HostApi.sendGameover(player.rakssid, IMessages:msgGameOverByDBDataError(), GameOverCode.LoadDBDataError)
        HostApi.sendReleaseManor(player.userId)
    end
end

return DBDataListener

--endregion
