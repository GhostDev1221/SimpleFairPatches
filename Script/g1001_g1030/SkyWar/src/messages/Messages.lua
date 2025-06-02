--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "config.GameConfig"
require "base.messages.TextFormat"

Messages = {}

function Messages:gamename()
	return TextFormat:getTipType(57);
end

return Messages


--endregion
