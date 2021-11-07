local templates = {}

--- @param name string
--- @param visible boolean|nil
function templates.checkboxes_flow(name, visible)
  return {
    type = "flow",
    direction = "vertical",
    ref = { name .. "_flow" },
    { type = "flow", name = "incompleted", direction = "vertical" },
    { type = "flow", name = "completed", direction = "vertical", visible = false },
    visible = visible,
  }
end

--- @param sprite string
--- @param tooltip LocalisedString|nil
--- @param action table|nil
--- @param ref table|nil
function templates.frame_action_button(sprite, tooltip, action, ref)
  return {
    type = "sprite-button",
    style = "frame_action_button",
    sprite = sprite .. "_white",
    hovered_sprite = sprite .. "_black",
    clicked_sprite = sprite .. "_black",
    tooltip = tooltip,
    ref = ref,
    actions = {
      on_click = action,
    },
  }
end

return templates
