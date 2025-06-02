---
--- Created by Jimmy.
--- DateTime: 2017/10/19 0019 10:38
---

VectorUtil = {}

function VectorUtil.newVector3i(x, y, z)
    local vec = Vector3i.new()
    vec.x = x
    vec.y = y
    vec.z = z
    return vec
end

function VectorUtil.newVector3(x, y, z)
    local vec3 = Vector3.new()
    vec3.x = x
    vec3.y = y
    vec3.z = z
    return vec3
end

function VectorUtil.toVector3(vec3i)
    local vec3 = Vector3.new()
    vec3.x = vec3i.x
    vec3.y = vec3i.y
    vec3.z = vec3i.z
    return vec3
end

function VectorUtil.toVector3i(vec3)
    local vec3i = Vector3i.new()
    vec3i.x = vec3.x
    vec3i.y = vec3.y
    vec3i.z = vec3.z
    return vec3i
end

function VectorUtil.hashVector3(vec3)
    return vec3.x .. ":" .. vec3.y .. ":" .. vec3.z
end

function VectorUtil.toBlockVector3(x, y, z)
    if x < 0 then
        x = x - 1
    end
    if y < 0 then
        y = y - 1
    end
    if z < 0 then
        z = z - 1
    end
    return VectorUtil.newVector3i(x, y, z)
end

function VectorUtil.equal(vec3_1, vec3_2)
    if vec3_1 and vec3_2 then
        return vec3_1.x == vec3_2.x and vec3_1.y == vec3_2.y and vec3_1.z == vec3_2.z
    else
        return false
    end
end

VectorUtil.ZEOR = VectorUtil.newVector3(0, 0, 0)
return VectorUtil