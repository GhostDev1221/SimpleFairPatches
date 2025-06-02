require "config.SupplyConfig"
require "data.SupplyPoint"

SupplyManager = {}

function SupplyManager:InitSupplyPoint(maxSupplyNum)
    self.supplyObjectTable = {}
    self.enableSupply = {}
    local configs = SupplyConfig:GetConfigs()
    for k, config in pairs(configs) do
        local supply = SupplyPoint.new(config)
        supply:RegisterRandomItemCallback(self.OnRandomItem, self)
        supply:RegisterReceiveSupplyCallback(self.OnSupplyReceive, self)
        table.insert(self.supplyObjectTable, supply)
    end
    self.maxNumber = maxSupplyNum or #self.supplyObjectTable
    LuaTimer:schedule(self.Update, nil, 1, self)
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    for index = 1, self.maxNumber do
        self:RandomSupplyItem()
    end
end

function SupplyManager:RandomSupplyItem()
    local index = self:RandomNumber()
    if type(index) == "number" then
        local supply = self.supplyObjectTable[index]
        if type(supply) == "table" then
            supply:RandomItem()
        end
    end
end

--当补给点被拾取的时候调用  参数是补给点Id  拾取的玩家  拾取的物品Id
function SupplyManager:OnSupplyReceive(supplyId, player, receiveItemId, delayTime)
    self.enableSupply[supplyId] = nil
    LuaTimer:schedule(self.RandomSupplyItem, delayTime, nil, self)
    --TODO
end
-- 当补给点 随机物品之后调用 参数是补给点id  和随机的物品的id
function SupplyManager:OnRandomItem(supplyId, itemId)
    if supplyId == nil then
        return
    end
    self.enableSupply[supplyId] = true
end

function SupplyManager:Update()
    for _, supply in pairs(self.supplyObjectTable) do
        if type(supply.Update) == "function" then
            supply:Update()
        end
    end
end

function SupplyManager:RandomNumber()
    local maxNum = #self.supplyObjectTable
    if maxNum == 0 then
        return nil
    end
    local randNum = math.random(1, maxNum)
    local supply = self.supplyObjectTable[randNum]
    local times = 3
    if type(supply) == "table" then
        while self.enableSupply[supply:GetSupplyId()] and times > 0 do
            randNum = math.random(1, maxNum)
            supply = self.supplyObjectTable[randNum]
        end
        times = times - 1
        return randNum
    end
    return nil
end
