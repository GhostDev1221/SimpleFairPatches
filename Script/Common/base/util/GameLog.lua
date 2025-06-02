---
--- Created by Jimmy.
--- DateTime: 2018/4/14 0014 12:38
---

GameLog = {}

function GameLog.log(userId, type, action, data, immediate)
    HostApi.setDBLogData(userId, type, action, data, immediate or true)
end

return GameLog