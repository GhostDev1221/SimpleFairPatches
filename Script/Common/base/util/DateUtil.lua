---
--- Created by Jimmy.
--- DateTime: 2018/3/8 0008 10:16
---
require "base.util.NumberUtil"

DateUtil = {}

function DateUtil.getYearWeek(time)
    return os.date("%Y", time) .. DateUtil.getWeeksOfYear(time)
end

function DateUtil.getWeeksOfYear(time)
    if time == nil then
        time = os.time()
    end
    local firstYearTime = os.time({ day = 1, month = 1, year = os.date("%Y", time) })
    local firstYearDate = os.date("*t", firstYearTime)
    local date = os.date("*t", time)
    local start_wday = firstYearDate.wday - 1
    local yday = date.yday
    if (start_wday + yday) % 7 == 0 then
        return (start_wday + yday) / 7
    else
        return NumberUtil.getIntPart((start_wday + yday) / 7) + 1
    end
end

function DateUtil.getYearDay(time)
    if time == nil then
        time = os.time()
    end
    return os.date("%Y", time) .. os.date("*t", time).yday
end

function DateUtil.getDate(time)
    if time == nil then
        time = os.time()
    end
    return os.date("%Y-%m-%d", time)
end

function DateUtil.getDateString(time)
    if time == nil then
        time = os.time()
    end
    return os.date("%Y-%m-%d %X", time)
end

function DateUtil.getWeekLastTime(time)
    if time == nil then
        time = os.time()
    end
    time = time - (time % 86400) - 28800
    local date = os.date("*t", time)
    local wday = date.wday
    time = time + (7 - wday + 1) * 86400
    return time + 1800
end

function DateUtil.getDayLastTime(time)
    if time == nil then
        time = os.time()
    end
    time = time - (time % 86400) + 86400 - 28800
    return time + 1800
end

function DateUtil.getWeekSeconds()
    return 604800
end

return DateUtil