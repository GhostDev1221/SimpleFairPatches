---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by work.
--- DateTime: 2018/8/7 19:22
---
ShopConfig = {}

ShopConfig.Shop = {}

function ShopConfig:init(shop)
    for groupIndex, group in pairs(shop) do
        local goodsGroup = {}
        goodsGroup.type = group.type
        goodsGroup.icon = group.icon
        goodsGroup.name = group.name
        goodsGroup.goods = {}
        for goodsIndex, goodsItem in pairs(group.goods) do
            local item = {}
            item.gid = goodsItem.price[1]
            item.gmt = goodsItem.price[2]
            item.gc = goodsItem.price[3]
            item.eid = goodsItem.price[4]
            item.ec1 = goodsItem.price[5]
            item.ec2 = goodsItem.price[6]
            item.limit = goodsItem.price[7]
            item.desc = goodsItem.desc
            goodsGroup.goods[goodsIndex] = item
        end
        self.Shop[groupIndex] = goodsGroup
    end
end

function ShopConfig:prepareShop()
    for groupIndex, group in pairs(self.Shop) do
        EngineWorld:addGoodsGroupToShop(group.type, group.icon, group.name)
        for goodsIndex, goods in pairs(group.goods) do
            EngineWorld:addGoodsToShop(group.type, self.newGoods(goods))
        end
    end
end

function ShopConfig.newGoods(item)
    local goods = Goods.new()
    goods.itemId =  item.gid
    goods.itemMeta =  item.gmt
    goods.itemNum =  item.gc
    goods.coinId =  item.eid
    goods.blockymodsPrice =  item.ec1
    goods.blockmanPrice =  item.ec2
    goods.limit =  item.limit
    goods.desc =  item.desc
    return goods
end

return ShopConfig