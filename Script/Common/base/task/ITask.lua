--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "base.util.class"

ITask = class()
ITask.timer = 0
ITask.status = 0
ITask.created = false

function ITask:ctor(status)
    self.timer = SecTimer.createTimer(function(ticks)
        if not self.created then
            self.created = true
            self:onCreate()
        end
        self:onTick(ticks)
    end)
    self.status = status
end

function ITask:onCreate()

end

function ITask:onTick(ticks)

end

function ITask:start()
    SecTimer.startTimer(self.timer)
end

function ITask:stop()
    SecTimer.stopTimer(self.timer)
end

function ITask:pureStop()
    SecTimer:stopTimer(self.timer)
end

return ITask
--endregion
