---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2018/11/5 10:11
---

require "base.util.class"
require "base.task.ITask"

local CGameTimeTask = class("GameTimeTask", ITask)

function CGameTimeTask:onTick(ticks)
    GameMatch:onTick(ticks)
end

function CGameTimeTask:onCreate()
    GameMatch.curStatus = self.status
end

GameTimeTask = CGameTimeTask.new(1)

return GameTimeTask