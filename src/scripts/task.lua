local util = require("scripts.util")

--- @class Task
local Task = {}

--- Delete the task and remove it from all GUIs.
function Task:delete()
  global.tasks[self.id] = nil

  for player_index in pairs(global.players) do
    local Gui = util.get_tasks_gui(player_index)
    if Gui then
      Gui:delete_task(self.id)
    end
  end
end

local task = {}

--- @param title string
--- @param description string
--- @param deadline number
--- @param play_notification boolean
function task.new(title, description, deadline, play_notification)
  local id = global.next_task_id
  global.next_task_id = id + 1

  --- @type Task
  local self = {
    completed = false,
    deadline = deadline,
    description = description,
    id = id,
    owner = nil, --- @type LuaPlayer|nil
    play_notification = play_notification,
    private = false,
    subtasks = {}, --- @type number[]
    title = title,
  }

  setmetatable(self, { __index = Task })

  global.tasks[id] = self

  return self
end

--- @param Task Task
function task.load(Task)
  setmetatable(Task, { __index = Task })
end

return task
