local constants = require("constants")

local edit_task_gui = require("scripts.gui.edit-task.index")
local util = require("scripts.util")

local actions = {}

local function toggle_fab(elem, sprite, state)
  if state then
    elem.style = "flib_selected_frame_action_button"
    elem.sprite = sprite .. "_black"
  else
    elem.style = "frame_action_button"
    elem.sprite = sprite .. "_white"
  end
end

--- @param Gui TasksGui
function actions.recenter(Gui)
  Gui.refs.window.force_auto_center()
end

--- @param Gui TasksGui
function actions.close(Gui)
  Gui:close()
end

--- @param Gui TasksGui
function actions.pin(Gui)
  Gui.state.pinned = not Gui.state.pinned

  toggle_fab(Gui.refs.pin_button, "flib_pin", Gui.state.pinned)

  if Gui.state.pinned then
    Gui.state.ignore_close = true
    Gui.player.opened = nil
  else
    Gui.player.opened = Gui.refs.window
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
      set_private = not Task and not ParentTask and Gui.refs.visibility_switch.switch_state == "right",
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

  -- TEMPORARY:
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

return actions
