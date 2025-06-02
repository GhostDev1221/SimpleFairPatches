--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

require "Match"
require "base.util.VectorUtil"
require "messages.Messages"

BlockListener = {}

function BlockListener:init()
    BlockBreakEvent.registerCallBack(self.onBlockBreak)
    PlayerPlaceBlockEvent.registerCallBack(self.onBlockPlace)
    BlockTNTExplodeEvent.registerCallBack(self.onBlockTNTExplode)
end

function BlockListener.onBlockBreak(rakssid, blockId, vec3)
    if GameMatch:isGameStart() == false then
        return false
    end
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return false
    end
    -- Bed Block
    if blockId == 26 then
        for i, team in pairs(GameMatch.Teams) do
            if team.id ~= player.team.id then
                for i, vec in pairs(team.bedPos) do
                    if VectorUtil.hashVector3(vec3) == VectorUtil.hashVector3(vec) and team.isHaveBed then
                        player:onDestroyBed()
                        team:destroyBed()
                        MsgSender.sendMsg(32, Messages:breakBed(team:getDisplayName(), player:getDisplayName()))
                        return true
                    end
                end
            end
        end
    else
        if GameMatch.blockCache[VectorUtil.hashVector3(vec3)] ~= nil then
            GameMatch.blockCache[VectorUtil.hashVector3(vec3)] = nil
            return true
        end
    end
    return false
end

function BlockListener.onBlockPlace(rakssid, blockId, blockMeta, vec3)
    if GameMatch:isGameStart() then
        local player = PlayerManager:getPlayerByRakssid(rakssid)
        if player ~= nil then
            GameMatch.blockCache[VectorUtil.hashVector3(vec3)] = true
            return true
        end
    end
    return false
end

function BlockListener.onBlockTNTExplode(entityId, pos, attr)
    attr.isBreakBlock = false
    return false
end

return BlockListener
--endregion
