---
--- Created by longxiang.
--- DateTime: 2018/11/9  16:15

require "Match"

DBDataListener = {}

function DBDataListener:init()
    BaseListener.registerCallBack(GetDataFromDBEvent, self.onGetDataFromDB)
end

function DBDataListener.onGetDataFromDB(player, subKey, data)
    player:initDataFromDB(data, subKey)
end

return DBDataListener

--endregion
