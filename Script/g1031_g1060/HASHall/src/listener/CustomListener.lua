---
--- Created by longxiang.
--- DateTime: 2018/11/9  16:15
---
CustomListener = {}

function CustomListener:init()
    CustomTipMsgEvent.registerCallBack(self.onCustomTipMsg)
    ConsumeTipMsgEvent.registerCallBack(self.onConsumeTipMsg)
end

function CustomListener.onCustomTipMsg(rakssid, extra, isRight)
    CustomListener.onTipMsg(rakssid, extra, isRight)
end


function CustomListener.onConsumeTipMsg(rakssid, extra, isRight)
    CustomListener.onTipMsg(rakssid, extra, isRight)
end

function CustomListener.onTipMsg(rakssid, extra, isRight)
    if isRight == false then
        return
    end
    
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return
    end

    local extras = StringUtil.split(extra, "=")
    if extras[1] == "Tip" and extras[2] ~= nil then
        local npc = GameManager:getNpcByEntityId(tonumber(extras[2]))

        if npc then
            npc:onPlayerSelected(player)
        end
    end
end

return CustomListener
--endregion
