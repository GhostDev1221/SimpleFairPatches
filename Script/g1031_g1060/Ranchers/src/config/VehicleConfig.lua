VehicleConfig = {}
VehicleConfig.vehicles = {}

function VehicleConfig:init(config)
    for i, v in pairs(config) do
        local vehicle = {}
        vehicle.type = tonumber(v.type)
        vehicle.pos = VectorUtil.newVector3(tonumber(v.x), tonumber(v.y), tonumber(v.z))
        vehicle.yaw = tonumber(v.yaw)
        table.insert(self.vehicles, vehicle)
    end
end

function VehicleConfig:prepareVehicle()
    for i, vehicle in pairs(self.vehicles) do
        vehicle.entityId = EngineWorld:addVehicleNpc(vehicle.pos, vehicle.type, vehicle.yaw)
    end
end

return VehicleConfig