--- @class Task
local Task = {}

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
