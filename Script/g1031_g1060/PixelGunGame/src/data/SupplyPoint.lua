require "data.EventCallback"

SupplyPoint = class()

SupplyPointStatus = {
    DISENABLE_STATUS = 0,
    WAIT_RECEIVE_STATUS = 1,
    INTERVAL_STATUS = 2
}

function SupplyPoint:ctor(config)
    self.SupplyId = config.SupplyId
    self.SupplyPos = config.SupplyPos
    self.SupplyRange = config.SupplyRange
    self.SupplyItemTab = config.SupplyItemTab
    self.SupplyItemValue = config.SupplyItemValue
    self.RefreshInterval = config.RefreshInterval
    self.currentSupplyItemId = nil
    self.currentSupplyItemValue = 0
    self.status = SupplyPointStatus.DISENABLE_STATUS
    self.ReceiveSupplyCallback = nil
    self.RandomItemCallback = nil
    self.entityId = 0
end

function SupplyPoint:GetSupplyId()
    return self.SupplyId
end

function SupplyPoint:RegisterRandomItemCallback(callback, obj)
    self.RandomItemCallback = EventCallback.new(callback, obj)
end

function SupplyPoint:RegisterReceiveSupplyCallback(callback, obj)
    self.ReceiveSupplyCallback = EventCallback.new(callback, obj)
end

function SupplyPoint:Update()
    if self.status ~= SupplyPointStatus.WAIT_RECEIVE_STATUS then
        return
    end
    local players = PlayerManager:getPlayers()
    for _, player in pairs(players) do
        if self:CheckTrigger(player) then
            self:OnReceiveDone(player)
            break
        end
    end
end

function SupplyPoint:CheckTrigger(player)
    if player == nil then
        return false
    end
    local pos = player:getPosition()
    if pos.x or pos.y or pos.z then
        if math.abs(pos.y - self.SupplyPos.y) <= self.SupplyRange then
            local curDistance = (math.abs(pos.x - self.SupplyPos.x) ^ 2) + (math.abs(pos.z - self.SupplyPos.z) ^ 2)
            return math.sqrt(curDistance) <= self.SupplyRange
        end
    end
    return false
end

function SupplyPoint:RandomItem()
    if self.currentSupplyItemId == nil then
        local maxNum = #self.SupplyItemTab
        local randomindex = math.random(1, maxNum)
        local itemid = self.SupplyItemTab[randomindex]
        local itemval = self.SupplyItemValue[randomindex]
        self.currentSupplyItemId = itemid
        self.currentSupplyItemValue = itemval
        local pos = VectorUtil.newVector3(self.SupplyPos.x, self.SupplyPos.y + 1, self.SupplyPos.z)
        self.entityId = EngineWorld:addEntityItem(self.currentSupplyItemId, self.currentSupplyItemValue, 0, 1000, pos, VectorUtil.ZEOR, true, true)
        self.status = SupplyPointStatus.WAIT_RECEIVE_STATUS
        if type(self.RandomItemCallback) == "table" then
            self.RandomItemCallback:Invoke(self.SupplyId, self.currentSupplyItemId)
        end
    end
end

function SupplyPoint:OnReceiveDone(player)
    if self.currentSupplyItemId == nil and self.currentSupplyItemValue > 0 then
        return
    end
    SupplyUtil:onPlayerPickup(self.currentSupplyItemId, self.currentSupplyItemValue, player)
    HostApi.notifyGetItem(player.rakssid, self.currentSupplyItemId, 0, self.currentSupplyItemValue)

    if self.entityId ~= 0 then
        EngineWorld:removeEntity(self.entityId)
        self.entityId = 0
    end

    self.currentSupplyItemId = 0
    self.currentSupplyItemValue = 0

    if type(self.ReceiveSupplyCallback) == "table" then
        self.ReceiveSupplyCallback:Invoke(self.SupplyId, player, self.currentSupplyItemId, self.RefreshInterval)
    end
    self.currentSupplyItemId = nil
    self.status = SupplyPointStatus.INTERVAL_STATUS
end
