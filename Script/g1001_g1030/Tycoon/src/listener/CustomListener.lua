---
--- Created by Jimmy.
--- DateTime: 2018/6/8 0008 11:51
---
CustomListener = {}

function CustomListener:init()
    CustomTipMsgEvent.registerCallBack(self.onCustomTipMsg)
    ConsumeDiamondsEvent.registerCallBack(self.onConsumeDiamonds)
end

function CustomListener.onCustomTipMsg(rakssid, extra, isRight)
    if isRight == false then
        return
    end
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return
    end

    local extras = StringUtil.split(extra, "=")
    if #extras ~= 2 then
        return
    end

    if extras[1] == "ExtraPortal" then
        local npc = GameManager:getNpcByEntityId(tonumber(extras[2]))
        if npc then
            npc:onPlayerSelected(player)
        end
        return
    end

    if extras[1] == "Single" then
        player:unlockOccupation(extra)
        return
    end

    if extras[1] == "Perpetual" then
        player:unlockOccupation(extra)
        return
    end

    local npc = GameManager:getNpcByEntityId(tonumber(extras[2]))
    if npc then
        if npc.curSelectNum >= npc.selectedMaxNum then
            MsgSender.sendCenterTipsToTarget(player.rakssid, 3, Messages:msgHeroHasBeenChosen())
            return
        end

        npc:selectOccupation(player)
        return
    end

    if extras[1] == "Occupation" then
        MsgSender.sendCenterTipsToTarget(player.rakssid, 3, Messages:msgHeroHasBeenChosen())
        return
    end

end

function CustomListener.onConsumeDiamonds(rakssid, isSuccess, message, extra, payId)
    if isSuccess == false then
        EngineUtil.disposePlatformOrder(0, payId, false)
        return
    end

    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        EngineUtil.disposePlatformOrder(0, payId, false)
        return
    end

    local extras = StringUtil.split(extra, "=")
    if #extras ~= 2 then
        EngineUtil.disposePlatformOrder(player.userId, payId, false)
        return
    end

    local npc = GameManager:getNpcByEntityId(tonumber(extras[2]))
    if npc == nil then
        EngineUtil.disposePlatformOrder(player.userId, payId, false)
        MsgSender.sendCenterTipsToTarget(player.rakssid, 3, Messages:msgHeroHasBeenChosen())
        return
    end

    if npc.curSelectNum >= npc.selectedMaxNum then
        EngineUtil.disposePlatformOrder(player.userId, payId, false)
        MsgSender.sendCenterTipsToTarget(player.rakssid, 3, Messages:msgHeroHasBeenChosen())
        return
    end

    if extras[1] == "Single" then
        EngineUtil.disposePlatformOrder(player.userId, payId, true)
        npc:selectOccupation(player)
        return
    end

    if extras[1] == "Perpetual" then
        EngineUtil.disposePlatformOrder(player.userId, payId, true)
        player:addsupOccIds(npc.config.id)
        npc:selectOccupation(player)
        return
    end

end

return CustomListener
--endregion
