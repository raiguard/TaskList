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
  -- TODO:
end

return player_data
