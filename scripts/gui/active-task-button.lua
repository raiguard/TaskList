local gui = require("__flib__/gui")
local mod_gui = require("__core__/lualib/mod-gui")

local active_task_button = {}

--- @param player LuaPlayer
--- @param player_table PlayerTable
function active_task_button.build(player, player_table)
  local button = player_table.guis.active_task_button
  if not button or not button.valid then
    button = gui.add(mod_gui.get_button_flow(player), {
      type = "button",
      style = mod_gui.button_style,
      style_mods = { left_padding = 8, right_padding = 8 },
      actions = {
        on_click = { gui = "tasks", action = "toggle" },
      },
    })

    player_table.guis.active_task_button = button
  end

  active_task_button.update(player, player_table)
end

--- @param player LuaPlayer
--- @param player_table PlayerTable
function active_task_button.update(player, player_table)
  local button = player_table.guis.active_task_button
  if button and button.valid then
    local tasks
    if player.mod_settings["tlst-show-active-task"].value == "force" then
      tasks = global.forces[player.force.index].tasks
    else
      tasks = player_table.tasks
    end
    -- The "active" task is the first top-level active task we come across
    for _, task_id in pairs(tasks) do
      local Task = global.tasks[task_id]
      if Task and Task.status == "in_progress" then
        button.caption = Task.title
        return
      end
    end
    button.caption = { "gui.tlst-no-active-task" }
  end
end

--- @param player_table PlayerTable
function active_task_button.destroy(player_table)
  local button = player_table.guis.active_task_button
  if button then
    if button.valid then
      button.destroy()
    end
    player_table.guis.active_task_button = nil
  end
end

return active_task_button
