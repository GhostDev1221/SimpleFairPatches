--GamePlayer.lua
require "base.util.class"
require "base.data.BasePlayer"
require "data.GameTeam"
require "base.web.WebService"
require "base.messages.IMessages"
require "base.code.GameOverCode"
require "config.SnowballSpeed"
require "config.ScoreConfig"
require "Match"

GamePlayer = class("GamePlayer", BasePlayer)

function GamePlayer:init()

    self:initStaticAttr()

    self.team = {}
    self:initTeam()

    self.kills = 0
    self.score = 0
    self.lastKillTime = 0
    self.multiKill = 0
    self.isLogout = false
    self.lastSpawn = os.time()

    self:teleInitPos()
    self:initInvItem()
    self:initScorePoint()
end

function GamePlayer:initScorePoint()
    self.scorePoints[ScoreID.KILL] = 0
    self.scorePoints[ScoreID.SERIAL_KILL] = 0
end
function GamePlayer:initInvItem()
    self:addItem(269, 1, 0)
    if self.staticAttr.supperPlayer == 0 then
        self:addItem(46, 1, 0)
    end
    if self.staticAttr.supperPlayer == 1 then
        self:addItem(332, 30, 0)
        self:addItem(80, 64, 0)
        self:addItem(46, 2, 0)
    end
    if self.staticAttr.supperPlayer == 2 then
        self:addItem(332, 40, 0)
        self:addItem(80, 128, 0)
        self:addItem(46, 3, 0)
    end
end

function GamePlayer:addSnowball(time)
    self:addItem(332, SnowballSpeed:getSnowballCount(self.staticAttr.supperPlayer, time), 0)
end

function GamePlayer:teleInitPos()
    HostApi.resetPos(self.rakssid, self.team.initPos.x, self.team.initPos.y + 0.5, self.team.initPos.z)
end

function GamePlayer:teleRandomPos()
    local team = TeamConfig:getTeam(self.team.id);
    if team ~= nil then
        local produce = team.produce.produce
        local randomIndex = {}
        for i, v in pairs(produce) do
            table.insert(randomIndex, i);
        end
        math.randomseed(tostring(os.time()):reverse():sub(1, 7))
        local index = math.random(1, #randomIndex)
        local pos = produce[randomIndex[index]].pos
        HostApi.resetPos(self.rakssid, pos.x, pos.y + 0.5, pos.z)
    else
        self:teleInitPos()
    end

end

function GamePlayer:buildShowName()

    local nameList = {}
    local nameListNum = 1

    -- title
    if (self.staticAttr.title ~= nil) then
        nameList[nameListNum] = self.staticAttr.title
        nameListNum = nameListNum + 1
    end

    if self.staticAttr.role ~= -1 then
        local clanTitle = TextFormat.colorGreen .. self.staticAttr.clanName
        if self.staticAttr.role == 0 then
            clanTitle = clanTitle .. TextFormat.colorWrite .. "[Member]"
        end
        if self.staticAttr.role == 10 then
            clanTitle = clanTitle .. TextFormat.colorRed .. "[Elder]"
        end
        if self.staticAttr.role == 20 then
            clanTitle = clanTitle .. TextFormat.colorOrange .. "[Chief]"
        end
        nameList[nameListNum] = clanTitle
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

    nameList[nameListNum] = TextFormat.colorWrite .. disName
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

function GamePlayer:getDisplayName()
    if self.team ~= nil then
        return self.team:getDisplayName() .. TextFormat.colorWrite .. self.name
    else
        return self.name
    end
end

function GamePlayer:initTeam()
    local team = GameMatch.Teams[self.dynamicAttr.team]
    if team == nil then
        local config = TeamConfig:getTeam(self.dynamicAttr.team)
        team = GameTeam.new(config)
        GameMatch.Teams[config.id] = team
    end
    team:addPlayer()
    self.team = team
end

function GamePlayer:onLogout()
    if self.isLogout == false then
        self.isLogout = true
        self.team:subPlayer()
    end
end

function GamePlayer:onKill()

    self.team:addKillNum()

    self.kills = self.kills + 1
    self.score = self.score + ScoreConfig.KILL_SCORE
    self.scorePoints[ScoreID.KILL] = self.scorePoints[ScoreID.KILL] + 1
    if self.multiKill == 0 then
        self.multiKill = 1
    else
        if os.time() - self.lastKillTime <= 30 then
            self.multiKill = self.multiKill + 1
            self.scorePoints[ScoreID.SERIAL_KILL] = self.scorePoints[ScoreID.SERIAL_KILL] + 1
        else
            self.multiKill = 1
        end
    end

    self.lastKillTime = os.time()

    if self.multiKill >= 5 then
        self.score = self.score + ScoreConfig.KILL_5_SCORE
        MsgSender.sendMsg(IMessages:msgFiveKill(self:getDisplayName()))
    elseif self.multiKill >= 4 then
        self.score = self.score + ScoreConfig.KILL_4_SCORE
        MsgSender.sendMsg(IMessages:msgThirdKill(self:getDisplayName()))
    elseif self.multiKill >= 3 then
        self.score = self.score + ScoreConfig.KILL_4_SCORE
        MsgSender.sendMsg(IMessages:msgThirdKill(self:getDisplayName()))
    elseif self.multiKill >= 2 then
        self.score = self.score + ScoreConfig.KILL_2_SCORE
        MsgSender.sendMsg(IMessages:msgDoubleKill(self:getDisplayName()))
    end

end

function GamePlayer:onWin()
    self.score = self.score + ScoreConfig.WIN_SCORE
end

function GamePlayer:onDie()
    HostApi.sendRespawnCountDown(self.rakssid, 3)
end

function GamePlayer:onGameEnd(win)
    self:reward(win, GameMatch:getPlayerRank(self), true)
end

function GamePlayer:overGame(death, win)
    self:onLogout()
    if death then
        HostApi.sendGameover(self.rakssid, IMessages:msgGameOverDeath(), GameOverCode.GameOver)
    else
        if win then
            HostApi.sendGameover(self.rakssid, IMessages:msgGameOverWin(), GameOverCode.GameOver)
        else
            HostApi.sendGameover(self.rakssid, IMessages:msgGameOver(), GameOverCode.GameOver)
        end
    end
end

function GamePlayer:reward(isWin, rank, isEnd)

    if RewardManager:isUserRewardFinish(self.userId) then
        return
    end

    UserExpManager:addUserExp(self.userId, isWin, 2)

    if isWin then
        HostApi.sendPlaySound(self.rakssid, 10023)
    else
        HostApi.sendPlaySound(self.rakssid, 10024)
    end
    if isEnd then
        return
    end
    RewardManager:getUserReward(self.userId, rank, function(data)

    end)
end

function GamePlayer:onQuit()
    local isCount = 0
    if RewardManager:isUserRewardFinish(self.userId) then
        isCount = 1
    end
    ReportManager:reportUserData(self.userId, self.kills, GameMatch:getPlayerRank(self), isCount)
end

return GamePlayer

--endregion
