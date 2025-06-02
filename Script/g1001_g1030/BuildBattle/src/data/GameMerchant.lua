---
--- Created by Yaoqiang.
--- DateTime: 2018/6/22 0025 17:50
---
require "Match"
require "base.util.MerchantUtil"

GameMerchant = class()

function GameMerchant:ctor(pos, yaw, name, sp_room_id, index)
    self.index = index
    self.sp_room_id = sp_room_id
    self.id = EngineWorld:addMerchantNpc(pos, yaw, name)
    self:upgrade()
end

function GameMerchant:upgrade()
    self:syncPlayers()
end

function GameMerchant:syncPlayers()
    local players = PlayerManager:getPlayers()
    for i, v in pairs(players) do
        MerchantUtil:changeCommodityList(self.id, v.rakssid, self.index)
    end
end

function GameMerchant:syncPlayer(rakssid)
    MerchantUtil:changeCommodityList(self.id, rakssid, self.index)
end
