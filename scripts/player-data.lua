local active_task_button = require("__TaskList__.scripts.gui.active-task-button")
local tasks_gui = require("__TaskList__.scripts.gui.tasks.index")

local player_data = {}

--- Initializes the player's `global` table.
--- @param player LuaPlayer
function player_data.init(player)
  --- @class PlayerTable
  global.players[player.index] = {
    --- @type number[]
    completed_tasks = {},
    flags = {},
    --- @type PlayerGuis
    guis = {},
    --- @type number[]
    tasks = {},
  }
end

--- @class PlayerGuis
--- @field active_task_button LuaGuiElement?
--- @field edit_task EditTaskGui?
--- @field tasks TasksGui?

--- Refreshes the player's data, including GUIs, based on changes.
--- @param player LuaPlayer
--- @param player_table PlayerTable
function player_data.refresh(player, player_table)
  local TasksGui = player_table.guis.tasks
  if TasksGui then
    TasksGui:destroy()
  end
  tasks_gui.new(player, player_table)

  local EditTaskGui = player_table.guis.edit_task
  if EditTaskGui then
    EditTaskGui:destroy()
  end

  active_task_button.destroy(player_table)
  if player.mod_settings["tlst-show-active-task"].value ~= "off" then
    active_task_button.build(player, player_table)
  end
end

return player_data
