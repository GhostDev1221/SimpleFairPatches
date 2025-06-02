--GameConfig.lua
require "base.util.tinyyaml"
require "config.TeamConfig"
require "config.RespawnConfig"

GameConfig = {}
GameConfig.isChina = false
GameConfig.RootPath = ""
GameConfig.waitingPlayerTime = 0
GameConfig.disableMoveTime = 0
GameConfig.prepareTime = 0
GameConfig.gameTime = 0
GameConfig.gameOverTime = 0
GameConfig.ffStartTime = 0
GameConfig.ffTime = 0
GameConfig.inventory = {}
GameConfig.inventory[1] = {}
GameConfig.inventory[1].RefreshTime = 0

GameConfig.initPos = {}
GameConfig.ffPos = {}

GameConfig.inventory = {}
GameConfig.inventory[1] = {}
GameConfig.inventory[1].fixedItems = {}
GameConfig.inventory[1].foodNumRange = {}
GameConfig.inventory[1].food = {}
GameConfig.inventory[1].equipNumRange = {}
GameConfig.inventory[1].equip = {}
GameConfig.inventory[1].weaponNumRange = {}
GameConfig.inventory[1].weapon = {}
GameConfig.inventory[1].materialsNumRange = {}
GameConfig.inventory[1].materials = {}
GameConfig.inventory[1].pos = {}

GameConfig.sppItems = {}
GameConfig.clzItems = {}

function GameConfig:init()
    local configPath = self.RootPath
    local file = io.open(configPath, "r")
    local fileStream = file.read(file, "*a")
    local tinyObj = TinyParse(fileStream)

    self.waitingPlayerTime = tonumber(tinyObj.waitingPlayerTime)
    self.disableMoveTime = tonumber(tinyObj.disableMoveTime)
    self.prepareTime = tonumber(tinyObj.prepareTime)
    self.gameTime = tonumber(tinyObj.gameTime)
    self.gameOverTime = tonumber(tinyObj.gameOverTime)
    self.ffStartTime = tonumber(tinyObj.ffStartTime)
    self.ffTime = tonumber(tinyObj.ffTime)
    self.inventory[1].RefreshTime = tonumber(tinyObj.inventory[1].RefreshTime)

    for i, v in pairs(tinyObj.initPos) do
        self.initPos[i] = {}
        self.initPos[i].use = false
        self.initPos[i].x = tonumber(v.x)
        self.initPos[i].y = tonumber(v.y)
        self.initPos[i].z = tonumber(v.z)
    end

    for i, v in pairs(tinyObj.ffPos) do
        self.ffPos[i] = {}
        self.ffPos[i].use = false
        self.ffPos[i].x = tonumber(v.x)
        self.ffPos[i].y = tonumber(v.y)
        self.ffPos[i].z = tonumber(v.z)
    end

    self.inventory[1].foodNumRange[1] = tonumber(tinyObj.inventory[1].foodNumRange[1])
    self.inventory[1].foodNumRange[2] = tonumber(tinyObj.inventory[1].foodNumRange[2])
    for i, v in pairs(tinyObj.inventory[1].food) do
        self.inventory[1].food[i] = {}
        self.inventory[1].food[i].id = tonumber(v.id)
        self.inventory[1].food[i].randomRange = {}
        self.inventory[1].food[i].randomRange[1] = tonumber(v.randomRange[1])
        self.inventory[1].food[i].randomRange[2] = tonumber(v.randomRange[2])
        self.inventory[1].food[i].probability = tonumber(v.probability)
    end

    self.inventory[1].equipNumRange[1] = tonumber(tinyObj.inventory[1].equipNumRange[1])
    self.inventory[1].equipNumRange[2] = tonumber(tinyObj.inventory[1].equipNumRange[2])
    for i, v in pairs(tinyObj.inventory[1].equip) do
        self.inventory[1].equip[i] = {}
        self.inventory[1].equip[i].id = tonumber(v.id)
        self.inventory[1].equip[i].randomRange = {}
        self.inventory[1].equip[i].randomRange[1] = tonumber(v.randomRange[1])
        self.inventory[1].equip[i].randomRange[2] = tonumber(v.randomRange[2])
        self.inventory[1].equip[i].probability = tonumber(v.probability)
    end

    self.inventory[1].materialsNumRange[1] = tonumber(tinyObj.inventory[1].materialsNumRange[1])
    self.inventory[1].materialsNumRange[2] = tonumber(tinyObj.inventory[1].materialsNumRange[2])
    for i, v in pairs(tinyObj.inventory[1].materials) do
        self.inventory[1].materials[i] = {}
        self.inventory[1].materials[i].id = tonumber(v.id)
        self.inventory[1].materials[i].randomRange = {}
        self.inventory[1].materials[i].randomRange[1] = tonumber(v.randomRange[1])
        self.inventory[1].materials[i].randomRange[2] = tonumber(v.randomRange[2])
        self.inventory[1].materials[i].probability = tonumber(v.probability)
    end

    self.inventory[1].weaponNumRange[1] = tonumber(tinyObj.inventory[1].weaponNumRange[1])
    self.inventory[1].weaponNumRange[2] = tonumber(tinyObj.inventory[1].weaponNumRange[2])
    for i, v in pairs(tinyObj.inventory[1].weapon) do
        self.inventory[1].weapon[i] = {}
        self.inventory[1].weapon[i].id = tonumber(v.id)
        self.inventory[1].weapon[i].randomRange = {}
        self.inventory[1].weapon[i].randomRange[1] = tonumber(v.randomRange[1])
        self.inventory[1].weapon[i].randomRange[2] = tonumber(v.randomRange[2])
        self.inventory[1].weapon[i].probability = tonumber(v.probability)
    end


    for i, v in pairs(tinyObj.inventory[1].pos) do
        self.inventory[1].pos[i] = {}
        self.inventory[1].pos[i].x = tonumber(v.x)
        self.inventory[1].pos[i].y = tonumber(v.y)
        self.inventory[1].pos[i].z = tonumber(v.z)
    end

    local sppi = 0
    for i, v in pairs(tinyObj.sppItems) do
        sppi = sppi + 1
        self.sppItems[sppi] = {}
        self.sppItems[sppi].id = tonumber(i)
        self.sppItems[sppi].num = tonumber(v)
    end

    for i, v in pairs(tinyObj.clzItems) do
        self.clzItems[i] = {}

        local clzi = 0
        for si, sv in pairs(v) do
            clzi = clzi + 1
            self.clzItems[i][clzi] = {}
            self.clzItems[i][clzi].id = tonumber(si)
            self.clzItems[i][clzi].num = tonumber(sv)
        end
    end

    TeamConfig:init()
    RespawnConfig:init(tinyObj.respawn)

end

function GameConfig:getValidInitPos()
    for i, v in pairs(self.initPos) do
        if (v.use == false) then
            return i
        end
    end
    return math.random(1, #self.initPos)
end

function GameConfig:getValidffPos()
    for i, v in pairs(self.ffPos) do
        if (v.use == false) then
            return i
        end
    end
    return math.random(1, #self.ffPos)
end

return GameConfig