data:extend({
  { type = "custom-input", name = "tlst-toggle-gui", key_sequence = "CONTROL + T", action = "lua" },
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
