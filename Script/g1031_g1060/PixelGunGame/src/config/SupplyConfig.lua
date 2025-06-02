require "base.util.VectorUtil"
require "base.util.StringUtil"
SupplyConfig = {}

local supplyConfigs = {}

function SupplyConfig:init(configs)
    for id, config in pairs(configs) do
        local supply = self:NewSupply(config)
        table.insert(supplyConfigs, supply)
    end
end

local function ParsePosition(str)
    local tab = StringUtil.split(str, "#")
    local x = tonumber(tab[1]) or 0
    local y = tonumber(tab[2]) or 0
    local z = tonumber(tab[3]) or 0
    return VectorUtil.newVector3i(x, y, z)
end

local function ParseItemTab(str)
    local res = StringUtil.split(str, "#")
    local tab = {}
    for i, id in ipairs(res) do
        local itemid = tonumber(id)
        if type(itemid) == "number" then
            table.insert(tab, itemid)
        end
    end
    return tab
end

local function ParseItemValue(str)
    local res = StringUtil.split(str, "#")
    local val = {}
    for i, v in ipairs(res) do
        local value = tonumber(v)
        if type(value) == "number" then
            table.insert(val, value)
        end
    end
    return val
end

function SupplyConfig:NewSupply(config)
    local tab = 
    {
        SupplyId = tonumber(config.SupplyId),
        SupplyPos = ParsePosition(config.SupplyPos),
        SupplyRange = tonumber(config.SupplyRange),
        SupplyItemTab = ParseItemTab(config.SupplyItemTab),
        SupplyItemValue = ParseItemValue(config.SupplyValue),
        RefreshInterval = tonumber(config.RefreshInterval)
    }
    return tab
end

function SupplyConfig:GetConfigs()
    return supplyConfigs
end
