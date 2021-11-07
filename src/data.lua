local data_util = require("__flib__.data-util")

data:extend({
  { type = "custom-input", name = "tlst-toggle-gui", key_sequence = "CONTROL + T", action = "lua" },
  {
    type = "shortcut",
    name = "tlst-toggle-gui",
    localised_name = { "mod-name.TaskList" },
    icon = { filename = data_util.empty_image, size = 1, scale = 16 },
    toggleable = true,
    associated_control_input = "tlst-toggle-gui",
    action = "lua",
  },
  {
    type = "sprite",
    name = "tlst_arrow_up",
    filename = "__TaskList__/graphics/tool-icons.png",
    position = { 0, 0 },
    size = 32,
    mipmap_count = 2,
    flags = { "icon" },
  },
  {
    type = "sprite",
    name = "tlst_arrow_down",
    filename = "__TaskList__/graphics/tool-icons.png",
    position = { 0, 32 },
    size = 32,
    mipmap_count = 2,
    flags = { "icon" },
  },
  {
    type = "sprite",
    name = "tlst_arrow_right",
    filename = "__TaskList__/graphics/tool-icons.png",
    position = { 0, 64 },
    size = 32,
    mipmap_count = 2,
    flags = { "icon" },
  },
})

local styles = data.raw["gui-style"]["default"]

styles.tlst_inside_shallow_frame_with_spacing = {
  type = "frame_style",
  parent = "inside_shallow_frame_with_padding",
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 8,
  },
}

styles.tlst_description_frame = {
  type = "frame_style",
  padding = 0,
  graphical_set = {
    base = {
      position = { 85, 0 },
      corner_size = 8,
      center = { position = { 42, 8 }, width = 1, height = 1 },
      draw_type = "outer",
    },
    shadow = default_inner_shadow,
  },
}
