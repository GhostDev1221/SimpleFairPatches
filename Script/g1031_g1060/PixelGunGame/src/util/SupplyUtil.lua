SupplyUtil = {}
SupplyUtil.TYPE = {
    Bullet = 1,
    Defence = 2,
    Health = 3,
    Key = 4,
    Gold = 5
}

function SupplyUtil:onPlayerPickup(itemId, value, player)
    local type = SupplyItemConfig:getTypeById(itemId)
    if type == 0 then
        return
    end
    if type == SupplyUtil.TYPE.Bullet then
        self:onPickupBullet(player, value)
        return
    end
    if type == SupplyUtil.TYPE.Defence then
        self:onPickupDefence(player, value)
        return
    end
    if type == SupplyUtil.TYPE.Health then
        self:onPickupHealth(player, value)
        return
    end
    if type == SupplyUtil.TYPE.Key then
        self:onPickupKey(player, value)
        return
    end
    if type == SupplyUtil.TYPE.Gold then
        self:onPickupGold(player, value)
        return
    end
end

function SupplyUtil:onPickupBullet(player, value)
    player:onPickUpBullet(value)
end

function SupplyUtil:onPickupDefence(player, value)
    player:addDefense(value)
end

function SupplyUtil:onPickupHealth(player, value)
    player:addHealth(value)
end

function SupplyUtil:onPickupKey(player, value)
    player:addKey(value)
end

function SupplyUtil:onPickupGold(player, value)
    player:addCurrency(value)
end