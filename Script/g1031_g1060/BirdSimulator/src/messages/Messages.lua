---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:11
---
require "base.messages.TextFormat"

Messages = {}

function Messages:gamename()
    return TextFormat:getTipType(1041001)
end

function Messages:backpackFull()
    return 1041002
end

function Messages:notEnoughFruit()
    return 1041003
end

function Messages:notCarryBird()
    return 1041004
end

return Messages