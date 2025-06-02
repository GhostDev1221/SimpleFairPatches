---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:20
---
require "base.util.class"
require "base.data.BasePlayer"
require "data.GameSeason"
require "util.RewardUtil"
require "Match"

GamePlayer = class("GamePlayer", BasePlayer)

function GamePlayer:init()
    self:initStaticAttr(0)
    self.level = 1
    self.money = 0
    self.cur_exp = 0
    self.yaoshi = 0
    self.chest_integral = 0
    self.unlock_map = {}
    self.fragment_jindu = {}
    self.chests = {}
    self.equip_guns = {}
    self.equip_props = {}
    self.equip_blocks = {}
    self.guns = {}
    self.props = {}
    self.blocks = {}
    self.armor_level = 1
    self.armor_upTime = 0
    self.armor_value = 0
    self.rewards = {}
    self.cur_is_random = 0
    self.cur_map_id = ""
    self.mode_first = {}
    self.mode_first_day_id = 0
    self.init_exp = false
    self.vip_time = 0

    self.standByTime = 0
    self.moveHash = ""
    self.addHealth = 0
    self.addDefense = 0
    self.maxHealth = 0
    self.allProperties = {}

    self:teleInitPos()
end

function GamePlayer:initDataFromDB(data, subKey)
    if subKey == DbUtil.GAME_DATA then
        self:initGameDataFromDB(data)
    end
    if subKey == DbUtil.MODE_DATA then
        self:initModeDataFromDB(data)
    end
    if subKey == DbUtil.ARMORY_DATA then
        self:initArmoryDataFromDB(data)
    end
    if subKey == DbUtil.PROTECT_ARMOR then
        self:initProtectArmorDataFromDB(data)
    end
    if subKey == DbUtil.REWARD_DATA then
        self:initRewardDataFromDB(data)
    end
end

function GamePlayer:initGameDataFromDB(data)
    if #data ~= 0 then
        local result = json.decode(data)
        self.level = result.level or 1
        self.money = result.money or 0
        self.cur_exp = result.cur_exp or 0
        self.armor_value = ArmorConfig:getCurArmorValueByLevel(self.armor_level) or result.armor_value
        self.yaoshi = result.yaoshi or 0
        self.chest_integral = result.chest_integral or 0
        self.chests = result.chests or {}
        self.equip_guns = result.equip_guns or {}
        self.equip_props = result.equip_props or {}
        self.equip_blocks = result.equip_blocks or {}
        self.cur_is_random = 0
        self.cur_map_id = result.cur_map_id or ""
        self.mode_first = result.mode_first or {}
        self.mode_first_day_id = result.mode_first_day_id or 0
        self.vip_time = result.vip_time or 0
    end
    local mode_first_day_id = DateUtil.getYearDay()
    if self.mode_first_day_id ~= mode_first_day_id then
        self.mode_first = {}
        self.mode_first_day_id = mode_first_day_id
    end
    if #self.chests == 0 then
        GameChestLottery:initChestLotteryData(self)
    end
    self:setShowName(self:buildShowName())
    self:teleInitPos()
    self:setCurrency(self.money)
    self:initEquipItems()
    self:syncHallInfo()
    self:initMaxHealthByLevel(self.level)
    GameSeason:getUserSeasonInfo(self.userId, false, 3)
    GameGunStore:syncGunStoreData(self)
    GameGunStore:updateEquipAttr(self)
    GameChestLottery:syncChestLotteryData(self)
    RewardUtil:tryConsumeRewards(self)
end

function GamePlayer:initModeDataFromDB(data)
    if #data ~= 0 then
        local result = json.decode(data)
        self.init_exp = result.init_exp or false
        self.unlock_map = result.unlock_map or {}
        self.fragment_jindu = result.fragment_jindu or {}
        self.fragment_jindu_day_id = result.fragment_jindu_day_id or 0
        local fragment_jindu_day_id = DateUtil.getYearDay()
        if self.fragment_jindu_day_id ~= fragment_jindu_day_id then
            self.fragment_jindu = {}
            self.fragment_jindu_day_id = fragment_jindu_day_id
        end

        if not self.init_exp then
            self:addExp(GameConfig.initExp)
            self.init_exp = true
        end
    else
        if not self.init_exp then
            self:addExp(GameConfig.initExp)
            self.init_exp = true
        end
    end
    RewardUtil:tryConsumeRewards(self)
end

function GamePlayer:initArmoryDataFromDB(data)
    if #data ~= 0 then
        local result = json.decode(data)
        self.guns = result.guns or {}
        self.props = result.props or {}
        self.blocks = result.blocks or {}
    end
    if #self.guns == 0 and #self.props == 0 then
        GameGunStore:initGunStoreData(self)
        self:initEquipItems()
    end
    GameGunStore:syncGunStoreData(self)
    RewardUtil:tryConsumeRewards(self)
end

function GamePlayer:initProtectArmorDataFromDB(data)
    if #data ~= 0 then
        local result = json.decode(data)
        self.armor_level = result.armor_level or 1
        self.armor_upTime = result.armor_upTime or 0
        self:initArmorData()
    end
    self:updateDefense()
end

function GamePlayer:initRewardDataFromDB(data)
    if #data ~= 0 then
        local result = json.decode(data)
        self.rewards = result.rewards or {}
    end
    RewardUtil:tryConsumeRewards(self)
end

function GamePlayer:updateDefense()
    self.armor_value = ArmorConfig:getCurArmorValueByLevel(self.armor_level)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:changeDefense(self.armor_value + self.addDefense, self.armor_value + self.addDefense)
    end
end

function GamePlayer:updateHealth()
    self:changeMaxHealth(self.maxHealth + self.addHealth)
end

function GamePlayer:initArmorData()
    if self.armor_upTime ~= 0 then
        local upTime = self.armor_upTime - os.time()
        if upTime > 0 then
            WaitUpgradeQueue:addUpgradeTask(self.userId, WaitUpgradeQueue.UpgradeType.UpgradeArmor, self.armor_level, upTime)
        else
            GameArmor:onUpgradeArmorFinished(self, self.armor_level)
        end
    end
end

function GamePlayer:initEquipItems()
    for type, equip_gun in pairs(self.equip_guns) do
        self:onGetProperties(equip_gun.ItemId, equip_gun.PropertyIds)
        local gun = GunConfig:getGun(equip_gun.Id)
        if gun then
            self:replaceItem(gun.ItemId, 1, 0, tonumber(gun.TabType) - 1, 1000)
            self:addItem(gun.BulletId, gun.SpareBullet, 0, true)
        end
    end
    local props_count = 0
    for _, equip_prop in pairs(self.equip_props) do
        self:onGetProperties(equip_prop.ItemId, equip_prop.PropertyIds)
        local prop_tab = PropConfig:getPropsTab(equip_prop.ItemId)
        if prop_tab then
            self:replaceItem(equip_prop.ItemId, 1, 0, prop_tab + props_count)
        end
        props_count = props_count + 1
    end
    for type, equip_block in pairs(self.equip_blocks) do
        self:onGetProperties(equip_block.ItemId, equip_block.PropertyIds)
        self:replaceItem(equip_block.ItemId, equip_block.Count, 0, tonumber(type) + 1)
    end
end

function GamePlayer:initMaxHealthByLevel(level)
    local maxHealth = ExpConfig:getMaxHp(level)
    self.maxHealth = maxHealth
    self:changeMaxHealth(self.maxHealth + self.addHealth)
end

function GamePlayer:onGetProperties(itemId, propertyIds)
    local properties = PropertyConfig:getPropertyByIds(propertyIds)
    for _, property in pairs(properties) do
        property:onPlayerGet(self)
    end
    self.allProperties[tostring(itemId)] = properties
end

function GamePlayer:onEquipItem(itemId, propertyIds)
    local properties = self.allProperties[tostring(itemId)]
    if not properties then
        properties = PropertyConfig:getPropertyByIds(propertyIds)
        self.allProperties[tostring(itemId)] = properties
    end
    if #properties > 0 then
        for _, property in pairs(properties) do
            property:onPlayerEquip(self)
        end
    end
end

function GamePlayer:onUnloadItem(itemId, propertyIds)
    local properties = self.allProperties[tostring(itemId)]
    if not properties then
        properties = PropertyConfig:getPropertyByIds(propertyIds)
        self.allProperties[tostring(itemId)] = properties
    end
    if #properties > 0 then
        for _, property in pairs(properties) do
            property:onPlayerUnload(self)
        end
    end
end

function GamePlayer:isGameVip()
    return self.vip_time - os.time() > 0
end

function GamePlayer:buildShowName()
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

    local disName = TextFormat.colorWrite .. self.name
    if self:isGameVip() then
        disName = TextFormat.colorGold .. "[VIP]" .. disName
    end

    nameList[nameListNum] = disName
    nameListNum = nameListNum + 1

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

function GamePlayer:getHallInfo()
    local lv = self.level or 1
    local cur_exp = self.cur_exp or 0
    local max_exp, is_max = ExpConfig:getMaxExp(self.level)
    local yaoshi = self.yaoshi
    return lv, cur_exp, max_exp, yaoshi, is_max
end

function GamePlayer:syncHallInfo()
    local lv, cur_exp, max_exp, yaoshi, is_max = self:getHallInfo()
    HostApi.sendShowPixelGunHallInfo(self.rakssid, lv, cur_exp, max_exp, yaoshi, is_max)
end

function GamePlayer:onMoneyChange()
    self.money = self:getCurrency()
end

function GamePlayer:onUnloadGun(type, itemId)
    self:removeItem(itemId, 1)
    local gun = GunConfig:getGunByItemId(itemId)
    if gun then
        self:removeItem(gun.BulletId, gun.SpareBullet)
    end
end

function GamePlayer:onEquipGun(type, itemId)
    self:replaceItem(itemId, 1, 0, tonumber(type) - 1, 1000)
    local gun = GunConfig:getGunByItemId(itemId)
    if gun then
        self:addItem(gun.BulletId, gun.SpareBullet, 0, true)
    end
end

function GamePlayer:onUnloadProp(itemId)
    self:removeItem(itemId, 1)
end

function GamePlayer:onEquipProp(itemId)
    for index, equip_prop in pairs(self.equip_props) do
        self:replaceItem(equip_prop.ItemId, 1, 0, 5 + index)
        if index >= 2 then
            break
        end
    end
end

function GamePlayer:onUnloadBlock(itemId)
    self:removeItem(itemId, 1000)
end

function GamePlayer:onEquipBlock(itemId, count)
    self:replaceItem(itemId, count, 0, 8)
end

function GamePlayer:getModeInfo()
    return ModeSelectConfig:getModeInfo(self)
end

function GamePlayer:unlockMap(map_id)
    if self.unlock_map then
        for _, map in pairs(self.unlock_map) do
            if tonumber(map) == tonumber(map_id) then
                return
            end
        end
        table.insert(self.unlock_map, map_id)
    end
end

function GamePlayer:isUnlockMap(map_id)
    if self.unlock_map then
        for _, map in pairs(self.unlock_map) do
            if tonumber(map) == tonumber(map_id) then
                return true
            end
        end
    end
    return false
end

function GamePlayer:getFragmentJindu(map_id)
    for _, frag in pairs(self.fragment_jindu) do
        if tostring(frag.map_id) == tostring(map_id) then
            return tonumber(frag.jindu)
        end
    end

    return 0
end

function GamePlayer:getModeFirst(gameType)
    for k, v in pairs(self.mode_first) do
        if tostring(v) == tostring(gameType) then
            return false
        end
    end
    return true
end

function GamePlayer:addExp(exp)
    self.cur_exp = self.cur_exp + exp
    local cur_max, is_max = ExpConfig:getMaxExp(self.level)

    while not is_max and self.cur_exp >= cur_max do

        self.level = self.level + 1
        self.cur_exp = self.cur_exp - cur_max

        cur_max, is_max = ExpConfig:getMaxExp(self.level)
    end

    self:syncHallInfo()
end

function GamePlayer:teleInitPos()
    self:teleportPosWithYaw(GameConfig.initPos, 90)
    HostApi.changePlayerPerspece(self.rakssid, 1)
end

function GamePlayer:onMove(x, y, z)
    local hash = x .. ":" .. y .. ":" .. z
    if self.moveHash ~= hash then
        self.moveHash = hash
        self.standByTime = 0
    end
end

function GamePlayer:onTick()
    self.standByTime = self.standByTime + 1

    if self.standByTime == GameConfig.standByTime - 10 then
        -- MsgSender.sendBottomTipsToTarget(self.rakssid, 3, Messages:msgNotOperateTip())
    end
    if self.standByTime >= GameConfig.standByTime then
        self:doPlayerQuit()
    end
end

function GamePlayer:doPlayerQuit()
    BaseListener.onPlayerLogout(self.userId)
    HostApi.sendGameover(self.rakssid, IMessages:msgGameOver(), GameOverCode.GameOver)
end

return GamePlayer

--endregion


