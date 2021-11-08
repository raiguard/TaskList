local table = require("__flib__.table")

local util = {}

--- Create a local flying text with an error sound.
--- @param player LuaPlayer
--- @param text LocalisedString
function util.error_text(player, text)
  player.create_local_flying_text({ create_at_cursor = true, text = text })
  player.play_sound({ path = "utility/cannot_build" })
end

--- Safely retrieve the GUI for the given player.
--- @param player_index number
--- @param gui_name string
--- @return TasksGui
function util.get_gui(player_index, gui_name)
  local player_table = global.players[player_index]
  if player_table then
    local Gui = player_table.guis[gui_name]
    if Gui and Gui.refs.window.valid then
      return Gui
    end
  end
end

function util.remove_task(source, task_id)
  table.remove(source, table.find(source, task_id))
end

return util
