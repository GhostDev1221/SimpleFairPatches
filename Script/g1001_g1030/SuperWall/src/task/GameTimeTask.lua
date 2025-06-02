--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
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

--endregion
