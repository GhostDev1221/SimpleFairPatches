--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

MsgSender = {}

function MsgSender.sendMsg(msg, args)
    MsgSender.sendMsgToTarget(0, msg, args)
end

function MsgSender.sendMsgToTarget(rakssid, msg, args)
    if (msg == nil) then
        HostApi.log("Msg.sendMsg  is nil msg")
        return
    end

    if type(msg) == "number" then
        HostApi.broadCastMsgByType(rakssid, 0, 5, msg, args or "")
    else
        HostApi.broadCastMsg(rakssid, 0, 5, msg)
    end
end

function MsgSender.sendTopTips(time, msg, args)
    MsgSender.sendTopTipsToTarget(0, time, msg, args)
end

function MsgSender.sendTopTipsToTarget(rakssid, time, msg, args)
    if (msg == nil) then
        HostApi.log("Msg.sendTopTips  is nil msg")
        return
    end

    if type(msg) == "number" then
        HostApi.broadCastMsgByType(rakssid, 1, time, msg, args or "")
    else
        HostApi.broadCastMsg(rakssid, 1, time, msg)
    end
end

function MsgSender.sendBottomTips(time, msg, args)
    MsgSender.sendBottomTipsToTarget(0, time, msg, args)
end

function MsgSender.sendBottomTipsToTarget(rakssid, time, msg, args)
    if (msg == nil) then
        HostApi.log("Msg.sendBottomTips  is nil msg")
        return
    end

    if type(msg) == "number" then
        HostApi.broadCastMsgByType(rakssid, 2, time, msg, args or "")
    else
        HostApi.broadCastMsg(rakssid, 2, time, msg)
    end
end

function MsgSender.sendCenterTips(time, msg, args)
    MsgSender.sendCenterTipsToTarget(0, time, msg, args)
end

function MsgSender.sendCenterTipsToTarget(rakssid, time, msg, args)
    if (msg == nil) then
        HostApi.log("Msg.sendCenterTips  is nil msg")
        return
    end

    if type(msg) == "number" then
        HostApi.broadCastMsgByType(rakssid, 3, time, msg, args or "")
    else
        HostApi.broadCastMsg(rakssid, 3, time, msg)
    end
end

function MsgSender.sendOtherTips(time, msg, args)
    MsgSender.sendOtherTipsToTarget(0, time, msg, args)
end

function MsgSender.sendOtherTipsToTarget(rakssid, time, msg, args)
    if (msg == nil) then
        HostApi.log("Msg.sendOtherTips is nil msg")
        return
    end

    if type(msg) == "number" then
        HostApi.broadCastMsgByType(rakssid, 4, time, msg, args or "")
    else
        HostApi.broadCastMsg(rakssid, 4, time, msg)
    end
end

function MsgSender.sendKillMsg(killer, dead, armsId, kills, head, color)
    MsgSender.sendKillMsgToTarget(0, killer, dead, armsId, kills, head, color)
end

function MsgSender.sendKillMsgToTarget(rakssid, killer, dead, armsId, kills, head, color)
    if type(killer) ~= "string" or type(dead) ~= "string" or type(color) ~= "string"
    or type(armsId) ~= "number" or type(kills) ~= "number" or type(head) ~= "number" then
        HostApi.log("[Error] Msg.sendKillMsg:incorrect parameter type")
        return
    end
    local data = {}
    data.killer = killer
    data.dead = dead
    data.armsId = armsId
    data.kills = kills
    data.head = head
    data.color = color
    HostApi.sendKillMsg(rakssid, json.encode(data))
end

return MsgSender

--endregion
