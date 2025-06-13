local table = require("__flib__.table")

local util = require("scripts.util")

--- @alias TaskID integer

--- @class Task: LuaObject
--- @field assignee LuaPlayer?
--- @field priority string
--- @field area string
--- @field completed boolean
--- @field completed_tasks TaskID[]
--- @field description string
--- @field id TaskID
--- @field object_name "Task"
--- @field owner LuaForce|LuaPlayer|Task
--- @field owner_table ForceTable|PlayerTable|Task
--- @field status string
--- @field tasks TaskID[]
--- @field title string
local Task = {}

--- Update the task info and refresh all GUIs
--- @param title string
--- @param description string
--- @param assignee LuaPlayer|nil
--- @param status string
function Task:update(title, description, assignee, status, priority, area)
    self.title = title
    self.description = description
    self.assignee = assignee
    self.status = status
    self.priority = priority
    self.area = area

    self:update_guis(function(Gui)
        Gui:update_task(self)
    end)
end

--- Delete the task and remove it from all GUIs.
function Task:delete()
    for _, subtasks in pairs({self.completed_tasks, self.tasks}) do
        for _, task_id in pairs(subtasks) do
            local subtask = storage.tasks[task_id]
            if subtask then
                subtask:delete()
            end
        end
    end

    storage.tasks[self.id] = nil

    local owner_table = self.owner_table
    local tasks_table = owner_table[self.completed and "completed_tasks" or "tasks"]
    table.remove(tasks_table, table.find(tasks_table, self.id))

    self:update_guis(function(Gui)
        Gui:delete_task(self)
    end)
end

function Task:toggle_completed()
    local owner_table = self.owner_table

    self.completed = not self.completed

    if self.completed then
        util.remove_task(owner_table.tasks, self.id)
        table.insert(owner_table.completed_tasks, 1, self.id)
    else
        util.remove_task(owner_table.completed_tasks, self.id)
        table.insert(owner_table.tasks, self.id)
    end

    self:update_guis(function(Gui)
        Gui:delete_task(self, not self.completed)
        Gui:add_task(self, self.completed and 1 or nil)
    end)
end

--- @param delta number
function Task:move(delta)
    local tasks_table = self.owner_table[self.completed and "completed_tasks" or "tasks"]
    local index = table.find(tasks_table, self.id)
    if index then
        if index + delta > 0 and index + delta <= #tasks_table then
            tasks_table[index] = tasks_table[index + delta]
            tasks_table[index + delta] = self.id

            self:update_guis(function(Gui)
                Gui:move_task(self, delta)
            end)
        end
    end
end

--- @param callback fun(Gui: EditTaskGui|TasksGui)
function Task:update_guis(callback)
    local players = {}

    -- Get ultimate owner
    local owner = self.owner
    while owner.object_name == "Task" do
        owner = owner.owner
    end

    if owner.object_name == "LuaForce" then
        for player_index, player in pairs(game.players) do
            if util.get_force(player).index == owner.index then
                table.insert(players, player_index)
            end
        end
    elseif owner.valid then
        players = {owner.index}
    end

    for _, player_index in pairs(players) do
        local Gui = util.get_gui(player_index, "tasks")
        if Gui then
            callback(Gui)
        end
    end
end

local task = {}

--- @param title string
--- @param description string
--- @field priority int
--- @field area string
--- @param owner LuaForce|LuaPlayer|Task
--- @param assignee LuaPlayer|nil
--- @param status string
--- @param add_to_top boolean
function task.new(title, description, owner, assignee, status, add_to_top, priority, area)
    local id = storage.next_task_id
    storage.next_task_id = id + 1

    local owner_table

    if owner.object_name == "Task" then
        owner_table = owner
    elseif owner.object_name == "LuaForce" then
        owner_table = storage.forces[owner.index]
    else
        owner_table = storage.players[owner.index]
    end

    --- If `owner` is a `LuaPlayer`, then `assignee` will always be the same `LuaPlayer`.
    --- @type Task
    local self = {
        assignee = assignee,
        completed = false,
        completed_tasks = {},
        description = description,
        id = id,
        priority = priority,
        area = area,
        object_name = "Task",
        owner = owner,
        owner_table = owner_table,
        status = status,
        tasks = {},
        title = title
    }

    if add_to_top then
        table.insert(owner_table.tasks, 1, self.id)
    else
        table.insert(owner_table.tasks, self.id)
    end

    task.load(self)

    storage.tasks[id] = self

    self:update_guis(function(Gui)
        Gui:add_task(self, add_to_top and 1 or nil)
    end)

    return self
end

--- @param self Task
function task.load(self)
    setmetatable(self, {
        __index = Task
    })
end

return task
