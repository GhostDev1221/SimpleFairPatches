require "base.util.class"
require "base.data.BasePlayer"
require "base.util.InventoryUtil"
require "util.DbUtil"
require "Match"
require "data.GameBird"
require "data.GameBirdBag"
require "data.GameMonster"
require "data.GameChest"
require "data.GameNest"
require "data.PlayerTask"

GamePlayer = class("GamePlayer", BasePlayer)

function GamePlayer:init()
    self:initStaticAttr(0)
    self:initUserProperty()
    self:initUserInfo()
end

function GamePlayer:initUserProperty()
    self.hp = GameConfig.hp
    self.moveSpeed = GameConfig.moveSpeed
    self.jump = GameConfig.jump
    self.hpRecoverCD = GameConfig.hpRecoverCD
    self.hpRecover = GameConfig.hpRecover
    self.awayFromBattleCD = GameConfig.awayFromBattleCD
    self.convertRate = GameConfig.convertRate
    self.novicePackageId = nil
    self.enterFieldIndex = 0
    self.enterDoorIndex = 0

    self.isInBattle = false
    self.isInNestArea = false
    self.isConvert = false
    self.isInVipArea = false

    self.hpChangeTime = 0

    self.curFruitNum = 0
    self.maxBackpackCapacity = 0
    self.totalFruitNum = 0

    self.money = 0
    self.eggTicket = 0
    self.score = 0

    self.drawLuckyOffsets = {}
    self.buyGiftbagList = {} --玩家购买的礼包

    self.buff = {}
    self.allCollectExtra = 0
    self.blueCollectExtra = 0
    self.redCollectExtra = 0
    self.yellowCollectExtra = 0
    self.greenCollectExtra = 0

    self.allCollectCDExtra = 0
    self.blueCollectCDExtra = 0
    self.redCollectCDExtra = 0
    self.yellowCollectCDExtra = 0
    self.greenCollectCDExtra = 0

    self.attackExtra = 0
    self.attackCDExtra = 0

    self.fruitConvertExtra = 0
    self.fruitConvertCDExtra = 0
    self.fruitConvertPercentExtra = 0
    self.flySpeedExtra = 0

    self.moveSpeedExtra = 0
    self.jumpExtra = 0

    -- vip 特权
    self.isVipArea = false
    self.collectVipExtra = 0
    self.convertVipExtra = 0

    self.itemStatusInfos = {}
    self.collectorId = nil
    self.storageBagId = nil
    self.decoration = {
        ["custom_hair"] = nil,
        ["custom_face"] = nil,
        ["clothes_tops"] = nil,
        ["clothes_pants"] = nil,
        ["custom_shoes"] = nil,
        ["custom_glasses"] = nil,
        ["custom_scarf"] = nil,
        ["custom_wing"] = nil,
        ["custom_hat"] = nil,
        ["custom_decorate_hat"] = nil,
        ["custom_hand"] = nil,
        ["custom_tail"] = nil,
        ["custom_wing_flag"] = nil,
        ["custom_foot_halo"] = nil,
        ["custom_back_effect"] = nil,
        ["custom_crown"] = nil
    }

    self.inHandItemId = 0
    self.privilegeIds = {}

    self:setCurrency(self.money)
    self:changeMaxHealth(self.hp)

    self.buyStoreHouseItems = {}
    self.firstLoginTime = os.time()
    self.chestCountdowns = {}

    self.isShowArrow = true
    self.isShowTaskArrow = true
    self.isShowShopArrow = true
end

function GamePlayer:setChestCountDown(chestId, time)
    self.chestCountdowns[chestId] = time
end

function GamePlayer:getChestCountDown(chestId)
    return self.chestCountdowns[chestId]
end

function GamePlayer:addProp(id, num)
    if id == 9000001 then
        self:addMoney(num)
    elseif id == 9000002 then
        self:AddEggTicket(num)
    else
        self.userBirdBag:addBagItem(id, num)
    end
    TaskHelper.dispatch(TaskType.CollectPropEvent, self.rakssid, id, num)
end

function GamePlayer:initUserInfo()
    self.userNest = nil
    self.userBird = nil
    self.userBirdBag = nil
    self.userMonster = nil
    self.taskControl = nil
end

function GamePlayer:addPrivilegeId(id)
    if type(id) == "number" then
        if id == 10003 then
            self:setVipArea()
        elseif id == 10004 then
            self:setVipCollect()
        elseif id == 10005 then
            self:setVipConvert()
        elseif id == 10006 then
            self:setVipHp()
        end
        table.insert(self.privilegeIds, id)
    end
    self:setBirdSimulatorBag()
end

function GamePlayer:isHavePrivilegeId(id)
    if type(id) ~= "number" then
        return false
    end
    for _, v in pairs(self.privilegeIds) do
        if v == id then
            return true
        end
    end
    return false
end

function GamePlayer:getTaskControl()
    return self.taskControl
end

function GamePlayer:getPackageTime(timeLeft)
    if type(self.novicePackageId) == "number" then
        return -1
    end
    local endTime = self.firstLoginTime + timeLeft * 24 * 60 * 60
    local passageTime = endTime - os.time()
    return passageTime * 1000
end

CurrencyType = {
    Diamond = 1,
    Money = 3,
    EggTicket = 4
}

-- //1 not  buy  2  not use 3 in use
function GamePlayer:GetItemStatus(itemId)
    local status = self.itemStatusInfos[itemId]
    return status == nil and StoreItemStatus.NotBuy or status
end
function GamePlayer:SetItemStatus(itemId, status)
    self.itemStatusInfos[itemId] = status
end
function GamePlayer:AddCanAcceptTask(taskId)
    self.canAcceptTasks[taskId] = true
end

function GamePlayer:CheckMainTaskIsComplete(taskId)
    return self.completeTasks[taskId] and true or false
end

function GamePlayer:AddEggTicket(num)
    if type(num) == "number" and num > 0 then
        self.eggTicket = self.eggTicket + num
        self:setBirdSimulatorPlayerInfo()
    end
    return self.eggTicket
end

function GamePlayer:GetTicketNum()
    return self.eggTicket
end

function GamePlayer:SubEggTicket(num)
    if num > 0 and self.eggTicket - num >= 0 then
        self.eggTicket = self.eggTicket - num
        self:setBirdSimulatorPlayerInfo()
        return true
    end
    return false
end

function GamePlayer:GetMoneyNum()
    return self:getCurrency()
end

-- 设置采集器
function GamePlayer:SetCollector(itemId, actorName, actorId)
    if type(itemId) == "number" then
        if type(self.collectorId) == "number" then
            self.itemStatusInfos[self.collectorId] = StoreItemStatus.NotUse
            self:removeItem(self.collectorId, 1)
        end
        self.collectorId = itemId
        self:addItem(self.collectorId, 1)
        self.itemStatusInfos[self.collectorId] = StoreItemStatus.OnUser
    end
end

-- 设置储存罐
function GamePlayer:SetStorageBag(itemId, actorName, actorId)
    if type(itemId) == "number" then
        if type(self.storageBagId) == "number" then
            self.itemStatusInfos[self.storageBagId] = StoreItemStatus.NotUse
        end
        self.storageBagId = itemId
        self:setBackPackUI(itemId)
        self.entityPlayerMP:changeClothes("custom_bag", actorId)
        self.itemStatusInfos[self.storageBagId] = StoreItemStatus.OnUser
    end
end

-- 设置装饰
function GamePlayer:SetDecoration(itemId, actorName, actorId)
    if type(itemId) == "number" then
        local curDecorationId = self.decoration[actorName]
        if type(curDecorationId) == "number" then
            self.itemStatusInfos[curDecorationId] = StoreItemStatus.NotUse
        end
        self.itemStatusInfos[itemId] = StoreItemStatus.OnUser
        self.decoration[actorName] = itemId
        self.entityPlayerMP:changeClothes(actorName, actorId)
    end
end

function GamePlayer:getHaveItemFromStore(itemId)
    local res = self.itemStatusInfos[itemId]
    return res and true or false
end

function GamePlayer:GetDrawLuckyIndexByPoolId(id, maxCount)
    if self.drawLuckyOffsets[id] == nil then
        self.drawLuckyOffsets[id] = 1
    end
    local offset = self.drawLuckyOffsets[id]
    self.drawLuckyOffsets[id] = math.min(offset + 1, maxCount)
    return offset
end

function GamePlayer:OnRandKey(poolId)
    self.drawLuckyOffsets[poolId] = 1
end

function GamePlayer:AddGiftbag(giftId)
    if self.buyGiftbagList[giftId] == nil then
        self.buyGiftbagList[giftId] = 1
    else
        self.buyGiftbagList[giftId] = self.buyGiftbagList[giftId] + 1
    end
end

function GamePlayer:GetGiftNumberof(giftId)
    local num = self.buyGiftbagList[giftId]
    return num or 0
end

function GamePlayer:teleInitPos()
    self:teleportPos(GameConfig.initPos)
end

function GamePlayer:onMoneyChange()
    self.money = self:getCurrency()
end

function GamePlayer:addMoney(money)
    if money > 0 then
        self:addCurrency(money)
    end
end

function GamePlayer:subMoney(money)
    if money > 0 then
        self:subCurrency(money)
    end
end

function GamePlayer:setMaxBackpackCapacity(capacity)
    self.maxBackpackCapacity = capacity
end

function GamePlayer:getMaxBackpackCapacity()
    return self.maxBackpackCapacity
end

function GamePlayer:isEnoughFruitNum(num)
    if num > 0 and self.curFruitNum >= num then
        return true
    end

    return false
end

function GamePlayer:isBackpackFull()
    return self.curFruitNum >= self.maxBackpackCapacity
end

function GamePlayer:setCurFruitNum(num)
    if num > 0 then
        self.curFruitNum = num
    end
end

function GamePlayer:setTotalFruitNum(num)
    if num > 0 then
        self.totalFruitNum = num
    end
end

function GamePlayer:addFruitNum(num)
    if num <= 0 or self.curFruitNum >= self.maxBackpackCapacity then
        return
    end

    local tempNum = self.maxBackpackCapacity - self.curFruitNum

    self.curFruitNum = self.curFruitNum + num
    if self:isBackpackFull() then
        self.curFruitNum = self.maxBackpackCapacity
        self.totalFruitNum = self.totalFruitNum + tempNum
        self.appIntegral = self.appIntegral + tempNum

        if self.isShowArrow == true then
            if self.userNest ~= nil then
                local nestInfo = NestConfig:getNestInfoById(self.userNest.nestIndex)
                local pos = VectorUtil.newVector3(nestInfo.pos.x, nestInfo.pos.y, nestInfo.pos.z)
                HostApi.changeGuideArrowStatus(self.rakssid, pos, true)
            end
        end
    else
        self.totalFruitNum = self.totalFruitNum + num
        self.appIntegral = self.appIntegral + num
    end
    self:setBirdSimulatorPlayerInfo()
    self:setBagInfo(self.curFruitNum, self:getMaxBackpackCapacity())
end

function GamePlayer:subFruitNum(num)
    if num <= 0 or self.curFruitNum < num then
        return
    end
    self.curFruitNum = self.curFruitNum - num
    self:setBirdSimulatorPlayerInfo()
    self:setBagInfo(self.curFruitNum, self:getMaxBackpackCapacity())
end

function GamePlayer:reward()
    RewardManager:getUserGoldReward(self.userId, self.score, function(data)

    end)
end

function GamePlayer:onQuit()
    if self.taskControl ~= nil then
        self.taskControl:OnPlayerLogout()
    end
    ChestManager:onPlayerLogout(self)
    -- 重置鸟巢格位状态
    if self.userBirdBag ~= nil then
        if self.userNest ~= nil then
            self.userBirdBag:setNests(self.userNest.nestIndex, false)
        end
    end

    -- 删除墙上的名字
    if self.userNest ~= nil then
        local nestInfo = NestConfig:getNestInfoById(self.userNest.nestIndex)
        if nestInfo ~= nil then
            local y = nestInfo.pos.y
            if self.userNest.nestIndex % 2 == 0 then
                y = y + 5
            else
                y = y + 7
            end

            local textPos = VectorUtil.newVector3(nestInfo.pos.x + 2.5, y, nestInfo.pos.z)
            HostApi.deleteWallText(textPos)
        end
    end

    -- 删除小鸟entity
    if self.userBird ~= nil then
        self.userBird:deleteBirds()
    end

    if self.userMonster ~= nil then
        self.userMonster:setMonsterLostTarget()
    end

    SceneManager:deleteUserInfoByUid(self.userId)
    self:initUserInfo()

    -- 释放领地
    HostApi.sendReleaseManor(self.userId)
end

function GamePlayer:addScore(score)
    self.score = self.score + score
end

function GamePlayer:prepareDataSaveToDB()
    local data = {
        money = self:getCurrency(),
        fruit = self.curFruitNum,
        totalFruit = self.totalFruitNum,
        ticket = self.eggTicket,
        items = self:getItemsHasBought(),
        firstLoginTime = self.firstLoginTime,
        novicePackageId = self.novicePackageId,
        privilegeIds = self.privilegeIds,
        nestTip = 1,
        taskTip = 1,
        shopTip = 1
    }

    if self.isShowArrow == false then
        data.nestTip = 0
    end

    if self.isShowTaskArrow == false then
        data.taskTip = 0
    end

    if self.isShowShopArrow == false then
        data.shopTip = 0
    end

    data.chestCountdowns = {}
    data.buyGiftbagList = {}
    data.drawLuckyOffsets = {}
    for k, v in pairs(self.chestCountdowns) do
        data.chestCountdowns[tostring(k)] = v
    end
    for k, v in pairs(self.buyGiftbagList) do
        data.buyGiftbagList[tostring(k)] = v
    end
    for k, v in pairs(self.drawLuckyOffsets) do
        data.drawLuckyOffsets[tostring(k)] = v
    end

    return data
end

function GamePlayer:getItemsHasBought()
    local data = {}
    for k, v in pairs(self.itemStatusInfos) do
        data[tostring(k)] = v
    end
    return data
end

function GamePlayer:addItemsHasBought(data)
    for k, v in pairs(data) do
        self.itemStatusInfos[tonumber(k)] = v
    end
    for itemid, status in pairs(self.itemStatusInfos) do
        local curItem = StoreHouseItems:getItemInfo(itemid)
        if curItem ~= nil then
            if status == StoreItemStatus.OnUser then
                if curItem.ItemType == 1 then --采集器
                    self:SetCollector(itemid, curItem.actorName, curItem.actorId)
                elseif curItem.ItemType == 2 then --存储灌
                    self:SetStorageBag(itemid, curItem.actorName, curItem.actorId)
                elseif curItem.ItemType == 3 then --装饰
                    self:SetDecoration(itemid, curItem.actorName, curItem.actorId)
                end
            end
        end
    end
end

function GamePlayer:initDataFromDB(data, subKey)
    -- player data
    if subKey == DbUtil.TAG_PLAYER then
        if #data ~= 0 then
            self:initPlayerDataFromDB(data)
        else
            self:initFirstItems()
        end
        DBManager:getPlayerData(self.userId, DbUtil.TAG_BIRD)
    end

    -- bird data
    if subKey == DbUtil.TAG_BIRD then
        if self.userBird == nil then
             return
        end

        if #data ~= 0 then
            self.userBird:initDataFromDB(data)
        end

        DBManager:getPlayerData(self.userId, DbUtil.TAG_BAG)
        DBManager:getPlayerData(self.userId, DbUtil.TAG_MONSTER)
    end

    -- bag data
    if subKey == DbUtil.TAG_BAG then
        if self.userBirdBag == nil then
            return
        end

        if #data ~= 0 then
            self.userBirdBag:initDataFromDB(data)
        end
        self:setBirdSimulatorInfo()
        self:setBagInfo(self.curFruitNum, self:getMaxBackpackCapacity())
        DrawLuckyManager:SyncDrawLucky(self)

        -- 同步门能否走过
        for i, v in pairs(FieldConfig.door) do
            if tonumber(v.type) == 0 then
                if tonumber(v.entityId) ~= 0 and tonumber(self.userBirdBag.maxCarryBirdNum) >= tonumber(v.requirement) then
                    EngineWorld:getWorld():updateSessionNpc(v.entityId, self.rakssid, "", v.actorName, v.bodyName, v.bodyId2, "", "", 0, false)
                end
            elseif tonumber(v.type) == 1 then
                -- vip
                if self.isVipArea and tonumber(self.userBirdBag.maxCarryBirdNum) >= tonumber(v.requirement) then
                    EngineWorld:getWorld():updateSessionNpc(v.entityId, self.rakssid, "", v.actorName, v.bodyName, v.bodyId2, "", "", 0, false)
                end
            end
        end

        DBManager:getPlayerData(self.userId, DbUtil.TAG_TASK)
    end

    -- monster data
    if subKey == DbUtil.TAG_MONSTER then
        if self.userMonster == nil then
            return
        end

        if #data ~= 0 then
            self.userMonster:initDataFromDB(data)
        end
    end

    -- task data
    if subKey == DbUtil.TAG_TASK then
        local taskCon = self:getTaskControl()
        if taskCon ~= nil then
            taskCon:onReadData(self.userId, data)
        end
    end

end

function GamePlayer:initPlayerDataFromDB(data)
    local item = json.decode(data)
    self:addItemsHasBought(item.items)
    self:setCurrency(tonumber(item.money))
    self:setCurFruitNum(tonumber(item.fruit))
    self:setTotalFruitNum(tonumber(item.totalFruit))
    self:AddEggTicket(tonumber(item.ticket))
    self.firstLoginTime = item.firstLoginTime
    self.novicePackageId = item.novicePackageId
    if tonumber(item.nestTip) == 0 then
        self.isShowArrow = false
    end

    if tonumber(item.taskTip) == 0 then
        self.isShowTaskArrow = false
    end

    if tonumber(item.shopTip) == 0 then
        self.isShowShopArrow = false
    end

    self.privilegeIds = item.privilegeIds or {}
    if type(item.chestCountdowns) == "table" then
        for k, v in pairs(item.chestCountdowns) do
            self.chestCountdowns[tonumber(k)] = v
        end
    end
    if type(item.buyGiftbagList) == "table" then
        for k, v in pairs(item.buyGiftbagList) do
            self.buyGiftbagList[tonumber(k)] = v
        end
    end
    if type(item.drawLuckyOffsets) == "table" then
        for k, v in pairs(item.drawLuckyOffsets) do
            self.drawLuckyOffsets[tonumber(k)] = v
        end
    end
    PersonalStoreManager:SyncStoreInfo(self)
    NovicePackage:SyncNovicePackageInfo(self)
    ChestManager:SyncChestInfo(self)
    StoreHouseManager:SyncStoreInfo(self)
    HostApi.changeGuideArrowStatus(self.rakssid, GameConfig.arrowPointToNpcPos, self.isShowTaskArrow)
    self:setVipValue()

    if self.isShowArrow == true and self:isBackpackFull() then
        if self.userNest ~= nil then
            local nestInfo = NestConfig:getNestInfoById(self.userNest.nestIndex)
            local pos = VectorUtil.newVector3(nestInfo.pos.x, nestInfo.pos.y, nestInfo.pos.z)
            HostApi.changeGuideArrowStatus(self.rakssid, pos, true)
        end
    end

    if self.isShowShopArrow == false then
        HostApi.changeGuideArrowStatus(self.rakssid, GameConfig.arrowPointToShopPos, false)
    end
end

function GamePlayer:setVipValue()
    if self:isHavePrivilegeId(10003) then
        self:setVipArea()
    end

    if self:isHavePrivilegeId(10004) then
        -- 采集 + 20%
        self:setVipCollect()
    end

    if self:isHavePrivilegeId(10005) then
        -- 转换 + 50%
        self:setVipConvert()
    end

    if self:isHavePrivilegeId(10006) then
        -- hp + 100%
        self:setVipHp()
    end
end

function GamePlayer:setVipArea()
    self.isVipArea = true
    for i, v in pairs(FieldConfig.door) do
        if tonumber(v.type) == 1 then
            -- vip
            if self.isVipArea and tonumber(self.userBirdBag.maxCarryBirdNum) >= tonumber(v.requirement) then
                EngineWorld:getWorld():updateSessionNpc(
                    v.entityId,
                    self.rakssid,
                    "",
                    v.actorName,
                    v.bodyName,
                    v.bodyId2,
                    "",
                    "",
                    0,
                    false
                )
            end
        end
    end
end

function GamePlayer:setVipCollect()
    -- 采集 + 20%
    self.collectVipExtra = 0.2
end

function GamePlayer:setVipConvert()
    -- 转换 + 50%
    self.convertVipExtra = 0.5
end

function GamePlayer:setVipHp()
    -- hp + 100%
    self:changeMaxHealth(self.hp * 2)
end

function GamePlayer:setBackPackUI(id)
    local capacity = BackpackConfig:getCapacityById(id)
    self:setMaxBackpackCapacity(capacity)
    if self.curFruitNum > capacity then
        self.curFruitNum = capacity
    end
    self:setBagInfo(self.curFruitNum, self:getMaxBackpackCapacity())
    self:setBirdSimulatorPlayerInfo()
end

function GamePlayer:initFirstItems()
    for _, v in pairs(InitItemsConfig.items) do
        if v.type == InitItemsConfig.ITEMS then
            if self.userBirdBag ~= nil then
                self.userBirdBag:addBagItem(v.itemId, v.num)
            end
        end

        if v.type == InitItemsConfig.BACKPACKS then
            local itemInfo = StoreHouseItems:getItemInfo(v.itemId)
            if itemInfo ~= nil then
                self:SetStorageBag(v.itemId, itemInfo.actorName, itemInfo.actorId)
            end
        end

        if v.type == InitItemsConfig.TOOLS then
            local itemInfo = StoreHouseItems:getItemInfo(v.itemId)
            if itemInfo ~= nil then
                self:SetCollector(v.itemId, itemInfo.actorName, itemInfo.actorId)
            end
        end

        if v.type == InitItemsConfig.BIRDS then
            for i = 1, v.num do
                local partIds = BirdConfig:getPartIdsById(v.itemId)
                local id = self.userBird:getLastBirdIndex()
                self.userBird:createBird(id, v.itemId, 1, 0, 1, partIds)
            end
        end
    end
    NovicePackage:SyncNovicePackageInfo(self)
    ChestManager:SyncChestInfo(self)
    StoreHouseManager:SyncStoreInfo(self)
    NovicePackage:SyncNovicePackageInfo(self)
    PersonalStoreManager:SyncStoreInfo(self)
    HostApi.changeGuideArrowStatus(self.rakssid, GameConfig.arrowPointToNpcPos, self.isShowTaskArrow)
end

function GamePlayer:setBirdSimulatorBag()
    local birdBag = BirdBag.new()
    birdBag.curCarry = self.userBirdBag.curCarryBirdNum
    birdBag.maxCarry = self.userBirdBag.maxCarryBirdNum
    birdBag.curCapacity = self.userBirdBag.curCapacityBirdNum
    birdBag.maxCapacity = self.userBirdBag.maxCapacityBirdNum
    birdBag.maxCarryLevel = BirdBagConfig:getMaxCarryBag()
    birdBag.maxCapacityLevel = BirdBagConfig:getMaxCapacityBag()
    birdBag.expandCarryPrice = BirdBagConfig:getNextExpandCarryPrice(self.userBirdBag.maxCarryBirdNum)
    birdBag.expandCapacityPrice = BirdBagConfig:getNextExpandCapacityPrice(self.userBirdBag.maxCapacityBirdNum)
    birdBag.expandCurrencyType = BirdBagConfig:getNextExpandCarryMoneyType(self.userBirdBag.curCarryBirdNum)
    birdBag.birds = self.userBird:getBirdUIInfo()
    self:getBirdSimulator():setBag(birdBag)
end

function GamePlayer:setBirdSimulatorPlayerInfo()
    local playerInfo = BirdPlayerInfo.new()
    playerInfo.score = self.totalFruitNum
    playerInfo.eggTicket = self.eggTicket
    playerInfo.isConvert = self:getConvert()
    self:getBirdSimulator():setPlayerInfo(playerInfo)
end

function GamePlayer:setBirdSimulatorBirdDress()
    local data = {}
    if self.userBird ~= nil then
        for i, v in pairs(self.userBird.dress) do
            local birdDress = BirdDress.new()
            birdDress.id = tonumber(v.itemId)
            birdDress.num = 1
            birdDress.type = ""
            birdDress.isUse = tonumber(v.bird)
            birdDress.bodyId = ""
            birdDress.bodyName = ""
            local partInfo = BirdConfig:getPartInfoById(v.itemId)
            if partInfo ~= nil then
                birdDress.type = tonumber(partInfo.type)
                birdDress.bodyId = partInfo.bodyId
                birdDress.bodyName = partInfo.bodyName
            end
            table.insert(data, birdDress)
        end
    end
    self:getBirdSimulator():setDress(data)
end

function GamePlayer:setBirdSimulatorFood()
    if self.userBirdBag == nil then
        return
    end

    local data = {}
    for i, v in pairs(self.userBirdBag.bagItems) do
        local birdFood = BirdFood.new()
        birdFood.id = tonumber(i)
        birdFood.num = tonumber(v)
        birdFood.icon = ""
        birdFood.desc = ""
        birdFood.name = ""
        local foodInfo = BirdConfig:getFoodInfoById(tonumber(i))
        if foodInfo ~= nil then
            birdFood.icon = foodInfo.icon
            birdFood.desc = foodInfo.desc
            birdFood.name = foodInfo.name
        end
        table.insert(data, birdFood)
    end
    self:getBirdSimulator():setFoods(data)
end

function GamePlayer:setBirdSimulatorAtlas()
    local data = {}
    local eggsInfo = BonusConfig:getEggsInfo()
    for _, v in pairs(eggsInfo) do
        local atlas = BirdAtlas.new()
        atlas.id = tonumber(v.id)
        atlas.eggIcon = v.icon
        atlas.items = self.userBird:getAtlasInfo(v.birds)
        table.insert(data, atlas)
    end

    self:getBirdSimulator():setAtlas(data)
end

function GamePlayer:setBirdSimulatorBuff()
    local data = {}

    for buffId, v in pairs(self.buff) do
        local buff = BirdBuff.new()
        buff.id = tonumber(buffId)
        buff.level = tonumber(v.times)
        buff.timeLeft = 1000 * (v.activeTime - (os.time() - v.addTime))
        buff.icon = v.icon
        if buff.timeLeft < 0 then
            buff.timeLeft = 0
        end
        table.insert(data, buff)
    end

    self:getBirdSimulator():setBuffs(data)
end

function GamePlayer:setTimePrices()
    local price = PaymentConfig:initBirdSimulatorTimePayment()
    self:getBirdSimulator():setTimePrices(price)
end

function GamePlayer:setBirdSimulatorInfo()
    self:setBirdBagNum()
    self:setBirdSimulatorBirdDress()
    self:setBirdSimulatorBag()
    self:setBirdSimulatorPlayerInfo()
    self:setBirdSimulatorFood()
    self:setBirdSimulatorAtlas()
    self:setTimePrices()
    if self.userBirdBag ~= nil and self.userNest ~= nil then
        self.userBirdBag:setNests(self.userNest.nestIndex, true)
    end
end

function GamePlayer:getConvert()
    return self.isConvert
end

function GamePlayer:setConvert(isConvert)
    self.isConvert = isConvert
end

function GamePlayer:toggleConvert()
    if self:getConvert() then
        self:setConvert(false)
        if self.userBird ~= nil then
            self.userBird:setStopConvertState()
        end
    else
        self:setConvert(true)
        if self.userBird ~= nil then
            self.userBird:setStartConvertState()
        end
    end
end

function GamePlayer:setHpChangeTime(time)
    self.hpChangeTime = time
end

function GamePlayer:getHpChangeTime()
    return self.hpChangeTime
end

function GamePlayer:addBuff(id, entityId)
    local buffId = tostring(id)
    if buffId == "0" then
        return
    end

    local buffInfo = BirdConfig:getGiftInfoById(buffId)
    if buffInfo == nil then
        return
    end

    if buffInfo.type == 3 then
        if buffInfo.coinId >= 1057 and buffInfo.coinId <= 1066 then
            -- 果币
            local level = 1
            local coinLevel = SceneManager:getCoinLevel(entityId)
            if coinLevel ~= nil then
                level = coinLevel
            end

            local money = tonumber(buffInfo.baseValue) * tonumber(level)
            self:addMoney(money)
            SceneManager:removeCoinLevel(entityId)
            TaskHelper.dispatch(TaskType.CollectPropEvent, self.rakssid, 9000001, money)
        else
            -- 背包物品
            if self.userBirdBag ~= nil then
                self.userBirdBag:addBagItem(buffInfo.baseValue, 1)
                local birdGain = BirdGain.new()
                birdGain.itemId = buffInfo.baseValue
                birdGain.num = 1
                birdGain.icon = buffInfo.icon
                HostApi.sendBirdGain(self.rakssid, {birdGain})
            end
            TaskHelper.dispatch(TaskType.CollectPropEvent, self.rakssid, buffInfo.baseValue, 1)
        end

        return
    end

    if self.buff[buffId] == nil then
        self.buff[buffId] = {}
        self.buff[buffId].times = 1
        self.buff[buffId].type = buffInfo.type
        self.buff[buffId].icon = buffInfo.icon
        self.buff[buffId].baseValue = tonumber(buffInfo.baseValue)
        self.buff[buffId].activeTime = tonumber(buffInfo.activeTime)
        self.buff[buffId].addTime = os.time()
    else
        self.buff[buffId].activeTime = tonumber(buffInfo.activeTime)
        self.buff[buffId].addTime = os.time()
        self.buff[buffId].times = self.buff[buffId].times + 1
        if self.buff[buffId].times > buffInfo.maxTimes then
            self.buff[buffId].times = buffInfo.maxTimes
        end
    end

    local value = self.buff[buffId].baseValue * self.buff[buffId].times
    self:setBuffValue(buffId, value)
    self:setBirdSimulatorBuff()
end

function GamePlayer:removeBuff(buffId)
    self:setBuffValue(buffId, 0)
    self.buff[buffId] = nil
    self:setBirdSimulatorBuff()
end

function GamePlayer:setBuffValue(buffId, value)
    if buffId == "9010" then
        self.allCollectExtra = value
    elseif buffId == "9011" then
        self.blueCollectExtra = value
    elseif buffId == "9012" then
        self.redCollectExtra = value
    elseif buffId == "9013" then
        self.yellowCollectExtra = value
    elseif buffId == "9014" then
        --elseif buffId == "9020" then
        --    self.allCollectCDExtra = value
        --elseif buffId == "9021" then
        --    self.blueCollectCDExtra = value
        --elseif buffId == "9022" then
        --    self.redCollectCDExtra = value
        --elseif buffId == "9023" then
        --    self.yellowCollectCDExtra = value
        --elseif buffId == "9024" then
        --    self.greenCollectCDExtra = value
        self.greenCollectExtra = value
    elseif buffId == "9030" then
        --elseif buffId == "9040" then
        --    self.attackCDExtra = value
        --elseif buffId == "9050" then
        --    self.fruitConvertExtra = value
        --elseif buffId == "9060" then
        --    self.fruitConvertCDExtra = value
        --elseif buffId == "9070" then
        --    self.fruitConvertPercentExtra = value
        --elseif buffId == "9080" then
        --    self.flySpeedExtra = value
        self.attackExtra = value
    elseif buffId == "8020" then
        self.moveSpeedExtra = value
        self:setSpeedAddition(self.moveSpeedExtra + self.moveSpeed)
    --elseif buffId == "8030" then
    --    self.jumpExtra = value
    end
end

function GamePlayer:getAllCollectExtra()
    return self.allCollectExtra
end

function GamePlayer:getColorCollectExtra(blockId)
    local value = 0
    if blockId >= 1301 and blockId <= 1303 then
        value = self.redCollectExtra
    end
    if blockId >= 1304 and blockId <= 1306 then
        value = self.yellowCollectExtra
    end
    if blockId >= 1307 and blockId <= 1309 then
        value = self.blueCollectExtra
    end
    if blockId >= 1310 and blockId <= 1312 then
        value = self.greenCollectExtra
    end
    return value
end

function GamePlayer:getFruitColorByBlockId(blockId)
    local value = 0
    if blockId >= 1301 and blockId <= 1303 then
        value = 1
    end
    if blockId >= 1304 and blockId <= 1306 then
        value = 2
    end
    if blockId >= 1307 and blockId <= 1309 then
        value = 3
    end
    if blockId >= 1310 and blockId <= 1312 then
        value = 4
    end
    return value
end

function GamePlayer:generateMonster()
    if self.enterFieldIndex == 0 then
        return
    end

    if self.userMonster ~= nil then
        self.userMonster:generateMonster(self:getPosition())
    end
end

function GamePlayer:onRespawn()
    self.curFruitNum = 0
    self:changeMaxHealth(self.hp)
    self:setVipValue()

    if self.userNest ~= nil then
        local nestInfo = NestConfig:getNestInfoById(self.userNest.nestIndex)
        self:teleportPosWithYaw(nestInfo.pos, nestInfo.yaw)
    end

    if self.userBird ~= nil then
        self.userBird:respawnBirds()
    end

    for itemid, status in pairs(self.itemStatusInfos) do
        local curItem = StoreHouseItems:getItemInfo(itemid)
        if curItem ~= nil then
            if status == StoreItemStatus.OnUser then
                if curItem.ItemType == 2 then --采集器
                    self:SetStorageBag(itemid, curItem.actorName, curItem.actorId)
                end
            end
        end
    end

    self:setBirdSimulatorPlayerInfo()
    self:setBagInfo(self.curFruitNum, self:getMaxBackpackCapacity())
end

function GamePlayer:setBirdBagNum()
    local curCarryBirdNum = self.userBird:getBirdNumInWorld()
    local curCapacityBirdNum = self.userBird:getBirdNum()
    self.userBirdBag:setCurCarryBirdNum(curCarryBirdNum)
    self.userBirdBag:setCurCapacityBirdNum(curCapacityBirdNum)
end

function GamePlayer:collectFruit(score, maxStage, stage, blockId)
    local fruitNum = 0
    local layer = 0

    local toolInfo = ToolConfig:getToolByItemId(self.inHandItemId)
    if toolInfo ~= nil then
        local extra = ToolConfig:getExtraPercent(self.inHandItemId, blockId)
        local allCollectExtra = self:getAllCollectExtra()
        local colorCollectExtra = self:getColorCollectExtra(blockId)
        local remainLayer = maxStage - stage.value
        if remainLayer >= toolInfo.layer then
            fruitNum =
                math.ceil(
                score * toolInfo.layer * (1 + extra + allCollectExtra + colorCollectExtra + self.collectVipExtra)
            )
            layer = toolInfo.layer
        else
            fruitNum =
                math.ceil(
                score * remainLayer * (1 + extra + allCollectExtra + colorCollectExtra + self.collectVipExtra)
            )
            layer = remainLayer
        end
    else
        fruitNum = score
        layer = 1
    end

    if fruitNum < 1 then
        fruitNum = 1
    end

    return fruitNum, layer
end

function GamePlayer:resetBattleState()
    self:setHpChangeTime(os.time())
    self.isInBattle = false
end

return GamePlayer

--endregion
