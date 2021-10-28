local task = require("scripts.task")

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
    Gui.state.pinning = true
    Gui.player.opened = nil
    Gui.state.pinning = false
  else
    Gui.player.opened = Gui.refs.window
    Gui.refs.window.force_auto_center()
  end
end

--- @param Gui TasksGui
function actions.create_task(Gui)
  local refs = Gui.refs

  task.new(refs.title_textfield.text, refs.description_textfield.text)

  Gui:update_tasks()
end

--- @param Gui TasksGui
--- @param msg table
--- @param e on_gui_checked_state_changed
function actions.toggle_task_completed(Gui, msg, e)
  local task_id = msg.task_id

  local task = global.tasks[task_id]
  if task then
    task.completed = not task.completed
    e.element.state = task.completed
  end
end

return actions
