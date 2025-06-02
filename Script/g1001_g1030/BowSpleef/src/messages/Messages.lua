--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "config.GameConfig"
require "base.messages.TextFormat"

Messages = {}

function Messages:gamename()
    return TextFormat:getTipType(34);
end

function Messages:msgGameData(players, seconds, score)
    return 35, players .. TextFormat.argsSplit .. seconds .. TextFormat.argsSplit .. score;
end

return Messages


--endregion
