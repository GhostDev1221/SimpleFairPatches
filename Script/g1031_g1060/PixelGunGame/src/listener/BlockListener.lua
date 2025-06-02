--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

require "manager.BlockManager"

BlockListener = {}
BlockListener.BlockLifeCache = {}

function BlockListener:init()
    BlockBreakEvent.registerCallBack(self.onBlockBreak)
    PlayerPlaceBlockEvent.registerCallBack(self.onBlockPlace)
    BlockTNTExplodeEvent.registerCallBack(self.onBlockTNTExplode)
    BlockBreakWithGunEvent.registerCallBack(self.onBlockBreakWithGun)
end

function BlockListener.onBlockBreak(rakssid, blockId, blockPos)
    return false
end

function BlockListener.onBlockPlace(rakssid, blockId, blockMeta, blockPos)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return false
    end
    if GameMatch.Process:isRunning(player.siteId) == false then
        return false
    end
    BlockManager:onPlayerPlaceBlock(player, blockId, blockPos)
    return true
end

function BlockListener.onBlockTNTExplode(entityId, pos, attr)
    attr.isBreakBlock = false
    return false
end

function BlockListener.onBlockBreakWithGun(rakssid, blockId, blockPos, gunId)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return
    end
    if GameMatch.Process:isRunning(player.siteId) == false then
        return
    end
    BlockManager:onPlayerShootBlock(player, blockPos, gunId)
end

return BlockListener
--endregion
