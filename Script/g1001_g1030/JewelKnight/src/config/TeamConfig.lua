require "config.SessionNpcConfig"

TeamConfig = {}
TeamConfig.teams = {}

function TeamConfig:initTeams(teams)
    for _, team in pairs(teams) do
        local data = {}
        data.id = tonumber(team.id)
        data.name = tostring(team.name)
        data.initPos = VectorUtil.newVector3i(tonumber(team.initPositionX), tonumber(team.initPositionY), tonumber(team.initPositionZ))
        data.yaw = tonumber(team.yaw)

        local exchangePos = {}
        exchangePos[1] = {}
        exchangePos[1][1] = tonumber(team.exchangeStartX)
        exchangePos[1][2] = tonumber(team.exchangeStartY)
        exchangePos[1][3] = tonumber(team.exchangeStartZ)
        exchangePos[2] = {}
        exchangePos[2][1] = tonumber(team.exchangeEndX)
        exchangePos[2][2] = tonumber(team.exchangeEndY)
        exchangePos[2][3] = tonumber(team.exchangeEndZ)
        data.exchangePos = Area.new(exchangePos)
        data.maxResource = tonumber(team.maxResource)

        data.statueName = team.statueName
        data.statueActor = team.statueActor
        data.statuePos = VectorUtil.newVector3(tonumber(team.statuePosX + 0.5), tonumber(team.statuePosY - 2), tonumber(team.statuePosZ + 0.5))
        data.statueYaw = tonumber(team.statueYaw)
        self.teams[data.id] = data
    end
end

function TeamConfig:getTeam(id)
    local team = self.teams[id]
    if team == nil then
        team = self.teams[1]
    end
    return team
end

function TeamConfig:getTeamColor(id)
    if id == 1 then
        return TextFormat.colorRed
    elseif id == 2 then
        return TextFormat.colorBlue
    elseif id == 3 then
        return TextFormat.colorGreen
    else
        return TextFormat.colorYellow
    end
end

function TeamConfig:prepareTeamStatue()
    for _, team in pairs(self.teams) do
        team.statueEntityId = EngineWorld:addSessionNpc(team.statuePos, team.statueYaw, SessionNpcConfig.STATUE_NPC, team.statueName, team.statueActor, "body", "1")
    end
end

function TeamConfig:getStatueByEntityId(id)
    for _, team in pairs(self.teams) do
        if team.statueEntityId == id then
            return team
        end
    end

    return nil
end
return TeamConfig