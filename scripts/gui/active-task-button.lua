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
--- @param Task Task
--- @return boolean
local function can_show_task(player, Task)
  if not Task then
    return false
  end
  if Task.status ~= "in_progress" then
    return false
  end
  if player.mod_settings["tlst-active-filter-assigned"].value then
    if Task.assignee == nil then
      return false
    end
    return Task.assignee.index == player.index
  end

  return true
end

--- @param player LuaPlayer
--- @param player_table PlayerTable
function active_task_button.update(player, player_table)
  
  local button = player_table.guis.active_task_button
  if button and button.valid then
    local tasks
    if player.mod_settings["tlst-show-active-task"].value == "force" then
      tasks = global.forces[player.force.index].tasks
    elseif player.mod_settings["tlst-show-active-task"].value == "off" then
      active_task_button.destroy(player,player_table)
    else
      tasks = player_table.tasks
    end
    -- The "active" task is the first top-level active task we come across
    for _, task_id in pairs(tasks) do
      local Task = global.tasks[task_id]
      if can_show_task(player, Task) then
        button.caption = Task.title
        return
      end
    end
    button.caption = { "gui.tlst-no-active-task" }
  end
end

--- @param player_table PlayerTable
function active_task_button.destroy(player,player_table)
  
  local button = player_table.guis.active_task_button


  if button then
    
    if button.valid then
      
      button.destroy()
      
    end
    player_table.guis.active_task_button = nil
  end


  
  local gui = player.gui.top
  mod_gui_button_flow = gui.mod_gui_button_flow
  if mod_gui_button_flow then
    if #mod_gui_button_flow.children_names == 0 then
       mod_gui_button_flow.destroy()
    end
  end
  top_frame = gui.mod_gui_top_frame
  if top_frame then
    inner_frame = top_frame.mod_gui_inner_frame
     if inner_frame then
        if #inner_frame.children_names == 0 then
          inner_frame.destroy()
        end
    end
        if #top_frame.children_names == 0 then
          top_frame.destroy()
        end
  end

end

return active_task_button
