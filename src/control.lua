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

  DESIGN NOTES:
  - Each task will have an entirely unique ID
    - Store the next ID in the root of `global`
  - Tasks will be stored in a one-dimensional table keyed by task ID
  - Player `tasks` tables will simply be lists of task IDs
  - Changing task ownership is facilitated simply by manipulating these IDs
  - However, this poses a problem of reverse lookup - we will have to keep a table of task -> locations as well
  - Each task only has one owner?
  - A task can have infinite subtasks
    - Subtasks are just pointers to other tasks, so they support the full feature suite, including more subtasks
    - Subtasks are only displayed by their titles in the tasks list
  - Any task can be opened in a new GUI to view its details, including subtasks
  - Investigate PRing `swap_children()` and `move_child()` functions to the LuaGuiElement API
]]

local event = require("__flib__.event")
local gui = require("__flib__.gui")
local migration = require("__flib__.migration")

local migrations = require("scripts.migrations")
local new_task_gui = require("scripts.gui.new-task.index")
local player_data = require("scripts.player-data")
local task = require("scripts.task")
local tasks_gui = require("scripts.gui.tasks.index")
local util = require("scripts.util")

-- BOOTSTRAP

event.on_init(function()
  global.next_task_id = 1
  global.tasks = {}
  global.players = {}

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
    if player_table.guis.new_task then
      new_task_gui.load(player_table.guis.new_task)
    end
  end
end)

event.on_configuration_changed(function(e)
  if migration.on_config_changed(e, migrations.versions) then
    migrations.generic()
  end
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

event.register("tlst-toggle-gui", function(e)
  local player_table = global.players[e.player_index]
  if player_table and player_table.guis.tasks then
    player_table.guis.tasks:toggle()
  end
end)

-- PLAYER

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)

  player_data.init(player)
  player_data.refresh(player, global.players[e.player_index])
end)
