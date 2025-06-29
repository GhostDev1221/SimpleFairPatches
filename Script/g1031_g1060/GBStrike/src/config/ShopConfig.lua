---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2018/11/8 11:03
---
ShopConfig = {}
ShopConfig.Shop = {}

function ShopConfig:init(shop)
    for shopIndex, element in pairs(shop) do
        local shopElement = {}
        shopElement.type = element.type
        shopElement.icon = element.icon
        shopElement.name = element.name
        shopElement.goods = {}
        for goodsIndex, goodsItem in pairs(element.goods) do
            local item = {}
            item.desc = goodsItem.desc
            item.gid = goodsItem.price[1]
            item.gmt = goodsItem.price[2]
            item.gc = goodsItem.price[3]
            item.eid = goodsItem.price[4]
            item.ec1 = goodsItem.price[5]
            item.ec2 = goodsItem.price[6]
            item.limit = goodsItem.price[7]
            shopElement.goods[goodsIndex] = item
        end
        self.Shop[shopIndex] = shopElement
    end
end

function ShopConfig:prepareShop()
    for shopIndex, element in pairs(self.Shop) do
        EngineWorld:addGoodsGroupToShop(element.type, element.icon, element.name)
        for goodsIndex, goodsItem in pairs(element.goods) do
            EngineWorld:addGoodsToShop(element.type, self.newGoods(goodsItem))
        end
    end
end

function ShopConfig.newGoods(item)
    local goodsItem = Goods.new()
    goodsItem.desc = item.desc
    goodsItem.itemId = item.gid
    goodsItem.itemMeta = item.gmt
    goodsItem.itemNum = item.gc
    goodsItem.coinId = item.eid
    goodsItem.blockymodsPrice = item.ec1
    goodsItem.blockmanPrice = item.ec2
    goodsItem.limit = item.limit
    return goodsItem
end

return ShopConfig