--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.messages.IMessages"
require "base.util.MsgSender"
require "base.util.VectorUtil"
require "base.code.GameOverCode"
require "messages.Messages"
require "data.GamePlayer"
require "data.GameChestLottery"
require "data.GameArmor"
require "data.GameAppShop"
require "Match"

PlayerListener = {}

function PlayerListener:init()

    BaseListener.registerCallBack(PlayerLoginEvent, self.onPlayerLogin)
    BaseListener.registerCallBack(PlayerLogoutEvent, self.onPlayerLogout)
    BaseListener.registerCallBack(PlayerReadyEvent, self.onPlayerReady)

    PlayerDieEvent.registerCallBack(self.onPlayerDied)
    PlayerAttackedEvent.registerCallBack(self.onPlayerHurt)
    PlayerMoveEvent.registerCallBack(self.onPlayerMove)
    PlayerCurrencyChangeEvent.registerCallBack(self.onPlayerCurrencyChange)
    OpenSelectModeEvent.registerCallBack(self.onOpenSelectMode)
    PlayerPixelGunHallUnlockMapEvent.registerCallBack(self.onPlayerPixelGunHallUnlockMap)
    PlayerOpenLotteryChestEvent.registerCallBack(self.onPlayerOpenLotteryChest)
    PlayerPixelGunFightEvent.registerCallBack(self.onPlayerPixelGunFight)
    PlayerBuyGoodsEvent.registerCallBack(self.onPlayerBuyGoods)
    PlayerBuyGoodsSuccessEvent.registerCallBack(self.onPlayerBuyGoodsSuccess)
    OpenArmorUpgradeEvent.registerCallBack(self.onOpenArmorUpgrade)
    PlayerUpgradeArmorEvent.registerCallBack(self.onPlayerUpgradeArmor)
    PlayerDropItemEvent.registerCallBack(function()
        return false
    end)
end

function PlayerListener.onPlayerLogin(clientPeer)
    local player = GamePlayer.new(clientPeer)
    player:init()
    return GameOverCode.Success, player, 1
end

function PlayerListener.onPlayerLogout(player)
    GameMatch:onPlayerQuit(player)
end

function PlayerListener.onPlayerReady(player)
    DbUtil:getPlayerData(player)
    HostApi.sendPlaySound(player.rakssid, 10036)
    HostApi.setDisarmament(player.rakssid, true)
    MsgSender.sendMsgToTarget(player.rakssid, IMessages:msgWelcomePlayer(Messages:gamename()))
    return 43200
end

function PlayerListener.onPlayerHurt(hurtPlayer, hurtFrom, damageType, hurtValue)
    return false
end

function PlayerListener.onPlayerDied(diePlayer, iskillByPlayer, killPlayer)
    return true
end

function PlayerListener.onPlayerMove(movePlayer, x, y, z)
    if x == 0 and y == 0 and z == 0 then
        return true
    end
    local player = PlayerManager:getPlayerByPlayerMP(movePlayer)
    if player == nil then
        return true
    end
    FuncNpcConfig:onPlayerMove(player, x, y, z)
    player:onMove(x, y, z)
    return true
end

function PlayerListener.onPlayerCurrencyChange(rakssid, currency)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player ~= nil then
        player:onMoneyChange()
    end
end

function PlayerListener.onOpenSelectMode(rakssid)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return
    end

    if not DbUtil:CanSavePlayerData(player, DbUtil.GAME_DATA) then
        return
    end

    local data = player:getModeInfo()
    HostApi.sendOpenPixelGunHallModeSelect(rakssid, true, json.encode(data))
end

function PlayerListener.onPlayerPixelGunHallUnlockMap(rakssid, num, mapId)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return
    end
    player:consumeDiamonds(1, num, Define.UnlockMap .. "#" .. mapId, true)
end

function PlayerListener.onPlayerOpenLotteryChest(rakssid, chestId)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return
    end
    GameChestLottery:onPlayerOpenLotteryChest(player, chestId)
end

function PlayerListener.onPlayerBuyGoods(rakssid, type, itemId, msg, isAddItem)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return false
    end
    isAddItem.value = false
    return true
end

function PlayerListener.onPlayerBuyGoodsSuccess(rakssid, type, itemId)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return
    end
    GameAppShop:onPlayerShopping(player, itemId)
end

function PlayerListener.onOpenArmorUpgrade(rakssid)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return false
    end
    GameArmor:sendOpenArmorUpgrade(player, true)
end

function PlayerListener.onPlayerUpgradeArmor(rakssid, state, operateType)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return false
    end
    GameArmor:upgradeArmor(player, state, operateType)
end

function PlayerListener.onPlayerPixelGunFight(rakssid, gameType, mapName)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return false
    end
    local _gameType, _mapId, _is_random = ModeSelectConfig:getFightMapInfo(player, gameType, mapName)

    if _gameType and _mapId then
        if _is_random then
            player.cur_is_random = 1
        end
        player.cur_map_id = _mapId
        HostApi.log("onPlayerPixelGunFight " .. tostring(_gameType) .. " " .. tostring(_mapId))
        EngineUtil.sendEnterOtherGame(player.rakssid, tostring(_gameType), player.userId, tostring(_mapId))
    end
end

return PlayerListener
--endregion
