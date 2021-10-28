local task = require("scripts.task")

local actions = {}

--- @param Gui NewTaskGui
function actions.close(Gui)
  Gui:destroy()
end

--- @param Gui NewTaskGui
function actions.confirm(Gui)
  local refs = Gui.refs

  task.new(refs.title_textfield.text, refs.description_textfield.text)

  Gui:destroy()
end

return actions
