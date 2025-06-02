---
--- Created by Jimmy.
--- DateTime: 2018/5/29 0029 11:15
---
UserInfoCache = {}
UserInfoCache.caches = {}

function UserInfoCache:FilterExistedUserId(userIds)
    local ids = {}
    for i, userId in pairs(userIds) do
        if self.caches[tostring(userId)] == nil then
            table.insert(ids, userId)
        end
    end
    return ids
end

function UserInfoCache:GetCacheByUserIds(userIds, func, key, ...)
    local ids = self:FilterExistedUserId(userIds)
    if #ids == 0 then
        func(...)
        return
    end
    WebResponse:registerCallBack(function(data, func, ...)
        if data ~= nil then
            for i, item in pairs(data) do
                local info = {}
                info.userId = item.userId
                info.vip = item.vip
                info.name = item.name
                self.caches[tostring(item.userId)] = info
            end
        end
        func(...)
    end, WebService:GetBlockymodsUserInfos(ids, key), func, ...)
end

function UserInfoCache:GetCache(userId)
    return self.caches[tostring(userId)]
end

return UserInfoCache