ExpConfig = {}
ExpConfig.exp = {}

function ExpConfig:initConfig(exps)
    for i, exp in pairs(exps) do
        local data = {}
        data.exp_lv = tonumber(exp.exp_lv) or 0
        data.exp_max = exp.exp_max or ""
        data.max_hp = tonumber(exp.max_hp) or 1
        
        table.insert(self.exp, data)
    end
    table.sort(self.exp, function(a, b)
        return a.exp_lv < b.exp_lv
    end)
end

function ExpConfig:getMaxExp(exp_lv)
    for _, exp in pairs(self.exp) do
        if tonumber(exp.exp_lv) == tonumber(exp_lv) then
            if tostring(exp.exp_max) == "###" then
                return 1, true
            else
                return tonumber(exp.exp_max), false
            end
        end
    end
    return 1, false
end

function ExpConfig:getMaxHp(level)
    for _, exp in pairs(self.exp) do
        if tonumber(exp.exp_lv) == tonumber(level) then
            return tonumber(exp.max_hp)
        end
    end
    return 1
end



return ExpConfig