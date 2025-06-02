RespawnManager = {}
RespawnManager.schedules = {}

function RespawnManager:addSchedule(rakssid, time)
    self.schedules[rakssid] = time
    --HostApi.log("RespawnManager:addSchedule: rakssid = " .. tostring(rakssid) .. ", time = " .. time)
end

function RespawnManager:tick(tick)
    --HostApi.log("time1 = " .. tick)
    for rakssid, time in pairs(self.schedules) do
        --HostApi.log("rakssid = " .. tostring(rakssid) .. " , time2 = " .. time)
        if time <= tick then
            local player = PlayerManager:getPlayerByRakssid(rakssid)
            if player ~= nil then
                player:onDie()
                GameMatch:ifGameOverByPlayer()
            end
            self:removeSchedule(rakssid)
        end
    end
end

function RespawnManager:removeSchedule(rakssid)
    if self.schedules[rakssid] ~= nil then
        self.schedules[rakssid] = nil
        --HostApi.log("RespawnManager:removeSchedule: rakssid = " .. tostring(rakssid))
    end
end

return RespawnManager