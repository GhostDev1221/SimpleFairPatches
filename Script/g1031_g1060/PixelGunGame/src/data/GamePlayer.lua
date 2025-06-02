---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:20
---
require "base.util.class"
require "base.data.BasePlayer"
require "Match"
require "config.RespawnConfig"

GamePlayer = class("GamePlayer", BasePlayer)
GamePlayer.Integral = {
    HEADSHOT = 1,
    KILL = 2,
    DIE = 3
}

function GamePlayer:init()
    self:initStaticAttr(0)
    self:teleInitPos()
    self.isFirstAward = false
    self.teamId = 0
    self.kills = 0
    self.dies = 0
    self.evenKills = 0
    self.onSkillDamageUid = 0
    self.onPosionDamageUid = 0
    self.onFireDamageUid = 0
    self.damageType = ""
    self.isHeadshot = false
    self.headshots = 0
    self.isLife = true
    self.armor_value = 0
    self.curDefense = 0
    self.maxDefense = 0
    self.maxHealth = 100
    self.addSpeed = 0
    self.addDamage = 0
    self.addHeadShot = 0
    self.invincibleTime = 0
    self.standByTime = 0
    self.siteId = 0
    self.waitRespawnTime = 0
    self.equip_guns = {}
    self.equip_props = {}
    self.equip_blocks = {}
    self.revenge = false
    self.extraAward = {}
    self.honorId = 0
    self.honor = 0
    self.money = 0
    self.mode_first = {}
    self.level = 0
    self.cur_exp = 0
    self.yaoshi = 0
    self.vip_time = 0
    self.rank = 0
    self.allProperties = {}
    self.curUseItemId = 0
    self.is_need_show_lv_up = false
    self.isReward = false
    self.rewards = {}
    self.respawnTaskKey = ""

    self:getUserSeasonInfo(3)
end

function GamePlayer:initDataFromDB(data, subKey)
    if subKey == DbUtil.GAME_DATA then
        self:initGameDataFromDB(data)
    end
    if subKey == DbUtil.REWARD_DATA then
        self:initRewardDataFromDB(data)
    end
end

function GamePlayer:initGameDataFromDB(data, subKey)
    if #data ~= 0 then
        local result = json.decode(data)
        self.level = result.level or 1
        self.money = result.money or 0
        self.cur_exp = result.cur_exp or 0
        self.armor_value = result.armor_value or 0
        self.yaoshi = result.yaoshi or 0
        self.chest_integral = result.chest_integral or 0
        self.chests = result.chests or {}
        self.equip_guns = result.equip_guns or {}
        self.equip_props = result.equip_props or {}
        self.equip_blocks = result.equip_blocks or {}
        self.cur_is_random = result.cur_is_random or 0
        self.cur_map_id = result.cur_map_id or ""
        self.mode_first = result.mode_first or {}
        self.mode_first_day_id = result.mode_first_day_id or 0
        self.vip_time = result.vip_time or 0
    end
    self:setCurrency(self.money)
    self:initMaxHealthByLevel(self.level)
    self:initDefense()
    self:initEquipItemsAttr()
    self:initEquipItems()
    self:changeMaxHealth(self.maxHealth)
    self:sendNameToOtherPlayers()
end

function GamePlayer:initMaxHealthByLevel(level)
    local maxHealth = ExpConfig:getMaxHp(level)
    self.maxHealth = maxHealth
end

function GamePlayer:initRewardDataFromDB(data)
    if #data ~= 0 then
        local result = json.decode(data)
        self.rewards = result.rewards or {}
    end
end

function GamePlayer:initEquipItemsAttr()
    for _, equip_gun in pairs(self.equip_guns) do
        self:onGetProperties(equip_gun.ItemId, equip_gun.PropertyIds)
        self:addGunDamage(equip_gun.ItemId, equip_gun.AddDamage)
    end
    for index, equip_prop in pairs(self.equip_props) do
        self:onGetProperties(equip_prop.ItemId, equip_prop.PropertyIds)
    end
    for type, equip_block in pairs(self.equip_blocks) do
        self:onGetProperties(equip_block.ItemId, equip_block.PropertyIds)
    end
end

function GamePlayer:initEquipItems()
    self:clearInv()
    for type, equip_gun in pairs(self.equip_guns) do
        self:replaceItem(equip_gun.ItemId, 1, 0, tonumber(type) - 1, 1000)
        local gun = GunConfig:getGunByItemId(equip_gun.ItemId)
        if gun ~= nil then
            self:addItem(gun.bulletId, gun.spareBullet, 0, true)
        end
    end
    for index, equip_prop in pairs(self.equip_props) do
        self:replaceItem(equip_prop.ItemId, 1, 0, 5 + index)
    end
    for index, equip_block in pairs(self.equip_blocks) do
        self:replaceItem(equip_block.ItemId, equip_block.Count, 0, tonumber(index) + 1)
    end
end

function GamePlayer:onGetProperties(itemId, propertyIds)
    local properties = PropertyConfig:getPropertyByIds(propertyIds)
    for _, property in pairs(properties) do
        property:onPlayerGet(self)
    end
    self.allProperties[tostring(itemId)] = properties
end

function GamePlayer:onEquipItem(itemId)
    if self.curUseItemId == itemId then
        return
    end
    self:onUnloadItem(self.curUseItemId)
    self.curUseItemId = itemId
    local properties = self.allProperties[tostring(itemId)]
    if properties and #properties > 0 then
        for _, property in pairs(properties) do
            property:onPlayerEquip(self)
        end
    end
end

function GamePlayer:onUnloadItem(itemId)
    local properties = self.allProperties[tostring(itemId)]
    if properties and #properties > 0 then
        for _, property in pairs(properties) do
            property:onPlayerUnload(self)
        end
    end
end

function GamePlayer:onUsedItem(target, damage)
    local properties = self.allProperties[tostring(self.curUseItemId)]
    if properties and #properties > 0 then
        for _, property in pairs(properties) do
            property:onPlayerUsed(self, target, damage)
        end
    end
end

function GamePlayer:onMoneyChange()
    self.money = self:getCurrency()
end

function GamePlayer:teleInitPos()
    self:teleportPos(GameConfig.initPos)
end

function GamePlayer:onPlayerRespawn()
    self.invincibleTime = GameConfig.invincibleTime
    self:getResetItem()
end

function GamePlayer:getResetItem()
    self.curDefense = self.maxDefense
    self:updateDefense()
    self:initEquipItems()
    self:changeMaxHealth(self.maxHealth)
end

function GamePlayer:getTeamId()
    return self.teamId
end

function GamePlayer:setTeamId(teamId)
    self.teamId = teamId
    HostApi.changePlayerTeam(0, self.userId, self.teamId)
    local players = PlayerManager:getPlayers()
    for _, player in pairs(players) do
        HostApi.changePlayerTeam(self.rakssid, player.userId, player.teamId)
    end
end

function GamePlayer:isInvincible()
    return self.invincibleTime > 0
end

function GamePlayer:initDefense()
    self.curDefense = self.armor_value
    self.maxDefense = self.armor_value
    self:updateDefense()
end

function GamePlayer:addMaxDefense(defense)
    self.maxDefense = self.maxDefense + defense
    self.curDefense = self.maxDefense
    self:updateDefense()
end

function GamePlayer:addDefense(defense)
    self.curDefense = self.curDefense + defense
    self.curDefense = math.min(self.curDefense, self.maxDefense)
    self:updateDefense()
end

function GamePlayer:subDefense(damage)
    if self.curDefense == nil or self.curDefense <= 0 then
        return damage
    end
    if self.curDefense - damage >= 0 then
        self.curDefense = self.curDefense - damage
        self:updateDefense()
        return 0
    else
        local result = damage - self.curDefense
        self.curDefense = 0
        self:updateDefense()
        return result
    end
end

function GamePlayer:updateDefense()
    if self.entityPlayerMP == nil then
        return
    end
    self.entityPlayerMP:changeDefense(self.curDefense, self.maxDefense)
end

function GamePlayer:addKey(key)
    self.yaoshi = self.yaoshi + key
end

function GamePlayer:onKill(dier)
    self.kills = self.kills + 1
    self.evenKills = self.evenKills + 1
    self.appIntegral = self.appIntegral + 1
    local headshot = 0
    if self.isHeadshot then
        headshot = 1
        self.headshots = self.headshots + 1
        self.isHeadshot = false
    end
    HostApi.notifyGetGoods(self.rakssid, "set:gun.json image:HeadShot", 0)
    HostApi.sendPlaySound(self.rakssid, 312)
    MsgSender.sendKillMsg(self.name, dier.name, self:getHeldItemId(), self.evenKills, headshot, TextFormat.colorAqua)
end

function GamePlayer:onDie(isEnd, isPlayer)
    self.isLife = false
    self.dies = self.dies + 1
    self.evenKills = 0
    if isPlayer == true then
        self.respawnTaskKey = LuaTimer:schedule(function(rakssid)
            HostApi.sendRespawnCountDown(rakssid, 0)
        end, GameConfig.autoRespawnTime, nil, self.rakssid)
    end
    if isEnd then
        self.waitRespawnTime = 1
    end
end

function GamePlayer:sendReviveData(killer)
    local data = {}
    local killer_weapon = GunConfig:getGunByItemId(killer:getHeldItemId()) or PropConfig:getPropByItemId(killer:getHeldItemId())
    if killer_weapon ~= nil then
        data.killer_use_gun_img = killer_weapon.image
        data.killer_use_gun_name = killer_weapon.name
    else
        data.killer_use_gun_img = ""
        data.killer_use_gun_name = ""
    end
    data.killer_name = killer.name
    --five guns
    data.arms = {}
    local guns = {}
    for type, equip_gun in pairs(killer.equip_guns) do
        table.insert(guns, {
            type = tonumber(type),
            gun = equip_gun
        })
    end
    table.sort(guns, function(gun1, gun2)
        return gun1.type < gun2.type
    end)
    for _, c_gun in pairs(guns) do
        local equip_gun = c_gun.gun
        local arms_item = {}
        local gun = GunConfig:getGunByItemId(equip_gun.ItemId) or PropConfig:getPropByItemId(equip_gun.ItemId)
        if gun ~= nil then
            arms_item.img = gun.image
            arms_item.name = gun.name
        else
            arms_item.img = ""
            arms_item.name = ""
        end
        table.insert(data.arms, arms_item)
    end

    --two skills
    data.gadgets = {}
    for i, equip_prop in pairs(killer.equip_props) do
        local gadgets_item = {}
        local prop = PropConfig:getPropByItemId(equip_prop.ItemId)
        if prop ~= nil then
            gadgets_item.img = prop.image
            gadgets_item.name = prop.name
        else
            gadgets_item.img = ""
            gadgets_item.name = ""
        end
        table.insert(data.gadgets, gadgets_item)
    end
    --one block
    data.killer_block_img = ""
    data.killer_block_name = ""
    for _, equip_block in pairs(killer.equip_blocks) do
        local prop = PropConfig:getPropByItemId(equip_block.ItemId)
        if prop ~= nil then
            data.killer_block_img = prop.image
            data.killer_block_name = prop.name
        end
    end

    data.battle_time = GameConfig.waitRespawnTime
    data.killer_entityId = killer:getEntityId()
    data.killer_itemId = killer:getHeldItemId()

    data.cur_hp = math.max(math.floor(killer:getHealth()), 1)
    data.max_hp = math.max(math.floor(killer:getMaxHealth()), 1)
    data.cur_defence = math.floor(killer.curDefense)
    data.max_defence = math.floor(killer.maxDefense)
    HostApi.sendOpenPixelRevive(self.rakssid, true, json.encode(data))
end

function GamePlayer:onMove(x, y, z)
    local hash = x .. ":" .. y .. ":" .. z
    if self.moveHash ~= hash then
        self.moveHash = hash
        self.standByTime = 0
    end
end

function GamePlayer:onTick()
    self.invincibleTime = self.invincibleTime - 1
    self.standByTime = self.standByTime + 1
    if self.standByTime == GameConfig.standByTime - 5 then
        MsgSender.sendBottomTipsToTarget(self.rakssid, 2, Messages:msgNotOperateTip())
    end
    if self.standByTime >= GameConfig.standByTime then
        BaseListener.onPlayerLogout(self.userId)
        HostApi.sendGameover(self.rakssid, IMessages:msgGameOver(), GameOverCode.GameOver)
    end
end

function GamePlayer:respawnRightNow()
    HostApi.sendRespawnCountDown(self.rakssid, 0)
    LuaTimer:cancel(self.respawnTaskKey)
end

function GamePlayer:onPickUpBullet(coe)
    for i, v in pairs(self.equip_guns) do
        local gun = GunConfig:getGunByItemId(v.ItemId)
        if gun ~= nil then
            local num = gun.pickupBulletNum * coe
            self:addItem(gun.bulletId, num, 0, true)
        end
    end
end

function GamePlayer:isGameVip()
    return self.vip_time - os.time() > 0
end
--
function GamePlayer:checkFirstAward()
    if self.mode_first == "" then
        table.insert(self.mode_first, GameMatch.gameType)
        return FirstAwardCheck:isFirstAward(GameMatch.gameType)
    end
    for i, v in pairs(self.mode_first) do
        if v == GameMatch.gameType then
            return false
        end
    end
    table.insert(self.mode_first, GameMatch.gameType)
    return FirstAwardCheck:isFirstAward(GameMatch.gameType)
end

function GamePlayer:getRewardInfo(reward, isWin)
    local data = {}
    data.exp = reward.exp
    data.money = reward.money
    data.yaoshi = reward.yaoshi
    data.integral = reward.integral
    if self:isGameVip() then
        data.exp = data.exp * ExtraAwardConfig:getVipAward("exp")
        data.money = data.money * ExtraAwardConfig:getVipAward("money")
        data.yaoshi = data.yaoshi * ExtraAwardConfig:getVipAward("yaoshi")
        if isWin then
            data.integral = data.integral * ExtraAwardConfig:getVipAward("integral")
        end

    end
    if self:checkFirstAward() then
        data.exp = data.exp * ExtraAwardConfig:getFirstAward("exp")
        data.money = data.money * ExtraAwardConfig:getFirstAward("money")
        data.yaoshi = data.yaoshi * ExtraAwardConfig:getFirstAward("yaoshi")
        if isWin then
            data.integral = data.integral * ExtraAwardConfig:getFirstAward("integral")
        end
    end
    if self.cur_is_random ~= 0 then
        data.exp = data.exp + ExtraAwardConfig:getRandomMapAward("exp")
        data.money = data.money + ExtraAwardConfig:getRandomMapAward("money")
        data.yaoshi = data.yaoshi + ExtraAwardConfig:getRandomMapAward("yaoshi")
        if isWin then
            data.integral = data.integral + ExtraAwardConfig:getRandomMapAward("integral")
        end
    end
    data.integral = self:getFinalIntegral(data.integral)
    if self.isReward == false then
        self:doReward(data)
    end
    return data
end

function GamePlayer:getFinalIntegral(integral)
    local headshot = HonorExponentConfig:getRateById(GamePlayer.Integral.HEADSHOT)
    local kill = HonorExponentConfig:getRateById(GamePlayer.Integral.KILL)
    local die = HonorExponentConfig:getRateById(GamePlayer.Integral.DIE)
    integral = integral + (self.headshots * headshot) + (self.kills * kill) + (self.dies * die)
    return integral
end

function GamePlayer:doReward(reward)
    self.isReward = true
    self:addCurrency(reward.money)
    self:addExp(reward.exp)
    self:addKey(reward.yaoshi)
    self:addFragment()
    SeasonManager:addUserHonor(self.userId, reward.integral, self.level)
end

function GamePlayer:addFragment()
    local item = {}
    item.Id = self.cur_map_id
    item.Count = 1
    item.Type = 4
    table.insert(self.rewards, item)
end

function GamePlayer:addExp(exp)

    self.cur_exp = self.cur_exp + exp
    local cur_max, is_max = ExpConfig:getMaxExp(self.level)

    while not is_max and self.cur_exp >= cur_max do

        self.level = self.level + 1
        self.cur_exp = self.cur_exp - cur_max
        self:addLvUpReward()
        cur_max, is_max = ExpConfig:getMaxExp(self.level)
    end
end

function GamePlayer:addLvUpReward()
    local money, yaoshi, gun_id, frag_num = ExpConfig:getLevelReward(self.level)
    self.money = self.money + money
    self.yaoshi = self.yaoshi + yaoshi

    -- add gun fragment
    if gun_id > 0 and frag_num > 0 then
        local item = {}
        item.Id = gun_id
        item.Count = frag_num
        item.Type = 1
        table.insert(self.rewards, item)
    end
    self.is_need_show_lv_up = true
end

function GamePlayer:getLvUpData()
    local data = {}
    local money, yaoshi, gun_id, frag_num = ExpConfig:getLevelReward(self.level)

    data.rewards = {}
    data.level = self.level

    local money_item = {}
    money_item.img = "set:pixelgungamebig.json image:jinbi"
    money_item.num = money
    table.insert(data.rewards, money_item)

    local yaoshi_item = {}
    yaoshi_item.img = "set:pixelgungamebig.json image:yaoshi_kuang"
    yaoshi_item.num = yaoshi
    table.insert(data.rewards, yaoshi_item)

    if gun_id > 0 and frag_num > 0 then
        local frag_item = {}
        frag_item.img = ExpConfig:getLevelFragImg(self.level)
        frag_item.num = frag_num
        table.insert(data.rewards, frag_item)
        -- show gun when gun and hp conflict 
        return data
    end

    local diffHp = ExpConfig:getDiffhp(self.level)

    if diffHp > 0 then
        local hp_item = {}
        hp_item.img = "set:pixelgungamebig.json image:hp_max"
        hp_item.num = diffHp
        table.insert(data.rewards, hp_item)
    end

    return data
end

function GamePlayer:showLvUpReward()
    if self.is_need_show_lv_up then
        -- HostApi.log("showLvUpReward " .. self.level)
        self.is_need_show_lv_up = false
        local lvUpData = self:getLvUpData()
        HostApi.sendOpenPixelLvUp(self.rakssid, true, json.encode(lvUpData))
    end
end

function GamePlayer:getUserSeasonInfo(retryTime)
    WebResponse:registerCallBack(function(data, userId, retryTime)
        if not data then
            if retryTime > 0 then
                self:getUserSeasonInfo(retryTime - 1)
            end
            return
        end
        self.honorId = data.segment
        self.honor = data.integral
    end, WebService:GetBlockymodsUserSeasonInfo(self.userId, false), self.userId, retryTime)
end

function GamePlayer:sendNameToOtherPlayers()
    local players = PlayerManager:getPlayers()
    for _, player in pairs(players) do
        if player:getTeamId() ~= self:getTeamId() then
            self.entityPlayerMP:changeNamePerspective(player.rakssid, true)
            player.entityPlayerMP:changeNamePerspective(self.rakssid, true)
        else
            self.entityPlayerMP:changeNamePerspective(player.rakssid, false)
            player.entityPlayerMP:changeNamePerspective(self.rakssid, false)
        end
    end
    self:setShowName(GameMatch.Process:buildShowName(self))
end

return GamePlayer

--endregion


