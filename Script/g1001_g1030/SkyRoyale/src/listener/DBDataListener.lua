---
--- Created by Jimmy.
--- DateTime: 2018/4/28 0028 10:10

require "Match"

DBDataListener = {}

function DBDataListener:init()
    BaseListener.registerCallBack(GetDataFromDBEvent, self.onGetDataFromDB)
end

function DBDataListener.onGetDataFromDB(player, role, data)
    player.isReady = true
    player:initDataFromDB(data)
end
return DBDataListener

--endregion
