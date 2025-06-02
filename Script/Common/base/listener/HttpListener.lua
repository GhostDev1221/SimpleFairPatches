---
--- Created by Jimmy.
--- DateTime: 2018/6/28 0028 11:37
---
require "base.web.WebResponse"

HttpListener = {}

function HttpListener:init()
    HttpResponseEvent.registerCallBack(self.onHttpResponse)
end

function HttpListener.onHttpResponse(result, marked)
    -- BLOCKYMODS --
    if string.find(marked, WebRequestType.BLOCKYMODS_USER_ATTR) ~= nil then
        WebResponse:onGetBlockymodsUserAttr(result, marked)
        return
    end
    if string.find(marked, WebRequestType.BLOCKYMODS_REWARD) ~= nil then
        WebResponse:onGetBlockymodsReward(result, marked)
        return
    end
    if string.find(marked, WebRequestType.BLOCKYMODS_GOLD_REWARD) ~= nil then
        WebResponse:onGetBlockymodsGoldReward(result, marked)
        return
    end
    if string.find(marked, WebRequestType.BLOCKYMODS_REPORT) ~= nil then
        WebResponse:onReportBlockymodsData(result, marked)
        return
    end
    if string.find(marked, WebRequestType.BLOCKYMODS_USER_INFOS) ~= nil then
        WebResponse:onGetBlockymodsUserInfos(result, marked)
        return
    end
    if marked == WebRequestType.BLOCKYMODS_REWARD_LIST then
        WebResponse:onGetBlockymodsRewardList(result, marked)
        return
    end
    if marked == WebRequestType.BLOCKYMODS_REPORT_LIST then
        WebResponse:onReportBlockymodsList(result, marked)
        return
    end
    if marked == WebRequestType.BLOCKYMODS_EXP_RULE then
        WebResponse:onGetBlockymodsExpRole(result, marked)
        return
    end
    if string.find(marked, WebRequestType.BLOCKYMODS_USER_EXP) ~= nil then
        WebResponse:onGetBlockymodsExp(result, marked)
        return
    end
    if marked == WebRequestType.BLOCKYMODS_SAVE_EXP then
        WebResponse:onSaveBlockymodsExp(result, marked)
        return
    end
    if marked == WebRequestType.BLOCKYMODS_SAVE_HONOR then
        WebResponse:onSaveBlockymodsHonor(result, marked)
        return
    end
    if string.find(marked, WebRequestType.BLOCKYMODS_USER_SEASON_INFO) ~= nil then
        WebResponse:onGetBlockymodsUserSeasonInfo(result, marked)
        return
    end
    if string.find(marked, WebRequestType.BLOCKYMODS_USER_SEASON_REWARD) ~= nil then
        WebResponse:onUpdateBlockymodsUserSeasonReward(result, marked)
        return
    end

    -- game api --
    if string.find(marked, WebRequestType.CHECK_MAILS) ~= nil then
        WebResponse:onCheckMails(result, marked)
        return
    end
    if string.find(marked, WebRequestType.SEND_MAILS) ~= nil then
        WebResponse:onSendMails(result, marked)
        return
    end
    if string.find(marked, WebRequestType.UPDATE_MAILS) ~= nil then
        WebResponse:onUpdateMails(result, marked)
        return
    end

    -- MCPEONLINE --
    if string.find(marked, WebRequestType.MCPEONLINE_USER_ATTR) ~= nil then
        WebResponse:onGetMcpeonlineUserAttr(result, marked)
        return
    end
    if string.find(marked, WebRequestType.MCPEONLINE_REWARD) ~= nil then
        WebResponse:onGetMcpeonlineReward(result, marked)
        return
    end
    if string.find(marked, WebRequestType.MCPEONLINE_REPORT) ~= nil then
        WebResponse:onGetMcpeonlineReport(result, marked)
        return
    end
end

return HttpListener