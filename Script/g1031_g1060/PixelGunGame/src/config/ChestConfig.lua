---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2019/1/2 11:11
---

ChestConfig = {}

ChestConfig.chests = {}

function ChestConfig:init(config)
    for index, v in pairs(config) do
        local chest = {}
        local i = tonumber(index)
        chest.id = tonumber(v.chestId)
        chest.money = tonumber(v.money)
        chest.des = v.description
        self.chests[i] = chest
    end
end

function ChestConfig:getMoneyList()
    local money = {}
    for i, v in pairs(self.chests) do
        money[i] = v.money
    end
    return money
end

function ChestConfig:getDesById(id)
    for i, v in pairs(self.chests) do
        if id == v.id then
            return v.des
        end
    end
end

function ChestConfig:getChestById(id)
    for i, v in pairs(self.chests) do
        if id == v.id then
            return v
        end
    end
end

function ChestConfig:getChestMoneyById(id)
    for i, v in pairs(self.chests) do
        if id == v.id then
            return v.money
        end
    end
    return 0
end

return ChestConfig