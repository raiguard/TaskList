local util = {}

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

return util
