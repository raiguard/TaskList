local util = {}

--- Safely retrieve the tasks GUI for the given player.
--- @param player_index number
--- @return TasksGui
function util.get_tasks_gui(player_index)
  local player_table = global.players[player_index]
  if player_table then
    local Gui = player_table.guis.tasks
    if Gui and Gui.refs.window.valid then
      return Gui
    end
  end
end

return util
