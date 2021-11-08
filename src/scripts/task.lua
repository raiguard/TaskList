local table = require("__flib__.table")

local util = require("scripts.util")

--- @class Task
local Task = {}

--- Update the task info and refresh all GUIs
--- @param title string
--- @param description string
--- @param assignee LuaPlayer|nil
function Task:update(title, description, assignee)
  self.title = title
  self.description = description
  self.assignee = assignee

  self:update_guis(function(Gui)
    Gui:update_task(self)
  end)
end

--- Delete the task and remove it from all GUIs.
function Task:delete()
  global.tasks[self.id] = nil

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

function Task:update_guis(callback)
  local players = {}
  if self.owner.object_name == "LuaForce" then
    for player_index, player in pairs(game.players) do
      if player.force.index == self.owner.index then
        table.insert(players, player_index)
      end
    end
  else
    players = { self.owner.index }
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
--- @param owner LuaForce|LuaPlayer
--- @param assignee LuaPlayer|nil
--- @param add_to_top boolean
function task.new(title, description, owner, assignee, add_to_top)
  local id = global.next_task_id
  global.next_task_id = id + 1

  local owner_table = owner.object_name == "LuaForce" and global.forces[owner.index] or global.players[owner.index]

  --- If `owner` is a `LuaPlayer`, then `assignee` will always be the same `LuaPlayer`.
  --- @type Task
  local self = {
    assignee = assignee,
    completed = false,
    description = description,
    id = id,
    object_name = "Task",
    owner = owner,
    owner_table = owner_table,
    subtasks = {}, --- @type number[]
    title = title,
  }

  table.insert(owner_table.tasks, self.id)

  task.load(self)

  global.tasks[id] = self

  self:update_guis(function(Gui)
    Gui:add_task(self, add_to_top and 1 or nil)
  end)

  return self
end

--- @param self Task
function task.load(self)
  setmetatable(self, { __index = Task })
end

return task
