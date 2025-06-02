---
--- Created by Jimmy.
--- DateTime: 2018/1/25 0025 10:11
---
require "base.messages.TextFormat"

Messages = {}

function Messages:gamename()
    return TextFormat:getTipType(43)
end

function Messages:msgNotOperateTip()
    return 1045001
end

function Messages:msgGameStartTip()
    return 1045002
end

return Messages