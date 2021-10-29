local task = require("scripts.task")

local actions = {}

--- @param Gui NewTaskGui
function actions.close(Gui)
  Gui:destroy()
end

--- @param Gui NewTaskGui
function actions.recenter(Gui)
  Gui.refs.window.force_auto_center()
end

--- @param Gui NewTaskGui
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

--- @param Gui NewTaskGui
function actions.confirm(Gui)
  local refs = Gui.refs

  local is_private = refs.private_checkbox.state
  local owner = is_private and Gui.player or Gui.player.force

  local assignee
  local assignee_dropdown = refs.assignee_dropdown
  local selected_index = assignee_dropdown.selected_index
  if selected_index > 1 then
    assignee = game.players[assignee_dropdown.items[selected_index]]
  end

  task.new(refs.title_textfield.text, refs.description_textfield.text, owner, assignee)

  Gui:destroy()
end

return actions
