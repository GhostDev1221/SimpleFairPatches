---
--- Created by Jimmy.
--- DateTime: 2017/10/20 0020 14:49
---

require "base.util.VectorUtil"
require "base.messages.TextFormat"

TeamConfig  = {}

TeamConfig.teams = {}

function TeamConfig:initTeams(teams)
    for i, v in pairs(teams) do
        self.teams[v.id] = {}
        self.teams[v.id].id = v.id
        self.teams[v.id].name = v.name
        self.teams[v.id].initPos = VectorUtil.newVector3i(tonumber(v.initPos[1]), tonumber(v.initPos[2]), tonumber(v.initPos[3]))
        self.teams[v.id].storePos = VectorUtil.newVector3(tonumber(v.storePos[1]), tonumber(v.storePos[2]), tonumber(v.storePos[3]))
        self.teams[v.id].storeYaw = tonumber(v.storePos[4])
        self.teams[v.id].storeName = v.storeName
        self.teams[v.id].ironPos = VectorUtil.newVector3(tonumber(v.ironPos[1]), tonumber(v.ironPos[2]), tonumber(v.ironPos[3]))
        self.teams[v.id].goldPos = VectorUtil.newVector3(tonumber(v.goldPos[1]), tonumber(v.goldPos[2]), tonumber(v.goldPos[3]))
        self.teams[v.id].bedPos = {}
        self.teams[v.id].bedPos[1] = VectorUtil.newVector3i(tonumber(v.bedPos[1][1]), tonumber(v.bedPos[1][2]), tonumber(v.bedPos[1][3]))
        self.teams[v.id].bedPos[2] = VectorUtil.newVector3i(tonumber(v.bedPos[2][1]), tonumber(v.bedPos[2][2]), tonumber(v.bedPos[2][3]))
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

return TeamConfig