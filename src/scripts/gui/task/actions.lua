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

return actions
