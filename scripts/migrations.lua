local player_data = require("__TaskList__.scripts.player-data")

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
  ["0.2.4"] = function()
    -- Create data tables for any forces that were missed
    for _, force in pairs(game.forces) do
      if not global.forces[force.index] then
        global.forces[force.index] = {
          completed_tasks = {},
          tasks = {},
        }
      end
    end
  end,
}

return migrations
