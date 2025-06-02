---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:11
---
require "base.messages.TextFormat"

Messages = {}

function Messages:gamename()
    return TextFormat:getTipType(10042001)
end

return Messages