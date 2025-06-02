---
--- Created by Jimmy.
--- DateTime: 2018/9/13 0028 11:37
---
require "base.web.WebService"
require "base.task.CommonTask"
require "base.data.EngineWorld"
require "base.DBManager"

BaseListener = {}
BaseListener.callbacks = {}

function BaseListener.registerCallBack(event, func)
    BaseListener.callbacks[event] = func
end

function BaseListener:init()
    GameInitEvent.registerCallBack(self.onGameInit)
    PlayerDynamicAttrEvent.registerCallBack(self.onPlayerDynamicAttr)
    PlayerLoginEvent.registerCallBack(self.onPlayerLogin)
    PlayerLogoutEvent.registerCallBack(self.onPlayerLogout)
    PlayerReadyEvent.registerCallBack(self.onPlayerReady)
    PlayerFirstSpawnEvent.registerCallBack(self.onPlayerFirstSpawn)
    PlayerRespawnEvent.registerCallBack(self.onPlayerRespawn)
    GetDataFromDBEvent.registerCallBack(self.onGetDataFromDB)
end

function BaseListener.onGameInit(GamePath, ver, serverworld, config, initPos)
    HostApi.log(VarDump(ServerWorld))
    EngineWorld:setWorld(serverworld)
    WebService:init(ver, config)
    WebService:GetBlockymodsExpRule()
    CommonTask:start()
    PlayerManager:setMaxPlayer(config.maxPlayers)
    local callback = BaseListener.callbacks[GameInitEvent]
    if callback == nil then
        return
    end
    callback(GamePath, initPos)
end

function BaseListener.onPlayerDynamicAttr(platformId, class, team, region, pioneer, vip)
    PlayerClassInfo:addClasses(platformId, {
        class = class,
        team = team,
        region = region,
        pioneer = pioneer,
        vip = vip
    })
end

function BaseListener.onPlayerLogin(clientPeer)
    if PlayerManager:isPlayerFull() then
        HostApi.sendGameover(clientPeer:getRakssid(), IMessages:msgGamePlayerIsEnough(), GameOverCode.PlayerIsEnough)
        return true
    end
    local callback = BaseListener.callbacks[PlayerLoginEvent]
    if callback == nil then
        HostApi.sendGameover(clientPeer:getRakssid(), IMessages:msgGameOver(), GameOverCode.GameOver)
        return true
    end
    local code, player, status, c_callback = callback(clientPeer)
    if code == GameOverCode.GameStarted then
        HostApi.sendGameover(clientPeer:getRakssid(), IMessages:msgGameHasStarting(), GameOverCode.GameStarted)
        return true
    end
    if code ~= GameOverCode.Success or player == nil then
        HostApi.sendGameover(clientPeer:getRakssid(), IMessages:msgGameOver(), GameOverCode.GameOver)
        return true
    end
    PlayerManager:addPlayer(player)
    if PlayerManager:isPlayerFull() then
        HostApi.sendStartGame(PlayerManager:getPlayerCount())
    end
    if status ~= nil and status >= 1 and status <= 2 then
        HostApi.sendGameStatus(clientPeer:getRakssid(), status)
    end
    if c_callback ~= nil then
        c_callback()
    end
    return true
end

function BaseListener.onPlayerLogout(userId)
    local player = PlayerManager:getPlayerByUserId(userId)
    if player ~= nil then
        PlayerManager:subPlayer(player)
        local clear = function(player)
            player:onPlayerLogout()
            DBManager:removeCache(player.userId)
        end
        local callback = BaseListener.callbacks[PlayerLogoutEvent]
        if callback == nil then
            clear(player)
            return
        end
        callback(player)
        clear(player)
    end
    return true
end

function BaseListener.onPlayerReady(rakssid)
    local callback = BaseListener.callbacks[PlayerReadyEvent]
    if callback == nil then
        return
    end
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        HostApi.sendGameover(rakssid, IMessages:msgGameOver(), GameOverCode.ReadyNoPlayer)
        return
    end
    local time = callback(player)
    if time ~= nil and time > 0 then
        player:addNightVisionPotionEffect(time)
    end
end

function BaseListener.onPlayerFirstSpawn(clientPeer)
    local callback = BaseListener.callbacks[PlayerFirstSpawnEvent]
    if callback == nil then
        return
    end
    local player = PlayerManager:getPlayerByRakssid(clientPeer:getRakssid())
    if player == nil then
        return
    end
    callback(player)
end

function BaseListener.onPlayerRespawn(clientPeer)
    local callback = BaseListener.callbacks[PlayerRespawnEvent]
    if callback == nil then
        return
    end
    local player = PlayerManager:getPlayerByRakssid(clientPeer:getRakssid())
    if player == nil then
        return
    end
    player:respawn(clientPeer)
    local time = callback(player)
    if time ~= nil and time > 0 then
        player:addNightVisionPotionEffect(time)
    end
end

function BaseListener.onGetDataFromDB(userId, subKey, data)
    local callback = BaseListener.callbacks[GetDataFromDBEvent]
    if callback == nil then
        return
    end
    local player = PlayerManager:getPlayerByUserId(userId)
    if player ~= nil then
        DBManager:initPlayerData(userId, subKey, data)
        callback(player, subKey, data)
    end
end

return BaseListener