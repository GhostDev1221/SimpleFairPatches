require "base.util.class"

EventCallback = class("EventCallback")

function EventCallback:ctor(func,obj)
    self.callback = func
    self.obj = obj
end

function EventCallback:Invoke(...)
    if type(self.callback) == 'function' then
        if type(self.obj) == 'table' then
            self.callback(self.obj, ...)
        else
            self.callback(...)
        end
    end
end