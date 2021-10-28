local player_data = require("scripts.player-data")

local migrations = {}

function migrations.generic()
  for i, player_table in pairs(global.players) do
    player_data.refresh(game.get_player(i), player_table)
  end
end

migrations.versions = {}

return migrations
