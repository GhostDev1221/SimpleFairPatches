--GameConfig.lua
require "base.util.tinyyaml"
require "base.util.VectorUtil"

GameConfig = {}
GameConfig.isChina = false
GameConfig.RootPath = ""

GameConfig.waitingPlayerTime = 0
GameConfig.prepareTime = 0
GameConfig.gameTime = 0
GameConfig.gameOverTime = 0

GameConfig.initPos = {}
GameConfig.floorY = {}

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

    GameConfig.initPos = VectorUtil.newVector3i(tinyObj.initPos[1], tinyObj.initPos[2], tinyObj.initPos[3])
    GameConfig.floorY.F1 = tonumber(tinyObj.floorY.F1)
    GameConfig.floorY.F2 = tonumber(tinyObj.floorY.F2)
    GameConfig.floorY.F3 = tonumber(tinyObj.floorY.F3)
    GameConfig.floorY.F4 = tonumber(tinyObj.floorY.F4)

end

function GameConfig:getFloorNum(y)
    if y >= self.floorY.F4 then
        return 4
    elseif y >= self.floorY.F3 then
        return 3
    elseif y >= self.floorY.F2 then
        return 2
    elseif y >= self.floorY.F1 then
        return 1
    else
        return 0
    end
end

return GameConfig