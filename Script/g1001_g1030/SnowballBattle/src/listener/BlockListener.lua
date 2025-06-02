--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

require "Match"

BlockListener = {}

function BlockListener:init()
    BlockBreakEvent.registerCallBack(self.onBlockBreak)
    PlayerPlaceBlockEvent.registerCallBack(self.onBlockPlace)
end

function BlockListener.onBlockBreak(rakssid, blockId, vec3)
    return GameConfig.enableBreak
end

function BlockListener.onBlockPlace(rakssid, blockId, blockMeta, vec3)
    if GameMatch:isGameStart() == false then
        return false
    end
    if blockId ~= 80 then
        return false
    end
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player ~= nil then
        if player.team:inBlockPlaceArea(vec3) then
            return true
        end
    end
    return false
end

return BlockListener
--endregion
