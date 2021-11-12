local player_data = require("scripts.player-data")

local migrations = {}

function migrations.generic()
  for i, player_table in pairs(global.players) do
    player_data.refresh(game.get_player(i), player_table)
  end
end

migrations.versions = {
  ["0.2.0"] = function()
    for _, task in pairs(global.tasks) do
      task.status = "not_started"
    end
  end,
}

return migrations
