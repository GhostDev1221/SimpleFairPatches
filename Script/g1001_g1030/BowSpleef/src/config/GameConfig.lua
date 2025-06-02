--GameConfig.lua
require "base.util.tinyyaml"

GameConfig = {}
GameConfig.isChina = false
GameConfig.RootPath = ""

GameConfig.waitingPlayerTime = 0
GameConfig.prepareTime = 0
GameConfig.gameTime = 0
GameConfig.gameOverTime = 0

GameConfig.goldGrowth = 0
GameConfig.initGold = 1000

GameConfig.initPos = {}
GameConfig.teleportPos = {}

GameConfig.sppItems = {}
GameConfig.clzItems = {}

function GameConfig:init()
    local configPath = self.RootPath

    local file = io.open(configPath, "r")
    local fileStream = file.read(file, "*a")
    local tinyObj = TinyParse(fileStream)

    self.waitingPlayerTime = tonumber(tinyObj.waitingPlayerTime)
    self.prepareTime = tonumber(tinyObj.prepareTime)
    self.gameTime = tonumber(tinyObj.gameTime)
    self.gameOverTime = tonumber(tinyObj.gameOverTime)
    self.goldGrowth = tonumber(tinyObj.goldGrowth)

    for i, v in pairs(tinyObj.initPos) do
        self.initPos[i] = {}
        self.initPos[i].use = false
        self.initPos[i].x = tonumber(v.x)
        self.initPos[i].y = tonumber(v.y)
        self.initPos[i].z = tonumber(v.z)
    end

    for i, v in pairs(tinyObj.teleportPos) do
        self.teleportPos[i] = {}
        self.teleportPos[i].use = false
        self.teleportPos[i].x = tonumber(v.x)
        self.teleportPos[i].y = tonumber(v.y)
        self.teleportPos[i].z = tonumber(v.z)
    end
end

function GameConfig:getValidInitPos()
    for i, v in pairs(self.initPos) do
        if(v.use == false) then
            return i
        end
    end
    return math.random(1, #self.initPos)
end

function GameConfig:getValidTeleportPos()
    for i, v in pairs(self.teleportPos) do
        if(v.use == false) then
            return i
        end
    end
    return math.random(1, #self.teleportPos)
end

return GameConfig