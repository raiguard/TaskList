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

--- Update completed visibility for all subtasks
--- @param flow LuaGuiElement
--- @param to_state boolean
function util.recursive_show_completed(flow, to_state)
  for _, row in pairs(flow.incompleted.children) do --- @diagnostic disable-line
    util.recursive_show_completed(row.details_flow.subtasks_flow, to_state)
  end

  local completed_flow = flow.completed --- @diagnostic disable-line
  if to_state and #completed_flow.children > 0 then
    completed_flow.visible = true

    for _, row in pairs(completed_flow.children) do
      util.recursive_show_completed(row.details_flow.subtasks_flow, to_state)
    end
  else
    completed_flow.visible = false
  end
end

function util.remove_task(source, task_id)
  table.remove(source, table.find(source, task_id))
end

return util
