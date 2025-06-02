--region *.lua

PlayerClassInfo = {}
PlayerClassInfo.Classes = {}

function PlayerClassInfo:addClasses(platformId, classInfo)
    self.Classes[tostring(platformId)] = classInfo
end

function PlayerClassInfo:getClasses(platformId)
    return self.Classes[tostring(platformId)]
end

function PlayerClassInfo:removeClasses(platformId)
    self.Classes[tostring(platformId)] = nil
end

--endregion
