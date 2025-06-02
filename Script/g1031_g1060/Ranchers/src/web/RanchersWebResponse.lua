RanchersWebResponse = {}
RanchersWebResponse.callbacks = {}
RanchersWebResponse.count = {}

function RanchersWebResponse:registerCallBack(func, marked, ...)
    assert(type(marked) == "string")
    assert(func ~= nil)
    self:unregisterCallBack(marked)
    self.callbacks[marked] = { func, ... }
end

function RanchersWebResponse:unregisterCallBack(marked)
    if self.callbacks[marked] ~= nil then
        self.callbacks[marked] = nil
    end
end

function RanchersWebResponse:onCallFunc(data, marked, ...)
    if self.callbacks[marked] ~= nil then
        self.callbacks[marked][1](data, unpack(self.callbacks[marked], 2), ...)
    end
    self:unregisterCallBack(marked)
end

function RanchersWebResponse:onReceiveLand(result, marked)
    result = WebResponse:formatResultCode(result)
    local userId = StringUtil.split(marked, ":")[2]
    local player = PlayerManager:getPlayerByUserId(userId)
    if player == nil then
        return false
    end
    if result ~= "{}" then
        local resultJson = json.decode(result)
        if resultJson.code == 1 then
            HostApi.sendCallOnManorResetClient(player.rakssid, player.userId)
        elseif resultJson.code == 2019 then
            HostApi.sendCommonTip(player.rakssid, "ranch_tip_already_has_monor")
        else
            HostApi.log("[error] RanchersWebResponse:onReceiveLand: code = " .. resultJson.code)
            HostApi.sendCommonTip(player.rakssid, "ranch_tip_get_manor_fail")
        end
    else
        HostApi.sendCommonTip(player.rakssid, "ranch_tip_get_manor_fail")
        HostApi.log("=== LuaLog: [error] RanchersWebResponse:onReceiveLand:["..tostring(userId).."] filed to get land ... ")
    end
end

function RanchersWebResponse:onCheckHasLand(result, marked)
    result = WebResponse:formatResultCode(result)
    if result ~= "{}" then
        local r = json.decode(result)
        if r.code == 1 then
            if r.data ~= nil and r.data.id ~= nil then
                self:onCallFunc(r.data, marked)
            else
                self:onCallFunc(nil, marked)
            end
            self:setCountDataToNull(marked)
        elseif r.code == 11 then
            self:onCallFunc(nil, marked)
            self:setCountDataToNull(marked)
            HostApi.log("RanchersWebResponse:onCheckHasLand: code = " .. r.code)
        else
            local userId = StringUtil.split(marked, ":")[2]
            HostApi.log("[error] RanchersWebResponse:onCheckHasLand: code = " .. r.code)
            local log = "[error] RanchersWebResponse:onMyHelpList: player["..tostring(userId).."] http error : remain count :"
            self:retryRequest(marked, function()
                RanchersWeb:checkHasLand(userId)
            end, function()
                self:onCallFunc(nil, marked)
            end, log)
        end

        return true
    end

    self:onCallFunc(nil, marked)
end

function RanchersWebResponse:onUpdateLandInfo(result, marked)
    result = WebResponse:formatResult(result)
    local userId = StringUtil.split(marked, ":")[2]
    if result ~= "{}" then
        -- 成功了什么都不做，只管发送
    else
        HostApi.log("=== LuaLog: [error] RanchersWebResponse:onUpdateLandInfo:["..tostring(userId).."] filed to update land info ... ")
    end
end

function RanchersWebResponse:onAskForHelp(result, marked)
    result = WebResponse:formatResult(result)
    local userId = StringUtil.split(marked, ":")[2]
    local player = PlayerManager:getPlayerByUserId(userId)
    if player == nil then
        return false
    end
    if result ~= "{}" then
        RanchersWeb:myHelpList(userId)
        HostApi.sendCommonTip(player.rakssid, "ranch_tip_ask_for_help_success")
    else
        HostApi.sendCommonTip(player.rakssid, "ranch_tip_ask_for_help_fail")
        RanchersWeb:myHelpList(userId)
        HostApi.log("[error] RanchersWebResponse:onAskForHelp:["..tostring(userId).."] filed to ask for help ... ")
    end
end

function RanchersWebResponse:onFinishHelp(result, marked)
    result = WebResponse:formatResultCode(result)
    local userId = StringUtil.split(marked, ":")[2]
    local player = PlayerManager:getPlayerByUserId(userId)
    if player == nil then
        self:onCallFunc(nil, marked)
        return false
    end

    if result ~= "{}" then
        local resultJson = json.decode(result)
        if resultJson.code == 1 then
            self:onCallFunc(resultJson, marked)
        elseif resultJson.code == 13 then
            self:onCallFunc(nil, marked)
            HostApi.sendRanchOrderHelpResult(player.rakssid, "ranch_tip_somebody_already_finish_help")
            RanchersWeb:myHelpList(userId)
        else
            HostApi.log("[error] RanchersWebResponse:onFinishHelp: code = " .. resultJson.code)
            self:onCallFunc(nil, marked)
            HostApi.sendRanchOrderHelpResult(player.rakssid, "ranch_tip_something_error")
            RanchersWeb:myHelpList(userId)
            HostApi.log("[error] RanchersWebResponse:onFinishHelp:["..userId.."] filed to finish help code["..resultJson.code.."] ")
        end
        return true
    end

    self:onCallFunc(nil, marked)
end

function RanchersWebResponse:onHelpList(result, marked)
    result = WebResponse:formatResult(result)
    local data = WebResponse:formatData(result)
    local userId = StringUtil.split(marked, ":")[2]
    local player = PlayerManager:getPlayerByUserId(userId)
    if player == nil then
        return false
    end

    if data ~= nil then
        for i, usersInfo in pairs(data) do
            for j, info in pairs(usersInfo) do
                local item = {}
                item.id = info.id
                item.userId = info.userId
                item.uniqueId = info.uniqueId
                item.orderId = info.orderId
                item.boxId = info.boxId
                item.isHot = info.isHot
                item.itemId = info.itemId
                item.itemCount = info.itemCount
                item.helperId = info.helperId
                item.helperName = info.helperName
                item.helperSex = info.helperSex
                item.boxAmount = info.boxAmount
                item.fullBoxNum = info.fullBoxNum
            end
        end

    else
        HostApi.log("[error] RanchersWebResponse:onHelpList:["..tostring(userId).."] data is nil")
    end
end

function RanchersWebResponse:onHelpListById(result, marked)
    result = WebResponse:formatResult(result)
    local data = WebResponse:formatData(result)
    local userId = StringUtil.split(marked, ":")[2]
    local player = PlayerManager:getPlayerByUserId(userId)
    if player == nil then
        self:onCallFunc(nil, marked)
        return false
    end
    if data ~= nil and data.id ~= nil then
        local item = {}
        item.id = data.id
        item.userId = data.userId
        item.uniqueId = data.uniqueId
        item.orderId = data.orderId
        item.boxId = data.boxId
        item.itemId = data.itemId
        item.itemCount = data.itemCount
        item.isHot = data.isHot
        item.helperId = data.helperId
        item.helperName = data.helperName
        item.helperSex = data.helperSex
        item.boxAmount = data.boxAmount
        item.fullBoxNum = data.fullBoxNum

        self:onCallFunc(item, marked)
        return true
    end
    self:onCallFunc(nil, marked)
    HostApi.sendCommonTip(player.rakssid, "ranch_tip_something_error")
    HostApi.log("[error] RanchersWebResponse:onHelpListById:["..tostring(userId).."] data is nil")
end

function RanchersWebResponse:onMyHelpList(result, marked)
    result = WebResponse:formatResultCode(result)
    local userId = StringUtil.split(marked, ":")[2]
    local player = PlayerManager:getPlayerByUserId(userId)
    if player == nil then
        return false
    end

    if result ~= "{}" then
        local resultJson = json.decode(result)
        if resultJson.code == 1 then
            if resultJson.data ~= nil then
                local items = {}
                for i, v in pairs(resultJson.data) do
                    if v.orderId ~= nil then
                        local item = {}
                        item.uniqueId = v.uniqueId
                        item.askForHelpId = v.id
                        item.userId = v.userId
                        item.orderId = tonumber(v.orderId)
                        item.boxId = v.boxId
                        item.helperId = v.helperId
                        item.helperName = v.helperName
                        item.helperSex = v.helperSex
                        item.itemId = tonumber(v.itemId)
                        item.count = v.itemCount
                        item.isHot = v.isHot
                        item.boxAmount = v.boxAmount
                        item.fullBoxNum = v.fullBoxNum
                        items[i] = item
                    end
                end

                if player.task ~= nil then
                    player.task:updateTasksListFromHttp(items)
                    local ranchTask = player.task:initRanchTask()
                    player:getRanch():setOrders(ranchTask)
                end

                self:setCountDataToNull(marked)
            end
        else
            HostApi.log(" RanchersWebResponse:onMyHelpList : code = ".. resultJson.code)
            local log = "[error] RanchersWebResponse:onMyHelpList: player["..tostring(userId).."] http error : remain count :"
            self:retryRequest(marked, function()
                RanchersWeb:myHelpList(userId)
            end, function()
                -- do nothing
            end, log)
        end
    end
end

function RanchersWebResponse:onFinishOrder(result, marked)
    result = WebResponse:formatResult(result)
    local userId = StringUtil.split(marked, ":")[2]
    if result ~= "{}" then
        -- 成功了什么都不做，只管发送
        HostApi.log("RanchersWebResponse:onFinishOrder: success ")
    else
        HostApi.log("=== LuaLog: [error] RanchersWebResponse:onFinishOrder: ["..tostring(userId).."] filed to finish order ... ")
    end
end

function RanchersWebResponse:onUpdateOrder(result, marked)
    result = WebResponse:formatResult(result)
    local userId = StringUtil.split(marked, ":")[2]
    if result ~= "{}" then
        -- 成功了什么都不做，只管发送
        HostApi.log("RanchersWebResponse:onUpdateOrder: success ")
    else
        HostApi.log("=== LuaLog: [error] RanchersWebResponse:onUpdateOrder: ["..tostring(userId).."] filed to update order ... ")
    end
end

function RanchersWebResponse:onGiftSend(result, marked)
    result = WebResponse:formatResultCode(result)
    if result ~= "{}" then
        local resultJson = json.decode(result)
        self:onCallFunc(resultJson.data, marked, resultJson.code)
        return true
    end
    HostApi.log("=== [error]RanchersWebResponse:onGiftSend : result = " .. tostring(result))
    self:onCallFunc(nil, marked, 0)
end

function RanchersWebResponse:onCheckLandsInfo(result, marked)
    result = WebResponse:formatResult(result)
    local data = WebResponse:formatData(result)
    if data ~= nil then
        self:onCallFunc(data, marked)
        return true
    end

    self:onCallFunc(nil, marked)
end

function RanchersWebResponse:onSendInvitation(result, marked)
    result = WebResponse:formatResultCode(result)
    if result ~= "{}" then
        local resultJson = json.decode(result)
        self:onCallFunc(resultJson.code, marked)
        return true
    end

    self:onCallFunc(nil, marked)
end

function RanchersWebResponse:onClanProsperity(result, marked)
    result = WebResponse:formatResult(result)
    local data = WebResponse:formatData(result)
    if data ~= nil then
        local items = {}
        for i, v in pairs(data) do
            local item = {}
            item.clanId = 0
            item.rank = 0
            item.maxCount = 0
            item.userCount = 0
            item.prosperity = 0
            item.name = ""
            item.headPic = ""

            if v.clanId ~= nil then
                item.clanId = v.clanId
            end

            if v.rank ~= nil then
                item.rank = v.rank
            end

            if v.maxCount ~= nil then
                item.maxCount = v.maxCount
            end

            if v.userCount ~= nil then
                item.userCount = v.userCount
            end

            if v.prosperity ~= nil then
                item.prosperity = v.prosperity
            end

            if v.headPic ~= nil then
                item.headPic = v.headPic
            end

            if v.name ~= nil then
                item.name = v.name
            end

            table.insert(items, item)
        end

        self:onCallFunc(items, marked)
        return true
    end

    self:onCallFunc(nil, marked)
end

function RanchersWebResponse:onMyClanProsperity(result, marked)
    result = WebResponse:formatResult(result)
    local data = WebResponse:formatData(result)
    if data ~= nil then
        self:onCallFunc(data, marked)
        return true
    end

    self:onCallFunc(nil, marked)
end

function RanchersWebResponse:setCountDataToNull(marked)
    if RanchersWebResponse.count[marked] ~= nil then
        RanchersWebResponse.count[marked] = nil
    end
end

function RanchersWebResponse:retryRequest(marked, func1, func2, log)
    if RanchersWebResponse.count[marked] == nil then
        RanchersWebResponse.count[marked] = 3
    end

    if RanchersWebResponse.count[marked] > 0 then
        func1()
        HostApi.log(log .. RanchersWebResponse.count[marked])
        RanchersWebResponse.count[marked] = RanchersWebResponse.count[marked] - 1
    else
        self:setCountDataToNull(marked)
        func2()
    end
end


