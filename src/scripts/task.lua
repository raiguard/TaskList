local util = require("scripts.util")

--- @class Task
local Task = {}

--- Delete the task and remove it from all GUIs.
function Task:delete()
  global.tasks[self.id] = nil

  for player_index in pairs(global.players) do
    local Gui = util.get_gui(player_index, "tasks")
    if Gui then
      Gui:delete_task(self.id)
    end
  end
end

local task = {}

--- @param title string
--- @param description string
--- @param owner LuaForce|LuaPlayer
function task.new(title, description, owner)
  local id = global.next_task_id
  global.next_task_id = id + 1

  --- @type Task
  local self = {
    completed = false,
    -- deadline = deadline,
    description = description,
    id = id,
    owner = owner,
    -- play_notification = play_notification,
    subtasks = {}, --- @type number[]
    title = title,
  }

  setmetatable(self, { __index = Task })

  global.tasks[id] = self

  -- TODO: This is code smell
  for player_index in pairs(global.players) do
    local TasksGui = util.get_gui(player_index, "tasks")
    if TasksGui then
      TasksGui:add_task(self)
    end
  end

  return self
end

--- @param Task Task
function task.load(Task)
  setmetatable(Task, { __index = Task })
end

return task
