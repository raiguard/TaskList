local data_util = require("__flib__.data-util")

data:extend({
  { type = "custom-input", name = "tlst-toggle-gui", key_sequence = "CONTROL + T", action = "lua" },
  { type = "custom-input", name = "tlst-new-task", key_sequence = "", action = "lua" },
  { type = "custom-input", name = "tlst-linked-confirm-gui", key_sequence = "", linked_game_control = "confirm-gui" },
  {
    type = "shortcut",
    name = "tlst-toggle-gui",
    icon = { filename = "__TaskList__/graphics/tasks-dark-x32.png", size = 32, mipmap_count = 2 },
    small_icon = { filename = "__TaskList__/graphics/tasks-dark-x24.png", size = 24, mipmap_count = 2 },
    disabled_icon = { filename = "__TaskList__/graphics/tasks-light-x32.png", size = 32, mipmap_count = 2 },
    disabled_small_icon = { filename = "__TaskList__/graphics/tasks-light-x24.png", size = 24, mipmap_count = 2 },
    toggleable = true,
    associated_control_input = "tlst-toggle-gui",
    action = "lua",
  },
  {
    type = "shortcut",
    name = "tlst-new-task",
    icon = { filename = "__TaskList__/graphics/new-task-dark-x32.png", size = 32, mipmap_count = 2 },
    small_icon = { filename = "__TaskList__/graphics/new-task-dark-x24.png", size = 24, mipmap_count = 2 },
    disabled_icon = { filename = "__TaskList__/graphics/new-task-light-x32.png", size = 32, mipmap_count = 2 },
    disabled_small_icon = { filename = "__TaskList__/graphics/new-task-light-x24.png", size = 24, mipmap_count = 2 },
    toggleable = true,
    associated_control_input = "tlst-new-task",
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

styles.tlst_description_frame = {
  type = "frame_style",
  bottom_padding = 6,
  left_padding = 8,
  right_padding = 8,
  top_padding = 4,
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

styles.tlst_red_dialog_button = {
  type = "button_style",
  parent = "dialog_button",
  default_graphical_set = styles.red_button.default_graphical_set,
  hovered_graphical_set = styles.red_button.hovered_graphical_set,
  clicked_graphical_set = styles.red_button.clicked_graphical_set,
}

styles.tlst_tasks_scroll_pane = {
  type = "scroll_pane_style",
  parent = "flib_naked_scroll_pane",
  top_padding = 2,
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 0,
  },
}
