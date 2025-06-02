--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

InventoryUtil = {}

function InventoryUtil:fillItem(inv, config)
    local nextSlot = 0
    nextSlot = self:fillItemByType(inv, nextSlot, config.food,
    config.foodNumRange[1], config.foodNumRange[2])

    nextSlot = self:fillItemByType(inv, nextSlot, config.equip,
    config.equipNumRange[1], config.equipNumRange[2])

    nextSlot = self:fillItemByType(inv, nextSlot, config.weapon,
    config.weaponNumRange[1], config.weaponNumRange[2])

    nextSlot = self:fillItemByType(inv, nextSlot, config.materials,
    config.materialsNumRange[1], config.materialsNumRange[2])
end

function InventoryUtil:fillItemByType(inv, slotBegin, config, rangeLow, rangeUpper)

    local itemSlot = slotBegin
    local items = self:randomItem(config, rangeLow, rangeUpper)
    for i, v in pairs(items) do
        if v.num > 64 then
            v.num = 64
        end
        inv:initByItem(itemSlot, v.id, v.num, 0)
        itemSlot = itemSlot + 1
    end

    return itemSlot
end

function InventoryUtil:randomItem(subconfig, numMin, numMax)

    -- 随机出该类型  Item 可以选出的种类数
    local number = 0
    number = math.random(numMax - numMin + 1)
    number = numMin + number

    -- 计算概率范围
    local total = 0
    for i, v in pairs(subconfig) do
        v.choose = false
        v.probfloor = total

        total = total + v.probability
        v.probUpper = total
    end

    local choose = 1
    local rsItems = {}
    while (choose < number) do
        local rs = math.random(0, total)

        for i, v in pairs(subconfig) do
            if (rs >= v.probfloor and rs < v.probUpper and v.choose == false) then

                local item = Item.getItemById(v.id)
                local num = self:randomItemNum(v) --每个种类的数目也是随机

                if (item == nil) then
                    HostApi.log("get item null" .. tostring(v.id))
                end

                if (item:getItemStackLimit() < 64) then
                    num = 1
                end

                rsItems[choose] = {}
                rsItems[choose].id = v.id
                rsItems[choose].num = num

                if v.extraItems ~= nil then
                    rsItems[choose].extraItems = {}
                    for j, extraItem in pairs(v.extraItems) do
                        local extra = {}
                        extra.id = tonumber(extraItem.id)
                        extra.num = tonumber(extraItem.num)
                        rsItems[choose].extraItems[j] = extra
                    end
                end

                v.choose = true
                choose = choose + 1
                break
            end
        end
    end

    return rsItems
end

function InventoryUtil:randomItemNum(item)
    local rs = 0
    local range = item.randomRange[2] - item.randomRange[1]
    if (range ~= 0) then
        rs = math.random(0, range)
    end

    rs = item.randomRange[1] + rs

    return rs
end

function InventoryUtil:prepareChest(config)
    for i, v in pairs(config) do
        local vc = Vector3i.new()
        vc.x = v.x
        vc.y = v.y
        vc.z = v.z
        EngineWorld:setBlock(vc, 54)
    end
end

function InventoryUtil:getPlayerInventoryInfo(player)
    local inv = player:getInventory()
    local inventory = {}
    inventory.item = {}
    inventory.gun = {}
    inventory.armor = {}
    for i = 1, 40 do
        local info = inv:getItemStackInfo(i - 1)
        if info.id > 0 and info.id < 10000 then
            local item = {}
            item.id = info.id
            item.meta = info.meta
            item.num = info.num
            item.stackIndex = i - 1
            if i <= 36 then
                if (item.id >= 426 and item.id <= 440) or (item.id >= 700 and item.id <= 714) then
                    item.num = 1
                    item.meta = 0
                    item.bullets = info.bullets
                    table.insert(inventory.gun, item)
                else
                    table.insert(inventory.item, item)
                end
            else
                item.num = 1
                item.meta = 0
                table.insert(inventory.armor, item)
            end
        end
    end
    return inventory
end

function InventoryUtil:getPlayerEnderInventoryInfo(player)
    local inv = player:getEnderInventory()
    local enderInv = {}
    enderInv.item = {}
    enderInv.gun = {}
    for i = 1, 27 do
        local info = inv:getItemStackInfo(i - 1)
        if info.id > 0 and info.id < 10000 then
            local item = {}
            item.id = info.id
            item.meta = info.meta
            item.num = info.num
            if item.id >= 426 and item.id <= 440 then
                item.num = 1
                item.meta = 0
                item.bullets = info.bullets
                table.insert(enderInv.gun, item)
            else
                table.insert(enderInv.item, item)
            end
        end
    end
    return enderInv
end

return InventoryUtil
--endregion
