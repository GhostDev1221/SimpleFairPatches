---
--- Created by Jimmy.
--- DateTime: 2018/8/24 0024 10:36
---
require "data.GameMineResource"

MineResourceConfig = {}
MineResourceConfig.mines = {}

function MineResourceConfig:init(mines)
    self:initMines(mines)
end

function MineResourceConfig:initMines(mines)
    for _, mine in pairs(mines) do
        local item = {}
        item.id = mine.id
        item.blockId = tonumber(mine.blockId)
        item.startPos = VectorUtil.newVector3i(tonumber(mine.x1), tonumber(mine.y1), tonumber(mine.z1))
        item.endPos = VectorUtil.newVector3i(tonumber(mine.x2), tonumber(mine.y2), tonumber(mine.z2))
        item.effect = mine.effect
        item.yaw = tonumber(mine.yaw)
        item.itemId = tonumber(mine.itemId)
        item.num = tonumber(mine.num)
        item.damage = tonumber(mine.damage)
        item.score=tonumber(mine.score)
        self.mines[#self.mines + 1] = item
    end
end

function MineResourceConfig:prepareMines()
    for _, mine in pairs(self.mines) do
        GameMineResource.new(mine)
    end
end

return MineResourceConfig