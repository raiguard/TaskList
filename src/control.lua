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

  for _, player in pairs(game.players) do
    player_data.init(player)
  end

  migrations.generic()
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
    if msg.gui == "main" then
      -- TODO: Make this a util function
      -- Phobos would be really nice here...
      local player_table = global.players[e.player_index]
      if player_table then
        local Gui = player_table.guis.main
        if Gui then
          Gui:dispatch(msg, e)
        end
      end
    end
  end
end)

event.register("tlst-toggle-gui", function(e)
  local player_table = global.players[e.player_index]
  if player_table and player_table.guis.main then
    player_table.guis.main:toggle()
  end
end)

-- PLAYER

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)

  player_data.init(player)
  player_data.refresh(player, global.players[e.player_index])
end)
