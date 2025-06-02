---
--- Created by Jimmy.
--- DateTime: 2018/2/2 0002 15:39
---
VehicleConfig = {}
VehicleConfig.vehicles = {}

function VehicleConfig:init(config)
    self:initVehicle(config.vehicle)
end

function VehicleConfig:initVehicle(config)
    for i, v in pairs(config) do
        local vehicle = {}
        vehicle.id = tonumber(v.id)
        vehicle.pos = VectorUtil.newVector3(tonumber(v.pos[1]), tonumber(v.pos[2]), tonumber(v.pos[3]))
        vehicle.yaw = tonumber(v.pos[4])
        self.vehicles[i] = vehicle
    end
end

function VehicleConfig:prepareVehicle()
    for i, vehicle in pairs(self.vehicles) do
        vehicle.entityId = EngineWorld:addVehicleNpc(vehicle.pos, vehicle.id, vehicle.yaw)
    end
end

function VehicleConfig:checkAndResetPosition()
    for i, vehicle in pairs(self.vehicles) do
        if EngineWorld:getWorld():hasPlayerByVehicle(vehicle.entityId) == false then
            EngineWorld:getWorld():resetVehiclePosition(vehicle.entityId, vehicle.pos)
        end
    end
end

return VehicleConfig