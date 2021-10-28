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
]]

local event = require("__flib__.event")
local gui = require("__flib__.gui")
local migration = require("__flib__.migration")

local migrations = require("scripts.migrations")
local player_data = require("scripts.player-data")

-- BOOTSTRAP

event.on_init(function()
  global.players = {}

  for player in pairs(game.players) do
    player_data.init(player)
  end

  migrations.generic()
end)

event.on_configuration_changed(function(e)
  if migration.on_config_changed(e, migrations.versions) then
    migrations.generic()
  end
end)

-- PLAYER

event.on_player_created(function(e)
  player_data.init(game.get_player(e.player_index))
end)
