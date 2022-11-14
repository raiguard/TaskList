local constants = require("__TaskList__.constants")

local task = require("__TaskList__.scripts.task")
local util = require("__TaskList__.scripts.util")

local actions = {}

--- @param Gui EditTaskGui
function actions.close(Gui)
  if Gui.state.just_confirmed then
    Gui.state.just_confirmed = false
    Gui.player.opened = Gui.refs.window
  else
    Gui:destroy()
  end
end

--- @param Gui EditTaskGui
function actions.recenter(Gui)
  Gui.refs.window.force_auto_center()
end

--- @param Gui EditTaskGui
function actions.update_assignee_dropdown(Gui)
  local dropdown = Gui.refs.assignee_dropdown

  local is_private = Gui.refs.private_checkbox.state
  if is_private then
    dropdown.enabled = false
    dropdown.selected_index = Gui.state.player_selection_index
  else
    dropdown.enabled = true
  end
end

--- @param Gui EditTaskGui
--- @param e on_gui_confirmed|CustomInputEvent
function actions.confirm(Gui, _, e)
  local refs = Gui.refs
  local clicked = e.name == defines.events.on_gui_confirmed or e.name == defines.events.on_gui_click

  local title = refs.title_textfield.text
  if #title == 0 then
    util.error_text(Gui.player, { "message.tlst-task-must-have-title" })
    if not clicked then
      Gui.state.just_confirmed = true
    end
    return
  end

  local assignee
  local assignee_dropdown = refs.assignee_dropdown
  local selected_index = assignee_dropdown.selected_index
  if selected_index > 1 then
    assignee = game.players[assignee_dropdown.items[selected_index]]
  end

  local status_index = refs.status_dropdown.selected_index
  local status
  for status_name, status_info in pairs(constants.task_status) do
    if status_info.index == status_index then
      status = status_name
    end
  end

  local Task = Gui.state.task
  if Task then
    Task:update(refs.title_textfield.text, refs.description_textfield.text, assignee, status)
  else
    local owner = Gui.state.parent_task
    if not owner then
      local is_private = refs.private_checkbox.state
      owner = is_private and Gui.player or util.get_force(Gui.player)
    end

    task.new(
      refs.title_textfield.text,
      refs.description_textfield.text,
      owner,
      assignee,
      status,
      refs.add_to_top_checkbox.state
    )
  end

  if clicked then
    Gui:destroy()
  end
end

--- @param Gui EditTaskGui
function actions.delete(Gui)
  local Task = Gui.state.task
  Task:delete()

  Gui:destroy()
end

return actions
