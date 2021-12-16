local constants = require("constants")

local edit_task_gui = require("scripts.gui.edit-task.index")
local util = require("scripts.util")

local actions = {}

--- @param Gui TaskGui
function actions.close(Gui)
  Gui:destroy()
end

--- @param Gui TaskGui
--- @param e on_gui_click
function actions.recenter(Gui, _, e)
  if e.button == defines.mouse_button_type.middle then
    Gui.refs.window.force_auto_center()
  end
end

--- @param Gui TasksGui
--- @param e on_gui_checked_state_changed
function actions.toggle_show_completed(Gui, _, e)
  local state = Gui.state
  state.show_completed = not state.show_completed
  e.element.state = state.show_completed

  Gui:update_show_completed()
end

--- @param Gui TasksGui
function actions.edit_task(Gui, msg)
  if not util.get_gui(Gui.player.index, "edit_task") then
    local Task = msg.task_id and global.tasks[msg.task_id] or nil
    local ParentTask = msg.parent_task_id and global.tasks[msg.parent_task_id] or nil
    edit_task_gui.new(Gui.player, Gui.player_table, {
      parent_gui = Gui,
      task = Task,
      parent_task = ParentTask,
    })
  end
end

--- @param Gui TasksGui
--- @param msg table
--- @param e on_gui_checked_state_changed
function actions.toggle_task_completed(Gui, msg, e)
  local task_id = msg.task_id

  local Task = global.tasks[task_id]
  if Task then
    Task:toggle_completed()
  end
end

--- @param Gui TasksGui
--- @param e on_gui_click
function actions.expand_task(Gui, _, e)
  local elem = e.element
  local details_flow = elem.parent.parent.details_flow

  if e.control or e.shift then
    local our_index = elem.parent.parent.get_index_in_parent()
    local delta = e.shift and 1 or -1
    elem.parent.parent.parent.swap_children(our_index + delta, our_index)
    return
  end

  details_flow.visible = not details_flow.visible
  if details_flow.visible then
    elem.sprite = "tlst_arrow_down"
  else
    elem.sprite = "tlst_arrow_right"
  end
end

--- @param Gui TasksGui
--- @param e on_gui_switch_state_changed
function actions.toggle_tasks_mode(Gui, _, e)
  local visible = e.element.switch_state == "left" and "force" or "private"

  Gui.refs.force_flow.visible = visible == "force"
  Gui.refs.private_flow.visible = visible == "private"
end

--- @param Gui TasksGui
--- @param msg table
--- @param e on_gui_click
function actions.move_task(Gui, msg, e)
  local delta = msg.delta
  local task_id = msg.task_id

  local Task = global.tasks[task_id]
  if Task then
    Task:move(delta)
  end
end

--- @param Gui TasksGui
--- @param msg table
function actions.cycle_task_status(Gui, msg)
  local Task = global.tasks[msg.task_id]
  if Task then
    local current = Task.status
    local next = next(constants.task_status, current) or next(constants.task_status)
    Task.status = next

    Task:update_guis(function(Gui)
      Gui:update_task(Task)
    end)
  end
end

--- @param Gui TasksGui
--- @param msg table
function actions.open_task_gui(Gui, msg)
  local Task = global.tasks[msg.task_id]
  if Task then
    local TaskGui = Gui.player_table.guis.task[msg.task_id]
    if not TaskGui then
      game.print("REQUIRE LOOP BABY")
      -- TaskGui = task_gui.new(Gui.player, Gui.player_table, Task)
    end
    -- TODO:
  end
end

return actions
