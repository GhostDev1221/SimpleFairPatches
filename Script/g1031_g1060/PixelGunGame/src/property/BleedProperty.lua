---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Jimmy.
--- DateTime: 2019/1/12 0012 13:05
---
require "property.BaseProperty"


BleedProperty = class("BleedProperty", BaseProperty)

function BleedProperty:onPlayerUsed(player, target, damage)
    DeBuffManager:createDeBuff(player, target, self.config)
end

return BleedProperty