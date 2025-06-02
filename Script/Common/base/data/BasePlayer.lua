--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.json"
require "base.web.WebService"
require "base.web.WebResponse"
require "base.messages.TextFormat"
require "base.classes.PlayerClassInfo"
require "base.prop.AppProps"

local CBasePlayer = class("BasePlayer")

function CBasePlayer:initMemberVariables()
    self.clientPeer = nil
    self.entityPlayerMP = nil
    self.userId = 0
    self.rakssid = 0
    self.name = nil
    self.gold = 0
    self.available = 0
    self.hasGet = 0
    self.scorePoints = {}
    self.defaultRank = 10
    self.respawnTimes = -1
    self.isReady = false
    self.inGameTime = os.time()
    self.appIntegral = 0

    self.staticAttr = {}
    self.staticAttr.hasInit = false

    self.staticAttr.vip = 0 -- vip
    self.staticAttr.supperPlayer = 0 -- spp
    self.staticAttr.lv = 0 -- lv
    self.staticAttr.attack = 0 -- att
    self.staticAttr.defense = 0 -- def
    self.staticAttr.health = 0 --heal
    self.staticAttr.title = "" -- title
    self.staticAttr.clanId = 0 -- clanId
    self.staticAttr.clanName = "" -- clanName
    self.staticAttr.role = -1 -- role
    self.staticAttr.classes = 0 --classes
    self.staticAttr.props = {} --props

    self.dynamicAttr = {}
    self.dynamicAttr.hasInit = false
    self.dynamicAttr.clz = 0
    self.dynamicAttr.region = 0
    self.dynamicAttr.team = 0
    self.dynamicAttr.pioneer = true
    self.dynamicAttr.vip = 0

    self.vip = 0
end

function CBasePlayer:getEntityPlayer()
    return self.entityPlayerMP
end

function CBasePlayer:ctor(clientPeer)
    self:initMemberVariables()
    self:respawn(clientPeer)
    self:initDynamicAttr()
end

function CBasePlayer:respawn(clientPeer)
    self.clientPeer = clientPeer
    self.entityPlayerMP = clientPeer:getEntityPlayer()
    self.userId = clientPeer:getPlatformUserId()
    self.rakssid = clientPeer:getRakssid()
    self.name = clientPeer:getName()
    self.respawnTimes = self.respawnTimes + 1
    self:useAppProps()
end

function CBasePlayer:initStaticAttr(teamId)
    WebResponse:registerCallBack(function(data)
        if data == nil then
            self:sendLoginResult(false, teamId or self.dynamicAttr.team, "",
                    PlayerManager:getPlayerCount(), PlayerManager:getMaxPlayer())
        else
            UserExpManager:getUserExpCache(self.userId)
            self:sendLoginResult(true, teamId or self.dynamicAttr.team, "",
                    PlayerManager:getPlayerCount(), PlayerManager:getMaxPlayer())
            self:setShowName(self:buildShowName())
            self:useAppProps()
        end
    end, WebService:GetBlockymodsUserAttr(self.userId, BaseMain:getGameType()))
end

function CBasePlayer:sendLoginResult(isSuccess, teamId, teamName, playerNum, maxPlayer)
    if self.clientPeer ~= nil then
        self.clientPeer:sendLoginResult(isSuccess, teamId, teamName, playerNum, maxPlayer)
    end
end

function CBasePlayer:onPlayerLogout()
    self.clientPeer = nil
    self.entityPlayerMP = nil
    ReportManager:onPlayerLogout(self)
end

function CBasePlayer:getDisplayName()
    return self.name
end

function CBasePlayer:addNightVisionPotionEffect(seconds)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addNightVisionPotionEffect(seconds)
    end
end

function CBasePlayer:useAppProps()
    AppProps:useAppProps(self, self.respawnTimes == 0)
end

function CBasePlayer:onUseCustomProp(propId, itemId)

end

function CBasePlayer:addItem(id, num, damage, isReverse)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addItem(id, num, damage, isReverse or false)
    end
end

function CBasePlayer:addGunItem(id, num, damage, bullets, isReverse)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addGunItem(id, num, damage, bullets, isReverse or false)
    end
end

function CBasePlayer:addItemToEnderChest(slot, id, num, damage)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addItemToEnderChest(slot, id, num, damage)
    end
end

function CBasePlayer:addGunItemToEnderChest(slot, id, num, damage, bullets)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addGunItemToEnderChest(slot, id, num, damage, bullets)
    end
end

function CBasePlayer:addGunDamage(gunId, damage)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addGunDamage(gunId, damage)
    end
end

function CBasePlayer:addGunBulletNum(gunId, bulletNum)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addGunBulletNum(gunId, bulletNum)
    end
end

function CBasePlayer:subGunRecoil(gunId, recoil)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:subGunRecoil(gunId, recoil)
    end
end

function CBasePlayer:removeItem(id, num)
    if self.entityPlayerMP ~= nil then
        local inv = self.entityPlayerMP:getInventory()
        inv:removeItem(id, num)
    end
end

function CBasePlayer:equipArmor(id, damage)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:equipArmor(id, damage)
    end
end

function CBasePlayer:replaceItem(id, num, damage, stackIndex, clipBullet)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:replaceItem(id, num, damage, stackIndex, clipBullet)
    end
end

function CBasePlayer:addEchantmentItem(id, num, damage, enchantmentId, enchantmentLevel)
    local enchantments = {}
    local enchantment = {}
    enchantment[1] = enchantmentId
    enchantment[2] = enchantmentLevel
    enchantments[1] = enchantment
    self:addEchantmentsItem(id, num, damage, enchantments)
end

function CBasePlayer:addEchantmentsItem(id, num, damage, enchantments)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addEchantmentItem(id, num, damage, enchantments)
    end
end

function CBasePlayer:getHealth()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getHealth()
    end
    return 20
end

function CBasePlayer:setHealth(health)
    if health == nil then
        return
    end
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:setEntityHealth(health)
    end
end

function CBasePlayer:addHealth(hp)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:heal(hp)
    end
end

function CBasePlayer:subHealth(hp)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:heal(-hp)
    end
end

function CBasePlayer:updateExp(level, exp, maxExp)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:updateExp(level, exp, maxExp)
    end
end

function CBasePlayer:getPosition()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getPosition()
    end
    return Vector3.new()
end

function CBasePlayer:getYaw()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getYaw()
    end
    return 0
end

function CBasePlayer:setPositionAndRotation(vec, yaw, pitch)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:setPositionAndRotation(vec, yaw, pitch)
    end
end

function CBasePlayer:getSex()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getSex()
    end
    return 1
end

function CBasePlayer:isWatchMode()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:isWatchMode()
    end
    return true
end

function CBasePlayer:setAllowFlying(flying)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setAllowFlying(flying)
    end
end

function CBasePlayer:setFoodLevel(value)
    if value == nil then
        return
    end
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:getFoodStats():setFoodLevel(value)
    end
end

function CBasePlayer:getFoodLevel()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getFoodStats():getFoodLevel()
    end
    return 20
end

function CBasePlayer:setSpeedAddition(level)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:setSpeedAdditionLevel(level)
    end
end

function CBasePlayer:getItemNumById(id)
    if self.entityPlayerMP ~= nil then
        local inv = self.entityPlayerMP:getInventory()
        return inv:getItemNum(id)
    end
    return 0
end

function CBasePlayer:clearInv()
    if self.entityPlayerMP ~= nil then
        local inv = self.entityPlayerMP:getInventory()
        inv:clear()
    end
end

function CBasePlayer:getInventory()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getInventory()
    end
end

function CBasePlayer:changeMaxHealth(health)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:changeMaxHealth(health)
    end
end

function CBasePlayer:getMaxHealth()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getMaxHealth()
    end
    return 0
end

function CBasePlayer:getHeldItemId()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getHeldItemId()
    end
    return 0
end

function CBasePlayer:setCurrency(currency)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setCurrency(currency)
    end
end

function CBasePlayer:addCurrency(currency)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addCurrency(currency)
    end
end

function CBasePlayer:subCurrency(currency)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:subCurrency(currency)
    end
end

function CBasePlayer:setUnlockedCommodities(unlockedCommodities)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setUnlockedCommodities(unlockedCommodities)
    end
end

function CBasePlayer:getCurrency()
    if self.entityPlayerMP ~= nil then
        return tonumber(tostring(self.entityPlayerMP:getCurrency()))
    end
    return 0
end

function CBasePlayer:addBackpackCapacity(capacity)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addBackpackCapacity(capacity)
    end
end

function CBasePlayer:subBackpackCapacity(capacity)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:subBackpackCapacity(capacity)
    end
end

function CBasePlayer:resetBackpack(capacity, maxCapacity)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:resetBackpack(capacity, maxCapacity)
    end
end

function CBasePlayer:setArmItem(itemId)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setArmItem(itemId)
    end
end

function CBasePlayer:fillInvetory(inventory)
    self:clearInv()
    if inventory == nil then
        return
    end
    local armors = inventory.armor
    for i, armor in pairs(armors) do
        if armor.id > 0 and armor.id < 10000 then
            self:equipArmor(armor.id, armor.meta)
        end
    end
    local guns = inventory.gun
    for i, gun in pairs(guns) do
        self:addGunItem(gun.id, gun.num, gun.meta, gun.bullets)
    end
    local items = inventory.item
    for i, item in pairs(items) do
        if item.id > 0 and item.id < 10000 then
            self:addItem(item.id, item.num, item.meta)
        end
    end
end

function CBasePlayer:fillEnderInvetory(enderInv)
    if enderInv == nil then
        return
    end
    local slot = 0
    local guns = enderInv.gun
    for i, gun in pairs(guns) do
        self:addGunItemToEnderChest(slot, gun.id, gun.num, gun.meta, gun.bullets)
        slot = slot + 1
    end
    local items = enderInv.item
    for i, item in pairs(items) do
        if item.id > 0 and item.id < 10000 then
            self:addItemToEnderChest(slot, item.id, item.num, item.meta)
            slot = slot + 1
        end
    end
end

function CBasePlayer:getEnderInventory()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getInventoryEnderChest()
    end
end

function CBasePlayer:addEffect(id, time, level)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:addEffect(id, time, level)
    end
end

function CBasePlayer:removeEffect(id)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:removeEffect(id)
    end
end

function CBasePlayer:clearEffects()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:clearEffects()
    end
end

function CBasePlayer:setRespawnPos(pos)
    if self.clientPeer ~= nil then
        self.clientPeer:setRespawnPos(VectorUtil.newVector3i(pos.x, pos.y + 0.5, pos.z))
    end
end

function CBasePlayer:teleportPos(pos)
    HostApi.resetPos(self.rakssid, pos.x, pos.y + 0.5, pos.z)
end

function CBasePlayer:teleportPosWithYaw(pos, yaw)
    HostApi.resetPosWithYaw(self.rakssid, pos.x, pos.y + 0.5, pos.z, yaw)
end

function CBasePlayer:changeClothes(partName, actorId)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:changeClothes(partName, actorId)
    end
end

function CBasePlayer:resetClothes()
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:resetClothes(self.userId)
    end
end

function CBasePlayer:playSkillEffect(name, duration, range, color)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:playSkillEffect(name, duration, range, color)
    end
end

function CBasePlayer:sendSkillEffect(effectId)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:sendSkillEffect(effectId)
    end
end

function CBasePlayer:getDefence()
    return self.staticAttr.defense
end

function CBasePlayer:getAttack()
    return self.staticAttr.attack
end

function CBasePlayer:buildShowName()
    local nameList = {}
    local nameListNum = 1
    -- title
    if self.staticAttr.title ~= nil then
        nameList[nameListNum] = self.staticAttr.title
        nameListNum = nameListNum + 1
    end

    if self.staticAttr.role ~= -1 then
        local clanTitle = TextFormat.colorGreen .. self.staticAttr.clanName
        if self.staticAttr.role == 0 then
            clanTitle = clanTitle .. TextFormat.colorWrite .. "[Member]"
        end
        if self.staticAttr.role == 10 then
            clanTitle = clanTitle .. TextFormat.colorRed .. "[Elder]"
        end
        if self.staticAttr.role == 20 then
            clanTitle = clanTitle .. TextFormat.colorOrange .. "[Chief]"
        end
        nameList[nameListNum] = clanTitle
        nameListNum = nameListNum + 1
    end

    -- pureName line
    local disName = TextFormat.colorWrite .. self.name;
    if self.staticAttr.lv > 0 then
        disName = TextFormat.colorGold .. "[Lv" .. tostring(self.staticAttr.lv) .. "]" .. TextFormat.colorWrite .. self.name
    end

    nameList[nameListNum] = disName
    nameListNum = nameListNum + 1

    --rebuild name
    local showName
    for i, v in pairs(nameList) do
        local lineName = v
        if (showName == nil) then
            showName = lineName
        else
            showName = showName .. "\n" .. lineName;
        end
    end

    return showName
end

function CBasePlayer:initDynamicAttr()
    local attr = PlayerClassInfo:getClasses(self.userId)
    if attr == nil then
        return
    end
    self.dynamicAttr.hasInit = true
    self.dynamicAttr.clz = attr.class
    self.dynamicAttr.region = attr.region
    self.dynamicAttr.team = attr.team
    self.dynamicAttr.pioneer = attr.pioneer
    self.dynamicAttr.vip = attr.vip
    if self.dynamicAttr.pioneer then
        self.vip = self.dynamicAttr.vip
    end
end

function CBasePlayer:setShowName(name, targetId)
    if self.clientPeer ~= nil then
        self.clientPeer:setShowName(name, targetId or 0)
    end
end

function CBasePlayer:setTeam(team)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setTeam(team)
    end
end

function CBasePlayer:changeHeart(hp, maxHp)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:changeHeart(hp, maxHp)
    end
end

function CBasePlayer:getEntityId()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:hashCode()
    end
    return -1
end

function CBasePlayer:addVehicles(vehicles)
    if self.entityPlayerMP == nil or vehicles == nil then
        return
    end
    for i, vehicle in pairs(vehicles) do
        self.entityPlayerMP:addOwnVehicle(vehicle)
    end
    self.entityPlayerMP:syncOwnVehicle()
end

function CBasePlayer:leaveVehicle()
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:leaveVehicle()
    end
end

function CBasePlayer:consumeDiamonds(uniqueId, diamonds, remark, isConsume)
    if self.clientPeer ~= nil then
        if isConsume == nil then
            self.clientPeer:consumeDiamonds(uniqueId, diamonds, remark, true)
        else
            self.clientPeer:consumeDiamonds(uniqueId, diamonds, remark, isConsume)
        end
    end
end

function CBasePlayer:isVisitor()
    if self.clientPeer ~= nil then
        return self.clientPeer:isVisitor()
    end
    return true
end

function CBasePlayer:setPersonalShopArea(startPos, endPos)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setPersonalShopArea(startPos, endPos)
    end
end

function CBasePlayer:getDiamond()
    if self.entityPlayerMP ~= nil then
        return tonumber(tostring(self.entityPlayerMP:getDiamond()))
    end
    return 0
end

function CBasePlayer:getGold()
    if self.entityPlayerMP ~= nil then
        return tonumber(tostring(self.entityPlayerMP:getGold()))
    end
    return 0
end

function CBasePlayer:setOnFrozen(frozenTime)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setOnFrozen(frozenTime)
    end
end

function CBasePlayer:setOnFire(fireTime)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setOnFire(fireTime)
    end
end

function CBasePlayer:addCustomEffect(name, effectName, duration)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addCustomEffect(name, effectName, duration)
    end
end

function CBasePlayer:getRanch()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getRanch()
    end
end

function CBasePlayer:getBirdSimulator()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getBirdSimulator()
    end
end

function CBasePlayer:setBagInfo(curCapacity, maxCapacity)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:setBagInfo(curCapacity, maxCapacity)
    end
end

function CBasePlayer:setBirdConvert(isConvert)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:setBirdConvert(isConvert)
    end
end

BasePlayer = CBasePlayer

return BasePlayer
--endregion
