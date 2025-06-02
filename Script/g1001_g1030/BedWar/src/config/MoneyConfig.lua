---
--- Created by Jimmy.
--- DateTime: 2017/11/21 0021 10:52
---
MoneyConfig = {}
MoneyConfig.money = {}
MoneyConfig.publicMoney = {}
MoneyConfig.coinMapping = {}

function MoneyConfig:init(config)
    for i, v in pairs(config) do
        local money = {}
        for j, item in pairs(v) do
            local key = tostring(item.id)
            money[key] = {}
            money[key].id = tonumber(item.id)
            money[key].time = tonumber(item.time)
            money[key].num = tonumber(item.num)
            money[key].life = tonumber(item.life)
        end
        self.money[i] = money
    end
end

function MoneyConfig:initPublicMoney(publicMoney)
    for i, v in pairs(publicMoney) do
        self.publicMoney[i] = {}
        self.publicMoney[i].pos = VectorUtil.newVector3(v.x, v.y, v.z)
        self.publicMoney[i].upgradeId = tonumber(v.upgradeId)
        self.publicMoney[i].id = tonumber(v.id)
        self.publicMoney[i].level = 1
    end
end

function MoneyConfig:initCoinMapping(coinMapping)
    for i, v in pairs(coinMapping) do
        self.coinMapping[i] = {}
        self.coinMapping[i].coinId = v.coinId
        self.coinMapping[i].itemId = v.itemId
    end
end

function MoneyConfig:getPublicMoneyByUpgradeId(upgradeId)
    for i, v in pairs(self.publicMoney) do
        if v.upgradeId == upgradeId then
            return v
        end
    end
    return nil
end

function MoneyConfig:getMoneyItem(lv, id)
    local m = self.money[lv]
    if m == nil then
        m = self.money[1]
    end
    local data = m[tostring(id)]
    if data == nil then
        for i, v in pairs(m) do
            data = v
            break
        end
    end
    return data
end


return MoneyConfig