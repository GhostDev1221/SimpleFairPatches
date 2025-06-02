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
    if GameMatch.blockCache[VectorUtil.hashVector3(vec3)] ~= nil then
        GameMatch.blockCache[VectorUtil.hashVector3(vec3)] = nil
        return true
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
