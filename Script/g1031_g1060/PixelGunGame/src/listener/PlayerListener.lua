--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.messages.IMessages"
require "base.util.MsgSender"
require "base.util.VectorUtil"
require "base.code.GameOverCode"
require "messages.Messages"
require "data.GamePlayer"
require "Match"
require "settlement.TeamSettlement"
require "settlement.PersonalSettlement"
require "util.SupplyUtil"
require "base.data.BasePlayer"

PlayerListener = {}

function PlayerListener:init()

    BaseListener.registerCallBack(PlayerLoginEvent, self.onPlayerLogin)
    BaseListener.registerCallBack(PlayerLogoutEvent, self.onPlayerLogout)
    BaseListener.registerCallBack(PlayerReadyEvent, self.onPlayerReady)
    BaseListener.registerCallBack(PlayerRespawnEvent, self.onPlayerRespawn)

    PlayerDieEvent.registerCallBack(self.onPlayerDied)
    PlayerAttackedEvent.registerCallBack(self.onPlayerHurt)
    PlayerMoveEvent.registerCallBack(self.onPlayerMove)
    PlayerDropItemEvent.registerCallBack(function()
        return false
    end)
    PlayerPickupItemEvent.registerCallBack(self.onPlayerPickupItem)
    PlayerPixelGunSelectBoxEvent.registerCallBack(self.onPlayerPixelGunSelectBox)
    PlayerPixelGunExitEvent.registerCallBack(self.onPlayerPixelGunExit)
    PlayerPixelGunRematchEvent.registerCallBack(self.onPlayerPixelGunRematch)
    PlayerPixelGunReviveEvent.registerCallBack(self.onPlayerPixelGunRevive)
    PlayerPixelGunResultBackEvent.registerCallBack(self.onPlayerPixelGunResultBack)
    PlayerPixelGunResultNextEvent.registerCallBack(self.onPlayerPixelGunResultNext)
    PlayerPixelGunResultRevengeEvent.registerCallBack(self.onPlayerPixelGunResultRevenge)
    PlayerCurrencyChangeEvent.registerCallBack(self.onPlayerCurrencyChange)
    PlayerChangeItemInHandEvent.registerCallBack(self.onPlayerChangeItemInHand)
    PlayerReviewPlayerEvent.registerCallBack(self.onPlayerReviewPlayer)

end

function PlayerListener.onPlayerLogin(clientPeer)
    local players = PlayerManager:getPlayerCount()
    if players == GameConfig.maxPlayers then
        return GameOverCode.PlayerIsEnough
    end
    local player = GamePlayer.new(clientPeer)
    player:init()
    return GameOverCode.Success, player, 1
end

function PlayerListener.onPlayerLogout(player)
    GameMatch:onPlayerQuit(player)
    local site = SiteConfig:getSitesById(player.siteId)
    if site == nil then
        return
    end
    if site.playernum == 0 then
        site.process:reset()
    else
        site:canNotRevenge()
    end
end

function PlayerListener.onPlayerReady(player)
    GameMatch.Process:assignTeam(player)
    DbUtil:getPlayerData(player)
    HostApi.sendPlaySound(player.rakssid, 10037)
    return 43200
end

function PlayerListener.onPlayerRespawn(player)
    if GameMatch.Process:isGameOver(player) then
        return -1
    end
    GameMatch.Process:onPlayerRespawn(player)
    player:onPlayerRespawn()
    player:sendNameToOtherPlayers()
    return 43200
end

function PlayerListener.onPlayerMove(Player, x, y, z)
    local player = PlayerManager:getPlayerByPlayerMP(Player)
    if player == nil then
        return false
    end
    if y <= GameConfig.deathLineY and GameMatch.Process:isRunning(player.siteId) then
        player:subHealth(99999)
    end
    player:onMove(x, y, z)
    return true
end

function PlayerListener.onPlayerHurt(hurtPlayer, hurtFrom, damageType, hurtValue)
    local hurter = PlayerManager:getPlayerByPlayerMP(hurtPlayer)
    if hurter == nil then
        return true
    end
    if GameMatch.Process:isRunning(hurter.siteId) == false then
        return false
    end

    if damageType == "outOfWorld" then
        hurtValue.value = 10000
        return true
    end

    if damageType == "fall" or damageType == "inWall" or damageType == "generic" then
        return false
    end

    if hurter:isInvincible() then
        return false
    end

    if damageType == "onFire" or damageType == "magic" then
        hurter.damageType = damageType
        return true
    end

    local attacker = PlayerManager:getPlayerByPlayerMP(hurtFrom)
    if attacker == nil then
        return true
    end

    if hurter:getTeamId() == attacker:getTeamId() then
        return false
    end

    if damageType == "explosion.player" or damageType == "explosion" then
        hurtValue.value = math.max(hurtValue.value * 1.3, 10)
    end

    if damageType == "player.gun.headshot" then
        attacker.isHeadshot = true
        hurtValue.value = hurtValue.value + attacker.addHeadShot
    else
        if damageType == "player" then -- no gun
            hurtValue.value = PropConfig:getCurHandDamage(attacker)
        end
        attacker.isHeadshot = false
    end
    hurtValue.value = hurtValue.value + attacker.addDamage
    attacker:onUsedItem(hurter, hurtValue)
    hurtValue.value = hurter:subDefense(hurtValue.value)
    return true
end

function PlayerListener.onPlayerDied(diePlayer, iskillByPlayer, killPlayer)
    local dier = PlayerManager:getPlayerByPlayerMP(diePlayer)
    if dier == nil then
        return true
    end
    local killer = PlayerManager:getPlayerByPlayerMP(killPlayer)
    if killer == nil then
        killer = PlayerManager:getPlayerByUserId(dier.onSkillDamageUid)
    end
    if killer == nil then
        if dier.damageType == "onFire" then
            killer = PlayerManager:getPlayerByUserId(dier.onFireDamageUid)
        end
        if dier.damageType == "magic" then
            killer = PlayerManager:getPlayerByUserId(dier.onPosionDamageUid)
        end
    end
    if killer == nil then
        killer = PlayerManager:getPlayerByUserId(dier.onPosionDamageUid)
    end
    if killer == nil then
        killer = PlayerManager:getPlayerByUserId(dier.onFireDamageUid)
    end
    dier.damageType = ""
    dier.onSkillDamageUid = 0
    dier.onPosionDamageUid = 0
    dier.onFireDamageUid = 0
    if killer == nil then
        HostApi.sendRespawnCountDown(dier.rakssid, GameConfig.autoRespawnTime)
        dier:onDie(false, false)
    else
        GameMatch:onPlayerKill(killer, dier)
    end
    return true
end

function PlayerListener.onPlayerPickupItem(rakssid, itemId, itemNum)
    return false
end

function PlayerListener.onPlayerPixelGunSelectBox(rakssid, index)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return
    end
    if GameMatch.Process:isSelect(player.siteId) == false then
        return
    end
    player.chest = tonumber(index)
    GameMatch.Process:updateChest(player.siteId)
end

function PlayerListener.onPlayerPixelGunExit(rakssid)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return
    end
    EngineUtil.sendEnterOtherGame(player.rakssid, "g1042", player.userId)
end

function PlayerListener.onPlayerPixelGunRematch(rakssid)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return
    end
    GameMatch.Process:changeSite(player)
end

function PlayerListener.onPlayerPixelGunRevive(rakssid)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return
    end
    local data = {}
    HostApi.sendOpenPixelRevive(rakssid, false, json.encode(data))
    player:respawnRightNow()
end

function PlayerListener.onPlayerPixelGunResultBack(rakssid)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return
    end
    EngineUtil.sendEnterOtherGame(rakssid, "g1042", player.userId, "")
end

function PlayerListener.onPlayerPixelGunResultNext(rakssid)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return
    end
    EngineUtil.sendEnterOtherGame(rakssid, GameMatch.gameType, player.userId, player.cur_map_id)
end

function PlayerListener.onPlayerPixelGunResultRevenge(rakssid)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        return
    end
    HostApi.log("onPlayerPixelGunResultRevenge")
    player.revenge = true
    local site = SiteConfig:getSitesById(player.siteId)
    if site ~= nil then
        site:updateRevenge()
    end
end

function PlayerListener.onPlayerCurrencyChange(rakssid, currency)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player ~= nil then
        player:onMoneyChange()
    end
end

function PlayerListener.onPlayerChangeItemInHand(rakssid, itemId, itemMeta)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if not player then
        return
    end
    player:onEquipItem(itemId)
end

function PlayerListener.onPlayerReviewPlayer(rakssid1, rakssid2)
    local player1 = PlayerManager:getPlayerByRakssid(rakssid1)
    local player2 = PlayerManager:getPlayerByRakssid(rakssid2)
    if player1 == nil or player2 == nil then
        return
    end
    if player1:getTeamId() ~= player2:getTeamId() then
        player1.entityPlayerMP:changeNamePerspective(player2.rakssid, true)
    else
        player1.entityPlayerMP:changeNamePerspective(player2.rakssid, false)
    end
end

return PlayerListener
--endregion
