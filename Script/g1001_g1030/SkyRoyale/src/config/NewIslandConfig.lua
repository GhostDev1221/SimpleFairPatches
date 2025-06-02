NewIslandConfig = {}
NewIslandConfig.islandWall = {}

function NewIslandConfig:initIslandWall(config)
    for i, v in pairs(config) do
        local data = {}
        data.fileName = v.fileName
        data.pos = VectorUtil.newVector3i(v.pos[1], v.pos[2], v.pos[3])
        data.time = tonumber(v.time)
        data.message = v.message or 0
        data.position = v.position or 0
        self.islandWall[i] = data
    end
end

function NewIslandConfig:generateIslandWall()
    for i, v in pairs(self.islandWall) do
        EngineWorld:getWorld():createOrDestroyHouseFromSchematic(v.fileName, v.pos, false, false, true)
    end
end

function NewIslandConfig:deleteIslandWall(time)
    for i, v in pairs(self.islandWall) do
        if v.time == time then
            EngineWorld:getWorld():createOrDestroyHouseFromSchematic(v.fileName, v.pos, false, false, false)
            if v.message ~= 0 then
                if v.position == 1 then
                    MsgSender.sendMsg(Messages:startMessage(v.message))
                elseif v.position == 2 then
                    MsgSender.sendTopTips(GameConfig.gameTipShowTime, Messages:startMessage(v.message))
                elseif v.position == 3 then
                    MsgSender.sendBottomTips(GameConfig.gameTipShowTime, Messages:startMessage(v.message))
                elseif v.position == 4 then
                    MsgSender.sendCenterTips(GameConfig.gameTipShowTime, Messages:startMessage(v.message))
                else
                    MsgSender.sendMsg(Messages:startMessage(v.message))
                end
            end
        end
    end
end

return NewIslandConfig