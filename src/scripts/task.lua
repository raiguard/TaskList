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
--- @param assignee LuaPlayer|nil
--- @param add_to_top boolean
function task.new(title, description, owner, assignee, add_to_top)
  local id = global.next_task_id
  global.next_task_id = id + 1

  --- If `owner` is a `LuaPlayer`, then `assignee` will always be the same `LuaPlayer`.
  --- @type Task
  local self = {
    assignee = assignee,
    completed = false,
    description = description,
    id = id,
    owner = owner,
    subtasks = {}, --- @type number[]
    title = title,
  }

  setmetatable(self, { __index = Task })

  global.tasks[id] = self

  -- TODO: This is the logical place to put this, but it feels like code smell
  if owner.object_name == "LuaForce" then
    for player_index, player in pairs(game.players) do
      if player.force == owner then
        local TasksGui = util.get_gui(player_index, "tasks")
        if TasksGui then
          TasksGui:add_task(self, add_to_top and 1 or nil)
        end
      end
    end
  else
    local TasksGui = util.get_gui(owner.index, "tasks")
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
