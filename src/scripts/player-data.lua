local tasks_gui = require("scripts.gui.tasks.index")

local player_data = {}

--- Initializes the player's `global` table.
--- @param player LuaPlayer
function player_data.init(player)
  --- @class PlayerTable
  global.players[player.index] = {
    completed_tasks = {},
    flags = {},
    guis = {
      --- @type table<number, TaskGui>
      task = {},
    },
    tasks = {},
  }
end

--- Refreshes the player's data, including GUIs, based on changes.
--- @param player LuaPlayer
--- @param player_table PlayerTable
function player_data.refresh(player, player_table)
  local Gui = player_table.guis.tasks
  if Gui then
    Gui:destroy()
  end

  tasks_gui.new(player, player_table)
end

return player_data
