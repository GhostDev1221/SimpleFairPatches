--GameConfig.lua
require "base.util.tinyyaml"
require "base.util.VectorUtil"
require "config.TeamConfig"

GameConfig = {}
GameConfig.isChina = false
GameConfig.RootPath = ""

GameConfig.gameTime = 0
GameConfig.gameOverTime = 0
GameConfig.resetTime = 0

GameConfig.startPlayers = 0

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

GameConfig.initItems = {}
GameConfig.sppItems = {}
GameConfig.clzItems = {}

function GameConfig:init()

    local configPath = self.RootPath
    local file = io.open(configPath, "r")
    local fileStream = file.read(file, "*a")
    local tinyObj = TinyParse(fileStream)

    self.gameTime = tonumber(tinyObj.gameTime)
    self.gameOverTime = tonumber(tinyObj.gameOverTime)
    self.resetTime = tonumber(tinyObj.resetTime)
    self.startPlayers = tonumber(tinyObj.startPlayers)

    local initItemi = 0
    for i, v in pairs(tinyObj.initItem) do
        initItemi = initItemi + 1
        self.initItems[initItemi] = {}
        self.initItems[initItemi].id = tonumber(i)
        self.initItems[initItemi].num = tonumber(v)
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

    TeamConfig:initTeams(tinyObj.TeamInfo)

end

return GameConfig