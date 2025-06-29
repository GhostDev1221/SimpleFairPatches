---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Jimmy.
--- DateTime: 2019/1/10 0010 17:52
---
require "skill.BaseSkill"

AddHeadShotSkill = class("AddHeadShotSkill", BaseSkill)
AddHeadShotSkill.AttributeType = {
    Duration = "6051",
    AddHeadShot = "6052"
}

function AddHeadShotSkill:onInitAttributeFinish()
    self.players = {}
    self.duration = self.duration + self:getAttributeById(AddHeadShotSkill.AttributeType.Duration)
    self.damage = self.damage + self:getAttributeById(AddHeadShotSkill.AttributeType.AddHeadShot)
end

function AddHeadShotSkill:createSkillEffect(name, time)
    local creator = self:getCreator()
    if #name > 6 and time > 0 then
        local add = self:getAttributeById(AddHeadShotSkill.AttributeType.Duration) * 1000
        creator:addCustomEffect("AddHeadShotSkill", name, time + add)
    end
end

function AddHeadShotSkill:onPlayerEffected(player)
    if self.players[tostring(player.userId)] then
        return
    end
    player.addHeadShot = player.addHeadShot + self.damage
    self.players[tostring(player.userId)] = true
end

function AddHeadShotSkill:onDestroy()
    for userId, _ in pairs(self.players) do
        local player = PlayerManager:getPlayerByUserId(userId)
        if player ~= nil then
            player.addHeadShot = player.addHeadShot - self.damage
        end
    end
    self.players = {}
end

return AddHeadShotSkill