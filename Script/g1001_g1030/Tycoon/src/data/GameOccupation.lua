---
--- Created by Jimmy.
--- DateTime: 2017/12/25 0025 11:54
---
require "config.DomainConfig"

GameOccupation = class()

function GameOccupation:ctor(domain, initPos, yaw, config, effect)
    self.id = config.id
    self.config = config
    self.effect = effect
    self.selectedMaxNum = GameConfig.occSelectMaxNum
    self.curSelectNum = 0
    self.initPos = initPos
    self.yaw = yaw
    self.domainConfig = domain
    self.domains = {}
    self.players = {}
    self:onCreate()
end

function GameOccupation:onCreate()
    self.entityId = EngineWorld:addActorNpc(self.initPos, self.yaw, self.config.actor, self.config.name, "idle", self.effect)
    GameManager:onAddOccupation(self)
end

function GameOccupation:onPlayerHit(player)
    self:onPlayerSelected(player, true)
end

function GameOccupation:onPlayerSelected(player, isHitByPlayer)
    local canSelect = false
    for _, id in pairs(player.baseOccIds) do
        if tonumber(id) == tonumber(self.config.id) then
            canSelect = true
        end
    end
    for _, id in pairs(player.supOccIds) do
        if tonumber(id) == tonumber(self.config.id) then
            canSelect = true
        end
    end
    for _, id in pairs(player.occGiftPack_common) do
        if tonumber(id) == tonumber(self.config.id) then
            canSelect = true
        end
    end
    if player.giftpackOccIds then
        canSelect = true
    end

    if player.occupationId ~= 0 then
        MsgSender.sendCenterTipsToTarget(player.rakssid, 3, Messages:hasDomainHint())
        return
    end

    if self.curSelectNum >= self.selectedMaxNum then
        MsgSender.sendCenterTipsToTarget(player.rakssid, 3, Messages:msgHeroHasBeenChosen())
        return
    end

    if canSelect == false then
        self:sendOccupationUnlock(player)
        return
    end

    if isHitByPlayer == true then
        HostApi.sendCustomTip(player.rakssid, self.config.hint, "Occupation=" .. tostring(self.entityId))
    else
        self:selectOccupation(player)
    end
end

function GameOccupation:resetOcc(player)
    for i, id in pairs(self.players) do
        if id == player.rakssid then
            table.remove(self.players, i)
            table.remove(self.domains, i)
            self.curSelectNum = self.curSelectNum - 1
            self:onCreate()
        end
    end
end

function GameOccupation:onRemove()
    EngineWorld:removeEntity(self.entityId)
    GameManager:onRemoveOccupation(self)
end

function GameOccupation:selectOccupation(player)
    self.curSelectNum = self.curSelectNum + 1
    self.players[self.curSelectNum] = player.rakssid
    self.domains[self.curSelectNum] = GameDomain.new(self, self.domainConfig, DomainConfig:getMaxBuildValue())
    self.domains[self.curSelectNum]:onPlayerSelect(player)
    if self.curSelectNum >= self.selectedMaxNum then
        self:onRemove()
    end
end

function GameOccupation:sendOccupationUnlock(player)
    local orientations = {}
    orientations[1] = ""
    orientations[2] = ""
    orientations[3] = ""

    local info = {
        id = tonumber(self.config.id),
        entityId = tonumber(self.entityId),
        name = self.config.name,
        actorName = self.config.actor,
        singlePrice = 1,
        perpetualPrice = 1,
        singleCurrencyType = 1,
        perpetualCurrencyType = 1,
        radarIcon = "set:tycoon_unlock.json image:radar_doctorstrange",
        orientations = orientations,
    }

    local unlockOccupationInfo = OccupationConfig:getUnlockOccupationInfoById(self.config.id)
    if unlockOccupationInfo ~= nil then
        info.singlePrice = unlockOccupationInfo.singlePrice
        info.perpetualPrice = unlockOccupationInfo.perpetualPrice
        info.singleCurrencyType = unlockOccupationInfo.singleCurrencyType
        info.perpetualCurrencyType = unlockOccupationInfo.perpetualCurrencyType
        info.radarIcon = unlockOccupationInfo.radarIcon
        if unlockOccupationInfo.orientations1 ~= "#" then
            info.orientations[1] = unlockOccupationInfo.orientations1
        end

        if unlockOccupationInfo.orientations2 ~= "#" then
            info.orientations[2] = unlockOccupationInfo.orientations2
        end

        if unlockOccupationInfo.orientations3 ~= "#" then
            info.orientations[3] = unlockOccupationInfo.orientations3
        end
    end

    HostApi.sendOccupationUnlock(player.rakssid, json.encode(info))
end