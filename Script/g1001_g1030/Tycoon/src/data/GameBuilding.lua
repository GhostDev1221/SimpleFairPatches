---
--- Created by Jimmy.
--- DateTime: 2018/7/10 0010 13:43
---
GameBuilding = class()

function GameBuilding:ctor(domain, config)
    self.domain = domain
    self.config = config
    self.entityId = 0
    self:onCreate()
end

function GameBuilding:onCreate()
    if self.config.name == "#" then
        self.config.name = ""
    end
    local name = self.config.name .. "=($" .. self.config.price .. ")"
    local pos = BasicConfig:getPosByBasic(self.domain.basicId, self.config.npcPos)
    local yaw = BasicConfig:getYawByBasic(self.domain.basicId, self.config.npcYaw)
    self.entityId = EngineWorld:addActorNpc(pos, yaw, self.config.npcActor, name, "idle")
    self.domain:addBuildingNpcRecord(self.config.id)
    GameManager:onAddBuilding(self)
end

function GameBuilding:isSamePlayer(player)
    return self.domain.player == player
end

function GameBuilding:onPlayerHit(player)
    if self:isSamePlayer(player) == false then
        MsgSender.sendCenterTipsToTarget(player.rakssid, 2, Messages:noSelfItem())
        return
    end
    local price = self.config.price
    local money = player:getCurrency()
    if price <= money then
        player:subCurrency(price)
        self:onRemove()
        self:buildBuilding()
    else
        MsgSender.sendCenterTipsToTarget(player.rakssid, 1, Messages:noMoney())
    end
end

function GameBuilding:buildBuilding()
    local pos = BasicConfig:getPosViByBasic(self.domain.basicId, self.config.startPos)
    local xImage, zImage = BasicConfig:getXandZImageByBasics(self.domain.basicId)
    EngineWorld:getWorld():createOrDestroyHouseFromSchematic(self.config.fileName, pos, xImage, zImage, true)
    self:rewardLadders(self.config)
    self.domain:addBuildingRecord(self.config.id)
    self.domain:addBuildProgress(self.config.value)
    self.domain:checkBuildings()
end

function GameBuilding:onRemove()
    EngineWorld:removeEntity(self.entityId)
    GameManager:onRemoveBuilding(self)
end

function GameBuilding:rewardLadders(item)
    if self.domain.player == nil then
        return
    end
    if self.config.rewardNum ~= 0 then
        MsgSender.sendCenterTipsToTarget(self.domain.player.rakssid, 1, Messages:rewradLadder())
        self.domain.player:addItem(item.rewardId, item.rewardNum, item.rewardMeta)
    else
        MsgSender.sendCenterTipsToTarget(self.domain.player.rakssid, 1, Messages:buildsucceed())
    end
end

return GameBuilding