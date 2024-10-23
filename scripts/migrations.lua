local player_data = require("scripts.player-data")

local migrations = {}

function migrations.generic()
  for i, player_table in pairs(storage.players) do
    player_data.refresh(game.get_player(i), player_table)
  end
end

migrations.versions = {
  ["0.2.0"] = function()
    for _, task in pairs(storage.tasks) do
      task.status = "not_started"
    end
  end,
  ["0.2.4"] = function()
    -- Create data tables for any forces that were missed
    for _, force in pairs(game.forces) do
      if not storage.forces[force.index] then
        storage.forces[force.index] = {
          completed_tasks = {},
          tasks = {},
        }
      end
    end
  end,
}

return migrations
