local main_gui = require("scripts.gui.main.index")

local player_data = {}

--- Initializes the player's `global` table.
--- @param player LuaPlayer
function player_data.init(player)
  global.players[player.index] = {
    flags = {},
    guis = {},
  }
end

--- Refreshes the player's data, including GUIs, based on changes.
--- @param player LuaPlayer
--- @param player_table PlayerTable
function player_data.refresh(player, player_table)
  local Gui = player_table.guis.main
  if Gui then
    Gui:destroy()
  end

  main_gui.new(player, player_table)
end

return player_data
