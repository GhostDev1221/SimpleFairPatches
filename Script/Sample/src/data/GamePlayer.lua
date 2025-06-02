---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:20
---
require "base.util.class"
require "base.data.BasePlayer"
require "Match"

GamePlayer = class("GamePlayer", BasePlayer)

function GamePlayer:init()

    self:initStaticAttr()


    self:teleInitPos()

end

function GamePlayer:teleInitPos()
    self:teleportPos(GameConfig.initPos)
end

function GamePlayer:reward()

end

return GamePlayer

--endregion


