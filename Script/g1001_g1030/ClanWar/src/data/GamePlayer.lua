--GamePlayer.lua
require "base.util.class"
require "base.data.BasePlayer"
require "base.web.WebService"
require "base.messages.IMessages"
require "base.code.GameOverCode"
require "config.TeamConfig"
require "data.GameTeam"
require "Match"

GamePlayer = class("GamePlayer", BasePlayer)

function GamePlayer:init()

    self:initStaticAttr()

    self.team = {}
    self.isLogout = false

    self:initTeam()
    self:reset()

end

function GamePlayer:buildShowName()

    local nameList = {}
    local nameListNum = 1

    if self.staticAttr.clanName ~= nil and #self.staticAttr.clanName > 0 then
        nameList[nameListNum] = TextFormat.colorGreen .. "[" .. self.staticAttr.clanName .. "]"
        nameListNum = nameListNum + 1
    end

    --superPlayer
    if (self.staticAttr.supperPlayer > 0) then

        local spTitle = "SuperPlayer"
        if (self.staticAttr.supperPlayer == 2) then
            spTitle = "SuperPlayer+"
        end
        nameList[nameListNum] = TextFormat.colorYellow .. spTitle
        nameListNum = nameListNum + 1
    end

    -- title
    if (self.staticAttr.title ~= nil) then
        nameList[nameListNum] = self.staticAttr.title
        nameListNum = nameListNum + 1
    end

    -- pureName line
    local disName = TextFormat.colorWrite .. self.name;

    if (self.staticAttr.lv > 0) then
        disName = TextFormat.colorGold .. "[Lv" .. tostring(self.staticAttr.lv) .. "]" .. TextFormat.colorWrite .. self.name
    end

    if self.team ~= nil then
        disName = disName .. self.team:getDisplayName()
    end

    nameList[nameListNum] = disName
    nameListNum = nameListNum + 1

    --rebuild name
    local showName
    for i, v in pairs(nameList) do
        local lineName = v
        if (showName == nil) then
            showName = lineName
        else
            showName = showName .. "\n" .. lineName;
        end
    end

    HostApi.log(showName)
    return showName
end

function GamePlayer:reset()
    self.kills = 0
    self.dies = 0
    self.score = 0
    self.flags = 0
    self:teleInitPos()
    self:resetInv()
    self:resetFood()
    self:initScorePoint()
end

function GamePlayer:initScorePoint()
    self.scorePoints[ScoreID.KILL] = 0
    self.scorePoints[ScoreID.DIE] = 0
end

function GamePlayer:resetFood()
    local foodStats = self.entityPlayerMP:getFoodStats()
    foodStats:setFoodLevel(20)
end

function GamePlayer:initItems()
    for i, v in pairs(GameConfig.initItems) do
        self:addItem(v.id, v.num, 0)
    end
end

function GamePlayer:initTeam()
    local team = GameMatch.Teams[self.dynamicAttr.team]
    if team ~= nil then
        team:addPlayer()
        self.team = team
    else
        HostApi.sendGameover(self.rakssid, IMessages:msgGameOver(), GameOverCode.NoThisTeam)
    end
end

function GamePlayer:resetInv()
    self:clearInv()
    self:initItems()
end

function GamePlayer:clearInv()
    if self.entityPlayerMP ~= nil then
        local inv = self.entityPlayerMP:getInventory()
        inv:clear()
    end
end

function GamePlayer:getDisplayName()
    return self.team:getDisplayName() .. TextFormat.colorWrite .. self.name
end

function GamePlayer:teleInitPos()
    HostApi.resetPos(self.rakssid, self.team.initPos.x, self.team.initPos.y + 0.5, self.team.initPos.z)
end

function GamePlayer:onLogout()
    if self.isLogout == false then
        self.isLogout = true
        self.team:subPlayer()
    end
end

function GamePlayer:onDie()
    HostApi.sendRespawnCountDown(self.rakssid, 3)
    self.dies = self.dies + 1
    if self.score + GameMatch.SCORE_DIE < 0 then
        self.score = 0
    else
        self.score = self.score + GameMatch.SCORE_DIE
    end
    self.team:onPlayerDeath()
    self.scorePoints[ScoreID.DIE] = self.scorePoints[ScoreID.DIE] + 1
end

function GamePlayer:onKill()
    self.kills = self.kills + 1
    self.score = self.score + GameMatch.SCORE_KILL
    self.team:onPlayerKill()
    self.scorePoints[ScoreID.KILL] = self.scorePoints[ScoreID.KILL] + 1
end

function GamePlayer:onPlaceFlag()
    self.flags = self.flags + 1
    self.score = self.score + GameMatch.SCORE_FLAG
end

return GamePlayer

--endregion
