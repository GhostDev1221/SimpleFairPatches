--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "config.GameConfig"
require "base.messages.TextFormat"

Messages = {}

function Messages:gamename()
    return TextFormat:getTipType(55);
end

function Messages:msgGameData(teamMsg, score)
    return 56, teamMsg .. TextFormat.argsSplit .. tostring(score);
end

return Messages


--endregion
