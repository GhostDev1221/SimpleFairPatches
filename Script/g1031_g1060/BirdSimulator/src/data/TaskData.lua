require "manager.TaskHelper"
require "data.EventCallback"
TaskData = class("TaskData")

local taskTypeFunc = nil
function TaskData:ctor(contentId, task)

    self.contentId = contentId
    local config = TaskConfig:getTaskContentById(self.contentId)
    if config == nil then
        return
    end
    self.id = config.id
    self.number = config.num
    self.color = config.color
    self.bindTaskId = task.taskId
    self.type = config.type
    self.curNumber = 0
    self.bindNpcId = task.bindNpcId
    self.name = ""
    self.desc = config.desc
    self.taskType = task:getTaskType()
    self.taskKey = ""
    self:create()
    if taskTypeFunc == nil then
        taskTypeFunc = {}
        taskTypeFunc[TaskType.HaveLevelBirdEvent] = self.HaveBirdEvent
        taskTypeFunc[TaskType.FeedBirdEvent] = self.DesignationIdNumber
        taskTypeFunc[TaskType.CollectFieldFruitEvent] = self.DesignationIdNumber
        taskTypeFunc[TaskType.BeaMonsterTaskEvent] = self.DesignationIdNumber
        taskTypeFunc[TaskType.CollectPropEvent] = self.DesignationIdNumber
        taskTypeFunc[TaskType.NpcDialogueEvent] = self.DesignationIdNumber
        taskTypeFunc[TaskType.GetItemByOpenChestEvent] = self.DesignationIdNumber
        taskTypeFunc[TaskType.CompleteNpcTaskNumEvent] = self.DesignationIdNumber
        taskTypeFunc[TaskType.DrawLuckyEvent] = self.DesignationIdNumber

        taskTypeFunc[TaskType.HaveBirdShellsEvent] = self.HaveBirdShellEvent
        taskTypeFunc[TaskType.CollectFruitByNum] = self.DesignationNumber
        taskTypeFunc[TaskType.HaveChestEvent] = self.DesignationNumber
        taskTypeFunc[TaskType.CollectFruitByColor] = self.DesignationIdColor
    end
end

function TaskData:create()
    self.desc = "tastlang_type_" .. self.type
    if type(self.id) == "table" and next(self.id) then
        if self.type == 6 then
            self.name = self.id[1]
        else
            self.name = "tastlang_id_" .. self.id[1]
        end
    elseif type(self.color) == "number" then
        self.name = "tastlang_id_" .. self.color
    else
        self.name = ""
    end
end

function TaskData:Init(rakssid)
    self.taskKey = string.format("%s:%d:%d", tostring(rakssid), self.bindTaskId, self.contentId)
    self.bindRakssid = rakssid
    local player = PlayerManager:getPlayerByRakssid(self.bindRakssid)
    if player == nil then
        return
    end
    local taskCon = player:getTaskControl()
    local func = taskTypeFunc[self.type]
    local listener = TaskHelper[self.type]
    if type(listener) == "table" and type(func) == "function" then
        listener:push(self.taskKey, func, self)
    end
    taskCon:PushTaskContent(self.taskKey, self, self.bindTaskId) -- 储存任务的key  方便玩家退出的时候移除
end

function TaskData:OnCreateSuccess()
    local player = PlayerManager:getPlayerByRakssid(self.bindRakssid)
    if self.type == TaskType.HaveLevelBirdEvent then
        self:HaveBirdEvent(self.bindRakssid)
    end
    if self.type == TaskType.HaveBirdShellsEvent then
       self:HaveBirdShellEvent(self.bindRakssid)
    end
end

function TaskData:IsComplete()
    return self.curNumber >= self.number
end

function TaskData:CheckTask()
    local player = PlayerManager:getPlayerByRakssid(self.bindRakssid)
    if player == nil then
        return
    end
    local taskCon = player:getTaskControl()
    taskCon:cacheRefreshTask(self.bindTaskId, self.bindNpcId)
    return false
end

function TaskData:HaveBirdEvent(rakssid)
    if self.bindRakssid ~= rakssid then
        return false
    end
    local player = PlayerManager:getPlayerByRakssid(self.bindRakssid)
    local level = self.id[1]
    if type(level) == "number" then
        if player ~= nil then
            self.curNumber = player.userBird:getBirdsNumByLevel(level)
            return self:CheckTask()
        end
    end
    return false
end

function TaskData:HaveBirdShellEvent(rakssid)
    if self.bindRakssid ~= rakssid then
        return false
    end
    local player = PlayerManager:getPlayerByRakssid(self.bindRakssid)
    if player == nil then
        return false
    end
    self.curNumber = player.userBirdBag.maxCarryBirdNum
    return self:CheckTask()
end
-- 指定id和数量
function TaskData:DesignationIdNumber(rakssid, id, num)
    if self.bindRakssid ~= rakssid then
        return false
    end
    for k, v in pairs(self.id) do
        if v == id then
            self.curNumber = self.curNumber + num
            return self:CheckTask()
        end
    end
    return false
end
-- 指定 数量 颜色
function TaskData:DesignationIdColor(rakssid, num, color)
    if self.bindRakssid ~= rakssid then
        return false
    end
    if self.color ~= color then
        return false
    end
    self.curNumber = self.curNumber + num
    return self:CheckTask()
end
-- 指定id
function TaskData:DesignationId(rakssid, id)
    if self.bindRakssid ~= rakssid then
        return false
    end
    if self.id ~= id then
        return false
    end
    for k, v in pairs(self.id) do
        if v == id then
            self.curNumber = self.curNumber + 1
            return self:CheckTask()
        end
    end
    return false
end
-- 指定数量
function TaskData:DesignationNumber(rakssid, num)
    if self.bindRakssid ~= rakssid then
        return false
    end
    self.curNumber = self.curNumber + num
    return self:CheckTask()
end

-- function TaskData:DesignationNotAdd(rakssid, num)
--     if self.bindRakssid ~= rakssid then
--         return false
--     end
--     self.curNumber = num
--     return self:CheckTask()
-- end
