---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Jimmy.
--- DateTime: 2019/1/8 0008 14:15
---
SeasonManager = {}
SeasonManager.UserSeasonInfoCache = {}
SeasonManager.WaitSaveHonorCache = {}

function SeasonManager:addUserHonor(userId, honor, level)
    table.insert(self.WaitSaveHonorCache, {
        userId = tonumber(tostring(userId)),
        honor = honor,
        level = (level or 1)
    })
end

function SeasonManager:trySaveHonorResult()
    if #self.WaitSaveHonorCache == 0 then
        return
    end
    local data = {}
    for _, cache in pairs(self.WaitSaveHonorCache) do
        table.insert(data, {
            userId = cache.userId,
            integral = cache.honor,
            level = cache.level,
            gameId = BaseMain:getGameType()
        })
    end
    self.WaitSaveHonorCache = {}
    WebService:SaveBlockymodsUsersHonor(data)
end

return SeasonManager