---
--- Created by longxiang.
--- DateTime: 2018/11/9  16:15

require "Match"

DBDataListener = {}

function DBDataListener:init()
    BaseListener.registerCallBack(GetDataFromDBEvent, self.onGetDataFromDB)
end

function DBDataListener.onGetDataFromDB(player, subkey, data)
    player.isReady = true
    player:initDataFromDB(data, subkey)
end

return DBDataListener

--endregion
