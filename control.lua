--[[
  DESIGN GOALS:
  - Extremely simple to-do list
  - Compact and full versions of the UI
    - Compact for reference, full for manipulation
  - Opt-in advanced features
    - Timed reminders (interval, absolute time)
    - Notifications for reminders
    - Task assignment
    - Maybe projects?
  - Current task must be easily visible in some way
    - Consider using the bottom-right of the screen for this
  - "Private" and "public" tasks
    - Private is visible only to you, public is visible to your force
  - An infinite amount of subtask nesting
  - Import and export TODOs

  DESIGN NOTES:
  - Each task will have an entirely unique ID
    - Store the next ID in the root of `global`
  - Tasks will be stored in a one-dimensional table keyed by task ID
  - Tasks can be owned by the force, or by the player
    - Player tasks will be shown separately from force tasks
  - A task can have infinite subtasks
    - Subtasks are just pointers to other tasks, so they support the full feature suite, including more subtasks
    - Subtasks may have a different assignee from their parent
  - Import and export will use the standard method
  - Each owner (force, player, or task) will have a `tasks` array containing the task IDs to show, in order
    - Subtasks are also stored in the same manner, but are in a `subtasks` table instead
  - When a task is completed, it is added to its owners `completed_tasks` array at the front
    - Completed tasks will be listed after active tasks, in the order that they were completed
    - Store completion time?
]]

local event = require("__flib__/event")
local gui = require("__flib__/gui")
local migration = require("__flib__/migration")

local active_task_button = require("__TaskList__/scripts/gui/active-task-button")
local migrations = require("__TaskList__/scripts/migrations")
local edit_task_gui = require("__TaskList__/scripts/gui/edit-task/index")
local player_data = require("__TaskList__/scripts/player-data")
local task = require("__TaskList__/scripts/task")
local tasks_gui = require("__TaskList__/scripts/gui/tasks/index")
local util = require("__TaskList__/scripts/util")

--- @param force LuaForce
local function init_force(force)
  --- @class ForceTable
  global.forces[force.index] = {
    --- @type number[]
    completed_tasks = {},
    --- @type number[]
    tasks = {},
  }
end

-- BOOTSTRAP

event.on_init(function()
  global.forces = {}
  global.next_task_id = 1
  --- @type table<uint, PlayerTable>
  global.players = {}
  --- @type table<number, Task>
  global.tasks = {}

  for _, force in pairs(game.forces) do
    init_force(force)
  end
  for _, player in pairs(game.players) do
    player_data.init(player)
  end

  migrations.generic()
end)

event.on_load(function()
  for _, Task in pairs(global.tasks) do
    task.load(Task)
  end

  for _, player_table in pairs(global.players) do
    tasks_gui.load(player_table.guis.tasks)
    if player_table.guis.edit_task then
      edit_task_gui.load(player_table.guis.edit_task)
    end
  end
end)

event.on_configuration_changed(function(e)
  if migration.on_config_changed(e, migrations.versions) then
    migrations.generic()
  end
end)

-- FORCE

event.on_force_created(function(e)
  init_force(e.force)
end)

-- INTERACTION

gui.hook_events(function(e)
  local msg = gui.read_action(e)
  if msg then
    local Gui = util.get_gui(e.player_index, msg.gui)
    if Gui then
      Gui:dispatch(msg, e)
    end
  end
end)

event.register("tlst-linked-confirm-gui", function(e)
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  local EditTaskGui = util.get_gui(e.player_index, "edit_task")
  if EditTaskGui then
    EditTaskGui:dispatch({ action = "confirm" })
    player.play_sound({ path = "utility/confirm" })
  elseif player.mod_settings["tlst-new-task-on-confirm"].value then
    local TasksGui = util.get_gui(e.player_index, "tasks")
    if TasksGui and TasksGui.state.visible and not TasksGui.state.pinned then
      TasksGui:dispatch({ action = "edit_task", confirmed = true })
    end
  end
end)

--- @param player_index uint
local function toggle_new_task(player_index)
  local EditTaskGui = util.get_gui(player_index, "edit_task")
  if EditTaskGui then
    EditTaskGui:destroy()
  else
    local player = game.get_player(player_index) --[[@as LuaPlayer]]
    local player_table = global.players[player_index]
    edit_task_gui.new(player, player_table, { standalone = true })
  end
end

event.register("tlst-new-task", function(e)
  toggle_new_task(e.player_index)
end)

event.register({ "tlst-toggle-gui", defines.events.on_lua_shortcut }, function(e)
  if (e.input_name or e.prototype_name) == "tlst-toggle-gui" then
    local player_table = global.players[e.player_index]
    local Gui = util.get_gui(e.player_index, "tasks")
    if Gui then
      Gui:toggle()
    else
      local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
      player_data.refresh(player, player_table)
    end
  elseif e.prototype_name == "tlst-new-task" then
    toggle_new_task(e.player_index)
  end
end)

-- PLAYER

event.on_player_created(function(e)
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]

  player_data.init(player)
  player_data.refresh(player, global.players[e.player_index])
end)

event.on_player_removed(function(e)
  -- Remove all player tasks
  local player_table = global.players[e.player_index]
  for _, task_ids in pairs({ player_table.completed_tasks, player_table.tasks }) do
    for _, task_id in pairs(task_ids) do
      local Task = global.tasks[task_id]
      if Task then
        Task:delete()
      end
    end
  end

  global.players[e.player_index] = nil
end)

event.on_runtime_mod_setting_changed(function(e)
  if e.setting == "tlst-new-task-on-confirm" then
    local TasksGui = util.get_gui(e.player_index, "tasks")
    if TasksGui then
      local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
      local tooltip = { "gui.tlst-new-task" }
      if player.mod_settings[e.setting].value then
        tooltip[1] = tooltip[1] .. "-instruction"
      end
      TasksGui.refs.new_task_button.tooltip = tooltip
    end
  elseif e.setting == "tlst-show-active-task" then
    local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
    local player_table = global.players[e.player_index]
    local value = player.mod_settings["tlst-show-active-task"].value
    if value == "off" then
      active_task_button.destroy(player_table)
    else
      active_task_button.build(player, player_table)
    end
  end
end)
