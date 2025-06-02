--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

require "base.messages.TextFormat"

Messages = {}

function Messages:gamename()
    return TextFormat:getTipType(31);
end

function Messages:breakBed(team, destroy)
    return team..TextFormat.argsSplit..destroy;
end

function Messages:getStoreName(type)
    local name = "";
    if GameConfig.isChina then
        if type == 1 then
            name = name .. "防具"
        elseif type == 2 then
            name = name .. "武器"
        elseif type == 3 then
            name = name .. "方块"
        elseif type == 4 then
            name = name .. "食物"
        else
            name = name .. "其他"
        end
    else
        if type == 1 then
            name = name .. "Armor"
        elseif type == 2 then
            name = name .. "Arms"
        elseif type == 3 then
            name = name .. "Block"
        elseif type == 4 then
            name = name .. "Food"
        else
            name = name .. "Other"
        end
    end
    return name
end

function Messages:msgUpgrade(name, goods)
    return 70, name..TextFormat.argsSplit..goods;
end

function Messages:msgStore()
    return TextFormat:getTipType(68);
end

function Messages:msgIronMoney()
    return TextFormat:getTipType(71);
end

function Messages:msgGoldMoney()
    return TextFormat:getTipType(72);
end

function Messages:msgPublicMoney()
    return TextFormat:getTipType(69);
end

function Messages:EnchantMentOpen()
    return 1008001
end

function Messages:EnchantMentLeftTime(time)
    return 1008002, tonumber(time)
end

function Messages:EnchantMentConsumeLack()
    return 1008003
end

return Messages


--endregion
