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
function actions.confirm(Gui)
  local refs = Gui.refs

  local is_private = refs.private_checkbox.state
  local owner = is_private and Gui.player or Gui.player.force

  task.new(refs.title_textfield.text, refs.description_textfield.text, owner)

  Gui:destroy()
end

return actions
