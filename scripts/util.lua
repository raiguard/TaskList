local table = require("__flib__.table")

local util = {}

--- Create a local flying text with an error sound.
--- @param player LuaPlayer
--- @param text LocalisedString
function util.error_text(player, text)
  player.create_local_flying_text({ create_at_cursor = true, text = text })
  player.play_sound({ path = "utility/cannot_build" })
end

--- Get the force for the player, accounting for Editor Extensions.
--- @param player LuaPlayer
--- @return LuaForce
function util.get_force(player)
  local interface = remote.interfaces["EditorExtensions"]
  if interface and interface.get_player_proper_force then
    return remote.call("EditorExtensions", "get_player_proper_force", player)
  end
  local force = player.force --[[@as LuaForce]]
  if string.find(force.name, "bpsb%-") then
    local proper_name = string.match(force.name, "bpsb%-sb%-f%-(.*)")
    if proper_name then
      force = game.forces[proper_name]
    end
  end
  return force
end

--- @class GuiIdent
--- @field name string
--- @field id string|number

--- Safely retrieve the GUI for the given player.
--- @param player_index number
--- @param gui_name string
--- @return EditTaskGui|TasksGui?
function util.get_gui(player_index, gui_name)
  local player_table = storage.players[player_index]
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

  local completed_flow = flow.completed --[[@as LuaGuiElement]]
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
